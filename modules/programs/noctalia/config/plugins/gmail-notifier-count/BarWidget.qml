import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.System
import qs.Services.UI
import qs.Widgets

// Gmail Notifier Count Bar Widget – active + history (unseen) "Notifier for Gmail" count
Item {
  id: root

  property var pluginApi: null

  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  readonly property string screenName: screen ? screen.name : ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isVertical: barPosition === "left" || barPosition === "right"
  readonly property real barHeight: Style.getBarHeightForScreen(screenName)
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  readonly property bool hideWhenZero: cfg.hideWhenZero ?? defaults.hideWhenZero ?? false

  property int gmailUnreadCount: 0
  property int otherNotificationCount: 0

  readonly property bool hasOtherNotifications: otherNotificationCount > 0

  function isGmailNotifier(item) {
    var key = "notifier for gmail";
    var app = (item.appName || "").toLowerCase();
    var summary = (item.summary || "").toLowerCase();
    var body = (item.body || "").toLowerCase();
    return app.indexOf(key) >= 0 || summary.indexOf(key) >= 0 || body.indexOf(key) >= 0;
  }

  function updateGmailCount() {
    if (typeof NotificationService === "undefined") {
      root.gmailUnreadCount = 0;
      root.otherNotificationCount = 0;
      return;
    }
    var gmailIds = {};
    var otherIds = {};
    function scanList(list) {
      if (!list) return;
      for (var i = 0; i < list.count; i++) {
        var item = list.get(i);
        if (!item.id) return;
        if (root.isGmailNotifier(item)) {
          gmailIds[item.id] = true;
        } else {
          otherIds[item.id] = true;
        }
      }
    }
    scanList(NotificationService.activeList);
    scanList(NotificationService.historyList);
    root.gmailUnreadCount = Object.keys(gmailIds).length;
    root.otherNotificationCount = Object.keys(otherIds).length;
  }

  Connections {
    target: typeof NotificationService !== "undefined" && NotificationService ? NotificationService.activeList : null
    function onCountChanged() { root.updateGmailCount(); }
  }
  Connections {
    target: typeof NotificationService !== "undefined" && NotificationService ? NotificationService.historyList : null
    function onCountChanged() { root.updateGmailCount(); }
  }

  readonly property real visualContentWidth: {
    if (isVertical) return root.capsuleHeight;
    var iconW = Style.toOdd(root.capsuleHeight * 0.6);
    var textW = countText ? countText.implicitWidth : 24;
    return iconW + textW + Style.marginS * 2 + Style.marginM * 2;
  }

  readonly property real visualContentHeight: {
    if (!isVertical) return root.capsuleHeight;
    var iconH = Style.toOdd(root.capsuleHeight * 0.45);
    var textH = root.barFontSize * 0.65 * 1.4;
    return iconH + textH + Style.marginS * 2 + Style.marginM * 2;
  }

  readonly property real contentWidth: isVertical ? root.capsuleHeight : visualContentWidth
  readonly property real contentHeight: isVertical ? visualContentHeight : root.capsuleHeight

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  visible: !(hideWhenZero && gmailUnreadCount === 0)

  readonly property string tooltipText: gmailUnreadCount === 0
    ? "No unread Gmail notifications"
    : (gmailUnreadCount === 1 ? "1 unread Gmail notification" : (gmailUnreadCount + " unread Gmail notifications"))

  Rectangle {
    id: visualCapsule
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    width: root.contentWidth
    height: root.contentHeight
    radius: Style.radiusM
    color: root.gmailUnreadCount > 0
      ? (mouseArea.containsMouse ? Qt.lighter(Color.mError, 1.15) : Color.mError)
      : (mouseArea.containsMouse ? Color.mHover : Style.capsuleColor)
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: isVertical ? 0 : Style.marginS
      anchors.rightMargin: isVertical ? 0 : Style.marginS
      anchors.topMargin: isVertical ? Style.marginS : 0
      anchors.bottomMargin: isVertical ? Style.marginS : 0
      spacing: Style.marginXS
      visible: !isVertical

      Item {
        implicitWidth: root.capsuleHeight
        implicitHeight: root.capsuleHeight
        Layout.alignment: Qt.AlignVCenter

        NIcon {
          id: mailIconH
          icon: "mail"
          color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
          pointSize: Style.toOdd(root.capsuleHeight * 0.5)
          anchors.centerIn: parent
        }

        Rectangle {
          visible: root.hasOtherNotifications
          width: 7
          height: 7
          radius: Style.radiusXS
          color: mouseArea.containsMouse ? Color.mOnHover : Color.mPrimary
          border.color: Color.mSurface
          border.width: Style.borderS
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenterOffset: root.capsuleHeight / 4
          anchors.verticalCenterOffset: -root.capsuleHeight / 4
          z: 2
        }
      }

      NText {
        id: countText
        text: String(root.gmailUnreadCount)
        color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
        pointSize: root.barFontSize
        font.weight: Font.Bold
        applyUiScale: false
        Layout.alignment: Qt.AlignVCenter
      }
    }

    ColumnLayout {
      anchors.centerIn: parent
      spacing: Style.marginXS
      visible: isVertical

      Item {
        implicitWidth: root.capsuleHeight
        implicitHeight: root.capsuleHeight
        Layout.alignment: Qt.AlignHCenter

        NIcon {
          icon: "mail"
          pointSize: Style.toOdd(root.capsuleHeight * 0.45)
          color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
          anchors.centerIn: parent
        }

        Rectangle {
          visible: root.hasOtherNotifications
          width: 7
          height: 7
          radius: Style.radiusXS
          color: mouseArea.containsMouse ? Color.mOnHover : Color.mPrimary
          border.color: Color.mSurface
          border.width: Style.borderS
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenterOffset: root.capsuleHeight / 4
          anchors.verticalCenterOffset: -root.capsuleHeight / 4
          z: 2
        }
      }

      NText {
        text: String(root.gmailUnreadCount)
        color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
        pointSize: root.barFontSize * 0.65
        font.weight: Font.Bold
        applyUiScale: false
        Layout.alignment: Qt.AlignHCenter
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton

    onClicked: {
      var panel = typeof PanelService !== "undefined" && PanelService
        ? PanelService.getPanel("notificationHistoryPanel", root.screen)
        : null;
      if (panel && typeof panel.toggle === "function") {
        panel.toggle(root);
      } else if (panel && typeof panel.open === "function") {
        panel.open();
      }
    }

    onEntered: {
      if (root.tooltipText) {
        TooltipService.show(root, root.tooltipText, BarService.getTooltipDirection());
      }
    }

    onExited: {
      TooltipService.hide();
    }
  }

  Component.onCompleted: {
    root.updateGmailCount();
  }
}
