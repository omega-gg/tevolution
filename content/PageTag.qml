//=================================================================================================
/*
    Copyright (C) 2020-2026 tevolution authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of tevolution.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.

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

    // NOTE: This is useful for web compliant VideoTag(s).
    property string pPrefix: "https://vbml.omega.gg/"

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    opacity: 0.0

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: pUpdateTag()

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onTagUpdated(image, text)
        {
            imageTag.applyImage(image);

            // NOTE: We want to display the tag once the image is ready.
            opacity = 1.0;
        }
    }

    Connections
    {
        target: currentTab

        /* QML_CONNECTION */ function onCurrentBookmarkUpdated()
        {
            pUpdateTag();
        }
    }

    Connections
    {
        target: player

        /* QML_CONNECTION */ function onCurrentTimeChanged()
        {
            pUpdateTag();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function pUpdateTag()
    {
        if (currentTab.isValid == false)
        {
            timer.stop();

            imageTag.clearPixmap();

            return;
        }

        timer.restart();
    }

    function pApplyFragment(source, key, value)
    {
        if (value)
        {
             return controllerNetwork.applyFragmentValue(source, key, value);
        }
        else return controllerNetwork.removeFragmentValue(source, key);
    }

    function pApplyTime(source)
    {
        var time;

        if (player.isLive == false)
        {
            // NOTE: We want to save the current time in seconds and floored.
            time = Math.floor(player.currentTime / 1000);

            return controllerNetwork.applyFragmentValue(source, 't', time);
        }
        // NOTE: We are not saving the currentTime on a live stream.
        else time = 0;

        return pApplyFragment(source, 't', time);
    }

    function pGetVbml()
    {
        var source = pApplyTime(currentTab.source);

        return currentTab.toVbml(source, player.currentTime);
    }

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
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: 100

        onTriggered: core.generateTag(pGetVbml(), pPrefix)
    }

    ImageScale
    {
        anchors.centerIn: parent

        width : gui.size
        height: width

        source: st.picture_tag

        asynchronous: true
    }

    SkyImage
    {
        id: imageTag

        anchors.centerIn: parent

        width : gui.sizeTag
        height: gui.sizeTag

        smooth: false
    }
}
