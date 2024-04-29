--------------------------------------------------------
--  DDL for Package Body GML_MOBILE_SHIP_CONFIRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_MOBILE_SHIP_CONFIRM" AS
  /* $Header: GMLMOSCB.pls 120.0 2005/05/25 16:50:52 appldev noship $ */


g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
g_gtin_code_length NUMBER := 14;


PROCEDURE CHECK_SHIP_SET(
                             p_delivery_id IN NUMBER,
                             x_ship_set      OUT NOCOPY VARCHAR2,
                             x_return_Status OUT NOCOPY VARCHAR2,
                             x_error_msg     OUT NOCOPY VARCHAR2)
    IS
        l_ship_set VARCHAR2(2000) := NULL;
        l_ship_set_id   NUMBER;
        l_ship_set_name VARCHAR2(30);
        unshipped_count NUMBER;

        CURSOR specified_ship_set  IS
               SELECT wdd.ship_set_id
                 FROM wsh_delivery_details      wdd,
                      wsh_delivery_assignments  wda
                WHERE wdd.delivery_detail_id = wda.delivery_detail_id
                  AND EXISTS (SELECT 'x'
                                FROM wsh_delivery_details  wdd2
                               WHERE wdd2.delivery_detail_id = wdd.delivery_detail_id
                                 AND wdd2.ship_set_id      is not null
                                 AND wdd2.shipped_quantity is not null)
                  AND wda.delivery_id        = p_delivery_id;

    BEGIN
        x_return_status := 'C';
        OPEN  specified_ship_set;
        loop
            FETCH specified_ship_set INTO l_ship_set_id;
            EXIT WHEN specified_ship_set%NOTFOUND;
            SELECT count(*)
            INTO unshipped_count
            FROM wsh_delivery_details wdd,
                    wsh_delivery_assignments wda,
                    wsh_new_deliveries wnd
            WHERE wdd.delivery_detail_id = wda.delivery_detail_id
               AND   wda.delivery_id = wnd.delivery_id
               AND   wnd.delivery_id = p_delivery_id
               AND   wdd.ship_set_id = l_ship_set_id
               AND   wdd.shipped_quantity is null;
            if (unshipped_count >0 ) then
                select set_name
                into l_ship_set_name
                from oe_sets
                where set_id = l_ship_set_id;
                if (l_ship_set is null) then
                    l_ship_set := l_ship_set_name;
                else l_ship_set := l_ship_set ||', '||l_ship_set_name;
                end if;
            end if;
         end loop;
         close specified_ship_set;
         if l_ship_set is null then
             x_return_status := 'C';
         else
             x_return_status := 'E';
             x_ship_set := l_ship_set;
         end if;
    EXCEPTION
         WHEN OTHERS THEN
             x_return_status := 'U';
END CHECK_SHIP_SET;

PROCEDURE CHECK_COMPLETE_DELVIERY(
                             p_delivery_id IN NUMBER,
                             x_return_Status OUT NOCOPY VARCHAR2,
                             x_error_msg     OUT NOCOPY VARCHAR2) IS
        exist_unspecified  NUMBER;
    BEGIN
        x_return_Status := 'C';
        select 1
        into exist_unspecified
        from dual
        where exists (select 1
                      from wsh_delivery_details wdd,
                           wsh_delivery_assignments wda
                      WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
                        AND  wdd.shipped_quantity is null
                        AND  wda.delivery_id = p_delivery_id
                       );
        if exist_unspecified = 1 then x_return_Status := 'E'; end if;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_return_Status := 'C';
            WHEN OTHERS THEN
                x_return_Status := 'U';
END CHECK_COMPLETE_DELVIERY;

PROCEDURE INV_DELIVERY_LINE_INFO(x_deliveryLineInfo OUT NOCOPY t_genref,
                                 p_delivery_id IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 x_return_Status OUT NOCOPY VARCHAR2) IS
BEGIN
     x_return_Status := 'C';

     OPEN x_deliveryLineInfo FOR
        SELECT ' ',del.name delivery_name, dd.delivery_detail_id,
        dd.inventory_item_id,msik.concatenated_segments, msik.description,
        dd.requested_quantity, dd.requested_quantity_uom,
        dd.serial_number, del.waybill, Nvl(msik.serial_number_control_code, 1),
        dd.subinventory, Nvl(dd.locator_id,0),dd.tracking_number,
        nvl(dd.transaction_temp_id,0),
        dd.picked_quantity, dd.requested_quantity_uom2, NVL(dd.lot_number, ' '), NVL(dd.picked_quantity2,0)
        ---FROM wsh_new_deliveries_ob_grp_v del, wsh_delivery_details_ob_grp_v dd,
        FROM wsh_new_deliveries del, wsh_delivery_details dd,
        wsh_delivery_assignments da, mtl_system_items_kfv msik
        WHERE da.delivery_id = del.delivery_id
        AND   da.delivery_detail_id = dd.delivery_detail_id
        AND   ( dd.inventory_item_id = p_inventory_item_id or p_inventory_item_id = -1 )
        AND   NVL( dd.inv_interfaced_flag, 'N') = 'N'
        AND   dd.released_status = 'Y'
        AND   del.delivery_id = p_delivery_id
        AND   msik.inventory_item_id(+) = dd.inventory_item_id
        AND   msik.organization_id(+) = dd.organization_id
        ORDER BY dd.subinventory,dd.locator_id, msik.concatenated_segments;

EXCEPTION
   when others then
      x_return_Status := 'E';

END INV_DELIVERY_LINE_INFO;


PROCEDURE INV_LINE_RETURN_TO_STOCK(p_delivery_id IN NUMBER,
				   p_delivery_line_id IN NUMBER,
				   p_shipped_quantity IN NUMBER,
				   p_shipped_quantity2 IN NUMBER,
				   x_return_status OUT NOCOPY VARCHAR2,
				   x_msg_data OUT NOCOPY VARCHAR2,
				   x_msg_count OUT NOCOPY NUMBER,
				   p_commit_flag IN VARCHAR2 DEFAULT FND_API.g_false,
				   p_relieve_rsv  IN VARCHAR2 DEFAULT 'Y')
IS
     cursor delivery_line(p_delivery_detail_id NUMBER) is
	select dd.delivery_detail_id,
          dd.requested_quantity,
          dd.picked_quantity,
          NVL(dd.requested_quantity2,0),
          NVL(dd.picked_quantity2, 0)
	  ---from wsh_delivery_details_ob_grp_v dd
	  from wsh_delivery_details dd
	  WHERE dd.delivery_detail_id = p_delivery_detail_id;

     cursor lpn_csr(p_delivery_detail_id in NUMBER) is
	select wdd.delivery_detail_id, wda.delivery_assignment_id,wda2.delivery_assignment_id
	  ---from wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments wda, wsh_delivery_details_ob_grp_v wdd2
	  from wsh_delivery_details wdd, wsh_delivery_assignments wda, wsh_delivery_details wdd2
	  , wsh_delivery_assignments wda2
	  where wdd.delivery_detail_id = wda.parent_delivery_detail_id
	  and wda.delivery_detail_id = wdd2.delivery_detail_id
	  and wdd2.delivery_detail_id = p_delivery_detail_id
	  and wda2.delivery_detail_id = wdd.delivery_detail_id;

     CURSOR nested_parent_lpn_cursor(l_inner_lpn_id NUMBER) is
	SELECT lpn_id
	  FROM WMS_LICENSE_PLATE_NUMBERS
	  START WITH lpn_id = l_inner_lpn_id
	  CONNECT BY lpn_id = PRIOR parent_lpn_id;

     l_delivery_details_id_table   WSH_UTIL_CORE.ID_TAB_TYPE;
     l_backorder_quantities_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_backorder_quantities2_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_requested_quantities_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_requested_quantities2_table  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_overpicked_quantities_table WSH_UTIL_CORE.ID_TAB_TYPE;
     l_overpicked_quantities2_table WSH_UTIL_CORE.ID_TAB_TYPE;
     l_dummy_table                 wsh_util_core.id_tab_type;
     l_out_rows                    wsh_util_core.id_tab_type;
     l_detail_attributes           wsh_delivery_details_pub.ChangedAttributeTabType;
     l_dummy_num_var               NUMBER := NULL;
     l_table_index                 NUMBER := 1;

     l_picked_quantity             NUMBER;
     l_picked_quantity2            NUMBER;
     l_parent_delivery_detail_id   NUMBER;
     l_bo_delivery_detail_id       NUMBER;
     l_delivery_assignment_id      NUMBER;
     l_par_delivery_assignment_id  NUMBER;
     l_lpn_id                      NUMBER;

     l_more_detail                 NUMBER;

     l_return_status               VARCHAR2(1);
     l_msg_count                   NUMBER;
     l_msg_data                    VARCHAR2(2000);

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   --this cursor only returns 1 record because delivery_line_id is an
   --unique key
   OPEN delivery_line(p_delivery_line_id);

   FETCH delivery_line INTO
     l_delivery_details_id_table(1),
     l_requested_quantities_table(1),
     l_picked_quantity,
     l_requested_quantities2_table(1),
     l_picked_quantity2;


   IF l_picked_quantity > l_requested_quantities_table(1) THEN
      l_backorder_quantities_table(1) :=
	l_picked_quantity - p_shipped_quantity;

      l_overpicked_quantities_table(1) :=
	l_picked_quantity - l_requested_quantities_table(1);
    ELSE
      l_backorder_quantities_table(1) :=
	l_requested_quantities_table(1) -
	p_shipped_quantity;

      l_overpicked_quantities_table(1) := 0;
   END IF;

   IF l_picked_quantity2 > l_requested_quantities2_table(1) THEN
      l_backorder_quantities2_table(1) :=
	l_picked_quantity2 - p_shipped_quantity2;

      l_overpicked_quantities2_table(1) :=
	l_picked_quantity2 - l_requested_quantities2_table(1);
    ELSE
      l_backorder_quantities2_table(1) :=
	l_requested_quantities2_table(1) -
	p_shipped_quantity2;

      l_overpicked_quantities2_table(1) := 0;
   END IF;

   l_dummy_table(1) := NULL;

   CLOSE delivery_line;

   IF p_shipped_quantity = 0 THEN

      OPEN lpn_csr(l_delivery_details_id_table(1));
      LOOP
	 FETCH lpn_csr INTO
	   l_parent_delivery_detail_id, l_delivery_assignment_id,
	   l_par_delivery_assignment_id;

	 EXIT WHEN lpn_csr%NOTFOUND;

	 SELECT lpn_id
	   INTO l_lpn_id
	   ---FROM wsh_delivery_details_ob_grp_v wdd
	   FROM wsh_delivery_details wdd
	   WHERE delivery_detail_id = l_parent_delivery_detail_id;

	 --update LPN(s) context to Resides in Inventory
	 FOR l_par_lpn_id IN nested_parent_lpn_cursor(l_lpn_id) LOOP
	    UPDATE wms_license_plate_numbers
	      SET lpn_context = 1,
	      last_update_date = SYSDATE,
	      last_updated_by   = fnd_global.user_id
	      WHERE lpn_id = l_par_lpn_id.lpn_id;
	 END LOOP;

	 --**Check whether Shipping's backorder API does
	 --1.  Unassign the delivery line from container
	 --2.  if container becomes empty, unassign the container from
	 --    delivery
      END LOOP;

      CLOSE lpn_csr;

    ELSE --corresponding if: p_shipped_quantity = 0

	    WSH_DELIVERY_DETAILS_PUB.split_line
	      (p_api_version   => 1.0,
	       p_init_msg_list => fnd_api.g_false,
	       p_commit        => p_commit_flag,
	       x_return_status => l_return_status,
	       x_msg_count     => l_msg_count,
	       x_msg_data      => l_msg_data,
	       p_from_detail_id => l_delivery_details_id_table(1),
	       x_new_detail_id => l_bo_delivery_detail_id,
	       x_split_quantity => l_backorder_quantities_table(1),
	       x_split_quantity2 => l_backorder_quantities2_table(1));

	   IF l_return_status <> fnd_api.g_ret_sts_success THEN
	       RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   l_detail_attributes(1).delivery_detail_id :=
	     l_delivery_details_id_table(1);
	   l_detail_attributes(1).shipped_quantity := p_shipped_quantity;
           l_detail_attributes(1).shipped_quantity2 := p_shipped_quantity2;

	   wsh_delivery_details_pub.update_shipping_attributes
	     (p_api_version_number   => 1.0,
	      p_init_msg_list        => fnd_api.g_false,
	      p_commit               => p_commit_flag,
	      x_return_status        => l_return_status,
	      x_msg_count            => l_msg_count,
	      x_msg_data             => l_msg_data,
	      p_changed_attributes   => l_detail_attributes,
	      p_source_code          => 'OE');

	   IF l_return_status <> fnd_api.g_ret_sts_success THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   l_delivery_details_id_table(1) := l_bo_delivery_detail_id;
   END IF;

   --bug3564157: Shipping's API require the dummy_table to be initialized
   l_dummy_table(1) := 0;
   wsh_ship_confirm_actions2.backorder
     (p_detail_ids => l_delivery_details_id_table,
      p_bo_qtys    => l_backorder_quantities_table,
      p_req_qtys   => l_backorder_quantities_table,
      p_bo_qtys2    => l_backorder_quantities2_table,
      p_overpick_qtys => l_overpicked_quantities_table,
      p_overpick_qtys2 => l_overpicked_quantities2_table,
      p_bo_mode => 'UNRESERVE',
      x_out_rows => l_out_rows,
      x_return_status => l_return_status);


   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF p_commit_flag = fnd_api.g_true THEN
      commit;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'INV_LINE_RETURN_TO_STOCK');
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);

END INV_LINE_RETURN_TO_STOCK;

PROCEDURE INV_REPORT_MISSING_QTY(
				 p_delivery_line_id IN NUMBER,
				 p_missing_quantity IN NUMBER,
				 p_missing_quantity2 IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_data OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER) IS
    l_detail_attributes  WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType;
    l_details      VARCHAR2(2000);
BEGIN
   l_detail_attributes(1).cycle_count_quantity := p_missing_quantity;
   l_detail_attributes(1).cycle_count_quantity2 := p_missing_quantity2;
   l_detail_attributes(1).delivery_detail_id   := p_delivery_line_id;

   wsh_delivery_details_pub.update_shipping_attributes
     (p_api_version_number => 1.0,
      p_init_msg_list      => FND_API.G_TRUE,
      p_commit             => FND_API.G_FALSE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'OE');

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      wsh_util_core.get_messages
	(p_init_msg_list => 'Y',
	 x_summary       => x_msg_data,
	 x_details       => l_details,
	 x_count         => x_msg_count);
   when no_data_found then
      -- do nothing for now
      null;

END INV_REPORT_MISSING_QTY;

PROCEDURE SUBMIT_DELIVERY_LINE(p_delivery_line_id IN NUMBER,
			       p_quantity IN NUMBER,
			       p_quantity2 IN NUMBER,
			       p_trackingNumber IN VARCHAR2,
			       x_return_status OUT NOCOPY VARCHAR2,
			       x_msg_data OUT NOCOPY VARCHAR2,
			       x_msg_count OUT NOCOPY NUMBER ) IS
    l_detail_attributes  WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType;


    l_details      VARCHAR2(2000);

/*
    CURSOR c_weight_vol_info IS
       SELECT unit_weight,
              unit_volume
           ---   nvl(wv_frozen_flag ,'N') wv_frozen_flag
       FROM WSH_DELIVERY_DETAILS_OB_GRP_V
       WHERE delivery_detail_id = p_delivery_line_id;

    l_weight_vol_info c_weight_vol_info%ROWTYPE;

    l_gross_weight NUMBER;

    l_net_weight NUMBER;

    l_total_volume NUMBER;
*/

  BEGIN

   IF p_quantity IS NOT NULL then
      l_detail_attributes(1).shipped_quantity := p_quantity;

      IF p_quantity2 IS NOT NULL then
         l_detail_attributes(1).shipped_quantity2 := p_quantity2;
      END IF;

/** Eddie : Do we need the following ?? wv_frozen_flag is not in WSH_DELIVERY_DETAILS_OB_GRP_V
      OPEN c_weight_vol_info;

      FETCH c_weight_vol_info INTO l_weight_vol_info;

      CLOSE c_weight_vol_info;

      IF (l_weight_vol_info.wv_frozen_flag= 'N' AND
          (l_weight_vol_info.unit_weight IS NOT NULL OR l_weight_vol_info.unit_volume IS NOT NULL))  THEN

        IF l_weight_vol_info.unit_weight IS NOT NULL THEN
         l_detail_attributes(1).gross_weight := p_quantity*l_weight_vol_info.unit_weight;
         l_detail_attributes(1).net_weight   := p_quantity*l_weight_vol_info.unit_weight;
        END IF;

        IF l_weight_vol_info.unit_volume IS NOT NULL  THEN
             l_detail_attributes(1).volume       := p_quantity*l_weight_vol_info.unit_volume;
        END IF;

      END IF;
*/

   END IF;

   IF p_trackingNumber IS NOT NULL THEN
      l_detail_attributes(1).tracking_number := p_trackingNumber;
   END IF;

   l_detail_attributes(1).delivery_detail_id := p_delivery_line_id;

   wsh_delivery_details_pub.update_shipping_attributes
     (p_api_version_number => 1.0,
      p_init_msg_list      => FND_API.G_TRUE,
      p_commit             => FND_API.G_FALSE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_changed_attributes => l_detail_attributes,
      p_source_code        => 'OE');

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      wsh_util_core.get_messages
	(p_init_msg_list => 'Y',
	 x_summary       => x_msg_data,
	 x_details       => l_details,
	 x_count         => x_msg_count);

   when no_data_found then
      -- do nothing for now
      null;

END SUBMIT_DELIVERY_LINE;

FUNCTION GET_SHIPMETHOD_MEANING(p_ship_method_code  IN  VARCHAR2)
     RETURN  VARCHAR2  IS
         l_ship_method_meaning VARCHAR2(80);
     BEGIN
         if p_ship_method_code is null then
             return '';
         else
             select meaning
             into l_ship_method_meaning
             from fnd_lookup_values_vl
             where lookup_type = 'SHIP_METHOD'
               and view_application_id = 3
               and lookup_code = p_ship_method_code;
          end if;
          return l_ship_method_meaning;
     EXCEPTION
         WHEN OTHERS THEN
             return '';
END GET_SHIPMETHOD_MEANING;

PROCEDURE GET_DELIVERY_INFO(x_delivery_info OUT NOCOPY t_genref,
                            p_delivery_id IN NUMBER)  IS

BEGIN
    open x_delivery_info for
     SELECT wnd.name, wnd.delivery_id, nvl(wnd.gross_weight, 0), wnd.weight_uom_code,
            wnd.waybill,' ',
     GET_SHIPMETHOD_MEANING(wnd.ship_method_code)
        FROM wsh_new_deliveries wnd
     WHERE wnd.delivery_id = p_delivery_id;
END GET_DELIVERY_INFO;


PROCEDURE CONFIRM_DELIVERY (
                             p_ship_delivery     IN  VARCHAR2  DEFAULT NULL,
                             p_delivery_id       IN  NUMBER,
                             p_organization_id   IN  NUMBER,
                             p_delivery_name     IN  VARCHAR2,
                             p_carrier_id        IN  NUMBER,
                             p_ship_method_code  IN  VARCHAR2,
                             p_gross_weight      IN  NUMBER,
                             p_gross_weight_uom  IN  VARCHAR2,
                             p_bol               IN  VARCHAR2,
                             p_waybill           IN  VARCHAR2,
                             p_action_flag       IN  VARCHAR2,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_ret_code          OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER) IS

        l_ship_set   VARCHAR2(2000) := NULL;
        l_error_msg  VARCHAR2(2000) := NULL;

        unspec_ship_set_exists  EXCEPTION;
        incomplete_delivery     EXCEPTION;

    BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_ret_code := 0;
        fnd_msg_pub.initialize;

        IF p_ship_delivery = 'YES' THEN
            CHECK_SHIP_SET(
                             p_delivery_id    => p_delivery_id,
                             x_ship_set       => l_ship_set,
                             x_return_Status  => x_return_status,
                             x_error_msg      => l_error_msg);
            IF x_return_status = 'E' THEN
                FND_MESSAGE.SET_NAME('INV', 'WMS_WSH_SHIPSET_FORCED');
                FND_MESSAGE.SET_TOKEN('SHIP_SET_NAME', l_ship_set);
                FND_MSG_PUB.ADD;
                RAISE unspec_ship_set_exists;
            ELSIF x_return_status = 'U' THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            CHECK_COMPLETE_DELVIERY(
                             p_delivery_id    => p_delivery_id,
                             x_return_Status  => x_return_status,
                             x_error_msg      => l_error_msg);
            IF x_return_status = 'E' THEN
                FND_MESSAGE.SET_NAME('INV', 'WMS_INCOMPLETE_DELI');
                FND_MSG_PUB.ADD;
                RAISE incomplete_delivery;
            ELSIF x_return_status = 'U' THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            WMS_SHIPPING_TRANSACTION_PUB.SHIP_CONFIRM_ALL(
                             p_delivery_id       => p_delivery_id,
                             p_organization_id   => p_organization_id,
                             p_delivery_name     => p_delivery_name,
                             p_carrier_id        => p_carrier_id,
                             p_ship_method_code  => p_ship_method_code,
                             p_gross_weight      => p_gross_weight,
                             p_gross_weight_uom  => p_gross_weight_uom,
                             p_bol               => p_bol,
                             p_waybill           => p_waybill,
                             p_action_flag       => p_action_flag,
                             x_return_status     => x_return_status,
                             x_msg_data          => x_msg_data,
                             x_msg_count         => x_msg_count);

        ELSE
            WMS_SHIPPING_TRANSACTION_PUB.SHIP_CONFIRM(
                             p_delivery_id       => p_delivery_id,
                             p_organization_id   => p_organization_id,
                             p_delivery_name     => p_delivery_name,
                             p_carrier_id        => p_carrier_id,
                             p_ship_method_code  => p_ship_method_code,
                             p_gross_weight      => p_gross_weight,
                             p_gross_weight_uom  => p_gross_weight_uom,
                             p_bol               => p_bol,
                             p_waybill           => p_waybill,
                             p_action_flag       => p_action_flag,
                             x_return_status     => x_return_status,
                             x_msg_data          => x_msg_data,
                             x_msg_count         => x_msg_count);
        END IF;

        IF x_return_status not in ('S','W') THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

    EXCEPTION
        WHEN unspec_ship_set_exists THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_ret_code := 1;

            --  Get message count and data
            fnd_msg_pub.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );

        WHEN incomplete_delivery THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_ret_code := 2;

            --  Get message count and data
            fnd_msg_pub.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );

        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;

    END CONFIRM_DELIVERY;


    PROCEDURE UNASSIGN_LINES_AND_CONFIRM (
                            p_delivery_id       IN  NUMBER,
                            p_organization_id   IN  NUMBER,
                            p_delivery_name     IN  VARCHAR2,
                            p_carrier_id        IN  NUMBER,
                            p_ship_method_code  IN  VARCHAR2,
                            p_gross_weight      IN  NUMBER,
                            p_gross_weight_uom  IN  VARCHAR2,
                            p_bol               IN  VARCHAR2,
                            p_waybill           IN  VARCHAR2,
                            p_action_flag       IN  VARCHAR2,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_msg_data          OUT NOCOPY VARCHAR2,
                            x_msg_count         OUT NOCOPY NUMBER) IS
        l_error_msg  VARCHAR2(2000) := NULL;
        unassign_lines_exc   EXCEPTION;
    BEGIN
        fnd_msg_pub.initialize;

        INV_SHIPPING_TRANSACTION_PUB.UNASSIGN_DELIVERY_LINES(
                         p_delivery_id    => p_delivery_id,
                         x_return_Status  => x_return_status,
                         x_error_msg      => l_error_msg);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE unassign_lines_exc;
        END IF;

        WMS_SHIPPING_TRANSACTION_PUB.SHIP_CONFIRM_ALL(
                         p_delivery_id       => p_delivery_id,
                         p_organization_id   => p_organization_id,
                         p_delivery_name     => p_delivery_name,
                         p_carrier_id        => p_carrier_id,
                         p_ship_method_code  => p_ship_method_code,
                         p_gross_weight      => p_gross_weight,
                         p_gross_weight_uom  => p_gross_weight_uom,
                         p_bol               => p_bol,
                         p_waybill           => p_waybill,
                         p_action_flag       => p_action_flag,
                         x_return_status     => x_return_status,
                         x_msg_data          => x_msg_data,
                         x_msg_count         => x_msg_count);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

    EXCEPTION
        WHEN unassign_lines_exc THEN
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            --  Get message count and data
            fnd_msg_pub.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );

    END UNASSIGN_LINES_AND_CONFIRM;


PROCEDURE Get_Ship_Conf_Delivery_Lov(x_deliveryLOV OUT NOCOPY t_genref,
                                     p_delivery_name IN VARCHAR2,
                                     p_organization_id IN NUMBER) IS
BEGIN
   OPEN x_deliveryLOV for
     SELECT distinct wnd.name, wnd.delivery_id, wnd.gross_weight, wnd.weight_uom_code,

     wnd.waybill,
     Get_Shipmethod_Meaning(wnd.ship_method_code)
     FROM wsh_new_deliveries wnd, wsh_delivery_assignments wda,wsh_delivery_details wdd

     WHERE wda.delivery_Detail_id = wdd.delivery_Detail_id
     AND   wda.delivery_id = wnd.delivery_id
     and   ( wdd.released_status = 'Y'  or wdd.released_status = 'X')
/*
             ( wdd.released_status = 'X' and
               exists (select 1
                       from mtl_system_items_b msi
                       where msi.organization_id = wdd.organization_id
                       and msi.inventory_item_id = wdd.inventory_item_id
                       and msi.mtl_transactions_enabled_flag = 'N'))  --


             )
*/
     and   wdd.organization_id = p_organization_id
     and   wnd.name like (p_delivery_name)
     AND status_code not in ('CO', 'CL', 'IT');
END  Get_Ship_Conf_Delivery_Lov;


  PROCEDURE Get_Ship_Items_Lov(x_items OUT NOCOPY t_genref,
                               p_organization_id IN NUMBER,
                               p_delivery_id IN NUMBER,
                               p_concatenated_segments IN VARCHAR2) IS
  l_cross_ref varchar2(204);
  BEGIN


   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length,
'00000000000000');

    OPEN x_items FOR
      SELECT DISTINCT msik.concatenated_segments concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
      FROM mtl_system_items_kfv msik, wsh_delivery_details dd, wsh_delivery_assignments da,
     wsh_new_deliveries nd
      WHERE msik.concatenated_segments LIKE (p_concatenated_segments)
      AND msik.organization_id = p_organization_id
      AND msik.inventory_item_id = dd.inventory_item_id
      AND nd.delivery_id = p_delivery_id
      AND nd.delivery_id = da.delivery_id
      AND da.delivery_detail_id = dd.delivery_detail_id
      AND (dd.inv_interfaced_flag = 'N' OR dd.inv_interfaced_flag IS NULL)
      AND dd.released_status = 'Y'
      AND nd.status_code NOT IN ('CO', 'CL', 'IT')

	--Changes for GTIN
	UNION


	      SELECT DISTINCT msik.concatenated_segments concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
	FROM mtl_system_items_kfv msik,
	wsh_delivery_details dd,
	wsh_delivery_assignments da,
	wsh_new_deliveries nd,
	mtl_cross_references mcr
	WHERE msik.organization_id = p_organization_id
	AND msik.inventory_item_id = dd.inventory_item_id

	AND nd.delivery_id = p_delivery_id
	AND nd.delivery_id = da.delivery_id
	AND da.delivery_detail_id = dd.delivery_detail_id
	AND (dd.inv_interfaced_flag = 'N' OR dd.inv_interfaced_flag IS NULL)
	  AND dd.released_status = 'Y'
	  AND nd.status_code NOT IN ('CO', 'CL', 'IT')
	  AND msik.inventory_item_id   = mcr.inventory_item_id
	  AND mcr.cross_reference_type = g_gtin_cross_ref_type
	  AND mcr.cross_reference      LIKE l_cross_ref
	  AND (mcr.organization_id     = msik.organization_id
	       OR

	       mcr.org_independent_flag = 'Y')
	  ORDER BY concatenated_segments;
  END get_ship_items_lov;

PROCEDURE Get_Ship_Method_LoV(x_shipMethodLOV OUT NOCOPY t_genref,
                              p_organization_id  IN NUMBER,
                              p_ship_method_name IN VARCHAR2) IS
BEGIN
   OPEN x_shipMethodLOV for
     select
     meaning,

     description,
     lookup_code ship_method_code
     from fnd_lookup_values_vl flv
     where lookup_type = 'SHIP_METHOD'
     and view_application_id = 3
     and nvl(start_date_active,sysdate)<=sysdate
     AND nvl(end_date_active,sysdate)>=sysdate
     AND enabled_flag = 'Y'
     AND meaning like ( p_ship_method_name)
     AND lookup_code in (select ship_method_code
                         from wsh_carrier_services wcs, wsh_org_carrier_services wocs,
                         wsh_carriers wc
                         where  wocs.organization_id = p_organization_id
                         AND wcs.ship_method_code = flv.lookup_code
                         AND wcs.enabled_flag = 'Y'
                         AND wocs.enabled_flag = 'Y'
                         AND wcs.carrier_service_id = wocs.carrier_service_id
                         and wcs.carrier_id = wc.carrier_id)
               ---          AND NVL(wc.generic_flag, 'N') = 'N')
     order by meaning;


END Get_Ship_Method_LoV;

END GML_MOBILE_SHIP_CONFIRM;

/
