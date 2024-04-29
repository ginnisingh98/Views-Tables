--------------------------------------------------------
--  DDL for Package Body INV_RSV_DETAIL_STAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RSV_DETAIL_STAGE_PVT" AS
/* $Header: INVRSDSB.pls 120.0.12010000.2 2010/03/11 09:41:32 viiyer noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_RSV_DETAIL_STAGE_PVT';
g_version_printed        BOOLEAN      := FALSE;
g_debug NUMBER;

 -- procedure to print a message to dbms_output
 -- disable by default since dbms_output.put_line is not allowed
 PROCEDURE debug_print(p_message IN VARCHAR2, p_level IN NUMBER := 9) IS
 BEGIN
    inv_log_util.TRACE(p_message, 'INV_RSV_DETAIL_STAGE_PVT', p_level);
 END debug_print;


-- Function
--   is_reservation_allowed
--
-- Description
--   This function will check whether the reservation is allowed for the given
--   SKU or not
--
-- Input Paramters
--   l_rsv_rec                  Contains info to be used to process the
--                              reservation with the SKU
-- Return Value
--   l_res_type                 = 1 if reservations are allowed
--                              = 2 if reservations are not allowed


 FUNCTION is_reservation_allowed
 (
   l_rsv_rec IN  inv_reservation_global.mtl_reservation_rec_type
 )
  RETURN NUMBER
  IS
    l_default_org_status_id NUMBER;
    l_return_status_id      NUMBER;
    l_res_type              NUMBER := 1;
    l_debug                 NUMBER;
    l_sub_reservable_type        NUMBER := 1;
    l_loc_reservable_type       NUMBER := 1;
    l_lot_reservable_type        NUMBER := 1;

  BEGIN
   l_debug := g_debug;
    IF (l_debug = 1) THEN
	    debug_print('Checking whether the reservations are allowed or not ');
    END IF;

    -- Check whether the onhand is reservable or not
    IF inv_cache.set_org_rec(l_rsv_rec.organization_id) THEN
       l_default_org_status_id :=  inv_cache.org_rec.default_status_id;
    END IF;

    IF (l_debug = 1) THEN
	    debug_print('Default Org status id is :' || l_default_org_status_id );
    END IF;


    IF l_default_org_status_id IS NULL THEN

	       IF (l_debug = 1) THEN
		    debug_print('Organization is not onhand material status enabled');
       		    debug_print('Checking the reservable status for individual SKU');
	       END IF;

	      -- Checking whether the subinventory is reservable or not
        -- If not reservable then no detailed/staged reservations would be created
        IF l_rsv_rec.subinventory_code IS NOT NULL AND l_rsv_rec.organization_id IS NOT NULL THEN
           BEGIN
             SELECT   NVL(reservable_type, 1)
               INTO   l_sub_reservable_type
               FROM   mtl_secondary_inventories
              WHERE   organization_id          = l_rsv_rec.organization_id
                AND   secondary_inventory_name = l_rsv_rec.subinventory_code;
           EXCEPTION
              WHEN OTHERS THEN
                 IF (l_debug = 1) THEN
                    debug_print('Exception Occurred while checking reservable type for subinventory : '
                                 || l_rsv_rec.subinventory_code || ' Organization Id :'
                                 || l_rsv_rec.organization_id );
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
           END;
        END IF;

        -- Checking whether the locator is reservable or not
        -- If not reservable then no detailed/staged reservations would be created
        IF l_rsv_rec.locator_id IS NOT NULL AND l_rsv_rec.organization_id IS NOT NULL THEN
           BEGIN
             SELECT   NVL(reservable_type, 1)
               INTO   l_loc_reservable_type
               FROM   mtl_item_locations
              WHERE   organization_id        = l_rsv_rec.organization_id
                AND   inventory_location_id  = l_rsv_rec.locator_id;
           EXCEPTION
             WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                 debug_print('Exception Occurred while checking reservable type for locator : '
                              || l_rsv_rec.locator_id || ' Organization Id :'
                              || l_rsv_rec.organization_id );
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
           END;
        END IF;

        -- Checking whether the lot is reservable or not
        -- If not reservable then no detailed/staged reservations would be created
        IF    l_rsv_rec.organization_id   IS NOT NULL
          AND l_rsv_rec.inventory_item_id IS NOT NULL
          AND l_rsv_rec.lot_number        IS NOT NULL THEN

           BEGIN
             SELECT   NVL(reservable_type, 1)
               INTO   l_lot_reservable_type
               FROM   mtl_lot_numbers
              WHERE   inventory_item_id = l_rsv_rec.inventory_item_id
                AND   organization_id   = l_rsv_rec.organization_id
                AND   lot_number        = l_rsv_rec.lot_number;
              EXCEPTION
                WHEN OTHERS THEN
                 IF (l_debug = 1) THEN
                    debug_print('Exception Occurred while checking reservable type for lot : '
                                 || l_rsv_rec.lot_number || ' Organization Id :'
                                 || l_rsv_rec.organization_id || ' Invenotry Item Id :'
                                 || l_rsv_rec.inventory_item_id);
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END;
        END IF;

        IF (l_debug = 1) THEN
            debug_print('For Inventory Item Id : ' || l_rsv_rec.inventory_item_id || ' Organization Id : '  || l_rsv_rec.organization_id);
            debug_print('Reservable type for Subinventory : ' ||  l_rsv_rec.subinventory_code || ' is :' || l_sub_reservable_type);
            debug_print('Reservable type for Locator : '      ||  l_rsv_rec.locator_id        || ' is :' || l_loc_reservable_type);
            debug_print('Reservable type for Lot Number : '   ||  l_rsv_rec.lot_number        || ' is :' || l_lot_reservable_type);
        END IF;

        IF l_sub_reservable_type = 1 AND l_loc_reservable_type = 1 AND l_lot_reservable_type = 1 THEN
             l_res_type := 1;
        ELSE
             l_res_type := 2;
        END IF;

    ELSE -- IF l_default_org_status_id IS NULL THEN

         -- Org is onhand material status enabled
         -- check for the status id and get the reservable_type from mtl_material_statuses_b
       	     IF (l_debug = 1) THEN
		             debug_print('Organization is onhand material status enabled');
       		       debug_print('Before getting the onhand status');
	           END IF;

         --calling function to get the MOQD status
        l_return_status_id  := INV_MATERIAL_STATUS_GRP.get_default_status
                               (p_organization_id       => l_rsv_rec.organization_id,
                                p_inventory_item_id     => l_rsv_rec.inventory_item_id,
                                p_sub_code              => l_rsv_rec.subinventory_code,
                                p_loc_id                => l_rsv_rec.locator_id,
                                p_lot_number            => l_rsv_rec.lot_number,
                                p_lpn_id                => l_rsv_rec.lpn_id,
                                p_transaction_action_id => NULL,
                                p_src_status_id         => NULL
                                );


	       IF (l_debug = 1) THEN
		            debug_print('Status id :' || l_return_status_id);
       		      debug_print('Before getting the onhand status');
	       END IF;

        IF l_return_status_id IS NULL THEN
            l_res_type :=1 ;  -- reservable type is YES
        ELSE
	          BEGIN
                SELECT reservable_type
                INTO   l_res_type
                FROM   mtl_material_statuses_b
                WHERE  status_id = l_return_status_id;
	          EXCEPTION
		           WHEN OTHERS THEN
	                  IF (l_debug = 1) THEN
		                  debug_print('Exception occurred while querying mtl_material_statuses_b :' || l_return_status_id);
	                  END IF;
		           l_res_type := 1 ;  -- reservable type is set to YES in case of exception
	          END;
	      END IF;
    END IF; -- IF l_default_org_status_id IS NULL THEN

	    IF (l_debug = 1) THEN
		    debug_print('Reservable type is :' || l_res_type);
	    END IF;

	    return l_res_type;

  EXCEPTION
      WHEN OTHERS THEN
	      IF (l_debug = 1) THEN
		       debug_print('Exception in is_reservation_allowed');
	      END IF;
        RETURN l_res_type;
  END;

 --
  -- Procedure
  --   Sort_Reservation
  -- Description
  --   Sorts the reservation table in the following order.
  --   The table will contain reservations corresponding to one
  --   demand source line
  --   1. Exact SKU match. Rev, Lot, Sub, Loc
  --   2. Partial SKU match. Rev, Lot, Sub. Locator unmatched
  --   3. Partial SKU match. Rev, Lot, Sub & Locator unmatched
  --   4. Partial SKU match. Rev. Lot, Sub & Locator unmatched
  --   5. No SKU match. Org/High level reservation
  --   6  Remaining reservations in the same order i.e increasing order of detailing
  -- Requirement
  --   Process reservation will process the reservation one by one
  --   starting with the first record from the output rsv table
  --   In order to pick the exact match or closest match, we need
  --   to sort the output rsv table in the above manner

  PROCEDURE Sort_Reservation
  ( p_mtl_reservation    IN OUT NOCOPY     inv_reservation_global.mtl_reservation_tbl_type ,
    p_rsv_rec            IN                inv_reservation_global.mtl_reservation_rec_type ,
    x_return_status      OUT NOCOPY  VARCHAR2 ,
    x_msg_count          OUT NOCOPY  NUMBER   ,
    x_msg_data           OUT NOCOPY  VARCHAR2
  )
  IS
    l_mtl_reservation inv_reservation_global.mtl_reservation_tbl_type;
    x_mtl_reservation inv_reservation_global.mtl_reservation_tbl_type;
    l_rsv_index       NUMBER      := 0;
    l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_debug NUMBER;

  BEGIN

    l_mtl_reservation := p_mtl_reservation;
    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('Inside Sort_Reservations. Original reservation count: ' || l_mtl_reservation.Count);
    END IF;
     -- Loop through the full rsv table to check for record wherein the full SKU is matching
	   -- If found, put the matching row into a different variable
     IF l_mtl_reservation.Count > 0 THEN
	   FOR i IN l_mtl_reservation.first..l_mtl_reservation.last
	   LOOP

		   IF nvl(l_mtl_reservation(i).revision ,        '@@@') = nvl(p_rsv_rec.revision,         '@@@') AND
		      nvl(l_mtl_reservation(i).lot_number,       '@@@') = nvl(p_rsv_rec.lot_number,       '@@@') AND
		      nvl(l_mtl_reservation(i).subinventory_code,'@@@') = nvl(p_rsv_rec.subinventory_code,'@@@') AND
		      nvl(l_mtl_reservation(i).locator_id,        -999) = nvl(p_rsv_rec.locator_id,        -999)
		   THEN
		      l_rsv_index := l_rsv_index + 1;
		      x_mtl_reservation(l_rsv_index) := l_mtl_reservation(i);
		      l_mtl_reservation.DELETE(i);
		   END IF;
	   END LOOP;
     END IF;

     IF (l_debug = 1) THEN
        debug_print('Exact match. Rev, Lot, Sub Loc : ' || l_rsv_index);
     END IF;

     -- Loop through the full rsv table to check for record wherein the partial SKU is matching
     -- rev, lot, sub matching
     -- If found, put the matching row into a different variable
     IF l_mtl_reservation.Count > 0 THEN
	   FOR i IN l_mtl_reservation.first..l_mtl_reservation.last
	   LOOP

		   IF nvl(l_mtl_reservation(i).revision ,        '@@@') = nvl(p_rsv_rec.revision,         '@@@') AND
		      nvl(l_mtl_reservation(i).lot_number,       '@@@') = nvl(p_rsv_rec.lot_number,       '@@@') AND
		      nvl(l_mtl_reservation(i).subinventory_code,'@@@') = nvl(p_rsv_rec.subinventory_code,'@@@')
		   THEN
		       l_rsv_index := l_rsv_index + 1;
		       x_mtl_reservation(l_rsv_index) := l_mtl_reservation(i);
		       l_mtl_reservation.DELETE(i);
		   END IF;
	   END LOOP;
     END IF;

     IF (l_debug = 1) THEN
        debug_print('Partial match. Rev, Lot, Sub : ' || l_rsv_index);
     END IF;

     -- Loop through the full rsv table to check for record wherein the partial SKU is matching
     -- rev & lot matching
     -- If found, put the matching row into a different variable
     IF l_mtl_reservation.Count > 0 THEN
	   FOR i IN l_mtl_reservation.first..l_mtl_reservation.last
	   LOOP

		   IF nvl(l_mtl_reservation(i).revision  , '@@@') = nvl(p_rsv_rec.revision  , '@@@') AND
		      nvl(l_mtl_reservation(i).lot_number, '@@@') = nvl(p_rsv_rec.lot_number, '@@@')
		   THEN
		      l_rsv_index := l_rsv_index + 1;
		      x_mtl_reservation(l_rsv_index) := l_mtl_reservation(i);
		      l_mtl_reservation.DELETE(i);
		   END IF;
	   END LOOP;
     END IF;

     IF (l_debug = 1) THEN
        debug_print('Partial match. Rev, Lot : ' || l_rsv_index);
     END IF;

     -- Loop through the full rsv table to check for record wherein the partial SKU is matching
     -- only rev matching\
     -- If found, put the matching row into a different variable
     IF l_mtl_reservation.Count > 0 THEN
	   FOR i IN l_mtl_reservation.first..l_mtl_reservation.last
	   LOOP
		   IF nvl(l_mtl_reservation(i).revision , '@@@') = nvl(p_rsv_rec.revision, '@@@')
		   THEN
   		      l_rsv_index := l_rsv_index + 1;
		      x_mtl_reservation(l_rsv_index) := l_mtl_reservation(i);
		      l_mtl_reservation.DELETE(i);
		   END IF;
	   END LOOP;
     END IF;

     IF (l_debug = 1) THEN
        debug_print('Partial match. Only Rev : ' || l_rsv_index);
     END IF;

     -- Loop through the full rsv table to check for records not matching with the SKU at all
     -- These would be the high/org level reservations
     -- If found, put the matching row into a different variable
     IF l_mtl_reservation.Count > 0 THEN
	   FOR i IN l_mtl_reservation.first..l_mtl_reservation.last
	   LOOP
		   IF l_mtl_reservation(i).revision          IS NULL AND l_mtl_reservation(i).lot_number IS NULL AND
                      l_mtl_reservation(i).subinventory_code IS NULL AND l_mtl_reservation(i).locator_id IS NULL THEN
      		      l_rsv_index := l_rsv_index + 1;
		      x_mtl_reservation(l_rsv_index) := l_mtl_reservation(i);
		      l_mtl_reservation.DELETE(i);
		   END IF;
	   END LOOP;
     END IF;

     IF (l_debug = 1) THEN
        debug_print('No Match. High level reservation : ' || l_rsv_index);
     END IF;

     -- Put the remaining reservations in the same order
     -- The default order is increasing order of detailing
     IF l_mtl_reservation.Count > 0 THEN
	   FOR i IN l_mtl_reservation.first..l_mtl_reservation.last
	   LOOP
   		      l_rsv_index := l_rsv_index + 1;
		      x_mtl_reservation(l_rsv_index) := l_mtl_reservation(i);
		      l_mtl_reservation.DELETE(i);
	   END LOOP;
     END IF;

     IF (l_debug = 1) THEN
        debug_print('No Match. Detailed rsv for other sku : ' || l_rsv_index);
     END IF;

    p_mtl_reservation := x_mtl_reservation;

    IF (l_debug = 1) THEN
        debug_print('Done with reservations sorting. Sorted reservation count: ' || l_mtl_reservation.Count);
    END IF;

    x_return_status   := l_return_status;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      IF (l_debug = 1) THEN
        debug_print('Error occurred in Sort Reservation : ' || x_return_status);
      END IF;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
        debug_print('Exception occurred in Sort Reservation : ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
        debug_print('Exception occurred in Sort Reservation : ' || x_return_status);
      END IF;

 END Sort_Reservation;

 --
  -- Procedure
  --   Get_atr
  -- Description
  --   Used to get the atr for the sku passed in rsv rec

  PROCEDURE Get_atr
  ( p_rsv_rec            IN          inv_reservation_global.mtl_reservation_rec_type ,
    x_atr                OUT NOCOPY  NUMBER   ,
    x_return_status      OUT NOCOPY  VARCHAR2 ,
    x_msg_count          OUT NOCOPY  NUMBER   ,
    x_msg_data           OUT NOCOPY  VARCHAR2
  )
  IS
    l_mtl_reservation inv_reservation_global.mtl_reservation_tbl_type;
    x_mtl_reservation inv_reservation_global.mtl_reservation_tbl_type;
    l_rsv_index         NUMBER      := 0;
    l_return_status     VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_debug             NUMBER;
    l_rev_control       BOOLEAN;
    l_lot_control       BOOLEAN;
    l_ser_control       BOOLEAN;
    l_tree_id           INTEGER;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(240);
    l_qoh               NUMBER;
    l_rqoh              NUMBER;
    l_qr                NUMBER;
    l_qs                NUMBER;
    l_att               NUMBER;
    l_atr               NUMBER;
    l_sqoh              NUMBER;
    l_srqoh             NUMBER;
    l_sqr               NUMBER;
    l_sqs               NUMBER;
    l_satt              NUMBER;
    l_satr              NUMBER;

  BEGIN
      l_debug := g_debug;

      IF (l_debug = 1) THEN
	  debug_print('Inside Get atr ');
      END IF;

      IF INV_CACHE.item_rec.revision_qty_control_code =  inv_reservation_global.g_revision_control_yes THEN
        l_rev_control := TRUE;
      ELSE
        l_rev_control := FALSE;
      END IF;

      IF INV_CACHE.item_rec.lot_control_code = inv_reservation_global.g_lot_control_yes THEN
        l_lot_control := TRUE;
      ELSE
        l_lot_control := FALSE;
      END IF;

      IF INV_CACHE.item_rec.serial_number_control_code  <> inv_reservation_global.g_serial_control_predefined THEN
        l_ser_control := TRUE;
      ELSE
        l_ser_control := FALSE;
      END IF;

      IF (l_debug = 1) THEN
	  debug_print('Creating tree to get the atr for the given sku ');
      END IF;

	   inv_quantity_tree_pvt.create_tree (
	   p_api_version_number         => 1.0
	 , p_init_msg_lst               => fnd_api.g_true
	 , x_return_status              => l_return_status
	 , x_msg_count                  => x_msg_count
	 , x_msg_data                   => x_msg_data
	 , p_organization_id            => p_rsv_rec.organization_id
	 , p_inventory_item_id          => p_rsv_rec.inventory_item_id
	 , p_tree_mode                  => inv_quantity_tree_pvt.g_reservation_mode
	 , p_is_revision_control        => l_rev_control
	 , p_is_lot_control             => l_lot_control
	 , p_is_serial_control          => l_ser_control
	 , p_asset_sub_only             => FALSE
	 , p_include_suggestion         => TRUE
	 , p_demand_source_type_id      => p_rsv_rec.demand_source_type_id
	 , p_demand_source_header_id    => p_rsv_rec.demand_source_header_id
	 , p_demand_source_line_id      => p_rsv_rec.demand_source_line_id
	 , p_demand_source_name         => p_rsv_rec.demand_source_name
	 , p_demand_source_delivery     => p_rsv_rec.demand_source_delivery
	 , p_lot_expiration_date        => SYSDATE
	 , x_tree_id                    => l_tree_id
	);

	    IF (l_debug = 1) THEN
		    debug_print('After create tree in process reservations ' || l_return_status || ' Tree Id: ' || l_tree_id);
	    END IF;

	    IF l_return_status = fnd_api.g_ret_sts_error THEN
		    RAISE fnd_api.g_exc_error;
	    END IF;

	    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		    RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	     inv_quantity_tree_pvt.query_tree(
	      p_api_version_number         => 1.0
	    , p_init_msg_lst               => fnd_api.g_true
	    , x_return_status              => l_return_status
	    , x_msg_count                  => l_msg_count
	    , x_msg_data                   => l_msg_data
	    , p_tree_id                    => l_tree_id
	    , p_revision                   => p_rsv_rec.revision
	    , p_lot_number                 => p_rsv_rec.lot_number
	    , p_subinventory_code          => p_rsv_rec.subinventory_code
	    , p_locator_id                 => p_rsv_rec.locator_id
	    , x_qoh                        => l_qoh
	    , x_rqoh                       => l_rqoh
	    , x_qr                         => l_qr
	    , x_qs                         => l_qs
	    , x_att                        => l_att
	    , x_atr                        => l_atr
	    , x_sqoh                       => l_sqoh
	    , x_srqoh                      => l_srqoh
	    , x_sqr                        => l_sqr
	    , x_sqs                        => l_sqs
	    , x_satt                       => l_satt
	    , x_satr                       => l_satr
	    , p_lpn_id                     => p_rsv_rec.lpn_id
	    );

	    IF (l_debug = 1) THEN
		    debug_print('After query tree in process reservations ' || l_return_status);
	    END IF;


	    IF l_return_status = fnd_api.g_ret_sts_error THEN
	      RAISE fnd_api.g_exc_error;
	    END IF;

	    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	    IF (l_debug = 1) THEN
	      debug_print('l_atr '  || l_atr);
	      debug_print('l_att '  || l_att);
	      debug_print('l_qoh '  || l_qoh);
	      debug_print('l_rqoh ' || l_rqoh);
	      debug_print('l_qr '   || l_qr);
	      debug_print('l_qs '   || l_qs);
	      debug_print('l_satr ' || l_satr);
	      debug_print('l_satt ' || l_satt);
	      debug_print('l_sqoh ' || l_sqoh);
	      debug_print('l_srqoh '|| l_srqoh);
	      debug_print('l_sqr '  || l_sqr);
	      debug_print('l_sqs '  || l_sqs);
	    END IF;

    x_atr := l_atr;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      IF (l_debug = 1) THEN
        debug_print('Error occurred in Get atr : ' || x_return_status);
      END IF;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
        debug_print('Exception occurred in Get atr : ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
        debug_print('Exception occurred in Get atr : ' || x_return_status);
      END IF;
  END Get_atr;


-- Procedure
--   process_reservation
--
-- Description
--   This api will detail and stage an org level or detailed reservation
--
-- Input Paramters
--   p_api_version_number       API version number (current version is 1.0)
--
--   p_init_msg_lst             Whether initialize the error message list or
--                              not.
--                              Should be fnd_api.g_false or fnd_api.g_true
--
--   p_rsv_rec                  Contains info to be used to process the
--                              reservation
--
--   p_serial_number            Contains serial numbers to be staged
--
--   p_rsv_status               'DETAIL' or 'STAGE'
--				IF DETAIL then the reservation would be detailed
--                              to the sku passed
--                              IF STAGE then the reservation would be
--                              detailed and then staged
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if
--                              an unexpected error occurred
--
--   x_msg_count                Number of error message in the error message
--                              list
--
--   x_msg_data                 If the number of error message in the error
--                              message list is one, the error message
--                              is in this output parameter
--

  PROCEDURE Process_Reservation
  ( p_api_version_number IN  NUMBER ,
    p_init_msg_lst       IN  VARCHAR2 DEFAULT fnd_api.g_false ,
    p_rsv_rec            IN  inv_reservation_global.mtl_reservation_rec_type ,
    p_serial_number      IN  inv_reservation_global.serial_number_tbl_type ,
    p_rsv_status         IN  VARCHAR2,
    x_return_status      OUT NOCOPY  VARCHAR2 ,
    x_msg_count          OUT NOCOPY  NUMBER   ,
    x_msg_data           OUT NOCOPY  VARCHAR2
  )
 IS

 l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_msg_count     NUMBER;
 l_msg_data      VARCHAR2(2000);
 l_query_input                inv_reservation_global.mtl_reservation_rec_type;
 l_query_det_rsv              inv_reservation_global.mtl_reservation_rec_type;
 l_to_rsv_record              inv_reservation_global.mtl_reservation_rec_type;
 l_original_rsv_record        inv_reservation_global.mtl_reservation_rec_type;
 l_rsv_rec                    inv_reservation_global.mtl_reservation_rec_type;
 l_rsv_rec1                   inv_reservation_global.mtl_reservation_rec_type;
 l_create_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
 l_mtl_reservation_staged     inv_reservation_global.mtl_reservation_rec_type;
 l_mtl_reservation_det_qty    inv_reservation_global.mtl_reservation_rec_type;
 l_mtl_reservation            inv_reservation_global.mtl_reservation_tbl_type;
 l_mtl_reservation_non_staged inv_reservation_global.mtl_reservation_tbl_type;
 l_mtl_reservation_detailed   inv_reservation_global.mtl_reservation_tbl_type;
 l_dummy_sn                   inv_reservation_global.serial_number_tbl_type;
 l_serial_number              inv_reservation_global.serial_number_tbl_type;
 l_serial_number1             inv_reservation_global.serial_number_tbl_type;
 l_mtl_rsv_non_staged_count   NUMBER := 0;
 l_mtl_rsv_detailed_count     NUMBER := 0;
 l_mtl_reservation_count      NUMBER := 0;
 l_error_code                 NUMBER;
 l_primary_reservation_qty    NUMBER := 0;
 l_secondary_reservation_qty  NUMBER := 0;
 l_remaining_reservation_qty  NUMBER := 0;
 l_new_rsv_quantity           NUMBER := 0;
 l_new_prim_rsv_quantity      NUMBER := 0;
 l_staged_flag                VARCHAR2(1);
 l_return_value               BOOLEAN;
 l_det_res_id                 NUMBER;
 l_det_res_qty                NUMBER;
 l_primary_uom                VARCHAR2(3);
 l_secondary_uom              VARCHAR2(3);
 l_revision_control_code      NUMBER;
 l_lot_control_code           NUMBER;
 l_serial_number_control_code NUMBER;
 l_rsv_index                  NUMBER := 0;
 l_debug                      NUMBER;
 --l_sub_reservable_type        NUMBER := 1;
 --l_loc_reservable_type       NUMBER := 1;
 --l_lot_reservable_type        NUMBER := 1;
 l_msnt_seq                   NUMBER := 0;
 l_default_org_status_id      NUMBER ;
 l_reservation_allowed        NUMBER ;
 l_atr                        INTEGER ;

 BEGIN

 SAVEPOINT process_reservation_ds;

    IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('Inside Process_Reservations');
    END IF;

    IF (l_debug = 1) THEN
        debug_print('Printing the input reservation record passed');
    END IF;

    --Assign the input record to a local variable for modifications
    l_rsv_rec := p_rsv_rec;
    l_rsv_rec1 := p_rsv_rec;
    l_serial_number := p_serial_number;

    --Print the input reservation record passed
    inv_reservation_pvt.print_rsv_rec( p_rsv_rec => l_rsv_rec);

    IF (l_debug = 1) THEN
        debug_print('Converting all the missing fields in the input reservation record to NULL');
    END IF;
    --Convert all the missing fileds in the input rsv record to NULL
    inv_reservation_pvt.convert_missing_to_null ( p_rsv_rec => l_rsv_rec1, x_rsv_rec => l_rsv_rec);
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF (l_debug = 1) THEN
              debug_print(' return error from inv_reservation_pvt.convert_missing_to_null '||l_return_status);
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

   --Print the input reservation record passed
    inv_reservation_pvt.print_rsv_rec( p_rsv_rec => l_rsv_rec);

    IF (l_debug = 1) THEN
        debug_print('Handling prim, sec, rsv uom and qty');
    END IF;
    --Handle uom conversion
      inv_reservation_pvt.convert_quantity( x_return_status => l_return_status, px_rsv_rec => l_rsv_rec);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF (l_debug = 1) THEN
                debug_print(' return error from inv_reservation_pvt.convert_quantity '||l_return_status);
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Query reservations only on the basis of demand source line id from the input.
    --This will fetch all reservation records for the respective demand source line
    --which is processed later
    l_query_input.demand_source_line_id   := l_rsv_rec.demand_source_line_id;
    l_query_input.demand_source_header_id := l_rsv_rec.demand_source_header_id;
    l_query_input.inventory_item_Id       := l_rsv_rec.inventory_item_Id;
    l_query_input.organization_id         := l_rsv_rec.organization_id;
    l_query_input.supply_source_type_id   := inv_reservation_global.g_source_type_inv;
    l_query_input.demand_source_type_id   := l_rsv_rec.demand_source_type_id;


    IF (l_debug = 1) THEN
          debug_print('Demand Source line id :'          || l_rsv_rec.demand_source_line_id);
          debug_print('Reservation Status passed is  : ' || p_rsv_status);
    END IF;

    --l_query_input.ship_ready_flag := NULL;
    --l_query_input.staged_flag := NULL;

        inv_reservation_pub.query_reservation(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_query_input                => l_query_input
        , x_mtl_reservation_tbl        => l_mtl_reservation
        , x_mtl_reservation_tbl_count  => l_mtl_reservation_count
        , x_error_code                 => l_error_code
        );

         -- Return an error if the query reservations call failed
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
             IF (l_debug = 1) THEN
                debug_print(' return error from query reservation: '||l_return_status);
             END IF;
             fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF l_mtl_reservation_count > 0  THEN
              --Calculate the total primary reservation qty by summing up all the
              --non staged reservations for the demand source line
              --save all the non staged rsv records in a different variable
              FOR i IN l_mtl_reservation.first..l_mtl_reservation.last
                LOOP
                      l_staged_flag := l_mtl_reservation(i).staged_flag;
                      IF NVL(l_staged_flag, 'N') = 'N' THEN
                        l_rsv_index := l_rsv_index + 1;
                        l_mtl_reservation_non_staged(l_rsv_index) := l_mtl_reservation(i);
                        l_primary_reservation_qty    := l_primary_reservation_qty   +  l_mtl_reservation(i).primary_reservation_quantity;
                        l_secondary_reservation_qty  := l_secondary_reservation_qty +  l_mtl_reservation(i).secondary_reservation_quantity;
                      END IF;
              END LOOP;

              l_mtl_rsv_non_staged_count := l_mtl_reservation_non_staged.Count;

              IF (l_debug = 1) THEN
                    debug_print('No. of unstaged reservations : '|| l_mtl_rsv_non_staged_count);
                    debug_print('Primary reservation qty : '     || l_primary_reservation_qty);
                    debug_print('Secondary reservation qty : '   || l_secondary_reservation_qty);
                END IF;

         ELSE
              IF (l_debug = 1) THEN
                  debug_print('No reservations exists for the demand source line : '|| l_rsv_rec.demand_source_line_id);
                  debug_print('Return without processing any reservations');
              END IF;
            x_return_status := fnd_api.g_ret_sts_success;
            RETURN;
         END IF;

       IF l_mtl_rsv_non_staged_count <= 0 THEN
            IF (l_debug = 1) THEN
                  debug_print('No Unstaged reservations exists for the demand source line : '|| l_rsv_rec.demand_source_line_id);
                  debug_print('Return without processing any reservations');
              END IF;
            x_return_status := fnd_api.g_ret_sts_success;
            RETURN;
        END IF;

        -- set the item cache
        l_return_value := INV_CACHE.set_item_rec (l_rsv_rec.organization_id, l_rsv_rec.inventory_item_id);
        If NOT l_return_value THEN
            IF (l_debug = 1) THEN
                 debug_print('Exception occurred while setting the item cache');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
        End If;

        l_primary_uom                  := INV_CACHE.item_rec.primary_uom_code;
        l_secondary_uom                := INV_CACHE.item_rec.secondary_uom_code;
        l_revision_control_code        := INV_CACHE.item_rec.revision_qty_control_code;
        l_lot_control_code             := INV_CACHE.item_rec.lot_control_code;
        l_serial_number_control_code   := INV_CACHE.item_rec.serial_number_control_code;

        IF (l_debug = 1) THEN
             debug_print('Printing values from the item cache');
             debug_print('l_primary_uom                 : '|| l_primary_uom);
             debug_print('l_secondary_uom               : '|| l_secondary_uom);
             debug_print('l_revision_control_code       : '|| l_revision_control_code);
             debug_print('l_lot_control_code            : '|| l_lot_control_code);
             debug_print('l_serial_number_control_code  : '|| l_serial_number_control_code);
        END IF;

        -- set the rev passed as null if item is not rev controlled
        IF  Nvl(l_revision_control_code, 1) = 1 THEN
            l_rsv_rec.revision := NULL;
        END IF;

        -- set the lot passed as null if item is not lot controlled
        IF  l_lot_control_code = 1 THEN
            l_rsv_rec.lot_number := NULL;
        END IF;

        -- set the serial passed as null if item is not serial controlled
        IF  l_serial_number_control_code = 1 THEN
            l_serial_number := l_dummy_sn;
        END IF;

        --sort reservations only if the non staged reservations count
        --is more than 1
        IF l_mtl_rsv_non_staged_count > 1 THEN

            -- Reservation table needs to be sorted as per the order
            -- mentioned in sort_reservation helper procedure
            inv_rsv_detail_stage_pvt.Sort_Reservation (
            p_mtl_reservation => l_mtl_reservation_non_staged,
            p_rsv_rec         => l_rsv_rec,
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data
            );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
                IF (l_debug = 1) THEN
                    debug_print(' return error from sort reservation: '||l_return_status);
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

        END IF;

        -- Call to check whether reservations are allowed or not allowed
        -- This checks whether the input sku is reservable or not
          l_reservation_allowed := is_reservation_allowed (l_rsv_rec);

        IF  (l_debug = 1) THEN
            IF l_reservation_allowed = 1 THEN
               debug_print('Reservations are allowed');
            ELSE
               debug_print('Reservations are not allowed');
            END IF;
        END IF;

        -- If p_rsv_status is passed as DETAIL then detail the reservation with the SKU passed
        -- If p_rsv_status is passed as STAGE then detail as well as stage the reservation with the SKU passed
        -- If the prim rsv qty passed is >= total prim reserved qty then delete all the non staged reservations
        -- against the demand source line and create a new detailed reservation with the new prim rsv qty and sku
        -- If the prim rsv qty passed is < total prim reserved qty then we will have to split the reservations
        -- Splitting of reservations is done in 2 steps
        -- For example, we have 2 reservations (r1, r2) records against a demand source line with qty 6 and 4 resp
        -- So total prim  rsv qty = 10 and qty to be detailed or staged is 5
        -- reduce 5 from r1 (update r1 to 1) and create a new detailed rsv with 5 qty and sku passed
        -- or delete r2 with 4 qty, reduce r1 by 4 qty and create a new detailed rsv with 5 qty and sku passed

      IF p_rsv_status IN ('DETAIL','STAGE') THEN

                IF (l_debug = 1) THEN
                  debug_print('l_rsv_rec.primary_reservation_quantity : '||l_rsv_rec.primary_reservation_quantity);
                  debug_print('l_primary_reservation_qty : '||l_primary_reservation_qty);
                END IF;

            IF l_rsv_rec.primary_reservation_quantity >=  l_primary_reservation_qty THEN
                    IF (l_debug = 1) THEN
                      debug_print('l_rsv_rec.primary_reservation_quantity >=  l_primary_reservation_qty ');
                    END IF;

                FOR i IN l_mtl_reservation_non_staged.first..l_mtl_reservation_non_staged.last
                  LOOP
                        IF (l_debug = 1) THEN
                            debug_print('Deleting reservation - reservation id :'||l_mtl_reservation_non_staged(i).reservation_id);
                        END IF;

                          inv_reservation_pub.delete_reservation
                        ( p_api_version_number => 1.0
                        , p_init_msg_lst       => fnd_api.g_false
                        , x_return_status      => l_return_status
                        , x_msg_count          => l_msg_count
                        , x_msg_data           => l_msg_data
                        , p_rsv_rec            => l_mtl_reservation_non_staged(i)
                        , p_serial_number      => l_dummy_sn
                        );

                        -- Return an error if the delete reservations call failed
                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          IF (l_debug = 1) THEN
                            debug_print(' return error from delete reservation: '||l_return_status);
                          END IF;
                          RAISE fnd_api.g_exc_unexpected_error;
                      END IF;
                  END LOOP;

              ELSE -- l_rsv_rec.reservation_quantity <  l_primary_reservation_qty
                      IF (l_debug = 1) THEN
                          debug_print('l_rsv_rec.primary_reservation_quantity <  l_primary_reservation_qty ');
                          debug_print('l_remaining_reservation_qty :' || l_remaining_reservation_qty);
                      END IF;

                l_remaining_reservation_qty :=  l_rsv_rec.primary_reservation_quantity;

                FOR i IN l_mtl_reservation_non_staged.first..l_mtl_reservation_non_staged.last
                LOOP

                      IF (l_debug = 1) THEN
                          debug_print('l_mtl_reservation_non_staged(i).primary_reservation_quantity :'
                                      || l_mtl_reservation_non_staged(i).primary_reservation_quantity);
                          debug_print('l_remaining_reservation_qty :' || l_remaining_reservation_qty);
                      END IF;

                  IF  l_remaining_reservation_qty >= l_mtl_reservation_non_staged(i).primary_reservation_quantity THEN
                        IF (l_debug = 1) THEN
                          debug_print('l_remaining_reservation_qty >= l_mtl_reservation_non_staged(i).primary_reservation_quantity');
                          debug_print('Deleting reservation - reservation id :' || l_mtl_reservation_non_staged(i).reservation_id);
                        END IF;

                          inv_reservation_pub.delete_reservation
                        ( p_api_version_number => 1.0
                        , p_init_msg_lst       => fnd_api.g_false
                        , x_return_status      => l_return_status
                        , x_msg_count          => l_msg_count
                        , x_msg_data           => l_msg_data
                        , p_rsv_rec            => l_mtl_reservation_non_staged(i)
                        , p_serial_number      => l_dummy_sn
                        );

                        -- Return an error if the delete reservations call failed
                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          IF (l_debug = 1) THEN
                            debug_print(' return error from delete reservation: '||l_return_status);
                          END IF;
                          RAISE fnd_api.g_exc_unexpected_error;
                      END IF;


                  ELSE --IF l_remaining_reservation_qty < l_mtl_reservation(i).reservation_quantity

                      IF (l_debug = 1) THEN
                          debug_print('l_remaining_reservation_qty < l_mtl_reservation(i).reservation_quantity');
                      END IF;

                      l_new_prim_rsv_quantity := l_mtl_reservation_non_staged(i).primary_reservation_quantity   - l_remaining_reservation_qty;
                    --l_new_sec_rsv_quantity  := l_mtl_reservation_non_staged(i).secondary_reservation_quantity - l_remaining_reservation_qty2;

                      l_original_rsv_record                         := l_mtl_reservation_non_staged(i);
                      l_to_rsv_record                               := l_mtl_reservation_non_staged(i);
                      l_to_rsv_record.primary_reservation_quantity  := l_new_prim_rsv_quantity;
                      --l_to_rsv_record.reservation_quantity          := l_new_rsv_quantity;
                      --l_to_rsv_record.secondary_reservation_quantity := l_new_sec_rsv_quantity;

                      IF (l_debug = 1) THEN
                        debug_print('Handling rsv qty and sec rsv qty for the reservation record which is to be updated');
                      END IF;

                      inv_reservation_pvt.convert_quantity( x_return_status => l_return_status, px_rsv_rec => l_to_rsv_record);
                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          IF (l_debug = 1) THEN
                              debug_print(' return error from inv_reservation_pvt.convert_quantity '||l_return_status);
                          END IF;
                          RAISE fnd_api.g_exc_unexpected_error;
                      END IF;


                        IF (l_debug = 1) THEN
                            debug_print('Update reservation - reservation id : ' || l_mtl_reservation_non_staged(i).reservation_id);
                            debug_print('Old primary Qty : ' || l_original_rsv_record.primary_reservation_quantity);
                            debug_print('New primary Qty : ' || l_to_rsv_record.primary_reservation_quantity);
                            debug_print('Updating reservation');
                        END IF;

                      -- This update will always reduce the primary qty.
                      -- Unmarking of the serial in case of serial controlled items is handled by the api
                      inv_reservation_pub.update_reservation(
                            p_api_version_number         => 1.0
                          , p_init_msg_lst               => fnd_api.g_false
                          , x_return_status              => l_return_status
                          , x_msg_count                  => l_msg_count
                          , x_msg_data                   => l_msg_data
                          , p_original_rsv_rec           => l_original_rsv_record
                          , p_to_rsv_rec                 => l_to_rsv_record
                          , p_original_serial_number     => l_dummy_sn
                          , p_to_serial_number           => l_dummy_sn
                          , p_validation_flag            => fnd_api.g_true
                          , p_over_reservation_flag      => 2
                      );

                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          IF (l_debug = 1) THEN
                              debug_print('return error from update reservation: '||l_return_status);
                          END IF;
                          fnd_message.set_name('INV', 'INV_UPD_RSV_FAILED');
                          fnd_msg_pub.ADD;
                          RAISE fnd_api.g_exc_unexpected_error;
                        END IF;
                END IF; --IF l_remaining_reservation_qty >= l_mtl_reservation_non_staged(i).reservation_quantity

                l_remaining_reservation_qty  := l_remaining_reservation_qty  - l_mtl_reservation_non_staged(i).primary_reservation_quantity;
              --l_remaining_reservation_qty2 := l_remaining_reservation_qty2 - l_mtl_reservation_non_staged(i).secondary_reservation_quantity;

                    IF (l_debug = 1) THEN
                        debug_print('l_remaining_reservation_qty :'||l_remaining_reservation_qty);
                    END IF;
                EXIT WHEN  l_remaining_reservation_qty <= 0 ;
                END LOOP;

            END IF; --IF l_rsv_rec.reservation_quantity >=  l_primary_reservation_qty

         -- Check the atr for the sku passed for detailing/staging the reservation
              inv_rsv_detail_stage_pvt.Get_atr(
                p_rsv_rec         => l_rsv_rec
              , x_atr             => l_atr
              , x_return_status   => l_return_status
              , x_msg_count       => l_msg_count
              , x_msg_data        => l_msg_data
              );

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                IF (l_debug = 1) THEN
                    debug_print(' return error from inv_rsv_detail_stage_pvt.Get_atr '||l_return_status);
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              ELSE
                 IF (l_debug = 1) THEN
                    debug_print(' Atr for the given sku is : '||l_atr);
                END IF;
              END IF;


        -- Create a new detailed reservation in any case : over picking / split reservation scenarios
        -- Detailed/ Staged level reservations will not be created if Subinventory or Locator or Lot is non reservable
        -- or atr for the given sku is <= 0

                IF l_reservation_allowed = 1 AND l_atr > 0 THEN
                            l_create_rsv_rec.reservation_id                 :=  NULL;
                            l_create_rsv_rec.requirement_date               :=  Nvl(l_rsv_rec.requirement_date, SYSDATE);
                            l_create_rsv_rec.organization_id                :=  l_rsv_rec.organization_id;
                            l_create_rsv_rec.inventory_item_id              :=  l_rsv_rec.inventory_item_id;
                            l_create_rsv_rec.demand_source_type_id          :=  l_rsv_rec.demand_source_type_id;
                            l_create_rsv_rec.demand_source_name             :=  l_rsv_rec.demand_source_name;
                            l_create_rsv_rec.demand_source_header_id        :=  l_rsv_rec.demand_source_header_id;
                            l_create_rsv_rec.demand_source_line_id          :=  l_rsv_rec.demand_source_line_id;
                            l_create_rsv_rec.demand_source_delivery         :=  NULL;
                            l_create_rsv_rec.primary_uom_code               :=  l_rsv_rec.primary_uom_code;
                            l_create_rsv_rec.secondary_uom_code             :=  l_rsv_rec.secondary_uom_code;
                            l_create_rsv_rec.primary_uom_id                 :=  NULL;
                            l_create_rsv_rec.secondary_uom_id               :=  NULL;
                            l_create_rsv_rec.reservation_uom_code           :=  l_rsv_rec.reservation_uom_code;
                            l_create_rsv_rec.reservation_uom_id             :=  NULL;
                            l_create_rsv_rec.reservation_quantity           :=  l_rsv_rec.reservation_quantity;
                            l_create_rsv_rec.primary_reservation_quantity   :=  l_rsv_rec.primary_reservation_quantity;
                            l_create_rsv_rec.secondary_reservation_quantity :=  l_rsv_rec.secondary_reservation_quantity;
                            l_create_rsv_rec.autodetail_group_id            :=  NULL;
                            l_create_rsv_rec.external_source_code           :=  NULL;
                            l_create_rsv_rec.external_source_line_id        :=  NULL;
                            l_create_rsv_rec.supply_source_type_id          :=  inv_reservation_global.g_source_type_inv;
                            l_create_rsv_rec.supply_source_header_id        :=  NULL;
                            l_create_rsv_rec.supply_source_line_id          :=  NULL;
                            l_create_rsv_rec.supply_source_name             :=  NULL;
                            l_create_rsv_rec.supply_source_line_detail      :=  NULL;
                            l_create_rsv_rec.revision                       :=  l_rsv_rec.revision;
                            l_create_rsv_rec.subinventory_code              :=  l_rsv_rec.subinventory_code;
                            l_create_rsv_rec.subinventory_id                :=  NULL;
                            l_create_rsv_rec.locator_id                     :=  l_rsv_rec.locator_id ;
                            l_create_rsv_rec.lot_number                     :=  l_rsv_rec.lot_number;
                            l_create_rsv_rec.lpn_id                         :=  l_rsv_rec.lpn_id;
                            l_create_rsv_rec.lot_number_id                  :=  NULL;
                            l_create_rsv_rec.pick_slip_number               :=  NULL;
                            l_create_rsv_rec.attribute_category             :=  NULL;
                            l_create_rsv_rec.attribute1                     :=  NULL;
                            l_create_rsv_rec.attribute2                     :=  NULL;
                            l_create_rsv_rec.attribute3                     :=  NULL;
                            l_create_rsv_rec.attribute4                     :=  NULL;
                            l_create_rsv_rec.attribute5                     :=  NULL;
                            l_create_rsv_rec.attribute6                     :=  NULL;
                            l_create_rsv_rec.attribute7                     :=  NULL;
                            l_create_rsv_rec.attribute8                     :=  NULL;
                            l_create_rsv_rec.attribute9                     :=  NULL;
                            l_create_rsv_rec.attribute10                    :=  NULL;
                            l_create_rsv_rec.attribute11                    :=  NULL;
                            l_create_rsv_rec.attribute12                    :=  NULL;
                            l_create_rsv_rec.attribute13                    :=  NULL;
                            l_create_rsv_rec.attribute14                    :=  NULL;
                            l_create_rsv_rec.attribute15                    :=  NULL;
                            l_create_rsv_rec.ship_ready_flag                :=  NULL;
                            l_create_rsv_rec.staged_flag                    :=  NULL;
                            l_create_rsv_rec.detailed_quantity              :=  NULL; --l_rsv_rec.primary_reservation_quantity;
                            l_create_rsv_rec.secondary_detailed_quantity    :=  NULL; --l_rsv_rec.secondary_reservation_quantity;

                            IF (l_debug = 1) THEN
                                debug_print('Calling create resrevation for creating the detailed reservation ');
                            END IF;

                            inv_reservation_pub.create_reservation(
                              p_api_version_number         => 1.0
                            , p_init_msg_lst               => fnd_api.g_false
                            , x_return_status              => l_return_status
                            , x_msg_count                  => l_msg_count
                            , x_msg_data                   => l_msg_data
                            , p_rsv_rec                    => l_create_rsv_rec
                            , p_serial_number              => l_serial_number
                            , x_serial_number              => l_serial_number1
                            , p_partial_reservation_flag   => fnd_api.g_true
                            , p_force_reservation_flag     => fnd_api.g_false
                            , p_validation_flag            => fnd_api.g_true
                            , x_quantity_reserved          => l_det_res_qty
                            , x_reservation_id             => l_det_res_id
                            , p_over_reservation_flag      => 2
                            );

                            -- Return an error if the query reservation call failed
                            IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                IF (l_debug = 1) THEN
                                  debug_print('return error from query reservation: '||l_return_status);
                                END IF;
                                fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
                                fnd_msg_pub.ADD;
                                RAISE fnd_api.g_exc_unexpected_error;
                            END IF;

                            IF (l_debug = 1) THEN
                                debug_print('Detailed reservation created. Reservation Id : ' || l_det_res_id || ' and qty :' || l_det_res_qty);
                            END IF;

                            l_query_det_rsv.reservation_id := l_det_res_id;

                            IF (l_debug = 1) THEN
                                debug_print('Querying reservation before updating the detailed qty  ');
                            END IF;
                            -- Query for the one reservation created for updating the det qty
                            inv_reservation_pub.query_reservation(
                            p_api_version_number         => 1.0
                          , p_init_msg_lst               => fnd_api.g_true
                          , x_return_status              => l_return_status
                          , x_msg_count                  => l_msg_count
                          , x_msg_data                   => l_msg_data
                          , p_query_input                => l_query_det_rsv
                          , x_mtl_reservation_tbl        => l_mtl_reservation_detailed
                          , x_mtl_reservation_tbl_count  => l_mtl_rsv_detailed_count
                          , x_error_code                 => l_error_code
                          );

                          -- Return an error if the query reservations call failed
                          IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              IF (l_debug = 1) THEN
                                  debug_print(' return error from query reservation: '||l_return_status);
                              END IF;
                              fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_unexpected_error;
                          END IF;

                          l_mtl_reservation_det_qty                             := l_mtl_reservation_detailed(1) ;
                          l_mtl_reservation_det_qty.detailed_quantity           := l_det_res_qty; --l_rsv_rec.primary_reservation_quantity;
                          l_mtl_reservation_det_qty.secondary_detailed_quantity := NULL; --l_rsv_rec.secondary_reservation_quantity;

                          IF (l_debug = 1) THEN
                              debug_print('Updating the detailed qty and sec detailed qty fields ');
                          END IF;

                          --This update is meant only to update the det qty and sec det qty
                          inv_reservation_pub.update_reservation(
                                p_api_version_number         => 1.0
                              , p_init_msg_lst               => fnd_api.g_false
                              , x_return_status              => l_return_status
                              , x_msg_count                  => l_msg_count
                              , x_msg_data                   => l_msg_data
                              , p_original_rsv_rec           => l_mtl_reservation_detailed(1)
                              , p_to_rsv_rec                 => l_mtl_reservation_det_qty
                              , p_original_serial_number     => l_dummy_sn
                              , p_to_serial_number           => l_dummy_sn
                              , p_validation_flag            => fnd_api.g_true
                              , p_over_reservation_flag      => 2
                          );

                          IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              IF (l_debug = 1) THEN
                                  debug_print('return error from update reservation: '||l_return_status);
                              END IF;
                              fnd_message.set_name('INV', 'INV_UPD_RSV_FAILED');
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_unexpected_error;
                        END IF;

                        IF (l_debug = 1) THEN
                             debug_print('Reservation successfully detailed ');
                        END IF;

                END IF; -- IF l_reservation_allowed = 1 AND l_atr > 0

      END IF; -- detail,stage

      --If rsv status is 'STAGE' then detail the reservation to the sku passed and then stage it
      IF p_rsv_status = 'STAGE' THEN

            IF (l_debug = 1) THEN
                  debug_print('Staging the detailed reservation created');
            END IF;

            -- l_det_res_id would be null for non reservable sub, lot or loc
            -- and for cases wherein the atr is <= 0
            IF l_det_res_id IS NOT NULL THEN
                  l_query_det_rsv.reservation_id := l_det_res_id;

                  IF (l_debug = 1) THEN
                       debug_print('Querying reservation before staging  ');
                  END IF;
                  -- Query for the one detailed reservation created
                  inv_reservation_pub.query_reservation(
                  p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_true
                , x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , p_query_input                => l_query_det_rsv
                , x_mtl_reservation_tbl        => l_mtl_reservation_detailed
                , x_mtl_reservation_tbl_count  => l_mtl_rsv_detailed_count
                , x_error_code                 => l_error_code
                );

                -- Return an error if the query reservations call failed
                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    IF (l_debug = 1) THEN
                        debug_print(' return error from query reservation: '||l_return_status);
                    END IF;
                    fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                l_mtl_reservation_staged := l_mtl_reservation_detailed(1) ;
                l_mtl_reservation_staged.staged_flag := 'Y';
                l_mtl_reservation_staged.ship_ready_flag := 1;
                l_mtl_reservation_staged.detailed_quantity := 0;
                l_mtl_reservation_staged.secondary_detailed_quantity := 0;

                IF (l_debug = 1) THEN
                     debug_print('Updating the staging fields ');
                END IF;

                inv_reservation_pub.update_reservation(
                      p_api_version_number         => 1.0
                    , p_init_msg_lst               => fnd_api.g_false
                    , x_return_status              => l_return_status
                    , x_msg_count                  => l_msg_count
                    , x_msg_data                   => l_msg_data
                    , p_original_rsv_rec           => l_mtl_reservation_detailed(1)
                    , p_to_rsv_rec                 => l_mtl_reservation_staged
                    , p_original_serial_number     => l_dummy_sn
                    , p_to_serial_number           => l_dummy_sn
                    , p_validation_flag            => fnd_api.g_true
                    , p_over_reservation_flag      => 2
                );

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    IF (l_debug = 1) THEN
                        debug_print('return error from update reservation: '||l_return_status);
                    END IF;
                    fnd_message.set_name('INV', 'INV_UPD_RSV_FAILED');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

            END IF; --IF l_det_res_id IS NOT NULL THEN

      END IF; --IF p_rsv_status = 'STAGE' THEN

	 x_return_status := l_return_status;

  EXCEPTION

     WHEN fnd_api.g_exc_error THEN
	ROLLBACK TO process_reservation_ds;
	x_return_status  := fnd_api.g_ret_sts_error;
  IF (l_debug = 1) THEN
       debug_print('Error occurred in Process Reservation : '||l_return_status);
  END IF;
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);


     WHEN fnd_api.g_exc_unexpected_error THEN
	ROLLBACK TO process_reservation_ds;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
   IF (l_debug = 1) THEN
       debug_print('Unexpected error occurred in Process Reservation : '||l_return_status);
   END IF;
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN OTHERS THEN
	ROLLBACK TO process_reservation_ds;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
  IF (l_debug = 1) THEN
      debug_print('Unexpected error occurred in Process Reservation : '||l_return_status);
  END IF;
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

 END process_reservation;

END inv_rsv_detail_stage_pvt;

/
