# Dequarantine
Dequarantine is a small macOS application built in SwiftUI that automates the process of removing the "com.apple.quarantine" extended attribute from selected files.

This is useful for files downloaded from the internet, especially `.app` binaries. This application is not intended to facilitate software piracy.

## Features
- [x] Drag-and-drop functionality
- [x] Icons for drag-and-drop area
- [x] Grey overlay animation for drag-and-drop area
- [x] File picker functionality
- [x] Icon animation for file picker
- [x] Dequarantine operation
- [ ] Try to fix the multiple drag-and-drop using an event listener or callback
- [ ] Logs button that only appears when dequarantine action has been performed once
- [ ] Log dequarantine operations (clear existing log) and display text field on logs button press
- [ ] Log colors: black for info, green for success, red for failure, yellow for not quarantined
- [ ] Loading spinner during dequarantine operation
- [ ] Success animation -> checkmark.circle green
- [ ] Full failure animation -> exclamationmark.circle red
- [ ] Partial failure animation -> find the warning triangle icon yellow
- [ ] “File” menu entry to open file picker
- [ ] “Open with” functionality from Finder
- [ ] Keyboard shortcut from Finder (Command + Shift + D + Q)
- [ ] About screen
- [ ] App icon
