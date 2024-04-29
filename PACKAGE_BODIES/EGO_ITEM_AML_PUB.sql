--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_AML_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_AML_PUB" AS
/* $Header: EGOITAMB.pls 120.7.12000000.2 2007/07/10 13:49:49 ksathupa ship $ */

-- =============================================================================
--                         Package variables and cursors
-- =============================================================================

G_FILE_NAME          CONSTANT  VARCHAR2(12)  := 'EGOITAMB.pls';
G_PKG_NAME           CONSTANT  VARCHAR2(30)  := 'EGO_ITEM_AML_PUB';
G_EGO_ITEM           CONSTANT  VARCHAR2(30)  := 'EGO_ITEM';

G_ADD_ACD_TYPE       CONSTANT  VARCHAR2(10) := 'ADD';
G_CHANGE_ACD_TYPE    CONSTANT  VARCHAR2(10) := 'CHANGE';
G_DELETE_ACD_TYPE    CONSTANT  VARCHAR2(10) := 'DELETE';
G_HISTORY_ACD_TYPE   CONSTANT  VARCHAR2(10) := 'HISTORY';

-- =============================================================================
--                     Private Functions and Procedures
-- =============================================================================

--
-- write debug into log
--
PROCEDURE log_now (p_log_level  IN NUMBER
                  ,p_module     IN VARCHAR2
                  ,p_message    IN VARCHAR2
                  ) IS
BEGIN
  IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(log_level => p_log_level
                  ,module    => 'fnd.plsql.ego.EGO_ITEM_AML_PUB.'||p_module
                  ,message   => p_message
                  );
  END IF;
--  sri_debug (p_message);
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END log_now;


-- =============================================================================
--                     Public Functions and Procedures
-- =============================================================================

FUNCTION Check_CM_Existance RETURN VARCHAR2 IS
  ----------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Check_Change_Management_Existance
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : Check whether CM is installed and active
  --               (the table ENG_CHANGE_MGMT_TYPES_VL is populated)
  --
  -- Return Parameter:
  --           'S' if view eng_change_mgmt_types_vl is populated
  --           'E' in all other cases
  --
  ----------------------------------------------------------------------------
  l_product_exists   VARCHAR2(1) := G_RET_STS_ERROR;
  --l_status           fnd_product_installations.status%TYPE;
  --l_count            NUMBER;

  /*CURSOR c_product_check (cp_app_short_name IN VARCHAR2) IS
    SELECT inst.status
    FROM   fnd_product_installations inst, fnd_application app
    WHERE  inst.application_id = app.application_id
      AND  app.application_short_name = cp_app_short_name
      AND  inst.status <> 'N';*/

  BEGIN
    -- Checking whether the product is installed.
    /*OPEN c_product_check (cp_app_short_name => 'ENG');
    FETCH c_product_check INTO l_status;
    CLOSE c_product_check;
    IF (l_status = 'I') THEN
      -- package exists and DBI is installed
      -- check if a record exists in eng_change_mgmt_types_vl
      SELECT count(*)
      INTO  l_count
      FROM eng_change_mgmt_types_vl
      WHERE disable_flag = 'N';
      IF l_count <> 0 THEN
        l_product_exists := G_RET_STS_SUCCESS;
      END IF;
    END IF;
    RETURN (l_product_exists);
  EXCEPTION
    WHEN OTHERS THEN
      IF c_product_check%ISOPEN THEN
        CLOSE c_product_check;
      END IF;
      RETURN (l_product_exists);*/

  l_product_exists :=  EGO_COMMON_PVT.Is_EGO_Installed(1.0, '');
    IF (l_product_exists = 'T') THEN
      RETURN FND_API.G_RET_STS_SUCCESS;
    ELSE
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.G_RET_STS_ERROR;
  END Check_CM_Existance;

Procedure Implement_AML_Changes (
    p_api_version        IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2,
    p_commit             IN   VARCHAR2,
    p_change_id          IN   NUMBER,
    p_change_line_id     IN   NUMBER,
    x_return_status      OUT  NOCOPY VARCHAR2,
    x_msg_count          OUT  NOCOPY NUMBER,
    x_msg_data           OUT  NOCOPY VARCHAR2
  ) IS
  ----------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Implement_AML_Changes
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : Initialize the Item record with the values of the
  --             item_id (p_inventory_item_id) and Org Id (p_Organization_id)
  --
  -- Parameters:
  --     IN    : p_change_id        NUMBER
  --           : p_change_line_id   NUMBER
  --                one of the above parameters is mandatory
  --
  --
  --    OUT    : x_return_status    VARCHAR2
  --             x_msg_count        NUMBER
  --             x_msg_data         VARCHAR2
  --
  ----------------------------------------------------------------------------
  l_api_version    NUMBER := 1.0;
  l_api_name       VARCHAR2(30) := 'IMPLEMENT_AML_CHANGES';
  l_user_id        NUMBER;
  l_login_id       NUMBER;
  event_dml_Type   VARCHAR2(30) := ' ';

  l_pend_data_row  EGO_MFG_PART_NUM_CHGS%ROWTYPE;
  l_prod_data_row  MTL_MFG_PART_NUMBERS%ROWTYPE;

  TYPE NUM_TABLE_TYPE     IS TABLE OF mtl_mfg_part_numbers.manufacturer_id%TYPE;
  TYPE CHAR150_TABLE_TYPE IS TABLE OF mtl_mfg_part_numbers.mfg_part_num%TYPE;

  l_organization_id_tbl     NUM_TABLE_TYPE;
  l_manufacturer_id_tbl     NUM_TABLE_TYPE;
  l_mfg_part_num_tbl        CHAR150_TABLE_TYPE;
  l_inventory_item_id_tbl   NUM_TABLE_TYPE;
  l_change_line_id_tbl      NUM_TABLE_TYPE;
  l_acd_type_tbl            CHAR150_TABLE_TYPE;
  l_pending_row_count       NUMBER;

  l_sysdate        DATE;
  l_msg_data       VARCHAR2(4000);
  l_return_status  VARCHAR2(1);

  CURSOR c_get_pending_data (cp_mfg_id         IN NUMBER
                            ,cp_item_id        IN NUMBER
                            ,cp_org_id         IN NUMBER
                            ,cp_mfg_part_num   IN VARCHAR2
                            ,cp_change_line_id IN NUMBER
                            ,cp_acd_type       IN VARCHAR2) IS
    SELECT *
    FROM   ego_mfg_part_num_chgs
    WHERE  manufacturer_id   = cp_mfg_id
      AND  inventory_item_id = cp_item_id
      AND  organization_id   = cp_org_id
      AND  mfg_part_num      = cp_mfg_part_num
      AND  change_line_id    = cp_change_line_id
      AND  acd_type          = cp_acd_type;
--  work around for 3446060
--      FOR UPDATE NOWAIT;
--      FOR UPDATE OF implmentation_date, last_update_date, last_updated_by, last_update_login NOWAIT;

  CURSOR c_get_production_data (cp_inventory_item_id  IN  NUMBER
                               ,cp_organization_id    IN  NUMBER
                               ,cp_manufacturer_id    IN  NUMBER
                               ,cp_mfg_part_num       IN  VARCHAR2) IS
    SELECT *
    FROM   mtl_mfg_part_numbers
    WHERE  inventory_item_id = cp_inventory_item_id
      AND  organization_id = cp_organization_id
      AND  manufacturer_id = cp_manufacturer_id
      AND  mfg_part_num    = cp_mfg_part_num;

  BEGIN
    log_now (p_log_level  => FND_LOG.LEVEL_PROCEDURE
            ,p_module     => l_api_name
            ,p_message    => 'p_api_version:'||p_api_version||'-'||
                             'p_init_msg_list:'||p_init_msg_list||'-'||
                             'p_commit'||p_commit||'-'||
                             'p_change_id:'||p_change_id||'-'||
                             'p_change_line_id:'||p_change_line_id
             );

    -- standard check for API validation
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_change_id   IS NULL AND  p_change_line_id IS NULL) THEN
      fnd_message.set_name('EGO','EGO_MAND_PARAM_MISSING');
      fnd_message.set_token('PROGRAM', G_PKG_NAME || l_api_name);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_msg_pub.Count_And_Get
        (p_count        =>      x_msg_count
        ,p_data         =>      x_msg_data
        );
      RETURN;
    END IF;

    BEGIN
      SELECT ORGANIZATION_ID, MANUFACTURER_ID, MFG_PART_NUM,
             INVENTORY_ITEM_ID, CHANGE_LINE_ID, ACD_TYPE
      BULK COLLECT INTO
             l_organization_id_tbl, l_manufacturer_id_tbl,
             l_mfg_part_num_tbl,    l_inventory_item_id_tbl,
             l_change_line_id_tbl,  l_acd_type_tbl
      FROM   ego_mfg_part_num_chgs
      WHERE  NVL(change_id,-1) = NVL(NVL(p_change_id, change_id),-1)
        AND  NVL(change_line_id, -1) =
                   NVL(NVL(p_change_line_id, change_line_id),-1)
        AND  implmentation_date  IS NULL
        AND  acd_type IN
                (G_ADD_ACD_TYPE, G_CHANGE_ACD_TYPE, G_DELETE_ACD_TYPE);
      l_pending_row_count := SQL%ROWCOUNT;
      log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
              ,p_module     => l_api_name
              ,p_message    => ' no of rows to process '||l_pending_row_count);
    EXCEPTION
      WHEN  NO_DATA_FOUND THEN
        log_now (p_log_level  => FND_LOG.LEVEL_PROCEDURE
                ,p_module     => l_api_name
                ,p_message    => ' no rows to process - returning ');
        RETURN;
    END;

    l_user_id  := FND_GLOBAL.User_Id;
    l_login_id := FND_GLOBAL.Conc_Login_Id;
    l_sysdate := SYSDATE;

    -- create save point
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT IMPLEMENT_AML_CHANGES;
    END IF;

    -- Initialize message list
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    FOR l_pend_index IN 1..l_pending_row_count LOOP
      log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
              ,p_module     => l_api_name
              ,p_message    => ' started changes for item id:'||l_inventory_item_id_tbl(l_pend_index)||'-'
                             ||' org id:'||l_organization_id_tbl(l_pend_index)||'-'
                             ||' mfg id:'||l_manufacturer_id_tbl(l_pend_index)||'-'
                             ||' mfg part num:'||l_mfg_part_num_tbl(l_pend_index)||'-'
                             ||' ACD type:'||l_acd_type_tbl(l_pend_index)
             );
      IF l_acd_type_tbl(l_pend_index) IN (G_CHANGE_ACD_TYPE, G_DELETE_ACD_TYPE) THEN
        OPEN c_get_production_data
                (cp_inventory_item_id  => l_inventory_item_id_tbl(l_pend_index)
                ,cp_organization_id    => l_organization_id_tbl(l_pend_index)
                ,cp_manufacturer_id    => l_manufacturer_id_tbl(l_pend_index)
                ,cp_mfg_part_num       => l_mfg_part_num_tbl(l_pend_index));
        FETCH c_get_production_data INTO l_prod_data_row;
        IF c_get_production_data%FOUND THEN
          -- create a history record in ego_mfg_part_num_changes
          INSERT INTO ego_mfg_part_num_chgs
            (manufacturer_id
            ,mfg_part_num
            ,inventory_item_id
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,organization_id
            ,mrp_planning_code
            ,description
            ,first_article_status
            ,approval_status
            ,change_id
            ,change_line_id
            ,acd_type
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,implmentation_date
            ,start_date
            ,end_date)
          VALUES
            (l_prod_data_row.manufacturer_id
            ,l_prod_data_row.mfg_part_num
            ,l_prod_data_row.inventory_item_id
            ,l_sysdate
            ,l_user_id
            ,l_sysdate
            ,l_user_id
            ,l_login_id
            ,l_prod_data_row.organization_id
            ,l_prod_data_row.mrp_planning_code
            ,l_prod_data_row.description
            ,l_prod_data_row.first_article_status
            ,l_prod_data_row.approval_status
            ,p_change_id
            ,p_change_line_id
            ,G_HISTORY_ACD_TYPE
            ,l_prod_data_row.attribute_category
            ,l_prod_data_row.attribute1
            ,l_prod_data_row.attribute2
            ,l_prod_data_row.attribute3
            ,l_prod_data_row.attribute4
            ,l_prod_data_row.attribute5
            ,l_prod_data_row.attribute6
            ,l_prod_data_row.attribute7
            ,l_prod_data_row.attribute8
            ,l_prod_data_row.attribute9
            ,l_prod_data_row.attribute10
            ,l_prod_data_row.attribute11
            ,l_prod_data_row.attribute12
            ,l_prod_data_row.attribute13
            ,l_prod_data_row.attribute14
            ,l_prod_data_row.attribute15
            ,NULL
            ,l_prod_data_row.start_date
            ,l_prod_data_row.end_date);
          log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                  ,p_module     => l_api_name
                  ,p_message    => 'successfully created a history record in ego_mfg_part_num_chgs'
                  );
          IF l_acd_type_tbl(l_pend_index) = G_CHANGE_ACD_TYPE THEN
            -- copy the pending row into production (basically update)
            OPEN c_get_pending_data
                (cp_mfg_id         => l_manufacturer_id_tbl(l_pend_index)
                ,cp_item_id        => l_inventory_item_id_tbl(l_pend_index)
                ,cp_org_id         => l_organization_id_tbl(l_pend_index)
                ,cp_mfg_part_num   => l_mfg_part_num_tbl(l_pend_index)
                ,cp_change_line_id => l_change_line_id_tbl(l_pend_index)
                ,cp_acd_type       => l_acd_type_tbl(l_pend_index)
                );
            FETCH c_get_pending_data INTO  l_pend_data_row;
            CLOSE c_get_pending_data;
            UPDATE mtl_mfg_part_numbers
              SET first_article_status  = l_pend_data_row.first_article_status
                  ,approval_status      = l_pend_data_row.approval_status
                  ,start_date           = l_pend_data_row.start_date
                  ,end_date             = l_pend_data_row.end_date
		,attribute1           = l_pend_data_row.attribute1 --Added attribute 1 - 15 for bug 6109336
		,attribute2          = l_pend_data_row.attribute2
		,attribute3          = l_pend_data_row.attribute3
		,attribute4          = l_pend_data_row.attribute4
		,attribute5          = l_pend_data_row.attribute5
		,attribute6          = l_pend_data_row.attribute6
		,attribute7          = l_pend_data_row.attribute7
		,attribute8          =  l_pend_data_row.attribute8
		,attribute9          = l_pend_data_row.attribute9
		,attribute10         = l_pend_data_row.attribute10
		,attribute11         = l_pend_data_row.attribute11
		,attribute12         = l_pend_data_row.attribute12
		,attribute13         =  l_pend_data_row.attribute13
		,attribute14         = l_pend_data_row.attribute14
		,attribute15         = l_pend_data_row.attribute15
                  ,last_update_date     = l_sysdate
                  ,last_updated_by      = l_user_id
                  ,last_update_login    = l_login_id
            WHERE manufacturer_id   = l_manufacturer_id_tbl(l_pend_index)
              AND inventory_item_id = l_inventory_item_id_tbl(l_pend_index)
              AND organization_id   = l_organization_id_tbl(l_pend_index)
              AND mfg_part_num      = l_mfg_part_num_tbl(l_pend_index);
            log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                    ,p_module     => l_api_name
                    ,p_message    => 'successfully updated production row'
                     );
            event_dml_Type := 'UPDATE';
          ELSIF l_acd_type_tbl(l_pend_index) = G_DELETE_ACD_TYPE THEN
            -- delete the record from mtl_mfg_part_numbers
            DELETE mtl_mfg_part_numbers
            WHERE manufacturer_id   = l_manufacturer_id_tbl(l_pend_index)
              AND inventory_item_id = l_inventory_item_id_tbl(l_pend_index)
              AND organization_id   = l_organization_id_tbl(l_pend_index)
              AND mfg_part_num      = l_mfg_part_num_tbl(l_pend_index);
            log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                    ,p_module     => l_api_name
                    ,p_message    => 'successfully deleted production row'
                     );
            event_dml_Type := 'DELETE';
          END IF;

          UPDATE ego_mfg_part_num_chgs
            SET implmentation_date = l_sysdate
               ,last_update_date    = l_sysdate
               ,last_updated_by     = l_user_id
               ,last_update_login   = l_login_id
          WHERE manufacturer_id   = l_manufacturer_id_tbl(l_pend_index)
            AND inventory_item_id = l_inventory_item_id_tbl(l_pend_index)
            AND organization_id   = l_organization_id_tbl(l_pend_index)
            AND mfg_part_num      = l_mfg_part_num_tbl(l_pend_index)
            AND change_line_id    = l_change_line_id_tbl(l_pend_index)
            AND acd_type          = l_acd_type_tbl(l_pend_index);
            log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                    ,p_module     => l_api_name
                    ,p_message    => 'successfully updated pending row as implemented'
                     );
        END IF;
        CLOSE c_get_production_data;

      ELSIF l_acd_type_tbl(l_pend_index) = G_ADD_ACD_TYPE THEN
        OPEN c_get_pending_data
            (cp_mfg_id         => l_manufacturer_id_tbl(l_pend_index)
            ,cp_item_id        => l_inventory_item_id_tbl(l_pend_index)
            ,cp_org_id         => l_organization_id_tbl(l_pend_index)
            ,cp_mfg_part_num   => l_mfg_part_num_tbl(l_pend_index)
            ,cp_change_line_id => l_change_line_id_tbl(l_pend_index)
            ,cp_acd_type       => l_acd_type_tbl(l_pend_index)
            );
        FETCH c_get_pending_data INTO  l_pend_data_row;
        CLOSE c_get_pending_data;
        -- insert a new record into production table
        INSERT INTO  mtl_mfg_part_numbers
          (manufacturer_id
          ,mfg_part_num
          ,inventory_item_id
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,organization_id
          ,mrp_planning_code
          ,description
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,first_article_status
          ,approval_status
          ,start_date
          ,end_date)
        VALUES
          (l_pend_data_row.manufacturer_id
          ,l_pend_data_row.mfg_part_num
          ,l_pend_data_row.inventory_item_id
          ,l_sysdate
          ,l_user_id
          ,l_sysdate
          ,l_user_id
          ,l_login_id
          ,l_pend_data_row.organization_id
          ,l_pend_data_row.mrp_planning_code
          ,l_pend_data_row.description
          ,l_pend_data_row.attribute_category
          ,l_pend_data_row.attribute1
          ,l_pend_data_row.attribute2
          ,l_pend_data_row.attribute3
          ,l_pend_data_row.attribute4
          ,l_pend_data_row.attribute5
          ,l_pend_data_row.attribute6
          ,l_pend_data_row.attribute7
          ,l_pend_data_row.attribute8
          ,l_pend_data_row.attribute9
          ,l_pend_data_row.attribute10
          ,l_pend_data_row.attribute11
          ,l_pend_data_row.attribute12
          ,l_pend_data_row.attribute13
          ,l_pend_data_row.attribute14
          ,l_pend_data_row.attribute15
          ,l_pend_data_row.first_article_status
          ,l_pend_data_row.approval_status
          ,l_pend_data_row.start_date
          ,l_pend_data_row.end_date);
          log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                  ,p_module     => l_api_name
                  ,p_message    => 'successfully created a record in production table'
                   );

         event_dml_Type := 'CREATE';
        -- update the pending row as implemented
        UPDATE ego_mfg_part_num_chgs
          SET implmentation_date = l_sysdate
             ,last_update_date   = l_sysdate
             ,last_updated_by    = l_user_id
             ,last_update_login  = l_login_id
        WHERE manufacturer_id   = l_manufacturer_id_tbl(l_pend_index)
          AND inventory_item_id = l_inventory_item_id_tbl(l_pend_index)
          AND organization_id   = l_organization_id_tbl(l_pend_index)
          AND mfg_part_num      = l_mfg_part_num_tbl(l_pend_index)
          AND change_line_id    = l_change_line_id_tbl(l_pend_index)
          AND acd_type          = l_acd_type_tbl(l_pend_index);
          log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                  ,p_module     => l_api_name
                  ,p_message    => 'successfully updated pending row as implemented'
                   );
      END IF;  -- acd_type

      --Start 4105841 : Business Event Enhancement
      IF event_dml_type IN( 'CREATE', 'DELETE', 'UPDATE') THEN
        log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                ,p_module     => l_api_name
                ,p_message    => ' calling Business Event '
                 );
        EGO_WF_WRAPPER_PVT.Raise_AML_Event
                (p_event_name        => EGO_WF_WRAPPER_PVT.G_AML_CHANGE_EVENT
                ,p_dml_type          => event_dml_type
                ,p_Inventory_Item_Id => l_inventory_item_id_tbl(l_pend_index)
                ,p_Organization_Id   => l_organization_id_tbl(l_pend_index)
                ,p_Manufacturer_Id   => l_manufacturer_id_tbl(l_pend_index)
                ,p_Mfg_Part_Num      => l_mfg_part_num_tbl(l_pend_index)
                ,x_msg_data          => l_msg_data
                ,x_return_status     => l_return_status
                );
        log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                ,p_module     => l_api_name
                ,p_message    => ' calling Business Event done'
                 );
        event_dml_type := ' ';
      END IF;
      --End 4105841 : Business Event Enhancement
      log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
              ,p_module     => l_api_name
              ,p_message    => ' completed changes for item id:'||l_inventory_item_id_tbl(l_pend_index)||'-'
                             ||' org id:'||l_organization_id_tbl(l_pend_index)||'-'
                             ||' mfg id:'||l_manufacturer_id_tbl(l_pend_index)||'-'
                             ||' mfg part num:'||l_mfg_part_num_tbl(l_pend_index)||'-'
                             ||' ACD type:'||l_acd_type_tbl(l_pend_index)
               );
    END LOOP;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
      --calling the Sync Index only if the work is committed.
      --if needed else where before commit or if the commit is
      --called else where before this commit pls call the same method.
      log_now (p_log_level  => FND_LOG.LEVEL_PROCEDURE
              ,p_module     => l_api_name
              ,p_message    => ' calling EGO_ITEM_TEXT_UTIL.Sync_Index '
               );
      EGO_ITEM_TEXT_UTIL.Sync_Index();
      log_now (p_log_level  => FND_LOG.LEVEL_PROCEDURE
              ,p_module     => l_api_name
              ,p_message    => ' returning from EGO_ITEM_TEXT_UTIL.Sync_Index '
             );
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
    log_now (p_log_level  => FND_LOG.LEVEL_PROCEDURE
            ,p_module     => l_api_name
            ,p_message    => ' returning with status '||x_return_status
             );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO IMPLEMENT_AML_CHANGES;
      END IF;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      log_now (p_log_level  => FND_LOG.LEVEL_EXCEPTION
              ,p_module     => l_api_name
              ,p_message    => 'Expected Error as Exception '||x_msg_count ||'-'|| x_msg_data
               );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO IMPLEMENT_AML_CHANGES;
      END IF;
      x_RETURN_STATUS := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      log_now (p_log_level  => FND_LOG.LEVEL_EXCEPTION
              ,p_module     => l_api_name
              ,p_message    => 'Unexpected Error as Exception '||x_msg_count ||'-'|| x_msg_data
               );
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO IMPLEMENT_AML_CHANGES;
      END IF;
      IF c_get_pending_data%ISOPEN THEN
        CLOSE c_get_pending_data;
      END IF;
      IF c_get_production_data%ISOPEN THEN
        CLOSE c_get_production_data;
      END IF;
      log_now (p_log_level  => FND_LOG.LEVEL_EXCEPTION
              ,p_module     => l_api_name
              ,p_message    => 'Exception '||SQLERRM
               );
      x_return_status := G_RET_STS_UNEXP_ERROR;
      -- for PL/SQL errors
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
  END Implement_AML_Changes;

Procedure Delete_AML_Pending_Changes
  (p_api_version          IN  NUMBER
  ,p_init_msg_list        IN  VARCHAR2
  ,p_commit               IN  VARCHAR2
  ,p_inventory_item_id    IN  NUMBER
  ,p_organization_id      IN  NUMBER
  ,p_manufacturer_id      IN  NUMBER
  ,p_mfg_part_num         IN  VARCHAR2
  ,p_change_id            IN  NUMBER
  ,p_change_line_id       IN  NUMBER
  ,p_acd_type             IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_msg_count           OUT  NOCOPY VARCHAR2
  ,x_msg_data            OUT  NOCOPY VARCHAR2
  ) IS
  ----------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Delete_AML_Pending_Changes
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : Delete the pending changes from EGO_MFG_PART_NUM_CHGS
  --
  -- Parameters:
  --     IN    : p_inventory_item_id  NUMBER
  --           : p_organization_id    NUMBER
  --           : p_manufacturer_id    NUMBER
  --           : p_mfg_part_num       VARCHAR2
  --           : p_change_id          NUMBER
  --           : p_change_line_id     NUMBER
  --           : p_acd_type           VARCHAR2
  --
  --    OUT    : x_return_status    VARCHAR2
  --             x_msg_count        NUMBER
  --             x_msg_data         VARCHAR2
  --
  ----------------------------------------------------------------------------
  l_api_version    NUMBER := 1.0;
  l_api_name       VARCHAR2(50) := 'DELETE_AML_PENDING_CHANGES';

  BEGIN

    -- standard check for API validation
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF   p_change_id IS NULL
       AND
         p_change_line_id IS NULL THEN
      -- what are you planning to delete?
      RETURN;
    END IF;

    -- Initialize message list
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT DELETE_AML_PENDING_CHANGES;
    END IF;

    IF   p_inventory_item_id IS NULL
       AND
         p_organization_id IS NULL THEN
        --
        -- bug 3648353
        -- delete all unimplemented changes in the context of change order
        --
        DELETE EGO_MFG_PART_NUM_CHGS
        WHERE change_id = NVL(p_change_id, change_id)
          AND change_line_id = NVL(p_change_line_id, change_line_id)
          AND implmentation_date IS NULL;
    ELSE
      --
      -- deleting an individual line (all parameters are passed here)
      --
      DELETE EGO_MFG_PART_NUM_CHGS
      WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND manufacturer_id = p_manufacturer_id
        AND mfg_part_num = p_mfg_part_num
        AND change_id = p_change_id
        AND change_line_id = p_change_line_id
-- fix for 3439187
--      AND acd_type = p_acd_type
        AND implmentation_date IS NULL;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_RETURN_STATUS := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      log_now (p_log_level  => FND_LOG.LEVEL_EXCEPTION
              ,p_module     => l_api_name
              ,p_message    => 'Exception '||SQLERRM
               );
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO DELETE_AML_PENDING_CHANGES;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      -- for PL/SQL errors
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Delete_AML_Pending_Changes;


Procedure Check_AML_Policy_Allowed
  (p_api_version          IN  NUMBER
  ,p_inventory_item_id    IN  NUMBER
  ,p_organization_id      IN  NUMBER
  ,p_catalog_category_id  IN  NUMBER
  ,p_lifecycle_id         IN  NUMBER
  ,p_lifecycle_phase_id   IN  NUMBER
  ,p_allowable_policy     IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_policy_name         OUT  NOCOPY VARCHAR2
  ,x_item_number         OUT  NOCOPY VARCHAR2
  ,x_org_name            OUT  NOCOPY VARCHAR2
  ) IS
  ----------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Check_AML_Policy_Allowed
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- Function  : To check whether the AML Changes are allowed
  --               on the given item in the reqd organization
  --               returns the status in x_return_status
  --
  -- Parameters:
  --     IN    : p_api_version        NUMBER
  --           : p_inventory_item_id  NUMBER
  --           : p_organization_id    NUMBER
  --
  -- Return Parameter:
  --      x_return_status
  --           : 'Y' if Policy is allowed
  --           : 'N' if all other cases
  --      x_policy_name, x_item_number, x_org_name
  --           : contains the strings for message
  --
  ----------------------------------------------------------------------------

  l_api_name             CONSTANT  VARCHAR2(50) := 'CHECK_AML_POLICY_ALLOWED';
  l_policy_object_name   CONSTANT  VARCHAR2(30) := 'CATALOG_LIFECYCLE_PHASE';
  l_policy_code          CONSTANT  VARCHAR2(30) := 'CHANGE_POLICY';
  l_attr_object_name     CONSTANT  VARCHAR2(30) := 'EGO_CATALOG_GROUP';
  l_attr_code            CONSTANT  VARCHAR2(30) := 'AML_RULE';
  l_acceptable_policy    CONSTANT  VARCHAR2(30) := 'ALLOWED';

  l_api_version          NUMBER := 1.0;
  l_lc_catalog_cat_id    NUMBER;
  l_catalog_category_id  NUMBER;
  l_lifecycle_id         NUMBER;
  l_current_phase_id     NUMBER;

  l_dynamic_sql      VARCHAR2(32767);
  l_return_status    VARCHAR2(1);
  l_temp_status      VARCHAR2(1);
  l_policy_value     VARCHAR2(100);
  l_approval_status  VARCHAR2(1);

  CURSOR c_product_check (cp_app_short_name IN VARCHAR2) IS
    SELECT inst.status
    FROM   fnd_product_installations inst, fnd_application app
    WHERE  inst.application_id = app.application_id
      AND  app.application_short_name = cp_app_short_name
      AND  inst.status <> 'N';

  CURSOR c_get_lc_catalog_cat_id (cp_catalog_category_id  IN NUMBER
                                 ,cp_lifecycle_id         IN NUMBER) IS
--
-- this code does not return the first catalog category id in the hierarchy
--
--  SELECT olc.object_classification_code
--    FROM ego_obj_type_lifecycles olc, fnd_objects o
--   WHERE o.obj_name =  G_EGO_ITEM
--     AND olc.object_id = o.object_id
--     AND olc.lifecycle_id = cp_lifecycle_id
--     AND olc.object_classification_code IN
--             (SELECT TO_CHAR(ic.catalog_group_id)
--                FROM ego_catalog_groups_v ic
--              CONNECT BY PRIOR parent_catalog_group_id =  catalog_group_id
--                START WITH catalog_group_id = cp_catalog_category_id
--             );
--
  -- fix for bug 3681654
  -- using mtl_item_catalog_groups_b instead of ego_catalog_groups_v
  SELECT ic.item_catalog_group_id
    FROM mtl_item_catalog_groups_b ic
   WHERE EXISTS
          (
            SELECT olc.object_classification_code CatalogId
              FROM  ego_obj_type_lifecycles olc, fnd_objects o
             WHERE o.obj_name =  G_EGO_ITEM
               AND olc.object_id = o.object_id
               AND olc.lifecycle_id = cp_lifecycle_id
               AND olc.object_classification_code = to_char(ic.item_catalog_group_id)
          )
    CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
    START WITH item_catalog_group_id = cp_catalog_category_id;

  BEGIN
    x_return_status  := G_EGO_SHORT_NO;
    -- standard check for API validation
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
      RETURN;
    END IF;

    IF p_inventory_item_id IS NULL  THEN
      -- expecting catalog category_id, lifecycle_id and lifecycle_phase_id
      IF (p_catalog_category_id IS NULL
          OR
          p_lifecycle_id        IS NULL
          OR
          p_lifecycle_phase_id  IS NULL
         ) THEN
        x_return_status := G_EGO_SHORT_YES;
        RETURN;
      END IF;
    ELSE
      IF  p_organization_id IS NULL THEN
        RETURN;
      END IF;
    END IF;

    -- Checking whether EGO product is installed.
    OPEN c_product_check (cp_app_short_name => 'EGO');
    FETCH c_product_check INTO l_temp_status;
    CLOSE c_product_check;
    IF (l_temp_status <> 'I') THEN
      -- EGO does not exist
      x_return_status := G_EGO_SHORT_YES;
      RETURN;
    END IF;

    -- Checking whether ENG product is installed.
    IF (Check_CM_Existance() <> G_RET_STS_SUCCESS) THEN
      -- ENG does not exist
      x_return_status := G_EGO_SHORT_YES;
      RETURN;
    END IF;

    IF p_inventory_item_id IS NULL THEN
      l_catalog_category_id := p_catalog_category_id;
      l_lifecycle_id := p_lifecycle_id;
      l_current_phase_id := p_lifecycle_phase_id;
    ELSE
      -- check for policy control
      l_dynamic_sql :=
        ' SELECT item_catalog_group_id, lifecycle_id, current_phase_id,approval_status' ||
        ' FROM   mtl_system_items_b                                   ' ||
        ' WHERE  inventory_item_id =  :1' ||
        '   AND  organization_id   =  :2';
      EXECUTE IMMEDIATE l_dynamic_sql
        INTO l_catalog_category_id, l_lifecycle_id, l_current_phase_id,l_approval_status USING p_inventory_item_id,p_organization_id;
    END IF;
    -- check if the values are present.
    IF (l_catalog_category_id IS NULL
        OR l_lifecycle_id IS NULL
        OR l_current_phase_id IS NULL
  OR (l_approval_status IS NOT NULL
      AND l_approval_status <> 'A' )
       ) THEN
      x_return_status := G_EGO_SHORT_YES;
      RETURN;
    END IF;

    -- get the catalog_group id from which the life cycle is associated
    OPEN c_get_lc_catalog_cat_id
         (cp_catalog_category_id => l_catalog_category_id
         ,cp_lifecycle_id        => l_lifecycle_id
         );
    FETCH c_get_lc_catalog_cat_id INTO l_lc_catalog_cat_id;
    CLOSE c_get_lc_catalog_cat_id;

    l_dynamic_sql :=
      ' BEGIN                                                               '||
      '    ENG_CHANGE_POLICY_PKG.GetChangePolicy                            '||
      '    (                                                                '||
      '      p_policy_object_name      =>  :l_policy_object_name            '||
      '   ,  p_policy_code             =>  :l_policy_code                   '||
      '   ,  p_policy_pk1_value        =>  TO_CHAR(:l_lc_catalog_cat_id)    '||
      '   ,  p_policy_pk2_value        =>  TO_CHAR(:l_lifecycle_id)         '||
      '   ,  p_policy_pk3_value        =>  TO_CHAR(:l_current_phase_id)     '||
      '   ,  p_policy_pk4_value        =>  NULL                             '||
      '   ,  p_policy_pk5_value        =>  NULL                             '||
      '   ,  p_attribute_object_name   =>  :l_attr_object_name              '||
      '   ,  p_attribute_code          =>  :l_attr_code                     '||
      '   ,  p_attribute_value         =>  1                                '||
      '   ,  x_policy_value            =>  :l_policy_value                  '||
      '   );                                                                '||
      ' END;';
    EXECUTE IMMEDIATE l_dynamic_sql
    USING IN l_policy_object_name,
          IN l_policy_code,
          IN l_lc_catalog_cat_id,
          IN l_lifecycle_id,
          IN l_current_phase_id,
          IN l_attr_object_name,
          IN l_attr_code,
         OUT l_policy_value;

    IF (NVL(l_policy_value, l_acceptable_policy)
          IN (l_acceptable_policy
             ,p_allowable_policy
             )
       ) THEN
      x_return_status := G_EGO_SHORT_YES;
    ELSE
      -- the policy does not allow, put the message
      BEGIN
        -- get policy name
        SELECT name
        INTO x_policy_name
        FROM pa_ego_phases_v
        WHERE proj_element_id = l_current_phase_id;
        IF p_inventory_item_id IS NOT NULL THEN
          -- get concatenated segments
          SELECT concatenated_segments
          INTO x_item_number
          FROM mtl_system_items_kfv
          WHERE inventory_item_id = p_inventory_item_id
            AND organization_id = p_organization_id;
        END IF;
        IF p_organization_id IS NOT NULL THEN
          -- get organiation name
          SELECT organization_name
          INTO  x_org_name
          FROM  org_organization_definitions
          WHERE organization_id = p_organization_id;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          x_policy_name := NULL;
          x_item_number := NULL;
          x_org_name := NULL;
      END;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_product_check%ISOPEN THEN
        CLOSE c_product_check;
      END IF;
      IF c_get_lc_catalog_cat_id%ISOPEN THEN
        CLOSE c_get_lc_catalog_cat_id;
      END IF;
      x_return_status := G_EGO_SHORT_NO;
  END Check_AML_Policy_Allowed;


Function Check_No_AML_Priv
  (p_api_version          IN  NUMBER
  ,p_inventory_item_id    IN  NUMBER
  ,p_organization_id      IN  NUMBER
  ,p_privilege_name       IN  VARCHAR2
  ,p_party_id             IN  NUMBER  DEFAULT NULL
  ,p_user_id              IN  NUMBER  DEFAULT NULL
  ) RETURN VARCHAR2 IS
  ----------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Check_No_AML_Priv
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : To check whether the user has the specified privilege
  --              on the given item in the reqd organization
  --              Returns 'Y' if the item can be edited
  --              Returns 'N' in all other cases
  --
  -- Parameters:
  --     IN    : p_api_version        NUMBER
  --           : p_inventory_item_id  NUMBER
  --           : p_organization_id    NUMBER
  --           : p_privilege_name     VARCHAR2
  --           : p_party_id           NUMBER
  --           : p_user_id            NUMBER
  --
  -- Return Parameter:
  --           : 'Y' if the user has required privilege
  --           : 'N' if the user does not have required privilege
  --
  ----------------------------------------------------------------------------

  l_api_version      NUMBER := 1.0;
  l_api_name         VARCHAR2(50) := 'CHECK_NO_AML_PRIV';
  l_dynamic_sql      VARCHAR2(32767);
  l_return_status    VARCHAR2(1);
  l_temp_status      VARCHAR2(1);
  l_policy_value     VARCHAR2(100);

  l_party_key_prefix         CONSTANT  VARCHAR2(30) := 'HZ_PARTY:';

  l_aml_view_priv            CONSTANT  VARCHAR2(30) := 'EGO_VIEW_ITEM_AML';
  l_aml_edit_priv            CONSTANT  VARCHAR2(30) := 'EGO_EDIT_ITEM_AML';
  l_relitem_view_priv        CONSTANT  VARCHAR2(30) := 'EGO_VIEW_RELATED_ITEMS';
  l_relitem_edit_priv        CONSTANT  VARCHAR2(30) := 'EGO_EDIT_RELATED_ITEMS';
  l_custitem_xref_view_priv  CONSTANT  VARCHAR2(30) := 'EGO_VIEW_CUST_ITEM_XREFS';  -- Added for 3577973
  l_custitem_xref_edit_priv  CONSTANT  VARCHAR2(30) := 'EGO_EDIT_CUST_ITEM_XREFS';  -- Added for 3577973
  l_item_view_priv  CONSTANT  VARCHAR2(30) := 'EGO_VIEW_ITEM';  -- Added for 3577973
  l_item_edit_priv  CONSTANT  VARCHAR2(30) := 'EGO_EDIT_ITEM';  -- Added for 3577973

  l_item_xref_view_priv      CONSTANT  VARCHAR2(30) := 'EGO_VIEW_ITEM_XREFS';  -- Added for R12
  l_item_xref_edit_priv      CONSTANT  VARCHAR2(30) := 'EGO_EDIT_ITEM_XREFS';  -- Added for R12
  l_ss_item_xref_view_priv   CONSTANT  VARCHAR2(30) := 'EGO_VIEW_SS_ITEM_XREFS';  -- Added for R12
  l_ss_item_xref_edit_priv   CONSTANT  VARCHAR2(30) := 'EGO_EDIT_SS_ITEM_XREFS';  -- Added for R12

  l_party_id             NUMBER;
  l_user_id              NUMBER;
  l_party_key            VARCHAR2(50);
  l_dummy_msg            VARCHAR2(2000);
  l_null                 VARCHAR2(1) := NULL;

  CURSOR c_product_check (cp_app_short_name IN VARCHAR2) IS
    SELECT inst.status
    FROM   fnd_product_installations inst, fnd_application app
    WHERE  inst.application_id = app.application_id
      AND  app.application_short_name = cp_app_short_name
      AND  inst.status <> 'N';

  BEGIN
    l_return_status  := G_EGO_SHORT_YES;
    -- standard check for API validation
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
      RETURN l_return_status;
    END IF;
      log_now (p_log_level  => FND_LOG.LEVEL_PROCEDURE
              ,p_module     => l_api_name
              ,p_message    => 'p_inventory_item_id '||to_char(p_inventory_item_id)
                             ||' - p_org_id '||to_char(p_organization_id)
                             ||' - p_priv_name '||  p_privilege_name
                             ||' - p_party_id '||p_party_id
                             ||' - p_user_id  '||p_user_id
               );

    IF (p_inventory_item_id IS NULL OR
        p_organization_id IS NULL OR
        p_privilege_name IS NULL  OR
        (
          p_privilege_name IS NOT NULL  AND
          p_privilege_name NOT IN
            (l_aml_view_priv
            ,l_aml_edit_priv
            ,l_relitem_view_priv
            ,l_relitem_edit_priv
            ,l_custitem_xref_view_priv
            ,l_custitem_xref_edit_priv
            ,l_item_view_priv
            ,l_item_edit_priv
            ,l_item_xref_view_priv
            ,l_item_xref_edit_priv
            ,l_ss_item_xref_view_priv
            ,l_ss_item_xref_edit_priv
            )
        )
       ) THEN
      log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
              ,p_module     => l_api_name
              ,p_message    => ' returning status :'||l_return_status||': for invalid params '
               );
      RETURN l_return_status;
    END IF;

    log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
            ,p_module     => l_api_name
            ,p_message    => ' params are valid '
             );
    -- Checking whether EGO product is installed.
    OPEN c_product_check (cp_app_short_name => 'EGO');
    FETCH c_product_check INTO l_temp_status;
    CLOSE c_product_check;
    IF (l_temp_status <> 'I') THEN
      -- EGO does not exist
      log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
              ,p_module     => l_api_name
              ,p_message    => ' returning status :'||G_EGO_SHORT_NO||': for product not existing '
               );
      RETURN G_EGO_SHORT_NO;
    END IF;

    log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
            ,p_module     => l_api_name
            ,p_message    => ' EGO is installed '
             );
    l_party_id := p_party_id;
    IF l_party_id IS NULL THEN
      l_user_id  := NVL(p_user_id, FND_GLOBAL.User_Id);
      IF l_user_id = -1 THEN
        -- bug 3600938 if user_id is returned as -1, query from user_name
        l_dynamic_sql := 'SELECT PARTY_ID FROM EGO_USER_V where user_name = :1';
        EXECUTE IMMEDIATE l_dynamic_sql INTO l_party_id USING FND_GLOBAL.USER_NAME;
      ELSE
        l_dynamic_sql := 'SELECT PARTY_ID FROM EGO_USER_V where user_id = :1';
        EXECUTE IMMEDIATE l_dynamic_sql INTO l_party_id USING IN l_user_id;
      END IF;
--      EXECUTE IMMEDIATE l_dynamic_sql INTO l_party_id;
    END IF;
    l_party_key := l_party_key_prefix||l_party_id;
    l_dynamic_sql := 'SELECT  EGO_DATA_SECURITY.CHECK_FUNCTION ('
            ||':1, '--l_api_version
            ||':2, '--p_privilege_name
            ||':3, '--G_EGO_ITEM
            ||':4, '--p_inventory_item_id
            ||':5, '--p_organization_id
            ||':6, '-- pk3 value NULL
            ||':7, '-- pk4 value NULL
            ||':8, '-- pk5 value NULL
            ||':9 )'--l_party_key
            ||' FROM DUAL';
    EXECUTE IMMEDIATE l_dynamic_sql INTO l_temp_status
    USING IN l_api_version,
          IN p_privilege_name,
          IN G_EGO_ITEM,
          IN p_inventory_item_id,
          IN p_organization_id,
          IN l_null,
          IN l_null,
          IN l_null,
          IN l_party_key;
    log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
            ,p_module     => l_api_name
            ,p_message    => ' return value from data security check :'||l_temp_status
             );
    IF l_temp_status = 'T' THEN
      -- fix for 3439190
      IF p_privilege_name IN
            (l_aml_view_priv
            ,l_relitem_view_priv
            ,l_relitem_edit_priv
            ,l_custitem_xref_view_priv
            ,l_custitem_xref_edit_priv
            ,l_item_view_priv
            ,l_item_edit_priv
            ,l_item_xref_view_priv
            ,l_item_xref_edit_priv
            ,l_ss_item_xref_view_priv
            ,l_ss_item_xref_edit_priv
            ) THEN
        log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                ,p_module     => l_api_name
                ,p_message    => ' returrning status without policy check :'||G_EGO_SHORT_NO
                 );
        RETURN G_EGO_SHORT_NO;
      END IF;
      -- p_privilege_name = l_aml_edit_priv
      Check_AML_Policy_Allowed (p_api_version       => 1.0
                               ,p_inventory_item_id => p_inventory_item_id
                               ,p_organization_id   => p_organization_id
                               ,p_catalog_category_id  => NULL
                               ,p_lifecycle_id         => NULL
                               ,p_lifecycle_phase_id   => NULL
                               ,p_allowable_policy     => 'ALLOWED'
                               ,x_return_status     => l_temp_status
                               ,x_policy_name       => l_dummy_msg
                               ,x_item_number       => l_dummy_msg
                               ,x_org_name          => l_dummy_msg
                               );
        log_now (p_log_level  => FND_LOG.LEVEL_STATEMENT
                ,p_module     => l_api_name
                ,p_message    => ' return status from policy check :'||l_temp_status
                 );
      IF (l_temp_status = G_EGO_SHORT_YES) THEN
        --
        -- The policy control allows the change
        -- So, Check_No_AML_Privilege should return NO
        --
        RETURN G_EGO_SHORT_NO;
      ELSE
        RETURN l_return_status;
      END IF;
    END IF;
    return l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      log_now (p_log_level  => FND_LOG.LEVEL_EXCEPTION
              ,p_module     => l_api_name
              ,p_message    => 'Exception '||SQLERRM
               );
      IF c_product_check%ISOPEN THEN
        CLOSE c_product_check;
      END IF;
      RETURN l_return_status;
  END Check_No_AML_Priv;

PROCEDURE Check_No_MFG_Associations
  (p_api_version          IN  NUMBER
  ,p_manufacturer_id      IN  NUMBER
  ,p_manufacturer_name    IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_message_name        OUT  NOCOPY VARCHAR2
  ,x_message_text        OUT  NOCOPY VARCHAR2
  ) IS
  ----------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Check_No_MFG_Associations
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : To check if any associations exist on the manufacturer
  --              Returns 'Y' if no associations exist
  --              Returns 'N' in all other cases
  --
  -- Parameters:
  --     IN    : p_api_version        NUMBER
  --           : p_application_name   VARCHAR2
  --           : p_manufacturer_id    NUMBER
  --
  -- Return Parameter:
  --      x_return_status
  --           : 'Y' if no associations exist
  --           : 'N' if associations exist
  --      x_message_text
  --           : returns the message text
  ----------------------------------------------------------------------------
  l_api_version          NUMBER;
  l_api_name             VARCHAR2(50);
  l_return_status        VARCHAR2(1);
  l_message_name         VARCHAR2(30);
  l_mfg_name             mtl_manufacturers.manufacturer_name%TYPE;

  BEGIN
    l_api_version      := 1.0;
    l_api_name         := 'CHECK_NO_MFG_ASSOCIATIONS';
    l_message_name     := NULL;
    x_return_status    := G_EGO_SHORT_YES;
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
      RETURN;
    END IF;

    IF (p_manufacturer_id IS NULL) THEN
      RETURN;
    END IF;
    --
    -- check for mfg part num associations
    --
    BEGIN
      SELECT 'X'
      INTO l_return_status
      FROM mtl_mfg_part_numbers
      WHERE manufacturer_id = p_manufacturer_id
      AND rownum = 1;
      l_message_name := 'EGO_MTL_MFG_PART_NUM_EXIST';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    --
    -- check for pending changes for mfg part num
    --
    IF l_message_name IS NULL THEN
      BEGIN
        SELECT 'X'
        INTO l_return_status
        FROM DUAL
        WHERE EXISTS
         ( SELECT 'Y' FROM ego_mfg_part_num_chgs
           WHERE manufacturer_id = p_manufacturer_id
         );
        l_message_name := 'EGO_CHG_MFG_PART_NUM_EXIST';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;
    --
    -- check for PML list in catalog categories
    --
    IF l_message_name IS NULL THEN
      BEGIN
        SELECT 'X'
        INTO l_return_status
        FROM ego_cat_grp_mfg_assocs
        WHERE manufacturer_id = p_manufacturer_id
        AND rownum = 1;
        l_message_name := 'EGO_PML_MFG_ASSOC_EXIST';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    IF l_message_name IS NOT NULL THEN
      BEGIN
        SELECT manufacturer_name
        INTO l_mfg_name
        FROM mtl_manufacturers
        WHERE manufacturer_id = p_manufacturer_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_mfg_name := NULL;
      END;
      x_message_name := l_message_name;
      fnd_message.set_name('EGO',l_message_name);
      fnd_message.set_token('MFG_NAME',l_mfg_name);
      x_message_text := fnd_message.get();
      x_return_status := G_EGO_SHORT_NO;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('EGO', 'EGO_PLSQL_ERR');
      fnd_message.set_token('PKG_NAME', G_PKG_NAME);
      fnd_message.set_token('API_NAME', l_api_name);
      fnd_message.set_token('SQL_ERR_MSG', SQLERRM);
      x_message_name := 'EGO_PLSQL_ERR';
      x_message_text := fnd_message.get;
  END Check_No_MFG_Associations;

END EGO_ITEM_AML_PUB;

/
