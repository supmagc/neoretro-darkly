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

    property var game
    property bool playing

    onGameChanged: {
        videoPreviewLoader.sourceComponent = undefined;
        videoDelay.restart();
    }

    onPlayingChanged: {
        videoPreviewLoader.sourceComponent = undefined;
        videoDelay.restart();
    }

    // Timer to show the video
    Timer {
        id: videoDelay

        interval: 600
        onTriggered: {
            if (playing && game && game.assets.videos.length) {
                videoPreviewLoader.sourceComponent = videoPreviewWrapper;
            }
        }
    }

    Component {
        id: videoPreviewWrapper

        Video {
            id: videocomponent

            anchors.fill: parent
            source: game.assets.videoList.length ? game.assets.videoList[0] : ""
            fillMode: VideoOutput.PreserveAspectCrop
            muted: true
            loops: MediaPlayer.Infinite
            autoPlay: true
        }
    }

    Item {
        id: videocontainer

        anchors.fill: parent

        Loader {
            id: videoPreviewLoader
            asynchronous: true
            anchors { fill: parent }
        }
    }
}