// gameOS theme
// Copyright (C) 2018-2020 Seth Powell 
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.15
import QtGraphicalEffects 1.12
import QtMultimedia 5.15

Item {
    id: root

    readonly property var currentGameCollection: gameData ? gameData.collections.get(0) : ""
    readonly property var currentGameCollectionAltColor: dataConsoles[clearShortname(currentGameCollection.shortName)].altColor
    readonly property bool playVideo: gameData ? gameData.assets.videoList.length : false

    property bool selected: false
    property var gameData

/*    // In order to use the retropie icons here we need to do a little collection specific hack
    scale: selected ? 1 : 0.95
    Behavior on scale { NumberAnimation { duration: 100 } }
    z: selected ? 10 : 1
*/
    onSelectedChanged: {
        if (selected && playVideo)
            fadescreenshot.restart();
        else {
            fadescreenshot.stop();
            screenshot.opacity = 1;
            container.opacity = 1;
        }
    }

    // NOTE: Fade out the bg so there is a smooth transition into the video
    Timer {
        id: fadescreenshot

        interval: 1200
        onTriggered: {
            screenshot.opacity = 0;
        }
    }

    Item {
        id: container
        anchors.fill: parent
        Behavior on opacity { NumberAnimation { duration: 200 } }

        GameVideo {
            game: gameData
            anchors.fill: parent
            playing: selected
            //visible: selected
        }

        Image {
            id: marquee

            anchors.fill: parent
            source: gameData ? gameData.assets.marquee : ""
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(screenshot.width, screenshot.height)
            smooth: false
            asynchronous: true
            visible: gameData.assets.marquee && !selected
            Behavior on opacity { NumberAnimation { duration: 200 } } 
        }

        DropShadow {
            anchors.fill: parent
            horizontalOffset: 0
            verticalOffset: 5
            radius: 20
            samples: 20
            color: "#000000"
            source: marquee
            opacity: visible ? 0.5 : 0
            visible: gameData.assets.marquee && !selected
            Behavior on opacity { NumberAnimation {duration: 200 } }
            z: -5
        }

        Image {
            id: screenshot

            anchors.fill: parent
            anchors.margins: vpx(3)
            source: gameData ? gameData.assets.screenshots[0] || gameData.assets.background || "" : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(screenshot.width, screenshot.height)
            smooth: false
            asynchronous: true
            visible: !gameData.assets.marquee || selected
            Behavior on opacity { NumberAnimation { duration: 200 } } 
        }

        Image {
            id: favelogo

            anchors.fill: parent
            anchors.centerIn: parent
            anchors.margins: root.width/10
            source: gameData ? gameData.assets.logo : ""
            sourceSize: Qt.size(source.width, source.height)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            scale: selected ? 1.1 : 1
            opacity: visible ? 1 : 0
            visible: !gameData.assets.marquee || selected
            Behavior on scale { NumberAnimation { duration: 100 } }
            Behavior on opacity { NumberAnimation { duration: 50 } }
            z: 10
        }

        DropShadow {
            anchors.fill: parent
            anchors.centerIn: parent
            anchors.margins: root.width/10
            horizontalOffset: 0
            verticalOffset: 5
            radius: visible ? 50 : 0
            samples: 20
            color: "#000000"
            source: favelogo
            opacity: visible ? 1 : 0
            visible: !gameData.assets.marquee || selected
            Behavior on opacity { NumberAnimation {duration: 100 } }
            Behavior on radius { NumberAnimation {duration: 100 } }
            z: 5
        }

        Text {
            anchors.fill: parent
            text: gameData.title
            font {
                family: global.fonts.sans
                weight: Font.Medium
                pixelSize: vpx(16)
            }
            color: "white"

            horizontalAlignment : Text.AlignHCenter
            verticalAlignment : Text.AlignVCenter
            wrapMode: Text.Wrap

            visible: (selected && !gameData.assets.logo) || (!selected && !gameData.assets.marquee)
        }
    }

/*
    // List specific input
    Keys.onReleased: {
        // Accept
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            activated();        
        }
    }
*/

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: vpx(5)
            color: currentGameCollectionAltColor
        }
        visible: selected
    }  
}


