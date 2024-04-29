--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_QUOTE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_QUOTE_GRP" AS
/* $Header: ICXGPPQB.pls 120.2 2005/12/13 15:28:36 sbgeorge noship $*/

-- Constants
G_PKG_NAME      CONSTANT VARCHAR2(30):='ICX_CAT_POPULATE_QUOTE_GRP';

PROCEDURE populateOnlineQuotes
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_key                   IN              NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateOnlineQuotes';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_err_loc			PLS_INTEGER;
l_start_date			DATE;
l_end_date			DATE;
l_log_string			VARCHAR2(2000);

BEGIN
  l_err_loc := 100;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_err_loc := 200;
  -- Standard Start of API savepoint
  SAVEPOINT populateOnlineQuotes_sp;

  l_err_loc := 300;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_key:' || p_key;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 400;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 500;
  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);

  l_err_loc := 600;
  ICX_CAT_POPULATE_PODOCS_PVT.populateOnlineQuotes(p_key);

  l_err_loc := 700;
  -- Standard check of P_COMMIT
  IF (FND_API.To_Boolean(P_COMMIT)) THEN
    l_err_loc := 800;
    COMMIT;
    l_err_loc := 900;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Rebuild indexes called.');
    END IF;
  ELSE
    l_err_loc := 1000;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'p_commit is false, so Rebuild indexes is not called.');
    END IF;
  END IF;

  l_err_loc := 1100;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO populateOnlineQuotes_sp;
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
END populateOnlineQuotes;

END ICX_CAT_POPULATE_QUOTE_GRP;

/
