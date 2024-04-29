--------------------------------------------------------
--  DDL for Package Body INV_RESERVATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RESERVATION_PVT" AS
  /* $Header: INVRSV3B.pls 120.59.12010000.34 2013/02/28 09:33:36 avrose ship $*/
  --
  g_pkg_name CONSTANT VARCHAR2(30) := 'Inv_reservation_pvt';
  g_pkg_version CONSTANT VARCHAR2(100) := '$Header: INVRSV3B.pls 120.59.12010000.34 2013/02/28 09:33:36 avrose ship $';

  --
  TYPE query_cur_ref_type IS REF CURSOR;

  g_is_pickrelease_set NUMBER;
  g_debug NUMBER;
  -- Added the below 3 variables for Bug Fix 5264987
  g_oe_line_id	NUMBER;
  g_project_id	NUMBER;
  g_task_id	NUMBER;
  g_sch_mat_id NUMBER;  /* Added for bug 13829182 */

  --
  -- procedure to print a message to dbms_output
  -- disable by default since dbm_s_output.put_line is not allowed
  PROCEDURE debug_print(p_message IN VARCHAR2, p_level IN NUMBER := 9) IS
     --Bug: 3559328: Performance bug fix.The fnd call happens everytime
     -- debug_print is called.
    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    inv_log_util.TRACE(p_message, 'INV_RESERVATION_PVT', p_level);
  END debug_print;

  --
  PROCEDURE print_rsv_rec(p_rsv_rec IN inv_reservation_global.mtl_reservation_rec_type) IS
    l_debug number;
  BEGIN
     -- Bug 2944896 -- Commenting out the parameters which may have
     -- g_miss_char as the default value. This leads to truncation of the
     -- log file.
     --Bug 2955454. Removing the commented section. The values are printing
     -- correctly even if it is g_miss_char.
    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;
    IF (l_debug = 1) THEN
       debug_print('reservation_id              : '|| TO_CHAR(p_rsv_rec.reservation_id));
       debug_print('requirement_date            : '|| TO_CHAR(p_rsv_rec.requirement_date, 'YYYY/MM/DD'));
       debug_print('organization_id             : '|| TO_CHAR(p_rsv_rec.organization_id));
       debug_print('inventory_item_id           : '|| TO_CHAR(p_rsv_rec.inventory_item_id));
       debug_print('demand_source_type_id       : '|| TO_CHAR(p_rsv_rec.demand_source_type_id));
       debug_print('demand_source_name          : '|| p_rsv_rec.demand_source_name);
       debug_print('demand_source_header_id     : '|| TO_CHAR(p_rsv_rec.demand_source_header_id));
       debug_print('demand_source_line_id       : '|| TO_CHAR(p_rsv_rec.demand_source_line_id));
       debug_print('demand_source_line_detail   : '|| TO_CHAR(p_rsv_rec.demand_source_line_detail));
       debug_print('primary_uom_code            : '|| p_rsv_rec.primary_uom_code);
       debug_print('primary_uom_id              : '|| TO_CHAR(p_rsv_rec.primary_uom_id));
       debug_print('reservation_uom_code        : '|| p_rsv_rec.reservation_uom_code);
       debug_print('reservation_uom_id          : '|| TO_CHAR(p_rsv_rec.reservation_uom_id));
       debug_print('secondary_uom_code          : '|| p_rsv_rec.secondary_uom_code);
       debug_print('secondary_uom_id            : '|| TO_CHAR(p_rsv_rec.secondary_uom_id));
       debug_print('reservation_quantity        : '|| TO_CHAR(p_rsv_rec.reservation_quantity));
       debug_print('primary_reservation_quantity: '|| TO_CHAR(p_rsv_rec.primary_reservation_quantity));
       debug_print('secondary_reservation_quantity: '|| TO_CHAR(p_rsv_rec.secondary_reservation_quantity));
       debug_print('detailed_quantity: '|| TO_CHAR(p_rsv_rec.detailed_quantity));
       debug_print('secondary_detailed_quantity: '|| TO_CHAR(p_rsv_rec.secondary_detailed_quantity));
       debug_print('autodetail_group_id         : '|| TO_CHAR(p_rsv_rec.autodetail_group_id));
       debug_print('external_source_code        : '|| p_rsv_rec.external_source_code);
       debug_print('external_source_line_id     : '|| TO_CHAR(p_rsv_rec.external_source_line_id));
       debug_print('supply_source_type_id       : '|| TO_CHAR(p_rsv_rec.supply_source_type_id));
       debug_print('supply_source_header_id     : '|| TO_CHAR(p_rsv_rec.supply_source_header_id));
       debug_print('supply_source_line_id       : '|| TO_CHAR(p_rsv_rec.supply_source_line_id));
       debug_print('supply_source_name          : '|| (p_rsv_rec.supply_source_name));
       debug_print('supply_source_line_detail   : '|| TO_CHAR(p_rsv_rec.supply_source_line_detail));
       debug_print('revision                    : '|| p_rsv_rec.revision);
       debug_print('subinventory_code           : '|| p_rsv_rec.subinventory_code);
       debug_print('subinventory_id             : '|| TO_CHAR(p_rsv_rec.subinventory_id));
       debug_print('locator_id                  : '|| TO_CHAR(p_rsv_rec.locator_id));
       debug_print('lot_number                  : '|| p_rsv_rec.lot_number);
       debug_print('lot_number_id               : '|| TO_CHAR(p_rsv_rec.lot_number_id));
       debug_print('pick_slip_number            : '|| TO_CHAR(p_rsv_rec.pick_slip_number));
       debug_print('lpn_id                      : '|| TO_CHAR(p_rsv_rec.lpn_id));
       debug_print('ship_ready_flag             : '|| TO_CHAR(p_rsv_rec.ship_ready_flag));
       debug_print('staged_flag                 : '|| p_rsv_rec.staged_flag);
    END IF;
  END print_rsv_rec;


  -- helper procedure to get requested qty of wdd or order quantity from sales order
  PROCEDURE get_requested_qty
          ( p_demand_source_type_id     IN NUMBER
          , p_demand_source_header_id   IN NUMBER
          , p_demand_source_line_id     IN NUMBER
          , p_demand_source_line_detail IN NUMBER
          , p_project_id                IN NUMBER
          , p_task_id                   IN NUMBER
          , x_requested_qty             OUT NOCOPY NUMBER
	  , x_requested_qty2            OUT NOCOPY NUMBER
          )
  IS
    l_debug         NUMBER;
    l_requested_qty NUMBER := 0;
    l_requested_qty2 NUMBER := 0;
  BEGIN

    IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
       debug_print('In get_requested_qty');
       debug_print('p_demand_source_type_id = ' || p_demand_source_type_id);
       debug_print('p_demand_source_header_id = ' || p_demand_source_header_id);
       debug_print('p_demand_source_line_id = ' || p_demand_source_line_id);
       debug_print('p_demand_source_line_detail = ' || p_demand_source_line_detail);
       debug_print('p_project_id = ' || p_project_id);
       debug_print('p_task_id = ' || p_task_id);
    END IF;

    IF (p_demand_source_line_detail IS NOT NULL) THEN
      BEGIN
	 IF (l_debug = 1) THEN
	    debug_print('Inside source line as not null');
	 END IF;
	 SELECT   nvl(sum(requested_quantity),0) ,nvl(sum(requested_quantity2),0)
	   INTO   l_requested_qty ,l_requested_qty2
	   FROM   wsh_delivery_details
	   WHERE  source_line_id = p_demand_source_line_id
	   AND    delivery_detail_id = p_demand_source_line_detail;

      EXCEPTION
	 WHEN OTHERS THEN
	    l_requested_qty := 0;
	    l_requested_qty2:=0;
	    IF (l_debug = 1) THEN
	       debug_print('Exception in finding wdd');
	    END IF;
      END;
    ELSE
      BEGIN
	 SELECT   ordered_quantity , ordered_quantity2
	   INTO   l_requested_qty ,l_requested_qty2
	   FROM   oe_order_lines_all
	   WHERE  line_id = p_demand_source_line_id
           AND    nvl(project_id, -99) = nvl(p_project_id, -99)
           AND    nvl(task_id, -99) = nvl(p_task_id, -99);

      EXCEPTION
	 WHEN no_data_found THEN
	    l_requested_qty := 0;
	    l_requested_qty2 :=0;
	    IF (l_debug = 1) THEN
	       debug_print('No order line found');
	    END IF;
      END;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('l_requested_qty = ' || l_requested_qty);
       debug_print('l_requested_qty2 = ' || l_requested_qty2);
    END IF;

    x_requested_qty := l_requested_qty;
   x_requested_qty2 := l_requested_qty2;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        IF (l_debug = 1) THEN
            debug_print('excepted error');
        END IF;
        x_requested_qty := 0;
	x_requested_qty2 := 0;
        --
    WHEN fnd_api.g_exc_unexpected_error THEN
        IF (l_debug = 1) THEN
            debug_print('unexpected error');
        END IF;
        x_requested_qty := 0;
	x_requested_qty2 := 0;
        --
    WHEN OTHERS THEN
        IF (l_debug = 1) THEN
            debug_print('others error');
        END IF;
        x_requested_qty := 0;
	x_requested_qty2 := 0;

  END get_requested_qty;

--Bug 12978409: start
 	   PROCEDURE get_reservation_qty_lot(
 	             p_rsv_rec IN inv_reservation_global.mtl_reservation_rec_type,
 	             p_reservation_qty_lot OUT NOCOPY NUMBER)

 	     IS
 	         l_return_value BOOLEAN;
 	         l_mo_line mtl_txn_request_lines%ROWTYPE;
 	         l_debug  NUMBER;
 	         is_debug Boolean;
 	         l_lot_rsv_qty_order_uom NUMBER := 0;
 	         l_lot_primary_rsv_qty NUMBER := 0;
 	         l_lot_conv_factor_flag NUMBER := 0;
                 l_fulfill_base	VARCHAR2(1) := 'P'; -- MUOM fulfillment Project
                 l_lot_secondary_rsv_qty NUMBER := 0;-- MUOM fulfillment Project

 	         CURSOR check_if_lot_conv_exists(p_lot_number varchar2, p_inventory_item_id number, p_organization_id number)  IS
 	         SELECT count(*)
 	         FROM mtl_lot_uom_class_conversions
 	         WHERE lot_number      = p_rsv_rec.lot_number
 	         AND inventory_item_id = p_rsv_rec.inventory_item_id
 	         AND organization_id   = p_rsv_rec.organization_id
 	         AND (disable_date IS NULL or disable_date > sysdate);


 	   BEGIN

 	       IF (g_debug IS NULL) THEN
 	         g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 	       END IF;

 	     l_debug := g_debug;

 	     IF (l_debug = 1) THEN
 	        debug_print('In get_reservation_qty_lot ');
 	     END IF;

	-- MUOM fulfillment Project
 	       inv_utilities.get_inv_fulfillment_base(
                          p_source_line_id		=> p_rsv_rec.demand_source_line_id,
                          p_demand_source_type_id	=> p_rsv_rec.demand_source_type_id,
                          p_org_id				=> p_rsv_rec.organization_id,
                          x_fulfillment_base		=> l_fulfill_base
                            );

	 IF (l_debug = 1) THEN
            debug_print('get_reservation_qty_lot l_fulfill_base: = '||l_fulfill_base);
          END IF ;

         IF (l_fulfill_base = 'S') THEN
             p_reservation_qty_lot  := p_rsv_rec.secondary_reservation_quantity;
         ELSE
 	       p_reservation_qty_lot  := p_rsv_rec.primary_reservation_quantity;
 	 END IF;
         -- MUOM fulfillment Project

 	       l_return_value := inv_cache.set_item_rec( p_rsv_rec.organization_id, p_rsv_rec.inventory_item_id);
 	       IF NOT l_return_value THEN
 	         IF (l_debug = 1) THEN
 	             debug_print('error occurred while setting inv_cache.set_item_rec');
 	         END IF;
 	         RAISE fnd_api.g_exc_unexpected_error;
 	       End IF;


 	       IF p_rsv_rec.lot_number is NULL OR
 	       inv_cache.item_rec.lot_control_code <> 2 OR
 	       inv_cache.item_rec.primary_uom_code = p_rsv_rec.reservation_uom_code THEN
 	         IF (l_debug = 1) THEN
 	               debug_print('either item is not lot controlled or or lot num is null or rsv uom is same as prim uom. return');
 	         END IF;

 	         RETURN;
 	       END IF;

 	          IF (l_debug = 1) THEN
 	                 debug_print('p_rsv_rec.inventory_item_id           :' || p_rsv_rec.inventory_item_id);
 	                 debug_print('p_rsv_rec.organization_id             :' || p_rsv_rec.organization_id);
 	                 debug_print('inv_cache.item_rec.primary_uom_code :' || inv_cache.item_rec.primary_uom_code);
 	                 debug_print('p_rsv_rec.reservation_uom_code :' ||p_rsv_rec.reservation_uom_code);
 	                 debug_print('p_rsv_rec.lot_number :' ||p_rsv_rec.lot_number);
 	         END IF;

 	                 OPEN  check_if_lot_conv_exists(p_rsv_rec.lot_number, p_rsv_rec.inventory_item_id, p_rsv_rec.organization_id);
 	                 FETCH check_if_lot_conv_exists into l_lot_conv_factor_flag;
 	                 CLOSE check_if_lot_conv_exists;

 	                 IF (l_debug = 1) THEN
 	                         debug_print('l_lot_conv_factor_flag :' || l_lot_conv_factor_flag );
 	                 END IF;

 	        IF l_lot_conv_factor_flag > 0 THEN
                     IF (l_fulfill_base = 'S') THEN   -- MUOM fulfillment Project
                       l_lot_rsv_qty_order_uom  := inv_convert.inv_um_convert(
 	                             item_id          => p_rsv_rec.inventory_item_id
 	                           , lot_number       => p_rsv_rec.lot_number
 	                           , organization_id  => p_rsv_rec.organization_id
 	                           , precision        => null
 	                           , from_quantity    => p_rsv_rec.secondary_reservation_quantity
 	                           , from_unit        => inv_cache.item_rec.secondary_uom_code
 	                           , to_unit          => p_rsv_rec.reservation_uom_code
 	                           , from_name        => null
 	                           , to_name          => null
 	                            );

 	                         IF (l_debug = 1) THEN
 	                               debug_print('Allocated qty with lots in order uom (honoring lot conversion) when fulfilment base is S :' || l_lot_rsv_qty_order_uom);
 	                         END IF;

 	                     l_lot_secondary_rsv_qty  := inv_convert.inv_um_convert(
 	                             item_id          => p_rsv_rec.inventory_item_id
 	                           , organization_id  => p_rsv_rec.organization_id
 	                           , precision        => null
 	                           , from_quantity => l_lot_rsv_qty_order_uom
 	                           , from_unit      =>  p_rsv_rec.reservation_uom_code
 	                           , to_unit          =>  inv_cache.item_rec.secondary_uom_code
 	                           , from_name   => null
 	                           , to_name       => null
 	                            );

 	                       p_reservation_qty_lot :=  l_lot_secondary_rsv_qty;

 	                          IF (l_debug = 1) THEN
 	                              debug_print('l_lot_secondary_rsv_qty when fulfilment Base is S :' ||  l_lot_secondary_rsv_qty);
 	                         END IF;
                     ELSE
                       l_lot_rsv_qty_order_uom  := inv_convert.inv_um_convert(
 	                             item_id          => p_rsv_rec.inventory_item_id
 	                           , lot_number    => p_rsv_rec.lot_number
 	                           , organization_id  => p_rsv_rec.organization_id
 	                           , precision        => null
 	                           , from_quantity   => p_rsv_rec.primary_reservation_quantity
 	                           , from_unit        => inv_cache.item_rec.primary_uom_code
 	                           , to_unit          => p_rsv_rec.reservation_uom_code
 	                           , from_name   => null
 	                           , to_name       => null
 	                            );

 	                          IF (l_debug = 1) THEN
 	                                 debug_print('allocated qty with lots in order uom (honoring lot conversion) :' || l_lot_rsv_qty_order_uom);
 	                         END IF;

 	                     l_lot_primary_rsv_qty  := inv_convert.inv_um_convert(
 	                             item_id          => p_rsv_rec.inventory_item_id
 	                           , organization_id  => p_rsv_rec.organization_id
 	                           , precision        => null
 	                           , from_quantity    => l_lot_rsv_qty_order_uom
 	                           , from_unit        =>  p_rsv_rec.reservation_uom_code
 	                           , to_unit          =>  inv_cache.item_rec.primary_uom_code
 	                           , from_name        => null
 	                           , to_name          => null
 	                            );

 	                       p_reservation_qty_lot :=  l_lot_primary_rsv_qty;

 	                          IF (l_debug = 1) THEN
 	                                 debug_print('l_lot_primary_rsv_qty  :' ||  l_lot_primary_rsv_qty );
 	                         END IF;
 	                  END IF;  -- MUOM fulfillment Project
                   END IF;

 	                 IF (l_debug = 1) THEN
 	                      debug_print('p_reservation_qty_lot :' ||  p_reservation_qty_lot );
 	                 END IF;


 	   EXCEPTION
 	   WHEN OTHERS THEN
 	          IF (l_debug = 1) THEN
 	                   debug_print('Exception Occurred at get_reservation_qty_lot');
 	         END IF;

 	   END get_reservation_qty_lot;

 	 --Bug 12978409: end

  -- helper procedure called from update_reservation and
  -- transfer_reservation to get available to reserve qty
  -- for the supply source.
  PROCEDURE get_supply_reservable_qty
    ( x_return_status                OUT NOCOPY VARCHAR2
      , x_msg_count                    OUT NOCOPY NUMBER
      , x_msg_data                     OUT NOCOPY VARCHAR2
      , p_fm_supply_source_type_id     IN NUMBER
      , p_fm_supply_source_header_id   IN NUMBER
      , p_fm_supply_source_line_id     IN NUMBER
      , p_fm_supply_source_line_detail IN NUMBER
      , p_fm_primary_reservation_qty   IN NUMBER
      , p_to_supply_source_type_id     IN NUMBER
      , p_to_supply_source_header_id   IN NUMBER
      , p_to_supply_source_line_id     IN NUMBER
      , p_to_supply_source_line_detail IN NUMBER
      , p_to_primary_reservation_qty   IN NUMBER
      , p_to_organization_id           IN NUMBER
      , p_to_inventory_item_id         IN NUMBER
      , p_to_revision                  IN VARCHAR2
      , p_to_lot_number                IN VARCHAR2
      , p_to_subinventory_code         IN VARCHAR2
      , p_to_locator_id                IN NUMBER
      , p_to_lpn_id                    IN NUMBER
    , p_to_project_id                IN NUMBER
    , p_to_task_id                   IN NUMBER
    , x_reservable_qty               OUT NOCOPY NUMBER
    , x_qty_available                OUT NOCOPY NUMBER
    )
    IS
       l_debug                    NUMBER;
       l_qty_available_to_reserve NUMBER;
       l_qty_available            NUMBER;
       l_reservable_qty           NUMBER;
  BEGIN

     IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;

     IF (l_debug = 1) THEN
	debug_print('In get_supply_reservable_qty');
	debug_print('Orig supply source type id = ' || p_fm_supply_source_type_id);
	debug_print('Orig supply source header id = ' || p_fm_supply_source_header_id);
	debug_print('Orig supply source line id = ' || p_fm_supply_source_line_id);
	debug_print('Orig supply line detail  = ' || p_fm_supply_source_line_detail);
	debug_print('Orig primary qty = ' || p_fm_primary_reservation_qty);
	debug_print('To supply source type id = ' || p_to_supply_source_type_id);
	debug_print('To supply source header id = ' || p_to_supply_source_header_id);
	debug_print('To supply source line id = ' || p_to_supply_source_line_id);
	debug_print('To supply line detail = ' || p_to_supply_source_line_detail);
	debug_print('To primary qty = ' || p_to_primary_reservation_qty);
     END IF;

     inv_reservation_avail_pvt.available_supply_to_reserve
      (
       x_return_status                 => x_return_status
       , x_msg_count                     => x_msg_count
       , x_msg_data                      => x_msg_data
       , x_qty_available_to_reserve      => l_qty_available_to_reserve
       , x_qty_available                 => l_qty_available
       , p_organization_id               => p_to_organization_id
       , p_item_id                       => p_to_inventory_item_id
       , p_revision                      => p_to_revision
       , p_lot_number                    => p_to_lot_number
       , p_subinventory_code             => p_to_subinventory_code
       , p_locator_id                    => p_to_locator_id
       , p_lpn_id                        => p_to_lpn_id
       , p_fm_supply_source_type_id      => p_fm_supply_source_type_id
       , p_supply_source_type_id         => p_to_supply_source_type_id
       , p_supply_source_header_id       => p_to_supply_source_header_id
       , p_supply_source_line_id         => p_to_supply_source_line_id
       , p_supply_source_line_detail     => Nvl(p_to_supply_source_line_detail,fnd_api.g_miss_num)
       , p_project_id                    => p_to_project_id
       , p_task_id                       => p_to_task_id
       , p_api_version_number            => 1.0
       , p_init_msg_lst                  => fnd_api.g_false
       );

     IF (l_debug = 1) THEN
	debug_print('After calling available supply to reserve ' || x_return_status);
	debug_print('Available quantity to reserve. l_qty_available_to_reserve: ' || l_qty_available_to_reserve);
	debug_print('Available quantity on the document. l_qty_available: ' || l_qty_available);
     END IF;

     --
     IF x_return_status = fnd_api.g_ret_sts_error THEN
	RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (p_fm_supply_source_type_id = p_to_supply_source_type_id AND
	p_fm_supply_source_header_id = p_to_supply_source_header_id AND
	nvl(p_fm_supply_source_line_id, -1) = nvl(p_to_supply_source_line_id, -1) AND
	nvl(p_fm_supply_source_line_detail, -1) = nvl(p_to_supply_source_line_detail, -1)) THEN

       -- if supply of orig and to record is the same, we need to add the qty from orig
       -- record to the reservable qty because we're transfering to same supply source
       l_reservable_qty := nvl(l_qty_available_to_reserve,0) + p_fm_primary_reservation_qty;

     ELSE
       -- if transfer reservation from other supply to receiving, the total qty in rcv
       -- will increase, so we need to add the qty from orig record to the reservable qty
       IF (p_to_supply_source_type_id = inv_reservation_global.g_source_type_rcv) THEN
          l_reservable_qty := nvl(l_qty_available_to_reserve,0) + p_fm_primary_reservation_qty;
	ELSE
          l_reservable_qty := nvl(l_qty_available_to_reserve,0);
       END IF;

    END IF;

    x_reservable_qty := l_reservable_qty;
    x_qty_available := l_qty_available;

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
	x_return_status  := fnd_api.g_ret_sts_error;
	x_reservable_qty := 0;
	x_qty_available := 0;
	--
     WHEN fnd_api.g_exc_unexpected_error THEN
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	x_reservable_qty := 0;
	x_qty_available := 0;
	--
     WHEN OTHERS THEN
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	x_reservable_qty := 0;
	x_qty_available := 0;
	--
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'get_supply_reservable_qty');
      END IF;

  END get_supply_reservable_qty;

  -- helper procedure called from update_reservation and
  -- transfer_reservation to get available to reserve qty
  -- for the demand source
  PROCEDURE get_demand_reservable_qty
    ( x_return_status                OUT NOCOPY VARCHAR2
      , x_msg_count                    OUT NOCOPY NUMBER
      , x_msg_data                     OUT NOCOPY VARCHAR2
      , p_fm_demand_source_type_id     IN NUMBER
      , p_fm_demand_source_header_id   IN NUMBER
      , p_fm_demand_source_line_id     IN NUMBER
      , p_fm_demand_source_line_detail IN NUMBER
      , p_fm_primary_reservation_qty   IN NUMBER
      , p_fm_secondary_reservation_qty   IN NUMBER
      , p_to_demand_source_type_id     IN NUMBER
      , p_to_demand_source_header_id   IN NUMBER
      , p_to_demand_source_line_id     IN NUMBER
      , p_to_demand_source_line_detail IN NUMBER
      , p_to_primary_reservation_qty   IN NUMBER
      , p_to_organization_id           IN NUMBER
      , p_to_inventory_item_id         IN NUMBER
      , p_to_primary_uom_code          IN VARCHAR
      , p_to_project_id                IN NUMBER
      , p_to_task_id                   IN NUMBER
      , x_reservable_qty               OUT NOCOPY NUMBER
      , x_qty_available                OUT NOCOPY NUMBER
      , x_reservable_qty2               OUT NOCOPY NUMBER
      , x_qty_available2                OUT NOCOPY NUMBER
      )
    IS
       l_debug                    NUMBER;
       l_reservable_qty           NUMBER;
       l_qty_available_to_reserve NUMBER;
       l_qty_available            NUMBER;
       l_requested_qty            NUMBER;
       l_reservation_margin_above NUMBER;
	    -- MUOM Fulfillement project
       l_fulfill_base	VARCHAR2(1) := 'P';
       l_qty_available_to_reserve2 NUMBER;
       l_qty_available2           NUMBER;
       l_reservable_qty2          NUMBER;
       l_requested_qty2           NUMBER;
  BEGIN

    IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
       debug_print('In get_demand_reservable_qty');
       debug_print('Orig demand source type id = ' || p_fm_demand_source_type_id);
       debug_print('Orig demand source header id = ' || p_fm_demand_source_header_id);
       debug_print('Orig demand source line id = ' || p_fm_demand_source_line_id);
       debug_print('Orig demand line detail  = ' || p_fm_demand_source_line_detail);
       debug_print('Orig primary qty = ' || p_fm_primary_reservation_qty);
       debug_print('To demand source type id = ' || p_to_demand_source_type_id);
       debug_print('To demand source header id = ' || p_to_demand_source_header_id);
       debug_print('To demand source line id = ' || p_to_demand_source_line_id);
       debug_print('To demand line detail = ' || p_to_demand_source_line_detail);
       debug_print('To primary qty = ' || p_to_primary_reservation_qty);
       debug_print('To primary uom code = ' || p_to_primary_uom_code);
    END IF;

    inv_reservation_avail_pvt.available_demand_to_reserve
      (
       x_return_status                 => x_return_status
       , x_msg_count                     => x_msg_count
       , x_msg_data                      => x_msg_data
       , x_qty_available_to_reserve      => l_qty_available_to_reserve
       , x_qty_available                 => l_qty_available
       , x_qty_available_to_reserve2   => l_qty_available_to_reserve2
       , x_qty_available2                 => l_qty_available2
       , p_organization_id               => p_to_organization_id
       , p_item_id                       => p_to_inventory_item_id
       , p_primary_uom_code             => p_to_primary_uom_code
       , p_demand_source_type_id      => p_to_demand_source_type_id
       , p_demand_source_header_id   => p_to_demand_source_header_id
       , p_demand_source_line_id         => p_to_demand_source_line_id
       , p_demand_source_line_detail     => Nvl(p_to_demand_source_line_detail,fnd_api.g_miss_num)
       , p_project_id                    => p_to_project_id
       , p_task_id                       => p_to_task_id
       , p_api_version_number            => 1.0
       , p_init_msg_lst                  => fnd_api.g_false
       );


    IF (l_debug = 1) THEN
       debug_print('After calling available demand to reserve ' || x_return_status);
       debug_print('Available quantity to reserve. l_qty_available_to_reserve: ' || l_qty_available_to_reserve);
       debug_print('Available quantity on the document. l_qty_available: ' || l_qty_available);
       debug_print('Available quantity to reserve. l_qty_available_to_reserve2: ' || l_qty_available_to_reserve2);
       debug_print('Available quantity on the document. l_qty_available2: ' || l_qty_available2);
    END IF;

    --
    IF x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (p_fm_demand_source_type_id = p_to_demand_source_type_id AND
	p_fm_demand_source_header_id = p_to_demand_source_header_id AND
	nvl(p_fm_demand_source_line_id, -1) = nvl(p_to_demand_source_line_id, -1) AND
       nvl(p_fm_demand_source_line_detail, -1) = nvl(p_to_demand_source_line_detail, -1)) THEN

       -- if demand of orig and to record is the same, we need to add the qty from orig
       -- record to the reservable qty because we're transfering to same demand source
       l_reservable_qty := l_qty_available_to_reserve + p_fm_primary_reservation_qty;
       l_reservable_qty2 := l_qty_available_to_reserve2 +nvl(p_fm_secondary_reservation_qty,0);

     ELSE

       --for sales order or internal order, the reservable qty is the minimum of
       --requested qty of the line detail/line and the reservable qty of the sales order line
       IF (p_to_demand_source_type_id in (inv_reservation_global.g_source_type_oe,
                                          inv_reservation_global.g_source_type_internal_ord,
					  inv_reservation_global.g_source_type_rma) AND
	   p_fm_demand_source_type_id = p_to_demand_source_type_id AND
	   p_fm_demand_source_header_id = p_to_demand_source_header_id AND
	   nvl(p_fm_demand_source_line_id, -1) = nvl(p_to_demand_source_line_id, -1) AND
          nvl(p_fm_demand_source_line_detail, -1) <> nvl(p_to_demand_source_line_detail, -1)) THEN

          get_requested_qty
	    ( p_demand_source_type_id     => p_to_demand_source_type_id
	      , p_demand_source_header_id   => p_to_demand_source_header_id
	      , p_demand_source_line_id     => p_to_demand_source_line_id
	      , p_demand_source_line_detail => p_to_demand_source_line_detail
	      , p_project_id                => p_to_project_id
	      , p_task_id                   => p_to_task_id
	      , x_requested_qty           => l_requested_qty
	      , x_requested_qty2         => l_requested_qty2
	      );


          IF (l_debug = 1) THEN
             debug_print('l_requested_qty = ' || l_requested_qty);
             debug_print('reservable qty = ' || (l_qty_available_to_reserve + p_fm_primary_reservation_qty));
	     debug_print('l_requested_qty2 = ' || l_requested_qty2);
             debug_print('reservable qty2 = ' || (l_qty_available_to_reserve2 + nvl(p_fm_secondary_reservation_qty,0)));
          END IF;

          IF (nvl(l_requested_qty, 0) < (l_qty_available_to_reserve + p_fm_primary_reservation_qty)) THEN
             l_reservable_qty := nvl(l_requested_qty, 0);
	   ELSE
             l_reservable_qty := l_qty_available_to_reserve + p_fm_primary_reservation_qty;
          END IF;

	  IF (nvl(l_requested_qty2, 0) < (l_qty_available_to_reserve2 + p_fm_secondary_reservation_qty)) THEN
             l_reservable_qty2 := nvl(l_requested_qty2, 0);
	     ELSE
             l_reservable_qty2 := l_qty_available_to_reserve2 + p_fm_secondary_reservation_qty;
          END IF;

	ELSE
          l_reservable_qty := l_qty_available_to_reserve;
	  l_reservable_qty2 := l_qty_available_to_reserve2;

       END IF;

    END IF;

    IF (p_to_demand_source_type_id in (inv_reservation_global.g_source_type_oe,
                                          inv_reservation_global.g_source_type_internal_ord,
				       inv_reservation_global.g_source_type_rma)) THEN

       IF NOT (lot_divisible
	       (p_inventory_item_id => p_to_inventory_item_id,
		p_organization_id => p_to_organization_id)) THEN
	  get_ship_qty_tolerance
	    (
	     p_api_version_number          =>  1.0
	     , p_init_msg_lst              =>  fnd_api.g_false
	     , x_return_status             => x_return_status
	     , x_msg_count                 => x_msg_count
	     , x_msg_data                  => x_msg_data
	     , p_demand_type_id            => p_to_demand_source_type_id
	     , p_demand_header_id          => p_to_demand_source_header_id
	     , p_demand_line_id            => p_to_demand_source_line_id
	     , x_reservation_margin_above  => l_reservation_margin_above);

	  IF (l_debug = 1) THEN
	     debug_print('Inside is lot indivisible');
	  END IF;

	  IF (l_debug = 1) THEN
	     debug_print('After calling get_ship_qty_tolerance ' || x_return_status);
	     debug_print('Reservation margin above ' || l_reservation_margin_above);
	  END IF;

	  --
	  IF x_return_status = fnd_api.g_ret_sts_error THEN
	     RAISE fnd_api.g_exc_error;
	  END IF;

	  --
	  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
	     RAISE fnd_api.g_exc_unexpected_error;
	  END IF;

	  --MUOM Fulfillment Project
	  inv_utilities.get_inv_fulfillment_base(
			p_source_line_id		=> p_to_demand_source_line_id,
			p_demand_source_type_id => p_to_demand_source_type_id,
			p_org_id				=> p_to_organization_id,
			x_fulfillment_base		=> l_fulfill_base
			);

	  IF l_fulfill_base <> 'S' THEN
	     l_reservable_qty := l_reservable_qty + l_reservation_margin_above;
	     l_qty_available := l_qty_available + l_reservation_margin_above;
	   ELSE
		  l_reservable_qty2 := l_reservable_qty2 + l_reservation_margin_above;
		  l_qty_available2 := l_qty_available2 + l_reservation_margin_above;
	  END IF;
       END IF;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('reservable qty = ' || l_reservable_qty);
       debug_print('reservable qty2 = ' || l_reservable_qty2);
    END IF;

    x_reservable_qty := l_reservable_qty;
    x_qty_available := l_qty_available;
    x_reservable_qty2 := l_reservable_qty2;
    x_qty_available2 := l_qty_available2;

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
	x_return_status  := fnd_api.g_ret_sts_error;
	x_reservable_qty := 0;
	x_qty_available  := 0;
	x_reservable_qty2 := 0;
	x_qty_available2 := 0;
	--
    WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       x_reservable_qty := 0;
       x_qty_available  := 0;
       x_reservable_qty2 := 0;
       x_qty_available2 := 0;
       --
     WHEN OTHERS THEN
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	x_reservable_qty := 0;
	x_qty_available  := 0;
	x_reservable_qty2 := 0;
	x_qty_available2 := 0;
	--
	IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	   fnd_msg_pub.add_exc_msg(g_pkg_name, 'get_demand_reservable_qty');
      END IF;

  END get_demand_reservable_qty;

 --This procedure will compute the shipping tolerance for sales order,
  -- internal order and RMA and return the quantity in the primary uom of
  -- item
  PROCEDURE get_ship_qty_tolerance
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2  Default Fnd_API.G_False
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_demand_type_id                IN  NUMBER
   , p_demand_header_id              IN  NUMBER
   , p_demand_line_id                IN  NUMBER
   , x_reservation_margin_above      OUT NOCOPY NUMBER                   -- INVCONV
   ) is
      l_api_version_number  CONSTANT NUMBER       := 1.0;
      l_api_name            CONSTANT VARCHAR2(30) := 'get_ship_qty_tolerance';
      l_debug NUMBER;
      l_primary_uom_code  	     	VARCHAR2(3);
      l_ship_tolerance_above            NUMBER;          -- INVCONV
      l_line_rec_inventory_item_id      oe_order_lines_all.inventory_item_id%TYPE;
      l_line_rec_ordered_quantity       oe_order_lines_all.ordered_quantity%TYPE;
      l_line_rec_order_quantity_uom     oe_order_lines_all.order_quantity_uom%TYPE;
      l_line_rec_org_id                 oe_order_lines_all.org_id%TYPE;
      l_ordered_quantity_primary_uom NUMBER;

	  -- MUOM Fulfillment Project
	  l_fulfill_base	VARCHAR2(1) := 'P';
	  l_line_rec_ordered_quantity2  oe_order_lines_all.ordered_quantity2%TYPE;
  BEGIN

     IF (g_debug IS NULL) THEN
	g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;

     -- Initialize return status
     x_return_status := fnd_api.g_ret_sts_success;

     --  Standard call to check for call compatibility
     IF NOT fnd_api.compatible_api_call(l_api_version_number
					, p_api_version_number
					, l_api_name
					, G_PKG_NAME
					) THEN
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     --
     --  Initialize message list.
     IF fnd_api.to_boolean(p_init_msg_lst) THEN
	fnd_msg_pub.initialize;
     END IF;

     IF p_demand_type_id IN (inv_reservation_global.g_source_type_oe,
			     inv_reservation_global.g_source_type_internal_ord,
			     inv_reservation_global.g_source_type_rma) then

	--INVCONV - Retrieve ship tolerance above for lot indivisible scenarios
	BEGIN
	   SELECT inventory_item_id, ordered_quantity, order_quantity_uom, ship_from_org_id,
	     ship_tolerance_above , ordered_quantity2
	     INTO l_line_rec_inventory_item_id,
	     l_line_rec_ordered_quantity,
	     l_line_rec_order_quantity_uom,
	     l_line_rec_org_id,
	     l_ship_tolerance_above,
	     l_line_rec_ordered_quantity2
	     FROM oe_order_lines_all
	     WHERE line_id = p_demand_line_id;
	EXCEPTION
	   WHEN no_data_found THEN
	      IF (l_debug =1) THEN
		 debug_print('could not find the record for sales order line ' || p_demand_line_id);
	      END IF;
	END;

	-- Get primary UOM of the item
	BEGIN
	   select primary_uom_code
	     into l_primary_uom_code
	     from mtl_system_items
	     where organization_id   = l_line_rec_org_id
	     and   inventory_item_id = l_line_rec_inventory_item_id;
	 EXCEPTION
	   WHEN no_data_found THEN
	      IF (l_debug =1) THEN
	debug_print('could not find the record for the item id ' || l_line_rec_inventory_item_id || ' Org ' ||l_line_rec_org_id );
	      END IF;
	END;
	--MUOM Fulfillment Project
	inv_utilities.get_inv_fulfillment_base(
			p_source_line_id		=> p_demand_line_id,
			p_demand_source_type_id => p_demand_type_id,
			p_org_id				=> l_line_rec_org_id,
			x_fulfillment_base		=> l_fulfill_base
			);
	IF l_fulfill_base <> 'S' THEN
	 IF l_primary_uom_code = l_line_rec_order_quantity_uom THEN
	   x_reservation_margin_above := l_line_rec_ordered_quantity * NVL(l_ship_tolerance_above,0) / 100;
	 IF (l_debug =1) THEN
	       debug_print('quantity no convert');
	       debug_print('margin above :' || x_reservation_margin_above);
	   END IF;
	  ELSE -- the uoms are different. convert the order qty into primary
	   -- uom of the ite,

	   -- Convert order quantity into primary uom code
	   l_ordered_quantity_primary_uom :=
	     inv_convert.inv_um_convert
	     (
	      l_line_rec_inventory_item_id,
	      NULL,
	      l_line_rec_ordered_quantity,
	      l_line_rec_order_quantity_uom,
	      l_primary_uom_code,
	      NULL,
	      NULL);

	   x_reservation_margin_above := l_ordered_quantity_primary_uom *
	     NVL(l_ship_tolerance_above,0) / 100;

	   IF (l_debug =1) THEN
	      debug_print('quantity after convert :' || l_ordered_quantity_primary_uom);
	      debug_print('margin above :' || x_reservation_margin_above);
	   END IF;

	 END IF;
	ELSE
		x_reservation_margin_above := l_line_rec_ordered_quantity2 *
			NVL(l_ship_tolerance_above,0) / 100;

		IF (l_debug =1) THEN
			debug_print('margin above for fulfillment S:' || x_reservation_margin_above);
		END IF;

	END IF;

     END IF;
     x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION

     WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
	     , p_data  => x_msg_data
	     , p_encoded => 'F'
           );

     WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
	     , p_data   => x_msg_data
	     , p_encoded => 'F'
	     );

     WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
		, l_api_name
		);
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
	     , p_data   => x_msg_data
	     , p_encoded => 'F'
             );
  END Get_Ship_qty_Tolerance ;

  --
  -- Procedure
  --   convert_quantity
  -- Description
  --   convert quantity from reservation uom to primary uom or
  --   convert quantity from primary uom to reservation uom
  --   and store the quantity in the corresponding field in
  --   the record
  -- Requirement
  --   In px_rsv_rec, inventory_item_id must be valid;
  --   either primary_uom_code, primary_reservation_quantity
  --   or reservation_uom_code, reservation_quantity must be not null and valid
  PROCEDURE convert_quantity(x_return_status OUT NOCOPY VARCHAR2, px_rsv_rec IN OUT NOCOPY inv_reservation_global.mtl_reservation_rec_type) IS
    l_return_status    VARCHAR2(1)                                     := fnd_api.g_ret_sts_success;
    --l_rsv_rec          inv_reservation_global.mtl_reservation_rec_type;
    l_primary_uom_code VARCHAR2(3);
    l_tmp_secondary_quantity     NUMBER                                          := NULL; -- INVCONV
    l_tmp_quantity     NUMBER                                          := NULL;
    l_tracking_quantity_ind VARCHAR2(30);   --INVCONV
   -- MUOM Fulfillment project
    l_fulfill_base   VARCHAR2(1) := 'P';
  BEGIN
    --l_rsv_rec        := px_rsv_rec;

      --
    -- INVCONV - Retrieve secondary uom
    IF px_rsv_rec.primary_uom_code IS NULL or px_rsv_rec.secondary_uom_code IS NULL THEN
       SELECT primary_uom_code, secondary_uom_code,tracking_quantity_ind
         INTO px_rsv_rec.primary_uom_code, px_rsv_rec.secondary_uom_code,l_tracking_quantity_ind
         FROM mtl_system_items
        WHERE inventory_item_id = px_rsv_rec.inventory_item_id
          AND organization_id = px_rsv_rec.organization_id;
    END IF;

    /* it's possible that Secondary UOM is defined for the item but the item is tracked only in Primary */
    IF(l_tracking_quantity_ind <> 'PS')  THEN --INVCONV
      px_rsv_rec.secondary_uom_code := NULL;
      px_rsv_rec.secondary_reservation_quantity := NULL; /*Bug#8444523*/
    END IF;

    --
    --
    -- convert reservation quantity in reservation uom
    -- to primary quantity in primary uom if needed
    IF px_rsv_rec.primary_reservation_quantity IS NULL THEN
      -- get primary uom code for the item and org
      --
      -- compute the primary quantity
      -- INVCONV - upgrade call to inv_um_convert
      l_tmp_quantity                          := inv_convert.inv_um_convert(
                                                   item_id                      => px_rsv_rec.inventory_item_id
                                                 , lot_number                   => px_rsv_rec.lot_number
                                                 , organization_id              => px_rsv_rec.organization_id
                                                 , PRECISION                    => NULL -- use default precision
                                                 , from_quantity                => px_rsv_rec.reservation_quantity
                                                 , from_unit                    => px_rsv_rec.reservation_uom_code
                                                 , to_unit                      => px_rsv_rec.primary_uom_code
                                                 , from_name                    => NULL -- from uom name
                                                 , to_name                      => NULL -- to uom name
                                                 );

      IF l_tmp_quantity = -99999 THEN
        -- conversion failed
        fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-PRIMARY-UOM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      px_rsv_rec.primary_reservation_quantity  := l_tmp_quantity;
    --
    END IF;

--MUOM Fulfillment Project
    inv_utilities.get_inv_fulfillment_base(
               p_source_line_id        => px_rsv_rec.demand_source_line_id,
               p_demand_source_type_id => px_rsv_rec.demand_source_type_id,
               p_org_id                => px_rsv_rec.organization_id,
               x_fulfillment_base      => l_fulfill_base
              );

    --
    -- convert reservation quantity in primary_uom_code
    -- to reservation quantity in reservation uom code if needed
    IF px_rsv_rec.reservation_uom_code IS NULL THEN
      px_rsv_rec.reservation_uom_code  := px_rsv_rec.primary_uom_code;
      px_rsv_rec.reservation_quantity  := px_rsv_rec.primary_reservation_quantity;
    ELSIF  px_rsv_rec.reservation_quantity IS NULL
           AND px_rsv_rec.primary_reservation_quantity IS NOT NULL THEN
      -- if reservation_quantity is missing or both
      -- reservation_quantity and primary_reservation_quantity are
      -- present, we will compute the reservation quantity based
      -- on the primary reservation quantity
      -- Bug 1914778 - changed ELSIF so that reservation_quantity
      -- is calculated again only if it is null
      -- Bug 2116332 - only call inv_convert if UOMs are different
      IF px_rsv_rec.primary_uom_code = px_rsv_rec.reservation_uom_code THEN
        l_tmp_quantity  := px_rsv_rec.primary_reservation_quantity;
	   -- MUOM Fulfillment project
      ELSIF l_fulfill_base = 'S' and px_rsv_rec.demand_source_type_id in (2,8)
            and px_rsv_rec.reservation_uom_code = px_rsv_rec.secondary_uom_code
            and px_rsv_rec.secondary_reservation_quantity is not null THEN
        l_tmp_quantity  := px_rsv_rec.secondary_reservation_quantity;
      ELSIF l_fulfill_base = 'S' and px_rsv_rec.demand_source_type_id in (2,8)
            and px_rsv_rec.secondary_reservation_quantity is not null THEN
        l_tmp_quantity  := inv_convert.inv_um_convert(
                             item_id                      => px_rsv_rec.inventory_item_id
                           , lot_number                   => px_rsv_rec.lot_number
                           , organization_id              => px_rsv_rec.organization_id
                           , PRECISION                    => NULL -- use default precision
                           , from_quantity                => px_rsv_rec.secondary_reservation_quantity
                           , from_unit                    => px_rsv_rec.secondary_uom_code
                           , to_unit                      => px_rsv_rec.reservation_uom_code
                           , from_name                    => NULL -- from uom name
                           , to_name                      => NULL -- to uom name
                           );

        IF l_tmp_quantity = -99999 THEN
          -- conversion failed
          fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-RSV-UOM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        -- INVCONV upgrade inv_um_convert call
        l_tmp_quantity  := inv_convert.inv_um_convert(
                             item_id                      => px_rsv_rec.inventory_item_id
                           , lot_number                   => px_rsv_rec.lot_number
                           , organization_id              => px_rsv_rec.organization_id
                           , PRECISION                    => NULL -- use default precision
                           , from_quantity                => px_rsv_rec.primary_reservation_quantity
                           , from_unit                    => px_rsv_rec.primary_uom_code
                           , to_unit                      => px_rsv_rec.reservation_uom_code
                           , from_name                    => NULL -- from uom name
                           , to_name                      => NULL -- to uom name
                           );

        IF l_tmp_quantity = -99999 THEN
          -- conversion failed
          fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-RSV-UOM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      --
      px_rsv_rec.reservation_quantity  := l_tmp_quantity;
    END IF;

     -- INVCONV BEGIN
         -- If dual control and secondary quantity is missing, calculate it
         IF px_rsv_rec.secondary_uom_code IS NOT NULL AND
           px_rsv_rec.secondary_reservation_quantity IS NULL THEN
           l_tmp_secondary_quantity  := inv_convert.inv_um_convert(
                                         item_id                      => px_rsv_rec.inventory_item_id
                                       , lot_number                   => px_rsv_rec.lot_number
                                       , organization_id              => px_rsv_rec.organization_id
                                       , PRECISION                    => NULL -- use default precision
                                       , from_quantity                => px_rsv_rec.primary_reservation_quantity
                                      , from_unit                    => px_rsv_rec.primary_uom_code
                                      , to_unit                      => px_rsv_rec.secondary_uom_code
                                      , from_name                    => NULL -- from uom name
                                       , to_name                      => NULL -- to uom name
                                       );

          IF l_tmp_secondary_quantity = -99999 THEN
               -- conversion failed
               fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-SECOND-UOM'); -- INVCONV NEW MESSAGE
               fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
           END IF;
           px_rsv_rec.secondary_reservation_quantity  := l_tmp_secondary_quantity; -- INVCONV
         END IF;

         -- secondary_detailed_quantity could also be missing:
         IF px_rsv_rec.secondary_uom_code IS NOT NULL AND
           px_rsv_rec.secondary_detailed_quantity IS NULL THEN
           IF ( NVL(px_rsv_rec.detailed_quantity,0) = 0   OR
                px_rsv_rec.detailed_quantity = fnd_api.g_miss_num ) THEN --Bug#7482123.
                 px_rsv_rec.secondary_detailed_quantity := 0;
           ELSE -- convert from detailed_quantity to secondary_detailed_quantity
             l_tmp_secondary_quantity  := inv_convert.inv_um_convert(
                                         item_id                      => px_rsv_rec.inventory_item_id
                                       , lot_number                   => px_rsv_rec.lot_number
                                       , organization_id              => px_rsv_rec.organization_id
                                       , PRECISION                    => NULL -- use default precision
                                       , from_quantity                => px_rsv_rec.detailed_quantity
                                   , from_unit                    => px_rsv_rec.primary_uom_code
                                       , to_unit                      => px_rsv_rec.secondary_uom_code
                                       , from_name                    => NULL -- from uom name
                                       , to_name                      => NULL -- to uom name
                                       );

             IF l_tmp_secondary_quantity = -99999 THEN
               -- conversion failed
               fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-SECOND-UOM'); -- INVCONV NEW MESSAGE
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
             END IF;
             px_rsv_rec.secondary_detailed_quantity  := l_tmp_secondary_quantity; -- INVCONV
           END IF;
         END IF;
         -- INVCONV END
    --
    --px_rsv_rec       := l_rsv_rec;
    --
    x_return_status  := l_return_status;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    --
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Convert_Quantity');
      END IF;
  END convert_quantity;

  --
  -- Description
  --   convert missing value in the input record
  --   to null in the output record. if the value of
  --   field in the input record is not missing, it
  --   would be copied to the output record
  PROCEDURE convert_missing_to_null(p_rsv_rec IN inv_reservation_global.mtl_reservation_rec_type, x_rsv_rec OUT NOCOPY inv_reservation_global.mtl_reservation_rec_type) IS
  BEGIN
    IF p_rsv_rec.reservation_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.reservation_id  := p_rsv_rec.reservation_id;
    ELSE
      x_rsv_rec.reservation_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.requirement_date <> fnd_api.g_miss_date THEN
      x_rsv_rec.requirement_date  := p_rsv_rec.requirement_date;
    ELSE
      x_rsv_rec.requirement_date  := NULL;
    END IF;

    --
    IF p_rsv_rec.organization_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.organization_id  := p_rsv_rec.organization_id;
    ELSE
      x_rsv_rec.organization_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.inventory_item_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.inventory_item_id  := p_rsv_rec.inventory_item_id;
    ELSE
      x_rsv_rec.inventory_item_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.demand_source_type_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.demand_source_type_id  := p_rsv_rec.demand_source_type_id;
    ELSE
      x_rsv_rec.demand_source_type_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.demand_source_name <> fnd_api.g_miss_char THEN
      x_rsv_rec.demand_source_name  := p_rsv_rec.demand_source_name;
    ELSE
      x_rsv_rec.demand_source_name  := NULL;
    END IF;

    --
    IF p_rsv_rec.demand_source_delivery <> fnd_api.g_miss_num THEN
      x_rsv_rec.demand_source_delivery  := p_rsv_rec.demand_source_delivery;
    ELSE
      x_rsv_rec.demand_source_delivery  := NULL;
    END IF;

    --
    IF p_rsv_rec.demand_source_header_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.demand_source_header_id  := p_rsv_rec.demand_source_header_id;
    ELSE
      x_rsv_rec.demand_source_header_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.demand_source_line_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.demand_source_line_id  := p_rsv_rec.demand_source_line_id;
    ELSE
      x_rsv_rec.demand_source_line_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.primary_uom_code <> fnd_api.g_miss_char THEN
      x_rsv_rec.primary_uom_code  := p_rsv_rec.primary_uom_code;
    ELSE
      x_rsv_rec.primary_uom_code  := NULL;
    END IF;

    --
    IF p_rsv_rec.primary_uom_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.primary_uom_id  := p_rsv_rec.primary_uom_id;
    ELSE
      x_rsv_rec.primary_uom_id  := NULL;
    END IF;

     -- INVCONV BEGIN
         IF p_rsv_rec.secondary_uom_code <> fnd_api.g_miss_char THEN
           x_rsv_rec.secondary_uom_code  := p_rsv_rec.secondary_uom_code;
         ELSE
           x_rsv_rec.secondary_uom_code  := NULL;
         END IF;

        --
         IF p_rsv_rec.secondary_uom_id <> fnd_api.g_miss_num THEN
           x_rsv_rec.secondary_uom_id  := p_rsv_rec.secondary_uom_id;
         ELSE
           x_rsv_rec.secondary_uom_id  := NULL;
         END IF;
     -- INVCONV END

    --
    IF p_rsv_rec.reservation_uom_code <> fnd_api.g_miss_char THEN
      x_rsv_rec.reservation_uom_code  := p_rsv_rec.reservation_uom_code;
    ELSE
      x_rsv_rec.reservation_uom_code  := NULL;
    END IF;

    --
    IF p_rsv_rec.reservation_uom_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.reservation_uom_id  := p_rsv_rec.reservation_uom_id;
    ELSE
      x_rsv_rec.reservation_uom_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.reservation_quantity <> fnd_api.g_miss_num THEN
      x_rsv_rec.reservation_quantity  := p_rsv_rec.reservation_quantity;
    ELSE
      x_rsv_rec.reservation_quantity  := NULL;
    END IF;

    --
    IF p_rsv_rec.primary_reservation_quantity <> fnd_api.g_miss_num THEN
      x_rsv_rec.primary_reservation_quantity  := p_rsv_rec.primary_reservation_quantity;
    ELSE
      x_rsv_rec.primary_reservation_quantity  := NULL;
    END IF;

     -- INVCONV BEGIN
         IF p_rsv_rec.secondary_reservation_quantity <> fnd_api.g_miss_num THEN
           x_rsv_rec.secondary_reservation_quantity  := p_rsv_rec.secondary_reservation_quantity;
         ELSE
           x_rsv_rec.secondary_reservation_quantity  := NULL;
         END IF;
     -- INVCONV END

    --
    IF p_rsv_rec.detailed_quantity <> fnd_api.g_miss_num THEN
      x_rsv_rec.detailed_quantity  := p_rsv_rec.detailed_quantity;
    ELSE
      x_rsv_rec.detailed_quantity  := NULL;
    END IF;


     -- INVCONV BEGIN
         IF p_rsv_rec.secondary_detailed_quantity <> fnd_api.g_miss_num THEN
           x_rsv_rec.secondary_detailed_quantity  := p_rsv_rec.secondary_detailed_quantity;
         ELSE
           x_rsv_rec.secondary_detailed_quantity  := NULL;
         END IF;
     -- INVCONV END
    --
    IF p_rsv_rec.autodetail_group_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.autodetail_group_id  := p_rsv_rec.autodetail_group_id;
    ELSE
      x_rsv_rec.autodetail_group_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.external_source_code <> fnd_api.g_miss_char THEN
      x_rsv_rec.external_source_code  := p_rsv_rec.external_source_code;
    ELSE
      x_rsv_rec.external_source_code  := NULL;
    END IF;

    --
    IF p_rsv_rec.external_source_line_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.external_source_line_id  := p_rsv_rec.external_source_line_id;
    ELSE
      x_rsv_rec.external_source_line_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.supply_source_type_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.supply_source_type_id  := p_rsv_rec.supply_source_type_id;
    ELSE
      x_rsv_rec.supply_source_type_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.supply_source_header_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.supply_source_header_id  := p_rsv_rec.supply_source_header_id;
    ELSE
      x_rsv_rec.supply_source_header_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.supply_source_line_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.supply_source_line_id  := p_rsv_rec.supply_source_line_id;
    ELSE
      x_rsv_rec.supply_source_line_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.supply_source_line_detail <> fnd_api.g_miss_num THEN
      x_rsv_rec.supply_source_line_detail  := p_rsv_rec.supply_source_line_detail;
    ELSE
      x_rsv_rec.supply_source_line_detail  := NULL;
    END IF;

    --
    IF p_rsv_rec.supply_source_name <> fnd_api.g_miss_char THEN
      x_rsv_rec.supply_source_name  := p_rsv_rec.supply_source_name;
    ELSE
      x_rsv_rec.supply_source_name  := NULL;
    END IF;

    --
    IF p_rsv_rec.revision <> fnd_api.g_miss_char THEN
      x_rsv_rec.revision  := p_rsv_rec.revision;
    ELSE
      x_rsv_rec.revision  := NULL;
    END IF;

    --
    IF p_rsv_rec.subinventory_code <> fnd_api.g_miss_char THEN
      x_rsv_rec.subinventory_code  := p_rsv_rec.subinventory_code;
    ELSE
      x_rsv_rec.subinventory_code  := NULL;
    END IF;

    --
    IF p_rsv_rec.subinventory_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.subinventory_id  := p_rsv_rec.subinventory_id;
    ELSE
      x_rsv_rec.subinventory_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.locator_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.locator_id  := p_rsv_rec.locator_id;
    ELSE
      x_rsv_rec.locator_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.lot_number <> fnd_api.g_miss_char THEN
      x_rsv_rec.lot_number  := p_rsv_rec.lot_number;
    ELSE
      x_rsv_rec.lot_number  := NULL;
    END IF;

    --
    IF p_rsv_rec.lot_number_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.lot_number_id  := p_rsv_rec.lot_number_id;
    ELSE
      x_rsv_rec.lot_number_id  := NULL;
    END IF;

    --
    IF p_rsv_rec.pick_slip_number <> fnd_api.g_miss_num THEN
      x_rsv_rec.pick_slip_number  := p_rsv_rec.pick_slip_number;
    ELSE
      x_rsv_rec.pick_slip_number  := NULL;
    END IF;

    --
    IF p_rsv_rec.attribute_category <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute_category  := p_rsv_rec.attribute_category;
    ELSE
      x_rsv_rec.attribute_category  := NULL;
    END IF;

    --
    IF p_rsv_rec.attribute1 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute1  := p_rsv_rec.attribute1;
    ELSE
      x_rsv_rec.attribute1  := NULL;
    END IF;

    IF p_rsv_rec.attribute2 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute2  := p_rsv_rec.attribute2;
    ELSE
      x_rsv_rec.attribute2  := NULL;
    END IF;

    IF p_rsv_rec.attribute3 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute3  := p_rsv_rec.attribute3;
    ELSE
      x_rsv_rec.attribute3  := NULL;
    END IF;

    IF p_rsv_rec.attribute4 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute4  := p_rsv_rec.attribute4;
    ELSE
      x_rsv_rec.attribute4  := NULL;
    END IF;

    IF p_rsv_rec.attribute5 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute5  := p_rsv_rec.attribute5;
    ELSE
      x_rsv_rec.attribute5  := NULL;
    END IF;

    IF p_rsv_rec.attribute6 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute6  := p_rsv_rec.attribute6;
    ELSE
      x_rsv_rec.attribute6  := NULL;
    END IF;

    IF p_rsv_rec.attribute7 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute7  := p_rsv_rec.attribute7;
    ELSE
      x_rsv_rec.attribute7  := NULL;
    END IF;

    IF p_rsv_rec.attribute8 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute8  := p_rsv_rec.attribute8;
    ELSE
      x_rsv_rec.attribute8  := NULL;
    END IF;

    IF p_rsv_rec.attribute9 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute9  := p_rsv_rec.attribute9;
    ELSE
      x_rsv_rec.attribute9  := NULL;
    END IF;

    IF p_rsv_rec.attribute10 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute10  := p_rsv_rec.attribute10;
    ELSE
      x_rsv_rec.attribute10  := NULL;
    END IF;

    IF p_rsv_rec.attribute11 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute11  := p_rsv_rec.attribute11;
    ELSE
      x_rsv_rec.attribute11  := NULL;
    END IF;

    IF p_rsv_rec.attribute12 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute12  := p_rsv_rec.attribute12;
    ELSE
      x_rsv_rec.attribute12  := NULL;
    END IF;

    IF p_rsv_rec.attribute13 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute13  := p_rsv_rec.attribute13;
    ELSE
      x_rsv_rec.attribute13  := NULL;
    END IF;

    IF p_rsv_rec.attribute14 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute14  := p_rsv_rec.attribute14;
    ELSE
      x_rsv_rec.attribute14  := NULL;
    END IF;

    IF p_rsv_rec.attribute15 <> fnd_api.g_miss_char THEN
      x_rsv_rec.attribute15  := p_rsv_rec.attribute15;
    ELSE
      x_rsv_rec.attribute15  := NULL;
    END IF;

    IF p_rsv_rec.ship_ready_flag <> fnd_api.g_miss_num THEN
      x_rsv_rec.ship_ready_flag  := p_rsv_rec.ship_ready_flag;
    ELSE
      x_rsv_rec.ship_ready_flag  := NULL;
    END IF;

    IF p_rsv_rec.staged_flag <> fnd_api.g_miss_char THEN
      x_rsv_rec.staged_flag  := p_rsv_rec.staged_flag;
    ELSE
      x_rsv_rec.staged_flag  := NULL;
    END IF;

    IF p_rsv_rec.lpn_id <> fnd_api.g_miss_num THEN
      x_rsv_rec.lpn_id  := p_rsv_rec.lpn_id;
    ELSE
      x_rsv_rec.lpn_id  := NULL;
    END IF;

    /**** {{ R12 Enhanced reservations code changes. Adding new columns to
    -- convert_missing_to_null API}}****/
    IF p_rsv_rec.crossdock_flag <> fnd_api.g_miss_char THEN
       x_rsv_rec.crossdock_flag  := p_rsv_rec.crossdock_flag;
     ELSE
       x_rsv_rec.crossdock_flag  := NULL;
    END IF;

    IF p_rsv_rec.crossdock_criteria_id <> fnd_api.g_miss_num THEN
       x_rsv_rec.crossdock_criteria_id  := p_rsv_rec.crossdock_criteria_id;
     ELSE
       x_rsv_rec.crossdock_criteria_id  := NULL;
    END IF;

    IF p_rsv_rec.demand_source_line_detail <> fnd_api.g_miss_num THEN
       x_rsv_rec.demand_source_line_detail  := p_rsv_rec.demand_source_line_detail;
     ELSE
       x_rsv_rec.demand_source_line_detail  := NULL;
    END IF;

    IF p_rsv_rec.serial_reservation_quantity <> fnd_api.g_miss_num THEN
       x_rsv_rec.serial_reservation_quantity  := p_rsv_rec.serial_reservation_quantity;
     ELSE
       x_rsv_rec.serial_reservation_quantity  := NULL;
    END IF;

    IF p_rsv_rec.supply_receipt_date <> fnd_api.g_miss_date THEN
       x_rsv_rec.supply_receipt_date  := p_rsv_rec.supply_receipt_date;
     ELSE
       x_rsv_rec.supply_receipt_date  := NULL;
    END IF;

     IF p_rsv_rec.demand_ship_date <> fnd_api.g_miss_date THEN
       x_rsv_rec.demand_ship_date  := p_rsv_rec.demand_ship_date;
     ELSE
       x_rsv_rec.demand_ship_date  := NULL;
     END IF;

     IF p_rsv_rec.project_id <> fnd_api.g_miss_num THEN
       x_rsv_rec.project_id  := p_rsv_rec.project_id;
     ELSE
       x_rsv_rec.project_id  := NULL;
     END IF;

     IF p_rsv_rec.task_id <> fnd_api.g_miss_num THEN
       x_rsv_rec.task_id  := p_rsv_rec.task_id;
     ELSE
       x_rsv_rec.task_id  := NULL;
    END IF;

 /*** End R12 ***/
  END;

  --
  -- Description
  -- return true if any attribute in the input record is missing
  -- else return false
  FUNCTION check_missing(p_rsv_rec IN OUT NOCOPY inv_reservation_global.mtl_reservation_rec_type, x_what_field OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN IS
  BEGIN
    x_what_field  := NULL;

    IF p_rsv_rec.requirement_date = fnd_api.g_miss_date THEN
      x_what_field  := 'requirement_date';
    END IF;

    IF p_rsv_rec.organization_id = fnd_api.g_miss_num THEN
      x_what_field  := 'organization_id';
    END IF;

    IF p_rsv_rec.inventory_item_id = fnd_api.g_miss_num THEN
      x_what_field  := 'inventory_item_id';
    END IF;

    IF p_rsv_rec.demand_source_type_id = fnd_api.g_miss_num THEN
      x_what_field  := 'demand_source_type_id';
    END IF;

    IF p_rsv_rec.demand_source_name = fnd_api.g_miss_char THEN
      x_what_field  := 'demand_source_name';
    END IF;

    IF p_rsv_rec.demand_source_delivery = fnd_api.g_miss_num THEN
      x_what_field  := 'demand_source_delivery';
    END IF;

    IF p_rsv_rec.demand_source_header_id = fnd_api.g_miss_num THEN
      x_what_field  := 'demand_source_header_id';
    END IF;

    IF p_rsv_rec.demand_source_line_id = fnd_api.g_miss_num THEN
      x_what_field  := 'demand_source_line_id';
    END IF;

    IF p_rsv_rec.primary_uom_code = fnd_api.g_miss_char THEN
      x_what_field  := 'primary_uom_code';
    END IF;

    IF p_rsv_rec.primary_uom_id = fnd_api.g_miss_num THEN
      x_what_field  := 'primary_uom_id';
    END IF;

     -- INVCONV BEGIN
         IF p_rsv_rec.secondary_uom_code = fnd_api.g_miss_char THEN
           x_what_field  := 'secondary_uom_code';
         END IF;

        IF p_rsv_rec.secondary_uom_id = fnd_api.g_miss_num THEN
           x_what_field  := 'secondary_uom_id';
         END IF;
         -- INVCONV END

    IF p_rsv_rec.reservation_uom_code = fnd_api.g_miss_char THEN
      x_what_field  := 'reservation_uom_code';
    END IF;

    IF p_rsv_rec.reservation_uom_id = fnd_api.g_miss_num THEN
      x_what_field  := 'reservation_uom_id';
    END IF;

    IF p_rsv_rec.reservation_quantity = fnd_api.g_miss_num THEN
      x_what_field  := 'reservation_quantity';
    END IF;

    IF p_rsv_rec.primary_reservation_quantity = fnd_api.g_miss_num THEN
      x_what_field  := 'primary_reservation_quantity';
    END IF;

    -- INVCONV BEGIN
    IF p_rsv_rec.secondary_reservation_quantity = fnd_api.g_miss_num THEN
      x_what_field  := 'secondary_reservation_quantity';
    END IF;
    -- INVCONV END

    IF p_rsv_rec.detailed_quantity = fnd_api.g_miss_num THEN
      x_what_field  := 'detailed_quantity';
    END IF;

    -- INVCONV BEGIN
    IF p_rsv_rec.secondary_detailed_quantity = fnd_api.g_miss_num THEN
      x_what_field  := 'secondary_detailed_quantity';
    END IF;
    -- INVCONV BEGIN

    IF p_rsv_rec.autodetail_group_id = fnd_api.g_miss_num THEN
      x_what_field  := 'autodetail_group_id';
    END IF;

    IF p_rsv_rec.external_source_code = fnd_api.g_miss_char THEN
      x_what_field  := 'external_source_code';
    END IF;

    IF p_rsv_rec.external_source_line_id = fnd_api.g_miss_num THEN
      x_what_field  := 'external_source_line_id';
    END IF;

    IF p_rsv_rec.supply_source_type_id = fnd_api.g_miss_num THEN
      x_what_field  := 'supply_source_type_id';
    END IF;

    IF p_rsv_rec.supply_source_header_id = fnd_api.g_miss_num THEN
      x_what_field  := 'supply_source_header_id';
    END IF;

    IF p_rsv_rec.supply_source_line_id = fnd_api.g_miss_num THEN
      x_what_field  := 'supply_source_line_id';
    END IF;

    IF p_rsv_rec.supply_source_name = fnd_api.g_miss_char THEN
      x_what_field  := 'supply_source_name';
    END IF;

    IF p_rsv_rec.supply_source_line_detail = fnd_api.g_miss_num THEN
      x_what_field  := 'supply_source_line_detail';
    END IF;

    IF p_rsv_rec.revision = fnd_api.g_miss_char THEN
      x_what_field  := 'revision';
    END IF;

    IF p_rsv_rec.subinventory_code = fnd_api.g_miss_char THEN
      x_what_field  := 'subinventory_code';
    END IF;

    IF p_rsv_rec.subinventory_id = fnd_api.g_miss_num THEN
      x_what_field  := 'subinventory_id';
    END IF;

    IF p_rsv_rec.locator_id = fnd_api.g_miss_num THEN
      x_what_field  := 'locator_id';
    END IF;

    IF p_rsv_rec.lot_number = fnd_api.g_miss_char THEN
      x_what_field  := 'lot_number';
    END IF;

    IF p_rsv_rec.lot_number_id = fnd_api.g_miss_num THEN
      x_what_field  := 'lot_number_id';
    END IF;

    IF p_rsv_rec.pick_slip_number = fnd_api.g_miss_num THEN
      x_what_field  := 'pick_slip_number';
    END IF;

    IF p_rsv_rec.lpn_id = fnd_api.g_miss_num THEN
      x_what_field  := 'lpn_id';
    END IF;

    IF p_rsv_rec.attribute_category = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute_category';
    END IF;

    IF p_rsv_rec.attribute1 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute1';
    END IF;

    IF p_rsv_rec.attribute2 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute2';
    END IF;

    IF p_rsv_rec.attribute3 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute3';
    END IF;

    IF p_rsv_rec.attribute4 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute4';
    END IF;

    IF p_rsv_rec.attribute5 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute5';
    END IF;

    IF p_rsv_rec.attribute6 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute6';
    END IF;

    IF p_rsv_rec.attribute7 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute7';
    END IF;

    IF p_rsv_rec.attribute8 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute8';
    END IF;

    IF p_rsv_rec.attribute9 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute9';
    END IF;

    IF p_rsv_rec.attribute10 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute10';
    END IF;

    IF p_rsv_rec.attribute11 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute11';
    END IF;

    IF p_rsv_rec.attribute12 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute12';
    END IF;

    IF p_rsv_rec.attribute13 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute13';
    END IF;

    IF p_rsv_rec.attribute14 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute14';
    END IF;

    IF p_rsv_rec.attribute15 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute15';
    END IF;

    IF p_rsv_rec.attribute15 = fnd_api.g_miss_char THEN
      x_what_field  := 'attribute15';
    END IF;

    IF p_rsv_rec.ship_ready_flag = fnd_api.g_miss_num THEN
      x_what_field  := 'ship_ready_flag';
    END IF;

    IF p_rsv_rec.staged_flag = fnd_api.g_miss_char  THEN
       p_rsv_rec.staged_flag := NULL;
    END IF;

    /**** {{ R12 Enhanced reservations code changes. Adding new columns to
    -- check_missing API }}****/
    IF p_rsv_rec.crossdock_flag = fnd_api.g_miss_char  THEN
       p_rsv_rec.crossdock_flag := NULL;
    END IF;

    IF p_rsv_rec.crossdock_criteria_id = fnd_api.g_miss_num THEN
       p_rsv_rec.crossdock_criteria_id := NULL;
    END IF;

    IF p_rsv_rec.demand_source_line_detail = fnd_api.g_miss_num  THEN
       p_rsv_rec.demand_source_line_detail := NULL;
    END IF;

    IF p_rsv_rec.serial_reservation_quantity = fnd_api.g_miss_num  THEN
       p_rsv_rec.serial_reservation_quantity := NULL;
    END IF;

    IF p_rsv_rec.supply_receipt_date = fnd_api.g_miss_date  THEN
       p_rsv_rec.supply_receipt_date := NULL;
    END IF;

    IF p_rsv_rec.demand_ship_date = fnd_api.g_miss_date  THEN
       p_rsv_rec.demand_ship_date := NULL;
    END IF;

    IF p_rsv_rec.project_id = fnd_api.g_miss_num  THEN
       p_rsv_rec.project_id := NULL;
    END IF;

    IF p_rsv_rec.task_id = fnd_api.g_miss_num  THEN
       p_rsv_rec.task_id := NULL;
    END IF;

    /*** End R12 ***/
    debug_print('Check Missing parameter ' || x_what_field);

    IF x_what_field IS NOT NULL THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END check_missing;

  --
  -- Description
  --   construct an output record based on the input records in the
  --   following way
  --   1. if the value of a field in p_to_rsv_rec is not missing or
  --      is null, copy the value to the corresponding field
  --      in x_to_rsv_rec
  --   2. else, copy the value of in the corresponding field in
  --      p_original_rsv_rec to the corresponding field in x_to_rsv_rec
  PROCEDURE construct_to_reservation_row(
    p_original_rsv_rec IN     inv_reservation_global.mtl_reservation_rec_type
  , p_to_rsv_rec       IN     inv_reservation_global.mtl_reservation_rec_type
  , x_to_rsv_rec       OUT    NOCOPY inv_reservation_global.mtl_reservation_rec_type
  ) IS

  l_debug        NUMBER;
  -- MUOM Fulfillment project
  l_fulfill_base   VARCHAR2(1) := 'P';
  BEGIN

    IF (g_debug is NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF p_to_rsv_rec.reservation_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.reservation_id IS NULL THEN
      x_to_rsv_rec.reservation_id  := p_to_rsv_rec.reservation_id;
    ELSE
      x_to_rsv_rec.reservation_id  := p_original_rsv_rec.reservation_id;
    END IF;

    --
    IF p_to_rsv_rec.requirement_date <> fnd_api.g_miss_date
       OR p_to_rsv_rec.requirement_date IS NULL THEN
      x_to_rsv_rec.requirement_date  := p_to_rsv_rec.requirement_date;
    ELSE
      x_to_rsv_rec.requirement_date  := p_original_rsv_rec.requirement_date;
    END IF;

    --
    IF p_to_rsv_rec.organization_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.organization_id IS NULL THEN
      x_to_rsv_rec.organization_id  := p_to_rsv_rec.organization_id;
    ELSE
      x_to_rsv_rec.organization_id  := p_original_rsv_rec.organization_id;
    END IF;

    --
    IF p_to_rsv_rec.inventory_item_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.inventory_item_id IS NULL THEN
      x_to_rsv_rec.inventory_item_id  := p_to_rsv_rec.inventory_item_id;
    ELSE
      x_to_rsv_rec.inventory_item_id  := p_original_rsv_rec.inventory_item_id;
    END IF;

    --
    IF p_to_rsv_rec.demand_source_type_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.demand_source_type_id IS NULL THEN
      x_to_rsv_rec.demand_source_type_id  := p_to_rsv_rec.demand_source_type_id;
    ELSE
      x_to_rsv_rec.demand_source_type_id  := p_original_rsv_rec.demand_source_type_id;
    END IF;

    --
    IF p_to_rsv_rec.demand_source_name <> fnd_api.g_miss_char
       OR p_to_rsv_rec.demand_source_name IS NULL THEN
      x_to_rsv_rec.demand_source_name  := p_to_rsv_rec.demand_source_name;
    ELSE
      x_to_rsv_rec.demand_source_name  := p_original_rsv_rec.demand_source_name;
    END IF;

    --
    IF p_to_rsv_rec.demand_source_delivery <> fnd_api.g_miss_num
       OR p_to_rsv_rec.demand_source_delivery IS NULL THEN
      x_to_rsv_rec.demand_source_delivery  := p_to_rsv_rec.demand_source_delivery;
    ELSE
      x_to_rsv_rec.demand_source_delivery  := p_original_rsv_rec.demand_source_delivery;
    END IF;

    --
    IF p_to_rsv_rec.demand_source_header_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.demand_source_header_id IS NULL THEN
      x_to_rsv_rec.demand_source_header_id  := p_to_rsv_rec.demand_source_header_id;
    ELSE
      x_to_rsv_rec.demand_source_header_id  := p_original_rsv_rec.demand_source_header_id;
    END IF;

    --
    IF p_to_rsv_rec.demand_source_line_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.demand_source_line_id IS NULL THEN
      x_to_rsv_rec.demand_source_line_id  := p_to_rsv_rec.demand_source_line_id;
    ELSE
      x_to_rsv_rec.demand_source_line_id  := p_original_rsv_rec.demand_source_line_id;
    END IF;

    --
    IF p_to_rsv_rec.primary_uom_code <> fnd_api.g_miss_char
       OR p_to_rsv_rec.primary_uom_code IS NULL THEN
      x_to_rsv_rec.primary_uom_code  := p_to_rsv_rec.primary_uom_code;
    ELSE
      x_to_rsv_rec.primary_uom_code  := p_original_rsv_rec.primary_uom_code;
    END IF;

    --
    IF p_to_rsv_rec.primary_uom_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.primary_uom_id IS NULL THEN
      x_to_rsv_rec.primary_uom_id  := p_to_rsv_rec.primary_uom_id;
    ELSE
      x_to_rsv_rec.primary_uom_id  := p_original_rsv_rec.primary_uom_id;
    END IF;

    -- INVCONV BEGIN
    IF p_to_rsv_rec.secondary_uom_code <> fnd_api.g_miss_char
      OR p_to_rsv_rec.secondary_uom_code IS NULL THEN
      x_to_rsv_rec.secondary_uom_code  := p_to_rsv_rec.secondary_uom_code;
    ELSE
      x_to_rsv_rec.secondary_uom_code  := p_original_rsv_rec.secondary_uom_code;
    END IF;

    --
    IF p_to_rsv_rec.secondary_uom_id <> fnd_api.g_miss_num
        OR p_to_rsv_rec.secondary_uom_id IS NULL THEN
      x_to_rsv_rec.secondary_uom_id  := p_to_rsv_rec.secondary_uom_id;
    ELSE
      x_to_rsv_rec.secondary_uom_id  := p_original_rsv_rec.secondary_uom_id;
    END IF;
    -- INVCONV END
    --
    IF p_to_rsv_rec.reservation_uom_code <> fnd_api.g_miss_char
       OR p_to_rsv_rec.reservation_uom_code IS NULL THEN
      x_to_rsv_rec.reservation_uom_code  := p_to_rsv_rec.reservation_uom_code;
    ELSE
      x_to_rsv_rec.reservation_uom_code  := p_original_rsv_rec.reservation_uom_code;
    END IF;

    --
    IF p_to_rsv_rec.reservation_uom_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.reservation_uom_id IS NULL THEN
      x_to_rsv_rec.reservation_uom_id  := p_to_rsv_rec.reservation_uom_id;
    ELSE
      x_to_rsv_rec.reservation_uom_id  := p_original_rsv_rec.reservation_uom_id;
    END IF;

    --
    IF  p_to_rsv_rec.primary_reservation_quantity = fnd_api.g_miss_num
        AND p_to_rsv_rec.reservation_quantity = fnd_api.g_miss_num THEN
      -- neither primary quantity or reservaton quantity is
      -- specified for the to row
      x_to_rsv_rec.primary_reservation_quantity  := p_original_rsv_rec.primary_reservation_quantity;
      x_to_rsv_rec.reservation_quantity          := p_original_rsv_rec.reservation_quantity;
    ELSIF p_to_rsv_rec.primary_reservation_quantity <> fnd_api.g_miss_num
          OR p_to_rsv_rec.primary_reservation_quantity IS NULL THEN
      -- primary_reservation_quantity is specified for the to row
      -- here null is considered as a value
      x_to_rsv_rec.primary_reservation_quantity  := p_to_rsv_rec.primary_reservation_quantity;

      --ADM bug 9959125, retaining the reservation qty passed for OPM batch reservations, in order to avoid re-conversion.
      IF (l_debug = 1) THEN
        debug_print('p_to_rsv_rec.demand_source_type_id = '||p_to_rsv_rec.demand_source_type_id);
        debug_print('p_to_rsv_rec.reservation_quantity = '||p_to_rsv_rec.reservation_quantity);
        debug_print('x_to_rsv_rec.reservation_uom_code = '||x_to_rsv_rec.reservation_uom_code);
        debug_print('x_to_rsv_rec.primary_uom_code = '||x_to_rsv_rec.primary_uom_code);
        debug_print('p_original_rsv_rec.primary_reservation_quantity = '||p_original_rsv_rec.primary_reservation_quantity);
        debug_print('p_to_rsv_rec.primary_reservation_quantity = '||p_to_rsv_rec.primary_reservation_quantity);
        debug_print('p_to_rsv_rec.reservation_quantity = '||p_to_rsv_rec.reservation_quantity);
        debug_print('p_original_rsv_rec.reservation_quantity = '||p_original_rsv_rec.reservation_quantity);
        debug_print('p_to_rsv_rec.secondary_reservation_quantity = '||p_to_rsv_rec.secondary_reservation_quantity);
      END IF;

	    --MUOM Fulfillment Project
      inv_utilities.get_inv_fulfillment_base(
               p_source_line_id    => p_to_rsv_rec.demand_source_line_id,
               p_demand_source_type_id =>p_to_rsv_rec.demand_source_type_id,
               p_org_id                => p_to_rsv_rec.organization_id,
               x_fulfillment_base      => l_fulfill_base
      );

      IF p_to_rsv_rec.demand_source_type_id = 5 and p_to_rsv_rec.reservation_quantity is not null and x_to_rsv_rec.reservation_uom_code is not null
         and x_to_rsv_rec.reservation_uom_code <> x_to_rsv_rec.primary_uom_code and p_original_rsv_rec.primary_reservation_quantity = p_to_rsv_rec.primary_reservation_quantity
         and p_original_rsv_rec.reservation_quantity = p_to_rsv_rec.reservation_quantity and p_original_rsv_rec.demand_source_type_id = p_to_rsv_rec.demand_source_type_id THEN
         x_to_rsv_rec.reservation_quantity := p_to_rsv_rec.reservation_quantity;
      ELSIF p_to_rsv_rec.demand_source_type_id = 5 and p_to_rsv_rec.reservation_quantity is not null and x_to_rsv_rec.reservation_uom_code is not null
            and x_to_rsv_rec.reservation_uom_code <> x_to_rsv_rec.primary_uom_code and x_to_rsv_rec.reservation_uom_code = x_to_rsv_rec.secondary_uom_code
            and (p_to_rsv_rec.secondary_reservation_quantity <> fnd_api.g_miss_num AND p_to_rsv_rec.secondary_reservation_quantity IS NOT NULL)
            and p_original_rsv_rec.demand_source_type_id = p_to_rsv_rec.demand_source_type_id THEN
            x_to_rsv_rec.reservation_quantity := p_to_rsv_rec.secondary_reservation_quantity;
	    -- MUOM Fulfillment project
      ELSIF l_fulfill_base = 'S' and p_to_rsv_rec.demand_source_type_id in (2,8) AND p_to_rsv_rec.reservation_quantity is not null and x_to_rsv_rec.reservation_uom_code is not null
            and x_to_rsv_rec.reservation_uom_code <> x_to_rsv_rec.primary_uom_code and x_to_rsv_rec.reservation_uom_code = x_to_rsv_rec.secondary_uom_code
            and (p_to_rsv_rec.secondary_reservation_quantity <> fnd_api.g_miss_num AND p_to_rsv_rec.secondary_reservation_quantity IS NOT NULL)
            and p_original_rsv_rec.demand_source_type_id = p_to_rsv_rec.demand_source_type_id THEN
           x_to_rsv_rec.reservation_quantity := p_to_rsv_rec.secondary_reservation_quantity;
      ELSE
         IF (l_debug = 1) THEN
            debug_print('Nulling out x_to_rsv_rec.reservation_quantity');
         END IF;
         x_to_rsv_rec.reservation_quantity          := NULL;
      END IF;

    ELSE
      -- primary_reservation_quantity is fnd_api.g_miss_num
      -- but reservation_quantity is null or
      -- value other than fnd_api.g_miss_num
      -- for the to row
      x_to_rsv_rec.primary_reservation_quantity  := NULL;
      x_to_rsv_rec.reservation_quantity          := p_to_rsv_rec.reservation_quantity;
    END IF;

    --
    -- INVCONV BEGIN
    IF p_to_rsv_rec.secondary_reservation_quantity <> fnd_api.g_miss_num
        OR p_to_rsv_rec.secondary_reservation_quantity IS NULL THEN
      x_to_rsv_rec.secondary_reservation_quantity  := p_to_rsv_rec.secondary_reservation_quantity;
    ELSE
      x_to_rsv_rec.secondary_reservation_quantity  := p_original_rsv_rec.secondary_reservation_quantity;
    END IF;
    -- INVCONV END

    IF p_to_rsv_rec.detailed_quantity <> fnd_api.g_miss_num
       OR p_to_rsv_rec.detailed_quantity IS NULL THEN
      x_to_rsv_rec.detailed_quantity  := p_to_rsv_rec.detailed_quantity;
    ELSE
      x_to_rsv_rec.detailed_quantity  := p_original_rsv_rec.detailed_quantity;
    END IF;

    -- INVCONV BEGIN
    IF p_to_rsv_rec.secondary_detailed_quantity <> fnd_api.g_miss_num
         OR p_to_rsv_rec.secondary_detailed_quantity IS NULL THEN
      x_to_rsv_rec.secondary_detailed_quantity  := p_to_rsv_rec.secondary_detailed_quantity;
    ELSE
      x_to_rsv_rec.secondary_detailed_quantity  := p_original_rsv_rec.secondary_detailed_quantity;
    END IF;
    -- INVCONV END

    IF p_to_rsv_rec.autodetail_group_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.autodetail_group_id IS NULL THEN
      x_to_rsv_rec.autodetail_group_id  := p_to_rsv_rec.autodetail_group_id;
    ELSE
      x_to_rsv_rec.autodetail_group_id  := p_original_rsv_rec.autodetail_group_id;
    END IF;

    --
    IF p_to_rsv_rec.external_source_code <> fnd_api.g_miss_char
       OR p_to_rsv_rec.external_source_code IS NULL THEN
      x_to_rsv_rec.external_source_code  := p_to_rsv_rec.external_source_code;
    ELSE
      x_to_rsv_rec.external_source_code  := p_original_rsv_rec.external_source_code;
    END IF;

    --
    IF p_to_rsv_rec.external_source_line_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.external_source_line_id IS NULL THEN
      x_to_rsv_rec.external_source_line_id  := p_to_rsv_rec.external_source_line_id;
    ELSE
      x_to_rsv_rec.external_source_line_id  := p_original_rsv_rec.external_source_line_id;
    END IF;

    --
    IF p_to_rsv_rec.supply_source_type_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.supply_source_type_id IS NULL THEN
      x_to_rsv_rec.supply_source_type_id  := p_to_rsv_rec.supply_source_type_id;
    ELSE
      x_to_rsv_rec.supply_source_type_id  := p_original_rsv_rec.supply_source_type_id;
    END IF;

    --
    IF p_to_rsv_rec.supply_source_header_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.supply_source_header_id IS NULL THEN
      x_to_rsv_rec.supply_source_header_id  := p_to_rsv_rec.supply_source_header_id;
    ELSE
      x_to_rsv_rec.supply_source_header_id  := p_original_rsv_rec.supply_source_header_id;
    END IF;

    --
    IF p_to_rsv_rec.supply_source_line_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.supply_source_line_id IS NULL THEN
      x_to_rsv_rec.supply_source_line_id  := p_to_rsv_rec.supply_source_line_id;
    ELSE
      x_to_rsv_rec.supply_source_line_id  := p_original_rsv_rec.supply_source_line_id;
    END IF;

    --
    IF p_to_rsv_rec.supply_source_line_detail <> fnd_api.g_miss_num
       OR p_to_rsv_rec.supply_source_line_detail IS NULL THEN
      x_to_rsv_rec.supply_source_line_detail  := p_to_rsv_rec.supply_source_line_detail;
    ELSE
      x_to_rsv_rec.supply_source_line_detail  := p_original_rsv_rec.supply_source_line_detail;
    END IF;

    --
    IF p_to_rsv_rec.supply_source_name <> fnd_api.g_miss_char
       OR p_to_rsv_rec.supply_source_name IS NULL THEN
      x_to_rsv_rec.supply_source_name  := p_to_rsv_rec.supply_source_name;
    ELSE
      x_to_rsv_rec.supply_source_name  := p_original_rsv_rec.supply_source_name;
    END IF;

    --
    IF p_to_rsv_rec.revision <> fnd_api.g_miss_char
       OR p_to_rsv_rec.revision IS NULL THEN
      x_to_rsv_rec.revision  := p_to_rsv_rec.revision;
    ELSE
      x_to_rsv_rec.revision  := p_original_rsv_rec.revision;
    END IF;

    --
    IF p_to_rsv_rec.subinventory_code <> fnd_api.g_miss_char
       OR p_to_rsv_rec.subinventory_code IS NULL THEN
      x_to_rsv_rec.subinventory_code  := p_to_rsv_rec.subinventory_code;
    ELSE
      x_to_rsv_rec.subinventory_code  := p_original_rsv_rec.subinventory_code;
    END IF;

    --
    IF p_to_rsv_rec.subinventory_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.subinventory_id IS NULL THEN
      x_to_rsv_rec.subinventory_id  := p_to_rsv_rec.subinventory_id;
    ELSE
      x_to_rsv_rec.subinventory_id  := p_original_rsv_rec.subinventory_id;
    END IF;

    --
    IF p_to_rsv_rec.locator_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.locator_id IS NULL THEN
      x_to_rsv_rec.locator_id  := p_to_rsv_rec.locator_id;
    ELSE
      x_to_rsv_rec.locator_id  := p_original_rsv_rec.locator_id;
    END IF;

    --
    IF p_to_rsv_rec.lot_number <> fnd_api.g_miss_char
       OR p_to_rsv_rec.lot_number IS NULL THEN
      x_to_rsv_rec.lot_number  := p_to_rsv_rec.lot_number;
    ELSE
      x_to_rsv_rec.lot_number  := p_original_rsv_rec.lot_number;
    END IF;

    --
    IF p_to_rsv_rec.lot_number_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.lot_number_id IS NULL THEN
      x_to_rsv_rec.lot_number_id  := p_to_rsv_rec.lot_number_id;
    ELSE
      x_to_rsv_rec.lot_number_id  := p_original_rsv_rec.lot_number_id;
    END IF;

    --
    IF p_to_rsv_rec.pick_slip_number <> fnd_api.g_miss_num
       OR p_to_rsv_rec.pick_slip_number IS NULL THEN
      x_to_rsv_rec.pick_slip_number  := p_to_rsv_rec.pick_slip_number;
    ELSE
      x_to_rsv_rec.pick_slip_number  := p_original_rsv_rec.pick_slip_number;
    END IF;

    --
    IF p_to_rsv_rec.lpn_id <> fnd_api.g_miss_num
       OR p_to_rsv_rec.lpn_id IS NULL THEN
      x_to_rsv_rec.lpn_id  := p_to_rsv_rec.lpn_id;
    ELSE
      x_to_rsv_rec.lpn_id  := p_original_rsv_rec.lpn_id;
    END IF;

    --
    IF p_to_rsv_rec.attribute_category <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute_category IS NULL THEN
      x_to_rsv_rec.attribute_category  := p_to_rsv_rec.attribute_category;
    ELSE
      x_to_rsv_rec.attribute_category  := p_original_rsv_rec.attribute_category;
    END IF;

    --
    IF p_to_rsv_rec.attribute1 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute1 IS NULL THEN
      x_to_rsv_rec.attribute1  := p_to_rsv_rec.attribute1;
    ELSE
      x_to_rsv_rec.attribute1  := p_original_rsv_rec.attribute1;
    END IF;

    IF p_to_rsv_rec.attribute2 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute2 IS NULL THEN
      x_to_rsv_rec.attribute2  := p_to_rsv_rec.attribute2;
    ELSE
      x_to_rsv_rec.attribute2  := p_original_rsv_rec.attribute2;
    END IF;

    IF p_to_rsv_rec.attribute3 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute3 IS NULL THEN
      x_to_rsv_rec.attribute3  := p_to_rsv_rec.attribute3;
    ELSE
      x_to_rsv_rec.attribute3  := p_original_rsv_rec.attribute3;
    END IF;

    IF p_to_rsv_rec.attribute4 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute4 IS NULL THEN
      x_to_rsv_rec.attribute4  := p_to_rsv_rec.attribute4;
    ELSE
      x_to_rsv_rec.attribute4  := p_original_rsv_rec.attribute4;
    END IF;

    IF p_to_rsv_rec.attribute5 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute5 IS NULL THEN
      x_to_rsv_rec.attribute5  := p_to_rsv_rec.attribute5;
    ELSE
      x_to_rsv_rec.attribute5  := p_original_rsv_rec.attribute5;
    END IF;

    IF p_to_rsv_rec.attribute6 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute6 IS NULL THEN
      x_to_rsv_rec.attribute6  := p_to_rsv_rec.attribute6;
    ELSE
      x_to_rsv_rec.attribute6  := p_original_rsv_rec.attribute6;
    END IF;

    IF p_to_rsv_rec.attribute7 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute7 IS NULL THEN
      x_to_rsv_rec.attribute7  := p_to_rsv_rec.attribute7;
    ELSE
      x_to_rsv_rec.attribute7  := p_original_rsv_rec.attribute7;
    END IF;

    IF p_to_rsv_rec.attribute8 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute8 IS NULL THEN
      x_to_rsv_rec.attribute8  := p_to_rsv_rec.attribute8;
    ELSE
      x_to_rsv_rec.attribute8  := p_original_rsv_rec.attribute8;
    END IF;

    IF p_to_rsv_rec.attribute9 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute9 IS NULL THEN
      x_to_rsv_rec.attribute9  := p_to_rsv_rec.attribute9;
    ELSE
      x_to_rsv_rec.attribute9  := p_original_rsv_rec.attribute9;
    END IF;

    IF p_to_rsv_rec.attribute10 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute10 IS NULL THEN
      x_to_rsv_rec.attribute10  := p_to_rsv_rec.attribute10;
    ELSE
      x_to_rsv_rec.attribute10  := p_original_rsv_rec.attribute10;
    END IF;

    IF p_to_rsv_rec.attribute11 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute11 IS NULL THEN
      x_to_rsv_rec.attribute11  := p_to_rsv_rec.attribute11;
    ELSE
      x_to_rsv_rec.attribute11  := p_original_rsv_rec.attribute11;
    END IF;

    IF p_to_rsv_rec.attribute12 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute12 IS NULL THEN
      x_to_rsv_rec.attribute12  := p_to_rsv_rec.attribute12;
    ELSE
      x_to_rsv_rec.attribute12  := p_original_rsv_rec.attribute12;
    END IF;

    IF p_to_rsv_rec.attribute13 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute13 IS NULL THEN
      x_to_rsv_rec.attribute13  := p_to_rsv_rec.attribute13;
    ELSE
      x_to_rsv_rec.attribute13  := p_original_rsv_rec.attribute13;
    END IF;

    IF p_to_rsv_rec.attribute14 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute14 IS NULL THEN
      x_to_rsv_rec.attribute14  := p_to_rsv_rec.attribute14;
    ELSE
      x_to_rsv_rec.attribute14  := p_original_rsv_rec.attribute14;
    END IF;

    IF p_to_rsv_rec.attribute15 <> fnd_api.g_miss_char
       OR p_to_rsv_rec.attribute15 IS NULL THEN
      x_to_rsv_rec.attribute15  := p_to_rsv_rec.attribute15;
    ELSE
      x_to_rsv_rec.attribute15  := p_original_rsv_rec.attribute15;
    END IF;

    IF p_to_rsv_rec.ship_ready_flag <> fnd_api.g_miss_num
       OR p_to_rsv_rec.ship_ready_flag IS NULL THEN
      x_to_rsv_rec.ship_ready_flag  := p_to_rsv_rec.ship_ready_flag;
    ELSE
      x_to_rsv_rec.ship_ready_flag  := p_original_rsv_rec.ship_ready_flag;
    END IF;

    IF p_to_rsv_rec.staged_flag <> fnd_api.g_miss_char
       OR p_to_rsv_rec.staged_flag IS NULL THEN
      x_to_rsv_rec.staged_flag  := p_to_rsv_rec.staged_flag;
    ELSE
      x_to_rsv_rec.staged_flag  := p_original_rsv_rec.staged_flag;
    END IF;

    /**** {{ R12 Enhanced reservations code changes. Adding new columns to
    -- construct_to_reservation_row API }}****/
    IF p_to_rsv_rec.crossdock_flag <> fnd_api.g_miss_char
      OR p_to_rsv_rec.crossdock_flag IS NULL THEN
       x_to_rsv_rec.crossdock_flag  := p_to_rsv_rec.crossdock_flag;
     ELSE
       x_to_rsv_rec.crossdock_flag  := p_original_rsv_rec.crossdock_flag;
    END IF;

    IF p_to_rsv_rec.crossdock_criteria_id <> fnd_api.g_miss_num
      OR p_to_rsv_rec.crossdock_criteria_id IS NULL THEN
       x_to_rsv_rec.crossdock_criteria_id  := p_to_rsv_rec.crossdock_criteria_id;
     ELSE
       x_to_rsv_rec.crossdock_criteria_id  := p_original_rsv_rec.crossdock_criteria_id;
    END IF;

    IF p_to_rsv_rec.demand_source_line_detail <> fnd_api.g_miss_num
      OR p_to_rsv_rec.demand_source_line_detail IS NULL THEN
       x_to_rsv_rec.demand_source_line_detail  := p_to_rsv_rec.demand_source_line_detail;
     ELSE
       x_to_rsv_rec.demand_source_line_detail  := p_original_rsv_rec.demand_source_line_detail;
    END IF;

     IF p_to_rsv_rec.serial_reservation_quantity <> fnd_api.g_miss_num
      OR p_to_rsv_rec.serial_reservation_quantity IS NULL THEN
       x_to_rsv_rec.serial_reservation_quantity  := p_to_rsv_rec.serial_reservation_quantity;
     ELSE
       x_to_rsv_rec.serial_reservation_quantity  := p_original_rsv_rec.serial_reservation_quantity;
     END IF;

     IF p_to_rsv_rec.supply_receipt_date <> fnd_api.g_miss_date
      OR p_to_rsv_rec.supply_receipt_date IS NULL THEN
       x_to_rsv_rec.supply_receipt_date  := p_to_rsv_rec.supply_receipt_date;
     ELSE
       x_to_rsv_rec.supply_receipt_date  := p_original_rsv_rec.supply_receipt_date;
     END IF;

     IF p_to_rsv_rec.demand_ship_date <> fnd_api.g_miss_date
      OR p_to_rsv_rec.demand_ship_date IS NULL THEN
       x_to_rsv_rec.demand_ship_date  := p_to_rsv_rec.demand_ship_date;
     ELSE
       x_to_rsv_rec.demand_ship_date  := p_original_rsv_rec.demand_ship_date;
     END IF;

     IF p_to_rsv_rec.project_id <> fnd_api.g_miss_num
      OR p_to_rsv_rec.project_id IS NULL THEN
       x_to_rsv_rec.project_id  := p_to_rsv_rec.project_id;
     ELSE
       x_to_rsv_rec.project_id  := p_original_rsv_rec.project_id;
     END IF;

     IF p_to_rsv_rec.task_id <> fnd_api.g_miss_num
      OR p_to_rsv_rec.task_id IS NULL THEN
       x_to_rsv_rec.task_id  := p_to_rsv_rec.task_id;
     ELSE
       x_to_rsv_rec.task_id  := p_original_rsv_rec.task_id;
    END IF;

    /*** End R12 ***/

  END construct_to_reservation_row;

  --
  -- Description
  --   return true if the given index points to an item record
  --   in the cache which has a revision control code as yes
  FUNCTION is_revision_control(p_item_cache_index IN INTEGER)
    RETURN BOOLEAN IS
  BEGIN
    IF inv_reservation_global.g_item_record_cache(p_item_cache_index).revision_qty_control_code = inv_reservation_global.g_revision_control_yes THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_revision_control;

  --
  -- Description
  --   return true if the given index points to an item record
  --   in the cache which has a lot control code as yes
  FUNCTION is_lot_control(p_item_cache_index IN INTEGER)
    RETURN BOOLEAN IS
  BEGIN
    IF inv_reservation_global.g_item_record_cache(p_item_cache_index).lot_control_code = inv_reservation_global.g_lot_control_yes THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_lot_control;

  --
  -- Description
  --   return true if the given index points to an item record
  --   in the cache which has a serial control code as yes
  FUNCTION is_serial_control(p_item_cache_index IN INTEGER)
    RETURN BOOLEAN IS
  BEGIN
    IF inv_reservation_global.g_item_record_cache(p_item_cache_index).serial_number_control_code <> inv_reservation_global.g_serial_control_predefined THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END is_serial_control;

  --INVCONV BEGIN
  --
  -- Description
  -- ===========
  --   return true if the given index points to an item record
  --   in the cache which has a dual UOM control as true
  FUNCTION is_dual_control(p_item_cache_index IN INTEGER)
     RETURN BOOLEAN IS
     --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF inv_reservation_global.g_item_record_cache(p_item_cache_index).tracking_quantity_ind <> 'PS' THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END is_dual_control;

  -- Description
  -- ===========
  --   return true if the given index points to an item record
  --   in the cache which has lot divisible true
  FUNCTION is_lot_divisible(p_item_cache_index IN INTEGER)
     RETURN BOOLEAN IS
    l_debug number;
  BEGIN
    IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF inv_reservation_global.g_item_record_cache(p_item_cache_index).lot_control_code
       = inv_reservation_global.g_lot_control_yes AND
       inv_reservation_global.g_item_record_cache(p_item_cache_index).lot_divisible_flag <> 'Y' THEN
       IF (l_debug = 1) THEN
         debug_print('Lot divisible is FALSE ');
       END IF;
       RETURN FALSE;
    ELSE
       IF (l_debug = 1) THEN
         debug_print('Lot divisible is TRUE ');
       END IF;
       RETURN TRUE;
    END IF;
  END is_lot_divisible;

  -- B4498579 BEGIN
  -- Description
  -- ===========
  --   Determine lot divisibility for cases where caching is not in use
  --   and function is_lot_divisible above is not appropriate
  --   This function interrogates mtl_system_items.lot_divisible_flag
  FUNCTION lot_divisible(p_inventory_item_id NUMBER,p_organization_id NUMBER)
     RETURN BOOLEAN IS
	l_debug number;
	l_lot_divisible_flag VARCHAR2(1);
	l_lot_control_code NUMBER;
  BEGIN

     IF (g_debug IS NULL) THEN
	 g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      END IF;

      l_debug := g_debug;

      BEGIN
	 SELECT lot_control_code, lot_divisible_flag INTO
	   l_lot_control_code, l_lot_divisible_flag FROM mtl_system_items
	   WHERE inventory_item_id = p_inventory_item_id
	   AND organization_id = p_organization_id;
      EXCEPTION
	 WHEN no_data_found THEN
	    IF (l_debug =1) THEN
	       debug_print('could not find the record for the item id ' ||
			   p_inventory_item_id || ' Org ' || p_organization_id);
	    END IF;
      END;

      IF (l_debug = 1) THEN
	 debug_print('Lot divisible flag set to '||l_lot_divisible_flag );
      END IF;

      IF (l_lot_control_code = 2 AND Upper(l_lot_divisible_flag) <> 'Y') THEN
	 RETURN FALSE;
       ELSE
	 RETURN TRUE;
      END IF;

  END lot_divisible;
  -- B4498579 END

  -- INVCONV END

  /**** {{ R12 Enhanced reservations code changes. New API get_wip_entity_type }}****/
  /*  This API will take a set of parameters and return the wip entity type and the job type as output. */

  PROCEDURE get_wip_entity_type
    (
     p_api_version_number  IN   NUMBER
     , p_init_msg_lst      IN   VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status     OUT  NOCOPY VARCHAR2
     , x_msg_count         OUT  NOCOPY NUMBER
     , x_msg_data          OUT  NOCOPY VARCHAR2
     , p_organization_id   IN	NUMBER DEFAULT null
     , p_item_id	   IN	NUMBER DEFAULT null
     , p_source_type_id    IN	NUMBER DEFAULT INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP
     , p_source_header_id  IN	NUMBER
     , p_source_line_id	   IN   NUMBER
     , p_source_line_detail IN	NUMBER
     , x_wip_entity_type   OUT NOCOPY NUMBER
     , x_wip_job_type	   OUT NOCOPY VARCHAR2
     ) IS

	l_wip_entity_id NUMBER;
	l_wip_entity_type NUMBER;
	l_wip_job_type VARCHAR2(15);
	l_maintenance_object_source NUMBER;
	l_debug number;
	l_api_name  CONSTANT VARCHAR2(30) := 'Get_WIP_Entity_Type';

  BEGIN
     IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;

     IF (p_source_type_id <> INV_RESERVATION_GLOBAL.g_source_type_wip) THEN
	fnd_message.set_name('INV', 'INV_INVALID_SUPPLY_SOURCE');
	fnd_msg_pub.add;
	RAISE fnd_api.g_exc_error;
     END IF;

  BEGIN
     SELECT we.entity_type, wdj.maintenance_object_source INTO
       l_wip_entity_id, l_maintenance_object_source FROM wip_entities we,
       wip_discrete_jobs wdj WHERE we.wip_entity_id = p_source_header_id
       AND we.wip_entity_id = wdj.wip_entity_id(+);
  EXCEPTION
     WHEN no_data_found THEN
     IF (l_debug = 1) THEN
	debug_print('No WIP entity record found for the source header passed' );
     END IF;
     fnd_message.set_name('INV', 'INV_INVALID_WIP_ENTITY_TYPE');
     fnd_msg_pub.add;
     RAISE fnd_api.g_exc_error;
  END ;

  IF l_wip_entity_id = inv_reservation_global.g_wip_source_type_discrete then
     l_wip_entity_type := inv_reservation_global.g_wip_source_type_discrete;
     l_wip_job_type := 'DISCRETE';
   ELSIF l_wip_entity_id = 2 then
     l_wip_entity_type := inv_reservation_global.g_wip_source_type_repetitive;
     l_wip_job_type := 'REPETITIVE';
   ELSIF l_wip_entity_id = 4 then
     l_wip_entity_type := inv_reservation_global.g_wip_source_type_flow;
     l_wip_job_type := 'FLOW';
   ELSIF l_wip_entity_id = 5 then
     l_wip_entity_type := inv_reservation_global.g_wip_source_type_osfm;
     l_wip_job_type := 'OSFM';
   ELSIF l_wip_entity_id = 6 and l_maintenance_object_source = 1 then
     l_wip_entity_type := inv_reservation_global.g_wip_source_type_eam;
     l_wip_job_type := 'EAM';
   ELSIF l_wip_entity_id = 6 and l_maintenance_object_source = 2  then
     l_wip_entity_type := inv_reservation_global.g_wip_source_type_cmro;
     l_wip_job_type := 'CMRO'; -- AHL
   ELSIF l_wip_entity_id  = 9 then
     l_wip_entity_type := inv_reservation_global.g_wip_source_type_fpo;
     l_wip_job_type := 'FPO';
   ELSIF l_wip_entity_id = 10 then
     l_wip_entity_type := inv_reservation_global.g_wip_source_type_batch;
     l_wip_job_type := 'BATCH';
   ELSIF l_wip_entity_id = 16 THEN
     l_wip_entity_type := inv_reservation_global.g_wip_source_type_depot;
     l_wip_job_type := 'DEPOT';
  END IF;

  x_wip_entity_type := l_wip_entity_type;
  x_wip_job_type := l_wip_job_type;

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
	x_return_status  := fnd_api.g_ret_sts_error;
	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN fnd_api.g_exc_unexpected_error THEN
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN OTHERS THEN
	x_return_status  := fnd_api.g_ret_sts_unexp_error;

	IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	END IF;

	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_wip_entity_type;

  PROCEDURE update_serial_rsv_quantity(
     x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   , p_reservation_id      IN  NUMBER
   , p_update_serial_qty   IN  NUMBER)

  IS
    l_api_name     CONSTANT VARCHAR2(30) := 'update_serial_rsv_quantity';
    l_update_count NUMBER := 0;
    l_debug        NUMBER;
  BEGIN
    IF (g_debug is NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('In update_serial_rsv_quantity');
        debug_print('reservation_id = ' || p_reservation_id);
        debug_print('update_serial_qty = ' || p_update_serial_qty);
    END IF;

    update mtl_reservations
    set    serial_reservation_quantity = serial_reservation_quantity + p_update_serial_qty
    where  reservation_id = p_reservation_id;
    l_update_count := SQL%ROWCOUNT;

    IF (l_debug = 1) THEN
        debug_print('Number of rows update: ' || l_update_count);
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END update_serial_rsv_quantity;

 PROCEDURE is_serial_number_reserved(
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_serial_number_tbl         IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number_tbl         OUT NOCOPY inv_reservation_global.rsv_serial_number_table)
  IS
    l_api_name     CONSTANT VARCHAR2(30) := 'is_serial_number_reserved';
    l_debug        NUMBER;
    l_index        NUMBER := 0;
  BEGIN
    IF (g_debug is NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('In is_serial_number_reserved');
        FOR i in 1..p_serial_number_tbl.count LOOP
            debug_print(i || ' : item = ' || p_serial_number_tbl(i).inventory_item_id ||
                        ', serial number = ' || p_serial_number_tbl(i).serial_number);
        END LOOP;
    END IF;

    -- reset the index for x_serial_number_tbl
    l_index := 0;
    FOR i in 1..p_serial_number_tbl.count LOOP
        BEGIN
           SELECT reservation_id, serial_number
           INTO   x_serial_number_tbl(l_index).reservation_id, x_serial_number_tbl(l_index).serial_number
           FROM   mtl_serial_numbers
           WHERE  serial_number = p_serial_number_tbl(i).serial_number
           AND    inventory_item_id = p_serial_number_tbl(i).inventory_item_id
           AND    reservation_id is not null;
           l_index := l_index + 1;
        EXCEPTION
           WHEN no_data_found THEN
                IF (l_debug = 1) THEN
                    debug_print('serial number ' || p_serial_number_tbl(i).serial_number || ' is not reserved.');
                END IF;
        END;
    END LOOP;

    IF (l_debug = 1) THEN
        FOR i in 1..x_serial_number_tbl.count LOOP
            debug_print(i || ': reservation id = ' || x_serial_number_tbl(i).reservation_id ||
                        ', serial number = ' || x_serial_number_tbl(i).serial_number);
        END LOOP;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END is_serial_number_reserved;

  PROCEDURE is_serial_reserved(
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_serial_number_tbl         IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number_tbl         OUT NOCOPY inv_reservation_global.rsv_serial_number_table
   , x_mtl_reservation_tbl       OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type)
  IS
    l_api_name     CONSTANT VARCHAR2(30) := 'is_serial_number_reserved';
    l_debug        NUMBER;
    l_index        NUMBER := 0;

    CURSOR rsv_csr(p_reservation_id NUMBER) IS
       SELECT reservation_id
            , requirement_date
            , organization_id
            , inventory_item_id
            , demand_source_type_id
            , demand_source_name
            , demand_source_header_id
            , demand_source_line_id
            , demand_source_delivery
            , primary_uom_code
            , primary_uom_id
            , secondary_uom_code
            , secondary_uom_id
            , reservation_uom_code
            , reservation_uom_id
            , reservation_quantity
            , primary_reservation_quantity
            , secondary_reservation_quantity
            , detailed_quantity
            , secondary_detailed_quantity
            , autodetail_group_id
            , external_source_code
            , external_source_line_id
            , supply_source_type_id
            , supply_source_header_id
            , supply_source_line_id
            , supply_source_name
            , supply_source_line_detail
            , revision
            , subinventory_code
            , subinventory_id
            , locator_id
            , lot_number
            , lot_number_id
            , pick_slip_number
            , lpn_id
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
            , ship_ready_flag
            , staged_flag
            , crossdock_flag
            , crossdock_criteria_id
            , demand_source_line_detail
            , serial_reservation_quantity
            , supply_receipt_date
            , demand_ship_date
            , project_id
            , task_id
            , orig_supply_source_type_id
            , orig_supply_source_header_id
            , orig_supply_source_line_id
            , orig_supply_source_line_detail
            , orig_demand_source_type_id
            , orig_demand_source_header_id
            , orig_demand_source_line_id
	 , orig_demand_source_line_detail
	 , serial_number
       FROM mtl_reservations
       WHERE reservation_id = p_reservation_id;
  BEGIN
    IF (g_debug is NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('In is_serial_number_reserved');
        FOR i in 1..p_serial_number_tbl.count LOOP
            debug_print(i || ' : item = ' || p_serial_number_tbl(i).inventory_item_id ||
                        ', serial number = ' || p_serial_number_tbl(i).serial_number);
        END LOOP;
    END IF;

    -- reset the index for x_serial_number_tbl
    l_index := 0;
    FOR i in 1..p_serial_number_tbl.count LOOP
        BEGIN
           SELECT reservation_id, serial_number
           INTO   x_serial_number_tbl(l_index).reservation_id, x_serial_number_tbl(l_index).serial_number
           FROM   mtl_serial_numbers
           WHERE  serial_number = p_serial_number_tbl(i).serial_number
           AND    inventory_item_id = p_serial_number_tbl(i).inventory_item_id
           AND    reservation_id is not null;

           OPEN rsv_csr(x_serial_number_tbl(l_index).reservation_id);
           FETCH rsv_csr into x_mtl_reservation_tbl(l_index);
           CLOSE rsv_csr;

           l_index := l_index + 1;
        EXCEPTION
           WHEN no_data_found THEN
                IF (l_debug = 1) THEN
                    debug_print('serial number ' || p_serial_number_tbl(i).serial_number || ' is not reserved.');
                END IF;
        END;
    END LOOP;

    IF (l_debug = 1) THEN
        FOR i in 1..x_serial_number_tbl.count LOOP
            debug_print(i || ': reservation id = ' || x_serial_number_tbl(i).reservation_id ||
                        ', serial number = ' || x_serial_number_tbl(i).serial_number);
        END LOOP;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END is_serial_reserved;
  /*** End R12 ***/


  --   modify_tree_crt_del_rel
  -- Description
  --   modify quantity tree for create or delete or relieve reservations

  PROCEDURE modify_tree_crt_del_rel(
    x_return_status                OUT    NOCOPY VARCHAR2
  , p_tree_id                      IN     INTEGER
  , p_revision                     IN     VARCHAR2
  , p_lot_number                   IN     VARCHAR2
  , p_subinventory_code            IN     VARCHAR2
  , p_locator_id                   IN     NUMBER
  , p_lpn_id                       IN     NUMBER
  , p_primary_reservation_quantity IN     NUMBER
  , p_second_reservation_quantity  IN     NUMBER           -- INVCONV
  , p_detailed_quantity            IN     NUMBER
  , p_secondary_detailed_quantity  IN     NUMBER           -- INVCONV
  , p_relieve_quantity             IN     NUMBER DEFAULT 0
  , p_secondary_relieve_quantity   IN     NUMBER DEFAULT 0 -- INVCONV
  , p_partial_reservation_flag     IN     VARCHAR2
  , p_force_reservation_flag       IN     VARCHAR2
  , p_lot_divisible_flag           IN     VARCHAR2         -- INVCONV
  , p_action                       IN     VARCHAR2
  , x_qty_changed                  OUT    NOCOPY NUMBER
  , x_secondary_qty_changed        OUT    NOCOPY NUMBER    -- INVCONV
  , p_organization_id              IN     NUMBER DEFAULT NULL -- MUOM Fulfillemnt Project
  , p_demand_source_line_id        IN     NUMBER DEFAULT NULL -- MUOM Fulfillemnt Project
  , p_demand_source_type_id		   IN 	  NUMBER DEFAULT NULL -- MUOM Fulfillemnt Project
  ) IS
    l_return_status     VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_qoh               NUMBER;
    l_rqoh              NUMBER;
    l_qr                NUMBER;
    l_qs                NUMBER;
    l_att               NUMBER;
    l_atr               NUMBER;
    l_sqoh              NUMBER;                          -- INVCONV
    l_srqoh             NUMBER;                          -- INVCONV
    l_sqr               NUMBER;                          -- INVCONV
    l_sqs               NUMBER;                          -- INVCONV
    l_satt              NUMBER;                          -- INVCONV
    l_satr              NUMBER;                          -- INVCONV
    l_quantity_reserved NUMBER;
    l_quantity_type     NUMBER;
    l_secondary_net_qty NUMBER;                          -- INVCONV
    l_dual_control      BOOLEAN := FALSE;                -- INVCONV
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(240);
    l_net_qty           NUMBER;
    l_debug number;
   --MUOM Fulfillment Project
    l_fulfill_base varchar2(1):='P';

  BEGIN
    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    -- INVCONV
    -- Set boolean for dual control scenarios
    IF p_second_reservation_quantity is NOT NULL THEN
       l_dual_control := TRUE;
    END IF;

    -- INVCONV Include secondary parameters below
    inv_quantity_tree_pvt.query_tree(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_true
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_tree_id                    => p_tree_id
    , p_revision                   => p_revision
    , p_lot_number                 => p_lot_number
    , p_subinventory_code          => p_subinventory_code
    , p_locator_id                 => p_locator_id
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
    , p_lpn_id                     => p_lpn_id
    );

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
      debug_print('l_atr ' || l_atr);
      debug_print('l_att ' || l_att);
      debug_print('l_qoh ' || l_qoh);
      debug_print('l_rqoh ' || l_rqoh);
      debug_print('l_qr ' || l_qr);
      debug_print('l_qs ' || l_qs);

      -- INVCONV BEGIN
      debug_print('l_satr ' || l_satr);
      debug_print('l_satt ' || l_satt);
      debug_print('l_sqoh ' || l_sqoh);
      debug_print('l_srqoh ' || l_srqoh);
      debug_print('l_sqr ' || l_sqr);
      debug_print('l_sqs ' || l_sqs);
      -- INVCONV END
    END IF;

    --
    IF p_action = 'CREATE' THEN
      IF (l_debug = 1) THEN
        debug_print('CREATE');
        debug_print('p_primary_reservation_quantity ' || p_primary_reservation_quantity);
        debug_print('p_second_reservation_quantity ' || p_second_reservation_quantity);   -- INVCONV
        debug_print('p_detailed_quantity' || p_detailed_quantity);
        debug_print('p_secondary_detailed_quantity' || p_secondary_detailed_quantity);    -- INVCONV
      END IF;
      l_net_qty  := p_primary_reservation_quantity - NVL(p_detailed_quantity, 0);
      IF l_dual_control THEN                                                              -- INVCONV
        l_secondary_net_qty  := p_second_reservation_quantity - NVL(p_secondary_detailed_quantity, 0); -- INVCONV
      END IF;
      -- INVCONV BEGIN - lot_indivisible quantities cannot be split
      IF p_lot_divisible_flag = 'N' THEN
         IF l_net_qty < l_atr THEN
            -- Available to reserve cannot be subdivided
            fnd_message.set_name('INV', 'INV_LOT_INDIVISIBLE_VIOLATION');       -- INVCONV New Message
            fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
      -- INVCONV END   - lot_indivisible quantities cannot be split
    ELSIF p_action = 'DELETE' THEN
      IF (l_debug = 1) THEN
        debug_print('DELETE');
        debug_print('p_primary_reservation_quantity ' || p_primary_reservation_quantity);
        debug_print('p_detailed_quantity' || p_detailed_quantity);
      END IF;
      l_net_qty  := -p_primary_reservation_quantity + NVL(p_detailed_quantity, 0);
    ELSIF p_action = 'RELIEVE' THEN
      IF (l_debug = 1) THEN
        debug_print('RELIEVE');
        debug_print('p_primary_reservation_quantity ' || p_primary_reservation_quantity);
        debug_print('p_second_reservation_quantity ' || p_second_reservation_quantity);   -- INVCONV
        debug_print('p_detailed_quantity' || p_detailed_quantity);
        debug_print('p_secondary_detailed_quantity' || p_secondary_detailed_quantity);    -- INVCONV
      END IF;
      l_net_qty  := -p_relieve_quantity;
      IF l_dual_control THEN                                                              -- INVCONV
        l_secondary_net_qty  := -p_secondary_relieve_quantity;
      END IF;                                                                             -- INVCONV
    ELSE
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  --MUOM Fulfillment Project
	inv_utilities.get_inv_fulfillment_base(
			p_source_line_id		=> p_demand_source_line_id,
			p_demand_source_type_id => p_demand_source_type_id,
			p_org_id				=> p_organization_id,
			x_fulfillment_base		=> l_fulfill_base
			);

    IF (l_debug=1) THEN
         debug_print('Fulfill Base = '||l_fulfill_base);
    END IF;

    IF  p_force_reservation_flag <> fnd_api.g_true
        AND l_net_qty > 0
        AND ((l_net_qty > l_atr AND p_partial_reservation_flag = fnd_api.g_false AND l_fulfill_base='P')
              OR (l_atr <= 0 AND p_partial_reservation_flag = fnd_api.g_true)
              OR (l_fulfill_base ='S' AND l_secondary_net_qty > l_satr AND p_partial_reservation_flag = fnd_api.g_false)
            ) THEN
      fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
      debug_print('l_net_qty ' || l_net_qty);
      debug_print('l_secondary_net_qty ' || l_secondary_net_qty);                         -- INVCONV
    END IF;

    -- adjust the net quantity according to atr
    IF  l_net_qty > 0
        AND l_net_qty > l_atr THEN
      l_net_qty  := l_atr;
      IF l_dual_control THEN                                                              -- INVCONV
	   IF l_fulfill_base<>'S' or p_action <> 'CREATE' THEN
             l_secondary_net_qty  := l_satr;                                                   -- INVCONV
           END IF;
	END IF;                                                                             -- INVCONV
    END IF;

   If (l_debug = 1) THEN
      debug_print('l_net_qty  ' || l_net_qty);
      debug_print('l_secondary_net_qty ' || l_secondary_net_qty);
      debug_print('l_atr ' || l_atr);
      debug_print('l_satr ' || l_satr);
    END IF;

	--MUOM Fulfillment Project
    If l_fulfill_base='S' AND p_action = 'CREATE' THEN
     IF  l_secondary_net_qty > 0 THEN
         IF l_satr <= l_secondary_net_qty THEN
              l_net_qty  := l_atr;
              l_secondary_net_qty  := l_satr;
         ELSIF l_satr > l_secondary_net_qty THEN
              IF ( l_net_qty > l_atr ) THEN
                   l_net_qty  := l_atr;
              END IF;
        END IF;
     END IF;
   END IF;

    l_quantity_type  := inv_quantity_tree_pvt.g_qr_same_demand;
    --
    inv_quantity_tree_pvt.update_quantities(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_true
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_tree_id                    => p_tree_id
    , p_revision                   => p_revision
    , p_lot_number                 => p_lot_number
    , p_subinventory_code          => p_subinventory_code
    , p_locator_id                 => p_locator_id
    , p_primary_quantity           => l_net_qty
    , p_secondary_quantity         => l_secondary_net_qty                               -- INVCONV
    , p_quantity_type              => l_quantity_type
    , x_qoh                        => l_qoh
    , x_rqoh                       => l_rqoh
    , x_qr                         => l_qr
    , x_qs                         => l_qs
    , x_att                        => l_att
    , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh                                             -- INVCONV
    , x_srqoh                      => l_srqoh                                            -- INVCONV
    , x_sqr                        => l_sqr                                              -- INVCONV
    , x_sqs                        => l_sqs                                              -- INVCONV
    , x_satt                       => l_satt                                             -- INVCONV
    , x_satr                       => l_satr                                             -- INVCONV
    , p_lpn_id                     => p_lpn_id
    );

    --
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    x_qty_changed    := l_net_qty;
    IF l_dual_control THEN                                                               -- INVCONV
      x_secondary_qty_changed    := l_secondary_net_qty;                                 -- INVCONV
    END IF;                                                                              -- INVCONV
    x_return_status  := l_return_status;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    --
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'modify_tree_crt_del_rel');
      END IF;
  END modify_tree_crt_del_rel;

  --
  -- modify the trees for update or transfer reservation
  -- INVCONV - Add secondaries to parameter list
  PROCEDURE modify_tree_for_update_xfer(
    x_return_status              OUT    NOCOPY VARCHAR2
  , x_quantity_reserved          OUT    NOCOPY NUMBER
  , x_secondary_quantity_reserved OUT    NOCOPY NUMBER   --INVCONV
  , p_from_tree_id               IN     NUMBER
  , p_from_supply_source_type_id IN     NUMBER
  , p_from_revision              IN     VARCHAR2
  , p_from_lot_number            IN     VARCHAR2
  , p_from_subinventory_code     IN     VARCHAR2
  , p_from_locator_id            IN     NUMBER
  , p_from_lpn_id                IN     NUMBER
  , p_from_primary_rsv_quantity  IN     NUMBER
  , p_from_second_rsv_quantity   IN     NUMBER
  , p_from_detailed_quantity     IN     NUMBER
  , p_from_sec_detailed_quantity IN     NUMBER
  , p_to_tree_id                 IN     NUMBER
  , p_to_supply_source_type_id   IN     NUMBER
  , p_to_revision                IN     VARCHAR2
  , p_to_lot_number              IN     VARCHAR2
  , p_to_subinventory_code       IN     VARCHAR2
  , p_to_locator_id              IN     NUMBER
  , p_to_lpn_id                  IN     NUMBER
  , p_to_primary_rsv_quantity    IN     NUMBER
  , p_to_second_rsv_quantity     IN     NUMBER
  , p_to_detailed_quantity       IN     NUMBER
  , p_to_second_detailed_quantity IN    NUMBER
  , p_to_revision_control        IN     BOOLEAN
  , p_to_lot_control             IN     BOOLEAN
  , p_action                     IN     VARCHAR2
  , p_lot_divisible_flag         IN     VARCHAR2         -- INVCONV
  , p_partial_reservation_flag   IN     VARCHAR2 DEFAULT fnd_api.g_false
  , p_check_availability         IN     VARCHAR2 DEFAULT fnd_api.g_false
  ) IS

    l_return_status  VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_tmp_revision   VARCHAR2(3);
    l_tmp_lot_number VARCHAR2(80);                                  -- BUG 4180127
    l_net_qty1       NUMBER;
    l_secondary_net_qty1   NUMBER;                                  -- INVCONV
    l_net_qty2       NUMBER;
    l_secondary_net_qty2   NUMBER;                                  -- INVCONV
    l_qoh            NUMBER;
    l_rqoh           NUMBER;
    l_atr            NUMBER;
    l_att            NUMBER;
    l_qr             NUMBER;
    l_qs             NUMBER;
    l_sqoh           NUMBER;                                        -- INVCONV
    l_srqoh          NUMBER;                                        -- INVCONV
    l_satr           NUMBER;                                        -- INVCONV
    l_satt           NUMBER;                                        -- INVCONV
    l_sqr            NUMBER;                                        -- INVCONV
    l_sqs            NUMBER;                                        -- INVCONV
    l_dual_control   BOOLEAN;                                       -- INVCONV
    l_modify_tree1   BOOLEAN;
    l_modify_tree2   BOOLEAN;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(240);
    l_debug number;

  BEGIN
    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

     -- INVCONV BEGIN
     -- Set boolean for dual control scenarios
     IF p_from_second_rsv_quantity is NOT NULL THEN
        l_dual_control := TRUE;
     END IF;
     -- INVCONV END

    IF p_action = 'UPDATE' THEN
      l_net_qty1  := -p_from_primary_rsv_quantity + NVL(p_from_detailed_quantity, 0);
      IF l_dual_control THEN                                        -- INVCONV
        l_secondary_net_qty1 :=
           -p_from_second_rsv_quantity + NVL(p_from_sec_detailed_quantity, 0); -- INVCONV
      END IF;                                                       -- INVCONV
    ELSE -- for transfer reservation
      l_net_qty1  := -p_to_primary_rsv_quantity + NVL(p_to_detailed_quantity, 0);
      IF l_dual_control THEN                                        -- INVCONV
        l_secondary_net_qty1 := -p_to_second_rsv_quantity + NVL(p_to_second_detailed_quantity, 0);  -- INVCONV
      END IF;                                                       -- INVCONV
    END IF;

    l_net_qty2       := p_to_primary_rsv_quantity - NVL(p_to_detailed_quantity, 0);
    IF l_dual_control THEN                                          -- INVCONV
      l_secondary_net_qty2 := p_to_second_rsv_quantity - NVL(p_to_second_detailed_quantity, 0);  -- INVCONV
    END IF;                                                         -- INVCONV
    --
    IF p_from_supply_source_type_id = inv_reservation_global.g_source_type_inv THEN
       -- INVCONV - Incorporate secondaries
      inv_quantity_tree_pvt.update_quantities(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_true
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_tree_id                    => p_from_tree_id
      , p_revision                   => p_from_revision
      , p_lot_number                 => p_from_lot_number
      , p_subinventory_code          => p_from_subinventory_code
      , p_locator_id                 => p_from_locator_id
      , p_primary_quantity           => l_net_qty1
      , p_secondary_quantity         => l_secondary_net_qty1
      , p_quantity_type              => inv_quantity_tree_pvt.g_qr_other_demand
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
      , p_lpn_id                     => p_from_lpn_id
      );

      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      l_modify_tree1  := TRUE;
    ELSE
      l_modify_tree1  := FALSE;
    END IF;

    --
    l_modify_tree2   := FALSE;

    IF  p_to_supply_source_type_id = inv_reservation_global.g_source_type_inv
        AND l_modify_tree1
        AND p_to_tree_id IS NOT NULL
        AND p_from_tree_id <> p_to_tree_id THEN
      l_modify_tree2  := TRUE;

      -- check before passing the revision, and lot number
      -- since the second tree might have different control
      -- settings
      IF p_to_revision_control THEN
        l_tmp_revision  := p_from_revision;
      ELSE
        l_tmp_revision  := NULL;
      END IF;

      --
      IF p_to_lot_control THEN
        l_tmp_lot_number  := p_from_lot_number;
      ELSE
        l_tmp_lot_number  := NULL;
      END IF;

      --
      -- INVCONV - Incorporate secondaries into call
      inv_quantity_tree_pvt.update_quantities(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_true
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_tree_id                    => p_to_tree_id
      , p_revision                   => l_tmp_revision
      , p_lot_number                 => l_tmp_lot_number
      , p_subinventory_code          => p_from_subinventory_code
      , p_locator_id                 => p_from_locator_id
      , p_primary_quantity           => l_net_qty1
      , p_secondary_quantity         => l_secondary_net_qty1
      , p_quantity_type              => inv_quantity_tree_pvt.g_qr_other_demand
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
      , p_lpn_id                     => p_from_lpn_id
      );

      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        -- fail to modify in tree2
        -- undo the modification in tree1
         -- INVCONV - Incorporate secondaries into call
        inv_quantity_tree_pvt.update_quantities(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_tree_id                    => p_from_tree_id
        , p_revision                   => p_from_revision
        , p_lot_number                 => p_from_lot_number
        , p_subinventory_code          => p_from_subinventory_code
        , p_locator_id                 => p_from_locator_id
        , p_primary_quantity           => -l_net_qty1
        , p_secondary_quantity         => -l_secondary_net_qty1
        , p_quantity_type              => inv_quantity_tree_pvt.g_qr_same_demand
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
        , p_lpn_id                     => p_from_lpn_id
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          -- can not add the reservation back on the tree
          -- panic
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --
        -- recover the quantity tree1 correctly, but
        -- since we failed to modify the tree, raise expected error
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
--Start changes for Bug Number#3336837
-- Bug Number 3447373 Removed the qty validation for transfers

IF p_action='UPDATE' AND p_from_supply_source_type_id = inv_reservation_global.g_source_type_inv then
    IF (l_debug = 1) THEN
      debug_print('Validate Qty :Action Update');
    END IF;

     -- INVCONV - Incorporate secondaries into call
     inv_quantity_tree_pvt.query_tree(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_true
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_tree_id                    => p_from_tree_id
    , p_revision                   => p_from_revision
    , p_lot_number                 => p_from_lot_number
    , p_subinventory_code          => p_from_subinventory_code
    , p_locator_id                 => p_from_locator_id
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
    , p_lpn_id                     => p_from_lpn_id
    );

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- INVCONV BEGIN - lot indivisible quantities must be fully consumed
    IF p_lot_divisible_flag = 'N' THEN
      IF (l_debug = 1) THEN
         debug_print('Lot indivisible scenario so compare l_atr '||l_atr ||' with l_net_qty2 '||l_net_qty2);
      END IF;
      IF l_atr > l_net_qty2 THEN
        fnd_message.set_name('INV', 'INV_LOT_INDIVISIBLE_VIOLATION');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    -- INVCONV END

 END IF;

   IF (l_debug = 1) THEN
      debug_print('l_atr '||l_atr);
      debug_print('l_rqoh '||l_rqoh);
      debug_print('l_net_qty2 '||l_net_qty2);
   END IF;

   -- Bug 6141096: Fail the reservation if available to reserve(ATR) is less than or equal to zero, even if the
   -- the partial reservation flag is set to true.
   IF ( p_partial_reservation_flag = fnd_api.g_true  AND l_net_qty2 > l_atr AND l_atr > 0)THEN -- Bug 6141096
    l_net_qty2 := l_atr;
    x_quantity_reserved := l_net_qty2;

    IF l_dual_control THEN                                          -- INVCONV
      l_secondary_net_qty2 := l_satr;                               -- INVCONV
      x_secondary_quantity_reserved := l_secondary_net_qty2;        -- INVCONV
    END IF;                                                         -- INVCONV
   ELSIF (      l_net_qty2 > l_atr
           AND  (p_partial_reservation_flag <> fnd_api.g_true OR l_atr <= 0) -- Bug 6141096
           AND  p_action='UPDATE'
           AND  p_check_availability = fnd_api.g_true )THEN
    --rollback quantity tree changes .
       IF l_modify_tree1 THEN
        -- INVCONV Incorporate secondaries
        inv_quantity_tree_pvt.update_quantities(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_tree_id                    => p_from_tree_id
        , p_revision                   => p_from_revision
        , p_lot_number                 => p_from_lot_number
        , p_subinventory_code          => p_from_subinventory_code
        , p_locator_id                 => p_from_locator_id
        , p_primary_quantity           => -l_net_qty1
        , p_secondary_quantity         => -l_secondary_net_qty1
        , p_quantity_type              => inv_quantity_tree_pvt.g_qr_same_demand
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
        , p_lpn_id                     => p_from_lpn_id
        );
        IF (l_debug = 1) THEN
           debug_print('return status from Rollback Tree1 changes '||l_return_status);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          -- can not add the reservation back on the tree
          -- panic
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
       END IF;


      fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
--Changed for Qty validation. Bug 3336837

    --
    -- adding the quantity to the to tree
    --Bug 1575930
    -- The from tree must also be updated with the quantity, since the
    --  from tree and the to tree are for the same organization and item

     -- INVCONV Incorporate Secondaries in call
    inv_quantity_tree_pvt.update_quantities(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_true
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_tree_id                    => p_from_tree_id
    , p_revision                   => p_from_revision
    , p_lot_number                 => p_from_lot_number
    , p_subinventory_code          => p_from_subinventory_code
    , p_locator_id                 => p_from_locator_id
    , p_primary_quantity           => l_net_qty2
    , p_secondary_quantity         => l_secondary_net_qty2
    , p_quantity_type              => inv_quantity_tree_pvt.g_qr_other_demand
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
    , p_lpn_id                     => p_from_lpn_id
    );

    IF  l_return_status = fnd_api.g_ret_sts_success
        AND l_modify_tree2 THEN

      -- INVCONV Incorporate Secondaries in call
      inv_quantity_tree_pvt.update_quantities(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_true
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_tree_id                    => p_to_tree_id
      , p_revision                   => p_to_revision
      , p_lot_number                 => p_to_lot_number
      , p_subinventory_code          => p_to_subinventory_code
      , p_locator_id                 => p_to_locator_id
      , p_primary_quantity           => l_net_qty2
      , p_secondary_quantity         => l_secondary_net_qty2
      , p_quantity_type              => inv_quantity_tree_pvt.g_qr_same_demand
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
      , p_lpn_id                     => p_to_lpn_id
      );
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      -- fail to modify in tree2
      -- undo the modification in tree1 if l_modify_tree1 is true
      IF l_modify_tree1 THEN
        -- INVCONV - Incorporate secondaries
        inv_quantity_tree_pvt.update_quantities(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_tree_id                    => p_from_tree_id
        , p_revision                   => p_from_revision
        , p_lot_number                 => p_from_lot_number
        , p_subinventory_code          => p_from_subinventory_code
        , p_locator_id                 => p_from_locator_id
        , p_primary_quantity           => -l_net_qty1
        , p_secondary_quantity         => -l_secondary_net_qty1
        , p_quantity_type              => inv_quantity_tree_pvt.g_qr_same_demand
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
        , p_lpn_id                     => p_from_lpn_id
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          -- can not add the reservation back on the tree
          -- panic
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --
        IF l_modify_tree2 THEN
          -- INVCONV - Incorporate secondaries
          inv_quantity_tree_pvt.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_true
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_tree_id                    => p_to_tree_id
          , p_revision                   => l_tmp_revision
          , p_lot_number                 => l_tmp_lot_number
          , p_subinventory_code          => p_from_subinventory_code
          , p_locator_id                 => p_from_locator_id
          , p_primary_quantity           => -l_net_qty1
          , p_secondary_quantity         => -l_secondary_net_qty1
          , p_quantity_type              => inv_quantity_tree_pvt.g_qr_other_demand
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
          , p_lpn_id                     => p_from_lpn_id
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            -- can not add the reservation back on the tree
            -- panic
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          --
          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        -- recover the quantity tree1 correctly, but
        -- since we failed to modify the tree, raise expected error
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    x_return_status  := l_return_status;
    x_quantity_reserved := l_net_qty2;

    IF l_dual_control THEN                                          -- INVCONV
      x_secondary_quantity_reserved := l_secondary_net_qty2;        -- INVCONV
    END IF;                                                         -- INVCONV

  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    --
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'modify_tree_for_update_xfer');
      END IF;
  END modify_tree_for_update_xfer;

  --
  -- Procedure
  --   query_resevation
  -- Description
  --   This  procedure returns all reservations that satisfy the user
  --   specified criteria.
  PROCEDURE query_reservation(
    p_api_version_number        IN     NUMBER
  , p_init_msg_lst              IN     VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status             OUT    NOCOPY VARCHAR2
  , x_msg_count                 OUT    NOCOPY NUMBER
  , x_msg_data                  OUT    NOCOPY VARCHAR2
  , p_query_input               IN     inv_reservation_global.mtl_reservation_rec_type
  , p_lock_records              IN     VARCHAR2 DEFAULT fnd_api.g_false
  , p_sort_by_req_date          IN     NUMBER DEFAULT inv_reservation_global.g_query_no_sort
  , p_cancel_order_mode         IN     NUMBER DEFAULT inv_reservation_global.g_cancel_order_no
  , x_mtl_reservation_tbl       OUT    NOCOPY inv_reservation_global.mtl_reservation_tbl_type
  , x_mtl_reservation_tbl_count OUT    NOCOPY NUMBER
  , x_error_code                OUT    NOCOPY NUMBER
  ) IS
    l_api_version_number CONSTANT NUMBER                                          := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)                                    := 'Query_Reservation';
    l_return_status               VARCHAR2(1)                                     := fnd_api.g_ret_sts_success;
    l_counter                     INTEGER;
    l_rsv_rec                     inv_reservation_global.mtl_reservation_rec_type;
    l_sort_stmt                   VARCHAR2(2000);
    l_lock_stmt                   VARCHAR2(60);
    -- Bug 4881317
    l_qry_stmt                    VARCHAR2(15000);
    l_cursor_ref                  query_cur_ref_type;
    l_miss_num                    NUMBER                                          := fnd_api.g_miss_num;
    l_miss_char                   VARCHAR2(1)                                     := fnd_api.g_miss_char;
    l_miss_date                   DATE                                            := fnd_api.g_miss_date;
    l_update                      BOOLEAN                                         := FALSE;
    l_sort_default                BOOLEAN                                         := FALSE;
    l_res_cursor                  BOOLEAN                                         := FALSE;
    l_demand_cursor               BOOLEAN := FALSE;
    l_debug NUMBER := 0;

    -- Bug 3560916: When multiple processes are accessing the same
    -- reservation record, the query reservation is failing because of
    -- NOLOCK. This happens from pick confirm while transferring
    -- reservations. Removed the nowait from c_res_id_update cursor.

    -- INVCONV - Incorporate secondary quantities
    CURSOR c_res_id_update IS
       SELECT
	 reservation_id
	 , requirement_date
	 , organization_id
	 , inventory_item_id
	 , demand_source_type_id
	 , demand_source_name
	 , demand_source_header_id
	 , demand_source_line_id
	 , demand_source_delivery
	 , primary_uom_code
	 , primary_uom_id
	 , secondary_uom_code
	 , secondary_uom_id
	 , reservation_uom_code
	 , reservation_uom_id
	 , reservation_quantity
	 , primary_reservation_quantity
	 , secondary_reservation_quantity
	 , detailed_quantity
	 , secondary_detailed_quantity
	 , autodetail_group_id
	 , external_source_code
	 , external_source_line_id
	 , supply_source_type_id
	 , supply_source_header_id
	 , supply_source_line_id
	 , supply_source_name
	 , supply_source_line_detail
	 , revision
	 , subinventory_code
	 , subinventory_id
	 , locator_id
	 , lot_number
	 , lot_number_id
	 , pick_slip_number
	 , lpn_id
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
	 , ship_ready_flag
	 , staged_flag
	 /**** {{ R12 Enhanced reservations code changes. Adding new
	 -- columns to query reservations. id passed for update}}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
	 , serial_number
	 /***** End R12 ***/
	 FROM mtl_reservations
	 WHERE reservation_id = p_query_input.reservation_id
	 FOR UPDATE --NOWAIT
	 ORDER BY NVL(revision, ' '), NVL(lot_number, ' '), NVL(subinventory_code, ' '), NVL(locator_id, 0);

    -- INVCONV - Incorporate secondary quantities
    CURSOR c_res_id IS
       SELECT
	 reservation_id
	 , requirement_date
	 , organization_id
	 , inventory_item_id
	 , demand_source_type_id
	 , demand_source_name
	 , demand_source_header_id
	 , demand_source_line_id
	 , demand_source_delivery
	 , primary_uom_code
	 , primary_uom_id
	 , secondary_uom_code
	 , secondary_uom_id
	 , reservation_uom_code
	 , reservation_uom_id
	 , reservation_quantity
	 , primary_reservation_quantity
	 , secondary_reservation_quantity
	 , detailed_quantity
	 , secondary_detailed_quantity
	 , autodetail_group_id
	 , external_source_code
	 , external_source_line_id
	 , supply_source_type_id
	 , supply_source_header_id
	 , supply_source_line_id
	 , supply_source_name
	 , supply_source_line_detail
	 , revision
	 , subinventory_code
	 , subinventory_id
	 , locator_id
	 , lot_number
	 , lot_number_id
	 , pick_slip_number
	 , lpn_id
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
	 , ship_ready_flag
	 , staged_flag
	 /**** {{ R12 Enhanced reservations code changes. Adding new
	 -- columns to query reservations. id passed no update}}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
	 , serial_number
	 /***** End R12 ***/
	 FROM mtl_reservations
         WHERE reservation_id = p_query_input.reservation_id
	 ORDER BY NVL(revision, ' '), NVL(lot_number, ' '), NVL(subinventory_code, ' '), NVL(locator_id, 0);

    -- INVCONV - Incorporate secondary quantities
    --modified the order of conditions and removed unnecessary null conditions to improve the performance as part of bug 7343600
    CURSOR c_demand_update IS
       SELECT
	 reservation_id
	 , requirement_date
	 , organization_id
	 , inventory_item_id
	 , demand_source_type_id
	 , demand_source_name
	 , demand_source_header_id
	 , demand_source_line_id
	 , demand_source_delivery
	 , primary_uom_code
	 , primary_uom_id
	 , secondary_uom_code
	 , secondary_uom_id
	 , reservation_uom_code
	 , reservation_uom_id
	 , reservation_quantity
	 , primary_reservation_quantity
	 , secondary_reservation_quantity
	 , detailed_quantity
	 , secondary_detailed_quantity
	 , autodetail_group_id
	 , external_source_code
	 , external_source_line_id
	 , supply_source_type_id
	 , supply_source_header_id
	 , supply_source_line_id
	 , supply_source_name
	 , supply_source_line_detail
	 , revision
	 , subinventory_code
	 , subinventory_id
	 , locator_id
	 , lot_number
	 , lot_number_id
	 , pick_slip_number
	 , lpn_id
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
	 , ship_ready_flag
	 , staged_flag
	  /**** {{ R12 Enhanced reservations code changes. Adding new
	 -- columns to query reservations. demand passed }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
	 , serial_number
	 /***** End R12 ***/
	 FROM mtl_reservations
	 WHERE demand_source_line_id = p_query_input.demand_source_line_id
	     AND (p_query_input.lpn_id = l_miss_num
                  OR p_query_input.lpn_id IS NULL
                     AND lpn_id IS NULL
                  OR p_query_input.lpn_id = lpn_id
                 )
	     AND
		 (p_query_input.organization_id = l_miss_num
                  OR organization_id = p_query_input.organization_id
                 )
             AND (p_query_input.inventory_item_id = l_miss_num
                   OR inventory_item_id = p_query_input.inventory_item_id
                 )
	     AND (p_query_input.requirement_date = l_miss_date
                  OR  requirement_date = p_query_input.requirement_date
                 )
             AND (p_query_input.demand_source_type_id = l_miss_num
                  OR demand_source_type_id = p_query_input.demand_source_type_id
                 )
             AND (p_query_input.demand_source_header_id = l_miss_num
                  OR p_query_input.demand_source_header_id IS NULL
                     AND demand_source_header_id IS NULL
                  OR p_query_input.demand_source_header_id = demand_source_header_id
                 )
             AND (p_query_input.demand_source_name = l_miss_char
                  OR p_query_input.demand_source_name IS NULL
                     AND demand_source_name IS NULL
                  OR p_query_input.demand_source_name = demand_source_name
                 )
             AND (p_query_input.demand_source_delivery = l_miss_num
                  OR p_query_input.demand_source_delivery IS NULL
                     AND demand_source_delivery IS NULL
                  OR p_query_input.demand_source_delivery = demand_source_delivery
                 )
             AND (p_query_input.primary_uom_code = l_miss_char
                  OR p_query_input.primary_uom_code IS NULL
                     AND primary_uom_code IS NULL
                  OR p_query_input.primary_uom_code = primary_uom_code
                 )
             AND (p_query_input.primary_uom_id = l_miss_num
                  OR p_query_input.primary_uom_id IS NULL
                     AND primary_uom_id IS NULL
                  OR p_query_input.primary_uom_id = primary_uom_id
                 )

              -- INVCONV BEGIN
             AND (p_query_input.secondary_uom_code = l_miss_char
                  OR p_query_input.secondary_uom_code IS NULL
                     AND secondary_uom_code IS NULL
                  OR p_query_input.secondary_uom_code = secondary_uom_code
                 )
             AND (p_query_input.secondary_uom_id = l_miss_num
                  OR p_query_input.secondary_uom_id IS NULL
                     AND secondary_uom_id IS NULL
                  OR p_query_input.secondary_uom_id = secondary_uom_id
                 )
             -- INVCONV END
             AND (p_query_input.reservation_uom_code = l_miss_char
                  OR p_query_input.reservation_uom_code IS NULL
                     AND reservation_uom_code IS NULL
                  OR p_query_input.reservation_uom_code = reservation_uom_code
                 )
             AND (p_query_input.reservation_uom_id = l_miss_num
                  OR p_query_input.reservation_uom_id IS NULL
                     AND reservation_uom_id IS NULL
                  OR p_query_input.reservation_uom_id = reservation_uom_id
                 )
             AND (p_query_input.autodetail_group_id = l_miss_num
                  OR p_query_input.autodetail_group_id IS NULL
                     AND autodetail_group_id IS NULL
                  OR p_query_input.autodetail_group_id = autodetail_group_id
                 )
             AND (p_query_input.external_source_code = l_miss_char
                  OR p_query_input.external_source_code IS NULL
                     AND external_source_code IS NULL
                  OR p_query_input.external_source_code = external_source_code
                 )
             AND (p_query_input.external_source_line_id = l_miss_num
                  OR p_query_input.external_source_line_id IS NULL
                     AND external_source_line_id IS NULL
                  OR p_query_input.external_source_line_id = external_source_line_id
                 )
             AND (p_query_input.supply_source_type_id = l_miss_num
                  OR supply_source_type_id = p_query_input.supply_source_type_id
                 )
             AND (p_query_input.supply_source_header_id = l_miss_num
                  OR p_query_input.supply_source_header_id IS NULL
                     AND supply_source_header_id IS NULL
                  OR p_query_input.supply_source_header_id = supply_source_header_id
                 )
             AND (p_query_input.supply_source_line_id = l_miss_num
                  OR p_query_input.supply_source_line_id IS NULL
                     AND supply_source_line_id IS NULL
                  OR p_query_input.supply_source_line_id = supply_source_line_id
                 )
             AND (p_query_input.supply_source_name = l_miss_char
                  OR p_query_input.supply_source_name IS NULL
                     AND supply_source_name IS NULL
                  OR p_query_input.supply_source_name = supply_source_name
                 )
             AND (p_query_input.supply_source_line_detail = l_miss_num
                  OR p_query_input.supply_source_line_detail IS NULL
                     AND supply_source_line_detail IS NULL
                  OR p_query_input.supply_source_line_detail = supply_source_line_detail
                 )
             AND (p_query_input.revision = l_miss_char
                  OR p_query_input.revision IS NULL
                     AND revision IS NULL
                  OR p_query_input.revision = revision
                 )
             AND (p_query_input.subinventory_code = l_miss_char
                  OR p_query_input.subinventory_code IS NULL
                     AND subinventory_code IS NULL
                  OR p_query_input.subinventory_code = subinventory_code
                 )
             AND (p_query_input.subinventory_id = l_miss_num
                  OR p_query_input.subinventory_id IS NULL
                     AND subinventory_id IS NULL
                  OR p_query_input.subinventory_id = subinventory_id
                 )
             AND (p_query_input.locator_id = l_miss_num
                  OR p_query_input.locator_id IS NULL
                     AND locator_id IS NULL
                  OR p_query_input.locator_id = locator_id
                 )
             AND (p_query_input.lot_number = l_miss_char
                  OR p_query_input.lot_number IS NULL
                     AND lot_number IS NULL
                  OR p_query_input.lot_number = lot_number
                 )
             AND (p_query_input.lot_number_id = l_miss_num
                  OR p_query_input.lot_number_id IS NULL
                     AND lot_number_id IS NULL
                  OR p_query_input.lot_number_id = lot_number_id
                 )
             AND (p_query_input.ship_ready_flag = l_miss_num
                  OR (p_query_input.ship_ready_flag IS NULL OR p_query_input.ship_ready_flag = 2)
                     AND (ship_ready_flag IS NULL OR ship_ready_flag = 2)
                  OR p_query_input.ship_ready_flag = ship_ready_flag
                 )
             AND (p_query_input.staged_flag = l_miss_char
                  OR (p_query_input.staged_flag IS NULL OR p_query_input.staged_flag = 'N')
                     AND (staged_flag IS NULL OR staged_flag = 'N')
                  OR p_query_input.staged_flag = staged_flag
                 )
             AND (p_query_input.attribute_category = l_miss_char
                  OR p_query_input.attribute_category IS NULL
                     AND attribute_category IS NULL
                  OR p_query_input.attribute_category = attribute_category
                 )
             AND (p_query_input.attribute1 = l_miss_char
                  OR p_query_input.attribute1 IS NULL
                     AND attribute1 IS NULL
                  OR p_query_input.attribute1 = attribute1
                 )
             AND (p_query_input.attribute2 = l_miss_char
                  OR p_query_input.attribute2 IS NULL
                     AND attribute2 IS NULL
                  OR p_query_input.attribute2 = attribute2
                 )
             AND (p_query_input.attribute3 = l_miss_char
                  OR p_query_input.attribute3 IS NULL
                     AND attribute3 IS NULL
                  OR p_query_input.attribute3 = attribute3
                 )
             AND (p_query_input.attribute4 = l_miss_char
                  OR p_query_input.attribute4 IS NULL
                     AND attribute4 IS NULL
                  OR p_query_input.attribute4 = attribute4
                 )
             AND (p_query_input.attribute5 = l_miss_char
                  OR p_query_input.attribute5 IS NULL
                     AND attribute5 IS NULL
                  OR p_query_input.attribute5 = attribute5
                 )
             AND (p_query_input.attribute6 = l_miss_char
                  OR p_query_input.attribute6 IS NULL
                     AND attribute6 IS NULL
                  OR p_query_input.attribute6 = attribute6
                 )
             AND (p_query_input.attribute7 = l_miss_char
                  OR p_query_input.attribute7 IS NULL
                     AND attribute7 IS NULL
                  OR p_query_input.attribute7 = attribute7
                 )
             AND (p_query_input.attribute8 = l_miss_char
                  OR p_query_input.attribute8 IS NULL
                     AND attribute8 IS NULL
                  OR p_query_input.attribute8 = attribute8
                 )
             AND (p_query_input.attribute9 = l_miss_char
                  OR p_query_input.attribute9 IS NULL
                     AND attribute9 IS NULL
                  OR p_query_input.attribute9 = attribute9
                 )
             AND (p_query_input.attribute10 = l_miss_char
                  OR p_query_input.attribute10 IS NULL
                     AND attribute10 IS NULL
                  OR p_query_input.attribute10 = attribute10
                 )
             AND (p_query_input.attribute11 = l_miss_char
                  OR p_query_input.attribute11 IS NULL
                     AND attribute11 IS NULL
                  OR p_query_input.attribute11 = attribute11
                 )
             AND (p_query_input.attribute12 = l_miss_char
                  OR p_query_input.attribute12 IS NULL
                     AND attribute12 IS NULL
                  OR p_query_input.attribute12 = attribute12
                 )
             AND (p_query_input.attribute13 = l_miss_char
                  OR p_query_input.attribute13 IS NULL
                     AND attribute13 IS NULL
                  OR p_query_input.attribute13 = attribute13
                 )
             AND (p_query_input.attribute14 = l_miss_char
                  OR p_query_input.attribute14 IS NULL
                     AND attribute14 IS NULL
                  OR p_query_input.attribute14 = attribute14
                 )
             AND (p_query_input.attribute15 = l_miss_char
                  OR p_query_input.attribute15 IS NULL
                     AND attribute15 IS NULL
                  OR p_query_input.attribute15 = attribute15
		  )
	 /**** {{ R12 Enhanced reservations code changes. query reservation
		       -- where clause}}****/
	AND (p_query_input.crossdock_flag = l_miss_char
                  OR p_query_input.crossdock_flag IS NULL
                     AND crossdock_flag IS NULL
                  OR p_query_input.crossdock_flag = crossdock_flag
	     )
	AND (p_query_input.crossdock_criteria_id = l_miss_num
                  OR p_query_input.crossdock_criteria_id IS NULL
                     AND crossdock_criteria_id IS NULL
                  OR p_query_input.crossdock_criteria_id = crossdock_criteria_id
	)
	AND (p_query_input.demand_source_line_detail = l_miss_num
                  OR p_query_input.demand_source_line_detail IS NULL
                     AND demand_source_line_detail IS NULL
                  OR p_query_input.demand_source_line_detail = demand_source_line_detail
	)
	AND (p_query_input.supply_receipt_date = l_miss_date
                  OR p_query_input.supply_receipt_date IS NULL
                     AND supply_receipt_date IS NULL
                  OR p_query_input.supply_receipt_date = supply_receipt_date
	)
	AND (p_query_input.demand_ship_date = l_miss_date
                  OR p_query_input.demand_ship_date IS NULL
                     AND demand_ship_date IS NULL
                  OR p_query_input.demand_ship_date = demand_ship_date
	)
	AND (p_query_input.project_id = l_miss_num
                  OR p_query_input.project_id IS NULL
                     AND project_id IS NULL
                  OR p_query_input.project_id = project_id
	)
	AND (p_query_input.task_id = l_miss_num
                  OR p_query_input.task_id IS NULL
                     AND task_id IS NULL
                  OR p_query_input.task_id = task_id
	)
	 /***** End R12 ***/
      FOR UPDATE NOWAIT
        ORDER BY NVL(revision, ' '), NVL(lot_number, ' '), NVL(subinventory_code, ' '), NVL(locator_id, 0);

    -- INVCONV - Incorporate secondary quantities
    CURSOR c_demand IS
       SELECT
	 reservation_id
	 , requirement_date
	 , organization_id
	 , inventory_item_id
	 , demand_source_type_id
	 , demand_source_name
	 , demand_source_header_id
	 , demand_source_line_id
	 , demand_source_delivery
	 , primary_uom_code
	 , primary_uom_id
	 , secondary_uom_code
	 , secondary_uom_id
	 , reservation_uom_code
	 , reservation_uom_id
	 , reservation_quantity
	 , primary_reservation_quantity
	 , secondary_reservation_quantity
	 , detailed_quantity
	 , secondary_detailed_quantity
	 , autodetail_group_id
	 , external_source_code
	 , external_source_line_id
	 , supply_source_type_id
	 , supply_source_header_id
	 , supply_source_line_id
	 , supply_source_name
	 , supply_source_line_detail
	 , revision
	 , subinventory_code
	 , subinventory_id
	 , locator_id
	 , lot_number
	 , lot_number_id
	 , pick_slip_number
	 , lpn_id
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
	 , ship_ready_flag
	 , staged_flag
	  /**** {{ R12 Enhanced reservations code changes. Adding new
	 -- columns to query reservations. demand passed }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
	 , serial_number
	 /***** End R12 ***/
	 FROM mtl_reservations
         WHERE demand_source_line_id = p_query_input.demand_source_line_id
           AND (p_query_input.requirement_date = l_miss_date
                OR p_query_input.requirement_date IS NULL
                   AND requirement_date IS NULL
                OR p_query_input.requirement_date = requirement_date
               )
           AND (p_query_input.organization_id = l_miss_num
                OR p_query_input.organization_id IS NULL
                   AND organization_id IS NULL
                OR p_query_input.organization_id = organization_id
               )
           AND (p_query_input.inventory_item_id = l_miss_num
                OR p_query_input.inventory_item_id IS NULL
                   AND inventory_item_id IS NULL
                OR p_query_input.inventory_item_id = inventory_item_id
               )
           AND (p_query_input.demand_source_type_id = l_miss_num
                OR p_query_input.demand_source_type_id IS NULL
                   AND demand_source_type_id IS NULL
                OR p_query_input.demand_source_type_id = demand_source_type_id
               )
           AND (p_query_input.demand_source_header_id = l_miss_num
                OR p_query_input.demand_source_header_id IS NULL
                   AND demand_source_header_id IS NULL
                OR p_query_input.demand_source_header_id = demand_source_header_id
               )
           AND (p_query_input.demand_source_name = l_miss_char
                OR p_query_input.demand_source_name IS NULL
                   AND demand_source_name IS NULL
                OR p_query_input.demand_source_name = demand_source_name
               )
           AND (p_query_input.demand_source_delivery = l_miss_num
                OR p_query_input.demand_source_delivery IS NULL
                   AND demand_source_delivery IS NULL
                OR p_query_input.demand_source_delivery = demand_source_delivery
               )
           AND (p_query_input.primary_uom_code = l_miss_char
                OR p_query_input.primary_uom_code IS NULL
                   AND primary_uom_code IS NULL
                OR p_query_input.primary_uom_code = primary_uom_code
               )
           AND (p_query_input.primary_uom_id = l_miss_num
                OR p_query_input.primary_uom_id IS NULL
                   AND primary_uom_id IS NULL
                OR p_query_input.primary_uom_id = primary_uom_id
               )

           -- INVCONV BEGIN
           AND (p_query_input.secondary_uom_code = l_miss_char
                OR p_query_input.secondary_uom_code IS NULL
                   AND secondary_uom_code IS NULL
                OR p_query_input.secondary_uom_code = secondary_uom_code
               )
           AND (p_query_input.secondary_uom_id = l_miss_num
                OR p_query_input.secondary_uom_id IS NULL
                   AND secondary_uom_id IS NULL
                OR p_query_input.secondary_uom_id = secondary_uom_id
               )
           -- INVCONV END
           AND (p_query_input.reservation_uom_code = l_miss_char
                OR p_query_input.reservation_uom_code IS NULL
                   AND reservation_uom_code IS NULL
                OR p_query_input.reservation_uom_code = reservation_uom_code
               )
           AND (p_query_input.reservation_uom_id = l_miss_num
                OR p_query_input.reservation_uom_id IS NULL
                   AND reservation_uom_id IS NULL
                OR p_query_input.reservation_uom_id = reservation_uom_id
               )
           AND (p_query_input.autodetail_group_id = l_miss_num
                OR p_query_input.autodetail_group_id IS NULL
                   AND autodetail_group_id IS NULL
                OR p_query_input.autodetail_group_id = autodetail_group_id
               )
           AND (p_query_input.external_source_code = l_miss_char
                OR p_query_input.external_source_code IS NULL
                   AND external_source_code IS NULL
                OR p_query_input.external_source_code = external_source_code
               )
           AND (p_query_input.external_source_line_id = l_miss_num
                OR p_query_input.external_source_line_id IS NULL
                   AND external_source_line_id IS NULL
                OR p_query_input.external_source_line_id = external_source_line_id
               )
           AND (p_query_input.supply_source_type_id = l_miss_num
                OR p_query_input.supply_source_type_id IS NULL
                   AND supply_source_type_id IS NULL
                OR p_query_input.supply_source_type_id = supply_source_type_id
               )
           AND (p_query_input.supply_source_header_id = l_miss_num
                OR p_query_input.supply_source_header_id IS NULL
                   AND supply_source_header_id IS NULL
                OR p_query_input.supply_source_header_id = supply_source_header_id
               )
           AND (p_query_input.supply_source_line_id = l_miss_num
                OR p_query_input.supply_source_line_id IS NULL
                   AND supply_source_line_id IS NULL
                OR p_query_input.supply_source_line_id = supply_source_line_id
               )
           AND (p_query_input.supply_source_name = l_miss_char
                OR p_query_input.supply_source_name IS NULL
                   AND supply_source_name IS NULL
                OR p_query_input.supply_source_name = supply_source_name
               )
           AND (p_query_input.supply_source_line_detail = l_miss_num
                OR p_query_input.supply_source_line_detail IS NULL
                   AND supply_source_line_detail IS NULL
                OR p_query_input.supply_source_line_detail = supply_source_line_detail
               )
           AND (p_query_input.revision = l_miss_char
                OR p_query_input.revision IS NULL
                   AND revision IS NULL
                OR p_query_input.revision = revision
               )
           AND (p_query_input.subinventory_code = l_miss_char
                OR p_query_input.subinventory_code IS NULL
                   AND subinventory_code IS NULL
                OR p_query_input.subinventory_code = subinventory_code
               )
           AND (p_query_input.subinventory_id = l_miss_num
                OR p_query_input.subinventory_id IS NULL
                   AND subinventory_id IS NULL
                OR p_query_input.subinventory_id = subinventory_id
               )
           AND (p_query_input.locator_id = l_miss_num
                OR p_query_input.locator_id IS NULL
                   AND locator_id IS NULL
                OR p_query_input.locator_id = locator_id
               )
           AND (p_query_input.lot_number = l_miss_char
                OR p_query_input.lot_number IS NULL
                   AND lot_number IS NULL
                OR p_query_input.lot_number = lot_number
               )
           AND (p_query_input.lot_number_id = l_miss_num
                OR p_query_input.lot_number_id IS NULL
                   AND lot_number_id IS NULL
                OR p_query_input.lot_number_id = lot_number_id
               )
           AND (p_query_input.lpn_id = l_miss_num
                OR p_query_input.lpn_id IS NULL
                   AND lpn_id IS NULL
                OR p_query_input.lpn_id = lpn_id
               )
           AND (p_query_input.ship_ready_flag = l_miss_num
                OR (p_query_input.ship_ready_flag IS NULL OR p_query_input.ship_ready_flag = 2)
                   AND (ship_ready_flag IS NULL OR ship_ready_flag = 2)
                OR p_query_input.ship_ready_flag = ship_ready_flag
               )
           AND (p_query_input.staged_flag = l_miss_char
                OR (p_query_input.staged_flag IS NULL OR p_query_input.staged_flag = 'N')
                   AND (staged_flag IS NULL OR staged_flag = 'N')
                OR p_query_input.staged_flag = staged_flag
               )
           AND (p_query_input.attribute_category = l_miss_char
                OR p_query_input.attribute_category IS NULL
                   AND attribute_category IS NULL
                OR p_query_input.attribute_category = attribute_category
               )
           AND (p_query_input.attribute1 = l_miss_char
                OR p_query_input.attribute1 IS NULL
                   AND attribute1 IS NULL
                OR p_query_input.attribute1 = attribute1
               )
           AND (p_query_input.attribute2 = l_miss_char
                OR p_query_input.attribute2 IS NULL
                   AND attribute2 IS NULL
                OR p_query_input.attribute2 = attribute2
               )
           AND (p_query_input.attribute3 = l_miss_char
                OR p_query_input.attribute3 IS NULL
                   AND attribute3 IS NULL
                OR p_query_input.attribute3 = attribute3
               )
           AND (p_query_input.attribute4 = l_miss_char
                OR p_query_input.attribute4 IS NULL
                   AND attribute4 IS NULL
                OR p_query_input.attribute4 = attribute4
               )
           AND (p_query_input.attribute5 = l_miss_char
                OR p_query_input.attribute5 IS NULL
                   AND attribute5 IS NULL
                OR p_query_input.attribute5 = attribute5
               )
           AND (p_query_input.attribute6 = l_miss_char
                OR p_query_input.attribute6 IS NULL
                   AND attribute6 IS NULL
                OR p_query_input.attribute6 = attribute6
               )
           AND (p_query_input.attribute7 = l_miss_char
                OR p_query_input.attribute7 IS NULL
                   AND attribute7 IS NULL
                OR p_query_input.attribute7 = attribute7
               )
           AND (p_query_input.attribute8 = l_miss_char
                OR p_query_input.attribute8 IS NULL
                   AND attribute8 IS NULL
                OR p_query_input.attribute8 = attribute8
               )
           AND (p_query_input.attribute9 = l_miss_char
                OR p_query_input.attribute9 IS NULL
                   AND attribute9 IS NULL
                OR p_query_input.attribute9 = attribute9
               )
           AND (p_query_input.attribute10 = l_miss_char
                OR p_query_input.attribute10 IS NULL
                   AND attribute10 IS NULL
                OR p_query_input.attribute10 = attribute10
               )
           AND (p_query_input.attribute11 = l_miss_char
                OR p_query_input.attribute11 IS NULL
                   AND attribute11 IS NULL
                OR p_query_input.attribute11 = attribute11
               )
           AND (p_query_input.attribute12 = l_miss_char
                OR p_query_input.attribute12 IS NULL
                   AND attribute12 IS NULL
                OR p_query_input.attribute12 = attribute12
               )
           AND (p_query_input.attribute13 = l_miss_char
                OR p_query_input.attribute13 IS NULL
                   AND attribute13 IS NULL
                OR p_query_input.attribute13 = attribute13
               )
           AND (p_query_input.attribute14 = l_miss_char
                OR p_query_input.attribute14 IS NULL
                   AND attribute14 IS NULL
                OR p_query_input.attribute14 = attribute14
               )
           AND (p_query_input.attribute15 = l_miss_char
                OR p_query_input.attribute15 IS NULL
                   AND attribute15 IS NULL
                OR p_query_input.attribute15 = attribute15
		)
		/**** {{ R12 Enhanced reservations code changes }}****/
	AND (p_query_input.crossdock_flag = l_miss_char
                  OR p_query_input.crossdock_flag IS NULL
                     AND crossdock_flag IS NULL
                  OR p_query_input.crossdock_flag = crossdock_flag
	     )
	AND (p_query_input.crossdock_criteria_id = l_miss_num
                  OR p_query_input.crossdock_criteria_id IS NULL
                     AND crossdock_criteria_id IS NULL
                  OR p_query_input.crossdock_criteria_id = crossdock_criteria_id
	)
	AND (p_query_input.demand_source_line_detail = l_miss_num
                  OR p_query_input.demand_source_line_detail IS NULL
                     AND demand_source_line_detail IS NULL
                  OR p_query_input.demand_source_line_detail = demand_source_line_detail
	)
	AND (p_query_input.supply_receipt_date = l_miss_date
                  OR p_query_input.supply_receipt_date IS NULL
                     AND supply_receipt_date IS NULL
                  OR p_query_input.supply_receipt_date = supply_receipt_date
	)
	AND (p_query_input.demand_ship_date = l_miss_date
                  OR p_query_input.demand_ship_date IS NULL
                     AND demand_ship_date IS NULL
                  OR p_query_input.demand_ship_date = demand_ship_date
	)
	AND (p_query_input.project_id = l_miss_num
                  OR p_query_input.project_id IS NULL
                     AND project_id IS NULL
                  OR p_query_input.project_id = project_id
	)
	AND (p_query_input.task_id = l_miss_num
                  OR p_query_input.task_id IS NULL
                     AND task_id IS NULL
                  OR p_query_input.task_id = task_id
	)
	 /***** End R12 ***/


      ORDER BY NVL(revision, ' '), NVL(lot_number, ' '), NVL(subinventory_code, ' '), NVL(locator_id, 0);
  BEGIN
    x_error_code                 := inv_reservation_global.g_err_unexpected;

    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) then
       debug_print('Inside Query reservations...');
    END IF;

    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    IF (l_debug = 1) then
       debug_print('Lock Records: ' || p_lock_records);
       debug_print('p_sort_by_req_date: ' || p_sort_by_req_date);
       debug_print('p_cancel_order_mode: ' || p_cancel_order_mode);
    END IF;


    IF p_lock_records = fnd_api.g_true THEN
      l_lock_stmt  := ' FOR UPDATE NOWAIT';
      l_update     := TRUE;
    END IF;

    --
    -- Pl. note the order by precedence
    -- 1. By requirement_date - asc or desc (For WIP)
    -- 2. By ship_ready_flag, detailed quantity (For OE/OM)
    -- 3. By revision,lot,sub,locator - high level reservations 1st(For default)
    --
    IF p_sort_by_req_date = inv_reservation_global.g_query_req_date_asc THEN
       l_sort_stmt  := ' ORDER BY REQUIREMENT_DATE ASC ';
     ELSIF p_sort_by_req_date = inv_reservation_global.g_query_req_date_desc THEN
       l_sort_stmt  := ' ORDER BY REQUIREMENT_DATE DESC ';
       /**** {{ R12 Enhanced reservations code changes. Adding new sort by conditions }}****/
     ELSIF p_sort_by_req_date = inv_reservation_global.g_query_demand_ship_date_asc THEN
       l_sort_stmt  := ' ORDER BY NVL(DEMAND_SHIP_DATE,REQUIREMENT_DATE) ASC ';
     ELSIF p_sort_by_req_date = inv_reservation_global.g_query_demand_ship_date_desc THEN
       l_sort_stmt  := ' ORDER BY NVL(DEMAND_SHIP_DATE,REQUIREMENT_DATE) DESC ';
     ELSIF p_sort_by_req_date = inv_reservation_global.g_query_supply_rcpt_date_asc THEN
       l_sort_stmt  := ' ORDER BY NVL(SUPPLY_SHIP_DATE,REQUIREMENT_DATE) ASC ';
     ELSIF p_sort_by_req_date = inv_reservation_global.g_query_supply_rcpt_date_asc THEN
       l_sort_stmt  := ' ORDER BY NVL(SUPPLY_SHIP_DATE,REQUIREMENT_DATE) DESC ';
       /*** End R12 ***/

     ELSIF p_cancel_order_mode = inv_reservation_global.g_cancel_order_yes THEN
       l_sort_stmt  := ' ORDER BY NVL(SHIP_READY_FLAG,2) DESC, ' || 'NVL(DETAILED_QUANTITY,0) ';
     ELSE
       -- Default order by - High level followed by detail
       l_sort_default  := TRUE;
       l_sort_stmt     := ' ORDER BY NVL(REVISION, ' || ' '' ''), ' || ' NVL(LOT_NUMBER, ' || ' '' ''), ' || ' NVL(SUBINVENTORY_CODE, ' || ' '' ''), ' || ' NVL(LOCATOR_ID,0) ';
       -- /*** Easier to read this
       --  ORDER BY NVL(REVISION,          ' '),
       --	 NVL(LOT_NUMBER,        ' '),
       --	 NVL(SUBINVENTORY_CODE, ' '),
       --	 NVL(LOCATOR_ID,0) ****/
    END IF;

    IF (l_debug = 1) then
       debug_print('Reservation ID: ' || p_query_input.reservation_id);
       debug_print('demand_source_line_id: ' || p_query_input.demand_source_line_id);
       debug_print('inventory_item_id: ' || p_query_input.inventory_item_id);
       debug_print('organization_id: ' || p_query_input.organization_id);
       debug_print('supply source header id: ' || p_query_input.supply_source_header_id);
       debug_print('supply source line id: ' || p_query_input.supply_source_line_id);
       debug_print('supply source type id: ' || p_query_input.supply_source_type_id);
       IF l_sort_default then
	  debug_print('l_sort_default is true');
	ELSE
	  debug_print('l_sort_default is flase');
       END IF;
       IF l_update then
	  debug_print('l_update is true ');
	ELSE
	  debug_print('l_update is false ');
       END IF;
    END IF;

    IF  p_query_input.reservation_id <> fnd_api.g_miss_num
      AND p_query_input.reservation_id IS NOT NULL THEN
       IF (l_debug = 1) then
	  debug_print(' Inside ref cursor for reservation id');
       END IF;
       IF l_sort_default THEN
	  IF l_update THEN
	     IF (l_debug = 1) then
		debug_print(' Open res cursor for update');
	     END IF;
	     OPEN c_res_id_update;
	     l_res_cursor  := TRUE;
	   ELSE
	     IF (l_debug = 1) then
		debug_print(' Open res cursor for NO update');
	     END IF;
	     OPEN c_res_id;
	    l_res_cursor  := TRUE;
	  END IF;
	  IF (l_debug = 1) and l_res_cursor then
	     debug_print('l_res_cursor is true ');
	   ELSE
	     debug_print('l_res_cursor is false ');
	  END IF;
	ELSE
        -- INVCONV - Incorporate secondary quantities
	  OPEN l_cursor_ref FOR    'SELECT
	    reservation_id
	  , requirement_date
	  , organization_id
	  , inventory_item_id
	  , demand_source_type_id
	  , demand_source_name
	  , demand_source_header_id
	  , demand_source_line_id
	  , demand_source_delivery
	  , primary_uom_code
	  , primary_uom_id
	  , secondary_uom_code
	  , secondary_uom_id
	  , reservation_uom_code
	  , reservation_uom_id
	  , reservation_quantity
	  , primary_reservation_quantity
	  , secondary_reservation_quantity
	  , detailed_quantity
	  , secondary_detailed_quantity
	  , autodetail_group_id
	  , external_source_code
	  , external_source_line_id
	  , supply_source_type_id
	  , supply_source_header_id
	  , supply_source_line_id
	  , supply_source_name
	  , supply_source_line_detail
	  , revision
	  , subinventory_code
	  , subinventory_id
	  , locator_id
	  , lot_number
	  , lot_number_id
	  , pick_slip_number
	  , lpn_id
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
	  , ship_ready_flag
	  , staged_flag
	   /**** {{ R12 Enhanced reservations code changes. Adding new
	    -- columns for query reservations }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
         , serial_number
	 /***** End R12 ***/
        FROM mtl_reservations
        WHERE
        :reservation_id = reservation_id '
                              || l_lock_stmt
                              || l_sort_stmt USING p_query_input.reservation_id;
      END IF;
    ELSIF  p_query_input.demand_source_line_id <> fnd_api.g_miss_num
      AND p_query_input.demand_source_line_id IS NOT NULL THEN
       IF (l_debug = 1) then
	  debug_print(' Inside ref cursor for demand');
       END IF;
       IF l_sort_default THEN
	  IF l_update THEN
	     l_demand_cursor  := TRUE;
	     IF (l_debug = 1) then
		debug_print(' Open demand cursor for update');
	     END IF;
	     OPEN c_demand_update;
	   ELSE
	     l_demand_cursor  := TRUE;
	     IF (l_debug = 1) then
		debug_print(' Open demand cursor for NO update');
	     END IF;
	     OPEN c_demand;
	  END IF;
	  IF (l_debug = 1) AND l_demand_cursor then
	     debug_print('l_demand_cursor is true');
	   ELSE
	     debug_print('l_demand_cursor is false');
	  END IF;
	ELSE
          -- INVCONV - Incorporate secondary quantities
	  OPEN l_cursor_ref FOR    'SELECT
	    reservation_id
	    , requirement_date
	    , organization_id
	    , inventory_item_id
	    , demand_source_type_id
	    , demand_source_name
	    , demand_source_header_id
	    , demand_source_line_id
	    , demand_source_delivery
	    , primary_uom_code
	    , primary_uom_id
	    , secondary_uom_code
	    , secondary_uom_id
	    , reservation_uom_code
	    , reservation_uom_id
	    , reservation_quantity
	    , primary_reservation_quantity
	    , secondary_reservation_quantity
	    , detailed_quantity
	    , secondary_detailed_quantity
	    , autodetail_group_id
	    , external_source_code
	    , external_source_line_id
	    , supply_source_type_id
	    , supply_source_header_id
	    , supply_source_line_id
	    , supply_source_name
	    , supply_source_line_detail
	    , revision
	    , subinventory_code
	    , subinventory_id
	    , locator_id
	    , lot_number
	    , lot_number_id
	    , pick_slip_number
	    , lpn_id
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
	    , ship_ready_flag
	    , staged_flag
	    /**** {{ R12 Enhanced reservations code changes. Adding new
	    -- columns for query reservations }}****/
	    , crossdock_flag
	    , crossdock_criteria_id
	    , demand_source_line_detail
	    , serial_reservation_quantity
	    , supply_receipt_date
	    , demand_ship_date
	    , project_id
	    , task_id
	    , orig_supply_source_type_id
	    , orig_supply_source_header_id
	    , orig_supply_source_line_id
	    , orig_supply_source_line_detail
	    , orig_demand_source_type_id
	    , orig_demand_source_header_id
	    , orig_demand_source_line_id
	    , orig_demand_source_line_detail
            , serial_number
	    /***** End R12 ***/
	    FROM mtl_reservations
	    WHERE
	    demand_source_line_id = :demand_source_line_id
	    AND
	    (:requirement_date = :l_miss_date
	     OR :requirement_date IS NULL
	     AND requirement_date IS NULL
	     OR :requirement_date
	     = requirement_date
	     )
	       AND
        (:organization_id = :l_miss_num
         OR :organization_id IS NULL
         AND organization_id IS NULL
         OR :organization_id = organization_id
         )
        AND
        (:inventory_item_id = :l_miss_num
         OR :inventory_item_id IS NULL
         AND inventory_item_id IS NULL
         OR :inventory_item_id = inventory_item_id
         )
  AND
  (:demand_source_type_id = :l_miss_num
         OR :demand_source_type_id IS NULL
         AND demand_source_type_id IS NULL
         OR :demand_source_type_id
         = demand_source_type_id
         )
        AND
        (:demand_source_header_id = :l_miss_num
         OR :demand_source_header_id IS NULL
         AND demand_source_header_id IS NULL
         OR :demand_source_header_id
         = demand_source_header_id
         )
        AND
        (:demand_source_name = :l_miss_char
         OR :demand_source_name IS NULL
         AND demand_source_name IS NULL
         OR :demand_source_name = demand_source_name
         )
        AND
        (:demand_source_delivery = :l_miss_num
         OR :demand_source_delivery IS NULL
         AND demand_source_delivery IS NULL
         OR :demand_source_delivery = demand_source_delivery
         )
      AND
        (:primary_uom_code = :l_miss_char
         OR :primary_uom_code IS NULL
         AND primary_uom_code IS NULL
         OR :primary_uom_code = primary_uom_code
         )
        AND
        (:primary_uom_id = :l_miss_num
         OR :primary_uom_id IS NULL
         AND primary_uom_id IS NULL
         OR :primary_uom_id = primary_uom_id
         )
         -- INVCONV BEGIN
        AND
        (:secondary_uom_code = :l_miss_char
         OR :secondary_uom_code IS NULL
         AND secondary_uom_code IS NULL
         OR :secondary_uom_code = secondary_uom_code
         )
        AND
        (:secondary_uom_id = :l_miss_num
         OR :secondary_uom_id IS NULL
         AND secondary_uom_id IS NULL
         OR :secondary_uom_id = secondary_uom_id
         )
        -- INVCONV END
        AND
        (:reservation_uom_code = :l_miss_char
         OR :reservation_uom_code IS NULL
         AND reservation_uom_code IS NULL
         OR :reservation_uom_code = reservation_uom_code
         )
        AND
        (:reservation_uom_id = :l_miss_num
         OR :reservation_uom_id IS NULL
         AND reservation_uom_id IS NULL
         OR :reservation_uom_id = reservation_uom_id
         )
        AND
        (:autodetail_group_id = :l_miss_num
         OR :autodetail_group_id IS NULL
         AND autodetail_group_id IS NULL
         OR :autodetail_group_id = autodetail_group_id
         )
        AND
        (:external_source_code = :l_miss_char
         OR :external_source_code IS NULL
         AND external_source_code IS NULL
         OR :external_source_code = external_source_code
         )
        AND
        (:external_source_line_id = :l_miss_num
         OR :external_source_line_id IS NULL
         AND external_source_line_id IS NULL
         OR :external_source_line_id = external_source_line_id
         )
        AND
        (:supply_source_type_id = :l_miss_num
         OR :supply_source_type_id IS NULL
         AND supply_source_type_id IS NULL
         OR :supply_source_type_id = supply_source_type_id
         )
        AND
        (:supply_source_header_id = :l_miss_num
         OR :supply_source_header_id IS NULL
         AND supply_source_header_id IS NULL
         OR :supply_source_header_id
         = supply_source_header_id
         )
        AND
        (:supply_source_line_id = :l_miss_num
         OR :supply_source_line_id IS NULL
         AND supply_source_line_id IS NULL
         OR :supply_source_line_id = supply_source_line_id
         )
        AND
        (:supply_source_name = :l_miss_char
         OR :supply_source_name IS NULL
         AND supply_source_name IS NULL
         OR :supply_source_name = supply_source_name
         )
        AND
        (:supply_source_line_detail = :l_miss_num
         OR :supply_source_line_detail IS NULL
         AND supply_source_line_detail IS NULL
         OR :supply_source_line_detail
         = supply_source_line_detail
         )
        AND
        (:revision = :l_miss_char
         OR :revision IS NULL
         AND revision IS NULL
         OR :revision = revision
         )
        AND
        (:subinventory_code = :l_miss_char
         OR :subinventory_code IS NULL
         AND subinventory_code IS NULL
         OR :subinventory_code = subinventory_code
         )
       AND
        (:subinventory_id = :l_miss_num
         OR :subinventory_id IS NULL
         AND subinventory_id IS NULL
         OR :subinventory_id = subinventory_id
         )
        AND
        (:locator_id = :l_miss_num
         OR :locator_id IS NULL
         AND locator_id IS NULL
         OR :locator_id = locator_id
         )
        AND
        (:lot_number = :l_miss_char
         OR :lot_number IS NULL
         AND lot_number IS NULL
         OR :lot_number = lot_number
         )
        AND
        (:lot_number_id = :l_miss_num
         OR :lot_number_id IS NULL
         AND lot_number_id IS NULL
         OR :lot_number_id = lot_number_id
         )
        AND
        (:lpn_id = :l_miss_num
         OR :lpn_id IS NULL
         AND lpn_id IS NULL
         OR :lpn_id = lpn_id
         )
        AND
        (:ship_ready_flag = :l_miss_num
         OR (:ship_ready_flag IS NULL OR :ship_ready_flag = 2)
         AND (ship_ready_flag IS NULL OR ship_ready_flag = 2)
         OR :ship_ready_flag = ship_ready_flag
         )
        AND
        (:staged_flag = :l_miss_char
         OR (:staged_flag IS NULL OR :staged_flag = ''N'')
         AND (staged_flag IS NULL OR staged_flag = ''N'')
         OR :staged_flag = staged_flag
         )
        AND
        (:attribute_category = :l_miss_char
         OR :attribute_category IS NULL
         AND attribute_category IS NULL
         OR :attribute_category = attribute_category
         )
        AND
        (:attribute1 = :l_miss_char
         OR :attribute1 IS NULL
         AND attribute1 IS NULL
         OR :attribute1 = attribute1
         )
       AND
        (:attribute2 = :l_miss_char
         OR :attribute2 IS NULL
         AND attribute2 IS NULL
         OR :attribute2 = attribute2
         )
        AND
        (:attribute3 = :l_miss_char
         OR :attribute3 IS NULL
         AND attribute3 IS NULL
         OR :attribute3 = attribute3
         )
        AND
        (:attribute4 = :l_miss_char
         OR :attribute4 IS NULL
         AND attribute4 IS NULL
         OR :attribute4 = attribute4
         )
       AND
        (:attribute5 = :l_miss_char
         OR :attribute5 IS NULL
         AND attribute5 IS NULL
         OR :attribute5 = attribute5
         )
        AND
        (:attribute6 = :l_miss_char
         OR :attribute6 IS NULL
         AND attribute6 IS NULL
         OR :attribute6 = attribute6
         )
        AND
        (:attribute7 = :l_miss_char
         OR :attribute7 IS NULL
         AND attribute7 IS NULL
         OR :attribute7 = attribute7
         )
        AND
        (:attribute8 = :l_miss_char
         OR :attribute8 IS NULL
         AND attribute8 IS NULL
         OR :attribute8 = attribute8
         )
        AND
        (:attribute9 = :l_miss_char
         OR :attribute9 IS NULL
         AND attribute9 IS NULL
         OR :attribute9 = attribute9
         )
        AND
        (:attribute10 = :l_miss_char
         OR :attribute10 IS NULL
         AND attribute10 IS NULL
         OR :attribute10 = attribute10
         )
        AND
        (:attribute11 = :l_miss_char
         OR :attribute11 IS NULL
         AND attribute11 IS NULL
         OR :attribute11 = attribute11
         )
        AND
        (:attribute12 = :l_miss_char
         OR :attribute12 IS NULL
         AND attribute12 IS NULL
         OR :attribute12 = attribute12
         )
        AND
        (:attribute13 = :l_miss_char
         OR :attribute13 IS NULL
         AND attribute13 IS NULL
         OR :attribute13 = attribute13
         )
        AND
        (:attribute14 = :l_miss_char
         OR :attribute14 IS NULL
         AND attribute14 IS NULL
         OR :attribute14 = attribute14
         )
        AND
        (:attribute15 = :l_miss_char
         OR :attribute15 IS NULL
         AND attribute15 IS NULL
         OR :attribute15 = attribute15
         )
/**** {{ R12 Enhanced reservations code changes }}****/
	AND
	   (:crossdock_flag = :l_miss_char
         OR :crossdock_flag IS NULL
         AND crossdock_flag IS NULL
         OR :crossdock_flag = crossdock_flag
         )
	AND
	   (:crossdock_criteria_id = :l_miss_num
         OR :crossdock_criteria_id IS NULL
         AND crossdock_criteria_id IS NULL
         OR :crossdock_criteria_id = crossdock_criteria_id
	    )
        AND
	   (:demand_source_line_detail = :l_miss_num
         OR :demand_source_line_detail IS NULL
         AND demand_source_line_detail IS NULL
         OR :demand_source_line_detail = demand_source_line_detail
	    )
	AND
	   (:supply_receipt_date = :l_miss_date
         OR :supply_receipt_date IS NULL
         AND supply_receipt_date IS NULL
         OR :supply_receipt_date = supply_receipt_date
	    )
	AND
	   (:demand_ship_date = :l_miss_date
         OR :demand_ship_date IS NULL
         AND demand_ship_date IS NULL
         OR :demand_ship_date = demand_ship_date
	    )
	AND
	   (:project_id = :l_miss_num
         OR :project_id IS NULL
         AND project_id IS NULL
         OR :project_id = project_id
	    )
	 AND
	   (:task_id = :l_miss_num
         OR :task_id IS NULL
         AND task_id IS NULL
         OR :task_id = task_id
	    )
/***** End R12  ***/
	   '
                              || l_lock_stmt
                              || l_sort_stmt
          USING  p_query_input.demand_source_line_id
               , p_query_input.requirement_date
               , l_miss_date
               , p_query_input.requirement_date
               , p_query_input.requirement_date
               , p_query_input.organization_id
               , l_miss_num
               , p_query_input.organization_id
               , p_query_input.organization_id
               , p_query_input.inventory_item_id
               , l_miss_num
               , p_query_input.inventory_item_id
               , p_query_input.inventory_item_id
               , p_query_input.demand_source_type_id
               , l_miss_num
               , p_query_input.demand_source_type_id
               , p_query_input.demand_source_type_id
               , p_query_input.demand_source_header_id
               , l_miss_num
               , p_query_input.demand_source_header_id
               , p_query_input.demand_source_header_id
               , p_query_input.demand_source_name
               , l_miss_char
               , p_query_input.demand_source_name
               , p_query_input.demand_source_name
               , p_query_input.demand_source_delivery
               , l_miss_num
               , p_query_input.demand_source_delivery
               , p_query_input.demand_source_delivery
               , p_query_input.primary_uom_code
               , l_miss_char
               , p_query_input.primary_uom_code
               , p_query_input.primary_uom_code
               , p_query_input.primary_uom_id
               , l_miss_num
               , p_query_input.primary_uom_id
               , p_query_input.primary_uom_id
                -- INVCONV BEGIN
               , p_query_input.secondary_uom_code
               , l_miss_char
               , p_query_input.secondary_uom_code
               , p_query_input.secondary_uom_code
               , p_query_input.secondary_uom_id
               , l_miss_num
               , p_query_input.secondary_uom_id
               , p_query_input.secondary_uom_id
               -- INVCONV END
               , p_query_input.reservation_uom_code
               , l_miss_char
               , p_query_input.reservation_uom_code
               , p_query_input.reservation_uom_code
               , p_query_input.reservation_uom_id
               , l_miss_num
               , p_query_input.reservation_uom_id
               , p_query_input.reservation_uom_id
               , p_query_input.autodetail_group_id
               , l_miss_num
               , p_query_input.autodetail_group_id
               , p_query_input.autodetail_group_id
               , p_query_input.external_source_code
               , l_miss_char
               , p_query_input.external_source_code
               , p_query_input.external_source_code
               , p_query_input.external_source_line_id
               , l_miss_num
               , p_query_input.external_source_line_id
               , p_query_input.external_source_line_id
               , p_query_input.supply_source_type_id
               , l_miss_num
               , p_query_input.supply_source_type_id
               , p_query_input.supply_source_type_id
               , p_query_input.supply_source_header_id
               , l_miss_num
               , p_query_input.supply_source_header_id
               , p_query_input.supply_source_header_id
               , p_query_input.supply_source_line_id
               , l_miss_num
               , p_query_input.supply_source_line_id
               , p_query_input.supply_source_line_id
               , p_query_input.supply_source_name
               , l_miss_char
               , p_query_input.supply_source_name
               , p_query_input.supply_source_name
               , p_query_input.supply_source_line_detail
               , l_miss_num
               , p_query_input.supply_source_line_detail
               , p_query_input.supply_source_line_detail
               , p_query_input.revision
               , l_miss_char
               , p_query_input.revision
               , p_query_input.revision
               , p_query_input.subinventory_code
               , l_miss_char
               , p_query_input.subinventory_code
               , p_query_input.subinventory_code
               , p_query_input.subinventory_id
               , l_miss_num
               , p_query_input.subinventory_id
               , p_query_input.subinventory_id
               , p_query_input.locator_id
               , l_miss_num
               , p_query_input.locator_id
               , p_query_input.locator_id
               , p_query_input.lot_number
               , l_miss_char
               , p_query_input.lot_number
               , p_query_input.lot_number
               , p_query_input.lot_number_id
               , l_miss_num
               , p_query_input.lot_number_id
               , p_query_input.lot_number_id
               , p_query_input.lpn_id
               , l_miss_num
               , p_query_input.lpn_id
               , p_query_input.lpn_id
               , p_query_input.ship_ready_flag
               , l_miss_num
               , p_query_input.ship_ready_flag
               , p_query_input.ship_ready_flag
               , p_query_input.ship_ready_flag
               , p_query_input.staged_flag
               , l_miss_char
               , p_query_input.staged_flag
               , p_query_input.staged_flag
               , p_query_input.staged_flag
               , p_query_input.attribute_category
               , l_miss_char
               , p_query_input.attribute_category
               , p_query_input.attribute_category
               , p_query_input.attribute1
               , l_miss_char
               , p_query_input.attribute1
               , p_query_input.attribute1
               , p_query_input.attribute2
               , l_miss_char
               , p_query_input.attribute2
               , p_query_input.attribute2
               , p_query_input.attribute3
               , l_miss_char
               , p_query_input.attribute3
               , p_query_input.attribute3
               , p_query_input.attribute4
               , l_miss_char
               , p_query_input.attribute4
               , p_query_input.attribute4
               , p_query_input.attribute5
               , l_miss_char
               , p_query_input.attribute5
               , p_query_input.attribute5
               , p_query_input.attribute6
               , l_miss_char
               , p_query_input.attribute6
               , p_query_input.attribute6
               , p_query_input.attribute7
               , l_miss_char
               , p_query_input.attribute7
               , p_query_input.attribute7
               , p_query_input.attribute8
               , l_miss_char
               , p_query_input.attribute8
               , p_query_input.attribute8
               , p_query_input.attribute9
               , l_miss_char
               , p_query_input.attribute9
               , p_query_input.attribute9
               , p_query_input.attribute10
               , l_miss_char
               , p_query_input.attribute10
               , p_query_input.attribute10
               , p_query_input.attribute11
               , l_miss_char
               , p_query_input.attribute11
               , p_query_input.attribute11
               , p_query_input.attribute12
               , l_miss_char
               , p_query_input.attribute12
               , p_query_input.attribute12
               , p_query_input.attribute13
               , l_miss_char
               , p_query_input.attribute13
               , p_query_input.attribute13
               , p_query_input.attribute14
               , l_miss_char
               , p_query_input.attribute14
               , p_query_input.attribute14
               , p_query_input.attribute15
               , l_miss_char
               , p_query_input.attribute15
	   , p_query_input.attribute15
           /**** {{ R12 Enhanced reservations code changes }}****/
	   , p_query_input.crossdock_flag
	   , l_miss_char
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_criteria_id
	   , l_miss_num
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.demand_source_line_detail
	   , l_miss_num
	   , p_query_input.demand_source_line_detail
	   , p_query_input.demand_source_line_detail
	   , p_query_input.supply_receipt_date
	   , l_miss_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.demand_ship_date
	   , l_miss_date
	   , p_query_input.demand_ship_date
	   , p_query_input.demand_ship_date
	   , p_query_input.project_id
	   , l_miss_num
	   , p_query_input.project_id
	   , p_query_input.project_id
	   , p_query_input.task_id
	   , l_miss_num
	   , p_query_input.task_id
	   , p_query_input.task_id

           /***** End R12 ***/
	   ;
      END IF;
    ELSIF  p_query_input.inventory_item_id <> fnd_api.g_miss_num
           AND p_query_input.inventory_item_id IS NOT NULL
           AND p_query_input.organization_id <> fnd_api.g_miss_num
	     AND p_query_input.organization_id IS NOT NULL THEN
       IF (l_debug = 1) then
	  debug_print (' Inside ref cursor for item/org');
       END IF;
      -- INVCONV - Incorporate secondaries
      OPEN l_cursor_ref FOR    'SELECT
          reservation_id
        , requirement_date
        , organization_id
        , inventory_item_id
        , demand_source_type_id
        , demand_source_name
        , demand_source_header_id
        , demand_source_line_id
        , demand_source_delivery
        , primary_uom_code
        , primary_uom_id
        , secondary_uom_code
        , secondary_uom_id
        , reservation_uom_code
        , reservation_uom_id
        , reservation_quantity
        , primary_reservation_quantity
        , secondary_reservation_quantity
        , detailed_quantity
        , secondary_detailed_quantity
        , autodetail_group_id
        , external_source_code
        , external_source_line_id
        , supply_source_type_id
        , supply_source_header_id
        , supply_source_line_id
        , supply_source_name
        , supply_source_line_detail
        , revision
        , subinventory_code
        , subinventory_id
        , locator_id
        , lot_number
        , lot_number_id
        , pick_slip_number
        , lpn_id
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
        , ship_ready_flag
        , staged_flag
         /**** {{ R12 Enhanced reservations code changes. Adding new
            -- columns for query reservations }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
         , serial_number
         /***** End R12 ***/
        FROM mtl_reservations
        WHERE
        inventory_item_id = :inventory_item_id
        and organization_id = :organization_id
        AND
   (:requirement_date = :l_miss_date
         OR :requirement_date IS NULL
         AND requirement_date IS NULL
         OR :requirement_date
         = requirement_date
         )
  AND
  (:demand_source_type_id = :l_miss_num
         OR :demand_source_type_id IS NULL
         AND demand_source_type_id IS NULL
         OR :demand_source_type_id
         = demand_source_type_id
         )
        AND
        (:demand_source_header_id = :l_miss_num
         OR :demand_source_header_id IS NULL
         AND demand_source_header_id IS NULL
         OR :demand_source_header_id
         = demand_source_header_id
         )
        AND
        (:demand_source_line_id = :l_miss_num
         OR :demand_source_line_id IS NULL
         AND demand_source_line_id IS NULL
         OR :demand_source_line_id = demand_source_line_id
         )
        AND
        (:demand_source_name = :l_miss_char
         OR :demand_source_name IS NULL
         AND demand_source_name IS NULL
         OR :demand_source_name = demand_source_name
         )
        AND
        (:demand_source_delivery = :l_miss_num
         OR :demand_source_delivery IS NULL
         AND demand_source_delivery IS NULL
         OR :demand_source_delivery = demand_source_delivery
         )
      AND
        (:primary_uom_code = :l_miss_char
         OR :primary_uom_code IS NULL
         AND primary_uom_code IS NULL
         OR :primary_uom_code = primary_uom_code
         )
        AND
        (:primary_uom_id = :l_miss_num
         OR :primary_uom_id IS NULL
         AND primary_uom_id IS NULL
         OR :primary_uom_id = primary_uom_id
         )
         -- INVCONV BEGIN
        AND
        (:secondary_uom_code = :l_miss_char
         OR :secondary_uom_code IS NULL
         AND secondary_uom_code IS NULL
         OR :secondary_uom_code = secondary_uom_code
         )
        AND
        (:secondary_uom_id = :l_miss_num
         OR :secondary_uom_id IS NULL
         AND secondary_uom_id IS NULL
         OR :secondary_uom_id = secondary_uom_id
         )
        -- INVCONV END
        AND
        (:reservation_uom_code = :l_miss_char
         OR :reservation_uom_code IS NULL
         AND reservation_uom_code IS NULL
         OR :reservation_uom_code = reservation_uom_code
         )
        AND
        (:reservation_uom_id = :l_miss_num
         OR :reservation_uom_id IS NULL
         AND reservation_uom_id IS NULL
         OR :reservation_uom_id = reservation_uom_id
         )
        AND
        (:autodetail_group_id = :l_miss_num
         OR :autodetail_group_id IS NULL
         AND autodetail_group_id IS NULL
         OR :autodetail_group_id = autodetail_group_id
         )
        AND
        (:external_source_code = :l_miss_char
         OR :external_source_code IS NULL
         AND external_source_code IS NULL
         OR :external_source_code = external_source_code
         )
        AND
        (:external_source_line_id = :l_miss_num
         OR :external_source_line_id IS NULL
         AND external_source_line_id IS NULL
         OR :external_source_line_id = external_source_line_id
         )
        AND
        (:supply_source_type_id = :l_miss_num
         OR :supply_source_type_id IS NULL
         AND supply_source_type_id IS NULL
         OR :supply_source_type_id = supply_source_type_id
         )
        AND
        (:supply_source_header_id = :l_miss_num
         OR :supply_source_header_id IS NULL
         AND supply_source_header_id IS NULL
         OR :supply_source_header_id
         = supply_source_header_id
         )
        AND
        (:supply_source_line_id = :l_miss_num
         OR :supply_source_line_id IS NULL
         AND supply_source_line_id IS NULL
         OR :supply_source_line_id = supply_source_line_id
         )
        AND
        (:supply_source_name = :l_miss_char
         OR :supply_source_name IS NULL
         AND supply_source_name IS NULL
         OR :supply_source_name = supply_source_name
         )
        AND
        (:supply_source_line_detail = :l_miss_num
         OR :supply_source_line_detail IS NULL
         AND supply_source_line_detail IS NULL
         OR :supply_source_line_detail
         = supply_source_line_detail
         )
        AND
        (:revision = :l_miss_char
         OR :revision IS NULL
         AND revision IS NULL
         OR :revision = revision
         )
        AND
        (:subinventory_code = :l_miss_char
         OR :subinventory_code IS NULL
         AND subinventory_code IS NULL
         OR :subinventory_code = subinventory_code
         )
       AND
        (:subinventory_id = :l_miss_num
         OR :subinventory_id IS NULL
         AND subinventory_id IS NULL
         OR :subinventory_id = subinventory_id
         )
        AND
        (:locator_id = :l_miss_num
         OR :locator_id IS NULL
         AND locator_id IS NULL
         OR :locator_id = locator_id
         )
        AND
        (:lot_number = :l_miss_char
         OR :lot_number IS NULL
         AND lot_number IS NULL
         OR :lot_number = lot_number
         )
        AND
        (:lot_number_id = :l_miss_num
         OR :lot_number_id IS NULL
         AND lot_number_id IS NULL
         OR :lot_number_id = lot_number_id
         )
        AND
        (:lpn_id = :l_miss_num
         OR :lpn_id IS NULL
         AND lpn_id IS NULL
         OR :lpn_id = lpn_id
         )
        AND
        (:ship_ready_flag = :l_miss_num
         OR (:ship_ready_flag IS NULL OR :ship_ready_flag = 2)
         AND (ship_ready_flag IS NULL OR ship_ready_flag = 2)
         OR :ship_ready_flag = ship_ready_flag
         )
        AND
        (:staged_flag = :l_miss_char
         OR (:staged_flag IS NULL OR :staged_flag = ''N'')
         AND (staged_flag IS NULL OR staged_flag = ''N'')
         OR :staged_flag = staged_flag
         )
        AND
        (:attribute_category = :l_miss_char
         OR :attribute_category IS NULL
         AND attribute_category IS NULL
         OR :attribute_category = attribute_category
         )
        AND
        (:attribute1 = :l_miss_char
         OR :attribute1 IS NULL
         AND attribute1 IS NULL
         OR :attribute1 = attribute1
         )
       AND
        (:attribute2 = :l_miss_char
         OR :attribute2 IS NULL
         AND attribute2 IS NULL
         OR :attribute2 = attribute2
         )
        AND
        (:attribute3 = :l_miss_char
         OR :attribute3 IS NULL
         AND attribute3 IS NULL
         OR :attribute3 = attribute3
         )
        AND
        (:attribute4 = :l_miss_char
         OR :attribute4 IS NULL
         AND attribute4 IS NULL
         OR :attribute4 = attribute4
         )
       AND
        (:attribute5 = :l_miss_char
         OR :attribute5 IS NULL
         AND attribute5 IS NULL
         OR :attribute5 = attribute5
         )
        AND
        (:attribute6 = :l_miss_char
         OR :attribute6 IS NULL
         AND attribute6 IS NULL
         OR :attribute6 = attribute6
         )
        AND
        (:attribute7 = :l_miss_char
         OR :attribute7 IS NULL
         AND attribute7 IS NULL
         OR :attribute7 = attribute7
         )
        AND
        (:attribute8 = :l_miss_char
         OR :attribute8 IS NULL
         AND attribute8 IS NULL
         OR :attribute8 = attribute8
         )
        AND
        (:attribute9 = :l_miss_char
         OR :attribute9 IS NULL
         AND attribute9 IS NULL
         OR :attribute9 = attribute9
         )
        AND
        (:attribute10 = :l_miss_char
         OR :attribute10 IS NULL
         AND attribute10 IS NULL
         OR :attribute10 = attribute10
         )
        AND
        (:attribute11 = :l_miss_char
         OR :attribute11 IS NULL
         AND attribute11 IS NULL
         OR :attribute11 = attribute11
         )
        AND
        (:attribute12 = :l_miss_char
         OR :attribute12 IS NULL
         AND attribute12 IS NULL
         OR :attribute12 = attribute12
         )
        AND
        (:attribute13 = :l_miss_char
         OR :attribute13 IS NULL
         AND attribute13 IS NULL
         OR :attribute13 = attribute13
         )
        AND
        (:attribute14 = :l_miss_char
         OR :attribute14 IS NULL
         AND attribute14 IS NULL
         OR :attribute14 = attribute14
         )
        AND
        (:attribute15 = :l_miss_char
         OR :attribute15 IS NULL
         AND attribute15 IS NULL
         OR :attribute15 = attribute15
         )

/**** {{ R12 Enhanced reservations code changes }}****/
	AND
	   (:crossdock_flag = :l_miss_char
         OR :crossdock_flag IS NULL
         AND crossdock_flag IS NULL
         OR :crossdock_flag = crossdock_flag
         )
	AND
	   (:crossdock_criteria_id = :l_miss_num
         OR :crossdock_criteria_id IS NULL
         AND crossdock_criteria_id IS NULL
         OR :crossdock_criteria_id = crossdock_criteria_id
	    )
        AND
	   (:demand_source_line_detail = :l_miss_num
         OR :demand_source_line_detail IS NULL
         AND demand_source_line_detail IS NULL
         OR :demand_source_line_detail = demand_source_line_detail
	    )
	AND
	   (:supply_receipt_date = :l_miss_date
         OR :supply_receipt_date IS NULL
         AND supply_receipt_date IS NULL
         OR :supply_receipt_date = supply_receipt_date
	    )
	AND
	   (:demand_ship_date = :l_miss_date
         OR :demand_ship_date IS NULL
         AND demand_ship_date IS NULL
         OR :demand_ship_date = demand_ship_date
	    )
	AND
	   (:project_id = :l_miss_num
         OR :project_id IS NULL
         AND project_id IS NULL
         OR :project_id = project_id
	    )
	 AND
	   (:task_id = :l_miss_num
         OR :task_id IS NULL
         AND task_id IS NULL
         OR :task_id = task_id
	    )
/***** End R12 ***/

  '
                            || l_lock_stmt
                            || l_sort_stmt
        USING  p_query_input.inventory_item_id
             , p_query_input.organization_id
             , p_query_input.requirement_date
             , l_miss_date
             , p_query_input.requirement_date
             , p_query_input.requirement_date
             , p_query_input.demand_source_type_id
             , l_miss_num
             , p_query_input.demand_source_type_id
             , p_query_input.demand_source_type_id
             , p_query_input.demand_source_header_id
             , l_miss_num
             , p_query_input.demand_source_header_id
             , p_query_input.demand_source_header_id
             , p_query_input.demand_source_line_id
             , l_miss_num
             , p_query_input.demand_source_line_id
             , p_query_input.demand_source_line_id
             , p_query_input.demand_source_name
             , l_miss_char
             , p_query_input.demand_source_name
             , p_query_input.demand_source_name
             , p_query_input.demand_source_delivery
             , l_miss_num
             , p_query_input.demand_source_delivery
             , p_query_input.demand_source_delivery
             , p_query_input.primary_uom_code
             , l_miss_char
             , p_query_input.primary_uom_code
             , p_query_input.primary_uom_code
             , p_query_input.primary_uom_id
             , l_miss_num
             , p_query_input.primary_uom_id
             , p_query_input.primary_uom_id
              -- INVCONV BEGIN
             , p_query_input.secondary_uom_code
             , l_miss_char
             , p_query_input.secondary_uom_code
             , p_query_input.secondary_uom_code
             , p_query_input.secondary_uom_id
             , l_miss_num
             , p_query_input.secondary_uom_id
             , p_query_input.secondary_uom_id
             -- INVCONV END
             , p_query_input.reservation_uom_code
             , l_miss_char
             , p_query_input.reservation_uom_code
             , p_query_input.reservation_uom_code
             , p_query_input.reservation_uom_id
             , l_miss_num
             , p_query_input.reservation_uom_id
             , p_query_input.reservation_uom_id
             , p_query_input.autodetail_group_id
             , l_miss_num
             , p_query_input.autodetail_group_id
             , p_query_input.autodetail_group_id
             , p_query_input.external_source_code
             , l_miss_char
             , p_query_input.external_source_code
             , p_query_input.external_source_code
             , p_query_input.external_source_line_id
             , l_miss_num
             , p_query_input.external_source_line_id
             , p_query_input.external_source_line_id
             , p_query_input.supply_source_type_id
             , l_miss_num
             , p_query_input.supply_source_type_id
             , p_query_input.supply_source_type_id
             , p_query_input.supply_source_header_id
             , l_miss_num
             , p_query_input.supply_source_header_id
             , p_query_input.supply_source_header_id
             , p_query_input.supply_source_line_id
             , l_miss_num
             , p_query_input.supply_source_line_id
             , p_query_input.supply_source_line_id
             , p_query_input.supply_source_name
             , l_miss_char
             , p_query_input.supply_source_name
             , p_query_input.supply_source_name
             , p_query_input.supply_source_line_detail
             , l_miss_num
             , p_query_input.supply_source_line_detail
             , p_query_input.supply_source_line_detail
             , p_query_input.revision
             , l_miss_char
             , p_query_input.revision
             , p_query_input.revision
             , p_query_input.subinventory_code
             , l_miss_char
             , p_query_input.subinventory_code
             , p_query_input.subinventory_code
             , p_query_input.subinventory_id
             , l_miss_num
             , p_query_input.subinventory_id
             , p_query_input.subinventory_id
             , p_query_input.locator_id
             , l_miss_num
             , p_query_input.locator_id
             , p_query_input.locator_id
             , p_query_input.lot_number
             , l_miss_char
             , p_query_input.lot_number
             , p_query_input.lot_number
             , p_query_input.lot_number_id
             , l_miss_num
             , p_query_input.lot_number_id
             , p_query_input.lot_number_id
             , p_query_input.lpn_id
             , l_miss_num
             , p_query_input.lpn_id
             , p_query_input.lpn_id
             , p_query_input.ship_ready_flag
             , l_miss_num
             , p_query_input.ship_ready_flag
             , p_query_input.ship_ready_flag
             , p_query_input.ship_ready_flag
             , p_query_input.staged_flag
             , l_miss_char
             , p_query_input.staged_flag
             , p_query_input.staged_flag
             , p_query_input.staged_flag
             , p_query_input.attribute_category
             , l_miss_char
             , p_query_input.attribute_category
             , p_query_input.attribute_category
             , p_query_input.attribute1
             , l_miss_char
             , p_query_input.attribute1
             , p_query_input.attribute1
             , p_query_input.attribute2
             , l_miss_char
             , p_query_input.attribute2
             , p_query_input.attribute2
             , p_query_input.attribute3
             , l_miss_char
             , p_query_input.attribute3
             , p_query_input.attribute3
             , p_query_input.attribute4
             , l_miss_char
             , p_query_input.attribute4
             , p_query_input.attribute4
             , p_query_input.attribute5
             , l_miss_char
             , p_query_input.attribute5
             , p_query_input.attribute5
             , p_query_input.attribute6
             , l_miss_char
             , p_query_input.attribute6
             , p_query_input.attribute6
             , p_query_input.attribute7
             , l_miss_char
             , p_query_input.attribute7
             , p_query_input.attribute7
             , p_query_input.attribute8
             , l_miss_char
             , p_query_input.attribute8
             , p_query_input.attribute8
             , p_query_input.attribute9
             , l_miss_char
             , p_query_input.attribute9
             , p_query_input.attribute9
             , p_query_input.attribute10
             , l_miss_char
             , p_query_input.attribute10
             , p_query_input.attribute10
             , p_query_input.attribute11
             , l_miss_char
             , p_query_input.attribute11
             , p_query_input.attribute11
             , p_query_input.attribute12
             , l_miss_char
             , p_query_input.attribute12
             , p_query_input.attribute12
             , p_query_input.attribute13
             , l_miss_char
             , p_query_input.attribute13
             , p_query_input.attribute13
             , p_query_input.attribute14
             , l_miss_char
             , p_query_input.attribute14
             , p_query_input.attribute14
             , p_query_input.attribute15
             , l_miss_char
             , p_query_input.attribute15
	   , p_query_input.attribute15
 /**** {{ R12 Enhanced reservations code changes }}****/
	   , p_query_input.crossdock_flag
	   , l_miss_char
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_criteria_id
	   , l_miss_num
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.demand_source_line_detail
	   , l_miss_num
	   , p_query_input.demand_source_line_detail
	   , p_query_input.demand_source_line_detail
	   , p_query_input.supply_receipt_date
	   , l_miss_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.demand_ship_date
	   , l_miss_date
	   , p_query_input.demand_ship_date
	   , p_query_input.demand_ship_date
	   , p_query_input.project_id
	   , l_miss_num
	   , p_query_input.project_id
	   , p_query_input.project_id
	   , p_query_input.task_id
	   , l_miss_num
	   , p_query_input.task_id
	   , p_query_input.task_id
           /***** End R12 ***/
	   ;

      -- kkoothan Added the following  ELSE IF section as part of Bug Fix:2783806
      ELSIF p_query_input.supply_source_header_id <  fnd_api.g_miss_num
       AND p_query_input.supply_source_header_id IS NOT NULL
--      Bug 4881317 checking these conditions later
--      AND p_query_input.supply_source_line_id <  fnd_api.g_miss_num
--      AND p_query_input.supply_source_line_id IS NOT NULL
       AND p_query_input.supply_source_type_id <  fnd_api.g_miss_num
	 AND p_query_input.supply_source_type_id IS NOT NULL  THEN
       IF (l_debug = 1) then
	  debug_print(' Inside ref cursor for supply');
       END IF;
        -- INVCONV - Incorporate secondaries
      l_qry_stmt:= 'SELECT
            reservation_id
          , requirement_date
          , organization_id
          , inventory_item_id
          , demand_source_type_id
          , demand_source_name
          , demand_source_header_id
          , demand_source_line_id
          , demand_source_delivery
          , primary_uom_code
          , primary_uom_id
          , secondary_uom_code
          , secondary_uom_id
          , reservation_uom_code
          , reservation_uom_id
          , reservation_quantity
          , primary_reservation_quantity
          , secondary_reservation_quantity
          , detailed_quantity
          , secondary_detailed_quantity
          , autodetail_group_id
          , external_source_code
          , external_source_line_id
          , supply_source_type_id
          , supply_source_header_id
          , supply_source_line_id
          , supply_source_name
          , supply_source_line_detail
          , revision
          , subinventory_code
          , subinventory_id
          , locator_id
          , lot_number
          , lot_number_id
          , pick_slip_number
          , lpn_id
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
          , ship_ready_flag
          , staged_flag
	  /**** {{ R12 Enhanced reservations code changes }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
         , serial_number
	 /***** End R12 ***/
          FROM mtl_reservations
          WHERE
          supply_source_header_id = :supply_source_header_id
          and supply_source_type_id = :supply_source_type_id
          AND
           (:requirement_date = :l_miss_date
           OR :requirement_date IS NULL
           AND requirement_date IS NULL
           OR :requirement_date
           = requirement_date
           )
          AND
          (:organization_id = :l_miss_num
           OR :organization_id IS NULL
           AND organization_id IS NULL
           OR :organization_id = organization_id
           )
          AND
          (:inventory_item_id = :l_miss_num
           OR :inventory_item_id IS NULL
           AND inventory_item_id IS NULL
           OR :inventory_item_id = inventory_item_id
           )
          AND
          (:demand_source_type_id = :l_miss_num
           OR :demand_source_type_id IS NULL
           AND demand_source_type_id IS NULL
           OR :demand_source_type_id
           = demand_source_type_id
           )
          AND
          (:demand_source_header_id = :l_miss_num
           OR :demand_source_header_id IS NULL
           AND demand_source_header_id IS NULL
           OR :demand_source_header_id
           = demand_source_header_id
           )
          AND
          (:demand_source_line_id = :l_miss_num
           OR :demand_source_line_id IS NULL
           AND demand_source_line_id IS NULL
           OR :demand_source_line_id = demand_source_line_id
           )
          AND
          (:demand_source_name = :l_miss_char
           OR :demand_source_name IS NULL
           AND demand_source_name IS NULL
           OR :demand_source_name = demand_source_name
           )
          AND
          (:demand_source_delivery = :l_miss_num
           OR :demand_source_delivery IS NULL
           AND demand_source_delivery IS NULL
           OR :demand_source_delivery = demand_source_delivery
           )
        AND
          (:primary_uom_code = :l_miss_char
           OR :primary_uom_code IS NULL
           AND primary_uom_code IS NULL
           OR :primary_uom_code = primary_uom_code
           )
          AND
          (:primary_uom_id = :l_miss_num
           OR :primary_uom_id IS NULL
           AND primary_uom_id IS NULL
           OR :primary_uom_id = primary_uom_id
           )
           -- INVCONV BEGIN
          AND
          (:secondary_uom_code = :l_miss_char
           OR :secondary_uom_code IS NULL
           AND secondary_uom_code IS NULL
           OR :secondary_uom_code = secondary_uom_code
           )
          AND
          (:secondary_uom_id = :l_miss_num
           OR :secondary_uom_id IS NULL
           AND secondary_uom_id IS NULL
           OR :secondary_uom_id = secondary_uom_id
           )
          -- INVCONV END
          AND
          (:reservation_uom_code = :l_miss_char
           OR :reservation_uom_code IS NULL
           AND reservation_uom_code IS NULL
           OR :reservation_uom_code = reservation_uom_code
           )
          AND
          (:reservation_uom_id = :l_miss_num
           OR :reservation_uom_id IS NULL
           AND reservation_uom_id IS NULL
           OR :reservation_uom_id = reservation_uom_id
           )
          AND
          (:autodetail_group_id = :l_miss_num
           OR :autodetail_group_id IS NULL
           AND autodetail_group_id IS NULL
           OR :autodetail_group_id = autodetail_group_id
           )
          AND
          (:external_source_code = :l_miss_char
           OR :external_source_code IS NULL
           AND external_source_code IS NULL
           OR :external_source_code = external_source_code
           )
          AND
          (:external_source_line_id = :l_miss_num
           OR :external_source_line_id IS NULL
           AND external_source_line_id IS NULL
           OR :external_source_line_id = external_source_line_id
           )
          AND
          (:supply_source_name = :l_miss_char
           OR :supply_source_name IS NULL
           AND supply_source_name IS NULL
           OR :supply_source_name = supply_source_name
           )
          AND
          (:supply_source_line_detail = :l_miss_num
           OR :supply_source_line_detail IS NULL
           AND supply_source_line_detail IS NULL
           OR :supply_source_line_detail
           = supply_source_line_detail
           )
          AND
          (:revision = :l_miss_char
           OR :revision IS NULL
           AND revision IS NULL
           OR :revision = revision
           )
          AND
          (:subinventory_code = :l_miss_char
           OR :subinventory_code IS NULL
           AND subinventory_code IS NULL
           OR :subinventory_code = subinventory_code
           )
         AND
          (:subinventory_id = :l_miss_num
           OR :subinventory_id IS NULL
           AND subinventory_id IS NULL
           OR :subinventory_id = subinventory_id
           )
          AND
          (:locator_id = :l_miss_num
           OR :locator_id IS NULL
           AND locator_id IS NULL
           OR :locator_id = locator_id
           )
          AND
          (:lot_number = :l_miss_char
           OR :lot_number IS NULL
           AND lot_number IS NULL
           OR :lot_number = lot_number
           )
          AND
          (:lot_number_id = :l_miss_num
           OR :lot_number_id IS NULL
           AND lot_number_id IS NULL
           OR :lot_number_id = lot_number_id
           )
          AND
          (:lpn_id = :l_miss_num
           OR :lpn_id IS NULL
           AND lpn_id IS NULL
           OR :lpn_id = lpn_id
           )
          AND
          (:ship_ready_flag = :l_miss_num
           OR (:ship_ready_flag IS NULL OR :ship_ready_flag = 2)
           AND (ship_ready_flag IS NULL OR ship_ready_flag = 2)
           OR :ship_ready_flag = ship_ready_flag
           )
          AND
          (:staged_flag = :l_miss_char
           OR (:staged_flag IS NULL OR :staged_flag = ''N'')
           AND (staged_flag IS NULL OR staged_flag = ''N'')
           OR :staged_flag = staged_flag
           )
          AND
          (:attribute_category = :l_miss_char
           OR :attribute_category IS NULL
           AND attribute_category IS NULL
           OR :attribute_category = attribute_category
           )
          AND
          (:attribute1 = :l_miss_char
           OR :attribute1 IS NULL
           AND attribute1 IS NULL
           OR :attribute1 = attribute1
           )
         AND
          (:attribute2 = :l_miss_char
           OR :attribute2 IS NULL
           AND attribute2 IS NULL
           OR :attribute2 = attribute2
           )
          AND
          (:attribute3 = :l_miss_char
           OR :attribute3 IS NULL
           AND attribute3 IS NULL
           OR :attribute3 = attribute3
           )
          AND
          (:attribute4 = :l_miss_char
           OR :attribute4 IS NULL
           AND attribute4 IS NULL
           OR :attribute4 = attribute4
           )
         AND
          (:attribute5 = :l_miss_char
           OR :attribute5 IS NULL
           AND attribute5 IS NULL
           OR :attribute5 = attribute5
           )
          AND
          (:attribute6 = :l_miss_char
           OR :attribute6 IS NULL
           AND attribute6 IS NULL
           OR :attribute6 = attribute6
           )
          AND
          (:attribute7 = :l_miss_char
           OR :attribute7 IS NULL
           AND attribute7 IS NULL
           OR :attribute7 = attribute7
           )
          AND
          (:attribute8 = :l_miss_char
           OR :attribute8 IS NULL
           AND attribute8 IS NULL
           OR :attribute8 = attribute8
           )
          AND
          (:attribute9 = :l_miss_char
           OR :attribute9 IS NULL
           AND attribute9 IS NULL
           OR :attribute9 = attribute9
           )
          AND
          (:attribute10 = :l_miss_char
           OR :attribute10 IS NULL
           AND attribute10 IS NULL
           OR :attribute10 = attribute10
           )
          AND
          (:attribute11 = :l_miss_char
           OR :attribute11 IS NULL
           AND attribute11 IS NULL
           OR :attribute11 = attribute11
           )
          AND
          (:attribute12 = :l_miss_char
           OR :attribute12 IS NULL
           AND attribute12 IS NULL
           OR :attribute12 = attribute12
           )
          AND
          (:attribute13 = :l_miss_char
           OR :attribute13 IS NULL
           AND attribute13 IS NULL
           OR :attribute13 = attribute13
           )
          AND
          (:attribute14 = :l_miss_char
           OR :attribute14 IS NULL
           AND attribute14 IS NULL
           OR :attribute14 = attribute14
           )
          AND
          (:attribute15 = :l_miss_char
           OR :attribute15 IS NULL
           AND attribute15 IS NULL
           OR :attribute15 = attribute15
           )
/**** {{ R12 Enhanced reservations code changes }}****/
	AND
	   (:crossdock_flag = :l_miss_char
         OR :crossdock_flag IS NULL
         AND crossdock_flag IS NULL
         OR :crossdock_flag = crossdock_flag
         )
	AND
	   (:crossdock_criteria_id = :l_miss_num
         OR :crossdock_criteria_id IS NULL
         AND crossdock_criteria_id IS NULL
         OR :crossdock_criteria_id = crossdock_criteria_id
	    )
        AND
	   (:demand_source_line_detail = :l_miss_num
         OR :demand_source_line_detail IS NULL
         AND demand_source_line_detail IS NULL
         OR :demand_source_line_detail = demand_source_line_detail
	    )
	AND
	   (:supply_receipt_date = :l_miss_date
         OR :supply_receipt_date IS NULL
         AND supply_receipt_date IS NULL
         OR :supply_receipt_date = supply_receipt_date
	    )
	AND
	   (:demand_ship_date = :l_miss_date
         OR :demand_ship_date IS NULL
         AND demand_ship_date IS NULL
         OR :demand_ship_date = demand_ship_date
	    )
	AND
	   (:project_id = :l_miss_num
         OR :project_id IS NULL
         AND project_id IS NULL
         OR :project_id = project_id
	    )
	 AND
	   (:task_id = :l_miss_num
         OR :task_id IS NULL
         AND task_id IS NULL
         OR :task_id = task_id
	    )
         ';
/***** End R12 ***/

         --Bug 4881317 If supply_source_line_id is passed, append the condition to the query
         If  ( p_query_input.supply_source_line_id < fnd_api.g_miss_num
               AND p_query_input.supply_source_line_id IS NOT NULL )
          THEN
              OPEN l_cursor_ref FOR l_qry_stmt
                                 || 'AND supply_source_line_id = :supply_source_line_id
                                 ' || l_lock_stmt || l_sort_stmt
          using
           p_query_input.supply_source_header_id
          ,p_query_input.supply_source_type_id
          ,p_query_input.requirement_date
          ,l_miss_date
          ,p_query_input.requirement_date
          ,p_query_input.requirement_date
          ,p_query_input.organization_id
          ,l_miss_num
          ,p_query_input.organization_id
          ,p_query_input.organization_id
          ,p_query_input.inventory_item_id
          ,l_miss_num
          ,p_query_input.inventory_item_id
          ,p_query_input.inventory_item_id
          ,p_query_input.demand_source_type_id
          ,l_miss_num
          ,p_query_input.demand_source_type_id
          ,p_query_input.demand_source_type_id
          ,p_query_input.demand_source_header_id
          ,l_miss_num
          ,p_query_input.demand_source_header_id
          ,p_query_input.demand_source_header_id
          ,p_query_input.demand_source_line_id
          ,l_miss_num
          ,p_query_input.demand_source_line_id
          ,p_query_input.demand_source_line_id
          ,p_query_input.demand_source_name
          ,l_miss_char
          ,p_query_input.demand_source_name
          ,p_query_input.demand_source_name
          ,p_query_input.demand_source_delivery
          ,l_miss_num
          ,p_query_input.demand_source_delivery
          ,p_query_input.demand_source_delivery
          ,p_query_input.primary_uom_code
          ,l_miss_char
          ,p_query_input.primary_uom_code
          ,p_query_input.primary_uom_code
          ,p_query_input.primary_uom_id
          ,l_miss_num
          ,p_query_input.primary_uom_id
          ,p_query_input.primary_uom_id
          -- INVCONV BEGIN
          ,p_query_input.secondary_uom_code
          ,l_miss_char
          ,p_query_input.secondary_uom_code
          ,p_query_input.secondary_uom_code
          ,p_query_input.secondary_uom_id
          ,l_miss_num
          ,p_query_input.secondary_uom_id
          ,p_query_input.secondary_uom_id
          -- INVCONV END
          ,p_query_input.reservation_uom_code
          ,l_miss_char
          ,p_query_input.reservation_uom_code
          ,p_query_input.reservation_uom_code
          ,p_query_input.reservation_uom_id
          ,l_miss_num
          ,p_query_input.reservation_uom_id
          ,p_query_input.reservation_uom_id
          ,p_query_input.autodetail_group_id
          ,l_miss_num
          ,p_query_input.autodetail_group_id
          ,p_query_input.autodetail_group_id
          ,p_query_input.external_source_code
          ,l_miss_char
          ,p_query_input.external_source_code
          ,p_query_input.external_source_code
          ,p_query_input.external_source_line_id
          ,l_miss_num
          ,p_query_input.external_source_line_id
          ,p_query_input.external_source_line_id
          ,p_query_input.supply_source_name
          ,l_miss_char
          ,p_query_input.supply_source_name
          ,p_query_input.supply_source_name
          ,p_query_input.supply_source_line_detail
          ,l_miss_num
          ,p_query_input.supply_source_line_detail
          ,p_query_input.supply_source_line_detail
          ,p_query_input.revision
          ,l_miss_char
          ,p_query_input.revision
          ,p_query_input.revision
          ,p_query_input.subinventory_code
          ,l_miss_char
          ,p_query_input.subinventory_code
          ,p_query_input.subinventory_code
          ,p_query_input.subinventory_id
          ,l_miss_num
          ,p_query_input.subinventory_id
          ,p_query_input.subinventory_id
          ,p_query_input.locator_id
          ,l_miss_num
          ,p_query_input.locator_id
          ,p_query_input.locator_id
          ,p_query_input.lot_number
          ,l_miss_char
          ,p_query_input.lot_number
          ,p_query_input.lot_number
          ,p_query_input.lot_number_id
          ,l_miss_num
          ,p_query_input.lot_number_id
          ,p_query_input.lot_number_id
          ,p_query_input.lpn_id
          ,l_miss_num
          ,p_query_input.lpn_id
          ,p_query_input.lpn_id
          ,p_query_input.ship_ready_flag
          ,l_miss_num
          ,p_query_input.ship_ready_flag
          ,p_query_input.ship_ready_flag
          ,p_query_input.ship_ready_flag
          ,p_query_input.staged_flag
          ,l_miss_char
          ,p_query_input.staged_flag
          ,p_query_input.staged_flag
          ,p_query_input.staged_flag
          ,p_query_input.attribute_category
          ,l_miss_char
          ,p_query_input.attribute_category
          ,p_query_input.attribute_category
          ,p_query_input.attribute1
          ,l_miss_char
          ,p_query_input.attribute1
          ,p_query_input.attribute1
          ,p_query_input.attribute2
          ,l_miss_char
          ,p_query_input.attribute2
          ,p_query_input.attribute2
          ,p_query_input.attribute3
          ,l_miss_char
          ,p_query_input.attribute3
          ,p_query_input.attribute3
          ,p_query_input.attribute4
          ,l_miss_char
          ,p_query_input.attribute4
          ,p_query_input.attribute4
          ,p_query_input.attribute5
          ,l_miss_char
          ,p_query_input.attribute5
          ,p_query_input.attribute5
          ,p_query_input.attribute6
          ,l_miss_char
          ,p_query_input.attribute6
          ,p_query_input.attribute6
          ,p_query_input.attribute7
          ,l_miss_char
          ,p_query_input.attribute7
          ,p_query_input.attribute7
          ,p_query_input.attribute8
          ,l_miss_char
          ,p_query_input.attribute8
          ,p_query_input.attribute8
          ,p_query_input.attribute9
          ,l_miss_char
          ,p_query_input.attribute9
          ,p_query_input.attribute9
          ,p_query_input.attribute10
          ,l_miss_char
          ,p_query_input.attribute10
          ,p_query_input.attribute10
          ,p_query_input.attribute11
          ,l_miss_char
          ,p_query_input.attribute11
          ,p_query_input.attribute11
          ,p_query_input.attribute12
          ,l_miss_char
          ,p_query_input.attribute12
          ,p_query_input.attribute12
          ,p_query_input.attribute13
          ,l_miss_char
          ,p_query_input.attribute13
          ,p_query_input.attribute13
          ,p_query_input.attribute14
          ,l_miss_char
          ,p_query_input.attribute14
          ,p_query_input.attribute14
          ,p_query_input.attribute15
          ,l_miss_char
          ,p_query_input.attribute15
	     ,p_query_input.attribute15
 /**** {{ R12 Enhanced reservations code changes }}****/
	   , p_query_input.crossdock_flag
	   , l_miss_char
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_criteria_id
	   , l_miss_num
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.demand_source_line_detail
	   , l_miss_num
	   , p_query_input.demand_source_line_detail
	   , p_query_input.demand_source_line_detail
	   , p_query_input.supply_receipt_date
	   , l_miss_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.demand_ship_date
	   , l_miss_date
	   , p_query_input.demand_ship_date
	   , p_query_input.demand_ship_date
	   , p_query_input.project_id
	   , l_miss_num
	   , p_query_input.project_id
	   , p_query_input.project_id
	   , p_query_input.task_id
	   , l_miss_num
	   , p_query_input.task_id
	   , p_query_input.task_id
           ,p_query_input.supply_source_line_id

	   /***** End R12 ***/
	     ;
           ELSE
              OPEN l_cursor_ref FOR l_qry_stmt
                                 || l_lock_stmt || l_sort_stmt
          using
           p_query_input.supply_source_header_id
          ,p_query_input.supply_source_type_id
          ,p_query_input.requirement_date
          ,l_miss_date
          ,p_query_input.requirement_date
          ,p_query_input.requirement_date
          ,p_query_input.organization_id
          ,l_miss_num
          ,p_query_input.organization_id
          ,p_query_input.organization_id
          ,p_query_input.inventory_item_id
          ,l_miss_num
          ,p_query_input.inventory_item_id
          ,p_query_input.inventory_item_id
          ,p_query_input.demand_source_type_id
          ,l_miss_num
          ,p_query_input.demand_source_type_id
          ,p_query_input.demand_source_type_id
          ,p_query_input.demand_source_header_id
          ,l_miss_num
          ,p_query_input.demand_source_header_id
          ,p_query_input.demand_source_header_id
          ,p_query_input.demand_source_line_id
          ,l_miss_num
          ,p_query_input.demand_source_line_id
          ,p_query_input.demand_source_line_id
          ,p_query_input.demand_source_name
          ,l_miss_char
          ,p_query_input.demand_source_name
          ,p_query_input.demand_source_name
          ,p_query_input.demand_source_delivery
          ,l_miss_num
          ,p_query_input.demand_source_delivery
          ,p_query_input.demand_source_delivery
          ,p_query_input.primary_uom_code
          ,l_miss_char
          ,p_query_input.primary_uom_code
          ,p_query_input.primary_uom_code
          ,p_query_input.primary_uom_id
          ,l_miss_num
          ,p_query_input.primary_uom_id
          ,p_query_input.primary_uom_id
          -- INVCONV BEGIN
          ,p_query_input.secondary_uom_code
          ,l_miss_char
          ,p_query_input.secondary_uom_code
          ,p_query_input.secondary_uom_code
          ,p_query_input.secondary_uom_id
          ,l_miss_num
          ,p_query_input.secondary_uom_id
          ,p_query_input.secondary_uom_id
          -- INVCONV END
          ,p_query_input.reservation_uom_code
          ,l_miss_char
          ,p_query_input.reservation_uom_code
          ,p_query_input.reservation_uom_code
          ,p_query_input.reservation_uom_id
          ,l_miss_num
          ,p_query_input.reservation_uom_id
          ,p_query_input.reservation_uom_id
          ,p_query_input.autodetail_group_id
          ,l_miss_num
          ,p_query_input.autodetail_group_id
          ,p_query_input.autodetail_group_id
          ,p_query_input.external_source_code
          ,l_miss_char
          ,p_query_input.external_source_code
          ,p_query_input.external_source_code
          ,p_query_input.external_source_line_id
          ,l_miss_num
          ,p_query_input.external_source_line_id
          ,p_query_input.external_source_line_id
          ,p_query_input.supply_source_name
          ,l_miss_char
          ,p_query_input.supply_source_name
          ,p_query_input.supply_source_name
          ,p_query_input.supply_source_line_detail
          ,l_miss_num
          ,p_query_input.supply_source_line_detail
          ,p_query_input.supply_source_line_detail
          ,p_query_input.revision
          ,l_miss_char
          ,p_query_input.revision
          ,p_query_input.revision
          ,p_query_input.subinventory_code
          ,l_miss_char
          ,p_query_input.subinventory_code
          ,p_query_input.subinventory_code
          ,p_query_input.subinventory_id
          ,l_miss_num
          ,p_query_input.subinventory_id
          ,p_query_input.subinventory_id
          ,p_query_input.locator_id
          ,l_miss_num
          ,p_query_input.locator_id
          ,p_query_input.locator_id
          ,p_query_input.lot_number
          ,l_miss_char
          ,p_query_input.lot_number
          ,p_query_input.lot_number
          ,p_query_input.lot_number_id
          ,l_miss_num
          ,p_query_input.lot_number_id
          ,p_query_input.lot_number_id
          ,p_query_input.lpn_id
          ,l_miss_num
          ,p_query_input.lpn_id
          ,p_query_input.lpn_id
          ,p_query_input.ship_ready_flag
          ,l_miss_num
          ,p_query_input.ship_ready_flag
          ,p_query_input.ship_ready_flag
          ,p_query_input.ship_ready_flag
          ,p_query_input.staged_flag
          ,l_miss_char
          ,p_query_input.staged_flag
          ,p_query_input.staged_flag
          ,p_query_input.staged_flag
          ,p_query_input.attribute_category
          ,l_miss_char
          ,p_query_input.attribute_category
          ,p_query_input.attribute_category
          ,p_query_input.attribute1
          ,l_miss_char
          ,p_query_input.attribute1
          ,p_query_input.attribute1
          ,p_query_input.attribute2
          ,l_miss_char
          ,p_query_input.attribute2
          ,p_query_input.attribute2
          ,p_query_input.attribute3
          ,l_miss_char
          ,p_query_input.attribute3
          ,p_query_input.attribute3
          ,p_query_input.attribute4
          ,l_miss_char
          ,p_query_input.attribute4
          ,p_query_input.attribute4
          ,p_query_input.attribute5
          ,l_miss_char
          ,p_query_input.attribute5
          ,p_query_input.attribute5
          ,p_query_input.attribute6
          ,l_miss_char
          ,p_query_input.attribute6
          ,p_query_input.attribute6
          ,p_query_input.attribute7
          ,l_miss_char
          ,p_query_input.attribute7
          ,p_query_input.attribute7
          ,p_query_input.attribute8
          ,l_miss_char
          ,p_query_input.attribute8
          ,p_query_input.attribute8
          ,p_query_input.attribute9
          ,l_miss_char
          ,p_query_input.attribute9
          ,p_query_input.attribute9
          ,p_query_input.attribute10
          ,l_miss_char
          ,p_query_input.attribute10
          ,p_query_input.attribute10
          ,p_query_input.attribute11
          ,l_miss_char
          ,p_query_input.attribute11
          ,p_query_input.attribute11
          ,p_query_input.attribute12
          ,l_miss_char
          ,p_query_input.attribute12
          ,p_query_input.attribute12
          ,p_query_input.attribute13
          ,l_miss_char
          ,p_query_input.attribute13
          ,p_query_input.attribute13
          ,p_query_input.attribute14
          ,l_miss_char
          ,p_query_input.attribute14
          ,p_query_input.attribute14
          ,p_query_input.attribute15
          ,l_miss_char
          ,p_query_input.attribute15
	     ,p_query_input.attribute15
 /**** {{ R12 Enhanced reservations code changes }}****/
	   , p_query_input.crossdock_flag
	   , l_miss_char
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_criteria_id
	   , l_miss_num
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.demand_source_line_detail
	   , l_miss_num
	   , p_query_input.demand_source_line_detail
	   , p_query_input.demand_source_line_detail
	   , p_query_input.supply_receipt_date
	   , l_miss_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.demand_ship_date
	   , l_miss_date
	   , p_query_input.demand_ship_date
	   , p_query_input.demand_ship_date
	   , p_query_input.project_id
	   , l_miss_num
	   , p_query_input.project_id
	   , p_query_input.project_id
	   , p_query_input.task_id
	   , l_miss_num
	   , p_query_input.task_id
	   , p_query_input.task_id

	   /***** End R12 ***/
	     ;

         END IF; -- End If for supply_source_line_id
         -- End changes for Bug 4881317

     ELSE
       IF (l_debug = 1) then
	  debug_print(' Inside cursor ref no values passed');
       END IF;
      -- INVCONV - Incorporate secondaries
      OPEN l_cursor_ref FOR    'SELECT
          reservation_id
        , requirement_date
        , organization_id
        , inventory_item_id
        , demand_source_type_id
        , demand_source_name
        , demand_source_header_id
        , demand_source_line_id
        , demand_source_delivery
        , primary_uom_code
        , primary_uom_id
        , secondary_uom_code
        , secondary_uom_id
        , reservation_uom_code
        , reservation_uom_id
        , reservation_quantity
        , primary_reservation_quantity
        , secondary_reservation_quantity
        , detailed_quantity
        , secondary_detailed_quantity
        , autodetail_group_id
        , external_source_code
        , external_source_line_id
        , supply_source_type_id
        , supply_source_header_id
        , supply_source_line_id
        , supply_source_name
        , supply_source_line_detail
        , revision
        , subinventory_code
        , subinventory_id
        , locator_id
        , lot_number
        , lot_number_id
        , pick_slip_number
        , lpn_id
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
        , ship_ready_flag
        , staged_flag
	/**** {{ R12 Enhanced reservations code changes }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
         , serial_number
	 /***** End R12 ***/
        FROM mtl_reservations
        WHERE
   (:requirement_date = :l_miss_date
         OR :requirement_date IS NULL
         AND requirement_date IS NULL
         OR :requirement_date
         = requirement_date
         )
        AND
        (:organization_id = :l_miss_num
         OR :organization_id IS NULL
         AND organization_id IS NULL
         OR :organization_id = organization_id
         )
        AND
        (:inventory_item_id = :l_miss_num
         OR :inventory_item_id IS NULL
         AND inventory_item_id IS NULL
         OR :inventory_item_id = inventory_item_id
         )
  AND
  (:demand_source_type_id = :l_miss_num
         OR :demand_source_type_id IS NULL
         AND demand_source_type_id IS NULL
         OR :demand_source_type_id
         = demand_source_type_id
         )
        AND
        (:demand_source_header_id = :l_miss_num
         OR :demand_source_header_id IS NULL
         AND demand_source_header_id IS NULL
         OR :demand_source_header_id
         = demand_source_header_id
         )
        AND
        (:demand_source_line_id = :l_miss_num
         OR :demand_source_line_id IS NULL
         AND demand_source_line_id IS NULL
         OR :demand_source_line_id = demand_source_line_id
         )
        AND
        (:demand_source_name = :l_miss_char
         OR :demand_source_name IS NULL
         AND demand_source_name IS NULL
         OR :demand_source_name = demand_source_name
         )
        AND
        (:demand_source_delivery = :l_miss_num
         OR :demand_source_delivery IS NULL
         AND demand_source_delivery IS NULL
         OR :demand_source_delivery = demand_source_delivery
         )
      AND
        (:primary_uom_code = :l_miss_char
         OR :primary_uom_code IS NULL
         AND primary_uom_code IS NULL
         OR :primary_uom_code = primary_uom_code
         )
        AND
        (:primary_uom_id = :l_miss_num
         OR :primary_uom_id IS NULL
         AND primary_uom_id IS NULL
         OR :primary_uom_id = primary_uom_id
         )
         -- INVCONV BEGIN
        AND
        (:secondary_uom_code = :l_miss_char
         OR :secondary_uom_code IS NULL
         AND secondary_uom_code IS NULL
         OR :secondary_uom_code = secondary_uom_code
         )
        AND
        (:secondary_uom_id = :l_miss_num
         OR :secondary_uom_id IS NULL
         AND secondary_uom_id IS NULL
         OR :secondary_uom_id = secondary_uom_id
         )
        -- INVCONV END
        AND
        (:reservation_uom_code = :l_miss_char
         OR :reservation_uom_code IS NULL
         AND reservation_uom_code IS NULL
         OR :reservation_uom_code = reservation_uom_code
         )
        AND
        (:reservation_uom_id = :l_miss_num
         OR :reservation_uom_id IS NULL
         AND reservation_uom_id IS NULL
         OR :reservation_uom_id = reservation_uom_id
         )
        AND
        (:autodetail_group_id = :l_miss_num
         OR :autodetail_group_id IS NULL
         AND autodetail_group_id IS NULL
         OR :autodetail_group_id = autodetail_group_id
         )
        AND
        (:external_source_code = :l_miss_char
         OR :external_source_code IS NULL
         AND external_source_code IS NULL
         OR :external_source_code = external_source_code
         )
        AND
        (:external_source_line_id = :l_miss_num
         OR :external_source_line_id IS NULL
         AND external_source_line_id IS NULL
         OR :external_source_line_id = external_source_line_id
         )
        AND
        (:supply_source_type_id = :l_miss_num
         OR :supply_source_type_id IS NULL
         AND supply_source_type_id IS NULL
         OR :supply_source_type_id = supply_source_type_id
         )
        AND
        (:supply_source_header_id = :l_miss_num
         OR :supply_source_header_id IS NULL
         AND supply_source_header_id IS NULL
         OR :supply_source_header_id
         = supply_source_header_id
         )
        AND
        (:supply_source_line_id = :l_miss_num
         OR :supply_source_line_id IS NULL
         AND supply_source_line_id IS NULL
         OR :supply_source_line_id = supply_source_line_id
         )
        AND
        (:supply_source_name = :l_miss_char
         OR :supply_source_name IS NULL
         AND supply_source_name IS NULL
         OR :supply_source_name = supply_source_name
         )
        AND
        (:supply_source_line_detail = :l_miss_num
         OR :supply_source_line_detail IS NULL
         AND supply_source_line_detail IS NULL
         OR :supply_source_line_detail
         = supply_source_line_detail
         )
        AND
        (:revision = :l_miss_char
         OR :revision IS NULL
         AND revision IS NULL
         OR :revision = revision
         )
        AND
        (:subinventory_code = :l_miss_char
         OR :subinventory_code IS NULL
         AND subinventory_code IS NULL
         OR :subinventory_code = subinventory_code
         )
       AND
        (:subinventory_id = :l_miss_num
         OR :subinventory_id IS NULL
         AND subinventory_id IS NULL
         OR :subinventory_id = subinventory_id
         )
        AND
        (:locator_id = :l_miss_num
         OR :locator_id IS NULL
         AND locator_id IS NULL
         OR :locator_id = locator_id
         )
        AND
        (:lot_number = :l_miss_char
         OR :lot_number IS NULL
         AND lot_number IS NULL
         OR :lot_number = lot_number
         )
        AND
        (:lot_number_id = :l_miss_num
         OR :lot_number_id IS NULL
         AND lot_number_id IS NULL
         OR :lot_number_id = lot_number_id
         )
        AND
        (:lpn_id = :l_miss_num
         OR :lpn_id IS NULL
         AND lpn_id IS NULL
         OR :lpn_id = lpn_id
         )
        AND
        (:ship_ready_flag = :l_miss_num
         OR (:ship_ready_flag IS NULL OR :ship_ready_flag = 2)
         AND (ship_ready_flag IS NULL OR ship_ready_flag = 2)
         OR :ship_ready_flag = ship_ready_flag
         )
        AND
        (:staged_flag = :l_miss_char
         OR (:staged_flag IS NULL OR :staged_flag = ''N'')
         AND (staged_flag IS NULL OR staged_flag = ''N'')
         OR :staged_flag = staged_flag
         )
        AND
        (:attribute_category = :l_miss_char
         OR :attribute_category IS NULL
         AND attribute_category IS NULL
         OR :attribute_category = attribute_category
         )
        AND
        (:attribute1 = :l_miss_char
         OR :attribute1 IS NULL
         AND attribute1 IS NULL
         OR :attribute1 = attribute1
         )
       AND
        (:attribute2 = :l_miss_char
         OR :attribute2 IS NULL
         AND attribute2 IS NULL
         OR :attribute2 = attribute2
         )
        AND
        (:attribute3 = :l_miss_char
         OR :attribute3 IS NULL
         AND attribute3 IS NULL
         OR :attribute3 = attribute3
         )
        AND
        (:attribute4 = :l_miss_char
         OR :attribute4 IS NULL
         AND attribute4 IS NULL
         OR :attribute4 = attribute4
         )
       AND
        (:attribute5 = :l_miss_char
         OR :attribute5 IS NULL
         AND attribute5 IS NULL
         OR :attribute5 = attribute5
         )
        AND
        (:attribute6 = :l_miss_char
         OR :attribute6 IS NULL
         AND attribute6 IS NULL
         OR :attribute6 = attribute6
         )
        AND
        (:attribute7 = :l_miss_char
         OR :attribute7 IS NULL
         AND attribute7 IS NULL
         OR :attribute7 = attribute7
         )
        AND
        (:attribute8 = :l_miss_char
         OR :attribute8 IS NULL
         AND attribute8 IS NULL
         OR :attribute8 = attribute8
         )
        AND
        (:attribute9 = :l_miss_char
         OR :attribute9 IS NULL
         AND attribute9 IS NULL
         OR :attribute9 = attribute9
         )
        AND
        (:attribute10 = :l_miss_char
         OR :attribute10 IS NULL
         AND attribute10 IS NULL
         OR :attribute10 = attribute10
         )
        AND
        (:attribute11 = :l_miss_char
         OR :attribute11 IS NULL
         AND attribute11 IS NULL
         OR :attribute11 = attribute11
         )
        AND
        (:attribute12 = :l_miss_char
         OR :attribute12 IS NULL
         AND attribute12 IS NULL
         OR :attribute12 = attribute12
         )
        AND
        (:attribute13 = :l_miss_char
         OR :attribute13 IS NULL
         AND attribute13 IS NULL
         OR :attribute13 = attribute13
         )
        AND
        (:attribute14 = :l_miss_char
         OR :attribute14 IS NULL
         AND attribute14 IS NULL
         OR :attribute14 = attribute14
         )
        AND
        (:attribute15 = :l_miss_char
         OR :attribute15 IS NULL
         AND attribute15 IS NULL
         OR :attribute15 = attribute15
         )

/**** {{ R12 Enhanced reservations code changes }}****/
	AND
	   (:crossdock_flag = :l_miss_char
         OR :crossdock_flag IS NULL
         AND crossdock_flag IS NULL
         OR :crossdock_flag = crossdock_flag
         )
	AND
	   (:crossdock_criteria_id = :l_miss_num
         OR :crossdock_criteria_id IS NULL
         AND crossdock_criteria_id IS NULL
         OR :crossdock_criteria_id = crossdock_criteria_id
	    )
        AND
	   (:demand_source_line_detail = :l_miss_num
         OR :demand_source_line_detail IS NULL
         AND demand_source_line_detail IS NULL
         OR :demand_source_line_detail = demand_source_line_detail
	    )
	AND
	   (:supply_receipt_date = :l_miss_date
         OR :supply_receipt_date IS NULL
         AND supply_receipt_date IS NULL
         OR :supply_receipt_date = supply_receipt_date
	    )
	AND
	   (:demand_ship_date = :l_miss_date
         OR :demand_ship_date IS NULL
         AND demand_ship_date IS NULL
         OR :demand_ship_date = demand_ship_date
	    )
	AND
	   (:project_id = :l_miss_num
         OR :project_id IS NULL
         AND project_id IS NULL
         OR :project_id = project_id
	    )
	 AND
	   (:task_id = :l_miss_num
         OR :task_id IS NULL
         AND task_id IS NULL
         OR :task_id = task_id
	    )
/***** End R12 ***/

  '
                            || l_lock_stmt
                            || l_sort_stmt
        USING  p_query_input.requirement_date
             , l_miss_date
             , p_query_input.requirement_date
             , p_query_input.requirement_date
             , p_query_input.organization_id
             , l_miss_num
             , p_query_input.organization_id
             , p_query_input.organization_id
             , p_query_input.inventory_item_id
             , l_miss_num
             , p_query_input.inventory_item_id
             , p_query_input.inventory_item_id
             , p_query_input.demand_source_type_id
             , l_miss_num
             , p_query_input.demand_source_type_id
             , p_query_input.demand_source_type_id
             , p_query_input.demand_source_header_id
             , l_miss_num
             , p_query_input.demand_source_header_id
             , p_query_input.demand_source_header_id
             , p_query_input.demand_source_line_id
             , l_miss_num
             , p_query_input.demand_source_line_id
             , p_query_input.demand_source_line_id
             , p_query_input.demand_source_name
             , l_miss_char
             , p_query_input.demand_source_name
             , p_query_input.demand_source_name
             , p_query_input.demand_source_delivery
             , l_miss_num
             , p_query_input.demand_source_delivery
             , p_query_input.demand_source_delivery
             , p_query_input.primary_uom_code
             , l_miss_char
             , p_query_input.primary_uom_code
             , p_query_input.primary_uom_code
             , p_query_input.primary_uom_id
             , l_miss_num
             , p_query_input.primary_uom_id
             , p_query_input.primary_uom_id
             -- INVCONV BEGIN
             , p_query_input.secondary_uom_code
             , l_miss_char
             , p_query_input.secondary_uom_code
             , p_query_input.secondary_uom_code
             , p_query_input.secondary_uom_id
             , l_miss_num
             , p_query_input.secondary_uom_id
             , p_query_input.secondary_uom_id
             -- INVCONV END
             , p_query_input.reservation_uom_code
             , l_miss_char
             , p_query_input.reservation_uom_code
             , p_query_input.reservation_uom_code
             , p_query_input.reservation_uom_id
             , l_miss_num
             , p_query_input.reservation_uom_id
             , p_query_input.reservation_uom_id
             , p_query_input.autodetail_group_id
             , l_miss_num
             , p_query_input.autodetail_group_id
             , p_query_input.autodetail_group_id
             , p_query_input.external_source_code
             , l_miss_char
             , p_query_input.external_source_code
             , p_query_input.external_source_code
             , p_query_input.external_source_line_id
             , l_miss_num
             , p_query_input.external_source_line_id
             , p_query_input.external_source_line_id
             , p_query_input.supply_source_type_id
             , l_miss_num
             , p_query_input.supply_source_type_id
             , p_query_input.supply_source_type_id
             , p_query_input.supply_source_header_id
             , l_miss_num
             , p_query_input.supply_source_header_id
             , p_query_input.supply_source_header_id
             , p_query_input.supply_source_line_id
             , l_miss_num
             , p_query_input.supply_source_line_id
             , p_query_input.supply_source_line_id
             , p_query_input.supply_source_name
             , l_miss_char
             , p_query_input.supply_source_name
             , p_query_input.supply_source_name
             , p_query_input.supply_source_line_detail
             , l_miss_num
             , p_query_input.supply_source_line_detail
             , p_query_input.supply_source_line_detail
             , p_query_input.revision
             , l_miss_char
             , p_query_input.revision
             , p_query_input.revision
             , p_query_input.subinventory_code
             , l_miss_char
             , p_query_input.subinventory_code
             , p_query_input.subinventory_code
             , p_query_input.subinventory_id
             , l_miss_num
             , p_query_input.subinventory_id
             , p_query_input.subinventory_id
             , p_query_input.locator_id
             , l_miss_num
             , p_query_input.locator_id
             , p_query_input.locator_id
             , p_query_input.lot_number
             , l_miss_char
             , p_query_input.lot_number
             , p_query_input.lot_number
             , p_query_input.lot_number_id
             , l_miss_num
             , p_query_input.lot_number_id
             , p_query_input.lot_number_id
             , p_query_input.lpn_id
             , l_miss_num
             , p_query_input.lpn_id
             , p_query_input.lpn_id
             , p_query_input.ship_ready_flag
             , l_miss_num
             , p_query_input.ship_ready_flag
             , p_query_input.ship_ready_flag
             , p_query_input.ship_ready_flag
             , p_query_input.staged_flag
             , l_miss_char
             , p_query_input.staged_flag
             , p_query_input.staged_flag
             , p_query_input.staged_flag
             , p_query_input.attribute_category
             , l_miss_char
             , p_query_input.attribute_category
             , p_query_input.attribute_category
             , p_query_input.attribute1
             , l_miss_char
             , p_query_input.attribute1
             , p_query_input.attribute1
             , p_query_input.attribute2
             , l_miss_char
             , p_query_input.attribute2
             , p_query_input.attribute2
             , p_query_input.attribute3
             , l_miss_char
             , p_query_input.attribute3
             , p_query_input.attribute3
             , p_query_input.attribute4
             , l_miss_char
             , p_query_input.attribute4
             , p_query_input.attribute4
             , p_query_input.attribute5
             , l_miss_char
             , p_query_input.attribute5
             , p_query_input.attribute5
             , p_query_input.attribute6
             , l_miss_char
             , p_query_input.attribute6
             , p_query_input.attribute6
             , p_query_input.attribute7
             , l_miss_char
             , p_query_input.attribute7
             , p_query_input.attribute7
             , p_query_input.attribute8
             , l_miss_char
             , p_query_input.attribute8
             , p_query_input.attribute8
             , p_query_input.attribute9
             , l_miss_char
             , p_query_input.attribute9
             , p_query_input.attribute9
             , p_query_input.attribute10
             , l_miss_char
             , p_query_input.attribute10
             , p_query_input.attribute10
             , p_query_input.attribute11
             , l_miss_char
             , p_query_input.attribute11
             , p_query_input.attribute11
             , p_query_input.attribute12
             , l_miss_char
             , p_query_input.attribute12
             , p_query_input.attribute12
             , p_query_input.attribute13
             , l_miss_char
             , p_query_input.attribute13
             , p_query_input.attribute13
             , p_query_input.attribute14
             , l_miss_char
             , p_query_input.attribute14
             , p_query_input.attribute14
             , p_query_input.attribute15
             , l_miss_char
             , p_query_input.attribute15
	   , p_query_input.attribute15
 /**** {{ R12 Enhanced reservations code changes }}****/
	   , p_query_input.crossdock_flag
	   , l_miss_char
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_flag
	   , p_query_input.crossdock_criteria_id
	   , l_miss_num
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.crossdock_criteria_id
	   , p_query_input.demand_source_line_detail
	   , l_miss_num
	   , p_query_input.demand_source_line_detail
	   , p_query_input.demand_source_line_detail
	   , p_query_input.supply_receipt_date
	   , l_miss_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.supply_receipt_date
	   , p_query_input.demand_ship_date
	   , l_miss_date
	   , p_query_input.demand_ship_date
	   , p_query_input.demand_ship_date
	   , p_query_input.project_id
	   , l_miss_num
	   , p_query_input.project_id
	   , p_query_input.project_id
	   , p_query_input.task_id
	   , l_miss_num
	   , p_query_input.task_id
	   , p_query_input.task_id

	   /***** End R12 ***/
	   ;
    END IF;

    --
    l_counter                    := 0;

    LOOP
       IF l_res_cursor THEN
	  IF l_update THEN
	     --    IF (l_debug = 1) then
	     --	debug_print(' Inside res cursor for update...');
	     --    END IF;
	     FETCH c_res_id_update INTO l_rsv_rec;
	     EXIT WHEN c_res_id_update%NOTFOUND;
	   ELSE
		--	IF (l_debug = 1) then
		--	   debug_print(' Inside res cursor no update...');
		--	END IF;
		FETCH c_res_id INTO l_rsv_rec;
		EXIT WHEN c_res_id%NOTFOUND;
	  END IF;
	ELSIF l_demand_cursor THEN
		IF l_update THEN
		   --	   IF (l_debug = 1) then
		   --	      debug_print (' Inside demand cursor for update...');
		   --	   END IF;
		   FETCH c_demand_update INTO l_rsv_rec;
		   EXIT WHEN c_demand_update%NOTFOUND;
		 ELSE
		      --      IF (l_debug = 1) then
		      -- debug_print (' Inside demand cursor no update...');
		      -- END IF;
		      FETCH c_demand INTO l_rsv_rec;
		      EXIT WHEN c_demand%NOTFOUND;
		END IF;
	ELSE
		      --IF (l_debug = 1) then
		      --	 debug_print(' Inside ref cursor...');
		      --    END IF;
		      FETCH l_cursor_ref INTO l_rsv_rec;
		      EXIT WHEN l_cursor_ref%NOTFOUND;
       END IF;

       l_counter                         := l_counter + 1;
       x_mtl_reservation_tbl(l_counter)  := l_rsv_rec;
    END LOOP;

    IF c_res_id%ISOPEN THEN
       CLOSE c_res_id;
     ELSIF c_res_id_update%ISOPEN THEN
       CLOSE c_res_id_update;
     ELSIF c_demand_update%ISOPEN THEN
       CLOSE c_demand_update;
     ELSIF c_demand%ISOPEN THEN
       CLOSE c_demand;
     ELSE
       CLOSE l_cursor_ref;
    END IF;

    IF (l_debug = 1) then
       debug_print(' Counter: ' || l_counter);
       debug_print(' return status: ' || l_return_status);
       debug_print('error code' || inv_reservation_global.g_err_no_error);
    END IF;
    --
    x_mtl_reservation_tbl_count  := l_counter;
    x_return_status              := l_return_status;
    x_error_code                 := inv_reservation_global.g_err_no_error;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      IF SQLCODE = -54 THEN -- failed to lock
        x_return_status  := fnd_api.g_ret_sts_error;
        x_error_code     := inv_reservation_global.g_err_fail_to_lock_rec;
      ELSE
        x_return_status  := fnd_api.g_ret_sts_unexp_error;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      END IF;
  END query_reservation;

 /**** {{ R12 Enhanced reservations code changes. Overloaded query
  -- reservation for querying serial numbers  }}****/
  -- Overloaded API for query_reservation

  PROCEDURE query_reservation
    (
     p_api_version_number        	IN     	NUMBER
     , p_init_msg_lst              	IN     	VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status             	OUT   	NOCOPY VARCHAR2
     , x_msg_count                 	OUT    	NOCOPY NUMBER
     , x_msg_data                  	OUT    	NOCOPY VARCHAR2
     , p_query_input               	IN     	inv_reservation_global.mtl_reservation_rec_type
     , p_lock_records              	IN     	VARCHAR2 DEFAULT fnd_api.g_false
     , p_sort_by_req_date          	IN     	NUMBER DEFAULT inv_reservation_global.g_query_no_sort
     , p_cancel_order_mode         	IN     	NUMBER DEFAULT inv_reservation_global.g_cancel_order_no
     , p_serial_number_table	        IN	inv_reservation_global.rsv_serial_number_table
     , x_mtl_reservation_tbl       	OUT    	NOCOPY inv_reservation_global.mtl_reservation_tbl_type
     , x_mtl_reservation_tbl_count 	OUT    	NOCOPY NUMBER
     , x_serial_number_table	        OUT	NOCOPY inv_reservation_global.rsv_serial_number_table
    , x_serial_number_table_count	OUT 	NOCOPY NUMBER
    , x_error_code                	OUT    	NOCOPY NUMBER
    ) IS

       l_api_name     CONSTANT VARCHAR2(30) := 'Query_Reservation';
       l_serial_number_table inv_reservation_global.rsv_serial_number_table;
       l_serial_table_index BINARY_INTEGER;
       l_output_index BINARY_INTEGER;
       l_reservation_index BINARY_INTEGER;
       l_reservation_id NUMBER;
       l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
       l_debug NUMBER;
       l_serial_number varchar2(30);
       l_mtl_reservation_tbl
	 inv_reservation_global.mtl_reservation_tbl_type;
       l_progress NUMBER;
       l_mtl_reservation_tbl_count NUMBER;
       l_rsv_rec inv_reservation_global.mtl_reservation_rec_type;
       l_error_code NUMBER;
       l_serial_number_table_temp inv_reservation_global.rsv_serial_number_table; --Bug# 13479815

  BEGIN

     -- The new API will be called to query a set of serial numbers or if
     -- the reservation record has serial numbers and the query API has to
     -- return the serial numbers, then this API will be used.
     -- All the serial number retrieval logic will go here. This will
     -- inturn call the old API to get the reservation records and for each
     -- reservation record, we will have to query the serials and return
     -- the serials along with reservation IDs will be passed back as
     -- output.

     l_debug := g_debug;

      IF l_debug=1 THEN
	  debug_print ('Inside overloaded query reservations');
      END IF;
      l_rsv_rec := p_query_input;
     -- First call the query reservations to get all the reservation
     -- records.
      inv_reservation_pvt.query_reservation
	 (p_api_version_number             => 1.0,
	  p_init_msg_lst                   => fnd_api.g_false,
	  x_return_status                  => l_return_status,
	  x_msg_count                      => x_msg_count,
	  x_msg_data                       => x_msg_data,
	  p_query_input                    => l_rsv_rec,
	  p_lock_records                   => fnd_api.g_true,
	  p_sort_by_req_date               => p_sort_by_req_date,
	  x_mtl_reservation_tbl            => l_mtl_reservation_tbl,
	  x_mtl_reservation_tbl_count      => l_mtl_reservation_tbl_count,
	  x_error_code                     => l_error_code
	  );

       IF l_debug=1 THEN
	  debug_print ('Return Status after querying reservations '||l_return_status);
       END IF;

       l_progress := 80;

       IF l_return_status = fnd_api.g_ret_sts_error THEN

	  IF l_debug=1 THEN
	     debug_print('Raising expected error'||l_return_status);
	  END IF;
	  RAISE fnd_api.g_exc_error;

	ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

	  IF l_debug=1 THEN
	     debug_print('Rasing Unexpected error'||l_return_status);
	  END IF;
	  RAISE fnd_api.g_exc_unexpected_error;

       END IF;

       IF (l_debug=1) THEN
	    debug_print('x_mtl_reservation_tbl_count='|| l_mtl_reservation_tbl_count);
       END IF;

       -- check to see if the serial number table is empty or not
       IF p_serial_number_table.COUNT = 0 THEN
	  -- then nothing was passed and get all the serial numbers for
	  -- each reservation record returned from query

          l_output_index := 1 ;  --Bug# 13479815
          FOR i IN 1..l_mtl_reservation_tbl_count LOOP
            BEGIN
		IF (l_debug=1) THEN
                   debug_print('Count. i: '|| i);
                END IF;
                 SELECT reservation_id, serial_number bulk collect INTO
                 -- l_serial_number_table FROM mtl_serial_numbers
                 /* Bug# 13479815: replaced l_serial_number_table with l_serial_number_table_temp */
                 l_serial_number_table_temp  FROM mtl_serial_numbers
                 WHERE reservation_id = l_mtl_reservation_tbl(i).reservation_id;

              IF l_serial_number_table_temp.Count > 0 THEN  --Bug# 13557393
                -- Bug# 13479815 Start : populating l_serial_number_table with all the serial number details
                  FOR j IN l_serial_number_table_temp.first..l_serial_number_table_temp.last
                  LOOP
                        l_serial_number_table(l_output_index) := l_serial_number_table_temp(j);
                        l_output_index := l_output_index + 1;
                  END LOOP;
                -- Bug# 13479815: End
              END IF;

	     EXCEPTION
		WHEN no_data_found THEN
		   IF l_debug=1 THEN
		      debug_print('No serials found for reservation record. id: ' || l_mtl_reservation_tbl(i).reservation_id);
		   END IF;
	     END;

	  END LOOP;

	ELSE
		   -- serial numbers are passed. loop all the serials and make sure
		   -- that the serial number passed is infact valid and belong to the reservation records returned.
		   IF (l_debug=1) THEN
		      debug_print('Total number of serials passed: '|| p_serial_number_table.COUNT);
		   END IF;

		   FOR l_serial_table_index IN p_serial_number_table.first..p_serial_number_table.last
		   LOOP
		      l_serial_number :=
			p_serial_number_table(l_serial_table_index).serial_number;

		      BEGIN

			 IF (l_debug=1) THEN
			    debug_print('Count. Serial index: '|| l_serial_table_index);
			 END IF;

			 SELECT reservation_id INTO l_reservation_id FROM
			   mtl_serial_numbers WHERE serial_number = l_serial_number AND
			   current_organization_id = l_mtl_reservation_tbl(l_serial_table_index).organization_id AND
			   inventory_item_id = l_mtl_reservation_tbl(l_serial_table_index).inventory_item_id;

		      EXCEPTION
			 WHEN no_data_found THEN
			    IF l_debug=1 THEN
			       debug_print('Serial passed cannot be found. Serial Number: ' || l_serial_number);
			    END IF;
		      END;

		      l_output_index := 1;
		      IF (l_reservation_id IS NOT NULL) THEN

			 FOR l_reservation_index IN l_mtl_reservation_tbl.first..l_mtl_reservation_tbl.last
			 LOOP
			    IF (l_reservation_id =
				l_mtl_reservation_tbl(l_reservation_index).reservation_id) THEN
			       -- add the serial and the reservation id to
			       -- the serial number table
			       l_serial_number_table(l_output_index).reservation_id := l_reservation_id;
			       l_serial_number_table(l_output_index).serial_number := l_serial_number;
			       l_output_index := l_output_index + 1;
			       EXIT;
			    END IF;
			 END LOOP;
		      END IF;

		   END LOOP;

       END IF;

       x_mtl_reservation_tbl        := l_mtl_reservation_tbl;
       x_mtl_reservation_tbl_count  := l_mtl_reservation_tbl_count;
       x_return_status              := l_return_status;
       x_error_code                 := inv_reservation_global.g_err_no_error;
       x_serial_number_table := l_serial_number_table;
       x_serial_number_table_count := l_serial_number_table.COUNT;

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
	x_return_status  := fnd_api.g_ret_sts_error;
	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN fnd_api.g_exc_unexpected_error THEN
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN OTHERS THEN
	IF SQLCODE = -54 THEN -- failed to lock
	   x_return_status  := fnd_api.g_ret_sts_error;
	   x_error_code     := inv_reservation_global.g_err_fail_to_lock_rec;
	 ELSE
	   x_return_status  := fnd_api.g_ret_sts_unexp_error;

	   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	   END IF;

	   --  Get message count and data
	   fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	END IF;
  END query_reservation;

  /*** End R12 ***/
  --
  PROCEDURE create_reservation
    (
     p_api_version_number       IN     NUMBER
     , p_init_msg_lst             IN     VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status            OUT    NOCOPY VARCHAR2
     , x_msg_count                OUT    NOCOPY NUMBER
     , x_msg_data                 OUT    NOCOPY VARCHAR2
     , p_rsv_rec                  IN     inv_reservation_global.mtl_reservation_rec_type
     , p_serial_number            IN     inv_reservation_global.serial_number_tbl_type
     , x_serial_number            OUT    NOCOPY inv_reservation_global.serial_number_tbl_type
     , p_partial_reservation_flag IN     VARCHAR2 DEFAULT fnd_api.g_false
     , p_force_reservation_flag   IN     VARCHAR2 DEFAULT fnd_api.g_false
     , p_validation_flag          IN     VARCHAR2 DEFAULT fnd_api.g_true
     , p_over_reservation_flag      IN  NUMBER DEFAULT 0
     , x_quantity_reserved        OUT    NOCOPY NUMBER
     , x_secondary_quantity_reserved        OUT NOCOPY NUMBER
     -- INVCONV
     , x_reservation_id           OUT    NOCOPY NUMBER
    /**** {{ R12 Enhanced reservations code changes }}****/
    , p_partial_rsv_exists        IN  BOOLEAN DEFAULT FALSE
    /*** End R12 ***/
    , p_substitute_flag           IN  BOOLEAN DEFAULT FALSE /* Bug 6044651 */
    ) IS
    l_api_version_number CONSTANT NUMBER                                          := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)                                    := 'Create_Reservation';
    l_return_status               VARCHAR2(1)                                     := fnd_api.g_ret_sts_success;
    l_rsv_rec                     inv_reservation_global.mtl_reservation_rec_type;
    l_actual_primary_quantity     NUMBER := NULL;
    l_tmp_rsv_tbl                 inv_reservation_global.mtl_reservation_tbl_type;
    l_tmp_rsv_tbl_count           NUMBER;
    l_dummy_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
    l_dummy_serial_array          inv_reservation_global.serial_number_tbl_type;
    l_tree_id                     INTEGER;
    l_orig_item_cache_index       INTEGER                                         := NULL;
    l_orig_org_cache_index        INTEGER                                         := NULL;
    l_orig_demand_cache_index     INTEGER                                         := NULL;
    l_orig_supply_cache_index     INTEGER                                         := NULL;
    l_orig_sub_cache_index        INTEGER                                         := NULL;
    l_to_item_cache_index         INTEGER                                         := NULL;
    l_to_org_cache_index          INTEGER                                         := NULL;
    l_to_demand_cache_index       INTEGER                                         := NULL;
    l_to_supply_cache_index       INTEGER                                         := NULL;
    l_to_sub_cache_index          INTEGER                                         := NULL;
    l_reservation_id              NUMBER;
    l_date                        DATE;
    l_user_id                     NUMBER;
    l_request_id                  NUMBER;
    l_login_id                    NUMBER;
    l_prog_appl_id                NUMBER;
    l_program_id                  NUMBER;
    l_rowid                       VARCHAR2(30);
    l_error_code                  NUMBER;
    l_qty_changed                 NUMBER;
    l_secondary_qty_changed       NUMBER; 					-- INVCONV
    l_what_field                  VARCHAR2(240);
    l_debug number;
    l_lot_divisible_flag          VARCHAR2(1)                                    :='Y'; -- INVCONV
    l_dual_control_flag           VARCHAR2(1)
      :='N'; -- INVCONV
    /**** {{ R12 Enhanced reservations code changes }}****/
    l_rsv_updated                 BOOLEAN :=FALSE;
    l_progress                    NUMBER;
    --  l_from_rsv_rec                inv_reservation_global.mtl_reservation_rec_type
    --   := p_rsv_rec;
    l_to_rsv_rec                  inv_reservation_global.mtl_reservation_rec_type;
    l_mtl_reservation_tbl         inv_reservation_global.mtl_reservation_tbl_type;
    l_mtl_reservation_tbl_count   NUMBER;
    l_quantity_reserved           NUMBER;
    l_secondary_quantity_reserved NUMBER;
    l_qty_available               NUMBER;
    l_serial_index                NUMBER;
    l_serial_number inv_reservation_global.serial_number_tbl_type;
    l_item_rec  inv_reservation_global.item_record;
    l_supply_lock_handle varchar2(128);
    l_demand_lock_handle varchar2(128);
    l_lock_status NUMBER;
    l_group_mark_id NUMBER := NULL;
    l_lock_obtained BOOLEAN := FALSE;
    l_project_id NUMBER;
    l_task_id NUMBER;
    l_pjm_enabled NUMBER;
    l_reservation_margin_above NUMBER;
    l_supply_source_type_id NUMBER;
    l_exp_date DATE; --Expired lots custom hook
    l_reservation_qty_lot NUMBER := 0; --Bug 12978409
    /* Added for bug 13829182 */
    l_wip_entity_id NUMBER;
	l_wip_entity_type NUMBER;
	l_wip_job_type VARCHAR2(15);
	l_maintenance_object_source NUMBER;
    /* End of changes for bug 13829182 */
    --MUOM Fulfillment Project
    l_qty_changed2  NUMBER;
    l_qty_available2 NUMBER;
    l_fulfill_base	VARCHAR2(1) := 'P';

    -- changing the cursor
    -- adding org_id in the condition
    -- bug 9874238
    CURSOR c_item(p_inventory_item_id NUMBER,p_organization_id NUMBER) IS
         SELECT *
           FROM mtl_system_items
          WHERE inventory_Item_Id = p_inventory_item_id
	  AND organization_id = p_organization_id;
    /*** End R12 ***/
  BEGIN
     -- Use cache to get value for l_debug
     IF g_is_pickrelease_set IS NULL THEN
        g_is_pickrelease_set := 2;
        IF INV_CACHE.is_pickrelease THEN
           g_is_pickrelease_set := 1;
        END IF;
     END IF;
     IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;

     IF (l_debug = 1) THEN
        debug_print('Inside create reservation... ');
     END IF;

    --
    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    /**** {{ R12 Enhanced reservations code changes.Initializing orig parameters }}****/

    SAVEPOINT create_reservation_sa;

    l_rsv_rec := p_rsv_rec;

    -- Set the original columns to g_miss_xxx as the user should not be
    -- setting these values. Do not query by them
    l_rsv_rec.orig_supply_source_type_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_supply_source_header_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_supply_source_line_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_supply_source_line_detail := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_type_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_header_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_line_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_line_detail := fnd_api.g_miss_num;


    IF (l_rsv_rec.project_id IS NULL)  THEN
       l_rsv_rec.project_id := fnd_api.g_miss_num;
    END IF;
    IF (l_rsv_rec.task_id IS NULL)  THEN
       l_rsv_rec.task_id := fnd_api.g_miss_num;
    END IF;

    l_progress :=50;

    inv_reservation_pvt.convert_quantity
      (x_return_status      => l_return_status,
       px_rsv_rec           => l_rsv_rec
       );

    IF l_debug=1 THEN
       debug_print('Return Status from convert quantity'||l_return_status);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_error THEN

       IF l_debug=1 THEN
	  debug_print('Raising expected error'||l_return_status);
       END IF;
       RAISE fnd_api.g_exc_error;

     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

       IF l_debug=1 THEN
	  debug_print('Rasing Unexpected error'||l_return_status);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    l_progress :=60;

    IF l_debug=1 THEN
       debug_print('Calling query reservation to query existing reservations'||l_return_status);
    END IF;

    l_progress := 70;

    inv_reservation_pvt.query_reservation
      (p_api_version_number             => 1.0,
       p_init_msg_lst                   => fnd_api.g_false,
       x_return_status                  => l_return_status,
       x_msg_count                      => x_msg_count,
       x_msg_data                       => x_msg_data,
       p_query_input                    => l_rsv_rec,
       p_lock_records                   => fnd_api.g_true,
       x_mtl_reservation_tbl            => l_mtl_reservation_tbl,
       x_mtl_reservation_tbl_count      => l_mtl_reservation_tbl_count,
       x_error_code                     => l_error_code
       );


    IF l_debug=1 THEN
       debug_print ('Return Status after querying reservations '||l_return_status);
    END IF;

    l_progress := 80;

    IF l_return_status = fnd_api.g_ret_sts_error THEN

       IF l_debug=1 THEN
	  debug_print('Raising expected error'||l_return_status);
       END IF;
       RAISE fnd_api.g_exc_error;

     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

       IF l_debug=1 THEN
	  debug_print('Rasing Unexpected error'||l_return_status);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    IF (l_debug=1) THEN

       debug_print('x_mtl_reservation_tbl_count='|| l_mtl_reservation_tbl_count);

    END IF;

    IF (p_partial_rsv_exists OR l_mtl_reservation_tbl.COUNT > 0) THEN
       --Since create reservation is called by OM even when they updated the existing reservation
       --we need to query existing reservations and see if the existing reservation can be updated.
       IF (l_debug=1) THEN

	  debug_print('Partial reservation flag passed as true or we found existing reservations');
	  IF p_partial_rsv_exists THEN
	     debug_print('The value of partial rsv exists is TRUE');
	   ELSE
	     debug_print('The value of partial rsv exists is FALSE');
	  END IF;

       END IF;

       IF p_serial_number.COUNT > 0 THEN
	  -- We donot support updating existing reservations if serial
	  --  numbers are passed. the calling api should call update
	  --  reservations and not create reservations
	  IF l_debug=1 THEN
	     debug_print('Serial numbers are passed with partial flag exists. error out');
	  END IF;
	  fnd_message.set_name('INV', 'INV_SER_PARTIAL_RSV_EXISTS');
	  fnd_msg_pub.add;
	  RAISE fnd_api.g_exc_error;
       END IF;

       IF l_debug=1 THEN
	  inv_reservation_pvt.print_rsv_rec (p_rsv_rec);
       END IF;

       l_progress := 90;

       FOR i IN 1..l_mtl_reservation_tbl_count LOOP
	  inv_reservation_pvt.print_rsv_rec (l_mtl_reservation_tbl(i));

	  --If the queried reservation record is staged or has a lot number stamped or is
	  -- revision controlled or has an LPN Id stamped or has a different SubInventory
	  l_progress := 100;

	  IF ((l_mtl_reservation_tbl(i).staged_flag='Y')
	      OR (nvl(l_mtl_reservation_tbl(i).lot_number,'@@@')<>nvl(p_rsv_rec.lot_number,'@@@') AND p_rsv_rec.lot_number<>fnd_api.g_miss_char)
	      OR (nvl(l_mtl_reservation_tbl(i).revision,'@@@')<>nvl(p_rsv_rec.revision,'@@@')AND p_rsv_rec.revision <>fnd_api.g_miss_char)
	      OR (nvl(l_mtl_reservation_tbl(i).lpn_id,-1)<>nvl(p_rsv_rec.lpn_id,-1)AND p_rsv_rec.lpn_id <> fnd_api.g_miss_num)
	      OR (nvl(l_mtl_reservation_tbl(i).subinventory_code,'@@@')<>nvl(p_rsv_rec.subinventory_code,'@@@')AND p_rsv_rec.subinventory_code <>fnd_api.g_miss_char)) THEN

	     IF (l_debug=1) THEN
		debug_print('Skipping reservation record');
	     END IF;

	     l_progress := 110;

	     GOTO next_record;
	   ELSE

	     IF (l_debug=1) THEN

		debug_print('Need to update reservation record');
	     END IF;

	     IF l_debug=1 THEN

		debug_print('Reservation record that needs to be updated');
		inv_reservation_pvt.print_rsv_rec (l_mtl_reservation_tbl(i));

	     END IF;

	     l_progress := 120;

	     l_to_rsv_rec.primary_reservation_quantity := l_rsv_rec.primary_reservation_quantity
	       + l_mtl_reservation_tbl(i).primary_reservation_quantity;
	     -- INVCONV BEGIN
	     -- Look at the reservation table row to determine if this is a dual control item.
	     -- If it is dual control and a secondary_reservation_quantity has been supplied,
	     -- then  calculate the to_resv_rec.secondary_reservation_quantity.
	     -- Otherwise leave it empty to be computed as necessary by the private level API
	     IF l_mtl_reservation_tbl(i).secondary_reservation_quantity is not NULL and
	       l_to_rsv_rec.secondary_reservation_quantity is not NULL THEN
		l_to_rsv_rec.secondary_reservation_quantity := l_rsv_rec.secondary_reservation_quantity
		  + l_mtl_reservation_tbl(i).secondary_reservation_quantity;

	     END IF;
	     -- INVCONV END
	     l_progress := 130;

	     IF l_rsv_rec.reservation_uom_code = l_mtl_reservation_tbl(i).reservation_uom_code THEN

		l_to_rsv_rec.reservation_quantity := l_rsv_rec.reservation_quantity + l_mtl_reservation_tbl(i).reservation_quantity;

	      ELSE

		l_to_rsv_rec.reservation_quantity := NULL;

	     END IF;

	     l_progress := 140;

	     IF (l_debug=1) THEN

		debug_print('Calling update reservations to update reservation record');

	     END IF;

	     inv_reservation_pvt.update_reservation
	       (p_api_version_number          => 1.0,
		p_init_msg_lst                => fnd_api.g_false,
		x_return_status               => l_return_status,
		x_msg_count                   => x_msg_count,
		x_msg_data                    => x_msg_data,
		x_quantity_reserved           => l_quantity_reserved,
		x_secondary_quantity_reserved => l_secondary_quantity_reserved,  -- INVCONV
		p_original_rsv_rec            => l_mtl_reservation_tbl(i),
		p_to_rsv_rec                  => l_to_rsv_rec,
		p_original_serial_number      => p_serial_number,
		p_to_serial_number            => l_dummy_serial_array,
		p_validation_flag             => p_validation_flag,              -- BUG 4705409
		p_partial_reservation_flag    => p_partial_reservation_flag,
		p_check_availability          => fnd_api.g_true,
		p_over_reservation_flag       => p_over_reservation_flag
		);

	     l_progress := 150;

	     IF (l_debug=1) THEN
		debug_print ('Return Status after updating reservations '||l_return_status);
	     END IF;

	     IF l_return_status = fnd_api.g_ret_sts_error THEN

		IF l_debug=1 THEN
		   debug_print('Raising expected error'||l_return_status);
		END IF;

		RAISE fnd_api.g_exc_error;

	      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

		IF l_debug=1 THEN
		   debug_print('Raising Unexpected error'||l_return_status);
		END IF;

		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	     l_progress := 160;

	     l_quantity_reserved:=l_quantity_reserved - l_mtl_reservation_tbl(i).primary_reservation_quantity;

	     x_quantity_reserved := l_quantity_reserved;
	     x_reservation_id    := l_mtl_reservation_tbl(i).reservation_id;

	     IF l_debug=1 THEN
		debug_print('After updating reservation successfully from
			    inside create'|| l_return_status);
		debug_print('Quantity reserved inside create'|| l_quantity_reserved);
		debug_print('Reservation id inside create'|| l_mtl_reservation_tbl(i).reservation_id);
	     END IF;

	     l_rsv_updated := TRUE;
	     x_return_status := l_return_status;
	     EXIT;

	  END IF;

	  <<next_record>>
	    NULL;
       END LOOP;

    END IF;

    -- End. Do not need this as we are moving this to the private package.

    IF ((NOT l_rsv_updated) OR (l_mtl_reservation_tbl.COUNT = 0)) THEN

      /*** End R12 ***/


      /**** {{ R12 Enhanced reservations code changes.Calling the reservation
      -- lock API to create a user-defined lock for non-inventory supplies }} *****/

      -- Bug 5199672: Should pass null to supply and demand line detail as
      -- we will have to lock the records at the document level and not at
      -- the line level. Also, for ASN, pass the source type as PO so that the
      -- the lock name would be the same as the PO's

       IF (l_rsv_rec.supply_source_type_id =
	   inv_reservation_global.g_source_type_asn) THEN
	  l_supply_source_type_id :=
	    inv_reservation_global.g_source_type_po;
	ELSE
	  l_supply_source_type_id := l_rsv_rec.supply_source_type_id;
       END IF;

       IF (l_rsv_rec.supply_source_type_id <> inv_reservation_global.g_source_type_inv) THEN
	  inv_reservation_lock_pvt.lock_supply_demand_record
	    (p_organization_id => l_rsv_rec.organization_id
	     ,p_inventory_item_id => l_rsv_rec.inventory_item_id
	     ,p_source_type_id => l_supply_source_type_id
	     ,p_source_header_id => l_rsv_rec.supply_source_header_id
	     ,p_source_line_id =>  l_rsv_rec.supply_source_line_id
	     ,p_source_line_detail => NULL
	     ,x_lock_handle => l_supply_lock_handle
	     ,x_lock_status => l_lock_status);

	  IF l_lock_status = 0 THEN
	     fnd_message.set_name('INV', 'INV_INVALID_LOCK');
	     fnd_msg_pub.ADD;
	     RAISE fnd_api.g_exc_error;
	  END if;

	  inv_reservation_lock_pvt.lock_supply_demand_record
	    (p_organization_id => l_rsv_rec.organization_id
	     ,p_inventory_item_id => l_rsv_rec.inventory_item_id
	     ,p_source_type_id => l_rsv_rec.demand_source_type_id
	     ,p_source_header_id => l_rsv_rec.demand_source_header_id
	     ,p_source_line_id =>  l_rsv_rec.demand_source_line_id
	     ,p_source_line_detail => NULL
	     ,x_lock_handle => l_demand_lock_handle
	     ,x_lock_status => l_lock_status);

	  IF l_lock_status = 0 THEN
	     fnd_message.set_name('INV', 'INV_INVALID_LOCK');
	     fnd_msg_pub.ADD;
	     RAISE fnd_api.g_exc_error;
	  END if;

	 l_lock_obtained := TRUE;

      END IF;

  /*** End R12 ***/

       -- SAVEPOINT create_reservation_sa;
       -- Bug #2819700
       -- Adding an extra check to make sure that create reservations does not
       -- pass a negative reservation quantity.
       IF (l_debug = 1) THEN
	  debug_print('Primary_reservation_qty before inserting (create)= '
		              ||To_char(l_rsv_rec.primary_reservation_quantity) );
	  debug_print('Secondary_reservation_qty before inserting (create)= '
		      ||To_char(l_rsv_rec.secondary_reservation_quantity) );   -- INVCONV
	  debug_print('Reservation_qty before inserting (create)= '
		      || To_char(l_rsv_rec.reservation_quantity) );
       END IF;

       IF ((NVL(l_rsv_rec.reservation_quantity,0) < 0) OR
	   (NVL(l_rsv_rec.primary_reservation_quantity,0) < 0) ) THEN
	  fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
	  fnd_msg_pub.ADD;
	  RAISE fnd_api.g_exc_error;
       END IF;

       /*---------------- Added by nimisra for bug6268983 ----------------
       This check is done in Order to Ensure that No custom code can Populate Demand_source_name for
       Sales orders Or Internal Orders
       --------------------------------------------------------------------*/
       IF (p_rsv_rec.demand_source_type_id=2 or p_rsv_rec.demand_source_type_id=8)
       and (p_rsv_rec.demand_source_name is NOT NULL) THEN
       fnd_message.set_name('INV', 'INV_INVALID_DEMAND_SOURCE');
       fnd_msg_pub.ADD; debug_print('For Sales Orders and Internal Orders DEMAND_SOURCE_NAME Should Be Null');
       RAISE fnd_api.g_exc_error;
       END IF;

       /* ------------------Added by nimisra for bug6268983--------------- */

       -- handle specially for detailed_quantity
       IF l_rsv_rec.detailed_quantity IS NULL
	 OR l_rsv_rec.detailed_quantity = fnd_api.g_miss_num THEN
	  l_rsv_rec.detailed_quantity  := 0;
       END IF;

       -- INVCONV - KYH Check this
       IF l_rsv_rec.secondary_detailed_quantity = fnd_api.g_miss_num THEN
	  l_rsv_rec.secondary_detailed_quantity  := NULL;
       END IF;


       -- INVCONV BEGIN
       --
       -- validate input
       IF check_missing(l_rsv_rec, l_what_field) THEN
	  -- input record attribute can not be missing
	  -- for creation of reservation.
	  -- must be some value or null.
	  fnd_message.set_name('INV', 'INV-RSV-INPUT-MISSING');
	  fnd_message.set_token('FIELD_NAME', l_what_field);
	  fnd_msg_pub.ADD;
	  RAISE fnd_api.g_exc_error;
       END IF;


       IF (l_debug = 1) THEN
	  /**** {{ R12 Enhanced reservations code changes }}****/
	  --  debug_print(' Before CALLING CONVERT record');
	  /*** End R12 ***/
	  debug_print(' reservation is' || l_reservation_id);
	  debug_print(' reservation qty' || l_rsv_rec.reservation_quantity);
	  debug_print(' reservation pri qty' || l_rsv_rec.primary_reservation_quantity);
	  debug_print(' reservation second qty' || l_rsv_rec.secondary_reservation_quantity); -- INVCONV
       END IF;


       /**** {{ R12 Enhanced reservations code changes }}****/

       /**** Commenting out this code as we have already called query
       -- reservation in the beginning of this API
       --Bug#2729651. Calling the procedure convert_quantity before calling query_reservation. This is
       --because the form passes primary_uom as NULL. so this allows multiple reservations for the same
       --criteria. We compute the primary UOM if it is passed as NULL before checking for existing reservations.
       -- convert quantity between primary uom and reservation uom
       -- Bug 2737887. Commneting out the If condition, since
       -- we have to call the convert UOM API for all cases.
       --  IF (l_rsv_rec.primary_uom_code IS NULL) THEN
       convert_quantity(x_return_status => l_return_status, px_rsv_rec => l_rsv_rec);
	 --  END IF;

	 -- BUG 2737887. Inclding error handling for the above call to
	 -- convert quantity.
	 IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
	 END IF;

	 --
	 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 End comment *******/
	 /*** End R12 ***/

	 IF (l_debug = 1) THEN
	    /**** {{ R12 Enhanced reservations code changes }}****/
	    --debug_print(' AFTER CALLING CONVERT record');
	    /*** End R12 ***/
	    debug_print(' reservation is' || l_reservation_id);
	    debug_print(' reservation qty' || l_rsv_rec.reservation_quantity);
	    debug_print(' reservation pri qty' || l_rsv_rec.primary_reservation_quantity);
	    debug_print(' reservation second qty' || l_rsv_rec.secondary_reservation_quantity); -- INVCONV
	 END IF;

	 /**** {{ R12 Enhanced reservations code changes }}****/
	 /**** Commenting out this code as we have already called query
	 -- reservation in the beginning of this API
	 -- query to see whether a record with the key
	 -- attributes already exists
	 -- if there is, return error
	 -- user should use update instead.
	 query_reservation
	   (
	   p_api_version_number         => 1.0
	   , p_init_msg_lst               => fnd_api.g_false
	   , x_return_status              => l_return_status
	   , x_msg_count                  => x_msg_count
	   , x_msg_data                   => x_msg_data
	   , p_query_input                => l_rsv_rec
	   , p_lock_records               => fnd_api.g_true
	   , x_mtl_reservation_tbl        => l_tmp_rsv_tbl
	   , x_mtl_reservation_tbl_count  => l_tmp_rsv_tbl_count
	   , x_error_code                 => l_error_code
	   );

	   IF (l_debug = 1) THEN
	   debug_print('After query_reservations ' || l_return_status);
	   END IF;
	   --
	   IF l_return_status = fnd_api.g_ret_sts_error THEN
	   RAISE fnd_api.g_exc_error;
	   END IF;

	   --
	   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	   RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   --
	   IF l_tmp_rsv_tbl_count > 0 THEN
	   fnd_message.set_name('INV', 'INV-RESERVATION-EXIST');
	   fnd_msg_pub.ADD;
	   RAISE fnd_api.g_exc_error;
	   END IF;

	 ***  End comment *******/
	   -- Get the project and task for demands in OE, INT-ORD and RMA
	   IF l_debug=1 THEN
	      debug_print('Before Rsv rec project id: ' || l_rsv_rec.project_id);
	      debug_print('Before Rsv rec task id: ' || l_rsv_rec.task_id);
	   END IF;
         -- Bug : 5264987 : For pick release getting the l_pjm_enabled flag
         -- INV_CACHE
	IF INV_CACHE.is_pickrelease THEN
		-- Query for and cache the org record.
		IF (NOT INV_CACHE.set_org_rec(l_rsv_rec.organization_id))
		THEN
			IF (l_debug = 1) THEN
			debug_print('Error caching the org record');
			END IF;
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- Set the PJM enabled flag.
		l_pjm_enabled := INV_CACHE.org_rec.project_reference_enabled;
	ELSE

	   BEGIN
	      SELECT project_reference_enabled
		INTO l_pjm_enabled
		FROM   mtl_parameters
		WHERE  organization_id = l_rsv_rec.organization_id;
	   EXCEPTION
	      WHEN no_data_found THEN
		 IF l_debug=1 THEN
		    debug_print('Cannot find the project and task information');
		 END IF;
	   END;
	 END IF;
	 IF (l_rsv_rec.demand_source_type_id IN
	   (inv_reservation_global.g_source_type_oe,
	    inv_reservation_global.g_source_type_internal_ord,
	    inv_reservation_global.g_source_type_rma)) AND
	   (l_pjm_enabled = 1) THEN

	    IF (l_rsv_rec.demand_source_line_id IS NOT NULL) AND
	      (l_rsv_rec.demand_source_line_id <> fnd_api.g_miss_num)
	      AND ((l_rsv_rec.project_id IS NULL) OR
		   (l_rsv_rec.task_id IS NULL)) THEN
		BEGIN
		   SELECT project_id, task_id INTO l_project_id, l_task_id
		     FROM oe_order_lines_all WHERE
		     line_id = l_rsv_rec.demand_source_line_id;
		     -- Bug 5264987
		     -- Storing in global variables so that they are not queried again during transfer_reservation
		     g_oe_line_id := l_rsv_rec.demand_source_line_id;
		     g_project_id := l_project_id;
		     g_task_id	  := l_task_id;
		EXCEPTION
		   WHEN no_data_found THEN
		      IF l_debug=1 THEN
			 debug_print('Cannot find the project and task information');
		      END IF;
		END;
		IF ((l_rsv_rec.project_id IS NULL) AND
		    (l_project_id IS NOT NULL)) THEN
		   l_rsv_rec.project_id := l_project_id;
		END IF;
		IF ((l_rsv_rec.task_id IS NULL) AND
		    (l_task_id IS NOT NULL)) THEN
		   l_rsv_rec.task_id := l_task_id;
		END IF;
	    END IF;

       /* Added for bug 13829182 */
    ELSIF ( (l_rsv_rec.demand_source_type_id = inv_reservation_global.g_source_type_wip) AND (l_pjm_enabled = 1))  THEN

        BEGIN
            SELECT we.entity_type, wdj.maintenance_object_source
                 INTO l_wip_entity_id, l_maintenance_object_source
               FROM wip_entities we, wip_discrete_jobs wdj
            WHERE we.wip_entity_id = l_to_rsv_rec.demand_source_header_id
                 AND we.wip_entity_id = wdj.wip_entity_id(+);
        EXCEPTION
            WHEN no_data_found THEN
                IF (l_debug = 1) THEN
                    debug_print('No WIP entity record found for the source header passed' );
                END IF;
        END ;

        IF l_wip_entity_id = 6 and l_maintenance_object_source = 2  then
             l_wip_entity_type := inv_reservation_global.g_wip_source_type_cmro;
             l_wip_job_type := 'CMRO'; -- AHL
        ELSE
             l_wip_entity_type := null;
             l_wip_job_type := null; -- AHL
        END IF;

        IF (l_wip_job_type = 'CMRO' AND l_rsv_rec.demand_source_line_detail IS NOT NULL)
                AND (l_rsv_rec.demand_source_line_detail <> fnd_api.g_miss_num)
                AND ((l_rsv_rec.project_id IS NULL) OR (l_rsv_rec.task_id IS NULL)) THEN
            BEGIN
                SELECT wdj.project_id, WDJ.TASK_ID
                    INTO l_project_id, l_task_id
                   FROM ahl_schedule_materials asmt, ahl_workorders aw, WIP_DISCRETE_JOBS WDJ
                WHERE asmt.scheduled_material_id = l_rsv_rec.demand_source_line_detail
                     AND asmt.visit_task_id           = aw.visit_task_id
                     AND ASMT.VISIT_ID                = AW.VISIT_ID
                     AND aw.wip_entity_id             = wdj.wip_entity_id
                     AND AW.STATUS_CODE              IN ('1','3') -- 1:Unreleased,3:Released
                     AND ASMT.STATUS                  = 'ACTIVE';

                g_sch_mat_id := l_rsv_rec.demand_source_line_detail;
                g_project_id := l_project_id;
                g_task_id	  := l_task_id;

            EXCEPTION
                WHEN others THEN
                    IF l_debug=1 THEN
                        debug_print('Cannot find the project and task information from CMRO WO => '||sqlerrm);
                    END IF;
            END;
            IF ((l_rsv_rec.project_id IS NULL) AND (l_project_id IS NOT NULL)) THEN
                l_rsv_rec.project_id := l_project_id;
            END IF;
            IF ((l_rsv_rec.task_id IS NULL) AND (l_task_id IS NOT NULL)) THEN
                l_rsv_rec.task_id := l_task_id;
            END IF;
        END IF;                -- l_wip_job_type = 'CMRO'
        /* End of changes for bug 13829182 */

	  ELSE -- not project enable
	       l_to_rsv_rec.project_id := NULL;
	       l_to_rsv_rec.task_id := NULL;
	 END IF;
	 IF l_debug=1 THEN
	    debug_print('After Rsv rec project id: ' || l_rsv_rec.project_id);
	    debug_print('After Rsv rec task id: ' || l_rsv_rec.task_id);
	 END IF;
	 /*** End R12 ***/

	   IF (l_debug = 1) THEN
	      debug_print('p_validation_flag' || p_validation_flag);
	   END IF;
	   --
	   /**** {{ R12 Enhanced reservations code changes }}****/
	   IF p_serial_number.COUNT > 0 THEN
	      l_serial_number := p_serial_number;
	   END IF;
	   /*** End R12 ***/

	   -- call validation api if the validate_flag is set to true
	   -- Bug 2354735: Proceed with Validation if p_validation_flag = 'T' or 'V'
	   IF p_validation_flag = fnd_api.g_true OR p_validation_flag = 'V' THEN
	      inv_reservation_validate_pvt.validate_input_parameters
		(
		 x_return_status              => l_return_status
		 , p_orig_rsv_rec               => l_rsv_rec
		 , p_to_rsv_rec                 => l_dummy_rsv_rec
		 , p_orig_serial_array          => l_serial_number
		 , p_to_serial_array            => l_dummy_serial_array
		 , p_rsv_action_name            => 'CREATE'
		 , x_orig_item_cache_index      => l_orig_item_cache_index
		 , x_orig_org_cache_index       => l_orig_org_cache_index
		 , x_orig_demand_cache_index    => l_orig_demand_cache_index
		 , x_orig_supply_cache_index    => l_orig_supply_cache_index
		 , x_orig_sub_cache_index       => l_orig_sub_cache_index
		 , x_to_item_cache_index        => l_to_item_cache_index
		 , x_to_org_cache_index         => l_to_org_cache_index
		 , x_to_demand_cache_index      => l_to_demand_cache_index
		 , x_to_supply_cache_index      => l_to_supply_cache_index
		 , x_to_sub_cache_index         => l_to_sub_cache_index
		 , p_substitute_flag            => p_substitute_flag           /* Bug 6044651 */
		 );

	      IF (l_debug = 1) THEN
		 debug_print('After validate_input_parameters ' || l_return_status);
	      END IF;
	      --
	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;

	      -- INVCONV BEGIN
	      IF NOT is_lot_divisible(l_orig_item_cache_index) THEN
		 l_lot_divisible_flag := 'N';
	      END IF;
	      -- INVCONV END
	   END IF;

	   --
	   -- Pre Insert CTO Validation
	   IF l_rsv_rec.demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
	      --
	      cto_workflow_api_pk.inventory_reservation_check(p_order_line_id => l_rsv_rec.demand_source_line_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

	      IF (l_debug = 1) THEN
		 debug_print('After CTO validation ' || l_return_status);
	      END IF;
	      --
	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	      --
	   END IF;


	   IF l_return_status = fnd_api.g_ret_sts_error THEN
	      RAISE fnd_api.g_exc_error;
	   END IF;

	   --
	   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

      -- Expired lots custom hook
      IF inv_pick_release_pub.g_pick_expired_lots THEN
          l_exp_date := NULL;
      ELSE
          l_exp_date := SYSDATE;
      END IF;

	   -- call modify tree procedure to change the tree if supply is inv
	   -- will call quantity validation for other supply sources in the future
	   -- Bug 2354735: Proceed with Trees only if p_validation_flag = 'T'
	   IF  p_force_reservation_flag <> fnd_api.g_true
	     AND p_validation_flag = fnd_api.g_true
	     AND l_rsv_rec.supply_source_type_id = inv_reservation_global.g_source_type_inv THEN
	      inv_quantity_tree_pvt.create_tree
		(
		 p_api_version_number         => 1.0
		 , p_init_msg_lst               => fnd_api.g_true
		 , x_return_status              => l_return_status
		 , x_msg_count                  => x_msg_count
		 , x_msg_data                   => x_msg_data
		 , p_organization_id            => l_rsv_rec.organization_id
		 , p_inventory_item_id          => l_rsv_rec.inventory_item_id
		 , p_tree_mode                  => inv_quantity_tree_pvt.g_reservation_mode
		 , p_is_revision_control        => is_revision_control(l_orig_item_cache_index)
		 , p_is_lot_control             => is_lot_control(l_orig_item_cache_index)
		 , p_is_serial_control          => is_serial_control(l_orig_item_cache_index)
		 , p_asset_sub_only             => FALSE
		 , p_include_suggestion         => TRUE
		 , p_demand_source_type_id      => l_rsv_rec.demand_source_type_id
		 , p_demand_source_header_id    => l_rsv_rec.demand_source_header_id
		 , p_demand_source_line_id      => l_rsv_rec.demand_source_line_id
		 , p_demand_source_name         => l_rsv_rec.demand_source_name
		, p_demand_source_delivery     => l_rsv_rec.demand_source_delivery
		, p_lot_expiration_date        => l_exp_date --SYSDATE -- Bug#2716563
		, x_tree_id                    => l_tree_id
		);

	      IF (l_debug = 1) THEN
		 debug_print('After create tree ' || l_return_status);
	      END IF;

	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;

	      IF (l_debug = 1) THEN
		 debug_print('calling modify_tree_crt_del_rel');
		 debug_print('l_rsv_rec.primary_reservation_quantity: ' ||
			     l_rsv_rec.primary_reservation_quantity);
		 debug_print('l_rsv_rec.secondary_reservation_quantity: ' ||
			     l_rsv_rec.secondary_reservation_quantity);  -- INVCONV

	      END IF;
	      -- INVCONV upgrade call for secondaries and lot divisibility
	      modify_tree_crt_del_rel
		(
		 x_return_status              => l_return_status
		 , p_tree_id                    => l_tree_id
		 , p_revision                   => l_rsv_rec.revision
		 , p_lot_number                 => l_rsv_rec.lot_number
		 , p_subinventory_code          => l_rsv_rec.subinventory_code
		 , p_locator_id                 => l_rsv_rec.locator_id
		 , p_lpn_id                     => l_rsv_rec.lpn_id
		 , p_primary_reservation_quantity=> l_rsv_rec.primary_reservation_quantity
		 , p_second_reservation_quantity=> l_rsv_rec.secondary_reservation_quantity
		 , p_detailed_quantity          => l_rsv_rec.detailed_quantity
		 , p_secondary_detailed_quantity => l_rsv_rec.secondary_detailed_quantity
		 , p_partial_reservation_flag   => p_partial_reservation_flag
		 , p_force_reservation_flag     => p_force_reservation_flag
		 , p_lot_divisible_flag         => l_lot_divisible_flag                            -- INVCONV
		 , p_action                     => 'CREATE'
		 , x_qty_changed                => l_qty_changed
		 , x_secondary_qty_changed      => l_secondary_qty_changed				--INVCONV
		 , p_organization_id            => l_rsv_rec.organization_id
                 , p_demand_source_line_id      => l_rsv_rec.demand_source_line_id
		 , p_demand_source_type_id      => l_rsv_rec.demand_source_type_id
		);
	      IF (l_debug = 1) THEN
		 debug_print('After modify tree crt del rel ' || l_return_status);
		 debug_print('l_qty_changed: ' || l_qty_changed);
		 debug_print('l_secondary_qty_changed: ' || l_secondary_qty_changed);            -- INVCONV
	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;

	      /**** {{ R12 Enhanced reservations code changes }}****/
	      --IF (l_debug = 1) THEN
	      -- debug_print(' l_qty_changed' || l_qty_changed);
	      --  debug_print('l_secondary_qty_changed: ' || l_secondary_qty_changed);    -- INVCONV
	      -- END IF;
	      /*** End R12 ***/

	      IF  l_qty_changed > 0
		AND l_qty_changed < l_rsv_rec.primary_reservation_quantity - NVL(l_rsv_rec.detailed_quantity, 0) THEN
		 -- partial reservation. needs to recompute
		 -- the actual quantity for reservation
		 -- convert quantity between primary uom and reservation uom
		 -- Bug 2116332 - Need to set reservation quantity to NULL
		 --   before calling convert_quantity

		 l_rsv_rec.primary_reservation_quantity  := l_qty_changed + NVL(l_rsv_rec.detailed_quantity, 0);
                 -- 5016196 BEGIN
                 -- For dual tracked items recompute the secondary
		 IF l_rsv_rec.secondary_reservation_quantity IS NOT NULL THEN
		   l_rsv_rec.secondary_reservation_quantity  := l_secondary_qty_changed + NVL(l_rsv_rec.secondary_detailed_quantity, 0);
                 END IF;
                 -- 5016196 END
		 l_rsv_rec.reservation_quantity          := NULL;
		 IF (l_debug = 1) THEN
		    debug_print('l_rsv_rec.detailed_quantity: ' || l_rsv_rec.detailed_quantity);
		    debug_print('l_rsv_rec.primary_reservation_quantity: ' || l_rsv_rec.primary_reservation_quantity);
		    debug_print('l_rsv_rec.secondary_reservation_quantity: ' || l_rsv_rec.secondary_reservation_quantity);
		 END IF;
		 convert_quantity(x_return_status => l_return_status, px_rsv_rec => l_rsv_rec);

		 IF (l_debug = 1) THEN
		    debug_print('After convert qty ' || l_return_status);
		 END IF;

		 IF l_return_status = fnd_api.g_ret_sts_error THEN
		    RAISE fnd_api.g_exc_error;
		 END IF;

		 --
		 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;
	      END IF;

		   --MUOM Fulfillment Project
		inv_utilities.get_inv_fulfillment_base(
			p_source_line_id		  => l_rsv_rec.demand_source_line_id,
			p_demand_source_type_id => l_rsv_rec.demand_source_type_id,
			p_org_id				  => l_rsv_rec.organization_id,
			x_fulfillment_base		 => l_fulfill_base
			);

   IF  (l_fulfill_base = 'S') THEN
       IF  (l_qty_changed > 0
		   AND l_qty_changed > l_rsv_rec.primary_reservation_quantity - nvl(l_rsv_rec.detailed_quantity, 0)
       AND l_secondary_qty_changed =l_rsv_rec.secondary_reservation_quantity) THEN

       l_rsv_rec.primary_reservation_quantity  := l_qty_changed + NVL(l_rsv_rec.detailed_quantity, 0);
             IF (l_debug = 1) THEN
		    debug_print('l_rsv_rec.detailed_quantity:  when fulfilment base is S' || l_rsv_rec.detailed_quantity);
		    debug_print('l_rsv_rec.primary_reservation_quantity: when fulfilment base is S ' || l_rsv_rec.primary_reservation_quantity);
		    debug_print('l_rsv_rec.secondary_reservation_quantity: when fulfilment base is S' || l_rsv_rec.secondary_reservation_quantity);
	    END IF;
       END IF;
    END IF;

	      /**** {{ R12 Enhanced reservations code changes }}****/
	      --Setting the serial reservation quantity

              /*** move to before insert_row
	      IF l_serial_number.COUNT > 0 THEN
		 l_rsv_rec.serial_reservation_quantity := l_serial_number.COUNT;
		 IF (l_rsv_rec.serial_reservation_quantity > l_rsv_rec.primary_reservation_quantity) THEN
		    fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
		 END IF;

	      END IF;
              ********************/
	      /*** End R12 ***/

		/**** {{ R12 Enhanced reservations code changes }}****/
		ELSIF (l_rsv_rec.supply_source_type_id IN
		       (inv_reservation_global.g_source_type_wip,
			inv_reservation_global.g_source_type_po,
			inv_reservation_global.g_source_type_asn,
			inv_reservation_global.g_source_type_intransit,
			inv_reservation_global.g_source_type_internal_req,
			inv_reservation_global.g_source_type_rcv)) AND
		  p_over_reservation_flag NOT IN (1,3) THEN
	      -- call the available to reserve API to get the supply and
	      -- demand availability
	      -- Bug 5199672: Should pass g_miss_num as default for supply
	      -- source line detail. Otherwise, high level reservations
	      -- will not be considered.

	      inv_reservation_avail_pvt.available_supply_to_reserve
		(
		 x_return_status                   => l_return_status
		 , x_msg_count                     => x_msg_count
		 , x_msg_data                      => x_msg_data
		 , x_qty_available_to_reserve      => l_qty_changed
		 , x_qty_available                 => l_qty_available
		 , p_organization_id               => l_rsv_rec.organization_id
		 , p_item_id	                   => l_rsv_rec.inventory_item_id
		 , p_revision                      => l_rsv_rec.revision
		 , p_lot_number                    => l_rsv_rec.lot_number
		 , p_subinventory_code             => l_rsv_rec.subinventory_code
		 , p_locator_id	                   => l_rsv_rec.locator_id
		 , p_supply_source_type_id	    => l_rsv_rec.supply_source_type_id
		 , p_supply_source_header_id	    => l_rsv_rec.supply_source_header_id
		 , p_supply_source_line_id	    => l_rsv_rec.supply_source_line_id
		 , p_supply_source_line_detail	    => Nvl(l_rsv_rec.supply_source_line_detail,fnd_api.g_miss_num)
		 , p_lpn_id			    => l_rsv_rec.lpn_id
		 , p_project_id		            => l_rsv_rec.project_id
		, p_task_id			    => l_rsv_rec.task_id
		, p_api_version_number     	    => 1.0
		, p_init_msg_lst             	    => fnd_api.g_false
		);

	      IF (l_debug = 1) THEN
		 debug_print('After calling available supply to reserve ' || l_return_status);
		 debug_print('Available quantity to reserve. l_qty_changed: ' || l_qty_changed);
		 debug_print('Available quantity on the document. l_qty_available: ' || l_qty_available);
	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;

         -- bug #5454715. Error out if the available supply to reserve is zero.
         IF l_qty_changed = 0 THEN
          fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
         END IF;


	      -- Bug 5199672: Removed the condition l_qty_changed > 0
	      IF ((l_rsv_rec.primary_reservation_quantity - l_qty_changed) > 0.000005) THEN

		   IF (p_partial_reservation_flag = fnd_api.g_false) THEN
		    IF (l_debug = 1) THEN
		       debug_print('The supply document doesnt have enough quantity to be reserved against. error out. ');
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
		  ELSE
		    l_rsv_rec.primary_reservation_quantity  := l_qty_changed + NVL(l_rsv_rec.detailed_quantity, 0);
		    l_rsv_rec.reservation_quantity          := NULL;
		    IF (l_debug = 1) THEN
		       debug_print('l_rsv_rec.detailed_quantity: ' || l_rsv_rec.detailed_quantity);
		       debug_print('l_rsv_rec.primary_reservation_quantity: ' || l_rsv_rec.primary_reservation_quantity);
		    END IF;
		    convert_quantity(x_return_status => l_return_status, px_rsv_rec => l_rsv_rec);

		    IF (l_debug = 1) THEN
		       debug_print('After convert qty ' || l_return_status);
		    END IF;

		    IF l_return_status = fnd_api.g_ret_sts_error THEN
		       RAISE fnd_api.g_exc_error;
		    END IF;

		    --
		    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		       RAISE fnd_api.g_exc_unexpected_error;
		    END IF;

		 END IF;
	      END IF;
	   END IF;

	   IF (l_rsv_rec.demand_source_type_id IN
	       (inv_reservation_global.g_source_type_wip,
		inv_reservation_global.g_source_type_oe,
		inv_reservation_global.g_source_type_internal_ord,
		inv_reservation_global.g_source_type_rma))  AND
	     p_over_reservation_flag NOT IN (2,3) THEN

	      -- Bug 5199672: Should pass g_miss_num as default for demand
	      -- source line detail. Otherwise, high level reservations
	      -- will not be considered.

		  -- MUOM Fulfillment project
	      inv_reservation_avail_pvt.available_demand_to_reserve
		(
		 x_return_status                   => l_return_status
		 , x_msg_count                     => x_msg_count
		 , x_msg_data                      => x_msg_data
		 , x_qty_available_to_reserve      => l_qty_changed
		 , x_qty_available                 => l_qty_available
		 , x_qty_available_to_reserve2  => l_qty_changed2
                 , x_qty_available2                 => l_qty_available2
		 , p_organization_id               => l_rsv_rec.organization_id
		 , p_item_id                       => l_rsv_rec.inventory_item_id
		 , p_primary_uom_code              => l_rsv_rec.primary_uom_code
		 , p_demand_source_type_id	   => l_rsv_rec.demand_source_type_id
		 , p_demand_source_header_id	   => l_rsv_rec.demand_source_header_id
		 , p_demand_source_line_id	   => l_rsv_rec.demand_source_line_id
		 , p_demand_source_line_detail     => Nvl(l_rsv_rec.demand_source_line_detail,fnd_api.g_miss_num)
		 , p_project_id		           => l_rsv_rec.project_id
		 , p_task_id			   => l_rsv_rec.task_id
		 , p_api_version_number     	   => 1.0
		 , p_init_msg_lst             	   => fnd_api.g_false
		 );


	      IF (l_debug = 1) THEN
		 debug_print('After calling available demand to reserve ' || l_return_status);
		 debug_print('Available quantity to reserve. l_qty_changed: ' || l_qty_changed);
		 debug_print('Available quantity on the document. l_qty_available: ' || l_qty_available);
                 debug_print('Available quantity to reserve. l_qty_changed2: ' || l_qty_changed2);
		 debug_print('Available quantity on the document. l_qty_available2: ' || l_qty_available2);

	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;


	      IF (l_rsv_rec.demand_source_type_id in (inv_reservation_global.g_source_type_oe,
						 inv_reservation_global.g_source_type_internal_ord,
						 inv_reservation_global.g_source_type_rma)) THEN

		 IF NOT
		   (lot_divisible
		    (p_inventory_item_id => l_rsv_rec.inventory_item_id,
		     p_organization_id => l_rsv_rec.organization_id)) THEN
		    get_ship_qty_tolerance
		      (
		       p_api_version_number          =>  1.0
		       , p_init_msg_lst              =>  fnd_api.g_false
		       , x_return_status             => x_return_status
		       , x_msg_count                 => x_msg_count
		       , x_msg_data                  => x_msg_data
		       , p_demand_type_id            => l_rsv_rec.demand_source_type_id
		       , p_demand_header_id          => l_rsv_rec.demand_source_header_id
		       , p_demand_line_id            => l_rsv_rec.demand_source_line_id
		       , x_reservation_margin_above  => l_reservation_margin_above);

		    IF (l_debug = 1) THEN
		       debug_print('Inside is lot indivisible');
		    END IF;

		    IF (l_debug = 1) THEN
		       debug_print('After calling get_ship_qty_tolerance ' || x_return_status);
		       debug_print('Reservation margin above ' || l_reservation_margin_above);
		    END IF;

		    --
		    IF x_return_status = fnd_api.g_ret_sts_error THEN
		       RAISE fnd_api.g_exc_error;
		    END IF;

		    --
		    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
		       RAISE fnd_api.g_exc_unexpected_error;
		    END IF;
		           --MUOM Fulfillment Project

	           If l_fulfill_base <> 'S' Then
	              l_qty_changed := l_qty_changed + l_reservation_margin_above;
	              l_qty_available := l_qty_available + l_reservation_margin_above;
	           Else
		       l_qty_changed2 := l_qty_changed2 + l_reservation_margin_above;
		       l_qty_available2 := l_qty_available2 + l_reservation_margin_above;
	           END IF;

		 END IF;
	      END IF;

	      IF (l_debug = 1) THEN
		 debug_print('available quantity to reserve. l_qty_changed: ' || l_qty_changed);
		 debug_print('available quantity on the document. l_qty_available: ' || l_qty_available);
                 debug_print('available quantity on the document. l_qty_changed2: ' || l_qty_changed2);
	      END IF;

          --Bug 12978409 : start
	      -- Bug 5199672: Removed the condition l_qty_changed > 0
	      /*IF ((l_rsv_rec.primary_reservation_quantity - l_qty_changed) >
		   0.000005) THEN*/
           get_reservation_qty_lot(
 	                          p_rsv_rec              => l_rsv_rec,
 	                          p_reservation_qty_lot  => l_reservation_qty_lot);

      IF (l_fulfill_base = 'S') THEN                   -- MUOM fulfillment Project
        --
	IF (l_debug= 1) THEN
          debug_print('Available quantity on the document for FB=S is l_reservation_qty_lot: ' || l_reservation_qty_lot);
       END IF;
       --
	IF((l_reservation_qty_lot-l_qty_changed2)>0.000005) THEN
          IF (l_debug= 1) THEN
            debug_print('The demand document doesnt have enough quantity to be reserved against. error out. for fulfilment base=S');
          END IF;
          fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        END IF;
      ELSE
        IF ((l_reservation_qty_lot - l_qty_changed) > 0.000005) THEN
          IF (l_debug = 1) THEN
            debug_print('The demand document doesnt have enough quantity to be reserved against. error out. ');
          END IF;
          fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        END IF;
      END IF;   -- MUOM fulfillment Project ends

    END IF;

	   /*** End R12 ***/

	   -- Bug #2819700
	   -- Adding an extra check to make sure that create reservations does not
	   -- create a negative reservation record.
	   IF (l_debug = 1) THEN
	      debug_print('Primary_reservation_qty before inserting (create)= '
			  || To_char(l_rsv_rec.primary_reservation_quantity) );
	      debug_print('Secondary_reservation_qty before inserting (create)= '
			  || To_char(l_rsv_rec.secondary_reservation_quantity) );  -- INVCONV
	      debug_print('Reservation_qty before inserting (create)= '
			  || To_char(l_rsv_rec.reservation_quantity) );
	   END IF;

	   IF (  (NVL(l_rsv_rec.reservation_quantity,0) < 0) OR
		 (NVL(l_rsv_rec.primary_reservation_quantity,0) < 0) ) THEN
	      fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;
	   END IF;

	   --Bug 5535030 Selecting the sequence value has been moved to the table handler in
	   -- INVRSV6B.pls
/*	   -- create reservation id
	   SELECT mtl_demand_s.NEXTVAL
	     INTO l_reservation_id
	     FROM DUAL;*/
           l_reservation_id := NULL;
	   --
	   l_date := SYSDATE;

	   --
	   l_user_id            := fnd_global.user_id;
	   l_login_id           := fnd_global.login_id;

	   IF l_login_id = -1 THEN
	      l_login_id  := fnd_global.conc_login_id;
	   END IF;

	   l_request_id         := fnd_global.conc_request_id;
	   l_prog_appl_id       := fnd_global.prog_appl_id;
	   l_program_id         := fnd_global.conc_program_id;
	   --

	   IF (l_debug = 1) THEN
	      debug_print(' Before inserting record');
	      debug_print(' reservation is' || l_reservation_id);
	      debug_print(' reservation qty' || l_rsv_rec.reservation_quantity);
	      debug_print(' reservation pri qty' || l_rsv_rec.primary_reservation_quantity);
	      debug_print('l_secondary_qty_changed: ' || l_secondary_qty_changed);    -- INVCONV
	   END IF;

	   -- Bug 3461990: Reservations API should not create reservations with more
	   -- than 5 decimal places, since the transaction quantity is being
	   -- rounded to 5 decimal places.

	   l_rsv_rec.primary_reservation_quantity :=
	     Round(l_rsv_rec.primary_reservation_quantity,5);
	   l_rsv_rec.reservation_quantity := Round(l_rsv_rec.reservation_quantity,5);

           IF (l_orig_item_cache_index is NULL) THEN
              inv_reservation_util_pvt.search_item_cache
                (
                  x_return_status      => l_return_status
                 ,p_inventory_item_id  => l_rsv_rec.inventory_item_id
                 ,p_organization_id    => l_rsv_rec.organization_id
                 ,x_index              => l_orig_item_cache_index
                 );

              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                 RAISE fnd_api.g_exc_error;
              End If;

              IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              IF (l_orig_item_cache_index IS NULL) THEN
                 OPEN c_item(l_rsv_rec.inventory_item_id,l_rsv_rec.organization_id);
                 FETCH c_item into l_item_rec;
                 CLOSE c_item;

                 inv_reservation_util_pvt.add_item_cache
                  (
                   x_return_status              => l_return_status
                  ,p_item_record                => l_item_rec
                  ,x_index                      => l_orig_item_cache_index
                  );

                 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                   RAISE fnd_api.g_exc_error;
                 END IF;

                 IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                   RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF;
           END IF;

	   IF is_dual_control(l_orig_item_cache_index) THEN                          -- INVCONV
	      l_dual_control_flag := 'Y';
	      l_rsv_rec.secondary_reservation_quantity :=
		Round(l_rsv_rec.secondary_reservation_quantity,5);                    -- INVCONV
	   END IF;                                                                   -- INVCONV

           IF l_serial_number.COUNT > 0 THEN
              l_rsv_rec.serial_reservation_quantity := l_serial_number.COUNT;
              IF (l_rsv_rec.serial_reservation_quantity > l_rsv_rec.primary_reservation_quantity) THEN
                 fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_error;
              END IF;
           END IF;

             -- Added for bug 8851133 -Start
            IF (l_dual_control_flag = 'Y') THEN
                       IF (  l_rsv_rec.detailed_quantity = 0 ) THEN
                                 l_rsv_rec.secondary_detailed_quantity := 0;
                        END IF;
            ELSE
                        l_rsv_rec.secondary_reservation_quantity := NULL;
            END IF;

            -- bug 8851133 - End

	   IF (l_debug = 1) THEN
	      debug_print(' Create: Before inserting record');
	      debug_print(' After rounding reservation = ' || l_reservation_id);
	      debug_print(' After rounding reservation qty = ' || l_rsv_rec.reservation_quantity);
	      debug_print(' After rounding reservation pri qty = ' || l_rsv_rec.primary_reservation_quantity);
	      debug_print(' After rounding reservation sec qty = ' || l_rsv_rec.secondary_reservation_quantity); -- INVCONV
              debug_print(' serial reservation qty = ' || l_rsv_rec.serial_reservation_quantity);
	   END IF;

	   -- INVCONV - Upgrade call to incorporate secondaries
	   mtl_reservations_pkg.insert_row
	     (
	      x_rowid                       => l_rowid
	      , x_reservation_id             => l_reservation_id
	      , x_requirement_date           => l_rsv_rec.requirement_date
	      , x_organization_id            => l_rsv_rec.organization_id
	      , x_inventory_item_id          => l_rsv_rec.inventory_item_id
	      , x_demand_source_type_id      => l_rsv_rec.demand_source_type_id
	      , x_demand_source_name         => l_rsv_rec.demand_source_name
	      , x_demand_source_header_id    => l_rsv_rec.demand_source_header_id
	      , x_demand_source_line_id      => l_rsv_rec.demand_source_line_id
	      , x_demand_source_delivery     => l_rsv_rec.demand_source_delivery
	      , x_primary_uom_code           => l_rsv_rec.primary_uom_code
	      , x_primary_uom_id             => l_rsv_rec.primary_uom_id
	      , x_secondary_uom_code         => l_rsv_rec.secondary_uom_code
	      , x_secondary_uom_id           => l_rsv_rec.secondary_uom_id
	      , x_reservation_uom_code       => l_rsv_rec.reservation_uom_code
	     , x_reservation_uom_id         => l_rsv_rec.reservation_uom_id
	     , x_reservation_quantity       => l_rsv_rec.reservation_quantity
	     , x_primary_reservation_quantity=> l_rsv_rec.primary_reservation_quantity
	     , x_second_reservation_quantity=> l_rsv_rec.secondary_reservation_quantity
	     , x_detailed_quantity          => l_rsv_rec.detailed_quantity
	     , x_secondary_detailed_quantity=> l_rsv_rec.secondary_detailed_quantity
	     , x_autodetail_group_id        => l_rsv_rec.autodetail_group_id
	     , x_external_source_code       => l_rsv_rec.external_source_code
	     , x_external_source_line_id    => l_rsv_rec.external_source_line_id
	     , x_supply_source_type_id      => l_rsv_rec.supply_source_type_id
	     , x_supply_source_header_id    => l_rsv_rec.supply_source_header_id
	     , x_supply_source_line_id      => l_rsv_rec.supply_source_line_id
	     , x_supply_source_line_detail  => l_rsv_rec.supply_source_line_detail
	     , x_supply_source_name         => l_rsv_rec.supply_source_name
	     , x_revision                   => l_rsv_rec.revision
	     , x_subinventory_code          => l_rsv_rec.subinventory_code
	     , x_subinventory_id            => l_rsv_rec.subinventory_id
	     , x_locator_id                 => l_rsv_rec.locator_id
	     , x_lot_number                 => l_rsv_rec.lot_number
	     , x_lot_number_id              => l_rsv_rec.lot_number_id
	     , x_serial_number              => NULL
	     , x_serial_number_id           => NULL
	     , x_partial_quantities_allowed => NULL
	     , x_auto_detailed              => NULL
	     , x_pick_slip_number           => l_rsv_rec.pick_slip_number
	     , x_lpn_id                     => l_rsv_rec.lpn_id
	     , x_last_update_date           => l_date
	     , x_last_updated_by            => l_user_id
	     , x_creation_date              => l_date
	     , x_created_by                 => l_user_id
	     , x_last_update_login          => l_login_id
	     , x_request_id                 => l_request_id
	     , x_program_application_id     => l_prog_appl_id
	     , x_program_id                 => l_program_id
	     , x_program_update_date        => l_date
	     , x_attribute_category         => l_rsv_rec.attribute_category
	     , x_attribute1                 => l_rsv_rec.attribute1
	     , x_attribute2                 => l_rsv_rec.attribute2
	     , x_attribute3                 => l_rsv_rec.attribute3
	     , x_attribute4                 => l_rsv_rec.attribute4
	     , x_attribute5                 => l_rsv_rec.attribute5
	     , x_attribute6                 => l_rsv_rec.attribute6
	     , x_attribute7                 => l_rsv_rec.attribute7
	     , x_attribute8                 => l_rsv_rec.attribute8
	     , x_attribute9                 => l_rsv_rec.attribute9
	     , x_attribute10                => l_rsv_rec.attribute10
	     , x_attribute11                => l_rsv_rec.attribute11
	     , x_attribute12                => l_rsv_rec.attribute12
	     , x_attribute13                => l_rsv_rec.attribute13
	     , x_attribute14                => l_rsv_rec.attribute14
	     , x_attribute15                => l_rsv_rec.attribute15
	     , x_ship_ready_flag            => l_rsv_rec.ship_ready_flag
	     , x_staged_flag                => l_rsv_rec.staged_flag
	     /**** {{ R12 Enhanced reservations code changes }}****/
	     , x_crossdock_flag             => l_rsv_rec.crossdock_flag
	     , x_crossdock_criteria_id      => l_rsv_rec.crossdock_criteria_id
	     , x_demand_source_line_detail  => l_rsv_rec.demand_source_line_detail
	     , x_serial_reservation_quantity => l_rsv_rec.serial_reservation_quantity
	     , x_supply_receipt_date        => l_rsv_rec.supply_receipt_date
	     , x_demand_ship_date             => l_rsv_rec.demand_ship_date
	     , x_project_id                   => l_rsv_rec.project_id
	     , x_task_id                      => l_rsv_rec.task_id
	     , x_orig_supply_type_id   => l_rsv_rec.supply_source_type_id
	     , x_orig_supply_header_id => l_rsv_rec.supply_source_header_id
	     , x_orig_supply_line_id     => l_rsv_rec.supply_source_line_id
	     , x_orig_supply_line_detail => l_rsv_rec.supply_source_line_detail
	     , x_orig_demand_type_id     => l_rsv_rec.demand_source_type_id
	     , x_orig_demand_header_id   => l_rsv_rec.demand_source_header_id
	     , x_orig_demand_line_id     => l_rsv_rec.demand_source_line_id
	     , x_orig_demand_line_detail => l_rsv_rec.demand_source_line_detail
	     /*** End R12 ***/
	     );

  	   IF (l_debug = 1) THEN
		   debug_print(' After call to insert_row reservation_id = ' || l_reservation_id);
	   END IF;
	   IF (l_debug = 1) THEN
	      debug_print('before sync ' || l_return_status);
	   END IF;
	   -- for data sync b/w mtl_demand and mtl_reservations
	   inv_rsv_synch.for_insert(p_reservation_id => l_reservation_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

	   IF (l_debug = 1) THEN
	      debug_print('After sync ' || l_return_status);
	   END IF;

	   IF l_return_status = fnd_api.g_ret_sts_error THEN
	      RAISE fnd_api.g_exc_error;
	   END IF;

	   --
	   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   /**** {{ R12 Enhanced reservations code changes. Serial number
	   -- changes for creating new reservations  }}****/

	   IF (l_debug = 1) THEN
	      debug_print('Serial number count' || l_serial_number.COUNT);
	      debug_print('Original Serial number count' || p_serial_number.COUNT);
	   END IF;

	   IF l_serial_number.COUNT > 0 THEN

	      IF (l_debug = 1) THEN
		 debug_print('Inside serial loop' || l_serial_number.COUNT);
	      END IF;

	      FOR l_serial_index IN l_serial_number.first..l_serial_number.last
		LOOP
		   IF (l_debug = 1) THEN
		      debug_print('reservation id' ||
				  l_rsv_rec.reservation_id);
		      debug_print('serial number' ||
				  l_serial_number(l_serial_index).serial_number);
		      debug_print('inventory item id' ||
				  l_rsv_rec.inventory_item_id);
		      debug_print('org id' ||
				  l_rsv_rec.organization_id);

		   END IF;

		 BEGIN
		    SELECT group_mark_id INTO l_group_mark_id FROM
		      mtl_serial_numbers WHERE
		      serial_number = l_serial_number(l_serial_index).serial_number AND
		      inventory_item_id = l_rsv_rec.inventory_item_id AND
		      current_organization_id = l_rsv_rec.organization_id;
		    EXCEPTION
		    WHEN no_data_found THEN

		       IF (l_debug = 1) THEN
			  debug_print('Errow while selecting the serial number. serial Number ' || l_serial_number(l_serial_index).serial_number);
		       END IF;
		       fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		       fnd_msg_pub.ADD;
		       RAISE fnd_api.g_exc_error;
		 END;

		 IF (l_group_mark_id IS NOT NULL)  AND (l_group_mark_id <> -1)THEN
		    IF (l_debug = 1) THEN
		       debug_print('Group Mark Id is not null for serial ' || l_serial_number(l_serial_index).serial_number);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
		 END IF;

		 BEGIN
		    UPDATE mtl_serial_numbers SET reservation_id =
		      l_reservation_id, group_mark_id =
		      l_reservation_id WHERE
		      serial_number = l_serial_number(l_serial_index).serial_number AND
		      inventory_item_id = l_rsv_rec.inventory_item_id AND
		      current_organization_id = l_rsv_rec.organization_id;

		 EXCEPTION
		    WHEN no_data_found THEN

		       IF (l_debug = 1) THEN
			  debug_print('Errow while updating the serial number. serial Number ' || l_serial_number(l_serial_index).serial_number || ' Reservation Id : ' || l_rsv_rec.reservation_id);
		       END IF;
		       fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		       fnd_msg_pub.ADD;
		       RAISE fnd_api.g_exc_error;
		 END;
		END LOOP;

	   END IF;

	   /*** End R12 ***/
	   --
	   -- Post Insert CTO Validation
	   IF l_rsv_rec.demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
	      --
	      cto_workflow_api_pk.wf_update_after_inv_reserv(p_order_line_id => l_rsv_rec.demand_source_line_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

	      IF (l_debug = 1) THEN
		 debug_print('After post CTO validation ' || l_return_status);
	      END IF;
	      --
	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      --
	      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	   END IF;

	   insert_rsv_temp
	     (
	      p_organization_id            => l_rsv_rec.organization_id
	      , p_inventory_item_id          => l_rsv_rec.inventory_item_id
	      , p_primary_reservation_quantity=> l_rsv_rec.primary_reservation_quantity
	      , p_tree_id                    => l_tree_id
	      , p_reservation_id             => l_reservation_id
	      , x_return_status              => l_return_status
	      , p_demand_source_line_id      => l_rsv_rec.demand_source_line_id
	      , p_demand_source_header_id    => l_rsv_rec.demand_source_header_id
	      , p_demand_source_name         => l_rsv_rec.demand_source_name
	      );

	   IF (l_debug = 1) THEN
	      debug_print('After insert into rsv temp ' || l_return_status);
	   END IF;

	   IF l_return_status = fnd_api.g_ret_sts_error THEN
	      RAISE fnd_api.g_exc_error;
	   END IF;

	   --
	   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   --
	   IF (l_debug = 1) THEN
	      debug_print('Final status after create reservation API ' ||
			  l_return_status);
	      debug_print('qty reserved ' ||
			  l_rsv_rec.primary_reservation_quantity);
	      debug_print('secondary qty reserved ' ||
			  l_rsv_rec.secondary_reservation_quantity);                  -- INVCONV
	      debug_print('reservation id' ||
			  l_reservation_id);

	   END IF;

	   /**** {{ R12 Enhanced reservations code changes. Should be
	   -- releasing the locks. }} *****/
	   IF l_lock_obtained THEN
	      inv_reservation_lock_pvt.release_lock
		(l_supply_lock_handle);
	      inv_reservation_lock_pvt.release_lock
		(l_demand_lock_handle);
	   END IF;
	   /*** End R12 ***/

	   -- set output variables
	   x_quantity_reserved  := l_rsv_rec.primary_reservation_quantity;

	   IF l_dual_control_flag = 'Y' THEN                           -- INVCONV
	      x_secondary_quantity_reserved := l_rsv_rec.secondary_reservation_quantity; -- INVCONV
	   END IF;                                                                    -- INVCONV

	   x_reservation_id     := l_reservation_id;
	   --
	   x_return_status      := l_return_status;
	   /**** {{ R12 Enhanced reservations code changes. Serial number
	   -- changes for creating new reservations  }}****/
	   x_serial_number := l_serial_number;
	   /*** End R12 ***/
	   --

	   /**** {{ R12 Enhanced reservations code changes }}****/
    END IF; -- If not l_rsv is true
    -- Do this only if the l_rsv_is set to false. Otherwise, we
    -- would have updated the record.
    /*** End R12 ***/

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
	ROLLBACK TO create_reservation_sa;
	x_return_status  := fnd_api.g_ret_sts_error;
	/**** {{ R12 Enhanced reservations code changes. Should be
	-- releasing the locks. }} *****/
	IF l_lock_obtained THEN
	   inv_reservation_lock_pvt.release_lock
	     (l_supply_lock_handle);
	   inv_reservation_lock_pvt.release_lock
	     (l_demand_lock_handle);
	END IF;
	/*** End R12 ***/
	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN fnd_api.g_exc_unexpected_error THEN
	ROLLBACK TO create_reservation_sa;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	/**** {{ R12 Enhanced reservations code changes. Should be
	-- releasing the locks. }} *****/
	IF l_lock_obtained THEN
	   inv_reservation_lock_pvt.release_lock
	     (l_supply_lock_handle);
	   inv_reservation_lock_pvt.release_lock
	     (l_demand_lock_handle);
	END IF;
	/*** End R12 ***/
	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN OTHERS THEN
	ROLLBACK TO create_reservation_sa;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	/**** {{ R12 Enhanced reservations code changes. Should be
	-- releasing the locks. }} *****/
	IF l_lock_obtained THEN
	   inv_reservation_lock_pvt.release_lock
	     (l_supply_lock_handle);
	   inv_reservation_lock_pvt.release_lock
	     (l_demand_lock_handle);
	END IF;
	/*** End R12 ***/
	IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	END IF;

	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_reservation;


  PROCEDURE update_reservation
    (
     p_api_version_number            IN     NUMBER
     , p_init_msg_lst                  IN     VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status                 OUT    NOCOPY VARCHAR2
     , x_msg_count                     OUT    NOCOPY NUMBER
     , x_msg_data                      OUT    NOCOPY VARCHAR2
     , p_original_rsv_rec              IN     inv_reservation_global.mtl_reservation_rec_type
     , p_to_rsv_rec                    IN     inv_reservation_global.mtl_reservation_rec_type
     , p_original_serial_number        IN     inv_reservation_global.serial_number_tbl_type
     , p_to_serial_number              IN     inv_reservation_global.serial_number_tbl_type
     , p_validation_flag               IN     VARCHAR2 DEFAULT fnd_api.g_true
     , p_check_availability            IN     VARCHAR2 DEFAULT fnd_api.g_false
     , p_over_reservation_flag         IN  NUMBER DEFAULT 0
     ) IS


     l_api_version_number CONSTANT NUMBER :=  1.0;
     l_api_name           CONSTANT VARCHAR2(30) := 'Update_Reservation';
     l_return_status      VARCHAR2(1) :=  fnd_api.g_ret_sts_success;
     l_quantity_reserved  NUMBER;
     l_secondary_quantity_reserved NUMBER;          -- INVCONV
     l_debug NUMBER;

     l_reservation_qty_lot NUMBER := 0; --Bug 12978409

    BEGIN
       --  Standard call to check for call compatibility
       IF NOT fnd_api.compatible_api_call
	 (l_api_version_number
	  , p_api_version_number
	  , l_api_name
	  , G_PKG_NAME
	  ) THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       --  Initialize message list.
       IF fnd_api.to_boolean(p_init_msg_lst) THEN
	  fnd_msg_pub.initialize;
       END IF;

       -- Use cache to get value for l_debug
       IF g_is_pickrelease_set IS NULL THEN
          g_is_pickrelease_set := 2;
          IF INV_CACHE.is_pickrelease THEN
             g_is_pickrelease_set := 1;
          END IF;
       END IF;
       IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
          g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       END IF;

       l_debug := g_debug;

       IF l_debug=1 THEN
	  debug_print('Calling the overloaded procedure update_reservation');
       END IF;

       -- INVCONV Upgrade call to incorporate secondary_quantity_reserved
       inv_reservation_pvt.update_reservation
	 (p_api_version_number          => 1.0,
	  p_init_msg_lst                => fnd_api.g_false,
	  x_return_status               => l_return_status,
	  x_msg_count                   => x_msg_count,
	  x_msg_data                    => x_msg_data,
	  x_quantity_reserved           => l_quantity_reserved,
	  x_secondary_quantity_reserved => l_secondary_quantity_reserved,
	  p_original_rsv_rec            => p_original_rsv_rec,
	  p_to_rsv_rec                  => p_to_rsv_rec,
	  p_original_serial_number      => p_original_serial_number ,
	  p_to_serial_number            => p_to_serial_number,
	  p_validation_flag             => p_validation_flag,
	  p_partial_reservation_flag    => fnd_api.g_false,
	  p_check_availability          => p_check_availability,
	  p_over_reservation_flag       => p_over_reservation_flag
	  );


       IF (l_debug=1) THEN
	  debug_print ('Return Status after updating reservations '||l_return_status);
       END IF;

       IF l_return_status = fnd_api.g_ret_sts_error THEN

	  IF l_debug=1 THEN
	     debug_print('Raising expected error'||l_return_status);
	  END IF;

	  RAISE fnd_api.g_exc_error;

	ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

	  IF l_debug=1 THEN
	     debug_print('Raising Unexpected error'||l_return_status);
	  END IF;

	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;


       x_return_status := l_return_status;

    EXCEPTION

       WHEN fnd_api.g_exc_error THEN
	  x_return_status := fnd_api.g_ret_sts_error;
	  --  Get message count and data
	  fnd_msg_pub.count_and_get
	    (  p_count => x_msg_count
	       , p_data  => x_msg_data
	       );

       WHEN fnd_api.g_exc_unexpected_error THEN
	  x_return_status := fnd_api.g_ret_sts_unexp_error ;

          --  Get message count and data
	  fnd_msg_pub.count_and_get
	    (  p_count  => x_msg_count
	       , p_data   => x_msg_data
	       );

       WHEN OTHERS THEN
	  x_return_status := fnd_api.g_ret_sts_unexp_error ;

	  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	    THEN
	     fnd_msg_pub.add_exc_msg
	       (  g_pkg_name
		  , l_api_name
		  );
	  END IF;

	  --  Get message count and data
	  fnd_msg_pub.count_and_get
	    (  p_count  => x_msg_count
	       , p_data   => x_msg_data
	       );

    END update_reservation;

    --overloaded procedure
    --
    -- INVCONV incorporate parameter x_secondary_quantity_reserved
    PROCEDURE update_reservation
      (
       p_api_version_number              IN     NUMBER
       , p_init_msg_lst                  IN     VARCHAR2 DEFAULT fnd_api.g_false
       , x_return_status                 OUT    NOCOPY VARCHAR2
       , x_msg_count                     OUT    NOCOPY NUMBER
       , x_msg_data                      OUT    NOCOPY VARCHAR2
       , x_quantity_reserved             OUT    NOCOPY NUMBER
       , x_secondary_quantity_reserved   OUT    NOCOPY NUMBER
       , p_original_rsv_rec              IN     inv_reservation_global.mtl_reservation_rec_type
       , p_to_rsv_rec                    IN     inv_reservation_global.mtl_reservation_rec_type
       , p_original_serial_number        IN     inv_reservation_global.serial_number_tbl_type
       , p_to_serial_number              IN     inv_reservation_global.serial_number_tbl_type
       , p_validation_flag               IN     VARCHAR2 DEFAULT fnd_api.g_true
       , p_partial_reservation_flag      IN     VARCHAR2 DEFAULT fnd_api.g_false
       , p_check_availability            IN     VARCHAR2 DEFAULT fnd_api.g_false
       , p_over_reservation_flag         IN  NUMBER DEFAULT 0
      ) IS
	 l_api_version_number  CONSTANT NUMBER        := 1.0;
	 l_api_name            CONSTANT VARCHAR2(30)  := 'Update_Reservation';
	 l_return_status  VARCHAR2(1)            := fnd_api.g_ret_sts_success;
	 l_miss_num  NUMBER                 := fnd_api.g_miss_num;
	 l_miss_char VARCHAR2(1)            := fnd_api.g_miss_char;
	 l_original_rsv_rec inv_reservation_global.mtl_reservation_rec_type;
	 l_to_rsv_rec   inv_reservation_global.mtl_reservation_rec_type;
	 l_orig_rsv_tbl inv_reservation_global.mtl_reservation_tbl_type;
	 l_orig_rsv_tbl_count  NUMBER;
	 l_to_rsv_tbl  inv_reservation_global.mtl_reservation_tbl_type;
	 --
	 l_to_rsv_tbl_count            NUMBER;
	 l_tree_id1                    INTEGER;
	 l_tree_id2                    INTEGER;
	 l_primary_quantity_reserved   NUMBER;
	 l_primary_uom_code            VARCHAR2(3);
	 l_orig_item_cache_index       INTEGER                                         := NULL;
	 l_orig_org_cache_index        INTEGER                                         := NULL;
	 l_orig_demand_cache_index     INTEGER                                         := NULL;
	 l_orig_supply_cache_index     INTEGER                                         := NULL;
	 l_orig_sub_cache_index        INTEGER                                         := NULL;
	 l_to_item_cache_index         INTEGER                                         := NULL;
	 l_to_org_cache_index          INTEGER                                         := NULL;
	 l_to_demand_cache_index       INTEGER                                         := NULL;
	 l_to_supply_cache_index       INTEGER                                         := NULL;
	 l_to_sub_cache_index          INTEGER                                         := NULL;
	 l_date                        DATE;
	 l_user_id                     NUMBER;
	 l_request_id                  NUMBER;
	 l_login_id                    NUMBER;
	 l_prog_appl_id                NUMBER;
	 l_program_id                  NUMBER;
	 l_error_code                  NUMBER;
	 l_debug number;
	 l_quantity_reserved           NUMBER;
	 l_secondary_quantity_reserved NUMBER;                                        -- INVCONV
	 l_lot_divisible_flag          VARCHAR2(1)      := 'Y' ;                      -- INVCONV
	 l_dual_control_flag           VARCHAR2(1)      := 'N' ;
	 -- INVCONV
	 /**** {{ R12 Enhanced reservations code changes }}****/
	 l_original_serial_number inv_reservation_global.serial_number_tbl_type;
	 l_to_serial_number inv_reservation_global.serial_number_tbl_type;
	 l_qty_available NUMBER := 0;
	 l_serial_number_table inv_reservation_global.serial_number_tbl_type;
	 l_dummy_serial_array  inv_reservation_global.serial_number_tbl_type;
	 l_dummy_rsv_rec inv_reservation_global.mtl_reservation_rec_type;
	 l_serials_tobe_unreserved NUMBER;
	 l_total_serials_reserved NUMBER;
	 l_reservation_id NUMBER;
	 l_original_serial_count NUMBER;
	 l_to_serial_count NUMBER;
	 l_supply_lock_handle varchar2(128);
	 l_demand_lock_handle varchar2(128);
	 l_lock_status NUMBER;
         l_reservable_qty NUMBER;
	 l_booked_flag VARCHAR2(1) := 'N';
	 l_open_flag	VARCHAR2(1);
	 l_group_mark_id NUMBER := NULL;
	 l_lock_obtained BOOLEAN := FALSE;
	 l_pjm_enabled NUMBER;
	 l_project_id NUMBER;
	 l_task_id NUMBER;
	 l_supply_source_type_id NUMBER;
	 /*** End R12 ***/

    /* Added for CMRO bug 13829182 */
    l_wip_entity_id NUMBER;
    l_wip_entity_type NUMBER;
    l_wip_job_type VARCHAR2(15);
    l_maintenance_object_source NUMBER;
    /* End of changes for CMRO bug 13829182 */
	-- MUOM Fulfillment Project
    l_reservable_qty2 NUMBER;
    l_qty_available2  NUMBER;
    l_fulfill_base   VARCHAR2(1) := 'P';
    l_org_sec_rsv_qty  NUMBER;

	-- changes for bug 9874238 start
	 CURSOR c_item(p_inventory_item_id NUMBER,p_organization_id NUMBER) IS
         SELECT *
           FROM mtl_system_items
          WHERE inventory_Item_Id = p_inventory_item_id
	  AND organization_id = p_organization_id;
	 l_item_rec  inv_reservation_global.item_record;
	-- changes for bug 9874238 end
    l_reservation_qty_lot NUMBER := 0; --Bug 12978409
    BEGIN

     /*Bug 4700706. Moved the following statement up as otherwise when it was somewhere in the middle of  the
       procedure and if any error occurs before the definition of the savepoint , it would go to the EXCEPTION
       block and there we have 'Rollback to update_reservation_sa' statement which was causing issue.
     */
     SAVEPOINT update_reservation_sa;

       -- Use cache to get value for l_debug
       IF g_is_pickrelease_set IS NULL THEN
	  g_is_pickrelease_set := 2;
        IF INV_CACHE.is_pickrelease THEN
           g_is_pickrelease_set := 1;
        END IF;
     END IF;
     IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;

     IF (l_debug = 1) THEN
        debug_print('Inside update reservation...');
     END IF;


     --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('The original reservation record: ');
    END IF;

    print_rsv_rec(p_original_rsv_rec);

    IF (l_debug = 1) THEN
       debug_print('The to reservation record: ');
    END IF;

    print_rsv_rec(p_to_rsv_rec);

    -- Bug #2819700
    -- Adding an extra check to make sure that the update reservations does
    -- not update the existing record to negative. Raise an exception.
    IF (l_debug = 1) THEN
      debug_print('Primary_reservation_qty before inserting (update)= '
		              || To_char(p_to_rsv_rec.primary_reservation_quantity));
      debug_print('Secondary_reservation_qty before inserting (update)= '
                              || To_char(p_to_rsv_rec.secondary_reservation_quantity));  -- INVCONV
      debug_print('Reservation_qty before inserting (update)= '
		              || To_char(p_to_rsv_rec.reservation_quantity));
    END IF;

    IF ((NVL(p_to_rsv_rec.reservation_quantity,0) < 0) OR
	      (NVL(p_to_rsv_rec.primary_reservation_quantity,0) < 0) ) THEN
      fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- INVCONV BEGIN
    /*Bug#13045525 Changing the condition as the validation makes sense when the primary quantity is greater than zero */
    IF (NVL(p_to_rsv_rec.primary_reservation_quantity,0) > 0) AND (NVL(p_to_rsv_rec.secondary_reservation_quantity,0) < 0) THEN
      fnd_message.set_name('INV', 'INV-INVALID NEGATIVE SECONDARY QTY');    -- INVCONV NEW MESSAGE
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    -- INVCONV END

    /**** {{ R12 Enhanced reservations code changes. Initializing orig parameters }}****/

    -- Set the original columns to g_miss_xxx as the user should not be
    -- setting these values. Do not query by them
    l_original_rsv_rec := p_original_rsv_rec;

    l_original_rsv_rec.orig_supply_source_type_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_supply_source_header_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_supply_source_line_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_supply_source_line_detail := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_demand_source_type_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_demand_source_header_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_demand_source_line_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_demand_source_line_detail := fnd_api.g_miss_num;

    /*** End R12 ***/

    --
    -- if the update to quantity is 0, call delete instead
    IF p_to_rsv_rec.primary_reservation_quantity = 0 OR
      (p_to_rsv_rec.reservation_quantity = 0 AND
       (p_to_rsv_rec.primary_reservation_quantity IS NULL OR p_to_rsv_rec.primary_reservation_quantity = fnd_api.g_miss_num))
	 THEN

       delete_reservation
	 (
	  p_api_version_number         => 1.0
	  , p_init_msg_lst             => p_init_msg_lst
	  , x_return_status            => l_return_status
	  , x_msg_count                => x_msg_count
	  , x_msg_data                 => x_msg_data
	  , p_rsv_rec                  => p_original_rsv_rec
	  , p_original_serial_number   => p_original_serial_number
	  , p_validation_flag          => p_validation_flag
	  );

       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       --
       x_return_status  := l_return_status;
       RETURN;
    END IF;

    --
    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    --
    --
    -- search for the from row
    IF (l_debug = 1) THEN
       debug_print('Querying Reservation for the from record');
    END IF;
    /**** {{ R12 Enhanced reservations code changes }}****/
    query_reservation
      (
       p_api_version_number         => 1.0
       , p_init_msg_lst               => fnd_api.g_false
       , x_return_status              => l_return_status
       , x_msg_count                  => x_msg_count
       , x_msg_data                   => x_msg_data
       , p_query_input                => l_original_rsv_rec
       , p_lock_records               => fnd_api.g_true
       , x_mtl_reservation_tbl        => l_orig_rsv_tbl
       , x_mtl_reservation_tbl_count  => l_orig_rsv_tbl_count
       , x_error_code                 => l_error_code
       );
    /*** End R12 ***/
    IF l_return_status = fnd_api.g_ret_sts_error THEN
       IF (l_debug = 1) THEN
	  debug_print('Query Reservation returned error');
       END IF;
       RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       IF (l_debug = 1) THEN
	  debug_print('Query Reservation returned unexpected error');
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    IF l_orig_rsv_tbl_count = 0 THEN
       IF (l_debug = 1) THEN
	  debug_print('Query Reservation returned no row');
       END IF;
       fnd_message.set_name('INV', 'INV-ROW NOT FOUND');
       fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_orig_rsv_tbl_count > 1 THEN
       IF (l_debug = 1) THEN
	  debug_print('Query Reservation returned more than one row');
       END IF;
       fnd_message.set_name('INV', 'INV-UPATE MORE THAN ONE RSV');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('Constructing to reservation row');
    END IF;

    construct_to_reservation_row(l_orig_rsv_tbl(1), p_to_rsv_rec, l_to_rsv_rec);

    IF (l_debug = 1) THEN
       debug_print('Constructed to reservation row');
    END IF;

    /**** {{ R12 Enhanced reservations code changes.Calling the reservation
    -- lock API to create a user-defined lock for non-inventory supplies }} *****/
    -- Bug 5199672: Should pass null to supply and demand line detail as
      -- we will have to lock the records at the document level and not at
      -- the line level. Also, for ASN, pass the source type as PO so that the
      -- the lock name would be the same as the PO's

    IF (l_to_rsv_rec.supply_source_type_id =
	inv_reservation_global.g_source_type_asn) THEN
       l_supply_source_type_id :=
	 inv_reservation_global.g_source_type_po;
     ELSE
       l_supply_source_type_id := l_to_rsv_rec.supply_source_type_id;
    END IF;

    IF (l_to_rsv_rec.supply_source_type_id <> inv_reservation_global.g_source_type_inv) THEN
       inv_reservation_lock_pvt.lock_supply_demand_record
	 (p_organization_id => l_to_rsv_rec.organization_id
	  ,p_inventory_item_id => l_to_rsv_rec.inventory_item_id
	  ,p_source_type_id => l_supply_source_type_id
	  ,p_source_header_id => l_to_rsv_rec.supply_source_header_id
	  ,p_source_line_id =>  l_to_rsv_rec.supply_source_line_id
	  ,p_source_line_detail => NULL
	  ,x_lock_handle => l_supply_lock_handle
	  ,x_lock_status => l_lock_status);

       IF l_lock_status = 0 THEN
	  fnd_message.set_name('INV', 'INV_INVALID_LOCK');
	  fnd_msg_pub.ADD;
	  RAISE fnd_api.g_exc_error;
       END if;

       inv_reservation_lock_pvt.lock_supply_demand_record
	 (p_organization_id => l_to_rsv_rec.organization_id
	  ,p_inventory_item_id => l_to_rsv_rec.inventory_item_id
	  ,p_source_type_id => l_to_rsv_rec.demand_source_type_id
	  ,p_source_header_id => l_to_rsv_rec.demand_source_header_id
	  ,p_source_line_id =>  l_to_rsv_rec.demand_source_line_id
	  ,p_source_line_detail => NULL
	  ,x_lock_handle => l_demand_lock_handle
	  ,x_lock_status => l_lock_status);

       IF l_lock_status = 0 THEN
	  fnd_message.set_name('INV', 'INV_INVALID_LOCK');
	  fnd_msg_pub.ADD;
	  RAISE fnd_api.g_exc_error;
       END if;

       l_lock_obtained := TRUE;
    END IF;
    /*** End R12 ***/

    -- here we might add some validation of input parameters
    -- for update api, the reservation id should not be changed
    IF l_orig_rsv_tbl(1).reservation_id <> l_to_rsv_rec.reservation_id THEN
       IF (l_debug = 1) THEN
	  debug_print('Cannot update reservation ID');
       END IF;
       fnd_message.set_name('INV', 'CANNOT_UPDATE_RESERVATION_ID');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_orig_rsv_tbl(1).organization_id <> l_to_rsv_rec.organization_id THEN
       IF (l_debug = 1) THEN
	  debug_print('Cannot update organization ID');
       END IF;
       fnd_message.set_name('INV', 'CANNOT_UPDATE_ORGANIZATION_ID');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_orig_rsv_tbl(1).inventory_item_id <> l_to_rsv_rec.inventory_item_id THEN
       IF (l_debug = 1) THEN
	  debug_print('Cannot update Inventory Item ID');
       END IF;
       fnd_message.set_name('INV', 'CANNOT_UPDATE_INVENTORY_ITEM');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    --
    -- convert quantity between primary uom and reservation uom
    convert_quantity(x_return_status => l_return_status, px_rsv_rec => l_to_rsv_rec);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
    END IF;
    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    -- if the caller does not specified reservation_id, l_to_rsv_rec will
    -- has the same reservation_id as l_orig_rsv_tbl(1) due to the way
    -- construct_to_reservation_row works.
    -- but we should set it to g_miss_num again
    -- otherwise query_reservation will use only the
    -- reservation_id to do the search.
    IF l_to_rsv_rec.reservation_id = l_orig_rsv_tbl(1).reservation_id THEN
       l_to_rsv_rec.reservation_id  := fnd_api.g_miss_num;
    END IF;

    /**** {{ R12 Enhanced reservations code changes }}****/

    -- Set the original columns to g_miss_xxx as the user should not be
    -- setting these values. Do not query by them
    l_to_rsv_rec.orig_supply_source_type_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_supply_source_header_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_supply_source_line_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_supply_source_line_detail := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_demand_source_type_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_demand_source_header_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_demand_source_line_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_demand_source_line_detail := fnd_api.g_miss_num;

    IF (l_to_rsv_rec.project_id IS NULL)  THEN
       l_to_rsv_rec.project_id := fnd_api.g_miss_num;
    END IF;
    IF (l_to_rsv_rec.task_id IS NULL)  THEN
       l_to_rsv_rec.task_id := fnd_api.g_miss_num;
    END IF;
    /*** End R12 ***/

    IF (l_debug = 1) THEN
       debug_print('Querying reservatione for the to record');
    END IF;

    query_reservation
      (
       p_api_version_number           => 1.0
       , p_init_msg_lst               => fnd_api.g_false
       , x_return_status              => l_return_status
       , x_msg_count                  => x_msg_count
       , x_msg_data                   => x_msg_data
       , p_query_input                => l_to_rsv_rec
       , p_lock_records               => fnd_api.g_true
       , x_mtl_reservation_tbl        => l_to_rsv_tbl
       , x_mtl_reservation_tbl_count  => l_to_rsv_tbl_count
       , x_error_code                 => l_error_code
       );
    IF (l_debug = 1) THEN
       debug_print('Queried reservation');
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_error THEN
       IF (l_debug = 1) THEN
	  debug_print('Query Reservation returned error');
       END IF;
       RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       IF (l_debug = 1) THEN
	  debug_print('Query Reservation returned unexpected error');
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    IF l_to_rsv_tbl_count > 1
      OR l_to_rsv_tbl_count > 0
      AND l_to_rsv_tbl(1).reservation_id <> l_orig_rsv_tbl(1).reservation_id THEN
       IF (l_debug = 1) THEN
	  debug_print('Reservation target row exists');
       END IF;
       fnd_message.set_name('INV', 'INV-RSV TARGET ROW EXISTS');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    /**** {{ R12 Enhanced reservations code changes }}****/

    -- Get the project and task for demands in OE, INT-ORD and RMA
    IF l_debug=1 THEN
       debug_print('Before Rsv rec project id: ' || l_to_rsv_rec.project_id);
       debug_print('Before Rsv rec task id: ' || l_to_rsv_rec.task_id);
    END IF;

    BEGIN
       SELECT project_reference_enabled
	 INTO l_pjm_enabled
	 FROM   mtl_parameters
	 WHERE  organization_id = l_to_rsv_rec.organization_id;
    EXCEPTION
       WHEN no_data_found THEN
	  IF l_debug=1 THEN
	     debug_print('Cannot find the project and task information');
	  END IF;
    END;

    IF (l_to_rsv_rec.demand_source_type_id IN
	(inv_reservation_global.g_source_type_oe,
	 inv_reservation_global.g_source_type_internal_ord,
	 inv_reservation_global.g_source_type_rma)) AND
      (l_pjm_enabled = 1) THEN

       IF (l_to_rsv_rec.demand_source_line_id IS NOT NULL) AND
	 (l_to_rsv_rec.demand_source_line_id <> fnd_api.g_miss_num)
	 AND ((l_to_rsv_rec.project_id = fnd_api.g_miss_num) OR
	      (l_to_rsv_rec.task_id = fnd_api.g_miss_num)) THEN
	 BEGIN
	    SELECT project_id, task_id INTO l_project_id, l_task_id
	      FROM oe_order_lines_all WHERE
	      line_id = l_to_rsv_rec.demand_source_line_id;
	 EXCEPTION
	    WHEN no_data_found THEN
	       IF l_debug=1 THEN
		  debug_print('Cannot find the project and task information');
	       END IF;
	 END;

	 IF (l_to_rsv_rec.project_id = fnd_api.g_miss_num) THEN
	    IF (l_project_id IS NOT NULL) THEN
	       l_to_rsv_rec.project_id := l_project_id;
	     ELSE
	       l_to_rsv_rec.project_id := NULL;
	    END IF;
	 END IF;

	 IF (l_to_rsv_rec.task_id = fnd_api.g_miss_num) THEN
	    IF (l_task_id IS NOT NULL) THEN
	       l_to_rsv_rec.task_id := l_task_id;
	     ELSE
	       l_to_rsv_rec.task_id := NULL;
	    END IF;
	 END IF;

       END IF;
       /* Added elseif for CMRO bug 13829182 */
    ELSIF (  (l_to_rsv_rec.demand_source_type_id = inv_reservation_global.g_source_type_wip) AND (l_pjm_enabled = 1))  THEN
        BEGIN
                 SELECT we.entity_type, wdj.maintenance_object_source
                     INTO  l_wip_entity_id, l_maintenance_object_source
                   FROM wip_entities we, wip_discrete_jobs wdj
                WHERE we.wip_entity_id = l_to_rsv_rec.demand_source_header_id
                   AND we.wip_entity_id = wdj.wip_entity_id(+);
        EXCEPTION
            WHEN no_data_found THEN
                 IF (l_debug = 1) THEN
                    debug_print('No WIP entity record found for the source header passed' );
                 END IF;
        END;

        IF l_wip_entity_id = 6 and l_maintenance_object_source = 2  then
            l_wip_entity_type := inv_reservation_global.g_wip_source_type_cmro;
            l_wip_job_type := 'CMRO'; -- AHL
        ELSE
            l_wip_entity_type := null;
            l_wip_job_type := null; -- AHL
        END IF;

        IF ( l_wip_job_type = 'CMRO' AND l_to_rsv_rec.demand_source_line_detail IS NOT NULL)
            AND (l_to_rsv_rec.demand_source_line_detail <> fnd_api.g_miss_num)
            AND ((l_to_rsv_rec.project_id = fnd_api.g_miss_num) OR (l_to_rsv_rec.task_id = fnd_api.g_miss_num)) THEN

            BEGIN
                SELECT wdj.project_id, WDJ.TASK_ID
                    INTO l_project_id, l_task_id
                   FROM ahl_schedule_materials asmt, ahl_workorders aw, WIP_DISCRETE_JOBS WDJ
                WHERE asmt.scheduled_material_id = l_to_rsv_rec.demand_source_line_detail
                     AND asmt.visit_task_id           = aw.visit_task_id
                     AND ASMT.VISIT_ID                = AW.VISIT_ID
                     AND aw.wip_entity_id             = wdj.wip_entity_id
                     AND AW.STATUS_CODE              IN ('1','3') -- 1:Unreleased,3:Released
                     AND ASMT.STATUS                  = 'ACTIVE';

            EXCEPTION
                WHEN others THEN
                    IF l_debug=1 THEN
                        debug_print('Cannot find the project and task information from CMRO WO: '||sqlerrm);
                    END IF;
            END;


            IF (l_to_rsv_rec.project_id = fnd_api.g_miss_num) THEN
                IF (l_project_id IS NOT NULL ) THEN
                    l_to_rsv_rec.project_id := l_project_id;
                ELSE
                    l_to_rsv_rec.project_id := NULL;
                END IF;
            END IF;

            IF (l_to_rsv_rec.task_id = fnd_api.g_miss_num) THEN
                IF (l_task_id IS NOT NULL) THEN
                    l_to_rsv_rec.task_id := l_task_id;
                ELSE
                    l_to_rsv_rec.task_id := NULL;
                END IF;
            END IF;

        END IF;
        /* End of changes for CMRO bug 13829182 */
     ELSE -- not project enable
	  l_to_rsv_rec.project_id := NULL;
	  l_to_rsv_rec.task_id := NULL;
    END IF;
    IF l_debug=1 THEN
       debug_print('After Rsv rec project id: ' || l_to_rsv_rec.project_id);
       debug_print('After Rsv rec task id: ' || l_to_rsv_rec.task_id);
    END IF;

    l_original_serial_count := p_original_serial_number.COUNT;
    l_to_serial_count := p_to_serial_number.COUNT;
    -- if from and to serials are passed, then pass them to the validate API
    IF l_original_serial_count > 0 THEN
       l_original_serial_number := p_original_serial_number;
    END IF;
    IF l_to_serial_count > 0 THEN
       l_to_serial_number := p_to_serial_number;
    END IF;
    /*** End R12 ***/
    --
    --Bug 2354735: Validate if p_validation_flag is either 'T' or 'V'
    IF (p_validation_flag = fnd_api.g_true OR p_validation_flag = 'V') THEN
      IF (l_debug = 1) THEN
         debug_print('Validation flag is true');
         debug_print('from dmd src type:'|| l_orig_rsv_tbl(1).demand_source_type_id);
         debug_print('to dmd src type:'|| l_to_rsv_rec.demand_source_type_id);
         debug_print('from dmd src hdr:'|| l_orig_rsv_tbl(1).demand_source_header_id);
         debug_print('to dmd src hdr:'|| l_to_rsv_rec.demand_source_header_id);
         debug_print('from dmd src line:'|| l_orig_rsv_tbl(1).demand_source_line_id);
         debug_print('to dmd src line:'|| l_to_rsv_rec.demand_source_line_id);
      END IF;
      -- we do validation after the query because
      -- for update, we might have many input value set to
      -- missing. We need to use the actual value to do
      -- validation
      inv_reservation_validate_pvt.validate_input_parameters
	(
	 x_return_status              => l_return_status
	 , p_orig_rsv_rec               => l_orig_rsv_tbl(1)
	 , p_to_rsv_rec                 => l_to_rsv_rec
	 /**** {{ R12 Enhanced reservations code changes }}****/
	 , p_orig_serial_array          => l_original_serial_number
	 , p_to_serial_array            => l_to_serial_number
	 /*** End R12 ***/
	 , p_rsv_action_name            => 'UPDATE'
	 , x_orig_item_cache_index      => l_orig_item_cache_index
	 , x_orig_org_cache_index       => l_orig_org_cache_index
	 , x_orig_demand_cache_index    => l_orig_demand_cache_index
	 , x_orig_supply_cache_index    => l_orig_supply_cache_index
	 , x_orig_sub_cache_index       => l_orig_sub_cache_index
	 , x_to_item_cache_index        => l_to_item_cache_index
	 , x_to_org_cache_index         => l_to_org_cache_index
	 , x_to_demand_cache_index      => l_to_demand_cache_index
	 , x_to_supply_cache_index      => l_to_supply_cache_index
	 , x_to_sub_cache_index         => l_to_sub_cache_index
	 );

      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 IF (l_debug = 1) THEN
	    debug_print('Validate input parameters returned error');
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 IF (l_debug = 1) THEN
	    debug_print('Validate input parameters returned unexpected error');
	 END IF;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -- INVCONV B4498579 BEGIN
    -- Use cache to determine lot divisibility where possible
    IF NVL(l_to_item_cache_index,0) > 0 THEN
      IF NOT is_lot_divisible(l_to_item_cache_index) THEN
       l_lot_divisible_flag := 'N';
      END IF;
    ELSE
    -- otherwise, where cache not available
      IF NOT lot_divisible(l_orig_rsv_tbl(1).inventory_item_id,l_orig_rsv_tbl(1).organization_id) THEN
	l_lot_divisible_flag := 'N';
      END IF;
    END IF;
    IF (l_debug = 1) THEN
      debug_print('Update scenario and lot divisible is '||l_lot_divisible_flag);
    END IF;
    -- INVCONV B4498579 END

    --
    --Bug 2354735: Proceed with Trees only if p_validation_flag = 'T'

    -- Pick Releaser Performance - Added validation_flag = 'Q' to distinguish
    -- between validation above and the qty tree processing below.
     /**** {{ R12 Enhanced reservations code changes }}****/
    IF (((p_validation_flag = fnd_api.g_true) OR (p_validation_flag = 'T') OR
       (p_validation_flag = 'Q')) AND l_to_rsv_rec.supply_source_type_id = inv_reservation_global.g_source_type_inv)
      THEN
       /*** End R12 ***/

	-- changes for bug 9874238 start
       	IF (l_orig_item_cache_index is NULL) THEN
              inv_reservation_util_pvt.search_item_cache
                (
                  x_return_status      => l_return_status
                 ,p_inventory_item_id  => l_orig_rsv_tbl(1).inventory_item_id
                 ,p_organization_id    => l_orig_rsv_tbl(1).organization_id
                 ,x_index              => l_orig_item_cache_index
                 );

              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                 RAISE fnd_api.g_exc_error;
              End If;

              IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              IF (l_orig_item_cache_index IS NULL) THEN
                 OPEN c_item(l_orig_rsv_tbl(1).inventory_item_id,l_orig_rsv_tbl(1).organization_id);
                 FETCH c_item into l_item_rec;
                 CLOSE c_item;

                 inv_reservation_util_pvt.add_item_cache
                  (
                   x_return_status              => l_return_status
                  ,p_item_record                => l_item_rec
                  ,x_index                      => l_orig_item_cache_index
                  );

                 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                   RAISE fnd_api.g_exc_error;
                 END IF;

                 IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                   RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF;
           END IF;

	IF (l_debug = 1) THEN
      		debug_print('After adding item to the cache l_orig_item_cache_index: '||l_orig_item_cache_index);
    	END IF;
	-- changes for bug 9874238 end

       inv_quantity_tree_pvt.create_tree
	 (
	  p_api_version_number         => 1.0
	  , p_init_msg_lst               => fnd_api.g_true
	  , x_return_status              => l_return_status
	  , x_msg_count                  => x_msg_count
	  , x_msg_data                   => x_msg_data
	  , p_organization_id            => l_orig_rsv_tbl(1).organization_id
	  , p_inventory_item_id          => l_orig_rsv_tbl(1).inventory_item_id
	  , p_tree_mode                  => inv_quantity_tree_pvt.g_reservation_mode
	  , p_is_revision_control        => is_revision_control(l_orig_item_cache_index)
	  , p_is_lot_control             => is_lot_control(l_orig_item_cache_index)
	  , p_is_serial_control          => is_serial_control(l_orig_item_cache_index)
	  , p_asset_sub_only             => FALSE
	  , p_include_suggestion         => TRUE
	  , p_demand_source_type_id      => l_orig_rsv_tbl(1).demand_source_type_id
         , p_demand_source_header_id    => l_orig_rsv_tbl(1).demand_source_header_id
         , p_demand_source_line_id      => l_orig_rsv_tbl(1).demand_source_line_id
         , p_demand_source_name         => l_orig_rsv_tbl(1).demand_source_name
         , p_demand_source_delivery     => l_orig_rsv_tbl(1).demand_source_delivery
         , p_lot_expiration_date        => SYSDATE -- Bug#2716563
         , x_tree_id                    => l_tree_id1
         );

         --
         IF l_return_status = fnd_api.g_ret_sts_error THEN
           IF (l_debug = 1) THEN
              debug_print('Create Tree returned error');
           END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

         --
         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           IF (l_debug = 1) THEN
              debug_print('Create Tree returned unexpected error');
           END IF;
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;

          --
         /*  Bug 1575930
          *  Because of changes to the quantity tree API, we no longer
          *  build separate trees on the basis of demand info.  The tree created
          *  above and this tree would actually be the same tree, but would
          *  would have different tree_ids.  We don't need to update the same
          *  tree twice, so we don't need to create the same tree twice.
          *  Instead, pass NULL to the modify_tree procedure.
          *inv_quantity_tree_pvt.create_tree
          * (
          *   p_api_version_number      => 1.0
          * , p_init_msg_lst            => fnd_api.g_true
          * , x_return_status           => l_return_status
          * , x_msg_count               => x_msg_count
          * , x_msg_data                => x_msg_data
          * , p_organization_id         => l_to_rsv_rec.organization_id
          * , p_inventory_item_id       => l_to_rsv_rec.inventory_item_id
          * , p_tree_mode               => inv_quantity_tree_pvt.g_reservation_mode
          * , p_is_revision_control     => is_revision_control(l_to_item_cache_index)
          * , p_is_lot_control          => is_lot_control(l_to_item_cache_index)
          * , p_is_serial_control       => is_serial_control(l_to_item_cache_index)
          * , p_asset_sub_only          => FALSE
          * , p_include_suggestion      => TRUE
          * , p_demand_source_type_id   => l_to_rsv_rec.demand_source_type_id
          * , p_demand_source_header_id => l_to_rsv_rec.demand_source_header_id
          * , p_demand_source_line_id   => l_to_rsv_rec.demand_source_line_id
          * , p_demand_source_name      => l_to_rsv_rec.demand_source_name
          * , p_demand_source_delivery  => l_to_rsv_rec.demand_source_delivery
          * , p_lot_expiration_date     => NULL
          * , x_tree_id                 => l_tree_id2
          *);
          --
          *IF l_return_status = fnd_api.g_ret_sts_error THEN
          *   RAISE fnd_api.g_exc_error;
          *END IF ;
          --
          *IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          *   RAISE fnd_api.g_exc_unexpected_error;
          *END IF;
          */
          --
         l_tree_id2  := NULL;
         -- INVCONV - Upgrade call to incorporate secondaries
         modify_tree_for_update_xfer(
           x_return_status              => l_return_status
         , x_quantity_reserved          => l_quantity_reserved
         , x_secondary_quantity_reserved => l_secondary_quantity_reserved
         , p_from_tree_id               => l_tree_id1
         , p_from_supply_source_type_id => l_orig_rsv_tbl(1).supply_source_type_id
         , p_from_revision              => l_orig_rsv_tbl(1).revision
         , p_from_lot_number            => l_orig_rsv_tbl(1).lot_number
         , p_from_subinventory_code     => l_orig_rsv_tbl(1).subinventory_code
         , p_from_locator_id            => l_orig_rsv_tbl(1).locator_id
         , p_from_lpn_id                => l_orig_rsv_tbl(1).lpn_id
         , p_from_primary_rsv_quantity  => l_orig_rsv_tbl(1).primary_reservation_quantity
         , p_from_second_rsv_quantity   => l_orig_rsv_tbl(1).secondary_reservation_quantity
         , p_from_detailed_quantity     => l_orig_rsv_tbl(1).detailed_quantity
         , p_from_sec_detailed_quantity => l_orig_rsv_tbl(1).secondary_detailed_quantity
         , p_to_tree_id                 => l_tree_id2
         , p_to_supply_source_type_id   => l_to_rsv_rec.supply_source_type_id
         , p_to_revision                => l_to_rsv_rec.revision
         , p_to_lot_number              => l_to_rsv_rec.lot_number
         , p_to_subinventory_code       => l_to_rsv_rec.subinventory_code
         , p_to_locator_id              => l_to_rsv_rec.locator_id
         , p_to_lpn_id                  => l_to_rsv_rec.lpn_id
         , p_to_primary_rsv_quantity    => l_to_rsv_rec.primary_reservation_quantity
         , p_to_second_rsv_quantity     => l_to_rsv_rec.secondary_reservation_quantity
         , p_to_detailed_quantity       => l_to_rsv_rec.detailed_quantity
         , p_to_second_detailed_quantity => l_to_rsv_rec.secondary_detailed_quantity
         , p_to_revision_control        => is_revision_control(l_to_item_cache_index)
         , p_to_lot_control             => is_lot_control(l_to_item_cache_index)
         , p_action                     => 'UPDATE'
         , p_lot_divisible_flag         => l_lot_divisible_flag                          -- INVCONV
         , p_partial_reservation_flag   => p_partial_reservation_flag
         , p_check_availability         => p_check_availability
         );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
           IF (l_debug = 1) THEN
              debug_print('modify_tree_for_update_xfer returned error');
           END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

         --
         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           IF (l_debug = 1) THEN
              debug_print('modify_tree_for_update_xfer returned unexpected error');
           END IF;
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;


         IF (l_debug = 1) THEN
              debug_print('modify_tree_for_update_xfer returned success ');
              debug_print('The value for x_quantity_reserved is'||l_quantity_reserved );
              debug_print('The value for x_secondary_quantity_reserved is'||l_secondary_quantity_reserved ); --INVCONV
	 END IF;

	 IF  l_quantity_reserved > 0
	   AND l_quantity_reserved < l_to_rsv_rec.primary_reservation_quantity - NVL(l_to_rsv_rec.detailed_quantity, 0) THEN
	    -- This is the case of partial reservations. We  need to recompute
	    -- the actual quantity for reservation
	    -- convert quantity between primary uom and reservation uom
	    l_to_rsv_rec.primary_reservation_quantity  := l_quantity_reserved + NVL(l_to_rsv_rec.detailed_quantity, 0);
	    -- INVCONV BEGIN
	    IF is_dual_control(l_orig_item_cache_index) THEN
	       l_dual_control_flag := 'Y';
	       l_to_rsv_rec.secondary_reservation_quantity  := l_secondary_quantity_reserved + NVL(l_to_rsv_rec.secondary_detailed_quantity, 0); -- Bug 6942475
	    END IF;
	    -- INVCONV END
	    l_to_rsv_rec.reservation_quantity          := NULL;

	    IF (l_debug = 1) THEN
	       debug_print('l_to_rsv_rec.detailed_quantity: ' || l_to_rsv_rec.detailed_quantity);
	       debug_print('l_to_rsv_rec.primary_reservation_quantity: ' || l_to_rsv_rec.primary_reservation_quantity);
	       debug_print('l_to_rsv_rec.secondary_reservation_quantity: ' || l_to_rsv_rec.secondary_reservation_quantity); -- INVCONV
	    END IF;

	    convert_quantity(x_return_status => l_return_status, px_rsv_rec => l_to_rsv_rec);


	    IF (l_debug = 1) THEN
	       debug_print('After convert qty ' || l_return_status);
	    END IF;

	    IF l_return_status = fnd_api.g_ret_sts_error THEN
	       IF (l_debug = 1) THEN
		  debug_print('The convert_quantity returned a expected error');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	       IF (l_debug = 1) THEN
		  debug_print('The convert_quantity returned a unexpected error');
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	 END IF;--partial reservation case


 /**** {{ R12 Enhanced reservations code changes }}****/
     ELSIF (l_to_rsv_rec.supply_source_type_id IN
	    (inv_reservation_global.g_source_type_wip, inv_reservation_global.g_source_type_po,
	     inv_reservation_global.g_source_type_asn,
	     inv_reservation_global.g_source_type_intransit,
	     inv_reservation_global.g_source_type_internal_req,
	     inv_reservation_global.g_source_type_rcv))  AND
       p_over_reservation_flag NOT IN (1,3) THEN
       -- call the helper procedure to get the reservable qty of the supply
       -- Bug 5199672: Should pass g_miss_num as default for supply
       -- source line detail. Otherwise, high level reservations
       -- will not be considered.
       get_supply_reservable_qty
	 (
       	    x_return_status                 => l_return_status
	  , x_msg_count                     => x_msg_count
	  , x_msg_data                      => x_msg_data
          , p_fm_supply_source_type_id      => l_orig_rsv_tbl(1).supply_source_type_id
          , p_fm_supply_source_header_id    => l_orig_rsv_tbl(1).supply_source_header_id
          , p_fm_supply_source_line_id      => l_orig_rsv_tbl(1).supply_source_line_id
          , p_fm_supply_source_line_detail  => l_orig_rsv_tbl(1).supply_source_line_detail
          , p_fm_primary_reservation_qty    => l_orig_rsv_tbl(1).primary_reservation_quantity
          , p_to_supply_source_type_id      => l_to_rsv_rec.supply_source_type_id
          , p_to_supply_source_header_id    => l_to_rsv_rec.supply_source_header_id
          , p_to_supply_source_line_id      => l_to_rsv_rec.supply_source_line_id
          , p_to_supply_source_line_detail  => l_to_rsv_rec.supply_source_line_detail
          , p_to_primary_reservation_qty    => l_to_rsv_rec.primary_reservation_quantity
          , p_to_organization_id            => l_to_rsv_rec.organization_id
          , p_to_inventory_item_id          => l_to_rsv_rec.inventory_item_id
          , p_to_revision                   => l_to_rsv_rec.revision
          , p_to_lot_number                 => l_to_rsv_rec.lot_number
          , p_to_subinventory_code          => l_to_rsv_rec.subinventory_code
          , p_to_locator_id                 => l_to_rsv_rec.locator_id
          , p_to_lpn_id                     => l_to_rsv_rec.lpn_id
          , p_to_project_id                 => l_to_rsv_rec.project_id
          , p_to_task_id                    => l_to_rsv_rec.task_id
	 , x_reservable_qty                 => l_quantity_reserved
	 , x_qty_available                  => l_qty_available
	 );

       IF (l_debug = 1) THEN
	  debug_print('After calling get supply reservable qty ' || l_return_status);
	  debug_print('Available quantity to reserve:  ' || l_quantity_reserved);
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;


       IF ((l_to_rsv_rec.primary_reservation_quantity - l_quantity_reserved)
	 > 0.000005) THEN

          IF (p_partial_reservation_flag = fnd_api.g_false) THEN
             IF (l_debug = 1) THEN
                debug_print('The supply document doesnt have enough quantity to be reserved against. error out. ');
             END IF;
             fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
          ELSE
             l_to_rsv_rec.primary_reservation_quantity  := l_quantity_reserved;
             l_to_rsv_rec.reservation_quantity          := NULL;
             IF (l_debug = 1) THEN
                debug_print('l_to_rsv_rec.primary_reservation_quantity: ' || l_to_rsv_rec.primary_reservation_quantity);
             END IF;
             convert_quantity(x_return_status => l_return_status, px_rsv_rec => l_to_rsv_rec);

             IF (l_debug = 1) THEN
                debug_print('After convert qty ' || l_return_status);
             END IF;

             IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             END IF;

             --
             IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;

          END IF;

       END IF;

    END IF;

    IF (l_debug = 1) THEN
       debug_print('From record:');
       debug_print('demand_source_type_id = ' || l_orig_rsv_tbl(1).demand_source_type_id);
       debug_print('demand_source_header_id = ' || l_orig_rsv_tbl(1).demand_source_header_id);
       debug_print('demand_source_line_id = ' || l_orig_rsv_tbl(1).demand_source_line_id);
       debug_print('demand_source_line_detail = ' || l_orig_rsv_tbl(1).demand_source_line_detail);
       debug_print('To record:');
       debug_print('demand_source_type_id = ' || l_to_rsv_rec.demand_source_type_id);
       debug_print('demand_source_header_id = ' || l_to_rsv_rec.demand_source_header_id);
       debug_print('demand_source_line_id = ' || l_to_rsv_rec.demand_source_line_id);
       debug_print('demand_source_line_detail = ' || l_to_rsv_rec.demand_source_line_detail);
    END IF;

    IF (l_to_rsv_rec.demand_source_type_id IN
	(inv_reservation_global.g_source_type_oe,
	 inv_reservation_global.g_source_type_internal_ord,inv_reservation_global.g_source_type_rma)) THEN
      BEGIN
	 SELECT open_flag, booked_flag
	   INTO l_open_flag,
	   l_booked_flag
	   FROM oe_order_lines_all
	   WHERE line_id = l_to_rsv_rec.demand_source_line_id;
      EXCEPTION WHEN no_data_found THEN
      fnd_message.set_name('INV', 'INV_INVALID_SALES_ORDER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
      END;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('Open flag :' || l_open_flag);
       debug_print('booked flag :' || l_booked_flag);
    END IF;

    IF (((l_to_rsv_rec.demand_source_type_id IN
	 (inv_reservation_global.g_source_type_oe,
	  inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma)) AND

	(NOT((Nvl(l_orig_rsv_tbl(1).demand_source_type_id,-99) = Nvl(l_to_rsv_rec.demand_source_type_id,-99)) AND
	 (Nvl(l_orig_rsv_tbl(1).demand_source_header_id,-99) = Nvl(l_to_rsv_rec.demand_source_header_id,-99)) AND
	 (Nvl(l_orig_rsv_tbl(1).demand_source_line_id,-99) = Nvl(l_to_rsv_rec.demand_source_line_id,-99)) AND
	  nvl(l_open_flag, 'N') = 'N'))) OR
      (l_to_rsv_rec.demand_source_type_id =
       inv_reservation_global.g_source_type_wip)) AND
       p_over_reservation_flag NOT IN (2,3)  THEN

       -- call the helper procedure to get the reservable qty of the demand
       IF (l_debug = 1) THEN
	     debug_print('Inside get demand reservable qty');
       END IF;
      Inv_Utilities.Get_Inv_Fulfillment_Base(
                    p_source_line_id		      => l_to_rsv_rec.demand_source_line_id,
		    p_demand_source_type_id	=> l_to_rsv_rec.demand_source_type_id,
		    p_org_id		              => l_to_rsv_rec.organization_id,
                   x_fulfillment_base		    => l_fulfill_base	);

      IF (l_fulfill_base = 'S') THEN
      l_org_sec_rsv_qty :=l_orig_rsv_tbl(1).secondary_reservation_quantity;  -- MUOM fulfillment Project
      ELSE
      l_org_sec_rsv_qty:=null;
      END IF;
      --
      IF (l_debug = 1) THEN
         debug_print( ' orginal_secondary_reservation_quantity'||l_orig_rsv_tbl(1).secondary_reservation_quantity);
      END IF;
       --
       -- Bug 5199672: Should pass g_miss_num as default for demand
       -- source line detail. Otherwise, high level reservations
       -- will not be considered.
       get_demand_reservable_qty
	 (
	  x_return_status                 => l_return_status
	  , x_msg_count                     => x_msg_count
	  , x_msg_data                      => x_msg_data
          , p_fm_demand_source_type_id      => l_orig_rsv_tbl(1).demand_source_type_id
          , p_fm_demand_source_header_id    => l_orig_rsv_tbl(1).demand_source_header_id
          , p_fm_demand_source_line_id      => l_orig_rsv_tbl(1).demand_source_line_id
          , p_fm_demand_source_line_detail  => l_orig_rsv_tbl(1).demand_source_line_detail
          , p_fm_primary_reservation_qty    => l_orig_rsv_tbl(1).primary_reservation_quantity
	   , p_fm_secondary_reservation_qty  => l_org_sec_rsv_qty -- MUOM fulfillment Project
          , p_to_demand_source_type_id      => l_to_rsv_rec.demand_source_type_id
          , p_to_demand_source_header_id    => l_to_rsv_rec.demand_source_header_id
          , p_to_demand_source_line_id      => l_to_rsv_rec.demand_source_line_id
          , p_to_demand_source_line_detail  => l_to_rsv_rec.demand_source_line_detail
          , p_to_primary_reservation_qty    => l_to_rsv_rec.primary_reservation_quantity
	 , p_to_organization_id            => l_to_rsv_rec.organization_id
	 , p_to_inventory_item_id          => l_to_rsv_rec.inventory_item_id
	 , p_to_primary_uom_code           => l_to_rsv_rec.primary_uom_code
	 , p_to_project_id                 => l_to_rsv_rec.project_id
	 , p_to_task_id                    => l_to_rsv_rec.task_id
         /*Fixed for bug#8402349
           Variable l_reservable_qty is used because variable l_quantity_reserved hold the
           qty that is reserved and using that in this call will override it's value by
           reservable qty on demand. result in wrong value returned for qty reserved.
         */
	 /*, x_reservable_qty              =>  l_quantity_reserved */
          , x_reservable_qty               =>  l_reservable_qty
	 , x_qty_available                 => l_qty_available
	 , x_reservable_qty2               =>  l_reservable_qty2
         , x_qty_available2                 => l_qty_available2
	 );


       IF (l_debug = 1) THEN
	  debug_print('After calling available demand to reserve ' || l_return_status);
	  debug_print('Available quantity to reserve. l_qty_changed: ' || l_quantity_reserved);
          debug_print('Available quantity to reserve. l_reservable_qty: ' || l_reservable_qty);
          debug_print('Available quantity to reserve. l_reservable_qty2: ' || l_reservable_qty2);
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

        /*Fixed for bug#8402349
           Variable l_reservable_qty is used rather than variable l_quantity_reserved because
           variable l_reservable_qty is used now in call to API get_demand_reservable_qty
         */

           --Bug 12978409 : start
           -- Bug 5199672: Removed the condition l_qty_changed > 0
          /*  IF ((l_to_rsv_rec.primary_reservation_quantity -
                    l_reservable_qty) > 0.000005) THEN*/
              get_reservation_qty_lot( p_rsv_rec    => l_to_rsv_rec,
                                                   p_reservation_qty_lot  => l_reservation_qty_lot);
       -- MUOM fulfillment Project
       inv_utilities.get_inv_fulfillment_base(
                                     p_source_line_id	 => l_to_rsv_rec.demand_source_line_id,
			             p_demand_source_type_id => l_to_rsv_rec.demand_source_type_id,
			             p_org_id  => l_to_rsv_rec.organization_id,
                                     x_fulfillment_base => l_fulfill_base);

      IF (l_fulfill_base = 'S') THEN

        IF((l_reservation_qty_lot-l_reservable_qty2)>0.000005) THEN
          IF (l_debug = 1) Then
            debug_print('The demand document doesnt have enough quantity to be reserved against. error out. for fulfilment base=S ');
             debug_print('l_reservable_qty2:= '||l_reservable_qty2);
             debug_print('l_reservation_qty_lot:= '||l_reservation_qty_lot);
          END IF;
          fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        END IF;
      ELSE
        IF ((l_reservation_qty_lot - l_reservable_qty) > 0.000005) THEN
          IF (l_debug = 1) THEN
            debug_print('The demand document doesnt have enough quantity to be reserved against. error out. ');
            debug_print('l_to_rsv_rec.primary_reservation_quantity: ' || l_to_rsv_rec.primary_reservation_quantity);
          END IF;
          fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        END IF;
      END IF;
      -- MUOM fulfillment Project ends
    END IF;

    /*** End R12 ***/

    --
    -- Pre Update CTO Validation
    IF l_to_rsv_rec.demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
       --
       IF (l_debug = 1) THEN
          debug_print('Pre Update CTO validation');
       END IF;

       IF l_orig_rsv_tbl(1).primary_reservation_quantity > l_to_rsv_rec.primary_reservation_quantity THEN
	  cto_workflow_api_pk.inventory_unreservation_check
	    (
	     p_order_line_id              => l_orig_rsv_tbl(1).demand_source_line_id
	     , p_rsv_quantity               => l_orig_rsv_tbl(1).primary_reservation_quantity - l_to_rsv_rec.primary_reservation_quantity
	     , x_return_status              => l_return_status
	     , x_msg_count                  => x_msg_count
	     , x_msg_data                   => x_msg_data
	     );

	ELSE  --Else Condition Added for Bug#2467387.
	  cto_workflow_api_pk.inventory_reservation_check
	    (
	     p_order_line_id => l_orig_rsv_tbl(1).demand_source_line_id
	     ,x_return_status => l_return_status
	     ,x_msg_count => x_msg_count
	     ,x_msg_data => x_msg_data
	     );
       END IF;
       --
       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  debug_print('Pre Update CTO validation returned error');
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  debug_print('Pre Update CTO validation returned unexpected error');
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;
       --
    END IF;

    --Bug 1838450.  Detailed quantity should never exceed primary
    --  reservation quantity.  So, if someone has reduced the
    --  reservation quantity, we should reduce the detailed quantity also

    IF l_to_rsv_rec.detailed_quantity > l_to_rsv_rec.primary_reservation_quantity THEN
       IF (l_debug = 1) THEN
	  debug_print('Setting detailed quantity the same as the primary reservation quantity');
       END IF;
       l_to_rsv_rec.detailed_quantity  := l_to_rsv_rec.primary_reservation_quantity;
       -- INVCONV BEGIN
       IF l_dual_control_flag = 'Y' THEN
	  l_to_rsv_rec.secondary_detailed_quantity  := l_to_rsv_rec.secondary_reservation_quantity;
       END IF;
       -- INVCONV END
    END IF;

    --Bug #2819700
    --Adding an extra check to make sure that the update reservations does
    --not update the existing record to negative. Raise an exception.
    -- Adding this check after the tree is created and
    -- modify_tree_for_update_xfer is called and some computations
    -- have been made.
    IF (l_debug = 1) THEN
      debug_print('Primary_reservation_qty before inserting (update)= '
		              || To_char(l_to_rsv_rec.primary_reservation_quantity));
      debug_print('Secondary_reservation_qty before inserting (update)= '
                              || To_char(l_to_rsv_rec.secondary_reservation_quantity));
      debug_print('Reservation_qty before inserting (update)= '
		              || To_char(l_to_rsv_rec.reservation_quantity)); -- INVCONV
    END IF;

    IF (  (NVL(l_to_rsv_rec.reservation_quantity,0) < 0) OR
	        (NVL(l_to_rsv_rec.primary_reservation_quantity,0) < 0) ) THEN
      fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

     -- INVCONV BEGIN
    IF (NVL(l_to_rsv_rec.secondary_reservation_quantity,0) < 0) THEN
      fnd_message.set_name('INV', 'INV-INVALID NEGATIVE SECONDARY');   -- INVCONV New Message
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    -- INVCONV END

    /**** {{ R12 Enhanced reservations code changes }}****/
    -- Check for the serial reservations. All serial related checks will be
    -- done here.
    IF (l_debug = 1) THEN
       debug_print('Original serial count' || l_original_serial_count);
       debug_print('To serial count' || l_to_serial_count);
    END IF;

    IF (l_original_serial_count = 0 AND l_to_serial_count = 0) THEN
       -- both from and to serial tables are empty. They are not passed.
       IF (l_debug = 1) THEN
	  debug_print('Inside serial check. Not passed');
       END IF;
       BEGIN
	  SELECT inventory_item_id, serial_number bulk collect INTO
	    l_serial_number_table FROM
	    mtl_serial_numbers  WHERE reservation_id =
	   l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
	    l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
       EXCEPTION
	  WHEN no_data_found THEN
	     IF l_debug=1 THEN
		debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
	     END IF;
       END;

       l_total_serials_reserved := l_serial_number_table.COUNT;
       IF l_debug=1 THEN
		debug_print('Total reserved serials: ' || l_total_serials_reserved);
       END IF;

       IF (l_total_serials_reserved > 0) THEN
	  -- call validate serials for the to record.
	  inv_reservation_validate_pvt.validate_serials
	    (
	     x_return_status              => l_return_status
	     , p_rsv_action_name          => 'UPDATE'
	     , p_orig_rsv_rec             => l_dummy_rsv_rec
	     , p_to_rsv_rec               => l_to_rsv_rec
	     , p_orig_serial_array        => l_dummy_serial_array
	     , p_to_serial_array          => l_serial_number_table
	     );

	  IF (l_debug = 1) THEN
	     debug_print('After calling validate serials ' || l_return_status);
	  END IF;

	  --
	  IF l_return_status = fnd_api.g_ret_sts_error THEN
	     RAISE fnd_api.g_exc_error;
	  END IF;


	  --
	  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	     RAISE fnd_api.g_exc_unexpected_error;
	  END IF;

	  -- there are some serial reserved. Check if the number of serials
	  -- exceed the reservation quantity.
	  IF (l_total_serials_reserved > l_to_rsv_rec.primary_reservation_quantity) THEN
	     -- we have to unreserve some of the serials
	     -- unreserve the extra serials that are more than the primary_reservation_quantity
	     IF (l_debug = 1) THEN
		debug_print('Total serials more than reservation quantity.');
	     END IF;

	     l_serials_tobe_unreserved := l_total_serials_reserved - l_to_rsv_rec.primary_reservation_quantity;

	     FOR i IN 1..l_serials_tobe_unreserved
	       LOOP
	         BEGIN
		    UPDATE mtl_serial_numbers SET reservation_id = NULL,
		      group_mark_id = NULL, line_mark_id = NULL,
		      lot_line_mark_id = NULL WHERE
		      serial_number = l_serial_number_table(i).serial_number AND
		      current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		      inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
		 EXCEPTION
		    WHEN no_data_found THEN
		       IF l_debug=1 THEN
			  debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		       END IF;
		       fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		       fnd_msg_pub.ADD;
		       RAISE fnd_api.g_exc_error;
		 END;
		 IF l_debug=1 THEN
		    debug_print('Serial being unreserved. serial number: ' || l_serial_number_table(i).serial_number);
		 END IF;
	       END LOOP;
	       -- update the serial reservation quantity to be the primary
	       -- reservation quantity, as it is in excess.
	       l_to_rsv_rec.serial_reservation_quantity := l_to_rsv_rec.primary_reservation_quantity;

	   ELSE
	       -- we will have to migrate the serials to the new reservation
	       -- Since it is the same record we are working on. We dont have to
	       -- do anything. Just make sure that the group_mark_id and the
		       -- reservation id are populated.

	       FOR l_serial_index IN l_serial_number_table.first..l_serial_number_table.last
		 LOOP
		    IF l_debug=1 THEN
		     debug_print('Inside serials not more than res qty');
		     debug_print('reservation id' ||
				 l_orig_rsv_tbl(1).reservation_id);
		     debug_print('serial being processed' ||
				 l_serial_number_table(l_serial_index).serial_number);
		     debug_print('org' ||
				 l_orig_rsv_tbl(1).organization_id);
		      debug_print('item' ||
				 l_orig_rsv_tbl(1).inventory_item_id);
		 END IF;
	           BEGIN
		      UPDATE mtl_serial_numbers SET reservation_id = l_orig_rsv_tbl(1).reservation_id,
			group_mark_id = l_orig_rsv_tbl(1).reservation_id WHERE
			serial_number = l_serial_number_table(l_serial_index).serial_number
			AND current_organization_id = l_orig_rsv_tbl(1).organization_id
			AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
		   EXCEPTION

		      WHEN no_data_found THEN
			 IF l_debug=1 THEN
			    debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
			 END IF;
			 fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
			 fnd_msg_pub.ADD;
			 RAISE fnd_api.g_exc_error;
		   END;
		   IF l_debug=1 THEN
		      debug_print('Serial being migrated. serial number: ' || l_serial_number_table(l_serial_index).serial_number);
		   END IF;
		 END LOOP;
		 -- update the serial reservation quantity
		 l_to_rsv_rec.serial_reservation_quantity := l_total_serials_reserved;

	  END IF;
       END IF;

     ELSIF (l_original_serial_count > 0 OR l_to_serial_count > 0) THEN

       -- One of them is passed.
       -- From record is already validated. There are some extra
       -- validations that needs to happen for the to record.

       IF (l_to_serial_count > 0) THEN
	  -- The serial has bo be either reserved to the from record or
	  -- not reserved at all.
	  FOR i IN p_to_serial_number.first..p_to_serial_number.last
	    LOOP
	      BEGIN
		 SELECT reservation_id, group_mark_id INTO
		   l_reservation_id,l_group_mark_id
		   FROM mtl_serial_numbers WHERE
		   serial_number = p_to_serial_number(i).serial_number AND
		   current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		   inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for this data : ' ||
				   p_to_serial_number(i).serial_number);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_TO_SERIAL');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;

	      IF (l_reservation_id IS NOT NULL AND l_reservation_id <>
		  l_orig_rsv_tbl(1).reservation_id) THEN
		 fnd_message.set_name('INV', 'INV_INVALID_TO_SERIAL');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      -- If the serial is not reserved then it should not have the
	      -- group mark id stamped. It means it is being used by
	      -- another transaction and cant be reserved.
	      IF (l_reservation_id IS NULL) AND (l_group_mark_id IS NOT NULL) AND
		  (l_group_mark_id <> -1)THEN
		 IF (l_debug = 1) THEN
		    debug_print('Group Mark Id is not null for serial ' || p_to_serial_number(i).serial_number);
		 END IF;
		 fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	    END LOOP;

       END IF;

       -- unreserve the from and reserve the to and make sure that the
       -- total doesnt exceed the primary reservation quantity.
       IF (l_original_serial_count > 0) THEN
	  FOR i IN
	    p_original_serial_number.first..p_original_serial_number.last
	    LOOP
	      BEGIN
		 UPDATE mtl_serial_numbers SET reservation_id = NULL,
		   group_mark_id = NULL, line_mark_id = NULL,
		      lot_line_mark_id = NULL  WHERE
		   serial_number = p_original_serial_number(i).serial_number AND
		   current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		   inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;
	    END LOOP;
       END IF;

       IF (l_to_serial_count > 0) THEN
	  FOR i IN p_to_serial_number.first..p_to_serial_number.last
	    LOOP
	       IF (l_debug = 1) THEN
		  debug_print('reservation id' ||
			      l_orig_rsv_tbl(1).reservation_id);
		  debug_print('serial number' ||
			      p_to_serial_number(i).serial_number);
		  debug_print('organization_id' ||
			      l_orig_rsv_tbl(1).organization_id);
		  debug_print('inventory_item_id = ' || l_orig_rsv_tbl(1).inventory_item_id);
	       END IF;
	      BEGIN
		 UPDATE mtl_serial_numbers SET reservation_id = l_orig_rsv_tbl(1).reservation_id,
		   group_mark_id = l_orig_rsv_tbl(1).reservation_id WHERE
		   serial_number = p_to_serial_number(i).serial_number AND
		   current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		   inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation
				   record. serial number: ' ||  p_to_serial_number(i).serial_number);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;
	    END LOOP;
       END IF;

	IF (l_debug = 1) THEN
				   debug_print('reservation id' ||
					       l_orig_rsv_tbl(1).reservation_id);
				   debug_print('organization_id' ||
					       l_orig_rsv_tbl(1).organization_id);
				   debug_print('inventory_item_id = ' || l_orig_rsv_tbl(1).inventory_item_id);
				   END IF;
	BEGIN
	  SELECT COUNT(1) INTO l_total_serials_reserved FROM
	    mtl_serial_numbers  WHERE reservation_id =
	    l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
	    l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
       EXCEPTION
	  WHEN no_data_found THEN
	     IF l_debug=1 THEN
		debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
	     END IF;
       END;
     IF (l_debug = 1) THEN
	debug_print('After counting serials' || l_total_serials_reserved);
	debug_print('Total reservation qty' || l_to_rsv_rec.primary_reservation_quantity);
     END IF;

       l_to_rsv_rec.serial_reservation_quantity := l_total_serials_reserved;

       IF (l_total_serials_reserved > l_to_rsv_rec.primary_reservation_quantity) THEN
	  -- we have to unreserve some of the serials
	  -- unreserve the extra serials that are more than the primary_reservation_quantity
	  IF (l_debug = 1) THEN
	     debug_print('Inside relieving serials');
	  END IF;

          BEGIN
	     SELECT inventory_item_id, serial_number bulk collect INTO
	       l_serial_number_table FROM
	       mtl_serial_numbers  WHERE reservation_id =
	       l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
	       l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	  EXCEPTION
	     WHEN no_data_found THEN
		IF l_debug=1 THEN
		   debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		END IF;
	  END;
	  l_serials_tobe_unreserved := l_total_serials_reserved - l_to_rsv_rec.primary_reservation_quantity;

	  FOR i IN 1..l_serials_tobe_unreserved
	    LOOP
	       IF (l_debug = 1) THEN
		  debug_print('Serial being unreserved' || l_serial_number_table(i).serial_number);
	       END IF;
	       BEGIN
		  UPDATE mtl_serial_numbers SET reservation_id = NULL,
		    group_mark_id = NULL, line_mark_id = NULL,
		      lot_line_mark_id = NULL WHERE
		    serial_number = l_serial_number_table(i).serial_number AND
		    current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		    inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	       EXCEPTION
		  WHEN no_data_found THEN
		     IF l_debug=1 THEN
			debug_print('Inside relieve serials.No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		     END IF;
		     fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		     fnd_msg_pub.ADD;
		     RAISE fnd_api.g_exc_error;
	       END;
	    END LOOP;
	    -- update the serial reservation quantity to be the primary
	    -- reservation quantity, as it is in excess.
	    l_to_rsv_rec.serial_reservation_quantity := l_to_rsv_rec.primary_reservation_quantity;
       END IF;

    END IF;
    /*** End R12  ***/

    -- obtain program and user info
    l_date := SYSDATE;

    --
    l_user_id        := fnd_global.user_id;
    l_login_id       := fnd_global.login_id;

    IF l_login_id = -1 THEN
      l_login_id  := fnd_global.conc_login_id;
    END IF;

    l_request_id     := fnd_global.conc_request_id;
    l_prog_appl_id   := fnd_global.prog_appl_id;
    l_program_id     := fnd_global.conc_program_id;
    --
    -- update the table
    IF (l_debug = 1) THEN
       debug_print('Calling mtl_reservations_pkg.update_row');
    END IF;

    -- Bug 3461990: Reservations API should not update reservations with more
    -- than 5 decimal places, since the transaction quantity is being
    -- rounded to 5 decimal places.

    l_to_rsv_rec.primary_reservation_quantity :=
      round(l_to_rsv_rec.primary_reservation_quantity,5);
    l_to_rsv_rec.reservation_quantity :=
      round(l_to_rsv_rec.reservation_quantity,5);
    l_to_rsv_rec.detailed_quantity :=
      round(Nvl(l_to_rsv_rec.detailed_quantity,0),5);

     -- INVCONV BEGIN
    IF l_dual_control_flag = 'Y' THEN
      l_to_rsv_rec.secondary_reservation_quantity :=
        round(l_to_rsv_rec.secondary_reservation_quantity,5);
      l_to_rsv_rec.secondary_detailed_quantity :=
        round(Nvl(l_to_rsv_rec.secondary_detailed_quantity,0),5);
    END IF;
    -- INVCONV END

    IF (l_debug = 1) THEN
       debug_print(' Update: Before updating record');
       debug_print(' After rounding reservation is' || l_orig_rsv_tbl(1).reservation_id);
       debug_print(' After rounding reservation qty' || l_to_rsv_rec.reservation_quantity);
       debug_print(' After rounding reservation pri qty' || l_to_rsv_rec.primary_reservation_quantity);
       debug_print(' After rounding reservation sec qty' || l_to_rsv_rec.secondary_reservation_quantity); -- INVCONV
       debug_print(' After rounding detailed quantity' || l_to_rsv_rec.detailed_quantity);
       debug_print(' After rounding sec detailed quantity' || l_to_rsv_rec.secondary_detailed_quantity); --INVCONV
    END IF;

    -- INVCONV - Upgrade to incorporate secondaries
    mtl_reservations_pkg.update_row
      (
       x_reservation_id             => l_orig_rsv_tbl(1).reservation_id
       , x_requirement_date           => l_to_rsv_rec.requirement_date
       , x_organization_id            => l_to_rsv_rec.organization_id
       , x_inventory_item_id          => l_to_rsv_rec.inventory_item_id
       , x_demand_source_type_id      => l_to_rsv_rec.demand_source_type_id
       , x_demand_source_name         => l_to_rsv_rec.demand_source_name
       , x_demand_source_header_id    => l_to_rsv_rec.demand_source_header_id
       , x_demand_source_line_id      => l_to_rsv_rec.demand_source_line_id
       , x_demand_source_delivery     => l_to_rsv_rec.demand_source_delivery
       , x_primary_uom_code           => l_to_rsv_rec.primary_uom_code
       , x_primary_uom_id             => l_to_rsv_rec.primary_uom_id
       , x_secondary_uom_code         => l_to_rsv_rec.secondary_uom_code
       , x_secondary_uom_id           => l_to_rsv_rec.secondary_uom_id
       , x_reservation_uom_code       => l_to_rsv_rec.reservation_uom_code
      , x_reservation_uom_id         => l_to_rsv_rec.reservation_uom_id
      , x_reservation_quantity       => l_to_rsv_rec.reservation_quantity
      , x_primary_reservation_quantity=> l_to_rsv_rec.primary_reservation_quantity
      , x_second_reservation_quantity=> l_to_rsv_rec.secondary_reservation_quantity
      , x_detailed_quantity          => l_to_rsv_rec.detailed_quantity
      , x_secondary_detailed_quantity=> l_to_rsv_rec.secondary_detailed_quantity
      , x_autodetail_group_id        => l_to_rsv_rec.autodetail_group_id
      , x_external_source_code       => l_to_rsv_rec.external_source_code
      , x_external_source_line_id    => l_to_rsv_rec.external_source_line_id
      , x_supply_source_type_id      => l_to_rsv_rec.supply_source_type_id
      , x_supply_source_header_id    => l_to_rsv_rec.supply_source_header_id
      , x_supply_source_line_id      => l_to_rsv_rec.supply_source_line_id
      , x_supply_source_line_detail  => l_to_rsv_rec.supply_source_line_detail
      , x_supply_source_name         => l_to_rsv_rec.supply_source_name
      , x_revision                   => l_to_rsv_rec.revision
      , x_subinventory_code          => l_to_rsv_rec.subinventory_code
      , x_subinventory_id            => l_to_rsv_rec.subinventory_id
      , x_locator_id                 => l_to_rsv_rec.locator_id
      , x_lot_number                 => l_to_rsv_rec.lot_number
      , x_lot_number_id              => l_to_rsv_rec.lot_number_id
      , x_serial_number              => NULL
      , x_serial_number_id           => NULL
      , x_partial_quantities_allowed => NULL
      , x_auto_detailed              => NULL
      , x_pick_slip_number           => l_to_rsv_rec.pick_slip_number
      , x_lpn_id                     => l_to_rsv_rec.lpn_id
      , x_last_update_date           => l_date
      , x_last_updated_by            => l_user_id
      , x_last_update_login          => l_login_id
      , x_request_id                 => l_request_id
      , x_program_application_id     => l_prog_appl_id
      , x_program_id                 => l_program_id
      , x_program_update_date        => l_date
      , x_attribute_category         => l_to_rsv_rec.attribute_category
      , x_attribute1                 => l_to_rsv_rec.attribute1
      , x_attribute2                 => l_to_rsv_rec.attribute2
      , x_attribute3                 => l_to_rsv_rec.attribute3
      , x_attribute4                 => l_to_rsv_rec.attribute4
      , x_attribute5                 => l_to_rsv_rec.attribute5
      , x_attribute6                 => l_to_rsv_rec.attribute6
      , x_attribute7                 => l_to_rsv_rec.attribute7
      , x_attribute8                 => l_to_rsv_rec.attribute8
      , x_attribute9                 => l_to_rsv_rec.attribute9
      , x_attribute10                => l_to_rsv_rec.attribute10
      , x_attribute11                => l_to_rsv_rec.attribute11
      , x_attribute12                => l_to_rsv_rec.attribute12
      , x_attribute13                => l_to_rsv_rec.attribute13
      , x_attribute14                => l_to_rsv_rec.attribute14
      , x_attribute15                => l_to_rsv_rec.attribute15
      , x_ship_ready_flag            => l_to_rsv_rec.ship_ready_flag
      , x_staged_flag                => l_to_rsv_rec.staged_flag
      /**** {{ R12 Enhanced reservations code changes }}****/
      , x_crossdock_flag             => l_to_rsv_rec.crossdock_flag
      , x_crossdock_criteria_id      => l_to_rsv_rec.crossdock_criteria_id
      , x_demand_source_line_detail  => l_to_rsv_rec.demand_source_line_detail
      , x_serial_reservation_quantity => l_to_rsv_rec.serial_reservation_quantity
      , x_supply_receipt_date        => l_to_rsv_rec.supply_receipt_date
      , x_demand_ship_date           => l_to_rsv_rec.demand_ship_date
      , x_project_id                 => l_to_rsv_rec.project_id
      , x_task_id                    => l_to_rsv_rec.task_id
      /*** End R12 ***/

      );
      /*Bug#12665435 */
      IF l_quantity_reserved IS NULL THEN
           l_quantity_reserved  := l_to_rsv_rec.primary_reservation_quantity;
      END IF;
    -- for data sync b/w mtl_demand and mtl_reservations
    IF (l_debug = 1) THEN
       debug_print('Calling inv_rsv_synch.for_update');
    END IF;
    inv_rsv_synch.for_update(p_reservation_id => l_orig_rsv_tbl(1).reservation_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    -- Post Update CTO Validation
    IF l_to_rsv_rec.demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
       --
       IF l_orig_rsv_tbl(1).primary_reservation_quantity > l_to_rsv_rec.primary_reservation_quantity THEN
	  IF (l_debug = 1) THEN
	     debug_print('Calling cto_workflow_api_pk.wf_update_after_inv_unreserv');
	  END IF;
	  cto_workflow_api_pk.wf_update_after_inv_unreserv
	    (
	     p_order_line_id => l_to_rsv_rec.demand_source_line_id
	     , x_return_status => l_return_status
	     , x_msg_count => x_msg_count
	     , x_msg_data => x_msg_data
	     );
	ELSE --Else Condition Added for Bug#2467387.
	  IF (l_debug = 1) THEN
	     debug_print('Calling cto_workflow_api_pk.wf_update_after_inv_reserv');
	  END IF;
          cto_workflow_api_pk.wf_update_after_inv_reserv
	    (
	     p_order_line_id => l_to_rsv_rec.demand_source_line_id
	     ,x_return_status => l_return_status
	     ,x_msg_count => x_msg_count
	     ,x_msg_data => x_msg_data
	     );
       END IF;
       --
       IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
       --
    END IF;

    /**** {{ R12 Enhanced reservations code changes. Should be
    -- releasing the locks. }} *****/
    IF l_lock_obtained THEN
       inv_reservation_lock_pvt.release_lock
	 (l_supply_lock_handle);
       inv_reservation_lock_pvt.release_lock
	 (l_demand_lock_handle);
    END IF;
    /*** End R12 ***/

    x_return_status  := l_return_status;
    x_quantity_reserved:=l_quantity_reserved;
    -- INVCONV BEGIN
    IF l_dual_control_flag = 'Y' THEN
       x_secondary_quantity_reserved:=l_secondary_quantity_reserved;
    END IF;
    -- INVCONV END
    EXCEPTION
       WHEN fnd_api.g_exc_error THEN
	  IF (l_debug = 1) THEN
	     debug_print('Exception');
	  END IF;
	  ROLLBACK TO update_reservation_sa;
	  x_return_status  := fnd_api.g_ret_sts_error;
	  /**** {{ R12 Enhanced reservations code changes. Should be
	  -- releasing the locks. }} *****/
	  IF l_lock_obtained THEN
	     inv_reservation_lock_pvt.release_lock
	       (l_supply_lock_handle);
	     inv_reservation_lock_pvt.release_lock
	       (l_demand_lock_handle);
	  END IF;
	  /*** End R12 ***/
	  --  Get message count and data
	  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
       WHEN fnd_api.g_exc_unexpected_error THEN
	  IF (l_debug = 1) THEN
	     debug_print('Exception Unexpected');
	  END IF;
	  ROLLBACK TO update_reservation_sa;
	  x_return_status  := fnd_api.g_ret_sts_unexp_error;
	  /**** {{ R12 Enhanced reservations code changes. Should be
	  -- releasing the locks. }} *****/
	  IF l_lock_obtained THEN
	     inv_reservation_lock_pvt.release_lock
	       (l_supply_lock_handle);
	     inv_reservation_lock_pvt.release_lock
	       (l_demand_lock_handle);
	  END IF;
	  /*** End R12 ***/
	  --  Get message count and data
	  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
       WHEN OTHERS THEN
	  IF (l_debug = 1) THEN
	     debug_print('Exception Others'|| SQLERRM);
	  END IF;
	  ROLLBACK TO update_reservation_sa;
	  x_return_status  := fnd_api.g_ret_sts_unexp_error;
	  /**** {{ R12 Enhanced reservations code changes. Should be
	  -- releasing the locks. }} *****/
	  IF l_lock_obtained THEN
	     inv_reservation_lock_pvt.release_lock
	       (l_supply_lock_handle);
	     inv_reservation_lock_pvt.release_lock
	       (l_demand_lock_handle);
	  END IF;
	  /*** End R12 ***/
	  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	  END IF;

	  --  Get message count and data
	  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    END update_reservation;

  --
  PROCEDURE relieve_reservation(
    p_api_version_number        IN     NUMBER
  , p_init_msg_lst              IN     VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status             OUT    NOCOPY VARCHAR2
  , x_msg_count                 OUT    NOCOPY NUMBER
  , x_msg_data                  OUT    NOCOPY VARCHAR2
  , p_rsv_rec                   IN     inv_reservation_global.mtl_reservation_rec_type
  , p_primary_relieved_quantity IN     NUMBER
  , p_secondary_relieved_quantity IN     NUMBER                                     -- INVCONV
  , p_relieve_all               IN     VARCHAR2 DEFAULT fnd_api.g_true
  , p_original_serial_number    IN     inv_reservation_global.serial_number_tbl_type
  , p_validation_flag           IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_primary_relieved_quantity OUT    NOCOPY NUMBER
  , x_secondary_relieved_quantity  OUT    NOCOPY NUMBER 			    -- INVCONV
  , x_primary_remain_quantity   OUT    NOCOPY NUMBER
  , x_secondary_remain_quantity OUT    NOCOPY NUMBER                                -- INVCONV
  ) IS
    l_api_version_number          CONSTANT NUMBER       := 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) := 'Relieve_Reservation';
    l_return_status               VARCHAR2(1)           := fnd_api.g_ret_sts_success;
    l_tmp_rsv_tbl                 inv_reservation_global.mtl_reservation_tbl_type;
    l_tmp_rsv_tbl_count           NUMBER;
    l_reservation_id              NUMBER;
    l_dummy_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
    l_dummy_serial_array          inv_reservation_global.serial_number_tbl_type;
    --
    l_orig_item_cache_index       INTEGER                                         := NULL;
    l_orig_org_cache_index        INTEGER                                         := NULL;
    l_orig_demand_cache_index     INTEGER                                         := NULL;
    l_orig_supply_cache_index     INTEGER                                         := NULL;
    l_orig_sub_cache_index        INTEGER                                         := NULL;
    l_to_item_cache_index         INTEGER                                         := NULL;
    l_to_org_cache_index          INTEGER                                         := NULL;
    l_to_demand_cache_index       INTEGER                                         := NULL;
    l_to_supply_cache_index       INTEGER                                         := NULL;
    l_to_sub_cache_index          INTEGER                                         := NULL;
    l_tree_id                     NUMBER;
    l_error_code                  NUMBER;
    l_primary_relieved_quantity   NUMBER;
    l_secondary_relieved_quantity NUMBER;                                         -- INVCONV
    l_primary_remain_quantity     NUMBER;
    l_secondary_remain_quantity   NUMBER;                                         -- INVCONV
    l_date                        DATE;
    l_user_id                     NUMBER;
    l_request_id                  NUMBER;
    l_login_id                    NUMBER;
    l_prog_appl_id                NUMBER;
    l_program_id                  NUMBER;
    l_qty_changed                 NUMBER;
    l_secondary_qty_changed       NUMBER;					 -- INVCONV
    l_debug number;
    l_lot_divisible_flag          VARCHAR2(1);                                   -- INVCONV
    l_dual_control_flag		  VARCHAR2(1)			:= 'N';          -- INVCONV
    /*** {{ R12 Enhanced reservations code changes ***/
    l_count                       NUMBER;
    l_count_to_unrsv_serials      NUMBER :=0;
    l_serial_number_table         inv_reservation_global.serial_number_tbl_type;
    l_rsv_rec                     inv_reservation_global.mtl_reservation_rec_type;
    /*** End R12 }} ***/
  BEGIN
    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    SAVEPOINT relieve_reservation_sa;
    --
     -- Use cache to get value for l_debug
     IF g_is_pickrelease_set IS NULL THEN
        g_is_pickrelease_set := 2;
        IF INV_CACHE.is_pickrelease THEN
           g_is_pickrelease_set := 1;
        END IF;
     END IF;
     IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;

    /**** {{ R12 Enhanced reservations code changes ****/
    -- Set the original columns to g_miss_xxx as the user should not be
    -- setting these values. Do not query by them
    l_rsv_rec := p_rsv_rec;

    l_rsv_rec.orig_supply_source_type_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_supply_source_header_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_supply_source_line_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_supply_source_line_detail := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_type_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_header_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_line_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_line_detail := fnd_api.g_miss_num;

    /*** End R12 }} ***/

     IF (l_debug = 1) THEN
        debug_print('calling query_reservation');
     END IF;
    query_reservation(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_false
    , x_return_status              => l_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_query_input                => l_rsv_rec         /*** {{ R12 Enhanced reservations code changes ***/
    , p_lock_records               => fnd_api.g_true
    , x_mtl_reservation_tbl        => l_tmp_rsv_tbl
    , x_mtl_reservation_tbl_count  => l_tmp_rsv_tbl_count
    , x_error_code                 => l_error_code
    );

    --
    IF l_return_status = fnd_api.g_ret_sts_error THEN
     	IF (l_debug = 1) THEN
        	debug_print( 'error from query reservation');
     	END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF (l_debug = 1) THEN
         debug_print('error from query reservation');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    IF l_tmp_rsv_tbl_count = 0 THEN
      IF (l_debug = 1) THEN
         debug_print('reservation not found ');
      END IF;
      fnd_message.set_name('INV', 'INV-ROW NOT FOUND');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_tmp_rsv_tbl_count > 1 THEN
      IF (l_debug = 1) THEN
         debug_print('found more than one row reservation');
      END IF;
      fnd_message.set_name('INV', 'INV-RELIEVE MORE THAN ONE ROW');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    l_reservation_id             := l_tmp_rsv_tbl(1).reservation_id;
    IF (l_debug = 1) THEN
       debug_print('reservation id is ' || l_reservation_id);
    END IF;

    IF p_validation_flag = fnd_api.g_true THEN
         -- validation is needed to get revision, lot,
         --serial control information
         -- for creating the quantity tree

       -- added for crossdock reservation, pass the to reservation record
       -- with values instead of dummy record with the remain quantity
       -- populated to the record.
       IF ((l_tmp_rsv_tbl(1).crossdock_criteria_id is not null) and
	   (l_tmp_rsv_tbl(1).crossdock_criteria_id <> fnd_api.g_miss_num)) THEN
	  IF (l_debug = 1) THEN
	     debug_print('assigning cross dock to record');
	  END IF;

	  IF (p_relieve_all = fnd_api.g_false) THEN
	     IF (l_debug = 1) THEN
		debug_print('relieve all is false');
	     END IF;
	     l_primary_remain_quantity :=
	       l_tmp_rsv_tbl(1).primary_reservation_quantity -
	       Nvl(p_primary_relieved_quantity,0);
	   ELSE
	     IF (l_debug = 1) THEN
		debug_print('relieve all is true');
	     END IF;
	     l_primary_remain_quantity := 0;
	  END IF;

	  l_dummy_rsv_rec := l_tmp_rsv_tbl(1);
	  IF (l_debug = 1) THEN
	     debug_print('from rec primary reservation qty' || l_tmp_rsv_tbl(1).primary_reservation_quantity);
	     debug_print('to rec primary reservation qty' || l_primary_remain_quantity);
	  END IF;
          l_dummy_rsv_rec.primary_reservation_quantity := l_primary_remain_quantity;
	  l_dummy_rsv_rec.reservation_quantity := null;
	  --l_dummy_rsv_rec.secondary_reservation_quantity := l_secondary_remain_quantity;
       END IF;

       IF (l_debug = 1) THEN
          debug_print('calling validate_input_parameters');
       END IF;

      inv_reservation_validate_pvt.validate_input_parameters(
        x_return_status              => l_return_status
      , p_orig_rsv_rec               => l_tmp_rsv_tbl(1)
      , p_to_rsv_rec                 => l_dummy_rsv_rec
      , p_orig_serial_array          => p_original_serial_number
      , p_to_serial_array            => l_dummy_serial_array
      , p_rsv_action_name            => 'RELIEVE'
      , x_orig_item_cache_index      => l_orig_item_cache_index
      , x_orig_org_cache_index       => l_orig_org_cache_index
      , x_orig_demand_cache_index    => l_orig_demand_cache_index
      , x_orig_supply_cache_index    => l_orig_supply_cache_index
      , x_orig_sub_cache_index       => l_orig_sub_cache_index
      , x_to_item_cache_index        => l_to_item_cache_index
      , x_to_org_cache_index         => l_to_org_cache_index
      , x_to_demand_cache_index      => l_to_demand_cache_index
      , x_to_supply_cache_index      => l_to_supply_cache_index
      , x_to_sub_cache_index         => l_to_sub_cache_index
      );

      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         IF (l_debug = 1) THEN
            debug_print('Error in validate_input_parameters');
         END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         IF (l_debug = 1) THEN
            debug_print('Unexpected error in validate_input_parameters');
         END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
       -- INVCONV BEGIN
      IF is_lot_divisible(l_orig_item_cache_index) THEN
        l_lot_divisible_flag := 'Y';
      END IF;
      -- INVCONV END
      --
      -- check quantity
      IF  p_primary_relieved_quantity IS NULL
          AND p_relieve_all <> fnd_api.g_true THEN
        IF (l_debug = 1) THEN
           debug_print('relieve_quantity_not_specified');
        END IF;
        fnd_message.set_name('INV', 'RELIEVE_QUANTITY_NOT_SPECIFIED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF p_primary_relieved_quantity > l_tmp_rsv_tbl(1).primary_reservation_quantity THEN
        IF (l_debug = 1) THEN
           debug_print('relieve_more_than_reserved');
        END IF;
        fnd_message.set_name('INV', 'RELIEVE_MORE_THAN_RESERVED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF is_dual_control(l_orig_item_cache_index) THEN
        l_dual_control_flag := 'Y';
      END IF;

      IF p_relieve_all = fnd_api.g_true THEN
        l_primary_relieved_quantity  := l_tmp_rsv_tbl(1).primary_reservation_quantity;
        l_primary_remain_quantity    := 0;
        -- INVCONV BEGIN
        IF l_dual_control_flag = 'Y' THEN
          l_secondary_relieved_quantity  := l_tmp_rsv_tbl(1).secondary_reservation_quantity;
          l_secondary_remain_quantity    := 0;
        END IF;
        -- INVCONV END
      ELSE
        l_primary_relieved_quantity  := p_primary_relieved_quantity;
        l_primary_remain_quantity    := l_tmp_rsv_tbl(1).primary_reservation_quantity - l_primary_relieved_quantity;
        -- INVCONV BEGIN
        IF l_dual_control_flag = 'Y' THEN
          l_secondary_relieved_quantity := p_secondary_relieved_quantity;
          l_secondary_remain_quantity   := l_tmp_rsv_tbl(1).secondary_reservation_quantity - l_secondary_relieved_quantity;
        END IF;
        -- INVCONV END
      END IF;

      IF l_tmp_rsv_tbl(1).supply_source_type_id = inv_reservation_global.g_source_type_inv THEN
           -- call quantity processor to
           -- modify the tree so that the quantity tree
           -- reflect the deletion
        IF (l_debug = 1) THEN
           debug_print('calling inv_quantity_tree_pvt.create_tree');
        END IF;
        inv_quantity_tree_pvt.create_tree(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_organization_id            => l_tmp_rsv_tbl(1).organization_id
        , p_inventory_item_id          => l_tmp_rsv_tbl(1).inventory_item_id
        , p_tree_mode                  => inv_quantity_tree_pvt.g_reservation_mode
        , p_is_revision_control        => is_revision_control(l_orig_item_cache_index)
        , p_is_lot_control             => is_lot_control(l_orig_item_cache_index)
        , p_is_serial_control          => is_serial_control(l_orig_item_cache_index)
        , p_asset_sub_only             => FALSE
        , p_include_suggestion         => TRUE
        , p_demand_source_type_id      => l_tmp_rsv_tbl(1).demand_source_type_id
        , p_demand_source_header_id    => l_tmp_rsv_tbl(1).demand_source_header_id
        , p_demand_source_line_id      => l_tmp_rsv_tbl(1).demand_source_line_id
        , p_demand_source_name         => l_tmp_rsv_tbl(1).demand_source_name
        , p_demand_source_delivery     => l_tmp_rsv_tbl(1).demand_source_delivery
        , p_lot_expiration_date        => NULL
        , x_tree_id                    => l_tree_id
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
         IF (l_debug = 1) THEN
            debug_print('error calling inv_quantity_tree_pvt.create_tree');
         END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
               debug_print('unexpected error calling inv_quantity_tree_pvt.create_tree');
            END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
           debug_print('calling modify_tree_crt_del_rel');
        END IF;
        -- INVCONV - Upgrade call to incorporate secondaries
        modify_tree_crt_del_rel(
          x_return_status              => l_return_status
        , p_tree_id                    => l_tree_id
        , p_revision                   => l_tmp_rsv_tbl(1).revision
        , p_lot_number                 => l_tmp_rsv_tbl(1).lot_number
        , p_subinventory_code          => l_tmp_rsv_tbl(1).subinventory_code
        , p_locator_id                 => l_tmp_rsv_tbl(1).locator_id
        , p_lpn_id                     => l_tmp_rsv_tbl(1).lpn_id
        , p_primary_reservation_quantity=> l_tmp_rsv_tbl(1).primary_reservation_quantity
        , p_second_reservation_quantity=> l_tmp_rsv_tbl(1).secondary_reservation_quantity
        , p_detailed_quantity          => l_tmp_rsv_tbl(1).detailed_quantity
        , p_secondary_detailed_quantity=> l_tmp_rsv_tbl(1).secondary_detailed_quantity
        , p_relieve_quantity           => l_primary_relieved_quantity
        , p_secondary_relieve_quantity => l_secondary_relieved_quantity
        , p_partial_reservation_flag   => fnd_api.g_false
        , p_force_reservation_flag     => fnd_api.g_false
        , p_lot_divisible_flag         => l_lot_divisible_flag      -- INVCONV
        , p_action                     => 'RELIEVE'
        , x_qty_changed                => l_qty_changed
        , x_secondary_qty_changed      => l_secondary_qty_changed
	, p_organization_id            => l_rsv_rec.organization_id
        , p_demand_source_line_id      => l_tmp_rsv_tbl(1).demand_source_line_id
	, p_demand_source_type_id      => l_tmp_rsv_tbl(1).demand_source_type_id
        );

        --
        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
             debug_print('error calling modify_tree_crt_del_rel');
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
             debug_print('unexpected error calling modify_tree_crt_del_rel');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      --
      END IF;
    END IF;

     -- delete the reservation from the db table
    IF l_primary_remain_quantity = 0 THEN

       --Bug 3830160: Added a call to delete the demand if the entire
       --reservation is relieved. Code to delete mtl_demand.

       IF (l_debug = 1) THEN
          debug_print('calling inv_rsv_synch.for_delete');
       END IF;

       inv_rsv_synch.for_delete
         (
          p_reservation_id             => l_reservation_id
          , x_return_status              => l_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          );

       IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
             debug_print('error calling inv_rsv_synch.for_delete');
          END IF;
           RAISE fnd_api.g_exc_error;
       END IF;

       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
             debug_print('unexpected error calling inv_rsv_synch.for_delete');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
       -- End changes for bug 3827307

       /*** {{ R12 Enhanced reservations code changes ***/
       -- update the mtl_serial_numbers, null out the reservation_id
       -- and group_mark_id of the reserved serials before delete the
       -- reservation. There is no need to update the serial_reservation_quantity
       -- because the reservation record will be deleted.
       BEGIN
         update mtl_serial_numbers
         set    reservation_id = NULL,
	   group_mark_id = NULL,
	   line_mark_id = NULL,
	   lot_line_mark_id = NULL
         where  reservation_id = l_reservation_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                 debug_print('No serial numbers stamp with reservation_id ' || l_reservation_id);
              END IF;
       END;
       /*** End R12 }} ***/

       IF (l_debug = 1) THEN
          debug_print('calling mtl_reservations_pkg.delete_row');
       END IF;
       mtl_reservations_pkg.delete_row(x_reservation_id => l_reservation_id);
       NULL;

     ELSE

       --Bug 3830160: Moved the relieve demand code inside this block
       --so that 'for_relieve' will be called only if there are some pending
       --demand and if we are not relieving the entire reservation.

        IF (l_debug = 1) THEN
           debug_print('calling inv_rsv_synch.for_relieve');
        END IF;

        inv_rsv_synch.for_relieve(
          p_reservation_id             => l_reservation_id
        , p_primary_relieved_quantity  => l_primary_relieved_quantity
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
             debug_print('error calling inv_rsv_synch.for_relieve');
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           IF (l_debug = 1) THEN
              debug_print('unexpected error calling inv_rsv_synch.for_relieve');
           END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- End changes Bug3830160.

      l_tmp_rsv_tbl(1).primary_reservation_quantity  := l_tmp_rsv_tbl(1).primary_reservation_quantity - l_primary_relieved_quantity;

      -- INVCONV BEGIN
      IF l_dual_control_flag = 'Y' THEN
        l_tmp_rsv_tbl(1).secondary_reservation_quantity := l_tmp_rsv_tbl(1).secondary_reservation_quantity - l_secondary_relieved_quantity;
      END IF;
      -- INVCONV END

      --Bug 2116332 - convert_quantity only updates reservation quantity
      -- if that field is NULL.  So, we have to make reservation quantity
      -- NULL if we want to populate it from primary_reservation_quantity
      l_tmp_rsv_tbl(1).reservation_quantity          := NULL;
     	IF (l_debug = 1) THEN
        	debug_print('calling convert_quantity');
     	END IF;
      convert_quantity(x_return_status => l_return_status, px_rsv_rec => l_tmp_rsv_tbl(1));

      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- obtain program and user info
      l_date := SYSDATE;

      --
      l_user_id                                      := fnd_global.user_id;
      l_login_id                                     := fnd_global.login_id;

      IF l_login_id = -1 THEN
        l_login_id  := fnd_global.conc_login_id;
      END IF;

      l_request_id                                   := fnd_global.conc_request_id;
      l_prog_appl_id                                 := fnd_global.prog_appl_id;
      l_program_id                                   := fnd_global.conc_program_id;

      --Adding an extra check to make sure that relieve reservations does not
      -- update the record to a negative quantity.
      IF (l_debug = 1) THEN
        debug_print('Primary_reservation_qty before inserting (relieve)= '
		                || To_char(l_tmp_rsv_tbl(1).primary_reservation_quantity) );
        debug_print('Secondary_reservation_qty before inserting (relieve)= '
                                || To_char(l_tmp_rsv_tbl(1).secondary_reservation_quantity) );
        debug_print('Reservation_qty before inserting (relieve)= '
		                || To_char(l_tmp_rsv_tbl(1).reservation_quantity) );
      END IF;

      IF (  (NVL(l_tmp_rsv_tbl(1).reservation_quantity,0) < 0) OR
	          (NVL(l_tmp_rsv_tbl(1).primary_reservation_quantity,0) < 0) ) THEN
        fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- INVCONV BEGIN
      IF (NVL(l_tmp_rsv_tbl(1).secondary_reservation_quantity,0) < 0) THEN
        fnd_message.set_name('INV', 'INV-INVALID NEGATIVE SECONDARY');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      -- INVCONV END

      /*** {{ R12 Enhanced reservations code changes ***/
      -- if serial record is not empty, then unmark the group_mark_id and
      -- reservation_id in mtl_serial_numbers of the serial numbers pass in the record.
      -- also update the serial_reservation_quantity in the mtl_reservations.
      -- if serial record is empty, need to get the serials with reservation_id and
      -- unmark the serial until the serial_reservation_quantity = primary_reservation_quantity
      IF (p_original_serial_number.COUNT > 0) THEN
	 l_count := 0;
	 IF (l_debug = 1) THEN
	    debug_print('Inside relieve serial numbers');
	 END IF;
	 FOR i in 1..p_original_serial_number.COUNT LOOP
	    IF (l_debug = 1) THEN
	       debug_print('serial number' ||
			   p_original_serial_number(i).serial_number);
	       debug_print('item ' || l_tmp_rsv_tbl(1).inventory_item_id);
	    END IF;
             BEGIN
                UPDATE mtl_serial_numbers
		  SET reservation_id = NULL,
		  group_mark_id = NULL, line_mark_id = NULL,
		  lot_line_mark_id = NULL
		  WHERE  serial_number = p_original_serial_number(i).serial_number
		  AND    inventory_item_id =
		  l_tmp_rsv_tbl(1).inventory_item_id
		  AND current_organization_id = l_tmp_rsv_tbl(1).organization_id;
             EXCEPTION
                WHEN no_data_found THEN
                   IF (l_debug = 1) THEN
		      debug_print('No serials found for serial number ' || p_original_serial_number(i).serial_number);
                   END IF;
             END;
             l_count := l_count + 1;
	     IF (l_debug = 1) THEN
		debug_print('relieved serial count: ' || l_count);
	     END IF;
	 END LOOP;

	 IF (l_tmp_rsv_tbl(1).primary_reservation_quantity >=
	     Nvl(l_tmp_rsv_tbl(1).serial_reservation_quantity,0) - l_count) THEN
	    l_tmp_rsv_tbl(1).serial_reservation_quantity :=
	      l_tmp_rsv_tbl(1).serial_reservation_quantity - l_count;
	    IF (l_debug = 1) THEN
	       debug_print('Inside rsv > serial count: ' ||
			   l_tmp_rsv_tbl(1).primary_reservation_quantity
			   || ':' ||
			   l_tmp_rsv_tbl(1).serial_reservation_quantity ||
			   ':' || l_count);
	    END IF;
          ELSE
              -- need to unreserved more serials until the serial_reservation_quantity
	     -- is less than or equal to primary_reservation_quantity
	     IF (l_debug = 1) THEN
		debug_print('Inside serial count > rsv : ' ||
			    l_tmp_rsv_tbl(1).primary_reservation_quantity
			    || ':' ||
			    l_tmp_rsv_tbl(1).serial_reservation_quantity ||
			    ':' || l_count);
	     END IF;
              l_count_to_unrsv_serials := (Nvl(l_tmp_rsv_tbl(1).serial_reservation_quantity,0) - l_count)-l_tmp_rsv_tbl(1).primary_reservation_quantity;

	      IF (l_debug = 1) THEN
		 debug_print('total serials to be unreserved' ||
			     l_count_to_unrsv_serials);
		 debug_print('reservation id ' || l_reservation_id);
	      END IF;

              BEGIN
                 SELECT inventory_item_id,serial_number BULK COLLECT
                 INTO   l_serial_number_table
                 FROM   mtl_serial_numbers
                 WHERE  reservation_id = l_reservation_id;
              EXCEPTION
                 WHEN no_data_found THEN
                    IF (l_debug = 1) THEN
                        debug_print('No serials found for reservation record. id = ' || l_reservation_id);
                    END IF;
                    fnd_message.set_name('INV', 'INV_SR_EXCEED_RSV_QTY');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;
              END;

	      IF (l_debug = 1) THEN
		 debug_print('After query serials');
		 debug_print('l_serial_number_table.COUNT' ||
			     l_serial_number_table.COUNT);

	      END IF;

              IF (l_serial_number_table.COUNT < l_count_to_unrsv_serials) THEN
                  IF (l_debug = 1) THEN
                      debug_print('Not enough serials to unreserved for reservation record. id = ' || l_reservation_id);
                  END IF;
                  fnd_message.set_name('INV', 'INV_SR_EXCEED_RSV_QTY');
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_error;
              END IF;

              FOR i in 1..l_count_to_unrsv_serials LOOP
                  BEGIN
		     IF (l_debug = 1) THEN
			debug_print('inside relieve. serial ' ||
				    l_serial_number_table(i).serial_number);
			debug_print('inside relieve. item ' || l_serial_number_table(i).serial_number);
		     END IF;
		     UPDATE mtl_serial_numbers
		       SET reservation_id = NULL,
		       group_mark_id = NULL, line_mark_id = NULL,
		       lot_line_mark_id = NULL
		       WHERE  serial_number = l_serial_number_table(i).serial_number
		       AND inventory_item_id =
		       l_serial_number_table(i).inventory_item_id AND
		       current_organization_id = l_tmp_rsv_tbl(1).organization_id;
                  EXCEPTION
                     WHEN no_data_found THEN
                        IF (l_debug = 1) THEN
                            debug_print('No serial found for serial number ' || l_serial_number_table(i).serial_number);
                        END IF;
                  END;
                  l_count := l_count + 1;
		  IF (l_debug = 1) THEN
		     debug_print('l_count' || l_count);
		  END IF;
              END LOOP;

              l_tmp_rsv_tbl(1).serial_reservation_quantity :=
		l_tmp_rsv_tbl(1).serial_reservation_quantity - l_count;
	      IF (l_debug = 1) THEN
		 debug_print('final serial count' || l_tmp_rsv_tbl(1).serial_reservation_quantity);
	      END IF;
          END IF;
      ELSE -- p_original_serial_number is null
          IF (l_tmp_rsv_tbl(1).primary_reservation_quantity <
                     Nvl(l_tmp_rsv_tbl(1).serial_reservation_quantity,0)) THEN

              -- need to unreserved more serials until the serial_reservation_quantity
              -- is less than or equal to primary_reservation_quantity
              l_count_to_unrsv_serials :=
		Nvl(l_tmp_rsv_tbl(1).serial_reservation_quantity,0) - l_tmp_rsv_tbl(1).primary_reservation_quantity;
	      IF (l_debug = 1) THEN
		 debug_print('Inside p_original is null. total serials to be unreserved' ||
			     l_count_to_unrsv_serials);
		 debug_print('serial qty ' ||
			     l_tmp_rsv_tbl(1).serial_reservation_quantity);
		 debug_print('rsv qty ' || l_tmp_rsv_tbl(1).primary_reservation_quantity);
	      END IF;

              BEGIN
                 SELECT inventory_item_id, serial_number BULK COLLECT
                 INTO   l_serial_number_table
                 FROM   mtl_serial_numbers
                 WHERE  reservation_id = l_reservation_id;
              EXCEPTION
                 WHEN no_data_found THEN
                    IF (l_debug = 1) THEN
                        debug_print('No serial found for reservation record. id = ' || l_reservation_id);
                    END IF;
                    fnd_message.set_name('INV', 'INV_SR_EXCEED_RSV_QTY');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;
              END;

              IF (l_serial_number_table.COUNT < l_count_to_unrsv_serials) THEN
                  IF (l_debug = 1) THEN
                      debug_print('Not enough serials to unreserved for reservation record. id = ' || l_reservation_id);
                  END IF;
                  fnd_message.set_name('INV', 'INV_SR_EXCEED_RSV_QTY');
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_error;
              END IF;

              FOR i in 1..l_count_to_unrsv_serials LOOP
                  BEGIN
                     UPDATE mtl_serial_numbers
		       SET reservation_id = NULL,
		       group_mark_id = NULL, line_mark_id = NULL,
		       lot_line_mark_id = NULL
		       WHERE serial_number = l_serial_number_table(i).serial_number
		       AND inventory_item_id = l_serial_number_table(i).inventory_item_id;
                  EXCEPTION
                     WHEN no_data_found THEN
                        IF (l_debug = 1) THEN
			   debug_print('No serials found for serial number ' || l_serial_number_table(i).serial_number);
                        END IF;
                  END;
              END LOOP;

              l_tmp_rsv_tbl(1).serial_reservation_quantity := l_tmp_rsv_tbl(1).serial_reservation_quantity
                                                            - l_count_to_unrsv_serials;
          END IF;
      END IF;
      /*** End R12 }} ***/

         -- update the quantity in a quick and dirty way
      IF (l_debug = 1) THEN
         debug_print('update reservation');
      END IF;

      -- INVCONV - Incorporate secondaries
      UPDATE mtl_reservations
	SET primary_reservation_quantity = l_tmp_rsv_tbl(1).primary_reservation_quantity
	, secondary_reservation_quantity = l_tmp_rsv_tbl(1).secondary_reservation_quantity
	, reservation_quantity = l_tmp_rsv_tbl(1).reservation_quantity
	, last_update_date = l_date
	, last_updated_by = l_user_id
	, last_update_login = l_login_id
	, request_id = l_request_id
	, program_application_id = l_prog_appl_id
	, program_id = l_program_id
	, program_update_date = l_date
	/*** {{ R12 Enhanced reservations code changes ***/
	, serial_reservation_quantity =
	l_tmp_rsv_tbl(1).serial_reservation_quantity
	/*** End R12 }} ***/
	WHERE reservation_id = l_reservation_id;
    END IF;

    --
    x_primary_relieved_quantity  := l_primary_relieved_quantity;
    x_primary_remain_quantity    := l_primary_remain_quantity;
    -- INVCONV BEGIN
    IF l_dual_control_flag = 'Y' THEN
      x_secondary_relieved_quantity  := l_secondary_relieved_quantity;
      x_secondary_remain_quantity    := l_secondary_remain_quantity;
    END IF;
    -- INVCONV END
    x_return_status              := l_return_status;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO relieve_reservation_sa;
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO relieve_reservation_sa;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO relieve_reservation_sa;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END relieve_reservation;

  --
  PROCEDURE delete_reservation(
    p_api_version_number     IN     NUMBER
  , p_init_msg_lst           IN     VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , p_rsv_rec                IN     inv_reservation_global.mtl_reservation_rec_type
  , p_original_serial_number IN     inv_reservation_global.serial_number_tbl_type
  , p_validation_flag        IN     VARCHAR2 DEFAULT fnd_api.g_true
  ) IS
    l_api_version_number CONSTANT NUMBER                                          := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)                                    := 'Delete_Reservation';
    l_return_status               VARCHAR2(1)                                     := fnd_api.g_ret_sts_success;
    l_tmp_rsv_tbl                 inv_reservation_global.mtl_reservation_tbl_type;
    l_tmp_rsv_tbl_count           NUMBER;
    l_reservation_id              NUMBER;
    l_dummy_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
    l_dummy_serial_array          inv_reservation_global.serial_number_tbl_type;
    --
    l_orig_item_cache_index       INTEGER                                         := NULL;
    l_orig_org_cache_index        INTEGER                                         := NULL;
    l_orig_demand_cache_index     INTEGER                                         := NULL;
    l_orig_supply_cache_index     INTEGER                                         := NULL;
    l_orig_sub_cache_index        INTEGER                                         := NULL;
    l_to_item_cache_index         INTEGER                                         := NULL;
    l_to_org_cache_index          INTEGER                                         := NULL;
    l_to_demand_cache_index       INTEGER                                         := NULL;
    l_to_supply_cache_index       INTEGER                                         := NULL;
    l_to_sub_cache_index          INTEGER                                         := NULL;
    l_tree_id                     NUMBER;
    l_error_code                  NUMBER;
    l_qty_changed                 NUMBER;
    l_secondary_qty_changed       NUMBER;					-- INVCONV
    l_debug number;
    l_lot_divisible_flag          VARCHAR2(1)                                     :='Y'; -- INVCONV

    /*** {{ R12 Enhanced reservations code changes ***/
    l_rsv_rec                     inv_reservation_global.mtl_reservation_rec_type;
    /*** End R12 }} ***/
  BEGIN
     -- Use cache to get value for l_debug
     IF g_is_pickrelease_set IS NULL THEN
        g_is_pickrelease_set := 2;
        IF INV_CACHE.is_pickrelease THEN
           g_is_pickrelease_set := 1;
        END IF;
     END IF;
     IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;
     IF (l_debug = 1) THEN
        debug_print('Inside delete reservation...');
     END IF;
    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    /**** {{ R12 Enhanced reservations code changes ****/
    -- Set the original columns to g_miss_xxx as the user should not be
    -- setting these values. Do not query by them
    l_rsv_rec := p_rsv_rec;

    l_rsv_rec.orig_supply_source_type_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_supply_source_header_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_supply_source_line_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_supply_source_line_detail := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_type_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_header_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_line_id := fnd_api.g_miss_num;
    l_rsv_rec.orig_demand_source_line_detail := fnd_api.g_miss_num;

    /*** End R12 }} ***/

    IF (l_debug = 1) THEN
       debug_print('Before calling query reservation...');
    END IF;
    --
    query_reservation(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_false
    , x_return_status              => l_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_query_input                => l_rsv_rec           /*** {{ R12 Enhanced reservations code changes ***/
    , p_lock_records               => fnd_api.g_true
    , x_mtl_reservation_tbl        => l_tmp_rsv_tbl
    , x_mtl_reservation_tbl_count  => l_tmp_rsv_tbl_count
    , x_error_code                 => l_error_code
    );

    --
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    IF l_tmp_rsv_tbl_count = 0 THEN
      fnd_message.set_name('INV', 'INV-ROW NOT FOUND');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('After calling query reservation... ' || l_return_status);
       debug_print('No of rows to be deleted '|| l_tmp_rsv_tbl_count);
    END IF;
    --
    IF l_tmp_rsv_tbl_count > 1 THEN
      fnd_message.set_name('INV', 'INV-DELETE MORE THAN ONE ROW');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    l_reservation_id  := l_tmp_rsv_tbl(1).reservation_id;

    --
    IF (l_debug = 1) THEN
       debug_print('Before calling validate...');
    END IF;
    -- Bug 2354735: Proceed with Validation if p_validation_flag = 'T' or 'V'
     IF p_validation_flag = fnd_api.g_true OR p_validation_flag = 'V' THEN
      -- validation is needed to get revision, lot,
      --serial control information
      -- for creating the quantity tree
      inv_reservation_validate_pvt.validate_input_parameters(
        x_return_status              => l_return_status
      , p_orig_rsv_rec               => l_tmp_rsv_tbl(1)
      , p_to_rsv_rec                 => l_dummy_rsv_rec
      , p_orig_serial_array          => p_original_serial_number
      , p_to_serial_array            => l_dummy_serial_array
      , p_rsv_action_name            => 'DELETE'
      , x_orig_item_cache_index      => l_orig_item_cache_index
      , x_orig_org_cache_index       => l_orig_org_cache_index
      , x_orig_demand_cache_index    => l_orig_demand_cache_index
      , x_orig_supply_cache_index    => l_orig_supply_cache_index
      , x_orig_sub_cache_index       => l_orig_sub_cache_index
      , x_to_item_cache_index        => l_to_item_cache_index
      , x_to_org_cache_index         => l_to_org_cache_index
      , x_to_demand_cache_index      => l_to_demand_cache_index
      , x_to_supply_cache_index      => l_to_supply_cache_index
      , x_to_sub_cache_index         => l_to_sub_cache_index
      );

      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- INVCONV BEGIN
      IF NOT is_lot_divisible(l_orig_item_cache_index) THEN
        l_lot_divisible_flag := 'N';
      END IF;
      -- INVCONV END

      -- Bug 2354735: Proceed with Trees only if p_validation_flag = 'T'
      IF l_tmp_rsv_tbl(1).supply_source_type_id = inv_reservation_global.g_source_type_inv
         AND p_validation_flag = fnd_api.g_true THEN
        -- call quantity processor to
        -- modify the tree so that the quantity tree
        -- reflect the deletion
        inv_quantity_tree_pvt.create_tree(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_organization_id            => l_tmp_rsv_tbl(1).organization_id
        , p_inventory_item_id          => l_tmp_rsv_tbl(1).inventory_item_id
        , p_tree_mode                  => inv_quantity_tree_pvt.g_reservation_mode
        , p_is_revision_control        => is_revision_control(l_orig_item_cache_index)
        , p_is_lot_control             => is_lot_control(l_orig_item_cache_index)
        , p_is_serial_control          => is_serial_control(l_orig_item_cache_index)
        , p_asset_sub_only             => FALSE
        , p_include_suggestion         => TRUE
        , p_demand_source_type_id      => l_tmp_rsv_tbl(1).demand_source_type_id
        , p_demand_source_header_id    => l_tmp_rsv_tbl(1).demand_source_header_id
        , p_demand_source_line_id      => l_tmp_rsv_tbl(1).demand_source_line_id
        , p_demand_source_name         => l_tmp_rsv_tbl(1).demand_source_name
        , p_demand_source_delivery     => l_tmp_rsv_tbl(1).demand_source_delivery
        , p_lot_expiration_date        => NULL
        , x_tree_id                    => l_tree_id
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

	IF (l_debug = 1) THEN
           debug_print('After calling validate...' || l_return_status);
        END IF;

        -- INVCONV - Upgrade call to incorporate secondaries
        modify_tree_crt_del_rel(
          x_return_status              => l_return_status
        , p_tree_id                    => l_tree_id
        , p_revision                   => l_tmp_rsv_tbl(1).revision
        , p_lot_number                 => l_tmp_rsv_tbl(1).lot_number
        , p_subinventory_code          => l_tmp_rsv_tbl(1).subinventory_code
        , p_locator_id                 => l_tmp_rsv_tbl(1).locator_id
        , p_lpn_id                     => l_tmp_rsv_tbl(1).lpn_id
        , p_primary_reservation_quantity=> l_tmp_rsv_tbl(1).primary_reservation_quantity
        , p_second_reservation_quantity=> l_tmp_rsv_tbl(1).secondary_reservation_quantity
        , p_detailed_quantity          => l_tmp_rsv_tbl(1).detailed_quantity
        , p_secondary_detailed_quantity=> l_tmp_rsv_tbl(1).secondary_detailed_quantity
        , p_partial_reservation_flag   => fnd_api.g_false
        , p_force_reservation_flag     => fnd_api.g_false
        , p_lot_divisible_flag         => l_lot_divisible_flag    -- INVCONV
        , p_action                     => 'DELETE'
        , x_qty_changed                => l_qty_changed
        , x_secondary_qty_changed      => l_secondary_qty_changed
	, p_organization_id            => l_rsv_rec.organization_id
        , p_demand_source_line_id      => l_tmp_rsv_tbl(1).demand_source_line_id
	, p_demand_source_type_id      => l_tmp_rsv_tbl(1).demand_source_type_id
        );

        --
        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
	IF (l_debug = 1) THEN
           debug_print('Return Status...' || l_return_status);
        END IF;
      --
      END IF;
    END IF;


    -- Pre Delete CTO Validation
    IF l_tmp_rsv_tbl(1).demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
      --
      cto_workflow_api_pk.inventory_unreservation_check(
        p_order_line_id              => l_tmp_rsv_tbl(1).demand_source_line_id
      , p_rsv_quantity               => l_tmp_rsv_tbl(1).primary_reservation_quantity
      , x_return_status              => l_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      );

      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    --
    END IF;
    IF (l_debug = 1) THEN
       debug_print('After calling inventory_unreservation_check...' || l_return_status);
    END IF;

    --
    -- for data sync b/w mtl_demand and mtl_reservations
    inv_rsv_synch.for_delete(p_reservation_id => l_reservation_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    /*** {{ R12 Enhanced reservations code changes ***/
    -- update the mtl_serial_numbers, null out the reservation_id
    -- and group_mark_id of the reserved serials before delete the
    -- reservation. There is no need to update the serial_reservation_quantity
    -- because the reservation record will be deleted.
    BEGIN
       update mtl_serial_numbers
	 set reservation_id = NULL,
	 group_mark_id = NULL, line_mark_id = NULL,
	 lot_line_mark_id = NULL
	 where reservation_id = l_reservation_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
	  IF (l_debug = 1) THEN
	     debug_print('No serial numbers stamp with reservation_id ' || l_reservation_id);
	  END IF;
    END;
    /*** End R12 }} ***/

    --
    --
    -- delete the reservation from the db table
    mtl_reservations_pkg.delete_row(x_reservation_id => l_reservation_id);

    -- Post Delete CTO Validation
    IF l_tmp_rsv_tbl(1).demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
      --
      cto_workflow_api_pk.wf_update_after_inv_unreserv(
        p_order_line_id              => l_tmp_rsv_tbl(1).demand_source_line_id
      , x_return_status              => l_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      );

      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --
      IF (l_debug = 1) THEN
         debug_print('After calling wf_update_after_inv_unreserv...' || l_return_status);
      END IF;
    END IF;

    x_return_status   := l_return_status;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END delete_reservation;


/**** {{ R12 Enhanced reservations code changes }}****/
-- Description
  --   transfer is very similar to update
  --   except the to row can be not exist (will be created) or
  --   exist (will be add upon)
  PROCEDURE transfer_reservation
    (
     p_api_version_number       IN     NUMBER
     , p_init_msg_lst           IN     VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status          OUT    NOCOPY VARCHAR2
     , x_msg_count              OUT    NOCOPY NUMBER
     , x_msg_data               OUT    NOCOPY VARCHAR2
     , p_original_rsv_rec       IN     inv_reservation_global.mtl_reservation_rec_type
     , p_to_rsv_rec             IN     inv_reservation_global.mtl_reservation_rec_type
     , p_original_serial_number IN     inv_reservation_global.serial_number_tbl_type
     , p_validation_flag        IN     VARCHAR2 DEFAULT fnd_api.g_true
     , p_over_reservation_flag  IN  NUMBER DEFAULT 0
     , x_reservation_id         OUT    NOCOPY NUMBER
     ) IS

     l_api_version_number CONSTANT NUMBER :=  1.0;
     l_api_name           CONSTANT VARCHAR2(30) := 'Transfrer_Reservation';
     l_return_status      VARCHAR2(1) :=  fnd_api.g_ret_sts_success;
     l_quantity_reserved  NUMBER;
     l_secondary_quantity_reserved NUMBER;          -- INVCONV
     l_debug NUMBER;
     l_dummy_serial_number inv_reservation_global.serial_number_tbl_type;
     l_reservation_id NUMBER;
     l_reservation_qty_lot NUMBER := 0; --Bug 12978409

  BEGIN
     --  Standard call to check for call compatibility
     IF NOT fnd_api.compatible_api_call
       (l_api_version_number
	, p_api_version_number
	, l_api_name
	, G_PKG_NAME
	) THEN
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     --  Initialize message list.
     IF fnd_api.to_boolean(p_init_msg_lst) THEN
	fnd_msg_pub.initialize;
     END IF;

     -- Use cache to get value for l_debug
     IF g_is_pickrelease_set IS NULL THEN
        g_is_pickrelease_set := 2;
        IF INV_CACHE.is_pickrelease THEN
           g_is_pickrelease_set := 1;
        END IF;
     END IF;
     IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;

     IF l_debug=1 THEN
	debug_print('Calling the overloaded procedure transfer_reservation');
     END IF;

     inv_reservation_pvt.transfer_reservation
       (p_api_version_number          => 1.0,
	p_init_msg_lst                => p_init_msg_lst,
	x_return_status               => l_return_status,
	x_msg_count                   => x_msg_count,
	x_msg_data                    => x_msg_data,
	p_original_rsv_rec            => p_original_rsv_rec,
	p_to_rsv_rec                  => p_to_rsv_rec,
	p_original_serial_number      => p_original_serial_number,
	p_to_serial_number            => l_dummy_serial_number,
	p_validation_flag             => p_validation_flag,
	p_over_reservation_flag       => p_over_reservation_flag,
	x_reservation_id              => l_reservation_id
	);

     IF (l_debug=1) THEN
	debug_print ('Return Status after transfer reservations '||l_return_status);
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_error THEN

	IF l_debug=1 THEN
	   debug_print('Raising expected error'||l_return_status);
	END IF;

	RAISE fnd_api.g_exc_error;

      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

	IF l_debug=1 THEN
	   debug_print('Raising Unexpected error'||l_return_status);
	END IF;

	RAISE fnd_api.g_exc_unexpected_error;
     END IF;


     x_return_status := l_return_status;
     x_reservation_id := l_reservation_id;

  EXCEPTION

     WHEN fnd_api.g_exc_error THEN
	x_return_status := fnd_api.g_ret_sts_error;
	--  Get message count and data
	fnd_msg_pub.count_and_get
	  (  p_count => x_msg_count
	     , p_data  => x_msg_data
	     );

     WHEN fnd_api.g_exc_unexpected_error THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error ;

	--  Get message count and data
	fnd_msg_pub.count_and_get
	  (  p_count  => x_msg_count
	     , p_data   => x_msg_data
	     );

     WHEN OTHERS THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error ;

	IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	  THEN
	   fnd_msg_pub.add_exc_msg
	     (  g_pkg_name
		, l_api_name
		);
	END IF;

	--  Get message count and data
	fnd_msg_pub.count_and_get
	  (  p_count  => x_msg_count
	     , p_data   => x_msg_data
	     );

  END transfer_reservation;
  /*** End R12 ***/

  -- Overloaded transfer_reservation API
  -- Description
  --   transfer is very similar to update
  --   except the to row can be not exist (will be created) or
  --   exist (will be add upon)
  PROCEDURE transfer_reservation
    (
     p_api_version_number     IN     NUMBER
     , p_init_msg_lst           IN     VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status          OUT    NOCOPY VARCHAR2
     , x_msg_count              OUT    NOCOPY NUMBER
     , x_msg_data               OUT    NOCOPY VARCHAR2
     , p_original_rsv_rec       IN     inv_reservation_global.mtl_reservation_rec_type
     , p_to_rsv_rec             IN     inv_reservation_global.mtl_reservation_rec_type
     , p_original_serial_number IN     inv_reservation_global.serial_number_tbl_type
     /**** {{ R12 Enhanced reservations code changes }}****/
     , p_to_serial_number  IN  inv_reservation_global.serial_number_tbl_type
     /*** End R12 ***/
     , p_validation_flag        IN     VARCHAR2 DEFAULT fnd_api.g_true
     , p_over_reservation_flag  IN  NUMBER DEFAULT 0
     , x_reservation_id         OUT    NOCOPY NUMBER
     ) IS
	l_api_version_number  CONSTANT NUMBER                                          := 1.0;
	l_api_name            CONSTANT VARCHAR2(30)                                    := 'Transfer_Reservation';
	l_return_status                VARCHAR2(1)                                     := fnd_api.g_ret_sts_success;
	l_original_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
	l_to_rsv_rec                   inv_reservation_global.mtl_reservation_rec_type;
	l_orig_rsv_tbl                 inv_reservation_global.mtl_reservation_tbl_type;
	l_orig_rsv_tbl_count           NUMBER;
	l_to_rsv_tbl                   inv_reservation_global.mtl_reservation_tbl_type;
	--
	l_to_rsv_tbl_count             NUMBER;
	l_transfer_all                 BOOLEAN;
	l_to_row_exist                 BOOLEAN;
	l_primary_uom_code             VARCHAR2(3);
	l_reservation_uom_code         VARCHAR2(3);
	l_reservation_id               NUMBER;
	l_orig_item_cache_index        INTEGER                                         := NULL;
	l_orig_org_cache_index         INTEGER                                         := NULL;
	l_orig_demand_cache_index      INTEGER                                         := NULL;
	l_orig_supply_cache_index      INTEGER                                         := NULL;
	l_orig_sub_cache_index         INTEGER                                         := NULL;
	l_to_item_cache_index          INTEGER                                         := NULL;
	l_to_org_cache_index           INTEGER                                         := NULL;
	l_to_demand_cache_index        INTEGER                                         := NULL;
	l_to_supply_cache_index        INTEGER                                         := NULL;
	l_to_sub_cache_index           INTEGER                                         := NULL;
	l_primary_reservation_quantity NUMBER;
	l_second_reservation_quantity  NUMBER;                                      -- INVCONV
	l_tree_id1                     NUMBER;
	l_tree_id2                     NUMBER;
	l_date                         DATE;
	l_user_id                      NUMBER;
	l_request_id                   NUMBER;
	l_login_id                     NUMBER;
	l_prog_appl_id                 NUMBER;
	l_program_id                   NUMBER;
	l_qty                          NUMBER;
	l_rowid                        VARCHAR2(2000);
	l_error_code                   NUMBER;
	l_detailed_quantity            NUMBER;
	l_secondary_detailed_quantity  NUMBER;                                       -- INVCONV
	l_new_orig_rsv_qty             NUMBER;
	l_new_orig_prim_qty            NUMBER;
	l_orig_second_rsv_qty          NUMBER;                                       -- INVCONV
	l_primary_rsv_quantity NUMBER;
	l_secondary_rsv_quantity       NUMBER;                                       -- INVCONV
	l_rsv_quantity NUMBER;
	l_debug number;
	l_quantity_reserved  NUMBER;
	l_secondary_quantity_reserved  NUMBER;                                       -- INVCONV
	l_lot_divisible_flag           VARCHAR2(1)  :='Y';                           -- INVCONV
	l_dual_tracking                BOOLEAN := FALSE;                             -- INVCONV

	/**** {{ R12 Enhanced reservations code changes }}****/
	l_original_serial_number inv_reservation_global.serial_number_tbl_type;
	l_to_serial_number inv_reservation_global.serial_number_tbl_type;
	l_serial_number_table inv_reservation_global.serial_number_tbl_type;
	l_dummy_rsv_rec inv_reservation_global.mtl_reservation_rec_type;
	l_dummy_serial_array  inv_reservation_global.serial_number_tbl_type;
	l_qty_available NUMBER := 0;
	l_original_serial_count NUMBER;
	l_to_serial_count NUMBER;
	l_serial_param NUMBER;
	l_serials_tobe_unreserved NUMBER;
	l_total_serials_reserved NUMBER;
	l_total_to_serials_reserved NUMBER;
	l_from_reservation_id NUMBER;
	l_validate_serials_reserved NUMBER;
	l_validate_serial_number_table inv_reservation_global.serial_number_tbl_type;
	l_serials_unreserved NUMBER;
	l_to_reservation_id NUMBER;
	l_total_from_serials_reserved NUMBER;
	l_from_primary_reservation_qty NUMBER;
	l_to_primary_reservation_qty NUMBER;
	l_supply_lock_handle varchar2(128);
	l_demand_lock_handle varchar2(128);
	l_lock_status NUMBER;
        l_reserved_qty NUMBER := 0;
        l_requested_qty NUMBER := 0;
	l_group_mark_id NUMBER := NULL;
	l_lock_obtained BOOLEAN := FALSE;
	l_pjm_enabled NUMBER;
	l_project_id NUMBER;
	l_task_id NUMBER;
	l_orig_supply_type_id NUMBER;
	l_supply_source_type_id NUMBER;
	/*** End R12 ***/
    l_reservation_qty_lot NUMBER := 0; --Bug 12978409
    /* Added for bug 13829182 */
    l_wip_entity_id NUMBER;
	l_wip_entity_type NUMBER;
	l_wip_job_type VARCHAR2(15);
	l_maintenance_object_source NUMBER;
    /* End of changes for bug 13829182 */
    --MUOM Fulfillment Project
     l_qty_available2  NUMBER;
     l_quantity_reserved2 NUMBER;
     l_fulfill_base   VARCHAR2(1) := 'P';
     l_org_sec_rsv_qty NUMBER;
     l_qoh NUMBER;
     l_rqoh NUMBER;
     l_qr NUMBER;
	 l_qs NUMBER;
	 l_att NUMBER;
	 l_atr NUMBER;
     l_sqoh	NUMBER;
	 l_srqoh NUMBER;
	 l_sqr NUMBER;
     l_sqs NUMBER;
     l_satt NUMBER;
     l_satr NUMBER;


  BEGIN
    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;
    IF (l_debug = 1) THEN
       debug_print('Inside transfer reservation...');
    END IF;

    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('The original reservation record: ');
    END IF;
    print_rsv_rec(p_original_rsv_rec);
    IF (l_debug = 1) THEN
       debug_print('The to reservation record: ');
    END IF;
    print_rsv_rec(p_to_rsv_rec);

    --
    --
    -- if the transfer quantity is 0, call delete instead
    IF p_to_rsv_rec.primary_reservation_quantity = 0
       OR (p_to_rsv_rec.reservation_quantity = 0
           AND (p_to_rsv_rec.primary_reservation_quantity IS NULL
                OR p_to_rsv_rec.primary_reservation_quantity = fnd_api.g_miss_num
               )
          ) THEN
      x_return_status  := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;

    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    /**** {{ R12 Enhanced reservations code changes }}****/

    -- Set the original columns to g_miss_xxx as the user should not be
    -- setting these values. Do not query by them
    l_original_rsv_rec := p_original_rsv_rec;

    l_original_rsv_rec.orig_supply_source_type_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_supply_source_header_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_supply_source_line_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_supply_source_line_detail := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_demand_source_type_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_demand_source_header_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_demand_source_line_id := fnd_api.g_miss_num;
    l_original_rsv_rec.orig_demand_source_line_detail := fnd_api.g_miss_num;

    /*** End R12 ***/

    SAVEPOINT transfer_reservation_sa;
    IF (l_debug = 1) THEN
       debug_print('Before calling query rsv for the from record: ' || l_return_status);
    END IF;

    -- search for the from row
    query_reservation(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_false
    , x_return_status              => l_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_query_input                => l_original_rsv_rec
    , p_lock_records               => fnd_api.g_true
    , x_mtl_reservation_tbl        => l_orig_rsv_tbl
    , x_mtl_reservation_tbl_count  => l_orig_rsv_tbl_count
    , x_error_code                 => l_error_code
    );

    --
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    IF l_orig_rsv_tbl_count = 0 THEN
      fnd_message.set_name('INV', 'INV-ROW NOT FOUND');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_orig_rsv_tbl_count > 1 THEN
      fnd_message.set_name('INV', 'TRANSFER MORE THAN ONE ROW');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('After calling query rsv from record: ' || l_return_status);
       debug_print(' orig tbl count' || l_orig_rsv_tbl_count);
    END IF;

    construct_to_reservation_row(l_orig_rsv_tbl(1), p_to_rsv_rec, l_to_rsv_rec);

    --
    -- if the caller does not specified reservation_id, l_to_rsv_rec will
    -- has the same reservation_id as l_orig_rsv_tbl(1) due to the way
    -- construct_to_reservation_row works.
    -- but we should set it to g_miss_num again
    -- otherwise query_reservation will use only the
    -- reservation_id to do the search.
    IF l_to_rsv_rec.reservation_id = l_orig_rsv_tbl(1).reservation_id THEN
      l_to_rsv_rec.reservation_id  := fnd_api.g_miss_num;
    END IF;

    --
    IF l_orig_rsv_tbl(1).organization_id <> l_to_rsv_rec.organization_id THEN
      fnd_message.set_name('INV', 'CANNOT_CHANGE_ORGANIZATION_ID');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_orig_rsv_tbl(1).inventory_item_id <> l_to_rsv_rec.inventory_item_id THEN
      fnd_message.set_name('INV', 'CANNOT_CHANGE_INVENTORY_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- convert quantity between primary uom and reservation uom
    convert_quantity(x_return_status => l_return_status, px_rsv_rec => l_to_rsv_rec);

    --
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    /**** {{ R12 Enhanced reservations code changes }}****/

    -- Set the original columns to g_miss_xxx as the user should not be
    -- setting these values. Do not query by them
    l_to_rsv_rec.orig_supply_source_type_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_supply_source_header_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_supply_source_line_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_supply_source_line_detail := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_demand_source_type_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_demand_source_header_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_demand_source_line_id := fnd_api.g_miss_num;
    l_to_rsv_rec.orig_demand_source_line_detail := fnd_api.g_miss_num;

    IF (l_to_rsv_rec.project_id IS NULL)  THEN
       l_to_rsv_rec.project_id := fnd_api.g_miss_num;
    END IF;
    IF (l_to_rsv_rec.task_id IS NULL)  THEN
       l_to_rsv_rec.task_id := fnd_api.g_miss_num;
    END IF;
    /*** End R12 ***/

    IF (l_debug = 1) THEN
       debug_print('Before query reservation for the to rec...' || l_return_status);
    END IF;
    --
    -- search for the to row
    query_reservation(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_false
    , x_return_status              => l_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_query_input                => l_to_rsv_rec
    , p_lock_records               => fnd_api.g_true
    , x_mtl_reservation_tbl        => l_to_rsv_tbl
    , x_mtl_reservation_tbl_count  => l_to_rsv_tbl_count
    , x_error_code                 => l_error_code
    );

    --
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    IF l_to_rsv_tbl_count > 1 THEN
      -- if there more than one target row, the reservation table
      -- must be damaged. We can not do anything but failed
      fnd_message.set_name('INV', 'INV-RSV-TOO-MANY-TARGET');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('After query reservation to rec...' || l_return_status);
       debug_print('l_to_rsv_tbl_count ' || l_to_rsv_tbl_count);
    END IF;

    IF  l_to_rsv_tbl_count = 1
        AND l_to_rsv_tbl(1).reservation_id = l_orig_rsv_tbl(1).reservation_id THEN
      -- this is a lazy way to find out that the user
      -- is trying to use transfer_reservation
      -- to update non primary key fields
      -- otherwise we would not have the target row having the same values
      -- in the primary key columns (see query_reservation select criteria)
      -- as the original reservation.
      -- we might want to move that to the validation api soon
      fnd_message.set_name('INV', 'MISS_USE_TRANSFER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_to_row_exist   := (l_to_rsv_tbl_count > 0);

    --
    -- if the target reservation already exists, record its reservation id
    IF l_to_row_exist THEN
      l_to_rsv_rec.reservation_id  := l_to_rsv_tbl(1).reservation_id;
    END IF;

   --
    IF l_orig_rsv_tbl(1).primary_reservation_quantity < l_to_rsv_rec.primary_reservation_quantity THEN
      fnd_message.set_name('INV', 'TRANSFER MORE THAN RESERVE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    /**** {{ R12 Enhanced reservations code changes.Calling the reservation
    -- lock API to create a user-defined lock for non-inventory supplies }} *****/
      -- Bug 5199672: Should pass null to supply and demand line detail as
      -- we will have to lock the records at the document level and not at
      -- the line level. Also, for ASN, pass the source type as PO so that the
      -- the lock name would be the same as the PO's

    IF (l_to_rsv_rec.supply_source_type_id =
	inv_reservation_global.g_source_type_asn) THEN
       l_supply_source_type_id :=
	 inv_reservation_global.g_source_type_po;
     ELSE
       l_supply_source_type_id := l_to_rsv_rec.supply_source_type_id;
    END IF;

    IF (l_to_rsv_rec.supply_source_type_id <> inv_reservation_global.g_source_type_inv) THEN
       inv_reservation_lock_pvt.lock_supply_demand_record
	 (p_organization_id => l_to_rsv_rec.organization_id
	  ,p_inventory_item_id => l_to_rsv_rec.inventory_item_id
	  ,p_source_type_id => l_supply_source_type_id
	  ,p_source_header_id => l_to_rsv_rec.supply_source_header_id
	  ,p_source_line_id =>  l_to_rsv_rec.supply_source_line_id
	  ,p_source_line_detail => NULL
	  ,x_lock_handle => l_supply_lock_handle
	  ,x_lock_status => l_lock_status);

       IF l_lock_status = 0 THEN
	  fnd_message.set_name('INV', 'INV_INVALID_LOCK');
	  fnd_msg_pub.ADD;
	  RAISE fnd_api.g_exc_error;
       END if;

       inv_reservation_lock_pvt.lock_supply_demand_record
	 (p_organization_id => l_to_rsv_rec.organization_id
	  ,p_inventory_item_id => l_to_rsv_rec.inventory_item_id
	  ,p_source_type_id => l_to_rsv_rec.demand_source_type_id
	  ,p_source_header_id => l_to_rsv_rec.demand_source_header_id
	  ,p_source_line_id =>  l_to_rsv_rec.demand_source_line_id
	  ,p_source_line_detail => NULL
	  ,x_lock_handle => l_demand_lock_handle
	  ,x_lock_status => l_lock_status);

       IF l_lock_status = 0 THEN
	  fnd_message.set_name('INV', 'INV_INVALID_LOCK');
	  fnd_msg_pub.ADD;
	  RAISE fnd_api.g_exc_error;
       END if;

       l_lock_obtained := TRUE;
    END IF;

    -- Get the project and task for demands in OE, INT-ORD and RMA
    IF l_debug=1 THEN
       debug_print('Before Rsv rec project id: ' || l_to_rsv_rec.project_id);
       debug_print('Before Rsv rec task id: ' || l_to_rsv_rec.task_id);
    END IF;
    -- Bug : 5264987 : For Pick Release seeting the l_pjm_enabled flag
    -- from INV_CACHE.
    IF INV_CACHE.is_pickrelease OR g_is_pickrelease_set = 1 THEN
        debug_print ('is_pickrelaese is true');
	-- Query for and cache the org record.
	IF (NOT INV_CACHE.set_org_rec(l_to_rsv_rec.organization_id))
	THEN
		IF (l_debug = 1) THEN
			debug_print('Error caching the org record');
		END IF;
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;
	-- Set the PJM enabled flag.
	l_pjm_enabled := INV_CACHE.org_rec.project_reference_enabled;
    ELSE
        debug_print ('is_pickrelaese is not true');
        BEGIN
            SELECT project_reference_enabled
	    INTO l_pjm_enabled
	    FROM   mtl_parameters
	    WHERE  organization_id = l_to_rsv_rec.organization_id;
        EXCEPTION
            WHEN no_data_found THEN
	       IF l_debug=1 THEN
	       debug_print('Cannot find the project and task information');
	       END IF;
        END;
     END IF;
    IF (l_to_rsv_rec.demand_source_type_id IN
	(inv_reservation_global.g_source_type_oe,
	 inv_reservation_global.g_source_type_internal_ord,
	 inv_reservation_global.g_source_type_rma)) AND
      (l_pjm_enabled = 1) THEN

       IF (l_to_rsv_rec.demand_source_line_id IS NOT NULL) AND
	 (l_to_rsv_rec.demand_source_line_id <> fnd_api.g_miss_num)
	 AND ((l_to_rsv_rec.project_id = fnd_api.g_miss_num) OR
	      (l_to_rsv_rec.task_id = fnd_api.g_miss_num)) THEN
	 -- Added the below IF condition for Bug Fix 5264987
	 IF l_to_rsv_rec.demand_source_line_id = g_oe_line_id THEN
		l_project_id := g_project_id;
		l_task_id    := g_task_id;
	 ELSE
		 BEGIN
		    SELECT project_id, task_id INTO l_project_id, l_task_id
		      FROM oe_order_lines_all WHERE
		      line_id = l_to_rsv_rec.demand_source_line_id;
		 EXCEPTION
		    WHEN no_data_found THEN
		       IF l_debug=1 THEN
			  debug_print('Cannot find the project and task information');
		       END IF;
		 END;
	 END IF;

	 IF (l_to_rsv_rec.project_id = fnd_api.g_miss_num) THEN
	    IF (l_project_id IS NOT NULL) THEN
	       l_to_rsv_rec.project_id := l_project_id;
	     ELSE
	       l_to_rsv_rec.project_id := NULL;
	    END IF;
	 END IF;

	 IF (l_to_rsv_rec.task_id = fnd_api.g_miss_num) THEN
	    IF (l_task_id IS NOT NULL) THEN
	       l_to_rsv_rec.task_id := l_task_id;
	     ELSE
	       l_to_rsv_rec.task_id := NULL;
	    END IF;
	 END IF;

       END IF;
        /* Added for bug 13829182 */
    ELSIF ( (l_to_rsv_rec.demand_source_type_id = inv_reservation_global.g_source_type_wip) AND (l_pjm_enabled = 1))  THEN
        BEGIN
            SELECT we.entity_type, wdj.maintenance_object_source
                INTO l_wip_entity_id, l_maintenance_object_source
              FROM wip_entities we, wip_discrete_jobs wdj
           WHERE we.wip_entity_id = l_to_rsv_rec.demand_source_header_id
                AND we.wip_entity_id = wdj.wip_entity_id(+);
        EXCEPTION
            WHEN no_data_found THEN
                IF (l_debug = 1) THEN
                    debug_print('No WIP entity record found for the source header passed' );
                END IF;
        END;

        IF l_wip_entity_id = 6 and l_maintenance_object_source = 2  then
             l_wip_entity_type := inv_reservation_global.g_wip_source_type_cmro;
             l_wip_job_type := 'CMRO'; -- AHL
        ELSE
             l_wip_entity_type := null;
             l_wip_job_type := null; -- AHL
        END IF;

        IF ( l_wip_job_type = 'CMRO' AND l_to_rsv_rec.demand_source_line_detail IS NOT NULL)
                AND (l_to_rsv_rec.demand_source_line_detail <> fnd_api.g_miss_num)
                AND ((l_to_rsv_rec.project_id = fnd_api.g_miss_num) OR (l_to_rsv_rec.task_id = fnd_api.g_miss_num)) THEN

                    IF l_to_rsv_rec.demand_source_line_detail = g_sch_mat_id THEN
                            l_project_id := g_project_id;
                            l_task_id    := g_task_id;
                    ELSE
                        BEGIN
                            SELECT wdj.project_id, WDJ.TASK_ID
                                INTO l_project_id, l_task_id
                               FROM ahl_schedule_materials asmt, ahl_workorders aw, WIP_DISCRETE_JOBS WDJ
                            WHERE asmt.scheduled_material_id = l_to_rsv_rec.demand_source_line_detail
                                 AND asmt.visit_task_id           = aw.visit_task_id
                                 AND ASMT.VISIT_ID                = AW.VISIT_ID
                                 AND aw.wip_entity_id             = wdj.wip_entity_id
                                 AND AW.STATUS_CODE              IN ('1','3') -- 1:Unreleased,3:Released
                                 AND ASMT.STATUS                  = 'ACTIVE';
                        EXCEPTION
                            WHEN others THEN
                                IF l_debug=1 THEN
                                    debug_print('Cannot find the project and task information from CMRO WO: '||sqlerrm);
                                END IF;
                        END;
                    END IF;
                    IF (l_to_rsv_rec.project_id = fnd_api.g_miss_num) THEN
                        IF (l_project_id IS NOT NULL ) THEN
                            l_to_rsv_rec.project_id := l_project_id;
                        ELSE
                            l_to_rsv_rec.project_id := NULL;
                        END IF;
                    END IF;

                    IF (l_to_rsv_rec.task_id = fnd_api.g_miss_num) THEN
                        IF (l_task_id IS NOT NULL) THEN
                            l_to_rsv_rec.task_id := l_task_id;
                        ELSE
                            l_to_rsv_rec.task_id := NULL;
                        END IF;
                    END IF;
        END IF;  -- l_wip_job_type = 'CMRO'
        /* End of changes for bug 13829182 */
     ELSE -- not project enable
	  l_to_rsv_rec.project_id := NULL;
	  l_to_rsv_rec.task_id := NULL;
    END IF;
    IF l_debug=1 THEN
       debug_print('After Rsv rec project id: ' || l_to_rsv_rec.project_id);
       debug_print('After Rsv rec task id: ' || l_to_rsv_rec.task_id);
    END IF;
    /*** End R12 ***/


    -- INVCONV - Establish whether item is tracked in dual UOMs
    IF l_orig_rsv_tbl(1).secondary_uom_code is NOT NULL THEN
      l_dual_tracking := TRUE;
    END IF;
    -- INVCONV END
    --MUOM Fulfillment Project
    inv_utilities.get_inv_fulfillment_base(
               p_source_line_id        => l_orig_rsv_tbl(1).demand_source_line_id,
               p_demand_source_type_id =>l_orig_rsv_tbl(1).demand_source_type_id,
               p_org_id                => l_orig_rsv_tbl(1).organization_id,
               x_fulfillment_base      => l_fulfill_base
    );

    --
    -- see whether we are transferring all quantity
    -- or just partial
    IF l_fulfill_base <> 'S' THEN
      l_transfer_all   := (l_orig_rsv_tbl(1).primary_reservation_quantity = l_to_rsv_rec.primary_reservation_quantity);
	ELSE
      l_transfer_all   := (l_orig_rsv_tbl(1).secondary_reservation_quantity = l_to_rsv_rec.secondary_reservation_quantity);
    END IF;

	IF l_fulfill_base = 'S' and l_transfer_all THEN
	  l_to_rsv_rec.primary_reservation_quantity := l_orig_rsv_tbl(1).primary_reservation_quantity;
	END IF;

    /**** {{ R12 Enhanced reservations code changes }}****/
    l_original_serial_count := p_original_serial_number.COUNT;
    l_to_serial_count := p_to_serial_number.COUNT;
    -- set the parameter value to handle serial numbers.
    IF (l_original_serial_count = 0 AND l_to_serial_count = 0) THEN
       l_serial_param := 1;
     ELSIF (l_original_serial_count > 0 AND l_to_serial_count = 0) THEN
       l_serial_param := 2;
     ELSIF (l_original_serial_count = 0 AND l_to_serial_count > 0) THEN
       l_serial_param := 3;
     ELSIF (l_original_serial_count > 0 AND l_to_serial_count > 0) THEN
       l_serial_param := 4;
     ELSE
       -- indeterminate value.error
       IF (l_debug = 1) THEN
	  debug_print('Cannot determine what is being passed to the serial tables');
       END IF;
       fnd_message.set_name('INV', 'INV_INVALID_SERIAL_TABLES');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
       debug_print('Serial Param' || l_serial_param);
       debug_print('Original serial count' || l_original_serial_count);
       debug_print('To serial count' || l_to_serial_count);
    END IF;

    -- if from and to serials are passed, then pass them to the validate API
    IF l_original_serial_count > 0 THEN
       l_original_serial_number := p_original_serial_number;
    END IF;
    IF l_to_serial_count > 0 THEN
       l_to_serial_number := p_to_serial_number;
    END IF;
    /*** End R12 ***/
    IF (l_debug = 1) THEN
       debug_print('Before calling validate');
    END IF;

    IF p_validation_flag = fnd_api.g_true THEN
      -- we do validation after the query because
      -- for transfer, we might have many input value set to
      -- missing. We need to use the actual value to do
      -- validation
       inv_reservation_validate_pvt.validate_input_parameters
	 (
	  x_return_status              => l_return_status
	  , p_orig_rsv_rec               => l_orig_rsv_tbl(1)
	  , p_to_rsv_rec                 => l_to_rsv_rec
	  /**** {{ R12 Enhanced reservations code changes }}****/
	  , p_orig_serial_array          => l_original_serial_number
	  , p_to_serial_array            => l_to_serial_number
	  /*** End R12 ***/
	  , p_rsv_action_name            => 'TRANSFER'
	  , x_orig_item_cache_index      => l_orig_item_cache_index
	  , x_orig_org_cache_index       => l_orig_org_cache_index
	  , x_orig_demand_cache_index    => l_orig_demand_cache_index
	  , x_orig_supply_cache_index    => l_orig_supply_cache_index
	  , x_orig_sub_cache_index       => l_orig_sub_cache_index
	  , x_to_item_cache_index        => l_to_item_cache_index
	  , x_to_org_cache_index         => l_to_org_cache_index
	  , x_to_demand_cache_index      => l_to_demand_cache_index
	  , x_to_supply_cache_index      => l_to_supply_cache_index
	  , x_to_sub_cache_index         => l_to_sub_cache_index
	  );

       --
       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       IF (l_debug = 1) THEN
	  debug_print('After calling validate' || l_return_status);
       END IF;

       /**** {{ R12 Enhanced reservations code changes }}****/
    END IF;

    IF p_validation_flag = fnd_api.g_true AND
      (l_to_rsv_rec.supply_source_type_id = inv_reservation_global.g_source_type_inv) THEN

       /*** End R12 ***/
       -- INVCONV BEGIN
       IF NOT is_lot_divisible(l_orig_item_cache_index) THEN
	  l_lot_divisible_flag := 'N';
	  IF (l_debug = 1) THEN
	     debug_print('Lot indivisible is TRUE ');
	  END IF;
       END IF;
       -- INVCONV END

       inv_quantity_tree_pvt.create_tree
	 (
	  p_api_version_number         => 1.0
	  , p_init_msg_lst               => fnd_api.g_true
	  , x_return_status              => l_return_status
	  , x_msg_count                  => x_msg_count
	  , x_msg_data                   => x_msg_data
	  , p_organization_id            => l_orig_rsv_tbl(1).organization_id
	  , p_inventory_item_id          => l_orig_rsv_tbl(1).inventory_item_id
	  , p_tree_mode                  => inv_quantity_tree_pvt.g_reservation_mode
	  , p_is_revision_control        => is_revision_control(l_orig_item_cache_index)
	  , p_is_lot_control             => is_lot_control(l_orig_item_cache_index)
	  , p_is_serial_control          => is_serial_control(l_orig_item_cache_index)
	  , p_asset_sub_only             => FALSE
	  , p_include_suggestion         => TRUE
	  , p_demand_source_type_id      => l_orig_rsv_tbl(1).demand_source_type_id
	  , p_demand_source_header_id    => l_orig_rsv_tbl(1).demand_source_header_id
	  , p_demand_source_line_id      => l_orig_rsv_tbl(1).demand_source_line_id
	 , p_demand_source_name         => l_orig_rsv_tbl(1).demand_source_name
	 , p_demand_source_delivery     => l_orig_rsv_tbl(1).demand_source_delivery
	 , p_lot_expiration_date        => SYSDATE -- Bug#2716563
	 , x_tree_id                    => l_tree_id1
	 );

       --
       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       --
       inv_quantity_tree_pvt.create_tree
	 (
	  p_api_version_number         => 1.0
	  , p_init_msg_lst               => fnd_api.g_true
	  , x_return_status              => l_return_status
	  , x_msg_count                  => x_msg_count
	  , x_msg_data                   => x_msg_data
	  , p_organization_id            => l_to_rsv_rec.organization_id
	  , p_inventory_item_id          => l_to_rsv_rec.inventory_item_id
	  , p_tree_mode                  => inv_quantity_tree_pvt.g_reservation_mode
	  , p_is_revision_control        => is_revision_control(l_to_item_cache_index)
	  , p_is_lot_control             => is_lot_control(l_to_item_cache_index)
	  , p_is_serial_control          => is_serial_control(l_to_item_cache_index)
	  , p_asset_sub_only             => FALSE
	  , p_include_suggestion         => TRUE
	  , p_demand_source_type_id      => l_to_rsv_rec.demand_source_type_id
	  , p_demand_source_header_id    => l_to_rsv_rec.demand_source_header_id
	  , p_demand_source_line_id      => l_to_rsv_rec.demand_source_line_id
	  , p_demand_source_name         => l_to_rsv_rec.demand_source_name
	 , p_demand_source_delivery     => l_to_rsv_rec.demand_source_delivery
	 , p_lot_expiration_date        => SYSDATE -- Bug#2716563
	 , x_tree_id                    => l_tree_id2
	 );

       --
       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

	   -- MUOM Fulfillment project
	  IF  l_orig_rsv_tbl(1).supply_source_type_id = inv_reservation_global.g_source_type_po
        AND l_to_rsv_rec.supply_source_type_id = inv_reservation_global.g_source_type_inv
        AND l_fulfill_base = 'S' AND l_transfer_all THEN

              inv_quantity_tree_pvt.query_tree(
               p_api_version_number         => 1.0
             , p_init_msg_lst               => fnd_api.g_true
             , x_return_status              => l_return_status
             , x_msg_count                  => x_msg_count
             , x_msg_data                   => x_msg_data
             , p_tree_id                    => l_tree_id2
             , p_revision                   => l_to_rsv_rec.revision
             , p_lot_number                 => l_to_rsv_rec.lot_number
             , p_subinventory_code          => l_to_rsv_rec.subinventory_code
             , p_locator_id                 => l_to_rsv_rec.locator_id
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
             , p_lpn_id                     => l_to_rsv_rec.lpn_id
             );

             l_to_rsv_rec.primary_reservation_quantity := l_atr;
      END IF;
	  -- End MUOM Fulfillment project

       --
       -- INVCONV - upgrade call to incorporate secondaries
       modify_tree_for_update_xfer
	 (
	  x_return_status              => l_return_status
	  , x_quantity_reserved          => l_quantity_reserved
	  , x_secondary_quantity_reserved => l_secondary_quantity_reserved
	  , p_from_tree_id               => l_tree_id1
	  , p_from_supply_source_type_id => l_orig_rsv_tbl(1).supply_source_type_id
	  , p_from_revision              => l_orig_rsv_tbl(1).revision
	  , p_from_lot_number            => l_orig_rsv_tbl(1).lot_number
	  , p_from_subinventory_code     => l_orig_rsv_tbl(1).subinventory_code
	  , p_from_locator_id            => l_orig_rsv_tbl(1).locator_id
	  , p_from_lpn_id                => l_orig_rsv_tbl(1).lpn_id
	  , p_from_primary_rsv_quantity  => l_orig_rsv_tbl(1).primary_reservation_quantity
	  , p_from_second_rsv_quantity   => l_orig_rsv_tbl(1).secondary_reservation_quantity
	  , p_from_detailed_quantity     => l_orig_rsv_tbl(1).detailed_quantity
	  , p_from_sec_detailed_quantity => l_orig_rsv_tbl(1).secondary_detailed_quantity
	  , p_to_tree_id                 => l_tree_id2
	 , p_to_supply_source_type_id   => l_to_rsv_rec.supply_source_type_id
	 , p_to_revision                => l_to_rsv_rec.revision
	 , p_to_lot_number              => l_to_rsv_rec.lot_number
	 , p_to_subinventory_code       => l_to_rsv_rec.subinventory_code
	 , p_to_locator_id              => l_to_rsv_rec.locator_id
	 , p_to_lpn_id                  => l_to_rsv_rec.lpn_id
	 , p_to_primary_rsv_quantity    => l_to_rsv_rec.primary_reservation_quantity
	 , p_to_second_rsv_quantity     => l_to_rsv_rec.secondary_reservation_quantity
	 , p_to_detailed_quantity       => l_to_rsv_rec.detailed_quantity
	 , p_to_second_detailed_quantity => l_to_rsv_rec.secondary_detailed_quantity
	 , p_to_revision_control        => is_revision_control(l_to_item_cache_index)
	 , p_to_lot_control             => is_lot_control(l_to_item_cache_index)
	 , p_action                     => 'TRANSFER'
	 , p_lot_divisible_flag         => l_lot_divisible_flag    -- INVCONV
	 , p_partial_reservation_flag   => fnd_api.g_false
	 , p_check_availability         => fnd_api.g_false
	 );


       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       /**** {{ R12 Enhanced reservations code changes }}****/
     ELSIF (l_to_rsv_rec.supply_source_type_id IN
	    (inv_reservation_global.g_source_type_wip, inv_reservation_global.g_source_type_po,
	     inv_reservation_global.g_source_type_asn,
	     inv_reservation_global.g_source_type_intransit,
	     inv_reservation_global.g_source_type_internal_req,
	     inv_reservation_global.g_source_type_rcv)) AND
       p_over_reservation_flag NOT IN (1,3) THEN

	   --In xdock case, splitting the reservation calls transfer reservation during deliver operation.
	   --However, RTP has already processed and decremented the receiving supply, so the call to
	   --get_supply_reservable_qty is not needed -- Added for bug 9879753 - Start

	   	   IF  (l_original_rsv_rec.supply_source_type_id=inv_reservation_global.g_source_type_rcv
			AND l_to_rsv_rec.supply_source_type_id=inv_reservation_global.g_source_type_rcv
			AND l_original_rsv_rec.external_source_code='XDOCK' AND l_to_rsv_rec.external_source_code='XDOCK') THEN

			NULL;

		   ELSE

       -- call the helper procedure to get the reservable qty of the supply
       -- Bug 5199672: Should pass g_miss_num as default for supply
       -- source line detail. Otherwise, high level reservations
       -- will not be considered.
       get_supply_reservable_qty
         (
            x_return_status                 => l_return_status
          , x_msg_count                     => x_msg_count
          , x_msg_data                      => x_msg_data
          , p_fm_supply_source_type_id      => l_orig_rsv_tbl(1).supply_source_type_id
          , p_fm_supply_source_header_id    => l_orig_rsv_tbl(1).supply_source_header_id
          , p_fm_supply_source_line_id      => l_orig_rsv_tbl(1).supply_source_line_id
          , p_fm_supply_source_line_detail  => l_orig_rsv_tbl(1).supply_source_line_detail
          , p_fm_primary_reservation_qty    => l_orig_rsv_tbl(1).primary_reservation_quantity
          , p_to_supply_source_type_id      => l_to_rsv_rec.supply_source_type_id
          , p_to_supply_source_header_id    => l_to_rsv_rec.supply_source_header_id
          , p_to_supply_source_line_id      => l_to_rsv_rec.supply_source_line_id
          , p_to_supply_source_line_detail  => l_to_rsv_rec.supply_source_line_detail
          , p_to_primary_reservation_qty    => l_to_rsv_rec.primary_reservation_quantity
          , p_to_organization_id            => l_to_rsv_rec.organization_id
          , p_to_inventory_item_id          => l_to_rsv_rec.inventory_item_id
          , p_to_revision                   => l_to_rsv_rec.revision
          , p_to_lot_number                 => l_to_rsv_rec.lot_number
          , p_to_subinventory_code          => l_to_rsv_rec.subinventory_code
          , p_to_locator_id                 => l_to_rsv_rec.locator_id
          , p_to_lpn_id                     => l_to_rsv_rec.lpn_id
          , p_to_project_id                 => l_to_rsv_rec.project_id
          , p_to_task_id                    => l_to_rsv_rec.task_id
	 , x_reservable_qty                => l_quantity_reserved
	 , x_qty_available                 => l_qty_available
         );

       IF (l_debug = 1) THEN
	  debug_print('After calling available supply to reserve ' || l_return_status);
	  debug_print('Available quantity to reserve. l_quantity_reserved: ' || l_quantity_reserved);
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;
       --MUOM Fulfillment Project
       inv_utilities.get_inv_fulfillment_base(
               p_source_line_id        => l_orig_rsv_tbl(1).demand_source_line_id,
               p_demand_source_type_id =>l_orig_rsv_tbl(1).demand_source_type_id,
               p_org_id                => l_orig_rsv_tbl(1).organization_id,
               x_fulfillment_base      => l_fulfill_base
       );

	   IF l_fulfill_base = 'S' AND l_to_rsv_rec.supply_source_type_id <> inv_reservation_global.g_source_type_inv
	   AND l_orig_rsv_tbl(1).supply_source_type_id = inv_reservation_global.g_source_type_inv THEN
	       l_to_rsv_rec.primary_reservation_quantity := inv_convert.inv_um_convert(
                                  item_id                      => l_to_rsv_rec.inventory_item_id
                                , lot_number                   => NULL
                                , organization_id              => l_to_rsv_rec.organization_id
                                , PRECISION                    => NULL -- use default precision
                                , from_quantity                => l_to_rsv_rec.secondary_reservation_quantity
                                , from_unit                    => l_to_rsv_rec.secondary_uom_code
                                , to_unit                      => l_to_rsv_rec.primary_uom_code
                                , from_name                    => NULL -- from uom name
                                , to_name                      => NULL -- to uom name
                                );
	   END IF;

       IF ((l_to_rsv_rec.primary_reservation_quantity - l_quantity_reserved)
	 > 0.000005) THEN

          IF (l_debug = 1) THEN
             debug_print('The supply document doesnt have enough quantity to be reserved against. error out. ');
             debug_print('l_to_rsv_rec.primary_reservation_quantity: ' || l_to_rsv_rec.primary_reservation_quantity);
          END IF;
          fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;

       END IF;
       END IF; --xdock split - Bug 9879753 End
    END IF;

   IF (l_debug = 1) THEN
       debug_print('From record:');
       debug_print('demand_source_type_id = ' || l_orig_rsv_tbl(1).demand_source_type_id);
       debug_print('demand_source_header_id = ' || l_orig_rsv_tbl(1).demand_source_header_id);
       debug_print('demand_source_line_id = ' || l_orig_rsv_tbl(1).demand_source_line_id);
       debug_print('demand_source_line_detail = ' || l_orig_rsv_tbl(1).demand_source_line_detail);
       debug_print('To record:');
       debug_print('demand_source_type_id = ' || l_to_rsv_rec.demand_source_type_id);
       debug_print('demand_source_header_id = ' || l_to_rsv_rec.demand_source_header_id);
       debug_print('demand_source_line_id = ' || l_to_rsv_rec.demand_source_line_id);
       debug_print('demand_source_line_detail = ' || l_to_rsv_rec.demand_source_line_detail);
    END IF;

    IF (l_to_rsv_rec.demand_source_type_id IN
	(inv_reservation_global.g_source_type_wip,
	 inv_reservation_global.g_source_type_oe,
	 inv_reservation_global.g_source_type_internal_ord,
	 inv_reservation_global.g_source_type_rma)) AND
      p_over_reservation_flag NOT IN (2,3) THEN
       -- call the helper procedure to get the reservable qty of the demand
       -- Bug 5199672: Should pass g_miss_num as default for demand
       -- source line detail. Otherwise, high level reservations
       -- will not be considered.

       IF (l_fulfill_base = 'S') THEN
           l_org_sec_rsv_qty :=l_orig_rsv_tbl(1).secondary_reservation_quantity;  -- MUOM fulfillment Project
      ELSE
           l_org_sec_rsv_qty:=null;
      END IF;
       --
       IF (l_debug = 1) THEN
         debug_print('l_org_sec_rsv_qty : ' || l_org_sec_rsv_qty);
       END IF;
        --
       get_demand_reservable_qty
         (
            x_return_status                 => l_return_status
          , x_msg_count                     => x_msg_count
          , x_msg_data                      => x_msg_data
          , p_fm_demand_source_type_id      => l_orig_rsv_tbl(1).demand_source_type_id
          , p_fm_demand_source_header_id    => l_orig_rsv_tbl(1).demand_source_header_id
          , p_fm_demand_source_line_id      => l_orig_rsv_tbl(1).demand_source_line_id
          , p_fm_demand_source_line_detail  => l_orig_rsv_tbl(1).demand_source_line_detail
          , p_fm_primary_reservation_qty    => l_orig_rsv_tbl(1).primary_reservation_quantity
          , p_fm_secondary_reservation_qty  => l_org_sec_rsv_qty
          , p_to_demand_source_type_id      => l_to_rsv_rec.demand_source_type_id
          , p_to_demand_source_header_id    => l_to_rsv_rec.demand_source_header_id
          , p_to_demand_source_line_id      => l_to_rsv_rec.demand_source_line_id
          , p_to_demand_source_line_detail  => l_to_rsv_rec.demand_source_line_detail
          , p_to_primary_reservation_qty    => l_to_rsv_rec.primary_reservation_quantity
          , p_to_organization_id            => l_to_rsv_rec.organization_id
          , p_to_inventory_item_id          => l_to_rsv_rec.inventory_item_id
          , p_to_primary_uom_code           => l_to_rsv_rec.primary_uom_code
          , p_to_project_id                 => l_to_rsv_rec.project_id
          , p_to_task_id                    => l_to_rsv_rec.task_id
	  , x_reservable_qty       => l_quantity_reserved
	  , x_qty_available         => l_qty_available
	  , x_reservable_qty2     => l_quantity_reserved2
          , x_qty_available2        => l_qty_available2
          );

       IF (l_debug = 1) THEN
	  debug_print('After calling available demand to reserve ' || l_return_status);
	  debug_print('Available quantity to reserve. l_quantity_reserved: ' || l_quantity_reserved);
	  debug_print('Available quantity to reserve. l_quantity_reserved2: ' || l_quantity_reserved2);
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
       END IF;

       --
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

      --Bug 12978409 : start
       -- Bug 5199672: Removed the condition l_qty_changed > 0
      /*  IF ((l_to_rsv_rec.primary_reservation_quantity - l_quantity_reserved)
                 > 0.000005) THEN */
          get_reservation_qty_lot(
                  p_rsv_rec              => l_to_rsv_rec,
                  p_reservation_qty_lot  => l_reservation_qty_lot);
      -- MUOM fulfillment Project
      IF (l_fulfill_base = 'S') THEN

	IF((l_reservation_qty_lot-l_quantity_reserved2)>0.000005) THEN
	  --
          IF (l_debug = 1) THEN
            debug_print('The demand document doesnt have enough quantity to be reserved against. error out. for fulfilment base=S ');
            debug_print('l_quantity_reserved2 : ' || l_quantity_reserved2);
            debug_print('l_reservation_qty_lot : ' || l_reservation_qty_lot);
          END IF;
          fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        END IF;
      ELSE
        IF ((l_reservation_qty_lot - l_quantity_reserved) > 0.000005) THEN
          IF (l_debug = 1) THEN
            debug_print('The demand document doesnt have enough quantity to be reserved against. error out. ');
            debug_print('l_to_rsv_rec.primary_reservation_quantity: ' || l_to_rsv_rec.primary_reservation_quantity);
          END IF;
          fnd_message.set_name('INV', 'INV_INVALID_AVAILABLE_QTY');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        END IF;
      END IF;
      -- MUOM fulfillment Project
      END IF;
    /*** End R12 ***/

    IF (l_debug = 1) THEN
       debug_print('After calling create/modify tree ' || l_return_status);
    END IF;

    -- obtain program and user info
    l_date := SYSDATE;

    --
    l_user_id        := fnd_global.user_id;
    l_login_id       := fnd_global.login_id;

    IF l_login_id = -1 THEN
      l_login_id  := fnd_global.conc_login_id;
    END IF;

    l_request_id     := fnd_global.conc_request_id;
    l_prog_appl_id   := fnd_global.prog_appl_id;
    l_program_id     := fnd_global.conc_program_id;

    --
    --  actions based on l_transfer_all and l_to_row_exist
    --  l_transfer_all    l_to_row_exist     from row            to row
    --    true                true            delete             add qty
    --    true                false           update all but id  nothing
    --    false               true            reduce qty         add qty
    --    false               false           reduce qty         create
    --
    -- for from row
    IF l_transfer_all = FALSE THEN
       IF (l_debug = 1) THEN
          debug_print('Transfer all is false');
       END IF;
      -- Pre Update CTO Validation
      IF l_orig_rsv_tbl(1).demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
	 --
	IF (l_debug = 1) THEN
           debug_print('Before calling cto work flow unresv check');
        END IF;
        cto_workflow_api_pk.inventory_unreservation_check(
          p_order_line_id              => l_orig_rsv_tbl(1).demand_source_line_id
        , p_rsv_quantity               => l_to_rsv_rec.primary_reservation_quantity
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        --
        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
	--
	IF (l_debug = 1) THEN
           debug_print('After calling cto work flow unresv check');
        END IF;
      END IF;

      -- I don't call the table handler since only the quantities are changed
      -- along with who columns

      /*
      ** Include detailed quantity too in the update...
      */

      IF (l_orig_rsv_tbl(1).detailed_quantity IS NULL) THEN
        l_detailed_quantity  := NULL;
      END IF;

      IF (l_orig_rsv_tbl(1).detailed_quantity = 0) THEN
        l_detailed_quantity  := 0;
      END IF;

      IF (l_orig_rsv_tbl(1).detailed_quantity > 0) THEN
        l_detailed_quantity  := l_orig_rsv_tbl(1).detailed_quantity - l_to_rsv_rec.primary_reservation_quantity;

        -- INVCONV BEGIN -  populate secondary for dual tracked item
        IF l_dual_tracking THEN

          /* Fix for Bug#12837088 . Calculate secondary from primary as mathematical subtraction can be negative or out of deviation */
         /* uncommenting the fix done for Bug#12837088 MUOM Fulfillment Project*/
		  l_primary_uom_code   := l_to_rsv_rec.primary_uom_code; -- 13604458
          l_secondary_detailed_quantity  :=
             l_orig_rsv_tbl(1).secondary_detailed_quantity - l_to_rsv_rec.secondary_reservation_quantity;

		  --BUG12622871
			IF (l_debug = 1) THEN
			debug_print(' Adding debug msg before UOM convert place 1');
			debug_print(' Value of item id is '||To_char(l_orig_rsv_tbl(1).inventory_item_id));
			debug_print(' Value of lot is '||To_char(l_orig_rsv_tbl(1).lot_number));
			debug_print(' Value of org is '||To_char(l_orig_rsv_tbl(1).organization_id));
			debug_print(' Value of l_detailed_quantity is '||To_char(l_detailed_quantity));
			debug_print(' Value of l_primary_uom_code is '||To_char(l_primary_uom_code));
			debug_print(' Value of l_orig_rsv_tbl(1).secondary_uom_code is '||to_char(l_orig_rsv_tbl(1).secondary_uom_code));
			END IF;

			IF(NVL(l_detailed_quantity,0) <> 0) THEN
			  IF(l_secondary_detailed_quantity <0) THEN -- MUOM Fulfillment Project
				l_secondary_detailed_quantity  := inv_convert.inv_um_convert(
                                 item_id                   => l_orig_rsv_tbl(1).inventory_item_id
                               , lot_number             => l_orig_rsv_tbl(1).lot_number
                               , organization_id        => l_orig_rsv_tbl(1).organization_id
                               , PRECISION            => NULL -- use default precision
                               , from_quantity           => l_detailed_quantity
                               , from_unit                  => l_primary_uom_code
                               , to_unit                      => l_orig_rsv_tbl(1).secondary_uom_code
                               , from_name                => NULL -- from uom name
                               , to_name                     => NULL -- to uom name
                               );

							   /* Start 13604458 */
                           IF (l_secondary_detailed_quantity  = -99999) THEN
                               -- conversion failed
                              IF (l_debug = 1) THEN
                                  debug_print('Conversion to SECONDARY UOM Failed');
                              END IF;
                              fnd_message.set_name('INV', 'INV_INVALID_UOM_CONV');
                              fnd_message.set_token('VALUE1', l_orig_rsv_tbl(1).secondary_uom_code);
                              fnd_message.set_token('VALUE2', l_primary_uom_code);
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_error;
                           END IF;
                           /* End 13604458 */
			  END IF;
			ELSE
				IF(l_detailed_quantity IS NULL) THEN
					l_secondary_detailed_quantity := NULL;
				ELSE
					l_secondary_detailed_quantity := 0;
				END IF;
			END IF;

			IF (l_debug = 1) THEN
		        	debug_print(' Value of l_secondary_detailed_quantity after uom convert1  is'||To_char(l_secondary_detailed_quantity));
			END IF;
        END IF;
        -- INVCONV END

        IF (l_detailed_quantity < 0) THEN
          l_detailed_quantity  := 0;
          -- INVCONV BEGIN
          IF l_dual_tracking THEN
            l_secondary_detailed_quantity  := 0;
          END IF;
          -- INVCONV END
        END IF;
      END IF;

      --bug 2186857
      --The update statement below did a straight subtraction of the
      -- to rsv qty from the original rsv qty.  However, this did not take
      -- into account that the two reservations could have different
      -- reservation UOMs.  So, before the update, we must determine
      -- the new original reservation qty
      l_new_orig_prim_qty  := l_orig_rsv_tbl(1).primary_reservation_quantity - l_to_rsv_rec.primary_reservation_quantity;
      l_primary_uom_code   := l_to_rsv_rec.primary_uom_code;

      IF l_orig_rsv_tbl(1).reservation_uom_code IS NULL THEN
        l_reservation_uom_code  := l_primary_uom_code;
      ELSE
        l_reservation_uom_code  := l_orig_rsv_tbl(1).reservation_uom_code;
      END IF;

	   --MUOM Fulfillment Project
            inv_utilities.get_inv_fulfillment_base(
                      p_source_line_id        => l_orig_rsv_tbl(1).demand_source_line_id,
                      p_demand_source_type_id =>l_orig_rsv_tbl(1).demand_source_type_id,
                      p_org_id                => l_orig_rsv_tbl(1).organization_id,
                      x_fulfillment_base      => l_fulfill_base
             );

      IF l_primary_uom_code <> l_reservation_uom_code and l_fulfill_base <> 'S' THEN
        -- INVCONV - Upgrade call to inv_um_convert to pass lot and org
        l_new_orig_rsv_qty  := inv_convert.inv_um_convert(
                                 item_id                      => l_orig_rsv_tbl(1).inventory_item_id
                               , lot_number                   => l_orig_rsv_tbl(1).lot_number
                               , organization_id              => l_orig_rsv_tbl(1).organization_id
                               , PRECISION                    => NULL -- use default precision
                               , from_quantity                => l_new_orig_prim_qty
                               , from_unit                    => l_primary_uom_code
                               , to_unit                      => l_reservation_uom_code
                               , from_name                    => NULL -- from uom name
                               , to_name                      => NULL -- to uom name
                               );

        IF l_new_orig_rsv_qty = -99999 THEN
          -- conversion failed
          fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-PRIMARY-UOM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
	   -- MUOM Fulfillment project
      ELSIF l_orig_rsv_tbl(1).reservation_uom_code = l_orig_rsv_tbl(1).secondary_uom_code AND l_fulfill_base = 'S' THEN
        l_new_orig_rsv_qty  := l_orig_rsv_tbl(1).secondary_reservation_quantity - NVL(l_to_rsv_rec.secondary_reservation_quantity,0);
	  ELSIF l_orig_rsv_tbl(1).reservation_uom_code <> l_primary_uom_code AND l_orig_rsv_tbl(1).reservation_uom_code <> l_orig_rsv_tbl(1).secondary_uom_code AND l_fulfill_base = 'S' THEN
             l_new_orig_rsv_qty    := inv_convert.inv_um_convert(
                                        item_id          => l_orig_rsv_tbl(1).inventory_item_id
                                      , lot_number       => l_orig_rsv_tbl(1).lot_number
                                      , organization_id  => l_orig_rsv_tbl(1).organization_id
                                      , precision        => null
                                      , from_quantity    => l_orig_rsv_tbl(1).secondary_reservation_quantity - NVL(l_to_rsv_rec.secondary_reservation_quantity,0)
                                      , from_unit        => l_orig_rsv_tbl(1).secondary_uom_code
                                      , to_unit          => l_orig_rsv_tbl(1).reservation_uom_code
                                      , from_name        => NULL
                                      , to_name          => NULL
                                       );
      ELSE
        l_new_orig_rsv_qty  := l_new_orig_prim_qty;
      END IF;

      -- INVCONV BEGIN
      IF l_dual_tracking THEN

       /* Fix for Bug#12837088 . Calculate secondary from primary as mathematical subtraction can be negative or out of deviation */
       -- 13604458 Calculate secondary only when l_orig_second_rsv_qty is negative
       l_orig_second_rsv_qty :=
         l_orig_rsv_tbl(1).secondary_reservation_quantity - NVL(l_to_rsv_rec.secondary_reservation_quantity,0);

		--BUG12622871
			IF (l_debug = 1) THEN
			debug_print(' Adding debug msg before UOM convert place 2');
			debug_print(' Value of item id is '||To_char(l_orig_rsv_tbl(1).inventory_item_id));
			debug_print(' Value of lot is '||To_char(l_orig_rsv_tbl(1).lot_number));
			debug_print(' Value of org is '||To_char(l_orig_rsv_tbl(1).organization_id));
			debug_print(' Value of l_new_orig_rsv_qty is '||To_char(l_new_orig_rsv_qty));
			debug_print(' Value of l_primary_uom_codeis '||To_char(l_primary_uom_code));
			debug_print(' Value of l_orig_rsv_tbl(1).secondary_uom_code is '||To_char(l_orig_rsv_tbl(1).secondary_uom_code));
			END IF;

		IF(l_orig_rsv_tbl(1).reservation_uom_code = l_orig_rsv_tbl(1).secondary_uom_code) THEN
			l_orig_second_rsv_qty := l_new_orig_rsv_qty;
		ELSE
		             -- 13604458. Calculate secondary only when l_orig_second_rsv_qty  is negative
                    IF (l_orig_second_rsv_qty < 0 ) THEN
			         l_orig_second_rsv_qty  := inv_convert.inv_um_convert(
                                 item_id                      => l_orig_rsv_tbl(1).inventory_item_id
                               , lot_number                   => l_orig_rsv_tbl(1).lot_number
                               , organization_id              => l_orig_rsv_tbl(1).organization_id
                               , PRECISION                    => NULL -- use default precision
                               , from_quantity                => l_new_orig_rsv_qty
                               , from_unit                    => l_primary_uom_code
                               , to_unit                      => l_orig_rsv_tbl(1).secondary_uom_code
                               , from_name                    => NULL -- from uom name
                               , to_name                      => NULL -- to uom name
                               );
							/* Start 13604458 */
                         IF (l_orig_second_rsv_qty  = -99999) THEN
                               -- conversion failed
                              IF (l_debug = 1) THEN
                                  debug_print('Conversion to SECONDARY UOM Failed');
                              END IF;
                              fnd_message.set_name('INV', 'INV_INVALID_UOM_CONV');
                              fnd_message.set_token('VALUE1', l_orig_rsv_tbl(1).secondary_uom_code);
                              fnd_message.set_token('VALUE2', l_primary_uom_code);
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_error;
                         END IF;
                         /* End 13604458 */
				  END IF;
		END IF;

			IF (l_debug = 1) THEN
			debug_print(' Value of l_orig_second_rsv_qty after uom convert is'||To_char(l_orig_second_rsv_qty));
			END IF;

      END IF;
      -- INVCONV END

      --Bug #2819700
      --Adding an extra check to make sure that tranfer reservations does not
      -- update the original reservation record to a NEGATIVE NUMBER.
      IF (l_debug = 1) THEN
        debug_print('Primary_reservation_qty before inserting (xfer)= '
		                || To_char(l_new_orig_prim_qty) );
        debug_print('Secondary_reservation_qty before inserting (xfer)= '
                                || To_char(l_orig_second_rsv_qty) );        -- INVCONV
        debug_print('Reservation_qty before inserting (xfer)= '
		                || To_char(l_new_orig_rsv_qty) );
      END IF;

      IF (  (NVL(l_new_orig_rsv_qty,0) < 0) OR
	          (NVL(l_new_orig_prim_qty,0) < 0) ) THEN
        fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

       -- INVCONV BEGIN
      IF (NVL(l_orig_second_rsv_qty,0) < 0) THEN
        fnd_message.set_name('INV', 'INV-INVALID NEGATIVE SECONDARY'); -- INVCONV New Message
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      -- INVCONV END
      -- Bug 3461990: Reservations API should not update reservations with more
      -- than 5 decimal places, since the transaction quantity is being
      -- rounded to 5 decimal places.

      l_new_orig_prim_qty :=
	round(l_new_orig_prim_qty,5);
      -- INVCONV BEGIN
      IF l_dual_tracking THEN
        l_orig_second_rsv_qty :=
          round(l_orig_second_rsv_qty,5);
      END IF;
      -- INVCONV END

      l_new_orig_rsv_qty :=
	round(l_new_orig_rsv_qty,5);
      l_detailed_quantity  :=
	round(Nvl(l_detailed_quantity,0),5);


      IF (l_debug = 1) THEN
	 debug_print(' Transfer: Before updating from record');
	 debug_print(' After rounding reservation is' || l_orig_rsv_tbl(1).reservation_id);
	 debug_print(' After rounding reservation qty' || l_new_orig_rsv_qty);
	 debug_print(' After rounding reservation pri qty' || l_new_orig_prim_qty);
         debug_print(' After rounding reservation sec qty' || l_orig_second_rsv_qty);
	 debug_print(' After rounding detailed quantity' || l_detailed_quantity);
      END IF;

      -- INVCONV - Incorporate secondary_reservation_quantity
      UPDATE mtl_reservations
         SET primary_reservation_quantity = l_new_orig_prim_qty
           , secondary_reservation_quantity = l_orig_second_rsv_qty
           , reservation_quantity = l_new_orig_rsv_qty
           , detailed_quantity = l_detailed_quantity
           , secondary_detailed_quantity = l_secondary_detailed_quantity           --bug 8448053  kbanddyo
           , last_update_date = l_date
           , last_updated_by = l_user_id
           , last_update_login = l_login_id
           , request_id = l_request_id
           , program_application_id = l_prog_appl_id
           , program_id = l_program_id
           , program_update_date = l_date
       WHERE reservation_id = l_orig_rsv_tbl(1).reservation_id;

      -- for data sync b/w mtl_demand and mtl_reservations
      inv_rsv_synch.for_update(p_reservation_id => l_orig_rsv_tbl(1).reservation_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --
    /** Commented out by request of CTO.  This was causing an extra
     *  update to the workflow that was causing problems.
     *  Bug 2073768
     *  This code was not interacting correctly with CTO.
     *  No longer call the wf_update_after_inv_unreserv api from
     *  transfer_reservation
     *-- Post Update CTO Validation
     * IF l_orig_rsv_tbl(1).demand_source_type_id in (
     *    inv_reservation_global.g_source_type_oe
     *         ,inv_reservation_global.g_source_type_internal_ord
     *         ,inv_reservation_global.g_source_type_rma) THEN
     *     --
     *     cto_workflow_api_pk.wf_update_after_inv_unreserv(
     *       p_order_line_id      => l_orig_rsv_tbl(1).demand_source_line_id
     *     , x_return_status      => l_return_status
     *     , x_msg_count          => x_msg_count
     *     , x_msg_data           => x_msg_data
     *     );
     *     --
     *     IF l_return_status = fnd_api.g_ret_sts_error THEN
     *      RAISE fnd_api.g_exc_error;
     *    END IF ;
     *     --
     *     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
     *      RAISE fnd_api.g_exc_unexpected_error;
     *    END IF;
     *     --
     * END IF;
     */
       ELSIF l_to_row_exist = TRUE THEN
       IF (l_debug = 1) THEN
          debug_print('To row exists and transfer all is true');
       END IF;
       -- Pre Delete CTO Validation
      IF l_orig_rsv_tbl(1).demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
        --
        cto_workflow_api_pk.inventory_unreservation_check(
          p_order_line_id              => l_orig_rsv_tbl(1).demand_source_line_id
        , p_rsv_quantity               => l_to_rsv_rec.primary_reservation_quantity
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        --
        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      --
      END IF;

      -- for data sync b/w mtl_demand and mtl_reservations
      inv_rsv_synch.for_delete(p_reservation_id => l_orig_rsv_tbl(1).reservation_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- 2884492
       mtl_reservations_pkg.delete_row
	(x_reservation_id => l_orig_rsv_tbl(1).reservation_id
	,x_to_reservation_id => l_to_rsv_tbl(1).reservation_id);
    /** commented out by request of CTO.  The workflow was not processing
     *  correctly.
     *  Bug 2073768
     *  This code was not interacting correctly with CTO.
     *  No longer call the wf_update_after_inv_unreserv api from
     *  transfer_reservation
     *-- Post Delete CTO Validation
     * IF l_orig_rsv_tbl(1).demand_source_type_id in (
     *    inv_reservation_global.g_source_type_oe
     *          ,inv_reservation_global.g_source_type_internal_ord
     *          ,inv_reservation_global.g_source_type_rma) THEN
     *     --
     *     cto_workflow_api_pk.wf_update_after_inv_unreserv(
     *       p_order_line_id      => l_orig_rsv_tbl(1).demand_source_line_id
     *     , x_return_status      => l_return_status
     *     , x_msg_count          => x_msg_count
     *     , x_msg_data           => x_msg_data
     *     );
     *     --
     *     IF l_return_status = fnd_api.g_ret_sts_error THEN
     *      RAISE fnd_api.g_exc_error;
     *    END IF ;
     *     --
     *     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
     *      RAISE fnd_api.g_exc_unexpected_error;
     *    END IF;
     *     --
     * END IF;
     */
       ELSE
       IF (l_debug = 1) THEN
          debug_print('To row does not exist and transfer all is true');
       END IF;
      -- Pre Update CTO Validation
      IF l_orig_rsv_tbl(1).demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
        --
        cto_workflow_api_pk.inventory_unreservation_check(
          p_order_line_id              => l_orig_rsv_tbl(1).demand_source_line_id
        , p_rsv_quantity               => l_orig_rsv_tbl(1).primary_reservation_quantity
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        --
        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      --
      END IF;

      -- Added for bug 2458523
      -- Pre Insert CTO Validation
      IF l_to_rsv_rec.demand_source_type_id IN
	(inv_reservation_global.g_source_type_oe,
	 inv_reservation_global.g_source_type_internal_ord,
	 inv_reservation_global.g_source_type_rma) THEN

        --
        cto_workflow_api_pk.inventory_reservation_check(
          p_order_line_id              => l_to_rsv_rec.demand_source_line_id
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        --
        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      --
      END IF;

      --Bug #2819700
      --Adding an extra check to make sure that tranfer reservations does not
      -- update the to reservation record to a NEGATIVE NUMBER.
      IF (l_debug = 1) THEN
        debug_print('Primary_reservation_qty before inserting (xfer)= '
		                || To_char(l_to_rsv_rec.primary_reservation_quantity) );
        debug_print('Secondary_reservation_qty before inserting (xfer)= '
                                || To_char(l_to_rsv_rec.secondary_reservation_quantity) );   -- INVCONV
        debug_print('Reservation_qty before inserting (xfer)= '
		                || To_char(l_to_rsv_rec.reservation_quantity) );
      END IF;

      IF (  (NVL(l_to_rsv_rec.reservation_quantity,0) < 0) OR
	    (NVL(l_to_rsv_rec.primary_reservation_quantity,0) < 0) ) THEN
	 fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

       -- INVCONV BEGIN
      IF (NVL(l_to_rsv_rec.secondary_reservation_quantity,0) < 0) THEN
         fnd_message.set_name('INV', 'INV-INVALID NEGATIVE SECONDARY'); -- INVCONV New Message
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
      -- INVCONV END

      -- Bug 3461990: Reservations API should not update reservations with more
      -- than 5 decimal places, since the transaction quantity is being
      -- rounded to 5 decimal places.

      l_to_rsv_rec.primary_reservation_quantity :=
	round(l_to_rsv_rec.primary_reservation_quantity,5);

      -- INVCONV BEGIN
      IF l_dual_tracking THEN
        l_to_rsv_rec.secondary_reservation_quantity :=
          round(l_to_rsv_rec.secondary_reservation_quantity,5);
      END IF;
      -- INVCONV END

      l_to_rsv_rec.reservation_quantity :=
	round(l_to_rsv_rec.reservation_quantity,5);
      l_to_rsv_rec.detailed_quantity  :=
	round(Nvl(l_to_rsv_rec.detailed_quantity,0),5);


      IF (l_debug = 1) THEN
	 debug_print(' Transfer: Before updating all but id for the from record');
	 debug_print(' After rounding reservation is' || l_orig_rsv_tbl(1).reservation_id);
	 debug_print(' After rounding reservation qty' || l_to_rsv_rec.reservation_quantity);
	 debug_print(' After rounding reservation pri qty' || l_to_rsv_rec.primary_reservation_quantity);
	 debug_print(' After rounding detailed quantity' ||l_to_rsv_rec.detailed_quantity );
      END IF;

      -- INVCONV - Incorporate secondaries in update
      mtl_reservations_pkg.update_row
	(
	 x_reservation_id             => l_orig_rsv_tbl(1).reservation_id
	 , x_requirement_date           => l_to_rsv_rec.requirement_date
	 , x_organization_id            => l_to_rsv_rec.organization_id
	 , x_inventory_item_id          => l_to_rsv_rec.inventory_item_id
	 , x_demand_source_type_id      => l_to_rsv_rec.demand_source_type_id
	 , x_demand_source_header_id    => l_to_rsv_rec.demand_source_header_id
	 , x_demand_source_line_id      => l_to_rsv_rec.demand_source_line_id
	 , x_demand_source_name         => l_to_rsv_rec.demand_source_name
	 , x_demand_source_delivery     => l_to_rsv_rec.demand_source_delivery
	 , x_primary_uom_code           => l_to_rsv_rec.primary_uom_code
	 , x_primary_uom_id             => l_to_rsv_rec.primary_uom_id
	 , x_secondary_uom_code         => l_to_rsv_rec.secondary_uom_code
	 , x_secondary_uom_id           => l_to_rsv_rec.secondary_uom_id
	 , x_reservation_uom_code       => l_to_rsv_rec.reservation_uom_code
	 , x_reservation_uom_id         => l_to_rsv_rec.reservation_uom_id
	, x_reservation_quantity       => l_to_rsv_rec.reservation_quantity
	, x_primary_reservation_quantity=> l_to_rsv_rec.primary_reservation_quantity
	, x_second_reservation_quantity=> l_to_rsv_rec.secondary_reservation_quantity
	, x_detailed_quantity          => l_to_rsv_rec.detailed_quantity
	, x_secondary_detailed_quantity=> l_to_rsv_rec.secondary_detailed_quantity
	, x_autodetail_group_id        => l_to_rsv_rec.autodetail_group_id
	, x_external_source_code       => l_to_rsv_rec.external_source_code
	, x_external_source_line_id    => l_to_rsv_rec.external_source_line_id
	, x_supply_source_type_id      => l_to_rsv_rec.supply_source_type_id
	, x_supply_source_header_id    => l_to_rsv_rec.supply_source_header_id
	, x_supply_source_line_id      => l_to_rsv_rec.supply_source_line_id
	, x_supply_source_name         => l_to_rsv_rec.supply_source_name
	, x_supply_source_line_detail  => l_to_rsv_rec.supply_source_line_detail
	, x_revision                   => l_to_rsv_rec.revision
	, x_subinventory_code          => l_to_rsv_rec.subinventory_code
	, x_subinventory_id            => l_to_rsv_rec.subinventory_id
	, x_locator_id                 => l_to_rsv_rec.locator_id
	, x_lot_number                 => l_to_rsv_rec.lot_number
	, x_lot_number_id              => l_to_rsv_rec.lot_number_id
	, x_serial_number              => NULL
	, x_serial_number_id           => NULL
	, x_partial_quantities_allowed => NULL
	, x_auto_detailed              => NULL
	, x_pick_slip_number           => l_to_rsv_rec.pick_slip_number
	, x_lpn_id                     => l_to_rsv_rec.lpn_id
	, x_last_update_date           => l_date
	, x_last_updated_by            => l_user_id
	, x_last_update_login          => l_login_id
	, x_request_id                 => l_request_id
	, x_program_application_id     => l_prog_appl_id
	, x_program_id                 => l_program_id
	, x_program_update_date        => l_date
	, x_attribute_category         => l_to_rsv_rec.attribute_category
	, x_attribute1                 => l_to_rsv_rec.attribute1
	, x_attribute2                 => l_to_rsv_rec.attribute2
	, x_attribute3                 => l_to_rsv_rec.attribute3
	, x_attribute4                 => l_to_rsv_rec.attribute4
	, x_attribute5                 => l_to_rsv_rec.attribute5
	, x_attribute6                 => l_to_rsv_rec.attribute6
	, x_attribute7                 => l_to_rsv_rec.attribute7
	, x_attribute8                 => l_to_rsv_rec.attribute8
	, x_attribute9                 => l_to_rsv_rec.attribute9
	, x_attribute10                => l_to_rsv_rec.attribute10
	, x_attribute11                => l_to_rsv_rec.attribute11
	, x_attribute12                => l_to_rsv_rec.attribute12
	, x_attribute13                => l_to_rsv_rec.attribute13
	, x_attribute14                => l_to_rsv_rec.attribute14
	, x_attribute15                => l_to_rsv_rec.attribute15
	, x_ship_ready_flag            => l_to_rsv_rec.ship_ready_flag
	, x_staged_flag                => l_to_rsv_rec.staged_flag
	/**** {{ R12 Enhanced reservations code changes }}****/
	, x_crossdock_flag             => l_to_rsv_rec.crossdock_flag
	, x_crossdock_criteria_id      => l_to_rsv_rec.crossdock_criteria_id
	, x_demand_source_line_detail  => l_to_rsv_rec.demand_source_line_detail
	, x_serial_reservation_quantity => l_to_rsv_rec.serial_reservation_quantity
	, x_supply_receipt_date        => l_to_rsv_rec.supply_receipt_date
	, x_demand_ship_date           => l_to_rsv_rec.demand_ship_date
	, x_project_id                 => l_to_rsv_rec.project_id
	, x_task_id                    => l_to_rsv_rec.task_id
	/*** End R12 ***/
	);
      --
      -- for data sync b/w mtl_demand and mtl_reservations
      inv_rsv_synch.for_update(p_reservation_id => l_orig_rsv_tbl(1).reservation_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

      debug_print(' return status after updating row' || l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- since to row not exists, transfer all
      x_reservation_id  := l_orig_rsv_tbl(1).reservation_id;

      IF l_orig_rsv_tbl(1).demand_source_type_id = 2   -- Bug 6195783 : Begin
      AND l_to_rsv_rec.demand_source_type_id = 9
      AND l_orig_rsv_tbl(1).primary_reservation_quantity = l_to_rsv_rec.primary_reservation_quantity THEN
         cto_workflow_api_pk.wf_update_after_inv_unreserv(
         p_order_line_id      => l_orig_rsv_tbl(1).demand_source_line_id
         , x_return_status      => l_return_status
         , x_msg_count          => x_msg_count
         , x_msg_data           => x_msg_data
         );
      END IF;                                          -- Bug 6195783 : End

    /** commented out by request of CTO.  Their workflow was not
     *  progressing properly
     *  Bug 2073768
     *  This code was not interacting correctly with CTO.
     *  No longer call the wf_update_after_inv_unreserv api from
     *  transfer_reservation
     *-- Post Update CTO Validation
     * IF l_orig_rsv_tbl(1).demand_source_type_id in (
     *    inv_reservation_global.g_source_type_oe
     *          ,inv_reservation_global.g_source_type_internal_ord
     *          ,inv_reservation_global.g_source_type_rma) THEN
     *     --
     *     cto_workflow_api_pk.wf_update_after_inv_unreserv(
     *       p_order_line_id      => l_orig_rsv_tbl(1).demand_source_line_id
     *     , x_return_status      => l_return_status
     *     , x_msg_count          => x_msg_count
     *     , x_msg_data           => x_msg_data
     *     );
     *     --
     *     IF l_return_status = fnd_api.g_ret_sts_error THEN
     *      RAISE fnd_api.g_exc_error;
     *    END IF ;
     *     --
     *     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
     *      RAISE fnd_api.g_exc_unexpected_error;
     *    END IF;
     *     --
     * END IF;
     */
    END IF;

    --
     IF l_to_row_exist = TRUE THEN
	IF (l_debug = 1) THEN
           debug_print('To row does exists');
        END IF;

      /* Commenting out call to CTO inventory_unreservation_check API. This
	API has already been called in the previous if then else. This
	  issue has been reported in bug 2458523
      -- Pre Update CTO Validation
      IF l_to_rsv_rec.demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
        --
        cto_workflow_api_pk.inventory_unreservation_check(
          p_order_line_id              => l_to_rsv_rec.demand_source_line_id
        , p_rsv_quantity               => l_to_rsv_rec.primary_reservation_quantity
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        --
        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      --
      END IF;
      */

      -- Added for bug 2458523
      -- Pre Insert CTO Validation
      IF l_to_rsv_rec.demand_source_type_id IN
	  (inv_reservation_global.g_source_type_oe,
	   inv_reservation_global.g_source_type_internal_ord,
	   inv_reservation_global.g_source_type_rma) THEN

        --
        cto_workflow_api_pk.inventory_reservation_check(
          p_order_line_id              => l_to_rsv_rec.demand_source_line_id
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        --
        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      --
      END IF;

      l_primary_rsv_quantity := 0;
      l_rsv_quantity := 0;

       -- INVCONV - Retrieve secondaries
      SELECT  primary_reservation_quantity, secondary_reservation_quantity, reservation_quantity
      INTO    l_primary_rsv_quantity, l_secondary_rsv_quantity, l_rsv_quantity
            FROM    mtl_reservations
      WHERE   reservation_id = l_to_rsv_tbl(1).reservation_id;

      l_primary_rsv_quantity := l_primary_rsv_quantity + l_to_rsv_rec.primary_reservation_quantity;

       -- INVCONV BEGIN
      IF l_dual_tracking THEN
        l_secondary_rsv_quantity :=l_secondary_rsv_quantity + l_to_rsv_rec.secondary_reservation_quantity;
      END IF;
      -- INVCONV END

      l_rsv_quantity :=l_rsv_quantity + l_to_rsv_rec.reservation_quantity;

      --Bug #2819700
      --Adding an extra check to make sure that tranfer reservations does not
      --update the to reservation record to a NEGATIVE NUMBER.
      IF (l_debug = 1) THEN
        debug_print('Primary_reservation_qty before inserting (xfer)= ' || To_char(l_primary_rsv_quantity) );
        debug_print('Secondary_reservation_qty before inserting (xfer)= ' || To_char(l_secondary_rsv_quantity) ); --INVCONV
        debug_print('Rreservation_qty before inserting (xfer)= ' ||To_char(l_rsv_quantity));
      END IF;

      IF (  (NVL(l_primary_rsv_quantity,0) < 0) OR
	          (NVL(l_rsv_quantity,0)< 0) ) THEN
       fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

       -- INVCONV BEGIN
      IF (NVL(l_secondary_rsv_quantity,0) < 0) THEN
        fnd_message.set_name('INV', 'INV-INVALID NEGATIVE SECONDARY'); -- INVCONV New Message
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      -- INVCONV END

      -- Bug 3461990: Reservations API should not be updated with more
      -- than 5 decimal places, since the transaction quantity is being
      -- rounded to 5 decimal places.
      IF (l_debug = 1) THEN
	 debug_print(' Transfer: Before adding the qty to the to record');
      END IF;

      -- wont call table handler since only quantities are changed along
      -- with the who column this is simpler to read and understand

      -- INVCONV - Incorporate secondary_reservation_quantity which could be null
      UPDATE mtl_reservations
         SET primary_reservation_quantity = Round((primary_reservation_quantity + l_to_rsv_rec.primary_reservation_quantity),5)
           , secondary_reservation_quantity = Round((secondary_reservation_quantity + l_to_rsv_rec.secondary_reservation_quantity),5)
           , reservation_quantity = Round((reservation_quantity + l_to_rsv_rec.reservation_quantity),5)
           , detailed_quantity = Round(NVL(detailed_quantity, 0) + NVL(l_to_rsv_rec.detailed_quantity, 0),5)
           , secondary_detailed_quantity = Round(NVL(secondary_detailed_quantity, 0) + NVL(l_to_rsv_rec.secondary_detailed_quantity, 0),5)           --bug 8448053  kbanddyo
           , last_update_date = l_date
           , last_updated_by = l_user_id
           , last_update_login = l_login_id
           , request_id = l_request_id
           , program_application_id = l_prog_appl_id
           , program_id = l_program_id
           , program_update_date = l_date
       WHERE reservation_id = l_to_rsv_tbl(1).reservation_id;

      -- for data sync b/w mtl_demand and mtl_reservations
      inv_rsv_synch.for_update(p_reservation_id => l_to_rsv_tbl(1).reservation_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      x_reservation_id  := l_to_rsv_tbl(1).reservation_id;
    /** Commented out by request of CTO.  Their workflow was not
     *  progressing correctly
     *  Bug 2073768
     *  This code was not interacting correctly with CTO.
     *  No longer call the wf_update_after_inv_unreserv api from
     *  transfer_reservation
     *-- Post Update CTO Validation
     * IF l_to_rsv_rec.demand_source_type_id in (
     *   inv_reservation_global.g_source_type_oe
     *         ,inv_reservation_global.g_source_type_internal_ord
     *        ,inv_reservation_global.g_source_type_rma) THEN
     *    --
     *    cto_workflow_api_pk.wf_update_after_inv_unreserv(
     *      p_order_line_id      => l_to_rsv_rec.demand_source_line_id
     *    , x_return_status      => l_return_status
     *    , x_msg_count          => x_msg_count
     *    , x_msg_data           => x_msg_data
     *    );
     *    --
     *    IF l_return_status = fnd_api.g_ret_sts_error THEN
     *     RAISE fnd_api.g_exc_error;
     *   END IF ;
     *    --
     *    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
     *     RAISE fnd_api.g_exc_unexpected_error;
     *   END IF;
     *    --
     *END IF;
     */
       ELSIF l_transfer_all = FALSE THEN
	IF (l_debug = 1) THEN
           debug_print('To row does not exists and transfer all is false');
        END IF;
      -- Pre Insert CTO Validation
      IF l_to_rsv_rec.demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
        --
        cto_workflow_api_pk.inventory_reservation_check(
          p_order_line_id              => l_to_rsv_rec.demand_source_line_id
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        --
        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      --
      END IF;

      --Bug #2819700
      --Adding an extra check to make sure that tranfer reservations does not
      -- insert the to reservation record to a NEGATIVE NUMBER.
      IF (l_debug = 1) THEN
        debug_print('Primary_reservation_qty before inserting (xfer)= '
		                || To_char(l_to_rsv_rec.primary_reservation_quantity) );
         debug_print('Secondary_reservation_qty before inserting (xfer)= '
                                || To_char(l_to_rsv_rec.secondary_reservation_quantity) ); --INVCONV
        debug_print('Reservation_qty before inserting (xfer)= '
		                || To_char(l_to_rsv_rec.reservation_quantity) );
      END IF;

      IF (  (NVL(l_to_rsv_rec.reservation_quantity,0) < 0) OR
	    (NVL(l_to_rsv_rec.primary_reservation_quantity,0) < 0) ) THEN
	 fnd_message.set_name('INV', 'INV-INVALID RESERVATION QTY');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

       -- INVCONV BEGIN
      IF (NVL(l_to_rsv_rec.secondary_reservation_quantity,0) < 0) THEN
         fnd_message.set_name('INV', 'INV-INVALID NEGATIVE SECONDARY'); -- INVCONV New Message
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
      -- INVCONV END


      -- Bug 3461990: Reservations API should not create reservations with more
      -- than 5 decimal places, since the transaction quantity is being
      -- rounded to 5 decimal places.

      l_to_rsv_rec.primary_reservation_quantity :=
	round(l_to_rsv_rec.primary_reservation_quantity,5);
      -- INVCONV BEGIN
      IF l_dual_tracking THEN
        l_to_rsv_rec.secondary_reservation_quantity :=
          round(l_to_rsv_rec.secondary_reservation_quantity,5);
      END IF;
      -- INVCONV END
      l_to_rsv_rec.reservation_quantity  :=
	round(l_to_rsv_rec.reservation_quantity,5);
      l_to_rsv_rec.detailed_quantity  :=
	round(Nvl(l_to_rsv_rec.detailed_quantity,0),5);

          -- Added for bug 8851133 -Start
            IF l_dual_tracking THEN
                       IF (  l_to_rsv_rec.detailed_quantity = 0 ) THEN
                                 l_to_rsv_rec.secondary_detailed_quantity := 0;
                        END IF;
            ELSE
                        l_to_rsv_rec.secondary_reservation_quantity := NULL;
            END IF;

           -- bug 8851133 - End


      IF (l_debug = 1) THEN
	 debug_print(' Transfer: Before creating new reservations for the to record');
	 debug_print(' After rounding reservation is' || l_orig_rsv_tbl(1).reservation_id);
	 debug_print(' After rounding reservation qty' || l_to_rsv_rec.reservation_quantity);
	 debug_print(' After rounding reservation pri qty' || l_to_rsv_rec.primary_reservation_quantity);
         debug_print(' After rounding reservation sec qty' || l_to_rsv_rec.secondary_reservation_quantity);
	 debug_print(' After rounding detailed quantity' ||l_to_rsv_rec.detailed_quantity );
      END IF;

      /**** {{ R12 Enhanced reservations code changes }}****/
      -- if the reservation being transferred is from PO to ASN
      -- we need to update the original supply as PO, because we
      -- will have to transfer the reservation back to ASN while reducing
      -- and cancelling ASNs
      IF (l_to_rsv_rec.supply_source_type_id =
	  inv_reservation_global.g_source_type_asn) AND
	(l_orig_rsv_tbl(1).supply_source_type_id = inv_reservation_global.g_source_type_po) THEN

	 l_orig_supply_type_id := inv_reservation_global.g_source_type_po;
	 IF (l_debug = 1) THEN
	    debug_print('The original supply is po and the new supply is asn' ||l_orig_supply_type_id);
	 END IF;

      END IF;

      /*** End R12 ***/
      -- create reservation id
     /* SELECT mtl_demand_s.NEXTVAL
        INTO l_reservation_id
        FROM DUAL; */
	-- Bug 55350300 --Selecting the sequence value has been moved to the table handler
	-- in INVRSV6B.pls

	l_reservation_id := NULL;

  --12362469
  IF l_to_rsv_rec.staged_flag = 'Y'
  THEN
    l_to_rsv_rec.serial_reservation_quantity := 0 ;
  END IF;
  --12362469

      -- INVCONV - Incorporate secondary columns
      mtl_reservations_pkg.insert_row
	(
	 x_rowid                      => l_rowid
	 , x_reservation_id             => l_reservation_id
	 , x_requirement_date           => l_to_rsv_rec.requirement_date
	 , x_organization_id            => l_to_rsv_rec.organization_id
	 , x_inventory_item_id          => l_to_rsv_rec.inventory_item_id
	 , x_demand_source_type_id      => l_to_rsv_rec.demand_source_type_id
	 , x_demand_source_name         => l_to_rsv_rec.demand_source_name
	 , x_demand_source_header_id    => l_to_rsv_rec.demand_source_header_id
	 , x_demand_source_line_id      => l_to_rsv_rec.demand_source_line_id
	 , x_demand_source_delivery     => l_to_rsv_rec.demand_source_delivery
	 , x_primary_uom_code           => l_to_rsv_rec.primary_uom_code
	 , x_primary_uom_id             => l_to_rsv_rec.primary_uom_id
	 , x_secondary_uom_code         => l_to_rsv_rec.secondary_uom_code
	 , x_secondary_uom_id           => l_to_rsv_rec.secondary_uom_id
	 , x_reservation_uom_code       => l_to_rsv_rec.reservation_uom_code
	 , x_reservation_uom_id         => l_to_rsv_rec.reservation_uom_id
	, x_reservation_quantity       => l_to_rsv_rec.reservation_quantity
	, x_primary_reservation_quantity=> l_to_rsv_rec.primary_reservation_quantity
	, x_second_reservation_quantity=> l_to_rsv_rec.secondary_reservation_quantity
	, x_detailed_quantity          => l_to_rsv_rec.detailed_quantity
	, x_secondary_detailed_quantity => l_to_rsv_rec.secondary_detailed_quantity
	, x_autodetail_group_id        => l_to_rsv_rec.autodetail_group_id
	, x_external_source_code       => l_to_rsv_rec.external_source_code
	, x_external_source_line_id    => l_to_rsv_rec.external_source_line_id
	, x_supply_source_type_id      => l_to_rsv_rec.supply_source_type_id
	, x_supply_source_header_id    => l_to_rsv_rec.supply_source_header_id
	, x_supply_source_line_id      => l_to_rsv_rec.supply_source_line_id
	, x_supply_source_line_detail  => l_to_rsv_rec.supply_source_line_detail
	, x_supply_source_name         => l_to_rsv_rec.supply_source_name
	, x_revision                   => l_to_rsv_rec.revision
	, x_subinventory_code          => l_to_rsv_rec.subinventory_code
	, x_subinventory_id            => l_to_rsv_rec.subinventory_id
	, x_locator_id                 => l_to_rsv_rec.locator_id
	, x_lot_number                 => l_to_rsv_rec.lot_number
	, x_lot_number_id              => l_to_rsv_rec.lot_number_id
	, x_serial_number              => NULL
	, x_serial_number_id           => NULL
	, x_partial_quantities_allowed => NULL
	, x_auto_detailed              => NULL
	, x_pick_slip_number           => l_to_rsv_rec.pick_slip_number
	, x_lpn_id                     => l_to_rsv_rec.lpn_id
	, x_last_update_date           => l_date
	, x_last_updated_by            => l_user_id
	, x_creation_date              => l_date
	, x_created_by                 => l_user_id
	, x_last_update_login          => l_login_id
	, x_request_id                 => l_request_id
	, x_program_application_id     => l_prog_appl_id
	, x_program_id                 => l_program_id
	, x_program_update_date        => l_date
	, x_attribute_category         => l_to_rsv_rec.attribute_category
	, x_attribute1                 => l_to_rsv_rec.attribute1
	, x_attribute2                 => l_to_rsv_rec.attribute2
	, x_attribute3                 => l_to_rsv_rec.attribute3
	, x_attribute4                 => l_to_rsv_rec.attribute4
	, x_attribute5                 => l_to_rsv_rec.attribute5
	, x_attribute6                 => l_to_rsv_rec.attribute6
	, x_attribute7                 => l_to_rsv_rec.attribute7
	, x_attribute8                 => l_to_rsv_rec.attribute8
	, x_attribute9                 => l_to_rsv_rec.attribute9
	, x_attribute10                => l_to_rsv_rec.attribute10
	, x_attribute11                => l_to_rsv_rec.attribute11
	, x_attribute12                => l_to_rsv_rec.attribute12
	, x_attribute13                => l_to_rsv_rec.attribute13
	, x_attribute14                => l_to_rsv_rec.attribute14
	, x_attribute15                => l_to_rsv_rec.attribute15
	, x_ship_ready_flag            => l_to_rsv_rec.ship_ready_flag
	, x_staged_flag                => l_to_rsv_rec.staged_flag
	/**** {{ R12 Enhanced reservations code changes }}****/
	, x_crossdock_flag             => l_to_rsv_rec.crossdock_flag
	, x_crossdock_criteria_id      => l_to_rsv_rec.crossdock_criteria_id
	, x_demand_source_line_detail  => l_to_rsv_rec.demand_source_line_detail
	, x_serial_reservation_quantity => l_to_rsv_rec.serial_reservation_quantity
	, x_supply_receipt_date        => l_to_rsv_rec.supply_receipt_date
	, x_demand_ship_date             => l_to_rsv_rec.demand_ship_date
	, x_project_id                   => l_to_rsv_rec.project_id
	, x_task_id                      => l_to_rsv_rec.task_id
	, x_orig_supply_type_id   => l_orig_supply_type_id
	, x_orig_supply_header_id => l_to_rsv_rec.supply_source_header_id
	, x_orig_supply_line_id     => l_to_rsv_rec.supply_source_line_id
	, x_orig_supply_line_detail => l_to_rsv_rec.supply_source_line_detail
	, x_orig_demand_type_id     => l_to_rsv_rec.demand_source_type_id
	, x_orig_demand_header_id   => l_to_rsv_rec.demand_source_header_id
	, x_orig_demand_line_id     => l_to_rsv_rec.demand_source_line_id
	, x_orig_demand_line_detail => l_to_rsv_rec.demand_source_line_detail
	/*** End R12 ***/
	);

      debug_print(' After call to insert_row : reservation_id : ' || l_reservation_id);

      -- insert into mtl_reservations
      x_reservation_id  := l_reservation_id;

      -- for data sync b/w mtl_demand and mtl_reservations
      inv_rsv_synch.for_insert(p_reservation_id => l_reservation_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    --
    END IF;

    debug_print(' Before serial number check' || l_return_status);

    -- Bug 2073768
    -- The order status was not being updated in correctly in the
    -- sales order, becuase we were only calling this cto api for
    -- partial reservation transfers.  Now, call this API everytime
    -- transfer_reservation is called
    -- Post Insert CTO Validation
    IF l_to_rsv_rec.demand_source_type_id IN (inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_rma) THEN
      --
      cto_workflow_api_pk.wf_update_after_inv_reserv(p_order_line_id => l_to_rsv_rec.demand_source_line_id, x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data);

      debug_print(' After CTO API' || l_return_status);
      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    --
    END IF;

    /**** {{ R12 Enhanced reservations code changes }}****/
    -- Handling of serial numbers starts here. This block has the changes
    -- related to serial reservations.

    -- get all the from serials that have been reserved.
    --check to see if serial are reserved.

       BEGIN
	  SELECT inventory_item_id, serial_number bulk collect INTO
	    l_serial_number_table FROM
	    mtl_serial_numbers  WHERE reservation_id =
	    l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
	    l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
       EXCEPTION
	  WHEN no_data_found THEN
	     IF l_debug=1 THEN
		debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
	     END IF;
       END;

       l_total_serials_reserved := l_serial_number_table.COUNT;
       IF l_debug=1 THEN
	  debug_print('Total reserved serials: ' || l_total_serials_reserved);
       END IF;

       -- exceed the reservation quantity.
       IF (l_to_row_exist) THEN
	  l_to_reservation_id := l_to_rsv_tbl(1).reservation_id;
	ELSIF (l_transfer_all) THEN
	  l_to_reservation_id := l_orig_rsv_tbl(1).reservation_id;
	ELSE
	  l_to_reservation_id := l_reservation_id;
       END IF;

       --check to see if serial are reserved.
	BEGIN
	   SELECT primary_reservation_quantity INTO
	     l_from_primary_reservation_qty FROM mtl_reservations WHERE
	     reservation_id =  l_orig_rsv_tbl(1).reservation_id;
	EXCEPTION
	   WHEN no_data_found THEN
	      IF l_debug=1 THEN
		 debug_print('This is case 1. The from reservation recordhas been deleted. Id: ' || l_orig_rsv_tbl(1).reservation_id);
	      END IF;
	END;
	BEGIN
	   SELECT primary_reservation_quantity INTO
	     l_to_primary_reservation_qty FROM mtl_reservations WHERE
	     reservation_id =  l_to_reservation_id;
	EXCEPTION
	   WHEN no_data_found THEN
	      IF l_debug=1 THEN
		 debug_print('This is case 2. The to reservation record has been deleted. Id: ' || l_to_reservation_id);
	      END IF;
	END;
	l_to_primary_reservation_qty :=
	  Nvl(l_to_primary_reservation_qty,0);
	l_from_primary_reservation_qty := Nvl(l_from_primary_reservation_qty,0);

	debug_print(' Before Serial param' || l_return_status);

	--Bug 5198421: If no serials are passed and no serial are reserved
	-- set the serial reservation qty and do nothing.
	IF ((l_serial_param = 1) AND (l_total_serials_reserved = 0)) THEN
	   -- set the serial reservation qty to zero
	   BEGIN
	      UPDATE mtl_reservations SET serial_reservation_quantity = 0
		WHERE reservation_id = l_orig_rsv_tbl(1).reservation_id;
	   EXCEPTION
	      WHEN no_data_found THEN
		 IF l_debug=1 THEN
		    debug_print('Could not find the reservation record: ' || l_orig_rsv_tbl(1).reservation_id);
		 END IF;
	   END;
	END IF;


	IF (l_serial_param = 1) AND (l_total_serials_reserved > 0) THEN
	   -- This means that no serials are being passed.
	   -- There are three conditions that we have to handle.
	   --1. If transfer all is true and to row exists, then move everything
	   -- to the to record
	   --2. If transfer all is true and to row does not exist, then we have
	   -- to do nothing as it is the same row that is being updated.
	   --3. If transfer_all is false, then move the excess serials to the
	   -- to record
	   IF l_debug=1 THEN
	      debug_print('Inside param 1');
	      debug_print('Original tbl(1)Org id: ' || l_orig_rsv_tbl(1).organization_id);
	      debug_print('Original tbl(1)Item id: ' || l_orig_rsv_tbl(1).inventory_item_id);
	   END IF;

	   IF ((l_total_serials_reserved >
		l_from_primary_reservation_qty) OR (l_transfer_all AND
						    (NOT l_to_row_exist))) THEN
	      -- call validate serials for the to record as we may have to
	     -- transfer the serials AT random.
	     inv_reservation_validate_pvt.validate_serials
	       (
		x_return_status              => l_return_status
		 , p_rsv_action_name         => 'TRANSFER'
		, p_orig_rsv_rec             => l_dummy_rsv_rec
		, p_to_rsv_rec               => l_to_rsv_rec
		, p_orig_serial_array        => l_dummy_serial_array
		, p_to_serial_array          => l_serial_number_table
		);

	     IF (l_debug = 1) THEN
		debug_print('After calling validate serials ' || l_return_status);
	     END IF;

	     --
	     IF l_return_status = fnd_api.g_ret_sts_error THEN
		RAISE fnd_api.g_exc_error;
	     END IF;

	     --
	     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;
	  END IF;

	  IF (l_total_serials_reserved > 0) THEN
	     IF (l_transfer_all AND l_to_row_exist) THEN
		debug_print('Inside param 1. transfer_all and to_row_exists');
		-- validate the serials with the to record and move everything.
		IF (l_debug = 1) THEN
		   debug_print('Original serial count: ' || l_original_serial_count);
		   debug_print('To serial count: ' || l_to_serial_count);
		END IF;

		-- both from and to serial tables are empty. They are not passed.
		IF (l_debug = 1) THEN
		   debug_print('Inside serial check. Not passed');
		END IF;

		IF (l_total_serials_reserved > l_to_primary_reservation_qty) THEN
		   fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		   fnd_msg_pub.ADD;
		   RAISE fnd_api.g_exc_error;
		END IF;
		-- we will have to migrate the serials to the new reservation
		-- Just make sure that the group_mark_id and the
		-- reservation id are populated.
		FOR l_serial_index IN l_serial_number_table.first..l_serial_number_table.last
		  LOOP
	            BEGIN
		       UPDATE mtl_serial_numbers SET reservation_id = l_to_reservation_id,
			 group_mark_id = l_to_reservation_id WHERE
			 serial_number = l_serial_number_table(l_serial_index).serial_number AND
			 inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id AND
			 current_organization_id = l_orig_rsv_tbl(1).organization_id;
		    EXCEPTION
		       WHEN no_data_found THEN
			  IF l_debug=1 THEN
			     debug_print('No serials found for serial number. : ' || l_serial_number_table(l_serial_index).serial_number);
			  END IF;
			  fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
			  fnd_msg_pub.ADD;
			  RAISE fnd_api.g_exc_error;
		    END;
		    IF l_debug=1 THEN
		       debug_print('Serial being migrated. serial number: ' || l_serial_number_table(l_serial_index).serial_number);
		    END IF;
		  END LOOP;

		  -- update the serial reservation quantity
		  update_serial_rsv_quantity
		    (x_return_status => l_return_status
		     , x_msg_count   => x_msg_count
		     , x_msg_data    => x_msg_data
		     , p_reservation_id  => l_to_reservation_id
		     , p_update_serial_qty => l_total_serials_reserved
		     );

		  IF (l_debug = 1) THEN
		     debug_print('After calling update serial reservations ' || l_return_status);
		  END IF;

		  IF l_return_status = fnd_api.g_ret_sts_error THEN
		     RAISE fnd_api.g_exc_error;
		  END IF;

		  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		     RAISE fnd_api.g_exc_unexpected_error;
		  END IF;

	      ELSIF (NOT l_transfer_all) THEN
	         -- transfer the excess to the to record there are some serial reserved. Check if the
		 -- number of serials
		IF (l_debug = 1) THEN
			debug_print('Inside param 1. Not l_transfer_all');
		END IF;

		IF (l_total_serials_reserved > l_from_primary_reservation_qty) THEN
		   -- we have to unreserve some of the serials
		   -- unreserve the extra serials that are more than the primary_reservation_quantity
		   IF (l_debug = 1) THEN
		      debug_print('Total serials more than from reservation quantity.');
		   END IF;

		   l_serials_tobe_unreserved := l_total_serials_reserved - l_from_primary_reservation_qty;

		   FOR i IN 1..l_serials_tobe_unreserved
		     LOOP
	               BEGIN
			  UPDATE mtl_serial_numbers SET reservation_id = l_to_reservation_id,
			    group_mark_id = l_to_reservation_id WHERE
			    serial_number = l_serial_number_table(i).serial_number AND
			    inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id AND
			    current_organization_id = l_orig_rsv_tbl(1).organization_id;
		       EXCEPTION
			  WHEN no_data_found THEN
			     IF l_debug=1 THEN
				debug_print('No serials found for Serial Number: ' || l_serial_number_table(i).serial_number);
			     END IF;
			     fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
			     fnd_msg_pub.ADD;
			     RAISE fnd_api.g_exc_error;
		       END;

		       IF l_debug=1 THEN
			  debug_print('Serial being unreserved. serial number: ' || l_serial_number_table(i).serial_number);
		       END IF;

		     END LOOP;
		     -- update the serial reservation quantity to be the primary
		     -- reservation quantity, as it is in excess.
		     -- update the serial reservation quantity
		     update_serial_rsv_quantity
		       (x_return_status => l_return_status
			, x_msg_count   => x_msg_count
			, x_msg_data    => x_msg_data
			, p_reservation_id  => l_orig_rsv_tbl(1).reservation_id
			, p_update_serial_qty => -l_serials_tobe_unreserved
			);

		     IF (l_debug = 1) THEN
			debug_print('After calling update serial reservations ' || l_return_status);
		     END IF;

		     IF l_return_status = fnd_api.g_ret_sts_error THEN
			RAISE fnd_api.g_exc_error;
		     END IF;

		     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
			RAISE fnd_api.g_exc_unexpected_error;
		     END IF;

		     update_serial_rsv_quantity
		       (x_return_status => l_return_status
			, x_msg_count   => x_msg_count
			, x_msg_data    => x_msg_data
			, p_reservation_id  => l_to_reservation_id
			, p_update_serial_qty => l_serials_tobe_unreserved
			);

		     IF (l_debug = 1) THEN
			debug_print('After calling update serial reservations ' || l_return_status);
		     END IF;

		     IF l_return_status = fnd_api.g_ret_sts_error THEN
			RAISE fnd_api.g_exc_error;
		     END IF;

		     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
			RAISE fnd_api.g_exc_unexpected_error;
		     END IF;

		     -- check to see if we are transferring more than the
		     -- reserved qty
		     BEGIN
			SELECT COUNT(1) INTO l_total_to_serials_reserved FROM
			  mtl_serial_numbers  WHERE reservation_id =
			  l_to_reservation_id AND current_organization_id =
			  l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
		     EXCEPTION
			WHEN no_data_found THEN
			   IF l_debug=1 THEN
			      debug_print('No serials found for reservation record. id: ' || l_to_reservation_id);
			   END IF;
		     END;
		     IF (l_total_to_serials_reserved > l_to_primary_reservation_qty) THEN
			fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
			fnd_msg_pub.ADD;
			RAISE fnd_api.g_exc_error;
		     END IF;

		END IF; -- total serials more than orig reservation qty

	      ELSIF (l_transfer_all AND (NOT l_to_row_exist)) THEN
			     -- make sure that the total serials doesnt
			     -- exceed the to reservation count and they
			     -- are validated.
	        IF (l_total_serials_reserved > l_to_primary_reservation_qty) THEN
		   fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		   fnd_msg_pub.ADD;
		   RAISE fnd_api.g_exc_error;
		END IF;
	  END IF; -- transfer all and to row exists

       END IF; -- serials reserved
    END IF;-- l_serial_param = 1

    IF (l_serial_param = 2) THEN
       -- We will have to unreserve the from serials and if the serial count
       -- exceeds the from primary qty, transfer them to the to record

       -- validate if the passed serials belong to the from reservation
       -- record.
       IF l_debug=1 THEN
	  debug_print('Inside param 2');
	  debug_print('Original tbl(1)Org id: ' || l_orig_rsv_tbl(1).organization_id);
	  debug_print('Original tbl(1)Item id: ' || l_orig_rsv_tbl(1).inventory_item_id);
       END IF;

       -- The serial has to be reserved to the from record
       FOR i IN p_original_serial_number.first..p_original_serial_number.last
	 LOOP
	   BEGIN
	      SELECT reservation_id INTO l_from_reservation_id FROM mtl_serial_numbers WHERE
		serial_number = p_original_serial_number(i).serial_number AND
		current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	   EXCEPTION
	      WHEN no_data_found THEN
		 IF l_debug=1 THEN
		    debug_print('No serials found for this data : ' || p_to_serial_number(i).serial_number);
		 END IF;
	   END;

	   -- if the serial is not reserved or if the serial belongs to a
	   -- different reservation record, then fail
	   IF (l_from_reservation_id IS NOT NULL AND l_from_reservation_id <>
	       l_orig_rsv_tbl(1).reservation_id) OR (l_from_reservation_id IS NULL) THEN
	      fnd_message.set_name('INV', 'INV_INVALID_FROM_SERIAL');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;
	   END IF;

	   IF (l_total_serials_reserved > 0) THEN
	   -- unreserve the passed serials.
	     BEGIN
		UPDATE mtl_serial_numbers SET reservation_id = NULL,
		  group_mark_id = NULL, line_mark_id = NULL,
		  lot_line_mark_id = NULL WHERE
		  serial_number = p_original_serial_number(i).serial_number AND
		  current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		  inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	     EXCEPTION
		WHEN no_data_found THEN
		   IF l_debug=1 THEN
		      debug_print('No serials found for this data : ' || p_to_serial_number(i).serial_number);
		   END IF;
	     END;
	   END IF;
	 END LOOP;

	 IF (l_total_serials_reserved > 0) THEN
	    IF (l_transfer_all AND l_to_row_exist) THEN
	       -- if more serials are reserved,
	       -- transfer them to the to record
	       -- validate the serials before transferring them to to
	       -- record.
	       IF (l_debug = 1) THEN
		  debug_print('Inside param 2. transfer_all and to_row_exists');
	       END IF;

	       BEGIN
		  SELECT inventory_item_id, serial_number bulk collect INTO
		    l_validate_serial_number_table FROM
		    mtl_serial_numbers  WHERE reservation_id =
		    l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		    l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	       EXCEPTION
		  WHEN no_data_found THEN
		     IF l_debug=1 THEN
			debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		     END IF;
	       END;

	       l_validate_serials_reserved := l_validate_serial_number_table.COUNT;

	       IF l_debug=1 THEN
		  debug_print('Total reserved serials: ' || l_validate_serials_reserved);
	       END IF;

	       IF (l_validate_serials_reserved > 0) THEN
		  -- from record still has some reserved serials afer
		  -- unreserving the passed serials. transfer them to the to_record
		  inv_reservation_validate_pvt.validate_serials
		    (
		     x_return_status              => l_return_status
		     , p_rsv_action_name          => 'TRANSFER'
		     , p_orig_rsv_rec             => l_dummy_rsv_rec
		     , p_to_rsv_rec               => l_to_rsv_rec
		     , p_orig_serial_array        => l_dummy_serial_array
		     , p_to_serial_array          => l_validate_serial_number_table
		     );

		  IF (l_debug = 1) THEN
		     debug_print('After calling validate serials ' || l_return_status);
		  END IF;

		  --
		  IF l_return_status = fnd_api.g_ret_sts_error THEN
		     RAISE fnd_api.g_exc_error;
		  END IF;

		  --
		  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		     RAISE fnd_api.g_exc_unexpected_error;
		  END IF;
	       END IF;

               BEGIN
		  UPDATE mtl_serial_numbers SET reservation_id = l_to_reservation_id,
		    group_mark_id = l_to_reservation_id WHERE
		    reservation_id = l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		    l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;

	       EXCEPTION
		  WHEN no_data_found THEN
		     IF l_debug=1 THEN
			debug_print('No serials found for this data. rsv id: ' || l_orig_rsv_tbl(1).reservation_id);
		     END IF;
		     fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		     fnd_msg_pub.ADD;
		     RAISE fnd_api.g_exc_error;
	       END;

	       -- check to see if we have reserved more than the to_record
	       BEGIN
		  SELECT COUNT(1) INTO l_total_to_serials_reserved FROM
		    mtl_serial_numbers  WHERE reservation_id =
		    l_to_reservation_id AND current_organization_id =
		    l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	       EXCEPTION
		  WHEN no_data_found THEN
		     IF l_debug=1 THEN
			debug_print('No serials found for reservation record. id: ' || l_to_reservation_id);
		     END IF;
	       END;

	       IF (l_total_to_serials_reserved > l_to_primary_reservation_qty) THEN
		  fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	       END IF;

		 -- update with whatever is being moved to the to record
		 update_serial_rsv_quantity
		   (x_return_status => l_return_status
		    , x_msg_count   => x_msg_count
		    , x_msg_data    => x_msg_data
		    , p_reservation_id  => l_to_reservation_id
		    , p_update_serial_qty => l_validate_serial_number_table.count
		    );

		 IF (l_debug = 1) THEN
		    debug_print('After calling update serial reservations ' || l_return_status);
		 END IF;

		 IF l_return_status = fnd_api.g_ret_sts_error THEN
		    RAISE fnd_api.g_exc_error;
		 END IF;

		 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;

	     ELSIF (NOT l_transfer_all) THEN
		 --the from serials are already unreserved. If there are
		 -- more serials, validate and move the excess to the
		 -- to record
		     IF (l_debug = 1) THEN
			debug_print('Inside param 2. not transfer_all');
		     END IF;
		 BEGIN
		    SELECT inventory_item_id, serial_number bulk collect INTO
		      l_validate_serial_number_table FROM
		      mtl_serial_numbers  WHERE reservation_id =
		      l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		      l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
		 EXCEPTION
		    WHEN no_data_found THEN
		       IF l_debug=1 THEN
			  debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		       END IF;
		 END;

		 l_validate_serials_reserved := l_validate_serial_number_table.COUNT;

		 IF l_debug=1 THEN
		    debug_print('Total reserved serials: ' || l_validate_serials_reserved);
		 END IF;

		 IF (l_validate_serials_reserved > 0) AND (l_validate_serials_reserved > l_from_primary_reservation_qty) THEN
		    inv_reservation_validate_pvt.validate_serials
		      (
		       x_return_status              => l_return_status
		        , p_rsv_action_name         => 'TRANSFER'
		       , p_orig_rsv_rec             => l_dummy_rsv_rec
		       , p_to_rsv_rec               => l_to_rsv_rec
		       , p_orig_serial_array        => l_dummy_serial_array
		       , p_to_serial_array          => l_validate_serial_number_table
		       );

		    IF (l_debug = 1) THEN
		       debug_print('After calling validate serials ' || l_return_status);
		    END IF;

		    --
		    IF l_return_status = fnd_api.g_ret_sts_error THEN
		       RAISE fnd_api.g_exc_error;
		    END IF;

		    --
		    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		       RAISE fnd_api.g_exc_unexpected_error;
		    END IF;

		    -- we have to unreserve some of the serials
		    -- unreserve the extra serials that are more than the primary_reservation_quantity
		    IF (l_debug = 1) THEN
		       debug_print('Total serials more than reservation quantity.');
		    END IF;

		    l_serials_tobe_unreserved := l_validate_serials_reserved -  l_from_primary_reservation_qty;

		    FOR i IN 1..l_serials_tobe_unreserved
		      LOOP
	               BEGIN
			  UPDATE mtl_serial_numbers SET reservation_id = l_to_reservation_id,
			    group_mark_id = l_to_reservation_id WHERE
			    serial_number = l_validate_serial_number_table(i).serial_number AND
			    inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id AND
			    current_organization_id = l_orig_rsv_tbl(1).organization_id;
		       EXCEPTION
			  WHEN no_data_found THEN
			     IF l_debug=1 THEN
				debug_print('No serials found for serial number: ' || l_validate_serial_number_table(i).serial_number);
			     END IF;
			     fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
			     fnd_msg_pub.ADD;
			     RAISE fnd_api.g_exc_error;
		       END;

		       IF l_debug=1 THEN
			  debug_print('Serial being unreserved. serial number: ' || l_serial_number_table(i).serial_number);
		       END IF;

		      END LOOP;

		      BEGIN
			 SELECT COUNT(1) INTO l_total_to_serials_reserved FROM
			   mtl_serial_numbers  WHERE reservation_id =
			   l_to_reservation_id AND current_organization_id =
			   l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
		      EXCEPTION
			 WHEN no_data_found THEN
			    IF l_debug=1 THEN
			       debug_print('No serials found for reservation record. id: ' || l_to_reservation_id);
			    END IF;
		      END;

		      IF (l_total_to_serials_reserved > l_to_primary_reservation_qty) THEN
			 fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
			 fnd_msg_pub.ADD;
			 RAISE fnd_api.g_exc_error;
		      END IF;

		      update_serial_rsv_quantity
			(x_return_status => l_return_status
			 , x_msg_count   => x_msg_count
			 , x_msg_data    => x_msg_data
			 , p_reservation_id  => l_to_reservation_id
			 , p_update_serial_qty => l_serials_tobe_unreserved
			 );

		      IF (l_debug = 1) THEN
			 debug_print('After calling update serial reservations ' || l_return_status);
		      END IF;

		      IF l_return_status = fnd_api.g_ret_sts_error THEN
			 RAISE fnd_api.g_exc_error;
		      END IF;

		      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
			 RAISE fnd_api.g_exc_unexpected_error;
		      END IF;
		 END IF; -- total serials more than orig reservation qty
		 -- now update the from reservation record as we have to
		 -- update the unreserved serial and the transferred serial
		 l_serials_unreserved := -(p_original_serial_number.COUNT + Nvl(l_serials_tobe_unreserved,0));
		 IF (l_debug = 1) THEN
		    debug_print('Total serials unreserved ' || l_serials_unreserved);
		 END IF;
		 -- update the serial reservation quantity to be the primary
		 -- reservation quantity, as it is in excess.
		 -- update the serial reservation quantity
		 update_serial_rsv_quantity
		   (x_return_status => l_return_status
		    , x_msg_count   => x_msg_count
		    , x_msg_data    => x_msg_data
		    , p_reservation_id  => l_orig_rsv_tbl(1).reservation_id
		    , p_update_serial_qty => l_serials_unreserved
		    );

		 IF (l_debug = 1) THEN
		    debug_print('After calling update serial reservation qty ' || l_return_status);
		 END IF;

		 IF l_return_status = fnd_api.g_ret_sts_error THEN
		    RAISE fnd_api.g_exc_error;
		 END IF;

		 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;

	     ELSIF (l_transfer_all AND (NOT l_to_row_exist)) THEN
		    -- we have already unreserved the serials. Since we are
		    -- working on the same record, we will have to update
		    -- the serial reservation quantity

		IF (l_debug = 1) THEN
		   debug_print('Inside param 2. transfer_all and not to_row_exist');
		END IF;
                BEGIN
		   SELECT inventory_item_id, serial_number bulk collect INTO
		     l_validate_serial_number_table FROM
		     mtl_serial_numbers  WHERE reservation_id =
		     l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		     l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
		EXCEPTION
		   WHEN no_data_found THEN
		      IF l_debug=1 THEN
			 debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		      END IF;
		END;

		l_validate_serials_reserved := l_validate_serial_number_table.COUNT;

		IF l_debug=1 THEN
		   debug_print('Total reserved serials: ' || l_validate_serials_reserved);
		END IF;

		IF (l_validate_serials_reserved > l_to_primary_reservation_qty) THEN
		   fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		   fnd_msg_pub.ADD;
		   RAISE fnd_api.g_exc_error;
		END IF;

		IF (l_validate_serials_reserved > 0) THEN
		   inv_reservation_validate_pvt.validate_serials
		     (
		      x_return_status              => l_return_status
		      , p_rsv_action_name         => 'TRANSFER'
		      , p_orig_rsv_rec             => l_dummy_rsv_rec
		      , p_to_rsv_rec               => l_to_rsv_rec
		      , p_orig_serial_array        => l_dummy_serial_array
		      , p_to_serial_array          => l_validate_serial_number_table
		      );

		   IF (l_debug = 1) THEN
		      debug_print('After calling validate serials ' || l_return_status);
		   END IF;

		   --
		   IF l_return_status = fnd_api.g_ret_sts_error THEN
		      RAISE fnd_api.g_exc_error;
		   END IF;

		   --
		   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		      RAISE fnd_api.g_exc_unexpected_error;
		   END IF;

		   -- we have to unreserve some of the serials
		   -- unreserve the extra serials that are more than the primary_reservation_quantity
		   IF (l_debug = 1) THEN
		      debug_print('Total serials more than reservation quantity.');
		   END IF;
		END IF;

		update_serial_rsv_quantity
		  (x_return_status => l_return_status
		   , x_msg_count   => x_msg_count
		   , x_msg_data    => x_msg_data
		   , p_reservation_id  => l_orig_rsv_tbl(1).reservation_id
		   , p_update_serial_qty => -p_original_serial_number.COUNT
		   );

		IF (l_debug = 1) THEN
		   debug_print('After calling update serial reservation qty ' || l_return_status);
		END IF;

		IF l_return_status = fnd_api.g_ret_sts_error THEN
		       RAISE fnd_api.g_exc_error;
		END IF;

		IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		   RAISE fnd_api.g_exc_unexpected_error;
		END IF;

	    END IF;-- transfer all and to row exists
	 END IF ; -- total serials reserved > 0
    END IF; -- param = 2

    IF (l_serial_param = 3) THEN
       -- to serials are passed but not the from serial.
       -- reserve the serials. if the serial belongs to the from record,
       -- transfer it to the to record.

       IF l_debug=1 THEN
	  debug_print('Inside param 3');
	  debug_print('Original tbl(1)Org id: ' || l_orig_rsv_tbl(1).organization_id);
	  debug_print('Original tbl(1)Item id: ' || l_orig_rsv_tbl(1).inventory_item_id);
       END IF;

       -- validate the serial numbers passed and reserve them

       FOR i IN p_to_serial_number.first..p_to_serial_number.last
	 LOOP
	   BEGIN
	      IF (l_debug = 1) THEN
		 debug_print('Processing serial number' || p_to_serial_number(i).serial_number);
	      END IF;

	      SELECT reservation_id, group_mark_id INTO
		l_from_reservation_id, l_group_mark_id FROM mtl_serial_numbers WHERE
		serial_number = p_to_serial_number(i).serial_number AND
		current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	   EXCEPTION
	      WHEN no_data_found THEN
		 IF l_debug=1 THEN
		    debug_print('No serials found for this data : ' ||
				p_to_serial_number(i).serial_number);
		 END IF;
		 fnd_message.set_name('INV', 'INV_INVALID_FROM_SERIAL');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	   END;

	   IF (l_from_reservation_id IS NOT NULL AND l_from_reservation_id <>
	       l_orig_rsv_tbl(1).reservation_id) THEN
	      fnd_message.set_name('INV', 'INV_INVALID_FROM_SERIAL');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;
	   END IF;

	   -- If reservation id is null, then we are reserving a new
	   -- serial. we should check to see if the group mark id is null or
	   -- it is not being used by another transaction.

	   IF (l_from_reservation_id IS NULL) AND (l_group_mark_id IS NOT NULL)  AND (l_group_mark_id <> -1)THEN
	      IF (l_debug = 1) THEN
		 debug_print('Group Mark Id is not null for serial ' || p_to_serial_number(i).serial_number);
	      END IF;
	      fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;
	   END IF;

	   BEGIN
	      UPDATE mtl_serial_numbers SET reservation_id = l_to_reservation_id,
		group_mark_id = l_to_reservation_id WHERE
		serial_number = p_to_serial_number(i).serial_number AND
		current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	   EXCEPTION
	      WHEN no_data_found THEN
		 IF l_debug=1 THEN
		    debug_print('No serials found for this data : ' || p_to_serial_number(i).serial_number);
		 END IF;
	   END;
	 END LOOP;

	 IF (l_transfer_all AND l_to_row_exist) THEN
	    -- validate the from serial with the to record.
	    -- if count + to reserved count exceeds primary qty - fail
	    -- else update from to to

	    IF (l_debug = 1) THEN
	       debug_print('Inside param 3. transfer_all and to_row_exist');
	    END IF;

	    -- we need to validate only if there are more serials reserved
	    -- and we need to transfer to the to_record.
	    IF (l_total_serials_reserved > 0) THEN
	       -- call validate serials for the to record.
	       inv_reservation_validate_pvt.validate_serials
		 (
		  x_return_status              => l_return_status
		  , p_rsv_action_name         => 'TRANSFER'
		  , p_orig_rsv_rec             => l_dummy_rsv_rec
		  , p_to_rsv_rec               => l_to_rsv_rec
		  , p_orig_serial_array        => l_dummy_serial_array
		  , p_to_serial_array          => l_serial_number_table
		  );

	       IF (l_debug = 1) THEN
		  debug_print('After calling validate serials ' || l_return_status);
	       END IF;

	       --
	       IF l_return_status = fnd_api.g_ret_sts_error THEN
		  RAISE fnd_api.g_exc_error;
	       END IF;

	       --
	       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

	    END IF;

	    -- we will have to migrate the serials to the new reservation
	    -- Just make sure that the group_mark_id and the
	    -- reservation id are populated.
	    FOR l_serial_index IN l_serial_number_table.first..l_serial_number_table.last
	      LOOP
	        BEGIN
		   UPDATE mtl_serial_numbers SET reservation_id = l_to_reservation_id,
		     group_mark_id = l_to_reservation_id WHERE
		     serial_number = l_serial_number_table(l_serial_index).serial_number AND
		     inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id AND
		     current_organization_id = l_orig_rsv_tbl(1).organization_id;
		EXCEPTION
		   WHEN no_data_found THEN
		      IF l_debug=1 THEN
			 debug_print('No serials found for the serial number: ' || l_serial_number_table(l_serial_index).serial_number);
		      END IF;
		      fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		      fnd_msg_pub.ADD;
		      RAISE fnd_api.g_exc_error;
		END;

		IF l_debug=1 THEN
		   debug_print('Serial being migrated. serial number: ' || l_serial_number_table(l_serial_index).serial_number);
		END IF;

	      END LOOP;

	      BEGIN
		 SELECT COUNT(1) INTO l_total_to_serials_reserved FROM
		   mtl_serial_numbers  WHERE reservation_id =
		   l_to_reservation_id AND current_organization_id =
		   l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_to_reservation_id);
		    END IF;
	      END;

	      IF (l_total_to_serials_reserved > l_to_primary_reservation_qty) THEN
		 fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      -- update the to serial reservation quantity. dont have
	      -- to update from as the from record is deleted.

	      BEGIN
		 UPDATE mtl_reservations SET serial_reservation_quantity
		   = l_total_to_serials_reserved WHERE reservation_id =
		   l_to_reservation_id;

	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('Update failed for from reservation record. id: ' || l_to_reservation_id);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_ROW');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;

	      IF (l_debug = 1) THEN
		 debug_print('After updating serial count of the to_record.');
	      END IF;

	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;

	  ELSIF (l_transfer_all AND (NOT l_to_row_exist)) THEN
		    -- validate the from serial with the to record.
	      -- if count + to reserved count exceeds primary qty - fail
		    -- else update from to to

	      IF (l_debug = 1) THEN
		 debug_print('Inside param 3. transfer_all and not to_row_exist');
	      END IF;

	      IF (l_total_serials_reserved > 0) THEN
		 -- call validate serials for the to record.
		 inv_reservation_validate_pvt.validate_serials
		   (
		    x_return_status              => l_return_status
		    , p_rsv_action_name          => 'TRANSFER'
		    , p_orig_rsv_rec             => l_dummy_rsv_rec
		    , p_to_rsv_rec               => l_to_rsv_rec
		    , p_orig_serial_array        => l_dummy_serial_array
		    , p_to_serial_array          => l_serial_number_table
		    );

		 IF (l_debug = 1) THEN
		    debug_print('After calling validate serials ' || l_return_status);
		 END IF;

		 --
		 IF l_return_status = fnd_api.g_ret_sts_error THEN
		    RAISE fnd_api.g_exc_error;
		 END IF;

		 --
		 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;

	      END IF;

	      -- we have already reserved the serials. Since we are
	      -- working on the same record, we will have to update
	      -- the serial reservation quantity. check to see if the
	      -- count exceeds
	      BEGIN
		 SELECT COUNT(1) INTO l_total_to_serials_reserved FROM
		   mtl_serial_numbers  WHERE reservation_id =
		   l_orig_rsv_tbl(1).reservation_id AND current_organization_id = l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_to_reservation_id);
		    END IF;
	      END;

	      IF (l_total_to_serials_reserved > l_to_primary_reservation_qty) THEN
		 fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

              BEGIN
		 UPDATE mtl_reservations SET serial_reservation_quantity
		   = l_total_to_serials_reserved WHERE reservation_id =
		   l_orig_rsv_tbl(1).reservation_id;

	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('Update failed for from reservation record. id: ' || l_to_reservation_id);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_ROW');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;

	      IF (l_debug = 1) THEN
		 debug_print('After calling update serial reservation qty ' || l_return_status);
	      END IF;

	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;

	  ELSIF (NOT l_transfer_all) THEN
		      -- serials passed have already been reserved. make sure the
		      -- count doesnt exceed.
	      IF l_debug=1 THEN
		 debug_print('Inside param 3. Not transfer all');
		 debug_print('to reservation id: ' || l_to_reservation_id);
		 debug_print('from reservation id: ' || l_orig_rsv_tbl(1).reservation_id);
	      END IF;

	      -- check the from serial count. if the from count exceeds the
	      -- from reservation qty, transfer to the to record.
	      IF (l_total_serials_reserved > 0) THEN
               BEGIN
		  SELECT inventory_item_id, serial_number bulk collect INTO
		    l_validate_serial_number_table FROM
		    mtl_serial_numbers  WHERE reservation_id =
		    l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		    l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	       EXCEPTION
		  WHEN no_data_found THEN
		     IF l_debug=1 THEN
			debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		     END IF;
	       END;

	       l_total_from_serials_reserved := l_validate_serial_number_table.COUNT;

	       IF (l_total_from_serials_reserved > l_from_primary_reservation_qty) THEN
		  -- we have to transfer some of the serials to the to_record
		  -- unreserve the extra serials that are more than the primary_reservation_quantity
		  IF (l_debug = 1) THEN
		     debug_print('Total serials more than from reservation quantity.');
		  END IF;

		  -- need to validate serials as we are going to transfer
		  -- them at randon
		  -- call validate serials for the to record.
		  inv_reservation_validate_pvt.validate_serials
		    (
		     x_return_status              => l_return_status
		     , p_rsv_action_name          => 'TRANSFER'
		     , p_orig_rsv_rec             => l_dummy_rsv_rec
		     , p_to_rsv_rec               => l_to_rsv_rec
		     , p_orig_serial_array        => l_dummy_serial_array
		     , p_to_serial_array          => l_validate_serial_number_table
		     );

		  IF (l_debug = 1) THEN
		     debug_print('After calling validate serials ' || l_return_status);
		  END IF;

		  --
		  IF l_return_status = fnd_api.g_ret_sts_error THEN
		     RAISE fnd_api.g_exc_error;
		  END IF;

		  --
		  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		     RAISE fnd_api.g_exc_unexpected_error;
		  END IF;


		  l_serials_tobe_unreserved := l_total_from_serials_reserved - l_from_primary_reservation_qty;

		  FOR i IN 1..l_serials_tobe_unreserved
		    LOOP
	             BEGIN
			UPDATE mtl_serial_numbers SET
			  reservation_id = l_to_reservation_id,
			  group_mark_id = l_to_reservation_id WHERE
			  serial_number = l_validate_serial_number_table(i).serial_number AND
			  inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id AND
			  current_organization_id = l_orig_rsv_tbl(1).organization_id;
		     EXCEPTION
			WHEN no_data_found THEN
			   IF l_debug=1 THEN
			      debug_print('No serials found for Serial Number: ' || l_serial_number_table(i).serial_number);
			   END IF;
			   fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
			   fnd_msg_pub.ADD;
			   RAISE fnd_api.g_exc_error;
		     END;

		     IF l_debug=1 THEN
			debug_print('Serial being unreserved. serial number: ' || l_serial_number_table(i).serial_number);
		     END IF;

		    END LOOP;
	       END IF;
	      END IF;

              BEGIN
		 SELECT COUNT(1) INTO l_total_to_serials_reserved FROM
		   mtl_serial_numbers  WHERE reservation_id =
		   l_to_reservation_id AND current_organization_id =
		   l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for to reservation record. id: ' || l_to_reservation_id);
		    END IF;
	      END;

	      IF (l_total_to_serials_reserved > l_to_primary_reservation_qty) THEN
		 fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      BEGIN
		 UPDATE mtl_reservations SET serial_reservation_quantity
		   = l_total_to_serials_reserved WHERE reservation_id =
		   l_to_reservation_id;

	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('Update failed for to reservation record. id: ' || l_to_reservation_id);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_ROW');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;

	      BEGIN
		 SELECT COUNT(1) INTO l_total_from_serials_reserved FROM
		   mtl_serial_numbers  WHERE reservation_id =
		   l_orig_rsv_tbl(1).reservation_id AND
		   current_organization_id = l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for to reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		    END IF;
	      END;

              BEGIN
		 UPDATE mtl_reservations SET serial_reservation_quantity
		   = l_total_from_serials_reserved WHERE reservation_id =
		   l_orig_rsv_tbl(1).reservation_id;

	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('Update failed for from reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_ROW');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;


	 END if; -- transfer all and to row exist
    END IF; -- param = 3


    IF (l_serial_param = 4) THEN

       -- We will have to unreserve the from serials and if the serial count
       -- exceeds the from primary qty, transfer them to the to record

       -- validate if the passed serials belong to the from reservation
       -- record.
       IF l_debug=1 THEN
	  debug_print('Inside param 2');
	  debug_print('Original tbl(1)Org id: ' || l_orig_rsv_tbl(1).organization_id);
	  debug_print('Original tbl(1)Item id: ' || l_orig_rsv_tbl(1).inventory_item_id);
       END IF;
       -- The serial has to be reserved to the from record
       FOR i IN p_original_serial_number.first..p_original_serial_number.last
	 LOOP
	   BEGIN
	      SELECT reservation_id INTO l_from_reservation_id FROM mtl_serial_numbers WHERE
		serial_number = p_original_serial_number(i).serial_number AND
		current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	   EXCEPTION
	      WHEN no_data_found THEN
		 IF l_debug=1 THEN
		    debug_print('No serials found for this data : ' || p_original_serial_number(i).serial_number);
		 END IF;
	   END;

	   -- if the serial is not reserved or if the serial belongs to a
	   -- different reservation record, then fail
	   IF (l_from_reservation_id IS NOT NULL AND l_from_reservation_id <>
	       l_orig_rsv_tbl(1).reservation_id) OR (l_from_reservation_id IS NULL) THEN
	      fnd_message.set_name('INV', 'INV_INVALID_FROM_SERIAL');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;
	   END IF;

	   -- unreserve the passed serials.
	     BEGIN
		UPDATE mtl_serial_numbers SET reservation_id = NULL,
		  group_mark_id = NULL, line_mark_id = NULL,
		  lot_line_mark_id = NULL WHERE
		  serial_number = p_original_serial_number(i).serial_number AND
		  current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		  inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	     EXCEPTION
		WHEN no_data_found THEN
		   IF l_debug=1 THEN
		      debug_print('No serials found for this data : ' || p_original_serial_number(i).serial_number);
		   END IF;
	     END;
	 END LOOP;

	 -- to serials are passed .
	 -- reserve the serials. if the serial belongs to the from record,
	 -- transfer it to the to record.

	 -- validate the serial numbers passed and reserve them

	 FOR i IN p_to_serial_number.first..p_to_serial_number.last
	   LOOP
	     BEGIN
		SELECT reservation_id, group_mark_id INTO
		  l_from_reservation_id, l_group_mark_id FROM mtl_serial_numbers WHERE
		  serial_number = p_to_serial_number(i).serial_number AND
		  current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		  inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	     EXCEPTION
		WHEN no_data_found THEN
		   IF l_debug=1 THEN
		      debug_print('No serials found for this data : ' || p_to_serial_number(i).serial_number);
		   END IF;
		   fnd_message.set_name('INV', 'INV_INVALID_FROM_SERIAL');
		   fnd_msg_pub.ADD;
		   RAISE fnd_api.g_exc_error;
	     END;

	     IF (l_from_reservation_id IS NOT NULL AND l_from_reservation_id <>
		 l_orig_rsv_tbl(1).reservation_id) THEN
		fnd_message.set_name('INV', 'INV_INVALID_FROM_SERIAL');
		fnd_msg_pub.ADD;
		RAISE fnd_api.g_exc_error;
	     END IF;

	     IF (l_from_reservation_id IS NULL) AND (l_group_mark_id IS NOT NULL)  AND (l_group_mark_id <> -1)THEN
		IF (l_debug = 1) THEN
		   debug_print('Group Mark Id is not null for serial ' || p_to_serial_number(i).serial_number);
		END IF;
		fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
		fnd_msg_pub.ADD;
		RAISE fnd_api.g_exc_error;
	     END IF;

	     BEGIN
		UPDATE mtl_serial_numbers SET reservation_id = l_to_reservation_id,
		  group_mark_id = l_to_reservation_id WHERE
		  serial_number = p_to_serial_number(i).serial_number AND
		  current_organization_id = l_orig_rsv_tbl(1).organization_id AND
		  inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	     EXCEPTION
		WHEN no_data_found THEN
		   IF l_debug=1 THEN
		      debug_print('No serials found for this data : ' || p_to_serial_number(i).serial_number);
		   END IF;
	     END;
	   END LOOP;

	   IF (l_transfer_all AND l_to_row_exist) THEN
	      -- if more serials are reserved,
	      -- transfer them to the to record
	      -- validate the serials before transferring them to to
	      -- record.
	      IF (l_debug = 1) THEN
		 debug_print('Inside param 4. transfer_all and to_row_exist');
	      END IF;

	      IF (l_total_serials_reserved > 0) THEN
	       BEGIN
		  SELECT inventory_item_id, serial_number bulk collect INTO
		    l_validate_serial_number_table FROM
		    mtl_serial_numbers  WHERE reservation_id =
		    l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		    l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	       EXCEPTION
		  WHEN no_data_found THEN
		     IF l_debug=1 THEN
			debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		     END IF;
	       END;

	       l_validate_serials_reserved := l_validate_serial_number_table.COUNT;
	       IF l_debug=1 THEN
		  debug_print('Total reserved serials: ' || l_validate_serials_reserved);
	       END IF;

	       IF (l_validate_serials_reserved > 0) THEN
		  inv_reservation_validate_pvt.validate_serials
		    (
		     x_return_status              => l_return_status
		     , p_rsv_action_name         => 'TRANSFER'
		     , p_orig_rsv_rec             => l_dummy_rsv_rec
		     , p_to_rsv_rec               => l_to_rsv_rec
		     , p_orig_serial_array        => l_dummy_serial_array
		     , p_to_serial_array          => l_validate_serial_number_table
		     );

		  IF (l_debug = 1) THEN
		     debug_print('After calling validate serials ' || l_return_status);
		  END IF;

		  --
		  IF l_return_status = fnd_api.g_ret_sts_error THEN
		     RAISE fnd_api.g_exc_error;
		  END IF;

		  --
		  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		     RAISE fnd_api.g_exc_unexpected_error;
		  END IF;

		  BEGIN
		     UPDATE mtl_serial_numbers SET reservation_id = l_to_reservation_id,
		       group_mark_id = l_to_reservation_id WHERE
		       reservation_id = l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		       l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;

		  EXCEPTION
		     WHEN no_data_found THEN
			IF l_debug=1 THEN
			   debug_print('No serials found for this data. rsv id: ' || l_orig_rsv_tbl(1).reservation_id);
			END IF;
			fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
			fnd_msg_pub.ADD;
			RAISE fnd_api.g_exc_error;
		  END;
	       END IF;
	      END IF;

	      BEGIN
		 SELECT COUNT(1) INTO l_total_to_serials_reserved FROM
		   mtl_serial_numbers  WHERE reservation_id =
		   l_to_reservation_id AND current_organization_id =
		   l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_to_reservation_id);
		    END IF;
	      END;

	      IF (l_total_to_serials_reserved > l_to_primary_reservation_qty) THEN
		 fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      BEGIN
		 UPDATE mtl_reservations SET serial_reservation_quantity
		   = l_total_to_serials_reserved WHERE reservation_id =
		   l_orig_rsv_tbl(1).reservation_id;

	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_ROW');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;

	    ELSIF (l_transfer_all AND (NOT l_to_row_exist)) THEN

		    -- validate the from serial with the to record.
		    -- if count + to reserved count exceeds primary qty - fail
		    -- else update from to to

	      IF (l_debug = 1) THEN
		 debug_print('Inside param 4. transfer_all and not to_row_exist');
	      END IF;

	      IF (l_total_serials_reserved > 0) THEN
	        BEGIN
		   SELECT inventory_item_id, serial_number bulk collect INTO
		     l_validate_serial_number_table FROM
		     mtl_serial_numbers  WHERE reservation_id =
		     l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		     l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
		EXCEPTION
		   WHEN no_data_found THEN
		      IF l_debug=1 THEN
			 debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		      END IF;
		END;

		l_validate_serials_reserved := l_validate_serial_number_table.COUNT;
		IF l_debug=1 THEN
		   debug_print('Total reserved serials: ' || l_validate_serials_reserved);
		END IF;

		IF (l_validate_serials_reserved > 0) THEN
		   inv_reservation_validate_pvt.validate_serials
		     (
		      x_return_status              => l_return_status
		      , p_rsv_action_name         => 'TRANSFER'
		      , p_orig_rsv_rec             => l_dummy_rsv_rec
		      , p_to_rsv_rec               => l_to_rsv_rec
		      , p_orig_serial_array        => l_dummy_serial_array
		      , p_to_serial_array          => l_validate_serial_number_table
		      );

		   IF (l_debug = 1) THEN
		      debug_print('After calling validate serials ' || l_return_status);
		   END IF;

		   --
		   IF l_return_status = fnd_api.g_ret_sts_error THEN
		      RAISE fnd_api.g_exc_error;
		   END IF;

		   --
		   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		      RAISE fnd_api.g_exc_unexpected_error;
		   END IF;
		END IF;
	      END IF;

              BEGIN
		 SELECT COUNT(1) INTO l_total_to_serials_reserved FROM
		   mtl_serial_numbers  WHERE reservation_id =
		   l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		   l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		    END IF;
	      END;
	      IF (l_total_to_serials_reserved > l_to_primary_reservation_qty) THEN
		 fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

              BEGIN
		 UPDATE mtl_reservations SET serial_reservation_quantity
		   = l_total_to_serials_reserved WHERE reservation_id =
		   l_orig_rsv_tbl(1).reservation_id;

	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_ROW');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;

	    ELSIF (NOT l_transfer_all) THEN
		    -- check to see if there are excess serials in from
		    -- record. if so, validate and move them to to record
		    -- then count and update the serial count

	      IF (l_debug = 1) THEN
		 debug_print('Inside param 4. not transfer_all');
	      END IF;

	      IF (l_total_serials_reserved > 0) THEN
	        BEGIN
		   SELECT inventory_item_id, serial_number bulk collect INTO
		     l_validate_serial_number_table FROM
		     mtl_serial_numbers  WHERE reservation_id =
		     l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		     l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
		EXCEPTION
		   WHEN no_data_found THEN
		      IF l_debug=1 THEN
			 debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		      END IF;
		END;

		l_validate_serials_reserved := l_validate_serial_number_table.COUNT;
		IF l_debug=1 THEN
		   debug_print('Total reserved serials: ' || l_validate_serials_reserved);
		END IF;

		IF (l_validate_serials_reserved > l_from_primary_reservation_qty) THEN
		   -- we have to unreserve some of the serials
		   -- unreserve the extra serials that are more than the primary_reservation_quantity
		   IF (l_debug = 1) THEN
		      debug_print('Total serials more than reservation quantity.');
		   END IF;

		   IF (l_validate_serials_reserved > 0) THEN
		      inv_reservation_validate_pvt.validate_serials
			(
			 x_return_status              => l_return_status
			 , p_rsv_action_name         => 'TRANSFER'
			 , p_orig_rsv_rec             => l_dummy_rsv_rec
			 , p_to_rsv_rec               => l_to_rsv_rec
			 , p_orig_serial_array        => l_dummy_serial_array
			 , p_to_serial_array          => l_validate_serial_number_table
			 );

		      IF (l_debug = 1) THEN
			 debug_print('After calling validate serials ' || l_return_status);
		      END IF;

		      --
		      IF l_return_status = fnd_api.g_ret_sts_error THEN
			 RAISE fnd_api.g_exc_error;
		      END IF;

		      --
		      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
			 RAISE fnd_api.g_exc_unexpected_error;
		      END IF;

		      l_serials_tobe_unreserved := l_validate_serials_reserved -  l_from_primary_reservation_qty;

		      FOR i IN 1..l_serials_tobe_unreserved
			LOOP
	                  BEGIN
			     UPDATE mtl_serial_numbers SET reservation_id = l_to_reservation_id,
			       group_mark_id = l_to_reservation_id WHERE
			       serial_number = l_validate_serial_number_table(i).serial_number AND
			       inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id AND
			       current_organization_id = l_orig_rsv_tbl(1).organization_id;
			  EXCEPTION
			     WHEN no_data_found THEN
				IF l_debug=1 THEN
				   debug_print('No serials found for serial number: ' || l_validate_serial_number_table(i).serial_number);
				END IF;
				fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
				fnd_msg_pub.ADD;
				RAISE fnd_api.g_exc_error;
			  END;

			  IF l_debug=1 THEN
			     debug_print('Serial being unreserved. serial number: ' || l_serial_number_table(i).serial_number);
			  END IF;

			END LOOP;
		   END IF;
		END IF;
	      END IF;

	      BEGIN
		 SELECT COUNT(1) INTO l_total_to_serials_reserved FROM
		   mtl_serial_numbers  WHERE reservation_id =
		   l_to_reservation_id AND current_organization_id =
		   l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_to_reservation_id);
		    END IF;
	      END;
	      IF (l_total_to_serials_reserved > l_to_primary_reservation_qty) THEN
		 fnd_message.set_name('INV', 'INV_SERIAL_QTY_MORE_THAN_RSV');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      BEGIN
		 UPDATE mtl_reservations SET serial_reservation_quantity
		   = l_total_to_serials_reserved WHERE reservation_id =
		   l_to_reservation_id;

	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_to_reservation_id);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_ROW');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;

              BEGIN
		 SELECT COUNT(1) INTO l_total_from_serials_reserved FROM
		   mtl_serial_numbers  WHERE reservation_id =
		   l_orig_rsv_tbl(1).reservation_id AND current_organization_id =
		   l_orig_rsv_tbl(1).organization_id AND inventory_item_id = l_orig_rsv_tbl(1).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		    END IF;
	      END;

              BEGIN
		 UPDATE mtl_reservations SET serial_reservation_quantity
		   = l_total_from_serials_reserved WHERE reservation_id =
		   l_orig_rsv_tbl(1).reservation_id;

	      EXCEPTION
		 WHEN no_data_found THEN
		    IF l_debug=1 THEN
		       debug_print('No serials found for reservation record. id: ' || l_orig_rsv_tbl(1).reservation_id);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INVALID_ROW');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;

	   END IF;-- transfer all and to row exist

    END IF;-- param = 4

    /*** End R12 ***/

    /**** {{ R12 Enhanced reservations code changes. Should be
    -- releasing the locks. }} *****/
    IF l_lock_obtained THEN
       inv_reservation_lock_pvt.release_lock
	 (l_supply_lock_handle);
       inv_reservation_lock_pvt.release_lock
	 (l_demand_lock_handle);
    END IF;
    /*** End R12 ***/

    x_return_status  := l_return_status;
  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
	ROLLBACK TO transfer_reservation_sa;
	x_return_status  := fnd_api.g_ret_sts_error;
	/**** {{ R12 Enhanced reservations code changes. Should be
	-- releasing the locks. }} *****/
	IF l_lock_obtained THEN
	   inv_reservation_lock_pvt.release_lock
	     (l_supply_lock_handle);
	   inv_reservation_lock_pvt.release_lock
	     (l_demand_lock_handle);
	END IF;
	/*** End R12 ***/
	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN fnd_api.g_exc_unexpected_error THEN
	ROLLBACK TO transfer_reservation_sa;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	/**** {{ R12 Enhanced reservations code changes. Should be
	-- releasing the locks. }} *****/
	IF l_lock_obtained THEN
	   inv_reservation_lock_pvt.release_lock
	     (l_supply_lock_handle);
	   inv_reservation_lock_pvt.release_lock
	     (l_demand_lock_handle);
	END IF;
	/*** End R12 ***/
	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN OTHERS THEN
	ROLLBACK TO transfer_reservation_sa;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	/**** {{ R12 Enhanced reservations code changes. Should be
	-- releasing the locks. }} *****/
	IF l_lock_obtained THEN
	   inv_reservation_lock_pvt.release_lock
	     (l_supply_lock_handle);
	   inv_reservation_lock_pvt.release_lock
	     (l_demand_lock_handle);
	END IF;
	/*** End R12 ***/
	IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	END IF;

	--  Get message count and data
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END transfer_reservation;

  --
  -- Procedure
  /*
  ** ----------------------------------------------------------------------
  ** For Order Management(OM) use only. Please read below:
  ** MUST PASS DEMAND SOURCE HEADER ID AND DEMAND SOURCE LINE ID
  ** ----------------------------------------------------------------------
  ** This API has been written exclusively for Order Management, who query
  ** reservations extensively.
  ** The generic query reservation API, query_reservation(see signature above)
  ** builds a dynamic SQL to satisfy all callers as it does not know what the
  ** search criteria is, at design time.
  ** The dynamic SQL consumes soft parse time, which reduces performance.
  ** An excessive use of query_reservation contributes to performance
  ** degradation because of soft parse times.
  ** Since we know what OM would always use to query reservations
  ** - demand source header id and demand source line id, a new API
  ** with static SQL would be be effective, with reduced performance impact.
  ** ----------------------------------------------------------------------
  ** Since OM has been using query_reservation before this, the signature of the
  ** new API below remains the same to cause minimal impact.
  ** ----------------------------------------------------------------------
  **Bug 2872822 Added new constants for p_query_by_req_date and handled two
  ** new cursors.Did not use Dynamic SQL for parsing performance issue.
  */
  PROCEDURE query_reservation_om_hdr_line(
    p_api_version_number        IN     NUMBER
  , p_init_msg_lst              IN     VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status             OUT    NOCOPY VARCHAR2
  , x_msg_count                 OUT    NOCOPY NUMBER
  , x_msg_data                  OUT    NOCOPY VARCHAR2
  , p_query_input               IN     inv_reservation_global.mtl_reservation_rec_type
  , p_lock_records              IN     VARCHAR2 DEFAULT fnd_api.g_false
  , p_sort_by_req_date          IN     NUMBER DEFAULT inv_reservation_global.g_query_no_sort
  , p_cancel_order_mode         IN     NUMBER DEFAULT inv_reservation_global.g_cancel_order_no
  , x_mtl_reservation_tbl       OUT    NOCOPY inv_reservation_global.mtl_reservation_tbl_type
  , x_mtl_reservation_tbl_count OUT    NOCOPY NUMBER
  , x_error_code                OUT    NOCOPY NUMBER
  ) IS
    l_api_version_number CONSTANT NUMBER                                          := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)                                    := 'Query_Reservation_OM_Hdr_Line';
    l_return_status               VARCHAR2(1)                                     := fnd_api.g_ret_sts_success;
    l_counter                     INTEGER;
    l_rsv_rec                     inv_reservation_global.mtl_reservation_rec_type;

    --   Cursor to fetch MTL_RESERVATION record based on passed
    --   demand_source_header_id and demand_source_line_id

    -- INVCONV - Incorporate secondary columns
    CURSOR mrc(dmd_source_header_id NUMBER, dmd_source_line_id NUMBER) IS
       SELECT
	 mr.reservation_id
	 , mr.requirement_date
	 , mr.organization_id
	 , mr.inventory_item_id
	 , mr.demand_source_type_id
	 , mr.demand_source_name
	 , mr.demand_source_header_id
	 , mr.demand_source_line_id
	 , mr.demand_source_delivery
	 , mr.primary_uom_code
	 , mr.primary_uom_id
	 , mr.secondary_uom_code
	 , mr.secondary_uom_id
	 , mr.reservation_uom_code
	 , mr.reservation_uom_id
	 , mr.reservation_quantity
	 , mr.primary_reservation_quantity
	 , mr.secondary_reservation_quantity
	 , mr.detailed_quantity
	 , mr.secondary_detailed_quantity
	 , mr.autodetail_group_id
	 , mr.external_source_code
	 , mr.external_source_line_id
	 , mr.supply_source_type_id
	 , mr.supply_source_header_id
	 , mr.supply_source_line_id
	 , mr.supply_source_name
	 , mr.supply_source_line_detail
	 , mr.revision
	 , mr.subinventory_code
	 , mr.subinventory_id
	 , mr.locator_id
	 , mr.lot_number
	 , mr.lot_number_id
	 , mr.pick_slip_number
	 , mr.lpn_id
	 , mr.attribute_category
	 , mr.attribute1
	 , mr.attribute2
	 , mr.attribute3
	 , mr.attribute4
	 , mr.attribute5
	 , mr.attribute6
	 , mr.attribute7
	 , mr.attribute8
	 , mr.attribute9
	 , mr.attribute10
	 , mr.attribute11
	 , mr.attribute12
	 , mr.attribute13
	 , mr.attribute14
	 , mr.attribute15
	 , mr.ship_ready_flag
	 , mr.staged_flag
	 /**** {{ R12 Enhanced reservations code changes }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
	 , serial_number
	 /***** End R12 ***/

          FROM mtl_reservations mr
         WHERE demand_source_type_id IN (inv_reservation_global.g_source_type_oe
                                       , inv_reservation_global.g_source_type_internal_ord
                                       , inv_reservation_global.g_source_type_rma
                                        )
           AND demand_source_header_id = dmd_source_header_id
           AND demand_source_line_id = dmd_source_line_id
      ORDER BY NVL(mr.revision, ' ')
             , NVL(mr.lot_number, ' ')
             , NVL(mr.subinventory_code, ' ')
             , NVL(mr.locator_id, 0);

    --   Bug#2872822 Cursor to fetch MTL_RESERVATION record based on passed
    --   demand_source_header_id and demand_source_line_id
    --   the records are obtained in the ascending order of requirement_date
    -- INVCONV - Incorporate secondary columns
    CURSOR mrc_asc(dmd_source_header_id NUMBER, dmd_source_line_id NUMBER) IS
       SELECT
	 mr.reservation_id
	 , mr.requirement_date
	 , mr.organization_id
	 , mr.inventory_item_id
	 , mr.demand_source_type_id
	 , mr.demand_source_name
	 , mr.demand_source_header_id
	 , mr.demand_source_line_id
	 , mr.demand_source_delivery
	 , mr.primary_uom_code
	 , mr.primary_uom_id
	 , mr.reservation_uom_code
	 , mr.reservation_uom_id
	 , mr.secondary_uom_code
	 , mr.secondary_uom_id
	 , mr.reservation_quantity
	 , mr.primary_reservation_quantity
	 , mr.secondary_reservation_quantity
	 , mr.detailed_quantity
	 , mr.secondary_detailed_quantity
	 , mr.autodetail_group_id
	 , mr.external_source_code
	 , mr.external_source_line_id
	 , mr.supply_source_type_id
	 , mr.supply_source_header_id
	 , mr.supply_source_line_id
	 , mr.supply_source_name
	 , mr.supply_source_line_detail
	 , mr.revision
	 , mr.subinventory_code
	 , mr.subinventory_id
	 , mr.locator_id
	 , mr.lot_number
	 , mr.lot_number_id
	 , mr.pick_slip_number
	 , mr.lpn_id
	 , mr.attribute_category
	 , mr.attribute1
	 , mr.attribute2
	 , mr.attribute3
	 , mr.attribute4
	 , mr.attribute5
	 , mr.attribute6
	 , mr.attribute7
	 , mr.attribute8
	 , mr.attribute9
	 , mr.attribute10
	 , mr.attribute11
	 , mr.attribute12
	 , mr.attribute13
	 , mr.attribute14
	 , mr.attribute15
	 , mr.ship_ready_flag
	 , mr.staged_flag
/**** {{ R12 Enhanced reservations code changes }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
	 , serial_number
	 /***** End R12 ***/

          FROM mtl_reservations mr
         WHERE demand_source_type_id IN (inv_reservation_global.g_source_type_oe
                                       , inv_reservation_global.g_source_type_internal_ord
                                       , inv_reservation_global.g_source_type_rma
                                        )
           AND demand_source_header_id = dmd_source_header_id
           AND demand_source_line_id = dmd_source_line_id
      ORDER BY mr.requirement_date asc
             , NVL(mr.revision, ' ')
             , NVL(mr.lot_number, ' ')
             , NVL(mr.subinventory_code, ' ')
             , NVL(mr.locator_id, 0);

    --   Bug#2872822 Cursor to fetch MTL_RESERVATION record based on passed
    --   demand_source_header_id and demand_source_line_id
    --   the records are obtained in the descending order of requirement_date
    -- INVCONV - Incorporate secondary columns
    CURSOR mrc_desc(dmd_source_header_id NUMBER, dmd_source_line_id NUMBER) IS
       SELECT
	 mr.reservation_id
	 , mr.requirement_date
	 , mr.organization_id
	 , mr.inventory_item_id
	 , mr.demand_source_type_id
	 , mr.demand_source_name
	 , mr.demand_source_header_id
	 , mr.demand_source_line_id
	 , mr.demand_source_delivery
	 , mr.primary_uom_code
	 , mr.primary_uom_id
	 , mr.secondary_uom_code
	 , mr.secondary_uom_id
	 , mr.reservation_uom_code
	 , mr.reservation_uom_id
	 , mr.reservation_quantity
	 , mr.primary_reservation_quantity
	 , mr.secondary_reservation_quantity
	 , mr.detailed_quantity
	 , mr.secondary_detailed_quantity
	 , mr.autodetail_group_id
	 , mr.external_source_code
	 , mr.external_source_line_id
	 , mr.supply_source_type_id
	 , mr.supply_source_header_id
	 , mr.supply_source_line_id
	 , mr.supply_source_name
	 , mr.supply_source_line_detail
	 , mr.revision
	 , mr.subinventory_code
	 , mr.subinventory_id
	 , mr.locator_id
	 , mr.lot_number
	 , mr.lot_number_id
	 , mr.pick_slip_number
	 , mr.lpn_id
	 , mr.attribute_category
	 , mr.attribute1
	 , mr.attribute2
	 , mr.attribute3
	 , mr.attribute4
	 , mr.attribute5
	 , mr.attribute6
	 , mr.attribute7
	 , mr.attribute8
	 , mr.attribute9
	 , mr.attribute10
	 , mr.attribute11
	 , mr.attribute12
	 , mr.attribute13
	 , mr.attribute14
	 , mr.attribute15
	 , mr.ship_ready_flag
	 , mr.staged_flag
	 /**** {{ R12 Enhanced reservations code changes }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
	 , serial_number
	 /***** End R12 ***/

          FROM mtl_reservations mr
         WHERE demand_source_type_id IN (inv_reservation_global.g_source_type_oe
                                       , inv_reservation_global.g_source_type_internal_ord
                                       , inv_reservation_global.g_source_type_rma
                                        )
           AND demand_source_header_id = dmd_source_header_id
           AND demand_source_line_id = dmd_source_line_id
      ORDER BY mr.requirement_date DESC
             , NVL(mr.revision, ' ')
             , NVL(mr.lot_number, ' ')
             , NVL(mr.subinventory_code, ' ')
             , NVL(mr.locator_id, 0);
  BEGIN
    x_error_code                 := inv_reservation_global.g_err_unexpected;

    --
    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    /*
    ** Make sure the required parameters are passed
    */
    IF (p_query_input.demand_source_header_id = fnd_api.g_miss_num
        OR p_query_input.demand_source_header_id IS NULL
       ) THEN
      fnd_message.set_name('INV', 'INV-RSV-INPUT-MISSING');
      fnd_message.set_token('FIELD_NAME', 'demand_source_header_id');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_query_input.demand_source_line_id = fnd_api.g_miss_num
        OR p_query_input.demand_source_line_id IS NULL
       ) THEN
      fnd_message.set_name('INV', 'INV-RSV-INPUT-MISSING');
      fnd_message.set_token('FIELD_NAME', 'demand_source_line_id');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --Bug#2872822/2914726 OM call to this API passes null. This was changed
    -- handle null also.
    IF (p_sort_by_req_date NOT IN ( inv_reservation_global.g_query_req_date_inv_asc,
				   inv_reservation_global.g_query_req_date_inv_desc)) OR p_sort_by_req_date IS NULL
      then
       OPEN mrc(p_query_input.demand_source_header_id, p_query_input.demand_source_line_id);
       l_counter                    := 0;

       LOOP
         FETCH mrc INTO l_rsv_rec;
         EXIT WHEN mrc%NOTFOUND;
         l_counter                         := l_counter + 1;
         x_mtl_reservation_tbl(l_counter)  := l_rsv_rec;
       END LOOP;

       CLOSE mrc;
    ELSIF p_sort_by_req_date =inv_reservation_global.g_query_req_date_inv_asc then
           OPEN mrc_asc(p_query_input.demand_source_header_id,
                                    p_query_input.demand_source_line_id);
         l_counter                    := 0;
        LOOP
        FETCH mrc_asc INTO l_rsv_rec;
        EXIT WHEN mrc_asc%NOTFOUND;
        l_counter                         := l_counter + 1;
        x_mtl_reservation_tbl(l_counter)  := l_rsv_rec;
        END LOOP;
        CLOSE mrc_asc;
    ELSIF p_sort_by_req_date =inv_reservation_global.g_query_req_date_inv_desc then
         OPEN mrc_desc(p_query_input.demand_source_header_id,
                                    p_query_input.demand_source_line_id);
            l_counter                    := 0;
          LOOP
          FETCH mrc_desc INTO l_rsv_rec;
          EXIT WHEN mrc_desc%NOTFOUND;
          l_counter                         := l_counter + 1;
          x_mtl_reservation_tbl(l_counter)  := l_rsv_rec;
          END LOOP;

         CLOSE  mrc_desc;

    END IF; --Sort by req date
    --
    x_mtl_reservation_tbl_count  := l_counter;
    x_return_status              := l_return_status;
    x_error_code                 := inv_reservation_global.g_err_no_error;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END query_reservation_om_hdr_line;

  -- Change the signiture of upd_reservation_pup for bug 2879208
  -- Create overload porceudre

  PROCEDURE Upd_Reservation_Pup_New(
    x_return_status           OUT    NOCOPY VARCHAR2
  , x_msg_count               OUT    NOCOPY NUMBER
  , x_msg_data                OUT    NOCOPY VARCHAR2
  , p_commit                  IN     VARCHAR2 := fnd_api.g_false
  , p_init_msg_list           IN     VARCHAR2 := fnd_api.g_false
  , p_organization_id         IN     NUMBER
  , p_demand_source_header_id IN     NUMBER
  , p_demand_source_line_id   IN     NUMBER
  , p_from_subinventory_code  IN     VARCHAR2
  , p_from_locator_id         IN     NUMBER
  , p_to_subinventory_code    IN     VARCHAR2
  , p_to_locator_id           IN     NUMBER
  , p_inventory_item_id       IN     NUMBER
  , p_revision                IN     VARCHAR2
  , p_lot_number              IN     VARCHAR2
  , p_quantity                IN     NUMBER
  , p_uom                     IN     VARCHAR2
  , p_lpn_id                  IN     NUMBER   := NULL
  , p_validation_flag         IN     VARCHAR2 := fnd_api.g_false
  , p_force_reservation_flag  IN     VARCHAR2 := fnd_api.g_false
  , p_requirement_date        IN     DATE DEFAULT NULL  -- bug 2879208
  , p_source_lpn_id           IN     NUMBER   := NULL -- Bug 4016953/3871066
  , p_demand_source_name      IN     VARCHAR2 DEFAULT NULL -- RTV Project
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)  := 'Upd_Reservation_PUP_New';
    l_api_version CONSTANT NUMBER        := 1.0;
    l_debug                NUMBER;
    l_progress             VARCHAR2(500) := '0';

    -- Variables used by API logic
    l_remaining_qty           NUMBER;
    l_remaining_qty_uom        VARCHAR2(3);
    l_call_xfr_rsv            BOOLEAN := FALSE;
    l_reservation_id          NUMBER;
    l_demand_source_header_id NUMBER;

    -- MTL_RESERVATIONS record type declarations
    l_src_rsv       inv_reservation_global.mtl_reservation_rec_type;
    l_xfr_rsv       inv_reservation_global.mtl_reservation_rec_type;
    l_serial_number inv_reservation_global.serial_number_tbl_type;

    l_primary_quantity NUMBER;  --The two for 14011079
    l_primary_uom_code VARCHAR(3);
    -- Cursor to fetch the from reservations
    -- INVCONV - Incorporate secondaries into select
    CURSOR  rsv_cur(v_quantity NUMBER) IS  --add one parameter for bug 14011079
       SELECT
	 reservation_id
	 , requirement_date
	 , organization_id
	 , inventory_item_id
	 , demand_source_type_id
	 , demand_source_name
	 , demand_source_header_id
	 , demand_source_line_id
	 , demand_source_delivery
	 , primary_uom_code
	 , primary_uom_id
	 , secondary_uom_code
	 , secondary_uom_id
	 , reservation_uom_code
	 , reservation_uom_id
	 , reservation_quantity
	 , primary_reservation_quantity
	 , secondary_reservation_quantity
	 , detailed_quantity
	 , secondary_detailed_quantity
	 , autodetail_group_id
	 , external_source_code
	 , external_source_line_id
	 , supply_source_type_id
	 , supply_source_header_id
	 , supply_source_line_id
	 , supply_source_name
	 , supply_source_line_detail
	 , revision
	 , subinventory_code
	 , subinventory_id
	 , locator_id
	 , lot_number
	 , lot_number_id
	 , pick_slip_number
	 , lpn_id
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
	 , ship_ready_flag
	 , staged_flag
	 /**** {{ R12 Enhanced reservations code changes }}****/
	 , crossdock_flag
	 , crossdock_criteria_id
	 , demand_source_line_detail
	 , serial_reservation_quantity
	 , supply_receipt_date
	 , demand_ship_date
	 , project_id
	 , task_id
	 , orig_supply_source_type_id
	 , orig_supply_source_header_id
	 , orig_supply_source_line_id
	 , orig_supply_source_line_detail
	 , orig_demand_source_type_id
	 , orig_demand_source_header_id
	 , orig_demand_source_line_id
	 , orig_demand_source_line_detail
	 , serial_number
	 /***** End R12 ***/

        FROM mtl_reservations
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         AND (p_revision IS NULL OR revision = p_revision)
         AND (demand_source_header_id = l_demand_source_header_id OR l_demand_source_header_id IS NULL)
         AND (demand_source_line_id = p_demand_source_line_id   OR p_demand_source_line_id is NULL)
		 AND (demand_source_name =  p_demand_source_name OR p_demand_source_name IS NULL)  --RTV Changes
         AND subinventory_code = p_from_subinventory_code
         AND locator_id = p_from_locator_id
         AND (p_lot_number IS NULL OR lot_number = p_lot_number)
         -- NVL added to prevent dependency on TM to not break existing code
         -- by resulting in a no records found if p_source_lpn_id is null.
         -- All new calls to this api starting with this bug
         -- fix (4016953/3871066) pass the p_source_lpn_id
         AND (lpn_id = NVL(p_source_lpn_id, lpn_id) OR lpn_id IS NULL)
     ORDER BY lpn_id asc, abs(primary_reservation_quantity-v_quantity); -- for bug 14011079 add the last order

  BEGIN
    -- Initialize return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    SAVEPOINT upd_reservation_pup_new;
    l_remaining_qty           := p_quantity;
    l_remaining_qty_uom       := p_uom;
    l_demand_source_header_id := INV_SALESORDER.Get_Salesorder_For_OEHeader(p_demand_source_header_id);

    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
       debug_print(l_api_name || ' Entered ' || g_pkg_version);
       debug_print('orgid='||p_organization_id||' shdid='||p_demand_source_header_id||' slnid='||
         p_demand_source_line_id||' fsub='||p_from_subinventory_code||' floc='||p_from_locator_id);
       debug_print('tsub='||p_to_subinventory_code||' tloc='||p_to_locator_id||' itm='||p_inventory_item_id||
	  ' rev=' ||p_revision||' lot='||p_lot_number||' qty='||p_quantity||' uom='||p_uom);
       debug_print('lpn='||p_lpn_id||' val='||p_validation_flag||' frc='||p_force_reservation_flag||' rdate='||
          to_char(p_requirement_date, 'MON-DD-YYYY HH:MI:SS')||' dsrc='||l_demand_source_header_id||' slpn='||p_source_lpn_id);
    END IF;
    -- add for bug 14011079 convert quantiy to primary_quantity if it is not.
    l_primary_quantity :=p_quantity;
    l_primary_uom_code :=NULL;

    IF p_organization_id IS NOT NULL AND p_inventory_item_id IS NOT NULL THEN
      BEGIN
        IF inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) THEN
           l_primary_uom_code := inv_cache.item_rec.primary_uom_code;
           IF (l_debug = 1) THEN
              debug_print('l_primary_uom_code='||l_primary_uom_code);
           END IF;
        END IF;
        IF l_primary_uom_code IS NOT NULL AND l_primary_uom_code<>p_uom THEN
           l_primary_quantity := inv_convert.inv_um_convert(item_id   => p_inventory_item_id
            , lot_number		=> p_lot_number
            , organization_id      => p_organization_id
            , PRECISION            => NULL -- use default precision
            , from_quantity        => p_quantity
            , from_unit            => p_uom
            , to_unit              => l_primary_uom_code
            , from_name            => NULL -- from uom name
            , to_name              => NULL); -- to uom name
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        debug_print('Conversion to Primay UOM Failed for p_quantity and p_uom');
        l_primary_quantity :=p_quantity;
      END;
    END IF;

    IF (l_debug = 1) THEN
      debug_print('After Conversion l_primary_quantity='||l_primary_quantity);
      debug_print('After Conversion l_primary_uom_code='||l_primary_uom_code);
    END IF;
    FOR l_src_rsv IN rsv_cur(l_primary_quantity) LOOP
    -- end for 14011079
      IF (l_debug = 1) THEN
        debug_print('Got rsvid= '||l_src_rsv.reservation_id||' qty=
                    '||l_src_rsv.primary_reservation_quantity||' uom=
                    '||l_src_rsv.primary_uom_code||' sub='||l_src_rsv.subinventory_code||' loc= '||
                    l_src_rsv.locator_id||' lpn= '||l_src_rsv.lpn_id);
        debug_print('l_remaining_qty: ' || l_remaining_qty || '
                   l_remaining_qty_uom ' || l_remaining_qty_uom || '
                   l_src_rsv.primary_uom_code:' || l_src_rsv.primary_uom_code);
      END IF;

       -- Copy all data from old reservation to the new reservation
      l_xfr_rsv := l_src_rsv;

      l_progress := 'Convert l_remaining_qty to rsv uom '||l_remaining_qty;
      IF ( l_remaining_qty_uom <> l_src_rsv.primary_uom_code ) THEN

        -- INVCONV - upgrade call to inv_um_convert to pass lot and org
        l_remaining_qty := inv_convert.inv_um_convert(
           item_id		=> l_src_rsv.inventory_item_id
         , lot_number		=> l_src_rsv.lot_number
         , organization_id      => l_src_rsv.organization_id
         , PRECISION            => NULL -- use default precision
         , from_quantity        => l_remaining_qty
         , from_unit            => l_remaining_qty_uom
         , to_unit              => l_src_rsv.primary_uom_code
         , from_name            => NULL -- from uom name
         , to_name              => NULL); -- to uom name

         IF l_remaining_qty = -99999 THEN
           -- conversion failed
           IF (l_debug = 1) THEN
             debug_print('Conversion to RSV UOM Failed');
           END IF;
           fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-RSV-UOM');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
         END IF;

          -- Remember UOM of current remaining quantity
          l_remaining_qty_uom := l_src_rsv.primary_uom_code;
        END IF;

        -- Even if the reservation does not need to be transfered we count the qty
        l_xfr_rsv.primary_reservation_quantity :=
          LEAST(l_src_rsv.Primary_reservation_quantity, l_remaining_qty);
        --l_xfr_rsv.primary_uom_code := l_src_rsv.primary_uom_code;
        l_remaining_qty := l_remaining_qty - l_xfr_rsv.primary_reservation_quantity;
        -- INVCONV B4242576 BEGIN
        -- compute secondaries as necessary for items tracking in primary and secondary
        IF l_src_rsv.secondary_uom_code is not null THEN
          IF (l_debug = 1) THEN
            debug_print('Dual tracked item so populate secondary quantities for '||l_src_rsv.secondary_uom_code);
          END IF;
          IF l_xfr_rsv.primary_reservation_quantity < l_src_rsv.primary_reservation_quantity THEN
            -- Transferring less than the full qty so determine the equivalent secondary
            l_xfr_rsv.secondary_reservation_quantity := inv_convert.inv_um_convert(
              item_id              => l_xfr_rsv.inventory_item_id
            , lot_number	   => l_xfr_rsv.lot_number
            , organization_id      => l_xfr_rsv.organization_id
            , PRECISION            => NULL -- use default precision
            , from_quantity        => l_xfr_rsv.primary_reservation_quantity
            , from_unit            => l_xfr_rsv.primary_uom_code
            , to_unit              => l_src_rsv.secondary_uom_code
            , from_name            => NULL -- from uom name
            , to_name              => NULL); -- to uom name

            IF l_remaining_qty = -99999 THEN
              -- conversion failed
              IF (l_debug = 1) THEN
                debug_print('Conversion to SECONDARY UOM Failed');
              END IF;
              fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-SECOND-UOM');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
            IF (l_debug = 1) THEN
              debug_print('After conversion secondary_qty= '||l_src_rsv.secondary_reservation_quantity); -- KYH
            END IF;
          END IF;
        END IF;
        -- INVCONV B4242576 END

      IF (l_debug = 1) THEN
         debug_print('l_remaining_qty before xfer: ' || l_remaining_qty || '
                     l_xfr_rsv.primary_reservation_quantity ' ||
                     l_xfr_rsv.primary_reservation_quantity);
      END IF;

      -- Only if the original reservation is at the LPN level should we
      -- transfer the reservatoin to the new LPN not applicable if p_lpn_id
      -- is null, i.e. whole staged LPN being subxfered
      -- Bug 3846145: The transfer should happen only if the source and the
      --destination lpns are different.
      IF ( l_src_rsv.lpn_id IS NOT NULL AND p_lpn_id IS NOT NULL AND
           (l_src_rsv.lpn_id <> p_lpn_id) ) THEN
         l_xfr_rsv.lpn_id := p_lpn_id;
         l_call_xfr_rsv := TRUE;
         IF (l_debug = 1) THEN
            debug_print('Inside source lpn and p_lpn are not null');
         END IF;
      END IF;

      -- If the reservation needs to transfer locations...
      IF ( l_src_rsv.subinventory_code <> p_to_subinventory_code OR
           l_src_rsv.locator_id        <> p_to_locator_id )
      THEN
        l_xfr_rsv.subinventory_code := p_to_subinventory_code;
        l_xfr_rsv.locator_id        := p_to_locator_id;
        l_call_xfr_rsv := TRUE;
        IF (l_debug = 1) THEN
            debug_print('Inside loc, sub or both are different');
         END IF;
      END IF;

      IF ( l_call_xfr_rsv ) THEN
        l_xfr_rsv.reservation_quantity := NULL;
        l_xfr_rsv.reservation_id       := NULL;

        l_progress := 'Call to Transfer_Reservation';
        INV_RESERVATION_PVT.Transfer_Reservation (
          p_api_version_number     => 1.0
        , p_init_msg_lst           => fnd_api.g_false
        , x_return_status          => x_return_status
        , x_msg_count              => x_msg_count
        , x_msg_data               => x_msg_data
        , p_original_rsv_rec       => l_src_rsv
        , p_to_rsv_rec             => l_xfr_rsv
        , p_original_serial_number => l_serial_number
        , p_validation_flag        => p_validation_flag
        , x_reservation_id         => l_reservation_id );

        IF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_call_xfr_rsv := FALSE;
        l_progress := 'Done with reservation loop';
      END IF;

      IF (l_debug = 1) THEN
        debug_print('new l_remaining_qty='||l_remaining_qty||' last reservation_id='||l_reservation_id);
      END IF;

      EXIT WHEN ROUND(l_remaining_qty, 5) <= 0;
    END LOOP;
    l_progress := 'Done with reservation loop';

    IF ( ROUND(l_remaining_qty, 5) > 0 ) THEN
      IF (l_debug = 1) THEN
        debug_print('Not enough reserved quantity l_remaining_qty='||l_remaining_qty);
      END IF;
      fnd_message.set_name('INV', 'INV_UPDATE_RSV_FAILED');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO upd_reservation_pup_new;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      IF (l_debug = 1) THEN
        debug_print(l_api_name ||' Exec Err prog='||l_progress||' SQL error: '|| SQLERRM(SQLCODE));
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO upd_reservation_pup_new;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      IF (l_debug = 1) THEN
        debug_print(l_api_name ||' Unexp Err prog='||l_progress||' SQL error: '|| SQLERRM(SQLCODE));
      END IF;
  END Upd_Reservation_PUP_New;


-- Create overload porceudre for bug 2879208
   PROCEDURE upd_reservation_pup(
    x_return_status           OUT    NOCOPY VARCHAR2
  , x_msg_count               OUT    NOCOPY NUMBER
  , x_msg_data                OUT    NOCOPY VARCHAR2
  , p_commit                  IN     VARCHAR2 := fnd_api.g_false
  , p_init_msg_list           IN     VARCHAR2 := fnd_api.g_false
  , p_organization_id         IN     NUMBER
  , p_demand_source_header_id IN     NUMBER
  , p_demand_source_line_id   IN     NUMBER
  , p_from_subinventory_code  IN     VARCHAR2
  , p_from_locator_id         IN     NUMBER
  , p_to_subinventory_code    IN     VARCHAR2
  , p_to_locator_id           IN     NUMBER
  , p_inventory_item_id       IN     NUMBER
  , p_revision                IN     VARCHAR2
  , p_lot_number              IN     VARCHAR2
  , p_quantity                IN     NUMBER
  , p_uom                     IN     VARCHAR2
  , p_validation_flag         IN     VARCHAR2 := fnd_api.g_false
  , p_force_reservation_flag  IN     VARCHAR2 := fnd_api.g_false
  )
     IS

   BEGIN
      upd_reservation_pup_new
	(
	 x_return_status              => x_return_status
	 , x_msg_count                  => x_msg_count
	 , x_msg_data                   => x_msg_data
	 , p_organization_id            => p_organization_id
	 , p_demand_source_header_id    => p_demand_source_header_id
	 , p_demand_source_line_id      => p_demand_source_line_id
	 , p_from_subinventory_code     => p_from_subinventory_code
	 , p_from_locator_id            => p_from_locator_id
	 , p_to_subinventory_code       => p_to_subinventory_code
	 , p_to_locator_id              => p_to_locator_id
	 , p_inventory_item_id          => p_inventory_item_id
	 , p_revision                   => p_revision
	 , p_lot_number                 => p_lot_number
	 , p_quantity                   => p_quantity
	 , p_uom                        => p_uom
	 , p_force_reservation_flag     => p_force_reservation_flag
	 , p_requirement_date           => NULL
        );
   END upd_reservation_pup;




  PROCEDURE transfer_lpn_trx_reservation(
    x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , p_commit                 IN     VARCHAR2 := fnd_api.g_false
  , p_init_msg_list          IN     VARCHAR2 := fnd_api.g_false
  , p_transaction_temp_id    IN     NUMBER := 0
  , p_organization_id        IN     NUMBER
  , p_lpn_id                 IN     NUMBER
  , p_from_subinventory_code IN     VARCHAR2
  , p_from_locator_id        IN     NUMBER
  , p_to_subinventory_code   IN     VARCHAR2
  , p_to_locator_id          IN     NUMBER
  , p_inventory_item_id      IN     NUMBER := NULL
  , p_revision               IN     VARCHAR2 := NULL
  , p_lot_number             IN     VARCHAR2 := NULL
  , p_trx_quantity           IN     NUMBER := NULL
  , p_trx_uom                IN     VARCHAR2 := NULL
  ) IS
    l_count    NUMBER  := 0;
    l_lotfound BOOLEAN := FALSE;


    l_api_version_number NUMBER := 1.0;

    l_loop_counter NUMBER := 0;   -- bug 2879208

    CURSOR c_lottmp IS
      SELECT lot_number
           , transaction_quantity
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_transaction_temp_id;

	    --bug 2648532 - performance changes
	    CURSOR lpn_deliveries IS
	       SELECT wdd.source_header_id
	            , wdd.source_line_id
	            , wdd.inventory_item_id
	            , wdd.revision
	            , wdd.lot_number
	            , wdd.requested_quantity
                    , wdd.picked_quantity --9699014
	            , wdd.requested_quantity_uom
	            , wdd.delivery_detail_id
	            , wdd2.lpn_id
	         FROM wsh_delivery_details wdd,
	              wsh_delivery_assignments wda,
	              wsh_delivery_details wdd2
	        WHERE wdd.container_flag = 'N' --bug4639858 Only want wdd lines that represent items
	          AND wdd.delivery_detail_id = wda.delivery_detail_id
	          AND wda.parent_delivery_detail_id = wdd2.delivery_detail_id
	          -- Workaround for performance issue 3631133
	          -- lpn_id for the LPN and it's child lpns will be stored in this global
	          -- temp table under the line_id.  this is to avoid a connect by statment
	          -- in this cursor
                  -- Note: Repeating the where condition below to force the db optimizer
                  -- to drive the main-query from sub-query. bug: 4145360
             AND wdd2.released_status = 'X'    -- For LPN reuse ER : 6845650
	          AND wdd2.lpn_id IN ( SELECT line_id
	                               FROM   WMS_TXN_CONTEXT_TEMP
	                               WHERE  txn_source_name = 'XFER_LPN_RES'
	                                 AND  txn_source_name = 'XFER_LPN_RES' );

    CURSOR item_deliveries(p_lot VARCHAR2) IS
      SELECT source_header_id
           , source_line_id
        FROM wsh_delivery_details
       WHERE inventory_item_id = p_inventory_item_id
         AND NVL(subinventory, '@@@@') = NVL(p_from_subinventory_code, '@@@@')
         AND NVL(revision, '@@@@') = NVL(p_revision, '@@@@')
         AND NVL(lot_number, '@@@@') = NVL(p_lot, '@@@@')
         AND delivery_detail_id IN
	(SELECT wda.delivery_detail_id
	 FROM wsh_delivery_assignments wda,
	 wsh_delivery_details wdd2,
	 wms_license_plate_numbers wlpn
	 WHERE wda.parent_delivery_detail_id = wdd2.delivery_detail_id
	 AND   wdd2.lpn_id                   = wlpn.lpn_id
	 AND   wlpn.outermost_lpn_id         = p_lpn_id
    AND   wdd2.released_status          = 'X');  -- For LPN reuse ER : 6845650

    l_debug number;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT transfer_lpn_trx_reservation;
    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;     -- Use cache to get value for l_debug

    l_debug := g_debug;
    -- If p_lpn_id parameter has been popluated, then transfer is a consolidation
    IF (p_inventory_item_id IS NULL) THEN
      -- retrieve all the delivery items for that lpn and call transfer reservatin api
      IF (l_debug = 1) THEN
         debug_print('Reservation transfer of whole lpn: consolidate', 9);
      END IF;

      -- Workaround for performance issue 3631133
      -- lpn_id for the LPN and it's child lpns will be stored in this global
      -- temp table under the line_id
      INSERT INTO WMS_TXN_CONTEXT_TEMP ( line_id, txn_source_name )
      SELECT distinct lpn_id, 'XFER_LPN_RES'
      FROM   wms_license_plate_numbers
      START WITH lpn_id = p_lpn_id
      CONNECT BY parent_lpn_id = PRIOR lpn_id;

      FOR lpn_del_rec IN lpn_deliveries LOOP
	 l_loop_counter := l_loop_counter + 1;   -- bug 2879208

        IF (l_debug = 1) THEN
           debug_print(
             'found rec src hdr id: '
          || lpn_del_rec.source_header_id
          || ' src line id: '
          || lpn_del_rec.source_line_id
          || ' item id: '
          || lpn_del_rec.inventory_item_id
          || ' rev: '
          || lpn_del_rec.revision
          || ' lot: '
          || lpn_del_rec.lot_number
	  || ' ddid='||lpn_del_rec.delivery_detail_id
	  || ' lpn='||lpn_del_rec.lpn_id
	  , 9
        );
        END IF;
        upd_reservation_pup_new(
          x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_organization_id            => p_organization_id
        , p_demand_source_header_id    => lpn_del_rec.source_header_id
        , p_demand_source_line_id      => lpn_del_rec.source_line_id
        , p_from_subinventory_code     => p_from_subinventory_code
        , p_from_locator_id            => p_from_locator_id
        , p_to_subinventory_code       => p_to_subinventory_code
        , p_to_locator_id              => p_to_locator_id
        , p_inventory_item_id          => lpn_del_rec.inventory_item_id
        , p_revision                   => lpn_del_rec.revision
        , p_lot_number                 => lpn_del_rec.lot_number
        , p_quantity                   => NVL(lpn_del_rec.picked_quantity,lpn_del_rec.requested_quantity)  --9699014
        , p_uom                        => lpn_del_rec.requested_quantity_uom
	, p_force_reservation_flag     => fnd_api.g_true
	, p_requirement_date           => (Sysdate + l_loop_counter/(24*3600))  -- bug 2879208
    , p_source_lpn_id              => lpn_del_rec.lpn_id --bug12722739
        );

        IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
             debug_print('upd_reservation_pup failed '|| x_msg_data, 1);
          END IF;
          fnd_message.set_name('WMS', 'UPD_RESERVATION_PUP_FAIL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      -- Workaround for performance issue 3631133
      -- need to delete the inserted values in temp table above
      DELETE FROM WMS_TXN_CONTEXT_TEMP
      WHERE  txn_source_name = 'XFER_LPN_RES';
    ELSE
      --LPN split, transfer reservation of a single item type
      IF (l_debug = 1) THEN
         debug_print('reservation transfer of item within an lpn: split', 9);
      END IF;

      --Check if item is lot controlled
      FOR v_lottmp IN c_lottmp LOOP
        l_loop_counter := l_loop_counter + 1;

        IF (l_debug = 1) THEN
           debug_print('item is lot controlled found lot= '|| v_lottmp.lot_number, 9);
        END IF;
        l_lotfound  := TRUE;

        FOR item_del_rec IN item_deliveries(v_lottmp.lot_number) LOOP
          IF (l_debug = 1) THEN
             debug_print('found rec src hdr id: '|| item_del_rec.source_header_id || ' src line id: ' || item_del_rec.source_line_id, 9);
          END IF;

          IF (l_count < 1) THEN
            upd_reservation_pup_new(
              x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_organization_id            => p_organization_id
            , p_demand_source_header_id    => item_del_rec.source_header_id
            , p_demand_source_line_id      => item_del_rec.source_line_id
            , p_from_subinventory_code     => p_from_subinventory_code
            , p_from_locator_id            => p_from_locator_id
            , p_to_subinventory_code       => p_to_subinventory_code
            , p_to_locator_id              => p_to_locator_id
            , p_inventory_item_id          => p_inventory_item_id
            , p_revision                   => p_revision
            , p_lot_number                 => v_lottmp.lot_number
            , p_quantity                   => v_lottmp.transaction_quantity
            , p_uom                        => p_trx_uom
            , p_force_reservation_flag     => fnd_api.g_true
            , p_requirement_date           => (Sysdate + l_loop_counter/(24*3600))
            );

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                 debug_print('upd_reservation_pup failed '|| x_msg_data, 1);
              END IF;
              fnd_message.set_name('WMS', 'UPD_RESERVATION_PUP_FAIL');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_count  := l_count + 1;
          ELSE
            IF (l_debug = 1) THEN
               debug_print('**Split disallowed for lpns with multiple delivery lines for the same item', 1);
            END IF;
            fnd_message.set_name('INV', 'INV_MULTI_DEL_SPLIT_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END LOOP;
      END LOOP;

      IF (NOT l_lotfound) THEN
        l_loop_counter := l_loop_counter + 1;

        --Non lot controlled item, or single lot entry use given parameters.
        IF (l_debug = 1) THEN
           debug_print('no rows found in mtlt, processing single row', 9);
        END IF;

        FOR item_del_rec IN item_deliveries(p_lot_number) LOOP
          IF (l_debug = 1) THEN
             debug_print('found rec src hdr id: '|| item_del_rec.source_header_id || ' src line id: ' || item_del_rec.source_line_id, 9);
          END IF;

          IF (l_count < 1) THEN
            upd_reservation_pup_new(
              x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_organization_id            => p_organization_id
            , p_demand_source_header_id    => item_del_rec.source_header_id
            , p_demand_source_line_id      => item_del_rec.source_line_id
            , p_from_subinventory_code     => p_from_subinventory_code
            , p_from_locator_id            => p_from_locator_id
            , p_to_subinventory_code       => p_to_subinventory_code
            , p_to_locator_id              => p_to_locator_id
            , p_inventory_item_id          => p_inventory_item_id
            , p_revision                   => p_revision
            , p_lot_number                 => p_lot_number
            , p_quantity                   => p_trx_quantity
            , p_uom                        => p_trx_uom
            , p_force_reservation_flag     => fnd_api.g_true
            , p_requirement_date           => (Sysdate + l_loop_counter/(24*3600))
            );

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                 debug_print('upd_reservation_pup failed '|| x_msg_data, 1);
              END IF;
              fnd_message.set_name('WMS', 'UPD_RESERVATION_PUP_FAIL');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_count  := l_count + 1;
          ELSE
            IF (l_debug = 1) THEN
               debug_print('**Split disallowed for lpns with multiple delivery lines for the same item', 1);
            END IF;
            fnd_message.set_name('INV', 'INV_MULTI_DEL_SPLIT_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END LOOP;
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      fnd_message.set_name('WMS', 'INV_XFR_RSV_FAILURE');
      fnd_msg_pub.ADD;
      ROLLBACK TO transfer_lpn_trx_reservation;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_message.set_name('WMS', 'INV_XFR_RSV_FAILURE');
      fnd_msg_pub.ADD;
      ROLLBACK TO transfer_lpn_trx_reservation;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      fnd_message.set_name('WMS', 'INV_XFR_RSV_FAILURE');
      fnd_msg_pub.ADD;
      ROLLBACK TO transfer_lpn_trx_reservation;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('wms_upd_res_pvt', 'TRANSFER_LPN_TRX_RESERVATION');
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END transfer_lpn_trx_reservation;

  PROCEDURE insert_rsv_temp(
    p_organization_id                  NUMBER
  , p_inventory_item_id                NUMBER
  , p_primary_reservation_quantity     NUMBER
  , p_tree_id                          NUMBER
  , p_reservation_id                   NUMBER
  , x_return_status                OUT NOCOPY VARCHAR2
  , p_demand_source_line_id            NUMBER
  , p_demand_source_header_id          NUMBER
  , p_demand_source_name               VARCHAR2
  ) IS
    l_api_name      VARCHAR2(100)  := 'Insert_rsv_temp';
    x_msg_count     NUMBER;
    x_msg_data      VARCHAR2(1000);
    l_return_status VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_debug         NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    INSERT INTO rsv_temp
                (
                p_organization_id
              , p_inventory_item_id
              , p_primary_reservation_quantity
              , p_tree_id
              , p_reservation_id
              , p_demand_source_line_id
              , p_demand_source_header_id
              , p_demand_source_name
                )
         VALUES (
                p_organization_id
              , p_inventory_item_id
              , p_primary_reservation_quantity
              , p_tree_id
              , p_reservation_id
              , p_demand_source_line_id
              , p_demand_source_header_id
              , p_demand_source_name
                );

         IF (l_debug = 1) THEN
            debug_print('Inserted rsv_temp org='||p_organization_id||' item='||p_inventory_item_id||', p_tree_id='||p_tree_id||', p_reservation_id='||p_reservation_id||', p_demand_source_line_id ='||p_demand_source_line_id);
         END IF;

    x_return_status  := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END insert_rsv_temp;

  --Ref 2132071 This procedure pick up reservations created from last commit issued
  --and check if there is any node violation.If there is one then it will clear
  --the reservations .This call also clears Quantity cache at the end of call
  --to ensure that bad trees are not in place.

  PROCEDURE do_check_for_commit(
    p_api_version_number  IN     NUMBER
  , p_init_msg_lst        IN     VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status       OUT    NOCOPY VARCHAR2
  , x_msg_count           OUT    NOCOPY NUMBER
  , x_msg_data            OUT    NOCOPY VARCHAR2
  , x_failed_rsv_temp_tbl OUT    NOCOPY inv_reservation_global.mtl_failed_rsv_tbl_type
  ) IS
    l_api_version_number CONSTANT NUMBER                                          := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)                                    := 'Do_check_for_commit';
    l_return_status               VARCHAR2(1)                                     := fnd_api.g_ret_sts_success;
    l_no_violation                BOOLEAN;
    l_root_id                     INTEGER;
    l_failed_rsv_temp_tbl         inv_reservation_global.mtl_failed_rsv_tbl_type;
    l_failed_rsv_temp_rec         inv_reservation_global.mtl_failed_rsv_rec_type;
    l_rsv_rec                     inv_reservation_global.mtl_reservation_rec_type;
    p_original_serial_number      inv_reservation_global.serial_number_tbl_type;
    l_reservation_id              NUMBER;
    l_failed_rsv_temp_tbl_count   INTEGER                                         := 0;
    l_error_code                  VARCHAR2(100);
    l_demand_source_line_id       NUMBER;
    l_demand_source_header_id     NUMBER;
    l_demand_source_name          VARCHAR2(1000);
    l_organization_id             NUMBER;
    l_inventory_item_id           NUMBER;

    l_debug                       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    -- Bug 3926414, added order by clause to avoid deadlock.
    CURSOR tree_csr IS
      SELECT p_tree_id
        FROM rsv_temp
        ORDER BY p_organization_id, p_inventory_item_id;

    --Bug 6812723, changing input from p_tree_id to l_tree_id
    CURSOR rsv_csr(l_tree_id NUMBER) IS
      SELECT p_reservation_id
           , p_organization_id
           , p_inventory_item_id
           , p_demand_source_line_id
           , p_demand_source_header_id
           , p_demand_source_name
        FROM rsv_temp
       WHERE p_tree_id = l_tree_id;
  BEGIN
    FOR tree_rec IN tree_csr LOOP

      IF (l_debug = 1) THEN
            debug_print('Calling do_check for tree_id = '||tree_rec.p_tree_id);
      END IF;

      inv_quantity_tree_pvt.do_check(p_api_version_number, p_init_msg_lst, l_return_status, x_msg_count, x_msg_data, tree_rec.p_tree_id, l_no_violation);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF NOT (l_no_violation) THEN
        OPEN rsv_csr(tree_rec.p_tree_id);

        LOOP
          FETCH rsv_csr INTO l_reservation_id, l_organization_id, l_inventory_item_id, l_demand_source_line_id, l_demand_source_header_id, l_demand_source_name;
          EXIT WHEN rsv_csr%NOTFOUND;
          l_rsv_rec.reservation_id                            := l_reservation_id;

          IF (l_debug = 1) THEN
                debug_print('Deleting Rsv for Org='||l_organization_id||', item='||l_inventory_item_id||', reservation_id='||l_reservation_id||', demand_source_line_id ='||l_demand_source_line_id);
             END IF;

          delete_reservation(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => p_init_msg_lst
          , x_return_status              => l_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_rsv_rec                    => l_rsv_rec
          , p_original_serial_number     => p_original_serial_number
          , p_validation_flag            => fnd_api.g_false
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          --
          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          --  END IF;
          END IF;

          l_failed_rsv_temp_tbl_count                         := l_failed_rsv_temp_tbl_count + 1;
          l_failed_rsv_temp_rec.reservation_id                := l_reservation_id;
          l_failed_rsv_temp_rec.organization_id               := l_organization_id;
          l_failed_rsv_temp_rec.inventory_item_id             := l_inventory_item_id;
          l_failed_rsv_temp_rec.demand_source_line_id         := l_demand_source_line_id;
          l_failed_rsv_temp_rec.demand_source_header_id       := l_demand_source_header_id;
          l_failed_rsv_temp_rec.demand_source_name            := l_demand_source_name;
          l_failed_rsv_temp_tbl(l_failed_rsv_temp_tbl_count)  := l_failed_rsv_temp_rec;
        END LOOP;

        IF rsv_csr%ISOPEN THEN
          CLOSE rsv_csr;
        END IF;
      END IF;
    END LOOP;

    x_failed_rsv_temp_tbl  := l_failed_rsv_temp_tbl;
    x_return_status        := l_return_status;
    inv_quantity_tree_pub.clear_quantity_cache;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END do_check_for_commit;

  /**** {{ R12 Enhanced reservations code changes }}****/
  PROCEDURE Transfer_Reservation_SubXfer
    ( p_api_version_number         IN  NUMBER   DEFAULT 1.0
    , p_init_msg_lst               IN  VARCHAR2 DEFAULT fnd_api.g_false
    , x_return_status              OUT NOCOPY VARCHAR2
    , x_msg_count                  OUT NOCOPY NUMBER
    , x_msg_data                   OUT NOCOPY VARCHAR2
    , p_Inventory_Item_Id          IN  Number
    , p_Organization_id            IN  Number
    , p_original_Reservation_Id    IN  Number
    , p_From_Serial_Number         IN  Varchar2
    , p_to_SubInventory            IN  Varchar2
    , p_To_Locator_Id              IN  Number
    , p_to_serial_number           IN  Varchar2
    , p_validation_flag            IN  VARCHAR2
    , x_to_reservation_id          OUT NOCOPY NUMBER)

    IS

        l_api_name    CONSTANT VARCHAR2(30) := 'Transfer_Reservation_SubXfer';
        -- Define local variables
        l_original_rsv_rec           inv_reservation_global.mtl_reservation_rec_type ;
        l_to_rsv_rec                 inv_reservation_global.mtl_reservation_rec_type ;
        l_original_serial_number_Tab inv_reservation_global.serial_number_tbl_type ;
        l_to_serial_number_Tab       inv_reservation_global.serial_number_tbl_type ;
        l_Reservation_Id             Number;
        l_return_status              VARCHAR2(1):= fnd_api.g_ret_sts_success;
	l_debug number;

        --Define a cursor that gets ReservationId information for a given org_id,
        --item_id and serial number information
        Cursor Get_Reservation_ID_Cur_Type
                     ( v_Serial_Number     Varchar2
                      ,v_Inventory_Item_Id Number
                      ,v_Organization_Id   Number ) IS

             Select Reservation_ID
               From Mtl_Serial_Numbers
              Where Inventory_Item_Id = v_Inventory_Item_Id
                and current_organization_id = v_Organization_id
                and Serial_Number = v_Serial_Number;
        BEGIN

           -- Use cache to get value for l_debug
           IF g_is_pickrelease_set IS NULL THEN
              g_is_pickrelease_set := 2;
              IF INV_CACHE.is_pickrelease THEN
                 g_is_pickrelease_set := 1;
              END IF;
           END IF;
           IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
              g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
           END IF;

           l_debug := g_debug;

              -- Check if reservation id parameter has any value if not then get value from mtl_serial_numbers table.
	   If p_original_Reservation_Id IS Null THEN
	      IF (l_debug = 1) THEN
		 debug_print('reservation_id is not passed');
	      END IF;
                   Open Get_Reservation_ID_Cur_Type
                        (p_From_Serial_Number,
                         p_Inventory_Item_Id,
                         p_Organization_Id );
                   Fetch Get_Reservation_ID_Cur_Type Into l_Reservation_Id;
                   Close Get_Reservation_ID_Cur_Type ;
	    ELSE
	      IF (l_debug = 1) THEN
		 debug_print('reservation_id is passed');
	      END IF;
                 l_Reservation_Id := p_original_Reservation_Id ;
              End If;
              If l_Reservation_Id IS NULL  Then
                   RAISE fnd_api.g_exc_unexpected_error;
              End If;

              l_original_rsv_rec.Reservation_id := l_Reservation_Id ;
              l_To_Rsv_Rec.subinventory_code    := p_to_SubInventory ;
              l_To_Rsv_Rec.locator_id           := p_To_Locator_Id ;
	      l_to_rsv_rec.primary_reservation_quantity := 1;
             -- l_Original_serial_number_Tab(1).Serial_Number := p_from_serial_number;
              l_to_serial_number_tab(1).Serial_Number       := p_to_serial_number;
              l_to_serial_number_tab(1).inventory_item_id   := p_inventory_item_id;
              --Call Reservation Transafer API

              Inv_Reservation_Pvt.transfer_reservation
		(
                 p_api_version_number     => p_api_version_number ,
                 p_init_msg_lst           => p_init_msg_lst,
                 x_return_status          => l_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data,
                 p_original_rsv_rec       => l_original_rsv_rec,
                 p_to_rsv_rec             => l_To_Rsv_Rec ,
                 p_original_serial_number => l_original_serial_number_Tab,
                 p_to_serial_number       => l_to_serial_number_Tab,
                 p_validation_flag        => p_Validation_Flag,
		 x_reservation_id         => x_To_Reservation_Id );

	      IF (l_debug = 1) THEN
		 debug_print('After calling transfer reservation. Return status: ' ||  l_return_status);
	      END IF;

	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF ;

           IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;

           x_return_status := l_return_status;

        EXCEPTION

            WHEN fnd_api.g_exc_error THEN
                x_return_status := fnd_api.g_ret_sts_error;

                --  Get message count and data
                fnd_msg_pub.count_and_get
                  (  p_count => x_msg_count
                   , p_data  => x_msg_data
                   );

           WHEN fnd_api.g_exc_unexpected_error THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error ;

                --  Get message count and data
                fnd_msg_pub.count_and_get
                  (  p_count  => x_msg_count
                   , p_data   => x_msg_data
                    );

            WHEN OTHERS THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error ;

                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
                  THEN
                   fnd_msg_pub.add_exc_msg
                     (  g_pkg_name
                      , l_api_name
                      );
                END IF;

                --  Get message count and data
                fnd_msg_pub.count_and_get
                  (  p_count  => x_msg_count
                   , p_data   => x_msg_data
                     );

  END transfer_reservation_SubXfer;

  PROCEDURE transfer_serial_rsv_in_LPN(
     x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_organization_id           IN  NUMBER
   , p_inventory_item_id         IN  NUMBER DEFAULT NULL
   , p_lpn_id                    IN  NUMBER
   , p_outermost_lpn_id          IN  NUMBER
   , p_to_subinventory_code      IN  VARCHAR2
   , p_to_locator_id             IN  NUMBER)
  IS
    l_api_name                   CONSTANT VARCHAR2(30) := 'transfer_serial_rsv_in_LPN';
    l_return_status              VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(1000);
    l_debug                      NUMBER;

    TYPE rsv_serials_item_rec    IS RECORD
      (
         reservation_id           NUMBER
       , serial_number            VARCHAR2(30)
       , inventory_item_id        NUMBER
      );

    TYPE rsv_serials_item_tbl IS TABLE OF rsv_serials_item_rec
      INDEX BY BINARY_INTEGER;

    l_rsv_serials_tbl            rsv_serials_item_tbl;
    l_serial_number_tbl          inv_reservation_global.serial_number_tbl_type;
    l_index                      NUMBER := 0;
    l_rsv_serials_tbl_count      NUMBER := 0;
    l_original_rsv_rec           inv_reservation_global.mtl_reservation_rec_type;
    l_to_rsv_rec                 inv_reservation_global.mtl_reservation_rec_type;
    l_reservation_id             NUMBER;

    -- cursor of getting reservations with serial_number reserved in the lpn which
    -- outermost_lpn_id of the lpn = p_outermost_lpn_id and the reservation does not
    -- have lpn reserved and p_inventory_item_id is passed.
    CURSOR serials_outer_lpn_with_item IS
       SELECT msn.reservation_id,
              msn.serial_number,
              msn.inventory_item_id
       FROM   mtl_reservations mr,
              mtl_serial_numbers msn
       WHERE  mr.organization_id = p_organization_id
       AND    mr.inventory_item_id = p_inventory_item_id
       AND    mr.reservation_id = msn.reservation_id
       AND    mr.lpn_id = null
       AND    msn.lpn_id IN (SELECT lpn_id
                             FROM   wms_license_plate_numbers
                             WHERE  outermost_lpn_id = p_outermost_lpn_id)
       GROUP BY msn.reservation_id, msn.serial_number, msn.inventory_item_id;

    -- cursor of getting reservations with serial_number reserved in the lpn which
    -- outermost_lpn_id of the lpn = p_outermost_lpn_id and the reservation does not
    -- have lpn reserved and p_inventory_item_id is not passed.
    CURSOR serials_outer_lpn_no_item IS
       SELECT msn.reservation_id,
              msn.serial_number,
              msn.inventory_item_id
       FROM   mtl_reservations mr,
              mtl_serial_numbers msn
       WHERE  mr.organization_id = p_organization_id
       AND    mr.reservation_id = msn.reservation_id
       AND    mr.lpn_id = null
       AND    msn.lpn_id IN (SELECT lpn_id
                             FROM   wms_license_plate_numbers
                             WHERE  outermost_lpn_id = p_outermost_lpn_id)
       GROUP BY msn.reservation_id, msn.serial_number, msn.inventory_item_id;

    -- cursor of getting reservations with serial_number reserved in the lpn
    -- which lpn_id = p_lpn_id and the reservation does not have lpn reserved
    -- and p_inventory_item_id is passed.
    CURSOR serials_lpn_with_item IS
       SELECT msn.reservation_id,
              msn.serial_number,
              msn.inventory_item_id
       FROM   mtl_reservations mr,
              mtl_serial_numbers msn
       WHERE  mr.organization_id = p_organization_id
       AND    mr.inventory_item_id = p_inventory_item_id
       AND    mr.reservation_id = msn.reservation_id
       AND    mr.lpn_id = null
       AND    msn.lpn_id = p_lpn_id
       GROUP BY msn.reservation_id, msn.serial_number, msn.inventory_item_id;

    -- cursor of getting reservations with serial_number reserved in the lpn
    -- which lpn_id = p_lpn_id and the reservation does not have lpn reserved
    -- and p_inventory_item_id is not passed.
    CURSOR serials_lpn_no_item IS
       SELECT msn.reservation_id,
              msn.serial_number,
              msn.inventory_item_id
       FROM   mtl_reservations mr,
              mtl_serial_numbers msn
       WHERE  mr.organization_id = p_organization_id
       AND    mr.reservation_id = msn.reservation_id
       AND    mr.lpn_id = null
       AND    msn.lpn_id = p_lpn_id
       GROUP BY msn.reservation_id, msn.serial_number, msn.inventory_item_id;

  BEGIN
    IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('In transfer_serial_rsv_in_LPN');
        debug_print('p_organization_id = ' || p_organization_id);
        debug_print('p_inventory_item_id = ' || p_inventory_item_id);
        debug_print('p_lpn_id = ' || p_lpn_id);
        debug_print('p_outermost_lpn_id = ' || p_outermost_lpn_id);
        debug_print('p_to_subinventory_code = ' || p_to_subinventory_code);
        debug_print('p_to_locator_id = ' || p_to_locator_id);
    END IF;

    IF (p_outermost_lpn_id is not NULL and p_lpn_id is not NULL) THEN
        IF (l_debug = 1) THEN
            debug_print('Error: both p_outermost_lpn_id and p_lpn_id are populated');
        END IF;
    ELSIF (p_outermost_lpn_id is not NULL) THEN
        IF (l_debug = 1) THEN
            debug_print('p_outermost_lpn_id is not NULL');
        END IF;

        IF (p_inventory_item_id is not NULL) THEN
            IF (l_debug = 1) THEN
                debug_print('p_inventory_item_id is not NULL');
            END IF;

            OPEN serials_outer_lpn_with_item;
            FETCH serials_outer_lpn_with_item BULK COLLECT INTO l_rsv_serials_tbl;
            CLOSE serials_outer_lpn_with_item;
        ELSE
            IF (l_debug = 1) THEN
                debug_print('p_inventory_item_id is NULL');
            END IF;

            OPEN serials_outer_lpn_no_item;
            FETCH serials_outer_lpn_no_item BULK COLLECT INTO l_rsv_serials_tbl;
            CLOSE serials_outer_lpn_no_item;
        END IF;
    ELSIF (p_lpn_id is not NULL) THEN
        IF (l_debug = 1) THEN
            debug_print('p_lpn_id is not NULL');
        END IF;

        IF (p_inventory_item_id is not NULL) THEN
            OPEN serials_lpn_with_item;
            FETCH serials_lpn_with_item BULK COLLECT INTO l_rsv_serials_tbl;
            CLOSE serials_lpn_with_item;
        ELSE
            OPEN serials_lpn_no_item;
            FETCH serials_lpn_no_item BULK COLLECT INTO l_rsv_serials_tbl;
            CLOSE serials_lpn_no_item;
        END IF;
    END IF;

    l_rsv_serials_tbl_count := l_rsv_serials_tbl.COUNT;
    l_index := 0;

    -- construct to reservation record if l_rsv_serials_tbl_count > 0
    IF (l_rsv_serials_tbl_count > 0) THEN
        l_to_rsv_rec.subinventory_code := p_to_subinventory_code;
        l_to_rsv_rec.locator_id := p_to_locator_id;

       -- construct original reservation record and serial number table
       FOR i in 1..l_rsv_serials_tbl_count LOOP
          l_index := l_index + 1;

          -- construct serial number table for same reservation_id
          l_serial_number_tbl(l_index).inventory_item_id := l_rsv_serials_tbl(i).inventory_item_id;
          l_serial_number_tbl(l_index).serial_number := l_rsv_serials_tbl(i).serial_number;

          -- need to check the next record's reservation id with current reservation_id
          -- or if it's the last record of the serial number table
          IF ((i+1 <= l_rsv_serials_tbl_count AND
                l_rsv_serials_tbl(i).reservation_id <> l_rsv_serials_tbl(i+1).reservation_id)
                  OR i = l_rsv_serials_tbl_count) THEN

             -- if the current reservation_id <> next record's reservation_id,
             -- or it is the last record of the serial number table, then
             -- finished construct the serial number table, contruct original reservation record
             -- and call transfer_reservation API

             l_original_rsv_rec.reservation_id := l_rsv_serials_tbl(i).reservation_id;

             IF (l_debug = 1) THEN
                 debug_print('calling transfer_reservations');
                 debug_print('original rec rsv id = ' || l_original_rsv_rec.reservation_id);
             END IF;

             inv_reservation_pvt.transfer_reservation(
                  p_api_version_number     => 1.0
                , p_init_msg_lst           => fnd_api.g_false
                , x_return_status          => l_return_status
                , x_msg_count              => l_msg_count
                , x_msg_data               => l_msg_data
                , p_original_rsv_rec       => l_original_rsv_rec
                , p_to_rsv_rec             => l_to_rsv_rec
                , p_original_serial_number => l_serial_number_tbl
                , p_to_serial_number       => l_serial_number_tbl
                , p_validation_flag        => fnd_api.g_true
                , x_reservation_id         => l_reservation_id
                );

             IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                IF (l_debug = 1) THEN
                   debug_print('Error return status from transfer_reservation');
                END IF;

                RAISE fnd_api.g_exc_error;
             ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                IF (l_debug = 1) THEN
                    debug_print('Unexpected return status from transfer_reservation');
                END IF;

                RAISE fnd_api.g_exc_unexpected_error;
             END IF;

             -- delete the content of l_serial_number_tbl and reset the index
             l_serial_number_tbl.DELETE;
             l_index := 0;
          END IF;
       END LOOP;
    END IF;

    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
          debug_print('unexpected error: ' || SQLERRM);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
          debug_print('others error: ' || SQLERRM);
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END transfer_serial_rsv_in_LPN;

/*** End R12 ***/

END inv_reservation_pvt;


/
