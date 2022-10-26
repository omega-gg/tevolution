//=================================================================================================
/*
    Copyright (C) 2020 tevolution authors. <http://omega.gg/tevolution>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of tevolution.

    - Private License Usage:
    tevolution licensees holding valid private licenses may use this file in accordance with the
    private license agreement provided with the Software or, alternatively, in accordance with the
    terms contained in written agreement between you and tevolution authors. For further
    information contact us at contact@omega.gg.
*/
//=================================================================================================

import QtQuick 1.0
import Sky     1.0

Item
{
    id: gui

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property int step: pGetStep()

    property bool asynchronous: true

    /* read */ property variant server: core.server

    /* read */ property variant currentTab: core.tabs.currentTab

    //---------------------------------------------------------------------------------------------
    // Private

//#!MOBILE
    property bool pVersion: (online.version && online.version != sk.version)
//#END

    property int pSize: (st.isTight) ? height / 3
                                     : height / 2

    // NOTE: Margins are 56 pixels on a 512 tag.
    property int pSizeTag: pSize * 0.890625

    property int pSizeLoader: height / 128

    property bool pAudio: (player.outputActive == AbstractBackend.OutputAudio || player.isAudio
                           ||
                           player.hasOutput)

    property bool pCoverActive: (step > 1 && (player.isStopped || player.isStarting
                                              ||
                                              player.isResuming || pAudio))

    property string pCover: ""

    property int pStep: -1

    //---------------------------------------------------------------------------------------------
    // Style

    property int pDuration: st.ms1000

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    opacity: 0

    //---------------------------------------------------------------------------------------------
    // Animations
    //---------------------------------------------------------------------------------------------

    Behavior on opacity
    {
        PropertyAnimation
        {
            duration: st.duration_normal

            easing.type: st.easing
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        opacity = 1.0;

        core.generateSource();
    }

    onPCoverActiveChanged:
    {
        if (pStep < 2 || (pStep == 2 && step == 1))
        {
            behaviorOpacity.enabled = true;

            if (pCoverActive) cover.opacity = 1.0;
            else              cover.opacity = 0.0;

            behaviorOpacity.enabled = false;
        }
        else if (pCoverActive) cover.opacity = 1.0;
        else                   cover.opacity = 0.0;

        pStep = step;
    }

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onTagSourceUpdated(image)
        {
            imageTag.applyImage(image);
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function toggleFullScreen()
    {
        if (window.fullScreen == false)
        {
            window.fullScreen = true;

            if (player.isPlaying == false) return;

            window.idle = true;
        }
        else pRestoreFullScreen();
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onMessageReceived(message) {}

    function onBeforeClose() {}

    function onActiveChanged()
    {
        // NOTE: When active we want to avoid screen savers at all time.
        if (window.isActive)
        {
            sk.screenDimEnabled   = false;
            sk.screenSaverEnabled = false;
        }
        else
        {
            sk.screenDimEnabled   = true;
            sk.screenSaverEnabled = true;
        }
    }

    function onIdleChanged()
    {
        if (window.idle) sk.cursorVisible = false;
        else             sk.cursorVisible = true;
    }

    //---------------------------------------------------------------------------------------------
    // Keys

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_Escape)
        {
            event.accepted = true;

            pClose();
        }
        else if (event.key == Qt.Key_Q && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            window.close();
        }
        else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
        {
            event.accepted = true;

            toggleFullScreen()
        }
    }

    function onKeyReleased(event) {}

    //---------------------------------------------------------------------------------------------

    function keyPressed(event) {}

    function keyReleased(event) {}

    //---------------------------------------------------------------------------------------------
    // Private

    function pClose()
    {
        window.close();
    }

    function pRestoreFullScreen()
    {
        window.fullScreen = false;
//#!MAC+!MOBILE
        // FIXME macOS: We can't go from full screen to normal window right away.
        //              This could be related to the animation.
        window.maximized = false;
//#END
    }

    function pGetStep()
    {
        if (player.hasStarted)
        {
            return 3;
        }
        else if (server.isConnected)
        {
            if (player.source) return 2;
            else               return 1;
        }
        else return 0;
    }

    function pGetCover()
    {
        var cover = currentTab.cover;

        // NOTE: We want to avoid a blank cover when the track is loading.
        if (currentTab.isLoading && cover == "")
        {
            return pCover;
        }
        else return cover;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

//#DESKTOP
    ViewDrag
    {
        anchors.fill: parent

        // NOTE: This enables the PointingHandCursor during playback.
        //hoverEnabled: player.isPlaying

        dragEnabled: (window.fullScreen == false)

        cursor: Qt.PointingHandCursor

        onDoubleClicked: toggleFullScreen()
    }
//#END

    Rectangle
    {
        anchors.fill: parent

        visible: (opacity != 0.0)

        opacity: (step > 1) ? 1.0 : 0.0

        color: "black"

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: pDuration

                easing.type: st.easing
            }
        }
    }

    Player
    {
        id: player

        anchors.fill: parent

        visible: hasStarted

        backend: BackendVlc {}

        server: gui.server

        tabs: core.tabs

        Component.onCompleted: core.applyHooks(player)
    }

    Noise
    {
        id: noise

        anchors.fill: parent

        visible: (opacity != 0.0)

        opacity: (step == 0) ? 1.0 : 0.0

        interval: st.noise_interval

        fillMode: Noise.PreserveAspectCrop

        color: st.noise_color

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: pDuration

                easing.type: st.easing
            }
        }
    }

    AnimatedSlideImage
    {
        id: flag

        anchors.fill: parent

        visible: (opacity != 0.0)

        opacity: (step == 1) ? 1.0 : 0.0

        source: st.picture_flag

        smooth: false

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: pDuration

                easing.type: st.easing
            }
        }
    }

    ImageScale
    {
        anchors.centerIn: parent

        width : pSize
        height: width

        visible: (opacity != 0.0)

        opacity: (step < 2) ? 1.0 : 0.0

        source: st.picture_tag

        asynchronous: true

        Image
        {
            id: imageTag

            anchors.centerIn: parent

            width : pSizeTag
            height: pSizeTag

            smooth: false
        }

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: pDuration

                easing.type: st.easing
            }
        }
    }

    // FIXME: When resuming the player gets black right before starting.
    //        So we make sure we have the cover in the foreground.
    ImageScale
    {
        id: cover

        anchors.fill: player

        visible: (opacity != 0.0)
        opacity: 0.0

        source: pGetCover()

        sourceDefault: st.picture_flag

        fillMode: (st.isTight || (player.isStopped == false && pAudio)) ? Image.PreserveAspectFit
                                                                        : Image.PreserveAspectCrop

        // NOTE: When we switch from playback to the cover we want to avoid blinking on the
        //       previous cover.
        onVisibleChanged:
        {
            if (visible) return;

            // NOTE: Disabling asynchronous so we can load the cover as fast as possible before it
            //       gets visible.
            asynchronous = false;
        }

        onSourceChanged:
        {
            pCover = source;

            asynchronous = gui.asynchronous;
        }

        Behavior on opacity
        {
            id: behaviorOpacity

            enabled: false

            PropertyAnimation
            {
                duration: pDuration

                easing.type: st.easing
            }
        }
    }

    Loader
    {
        anchors.fill: parent

        source: (step > 1 && player.videoTag) ? "PageTag.qml" : ""

        asynchronous: true
    }

    Subtitle
    {
        player: player

        function onUpdateMargin()
        {
            margin = applySize(player, cover);
        }
    }

    AnimatedSlideImage
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        height: pSizeLoader

        visible: (opacity != 0.0)

        opacity: (player.isPlaying && player.isLoading) ? 0.8 : 0.0

        source: st.picture_flag

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: st.duration_faster

                easing.type: st.easing
            }
        }
    }

    ButtonTouchIcon
    {
        margins: st.dp8

//#MOBILE
        // NOTE mobile: For now, updates are handled through the stores.
        visible: false
//#ELSE
        visible: pVersion
//#END

        highlighted: isFocused

        icon: st.icon_download

        onClicked:
        {
            // NOTE: We add a two step click to avoid updating by mistake.
            if (isFocused == false)
            {
                setFocus();

                return;
            }

            if (core.updateVersion())
            {
                window.close();

                return;
            }

            Qt.openUrlExternally("https://omega.gg/tevolution/get");
        }
    }

//#DESKTOP
    ButtonsWindow
    {
        anchors.top  : parent.top
        anchors.right: parent.right

        visible: (window.isEntered && window.idle == false)

        buttonMinimize.margins: st.dp10
        buttonMaximize.margins: st.dp10
        buttonClose   .margins: st.dp6

        buttonMinimize.visible: (st.isTight == false)
        buttonMaximize.visible: buttonMinimize.visible
    }
//#END
}
