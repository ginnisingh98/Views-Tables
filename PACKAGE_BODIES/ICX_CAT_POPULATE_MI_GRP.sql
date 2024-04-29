--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_MI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_MI_GRP" AS
/* $Header: ICXGPPMB.pls 120.5.12010000.2 2014/02/26 09:39:08 jaxin ship $*/

-- Constants
G_PKG_NAME      CONSTANT VARCHAR2(30):='ICX_CAT_POPULATE_MI_GRP';

-- Called from inventory master item forms / html interface for the following actions:
-- 1. Create an item
-- 2. Update an item
-- 3. Delete an item (only from delete groups)
-- 4. Translation of an item is updated
-- 5. An item is assigned to an org
PROCEDURE populateItemChange
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_dml_type              IN              VARCHAR2                                ,
        p_inventory_item_id     IN              NUMBER                                  ,
        p_item_number           IN              VARCHAR2                                ,
        p_organization_id       IN              NUMBER                                  ,
        p_organization_code     IN              VARCHAR2                                ,
        p_master_org_flag       IN              VARCHAR2                                ,
        p_item_description      IN              VARCHAR2
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateItemChange';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_err_loc			PLS_INTEGER;
l_start_date                    DATE;
l_end_date                      DATE;
l_log_string			VARCHAR2(2000);
l_tmp_count                     NUMBER                  := 0;
BEGIN
  l_err_loc := 100;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_err_loc := 200;
  -- Standard Start of API savepoint
  SAVEPOINT populateItemChange_sp;

  l_err_loc := 300;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_start_date := sysdate;
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    '; Parameter List: p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_dml_type:' || p_dml_type ||
                    ', p_inventory_item_id:' || p_inventory_item_id ||
                    ', p_item_number:' || p_item_number ||
                    ', p_organization_id:' || p_organization_id ||
                    ', p_organization_code:' || p_organization_code ||
                    ', p_master_org_flag:' || p_master_org_flag ||
                    ', p_item_description:' || p_item_description ;
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
  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);

  /* START OF TO BE REMOVED */
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_err_loc := 650;
    SELECT COUNT(*)
    INTO l_tmp_count
    FROM mtl_system_items_kfv mi
    WHERE mi.inventory_item_id = p_inventory_item_id
    AND mi.organization_id = p_organization_id;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Num. of rows from mi for the given inventory_item_id and organization_id:' ||
       l_tmp_count);
    END IF;

    SELECT COUNT(*)
    INTO l_tmp_count
    FROM mtl_system_items_tl mtl
    WHERE mtl.inventory_item_id = p_inventory_item_id
    AND mtl.organization_id = p_organization_id
    AND mtl.language = mtl.source_lang;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Num. of rows from mtl for the given inventory_item_id and organization_id:' ||
       l_tmp_count);
    END IF;

    SELECT COUNT(*)
    INTO l_tmp_count
    FROM mtl_item_categories mic
    WHERE mic.inventory_item_id = p_inventory_item_id
    AND mic.organization_id = p_organization_id
    AND mic.category_set_id = 2;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Num. of rows from mic for the given inventory_item_id and organization_id:' ||
       l_tmp_count);
    END IF;
  END IF;
  /* END OF TO BE REMOVED */

  l_err_loc := 700;
  -- Set the global parameter ICX_CAT_UTIL_PVT.g_ItemCatgChange_const
  ICX_CAT_UTIL_PVT.g_ItemCatgChange_const := FALSE;

  --populateItemChange will always join with mtl_parameters to figure out
  --the child orgs,  If we do it otherwise, then we have to open the
  --populateItemChange cursor many times for each child org

  IF (P_DML_TYPE = 'DELETE') THEN
    -- Info: Deleting an item from the master org also deletes the items from its child orgs
    l_err_loc := 800;
    ICX_CAT_POPULATE_MI_PVT.populateItemDelete(P_INVENTORY_ITEM_ID, P_ORGANIZATION_ID);
  ELSE
    l_err_loc := 900;
    ICX_CAT_POPULATE_MI_PVT.populateItemChange(P_INVENTORY_ITEM_ID, P_ORGANIZATION_ID, NULL, NULL);
  END IF;

  l_err_loc := 1000;
  -- Standard check of P_COMMIT
  IF (FND_API.To_Boolean(P_COMMIT)) THEN
    l_err_loc := 1100;
    COMMIT;
    l_err_loc := 1200;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Rebuild indexes called.');
    END IF;
  ELSE
    l_err_loc := 1300;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'p_commit is false, so Rebuild indexes is not called in.');
    END IF;
  END IF;
  l_err_loc := 1400;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_end_date := sysdate;
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       l_api_name || ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO populateItemChange_sp;
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
END populateItemChange;

-- Called from inventory's item open interface (IOI) for the following actions:
-- 1. Create/Update an item                                     P_ENTITY_TYPE = 'ITEM'
-- 2. Translation of an item is updated                         P_ENTITY_TYPE = 'ITEM'
-- 3. An item is assigned to an org                             P_ENTITY_TYPE = 'ITEM'
-- 4. Create/Update/Delete of an items category assignment      P_ENTITY_TYPE = 'ITEM_CATEGORY'
-- Join with MTL_ITEM_BULKLOAD_RECS to get the changed inventory_item_id and organization_id
PROCEDURE populateBulkItemChange
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_request_id            IN              NUMBER                                  ,
        p_entity_type           IN              VARCHAR2
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateBulkItemChange';
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
  SAVEPOINT populateBulkItemChange_sp;

  l_err_loc := 300;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_request_id:' || p_request_id ||
                    ', p_entity_type:' || p_entity_type;
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
  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);

  l_err_loc := 650;
  -- Log the values from mtl_bulkload_item_recs:
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logMtlItemBulkloadRecsData(p_request_id);
  END IF;

  l_err_loc := 700;
  IF (P_ENTITY_TYPE = 'ITEM') THEN
    l_err_loc := 800;
    -- Set the global parameter ICX_CAT_UTIL_PVT.g_ItemCatgChange_const
    ICX_CAT_UTIL_PVT.g_ItemCatgChange_const := FALSE;

    l_err_loc := 850;
    ICX_CAT_POPULATE_MI_PVT.populateItemChange(NULL, NULL, P_REQUEST_ID, P_ENTITY_TYPE);
  ELSIF (P_ENTITY_TYPE = 'ITEM_CATEGORY') THEN
    l_err_loc := 900;
    -- Set the global parameter ICX_CAT_UTIL_PVT.g_ItemCatgChange_const
    ICX_CAT_UTIL_PVT.g_ItemCatgChange_const := TRUE;

    l_err_loc := 950;
    ICX_CAT_POPULATE_MI_PVT.populateItemCatgChange(NULL, NULL, NULL, P_REQUEST_ID, P_ENTITY_TYPE);
  ELSE
    l_err_loc := 1000;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Invalid entity_type:' || P_ENTITY_TYPE);
    END IF;
  END IF;

  l_err_loc := 1100;
  -- Standard check of P_COMMIT
  IF (FND_API.To_Boolean(P_COMMIT)) THEN
    l_err_loc := 1200;
    COMMIT;
    l_err_loc := 1300;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Rebuild indexes called.');
    END IF;
  ELSE
    l_err_loc := 1400;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
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
      ROLLBACK TO populateBulkItemChange_sp;
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
END populateBulkItemChange;

-- Called from inventory forms / HTML interface for the following actions:
-- 1. Item category assignment is created
-- 2. Item category assignment is updated
-- 3. Item category assignment is deleted
PROCEDURE populateItemCategoryChange
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_dml_type              IN              VARCHAR2                                ,
        p_inventory_item_id     IN              NUMBER                                  ,
        p_item_number           IN              VARCHAR2                                ,
        p_organization_id       IN              NUMBER                                  ,
        p_master_org_flag       IN              VARCHAR2                                ,
        p_category_set_id       IN              NUMBER                                  ,
        p_category_id           IN              NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateItemCategoryChange';
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
  SAVEPOINT populateItemCategoryChange_sp;

  l_err_loc := 300;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', p_api_version:' || p_api_version ||
                    ', p_commit:' || p_commit ||
                    ', p_dml_type:' || p_dml_type ||
                    ', p_inventory_item_id:' || p_inventory_item_id ||
                    ', p_item_number:' || p_item_number ||
                    ', p_organization_id:' || p_organization_id ||
                    ', p_master_org_flag:' || p_master_org_flag ||
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
  IF (ICX_CAT_UTIL_PVT.g_category_set_id <> P_CATEGORY_SET_ID) THEN
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'returning; g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id );
    END IF;
    RETURN;
  END IF;

  l_err_loc := 800;
  ICX_CAT_UTIL_PVT.setCommitParameter(P_COMMIT);

  l_err_loc := 900;
  -- Set the global parameter ICX_CAT_UTIL_PVT.g_ItemCatgChange_const
  ICX_CAT_UTIL_PVT.g_ItemCatgChange_const := TRUE;

  IF (P_DML_TYPE = 'DELETE') THEN
    l_err_loc := 1000;
    ICX_CAT_POPULATE_MI_PVT.populateItemCatgDelete(P_INVENTORY_ITEM_ID, P_ORGANIZATION_ID);
  ELSE
    l_err_loc := 1100;
    ICX_CAT_POPULATE_MI_PVT.populateItemCatgChange(P_INVENTORY_ITEM_ID, P_ORGANIZATION_ID, P_CATEGORY_ID, NULL, NULL);
  END IF;

  l_err_loc := 1200;
  -- Standard check of P_COMMIT
  IF (FND_API.To_Boolean(P_COMMIT)) THEN
    l_err_loc := 1300;
    COMMIT;
    l_err_loc := 1400;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Rebuild indexes called.');
    END IF;
  ELSE
    l_err_loc := 1500;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'p_commit is false, so Rebuild indexes is not called.');
    END IF;
  END IF;

  l_err_loc := 1600;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO populateItemCategoryChange_sp;
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
END populateItemCategoryChange;

END ICX_CAT_POPULATE_MI_GRP;

/
