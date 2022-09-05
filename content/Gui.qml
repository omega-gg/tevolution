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
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // Private

    property int pSize: (st.isTight) ? height / 3
                                     : height / 2

    // NOTE: Margins are 56 pixels on a 512 tag.
    property int pSizeTag: pSize * 0.890625

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

        core.generateTag("https://vbml.omega.gg/");
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
        if (window.fullScreen)
        {
            window.fullScreen = false;
//#!MAC+!MOBILE
            // FIXME macOS: We can't go from full screen to normal window right away.
            //              This could be related to the animation.
            window.maximized = false;
//#END
        }
        else
        {
            window.fullScreen = true;

            //if (player.isPlaying == false) return;

            window.idle = true;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onMessageReceived(message) {}

    function onBeforeClose() {}

    function onActiveChanged() {}

    function onIdleChanged() {}

    //---------------------------------------------------------------------------------------------
    // Keys

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_Escape)
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

    Noise
    {
        anchors.fill: parent

        interval: st.noise_interval

        fillMode: Noise.PreserveAspectCrop

        color: st.noise_color
    }

    ImageScale
    {
        anchors.centerIn: parent

        width : pSize
        height: width

        source: st.picture_tag

        asynchronous: true
    }

    Image
    {
        id: imageTag

        anchors.centerIn: parent

        width : pSizeTag
        height: pSizeTag

        smooth: false
    }
}
