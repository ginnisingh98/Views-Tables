--------------------------------------------------------
--  DDL for Package Body WMS_DEVICE_CONFIRMATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DEVICE_CONFIRMATION_PUB" AS
/* $Header: WMSDEVCB.pls 120.8.12010000.4 2009/03/05 10:55:27 aditshar ship $ */

-- TASK status IN WDT
l_g_task_loaded                 CONSTANT NUMBER  := 4;
l_g_task_active                 CONSTANT NUMBER  := 9;


TYPE  lpn_lot_quantity_rec   IS  RECORD
  ( lpn_id      NUMBER,
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    lot_number  VARCHAR2(80),
    qty         NUMBER
    );

TYPE lpn_lot_quantity_tbl  IS TABLE OF  lpn_lot_quantity_rec INDEX BY BINARY_INTEGER;
--  PL/SQL TABLE used to store lot_number and qty for passed in lpn_id
t_lpn_lot_qty_table  lpn_lot_quantity_tbl;


-----------------------------------------------------
-- trace
-----------------------------------------------------
PROCEDURE trace(p_msg IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
      inv_trx_util_pub.trace(p_msg, 'WMS_DEVICE_CONFIRMATION_PUB', 9);
END trace;


--this api does not get called when p_transaction_quantity ==0
PROCEDURE validate_child_record(p_relation_id IN NUMBER,
				p_error_on_lot_serial_null IN VARCHAR2,
				p_lot_code IN NUMBER,
				p_serial_code IN NUMBER,
				p_txn_temp_id IN NUMBER,
				P_qty_disc_flag IN NUMBER,
				p_transaction_quantity IN NUMBER,--of main record
				--total qty, might be null in case
				--user picked all suggested and did
				--NOT pass quantity
				x_return_status OUT NOCOPY VARCHAR2) IS

l_lot_code NUMBER:= p_lot_code;
l_serial_code NUMBER := p_serial_code;
l_lot_cnt NUMBER :=0 ;
l_serial_cnt NUMBER;
l_orig_lot_qty NUMBER;--per record in MTLT
l_count_child_rec NUMBER := 0;
l_total_lot_qty NUMBER :=0;--for all record in MTLT corresponding to MMTT

CURSOR child_rec_cursor IS
   SELECT lot_number,lot_qty,serial_number
     FROM wms_device_requests
     WHERE relation_id = p_relation_id
     AND task_id = p_txn_temp_id
     AND business_event_id IN (wms_device_integration_pvt.wms_be_task_confirm,wms_device_integration_pvt.wms_be_load_confirm)
     AND task_summary = 'N';

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF (l_debug = 1) THEN
      trace('Inside validate_child_record');
   END IF;

   SELECT COUNT(*),SUM(lot_qty) INTO l_count_child_rec,l_total_lot_qty
     FROM wms_device_requests
     WHERE relation_id = p_relation_id
     AND task_id = p_txn_temp_id
     AND business_event_id IN (wms_device_integration_pvt.wms_be_task_confirm,wms_device_integration_pvt.wms_be_load_confirm)
     AND task_summary = 'N';

  IF (l_debug = 1) THEN
     trace('l_count_temp::'||l_count_child_rec||' total_lot_qty::'||l_total_lot_qty);
  END IF;

   --in case of qty discrepancy for lot/serial item , child records must exist
   IF l_count_child_rec = 0  AND p_qty_disc_flag <> 0 THEN
      IF (l_debug = 1) THEN
         trace('Error: qty discrepancy and no child rec found');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --make sure that the sum of lot_qty is equal to the transaction_quantiy
   IF l_count_child_rec <> 0 AND p_transaction_quantity IS NOT NULL
     AND p_transaction_quantity <> l_total_lot_qty THEN
      IF (l_debug = 1) THEN
         trace('Error: Total lot_qty is greater than transaction_quantity');
      END IF;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   FOR l_child_rec IN child_rec_cursor LOOP--child records

	IF (l_lot_code >1) THEN--means LOT CONTROLLED

	   IF l_child_rec.lot_number IS NOT NULL THEN
	      SELECT 1 INTO l_lot_cnt FROM dual WHERE exists
		(SELECT lot_number FROM mtl_transaction_lots_temp
		 WHERE transaction_temp_id = p_txn_temp_id
		 AND lot_number = l_child_rec.lot_number );

	      IF l_lot_cnt = 1 then
		 SELECT TRANSACTION_QUANTITY INTO l_orig_lot_qty
		   FROM mtl_transaction_lots_temp
		   WHERE transaction_temp_id = p_txn_temp_id
		   AND lot_number = l_child_rec.lot_number;
	      END IF;
	      --make sure that lot_qty is not more than the allocated for
	      --specific lot
	      IF ( l_lot_cnt = 0 OR l_child_rec.lot_qty > l_orig_lot_qty ) THEN
		 IF (l_debug = 1) THEN
   		 trace('Invalid Lot:Allocated Lot is not chosen or qty is greater');
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LOT');
		 FND_MSG_PUB.ADD;
		 RAISE FND_API.G_EXC_ERROR;
	      END IF;
	    ELSIF p_error_on_lot_serial_null = 'Y' THEN--l_rec.LOT_NUMBER is null
	      IF (l_debug = 1) THEN
   	      trace('Erroring out:Lot info NOT provided in child record');
	      END IF;
	      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LOT');
	      FND_MSG_PUB.ADD;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;

        /* -- Serial Not supported, Will be done later
	   IF (l_serial_code >1 AND l_serial_code<>6) THEN --both lot and serial controlled

	      IF l_child_rec.serial_number IS NOT NULL THEN
		 SELECT 1 INTO l_serial_cnt FROM dual WHERE exists
		   (SELECT fm_serial_number--What if RANGE serials ??
		    FROM mtl_serial_numbers_temp msnt,
		    mtl_transaction_lots_temp mtlt
		    WHERE mtlt.transaction_temp_id = p_txn_temp_id
		    AND   msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
		    AND  msnt.fm_serial_number =  l_child_rec.serial_number);

		 IF (l_serial_cnt = 0)  THEN
		    IF (l_debug = 1) THEN
   		    trace('Invalid Serial:Either allocate_serial_flag IS off FOR the org OR Allocated Serial is not chosen');
		    END IF;
		    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SER');
		    FND_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
		 END IF;
	       ELSIF p_error_on_lot_serial_null = 'Y' THEN --l_child_rec.serial_number IS NULL
		 IF (l_debug = 1) THEN
   		 trace('Erroring out:serial info NOT provided in child record');
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SER');
		 FND_MSG_PUB.ADD;
		 RAISE FND_API.G_EXC_ERROR;
	      END IF;
	   END IF;

	 ELSIF (l_serial_code >1 AND l_serial_code<>6) THEN --serial controlled only

	   IF l_child_rec.serial_number IS NOT NULL THEN
	      SELECT 1 INTO l_serial_cnt FROM dual WHERE exists
		(SELECT fm_serial_number
		 FROM mtl_serial_numbers_temp msnt
		 WHERE msnt.transaction_temp_id = p_txn_temp_id
		 AND msnt.fm_serial_number = l_child_rec.serial_number);

	      IF (l_serial_cnt = 0)  THEN
		 IF (l_debug = 1) THEN
   		 trace('Invalid Serial:Either allocate_serial_flag IS off FOR the org OR Allocated Serial is not chosen');
		 END IF;
		 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SER');
		 FND_MSG_PUB.ADD;
		 RAISE FND_API.G_EXC_ERROR;
	      END IF;
	    ELSIF p_error_on_lot_serial_null = 'Y' THEN --l_child_rec.serial_number IS NULL
	      IF (l_debug = 1) THEN
   	      trace('Erroring out:serial info NOT provided in child record');
	      END IF;
	      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SER');
	      FND_MSG_PUB.ADD;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;

	     */


	END IF;--means LOT CONTROLED

   END LOOP;--for child records

   x_return_status:=FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END validate_child_record;

---************


PROCEDURE populate_history(x_request_id OUT NOCOPY NUMBER)IS

   l_request_id NUMBER;
   l_request_date DATE;
   l_device_id NUMBER;
   l_requested_by NUMBER;
   l_CREATION_DATE  DATE;
   l_CREATED_BY  NUMBER;
   l_LAST_UPDATE_DATE  DATE;
   l_resp_application_id NUMBER;
   l_resp_id NUMBER;
   l_last_updated_by NUMBER ;
   l_status_code VARCHAR2(1);

   l_parent_rec_cnt NUMBER :=0;

   CURSOR tsk_confirm_cursor IS
      SELECT relation_id -- all following are passed by WCS
	, task_id
	, task_summary
	, business_event_id
	, transaction_quantity
	, transfer_sub_code
	, transfer_loc_id
	, lpn_id
	, xfer_lpn_id
	, device_status
	, reason_id
	, organization_id--Its NOT NULL Column
	, status_code
	, status_msg
	, lot_number
	, lot_qty
	, serial_number
	, device_id
	FROM wms_device_requests
	WHERE business_event_id IN (wms_device_integration_pvt.wms_be_load_confirm,wms_device_integration_pvt.wms_be_task_confirm)
	ORDER BY relation_id ASC,task_id ASC, task_summary desc;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SELECT wms_device_requests_s.nextval INTO l_request_id FROM dual;
   IF (l_debug = 1) THEN
      trace('Inside populate_History: New request_id for all records:'||l_request_id);
   END IF;


   FOR l_rec IN tsk_confirm_cursor LOOP

      --get all values for NOT NULL columns of WDRH from hist table, it will
      --remain same for child records AS well

      --get these value only once for the main record which will remain
      --same FOR the child RECORD AS well, since the cursor is ordered by
      --task_summary desc for each relation id and task_id,first will be the main
      --record then will be child records

      IF l_rec.task_summary = 'Y' THEN

	 l_parent_rec_cnt := l_parent_rec_cnt+1;
	 BEGIN
	    SELECT
	      DEVICE_ID
	      ,responsibility_application_id
	      ,responsibility_id
	      INTO
	      l_device_id
	      ,l_resp_application_id
	      ,l_resp_id
	      FROM wms_device_requests_hist
	      WHERE request_id = nvl(l_rec.relation_id,-1)
	      --nvl,to handle ERROR: when WCS does NOT pass relation_id or task_id
	      AND task_id = nvl(l_rec.task_id,-1)
	      AND task_summary = 'Y'
	      AND business_event_id IN (wms_device_integration_pvt.wms_be_pick_release,wms_device_integration_pvt.wms_be_wip_pick_release,wms_device_integration_pvt.wms_be_mo_task_alloc)
	      AND ROWNUM<2;
	 EXCEPTION
	    WHEN no_data_found THEN

	       l_device_id := nvl(l_rec.device_id,-1);
	       l_resp_application_id := -1;
	       l_resp_id := -1;
	       IF (l_debug = 1) THEN
		  trace('Invalid txn_temp_id ::'||l_rec.task_id||'or relation_id::'||l_rec.relation_id);
	       END IF;
	 END;

      END IF;

      IF (l_rec.task_id IS NULL) OR (l_rec.relation_id IS NULL) THEN
	 l_rec.status_code := 'E';
	 l_rec.status_msg := 'Error:Null parent_task_id or task_id';
      END IF;


      INSERT INTO wms_device_requests_hist(request_id
					   , relation_id -- parent_request_id
					   , task_id
					   , business_event_id
					   , transaction_quantity
					   , transfer_sub_code
					   , transfer_loc_id
					   , lpn_id
					   , xfer_lpn_id
					   , device_status
					   , reason_id
					   , task_summary
					   , organization_id
					   , device_id
					   , request_date
					   , requested_by
					   , status_code
					   , status_msg
					   , responsibility_application_id
					   , responsibility_id
					   , creation_date
					   , created_by
					   , last_update_date
					   , last_updated_by
					   , lot_number
					   , lot_qty
					   , serial_number
					   ) VALUES (l_request_id
						     , l_rec.relation_id
						     , l_rec.task_id
						     , l_rec.business_event_id
						     , l_rec.transaction_quantity
						     , l_rec.transfer_sub_code
						     , l_rec.transfer_loc_id
						     , l_rec.lpn_id
						     , l_rec.xfer_lpn_id
						     , l_rec.device_status
						     , l_rec.reason_id
						     , l_rec.task_summary
						     , l_rec.organization_id
						     , l_device_id
						     , SYSDATE
						     , fnd_global.USER_ID
						     , nvl(l_rec.status_code,'E') --Bug#4535546.Added nvl
						     , l_rec.status_msg
						     , l_resp_application_id
						     , l_resp_id
						     , SYSDATE
						     , fnd_global.USER_ID
						     , SYSDATE
						     , fnd_global.USER_ID
						     , l_rec.lot_number
						     , l_rec.lot_qty
						     , l_rec.serial_number
						     );



   END LOOP;
   x_request_id :=l_request_id;
   IF (l_debug = 1) THEN
      trace('populate_History:Total parent rec processed::'||l_parent_rec_cnt);
   END IF;

END populate_history;

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

   END IF;
   FND_MSG_PUB.initialize;
   RETURN l_msg_data;
END GET_MSG_STACK;


PROCEDURE update_wdr_for_error_rec(p_task_id IN NUMBER
				   ,p_relation_id IN NUMBER) IS
l_status_msg VARCHAR2(240);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_status_msg := get_msg_stack;--only last message
                                 --IN the stack
   UPDATE wms_device_requests
     SET status_code = 'E',
     status_msg = l_status_msg
     WHERE  business_event_id IN (wms_device_integration_pvt.wms_be_task_confirm,wms_device_integration_pvt.wms_be_load_confirm)
     AND task_id = p_task_id
     AND relation_id = p_relation_id;

   IF (l_debug = 1) THEN
      trace('ERROR: Current record completed with Error:task_id:'||p_task_id||'::relation_id:'||p_relation_id);
   END IF;
END update_wdr_for_error_rec;




--this api checks for items, lot/serial, qty in picked/allocated LPN and returns appropriate
--value for LPN match
/*
   The following table gives the conditions checked by LPN Match
   and its return values

   Condition                            x_match    x_return_status
   =================================================================
   LPN already picked                       7               E
   LPN location is invalid                  6               E
   LPN SUB is null                         10               E
   LPN already staged for another SO       12               E
   Item/Lot/Revision is not in LPN          5               E
   LPN has multiple items                   2               S

   LPN has requested item but quantity is   4               S
   more that the allocated quantity

   Serial number is not valid for this     11               E
   transaction.
   LPN has requested item with sufficient   8               E
   quantity but LPN content status is
   invalid
   Serial Allocation was requested for the  9               E
   item but it is not allowed/there
   Everything allright and exact quantity   1               S
   match.LPN has only this item
   Everything allright and quantity in LPN  3               S
   is less than requested quantity.LPN has only
   this item

   Although x_match is being set even for error conditions
   it is used by the calling code ONLY in case of success

*/

 PROCEDURE get_lpn_match
     (   p_lpn				IN  NUMBER
	 ,  p_org_id                    IN  NUMBER
	 ,  p_item_id 			IN  NUMBER
	 ,  p_rev 			IN  VARCHAR2
	 ,  p_lot 			IN  VARCHAR2
	 ,  p_qty 			IN  NUMBER
	 ,  p_uom 			IN  VARCHAR2
	 ,  x_match                     OUT NOCOPY NUMBER
	 ,  x_sub 			OUT NOCOPY VARCHAR2
	 ,  x_loc 			OUT NOCOPY VARCHAR2
	 ,  x_qty 			OUT NOCOPY NUMBER
	 ,  x_return_status		OUT NOCOPY VARCHAR2
	 ,  x_msg_count			OUT NOCOPY NUMBER
	 ,  x_msg_data			OUT NOCOPY VARCHAR2
	 ,  p_temp_id 			IN  NUMBER
	 ,  p_wms_installed 		IN  VARCHAR2
	 ,  p_transaction_type_id 	IN  NUMBER
	 ,  p_cost_group_id		IN  NUMBER
	 ,  p_is_sn_alloc		IN  VARCHAR2
	 ,  p_action			IN  NUMBER
	 ,  x_temp_id                   OUT NOCOPY NUMBER
	 ,  x_loc_id                    OUT NOCOPY NUMBER
	 ,  x_lpn_lot_vector            OUT NOCOPY VARCHAR2
	 )

     IS

   l_msg_cnt  NUMBER;
   l_msg_data  VARCHAR2(2000);
   l_return_status VARCHAR2(240);

   l_exist_qty NUMBER;
   l_item_cnt NUMBER;
   l_rev_cnt NUMBER;
   l_lot_cnt NUMBER;
   l_item_cnt2 NUMBER;
   l_cg_cnt NUMBER;

   l_sub VARCHAR2(60);
   l_loc VARCHAR2(60);
   l_loaded NUMBER := 0;
   l_allocate_serial_flag NUMBER := 0;
   l_temp_serial_trans_temp NUMBER := 0;
   l_serial_number VARCHAR2(50);

   l_lpn_qty NUMBER;
   l_lpn_uom VARCHAR2(3);

   l_txn_uom VARCHAR2(3);

   l_primary_uom VARCHAR2(3);
   l_lot_code NUMBER;
   l_serial_code NUMBER;
   l_mmtt_qty NUMBER;

   l_out_temp_id NUMBER:=0;

   l_serial_exist_cnt NUMBER:=0;
   l_total_serial_cnt NUMBER:=0;
   l_so_cnt NUMBER:=0;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_mtlt_lot_number VARCHAR2(80);
   l_mtlt_primary_qty NUMBER;
   l_wlc_quantity NUMBER;
   l_wlc_uom_code VARCHAR2(3);
   l_lot_match NUMBER;
   l_ok_to_process VARCHAR2(5);
   l_is_revision_control VARCHAR2(5);
   l_is_lot_control VARCHAR2(5);
   l_is_serial_control VARCHAR2(5);
   b_is_revision_control BOOLEAN;
   b_is_lot_control  BOOLEAN;
   b_is_serial_control BOOLEAN;
   l_from_lpn VARCHAR2(30);
   l_loc_id NUMBER;
   l_lpn_context NUMBER;

   l_lpn_exists NUMBER;
   l_qoh        NUMBER;
   l_rqoh       NUMBER;
   l_qr         NUMBER;
   l_qs         NUMBER;
   l_att        NUMBER;
   l_atr        NUMBER;
   l_allocated_lpn_id  NUMBER;
   l_table_index    NUMBER := 0;
   l_table_total    NUMBER := 0;
   l_table_count    NUMBER;
   l_lpn_include_lpn  NUMBER;
   l_xfr_sub_code  VARCHAR2(30);
   l_sub_active NUMBER := 0;
   l_loc_active NUMBER := 0;


   CURSOR ser_csr IS
      SELECT serial_number
	FROM   mtl_serial_numbers
	WHERE  lpn_id = p_lpn
	AND    inventory_item_id = p_item_id
	AND    Nvl(lot_number,-999) = Nvl(p_lot,-999);

   CURSOR lot_csr IS
      SELECT
	mtlt.primary_quantity,
	mtlt.lot_number
	FROM
	mtl_transaction_lots_temp mtlt
	WHERE  mtlt.transaction_temp_id = p_temp_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      trace('lpn_match: In lpn Match');
   END IF;

   l_lpn_qty := p_qty;

   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   l_lpn_exists := 0;

   --clear the PL/SQL table each time come in
   t_lpn_lot_qty_table.delete;

   BEGIN

      SELECT  1,
	lpn_context
	INTO  l_lpn_exists,
	l_lpn_context
	FROM  wms_license_plate_numbers wlpn
	WHERE wlpn.organization_id = p_org_id
	AND   wlpn.lpn_id = p_lpn;

   EXCEPTION

      WHEN no_data_found THEN

	 IF (l_debug = 1) THEN
   	 trace('lpn_match: lpn does not exist in org');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_LPN');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
   END;

   IF l_lpn_exists = 0 OR
     p_lpn = 0 OR
     l_lpn_context <> wms_container_pub.lpn_context_inv THEN

      IF (l_debug = 1) THEN
         trace('lpn_match: lpn does not exist in org');
      END IF;
      FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_LPN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   IF (l_debug = 1) THEN
      trace('lpn_match: Checking if lpn has been picked already');
   END IF;

   x_match := 0;

   BEGIN

      SELECT 1
	INTO l_loaded
	FROM dual
	WHERE exists
	( SELECT 1
	  from mtl_material_transactions_temp
	  where transaction_header_id
	  =(SELECT transaction_header_id
	    from mtl_material_transactions_temp
	    WHERE transaction_temp_id=p_temp_id)
	  AND (transfer_lpn_id=p_lpn OR content_lpn_id=p_lpn)
	  AND cost_group_id = p_cost_group_id);

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
	 l_loaded:=0;

   END;

   IF l_loaded > 0 THEN

      x_match := 7;
      FND_MESSAGE.SET_NAME('WMS','WMS_LOADED_ERROR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   -- Check if locator is valid
   IF (l_debug = 1) THEN
      trace('lpn_match: Fetch sub/loc for LPN ');
   END IF;

   BEGIN
-- WMS PJM Integration, Selecting the resolved concatenated segments instead of concatenated segments
      SELECT
	w.subinventory_code,
   INV_PROJECT.GET_LOCSEGS(w.locator_id, w.organization_id),
	w.license_plate_number,
	w.locator_id,
	w.lpn_context
	INTO
	l_sub,
	l_loc,
	l_from_lpn,
	l_loc_id,
	l_lpn_context
	FROM
	wms_license_plate_numbers w
	WHERE
	w.lpn_id = p_lpn
	AND    w.locator_id is not null;

	IF l_sub IS NULL THEN

         -- The calling java code treats this condition as an error

         x_match := 10;
         FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_SUB');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;

      END IF;

      -- bug 2398247
      -- verify if sub is active
      SELECT COUNT(*)
	INTO l_sub_active
	FROM mtl_secondary_inventories
	WHERE Nvl(disable_date, Sysdate+1) > Sysdate
	AND organization_id = p_org_id
	AND secondary_inventory_name = l_sub;

      IF l_sub_active = 0 THEN
	 x_match := 10;
	 FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_SUB');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- verify if locator is active
      SELECT COUNT(*)
	INTO l_loc_active
	FROM mtl_item_locations_kfv
	WHERE Nvl(disable_date, sysdate+1) > sysdate
	AND organization_id = p_org_id
	AND subinventory_code = l_sub
	AND inventory_location_id = l_loc_id;

      IF l_loc_active = 0 THEN

	 x_match := 10;
	 FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_LOC');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;

      END IF;

      x_sub := l_sub;
      x_loc := l_loc;
      x_loc_id := l_loc_id;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
         x_match := 6;
         FND_MESSAGE.SET_NAME('WMS','WMS_TD_LPN_LOC_NOT_FOUND');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;

   END;

   IF (l_debug = 1) THEN
      trace('lpn_match: sub is '||l_sub);
      trace('lpn_match: loc is '||l_loc);
   END IF;

   -- Check if LPN has already been allocated for any Sales order
   -- If LPN has been picked for a sales order then it cannot be picked

   IF (l_debug = 1) THEN
      trace('lpn_match: Checking SO for lpn');
   END IF;

   BEGIN

      SELECT 1
	INTO l_so_cnt
	FROM dual
	WHERE  exists
	(SELECT 1
	 FROM wsh_delivery_details
	 WHERE lpn_id=p_lpn
	 AND organization_id=p_org_id
	 );

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
         l_so_cnt := 0;

   END;

   IF l_so_cnt > 0 THEN

      x_match := 12;
      FND_MESSAGE.SET_NAME('WMS','WMS_LPN_STAGED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   SELECT
     primary_uom_code,
     lot_control_code,
     serial_number_control_code
     INTO
     l_primary_uom,
     l_lot_code,
     l_serial_code
     FROM   mtl_system_items
     WHERE  organization_id = p_org_id
     AND    inventory_item_id = p_item_id;


   SELECT mmtt.transfer_subinventory
     INTO l_xfr_sub_code
     FROM mtl_material_transactions_temp mmtt
     WHERE mmtt.transaction_temp_id = p_temp_id;


   -- Check to see if the item is in the LPN
   IF (l_debug = 1) THEN
      trace('lpn_match: Checking to see if required  item,cg,rev,lot exist in lpn..');
   END IF;

   l_item_cnt := 0;
   IF (l_debug = 1) THEN
      trace('lpn_match: item'||p_item_id||'LPN'||p_lpn || 'Org'||p_org_id||' lot'||p_lot||' Rev'||p_rev);
   END IF;

   BEGIN

      SELECT 1 INTO l_item_cnt FROM DUAL WHERE exists
       ( SELECT 1
	 FROM wms_lpn_contents wlc
	 WHERE wlc.parent_lpn_id =  p_lpn
 	 AND   wlc.organization_id = p_org_id
	 AND   wlc.inventory_item_id = p_item_id
	 AND   Nvl(wlc.revision,'-999') = Nvl(p_rev,Nvl(wlc.revision,'-999')));  --bug 2495592

   EXCEPTION

      -- Item/lot/rev combo does not exist in LPN

      WHEN NO_DATA_FOUND THEN

	 IF (l_debug = 1) THEN
   	 trace('lpn_match: item lot rev combo does not exist');
	 END IF;
	 x_match := 5;
         FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_LPN');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;

   END;

   IF l_item_cnt > 0 AND l_lot_code > 1 THEN
      --Do this only for lot controlled items

      BEGIN

	 SELECT 1 INTO l_item_cnt FROM DUAL WHERE exists
	   ( SELECT 1
	     FROM wms_lpn_contents wlc,
	          mtl_transaction_lots_temp mtlt
	     WHERE wlc.parent_lpn_id =  p_lpn
	     AND   wlc.organization_id = p_org_id
	     AND   wlc.inventory_item_id = p_item_id
	     AND   Nvl(wlc.revision,'-999') = Nvl(p_rev,Nvl(wlc.revision,'-999'))
	     AND   (mtlt.transaction_temp_id = p_temp_id
		    AND   mtlt.lot_number = wlc.lot_number));

      EXCEPTION

	 -- Item/lot/rev combo does not exist in LPN

	 WHEN NO_DATA_FOUND THEN

	    IF (l_debug = 1) THEN
   	    trace('lpn_match:lot rev combo for the item does not exist');
	    END IF;
	    x_match := 5;
	    FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_LOT_LPN');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;

      END;

   END IF;

   -- Item with the correct lot/revision exists in LPN
   IF p_is_sn_alloc = 'Y' AND p_action = 4 THEN
		b_is_serial_control := TRUE;
		l_is_serial_control := 'true';
   ELSE
		b_is_serial_control := FALSE;
		l_is_serial_control := 'false';
   END IF;

   IF l_lot_code > 1 THEN
		b_is_lot_control := TRUE;
		l_is_lot_control := 'true';
   ELSE
		b_is_lot_control := FALSE;
		l_is_lot_control := 'false';
   END IF;

   IF p_rev IS NULL THEN
		b_is_revision_control := FALSE;
		l_is_revision_control := 'false';
   ELSE
		b_is_revision_control := TRUE;
		l_is_revision_control := 'true';
   END IF;

   IF (l_debug = 1) THEN
      trace('lpn_match: is_serial_control:'   || l_is_serial_control);
      trace('lpn_match: is_lot_control:'      || l_is_lot_control);
      trace('lpn_match: is_revision_control:' || l_is_revision_control);
   END IF;

   BEGIN
       select allocated_lpn_id
       into   l_allocated_lpn_id
       from mtl_material_transactions_temp
       where transaction_temp_id = p_temp_id;
   EXCEPTION
       WHEN no_data_found then
	   IF (l_debug = 1) THEN
   	   trace ('lpn_match: transaction does not exist in mmtt');
	   END IF;
	   FND_MESSAGE.SET_NAME('INV','INV_INVALID_TRANSACTION');
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
   END;

   -- clear quantity cache before we create qty tree.
   inv_quantity_tree_pub.clear_quantity_cache;

   -- Check if LPN has items other than the one requested

   IF (l_debug = 1) THEN
      trace('lpn_match: lpn has the requested item ');
   END IF;

   l_item_cnt2 := 0;
   l_lot_cnt := 0;
   l_rev_cnt := 0;
   l_cg_cnt := 0;

   l_item_cnt2 := 0;
   l_lot_cnt := 0;
   l_rev_cnt := 0;
   l_cg_cnt := 0;

   l_lpn_include_lpn := 0;

   SELECT count( distinct inventory_item_id ),
          count( distinct lot_number ),
          count( distinct revision )    ,
          count( distinct cost_group_id )
   INTO   l_item_cnt2,
          l_lot_cnt,
          l_rev_cnt,
          l_cg_cnt
   FROM   wms_lpn_contents
   WHERE  parent_lpn_id =  p_lpn
   AND    organization_id = p_org_id;

   select count(*)
   into   l_lpn_include_lpn
   from   wms_license_plate_numbers
   where  outermost_lpn_id = p_lpn
   and    organization_id = p_org_id;


   IF l_item_cnt2 > 1 OR l_rev_cnt > 1  OR l_lpn_include_lpn > 1 THEN

      -- LPN has multiple items
      -- Such LPN's can be picked but in such cases the user has to
      -- manually confirm the LPN.
      -- No validation for LPN contents in such a case.

      IF (l_debug = 1) THEN
         trace('lpn_match:  lpn has items other than requested item ');
      END IF;

      x_match := 2;

      IF l_lot_code > 1 THEN

	 l_lpn_qty := 0;

	 OPEN lot_csr;
	 LOOP
	    FETCH lot_csr
	      INTO
	      l_mtlt_primary_qty,
	      l_mtlt_lot_number;

	    EXIT WHEN lot_csr%notfound;

	    IF (l_debug = 1) THEN
   	    trace('l_mtlt_lot_number : ' || l_mtlt_lot_number);
   	    trace('l_mtlt_primary_qty: ' || l_mtlt_primary_qty);
	    END IF;


	    IF nvl(l_allocated_lpn_id, 0) = p_lpn THEN
	          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
	          -- in order to get correct att.
		  inv_quantity_tree_pub.update_quantities
			  (  p_api_version_number    =>   1.0
			   , p_init_msg_lst          =>   fnd_api.g_false
			   , x_return_status         =>   l_return_status
			   , x_msg_count             =>   l_msg_cnt
			   , x_msg_data              =>   l_msg_data
			   , p_organization_id       =>   p_org_id
			   , p_inventory_item_id     =>   p_item_id
			   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			   , p_is_revision_control   =>   b_is_revision_control
			   , p_is_lot_control        =>   TRUE
			   , p_is_serial_control     =>   b_is_serial_control
			   , p_revision              =>   nvl(p_rev, NULL)
			   , p_lot_number            =>   l_mtlt_lot_number
			   , p_subinventory_code     =>   l_sub
			   , p_locator_id            =>   l_loc_id
			   , p_primary_quantity      =>   -l_mtlt_primary_qty
			   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			   , x_qoh                   =>   l_qoh
			   , x_rqoh		     =>   l_rqoh
			   , x_qr		     =>   l_qr
			   , x_qs		     =>   l_qs
			   , x_att		     =>   l_att
			   , x_atr		     =>   l_atr
		           , p_lpn_id                =>   p_lpn
		           , p_transfer_subinventory_code => l_xfr_sub_code
	    	   );
	          IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
			IF (l_debug = 1) THEN
   			trace('lpn_match: after update qty tree for lpn l_att:' || l_att||' for lot:'||l_mtlt_lot_number);
			END IF;
		  ELSE
			 IF (l_debug = 1) THEN
   			 trace('lpn_match: calling update qty tree with lpn 1st time failed ');
			 END IF;
			 FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
			 FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.G_EXC_ERROR;
		  END IF;
	       ELSE
	          inv_quantity_tree_pub.update_quantities
			  (  p_api_version_number    =>   1.0
			   , p_init_msg_lst          =>   fnd_api.g_false
			   , x_return_status         =>   l_return_status
			   , x_msg_count             =>   l_msg_cnt
			   , x_msg_data              =>   l_msg_data
			   , p_organization_id       =>   p_org_id
			   , p_inventory_item_id     =>   p_item_id
			   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			   , p_is_revision_control   =>   b_is_revision_control
			   , p_is_lot_control        =>   TRUE
			   , p_is_serial_control     =>   b_is_serial_control
			   , p_revision              =>   nvl(p_rev, NULL)
			   , p_lot_number            =>   l_mtlt_lot_number
			   , p_subinventory_code     =>   l_sub
			   , p_locator_id            =>   l_loc_id
			   , p_primary_quantity      =>   -l_mtlt_primary_qty
			   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			   , x_qoh                   =>   l_qoh
			   , x_rqoh		     =>   l_rqoh
			   , x_qr		     =>   l_qr
			   , x_qs		     =>   l_qs
			   , x_att		     =>   l_att
			   , x_atr		     =>   l_atr
		       --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
		           , p_transfer_subinventory_code => l_xfr_sub_code
	    	   );
	    	  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
			IF (l_debug = 1) THEN
   			trace('lpn_match: after update qty tree without lpn l_att:' || l_att||' for lot:'||l_mtlt_lot_number);
			END IF;
		  ELSE
			 IF (l_debug = 1) THEN
   			 trace('lpn_match: calling update qty tree back without lpn 1st time failed ');
			 END IF;
			 FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
			 FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.G_EXC_ERROR;
		  END IF;

            END IF;

	    inv_quantity_tree_pub.query_quantities
		     ( p_api_version_number    =>   1.0
		     , p_init_msg_lst          =>   fnd_api.g_false
		     , x_return_status         =>   l_return_status
		     , x_msg_count             =>   l_msg_cnt
		     , x_msg_data              =>   l_msg_data
		     , p_organization_id       =>   p_org_id
		     , p_inventory_item_id     =>   p_item_id
		     , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
		     , p_is_revision_control   =>   b_is_revision_control
		     , p_is_lot_control        =>   TRUE
		     , p_is_serial_control     =>   b_is_serial_control
		     , p_demand_source_type_id =>   -9999
		     , p_revision              =>   nvl(p_rev, NULL)
		     , p_lot_number            =>   l_mtlt_lot_number
		     , p_subinventory_code     =>   l_sub
		     , p_locator_id            =>   l_loc_id
		     , x_qoh                   =>   l_qoh
		     , x_rqoh  		       =>   l_rqoh
		     , x_qr		       =>   l_qr
		     , x_qs		       =>   l_qs
		     , x_att		       =>   l_att
		     , x_atr		       =>   l_atr
		     , p_lpn_id                =>   p_lpn
	             , p_transfer_subinventory_code => l_xfr_sub_code
		     );

	    IF (l_return_status = fnd_api.g_ret_sts_success ) THEN

	      IF (l_att > 0) THEN

	        l_table_index := l_table_index + 1;

		IF (l_mtlt_primary_qty >= l_att) THEN

                  IF (l_debug = 1) THEN
                     trace('lpn_match: l_table_index:'||l_table_index||' lot_number:'||l_mtlt_lot_number||' qty: '||l_att);
                  END IF;
		  l_lpn_qty := l_lpn_qty + l_att;

		  t_lpn_lot_qty_table(l_table_index).lpn_id := p_lpn;
		  t_lpn_lot_qty_table(l_table_index).lot_number := l_mtlt_lot_number;
		  t_lpn_lot_qty_table(l_table_index).qty := l_att;

		ELSE
                  IF (l_debug = 1) THEN
                     trace('lpn_match: l_table_index:'||l_table_index||' lot_number:'||l_mtlt_lot_number||' qty: '||l_mtlt_primary_qty);
                  END IF;
		  l_lpn_qty := l_lpn_qty + l_mtlt_primary_qty;

		  t_lpn_lot_qty_table(l_table_index).lpn_id := p_lpn;
		  t_lpn_lot_qty_table(l_table_index).lot_number := l_mtlt_lot_number;
		  t_lpn_lot_qty_table(l_table_index).qty := l_mtlt_primary_qty;

		END IF;

	      ELSE

		 IF (l_debug = 1) THEN
   		 trace('lpn_match: LPN does not have lot ' || l_mtlt_lot_number);
		 END IF;
		 /*trace('lpn_match: l_table_index:'||l_table_index||' lot_number:'||l_mtlt_lot_number||' qty: 0 ');
		 t_lpn_lot_qty_table(l_table_index).lpn_id := p_lpn;
		 t_lpn_lot_qty_table(l_table_index).lot_number := l_mtlt_lot_number;
		 t_lpn_lot_qty_table(l_table_index).qty := l_mtlt_primary_qty;*/

	      END IF;

	    ELSE

		 IF (l_debug = 1) THEN
   		 trace('lpn_match: calling qty tree 1st time failed ');
		 END IF;
		 FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		 FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		 FND_MSG_PUB.ADD;
		 RAISE FND_API.G_EXC_ERROR;

     	    END IF;

     	    IF nvl(l_allocated_lpn_id, 0) = p_lpn THEN
		  --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
		  -- in order to get correct att.
		  inv_quantity_tree_pub.update_quantities
			  (  p_api_version_number    =>   1.0
			   , p_init_msg_lst          =>   fnd_api.g_false
			   , x_return_status         =>   l_return_status
			   , x_msg_count             =>   l_msg_cnt
			   , x_msg_data              =>   l_msg_data
			   , p_organization_id       =>   p_org_id
			   , p_inventory_item_id     =>   p_item_id
			   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			   , p_is_revision_control   =>   b_is_revision_control
			   , p_is_lot_control        =>   TRUE
			   , p_is_serial_control     =>   b_is_serial_control
			   , p_revision              =>   nvl(p_rev, NULL)
			   , p_lot_number            =>   l_mtlt_lot_number
			   , p_subinventory_code     =>   l_sub
			   , p_locator_id            =>   l_loc_id
			   , p_primary_quantity      =>   l_mtlt_primary_qty
			   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			   , x_qoh                   =>   l_qoh
			   , x_rqoh		     =>   l_rqoh
			   , x_qr		     =>   l_qr
			   , x_qs		     =>   l_qs
			   , x_att		     =>   l_att
			   , x_atr		     =>   l_atr
			   , p_lpn_id                =>   p_lpn
		           , p_transfer_subinventory_code => l_xfr_sub_code
		   );
		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		        IF (l_debug = 1) THEN
   		        trace('lpn_match: after update qty tree back for lpn l_att:' || l_att||' for lot:'||l_mtlt_lot_number);
		        END IF;
		  ELSE
		         IF (l_debug = 1) THEN
   		         trace('lpn_match: calling update qty tree back with lpn 1st time failed ');
		         END IF;
			 FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
			 FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
			 FND_MSG_PUB.ADD;
		         RAISE FND_API.G_EXC_ERROR;
		  END IF;
	       ELSE
		  inv_quantity_tree_pub.update_quantities
			  (  p_api_version_number    =>   1.0
			   , p_init_msg_lst          =>   fnd_api.g_false
			   , x_return_status         =>   l_return_status
			   , x_msg_count             =>   l_msg_cnt
			   , x_msg_data              =>   l_msg_data
			   , p_organization_id       =>   p_org_id
			   , p_inventory_item_id     =>   p_item_id
			   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			   , p_is_revision_control   =>   b_is_revision_control
			   , p_is_lot_control        =>   TRUE
			   , p_is_serial_control     =>   b_is_serial_control
			   , p_revision              =>   nvl(p_rev, NULL)
			   , p_lot_number            =>   l_mtlt_lot_number
			   , p_subinventory_code     =>   l_sub
			   , p_locator_id            =>   l_loc_id
			   , p_primary_quantity      =>   l_mtlt_primary_qty
			   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			   , x_qoh                   =>   l_qoh
			   , x_rqoh		     =>   l_rqoh
			   , x_qr		     =>   l_qr
			   , x_qs		     =>   l_qs
			   , x_att		     =>   l_att
			   , x_atr		     =>   l_atr
		       --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
		           , p_transfer_subinventory_code => l_xfr_sub_code
		   );
		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
			IF (l_debug = 1) THEN
   			trace('lpn_match: after update qty tree back without lpn l_att:' || l_att||' for lot:'||l_mtlt_lot_number);
			END IF;
		  ELSE
			 IF (l_debug = 1) THEN
   			 trace('lpn_match: calling update qty tree back without lpn 1st time failed ');
			 END IF;
			 FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
			 FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.G_EXC_ERROR;
		  END IF;
           END IF;

	 END LOOP;
	 CLOSE lot_csr;

       ELSIF p_is_sn_alloc = 'Y' AND p_action = 4 THEN

	       IF (l_debug = 1) THEN
   	       trace('lpn_match: SN control and SN allocation on');
	       END IF;

	       SELECT COUNT(fm_serial_number)
		 INTO   l_serial_exist_cnt
		 FROM   mtl_serial_numbers_temp msnt
		 WHERE  msnt.transaction_temp_id = p_temp_id
		 AND    msnt.fm_serial_number IN
		 ( SELECT serial_number
		   FROM   mtl_serial_numbers
		   WHERE  lpn_id = p_lpn
		   AND    inventory_item_id = p_item_id
		   AND    Nvl(revision, '-999') = Nvl(p_rev, '-999')
		   );

	       IF (l_debug = 1) THEN
   	       trace('lpn_match: SN exist count'||l_serial_exist_cnt);
	       END IF;

	       IF ( l_serial_exist_cnt = 0 ) THEN
		  IF (l_debug = 1) THEN
   		  trace('lpn_match: LPN does not have the allocated serials ');
		  END IF;
		  -- Serial numbers missing for the transaction
		  x_match := 9;
		  FND_MESSAGE.SET_NAME('INV','INV_INT_SERMISEXP');
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;


	       SELECT COUNT(fm_serial_number)
		 INTO   l_total_serial_cnt
		 FROM   mtl_serial_numbers_temp msnt,
		 mtl_transaction_lots_temp mtlt
		 WHERE  mtlt.transaction_temp_id = p_temp_id
		 AND    msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

	       IF (l_debug = 1) THEN
   	       trace('lpn_match: SN tot count'||l_total_serial_cnt);
	       END IF;
	       IF ( l_total_serial_cnt > l_serial_exist_cnt ) THEN
		  IF (l_debug = 1) THEN
   		  trace('lpn_match: LPN has less');
		  END IF;
		  l_lpn_qty := l_serial_exist_cnt;

	       END IF;

       ELSE -- Plain item OR REVISION controlled item

	       IF (l_debug = 1) THEN
   	       trace('lpn_match: Getting total qty in user entered uom..');
	       END IF;

	       IF nvl(l_allocated_lpn_id, 0) = p_lpn THEN
		  --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
		  -- in order to get correct att.
			  inv_quantity_tree_pub.update_quantities
				  (  p_api_version_number    =>   1.0
				   , p_init_msg_lst          =>   fnd_api.g_false
				   , x_return_status         =>   l_return_status
				   , x_msg_count             =>   l_msg_cnt
				   , x_msg_data              =>   l_msg_data
				   , p_organization_id       =>   p_org_id
				   , p_inventory_item_id     =>   p_item_id
				   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
				   , p_is_revision_control   =>   b_is_revision_control
				   , p_is_lot_control        =>   FALSE
				   , p_is_serial_control     =>   b_is_serial_control
				   , p_revision              =>   nvl(p_rev, NULL)
				   , p_lot_number            =>   null
				   , p_subinventory_code     =>   l_sub
				   , p_locator_id            =>   l_loc_id
				   , p_primary_quantity      =>   -p_qty
				   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
				   , x_qoh                   =>   l_qoh
				   , x_rqoh		     =>   l_rqoh
				   , x_qr		     =>   l_qr
				   , x_qs		     =>   l_qs
				   , x_att		     =>   l_att
				   , x_atr		     =>   l_atr
				   , p_lpn_id                =>   p_lpn
		                   , p_transfer_subinventory_code => l_xfr_sub_code
			   );
			  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
			     IF (l_debug = 1) THEN
   			     trace('lpn_match: update qty tree with lpn 2nd time: l_att:' || l_att);
			     END IF;
			   ELSE
			     IF (l_debug = 1) THEN
   			     trace('lpn_match: calling update qty tree with lpn 2nd time failed ');
			     END IF;
			     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
			     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
			     FND_MSG_PUB.ADD;
				 RAISE FND_API.G_EXC_ERROR;
			  END IF;
		  ELSE
			  inv_quantity_tree_pub.update_quantities
				  (  p_api_version_number    =>   1.0
				   , p_init_msg_lst          =>   fnd_api.g_false
				   , x_return_status         =>   l_return_status
				   , x_msg_count             =>   l_msg_cnt
				   , x_msg_data              =>   l_msg_data
				   , p_organization_id       =>   p_org_id
				   , p_inventory_item_id     =>   p_item_id
				   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
				   , p_is_revision_control   =>   b_is_revision_control
				   , p_is_lot_control        =>   FALSE
				   , p_is_serial_control     =>   b_is_serial_control
				   , p_revision              =>   nvl(p_rev, NULL)
				   , p_lot_number            =>   null
				   , p_subinventory_code     =>   l_sub
				   , p_locator_id            =>   l_loc_id
				   , p_primary_quantity      =>   -p_qty
				   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
				   , x_qoh                   =>   l_qoh
				   , x_rqoh		     =>   l_rqoh
				   , x_qr		     =>   l_qr
				   , x_qs		     =>   l_qs
				   , x_att		     =>   l_att
				   , x_atr		     =>   l_atr
			       --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
		                   , p_transfer_subinventory_code => l_xfr_sub_code
			   );
			  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
			     IF (l_debug = 1) THEN
   			     trace('lpn_match: update qty tree without lpn 2nd time:l_att:'||l_att);
			     END IF;
			   ELSE
			     IF (l_debug = 1) THEN
   			     trace('lpn_match: calling update qty tree back without lpn 2nd time failed ');
			     END IF;
			     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
			     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
			     FND_MSG_PUB.ADD;
			     RAISE FND_API.G_EXC_ERROR;
			  END IF;

                 END IF;

		 inv_quantity_tree_pub.query_quantities
				     ( p_api_version_number    =>   1.0
				     , p_init_msg_lst          =>   fnd_api.g_false
				     , x_return_status         =>   l_return_status
				     , x_msg_count             =>   l_msg_cnt
				     , x_msg_data              =>   l_msg_data
				     , p_organization_id       =>   p_org_id
				     , p_inventory_item_id     =>   p_item_id
				     , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
				     , p_is_revision_control   =>   b_is_revision_control
				     , p_is_lot_control        =>   FALSE
				     , p_is_serial_control     =>   b_is_serial_control
				     , p_demand_source_type_id =>   -9999
				     , p_revision              =>   nvl(p_rev, NULL)
				     , p_lot_number            =>   null
				     , p_subinventory_code     =>   l_sub
				     , p_locator_id            =>   l_loc_id
				     , x_qoh                   =>   l_qoh
				     , x_rqoh  		       =>   l_rqoh
				     , x_qr		       =>   l_qr
				     , x_qs		       =>   l_qs
				     , x_att		       =>   l_att
				     , x_atr		       =>   l_atr
				     , p_lpn_id                =>   p_lpn
		                     , p_transfer_subinventory_code => l_xfr_sub_code
				     );

	    IF (l_return_status = fnd_api.g_ret_sts_success ) THEN

		l_lpn_qty := l_att;

	    ELSE

	       IF (l_debug = 1) THEN
   	       trace('lpn_match: calling qty tree 2nd time failed ');
	       END IF;
	       FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
	       FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
	       FND_MSG_PUB.add;
	       RAISE FND_API.G_EXC_ERROR;

	    END IF;

	    IF nvl(l_allocated_lpn_id, 0) = p_lpn THEN
		  --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
		  -- in order to get correct att.
		  inv_quantity_tree_pub.update_quantities
			  (  p_api_version_number    =>   1.0
			   , p_init_msg_lst          =>   fnd_api.g_false
			   , x_return_status         =>   l_return_status
			   , x_msg_count             =>   l_msg_cnt
			   , x_msg_data              =>   l_msg_data
			   , p_organization_id       =>   p_org_id
			   , p_inventory_item_id     =>   p_item_id
			   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			   , p_is_revision_control   =>   b_is_revision_control
			   , p_is_lot_control        =>   FALSE
			   , p_is_serial_control     =>   b_is_serial_control
			   , p_revision              =>   nvl(p_rev, NULL)
			   , p_lot_number            =>   null
			   , p_subinventory_code     =>   l_sub
			   , p_locator_id            =>   l_loc_id
			   , p_primary_quantity      =>   p_qty
			   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			   , x_qoh                   =>   l_qoh
			   , x_rqoh		     =>   l_rqoh
			   , x_qr		     =>   l_qr
			   , x_qs		     =>   l_qs
			   , x_att		     =>   l_att
			   , x_atr		     =>   l_atr
			   , p_lpn_id                =>   p_lpn
		           , p_transfer_subinventory_code => l_xfr_sub_code
		   );
		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: update qty tree back with lpn 2nd time: l_att:' || l_att);
		     END IF;
		   ELSE
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: calling update qty tree with lpn 2nd time failed ');
		     END IF;
		     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;
	    ELSE
		  inv_quantity_tree_pub.update_quantities
			  (  p_api_version_number    =>   1.0
			   , p_init_msg_lst          =>   fnd_api.g_false
			   , x_return_status         =>   l_return_status
			   , x_msg_count             =>   l_msg_cnt
			   , x_msg_data              =>   l_msg_data
			   , p_organization_id       =>   p_org_id
			   , p_inventory_item_id     =>   p_item_id
			   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			   , p_is_revision_control   =>   b_is_revision_control
			   , p_is_lot_control        =>   FALSE
			   , p_is_serial_control     =>   b_is_serial_control
			   , p_revision              =>   nvl(p_rev, NULL)
			   , p_lot_number            =>   null
			   , p_subinventory_code     =>   l_sub
			   , p_locator_id            =>   l_loc_id
			   , p_primary_quantity      =>   p_qty
			   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			   , x_qoh                   =>   l_qoh
			   , x_rqoh		     =>   l_rqoh
			   , x_qr		     =>   l_qr
			   , x_qs		     =>   l_qs
			   , x_att		     =>   l_att
			   , x_atr		     =>   l_atr
		       --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
		           , p_transfer_subinventory_code => l_xfr_sub_code
		   );
		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: update qty tree back without lpn 2nd time:l_att:'||l_att);
		     END IF;
		   ELSE
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: calling update qty tree back without lpn 2nd time failed ');
		     END IF;
		     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;

            END IF;

      END IF;

    ELSE

	 -- LPN has just the item requested
	 -- See if quantity/details it has will match the quantity allocated
	 -- Find out if the item is lot/serial controlled and UOM of item
	 -- and compare with transaction details

	 IF (l_debug = 1) THEN
   	 trace('lpn_match:  lpn has only the requested item ');
	 END IF;

	 SELECT
	   primary_quantity,
	   transaction_uom
	   INTO
	   l_mmtt_qty,
	   l_txn_uom
	   FROM   mtl_material_transactions_temp
	   WHERE  transaction_temp_id = p_temp_id;


	 -- If item is lot controlled then validate the lots

	 IF l_lot_code > 1 THEN

	    IF (l_debug = 1) THEN
   	    trace('lpn_match:  item is lot controlled' );
	    END IF;

	    -- If item is also serial controlled and serial allocation is
	    -- on then count the number of serials allocated which exist
	    -- in the LPN.
	    -- If the count is 0 then raise an error

	    IF p_is_sn_alloc = 'Y' AND p_action = 4 THEN

	       IF (l_debug = 1) THEN
   	       trace('lpn_match: SN control and SN allocation on');
	       END IF;

	       SELECT COUNT(fm_serial_number)
		 INTO   l_serial_exist_cnt
		 FROM
		 mtl_serial_numbers_temp msnt,
		 mtl_transaction_lots_temp mtlt
		 WHERE  mtlt.transaction_temp_id = p_temp_id
		 AND    msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
		 AND    msnt.fm_serial_number IN
		 (	SELECT serial_number
			FROM   mtl_serial_numbers
			WHERE  lpn_id = p_lpn
			AND    inventory_item_id = p_item_id
			AND    Nvl(revision, '-999') = Nvl(p_rev, '-999')
			);

	       IF (l_debug = 1) THEN
   	       trace('lpn_match: SN exist count'||l_serial_exist_cnt);
	       END IF;

	       IF ( l_serial_exist_cnt = 0 ) THEN

		  IF (l_debug = 1) THEN
   		  trace('lpn_match: No serial allocations have occured or LPN does not have the allocated serials ');
		  END IF;
		  -- Serial numbers missing for the transaction
		  x_match := 9;
		  FND_MESSAGE.SET_NAME('INV','INV_INT_SERMISEXP');
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;

	       END IF;

	    END IF;

	    -- Check whether the Lots allocated are all in the LPN
	    -- An LPN can have many lots and items/revisions, check if the
	    -- lots allocated for the item exist in the LPN and if any of
	    -- them has quantity less/more than what was suggested.

	    IF (l_debug = 1) THEN
   	    trace( 'lpn_match: Check whether the LPN has any lot whose quantity exceeds allocated quantity');
	    END IF;
	    l_lpn_qty := 0;

	    OPEN lot_csr;
	    LOOP
	       FETCH lot_csr
		 INTO
		 l_mtlt_primary_qty,
		 l_mtlt_lot_number;

	       EXIT WHEN lot_csr%notfound;

	       l_lot_match := 0;
	       IF (l_debug = 1) THEN
   	       trace('lpn_match: l_mtlt_lot_number : ' || l_mtlt_lot_number);
   	       trace('lpn_match: l_mtlt_primary_qty: ' || l_mtlt_primary_qty);
	       END IF;


	       l_lot_cnt := l_lot_cnt - 1;


	       IF nvl(l_allocated_lpn_id, 0) = p_lpn THEN
		  --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
		  -- in order to get correct att.
		  inv_quantity_tree_pub.update_quantities
		    (  p_api_version_number    =>   1.0
		       , p_init_msg_lst          =>   fnd_api.g_false
		       , x_return_status         =>   l_return_status
		       , x_msg_count             =>   l_msg_cnt
		       , x_msg_data              =>   l_msg_data
		       , p_organization_id       =>   p_org_id
		       , p_inventory_item_id     =>   p_item_id
		       , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
		       , p_is_revision_control   =>   b_is_revision_control
		       , p_is_lot_control        =>   TRUE
		       , p_is_serial_control     =>   b_is_serial_control
		       , p_revision              =>   nvl(p_rev, NULL)
		       , p_lot_number            =>   l_mtlt_lot_number
		       , p_subinventory_code     =>   l_sub
		       , p_locator_id            =>   l_loc_id
		       , p_primary_quantity      =>   -l_mtlt_primary_qty
		       , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
		       , x_qoh                   =>   l_qoh
		       , x_rqoh		     =>   l_rqoh
		       , x_qr		     =>   l_qr
		       , x_qs		     =>   l_qs
		       , x_att		     =>   l_att
		       , x_atr		     =>   l_atr
		       , p_lpn_id                =>   p_lpn
		       , p_transfer_subinventory_code => l_xfr_sub_code
		    );
		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: update qty tree 3rd time for lpn l_att:'||l_att||' for lot:'||l_mtlt_lot_number);
		     END IF;
		   ELSE
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: calling update qty tree with lpn 3rd time failed ');
		     END IF;
		     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;
		ELSE
		  inv_quantity_tree_pub.update_quantities
		    (  p_api_version_number    =>   1.0
		       , p_init_msg_lst          =>   fnd_api.g_false
		       , x_return_status         =>   l_return_status
		       , x_msg_count             =>   l_msg_cnt
		       , x_msg_data              =>   l_msg_data
		       , p_organization_id       =>   p_org_id
		       , p_inventory_item_id     =>   p_item_id
		       , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
		       , p_is_revision_control   =>   b_is_revision_control
		       , p_is_lot_control        =>   TRUE
		       , p_is_serial_control     =>   b_is_serial_control
		       , p_revision              =>   nvl(p_rev, NULL)
		       , p_lot_number            =>   l_mtlt_lot_number
		       , p_subinventory_code     =>   l_sub
		       , p_locator_id            =>   l_loc_id
		       , p_primary_quantity      =>   -l_mtlt_primary_qty
		       , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
		       , x_qoh                   =>   l_qoh
		       , x_rqoh		     =>   l_rqoh
		       , x_qr		     =>   l_qr
		       , x_qs		     =>   l_qs
		       , x_att		     =>   l_att
		       , x_atr		     =>   l_atr
		       --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
		       , p_transfer_subinventory_code => l_xfr_sub_code
		    );
		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: after update without lpn 3rd time l_att:'|| l_att||' for lot:'||l_mtlt_lot_number);
		     END IF;
		   ELSE
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: calling update qty tree back 3rd time without lpn 3rd time failed ');
		     END IF;
		     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;

	       END IF;

	       inv_quantity_tree_pub.query_quantities
		 ( p_api_version_number    =>   1.0
		   , p_init_msg_lst          =>   fnd_api.g_false
		   , x_return_status         =>   l_return_status
		   , x_msg_count             =>   l_msg_cnt
		   , x_msg_data              =>   l_msg_data
		   , p_organization_id       =>   p_org_id
		   , p_inventory_item_id     =>   p_item_id
		   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
		   , p_is_revision_control   =>   b_is_revision_control
		   , p_is_lot_control        =>   TRUE
		   , p_is_serial_control     =>   b_is_serial_control
		   , p_demand_source_type_id =>   -9999
		   , p_revision              =>   nvl(p_rev, NULL)
		   , p_lot_number            =>   l_mtlt_lot_number
		   , p_subinventory_code     =>   l_sub
		   , p_locator_id            =>   l_loc_id
		   , x_qoh                   =>   l_qoh
		   , x_rqoh  		       =>   l_rqoh
		   , x_qr		       =>   l_qr
		   , x_qs		       =>   l_qs
		   , x_att		       =>   l_att
		   , x_atr		       =>   l_atr
		 , p_lpn_id                =>   p_lpn
		 , p_transfer_subinventory_code => l_xfr_sub_code
		 );

	       IF (l_return_status = fnd_api.g_ret_sts_success ) THEN

		  l_lot_match := 1;

		  IF (l_att > 0) THEN

		     l_table_index := l_table_index + 1;

		     IF (l_mtlt_primary_qty >= l_att) THEN

			l_lpn_qty := l_lpn_qty + l_att;

			IF (l_debug = 1) THEN
   			trace('lpn_match: l_table_index:'||l_table_index||' lot_number:'||l_mtlt_lot_number||' qty:'||l_att);
			END IF;
			t_lpn_lot_qty_table(l_table_index).lpn_id := p_lpn;
			t_lpn_lot_qty_table(l_table_index).lot_number := l_mtlt_lot_number;
			t_lpn_lot_qty_table(l_table_index).qty := l_att;

		      ELSE

			l_lpn_qty := l_lpn_qty + l_mtlt_primary_qty;

			IF (l_debug = 1) THEN
   			trace('lpn_match: l_table_index:'||l_table_index||' lot_number:'||l_mtlt_lot_number||' qty:'||l_mtlt_primary_qty);
			END IF;
			t_lpn_lot_qty_table(l_table_index).lpn_id := p_lpn;
			t_lpn_lot_qty_table(l_table_index).lot_number := l_mtlt_lot_number;
			t_lpn_lot_qty_table(l_table_index).qty := l_mtlt_primary_qty;

		     END IF;

		   ELSE

		     IF (l_debug = 1) THEN
   		     trace('lpn_match: LPN does not have lot ' || l_mtlt_lot_number);
		     END IF;

		     /*trace('lpn_match: l_table_index:'||l_table_index||' lot_number:'||l_mtlt_lot_number||' qty:0');
		     t_lpn_lot_qty_table(l_table_index).lpn_id := p_lpn;
		       t_lpn_lot_qty_table(l_table_index).lot_number := l_mtlt_lot_number;
		       t_lpn_lot_qty_table(l_table_index).qty := 0;	*/

		       IF x_match <> 4 THEN

			  x_match := 3;

		       END IF;

		       l_lot_match := 0;

		       l_lot_cnt := l_lot_cnt + 1;


		  END IF;

		ELSE

		  IF (l_debug = 1) THEN
   		  trace('lpn_match: calling qty tree 3rd time failed ');
		  END IF;
		  FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		  FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		  FND_MSG_PUB.add;
		  RAISE FND_API.G_EXC_ERROR;

	       END IF;

	       IF l_lot_match <> 0 AND x_match <> 4 THEN

		  IF l_mtlt_primary_qty < l_att THEN

		     IF (l_debug = 1) THEN
   		     trace('lpn_match: Qty in LPN for lot ' || l_mtlt_lot_number || ' more than transaction qty for that lot');
		     END IF;
		     x_match := 4;

		   ELSIF  l_mtlt_primary_qty > l_att THEN
		     if l_qoh = l_att then
			IF (l_debug = 1) THEN
   			trace('lpn_match: Qty in LPN for lot ' || l_mtlt_lot_number || ' less than transaction qty for that lot');
			END IF;
			x_match := 3;
                      else
			IF (l_debug = 1) THEN
   			trace('lpn_match: Qty in LPN for lot ' || l_mtlt_lot_number || ' less than transaction qty for that lot and lpn is for multiple task');
			END IF;
			x_match := 4;
		     end if;

		   ELSE

		     IF x_match <> 3 THEN

			IF (l_debug = 1) THEN
   			trace('lpn_match: qty in LPN for lot ' || l_mtlt_lot_number || ' equal to transaction qty for that lot');
			END IF;
			if l_qoh = l_att then
		            IF (l_debug = 1) THEN
   		            trace('lpn_match: lpn qoh is equal to att. Exact match');
		            END IF;
			    x_match := 1;
			 else
			   IF (l_debug = 1) THEN
   			   trace('lpn_match: lpn qoh is great than att. part of lpn is match');
			   END IF;
			   x_match := 4;
			end if;
		     END IF;

		  END IF;

	       END IF;

	       IF nvl(l_allocated_lpn_id, 0) = p_lpn THEN
		  --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
		  -- in order to get correct att.
		  inv_quantity_tree_pub.update_quantities
			  (  p_api_version_number    =>   1.0
			   , p_init_msg_lst          =>   fnd_api.g_false
			   , x_return_status         =>   l_return_status
			   , x_msg_count             =>   l_msg_cnt
			   , x_msg_data              =>   l_msg_data
			   , p_organization_id       =>   p_org_id
			   , p_inventory_item_id     =>   p_item_id
			   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			   , p_is_revision_control   =>   b_is_revision_control
			   , p_is_lot_control        =>   TRUE
			   , p_is_serial_control     =>   b_is_serial_control
			   , p_revision              =>   nvl(p_rev, NULL)
			   , p_lot_number            =>   l_mtlt_lot_number
			   , p_subinventory_code     =>   l_sub
			   , p_locator_id            =>   l_loc_id
			   , p_primary_quantity      =>   l_mtlt_primary_qty
			   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			   , x_qoh                   =>   l_qoh
			   , x_rqoh		     =>   l_rqoh
			   , x_qr		     =>   l_qr
			   , x_qs		     =>   l_qs
			   , x_att		     =>   l_att
			   , x_atr		     =>   l_atr
			   , p_lpn_id                =>   p_lpn
		           , p_transfer_subinventory_code => l_xfr_sub_code
		    );
		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: update qty tree back 3rd time for lpn l_att:'||l_att||' for lot:'||l_mtlt_lot_number);
		     END IF;
		   ELSE
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: calling update qty tree with lpn 3rd time failed ');
		     END IF;
		     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;
		ELSE
		  inv_quantity_tree_pub.update_quantities
		    (  p_api_version_number    =>   1.0
			   , p_init_msg_lst          =>   fnd_api.g_false
			   , x_return_status         =>   l_return_status
			   , x_msg_count             =>   l_msg_cnt
			   , x_msg_data              =>   l_msg_data
			   , p_organization_id       =>   p_org_id
			   , p_inventory_item_id     =>   p_item_id
			   , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			   , p_is_revision_control   =>   b_is_revision_control
			   , p_is_lot_control        =>   TRUE
			   , p_is_serial_control     =>   b_is_serial_control
			   , p_revision              =>   nvl(p_rev, NULL)
			   , p_lot_number            =>   l_mtlt_lot_number
			   , p_subinventory_code     =>   l_sub
			   , p_locator_id            =>   l_loc_id
			   , p_primary_quantity      =>   l_mtlt_primary_qty
			   , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			   , x_qoh                   =>   l_qoh
			   , x_rqoh		     =>   l_rqoh
			   , x_qr		     =>   l_qr
			   , x_qs		     =>   l_qs
			   , x_att		     =>   l_att
			   , x_atr		     =>   l_atr
		       --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
		           , p_transfer_subinventory_code => l_xfr_sub_code
		   );
		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: after update qty tree back without lpn 3rd time l_att:'|| l_att||' for lot:'||l_mtlt_lot_number);
		     END IF;
		   ELSE
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: calling update qty tree back without lpn 3rd time failed ');
		     END IF;
		     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;

	       END IF;

	    END LOOP;
	    CLOSE lot_csr;

	    IF l_lot_cnt > 0 THEN

	       x_match := 4;

	    END IF;

	    -- Now that all the lots have been validated, check whether the serial
	    -- numbers allocated match the ones in the lpn.

	    IF p_is_sn_alloc = 'Y' AND p_action = 4 AND ( x_match = 1 OR x_match = 3 ) THEN

	       SELECT COUNT(fm_serial_number)
		 INTO   l_total_serial_cnt
		 FROM   mtl_serial_numbers_temp msnt,
		 mtl_transaction_lots_temp mtlt
		 WHERE  mtlt.transaction_temp_id = p_temp_id
		 AND    msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

	       IF (l_debug = 1) THEN
   	       trace('lpn_match: SN tot count'||l_total_serial_cnt);
	       END IF;
	       IF ( l_total_serial_cnt = l_serial_exist_cnt ) THEN

		  IF (l_debug = 1) THEN
   		  trace('lpn_match: LPN matches exactly');
		  END IF;
               x_match := 1;

		ELSIF ( l_total_serial_cnt > l_serial_exist_cnt ) THEN

		  IF (l_debug = 1) THEN
   		  trace('lpn_match: LPN has less');
		  END IF;
		  x_match := 3;

		ELSE

		  IF (l_debug = 1) THEN
   		  trace('lpn_match: LPN has extra serials');
		  END IF;
		  x_match := 4;

	       END IF;

	    END IF;


	  ELSE -- Item is not lot controlled

		  IF (l_debug = 1) THEN
   		  trace('lpn_match: Not Lot controlled ..');
		  END IF;
		  -- Check serial numbers if serial controlled and serial
		  -- allocation is turned on

		  IF p_is_sn_alloc = 'Y' AND p_action = 4 THEN

		     IF (l_debug = 1) THEN
   		     trace('lpn_match: SN control and SN allocation on');
		     END IF;

		     SELECT COUNT(fm_serial_number)
		       INTO   l_serial_exist_cnt
		       FROM   mtl_serial_numbers_temp msnt
		       WHERE  msnt.transaction_temp_id = p_temp_id
		       AND    msnt.fm_serial_number IN
		       ( SELECT serial_number
			 FROM   mtl_serial_numbers
			 WHERE  lpn_id = p_lpn
			 AND    inventory_item_id = p_item_id
			 AND    Nvl(revision, '-999') = Nvl(p_rev, '-999')
			 );

		     IF (l_debug = 1) THEN
   		     trace('lpn_match: SN exist count'||l_serial_exist_cnt);
		     END IF;

		     IF ( l_serial_exist_cnt = 0 ) THEN
			IF (l_debug = 1) THEN
   			trace('lpn_match: LPN does not have the allocated serials ');
			END IF;
			-- Serial numbers missing for the transaction
			x_match := 9;
			FND_MESSAGE.SET_NAME('INV','INV_INT_SERMISEXP');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		     END IF;


		  END IF;

		  -- Get qty
		  IF (l_debug = 1) THEN
   		  trace('lpn_match:  get lpn quantity ');
		  END IF;


		  IF nvl(l_allocated_lpn_id, 0) = p_lpn THEN
		     --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
		     -- in order to get correct att.
		     inv_quantity_tree_pub.update_quantities
		       (  p_api_version_number    =>   1.0
			  , p_init_msg_lst          =>   fnd_api.g_false
			  , x_return_status         =>   l_return_status
			  , x_msg_count             =>   l_msg_cnt
			  , x_msg_data              =>   l_msg_data
			  , p_organization_id       =>   p_org_id
			  , p_inventory_item_id     =>   p_item_id
			  , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			  , p_is_revision_control   =>   b_is_revision_control
			  , p_is_lot_control        =>   FALSE
			  , p_is_serial_control     =>   b_is_serial_control
			  , p_revision              =>   nvl(p_rev, NULL)
			  , p_lot_number            =>   null
			  , p_subinventory_code     =>   l_sub
			  , p_locator_id            =>   l_loc_id
			  , p_primary_quantity      =>   -l_mmtt_qty
			  , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			  , x_qoh                   =>   l_qoh
			  , x_rqoh		     =>   l_rqoh
			  , x_qr		     =>   l_qr
			  , x_qs		     =>   l_qs
			  , x_att		     =>   l_att
		          , x_atr		     =>   l_atr
		          , p_lpn_id                =>   p_lpn
		          , p_transfer_subinventory_code => l_xfr_sub_code
		       );
		     IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
			IF (l_debug = 1) THEN
   			trace('lpn_match: update qty tree with lpn 4th time: l_att:' || l_att);
			END IF;
		      ELSE
			IF (l_debug = 1) THEN
   			trace('lpn_match: calling update qty tree with lpn 4th time failed ');
			END IF;
			FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
			FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		     END IF;
		   ELSE
		     inv_quantity_tree_pub.update_quantities
		       (  p_api_version_number    =>   1.0
			  , p_init_msg_lst          =>   fnd_api.g_false
			  , x_return_status         =>   l_return_status
			  , x_msg_count             =>   l_msg_cnt
			  , x_msg_data              =>   l_msg_data
			  , p_organization_id       =>   p_org_id
			  , p_inventory_item_id     =>   p_item_id
			  , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			  , p_is_revision_control   =>   b_is_revision_control
			  , p_is_lot_control        =>   FALSE
			  , p_is_serial_control     =>   b_is_serial_control
			  , p_revision              =>   nvl(p_rev, NULL)
			  , p_lot_number            =>   null
			  , p_subinventory_code     =>   l_sub
			  , p_locator_id            =>   l_loc_id
			  , p_primary_quantity      =>   -l_mmtt_qty
			  , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			  , x_qoh                   =>   l_qoh
			  , x_rqoh		     =>   l_rqoh
			  , x_qr		     =>   l_qr
			  , x_qs		     =>   l_qs
			  , x_att		     =>   l_att
		       , x_atr		     =>   l_atr
		       --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
		       , p_transfer_subinventory_code => l_xfr_sub_code
		       );
		     IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
			IF (l_debug = 1) THEN
   			trace('lpn_match: update qty tree without lpn 4th time:l_att:'||l_att);
			END IF;
		      ELSE
			IF (l_debug = 1) THEN
   			trace('lpn_match: calling update qty tree without lpn 4th time failed ');
			END IF;
			FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
			FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		     END IF;

		  END IF;

		  inv_quantity_tree_pub.query_quantities
		    ( p_api_version_number    =>   1.0
		      , p_init_msg_lst          =>   fnd_api.g_false
		      , x_return_status         =>   l_return_status
		      , x_msg_count             =>   l_msg_cnt
		      , x_msg_data              =>   l_msg_data
		      , p_organization_id       =>   p_org_id
		      , p_inventory_item_id     =>   p_item_id
		      , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
		      , p_is_revision_control   =>   b_is_revision_control
		      , p_is_lot_control        =>   FALSE
		      , p_is_serial_control     =>   b_is_serial_control
		      , p_demand_source_type_id =>   -9999
		      , p_revision              =>   nvl(p_rev, NULL)
		      , p_lot_number            =>   NULL
		      , p_subinventory_code     =>   l_sub
		      , p_locator_id            =>   l_loc_id
		      , x_qoh                   =>   l_qoh
		      , x_rqoh  		       =>   l_rqoh
		      , x_qr		       =>   l_qr
		      , x_qs		       =>   l_qs
		      , x_att		       =>   l_att
		    , x_atr		       =>   l_atr
		    , p_lpn_id                =>   p_lpn
		    , p_transfer_subinventory_code => l_xfr_sub_code
		    );

		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN

		     IF (l_debug = 1) THEN
   		     trace('lpn_match: lpn quantity = ' || l_att );
		     END IF;

		     IF l_mmtt_qty = l_att THEN
			if l_qoh = l_att then
			   -- LPN is a match!
			   IF (l_debug = 1) THEN
   			   trace('lpn_match: LPN matched');
			   END IF;
			   x_match := 1;
			 else
			   -- LPN is for multiple task
			   IF (l_debug = 1) THEN
   			   trace('lpn_match: LPN has multiple task.');
			   END IF;
			   x_match := 4;
			end if;

		      ELSIF l_mmtt_qty > l_att THEN
			if  l_qoh = l_att then
			   IF (l_debug = 1) THEN
   			   trace('lpn_match: lpn has less requested qty and lpn is whole allocation');
			   END IF;
			   x_match := 3;
			 else
			   IF (l_debug = 1) THEN
   			   trace('lpn_match: lpn has less than requested qty and lpn is partial allocation');
			   END IF;
			   x_match := 4;
			end if;
			l_lpn_qty := l_att;
		      ELSE

			x_match := 4;

		     END IF;

		   ELSE

		     IF (l_debug = 1) THEN
   		     trace('lpn_match: calling qty tree 4th time failed');
		     END IF;
		     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		     FND_MSG_PUB.add;
		     RAISE FND_API.G_EXC_ERROR;

		  END IF;

		  IF nvl(l_allocated_lpn_id, 0) = p_lpn THEN
		     --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
		     -- in order to get correct att.
		     inv_quantity_tree_pub.update_quantities
		       (  p_api_version_number    =>   1.0
			  , p_init_msg_lst          =>   fnd_api.g_false
			  , x_return_status         =>   l_return_status
			  , x_msg_count             =>   l_msg_cnt
			  , x_msg_data              =>   l_msg_data
			  , p_organization_id       =>   p_org_id
			  , p_inventory_item_id     =>   p_item_id
			  , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			  , p_is_revision_control   =>   b_is_revision_control
			  , p_is_lot_control        =>   FALSE
			  , p_is_serial_control     =>   b_is_serial_control
			  , p_revision              =>   nvl(p_rev, NULL)
			  , p_lot_number            =>   null
			  , p_subinventory_code     =>   l_sub
			  , p_locator_id            =>   l_loc_id
			  , p_primary_quantity      =>   l_mmtt_qty
			  , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			  , x_qoh                   =>   l_qoh
			  , x_rqoh		     =>   l_rqoh
			  , x_qr		     =>   l_qr
			  , x_qs		     =>   l_qs
			  , x_att		     =>   l_att
		          , x_atr		     =>   l_atr
		          , p_lpn_id                =>   p_lpn
		          , p_transfer_subinventory_code => l_xfr_sub_code
		       );
		     IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
			IF (l_debug = 1) THEN
   			trace('lpn_match: update qty tree back with lpn 4th time: l_att:' || l_att);
			END IF;
		      ELSE
			IF (l_debug = 1) THEN
   			trace('lpn_match: calling update qty tree back with lpn 4th time failed ');
			END IF;
			FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
			FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		     END IF;
		   ELSE
		     inv_quantity_tree_pub.update_quantities
		       (  p_api_version_number    =>   1.0
			  , p_init_msg_lst          =>   fnd_api.g_false
			  , x_return_status         =>   l_return_status
			  , x_msg_count             =>   l_msg_cnt
			  , x_msg_data              =>   l_msg_data
			  , p_organization_id       =>   p_org_id
			  , p_inventory_item_id     =>   p_item_id
			  , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
			  , p_is_revision_control   =>   b_is_revision_control
			  , p_is_lot_control        =>   FALSE
			  , p_is_serial_control     =>   b_is_serial_control
			  , p_revision              =>   nvl(p_rev, NULL)
			  , p_lot_number            =>   null
			  , p_subinventory_code     =>   l_sub
			  , p_locator_id            =>   l_loc_id
			  , p_primary_quantity      =>   l_mmtt_qty
			  , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
			  , x_qoh                   =>   l_qoh
			  , x_rqoh		     =>   l_rqoh
			  , x_qr		     =>   l_qr
			  , x_qs		     =>   l_qs
			  , x_att		     =>   l_att
		       , x_atr		     =>   l_atr
		       --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
		       , p_transfer_subinventory_code => l_xfr_sub_code
		       );
		  IF (l_return_status = fnd_api.g_ret_sts_success ) THEN
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: update qty tree back without lpn 4th time:l_att:'||l_att);
		     END IF;
		   ELSE
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: calling update qty tree back without lpn 4th time failed ');
		     END IF;
		     FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
		     FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;

		  END IF;

		  -- If the LPN quantity exactly matches/ has less than, the requested
		  -- quantity then match the serial numbers also

		  IF p_is_sn_alloc = 'Y' AND p_action = 4 AND ( x_match = 1 OR x_match = 3 ) THEN

		     SELECT
		       COUNT(fm_serial_number)
		       INTO
		       l_total_serial_cnt
		       FROM
		       mtl_serial_numbers_temp msnt
		       WHERE msnt.transaction_temp_id=p_temp_id;
		     IF (l_debug = 1) THEN
   		     trace('lpn_match: SN tot count'||l_total_serial_cnt);
		     END IF;

		     IF (l_total_serial_cnt = l_serial_exist_cnt) THEN

			IF (l_debug = 1) THEN
   			trace('lpn_match: LPN matches exactly');
			END IF;
			x_match := 1;

		      ELSIF(l_total_serial_cnt > l_serial_exist_cnt) THEN

			IF (l_debug = 1) THEN
   			trace('lpn_match: LPN has less');
			END IF;
			x_match := 3;
			l_lpn_qty := l_serial_exist_cnt;

		      ELSE

			IF (l_debug = 1) THEN
   			trace('lpn_match: LPN has extra serials');
			END IF;
			x_match := 4;

		     END IF;

		  END IF;

		  IF (l_debug = 1) THEN
   		  trace('lpn_match: After 4');
		  END IF;

	 END IF; -- lot control check

   END IF; -- lpn has only one item


   IF x_match = 1 OR x_match = 3 THEN

      IF p_action = 4 THEN

	 -- serial controlled - CHECK serial status
	 IF (l_debug = 1) THEN
   	 trace('lpn_match:  x_match is '||x_match||' and item is serial controlled ');
	 END IF;

	 OPEN ser_csr;
         LOOP

            FETCH ser_csr into l_serial_number;

            EXIT WHEN ser_csr%NOTFOUND;

	    IF inv_material_status_grp.is_status_applicable
	      (p_wms_installed              => p_wms_installed,
	       p_trx_status_enabled         => NULL,
	       p_trx_type_id                => p_transaction_type_id,
	       p_lot_status_enabled         => NULL,
	       p_serial_status_enabled      => NULL,
	       p_organization_id            => p_org_id,
	       p_inventory_item_id          => p_item_id,
	       p_sub_code                   => x_sub,
	       p_locator_id                 => NULL,
	       p_lot_number                 => p_lot,
	       p_serial_number              => l_serial_number,
	       p_object_type                => 'A') = 'N'

	      THEN

	       IF (l_debug = 1) THEN
   	       trace('lpn_match: After 6');
	       END IF;
	       x_match := 11;
	       CLOSE ser_csr;
	       FND_MESSAGE.SET_NAME('INV','INV_SER_STATUS_NA');
	       FND_MESSAGE.SET_TOKEN('TOKEN',l_serial_number);
	       FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;

            END IF;

         END LOOP;
         CLOSE ser_csr;

       ELSE

	       l_serial_number := NULL;
	       -- Check whether the LPN status is applicable for this transaction
	       IF inv_material_status_grp.is_status_applicable
		 (p_wms_installed              => p_wms_installed,
		  p_trx_status_enabled         => NULL,
		  p_trx_type_id                => p_transaction_type_id,
		  p_lot_status_enabled         => NULL,
		  p_serial_status_enabled      => NULL,
		  p_organization_id            => p_org_id,
		  p_inventory_item_id          => p_item_id,
		  p_sub_code                   => x_sub,
		  p_locator_id                 => NULL,
		  p_lot_number                 => p_lot,
		  p_serial_number              => l_serial_number,
		  p_object_type                => 'A') = 'N'

		 THEN

		  x_match := 8;

		  -- LPN status is invalid for this operation

		  FND_MESSAGE.SET_NAME('INV','INV_INVALID_LPN_STATUS');
		  FND_MESSAGE.SET_TOKEN('TOKEN1',TO_CHAR(p_lpn));
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;

	       END IF;

      END IF;

   END IF;


   IF (l_debug = 1) THEN
      trace('lpn_match: x_match : ' || x_match);
      trace('lpn_match: p_is_sn_alloc : ' || p_is_sn_alloc);
   END IF;


   l_table_total := t_lpn_lot_qty_table.COUNT;
   if l_table_total > 0 then
      IF (l_debug = 1) THEN
         trace('lpn_match:  building lpn lot vector for '||l_table_total||' records');
      END IF;
      for  l_table_count IN 1..l_table_total   LOOP
	 IF (l_debug = 1) THEN
   	 trace('lpn_match: index is : '||l_table_count);
	 END IF;
          x_lpn_lot_vector := x_lpn_lot_vector || t_lpn_lot_qty_table(l_table_count).lot_number
	    || '@@@@@'
	    || t_lpn_lot_qty_table(l_table_count).qty
	    || '&&&&&';


      END LOOP;

    else
      x_lpn_lot_vector := null;
   end if;

   IF (l_debug = 1) THEN
      trace('lpn_match: LPN QTY '||l_lpn_qty);
   END IF;

   x_temp_id := l_out_temp_id;
   x_qty := least(l_lpn_qty, p_qty);
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 1) THEN
      trace('lpn_match: Match :'||x_match);
      trace('lpn_match: x_loc_id :' || x_loc_id);
      trace('lpn_match: x_lpn_lot_vector :'||x_lpn_lot_vector);
      trace('lpn_match: x_qty :'||x_qty );
      trace('lpn_match: x_return_status :'||x_return_status);
      trace('lpn_match: x_temp_id :'||x_temp_id);
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
         trace('lpn_match:  Exception raised');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
       IF (l_debug = 1) THEN
          trace('lpn_match: Other exception raised : ' || Sqlerrm);
       END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data => x_msg_data );

END get_lpn_match;


-----------------------------------------------------
--   retrieve all the records from wms_device_requests and process
--
------------------------------------------------------
PROCEDURE device_confirmation(
			      x_return_status OUT NOCOPY VARCHAR2
			      ,x_msg_count OUT NOCOPY NUMBER
			      ,x_msg_data  OUT NOCOPY VARCHAR2
			      ,p_request_id IN NUMBER
			      ,x_successful_row_cnt OUT nocopy  number
			      ) IS

l_conf_rec_cnt NUMBER;
l_lpn_controlled_flag NUMBER;
l_count NUMBER :=0;
l_txn_quantity NUMBER;
l_xfer_sub_code VARCHAR2(30);
l_xfer_loc_id NUMBER;
ll_xfer_sub_code VARCHAR2(30);
ll_xfer_loc_id NUMBER;
l_lpn_sub  VARCHAR2(30);
l_lpn_loc VARCHAR2(60);
l_lot_code NUMBER;
l_serial_code NUMBER;
l_inventory_item_id NUMBER;
l_parent_request_id NUMBER;
l_mmtt_count NUMBER;
l_move_order_line_id NUMBER;
l_pr_qty NUMBER;
ll_pr_qty NUMBER;
-- start bUG 8197536
ll_sec_qty NUMBER;
l_secondary_uom varchar2(3);
l_dual_uom_control number;
-- end bUG 8197536
l_txn_hdr_id NUMBER;
l_txn_temp_id NUMBER;
l_lot NUMBER;
l_rev VARCHAR2(3);
l_tran_source_type_id NUMBER;
l_tran_action_id NUMBER;
l_qty_discrepancy_flag NUMBER :=0;
l_sub_discrepancy_flag NUMBER :=0;
l_loc_discrepancy_flag NUMBER :=0;
l_period_id NUMBER;
l_open_past_period BOOLEAN;
l_txn_ret NUMBER;
l_lpn_context NUMBER;
l_pick_lpn_context NUMBER;
l_sub_code VARCHAR2(30);
l_loc_id NUMBER;
l_source_line_id NUMBER;
l_wf NUMBER :=0;
l_last_updated_by NUMBER;
l_mmtt_txn_qty NUMBER;
ll_mmtt_txn_qty NUMBER;
l_primary_uom varchar2(3);
l_primary_quantity NUMBER;
l_transaction_uom VARCHAR2(3);
l_lpn_match NUMBER;
l_tran_type_id NUMBER;
l_cost_group_id NUMBER;
l_orig_lpn_id NUMBER;
l_lpn_qty_pickable NUMBER :=0;
x_lpn_lot_vector VARCHAR2(200);
x_temp_id NUMBER;
x_loc_id NUMBER;
l_new_request_id NUMBER;
l_mtlt_pr_qty NUMBER;
l_xfer_lpn VARCHAR2(30);
l_lpn                    WMS_CONTAINER_PUB.LPN;
l_any_row_failed BOOLEAN := FALSE;

l_per_res_id NUMBER;
l_wms_task_type  NUMBER;
l_std_op_id  NUMBER;
l_operation_plan_id  NUMBER;
l_person_id NUMBER;
l_orig_txn_hdr_id NUMBER;
l_org_id NUMBER;


/*
CURSOR c_fm_to_serial_number(l_txn_temp_id NUMBER) IS
   SELECT
     msnt.fm_serial_number,
     msnt.to_serial_number
     FROM  mtl_serial_numbers_temp msnt
     WHERE msnt.transaction_temp_id = l_txn_temp_id;

CURSOR c_fm_to_lot_serial_number(l_txn_temp_id NUMBER) IS
   SELECT
     msnt.fm_serial_number,
     msnt.to_serial_number
     FROM
     mtl_serial_numbers_temp msnt,
     mtl_transaction_lots_temp mtlt
     WHERE mtlt.transaction_temp_id = l_txn_temp_id
     AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;
*/

CURSOR wdr_cursor IS
   SELECT relation_id -- parent_request_id
     , task_id
     , task_summary
     , business_event_id
     , transaction_quantity
     , transfer_sub_code
     , transfer_loc_id
     , lpn_id
     , xfer_lpn_id
     , device_status
     , reason_id
     , organization_id--Its NOT NULL Column
     FROM wms_device_requests
     WHERE business_event_id IN
        (wms_device_integration_pvt.wms_be_task_confirm, wms_device_integration_pvt.wms_be_load_confirm)
     AND device_status = 'S'
     AND task_summary = 'Y'
     ORDER BY xfer_lpn_id;

--this cursor will be used to upate mtlt for unpicked lots
CURSOR c_mtlt_update (p_relation_id NUMBER, p_temp_id NUMBER) IS
   SELECT lot_number,lot_qty FROM wms_device_requests
     WHERE relation_id = p_relation_id
     AND task_id = p_temp_id
     AND task_summary = 'N'
     AND business_event_id IN
     (wms_device_integration_pvt.wms_be_task_confirm,
      wms_device_integration_pvt.wms_be_load_confirm);


  --Following c_update_xfer_lpn_context cursor is used to update LPN context to RESIDE_IN_INV after call to TM
  --1-For REPLENISHMENT TASKS
  --2-Only for LPNs that are being dropped
  --For SO Pick, TM handles it in post 11.5.10.
  --In case the LPN is going to the non-LPN controlled sub then TM would have already unpacked and updated the lpn context TO 'defined but not used'. Leave these LPN as it is.

  CURSOR c_update_xfer_lpns_context IS
     SELECT wlpn.lpn_id,organization_id FROM wms_license_plate_numbers wlpn
       WHERE wlpn.lpn_context <> wms_container_pub.lpn_context_pregenerated
       --to avoid LPNS that have been unpacked by TM for non-LPN ctrld sub
       AND wlpn.lpn_id IN
       (SELECT wdr.xfer_lpn_id
        FROM wms_device_requests wdr,
        wms_device_requests_hist wdrh,
        wms_dispatched_tasks wdt
        WHERE wdr.business_event_id = wms_device_integration_pvt.WMS_BE_TASK_CONFIRM
        AND wdr.task_id = wdt.transaction_temp_id
        AND wdt.task_type IN (4,5,7) -- ONLY for Replenishment, MO Xfer,Staging TASKS
	AND wdr.status_code = 'S'
        AND wdr.device_status = 'S'
        AND wdr.task_summary = 'Y'
        AND wdr.task_summary = wdrh.task_summary
        and wdrh.request_id = wdr.relation_id
        AND wdr.task_id = wdrh.task_id
        AND wdr.transaction_quantity > 0
        AND wdrh.business_event_id IN (wms_device_integration_pvt.wms_be_pick_release,wms_device_integration_pvt.wms_be_wip_pick_release,wms_device_integration_pvt.wms_be_mo_task_alloc)
        AND wdrh.TASK_TYPE_ID = 1);


--used to xfer records into WDTH
CURSOR mmtt_csr IS
   SELECT transaction_temp_id, organization_id, transfer_lpn_id, content_lpn_id
     FROM mtl_material_transactions_temp mmtt
     WHERE mmtt.transaction_header_id = l_txn_hdr_id;


--used to update the account period in mmtt
CURSOR c_open_period_check IS SELECT distinct organization_id, task_id
  FROM wms_device_requests
  WHERE business_event_id = wms_device_integration_pvt.WMS_BE_TASK_CONFIRM
  AND status_code = 'S'
  AND device_status = 'S'
  AND task_summary = 'Y';


l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_successful_row_cnt := 0;
   x_return_status:=FND_API.G_RET_STS_SUCCESS;

   SAVEPOINT WMS_DEVICE_REQUESTS_SP_OUTER;

   --this header_id will be used to call TM for the batch
   SELECT mtl_material_transactions_s.NEXTVAL INTO l_txn_hdr_id FROM DUAL;

   IF (l_debug = 1) THEN
      trace('Inside Device_Confirmation API:p_request_id'||p_request_id);
   END IF;

   FOR l_rec IN wdr_cursor LOOP
      --FOR each record this savepoint wil be overwritten
      SAVEPOINT WMS_DEVICE_REQUESTS_SP;
      FND_MSG_PUB.initialize;
      --Check if device status

      IF l_rec.device_status <> FND_API.g_ret_sts_success THEN
	 IF (l_debug = 1) THEN
   	 trace('DEVICE REQUEST has its status as ERROR ');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_ERR_DEVICE_STATUS');
	 FND_MSG_PUB.ADD;

	 --update wdr for error_code and error_mesg
	 ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
	 l_any_row_failed := TRUE;
	 update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
	 GOTO continue_loop;

       ELSE--device status is success
	 IF l_rec.relation_id IS NULL OR l_rec.task_id IS NULL THEN
	    IF (l_debug = 1) THEN
   	    trace('Error: parent_request_id or task_id is null for Task Confirm');
	    END IF;
	    FND_MESSAGE.SET_NAME('WMS', 'WMS_MISSING_TASK_INFO');
	    FND_MSG_PUB.ADD;

	    --update wdr for error_code and error_mesg
	    ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
	    l_any_row_failed := TRUE;
	    update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
	    GOTO continue_loop;

	  ELSE
	    IF (l_debug = 1) THEN
   	    trace('Processing Task: task_id:'||l_rec.task_id||':request_id :'||l_rec.relation_id);
	    END IF;
	    --Check if corresponding RECORD exist in the WDRH history table

            BEGIN
	       SELECT task_id,lpn_id INTO l_txn_temp_id,l_orig_lpn_id
		 FROM wms_device_requests_hist
		 WHERE request_id = l_rec.relation_id
		 AND task_id = l_rec.task_id
		 AND business_event_id IN (wms_device_integration_pvt.wms_be_pick_release,wms_device_integration_pvt.wms_be_wip_pick_release,wms_device_integration_pvt.wms_be_mo_task_alloc)
		 AND ROWNUM <2;
	    EXCEPTION
	       WHEN no_data_found THEN

		  FND_MESSAGE.SET_NAME('WMS', 'WMS_MISSING_TASK_INFO');
                  FND_MSG_PUB.ADD;

		  --update wdr for error_code and error_mesg
		  ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		  l_any_row_failed := TRUE;
		  update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		  GOTO continue_loop;
	    END;


	    --There are two records for a single mmtt record (after
	    -- pick_release) IN wdrh one for pick and another for drop, hence
	    --the condition AND ROWNUM <1 is required in above query

	    IF l_txn_temp_id IS NOT NULL THEN --means record exist
	       IF (l_debug = 1) THEN
   	       trace('txn_temp_id is valid:'||l_txn_temp_id);
	       END IF;
	       --get remaining details from MMTT
	       SELECT
		 transaction_header_id,
	       inventory_item_id,
	       move_order_line_id,
	       primary_quantity,
	       transaction_quantity,
	       transfer_subinventory,
	       transfer_to_location,
	       revision,
	       transaction_source_type_id,
	       transaction_action_id,
	       subinventory_code,
	       locator_id,
	       last_updated_by,
	       transaction_uom,
	       transaction_type_id,
	       cost_group_id
	       INTO
	       l_orig_txn_hdr_id,
	       l_inventory_item_id,
	       l_move_order_line_id,
	       l_pr_qty,
	       l_mmtt_txn_qty,
	       l_xfer_sub_code,
	       l_xfer_loc_id,
	       l_rev,
	       l_tran_source_type_id,
	       l_tran_action_id,
	       l_sub_code,
	       l_loc_id,
	       l_last_updated_by,
	       l_transaction_uom,
	       l_tran_type_id,
	       l_cost_group_id
	       FROM mtl_material_transactions_temp
	       WHERE transaction_temp_id = l_txn_temp_id;

	     --Validate the passed quantity
	     IF l_rec.transaction_quantity IS NOT NULL THEN --chances are that didn't choose suggestion
		IF (l_rec.transaction_quantity < l_mmtt_txn_qty) THEN
		   l_qty_discrepancy_flag := 1;--so qty discrepancy
		 ELSIF (l_rec.transaction_quantity > l_mmtt_txn_qty) THEN
		   IF (l_debug = 1) THEN
   		   trace('Quantity is not valid in the record');
		   END IF;
		   FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_QTY');
		   FND_MSG_PUB.ADD;

		   --update wdr for error_code and mesg
		   ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		   l_any_row_failed := TRUE;
		   update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		   GOTO continue_loop;
		END IF;
	     END IF;
	     IF (l_debug = 1) THEN
   	     trace('Validate xfer Sub');
	     END IF;
	     --Validate drop off Subinventory
	     IF l_rec.transfer_sub_code IS NOT NULL THEN --chances are that didn't choose suggestion
		IF l_rec.transfer_sub_code <> l_xfer_sub_code THEN--sub discrepancy
		   l_sub_discrepancy_flag := 1;
                    BEGIN
		       SELECT
			 msi.lpn_controlled_flag
			 INTO
			 l_lpn_controlled_flag
			 FROM
			 mtl_secondary_inventories msi
			 WHERE msi.organization_id = l_rec.organization_id
			 AND  msi.secondary_inventory_name = l_rec.transfer_sub_code
			 AND sysdate <= nvl(msi.disable_date,sysdate);
		    EXCEPTION
		       WHEN no_data_found THEN
			  IF (l_debug = 1) THEN
   			  trace('Invalid Sub:This Subinventory does not exist');
			  END IF;
			  FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SUB');
			  FND_MSG_PUB.ADD;

			  --update wdr for error_code and mesg
			  ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			  l_any_row_failed := TRUE;
			  update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			  GOTO continue_loop;
		    END;
		    IF (l_lpn_controlled_flag IS NULL) OR (l_lpn_controlled_flag <> wms_globals.g_lpn_controlled_sub) THEN
		       IF (l_debug = 1) THEN
   		       trace('Invalid Sub:SUB is not LPN Controlled');
		       END IF;
		       FND_MESSAGE.SET_NAME('WMS', 'WMS_SUB_NOLPN_CTRLD');
		       FND_MSG_PUB.ADD;
		       --update wdr for error_code and mesg
		       ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		       l_any_row_failed := TRUE;
		       update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		       GOTO continue_loop;
		    END IF;
		END IF;
	     END IF;

	     --Validate drop off Locator
	     IF (l_debug = 1) THEN
   	     trace('Validate xfer Loc');
	     END IF;
	     IF l_rec.transfer_loc_id IS NOT NULL THEN --chances are that didn't choose suggestion
		IF l_rec.transfer_loc_id <> l_xfer_loc_id THEN--loc discrepancy
		   l_loc_discrepancy_flag := 1;

		   SELECT 1 INTO l_count FROM DUAL WHERE exists
		     ( SELECT 1
		       FROM mtl_item_locations_kfv
		       WHERE organization_id = l_rec.organization_id
		       AND inventory_location_id = l_rec.transfer_loc_id
		       AND sysdate < nvl(disable_date,sysdate+1)
		       );
		   IF (l_count = 0) THEN
		      IF (l_debug = 1) THEN
   		      trace('Invalid Locator:Locator does not exist in this Sub/Org');
		      END IF;
		      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LOC');--done
		      FND_MSG_PUB.ADD;

		      --update wdr for error_code and mesg
		      ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		      l_any_row_failed := TRUE;
		      update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		      GOTO continue_loop;
		   END IF;
		END IF;
	     END IF;

	     --Validate the picked lpn_id
	     IF (l_debug = 1) THEN
   	     trace('passed lpn_id:'|| l_rec.lpn_id);
	     END IF;

		IF ((l_orig_lpn_id IS NOT NULL) AND (l_rec.lpn_id IS NOT NULL)
		    AND (l_orig_lpn_id <> l_rec.lpn_id)) OR ((l_orig_lpn_id IS NOT NULL) AND (l_rec.lpn_id IS NULL)) THEN

		--If we pass the LPN_id (which will appear in case LPN
		--allocation is turned on) in WDR the user must not pick
		--loose and record for task_confirmation should have
		--lpn_id populated, he might pick another LPN but from same
		--location, we will validate and process

		--If we do not pass LPN_id, THEN item can be picked looses and
		--record for task_confirmation can have lpn_id as null
		--   OR valid lpn can be picked from SAME SUGGESTED LOCATOR
		--with lpn_id in WDR being populated
		IF (l_debug = 1) THEN
   		trace('Error:Invalid Picked LPN:allocated LPN and picked LPNs do NOT match');
		END IF;
		FND_MESSAGE.SET_NAME('WMS', 'WMS_MISMATCH_LPN');
		FND_MSG_PUB.ADD;

		--update wdr for error_code and error_mesg
		ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		l_any_row_failed := TRUE;
		update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		GOTO continue_loop;

	      ELSIF (l_rec.lpn_id IS NOT NULL) THEN


		   IF (l_debug = 1) THEN
		      trace('validate the lpn context OF picked lpn');
		   END IF;

                   BEGIN
		      SELECT lpn_context
			INTO l_pick_lpn_context
			FROM wms_license_plate_numbers WHERE
			lpn_id = l_rec.lpn_id
			AND organization_id = l_rec.organization_id;


		      IF (l_debug = 1) THEN
			 trace('picked LPN:'||l_rec.lpn_id||'::context::'||l_pick_lpn_context);
		      END IF;

                   exception
		      WHEN no_data_found THEN
			 IF (l_debug = 1) THEN
			    trace('Error:NO data found for picked lpn_id:'||l_rec.lpn_id);
			 END IF;
			 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
			 FND_MSG_PUB.ADD;

			 --update wdr for error_code and error_mesg
			 ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			 update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			 GOTO continue_loop;
		   END;

		   IF l_pick_lpn_context NOT IN ( wms_container_pub.lpn_context_pregenerated,wms_container_pub.LPN_CONTEXT_INV) THEN
		      IF (l_debug = 1) THEN
			 trace('Invalid LPN context for picked LPN:'||l_rec.lpn_id||'::context::'||l_pick_lpn_context);
		      END IF;
		      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
		      FND_MSG_PUB.ADD;

		      --update wdr for error_code and error_mesg
		      ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		      update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		      GOTO continue_loop;

		   END IF;


		   IF (l_debug = 1) THEN
		      trace('Calling get LPN Match for picked LPN');
		   END IF;
		   --get information about picked LPN
		   get_lpn_match (
			       p_lpn        => l_rec.lpn_id
			       ,  p_org_id  => l_rec.organization_id
			       ,  p_item_id => l_inventory_item_id
			       ,  p_rev     => null
			       ,  p_lot 	=> null
			       ,  p_qty 	=> l_mmtt_txn_qty
			       ,  p_uom 	=> l_transaction_uom
			       ,  x_match       => l_lpn_match
			       ,  x_sub 	=> l_lpn_sub
			       ,  x_loc 	=> l_lpn_loc
			       ,  x_qty 	=> l_lpn_qty_pickable--qty that can be picked from LPN
			       ,  x_return_status    => x_return_status
			       ,  x_msg_count	     => x_msg_count
			       ,  x_msg_data	     => x_msg_data
			       ,  p_temp_id 	     => l_txn_temp_id
			       ,  p_wms_installed    => 'true'
			       ,  p_transaction_type_id  => l_tran_type_id
			       ,  p_cost_group_id	 => l_cost_group_id
			       ,  p_is_sn_alloc	         => 'Y' --we support only this
			       ,  p_action		 => 0--We DO not support serial,needed to pass ; FOR serial:4
			       ,  x_temp_id          => x_temp_id  --not used currently
			       ,  x_loc_id           => x_loc_id
		               ,  x_lpn_lot_vector   => x_lpn_lot_vector --not used currently
		             );

		IF (l_debug = 1) THEN
		   trace('device_confirmation: returned from get_lpn_match');
		   trace('device_confirmation: value of lpn_match'||l_lpn_match||':loc_id:'||x_loc_id);
		END IF;


		--put a check to see that the picked LPN is from the
		--suggested location otherwise error out
		IF l_loc_id <> x_loc_id THEN
		   IF (l_debug = 1) THEN
		      trace('Error:Unallowed LPN:substituted LPN must be picked from suggested Location');
		   END IF;
		   FND_MESSAGE.SET_NAME('WMS', 'WMS_SUBST_LPN_ERR');
		   FND_MSG_PUB.ADD;

		   --update wdr for error_code and error_mesg
		   ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		   l_any_row_failed := TRUE;
		   update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		   GOTO continue_loop;

		END IF;


	     END IF;

	     IF (l_debug = 1) THEN
   	     trace('passed xfer_lpn_id:'||l_rec.xfer_lpn_id);
	     END IF;
	     --Validate the Xfer_lpn_id only if it is different than picked
	     --LPN_id

	     IF (l_rec.xfer_lpn_id IS NOT NULL AND l_rec.lpn_id <> l_rec.xfer_lpn_id )
	       OR (l_rec.xfer_lpn_id IS NOT NULL AND l_rec.lpn_id IS NULL) THEN --Mandatory field

                   BEGIN
		      SELECT lpn_context,license_plate_number
			INTO l_lpn_context, l_xfer_lpn
			FROM wms_license_plate_numbers WHERE
			lpn_id = l_rec.xfer_lpn_id
			AND organization_id = l_rec.organization_id;

		      IF (l_debug = 1) THEN
			 trace('xfer_LPN:'||l_rec.xfer_lpn_id||'::context::'||l_lpn_context);
		      END IF;

		   EXCEPTION
		      WHEN no_data_found THEN
			 IF (l_debug = 1) THEN
			    trace('Error:NO data found for xfer_lpn_id:'||l_rec.xfer_lpn_id);
			 END IF;
			 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
			 FND_MSG_PUB.ADD;

			 --update wdr for error_code and error_mesg
			 ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			 l_any_row_failed := TRUE;
			 update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			 GOTO continue_loop;
		   END;

		   IF l_lpn_context NOT IN (wms_container_pub.LPN_CONTEXT_PACKING,
					    wms_container_pub.lpn_context_pregenerated,wms_container_pub.LPN_CONTEXT_INV) THEN
		      IF (l_debug = 1) THEN
			 trace('Invalid LPN context for xfer_LPN:'||l_rec.xfer_lpn_id||'::context::'||l_lpn_context);
		      END IF;
		      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
		      FND_MSG_PUB.ADD;

		      --update wdr for error_code and error_mesg
		      ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		      l_any_row_failed := TRUE;
		      update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		      GOTO continue_loop;

		   END IF;


		--make sure that lines picked in the LPN have same
		--delivery_id, IF delivery_id is not stamped then it uses
		--mol.carton_grouping_id. It also makes sure that lines in
		--the lpn are going to the same xfer sub/loc


		IF (l_debug = 1) THEN
		   trace('After calling validate_pick_to_lpn l_txn_temp_id :'||l_txn_temp_id);
		END IF;


		--this call will make sure that the lpn picked has same delivery
		wms_task_dispatch_gen.validate_pick_to_lpn
		  (p_api_version_number => 1.0  ,
		   x_return_status      => x_return_status,
		   x_msg_count          => x_msg_count,
		   x_msg_data           => x_msg_data,
		   p_organization_id    => l_rec.organization_id,
		   p_pick_to_lpn        => l_xfer_lpn,
		   p_temp_id            => l_txn_temp_id);

		IF (l_debug = 1) THEN
		   trace('After calling validate_pick_to_lpn x_return_status:'||x_return_status);
		   trace('x_msg_data :'||x_msg_data);
		END IF;


		IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
		   FND_MSG_PUB.ADD;
		   --update wdr for error_code and error_mesg
		   ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		   l_any_row_failed := TRUE;
		   update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		   GOTO continue_loop;

		 ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		   FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
		   FND_MSG_PUB.ADD;
		   --update wdr for error_code and error_mesg
		   ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		   l_any_row_failed := TRUE;
		   update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		   GOTO continue_loop;
		END IF;

	      ELSIF (l_rec.transaction_quantity <> 0 AND l_rec.lpn_id <>
		     l_rec.xfer_lpn_id ) THEN --ERROR OUT
		--l_rec.transaction_quantity =0 no need for xfer_lpn_id
		IF (l_debug = 1) THEN
   		trace('Error:No infomration about xfer_LPN_id was passed from WCS');
		END IF;
		FND_MESSAGE.SET_NAME('WMS', 'WMS_MISSING_XFER_LPN');
		FND_MSG_PUB.ADD;

		--update wdr for error_code and error_mesg
		ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		l_any_row_failed := TRUE;
		update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		GOTO continue_loop;
	     END IF;


	     -- Getting info about item being lot/Serial controlled
	     SELECT lot_control_code,serial_number_control_code,primary_uom_code
	       INTO l_lot_code,l_serial_code,l_primary_uom
	       FROM mtl_system_items
	       WHERE organization_id = l_rec.organization_id
	       AND inventory_item_id = l_inventory_item_id;
	     IF (l_debug = 1) THEN
   	     trace('l_lot_code := '||l_lot_code||':l_serial_code:='||l_serial_code);
	     END IF;


	     -- Error out if Short picked for Serial item
	     IF l_qty_discrepancy_flag <> 0 AND  (l_serial_code >1 AND
						  l_serial_code<>6) THEN
		IF (l_debug = 1) THEN
   		trace('Error:UnderPick of Serial item is not supported');
		END IF;
		FND_MESSAGE.SET_NAME('WMS', 'WMS_SER_SHORT_PICK_ERR');
		FND_MSG_PUB.ADD;

		--update wdr for error_code and error_mesg
		ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		l_any_row_failed := TRUE;
		update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		GOTO continue_loop;

	     END IF;

	                  ----*****************New Code Starts***********
             --Game plan to support mix of just Load_confirm along with task_confirm
             --Step0 Get reouseces information
             --Step1 Insert into WMS_DISPATCHED_TASKS --as "ACTIVE =9" for the user fnd_global.user_id
             --Step2 Do all MMTT manipulation and then WDT manipulation
             --Step3 Update the transaction_header_id of MMTT tasks that need to be dropped TO a NEW same common value AND THEN call TM
             --Step4 Archieve task Xfer WDT to WDTH for records that are being dropped
             --Step5 Call TM after the loop
             --Step6 Updae LPN Context apporpriately for droped LPNs:
             -- Replenishment task = 2 (reside IN inv), so tasks are taken
             -- care OF BY TM


               --Step0 Get reources information
               -- Picking or Replenishment task
               SELECT bremp.resource_id role_id
                    , t.wms_task_type
                    , t.standard_operation_id
                    , t.operation_plan_id
                    INTO l_per_res_id
                    , l_wms_task_type
                    , l_std_op_id
                    , l_operation_plan_id
                    FROM mtl_material_transactions_temp t, bom_std_op_resources bsor, bom_resources bremp
                    WHERE t.transaction_temp_id = l_rec.task_id
                    AND t.standard_operation_id = bsor.standard_operation_id
                    AND bsor.resource_id = bremp.resource_id
                    AND bremp.resource_type = 2
                    AND ROWNUM < 2;


             SELECT employee_id INTO l_person_id
               FROM fnd_user WHERE user_id = fnd_global.user_id;


             --Step1 Insert into WMS_DISPATCHED_TASKS --as "ACTIVE =9"

             INSERT INTO wms_dispatched_tasks
               (
                task_id
                , transaction_temp_id
                , organization_id
                , user_task_type
                , person_id
                , effective_start_date
                , effective_end_date
                , person_resource_id
                , status
                , dispatched_time
                , last_update_date
                , last_updated_by
                , creation_date
                , created_by
                , task_type
                , operation_plan_id
                , move_order_line_id
                )
                 VALUES (
                         wms_dispatched_tasks_s.NEXTVAL
                         , l_rec.task_id --transaction_temp_id
                         , l_rec.organization_id
                         , NVL(l_std_op_id, 2)
                         , l_person_id
                         , SYSDATE
                         , SYSDATE
                         , l_per_res_id
                         , l_g_task_active
                         , SYSDATE
                         , SYSDATE
                         , fnd_global.user_id
                         , SYSDATE
                         , fnd_global.user_id
                         , l_wms_task_type
                         , l_operation_plan_id
                         , l_move_order_line_id
                         );



             --Step2 DO all MMTT manipulation


	     IF (l_qty_discrepancy_flag = 0 AND l_sub_discrepancy_flag = 0 AND
		 l_loc_discrepancy_flag = 0) THEN --Has picked all suggested values

		IF (l_debug = 1) THEN
   		trace('User has picked all suggested values');
		END IF;

		--Even if the user has picked the suggested qty, make sure he
	        --picked allocated lot/serials. Validation for lot/serial
		--will be required only in case he passes those information,
		--Otherwise will not error out assuming he picked correct ones
		--Update the request_id for child records if they exist.

		IF (l_lot_code >1 OR l_serial_code >1) THEN--LOT OR/AND SERIAL ITEMS
		   IF (l_debug = 1) THEN
   		   trace('device_confirmation:validating lot/serial substitution');
		   END IF;

		   validate_child_record(l_rec.relation_id,'Y',l_lot_code,l_serial_code,l_txn_temp_id,l_qty_discrepancy_flag,l_rec.transaction_quantity,x_return_status);
		   --l_rec.task_id is same asl_txn_temp_id in this file

		   IF x_return_status <> FND_API.g_ret_sts_success THEN
		      IF (l_debug = 1) THEN
   		      trace('Error:In validating Lot/Serial information');
		      END IF;
		      FND_MESSAGE.SET_NAME('WMS', 'WMS_LOT_SER_VALIDATION_FAIL');
		      FND_MSG_PUB.ADD;

		      --update wdr for error_code and error_mesg
		      ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		      l_any_row_failed := TRUE;
		      update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		      GOTO continue_loop;

		   END IF;

		END IF;--LOT OR/AND SERIAL ITEMS



		--Updating MMTT with LPN information
		IF (l_debug = 1) THEN
   		trace('device_confirmation:Updating MMTT');
		END IF;

		IF (l_rec.lpn_id IS NOT NULL) THEN--picked an LPN

		   IF (l_debug = 1) THEN
		      trace('device_confirmation:user has picked LPN');
		   END IF;
		   --IN this case lpn_match=3 won't arise otherwise we have
		   --either data issue or l_lpn_match returned is not correct

		   --l_lpn_match will have value only in case there is
		   --wdr.lpn_id, so no need to check for it being null here

		   IF l_lpn_match=1 THEN --and no qty_disc

		      UPDATE mtl_material_transactions_temp
			SET content_lpn_id = l_rec.lpn_id,
			transfer_lpn_id = l_rec.xfer_lpn_id
			WHERE transaction_temp_id = l_txn_temp_id
			AND organization_id= l_rec.organization_id;

		      -- Later update LPN context For this case of picked_from_LPN to Packing
		      -- context AS it will be entirely nested

		    ELSIF  l_lpn_match=2 THEN
		      if l_rec.lpn_id = l_rec.xfer_lpn_id then
			 --Error
			 IF (l_debug = 1) THEN
   			 trace('error out,Can not move the entire LPN');
			 END IF;
			 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVLID_LPN_MOVE');
			 FND_MSG_PUB.ADD;

			 --update wdr for error_code and error_mesg
			 ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			 l_any_row_failed := TRUE;
			 update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			 GOTO continue_loop;
		       else
			 if l_rec.transaction_quantity > l_lpn_qty_pickable then
			    --ERROR;
			    IF (l_debug = 1) THEN
   			    trace('error out,qty picked is more then pickable qty in LPN');
			    END IF;
			    FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_QTY');
			    FND_MSG_PUB.ADD;

			    --update wdr for error_code and error_mesg
			    ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			    l_any_row_failed := TRUE;
			    update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			    GOTO continue_loop;

			  else
			    UPDATE mtl_material_transactions_temp
			      SET lpn_id = l_rec.lpn_id,
			      transfer_lpn_id = l_rec.xfer_lpn_id
			      WHERE transaction_temp_id = l_txn_temp_id
			      AND organization_id= l_rec.organization_id;
			 end if;
		      end if;

		    ELSIF  l_lpn_match=4 THEN
		      if l_rec.lpn_id = l_rec.xfer_lpn_id then
			 --ERROR;
			 IF (l_debug = 1) THEN
   			 trace('error out,Can not move the entire LPN');
			 END IF;
			 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_LPN_MOVE');
			 FND_MSG_PUB.ADD;

			 --update wdr for error_code and error_mesg
			 ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			 l_any_row_failed := TRUE;
			 update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			 GOTO continue_loop;
		       else
			 UPDATE mtl_material_transactions_temp
			   SET lpn_id = l_rec.lpn_id,
			   transfer_lpn_id = l_rec.xfer_lpn_id
			   WHERE transaction_temp_id = l_txn_temp_id
			   AND organization_id= l_rec.organization_id;
		      end if;

		   END IF;

		 ELSE--PICKED LOOSE
		   IF (l_debug = 1) THEN
   		   trace('user has picked loose');
		   END IF;
		   UPDATE mtl_material_transactions_temp
		     SET transfer_lpn_id = l_rec.xfer_lpn_id
			WHERE transaction_temp_id = l_txn_temp_id
			AND organization_id= l_rec.organization_id;

		END IF;--picked LOOSE


	      ELSE--means,at least one kind of qty/sub/loc discrepancy

		IF (l_debug = 1) THEN
   		trace('At least one kind of qty/sub/loc discrepancy');
		END IF;

		--If there is qty discrepancy, only in that case worry about
		--child records here because the case in which the user picked
		--the suggested qty of different lot/serial has been taken care
		--of above
		--Update MTLT/MSNT

		IF (l_qty_discrepancy_flag <> 0) AND l_rec.transaction_quantity <> 0 THEN --means qty_discrepancy
		  --we do not want to error out in case qty_picked is 0 and
		  --lot/serial info in child record is NOT provided

		   IF (l_lot_code >1 OR l_serial_code >1) THEN --LOT OR/AND SERIAL ITEMS
		      IF (l_debug = 1) THEN
   		      trace('device_confirmation:validating lot/serial substitution');
		      END IF;
		      --make sure that WCS has passed information about picked: Manadatory
		      --Also verify lot_qty/serial_qty information is correct
		      --for respective child records. like for a particular lot,
		      --lot_qty should NOT be greater than allocated_lot_qty

		      validate_child_record(l_rec.relation_id,'Y',l_lot_code,l_serial_code,l_txn_temp_id,l_qty_discrepancy_flag,l_rec.transaction_quantity,x_return_status);

		      IF x_return_status <> FND_API.g_ret_sts_success THEN
			 IF (l_debug = 1) THEN
   			 trace('Error:In validating Lot/Serial information');
			 END IF;
			 FND_MESSAGE.SET_NAME('WMS', 'WMS_LOT_SER_VALIDATION_FAIL');
			 FND_MSG_PUB.ADD;

			 --update wdr for error_code and error_mesg
			 ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			 l_any_row_failed := TRUE;
			 update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			 GOTO continue_loop;
		      END IF;

		   END IF;--LOT OR/AND SERIAL ITEMS
		END IF;--means qty_discrepancy


		--getting some info.
		 BEGIN
		    SELECT COUNT(*)
		      INTO l_mmtt_count
		      FROM  mtl_material_transactions_temp mmtt
		      WHERE mmtt.transaction_temp_id <> l_rec.task_id
		      AND   mmtt.move_order_line_id = l_move_order_line_id;
		 EXCEPTION
		    WHEN no_data_found THEN
		       l_mmtt_count := 0;
		 END;

		 SELECT mtrl.txn_source_line_id
		   INTO l_source_line_id
		   FROM mtl_txn_request_lines mtrl
		   WHERE mtrl.line_id = l_move_order_line_id;


		 --If user has picked qty zero, backorder line,log
		 --exception,fire appropriate workflow
		 IF l_rec.transaction_quantity = 0 THEN-- l_cur.transaction_quantity = 0

		    IF l_mmtt_count > 0 THEN -- l_mmtt_count > 0
		       IF (l_debug = 1) THEN
			  trace('Other MMTT lines exist too. Delete MMTT and UPDATE move ORDER line');
		       END IF;
		       DELETE FROM mtl_material_transactions_temp
			 WHERE transaction_temp_id = l_txn_temp_id;

		       IF l_lot_code > 1 THEN

			  -- Lot controlled item
			  IF (l_serial_code >1 AND l_serial_code<>6) THEN -- Lot and Serial controlled item

			     DELETE FROM mtl_serial_numbers_temp msnt
			       WHERE msnt.transaction_temp_id IN
			       (SELECT mtlt.serial_transaction_temp_id
				FROM  mtl_transaction_lots_temp mtlt
				WHERE mtlt.transaction_temp_id = l_txn_temp_id);
			  END IF;

			  DELETE FROM mtl_transaction_lots_temp mtlt
			    WHERE mtlt.transaction_temp_id = l_txn_temp_id;

			ELSIF (l_serial_code >1 AND l_serial_code<>6) THEN --Serial controlled item

			  DELETE FROM mtl_serial_numbers_temp msnt
			    WHERE msnt.transaction_temp_id = l_txn_temp_id;

		       END IF;

		       UPDATE mtl_txn_request_lines
			 SET quantity_detailed = quantity_detailed - l_pr_qty-- this diff is zero
			 WHERE line_id = l_move_order_line_id;

		     ELSE -- means l_mmtt_count = 0

		       IF (l_debug = 1) THEN
   		       trace('Just one MMTT line exists. Close MO and backorder');
		       END IF;

		       DELETE FROM wms_dispatched_tasks WHERE transaction_temp_id =  l_rec.task_id; --Bug 6987801

		       inv_mo_backorder_pvt.backorder
			 (p_line_id            => l_move_order_line_id
			  ,  x_return_status   => x_return_status
			  ,  x_msg_count       => x_msg_count
			  ,  x_msg_data        => x_msg_data);


		       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			  FND_MESSAGE.SET_NAME('WMS','WMS_BACKORDER_FAILED');
			  FND_MSG_PUB.ADD;

			  --update wdr for error_code and error_mesg
			  ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			  l_any_row_failed := TRUE;
			  update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			  GOTO continue_loop;
		       END IF;

		       IF (l_debug = 1) THEN
   		       trace('Calling API to clean up reservations');
		       END IF;

		       inv_transfer_order_pvt.clean_reservations
			 (p_source_line_id => l_source_line_id,
			  x_return_status  => x_return_status,
			  x_msg_count      => x_msg_count,
			  x_msg_data       => x_msg_data);

		       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			  FND_MESSAGE.SET_NAME('WMS','WMS_BACKORDER_FAILED');
			  FND_MSG_PUB.ADD;

			  --update wdr for error_code and error_mesg
			  ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			  l_any_row_failed := TRUE;
			  update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			  GOTO continue_loop;
		       END IF;

		       DELETE FROM mtl_material_transactions_temp
			 WHERE transaction_temp_id = l_txn_temp_id;

		       IF l_lot_code > 1 THEN

			  -- Lot controlled item
			  IF (l_serial_code >1 AND l_serial_code<>6) THEN -- Lot and Serial controlled item
			     DELETE FROM mtl_serial_numbers_temp msnt
			       WHERE msnt.transaction_temp_id IN
			       (SELECT mtlt.serial_transaction_temp_id
				FROM  mtl_transaction_lots_temp mtlt
				WHERE mtlt.transaction_temp_id = l_txn_temp_id);
			  END IF;

			  DELETE FROM mtl_transaction_lots_temp mtlt
			    WHERE mtlt.transaction_temp_id = l_txn_temp_id;

			ELSIF (l_serial_code >1 AND l_serial_code<>6) THEN --Serial controlled item

			  DELETE FROM mtl_serial_numbers_temp msnt
			    WHERE msnt.transaction_temp_id = l_txn_temp_id;

		       END IF;

		    END IF;-- l_mmtt_count > 0


		    IF (l_debug = 1) THEN
   		       trace('Reverting Xfer LPN context to its original value');
		    END IF;
		    --
		    -- Update the context to whatever it started with
		    -- before processing the record with zero qty
		    --

		    /* updated as part of the bug 4411819
		    --using wms_container_pvt.Modify_LPN() API instead
		    UPDATE wms_license_plate_numbers
		      SET lpn_context = l_lpn_context -- this still has
		      --the original value of lpn context
		      WHERE lpn_id = l_rec.xfer_lpn_id;
		      */

		    --Bug 6987801 : added if xfer_lpn_id is not null
                    IF l_rec.xfer_lpn_id IS NOT NULL THEN
		      l_lpn.lpn_id      := l_rec.xfer_lpn_id;
		    l_lpn.organization_id := l_rec.organization_id;
		    l_lpn.lpn_context := l_lpn_context;

		    wms_container_pvt.Modify_LPN
		      (
			p_api_version             => 1.0
			, p_validation_level      => fnd_api.g_valid_level_none
			, x_return_status         => x_return_status
			, x_msg_count             => x_msg_count
			, x_msg_data              => x_msg_data
			, p_lpn                   => l_lpn
			) ;

		    l_lpn := NULL;
                 END IF;

		  ELSE --means l_cur.transaction_quantity <> 0


		    IF (l_qty_discrepancy_flag <> 0) THEN --for qty disc only
		       --backorder remaining qty
		       IF (l_debug = 1) THEN
   		       trace('Inside Qty discrepancy ');
		       END IF;

		       -- Clean up code. Have to delete MMTT, MTLT, MSNT, WDT, if picked less
		       -- and update move order line

		       IF (l_debug = 1) THEN
   		       trace('Deleteing all unpicked lot/serials from MTLT/MSNT');
		       END IF;

		       --delete all unpicked lot/serials from MTLT/MSNT
		       IF l_lot_code >1 THEN

			  IF (l_serial_code >1 AND l_serial_code<>6) THEN

			     DELETE FROM mtl_serial_numbers_temp msnt
			       WHERE transaction_temp_id IN
			       (SELECT msnt.transaction_temp_id
				FROM  mtl_transaction_lots_temp mtlt,
				mtl_serial_numbers_temp msnt
				WHERE mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
				AND mtlt.transaction_temp_id =l_txn_temp_id)
			       AND msnt.fm_serial_number NOT IN
			       (SELECT serial_number FROM wms_device_requests
				WHERE relation_id = l_rec.relation_id
				AND task_id = l_txn_temp_id
				AND business_event_id = wms_device_integration_pvt.WMS_BE_TASK_CONFIRM
				AND task_summary = 'N');

			  END IF;


			  --Update qty in MTLT by qty passed in the child
			  -- records for corresponding lots

			  --In the child record, txn quantity is total
			  --quantity of the parent record. It is the
			  --lot_qty column which keeps correct lot qty for child record.

			  for l_mtlt_update in c_mtlt_update(l_rec.relation_id,l_txn_temp_id)
			    loop

			    l_mtlt_pr_qty :=l_mtlt_update.lot_qty;

			    --get the primary qty correctly based on UOM
			    IF (l_primary_uom <> l_transaction_uom) THEN
			    l_mtlt_pr_qty := INV_Convert.inv_um_convert
			    (item_id 	        => l_inventory_item_id,
			    precision	        => null,
			    from_quantity 	=> l_mtlt_update.lot_qty,
			    from_unit	        => l_transaction_uom,
			    to_unit		=> l_primary_uom,
			    from_name	        => null,
			    to_name		=> null);
			    END IF;

			    trace('l_mtlt_pr_qty::'||l_mtlt_pr_qty||'mtlt_lot_TXN_QTY:::'||l_mtlt_update.lot_qty);

			    update mtl_transaction_lots_temp set
			    TRANSACTION_QUANTITY = l_mtlt_update.lot_qty,
			    PRIMARY_QUANTITY = l_mtlt_pr_qty
			    WHERE transaction_temp_id = l_txn_temp_id
			    AND lot_number = l_mtlt_update.lot_number;

			    end loop;



			ELSIF (l_serial_code >1 AND l_serial_code<>6) THEN

			  -- Deleting serials which have not been picked

			  DELETE FROM mtl_serial_numbers_temp msnt
			    WHERE  msnt.transaction_temp_id = l_txn_temp_id
			    AND    msnt.fm_serial_number NOT IN
			    ( SELECT wdr.serial_number FROM
			      wms_device_requests wdr
			      WHERE relation_id = l_rec.relation_id
			      AND task_id = l_txn_temp_id
			      AND task_summary = 'N'
			      AND business_event_id IN (wms_device_integration_pvt.wms_be_task_confirm,wms_device_integration_pvt.WMS_BE_load_CONFIRM));


		       END IF;

		       IF (l_debug = 1) THEN
   		       trace('Upating quantity_detailed of mtrl');
		       END IF;
		       UPDATE mtl_txn_request_lines
			 SET  quantity_detailed = l_rec.transaction_quantity
			 WHERE line_id = l_move_order_line_id;

		    END IF;--for qty disc only



		    --Updating MMTT for LPN
		    IF (l_rec.lpn_id IS NOT NULL) THEN--picked an LPN
		       IF (l_debug = 1) THEN
			  trace('Updating MMTT for LPN');
		       END IF;
		       IF l_lpn_match =1 THEN
			  if (l_qty_discrepancy_flag <> 0) THEN--means qty_disc
			     if l_rec.lpn_id = l_rec.xfer_lpn_id then
				--ERROR;
				IF (l_debug = 1) THEN
   				trace('error out,Can not move the entire LPN');
				END IF;
				FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_LPN_MOVE');
				FND_MSG_PUB.ADD;
				--update wdr for error_code and error_mesg
				ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
				l_any_row_failed := TRUE;
				update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
				GOTO continue_loop;

			      ELSE-- taking from pickLPN to XferLPN
				UPDATE mtl_material_transactions_temp
				  SET lpn_id = l_rec.lpn_id,
				  transfer_lpn_id = l_rec.xfer_lpn_id
				  WHERE transaction_temp_id = l_txn_temp_id
				  AND organization_id= l_rec.organization_id;
			     end if;
			   ELSE --means no qty discrepancy

			     UPDATE mtl_material_transactions_temp
			       SET content_lpn_id = l_rec.lpn_id,
			       transfer_lpn_id = l_rec.xfer_lpn_id
			       WHERE transaction_temp_id = l_txn_temp_id
			       AND organization_id= l_rec.organization_id;
			  END IF;

			ELSIF  l_lpn_match=2 THEN
			  if l_rec.lpn_id = l_rec.xfer_lpn_id then
			     --Error
			     IF (l_debug = 1) THEN
   			     trace('error out,Can not move the entire LPN');
			     END IF;
			     FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_LPN_MOVE');
			     FND_MSG_PUB.ADD;
			     --update wdr for error_code and error_mesg
			     ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			     l_any_row_failed := TRUE;
			     update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			     GOTO continue_loop;
			   else if l_rec.transaction_quantity > l_lpn_qty_pickable then
				--ERROR;
				IF (l_debug = 1) THEN
   				trace('error out,qty picked is more then pickable qty in LPN');
				END IF;
				FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_QTY');
				FND_MSG_PUB.ADD;
				--update wdr for error_code and error_mesg
				ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
				l_any_row_failed := TRUE;
				update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
				GOTO continue_loop;

			      else-- taking from pickLPN to XferLPN
				UPDATE mtl_material_transactions_temp
				  SET lpn_id = l_rec.lpn_id,
				  transfer_lpn_id = l_rec.xfer_lpn_id
				  WHERE transaction_temp_id = l_txn_temp_id
				  AND organization_id= l_rec.organization_id;
			     end if;
			  end if;

			ELSIF  l_lpn_match = 3 THEN--already means qty_disc
			  if l_rec.transaction_quantity = l_lpn_qty_pickable then

			     UPDATE mtl_material_transactions_temp
			       SET content_lpn_id = l_rec.lpn_id,
			       transfer_lpn_id = l_rec.xfer_lpn_id
			       WHERE transaction_temp_id = l_txn_temp_id
				  AND organization_id= l_rec.organization_id;

			   elsif l_rec.transaction_quantity < l_lpn_qty_pickable then
			     if l_rec.lpn_id = l_rec.xfer_lpn_id then
				--ERROR;
				IF (l_debug = 1) THEN
   				trace('error out,Can not move the entire LPN');
				END IF;
				FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_LPN_MOVE');
				FND_MSG_PUB.ADD;
				--update wdr for error_code and error_mesg
				ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
				l_any_row_failed := TRUE;
				update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
				GOTO continue_loop;
			      ELSE
				UPDATE mtl_material_transactions_temp
				  SET lpn_id = l_rec.lpn_id,
				  transfer_lpn_id = l_rec.xfer_lpn_id
				  WHERE transaction_temp_id = l_txn_temp_id
				  AND organization_id= l_rec.organization_id;
			     end if;
			   else --means (wdr.transaction_quantity > l_lpn_qty_pickable), not possible
			     --ERROR;
			     IF (l_debug = 1) THEN
   			     trace('error out,qty picked is more then pickable qty in LPN');
			     END IF;
			     FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_QTY');
			     FND_MSG_PUB.ADD;
			     --update wdr for error_code and error_mesg
			     ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			     l_any_row_failed := TRUE;
			     update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			     GOTO continue_loop;

			  end if;

			ELSIF  l_lpn_match = 4 THEN
			  if l_rec.lpn_id = l_rec.xfer_lpn_id then
			     --ERROR;
			     IF (l_debug = 1) THEN
   			     trace('error out,Can not move the entire LPN');
			     END IF;
			     FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_LPN_MOVE');
			     FND_MSG_PUB.ADD;
			     --update wdr for error_code and error_mesg
			     ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			     l_any_row_failed := TRUE;
			     update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			     GOTO continue_loop;
			   else
			     UPDATE mtl_material_transactions_temp
			       SET lpn_id = l_rec.lpn_id,
			       transfer_lpn_id = l_rec.xfer_lpn_id
			       WHERE transaction_temp_id = l_txn_temp_id
			       AND organization_id= l_rec.organization_id;
			  end if;

		       END IF;

		     ELSE-- Picked Loose
		       IF (l_debug = 1) THEN
   		       trace('User has picked loose');
		       END IF;
		       UPDATE mtl_material_transactions_temp
			 SET transfer_lpn_id = l_rec.xfer_lpn_id
			 WHERE transaction_temp_id = l_txn_temp_id
			 AND organization_id= l_rec.organization_id;

		    END IF;--picked Loose


		    IF (l_debug = 1) THEN
   		    trace('Picked txn  quantity:'||l_rec.transaction_quantity);
		    END IF;

		    --update MMTT for qty/loc/sub disc
		    ll_pr_qty := l_pr_qty ;
		    ll_mmtt_txn_qty := l_mmtt_txn_qty;

		    IF (l_qty_discrepancy_flag <> 0) THEN

		       ll_mmtt_txn_qty := l_rec.transaction_quantity;
		       ll_pr_qty := l_rec.transaction_quantity;

		       IF (l_debug = 1) THEN
   		       trace('Updating MMTT for qty disc');
		       END IF;
		       --get the primary qty correctly based on UOM
		       IF (l_primary_uom <> l_transaction_uom) THEN
			  ll_pr_qty := INV_Convert.inv_um_convert
			    (item_id 	        => l_inventory_item_id,
			     precision	        => null,
			     from_quantity 	=> l_rec.transaction_quantity,
			     from_unit	        => l_transaction_uom,
			     to_unit		=> l_primary_uom,
			     from_name	        => null,
			     to_name		=> null);
		       END IF;
		       IF (l_debug = 1) THEN
   		       trace('qty discrepancy new l_txn_qty:'||ll_mmtt_txn_qty);
   		       trace('qty discrepancy new l_prim_qty:'||ll_pr_qty);
		       END IF;

		    END IF;


		    --Updating MMTT for sub/loc disc
		    ll_xfer_sub_code := l_xfer_sub_code;
		    ll_xfer_loc_id := l_xfer_loc_id;

		    IF (l_sub_discrepancy_flag <> 0) AND
		      (l_loc_discrepancy_flag <> 0) THEN

		       ll_xfer_sub_code := l_rec.transfer_sub_code;
		       ll_xfer_loc_id := l_rec.transfer_loc_id;

		       IF (l_debug = 1) THEN
   		       trace('sub/loc discrepancy new ll_xfer_sub_code:'||ll_xfer_sub_code );
   		       trace('sub/loc discrepancy new ll_xfer_loc_id:'|| ll_xfer_loc_id );
		       END IF;
		     ELSIF (l_loc_discrepancy_flag <> 0) THEN

		       ll_xfer_loc_id := l_rec.transfer_loc_id;
		       IF (l_debug = 1) THEN
   		       trace('loc discrepancy new ll_xfer_loc_id:'|| ll_xfer_loc_id );
		       END IF;
		    END IF;


		    IF (l_debug = 1) THEN
   		    trace('Updating MMTT for qty/sub/loc disc');
		    END IF;

		   /* changes for bug 8197536 */
		    select dual_uom_control,secondary_uom_code
		    into l_dual_uom_control,l_secondary_uom
                    FROM mtl_system_items_b
		    where inventory_item_id = l_inventory_item_id
		    and organization_id      = l_rec.organization_id;
		    if(l_dual_uom_control <> 1)
		    THEN
		    	ll_sec_qty := INV_Convert.inv_um_convert
			    (item_id 	        => l_inventory_item_id,
			     precision	        => null,
			     from_quantity 	=> ll_pr_qty,
			     from_unit	        => l_primary_uom,
			     to_unit		=> l_secondary_uom,
			     from_name	        => null,
			     to_name		=> null);

			     UPDATE mtl_material_transactions_temp
		      SET transfer_subinventory = ll_xfer_sub_code
		      , transfer_to_location  = ll_xfer_loc_id
		      , primary_quantity      = ll_pr_qty
		      , secondary_transaction_quantity = ll_sec_qty
		      , transaction_quantity  = ll_mmtt_txn_qty
		      WHERE transaction_temp_id = l_txn_temp_id
		      AND organization_id      = l_rec.organization_id;
		    ELSE
		    	UPDATE mtl_material_transactions_temp
		      SET transfer_subinventory = ll_xfer_sub_code
		      , transfer_to_location  = ll_xfer_loc_id
		      , primary_quantity      = ll_pr_qty
		      , transaction_quantity  = ll_mmtt_txn_qty
		      WHERE transaction_temp_id = l_txn_temp_id
		      AND organization_id      = l_rec.organization_id;
		    END if;
    /* end of changes for bug 8197536 */


		 END IF; --l_cur.transaction_quantity <> 0



		 -- Log Exception
		 IF l_rec.reason_id IS NOT NULL THEN

		    IF (l_debug = 1) THEN
   		    trace('logging exception for qty/sub/loc discrepanc FOR reason id'||l_rec.reason_id);
		    END IF;

		    wms_txnrsn_actions_pub.log_exception
		      (p_api_version_number =>1.0
		       , p_init_msg_lst     =>fnd_api.g_false
		       , p_commit           => FND_API.G_FALSE
		       , x_return_status    =>x_return_status
		       , x_msg_count        =>x_msg_count
		       , x_msg_data         =>x_msg_data
		       , p_organization_id  =>l_rec.organization_id
		       , p_mmtt_id          =>l_txn_temp_id
		       , p_task_id          =>l_txn_temp_id
		       , p_reason_id        =>l_rec.reason_id
		       , p_subinventory_code=>l_sub_code--picking sub
		       , p_locator_id       =>l_loc_id--picking loc
		       , p_discrepancy_type =>1
		       , p_user_id          =>l_last_updated_by--from mmtt
		       , p_item_id          =>l_inventory_item_id
		       , p_is_loc_desc      =>TRUE --Bug 4319541
		       );

		    IF (l_debug = 1) THEN
   		    trace('After logging exception for qty discrepancy');
		    END IF;

		    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		       FND_MESSAGE.SET_NAME('WMS','WMS_LOG_EXCEPTION_FAIL');
		       FND_MSG_PUB.ADD;
		       --update wdr for error_code and error_mesg
		       ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		       l_any_row_failed := TRUE;
		       update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		       GOTO continue_loop;

		     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		       FND_MESSAGE.SET_NAME('WMS','WMS_LOG_EXCEPTION_FAIL');
		       FND_MSG_PUB.ADD;
		       --update wdr for error_code and error_mesg
		       ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		       l_any_row_failed := TRUE;
		       update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		       GOTO continue_loop;

		    END IF;

		 END IF;


		 l_wf:=0;

                       BEGIN
			  SELECT  1
			    INTO  l_wf
			    FROM  MTL_TRANSACTION_REASONS
			    WHERE reason_id=l_rec.reason_id
			    and  workflow_name is not null
			      and workflow_name<>' '
			      and workflow_process is not null
				and workflow_process<>' ';
		       EXCEPTION
			  WHEN NO_DATA_FOUND THEN
			     l_wf:=0;
		       END;

		       IF l_wf > 0 THEN

			  IF (l_debug = 1) THEN
   			  trace('WF exists qty_pick reason_id'||l_rec.reason_id);
			  END IF;
			  -- Calling Workflow

			  IF l_rec.reason_id IS NOT NULL THEN

			     IF (l_debug = 1) THEN
   			     trace('Calling  workflow wrapper for Qty  Discrepancy');
			     END IF;

			     wms_workflow_wrappers.wf_wrapper
			       (p_api_version          =>  1.0,
				p_init_msg_list        =>  fnd_api.g_false,
				p_commit	       =>  fnd_api.g_false,
				x_return_status        =>  x_return_status ,
				x_msg_count            =>  x_msg_count,
				x_msg_data             =>  x_msg_data,
				p_org_id               =>  l_rec.organization_id ,
				p_rsn_id               =>  l_rec.reason_id,
				p_calling_program      =>  'wms_device_confirmation_pub.device_confirmation',
				p_tmp_id               =>  l_txn_temp_id,
				p_quantity_picked      =>  l_rec.transaction_quantity
				);

			  END IF;

			  IF (l_debug = 1) THEN
   			  trace('After Calling WF Wrapperfor Qty  Discrepancy');
			  END IF;

			  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			     IF (l_debug = 1) THEN
   			     trace('device_confirmation: Error callinf WF wrapper');
			     END IF;
			     FND_MESSAGE.SET_NAME('WMS','WMS_WORK_FLOW_FAIL');
			     FND_MSG_PUB.ADD;
			     --update wdr for error_code and error_mesg
			     ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			     l_any_row_failed := TRUE;
			     update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			     GOTO continue_loop;

			   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
			     IF (l_debug = 1) THEN
   			     trace('device_confirmation: Error calling WF wrapper');
			     END IF;
			     FND_MESSAGE.SET_NAME('WMS','WMS_WORK_FLOW_FAIL');
			     FND_MSG_PUB.ADD;
			     --update wdr for error_code and error_mesg
			     ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
			     l_any_row_failed := TRUE;
			     update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
			     GOTO continue_loop;

			  END IF;

		       END IF;


	     END IF;--at least one kind of discrepancy



             IF (l_debug = 1) THEN
                trace('Updating Headr and txn_status of the Drop record');
             END IF;

             UPDATE mtl_material_transactions_temp
               SET  transaction_date = sysdate
               ,transaction_status = 3
               ,transaction_header_id = l_txn_hdr_id
               WHERE transaction_temp_id = l_txn_temp_id
               AND organization_id= l_rec.organization_id
               AND l_rec.business_event_id <> wms_device_integration_pvt.wms_be_load_confirm;
             -- update headerand txn_status of only those mmtt records that are destined TO be dropped



             --Step2.2 Do manipulation of WDT for THIS task status as Loaded Now
             -- IT does not have to wait till laterr stage.

             UPDATE wms_dispatched_tasks
               SET status =  l_g_task_loaded
               ,last_update_date = Sysdate
               ,loaded_time = Sysdate
               ,last_updated_by = fnd_global.user_id
               WHERE transaction_temp_id = l_rec.task_id;



             /*
             --update LPN context of picked_from_LPN as it
             --will be entirely nested in following cases
             IF ((l_lpn_match=1 or l_lpn_match=3)  AND  l_rec.lpn_id <> l_rec.xfer_lpn_id)



               IF (l_rec.lpn_id IS NOT NULL AND (l_lpn_match=1 or l_lpn_match=3)  AND l_rec.lpn_id <> l_rec.xfer_lpn_id) THEN

                  wms_container_pvt.modify_lpn_wrapper
                    (p_api_version    => '1.0',
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     p_lpn_id         => l_rec.lpn_id,
                     p_lpn_context    => WMS_Container_PUB.LPN_CONTEXT_PACKING);

                  IF ((x_return_status = FND_API.g_ret_sts_unexp_error) OR (x_return_status
                                                                            = FND_API.g_ret_sts_error)) THEN

                     IF (l_debug = 1) THEN
                        trace('device_confirmation: Load LPN modify_lpn_wrapper error');
                     END IF;
                     FND_MESSAGE.SET_NAME('WMS','WMS_TD_MODIFY_LPN_ERROR');
                     FND_MSG_PUB.ADD;
                     --update wdr for error_code and error_mesg
                     ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
                     update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
                     GOTO continue_loop;


                  END IF;

               END IF;
                  */

             --NOW Change the LPN context of Xfer LPN to Loaded here to avoid
             --faling load operation OF entire batch AS against TO
             -- malicious records ONLY

	     --Bug 6987801 : added if xfer_lpn_id is not null
             IF l_rec.xfer_lpn_id IS NOT NULL THEN
             wms_container_pvt.modify_lpn_wrapper
               (p_api_version    => '1.0',
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_lpn_id         => l_rec.xfer_lpn_id,
                p_lpn_context    => WMS_Container_PUB.LPN_CONTEXT_PACKING);

             IF ((x_return_status = FND_API.g_ret_sts_unexp_error) OR (x_return_status
                                                                       = FND_API.g_ret_sts_error)) THEN

                IF (l_debug = 1) THEN
                   trace('device_confirmation: Load LPN modify_lpn_wrapper error');
                END IF;
                FND_MESSAGE.SET_NAME('WMS','WMS_TD_MODIFY_LPN_ERROR');
                FND_MSG_PUB.ADD;
                --update wdr for error_code and error_mesg
                ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
                update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
                GOTO continue_loop;
             END IF;
	    END IF;



	     ---88888888888888888888888888888888888888888888888888888888888888888
	     --moved the call to TM for complete batch rather than for each line
	     ---888888888888888888888888888888888888888888888888888888888888888888


	     ELSE--means l_txn_temp_id IS NULL,No corresponding record in WDRH
		    IF (l_debug = 1) THEN
   		    trace('parent_request_id is not valid');
		    END IF;
		    FND_MESSAGE.SET_NAME('WMS', 'WMS_MISSING_TASK_INFO');
		    FND_MSG_PUB.ADD;
		    --update wdr for error_code and error_mesg
		    ROLLBACK TO WMS_DEVICE_REQUESTS_SP;
		    l_any_row_failed := TRUE;
		    update_wdr_for_error_rec(l_rec.task_id,l_rec.relation_id);
		    GOTO continue_loop;
	    END IF;
	 END IF;-- l_rec.relation_id IS NULL

      END IF;--device success

      --Update WDR for Success, which will be transferred to WDRH
      UPDATE wms_device_requests
	SET status_code = 'S',
	status_msg = null
	WHERE  business_event_id in (wms_device_integration_pvt.wms_be_task_confirm,wms_device_integration_pvt.wms_be_load_confirm)
	AND task_id = l_rec.task_id
	AND relation_id = l_rec.relation_id;

      --It has come here it means that, this record was successful
      -- increasing the count for successful rows
      x_successful_row_cnt := x_successful_row_cnt +1;

      <<continue_loop>>
      IF (l_debug = 1) THEN
         trace('device_confirmation:done with current record ');
      END IF;
   END LOOP;

   --Proces the BATCH now

   IF l_any_row_failed THEN
      x_return_status := 'W';
   END IF;


   --validating the account period and updating mmtt accordingly
   -- ONLY for records that is being dropped
   IF (l_debug = 1) THEN
      trace('Check if account period is open before calling TM');
   END IF;

   FOR l_open_period_check IN c_open_period_check loop

      invttmtx.tdatechk(org_id           => l_open_period_check.organization_id,
			transaction_date => sysdate,
			period_id        => l_period_id,
			open_past_period => l_open_past_period);

      IF l_period_id <> -1 THEN
	 IF (l_debug = 1) THEN
	    trace('Need to update the account period in MMTT');
	 END IF;
	 UPDATE mtl_material_transactions_temp
	   SET  acct_period_id = l_period_id
	   WHERE transaction_temp_id = l_open_period_check.task_id
	   AND organization_id = l_open_period_check.organization_id;
       ELSE
	 IF (l_debug = 1) THEN
	    trace('device_confirmation: Period is invalid');
	 END IF;
	 FND_MESSAGE.SET_NAME('INV', 'INV_NO_OPEN_PERIOD');
	 FND_MSG_PUB.ADD;
	 x_return_status := FND_API.g_ret_sts_error;
	 ROLLBACK TO WMS_DEVICE_REQUESTS_SP_OUTER;

      END IF;

   END LOOP;



   IF (l_debug = 1) THEN
      trace('Done with all records: Insert WDT History ONLY for LPNs to be DROPPED');
   END IF;


   --Step4 Xfer WDT to WDTH for records that are being dropped
   -- ONLY those MMTT are update with this NEW l_txn_hdr_id that are destined
   -- TO be dropped


   FOR l_mmtt_csr IN mmtt_csr LOOP

       -- we need this for interoperabiliy of Device framework and MObile UI
      -- First keep both values transfer_lpn_id and content_lpn_id same but
      -- before call tm , correct it

      -- Modified for bug 7254269 start
	      IF (l_mmtt_csr.content_lpn_id = l_mmtt_csr.transfer_lpn_id) THEN
		 -- We are transferring the entire lpn
		 UPDATE mtl_material_transactions_temp mmtt
		   set transfer_lpn_id = NULL , lpn_id = NULL
		   WHERE mmtt.transaction_temp_id = l_mmtt_csr.transaction_temp_id;
	      END IF;
      -- Modified for bug 7254269 end



      wms_task_dispatch_put_away.archive_task
        (
         p_temp_id                    => l_mmtt_csr.transaction_temp_id
         , p_org_id                     => l_mmtt_csr.organization_id
         , x_return_status              => x_return_status
         , x_msg_count                  => x_msg_count
         , x_msg_data                   => x_msg_data
         , p_delete_mmtt_flag           => 'N'
         , p_txn_header_id              => l_txn_hdr_id
         , p_transfer_lpn_id            => NVL(l_mmtt_csr.transfer_lpn_id, l_mmtt_csr.content_lpn_id)
         );
   END LOOP;



   --Step5 Calling TM ONLY for those records in the batch that are destined to be
   -- dropped. IN code above only those MMTT records are stamped with
   --NEW common transaction_header_id that are TO be dropped.

   --Failed records in the batch will have their original header_id, so they
   --will not get considered in this call to TM and hence willl NOT be picked by TM

   IF (l_debug = 1) THEN
      trace('Calling TM ONLY for LPNs to be  Dropped' );
      trace('Calling TM:hdr_id'||l_txn_hdr_id);
   END IF;


      l_txn_ret := inv_lpn_trx_pub.process_lpn_trx
	(p_trx_hdr_id         => l_txn_hdr_id,
	 p_commit             => fnd_api.g_false,
	 x_proc_msg           => x_msg_data);

      IF (l_debug = 1) THEN
	 trace('After call to TM, Txn proc ret'||l_txn_ret);
      END IF;

      --If any record in the batch fails TM returns -1, so if any record in TM
      --fails, total batch will be rolled back

      IF l_txn_ret<>0 THEN
	 IF (l_debug = 1) THEN
	    trace('*************TM call FAILED***************');
	 END IF;

	 FND_MESSAGE.SET_NAME('WMS','WMS_TD_TXNMGR_ERROR' );
	 FND_MSG_PUB.ADD;

	 x_return_status := FND_API.g_ret_sts_error;

	 ROLLBACK TO WMS_DEVICE_REQUESTS_SP_OUTER;

       ELSE
	 --TM CALL SUCCESSFUL


	 IF (l_debug = 1) THEN
	    trace('*************TM call successful***************');
	    trace('Updating context for all replenished  LPNs' );
	 END IF;

	 --Step6 Update LPN Context apporpriately for processed LPNs
	 --For droped LPN tasks ONLY:
	 --    Replenishment task = (reside IN inv) wms_container_pub.lpn_context_inv
	 --    so taks = Handled by TM (Do NOT do anything)
	 -- All successful LPNs are already Loaded in the loop above for each call


	 --Update the LPN context to Reside in INV for all LPNs for Replenishment
	 --tasks. For SO tasks, it is handled in the TM
	 -- the cursor c_update_xfer_lpns_context ensure that LPNs for
	 -- replenishment tasks are here only


	 FOR l_update_xfer_lpns_context IN c_update_xfer_lpns_context loop

	    --In case LPN is getting transferred, both lpn_id and
	    --xfer_lpn_id are same, so getting updated correctly

	    --as part of the bug 4411819, replaced
	    --wms_container_pub.modify_lpn_wrapper to  wms_container_pvt.Modify_LPN

	    l_lpn.lpn_id        := l_update_xfer_lpns_context.lpn_id;
	    l_lpn.organization_id := l_update_xfer_lpns_context.organization_id;
	    l_lpn.lpn_context := wms_container_pub.lpn_context_picked;

	    wms_container_pvt.Modify_LPN
	      (
		p_api_version             => 1.0
		, p_validation_level      => fnd_api.g_valid_level_none
		, x_return_status         => x_return_status
		, x_msg_count             => x_msg_count
		, x_msg_data              => x_msg_data
		, p_lpn                   => l_lpn
		) ;


	    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
	      x_return_status = FND_API.g_ret_sts_error THEN

	       IF (l_debug = 1) THEN
		  trace('device_confirmation: modify_lpn Unexpected error');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_TD_MODIFY_LPN_ERROR' );
	       FND_MSG_PUB.ADD;
	       --rollback the batch
	       ROLLBACK TO wms_device_requests_sp_outer;

	    END IF;

	 END LOOP;

      END IF;

      IF (l_debug = 1) THEN
	 trace('calling populate_history in WDRH for all records' );
      END IF;
      populate_history(l_new_request_id);

      IF (l_debug = 1) THEN
	 trace(' device_confirmation:Delete requested rows from WDR');
      END IF;
      delete from wms_device_requests;--since temp table is session specific

      --Commit will be done by calling api
      IF (l_debug = 1) THEN
	 trace('device_confirmation:done with this API');
      END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_REQ_FAIL');
      FND_MSG_PUB.ADD;
      --since all original records have been deleted from WDRH before making this
      --call
      IF (l_debug = 1) THEN
         trace('calling populate_history for all records' );
      END IF;
      populate_history(l_new_request_id);

      IF  p_request_id IS NOT NULL THEN---p_request_id is not null only for
	 --resubmission, it is null for
	 --normal case
	 IF (l_debug = 1) THEN
   	 trace('Updating resubmitted records for EXP exception thrown' );
	 END IF;
	 --this is set to P in the form while making call to concurrent req
	 UPDATE wms_device_requests_hist
	   SET status_code = 'E',resubmit_date = sysdate,
	   status_msg= 'g_expected_error'
	   WHERE request_id = l_new_request_id
	   AND BUSINESS_EVENT_ID IN (wms_device_integration_pvt.wms_be_task_confirm,wms_device_integration_pvt.wms_be_load_confirm);

	 COMMIT;
       ELSE  --Bug#4535546. Added ELSE block.
	 ROLLBACK TO WMS_DEVICE_REQUESTS_SP_OUTER;
      END IF;

      IF (l_debug = 1) THEN
         trace('DEVICE_CONFIRMATION:Error: G_EXC_ERR');
      END IF;
      -- ROLLBACK TO WMS_DEVICE_REQUESTS_SP_OUTER;Commented for Bug#4535546
      x_return_status := FND_API.G_RET_STS_ERROR;

      x_msg_data:=GET_MSG_STACK ;     --Bug#4535546.

   WHEN OTHERS THEN

      FND_MESSAGE.SET_NAME('WMS', 'WMS_DEV_REQ_FAIL');
      FND_MSG_PUB.ADD;
      --since all original records have been deleted from WDRH before making this
      --call
      IF (l_debug = 1) THEN
         trace('calling populate_history for all records' );
      END IF;
      populate_history(l_new_request_id);

      IF  p_request_id IS NOT NULL THEN---p_request_id is not null only for
	                               --resubmission, it is null for
	                               --normal case
	 IF (l_debug = 1) THEN
   	 trace('Updating resubmitted records for UNEXP exception thrown' );
	 END IF;
	 --this is set to P in the form while making call to concurrent req
	 UPDATE wms_device_requests_hist
	   SET status_code = 'E',resubmit_date = Sysdate,
	   status_msg='g_unexpected_error'
	   WHERE request_id = l_new_request_id
	   AND BUSINESS_EVENT_ID IN (wms_device_integration_pvt.wms_be_task_confirm,wms_device_integration_pvt.wms_be_load_confirm);

	 COMMIT;
      ELSE  --Bug#4535546. Added ELSE block.
        ROLLBACK TO WMS_DEVICE_REQUESTS_SP_OUTER;
     END IF;

      IF (l_debug = 1) THEN
         trace('DEVICE_CONFIRMATION:Error: G_UNEXC_ERR');
      END IF;
  --  ROLLBACK TO WMS_DEVICE_REQUESTS_SP_OUTER; Commented for Bug#4535546
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      x_msg_data:=GET_MSG_STACK ;   --Bug#4535546.

END device_confirmation;


END wms_device_confirmation_pub;


/
