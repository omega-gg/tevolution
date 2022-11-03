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

Application
{
    id: application

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias gui: loader.item

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pLoad()
    {
        core.load();

        loader.source = "Gui.qml";
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    WindowSky
    {
        id: window

        vsync: local.vsync

        idleCheck: (gui != null)

        st: StyleApplication { id: st }

//#MOBILE
        Component.onCompleted:
        {
            pLoad();

//#ANDROID
            //-------------------------------------------------------------------------------------
            // NOTE android: If we don't do that it seems the background flashes at the beginning.

            sk.processEvents();

            hideSplash(st.duration_faster);

            //-------------------------------------------------------------------------------------
//#END

            online.load();
        }
//#ELSE
        onFadeIn:
        {
            pLoad();

            online.load();
        }
//#END

        /* QML_EVENT */ onMessageReceived: function(message)
        {
            gui.onMessageReceived(message)
        }

        /* QML_EVENT */ onKeyPressed : function(event) { gui.onKeyPressed (event) }
        /* QML_EVENT */ onKeyReleased: function(event) { gui.onKeyReleased(event) }

        /* QML_EVENT */ onViewportKeyPressed: function(event)
        {
            if (gui == null) return;

            event.accepted = true;

            gui.keyPressed(event);
        }

        /* QML_EVENT */ onViewportKeyReleased: function(event) { gui.keyReleased(event); }

        onBeforeClose: gui.onBeforeClose()

        onActiveChanged: if (gui) gui.onActiveChanged()

        onVsyncChanged: local.vsync = window.vsync

        onIdleChanged: gui.onIdleChanged()

//#MOBILE
        onDoubleClicked: gui.toggleFullScreen()
//#END

//#DESKTOP
        onAvailableGeometryChanged: local.screen = screenNumber()
//#END

        Loader
        {
            id: loader

            anchors.fill: parent
        }
    }
}
