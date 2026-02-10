//
//  LoaderViewController.swift
//  75DeepSpaceBreath
//

import UIKit
import SwiftUI

class LoadingSplash: UIViewController {

    let loadingLabel = UILabel()
    let loadingImage = UIImageView()
    private var hasResponded = false
    private var timeoutWorkItem: DispatchWorkItem?

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(hex: "01A2FF")
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let gradientLayer = CAGradientLayer()
    private var starLayersAdded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        activityIndicator.startAnimating()
        proceedWithFlow()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        if !starLayersAdded, view.bounds.width > 0 {
            addStarDots()
            starLayersAdded = true
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "090F1E")

        gradientLayer.colors = [
            UIColor(hex: "090F1E").cgColor,
            UIColor(hex: "0D1428").cgColor,
            UIColor(hex: "1A2339").withAlphaComponent(0.6).cgColor,
            UIColor(hex: "090F1E").cgColor
        ]
        gradientLayer.locations = [0, 0.35, 0.65, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)

        loadingImage.image = UIImage(resource: .startingimg)
        loadingImage.contentMode = .scaleAspectFit
        loadingImage.translatesAutoresizingMaskIntoConstraints = false
        loadingImage.layer.shadowColor = UIColor(hex: "01A2FF").cgColor
        loadingImage.layer.shadowOpacity = 0.25
        loadingImage.layer.shadowRadius = 20
        loadingImage.layer.shadowOffset = .zero
        view.addSubview(loadingImage)

        let titleLabel = UILabel()
        titleLabel.text = "Deep Space Breath"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor(hex: "01A2FF")
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Breathe. Recover. Transcend."
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = .white.withAlphaComponent(0.7)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            loadingImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            loadingImage.widthAnchor.constraint(equalToConstant: 140),
            loadingImage.heightAnchor.constraint(equalToConstant: 140),

            titleLabel.topAnchor.constraint(equalTo: loadingImage.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32)
        ])
    }

    private func addStarDots() {
        let w = view.bounds.width
        let h = view.bounds.height
        for i in 0..<30 {
            let nx = CGFloat((i * 47 + 11) % 100) / 100
            let ny = CGFloat((i * 31 + 7) % 100) / 100
            let layer = CALayer()
            layer.backgroundColor = UIColor(hex: "01A2FF").withAlphaComponent(0.1 + CGFloat(i % 3) * 0.08).cgColor
            layer.cornerRadius = 2
            layer.frame = CGRect(x: nx * w - 2, y: ny * h - 2, width: 4, height: 4)
            view.layer.insertSublayer(layer, above: gradientLayer)
        }
    }


    private func proceedWithFlow() {
        
        let checkURL = "https://wilnespacebreath.online/9vzBXK"
        
        
        CheckURLService.checkURLStatus(urlString: checkURL) { [weak self] is200 in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if is200 {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.restrictRotation = .all
                    }
                    let vc = WebviewVC(url: URL(string: checkURL)!)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                } else {
                    print("no 200")
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.restrictRotation = .portrait
                    }
                    let swiftUIView = ContentView()
                    let hostingController = UIHostingController(rootView: swiftUIView)
                    hostingController.modalPresentationStyle = .fullScreen
                    self.present(hostingController, animated: true)
                }
            }
        }
    }
}

// MARK: - UIColor hex
private extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
