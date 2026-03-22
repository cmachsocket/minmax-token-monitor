import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Layouts as QtLayouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: config_page

    // These must match the entry names in main.xml
    property alias cfg_apiKey: apiKey.text
    property alias cfg_refreshInterval: refreshInterval.value

    // KCM injects cfg_*Default initial properties from kcfg entries.
    property string cfg_apiKeyDefault: ""
    property int cfg_refreshIntervalDefault: 60

    height: childrenRect.height
    width: childrenRect.width

    QtLayouts.ColumnLayout {
        anchors.fill: parent

        QtControls.Label {
            text: "API Key:"
            QtLayouts.Layout.alignment: Qt.AlignLeft
        }

        QtControls.TextField {
            id: apiKey
            placeholderText: "Enter MinMax API Key"
            echoMode: QtControls.TextField.Password
            QtLayouts.Layout.minimumWidth: 250
            QtLayouts.Layout.alignment: Qt.AlignLeft
        }

        QtControls.Label {
            text: "Refresh Interval (seconds):"
            QtLayouts.Layout.alignment: Qt.AlignLeft
        }

        QtLayouts.RowLayout {
            QtControls.SpinBox {
                id: refreshInterval
                from: 10
                to: 3600
                stepSize: 10
                QtLayouts.Layout.alignment: Qt.AlignLeft
            }
            QtControls.Label {
                text: "sec"
            }
        }
    }
}
