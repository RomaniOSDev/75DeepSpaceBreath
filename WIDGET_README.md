# Home Screen Widget

To add a **Home Screen Widget** ("Start [program]" or "Last session: -18%"):

1. In Xcode: **File → New → Target**
2. Choose **Widget Extension**, name it e.g. `DeepSpaceBreathWidget`
3. Enable **Include Configuration App Intent** if you want configurable shortcuts
4. In the widget's `TimelineProvider` / view, read shared data:
   - Use **App Groups** so the widget can read `UserDefaults(suiteName: "group.com.deepspacebreath")`
   - In the main app, write last session summary and favorite program IDs to that suite when saving a session / changing settings
   - Widget shows: "Last session: -18%" or "Quick start: Neutron Star" with a deep link URL into the app

5. **URL scheme**: In the main app's Info.plist add a URL scheme (e.g. `deepspacebreath://`) and handle `openURL` in SceneDelegate to open a specific program or the After Workout flow.

The app already stores sessions and favorites in UserDefaults; duplicate the needed keys into the App Group suite when you add the widget target.
