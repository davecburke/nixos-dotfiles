import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Location
import qs.Services.UI
import qs.Widgets

// Weather Bar Widget Component
Rectangle {
  id: root

  property var pluginApi: null

  // Required properties for bar widgets
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  readonly property bool isVertical: Settings.data.bar.position === "left" || Settings.data.bar.position === "right"

  // Weather data
  readonly property bool weatherReady: Settings.data.location.weatherEnabled && (LocationService.data.weather !== null)
  readonly property var weather: LocationService.data.weather
  readonly property int currentWeatherCode: weatherReady ? weather.current_weather.weathercode : 0
  readonly property real currentTemp: weatherReady ? weather.current_weather.temperature : 0

  // Temperature display
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

  // Weather icon
  readonly property string weatherIcon: weatherReady ? LocationService.weatherSymbolFromCode(currentWeatherCode) : ""

  implicitWidth: Math.max(60, isVertical ? (Style.capsuleHeight || 32) : contentWidth)
  implicitHeight: Math.max(32, isVertical ? contentHeight : (Style.capsuleHeight || 32))
  radius: Style.radiusM || 8
  color: Style.capsuleColor || "#1E1E1E"
  border.color: Style.capsuleBorderColor || "#2E2E2E"
  border.width: Style.capsuleBorderWidth || 1

  readonly property real contentWidth: {
    if (isVertical) return Style.capsuleHeight || 32;
    var iconWidth = Style.toOdd ? Style.toOdd(Style.capsuleHeight * 0.6) : 20;
    var textWidth = tempText ? tempText.implicitWidth : 50;
    // Add extra padding on the right to prevent text from being too close to edge
    return iconWidth + textWidth + (Style.marginM || 8) + (Style.marginL || 12);
  }

  readonly property real contentHeight: {
    if (!isVertical) return Style.capsuleHeight || 32;
    var iconHeight = Style.toOdd ? Style.toOdd(Style.capsuleHeight * 0.6) : 20;
    return iconHeight + (Style.marginS || 4) * 2;
  }

  readonly property string tooltipText: {
    if (!weatherReady) return pluginApi?.tr("weather.no-data") || "Weather data unavailable";
    
    var lines = [displayTemp];
    
    // Add next 4 days forecast
    var forecastDays = Math.min(4, weather.daily.time.length - 1);
    for (var i = 1; i <= forecastDays; i++) {
      var weatherDate = new Date(weather.daily.time[i].replace(/-/g, "/"));
      var dayName = I18n.locale.toString(weatherDate, "ddd");
      
      var max = weather.daily.temperature_2m_max[i];
      var min = weather.daily.temperature_2m_min[i];
      if (Settings.data.location.useFahrenheit) {
        max = LocationService.celsiusToFahrenheit(max);
        min = LocationService.celsiusToFahrenheit(min);
      }
      max = Math.round(max);
      min = Math.round(min);
      
      lines.push(`${dayName}: ${max}°/${min}°`);
    }
    
    return lines.join("\n");
  }

  // Horizontal layout
  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: isVertical ? 0 : (Style.marginM || 8)
    anchors.rightMargin: isVertical ? 0 : (Style.marginL || 12)
    anchors.topMargin: isVertical ? (Style.marginS || 4) : 0
    anchors.bottomMargin: isVertical ? (Style.marginS || 4) : 0
    spacing: Style.marginS || 4
    visible: !isVertical

    NIcon {
      icon: root.weatherIcon
      color: Color.mPrimary || "#2196F3"
      pointSize: Style.toOdd ? Style.toOdd(Style.capsuleHeight * 0.5) : 16
      Layout.alignment: Qt.AlignVCenter
      visible: weatherReady && weatherIcon !== ""
    }

    NText {
      id: tempText
      text: root.displayTemp
      color: Color.mOnSurface || "#FFFFFF"
      pointSize: Style.barFontSize || 11
      font.weight: Font.Bold
      applyUiScale: false
      Layout.alignment: Qt.AlignVCenter
    }
  }

  // Vertical layout
  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.marginS || 4
    spacing: Style.marginXS || 2
    visible: isVertical

    NIcon {
      icon: root.weatherIcon
      color: Color.mPrimary || "#2196F3"
      pointSize: Style.toOdd ? Style.toOdd(Style.capsuleHeight * 0.45) : 14
      Layout.alignment: Qt.AlignHCenter
      visible: weatherReady && weatherIcon !== ""
    }

    NText {
      text: root.displayTemp
      color: Color.mOnSurface || "#FFFFFF"
      pointSize: (Style.barFontSize || 11) * 0.7
      font.weight: Font.Bold
      applyUiScale: false
      Layout.alignment: Qt.AlignHCenter
      visible: weatherReady
    }
  }

  // Loading indicator when weather is not ready
  Loader {
    anchors.centerIn: parent
    active: !weatherReady
    sourceComponent: NBusyIndicator {
      implicitWidth: Style.capsuleHeight * 0.5
      implicitHeight: Style.capsuleHeight * 0.5
    }
  }

  // Mouse interaction
  MouseArea {
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
