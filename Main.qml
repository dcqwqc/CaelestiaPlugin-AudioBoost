import QtQuick
import Caelestia.Config
import Caelestia.Plugins
import qs.services

Item {
    id: root

    property SettingsObject settings: null
    property var seenStreamIds: ({})

    visible: false
    implicitWidth: 0
    implicitHeight: 0

    function ceiling(): real {
        return Math.max(1, Math.min(2, Number(settings?.maxBoostPercent ?? 200) / 100));
    }

    function rules(): var {
        try {
            const parsed = JSON.parse(String(settings?.appBoostsJson ?? "{}"));
            return parsed && typeof parsed === "object" ? parsed : {};
        } catch (e) {
            return {};
        }
    }

    function appName(stream): string {
        return Audio.getStreamName(stream);
    }

    function applyCeiling(): void {
        GlobalConfig.services.maxVolume = ceiling();
    }

    function applyRule(stream, force): void {
        if (!stream?.audio)
            return;

        const id = String(stream.id);
        if (!force && seenStreamIds[id])
            return;

        const map = rules();
        const name = appName(stream);
        if (map[name] !== undefined) {
            const target = Math.max(1, Math.min(ceiling(), Number(map[name]) / 100));
            Audio.setStreamVolume(stream, target);
        }

        const copy = Object.assign({}, seenStreamIds);
        copy[id] = true;
        seenStreamIds = copy;
    }

    function applyAll(force): void {
        applyCeiling();
        for (const stream of Audio.streams)
            applyRule(stream, force);
    }

    onSettingsChanged: applyAll(true)
    Component.onCompleted: applyAll(true)

    Connections {
        target: root.settings

        function onMaxBoostPercentChanged(): void {
            root.applyAll(true);
        }

        function onAppBoostsJsonChanged(): void {
            root.applyAll(true);
        }
    }

    Connections {
        target: Audio

        function onStreamsChanged(): void {
            const live = {};
            for (const stream of Audio.streams) {
                live[String(stream.id)] = true;
                root.applyRule(stream, false);
            }

            const kept = {};
            for (const id in root.seenStreamIds) {
                if (live[id])
                    kept[id] = true;
            }
            root.seenStreamIds = kept;
        }
    }
}
