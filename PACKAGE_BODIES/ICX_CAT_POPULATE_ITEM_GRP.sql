--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_ITEM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_ITEM_GRP" AS
/* $Header: ICXGPPIB.pls 120.4 2005/12/13 15:28:19 sbgeorge noship $*/

-- Constants
G_PKG_NAME      CONSTANT VARCHAR2(30):='ICX_CAT_POPULATE_ITEM_GRP';

PROCEDURE populateVendorNameChanges
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_vendor_id             IN              NUMBER                                  ,
        p_vendor_name           IN              VARCHAR2
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateVendorNameChanges';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_start_date			DATE;
l_end_date			DATE;
l_log_string			VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT populateVendorNameChanges_sp;

  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_vendor_id:' || p_vendor_id ||
                    ', p_vendor_name:' || p_vendor_name ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);

  ICX_CAT_POPULATE_ITEM_PVT.populateVendorNameChanges(p_vendor_id, p_vendor_name);

  -- Standard check of P_COMMIT
  IF (FND_API.To_Boolean(P_COMMIT)) THEN
    COMMIT;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Commit done.');
    END IF;
  ELSE
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Commit not done.');
    END IF;
  END IF;

  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO populateVendorNameChanges_sp;
    EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                         ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                         'ROLLBACK TO the savepoint caused the exception -->'
                         || SQLERRM);
        END IF;
        NULL;
    END;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END populateVendorNameChanges;

PROCEDURE populateVendorMerge
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_from_vendor_id        IN              NUMBER                                  ,
        p_from_site_id          IN              NUMBER                                  ,
        p_to_vendor_id          IN              NUMBER                                  ,
        p_to_site_id            IN              NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateVendorMerge';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_start_date			DATE;
l_end_date			DATE;
l_log_string			VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT populateVendorMerge_sp;

  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_from_vendor_id:' || p_from_vendor_id ||
                    ', p_from_site_id:' || p_from_site_id ||
                    ', p_to_vendor_id:' || p_to_vendor_id ||
                    ', p_to_site_id:' || p_to_site_id ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);

  ICX_CAT_POPULATE_ITEM_PVT.populateVendorMerge(p_from_vendor_id, p_from_site_id, p_to_vendor_id, p_to_site_id);

  -- Standard check of P_COMMIT
  IF (FND_API.To_Boolean(P_COMMIT)) THEN
    COMMIT;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Commit done.');
    END IF;
  ELSE
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Commit not done.');
    END IF;
  END IF;

  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO populateVendorMerge_sp;
    EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                         ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                         'ROLLBACK TO the savepoint caused the exception -->'
                         || SQLERRM);
        END IF;
        NULL;
    END;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END populateVendorMerge;

PROCEDURE rebuildIPIntermediaIndex
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_TRUE              ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'rebuildIPIntermediaIndex';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_err_loc			PLS_INTEGER;
l_start_date			DATE;
l_end_date			DATE;
l_log_string			VARCHAR2(2000);

BEGIN
  l_err_loc := 100;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_err_loc := 200;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 300;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
    l_err_loc := 400;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 500;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' About to call rebuild_index');
  END IF;

  l_err_loc := 600;
  ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;

  l_err_loc := 700;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END rebuildIPIntermediaIndex;

END ICX_CAT_POPULATE_ITEM_GRP;

/
