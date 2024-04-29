--------------------------------------------------------
--  DDL for Package MTL_SECONDARY_INVENTORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_SECONDARY_INVENTORIES_PKG" AUTHID CURRENT_USER AS
  /* $Header: INVSDSUS.pls 120.2.12010000.2 2010/01/05 16:04:40 abasheer ship $ */
  FUNCTION check_unique(x_rowid IN OUT nocopy VARCHAR2, x_secondary_inventory_name VARCHAR2, x_organization_id NUMBER)
    RETURN NUMBER;

  PROCEDURE commit_row;

  PROCEDURE rollback_row;

  /* WMS Enhancements
     Accomodated Status_ID, Default_Loc_Status_ID, Default_Cost_Group_ID
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
  -- , X_pick_methodology       NUMBER
  , x_pick_uom_code                     VARCHAR2
  , x_cartonization_flag                NUMBER
  , x_planning_level                    NUMBER DEFAULT 2
  , x_default_count_type_code           NUMBER DEFAULT 2
  , x_subinventory_type                 NUMBER DEFAULT 1--RCVLOCATORSSUPPORT
  , x_enable_bulk_pick                  VARCHAR2 DEFAULT 'N'
  , x_enable_locator_alias              VARCHAR2 DEFAULT 'N'
  , x_enforce_alias_uniqueness          VARCHAR2 DEFAULT 'N'
  , x_enable_opp_cyc_count_flag         VARCHAR2 DEFAULT 'N'  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_header_id           NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_quantity            NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_days                NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  );

  /* WMS Enhancements
     Accomodated Status_ID, Default_Loc_Status_ID, Default_Cost_Group_ID
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
  -- , X_pick_methodology         NUMBER
  , x_pick_uom_code              VARCHAR2
  , x_cartonization_flag         NUMBER
  , x_planning_level             NUMBER DEFAULT 2
  , x_default_count_type_code    NUMBER DEFAULT 2
  , x_subinventory_type          NUMBER DEFAULT 1 --RCVLOCATORSSUPPORT
  , x_enable_bulk_pick           VARCHAR2 DEFAULT 'N'
  , x_enable_locator_alias       VARCHAR2 DEFAULT 'N'
  , x_enforce_alias_uniqueness   VARCHAR2 DEFAULT 'N'
  , x_enable_opp_cyc_count_flag  VARCHAR2 DEFAULT 'N'  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_header_id    NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_quantity     NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_days         NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
);

  /* WMS Enhancements
     Accomodated Status_ID, Default_Loc_Status_ID, Default_Cost_Group_ID
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
  --, pick_methodology         NUMBER
  , x_pick_uom_code              VARCHAR2
  , x_cartonization_flag         NUMBER
  , x_planning_level             NUMBER DEFAULT 2
  , x_default_count_type_code    NUMBER DEFAULT 2
  , x_subinventory_type          NUMBER DEFAULT 1 --RCVLOCATORSSUPPORT
  , x_enable_bulk_pick           VARCHAR2 DEFAULT 'N'
  , x_enable_locator_alias       VARCHAR2 DEFAULT 'N'
  , x_enforce_alias_uniqueness   VARCHAR2 DEFAULT 'N'
  , x_enable_opp_cyc_count_flag  VARCHAR2 DEFAULT 'N'  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_header_id    NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_quantity     NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  , x_opp_cyc_count_days         NUMBER DEFAULT NULL  -- Added for Opp Cyc Counting bug#9248808
  );

  PROCEDURE delete_row(x_rowid VARCHAR2);

  /* WMS Material Status Enhancements
     This procedure caters to the maintenance of the Material Status
     Hisotry. */
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
  );

  --Bug# 1695432 added col X_Initial_Status_Flag,X_From_Mobile_Apps_Flag

  FUNCTION get_miss_num
    RETURN NUMBER;
END mtl_secondary_inventories_pkg;

/
