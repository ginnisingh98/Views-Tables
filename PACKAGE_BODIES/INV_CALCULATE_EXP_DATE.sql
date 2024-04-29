--------------------------------------------------------
--  DDL for Package Body INV_CALCULATE_EXP_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CALCULATE_EXP_DATE" AS
/* $Header: INVCEDTB.pls 120.4.12010000.2 2009/12/24 19:28:48 musinha ship $ */

   g_pkg_name    VARCHAR2(80) := 'INV_CALCULATE_EXP_DATE';
   l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

   PROCEDURE mydebug( p_msg        IN        VARCHAR2
                     ,p_module     IN        VARCHAR2 DEFAULT NULL)
   IS
   BEGIN

     IF (l_debug = 1) THEN
        inv_log_util.trace( p_message => p_msg,
        p_module  => g_pkg_name ||'.'||p_module ,
        p_level => 9);
     END IF;

   --dbms_output.put_line( p_msg );
   END mydebug;

   -- Function used to get the transaciton id for row inserted in MTI and MMTT
   FUNCTION get_txn_id  ( p_table IN NUMBER) RETURN NUMBER IS
   BEGIN
      IF p_table = 1 THEN
         IF g_mti_txn_id IS NOT NULL THEN
            RETURN g_mti_txn_id;
         ELSE
            RETURN -1;
         END IF;
      ELSE
         IF g_mmtt_txn_id IS NOT NULL THEN
            RETURN g_mmtt_txn_id;
         ELSE
            RETURN -1;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
            mydebug('WHEN OTHERS exception : '||SQLERRM, 'GET_TXN_ID');
         END IF;
         RETURN -1;
   END get_txn_id;

   -- Function used to get the transaciton id for row inserted in MTLI and MTLT
   FUNCTION get_lot_txn_id ( p_table IN NUMBER) RETURN ROWID IS
   BEGIN
      IF p_table = 1 THEN
         IF g_mtli_txn_id IS NOT NULL THEN
            RETURN g_mtli_txn_id;
         ELSE
            RETURN '-1';
         END IF;
      ELSE
         IF g_mtlt_txn_id IS NOT NULL THEN
            RETURN g_mtlt_txn_id;
         ELSE
            RETURN '-1';
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
            mydebug('WHEN OTHERS exception : '||SQLERRM, 'GET_TXN_ID');
         END IF;
         RETURN '-1';
   END get_lot_txn_id;

   -- Function used to set the transaciton id for row inserted in MTI and MMTT
   PROCEDURE set_txn_id  ( p_table         IN      NUMBER,
                           p_header_id     IN      NUMBER) IS
   BEGIN
      IF p_table = 1 THEN
         g_mti_txn_id := p_header_id;
      ELSE
         g_mmtt_txn_id := p_header_id;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN NULL;
   END set_txn_id;

   -- Function used to set the transaciton id for row inserted in MTLI and MTLT
   PROCEDURE set_lot_txn_id  ( p_table             IN      NUMBER,
                               p_header_id         IN      ROWID) IS
   BEGIN
      IF p_table = 1 THEN
         g_mtli_txn_id := p_header_id;
      ELSE
         g_mtlt_txn_id := p_header_id;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN NULL;
   END set_lot_txn_id;

   -- Function used to reset all transaciton id for rows inserted in MTI, MMTT, MTLI and MTLT
   PROCEDURE reset_header_id IS
   BEGIN
      g_mti_txn_id := -1;
      g_mtli_txn_id := '-1';
      g_mmtt_txn_id := -1;
      g_mtlt_txn_id := '-1';
   END reset_header_id;

   -- Function used to populate MTI record. Data stored in this table can be used during Custom Lot Expiration Calc.
   PROCEDURE assign_mti_rec (
                     p_inventory_item_id           IN NUMBER
                   , p_revision                    IN VARCHAR2
                   , p_organization_id             IN NUMBER
                   , p_transaction_action_id       IN NUMBER
                   , p_subinventory_code           IN VARCHAR2
                   , p_locator_id                  IN NUMBER
                   , p_transaction_type_id         IN NUMBER
                   , p_trx_source_type_id          IN NUMBER
                   , p_transaction_quantity        IN NUMBER
                   , p_primary_quantity            IN NUMBER
                   , p_transaction_uom             IN VARCHAR2
                   , p_ship_to_location            IN NUMBER
                   , p_reason_id                   IN NUMBER
                   , p_user_id                     IN NUMBER
                   , p_transfer_lpn_id             IN NUMBER
                   , p_transaction_source_id       IN NUMBER
                   , p_trx_source_line_id          IN NUMBER
                   , p_project_id                  IN NUMBER
                   , p_task_id                     IN NUMBER
                   , p_planning_organization_id    IN NUMBER
                   , p_planning_tp_type            IN NUMBER
                   , p_owning_organization_id      IN NUMBER
                   , p_owning_tp_type              IN NUMBER
                   , p_distribution_account_id     IN NUMBER
                   , p_sec_transaction_quantity    IN NUMBER
                   , p_secondary_uom_code          IN VARCHAR2
                   , x_return_status               OUT NOCOPY VARCHAR2
                   ) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF g_mti_tbl.COUNT > 0 THEN
         g_mti_tbl.DELETE;
      END IF;

      g_mti_tbl(0).inventory_item_id      := p_inventory_item_id;
      g_mti_tbl(0).revision               := p_revision;
      g_mti_tbl(0).organization_id        := p_organization_id;
      g_mti_tbl(0).transaction_action_id  := p_transaction_action_id;
      g_mti_tbl(0).subinventory_code      := p_subinventory_code;
      g_mti_tbl(0).locator_id             := p_locator_id;
      g_mti_tbl(0).transaction_type_id    := p_transaction_type_id;
      g_mti_tbl(0).transaction_source_type_id     := p_trx_source_type_id;
      g_mti_tbl(0).transaction_quantity   := p_transaction_quantity;
      g_mti_tbl(0).primary_quantity       := p_primary_quantity;
      g_mti_tbl(0).transaction_uom        := p_transaction_uom;
      g_mti_tbl(0).ship_to_location_id    := p_ship_to_location;
      g_mti_tbl(0).reason_id              := p_reason_id;
      g_mti_tbl(0).transfer_lpn_id        := p_transfer_lpn_id;
      g_mti_tbl(0).transaction_source_id  := p_transaction_source_id;
      g_mti_tbl(0).trx_source_line_id     := p_trx_source_line_id;
      g_mti_tbl(0).project_id             := p_project_id;
      g_mti_tbl(0).task_id                := p_task_id;
      g_mti_tbl(0).planning_organization_id := p_planning_organization_id;
      g_mti_tbl(0).planning_tp_type       := p_planning_tp_type;
      g_mti_tbl(0).owning_organization_id := p_owning_organization_id;
      g_mti_tbl(0).owning_tp_type         := p_owning_tp_type;
      g_mti_tbl(0).distribution_account_id := p_distribution_account_id;
      g_mti_tbl(0).secondary_transaction_quantity := p_sec_transaction_quantity;
      g_mti_tbl(0).secondary_uom_code := p_secondary_uom_code;

   EXCEPTION
      WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 1) THEN
         mydebug('WHEN OTHERS exception : '||SQLERRM, 'GET_TXN_ID');
      END IF;
   END assign_mti_rec;

   -- Function used to get populated MTI table populated by assign_mti_rec Procedure.
   FUNCTION get_mti_tbl RETURN mti_tab IS
   BEGIN
      RETURN g_mti_tbl;
   END get_mti_tbl;

   -- Function used to purge populated MTI table populated by assign_mti_rec Procedure.
   PROCEDURE purge_mti_tab IS
   BEGIN
      IF g_mti_tbl.COUNT > 0 THEN
         g_mti_tbl.DELETE;
      END IF;
   END purge_mti_tab;

   -- Function used to populate MMTT record. Data stored in this table can be used during Custom Lot Expiration Calc.
   PROCEDURE assign_mmtt_rec (
                     p_inventory_item_id           IN NUMBER
                   , p_revision                    IN VARCHAR2
                   , p_organization_id             IN NUMBER
                   , p_transaction_action_id       IN NUMBER
                   , p_subinventory_code           IN VARCHAR2
                   , p_locator_id                  IN NUMBER
                   , p_transaction_type_id         IN NUMBER
                   , p_trx_source_type_id          IN NUMBER
                   , p_transaction_quantity        IN NUMBER
                   , p_primary_quantity            IN NUMBER
                   , p_transaction_uom             IN VARCHAR2
                   , p_ship_to_location            IN NUMBER
                   , p_reason_id                   IN NUMBER
                   , p_user_id                     IN NUMBER
                   , p_transfer_lpn_id             IN NUMBER
                   , p_transaction_source_id       IN NUMBER
                   , p_transaction_cost            IN NUMBER
                   , p_project_id                  IN NUMBER
                   , p_task_id                     IN NUMBER
                   , p_planning_organization_id    IN NUMBER
                   , p_planning_tp_type            IN NUMBER
                   , p_owning_organization_id      IN NUMBER
                   , p_owning_tp_type              IN NUMBER
                   , p_distribution_account_id     IN NUMBER
                   , p_sec_transaction_quantity    IN NUMBER
                   , p_secondary_uom_code          IN VARCHAR2
                   , x_return_status               OUT NOCOPY VARCHAR2
                   ) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF g_mmtt_tbl.COUNT > 0 THEN
         g_mmtt_tbl.DELETE;
      END IF;

      g_mmtt_tbl(0).inventory_item_id      := p_inventory_item_id;
      g_mmtt_tbl(0).revision               := p_revision;
      g_mmtt_tbl(0).organization_id        := p_organization_id;
      g_mmtt_tbl(0).transaction_action_id  := p_transaction_action_id;
      g_mmtt_tbl(0).subinventory_code      := p_subinventory_code;
      g_mmtt_tbl(0).locator_id             := p_locator_id;
      g_mmtt_tbl(0).transaction_type_id    := p_transaction_type_id;
      g_mmtt_tbl(0).transaction_source_type_id     := p_trx_source_type_id;
      g_mmtt_tbl(0).transaction_quantity   := p_transaction_quantity;
      g_mmtt_tbl(0).primary_quantity       := p_primary_quantity;
      g_mmtt_tbl(0).transaction_uom        := p_transaction_uom;
      g_mmtt_tbl(0).ship_to_location       := p_ship_to_location;
      g_mmtt_tbl(0).reason_id              := p_reason_id;
      g_mmtt_tbl(0).transfer_lpn_id        := p_transfer_lpn_id;
      g_mmtt_tbl(0).transaction_source_id := p_transaction_source_id;
      g_mmtt_tbl(0).transaction_cost       := p_transaction_cost;
      g_mmtt_tbl(0).project_id             := p_project_id;
      g_mmtt_tbl(0).task_id                := p_task_id;
      g_mmtt_tbl(0).planning_organization_id := p_planning_organization_id;
      g_mmtt_tbl(0).planning_tp_type       := p_planning_tp_type;
      g_mmtt_tbl(0).owning_organization_id := p_owning_organization_id;
      g_mmtt_tbl(0).owning_tp_type         := p_owning_tp_type;
      g_mmtt_tbl(0).distribution_account_id := p_distribution_account_id;
      g_mmtt_tbl(0).secondary_transaction_quantity := p_sec_transaction_quantity;
      g_mmtt_tbl(0).secondary_uom_code := p_secondary_uom_code;

   EXCEPTION
      WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 1) THEN
         mydebug('WHEN OTHERS exception : '||SQLERRM, 'GET_TXN_ID');
      END IF;
   END assign_mmtt_rec;

   -- Function used to get populated MMTT table populated by assign_mmtt_rec Procedure.
   FUNCTION get_mmtt_tbl RETURN mmtt_tab IS
   BEGIN
      RETURN g_mmtt_tbl;
   END get_mmtt_tbl;

   -- Function used to purge populated MMTT table populated by assign_mmtt_rec Procedure.
   PROCEDURE purge_mmtt_tab IS
   BEGIN
      IF g_mmtt_tbl.COUNT > 0 THEN
         g_mmtt_tbl.DELETE;
      END IF;
   END purge_mmtt_tab;

   -- Procedure to query the primary onhand qty of lot. If this is zero and origination date null,
   -- system will default the lot attributes and will update the lot record.
   PROCEDURE get_lot_primary_onhand
   (  p_inventory_item_id    IN NUMBER
     ,p_organization_id      IN NUMBER
     ,p_lot_number           IN VARCHAR2
     ,x_onhand               OUT NOCOPY NUMBER
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
   ) IS
      l_rqoh  NUMBER;
      l_qr    NUMBER;
      l_qs    NUMBER;
      l_att   NUMBER;
      l_atr   NUMBER;
      l_sqoh  NUMBER;
      l_satt  NUMBER;
      l_satr  NUMBER;
      l_srqoh NUMBER;
      l_sqr   NUMBER;
      l_sqs   NUMBER;
   BEGIN
      inv_quantity_tree_pub.query_quantities
      (
        p_api_version_number    =>   1.0
      , p_init_msg_lst          =>   'T'
      , x_return_status         =>   x_return_status
      , x_msg_count             =>   x_msg_count
      , x_msg_data              =>   x_msg_data
      , p_organization_id       =>   p_organization_id
      , p_inventory_item_id     =>   p_inventory_item_id
      , p_tree_mode             =>   1
      , p_is_revision_control   =>   FALSE
      , p_is_lot_control        =>   TRUE
      , p_is_serial_control     =>   FALSE
      , p_revision              =>   NULL
      , p_lot_number            =>   p_lot_number
      , p_subinventory_code     =>   NULL
      , p_locator_id            =>   NULL
      , p_onhand_source         =>   3
      , x_qoh                   =>   x_onhand
      , x_rqoh                  =>   l_rqoh
      , x_qr                    =>   l_qr
      , x_qs                    =>   l_qs
      , x_att                   =>   l_att
      , x_atr                   =>   l_atr
      , p_grade_code            =>   NULL
      , x_sqoh                  =>   l_sqoh
      , x_satt                  =>   l_satt
      , x_satr                  =>   l_satr
      , x_srqoh                 =>   l_srqoh
      , x_sqr                   =>   l_sqr
      , x_sqs                   =>   l_sqs
      , p_lpn_id                =>   NULL
      );
   END get_lot_primary_onhand;

   -- Procedure to query the origination date of lot. If this is null and primary qty zero,
   -- system will default the lot attributes and will update the lot record.
   PROCEDURE get_origination_date
   (  p_inventory_item_id    IN NUMBER
     ,p_organization_id      IN NUMBER
     ,p_lot_number           IN VARCHAR2
     ,x_orig_date            OUT NOCOPY DATE
     ,x_return_status        OUT NOCOPY VARCHAR2
   ) IS
   orig_date DATE;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      BEGIN                                                                                                                 /*begin segment 2 */
         SELECT origination_date
           INTO x_orig_date
           FROM mtl_lot_numbers
          WHERE inventory_item_id = p_inventory_item_id
           AND lot_number = p_lot_number
           AND organization_id = p_organization_id;
      EXCEPTION
         WHEN no_data_found THEN
            BEGIN                                                                                                            /*begin segment 3*/
               SELECT a.origination_date
                 INTO x_orig_date
                 FROM mtl_transaction_lots_temp a
                    , mtl_material_transactions_temp b
                WHERE b.inventory_item_id = p_inventory_item_id
                  AND a.lot_number = p_lot_number
                  AND a.transaction_temp_id = b.transaction_temp_id
                  AND ROWNUM = 1
                  AND b.organization_id = p_organization_id;
            EXCEPTION
               WHEN OTHERS THEN
                  x_orig_date := NULL;
            END;
         WHEN OTHERS THEN
            x_orig_date := NULL;
      END;
   EXCEPTION
      WHEN OTHERS THEN
         x_orig_date := NULL;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END get_origination_date;

   -- bug#6073680 START
   -- Procedure to determine if lot is an existing lot.

   PROCEDURE check_lot_exists
   (  p_inventory_item_id    IN NUMBER
     ,p_organization_id      IN NUMBER
     ,p_lot_number           IN VARCHAR2
     ,x_lot_exist            OUT NOCOPY VARCHAR2
     ,x_return_status        OUT NOCOPY VARCHAR2
   ) IS
   l_lot_exists NUMBER;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_lot_exists := 0;
      x_lot_exist := 'FALSE';
      BEGIN                                                                                                                 /*begin segment 2 */
         SELECT 1
           INTO l_lot_exists
           FROM mtl_lot_numbers
          WHERE inventory_item_id = p_inventory_item_id
           AND lot_number = p_lot_number
           AND organization_id = p_organization_id;
      EXCEPTION
         WHEN no_data_found THEN
            l_lot_exists := 0;
      END;
      IF l_lot_exists = 1 THEN
         x_lot_exist := 'TRUE';
      ELSE
         x_lot_exist := 'FALSE';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_lot_exist := 'FALSE';
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END check_lot_exists;
   -- bug#6073680 END

   -- Procedure to return the lot expiration date. This will call the custom lot expiration code.
   -- If custom lot expiration code returns null, this procedure will return expiration date by
   -- adding shelf life days to transaction date.
   PROCEDURE get_lot_expiration_date
     ( p_mtli_lot_rec         IN  MTL_TRANSACTION_LOTS_INTERFACE%ROWTYPE
      ,p_mti_trx_rec          IN  MTL_TRANSACTIONS_INTERFACE%ROWTYPE
      ,p_mtlt_lot_rec         IN  MTL_TRANSACTION_LOTS_TEMP%ROWTYPE
      ,p_mmtt_trx_rec         IN  MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
      ,p_table                IN  NUMBER
      ,x_lot_expiration_date  OUT NOCOPY DATE
      ,x_return_status        OUT NOCOPY VARCHAR2
     ) IS
       l_shelf_life_code NUMBER;
       l_shelf_life_days NUMBER;
       l_inventory_item_id NUMBER;
       l_organization_id NUMBER;
       l_transaction_date DATE;
       l_transaction_action_id NUMBER; -- nsinghi bug#5209065 rework

        CURSOR Cur_item_dtl (c_inventory_item_id NUMBER, c_organization_id NUMBER) IS
        SELECT msi.shelf_life_code, msi.shelf_life_days
        FROM mtl_system_items msi
        WHERE msi.inventory_item_id = c_inventory_item_id
        AND    msi.organization_id = c_organization_id;
   BEGIN
      /* Initialize return status to success */
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ((p_table = 1 AND p_mti_trx_rec.inventory_item_id IS NOT NULL
                AND p_mti_trx_rec.organization_id IS NOT NULL)
         OR
         (p_table = 2 AND p_mmtt_trx_rec.inventory_item_id IS NOT NULL
                AND p_mmtt_trx_rec.organization_id IS NOT NULL)) THEN

         IF p_table = 1 THEN
            l_inventory_item_id := p_mti_trx_rec.inventory_item_id;
            l_organization_id := p_mti_trx_rec.organization_id;
            l_transaction_date := p_mti_trx_rec.transaction_date;
            l_transaction_action_id := p_mti_trx_rec.transaction_action_id; -- nsinghi bug#5209065 rework
         ELSE
            l_inventory_item_id := p_mmtt_trx_rec.inventory_item_id;
            l_organization_id := p_mmtt_trx_rec.organization_id;
            l_transaction_date := p_mmtt_trx_rec.transaction_date;
            l_transaction_action_id := p_mmtt_trx_rec.transaction_action_id; -- nsinghi bug#5209065 rework
         END IF;

         OPEN  Cur_item_dtl (l_inventory_item_id, l_organization_id);
         FETCH Cur_item_dtl INTO l_shelf_life_code, l_shelf_life_days;
         CLOSE Cur_item_dtl;
         /*
         IF (l_debug = 1 )THEN
            log_transaction_rec( p_mtli_lot_rec => p_mtli_lot_rec
                                ,p_mti_trx_rec => p_mti_trx_rec
                                ,p_mtlt_lot_rec => p_mtlt_lot_rec
                                ,p_mmtt_trx_rec => p_mmtt_trx_rec
                                ,p_table => p_table);
         END IF;
         */
         -- nsinghi bug#5209065 rework. Added the IF clause, as we need to call custom lot routine only for receipt transactions.
         IF NVL(l_transaction_action_id, -1) IN
                (       inv_globals.g_action_receipt
                        , inv_globals.g_action_assycomplete
                )
         THEN
                 inv_cust_calc_exp_date.get_custom_lot_expiration_date (
                                                  p_mtli_lot_rec        => p_mtli_lot_rec
                                                 ,p_mti_trx_rec         => p_mti_trx_rec
                                                 ,p_mtlt_lot_rec        => p_mtlt_lot_rec
                                                 ,p_mmtt_trx_rec        => p_mmtt_trx_rec
                                                 ,p_table               => p_table
                                                 ,x_lot_expiration_date => x_lot_expiration_date
                                                 ,x_return_status       => x_return_status);
         END IF;
         IF (x_lot_expiration_date IS NULL) THEN
           IF l_transaction_date IS NOT NULL THEN
              x_lot_expiration_date:=l_transaction_date+l_shelf_life_days;
           ELSE
              x_lot_expiration_date:=SYSDATE+l_shelf_life_days;
           END IF;
         END IF;
      ELSE
         x_lot_expiration_date:=SYSDATE+l_shelf_life_days;
      END IF;


   EXCEPTION
      WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 1) THEN
         mydebug('WHEN OTHERS exception : '||SQLERRM, 'GET_TXN_ID');
      END IF;
   END get_lot_expiration_date;

   -- Procedure to Update Inventory Lot. From MSCA, we cannot pass record type parameter. Hence all the parameters
   -- are passed to this API, which will inturn call the Public Update Inv Lot API.
   PROCEDURE update_inv_lot_attr(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_inventory_item_id      IN            NUMBER
  , p_organization_id        IN            NUMBER
  , p_lot_number             IN            VARCHAR2
  , p_source                 IN            NUMBER
  , p_expiration_date        IN            DATE DEFAULT NULL
  , p_grade_code             IN            VARCHAR2 DEFAULT NULL
  , p_origination_date       IN            DATE DEFAULT NULL
  , p_origination_type       IN            NUMBER DEFAULT NULL
  , p_status_id              IN            NUMBER DEFAULT NULL
  , p_retest_date            IN            DATE DEFAULT NULL
  , p_maturity_date          IN            DATE DEFAULT NULL
  , p_supplier_lot_number    IN            VARCHAR2 DEFAULT NULL
  , p_expiration_action_code IN            VARCHAR2 DEFAULT NULL
  , p_expiration_action_date IN            DATE DEFAULT NULL
  , p_hold_date              IN            DATE DEFAULT NULL
  , p_c_attribute1           IN            VARCHAR2 := NULL
  , p_c_attribute2           IN            VARCHAR2 := NULL
  , p_c_attribute3           IN            VARCHAR2 := NULL
  , p_c_attribute4           IN            VARCHAR2 := NULL
  , p_c_attribute5           IN            VARCHAR2 := NULL
  , p_c_attribute6           IN            VARCHAR2 := NULL
  , p_c_attribute7           IN            VARCHAR2 := NULL
  , p_c_attribute8           IN            VARCHAR2 := NULL
  , p_c_attribute9           IN            VARCHAR2 := NULL
  , p_c_attribute10          IN            VARCHAR2 := NULL
  , p_c_attribute11          IN            VARCHAR2 := NULL
  , p_c_attribute12          IN            VARCHAR2 := NULL
  , p_c_attribute13          IN            VARCHAR2 := NULL
  , p_c_attribute14          IN            VARCHAR2 := NULL
  , p_c_attribute15          IN            VARCHAR2 := NULL
  , p_c_attribute16          IN            VARCHAR2 := NULL
  , p_c_attribute17          IN            VARCHAR2 := NULL
  , p_c_attribute18          IN            VARCHAR2 := NULL
  , p_c_attribute19          IN            VARCHAR2 := NULL
  , p_c_attribute20          IN            VARCHAR2 := NULL
  , p_d_attribute1           IN            DATE := NULL
  , p_d_attribute2           IN            DATE := NULL
  , p_d_attribute3           IN            DATE := NULL
  , p_d_attribute4           IN            DATE := NULL
  , p_d_attribute5           IN            DATE := NULL
  , p_d_attribute6           IN            DATE := NULL
  , p_d_attribute7           IN            DATE := NULL
  , p_d_attribute8           IN            DATE := NULL
  , p_d_attribute9           IN            DATE := NULL
  , p_d_attribute10          IN            DATE := NULL
  , p_n_attribute1           IN            NUMBER := NULL
  , p_n_attribute2           IN            NUMBER := NULL
  , p_n_attribute3           IN            NUMBER := NULL
  , p_n_attribute4           IN            NUMBER := NULL
  , p_n_attribute5           IN            NUMBER := NULL
  , p_n_attribute6           IN            NUMBER := NULL
  , p_n_attribute7           IN            NUMBER := NULL
  , p_n_attribute8           IN            NUMBER := NULL
  , p_n_attribute9           IN            NUMBER := NULL
  , p_n_attribute10          IN            NUMBER := NULL
   -- bug#6073680 START. Added following parameters to handle WMS Attributes
  , p_description            IN            VARCHAR2 := NULL
  , p_vendor_name            IN            VARCHAR2 := NULL
  , p_date_code              IN            VARCHAR2 := NULL
  , p_change_date            IN            DATE := NULL
  , p_age                    IN            NUMBER := NULL
  , p_item_size              IN            NUMBER := NULL
  , p_color                  IN            VARCHAR2 := NULL
  , p_volume                 IN            NUMBER := NULL
  , p_volume_uom             IN            VARCHAR2 := NULL
  , p_place_of_origin        IN            VARCHAR2 := NULL
  , p_best_by_date           IN            DATE := NULL
  , p_length                 IN            NUMBER := NULL
  , p_length_uom             IN            VARCHAR2 := NULL
  , p_recycled_content       IN            NUMBER := NULL
  , p_thickness              IN            NUMBER := NULL
  , p_thickness_uom          IN            VARCHAR2 := NULL
  , p_width                  IN            NUMBER := NULL
  , p_width_uom              IN            VARCHAR2 := NULL
  , p_curl_wrinkle_fold      IN            VARCHAR2 := NULL
  , p_lot_attribute_category IN            VARCHAR2 := NULL
  , p_territory_code         IN            VARCHAR2 := NULL
  , p_vendor_id              IN            VARCHAR2 := NULL
  , p_parent_lot_number      IN            VARCHAR2 := NULL
   -- bug#6073680 END. Added following parameters to handle WMS Attributes
  ) IS
   l_in_lot_rec            MTL_LOT_NUMBERS%ROWTYPE;
   x_lot_rec               MTL_LOT_NUMBERS%ROWTYPE;
   l_api_version           NUMBER;
   l_init_msg_list         VARCHAR2(100);
   l_commit                VARCHAR2(100);
   l_return_status         VARCHAR2(1)  ;
   l_msg_data              VARCHAR2(3000)  ;
   l_msg_count             NUMBER    ;
   l_exc_error                    EXCEPTION;
   l_exc_unexpected_error         EXCEPTION;

  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /* Populating the variables and calling the overloaded API  */

     l_in_lot_rec.inventory_item_id             :=   p_inventory_item_id;
     l_in_lot_rec.organization_id               :=   p_organization_id;
     l_in_lot_rec.lot_number                    :=   p_lot_number;
     l_in_lot_rec.expiration_date               :=   p_expiration_date;
     l_in_lot_rec.grade_code                    :=   p_grade_code;
     l_in_lot_rec.origination_date              :=   p_origination_date;
     l_in_lot_rec.origination_type              :=   p_origination_type;
     l_in_lot_rec.status_id                     :=   p_status_id;
     l_in_lot_rec.retest_date                   :=   p_retest_date;
     l_in_lot_rec.maturity_date                 :=   p_maturity_date;
     l_in_lot_rec.supplier_lot_number           :=   p_supplier_lot_number;
     l_in_lot_rec.expiration_action_code        :=   p_expiration_action_code;
     l_in_lot_rec.expiration_action_date        :=   p_expiration_action_date;
     l_in_lot_rec.hold_date                     :=   p_hold_date;

     l_in_lot_rec.last_update_date              :=   SYSDATE ;
     l_in_lot_rec.last_updated_by               :=   FND_GLOBAL.USER_ID;
     l_in_lot_rec.last_update_login             :=   FND_GLOBAL.LOGIN_ID;

   -- bug#6073680 START. Added following parameters to handle WMS Attributes
     l_in_lot_rec.description                    := p_description;
     l_in_lot_rec.vendor_name                    := p_vendor_name;
     l_in_lot_rec.date_code                      := p_date_code;
     l_in_lot_rec.change_date                    := p_change_date;
     l_in_lot_rec.age                            := p_age;
     l_in_lot_rec.item_size                      := p_item_size;
     l_in_lot_rec.color                          := p_color;
     l_in_lot_rec.volume                         := p_volume;
     l_in_lot_rec.volume_uom                     := p_volume_uom;
     l_in_lot_rec.place_of_origin                := p_place_of_origin;
     l_in_lot_rec.best_by_date                   := p_best_by_date;
     l_in_lot_rec.length                         := p_length;
     l_in_lot_rec.length_uom                     := p_length_uom;
     l_in_lot_rec.recycled_content               := p_recycled_content;
     l_in_lot_rec.thickness                      := p_thickness;
     l_in_lot_rec.thickness_uom                  := p_thickness_uom;
     l_in_lot_rec.width                          := p_width;
     l_in_lot_rec.width_uom                      := p_width_uom;
     l_in_lot_rec.curl_wrinkle_fold              := p_curl_wrinkle_fold;
     l_in_lot_rec.lot_attribute_category         := p_lot_attribute_category;
     l_in_lot_rec.territory_code                 := p_territory_code;
     l_in_lot_rec.vendor_id                      := p_vendor_id;
     l_in_lot_rec.parent_lot_number              := p_parent_lot_number;
   -- bug#6073680 END.

     IF (p_c_attribute1 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute1                  :=   p_c_attribute1;
     END IF;
     IF (p_c_attribute2 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute2                  :=   p_c_attribute2;
     END IF;
     IF (p_c_attribute3 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute3                  :=   p_c_attribute3;
     END IF;
     IF (p_c_attribute4 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute4                  :=   p_c_attribute4;
     END IF;
     IF (p_c_attribute5 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute5                  :=   p_c_attribute5;
     END IF;
     IF (p_c_attribute6 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute6                  :=   p_c_attribute6;
     END IF;
     IF (p_c_attribute7 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute7                  :=   p_c_attribute7;
     END IF;
     IF (p_c_attribute8 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute8                  :=   p_c_attribute8;
     END IF;
     IF (p_c_attribute9 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute9                  :=   p_c_attribute9;
     END IF;
     IF (p_c_attribute10 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute10                 :=   p_c_attribute10;
     END IF;
     IF (p_c_attribute11 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute11                 :=   p_c_attribute11;
     END IF;
     IF (p_c_attribute12 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute12                 :=   p_c_attribute12;
     END IF;
     IF (p_c_attribute13 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute13                 :=   p_c_attribute13;
     END IF;
     IF (p_c_attribute14 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute14                 :=   p_c_attribute14;
     END IF;
     IF (p_c_attribute15 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute15                 :=   p_c_attribute15;
     END IF;
     IF (p_c_attribute16 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute16                 :=   p_c_attribute16;
     END IF;
     IF (p_c_attribute17 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute17                 :=   p_c_attribute17;
     END IF;
     IF (p_c_attribute18 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute18                 :=   p_c_attribute18;
     END IF;
     IF (p_c_attribute19 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute19                 :=   p_c_attribute19;
     END IF;
     IF (p_c_attribute20 IS NOT NULL) THEN
       l_in_lot_rec.c_attribute20                 :=   p_c_attribute20;
     END IF;
     IF (p_n_attribute1 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute1                  :=   p_n_attribute1;
     END IF;
     IF (p_n_attribute2 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute2                  :=   p_n_attribute2;
     END IF;
     IF (p_n_attribute3 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute3                  :=   p_n_attribute3;
     END IF;
     IF (p_n_attribute4 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute4                  :=   p_n_attribute4;
     END IF;
     IF (p_n_attribute5 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute5                  :=   p_n_attribute5;
     END IF;
     IF (p_n_attribute6 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute6                  :=   p_n_attribute6;
     END IF;
     IF (p_n_attribute7 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute7                  :=   p_n_attribute7;
     END IF;
     IF (p_n_attribute8 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute8                  :=   p_n_attribute8;
     END IF;
     IF (p_n_attribute9 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute9                  :=   p_n_attribute9;
     END IF;
     IF (p_n_attribute10 IS NOT NULL) THEN
       l_in_lot_rec.n_attribute10                 :=   p_n_attribute10;
     END IF;
     IF (p_d_attribute1 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute1                  :=   p_d_attribute1;
     END IF;
     IF (p_d_attribute2 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute2                  :=   p_d_attribute2;
     END IF;
     IF (p_d_attribute3 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute3                  :=   p_d_attribute3;
     END IF;
     IF (p_d_attribute4 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute4                  :=   p_d_attribute4;
     END IF;
     IF (p_d_attribute5 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute5                  :=   p_d_attribute5;
     END IF;
     IF (p_d_attribute6 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute6                  :=   p_d_attribute6;
     END IF;
     IF (p_d_attribute7 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute7                  :=   p_d_attribute7;
     END IF;
     IF (p_d_attribute8 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute8                  :=   p_d_attribute8;
     END IF;
     IF (p_d_attribute9 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute9                  :=   p_d_attribute9;
     END IF;
     IF (p_d_attribute10 IS NOT NULL) THEN
       l_in_lot_rec.d_attribute10                 :=   p_d_attribute10;
     END IF;
     --END BUG 4748451
     l_api_version                              :=   1.0;
     l_init_msg_list                            :=   fnd_api.g_false;
     l_commit                                   :=   fnd_api.g_false;

     /* Calling the overloaded procedure */
     inv_lot_api_pub.Update_Inv_lot(
           x_return_status     =>     l_return_status
         , x_msg_count         =>     l_msg_count
         , x_msg_data          =>     l_msg_data
         , x_lot_rec           =>     x_lot_rec
         , p_lot_rec           =>     l_in_lot_rec
         , p_source            =>     p_source
         , p_api_version       =>     l_api_version
         , p_init_msg_list     =>     l_init_msg_list
         , p_commit            =>     l_commit
          );

     IF l_debug = 1 THEN
         mydebug('Program Update_Inv_lot return ' || l_return_status, 9);
     END IF;
     IF l_return_status = fnd_api.g_ret_sts_error THEN
       IF l_debug = 1 THEN
         mydebug('Program Update_Inv_lot has failed with a user defined exception', 9);
       END IF;
       RAISE l_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       IF l_debug = 1 THEN
         mydebug('Program Update_Inv_lot has failed with a Unexpected exception', 9);
       END IF;
       FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
       FND_MESSAGE.SET_TOKEN('PROG_NAME','Update_Inv_lot');
       fnd_msg_pub.ADD;
       RAISE l_exc_unexpected_error;
     END IF;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status  := fnd_api.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          if( x_msg_count > 1 ) then
              x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
          end if;
          mydebug('Upd Inv Lot Attr: In No data found ' || SQLERRM, 9);
        WHEN l_exc_error THEN
          x_return_status  := fnd_api.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          if( x_msg_count > 1 ) then
              x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
          end if;
          mydebug('Upd Inv Lot Attr: In l_exc_error ' || SQLERRM, 9);
        WHEN l_exc_unexpected_error THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          if ( x_msg_count > 1 ) then
               x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
          end if;
          mydebug('In l_exc_unexpected_error ' || SQLERRM, 9);
        WHEN OTHERS THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          if( x_msg_count > 1 ) then
              x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
          end if;
          mydebug('Upd Inv Lot Attr: In others ' || SQLERRM, 9);
   END;

   -- Procedure to log all the data present in MTI, MTLI, MMTT and MTLT tables. Custom can use this API to
   -- verify which columns have data at runtime, so that those can be used in their Custom Code. This is
   -- a utility procedure.
   PROCEDURE log_transaction_rec(
       p_mtli_lot_rec         IN  MTL_TRANSACTION_LOTS_INTERFACE%ROWTYPE
      ,p_mti_trx_rec          IN  MTL_TRANSACTIONS_INTERFACE%ROWTYPE
      ,p_mtlt_lot_rec         IN  MTL_TRANSACTION_LOTS_TEMP%ROWTYPE
      ,p_mmtt_trx_rec         IN  MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
      ,p_table                IN  NUMBER
   )IS
   l_date_format VARCHAR2(30);
   BEGIN
      l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
      IF ((l_debug = 1) AND (p_table = 2 )) THEN
         mydebug(' TRANSACTION_HEADER_ID       '||p_mmtt_trx_rec.TRANSACTION_HEADER_ID);
         mydebug(' TRANSACTION_TEMP_ID         '||p_mmtt_trx_rec.TRANSACTION_TEMP_ID);
         mydebug(' SOURCE_CODE         '||p_mmtt_trx_rec.SOURCE_CODE);
         mydebug(' SOURCE_LINE_ID      '||p_mmtt_trx_rec.SOURCE_LINE_ID);
         mydebug(' TRANSACTION_MODE    '||p_mmtt_trx_rec.TRANSACTION_MODE);
         mydebug(' LOCK_FLAG   '||p_mmtt_trx_rec.LOCK_FLAG);
         mydebug(' LAST_UPDATE_DATE    '||TO_CHAR(p_mmtt_trx_rec.LAST_UPDATE_DATE, l_date_format));
         mydebug(' LAST_UPDATED_BY     '||p_mmtt_trx_rec.LAST_UPDATED_BY);
         mydebug(' CREATION_DATE       '||TO_CHAR(p_mmtt_trx_rec.CREATION_DATE, l_date_format));
         mydebug(' CREATED_BY  '||p_mmtt_trx_rec.CREATED_BY);
         mydebug(' LAST_UPDATE_LOGIN   '||p_mmtt_trx_rec.LAST_UPDATE_LOGIN);
         mydebug(' REQUEST_ID  '||p_mmtt_trx_rec.REQUEST_ID);
         mydebug(' PROGRAM_APPLICATION_ID      '||p_mmtt_trx_rec.PROGRAM_APPLICATION_ID);
         mydebug(' PROGRAM_ID  '||p_mmtt_trx_rec.PROGRAM_ID);
         mydebug(' PROGRAM_UPDATE_DATE         '||TO_CHAR(p_mmtt_trx_rec.PROGRAM_UPDATE_DATE, l_date_format));
         mydebug(' INVENTORY_ITEM_ID   '||p_mmtt_trx_rec.INVENTORY_ITEM_ID);
         mydebug(' REVISION    '||p_mmtt_trx_rec.REVISION);
         mydebug(' ORGANIZATION_ID     '||p_mmtt_trx_rec.ORGANIZATION_ID);
         mydebug(' SUBINVENTORY_CODE   '||p_mmtt_trx_rec.SUBINVENTORY_CODE);
         mydebug(' LOCATOR_ID  '||p_mmtt_trx_rec.LOCATOR_ID);
         mydebug(' TRANSACTION_QUANTITY        '||p_mmtt_trx_rec.TRANSACTION_QUANTITY);
         mydebug(' PRIMARY_QUANTITY    '||p_mmtt_trx_rec.PRIMARY_QUANTITY);
         mydebug(' TRANSACTION_UOM     '||p_mmtt_trx_rec.TRANSACTION_UOM);
         mydebug(' TRANSACTION_COST    '||p_mmtt_trx_rec.TRANSACTION_COST);
         mydebug(' TRANSACTION_TYPE_ID         '||p_mmtt_trx_rec.TRANSACTION_TYPE_ID);
         mydebug(' TRANSACTION_ACTION_ID       '||p_mmtt_trx_rec.TRANSACTION_ACTION_ID);
         mydebug(' TRANSACTION_SOURCE_TYPE_ID  '||p_mmtt_trx_rec.TRANSACTION_SOURCE_TYPE_ID);
         mydebug(' TRANSACTION_SOURCE_ID       '||p_mmtt_trx_rec.TRANSACTION_SOURCE_ID);
         mydebug(' TRANSACTION_SOURCE_NAME     '||p_mmtt_trx_rec.TRANSACTION_SOURCE_NAME);
         mydebug(' TRANSACTION_DATE    '||TO_CHAR(p_mmtt_trx_rec.TRANSACTION_DATE, l_date_format));
         mydebug(' ACCT_PERIOD_ID      '||p_mmtt_trx_rec.ACCT_PERIOD_ID);
         mydebug(' DISTRIBUTION_ACCOUNT_ID     '||p_mmtt_trx_rec.DISTRIBUTION_ACCOUNT_ID);
         mydebug(' TRANSACTION_REFERENCE       '||p_mmtt_trx_rec.TRANSACTION_REFERENCE);
         mydebug(' REQUISITION_LINE_ID         '||p_mmtt_trx_rec.REQUISITION_LINE_ID);
         mydebug(' REQUISITION_DISTRIBUTION_ID         '||p_mmtt_trx_rec.REQUISITION_DISTRIBUTION_ID);
         mydebug(' REASON_ID   '||p_mmtt_trx_rec.REASON_ID);
         mydebug(' LOT_NUMBER  '||p_mmtt_trx_rec.LOT_NUMBER);
         mydebug(' LOT_EXPIRATION_DATE         '||TO_CHAR(p_mmtt_trx_rec.LOT_EXPIRATION_DATE, l_date_format));
         mydebug(' SERIAL_NUMBER       '||p_mmtt_trx_rec.SERIAL_NUMBER);
         mydebug(' RECEIVING_DOCUMENT  '||p_mmtt_trx_rec.RECEIVING_DOCUMENT);
         mydebug(' DEMAND_ID   '||p_mmtt_trx_rec.DEMAND_ID);
         mydebug(' RCV_TRANSACTION_ID  '||p_mmtt_trx_rec.RCV_TRANSACTION_ID);
         mydebug(' MOVE_TRANSACTION_ID         '||p_mmtt_trx_rec.MOVE_TRANSACTION_ID);
         mydebug(' COMPLETION_TRANSACTION_ID   '||p_mmtt_trx_rec.COMPLETION_TRANSACTION_ID);
         mydebug(' WIP_ENTITY_TYPE     '||p_mmtt_trx_rec.WIP_ENTITY_TYPE);
         mydebug(' SCHEDULE_ID         '||p_mmtt_trx_rec.SCHEDULE_ID);
         mydebug(' REPETITIVE_LINE_ID  '||p_mmtt_trx_rec.REPETITIVE_LINE_ID);
         mydebug(' EMPLOYEE_CODE       '||p_mmtt_trx_rec.EMPLOYEE_CODE);
         mydebug(' PRIMARY_SWITCH      '||p_mmtt_trx_rec.PRIMARY_SWITCH);
         mydebug(' SCHEDULE_UPDATE_CODE        '||p_mmtt_trx_rec.SCHEDULE_UPDATE_CODE);
         mydebug(' SETUP_TEARDOWN_CODE         '||p_mmtt_trx_rec.SETUP_TEARDOWN_CODE);
         mydebug(' ITEM_ORDERING       '||p_mmtt_trx_rec.ITEM_ORDERING);
         mydebug(' NEGATIVE_REQ_FLAG   '||p_mmtt_trx_rec.NEGATIVE_REQ_FLAG);
         mydebug(' OPERATION_SEQ_NUM   '||p_mmtt_trx_rec.OPERATION_SEQ_NUM);
         mydebug(' PICKING_LINE_ID     '||p_mmtt_trx_rec.PICKING_LINE_ID);
         mydebug(' TRX_SOURCE_LINE_ID  '||p_mmtt_trx_rec.TRX_SOURCE_LINE_ID);
         mydebug(' TRX_SOURCE_DELIVERY_ID      '||p_mmtt_trx_rec.TRX_SOURCE_DELIVERY_ID);
         mydebug(' PHYSICAL_ADJUSTMENT_ID      '||p_mmtt_trx_rec.PHYSICAL_ADJUSTMENT_ID);
         mydebug(' CYCLE_COUNT_ID      '||p_mmtt_trx_rec.CYCLE_COUNT_ID);
         mydebug(' RMA_LINE_ID         '||p_mmtt_trx_rec.RMA_LINE_ID);
         mydebug(' CUSTOMER_SHIP_ID    '||p_mmtt_trx_rec.CUSTOMER_SHIP_ID);
         mydebug(' CURRENCY_CODE       '||p_mmtt_trx_rec.CURRENCY_CODE);
         mydebug(' CURRENCY_CONVERSION_RATE    '||p_mmtt_trx_rec.CURRENCY_CONVERSION_RATE);
         mydebug(' CURRENCY_CONVERSION_TYPE    '||p_mmtt_trx_rec.CURRENCY_CONVERSION_TYPE);
         mydebug(' CURRENCY_CONVERSION_DATE    '||TO_CHAR(p_mmtt_trx_rec.CURRENCY_CONVERSION_DATE, l_date_format));
         mydebug(' USSGL_TRANSACTION_CODE      '||p_mmtt_trx_rec.USSGL_TRANSACTION_CODE);
         mydebug(' VENDOR_LOT_NUMBER   '||p_mmtt_trx_rec.VENDOR_LOT_NUMBER);
         mydebug(' ENCUMBRANCE_ACCOUNT         '||p_mmtt_trx_rec.ENCUMBRANCE_ACCOUNT);
         mydebug(' ENCUMBRANCE_AMOUNT  '||p_mmtt_trx_rec.ENCUMBRANCE_AMOUNT);
         mydebug(' SHIP_TO_LOCATION    '||p_mmtt_trx_rec.SHIP_TO_LOCATION);
         mydebug(' SHIPMENT_NUMBER     '||p_mmtt_trx_rec.SHIPMENT_NUMBER);
         mydebug(' TRANSFER_COST       '||p_mmtt_trx_rec.TRANSFER_COST);
         mydebug(' TRANSPORTATION_COST         '||p_mmtt_trx_rec.TRANSPORTATION_COST);
         mydebug(' TRANSPORTATION_ACCOUNT      '||p_mmtt_trx_rec.TRANSPORTATION_ACCOUNT);
         mydebug(' FREIGHT_CODE        '||p_mmtt_trx_rec.FREIGHT_CODE);
         mydebug(' CONTAINERS  '||p_mmtt_trx_rec.CONTAINERS);
         mydebug(' WAYBILL_AIRBILL     '||p_mmtt_trx_rec.WAYBILL_AIRBILL);
         mydebug(' EXPECTED_ARRIVAL_DATE       '||TO_CHAR(p_mmtt_trx_rec.EXPECTED_ARRIVAL_DATE, l_date_format));
         mydebug(' TRANSFER_SUBINVENTORY       '||p_mmtt_trx_rec.TRANSFER_SUBINVENTORY);
         mydebug(' TRANSFER_ORGANIZATION       '||p_mmtt_trx_rec.TRANSFER_ORGANIZATION);
         mydebug(' TRANSFER_TO_LOCATION        '||p_mmtt_trx_rec.TRANSFER_TO_LOCATION);
         mydebug(' NEW_AVERAGE_COST    '||p_mmtt_trx_rec.NEW_AVERAGE_COST);
         mydebug(' VALUE_CHANGE        '||p_mmtt_trx_rec.VALUE_CHANGE);
         mydebug(' PERCENTAGE_CHANGE   '||p_mmtt_trx_rec.PERCENTAGE_CHANGE);
         mydebug(' MATERIAL_ALLOCATION_TEMP_ID         '||p_mmtt_trx_rec.MATERIAL_ALLOCATION_TEMP_ID);
         mydebug(' DEMAND_SOURCE_HEADER_ID     '||p_mmtt_trx_rec.DEMAND_SOURCE_HEADER_ID);
         mydebug(' DEMAND_SOURCE_LINE  '||p_mmtt_trx_rec.DEMAND_SOURCE_LINE);
         mydebug(' DEMAND_SOURCE_DELIVERY      '||p_mmtt_trx_rec.DEMAND_SOURCE_DELIVERY);
         mydebug(' ITEM_SEGMENTS       '||p_mmtt_trx_rec.ITEM_SEGMENTS);
         mydebug(' ITEM_DESCRIPTION    '||p_mmtt_trx_rec.ITEM_DESCRIPTION);
         mydebug(' ITEM_TRX_ENABLED_FLAG       '||p_mmtt_trx_rec.ITEM_TRX_ENABLED_FLAG);
         mydebug(' ITEM_LOCATION_CONTROL_CODE  '||p_mmtt_trx_rec.ITEM_LOCATION_CONTROL_CODE);
         mydebug(' ITEM_RESTRICT_SUBINV_CODE   '||p_mmtt_trx_rec.ITEM_RESTRICT_SUBINV_CODE);
         mydebug(' ITEM_RESTRICT_LOCATORS_CODE         '||p_mmtt_trx_rec.ITEM_RESTRICT_LOCATORS_CODE);
         mydebug(' ITEM_REVISION_QTY_CONTROL_CODE      '||p_mmtt_trx_rec.ITEM_REVISION_QTY_CONTROL_CODE);
         mydebug(' ITEM_PRIMARY_UOM_CODE       '||p_mmtt_trx_rec.ITEM_PRIMARY_UOM_CODE);
         mydebug(' ITEM_UOM_CLASS      '||p_mmtt_trx_rec.ITEM_UOM_CLASS);
         mydebug(' ITEM_SHELF_LIFE_CODE        '||p_mmtt_trx_rec.ITEM_SHELF_LIFE_CODE);
         mydebug(' ITEM_SHELF_LIFE_DAYS        '||p_mmtt_trx_rec.ITEM_SHELF_LIFE_DAYS);
         mydebug(' ITEM_LOT_CONTROL_CODE       '||p_mmtt_trx_rec.ITEM_LOT_CONTROL_CODE);
         mydebug(' ITEM_SERIAL_CONTROL_CODE    '||p_mmtt_trx_rec.ITEM_SERIAL_CONTROL_CODE);
         mydebug(' ITEM_INVENTORY_ASSET_FLAG   '||p_mmtt_trx_rec.ITEM_INVENTORY_ASSET_FLAG);
         mydebug(' ALLOWED_UNITS_LOOKUP_CODE   '||p_mmtt_trx_rec.ALLOWED_UNITS_LOOKUP_CODE);
         mydebug(' DEPARTMENT_ID       '||p_mmtt_trx_rec.DEPARTMENT_ID);
         mydebug(' DEPARTMENT_CODE     '||p_mmtt_trx_rec.DEPARTMENT_CODE);
         mydebug(' WIP_SUPPLY_TYPE     '||p_mmtt_trx_rec.WIP_SUPPLY_TYPE);
         mydebug(' SUPPLY_SUBINVENTORY         '||p_mmtt_trx_rec.SUPPLY_SUBINVENTORY);
         mydebug(' SUPPLY_LOCATOR_ID   '||p_mmtt_trx_rec.SUPPLY_LOCATOR_ID);
         mydebug(' VALID_SUBINVENTORY_FLAG     '||p_mmtt_trx_rec.VALID_SUBINVENTORY_FLAG);
         mydebug(' VALID_LOCATOR_FLAG  '||p_mmtt_trx_rec.VALID_LOCATOR_FLAG);
         mydebug(' LOCATOR_SEGMENTS    '||p_mmtt_trx_rec.LOCATOR_SEGMENTS);
         mydebug(' CURRENT_LOCATOR_CONTROL_CODE        '||p_mmtt_trx_rec.CURRENT_LOCATOR_CONTROL_CODE);
         mydebug(' NUMBER_OF_LOTS_ENTERED      '||p_mmtt_trx_rec.NUMBER_OF_LOTS_ENTERED);
         mydebug(' WIP_COMMIT_FLAG     '||p_mmtt_trx_rec.WIP_COMMIT_FLAG);
         mydebug(' NEXT_LOT_NUMBER     '||p_mmtt_trx_rec.NEXT_LOT_NUMBER);
         mydebug(' LOT_ALPHA_PREFIX    '||p_mmtt_trx_rec.LOT_ALPHA_PREFIX);
         mydebug(' NEXT_SERIAL_NUMBER  '||p_mmtt_trx_rec.NEXT_SERIAL_NUMBER);
         mydebug(' SERIAL_ALPHA_PREFIX         '||p_mmtt_trx_rec.SERIAL_ALPHA_PREFIX);
         mydebug(' SHIPPABLE_FLAG      '||p_mmtt_trx_rec.SHIPPABLE_FLAG);
         mydebug(' POSTING_FLAG        '||p_mmtt_trx_rec.POSTING_FLAG);
         mydebug(' REQUIRED_FLAG       '||p_mmtt_trx_rec.REQUIRED_FLAG);
         mydebug(' PROCESS_FLAG        '||p_mmtt_trx_rec.PROCESS_FLAG);
         mydebug(' ERROR_CODE  '||p_mmtt_trx_rec.ERROR_CODE);
         mydebug(' ERROR_EXPLANATION   '||p_mmtt_trx_rec.ERROR_EXPLANATION);
         mydebug(' ATTRIBUTE_CATEGORY  '||p_mmtt_trx_rec.ATTRIBUTE_CATEGORY);
         mydebug(' ATTRIBUTE1  '||p_mmtt_trx_rec.ATTRIBUTE1);
         mydebug(' ATTRIBUTE2  '||p_mmtt_trx_rec.ATTRIBUTE2);
         mydebug(' ATTRIBUTE3  '||p_mmtt_trx_rec.ATTRIBUTE3);
         mydebug(' ATTRIBUTE4  '||p_mmtt_trx_rec.ATTRIBUTE4);
         mydebug(' ATTRIBUTE5  '||p_mmtt_trx_rec.ATTRIBUTE5);
         mydebug(' ATTRIBUTE6  '||p_mmtt_trx_rec.ATTRIBUTE6);
         mydebug(' ATTRIBUTE7  '||p_mmtt_trx_rec.ATTRIBUTE7);
         mydebug(' ATTRIBUTE8  '||p_mmtt_trx_rec.ATTRIBUTE8);
         mydebug(' ATTRIBUTE9  '||p_mmtt_trx_rec.ATTRIBUTE9);
         mydebug(' ATTRIBUTE10         '||p_mmtt_trx_rec.ATTRIBUTE10);
         mydebug(' ATTRIBUTE11         '||p_mmtt_trx_rec.ATTRIBUTE11);
         mydebug(' ATTRIBUTE12         '||p_mmtt_trx_rec.ATTRIBUTE12);
         mydebug(' ATTRIBUTE13         '||p_mmtt_trx_rec.ATTRIBUTE13);
         mydebug(' ATTRIBUTE14         '||p_mmtt_trx_rec.ATTRIBUTE14);
         mydebug(' ATTRIBUTE15         '||p_mmtt_trx_rec.ATTRIBUTE15);
         mydebug(' MOVEMENT_ID         '||p_mmtt_trx_rec.MOVEMENT_ID);
         mydebug(' RESERVATION_QUANTITY        '||p_mmtt_trx_rec.RESERVATION_QUANTITY);
         mydebug(' SHIPPED_QUANTITY    '||p_mmtt_trx_rec.SHIPPED_QUANTITY);
         mydebug(' TRANSACTION_LINE_NUMBER     '||p_mmtt_trx_rec.TRANSACTION_LINE_NUMBER);
         mydebug(' TASK_ID     '||p_mmtt_trx_rec.TASK_ID);
         mydebug(' SOURCE_TASK_ID      '||p_mmtt_trx_rec.SOURCE_TASK_ID);
         mydebug(' PROJECT_ID          '||p_mmtt_trx_rec.PROJECT_ID);
         mydebug(' SOURCE_PROJECT_ID   '||p_mmtt_trx_rec.SOURCE_PROJECT_ID);
         mydebug(' PA_EXPENDITURE_ORG_ID       '||p_mmtt_trx_rec.PA_EXPENDITURE_ORG_ID);
         mydebug(' EXPENDITURE_TYPE    '||p_mmtt_trx_rec.EXPENDITURE_TYPE);
         mydebug(' FINAL_COMPLETION_FLAG       '||p_mmtt_trx_rec.FINAL_COMPLETION_FLAG);
         mydebug(' TRANSFER_PERCENTAGE         '||p_mmtt_trx_rec.TRANSFER_PERCENTAGE);
         mydebug(' QA_COLLECTION_ID    '||p_mmtt_trx_rec.QA_COLLECTION_ID);
         mydebug(' END_ITEM_UNIT_NUMBER        '||p_mmtt_trx_rec.END_ITEM_UNIT_NUMBER);
         mydebug(' SCHEDULED_PAYBACK_DATE      '||TO_CHAR(p_mmtt_trx_rec.SCHEDULED_PAYBACK_DATE, l_date_format));
         mydebug(' MOVE_ORDER_LINE_ID  '||p_mmtt_trx_rec.MOVE_ORDER_LINE_ID);
         mydebug(' TASK_GROUP_ID       '||p_mmtt_trx_rec.TASK_GROUP_ID);
         mydebug(' PICK_SLIP_NUMBER    '||p_mmtt_trx_rec.PICK_SLIP_NUMBER);
         mydebug(' RESERVATION_ID      '||p_mmtt_trx_rec.RESERVATION_ID);
         mydebug(' TRANSACTION_STATUS  '||p_mmtt_trx_rec.TRANSACTION_STATUS);
         mydebug(' WMS_TASK_TYPE       '||p_mmtt_trx_rec.WMS_TASK_TYPE);
         mydebug(' PARENT_LINE_ID      '||p_mmtt_trx_rec.PARENT_LINE_ID);
         mydebug(' WMS_TASK_STATUS     '||p_mmtt_trx_rec.WMS_TASK_STATUS);
         mydebug(' REBUILD_ITEM_ID     '||p_mmtt_trx_rec.REBUILD_ITEM_ID);
         mydebug(' REBUILD_SERIAL_NUMBER       '||p_mmtt_trx_rec.REBUILD_SERIAL_NUMBER);
         mydebug(' REBUILD_ACTIVITY_ID         '||p_mmtt_trx_rec.REBUILD_ACTIVITY_ID);
         mydebug(' REBUILD_JOB_NAME    '||p_mmtt_trx_rec.REBUILD_JOB_NAME);
         mydebug(' OWNING_TP_TYPE      '||p_mmtt_trx_rec.OWNING_TP_TYPE);
         mydebug(' XFR_OWNING_ORGANIZATION_ID  '||p_mmtt_trx_rec.XFR_OWNING_ORGANIZATION_ID);
         mydebug(' TRANSFER_OWNING_TP_TYPE     '||p_mmtt_trx_rec.TRANSFER_OWNING_TP_TYPE);
         mydebug(' PLANNING_TP_TYPE    '||p_mmtt_trx_rec.PLANNING_TP_TYPE);
         mydebug(' XFR_PLANNING_ORGANIZATION_ID        '||p_mmtt_trx_rec.XFR_PLANNING_ORGANIZATION_ID);
         mydebug(' TRANSFER_PLANNING_TP_TYPE   '||p_mmtt_trx_rec.TRANSFER_PLANNING_TP_TYPE);
         mydebug(' SECONDARY_UOM_CODE  '||p_mmtt_trx_rec.SECONDARY_UOM_CODE);
         mydebug(' SECONDARY_TRANSACTION_QUANTITY      '||p_mmtt_trx_rec.SECONDARY_TRANSACTION_QUANTITY);
         mydebug(' MOVE_ORDER_HEADER_ID        '||p_mmtt_trx_rec.MOVE_ORDER_HEADER_ID);
         mydebug(' SERIAL_ALLOCATED_FLAG       '||p_mmtt_trx_rec.SERIAL_ALLOCATED_FLAG);
         mydebug(' ORIGINAL_TRANSACTION_TEMP_ID        '||p_mmtt_trx_rec.ORIGINAL_TRANSACTION_TEMP_ID);
         mydebug(' TRANSFER_SECONDARY_QUANTITY         '||p_mmtt_trx_rec.TRANSFER_SECONDARY_QUANTITY);
         mydebug(' TRANSFER_SECONDARY_UOM      '||p_mmtt_trx_rec.TRANSFER_SECONDARY_UOM);
         mydebug(' TRANSFER_PRICE      '||p_mmtt_trx_rec.TRANSFER_PRICE);
--      END IF;
--      IF ((l_debug = 1) AND (p_mtlt_lot_rec.COUNT > 0 )) THEN
         mydebug(' TRANSACTION_TEMP_ID      '||p_mtlt_lot_rec.TRANSACTION_TEMP_ID);
         mydebug(' LAST_UPDATE_DATE         '||TO_CHAR(p_mtlt_lot_rec.LAST_UPDATE_DATE, l_date_format));
         mydebug(' LAST_UPDATED_BY  '||p_mtlt_lot_rec.LAST_UPDATED_BY);
         mydebug(' CREATION_DATE    '||TO_CHAR(p_mtlt_lot_rec.CREATION_DATE, l_date_format));
         mydebug(' CREATED_BY       '||p_mtlt_lot_rec.CREATED_BY);
         mydebug(' LAST_UPDATE_LOGIN        '||p_mtlt_lot_rec.LAST_UPDATE_LOGIN);
         mydebug(' REQUEST_ID       '||p_mtlt_lot_rec.REQUEST_ID);
         mydebug(' PROGRAM_APPLICATION_ID   '||p_mtlt_lot_rec.PROGRAM_APPLICATION_ID);
         mydebug(' PROGRAM_ID       '||p_mtlt_lot_rec.PROGRAM_ID);
         mydebug(' PROGRAM_UPDATE_DATE      '||TO_CHAR(p_mtlt_lot_rec.PROGRAM_UPDATE_DATE, l_date_format));
         mydebug(' TRANSACTION_QUANTITY     '||p_mtlt_lot_rec.TRANSACTION_QUANTITY);
         mydebug(' PRIMARY_QUANTITY         '||p_mtlt_lot_rec.PRIMARY_QUANTITY);
         mydebug(' LOT_NUMBER       '||p_mtlt_lot_rec.LOT_NUMBER);
         mydebug(' LOT_EXPIRATION_DATE      '||TO_CHAR(p_mtlt_lot_rec.LOT_EXPIRATION_DATE, l_date_format));
         mydebug(' ERROR_CODE       '||p_mtlt_lot_rec.ERROR_CODE);
         mydebug(' SERIAL_TRANSACTION_TEMP_ID       '||p_mtlt_lot_rec.SERIAL_TRANSACTION_TEMP_ID);
         mydebug(' DESCRIPTION      '||p_mtlt_lot_rec.DESCRIPTION);
         mydebug(' VENDOR_NAME      '||p_mtlt_lot_rec.VENDOR_NAME);
         mydebug(' SUPPLIER_LOT_NUMBER      '||p_mtlt_lot_rec.SUPPLIER_LOT_NUMBER);
         mydebug(' ORIGINATION_DATE         '||TO_CHAR(p_mtlt_lot_rec.ORIGINATION_DATE, l_date_format));
         mydebug(' DATE_CODE        '||p_mtlt_lot_rec.DATE_CODE);
         mydebug(' GRADE_CODE       '||p_mtlt_lot_rec.GRADE_CODE);
         mydebug(' CHANGE_DATE         '||TO_CHAR(p_mtlt_lot_rec.CHANGE_DATE, l_date_format));
         mydebug(' MATURITY_DATE         '||TO_CHAR(p_mtlt_lot_rec.MATURITY_DATE, l_date_format));
         mydebug(' STATUS_ID        '||p_mtlt_lot_rec.STATUS_ID);
         mydebug(' RETEST_DATE         '||TO_CHAR(p_mtlt_lot_rec.RETEST_DATE, l_date_format));
         mydebug(' AGE      '||p_mtlt_lot_rec.AGE);
         mydebug(' ITEM_SIZE        '||p_mtlt_lot_rec.ITEM_SIZE);
         mydebug(' COLOR    '||p_mtlt_lot_rec.COLOR);
         mydebug(' VOLUME   '||p_mtlt_lot_rec.VOLUME);
         mydebug(' VOLUME_UOM       '||p_mtlt_lot_rec.VOLUME_UOM);
         mydebug(' PLACE_OF_ORIGIN  '||p_mtlt_lot_rec.PLACE_OF_ORIGIN);
         mydebug(' BEST_BY_DATE         '||TO_CHAR(p_mtlt_lot_rec.BEST_BY_DATE, l_date_format));
         mydebug(' LENGTH   '||p_mtlt_lot_rec.LENGTH);
         mydebug(' LENGTH_UOM       '||p_mtlt_lot_rec.LENGTH_UOM);
         mydebug(' RECYCLED_CONTENT         '||p_mtlt_lot_rec.RECYCLED_CONTENT);
         mydebug(' THICKNESS        '||p_mtlt_lot_rec.THICKNESS);
         mydebug(' THICKNESS_UOM    '||p_mtlt_lot_rec.THICKNESS_UOM);
         mydebug(' WIDTH    '||p_mtlt_lot_rec.WIDTH);
         mydebug(' WIDTH_UOM        '||p_mtlt_lot_rec.WIDTH_UOM);
         mydebug(' CURL_WRINKLE_FOLD        '||p_mtlt_lot_rec.CURL_WRINKLE_FOLD);
         mydebug(' LOT_ATTRIBUTE_CATEGORY   '||p_mtlt_lot_rec.LOT_ATTRIBUTE_CATEGORY);
         mydebug(' C_ATTRIBUTE1     '||p_mtlt_lot_rec.C_ATTRIBUTE1);
         mydebug(' C_ATTRIBUTE2     '||p_mtlt_lot_rec.C_ATTRIBUTE2);
         mydebug(' C_ATTRIBUTE3     '||p_mtlt_lot_rec.C_ATTRIBUTE3);
         mydebug(' C_ATTRIBUTE4     '||p_mtlt_lot_rec.C_ATTRIBUTE4);
         mydebug(' C_ATTRIBUTE5     '||p_mtlt_lot_rec.C_ATTRIBUTE5);
         mydebug(' C_ATTRIBUTE6     '||p_mtlt_lot_rec.C_ATTRIBUTE6);
         mydebug(' C_ATTRIBUTE7     '||p_mtlt_lot_rec.C_ATTRIBUTE7);
         mydebug(' C_ATTRIBUTE8     '||p_mtlt_lot_rec.C_ATTRIBUTE8);
         mydebug(' C_ATTRIBUTE9     '||p_mtlt_lot_rec.C_ATTRIBUTE9);
         mydebug(' C_ATTRIBUTE10    '||p_mtlt_lot_rec.C_ATTRIBUTE10);
         mydebug(' C_ATTRIBUTE11    '||p_mtlt_lot_rec.C_ATTRIBUTE11);
         mydebug(' C_ATTRIBUTE12    '||p_mtlt_lot_rec.C_ATTRIBUTE12);
         mydebug(' C_ATTRIBUTE13    '||p_mtlt_lot_rec.C_ATTRIBUTE13);
         mydebug(' C_ATTRIBUTE14    '||p_mtlt_lot_rec.C_ATTRIBUTE14);
         mydebug(' C_ATTRIBUTE15    '||p_mtlt_lot_rec.C_ATTRIBUTE15);
         mydebug(' C_ATTRIBUTE16    '||p_mtlt_lot_rec.C_ATTRIBUTE16);
         mydebug(' C_ATTRIBUTE17    '||p_mtlt_lot_rec.C_ATTRIBUTE17);
         mydebug(' C_ATTRIBUTE18    '||p_mtlt_lot_rec.C_ATTRIBUTE18);
         mydebug(' C_ATTRIBUTE19    '||p_mtlt_lot_rec.C_ATTRIBUTE19);
         mydebug(' C_ATTRIBUTE20    '||p_mtlt_lot_rec.C_ATTRIBUTE20);
         mydebug(' D_ATTRIBUTE1     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE1, l_date_format));
         mydebug(' D_ATTRIBUTE2     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE2, l_date_format));
         mydebug(' D_ATTRIBUTE3     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE3, l_date_format));
         mydebug(' D_ATTRIBUTE4     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE4, l_date_format));
         mydebug(' D_ATTRIBUTE5     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE5, l_date_format));
         mydebug(' D_ATTRIBUTE6     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE6, l_date_format));
         mydebug(' D_ATTRIBUTE7     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE7, l_date_format));
         mydebug(' D_ATTRIBUTE8     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE8, l_date_format));
         mydebug(' D_ATTRIBUTE9     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE9, l_date_format));
         mydebug(' D_ATTRIBUTE10     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE10, l_date_format));
         mydebug(' N_ATTRIBUTE1     '||p_mtlt_lot_rec.N_ATTRIBUTE1);
         mydebug(' N_ATTRIBUTE2     '||p_mtlt_lot_rec.N_ATTRIBUTE2);
         mydebug(' N_ATTRIBUTE3     '||p_mtlt_lot_rec.N_ATTRIBUTE3);
         mydebug(' N_ATTRIBUTE4     '||p_mtlt_lot_rec.N_ATTRIBUTE4);
         mydebug(' N_ATTRIBUTE5     '||p_mtlt_lot_rec.N_ATTRIBUTE5);
         mydebug(' N_ATTRIBUTE6     '||p_mtlt_lot_rec.N_ATTRIBUTE6);
         mydebug(' N_ATTRIBUTE7     '||p_mtlt_lot_rec.N_ATTRIBUTE7);
         mydebug(' N_ATTRIBUTE8     '||p_mtlt_lot_rec.N_ATTRIBUTE8);
         mydebug(' N_ATTRIBUTE9     '||p_mtlt_lot_rec.N_ATTRIBUTE9);
         mydebug(' N_ATTRIBUTE10    '||p_mtlt_lot_rec.N_ATTRIBUTE10);
         mydebug(' VENDOR_ID        '||p_mtlt_lot_rec.VENDOR_ID);
         mydebug(' TERRITORY_CODE   '||p_mtlt_lot_rec.TERRITORY_CODE);
         mydebug(' SECONDARY_QUANTITY       '||p_mtlt_lot_rec.SECONDARY_QUANTITY);
         mydebug(' SECONDARY_UNIT_OF_MEASURE        '||p_mtlt_lot_rec.SECONDARY_UNIT_OF_MEASURE);
         mydebug(' REASON_CODE      '||p_mtlt_lot_rec.REASON_CODE);
         mydebug(' ATTRIBUTE_CATEGORY       '||p_mtlt_lot_rec.ATTRIBUTE_CATEGORY);
         mydebug(' ATTRIBUTE1       '||p_mtlt_lot_rec.ATTRIBUTE1);
         mydebug(' ATTRIBUTE2       '||p_mtlt_lot_rec.ATTRIBUTE2);
         mydebug(' ATTRIBUTE3       '||p_mtlt_lot_rec.ATTRIBUTE3);
         mydebug(' ATTRIBUTE4       '||p_mtlt_lot_rec.ATTRIBUTE4);
         mydebug(' ATTRIBUTE5       '||p_mtlt_lot_rec.ATTRIBUTE5);
         mydebug(' ATTRIBUTE6       '||p_mtlt_lot_rec.ATTRIBUTE6);
         mydebug(' ATTRIBUTE7       '||p_mtlt_lot_rec.ATTRIBUTE7);
         mydebug(' ATTRIBUTE8       '||p_mtlt_lot_rec.ATTRIBUTE8);
         mydebug(' ATTRIBUTE9       '||p_mtlt_lot_rec.ATTRIBUTE9);
         mydebug(' ATTRIBUTE10      '||p_mtlt_lot_rec.ATTRIBUTE10);
         mydebug(' ATTRIBUTE11      '||p_mtlt_lot_rec.ATTRIBUTE11);
         mydebug(' ATTRIBUTE12      '||p_mtlt_lot_rec.ATTRIBUTE12);
         mydebug(' ATTRIBUTE13      '||p_mtlt_lot_rec.ATTRIBUTE13);
         mydebug(' ATTRIBUTE14      '||p_mtlt_lot_rec.ATTRIBUTE14);
         mydebug(' ATTRIBUTE15      '||p_mtlt_lot_rec.ATTRIBUTE15);
         mydebug(' EXPIRATION_ACTION_CODE   '||p_mtlt_lot_rec.EXPIRATION_ACTION_CODE);
         mydebug(' EXPIRATION_ACTION_DATE     '||TO_CHAR(p_mtlt_lot_rec.EXPIRATION_ACTION_DATE, l_date_format));
         mydebug(' HOLD_DATE     '||TO_CHAR(p_mtlt_lot_rec.HOLD_DATE, l_date_format));
         mydebug(' ORIGINATION_TYPE         '||p_mtlt_lot_rec.ORIGINATION_TYPE);
         mydebug(' PARENT_LOT_NUMBER        '||p_mtlt_lot_rec.PARENT_LOT_NUMBER);
         mydebug(' REASON_ID        '||p_mtlt_lot_rec.REASON_ID);
         mydebug(' PARENT_OBJECT_TYPE       '||p_mtlt_lot_rec.PARENT_OBJECT_TYPE);
         mydebug(' PARENT_OBJECT_ID         '||p_mtlt_lot_rec.PARENT_OBJECT_ID);
         mydebug(' PARENT_OBJECT_TYPE2      '||p_mtlt_lot_rec.PARENT_OBJECT_TYPE2);
         mydebug(' PARENT_OBJECT_ID2        '||p_mtlt_lot_rec.PARENT_OBJECT_ID2);
      END IF;
      IF ((l_debug = 1) AND (p_table = 1 )) THEN
         mydebug(' TRANSACTION_INTERFACE_ID         '||p_mti_trx_rec.TRANSACTION_INTERFACE_ID);
         mydebug(' TRANSACTION_HEADER_ID    '||p_mti_trx_rec.TRANSACTION_HEADER_ID);
         mydebug(' SOURCE_CODE      '||p_mti_trx_rec.SOURCE_CODE);
         mydebug(' SOURCE_LINE_ID   '||p_mti_trx_rec.SOURCE_LINE_ID);
         mydebug(' SOURCE_HEADER_ID         '||p_mti_trx_rec.SOURCE_HEADER_ID);
         mydebug(' PROCESS_FLAG     '||p_mti_trx_rec.PROCESS_FLAG);
         mydebug(' VALIDATION_REQUIRED      '||p_mti_trx_rec.VALIDATION_REQUIRED);
         mydebug(' TRANSACTION_MODE         '||p_mti_trx_rec.TRANSACTION_MODE);
         mydebug(' LOCK_FLAG        '||p_mti_trx_rec.LOCK_FLAG);
         mydebug(' LAST_UPDATE_DATE     '||TO_CHAR(p_mtlt_lot_rec.LAST_UPDATE_DATE, l_date_format));
         mydebug(' LAST_UPDATED_BY  '||p_mti_trx_rec.LAST_UPDATED_BY);
         mydebug(' CREATION_DATE     '||TO_CHAR(p_mtlt_lot_rec.CREATION_DATE, l_date_format));
         mydebug(' CREATED_BY       '||p_mti_trx_rec.CREATED_BY);
         mydebug(' LAST_UPDATE_LOGIN        '||p_mti_trx_rec.LAST_UPDATE_LOGIN);
         mydebug(' REQUEST_ID       '||p_mti_trx_rec.REQUEST_ID);
         mydebug(' PROGRAM_APPLICATION_ID   '||p_mti_trx_rec.PROGRAM_APPLICATION_ID);
         mydebug(' PROGRAM_ID       '||p_mti_trx_rec.PROGRAM_ID);
         mydebug(' PROGRAM_UPDATE_DATE     '||TO_CHAR(p_mtlt_lot_rec.PROGRAM_UPDATE_DATE, l_date_format));
         mydebug(' INVENTORY_ITEM_ID        '||p_mti_trx_rec.INVENTORY_ITEM_ID);
         mydebug(' ITEM_SEGMENT1    '||p_mti_trx_rec.ITEM_SEGMENT1);
         mydebug(' ITEM_SEGMENT2    '||p_mti_trx_rec.ITEM_SEGMENT2);
         mydebug(' ITEM_SEGMENT3    '||p_mti_trx_rec.ITEM_SEGMENT3);
         mydebug(' ITEM_SEGMENT4    '||p_mti_trx_rec.ITEM_SEGMENT4);
         mydebug(' ITEM_SEGMENT5    '||p_mti_trx_rec.ITEM_SEGMENT5);
         mydebug(' ITEM_SEGMENT6    '||p_mti_trx_rec.ITEM_SEGMENT6);
         mydebug(' ITEM_SEGMENT7    '||p_mti_trx_rec.ITEM_SEGMENT7);
         mydebug(' ITEM_SEGMENT8    '||p_mti_trx_rec.ITEM_SEGMENT8);
         mydebug(' ITEM_SEGMENT9    '||p_mti_trx_rec.ITEM_SEGMENT9);
         mydebug(' ITEM_SEGMENT10   '||p_mti_trx_rec.ITEM_SEGMENT10);
         mydebug(' ITEM_SEGMENT11   '||p_mti_trx_rec.ITEM_SEGMENT11);
         mydebug(' ITEM_SEGMENT12   '||p_mti_trx_rec.ITEM_SEGMENT12);
         mydebug(' ITEM_SEGMENT13   '||p_mti_trx_rec.ITEM_SEGMENT13);
         mydebug(' ITEM_SEGMENT14   '||p_mti_trx_rec.ITEM_SEGMENT14);
         mydebug(' ITEM_SEGMENT15   '||p_mti_trx_rec.ITEM_SEGMENT15);
         mydebug(' ITEM_SEGMENT16   '||p_mti_trx_rec.ITEM_SEGMENT16);
         mydebug(' ITEM_SEGMENT17   '||p_mti_trx_rec.ITEM_SEGMENT17);
         mydebug(' ITEM_SEGMENT18   '||p_mti_trx_rec.ITEM_SEGMENT18);
         mydebug(' ITEM_SEGMENT19   '||p_mti_trx_rec.ITEM_SEGMENT19);
         mydebug(' ITEM_SEGMENT20   '||p_mti_trx_rec.ITEM_SEGMENT20);
         mydebug(' REVISION         '||p_mti_trx_rec.REVISION);
         mydebug(' ORGANIZATION_ID  '||p_mti_trx_rec.ORGANIZATION_ID);
         mydebug(' TRANSACTION_QUANTITY     '||p_mti_trx_rec.TRANSACTION_QUANTITY);
         mydebug(' PRIMARY_QUANTITY         '||p_mti_trx_rec.PRIMARY_QUANTITY);
         mydebug(' TRANSACTION_UOM  '||p_mti_trx_rec.TRANSACTION_UOM);
         mydebug(' TRANSACTION_DATE     '||TO_CHAR(p_mti_trx_rec.TRANSACTION_DATE, l_date_format));
         mydebug(' ACCT_PERIOD_ID   '||p_mti_trx_rec.ACCT_PERIOD_ID);
         mydebug(' SUBINVENTORY_CODE        '||p_mti_trx_rec.SUBINVENTORY_CODE);
         mydebug(' LOCATOR_ID       '||p_mti_trx_rec.LOCATOR_ID);
         mydebug(' LOC_SEGMENT1     '||p_mti_trx_rec.LOC_SEGMENT1);
         mydebug(' LOC_SEGMENT2     '||p_mti_trx_rec.LOC_SEGMENT2);
         mydebug(' LOC_SEGMENT3     '||p_mti_trx_rec.LOC_SEGMENT3);
         mydebug(' LOC_SEGMENT4     '||p_mti_trx_rec.LOC_SEGMENT4);
         mydebug(' LOC_SEGMENT5     '||p_mti_trx_rec.LOC_SEGMENT5);
         mydebug(' LOC_SEGMENT6     '||p_mti_trx_rec.LOC_SEGMENT6);
         mydebug(' LOC_SEGMENT7     '||p_mti_trx_rec.LOC_SEGMENT7);
         mydebug(' LOC_SEGMENT8     '||p_mti_trx_rec.LOC_SEGMENT8);
         mydebug(' LOC_SEGMENT9     '||p_mti_trx_rec.LOC_SEGMENT9);
         mydebug(' LOC_SEGMENT10    '||p_mti_trx_rec.LOC_SEGMENT10);
         mydebug(' LOC_SEGMENT11    '||p_mti_trx_rec.LOC_SEGMENT11);
         mydebug(' LOC_SEGMENT12    '||p_mti_trx_rec.LOC_SEGMENT12);
         mydebug(' LOC_SEGMENT13    '||p_mti_trx_rec.LOC_SEGMENT13);
         mydebug(' LOC_SEGMENT14    '||p_mti_trx_rec.LOC_SEGMENT14);
         mydebug(' LOC_SEGMENT15    '||p_mti_trx_rec.LOC_SEGMENT15);
         mydebug(' LOC_SEGMENT16    '||p_mti_trx_rec.LOC_SEGMENT16);
         mydebug(' LOC_SEGMENT17    '||p_mti_trx_rec.LOC_SEGMENT17);
         mydebug(' LOC_SEGMENT18    '||p_mti_trx_rec.LOC_SEGMENT18);
         mydebug(' LOC_SEGMENT19    '||p_mti_trx_rec.LOC_SEGMENT19);
         mydebug(' LOC_SEGMENT20    '||p_mti_trx_rec.LOC_SEGMENT20);
         mydebug(' TRANSACTION_SOURCE_ID    '||p_mti_trx_rec.TRANSACTION_SOURCE_ID);
         mydebug(' DSP_SEGMENT1     '||p_mti_trx_rec.DSP_SEGMENT1);
         mydebug(' DSP_SEGMENT2     '||p_mti_trx_rec.DSP_SEGMENT2);
         mydebug(' DSP_SEGMENT3     '||p_mti_trx_rec.DSP_SEGMENT3);
         mydebug(' DSP_SEGMENT4     '||p_mti_trx_rec.DSP_SEGMENT4);
         mydebug(' DSP_SEGMENT5     '||p_mti_trx_rec.DSP_SEGMENT5);
         mydebug(' DSP_SEGMENT6     '||p_mti_trx_rec.DSP_SEGMENT6);
         mydebug(' DSP_SEGMENT7     '||p_mti_trx_rec.DSP_SEGMENT7);
         mydebug(' DSP_SEGMENT8     '||p_mti_trx_rec.DSP_SEGMENT8);
         mydebug(' DSP_SEGMENT9     '||p_mti_trx_rec.DSP_SEGMENT9);
         mydebug(' DSP_SEGMENT10    '||p_mti_trx_rec.DSP_SEGMENT10);
         mydebug(' DSP_SEGMENT11    '||p_mti_trx_rec.DSP_SEGMENT11);
         mydebug(' DSP_SEGMENT12    '||p_mti_trx_rec.DSP_SEGMENT12);
         mydebug(' DSP_SEGMENT13    '||p_mti_trx_rec.DSP_SEGMENT13);
         mydebug(' DSP_SEGMENT14    '||p_mti_trx_rec.DSP_SEGMENT14);
         mydebug(' DSP_SEGMENT15    '||p_mti_trx_rec.DSP_SEGMENT15);
         mydebug(' DSP_SEGMENT16    '||p_mti_trx_rec.DSP_SEGMENT16);
         mydebug(' DSP_SEGMENT17    '||p_mti_trx_rec.DSP_SEGMENT17);
         mydebug(' DSP_SEGMENT18    '||p_mti_trx_rec.DSP_SEGMENT18);
         mydebug(' DSP_SEGMENT19    '||p_mti_trx_rec.DSP_SEGMENT19);
         mydebug(' DSP_SEGMENT20    '||p_mti_trx_rec.DSP_SEGMENT20);
         mydebug(' DSP_SEGMENT21    '||p_mti_trx_rec.DSP_SEGMENT21);
         mydebug(' DSP_SEGMENT22    '||p_mti_trx_rec.DSP_SEGMENT22);
         mydebug(' DSP_SEGMENT23    '||p_mti_trx_rec.DSP_SEGMENT23);
         mydebug(' DSP_SEGMENT24    '||p_mti_trx_rec.DSP_SEGMENT24);
         mydebug(' DSP_SEGMENT25    '||p_mti_trx_rec.DSP_SEGMENT25);
         mydebug(' DSP_SEGMENT26    '||p_mti_trx_rec.DSP_SEGMENT26);
         mydebug(' DSP_SEGMENT27    '||p_mti_trx_rec.DSP_SEGMENT27);
         mydebug(' DSP_SEGMENT28    '||p_mti_trx_rec.DSP_SEGMENT28);
         mydebug(' DSP_SEGMENT29    '||p_mti_trx_rec.DSP_SEGMENT29);
         mydebug(' DSP_SEGMENT30    '||p_mti_trx_rec.DSP_SEGMENT30);
         mydebug(' TRANSACTION_SOURCE_NAME  '||p_mti_trx_rec.TRANSACTION_SOURCE_NAME);
         mydebug(' TRANSACTION_SOURCE_TYPE_ID       '||p_mti_trx_rec.TRANSACTION_SOURCE_TYPE_ID);
         mydebug(' TRANSACTION_ACTION_ID    '||p_mti_trx_rec.TRANSACTION_ACTION_ID);
         mydebug(' TRANSACTION_TYPE_ID      '||p_mti_trx_rec.TRANSACTION_TYPE_ID);
         mydebug(' REASON_ID        '||p_mti_trx_rec.REASON_ID);
         mydebug(' TRANSACTION_REFERENCE    '||p_mti_trx_rec.TRANSACTION_REFERENCE);
         mydebug(' TRANSACTION_COST         '||p_mti_trx_rec.TRANSACTION_COST);
         mydebug(' DISTRIBUTION_ACCOUNT_ID  '||p_mti_trx_rec.DISTRIBUTION_ACCOUNT_ID);
         mydebug(' DST_SEGMENT1     '||p_mti_trx_rec.DST_SEGMENT1);
         mydebug(' DST_SEGMENT2     '||p_mti_trx_rec.DST_SEGMENT2);
         mydebug(' DST_SEGMENT3     '||p_mti_trx_rec.DST_SEGMENT3);
         mydebug(' DST_SEGMENT4     '||p_mti_trx_rec.DST_SEGMENT4);
         mydebug(' DST_SEGMENT5     '||p_mti_trx_rec.DST_SEGMENT5);
         mydebug(' DST_SEGMENT6     '||p_mti_trx_rec.DST_SEGMENT6);
         mydebug(' DST_SEGMENT7     '||p_mti_trx_rec.DST_SEGMENT7);
         mydebug(' DST_SEGMENT8     '||p_mti_trx_rec.DST_SEGMENT8);
         mydebug(' DST_SEGMENT9     '||p_mti_trx_rec.DST_SEGMENT9);
         mydebug(' DST_SEGMENT10    '||p_mti_trx_rec.DST_SEGMENT10);
         mydebug(' DST_SEGMENT11    '||p_mti_trx_rec.DST_SEGMENT11);
         mydebug(' DST_SEGMENT12    '||p_mti_trx_rec.DST_SEGMENT12);
         mydebug(' DST_SEGMENT13    '||p_mti_trx_rec.DST_SEGMENT13);
         mydebug(' DST_SEGMENT14    '||p_mti_trx_rec.DST_SEGMENT14);
         mydebug(' DST_SEGMENT15    '||p_mti_trx_rec.DST_SEGMENT15);
         mydebug(' DST_SEGMENT16    '||p_mti_trx_rec.DST_SEGMENT16);
         mydebug(' DST_SEGMENT17    '||p_mti_trx_rec.DST_SEGMENT17);
         mydebug(' DST_SEGMENT18    '||p_mti_trx_rec.DST_SEGMENT18);
         mydebug(' DST_SEGMENT19    '||p_mti_trx_rec.DST_SEGMENT19);
         mydebug(' DST_SEGMENT20    '||p_mti_trx_rec.DST_SEGMENT20);
         mydebug(' DST_SEGMENT21    '||p_mti_trx_rec.DST_SEGMENT21);
         mydebug(' DST_SEGMENT22    '||p_mti_trx_rec.DST_SEGMENT22);
         mydebug(' DST_SEGMENT23    '||p_mti_trx_rec.DST_SEGMENT23);
         mydebug(' DST_SEGMENT24    '||p_mti_trx_rec.DST_SEGMENT24);
         mydebug(' DST_SEGMENT25    '||p_mti_trx_rec.DST_SEGMENT25);
         mydebug(' DST_SEGMENT26    '||p_mti_trx_rec.DST_SEGMENT26);
         mydebug(' DST_SEGMENT27    '||p_mti_trx_rec.DST_SEGMENT27);
         mydebug(' DST_SEGMENT28    '||p_mti_trx_rec.DST_SEGMENT28);
         mydebug(' DST_SEGMENT29    '||p_mti_trx_rec.DST_SEGMENT29);
         mydebug(' DST_SEGMENT30    '||p_mti_trx_rec.DST_SEGMENT30);
         mydebug(' REQUISITION_LINE_ID      '||p_mti_trx_rec.REQUISITION_LINE_ID);
         mydebug(' CURRENCY_CODE    '||p_mti_trx_rec.CURRENCY_CODE);
         mydebug(' CURRENCY_CONVERSION_DATE     '||TO_CHAR(p_mti_trx_rec.CURRENCY_CONVERSION_DATE, l_date_format));
         mydebug(' CURRENCY_CONVERSION_TYPE         '||p_mti_trx_rec.CURRENCY_CONVERSION_TYPE);
         mydebug(' CURRENCY_CONVERSION_RATE         '||p_mti_trx_rec.CURRENCY_CONVERSION_RATE);
         mydebug(' USSGL_TRANSACTION_CODE   '||p_mti_trx_rec.USSGL_TRANSACTION_CODE);
         mydebug(' WIP_ENTITY_TYPE  '||p_mti_trx_rec.WIP_ENTITY_TYPE);
         mydebug(' SCHEDULE_ID      '||p_mti_trx_rec.SCHEDULE_ID);
         mydebug(' EMPLOYEE_CODE    '||p_mti_trx_rec.EMPLOYEE_CODE);
         mydebug(' DEPARTMENT_ID    '||p_mti_trx_rec.DEPARTMENT_ID);
         mydebug(' SCHEDULE_UPDATE_CODE     '||p_mti_trx_rec.SCHEDULE_UPDATE_CODE);
         mydebug(' SETUP_TEARDOWN_CODE      '||p_mti_trx_rec.SETUP_TEARDOWN_CODE);
         mydebug(' PRIMARY_SWITCH   '||p_mti_trx_rec.PRIMARY_SWITCH);
         mydebug(' MRP_CODE         '||p_mti_trx_rec.MRP_CODE);
         mydebug(' OPERATION_SEQ_NUM        '||p_mti_trx_rec.OPERATION_SEQ_NUM);
         mydebug(' REPETITIVE_LINE_ID       '||p_mti_trx_rec.REPETITIVE_LINE_ID);
         mydebug(' PICKING_LINE_ID  '||p_mti_trx_rec.PICKING_LINE_ID);
         mydebug(' TRX_SOURCE_LINE_ID       '||p_mti_trx_rec.TRX_SOURCE_LINE_ID);
         mydebug(' TRX_SOURCE_DELIVERY_ID   '||p_mti_trx_rec.TRX_SOURCE_DELIVERY_ID);
         mydebug(' DEMAND_ID        '||p_mti_trx_rec.DEMAND_ID);
         mydebug(' CUSTOMER_SHIP_ID         '||p_mti_trx_rec.CUSTOMER_SHIP_ID);
         mydebug(' LINE_ITEM_NUM    '||p_mti_trx_rec.LINE_ITEM_NUM);
         mydebug(' RECEIVING_DOCUMENT       '||p_mti_trx_rec.RECEIVING_DOCUMENT);
         mydebug(' RCV_TRANSACTION_ID       '||p_mti_trx_rec.RCV_TRANSACTION_ID);
         mydebug(' SHIP_TO_LOCATION_ID      '||p_mti_trx_rec.SHIP_TO_LOCATION_ID);
         mydebug(' ENCUMBRANCE_ACCOUNT      '||p_mti_trx_rec.ENCUMBRANCE_ACCOUNT);
         mydebug(' ENCUMBRANCE_AMOUNT       '||p_mti_trx_rec.ENCUMBRANCE_AMOUNT);
         mydebug(' VENDOR_LOT_NUMBER        '||p_mti_trx_rec.VENDOR_LOT_NUMBER);
         mydebug(' TRANSFER_SUBINVENTORY    '||p_mti_trx_rec.TRANSFER_SUBINVENTORY);
         mydebug(' TRANSFER_ORGANIZATION    '||p_mti_trx_rec.TRANSFER_ORGANIZATION);
         mydebug(' TRANSFER_LOCATOR         '||p_mti_trx_rec.TRANSFER_LOCATOR);
         mydebug(' XFER_LOC_SEGMENT1        '||p_mti_trx_rec.XFER_LOC_SEGMENT1);
         mydebug(' XFER_LOC_SEGMENT2        '||p_mti_trx_rec.XFER_LOC_SEGMENT2);
         mydebug(' XFER_LOC_SEGMENT3        '||p_mti_trx_rec.XFER_LOC_SEGMENT3);
         mydebug(' XFER_LOC_SEGMENT4        '||p_mti_trx_rec.XFER_LOC_SEGMENT4);
         mydebug(' XFER_LOC_SEGMENT5        '||p_mti_trx_rec.XFER_LOC_SEGMENT5);
         mydebug(' XFER_LOC_SEGMENT6        '||p_mti_trx_rec.XFER_LOC_SEGMENT6);
         mydebug(' XFER_LOC_SEGMENT7        '||p_mti_trx_rec.XFER_LOC_SEGMENT7);
         mydebug(' XFER_LOC_SEGMENT8        '||p_mti_trx_rec.XFER_LOC_SEGMENT8);
         mydebug(' XFER_LOC_SEGMENT9        '||p_mti_trx_rec.XFER_LOC_SEGMENT9);
         mydebug(' XFER_LOC_SEGMENT10       '||p_mti_trx_rec.XFER_LOC_SEGMENT10);
         mydebug(' XFER_LOC_SEGMENT11       '||p_mti_trx_rec.XFER_LOC_SEGMENT11);
         mydebug(' XFER_LOC_SEGMENT12       '||p_mti_trx_rec.XFER_LOC_SEGMENT12);
         mydebug(' XFER_LOC_SEGMENT13       '||p_mti_trx_rec.XFER_LOC_SEGMENT13);
         mydebug(' XFER_LOC_SEGMENT14       '||p_mti_trx_rec.XFER_LOC_SEGMENT14);
         mydebug(' XFER_LOC_SEGMENT15       '||p_mti_trx_rec.XFER_LOC_SEGMENT15);
         mydebug(' XFER_LOC_SEGMENT16       '||p_mti_trx_rec.XFER_LOC_SEGMENT16);
         mydebug(' XFER_LOC_SEGMENT17       '||p_mti_trx_rec.XFER_LOC_SEGMENT17);
         mydebug(' XFER_LOC_SEGMENT18       '||p_mti_trx_rec.XFER_LOC_SEGMENT18);
         mydebug(' XFER_LOC_SEGMENT19       '||p_mti_trx_rec.XFER_LOC_SEGMENT19);
         mydebug(' XFER_LOC_SEGMENT20       '||p_mti_trx_rec.XFER_LOC_SEGMENT20);
         mydebug(' SHIPMENT_NUMBER  '||p_mti_trx_rec.SHIPMENT_NUMBER);
         mydebug(' TRANSPORTATION_COST      '||p_mti_trx_rec.TRANSPORTATION_COST);
         mydebug(' TRANSPORTATION_ACCOUNT   '||p_mti_trx_rec.TRANSPORTATION_ACCOUNT);
         mydebug(' TRANSFER_COST    '||p_mti_trx_rec.TRANSFER_COST);
         mydebug(' FREIGHT_CODE     '||p_mti_trx_rec.FREIGHT_CODE);
         mydebug(' CONTAINERS       '||p_mti_trx_rec.CONTAINERS);
         mydebug(' WAYBILL_AIRBILL  '||p_mti_trx_rec.WAYBILL_AIRBILL);
         mydebug(' EXPECTED_ARRIVAL_DATE     '||TO_CHAR(p_mti_trx_rec.EXPECTED_ARRIVAL_DATE, l_date_format));
         mydebug(' NEW_AVERAGE_COST         '||p_mti_trx_rec.NEW_AVERAGE_COST);
         mydebug(' VALUE_CHANGE     '||p_mti_trx_rec.VALUE_CHANGE);
         mydebug(' PERCENTAGE_CHANGE        '||p_mti_trx_rec.PERCENTAGE_CHANGE);
         mydebug(' DEMAND_SOURCE_HEADER_ID  '||p_mti_trx_rec.DEMAND_SOURCE_HEADER_ID);
         mydebug(' DEMAND_SOURCE_LINE       '||p_mti_trx_rec.DEMAND_SOURCE_LINE);
         mydebug(' DEMAND_SOURCE_DELIVERY   '||p_mti_trx_rec.DEMAND_SOURCE_DELIVERY);
         mydebug(' NEGATIVE_REQ_FLAG        '||p_mti_trx_rec.NEGATIVE_REQ_FLAG);
         mydebug(' ERROR_EXPLANATION        '||p_mti_trx_rec.ERROR_EXPLANATION);
         mydebug(' SHIPPABLE_FLAG   '||p_mti_trx_rec.SHIPPABLE_FLAG);
         mydebug(' ERROR_CODE       '||p_mti_trx_rec.ERROR_CODE);
         mydebug(' REQUIRED_FLAG    '||p_mti_trx_rec.REQUIRED_FLAG);
         mydebug(' ATTRIBUTE_CATEGORY       '||p_mti_trx_rec.ATTRIBUTE_CATEGORY);
         mydebug(' ATTRIBUTE1       '||p_mti_trx_rec.ATTRIBUTE1);
         mydebug(' ATTRIBUTE2       '||p_mti_trx_rec.ATTRIBUTE2);
         mydebug(' ATTRIBUTE3       '||p_mti_trx_rec.ATTRIBUTE3);
         mydebug(' ATTRIBUTE4       '||p_mti_trx_rec.ATTRIBUTE4);
         mydebug(' ATTRIBUTE5       '||p_mti_trx_rec.ATTRIBUTE5);
         mydebug(' ATTRIBUTE6       '||p_mti_trx_rec.ATTRIBUTE6);
         mydebug(' ATTRIBUTE7       '||p_mti_trx_rec.ATTRIBUTE7);
         mydebug(' ATTRIBUTE8       '||p_mti_trx_rec.ATTRIBUTE8);
         mydebug(' ATTRIBUTE9       '||p_mti_trx_rec.ATTRIBUTE9);
         mydebug(' ATTRIBUTE10      '||p_mti_trx_rec.ATTRIBUTE10);
         mydebug(' ATTRIBUTE11      '||p_mti_trx_rec.ATTRIBUTE11);
         mydebug(' ATTRIBUTE12      '||p_mti_trx_rec.ATTRIBUTE12);
         mydebug(' ATTRIBUTE13      '||p_mti_trx_rec.ATTRIBUTE13);
         mydebug(' ATTRIBUTE14      '||p_mti_trx_rec.ATTRIBUTE14);
         mydebug(' ATTRIBUTE15      '||p_mti_trx_rec.ATTRIBUTE15);
         mydebug(' REQUISITION_DISTRIBUTION_ID      '||p_mti_trx_rec.REQUISITION_DISTRIBUTION_ID);
         mydebug(' MOVEMENT_ID      '||p_mti_trx_rec.MOVEMENT_ID);
         mydebug(' RESERVATION_QUANTITY     '||p_mti_trx_rec.RESERVATION_QUANTITY);
         mydebug(' SHIPPED_QUANTITY         '||p_mti_trx_rec.SHIPPED_QUANTITY);
         mydebug(' INVENTORY_ITEM   '||p_mti_trx_rec.INVENTORY_ITEM);
         mydebug(' LOCATOR_NAME     '||p_mti_trx_rec.LOCATOR_NAME);
         mydebug(' TASK_ID  '||p_mti_trx_rec.TASK_ID);
         mydebug(' TO_TASK_ID       '||p_mti_trx_rec.TO_TASK_ID);
         mydebug(' SOURCE_TASK_ID   '||p_mti_trx_rec.SOURCE_TASK_ID);
         mydebug(' PROJECT_ID       '||p_mti_trx_rec.PROJECT_ID);
         mydebug(' TO_PROJECT_ID    '||p_mti_trx_rec.TO_PROJECT_ID);
         mydebug(' SOURCE_PROJECT_ID        '||p_mti_trx_rec.SOURCE_PROJECT_ID);
         mydebug(' PA_EXPENDITURE_ORG_ID    '||p_mti_trx_rec.PA_EXPENDITURE_ORG_ID);
         mydebug(' EXPENDITURE_TYPE         '||p_mti_trx_rec.EXPENDITURE_TYPE);
         mydebug(' FINAL_COMPLETION_FLAG    '||p_mti_trx_rec.FINAL_COMPLETION_FLAG);
         mydebug(' TRANSFER_PERCENTAGE      '||p_mti_trx_rec.TRANSFER_PERCENTAGE);
         mydebug(' TRANSACTION_SEQUENCE_ID  '||p_mti_trx_rec.TRANSACTION_SEQUENCE_ID);
         mydebug(' MATERIAL_ACCOUNT         '||p_mti_trx_rec.MATERIAL_ACCOUNT);
         mydebug(' MATERIAL_OVERHEAD_ACCOUNT        '||p_mti_trx_rec.MATERIAL_OVERHEAD_ACCOUNT);
         mydebug(' RESOURCE_ACCOUNT         '||p_mti_trx_rec.RESOURCE_ACCOUNT);
         mydebug(' OUTSIDE_PROCESSING_ACCOUNT       '||p_mti_trx_rec.OUTSIDE_PROCESSING_ACCOUNT);
         mydebug(' OVERHEAD_ACCOUNT         '||p_mti_trx_rec.OVERHEAD_ACCOUNT);
         mydebug(' BOM_REVISION     '||p_mti_trx_rec.BOM_REVISION);
         mydebug(' ROUTING_REVISION         '||p_mti_trx_rec.ROUTING_REVISION);
         mydebug(' BOM_REVISION_DATE     '||TO_CHAR(p_mti_trx_rec.BOM_REVISION_DATE, l_date_format));
         mydebug(' ROUTING_REVISION_DATE     '||TO_CHAR(p_mti_trx_rec.ROUTING_REVISION_DATE, l_date_format));
         mydebug(' ALTERNATE_BOM_DESIGNATOR         '||p_mti_trx_rec.ALTERNATE_BOM_DESIGNATOR);
         mydebug(' ALTERNATE_ROUTING_DESIGNATOR     '||p_mti_trx_rec.ALTERNATE_ROUTING_DESIGNATOR);
         mydebug(' ACCOUNTING_CLASS         '||p_mti_trx_rec.ACCOUNTING_CLASS);
         mydebug(' DEMAND_CLASS     '||p_mti_trx_rec.DEMAND_CLASS);
         mydebug(' PARENT_ID        '||p_mti_trx_rec.PARENT_ID);
         mydebug(' SUBSTITUTION_TYPE_ID     '||p_mti_trx_rec.SUBSTITUTION_TYPE_ID);
         mydebug(' SUBSTITUTION_ITEM_ID     '||p_mti_trx_rec.SUBSTITUTION_ITEM_ID);
         mydebug(' SCHEDULE_GROUP   '||p_mti_trx_rec.SCHEDULE_GROUP);
         mydebug(' BUILD_SEQUENCE   '||p_mti_trx_rec.BUILD_SEQUENCE);
         mydebug(' SCHEDULE_NUMBER  '||p_mti_trx_rec.SCHEDULE_NUMBER);
         mydebug(' SCHEDULED_FLAG   '||p_mti_trx_rec.SCHEDULED_FLAG);
         mydebug(' FLOW_SCHEDULE    '||p_mti_trx_rec.FLOW_SCHEDULE);
         mydebug(' COST_GROUP_ID    '||p_mti_trx_rec.COST_GROUP_ID);
         mydebug(' KANBAN_CARD_ID   '||p_mti_trx_rec.KANBAN_CARD_ID);
         mydebug(' QA_COLLECTION_ID         '||p_mti_trx_rec.QA_COLLECTION_ID);
         mydebug(' OVERCOMPLETION_TRANSACTION_QTY   '||p_mti_trx_rec.OVERCOMPLETION_TRANSACTION_QTY);
         mydebug(' OVERCOMPLETION_PRIMARY_QTY       '||p_mti_trx_rec.OVERCOMPLETION_PRIMARY_QTY);
         mydebug(' OVERCOMPLETION_TRANSACTION_ID    '||p_mti_trx_rec.OVERCOMPLETION_TRANSACTION_ID);
         mydebug(' END_ITEM_UNIT_NUMBER     '||p_mti_trx_rec.END_ITEM_UNIT_NUMBER);
         mydebug(' SCHEDULED_PAYBACK_DATE     '||TO_CHAR(p_mti_trx_rec.SCHEDULED_PAYBACK_DATE, l_date_format));
         mydebug(' ORG_COST_GROUP_ID        '||p_mti_trx_rec.ORG_COST_GROUP_ID);
         mydebug(' COST_TYPE_ID     '||p_mti_trx_rec.COST_TYPE_ID);
         mydebug(' SOURCE_LOT_NUMBER        '||p_mti_trx_rec.SOURCE_LOT_NUMBER);
         mydebug(' TRANSFER_COST_GROUP_ID   '||p_mti_trx_rec.TRANSFER_COST_GROUP_ID);
         mydebug(' LPN_ID   '||p_mti_trx_rec.LPN_ID);
         mydebug(' TRANSFER_LPN_ID  '||p_mti_trx_rec.TRANSFER_LPN_ID);
         mydebug(' CONTENT_LPN_ID   '||p_mti_trx_rec.CONTENT_LPN_ID);
         mydebug(' XML_DOCUMENT_ID  '||p_mti_trx_rec.XML_DOCUMENT_ID);
         mydebug(' ORGANIZATION_TYPE        '||p_mti_trx_rec.ORGANIZATION_TYPE);
         mydebug(' TRANSFER_ORGANIZATION_TYPE       '||p_mti_trx_rec.TRANSFER_ORGANIZATION_TYPE);
         mydebug(' OWNING_ORGANIZATION_ID   '||p_mti_trx_rec.OWNING_ORGANIZATION_ID);
         mydebug(' OWNING_TP_TYPE   '||p_mti_trx_rec.OWNING_TP_TYPE);
         mydebug(' XFR_OWNING_ORGANIZATION_ID       '||p_mti_trx_rec.XFR_OWNING_ORGANIZATION_ID);
         mydebug(' TRANSFER_OWNING_TP_TYPE  '||p_mti_trx_rec.TRANSFER_OWNING_TP_TYPE);
         mydebug(' PLANNING_ORGANIZATION_ID         '||p_mti_trx_rec.PLANNING_ORGANIZATION_ID);
         mydebug(' PLANNING_TP_TYPE         '||p_mti_trx_rec.PLANNING_TP_TYPE);
         mydebug(' XFR_PLANNING_ORGANIZATION_ID     '||p_mti_trx_rec.XFR_PLANNING_ORGANIZATION_ID);
         mydebug(' TRANSFER_PLANNING_TP_TYPE        '||p_mti_trx_rec.TRANSFER_PLANNING_TP_TYPE);
         mydebug(' SECONDARY_UOM_CODE       '||p_mti_trx_rec.SECONDARY_UOM_CODE);
         mydebug(' SECONDARY_TRANSACTION_QUANTITY   '||p_mti_trx_rec.SECONDARY_TRANSACTION_QUANTITY);
         -- Bug 9239746 : Commenting the following two columns as they are obsolete.
         -- mydebug(' TRANSACTION_GROUP_ID     '||p_mti_trx_rec.TRANSACTION_GROUP_ID);
         -- mydebug(' TRANSACTION_GROUP_SEQ    '||p_mti_trx_rec.TRANSACTION_GROUP_SEQ);
         mydebug(' REPRESENTATIVE_LOT_NUMBER        '||p_mti_trx_rec.REPRESENTATIVE_LOT_NUMBER);
         mydebug(' TRANSACTION_BATCH_ID     '||p_mti_trx_rec.TRANSACTION_BATCH_ID);
         mydebug(' TRANSACTION_BATCH_SEQ    '||p_mti_trx_rec.TRANSACTION_BATCH_SEQ);
         mydebug(' REBUILD_ITEM_ID  '||p_mti_trx_rec.REBUILD_ITEM_ID);
         mydebug(' REBUILD_SERIAL_NUMBER    '||p_mti_trx_rec.REBUILD_SERIAL_NUMBER);
         mydebug(' REBUILD_ACTIVITY_ID      '||p_mti_trx_rec.REBUILD_ACTIVITY_ID);
         mydebug(' REBUILD_JOB_NAME         '||p_mti_trx_rec.REBUILD_JOB_NAME);
         mydebug(' MOVE_TRANSACTION_ID      '||p_mti_trx_rec.MOVE_TRANSACTION_ID);
         mydebug(' COMPLETION_TRANSACTION_ID        '||p_mti_trx_rec.COMPLETION_TRANSACTION_ID);
         mydebug(' WIP_SUPPLY_TYPE  '||p_mti_trx_rec.WIP_SUPPLY_TYPE);
         mydebug(' RELIEVE_RESERVATIONS_FLAG        '||p_mti_trx_rec.RELIEVE_RESERVATIONS_FLAG);
         mydebug(' RELIEVE_HIGH_LEVEL_RSV_FLAG      '||p_mti_trx_rec.RELIEVE_HIGH_LEVEL_RSV_FLAG);
         mydebug(' TRANSFER_PRICE   '||p_mti_trx_rec.TRANSFER_PRICE);
--      END IF;
--      IF ((l_debug = 1) AND (p_mtli_lot_rec.COUNT > 0 )) THEN
         mydebug(' TRANSACTION_INTERFACE_ID      '||p_mtli_lot_rec.TRANSACTION_INTERFACE_ID);
         mydebug(' SOURCE_CODE   '||p_mtli_lot_rec.SOURCE_CODE);
         mydebug(' SOURCE_LINE_ID        '||p_mtli_lot_rec.SOURCE_LINE_ID);
         mydebug(' LAST_UPDATE_DATE     '||TO_CHAR(p_mtlt_lot_rec.LAST_UPDATE_DATE, l_date_format));
         mydebug(' LAST_UPDATED_BY       '||p_mtli_lot_rec.LAST_UPDATED_BY);
         mydebug(' CREATION_DATE     '||TO_CHAR(p_mtlt_lot_rec.CREATION_DATE, l_date_format));
         mydebug(' CREATED_BY    '||p_mtli_lot_rec.CREATED_BY);
         mydebug(' LAST_UPDATE_LOGIN     '||p_mtli_lot_rec.LAST_UPDATE_LOGIN);
         mydebug(' REQUEST_ID    '||p_mtli_lot_rec.REQUEST_ID);
         mydebug(' PROGRAM_APPLICATION_ID        '||p_mtli_lot_rec.PROGRAM_APPLICATION_ID);
         mydebug(' PROGRAM_ID    '||p_mtli_lot_rec.PROGRAM_ID);
         mydebug(' PROGRAM_UPDATE_DATE     '||TO_CHAR(p_mtlt_lot_rec.PROGRAM_UPDATE_DATE, l_date_format));
         mydebug(' LOT_NUMBER    '||p_mtli_lot_rec.LOT_NUMBER);
         mydebug(' LOT_EXPIRATION_DATE     '||TO_CHAR(p_mtlt_lot_rec.LOT_EXPIRATION_DATE, l_date_format));
         mydebug(' TRANSACTION_QUANTITY  '||p_mtli_lot_rec.TRANSACTION_QUANTITY);
         mydebug(' PRIMARY_QUANTITY      '||p_mtli_lot_rec.PRIMARY_QUANTITY);
         mydebug(' SERIAL_TRANSACTION_TEMP_ID    '||p_mtli_lot_rec.SERIAL_TRANSACTION_TEMP_ID);
         mydebug(' ERROR_CODE    '||p_mtli_lot_rec.ERROR_CODE);
         mydebug(' PROCESS_FLAG  '||p_mtli_lot_rec.PROCESS_FLAG);
         mydebug(' DESCRIPTION   '||p_mtli_lot_rec.DESCRIPTION);
         mydebug(' VENDOR_NAME   '||p_mtli_lot_rec.VENDOR_NAME);
         mydebug(' SUPPLIER_LOT_NUMBER   '||p_mtli_lot_rec.SUPPLIER_LOT_NUMBER);
         mydebug(' ORIGINATION_DATE     '||TO_CHAR(p_mtlt_lot_rec.ORIGINATION_DATE, l_date_format));
         mydebug(' DATE_CODE     '||p_mtli_lot_rec.DATE_CODE);
         mydebug(' GRADE_CODE    '||p_mtli_lot_rec.GRADE_CODE);
         mydebug(' CHANGE_DATE     '||TO_CHAR(p_mtlt_lot_rec.CHANGE_DATE, l_date_format));
         mydebug(' MATURITY_DATE     '||TO_CHAR(p_mtlt_lot_rec.MATURITY_DATE, l_date_format));
         mydebug(' STATUS_ID     '||p_mtli_lot_rec.STATUS_ID);
         mydebug(' RETEST_DATE     '||TO_CHAR(p_mtlt_lot_rec.RETEST_DATE, l_date_format));
         mydebug(' AGE   '||p_mtli_lot_rec.AGE);
         mydebug(' ITEM_SIZE     '||p_mtli_lot_rec.ITEM_SIZE);
         mydebug(' COLOR         '||p_mtli_lot_rec.COLOR);
         mydebug(' VOLUME        '||p_mtli_lot_rec.VOLUME);
         mydebug(' VOLUME_UOM    '||p_mtli_lot_rec.VOLUME_UOM);
         mydebug(' PLACE_OF_ORIGIN       '||p_mtli_lot_rec.PLACE_OF_ORIGIN);
         mydebug(' BEST_BY_DATE     '||TO_CHAR(p_mtlt_lot_rec.BEST_BY_DATE, l_date_format));
         mydebug(' LENGTH        '||p_mtli_lot_rec.LENGTH);
         mydebug(' LENGTH_UOM    '||p_mtli_lot_rec.LENGTH_UOM);
         mydebug(' RECYCLED_CONTENT      '||p_mtli_lot_rec.RECYCLED_CONTENT);
         mydebug(' THICKNESS     '||p_mtli_lot_rec.THICKNESS);
         mydebug(' THICKNESS_UOM         '||p_mtli_lot_rec.THICKNESS_UOM);
         mydebug(' WIDTH         '||p_mtli_lot_rec.WIDTH);
         mydebug(' WIDTH_UOM     '||p_mtli_lot_rec.WIDTH_UOM);
         mydebug(' CURL_WRINKLE_FOLD     '||p_mtli_lot_rec.CURL_WRINKLE_FOLD);
         mydebug(' LOT_ATTRIBUTE_CATEGORY        '||p_mtli_lot_rec.LOT_ATTRIBUTE_CATEGORY);
         mydebug(' C_ATTRIBUTE1  '||p_mtli_lot_rec.C_ATTRIBUTE1);
         mydebug(' C_ATTRIBUTE2  '||p_mtli_lot_rec.C_ATTRIBUTE2);
         mydebug(' C_ATTRIBUTE3  '||p_mtli_lot_rec.C_ATTRIBUTE3);
         mydebug(' C_ATTRIBUTE4  '||p_mtli_lot_rec.C_ATTRIBUTE4);
         mydebug(' C_ATTRIBUTE5  '||p_mtli_lot_rec.C_ATTRIBUTE5);
         mydebug(' C_ATTRIBUTE6  '||p_mtli_lot_rec.C_ATTRIBUTE6);
         mydebug(' C_ATTRIBUTE7  '||p_mtli_lot_rec.C_ATTRIBUTE7);
         mydebug(' C_ATTRIBUTE8  '||p_mtli_lot_rec.C_ATTRIBUTE8);
         mydebug(' C_ATTRIBUTE9  '||p_mtli_lot_rec.C_ATTRIBUTE9);
         mydebug(' C_ATTRIBUTE10         '||p_mtli_lot_rec.C_ATTRIBUTE10);
         mydebug(' C_ATTRIBUTE11         '||p_mtli_lot_rec.C_ATTRIBUTE11);
         mydebug(' C_ATTRIBUTE12         '||p_mtli_lot_rec.C_ATTRIBUTE12);
         mydebug(' C_ATTRIBUTE13         '||p_mtli_lot_rec.C_ATTRIBUTE13);
         mydebug(' C_ATTRIBUTE14         '||p_mtli_lot_rec.C_ATTRIBUTE14);
         mydebug(' C_ATTRIBUTE15         '||p_mtli_lot_rec.C_ATTRIBUTE15);
         mydebug(' C_ATTRIBUTE16         '||p_mtli_lot_rec.C_ATTRIBUTE16);
         mydebug(' C_ATTRIBUTE17         '||p_mtli_lot_rec.C_ATTRIBUTE17);
         mydebug(' C_ATTRIBUTE18         '||p_mtli_lot_rec.C_ATTRIBUTE18);
         mydebug(' C_ATTRIBUTE19         '||p_mtli_lot_rec.C_ATTRIBUTE19);
         mydebug(' C_ATTRIBUTE20         '||p_mtli_lot_rec.C_ATTRIBUTE20);
         mydebug(' D_ATTRIBUTE1     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE1, l_date_format));
         mydebug(' D_ATTRIBUTE2     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE2, l_date_format));
         mydebug(' D_ATTRIBUTE3     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE3, l_date_format));
         mydebug(' D_ATTRIBUTE4     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE4, l_date_format));
         mydebug(' D_ATTRIBUTE5     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE5, l_date_format));
         mydebug(' D_ATTRIBUTE6     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE6, l_date_format));
         mydebug(' D_ATTRIBUTE7     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE7, l_date_format));
         mydebug(' D_ATTRIBUTE8     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE8, l_date_format));
         mydebug(' D_ATTRIBUTE9     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE9, l_date_format));
         mydebug(' D_ATTRIBUTE10     '||TO_CHAR(p_mtlt_lot_rec.D_ATTRIBUTE10, l_date_format));
         mydebug(' N_ATTRIBUTE1  '||p_mtli_lot_rec.N_ATTRIBUTE1);
         mydebug(' N_ATTRIBUTE2  '||p_mtli_lot_rec.N_ATTRIBUTE2);
         mydebug(' N_ATTRIBUTE3  '||p_mtli_lot_rec.N_ATTRIBUTE3);
         mydebug(' N_ATTRIBUTE4  '||p_mtli_lot_rec.N_ATTRIBUTE4);
         mydebug(' N_ATTRIBUTE5  '||p_mtli_lot_rec.N_ATTRIBUTE5);
         mydebug(' N_ATTRIBUTE6  '||p_mtli_lot_rec.N_ATTRIBUTE6);
         mydebug(' N_ATTRIBUTE7  '||p_mtli_lot_rec.N_ATTRIBUTE7);
         mydebug(' N_ATTRIBUTE8  '||p_mtli_lot_rec.N_ATTRIBUTE8);
         mydebug(' N_ATTRIBUTE9  '||p_mtli_lot_rec.N_ATTRIBUTE9);
         mydebug(' N_ATTRIBUTE10         '||p_mtli_lot_rec.N_ATTRIBUTE10);
         mydebug(' VENDOR_ID     '||p_mtli_lot_rec.VENDOR_ID);
         mydebug(' TERRITORY_CODE        '||p_mtli_lot_rec.TERRITORY_CODE);
         mydebug(' PRODUCT_CODE  '||p_mtli_lot_rec.PRODUCT_CODE);
         mydebug(' PRODUCT_TRANSACTION_ID        '||p_mtli_lot_rec.PRODUCT_TRANSACTION_ID);
         mydebug(' SECONDARY_TRANSACTION_QUANTITY        '||p_mtli_lot_rec.SECONDARY_TRANSACTION_QUANTITY);
         mydebug(' SUBLOT_NUM    '||p_mtli_lot_rec.SUBLOT_NUM);
         mydebug(' REASON_CODE   '||p_mtli_lot_rec.REASON_CODE);
         mydebug(' ATTRIBUTE_CATEGORY    '||p_mtli_lot_rec.ATTRIBUTE_CATEGORY);
         mydebug(' ATTRIBUTE1    '||p_mtli_lot_rec.ATTRIBUTE1);
         mydebug(' ATTRIBUTE2    '||p_mtli_lot_rec.ATTRIBUTE2);
         mydebug(' ATTRIBUTE3    '||p_mtli_lot_rec.ATTRIBUTE3);
         mydebug(' ATTRIBUTE4    '||p_mtli_lot_rec.ATTRIBUTE4);
         mydebug(' ATTRIBUTE5    '||p_mtli_lot_rec.ATTRIBUTE5);
         mydebug(' ATTRIBUTE6    '||p_mtli_lot_rec.ATTRIBUTE6);
         mydebug(' ATTRIBUTE7    '||p_mtli_lot_rec.ATTRIBUTE7);
         mydebug(' ATTRIBUTE8    '||p_mtli_lot_rec.ATTRIBUTE8);
         mydebug(' ATTRIBUTE9    '||p_mtli_lot_rec.ATTRIBUTE9);
         mydebug(' ATTRIBUTE10   '||p_mtli_lot_rec.ATTRIBUTE10);
         mydebug(' ATTRIBUTE11   '||p_mtli_lot_rec.ATTRIBUTE11);
         mydebug(' ATTRIBUTE12   '||p_mtli_lot_rec.ATTRIBUTE12);
         mydebug(' ATTRIBUTE13   '||p_mtli_lot_rec.ATTRIBUTE13);
         mydebug(' ATTRIBUTE14   '||p_mtli_lot_rec.ATTRIBUTE14);
         mydebug(' ATTRIBUTE15   '||p_mtli_lot_rec.ATTRIBUTE15);
         mydebug(' EXPIRATION_ACTION_CODE        '||p_mtli_lot_rec.EXPIRATION_ACTION_CODE);
         mydebug(' EXPIRATION_ACTION_DATE     '||TO_CHAR(p_mtlt_lot_rec.EXPIRATION_ACTION_DATE, l_date_format));
         mydebug(' HOLD_DATE     '||TO_CHAR(p_mtlt_lot_rec.HOLD_DATE, l_date_format));
         mydebug(' ORIGINATION_TYPE      '||p_mtli_lot_rec.ORIGINATION_TYPE);
         mydebug(' PARENT_LOT_NUMBER     '||p_mtli_lot_rec.PARENT_LOT_NUMBER);
         mydebug(' REASON_ID     '||p_mtli_lot_rec.REASON_ID);
         mydebug(' PARENT_OBJECT_TYPE    '||p_mtli_lot_rec.PARENT_OBJECT_TYPE);
         mydebug(' PARENT_OBJECT_ID      '||p_mtli_lot_rec.PARENT_OBJECT_ID);
         mydebug(' PARENT_OBJECT_NUMBER  '||p_mtli_lot_rec.PARENT_OBJECT_NUMBER);
         mydebug(' PARENT_ITEM_ID        '||p_mtli_lot_rec.PARENT_ITEM_ID);
         mydebug(' PARENT_OBJECT_TYPE2   '||p_mtli_lot_rec.PARENT_OBJECT_TYPE2);
         mydebug(' PARENT_OBJECT_ID2     '||p_mtli_lot_rec.PARENT_OBJECT_ID2);
         mydebug(' PARENT_OBJECT_NUMBER2         '||p_mtli_lot_rec.PARENT_OBJECT_NUMBER2);
      END IF;
   EXCEPTION
   WHEN OTHERS THEN
      mydebug('WHEN OTHERS exception : '||SQLERRM, 'LOG_TRANSACTION_REC');
   END log_transaction_rec;

END INV_CALCULATE_EXP_DATE;

/
