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

#include "DataLocal.h"

// Qt includes
#include <QXmlStreamWriter>
#include <QFile>

// Sk includes
#include <WControllerApplication>
#include <WControllerXml>
#include <WAbstractThreadAction>

//-------------------------------------------------------------------------------------------------
// Functions declarations

void DataLocal_patch(QString & data, const QString & api);

//-------------------------------------------------------------------------------------------------
// Static variables

// NOTE: Defaut streaming port for tevolution.
static const int DATALOCAL_PORT = 8300;

// NOTE: Defaut broadcasting port.
static const int DATALOCAL_BROADCAST_PORT = 9300;

//=================================================================================================
// DataLocalWrite
//=================================================================================================

class DataLocalWrite : public WAbstractThreadAction
{
    Q_OBJECT

public:
    DataLocalWrite(DataLocal * data)
    {
        this->data = data;
    }

protected: // WAbstractThreadAction reimplementation
    /* virtual */ WAbstractThreadReply * createReply() const;

protected: // WAbstractThreadAction implementation
    /* virtual */ bool run();

public: // Variables
    DataLocal * data;

    QString path;

    QString name;
    QString version;

    bool vsync;

#ifndef SK_NO_TORRENT
    int torrentPort;

    int torrentConnections;

    int torrentUpload;
    int torrentDownload;

    int torrentCache;
#endif

    int broadcastPort;
};

//=================================================================================================
// DataLocalWrite
//=================================================================================================

/* virtual */ WAbstractThreadReply * DataLocalWrite::createReply() const
{
    return new WLocalObjectReplySave(data);
}

/* virtual */ bool DataLocalWrite::run()
{
    QFile file(path);

    if (file.open(QIODevice::WriteOnly) == false)
    {
        qWarning("DataLocalWrite::run: Failed to open file %s.", path.C_STR);

        return false;
    }

    QXmlStreamWriter stream(&file);

    stream.setAutoFormatting(true);

    stream.writeStartDocument();

    stream.writeStartElement(name);

    stream.writeTextElement("version", version);

    stream.writeTextElement("vsync", QString::number(vsync));

#ifndef SK_NO_TORRENT
    stream.writeTextElement("torrentPort", QString::number(torrentPort));

    stream.writeTextElement("torrentConnections", QString::number(torrentConnections));

    stream.writeTextElement("torrentUpload",   QString::number(torrentUpload));
    stream.writeTextElement("torrentDownload", QString::number(torrentDownload));

    stream.writeTextElement("torrentCache", QString::number(torrentCache));
#endif

    stream.writeTextElement("broadcastPort", QString::number(broadcastPort));

    stream.writeEndElement(); // name

    stream.writeEndDocument();

    qDebug("DATA LOCAL SAVED");

    return true;
}

//=================================================================================================
// DataLocal
//=================================================================================================

/* explicit */ DataLocal::DataLocal(QObject * parent) : WLocalObject(parent)
{
#ifdef QT_4
    _vsync = false;
#else
    // NOTE Qt5: Without vsync animations are messed up.
    _vsync = true;
#endif

#ifndef SK_NO_TORRENT
    _torrentPort = DATALOCAL_PORT;

    // FIXME: Let's try 200 because why not ?
    _torrentConnections = 200;

    _torrentUpload   = 0;
    _torrentDownload = 0;

    _torrentCache = 2000;
#endif

    _broadcastPort = DATALOCAL_BROADCAST_PORT;
}

//-------------------------------------------------------------------------------------------------
// WLocalObject reimplementation
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE virtual */ bool DataLocal::load(bool)
{
    QString path = getFilePath();

    QFile file(path);

    if (file.exists() == false) return false;

    if (file.open(QIODevice::ReadOnly) == false)
    {
        qWarning("DataLocal::load: Failed to open file %s.", path.C_STR);

        return false;
    }

    return extract(file.readAll());
}

/* Q_INVOKABLE virtual */ QString DataLocal::getFilePath() const
{
    return getParentPath() + "/data.xml";
}

//-------------------------------------------------------------------------------------------------
// Protected WLocalObject reimplementation
//-------------------------------------------------------------------------------------------------

/* virtual */ WAbstractThreadAction * DataLocal::onSave(const QString & path)
{
    DataLocalWrite * action = new DataLocalWrite(this);

    action->path = path;

    action->name    = sk->name   ();
    action->version = sk->version();

    action->vsync = _vsync;

#ifndef SK_NO_TORRENT
    action->torrentPort = _torrentPort;

    action->torrentConnections = _torrentConnections;

    action->torrentUpload   = _torrentUpload;
    action->torrentDownload = _torrentDownload;

    action->torrentCache = _torrentCache;
#endif

    action->broadcastPort = _broadcastPort;

    return action;
}

//-------------------------------------------------------------------------------------------------
// Private functions
//-------------------------------------------------------------------------------------------------

bool DataLocal::extract(const QByteArray & array)
{
    QXmlStreamReader stream(array);

    //---------------------------------------------------------------------------------------------
    // version

    if (WControllerXml::readNextStartElement(&stream, "version") == false) return false;

    _version = WControllerXml::readNextString(&stream);

    if (Sk::versionIsHigher(sk->version(), _version))
    {
        QString content = array;

        DataLocal_patch(content, _version);

        return extract(content.toUtf8());
    }

    //---------------------------------------------------------------------------------------------
    // vsync

    if (WControllerXml::readNextStartElement(&stream, "vsync") == false) return false;

    _vsync = WControllerXml::readNextInt(&stream);

#ifndef SK_NO_TORRENT
    //---------------------------------------------------------------------------------------------
    // torrentPort

    if (WControllerXml::readNextStartElement(&stream, "torrentPort") == false) return false;

    _torrentPort = WControllerXml::readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentConnections

    if (WControllerXml::readNextStartElement(&stream, "torrentConnections") == false) return false;

    _torrentConnections = WControllerXml::readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentUpload

    if (WControllerXml::readNextStartElement(&stream, "torrentUpload") == false) return false;

    _torrentUpload = WControllerXml::readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentDownload

    if (WControllerXml::readNextStartElement(&stream, "torrentDownload") == false) return false;

    _torrentDownload = WControllerXml::readNextInt(&stream);

    //---------------------------------------------------------------------------------------------
    // torrentCache

    if (WControllerXml::readNextStartElement(&stream, "torrentCache") == false) return false;

    _torrentCache = WControllerXml::readNextInt(&stream);
#endif

    //---------------------------------------------------------------------------------------------
    // broadcastPort

    if (WControllerXml::readNextStartElement(&stream, "broadcastPort") == false) return false;

    _broadcastPort = WControllerXml::readNextInt(&stream);

    qDebug("DATA LOCAL LOADED");

    return true;
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

bool DataLocal::vsync() const
{
    return _vsync;
}

void DataLocal::setVsync(bool enabled)
{
    if (_vsync == enabled) return;

    _vsync = enabled;

    emit vsyncChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

#ifndef SK_NO_TORRENT

int DataLocal::torrentPort() const
{
    return _torrentPort;
}

void DataLocal::setTorrentPort(int port)
{
    if (_torrentPort == port) return;

    _torrentPort = port;

    emit torrentPortChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

int DataLocal::torrentConnections() const
{
    return _torrentConnections;
}

void DataLocal::setTorrentConnections(int connections)
{
    if (_torrentConnections == connections) return;

    _torrentConnections = connections;

    emit torrentConnectionsChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

int DataLocal::torrentUpload() const
{
    return _torrentUpload;
}

void DataLocal::setTorrentUpload(int upload)
{
    if (_torrentUpload == upload) return;

    _torrentUpload = upload;

    emit torrentUploadChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

int DataLocal::torrentDownload() const
{
    return _torrentDownload;
}

void DataLocal::setTorrentDownload(int download)
{
    if (_torrentDownload == download) return;

    _torrentDownload = download;

    emit torrentDownloadChanged();

    save();
}

//-------------------------------------------------------------------------------------------------

int DataLocal::torrentCache() const
{
    return _torrentCache;
}

void DataLocal::setTorrentCache(int cache)
{
    if (_torrentCache == cache) return;

    _torrentCache = cache;

    emit torrentCacheChanged();

    save();
}

#endif

//-------------------------------------------------------------------------------------------------

int DataLocal::broadcastPort() const
{
    return _broadcastPort;
}

void DataLocal::setBroadcastPort(int port)
{
    if (_broadcastPort == port) return;

    _broadcastPort = port;

    emit broadcastPortChanged();

    save();
}

#include "DataLocal.moc"
