--------------------------------------------------------
--  DDL for Package Body WMS_SHIPPING_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SHIPPING_INTERFACE_GRP" AS
/* $Header: WMSGINTB.pls 120.4 2007/01/05 22:53:35 satkumar noship $ */

g_pkg_name                  CONSTANT VARCHAR2(30)  := 'WMS_SHIPPING_INTERFACE_GRP';
g_pkg_version               CONSTANT VARCHAR2(100) := '$Header: WMSGINTB.pls 120.4 2007/01/05 22:53:35 satkumar noship $';
g_debug_on                  CONSTANT NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
g_ret_status_success        CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_success;
g_ret_status_error          CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_error;
g_ret_status_unexp_error    CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_unexp_error;

G_WMS_RELEASE_LEVEL         CONSTANT NUMBER := WMS_CONTROL.GET_CURRENT_RELEASE_LEVEL;
G_J_RELEASE_LEVEL           CONSTANT NUMBER := INV_RELEASE.G_J_RELEASE_LEVEL;

g_exc_unexpected_error      EXCEPTION ;



PROCEDURE print_debug(p_message in VARCHAR2) IS
BEGIN
--   dbms_output.put_line(p_message);
   IF g_debug_on = 1 then
      inv_log_util.trace(p_message, g_pkg_name,9);
   END IF;
EXCEPTION
   WHEN OTHERS  THEN
      print_debug('Proc: print_debug .. UNEXPECTED Exception : '|| sqlerrm );
END;


FUNCTION get_lpn_context
          (p_lpn_id                 IN            NUMBER,
           x_outermost_lpn_id       OUT   NOCOPY  NUMBER,
           x_license_plate_number   OUT   NOCOPY  VARCHAR2,
           x_return_status          OUT   NOCOPY  VARCHAR2)
RETURN  NUMBER
IS
l_procname             CONSTANT VARCHAR2(100) := 'get_lpn_context- ';
l_lpn_context          NUMBER := NULL;
l_outermost_lpn_id     NUMBER := NULL;
l_license_plate_number VARCHAR2(30);
BEGIN

   IF g_debug_on = 1 THEN
      print_debug (l_procname || 'p_lpn_id: ' || p_lpn_id  );
   END IF;

   SELECT  lpn_context ,
           outermost_lpn_id,
           license_plate_number
   INTO    l_lpn_context ,
           x_outermost_lpn_id,
           x_license_plate_number
   FROM    wms_license_plate_numbers
   WHERE   lpn_id = p_lpn_id;

   x_return_status := g_ret_status_success;

   IF g_debug_on = 1 THEN
      print_debug (l_procname || 'x_lpn_context:' || l_lpn_context ||': OuterMostLPN:' || x_outermost_lpn_id || ':  LPN:' || x_license_plate_number);
   END IF;
   RETURN l_lpn_context;

EXCEPTION
   WHEN OTHERS  THEN
      x_return_status := g_ret_status_unexp_error ;
      IF g_debug_on = 1 THEN
         print_debug(l_procname || 'Exception OTHERS : '  ||sqlerrm );
      END IF;
      RETURN NULL;

END get_lpn_context;


PROCEDURE proc_action_unassign_delivery
           (p_delivery_detail_tbl  IN OUT  NOCOPY  wms_shipping_interface_grp.g_delivery_detail_tbl,
            x_return_status        OUT     NOCOPY  VARCHAR2)
IS
l_procname             CONSTANT VARCHAR2(100) := 'proc_action_unassign_delivery- ';
l_lpn_context          NUMBER := NULL;
l_outermost_lpn_id     NUMBER := NULL;
l_license_plate_number VARCHAR2(30);
BEGIN
   FOR i IN 1..p_delivery_detail_tbl.COUNT
   LOOP
      l_lpn_context := NULL;
      l_lpn_context := get_lpn_context (p_lpn_id               =>  p_delivery_detail_tbl(i).lpn_id ,
                                        x_outermost_lpn_id     =>  l_outermost_lpn_id,
                                        x_license_plate_number => l_license_plate_number,
                                        x_return_status        =>  x_return_status);
      IF x_return_status <> g_ret_status_success THEN
         p_delivery_detail_tbl(i).return_status := 'E';
         p_delivery_detail_tbl(i).r_message_appl := 'WMS';
         p_delivery_detail_tbl(i).r_message_code := 'WMS_ERROR_LPN_CONTEXT' ;
         p_delivery_detail_tbl(i).r_message_token := l_license_plate_number ;
         p_delivery_detail_tbl(i).r_message_type := 'E';
         p_delivery_detail_tbl(i).r_message_text := '';
         -- Error selecting LPN Context
      ELSE
         IF l_lpn_context =  9  THEN
            p_delivery_detail_tbl(i).return_status   := 'E';
            p_delivery_detail_tbl(i).r_message_appl  := 'WMS';
            p_delivery_detail_tbl(i).r_message_code  := 'WMS_LPN_LOADED_TO_DOCK' ;
            p_delivery_detail_tbl(i).r_message_token := l_license_plate_number ;
            p_delivery_detail_tbl(i).r_message_type  := 'E';
            p_delivery_detail_tbl(i).r_message_text  := '';
            -- Already loaded to Dock.. Cannot unassign delivery;
         ELSIF (l_lpn_context = 11) AND (l_outermost_lpn_id <> p_delivery_detail_tbl(i).lpn_id ) THEN
                  p_delivery_detail_tbl(i).return_status   := 'E';
		  p_delivery_detail_tbl(i).r_message_appl  := 'WMS';
		  p_delivery_detail_tbl(i).r_message_code  := 'WMS_STAGED_LPN_IS_NESTED' ;
		  p_delivery_detail_tbl(i).r_message_token := l_license_plate_number ;
		  p_delivery_detail_tbl(i).r_message_type  := 'E';
                  p_delivery_detail_tbl(i).r_message_text  := '';
         ELSE
            p_delivery_detail_tbl(i).return_status := 'S';
         END IF;
      END IF;
      IF g_debug_on = 1 THEN
         print_debug (l_procname || 'Table Index: ' || i );
         print_debug (l_procname || 'p_lpn_id: ' || p_delivery_detail_tbl(i).lpn_id  );
         print_debug (l_procname || 'return_status:' || p_delivery_detail_tbl(i).return_status);
         print_debug (l_procname || 'return_message_text:' || p_delivery_detail_tbl(i).r_message_text);
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS  THEN
      x_return_status := g_ret_status_unexp_error ;
      IF g_debug_on = 1 THEN
         print_debug(l_procname || 'Exception OTHERS : '  ||sqlerrm );
      END IF;

END proc_action_unassign_delivery;

PROCEDURE Proc_unassign_released_lines
           (p_delivery_detail_tbl  IN OUT  NOCOPY  wms_shipping_interface_grp.g_delivery_detail_tbl,
            x_return_status        OUT     NOCOPY  VARCHAR2)
IS
l_procname             CONSTANT VARCHAR2(100) := 'Proc_unassign_for_released_lines- ';

l_exists NUMBER:=0;
l_cd_exists NUMBER:=0;

BEGIN
   x_return_status := g_ret_status_success;

   IF g_debug_on = 1 THEN print_debug('starting to copy the PL/SQL records to the temp table'); end if;
   delete wms_wsh_wdd_gtemp;

   FOR i IN 1..p_delivery_detail_tbl.COUNT
   LOOP
      if p_delivery_detail_tbl(i).move_order_line_id is null then
         IF g_debug_on = 1 THEN
         	print_debug (l_procname || 'move order line id is not passed from shipping for delivery detail id '
         	||p_delivery_detail_tbl(i).delivery_detail_id);
         END IF;
         RAISE g_exc_unexpected_error;
      END IF;
      insert into wms_wsh_wdd_gtemp
      (delivery_detail_id,move_order_line_id)
       values
       ( p_delivery_detail_tbl(i).delivery_detail_id,p_delivery_detail_tbl(i).move_order_line_id);

   END LOOP;

   -- Adding the following check for Planned Crossdocking project in R12. Maneesh
   IF (g_debug_on =1 ) THEN
      print_debug('Checking to see if there is a crossdock task');
   END IF;

   BEGIN
      SELECT 1
	INTO l_cd_exists
	FROM dual
	WHERE exists (
		      SELECT line_id
		      FROM mtl_txn_request_lines mtrl
		      , mtl_material_transactions_temp mmtt
		      , wms_wsh_wdd_gtemp wwwg
		      , mtl_txn_request_headers mtrh
		      WHERE mmtt.move_order_line_id =
		      wwwg.move_order_line_id
		      AND mtrl.line_id = mmtt.move_order_line_id
		      AND mtrl.header_id = mtrh.header_id
		      AND mtrh.move_order_type = 6
		      AND mtrl.backorder_delivery_detail_id IS NOT NULL
		      AND mtrl.line_status = 7);

	x_return_status := 'E';
   EXCEPTION
      WHEN OTHERS THEN
	 print_debug('No Crossdock Tasks!');
   END;

   IF g_debug_on = 1 THEN
      print_debug('Return Status after Crossdock Check:'||x_return_status);
   END IF;

   IF x_return_status = g_ret_status_success THEN

      IF g_debug_on = 1 THEN
	 print_debug('starting query');
	 print_debug('checking the transfer lpn first');
      END IF;

      BEGIN
	 select 1
	   into l_exists
	   from dual
	   where exists(
			select move_order_line_id
			from mtl_material_transactions_temp mmtt
			where   -- first case, line is loaded into same lpn or has the same carton
			mmtt.transfer_lpn_id is not null and     -- the line is loaded
			mmtt.transfer_lpn_id in -- loaded into a LPN which is included in the inputted lines
			(Select nvl(transfer_lpn_id,cartonization_id)
			 From mtl_material_transactions_temp mmtt1,WMS_WSH_WDD_GTEMP wwwg
			 Where mmtt1.move_order_line_id = wwwg.move_order_line_id
			 and nvl(mmtt1.transfer_lpn_id,mmtt1.cartonization_id) is not null)
			and not exists( select 1
					from WMS_WSH_WDD_GTEMP www
					where www.move_order_line_id = mmtt.move_order_line_id)
			and mmtt.parent_line_id is null  -- excluding the bulk tasks
			and mmtt.move_order_line_id is not null
			);

			IF g_debug_on = 1 THEN
			   print_debug('complete querying on transfer lpn');
			   print_debug (l_procname || 'Packing violations exist on transfer lpn!');
			END IF;

			x_return_status := 'E';
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    IF g_debug_on = 1 THEN
	       print_debug(l_procname || 'No packing violation for transfer lpns');
	       print_debug(l_procname || 'Checking the cartonization id...');
	    END IF;
            BEGIN
	       select 1
		 into l_exists
		 from dual
		 where exists(
			      select move_order_line_id
			      from mtl_material_transactions_temp mmtt
			      where  mmtt.transfer_lpn_id is null
			      and mmtt.cartonization_id in
			      (Select nvl(transfer_lpn_id,cartonization_id)
	                       From mtl_material_transactions_temp mmtt1,WMS_WSH_WDD_GTEMP wwwg
			       Where mmtt1.move_order_line_id = wwwg.move_order_line_id
			       and nvl(mmtt1.transfer_lpn_id,mmtt1.cartonization_id) is not null)
			      and not exists( select 1
					      from WMS_WSH_WDD_GTEMP www
					      where www.move_order_line_id = mmtt.move_order_line_id)
			      and mmtt.parent_line_id is null  -- excluding the bulk tasks
			      and mmtt.move_order_line_id is not null
			      );

			      IF g_debug_on = 1 THEN
				 print_debug('complete querying on cartonization_id');
				 print_debug (l_procname || 'Packing violations exist on cartonization id!');
			      END IF;

			      x_return_status := 'E';
	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		  IF g_debug_on = 1 THEN
		     print_debug(l_procname || 'No packing violation');
		  END IF;
	       WHEN OTHERS  THEN
		  x_return_status := g_ret_status_unexp_error ;
		  IF g_debug_on = 1 THEN
		     print_debug(l_procname || 'Exception OTHERS : '  ||sqlerrm );
		  END IF;
	    END;
	 WHEN OTHERS  THEN
	    x_return_status := g_ret_status_unexp_error ;
	    IF g_debug_on = 1 THEN
	       print_debug(l_procname || 'Exception OTHERS : '  ||sqlerrm );
	    END IF;
      END;
   END IF; --IF x_return_status = g_ret_status_success THEN
END Proc_unassign_released_lines;

PROCEDURE process_delivery_details (
       p_api_version                IN                 NUMBER,
       p_init_msg_list              IN                 VARCHAR2 := wms_shipping_interface_grp.g_false,
       p_commit                     IN                 VARCHAR2 := wms_shipping_interface_grp.g_false,
       p_validation_level           IN                 NUMBER   := wms_shipping_interface_grp.g_full_validation,
       p_action                     IN                 VARCHAR2,
       p_delivery_detail_tbl        IN OUT NOCOPY      wms_shipping_interface_grp.g_delivery_detail_tbl,
       x_return_status              OUT    NOCOPY      VARCHAR2,
       x_msg_count                  OUT    NOCOPY      NUMBER,
       x_msg_data                   OUT    NOCOPY      VARCHAR2)
IS
l_procname             CONSTANT VARCHAR2(100) := 'process_delivery_details- ';
l_api_version          CONSTANT NUMBER := 1.0;
l_progress             VARCHAR2(10) := '0';

l_shipping_attr      WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
l_shipping_in_rec    WSH_INTERFACE_EXT_GRP.detailInRecType;
l_shipping_out_rec   WSH_INTERFACE_EXT_GRP.detailOutRecType;
l_attr_counter       NUMBER := 1;

x_msg_details		     VARCHAR2(3000);
l_pricing_ind        VARCHAR2(30);
l_tolerance          NUMBER;
l_source_type_id     NUMBER;
BEGIN
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_procname,
                                      G_PKG_NAME) THEN
      RAISE g_exc_unexpected_error;
   END IF;


   IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
   END IF;

   x_return_status  := fnd_api.g_ret_sts_success;

   print_debug(l_procname || ' Entered ' || g_pkg_version);
   print_debug('action='||p_action||' deltblcnt='||p_delivery_detail_tbl.COUNT|| ' relvl='||G_WMS_RELEASE_LEVEL);

   IF  p_action = wms_shipping_interface_grp.g_action_unassign_delivery
   THEN
       IF p_delivery_detail_tbl(1).released_Status = 'X' and p_delivery_detail_tbl(1).container_flag = 'Y'  THEN -- for staged LPNs
          IF g_debug_on = 1 THEN
         	print_debug (l_procname || 'calling API to handle the staged LPN.');
          END IF;
          Proc_action_unassign_delivery
           (p_delivery_detail_tbl  =>  p_delivery_detail_tbl,
            x_return_status        =>  x_return_status);
           IF x_return_status <> g_ret_status_success THEN
               RAISE g_exc_unexpected_error;
           END IF;
       ELSIF p_delivery_detail_tbl(1).released_status = 'S' THEN
           IF g_debug_on = 1 THEN
	            	print_debug (l_procname || 'calling API to handle the released lines.');
           END IF;
           Proc_unassign_released_lines
	              (p_delivery_detail_tbl  =>  p_delivery_detail_tbl,
	               x_return_status        =>  x_return_status);
	   IF g_debug_on = 1 THEN
	   	print_debug (l_procname || 'proc_unassign_released_lines returns:'||x_return_status);
           END IF;
	   IF x_return_status <> g_ret_status_success THEN
	       p_delivery_detail_tbl(1).return_status   := 'E';
	       p_delivery_detail_tbl(1).r_message_appl  := 'WMS';
	       p_delivery_detail_tbl(1).r_message_code  := 'WMS_PACKING_VIOLATION';
	       p_delivery_detail_tbl(1).r_message_type  := 'E';
	       p_delivery_detail_tbl(1).r_message_text  := '';

	       fnd_message.set_name('WMS', 'WMS_PACKING_VIOLATION');
	       fnd_msg_pub.add;
           END IF;
       ELSE
           IF g_debug_on = 1 THEN
         	print_debug (l_procname || 'released_status is not correct:'||p_delivery_detail_tbl(1).released_status);
           END IF;
           RAISE g_exc_unexpected_error;
       END IF;
   ELSIF ( p_action = WMS_SHIPPING_INTERFACE_GRP.G_ACTION_VALIDATE_SEC_QTY AND
           G_WMS_RELEASE_LEVEL >= G_J_RELEASE_LEVEL ) THEN
     l_progress := '000';
     FOR i IN 1..p_delivery_detail_tbl.COUNT LOOP
       -- Only check for catch weights if Delivery Detail is for a Sales Order
       IF ( p_delivery_detail_tbl(i).line_direction = 'O' ) THEN
         IF ( p_delivery_detail_tbl(i).picked_quantity2 IS NOT NULL AND
              p_delivery_detail_tbl(i).requested_quantity_uom2 IS NOT NULL ) THEN

           l_tolerance := WMS_CATCH_WEIGHT_PVT.Check_Secondary_Qty_Tolerance (
                            p_api_version        => 1.0
                          , x_return_status      => x_return_status
                          , x_msg_count          => x_msg_count
                          , x_msg_data           => x_msg_data
                          , p_organization_id    => p_delivery_detail_tbl(i).organization_id
                          , p_inventory_item_id  => p_delivery_detail_tbl(i).inventory_item_id
                          , p_quantity           => p_delivery_detail_tbl(i).picked_quantity
                          , p_uom_code           => p_delivery_detail_tbl(i).requested_quantity_uom
                          , p_secondary_quantity => p_delivery_detail_tbl(i).picked_quantity2 );

           IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
	      print_debug('Check_Secondary_Qty_Tolerance failed');

	      fnd_message.set_name('WMS','WMS_CATCH_WT_API_ERR' );
	      fnd_msg_pub.add;
	      raise fnd_api.g_exc_unexpected_error;
           END IF;

           IF ( l_tolerance <> 0 ) THEN
             p_delivery_detail_tbl(i).return_status   := 'E';
             p_delivery_detail_tbl(i).r_message_appl  := 'WMS';
             p_delivery_detail_tbl(i).r_message_code  := 'WMS_CTWT_TOLERANCE_ERROR';
             p_delivery_detail_tbl(i).r_message_type  := 'E';
             p_delivery_detail_tbl(i).r_message_text  := '';
           END IF;
         ELSE -- need to try and defualt secondary quantities.
           l_pricing_ind := NULL;

           WMS_CATCH_WEIGHT_PVT.Get_Default_Secondary_Quantity (
             p_api_version            => 1.0
           , x_return_status          => x_return_status
           , x_msg_count              => x_msg_count
           , x_msg_data               => x_msg_data
           , p_organization_id        => p_delivery_detail_tbl(i).organization_id
           , p_inventory_item_id      => p_delivery_detail_tbl(i).inventory_item_id
           , p_quantity               => p_delivery_detail_tbl(i).picked_quantity
           , p_uom_code               => p_delivery_detail_tbl(i).requested_quantity_uom
           , x_ont_pricing_qty_source => l_pricing_ind
           , x_secondary_uom_code     => p_delivery_detail_tbl(i).requested_quantity_uom2
           , x_secondary_quantity     => p_delivery_detail_tbl(i).picked_quantity2 );

           IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
	      print_debug('Get_Default_Secondary_Quantity failed priceind='||l_pricing_ind||' msg='|| x_msg_data||' cnt='||x_msg_count);

             IF ( l_pricing_ind = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
               p_delivery_detail_tbl(i).return_status  := 'E';
               p_delivery_detail_tbl(i).r_message_appl := 'WMS';
               p_delivery_detail_tbl(i).r_message_type := 'E';
               p_delivery_detail_tbl(i).r_message_text := '';

               IF ( x_msg_count <= 1 ) THEN
                 p_delivery_detail_tbl(i).r_message_code := x_msg_data;
               ELSE
                 p_delivery_detail_tbl(i).r_message_code := fnd_msg_pub.get(1,'F');
               END IF;
               -- do not need to fail batch reset to success
               x_return_status := fnd_api.g_ret_sts_success;
             ELSE -- General failure fail batch
               fnd_message.set_name('WMS','WMS_CATCH_WT_API_ERR');
               fnd_msg_pub.add;
               raise fnd_api.g_exc_unexpected_error;
             END IF;
           ELSIF ( l_pricing_ind = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
             IF ( p_delivery_detail_tbl(i).picked_quantity2 IS NULL OR
                  p_delivery_detail_tbl(i).requested_quantity_uom2 IS NULL ) THEN
               -- Item is catch weight enabled, but could not default
               p_delivery_detail_tbl(i).return_status  := 'E';
               p_delivery_detail_tbl(i).r_message_appl := 'WMS';
               p_delivery_detail_tbl(i).r_message_code := 'WMS_CTWT_DEFAULT_ERROR';
               p_delivery_detail_tbl(i).r_message_type := 'E';
               p_delivery_detail_tbl(i).r_message_text := '';
             ELSE
               -- Got defaults, call shipping api to update picked_quantity2 with weights
               -- If everything checks out, update wdd.picked_quantity2 with catch weight.
               l_shipping_attr(l_attr_counter).delivery_detail_id := p_delivery_detail_tbl(i).delivery_detail_id;
               l_shipping_attr(l_attr_counter).picked_quantity2   := p_delivery_detail_tbl(i).picked_quantity2;
               l_shipping_attr(l_attr_counter).requested_quantity_uom2 := p_delivery_detail_tbl(i).requested_quantity_uom2;
               l_attr_counter := l_attr_counter + 1;
             END IF;
           END IF;
         END IF;
       END IF;
     END LOOP;

     l_progress := '700';
     IF ( l_shipping_attr.COUNT > 0 ) THEN
       l_shipping_in_rec.caller := 'WMS';
       l_shipping_in_rec.action_code := 'UPDATE';

       print_debug('Calling Create_Update_Delivery_Detail deldet count='||l_shipping_attr.COUNT );

       WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail (
         p_api_version_number => 1.0
       , p_init_msg_list      => fnd_api.g_false
       , p_commit             => fnd_api.g_false
       , x_return_status      => x_return_status
       , x_msg_count          => x_msg_count
       , x_msg_data           => x_msg_data
       , p_detail_info_tab    => l_shipping_attr
       , p_IN_rec             => l_shipping_in_rec
       , x_OUT_rec            => l_shipping_out_rec );

       IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
         wsh_util_core.get_messages('Y', x_msg_data, x_msg_details, x_msg_count);

         if x_msg_count > 1 then
           x_msg_data := x_msg_data || x_msg_details;
         else
           x_msg_data := x_msg_data;
         end if;

	 print_debug('Error calling Create_Update_Delivery_Detail');
	 print_debug('Error Msg: ' || x_msg_data);
         FND_MESSAGE.SET_NAME('WMS','WMS_UPD_DELIVERY_ERROR' );
         FND_MESSAGE.SET_TOKEN('MSG1', x_msg_data);
         FND_MSG_PUB.ADD;
         raise fnd_api.g_exc_unexpected_error;
       END IF;
     END IF;
   END IF;

   fnd_msg_pub.count_and_get
        ( p_encoded     => wms_shipping_interface_grp.g_false,
          p_count       => x_msg_count,
          p_data        => x_msg_data
          );

   IF (g_debug_on = 1) THEN
      print_debug ('get message stack, count='||x_msg_count);
   END IF;
   IF x_msg_count = 0 THEN
      x_msg_data := '';
    ELSIF x_msg_count =1 THEN
      null;
    ELSE
      x_msg_data := fnd_msg_pub.get(x_msg_count,wms_shipping_interface_grp.g_false);
   END IF;


EXCEPTION
   WHEN OTHERS THEN
        x_return_status := g_ret_status_unexp_error;
        fnd_message.set_name('WMS', 'ERR_PROC_UNASSIGN_DEL');
        fnd_msg_pub.add;

      fnd_msg_pub.count_and_get
        ( p_encoded     => wms_shipping_interface_grp.g_false,
          p_count       => x_msg_count,
          p_data        => x_msg_data
          );

      IF g_debug_on = 1 THEN
         print_debug(l_procname||' progress= '||l_progress||' Exception OTHERS : '||sqlerrm );
      END IF;

END process_delivery_details;


--This procedure is called by Shipping whenever there is
--trip-delivery assignment or unassignment. Places where this procedure can be invoked:
--1. Shipping's ship confirm API
--2. Direct Ship (Right before calling Shipping's ship confirm API)
--3. Desktop
--This procedure should only return error in case 3.
PROCEDURE process_delivery_trip
  (p_api_version       IN            NUMBER
   ,p_init_msg_list    IN            VARCHAR2 := wms_shipping_interface_grp.g_false
   ,p_commit           IN            VARCHAR2 := wms_shipping_interface_grp.g_false
   ,p_validation_level IN            NUMBER   := wms_shipping_interface_grp.g_full_validation
   ,p_action           IN            VARCHAR2
   ,p_dlvy_trip_tbl    IN OUT nocopy wms_shipping_interface_grp.g_dlvy_trip_tbl
   ,x_return_status    OUT    nocopy VARCHAR2
   ,x_msg_count        OUT    nocopy NUMBER
   ,x_msg_data         OUT    nocopy VARCHAR2) IS

      l_api_version CONSTANT NUMBER := 1.0;
      l_procname    CONSTANT VARCHAR2(100) := 'process_delivery_trip - ';
      l_trip_id     NUMBER;
BEGIN
   x_return_status := g_ret_status_success;
   x_msg_count := 0;
   x_msg_data := '';

   --Trip-delivery association happening in case 2 mentioned above
   --Thus, do nothing
   IF wms_globals.g_ship_confirm_method = 'DIRECT' THEN
      RETURN;
   END IF;

   IF NOT fnd_api.compatible_api_call(l_api_version
				      ,p_api_version
				      ,l_procname
				      ,g_pkg_name) THEN
      IF g_debug_on = 1 THEN
         print_debug (l_procname || 'Incompatible API call' );
      END IF;
      RAISE g_exc_unexpected_error;
   END IF;

   IF p_action NOT IN (wms_shipping_interface_grp.g_action_assign_dlvy_trip,
                       wms_shipping_interface_grp.g_action_unassign_dlvy_trip) THEN
      IF g_debug_on = 1 THEN
	 print_debug(l_procname || 'Invalid action passed in');
      END IF;
      RAISE g_exc_unexpected_error;
   END IF;

   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF g_debug_on = 1 THEN
      print_debug(l_procname || 'start to process_delivery_trip');
      print_debug(l_procname || 'Num records passed in: ' || p_dlvy_trip_tbl.COUNT);
   END IF;

   --no org_id because delivery_id is the primary key
   FOR i IN 1..p_dlvy_trip_tbl.COUNT LOOP
      IF g_debug_on = 1 THEN
	 print_debug(l_procname || 'At record: ' || i);
	 print_debug(l_procname || 'delivery id: '|| p_dlvy_trip_tbl(i).delivery_id);
	 print_debug(l_procname || 'trip id: ' || p_dlvy_trip_tbl(i).trip_id);
      END IF;

      IF p_dlvy_trip_tbl(i).delivery_id IS NOT NULL
	AND p_dlvy_trip_tbl(i).trip_id IS NOT NULL THEN

      BEGIN

	 --Shipping ship confirm API calls our
	 --WMS_SHIPPING_PUB.DEL_WSTT_RECS_BY_DELIVERY_ID before reaching this API.
	 --Therefore, entries will have been deleted from the temp table, and this
	 --procedure will not fail.
         -- MRANA : 4576909: The above is not true anymore.. we are now going to
         -- update WSTT with the new Trip id or null depending on the action code.
	 SELECT DISTINCT trip_id
	   INTO l_trip_id
	   FROM wms_shipping_transaction_temp
	   WHERE delivery_id = p_dlvy_trip_tbl(i).delivery_id;

         IF g_debug_on = 1 THEN
	    print_debug(l_procname || ': wstt.l_trip_id:  '|| l_trip_id);
         END IF;
	 --get to here means the delivery is loaded to dock
	 IF p_action = wms_shipping_interface_grp.g_action_assign_dlvy_trip THEN
	    IF l_trip_id = p_dlvy_trip_tbl(i).trip_id THEN
                IF g_debug_on = 1 THEN
	           print_debug(l_procname || ': wstt.l_trip_id:  is same as the trip passed in ');
                END IF;
	       --assigning to same trip again
	       p_dlvy_trip_tbl(i).return_status := 'S';
	     ELSE
	      /* NCR Bug : 4576909 :  Instead of returning error, update WSTT
 *             p_dlvy_trip_tbl(i).return_status := 'E';
	       p_dlvy_trip_tbl(i).r_message_appl := 'WMS';
	       p_dlvy_trip_tbl(i).r_message_code := 'WMS_DLVY_LOADED_TO_DOCK';
	       p_dlvy_trip_tbl(i).r_message_token := p_dlvy_trip_tbl(i).delivery_id;
	       p_dlvy_trip_tbl(i).r_message_token_name := 'DELIVERY_ID';
	       p_dlvy_trip_tbl(i).r_message_type := 'E';

	       FND_MESSAGE.SET_NAME('WMS','WMS_DLVY_LOADED_TO_DOCK' );
	       FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_dlvy_trip_tbl(i).delivery_id);

	       p_dlvy_trip_tbl(i).r_message_text := fnd_message.get; */

               BEGIN
                  UPDATE wms_shipping_transaction_temp
                  SET    trip_id =  p_dlvy_trip_tbl(i).trip_id
                  WHERE  delivery_id = p_dlvy_trip_tbl(i).delivery_id;
                  IF g_debug_on = 1 THEN
	             print_debug(l_procname || ': wstt.l_trip_id:  updated ' );
                  END IF;
	       p_dlvy_trip_tbl(i).return_status := 'S';
               EXCEPTION
                  WHEN OTHERS THEN
                     x_return_status := g_ret_status_unexp_error;
                     IF g_debug_on = 1 THEN
	                print_debug(l_procname || ': wstt could not be updated: '  || SQLCODE ||':' || SQLERRM);
                     END IF;
               END ;
	    END IF;
	  ELSIF p_action = wms_shipping_interface_grp.g_action_unassign_dlvy_trip THEN
	    --need a different error message?
	    /* NCR Bug : 4576909 :  Instead of returning error, update WSTT
	    p_dlvy_trip_tbl(i).return_status := 'E';
	    p_dlvy_trip_tbl(i).r_message_appl := 'WMS';
	    p_dlvy_trip_tbl(i).r_message_code := 'WMS_DLVY_LOADED_TO_DOCK';
	    p_dlvy_trip_tbl(i).r_message_token := p_dlvy_trip_tbl(i).delivery_id;
	    p_dlvy_trip_tbl(i).r_message_token_name := 'DELIVERY_ID';
	    p_dlvy_trip_tbl(i).r_message_type := 'E';

	    FND_MESSAGE.SET_NAME('WMS','WMS_DLVY_LOADED_TO_DOCK' );
	    FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_dlvy_trip_tbl(i).delivery_id);

	    p_dlvy_trip_tbl(i).r_message_text := fnd_message.get; */

            BEGIN
                  UPDATE wms_shipping_transaction_temp
                  SET    trip_id =  NULL
                  WHERE  delivery_id = p_dlvy_trip_tbl(i).delivery_id;
                  IF g_debug_on = 1 THEN
	             print_debug(l_procname || ': wstt.l_trip_id:  updated ' );
                  END IF;
	     p_dlvy_trip_tbl(i).return_status := 'S';
             EXCEPTION
                  WHEN OTHERS THEN
                  x_return_status := g_ret_status_unexp_error;
                     IF g_debug_on = 1 THEN
	                print_debug(l_procname || ': wstt could not be updated: '  || SQLCODE ||':' || SQLERRM);
                     END IF;
            END ;

	 END IF;
      EXCEPTION
	 WHEN no_data_found THEN
	    p_dlvy_trip_tbl(i).return_status := 'S';
	 WHEN OTHERS THEN
	    p_dlvy_trip_tbl(i).return_status := 'U';
	    IF g_debug_on = 1 THEN
	       print_debug(l_procname || SQLERRM);
	    END IF;
      END;
       ELSE
	    p_dlvy_trip_tbl(i).return_status := 'U';
	    IF g_debug_on = 1 THEN
	       print_debug(l_procname || 'Either delivery id or trip id is not passed in');
	    END IF;
      END IF;
   END LOOP;


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := g_ret_status_unexp_error;
END process_delivery_trip;

PROCEDURE process_serial_number
  (p_api_version         IN NUMBER
   ,p_init_msg_list      IN VARCHAR2 := wms_shipping_interface_grp.g_false
   ,p_commit             IN VARCHAR2 := wms_shipping_interface_grp.g_false
   ,p_validation_level   IN NUMBER := wms_shipping_interface_grp.g_full_validation
   ,p_action             IN VARCHAR2
   ,p_serial_number_tbl  IN OUT nocopy wms_shipping_interface_grp.g_serial_number_tbl
   ,x_return_status      OUT nocopy VARCHAR2
   ,x_msg_count          OUT nocopy NUMBER
   ,x_msg_data           OUT nocopy VARCHAR2) IS

      TYPE inventory_item_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE organization_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE serial_number_tbl IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
      TYPE lpn_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

      l_inventory_item_id_tbl inventory_item_id_tbl;
      l_serial_number_tbl     serial_number_tbl;
      l_lpn_id_tbl            lpn_id_tbl;
      l_current_org_id_tbl    organization_id_tbl;
      l_user_id               NUMBER := fnd_global.user_id;
BEGIN
   print_debug('PROCESS_SERIAL_NUMBER: Entered');
   x_return_status := g_ret_status_success;
   x_msg_count := 0;
   x_msg_data := '';

   IF p_action = wms_shipping_interface_grp.g_action_update THEN
      IF NOT fnd_api.compatible_api_call(1.0
					 ,p_api_version
					 ,'PROCESS_SERIAL_NUMBER'
					 ,g_pkg_name) THEN
	 print_debug('PROCESS_SERIAL_NUMBER: Incompatible API call');
	 RAISE g_exc_unexpected_error;
      END IF;

      IF p_init_msg_list = 'T' THEN
	 fnd_msg_pub.initialize;
      END IF;

      print_debug('PROCESS_SERIAL_NUMBER: Start processing serial numbers');

      print_debug('PROCESS_SERIAL_NUMBER: Start populating local tables');
      FOR i IN p_serial_number_tbl.first..p_serial_number_tbl.last LOOP
	 l_inventory_item_id_tbl(i) := p_serial_number_tbl(i).inventory_item_id;
	 l_serial_number_tbl(i) := p_serial_number_tbl(i).serial_number;
	 l_lpn_id_tbl(i) := p_serial_number_tbl(i).lpn_id;
	 l_current_org_id_tbl(i) := p_serial_number_tbl(i).current_organization_id;

	 print_debug('PROCESS_SERIAL_NUMBER: index: ' || i);
	 print_debug('PROCESS_SERIAL_NUMBER: inventory_item_id: ' || l_inventory_item_id_tbl(i));
	 print_debug('PROCESS_SERIAL_NUMBER: serial_number: ' || l_serial_number_tbl(i));
	 print_debug('PROCESS_SERIAL_NUMBER: lpn_id: ' || l_lpn_id_tbl(i));
	 print_debug('PROCESS_SERIAL_NUMBER: current_org_id: ' || l_current_org_id_tbl(i));
      END LOOP;
      print_debug('PROCESS_SERIAL_NUMBER: Finished populating local tables.  Count: ' || l_lpn_id_tbl.COUNT);

      print_debug('PROCESS_SERIAL_NUMBER: Update MSN table');
      forall i IN l_lpn_id_tbl.first..l_lpn_id_tbl.last
	UPDATE mtl_serial_numbers
	SET lpn_id = l_lpn_id_tbl(i)
	,last_update_date = Sysdate
	,last_updated_by = l_user_id
	WHERE inventory_item_id = l_inventory_item_id_tbl(i)
	AND serial_number = l_serial_number_tbl(i)
	AND current_organization_id = l_current_org_id_tbl(i);

      print_debug('PROCESS_SERIAL_NUMBER: Finished updating');
      print_debug('PROCES_SERIAL_NUMBER: Total rows updated: ' || SQL%ROWCOUNT);
      IF g_debug_on = 1 THEN
	 FOR i IN l_lpn_id_tbl.first..l_lpn_id_tbl.last LOOP
	    print_debug('PROCESS_SERIAL_NUMBER: Row ' || i || ' updated ' || SQL%bulk_rowcount(i) || ' rows.');
	 END LOOP;
      END IF;
    ELSE
      print_debug('PROCESS_SERIAL_NUMBER: Invalid action passed in');
      RAISE g_exc_unexpected_error;
   END IF;

   IF p_commit = 'T' THEN
      COMMIT;
      print_debug('PROCESS_SERIAL_NUMBER: Committed change');
   END IF;
   print_debug('PROCESS_SERIAL_NUMBER: Ended');
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := g_ret_status_unexp_error;
      print_debug('PROCESS_SERIAL_NUMBER: Exception raised!');
END process_serial_number;


/* Added the following API, which will be called by WSH
with p_action as 'INCLUDE_DELIVERY_FOR_PLANNING', when
the delivery is not assigned to any trip, to validate whether
any LPN associated with this delivery is already loaded to dock door
*/
PROCEDURE process_deliveries
	 (p_api_version       IN            NUMBER
	  ,p_init_msg_list    IN            VARCHAR2 := Wms_Shipping_Interface_Grp.g_false
	  ,p_commit           IN            VARCHAR2 := Wms_Shipping_Interface_Grp.g_false
	  ,p_validation_level IN            NUMBER   := Wms_Shipping_Interface_Grp.g_full_validation
	  ,p_action           IN            VARCHAR2
	  ,x_dlvy_trip_tbl    IN OUT nocopy Wms_Shipping_Interface_Grp.g_dlvy_trip_tbl
	  ,x_return_status    OUT    nocopy VARCHAR2
	  ,x_msg_count        OUT    nocopy NUMBER
	  ,x_msg_data         OUT    nocopy VARCHAR2) IS

	  l_delivery_status	NUMBER(1);

BEGIN
        x_return_status := 'S';
        print_debug('In ....PROCESS_DELIVERIES ' );
        print_debug('p_api_version: ' || p_api_version );
        print_debug('p_init_msg_list: ' || p_init_msg_list );
        print_debug('p_commit: ' || p_commit );
        print_debug('p_validation_level: ' || p_validation_level );
        print_debug('p_action: ' || p_action );
        print_debug('x_dlvy_trip_tbl: ' || x_dlvy_trip_tbl.COUNT );

	x_msg_count := 0;
	x_msg_data := '';
	IF p_action = Wms_Shipping_Interface_Grp.g_action_plan_delivery THEN
		FOR i IN x_dlvy_trip_tbl.first..x_dlvy_trip_tbl.last LOOP
			l_delivery_status := 0;
                        print_debug('x_dlvy_trip_tbl(i).delivery_id :  ' || x_dlvy_trip_tbl(i).delivery_id);

			BEGIN
				SELECT 1
				INTO l_delivery_status
				FROM dual
				WHERE EXISTS (  SELECT lpn_context
					FROM wms_license_plate_numbers wlpn
					, wms_shipping_transaction_temp wstt
					WHERE wlpn.lpn_id = wstt.outermost_lpn_id
					AND wstt.delivery_id = x_dlvy_trip_tbl(i).delivery_id
					AND wlpn.lpn_context = 9 );

				IF l_delivery_status = 1 THEN
					x_dlvy_trip_tbl(i).return_status := 'E';
					x_dlvy_trip_tbl(i).r_message_appl := 'WMS';
					x_dlvy_trip_tbl(i).r_message_code := 'WMS_DELIVERY_LOADED_TO_DOCK';
					x_dlvy_trip_tbl(i).r_message_token := x_dlvy_trip_tbl(i).delivery_id;
					x_dlvy_trip_tbl(i).r_message_token_name := 'DELIVERY_ID';
					x_dlvy_trip_tbl(i).r_message_type := 'E';
                                        print_debug('r_message_code : WMS_DELIVERY_LOADED_TO_DOCK');
				END IF;
                                print_debug('l_delivery_status :' || l_delivery_status);

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					x_dlvy_trip_tbl(i).return_status := 'S';
					x_dlvy_trip_tbl(i).r_message_appl := 'WMS';
					x_dlvy_trip_tbl(i).r_message_code := '';
					x_dlvy_trip_tbl(i).r_message_token := x_dlvy_trip_tbl(i).delivery_id;
					x_dlvy_trip_tbl(i).r_message_token_name := 'DELIVERY_ID';
					x_dlvy_trip_tbl(i).r_message_type := 'S';
                                print_debug('NO_DATA_FOUND :' || x_dlvy_trip_tbl(i).delivery_id);
			END;

			IF g_debug_on = 1 THEN
				print_debug('WMS_SHIPPING_INTERFACE_GRP.PROCESS_DELIVERIES : ' || ' Record No : ' || i );
				print_debug('WMS_SHIPPING_INTERFACE_GRP.PROCESS_DELIVERIES : ' || ' Delivery ID : ' || x_dlvy_trip_tbl(i).delivery_id );
				print_debug('WMS_SHIPPING_INTERFACE_GRP.PROCESS_DELIVERIES : ' || ' r_message_code : ' || x_dlvy_trip_tbl(i).r_message_code );
			END IF;

		END LOOP;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'E';
		x_msg_count := 1;
		x_msg_data := 'Unexpected exception in PROCESS_DELIVERIES';

END process_deliveries;

END wms_shipping_interface_grp;

/
