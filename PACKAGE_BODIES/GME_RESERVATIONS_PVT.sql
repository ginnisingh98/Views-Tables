--------------------------------------------------------
--  DDL for Package Body GME_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_RESERVATIONS_PVT" AS
/* $Header: GMEVRSVB.pls 120.24.12010000.4 2009/06/17 16:53:02 gmurator ship $ */
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_RESERVATIONS_PVT';

/* ***********************************************************************************************
 Oracle Process Manufacturing Process Execution APIs

 File Name: GMEVRSVB.pls
 Contents:  GME reservation related procedures.
 HISTORY
 SivakumarG Bug#4604943 29-MAR-2006
  Created new procedure validate_mtl_for_reservation to take care of validations. And all
  validations in create_material_reservation,auto_detail_line will be take care of by this proc
  the validation code in auto_detail_batch is removed as it will be taken care in
  auto_detail_line procedure
 Pawan Kumar bug 5139060
 Made changes in create_batch_reservation to pass  Suggestions mode (S) in the called by param
 to assess the total unreserved quantity
 Pawan kumar bug 5294184
 add gme_common_pvt.g_rule_based_resv_horizon in auto_detail_batch
 Swapna K  bug: 6665408 28-DEC-2007
 Added call to procedure inv_quantity_tree_pub.clear_quantity_cache in the procedure
 auto_detail_line to clear the quantity cache and recreate it again

  S. Kommineni   11-Feb-2008   6778968
     Added parameter value when calling build_and_create_transaction in procedure convert_dtl_reservation

  Archana Mundhe 30-May-2008 Bug 6437252
    Added lpn_id parameter to create_material_reservation procedure.

    Apeksha Mishra 17-June-2009 Bug 8599753
    Updated the value of l_open_qty as the WMS engine is using its own intelligence to
    calculate quantity and hence we just need to pass
    l_open_qty as planned in case of Pending batches and Planned-actual in case of WIP batches.
/*************************************************************************************************/

   PROCEDURE get_reservations_msca (
      p_organization_id      IN              NUMBER
     ,p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER
     ,p_subinventory_code    IN              VARCHAR2
     ,p_locator_id           IN              NUMBER
     ,p_lot_number           IN              VARCHAR2
     ,x_return_status        OUT NOCOPY      VARCHAR2
     ,x_error_msg            OUT NOCOPY      VARCHAR2
     ,x_rsrv_cursor          OUT NOCOPY      g_msca_resvns)
   IS
      l_date_format   VARCHAR2 (100);
      l_api_name      VARCHAR2 (50)  := 'get_reservations_msca';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_error_msg := ' ';
      fnd_profile.get ('ICX_DATE_FORMAT_MASK', l_date_format);

      OPEN x_rsrv_cursor
       FOR
          SELECT   mr.reservation_id
                  ,TO_CHAR (mr.requirement_date, l_date_format)
                  ,mr.primary_uom_code, mr.reservation_uom_code
                  ,NVL (mr.reservation_quantity, 0)
                  ,NVL (mr.primary_reservation_quantity, 0)
                  ,mr.subinventory_code, mr.subinventory_id, mr.locator_id
                  ,mr.lot_number, mr.lot_number_id
                  ,NVL (mr.detailed_quantity, 0)
                  ,NVL (mr.secondary_detailed_quantity, 0)
                  ,NVL (mr.secondary_reservation_quantity, 0)
                  ,mr.secondary_uom_code, mr.inventory_item_id
                  ,loc.concatenated_segments
              FROM mtl_reservations mr, wms_item_locations_kfv loc
             WHERE mr.organization_id = p_organization_id
               AND mr.demand_source_type_id = gme_common_pvt.g_txn_source_type
               AND mr.demand_source_header_id = p_batch_id
               AND mr.demand_source_line_id = p_material_detail_id
               AND NVL (mr.subinventory_code, '1') =
                                                NVL (p_subinventory_code, '1')
               AND NVL (mr.locator_id, -1) = NVL (p_locator_id, -1)
               AND mr.organization_id = loc.organization_id(+)
               AND mr.subinventory_code = loc.subinventory_code(+)
               AND mr.locator_id = loc.inventory_location_id(+)
               AND (p_lot_number IS NULL OR mr.lot_number = p_lot_number)
               AND NOT EXISTS (SELECT 1
                                 FROM mtl_material_transactions_temp
                                WHERE reservation_id = mr.reservation_id)
          ORDER BY mr.requirement_date;
   EXCEPTION
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
         x_error_msg := fnd_message.get;
   END get_reservations_msca;

   PROCEDURE create_batch_reservations (
      p_batch_id        IN              NUMBER
     ,p_timefence       IN              NUMBER DEFAULT 1000
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)      := 'create_batch_reservations';
      l_return_status       VARCHAR2 (1);
      l_mtl_dtl_rec         gme_material_details%ROWTYPE;
      l_resv_qty            NUMBER                         DEFAULT NULL;
      line_resvn_err        EXCEPTION;
      get_open_qty_err      EXCEPTION;

      CURSOR cur_reservable_ings
      IS
         SELECT   d.*
             FROM gme_material_details d, mtl_system_items i
            WHERE d.batch_id = p_batch_id
              AND d.line_type = -1
              AND d.line_type = -1
              AND (   NVL (p_timefence, 0) = 0
                   OR (d.material_requirement_date < SYSDATE + p_timefence) )
              AND i.inventory_item_id = d.inventory_item_id
              AND i.organization_id = d.organization_id
              AND i.reservable_type = 1
              AND d.phantom_type = 0
              AND (i.lot_control_code < 2
                   OR i.lot_control_code > 1 AND i.lot_divisible_flag = 'Y')
         ORDER BY d.line_no;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      FOR get_rec IN cur_reservable_ings LOOP
         l_mtl_dtl_rec := get_rec;

         IF (NVL (p_timefence, 0) <>
                               NVL (gme_common_pvt.g_reservation_timefence, 0) ) THEN
          --Pawan Kumar as done in create_material_reservations
          -- for bug 5139060
          -- Use Suggestions mode (S) in the called by param to assess the total
          -- unreserved quantity
            gme_common_pvt.get_open_qty (p_mtl_dtl_rec        => l_mtl_dtl_rec
                                        ,p_called_by          => 'S'
                                        ,x_open_qty           => l_resv_qty
                                        ,x_return_status      => l_return_status);

            IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
               RAISE get_open_qty_err;
            END IF;
         ELSE
           l_resv_qty := l_mtl_dtl_rec.plan_qty;
         END IF;
         IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'material_detail_id:'
                                || l_mtl_dtl_rec.material_detail_id
                                || ' has open qty of   '
                                || l_resv_qty);
         END IF;

         IF (NVL (l_resv_qty, 0) > 0) THEN
            create_material_reservation (p_matl_dtl_rec       => l_mtl_dtl_rec
                                        ,p_resv_qty           => l_resv_qty
                                        ,x_return_status      => l_return_status);

            IF (g_debug <= gme_debug.g_log_unexpected) THEN
               gme_debug.put_line (   g_pkg_name
                                  || '.'
                                  || l_api_name
                                  || ' create_material_reservation returns status of '
                                  || l_return_status);
            END IF;

            IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
               RAISE line_resvn_err;
            END IF;
         END IF;
      END LOOP;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN get_open_qty_err THEN
         x_return_status := l_return_status;
      WHEN line_resvn_err THEN
         x_return_status := l_return_status;
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
   END create_batch_reservations;

   -- Bug 6437252
   -- Added lpn_id parameter.
   PROCEDURE create_material_reservation (
      p_matl_dtl_rec    IN              gme_material_details%ROWTYPE
     ,p_resv_qty        IN              NUMBER DEFAULT NULL
     ,p_sec_resv_qty    IN              NUMBER DEFAULT NULL
     ,p_resv_um         IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory    IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id      IN              NUMBER DEFAULT NULL
     ,p_lpn_id          IN              NUMBER DEFAULT NULL
     ,p_lot_number      IN              VARCHAR2 DEFAULT NULL
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)    := 'create_material_reservation';
      l_return_status       VARCHAR2 (1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_qty_reserved        NUMBER;
      l_reservation_id      NUMBER;
      l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
      l_in_serial_num       inv_reservation_global.serial_number_tbl_type;
      l_out_serial_num      inv_reservation_global.serial_number_tbl_type;

      --Bug#4604943
      invalid_mtl_for_rsrv  EXCEPTION;
      create_resvn_err      EXCEPTION;

   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line ('input value p_resv_qty     => ' || p_resv_qty);
         gme_debug.put_line ('input value p_sec_resv_qty => ' || p_sec_resv_qty);
         gme_debug.put_line ('input value plan_qty       => ' || p_matl_dtl_rec.plan_qty);
         gme_debug.put_line ('input value resv_um        => ' || p_resv_um );
         gme_debug.put_line ('input value lpn_id        => ' || p_lpn_id);
         gme_debug.put_line ('input value release_type   => ' || p_matl_dtl_rec.release_type );
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      --Bug#4604943 Begin validate the batch and material line
      validate_mtl_for_reservation(
                 p_material_detail_rec => p_matl_dtl_rec
                ,x_return_status       => l_return_status );
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE invalid_mtl_for_rsrv;
      END IF;
      --Bug#4604943 End
      l_rsv_rec.requirement_date := p_matl_dtl_rec.material_requirement_date;
      l_rsv_rec.organization_id := p_matl_dtl_rec.organization_id;
      l_rsv_rec.inventory_item_id := p_matl_dtl_rec.inventory_item_id;
      l_rsv_rec.demand_source_type_id := gme_common_pvt.g_txn_source_type;
      l_rsv_rec.demand_source_header_id := p_matl_dtl_rec.batch_id;
      l_rsv_rec.demand_source_line_id := p_matl_dtl_rec.material_detail_id;
      l_rsv_rec.reservation_uom_code := NVL (p_resv_um, p_matl_dtl_rec.dtl_um);
      l_rsv_rec.reservation_quantity :=
                                     NVL (p_resv_qty, p_matl_dtl_rec.plan_qty);
      l_rsv_rec.secondary_reservation_quantity := p_sec_resv_qty;
      l_rsv_rec.revision := p_matl_dtl_rec.revision;
      l_rsv_rec.subinventory_code := p_subinventory;
      l_rsv_rec.locator_id := p_locator_id;
      -- Bug 6437252
      -- Assign lpn_id to reservation rec.
      l_rsv_rec.lpn_id := p_lpn_id;
      l_rsv_rec.lot_number := p_lot_number;
      l_rsv_rec.demand_source_name := NULL;
      l_rsv_rec.demand_source_delivery := NULL;
      l_rsv_rec.primary_uom_code := NULL;
      l_rsv_rec.primary_uom_id := NULL;
      l_rsv_rec.secondary_uom_code := NULL;
      l_rsv_rec.secondary_uom_id := NULL;
      l_rsv_rec.reservation_uom_id := NULL;
      l_rsv_rec.ship_ready_flag := NULL;
      l_rsv_rec.attribute_category := NULL;
      l_rsv_rec.attribute1 := NULL;
      l_rsv_rec.attribute2 := NULL;
      l_rsv_rec.attribute3 := NULL;
      l_rsv_rec.attribute4 := NULL;
      l_rsv_rec.attribute5 := NULL;
      l_rsv_rec.attribute6 := NULL;
      l_rsv_rec.attribute7 := NULL;
      l_rsv_rec.attribute8 := NULL;
      l_rsv_rec.attribute9 := NULL;
      l_rsv_rec.attribute10 := NULL;
      l_rsv_rec.attribute11 := NULL;
      l_rsv_rec.attribute12 := NULL;
      l_rsv_rec.attribute13 := NULL;
      l_rsv_rec.attribute14 := NULL;
      l_rsv_rec.attribute15 := NULL;
      l_rsv_rec.subinventory_id := NULL;
      l_rsv_rec.lot_number_id := NULL;
      l_rsv_rec.pick_slip_number := NULL;
      l_rsv_rec.primary_reservation_quantity := NULL;
      l_rsv_rec.detailed_quantity := NULL;
      l_rsv_rec.secondary_detailed_quantity := NULL;
      l_rsv_rec.autodetail_group_id := NULL;
      l_rsv_rec.external_source_code := NULL;
      l_rsv_rec.external_source_line_id := NULL;
      l_rsv_rec.supply_source_type_id :=
                                      inv_reservation_global.g_source_type_inv;
      l_rsv_rec.supply_source_header_id := NULL;
      l_rsv_rec.supply_source_line_id := NULL;
      l_rsv_rec.supply_source_name := NULL;
      l_rsv_rec.supply_source_line_detail := NULL;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling inv_reservation_pub.create_reservation');
      END IF;

-- nsinghi Bug5176319. Commented p_force_reservation_flag parameter. As per inv team, onhand could be -ve
-- before reservation, and hence this parameter should not be used.

      inv_reservation_pub.create_reservation
                                (p_api_version_number            => 1.0
                                ,p_init_msg_lst                  => fnd_api.g_false
                                ,x_return_status                 => l_return_status
                                ,x_msg_count                     => l_msg_count
                                ,x_msg_data                      => l_msg_data
                                ,p_rsv_rec                       => l_rsv_rec
                                ,p_serial_number                 => l_in_serial_num
                                ,x_serial_number                 => l_out_serial_num
                                ,p_partial_reservation_flag      => fnd_api.g_true
--                                ,p_force_reservation_flag        => fnd_api.g_true
                                ,p_validation_flag               => fnd_api.g_true
                                ,x_quantity_reserved             => l_qty_reserved
                                ,x_reservation_id                => l_reservation_id
                                ,p_partial_rsv_exists            => TRUE);

      IF (g_debug <= gme_debug.g_log_unexpected) THEN
        gme_debug.put_line (   g_pkg_name
                           || '.'
                           || l_api_name
                           || ' inv_reservation_pub.create_reservation returns status of '
                           || l_return_status
                           || ' for material_detail_id '
                           || p_matl_dtl_rec.material_detail_id
                           || ' qty reserved IS  '
                           || l_qty_reserved );
      END IF;
      IF (l_return_status IN
                     (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error) ) THEN
         RAISE create_resvn_err;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN create_resvn_err THEN
         IF (g_debug <= gme_debug.g_log_error) THEN
            gme_debug.put_line
                        (   'inv_reservation_pub.create_reservation returns '
                         || l_return_status);
            gme_debug.put_line ('error message is ' || l_msg_data);
         END IF;

         x_return_status := l_return_status;
      --Bug#4604943 just pass the actual return status from validate procedure
      WHEN invalid_mtl_for_rsrv THEN
         x_return_status := l_return_status;
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
   END create_material_reservation;

   PROCEDURE get_material_reservations (
      p_organization_id      IN              NUMBER
     ,p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER
     ,p_dispense_ind         IN              VARCHAR2
     ,x_return_status        OUT NOCOPY      VARCHAR2
     ,x_reservations_tbl     OUT NOCOPY      gme_common_pvt.reservations_tab)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'get_material_reservations';
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2(32767);
      l_return_status               VARCHAR2 (10);
      CURSOR cur_reservations (
         v_org_id               NUMBER
        ,v_batch_id             NUMBER
        ,v_material_detail_id   NUMBER)
      IS
         SELECT   mr.*
             FROM mtl_reservations mr
            WHERE organization_id = v_org_id
              AND demand_source_type_id = gme_common_pvt.g_txn_source_type
              AND demand_source_header_id = v_batch_id
              AND demand_source_line_id = v_material_detail_id
              AND NOT EXISTS (SELECT 1
                                FROM mtl_material_transactions_temp
                               WHERE reservation_id = mr.reservation_id)
         ORDER BY mr.requirement_date, mr.reservation_id; -- nsinghi bug#5176319. Add mr.reservation_id in order by clause.
         error_dispense_mat               EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      IF p_dispense_ind = 'Y' THEN

        gmo_dispense_grp.GET_MATERIAL_DISPENSE_DATA (p_api_version     => 1.0,
                                      p_init_msg_list           =>   'F',
                                      x_return_status           => l_return_status,
                                      x_msg_count               => l_msg_count,
                                      x_msg_data                => l_msg_data,
                                      p_material_detail_id      =>  p_material_detail_id,
                                      x_dispense_data            => x_reservations_tbl
                                     );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE error_dispense_mat;
          END IF;

      ELSE
        OPEN cur_reservations (p_organization_id
                              ,p_batch_id
                              ,p_material_detail_id);

        FETCH cur_reservations
        BULK COLLECT INTO x_reservations_tbl;

        CLOSE cur_reservations;
      END IF ;
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN error_dispense_mat THEN
        x_return_status := l_return_status;
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
   END get_material_reservations;

   FUNCTION reservation_fully_specified (
      p_reservation_rec          IN   mtl_reservations%ROWTYPE
     ,p_item_location_control    IN   NUMBER
     ,p_item_restrict_locators   IN   NUMBER)
      RETURN NUMBER
   IS
      x_reservation_type      NUMBER        := 0;
      l_eff_locator_control   NUMBER;
      l_return_status         VARCHAR2 (10);
      l_api_name     CONSTANT VARCHAR2 (30) := 'reservation_fully_specified';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF (p_reservation_rec.subinventory_code IS NOT NULL) THEN
         IF (p_reservation_rec.locator_id IS NOT NULL) THEN
            x_reservation_type := 1;                               -- its DLR
         ELSE
            l_eff_locator_control :=
               gme_common_pvt.eff_locator_control
                     (p_organization_id        => p_reservation_rec.organization_id
                     ,p_org_control            => gme_common_pvt.g_org_locator_control
                     ,p_subinventory           => p_reservation_rec.subinventory_code
                     ,p_item_control           => p_item_location_control
                     ,p_item_loc_restrict      => p_item_restrict_locators
                     ,p_action                 => gme_common_pvt.g_ing_issue_txn_action);

            IF (l_eff_locator_control = 1) THEN
               x_reservation_type := 1;                            -- its DLR
            ELSE
               x_reservation_type := 2;                            -- its PLR
            END IF;
         END IF;
      ELSIF (   p_reservation_rec.revision IS NOT NULL
             OR p_reservation_rec.lot_number IS NOT NULL) THEN
         x_reservation_type := 2;                                  -- its PLR
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;

      RETURN x_reservation_type;
   EXCEPTION
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
         RETURN -1;
   END reservation_fully_specified;

   PROCEDURE convert_partial_to_dlr (
      p_reservation_rec    IN              mtl_reservations%ROWTYPE
     ,p_material_dtl_rec   IN              gme_material_details%ROWTYPE
     ,p_item_rec           IN              mtl_system_items%ROWTYPE
     ,p_qty_check          IN              VARCHAR2 := fnd_api.g_false
     ,x_reservation_rec    OUT NOCOPY      mtl_reservations%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      l_api_name     CONSTANT VARCHAR2 (30) := 'convert_partial_to_dlr';
      l_eff_locator_control   NUMBER;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      x_reservation_rec := p_reservation_rec;

      IF (    p_item_rec.lot_control_code > 1
          AND x_reservation_rec.lot_number IS NULL) THEN
         x_return_status := 'F';
         RETURN;
      END IF;

      IF (p_reservation_rec.subinventory_code IS NULL) THEN
         IF (p_material_dtl_rec.subinventory IS NOT NULL) THEN
            x_reservation_rec.subinventory_code :=
                                              p_material_dtl_rec.subinventory;
         ELSE
            x_return_status := 'F';
            RETURN;
         END IF;
      END IF;
      /* Bug 5441643 Added NVL condition for location control code*/
      l_eff_locator_control :=
         gme_common_pvt.eff_locator_control
                    (p_organization_id        => x_reservation_rec.organization_id
                    ,p_org_control            => gme_common_pvt.g_org_locator_control
                    ,p_subinventory           => x_reservation_rec.subinventory_code
                    ,p_item_control           => NVL(p_item_rec.location_control_code,1)
                    ,p_item_loc_restrict      => p_item_rec.restrict_locators_code
                    ,p_action                 => gme_common_pvt.g_ing_issue_txn_action);

      IF (l_eff_locator_control <> 1 AND p_reservation_rec.locator_id IS NULL) THEN
         /* Bug 5441643 Added NVL condition for location control code*/
         IF (NVL(p_item_rec.location_control_code,1) <> 1) THEN
            IF (    p_material_dtl_rec.locator_id IS NOT NULL
                AND p_material_dtl_rec.subinventory =
                                           x_reservation_rec.subinventory_code) THEN
               x_reservation_rec.locator_id := p_material_dtl_rec.locator_id;
            ELSE
               x_return_status := 'F';
               RETURN;
            END IF;
         END IF;
      END IF;

      IF (p_qty_check = fnd_api.g_true) THEN
         --QUERY TREE FOR ATT WITH RESVN DETAILS AND COMPARE QTY
         NULL;
      END IF;
   EXCEPTION
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
   END convert_partial_to_dlr;

   PROCEDURE delete_batch_reservations (
      p_organization_id   IN              NUMBER
     ,p_batch_id          IN              NUMBER
     ,x_return_status     OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'delete_batch_reservations';
      l_return_status       VARCHAR2 (1);
      delete_resvn_error    EXCEPTION;

      CURSOR cur_batch_materials
      IS
         SELECT d.material_detail_id, d.batch_id, d.organization_id
           FROM gme_material_details d, mtl_system_items_b i
          WHERE d.organization_id = p_organization_id
            AND d.batch_id = p_batch_id
            AND d.line_type = gme_common_pvt.g_line_type_ing
            AND i.organization_id = d.organization_id
            AND i.inventory_item_id = d.inventory_item_id
            AND i.reservable_type = 1;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      FOR get_rec IN cur_batch_materials LOOP
         gme_reservations_pvt.delete_material_reservations
                         (p_organization_id         => get_rec.organization_id
                         ,p_batch_id                => get_rec.batch_id
                         ,p_material_detail_id      => get_rec.material_detail_id
                         ,x_return_status           => l_return_status);

         IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            RAISE delete_resvn_error;
         END IF;
      END LOOP;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN delete_resvn_error THEN
         x_return_status := l_return_status;
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
   END delete_batch_reservations;

   PROCEDURE delete_material_reservations (
      p_organization_id      IN              NUMBER
     ,p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER
     ,x_return_status        OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)   := 'delete_material_reservations';
      l_return_status       VARCHAR2 (1);
      l_rsv_tbl             gme_common_pvt.reservations_tab;
      del_resvn_error       EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line ('p_organization_id = ' || p_organization_id);
         gme_debug.put_line ('p_batch_id = ' || p_batch_id);
         gme_debug.put_line ('p_material_detail_id = ' || p_material_detail_id);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      gme_reservations_pvt.get_material_reservations
                                (p_organization_id         => p_organization_id
                                ,p_batch_id                => p_batch_id
                                ,p_material_detail_id      => p_material_detail_id
                                ,x_return_status           => x_return_status
                                ,x_reservations_tbl        => l_rsv_tbl);

      FOR i IN 1 .. l_rsv_tbl.COUNT LOOP
         gme_reservations_pvt.delete_reservation
                            (p_reservation_id      => l_rsv_tbl (i).reservation_id
                            ,x_return_status       => l_return_status);

         IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            RAISE del_resvn_error;
         END IF;
      END LOOP;

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE del_resvn_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN del_resvn_error THEN
         x_return_status := l_return_status;
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
   END delete_material_reservations;

   PROCEDURE delete_reservation (
      p_reservation_id   IN              NUMBER
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)             := 'delete_reservation';
      l_return_status       VARCHAR2 (1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
      l_serial_number       inv_reservation_global.serial_number_tbl_type;
      del_resvn_error       EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line ('p_reservation_id = ' || p_reservation_id);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      l_rsv_rec.reservation_id := p_reservation_id;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling inv_reservation_pub.delete_reservation');
      END IF;

      inv_reservation_pub.delete_reservation
                                          (p_api_version_number      => 1.0
                                          ,p_init_msg_lst            => fnd_api.g_false
                                          ,x_return_status           => l_return_status
                                          ,x_msg_count               => l_msg_count
                                          ,x_msg_data                => l_msg_data
                                          ,p_rsv_rec                 => l_rsv_rec
                                          ,p_serial_number           => l_serial_number);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE del_resvn_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN del_resvn_error THEN
         IF (g_debug <= gme_debug.g_log_error) THEN
            gme_debug.put_line
                        (   'inv_reservation_pub.delete_reservation returns '
                         || l_return_status);
            gme_debug.put_line ('error message is ' || l_msg_data);
         END IF;

         x_return_status := l_return_status;
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
   END delete_reservation;

   PROCEDURE get_reservation_dtl_qty (
      p_reservation_rec   IN              mtl_reservations%ROWTYPE
     ,p_uom_code          IN              VARCHAR2
     ,x_qty               OUT NOCOPY      NUMBER
     ,x_return_status     OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)   := 'get_reservation_dtl_qty';
      l_item_no             VARCHAR2 (2000);
      l_from_uom            VARCHAR2 (3);
      l_to_uom              VARCHAR2 (3);
      l_temp_qty            NUMBER;

      CURSOR cur_item_no (v_inventory_item_id NUMBER, v_org_id NUMBER)
      IS
         SELECT concatenated_segments
           FROM mtl_system_items_kfv
          WHERE inventory_item_id = v_inventory_item_id
            AND organization_id = v_org_id;

      uom_conv_error        EXCEPTION;
   BEGIN
      IF (p_reservation_rec.reservation_uom_code = p_uom_code) THEN
         l_temp_qty := p_reservation_rec.reservation_quantity;
      ELSIF (p_reservation_rec.primary_uom_code = p_uom_code) THEN
         l_temp_qty := p_reservation_rec.primary_reservation_quantity;
      ELSIF (p_reservation_rec.secondary_uom_code = p_uom_code) THEN
         l_temp_qty := p_reservation_rec.secondary_reservation_quantity;
      ELSE
         l_temp_qty :=
            inv_convert.inv_um_convert
                    (item_id              => p_reservation_rec.inventory_item_id
                    ,lot_number           => p_reservation_rec.lot_number
                    ,organization_id      => p_reservation_rec.organization_id
                    ,PRECISION            => gme_common_pvt.g_precision
                    ,from_quantity        => p_reservation_rec.reservation_quantity
                    ,from_unit            => p_reservation_rec.reservation_uom_code
                    ,to_unit              => p_uom_code
                    ,from_name            => NULL
                    ,to_name              => NULL);

         IF (l_temp_qty < 0) THEN
            OPEN cur_item_no (p_reservation_rec.inventory_item_id
                             ,p_reservation_rec.organization_id);

            FETCH cur_item_no
             INTO l_item_no;

            CLOSE cur_item_no;

            l_from_uom := p_reservation_rec.reservation_uom_code;
            l_to_uom := p_uom_code;
            RAISE uom_conv_error;
         END IF;
      END IF;

      x_qty := l_temp_qty;
   EXCEPTION
      WHEN uom_conv_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name ('GMI', 'IC_API_UOM_CONVERSION_ERROR');
         fnd_message.set_token ('ITEM_NO', l_item_no);
         fnd_message.set_token ('FROM_UOM', l_from_uom);
         fnd_message.set_token ('TO_UOM', l_to_uom);
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
   END get_reservation_dtl_qty;

   PROCEDURE get_reserved_qty (
      p_mtl_dtl_rec       IN              gme_material_details%ROWTYPE
     ,p_supply_sub_only   IN              VARCHAR2 DEFAULT 'F'
     ,x_reserved_qty      OUT NOCOPY      NUMBER
     ,x_return_status     OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)               := 'get_reserved_qty';
      l_mtl_dtl_rec         gme_material_details%ROWTYPE;
      l_resv_tbl            gme_common_pvt.reservations_tab;
      l_temp_qty            NUMBER;
      l_return_status       VARCHAR2 (1);

      CURSOR cur_get_resvns
      IS
         SELECT mr.*
           FROM mtl_reservations mr
          WHERE mr.demand_source_type_id = gme_common_pvt.g_txn_source_type
            AND mr.demand_source_header_id = l_mtl_dtl_rec.batch_id
            AND mr.demand_source_line_id = l_mtl_dtl_rec.material_detail_id
            AND (    (p_supply_sub_only = fnd_api.g_false)
                 OR (mr.subinventory_code = l_mtl_dtl_rec.subinventory) )
            AND NOT EXISTS (SELECT 1
                              FROM mtl_material_transactions_temp
                             WHERE reservation_id = mr.reservation_id);

      matl_fetch_error      EXCEPTION;
      get_resv_qty_error    EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      x_reserved_qty := 0;

      IF (p_mtl_dtl_rec.inventory_item_id IS NULL
          OR p_mtl_dtl_rec.dtl_um IS NULL
          OR p_mtl_dtl_rec.batch_id IS NULL
          OR (p_supply_sub_only = fnd_api.g_true AND p_mtl_dtl_rec.subinventory IS NULL)) THEN
         IF (NOT (gme_material_details_dbl.fetch_row (p_mtl_dtl_rec
                                                     ,l_mtl_dtl_rec) ) ) THEN
            RAISE matl_fetch_error;
         END IF;
      ELSE
         l_mtl_dtl_rec := p_mtl_dtl_rec;
      END IF;

      OPEN cur_get_resvns;

      FETCH cur_get_resvns
      BULK COLLECT INTO l_resv_tbl;

      CLOSE cur_get_resvns;

      FOR i IN 1 .. l_resv_tbl.COUNT LOOP
         get_reservation_dtl_qty (p_reservation_rec      => l_resv_tbl (i)
                                 ,p_uom_code             => l_mtl_dtl_rec.dtl_um
                                 ,x_qty                  => l_temp_qty
                                 ,x_return_status        => l_return_status);

         IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            RAISE get_resv_qty_error;
         END IF;

         x_reserved_qty := x_reserved_qty + l_temp_qty;
      END LOOP;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN matl_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN get_resv_qty_error THEN
         x_return_status := l_return_status;
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
   END get_reserved_qty;

   PROCEDURE relieve_reservation (
      p_reservation_id     IN              NUMBER
     ,p_prim_relieve_qty   IN              NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)            := 'relieve_reservation';
      l_return_status       VARCHAR2 (1);
      l_msg_count           NUMBER;
      l_prim_relieve_qty    NUMBER;
      l_prim_remain_qty     NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
      l_serial_number       inv_reservation_global.serial_number_tbl_type;
      relieve_resvn_error   EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      l_rsv_rec.reservation_id := p_reservation_id;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ':Calling inv_reservation_pub.relieve_reservation with reservation_id = '
             || p_reservation_id
             || ' relieve_qty '
             || p_prim_relieve_qty);
      END IF;

      inv_reservation_pub.relieve_reservation
                           (p_api_version_number             => 1.0
                           ,p_init_msg_lst                   => fnd_api.g_false
                           ,x_return_status                  => l_return_status
                           ,x_msg_count                      => l_msg_count
                           ,x_msg_data                       => l_msg_data
                           ,p_rsv_rec                        => l_rsv_rec
                           ,p_primary_relieved_quantity      => p_prim_relieve_qty
                           ,p_relieve_all                    => fnd_api.g_false
                           ,p_original_serial_number         => l_serial_number
                           ,p_validation_flag                => fnd_api.g_true
                           ,x_primary_relieved_quantity      => l_prim_relieve_qty
                           ,x_primary_remain_quantity        => l_prim_remain_qty);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || 'Return status from inv_reservation_pub.relieve_reservation is '
             || l_return_status);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'Error is :'
                             || l_msg_data);
      END IF;

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE relieve_resvn_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN relieve_resvn_error THEN
         x_return_status := l_return_status;
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
   END relieve_reservation;

   /* Pass only values needed to be updated reservation ID is required */
   PROCEDURE update_reservation (
      p_reservation_id   IN              NUMBER
     ,p_revision         IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory     IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id       IN              NUMBER DEFAULT NULL
     ,p_lot_number       IN              VARCHAR2 DEFAULT NULL
     ,p_new_qty          IN              NUMBER DEFAULT NULL
     ,p_new_sec_qty      IN              NUMBER DEFAULT NULL
     ,p_new_uom          IN              VARCHAR2 DEFAULT NULL
     ,p_new_date         IN              DATE DEFAULT NULL
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)             := 'update_reservation';
      l_return_status       VARCHAR2 (1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
      l_orig_rsv_rec        inv_reservation_global.mtl_reservation_rec_type;
      l_serial_number       inv_reservation_global.serial_number_tbl_type;
      update_resvn_error    EXCEPTION;
      query_resvn_error     EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      query_reservation (p_reservation_id       => p_reservation_id
                        ,x_reservation_rec      => l_orig_rsv_rec
                        ,x_return_status        => l_return_status);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE query_resvn_error;
      END IF;

      l_rsv_rec.reservation_id := p_reservation_id;
      l_rsv_rec.revision := p_revision;
      l_rsv_rec.subinventory_code := p_subinventory;
      l_rsv_rec.locator_id := p_locator_id;
      l_rsv_rec.lot_number := p_lot_number;
      l_rsv_rec.reservation_quantity := p_new_qty;
      l_rsv_rec.secondary_reservation_quantity := p_new_sec_qty;
      l_rsv_rec.reservation_uom_code := p_new_uom;
      l_rsv_rec.requirement_date := p_new_date;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ':Calling inv_reservation_pub.update_reservation with reservation_id = '
             || p_reservation_id);
      END IF;

      inv_reservation_pub.update_reservation
                                 (p_api_version_number          => 1.0
                                 ,p_init_msg_lst                => fnd_api.g_false
                                 ,x_return_status               => l_return_status
                                 ,x_msg_count                   => l_msg_count
                                 ,x_msg_data                    => l_msg_data
                                 ,p_original_rsv_rec            => l_orig_rsv_rec
                                 ,p_to_rsv_rec                  => l_rsv_rec
                                 ,p_original_serial_number      => l_serial_number
                                 ,p_to_serial_number            => l_serial_number
                                 ,p_validation_flag             => fnd_api.g_true
                                 ,p_check_availability          => fnd_api.g_true);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || 'Return status from inv_reservation_pub.update_reservation is '
             || l_return_status);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'Error is :'
                             || l_msg_data);
      END IF;

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE update_resvn_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN query_resvn_error THEN
         x_return_status := l_return_status;
      WHEN update_resvn_error THEN
         x_return_status := l_return_status;
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
   END update_reservation;

   /* Pass reservation ID to be queried */
   PROCEDURE query_reservation (
      p_reservation_id    IN              NUMBER
     ,x_reservation_rec   OUT NOCOPY      inv_reservation_global.mtl_reservation_rec_type
     ,x_return_status     OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)              := 'query_reservation';
      l_return_status       VARCHAR2 (1);
      l_error_code          NUMBER;
      l_rsv_count           NUMBER;
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_tbl             inv_reservation_global.mtl_reservation_tbl_type;
      l_serial_number       inv_reservation_global.serial_number_tbl_type;
      update_resvn_error    EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      l_rsv_rec.reservation_id := p_reservation_id;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ':Calling inv_reservation_pub.query_reservation with reservation_id = '
             || p_reservation_id);
      END IF;

      inv_reservation_pub.query_reservation
             (p_api_version_number             => 1.0
             ,p_init_msg_lst                   => fnd_api.g_false
             ,x_return_status                  => l_return_status
             ,x_msg_count                      => l_msg_count
             ,x_msg_data                       => l_msg_data
             ,p_query_input                    => l_rsv_rec
             ,p_lock_records                   => fnd_api.g_false
             ,p_sort_by_req_date               => inv_reservation_global.g_query_no_sort
             ,p_cancel_order_mode              => inv_reservation_global.g_cancel_order_no
             ,x_mtl_reservation_tbl            => l_rsv_tbl
             ,x_mtl_reservation_tbl_count      => l_rsv_count
             ,x_error_code                     => l_error_code);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || 'Return status from inv_reservation_pub.query_reservation is '
             || l_return_status);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'Error is :'
                             || l_msg_data);
      END IF;

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE update_resvn_error;
      END IF;

      x_reservation_rec := l_rsv_tbl (1);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN update_resvn_error THEN
         x_return_status := l_return_status;
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
   END query_reservation;

   FUNCTION pending_reservations_exist (
      p_organization_id      IN   NUMBER
     ,p_batch_id             IN   NUMBER
     ,p_material_detail_id   IN   NUMBER)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'pending_reservations_exist';
      l_temp                NUMBER;

      CURSOR cur_reservations (
         v_org_id               NUMBER
        ,v_batch_id             NUMBER
        ,v_material_detail_id   NUMBER)
      IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS (
                   SELECT 1
                     FROM mtl_reservations mr
                    WHERE organization_id = v_org_id
                      AND demand_source_type_id =
                                              gme_common_pvt.g_txn_source_type
                      AND demand_source_header_id = v_batch_id
                      AND demand_source_line_id = v_material_detail_id
                      AND NOT EXISTS (
                                      SELECT 1
                                        FROM mtl_material_transactions_temp
                                       WHERE reservation_id =
                                                             mr.reservation_id) );
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      OPEN cur_reservations (p_organization_id
                            ,p_batch_id
                            ,p_material_detail_id);

      FETCH cur_reservations
       INTO l_temp;

      CLOSE cur_reservations;

      IF (NVL (l_temp, 0) = 1) THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
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
         RETURN FALSE;
   END pending_reservations_exist;

   PROCEDURE convert_dtl_reservation (
      p_reservation_rec        IN              mtl_reservations%ROWTYPE
     ,p_material_details_rec   IN              gme_material_details%ROWTYPE
     ,p_qty_convert            IN              NUMBER := NULL
     ,x_message_count          OUT NOCOPY      NUMBER
     ,x_message_list           OUT NOCOPY      VARCHAR2
     ,x_return_status          OUT NOCOPY      VARCHAR2)
   IS
      l_api_name        CONSTANT VARCHAR2 (30)   := 'CONVERT_DTL_RESERVATION';
      error_unexpected           EXCEPTION;
      fetch_error                EXCEPTION;
      validation_error           EXCEPTION;
      create_transaction_error   EXCEPTION;
      detail_reservation_error   EXCEPTION;
      uom_conversion_failure     EXCEPTION;
      l_item_rec                 mtl_system_items%ROWTYPE;
      l_reservation_rec          mtl_reservations%ROWTYPE;
      l_qty_convert              NUMBER;
      l_rsv_type                 NUMBER;
      l_return_status            VARCHAR2 (1);
      l_actual_qty               NUMBER;

      CURSOR cur_fetch_item (v_org_id NUMBER, v_inventory_item_id NUMBER)
      IS
         SELECT *
           FROM mtl_system_items_b
          WHERE organization_id = v_org_id
            AND inventory_item_id = v_inventory_item_id;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Retrieve item row */
      OPEN cur_fetch_item (p_material_details_rec.organization_id
                          ,p_material_details_rec.inventory_item_id);

      FETCH cur_fetch_item
       INTO l_item_rec;

      IF cur_fetch_item%NOTFOUND THEN
         CLOSE cur_fetch_item;

         gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                    ,'TABLE_NAME'
                                    ,'MTL_SYSTEM_ITEMS');

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line
               (   g_pkg_name
                || '.'
                || l_api_name
                || ' Retrieval failure against mtl_system_items using id of  '
                || p_material_details_rec.inventory_item_id);
         END IF;

         RAISE fetch_error;
      END IF;

      CLOSE cur_fetch_item;

      /* Ensure the item is transaction enabled */
      IF l_item_rec.mtl_transactions_enabled_flag <> 'Y' THEN
         gme_common_pvt.log_message ('GME_ITEM_NOT_TRANSACTABLE');
         RAISE validation_error;
      END IF;

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;
      /* Verify that the reservation is fully detailed */
      l_rsv_type :=
         gme_reservations_pvt.reservation_fully_specified
                (p_reservation_rec             => p_reservation_rec
                ,p_item_location_control       => NVL(l_item_rec.location_control_code,1)
                ,p_item_restrict_locators      => l_item_rec.restrict_locators_code);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Return rsv_type from gme_reservations_pvt.reservation_fully_specified is '
             || TO_CHAR (l_rsv_type) );
      END IF;

      IF l_rsv_type = -1 THEN
         gme_common_pvt.log_message ('GME_RSV_DETAIL_REQUIRED');
         RAISE error_unexpected;
      END IF;

      IF l_rsv_type IN (0, 2) THEN                       -- Not fully detailed
         /* Detail the reservation to sub, locator level where possible */
         /* There must be sufficient inventory to support the reservation */
         gme_reservations_pvt.convert_partial_to_dlr
                               (p_reservation_rec       => p_reservation_rec
                               ,p_material_dtl_rec      => p_material_details_rec
                               ,p_item_rec              => l_item_rec
                               ,x_reservation_rec       => l_reservation_rec
                               ,x_return_status         => x_return_status);

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line
               (   g_pkg_name
                || '.'
                || l_api_name
                || ' Return status from gme_reservations_pvt.convert_partial_to_dlr is '
                || x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            gme_common_pvt.log_message ('GME_RSV_DETAIL_REQUIRED');
            RAISE detail_reservation_error;
         END IF;
      ELSE                                                   -- fully detailed
         l_reservation_rec := p_reservation_rec;
      END IF;

      /* Next phase is to create the inventory transaction and relieve the reservation */
      l_actual_qty := NVL (p_material_details_rec.actual_qty, 0);
      /* If p_qty_convert is null, need to pass in the full reservation_qty */
      /* but this must be expressed in terms of gme_material_details.dtl_um */
      l_qty_convert := p_qty_convert;

      IF l_qty_convert IS NULL THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' determine quantity to convert');
         END IF;

         IF p_material_details_rec.dtl_um =
                                        l_reservation_rec.reservation_uom_code THEN
            l_qty_convert := l_reservation_rec.reservation_quantity;
         ELSIF p_material_details_rec.dtl_um =
                                            l_reservation_rec.primary_uom_code THEN
            l_qty_convert := l_reservation_rec.primary_reservation_quantity;
         ELSE
            l_qty_convert :=
               inv_convert.inv_um_convert
                  (item_id              => l_reservation_rec.inventory_item_id
                  ,organization_id      => l_reservation_rec.organization_id
                  ,lot_number           => l_reservation_rec.lot_number
                  ,PRECISION            => gme_common_pvt.g_precision
                  ,from_quantity        => l_reservation_rec.primary_reservation_quantity
                  ,from_unit            => l_reservation_rec.primary_uom_code
                  ,to_unit              => p_material_details_rec.dtl_um
                  ,from_name            => NULL
                  ,to_name              => NULL);

            IF (l_qty_convert < 0) THEN
               IF g_debug <= gme_debug.g_log_statement THEN
                  gme_debug.put_line
                              (   g_pkg_name
                               || '.'
                               || l_api_name
                               || ' UOM Conversion fail from '
                               || l_reservation_rec.primary_uom_code
                               || ' to '
                               || p_material_details_rec.dtl_um
                               || ' for qty '
                               || l_reservation_rec.primary_reservation_quantity);
               END IF;

               RAISE uom_conversion_failure;
            END IF;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Invoking build_and_create_transaction with consume_qty of '
             || l_qty_convert
             || ' Subinventory is '
             || l_reservation_rec.subinventory_code
             || ' lot_divisible flag is '
             || l_item_rec.lot_divisible_flag);
      END IF;

      -- Bug 6778968 - Add p_called_by parameter to signify the calling routine.
      -- The variable l_qty_convert is expressed in terms of gme_material_details.dtl_um
      gme_release_batch_pvt.build_and_create_transaction
                                     (p_rsrv_rec           => l_reservation_rec
                                     ,p_lot_divisible_flag => l_item_rec.lot_divisible_flag
                                     ,p_mtl_dtl_rec        => p_material_details_rec
                                     ,p_trans_date         => SYSDATE
                                     ,p_consume_qty        => l_qty_convert
                                     ,p_called_by          => 'CVT'
                                     ,p_secondary_uom_code => l_item_rec.secondary_uom_code
                                     ,x_actual_qty         => l_actual_qty
                                     ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Return status from gme_release_batch_pvt.build_and_create_transaction is '
             || x_return_status);
      END IF;

      IF x_return_status NOT IN ('T', fnd_api.g_ret_sts_success) THEN
         RAISE create_transaction_error;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                   (   g_pkg_name
                    || '.'
                    || l_api_name
                    || ' build_and_create_transaction returns actial_qty of '
                    || l_actual_qty);
         gme_debug.put_line (   ' Completed private layer '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN error_unexpected OR uom_conversion_failure OR fetch_error OR validation_error OR create_transaction_error OR detail_reservation_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || ' When others exception:'
                                || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
   END convert_dtl_reservation;

   PROCEDURE auto_detail_line (
      p_material_details_rec   IN              gme_material_details%ROWTYPE
     ,x_return_status          OUT NOCOPY      VARCHAR2)
   IS
      l_api_name      CONSTANT VARCHAR2 (30)            := 'auto_detail_line';
      l_item_rec               mtl_system_items_b%ROWTYPE;
      l_rsv_rec                mtl_reservations%ROWTYPE;
      l_rsv_tbl                gme_common_pvt.reservations_tab;
      l_reservations_tbl       inv_reservation_global.mtl_reservation_tbl_type;
      l_rsv_type               NUMBER;
      l_open_qty               NUMBER;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      l_count                  NUMBER                                    := 1;
      l_return_status          VARCHAR2 (1);
      l_suggestion_list_rec_type wms_rule_extn_pvt.g_suggestion_list_rec_type;
      l_trolin_rec_type        inv_move_order_pub.trolin_rec_type;
      l_trolin_rec             mtl_txn_request_lines%ROWTYPE;
      reservable_type_error    EXCEPTION;
      retrieve_res_fail        EXCEPTION;
      item_fetch_fail          EXCEPTION;
      fetch_error              EXCEPTION;
      relieve_res_error        EXCEPTION;
      open_qty_error           EXCEPTION;
      update_mo_fail           EXCEPTION;
      create_suggestions_err   EXCEPTION;
      error_unexpected         EXCEPTION;
      create_reservation_err   EXCEPTION;
      --Bug#4604943
      invalid_mtl_for_rsrv     EXCEPTION;


      CURSOR cur_get_item_rec (v_item_id NUMBER, v_org_id NUMBER)
      IS
         SELECT *
           FROM mtl_system_items_b
           WHERE inventory_item_id = v_item_id AND organization_id = v_org_id;

      CURSOR cur_get_mo_rec (v_move_order_line_id NUMBER)
      IS
         SELECT   *
           FROM mtl_txn_request_lines
           WHERE line_id = v_move_order_line_id;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'Verify reservable_type ');
      END IF;

     --Bug#4604943 Begin validate the batch and material line
      validate_mtl_for_reservation(
                 p_material_detail_rec => p_material_details_rec
                ,x_return_status       => l_return_status );
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE invalid_mtl_for_rsrv;
      END IF;
       -- Pawan kumar made changes for 5294184

      IF  NOT (p_material_details_rec.material_requirement_date < SYSDATE +
         NVL(gme_common_pvt.g_rule_based_resv_horizon,10000)) THEN
        gme_common_pvt.log_message ('GME_NO_ING_TIME');
         RETURN ;
      END IF;

     --Bug#4604943 End
     -- Check for any ingredient failing in reservation category

      OPEN cur_get_item_rec (p_material_details_rec.inventory_item_id
                            ,p_material_details_rec.organization_id);

      FETCH cur_get_item_rec
       INTO l_item_rec;

      IF cur_get_item_rec%NOTFOUND THEN
         CLOSE cur_get_item_rec;

         gme_common_pvt.log_message ('PM_INVALID_ITEM');

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' item fetch fail for '
                                || p_material_details_rec.inventory_item_id);
         END IF;

         RAISE item_fetch_fail;
      END IF;

      CLOSE cur_get_item_rec;

      IF NVL (l_item_rec.reservable_type, 1) <> 1 /*Reservable*/ THEN
         RAISE reservable_type_error;
      END IF;

      gme_reservations_pvt.get_material_reservations
           (p_organization_id         => p_material_details_rec.organization_id
           ,p_batch_id                => p_material_details_rec.batch_id
           ,p_material_detail_id      => p_material_details_rec.material_detail_id
           ,x_return_status           => x_return_status
           ,x_reservations_tbl        => l_rsv_tbl);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' get_material_reservations returns '
                             || x_return_status);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' No. of reservations is '
                             || l_rsv_tbl.COUNT);
      END IF;

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE retrieve_res_fail;
      END IF;

      WHILE l_count <= l_rsv_tbl.COUNT LOOP
         l_rsv_rec := l_rsv_tbl (l_count);
         /* Verify that the reservation is fully detailed */
         /* Bug 5441643 Added NVL condition for location control code*/
         l_rsv_type :=
            gme_reservations_pvt.reservation_fully_specified
               (p_reservation_rec             => l_rsv_rec
               ,p_item_location_control       => NVL(l_item_rec.location_control_code,1)
               ,p_item_restrict_locators      => l_item_rec.restrict_locators_code);

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line
               (   g_pkg_name
                || '.'
                || l_api_name
                || ' Return rsv_type from gme_reservations_pvt.reservation_fully_specified is '
                || TO_CHAR (l_rsv_type) );
         END IF;

         IF l_rsv_type = -1 THEN
            gme_common_pvt.log_message ('GME_RSV_DETAIL_REQUIRED');
            RAISE error_unexpected;
         END IF;

         IF l_rsv_type = 0 /*HLT*/ THEN
            gme_reservations_pvt.relieve_reservation
               (p_reservation_id        => l_rsv_rec.reservation_id
               ,p_prim_relieve_qty      => l_rsv_rec.primary_reservation_quantity
               ,x_return_status         => x_return_status);

            IF g_debug <= gme_debug.g_log_statement THEN
               gme_debug.put_line
                            (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Return status from relieve_reservation is '
                             || x_return_status);
            END IF;

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE relieve_res_error;
            END IF;
         END IF;

         l_count := l_count + 1;
      END LOOP;

      /* Assess the open quantity */
    /* 8599753  Apeksha :commenting this call as we are directly passing the value of l_open_qty for "R" as reservation status.
    gme_common_pvt.get_open_qty (p_mtl_dtl_rec        => p_material_details_rec
                                  ,p_called_by          => 'R'
                                  ,x_open_qty           => l_open_qty
                                  ,x_return_status      => x_return_status);8599753 ends*/
/*8599753*/
l_open_qty :=  NVL (p_material_details_rec.wip_plan_qty, p_material_details_rec.plan_qty) - (p_material_details_rec.actual_qty);
/*8599753*/
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' get_open_qty returns open qty of '
                             || l_open_qty);
      END IF;

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE open_qty_error;
      END IF;

      /* If there is no open quantity, return here */
      IF l_open_qty <= 0 THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'No open quantity so RETURN now');
         END IF;

         RETURN;
      END IF;

      /* Update the Move Order */
      gme_move_orders_pvt.update_move_order_lines
           (p_batch_id                => p_material_details_rec.batch_id
           ,p_material_detail_id      => p_material_details_rec.material_detail_id
           ,p_new_qty                 => l_open_qty
           ,p_new_date                => NULL
           ,p_invis_move_line_id      => p_material_details_rec.move_order_line_id
           ,x_return_status           => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Return from update_move_order_lines is '
                             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE update_mo_fail;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Invoke wms_rule_extn_pvt.suggest_reservations for mo line_id => '
             || p_material_details_rec.move_order_line_id);
      END IF;

      OPEN cur_get_mo_rec (p_material_details_rec.move_order_line_id);

      FETCH cur_get_mo_rec INTO l_trolin_rec;

      IF cur_get_mo_rec%NOTFOUND THEN
         CLOSE cur_get_mo_rec;

         gme_common_pvt.log_message ('GME_NO_DATA_FOUND','TABLE_NAME','MTL_TXN_REQUEST_LINES');

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' move order line fetch fail for id'
                                || p_material_details_rec.move_order_line_id);
         END IF;
         RAISE fetch_error;
      END IF;
      CLOSE cur_get_mo_rec;

      l_trolin_rec_type.attribute1                   := l_trolin_rec.attribute1;
      l_trolin_rec_type.attribute2                   := l_trolin_rec.attribute2 ;
      l_trolin_rec_type.attribute3                   := l_trolin_rec.attribute3 ;
      l_trolin_rec_type.attribute4                   := l_trolin_rec.attribute4 ;
      l_trolin_rec_type.attribute5                   := l_trolin_rec.attribute5 ;
      l_trolin_rec_type.attribute6                   := l_trolin_rec.attribute6 ;
      l_trolin_rec_type.attribute7                   := l_trolin_rec.attribute7 ;
      l_trolin_rec_type.attribute8                   := l_trolin_rec.attribute8 ;
      l_trolin_rec_type.attribute9                   := l_trolin_rec.attribute9 ;
      l_trolin_rec_type.attribute10                  := l_trolin_rec.attribute10;
      l_trolin_rec_type.attribute11                  := l_trolin_rec.attribute11;
      l_trolin_rec_type.attribute12                  := l_trolin_rec.attribute12;
      l_trolin_rec_type.attribute13                  := l_trolin_rec.attribute13;
      l_trolin_rec_type.attribute14                  := l_trolin_rec.attribute14;
      l_trolin_rec_type.attribute15                  := l_trolin_rec.attribute15;
      l_trolin_rec_type.attribute_category           := l_trolin_rec.attribute_category;
      l_trolin_rec_type.created_by                   := l_trolin_rec.created_by;
      l_trolin_rec_type.creation_date                := l_trolin_rec.creation_date;
      l_trolin_rec_type.date_required                := l_trolin_rec.date_required;
      l_trolin_rec_type.from_locator_id              := l_trolin_rec.from_locator_id;
      l_trolin_rec_type.from_subinventory_code       := l_trolin_rec.from_subinventory_code;
      l_trolin_rec_type.from_subinventory_id         := l_trolin_rec.from_subinventory_id;
      l_trolin_rec_type.header_id                    := l_trolin_rec.header_id;
      l_trolin_rec_type.inventory_item_id            := l_trolin_rec.inventory_item_id;
      l_trolin_rec_type.last_updated_by              := l_trolin_rec.last_updated_by;
      l_trolin_rec_type.last_update_date             := l_trolin_rec.last_update_date;
      l_trolin_rec_type.last_update_login            := l_trolin_rec.last_update_login;
      l_trolin_rec_type.line_id                      := l_trolin_rec.line_id;
      l_trolin_rec_type.line_number                  := l_trolin_rec.line_number;
      l_trolin_rec_type.line_status                  := l_trolin_rec.line_status;
      l_trolin_rec_type.lot_number                   := l_trolin_rec.lot_number;
      l_trolin_rec_type.organization_id              := l_trolin_rec.organization_id;
      l_trolin_rec_type.program_application_id       := l_trolin_rec.program_application_id;
      l_trolin_rec_type.program_id                   := l_trolin_rec.program_id;
      l_trolin_rec_type.program_update_date          := l_trolin_rec.program_update_date;
      l_trolin_rec_type.project_id                   := l_trolin_rec.project_id;
      l_trolin_rec_type.quantity                     := l_trolin_rec.quantity;
      l_trolin_rec_type.quantity_delivered           := l_trolin_rec.quantity_delivered;
      l_trolin_rec_type.quantity_detailed            := l_trolin_rec.quantity_detailed;
      l_trolin_rec_type.reason_id                    := l_trolin_rec.reason_id;
      l_trolin_rec_type.reference                    := l_trolin_rec.reference;
      l_trolin_rec_type.reference_id                 := l_trolin_rec.reference_id;
      l_trolin_rec_type.reference_type_code          := l_trolin_rec.reference_type_code;
      l_trolin_rec_type.request_id                   := l_trolin_rec.request_id;
      l_trolin_rec_type.revision                     := l_trolin_rec.revision;
      l_trolin_rec_type.serial_number_end            := l_trolin_rec.serial_number_end;
      l_trolin_rec_type.serial_number_start          := l_trolin_rec.serial_number_start;
      l_trolin_rec_type.status_date                  := l_trolin_rec.status_date;
      l_trolin_rec_type.task_id                      := l_trolin_rec.task_id;
      l_trolin_rec_type.to_account_id                := l_trolin_rec.to_account_id;
      l_trolin_rec_type.to_locator_id                := l_trolin_rec.to_locator_id;
      l_trolin_rec_type.to_subinventory_code         := l_trolin_rec.to_subinventory_code;
      l_trolin_rec_type.to_subinventory_id           := l_trolin_rec.to_subinventory_id;
      l_trolin_rec_type.transaction_header_id        := l_trolin_rec.transaction_header_id;
      l_trolin_rec_type.transaction_type_id          := l_trolin_rec.transaction_type_id;
      l_trolin_rec_type.txn_source_id                := l_trolin_rec.txn_source_id;
      l_trolin_rec_type.txn_source_line_id           := l_trolin_rec.txn_source_line_id;
      l_trolin_rec_type.txn_source_line_detail_id    := l_trolin_rec.txn_source_line_detail_id;
      l_trolin_rec_type.transaction_source_type_id   := l_trolin_rec.transaction_source_type_id;
      l_trolin_rec_type.primary_quantity             := l_trolin_rec.primary_quantity;
      l_trolin_rec_type.to_organization_id           := l_trolin_rec.to_organization_id;
      l_trolin_rec_type.pick_strategy_id             := l_trolin_rec.pick_strategy_id;
      l_trolin_rec_type.put_away_strategy_id         := l_trolin_rec.put_away_strategy_id;
      l_trolin_rec_type.uom_code                     := l_trolin_rec.uom_code;
      l_trolin_rec_type.unit_number                  := l_trolin_rec.unit_number;
      l_trolin_rec_type.ship_to_location_id          := l_trolin_rec.ship_to_location_id;
      l_trolin_rec_type.from_cost_group_id           := l_trolin_rec.from_cost_group_id;
      l_trolin_rec_type.to_cost_group_id             := l_trolin_rec.to_cost_group_id;
      l_trolin_rec_type.lpn_id                       := l_trolin_rec.lpn_id;
      l_trolin_rec_type.to_lpn_id                    := l_trolin_rec.to_lpn_id;
      l_trolin_rec_type.pick_methodology_id          := l_trolin_rec.pick_methodology_id;
      l_trolin_rec_type.container_item_id            := l_trolin_rec.container_item_id;
      l_trolin_rec_type.carton_grouping_id           := l_trolin_rec.carton_grouping_id;
    --l_trolin_rec_type.return_status                := l_trolin_rec.return_status;
    --l_trolin_rec_type.db_flag                      := l_trolin_rec.db_flag;
    --l_trolin_rec_type.operation                    := l_trolin_rec.operation;
      l_trolin_rec_type.inspection_status            := l_trolin_rec.inspection_status;
      l_trolin_rec_type.wms_process_flag             := l_trolin_rec.wms_process_flag;
      l_trolin_rec_type.pick_slip_number             := l_trolin_rec.pick_slip_number;
      l_trolin_rec_type.pick_slip_date               := l_trolin_rec.pick_slip_date;
      l_trolin_rec_type.ship_set_id                  := l_trolin_rec.ship_set_id;
      l_trolin_rec_type.ship_model_id                := l_trolin_rec.ship_model_id;
      l_trolin_rec_type.model_quantity               := l_trolin_rec.model_quantity;
      l_trolin_rec_type.required_quantity            := l_trolin_rec.required_quantity;
      l_trolin_rec_type.secondary_quantity           := l_trolin_rec.secondary_quantity;
      --l_trolin_rec_type.secondary_uom              := l_trolin_rec.secondary_uom;
      l_trolin_rec_type.secondary_quantity_detailed  := l_trolin_rec.secondary_quantity_detailed;
      l_trolin_rec_type.secondary_quantity_delivered := l_trolin_rec.secondary_quantity_delivered;
      l_trolin_rec_type.grade_code                   := l_trolin_rec.grade_code;
      l_trolin_rec_type.secondary_required_quantity  := l_trolin_rec.secondary_required_quantity;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' about to invoke SUGGEST_RESERVATIONS for required quantity of '
                             ||l_trolin_rec_type.required_quantity);
      END IF;

      wms_rule_extn_pvt.suggest_reservations(
           p_api_version            =>  1.0
         , p_init_msg_list          =>  FND_API.G_TRUE
         , p_commit                 =>  FND_API.G_FALSE
         , p_validation_level       =>  100
         , x_return_status          =>  x_return_status
         , x_msg_count              =>  l_msg_count
         , x_msg_data               =>  l_msg_data
         , p_transaction_temp_id    =>  p_material_details_rec.move_order_line_id
         , p_allow_partial_pick     =>  FND_API.G_TRUE
         , p_suggest_serial         =>  FND_API.G_FALSE
         , p_mo_line_rec            =>  l_trolin_rec_type
         , p_demand_source_header_id=>  p_material_details_rec.batch_id
         , p_demand_source_line_id  =>  p_material_details_rec.material_detail_id
         , p_demand_source_type     =>  5
         , p_demand_source_name     =>  NULL
         , p_requirement_date       =>  p_material_details_rec.material_requirement_date
         , p_suggestions            =>  l_suggestion_list_rec_type);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' call to SUGGEST_RESERVATIONS returns '
                             || x_return_status);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' suggest_reservations mesg '
                             || l_msg_data);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE create_suggestions_err;
      END IF;

      /* Create a High Level Reservation for any outstanding open quantity */
      /* start by determining what the outstanding open quantity is        */
      gme_common_pvt.get_open_qty (p_mtl_dtl_rec        => p_material_details_rec
                                  ,p_called_by          => 'R'
                                  ,x_open_qty           => l_open_qty
                                  ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                     (   g_pkg_name
                      || '.'
                      || l_api_name
                      || ' after detailing get_open_qty returns open qty of '
                      || l_open_qty);
      END IF;

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE open_qty_error;
      END IF;

      /* Attempt to create a high level reservation (at organization level) for the outstanding qty */
      /* However there may be no inventory left to do this successfully so accept error status      */
      IF l_open_qty > 0 THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' attempting to create a HLR for the outstanding qty '
                                || l_open_qty     );
         END IF;
         gme_reservations_pvt.create_material_reservation
                                   (p_matl_dtl_rec       => p_material_details_rec
                                   ,p_resv_qty           => l_open_qty
                                   ,x_return_status      => l_return_status);

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' create_material_reservation returns '
                                || x_return_status);
         END IF;

         /* may not be sufficient inventory to create a balancing HLR so accept an error return */
         IF l_return_status NOT IN
                         (fnd_api.g_ret_sts_success, fnd_api.g_ret_sts_error) THEN
            x_return_status := l_return_status;
            RAISE create_reservation_err;
         END IF;
      END IF;

      /* bug: 6665408 Skommine Added call to clear_quantity_cache procedure
                    to recreate the quantity tree after the reservations are done */
      inv_quantity_tree_pub.clear_quantity_cache;


      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN reservable_type_error OR retrieve_res_fail OR
        item_fetch_fail OR fetch_error OR
        relieve_res_error OR open_qty_error OR update_mo_fail OR
        create_suggestions_err OR error_unexpected OR create_reservation_err THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'Exiting due to error exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name);
         END IF;
      --Bug#4604943
      WHEN invalid_mtl_for_rsrv THEN
         x_return_status := l_return_status;
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
   END auto_detail_line;

   PROCEDURE auto_detail_batch(p_batch_rec            IN GME_BATCH_HEADER%ROWTYPE,
                               p_timefence            IN NUMBER DEFAULT 100000,
                               x_return_status        OUT NOCOPY VARCHAR2) IS

    l_valid_mat            BOOLEAN;
    l_mat_status           NUMBER;
    l_step_status          NUMBER;
    l_step_id              NUMBER;
    l_return_status        VARCHAR2(1);
    l_found                NUMBER := 0;
    l_api_name             CONSTANT VARCHAR2(30) := 'auto_detail_batch' ;

    auto_detail_failure    EXCEPTION;
    -- Pawan kumar made changes for 5294184- add gme_common_pvt.g_rule_based_resv_horizon
    /* Retrieve Ingredient rows */
    CURSOR cur_get_reservable_ings
    IS
      SELECT d.*
      FROM gme_material_details d,mtl_system_items_b i
      WHERE d.batch_id = p_batch_rec.batch_id
        AND d.line_type = -1
        AND d.material_requirement_date < SYSDATE + NVL(gme_common_pvt.g_rule_based_resv_horizon,p_timefence)
        AND i. inventory_item_id = d.inventory_item_id
        AND i.organization_id = d.organization_id
        AND i.reservable_type = 1
        AND d.phantom_type = 0
      ORDER BY d.line_no;

   BEGIN
     IF g_debug <= gme_debug.g_log_procedure THEN
       gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF g_debug <= gme_debug.g_log_statement THEN
       gme_debug.put_line(g_pkg_name||'.'||l_api_name||'gme_common_pvt.g_rule_based_resv_horizon
         is '||gme_common_pvt.g_rule_based_resv_horizon);
       gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Retrieve Material Detail lines for batch_id '||p_batch_rec.batch_id);
       gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Timefence is '||p_timefence);
       gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Batch Status is '||p_batch_rec.batch_status);

     END IF;

     FOR get_matl_rec IN cur_get_reservable_ings LOOP
      l_found := 1 ;
       /* Bug#4604943 moved the validation code to procedure validate_mtl_for_reservation
          As the validation will be done in auto_detail_line procedure there is no need to the
          validation again over here
          commented the following IF condition also
        */
       --IF l_valid_mat THEN

       /* Invoke auto detail line to create detailed reservations for each of the ingredient lines */
       IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||' ********************* Ingredient Line Processing **************************');
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Invoke auto detail for material detail id '||get_matl_rec.material_detail_id);
       END IF;

       /*calling auto detail line */
       gme_reservations_pvt.auto_detail_line(p_material_details_rec => get_matl_rec
                                            ,x_return_status        => l_return_status);

       IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Call to auto detail line returns '||x_return_status);
       END IF;

       /* Bug#4604943 just checking for unexpected error similar to create_batch_reservations */
       IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE auto_detail_failure;
       END IF;

       --END IF;
     END LOOP;
     -- Pawan kumar made changes for 5294184
     IF l_found = 0 THEN
        gme_common_pvt.log_message ('GME_NO_ING_TIME');
     END IF;
     IF g_debug <= gme_debug.g_log_statement THEN
       gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
     END IF;

   EXCEPTION
     WHEN auto_detail_failure THEN
       IF g_debug <= gme_debug.g_log_unexpected THEN
         gme_debug.put_line('Exiting due to error exception in '||g_pkg_name||'.'||l_api_name);
       END IF;
       x_return_status := l_return_status;
     WHEN OTHERS THEN
       IF g_debug <= gme_debug.g_log_unexpected THEN
         gme_debug.put_line('When others exception in '||g_pkg_name||'.'||l_api_name||' Error is ' || SQLERRM);
       END IF;
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END auto_detail_batch;

   --Bug#4604943 created the following procedure
   PROCEDURE validate_mtl_for_reservation(
      p_material_detail_rec    IN              GME_MATERIAL_DETAILS%ROWTYPE,
      x_return_status          OUT NOCOPY      VARCHAR2) IS

     l_api_name         VARCHAR2(30) := 'VALIDATE_MTL_FOR_RESERVATION';
     l_batch_header_rec gme_batch_header%ROWTYPE;
     l_step_id          NUMBER;
     l_step_status      NUMBER;

     fetch_failure      EXCEPTION;
     demand_line_error  EXCEPTION;
     batch_status_error EXCEPTION;
   BEGIN
     IF g_debug <= gme_debug.g_log_procedure THEN
       gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
     END IF;

     x_return_status := fnd_api.g_ret_sts_success;

     l_batch_header_rec.batch_id := p_material_detail_rec.batch_id;
     IF NOT (gme_batch_header_dbl.fetch_row (l_batch_header_rec, l_batch_header_rec)) THEN
      RAISE fetch_failure;
     END IF;

    IF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending THEN
       --pending batch just return
       IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Batch is Pending status');
       END IF;
       RETURN;
    ELSIF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_wip THEN
      /* In WIP Bathes, do not create reservations for automatic and automatic by step if assoc step is not released*/
      IF p_material_detail_rec.release_type IN (gme_common_pvt.g_mtl_manual_release,gme_common_pvt.g_mtl_incremental_release) THEN
         IF g_debug <= gme_debug.g_log_statement THEN
           gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Batch is in WIP and material line is manual/incremental');
         END IF;
         RETURN;
      ELSIF p_material_detail_rec.release_type = gme_common_pvt.g_mtl_autobystep_release THEN
        /* if automatic by step then check step status */
        IF g_debug <= gme_debug.g_log_statement THEN
           gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Batch is in WIP and material line is Autoby step');
         END IF;
        IF NOT gme_common_pvt.get_assoc_step(p_material_detail_rec.material_detail_id,l_step_id,l_step_status) THEN
         RAISE demand_line_error;
        ELSIF l_step_id IS NOT NULL AND NVL(l_step_status,-1) <> gme_common_pvt.g_step_pending THEN
         RAISE demand_line_error;
        END IF;
      ELSE
        IF g_debug <= gme_debug.g_log_statement THEN
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Batch is in WIP and material line is automatic');
        END IF;
        RAISE demand_line_error;
      END IF; /*end of validations for WIP Batch*/
    ELSE
      RAISE batch_status_error;
    END IF; /* outer most if */

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
    END IF;
   EXCEPTION
    WHEN fetch_failure THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN demand_line_error THEN
      gme_common_pvt.log_message('GME_INVALID_DEMAND_LINE');
       x_return_status := fnd_api.g_ret_sts_error;
    WHEN batch_status_error THEN
      gme_common_pvt.log_message('GME_INVALID_BATCH_STATUS','PROCESS','RESERVATIONS');
      x_return_status := fnd_api.g_ret_sts_error;
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
   END validate_mtl_for_reservation;
END gme_reservations_pvt;

/