--------------------------------------------------------
--  DDL for Package Body WMS_ASN_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ASN_INTERFACE" AS
/* $Header: WMSASNIB.pls 115.28 2004/05/19 00:23:24 surpatel ship $ */

g_num_recs_per_group NUMBER := 0;
TYPE g_number_tb_tp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_error_rhi_id_tb g_number_tb_tp;

g_prior_interface_id NUMBER := 0;

PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER)
  IS
     l_trace_on NUMBER := 0;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'WMS_ASN_INTERFACE',
      p_level => p_level);


   SELECT fnd_profile.value('INV_DEBUG_TRACE')
     INTO l_trace_on
     FROM dual;

   IF l_trace_on = 1 THEN
      FND_FILE.put_line(FND_FILE.LOG, 'WMS_ASN_INTERFACE : ' || p_err_msg);
   END IF;

-- dbms_output.put_line(p_err_msg);
END print_debug;


PROCEDURE shipment_header_cleanup
  (p_shipment_header_id NUMBER)
  IS
     CURSOR l_lpn_curs IS
	SELECT lpn_id
	  FROM wms_license_plate_numbers
	  WHERE  source_header_id = p_shipment_header_id
	  AND lpn_context = 7
	  AND source_type_id = 1;
     l_lpn_id NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('shipment_header_cleanup - p_shipment_header_id : '||p_shipment_header_id, 1);
   END IF;

   OPEN l_lpn_curs;
   LOOP
      FETCH l_lpn_curs INTO l_lpn_id;
      EXIT WHEN l_lpn_curs%notfound;

      IF (l_debug = 1) THEN
         print_debug('Clean up this LPN - l_lpn_id : '||l_lpn_id, 4);
      END IF;


      DELETE mtl_serial_numbers
	WHERE lpn_id = l_lpn_id;

      DELETE wms_lpn_contents
	WHERE parent_lpn_id = l_lpn_id;

      DELETE wms_license_plate_numbers
	WHERE lpn_id = l_lpn_id;

   END LOOP;

   CLOSE l_lpn_curs;

   IF (l_debug = 1) THEN
      print_debug('shipment_header_cleanup - complete', 1);
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('shipment_header_cleanup - unexpected error ', 1);
      END IF;

      IF l_lpn_curs%isopen THEN
	 CLOSE l_lpn_curs;
      END IF;

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	 print_debug('SQL Error : '||SQLERRM(SQLCODE)||' SQL Error code : '||SQLCODE, 1);
	 END IF;
      END IF;

END;


PROCEDURE process
  (
   x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_interface_transaction_id    IN  NUMBER )
  IS
     CURSOR l_cur_lpn_interface IS
-- Bug# 1546081
	SELECT license_plate_number,
	  lot_number,
	  from_serial_number,
	  to_serial_number,
	  item_description,
	  quantity,
	  uom_code,
          serial_transaction_intf_id
	  FROM wms_lpn_contents_interface
	  WHERE interface_transaction_id = p_interface_transaction_id;

     CURSOR l_print_lpn_curs
       (v_group_id NUMBER)
       IS
	  SELECT DISTINCT wlpn.lpn_id
	    FROM wms_license_plate_numbers wlpn,
	    rcv_transactions_interface rti
	    WHERE  wlpn.source_header_id = rti.shipment_header_id
	    AND wlpn.lpn_context = 7
	    AND wlpn.source_type_id = 1
	    AND rti.group_id = v_group_id;

	-- Bug# 1546081
     CURSOR c_rcv_txn_interface_rec IS
	SELECT group_id,
	  to_organization_id,
	  item_id,
	  item_revision,
	  shipment_header_id,
	  po_line_id,
	  quantity,
	  unit_of_measure,
	  uom_code,
	  header_interface_id,
          shipment_num
	  FROM rcv_transactions_interface
	  WHERE interface_transaction_id = p_interface_transaction_id;

     -- Bug# 1546081

     CURSOR l_lpn_interface_UOM_curs IS
	SELECT uom_code
	  FROM wms_lpn_contents_interface
	  WHERE interface_transaction_id = p_interface_transaction_id;


     l_lpn_interface_rec l_cur_lpn_interface%ROWTYPE;
     l_rcv_txn_interface_rec c_rcv_txn_interface_rec%ROWTYPE;
     l_lpn_interface_UOM_rec l_lpn_interface_UOM_curs%ROWTYPE;
     l_lpn_rec wms_container_pub.lpn;
     l_lpn_id NUMBER;
     l_return_status VARCHAR2(1) := FND_API.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(400);
     l_inventory_item_id NUMBER;
     l_revision VARCHAR2(30);
     l_organization_id NUMBER;
     l_expiration_date DATE := Sysdate;
     l_object_id NUMBER;
     l_api_version NUMBER := 1.0;
     l_shipment_header_id NUMBER;
     l_po_line_id NUMBER;
     l_input_param_rec INV_LABEL.input_parameter_rec_type;
     l_label_status VARCHAR2(500);
     l_lot_control_code NUMBER;
     l_serial_control_code NUMBER;
     l_shelf_life_code NUMBER;
     l_shelf_life_days NUMBER;
     l_total_quantity NUMBER;
     l_is_header_error BOOLEAN := FALSE;
     l_progress VARCHAR2(10);
     l_total_quantity_rti NUMBER;
     l_num_recs_per_group NUMBER;

     -- For Asn Details Report
     l_asn_details_rec  inv_cr_asn_details.rcv_intf_rec_tp;

     /* Bug 2224521 */
     l_valid_lot BOOLEAN := TRUE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('Enter Process 10', 1);
      print_debug('p_interface_transaction_id = ' || p_interface_transaction_id, 4);
   END IF;

   l_progress := '10';

   -- For INV/WMS Patchset J just return
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j)) THEN
      IF (l_debug = 1) THEN
        print_debug('Insatnce on patchset J or higher, returning from this api', 1);
      END IF;
      return;
    END IF;

   SAVEPOINT process_lpn_intf;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Bug# 1546081
/*
   BEGIN
      SELECT *
	INTO l_rcv_txn_interface_rec
	FROM rcv_transactions_interface
	WHERE interface_transaction_id = p_interface_transaction_id;
   EXCEPTION
      WHEN OTHERS THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;
*/

   l_progress := '20';

   IF g_prior_interface_id = p_interface_transaction_id THEN
      IF (l_debug = 1) THEN
         print_debug('The LPN related with Interface ID is already processed ', 4);
      END IF;
      return;
   ELSE
      g_prior_interface_id := p_interface_transaction_id ;
   END IF;

   OPEN c_rcv_txn_interface_rec;
   FETCH c_rcv_txn_interface_rec INTO l_rcv_txn_interface_rec;

      IF (l_debug = 1) THEN
         print_debug('Group_id =  '||l_rcv_txn_interface_rec.group_id, 4);
      END IF;

   /*Start of fix for Bug 1900958 */
   IF c_rcv_txn_interface_rec%NOTFOUND THEN
      CLOSE c_rcv_txn_interface_rec;
      IF (l_debug = 1) THEN
         print_debug('No record exists in RCV_TRANSACTIONS_INTERFACE for this interface_transaction_ID', 4);
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   /*End of fix for Bug 1900958 */

   CLOSE c_rcv_txn_interface_rec;
-- End Bug# 1546081

   l_progress := '30';

   -- IF g_num_recs_per_group = 0 THEN
   -- if g_num_recs_per_group > l_num_recs_per_group
   -- the rti is cascaded and we don't need to do count
   -- from wms_lpn_contents_interface again as
   -- the contents of wms_lpn_contents_interface does not
   -- exist anymore and already processed.

      SELECT COUNT(*)
	INTO l_num_recs_per_group
	FROM wms_lpn_contents_interface
	WHERE group_id = l_rcv_txn_interface_rec.group_id
      ;

   IF (l_debug = 1) THEN
      print_debug('There are '|| to_char(l_num_recs_per_group) || ' records in WLPNC for this group_ID : '|| l_rcv_txn_interface_rec.group_id, 4);
   END IF;
   l_progress := '40';

   -- one rti record gets processed
   g_num_recs_per_group := g_num_recs_per_group + 1;

   FOR i IN 1..g_error_rhi_id_tb.COUNT LOOP
      IF l_rcv_txn_interface_rec.shipment_header_id = g_error_rhi_id_tb(i) THEN
	 IF (l_debug = 1) THEN
   	 print_debug('This interface_transaction_ID : '||p_interface_transaction_id||' belongs to this RCV_SHIPMENT_HEADER record : '||l_rcv_txn_interface_rec.shipment_header_id || ' that has errored out.', 4);
	 END IF;
	 l_is_header_error := TRUE;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END LOOP;

   --default following values from RTI
   l_organization_id := l_rcv_txn_interface_rec.to_organization_id;
   l_inventory_item_id := l_rcv_txn_interface_rec.item_id;   --??
   l_revision := l_rcv_txn_interface_rec.item_revision;
   l_shipment_header_id := l_rcv_txn_interface_rec.shipment_header_id;
   l_po_line_id := l_rcv_txn_interface_rec.po_line_id;


   l_progress := '50';

   -- validate the total quantity within WMS_LPN_CONTENTS_INTERFACE for one RTI record
   -- matches RTI quantity

   --
   -- Validate the quantity based on group and item
   --

   if (g_num_recs_per_group = l_num_recs_per_group)
   then
      IF (l_debug = 1) THEN
         print_debug ('Quantity Validation at the end of the LPN ', 4);
         print_debug(' Total quantity LPN '|| l_total_quantity, 4);
         print_debug(' Total quantity RTI '|| l_total_quantity_rti, 4);
      END IF;

      for c_group in (
	SELECT group_id,
	  item_id,
          item_num,
          validation_flag,
          processing_status_code,
          PO_LINE_LOCATION_ID,
          SHIPMENT_NUM
	  FROM rcv_transactions_interface where group_id = l_rcv_txn_interface_rec.group_id
           and item_id is not null )
      loop
	 IF (l_debug = 1) THEN
   	 print_debug(' 1. Group Id' || c_group.group_id , 4);
   	 print_debug(' 2. Item Id' || c_group.item_id , 4);
   	 print_debug(' 3. Item Num' || c_group.item_num , 4);
	 END IF;

      BEGIN

      SELECT nvl(SUM(quantity),0)
	INTO l_total_quantity
	FROM wms_lpn_contents_interface
	WHERE group_id =  c_group.group_id
          AND item_num =  c_group.item_num
        ;

      SELECT nvl(SUM(quantity),0)
	INTO l_total_quantity_rti
	FROM rcv_transactions_interface
	WHERE group_id = c_group.group_id
          AND item_id  = c_group.item_id
        ;
       EXCEPTION
       WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
   	 print_debug('Unexpected error while calculating total quantity within WMS_LPN_CONTENTS_INTERFACE.', 4);
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

      IF l_total_quantity < l_total_quantity_rti THEN
      IF (l_debug = 1) THEN
         print_debug('Total quantity within WMS_LPN_CONTENTS_INTERFACE shpuld not be less than quantity in RCV_TRANSACTIONS_INTERFACE for this interface_transaction_id at any time : ' || p_interface_transaction_id, 4);
         print_debug('l_total_quantity = ' || l_total_quantity, 4);
         print_debug('l_total_quantity_rti = ' || l_total_quantity_rti, 4);
         print_debug('l_rcv_txn_interface_rec.quantity = '|| l_rcv_txn_interface_rec.quantity, 4);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
      END IF;

   end loop;

   end if;

   -- validate UOM Code within WMS_LPN_CONTENTS_INTERFACE for one RTI record
   -- matches RTI UOM Code

   BEGIN
      SELECT uom_code
	INTO l_rcv_txn_interface_rec.uom_code
	FROM mtl_units_of_measure
	WHERE unit_of_measure = l_rcv_txn_interface_rec.unit_of_measure;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
   	 print_debug('Unexpected error in UOM to UOM code converstion ' || p_interface_transaction_id, 4);
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   OPEN l_lpn_interface_uom_curs;

   LOOP
      FETCH l_lpn_interface_uom_curs INTO l_lpn_interface_uom_rec;
      EXIT WHEN l_lpn_interface_uom_curs%notfound;

      IF l_lpn_interface_UOM_rec.uom_code IS NOT NULL AND
	l_rcv_txn_interface_rec.uom_code <> l_lpn_interface_UOM_rec.uom_code THEN
	 IF (l_debug = 1) THEN
   	 print_debug('UOM Code in WMS_LPN_Content_Interface does not match the UOM Code in RCV_TRANSACTIONS_INTERFACE for this interface_transaction_id : ' || p_interface_transaction_id, 4);
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

   END LOOP;

   CLOSE l_lpn_interface_uom_curs;

   l_progress := '55';

   OPEN l_cur_lpn_interface;
   -- loop through WMS_LPN_CONTENTS_INTERFACE records for this txn_intf_id
   LOOP
      FETCH l_cur_lpn_interface INTO l_lpn_interface_rec;
      EXIT WHEN l_cur_lpn_interface%notfound;

      -- create LPN
      l_lpn_rec.license_plate_number := l_lpn_interface_rec.license_plate_number;
      IF (l_debug = 1) THEN
         print_debug('Process WMS_LPN_Content_Interface record ' ||l_lpn_interface_rec.license_plate_number, 4);
      END IF;
      l_progress := '60';


      IF wms_container_pub.validate_lpn(l_lpn_rec) = inv_validate.f THEN
	 wms_container_pub.create_lpn
	   (p_api_version  => l_api_version,
	    x_return_status => l_return_status,
	    x_msg_count => l_msg_count,
	    x_msg_data => l_msg_data,
	    p_lpn => l_lpn_interface_rec.license_plate_number,
	    p_organization_id => l_organization_id,
	    x_lpn_id => l_lpn_id,
	    p_source => 7,
	    p_source_type_id => 1, -- PO
	    p_source_header_id => l_shipment_header_id,
	    p_source_name => l_rcv_txn_interface_rec.shipment_num    -- Need to be passed for clearing lpn contents during confirm receive
	    );


	 -- IF l_return_status <> FND_API.g_ret_sts_success THEN
	 IF ( (l_return_status = FND_API.g_ret_sts_error) or (l_return_status = FND_API.g_ret_sts_unexp_error) ) THEN
            x_return_status := l_return_status;
	    IF (l_debug = 1) THEN
   	    print_debug('Failed to create LPN. ', 4);
	    END IF;
	    l_progress := '65';

	    FND_MESSAGE.SET_NAME('WMS', 'WMS_LPN_GENERATION_FAIL');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.g_exc_error;

	 END IF;

       ELSE   -- lpn exists
	 IF (l_debug = 1) THEN
   	 print_debug('This is an exisiting License Plate Number in the system. ', 4);
	 END IF;
	 l_progress := '70';

	 BEGIN
	    SELECT lpn_id
	      INTO l_lpn_id
	      FROM wms_license_plate_numbers
	      WHERE license_plate_number = l_lpn_interface_rec.license_plate_number
	      AND source_header_id = l_shipment_header_id
	      AND lpn_context = 7
	      AND source_type_id = 1;

	    IF (l_debug = 1) THEN
   	    print_debug('But it is for the shipment that is currently importing. OK to proceed.', 4);
	    END IF;

	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug = 1) THEN
   	       print_debug('And this License Plate Number is not for this shipment. ', 4);
	       END IF;
	       l_progress := '80';
	       -- this existing LPN is not for this shipment
	       FND_MESSAGE.SET_NAME('WMS', 'WMS_ASN_INTF_LPN_EXIST');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.g_exc_error;
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Unexpected error while checking if the existing LPN matches the current shipment. ', 4);
	       END IF;
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END;

	 l_progress := '80';
      END IF;

      IF (l_debug = 1) THEN
         print_debug('LPN has been created. ', 4);
      END IF;
      l_progress := '90';

      BEGIN
	 SELECT lot_control_code,
	   serial_number_control_code,
	   shelf_life_code,
	   shelf_life_days
	   INTO l_lot_control_code,
	   l_serial_control_code,
	   l_shelf_life_code,
	   l_shelf_life_days
	   FROM mtl_system_items
	   WHERE inventory_item_id = l_inventory_item_id
	   AND organization_id = l_organization_id;

      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
   	    print_debug('Item validation failed unexpectedly while querying lot_control_code, etc. ', 4);
	    END IF;
	    l_progress := '100';
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;


      -- validate/insert lot
      IF l_lpn_interface_rec.lot_number IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	 print_debug('Lot number exists in WMS_LPN_CONTENTS_INTERFACE : ' || l_lpn_interface_rec.lot_number, 4);
	 END IF;
	 l_progress := '110';

	 IF l_lot_control_code <> 2 THEN
	    IF (l_debug = 1) THEN
   	    print_debug('This item is not lot controlled though. Proceed procesing as non-lot controlled.', 4);
	    END IF;
	    l_progress := '120';
	    l_lpn_interface_rec.lot_number := NULL;

	  ELSE

/***********************************************************************
Calling New API to validate Lot Attributes
This is replaced by the new call below.
*************************************************************************/
/*
            inv_lot_api_pub.validate_unique_lot
	   (p_org_id => l_organization_id,
	    p_inventory_item_id => l_inventory_item_id,
	    p_lot_uniqueness => NULL,
	    p_auto_lot_number => l_lpn_interface_rec.lot_number)
	    THEN

	    IF l_shelf_life_code = 2 THEN
	       l_expiration_date := l_expiration_date + l_shelf_life_days;
	       IF (l_debug = 1) THEN
   	       print_debug('Item is shelf life controlled, expiration date : ' || l_expiration_date, 4);
	       END IF;
	       l_progress := '125';
	    END IF;

	    IF (l_debug = 1) THEN
   	    print_debug('About to insert a lot - nothing will happen if this lot/item combination already exists', 4);
	    END IF;
	    l_progress := '130';

	    inv_lot_api_pub.insertlot
	      (p_api_version => l_api_version,
	       p_inventory_item_id => l_inventory_item_id,
	       p_organization_id => l_organization_id,
	       p_lot_number =>  l_lpn_interface_rec.lot_number,
	       p_expiration_date => l_expiration_date,
	       x_object_id => l_object_id,
	       x_return_status => l_return_status,
	       x_msg_count => l_msg_count,
	       x_msg_data => l_msg_data);


	    IF l_return_status <> FND_API.g_ret_sts_success THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Lot insertion failed. ', 4);
	       END IF;
	       l_progress := '140';

	       FND_MESSAGE.SET_NAME('WMS', 'WMS_ASN_INTF_INST_LOT_FAIL');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


	    END IF;
*/
--Call to New Lot Validation API here

           IF (l_debug = 1) THEN
              print_debug('Before Calling procedure to validate Lot' , 4);
           END IF;

           -- Check for Lot UniqueNess
           /* Bug 2224521 */
           --
           -- Call the API provided in Standard Lot API.
           -- This is to ensure that no other transactions
           -- is accessing the same Lot while this trnsaction is running
           --
               IF (l_debug = 1) THEN
                  print_debug('Before Calling Validate Unique Lot API ', 4);
               END IF;

               l_valid_lot := inv_lot_api_pub.validate_unique_lot(l_organization_id,
                                                    l_inventory_item_id,
                                                    '',
                                                    l_lpn_interface_rec.lot_number);
               if l_valid_lot then
                  null;
               else
                  fnd_message.set_name('INV','INV_INT_LOTUNIQEXP');
                  fnd_msg_pub.add;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               end if;

           wms_asn_lot_att.validate_lot ( l_return_status,l_msg_count,
              l_msg_data,p_interface_transaction_id    );

           IF (l_debug = 1) THEN
              print_debug('After  Calling procedure to validate Lot' , 4);
           END IF;

	    IF l_return_status <> FND_API.g_ret_sts_success THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Creating Lot number failed - Existing Lot', 4);
	       END IF;
	       l_progress := '130';

	       FND_MESSAGE.SET_NAME('WMS', 'WMS_ASN_INTF_INST_LOT_FAIL');
	       FND_MSG_PUB.ADD;

               /* Bug 2224521 -- For Existing Lots we don't raise an error */
	       -- RAISE FND_API.g_exc_error;

	    END IF;


/************************************************************************
This part is not needed anymore as lot unique ness check is taken care
by the above call
************************************************************************/

/*
	  ELSE
	    IF (l_debug = 1) THEN
   	    print_debug('Lot uniqueness check failed ', 4);
	    END IF;
	    l_progress := '150';
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
*/

	 END IF;


       ELSIF l_lpn_interface_rec.lot_number IS NULL
	 AND l_lot_control_code = 2 THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Required lot number is not passed for a lot controlled item ', 4);
	       END IF;
	       l_progress := '160';
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- validate/insert serial
      IF l_lpn_interface_rec.from_serial_number IS NOT NULL
	AND l_lpn_interface_rec.to_serial_number IS NOT NULL THEN

	 IF (l_debug = 1) THEN
   	 print_debug('Serial numbers exist in WMS_LPN_CONTENTS_INTERFACE - FROM : ' || l_lpn_interface_rec.from_serial_number || ' TO : ' || l_lpn_interface_rec.to_serial_number, 4);
	 END IF;
	 l_progress := '170';

	 IF l_serial_control_code <> 2 AND
	   l_serial_control_code <> 5 THEN
	    IF (l_debug = 1) THEN
   	    print_debug('This item is not serial controlled though. Proceed procesing as non-serial controlled.', 4);
	    END IF;
	    l_progress := '180';
	    l_lpn_interface_rec.from_serial_number := NULL;
	    l_lpn_interface_rec.to_serial_number := NULL;
	 ELSE

            /* This is Replaced by the New Serial Validation API

	    inv_serial_number_pub.insert_range_serial
	      (p_api_version => l_api_version,
	       p_inventory_item_id => l_inventory_item_id,
	       p_organization_id => l_organization_id,
	       p_from_serial_number => l_lpn_interface_rec.from_serial_number,
	       p_to_serial_number => l_lpn_interface_rec.to_serial_number,
	       p_initialization_date => Sysdate,
	       p_completion_date => NULL,
	       p_ship_date => NULL,
	       p_revision => l_revision,
	       p_lot_number => l_lpn_interface_rec.lot_number,
	       p_current_locator_id => NULL,
	       p_subinventory_code => NULL,
	       p_trx_src_id => NULL,
	       p_unit_vendor_id => NULL,
	       p_vendor_lot_number => NULL,
	       p_vendor_serial_number => NULL,
	       p_receipt_issue_type => NULL,
	       p_txn_src_id => NULL,
	       p_txn_src_name => NULL,
	       p_txn_src_type_id => NULL,
	       p_transaction_id => NULL,
	       p_current_status => 5,
	       p_parent_item_id => NULL,
	       p_parent_serial_number => NULL,
	       p_cost_group_id => NULL,
	       p_transaction_action_id => 27,
	       p_transaction_temp_id => NULL,
	       p_status_id => NULL,
	       p_inspection_status => NULL,
	       x_object_id => l_object_id,
	       x_return_status => x_return_status,
	       x_msg_count => x_msg_count,
	       x_msg_data => x_msg_data);
            */

	    wms_asn_lot_att.insert_range_serial
	      (p_inventory_item_id => l_inventory_item_id,
	       p_organization_id => l_organization_id,
	       p_from_serial_number => l_lpn_interface_rec.from_serial_number,
	       p_to_serial_number => l_lpn_interface_rec.to_serial_number,
	       p_initialization_date => Sysdate,
	       p_completion_date => NULL,
	       p_ship_date => NULL,
	       p_revision => l_revision,
	       p_lot_number => l_lpn_interface_rec.lot_number,
	       p_current_locator_id => NULL,
	       p_subinventory_code => NULL,
	       p_trx_src_id => NULL,
	       p_unit_vendor_id => NULL,
	       p_vendor_lot_number => NULL,
	       p_vendor_serial_number => NULL,
	       p_receipt_issue_type => NULL,
	       p_txn_src_id => NULL,
	       p_txn_src_name => NULL,
	       p_txn_src_type_id => NULL,
	       p_transaction_id => NULL,
	       p_current_status => 5,
	       p_parent_item_id => NULL,
	       p_parent_serial_number => NULL,
	       p_cost_group_id => NULL,
	       p_serial_transaction_intf_id => l_lpn_interface_rec.serial_transaction_intf_id,
	       p_status_id => NULL,
	       p_inspection_status => NULL,
	       x_object_id => l_object_id,
	       x_return_status => l_return_status,
	       x_msg_count => x_msg_count,
	       x_msg_data => x_msg_data);

	    --IF l_return_status <> FND_API.g_ret_sts_success THEN
	      IF ( (l_return_status = FND_API.g_ret_sts_error) or (l_return_status = FND_API.g_ret_sts_unexp_error) ) THEN
               x_return_status := l_return_status;
	       IF (l_debug = 1) THEN
   	       print_debug('Creating serial number failed', 4);
	       END IF;
	       l_progress := '190';

	       FND_MESSAGE.SET_NAME('WMS', 'WMS_ASN_INTF_INST_SERIAL_FAIL');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.g_exc_error;
	    END IF;
         END IF;

       ELSIF (l_lpn_interface_rec.from_serial_number IS NULL OR
              l_lpn_interface_rec.to_serial_number IS NULL) AND
                (l_serial_control_code = 2 OR
                 l_serial_control_code = 5) THEN
         IF (l_debug = 1) THEN
            print_debug('Required serial number is not passed for a serial controlled item ', 4);
         END IF;
         l_progress := '200';

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (l_debug = 1) THEN
         print_debug('Pack this interface record into LPN ', 4);
      END IF;
      l_progress := '210';

      -- pack LPN
      WMS_Container_PUB.PackUnpack_Container
	(p_api_version => l_api_version,
	 x_return_status => l_return_status,
	 x_msg_count => l_msg_count,
	 x_msg_data => l_msg_data,
	 p_lpn_id => l_lpn_id,
	 p_content_lpn_id => NULL,
	 p_content_item_id => l_inventory_item_id,
	 p_content_item_desc => l_lpn_interface_rec.item_description,
	 p_revision => l_revision,
	 p_lot_number => l_lpn_interface_rec.lot_number,
	 p_from_serial_number => l_lpn_interface_rec.from_serial_number,
	 p_to_serial_number => l_lpn_interface_rec.to_serial_number,
	 p_quantity => l_lpn_interface_rec.quantity,
	 p_uom => l_rcv_txn_interface_rec.uom_code,
	 p_organization_id => l_organization_id,
	 p_subinventory => NULL,
	 p_locator_id => NULL,
	 p_enforce_wv_constraints => NULL,
	 p_operation => 1, -- pack
	 p_cost_group_id => NULL,
	 p_source_type_id => 1, -- PO
	 p_source_header_id => NULL,
	 p_source_name => NULL,
	 p_source_line_id => l_po_line_id,
	 p_source_line_detail_id => NULL,
	 p_homogeneous_container => NULL,
	 p_match_locations => NULL,
	 p_match_lpn_context => NULL,
	p_match_lot => NULL,
	p_match_cost_groups => NULL,
	p_match_mtl_status => NULL
	);

      -- IF l_return_status <> FND_API.g_ret_sts_success THEN
      IF ( (l_return_status = FND_API.g_ret_sts_error) or (l_return_status = FND_API.g_ret_sts_unexp_error) ) THEN
         x_return_status := l_return_status;
	 IF (l_debug = 1) THEN
   	 print_debug('LPN Packing failed ', 4);
	 END IF;
	 l_progress := '220';

	 FND_MESSAGE.SET_NAME('WMS', 'WMS_ASN_INTF_PACK_LPN_FAIL');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END LOOP;

   l_progress := '230';

   CLOSE l_cur_lpn_interface;

   l_progress := '240';



    -- Adding WMS ASN Discrepancy Report Specific Call.
    l_progress := '241';
    -- Initialize Values
	 l_asn_details_rec.group_id            := l_rcv_txn_interface_rec.group_id ;
         l_asn_details_rec.to_organization_id  := l_rcv_txn_interface_rec.to_organization_id ;
	 l_asn_details_rec.item_id             := l_rcv_txn_interface_rec.item_id           ;
	 l_asn_details_rec.item_revision       := l_rcv_txn_interface_rec.item_revision    ;
	 l_asn_details_rec.shipment_header_id  := l_rcv_txn_interface_rec.shipment_header_id ;
	 l_asn_details_rec.po_line_id          := l_rcv_txn_interface_rec.po_line_id    ;
	 l_asn_details_rec.quantity            := l_rcv_txn_interface_rec.quantity    ;
	 l_asn_details_rec.unit_of_measure     := l_rcv_txn_interface_rec.unit_of_measure;
	 l_asn_details_rec.uom_code            := l_rcv_txn_interface_rec.uom_code   ;
	 l_asn_details_rec.header_interface_id := l_rcv_txn_interface_rec.header_interface_id;


    inv_cr_asn_details.create_asn_details_from_intf(
    l_asn_details_rec,
    x_return_status,
    x_msg_data
    );



   -- Commented this Part to do the Quantity Check for wms_lpn_contents_interface
   --
   -- DELETE wms_lpn_contents_interface
   --  WHERE interface_transaction_id = p_interface_transaction_id;

   l_progress := '250';

   IF (l_debug = 1) THEN
      print_debug('Process - after processing WMS_LPN_CONTENTS_INTERFACE - g_num_recs_per_group = ' || g_num_recs_per_group, 4);
   END IF;

   l_progress := '260';

   IF g_num_recs_per_group = l_num_recs_per_group THEN  -- this is the last record in this group for LPN, call printing

   IF (l_debug = 1) THEN
      print_debug('Process - Processing WMS_LPN_CONTENTS_INTERFACE - Before Deletion from wms_lpn_contents_interface ' , 4);
   END IF;

    DELETE wms_lpn_contents_interface
     WHERE group_id = l_rcv_txn_interface_rec.group_id ;

      OPEN l_print_lpn_curs (l_rcv_txn_interface_rec.group_id);

      LOOP
	 FETCH l_print_lpn_curs
	   INTO l_input_param_rec(1).lpn_id;
	 EXIT WHEN l_print_lpn_curs%notfound;

      END LOOP;

      CLOSE l_print_lpn_curs;

      IF (l_debug = 1) THEN
         print_debug('Process - before calling inv_label.print_label', 4);
      END IF;

      l_progress := '270';

      inv_label.print_label
	(x_return_status => l_return_status
	 , x_msg_count => l_msg_count
	 , x_msg_data  => l_msg_data
	 , x_label_status  => l_label_status
	 , p_api_version   => 1.0
	 , p_print_mode =>2
	 , p_business_flow_code => 25
	 , p_input_param_rec => l_input_param_rec
	 );

      IF (l_debug = 1) THEN
         print_debug('Process - after calling inv_label.print_label', 1);
      END IF;
      l_progress := '280';

   END IF;

   IF (l_debug = 1) THEN
      print_debug('Process complete', 1);
   END IF;



EXCEPTION
   WHEN FND_API.g_exc_error THEN
      IF (l_debug = 1) THEN
         print_debug('Process - expected error happened - l_progress : '||l_progress, 1);
      END IF;

      IF l_is_header_error <> TRUE THEN
	 g_error_rhi_id_tb(g_error_rhi_id_tb.COUNT + 1) := l_rcv_txn_interface_rec.shipment_header_id;
	 shipment_header_cleanup(l_rcv_txn_interface_rec.shipment_header_id);

      END IF;

      ROLLBACK TO process_lpn_intf;

      IF l_cur_lpn_interface%isopen THEN
	CLOSE l_cur_lpn_interface;
      END IF;
      IF l_print_lpn_curs%isopen THEN
	CLOSE l_print_lpn_curs;
      END IF;
      IF l_lpn_interface_uom_curs%isopen THEN
	CLOSE l_lpn_interface_uom_curs;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(p_count	=>	x_msg_count,
	 p_data		=>	x_msg_data
	 );


   WHEN FND_API.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
         print_debug('Process - unexpected error happened - l_progress : '||l_progress, 1);
      END IF;

      IF l_is_header_error <> TRUE THEN
	 g_error_rhi_id_tb(g_error_rhi_id_tb.COUNT + 1) := l_rcv_txn_interface_rec.shipment_header_id;
	 shipment_header_cleanup(l_rcv_txn_interface_rec.shipment_header_id);
      END IF;

      ROLLBACK TO process_lpn_intf;

      IF l_cur_lpn_interface%isopen THEN
	CLOSE l_cur_lpn_interface;
      END IF;
      IF l_print_lpn_curs%isopen THEN
	CLOSE l_print_lpn_curs;
      END IF;
      IF l_lpn_interface_uom_curs%isopen THEN
	CLOSE l_lpn_interface_uom_curs;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(p_count	=>	x_msg_count,
	 p_data		=>	x_msg_data
	 );


   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('Process - other error happened  - l_progress : '||l_progress, 1);
      END IF;

      IF l_is_header_error <> TRUE THEN
	 g_error_rhi_id_tb(g_error_rhi_id_tb.COUNT + 1) := l_rcv_txn_interface_rec.shipment_header_id;
	 shipment_header_cleanup(l_rcv_txn_interface_rec.shipment_header_id);

      END IF;

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	 print_debug('SQL Error : '||SQLERRM(SQLCODE)||' SQL Error code : '||SQLCODE, 1);
	 END IF;
      END IF;

      ROLLBACK TO process_lpn_intf;
      IF l_cur_lpn_interface%isopen THEN
        CLOSE l_cur_lpn_interface;
      END IF;
      IF l_print_lpn_curs%isopen THEN
	CLOSE l_print_lpn_curs;
      END IF;
      IF l_lpn_interface_uom_curs%isopen THEN
	CLOSE l_lpn_interface_uom_curs;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END process;




PROCEDURE print_label
  (p_shipment_header_id     IN  NUMBER)
  IS
     CURSOR l_lpn_curs IS
	SELECT lpn_id
	  FROM wms_license_plate_numbers
	  WHERE  source_header_id = p_shipment_header_id
	  AND lpn_context = 7
	  AND source_type_id = 1;



     l_input_param_rec INV_LABEL.input_parameter_rec_type;
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(400);
     l_label_status VARCHAR2(500);


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   OPEN l_lpn_curs;

   LOOP
      FETCH l_lpn_curs
	INTO l_input_param_rec(1).lpn_id;
      EXIT WHEN l_lpn_curs%notfound;

   END LOOP;

   CLOSE l_lpn_curs;

   inv_label.print_label
     (x_return_status => l_return_status
      , x_msg_count => l_msg_count
      , x_msg_data  => l_msg_data
      , x_label_status  => l_label_status
      , p_api_version   => 1.0
      , p_print_mode =>1
      , p_business_flow_code => 25
      , p_input_param_rec => l_input_param_rec
      );


EXCEPTION
   WHEN OTHERS THEN
      IF l_lpn_curs%isopen THEN
	 CLOSE l_lpn_curs;
       ELSE
	 NULL;
      END IF;


END print_label;



END WMS_ASN_INTERFACE;

/
