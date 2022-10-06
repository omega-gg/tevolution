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

#include "ControllerCore.h"

// Qt includes
#include <QDir>

// Sk includes
#include <WControllerApplication>
#include <WControllerFile>
#include <WControllerView>
#include <WControllerDeclarative>
#include <WControllerPlaylist>
#include <WControllerMedia>
#include <WControllerTorrent>
#include <WBroadcastServer>
#include <WViewResizer>
#include <WViewDrag>
#include <WWindow>
#include <WCache>
#include <WLoaderVbml>
#include <WLoaderTorrent>
#include <WHookTorrent>
#include <WTabsTrack>
#include <WTabTrack>
#include <WBackendVlc>
#include <WBackendIndex>
#include <WImageFilterColor>
#include <WImageFilterMask>
#include <WDeclarativeApplication>
#include <WDeclarativeBorders>
#include <WDeclarativeImage>
#include <WDeclarativeImageSvg>
#include <WDeclarativePlayer>
#include <WDeclarativeNoise>
#include <WBarcodeWriter>

// Application includes
#include <DataOnline>

W_INIT_CONTROLLER(ControllerCore)

//-------------------------------------------------------------------------------------------------
// Static variables

static const QString CORE_VERSION = "1.0.0-0";

#ifndef SK_DEPLOY
#ifdef Q_OS_MAC
static const QString PATH_STORAGE = "/../../../storage";
static const QString PATH_BACKEND = "../../../../../backend";
#else
static const QString PATH_STORAGE = "/storage";
static const QString PATH_BACKEND = "../../backend";
#endif
#endif

//-------------------------------------------------------------------------------------------------
// Ctor / dtor
//-------------------------------------------------------------------------------------------------

ControllerCore::ControllerCore() : WController()
{
    _online = NULL;

    _cache = NULL;

    _server = NULL;

    _tabs = NULL;

    _index = NULL;

    //---------------------------------------------------------------------------------------------
    // Settings

    sk->setName("tevolution");

    sk->setVersion(CORE_VERSION);

#ifdef Q_OS_LINUX
    sk->setIcon(":/icons/icon.svg");
#endif

#ifdef SK_DEPLOY
    _path = QDir::fromNativeSeparators(WControllerFile::pathWritable());
#else
    _path = QDir::currentPath() + PATH_STORAGE;
#endif

    wControllerFile->setPathStorage(_path);

    wControllerView->setLoadMode(WControllerView::LoadVisible);

#ifdef SK_DESKTOP
    sk->setDefaultMargins(5);
#endif

    //---------------------------------------------------------------------------------------------
    // DataLocal

    _local.setSaveEnabled(true);

    _local.load(true);

    //---------------------------------------------------------------------------------------------
    // QML
    //---------------------------------------------------------------------------------------------
    // Global

    qmlRegisterUncreatableType<WControllerDeclarative>("Sky", 1,0, "Sk", "Sk is not creatable");

    //---------------------------------------------------------------------------------------------
    // Application

    qmlRegisterType<WDeclarativeApplication>("Sky", 1,0, "Application");

    //---------------------------------------------------------------------------------------------
    // Kernel

    qmlRegisterUncreatableType<WAbstractTabs>("Sky", 1,0, "AbstractTabs",
                                              "AbstractTabs is abstract");

    qmlRegisterUncreatableType<WAbstractTab>("Sky", 1,0, "AbstractTab",
                                             "AbstractTab is abstract");

    //---------------------------------------------------------------------------------------------
    // Network

    qmlRegisterUncreatableType<WBroadcastServer>("Sky", 1,0, "BroadcastServer",
                                                 "ImageFilter not creatable");

    //---------------------------------------------------------------------------------------------
    // View

    qmlRegisterUncreatableType<WView>("Sky", 1,0, "View", "View is abstract");

    qmlRegisterType<WViewResizer>("Sky", 1,0, "ViewResizer");
    qmlRegisterType<WViewDrag>   ("Sky", 1,0, "ViewDrag");

    qmlRegisterType<WWindow>("Sky", 1,0, "BaseWindow");

    //---------------------------------------------------------------------------------------------
    // Image

    qmlRegisterUncreatableType<WImageFilter>("Sky", 1,0, "ImageFilter", "ImageFilter is abstract");

    qmlRegisterType<WImageFilterColor>("Sky", 1,0, "ImageFilterColor");
    qmlRegisterType<WImageFilterMask> ("Sky", 1,0, "ImageFilterMask");

    //---------------------------------------------------------------------------------------------
    // Declarative

    qmlRegisterType<WDeclarativeBorders>("Sky", 1,0, "Borders");

    qmlRegisterType<WDeclarativeMouseArea>("Sky", 1,0, "MouseArea");

    qmlRegisterType<WDeclarativeGradient>    ("Sky", 1,0, "ScaleGradient");
    qmlRegisterType<WDeclarativeGradientStop>("Sky", 1,0, "ScaleGradientStop");

    qmlRegisterType<WDeclarativeImage>     ("Sky", 1,0, "Image");
    qmlRegisterType<WDeclarativeImageScale>("Sky", 1,0, "ImageScale");
    qmlRegisterType<WDeclarativeImageSvg>  ("Sky", 1,0, "ImageSvg");

#ifdef QT_4
    qmlRegisterType<WDeclarativeImageSvgScale>("Sky", 1,0, "ImageSvgScale");
#endif

    qmlRegisterType<WDeclarativePlayer>("Sky", 1,0, "Player");

    qmlRegisterType<WDeclarativeNoise>("Sky", 1,0, "Noise");

    //---------------------------------------------------------------------------------------------
    // Multimedia

#ifdef QT_4
    qmlRegisterUncreatableType<WBackendNet>("Sky", 1,0, "BackendNet", "BackendNet is abstract");
#endif

    qmlRegisterUncreatableType<WAbstractBackend>("Sky", 1,0, "AbstractBackend",
                                                 "AbstractBackend is abstract");

    qmlRegisterUncreatableType<WAbstractHook>("Sky", 1,0, "AbstractHook",
                                              "AbstractHook is abstract");

    qmlRegisterType<WTabsTrack>("Sky", 1,0, "TabsTrack");
    qmlRegisterType<WTabTrack> ("Sky", 1,0, "TabTrack");

    qmlRegisterType<WBackendVlc>("Sky", 1,0, "BackendVlc");

    //---------------------------------------------------------------------------------------------
    // Context

    wControllerDeclarative->setContextProperty("sk", sk);

    wControllerDeclarative->setContextProperty("core",  this);
    wControllerDeclarative->setContextProperty("local", &(_local));
}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

#ifdef SK_DESKTOP

/* Q_INVOKABLE */ void ControllerCore::applyArguments(int & argc, char ** argv)
{
    if (argc < 2) return;

    _argument = QString(argv[1]);
}

#endif

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::load()
{
    if (_cache) return;

    //---------------------------------------------------------------------------------------------
    // DataLocal

    // NOTE: We make sure the storage folder is created.
    _local.createPath();

    //---------------------------------------------------------------------------------------------
    // Message handler

    // FIXME Qt4.8.7: qInstallMsgHandler breaks QML 'Keys' events.
#ifndef QT_4
    wControllerFile->initMessageHandler();
#endif

    //---------------------------------------------------------------------------------------------
    // Paths

    qDebug("tevolution %s", sk->version().C_STR);

    qDebug("Path storage: %s", _path.C_STR);
    qDebug("Path log:     %s", wControllerFile->pathLog().C_STR);
    qDebug("Path config:  %s", _local.getFilePath().C_STR);

    //---------------------------------------------------------------------------------------------
    // Controllers

    W_CREATE_CONTROLLER(WControllerPlaylist);
    W_CREATE_CONTROLLER(WControllerMedia);

#ifndef SK_NO_TORRENT
    W_CREATE_CONTROLLER_2(WControllerTorrent, _path + "/torrents", _local._torrentPort);
#endif

    //---------------------------------------------------------------------------------------------
    // Cache

    _cache = new WCache(_path + "/cache", 1048576 * 100); // 100 megabytes

    wControllerFile->setCache(_cache);

    //---------------------------------------------------------------------------------------------
    // LoaderVbml

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeVbml, new WLoaderVbml(this));

#ifndef SK_NO_TORRENT
    //---------------------------------------------------------------------------------------------
    // LoaderTorrent

    WLoaderTorrent * loaderTorrent = new WLoaderTorrent(this);

    wControllerPlaylist->registerLoader(WBackendNetQuery::TypeTorrent, loaderTorrent);
    wControllerTorrent ->registerLoader(WBackendNetQuery::TypeTorrent, loaderTorrent);
#endif

    //---------------------------------------------------------------------------------------------
    // BroadcastServer

    _server = new WBroadcastServer(_local._broadcastPort, this);

    _server->start();

    emit serverChanged();

#ifndef SK_NO_TORRENT
    //---------------------------------------------------------------------------------------------
    // Torrents

    applyTorrentOptions(_local._torrentConnections,
                        _local._torrentUpload, _local._torrentDownload, _local._torrentCache);
#endif

    //---------------------------------------------------------------------------------------------
    // Tabs

    _tabs = new WTabsTrack(this);

    _tabs->setId(1);

    _tabs->setMaxCount(1);

    _tabs->addTab();

    emit tabsChanged();

    //---------------------------------------------------------------------------------------------
    // Backends

    QString path = _path + "/backend/";

    if (QFile::exists(path) == false)
    {
        WControllerFileReply * reply = copyBackends(path);

        connect(reply, SIGNAL(complete(bool)), this, SLOT(onLoaded()));
    }
    else createIndex();

    //---------------------------------------------------------------------------------------------
    // DataOnline

    _online = new DataOnline(this);

    //---------------------------------------------------------------------------------------------
    // QML

    qmlRegisterType<DataOnline>("Sky", 1,0, "DataOnline");

    wControllerDeclarative->setContextProperty("online", _online);

    //---------------------------------------------------------------------------------------------

    _local.save();
}
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ bool ControllerCore::updateVersion()
{
    if (_online->_version.isEmpty() || _online->_version == CORE_VERSION) return false;

    if (Sk::runUpdate())
    {
        _online->_version = QString();

        return true;
    }
    else return false;
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::resetBackends() const
{
    WControllerFileReply * reply = copyBackends(_path + "/backend/");

    connect(reply, SIGNAL(complete(bool)), this, SLOT(onReload()));
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::generateSource()
{
    WBroadcastServer::startSource(_local._broadcastPort, "https://vbml.omega.gg/connect",
                                  this, SLOT(onSource(const QString &)));
}

/* Q_INVOKABLE */ void ControllerCore::generateTag(const QString & text)
{
    WBarcodeWriter::startWrite(text, this, SIGNAL(tagUpdated(const QImage &)));
}

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ void ControllerCore::clearCache()
{
    _cache->clearFiles();

#ifndef SK_NO_TORRENT
    wControllerTorrent->clearTorrents();
#endif
}

//-------------------------------------------------------------------------------------------------
// Static functions
//-------------------------------------------------------------------------------------------------

#ifndef SK_NO_TORRENT

/* Q_INVOKABLE static */ void ControllerCore::applyTorrentOptions(int connections,
                                                                  int upload, int download,
                                                                  int cache)
{
    wControllerTorrent->setOptions(connections, upload * 1024, download * 1024);

    wControllerTorrent->setSizeMax(qint64(cache) * 1048576);
}

#endif

//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE static */ void ControllerCore::applyHooks(WDeclarativePlayer * player)
{
#ifdef SK_NO_TORRENT
    Q_UNSUED(player);

    return;
#else
    Q_ASSERT(player);

    WAbstractBackend * backend = player->backend();

    Q_ASSERT(backend);

    QList<WAbstractHook *> list;

    list.append(new WHookTorrent(backend));

    player->setHooks(list);
#endif
}

//-------------------------------------------------------------------------------------------------
// Private functions
//-------------------------------------------------------------------------------------------------

void ControllerCore::createIndex()
{
#ifdef SK_NO_TORRENT
    _index = new WBackendIndex(WControllerFile::fileUrl(_path + "/backend/indexLite.vbml"));
#else
    _index = new WBackendIndex(WControllerFile::fileUrl(_path + "/backend/index.vbml"));
#endif

    connect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));

    emit indexChanged();
}

WControllerFileReply * ControllerCore::copyBackends(const QString & path) const
{
#ifdef SK_DEPLOY
#ifdef Q_OS_ANDROID
    return WControllerPlaylist::copyBackends("assets:/backend", path);
#else
    return WControllerPlaylist::copyBackends(WControllerFile::applicationPath("backend"), path);
#endif
#else
    return WControllerPlaylist::copyBackends(WControllerFile::applicationPath(PATH_BACKEND), path);
#endif
}

//-------------------------------------------------------------------------------------------------
// Private slots
//-------------------------------------------------------------------------------------------------

void ControllerCore::onLoaded()
{
    createIndex();
}

void ControllerCore::onIndexLoaded()
{
    disconnect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));

#if defined(SK_BACKEND_LOCAL) && defined(SK_DEPLOY) == false
    // NOTE: This makes sure that we have the latest local vbml loaded.
    resetBackends();

    // NOTE: We want to reload backends when the folder changes.
    _watcher.addFolder(WControllerFile::applicationPath(PATH_BACKEND));

    connect(&_watcher, SIGNAL(foldersModified(const QString &, const QStringList &)),
            this,      SLOT(resetBackends()));
#else
    _index->update();
#endif
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::onReload()
{
    if (_index == NULL) return;

    _index->clearCache();

    _index->reload();

    _index->reloadBackends();
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::onSource(const QString & source)
{
    qDebug("Server source: %s", source.C_STR);

    generateTag(source);
}

//-------------------------------------------------------------------------------------------------
// Properties
//-------------------------------------------------------------------------------------------------

WBroadcastServer * ControllerCore::server()
{
    return _server;
}

WTabsTrack * ControllerCore::tabs() const
{
    return _tabs;
}
