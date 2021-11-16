import QtQuick 2.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import "../Global"

FocusScope {
    property int currentLastPlayedIndex: 0
    property int currentFavoritesIndex: 0
    property var previousLastplayed: lastplayed_left

    readonly property var currentGame: {
        if (lastplayed_left.focus)
            return sort_lastplayed_base.get(0)
        if (lastplayed_right.focus)
            return sort_lastplayed_base.get(currentLastPlayedIndex+1)
        if (favorites.focus)
            return sort_favorites_base.get(currentFavoritesIndex)
        else
            return null
    }

    Component.onCompleted: lastplayed_left.focus = true

    SortFilterProxyModel {
        id: sort_lastplayed_base
        sourceModel: api.allGames
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder; }
    }

    SortFilterProxyModel {
        id: sort_favorites_base
        sourceModel: api.allGames
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder; }
        filters: ValueFilter { roleName: "favorite"; value: true; }
    }

    // 10 games to show maximum
    SortFilterProxyModel {
        id: sort_favorites_limited
        sourceModel: sort_favorites_base
        filters: IndexFilter { maximumIndex: 19; }
    }

    // 1 game to show maximum
    SortFilterProxyModel {
        id: sort_lastplayed_left
        sourceModel: sort_lastplayed_base
        filters: IndexFilter { maximumIndex: 0; }
    }

    // 6 games to show maximum
    SortFilterProxyModel {
        id: sort_lastplayed_right
        sourceModel: sort_lastplayed_base
        filters: IndexFilter { minimumIndex: 1; maximumIndex: 6; }
    }

    Behavior on focus {
        ParallelAnimation {
            PropertyAnimation {
                target: skew_color
                property: "width"
                from: parent.width
                to: parent.width * 0.77
                duration: 500
            }
            PropertyAnimation {
                target: skew_color
                property: "anchors.leftMargin"
                from: parent.width *1.5
                to: parent.width * 0.08
                duration: 350
            }
        }
    }

    // Skewed background
    Rectangle {
        id: skew_color
        height: parent.height
        antialiasing: true
        anchors {
            left: parent.left; leftMargin: parent.width * 0.08
            right: parent.right; rightMargin: parent.width * 0.16
        }
        color: "#1C1E2E"

        transform: Matrix4x4 {
            property real a: 12 * Math.PI / 180
            matrix: Qt.matrix4x4(
                1,      -Math.tan(a),       0,      0,
                0,      1,                  0,      0,
                0,      0,                  1,      0,
                0,      0,                  0,      1
            )
        }
        BackgroundImage {
            id: backgroundimage
            game: currentGame
            anchors {
                left: parent.left; right: parent.right
                top: parent.top; bottom: parent.bottom
            }
            opacity: 0.255
        }
    }

    // Build page as a big column
    Column {
        id: main
        width: parent.width * 0.9
        height: childrenRect.height
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top; topMargin: vpx(40)
        }
        spacing: vpx(10)

        // Continue playing text
        Text {
            text: "Continue playing"
            font {
                family: robotoSlabLight.name
                pixelSize: vpx(22)
            }
            color: "white"
        }

        // Continue playing games
        Item {
            width: parent.width
            height: vpx(280)

            opacity: (lastplayed_left.focus || lastplayed_right.focus) ? 1 : 0.5

            // Big field
            Loader {
                id: lastplayed_left
                active: home.focus
                width: parent.width * 0.4
                anchors {
                    top: parent.top; topMargin: vpx(10)
                    bottom: parent.bottom; bottomMargin: vpx(10)
                }

                asynchronous: true
                sourceComponent: GameItemHome {
                    gameData: sort_lastplayed_left.get(0)
                    selected: lastplayed_left.focus
                }
                visible: sort_lastplayed_left.get(0) && status == Loader.Ready
                
                focus: false
                onFocusChanged: { if(focus) previousLastplayed = lastplayed_left }
                Keys.onReleased: {
                    if (event.isAutoRepeat) {
                        return
                    }

                    if (api.keys.isAccept(event)) {
                        sfxAccept.play();

                        event.accepted = true;
                        api.memory.set("currentMenuIndex", currentMenuIndex)
                        currentGame.launch()
                    }

                    if ([Qt.Key_Right, Qt.Key_Down].includes(event.key)) {
                        sfxNav.play();
                        event.accepted = true;

                        if (event.key == Qt.Key_Right && sort_lastplayed_right.count > 0) lastplayed_right.focus = true
                        if (event.key == Qt.Key_Down && sort_favorites_limited.count > 0) favorites.focus = true
                    }
                }
            }
           
            GridView {
                id: lastplayed_right
                width: parent.width * 0.6
                height: parent.height
                anchors.right: parent.right

                cellWidth: width /3
                cellHeight: height /2
                currentIndex: currentLastPlayedIndex
                onCurrentIndexChanged: currentLastPlayedIndex = currentIndex

                model: sort_lastplayed_right
                delegate: Item {
                    readonly property var isSelected: GridView.isCurrentItem

                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight

                    Loader {
                        active: home.focus
                        anchors {
                            top: parent.top; topMargin: vpx(10)
                            right: parent.right;
                            bottom: parent.bottom; bottomMargin: vpx(10)
                            left: parent.left; leftMargin: vpx(10)
                        }

                        asynchronous: true
                        sourceComponent: GameItemHome {
                            gameData: modelData
                            selected: lastplayed_right.focus && isSelected
                        }
                        visible: status == Loader.Ready
                    }
                }

                highlightMoveDuration: vpx(150)

                focus: false
                interactive: false
                onFocusChanged: { if(focus) previousLastplayed = lastplayed_right }
                Keys.onReleased: {
                    if (event.isAutoRepeat) {
                        return
                    }

                    if (api.keys.isAccept(event)) {
                        event.accepted = true;
                        sfxAccept.play();

                        api.memory.set("currentMenuIndex", currentMenuIndex)
                        currentGame.launch()
                    }

                    if ([Qt.Key_Up, Qt.Key_Right, Qt.Key_Down, Qt.Key_Left].includes(event.key)) {
                        event.accepted = true;
                        sfxNav.play();
                    }

                    if (event.key == Qt.Key_Left) {
                        if ([0,3].includes(currentLastPlayedIndex)) lastplayed_left.focus = true
                        else currentLastPlayedIndex--
                    }

                    if (event.key == Qt.Key_Right && [0,1,3,4].includes(currentLastPlayedIndex)) currentLastPlayedIndex++

                    if (event.key == Qt.Key_Down) {
                        if ([0,1,2].includes(currentLastPlayedIndex))  currentLastPlayedIndex += 3
                        else if (sort_favorites_limited.count > 0) favorites.focus = true
                    }

                    if (event.key == Qt.Key_Up && [3,4,5].includes(currentLastPlayedIndex) ) currentLastPlayedIndex -= 3
                }
            }
        }

        // Favorites text
        Text {
            text: "Favorites"
            font {
                family: robotoSlabLight.name
                pixelSize: vpx(22)
            }
            color: "white"
        }

        // No Favorites
        Rectangle {
            width: parent.width
            height: vpx(160)

            color: "#101018"
            opacity: 0.5
            visible: sort_favorites_limited.count == 0

            transform: Matrix4x4 {
                property real a: 12 * Math.PI / 180
                matrix: Qt.matrix4x4(
                    1,      -Math.tan(a),       0,      0,
                    0,      1,                  0,      0,
                    0,      0,                  1,      0,
                    0,      0,                  0,      1
                )
            }

            Text {
                anchors.fill: parent

                text: "No favorites set"
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter
                font {
                    family: robotoSlabLight.name
                    pixelSize: vpx(22)
                }
                color: "gray"
            }
        }

        // Favorites games
        ListView {
            id: favorites
            width: parent.width
            height: vpx(160)
            anchors.topMargin: vpx(10)

            opacity: focus ? 1 : 0.5
            orientation: ListView.Horizontal
            currentIndex: currentFavoritesIndex
            onCurrentIndexChanged: currentFavoritesIndex = currentIndex
            visible: sort_favorites_limited.count > 0

            model: sort_favorites_limited
            delegate: Item {
                readonly property var isSelected: ListView.isCurrentItem

                width: ListView.view.width /5
                height: ListView.view.height * 0.9

                Loader {
                    active: home.focus
                    anchors {
                        top: parent.top; topMargin: vpx(10)
                        right: parent.right;
                        bottom: parent.bottom; bottomMargin: vpx(10)
                        left: parent.left;
                    }

                    asynchronous: true
                    sourceComponent: GameItemHome {
                        gameData: modelData
                        selected: favorites.focus && isSelected
                    }
                    visible: status === Loader.Ready
                }
            }

            clip: true

            highlightRangeMode: ListView.ApplyRange
            snapMode: ListView.SnapOneItem
            highlightMoveDuration: vpx(100)
            preferredHighlightBegin: width * 0.4
            preferredHighlightEnd: width * 0.6

            focus: false
            Keys.onReleased: {
                if (event.isAutoRepeat) {
                    return
                }

                if (api.keys.isAccept(event)) {
                    event.accepted = true;
                    sfxAccept.play();

                    api.memory.set("currentMenuIndex", currentMenuIndex)
                    currentGame.launch()
                }

                if ([Qt.Key_Up, Qt.Key_Right, Qt.Key_Left].includes(event.key)) {
                    event.accepted = true;
                    sfxNav.play();

                    if (event.key == Qt.Key_Up) previousLastplayed.focus = true
                }
            }
        }
    }

    Row {
        id: play_message
        width: parent.width * 0.9
        height: vpx(18)
        anchors {
            bottom: parent.bottom; bottomMargin: vpx(40)
            horizontalCenter: parent.horizontalCenter
        }
        spacing: vpx(8)
        visible: currentGame

        Controls {
            id: button_D

            message: "Play <b>" + currentGame.title + "</b>"
            text_color: "#8E63EC"
            front_color: "#338E63EC"
            back_color: "#338E63EC"
            input_button: "D"
        }
    }
}
