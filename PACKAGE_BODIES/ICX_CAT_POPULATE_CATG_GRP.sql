--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_CATG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_CATG_GRP" AS
/* $Header: ICXGPPCB.pls 120.2 2005/12/13 15:29:13 sbgeorge noship $*/

-- Constants
G_PKG_NAME      CONSTANT VARCHAR2(30):='ICX_CAT_POPULATE_CATG_GRP';

-- Called from inventory category forms / html interface for the following actions:
-- 1. Create a category
-- 2. Update a category
-- 3. Translation of a category is updated
-- Note: These informations are provided by Inventory team in 2005
-- 1. Deleting a category is not allowed from category forms / html interface
-- 2. No bulk operations (i.e loading data from an interface table) are allowed on category
PROCEDURE populateCategoryChange
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_dml_type              IN              VARCHAR2                                ,
        p_structure_id          IN              NUMBER                                  ,
        p_category_name         IN              VARCHAR2                                ,
        p_category_id           IN              NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateCategoryChange';
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
  SAVEPOINT populateCategoryChange_sp;

  l_err_loc := 300;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_dml_type:' || p_dml_type ||
                    ', p_structure_id:' || p_structure_id ||
                    ', p_category_name:' || p_category_name ||
                    ', p_category_id:' || p_category_id;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 400;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
    l_err_loc := 500;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 600;
  --Initialize the purchasing category set info.
  ICX_CAT_UTIL_PVT.getPurchasingCategorySetInfo;

  l_err_loc := 700;
  IF (ICX_CAT_UTIL_PVT.g_structure_id <> P_STRUCTURE_ID OR
      (P_DML_TYPE = 'CREATE' AND ICX_CAT_UTIL_PVT.g_validate_flag = 'Y')) THEN
    -- If ICX_CAT_UTIL_PVT.g_validate_flag is 'Y'
    -- Then ip does not have to process the category added to mtl_categories_b
    -- This category will be processed when it is added to the valid cats
    -- in the call to populateValidCategorySetInsert
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'returning; g_structure_id:' || ICX_CAT_UTIL_PVT.g_structure_id ||
          ', P_DML_TYPE:' || P_DML_TYPE ||
          ', g_validate_flag:' || ICX_CAT_UTIL_PVT.g_validate_flag );
    END IF;
    RETURN;
  END IF;


  l_err_loc := 800;
  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);
  l_err_loc := 900;
  ICX_CAT_POPULATE_CATG_PVT.g_DML_TYPE := P_DML_TYPE;

  l_err_loc := 1000;
  ICX_CAT_POPULATE_CATG_PVT.populateCategoryChange(P_CATEGORY_NAME, P_CATEGORY_ID);

  l_err_loc := 1100;
  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    l_err_loc := 1200;
    COMMIT;
    l_err_loc := 1300;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Rebuild indexes called.');
    END IF;
  ELSE
    l_err_loc := 1400;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'p_commit is false, so Rebuild indexes is not called.');
    END IF;
  END IF;

  l_err_loc := 1500;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO populateCategoryChange_sp;
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
END populateCategoryChange;

-- Called from inventory category forms / html interface for the following actions:
-- 1. A category is added to valid cat sets
-- Note: These informations are provided by Inventory team in 2005
-- 1. No bulk operations (i.e loading data from an interface table) allowed on valid cat sets
PROCEDURE populateValidCategorySetInsert
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_category_set_id       IN              NUMBER                                  ,
        p_category_id           IN              NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateValidCategorySetInsert';
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
  SAVEPOINT popValidCatgSetInsert_sp;

  l_err_loc := 300;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_category_set_id:' || p_category_set_id ||
                    ', p_category_id:' || p_category_id;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 400;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
    l_err_loc := 500;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 600;
  --Initialize the purchasing category set info.
  ICX_CAT_UTIL_PVT.getPurchasingCategorySetInfo;

  l_err_loc := 700;
  IF (ICX_CAT_UTIL_PVT.g_category_set_id <> P_CATEGORY_SET_ID OR
      ICX_CAT_UTIL_PVT.g_validate_flag = 'N') THEN
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'returning; g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
          ', g_validate_flag:' || ICX_CAT_UTIL_PVT.g_validate_flag );
    END IF;
    RETURN;
  END IF;

  l_err_loc := 800;
  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);
  l_err_loc := 900;
  ICX_CAT_POPULATE_CATG_PVT.g_DML_TYPE := ICX_CAT_POPULATE_CATG_PVT.g_DML_INSERT_TYPE;

  l_err_loc := 1000;
  ICX_CAT_POPULATE_CATG_PVT.populateValidCategorySetInsert(P_CATEGORY_ID);

  l_err_loc := 1100;
  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    l_err_loc := 1200;
    COMMIT;
    l_err_loc := 1300;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Rebuild indexes called.');
    END IF;
  ELSE
    l_err_loc := 1400;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'p_commit is false, so Rebuild indexes is not called.');
    END IF;
  END IF;

  l_err_loc := 1500;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO popValidCatgSetInsert_sp;
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
END populateValidCategorySetInsert;

-- Called from inventory category forms / html interface for the following actions:
-- 1. A category is updated in valid cat sets
-- Note: These informations are provided by Inventory team in 2005
-- 1. No bulk operations (i.e loading data from an interface table) allowed on valid cat sets
PROCEDURE populateValidCategorySetUpdate
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_category_set_id       IN              NUMBER                                  ,
        p_old_category_id       IN              NUMBER                                  ,
        p_new_category_id       IN              NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateValidCategorySetUpdate';
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
  SAVEPOINT popValidCatgSetUpdate_sp;

  l_err_loc := 300;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_category_set_id:' || p_category_set_id ||
                    ', p_old_category_id:' || p_old_category_id ||
                    ', p_new_category_id:' || p_new_category_id ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 400;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
    l_err_loc := 500;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 600;
  --Initialize the purchasing category set info.
  ICX_CAT_UTIL_PVT.getPurchasingCategorySetInfo;

  l_err_loc := 700;
  IF (ICX_CAT_UTIL_PVT.g_category_set_id <> P_CATEGORY_SET_ID OR
      ICX_CAT_UTIL_PVT.g_validate_flag = 'N') THEN
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'returning; g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
          ', g_validate_flag:' || ICX_CAT_UTIL_PVT.g_validate_flag );
    END IF;
    RETURN;
  END IF;

  l_err_loc := 800;
  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);
  l_err_loc := 900;
  ICX_CAT_POPULATE_CATG_PVT.g_DML_TYPE := ICX_CAT_POPULATE_CATG_PVT.g_DML_UPDATE_TYPE;

  l_err_loc := 1000;
  ICX_CAT_POPULATE_CATG_PVT.populateValidCategorySetUpdate(P_OLD_CATEGORY_ID, P_NEW_CATEGORY_ID);

  l_err_loc := 1100;
  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    l_err_loc := 1200;
    COMMIT;
    l_err_loc := 1300;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Rebuild indexes called.');
    END IF;
  ELSE
    l_err_loc := 1400;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'p_commit is false, so Rebuild indexes is not called.');
    END IF;
  END IF;

  l_err_loc := 1500;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO popValidCatgSetUpdate_sp;
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
END populateValidCategorySetUpdate;

-- Called from inventory category forms / html interface for the following actions:
-- 1. A category is deleted from valid cat sets
-- Note: These informations are provided by Inventory team in 2005
-- 1. No bulk operations (i.e loading data from an interface table) allowed on valid cat sets
PROCEDURE populateValidCategorySetDelete
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_category_set_id       IN              NUMBER                                  ,
        p_category_id           IN              NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateValidCategorySetDelete';
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
  SAVEPOINT popValidCatgSetDelete_sp;

  l_err_loc := 300;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS')  ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_category_set_id:' || p_category_set_id ||
                    ', p_category_id:' || p_category_id;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 400;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
    l_err_loc := 500;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 600;
  --Initialize the purchasing category set info.
  ICX_CAT_UTIL_PVT.getPurchasingCategorySetInfo;

  l_err_loc := 700;
  IF (ICX_CAT_UTIL_PVT.g_category_set_id <> P_CATEGORY_SET_ID OR
      ICX_CAT_UTIL_PVT.g_validate_flag = 'N') THEN
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'returning; g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
          ', g_validate_flag:' || ICX_CAT_UTIL_PVT.g_validate_flag );
    END IF;
    RETURN;
  END IF;

  l_err_loc := 800;
  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);

  l_err_loc := 900;
  ICX_CAT_POPULATE_CATG_PVT.g_DML_TYPE := ICX_CAT_POPULATE_CATG_PVT.g_DML_DELETE_TYPE;

  l_err_loc := 1000;
  ICX_CAT_POPULATE_CATG_PVT.populateValidCategorySetDelete(P_CATEGORY_ID);

  l_err_loc := 1100;
  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    l_err_loc := 1200;
    COMMIT;
    l_err_loc := 1300;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Rebuild indexes called.');
    END IF;
  ELSE
    l_err_loc := 1400;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'p_commit is false, so Rebuild indexes is not called.');
    END IF;
  END IF;

  l_err_loc := 1500;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO popValidCatgSetDelete_sp;
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
END populateValidCategorySetDelete;

END ICX_CAT_POPULATE_CATG_GRP;

/
