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

#ifndef DATALOCAL_H
#define DATALOCAL_H

// Sk includes
#include <WLocalObject>

class DataLocal : public WLocalObject
{
    Q_OBJECT

    Q_PROPERTY(bool vsync READ vsync WRITE setVsync NOTIFY vsyncChanged)

public:
    explicit DataLocal(QObject * parent = NULL);

public: // WLocalObject reimplementation
    /* Q_INVOKABLE virtual */ bool load(bool instant = false);

    /* Q_INVOKABLE virtual */ QString getFilePath() const;

protected: // WLocalObject reimplementation
    /* virtual */ WAbstractThreadAction * onSave(const QString & path);

private: // Functions
    bool extract(const QByteArray & array);

signals:
    void vsyncChanged();

#ifndef SK_NO_TORRENT
    void torrentPortChanged();

    void torrentConnectionsChanged();

    void torrentUploadChanged  ();
    void torrentDownloadChanged();

    void torrentCacheChanged();
#endif

    void broadcastPortChanged();

public: // Properties
    bool vsync() const;
    void setVsync(bool enabled);

#ifndef SK_NO_TORRENT
    int  torrentPort() const;
    void setTorrentPort(int port);

    int  torrentConnections() const;
    void setTorrentConnections(int connections);

    int  torrentUpload() const;
    void setTorrentUpload(int upload);

    int  torrentDownload() const;
    void setTorrentDownload(int download);

    int  torrentCache() const;
    void setTorrentCache(int cache);
#endif

    int  broadcastPort() const;
    void setBroadcastPort(int port);

private: // Variables
    QString _version;

    bool _vsync;

#ifndef SK_NO_TORRENT
    int _torrentPort;

    int _torrentConnections;

    int _torrentUpload;
    int _torrentDownload;

    int _torrentCache;
#endif

    int _broadcastPort;

private:
    Q_DISABLE_COPY(DataLocal)

    friend class ControllerCore;
};

#endif // DATALOCAL_H
