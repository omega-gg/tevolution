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
//#DEPLOY
        if (event.key == Qt.Key_Q && event.modifiers == Qt.ControlModifier)
//#ELSE
        // NOTE dev: It's useful to close the application quickly.
        if (event.key == Qt.Key_Escape)
//#END
        {
            event.accepted = true;

            window.close();
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
}
