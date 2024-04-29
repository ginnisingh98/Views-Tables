--------------------------------------------------------
--  DDL for Package Body INV_RESERVATION_AVAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RESERVATION_AVAIL_PVT" AS
/* $Header: INVVRVAB.pls 120.12.12010000.17 2013/02/01 06:46:07 brana ship $*/

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_RESERVATION_AVAIL_PVT';
  g_pkg_version CONSTANT VARCHAR2(100) := '$Header: INVVRVAB.pls 120.12.12010000.17 2013/02/01 06:46:07 brana ship $';
  g_debug NUMBER;

  -- procedure to print inventory debug message
  PROCEDURE debug_print(p_message IN VARCHAR2, p_level IN NUMBER := 9) IS
  BEGIN
    inv_log_util.TRACE(p_message, 'INV_RESERVATION_AVAIL_PVT', p_level);
  END debug_print;

  PROCEDURE available_supply_to_reserve
    (
       p_api_version_number        IN  NUMBER DEFAULT 1.0
     , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status             OUT NOCOPY VARCHAR2
     , x_msg_count                 OUT NOCOPY NUMBER
     , x_msg_data                  OUT NOCOPY VARCHAR2
     , p_organization_id           IN  NUMBER DEFAULT NULL
     , p_item_id                   IN  NUMBER DEFAULT NULL
     , p_revision                  IN  VARCHAR2 DEFAULT NULL
     , p_lot_number                IN  VARCHAR2 DEFAULT NULL
     , p_subinventory_code         IN  VARCHAR2 DEFAULT NULL
     , p_locator_id                IN  NUMBER DEFAULT NULL
     , p_lpn_id                    IN  NUMBER DEFAULT fnd_api.g_miss_num
     , p_fm_supply_source_type_id  IN  NUMBER DEFAULT 0
     , p_supply_source_type_id     IN  NUMBER
     , p_supply_source_header_id   IN  NUMBER
     , p_supply_source_line_id     IN  NUMBER
     , p_supply_source_line_detail IN  NUMBER DEFAULT fnd_api.g_miss_num
     , p_project_id                IN  NUMBER DEFAULT NULL
     , p_task_id                   IN  NUMBER DEFAULT NULL
     , x_qty_available_to_reserve  OUT NOCOPY NUMBER
     , x_qty_available             OUT NOCOPY NUMBER
    )  IS
    l_api_version_number CONSTANT NUMBER         := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)   := 'avilable_supply_to_reserve';
    l_return_status               VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_debug                       NUMBER;
    l_wip_entity_type             NUMBER;
    l_wip_job_type                VARCHAR2(15);
    l_available_quantity          NUMBER;
    l_source_uom_code             VARCHAR2(3);
    l_source_primary_uom_code     VARCHAR2(3);
    l_primary_reserved_quantity   NUMBER;
    l_qty_available_to_reserve    NUMBER;
    l_primary_available_qty       NUMBER;
    l_return_txn                  NUMBER := 0;
	l_rti_primary_quantity        NUMBER := 0;  -- 11899495

  BEGIN
    IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('In available_supply_to_reserve');
        debug_print('organization id = ' || p_organization_id);
        debug_print('inventory item id = ' || p_item_id);
        debug_print('revision = ' || p_revision);
        debug_print('lot number = ' || p_lot_number);
        debug_print('subinventory = ' || p_subinventory_code);
        debug_print('locator id = ' || p_locator_id);
        debug_print('supply source type id = ' || p_supply_source_type_id);
        debug_print('supply source header id = ' || p_supply_source_header_id);
        debug_print('supply source line id = ' || p_supply_source_line_id);
        debug_print('supply source line detail = ' || p_supply_source_line_detail);
        debug_print('project id = ' || p_project_id);
        debug_print('task id = ' || p_task_id);
    END IF;

    -- error out if supply source type id is null
    IF (p_supply_source_type_id is null) THEN
        fnd_message.set_name('INV', 'INV_NO_SUPPLY_TYPE');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END IF;

    -- for WIP supply source
    IF (p_supply_source_type_id = inv_reservation_global.g_source_type_wip) THEN

        -- error out if supply source header id is null
        IF (p_supply_source_header_id is null) THEN
            fnd_message.set_name('INV','INV_NO_SUPPLY_INFO');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;

        -- get wip entity type from wip_record_cache
        inv_reservation_util_pvt.get_wip_cache
           (
              x_return_status            => l_return_status
            , p_wip_entity_id            => p_supply_source_header_id
           );

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
        ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            l_wip_entity_type := inv_reservation_global.g_wip_record_cache(p_supply_source_header_id).wip_entity_type;
            l_wip_job_type := inv_reservation_global.g_wip_record_cache(p_supply_source_header_id).wip_entity_job;
        END IF;

        IF (l_debug = 1) THEN
            debug_print('wip entity type = ' || l_wip_entity_type);
        END IF;

        -- call availability API for the WIP entity type to get the quantity
        -- available on the document. This quantity is the quantity ordered
        -- minus the quantity already delivered on that document. It is the
        -- expected supply still remainin to be satisfied against the document
        -- line.
        IF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_discrete) THEN
            -- remove comment later
            IF (l_debug = 1) THEN
                debug_print('calling WIP discrete get_available_supply_demand');
            END IF;

	    IF (p_fm_supply_source_type_id =
		inv_reservation_global.g_source_type_inv) THEN
	        IF (l_debug = 1) THEN
                debug_print('It is a return transaction.');
            END IF;
	    l_return_txn := 1;
	    -- 1 means it is a return txn. we are transferring from inv to
	    -- wip and
	    -- 0 means not a return transaction.
	    END IF;

            WIP_RESERVATIONS_GRP.get_available_supply_demand
	      (
	       x_return_status              => l_return_status
	       , x_msg_count                  => l_msg_count
	       , x_msg_data                   => l_msg_data
	       , x_available_quantity         => l_available_quantity
	       , x_source_uom_code            => l_source_uom_code
	       , x_source_primary_uom_code    => l_source_primary_uom_code
	       , p_organization_id            => p_organization_id
	       , p_item_id                    => p_item_id
	       , p_revision                   => p_revision
	       , p_lot_number                 => p_lot_number
	       , p_subinventory_code          => p_subinventory_code
	       , p_locator_id                 => p_locator_id
	       , p_supply_demand_code         => 1
	       , p_supply_demand_type_id      => p_supply_source_type_id
	       , p_supply_demand_header_id    => p_supply_source_header_id
	       , p_supply_demand_line_id      => p_supply_source_line_id
	       , p_supply_demand_line_detail  => p_supply_source_line_detail
  	       , p_lpn_id                     => p_lpn_id
	       , p_project_id                 => null -- p_project_id
               , p_task_id                    => null -- p_task_id
               , p_api_version_number         => 1.0
               , p_init_msg_lst               => fnd_api.g_false
               , p_return_txn                 => l_return_txn
              );

            IF (l_debug = 1) THEN
                debug_print('return status from get_available_supply_demand = ' || l_return_status);
                debug_print('available quantity = ' || l_available_quantity);
                debug_print('source uom code = ' || l_source_uom_code);
                debug_print('source primary uom code = ' || l_source_primary_uom_code);
            END IF;

            IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                raise fnd_api.g_exc_error;
            ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                raise fnd_api.g_exc_unexpected_error;
            END IF;
        ELSIF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_osfm) THEN
            -- remove comment later
            IF (l_debug = 1) THEN
                debug_print('calling osfm get_available_supply_demand');
            END IF;

            WSM_RESERVATIONS_GRP.get_available_supply_demand
               (
                  x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , x_available_quantity         => l_available_quantity
                , x_source_uom_code            => l_source_uom_code
                , x_source_primary_uom_code    => l_source_primary_uom_code
                , p_organization_id            => p_organization_id
                , p_item_id                    => p_item_id
                , p_revision                   => p_revision
                , p_lot_number                 => p_lot_number
                , p_subinventory_code          => p_subinventory_code
                , p_locator_id                 => p_locator_id
                , p_supply_demand_code         => 1
                , p_supply_demand_type_id      => p_supply_source_type_id
                , p_supply_demand_header_id    => p_supply_source_header_id
                , p_supply_demand_line_id      => p_supply_source_line_id
                , p_supply_demand_line_detail  => p_supply_source_line_detail
                , p_lpn_id                     => p_lpn_id
                , p_project_id                 => null -- p_project_id
                , p_task_id                    => null -- p_task_id
                , p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
              );

            IF (l_debug = 1) THEN
                debug_print('return status from get_available_supply_demand = ' || l_return_status);
                debug_print('available quantity = ' || l_available_quantity);
                debug_print('source uom code = ' || l_source_uom_code);
                debug_print('source primary uom code = ' || l_source_primary_uom_code);
            END IF;

            IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                raise fnd_api.g_exc_error;
            ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                raise fnd_api.g_exc_unexpected_error;
            END IF;
        ELSIF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_fpo OR
                l_wip_entity_type = inv_reservation_global.g_wip_source_type_batch) THEN
           -- remove comment later
           IF (l_debug = 1) THEN
                debug_print('calling fpo get_available_supply_demand');
           END IF;
           GME_API_GRP.get_available_supply_demand
               (
                  x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , x_available_quantity         => l_available_quantity
                , x_source_uom_code            => l_source_uom_code
                , x_source_primary_uom_code    => l_source_primary_uom_code
                , p_organization_id            => p_organization_id
                , p_item_id                    => p_item_id
                , p_revision                   => p_revision
                , p_lot_number                 => p_lot_number
                , p_subinventory_code          => p_subinventory_code
                , p_locator_id                 => p_locator_id
                , p_supply_demand_code         => 1
                , p_supply_demand_type_id      => p_supply_source_type_id
                , p_supply_demand_header_id    => p_supply_source_header_id
                , p_supply_demand_line_id      => p_supply_source_line_id
                , p_supply_demand_line_detail  => p_supply_source_line_detail
                , p_lpn_id                     => p_lpn_id
                , p_project_id                 => null -- p_project_id
                , p_task_id                    => null -- p_task_id
                , p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
              );
              /* Added following elsif for bug 13524480 */
        ELSIF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_cmro) THEN
               IF (l_debug = 1) THEN
                debug_print('calling cmro get_available_supply_demand');
               END IF;

            AHL_INV_RESERVATIONS_GRP.get_available_supply_demand (
                 p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                ,  x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , p_organization_id            => p_organization_id
                , p_item_id                    => p_item_id
                , p_revision                   => p_revision
                , p_lot_number                 => p_lot_number
                , p_subinventory_code          => p_subinventory_code
                , p_locator_id                 => p_locator_id
                , p_supply_demand_code         => 1
                 , p_supply_demand_type_id      => p_supply_source_type_id
                , p_supply_demand_header_id    => p_supply_source_header_id
                , p_supply_demand_line_id      => p_supply_source_line_id
                , p_supply_demand_line_detail  => p_supply_source_line_detail
                 , p_lpn_id                     => p_lpn_id
                , p_project_id                 => null -- p_project_id
                , p_task_id                    => null -- p_task_id
                , x_available_quantity         => l_available_quantity
                , x_source_uom_code            => l_source_uom_code
                , x_source_primary_uom_code    => l_source_primary_uom_code
                );

        END IF;

        IF (l_debug = 1) THEN
            debug_print('return status from get_available_supply_demand = ' || l_return_status);
            debug_print('available quantity = ' || l_available_quantity);
            debug_print('source uom code = ' || l_source_uom_code);
            debug_print('source primary uom code = ' || l_source_primary_uom_code);
        END IF;

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            raise fnd_api.g_exc_error;
        ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
            raise fnd_api.g_exc_unexpected_error;
        END IF;

        -- need uom conversion if source uom is different from primary uom
        IF (l_available_quantity > 0 AND l_source_uom_code is not NULL AND l_source_uom_code <> l_source_primary_uom_code) THEN
            IF (l_debug = 1) THEN
               debug_print('calling inv_convert.inv_um_convert');
               debug_print('item_id = ' || p_item_id);
               debug_print('org_id = ' || p_organization_id);
               debug_print('lot_number = ' || p_lot_number);
               debug_print('l_available_quantity = ' || l_available_quantity);
               debug_print('l_source_uom_code = ' || l_source_uom_code);
               debug_print('l_source_primary_uom_code = ' || l_source_primary_uom_code);
            END IF;

            l_primary_available_qty := inv_convert.inv_um_convert
                                      (
                                         item_id            => p_item_id
                                       , lot_number         => p_lot_number
                                       , organization_id    => p_organization_id
                                       , precision          => null
                                       , from_quantity      => l_available_quantity
                                       , from_unit          => l_source_uom_code
                                       , to_unit            => l_source_primary_uom_code
                                       , from_name          => null
                                       , to_name            => null
                                      );
        ELSE
            l_primary_available_qty := l_available_quantity;
        END IF;


        -- get the sum of quantity that is already reserved on the document.
        BEGIN
           -- BUG 5052424 BEGIN
           -- For OPM assess exisiting reservations at line level
           -- Otherwise assess at header level
           IF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_fpo OR
                 l_wip_entity_type = inv_reservation_global.g_wip_source_type_batch) THEN
             SELECT nvl(sum(primary_reservation_quantity), 0)
             INTO   l_primary_reserved_quantity
             FROM   mtl_reservations
             WHERE  supply_source_type_id = p_supply_source_type_id
             AND    supply_source_header_id = p_supply_source_header_id
             AND    supply_source_line_id = p_supply_source_line_id;
           ELSE
             SELECT nvl(sum(primary_reservation_quantity), 0)
             INTO   l_primary_reserved_quantity
             FROM   mtl_reservations
             WHERE  supply_source_type_id = p_supply_source_type_id
             AND    supply_source_header_id = p_supply_source_header_id;
           END IF;
           -- BUG 5052424 END
        EXCEPTION
           WHEN no_data_found THEN
              IF (l_debug = 1) THEN
                  debug_print('No reservation found');
              END IF;

              l_primary_reserved_quantity := 0;
        END;

-- bug 10039922 Added g_source_type_req

    ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_po OR
            p_supply_source_type_id = inv_reservation_global.g_source_type_asn OR
             p_supply_source_type_id = inv_reservation_global.g_source_type_intransit OR
             p_supply_source_type_id = inv_reservation_global.g_source_type_req OR
              p_supply_source_type_id = inv_reservation_global.g_source_type_internal_req) THEN

        -- error out if supply source header or line id is null
        IF (p_supply_source_header_id is null or p_supply_source_line_id is null) THEN
            fnd_message.set_name('INV','INV_NO_SUPPLY_INFO');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;

        -- for ASN supply, error if if supply source line detail is null
        IF (p_supply_source_type_id = inv_reservation_global.g_source_type_asn
              and p_supply_source_line_detail is null) THEN
            fnd_message.set_name('INV','INV_NO_SUPPLY_INFO');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;

        -- call availability API for PO, ASN, Intransit shipment or Internal Req
        -- For PO, the available quantity is the quantity ordered
        -- minus the quantity already delivered on that document minu quantity received
        -- minus quantity transferred to the ASN (for WMS orgs). It is the
        -- expected supply still remaining to be satisfied against the document
        -- line.
        -- For ASN, the availability is the total quantity on the ASN - quantity
        -- received on the ASN.
        -- For Intransit shipment, the availability is the total quantity
        -- on the intransit shipment - quantity received against the intransit shipment
        -- line.
        -- For internal Req, the availability is the total quantity on the internal
        -- requisition document - quantity received against this document.
        IF (l_debug = 1) THEN
           debug_print('calling RCV get_available_supply_demand');
        END IF;

        RCV_availability.get_available_supply_demand
          (
             x_return_status              => l_return_status
           , x_msg_count                  => l_msg_count
           , x_msg_data                   => l_msg_data
           , x_available_quantity         => l_available_quantity
           , x_source_uom_code            => l_source_uom_code
           , x_source_primary_uom_code    => l_source_primary_uom_code
           , p_organization_id            => p_organization_id
           , p_item_id                    => p_item_id
           , p_revision                   => p_revision
           , p_lot_number                 => p_lot_number
           , p_subinventory_code          => p_subinventory_code
           , p_locator_id                 => p_locator_id
           , p_supply_demand_code         => 1
           , p_supply_demand_type_id      => p_supply_source_type_id
           , p_supply_demand_header_id    => p_supply_source_header_id
           , p_supply_demand_line_id      => p_supply_source_line_id
           , p_supply_demand_line_detail  => p_supply_source_line_detail
           , p_lpn_id                     => p_lpn_id
           , p_project_id                 => p_project_id
           , p_task_id                    => p_task_id
           , p_api_version_number         => 1.0
           , p_init_msg_lst               => fnd_api.g_false
          );

        IF (l_debug = 1) THEN
            debug_print('return status from RCV_availability.get_available_supply_demand = ' || l_return_status);
            debug_print('available quantity = ' || l_available_quantity);
            debug_print('source uom code = ' || l_source_uom_code);
            debug_print('source primary uom code = ' || l_source_primary_uom_code);
        END IF;

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            raise fnd_api.g_exc_error;
        ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
            raise fnd_api.g_exc_unexpected_error;
        END IF;

        -- need uom conversion if source uom is different from primary uom
        IF (l_available_quantity > 0 AND l_source_uom_code is not NULL AND l_source_uom_code <> l_source_primary_uom_code) THEN
            IF (l_debug = 1) THEN
               debug_print('calling inv_convert.inv_um_convert');
               debug_print('item_id = ' || p_item_id);
               debug_print('org_id = ' || p_organization_id);
               debug_print('lot_number = ' || p_lot_number);
               debug_print('l_available_quantity = ' || l_available_quantity);
               debug_print('l_source_uom_code = ' || l_source_uom_code);
               debug_print('l_source_primary_uom_code = ' || l_source_primary_uom_code);
            END IF;

            l_primary_available_qty := inv_convert.inv_um_convert
                                      (
                                         item_id            => p_item_id
                                       , lot_number         => p_lot_number
                                       , organization_id    => p_organization_id
                                       , precision          => null
                                       , from_quantity      => l_available_quantity
                                       , from_unit          => l_source_uom_code
                                       , to_unit            => l_source_primary_uom_code
                                       , from_name          => null
                                       , to_name            => null
                                      );
        ELSE
            l_primary_available_qty := l_available_quantity;
        END IF;

-- bug 10039922 Added g_source_type_req
        IF (p_supply_source_type_id = inv_reservation_global.g_source_type_po OR
             p_supply_source_type_id = inv_reservation_global.g_source_type_intransit OR
             p_supply_source_type_id = inv_reservation_global.g_source_type_req OR
              p_supply_source_type_id = inv_reservation_global.g_source_type_internal_req) THEN

            -- get the sum of quantity that is already reserved on the document.
            BEGIN
               SELECT nvl(sum(primary_reservation_quantity), 0)
               INTO   l_primary_reserved_quantity
               FROM   mtl_reservations
               WHERE  supply_source_type_id = p_supply_source_type_id
               AND    supply_source_header_id = p_supply_source_header_id
               AND    supply_source_line_id = p_supply_source_line_id
               AND    nvl(project_id, -99) = nvl(p_project_id, -99)
               AND    nvl(task_id, -99) = nvl(p_task_id, -99);
            EXCEPTION
               WHEN no_data_found THEN
                  IF (l_debug = 1) THEN
                      debug_print('No reservation found');
                  END IF;

                  l_primary_reserved_quantity := 0;
            END;


        ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_asn) THEN

            -- get the sum of quantity that is already reserved on the document.
            BEGIN
               SELECT nvl(sum(primary_reservation_quantity), 0)
               INTO   l_primary_reserved_quantity
               FROM   mtl_reservations
               WHERE  supply_source_type_id = p_supply_source_type_id
               AND    supply_source_header_id = p_supply_source_header_id
               AND    supply_source_line_id = p_supply_source_line_id
               AND    supply_source_line_detail = p_supply_source_line_detail
               AND    nvl(project_id, -99) = nvl(p_project_id, -99)
               AND    nvl(task_id, -99) = nvl(p_task_id, -99);
            EXCEPTION
               WHEN no_data_found THEN
                  IF (l_debug = 1) THEN
                      debug_print('No reservation found');
                  END IF;

                  l_primary_reserved_quantity := 0;
            END;


        END IF;

    ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_rcv) THEN

        -- error out if organization_id or item id is null
        IF (p_organization_id is null or p_item_id is null) THEN
            fnd_message.set_name('INV', 'INV_NO_ORG_ITEM');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;

        -- call availability API for available quantity in receiving
        IF (l_debug = 1) THEN
            debug_print('Receiving supply, before calling INV_RCV_availability.get_available_supply_demand');
        END IF;

        INV_RCV_availability.get_available_supply_demand
          (
             x_return_status              => l_return_status
           , x_msg_count                  => l_msg_count
           , x_msg_data                   => l_msg_data
           , x_available_quantity         => l_available_quantity
           , x_source_uom_code            => l_source_uom_code
           , x_source_primary_uom_code    => l_source_primary_uom_code
           , p_organization_id            => p_organization_id
           , p_item_id                    => p_item_id
           , p_revision                   => p_revision
           , p_lot_number                 => p_lot_number
           , p_subinventory_code          => p_subinventory_code
           , p_locator_id                 => p_locator_id
           , p_supply_demand_code         => 1
           , p_supply_demand_type_id      => p_supply_source_type_id
           , p_supply_demand_header_id    => p_supply_source_header_id
           , p_supply_demand_line_id      => p_supply_source_line_id
           , p_supply_demand_line_detail  => p_supply_source_line_detail
           , p_lpn_id                     => p_lpn_id
           , p_project_id                 => null -- p_project_id
           , p_task_id                    => null -- p_task_id
           , p_api_version_number         => 1.0
           , p_init_msg_lst               => fnd_api.g_false
          );

        IF (l_debug = 1) THEN
            debug_print('return status from get_available_supply_demand = ' || l_return_status);
            debug_print('available quantity = ' || l_available_quantity);
            debug_print('source uom code = ' || l_source_uom_code);
            debug_print('source primary uom code = ' || l_source_primary_uom_code);
        END IF;

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            raise fnd_api.g_exc_error;
        ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
            raise fnd_api.g_exc_unexpected_error;
        END IF;

        -- need uom conversion if source uom is different from primary uom
        IF (l_available_quantity > 0 AND l_source_uom_code is not NULL AND l_source_uom_code <> l_source_primary_uom_code) THEN
            IF (l_debug = 1) THEN
               debug_print('calling inv_convert.inv_um_convert');
               debug_print('item_id = ' || p_item_id);
               debug_print('org_id = ' || p_organization_id);
               debug_print('lot_number = ' || p_lot_number);
               debug_print('l_available_quantity = ' || l_available_quantity);
               debug_print('l_source_uom_code = ' || l_source_uom_code);
               debug_print('l_source_primary_uom_code = ' || l_source_primary_uom_code);
            END IF;

            l_primary_available_qty := inv_convert.inv_um_convert
                                      (
                                         item_id            => p_item_id
                                       , lot_number         => p_lot_number
                                       , organization_id    => p_organization_id
                                       , precision          => null
                                       , from_quantity      => l_available_quantity
                                       , from_unit          => l_source_uom_code
                                       , to_unit            => l_source_primary_uom_code
                                       , from_name          => null
                                       , to_name            => null
                                      );
        ELSE
            l_primary_available_qty := l_available_quantity;
        END IF;


        -- get the sum of quantity that is already reserved on the document.
        BEGIN
           SELECT nvl(sum(primary_reservation_quantity), 0)
           INTO   l_primary_reserved_quantity
           FROM   mtl_reservations
           WHERE  supply_source_type_id = p_supply_source_type_id
           AND    organization_id = p_organization_id
           AND    inventory_item_id = p_item_id
	   AND    demand_source_type_id <> 5;-- bug 9706800: Consider reservations only for Sales Order and not for WIP Jobs/OPM batches since MOL quantity
                                              -- which is being crossdocked to wip is already taken in to consideration (inv_rcv_availability.get_available_supply_demand)
        EXCEPTION
           WHEN no_data_found THEN
              IF (l_debug = 1) THEN
                  debug_print('No reservation found');
              END IF;

              l_primary_reserved_quantity := 0;
        END;

    END IF; -- end of WIP supply
	   --Start 11899495
	    IF nvl(l_primary_reserved_quantity,0) > 0 THEN
	    BEGIN
		   SELECT Nvl(ABS(SUM(primary_quantity)),0)
	       INTO l_rti_primary_quantity
	       FROM rcv_transactions_interface rti
	       WHERE to_organization_id = p_organization_id
	       AND item_id = p_item_id
	       AND NVL(item_revision, '@@@') = NVL(p_revision,NVL(item_revision, '@@@'))
	       AND rti.processing_status_code <> 'ERROR'
	       AND rti.transaction_status_code <> 'ERROR'
	       AND NOT exists (SELECT '1' FROM rcv_transactions rt
			   WHERE rt.interface_transaction_id = rti.interface_transaction_id)
	       AND (TRANSACTION_TYPE = 'DELIVER'
	           OR (TRANSACTION_TYPE IN ('RETURN TO VENDOR','RETURN TO CUSTOMER')
		   AND EXISTS (SELECT '1' FROM rcv_transactions rt
			     WHERE rt.transaction_id = rti.parent_transaction_id
			     AND rt.transaction_type IN ('RECEIVE','ACCEPT','REJECT','TRANSFER')))
	             OR (TRANSACTION_TYPE IN ('CORRECT')
		         AND quantity < 0
		   AND EXISTS (SELECT '1' FROM rcv_transactions rt
			     WHERE rt.transaction_id = rti.parent_transaction_id
			     AND rt.transaction_type IN ('RECEIVE')))
	             OR (TRANSACTION_TYPE IN ('CORRECT')
		         AND quantity > 0
		   AND EXISTS (SELECT '1' FROM rcv_transactions rt
			     WHERE rt.transaction_id = rti.parent_transaction_id
			     AND rt.transaction_type IN ('DELIVER'))));
        EXCEPTION
        WHEN OTHERS THEN
	    l_rti_primary_quantity := 0;
        END;

		END IF;

   IF (l_debug = 1) THEN
      debug_print('l_rti_primary_quantity:'||l_rti_primary_quantity);
   END IF;
    -- calculate the final available to reserve quantity from available quantity from document and
    -- reserved quantity of the document in primary uom
    IF (l_debug = 1) THEN
        debug_print('primary available qty = ' || l_primary_available_qty);
        debug_print('primary reserved qty = ' || l_primary_reserved_quantity);
    END IF;

    IF nvl(l_primary_reserved_quantity, 0) >= nvl(l_rti_primary_quantity, 0) THEN
	  l_qty_available_to_reserve := nvl(l_primary_available_qty, 0) - (nvl(l_primary_reserved_quantity, 0) - nvl(l_rti_primary_quantity, 0));
	ELSE
     l_qty_available_to_reserve := nvl(l_primary_available_qty, 0) ;
    END IF;
	--End 11899495

    x_qty_available_to_reserve := l_qty_available_to_reserve;
    x_qty_available := nvl(l_primary_available_qty, 0);

    x_return_status := l_return_status;
  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        IF (l_debug = 1) THEN
            debug_print('expected error in available_supply_to_reserve');
        END IF;
        --
     WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        IF (l_debug = 1) THEN
            debug_print('unexpected error in available_supply_to_reserve');
            debug_print('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM);
        END IF;
        --
     WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        IF (l_debug = 1) THEN
            debug_print('others error in available_supply_to_reserve');
            debug_print('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM);
        END IF;
        --
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
                , 'available_supply_to_reserve'
                );
        END IF;
        --
  END available_supply_to_reserve;


   PROCEDURE available_demand_to_reserve
    (  p_api_version_number        IN  NUMBER DEFAULT 1.0
     , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status             OUT NOCOPY VARCHAR2
     , x_msg_count                 OUT NOCOPY NUMBER
     , x_msg_data                  OUT NOCOPY VARCHAR2
     , p_organization_id           IN  NUMBER DEFAULT NULL
     , p_item_id                   IN  NUMBER DEFAULT NULL
     , p_primary_uom_code          IN  VARCHAR2 DEFAULT NULL
     , p_demand_source_type_id     IN  NUMBER
     , p_demand_source_header_id   IN  NUMBER
     , p_demand_source_line_id     IN  NUMBER
     , p_demand_source_line_detail IN  NUMBER DEFAULT fnd_api.g_miss_num
     , p_project_id                IN  NUMBER DEFAULT NULL
     , p_task_id                   IN  NUMBER DEFAULT NULL
     , x_qty_available_to_reserve  OUT NOCOPY NUMBER
     , x_qty_available             OUT NOCOPY NUMBER
    )  IS
          x_qty_available_to_reserve2 NUMBER;
          x_qty_available2 NUMBER;

BEGIN
  ---  MUOM Fulfillment Call the overloaded procedure
     available_demand_to_reserve(
                        p_api_version_number   => p_api_version_number
                      , p_init_msg_lst  =>  p_init_msg_lst
                      , x_return_status =>  x_return_status
                       , x_msg_count  =>  x_msg_count
                       , x_msg_data    =>    x_msg_data
                       , p_organization_id    =>   p_organization_id
                       , p_item_id     =>    p_item_id
                       , p_primary_uom_code  => p_primary_uom_code
                       , p_demand_source_type_id  =>p_demand_source_type_id
                       , p_demand_source_header_id  => p_demand_source_header_id
                       , p_demand_source_line_id  => p_demand_source_line_id
                       , p_demand_source_line_detail  =>p_demand_source_line_detail
                       , p_project_id  => p_project_id
                       , p_task_id   => p_task_id
                       , x_qty_available_to_reserve  => x_qty_available_to_reserve
                       , x_qty_available   =>   x_qty_available
                       , x_qty_available_to_reserve2  => x_qty_available_to_reserve2
                       , x_qty_available2    =>   x_qty_available2) ;

END  available_demand_to_reserve;

--MUOM overloaded procedure for x_qty_available_to_reserve2,  x_qty_available2

  PROCEDURE available_demand_to_reserve
    (
       p_api_version_number        IN  NUMBER DEFAULT 1.0
     , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status             OUT NOCOPY VARCHAR2
     , x_msg_count                 OUT NOCOPY NUMBER
     , x_msg_data                  OUT NOCOPY VARCHAR2
     , p_organization_id           IN  NUMBER DEFAULT NULL
     , p_item_id                   IN  NUMBER DEFAULT NULL
     , p_primary_uom_code          IN  VARCHAR2 DEFAULT NULL
     , p_demand_source_type_id     IN  NUMBER
     , p_demand_source_header_id   IN  NUMBER
     , p_demand_source_line_id     IN  NUMBER
     , p_demand_source_line_detail IN  NUMBER DEFAULT fnd_api.g_miss_num
     , p_project_id                IN  NUMBER DEFAULT NULL
     , p_task_id                   IN  NUMBER DEFAULT NULL
     , x_qty_available_to_reserve  OUT NOCOPY NUMBER
     , x_qty_available             OUT NOCOPY NUMBER
    , x_qty_available_to_reserve2  OUT NOCOPY NUMBER
    , x_qty_available2             OUT NOCOPY NUMBER
    )  IS
    l_api_version_number CONSTANT    NUMBER         := 1.0;
    l_api_name           CONSTANT    VARCHAR2(30)   := 'avilable_demand_to_reserve';
    l_return_status                  VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count                      NUMBER;
    l_msg_data                       VARCHAR2(2000);
    l_debug                          NUMBER;
    l_wip_entity_type                NUMBER;
    l_wip_job_type                   VARCHAR2(15);
    l_available_quantity             NUMBER;
    l_source_uom_code                VARCHAR2(3);
    l_source_primary_uom_code        VARCHAR2(3);
    l_primary_reserved_quantity      NUMBER;
    l_qty_available_to_reserve       NUMBER;
    l_primary_available_qty          NUMBER;
    l_wdd_primary_quantity           NUMBER;
    l_wdd_primary_reserved_qty       NUMBER;
    l_wdd_available_qty              NUMBER;
    l_order_available_qty            NUMBER;
    l_rsv_primary_uom_code           VARCHAR2(3);
    l_order_quantity_uom_code        VARCHAR2(3);
    l_wdd_picked_qty                 NUMBER  := 0;       --Added for Bug# 8807194
    l_primary_wdd_picked_qty         NUMBER;             --Added for Bug# 8807194
    l_wdd_uom_code                   VARCHAR2(3);        --Added for Bug# 8807194
    l_over_shippable_qty             NUMBER ;            --Bug#8983636

    --Bug 12978409: start
    lot_conv_factor_flag NUMBER := 0;
    l_lot_primary_rsv_qty_total NUMBER := 0;
    l_lot_rsv_quantity_rsv_uom NUMBER;
    l_lot_primary_rsv_qty NUMBER;
    l_order_line_uom VARCHAR2(3);
    l_lot_rsv_qty_order_uom NUMBER;

	/*  MUOM Fulfillment Project*/
    l_wdd_secondary_quantity         NUMBER;
    l_wdd_secondary_reserved_qty     NUMBER;
    l_rsv_secondary_uom_code         VARCHAR2(3);
    l_secondary_reserved_quantity    NUMBER;
    l_available_quantity2            NUMBER;
    l_order_quantity_uom2            VARCHAR2(3);
    l_wdd_picked_qty2                NUMBER;
    l_wdd_uom2                       VARCHAR2(3);
    l_wdd_available_qty2             number;
    l_order_available_qty2           number;
    l_qty_available_to_reserve2      number;

    CURSOR check_if_lot_conv_exists(p_lot_number varchar2, p_inventory_item_id number, p_organization_id number)  IS
    SELECT count(*)
    FROM mtl_lot_uom_class_conversions
    WHERE lot_number      = p_lot_number
    AND inventory_item_id = p_inventory_item_id
    AND organization_id   = p_organization_id
    AND (disable_date IS NULL or disable_date > sysdate);

    CURSOR rsv_with_lots IS
    SELECT  organization_id, inventory_item_id, lot_number,
            primary_uom_code, primary_reservation_quantity, reservation_uom_code
    FROM    mtl_reservations
    WHERE   demand_source_type_id     = p_demand_source_type_id
    AND     demand_source_header_id   = p_demand_source_header_id
    AND     demand_source_line_id     = p_demand_source_line_id
    AND     demand_source_line_detail is null
    AND     lot_number is not null;

    CURSOR get_order_line_uom IS
    SELECT order_quantity_uom
    FROM   oe_order_lines_all
    WHERE  line_id = p_demand_source_line_id;

    --Bug 12978409: end
  BEGIN
    IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('In available_demand_to_reserve');
        debug_print('demand source type id = ' || p_demand_source_type_id);
        debug_print('demand source header id = ' || p_demand_source_header_id);
        debug_print('demand source line id = ' || p_demand_source_line_id);
        debug_print('demand source line detail = ' || p_demand_source_line_detail);
        debug_print('project id = ' || p_project_id);
        debug_print('task id = ' || p_task_id);
    END IF;

    -- error out if demand source type id is null
    IF (p_demand_source_type_id is null) THEN
        fnd_message.set_name('INV', 'INV_NO_DEMAND_TYPE');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END IF;

    -- for WIP demand source
    IF (p_demand_source_type_id = inv_reservation_global.g_source_type_wip) THEN

        -- error out if demand source header id is null
        IF (p_demand_source_header_id is null) THEN
            fnd_message.set_name('INV','INV_NO_DEMAND_INFO');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;

        -- get wip entitty type from wip_record_cache
        inv_reservation_util_pvt.get_wip_cache
           (
              x_return_status            => l_return_status
            , p_wip_entity_id            => p_demand_source_header_id
           );

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
        ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
           l_wip_entity_type := inv_reservation_global.g_wip_record_cache(p_demand_source_header_id).wip_entity_type;
           l_wip_job_type := inv_reservation_global.g_wip_record_cache(p_demand_source_header_id).wip_entity_job;
        END IF;

        IF (l_debug = 1) THEN
            debug_print('wip entity type = ' || l_wip_entity_type);
        END IF;

        -- call availability API for the WIP entity type to get the quantity
        -- available on the document. This quantity is the quantity ordered
        -- minus the quantity already delivered on that document. It is the
        -- expected demand still remaining to be satisfied against the document
        -- line.
        IF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_cmro) THEN
            IF (l_debug = 1) THEN
                debug_print('calling WIP cmro get_available_supply_demand');
            END IF;

            AHL_INV_RESERVATIONS_GRP.get_available_supply_demand
               (
                  x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , x_available_quantity         => l_available_quantity
                , x_source_uom_code            => l_source_uom_code
                , x_source_primary_uom_code    => l_source_primary_uom_code
                , p_organization_id            => null
                , p_item_id                    => null
                , p_revision                   => null
                , p_lot_number                 => null
                , p_subinventory_code          => null
                , p_locator_id                 => null
                , p_supply_demand_code         => 2
                , p_supply_demand_type_id      => p_demand_source_type_id
                , p_supply_demand_header_id    => p_demand_source_header_id
                , p_supply_demand_line_id      => p_demand_source_line_id
                , p_supply_demand_line_detail  => p_demand_source_line_detail
                , p_lpn_id                     => null
                , p_project_id                 => null -- p_project_id
                , p_task_id                    => null -- p_task_id
                , p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
              );

            IF (l_debug = 1) THEN
                debug_print('return status from cmro get_available_supply_demand = ' || l_return_status);
                debug_print('available quantity = ' || l_available_quantity);
                debug_print('source uom code = ' || l_source_uom_code);
                debug_print('source primary uom code = ' || l_source_primary_uom_code);
            END IF;

            IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                raise fnd_api.g_exc_error;
            ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                raise fnd_api.g_exc_unexpected_error;
            END IF;

           -- get the sum of quantity that is already reserved on the document.
           -- bug #5458083 added demand_source_line_detail in the where clause
           -- for cmro demand.
           BEGIN
              SELECT nvl(sum(primary_reservation_quantity), 0)
              INTO   l_primary_reserved_quantity
              FROM   mtl_reservations
              WHERE  demand_source_type_id = p_demand_source_type_id
              AND    demand_source_header_id = p_demand_source_header_id
              AND    demand_source_line_id = p_demand_source_line_id
              AND    demand_source_line_detail = p_demand_source_line_detail;
           EXCEPTION
              WHEN no_data_found THEN
                 IF (l_debug = 1) THEN
                     debug_print('No reservation found for cmro test number');
                 END IF;

                 l_primary_reserved_quantity := 0;
           END;


        ELSIF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_fpo OR
                 l_wip_entity_type = inv_reservation_global.g_wip_source_type_batch) THEN
           IF (l_debug = 1) THEN
                debug_print('calling opm get_available_supply_demand');
           END IF;
           GME_API_GRP.get_available_supply_demand
               (
                  x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , x_available_quantity         => l_available_quantity
                , x_source_uom_code            => l_source_uom_code
                , x_source_primary_uom_code    => l_source_primary_uom_code
                , p_organization_id            => null
                , p_item_id                    => null
                , p_revision                   => null
                , p_lot_number                 => null
                , p_subinventory_code          => null
                , p_locator_id                 => null
                , p_supply_demand_code         => 2
                , p_supply_demand_type_id      => p_demand_source_type_id
                , p_supply_demand_header_id    => p_demand_source_header_id
                , p_supply_demand_line_id      => p_demand_source_line_id
                , p_supply_demand_line_detail  => p_demand_source_line_detail
                , p_lpn_id                     => null
                , p_project_id                 => null -- p_project_id
                , p_task_id                    => null -- p_task_id
                , p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
              );

           IF (l_debug = 1) THEN
               debug_print('return status from batch/fpo get_available_supply_demand = ' || l_return_status);
               debug_print('available quantity = ' || l_available_quantity);
               debug_print('source uom code = ' || l_source_uom_code);
               debug_print('source primary uom code = ' || l_source_primary_uom_code);
           END IF;

           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
               raise fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
               raise fnd_api.g_exc_unexpected_error;
           END IF;

           -- get the sum of quantity that is already reserved on the document.
           BEGIN
              SELECT nvl(sum(primary_reservation_quantity), 0)
              INTO   l_primary_reserved_quantity
              FROM   mtl_reservations
              WHERE  demand_source_type_id = p_demand_source_type_id
              AND    demand_source_header_id = p_demand_source_header_id
              AND    demand_source_line_id = p_demand_source_line_id;
           EXCEPTION
              WHEN no_data_found THEN
                 IF (l_debug = 1) THEN
                     debug_print('No reservation found for batch/fpo');
                 END IF;

                 l_primary_reserved_quantity := 0;
           END;

        END IF;

        -- need uom conversion if source uom is different from primary uom
        IF (l_source_uom_code <> l_source_primary_uom_code) THEN
            IF (l_debug = 1) THEN
               debug_print('calling inv_convert.inv_um_convert');
               debug_print('l_available_quantity = ' || l_available_quantity);
               debug_print('l_source_uom_code = ' || l_source_uom_code);
               debug_print('l_source_primary_uom_code = ' || l_source_primary_uom_code);
            END IF;

            l_primary_available_qty := inv_convert.inv_um_convert
                                      (
                                         item_id            => p_item_id
                                       , lot_number         => null
                                       , organization_id    => p_organization_id
                                       , precision          => null
                                       , from_quantity      => l_available_quantity
                                       , from_unit          => l_source_uom_code
                                       , to_unit            => l_source_primary_uom_code
                                       , from_name          => null
                                       , to_name            => null
                                      );
        ELSE
            l_primary_available_qty := l_available_quantity;
        END IF;

        l_qty_available_to_reserve := l_primary_available_qty - l_primary_reserved_quantity;

    ELSIF (p_demand_source_type_id in
	   (inv_reservation_global.g_source_type_oe,
	    inv_reservation_global.g_source_type_internal_ord,
	    inv_reservation_global.g_source_type_rma)) THEN

        IF (p_demand_source_line_detail is not NULL AND p_demand_source_line_detail <> fnd_api.g_miss_num) THEN

            IF (l_debug = 1) THEN
                debug_print('p_demand_source_line_detail is not NULL and p_demand_source_line_detail <> fnd_api.g_miss_num');
            END IF;

            -- get wdd requested quantity with line detail level
            BEGIN
               SELECT nvl(sum(requested_quantity), 0)  , nvl(sum(requested_quantity2), 0)
               INTO   l_wdd_primary_quantity, l_wdd_secondary_quantity
               FROM   wsh_delivery_details
               WHERE  source_line_id = p_demand_source_line_id
               AND    delivery_detail_id = p_demand_source_line_detail
               AND    nvl(project_id, -99) = nvl(p_project_id, -99)
               AND    nvl(task_id, -99) = nvl(p_task_id, -99);
            EXCEPTION
               WHEN no_data_found THEN
                  IF (l_debug = 1) THEN
                      debug_print('No wdd found for source_line_id: '|| p_demand_source_line_id);
                      debug_print('demand_source_line_detail: ' || p_demand_source_line_detail);
                      debug_print('project_id = ' || p_project_id || ' and task_id = ' || p_task_id);
                  END IF;

                  FND_MESSAGE.SET_NAME('INV', 'INV_WDD_NOT_FOUND');
                  FND_MSG_PUB.ADD;
                  RAISE fnd_api.g_exc_error;
            END;

            IF (l_debug = 1) THEN
                debug_print('l_wdd_primary_quantity = ' || l_wdd_primary_quantity);
		debug_print('l_wdd_secondary_quantity = ' || l_wdd_secondary_quantity);
            END IF;

            -- get reservation quantity against the wdd with line detail level
            BEGIN
               SELECT nvl(sum(primary_reservation_quantity), 0), primary_uom_code
			   ,nvl(sum(secondary_reservation_quantity), 0)
               INTO   l_wdd_primary_reserved_qty, l_rsv_primary_uom_code, l_wdd_secondary_reserved_qty
               FROM   mtl_reservations
               WHERE  demand_source_type_id = p_demand_source_type_id
               AND    demand_source_header_id = p_demand_source_header_id
               AND    demand_source_line_id = p_demand_source_line_id
               AND    demand_source_line_detail = p_demand_source_line_detail
               GROUP BY primary_uom_code;
            EXCEPTION
               WHEN no_data_found THEN
                  IF (l_debug = 1) THEN
                      debug_print('No reservation is found for detail level, demand_source_type_id= ' || p_demand_source_type_id);
                      debug_print('demand_source_header_id = ' || p_demand_source_header_id);
                      debug_print('demand_source_line_id = ' || p_demand_source_line_id);
                      debug_print('demand_source_line_detail = ' || p_demand_source_line_detail);
                      debug_print('project_id = ' || p_project_id || ' and task_id = ' || p_task_id);
                  END IF;

                  l_wdd_primary_reserved_qty := 0;
		  l_wdd_secondary_reserved_qty:=0;
            END;

            IF (l_debug = 1) THEN
                debug_print('l_wdd_primary_reserved_qty = ' || l_wdd_primary_reserved_qty);
				debug_print('l_wdd_secondary_reserved_qty = ' || l_wdd_secondary_reserved_qty);
            END IF;

            -- get all reservation quantity at the order line level
            BEGIN
               SELECT nvl(sum(primary_reservation_quantity), 0), primary_uom_code
			   ,nvl(sum(secondary_reservation_quantity), 0)
               INTO   l_primary_reserved_quantity, l_rsv_primary_uom_code ,l_secondary_reserved_quantity
               FROM   mtl_reservations
               WHERE  demand_source_type_id = p_demand_source_type_id
               AND    demand_source_header_id = p_demand_source_header_id
               AND    demand_source_line_id = p_demand_source_line_id
               GROUP BY primary_uom_code;
            EXCEPTION
               WHEN no_data_found THEN
                  IF (l_debug = 1) THEN
                      debug_print('No reservation is found for line level, demand_source_type_id= ' || p_demand_source_type_id);
                      debug_print('demand_source_header_id = ' || p_demand_source_header_id);
                      debug_print('demand_source_line_id = ' || p_demand_source_line_id);
                      debug_print('project_id = ' || p_project_id || ' and task_id = ' || p_task_id);
                  END IF;

                  l_primary_reserved_quantity := 0;
		  l_secondary_reserved_quantity :=0;
            END;

            IF (l_debug = 1) THEN
                debug_print('l_primary_reserved_quantity = ' || l_primary_reserved_quantity);
		debug_print('l_secondary_reserved_quantity = ' || l_secondary_reserved_quantity);
            END IF;

        ELSIF (p_demand_source_line_detail = fnd_api.g_miss_num) THEN

            IF (l_debug = 1) THEN
                debug_print('p_demand_source_line_detail = fnd_api.g_miss_num');
            END IF;

            -- get all reservation quantity at the order line level
            BEGIN
               SELECT nvl(sum(primary_reservation_quantity), 0), primary_uom_code
			   ,nvl(sum(secondary_reservation_quantity), 0)
               INTO   l_primary_reserved_quantity, l_rsv_primary_uom_code ,l_secondary_reserved_quantity
               FROM   mtl_reservations
               WHERE  demand_source_type_id = p_demand_source_type_id
               AND    demand_source_header_id = p_demand_source_header_id
               AND    demand_source_line_id = p_demand_source_line_id
               AND    lot_number IS NULL --Bug 12978409
               GROUP BY primary_uom_code;
            EXCEPTION
               WHEN no_data_found THEN
                  IF (l_debug = 1) THEN
                      debug_print('No reservation is found for line level, demand_source_type_id= ' || p_demand_source_type_id);                      debug_print('demand_source_header_id = ' || p_demand_source_header_id);
                      debug_print('demand_source_line_id = ' || p_demand_source_line_id);
                      debug_print('project_id = ' || p_project_id || ' and task_id = ' || p_task_id);
                  END IF;

                  l_primary_reserved_quantity := 0;
		  l_secondary_reserved_quantity :=0;
            END;

            IF (l_debug = 1) THEN
                debug_print('l_primary_reserved_quantity = ' || l_primary_reserved_quantity);
		debug_print('l_secondary_reserved_quantity = ' || l_secondary_reserved_quantity);
            END IF;

             --Bug 12978409 start Need t oconsider the lot uom conversion while calculating the total qty.
             FOR rsv_with_lots_rec IN rsv_with_lots LOOP
                EXIT WHEN rsv_with_lots%notfound;

                OPEN  check_if_lot_conv_exists(rsv_with_lots_rec.lot_number, rsv_with_lots_rec.inventory_item_id, rsv_with_lots_rec.organization_id);
                FETCH check_if_lot_conv_exists into lot_conv_factor_flag;
                CLOSE check_if_lot_conv_exists;

                OPEN  get_order_line_uom;
                FETCH get_order_line_uom into l_order_line_uom;
                CLOSE get_order_line_uom;

                    IF (l_debug = 1) THEN
                       debug_print('inventory_item_id =   ' || rsv_with_lots_rec.inventory_item_id);
                       debug_print('lot_number =          ' || rsv_with_lots_rec.lot_number);
                       debug_print('organization_id =     ' || rsv_with_lots_rec.organization_id);
                       debug_print('primary_uom_code =    ' || rsv_with_lots_rec.primary_uom_code);
                       debug_print('reservation_uom_code= ' || rsv_with_lots_rec.reservation_uom_code);
                       debug_print('order_line_uom =      ' || l_order_line_uom);
                       debug_print('lot_conv_factor_flag= ' || lot_conv_factor_flag);
                    END IF;

                IF lot_conv_factor_flag > 0 THEN
                    IF (l_debug = 1) THEN
                        debug_print('Lot conversion exists for this item');
                    END IF;

                     IF rsv_with_lots_rec.primary_uom_code <> rsv_with_lots_rec.reservation_uom_code THEN
                       IF (l_debug = 1) THEN
                             debug_print('primary_uom_code and reservation_uom_code are different');
                       END IF;

                       l_lot_rsv_quantity_rsv_uom  := inv_convert.inv_um_convert(
                                Item_id          => rsv_with_lots_rec.inventory_item_id
                              , Lot_number       => rsv_with_lots_rec.lot_number
                              , Organization_id  => rsv_with_lots_rec.organization_id
                              , Precision        => null
                              , From_quantity    => nvl(rsv_with_lots_rec.primary_reservation_quantity, 0)
                              , From_unit        => rsv_with_lots_rec.primary_uom_code
                              , To_unit          => rsv_with_lots_rec.reservation_uom_code
                              , from_name        => NULL
                              , to_name          => NULL
                               );
                             IF (l_debug = 1) THEN
                               debug_print('reservation qty with lots in reservation uom (honoring lot conversion) = '
                                           || l_lot_rsv_quantity_rsv_uom);
                             END IF;

                        l_lot_primary_rsv_qty  := inv_convert.inv_um_convert(
                                Item_id          => rsv_with_lots_rec.inventory_item_id
                              , Organization_id  => rsv_with_lots_rec.organization_id
                              , Precision        => null
                              , From_quantity    => l_lot_rsv_quantity_rsv_uom
                              , From_unit        => rsv_with_lots_rec.reservation_uom_code
                              , To_unit          => rsv_with_lots_rec.primary_uom_code
                              , from_name        => NULL
                              , to_name          => NULL
                               );

                        l_lot_primary_rsv_qty_total  :=  l_lot_primary_rsv_qty_total + l_lot_primary_rsv_qty ;

                             IF (l_debug = 1) THEN
                               debug_print('reservation qty with lots in primary uom (honoring lot conversion)= '
                                           || l_lot_primary_rsv_qty);
                               debug_print('total reservation qty with lots in primary uom (honoring lot conversion)= '
                                           || l_lot_primary_rsv_qty_total);
                             END IF;

                     ELSIF  rsv_with_lots_rec.primary_uom_code <> l_order_line_uom THEN
                       IF (l_debug = 1) THEN
                             debug_print('primary_uom_code and order_uom_code are different');
                       END IF;

                       l_lot_rsv_qty_order_uom  := inv_convert.inv_um_convert(
                                Item_id          => rsv_with_lots_rec.inventory_item_id
                              , Lot_number       => rsv_with_lots_rec.lot_number
                              , Organization_id  => rsv_with_lots_rec.organization_id
                              , Precision        => null
                              , From_quantity    => nvl(rsv_with_lots_rec.primary_reservation_quantity, 0)
                              , From_unit        => rsv_with_lots_rec.primary_uom_code
                              , To_unit          => l_order_line_uom
                              , from_name        => NULL
                              , to_name          => NULL
                               );
                             IF (l_debug = 1) THEN
                               debug_print('reservation qty with lots in order uom (honoring lot conversion) = '
                                           || l_lot_rsv_qty_order_uom);
                             END IF;

                        l_lot_primary_rsv_qty  := inv_convert.inv_um_convert(
                                Item_id          => rsv_with_lots_rec.inventory_item_id
                              , Organization_id  => rsv_with_lots_rec.organization_id
                              , Precision        => null
                              , From_quantity    => l_lot_rsv_qty_order_uom
                              , From_unit        => l_order_line_uom
                              , To_unit          => rsv_with_lots_rec.primary_uom_code
                              , from_name        => NULL
                              , to_name          => NULL
                               );
                          l_lot_primary_rsv_qty_total  :=  l_lot_primary_rsv_qty_total + l_lot_primary_rsv_qty ;

                             IF (l_debug = 1) THEN
                               debug_print('reservation qty with lots in primary uom (honoring lot conversion)= '
                                           || l_lot_primary_rsv_qty);
                               debug_print('total reservation qty with lots in primary uom (honoring lot conversion)= '
                                           || l_lot_primary_rsv_qty_total);
                             END IF;
                      ELSE
                            l_lot_primary_rsv_qty_total  :=  l_lot_primary_rsv_qty_total + nvl(rsv_with_lots_rec.primary_reservation_quantity, 0);
                            IF (l_debug = 1) THEN
                               debug_print('primary_uom_code and reservation_uom_code are same');
                               debug_print('l_lot_primary_rsv_qty_total = ' || l_lot_primary_rsv_qty_total);
                            END IF;

                      END IF;

                 ELSE
                    l_lot_primary_rsv_qty_total  :=  l_lot_primary_rsv_qty_total + nvl(rsv_with_lots_rec.primary_reservation_quantity, 0);
                    IF (l_debug = 1) THEN
                        debug_print('Lot conversion doesnt exist for this item');
                        debug_print('l_lot_primary_rsv_qty_total = ' || l_lot_primary_rsv_qty_total);
                    END IF;
                 END IF;
             END LOOP;

             IF (l_debug = 1) THEN
               debug_print('Total reservation qty with lots in primary uom = ' || l_lot_primary_rsv_qty_total);
             END IF;

             l_primary_reserved_quantity   := l_primary_reserved_quantity + l_lot_primary_rsv_qty_total;

             IF (l_debug = 1) THEN
               debug_print('Total primary reservation qty for lots and non lots rsv records = ' || l_lot_primary_rsv_qty_total);
             END IF;
             --Bug 12978409 end

        ELSIF (p_demand_source_line_detail is null) THEN

            IF (l_debug = 1) THEN
                debug_print('p_demand_source_line_detail is null');
            END IF;

            -- get all reservation quantity with the line detail = null
            BEGIN
               SELECT nvl(sum(primary_reservation_quantity), 0), primary_uom_code
			   ,nvl(sum(secondary_reservation_quantity), 0)
               INTO   l_primary_reserved_quantity, l_rsv_primary_uom_code ,l_secondary_reserved_quantity
               FROM   mtl_reservations
               WHERE  demand_source_type_id = p_demand_source_type_id
               AND    demand_source_header_id = p_demand_source_header_id
               AND    demand_source_line_id = p_demand_source_line_id
               AND    demand_source_line_detail is null
               AND    lot_number is null --lydal
               GROUP BY primary_uom_code;
            EXCEPTION
               WHEN no_data_found THEN
                  IF (l_debug = 1) THEN
                      debug_print('No reservation is found for line level, demand_source_type_id= ' || p_demand_source_type_id);                      debug_print('demand_source_header_id = ' || p_demand_source_header_id);
                      debug_print('demand_source_line_id = ' || p_demand_source_line_id);
                      debug_print('project_id = ' || p_project_id || ' and task_id = ' || p_task_id);
                  END IF;

                  l_primary_reserved_quantity := 0;
				  l_secondary_reserved_quantity :=0;
            END;

            IF (l_debug = 1) THEN
                debug_print('l_primary_reserved_quantity = ' || l_primary_reserved_quantity);
				debug_print('l_secondary_reserved_quantity = ' || l_secondary_reserved_quantity);
            END IF;

         --Bug 12978409 start Need t oconsider the lot uom conversion while calculating the total qty.
         FOR rsv_with_lots_rec IN rsv_with_lots LOOP
            EXIT WHEN rsv_with_lots%notfound;

            OPEN  check_if_lot_conv_exists(rsv_with_lots_rec.lot_number, rsv_with_lots_rec.inventory_item_id, rsv_with_lots_rec.organization_id);
            FETCH check_if_lot_conv_exists into lot_conv_factor_flag;
            CLOSE check_if_lot_conv_exists;

            OPEN  get_order_line_uom;
            FETCH get_order_line_uom into l_order_line_uom;
            CLOSE get_order_line_uom;

                IF (l_debug = 1) THEN
                   debug_print('inventory_item_id =   ' || rsv_with_lots_rec.inventory_item_id);
                   debug_print('lot_number =          ' || rsv_with_lots_rec.lot_number);
                   debug_print('organization_id =     ' || rsv_with_lots_rec.organization_id);
                   debug_print('primary_uom_code =    ' || rsv_with_lots_rec.primary_uom_code);
                   debug_print('reservation_uom_code= ' || rsv_with_lots_rec.reservation_uom_code);
                   debug_print('order_line_uom =      ' || l_order_line_uom);
                   debug_print('lot_conv_factor_flag= ' || lot_conv_factor_flag);
                END IF;

            IF lot_conv_factor_flag > 0 THEN
                IF (l_debug = 1) THEN
                    debug_print('Lot conversion exists for this item');
                END IF;

                 IF rsv_with_lots_rec.primary_uom_code <> rsv_with_lots_rec.reservation_uom_code THEN
                   IF (l_debug = 1) THEN
                         debug_print('primary_uom_code and reservation_uom_code are different');
                   END IF;

                   l_lot_rsv_quantity_rsv_uom  := inv_convert.inv_um_convert(
                            Item_id          => rsv_with_lots_rec.inventory_item_id
                          , Lot_number       => rsv_with_lots_rec.lot_number
                          , Organization_id  => rsv_with_lots_rec.organization_id
                          , Precision        => null
                          , From_quantity    => nvl(rsv_with_lots_rec.primary_reservation_quantity, 0)
                          , From_unit        => rsv_with_lots_rec.primary_uom_code
                          , To_unit          => rsv_with_lots_rec.reservation_uom_code
                          , from_name        => NULL
                          , to_name          => NULL
                           );
                         IF (l_debug = 1) THEN
                           debug_print('reservation qty with lots in reservation uom (honoring lot conversion) = '
                                       || l_lot_rsv_quantity_rsv_uom);
                         END IF;

                    l_lot_primary_rsv_qty  := inv_convert.inv_um_convert(
                            Item_id          => rsv_with_lots_rec.inventory_item_id
                          , Organization_id  => rsv_with_lots_rec.organization_id
                          , Precision        => null
                          , From_quantity    => l_lot_rsv_quantity_rsv_uom
                          , From_unit        => rsv_with_lots_rec.reservation_uom_code
                          , To_unit          => rsv_with_lots_rec.primary_uom_code
                          , from_name        => NULL
                          , to_name          => NULL
                           );
                      l_lot_primary_rsv_qty_total  :=  l_lot_primary_rsv_qty_total + l_lot_primary_rsv_qty ;

                         IF (l_debug = 1) THEN
                           debug_print('reservation qty with lots in primary uom (honoring lot conversion)= '
                                       || l_lot_primary_rsv_qty);
                           debug_print('total reservation qty with lots in primary uom (honoring lot conversion)= '
                                       || l_lot_primary_rsv_qty_total);
                         END IF;

                 ELSIF  rsv_with_lots_rec.primary_uom_code <> l_order_line_uom THEN
                   IF (l_debug = 1) THEN
                         debug_print('primary_uom_code and order_uom_code are different');
                   END IF;

                   l_lot_rsv_qty_order_uom  := inv_convert.inv_um_convert(
                            Item_id          => rsv_with_lots_rec.inventory_item_id
                          , Lot_number       => rsv_with_lots_rec.lot_number
                          , Organization_id  => rsv_with_lots_rec.organization_id
                          , Precision        => null
                          , From_quantity    => nvl(rsv_with_lots_rec.primary_reservation_quantity, 0)
                          , From_unit        => rsv_with_lots_rec.primary_uom_code
                          , To_unit          => l_order_line_uom
                          , from_name        => NULL
                          , to_name          => NULL
                           );
                         IF (l_debug = 1) THEN
                           debug_print('reservation qty with lots in order uom (honoring lot conversion) = '
                                       || l_lot_rsv_qty_order_uom);
                         END IF;

                    l_lot_primary_rsv_qty  := inv_convert.inv_um_convert(
                            Item_id          => rsv_with_lots_rec.inventory_item_id
                          , Organization_id  => rsv_with_lots_rec.organization_id
                          , Precision        => null
                          , From_quantity    => l_lot_rsv_qty_order_uom
                          , From_unit        => l_order_line_uom
                          , To_unit          => rsv_with_lots_rec.primary_uom_code
                          , from_name        => NULL
                          , to_name          => NULL
                           );
                      l_lot_primary_rsv_qty_total  :=  l_lot_primary_rsv_qty_total + l_lot_primary_rsv_qty ;

                         IF (l_debug = 1) THEN
                           debug_print('reservation qty with lots in primary uom (honoring lot conversion)= '
                                       || l_lot_primary_rsv_qty);
                           debug_print('total reservation qty with lots in primary uom (honoring lot conversion)= '
                                       || l_lot_primary_rsv_qty_total);
                         END IF;
                  ELSE
                        l_lot_primary_rsv_qty_total  :=  l_lot_primary_rsv_qty_total + nvl(rsv_with_lots_rec.primary_reservation_quantity, 0);
                        IF (l_debug = 1) THEN
                           debug_print('primary_uom_code and reservation_uom_code are same');
                           debug_print('l_lot_primary_rsv_qty_total = ' || l_lot_primary_rsv_qty_total);
                        END IF;

                  END IF;

             ELSE
                l_lot_primary_rsv_qty_total  :=  l_lot_primary_rsv_qty_total + nvl(rsv_with_lots_rec.primary_reservation_quantity, 0);
                IF (l_debug = 1) THEN
                    debug_print('Lot conversion doesnt exist for this item');
                    debug_print('l_lot_primary_rsv_qty_total = ' || l_lot_primary_rsv_qty_total);
                END IF;
             END IF;
         END LOOP;

         IF (l_debug = 1) THEN
             debug_print('Total reservation qty with lots in primary uom = ' || l_lot_primary_rsv_qty_total);
         END IF;

         l_primary_reserved_quantity   := l_primary_reserved_quantity + l_lot_primary_rsv_qty_total;

         IF (l_debug = 1) THEN
             debug_print('Total primary reservation qty for lots and non lots rsv records = ' || l_lot_primary_rsv_qty_total);
         END IF;
         --Bug 12978409 end

        END IF; --p_demand_source_line_detail


        -- get total ordered quantity at the order line level
        -- ????? for available quantity, do we need to substract ordered quantity from shipped quantity
        BEGIN
           SELECT ordered_quantity , order_quantity_uom
		   ,ordered_quantity2 , ordered_quantity_uom2
           INTO   l_available_quantity, l_order_quantity_uom_code
		    ,l_available_quantity2, l_order_quantity_uom2
           FROM   oe_order_lines_all
           WHERE  line_id = p_demand_source_line_id; --Bug14629017
           --AND    nvl(project_id, -99) = nvl(p_project_id, -99)
           --AND    nvl(task_id, -99) = nvl(p_task_id, -99);
        EXCEPTION
           WHEN no_data_found THEN
              IF (l_debug = 1) THEN
                  debug_print('No order is found for line_id = ' || p_demand_source_line_id);
                  debug_print('project_id = ' || p_project_id || ' and task_id = ' || p_task_id);
              END IF;
        END;
	--8983636 begin
	IF (p_organization_id IS NOT NULL) THEN
	IF (NOT INV_CACHE.set_org_rec(p_organization_id)) THEN
            IF (l_debug = 1) THEN
              debug_print('EXCEPTION while trying to set org parameters');
            END IF;
            RAISE fnd_api.g_exc_error;
        END IF;
	END IF;
        IF (l_debug = 1) THEN
           debug_print('wms enabled ? : '||NVL(INV_CACHE.org_rec.wms_enabled_flag,'N') );
        END IF;
        IF ( NVL(INV_CACHE.org_rec.wms_enabled_flag,'N') = 'Y' ) THEN
           BEGIN
             SELECT nvl((ordered_quantity * ship_tolerance_above/100),0) INTO l_over_shippable_qty
             FROM   oe_order_lines_all
	     WHERE  line_id = p_demand_source_line_id
             AND    nvl(project_id, -99) = nvl(p_project_id, -99)
             AND    nvl(task_id, -99)    = nvl(p_task_id, -99)
	     AND NOT EXISTS (SELECT 1 FROM MTL_RESERVATIONS MR
	                     WHERE MR.demand_source_line_id = p_demand_source_line_id
			     AND   MR.demand_source_type_id = p_demand_source_type_id
		             AND   MR.demand_source_header_id = p_demand_source_header_id
			     AND NVL (MR.staged_flag,'N')  <> 'Y' ) ;
             IF (l_debug = 1) THEN
               debug_print('overshippable qty :'||l_over_shippable_qty);
             END IF;
             l_available_quantity := l_available_quantity + l_over_shippable_qty ;
           EXCEPTION
           WHEN no_data_found THEN
              IF (l_debug = 1) THEN
                  debug_print('Querying overship tolerance ,No record found for line_id = ' || p_demand_source_line_id);
                  debug_print('This may be because not all qty is staged for this line');
              END IF;
           END;
        END IF;

        /*8983636-ends*/


	IF (l_rsv_primary_uom_code IS NULL) THEN
	   l_rsv_primary_uom_code := p_primary_uom_code;
	   IF (l_rsv_primary_uom_code IS NULL) THEN
	      BEGIN
		 SELECT primary_uom_code INTO l_rsv_primary_uom_code FROM
		   mtl_system_items WHERE organization_id = p_organization_id
		   AND inventory_item_id = p_item_id;
	      EXCEPTION WHEN no_data_found THEN
		 IF (l_debug = 1) THEN
		    debug_print('Cannot find the primary unit of measure');
		 END IF;
		  FND_MESSAGE.SET_NAME('INV', 'INV_UOM_NOTFOUND');
                  FND_MSG_PUB.ADD;
                  RAISE fnd_api.g_exc_error;
	      END;
	   END IF;

	END IF;

     IF(  l_rsv_secondary_uom_code is null) then
       l_rsv_secondary_uom_code:=  l_order_quantity_uom2;
    END IF;

        IF (l_order_quantity_uom_code <> l_rsv_primary_uom_code) THEN
           l_primary_available_qty := inv_convert.inv_um_convert
                                      (
                                         item_id            => p_item_id
                                       , lot_number         => null
                                       , organization_id    => p_organization_id
                                       , precision          => null
                                       , from_quantity      => l_available_quantity
                                       , from_unit          => l_order_quantity_uom_code
                                       , to_unit            => l_rsv_primary_uom_code
                                       , from_name          => null
                                       , to_name            => null
                                      );
        ELSE
           l_primary_available_qty := l_available_quantity;
        END IF;

        IF (l_debug = 1) THEN
            debug_print('l_available_quantity = ' || l_available_quantity);
            debug_print('l_primary_available_qty = ' || l_primary_available_qty);
	    debug_print('l_available_quantity2 = ' || l_available_quantity2);
        END IF;

        /* Start bug# 8807194 : Calculating the available to reserve quantity as ordered qty - reserved qty - wdd picked qty
           This is done for all the cases wherein wdd is pick released/shipped but there are no staged reservations.
           For example, staging transfer to a non reservable subinventory */

        BEGIN
           SELECT nvl((Sum(wdd.picked_quantity)),0), wdd.requested_quantity_uom
		    ,nvl((Sum(wdd.picked_quantity2)),0)
           INTO l_wdd_picked_qty, l_wdd_uom_code
		    ,l_wdd_picked_qty2
           FROM wsh_delivery_details wdd
           WHERE wdd.source_line_id =  p_demand_source_line_id
           AND wdd.released_status IN ('Y','C')
           AND NOT EXISTS
                (
                 SELECT 1 FROM mtl_reservations mr
                 WHERE mr.demand_source_line_id = wdd.source_line_id
                 AND nvl(mr.staged_flag, 'N') = 'Y'
                 AND mr.inventory_item_id = wdd.inventory_item_id
                 AND mr.organization_id = wdd.organization_id
                 AND nvl(mr.subinventory_code, '@@@') = nvl(wdd.subinventory, '@@@')
                 AND nvl(mr.locator_id, -999) = nvl(wdd.locator_id, -999)
                 AND nvl(mr.lot_number, '@@@') = nvl(wdd.lot_number, '@@@')
               )
           AND NOT EXISTS (SELECT 1 from mtl_parameters
                           WHERE organization_id = wdd.organization_id
                           AND NVL(wms_enabled_flag,'N') = 'Y')       --Bug 9036307
           GROUP BY wdd.requested_quantity_uom ;

        EXCEPTION
           WHEN no_data_found THEN
              l_wdd_picked_qty := 0;
              IF (l_debug = 1) THEN
                  debug_print('No delivery detail found which is staged/shipped and doesnt have staged reservation associated with the line_id = '
                              || p_demand_source_line_id);
              END IF;
        END;

        IF (l_wdd_uom_code IS NOT NULL AND l_wdd_uom_code <> l_rsv_primary_uom_code) THEN
           l_primary_wdd_picked_qty := inv_convert.inv_um_convert
                                      (
                                         item_id            => p_item_id
                                       , lot_number         => null
                                       , organization_id    => p_organization_id
                                       , precision          => null
                                       , from_quantity      => l_wdd_picked_qty
                                       , from_unit          => l_wdd_uom_code
                                       , to_unit            => l_rsv_primary_uom_code
                                       , from_name          => null
                                       , to_name            => null
                                      );
        ELSE
           l_primary_wdd_picked_qty := l_wdd_picked_qty;
        END IF;

        IF (l_debug = 1) THEN
            debug_print('l_wdd_picked_qty = ' || l_wdd_picked_qty);
            debug_print('l_primary_wdd_picked_qty = ' || l_primary_wdd_picked_qty);
	   debug_print('l_wdd_picked_qty2 = ' || l_wdd_picked_qty2);
        END IF;

        /* End bug# 8807194 */


        IF (p_demand_source_line_detail is not NULL AND p_demand_source_line_detail <> fnd_api.g_miss_num) THEN

            IF (l_debug = 1) THEN
                debug_print('p_demand_source_line_detail is not NULL AND p_demand_source_line_detail <> fnd_api.g_miss_num');
            END IF;

            l_wdd_available_qty := nvl(l_wdd_primary_quantity,0) - nvl(l_wdd_primary_reserved_qty,0);
            l_order_available_qty := nvl(l_primary_available_qty,0) - nvl(l_primary_reserved_quantity,0);

	    l_wdd_available_qty2 := nvl(l_wdd_secondary_quantity,0) - nvl(l_wdd_secondary_reserved_qty,0);
            l_order_available_qty2 := nvl(l_available_quantity2,0) - nvl(l_secondary_reserved_quantity,0);

            IF (l_debug = 1) THEN
                debug_print('l_wdd_available_qty = ' || l_wdd_available_qty);
                debug_print('l_order_available_qty = ' || l_order_available_qty);
	        debug_print('l_wdd_available_qty2 = ' || l_wdd_available_qty2);
                debug_print('l_order_available_qty2 = ' || l_order_available_qty2);
            END IF;

            IF (l_wdd_available_qty < l_order_available_qty) THEN
                l_qty_available_to_reserve := l_wdd_available_qty;
            ELSE
                l_qty_available_to_reserve := l_order_available_qty;
            END IF;
	   --
	   IF (l_wdd_available_qty2 < l_order_available_qty2) THEN
                l_qty_available_to_reserve2 := l_wdd_available_qty2;
            ELSE
                l_qty_available_to_reserve2 := l_order_available_qty2;
            END IF;
        ELSE
            --l_qty_available_to_reserve := nvl(l_primary_available_qty,0) - nvl(l_primary_reserved_quantity,0);
            /* Bug# 8807194: Commented the above calculation and rewrote it below. Reduced l_primary_wdd_picked_qty as well to
               get the l_qty_available_to_reserve */
	        l_qty_available_to_reserve := nvl(l_primary_available_qty,0) - nvl(l_primary_reserved_quantity,0) - nvl(l_primary_wdd_picked_qty,0) ;
		l_qty_available_to_reserve2 := nvl(l_available_quantity2,0) - nvl(l_secondary_reserved_quantity,0) - nvl(l_wdd_secondary_reserved_qty,0) ;
        END IF;

        IF (l_debug = 1) THEN
            debug_print('l_qty_available_to_reserve = ' || l_qty_available_to_reserve);
  	    debug_print('l_qty_available_to_reserve2 = ' || l_qty_available_to_reserve2);
        END IF;

    END IF; -- end of if WIP demand source

    IF (l_debug = 1) THEN
        debug_print('l_qty_available_to_reserve = ' || l_qty_available_to_reserve);
        debug_print('l_primary_available_qty = ' || l_primary_available_qty);
        debug_print('l_return_status = ' || l_return_status);
	debug_print('l_qty_available_to_reserve2 = ' || l_qty_available_to_reserve2);
        debug_print('l_available_quantity2 = ' || l_available_quantity2);
    END IF;

    x_qty_available_to_reserve := l_qty_available_to_reserve;
    x_qty_available := nvl(l_primary_available_qty, 0);

    x_qty_available_to_reserve2 := l_qty_available_to_reserve2;
    x_qty_available2 := nvl(l_available_quantity2, 0);

    x_return_status := l_return_status;
  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        --
     WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        --
     WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        --
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
                , 'available_demand_to_reserve'
                );
        END IF;
        --

  END available_demand_to_reserve;

END inv_reservation_avail_pvt;

/
