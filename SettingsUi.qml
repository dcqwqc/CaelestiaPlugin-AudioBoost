pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

ColumnLayout {
    id: root

    property var settings: null

    readonly property int ceilingPercent: Math.max(100, Math.min(200, Number(settings?.maxBoostPercent ?? 200)))
    readonly property var appNames: {
        const seen = {};
        const names = [];
        for (const stream of Audio.streams) {
            const name = Audio.getStreamName(stream);
            if (!seen[name]) {
                seen[name] = true;
                names.push(name);
            }
        }
        return names.sort();
    }

    Layout.fillWidth: true
    spacing: Tokens.spacing.extraSmall / 2

    function boostMap(): var {
        try {
            const parsed = JSON.parse(String(root.settings?.appBoostsJson ?? "{}"));
            return parsed && typeof parsed === "object" ? parsed : {};
        } catch (e) {
            return {};
        }
    }

    function appBoost(name): int {
        const map = boostMap();
        return Math.max(100, Math.min(ceilingPercent, Number(map[name] ?? 100)));
    }

    function setAppBoost(name, percent): void {
        if (!root.settings)
            return;

        const map = boostMap();
        const p = Math.max(100, Math.min(ceilingPercent, Math.round(percent)));

        if (p <= 100)
            delete map[name];
        else
            map[name] = p;

        root.settings.appBoostsJson = JSON.stringify(map);

        for (const stream of Audio.streams) {
            if (Audio.getStreamName(stream) === name)
                Audio.setStreamVolume(stream, p / 100);
        }
    }

    SectionHeader {
        first: true
        text: qsTr("Audio boost")
    }

    StepperRow {
        Layout.fillWidth: true
        first: true
        last: true
        label: qsTr("Maximum boost")
        subtext: qsTr("Extends Caelestia's native output and app sliders above 100%.")
        value: root.ceilingPercent
        from: 100
        to: 200
        stepSize: 5

        onMoved: v => {
            if (root.settings)
                root.settings.maxBoostPercent = Math.round(v);
        }
    }

    StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Tokens.padding.small
        Layout.rightMargin: Tokens.padding.small
        Layout.topMargin: Tokens.spacing.small
        text: qsTr("100% is normal gain. Boosting above it is useful for quiet apps, but very loud material can distort.")
        color: Colours.palette.m3outline
        font: Tokens.font.body.small
        wrapMode: Text.WordWrap
    }

    SectionHeader {
        text: qsTr("Per-app boost")
    }

    StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Tokens.padding.small
        Layout.rightMargin: Tokens.padding.small
        visible: root.appNames.length === 0
        text: qsTr("Start audio in an app and it will appear here.")
        color: Colours.palette.m3outline
        font: Tokens.font.body.small
        wrapMode: Text.WordWrap
    }

    Repeater {
        model: root.appNames

        StepperRow {
            required property string modelData
            required property int index

            Layout.fillWidth: true
            first: index === 0
            last: index === root.appNames.length - 1
            label: modelData
            subtext: root.appBoost(modelData) > 100
                ? qsTr("Remembered boost for this app")
                : qsTr("Normal gain")
            value: root.appBoost(modelData)
            from: 100
            to: root.ceilingPercent
            stepSize: 5

            onMoved: v => root.setAppBoost(modelData, v)
        }
    }
}
