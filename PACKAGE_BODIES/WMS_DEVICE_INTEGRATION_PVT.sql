--------------------------------------------------------
--  DDL for Package Body WMS_DEVICE_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DEVICE_INTEGRATION_PVT" AS
/* $Header: WMSDEVPB.pls 120.7.12010000.6 2010/01/07 14:17:37 pbonthu ship $ */


-----------------------------------------------------
--   Global declarations
-----------------------------------------------------
SUBTYPE WDR_ROW IS WMS_DEVICE_REQUESTS%ROWTYPE;
SUBTYPE WDRH_ROW IS WMS_DEVICE_REQUESTS_HIST%ROWTYPE;


-----------------------------------------------------
-- trace
-----------------------------------------------------
PROCEDURE trace(p_msg IN VARCHAR2, p_level IN NUMBER) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_trx_util_pub.trace(p_msg, 'WMS_DEVICE_INTEGRATION_PVT', p_level);
   END IF;
   --dbms_output.put_line(p_msg);
END trace;

-----------------------------------------------------
--   retrieve_Ship_Confirm_Details
--
------------------------------------------------------
PROCEDURE retrieve_ship_confirm_Details ( p_task_trx_id    IN NUMBER,
					  p_bus_event  IN   NUMBER,
					  x_request_id OUT NOCOPY NUMBER,
					  x_return_status OUT NOCOPY VARCHAR2) is

l_request_id NUMBER;
l_org_id NUMBER;
l_item_id NUMBER;
l_subinv VARCHAR2(30);
l_locator_id NUMBER;
l_lpn_id NUMBER;
l_qty NUMBER;
l_uom VARCHAR2(3);
l_rev VARCHAR2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SELECT wms_device_requests_s.nextval INTO l_request_id FROM dual;
   x_request_id := l_request_id;

   SELECT wdd1.organization_id,
     wdd1.subinventory,
     wdd1.locator_id,
     wdd1.inventory_item_id,
     wdd1.revision,
     wdd1.requested_quantity_uom,
     wdd2.lpn_id,
     wdd1.shipped_quantity
     INTO
     l_org_id,
     l_subinv,
     l_locator_id,
     l_item_id,
     l_rev,
     l_uom,
     l_lpn_id,
     l_qty
     FROM wsh_delivery_details wdd1, wsh_delivery_assignments_v wda,
     wsh_delivery_details wdd2
     WHERE wdd1.DELIVERY_DETAIL_ID = p_task_trx_id
   AND wdd1.delivery_detail_id = wda.parent_delivery_detail_id
     AND wda.parent_delivery_detail_id = wdd2.delivery_detail_id;

   insert INTO wms_device_requests (request_id,
				    task_id,
				    task_summary,
				    business_event_id,
				    organization_id,
				    subinventory_code,
				    locator_id,
				    inventory_item_id,
				    revision,
				    uom,
				    lpn_id,
				    transaction_quantity,
				    last_update_date,
				    last_updated_by) VALUES
     (l_request_id,
      p_task_trx_id,
      'Y',
      p_bus_event,
      l_org_id,
      l_subinv,
      l_locator_id,
      l_item_id,
      l_rev,
      l_uom,
      l_lpn_id,
      l_qty,
      Sysdate,
      FND_GLOBAL.USER_ID);

   x_return_status := 'S';

EXCEPTION
   WHEN no_data_found THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Error retrieve in ship confirm details, no data found');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   WHEN others THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Other error in retrieve ship confirm details');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;


END;




-----------------------------------------------------
--   retrieve_Bus_Event_Details
--	create device request record with MMTT record
------------------------------------------------------
PROCEDURE retrieve_Bus_Event_Details ( p_task_trx_id    IN NUMBER,
				       p_bus_event  IN   NUMBER,
				       x_request_id  OUT NOCOPY NUMBER,
				       x_return_status OUT NOCOPY VARCHAR2) is

l_request_id NUMBER;
l_org_id NUMBER;
l_item_id NUMBER;
l_subinv VARCHAR2(30);
l_locator_id NUMBER;
l_lpn_id NUMBER;
l_xfr_org_id NUMBER;
l_xfr_subinv VARCHAR2(30);
l_xfr_locator_id NUMBER;
l_qty NUMBER;
l_uom VARCHAR2(3);
l_rev VARCHAR2(10);

l_temp_sub VARCHAR2(30);
l_temp_loc NUMBER;
l_xfr_lpn_id NUMBER; --Added for Bug#8512121

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SELECT wms_device_requests_s.nextval INTO l_request_id FROM dual;
   x_request_id := l_request_id;

   SELECT organization_id,
     subinventory_code,
     locator_id,
     transfer_organization,
     transfer_subinventory,
     transfer_to_location,
     inventory_item_id,
     revision,
     transaction_uom,
     Nvl(lpn_id,allocated_lpn_id) lpn_id,
     transaction_quantity,
     TRANSFER_LPN_ID --Added for Bug#8512121
   INTO
     l_org_id,
     l_subinv,
     l_locator_id,
     l_xfr_org_id,
     l_xfr_subinv,
     l_xfr_locator_id,
     l_item_id,
     l_rev,
     l_uom,
     l_lpn_id,
     l_qty,
     l_xfr_lpn_id --Added for Bug#8512121
     FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_task_trx_id;

      IF p_bus_event in (WMS_BE_PUTAWAY_DROP, WMS_BE_PICK_DROP) THEN
      	IF (l_debug = 1) THEN
         	trace(' for putaway drop or pick drop, swap the sub/loc and transfer sub/loc');
      	END IF;
      	l_subinv := l_xfr_subinv;
      	l_xfr_subinv := null;

      	l_locator_id := l_xfr_locator_id;
      	l_xfr_locator_id := null;

	--made all these details null for multiple lines in LPN for putaway
	--or drop
	l_item_id :=NULL;
	l_rev := NULL;
	l_uom := NULL;
	l_qty := NULL;

      END IF;

      IF (l_debug = 1) THEN
         trace(' sub,loc,xfr_sub,xfr_loc:'||l_subinv||','||l_locator_id||','||l_xfr_subinv||','||l_xfr_locator_id);
	 trace('l_xfr_lpn_id:'||l_xfr_lpn_id);
         trace('l_lpn_id:'||l_lpn_id);
      END IF;

      insert INTO wms_device_requests (request_id,
				       task_id,
				       task_summary,
				       business_event_id,
				       organization_id,
				       subinventory_code,
				       locator_id,
				       transfer_org_id,
				       transfer_sub_code,
				       transfer_loc_id,
				       inventory_item_id,
				       revision,
				       uom,
				       lpn_id,
				       xfer_lpn_id, --Added for Bug#8512121
				       transaction_quantity,
				       last_update_date,
				       last_updated_by) VALUES
	(l_request_id,
	 p_task_trx_id,
	 'Y',
	 p_bus_event,
	 l_org_id,
	 l_subinv,
	 l_locator_id,
	 l_xfr_org_id,
	 l_xfr_subinv,
	 l_xfr_locator_id,
	 l_item_id,
	 l_rev,
	 l_uom,
	 l_lpn_id,
	 l_xfr_lpn_id, --Added for Bug#8512121
	 l_qty,
	 Sysdate,
	 FND_GLOBAL.USER_ID);


   x_return_status := 'S';

EXCEPTION
   WHEN no_data_found THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Error retrieve in business event details, no data found');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   WHEN others THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Other error in retrieve business event details');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;


END;

-----------------------------------------------------
--   retrieve_Bus_Event_Details
--     create device request record with the input parameters
------------------------------------------------------
PROCEDURE retrieve_Bus_Event_Details(
				     p_bus_event             IN   NUMBER,
				     p_task_trx_id	     IN   NUMBER,
				     p_org_id                IN   NUMBER,
				     p_item_id               IN   NUMBER := NULL,
				     p_subinv                IN   VARCHAR2 := NULL,
				     p_locator_id            IN   NUMBER := NULL,
				     p_lpn_id                IN   NUMBER := NULL,
				     p_xfer_lpn_id           IN   NUMBER := NULL,  --Added for Bug#8778050
				     p_xfr_org_id            IN   NUMBER := NULL,
				     p_xfr_subinv            IN   VARCHAR2 := NULL,
				     p_xfr_locator_id        IN   NUMBER := NULL,
				     p_qty                   IN   NUMBER :=NULL ,
				     p_uom                   IN VARCHAR2  := NULL,
				     p_rev                   IN VARCHAR2 := NULL,
				     x_request_id           OUT   NOCOPY NUMBER ,
				     x_return_status OUT NOCOPY VARCHAR2) IS

l_request_id NUMBER;
l_org_id NUMBER;
l_item_id NUMBER;
l_subinv VARCHAR2(30);
l_locator_id NUMBER;
l_lpn_id NUMBER;
l_xfr_org_id NUMBER;
l_xfr_subinv VARCHAR2(30);
l_xfr_locator_id NUMBER;
l_qty NUMBER;
l_uom VARCHAR2(3);
l_rev VARCHAR2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SELECT wms_device_requests_s.nextval INTO l_request_id FROM dual;
   x_request_id := l_request_id;

     --Added for Bug#8778050 start

     IF (l_debug = 1) THEN
         	trace(' p_xfer_lpn_id'|| p_xfer_lpn_id);
		trace(' p_lpn_id'|| p_lpn_id);
		trace(' p_bus_event'|| p_bus_event);
     END IF;

     --Added for Bug#8778050 end

      IF (p_bus_event=WMS_BE_PICK_DROP) OR
         ((p_bus_event=WMS_BE_PUTAWAY_DROP) AND (p_xfr_subinv IS NOT NULL)) THEN

      	IF (l_debug = 1) THEN
         	trace(' for putaway drop or pick drop, swap the sub/loc and transfer sub/loc');
      	END IF;
      	l_subinv := p_xfr_subinv;
      	l_locator_id := p_xfr_locator_id;
      	l_xfr_subinv := p_subinv;
      	l_xfr_locator_id := p_locator_id;
      ELSE
      	l_subinv := p_subinv;
      	l_locator_id := p_locator_id;
      	l_xfr_subinv := p_xfr_subinv;
      	l_xfr_locator_id := p_xfr_locator_id;

      END IF;
      IF (l_debug = 1) THEN
         trace(' sub,loc,xfr_sub,xfr_loc:'||l_subinv||','||l_locator_id||','||l_xfr_subinv||','||l_xfr_locator_id);
      END IF;

      insert INTO wms_device_requests (request_id,
				       task_id,
				       task_summary,
				       business_event_id,
				       organization_id,
				       subinventory_code,
				       locator_id,
				       transfer_org_id,
				       transfer_sub_code,
				       transfer_loc_id,
				       inventory_item_id,
				       revision,
				       uom,
				       lpn_id,
				       xfer_lpn_id,  --Added for Bug#8778050
				       transaction_quantity,
				       last_update_date,
				       last_updated_by) VALUES
	(l_request_id,
	 Nvl(p_task_trx_id,-9999),
	 'Y',
	 p_bus_event,
	 p_org_id,
	 l_subinv,
	 l_locator_id,
	 p_xfr_org_id,
	 l_xfr_subinv,
	 l_xfr_locator_id,
	 p_item_id,
	 p_rev,
	 p_uom,
	 p_lpn_id,
	 p_xfer_lpn_id, --Added for Bug#8778050
	 p_qty,
	 Sysdate,
	 FND_GLOBAL.USER_ID);

      x_return_status := 'S';

EXCEPTION
   WHEN no_data_found THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Error in retrieve business event details, no data found');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   WHEN others THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Other error in retrieve business event details');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;

END;

-----------------------------------------------------
--   Overloaded for WMS-OPM
--
------------------------------------------------------
PROCEDURE retrieve_Bus_Event_Details(
				     p_bus_event             IN   NUMBER,
				     p_task_trx_id	             IN   NUMBER,
				     p_org_id                IN   NUMBER,
				     p_item_id               IN   NUMBER := NULL,
				     p_subinv                IN   VARCHAR2 := NULL,
				     p_locator_id            IN   NUMBER := NULL,
				     p_lpn_id                IN   NUMBER := NULL,
				     p_xfr_org_id            IN   NUMBER := NULL,
				     p_xfr_subinv            IN   VARCHAR2 := NULL,
				     p_xfr_locator_id        IN   NUMBER := NULL,
				     p_qty                   IN   NUMBER :=NULL ,
				     p_uom                   IN VARCHAR2  := NULL,
				     p_rev                   IN VARCHAR2 := NULL,
                 p_device_id             IN   NUMBER,
				     x_request_id           OUT   NOCOPY NUMBER ,
				     x_return_status OUT NOCOPY VARCHAR2) IS

l_request_id NUMBER;
l_org_id NUMBER;
l_item_id NUMBER;
l_subinv VARCHAR2(30);
l_locator_id NUMBER;
l_lpn_id NUMBER;
l_xfr_org_id NUMBER;
l_xfr_subinv VARCHAR2(30);
l_xfr_locator_id NUMBER;
l_qty NUMBER;
l_uom VARCHAR2(3);
l_rev VARCHAR2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SELECT wms_device_requests_s.nextval INTO l_request_id FROM dual;
   x_request_id := l_request_id;

      IF (p_bus_event=WMS_BE_PICK_DROP) OR
         ((p_bus_event=WMS_BE_PUTAWAY_DROP) AND (p_xfr_subinv IS NOT NULL)) THEN

      	IF (l_debug = 1) THEN
         	trace(' for putaway drop or pick drop, swap the sub/loc and transfer sub/loc');
      	END IF;
      	l_subinv := p_xfr_subinv;
      	l_locator_id := p_xfr_locator_id;
      	l_xfr_subinv := p_subinv;
      	l_xfr_locator_id := p_locator_id;
      ELSE
      	l_subinv := p_subinv;
      	l_locator_id := p_locator_id;
      	l_xfr_subinv := p_xfr_subinv;
      	l_xfr_locator_id := p_xfr_locator_id;

      END IF;
      IF (l_debug = 1) THEN
         trace('Overloaded retrieve_Bus_Event_Details: sub,loc,xfr_sub,xfr_loc,dev_id:'||l_subinv||','||l_locator_id||','||l_xfr_subinv||','||l_xfr_locator_id||','||p_device_id);
      END IF;

      insert INTO wms_device_requests (request_id,
				       task_id,
				       task_summary,
				       business_event_id,
				       organization_id,
				       subinventory_code,
				       locator_id,
				       transfer_org_id,
				       transfer_sub_code,
				       transfer_loc_id,
				       inventory_item_id,
				       revision,
				       uom,
				       lpn_id,
                   device_id,
				       transaction_quantity,
				       last_update_date,
				       last_updated_by) VALUES
	(l_request_id,
	 Nvl(p_task_trx_id,-9999),
	 'Y',
	 p_bus_event,
	 p_org_id,
	 l_subinv,
	 l_locator_id,
	 p_xfr_org_id,
	 l_xfr_subinv,
	 l_xfr_locator_id,
	 p_item_id,
	 p_rev,
	 p_uom,
	 p_lpn_id,
    p_device_id,
	 p_qty,
	 Sysdate,
	 FND_GLOBAL.USER_ID);

      x_return_status := 'S';

EXCEPTION
   WHEN no_data_found THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Error in retrieve business event details, no data found');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   WHEN others THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Other error in retrieve business event details');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;

END;

-------------------------------------------------------
--   retrieve_Lot_Serial_Details
--
-------------------------------------------------------
PROCEDURE retrieve_Lot_Serial_Details(wdrrec wdr_row,
				      x_return_status OUT NOCOPY VARCHAR2 ) IS

   CURSOR lot_ser_cursor IS
      SELECT
	mtlt.lot_number lot_num,
	mtlt.transaction_quantity lot_qty,
	msnt.fm_serial_number ser_num
	FROM mtl_material_transactions_temp mmtt,
	mtl_transaction_lots_temp mtlt,
	mtl_serial_numbers_temp msnt
	WHERE
	mmtt.transaction_temp_id = wdrrec.task_id
	AND mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
	AND mmtt.transaction_temp_id = msnt.transaction_temp_id(+)
	AND ((mmtt.transaction_temp_id=msnt.transaction_temp_id
	      AND mtlt.serial_transaction_temp_id=msnt.transaction_temp_id)
	     OR  1=1);

   l_qty NUMBER;
   l_count NUMBER :=0 ;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   FOR l_rec IN lot_ser_cursor LOOP
      IF (l_rec.lot_num IS NOT NULL OR l_rec.ser_num IS NOT NULL) THEN
	 IF (l_rec.ser_num IS NOT NULL) THEN
	    l_qty := 1;
	  ELSE
	    l_qty := wdrrec.transaction_quantity;
	 END IF;
	 l_count := l_count + 1;
	 INSERT INTO wms_device_requests  (request_id,
					   task_id,
					   relation_id,
					   sequence_id,
					   task_summary,
					   task_type_id,
					   business_event_id,
					   organization_id,
					   subinventory_code,
					   locator_id,
					   transfer_org_id,
					   transfer_sub_code,
					   transfer_loc_id,
					   inventory_item_id,
					   revision,
					   uom,
					   lot_number,
					   lot_qty,
					   serial_number,
					   lpn_id,
					   transaction_quantity,
					   device_id,
					   status_code,
					   last_update_date,
					   last_updated_by,
					   last_update_login) VALUES
	   (wdrrec.request_id,
	    wdrrec.task_id,
	    wdrrec.relation_id,
	    wdrrec.sequence_id,
	    'N',
	    wdrrec.task_type_id,
	    wdrrec.business_event_id,
	    wdrrec.organization_id,
	    wdrrec.subinventory_code,
	    wdrrec.locator_id,
	    wdrrec.transfer_org_id,
	    wdrrec.transfer_sub_code,
	    wdrrec.transfer_loc_id,
	    wdrrec.inventory_item_id,
	    wdrrec.revision,
	    wdrrec.uom,
	    l_rec.lot_num,
	    l_rec.lot_qty,
	    l_rec.ser_num,
	    wdrrec.lpn_id,
	    l_qty,
	    wdrrec.device_id,
	    wdrrec.status_code,
	    wdrrec.last_update_date,
	    wdrrec.last_updated_by,
	    wdrrec.last_update_login);
      END IF;
   END LOOP;

   IF(l_count = 0) THEN
     IF (l_debug = 1) THEN
        trace('Error in retrieve lot serial details, no data found');
     END IF;
   END IF;

   x_return_status := 'S';

EXCEPTION

   WHEN others THEN
      x_return_status := 'E';
      IF (l_debug = 1) THEN
         trace('Other error in retrieve lot serial details');
	 trace('SQL error :'||substr(sqlerrm, 1, 240));
      END IF;



END;

---------------------------------------------------------
--   select_Device
--
---------------------------------------------------------
FUNCTION select_Device(wdrrec WMS_DEVICE_REQUESTS%ROWTYPE,
		       p_autoenable VARCHAR2,
		       p_parent_request_id NUMBER
		       ) return NUMBER is

   dev_id number := 0;
   par_task_id number := null;
   l_lot_ser_ok VARCHAR2(1);
   l_notification_flag VARCHAR2(1);
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_force_sign_on_flag Varchar2(1) :='N';
   l_dev_id NUMBER :=0;
    l_current_release_level NUMBER	:=  WMS_CONTROL.g_current_release_level;
     l_j_release_level   NUMBER		:=  INV_RELEASE.g_j_release_level;

   BEGIN
      IF (l_debug = 1) THEN
	 trace('in select device, org, sub, user, autoenable, bus, parent req:');
	 trace(wdrrec.organization_id ||','||wdrrec.subinventory_code||','||FND_GLOBAL.USER_ID||',' || p_autoenable || ',' || wdrrec.business_event_id || ',' || p_parent_request_id);
      END IF;
   -- Try to get the device id from history if the
   -- event id is task complete and the parent request id is not null
   IF wdrrec.business_event_id in (wms_be_task_complete, wms_be_task_skip, wms_be_task_cancel) AND
     p_parent_request_id IS NOT NULL THEN
      IF (l_debug = 1) THEN
	 trace('Finding device id from history for task completion');
      END IF;
      dev_id := 0;
      BEGIN
	 SELECT device_id, task_id
	   INTO dev_id, par_task_id
	   FROM wms_device_requests_hist
	   WHERE request_id = p_parent_request_id
	   AND ROWNUM < 2;
      EXCEPTION
	 WHEN OTHERS THEN
	    dev_id := NULL;
	    IF (l_debug = 1) THEN
	       trace('SQL error :'||substr(sqlerrm, 1, 240));
	     END IF;
      END;
      IF (l_debug = 1) THEN
	 trace('Found device id:'||dev_id);
      END IF;

    ELSIF  ( wdrrec.business_event_id = wms_be_mo_task_alloc
      AND  wdrrec.business_event_id = wms_be_putaway_drop) THEN

	    --look AT the destination sub for device for replenishment task
	    IF (l_debug = 1) THEN
	       trace('SelectDev:find device at destination for putaway OR  repl-allocation');
	    END IF;

            begin
	       seLECT DEVICE_ID INTO dev_ID FROM
		 ( SELECT wbed.DEVICE_ID  FROM
		   wms_bus_event_devices wbed,
		   wms_devices_b wd
		   WHERE
		   wd.device_id = wbed.device_id
		   AND WBED.organization_id = WD.organization_id
		   and wd.ENABLED_FLAG = 'Y'
		   and wbed.ENABLED_FLAG = 'Y'
		   AND decode(level_type,DEVICE_LEVEL_SUB,wbed.subinventory_code,level_value) =
		   decode(level_type,DEVICE_LEVEL_SUB,wdrrec.transfer_sub_code,DEVICE_LEVEL_ORG,
			  wdrrec.organization_id,DEVICE_LEVEL_LOCATOR,wdrrec.transfer_loc_id,
			  DEVICE_LEVEL_USER,FND_GLOBAL.USER_ID,level_value)
		   AND Nvl(wbed.organization_id,-1) = Nvl(wdrrec.organization_id,Nvl(wbed.organization_id,-1))
		   AND wbed.AUTO_ENABLED_FLAG = decode(p_autoenable,'Y','Y',wbed.AUTO_ENABLED_FLAG)
		   AND wbed.business_event_id = wdrrec.business_event_id
		   ORDER BY level_type desc)
		 where ROWNUM<2;

	       -- J Development
	       IF l_current_release_level >= l_j_release_level THEN
		  IF (dev_id <> 0 ) THEN
			BEGIN
			   SELECT force_sign_on_flag
			     INTO l_force_sign_on_flag
			     FROM   wms_devices_b
			     WHERE  device_id =  dev_id;
			   IF(l_force_sign_on_flag='Y') THEN
				BEGIN
				   SELECT  device_id
				     INTO    l_dev_id
				     FROM    wms_device_assignment_temp
				     WHERE   device_id = dev_id
				     AND CREATED_BY = FND_GLOBAL.USER_ID;
				EXCEPTION
				   WHEN NO_DATA_FOUND THEN
				      dev_id :=0;
				END;

			   END IF;

			EXCEPTION
			   WHEN OTHERS THEN
			      dev_id :=0;
			END;
		 END IF;
	       END IF;

	       IF (l_debug = 1) THEN
		  trace('Found device at destination device id:'||dev_id);
	       END IF;

	    exception
	       when NO_DATA_FOUND THEN
		  IF (l_debug = 1) THEN
		     trace('SelectDev:No device found at destination FOR putaway OR repl-allocation');
		  END IF;

	    END;


    ELSE --Other business events

	   BEGIN
	      SELECT DEVICE_ID INTO dev_ID FROM
		( SELECT wbed.DEVICE_ID  FROM
		  wms_bus_event_devices wbed,
		  wms_devices_b wd
		  WHERE
		  wd.device_id = wbed.device_id
		  AND WBED.organization_id = WD.organization_id
		  and wd.ENABLED_FLAG = 'Y'
		  and wbed.ENABLED_FLAG = 'Y'
		  AND decode(level_type,DEVICE_LEVEL_SUB,wbed.subinventory_code,level_value) =
		  decode(level_type,DEVICE_LEVEL_SUB,wdrrec.subinventory_code,DEVICE_LEVEL_ORG,
			 wdrrec.organization_id,DEVICE_LEVEL_LOCATOR,wdrrec.locator_id,
			 DEVICE_LEVEL_USER,FND_GLOBAL.USER_ID,level_value)
		  AND Nvl(wbed.organization_id,-1) = Nvl(wdrrec.organization_id,Nvl(wbed.organization_id,-1))
		  AND wbed.AUTO_ENABLED_FLAG = decode(p_autoenable,'Y','Y',wbed.AUTO_ENABLED_FLAG)
		  AND wbed.business_event_id = wdrrec.business_event_id
		  ORDER BY level_type desc)
		where ROWNUM<2;

	      -- J Development
	      IF l_current_release_level >= l_j_release_level THEN
		 IF (dev_id <> 0 ) THEN
			BEGIN
			   SELECT force_sign_on_flag
			     INTO l_force_sign_on_flag
			     FROM   wms_devices_b
			     WHERE  device_id =  dev_id;
			   IF(l_force_sign_on_flag='Y') THEN
				BEGIN
				   SELECT  device_id
				     INTO    l_dev_id
				     FROM    wms_device_assignment_temp
				     WHERE   device_id = dev_id
				     AND CREATED_BY = FND_GLOBAL.USER_ID;
				EXCEPTION
				   WHEN NO_DATA_FOUND THEN
				      dev_id :=0;
				END;

			   END IF;

			EXCEPTION
			   WHEN OTHERS THEN
			      dev_id :=0;
			END;
		 END IF;
	      END IF;

	      IF (l_debug = 1) THEN
		 trace('Found device id:'||dev_id);
	      END IF;

	   EXCEPTION
	      when NO_DATA_FOUND THEN
		 IF (l_debug = 1) THEN
		    trace('SelectDev:No device found at any level for source');

		 END IF;
	   END;

   END IF;

   IF (dev_id <> 0)THEN
      -- For business event Task Complete, check whether the device is enabled
      --  for task complete notification.

       /*Bug#6344286. Removed events wms_be_task_skip and wms_be_task_cancel from below IF
        because notification_flag is relevant only for the task_complete even */
      IF wdrrec.business_event_id in (wms_be_task_complete) THEN
      	BEGIN
      	  select nvl(notification_flag, 'N')
      	  into l_notification_flag
      	  from wms_devices_b
      	  where device_id = dev_id;
        EXCEPTION
      	  WHEN no_data_found THEN
	     IF (l_debug = 1) THEN
		trace('No device found for ID:'||dev_id);
	    END IF;
      	    l_notification_flag := 'N';
        END;
       ELSE
	     --SET the notification flag to Y for all other bus event for processing
	     l_notification_flag := 'Y';
      END IF;

      IF l_notification_flag = 'Y' THEN
        UPDATE wms_device_requests
	SET device_id = dev_id,
	task_id = nvl(par_task_id, task_id)
	WHERE request_id = wdrrec.request_id
	AND Nvl(task_type_id,0) = Nvl(wdrrec.task_type_id,Nvl(task_type_id,0))
	AND organization_id = wdrrec.organization_id
	AND business_event_id = wdrrec.business_event_id
	  AND Nvl(task_id,0) = Nvl(wdrrec.task_id,Nvl(task_id,0)); -- BUG4616997

	--set the global var if device is lot/ser capable. to be called
	--FROM cartonization FOR pick release AND REPLENISHMENT TASK
	--allocation bus event
	IF  wdrrec.business_event_id IN (wms_be_pick_release, wms_be_mo_task_alloc) then	    BEGIN
	      select Nvl(lot_serial_capable,'N')
		into l_lot_ser_ok
		from WMS_DEVICES_B
		where device_id = dev_id;
	   EXCEPTION
	      WHEN no_data_found THEN
		 l_lot_ser_ok := 'N';
	   END;

	   -- If Details enabled for device, retrieve the Lot/Serialdetails
	   IF (l_lot_ser_ok = 'Y') THEN
	      --set the global variable to be used in cartonization
	      --code to insert lot/ser records into wdr table
	      wms_insert_lotSer_rec_WDR := 1;
	   END IF;

	END IF;
      END IF;
    ELSIF wdrrec.business_event_id NOT IN (wms_be_task_complete,
					   wms_be_task_skip,
					   wms_be_task_cancel) then
	 IF (l_debug = 1) THEN
	    trace('No device found: Updating WDT for Task_id::'||wdrrec.task_id);
	 END IF;
	 UPDATE wms_dispatched_tasks
	   SET DEVICE_REQUEST_ID = NULL
	   WHERE TRANSACTION_TEMP_ID = wdrrec.task_id;
   END IF;

   IF (l_debug = 1) THEN
      trace('SelectDev: Deviceid='||dev_id||',parent_task='||par_task_id);
   END IF;

      return dev_id;
END;


---------------------------------------------------------
-- Write XML/CSV to File
---------------------------------------------------------
PROCEDURE WriteToFile(p_xml IN CLOB, p_file_dir IN VARCHAR2, p_file_name IN VARCHAR2) IS
	l_xmlstr varchar2(32767);
	l_line varchar2(2000);
	l_file UTL_FILE.FILE_TYPE;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	l_file := utl_file.fopen(rtrim(p_file_dir,'/'), p_file_name, 'w');
	l_xmlstr := dbms_lob.substr(p_xml, 32767);
	loop
		exit when l_xmlstr is null;
		l_line := substr(l_xmlstr, 1, instr(l_xmlstr, fnd_global.local_chr(10))-1);
		utl_file.put_line(l_file, l_line);
		l_xmlstr := substr(l_xmlstr, instr(l_xmlstr, fnd_global.local_chr(10))+1);
	end loop;
	utl_file.fclose(l_file);
EXCEPTION
	WHEN utl_file.invalid_path THEN
		IF (l_debug = 1) THEN
   		trace('Invalid path in WriteToFile: '||p_file_dir);
		END IF;
	WHEN utl_file.invalid_mode THEN
		IF (l_debug = 1) THEN
   		trace('Invalid mode in WriteToFile: w');
		END IF;
	WHEN fnd_api.g_exc_error THEN
      	IF (l_debug = 1) THEN
         	trace(' Expected Error in WriteXmlFile');
      	END IF;
	WHEN fnd_api.g_exc_unexpected_error THEN
      	IF (l_debug = 1) THEN
         	trace(' Unexpected Error in WriteXmlFile');
      	END IF;
    WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   trace('Error in WriteXmlFile');
		   trace('SQL error :'||substr(sqlerrm, 1, 240));
		END IF;
END WriteToFile;


---------------------------------------------------------
--   Generate XML/CSV
--
---------------------------------------------------------
FUNCTION generate_xml_csv(p_device_id NUMBER, p_iotype NUMBER) return NUMBER is
	retval number := 0;

	CURSOR xml_cur(p_dev_id NUMBER, p_task_sum VARCHAR2) IS
	SELECT wd.name DEVICE, wdr.request_id REQUESTID, ml1.meaning TASKTYPE,
	 ml2.meaning BUSINESSEVENT,
	  wdr.task_id TASKID, wdr.sequence_id SEQUENCEID,
	wdr.relation_id RELATIONID,
	mp1.organization_code ORG, wdr.subinventory_code SUB,
	milk1.concatenated_segments LOC, mp2.organization_code TRANSFERORG,
	wdr.transfer_sub_code TRANSFERSUB, milk2.concatenated_segments TRANSFERLOC,
	wlpn.license_plate_number LPN, wdr.xfer_lpn_id XFERLPNID, msik.concatenated_segments ITEM, --Added for Bug#8512121
	wdr.revision REVISION, wdr.transaction_quantity QUANTITY,
	  wdr.uom UOM, wdr.lot_number LOT, wdr.lot_qty LOTQTY,
	  wdr.serial_number serial,
	  wdr.status_msg STATUSMSG, wdr.last_update_date timestamp,
	   wdr.business_event_id bus_event_id
	FROM wms_device_requests wdr, mfg_lookups ml1, mfg_lookups ml2,
	wms_devices_vl wd, mtl_parameters mp1, mtl_item_locations_kfv milk1,
	mtl_parameters mp2, mtl_item_locations_kfv milk2, wms_license_plate_numbers wlpn,
	mtl_system_items_kfv msik
	WHERE ml1.lookup_type(+)= 'WMS_TASK_TYPES' AND ml1.lookup_code(+) = wdr.task_type_id
	  AND ml2.lookup_type(+)='WMS_BUS_EVENT_TYPES'
	  AND ml2.lookup_code(+) = wdr.business_event_id
	  AND wd.device_id = wdr.device_id AND mp1.organization_id = wdr.organization_id
	AND milk1.organization_id(+) = wdr.organization_id
	AND milk1.subinventory_code(+) = wdr.subinventory_code
	AND milk1.inventory_location_id(+) = wdr.locator_id
	AND mp2.organization_id (+) = wdr.transfer_org_id
	AND milk2.organization_id(+) = wdr.transfer_org_id
	AND milk2.subinventory_code(+) = wdr.transfer_sub_code
	AND milk2.inventory_location_id (+) = wdr.transfer_loc_id
	AND wlpn.lpn_id(+) = wdr.lpn_id
	AND msik.organization_id(+)= wdr.organization_id
	AND msik.inventory_item_id(+) = wdr.inventory_item_id
	AND wdr.device_id = p_dev_id
	AND nvl(wdr.task_summary,'Y') = p_task_sum
	ORDER BY wdr.task_id asc, wdr.sequence_id asc,wdr.task_type_id asc;

	l_seperator VARCHAR2(1) := ',';

	CURSOR csv_cur(p_dev_id NUMBER, p_task_sum VARCHAR2) IS
	SELECT 	wd.name ||l_seperator|| wdr.request_id ||l_seperator|| ml1.meaning ||l_seperator||
		 	ml2.meaning ||l_seperator|| wdr.task_id ||l_seperator|| wdr.sequence_id ||l_seperator
		 	||wdr.relation_id||l_seperator ||
			mp1.organization_code ||l_seperator|| wdr.subinventory_code ||l_seperator||
			milk1.concatenated_segments ||l_seperator|| mp2.organization_code ||l_seperator||
			wdr.transfer_sub_code ||l_seperator|| milk2.concatenated_segments ||l_seperator||
			wlpn.license_plate_number ||l_seperator|| wlpn1.license_plate_number ||l_seperator|| msik.concatenated_segments ||l_seperator|| --Added for Bug#8512121
			wdr.revision ||l_seperator|| wdr.transaction_quantity ||l_seperator||
	                wdr.uom ||l_seperator|| wdr.lot_number ||l_seperator||
	                wdr.lot_qty||l_seperator||
	                wdr.serial_number||l_seperator||wdr.status_msg||l_seperator||wdr.last_update_date
			CSV_LINE
			FROM wms_device_requests wdr, mfg_lookups ml1, mfg_lookups ml2,
			wms_devices_vl wd, mtl_parameters mp1, mtl_item_locations_kfv milk1,
			mtl_parameters mp2, mtl_item_locations_kfv milk2, wms_license_plate_numbers wlpn,wms_license_plate_numbers wlpn1,  --Added for Bug#8512121
			mtl_system_items_kfv msik
			WHERE ml1.lookup_type(+) = 'WMS_TASK_TYPES' AND ml1.lookup_code(+) = wdr.task_type_id
	                AND ml2.lookup_type(+)='WMS_BUS_EVENT_TYPES'
	                AND ml2.lookup_code(+) = wdr.business_event_id
			AND wd.device_id = wdr.device_id AND mp1.organization_id = wdr.organization_id
			AND milk1.organization_id(+) = wdr.organization_id
			AND milk1.subinventory_code(+) = wdr.subinventory_code
			AND milk1.inventory_location_id(+) = wdr.locator_id
			AND mp2.organization_id (+) = wdr.transfer_org_id
			AND milk2.organization_id(+) = wdr.transfer_org_id
			AND milk2.subinventory_code(+) = wdr.transfer_sub_code
			AND milk2.inventory_location_id (+) = wdr.transfer_loc_id
			AND wlpn.lpn_id(+) = wdr.lpn_id
			AND wlpn1.lpn_id(+)= wdr.xfer_lpn_id     --Added for Bug#8512121
			AND msik.organization_id(+) = wdr.organization_id
			AND msik.inventory_item_id(+) = wdr.inventory_item_id
			AND wdr.device_id = p_dev_id
			AND nvl(wdr.task_summary,'Y') = p_task_sum
			ORDER BY wdr.task_id asc, wdr.sequence_id asc, wdr.task_type_id asc;

	l_lot_serial_enabled VARCHAR2(1);
	l_detail_available NUMBER;
	l_task_sum VARCHAR2(1);
	l_dev_name VARCHAR2(30);
	l_file_dir VARCHAR2(50);
	l_file_prefix VARCHAR2(50);
	l_seq_id NUMBER;
	l_file_name VARCHAR2(50);

	l_file UTL_FILE.FILE_TYPE;

	l_csv_column_list VARCHAR2(200) :=
		'DEVICE,REQUESTID,TASKTYPE,BUSINESSEVENT,TASKID,SEQUENCEID,RELATIONID,ORG,SUB,'||'LOC,TRANSFERORG,TRANSFERSUB,TRANSFERLOC,LPN,XFERLPN,ITEM,REVISION,QUANTITY,UOM,LOT,LOTQTY,SERIAL,ERRORCODE,TIMESTAMP';  --Added for Bug#8512121

	l_order_num NUMBER;
	l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	IF (l_debug = 1) THEN
   	trace('In generate xml/csv, device_id = ' || p_device_id);
   	trace('Getting output dir, file name, lot/serial enabled, device name');
	END IF;
	BEGIN
		SELECT rtrim(out_directory,'/'), out_file_prefix, nvl(LOT_SERIAL_CAPABLE, 'N'), name
		INTO l_file_dir, l_file_prefix, l_lot_serial_enabled, l_dev_name
		FROM wms_devices
		WHERE device_id = p_device_id;

		SELECT request_id INTO l_seq_id
		FROM wms_device_requests
		WHERE device_id = p_device_id
		AND ROWNUM<2;

	EXCEPTION
		WHEN no_data_found THEN
			IF (l_debug = 1) THEN
   			trace('Error in getting device property, no data found');
			END IF;
			RAISE fnd_api.g_exc_unexpected_error;
		WHEN others THEN
			IF (l_debug = 1) THEN
			   trace('Other error in getting device property');
			   trace('SQL error :'||substr(sqlerrm, 1, 240));
			END IF;
	END;
	l_file_name := l_file_prefix || l_seq_id||'_'||p_device_id;

	IF (l_debug = 1) THEN
   	trace('Device supports lot/serial ? ' || l_lot_serial_enabled);
	END IF;
	IF l_lot_serial_enabled = 'Y' THEN
		-- When the device supports lot/serial,
		-- lot/serial information still may not be available
		-- check if detail information is not avaible, query summary record.
		BEGIN
         -- Bug 2762697: Lot information is not populated for device request
         -- The problem is that if there is more than one detail record
         -- The select into will fail
         -- Change to just check existence
         SELECT 1 INTO l_detail_available FROM dual
         WHERE exists(
           SELECT 1
           FROM wms_device_requests
           WHERE device_id = p_device_id
           AND nvl(task_summary,'Y') = 'N');

	 IF (l_debug = 1) THEN
	    trace('Lot/Serial detail info available');
	 END IF;
	 l_task_sum := 'N';
		EXCEPTION
		   WHEN no_data_found THEN
		      IF (l_debug = 1) THEN
			 trace('Lot/Serial detail info not available, use summary info');
		      END IF;
		      l_task_sum := 'Y';
		   WHEN others THEN
		      IF (l_debug = 1) THEN
				   trace('Error in checking detail info, use summary info');
				   trace('SQL error :'||substr(sqlerrm, 1, 240));
		      END IF;
		      l_task_sum := 'Y';
		END;
	 ELSE
		      l_task_sum := 'Y';
	END IF;

	IF (l_debug = 1) THEN
   	trace('After checking device and detail info, l_task_sum=' || l_task_sum);
	END IF;

	IF p_iotype = WMS_DEV_IO_XML THEN

	   -- XML
	   l_file_name := l_file_name || '.xml';
	   IF (l_debug = 1) THEN
	      trace('Result will be saved in '||l_file_dir||'/'||l_file_name);
	   END IF;

	   --OPEN FILE
	   l_file := UTL_FILE.FOPEN(l_file_dir, l_file_name, 'w');
	   UTL_FILE.PUT_LINE(l_file, XML_HEADER);
	   UTL_FILE.PUT_LINE(l_file, DEVICEH_TB || ' name="' || l_dev_name ||'"'
			     || ' request_id="' || l_seq_id || '"'|| TAG_E);
	   IF (l_debug = 1) THEN
	      trace('Opening xml cursor with dev_id='||p_device_id||',task_sum='||l_task_sum);
	   END IF;

	   FOR v_xml IN xml_cur(p_device_id, l_task_sum) LOOP

	      IF v_xml.bus_event_id = wms_be_pick_release THEN
		 begin
		    select To_number(wdd.source_header_number) into l_order_num from
		      wsh_delivery_details wdd,
		      mtl_material_transactions_temp mmtt
		      where mmtt.transaction_temp_id = v_xml.taskid
		      and mmtt.trx_source_line_id = wdd.source_line_id;
		 EXCEPTION
		    WHEN others THEN
		       IF (l_debug = 1) THEN
			  trace('Could not retrieve the SO Number');
		       END IF;
		 END;

	       ELSIF v_xml.bus_event_id = wms_be_mo_task_alloc THEN
		  BEGIN
		     select mtrl.header_id into l_order_num
		       from mtl_txn_request_lines mtrl,
		       mtl_material_transactions_temp mmtt
		       where mmtt.move_order_line_id = mtrl.line_id
		       and transaction_temp_id = v_xml.taskid;
		  EXCEPTION
		     WHEN others THEN
			IF (l_debug = 1) THEN
			   trace('Could not retrieve the Move Order Header');
			END IF;
		  END;
	      END IF;

	      IF (l_debug = 1) THEN
		 trace('Done setting header information');
	      END IF;



	      UTL_FILE.PUT_LINE(l_file, TASK_TB);
	      UTL_FILE.PUT_LINE(l_file, DEVICE_TB|| v_xml.DEVICE ||DEVICE_TE);
	      UTL_FILE.PUT_LINE(l_file, REQUESTID_TB|| v_xml.REQUESTID||REQUESTID_TE);
	      UTL_FILE.PUT_LINE(l_file, TASKTYPE_TB|| v_xml.TASKTYPE||TASKTYPE_TE);
	      UTL_FILE.PUT_LINE(l_file, BUSINESSEVENT_TB||v_xml.BUSINESSEVENT ||BUSINESSEVENT_TE);
	      UTL_FILE.PUT_LINE(l_file, TASKID_TB|| v_xml.TASKID||TASKID_TE);
	      UTL_FILE.PUT_LINE(l_file, SEQUENCEID_TB|| v_xml.SEQUENCEID||SEQUENCEID_TE);
	      UTL_FILE.PUT_LINE(l_file, RELATIONID_TB|| v_xml.RELATIONID||RELATIONID_TE);
	      UTL_FILE.PUT_LINE(l_file, ORG_TB|| v_xml.ORG||ORG_TE);
	      UTL_FILE.PUT_LINE(l_file, SUB_TB|| v_xml.SUB||SUB_TE);
	      UTL_FILE.PUT_LINE(l_file, LOC_TB||v_xml.LOC ||LOC_TE);
	      UTL_FILE.PUT_LINE(l_file, TRANSFERORG_TB|| v_xml.TRANSFERORG||TRANSFERORG_TE);
	      UTL_FILE.PUT_LINE(l_file, TRANSFERSUB_TB|| v_xml.TRANSFERSUB||TRANSFERSUB_TE);
	      UTL_FILE.PUT_LINE(l_file, TRANSFERLOC_TB|| v_xml.TRANSFERLOC||TRANSFERLOC_TE);
	      UTL_FILE.PUT_LINE(l_file, LPN_TB||v_xml.LPN ||LPN_TE);
	      UTL_FILE.PUT_LINE(l_file, XFERLPN_TB||v_xml.XFERLPNID ||XFERLPN_TE);  --Added for Bug#8512121
	      UTL_FILE.PUT_LINE(l_file, ITEM_TB||v_xml.ITEM ||ITEM_TE);
	      UTL_FILE.PUT_LINE(l_file, REVISION_TB|| v_xml.REVISION||REVISION_TE);
	      UTL_FILE.PUT_LINE(l_file, QUANTITY_TB|| v_xml.QUANTITY||QUANTITY_TE);
	      UTL_FILE.PUT_LINE(l_file, UOM_TB|| v_xml.UOM||UOM_TE);
	      UTL_FILE.PUT_LINE(l_file, LOT_TB|| v_xml.LOT||LOT_TE);
	      UTL_FILE.PUT_LINE(l_file, LOTQTY_TB|| v_xml.LOTQTY||LOTQTY_TE);
	      UTL_FILE.PUT_LINE(l_file, SERIAL_TB|| v_xml.SERIAL||SERIAL_TE);
	      UTL_FILE.PUT_LINE(l_file, SO_TB|| l_order_num||SO_TE);
	      UTL_FILE.PUT_LINE(l_file, ERRORCODE_TB|| v_xml.STATUSMSG||ERRORCODE_TE);
	      UTL_FILE.PUT_LINE(l_file, TIMESTAMP_TB|| v_xml.TIMESTAMP||TIMESTAMP_TE);
	      UTL_FILE.PUT_LINE(l_file, TASK_TE);
	   END LOOP;
	   UTL_FILE.PUT_LINE(l_file, DEVICE_TE);
	   UTL_FILE.fclose(l_file);
	   IF (l_debug = 1) THEN
	      trace(' File created ');
	   END IF;

	 ELSIF p_iotype = WMS_DEV_IO_CSV THEN
	     -- CSV
             l_file_name := l_file_name || '.csv';
	     IF (l_debug = 1) THEN
		trace('Result will be saved in '||l_file_dir||' '||l_file_name);
	     END IF;
	     l_seperator := ',';

	     -- OPEN FILE
	     l_file := UTL_FILE.FOPEN(l_file_dir, l_file_name, 'w');
	     UTL_FILE.PUT_LINE(l_file, l_csv_column_list);
	     IF (l_debug = 1) THEN
   		trace('Opening csv cursor with dev_id='||p_device_id||',task_sum='||l_task_sum);
	     END IF;
	     FOR v_csv IN csv_cur(p_device_id, l_task_sum) LOOP
		UTL_FILE.PUT_LINE(l_file, v_csv.csv_line);
	     END LOOP;

	     UTL_FILE.fclose(l_file);
	     IF (l_debug = 1) THEN
   		trace(' File created ');
	     END IF;
	 ELSE
             IF (l_debug = 1) THEN
		trace('Invalid iotype value passed to generate_xml_csv:'||p_iotype);
	     END IF;
	     RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	-- update outfile_name
	IF (l_debug = 1) THEN
   	trace('update outfile_name ' || l_file_name || p_device_id || l_task_sum);
	END IF;
	UPDATE wms_device_requests
	SET outfile_name = l_file_name
	WHERE device_id = p_device_id
	AND nvl(task_summary, 'Y') = decode(l_lot_serial_enabled,'N','Y','Y',nvl(task_summary,'Y'),'Y');

	return retval;
EXCEPTION
	WHEN utl_file.invalid_path THEN
		IF (l_debug = 1) THEN
   		trace('Invalid Path error in generate_xml_csv');
		END IF;
		FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_SETUP_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_REASON', 'Invalid Path');
		FND_MSG_PUB.ADD;
		retval := -1;
		return retval;
	WHEN utl_file.invalid_mode THEN
		IF (l_debug = 1) THEN
   		trace('Invalid mode in generate_xml_csv: w');
		END IF;
		FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_SETUP_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_REASON', 'Invalid Mode');
		FND_MSG_PUB.ADD;
		retval := -1;
		return retval;
	WHEN FND_API.G_EXC_ERROR THEN
		IF (l_debug = 1) THEN
   		trace(' Expected error in generate XML ');
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF (l_debug = 1) THEN
   		trace(' UnExpected error in generate XML ');
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   trace(' Other error in generate XML ');
		   trace('SQL error :'||substr(sqlerrm, 1, 240));
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END generate_xml_csv;



---------------------------------------------------------
--   Populate History
--
---------------------------------------------------------
PROCEDURE populate_History (p_call_ctx              IN   VARCHAR2 ,
                            p_bus_event             IN   NUMBER,
                            x_device_records_exist OUT NOCOPY VARCHAR2) IS -- Modified for bug#8778050

   l_counter NUMBER := 0;
   CURSOR cur_dev IS SELECT * FROM wms_device_requests where device_id is
      not null;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_device_records_exist := 'Y';

   FOR l_rec IN cur_dev LOOP
      /* IF (l_debug = 1) THEN
      trace('outfile_name='||l_rec.outfile_name||'request_id:'||l_rec.request_id||'task_id:'||l_rec.task_id);
	END IF;
	*/
	l_counter := l_counter +1;
      INSERT INTO wms_device_requests_hist (request_id,
					   task_id,
					   relation_id,
					   sequence_id,
					   task_summary,
					   task_type_id,
					   business_event_id,
					   organization_id,
					   subinventory_code,
					   locator_id,
					   transfer_org_id,
					   transfer_sub_code,
					   transfer_loc_id,
					   inventory_item_id,
					   revision,
					   uom,
					   lot_number,
					   lot_qty,
					   serial_number,
					    lpn_id,
					    xfer_lpn_id,
					   transaction_quantity,
					   device_id,
					   status_code,
					   status_msg,
					   outfile_name,
					   request_date,
					   resubmit_date,
					   requested_by,
					   responsibility_application_id,
					   responsibility_id,
					   concurrent_request_id,
					   program_application_id,
					   program_id,
					   program_update_date,
					   creation_date,
					   created_by,
					   last_update_date,
					   last_updated_by,
					   last_update_login) VALUES
	(l_rec.request_id,
	 l_rec.task_id,
	 l_rec.relation_id,
	 l_rec.sequence_id,
	 l_rec.task_summary,
	 l_rec.task_type_id,
	 l_rec.business_event_id,
	 l_rec.organization_id,
	 l_rec.subinventory_code,
	 l_rec.locator_id,
	 l_rec.transfer_org_id,
	 l_rec.transfer_sub_code,
	 l_rec.transfer_loc_id,
	 l_rec.inventory_item_id,
	 l_rec.revision,
	 l_rec.uom,
	 l_rec.lot_number,
	 l_rec.lot_qty,
	 l_rec.serial_number,
	 l_rec.lpn_id,
	 l_rec.xfer_lpn_id,
	 l_rec.transaction_quantity,
	 l_rec.device_id,
	 Nvl(l_rec.status_code,'S'),
	 l_rec.status_msg,
	 l_rec.outfile_name,
	 l_rec.last_update_date,
	 NULL,
	 l_rec.last_updated_by,
	 FND_GLOBAL.RESP_APPL_ID,
	 FND_GLOBAL.RESP_ID,
	 null,
	 null,
	 null,
	 null,
	 l_rec.last_update_date,
	 l_rec.last_updated_by,
	 l_rec.last_update_date,
	 l_rec.last_updated_by,
	 l_rec.last_update_login);


   END LOOP;

   -- Added for bug#8778050 start

   IF ( p_call_ctx = DEV_REQ_USER  and p_bus_event=WMS_BE_TASK_COMPLETE) then
        COMMIT;
   END IF;

   -- Added for bug#8778050 end

    IF (l_debug = 1) THEN
       trace('Inside the populate_history:l_counter'||l_counter);
    END IF;
   IF l_counter = 0 THEN
      x_device_records_exist := 'N';
   END IF;

END;

----------------------------------------------------------
---- Move rows back to the wms_device_requests temp table
----------------------------------------------------------

PROCEDURE move_resubmit_rows(p_request_id number, p_bus_event_id number)IS


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      trace('Move from Hist table to temp table');
   END IF;

   insert into wms_device_requests (
				 BUSINESS_EVENT_ID
				 ,DEVICE_ID
				 ,DEVICE_STATUS
				 ,INVENTORY_ITEM_ID
				 ,LAST_UPDATED_BY
				 ,LAST_UPDATE_DATE
				 ,LAST_UPDATE_LOGIN
				 ,LOCATOR_ID
				 ,LOT_NUMBER
				 ,LOT_QTY
				 ,LPN_ID
				 ,ORGANIZATION_ID
				 ,OUTFILE_NAME
				 ,REASON_ID
				 ,RELATION_ID
				 ,REQUEST_ID
				 ,REVISION
				 ,SEQUENCE_ID
				 ,SERIAL_NUMBER
				 ,STATUS_CODE
				 ,STATUS_MSG
				 ,SUBINVENTORY_CODE
				 ,TASK_ID
				 ,TASK_SUMMARY
				 ,TASK_TYPE_ID
				 ,TRANSACTION_QUANTITY
				 ,TRANSFER_LOC_ID
				 ,TRANSFER_ORG_ID
				 ,TRANSFER_SUB_CODE
				 ,UOM
				 ,XFER_LPN_ID)
     select
     BUSINESS_EVENT_ID
     ,DEVICE_ID
   ,DEVICE_STATUS
   ,INVENTORY_ITEM_ID
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,LOCATOR_ID
   ,LOT_NUMBER
   ,LOT_QTY
   ,LPN_ID
   ,ORGANIZATION_ID
   ,OUTFILE_NAME
   ,REASON_ID
   ,RELATION_ID
   ,REQUEST_ID
   ,REVISION
   ,SEQUENCE_ID
   ,SERIAL_NUMBER
   ,STATUS_CODE
   ,STATUS_MSG
   ,SUBINVENTORY_CODE
   ,TASK_ID
   ,TASK_SUMMARY
   ,TASK_TYPE_ID
   ,TRANSACTION_QUANTITY
   ,TRANSFER_LOC_ID
   ,TRANSFER_ORG_ID
   ,TRANSFER_SUB_CODE
   ,UOM
   ,XFER_LPN_ID
   from wms_device_requests_hist
   WHERE  request_id = p_request_id
   AND status_code ='P'
   AND Nvl(business_event_id,-1) = Nvl(p_bus_event_id,-1);


END;


---------------------------------------------------------
--  Retrieve err message from the message stack
---------------------------------------------------------
FUNCTION GET_MSG_STACK RETURN VARCHAR2 IS
	l_msg_count number;
	l_msg_data varchar2(240);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	fnd_msg_pub.count_And_get(
			p_count    => l_msg_count,
			p_data     => l_msg_data,
			p_encoded  => 'F'
	);
	IF (l_debug = 1) THEN
   	trace('get message stack, count='||l_msg_count);
	END IF;
	IF l_msg_count = 0 THEN
		l_msg_data := '';
	ELSIF l_msg_count =1 THEN
		null;
	 ELSE
	   l_msg_data := fnd_msg_pub.get(l_msg_count,'F');

	   /*l_msg_data := '';
		FOR i IN 1..l_msg_count LOOP
			l_msg_data := l_msg_data || fnd_msg_pub.get(I,'F');
		  END LOOP;
		  */
	END IF;
	FND_MSG_PUB.initialize;
	RETURN l_msg_data;
END GET_MSG_STACK;

---------------------------------------------------------
--   DEVICE_REQUEST
--
---------------------------------------------------------
  PROCEDURE DEVICE_REQUEST(
			   p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false,
			   p_bus_event             IN   NUMBER,
			   p_call_ctx              IN   VARCHAR2 ,
			   p_task_trx_id	              IN   NUMBER := NULL,
			   p_org_id                IN   NUMBER := NULL,
			   p_item_id               IN   NUMBER := NULL,
			   p_subinv                IN   VARCHAR2 := NULL,
			   p_locator_id            IN   NUMBER := NULL,
			   p_lpn_id                IN   NUMBER := NULL,
			   p_xfer_lpn_id           IN   NUMBER := NULL, --Added for Bug#8778050
			   p_xfr_org_id            IN   NUMBER := NULL,
			   p_xfr_subinv            IN   VARCHAR2 := NULL,
			   p_xfr_locator_id        IN   NUMBER := NULL,
			   p_trx_qty               IN   NUMBER := NULL,
			   p_trx_uom	              IN   VARCHAR2 := NULL,
			   p_rev                   IN   VARCHAR2 := NULL,
			   x_request_msg           OUT  NOCOPY VARCHAR2,
			   x_return_status         OUT  NOCOPY VARCHAR2,
			   x_msg_count             OUT  NOCOPY NUMBER,
			   x_msg_data              OUT  NOCOPY VARCHAR2,
			   p_request_id            IN OUT NOCOPY NUMBER) IS
cursor c_wdr is select * from WMS_DEVICE_REQUESTS where task_summary = 'Y';
cursor c_wdr_devgrp is select device_id from WMS_DEVICE_REQUESTS where device_id is not null group BY device_id;

l_seldev number;
l_cur_dev number;
l_lot_ser_ok varchar2(1);
l_deviotype number;
l_req_stat varchar2(255);
l_req_stat_msg varchar2(255);
l_dev_stat varchar2(255);
l_dev_req_type number;
l_retval number;
l_sort NUMBER;
l_msg varchar2(30);
l_autoenabled varchar2(2);
l_request_id number;
l_xml_stat VARCHAR2(1);
l_status_msg VARCHAR2(240) := '';
l_parent_request_id NUMBER;
l_notification_flag VARCHAR2(1);
l_device_records_exists VARCHAR2(1);
l_setup_row_cnt NUMBER := 0 ;
l_wcs_enabled VARCHAR2(1) := 'N'; --MHE

--Added for bug#9233592 start
l_xfr_org_id  NUMBER := NULL;
l_xfr_subinv  VARCHAR2(10) := '';
l_xfr_locator_id   NUMBER := NULL;
--Added for bug#9233592 end

l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- FOR PICK RELEASE AND REPLENISHMENT TASK ALLOCATION PARAMETER
   --'wms_call_device_request' SHOULD HAVE BEEN
   -- SET UP THROUGH CALL FROM PICK RELEASE AND MO PICK SLIP REPORT
   -- allocation CODE RESPECTIVELY.
   -- IF IT IS NULL THEN IT MEANS NO SET UP FOR THIS BUS EVENT IS DONE
   IF p_bus_event IN (wms_be_pick_release,wms_be_mo_task_alloc) AND wms_call_device_request IS NULL THEN
      RETURN;
   END IF;


   --If there is no record in the setup table for the concerned business
   --event then, return from here itself with success;

     BEGIN
	SELECT 1 INTO l_setup_row_cnt FROM DUAL WHERE exists
	  (SELECT 1
	   FROM wms_bus_event_devices
	   WHERE business_event_id = p_bus_event);

     EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   l_setup_row_cnt:=0;
     END;

     IF (l_setup_row_cnt = 0 AND p_bus_event < 50) THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	RETURN;
     END IF;

     SAVEPOINT WMS_DEVICE_REQUESTS;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (l_debug = 1) THEN
   	trace('******* Device Request *********');
     END IF;

     IF (p_bus_event IS NULL)THEN
	x_return_status := 'E';
	IF (l_debug = 1) THEN
   	   trace('Invlid Business Event');
	END IF;
	FND_MESSAGE.SET_NAME('WMS', 'WMS_BUSEVENT_INVALID');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Verify parameters passed . Either TaskId should be not NULL or
     -- Org and Sub should be Not NULL
     IF (l_debug = 1) THEN
   	trace('busev='||p_bus_event||',callctx='||p_call_ctx||',task='||p_task_trx_id||',org='||p_org_id||',sub='||p_subinv||',loc='||p_locator_id||', p_request_id='||p_request_id|| ' ,p_item_id= '||p_item_id);
     END IF;
     IF (p_bus_event NOT IN (wms_be_pick_release, wms_be_mo_task_alloc)
	 AND p_task_trx_id IS NULL AND
	  (p_org_id IS NULL OR (p_subinv is NULL AND p_xfr_subinv IS NULL))
	 ) THEN

	x_return_status := 'E';
	IF (l_debug = 1) THEN
   	   trace('Either Task_id is null or orgid is NULL OR sub IS NULL');
	END IF;
	FND_MESSAGE.SET_NAME('WMS', 'WMS_INVOKE_ERR');
	FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Validate p_request_id when the busniess event is Task Complete
	IF(p_bus_event in (wms_be_task_complete, wms_be_task_skip, wms_be_task_cancel)) THEN
		IF p_request_id IS NULL THEN
		  IF (l_debug = 1) THEN
   		  trace('Error: p_request_id is null for Task Complete/skip/cancel bus event');
		  END IF;
		  FND_MESSAGE.SET_NAME('WMS', 'WMS_INVOKE_ERR');
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
		ELSE
		  BEGIN
		    SELECT request_id INTO l_parent_request_id
		    FROM wms_device_requests_hist
		      WHERE request_id = p_request_id
		      AND task_summary = 'Y';
		  EXCEPTION
		    WHEN no_data_found THEN
		      IF (l_debug = 1) THEN
   		      trace('Error: p_request_id is not valid for Task Complete/skip/cancel');
		      END IF;
		      FND_MESSAGE.SET_NAME('WMS', 'WMS_INVOKE_ERR');
		      FND_MSG_PUB.ADD;
		      RAISE FND_API.G_EXC_ERROR;
		  END;
		END IF;
		IF (l_debug = 1) THEN
   		trace('Passed validation for Task Complete/skip/cancel, l_parent_request_id='||l_parent_request_id);
		END IF;
	END IF;


	-- Set the l_autoenabled based on the calling context
	if ( p_call_ctx = DEV_REQ_AUTO) then
	   l_autoenabled := 'Y';
	 else
	   l_autoenabled := 'N';
	end if;

	-- Retrieve Business Event details
	--for Pick Release and Replenish Task Allocation bus event it is done in cartonization code
        IF p_bus_event IN (wms_be_pick_release, wms_be_mo_task_alloc) THEN
            l_request_id := wms_pkRel_dev_req_id;
	ELSIF p_bus_event <> wms_be_ship_confirm AND p_bus_event NOT IN
	    (wms_be_pick_release, wms_be_mo_task_alloc) THEN

	   IF (l_debug = 1) THEN
	      trace('bus_event not ship_confirm, retrieve_Bus_Event_Details',9);
	   END IF;
--	   IF  ( p_org_id IS NOT NULL /* AND p_item_id IS NOT NULL */ AND  --Commented against bug : 5742996
--		 p_subinv IS NOT NULL AND p_locator_id IS NOT NULL) THEN

     IF (l_debug = 1) THEN
        trace('busev='||p_bus_event||',callctx='||p_call_ctx||',task='||p_task_trx_id||',org='||p_org_id||',sub='||p_subinv||',loc='||p_locator_id||', p_request_id='||p_request_id|| ' ,p_item_id= '||p_item_id);
        trace('busev='||p_bus_event||',callctx='||p_call_ctx||',task='||p_task_trx_id||',xfr_org='||p_xfr_org_id||',xfr_sub='||p_xfr_subinv||',xfr_loc='||p_xfr_locator_id||', p_request_id='||p_request_id|| ' ,p_item_id= '||p_item_id);
     END IF;


--   Bug :5742996 START
     IF (p_org_id IS NOT NULL AND/* AND p_item_id IS NOT NULL */
         p_subinv IS NOT NULL AND
         p_locator_id IS NOT NULL)
        OR  (p_bus_event in (WMS_BE_PUTAWAY_DROP, WMS_BE_PICK_DROP)
             AND p_xfr_org_id IS NOT NULL
             AND p_xfr_subinv IS NOT NULL
             AND p_xfr_locator_id IS NOT NULL)
     THEN
--   Bug :5742996 END
	      IF (l_debug = 1) THEN
 		 trace('CALL TO DEVICE_REQUEST BY ALL PARAMETERS WITH TEMP_ID also, retrieve_Bus_Event_Details',9);
	      END IF;
           --Added for bug#9233592 start
	   IF( p_bus_event in (wms_be_task_complete)
              AND p_xfr_org_id IS NULL
              AND p_xfr_subinv IS NULL
              AND p_xfr_locator_id IS NULL )
          THEN
                BEGIN
                    SELECT TRANSFER_ORG_ID,TRANSFER_SUB_CODE,TRANSFER_LOC_ID
                    INTO   l_xfr_org_id,l_xfr_subinv,l_xfr_locator_id
                    FROM
                    wms_device_requests_hist
                    WHERE REQUEST_ID=p_request_id;
		              EXCEPTION
		                WHEN no_data_found THEN
		                  IF (l_debug = 1) THEN
   		                  trace('Could not retrieve p_xfr_org_id,p_xfr_subinv,p_xfr_locator_id for Task Complete business flow using p_request_id');
		                  END IF;
		            END;
                trace('p_xfr_org_id,p_xfr_subinv,p_xfr_locator_id values for Task Complete business flow '||p_xfr_org_id||','||p_xfr_subinv||','||p_xfr_subinv||'are retrieved using p_request_id'||p_request_id);

                retrieve_Bus_Event_Details(p_bus_event,
					        p_task_trx_id,
					        p_org_id,
					        p_item_id,
					        p_subinv,
					        p_locator_id,
					        p_lpn_id,
					        p_xfer_lpn_id,  --Added for Bug#8778050
					        l_xfr_org_id,
					        l_xfr_subinv,
					        l_xfr_locator_id,
					        p_trx_qty,
					        p_trx_uom,
					        p_rev,
					        l_request_id,
					      x_return_status);

              ELSE

	      --Here Temp_id is needed just to identify the record in wdt to stamp device_id IN it
	      --Bug #2458131
	      retrieve_Bus_Event_Details(p_bus_event,
					 p_task_trx_id,
					 p_org_id,
					 p_item_id,
					 p_subinv,
					 p_locator_id,
					 p_lpn_id,
					 p_xfer_lpn_id,  --Added for Bug#8778050
					 p_xfr_org_id,
					 p_xfr_subinv,
					 p_xfr_locator_id,
					 p_trx_qty,
					 p_trx_uom,
					 p_rev,
					 l_request_id,
					 x_return_status);
		END IF;

		--Added for bug#9233592 end

	      IF (x_return_status = 'S')THEN

		 -- Updating wms_dispatched_tasks with the device_id
		 UPDATE wms_dispatched_tasks
		   SET DEVICE_REQUEST_ID = l_request_id
		   WHERE TRANSACTION_TEMP_ID = p_task_trx_id;

	       ELSIF (x_return_status = 'E')THEN
		 IF (l_debug = 1) THEN
   		 trace ('Could not retrieve Event Details');
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_PICKREL_ERR');
		 FND_MSG_PUB.ADD;
		 RAISE FND_API.G_EXC_ERROR;
	      END IF;

	    ELSIF (p_task_trx_id IS NOT NULL) THEN
	      IF (l_debug = 1) THEN
   	      trace(' CALL TO DEVICE_REQUEST BY TEMP_ID ONLY, retrieve_Bus_Event_Details',9);
	      END IF;
	      retrieve_Bus_Event_Details(p_task_trx_id,
					 p_bus_event,
					 l_request_id,
					 x_return_status);


	      IF (x_return_status = 'S')THEN
		 -- Updating wms_dispatched_tasks with the device_id
		 UPDATE wms_dispatched_tasks
		   SET DEVICE_REQUEST_ID = l_request_id
		   WHERE transaction_temp_id = p_task_trx_id;

	       ELSIF (x_return_status = 'E')THEN
		 IF (l_debug = 1) THEN
   		 trace('Could not retrieve Event Details');
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_BUSEVENT_ERR');
		 FND_MSG_PUB.ADD;
		 RAISE FND_API.G_EXC_ERROR;
	      END IF;
	   END IF;
	 ELSIF (p_task_trx_id IS NOT NULL AND p_bus_event = wms_be_ship_confirm) THEN
	   IF (l_debug = 1) THEN
   	   trace(' Task ID is not null and event is ship confirm, retrieve_Ship_Confirm_Details');
	   END IF;

	   retrieve_Ship_Confirm_Details(p_task_trx_id, p_bus_event,
					 l_request_id,x_return_status);
	   IF (x_return_status = 'E')THEN
	      IF (l_debug = 1) THEN
   	      trace('Could not retrieve ship confirm details');
	      END IF;
	      FND_MESSAGE.SET_NAME('WMS', 'WMS_SHIPCONFIRM_ERR');
	      FND_MSG_PUB.ADD;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	end if;

	-- Loop on WMS_DEVICE_REQUESTS per device
	IF p_bus_event NOT IN (wms_be_pick_release, wms_be_mo_task_alloc)
	  THEN --for pick release and replenish Task Allocation this IS done IN cartonization code

	   IF (l_debug = 1) THEN
	      trace('Select device for each request');
	   END IF;
	   for l_wdr in c_wdr  LOOP
	      l_seldev := select_Device(l_wdr, l_autoenabled, l_parent_request_id);
	      l_wdr.device_id := l_seldev;
	      -- If No device has been selected for this record, then do not
	      --  consider this record for further processing
	      if (l_seldev <> 0) then
		 select Nvl(lot_serial_capable,'N')
		   into l_lot_ser_ok
		   from WMS_DEVICES_B
		   where device_id = l_seldev;
		 -- If Details enabled for device, retrieve the Lot/Serialdetails
		 IF (l_lot_ser_ok = 'Y') THEN
		    retrieve_Lot_Serial_Details(l_wdr, x_return_status);
		    IF (x_return_status = 'E')THEN
		       IF (l_debug = 1) THEN
			  trace('Could not retrieve lot and or serial details');
		       END IF;
		       FND_MESSAGE.SET_NAME('WMS', 'WMS_LOT_SER_DETAIL_ERR');
		       FND_MSG_PUB.ADD;
		       RAISE FND_API.G_EXC_ERROR;
		    END IF;
		    l_lot_ser_ok:= NULL;
		 END IF;
	      end if;

	   end loop;
	END IF;
	-- Loop on WMS_DEVICE_REQUESTS per Device
	IF (l_debug = 1) THEN
	   trace('### Submit request per device group ');
	END IF;
	for l_cur_dev in c_wdr_devgrp  loop

		-- For Task Complete, if the device is enabled to notify task complete
		-- update the request records' RELATION_ID with the parent_request_id
		IF(p_bus_event in (wms_be_task_complete, wms_be_task_skip, wms_be_task_cancel)) THEN
			select nvl(notification_flag, 'N')
			into l_notification_flag
			from WMS_DEVICES_B
			where device_id = l_cur_dev.device_id;

			IF (l_debug = 1) THEN
   			trace('Event is task complete/skip/cancel, check whether need to update relation_id, notification_flag='||l_notification_flag);
			END IF;
			IF l_notification_flag = 'Y' THEN
			  IF (l_debug = 1) THEN
   			  trace('update request and request_hist for device '||l_cur_dev.device_id|| ' and parent_request_id='||l_parent_request_id);
			  END IF;
			  BEGIN
			    update wms_device_requests
			    set relation_id = l_parent_request_id
			    where device_id = l_cur_dev.device_id;

			    update wms_device_requests_hist
			    set relation_id = l_parent_request_id
			    where request_id = l_parent_request_id;
			  EXCEPTION
			    WHEN others THEN
			      IF (l_debug = 1) THEN
   			      trace('Error in updating relation_id on the request table for task complete/skip/cancel, dev_id='||l_cur_dev.device_id);
			      trace('SQL error :'||substr(sqlerrm, 1, 240));
			      END IF;
			      RAISE FND_API.G_EXC_ERROR;
			  END;
			END IF;
		END IF;

		select d.OUTPUT_METHOD_ID, p.WCS_ENABLED
		into l_deviotype, l_wcs_enabled
		from WMS_DEVICES_B d, mtl_parameters p
		where d.device_id = l_cur_dev.device_id
                and p.organization_id = d.organization_id;


		IF (l_debug = 1) THEN
   		trace('!----Device_ID: '||l_cur_dev.device_id||', got iotype ' || l_deviotype);
   		trace('MHE: p_org_id = '||p_org_id||', l_wcs_enabled = '||l_wcs_enabled);
		END IF;
		-- Generate XML,CSV if configured for it
		IF (( l_deviotype = WMS_DEV_IO_XML) OR (l_deviotype = WMS_DEV_IO_CSV)) then
			IF (l_debug = 1) THEN
   			trace('going to call generate_xml_csv');
			END IF;
			l_retval := generate_xml_csv(l_cur_dev.device_id,l_deviotype);
			IF l_retval <> 0 THEN
				l_xml_stat := 'E';
			ELSE
				l_xml_stat := 'S';
			END IF;
			IF (l_debug = 1) THEN
   			trace(' Done with generate xml , retval '||l_retval ||' status_code: '||l_xml_stat);
			END IF;
			l_status_msg := get_msg_stack;--only last message
		                                      --IN the stack

		      IF l_xml_stat <> 'S' THEN
		         UPDATE wms_device_requests
		         SET status_code = l_xml_stat,
		           status_msg = l_status_msg
		           WHERE device_id = l_cur_dev.device_id;
		      ELSE
		          UPDATE wms_device_requests
		          SET status_code = 'S'
		          WHERE device_id = l_cur_dev.device_id;
		      END IF;

		ELSIF (l_deviotype = WMS_DEV_IO_API) then
			IF (l_debug = 1) THEN
   			trace(' Submit sync_device_request');
			END IF;
         IF nvl(l_wcs_enabled,'N') = 'N' THEN
            trace('MHE: Calling WMS_DEVICE_INTEGRATION_PUB.SYNC_DEVICE_REQUEST');
   			WMS_DEVICE_INTEGRATION_PUB.SYNC_DEVICE_REQUEST(
   			       p_request_id    => l_request_id,
   			       p_device_id     => l_cur_dev.device_id,
   			       p_resubmit_flag => 'N',
   			       x_status_code   =>  l_req_stat,
   			       x_device_status => l_dev_stat,
   			       x_status_msg    => l_req_stat_msg );
         ELSE
            trace('MHE: Calling WMS_DEVICE_INTEGRATION_WCS.SYNC_DEVICE_REQUEST');
   			WMS_DEVICE_INTEGRATION_WCS.SYNC_DEVICE_REQUEST(
   			       p_request_id    => l_request_id,
   			       p_device_id     => l_cur_dev.device_id,
   			       p_resubmit_flag => 'N',
   			       x_status_code   =>  l_req_stat,
   			       x_device_status => l_dev_stat,
   			       x_status_msg    => l_req_stat_msg );
         END IF;


			IF ( l_req_stat <> FND_API.g_ret_sts_success) THEN
			   UPDATE wms_device_requests
			     SET status_code = l_req_stat,
			     status_msg = l_req_stat_msg
			     WHERE device_id = l_cur_dev.device_id;
			ELSE
			   UPDATE wms_device_requests
			     SET status_code = 'S'
			     WHERE device_id = l_cur_dev.device_id;
			END IF;
		end if;
	end loop;

	-- Populate the History table
	IF (l_debug = 1) THEN
   	trace('Populate Request History');
	END IF;
	populate_History(p_call_ctx,p_bus_event,l_device_records_exists); -- Modified for bug#8778050

	IF l_device_records_exists = 'N' THEN
	   -- No device exists, return null request id
	   IF (l_debug = 1) THEN
   	   trace('setting _request_id to NULL');
	   END IF;
	   p_request_id := NULL;
	 ELSE
	   p_request_id := l_request_id;
	END IF;

	-- Finally delete all rows from WMS_DEV_REQUEST so that each invocation of
	-- this API in this session starts with an empty table.

	IF (l_debug = 1) THEN
   	trace(' Delete request rows');
	END IF;
	delete  from wms_device_requests;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
         trace('Error: G_EXC_ERR : Delete request rows');
      END IF;
      	delete  from wms_device_requests;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_REQ_FAIL');
      FND_MSG_PUB.ADD;
      ROLLBACK TO WMS_DEVICE_REQUESTS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
         trace('Error: G_EXC_UNEXP : Delete request rows');
      END IF;
      	delete  from wms_device_requests;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_REQ_FAIL');
      FND_MSG_PUB.ADD;
      ROLLBACK TO WMS_DEVICE_REQUESTS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         trace('Error: '||substr(sqlerrm, 1, 100));
      END IF;
      	delete  from wms_device_requests;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_REQ_FAIL');
      FND_MSG_PUB.ADD;
      ROLLBACK TO WMS_DEVICE_REQUESTS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

END;

  PROCEDURE DEVICE_REQUEST(
		p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false,
		p_bus_event             IN   NUMBER,
		p_call_ctx              IN   VARCHAR2 ,
		p_task_trx_id	              IN   NUMBER := NULL,
		p_org_id                IN   NUMBER := NULL,
		p_item_id               IN   NUMBER := NULL,
		p_subinv                IN   VARCHAR2 := NULL,
		p_locator_id            IN   NUMBER := NULL,
		p_lpn_id                IN   NUMBER := NULL,
		p_xfr_org_id            IN   NUMBER := NULL,
		p_xfr_subinv            IN   VARCHAR2 := NULL,
		p_xfr_locator_id        IN   NUMBER := NULL,
		p_trx_qty               IN   NUMBER := NULL,
		p_trx_uom	              IN   VARCHAR2 := NULL,
		p_rev                   IN   VARCHAR2 := NULL,
		x_request_msg           OUT  NOCOPY VARCHAR2,
		x_return_status         OUT  NOCOPY VARCHAR2,
		x_msg_count             OUT  NOCOPY NUMBER,
		x_msg_data              OUT  NOCOPY VARCHAR2)
    IS
      l_request_id VARCHAR2(40);
      l_xfer_lpn_id NUMBER := NULL; --Added for Bug#8778050
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     DEVICE_REQUEST(
		p_init_msg_list=>p_init_msg_list,
		p_bus_event=>p_bus_event,
		p_call_ctx =>p_call_ctx,
		p_task_trx_id=>p_task_trx_id,
		p_org_id=>p_org_id,
		p_item_id=>p_item_id,
		p_subinv=>p_subinv,
		p_locator_id=>p_locator_id,
		p_lpn_id=>p_lpn_id,
		p_xfer_lpn_id=>l_xfer_lpn_id, --Added for Bug#8778050
		p_xfr_org_id=>p_xfr_org_id,
		p_xfr_subinv=>p_xfr_subinv,
		p_xfr_locator_id=>p_xfr_locator_id,
		p_trx_qty=>p_trx_qty,
		p_trx_uom=>p_trx_uom,
		p_rev=>p_rev,
		x_request_msg=>x_request_msg,
		x_return_status=>x_return_status,
		x_msg_count=>x_msg_count,
		x_msg_data=>x_msg_data,
		p_request_id=>l_request_id);

  END device_request;

--WMS-OPM
/*
	This will be the overloaded device_request API which will be called
	from an OPM UI. The difference in this API is that, the caller will
	know the device_id to which the the request must be sent and the API
	will not have any logic to resolve the API from the table wms_bus_event_devices

	Inserting into WDR is kept transparent to the OPM team who will call this
	through a wrapper API in a group package

	The request traffic will get logged in the wms_device_requests_hist table
	in addition to being captured in wms_carousel_log
*/
  PROCEDURE DEVICE_REQUEST(
			   p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false,
			   p_bus_event             IN   NUMBER,
			   p_call_ctx              IN   VARCHAR2 ,
			   p_task_trx_id	              IN   NUMBER := NULL,
			   p_org_id                IN   NUMBER := NULL,
			   p_item_id               IN   NUMBER := NULL,
			   p_subinv                IN   VARCHAR2 := NULL,
			   p_locator_id            IN   NUMBER := NULL,
			   p_lpn_id                IN   NUMBER := NULL,
			   p_xfr_org_id            IN   NUMBER := NULL,
			   p_xfr_subinv            IN   VARCHAR2 := NULL,
			   p_xfr_locator_id        IN   NUMBER := NULL,
			   p_trx_qty               IN   NUMBER := NULL,
			   p_trx_uom	              IN   VARCHAR2 := NULL,
			   p_rev                   IN   VARCHAR2 := NULL,
			   x_request_msg           OUT  NOCOPY VARCHAR2,
			   x_return_status         OUT  NOCOPY VARCHAR2,
			   x_msg_count             OUT  NOCOPY NUMBER,
			   x_msg_data              OUT  NOCOPY VARCHAR2,
			   p_request_id            IN OUT NOCOPY NUMBER,
			   p_device_id             IN   NUMBER) IS
cursor c_wdr is select * from WMS_DEVICE_REQUESTS where task_summary = 'Y';
cursor c_wdr_devgrp is select device_id from WMS_DEVICE_REQUESTS where device_id is not null group BY device_id;

l_seldev number;
l_cur_dev number;
l_lot_ser_ok varchar2(1);
l_deviotype number;
l_req_stat varchar2(255);
l_req_stat_msg varchar2(255);
l_dev_stat varchar2(255);
l_dev_req_type number;
l_retval number;
l_sort NUMBER;
l_msg varchar2(30);
l_autoenabled varchar2(2);
l_request_id number;
l_xml_stat VARCHAR2(1);
l_status_msg VARCHAR2(240) := '';
l_parent_request_id NUMBER;
l_notification_flag VARCHAR2(1);
l_device_records_exists VARCHAR2(1);
l_setup_row_cnt NUMBER := 0 ;
l_wcs_enabled VARCHAR2(1) := 'N'; --MHE

l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- FOR PICK RELEASE AND REPLENISHMENT TASK ALLOCATION PARAMETER
   --'wms_call_device_request' SHOULD HAVE BEEN
   -- SET UP THROUGH CALL FROM PICK RELEASE AND MO PICK SLIP REPORT
   -- allocation CODE RESPECTIVELY.
   -- IF IT IS NULL THEN IT MEANS NO SET UP FOR THIS BUS EVENT IS DONE
   IF p_bus_event IN (wms_be_pick_release,wms_be_mo_task_alloc) AND wms_call_device_request IS NULL THEN
      RETURN;
   END IF;


   --If there is no record in the setup table for the concerned business
   --event then, return from here itself with success;

     BEGIN
	SELECT 1 INTO l_setup_row_cnt FROM DUAL WHERE exists
	  (SELECT 1
	   FROM wms_bus_event_devices
	   WHERE business_event_id = p_bus_event);

     EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   l_setup_row_cnt:=0;
     END;

     IF (l_setup_row_cnt = 0 AND p_bus_event < 50) THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	RETURN;
     END IF;

     SAVEPOINT WMS_DEVICE_REQUESTS;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (l_debug = 1) THEN
   	trace('******* Device Request *********');
     END IF;

     IF (p_bus_event IS NULL)THEN
	x_return_status := 'E';
	IF (l_debug = 1) THEN
   	   trace('Invlid Business Event');
	END IF;
	FND_MESSAGE.SET_NAME('WMS', 'WMS_BUSEVENT_INVALID');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Verify parameters passed . Either TaskId should be not NULL or
     -- Org and Sub should be Not NULL
     IF (l_debug = 1) THEN
   	trace('busev='||p_bus_event||',callctx='||p_call_ctx||',task='||p_task_trx_id||',org='||p_org_id||',sub='||p_subinv||',loc='||p_locator_id||', p_request_id='||p_request_id|| ' ,p_item_id= '||p_item_id);
     END IF;
     IF (p_bus_event NOT IN (wms_be_pick_release, wms_be_mo_task_alloc)
	 AND p_task_trx_id IS NULL AND
	  (p_org_id IS NULL OR (p_subinv is NULL AND p_xfr_subinv IS NULL))
	 ) THEN

	x_return_status := 'E';
	IF (l_debug = 1) THEN
   	   trace('Either Task_id is null or orgid is NULL OR sub IS NULL');
	END IF;
	FND_MESSAGE.SET_NAME('WMS', 'WMS_INVOKE_ERR');
	FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Validate p_request_id when the busniess event is Task Complete
	IF(p_bus_event in (wms_be_task_complete, wms_be_task_skip, wms_be_task_cancel)) THEN
		IF p_request_id IS NULL THEN
		  IF (l_debug = 1) THEN
   		  trace('Error: p_request_id is null for Task Complete/skip/cancel bus event');
		  END IF;
		  FND_MESSAGE.SET_NAME('WMS', 'WMS_INVOKE_ERR');
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
		ELSE
		  BEGIN
		    SELECT request_id INTO l_parent_request_id
		    FROM wms_device_requests_hist
		      WHERE request_id = p_request_id
		      AND task_summary = 'Y';
		  EXCEPTION
		    WHEN no_data_found THEN
		      IF (l_debug = 1) THEN
   		      trace('Error: p_request_id is not valid for Task Complete/skip/cancel');
		      END IF;
		      FND_MESSAGE.SET_NAME('WMS', 'WMS_INVOKE_ERR');
		      FND_MSG_PUB.ADD;
		      RAISE FND_API.G_EXC_ERROR;
		  END;
		END IF;
		IF (l_debug = 1) THEN
   		trace('Passed validation for Task Complete/skip/cancel, l_parent_request_id='||l_parent_request_id);
		END IF;
	END IF;


	-- Set the l_autoenabled based on the calling context
	if ( p_call_ctx = DEV_REQ_AUTO) then
	   l_autoenabled := 'Y';
	 else
	   l_autoenabled := 'N';
	end if;

	-- Retrieve Business Event details
	--for Pick Release and Replenish Task Allocation bus event it is done in cartonization code
        IF p_bus_event IN (wms_be_pick_release, wms_be_mo_task_alloc) THEN
            l_request_id := wms_pkRel_dev_req_id;
	ELSIF p_bus_event <> wms_be_ship_confirm AND p_bus_event NOT IN
	    (wms_be_pick_release, wms_be_mo_task_alloc) THEN

	   IF (l_debug = 1) THEN
	      trace('bus_event not ship_confirm, retrieve_Bus_Event_Details',9);
	   END IF;
	   IF  ( p_org_id IS NOT NULL /* AND p_item_id IS NOT NULL */ AND
		 p_subinv IS NOT NULL AND p_locator_id IS NOT NULL) THEN
	      IF (l_debug = 1) THEN
		 trace('CALL TO DEVICE_REQUEST BY ALL PARAMETERS WITH TEMP_ID also, retrieve_Bus_Event_Details',9);
	      END IF;
	      --Here Temp_id is needed just to identify the record in wdt to stamp device_id IN it
	      --Bug #2458131
	      retrieve_Bus_Event_Details(p_bus_event,
					 p_task_trx_id,
					 p_org_id,
					 p_item_id,
					 p_subinv,
					 p_locator_id,
					 p_lpn_id,
					 p_xfr_org_id,
					 p_xfr_subinv,
					 p_xfr_locator_id,
					 p_trx_qty,
					 p_trx_uom,
					 p_rev,
                p_device_id,
					 l_request_id,
					 x_return_status);

	      IF (x_return_status = 'S')THEN

		 -- Updating wms_dispatched_tasks with the device_id
		 UPDATE wms_dispatched_tasks
		   SET DEVICE_REQUEST_ID = l_request_id
		   WHERE TRANSACTION_TEMP_ID = p_task_trx_id;

	       ELSIF (x_return_status = 'E')THEN
		 IF (l_debug = 1) THEN
   		 trace ('Could not retrieve Event Details');
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_PICKREL_ERR');
		 FND_MSG_PUB.ADD;
		 RAISE FND_API.G_EXC_ERROR;
	      END IF;

	    ELSIF (p_task_trx_id IS NOT NULL) THEN
	      IF (l_debug = 1) THEN
   	      trace(' CALL TO DEVICE_REQUEST BY TEMP_ID ONLY, retrieve_Bus_Event_Details',9);
	      END IF;
	      retrieve_Bus_Event_Details(p_task_trx_id,
					 p_bus_event,
					 l_request_id,
					 x_return_status);


	      IF (x_return_status = 'S')THEN
		 -- Updating wms_dispatched_tasks with the device_id
		 UPDATE wms_dispatched_tasks
		   SET DEVICE_REQUEST_ID = l_request_id
		   WHERE transaction_temp_id = p_task_trx_id;

	       ELSIF (x_return_status = 'E')THEN
		 IF (l_debug = 1) THEN
   		 trace('Could not retrieve Event Details');
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_BUSEVENT_ERR');
		 FND_MSG_PUB.ADD;
		 RAISE FND_API.G_EXC_ERROR;
	      END IF;
	   END IF;
	 ELSIF (p_task_trx_id IS NOT NULL AND p_bus_event = wms_be_ship_confirm) THEN
	   IF (l_debug = 1) THEN
   	   trace(' Task ID is not null and event is ship confirm, retrieve_Ship_Confirm_Details');
	   END IF;

	   retrieve_Ship_Confirm_Details(p_task_trx_id, p_bus_event,
					 l_request_id,x_return_status);
	   IF (x_return_status = 'E')THEN
	      IF (l_debug = 1) THEN
   	      trace('Could not retrieve ship confirm details');
	      END IF;
	      FND_MESSAGE.SET_NAME('WMS', 'WMS_SHIPCONFIRM_ERR');
	      FND_MSG_PUB.ADD;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	end if;

	-- Loop on WMS_DEVICE_REQUESTS per device
	IF p_bus_event NOT IN (wms_be_pick_release, wms_be_mo_task_alloc)
	  THEN --for pick release and replenish Task Allocation this IS done IN cartonization code

	   IF (l_debug = 1) THEN
	      trace('Select device for each request');
	   END IF;
	   for l_wdr in c_wdr  LOOP
              --WMS-OPM
	      --l_seldev := select_Device(l_wdr, l_autoenabled, l_parent_request_id);
	      IF (l_debug = 1) THEN
	          trace('Not calling select_Device. Directly using the passed Device Id:'||p_device_id);
	      END IF;
	      l_seldev := p_device_id;

	      l_wdr.device_id := l_seldev;
	      -- If No device has been selected for this record, then do not
	      --  consider this record for further processing
	      if (l_seldev <> 0) then
		 select Nvl(lot_serial_capable,'N')
		   into l_lot_ser_ok
		   from WMS_DEVICES_B
		   where device_id = l_seldev;
		 -- If Details enabled for device, retrieve the Lot/Serialdetails
		 IF (l_lot_ser_ok = 'Y') THEN
		    retrieve_Lot_Serial_Details(l_wdr, x_return_status);
		    IF (x_return_status = 'E')THEN
		       IF (l_debug = 1) THEN
			  trace('Could not retrieve lot and or serial details');
		       END IF;
		       FND_MESSAGE.SET_NAME('WMS', 'WMS_LOT_SER_DETAIL_ERR');
		       FND_MSG_PUB.ADD;
		       RAISE FND_API.G_EXC_ERROR;
		    END IF;
		    l_lot_ser_ok:= NULL;
		 END IF;
	      end if;

	   end loop;
	END IF;
	-- Loop on WMS_DEVICE_REQUESTS per Device
	IF (l_debug = 1) THEN
	   trace('### Submit request per device group ');
	END IF;
	for l_cur_dev in c_wdr_devgrp  loop

		-- For Task Complete, if the device is enabled to notify task complete
		-- update the request records' RELATION_ID with the parent_request_id
		IF(p_bus_event in (wms_be_task_complete, wms_be_task_skip, wms_be_task_cancel)) THEN
			select nvl(notification_flag, 'N')
			into l_notification_flag
			from WMS_DEVICES_B
			where device_id = l_cur_dev.device_id;

			IF (l_debug = 1) THEN
   			trace('Event is task complete/skip/cancel, check whether need to update relation_id, notification_flag='||l_notification_flag);
			END IF;
			IF l_notification_flag = 'Y' THEN
			  IF (l_debug = 1) THEN
   			  trace('update request and request_hist for device '||l_cur_dev.device_id|| ' and parent_request_id='||l_parent_request_id);
			  END IF;
			  BEGIN
			    update wms_device_requests
			    set relation_id = l_parent_request_id
			    where device_id = l_cur_dev.device_id;

			    update wms_device_requests_hist
			    set relation_id = l_parent_request_id
			    where request_id = l_parent_request_id;
			  EXCEPTION
			    WHEN others THEN
			      IF (l_debug = 1) THEN
   			      trace('Error in updating relation_id on the request table for task complete/skip/cancel, dev_id='||l_cur_dev.device_id);
			      trace('SQL error :'||substr(sqlerrm, 1, 240));
			      END IF;
			      RAISE FND_API.G_EXC_ERROR;
			  END;
			END IF;
		END IF;

		select d.OUTPUT_METHOD_ID, p.WCS_ENABLED
		into l_deviotype, l_wcs_enabled
		from WMS_DEVICES_B d, mtl_parameters p
		where d.device_id = l_cur_dev.device_id
                and p.organization_id = d.organization_id;


		IF (l_debug = 1) THEN
   		trace('!----Device_ID: '||l_cur_dev.device_id||', got iotype ' || l_deviotype);
   		trace('MHE: p_org_id = '||p_org_id||', l_wcs_enabled = '||l_wcs_enabled);
		END IF;
		-- Generate XML,CSV if configured for it
		IF (( l_deviotype = WMS_DEV_IO_XML) OR (l_deviotype = WMS_DEV_IO_CSV)) then
			IF (l_debug = 1) THEN
   			trace('going to call generate_xml_csv');
			END IF;
			l_retval := generate_xml_csv(l_cur_dev.device_id,l_deviotype);
			IF l_retval <> 0 THEN
				l_xml_stat := 'E';
			ELSE
				l_xml_stat := 'S';
			END IF;
			IF (l_debug = 1) THEN
   			trace(' Done with generate xml , retval '||l_retval ||' status_code: '||l_xml_stat);
			END IF;
			l_status_msg := get_msg_stack;--only last message
		                                      --IN the stack

		      IF l_xml_stat <> 'S' THEN
		         UPDATE wms_device_requests
		         SET status_code = l_xml_stat,
		           status_msg = l_status_msg
		           WHERE device_id = l_cur_dev.device_id;
		      ELSE
		          UPDATE wms_device_requests
		          SET status_code = 'S'
		          WHERE device_id = l_cur_dev.device_id;
		      END IF;

		ELSIF (l_deviotype = WMS_DEV_IO_API) then
			IF (l_debug = 1) THEN
   			trace(' Submit sync_device_request');
			END IF;
         IF nvl(l_wcs_enabled,'N') = 'N' THEN
            trace('MHE: Calling WMS_DEVICE_INTEGRATION_PUB.SYNC_DEVICE_REQUEST');
   			WMS_DEVICE_INTEGRATION_PUB.SYNC_DEVICE_REQUEST(
   			       p_request_id    => l_request_id,
   			       p_device_id     => l_cur_dev.device_id,
   			       p_resubmit_flag => 'N',
   			       x_status_code   =>  l_req_stat,
   			       x_device_status => l_dev_stat,
   			       x_status_msg    => l_req_stat_msg );
         ELSE
            trace('MHE: Calling WMS_DEVICE_INTEGRATION_WCS.SYNC_DEVICE_REQUEST');
   			WMS_DEVICE_INTEGRATION_WCS.SYNC_DEVICE_REQUEST(
   			       p_request_id    => l_request_id,
   			       p_device_id     => l_cur_dev.device_id,
   			       p_resubmit_flag => 'N',
   			       x_status_code   =>  l_req_stat,
   			       x_device_status => l_dev_stat,
   			       x_status_msg    => l_req_stat_msg );
         END IF;


			IF ( l_req_stat <> FND_API.g_ret_sts_success) THEN
			   UPDATE wms_device_requests
			     SET status_code = l_req_stat,
			     status_msg = l_req_stat_msg
			     WHERE device_id = l_cur_dev.device_id;
			ELSE
			   UPDATE wms_device_requests
			     SET status_code = 'S'
			     WHERE device_id = l_cur_dev.device_id;
			END IF;
		end if;
	end loop;

	-- Populate the History table
	IF (l_debug = 1) THEN
   	trace('Populate Request History');
	END IF;
	populate_History(p_call_ctx,p_bus_event,l_device_records_exists); -- Modified for bug#8778050

   --WMS-OPM
	p_request_id := l_request_id;

	-- Finally delete all rows from WMS_DEV_REQUEST so that each invocation of
	-- this API in this session starts with an empty table.

	IF (l_debug = 1) THEN
   	trace(' Delete request rows');
	END IF;
	delete  from wms_device_requests;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
         trace('Error: G_EXC_ERR : Delete request rows');
      END IF;
      	delete  from wms_device_requests;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_REQ_FAIL');
      FND_MSG_PUB.ADD;
      ROLLBACK TO WMS_DEVICE_REQUESTS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
         trace('Error: G_EXC_UNEXP : Delete request rows');
      END IF;
      	delete  from wms_device_requests;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_REQ_FAIL');
      FND_MSG_PUB.ADD;
      ROLLBACK TO WMS_DEVICE_REQUESTS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         trace('Error: '||substr(sqlerrm, 1, 100));
      END IF;
      	delete  from wms_device_requests;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_REQ_FAIL');
      FND_MSG_PUB.ADD;
      ROLLBACK TO WMS_DEVICE_REQUESTS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

END;

---------------------------------------------------------
--   RESUBMIT_REQUEST
--
---------------------------------------------------------

PROCEDURE resubmit_request
  (
   x_retcode		OUT		NOCOPY VARCHAR2,
   x_errbuf		OUT 	        NOCOPY VARCHAR2,
   p_request_id		IN		NUMBER,
   p_device_id 		IN 		NUMBER := null,
   p_task_trx_id	IN	        NUMBER := null,
   p_sequence_id	IN              NUMBER := NULL,
   P_business_event_id	IN              NUMBER
   )IS

   CURSOR x_cur IS SELECT distinct device_id dev_id
     FROM wms_device_requests_hist
     WHERE Nvl(device_id, -1) = Nvl( p_device_id, -1)
     AND request_id = p_request_id
     AND status_code ='P'
     AND Nvl(sequence_id,-1) = Nvl(p_sequence_id,nvl(sequence_id, -1))
     AND Nvl(task_id,-1) = Nvl(p_task_trx_id,nvl(task_id, -1))
     GROUP BY device_id;

   l_req_stat varchar2(255);
   l_stat_msg varchar2(255);
   l_dev_stat varchar2(255);
   l_dev_req_type number;
   l_msg VARCHAR2(240);
   l_ret boolean;
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(240);
   l_wcs_enabled VARCHAR2(1);
   l_successful_row_cnt NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      trace('RESUBMIT REQUEST::req ID :='||p_business_event_id||':p_request_id:='||p_request_id);
   END IF;

   move_resubmit_rows(p_request_id,p_business_event_id);

   IF (l_debug = 1) THEN
      trace('After Calling move_resubmit_rows');
   END IF;

   IF  p_business_event_id = WMS_BE_TASK_CONFIRM THEN--DEVICE CONFIRMATION

      IF (l_debug = 1) THEN
         trace('deleting all current error records from WDRH');
      END IF;
      --delete all current error records from WDRH
      DELETE FROM wms_device_requests_hist
	WHERE request_id = p_request_id
	AND status_code ='P'
	AND Nvl(sequence_id,-1) = Nvl(p_sequence_id,nvl(sequence_id, -1))
	AND Nvl(task_id,-1) = Nvl(p_task_trx_id,nvl(task_id, -1))
	AND business_event_id = p_business_event_id ;


      IF (l_debug = 1) THEN
         trace('calling Resubmission for device Confirmation');
      END IF;
      wms_device_confirmation_pub.device_confirmation(
						      l_req_stat
						      ,l_msg_count
						      ,l_msg_data
						      ,p_request_id
						      ,l_successful_row_cnt
						      );

      IF ( l_req_stat <> FND_API.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
   	 trace('device Confirmation returned:Unexpected error:l_msg_count'||l_msg_count||'::l_msg_data:'||l_msg_data);
	 END IF;
	 RAISE FND_API.g_exc_unexpected_error;
       ELSE
	 IF (l_debug = 1) THEN
   	 trace('device Confirmation returned:Success:Number of successful rows ::'||l_successful_row_cnt);
	 END IF;
	 --do not need to commit the txn, since concurrent request does it
      END IF;

    ELSE--other business event
      BEGIN
        SELECT nvl(WCS_ENABLED,'N') into l_wcs_enabled FROM MTL_PARAMETERS
        WHERE ORGANIZATION_ID = (SELECT ORGANIZATION_ID
                               FROM wms_device_requests_hist
                               WHERE request_id = p_request_id
                               AND status_code ='P'
                               AND Nvl(business_event_id,-1) = Nvl(p_business_event_id,-1)
                               AND ROWNUM < 2);
      EXCEPTION
      WHEN OTHERS THEN
        l_wcs_enabled := 'N';
      END;


      FOR l_rec IN x_cur LOOP
	 IF (l_debug = 1) THEN
   	 trace('Resubmitting request '||p_request_id ||', device '||l_rec.dev_id);
	 END IF;
         IF (l_wcs_enabled = 'Y') THEN
                WMS_DEVICE_INTEGRATION_WCS.SYNC_DEVICE_REQUEST(
							p_request_id    => p_request_id,
							p_device_id     => l_rec.dev_id,
							p_resubmit_flag => 'Y',
							x_status_code   =>  l_req_stat,
							x_device_status => l_dev_stat,
							x_status_msg    => l_stat_msg );
         ELSE
                WMS_DEVICE_INTEGRATION_PUB.SYNC_DEVICE_REQUEST(
                                                        p_request_id    => p_request_id,
                                                        p_device_id     => l_rec.dev_id,
                                                        p_resubmit_flag => 'Y',
                                                        x_status_code   =>  l_req_stat,
                                                        x_device_status => l_dev_stat,
                                                        x_status_msg    => l_stat_msg );
         END IF;

	 IF ( l_req_stat <> FND_API.g_ret_sts_success) THEN
	    UPDATE wms_device_requests_hist
	      SET status_code = l_req_stat,
	      status_msg = l_stat_msg
	      WHERE device_id = l_rec.dev_id
	      AND request_id = p_request_id;
	  ELSE
	    UPDATE wms_device_requests_hist
	      SET status_code = 'S'
	      WHERE device_id = l_rec.dev_id
	      AND request_id = p_request_id;
	 END IF;

      END LOOP;

   END IF;

   --finally remove the rows from the request table.

   DELETE FROM wms_device_requests
     WHERE request_id = p_request_id
     AND Nvl(business_event_id,-1) = Nvl(p_business_event_id,-1)
     AND Nvl(sequence_id,-1) = Nvl(p_sequence_id,nvl(sequence_id, -1));

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_RESUBMIT_FAIL');
      FND_MSG_PUB.ADD;
      ROLLBACK TO WMS_DEVICE_REQUESTS;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	l_dev_req_type,
		p_data		=>	l_req_stat
		);
      --this is set to P in the form while making call to concurrent req
      UPDATE wms_device_requests_hist
	SET status_code = 'E',resubmit_date = null
	WHERE request_id = p_request_id
	AND BUSINESS_EVENT_ID =p_business_event_id
	AND status_code = 'P';

      COMMIT;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_RESUBMIT_FAIL');
      FND_MSG_PUB.ADD;
      ROLLBACK TO WMS_DEVICE_REQUESTS;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	l_dev_req_type,
		p_data		=>	l_req_stat
		);

      --this is set to P in the form while making call to concurrent req
      UPDATE wms_device_requests_hist
	SET status_code = 'E',resubmit_date = null
	WHERE request_id = p_request_id
	AND BUSINESS_EVENT_ID =p_business_event_id
	AND status_code = 'P';

      COMMIT;

   WHEN OTHERS THEN
      trace('Resubmit_req SQL error :'||substr(sqlerrm, 1, 240));
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_RESUBMIT_FAIL');
      FND_MSG_PUB.ADD;
      ROLLBACK TO WMS_DEVICE_REQUESTS;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>     l_dev_req_type,
		p_data		=>	l_req_stat
		);
    --this is set to P in the form while making call to concurrent req
      UPDATE wms_device_requests_hist
	SET status_code = 'E',resubmit_date = null
	WHERE request_id = p_request_id
	AND BUSINESS_EVENT_ID =p_business_event_id
	AND status_code = 'P';

      COMMIT;


END RESUBMIT_REQUEST;


PROCEDURE is_device_set_up(p_org_id NUMBER,
			   p_bus_event_id NUMBER DEFAULT NULL,
			   x_return_status OUT NOCOPY VARCHAR2 )
--to set global vaiable WMS_CALLD_EVICE_REQUEST and wms_pick_release_device_request_id
  IS
   l_setup_row_cnt NUMBER:=0;
   l_device_cnt  NUMBER:=0;
   l_request_id NUMBER :=0;
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF p_org_id IS NOT NULL THEN
      BEGIN
	 --Check whether any device exist
	 SELECT 1 INTO l_device_cnt FROM DUAL WHERE exists
	   (SELECT 1
	    FROM wms_devices_b
	    WHERE ORGANIZATION_ID= p_org_id);
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    l_device_cnt:=0;
      END;

      IF l_device_cnt = 0 THEN
	 IF (l_debug = 1) THEN
	    trace(' No device exist in this Org'||p_org_id);
	 END IF;
	 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 RETURN;
       ELSIF p_bus_event_id IS NOT NULL THEN --check in the association table between device and bus_event

      BEGIN
	 SELECT 1 INTO l_setup_row_cnt FROM DUAL WHERE exists
	   (SELECT 1
	    FROM wms_bus_event_devices
	    WHERE business_event_id = p_bus_event_id
	    AND organization_id = p_org_id
	    and business_event_id < 50);


      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    l_setup_row_cnt:=0;
      END;

      IF (l_setup_row_cnt = 0 AND (p_bus_event_id < 50 )) THEN
	 IF (l_debug = 1) THEN
	    trace(' Device Request is not being used for business event='||p_bus_event_id);
	 END IF;
	 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 RETURN;
      END IF;

      END IF ;

   END IF ;
   SELECT wms_device_requests_s.nextval INTO l_request_id FROM dual;
   wms_pkRel_dev_req_id := l_request_id;

   --global parameter wms_call_device_request is used in WMSCRTNB.pls
   IF p_bus_event_id = wms_be_pick_release then
      wms_call_device_request := 1;
    ELSIF p_bus_event_id = wms_be_mo_task_alloc then
      wms_call_device_request := 2;
   END IF;

   IF (l_debug = 1) THEN
      trace('wms_call_device_request:::'||wms_call_device_request);
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

END is_device_set_up;



/* OBSOLETED :this procedure has been moved to WMSPURGS.pls/WMSPURGB.pls */
--call in hte concurrrent program has been changed to use new package
----------------------------------------------------------------------
-- failure x_retcode = 2 x_errbuf = 'ERROR'
-- success x_retcode = 0 x_errbuf = 'NORMAL'
----------------------------------------------------------------------
/*
PROCEDURE purge_wms(	x_errbuf     		OUT	NOCOPY VARCHAR2,
			x_retcode      	OUT	NOCOPY NUMBER,
			p_purge_date 	IN 	DATE,
			p_orgid 			IN		NUMBER,
			p_purge_name 	IN		VARCHAR2 )
  IS
     l_ret boolean;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (p_purge_date IS NULL OR p_orgid IS NULL)THEN
      l_ret := fnd_concurrent.set_completion_status('ERROR', 'WMS_MISS_REQ_PARAMETER');
      x_retcode := 2;
      x_errbuf := 'ERROR';
    ELSE
      delete from wms_device_requests_hist
	where creation_date < p_purge_date and organization_id = p_orgid ;
      delete from wms_lpn_histories
	where creation_date < p_purge_date and organization_id = p_orgid ;
      delete from wms_dispatched_tasks_history
	where creation_date < p_purge_date and organization_id = p_orgid ;
      delete from wms_exceptions
	where creation_date < p_purge_date and organization_id = p_orgid ;
      delete from wms_lpn_process_temp ;

      INSERT INTO mtl_purge_header (
				    purge_id,
				    last_update_date,
				    last_updated_by,
				    last_update_login,
				    creation_date,
				    created_by,
				    purge_date,
				    archive_flag,
				    purge_name,
				    organization_id)
	VALUES (
		mtl_material_transactions_s.NEXTVAL,
		Sysdate,
		FND_GLOBAL.user_id,
		fnd_global.user_id,
		Sysdate,
		FND_GLOBAL.user_id,
		p_purge_date,
		NULL,
		p_purge_name,
		p_orgid );

      l_ret := fnd_concurrent.set_completion_status('NORMAL', 'WMS_PURGE_SUCCESS');
      x_retcode := 0;
   END IF;
END purge_wms;
  */

END WMS_DEVICE_INTEGRATION_PVT;

/
