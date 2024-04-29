--------------------------------------------------------
--  DDL for Package Body MTL_SECONDARY_INVENTORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_SECONDARY_INVENTORIES_PKG" AS
  /* $Header: INVSDSUB.pls 120.2.12010000.2 2010/01/05 16:06:47 abasheer ship $ */
  FUNCTION check_unique(x_rowid IN OUT nocopy VARCHAR2, x_secondary_inventory_name VARCHAR2, x_organization_id NUMBER)
    RETURN NUMBER IS
    dummy NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO dummy
      FROM mtl_secondary_inventories
     WHERE organization_id = x_organization_id
       AND secondary_inventory_name = x_secondary_inventory_name
       AND((x_rowid IS NULL)
           OR(ROWID <> x_rowid));

    IF (dummy >= 1) THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END check_unique;

  PROCEDURE commit_row IS
  BEGIN
    COMMIT;
  END commit_row;

  PROCEDURE rollback_row IS
  BEGIN
    ROLLBACK;
  END rollback_row;

  /* WMS Enhancements
     Accomodated the Status_ID, Default_Loc_Status_ID, Default_Cost_Group_ID
     and LPN_Controlled_Flag in the following procedure. */
  PROCEDURE insert_row(
    x_rowid                      IN OUT nocopy VARCHAR2
  , x_secondary_inventory_name          VARCHAR2
  , x_organization_id                   NUMBER
  , x_last_update_date                  DATE
  , x_last_updated_by                   NUMBER
  , x_creation_date                     DATE
  , x_created_by                        NUMBER
  , x_last_update_login                 NUMBER
  , x_description                       VARCHAR2
  , x_disable_date                      DATE
  , x_inventory_atp_code                NUMBER
  , x_availability_type                 NUMBER
  , x_reservable_type                   NUMBER
  , x_locator_type                      NUMBER
  , x_picking_order                     NUMBER
  , x_dropping_order                    NUMBER
  , x_material_account                  NUMBER
  , x_material_overhead_account         NUMBER
  , x_resource_account                  NUMBER
  , x_overhead_account                  NUMBER
  , x_outside_processing_account        NUMBER
  , x_quantity_tracked                  NUMBER
  , x_asset_inventory                   NUMBER
  , x_source_type                       NUMBER
  , x_source_subinventory               VARCHAR2
  , x_source_organization_id            NUMBER
  , x_requisition_approval_type         NUMBER
  , x_expense_account                   NUMBER
  , x_encumbrance_account               NUMBER
  , x_attribute_category                VARCHAR2
  , x_attribute1                        VARCHAR2
  , x_attribute2                        VARCHAR2
  , x_attribute3                        VARCHAR2
  , x_attribute4                        VARCHAR2
  , x_attribute5                        VARCHAR2
  , x_attribute6                        VARCHAR2
  , x_attribute7                        VARCHAR2
  , x_attribute8                        VARCHAR2
  , x_attribute9                        VARCHAR2
  , x_attribute10                       VARCHAR2
  , x_attribute11                       VARCHAR2
  , x_attribute12                       VARCHAR2
  , x_attribute13                       VARCHAR2
  , x_attribute14                       VARCHAR2
  , x_attribute15                       VARCHAR2
  , x_preprocessing_lead_time           NUMBER
  , x_processing_lead_time              NUMBER
  , x_postprocessing_lead_time          NUMBER
  , x_demand_class                      VARCHAR2
  , x_project_id                        NUMBER
  , x_task_id                           NUMBER
  , x_subinventory_usage                NUMBER
  , x_notify_list_id                    NUMBER
  , x_depreciable_flag                  NUMBER
  , x_location_id                       NUMBER
  , x_status_id                         NUMBER
  , x_default_loc_status_id             NUMBER
  , x_lpn_controlled_flag               NUMBER
  , x_default_cost_group_id             NUMBER
  /* As per bug 1584641 */
  --, X_pick_methodology         NUMBER
  , x_pick_uom_code                     VARCHAR2
  , x_cartonization_flag                NUMBER
  , x_planning_level                    NUMBER   DEFAULT 2
  , x_default_count_type_code           NUMBER   DEFAULT 2
  , x_subinventory_type                 NUMBER   DEFAULT 1--RCVLOCATORSSUPPORT
  , x_enable_bulk_pick                  VARCHAR2 DEFAULT 'N'
  , x_enable_locator_alias              VARCHAR2 DEFAULT 'N'
  , x_enforce_alias_uniqueness          VARCHAR2 DEFAULT 'N'
  , x_enable_opp_cyc_count_flag         VARCHAR2 DEFAULT 'N'  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_header_id           NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_quantity            NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_days                NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808

  ) IS
    CURSOR c IS
      SELECT ROWID
        FROM mtl_secondary_inventories
       WHERE organization_id = x_organization_id
         AND secondary_inventory_name = x_secondary_inventory_name;
  BEGIN
    INSERT INTO mtl_secondary_inventories
                (
                 secondary_inventory_name
               , organization_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , description
               , disable_date
               , inventory_atp_code
               , availability_type
               , reservable_type
               , locator_type
               , picking_order
               , dropping_order
               , material_account
               , material_overhead_account
               , resource_account
               , overhead_account
               , outside_processing_account
               , quantity_tracked
               , asset_inventory
               , source_type
               , source_subinventory
               , source_organization_id
               , requisition_approval_type
               , expense_account
               , encumbrance_account
               , attribute_category
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
               , preprocessing_lead_time
               , processing_lead_time
               , postprocessing_lead_time
               , demand_class
               , project_id
               , task_id
               , subinventory_usage
               , notify_list_id
               , depreciable_flag
               , location_id
               , status_id
               , default_loc_status_id
               , lpn_controlled_flag
               , default_cost_group_id
               /* As per bug 1584641 */
                -- ,pick_methodology
               , pick_uom_code
               , cartonization_flag
               , planning_level
               , default_count_type_code
               , subinventory_type
               , enable_bulk_pick
               , enable_locator_alias
               , enforce_alias_uniqueness
               , enable_opp_cyc_count         -- Added for Opp Cyc Counting bug#9248808
               , opp_cyc_count_header_id           -- Added for Opp Cyc Counting bug#9248808
               , opp_cyc_count_quantity            -- Added for Opp Cyc Counting bug#9248808
               , opp_cyc_count_days                -- Added for Opp Cyc Counting bug#9248808
               )
         VALUES (
                 x_secondary_inventory_name
               , x_organization_id
               , x_last_update_date
               , x_last_updated_by
               , x_creation_date
               , x_created_by
               , x_last_update_login
               , x_description
               , x_disable_date
               , x_inventory_atp_code
               , x_availability_type
               , x_reservable_type
               , x_locator_type
               , x_picking_order
               , x_dropping_order
               , x_material_account
               , x_material_overhead_account
               , x_resource_account
               , x_overhead_account
               , x_outside_processing_account
               , x_quantity_tracked
               , x_asset_inventory
               , x_source_type
               , x_source_subinventory
               , x_source_organization_id
               , x_requisition_approval_type
               , x_expense_account
               , x_encumbrance_account
               , x_attribute_category
               , x_attribute1
               , x_attribute2
               , x_attribute3
               , x_attribute4
               , x_attribute5
               , x_attribute6
               , x_attribute7
               , x_attribute8
               , x_attribute9
               , x_attribute10
               , x_attribute11
               , x_attribute12
               , x_attribute13
               , x_attribute14
               , x_attribute15
               , x_preprocessing_lead_time
               , x_processing_lead_time
               , x_postprocessing_lead_time
               , x_demand_class
               , x_project_id
               , x_task_id
               , x_subinventory_usage
               , x_notify_list_id
               , x_depreciable_flag
               , x_location_id
               , x_status_id
               , x_default_loc_status_id
               , x_lpn_controlled_flag
               , x_default_cost_group_id
               /* As per bug 1584641 */
               --, X_pick_methodology
               , x_pick_uom_code
               , x_cartonization_flag
               , x_planning_level
               , x_default_count_type_code
               , x_subinventory_type
               , x_enable_bulk_pick
               , x_enable_locator_alias
               , x_enforce_alias_uniqueness
               , x_enable_opp_cyc_count_flag         -- Added for Opp Cyc Counting bug#9248808
               , x_opp_cyc_count_header_id           -- Added for Opp Cyc Counting bug#9248808
               , x_opp_cyc_count_quantity            -- Added for Opp Cyc Counting bug#9248808
               , x_opp_cyc_count_days                -- Added for Opp Cyc Counting bug#9248808
               );

    /* WMS Material Status Enhancements
       This Procedure Caters to the insertion of records in the
       table MTL_MATERIAL_STATUS_HISTORY. */
    /* Commenting this code because for status history we want to capture from where
       status was updated (Desktop or Mobile) and so we will make a call to this procedure
       explicitly instead of calling it indirectly
       Bug # 1695432
    IF (INV_INSTALL.ADV_INV_INSTALLED(p_Organization_ID => NULL))
      AND (X_Status_ID IS NOT NULL) THEN
        Status_History ( X_Organization_ID,
          NULL,
          NULL,
          NULL,
          2,
          X_Status_ID,
          X_Secondary_Inventory_Name,
          NULL,
          X_Creation_Date ,
          X_Created_By,
          X_Last_Updated_By,
          X_Last_Update_Date,
          X_Last_Update_Login,
          'Y',
          'Y');
    END IF;
   */
    OPEN c;
    FETCH c INTO x_rowid;

    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE c;
  END insert_row;

  /* WMS Enhancements
     Accomodated the Status_ID, Default_Loc_Status_ID, Default_Cost_Group_ID
     and LPN_Controlled_Flag in the following procedure. */
  PROCEDURE lock_row(
    x_rowid                      VARCHAR2
  , x_secondary_inventory_name   VARCHAR2
  , x_organization_id            NUMBER
  , x_description                VARCHAR2
  , x_disable_date               DATE
  , x_inventory_atp_code         NUMBER
  , x_availability_type          NUMBER
  , x_reservable_type            NUMBER
  , x_locator_type               NUMBER
  , x_picking_order              NUMBER
  , x_dropping_order             NUMBER
  , x_material_account           NUMBER
  , x_material_overhead_account  NUMBER
  , x_resource_account           NUMBER
  , x_overhead_account           NUMBER
  , x_outside_processing_account NUMBER
  , x_quantity_tracked           NUMBER
  , x_asset_inventory            NUMBER
  , x_source_type                NUMBER
  , x_source_subinventory        VARCHAR2
  , x_source_organization_id     NUMBER
  , x_requisition_approval_type  NUMBER
  , x_expense_account            NUMBER
  , x_encumbrance_account        NUMBER
  , x_attribute_category         VARCHAR2
  , x_attribute1                 VARCHAR2
  , x_attribute2                 VARCHAR2
  , x_attribute3                 VARCHAR2
  , x_attribute4                 VARCHAR2
  , x_attribute5                 VARCHAR2
  , x_attribute6                 VARCHAR2
  , x_attribute7                 VARCHAR2
  , x_attribute8                 VARCHAR2
  , x_attribute9                 VARCHAR2
  , x_attribute10                VARCHAR2
  , x_attribute11                VARCHAR2
  , x_attribute12                VARCHAR2
  , x_attribute13                VARCHAR2
  , x_attribute14                VARCHAR2
  , x_attribute15                VARCHAR2
  , x_preprocessing_lead_time    NUMBER
  , x_processing_lead_time       NUMBER
  , x_postprocessing_lead_time   NUMBER
  , x_demand_class               VARCHAR2
  , x_project_id                 NUMBER
  , x_task_id                    NUMBER
  , x_subinventory_usage         NUMBER
  , x_notify_list_id             NUMBER
  , x_depreciable_flag           NUMBER
  , x_location_id                NUMBER
  , x_status_id                  NUMBER
  , x_default_loc_status_id      NUMBER
  , x_lpn_controlled_flag        NUMBER
  , x_default_cost_group_id      NUMBER
  /* As per bug 1584641 */
  --, X_pick_methodology                 NUMBER
  , x_pick_uom_code              VARCHAR2
  , x_cartonization_flag         NUMBER
  , x_planning_level             NUMBER   DEFAULT 2
  , x_default_count_type_code    NUMBER   DEFAULT 2
  , x_subinventory_type          NUMBER   DEFAULT 1 --RCVLOCATORSSUPPORT
  , x_enable_bulk_pick           VARCHAR2 DEFAULT 'N'
  , x_enable_locator_alias       VARCHAR2 DEFAULT 'N'
  , x_enforce_alias_uniqueness   VARCHAR2 DEFAULT 'N'
  , x_enable_opp_cyc_count_flag  VARCHAR2 DEFAULT 'N'  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_header_id    NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_quantity     NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_days         NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  ) IS
    CURSOR c IS
      SELECT        *
      FROM mtl_secondary_inventories
      WHERE ROWID = x_rowid
      FOR UPDATE OF organization_id NOWAIT;

    recinfo        c%ROWTYPE;
    record_changed EXCEPTION;
  BEGIN
    OPEN c;
    FETCH c INTO recinfo;

    IF (c%NOTFOUND) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;

    CLOSE c;

    IF NOT(
           (recinfo.secondary_inventory_name = x_secondary_inventory_name)
           AND(recinfo.organization_id = x_organization_id)
           AND((recinfo.description = x_description)
               OR((recinfo.description IS NULL)
                  AND(x_description IS NULL)))
           AND((recinfo.disable_date = x_disable_date)
               OR((recinfo.disable_date IS NULL)
                  AND(x_disable_date IS NULL)))
           AND(recinfo.inventory_atp_code = x_inventory_atp_code)
           AND(recinfo.availability_type = x_availability_type)
           AND(recinfo.reservable_type = x_reservable_type)
           AND((recinfo.locator_type = x_locator_type)
               OR((recinfo.locator_type IS NULL)
                  AND(x_locator_type IS NULL)))
           AND((recinfo.picking_order = x_picking_order)
               OR((recinfo.picking_order IS NULL)
                  AND(x_picking_order IS NULL)))
           AND((recinfo.dropping_order = x_dropping_order)
               OR((recinfo.dropping_order IS NULL)
                  AND(x_dropping_order IS NULL)))
           AND((recinfo.material_account = x_material_account)
               OR((recinfo.material_account IS NULL)
                  AND(x_material_account IS NULL)))
           AND(
               (recinfo.material_overhead_account = x_material_overhead_account)
               OR((recinfo.material_overhead_account IS NULL)
                  AND(x_material_overhead_account IS NULL))
              )
           AND((recinfo.resource_account = x_resource_account)
               OR((recinfo.resource_account IS NULL)
                  AND(x_resource_account IS NULL)))
           AND((recinfo.overhead_account = x_overhead_account)
               OR((recinfo.overhead_account IS NULL)
                  AND(x_overhead_account IS NULL)))
           AND(
               (recinfo.outside_processing_account = x_outside_processing_account)
               OR((recinfo.outside_processing_account IS NULL)
                  AND(x_outside_processing_account IS NULL))
              )
           AND(recinfo.quantity_tracked = x_quantity_tracked)
           AND(recinfo.asset_inventory = x_asset_inventory)
           AND(recinfo.depreciable_flag = x_depreciable_flag)
           AND((recinfo.source_type = x_source_type)
               OR((recinfo.source_type IS NULL)
                  AND(x_source_type IS NULL)))
           AND(
               (recinfo.source_subinventory = x_source_subinventory)
               OR((recinfo.source_subinventory IS NULL)
                  AND(x_source_subinventory IS NULL))
              )
           AND(
               (recinfo.source_organization_id = x_source_organization_id)
               OR((recinfo.source_organization_id IS NULL)
                  AND(x_source_organization_id IS NULL))
              )
           AND(
               (recinfo.requisition_approval_type = x_requisition_approval_type)
               OR((recinfo.requisition_approval_type IS NULL)
                  AND(x_requisition_approval_type IS NULL))
              )
           AND((recinfo.expense_account = x_expense_account)
               OR((recinfo.expense_account IS NULL)
                  AND(x_expense_account IS NULL)))
           AND(
               (recinfo.encumbrance_account = x_encumbrance_account)
               OR((recinfo.encumbrance_account IS NULL)
                  AND(x_encumbrance_account IS NULL))
              )
           AND(
               (recinfo.attribute_category = x_attribute_category)
               OR((recinfo.attribute_category IS NULL)
                  AND(x_attribute_category IS NULL))
              )
          ) THEN
      RAISE record_changed;
    END IF;

    IF NOT(
           ((recinfo.attribute1 = x_attribute1)
            OR((recinfo.attribute1 IS NULL)
               AND(x_attribute1 IS NULL)))
           AND((recinfo.attribute2 = x_attribute2)
               OR((recinfo.attribute2 IS NULL)
                  AND(x_attribute2 IS NULL)))
           AND((recinfo.attribute3 = x_attribute3)
               OR((recinfo.attribute3 IS NULL)
                  AND(x_attribute3 IS NULL)))
           AND((recinfo.attribute4 = x_attribute4)
               OR((recinfo.attribute4 IS NULL)
                  AND(x_attribute4 IS NULL)))
           AND((recinfo.attribute5 = x_attribute5)
               OR((recinfo.attribute5 IS NULL)
                  AND(x_attribute5 IS NULL)))
           AND((recinfo.attribute6 = x_attribute6)
               OR((recinfo.attribute6 IS NULL)
                  AND(x_attribute6 IS NULL)))
           AND((recinfo.attribute7 = x_attribute7)
               OR((recinfo.attribute7 IS NULL)
                  AND(x_attribute7 IS NULL)))
           AND((recinfo.attribute8 = x_attribute8)
               OR((recinfo.attribute8 IS NULL)
                  AND(x_attribute8 IS NULL)))
           AND((recinfo.attribute9 = x_attribute9)
               OR((recinfo.attribute9 IS NULL)
                  AND(x_attribute9 IS NULL)))
           AND((recinfo.attribute10 = x_attribute10)
               OR((recinfo.attribute10 IS NULL)
                  AND(x_attribute10 IS NULL)))
           AND((recinfo.attribute11 = x_attribute11)
               OR((recinfo.attribute11 IS NULL)
                  AND(x_attribute11 IS NULL)))
           AND((recinfo.attribute12 = x_attribute12)
               OR((recinfo.attribute12 IS NULL)
                  AND(x_attribute12 IS NULL)))
           AND((recinfo.attribute13 = x_attribute13)
               OR((recinfo.attribute13 IS NULL)
                  AND(x_attribute13 IS NULL)))
           AND((recinfo.attribute14 = x_attribute14)
               OR((recinfo.attribute14 IS NULL)
                  AND(x_attribute14 IS NULL)))
           AND((recinfo.attribute15 = x_attribute15)
               OR((recinfo.attribute15 IS NULL)
                  AND(x_attribute15 IS NULL)))
           AND(
               (recinfo.preprocessing_lead_time = x_preprocessing_lead_time)
               OR((recinfo.preprocessing_lead_time IS NULL)
                  AND(x_preprocessing_lead_time IS NULL))
              )
           AND(
               (recinfo.processing_lead_time = x_processing_lead_time)
               OR((recinfo.processing_lead_time IS NULL)
                  AND(x_processing_lead_time IS NULL))
              )
           AND(
               (recinfo.postprocessing_lead_time = x_postprocessing_lead_time)
               OR((recinfo.postprocessing_lead_time IS NULL)
                  AND(x_postprocessing_lead_time IS NULL))
              )
           AND((recinfo.demand_class = x_demand_class)
               OR((recinfo.demand_class IS NULL)
                  AND(x_demand_class IS NULL)))
           AND((recinfo.project_id = x_project_id)
               OR((recinfo.project_id IS NULL)
                  AND(x_project_id IS NULL)))
           AND((recinfo.task_id = x_task_id)
               OR((recinfo.task_id IS NULL)
                  AND(x_task_id IS NULL)))
           AND(
               (recinfo.subinventory_usage = x_subinventory_usage)
               OR((recinfo.subinventory_usage IS NULL)
                  AND(x_subinventory_usage IS NULL))
              )
           AND((recinfo.notify_list_id = x_notify_list_id)
               OR((recinfo.notify_list_id IS NULL)
                  AND(x_notify_list_id IS NULL)))
           AND((recinfo.location_id = x_location_id)
               OR((recinfo.location_id IS NULL)
                  AND(x_location_id IS NULL)))
           AND((recinfo.status_id = x_status_id)
               OR((recinfo.status_id IS NULL)
                  AND(x_status_id IS NULL)))
           AND(
               (recinfo.default_loc_status_id = x_default_loc_status_id)
               OR((recinfo.default_loc_status_id IS NULL)
                  AND(x_default_loc_status_id IS NULL))
              )
           AND(
               (recinfo.lpn_controlled_flag = x_lpn_controlled_flag)
               OR((recinfo.lpn_controlled_flag IS NULL)
                  AND(x_lpn_controlled_flag IS NULL))
              )
           /* As per bug 1584641 */
                 --AND (  (Recinfo.pick_methodology =  X_pick_methodology)
                 --    OR ( (Recinfo.pick_methodology IS NULL)
                 --          AND (X_pick_methodology IS NULL)))
           AND((recinfo.pick_uom_code = x_pick_uom_code)
               OR((recinfo.pick_uom_code IS NULL)
                  AND(x_pick_uom_code IS NULL)))
           AND((recinfo.cartonization_flag = x_cartonization_flag)
               OR((recinfo.cartonization_flag IS NULL)
                  AND(x_cartonization_flag IS NULL)))
           AND((recinfo.planning_level = x_planning_level)
               OR((recinfo.planning_level IS NULL)
                  AND(x_planning_level IS NULL)))
           AND((recinfo.default_count_type_code = x_default_count_type_code)
               OR((recinfo.default_count_type_code IS NULL)
                  AND(x_default_count_type_code IS NULL))
              )
           AND((recinfo.subinventory_type = x_subinventory_type)
               OR((recinfo.subinventory_type IS NULL)
                  AND(x_subinventory_type IS NULL))
              ) --RCVLOCATORSSUPPORT
	   AND((recinfo.enable_bulk_pick = x_enable_bulk_pick)
               OR((recinfo.enable_bulk_pick IS NULL)
                  AND(x_enable_bulk_pick IS NULL))
              )
	   AND((recinfo.enable_locator_alias = x_enable_locator_alias)
               OR((recinfo.enable_locator_alias IS NULL)
                  AND(x_enable_locator_alias IS NULL))
              )
	   AND((recinfo.enforce_alias_uniqueness = x_enforce_alias_uniqueness)
               OR((recinfo.enforce_alias_uniqueness IS NULL)
                  AND(x_enforce_alias_uniqueness IS NULL))
              )
              -- Added for Opp Cyc Counting bug#9248808
	   AND((recinfo.enable_opp_cyc_count = x_enable_opp_cyc_count_flag)
               OR((recinfo.enable_opp_cyc_count IS NULL)
                  AND(x_enable_opp_cyc_count_flag IS NULL))
              ) --RCVLOCATORSSUPPORT
	   AND((recinfo.opp_cyc_count_header_id = x_opp_cyc_count_header_id)
               OR((recinfo.opp_cyc_count_header_id IS NULL)
                  AND(x_opp_cyc_count_header_id IS NULL))
              )
	   AND((recinfo.opp_cyc_count_quantity = x_opp_cyc_count_quantity)
               OR((recinfo.opp_cyc_count_quantity IS NULL)
                  AND(x_opp_cyc_count_quantity IS NULL))
              )
	   AND((recinfo.opp_cyc_count_days = x_opp_cyc_count_days)
               OR((recinfo.opp_cyc_count_days IS NULL)
                  AND(x_opp_cyc_count_days IS NULL))
              )

              -- Added for Opp Cyc Counting bug#9248808
          ) THEN
      RAISE record_changed;
    END IF;
  EXCEPTION
    WHEN record_changed THEN
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    WHEN OTHERS THEN
      RAISE;
  END lock_row;

  /* WMS Enhancements
     Accomodated the Status_ID, Default_Loc_Status_ID, Default_Cost_Group_ID
     and LPN_Controlled_Flag in the following procedure. */
  PROCEDURE update_row(
    x_rowid                      VARCHAR2
  , x_secondary_inventory_name   VARCHAR2
  , x_organization_id            NUMBER
  , x_last_update_date           DATE
  , x_last_updated_by            NUMBER
  , x_last_update_login          NUMBER
  , x_description                VARCHAR2
  , x_disable_date               DATE
  , x_inventory_atp_code         NUMBER
  , x_availability_type          NUMBER
  , x_reservable_type            NUMBER
  , x_locator_type               NUMBER
  , x_picking_order              NUMBER
  , x_dropping_order             NUMBER
  , x_material_account           NUMBER
  , x_material_overhead_account  NUMBER
  , x_resource_account           NUMBER
  , x_overhead_account           NUMBER
  , x_outside_processing_account NUMBER
  , x_quantity_tracked           NUMBER
  , x_asset_inventory            NUMBER
  , x_source_type                NUMBER
  , x_source_subinventory        VARCHAR2
  , x_source_organization_id     NUMBER
  , x_requisition_approval_type  NUMBER
  , x_expense_account            NUMBER
  , x_encumbrance_account        NUMBER
  , x_attribute_category         VARCHAR2
  , x_attribute1                 VARCHAR2
  , x_attribute2                 VARCHAR2
  , x_attribute3                 VARCHAR2
  , x_attribute4                 VARCHAR2
  , x_attribute5                 VARCHAR2
  , x_attribute6                 VARCHAR2
  , x_attribute7                 VARCHAR2
  , x_attribute8                 VARCHAR2
  , x_attribute9                 VARCHAR2
  , x_attribute10                VARCHAR2
  , x_attribute11                VARCHAR2
  , x_attribute12                VARCHAR2
  , x_attribute13                VARCHAR2
  , x_attribute14                VARCHAR2
  , x_attribute15                VARCHAR2
  , x_preprocessing_lead_time    NUMBER
  , x_processing_lead_time       NUMBER
  , x_postprocessing_lead_time   NUMBER
  , x_demand_class               VARCHAR2
  , x_project_id                 NUMBER
  , x_task_id                    NUMBER
  , x_subinventory_usage         NUMBER
  , x_notify_list_id             NUMBER
  , x_depreciable_flag           NUMBER
  , x_location_id                NUMBER
  , x_status_id                  NUMBER
  , x_default_loc_status_id      NUMBER
  , x_lpn_controlled_flag        NUMBER
  , x_default_cost_group_id      NUMBER
  /* As per bug 1584641 */
  -- ,X_pick_methodology               NUMBER
  , x_pick_uom_code              VARCHAR2
  , x_cartonization_flag         NUMBER
  , x_planning_level             NUMBER   DEFAULT 2
  , x_default_count_type_code    NUMBER   DEFAULT 2
  , x_subinventory_type          NUMBER   DEFAULT 1--RCVLOCATORSSUPPORT
  , x_enable_bulk_pick           VARCHAR2 DEFAULT 'N'
  , x_enable_locator_alias       VARCHAR2 DEFAULT 'N'
  , x_enforce_alias_uniqueness   VARCHAR2 DEFAULT 'N'
  , x_enable_opp_cyc_count_flag  VARCHAR2 DEFAULT 'N'  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_header_id    NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_quantity     NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_days         NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  ) IS
    l_status_id NUMBER;
  BEGIN
    SELECT status_id
      INTO l_status_id
      FROM mtl_secondary_inventories
     WHERE ROWID = x_rowid;

    UPDATE mtl_secondary_inventories
       SET secondary_inventory_name = x_secondary_inventory_name
         , organization_id = x_organization_id
         , last_update_date = x_last_update_date
         , last_updated_by = x_last_updated_by
         , last_update_login = x_last_update_login
         , description = x_description
         , disable_date = x_disable_date
         , inventory_atp_code = x_inventory_atp_code
         , availability_type = x_availability_type
         , reservable_type = x_reservable_type
         , locator_type = x_locator_type
         , picking_order = x_picking_order
         , dropping_order = x_dropping_order
         , material_account = x_material_account
         , material_overhead_account = x_material_overhead_account
         , resource_account = x_resource_account
         , overhead_account = x_overhead_account
         , outside_processing_account = x_outside_processing_account
         , quantity_tracked = x_quantity_tracked
         , asset_inventory = x_asset_inventory
         , source_type = x_source_type
         , source_subinventory = x_source_subinventory
         , source_organization_id = x_source_organization_id
         , requisition_approval_type = x_requisition_approval_type
         , expense_account = x_expense_account
         , encumbrance_account = x_encumbrance_account
         , attribute_category = x_attribute_category
         , attribute1 = x_attribute1
         , attribute2 = x_attribute2
         , attribute3 = x_attribute3
         , attribute4 = x_attribute4
         , attribute5 = x_attribute5
         , attribute6 = x_attribute6
         , attribute7 = x_attribute7
         , attribute8 = x_attribute8
         , attribute9 = x_attribute9
         , attribute10 = x_attribute10
         , attribute11 = x_attribute11
         , attribute12 = x_attribute12
         , attribute13 = x_attribute13
         , attribute14 = x_attribute14
         , attribute15 = x_attribute15
         , preprocessing_lead_time = x_preprocessing_lead_time
         , processing_lead_time = x_processing_lead_time
         , postprocessing_lead_time = x_postprocessing_lead_time
         , demand_class = x_demand_class
         , project_id = x_project_id
         , task_id = x_task_id
         , subinventory_usage = x_subinventory_usage
         , notify_list_id = x_notify_list_id
         , depreciable_flag = x_depreciable_flag
         , location_id = x_location_id
         , status_id = x_status_id
         , default_loc_status_id = x_default_loc_status_id
         , lpn_controlled_flag = x_lpn_controlled_flag
         , default_cost_group_id = x_default_cost_group_id
         /* As per bug 1584641 */
         -- , pick_methodology                =     X_pick_methodology
         , pick_uom_code = x_pick_uom_code
         , cartonization_flag = x_cartonization_flag
         , planning_level = x_planning_level
         , default_count_type_code = x_default_count_type_code
         , subinventory_type = x_subinventory_type
         , enable_bulk_pick = x_enable_bulk_pick
         , enable_locator_alias = x_enable_locator_alias
         , enforce_alias_uniqueness = x_enforce_alias_uniqueness
         , enable_opp_cyc_count = x_enable_opp_cyc_count_flag         -- Added for Opp Cyc Counting bug#9248808
         , opp_cyc_count_header_id = x_opp_cyc_count_header_id           -- Added for Opp Cyc Counting bug#9248808
         , opp_cyc_count_quantity = x_opp_cyc_count_quantity            -- Added for Opp Cyc Counting bug#9248808
         , opp_cyc_count_days = x_opp_cyc_count_days                -- Added for Opp Cyc Counting bug#9248808
      WHERE ROWID = x_rowid;

    /* WMS Material Status Enhancements
       This Procedure Caters to the insertion of records in the
       table MTL_MATERIAL_STATUS_HISTORY. */
    /* Commenting this code because for status history we want to capture from where
       status was updated (Desktop or Mobile) and so we will make a call to this procedure
       explicitly instead of calling it indirectly
       Bug # 1695432

    IF (INV_INSTALL.ADV_INV_INSTALLED(P_Organization_ID => NULL)) AND
       (X_Status_ID IS NOT NULL) AND
       (X_Status_ID <> l_status_id) THEN
        Status_History ( X_Organization_ID,
          NULL,
          NULL,
          NULL,
          2,
          X_Status_ID,
          X_Secondary_Inventory_Name,
          NULL,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Updated_By,
          X_Last_Update_Date,
          X_Last_Update_Login,
          NULL
          );
    END IF;
    */
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END update_row;

  PROCEDURE delete_row(x_rowid VARCHAR2) IS
  BEGIN
    DELETE FROM mtl_secondary_inventories
          WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;

  /* WMS Material Status Enhancements
     This Procedure Caters to the insertion of records in the
     table MTL_MATERIAL_STATUS_HISTORY. */
  PROCEDURE status_history(
    x_organization_id       NUMBER
  , x_inventory_item_id     NUMBER
  , x_lot_number            VARCHAR2
  , x_serial_number         VARCHAR2
  , x_update_method         NUMBER
  , x_status_id             NUMBER
  , x_zone_code             VARCHAR2
  , x_locator_id            NUMBER
  , x_creation_date         DATE
  , x_created_by            NUMBER
  , x_last_updated_by       NUMBER
  , x_last_update_date      DATE
  , x_last_update_login     NUMBER
  , x_initial_status_flag   VARCHAR2 DEFAULT NULL
  , x_from_mobile_apps_flag VARCHAR2 DEFAULT NULL
  ) IS
    p_status inv_material_status_pub.mtl_status_update_rec_type;
  BEGIN
    p_status.organization_id        := x_organization_id;
    p_status.inventory_item_id      := x_inventory_item_id;
    p_status.lot_number             := x_lot_number;
    p_status.serial_number          := x_serial_number;
    p_status.update_method          := x_update_method;
    p_status.status_id              := x_status_id;
    p_status.zone_code              := x_zone_code;
    p_status.locator_id             := x_locator_id;
    p_status.creation_date          := x_creation_date;
    p_status.created_by             := x_created_by;
    /*  p_Status.Last_Updated_By  := X_Last_Updated_By;  */
    p_status.last_update_date       := x_last_update_date;
    p_status.last_update_login      := x_last_update_login;
    p_status.initial_status_flag    := x_initial_status_flag;
    p_status.from_mobile_apps_flag  := x_from_mobile_apps_flag;
    -- Bug# 1695432
    inv_material_status_pkg.insert_status_history(p_status);
  END status_history;

  FUNCTION get_miss_num
    RETURN NUMBER IS
  BEGIN
    RETURN fnd_api.g_miss_num;
  END;
END mtl_secondary_inventories_pkg;

/
