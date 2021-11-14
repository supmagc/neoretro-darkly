import QtQuick 2.15
import QtGraphicalEffects 1.12
import "../Global"

FocusScope {
    focus: menu.focus

    DropShadow {
        anchors.fill: parent
        horizontalOffset: 0
        verticalOffset: vpx(5)
        radius: 24
        samples: 22
        spread: 0.2
        color: "#1C1E2E"
        source: parent
    }

    Rectangle {
        width: parent.width + 2
        height: parent.height + 2
        x: -1
        y: -1
        color: "#202335"
        border {
            width: 1
            color: "#1C1E2E"
        }

        Item {
            width: parent.width * 0.9
            height: parent.height * 0.7
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            Item {
                id: menu_inner
                width: parent.width * 0.5
                height: parent.height
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                ListView {
                    id: lv_menu
                    width: contentItem.childrenRect.width
                    height: vpx(22)
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }

                    orientation: ListView.Horizontal
                    currentIndex: currentMenuIndex
                    onCurrentIndexChanged: {
                        api.memory.set("currentMenuIndex", currentMenuIndex)
                    }

                    model: dataMenu

                    header: Item {
                        width: vpx(60)
                        height: vpx(22)
                        Image {
                            id: menu_input_LB
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            source: "../assets/buttons/button_LB.svg"
                            width: parent.width * 0.55
                            fillMode: Image.PreserveAspectFit
                            ColorOverlay {
                                anchors.fill: menu_input_LB
                                source: menu_input_LB
                                color: "#414767"
                                opacity: 0.5
                            }
                        }
                    }

                    delegate: MenuItems {}

                    footer: Item {
                        width: vpx(60)
                        height: vpx(22)
                        Image {
                            id: menu_input_RB
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            source: "../assets/buttons/button_RB.svg"
                            width: parent.width * 0.55
                            fillMode: Image.PreserveAspectFit
                            ColorOverlay {
                                anchors.fill: menu_input_RB
                                source: menu_input_RB
                                color: "#414767"
                                opacity: 0.5
                            }
                        }
                    }

                    highlight: MenuItemsHighlighted {}
                    highlightRangeMode: ListView.ApplyRange
                    highlightResizeDuration: root.width * 0.1
                    highlightResizeVelocity: root.width * 0.1
                    highlightMoveDuration: root.width * 0.1
                    highlightMoveVelocity: -1

                    interactive: false

                    focus: menu.focus

                    Component.onCompleted: positionViewAtIndex(currentMenuIndex, ListView.Beginning)

                    spacing: vpx(20)
                }
            }

            Item {
                width: parent.width * 0.5
                height: parent.height
                anchors {
                    right: parent.right; 
                    verticalCenter: parent.verticalCenter
                }

                Image {
                    id: menu_input_LT
                    anchors {
                        right: parent.right; leftMargin: -width *2
                        verticalCenter: parent.verticalCenter
                    }
                    width: vpx(30)
                    height: vpx(22)
                    source: "../assets/buttons/button_LT.svg"
                    sourceSize.width: width
                    fillMode: Image.PreserveAspectFit
                    visible: root.state === "games"
                    
                    ColorOverlay {
                        anchors.fill: menu_input_LT
                        source: menu_input_LT
                        color: "#414767"
                        opacity: 0.5
                    }
                }

                Component {
                    id: cmpt_helper_collection

                    Image {
                        id: img_helper_collection

                        sourceSize.width: width
                        asynchronous: true
                        source: {
                            if (root.state === "collections")
                                return "";
                            if (root.state === "home")
                                return "../assets/logos/color/"+clearShortname(home.currentGame.collections.get(0).shortName)+".png"
                            if (root.state === "games")
                                return "../assets/logos/color/"+clearShortname(allCollections[currentCollectionIndex].shortName)+".png"
                        }
                        fillMode: Image.PreserveAspectFit
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                        Behavior on source {
                            PropertyAnimation {
                                target: img_helper_collection
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 600
                                easing.type: Easing.OutExpo
                            }
                        }

                        visible: ["home","games"].includes(root.state)
                    }
                }

                Loader {
                    id: loader_helper_collection
                    sourceComponent: cmpt_helper_collection
                    width: vpx(250)
                    height: parent.height
                    anchors {
                        right: parent.right
                        rightMargin: vpx(35)
                    }
                    asynchronous: true
                    active: ["home","games"].includes(root.state)
                    visible: status === Loader.Ready
                }

                Image {
                    id: menu_input_RT
                    width: vpx(30)
                    height: vpx(22)
                    anchors {
                        right: parent.right;
                        rightMargin: vpx(290)
                        verticalCenter: parent.verticalCenter
                    }
                    source: "../assets/buttons/button_RT.svg"
                    sourceSize.width: width
                    fillMode: Image.PreserveAspectFit
                    visible: root.state === "games"

                    ColorOverlay {
                        anchors.fill: menu_input_RT
                        source: menu_input_RT
                        color: "#414767"
                        opacity: 0.5
                    }
                }

                visible: ["home","games"].includes(root.state)
            }
        }
    }
}