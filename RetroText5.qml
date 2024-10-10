import QtQuick 2.6
import "configs.js" as CONFIGS
import "constants.js" as CONSTANTS

Text {
    id: root

    font.family: subtitleFont.name
    font.pixelSize: if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE) && CONFIGS.getMainTextsize(api) == 1){return scaled(20)*1.05}
	else if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE) && CONFIGS.getMainTextsize(api) == 2){return scaled(20)*0.9}
	else if(api.memory.has(CONSTANTS.MAIN_TEXTSIZE) && CONFIGS.getMainTextsize(api) == 3){return scaled(20)*0.8}
	else {return scaled(20)}
    // font.capitalization: Font.AllUppercase
    color:  if(api.memory.has(CONSTANTS.MAIN_COLOUR) && api.memory.get(CONSTANTS.MAIN_COLOUR) == '极致复古' ){return "#abf476" }
	// else if(api.memory.has(CONSTANTS.MAIN_COLOUR) && api.memory.get(CONSTANTS.MAIN_COLOUR) == '流浪地球' ){return "#abf476" }
	else {return "#ffffff"}
	opacity: if(api.memory.has(CONSTANTS.MAIN_COLOUR) && api.memory.get(CONSTANTS.MAIN_COLOUR) == '流浪地球' ){return 0.7 }
	else {return 1}

    Text {
        text: root.text
        font.family: root.font.family
        font.pixelSize: root.font.pixelSize
        font.capitalization: root.font.capitalization
        leftPadding: root.leftPadding
		// width: flickable.width
        wrapMode: Text.WrapAnywhere
		horizontalAlignment: Text.AlignJustify
		
        color: "#000"
        z: -1

        anchors {
            left: parent.left; leftMargin: scaled(3)
            top: parent.top; topMargin: scaled(1)
        }
    }
}
