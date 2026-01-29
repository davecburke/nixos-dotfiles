import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Location
import qs.Services.UI
import qs.Widgets

// Weather Bar Widget Component
Item {
  id: root

  property var pluginApi: null

  // Required properties for bar widgets
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  // Bar positioning properties (per-screen for correct sizing)
  readonly property string screenName: screen?.name ?? ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isVertical: barPosition === "left" || barPosition === "right"
  readonly property real barHeight: Style.getBarHeightForScreen(screenName)
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  // Explicit content size (world-clock style): tight width, extra padding so "C" isn't on the edge
  readonly property real visualContentWidth: {
    if (isVertical) return capsuleHeight;
    var iconW = Style.toOdd(capsuleHeight * 0.6);
    var textW = tempText ? tempText.implicitWidth : 50;
    return iconW + textW + Style.marginM + Style.marginL;
  }
  readonly property real visualContentHeight: {
    if (!isVertical) return capsuleHeight;
    var iconH = Style.toOdd(capsuleHeight * 0.45);
    var textH = barFontSize * 0.7 * 1.4;
    return iconH + textH + Style.marginS * 2 + Style.marginM * 2;
  }
  readonly property real contentWidth: isVertical ? capsuleHeight : visualContentWidth
  readonly property real contentHeight: isVertical ? visualContentHeight : capsuleHeight

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  Layout.fillWidth: false
  Layout.fillHeight: false

  // Weather data
  readonly property bool weatherReady: Settings.data.location.weatherEnabled && (LocationService.data.weather !== null)
  readonly property var weather: LocationService.data.weather
  readonly property int currentWeatherCode: weatherReady ? weather.current_weather.weathercode : 0
  readonly property real currentTemp: weatherReady ? weather.current_weather.temperature : 0
  readonly property bool isDaytime: weatherReady ? weather.current_weather.is_day : true

  readonly property string displayTemp: {
    if (!weatherReady) return "--";
    var temp = currentTemp;
    var suffix = "C";
    if (Settings.data.location.useFahrenheit) {
      temp = LocationService.celsiusToFahrenheit(temp);
      suffix = "F";
    }
    temp = Math.round(temp);
    return `${temp}°${suffix}`;
  }

  readonly property string weatherIcon: weatherReady ? LocationService.weatherSymbolFromCode(currentWeatherCode, isDaytime) : ""
  readonly property string weatherDescription: weatherReady ? LocationService.weatherDescriptionFromCode(currentWeatherCode) : ""

  readonly property string tooltipText: {
    if (!weatherReady) return pluginApi?.tr("weather.no-data") || "Weather data unavailable";
    return displayTemp + " - " + weatherDescription;
  }

  Rectangle {
    id: visualCapsule
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    width: root.contentWidth
    height: root.contentHeight
    radius: Style.radiusM
    color: mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    // Horizontal layout (fill + marginM left, marginL right for padding around "23°C")
    RowLayout {
      id: row
      anchors.fill: parent
      anchors.leftMargin: isVertical ? 0 : Style.marginM
      anchors.rightMargin: isVertical ? 0 : Style.marginL
      anchors.topMargin: isVertical ? Style.marginS : 0
      anchors.bottomMargin: isVertical ? Style.marginS : 0
      spacing: Style.marginXS
      visible: !root.isVertical

      NIcon {
        icon: root.weatherIcon
        color: mouseArea.containsMouse ? Color.mOnHover : Color.mPrimary
        pointSize: Style.toOdd(root.capsuleHeight * 0.5)
        Layout.alignment: Qt.AlignVCenter
        visible: root.weatherReady && root.weatherIcon !== ""
      }

      NText {
        id: tempText
        text: root.displayTemp
        color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
        pointSize: root.barFontSize
        applyUiScale: false
        Layout.alignment: Qt.AlignVCenter
      }
    }

    // Vertical layout
    ColumnLayout {
      id: col
      anchors.centerIn: parent
      spacing: Style.marginXS
      visible: root.isVertical

      NIcon {
        icon: root.weatherIcon
        color: mouseArea.containsMouse ? Color.mOnHover : Color.mPrimary
        pointSize: Style.toOdd(root.capsuleHeight * 0.45)
        Layout.alignment: Qt.AlignHCenter
        visible: root.weatherReady && root.weatherIcon !== ""
      }

      NText {
        text: root.displayTemp
        color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
        pointSize: root.barFontSize * 0.7
        applyUiScale: false
        Layout.alignment: Qt.AlignHCenter
        visible: root.weatherReady
      }
    }

    Loader {
      anchors.centerIn: parent
      active: !root.weatherReady
      sourceComponent: NBusyIndicator {
        implicitWidth: root.capsuleHeight * 0.5
        implicitHeight: root.capsuleHeight * 0.5
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
      if (pluginApi) {
        pluginApi.openPanel(screen);
      }
    }

    onEntered: {
      if (tooltipText) {
        TooltipService.show(root, tooltipText, BarService.getTooltipDirection());
      }
    }

    onExited: {
      TooltipService.hide();
    }
  }
}
