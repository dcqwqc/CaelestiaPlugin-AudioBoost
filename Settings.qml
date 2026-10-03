import Caelestia.Plugins

SettingsObject {
    property int maxBoostPercent: 200
    SettingMeta on maxBoostPercent {
        label: "Maximum boost"
        description: "Upper limit exposed by Caelestia's output and app-volume sliders. 100% is normal gain; values above 100% amplify the stream and may clip."
        icon: "volume_up"
        inputType: SettingMeta.SpinBox
        min: 100
        max: 200
        step: 5
    }

    property string appBoostsJson: "{}"
}
