--------------------------------------------------------
--  DDL for Package LOT_SPLIT_DATA_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LOT_SPLIT_DATA_INSERT" AUTHID CURRENT_USER AS
/* $Header: INVLSPLS.pls 120.0 2005/05/25 05:31:08 appldev noship $ */
   TYPE inputrec IS RECORD (
                 transaction_type_id            MTL_TRANSACTION_TYPES.transaction_type_id%TYPE,
                 transaction_lot                VARCHAR2(1),
                 inventory_item_id              MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
                 revision                       MTL_ITEM_REVISIONS.revision%TYPE,
                 organization_id                MTL_PARAMETERS.organization_id%TYPE,
                 subinventory_code              MTL_SECONDARY_INVENTORIES.secondary_inventory_name%TYPE,
                 locator_id                     MTL_ITEM_LOCATIONS.inventory_location_id%TYPE,
                 transaction_quantity           MTL_MATERIAL_TRANSACTIONS.transaction_quantity%TYPE,
            		 secondary_transaction_quantity MTL_MATERIAL_TRANSACTIONS.secondary_transaction_quantity%TYPE, -- Bug #4093379  INVCONV
                 primary_quantity               MTL_MATERIAL_TRANSACTIONS.primary_quantity%TYPE,
                 transaction_uom                MTL_UNITS_OF_MEASURE.uom_code%TYPE,
                 item_description               MTL_SYSTEM_ITEMS_KFV.description%TYPE,
                 item_location_control_code     MTL_SYSTEM_ITEMS_KFV.location_control_code%TYPE,
                 item_restrict_subinv_code      MTL_SYSTEM_ITEMS_KFV.restrict_subinventories_code%TYPE,
                 item_restrict_locators_code    MTL_SYSTEM_ITEMS_KFV.restrict_locators_code%TYPE,
                 item_revision_qty_control_code MTL_SYSTEM_ITEMS_KFV.revision_qty_control_code%TYPE,
                 item_primary_uom_code          MTL_SYSTEM_ITEMS_KFV.primary_uom_code%TYPE,
                 item_secondary_uom_code        MTL_SYSTEM_ITEMS_KFV.secondary_uom_code%TYPE,  -- Bug #4093379 INVCONV
                 item_shelf_life_code           MTL_SYSTEM_ITEMS_KFV.shelf_life_code%TYPE,
                 item_shelf_life_days           MTL_SYSTEM_ITEMS_KFV.shelf_life_days%TYPE,
                 allowed_units_lookup_code      MTL_SYSTEM_ITEMS_KFV.allowed_units_lookup_code%TYPE,
                 lot_number                     MTL_LOT_NUMBERS.lot_number%TYPE,
                 parent_lot_number              MTL_LOT_NUMBERS.parent_lot_number%TYPE,  -- Bug #4093379 INVCONV
                 origination_type               MTL_TRANSACTION_LOTS_TEMP.origination_type%TYPE,  -- Bug #4093379 INVCONV
                 lot_expiration_date            MTL_LOT_NUMBERS.expiration_date%TYPE,
                 expiration_action_date         MTL_TRANSACTION_LOTS_TEMP.expiration_action_date%TYPE, -- Bug #4093379 INVCONV
            		 expiration_action_code		      MTL_TRANSACTION_LOTS_TEMP.expiration_action_code%TYPE, -- Bug #4093379 INVCONV
                 hold_date                      MTL_TRANSACTION_LOTS_TEMP.hold_date%TYPE, -- Bug #4093379 INVCONV
                 reason_id                      MTL_TRANSACTION_LOTS_TEMP.reason_id%TYPE, -- Bug #4093379 INVCONV
                 lpn_id                         WMS_LICENSE_PLATE_NUMBERS.lpn_id%TYPE,
                 lpn_number                     WMS_LICENSE_PLATE_NUMBERS.license_plate_number%TYPE,
                 xfr_lpn_id                     WMS_LICENSE_PLATE_NUMBERS.lpn_id%TYPE,
                 cost_group_id                  MTL_MATERIAL_TRANSACTIONS_TEMP.cost_group_id%TYPE,
                 project_id                     NUMBER,
                 task_id                        NUMBER,
                 transaction_temp_id            MTL_MATERIAL_TRANSACTIONS_TEMP.transaction_temp_id%TYPE,
                 transaction_header_id          MTL_MATERIAL_TRANSACTIONS_TEMP.transaction_header_id%TYPE,
                 transaction_batch_id           MTL_MATERIAL_TRANSACTIONS_TEMP.transaction_batch_id%TYPE,
                 transaction_batch_seq          MTL_MATERIAL_TRANSACTIONS_TEMP.transaction_batch_seq%TYPE,
                 description                    MTL_LOT_NUMBERS.DESCRIPTION%TYPE,
                 vendor_id                      MTL_LOT_NUMBERS.VENDOR_ID%TYPE,
                 supplier_lot_number            MTL_LOT_NUMBERS.SUPPLIER_LOT_NUMBER%TYPE,
                 territory_code                 MTL_LOT_NUMBERS.TERRITORY_CODE%TYPE,
                 grade_code                     MTL_LOT_NUMBERS.GRADE_CODE%TYPE,
                 origination_date               MTL_LOT_NUMBERS.ORIGINATION_DATE%TYPE,
                 date_code                      MTL_LOT_NUMBERS.DATE_CODE%TYPE,
                 status_id                      MTL_LOT_NUMBERS.STATUS_ID%TYPE,
                 change_date                    MTL_LOT_NUMBERS.CHANGE_DATE%TYPE,
                 age                            MTL_LOT_NUMBERS.AGE%TYPE,
                 retest_date                    MTL_LOT_NUMBERS.RETEST_DATE%TYPE,
                 maturity_date                  MTL_LOT_NUMBERS.MATURITY_DATE%TYPE,
                 lot_attribute_category         MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE,
                 item_size                     MTL_LOT_NUMBERS.ITEM_SIZE%TYPE,
                 color                         MTL_LOT_NUMBERS.COLOR%TYPE,
                 volume                        MTL_LOT_NUMBERS.VOLUME%TYPE,
                 volume_uom                    MTL_LOT_NUMBERS.VOLUME_UOM%TYPE,
                 place_of_origin               MTL_LOT_NUMBERS.PLACE_OF_ORIGIN%TYPE,
                 best_by_date                  MTL_LOT_NUMBERS.BEST_BY_DATE%TYPE,
                 length                        MTL_LOT_NUMBERS.LENGTH%TYPE,
                 length_uom                    MTL_LOT_NUMBERS.LENGTH_UOM%TYPE,
                 recycled_content              MTL_LOT_NUMBERS.RECYCLED_CONTENT%TYPE,
                 thickness                     MTL_LOT_NUMBERS.THICKNESS%TYPE,
                 thickness_uom                 MTL_LOT_NUMBERS.THICKNESS_UOM%TYPE,
                 width                         MTL_LOT_NUMBERS.WIDTH%TYPE,
                 width_uom                     MTL_LOT_NUMBERS.WIDTH_UOM%TYPE,
                 curl_wrinkle_fold             MTL_LOT_NUMBERS.CURL_WRINKLE_FOLD%TYPE,
                 c_attribute1                  MTL_LOT_NUMBERS.C_ATTRIBUTE1%TYPE,
                 c_attribute2                  MTL_LOT_NUMBERS.C_ATTRIBUTE2%TYPE,
                 c_attribute3                  MTL_LOT_NUMBERS.C_ATTRIBUTE3%TYPE,
                 c_attribute4                  MTL_LOT_NUMBERS.C_ATTRIBUTE4%TYPE,
                 c_attribute5                  MTL_LOT_NUMBERS.C_ATTRIBUTE5%TYPE,
                 c_attribute6                  MTL_LOT_NUMBERS.C_ATTRIBUTE6%TYPE,
                 c_attribute7                  MTL_LOT_NUMBERS.C_ATTRIBUTE7%TYPE,
                 c_attribute8                  MTL_LOT_NUMBERS.C_ATTRIBUTE8%TYPE,
                 c_attribute9                  MTL_LOT_NUMBERS.C_ATTRIBUTE9%TYPE,
                 c_attribute10                 MTL_LOT_NUMBERS.C_ATTRIBUTE10%TYPE,
                 c_attribute11                 MTL_LOT_NUMBERS.C_ATTRIBUTE11%TYPE,
                 c_attribute12                 MTL_LOT_NUMBERS.C_ATTRIBUTE12%TYPE,
                 c_attribute13                 MTL_LOT_NUMBERS.C_ATTRIBUTE13%TYPE,
                 c_attribute14                 MTL_LOT_NUMBERS.C_ATTRIBUTE14%TYPE,
                 c_attribute15                 MTL_LOT_NUMBERS.C_ATTRIBUTE15%TYPE,
                 c_attribute16                 MTL_LOT_NUMBERS.C_ATTRIBUTE16%TYPE,
                 c_attribute17                 MTL_LOT_NUMBERS.C_ATTRIBUTE17%TYPE,
                 c_attribute18                 MTL_LOT_NUMBERS.C_ATTRIBUTE18%TYPE,
                 c_attribute19                 MTL_LOT_NUMBERS.C_ATTRIBUTE19%TYPE,
                 c_attribute20                 MTL_LOT_NUMBERS.C_ATTRIBUTE20%TYPE,
                 d_attribute1                  MTL_LOT_NUMBERS.D_ATTRIBUTE1%TYPE,
                 d_attribute2                  MTL_LOT_NUMBERS.D_ATTRIBUTE2%TYPE,
                 d_attribute3                  MTL_LOT_NUMBERS.D_ATTRIBUTE3%TYPE,
                 d_attribute4                  MTL_LOT_NUMBERS.D_ATTRIBUTE4%TYPE,
                 d_attribute5                  MTL_LOT_NUMBERS.D_ATTRIBUTE5%TYPE,
                 d_attribute6                  MTL_LOT_NUMBERS.D_ATTRIBUTE6%TYPE,
                 d_attribute7                  MTL_LOT_NUMBERS.D_ATTRIBUTE7%TYPE,
                 d_attribute8                  MTL_LOT_NUMBERS.D_ATTRIBUTE8%TYPE,
                 d_attribute9                  MTL_LOT_NUMBERS.D_ATTRIBUTE9%TYPE,
                 d_attribute10                 MTL_LOT_NUMBERS.D_ATTRIBUTE10%TYPE,
                 n_attribute1                  MTL_LOT_NUMBERS.N_ATTRIBUTE1%TYPE,
                 n_attribute2                  MTL_LOT_NUMBERS.N_ATTRIBUTE2%TYPE,
                 n_attribute3                  MTL_LOT_NUMBERS.N_ATTRIBUTE3%TYPE,
                 n_attribute4                  MTL_LOT_NUMBERS.N_ATTRIBUTE4%TYPE,
                 n_attribute5                  MTL_LOT_NUMBERS.N_ATTRIBUTE5%TYPE,
                 n_attribute6                  MTL_LOT_NUMBERS.N_ATTRIBUTE6%TYPE,
                 n_attribute7                  MTL_LOT_NUMBERS.N_ATTRIBUTE7%TYPE,
                 n_attribute8                  MTL_LOT_NUMBERS.N_ATTRIBUTE8%TYPE,
                 n_attribute9                  MTL_LOT_NUMBERS.N_ATTRIBUTE9%TYPE,
                 n_attribute10                 MTL_LOT_NUMBERS.N_ATTRIBUTE10%TYPE
                 );
   TYPE input_table IS TABLE OF  inputrec
                    INDEX BY BINARY_INTEGER;
   tab_index   INTEGER ;
   tab_input   input_table;

   /* In case of Lot split transaction
         1st  record will be the starting lot record
             for 1 start lot insert into mmtt ,   mtlt
             for each mmtt  create an mmt record
             for each mtlt  create an mtln record
         and rest of the records will be the resulting lot record
             for each result lot insert into mmtt ,   mtlt
             for each mmtt  create an mmt record and populate transfer_transaction_id = start lot's id
             for each mtlt  create an mtln record and
                            create an mln  record
      Lot Merge transaction
         The last record will be the resulting lot record
         and all others will be the starting lot records
   */
--
PROCEDURE  set_table (
           p_transaction_type_id            IN  MTL_TRANSACTION_TYPES.transaction_type_id%TYPE,
           p_transaction_lot                IN  VARCHAR2,
           p_inventory_item_id              IN  MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
           p_revision                       IN  MTL_ITEM_REVISIONS.revision%TYPE,
           p_organization_id                IN  MTL_PARAMETERS.organization_id%TYPE,
           p_subinventory_code              IN  MTL_SECONDARY_INVENTORIES.secondary_inventory_name%TYPE,
           p_locator_id                     IN  MTL_ITEM_LOCATIONS.inventory_location_id%TYPE,
           p_transaction_quantity           IN  MTL_MATERIAL_TRANSACTIONS.transaction_quantity%TYPE,
           p_primary_quantity               IN  MTL_MATERIAL_TRANSACTIONS.primary_quantity%TYPE,
           p_transaction_uom                IN  MTL_UNITS_OF_MEASURE.uom_code%TYPE,
           p_item_description               IN  MTL_SYSTEM_ITEMS_KFV.description%TYPE,
           p_item_location_control_code     IN  MTL_SYSTEM_ITEMS_KFV.location_control_code%TYPE,
           p_item_restrict_subinv_code      IN  MTL_SYSTEM_ITEMS_KFV.restrict_subinventories_code%TYPE,
           p_item_restrict_locators_code    IN  MTL_SYSTEM_ITEMS_KFV.restrict_locators_code%TYPE,
           p_item_revision_qty_control_cd   IN  MTL_SYSTEM_ITEMS_KFV.revision_qty_control_code%TYPE,
           p_item_primary_uom_code          IN  MTL_SYSTEM_ITEMS_KFV.primary_uom_code%TYPE,
           p_item_shelf_life_code           IN  MTL_SYSTEM_ITEMS_KFV.shelf_life_code%TYPE,
           p_item_shelf_life_days           IN  MTL_SYSTEM_ITEMS_KFV.shelf_life_days%TYPE,
           p_allowed_units_lookup_code      IN  MTL_SYSTEM_ITEMS_KFV.allowed_units_lookup_code%TYPE,
           p_lot_number                     IN  MTL_LOT_NUMBERS.lot_number%TYPE,
           p_lot_expiration_date            IN  MTL_LOT_NUMBERS.expiration_date%TYPE,
           p_total_qty                      IN  MTL_MATERIAL_TRANSACTIONS.transaction_quantity%TYPE,
           p_lpn_id                         IN  WMS_LICENSE_PLATE_NUMBERS.lpn_id%TYPE,
           p_lpn_number                     IN  WMS_LICENSE_PLATE_NUMBERS.license_plate_number%TYPE,
           p_xfr_lpn_id                     IN  WMS_LICENSE_PLATE_NUMBERS.lpn_id%TYPE,
           p_userid                         IN  NUMBER,
           p_costgroup_id                   IN  WMS_LPN_CONTENTS.cost_group_id%TYPE,
           p_project_id                     IN  NUMBER,
           p_task_id                        IN  NUMBER,
           x_return_status                  OUT NOCOPY VARCHAR2,
           x_header_id                      OUT NOCOPY NUMBER,
           x_msg_data                       OUT NOCOPY VARCHAR2,
           x_msg_count                      OUT NOCOPY NUMBER,
           p_description                    IN  MTL_LOT_NUMBERS.DESCRIPTION%TYPE,
           p_vendor_id                      IN  MTL_LOT_NUMBERS.VENDOR_ID%TYPE,
           p_supplier_lot_number            IN  MTL_LOT_NUMBERS.SUPPLIER_LOT_NUMBER%TYPE,
           p_territory_code                 IN  MTL_LOT_NUMBERS.TERRITORY_CODE%TYPE,
           p_grade_code                     IN  MTL_LOT_NUMBERS.GRADE_CODE%TYPE,
           p_origination_date               IN  MTL_LOT_NUMBERS.ORIGINATION_DATE%TYPE,
           p_date_code                      IN  MTL_LOT_NUMBERS.DATE_CODE%TYPE,
           p_status_id                      IN  MTL_LOT_NUMBERS.STATUS_ID%TYPE,
           p_change_date                    IN  MTL_LOT_NUMBERS.CHANGE_DATE%TYPE,
           p_age                            IN  MTL_LOT_NUMBERS.AGE%TYPE,
           p_retest_date                    IN  MTL_LOT_NUMBERS.RETEST_DATE%TYPE,
           p_maturity_date                  IN  MTL_LOT_NUMBERS.MATURITY_DATE%TYPE,
           p_lot_attribute_category         IN  MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE,
           p_item_size                      IN  MTL_LOT_NUMBERS.ITEM_SIZE%TYPE,
           p_color                          IN  MTL_LOT_NUMBERS.COLOR%TYPE,
           p_volume                         IN  MTL_LOT_NUMBERS.VOLUME%TYPE,
           p_volume_uom                     IN  MTL_LOT_NUMBERS.VOLUME_UOM%TYPE,
           p_place_of_origin                IN  MTL_LOT_NUMBERS.PLACE_OF_ORIGIN%TYPE,
           p_best_by_date                   IN  MTL_LOT_NUMBERS.BEST_BY_DATE%TYPE,
           p_length                         IN  MTL_LOT_NUMBERS.LENGTH%TYPE,
           p_length_uom                     IN  MTL_LOT_NUMBERS.LENGTH_UOM%TYPE,
           p_recycled_content               IN  MTL_LOT_NUMBERS.RECYCLED_CONTENT%TYPE,
           p_thickness                      IN  MTL_LOT_NUMBERS.THICKNESS%TYPE,
           p_thickness_uom                  IN  MTL_LOT_NUMBERS.THICKNESS_UOM%TYPE,
           p_width                          IN  MTL_LOT_NUMBERS.WIDTH%TYPE,
           p_width_uom                      IN  MTL_LOT_NUMBERS.WIDTH_UOM%TYPE,
           p_curl_wrinkle_fold              IN  MTL_LOT_NUMBERS.CURL_WRINKLE_FOLD%TYPE,
           p_c_attribute1                   IN  MTL_LOT_NUMBERS.C_ATTRIBUTE1%TYPE,
           p_c_attribute2                   IN  MTL_LOT_NUMBERS.C_ATTRIBUTE2%TYPE,
           p_c_attribute3                   IN  MTL_LOT_NUMBERS.C_ATTRIBUTE3%TYPE,
           p_c_attribute4                   IN  MTL_LOT_NUMBERS.C_ATTRIBUTE4%TYPE,
           p_c_attribute5                   IN  MTL_LOT_NUMBERS.C_ATTRIBUTE5%TYPE,
           p_c_attribute6                   IN  MTL_LOT_NUMBERS.C_ATTRIBUTE6%TYPE,
           p_c_attribute7                   IN  MTL_LOT_NUMBERS.C_ATTRIBUTE7%TYPE,
           p_c_attribute8                   IN  MTL_LOT_NUMBERS.C_ATTRIBUTE8%TYPE,
           p_c_attribute9                   IN  MTL_LOT_NUMBERS.C_ATTRIBUTE9%TYPE,
           p_c_attribute10                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE10%TYPE,
           p_c_attribute11                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE11%TYPE,
           p_c_attribute12                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE12%TYPE,
           p_c_attribute13                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE13%TYPE,
           p_c_attribute14                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE14%TYPE,
           p_c_attribute15                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE15%TYPE,
           p_c_attribute16                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE16%TYPE,
           p_c_attribute17                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE17%TYPE,
           p_c_attribute18                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE18%TYPE,
           p_c_attribute19                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE19%TYPE,
           p_c_attribute20                  IN  MTL_LOT_NUMBERS.C_ATTRIBUTE20%TYPE,
           p_d_attribute1                   IN  MTL_LOT_NUMBERS.D_ATTRIBUTE1%TYPE,
           p_d_attribute2                   IN  MTL_LOT_NUMBERS.D_ATTRIBUTE2%TYPE,
           p_d_attribute3                   IN  MTL_LOT_NUMBERS.D_ATTRIBUTE3%TYPE,
           p_d_attribute4                   IN  MTL_LOT_NUMBERS.D_ATTRIBUTE4%TYPE,
           p_d_attribute5                   IN  MTL_LOT_NUMBERS.D_ATTRIBUTE5%TYPE,
           p_d_attribute6                   IN  MTL_LOT_NUMBERS.D_ATTRIBUTE6%TYPE,
           p_d_attribute7                   IN  MTL_LOT_NUMBERS.D_ATTRIBUTE7%TYPE,
           p_d_attribute8                   IN  MTL_LOT_NUMBERS.D_ATTRIBUTE8%TYPE,
           p_d_attribute9                   IN  MTL_LOT_NUMBERS.D_ATTRIBUTE9%TYPE,
           p_d_attribute10                  IN  MTL_LOT_NUMBERS.D_ATTRIBUTE10%TYPE,
           p_n_attribute1                   IN  MTL_LOT_NUMBERS.N_ATTRIBUTE1%TYPE,
           p_n_attribute2                   IN  MTL_LOT_NUMBERS.N_ATTRIBUTE2%TYPE,
           p_n_attribute3                   IN  MTL_LOT_NUMBERS.N_ATTRIBUTE3%TYPE,
           p_n_attribute4                   IN  MTL_LOT_NUMBERS.N_ATTRIBUTE4%TYPE,
           p_n_attribute5                   IN  MTL_LOT_NUMBERS.N_ATTRIBUTE5%TYPE,
           p_n_attribute6                   IN  MTL_LOT_NUMBERS.N_ATTRIBUTE6%TYPE,
           p_n_attribute7                   IN  MTL_LOT_NUMBERS.N_ATTRIBUTE7%TYPE,
           p_n_attribute8                   IN  MTL_LOT_NUMBERS.N_ATTRIBUTE8%TYPE,
           p_n_attribute9                   IN  MTL_LOT_NUMBERS.N_ATTRIBUTE9%TYPE,
           p_n_attribute10                  IN  MTL_LOT_NUMBERS.N_ATTRIBUTE10%TYPE,
           p_sec_transaction_quantity       IN  MTL_MATERIAL_TRANSACTIONS.secondary_transaction_quantity%TYPE DEFAULT NULL, -- Bug #4093379  INVCONV
      	   p_item_secondary_uom_code        IN  MTL_SYSTEM_ITEMS_KFV.secondary_uom_code%TYPE DEFAULT NULL,  -- Bug #4093379 INVCONV
           p_parent_lot_number              IN  MTL_LOT_NUMBERS.parent_lot_number%TYPE DEFAULT NULL,  -- Bug #4093379 INVCONV
           p_origination_type               IN  MTL_TRANSACTION_LOTS_TEMP.origination_type%TYPE DEFAULT NULL,  -- Bug #4093379 INVCONV
           p_expiration_action_date         IN  MTL_TRANSACTION_LOTS_TEMP.expiration_action_date%TYPE DEFAULT NULL, -- Bug #4093379 INVCONV
           p_expiration_action_code	        IN	MTL_TRANSACTION_LOTS_TEMP.expiration_action_code%TYPE DEFAULT NULL, -- Bug #4093379 INVCONV
           p_hold_date                      IN  MTL_TRANSACTION_LOTS_TEMP.hold_date%TYPE DEFAULT NULL, -- Bug #4093379 INVCONV
           p_reason_id                      IN  MTL_TRANSACTION_LOTS_TEMP.reason_id%TYPE DEFAULT NULL -- Bug #4093379 INVCONV
           );
--
PROCEDURE  insert_mmtt(p_total_qty                   IN     NUMBER,
                       p_transaction_type_id         IN     NUMBER,
                       p_userid                      IN     NUMBER,
                       x_return_status               OUT    NOCOPY VARCHAR2);
--
/* This procedure is called from the lotsplitmergepage (parent page) to get the initial values */
PROCEDURE  select_init_parameters(
                       p_organization_id     IN     MTL_ORGANIZATIONS.organization_id%TYPE,
                       x_stock_locator_code  OUT    NOCOPY MTL_parameters.stock_locator_control_code%TYPE,
                       x_wmsinstall          OUT    NOCOPY VARCHAR2,
                       x_wmsorg              OUT    NOCOPY VARCHAR2,
                       x_split_txnname       OUT    NOCOPY MTL_TRANSACTION_TYPES.transaction_type_name%TYPE,
                       x_merge_txnname       OUT    NOCOPY MTL_TRANSACTION_TYPES.transaction_type_name%TYPE,
                       x_translate_txnname   OUT    NOCOPY MTL_TRANSACTION_TYPES.transaction_type_name%TYPE,
                       x_cost_group_id       OUT    NOCOPY CST_COST_GROUPS.cost_group_id%TYPE,
                       x_primary_cost_method OUT    NOCOPY MTL_PARAMETERS.primary_cost_method%TYPE,
                       x_wsm_enabled_flag    OUT    NOCOPY VARCHAR2,
                       x_return_status       OUT    NOCOPY VARCHAR2,
                       x_msg_data            OUT    NOCOPY VARCHAR2,
                       x_msg_count           OUT    NOCOPY NUMBER,
                       x_dist_account_id     OUT    NOCOPY mtl_parameters.distribution_account_id%TYPE
  );
END lot_split_data_insert;

 

/
