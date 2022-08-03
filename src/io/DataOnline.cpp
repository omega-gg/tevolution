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

#include "DataOnline.h"

// Qt includes
#include <QXmlStreamReader>
#ifndef SK_DEPLOY
#include <QDir>
#endif

// Sk includes
#include <WControllerDownload>
#include <WControllerXml>

//-------------------------------------------------------------------------------------------------
// Static variables

static const QString ONLINE_PATH = "http://omega.gg/get/tevolution/1.0.0/data.xml";

//-------------------------------------------------------------------------------------------------
// Ctor / dtor
//-------------------------------------------------------------------------------------------------

/* explicit */ DataOnline::DataOnline(QObject * parent) : QObject(parent) {}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataOnline::load()
{
#ifdef SK_DEPLOY
    loadFile();

    startTimer(3600000); // 1 hour
#endif
}

//-------------------------------------------------------------------------------------------------
// Events
//-------------------------------------------------------------------------------------------------

/* virtual */ void DataOnline::timerEvent(QTimerEvent *)
{
    loadFile();
}

//-------------------------------------------------------------------------------------------------
// Private functions
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void DataOnline::loadFile()
{
    WRemoteData * data = wControllerDownload->getData(ONLINE_PATH, this);

    connect(data, SIGNAL(loaded(WRemoteData *)), this, SLOT(onLoaded(WRemoteData *)));
}

//-------------------------------------------------------------------------------------------------
// Private slots
//-------------------------------------------------------------------------------------------------

void DataOnline::onLoaded(WRemoteData * data)
{
    _version = QString();

    QXmlStreamReader stream(data->reply());

    while (stream.atEnd() == false)
    {
        QXmlStreamReader::TokenType type = stream.readNext();

        if (type != QXmlStreamReader::StartElement) continue;

        if (stream.name() == QString("version"))
        {
            _version = WControllerXml::readNextString(&stream);
        }
    }

    emit dataChanged();
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

QString DataOnline::version() const
{
    return _version;
}
