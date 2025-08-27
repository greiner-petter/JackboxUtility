import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel!
  private var dartQuitOK = false

  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard let flutterVC = NSApp.windows.first?.contentViewController as? FlutterViewController else { return }
    methodChannel = FlutterMethodChannel(name: "macos_channel", binaryMessenger: flutterVC.engine.binaryMessenger)

    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      if call.method == "ready_to_quit" {
        self.dartQuitOK = true
        result(nil)
      }
      result(FlutterMethodNotImplemented)
    }

    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    if dartQuitOK {
      return .terminateNow
    }
    methodChannel?.invokeMethod("request_close", arguments: nil)
    return .terminateCancel
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
