import QtQuick 2.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import "../Global"

FocusScope {
    focus: home.focus

    state: "last_played_default"

    property int currentLastPlayedIndex: 0
    property int currentFavoritesIndex: 0
    property bool lastIsDefault: true

    property var currentGame: {
        if (home.state === "last_played_default")
            return api.allGames.get(sort_last_played_base.mapToSource(0))
        if (home.state === "last_played")
            return api.allGames.get(sort_last_played_base.mapToSource(currentLastPlayedIndex+1))
        if (home.state === "favorites")
            return api.allGames.get(sort_favorites.mapToSource(currentFavoritesIndex))
        else
            return null
    }

    SortFilterProxyModel {
        id: sort_last_played_base
        sourceModel: api.allGames
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder; }
    }

    SortFilterProxyModel {
        id: sort_favorites
        sourceModel: api.allGames
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder; }
        filters: ValueFilter { roleName: "favorite"; value: true; }
    }

    // 9 games to show maximum
    SortFilterProxyModel {
        id: sort_favorites_limited
        sourceModel: sort_favorites
        filters: IndexFilter { maximumIndex: 9; }
    }

    // 1 game to show maximum
    SortFilterProxyModel {
        id: sort_last_played_big
        sourceModel: sort_last_played_base
        filters: IndexFilter { maximumIndex: 0; }
    }

    // 6 games to show maximum
    SortFilterProxyModel {
        id: sort_last_played
        sourceModel: sort_last_played_base
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

    Column {
        id: main
        width: parent.width * 0.9
        height: childrenRect.height
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top; topMargin: vpx(40)
        }
        spacing: vpx(10)

        Text {
            text: "Continue playing"
            font {
                family: robotoSlabLight.name
                pixelSize: vpx(22)
            }
            color: "white"
        }

        Row {
            height: vpx(280)
            opacity: ( home.state === "last_played" || home.state === "last_played_default" ) ? 1 : 0.5
            /*ListView {
                id: lv_lastPlayed_big
                width: main.width * 0.4
                height: parent.height

                orientation: ListView.Horizontal

                currentIndex: 0
                model: sort_last_played_big
                delegate: Rectangle {
                    readonly property bool isCurrentItem: ListView.isCurrentItem
                    readonly property bool isFocused: activeFocus
                    readonly property bool doubleFocus: lv_lastPlayed_big.focus && isCurrentItem

                    width: ListView.view.width
                    height: ListView.view.height

                    Item {
                        anchors {
                            fill: parent
                        }

                        Loader {
                            anchors.fill: parent
                            asynchronous: true
                            sourceComponent: GameItemHome {}
                            active: home.focus
                            visible: status === Loader.Ready
                        }
                    }
                }

                // clip: true

                highlightRangeMode: ListView.ApplyRange
                snapMode: ListView.NoSnap
                highlightMoveDuration: vpx(150)
                interactive: false

                focus: ( home.state === "last_played_default" )

                Component.onCompleted: {
                    positionViewAtIndex(0, ListView.SnapPosition)
                }

                Keys.onReleased: {
                    
                    if (event.isAutoRepeat) {
                        return
                    }

                    if (api.keys.isAccept(event)) {

                        //Accept game
                        sfxAccept.play();

                        event.accepted = true;
                        api.memory.set("currentMenuIndex", currentMenuIndex)
                        currentGame.launch()
                    }

                    if (event.key == Qt.Key_Right) {

                        //navigation sound
                        sfxNav.play();

                        event.accepted = true;
                        home.state = "last_played"
                    }

                    if (event.key == Qt.Key_Down && sort_favorites.count > 0) {

                        //navigation sound
                        sfxNav.play();

                        event.accepted = true;
                        lastIsDefault = true
                        home.state = "favorites"
                    }
                }
            }*/
            GameItemHome {
                id: lv_lastPlayed_big
                width: main.width * 0.4
                height: parent.height
                gameData: sort_last_played_big[0]

                Keys.onReleased: {
                    
                    if (event.isAutoRepeat) {
                        return
                    }

                    if (api.keys.isAccept(event)) {

                        //Accept game
                        sfxAccept.play();

                        event.accepted = true;
                        api.memory.set("currentMenuIndex", currentMenuIndex)
                        currentGame.launch()
                    }

                    if (event.key == Qt.Key_Right) {

                        //navigation sound
                        sfxNav.play();

                        event.accepted = true;
                        home.state = "last_played"
                    }

                    if (event.key == Qt.Key_Down && sort_favorites.count > 0) {

                        //navigation sound
                        sfxNav.play();

                        event.accepted = true;
                        lastIsDefault = true
                        home.state = "favorites"
                    }
                }
            }
            
            GridView {
                id: gv_lastPlayed
                width: main.width * 0.6
                height: parent.height
                cellWidth: width /3
                cellHeight: height /2
                //spacing: vpx(0)

                currentIndex: currentLastPlayedIndex
                onCurrentIndexChanged: currentLastPlayedIndex = currentIndex

                model: sort_last_played
                delegate: Item {
                    readonly property bool isCurrentItem: GridView.isCurrentItem
                    readonly property bool isFocused: activeFocus
                    readonly property bool doubleFocus: gv_lastPlayed.focus && isCurrentItem

                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight

                    Item {
                        anchors {
                            fill: parent
                        }

                        Loader {
                            anchors.fill: parent
                            asynchronous: true
                            sourceComponent: GameItemHome {}
                            active: home.focus
                            visible: status == Loader.Ready
                        }
                    }
                }

                // clip: true

                highlightMoveDuration: vpx(150)
                interactive: false

                focus: ( home.state === "last_played" )

                Component.onCompleted: {
                    positionViewAtIndex(currentLastPlayedIndex, GridView.SnapPosition)
                }

                Keys.onReleased: {

                    if (event.isAutoRepeat) {
                        return
                    }

                    if (api.keys.isAccept(event)) {
                        event.accepted = true;
                        api.memory.set("currentMenuIndex", currentMenuIndex)

                        //Accept game sound
                        sfxAccept.play();

                        currentGame.launch()
                    }
                    
                    if (event.key == Qt.Key_Left) {

                        //navigation sound
                        sfxNav.play();

                        event.accepted = true;
                        if ( [0,3].includes(currentLastPlayedIndex) )
                            home.state = "last_played_default"
                        else
                            currentLastPlayedIndex--
                    }

                    if (event.key == Qt.Key_Right) {

                        //navigation sound
                        sfxNav.play();

                        event.accepted = true;
                        if ( [0,1,3,4].includes(currentLastPlayedIndex) )
                            currentLastPlayedIndex++
                    }

                    if (event.key == Qt.Key_Down) {

                        //navigation sound
                        sfxNav.play();

                        event.accepted = true;
                        if ( [0,1,2].includes(currentLastPlayedIndex) ) {
                            currentLastPlayedIndex +=3
                        }

                        else if (sort_favorites.count > 0) {
                            lastIsDefault = false
                            home.state = "favorites"
                        }
                    }

                    if (event.key == Qt.Key_Up) {

                        //navigation sound
                        sfxNav.play();

                        event.accepted = true;
                        if ( [3,4,5].includes(currentLastPlayedIndex) )
                            currentLastPlayedIndex -=3
                    }
                }
            }
        }

        Text {
            text: "Favorites"
            font {
                family: robotoSlabLight.name
                pixelSize: vpx(22)
            }
            color: "white"
        }

        ListView {
            id: lv_favorites
            width: parent.width
            height: vpx(160)
            opacity: home.state === "favorites" ? 1 : 0.5

            orientation: ListView.Horizontal

            currentIndex: currentFavoritesIndex
            onCurrentIndexChanged: currentFavoritesIndex = currentIndex

            model: sort_favorites_limited
            delegate: Item {
                readonly property bool isCurrentItem: ListView.isCurrentItem
                readonly property bool isFocused: activeFocus
                readonly property bool doubleFocus: lv_favorites.focus && isCurrentItem

                width: ListView.view.width /5
                height: ListView.view.height * 0.9

                Item {
                    anchors {
                        fill: parent
                        margins: vpx(5)
                    }

                    Loader {
                        anchors.fill: parent
                        asynchronous: true
                        sourceComponent: GameItemHome {}
                        active: home.focus
                        visible: status === Loader.Ready
                    }
                }
            }

            clip: true

            highlightRangeMode: ListView.ApplyRange
            snapMode: ListView.SnapOneItem
            highlightMoveDuration: vpx(100)
            preferredHighlightBegin: width * 0.4
            preferredHighlightEnd: width * 0.6

            focus: ( home.state === "favorites" )

            Component.onCompleted: {
                    positionViewAtIndex(currentFavoritesIndex, ListView.SnapPosition)
            }

            Keys.onReleased: {

                if (event.isAutoRepeat) {
                    return
                }

                if (api.keys.isAccept(event)) {
                    event.accepted = true;
                    api.memory.set("currentMenuIndex", currentMenuIndex)

                    //Accept game sound
                    sfxAccept.play();

                    currentGame.launch()
                }

                
                if (event.key == Qt.Key_Left) {
                    //navigation sound
                    sfxNav.play();
                }

                if (event.key == Qt.Key_Right) {
                    //navigation sound
                    sfxNav.play();
                }

                if (event.key == Qt.Key_Down) {
                    //navigation sound
                    sfxNav.play();
                }

                if (event.key == Qt.Key_Up) {
                    event.accepted = true;
                    //navigation sound
                    sfxNav.play();
                    home.state = lastIsDefault ? "last_played_default" : "last_played"
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

        Controls {
            id: button_D

            message: "Play <b>"+currentGame.title+"</b>"
            text_color: "#8E63EC"
            front_color: "#338E63EC"
            back_color: "#338E63EC"
            input_button: "D"
        }
    }
}
