import QtQuick
import QtQuick.Layouts as QtLayouts
import QtQuick.Controls as QtControls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    readonly property string config_apiKey: Plasmoid.configuration.apiKey || ""
    readonly property int config_refreshInterval: Plasmoid.configuration.refreshInterval || 60

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    property string usageRatio: "0%"
    property string lastUpdated: "N/A"
    property string errorMessage: ""
    property bool isLoading: false

    // Colors
    readonly property string barColor: "#00D1B2"
    readonly property string bgColor: "#2D2D44"
    readonly property string textColor: "#FFFFFF"
    readonly property string subtextColor: "#A0A0A0"

    fullRepresentation: QtLayouts.RowLayout {
        anchors.fill: parent
        spacing: 0
        QtControls.Label {
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            text: usageRatio
            font.pixelSize: 14
            font.bold: true
            color: textColor
        }
        QtControls.Button {
            anchors.verticalCenter: parent.verticalCenter
            flat: true
            icon.source: Qt.resolvedUrl("../icon/refresh.svg")
            font.pixelSize: 14
            onClicked: fetchData()
        }
        Timer {
            interval: config_refreshInterval * 1000
            repeat: true
            onTriggered: fetchData()
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
