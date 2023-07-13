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

        /* QML_CONNECTION */ function onTagSourceUpdated(image)
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

        Image
        {
            id: imageTag

            anchors.centerIn: parent

            width : gui.sizeTag
            height: gui.sizeTag

            smooth: false
        }
    }

    MagicNumber
    {
        anchors.top: itemTag.bottom

        anchors.topMargin: Math.round(itemTag.height / 6)

        anchors.horizontalCenter: parent.horizontalCenter

        pixelSize: parent.height / 20

        text: core.number

        color: (step) ? "#f0f0f0"
                      : "#dcdcdc"
    }
}
