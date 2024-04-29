--------------------------------------------------------
--  DDL for Package Body WMS_CONSOLIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CONSOLIDATION_PUB" AS
/* $Header: WMSCONSB.pls 120.13.12010000.2 2008/08/25 06:50:57 anviswan ship $ */

/** Globals to hold Logging attributes **/
g_trace_on NUMBER := 0;

g_loc_type_dock_door       CONSTANT NUMBER := inv_globals.g_loc_type_dock_door;
g_loc_type_staging_lane    CONSTANT NUMBER := inv_globals.g_loc_type_staging_lane;
g_loc_type_consolidation   CONSTANT NUMBER := inv_globals.g_loc_type_consolidation;
g_loc_type_packing_station CONSTANT NUMBER := inv_globals.g_loc_type_packing_station;


PROCEDURE get_values_for_loc(p_sub                   IN  VARCHAR2,
			     p_loc_id                IN  NUMBER,
			     p_org_id                IN  NUMBER,
			     p_comp_cons_dels_inq_mode IN VARCHAR2,
			     x_total_no_of_dels      OUT NOCOPY NUMBER,
			     x_total_no_of_cons_dels OUT NOCOPY NUMBER,
			     x_total_no_of_lpns      OUT NOCOPY NUMBER,
			     x_return_status         OUT NOCOPY VARCHAR2,
			     x_msg_count             OUT NOCOPY NUMBER,
			     x_msg_data              OUT NOCOPY VARCHAR2)

  IS

     CURSOR del_csr IS
	SELECT DISTINCT
	  wda.delivery_id,
	  mil.inventory_location_id
	  FROM
	  wms_license_plate_numbers wlpn,
	  wsh_delivery_details wdd,
	  wsh_delivery_assignments_v wda,
	  mtl_item_locations mil
	  WHERE wlpn.organization_id   = p_org_id
	  AND   wlpn.locator_id        = mil.inventory_location_id
	  AND   Nvl(mil.physical_location_id, mil.inventory_location_id) = p_loc_id
	  AND   wlpn.subinventory_code = p_sub
	  AND   wlpn.lpn_context       in ( 11,12)
	  AND   wlpn.lpn_id            = wdd.lpn_id
	  AND   wdd.delivery_detail_id = wda.parent_delivery_detail_id
	  AND   wdd.organization_id    = p_org_id
	  AND   wda.delivery_id        IS NOT NULL
     AND   wdd.released_status = 'X';  -- For LPN reuse ER : 6845650

     l_count NUMBER;
     l_delivery_id NUMBER;
     l_locator_id NUMBER;

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   g_trace_on := fnd_profile.value('INV_DEBUG_TRACE') ;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_total_no_of_dels := 0;
   x_total_no_of_cons_dels := 0;


   OPEN del_csr;
   LOOP
      FETCH del_csr INTO l_delivery_id, l_locator_id;
      EXIT WHEN del_csr%notfound;

      x_total_no_of_dels := x_total_no_of_dels + 1;

      IF wms_consolidation_pub.is_delivery_consolidated
	(p_delivery_id => l_delivery_id,
	 p_org_id      => p_org_id,
	 p_sub         => p_sub,
	 p_loc_id      => l_locator_id) = 'Y' THEN

	 x_total_no_of_cons_dels := x_total_no_of_cons_dels + 1;

      END IF;

   END LOOP;
   CLOSE del_csr;


   SELECT COUNT(DISTINCT wlpn.outermost_lpn_id)
     INTO x_total_no_of_lpns
     FROM
     wms_license_plate_numbers wlpn,
     mtl_item_locations mil
     WHERE wlpn.lpn_context              in (11,12)
     AND   wlpn.organization_id          = p_org_id
     AND   wlpn.subinventory_code        = p_sub
     AND   wlpn.locator_id               = mil.inventory_location_id
     AND   Nvl(mil.physical_location_id, mil.inventory_location_id) = p_loc_id
     AND   wlpn.lpn_id                   = wlpn.outermost_lpn_id;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_values_for_loc: Error in get_values_for_loc API: ' || sqlerrm);
      END IF;

   WHEN OTHERS THEN

      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_values_for_loc: Unexpected Error in get_values_for_loc API: ' || sqlerrm);
      END IF;

END get_values_for_loc;



PROCEDURE get_consolidation_inq_loc(x_loc                   IN OUT NOCOPY VARCHAR2,
				    p_sub                   IN  VARCHAR2,
				    p_org_id                IN  NUMBER,
				    p_comp_cons_dels_inq_mode IN VARCHAR2,
				    x_total_no_of_dels      OUT NOCOPY NUMBER,
				    x_total_no_of_cons_dels OUT NOCOPY NUMBER,
				    x_total_no_of_lpns      OUT NOCOPY NUMBER,
				    x_return_status         OUT NOCOPY VARCHAR2,
				    x_msg_count             OUT NOCOPY NUMBER,
				    x_msg_data              OUT NOCOPY VARCHAR2,
				    x_loc_available         OUT NOCOPY VARCHAR2,
				    x_loc_count             OUT NOCOPY NUMBER)
  IS

     l_return_status VARCHAR2(10);
     l_loc_id NUMBER;
     l_loc VARCHAR2(30);
     l_loc_id1 NUMBER;
     l_temp_var NUMBER;
     /*******************************
     * Bug No : 3481421
     * Changed the datatype to the type of the associated column.
     * VARCHAR2(30) was not eanough to hold the 'meaning' column under
     * translated environments
     ********************************/
     l_type_meaning mfg_lookups.meaning%TYPE;

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     CURSOR all_locs_csr
       IS
	  -- need to query from both mil and milk
	  -- because we need to reference picking_order and concatenated_segments
	  SELECT DISTINCT
	    milk.inventory_location_id,
	    nvl(milk.inventory_location_type, 3),
	    mil.picking_order,
	    mil.dropping_order,
	    ml.meaning
	    FROM
	    mtl_item_locations_kfv milk,
	    mtl_item_locations mil,
	    wms_license_plate_numbers wlpn,
	    mfg_lookups ml
	    WHERE milk.organization_id          = p_org_id
	    AND   milk.subinventory_code        = p_sub
	    AND   milk.concatenated_segments    LIKE l_loc
	    AND   nvl(milk.inventory_location_type, 3)  NOT IN (g_loc_type_dock_door)
	    AND   mil.inventory_location_id    = wlpn.locator_id
	    AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	    AND   milk.project_id IS NULL
	    AND   milk.task_id IS NULL
	    AND   milk.organization_id          = mil.organization_id
	    AND   wlpn.lpn_context              in ( 11,12)
	    AND   wlpn.organization_id          = mil.organization_id
	    AND   wlpn.subinventory_code        = mil.subinventory_code
	    AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	    AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
	    ORDER BY ml.meaning, mil.picking_order, mil.dropping_order, milk.inventory_location_id;

     CURSOR cons_locs_csr
       IS
	  SELECT DISTINCT
	    milk.inventory_location_id,
	    nvl(milk.inventory_location_type, 3),
	    mil.picking_order,
	    mil.dropping_order,
	    ml.meaning
	    FROM
	    mtl_item_locations_kfv milk,
	    mtl_item_locations mil,
	    wms_license_plate_numbers wlpn,
	    wsh_delivery_details wdd2,
	    wsh_delivery_assignments_v wda,
	    mfg_lookups ml
	    WHERE milk.organization_id          = p_org_id
	    AND   milk.subinventory_code        = p_sub
	    AND   milk.concatenated_segments    LIKE l_loc
	    AND   nvl(milk.inventory_location_type, 3)  NOT IN (g_loc_type_dock_door)
	    AND   mil.inventory_location_id    = wlpn.locator_id
	    AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	    AND   milk.organization_id          = mil.organization_id
	    AND   milk.project_id IS NULL
	    AND   milk.task_id IS NULL
	    AND   wlpn.lpn_context              in ( 11,12)
	    AND   wlpn.subinventory_code        = mil.subinventory_code
	    AND   wlpn.organization_id          = mil.organization_id
	    AND   wlpn.lpn_id                   = wdd2.lpn_id
	    AND   wda.parent_delivery_detail_id = wdd2.delivery_detail_id
	    AND   wda.delivery_id               IS NOT NULL
	    AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	    AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
       AND   wdd2.released_status          = 'X'  -- For LPN reuse ER : 6845650
	    AND   wms_consolidation_pub.is_delivery_consolidated
	      (wda.delivery_id,
	       p_org_id,
	       p_sub,
	       mil.inventory_location_id) = 'Y'
	      ORDER BY ml.meaning, mil.picking_order, mil.dropping_order, milk.inventory_location_id;

BEGIN

   IF (l_debug = 1) THEN
      mydebug('Enter get_consolidation_inq_loc');
      mydebug('x_loc : ' ||x_loc);
      mydebug('p_sub : ' ||p_sub);
      mydebug('p_org_id : ' ||p_org_id);
      mydebug('p_comp_cons_dels_inq_mode : ' ||p_comp_cons_dels_inq_mode);
   END IF;

   g_trace_on := fnd_profile.value('INV_DEBUG_TRACE') ;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loc_available := 'Y';
   l_loc := (x_loc || '%');
   x_loc_count := 0;

   IF p_comp_cons_dels_inq_mode = 'ALL' THEN

      OPEN all_locs_csr;
      LOOP
	 FETCH all_locs_csr INTO l_loc_id1, l_temp_var, l_temp_var, l_temp_var, l_type_meaning;
	 EXIT WHEN all_locs_csr%notfound;

	 x_loc_count := x_loc_count + 1;

	 IF x_loc_count = 1 THEN l_loc_id := l_loc_id1;
	 END IF;

      END LOOP;
      CLOSE all_locs_csr;

    ELSE

      OPEN cons_locs_csr;
      LOOP
	 FETCH cons_locs_csr INTO l_loc_id1, l_temp_var, l_temp_var, l_temp_var, l_type_meaning;
	 EXIT WHEN cons_locs_csr%notfound;

	 x_loc_count := x_loc_count + 1;

	 IF x_loc_count = 1 THEN l_loc_id := l_loc_id1;
	 END IF;

      END LOOP;
      CLOSE cons_locs_csr;

   END IF;


   IF x_loc_count = 0 THEN

      x_loc_available := 'N';
      x_return_status := l_return_status;
      RETURN;

   END IF;

   IF (l_debug = 1) THEN
      mydebug('get_consolidation_inq_loc: before calling wms_consolidation_pub.get_values_for_loc');
      mydebug('p_sub : '||p_sub);
      mydebug('l_loc_id : '||l_loc_id);
      mydebug('p_org_id : '||p_org_id);
      mydebug('p_comp_cons_dels_inq_mode : '||p_comp_cons_dels_inq_mode);
  END IF;

   wms_consolidation_pub.get_values_for_loc
     (p_sub                     => p_sub,
      p_loc_id                  => l_loc_id,
      p_org_id                  => p_org_id,
      p_comp_cons_dels_inq_mode => p_comp_cons_dels_inq_mode,
      x_total_no_of_dels        => x_total_no_of_dels,
      x_total_no_of_cons_dels   => x_total_no_of_cons_dels,
      x_total_no_of_lpns        => x_total_no_of_lpns,
      x_return_status           => l_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data);

   IF (l_debug = 1) THEN
      mydebug('x_total_no_of_dels : '||x_total_no_of_dels);
      mydebug('x_total_no_of_cons_dels : '||x_total_no_of_cons_dels);
      mydebug('x_total_no_of_lpns : '||x_total_no_of_lpns);
      mydebug('l_return_status : '||l_return_status);
      mydebug('x_msg_data : '||x_msg_data);
      mydebug('x_msg_count : '||x_msg_count);
   END IF;


   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE FND_API.G_exc_unexpected_error;

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

      RAISE FND_API.g_exc_error;

   END IF;

   x_loc := INV_PROJECT.GET_LOCSEGS(l_loc_id,p_org_id);
   x_return_status := l_return_status;

   IF (l_debug = 1) THEN

      mydebug('x_total_no_of_dels : ' ||x_total_no_of_dels);
      mydebug('x_total_no_of_cons_dels : ' ||x_total_no_of_cons_dels);
      mydebug('x_total_no_of_lpns : ' ||x_total_no_of_lpns);
      mydebug('x_return_status : ' ||x_return_status);
      mydebug('x_loc_available : ' ||x_loc_available);
      mydebug('x_loc_count : ' ||x_loc_count);
      mydebug('Exiting get_consolidation_inq_loc');

   END IF;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_consolidation_inq_loc: Error in get_consolidation_inq_loc API: ' || sqlerrm);
      END IF;

   WHEN OTHERS THEN

      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_consolidation_inq_loc: Unexpected Error in get_consolidation_inq_loc API: ' || sqlerrm);
      END IF;

END get_consolidation_inq_loc;



PROCEDURE get_consolidation_inq_lpn_lov(x_lpn_lov OUT NOCOPY t_genref,
					p_org_id IN NUMBER,
					p_lpn IN VARCHAR2)

  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_lpn_lov FOR
     SELECT DISTINCT
     wlpn.license_plate_number,
     milk.subinventory_code,
     INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
     wlpn.lpn_id,
     /* Need to get LocatorId for LMS project, added by Anupam Jain*/
     milk.inventory_location_id,
      /* lms code end */
     nvl(milk.inventory_location_type, 3),
     mil.picking_order
     FROM
     wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv milk,
     mtl_item_locations mil
     WHERE wlpn.lpn_context              in (11, 12)
     AND   wlpn.organization_id          = p_org_id
     AND   wlpn.license_plate_number     LIKE p_lpn
     AND   wlpn.outermost_lpn_id         = wlpn.lpn_id
     AND   milk.organization_id          = wlpn.organization_id
     AND   milk.inventory_location_id    = wlpn.locator_id
     AND   milk.inventory_location_id    = mil.inventory_location_id
     AND   milk.organization_id          = mil.organization_id
     AND   milk.subinventory_code        = wlpn.subinventory_code
     AND   nvl(milk.inventory_location_type, 3)  NOT IN (g_loc_type_dock_door)
     ORDER BY nvl(milk.inventory_location_type, 3), mil.picking_order;

END get_consolidation_inq_lpn_lov;



PROCEDURE get_consolidation_inq_del_lov(x_deliveryLOV     OUT NOCOPY t_genref,
					p_organization_id IN NUMBER,
					p_delivery_name   IN VARCHAR2,
					p_lpn_id          IN NUMBER)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF p_lpn_id IS NOT NULL AND p_lpn_id <> 0 THEN

      OPEN x_deliveryLOV for

	SELECT DISTINCT
	wnd.name Delivery,
	wnd.delivery_id,
	inv_shipping_transaction_pub.get_shipmethod_meaning(wnd.ship_method_code)
	FROM
	wsh_new_deliveries wnd,
	wsh_delivery_assignments_v wda,
	wsh_delivery_details wdd,
	wms_license_plate_numbers wlpn
	WHERE wda.parent_delivery_detail_id = wdd.delivery_detail_id
	AND   wda.delivery_id               = wnd.delivery_id
	AND   wnd.name                      LIKE p_delivery_name
	AND   wnd.organization_id           = p_organization_id
	AND   wlpn.organization_id          = p_organization_id
	AND   wlpn.outermost_lpn_id         = p_lpn_id
	AND   wdd.lpn_id                    = wlpn.lpn_id
	AND   wlpn.lpn_context              in ( 11,12)
   AND   wdd.released_status           = 'X'  -- For LPN reuse ER : 6845650
	ORDER BY wnd.name;

    ELSE

      OPEN x_deliveryLOV for
	SELECT DISTINCT
	wnd.name Delivery,
	wnd.delivery_id,
	inv_shipping_transaction_pub.get_shipmethod_meaning(wnd.ship_method_code)
	FROM wsh_new_deliveries_ob_grp_v wnd,
	wsh_delivery_assignments_v wda,
	wsh_delivery_details_ob_grp_v wdd
	WHERE wda.delivery_Detail_id = wdd.delivery_Detail_id
	AND   wda.delivery_id        = wnd.delivery_id
	AND   wdd.released_status    = 'Y'
	AND   wnd.organization_id    = p_organization_id
	AND   wnd.name               LIKE p_delivery_name
	ORDER BY wnd.name;

   END IF;

END get_consolidation_inq_del_lov;


PROCEDURE get_cons_inq_orders_lov(x_order_lov   OUT NOCOPY t_genref,
				  p_org_id      IN NUMBER,
				  p_order       IN VARCHAR2,
				  p_delivery_id IN NUMBER,
				  p_lpn_id      IN NUMBER)
  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF p_delivery_id IS NOT NULL AND p_delivery_id <> 0 THEN

      IF p_lpn_id IS NOT NULL AND p_lpn_id <> 0 THEN

	 --Both delivery and LPN were entered

	 OPEN x_order_lov FOR

	   SELECT DISTINCT
	   wdd.source_header_number,
	   wda.delivery_id,
	   --c.customer_name                                                -- Commented for Bug# 4579790
	   party.party_name  customer_name                                  -- Added for Bug# 4579790
	   FROM
	   wsh_delivery_details wdd,
	   wsh_delivery_assignments_v wda,
	   -- ra_customers c,                                               -- Commented for Bug# 4579790
	   hz_parties party,                                                -- Added for Bug# 4579790
	   hz_cust_accounts cust_acct,                                      -- Added for Bug# 4579790
	   wms_license_plate_numbers wlpn,
	   wsh_delivery_details wdd2
	   WHERE wdd.customer_id               = cust_acct.cust_account_id  -- Added for Bug# 4579790
	   --wdd.customer_id                   = c.customer_id              -- Commented for Bug# 4579790
	   AND   cust_acct.party_id            = party.party_id             -- Added for Bug# 4579790
	   AND   wdd.organization_id           = p_org_id
	   AND   wdd.released_status           IN ('Y')
	   AND   wdd.source_header_number      LIKE p_order
	   AND   wda.delivery_detail_id        = wdd.delivery_detail_id
	   AND   wda.delivery_id               = p_delivery_id
	   AND   wda.parent_delivery_detail_id = wdd2.delivery_detail_id
	   AND   wlpn.organization_id          = p_org_id
	   AND   wlpn.outermost_lpn_id         = p_lpn_id
	   AND   wlpn.lpn_context              in ( 11,12)
	   AND   wlpn.lpn_id                   = wdd2.lpn_id
	   ORDER BY 1;


       ELSE

	 -- Only delivery was entered

	 OPEN x_order_lov FOR

	   SELECT DISTINCT
	   wdd.source_header_number,
	   wda.delivery_id,
	   --c.customer_name                                                -- Commented for Bug# 4579790
	   party.party_name  customer_name                                  -- Added for Bug# 4579790
	   FROM
	   wsh_delivery_details wdd,
	   wsh_delivery_assignments_v wda,
	   -- ra_customers c,                                               -- Commented for Bug# 4579790
	   hz_parties party,                                                -- Added for Bug# 4579790
	   hz_cust_accounts cust_acct                                       -- Added for Bug# 4579790
	   WHERE wdd.customer_id          = cust_acct.cust_account_id       -- Added for Bug# 4579790
	   --wdd.customer_id              = c.customer_id                   -- Commented for Bug# 4579790
	   AND   cust_acct.party_id       = party.party_id                  -- Added for Bug# 4579790
	   AND   wdd.organization_id      = p_org_id
	   AND   wdd.released_status      IN ('Y')
	   AND   wda.delivery_Detail_id   = wdd.delivery_Detail_id
	   AND   wdd.source_header_number LIKE p_order
           AND   wda.delivery_id          = p_delivery_id
           ORDER BY 1;

      END IF;

    ELSIF p_lpn_id IS NOT NULL AND p_lpn_id <> 0 THEN

      --Only LPN was entered

      OPEN x_order_lov FOR

	   SELECT DISTINCT
	   wdd.source_header_number,
	   wda.delivery_id,
	   --c.customer_name                                                -- Commented for Bug# 4579790
	   party.party_name  customer_name                                  -- Added for Bug# 4579790
	   FROM
	   wsh_delivery_details wdd,
	   wsh_delivery_assignments_v wda,
	   -- ra_customers c,                                               -- Commented for Bug# 4579790
	   hz_parties party,                                                -- Added for Bug# 4579790
	   hz_cust_accounts cust_acct,                                      -- Added for Bug# 4579790
	   wms_license_plate_numbers wlpn,
	   wsh_delivery_details wdd2
	   WHERE wdd.customer_id               = cust_acct.cust_account_id  -- Added for Bug# 4579790
	   --wdd.customer_id                   = c.customer_id              -- Commented for Bug# 4579790
	   AND   cust_acct.party_id            = party.party_id             -- Added for Bug# 4579790
	   AND   wdd.organization_id           = p_org_id
	   AND   wdd.released_status           IN ('Y')
           AND   wdd.source_header_number      LIKE p_order
           AND   wda.delivery_Detail_id        = wdd.delivery_Detail_id
	   AND   wda.parent_delivery_detail_id = wdd2.delivery_detail_id
	   AND   wlpn.organization_id          = p_org_id
	   AND   wlpn.outermost_lpn_id         = p_lpn_id
	   AND   wlpn.lpn_context              in ( 11,12)
      AND   wdd2.released_status          = 'X'
	   AND   wlpn.lpn_id                   = wdd2.lpn_id
           ORDER BY 1;


    ELSE

      --Neither LPN nor delivery was entered

      OPEN x_order_lov FOR

	   SELECT DISTINCT
	   wdd.source_header_number,
	   wda.delivery_id,
	   --c.customer_name                                                -- Commented for Bug# 4579790
	   party.party_name  customer_name                                  -- Added for Bug# 4579790
	   FROM
	   wsh_delivery_details_ob_grp_v wdd,
	   wsh_delivery_assignments_v wda,
	   -- ra_customers c,                                               -- Commented for Bug# 4579790
	   hz_parties party,                                                -- Added for Bug# 4579790
	   hz_cust_accounts cust_acct                                       -- Added for Bug# 4579790
	   WHERE wdd.customer_id          = cust_acct.cust_account_id       -- Added for Bug# 4579790
           --wdd.customer_id              = c.customer_id                   -- Commented for Bug# 4579790
           AND   cust_acct.party_id       = party.party_id                  -- Added for Bug# 4579790
	   AND   wdd.organization_id      = p_org_id
	   AND   wdd.released_status      IN ('Y')
	   AND   wda.delivery_Detail_id   = wdd.delivery_Detail_id
	   AND   wdd.source_header_number LIKE p_order
	   ORDER BY 1;

   END IF;

END get_cons_inq_orders_lov;



PROCEDURE get_consolidation_inq_sub_lov(x_sub_lov      OUT NOCOPY t_genref,
					p_sub          IN VARCHAR2,
					p_org_id       IN NUMBER)

  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_sub_lov FOR

     SELECT
     msi.secondary_inventory_name,
     Nvl(msi.locator_type, 1),
     msi.description,
     msi.asset_inventory,
     msi.lpn_controlled_flag,
     msi.picking_order,
     msi.enable_locator_alias
     FROM
     mtl_secondary_inventories msi
     WHERE msi.organization_id           = p_org_id
     AND   msi.lpn_controlled_flag       = 1
     AND   msi.secondary_inventory_name  LIKE p_sub
     ORDER BY msi.picking_order;

END get_consolidation_inq_sub_lov;


PROCEDURE get_consolidation_inq_loc_lov(x_loc_lov      OUT NOCOPY t_genref,
					p_sub          IN VARCHAR2,
					p_loc          IN VARCHAR2,
					p_org_id       IN NUMBER,
					p_comp_cons_dels_inq_mode IN VARCHAR2,
                                        p_alias        IN VARCHAR2)

  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF p_alias IS NULL THEN
      get_consolidation_inq_loc_lov(
       x_loc_lov      => x_loc_lov
      ,p_sub          => p_sub
      ,p_loc          => p_loc
      ,p_org_id       => p_org_id
      ,p_comp_cons_dels_inq_mode => p_comp_cons_dels_inq_mode
      );
      RETURN;
   END IF;

   IF p_comp_cons_dels_inq_mode = 'ALL' THEN

      OPEN x_loc_lov FOR

	SELECT DISTINCT
	milk.inventory_location_id,
	INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
	milk.description,
	ml.meaning,
	mil.picking_order
	FROM
	mtl_item_locations_kfv milk,
	mtl_item_locations mil,
	wms_license_plate_numbers wlpn,
	mfg_lookups ml
	WHERE milk.organization_id          = p_org_id
	AND   milk.alias = p_alias
	AND   milk.subinventory_code        = p_sub
	AND   milk.project_id IS NULL
	AND   milk.task_id IS NULL
	AND   nvl(milk.inventory_location_type, 3)  NOT IN (g_loc_type_dock_door)
	AND   mil.inventory_location_id    = wlpn.locator_id
	AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	AND   milk.organization_id          = mil.organization_id
	AND   wlpn.lpn_context              in ( 11,12)
	AND   wlpn.organization_id          = mil.organization_id
	AND   wlpn.subinventory_code        = mil.subinventory_code
	AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
	ORDER BY ml.meaning, mil.picking_order;

    ELSE


      OPEN x_loc_lov FOR

	SELECT DISTINCT
 	milk.inventory_location_id,
	INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
	milk.description,
	ml.meaning,
	mil.picking_order
	FROM
	mtl_item_locations_kfv milk,
	mtl_item_locations mil,
	wms_license_plate_numbers wlpn,
	wsh_delivery_details wdd2,
	wsh_delivery_assignments_v wda,
	mfg_lookups ml
	WHERE milk.organization_id          = p_org_id
	AND   milk.subinventory_code        = p_sub
	AND   milk.alias = p_alias
	AND   nvl(milk.inventory_location_type, 3)  NOT IN (g_loc_type_dock_door)
	AND   mil.inventory_location_id    = wlpn.locator_id
	AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	AND   milk.organization_id          = mil.organization_id
	AND   milk.project_id IS NULL
	AND   milk.task_id IS NULL
	AND   wlpn.lpn_context              in ( 11,12)
	AND   wlpn.subinventory_code        = mil.subinventory_code
	AND   wlpn.organization_id          = mil.organization_id
	AND   wlpn.lpn_id                   = wdd2.lpn_id
	AND   wda.parent_delivery_detail_id = wdd2.delivery_detail_id
	AND   wda.delivery_id               IS NOT NULL
   AND   wdd2.released_status           = 'X'  -- For LPN reuse ER : 6845650
	AND   wms_consolidation_pub.is_delivery_consolidated
	      (wda.delivery_id,
	       p_org_id,
	       p_sub,
	       mil.inventory_location_id)  = 'Y'
	AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
	ORDER BY ml.meaning, mil.picking_order;

   END IF;

END get_consolidation_inq_loc_lov;
PROCEDURE get_consolidation_inq_loc_lov(x_loc_lov      OUT NOCOPY t_genref,
					p_sub          IN VARCHAR2,
					p_loc          IN VARCHAR2,
					p_org_id       IN NUMBER,
					p_comp_cons_dels_inq_mode IN VARCHAR2)

  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF p_comp_cons_dels_inq_mode = 'ALL' THEN

      OPEN x_loc_lov FOR

	SELECT DISTINCT
	milk.inventory_location_id,
	INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
	milk.description,
	ml.meaning,
	mil.picking_order
	FROM
	mtl_item_locations_kfv milk,
	mtl_item_locations mil,
	wms_license_plate_numbers wlpn,
	mfg_lookups ml
	WHERE milk.organization_id          = p_org_id
	AND   INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id)    LIKE p_loc  -- bug 2769126
	AND   milk.subinventory_code        = p_sub
	AND   milk.project_id IS NULL
	AND   milk.task_id IS NULL
	AND   nvl(milk.inventory_location_type, 3)  NOT IN (g_loc_type_dock_door)
	AND   mil.inventory_location_id    = wlpn.locator_id
	AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	AND   milk.organization_id          = mil.organization_id
	AND   wlpn.lpn_context              in ( 11,12)
	AND   wlpn.organization_id          = mil.organization_id
	AND   wlpn.subinventory_code        = mil.subinventory_code
	AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
	ORDER BY ml.meaning, mil.picking_order;

    ELSE


      OPEN x_loc_lov FOR

	SELECT DISTINCT
 	milk.inventory_location_id,
	INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
	milk.description,
	ml.meaning,
	mil.picking_order
	FROM
	mtl_item_locations_kfv milk,
	mtl_item_locations mil,
	wms_license_plate_numbers wlpn,
	wsh_delivery_details wdd2,
	wsh_delivery_assignments_v wda,
	mfg_lookups ml
	WHERE milk.organization_id          = p_org_id
	AND   milk.subinventory_code        = p_sub
	AND   INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id)   LIKE p_loc  -- bug 2769126
	AND   nvl(milk.inventory_location_type, 3)  NOT IN (g_loc_type_dock_door)
	AND   mil.inventory_location_id    = wlpn.locator_id
	AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	AND   milk.organization_id          = mil.organization_id
	AND   milk.project_id IS NULL
	AND   milk.task_id IS NULL
	AND   wlpn.lpn_context              in ( 11,12)
	AND   wlpn.subinventory_code        = mil.subinventory_code
	AND   wlpn.organization_id          = mil.organization_id
	AND   wlpn.lpn_id                   = wdd2.lpn_id
	AND   wda.parent_delivery_detail_id = wdd2.delivery_detail_id
	AND   wda.delivery_id               IS NOT NULL
	AND   wms_consolidation_pub.is_delivery_consolidated
	      (wda.delivery_id,
	       p_org_id,
	       p_sub,
	       mil.inventory_location_id)  = 'Y'
	AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
   AND   wdd2.released_status          = 'X'  -- For LPN reuse ER : 6845650
	ORDER BY ml.meaning, mil.picking_order;

   END IF;

END get_consolidation_inq_loc_lov;



PROCEDURE get_values_for_lpn(p_lpn_id                IN  NUMBER,
			     p_org_id                IN  NUMBER,
			     x_sub                   IN  OUT NOCOPY VARCHAR2,
			     x_loc                   IN  OUT NOCOPY VARCHAR2,
			     x_delivery_id           IN  OUT NOCOPY NUMBER,
			     x_order_number          IN  OUT NOCOPY VARCHAR2,
			     p_inquiry_mode          IN  NUMBER,
			     p_comp_cons_dels_inq_mode IN VARCHAR2,
			     x_delivery_status       OUT NOCOPY VARCHAR2,
			     x_return_status         OUT NOCOPY VARCHAR2,
			     x_msg_count             OUT NOCOPY NUMBER,
			     x_msg_data              OUT NOCOPY VARCHAR2,
			     x_lpn                   OUT NOCOPY VARCHAR2,
			     x_project               OUT NOCOPY VARCHAR2,
			     x_task                  OUT NOCOPY VARCHAR2)

  IS

     CURSOR order_csr IS

	SELECT DISTINCT
	  wdd2.source_header_number
	  FROM
	  wsh_delivery_assignments_v wda,
	  wsh_delivery_details wdd,
	  wsh_delivery_details wdd2,
	  wms_license_plate_numbers wlpn
	  WHERE wlpn.outermost_lpn_id  = p_lpn_id
	  AND   wlpn.organization_id   = p_org_id
	  AND   wlpn.lpn_context       in ( 11,12)
	  AND   wlpn.lpn_id            = wdd.lpn_id
     AND   wdd.released_status    = 'X'   -- For LPN reuse ER : 6845650
	  AND   wdd.organization_id    = wlpn.organization_id
	  AND   wdd.delivery_detail_id = wda.parent_delivery_detail_id
	  AND   wda.delivery_detail_id = wdd2.delivery_detail_id
	  AND   wdd2.released_status   = 'Y';

     CURSOR order_csr2 IS

	SELECT DISTINCT
	  wdd2.source_header_number
	  FROM
	  wsh_delivery_assignments_v wda,
	  wsh_delivery_details wdd,
	  wsh_delivery_details wdd2,
	  wms_license_plate_numbers wlpn
	  WHERE wlpn.outermost_lpn_id  = p_lpn_id
	  AND   wlpn.organization_id   = p_org_id
	  AND   wlpn.lpn_context       in ( 11,12)
	  AND   wlpn.lpn_id            = wdd.lpn_id
	  AND   wdd.organization_id    = wlpn.organization_id
	  AND   wdd.delivery_detail_id = wda.parent_delivery_detail_id
	  AND   wda.delivery_detail_id = wdd2.delivery_detail_id
	  AND   wdd2.released_status   = 'Y'
	  AND   wda.delivery_id        = x_delivery_id;


     l_count NUMBER;
     l_order_num VARCHAR2(30);
     l_loc_id NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   g_trace_on := fnd_profile.value('INV_DEBUG_TRACE') ;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_delivery_status := 'N';

   IF p_inquiry_mode = 1 THEN

	    IF (g_trace_on = 1) THEN
	       mydebug('get_values_for_lpn : p_inquiry_mode = 1 ');
	    END IF;

      BEGIN

	 SELECT DISTINCT
	   wda.delivery_id,
	   wlpno.license_plate_number,
	   wlpn.locator_id,
	   inv_projectlocator_pub.get_project_number(mil.project_id),
	   inv_projectlocator_pub.get_task_number(mil.task_id)
	   INTO
	   x_delivery_id,
	   x_lpn,
	   l_loc_id,
	   x_project,
	   x_task
	   FROM
	   wsh_delivery_assignments_v wda,
	   wsh_delivery_details wdd,
	   wms_license_plate_numbers wlpn,
	   mtl_item_locations mil,
	   wms_license_plate_numbers wlpno
	   WHERE wlpn.organization_id   = p_org_id
	   AND   wlpn.lpn_context       in ( 11,12)
	   AND   wlpn.outermost_lpn_id  = p_lpn_id
	   AND   wlpno.lpn_id           = p_lpn_id  -- bug 2764736
	   AND   wlpn.lpn_id            = wdd.lpn_id
      AND   wdd.released_status    = 'X'  -- For LPN reuse ER : 6845650
	   AND   wdd.organization_id    = wlpn.organization_id
	   AND   wdd.delivery_detail_id = wda.parent_delivery_detail_id
	   AND   wlpn.locator_id        = mil.inventory_location_id
	   AND   wlpn.organization_id   = mil.organization_id
	   AND   ROWNUM = 1;

      EXCEPTION
	 WHEN no_data_found THEN
	    RAISE FND_API.g_exc_error;

      END;

      l_count := 0;
      OPEN order_csr;
      LOOP
	 FETCH order_csr INTO l_order_num;
	 EXIT WHEN order_csr%notfound;

	 l_count := l_count + 1;

      END LOOP;
      CLOSE order_csr;

      IF l_count > 1 THEN
	 x_order_number := 'Multiple';
       ELSE
	 x_order_number := l_order_num;
      END IF;


    ELSIF p_inquiry_mode = 2 THEN

	    IF (g_trace_on = 1) THEN
	       mydebug('get_values_for_lpn : p_inquiry_mode = 2 ');
	    END IF;

      IF x_order_number IS NOT NULL THEN

	 IF x_delivery_id IS NULL OR x_delivery_id = 0 THEN

	    BEGIN

	       SELECT DISTINCT
		 wda.delivery_id,
		 wlpno.license_plate_number,
		 wlpn.locator_id,
		 wlpn.subinventory_code,
		 INV_PROJECT.GET_LOCSEGS(wlpn.locator_id, wlpn.organization_id) concatenated_segments,
		 inv_projectlocator_pub.get_project_number(mil.project_id),
		 inv_projectlocator_pub.get_task_number(mil.task_id)
		 INTO
		 x_delivery_id,
		 x_lpn,
		 l_loc_id,
		 x_sub,
		 x_loc,
		 x_project,
		 x_task
		 FROM
		 wms_license_plate_numbers wlpn,
		 wms_license_plate_numbers wlpno,
		 wsh_delivery_assignments_v wda,
		 wsh_delivery_details wdd,
		 wsh_delivery_details wdd2,
		 mtl_item_locations mil
		 WHERE wlpn.outermost_lpn_id         = p_lpn_id
		 AND   wlpno.lpn_id                  = p_lpn_id  -- bug 2764736
		 AND   wlpn.lpn_context              in ( 11, 12)
		 AND   wlpn.organization_id          = p_org_id
		 AND   wdd.source_header_number      = x_order_number
		 AND   wdd.released_status           = 'Y'
		 AND   wda.delivery_detail_id        = wdd.delivery_detail_id
		 AND   wda.parent_delivery_detail_id = wdd2.delivery_detail_id
		 AND   wlpn.lpn_id                   = wdd2.lpn_id
		 AND   wlpn.locator_id               = mil.inventory_location_id
		 AND   wlpn.organization_id          = mil.organization_id
		 AND   ROWNUM = 1;

	    EXCEPTION
	       WHEN no_data_found THEN
		  RAISE FND_API.g_exc_error;

	    END;

	  ELSE

	      BEGIN

		 SELECT
		   wlpn.license_plate_number,
		   wlpn.locator_id,
		   wlpn.subinventory_code,
		   INV_PROJECT.GET_LOCSEGS(wlpn.locator_id, wlpn.organization_id) concatenated_segments,
		   inv_projectlocator_pub.get_project_number(mil.project_id),
		   inv_projectlocator_pub.get_task_number(mil.task_id)

		   INTO
		   x_lpn,
		   l_loc_id,
		   x_sub,
		   x_loc,
		   x_project,
		   x_task
		   FROM  wms_license_plate_numbers wlpn,
		   mtl_item_locations mil
		   WHERE wlpn.lpn_id          = p_lpn_id
		   AND   wlpn.organization_id = p_org_id
		   AND   wlpn.locator_id      = mil.inventory_location_id
		   AND   wlpn.organization_id = mil.organization_id
		   AND   wlpn.lpn_context     in ( 11,12);

	      EXCEPTION
		 WHEN no_data_found THEN
		    RAISE FND_API.g_exc_error;

	      END;

	 END IF;

       ELSIF x_delivery_id IS NOT NULL AND x_delivery_id <> 0 THEN

	   BEGIN

	      SELECT
		wlpn.license_plate_number,
		wlpn.locator_id,
		wlpn.subinventory_code,
		INV_PROJECT.GET_LOCSEGS(wlpn.locator_id, wlpn.organization_id) concatenated_segments,
		inv_projectlocator_pub.get_project_number(mil.project_id),
		inv_projectlocator_pub.get_task_number(mil.task_id)

		INTO
		x_lpn,
		l_loc_id,
		x_sub,
		x_loc,
		x_project,
		x_task
		FROM  wms_license_plate_numbers wlpn,
		mtl_item_locations mil
		WHERE wlpn.lpn_id          = p_lpn_id
		AND   wlpn.organization_id = p_org_id
		AND   wlpn.locator_id      = mil.inventory_location_id
		AND   wlpn.organization_id = mil.organization_id
		AND   wlpn.lpn_context     in ( 11,12);

	   EXCEPTION
	      WHEN no_data_found THEN
		 RAISE FND_API.g_exc_error;

	   END;

	   l_count := 0;
	   OPEN order_csr2;
	   LOOP
	      FETCH order_csr2 INTO l_order_num;
	      EXIT WHEN order_csr2%notfound;

	      l_count := l_count + 1;

	   END LOOP;
	   CLOSE order_csr2;

	   IF l_count > 1 THEN
	      x_order_number := 'Multiple';
	    ELSE
	      x_order_number := l_order_num;
	   END IF;

       ELSE -- Only LPN was entered

	   BEGIN

	      SELECT DISTINCT
		wda.delivery_id,
		wlpno.license_plate_number,
		wlpn.locator_id,
		wlpn.subinventory_code,
		INV_PROJECT.GET_LOCSEGS(wlpn.locator_id, wlpn.organization_id) concatenated_segments,
		inv_projectlocator_pub.get_project_number(mil.project_id),
		inv_projectlocator_pub.get_task_number(mil.task_id)

		INTO
		x_delivery_id,
		x_lpn,
		l_loc_id,
		x_sub,
		x_loc,
		x_project,
		x_task
		FROM
		wms_license_plate_numbers wlpn,
		wms_license_plate_numbers wlpno,
		wsh_delivery_assignments_v wda,
		wsh_delivery_details wdd,
		mtl_item_locations mil
		WHERE wlpn.outermost_lpn_id         = p_lpn_id
		AND   wlpno.lpn_id                  = p_lpn_id  -- bug 2764736
		AND   wlpn.lpn_context              in ( 11,12)
		AND   wlpn.organization_id          = p_org_id
		AND   wda.parent_delivery_detail_id = wdd.delivery_detail_id
		AND   wlpn.lpn_id                   = wdd.lpn_id
      AND   wdd.released_status           = 'X'  -- For LPN reuse ER : 6845650
		AND   wlpn.locator_id               = mil.inventory_location_id
		AND   wlpn.organization_id          = mil.organization_id
		AND   ROWNUM = 1;

	   EXCEPTION
	      WHEN no_data_found THEN
		 RAISE FND_API.g_exc_error;

	   END;

	   l_count := 0;

	   OPEN order_csr;
	   LOOP
	      FETCH order_csr INTO l_order_num;
	      EXIT WHEN order_csr%notfound;

	      l_count := l_count + 1;

	   END LOOP;
	   CLOSE order_csr;

	   IF l_count > 1 THEN
	      x_order_number := 'Multiple';
	    ELSE
	      x_order_number := l_order_num;
	   END IF;

      END IF;

   END IF;


   IF wms_consolidation_pub.is_delivery_consolidated
     (p_delivery_id => x_delivery_id,
      p_org_id      => p_org_id,
      p_sub         => x_sub,
      p_loc_id      => l_loc_id) = 'Y' THEN

      x_delivery_status := 'Y';

   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_values_for_lpn: Error in get_values_for_lpn API: ' || sqlerrm);
      END IF;

   WHEN OTHERS THEN

      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_values_for_lpn: Unexpected Error in get_values_for_lpn API: ' || sqlerrm);
      END IF;

END get_values_for_lpn;



PROCEDURE get_consolidation_inq_lpn(x_loc                   IN OUT NOCOPY VARCHAR2,
				    x_sub                   IN OUT NOCOPY VARCHAR2,
				    p_org_id                IN NUMBER,
				    x_delivery_id           IN OUT NOCOPY NUMBER,
				    x_order_number          IN OUT NOCOPY VARCHAR2,
				    p_inquiry_mode          IN NUMBER,
				    p_comp_cons_dels_inq_mode IN VARCHAR2,
				    x_lpn_vector            OUT NOCOPY VARCHAR2,
				    x_delivery_status       OUT NOCOPY VARCHAR2,
				    x_return_status         OUT NOCOPY VARCHAR2,
				    x_msg_count             OUT NOCOPY NUMBER,
				    x_msg_data              OUT	NOCOPY VARCHAR2,
				    x_lpn                   IN OUT NOCOPY VARCHAR2,
				    x_lpn_available         OUT NOCOPY VARCHAR2,
				    x_project               OUT NOCOPY VARCHAR2,
				    x_task                  OUT NOCOPY VARCHAR2)
  IS

     CURSOR lpn_csr IS

	SELECT DISTINCT
	  wlpn.outermost_lpn_id
	  FROM
	  wms_license_plate_numbers wlpn,
	  mtl_item_locations_kfv milk
	  WHERE wlpn.lpn_context               in (11,12)
	  AND   wlpn.subinventory_code         = x_sub
	  AND   wlpn.organization_id           = p_org_id
	  AND   milk.concatenated_segments LIKE (x_loc || '%')
	  AND   wlpn.locator_id                = milk.inventory_location_id
	  AND   wlpn.subinventory_code         = milk.subinventory_code
	  AND   milk.organization_id           = wlpn.organization_id
	  ORDER BY wlpn.outermost_lpn_id;


     CURSOR lpn_csr2 IS

	SELECT DISTINCT wlpn.outermost_lpn_id
	  FROM
	  wsh_delivery_details wdd,
	  wms_license_plate_numbers wlpn,
	  wsh_delivery_assignments_v wda,
	  wsh_delivery_details wdd2
	  WHERE wdd.source_header_number = x_order_number
	  AND   wdd.organization_id      = p_org_id
	  AND   wdd.released_status      = 'Y'
	  AND   wdd.delivery_detail_id   = wda.delivery_detail_id
	  AND   (Nvl(wda.delivery_id, -999) = Nvl(x_delivery_id, Nvl(wda.delivery_id, -999))
		 OR
		 x_delivery_id = 0)
	  AND   wdd2.delivery_detail_id  = wda.parent_delivery_detail_id
	  AND   wdd2.lpn_id              = wlpn.lpn_id
	  AND   wlpn.lpn_context         in ( 11,12)
	  AND   wlpn.organization_id     = wdd2.organization_id
	  ORDER BY wlpn.outermost_lpn_id;


      CURSOR lpn_csr3 IS

	 SELECT DISTINCT wlpn.outermost_lpn_id
	   FROM
	   wsh_delivery_details wdd,
	   wms_license_plate_numbers wlpn,
	   wsh_delivery_assignments_v wda
	   WHERE wda.delivery_id        = x_delivery_id
	   AND   wdd.delivery_detail_id = wda.parent_delivery_detail_id
	   AND   wdd.organization_id    = p_org_id
	   AND   wdd.lpn_id             = wlpn.lpn_id
	   AND   wlpn.lpn_context       in (11,12)
	   AND   wlpn.organization_id   = wdd.organization_id
	   ORDER BY wlpn.outermost_lpn_id;


     l_lpn_id NUMBER;
     l_count NUMBER := 0;
     l_loc_id NUMBER;
     l_return_status VARCHAR2(30);
     l_lpn1_id NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   g_trace_on := fnd_profile.value('INV_DEBUG_TRACE') ;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   x_lpn_available := 'Y';


   IF p_inquiry_mode = 1 THEN l_count := 0;
      OPEN lpn_csr;
      LOOP
	 FETCH lpn_csr INTO l_lpn_id;
	 EXIT WHEN lpn_csr%notfound;

	 l_count := l_count + 1;

	 IF l_count = 1 THEN
	    l_lpn1_id := l_lpn_id;
	 END IF;

	 x_lpn_vector := x_lpn_vector || l_lpn_id || ':';

      END LOOP;
      CLOSE lpn_csr;

    ELSIF p_inquiry_mode = 2 THEN

	    IF x_lpn IS NOT NULL THEN

	       SELECT  wlpn.lpn_id
		 INTO  l_lpn1_id
		 FROM  wms_license_plate_numbers wlpn
		 WHERE wlpn.license_plate_number = x_lpn
		 AND   wlpn.lpn_context          in ( 11,12)
		 AND   wlpn.organization_id      = p_org_id;

	       l_count := 1;
	       x_lpn_vector := x_lpn_vector || l_lpn1_id || ':';

	     ELSIF x_order_number IS NOT NULL THEN

	       l_count := 0;
	       OPEN lpn_csr2;
	       LOOP
		  FETCH lpn_csr2 INTO l_lpn_id;
		  EXIT WHEN lpn_csr2%notfound;

		  l_count := l_count + 1;

		  IF l_count = 1 THEN
		     l_lpn1_id := l_lpn_id;
		  END IF;

		  x_lpn_vector := x_lpn_vector || l_lpn_id || ':';

	       END LOOP;
	       CLOSE lpn_csr2;

	     ELSIF x_delivery_id IS NOT NULL THEN

		     l_count := 0;
		     OPEN lpn_csr3;
		     LOOP
			FETCH lpn_csr3 INTO l_lpn_id;
			EXIT WHEN lpn_csr3%notfound;

			l_count := l_count + 1;

			IF l_count = 1 THEN
			   l_lpn1_id := l_lpn_id;
			END IF;

			x_lpn_vector := x_lpn_vector || l_lpn_id || ':';

		     END LOOP;
		     CLOSE lpn_csr3;

	    END IF;

   END IF;

   IF l_count = 0 THEN

      x_lpn_available := 'N';
      x_return_status := l_return_status;
      RETURN;

   END IF;

   IF (g_trace_on = 1) THEN mydebug('get_consolidation_inq_lpn : x_lpn_vector ->' || x_lpn_vector);
   END IF;

   wms_consolidation_pub.get_values_for_lpn
     (p_lpn_id                  => l_lpn1_id,
      p_org_id                  => p_org_id,
      x_sub                     => x_sub,
      x_loc                     => x_loc,
      x_delivery_id             => x_delivery_id,
      x_order_number            => x_order_number,
      p_inquiry_mode            => p_inquiry_mode,
      p_comp_cons_dels_inq_mode => p_comp_cons_dels_inq_mode,
      x_delivery_status         => x_delivery_status,
      x_return_status           => l_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_lpn                     => x_lpn,
      x_project                 => x_project,
      x_task                    => x_task);

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE FND_API.G_exc_unexpected_error;

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

      RAISE FND_API.g_exc_error;

   END IF;


   x_return_status := l_return_status;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_consolidation_inq_lpn: Error in get_consolidation_inq_lpn API: ' || sqlerrm);
      END IF;

   WHEN OTHERS THEN

      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_consolidation_inq_lpn: Unexpected Error in get_consolidation_inq_lpn API: ' || sqlerrm);
      END IF;

END get_consolidation_inq_lpn;



PROCEDURE get_query_by_del_lpn(x_delivery_id           IN  OUT NOCOPY NUMBER,
			       p_org_id                IN  NUMBER,
			       x_order_number          OUT NOCOPY VARCHAR2,
			       x_loc                   OUT NOCOPY VARCHAR2,
			       x_sub                   OUT NOCOPY VARCHAR2,
			       x_lpn_vector            OUT NOCOPY VARCHAR2,
			       x_delivery_status       OUT NOCOPY VARCHAR2,
			       x_return_status         OUT NOCOPY VARCHAR2,
			       x_msg_count             OUT NOCOPY NUMBER,
			       x_msg_data              OUT NOCOPY VARCHAR2,
			       x_lpn                   OUT NOCOPY VARCHAR2,
			       x_lpn_available         OUT NOCOPY VARCHAR2,
			       x_tot_lines_for_del     OUT NOCOPY NUMBER,
			       x_tot_comp_lines_for_del OUT NOCOPY NUMBER,
			       x_tot_locs_for_del      OUT NOCOPY NUMBER,
			       x_project               OUT NOCOPY VARCHAR2,
			       x_task                  OUT NOCOPY VARCHAR2)

  IS

      CURSOR lpn_csr IS

	 SELECT DISTINCT wlpn.outermost_lpn_id
	   FROM
	   wsh_delivery_details wdd,
	   wms_license_plate_numbers wlpn,
	   wsh_delivery_assignments_v wda
	   WHERE wda.delivery_id        = x_delivery_id
	   AND   wdd.delivery_detail_id = wda.parent_delivery_detail_id
	   AND   wdd.organization_id    = p_org_id
	   AND   wdd.lpn_id             = wlpn.lpn_id
	   AND   wlpn.lpn_context       in ( 11,12)
	   AND   wlpn.organization_id   = wdd.organization_id
	   ORDER BY wlpn.outermost_lpn_id;


     l_lpn_id NUMBER;
     l_count NUMBER;
     l_loc_id NUMBER;
     l_return_status VARCHAR2(30);
     l_lpn1_id NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   g_trace_on := fnd_profile.value('INV_DEBUG_TRACE') ;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   x_lpn_available := 'Y';


   IF (l_debug = 1) THEN
      mydebug('Enter get_query_by_del_lpn : x_delivery_id = ' || x_delivery_id);
   END IF;

   SELECT COUNT(DISTINCT Nvl(mil.physical_location_id,
			     mil.inventory_location_id))
     INTO x_tot_locs_for_del
     FROM mtl_item_locations mil,
     wsh_delivery_details wdd,
     wsh_delivery_assignments_v wda
     WHERE wda.delivery_id = x_delivery_id
     AND wda.delivery_detail_id = wdd.delivery_detail_id
     AND wdd.locator_id = mil.inventory_location_id
     AND wdd.organization_id = mil.organization_id
     AND wdd.released_status = 'Y'
     ;

   IF (l_debug = 1) THEN
      mydebug('get_query_by_del_lpn : x_tot_locs_for_del = ' || x_tot_locs_for_del);
   END IF;


   l_count := 0;
   OPEN lpn_csr;
   LOOP
      FETCH lpn_csr INTO l_lpn_id;
      EXIT WHEN lpn_csr%notfound;

      l_count := l_count + 1;

      IF l_count = 1 THEN
	 l_lpn1_id := l_lpn_id;
      END IF;

      x_lpn_vector := x_lpn_vector || l_lpn_id || ':';

   END LOOP;
   CLOSE lpn_csr;

   IF l_count = 0 THEN

      x_lpn_available := 'N';
      x_return_status := l_return_status;
      RETURN;

   END IF;

   IF (g_trace_on = 1) THEN mydebug('get_query_by_del_lpn : x_lpn_vector ->' || x_lpn_vector);
   END IF;

   wms_consolidation_pub.get_values_for_lpn
     (p_lpn_id                  => l_lpn1_id,
      p_org_id                  => p_org_id,
      x_sub                     => x_sub,
      x_loc                     => x_loc,
      x_delivery_id             => x_delivery_id,
      x_order_number            => x_order_number,
      p_inquiry_mode            => 2,
      p_comp_cons_dels_inq_mode => 'ALL',
      x_delivery_status         => x_delivery_status,
      x_return_status           => l_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_lpn                     => x_lpn,
      x_project                 => x_project,
      x_task                    => x_task);

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE FND_API.G_exc_unexpected_error;

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

      RAISE FND_API.g_exc_error;

   END IF;

   SELECT COUNT(wdd.delivery_detail_id)
     INTO x_tot_lines_for_del
     FROM
     wsh_delivery_details wdd,
     wsh_delivery_assignments_v wda
     WHERE wdd.organization_id    = p_org_id
     AND   wdd.delivery_detail_id = wda.delivery_detail_id
     AND   wda.delivery_id        = x_delivery_id
     AND   wdd.lpn_id IS NULL;

   SELECT COUNT(wdd.delivery_detail_id)
     INTO x_tot_comp_lines_for_del
     FROM
     wsh_delivery_details wdd,
     wsh_delivery_assignments_v wda
     WHERE wdd.organization_id    = p_org_id
     AND   wdd.released_status    = 'Y'
     AND   wdd.delivery_detail_id = wda.delivery_detail_id
     AND   wda.delivery_id        = x_delivery_id
     AND   wdd.lpn_id IS NULL;

     x_return_status := l_return_status;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_query_by_del_lpn: Error in get_query_by_del_lpn API: ' || sqlerrm);
      END IF;

   WHEN OTHERS THEN

      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('get_query_by_del_lpn: Unexpected Error in get_query_by_del_lpn API: ' || sqlerrm);
      END IF;

END get_query_by_del_lpn;


PROCEDURE lpn_mass_move (p_org_id          IN  NUMBER,
			 p_from_sub        IN  VARCHAR2,
			 p_from_loc_id     IN  NUMBER,
			 p_to_sub          IN  VARCHAR2,
			 p_to_loc_id       IN  NUMBER,
                         p_to_loc_type     IN  NUMBER,
                         p_transfer_lpn_id IN  NUMBER,  -- = 0 when TOLPN is not input on the page
			 x_return_status   OUT NOCOPY VARCHAR2,
			 x_msg_count       OUT NOCOPY NUMBER,
			 x_msg_data        OUT NOCOPY VARCHAR2)

  IS

     CURSOR lpn_csr
       IS
	  SELECT  wlpn.lpn_id
	    FROM  wms_license_plate_numbers wlpn
	    WHERE wlpn.lpn_context       = 11
	    AND   wlpn.subinventory_code = p_from_sub
	    AND   wlpn.locator_id        = p_from_loc_id
	    AND   wlpn.organization_id   = p_org_id
	    AND   wlpn.lpn_id            = wlpn.outermost_lpn_id
	    AND   wlpn.parent_lpn_id     IS NULL;

     l_temp_id NUMBER;
     l_lpn_id  NUMBER;
     l_return   NUMBER;
     l_hdr_id NUMBER;
     l_period_id NUMBER;
     l_open_past_period BOOLEAN;
     l_item_id NUMBER;
     p_user_id NUMBER;
     l_lpns       wms_mdc_pvt.number_table_type;
     l_deliveries wms_mdc_pvt.number_table_type;
     l_allow_packing VARCHAR2(1);
     i NUMBER := 1;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_to_loc_type NUMBER;
BEGIN
p_user_id := fnd_global.user_id;
   SAVEPOINT sp_lpn_mass_move;
   g_trace_on := fnd_profile.value('INV_DEBUG_TRACE') ;

   IF (g_trace_on = 1) THEN mydebug('Entered lpn_mass_move: '); END IF;

   invttmtx.tdatechk(org_id           => p_org_id,
                     transaction_date => sysdate,
                     period_id        => l_period_id,
                     open_past_period => l_open_past_period);

   IF l_period_id = -1 THEN

      IF (g_trace_on = 1) THEN mydebug('lpn_mass_move: Period is invalid');
      END IF;

      FND_MESSAGE.SET_NAME('INV', 'INV_NO_OPEN_PERIOD');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_exc_unexpected_error;

   END IF;

   FOR lpn_rec IN lpn_csr LOOP
      l_lpns(i) := lpn_rec.lpn_id;
      i := i + 1;
   END LOOP;

   IF (g_trace_on = 1) THEN mydebug('l_lpns.count ' || l_lpns.count ); END IF;

   -- MR:  IF p_transfer_lpn_id IS NOT NULL AND p_transfer_lpn_id <> 0  THEN
   -- Commented the above since we want to validate from LPN even when TO_LPN is
   -- not provided, so that LPN mass move without MDC does not move CONSOL LPNs to any
   -- other locator

      -- Call the validation API to check if the from lpns can be dropped into TO lpn
      wms_mdc_pvt.validate_to_lpn(p_from_lpn_ids             => l_lpns,
                                  p_from_delivery_ids        => l_deliveries,
                                  p_to_lpn_id                => p_transfer_lpn_id,
                                  p_to_sub                   => p_to_sub,
                                  p_to_locator_id            => p_to_loc_id,
                                  x_allow_packing            => l_allow_packing,
                                  x_return_status            => x_return_status,
                                  x_msg_count                => x_msg_count,
                                  x_msg_data                 => x_msg_data);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         IF g_trace_on = 1 THEN
            mydebug('lpn_mass_move: Error from wms_mdc_pvt.validate_to_lpn: ' || x_msg_data);
         END IF;
         RAISE fnd_api.g_exc_error;
       ELSE
         IF g_trace_on = 1 THEN
            mydebug('lpn_mass_move: wms_mdc_pvt.validate_to_lpn returned: ' || l_allow_packing);
         END IF;

         IF l_allow_packing = 'N' THEN
            RAISE fnd_api.g_exc_error;
         END IF;

      END IF;
   -- MR: END IF; -- if p_transfer_lpn_id is not null


   IF l_allow_packing = 'C' THEN -- one of the from LPNs is a consol LPN
      IF p_transfer_lpn_id IS NULL OR p_transfer_lpn_id = 0 THEN
         BEGIN
         SELECT mil.inventory_location_type
           INTO l_to_loc_type
           FROM mtl_item_locations mil
          WHERE mil.organization_id       = p_org_id
            AND mil.subinventory_code     = p_to_sub
            AND mil.inventory_location_id = p_to_loc_id;
         IF (g_trace_on = 1) THEN mydebug('l_to_loc_type' || l_to_loc_type ); END IF;
         EXCEPTION WHEN NO_DATA_FOUND THEN
              IF (g_trace_on = 1) THEN mydebug('exception selecting to_loc_type' ); END IF;
              RAISE FND_API.G_exc_unexpected_error;
         END ;
         IF l_to_loc_type <> g_loc_type_staging_lane THEN
            fnd_message.set_name('WMS', 'WMS_STAGE_FROM_CONSOL_LPN'); -- mrana :addmsg
            fnd_msg_pub.ADD;
            IF g_trace_on = 1 THEN
               mydebug('WMS_STAGE_FROM_CONSOL_LPN : Destination Locator must be staging locator when one of' ||
                     ' the From LPNs is a consol LPN : ' );
               -- {{- Destination Locator must be staging locator when one of the From LPNs is a consol LPN }}

            END IF;
            RAISE fnd_api.g_exc_error;
         END IF ;
      END IF ;
   END IF;

   SELECT mtl_material_transactions_s.NEXTVAL INTO l_hdr_id FROM dual;

   IF (g_trace_on = 1) THEN mydebug('l_hdr_id ' || l_hdr_id ); END IF;

   OPEN lpn_csr;
   LOOP
      FETCH lpn_csr INTO l_lpn_id;
      EXIT WHEN lpn_csr%notfound;

      IF (g_trace_on = 1) THEN mydebug('lpn_mass_move: l_lpn_id : ' || l_lpn_id); END IF;


      IF inv_ui_item_sub_loc_lovs.vaildate_lpn_status
        (p_lpn_id              => l_lpn_id,
         p_orgid               => p_org_id,
         p_to_org_id           => p_org_id,
         p_wms_installed       => 'TRUE',
         p_transaction_type_id => 2) = 'N'
        OR
        inv_txn_validations.check_lpn_allocation
        (p_lpn_id              => l_lpn_id,
         p_org_id              => p_org_id,
         x_return_msg          => x_msg_data) = 'N'
        OR
        inv_txn_validations.check_lpn_serial_allocation
        (p_lpn_id              => l_lpn_id,
         p_org_id              => p_org_id,
         x_return_msg          => x_msg_data) = 'N' THEN

	 FND_MESSAGE.SET_NAME('WMS', x_msg_data);
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_exc_unexpected_error;
      END IF;

      IF (g_trace_on = 1) THEN mydebug('after pn validations ...:: ' ); END IF;
      SELECT wlc.inventory_item_id
	INTO l_item_id
	FROM
	wms_lpn_contents wlc,
	wms_license_plate_numbers wlpn
	WHERE wlc.parent_lpn_id     = wlpn.lpn_id
	AND   wlc.organization_id   = wlpn.organization_id
	AND   wlpn.outermost_lpn_id = l_lpn_id
	AND   wlpn.organization_id  = p_org_id
	AND   ROWNUM = 1;
      IF (g_trace_on = 1) THEN mydebug('l_item_id ' || l_item_id); END IF;


   INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP
     (TRANSACTION_HEADER_ID,
      TRANSACTION_TEMP_ID,
      PROCESS_FLAG,
      transaction_status,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      SUBINVENTORY_CODE,
      LOCATOR_ID,
      TRANSFER_SUBINVENTORY ,
      TRANSFER_TO_LOCATION,
      TRANSACTION_QUANTITY,
      PRIMARY_QUANTITY,
      TRANSACTION_UOM,
      TRANSACTION_TYPE_ID,
      TRANSACTION_ACTION_ID,
      TRANSACTION_SOURCE_TYPE_ID,
      TRANSACTION_DATE,
      acct_period_id,
      CONTENT_LPN_ID,
      transfer_lpn_id,
      posting_flag,
      wms_task_type)   -- bug 2879208
     VALUES
     (l_hdr_id,
      mtl_material_transactions_s.NEXTVAL,
      'Y',
      3,
      sysdate,
      p_user_id,
      sysdate,
      p_user_id,
      p_user_id,
      l_item_id,-- inventory item id
      p_org_id,
      p_from_sub,
      p_from_loc_id,
      p_to_sub,
      p_to_loc_id,
      1,--trx qty
      1, --prim qty
      'X',--uom
      2,--	p_trx_type_id,
      2,--	p_trx_action_id,
      13,--	p_trx_src_type_id,
      sysdate, --tran date
      l_period_id,
      l_lpn_id,--content lpn id
      p_transfer_lpn_id, -- transfer lpn id
      'Y',
      7)  -- bug 2879208
	returning transaction_temp_id INTO l_temp_id;
   l_return:=0;
      IF (g_trace_on = 1) THEN mydebug('lpn_mass_move: transaction_temp_id just inserted: ' || l_temp_id);
      END IF;

      IF l_return <> 0 THEN

	 ROLLBACK TO sp_lpn_mass_move;
	 RAISE FND_API.G_exc_unexpected_error;

      END IF;

   END LOOP;
   CLOSE lpn_csr;
   IF (l_debug = 1) THEN
      mydebug('lpn_mass_move:before calling TM for header : ' || l_hdr_id);
   END IF;
   l_return :=inv_lpn_trx_pub.process_lpn_trx
     (p_trx_hdr_id         => l_hdr_id,
      p_commit             => fnd_api.g_false,
      x_proc_msg           => x_msg_data);

   IF (l_debug = 1) THEN mydebug('l_return: ' || l_return); END IF;
   IF l_return <> 0 THEN
      ROLLBACK TO sp_lpn_mass_move;
      FND_MESSAGE.SET_NAME('WMS','WMS_TD_TXNMGR_ERROR' );
      FND_MSG_PUB.ADD;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   COMMIT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN mydebug('exit lpn_mass_move : ' || x_return_status); END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_lpn_mass_move;
      x_return_status:=FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('lpn_mass_move: Expected Error in lpn_mass_move API: ' || sqlerrm);
      END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF (g_trace_on = 1) THEN mydebug('Unexpected ROLLBACK ' ); END IF;
      ROLLBACK TO sp_lpn_mass_move;

   WHEN OTHERS THEN
      ROLLBACK TO sp_lpn_mass_move;
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (g_trace_on = 1) THEN mydebug('lpn_mass_move: Other Unexpected Error in lpn_mass_move API: ' || sqlerrm);
      END IF;

END lpn_mass_move;


PROCEDURE get_lpn_mass_move_sub_lov(x_sub_lov      OUT NOCOPY t_genref,
				    p_sub          IN VARCHAR2,
				    p_org_id       IN NUMBER)

  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_sub_lov FOR

     SELECT DISTINCT
     msi.secondary_inventory_name,
     Nvl(msi.locator_type, 1),
     msi.description,
     msi.asset_inventory,
     msi.picking_order,
     msi.enable_locator_alias
     FROM
     mtl_secondary_inventories msi,
     mtl_item_locations mil
     WHERE msi.organization_id             = p_org_id
     AND   msi.lpn_controlled_flag         = 1
     AND   msi.secondary_inventory_name LIKE p_sub
     AND   msi.secondary_inventory_name    = mil.subinventory_code
     AND   mil.organization_id             = msi.organization_id
     AND   Nvl(mil.inventory_location_type, 3)   IN (g_loc_type_consolidation,
					     g_loc_type_packing_station,
					     g_loc_type_staging_lane)
     AND   inv_material_status_grp.is_status_applicable('Y',
							NULL,
							2,
							NULL,
							NULL,
							p_org_id,
							NULL,
							msi.secondary_inventory_name,
							NULL,
							NULL,
							NULL,
							'Z') = 'Y'
     ORDER BY msi.picking_order;

END get_lpn_mass_move_sub_lov;


PROCEDURE get_lpn_mass_move_locs_lov(x_loc_lov      OUT NOCOPY t_genref,
				     p_org_id       IN NUMBER,
				     p_sub          IN VARCHAR2,
				     p_loc          IN VARCHAR2,
				     p_from_sub     IN VARCHAR2,
				     p_from_loc     IN VARCHAR2,
				     p_alias        IN VARCHAR2)

  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF p_alias IS NULL THEN
      get_lpn_mass_move_locs_lov(
       x_loc_lov      => x_loc_lov
      ,p_org_id       => p_org_id
      ,p_sub          => p_sub
      ,p_loc          => p_loc
      ,p_from_sub     => p_from_sub
      ,p_from_loc     => p_from_loc
      );
      RETURN;
   END IF;
   IF p_from_sub IS NULL THEN

      OPEN x_loc_lov FOR

	SELECT DISTINCT
	milk.inventory_location_id,
	INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
	milk.description,
	ml.meaning,
	mil.picking_order
	FROM
	mtl_item_locations_kfv milk,
	mtl_item_locations mil,
	mfg_lookups ml,
	wms_license_plate_numbers wlpn
	WHERE milk.organization_id          = p_org_id
	AND   milk.alias = p_alias
	AND   milk.subinventory_code        = p_sub
	AND   milk.project_id IS NULL
	AND   milk.task_id IS NULL
	AND   nvl(milk.inventory_location_type, 3) IN (g_loc_type_consolidation,
					       g_loc_type_packing_station,
					       g_loc_type_staging_lane)
	AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
	AND   wlpn.lpn_context              = 11
	AND   wlpn.organization_id          = mil.organization_id
	AND   wlpn.subinventory_code        = mil.subinventory_code
	AND   wlpn.locator_id               = mil.inventory_location_id
	AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	AND   milk.organization_id          = mil.organization_id
	AND  NOT exists
	(
	 SELECT 1
	 FROM
	 wms_license_plate_numbers wlpn2
	 WHERE wlpn2.lpn_context           <> 11
	 AND   wlpn2.organization_id        = mil.organization_id
	 AND   wlpn2.subinventory_code      = mil.subinventory_code
	 AND   wlpn2.locator_id             = mil.inventory_location_id
	 )
	AND NOT exists
	  (
	   SELECT 1
	   FROM mtl_onhand_quantities_detail moqd
	   WHERE moqd.primary_transaction_quantity > 0
	   AND moqd.locator_id = mil.inventory_location_id
	   AND moqd.organization_id = mil.organization_id
	   AND moqd.lpn_id IS NULL
	   )
	AND   inv_material_status_grp.is_status_applicable('Y',
							   NULL,
							   2,
							   NULL,
							   NULL,
							   p_org_id,
							   NULL,
							   milk.subinventory_code,
							   milk.inventory_location_id,
							   NULL,
							   NULL,
							   'L') = 'Y'
	ORDER BY ml.meaning, mil.picking_order;


      ELSE

      OPEN x_loc_lov FOR

	SELECT DISTINCT
	milk.inventory_location_id,
	INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
	milk.description,
	ml.meaning,
	mil.picking_order
	FROM
	mtl_item_locations_kfv milk,
	mtl_item_locations mil,
	mfg_lookups ml
	WHERE milk.organization_id          = p_org_id
	AND   milk.alias = p_alias
	AND   milk.subinventory_code        = p_sub
	AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	AND   milk.organization_id          = mil.organization_id
	AND   milk.project_id IS NULL
	AND   milk.task_id IS NULL
	AND   nvl(milk.inventory_location_type, 3) IN (g_loc_type_consolidation,
					       g_loc_type_packing_station,
					       g_loc_type_staging_lane)
	AND  NOT (milk.subinventory_code    = p_from_sub
		  AND
		  milk.concatenated_segments  LIKE p_from_loc ||'%')
	AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
	AND  NOT exists
	(
	 SELECT 1
	 FROM
	 wms_license_plate_numbers wlpn2
	 WHERE wlpn2.lpn_context                <> 11
	 AND   wlpn2.organization_id             = mil.organization_id
	 AND   wlpn2.subinventory_code           = mil.subinventory_code
	 AND   wlpn2.locator_id                  = mil.inventory_location_id
	 )
	AND   inv_material_status_grp.is_status_applicable('Y',
							   NULL,
							   2,
							   NULL,
							   NULL,
							   p_org_id,
							   NULL,
							   milk.subinventory_code,
							   milk.inventory_location_id,
							   NULL,
							   NULL,
							   'L') = 'Y'
	ORDER BY ml.meaning, mil.picking_order;

   END IF;

END get_lpn_mass_move_locs_lov;

PROCEDURE get_lpn_mass_move_locs_lov(x_loc_lov      OUT NOCOPY t_genref,
				     p_org_id       IN NUMBER,
				     p_sub          IN VARCHAR2,
				     p_loc          IN VARCHAR2,
				     p_from_sub     IN VARCHAR2,
				     p_from_loc     IN VARCHAR2)

  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF p_from_sub IS NULL THEN

      OPEN x_loc_lov FOR

	SELECT DISTINCT
	milk.inventory_location_id,
	INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
	milk.description,
	ml.meaning,
	mil.picking_order
	FROM
	mtl_item_locations_kfv milk,
	mtl_item_locations mil,
	mfg_lookups ml,
	wms_license_plate_numbers wlpn
	WHERE milk.organization_id          = p_org_id
	AND   INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) LIKE p_loc
	AND   milk.subinventory_code        = p_sub
	AND   milk.project_id IS NULL
	AND   milk.task_id IS NULL
	AND   nvl(milk.inventory_location_type, 3) IN (g_loc_type_consolidation,
					       g_loc_type_packing_station,
					       g_loc_type_staging_lane)
	AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
	AND   wlpn.lpn_context              = 11
	AND   wlpn.organization_id          = mil.organization_id
	AND   wlpn.subinventory_code        = mil.subinventory_code
	AND   wlpn.locator_id               = mil.inventory_location_id
	AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	AND   milk.organization_id          = mil.organization_id
	AND  NOT exists
	(
	 SELECT 1
	 FROM
	 wms_license_plate_numbers wlpn2
	 WHERE wlpn2.lpn_context           <> 11
	 AND   wlpn2.organization_id        = mil.organization_id
	 AND   wlpn2.subinventory_code      = mil.subinventory_code
	 AND   wlpn2.locator_id             = mil.inventory_location_id
	 )
	AND NOT exists
	  (
	   SELECT 1
	   FROM mtl_onhand_quantities_detail moqd
	   WHERE moqd.primary_transaction_quantity > 0
	   AND moqd.locator_id = mil.inventory_location_id
	   AND moqd.organization_id = mil.organization_id
	   AND moqd.lpn_id IS NULL
	   )
	AND   inv_material_status_grp.is_status_applicable('Y',
							   NULL,
							   2,
							   NULL,
							   NULL,
							   p_org_id,
							   NULL,
							   milk.subinventory_code,
							   milk.inventory_location_id,
							   NULL,
							   NULL,
							   'L') = 'Y'
	ORDER BY ml.meaning, mil.picking_order;


      ELSE

      OPEN x_loc_lov FOR

	SELECT DISTINCT
	milk.inventory_location_id,
	INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
	milk.description,
	ml.meaning,
	mil.picking_order
	FROM
	mtl_item_locations_kfv milk,
	mtl_item_locations mil,
	mfg_lookups ml
	WHERE milk.organization_id          = p_org_id
	AND   INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id)  LIKE p_loc
	AND   milk.subinventory_code        = p_sub
	AND   milk.inventory_location_id    = Nvl(mil.physical_location_id, mil.inventory_location_id)
	AND   milk.organization_id          = mil.organization_id
	AND   milk.project_id IS NULL
	AND   milk.task_id IS NULL
	AND   nvl(milk.inventory_location_type, 3) IN (g_loc_type_consolidation,
					       g_loc_type_packing_station,
					       g_loc_type_staging_lane)
	AND  NOT (milk.subinventory_code    = p_from_sub
		  AND
		  milk.concatenated_segments  LIKE p_from_loc ||'%')
	AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
	AND  NOT exists
	(
	 SELECT 1
	 FROM
	 wms_license_plate_numbers wlpn2
	 WHERE wlpn2.lpn_context                <> 11
	 AND   wlpn2.organization_id             = mil.organization_id
	 AND   wlpn2.subinventory_code           = mil.subinventory_code
	 AND   wlpn2.locator_id                  = mil.inventory_location_id
	 )
	AND   inv_material_status_grp.is_status_applicable('Y',
							   NULL,
							   2,
							   NULL,
							   NULL,
							   p_org_id,
							   NULL,
							   milk.subinventory_code,
							   milk.inventory_location_id,
							   NULL,
							   NULL,
							   'L') = 'Y'
	ORDER BY ml.meaning, mil.picking_order;

   END IF;

END get_lpn_mass_move_locs_lov;


PROCEDURE get_lpn_mass_move_lpn_lov(x_lpn_lov      OUT NOCOPY t_genref,
                                    p_org_id       IN NUMBER,
                                    p_lpn          IN VARCHAR2,
                                    p_from_loc_id  IN VARCHAR2) IS
BEGIN
   OPEN x_lpn_lov FOR
     SELECT lpn_id, license_plate_number, inventory_location_id,
            concatenated_segments, subinventory_code, lpn_context
     FROM (
     SELECT DISTINCT
        wlpn.lpn_id,
        wlpn.license_plate_number,
        milk.inventory_location_id,
        inv_project.get_locsegs(milk.inventory_location_id, milk.organization_id) concatenated_segments,
        milk.subinventory_code,
        11 lpn_context
     FROM
        wms_license_plate_numbers wlpn,
        mtl_item_locations_kfv milk
     WHERE wlpn.license_plate_number LIKE p_lpn
     AND wlpn.locator_id <> p_from_loc_id -- Make sure that we don't choose the TO lpn FROM the FROM locator
     AND milk.organization_id = p_org_id
     AND milk.project_id IS NULL
     AND milk.task_id IS NULL
     AND nvl(milk.inventory_location_type, 3) IN (g_loc_type_consolidation,
                                                  g_loc_type_packing_station,
                                                  g_loc_type_staging_lane)
     AND wlpn.lpn_context = 11 -- Picked
     AND wlpn.organization_id = milk.organization_id
     AND wlpn.locator_id = milk.inventory_location_id
     UNION ALL
     SELECT DISTINCT
        wlpn.lpn_id,
        wlpn.license_plate_number,
        NULL,
        NULL,
        NULL,
        5 lpn_context
     FROM
        wms_license_plate_numbers wlpn
     WHERE wlpn.license_plate_number LIKE p_lpn
     AND wlpn.lpn_context = 5  -- Defined but not used
     AND wlpn.organization_id = p_org_id)
     ORDER BY license_plate_number;

END get_lpn_mass_move_lpn_lov;


PROCEDURE get_empty_cons_loc_lov(x_loc_lov      OUT NOCOPY t_genref,
				 p_sub          IN VARCHAR2,
				 p_loc          IN VARCHAR2,
				 p_org_id       IN NUMBER)

  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_loc_lov FOR

     SELECT DISTINCT
     milk.inventory_location_id,
     INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
     milk.description,
     ml.meaning,
     mil.dropping_order
     FROM
     mtl_item_locations_kfv milk,
     mtl_item_locations mil,
     mfg_lookups ml
     WHERE milk.organization_id          = p_org_id
     AND   INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) LIKE p_loc
     AND   milk.subinventory_code        = p_sub
     AND   milk.inventory_location_id    = mil.inventory_location_id
     AND   milk.organization_id          = mil.organization_id
     AND   milk.project_id IS NULL
     AND   milk.task_id IS NULL
     AND   nvl(milk.inventory_location_type, 3) IN (g_loc_type_consolidation,
					    g_loc_type_packing_station,
					    g_loc_type_staging_lane)
     AND   nvl(mil.empty_flag, 'Y')     = 'Y'
     AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
     AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
     ORDER BY ml.meaning, mil.dropping_order;

END get_empty_cons_loc_lov;

PROCEDURE get_empty_cons_loc_lov(x_loc_lov      OUT NOCOPY t_genref,
				 p_sub          IN VARCHAR2,
				 p_loc          IN VARCHAR2,
				 p_org_id       IN NUMBER,
				 p_alias        IN VARCHAR2)

  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF p_alias IS NULL THEN
      get_empty_cons_loc_lov(
       x_loc_lov      => x_loc_lov
      ,p_sub          => p_sub
      ,p_loc          => p_loc
      ,p_org_id       => p_org_id
      );
      RETURN;
   END IF;

   OPEN x_loc_lov FOR

     SELECT DISTINCT
     milk.inventory_location_id,
     INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
     milk.description,
     ml.meaning,
     mil.dropping_order
     FROM
     mtl_item_locations_kfv milk,
     mtl_item_locations mil,
     mfg_lookups ml
     WHERE milk.organization_id          = p_org_id
     AND   milk.alias = p_alias
     AND   milk.subinventory_code        = p_sub
     AND   milk.inventory_location_id    = mil.inventory_location_id
     AND   milk.organization_id          = mil.organization_id
     AND   milk.project_id IS NULL
     AND   milk.task_id IS NULL
     AND   nvl(milk.inventory_location_type, 3) IN (g_loc_type_consolidation,
					    g_loc_type_packing_station,
					    g_loc_type_staging_lane)
     AND   nvl(mil.empty_flag, 'Y')     = 'Y'
     AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
     AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
     ORDER BY ml.meaning, mil.dropping_order;

END get_empty_cons_loc_lov;


--This procedure gets the first empty consolidation loc

PROCEDURE get_empty_cons_loc(p_sub             IN  VARCHAR2,
			     p_org_id          IN  NUMBER,
			     x_loc             OUT NOCOPY VARCHAR2,
			     x_loc_count       OUT NOCOPY NUMBER,
			     x_return_status   OUT NOCOPY VARCHAR2,
			     x_msg_count       OUT NOCOPY NUMBER,
			     x_msg_data        OUT NOCOPY VARCHAR2)

  IS

     CURSOR empty_loc_csr IS

	SELECT DISTINCT
	  INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id) concatenated_segments,
	  ml.meaning,
	  mil.dropping_order
	  FROM
	  mtl_item_locations_kfv milk,
	  mtl_item_locations mil,
	  mfg_lookups ml
	  WHERE milk.organization_id          = p_org_id
	  AND   milk.subinventory_code        = p_sub
	  AND   milk.inventory_location_id    = mil.inventory_location_id
	  AND   milk.organization_id          = mil.organization_id
	  AND   nvl(milk.inventory_location_type, 3) IN (g_loc_type_consolidation,
						 g_loc_type_packing_station,
						 g_loc_type_staging_lane)
	  AND   nvl(mil.empty_flag, 'Y')     = 'Y'
	  AND   ml.lookup_type                = 'MTL_LOCATOR_TYPES'
	  AND   ml.lookup_code                = nvl(milk.inventory_location_type, 3)
	  ORDER BY ml.meaning, mil.dropping_order;

     l_loc_rec empty_loc_csr%ROWTYPE;
     l_count NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return_status := 'S';

   l_count := 0;
   OPEN empty_loc_csr;
   LOOP
      FETCH empty_loc_csr INTO l_loc_rec;
      EXIT WHEN empty_loc_csr%notfound;

      l_count := l_count + 1;
      IF l_count = 1 THEN x_loc := l_loc_rec.concatenated_segments;
      END IF;

   END LOOP;
   CLOSE empty_loc_csr;

   x_loc_count := l_count;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

   WHEN OTHERS THEN

      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

END get_empty_cons_loc;



FUNCTION is_delivery_consolidated(p_delivery_id IN NUMBER,
				  p_org_id      IN NUMBER,
				  p_sub         IN VARCHAR2 DEFAULT NULL,  -- added default for packing workbench query (patchset J)
				  p_loc_id      IN NUMBER DEFAULT NULL)  -- added default for packing workbench query (patchset J)

  RETURN VARCHAR2 IS

     l_is_delivery_consolidated VARCHAR2(2) := 'N';
     l_count NUMBER := 0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

     BEGIN

	SELECT 1
	  INTO l_count
	  FROM
	  wms_license_plate_numbers wlpn,
      --  wms_dispatched_tasks_history wdth,  Commented by Bug#4337112.
	  wsh_delivery_details wdd2,
	  wsh_delivery_assignments_v wda
	  WHERE wda.delivery_id               = p_delivery_id
	  AND   wda.parent_delivery_detail_id = wdd2.delivery_detail_id
	  AND   wdd2.lpn_id                   = wlpn.lpn_id
	  AND   wlpn.lpn_context              in ( 11,12)
	  AND   wlpn.subinventory_code        = Nvl(p_sub, wlpn.subinventory_code)  -- added NVL for packing workbench query (patchset J)
	  AND   wlpn.locator_id               = Nvl(p_loc_id, wlpn.locator_id) -- added NVL for packing workbench query (patchset J)
	  AND   wlpn.organization_id          = p_org_id
      --  AND   wlpn.lpn_id                   = wdth.transfer_lpn_id Commented by Bug#4337112.
	  AND NOT exists
	  (
	   SELECT 1
	   FROM
	   mtl_material_transactions_temp mmtt,
	   wsh_delivery_details wdd1,
	   wsh_delivery_assignments_v wda2
	   WHERE wda2.delivery_id              = p_delivery_id
	   AND   wda2.delivery_detail_id       = wdd1.delivery_detail_id
	   AND   wdd1.organization_id          = p_org_id
	   AND   wdd1.released_status          = 'S'
	   AND   wdd1.move_order_line_id       = mmtt.move_order_line_id
	   AND   wdd1.organization_id          = mmtt.organization_id
       --  AND   wdth.operation_plan_id        = mmtt.operation_plan_id Commented by Bug#4337112.
	   );


     EXCEPTION
	WHEN no_data_found THEN
	   l_count := 0;

	WHEN too_many_rows THEN
	   l_count := 1;

     END;

     IF l_count > 0 THEN

	l_is_delivery_consolidated := 'Y';

     END IF;

     RETURN l_is_delivery_consolidated;

END is_delivery_consolidated;



PROCEDURE create_staging_move
  (p_org_id                       IN  NUMBER
   ,  p_user_id                   IN  NUMBER
   ,  p_emp_id                    IN  NUMBER
   ,  p_eqp_ins                   IN  VARCHAR2
   ,  p_lpn_id                    IN  NUMBER
   ,  x_return_status             OUT nocopy VARCHAR2
   ,  x_msg_count                 OUT NOCOPY  NUMBER
   ,  x_msg_data                  OUT NOCOPY  VARCHAR2
   ,  p_calling_mode              IN VARCHAR2
   ,  p_temp_id                   OUT NOCOPY NUMBER
   ) IS

      l_from_sub VARCHAR2(60);
      l_from_loc NUMBER;
      l_task_type VARCHAR2(30);
      l_orig_sub VARCHAR2(30);
      l_orig_loc NUMBER;
      l_op_plan_id NUMBER;

      l_temp_id NUMBER := 0;

      l_period_id NUMBER;
      l_open_past_period BOOLEAN;
      l_item_id NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SAVEPOINT sp_stg_move;

   -- Since the forms-server and MWA server recycles database connections
   -- we need to always check for debug profiles values and see if they
   -- are different from the values with which it was initialized earlier. If
   -- different then reinitialize the debug variables
   g_trace_on := fnd_profile.value('INV_DEBUG_TRACE') ;

   IF (g_trace_on = 1) THEN

      IF (l_debug = 1) THEN
         mydebug('WMS_Staging_Move_Pvt: In Create Staging Move API: 10');
         mydebug('WMS_Staging_Move_Pvt: Initializing Variables: 11');

	 mydebug('p_org_id: '||p_org_id);
	 mydebug('p_user_id: '||p_user_id);
	 mydebug('p_emp_id: '||p_emp_id);
	 mydebug('p_eqp_ins: '||p_eqp_ins);
	 mydebug('p_lpn_id: '||p_lpn_id);
	 mydebug('p_calling_mode: '||p_calling_mode);
	 mydebug('p_temp_id: '||p_temp_id);

    END IF;


   END IF;

   x_return_status := 'S';

   l_task_type:=7; --hard coded to be Staging Move task type


   IF (g_trace_on = 1) THEN

      IF (l_debug = 1) THEN
         mydebug('WMS_Staging_Move_Pvt: Checking Acct period ID: 13');
      END IF;

   END IF;


   invttmtx.tdatechk(org_id           => p_org_id,
		     transaction_date => sysdate,
		     period_id        => l_period_id,
		     open_past_period => l_open_past_period);

   IF l_period_id = -1 THEN

      IF (g_trace_on = 1) THEN

	 IF (l_debug = 1) THEN
   	 mydebug('WMS_Staging_Move_Pvt: Period is invalid: 15');
	 END IF;

      END IF;

      FND_MESSAGE.SET_NAME('INV', 'INV_NO_OPEN_PERIOD');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_exc_unexpected_error;

   END IF;


   BEGIN

      SELECT mmtt.transaction_temp_id
	INTO l_temp_id
	FROM
	wms_dispatched_tasks wdt,
	mtl_material_transactions_temp mmtt
	WHERE mmtt.organization_id     = p_org_id
	AND   mmtt.transfer_lpn_id     = p_lpn_id
	AND   mmtt.transaction_temp_id = wdt.transaction_temp_id
	AND   ROWNUM = 1;


   EXCEPTION
      WHEN no_data_found THEN
	 l_temp_id := 0;
   END;


   IF (l_temp_id > 0) THEN

      IF (g_trace_on = 1) THEN
	 IF (l_debug = 1) THEN
   	 mydebug('WMS_Staging_Move_Pvt: LPN  already loaded: 29');
	 END IF;
      END IF;

      IF p_calling_mode = 'LOAD' THEN
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_LOADED_ERROR');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_exc_unexpected_error;

       ELSE
	 p_temp_id := l_temp_id;
	 RETURN;
      END IF;

   END IF;


   IF (g_trace_on = 1) THEN

      IF (l_debug = 1) THEN
         mydebug('WMS_Staging_Move_Pvt: Checking Mtl Status: 29.3');
      END IF;

   END IF;

   IF inv_ui_item_sub_loc_lovs.vaildate_lpn_status
     (p_lpn_id              => p_lpn_id,
      p_orgid               => p_org_id,
      p_to_org_id           => p_org_id,
      p_wms_installed       => 'TRUE',
      p_transaction_type_id => 2) = 'N'
     OR
     inv_txn_validations.check_lpn_allocation
     (p_lpn_id              => p_lpn_id,
      p_org_id              => p_org_id,
      x_return_msg          => x_msg_data) = 'N'
     OR
     inv_txn_validations.check_lpn_serial_allocation
     (p_lpn_id              => p_lpn_id,
      p_org_id              => p_org_id,
      x_return_msg          => x_msg_data) = 'N' THEN

      IF (g_trace_on = 1) THEN
	 IF (l_debug = 1) THEN
   	 mydebug('WMS_Staging_Move_Pvt: Mtl Status Check Failed: 29.5');
	 END IF;
      END IF;

      FND_MESSAGE.SET_NAME('WMS', x_msg_data);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_exc_unexpected_error;
   END IF;

   IF (g_trace_on = 1) THEN
      IF (l_debug = 1) THEN
         mydebug('WMS_Staging_Move_Pvt: Calculate Original Destination: 32');
      END IF;
   END IF;

   BEGIN
      SELECT
	wdth.suggested_dest_subinventory,
	wdth.suggested_dest_locator_id,
	wdth.operation_plan_id,
	wlpn.subinventory_code,
	wlpn.locator_id
	INTO
	l_orig_sub,
	l_orig_loc,
	l_op_plan_id,
	l_from_sub,
	l_from_loc
	FROM
	wms_dispatched_tasks_history wdth,
	wms_license_plate_numbers wlpn
	WHERE wlpn.organization_id   = p_org_id
	AND   wlpn.outermost_lpn_id  = p_lpn_id
	AND   wdth.organization_id   = p_org_id
	AND   wdth.transfer_lpn_id   = wlpn.lpn_id
        AND   wdth.task_type = WMS_GLOBALS.G_WMS_TASK_TYPE_PICK  --Bug5883610
	AND   ROWNUM < 2;


   EXCEPTION
      WHEN no_data_found THEN
	 IF (g_trace_on = 1) THEN
	    IF (l_debug = 1) THEN
   	    mydebug('WMS_Staging_Move_Pvt: No corresponding rows found in WDTH: 35');
	    END IF;
	 END IF;
	 --Fix for the bug #4157153.Added the following Block.
	 --In case of Staging move for a splitted LPN, we will not have WDTH.
	 BEGIN
             SELECT wlpn.subinventory_code, wlpn.locator_id
	     INTO   l_from_sub, l_from_loc
             FROM   wms_license_plate_numbers wlpn
             WHERE  wlpn.lpn_id  =  p_lpn_id; --Bug#4337112. Changed outermost_lpn_id to lpn_id

             --Populate the suggested sub and loc
             l_orig_sub := l_from_sub;
             l_orig_loc := l_from_loc;
             IF (g_trace_on = 1 and l_debug = 1) THEN
   	        mydebug('WMS_Staging_Move_Pvt: For LPNs with no WDTH- l_from_sub:'||l_from_sub||',l_from_loc:'||l_from_loc);
	     END IF;
          EXCEPTION
          WHEN no_data_found THEN
             FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_LPN');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
	  END; --End of Fix for bug #4157153.
   END;

   SELECT wlc.inventory_item_id
     INTO l_item_id
     FROM
     wms_lpn_contents wlc,
     wms_license_plate_numbers wlpn
     WHERE wlc.parent_lpn_id     = wlpn.lpn_id
     AND   wlc.organization_id   = wlpn.organization_id
     AND   wlpn.outermost_lpn_id = p_lpn_id
     AND   wlpn.organization_id  = p_org_id
     AND   ROWNUM = 1;

   INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP
     (TRANSACTION_HEADER_ID,
      TRANSACTION_TEMP_ID,
      PROCESS_FLAG,
      transaction_status,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      SUBINVENTORY_CODE,
      LOCATOR_ID,
      transfer_organization,
      TRANSFER_SUBINVENTORY ,
      TRANSFER_TO_LOCATION,
      TRANSACTION_QUANTITY,
      PRIMARY_QUANTITY,
      TRANSACTION_UOM,
      TRANSACTION_TYPE_ID,
      TRANSACTION_ACTION_ID,
      TRANSACTION_SOURCE_TYPE_ID,
      TRANSACTION_DATE,
      acct_period_id,
      CONTENT_LPN_ID,
      posting_flag,
      operation_plan_id,
      wms_task_type,
      transfer_lpn_id)
     VALUES
     (mtl_material_transactions_s.nextval,
      mtl_material_transactions_s.NEXTVAL,
      'Y',
      2,
      sysdate,
      p_user_id,
      sysdate,
      p_user_id,
      p_user_id,
      l_item_id,-- inventory item id
      p_org_id,
      l_from_sub,
      l_from_loc,
      p_org_id,
      l_orig_sub,
      l_orig_loc,
      1,--trx qty
      1, --prim qty
      'X',--uom
      2,--	p_trx_type_id,
      2,--	p_trx_action_id,
      13,--	p_trx_src_type_id,
      sysdate, --tran date
      l_period_id,
      p_lpn_id,--content lpn id
      'Y',
      l_op_plan_id,
      l_task_type,
      p_lpn_id)
     returning transaction_temp_id INTO p_temp_id;


   INSERT INTO WMS_DISPATCHED_TASKS
     (TASK_ID                 ,
      TRANSACTION_TEMP_ID    ,
      ORGANIZATION_ID      ,
      USER_TASK_TYPE      ,
      PERSON_ID          ,
      EFFECTIVE_START_DATE ,
      EFFECTIVE_END_DATE  ,
      EQUIPMENT_ID       ,
      EQUIPMENT_INSTANCE   ,
      PERSON_RESOURCE_ID   ,
      MACHINE_RESOURCE_ID  ,
      STATUS              ,
      DISPATCHED_TIME     ,
      LAST_UPDATE_DATE      ,
      LAST_UPDATED_BY    ,
      CREATION_DATE    ,
      CREATED_BY ,
      task_type,
      suggested_dest_subinventory,
      suggested_dest_locator_id,
      operation_plan_id,
      TRANSFER_LPN_ID)
     VALUES(wms_dispatched_tasks_s.nextval,
	    p_temp_id,
	    p_org_id,
	    2,
	    p_emp_id,
	    sysdate,
	    sysdate,
	    0,
	    p_eqp_ins,
	    0,
	    0,
	    4,
	    sysdate,
	    sysdate,
	    p_user_id,
	    sysdate,
	    p_user_id,
	    l_task_type,
	    l_orig_sub,
	    l_orig_loc,
	    l_op_plan_id,
	    p_lpn_id
	    );


   IF (l_debug = 1) THEN
      mydebug('Update lpn_context to packing context - p_lpn_id: ' || p_lpn_id
                || ':' || wms_container_pvt.lpn_loaded_in_stage);
   END IF;

   /* bug 3424353
   * change the staus of the inner ones also to packing

     UPDATE wms_license_plate_numbers
     SET lpn_context = wms_container_pub.lpn_context_packing
     WHERE lpn_id = p_lpn_id;
     */

     wms_container_pvt.Modify_LPN_Wrapper
     ( p_api_version    =>  1.0
       ,x_return_status =>  x_return_status
       ,x_msg_count     =>  x_msg_count
       ,x_msg_data      =>  x_msg_data
       ,p_caller        =>  'WMS_CONS_STG_MV'   -- Staging move
       ,p_lpn_id        =>  p_lpn_id
       ,p_lpn_context   =>  wms_container_pvt.lpn_loaded_in_stage
       );

   IF (l_debug = 1) THEN
      mydebug('After wms_container_pvt.Modify_LPN_Wrapper: x_return_status' ||x_return_status );
   END IF;
   -- MRANA - MDC */
   IF p_calling_mode = 'LOAD' THEN
      IF (l_debug = 1) THEN
         mydebug('Commit ' || p_calling_mode );
      END IF;

      COMMIT;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_stg_move;
      x_return_status:=FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );
      IF (g_trace_on = 1) THEN
	 IF (l_debug = 1) THEN
   	 mydebug('create_staging_move: Error in create_staging_move API: ' || sqlerrm);
	 END IF;
      END IF;


   WHEN OTHERS THEN

      ROLLBACK TO sp_stg_move;
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );
      IF (g_trace_on = 1) THEN
	 IF (l_debug = 1) THEN
   	 mydebug('create_staging_move: Unexpected Error in create_staging_move API: ' || sqlerrm);
	 END IF;
      END IF;



END create_staging_move;


PROCEDURE mydebug(msg in varchar2)
  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   inv_mobile_helper_functions.tracelog
     (p_err_msg => msg,
      p_module  => 'wms_consolidation_pub',
      p_level   => 4);

   --dbms_output.put_line(msg);

   null;
END;

END wms_consolidation_pub;

/
