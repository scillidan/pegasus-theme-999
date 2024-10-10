import QtQuick 2.0
import QtMultimedia 5.15
import "configs.js" as CONFIGS
import "constants.js" as CONSTANTS

Row {
    id: root

    property alias fontSize: labeltext.font.pixelSize
    property alias value: currentValue.text
    property alias label: labeltext.text
    property alias textColor: labeltext.color
    property var model: []

    signal valueChange

    // private
    property var model_i: value ? model.indexOf(value): 0

	SoundEffect {
        id: forwardSound;
        source: 'sounds/cursor1.wav';
        volume: 0.1;
    }
	
	SoundEffect {
        id: nextSound;
        source: 'sounds/cursor2.wav';
        volume: 0.2;
    }


    Keys.onUpPressed: {
        event.accepted = true;
        model_i = model_i == 0 ? model.length - 1 : model_i - 1
        value = model[model_i]
        valueChange()
		forwardSound.play();
    }
    Keys.onDownPressed: {
        event.accepted = true;
        model_i = model_i == model.length - 1 ? 0 : model_i + 1
        value = model[model_i]
        valueChange()
		forwardSound.play();
    }
	
	Keys.onPressed: {
		if (api.keys.isAccept(event) && !event.isAutoRepeat) {
        event.accepted = true;
        model_i = model_i == model.length - 1 ? 0 : model_i + 1
        value = model[model_i]
        valueChange()
		forwardSound.play();
        }
		if (api.keys.isCancel(event)) {
            event.accepted = true;
			gamelist.focus = true; 
			nextSound.play();
        }
	}

    Rectangle {
        id: slider
        width: parent.fontSize*8//150
        height: parent.fontSize * 1.5

        color: "#50000000"
        border.color: "#60000000"
        border.width: vpx(1)

        anchors {
            verticalCenter: parent.verticalCenter
            rightMargin: 5
        }

        // Text {
            // id: arrowleft
            // color: "#eee"
            // font {
                // bold: true
                // pixelSize: parent.height * 1
            // }
            // verticalAlignment: Text.AlignVCenter

            // anchors {
                // top: parent.top
                // topMargin:1
                // left: parent.left
                // leftMargin: 5
            // }
            // text: '↑'
        // }
        RetroText3 {
            id: currentValue

            height: parent.height
            // verticalAlignment: Text.AlignVCenter
            // horizontalAlignment: Text.AlignHCenter
			// font.underline: root.activeFocus		
            color: root.activeFocus ? "#06fbf2" : "#ddd"
            anchors {
				top: parent.top
               topMargin: 6
                left: parent.left
                // left: arrowleft.right
                right: arrowright.left
                leftMargin: 15
                rightMargin: 15
            }

        font.family: subtitleFont.name
        style: Text.Outline; styleColor: "#666666"
	    font.pixelSize: parent.height * .7
            
        }
        RetroText3 {
            id: arrowright
			color: root.activeFocus ? "#06fbf2" : "#ddd"
            // color: arrowleft.color
			font {
                bold: true
                pixelSize: parent.height * .7
            }
			verticalAlignment: Text.AlignVCenter
            // font: arrowleft.font
			anchors {
                top: parent.top
                topMargin: parent.height * .2
                right: parent.right
                rightMargin: parent.height * .4
            }
            // anchors {
                // top: arrowleft.anchors.top
                // topMargin: arrowleft.anchors.topMargin
                // right: parent.right
                // rightMargin: 5
            // }
            text: '↑↓'
        }
    }

    Text {
        id: labeltext
        visible: false
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        color: "#eee"
        font.family: subtitleFont.name
        style: Text.Outline; styleColor: "black"
         anchors {             leftMargin: 5         }
    }
}
