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
    // Aliases
    //---------------------------------------------------------------------------------------------

//#!DEPLOY
    property alias codeNumber: codeNumber
//#END

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    visible: (opacity != 0.0)
    opacity: 0.0

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        if (tagImage) imageTag.applyImage(tagImage)

        opacity = 1.0;
    }

    onVisibleChanged: tagVisible = visible

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onTagSourceUpdated(image, text)
        {
            tagImage = image;

            imageTag.applyImage(image);
        }
    }

    Connections
    {
        target: gui

        /* QML_CONNECTION */ function onStepChanged()
        {
            if (step < 2) opacity = 1.0;
            else          opacity = 0.0;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Animations
    //---------------------------------------------------------------------------------------------

    Behavior on opacity
    {
        PropertyAnimation
        {
            duration: gui.durationAnimation

            easing.type: st.easing
        }
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    ImageScale
    {
        id: itemTag

        anchors.centerIn: parent

        width : gui.size
        height: width

        source: st.picture_tag

        asynchronous: true

        SkyImage
        {
            id: imageTag

            anchors.centerIn: parent

            width : gui.sizeTag
            height: gui.sizeTag

            smooth: false
        }
    }

    CodeNumber
    {
//#!DEPLOY
        id: codeNumber
//#END

        anchors.top: itemTag.bottom

        anchors.topMargin: Math.round(itemTag.height / 9)

        anchors.horizontalCenter: parent.horizontalCenter

        pixelSize: gui.size / 10

        text: core.number
    }
}
