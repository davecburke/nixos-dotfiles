import QtQuick
import Quickshell
import qs.Commons

Singleton {
  id: root

  property var pluginApi: null

  Component.onCompleted: {
    if (pluginApi) {
      Logger.i("GmailNotifierCount", "Main initialized for Gmail Notifier Count plugin");
    }
  }
}
