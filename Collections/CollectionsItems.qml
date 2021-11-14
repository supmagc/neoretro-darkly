import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: item_collection

    property var isCurrentItem: PathView.isCurrentItem
    property var shortname: clearShortname(modelData.shortName)
    property var collectionAltColor: dataConsoles[shortname].altColor

    width: PathView.currentWidth
    height: PathView.currentHeight

    Component {
        id: cpnt_collection_bg

        Item {
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: collectionAltColor
            }

            Image {
                id: img_collection_bg
                width: parent.width
                height: parent.height
                asynchronous: true
                source: "../assets/background/"+shortname+".jpg"
                fillMode: Image.PreserveAspectCrop

                Image {
                    id: img_collection_logo
                    asynchronous: true
                    source: "../assets/logos/color/"+shortname+".png"
                    anchors{
                        fill: parent
                        leftMargin: parent.width * 0.05
                        topMargin: parent.height * 0.05
                        rightMargin: parent.width * 0.05
                        bottomMargin: parent.height * 0.05
                    }
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignTop
                    fillMode: Image.PreserveAspectFit
                }
            }

            Desaturate {
                anchors.fill: img_collection_bg
                source: img_collection_bg
                desaturation: isCurrentItem ? 0 : 1
                Behavior on desaturation {
                    NumberAnimation { duration: 200; }
                }
            }

            Rectangle {
                id: msk_collection_bg
                anchors.fill: parent
                color: "#1C1E2E"
                opacity: isCurrentItem ? 0 : 0.90
                Behavior on opacity {
                    NumberAnimation { duration: 300; }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border {
                    width: vpx(6)
                    color: collectionAltColor
                }
                opacity: isCurrentItem
                Behavior on opacity {
                    NumberAnimation { duration: 250; }
                }
            }

        }

    }

    Loader {
        id: loader_collections_items
        anchors.fill: parent
        sourceComponent: cpnt_collection_bg
        asynchronous: true
        active: ( root.state === "collections" )
    }

}