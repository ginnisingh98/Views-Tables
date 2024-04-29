--------------------------------------------------------
--  DDL for Package Body GME_PENDING_PRODUCT_LOTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_PENDING_PRODUCT_LOTS_PVT" AS
/* $Header: GMEVPPLB.pls 120.15.12010000.2 2009/05/06 19:16:32 srpuri ship $ */

  g_debug      VARCHAR2 (5) := fnd_profile.VALUE ('AFLOG_LEVEL');
  g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_PENDING_PRODUCT_LOTS_PVT';

/*************************************************************************************************/
/* Oracle Process Manufacturing Process Execution APIs                                           */
/*                                                                                               */
/* File Name: GMEVPPLB.pls                                                                       */
/* Contents:  GME pending lot related procedures.                                                */
/* HISTORY:                                                                                      */
/* SivakumarG Bug#5186388 03-MAY-2006                                                            */
/*  Procedure relieve_pending_lots modified to delete the pending lots if transacting qty >=     */
/*  pending lot qty                                                                              */
/* Namit Singhi Bug#5689035. Added procedure get_pnd_prod_lot_qty				 */

/* G. Muratore    Bug 6941158  07-APR-2008                                                       */
/*      Initialized origination type to '1' (for production) before calling INV api to           */
/*      create the lot. PROCEDURE: create_product_lot                                            */
/* K.Swapna Bug#7139549 26-JUN-2008                                                              */
/*    The expiration date is not assigned to the pending product                                 */
/*    lot created when the item's expiration control is by shelf days.                           */
/*     create_product_lot procedure is change.                                                   */
/*************************************************************************************************/

  PROCEDURE get_pending_lot
              (p_material_detail_id       IN  NUMBER
              ,x_return_status            OUT NOCOPY VARCHAR2
              ,x_pending_product_lot_tbl  OUT NOCOPY gme_common_pvt.pending_lots_tab) IS

    CURSOR cur_get_lots (v_mtl_dtl_id NUMBER) IS
    SELECT *
      FROM gme_pending_product_lots
     WHERE material_detail_id = v_mtl_dtl_id
     ORDER BY sequence asc, lot_number asc;

    l_api_name     CONSTANT VARCHAR2 (30)      := 'GET_PENDING_LOT';
  BEGIN
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OPEN  cur_get_lots(p_material_detail_id);
    FETCH cur_get_lots BULK COLLECT INTO x_pending_product_lot_tbl;
    CLOSE cur_get_lots;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END get_pending_lot;

  PROCEDURE relieve_pending_lot
    (p_pending_lot_id           IN  NUMBER
    ,p_quantity                 IN  NUMBER
    ,p_secondary_quantity       IN  NUMBER := NULL
    ,x_return_status            OUT NOCOPY VARCHAR2) IS

    CURSOR cur_get_pending_lot_qty (v_pending_lot_id NUMBER) IS
    SELECT quantity, secondary_quantity
      FROM gme_pending_product_lots
     WHERE pending_product_lot_id = v_pending_lot_id;

    l_qty                        NUMBER;
    l_sec_qty                    NUMBER;
    l_api_name          CONSTANT VARCHAR2 (30)      := 'RELIEVE_PENDING_LOT';
    --Bug#5186388
    l_pending_product_lots_rec   gme_pending_product_lots%ROWTYPE;
    l_return_status              VARCHAR2(1);
    error_delete_row             EXCEPTION;
  BEGIN
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OPEN  cur_get_pending_lot_qty(p_pending_lot_id);
    FETCH cur_get_pending_lot_qty INTO l_qty, l_sec_qty;
    CLOSE cur_get_pending_lot_qty;

    IF p_quantity >= l_qty THEN

      /* Bug#5186388 if transacting qty is greater than pending lot qty then delete the lot
         rather than updating to zero */
      l_pending_product_lots_rec.pending_product_lot_id := p_pending_lot_id;
      delete_pending_product_lot( p_pending_product_lots_rec => l_pending_product_lots_rec
                                 ,x_return_status            => l_return_status
				);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE error_delete_row;
      END IF;

      /*UPDATE gme_pending_product_lots
         SET quantity = 0,
             last_updated_by = gme_common_pvt.g_user_ident,
             last_update_date = gme_common_pvt.g_timestamp,
             last_update_login = gme_common_pvt.g_login_id
       WHERE pending_product_lot_id = p_pending_lot_id;

      IF l_sec_qty IS NOT NULL THEN
        UPDATE gme_pending_product_lots
           SET secondary_quantity = 0
         WHERE pending_product_lot_id = p_pending_lot_id;
      END IF;  -- IF l_sec_qty IS NOT NULL THEN */
    ELSE
      UPDATE gme_pending_product_lots
         SET quantity = quantity - p_quantity,
             last_updated_by = gme_common_pvt.g_user_ident,
             last_update_date = gme_common_pvt.g_timestamp,
             last_update_login = gme_common_pvt.g_login_id
       WHERE pending_product_lot_id = p_pending_lot_id;

      IF l_sec_qty IS NOT NULL THEN
        UPDATE gme_pending_product_lots
           SET secondary_quantity = secondary_quantity - p_secondary_quantity
         WHERE pending_product_lot_id = p_pending_lot_id;
      END IF;  -- IF l_sec_qty IS NOT NULL THEN
    END IF;  -- IF p_quantity >= l_qty THEN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;
  EXCEPTION
    --Bug#5186388
    WHEN ERROR_DELETE_ROW THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END relieve_pending_lot;

  PROCEDURE create_product_lot
    (p_organization_id       IN              NUMBER
    ,p_inventory_item_id     IN              NUMBER
    ,p_parent_lot            IN              mtl_lot_numbers.lot_number%TYPE := NULL
    ,p_mmli_tbl              IN              gme_common_pvt.mtl_trans_lots_inter_tbl
    ,p_generate_lot          IN              VARCHAR2
    ,p_generate_parent_lot   IN              VARCHAR2
    /* nsinghi bug#4486074 Added the p_expiration_Date parameter. */
    ,p_expiration_date       IN              mtl_lot_numbers.expiration_date%TYPE := NULL
    ,x_mmli_tbl              OUT NOCOPY      gme_common_pvt.mtl_trans_lots_inter_tbl
    ,x_return_status         OUT NOCOPY      VARCHAR2) IS

    l_parent_lot             mtl_lot_numbers.lot_number%TYPE;
    l_gen_lot                mtl_lot_numbers.lot_number%TYPE;
    l_in_lot_rec             mtl_lot_numbers%ROWTYPE;
    l_lot_rec                mtl_lot_numbers%ROWTYPE;
    l_null_lot_number        BOOLEAN;

    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2 (2000);

    l_api_version            NUMBER := 1.0;
    l_source                 NUMBER;
    l_row_id                 ROWID;
    l_shelf_life_code        NUMBER;
    l_shelf_life_days        NUMBER;

    error_null_exp_dt        EXCEPTION;
    error_not_prod           EXCEPTION;
    error_get_item_rec       EXCEPTION;
    error_gen_lot_no_create  EXCEPTION;
    error_gen_lot            EXCEPTION;
    error_gen_parent_lot     EXCEPTION;
    error_lot_create         EXCEPTION;
    error_null_lots          EXCEPTION;

    /* nsinghi bug#4486074 Start */
    CURSOR Cur_item_dtl IS
      SELECT msi.shelf_life_code, msi.shelf_life_days
      FROM mtl_system_items msi
      WHERE msi.inventory_item_id = p_inventory_item_id
      AND    msi.organization_id = p_organization_id;
    /* nsinghi bug#4486074 End */

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'create_product_lot';
  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_organization_id= '||p_organization_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_inventory_item_id= '||p_inventory_item_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_parent_lot= '||p_parent_lot);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' lot count= '||p_mmli_tbl.count);
      FOR i in 1..p_mmli_tbl.count LOOP
        gme_debug.put_line(g_pkg_name||'.'||l_api_name||' lot number= '||p_mmli_tbl (i).lot_number);
      END LOOP;
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_generate_lot= '||p_generate_lot);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_generate_parent_lot= '||p_generate_parent_lot);
    END IF;

    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    x_mmli_tbl := p_mmli_tbl;

    IF p_generate_lot = fnd_api.g_false THEN
      l_null_lot_number := FALSE;

      FOR i in 1..x_mmli_tbl.count LOOP
        IF x_mmli_tbl(i).lot_number IS NULL THEN
          l_null_lot_number := TRUE;
        END IF;
      END LOOP;

      IF l_null_lot_number THEN
        IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
          gme_debug.put_line (g_pkg_name||'.'||l_api_name
                              ||' p_generate is false and there are null lot numbers');
        END IF;
        RAISE error_null_lots;
      END IF;
    END IF;

    l_parent_lot := p_parent_lot;

    IF p_generate_parent_lot = fnd_api.g_true AND p_parent_lot IS NULL THEN
      l_parent_lot :=
                  inv_lot_api_pub.auto_gen_lot
                        (p_org_id                          => p_organization_id
                        ,p_inventory_item_id               => p_inventory_item_id
                        ,p_lot_generation                  => NULL
                        ,p_lot_uniqueness                  => NULL
                        ,p_lot_prefix                      => NULL
                        ,p_zero_pad                        => NULL
                        ,p_lot_length                      => NULL
                        ,p_transaction_date                => NULL
                        ,p_revision                        => NULL
                        ,p_subinventory_code               => NULL
                        ,p_locator_id                      => NULL
                        ,p_transaction_type_id             => NULL
                        ,p_transaction_action_id           => NULL
                        ,p_transaction_source_type_id      => NULL
                        ,p_lot_number                      => NULL
                        ,p_api_version                     => 1.0
                        ,p_init_msg_list                   => fnd_api.g_false
                        ,p_commit                          => fnd_api.g_false
                        ,p_validation_level                => NULL
                        ,p_parent_lot_number               => NULL
                        ,x_return_status                   => x_return_status
                        ,x_msg_count                       => l_msg_count
                        ,x_msg_data                        => l_msg_data);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
          gme_debug.put_line (g_pkg_name||'.'||l_api_name
                              ||'auto_gen_lot for parent returned '
                              || x_return_status);
        END IF;
        RAISE error_gen_parent_lot;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name
                            ||'auto_gen_lot for parent'
                            || ':'
                            || 'l_parent_lot= '
                            || l_parent_lot);
      END IF;
    END IF;  -- IF p_generate_parent_lot = fnd_api.g_true AND p_parent_lot IS NULL THEN

    FOR i IN 1 .. x_mmli_tbl.COUNT LOOP
      IF x_mmli_tbl (i).lot_number IS NULL THEN
        x_mmli_tbl (i).lot_number := inv_lot_api_pub.auto_gen_lot
                           (p_org_id                          => p_organization_id
                           ,p_inventory_item_id               => p_inventory_item_id
                           ,p_lot_generation                  => NULL
                           ,p_lot_uniqueness                  => NULL
                           ,p_lot_prefix                      => NULL
                           ,p_zero_pad                        => NULL
                           ,p_lot_length                      => NULL
                           ,p_transaction_date                => NULL
                           ,p_revision                        => NULL
                           ,p_subinventory_code               => NULL
                           ,p_locator_id                      => NULL
                           ,p_transaction_type_id             => NULL
                           ,p_transaction_action_id           => NULL
                           ,p_transaction_source_type_id      => NULL
                           ,p_lot_number                      => NULL
                           ,p_api_version                     => 1.0
                           ,p_init_msg_list                   => fnd_api.g_false
                           ,p_commit                          => fnd_api.g_false
                           ,p_validation_level                => NULL
                           ,p_parent_lot_number               => l_parent_lot
                           ,x_return_status                   => x_return_status
                           ,x_msg_count                       => l_msg_count
                           ,x_msg_data                        => l_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
              gme_debug.put_line (g_pkg_name||'.'||l_api_name
                                  ||'auto_gen_lot'
                                  || ':'
                                  || 'l_gen_lot '
                                  || x_return_status);
            END IF;
            RAISE error_gen_lot;
        END IF;

        IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (g_pkg_name||'.'||l_api_name
                                ||'auto_gen_lot'
                                || ':'
                                || 'l_gen_lot= '
                                || l_gen_lot);
        END IF;
      END IF;  -- IF x_mmli_tbl (i).lot_number IS NULL THEN

    /* nsinghi bug#4486074 Start */

      OPEN  Cur_item_dtl;
      FETCH Cur_item_dtl INTO l_shelf_life_code, l_shelf_life_days;
      CLOSE Cur_item_dtl;
     /* Bug#7139549 Below code is commented as we do not assign the expiration
  date when the lot is created rather we assign the expiration date when the
transaction is created  for the items having expiration controlled by shelf days*/
/*      IF l_shelf_life_code = 2 THEN /* shelf life days
        l_in_lot_rec.expiration_date := SYSDATE + l_shelf_life_days; */
      IF l_shelf_life_code = 4 THEN
        IF p_expiration_date IS NULL THEN /* user-defined */
          FND_MESSAGE.SET_NAME('INV','INV_NULL_EXPIRATION_DATE_EXP');
          FND_MESSAGE.SET_TOKEN('PGM_NAME',g_pkg_name||'.'||l_api_name);
          fnd_msg_pub.ADD;
          RAISE error_null_exp_dt;
        ELSE
          l_in_lot_rec.expiration_date := p_expiration_date;
        END IF;
      END IF;

    /* nsinghi bug#4486074 End */

      l_in_lot_rec.parent_lot_number         := l_parent_lot;
      l_in_lot_rec.organization_id           := p_organization_id;
      l_in_lot_rec.inventory_item_id         := p_inventory_item_id;
      l_in_lot_rec.lot_number                := x_mmli_tbl (i).lot_number;

      -- Bug 6941158 - Initialize origination type to production
      l_in_lot_rec.origination_type := 1;

      inv_lot_api_pub.create_inv_lot
                            (x_return_status         => x_return_status
                            ,x_msg_count             => l_msg_count
                            ,x_msg_data              => l_msg_data
                            ,x_row_id                => l_row_id
                            ,x_lot_rec               => l_lot_rec
                            ,p_lot_rec               => l_in_lot_rec
                            ,p_source                => l_source
                            ,p_api_version           => l_api_version
                            ,p_init_msg_list         => fnd_api.g_true
                            ,p_commit                => fnd_api.g_false
                            ,p_validation_level      => fnd_api.g_valid_level_full
                            ,p_origin_txn_id         => 1);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE error_lot_create;
      END IF;

      x_mmli_tbl (i).parent_lot_number := l_parent_lot;
    END LOOP;  -- FOR i IN 1 .. l_mmli_tbl.COUNT LOOP

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' lot count= '||p_mmli_tbl.count);
      FOR i in 1..p_mmli_tbl.count LOOP
        gme_debug.put_line(g_pkg_name||'.'||l_api_name||' lot number= '||p_mmli_tbl (i).lot_number);
      END LOOP;
    END IF;

  EXCEPTION
  WHEN error_get_item_rec OR error_gen_parent_lot OR error_gen_lot THEN
    NULL;
  WHEN error_not_prod OR error_lot_create OR error_gen_lot_no_create OR error_null_lots OR error_null_exp_dt THEN
    x_return_status := fnd_api.g_ret_sts_error;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF (NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT) THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;

  END create_product_lot;

  PROCEDURE create_pending_product_lot
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_pending_product_lots_rec   OUT NOCOPY  gme_pending_product_lots%ROWTYPE
    ,x_return_status              OUT NOCOPY VARCHAR2) IS

    l_pp_lot_rec             gme_pending_product_lots%ROWTYPE;
    error_insert_row         EXCEPTION;

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'create_pending_product_lot';

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF NOT gme_pending_product_lots_dbl.insert_row
             (p_pending_product_lots_rec    => p_pending_product_lots_rec
             ,x_pending_product_lots_rec    => l_pp_lot_rec) THEN
      RAISE error_insert_row;
    END IF;

    x_pending_product_lots_rec := l_pp_lot_rec;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN  error_insert_row THEN
      gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
      x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END create_pending_product_lot;

  PROCEDURE update_pending_product_lot
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_pending_product_lots_rec   OUT NOCOPY  gme_pending_product_lots%ROWTYPE
    ,x_return_status              OUT NOCOPY VARCHAR2) IS

    error_update_row         EXCEPTION;
    error_fetch_row          EXCEPTION;
    l_api_name     CONSTANT  VARCHAR2 (30)      := 'update_pending_product_lot';

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF NOT gme_pending_product_lots_dbl.update_row
             (p_pending_product_lots_rec    => p_pending_product_lots_rec) THEN
      RAISE error_update_row;
    END IF;

    IF NOT gme_pending_product_lots_dbl.fetch_row
             (p_pending_product_lots_rec   => p_pending_product_lots_rec
             ,x_pending_product_lots_rec   => x_pending_product_lots_rec)  THEN
      RAISE error_fetch_row;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN error_update_row OR error_fetch_row THEN
      -- error message set in fetch routine
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_pending_product_lot;

  PROCEDURE delete_pending_product_lot
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_return_status              OUT NOCOPY VARCHAR2) IS

    error_delete_row         EXCEPTION;
    l_api_name     CONSTANT  VARCHAR2 (30)      := 'delete_pending_product_lot';

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF NOT gme_pending_product_lots_dbl.delete_row
             (p_pending_product_lots_rec    => p_pending_product_lots_rec) THEN
      RAISE error_delete_row;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN  error_delete_row THEN
      gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
      x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_pending_product_lot;

  --Bug#5078853 created the following over loaded procedure
  PROCEDURE delete_pending_product_lot
    (p_material_detail_id         IN  NUMBER
    ,x_return_status              OUT NOCOPY VARCHAR2)
  IS
    CURSOR c_get_pending_lots IS
      SELECT pending_product_lot_id
        FROM gme_pending_product_lots
       WHERE material_detail_id = p_material_detail_id;

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'delete_pending_product_lot';
    l_pending_product_lots_rec gme_pending_product_lots%ROWTYPE;

    error_delete_row         EXCEPTION;
  BEGIN
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF p_material_detail_id IS NOT NULL THEN
      OPEN c_get_pending_lots;
      LOOP
       FETCH c_get_pending_lots INTO l_pending_product_lots_rec.pending_product_lot_id;
       EXIT WHEN c_get_pending_lots%NOTFOUND;
       --call dbl layer
       IF NOT gme_pending_product_lots_dbl.delete_row
                         (p_pending_product_lots_rec    => l_pending_product_lots_rec) THEN
          CLOSE c_get_pending_lots;
	  RAISE error_delete_row;
       END IF;
      END LOOP;
      CLOSE c_get_pending_lots;
    END IF; /* p_material_detail_id IS NOT NULL*/

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN  error_delete_row THEN
      gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
      x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_pending_product_lot;

  PROCEDURE validate_material_for_create
                        (p_batch_header_rec          IN gme_batch_header%ROWTYPE
                        ,p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2) IS

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_material_for_create';

    l_item_rec               mtl_system_items_b%ROWTYPE;

    error_not_lot_control    EXCEPTION;
    error_no_lot_create      EXCEPTION;
    error_get_item_rec       EXCEPTION;

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    gme_material_detail_pvt.get_item_rec
                (p_org_id                 => p_batch_header_rec.organization_id
                ,p_item_id                => p_material_detail_rec.inventory_item_id
                ,x_item_rec               => l_item_rec
                ,x_return_status          => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE error_get_item_rec;
    END IF;

    IF l_item_rec.lot_control_code = 1 THEN
      FND_MESSAGE.SET_NAME('INV','INV_NO_LOT_CONTROL');
      FND_MESSAGE.SET_TOKEN('PGM_NAME',g_pkg_name||'.'||l_api_name);
      fnd_msg_pub.ADD;
      RAISE error_not_lot_control;
    END IF;

    IF p_batch_header_rec.update_inventory_ind = 'N' THEN
      IF p_material_detail_rec.line_type <> gme_common_pvt.g_line_type_ing THEN
        gme_common_pvt.log_message('GME_NO_LOT_CREATE');
        RAISE error_no_lot_create;
      END IF;
    ELSE
      IF p_material_detail_rec.line_type = gme_common_pvt.g_line_type_ing THEN
        gme_common_pvt.log_message('GME_NO_LOT_CREATE');
        RAISE error_no_lot_create;
      END IF;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN error_not_lot_control OR error_no_lot_create THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_material_for_create;

  FUNCTION get_last_sequence
      (p_matl_dtl_id      IN NUMBER
      ,x_return_status    OUT NOCOPY VARCHAR2)
  RETURN NUMBER IS
    CURSOR cur_get_sequ(v_dtl_id NUMBER) IS
    SELECT max(sequence)
    FROM   gme_pending_product_lots
    WHERE  material_detail_id = v_dtl_id;

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'get_last_sequence';

    l_sequ         NUMBER;

  BEGIN
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering function '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OPEN cur_get_sequ(p_matl_dtl_id);
    FETCH cur_get_sequ INTO l_sequ;
    CLOSE cur_get_sequ;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting function '||g_pkg_name||'.'||l_api_name);
    END IF;

    RETURN NVL(l_sequ, 0);

  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END get_last_sequence;

  PROCEDURE validate_record_for_create
                        (p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,p_pending_product_lots_rec  IN gme_pending_product_lots%ROWTYPE
                        ,p_create_lot                IN VARCHAR2
                        ,p_generate_lot              IN VARCHAR2
                        ,p_generate_parent_lot       IN VARCHAR2
                        ,p_parent_lot                IN mtl_lot_numbers.lot_number%TYPE := NULL
                        /* nsinghi bug#4486074 Added the p_expiration_Date parameter. */
                        ,p_expiration_date           IN mtl_lot_numbers.expiration_date%TYPE := NULL
                        ,x_pending_product_lots_rec  OUT NOCOPY gme_pending_product_lots%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2) IS

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_record_for_create';

    error_validate           EXCEPTION;
    error_create_lot         EXCEPTION;
    error_get_item           EXCEPTION;

    l_mmli_tbl               gme_common_pvt.mtl_trans_lots_inter_tbl;
    l_in_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
    l_lot_number             mtl_lot_numbers.lot_number%TYPE;
    l_dtl_qty                NUMBER;
    l_sec_qty                NUMBER;
    l_item_rec               mtl_system_items_b%ROWTYPE;

    l_sequence               NUMBER;

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    x_pending_product_lots_rec.batch_id           :=  p_material_detail_rec.batch_id;
    x_pending_product_lots_rec.material_detail_id :=  p_material_detail_rec.material_detail_id;

    gme_material_detail_pvt.get_item_rec
                   (p_org_id             => p_material_detail_rec.organization_id
                   ,p_item_id            => p_material_detail_rec.inventory_item_id
                   ,x_item_rec           => l_item_rec
                   ,x_return_status      => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE error_get_item;
    END IF;

    -- Validate following fields:
    /*
    SEQUENCE
    REVISION
    LOT_NUMBER
    QUANTITY
    SECONDARY_QUANTITY
    REASON_ID
     */

    IF p_pending_product_lots_rec.sequence IS NULL THEN
      l_sequence := get_last_sequence
                        (p_matl_dtl_id      => p_material_detail_rec.material_detail_id
                        ,x_return_status    => x_return_status);

      l_sequence := l_sequence + g_sequence_increment;
    ELSE
      l_sequence := p_pending_product_lots_rec.sequence;
    END IF;

    IF NOT validate_sequence
                         (p_matl_dtl_rec    => p_material_detail_rec
                         ,p_sequence        => l_sequence
                         ,x_return_status   => x_return_status) THEN
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      RAISE error_validate;
    END IF;

    x_pending_product_lots_rec.sequence :=  l_sequence;

    IF NOT validate_revision
                         (p_item_rec        => l_item_rec
                         ,p_revision        => p_pending_product_lots_rec.revision
                         ,x_return_status   => x_return_status) THEN
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      RAISE error_validate;
    END IF;

    x_pending_product_lots_rec.revision :=  p_pending_product_lots_rec.revision;

    l_lot_number := p_pending_product_lots_rec.lot_number;

    IF p_material_detail_rec.line_type <> gme_common_pvt.g_line_type_ing AND
       p_create_lot = fnd_api.g_true THEN
      l_in_mmli_tbl(1).lot_number := p_pending_product_lots_rec.lot_number;

      create_product_lot
          (p_organization_id       => p_material_detail_rec.organization_id
          ,p_inventory_item_id     => p_material_detail_rec.inventory_item_id
          ,p_parent_lot            => p_parent_lot
          ,p_mmli_tbl              => l_in_mmli_tbl
          ,p_generate_lot          => p_generate_lot
          ,p_generate_parent_lot   => p_generate_parent_lot
          /* nsinghi bug#4486074 Added the p_expiration_Date parameter. */
          ,p_expiration_date       => p_expiration_date
          ,x_mmli_tbl              => l_mmli_tbl
          ,x_return_status         => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE error_create_lot;
      END IF;

      l_lot_number := l_mmli_tbl(1).lot_number;
    END IF;

    IF NOT validate_lot_number
                           (p_inv_item_id   => p_material_detail_rec.inventory_item_id
                           ,p_org_id        => p_material_detail_rec.organization_id
                           ,p_lot_number    => l_lot_number
                           ,x_return_status => x_return_status) THEN
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      RAISE error_validate;
    END IF;

    x_pending_product_lots_rec.lot_number :=  l_lot_number;

    IF NOT validate_reason_id
                          (p_reason_id     => p_pending_product_lots_rec.reason_id
                          ,x_return_status => x_return_status) THEN
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      RAISE error_validate;
    END IF;

    x_pending_product_lots_rec.reason_id :=  p_pending_product_lots_rec.reason_id;

    l_dtl_qty := p_pending_product_lots_rec.quantity;
    l_sec_qty := p_pending_product_lots_rec.secondary_quantity;

    IF NOT validate_quantities
                        (p_matl_dtl_rec    => p_material_detail_rec
                        ,p_lot_number      => x_pending_product_lots_rec.lot_number
                        ,p_revision        => x_pending_product_lots_rec.revision
                        ,p_dtl_qty         => l_dtl_qty
                        ,p_sec_qty         => l_sec_qty
                        ,x_return_status   => x_return_status) THEN
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      RAISE error_validate;
    END IF;

    x_pending_product_lots_rec.quantity := l_dtl_qty;
    x_pending_product_lots_rec.secondary_quantity := l_sec_qty;

    -- Generated
    /*
    PENDING_PRODUCT_LOT_ID
    CREATION_DATE
    CREATED_BY
    LAST_UPDATE_DATE
    LAST_UPDATED_BY
    LAST_UPDATE_LOGIN
     */

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN error_validate OR error_create_lot OR error_get_item THEN
      NULL;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_record_for_create;

  PROCEDURE validate_material_for_update
                        (p_batch_header_rec          IN gme_batch_header%ROWTYPE
                        ,p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2) IS

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_material_for_update';

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_material_for_update;

  PROCEDURE validate_record_for_update
                        (p_material_detail_rec             IN gme_material_details%ROWTYPE
                        ,p_db_pending_product_lots_rec     IN gme_pending_product_lots%ROWTYPE
                        ,p_pending_product_lots_rec        IN gme_pending_product_lots%ROWTYPE
                        ,x_pending_product_lots_rec        OUT NOCOPY gme_pending_product_lots%ROWTYPE
                        ,x_return_status                   OUT NOCOPY VARCHAR2) IS

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_record_for_update';

    l_pending_product_lots_rec    gme_pending_product_lots%ROWTYPE;
    l_db_pending_product_lots_rec gme_pending_product_lots%ROWTYPE;
    l_in_pending_product_lots_rec gme_pending_product_lots%ROWTYPE;

    l_dtl_qty                     NUMBER;
    l_sec_qty                     NUMBER;

    l_sequence                    NUMBER;

    l_item_rec               mtl_system_items_b%ROWTYPE;

    error_validate                EXCEPTION;
    error_fetch_row               EXCEPTION;
    error_get_item                EXCEPTION;

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;


    IF p_db_pending_product_lots_rec.pending_product_lot_id IS NOT NULL THEN
      l_db_pending_product_lots_rec := p_db_pending_product_lots_rec;

      -- set sequence to that passed in because it may need to be updated
      l_sequence := p_pending_product_lots_rec.sequence;
    ELSE
      l_in_pending_product_lots_rec := p_pending_product_lots_rec;
      l_in_pending_product_lots_rec.material_detail_id := p_material_detail_rec.material_detail_id;
      l_in_pending_product_lots_rec.batch_id := p_material_detail_rec.batch_id;

      IF NOT gme_pending_product_lots_dbl.fetch_row
             (p_pending_product_lots_rec   => l_in_pending_product_lots_rec
             ,x_pending_product_lots_rec   => l_db_pending_product_lots_rec)  THEN
        RAISE error_fetch_row;
      END IF;

      -- sequence was used for retreival... not needed anymore, so NULL it out...
      l_sequence := NULL;
    END IF;

    x_pending_product_lots_rec.pending_product_lot_id := l_db_pending_product_lots_rec.pending_product_lot_id;
    x_pending_product_lots_rec.batch_id := l_db_pending_product_lots_rec.batch_id;
    x_pending_product_lots_rec.material_detail_id := l_db_pending_product_lots_rec.material_detail_id;
    x_pending_product_lots_rec.last_update_date := l_db_pending_product_lots_rec.last_update_date;
    x_pending_product_lots_rec.last_update_login := l_db_pending_product_lots_rec.last_update_login;
    x_pending_product_lots_rec.last_updated_by := l_db_pending_product_lots_rec.last_updated_by;

    gme_material_detail_pvt.get_item_rec
                   (p_org_id             => p_material_detail_rec.organization_id
                   ,p_item_id            => p_material_detail_rec.inventory_item_id
                   ,x_item_rec           => l_item_rec
                   ,x_return_status      => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE error_get_item;
    END IF;

    -- Validate following fields:
    /*
    SEQUENCE
    REVISION
    LOT_NUMBER
    QUANTITY
    SECONDARY_QUANTITY
    REASON_ID
     */

    -- l_sequence is set above because if passed in for retrieval, then it shouldn't be
    -- looked at for change, if pplot_id is passed in, then look at sequence for update

    IF l_sequence = fnd_api.g_miss_num THEN
      l_sequence := get_last_sequence
                        (p_matl_dtl_id      => p_material_detail_rec.material_detail_id
                        ,x_return_status    => x_return_status);
      l_sequence := l_sequence + g_sequence_increment;
    END IF;

    IF l_sequence IS NOT NULL THEN
      IF NOT validate_sequence
                         (p_matl_dtl_rec    => p_material_detail_rec
                         ,p_sequence        => l_sequence
                         ,x_return_status   => x_return_status) THEN
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        RAISE error_validate;
      END IF;
      x_pending_product_lots_rec.sequence :=  l_sequence;
    ELSE
      x_pending_product_lots_rec.sequence :=  l_db_pending_product_lots_rec.sequence;
    END IF;

    IF p_pending_product_lots_rec.revision = fnd_api.g_miss_char THEN
      x_pending_product_lots_rec.revision := NULL;
    ELSIF p_pending_product_lots_rec.revision IS NOT NULL THEN
      IF NOT validate_revision
                         (p_item_rec        => l_item_rec
                         ,p_revision        => p_pending_product_lots_rec.revision
                         ,x_return_status   => x_return_status) THEN
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        RAISE error_validate;
      END IF;

      x_pending_product_lots_rec.revision :=  p_pending_product_lots_rec.revision;
    ELSE
      x_pending_product_lots_rec.revision :=  l_db_pending_product_lots_rec.revision;
    END IF;

    IF p_pending_product_lots_rec.lot_number = fnd_api.g_miss_char THEN
      x_pending_product_lots_rec.lot_number := NULL;
      IF NOT validate_lot_number
                           (p_inv_item_id   => p_material_detail_rec.inventory_item_id
                           ,p_org_id        => p_material_detail_rec.organization_id
                           ,p_lot_number    => x_pending_product_lots_rec.lot_number
                           ,x_return_status => x_return_status) THEN
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        RAISE error_validate;
      END IF;
    ELSIF p_pending_product_lots_rec.lot_number IS NOT NULL THEN
      IF NOT validate_lot_number
                           (p_inv_item_id   => p_material_detail_rec.inventory_item_id
                           ,p_org_id        => p_material_detail_rec.organization_id
                           ,p_lot_number    => p_pending_product_lots_rec.lot_number
                           ,x_return_status => x_return_status) THEN
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        RAISE error_validate;
      END IF;
      x_pending_product_lots_rec.lot_number :=  p_pending_product_lots_rec.lot_number;
    ELSE
      x_pending_product_lots_rec.lot_number :=  l_db_pending_product_lots_rec.lot_number;
    END IF;

    IF p_pending_product_lots_rec.reason_id = fnd_api.g_miss_num THEN
      x_pending_product_lots_rec.reason_id := NULL;
    ELSIF p_pending_product_lots_rec.reason_id IS NOT NULL THEN
      IF NOT validate_reason_id
                          (p_reason_id     => p_pending_product_lots_rec.reason_id
                          ,x_return_status => x_return_status) THEN
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        RAISE error_validate;
      END IF;
      x_pending_product_lots_rec.reason_id :=  p_pending_product_lots_rec.reason_id;
    ELSE
      x_pending_product_lots_rec.reason_id :=  l_db_pending_product_lots_rec.reason_id;
    END IF;

    IF p_pending_product_lots_rec.quantity = fnd_api.g_miss_num THEN
      l_dtl_qty := NULL;
    ELSIF p_pending_product_lots_rec.quantity IS NOT NULL THEN
      l_dtl_qty :=  p_pending_product_lots_rec.quantity;
    ELSE
      l_dtl_qty :=  l_db_pending_product_lots_rec.quantity;
    END IF;

    IF p_pending_product_lots_rec.secondary_quantity = fnd_api.g_miss_num THEN
      l_sec_qty := NULL;
    ELSIF p_pending_product_lots_rec.quantity IS NOT NULL THEN
      l_sec_qty :=  p_pending_product_lots_rec.secondary_quantity;
    ELSE
      l_sec_qty :=  l_db_pending_product_lots_rec.secondary_quantity;
    END IF;

    IF NOT validate_quantities
                        (p_matl_dtl_rec    => p_material_detail_rec
                        ,p_lot_number      => x_pending_product_lots_rec.lot_number
                        ,p_revision        => x_pending_product_lots_rec.revision
                        ,p_dtl_qty         => l_dtl_qty
                        ,p_sec_qty         => l_sec_qty
                        ,x_return_status   => x_return_status) THEN
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      RAISE error_validate;
    END IF;

    x_pending_product_lots_rec.quantity := l_dtl_qty;
    x_pending_product_lots_rec.secondary_quantity := l_sec_qty;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN error_validate OR error_get_item THEN
      NULL;
    WHEN error_fetch_row THEN
      -- error message set in fetch routine
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_record_for_update;

  PROCEDURE validate_material_for_delete
                        (p_batch_header_rec          IN gme_batch_header%ROWTYPE
                        ,p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2) IS

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_material_for_delete';

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_material_for_delete;

  PROCEDURE validate_record_for_delete
                        (p_material_detail_rec             IN gme_material_details%ROWTYPE
                        ,p_db_pending_product_lots_rec     IN gme_pending_product_lots%ROWTYPE
                        ,p_pending_product_lots_rec        IN gme_pending_product_lots%ROWTYPE
                        ,x_pending_product_lots_rec        OUT NOCOPY gme_pending_product_lots%ROWTYPE
                        ,x_return_status                   OUT NOCOPY VARCHAR2) IS

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_record_for_delete';

    l_in_pending_product_lots_rec gme_pending_product_lots%ROWTYPE;

    error_fetch_row               EXCEPTION;

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF p_db_pending_product_lots_rec.pending_product_lot_id IS NOT NULL THEN
      x_pending_product_lots_rec := p_db_pending_product_lots_rec;
    ELSE
      l_in_pending_product_lots_rec := p_pending_product_lots_rec;
      l_in_pending_product_lots_rec.material_detail_id := p_material_detail_rec.material_detail_id;
      l_in_pending_product_lots_rec.batch_id := p_material_detail_rec.batch_id;

      IF NOT gme_pending_product_lots_dbl.fetch_row
             (p_pending_product_lots_rec   => l_in_pending_product_lots_rec
             ,x_pending_product_lots_rec   => x_pending_product_lots_rec)  THEN
        RAISE error_fetch_row;
      END IF;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

  EXCEPTION
    WHEN error_fetch_row THEN
      -- error message set in fetch routine
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_record_for_delete;

  -- Call this procedure at the record level because fields besides lot number are required
  FUNCTION validate_quantities
                        (p_matl_dtl_rec    IN gme_material_details%ROWTYPE
                        ,p_lot_number      IN VARCHAR2
                        ,p_revision        IN VARCHAR2
                        ,p_dtl_qty         IN OUT NOCOPY NUMBER
                        ,p_sec_qty         IN OUT NOCOPY NUMBER
                        ,x_return_status   OUT NOCOPY VARCHAR2)

  RETURN BOOLEAN IS
    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_quantities';
    l_exists                 NUMBER;
    l_return                 BOOLEAN;
    l_transaction_type_id    NUMBER;
    l_primary_uom_code       VARCHAR2(3);
    l_primary_lot_qty        NUMBER;
    l_secondary_uom_code     VARCHAR2(3);
    l_secondary_lot_qty      NUMBER;

    l_return_status          VARCHAR2(1);
    l_msg_data               VARCHAR2(3000);
    l_msg_count              NUMBER;

    CURSOR cur_get_uom (v_item_id NUMBER, v_org_id NUMBER) IS
    SELECT primary_uom_code, secondary_uom_code
      FROM mtl_system_items_b
     WHERE inventory_item_id = v_item_id
       AND organization_id = v_org_id;

    error_um_conv            EXCEPTION;
    error_val_qties          EXCEPTION;

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering function '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_matl_dtl_rec.material_detail_id='||p_matl_dtl_rec.material_detail_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_matl_dtl_rec.inventory_item_id='||p_matl_dtl_rec.inventory_item_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_matl_dtl_rec.organization_id='||p_matl_dtl_rec.organization_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_matl_dtl_rec.subinventory='||p_matl_dtl_rec.subinventory);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_matl_dtl_rec.locator_id='||p_matl_dtl_rec.locator_id);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_matl_dtl_rec.dtl_um='||p_matl_dtl_rec.dtl_um);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_lot_number='||p_lot_number);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_revision='||p_revision);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_dtl_qty='||p_dtl_qty);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_sec_qty='||p_sec_qty);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF p_matl_dtl_rec.line_type = gme_common_pvt.g_line_type_prod THEN
      l_transaction_type_id := GME_COMMON_PVT.g_prod_completion;
    ELSIF p_matl_dtl_rec.line_type = gme_common_pvt.g_line_type_byprod THEN
      l_transaction_type_id := GME_COMMON_PVT.g_byprod_completion;
    ELSE
      l_transaction_type_id := GME_COMMON_PVT.g_ing_issue;
    END IF;

    IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
      gme_debug.put_line (   g_pkg_name||'.'||l_api_name||' l_transaction_type_id='||l_transaction_type_id);
    END IF;

    OPEN cur_get_uom(p_matl_dtl_rec.inventory_item_id, p_matl_dtl_rec.organization_id);
    FETCH cur_get_uom INTO l_primary_uom_code, l_secondary_uom_code;
    CLOSE cur_get_uom;

    IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
      gme_debug.put_line (   g_pkg_name||'.'||l_api_name||' l_primary_uom_code='||l_primary_uom_code);
      gme_debug.put_line (   g_pkg_name||'.'||l_api_name||' l_secondary_uom_code='||l_secondary_uom_code);
    END IF;

    IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
      gme_debug.put_line (   g_pkg_name||'.'||l_api_name||' l_primary_lot_qty='||l_primary_lot_qty);
    END IF;

    l_return := INV_LOT_API_PUB.validate_quantities
        (p_api_version            => 1.0
        ,p_init_msg_list          => FND_API.G_FALSE
        ,p_transaction_type_id    => l_transaction_type_id
        ,p_organization_id        => p_matl_dtl_rec.organization_id
        ,p_inventory_item_id      => p_matl_dtl_rec.inventory_item_id
        ,p_revision               => p_revision
        ,p_subinventory_code      => p_matl_dtl_rec.subinventory
        ,p_locator_id             => p_matl_dtl_rec.locator_id
        ,p_lot_number             => p_lot_number
        ,p_transaction_quantity   => p_dtl_qty
        ,p_transaction_uom_code   => p_matl_dtl_rec.dtl_um
        ,p_primary_quantity       => l_primary_lot_qty
        ,p_primary_uom_code       => l_primary_uom_code
        ,p_secondary_quantity     => p_sec_qty
        ,p_secondary_uom_code     => l_secondary_uom_code
        ,x_return_status          => l_return_status
        ,x_msg_count              => l_msg_count
        ,x_msg_data               => l_msg_data);

    IF NOT l_return OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
        gme_debug.put_line (   g_pkg_name||'.'||l_api_name||' error returned from INV_LOT_API_PUB.validate_quantities with return status='||l_return_status);
        gme_debug.put_line (   g_pkg_name||'.'||l_api_name||' l_msg_count='||l_msg_count);
        gme_debug.put_line (   g_pkg_name||'.'||l_api_name||' l_msg_data='||l_msg_data);
      END IF;
      RAISE error_val_qties;
    END IF;

    IF p_dtl_qty IS NULL THEN
      p_dtl_qty := INV_CONVERT.inv_um_convert
                            (item_id            => p_matl_dtl_rec.inventory_item_id
                            ,lot_number         => p_lot_number
                            ,organization_id    => p_matl_dtl_rec.organization_id
                            ,precision          => gme_common_pvt.g_precision
                            ,from_quantity      => l_primary_lot_qty
                            ,from_unit          => l_primary_uom_code
                            ,to_unit            => p_matl_dtl_rec.dtl_um
                            ,from_name          => NULL
                            ,to_name            => NULL);

      IF p_dtl_qty = -99999  THEN
        IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                          (   g_pkg_name
                           || '.'
                           || l_api_name
                           || ' qty conversion failed for material detail'
                           || p_matl_dtl_rec.material_detail_id);
        END IF;
        RAISE error_um_conv;
      END IF;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting function '||g_pkg_name||'.'||l_api_name);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_dtl_qty='||p_dtl_qty);
      gme_debug.put_line(g_pkg_name||'.'||l_api_name||' p_sec_qty='||p_sec_qty);
    END IF;

    RETURN l_return;

  EXCEPTION
    WHEN error_val_qties THEN
      RETURN FALSE;
    WHEN error_um_conv THEN
      FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
      FND_MESSAGE.SET_TOKEN('PGM_NAME',g_pkg_name||'.'||l_api_name);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN FALSE;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN FALSE;
  END validate_quantities;

  FUNCTION validate_lot_number (p_inv_item_id   IN NUMBER
                               ,p_org_id        IN NUMBER
                               ,p_lot_number    IN VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2)

  RETURN BOOLEAN IS
    CURSOR check_lot_exists(v_item_id NUMBER
                           ,v_org_id  NUMBER
                           ,v_lot_no  VARCHAR2) IS
    SELECT count( 1 )
    FROM   mtl_lot_numbers
    WHERE  inventory_item_id = v_item_id
    AND    organization_id = v_org_id
    AND    lot_number = v_lot_no;


    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_lot_number';
    l_exists                 NUMBER;
    l_return                 BOOLEAN;

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering function '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OPEN check_lot_exists(p_inv_item_id, p_org_id, p_lot_number);
    FETCH check_lot_exists INTO l_exists;
    CLOSE check_lot_exists;

    IF l_exists > 0 THEN
      l_return := TRUE;
    ELSE
      FND_MESSAGE.SET_NAME('INV','INV_LOT_NOT_EXISTS');
      FND_MESSAGE.SET_TOKEN('PGM_NAME',g_pkg_name||'.'||l_api_name);
      fnd_msg_pub.ADD;
      l_return := FALSE;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting function '||g_pkg_name||'.'||l_api_name);
    END IF;

    RETURN l_return;

  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN FALSE;
  END validate_lot_number;

  FUNCTION validate_sequence (p_matl_dtl_rec    IN gme_material_details%ROWTYPE
                             ,p_sequence        IN NUMBER
                             ,x_return_status   OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS


    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_sequence';

    CURSOR cur_is_sequence (v_matl_dtl_id NUMBER, v_sequ NUMBER) IS
      SELECT 1
      FROM   gme_pending_product_lots
      WHERE  material_detail_id = v_matl_dtl_id
      AND    sequence = v_sequ;

    l_return                 BOOLEAN;
    l_is_sequ                NUMBER := 0;

    error_validation         EXCEPTION;

  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering function '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF p_sequence IS NULL THEN
      gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                 ,'FIELD_NAME'
                                 ,'SEQUENCE');
      RAISE error_validation;
    END IF;

    OPEN cur_is_sequence(p_matl_dtl_rec.material_detail_id, p_sequence);
    FETCH cur_is_sequence INTO l_is_sequ;
    CLOSE cur_is_sequence;

    IF l_is_sequ = 1 THEN
      gme_common_pvt.log_message ('GME_SEQUENCE_DUP');
      l_return := FALSE;
    ELSE
      l_return := TRUE;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting function '||g_pkg_name||'.'||l_api_name);
    END IF;

    RETURN l_return;

  EXCEPTION
    WHEN error_validation THEN
      return FALSE;
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN FALSE;
  END validate_sequence;

  FUNCTION validate_revision (p_item_rec        IN mtl_system_items_b%ROWTYPE
                             ,p_revision        IN VARCHAR2
                             ,x_return_status   OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  IS

    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_revision';

    l_return                 BOOLEAN;

    error_get_item           EXCEPTION;


  BEGIN

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering function '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
    /* Bug 4866553 Corrected API call */
    gme_material_detail_pvt.validate_revision
                   (p_revision           => p_revision
                   ,p_item_rec           => p_item_rec
                   ,x_return_status      => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- error message set in gme_material_detail_pvt.validate_revision
      l_return := FALSE;
    ELSE
      l_return := TRUE;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting function '||g_pkg_name||'.'||l_api_name);
    END IF;

    RETURN l_return;

  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN FALSE;
  END validate_revision;

  FUNCTION validate_reason_id(p_reason_id       IN NUMBER
                             ,x_return_status   OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
    l_api_name     CONSTANT  VARCHAR2 (30)      := 'validate_reason_id';

    l_is_reason              NUMBER;
    l_return                 BOOLEAN;

    CURSOR cur_is_reason (v_reason_id NUMBER) IS
      SELECT count(1)
      FROM  mtl_transaction_reasons
      WHERE reason_id = v_reason_id
      AND   NVL (disable_date, SYSDATE + 1) > SYSDATE;

  BEGIN
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering function '||g_pkg_name||'.'||l_api_name);
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF p_reason_id IS NULL THEN
      -- NULL is valid...
      return TRUE;
    END IF;

    OPEN cur_is_reason (p_reason_id);
    FETCH cur_is_reason INTO l_is_reason;
    CLOSE cur_is_reason;

    IF l_is_reason = 0 THEN
      FND_MESSAGE.SET_NAME('INV','INV_INT_REACODE');
      FND_MESSAGE.SET_TOKEN('PGM_NAME',g_pkg_name||'.'||l_api_name);
      fnd_msg_pub.ADD;
      l_return := FALSE;
    ELSE
      l_return := TRUE;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting function '||g_pkg_name||'.'||l_api_name);
    END IF;

    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN FALSE;
  END validate_reason_id;

  FUNCTION pending_product_lot_exist
               (p_batch_id                IN NUMBER
               ,p_material_detail_id      IN NUMBER)
  RETURN BOOLEAN IS
    l_api_name     CONSTANT  VARCHAR2 (30)      := 'pending_product_lot_exist';

    l_return                 BOOLEAN;
    l_is_pplot               NUMBER;

    CURSOR cur_pp_lot_exist (v_batch_id NUMBER, v_matl_dtl_id NUMBER) IS
      SELECT 1
      FROM  gme_pending_product_lots
      WHERE batch_id = v_batch_id
      AND   material_detail_id = v_matl_dtl_id
      AND   quantity <> 0
      AND   rownum = 1;

  BEGIN
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering function '||g_pkg_name||'.'||l_api_name);
    END IF;

    OPEN cur_pp_lot_exist (p_batch_id, p_material_detail_id);
    FETCH cur_pp_lot_exist INTO l_is_pplot;
    CLOSE cur_pp_lot_exist;

    IF l_is_pplot = 1 THEN
      l_return := TRUE;
    ELSE
      l_return := FALSE;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting function '||g_pkg_name||'.'||l_api_name);
    END IF;

    RETURN l_return;
  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
      END IF;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      RETURN FALSE;
  END pending_product_lot_exist;

-- nsinghi bug#5689035. Added this procedure.
  PROCEDURE get_pnd_prod_lot_qty (
     p_mtl_dtl_id        IN              NUMBER
    ,x_pnd_prod_lot_qty  OUT NOCOPY      NUMBER
    ,x_return_status     OUT NOCOPY      VARCHAR2)
  IS
     l_api_name   CONSTANT VARCHAR2 (30)               := 'get_pnd_prod_lot_qty';
     l_pnd_prod_lot_tbl    gme_common_pvt.pending_lots_tab;
     get_pending_lot_error EXCEPTION;

  BEGIN
     IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                            || l_api_name);
     END IF;

     x_return_status := fnd_api.g_ret_sts_success;
     x_pnd_prod_lot_qty := 0;

     get_pending_lot(p_material_detail_id => p_mtl_dtl_id
              ,x_return_status            => x_return_status
              ,x_pending_product_lot_tbl  => l_pnd_prod_lot_tbl);

     IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
        RAISE get_pending_lot_error;
     END IF;

     FOR i IN 1 .. l_pnd_prod_lot_tbl.COUNT LOOP
        x_pnd_prod_lot_qty := x_pnd_prod_lot_qty + l_pnd_prod_lot_tbl(i).quantity;
     END LOOP;

     IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
     END IF;
  EXCEPTION
     WHEN get_pending_lot_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
     WHEN OTHERS THEN
        IF g_debug <= gme_debug.g_log_unexpected THEN
           gme_debug.put_line (   'When others exception in '
                               || g_pkg_name
                               || '.'
                               || l_api_name
                               || ' Error is '
                               || SQLERRM);
        END IF;

        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
        x_return_status := fnd_api.g_ret_sts_unexp_error;
  END get_pnd_prod_lot_qty;

END gme_pending_product_lots_pvt;

/
