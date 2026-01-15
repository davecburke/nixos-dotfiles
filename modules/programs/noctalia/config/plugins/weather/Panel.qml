import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Location
import qs.Widgets

// Weather Panel Component
Item {
  id: root

  property var pluginApi: null

  readonly property var geometryPlaceholder: panelContainer

  property real contentPreferredWidth: 600 * Style.uiScaleRatio
  property real contentPreferredHeight: 220 * Style.uiScaleRatio

  readonly property bool allowAttach: true

  // Weather data
  readonly property bool weatherReady: Settings.data.location.weatherEnabled && (LocationService.data.weather !== null)
  readonly property var weather: LocationService.data.weather

  anchors.fill: parent

  Component.onCompleted: {
    if (pluginApi) {
      Logger.i("Weather", "Panel initialized");
    }
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: Color.mSurface || "#1E1E1E"
    radius: Style.radiusL || 12

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL || 12
      spacing: Style.marginM || 8
      clip: true

      // Current weather section
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginL || 12

        NIcon {
          Layout.alignment: Qt.AlignVCenter
          icon: root.weatherReady ? LocationService.weatherSymbolFromCode(root.weather.current_weather.weathercode) : ""
          pointSize: Style.fontSizeXXXL * 1.75 || 56
          color: Color.mPrimary || "#2196F3"
          visible: root.weatherReady
        }

        ColumnLayout {
          spacing: Style.marginXXS || 2
          Layout.fillWidth: true

          NText {
            visible: root.weatherReady
            text: {
              if (!root.weatherReady) {
                return "";
              }
              var temp = root.weather.current_weather.temperature;
              var suffix = "C";
              if (Settings.data.location.useFahrenheit) {
                temp = LocationService.celsiusToFahrenheit(temp);
                suffix = "F";
              }
              temp = Math.round(temp);
              return `${temp}°${suffix}`;
            }
            pointSize: Style.fontSizeXL * 1.6 || 32
            font.weight: Font.Bold
            color: Color.mOnSurface || "#FFFFFF"
          }
        }
      }

      // Divider
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Color.mOutline || "#3E3E3E"
        visible: root.weatherReady
      }

      // Forecast section - 5 days (current + next 4)
      RowLayout {
        visible: root.weatherReady
        Layout.fillWidth: true
        Layout.preferredHeight: undefined
        spacing: Style.marginM || 8

        Repeater {
          model: root.weatherReady ? Math.min(5, root.weather.daily.time.length) : 0
          delegate: ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginXS || 4
            Item {
              Layout.fillWidth: true
            }
            NText {
              Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
              text: {
                var weatherDate = new Date(root.weather.daily.time[index].replace(/-/g, "/"));
                return I18n.locale.toString(weatherDate, "ddd");
              }
              color: Color.mOnSurface || "#FFFFFF"
              pointSize: Style.fontSizeS || 12
            }
            NIcon {
              Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
              icon: LocationService.weatherSymbolFromCode(root.weather.daily.weathercode[index])
              pointSize: Style.fontSizeXXL * 1.6 || 32
              color: Color.mPrimary || "#2196F3"
            }
            NText {
              Layout.alignment: Qt.AlignHCenter
              text: {
                var max = root.weather.daily.temperature_2m_max[index];
                var min = root.weather.daily.temperature_2m_min[index];
                if (Settings.data.location.useFahrenheit) {
                  max = LocationService.celsiusToFahrenheit(max);
                  min = LocationService.celsiusToFahrenheit(min);
                }
                max = Math.round(max);
                min = Math.round(min);
                return `${max}°/${min}°`;
              }
              pointSize: Style.fontSizeXS || 10
              color: Color.mOnSurfaceVariant || "#AAAAAA"
            }
          }
        }
      }

      // Loading indicator
      Loader {
        active: !root.weatherReady
        Layout.alignment: Qt.AlignCenter
        sourceComponent: NBusyIndicator {}
      }
    }
  }
}
