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

#ifndef CONTROLLERCORE_H
#define CONTROLLERCORE_H

// Sk includes
#include <WController>
#ifndef SK_DEPLOY
#include <WFileWatcher>
#endif

// Application includes
#include <DataLocal>

// Defines
#define core ControllerCore::instance()

// Forward declarations
class WControllerFileReply;
class DataOnline;
class WAbstractBackend;
class WAbstractHook;
class WCache;
class WBroadcastServer;
class WBackendIndex;
class WTabsTrack;
class WDeclarativePlayer;

class ControllerCore : public WController
{
    Q_OBJECT

    Q_PROPERTY(WBroadcastServer * server READ server NOTIFY serverChanged)

    Q_PROPERTY(WTabsTrack * tabs READ tabs NOTIFY tabsChanged)

private:
    ControllerCore();

public: // Interface
#ifdef SK_DESKTOP
    Q_INVOKABLE void applyArguments(int & argc, char ** argv);
#endif

    Q_INVOKABLE void load();

    Q_INVOKABLE bool updateVersion();

    Q_INVOKABLE void resetBackends() const;

    Q_INVOKABLE void generateTag(const QString & vbml, const QString & prefix);

    Q_INVOKABLE void generateSource();

    Q_INVOKABLE void generateSourceTag(const QString & text);

    Q_INVOKABLE void clearCache();

public: // Static functions
#ifndef SK_NO_TORRENT
    Q_INVOKABLE static void applyTorrentOptions(int connections,
                                                int upload, int download, int cache);
#endif

    Q_INVOKABLE static void applyHooks(WDeclarativePlayer * player);

private: // Functions
    void createIndex();

    WControllerFileReply * copyBackends(const QString & path) const;

private slots:
    void onLoaded     ();
    void onIndexLoaded();

    void onReload();

    void onSource(const QString & source);

signals:
    void tagUpdated(const QImage & image);

    void serverChanged();

    void tabsChanged();

    void indexChanged();

public: // Properties
    WBroadcastServer * server();

    WTabsTrack * tabs() const;

private: // Variables
#ifdef SK_DESKTOP
    QString _argument;
#endif

    DataLocal    _local;
    DataOnline * _online;

    WCache * _cache;

    WBroadcastServer * _server;

    QString _path;

    WTabsTrack * _tabs;

    WBackendIndex * _index;

#ifndef SK_DEPLOY
    WFileWatcher _watcher;
#endif

private:
    Q_DISABLE_COPY      (ControllerCore)
    W_DECLARE_CONTROLLER(ControllerCore)
};

#endif // CONTROLLERCORE_H
