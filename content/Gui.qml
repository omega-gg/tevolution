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

    property bool asynchronous: true

    /* read */ property variant server: core.server

    /* read */ property variant currentTab: core.tabs.currentTab

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pConnected: server.isConnected

    property int pSize: (st.isTight) ? height / 3
                                     : height / 2

    // NOTE: Margins are 56 pixels on a 512 tag.
    property int pSizeTag: pSize * 0.890625

    property bool pAudio: (player.outputActive == AbstractBackend.OutputAudio || player.isAudio
                           ||
                           player.hasOutput)

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

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onTagUpdated(image)
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

    function getColor()
    {
        if (cover.visible || player.visible)
        {
             return "black";
        }
        else return st.window_color;
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onMessageReceived(message) {}

    function onBeforeClose() {}

    function onActiveChanged()
    {
        // NOTE: We want to avoid screen dimming at all time.
        sk.screenDimEnabled = window.isActive;
    }

    function onIdleChanged()
    {
        if (window.idle && player.isPlaying)
        {
             sk.cursorVisible = false;
        }
        else sk.cursorVisible = true;
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
        if (window.fullScreen)
        {
            pRestoreFullScreen();
        }
        else window.close();
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

    // FIXME: When resuming the player gets black right before starting.
    //        So we make sure we have the cover in the foreground.
    ImageScale
    {
        id: cover

        anchors.fill: player

        visible: (isSourceDefault == false
                  &&
                  (player.isStopped || player.isStarting || player.isResuming || pAudio))

        source: currentTab.cover

        fillMode: (st.isTight || (player.isStopped == false && pAudio)) ? Image.PreserveAspectFit
                                                                        : Image.PreserveAspectCrop

        asynchronous: gui.asynchronous

        // NOTE: When we switch from playback to the cover we want to avoid blinking on the
        //       previous cover. So we load it now.
        onVisibleChanged: if (visible) loadNow()
    }

    Noise
    {
        id: noise

        anchors.fill: parent

        visible: (player.visible == false && flag.opacity != 1.0)

        interval: st.noise_interval

        fillMode: Noise.PreserveAspectCrop

        color: st.noise_color
    }

    AnimatedSlideImage
    {
        id: flag

        anchors.fill: parent

        visible: (player.visible == false && cover.visible == false && opacity != 0.0)

        opacity: (pConnected) ? 1.0 : 0.0

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

        visible: (player.visible == false && cover.visible == false)

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
