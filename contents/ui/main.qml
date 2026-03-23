import QtQuick
import QtQuick.Layouts as QtLayouts
import QtQuick.Controls as QtControls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    readonly property string config_apiKey: Plasmoid.configuration.apiKey || ""
    readonly property int config_refreshInterval: Plasmoid.configuration.refreshInterval || 60

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: compactRepresentation

    property string usageRatio: "0%"
    property string lastUpdated: "N/A"
    property string errorMessage: ""
    property bool isLoading: false
    property string getTotal : ""
    property string getUsage : ""

    // Colors
    readonly property string barColor: "#00D1B2"
    readonly property string bgColor: "#2D2D44"
    readonly property string textColor: "#FFFFFF"
    readonly property string subtextColor: "#A0A0A0"

    compactRepresentation: MouseArea {
        property bool wasExpanded
        Accessible.name: Plasmoid.title
        Accessible.role: Accessible.Button
        onClicked: root.expanded = !wasExpanded
        onPressed: wasExpanded = root.expanded
        QtLayouts.RowLayout {
            anchors.fill: parent
            spacing: 0
            QtControls.Label {
                QtLayouts.Layout.alignment: Qt.AlignCenter
                horizontalAlignment: Text.AlignHCenter
                text: usageRatio
                font.pixelSize: 14
                font.bold: true
                color: textColor
            }

            Timer {
                interval: config_refreshInterval * 1000
                repeat: true
                onTriggered: fetchData()
            }
        }
    }

    fullRepresentation: PlasmaExtras.Representation{
        contentItem: Item {
            anchors.fill: parent
            QtLayouts.ColumnLayout{
                anchors.fill: parent
                QtControls.Label{

                    QtLayouts.Layout.alignment: Qt.AlignCenter
                    horizontalAlignment: Text.AlignHCenter
                    text : "usage : " + (getTotal-getUsage) + "/" + getTotal
                }
                QtControls.ProgressBar{

                    QtLayouts.Layout.alignment: Qt.AlignCenter
                    from: 0
                    to: getTotal
                    value: (getTotal-getUsage)
                    background: Rectangle {
                        implicitHeight: 20
                        color: "transparent"
                        radius: 3
                    }

                    contentItem: Item {
                        implicitHeight: 20

                        Rectangle {
                            width: control.visualPosition * parent.width
                            height: parent.height
                            color: barColor
                            radius: 3
                        }
                    }
                }
                QtControls.Button {

                    QtLayouts.Layout.alignment: Qt.AlignCenter
                    flat: true
                    focusPolicy: Qt.NoFocus
                    text : "refresh"
                    icon.source: Qt.resolvedUrl("../icon/refresh.svg")
                    font.pixelSize: 14
                    onClicked: fetchData()
                }
            }
        }
    }

    Component.onCompleted: fetchData()

    function fetchData() {
        isLoading = true;
        errorMessage = "";

        if (config_apiKey === "") {
            demoData();
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://www.minimaxi.com/v1/api/openplatform/coding_plan/remains", true);
        xhr.setRequestHeader("Authorization", "Bearer " + config_apiKey);

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var now = new Date();
                lastUpdated = now.toLocaleTimeString(Qt.locale(), "HH:mm");

                if (xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (resp.model_remains) {
                            var ratio = "0%";
                            for (var i = 0; i < resp.model_remains.length; i++) {
                                var m = resp.model_remains[i];
                                if (m.model_name && m.model_name.startsWith("MiniMax-M")) {
                                    var total = m.current_interval_total_count;
                                    var used = m.current_interval_usage_count;
                                    if (total > 0) {
                                        ratio = (100-Math.round(used / total * 100)) + "%";
                                    }
                                    break;
                                }
                            }
                            usageRatio = ratio;
                            getTotal = total;
                            getUsage = used;
                        }
                    } catch (e) {
                        errorMessage = "Parse error";
                        demoData();
                    }
                } else {
                    errorMessage = "API Error";
                    demoData();
                }
                isLoading = false;
            }
        };

        xhr.onerror = function () {
            errorMessage = "Network error";
            demoData();
            isLoading = false;
        };

        try {
            xhr.send();
        } catch (e) {
            demoData();
            isLoading = false;
        }
    }

    function demoData() {
        var now = new Date();
        lastUpdated = now.toLocaleTimeString(Qt.locale(), "HH:mm");
        usageRatio = Math.floor(Math.random() * 60 + 20) + "%";
        isLoading = false;
    }

}
