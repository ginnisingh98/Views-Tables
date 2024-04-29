--------------------------------------------------------
--  DDL for Package Body LOT_SPLIT_DATA_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LOT_SPLIT_DATA_INSERT" AS
/* $Header: INVLSPLB.pls 120.1 2006/03/14 02:43:58 rsagar noship $ */
   g_header_id                    NUMBER  := 0;
   g_pkg_name                     VARCHAR2(100) := 'lot_split_data_insert';



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
           )
IS
   ind         INTEGER := 0;
   l_dir       VARCHAR2(1000) := NULL;
   l_filename  VARCHAR2(100) := 'ins_mmtt' || to_char(sysdate, 'dd:mm:hh24:mi');
   x_mesg_data  VARCHAR2(2000) := 'None';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   /* For lot split transaction (INV_Globals.G_type_inv_lot_split) there is a single start
      lot and multiple resulting
      Start Lot always gets stored in the 1st index position .
      For Lot merger (inv_globals.G_type_inv_lot_merge) 1st index position should store
      the single resulting lot from
      multiple starting lots.
      For lot translate transaction (INV_Globals.G_type_inv_lot_translate) there is a
      single start lot and single resulting lot.
      Start Lot always gets stored in the 1st index position.
   */

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_header_id     := NULL;

   IF tab_index is NULL
   THEN
      tab_index := 0;
   END IF;

   ind := tab_index + 1;

   tab_input(ind).transaction_type_id            :=  p_transaction_type_id;
   tab_input(ind).transaction_lot                :=  p_transaction_lot;
   tab_input(ind).inventory_item_id              :=  p_inventory_item_id;
   tab_input(ind).revision                       :=  p_revision;
   tab_input(ind).organization_id                :=  p_organization_id;
   tab_input(ind).subinventory_code              :=  p_subinventory_code;
   tab_input(ind).locator_id                     :=  p_locator_id;
   tab_input(ind).transaction_quantity           :=  p_transaction_quantity;
   tab_input(ind).secondary_transaction_quantity :=  p_sec_transaction_quantity; -- Bug #4093379 INVCONV
   tab_input(ind).primary_quantity               :=  p_primary_quantity;
   tab_input(ind).transaction_uom                :=  p_transaction_uom;

   tab_input(ind).item_description               :=  p_item_description;
   tab_input(ind).item_location_control_code     :=  p_item_location_control_code;
   tab_input(ind).item_restrict_subinv_code      :=  p_item_restrict_subinv_code;
   tab_input(ind).item_restrict_locators_code    :=  p_item_restrict_locators_code;
   tab_input(ind).item_revision_qty_control_code :=  p_item_revision_qty_control_cd;
   tab_input(ind).item_primary_uom_code          :=  p_item_primary_uom_code;
   tab_input(ind).item_secondary_uom_code        :=  p_item_secondary_uom_code;  -- Bug #4093379 INVCONV
   tab_input(ind).item_shelf_life_code           :=  p_item_shelf_life_code;
   tab_input(ind).item_shelf_life_days           :=  p_item_shelf_life_days;
   tab_input(ind).allowed_units_lookup_code      :=  p_allowed_units_lookup_code;

   tab_input(ind).lot_number                     :=  LTRIM(RTRIM(p_lot_number));
   tab_input(ind).parent_lot_number              :=  LTRIM(RTRIM(p_parent_lot_number)); -- Bug #4093379 INVCONV
   tab_input(ind).origination_type               :=  p_origination_type;    -- Bug #4093379 INVCONV
   tab_input(ind).lot_expiration_date            :=  p_lot_expiration_date;
   tab_input(ind).expiration_action_date         :=  p_expiration_action_date; -- Bug #4093379 INVCONV
   tab_input(ind).expiration_action_code         :=  p_expiration_action_code; -- Bug #4093379 INVCONV
   tab_input(ind).hold_date                      :=  p_hold_date; -- Bug #4093379 INVCONV
   tab_input(ind).reason_id                      :=  p_reason_id; -- Bug #4093379 INVCONV
   tab_input(ind).lpn_id                         :=  p_lpn_id;
   tab_input(ind).lpn_number                     :=  p_lpn_number;
   tab_input(ind).xfr_lpn_id                     :=  p_xfr_lpn_id;
   tab_input(ind).cost_group_id                  :=  p_costgroup_id;
   tab_input(ind).project_id                     :=  p_project_id;
   tab_input(ind).task_id                        :=  p_task_id;

   tab_input(ind).transaction_temp_id            := NULL;
   tab_input(ind).transaction_header_id          := NULL;
   tab_input(ind).transaction_batch_id           := NULL;
   tab_input(ind).transaction_batch_seq          := NULL;

   tab_input(ind).description                    :=  p_description;
   tab_input(ind).vendor_id                      :=  p_vendor_id;
   tab_input(ind).supplier_lot_number            :=  p_supplier_lot_number;
   tab_input(ind).territory_code                 :=  p_territory_code;
   tab_input(ind).grade_code                     :=  p_grade_code;
   tab_input(ind).origination_date               :=  p_origination_date;
   tab_input(ind).date_code                      :=  p_date_code;
   tab_input(ind).status_id                      :=  p_status_id;
   tab_input(ind).change_date                    :=  p_change_date;
   tab_input(ind).age                            :=  p_age;
   tab_input(ind).retest_date                    :=  p_retest_date;
   tab_input(ind).maturity_date                  :=  p_maturity_date;
   tab_input(ind).lot_attribute_category         :=  p_lot_attribute_category;
   tab_input(ind).item_size                      :=  p_item_size;
   tab_input(ind).color                          :=  p_color;
   tab_input(ind).volume                         :=  p_volume;
   tab_input(ind).volume_uom                     :=  p_volume_uom;
   tab_input(ind).place_of_origin                :=  p_place_of_origin;
   tab_input(ind).best_by_date                   :=  p_best_by_date;
   tab_input(ind).length                         :=  p_length;
   tab_input(ind).length_uom                     :=  p_length_uom;
   tab_input(ind).recycled_content               :=  p_recycled_content;
   tab_input(ind).thickness                      :=  p_thickness;
   tab_input(ind).thickness_uom                  :=  p_thickness_uom;
   tab_input(ind).width                          :=  p_width;
   tab_input(ind).width_uom                      :=  p_width_uom;
   tab_input(ind).curl_wrinkle_fold              :=  p_curl_wrinkle_fold;
   tab_input(ind).c_attribute1                   :=  p_c_attribute1;
   tab_input(ind).c_attribute2                   :=  p_c_attribute2;
   tab_input(ind).c_attribute3                   :=  p_c_attribute3;
   tab_input(ind).c_attribute4                   :=  p_c_attribute4;
   tab_input(ind).c_attribute5                   :=  p_c_attribute5;
   tab_input(ind).c_attribute6                   :=  p_c_attribute6;
   tab_input(ind).c_attribute7                   :=  p_c_attribute7;
   tab_input(ind).c_attribute8                   :=  p_c_attribute8;
   tab_input(ind).c_attribute9                   :=  p_c_attribute9;
   tab_input(ind).c_attribute10                  :=  p_c_attribute10;
   tab_input(ind).c_attribute11                  :=  p_c_attribute11;
   tab_input(ind).c_attribute12                  :=  p_c_attribute12;
   tab_input(ind).c_attribute13                  :=  p_c_attribute13;
   tab_input(ind).c_attribute14                  :=  p_c_attribute14;
   tab_input(ind).c_attribute15                  :=  p_c_attribute15;
   tab_input(ind).c_attribute16                  :=  p_c_attribute16;
   tab_input(ind).c_attribute17                  :=  p_c_attribute17;
   tab_input(ind).c_attribute18                  :=  p_c_attribute18;
   tab_input(ind).c_attribute19                  :=  p_c_attribute19;
   tab_input(ind).c_attribute20                  :=  p_c_attribute20;
   tab_input(ind).d_attribute1                   :=  p_d_attribute1;
   tab_input(ind).d_attribute2                   :=  p_d_attribute2;
   tab_input(ind).d_attribute3                   :=  p_d_attribute3;
   tab_input(ind).d_attribute4                   :=  p_d_attribute4;
   tab_input(ind).d_attribute5                   :=  p_d_attribute5;
   tab_input(ind).d_attribute6                   :=  p_d_attribute6;
   tab_input(ind).d_attribute7                   :=  p_d_attribute7;
   tab_input(ind).d_attribute8                   :=  p_d_attribute8;
   tab_input(ind).d_attribute9                   :=  p_d_attribute9;
   tab_input(ind).d_attribute10                  :=  p_d_attribute10;
   tab_input(ind).n_attribute1                   :=  p_n_attribute1;
   tab_input(ind).n_attribute2                   :=  p_n_attribute2;
   tab_input(ind).n_attribute3                   :=  p_n_attribute3;
   tab_input(ind).n_attribute4                   :=  p_n_attribute4;
   tab_input(ind).n_attribute5                   :=  p_n_attribute5;
   tab_input(ind).n_attribute6                   :=  p_n_attribute6;
   tab_input(ind).n_attribute7                   :=  p_n_attribute7;
   tab_input(ind).n_attribute8                   :=  p_n_attribute8;
   tab_input(ind).n_attribute9                   :=  p_n_attribute9;
   tab_input(ind).n_attribute10                  :=  p_n_attribute10;

   tab_index := ind;

   IF (l_debug = 1) THEN
      INV_TRX_UTIL_PUB.trace('out :' || p_total_qty || ':' ,g_pkg_name,9);
      INV_TRX_UTIL_PUB.trace('Ttype :' ||p_transaction_type_id || ':' ,g_pkg_name,9);
      INV_TRX_UTIL_PUB.trace('Tlot  :' ||p_transaction_lot || ':' ,g_pkg_name,9);
      INV_TRX_UTIL_PUB.trace('Item  :' ||p_inventory_item_id || ':' ,g_pkg_name,9);
      INV_TRX_UTIL_PUB.trace('Org :' ||p_organization_id || ':' ,g_pkg_name,9);
      INV_TRX_UTIL_PUB.trace('Sub :' ||p_subinventory_code || ':' ,g_pkg_name,9);
      INV_TRX_UTIL_PUB.trace('Loc :' ||p_locator_id || ':' ,g_pkg_name,9);
      INV_TRX_UTIL_PUB.trace('TQty :' ||p_transaction_quantity || ':' ,g_pkg_name,9);
      INV_TRX_UTIL_PUB.trace('PQty:' ||p_primary_quantity || ':' ,g_pkg_name,9);
   END IF;

   IF   (p_total_qty  IS NOT NULL)
   THEN
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.trace('p_split is <> nul',g_pkg_name,9);
       END IF;
       lot_split_data_insert.insert_mmtt(p_total_qty,
                                         p_transaction_type_id,
                                         p_userid,
                                         x_return_status);
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.trace('after returning from insert_mmtt:Stat:' || x_return_status || ':',g_pkg_name,9);
       END IF;
       IF    (x_return_status =  FND_API.G_RET_STS_ERROR)
       THEN
           IF (l_debug = 1) THEN
              INV_TRX_UTIL_PUB.trace('FND_API.G_RET_STS_ERRO',g_pkg_name,9);
           END IF;
           RAISE FND_API.G_EXC_ERROR ;
       END IF;
       IF    (x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR)
       THEN
           IF (l_debug = 1) THEN
              INV_TRX_UTIL_PUB.trace('FND_API.G_RET_STS_UNEXPERRO',g_pkg_name,9);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF;
       x_header_id := tab_input(1).transaction_header_id;
        IF (l_debug = 1) THEN
           INV_TRX_UTIL_PUB.trace('Header: '|| x_header_id ,g_pkg_name,9);
        END IF;
       tab_index :=0;
       tab_input.delete;
   END IF;
   IF (l_debug = 1) THEN
      INV_TRX_UTIL_PUB.trace('mmtt over ' ,g_pkg_name,9);
   END IF;
   FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count             ,
                p_data                  =>      x_msg_data
        );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK ;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
            (p_encoded               =>      FND_API.G_FALSE,
             p_count                 =>      x_msg_count,
             p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.trace(x_msg_data || 'Close',g_pkg_name,9);
         END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
            (p_encoded               =>      FND_API.G_FALSE,
             p_count                 =>      x_msg_count,
             p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.trace(x_msg_data || 'Close',g_pkg_name,9);
         END IF;
   WHEN OTHERS
   THEN
         ROLLBACK ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
            (p_encoded               =>      FND_API.G_FALSE,
             p_count                 =>      x_msg_count,
             p_data                  =>      x_msg_data);
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.trace(x_msg_data || 'Close',g_pkg_name,9);
         END IF;
END set_table;
--
PROCEDURE  insert_data(p_ind                         IN     NUMBER,
                       p_ind_1st                     IN     NUMBER,
                       p_userid                      IN     NUMBER,
                       p_transaction_action_id       IN     NUMBER,
                       p_transaction_source_type_id  IN     NUMBER,
                       p_acct_period_id              IN     NUMBER,
                       p_parent_id                   IN     NUMBER,
                       p_dist_account_id             IN     NUMBER,
                       x_return_status               OUT    NOCOPY VARCHAR2)
IS
    l_msg_data   VARCHAR2(2000) := 'None..' ;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
    BEGIN
       l_msg_data := 'mtl_material_transactions_temp';
       INSERT
       INTO   mtl_material_transactions_temp
         (transaction_header_id
          ,transaction_temp_id
          ,transaction_mode
          ,lock_flag
          ,Process_flag
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          ,inventory_item_id
          ,revision
          ,organization_id
          ,subinventory_code
          ,locator_id
          ,transaction_quantity
          ,primary_quantity
          ,transaction_uom
          ,transaction_type_id
          ,transaction_action_id
          ,transaction_source_type_id
          ,transaction_date
          ,acct_period_id
          ,distribution_account_id
          ,item_description
          ,item_location_control_code
          ,item_restrict_subinv_code
          ,item_restrict_locators_code
          ,item_revision_qty_control_code
          ,item_primary_uom_code
          ,item_shelf_life_code
          ,item_shelf_life_days
          ,item_lot_control_code
          ,item_serial_control_code
          ,allowed_units_lookup_code
          ,parent_transaction_temp_id
          ,lpn_id
          ,transfer_lpn_id
          ,cost_group_id
          ,project_id
          ,task_id
          ,transaction_batch_id
          ,transaction_batch_seq
          ,secondary_transaction_quantity   -- Bug #4093379 INVCONV
          ,secondary_uom_code)              -- Bug #4093379 INVCONV
     VALUES
         ( tab_input(p_ind).transaction_header_id
          ,tab_input(p_ind).transaction_temp_id
          ,3
          ,'N'
          ,'Y'
          ,SYSDATE
          ,p_userid
          ,SYSDATE
          ,p_userid
          ,p_userid
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,tab_input(p_ind).inventory_item_id
          ,tab_input(p_ind).revision
          ,tab_input(p_ind).organization_id
          ,tab_input(p_ind).subinventory_code
          ,tab_input(p_ind).locator_id
          ,tab_input(p_ind).transaction_quantity
          ,tab_input(p_ind).primary_quantity
          ,tab_input(p_ind).transaction_uom
          ,tab_input(p_ind).transaction_type_id
          ,p_transaction_action_id
          ,p_transaction_source_type_id
          ,SYSDATE
          ,p_acct_period_id
          ,p_dist_account_id
          ,tab_input(p_ind_1st).item_description
          ,tab_input(p_ind_1st).item_location_control_code
          ,tab_input(p_ind_1st).item_restrict_subinv_code
          ,tab_input(p_ind_1st).item_restrict_locators_code
          ,tab_input(p_ind_1st).item_revision_qty_control_code
          ,tab_input(p_ind_1st).item_primary_uom_code
          ,tab_input(p_ind_1st).item_shelf_life_code
          ,tab_input(p_ind_1st).item_shelf_life_days
          ,2
          ,1
          ,tab_input(p_ind_1st).allowed_units_lookup_code
          ,p_parent_id
          ,tab_input(p_ind).lpn_id
          ,tab_input(p_ind).xfr_lpn_id
	  ,tab_input(p_ind).cost_group_id
          ,tab_input(p_ind).project_id
          ,tab_input(p_ind).task_id
          ,tab_input(p_ind).transaction_batch_id
          ,tab_input(p_ind).transaction_batch_seq
          ,tab_input(p_ind).secondary_transaction_quantity  -- Bug #4093379 INVCONV
          ,tab_input(p_ind).item_secondary_uom_code); -- Bug #4093379 INVCONV
     IF (l_debug = 1) THEN
        INV_TRX_UTIL_PUB.trace('inserted mmtt ..' || p_ind,g_pkg_name,9);
     END IF;

      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.trace('inserting mtlt ' || p_ind,g_pkg_name,9);
      END IF;
       l_msg_data := 'mtl_transaction_lots_temp ';

        INSERT  INTO
        mtl_transaction_lots_temp
           (transaction_temp_id
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,request_id
            ,program_application_id
            ,program_id
            ,program_update_date
            ,transaction_quantity
            ,primary_quantity
            ,secondary_quantity   -- Bug #40993379 INVCONV
            ,lot_number
            ,lot_expiration_date
            ,description
            ,vendor_id
            ,supplier_lot_number
            ,territory_code
            ,grade_code
            ,origination_date
            ,date_code
            ,status_id
            ,change_date
            ,age
            ,retest_date
            ,maturity_date
            ,lot_attribute_category
            ,item_size
            ,color
            ,volume
            ,volume_uom
            ,place_of_origin
            ,best_by_date
            ,length
            ,length_uom
            ,recycled_content
            ,thickness
            ,thickness_uom
            ,width
            ,width_uom
            ,curl_wrinkle_fold
            ,c_attribute1
            ,c_attribute2
            ,c_attribute3
            ,c_attribute4
            ,c_attribute5
            ,c_attribute6
            ,c_attribute7
            ,c_attribute8
            ,c_attribute9
            ,c_attribute10
            ,c_attribute11
            ,c_attribute12
            ,c_attribute13
            ,c_attribute14
            ,c_attribute15
            ,c_attribute16
            ,c_attribute17
            ,c_attribute18
            ,c_attribute19
            ,c_attribute20
            ,d_attribute1
            ,d_attribute2
            ,d_attribute3
            ,d_attribute4
            ,d_attribute5
            ,d_attribute6
            ,d_attribute7
            ,d_attribute8
            ,d_attribute9
            ,d_attribute10
            ,n_attribute1
            ,n_attribute2
            ,n_attribute3
            ,n_attribute4
            ,n_attribute5
            ,n_attribute6
            ,n_attribute7
            ,n_attribute8
            ,n_attribute9
            ,n_attribute10
            ,secondary_unit_of_measure  -- Bug #4093379 INVCONV
            ,parent_lot_number          -- Bug #4093379 INVCONV
            ,origination_type           -- Bug #4093379 INVCONV
            ,expiration_action_date     -- Bug #4093379 INVCONV
            ,expiration_action_code     -- Bug #4093379 INVCONV
            ,hold_date                  -- Bug #4093379 INVCONV
            ,reason_id)                 -- Bug #4093379 INVCONV
        VALUES
           ( tab_input(p_ind).transaction_temp_id
            ,SYSDATE
            ,p_userid
            ,SYSDATE
            ,p_userid
            ,p_userid
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,abs(tab_input(p_ind).transaction_quantity)
            ,abs(tab_input(p_ind).primary_quantity)
            ,abs(tab_input(p_ind).secondary_transaction_quantity) -- Bug #4093379 INVCONV
            ,tab_input(p_ind).lot_number
            ,tab_input(p_ind).lot_expiration_date
            ,tab_input(p_ind).description
            ,tab_input(p_ind).vendor_id
            ,tab_input(p_ind).supplier_lot_number
            ,tab_input(p_ind).territory_code
            ,tab_input(p_ind).grade_code
            ,tab_input(p_ind).origination_date
            ,tab_input(p_ind).date_code
            ,tab_input(p_ind).status_id
            ,tab_input(p_ind).change_date
            ,tab_input(p_ind).age
            ,tab_input(p_ind).retest_date
            ,tab_input(p_ind).maturity_date
            ,tab_input(p_ind).lot_attribute_category
            ,tab_input(p_ind).item_size
            ,tab_input(p_ind).color
            ,tab_input(p_ind).volume
            ,tab_input(p_ind).volume_uom
            ,tab_input(p_ind).place_of_origin
            ,tab_input(p_ind).best_by_date
            ,tab_input(p_ind).length
            ,tab_input(p_ind).length_uom
            ,tab_input(p_ind).recycled_content
            ,tab_input(p_ind).thickness
            ,tab_input(p_ind).thickness_uom
            ,tab_input(p_ind).width
            ,tab_input(p_ind).width_uom
            ,tab_input(p_ind).curl_wrinkle_fold
            ,tab_input(p_ind).c_attribute1
            ,tab_input(p_ind).c_attribute2
            ,tab_input(p_ind).c_attribute3
            ,tab_input(p_ind).c_attribute4
            ,tab_input(p_ind).c_attribute5
            ,tab_input(p_ind).c_attribute6
            ,tab_input(p_ind).c_attribute7
            ,tab_input(p_ind).c_attribute8
            ,tab_input(p_ind).c_attribute9
            ,tab_input(p_ind).c_attribute10
            ,tab_input(p_ind).c_attribute11
            ,tab_input(p_ind).c_attribute12
            ,tab_input(p_ind).c_attribute13
            ,tab_input(p_ind).c_attribute14
            ,tab_input(p_ind).c_attribute15
            ,tab_input(p_ind).c_attribute16
            ,tab_input(p_ind).c_attribute17
            ,tab_input(p_ind).c_attribute18
            ,tab_input(p_ind).c_attribute19
            ,tab_input(p_ind).c_attribute20
            ,tab_input(p_ind).d_attribute1
            ,tab_input(p_ind).d_attribute2
            ,tab_input(p_ind).d_attribute3
            ,tab_input(p_ind).d_attribute4
            ,tab_input(p_ind).d_attribute5
            ,tab_input(p_ind).d_attribute6
            ,tab_input(p_ind).d_attribute7
            ,tab_input(p_ind).d_attribute8
            ,tab_input(p_ind).d_attribute9
            ,tab_input(p_ind).d_attribute10
            ,tab_input(p_ind).n_attribute1
            ,tab_input(p_ind).n_attribute2
            ,tab_input(p_ind).n_attribute3
            ,tab_input(p_ind).n_attribute4
            ,tab_input(p_ind).n_attribute5
            ,tab_input(p_ind).n_attribute6
            ,tab_input(p_ind).n_attribute7
            ,tab_input(p_ind).n_attribute8
            ,tab_input(p_ind).n_attribute9
            ,tab_input(p_ind).n_attribute10
            ,tab_input(p_ind).item_secondary_uom_code    -- Bug #4093379 INVCONV
            ,tab_input(p_ind).parent_lot_number          -- Bug #4093379 INVCONV
            ,tab_input(p_ind).origination_type           -- Bug #4093379 INVCONV
            ,tab_input(p_ind).expiration_action_date     -- Bug #4093379 INVCONV
            ,tab_input(p_ind).expiration_action_code     -- Bug #4093379 INVCONV
            ,tab_input(p_ind).hold_date                  -- Bug #4093379 INVCONV
            ,tab_input(p_ind).reason_id                  -- Bug #4093379 INVCONV
            );
        IF (l_debug = 1) THEN
           INV_TRX_UTIL_PUB.trace('inserted mtlt ' || p_ind,g_pkg_name,9);
        END IF;
   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR ;
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.trace( 'G_EXC_ERROR:INV_LOT_COMMIT_FAILURE ' || l_msg_data || ':' || sqlerrm,g_pkg_name,9);
         END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.trace( 'G_EXC_UNEXPECTED_ERROR:INV_LOT_COMMIT_FAILURE ' || l_msg_data || ':' || sqlerrm,g_pkg_name,9);
         END IF;
   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('INV', 'INV_LOT_COMMIT_FAILURE');
         -- INV_LOT_COMMIT_FAILURE: There has been a database insert error, please contact your dba or Oracle Support'
         FND_MSG_PUB.ADD;
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.trace( 'Other INV_LOT_COMMIT_FAILURE ' || l_msg_data || ':' || sqlerrm,g_pkg_name,9);
         END IF;
   END ;
END insert_data;

PROCEDURE  insert_mmtt(p_total_qty                   IN     NUMBER,
                       p_transaction_type_id         IN     NUMBER,
                       p_userid                      IN     NUMBER,
                       x_return_status               OUT    NOCOPY VARCHAR2)
IS
  ind                            INTEGER := 0;
  ind_1st                        INTEGER := 1;
  l_parent_id                    NUMBER  := 0;
  l_header_id                    NUMBER  := 0;
  l_temp_id                      NUMBER  := 0;
  l_batch_id                     NUMBER  := 0;
  l_transaction_action_id        NUMBER  := inv_globals.G_Action_inv_lot_split;
  l_transaction_source_type_id   NUMBER  := inv_globals.G_SourceType_Inventory;
  l_acct_period_id               org_acct_periods.acct_period_id%TYPE := 0;
  l_dist_account_id              mtl_parameters.distribution_account_id%TYPE := NULL;
  l_wsm_enabled_flag             mtl_parameters.wsm_enabled_flag%TYPE := 'N';
  l_xfr_lpn_id                   NUMBER  := NULL;
  l_msg_count                    NUMBER  := NULL;
  l_msg_data                     VARCHAR2(2000)   := NULL;
  l_label_status                 VARCHAR2(300)    := NULL;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      INV_TRX_UTIL_PUB.trace('in insert_mmtt',g_pkg_name,9);
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_msg_data      := 'select header_id from dual';
   SELECT mtl_material_transactions_s.NEXTVAL
   INTO   l_header_id
   FROM   DUAL;
   g_header_id := l_header_id;

   l_msg_data      := 'select batch_id from dual';
   SELECT mtl_material_transactions_s.NEXTVAL
   INTO   l_batch_id
   FROM   DUAL;

   l_msg_data      := 'select acct_period_id from org_acct_periods';

   BEGIN
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.trace('getting acct_period_id', g_pkg_name, 9);
      END IF;
      SELECT acct_period_id
      INTO   l_acct_period_id
      FROM   org_acct_periods
      WHERE  INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Sysdate,tab_input(1).organization_id)
                                          >= trunc(period_start_date )
      AND    INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Sysdate,tab_input(1).organization_id)
                                          <= trunc(schedule_close_date)
      AND    organization_id = tab_input(1).organization_id;


   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_NOOPEN_PERIOD_FOR_DATE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE1', SYSDATE);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.trace( 'INV_NOOPEN_PERIOD_FOR_DATE '
                                     || ':' || sqlerrm,g_pkg_name,9);
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.trace( 'Others:INV_NOOPEN_PERIOD_FOR_DATE '
                                     || ':' || sqlerrm,g_pkg_name,9);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END;

   /* For Lot Translate, need to get the distribution account id and populate
      into mmtt */
   IF (p_transaction_type_id = inv_globals.G_type_inv_lot_translate) THEN
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.trace('lot translate before getting dist acct', g_pkg_name, 9);
      END IF;
      BEGIN
         SELECT distribution_account_id,
                wsm_enabled_flag
         INTO l_dist_account_id,
              l_wsm_enabled_flag
         FROM mtl_parameters
         WHERE organization_id = tab_input(1).organization_id;

         IF (l_dist_account_id IS NULL AND l_wsm_enabled_flag = 'Y') THEN
              IF (l_debug = 1) THEN
                 INV_TRX_UTIL_PUB.trace('dist acct is null and wsm enabled = Y', g_pkg_name, 9);
              END IF;
              SELECT transaction_account_id
              INTO l_dist_account_id
              FROM wsm_parameters
              WHERE organization_id = tab_input(1).organization_id;
         END IF;

         IF (l_dist_account_id IS NULL) THEN
             FND_MESSAGE.SET_NAME('INV', 'INV_NO_DIST_ACCOUNT_ID');
             FND_MSG_PUB.ADD;
             IF (l_debug = 1) THEN
                INV_TRX_UTIL_PUB.trace('INV_NO_DIST_ACCOUNT_ID' || ':' || sqlerrm, g_pkg_name, 9);
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
         END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('INV', 'INV_NO_DIST_ACCOUNT_ID');
         FND_MSG_PUB.ADD;
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.trace('INV_NO_DIST_ACCOUNT_ID' || ':' || sqlerrm, g_pkg_name, 9);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('INV', 'INV_NO_DIST_ACCOUNT_ID');
         FND_MSG_PUB.ADD;
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.trace('INV_NO_DIST_ACCOUNT_ID' || ':' || sqlerrm, g_pkg_name, 9);
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

   END IF;

   l_msg_data      := 'if trx_type';
   IF   ( p_transaction_type_id = inv_globals.G_type_inv_lot_split)
   THEN
      tab_input(ind_1st).transaction_quantity := p_total_qty;
      l_transaction_action_id  := inv_globals.G_Action_inv_lot_split;
   ELSE
      IF ( p_transaction_type_id = inv_globals.G_type_inv_lot_merge)
      THEN
         l_transaction_action_id  := inv_globals.G_Action_inv_lot_merge;
      ELSE
         tab_input(ind_1st).transaction_quantity := p_total_qty;
         l_transaction_action_id  := inv_globals.G_Action_inv_lot_translate;
      END IF;
   END IF;
   -- populate transaction_temp_id in the table so that you know the parent id to
   -- be populated in all transactions in mmtt
   l_msg_data      := 'FOR  ind  IN  1..tab_index';
   FOR  ind  IN  1..tab_index
   LOOP
   l_msg_data      := 'Next temp_id ';
       SELECT mtl_material_transactions_s.NEXTVAL
       INTO   l_temp_id
       FROM   DUAL;

       tab_input(ind).transaction_temp_id            := l_temp_id;
       tab_input(ind).transaction_header_id          := l_header_id;
       tab_input(ind).transaction_batch_id           := l_batch_id;

       /* This condition will be true only for resulting lots where there is a scope for
          creating a new lpn */
       IF (tab_input(ind).lpn_number IS NOT NULL) AND
          (tab_input(ind).lpn_id IS NULL) AND
          (tab_input(ind).xfr_lpn_id IS NULL   OR
           tab_input(ind).xfr_lpn_id = 0 )            THEN
          BEGIN
             l_msg_data      := 'select lpn';
             SELECT lpn_id
             INTO   l_xfr_lpn_id
             FROM   wms_license_plate_numbers
             WHERE  license_plate_number = tab_input(ind).lpn_number
             AND    parent_lpn_id        IS NULL
             AND    lpn_context          IN (1,5); -- Bug No 3886482, Pick LPNS with status 'Defined But Not Used'

             IF (l_debug = 1) THEN
                INV_TRX_UTIL_PUB.trace('Lpn Found    for ' || tab_input(ind).lpn_number  ||
                                           ':Id:             ' || l_xfr_lpn_id,g_pkg_name,9);
             END IF;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                IF (l_debug = 1) THEN
                   INV_TRX_UTIL_PUB.trace('No Lpn Found for ' || tab_input(ind).lpn_number,g_pkg_name,9);
                END IF;
                l_msg_data      := l_msg_data || 'NO_DATA_FOUND: ' || sqlerrm;
                IF (l_debug = 1) THEN
                   INV_TRX_UTIL_PUB.trace('msg:' || l_msg_data,g_pkg_name,9);
                END IF;
                WMS_Container_PUB.Create_LPN
                    (  p_api_version            =>      1.0,
                       x_return_status          =>      x_return_status                 ,
                       x_msg_count              =>      l_msg_count                     ,
                       x_msg_data               =>      l_msg_data                      ,
                       p_lpn                    =>      tab_input(ind).lpn_number       ,
                       p_organization_id        =>      tab_input(ind).organization_id  ,
                       p_revision               =>      tab_input(ind).revision         ,
                       p_lot_number             =>      tab_input(ind).lot_number       ,
                       p_subinventory           =>      tab_input(ind).subinventory_code,
                       p_locator_id             =>      tab_input(ind).locator_id       ,
                       x_lpn_id                 =>      l_xfr_lpn_id);

               IF (l_debug = 1) THEN
                  INV_TRX_UTIL_PUB.trace('Generate_lpn for ' || tab_input(ind).lpn_number  ||
                                           ':Id:             ' || l_xfr_lpn_id ||
                                           'stat             ' || x_return_status ||
                                           'msgt             ' || l_msg_count ||
                                           'data             ' || l_msg_data,g_pkg_name,9);
               END IF;

                IF    (x_return_status =  FND_API.G_RET_STS_ERROR)
                THEN
                    IF (l_debug = 1) THEN
                       INV_TRX_UTIL_PUB.trace('FND_API.G_RET_STS_ERROR',g_pkg_name,9);
                    END IF;
                    FND_MESSAGE.SET_NAME('WMS', 'WMS_LPN_GENERATION_FAIL');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;
                IF    (x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR)
                THEN
                    FND_MESSAGE.SET_NAME('WMS', 'WMS_LPN_GENERATION_FAIL');
                    FND_MSG_PUB.ADD;
                    IF (l_debug = 1) THEN
                       INV_TRX_UTIL_PUB.trace('FND_API.G_RET_STS_UNEXPERROR',g_pkg_name,9);
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                END IF;

             WHEN OTHERS THEN
                IF (l_debug = 1) THEN
                   INV_TRX_UTIL_PUB.trace('No Lpn Found for ' || tab_input(ind).lpn_number,g_pkg_name,9);
                END IF;
                l_msg_data      := 'LPN not found: ' || sqlerrm;
                IF (l_debug = 1) THEN
                   INV_TRX_UTIL_PUB.trace(l_msg_data,g_pkg_name,9);
                END IF;
                FND_MESSAGE.SET_NAME('INV', 'INV_FIELD_INVALID');
                FND_MESSAGE.SET_TOKEN('ENTITY1', tab_input(ind).lpn_number);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR ;
                EXIT;
          END ;
       ELSE
          l_xfr_lpn_id  := tab_input(ind).xfr_lpn_id;
       END IF;

       tab_input(ind).xfr_lpn_id                         := l_xfr_lpn_id;

       IF     (tab_input(ind).transaction_lot = 'S'
          AND  (p_transaction_type_id = inv_globals.G_type_inv_lot_split OR p_transaction_type_id = inv_globals.G_type_inv_lot_translate))
       THEN
           l_parent_id := l_temp_id;
       ELSE
           IF     (tab_input(ind).transaction_lot = 'R'
              AND  p_transaction_type_id = inv_globals.G_type_inv_lot_merge)
           THEN
              l_parent_id := l_temp_id;
           END IF;
       END IF;

       IF  (tab_input(ind_1st).item_primary_uom_code <> tab_input(ind).transaction_uom)
       THEN
            tab_input(ind).primary_quantity  := inv_convert.inv_um_convert
                                                           (  tab_input(ind).inventory_item_id
                                                            , 5
                                                            , tab_input(ind).transaction_quantity
                                                            , tab_input(ind).transaction_uom
                                                            , tab_input(ind_1st).item_primary_uom_code
                                                            , null
                                                            , null);
       END IF;
       IF  (tab_input(ind).transaction_lot = 'S')
       THEN
            tab_input(ind).primary_quantity     := tab_input(ind).primary_quantity * -1;
            tab_input(ind).transaction_quantity := tab_input(ind).transaction_quantity * -1;
            tab_input(ind).secondary_transaction_quantity := tab_input(ind).secondary_transaction_quantity * -1; -- Bug #4093379 INVCONV
       END IF;

       IF (p_transaction_type_id = inv_globals.G_type_inv_lot_translate OR
           p_transaction_type_id = inv_globals.G_type_inv_lot_split) THEN
           SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
           INTO   tab_input(ind).transaction_batch_seq
           FROM   DUAL;
       END IF;

   END LOOP;

   IF ( p_transaction_type_id = inv_globals.G_type_inv_lot_merge) THEN
   FOR  ind  IN  REVERSE 1..tab_index
   LOOP
        SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
        INTO   tab_input(ind).transaction_batch_seq
        FROM   DUAL;
   END LOOP;
   END IF;

   IF   ( p_transaction_type_id = inv_globals.G_type_inv_lot_split OR p_transaction_type_id = inv_globals.G_type_inv_lot_translate)
   THEN
   FOR  ind  IN  1..tab_index
   LOOP
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.trace(ind || ': Header_id ' || tab_input(ind).transaction_header_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': Parent_id ' || l_parent_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': Temp_id ' || tab_input(ind).transaction_temp_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': Batch_id ' || tab_input(ind).transaction_batch_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': Batch_seq ' || tab_input(ind).transaction_batch_seq,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 1 ' || tab_input(ind).transaction_type_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 2 ' || tab_input(ind).transaction_lot    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 3 ' || tab_input(ind).inventory_item_id  ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 4 ' || tab_input(ind).revision           ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 5 ' || tab_input(ind).organization_id    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 6 ' || tab_input(ind).subinventory_code  ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 7 ' || tab_input(ind).locator_id         ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 8 ' || tab_input(ind).transaction_quantity,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 9 ' || tab_input(ind).primary_quantity    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 0 ' || tab_input(ind).transaction_uom     ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 1 ' || tab_input(ind).secondary_transaction_quantity ,g_pkg_name,9); -- Bug #4093379 INVCONV
       END IF;

       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.trace(ind || ': 1 ' || tab_input(ind_1st).item_description    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 2 ' || tab_input(ind_1st).item_location_control_code,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 3 ' || tab_input(ind_1st).item_restrict_subinv_code ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 4 ' || tab_input(ind_1st).item_restrict_locators_code,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 5 ' || tab_input(ind_1st).item_revision_qty_control_code,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 6 ' || tab_input(ind_1st).item_primary_uom_code        ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 7 ' || tab_input(ind_1st).item_shelf_life_code         ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 8 ' || tab_input(ind_1st).item_shelf_life_days         ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 9 ' || tab_input(ind_1st).allowed_units_lookup_code    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 0 ' || tab_input(ind).lot_number                   ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 1 ' || tab_input(ind).lot_expiration_date          ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 2 ' || p_total_qty,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 3 ' || tab_input(ind).lpn_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 4 ' || tab_input(ind).lpn_number ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 5 ' || tab_input(ind).item_secondary_uom_code      ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 6 ' || tab_input(ind).parent_lot_number            ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 7 ' || tab_input(ind).expiration_action_date       ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 8 ' || tab_input(ind).expiration_action_code       ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 9 ' || tab_input(ind).hold_date                    ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 0 ' || tab_input(ind).reason_id                    ,g_pkg_name,9); -- Bug #4093379 INVCONV
       END IF;

       insert_data (p_ind                         =>     ind,
                    p_ind_1st                     =>     ind_1st ,
                    p_userid                      =>     p_userid ,
                    p_transaction_action_id       =>     l_transaction_action_id ,
                    p_transaction_source_type_id  =>     l_transaction_source_type_id ,
                    p_acct_period_id              =>     l_acct_period_id  ,
                    p_parent_id                   =>     l_parent_id ,
                    p_dist_account_id             =>     l_dist_account_id,
                    x_return_status               =>     x_return_status);

        IF    (x_return_status =  FND_API.G_RET_STS_ERROR)
        THEN
            IF (l_debug = 1) THEN
               INV_TRX_UTIL_PUB.trace('Split..FND_API.G_RET_STS_ERROR',g_pkg_name,9);
            END IF;
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        IF    (x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR)
        THEN
            IF (l_debug = 1) THEN
               INV_TRX_UTIL_PUB.trace('Split..FND_API.G_RET_STS_UNEXPERROR',g_pkg_name,9);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;

   END LOOP;
   END IF;

   IF ( p_transaction_type_id = inv_globals.G_type_inv_lot_merge) THEN
   FOR  ind  IN  REVERSE 1..tab_index
   LOOP
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.trace(ind || ': Header_id ' || tab_input(ind).transaction_header_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': Parent_id ' || l_parent_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': Temp_id ' || tab_input(ind).transaction_temp_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': Batch_id ' || tab_input(ind).transaction_batch_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': Batch_seq ' || tab_input(ind).transaction_batch_seq,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 1 ' || tab_input(ind).transaction_type_id,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 2 ' || tab_input(ind).transaction_lot    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 3 ' || tab_input(ind).inventory_item_id  ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 4 ' || tab_input(ind).revision           ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 5 ' || tab_input(ind).organization_id    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 6 ' || tab_input(ind).subinventory_code  ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 7 ' || tab_input(ind).locator_id         ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 8 ' || tab_input(ind).transaction_quantity,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 9 ' || tab_input(ind).primary_quantity    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 0 ' || tab_input(ind).transaction_uom     ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 1 ' || tab_input(ind).secondary_transaction_quantity ,g_pkg_name,9); -- Bug #4093379 INVCONV
       END IF;

       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.trace(ind || ': 1 ' || tab_input(ind_1st).item_description    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 2 ' || tab_input(ind_1st).item_location_control_code,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 3 ' || tab_input(ind_1st).item_restrict_subinv_code ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 4 ' || tab_input(ind_1st).item_restrict_locators_code,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 5 ' || tab_input(ind_1st).item_revision_qty_control_code,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 6 ' || tab_input(ind_1st).item_primary_uom_code        ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 7 ' || tab_input(ind_1st).item_shelf_life_code         ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 8 ' || tab_input(ind_1st).item_shelf_life_days         ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 9 ' || tab_input(ind_1st).allowed_units_lookup_code    ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 0 ' || tab_input(ind).lot_number                   ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 1 ' || tab_input(ind).lot_expiration_date          ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 2 ' || p_total_qty,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 3 ' || tab_input(ind).lpn_id                   ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 4 ' || tab_input(ind).lpn_number               ,g_pkg_name,9);
          INV_TRX_UTIL_PUB.trace(ind || ': 5 ' || tab_input(ind).item_secondary_uom_code      ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 6 ' || tab_input(ind).parent_lot_number            ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 7 ' || tab_input(ind).expiration_action_date       ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 8 ' || tab_input(ind).expiration_action_code       ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 9 ' || tab_input(ind).hold_date                    ,g_pkg_name,9); -- Bug #4093379 INVCONV
          INV_TRX_UTIL_PUB.trace(ind || ': 0 ' || tab_input(ind).reason_id                    ,g_pkg_name,9); -- Bug #4093379 INVCONV
       END IF;

       insert_data (p_ind                         =>     ind,
                    p_ind_1st                     =>     ind_1st ,
                    p_userid                      =>     p_userid ,
                    p_transaction_action_id       =>     l_transaction_action_id ,
                    p_transaction_source_type_id  =>     l_transaction_source_type_id ,
                    p_acct_period_id              =>     l_acct_period_id  ,
                    p_parent_id                   =>     l_parent_id ,
                    p_dist_account_id             =>     l_dist_account_id,
                    x_return_status               =>     x_return_status);

        IF    (x_return_status =  FND_API.G_RET_STS_ERROR)
        THEN
            IF (l_debug = 1) THEN
               INV_TRX_UTIL_PUB.trace('Merge..FND_API.G_RET_STS_ERROR',g_pkg_name,9);
               INV_TRX_UTIL_PUB.trace('x_msg_data:x_label_status:'|| l_msg_data      || ':'
                                                               || l_label_status  || ':' ,g_pkg_name,9);
            END IF;
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        IF    (x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR)
        THEN
            IF (l_debug = 1) THEN
               INV_TRX_UTIL_PUB.trace('Merge..FND_API.G_RET_STS_UNEXPERROR',g_pkg_name,9);
               INV_TRX_UTIL_PUB.trace('x_msg_data:x_label_status:'|| l_msg_data      || ':'
                                                               || l_label_status  || ':' ,g_pkg_name,9);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;

   END LOOP;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.trace('insert_mmtt:G_EXC_ERROR: ' || sqlerrm ,g_pkg_name,9);
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.trace('insert_mmtt:G_EXC_UNEXPECTED_ERROR: ' || sqlerrm ,g_pkg_name,9);
      END IF;
   WHEN OTHERS
   THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.trace('FND_API.G_RET_STS_UNEXP_ERROR; outer most  others' || sqlerrm,g_pkg_name,9);
         INV_TRX_UTIL_PUB.trace('other outer most...file closed' ,g_pkg_name,9);
         INV_TRX_UTIL_PUB.trace(l_msg_data,g_pkg_name,9);
      END IF;
END   insert_mmtt;
--
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
  )

IS
l_transaction_type_id    MTL_TRANSACTION_TYPES.transaction_type_id%TYPE;
CURSOR cur_trx_types IS
     SELECT transaction_type_name , transaction_type_id
     FROM   mtl_transaction_types
     WHERE  transaction_type_id IN  ( INV_Globals.G_type_inv_lot_split,
                                      INV_Globals.G_type_inv_lot_merge,
                                      INV_Globals.G_type_inv_lot_translate);
               -- (82, 83, 84);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status        := FND_API.G_RET_STS_SUCCESS;
   x_wmsinstall           := 'N';
   x_wmsorg               := 'N';
   x_split_txnname        := '';
   x_merge_txnname        := '';
   x_stock_locator_code   := '';
   x_wsm_enabled_flag     := 'N';
   l_transaction_type_id  := '';

   BEGIN
      FOR rec_trx_types  IN cur_trx_types
      LOOP
         IF (rec_trx_types.transaction_type_id = 82) THEN
             x_split_txnname := rec_trx_types.transaction_type_name;
         ELSE IF (rec_trx_types.transaction_type_id = 83) THEN
             x_merge_txnname := rec_trx_types.transaction_type_name;
         ELSE
             x_translate_txnname := rec_trx_types.transaction_type_name;
              END IF;
         END IF;
      END LOOP;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_TRANSACTION_TYPE_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY1', INV_Globals.G_type_inv_lot_split || ',' ||
                                       INV_Globals.G_type_inv_lot_merge || ',' ||
                                       INV_Globals.G_type_inv_lot_translate);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR ;

   END;

   BEGIN
      SELECT stock_locator_control_code
	,default_cost_group_id
	,primary_cost_method
	,wsm_enabled_flag
	,distribution_account_id
	INTO   x_stock_locator_code
	,x_cost_group_id
	,x_primary_cost_method
	,x_wsm_enabled_flag
	, x_dist_account_id
	FROM   mtl_parameters
	WHERE  organization_id = p_organization_id;

     IF (x_dist_account_id IS NULL AND x_wsm_enabled_flag = 'Y') THEN
        IF (l_debug = 1) THEN
           INV_TRX_UTIL_PUB.trace('dist acct is null and wsm enabled = Y', g_pkg_name, 9);
        END IF;
        SELECT NVL(transaction_account_id, 0)
        INTO   x_dist_account_id
        FROM   wsm_parameters
        WHERE  organization_id = p_organization_id;
     END IF;

     IF (l_debug = 1) THEN
        INV_TRX_UTIL_PUB.trace('dist acct = ' || x_dist_account_id, g_pkg_name, 9);
     END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_NO_LOCATOR_CONTROL_ORG');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR ;
      WHEN OTHERS THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_NO_LOCATOR_CONTROL_ORG');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END;

     -- Check if the WMS is installed ?
   BEGIN
     INV_TXN_VALIDATIONS.CHECK_WMS_INSTALL  (
                               x_return_status            =>  x_wmsinstall,
                               p_msg_count                =>  x_msg_count,
                               p_msg_data                 =>  x_msg_data,
                               p_org                      =>  NULL) ;

   EXCEPTION
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_INSTALL_CHK_ERROR');
--    WMS_INSTALL_CHK_ERROR : Error determining if WMS is Installed
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END;

     -- Check if the organization is a WMS organization ?
   BEGIN
     INV_TXN_VALIDATIONS.CHECK_WMS_INSTALL  (
                               x_return_status            =>  x_wmsorg,
                               p_msg_count                =>  x_msg_count,
                               p_msg_data                 =>  x_msg_data,
                               p_org                      =>  p_organization_id);

   EXCEPTION
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_WMS_ORG');
--    INV_WMS_ORG: Error Determining if Organization is WMS enabled
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END;

   x_return_status        := FND_API.G_RET_STS_SUCCESS;
   FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count             ,
                p_data                  =>      x_msg_data
        );
   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
            (p_encoded               =>      FND_API.G_FALSE,
             p_count                 =>      x_msg_count,
             p_data                  =>      x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
            (p_encoded               =>      FND_API.G_FALSE,
             p_count                 =>      x_msg_count,
             p_data                  =>      x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
            (p_encoded               =>      FND_API.G_FALSE,
             p_count                 =>      x_msg_count,
             p_data                  =>      x_msg_data);

END select_init_parameters;

--
END lot_split_data_insert;


/
