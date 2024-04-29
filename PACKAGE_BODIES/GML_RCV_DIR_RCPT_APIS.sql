--------------------------------------------------------
--  DDL for Package Body GML_RCV_DIR_RCPT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_RCV_DIR_RCPT_APIS" AS
/* $Header: GMLDIRDB.pls 120.0 2005/05/25 16:19:24 appldev noship $*/

g_interface_transaction_id  NUMBER;

PROCEDURE populate_default_values
  (p_rcv_transaction_rec IN OUT NOCOPY gml_rcv_std_rcpt_apis.rcv_transaction_rec_tp,
   p_rcv_rcpt_rec IN OUT NOCOPY gml_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp,
   p_group_id IN NUMBER,
   p_organization_id IN NUMBER,
   p_item_id IN NUMBER,
   p_revision IN VARCHAR2,
   p_source_type IN VARCHAR2,
   p_subinventory_code IN VARCHAR2,
   p_locator_id IN NUMBER,
   p_transaction_temp_id IN NUMBER,
   p_lot_control_code IN NUMBER,
   p_serial_control_code IN NUMBER)
  IS

     l_interface_transaction_id NUMBER;
     -- this is used to keep track of the id used to insert the row in rti

     l_lot_serial_break_tbl gml_rcv_common_apis.trans_rec_tb_tp;
     -- table that will store the record into which the lot/serial entered
     -- have to be broken.

--     l_transaction_type VARCHAR2(20) := 'DELIVER';
     -- I thought till 07/16/2000 that this should be deliver, but seems
     -- that it should actually be receive.
     l_transaction_type VARCHAR2(20) := 'RECEIVE';
     l_valid_ship_to_location BOOLEAN;
     l_valid_deliver_to_location BOOLEAN;
     l_valid_deliver_to_person BOOLEAN;
     l_valid_subinventory BOOLEAN;

     CURSOR Get_Item_No IS
         select segment1
         from mtl_system_items
         where inventory_item_id = p_item_id and
               organization_id=p_organization_id;

BEGIN


   --validate deliver to info
   rcv_transactions_sv.val_destination_info
     (p_organization_id,
      p_item_id,
      NULL,
      p_rcv_rcpt_rec.deliver_to_location_id,
      p_rcv_rcpt_rec.deliver_to_person_id,
      p_rcv_rcpt_rec.destination_subinventory,
      l_valid_ship_to_location,
      l_valid_deliver_to_location,
      l_valid_deliver_to_person,
      l_valid_subinventory);


   -- since user fill in deliver to subinventory and locator, and they are validated through LOV
   -- we dont need to validate or default them here as receiving does.

   IF l_valid_deliver_to_person THEN
      p_rcv_transaction_rec.deliver_to_person_id := p_rcv_rcpt_rec.deliver_to_person_id;
   END IF;

   IF l_valid_deliver_to_location THEN
      p_rcv_transaction_rec.deliver_to_location_id := p_rcv_rcpt_rec.deliver_to_location_id;
   END IF;

   p_rcv_transaction_rec.destination_subinventory := p_subinventory_code;
   p_rcv_transaction_rec.locator_id := p_locator_id;

   -- revision should be passed into matching logic

   p_rcv_transaction_rec.item_revision := p_revision;
   p_rcv_rcpt_rec.item_revision := p_revision;

   l_interface_transaction_id := gml_rcv_std_rcpt_apis.insert_txn_interface
     (p_rcv_transaction_rec,
      p_rcv_rcpt_rec,
      p_group_id,
      l_transaction_type,
      p_organization_id,
      p_rcv_transaction_rec.deliver_to_location_id,
      p_source_type);

    --Store the interface_transaction_id in a global variable
    g_interface_transaction_id := l_interface_transaction_id;

/*

   l_lot_serial_break_tbl(1).transaction_id := l_interface_transaction_id;
   l_lot_serial_break_tbl(1).primary_quantity := p_rcv_transaction_rec.primary_quantity;
   l_lot_serial_break_tbl(1).unit_of_measure := p_rcv_transaction_rec.transaction_uom;

   OPEN Get_Item_No;
   FETCH Get_Item_No INTO l_lot_serial_break_tbl(1).item_no;
   CLOSE Get_Item_No;
*/

END populate_default_values;


PROCEDURE create_osp_drct_dlvr_rti_rec (p_move_order_header_id IN OUT NOCOPY NUMBER,
					p_organization_id IN NUMBER,
					p_po_header_id IN NUMBER,
					p_po_release_id IN NUMBER,
					p_po_line_id IN NUMBER,
					p_po_line_location_id IN NUMBER,
					p_po_distribution_id IN NUMBER,
					p_item_id IN NUMBER,
					p_rcv_qty IN NUMBER,
					p_rcv_uom IN VARCHAR2,
					p_rcv_uom_code IN VARCHAR2,
					p_source_type IN VARCHAR2,
					p_transaction_temp_id IN NUMBER,
					p_revision IN VARCHAR2,
					x_status OUT NOCOPY VARCHAR2,
					x_message OUT NOCOPY VARCHAR2)
  IS
     l_rcpt_match_table_detail GML_RCV_TXN_INTERFACE.cascaded_trans_tab_type;  -- output for matching algorithm
     l_rcv_transaction_rec gml_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block

     l_transaction_type VARCHAR2(20) := 'DELIVER';
     l_total_primary_qty NUMBER := 0;

     l_msg_count NUMBER;
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;

     l_group_id NUMBER;
     l_rcv_rcpt_rec gml_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;

     l_err_message VARCHAR2(100);
     l_temp_message VARCHAR2(100);
     l_msg_prod VARCHAR2(5);

     l_progress VARCHAR2(10);


     CURSOR l_curs_rcpt_detail
       (v_po_distribution_id NUMBER)
       IS
	  SELECT
	    'N'       LINE_CHKBOX,
	    'VENDOR'        SOURCE_TYPE_CODE,
	    'VENDOR'        RECEIPT_SOURCE_CODE,
	    'PO'        ORDER_TYPE_CODE,
	    ''       ORDER_TYPE,
	    POLL.PO_HEADER_ID        PO_HEADER_ID,
	    POH.SEGMENT1        PO_NUMBER,
	    POLL.PO_LINE_ID        PO_LINE_ID,
	    POL.LINE_NUM        PO_LINE_NUMBER,
	    POLL.LINE_LOCATION_ID        PO_LINE_LOCATION_ID,
	    POLL.SHIPMENT_NUM        PO_SHIPMENT_NUMBER,
	    POLL.PO_RELEASE_ID        PO_RELEASE_ID,
	    POR.RELEASE_NUM        PO_RELEASE_NUMBER,
	    TO_NUMBER(NULL)        REQ_HEADER_ID,
	    NULL        REQ_NUMBER,
	    TO_NUMBER(NULL)        REQ_LINE_ID,
	    TO_NUMBER(NULL)        REQ_LINE,
	    TO_NUMBER(NULL)        REQ_DISTRIBUTION_ID,
	    POH.PO_HEADER_ID        RCV_SHIPMENT_HEADER_ID,
	    POH.SEGMENT1        RCV_SHIPMENT_NUMBER,
	    POL.PO_LINE_ID        RCV_SHIPMENT_LINE_ID,
	    POL.LINE_NUM        RCV_LINE_NUMBER,
	    POH.PO_HEADER_ID        FROM_ORGANIZATION_ID,
	    POLL.SHIP_TO_ORGANIZATION_ID        TO_ORGANIZATION_ID,
	    POH.VENDOR_ID        VENDOR_ID,
	    ''       SOURCE,
	    POH.VENDOR_SITE_ID        VENDOR_SITE_ID,
	    ''       OUTSIDE_OPERATION_FLAG,
	    POL.ITEM_ID        ITEM_ID,
	    NULL uom_code,
	    POL.UNIT_MEAS_LOOKUP_CODE        PRIMARY_UOM,
	    MUM.UOM_CLASS        PRIMARY_UOM_CLASS,
	    NULL       ITEM_ALLOWED_UNITS_LOOKUP_CODE,
	    NULL       ITEM_LOCATOR_CONTROL,
	    ''       RESTRICT_LOCATORS_CODE,
	    ''       RESTRICT_SUBINVENTORIES_CODE,
	    NULL       SHELF_LIFE_CODE,
	    NULL       SHELF_LIFE_DAYS,
	    MSI.SERIAL_NUMBER_CONTROL_CODE        SERIAL_NUMBER_CONTROL_CODE,
	    MSI.LOT_CONTROL_CODE        LOT_CONTROL_CODE,
	    DECODE(MSI.REVISION_QTY_CONTROL_CODE,1,'N',2,'Y','N')        ITEM_REV_CONTROL_FLAG_TO,
	    NULL        ITEM_REV_CONTROL_FLAG_FROM,
	    NULL        ITEM_NUMBER,
	    POL.ITEM_REVISION        ITEM_REVISION,
	    POL.ITEM_DESCRIPTION        ITEM_DESCRIPTION,
	    POL.CATEGORY_ID        ITEM_CATEGORY_ID,
	    ''       HAZARD_CLASS,
	    ''       UN_NUMBER,
	    POL.VENDOR_PRODUCT_NUM        VENDOR_ITEM_NUMBER,
	    POLL.SHIP_TO_LOCATION_ID        SHIP_TO_LOCATION_ID,
	    ''       SHIP_TO_LOCATION,
	    NULL        PACKING_SLIP,
	    POLL.RECEIVING_ROUTING_ID        ROUTING_ID,
	    ''       ROUTING_NAME,
	    POLL.NEED_BY_DATE        NEED_BY_DATE,
	    NVL(POLL.PROMISED_DATE,POLL.NEED_BY_DATE)        EXPECTED_RECEIPT_DATE,
	    POLL.QUANTITY        ORDERED_QTY,
	    POL.UNIT_MEAS_LOOKUP_CODE        ORDERED_UOM,
	    NULL        USSGL_TRANSACTION_CODE,
	    POLL.GOVERNMENT_CONTEXT        GOVERNMENT_CONTEXT,
	    POLL.INSPECTION_REQUIRED_FLAG        INSPECTION_REQUIRED_FLAG,
	    POLL.RECEIPT_REQUIRED_FLAG        RECEIPT_REQUIRED_FLAG,
	    POLL.ENFORCE_SHIP_TO_LOCATION_CODE        ENFORCE_SHIP_TO_LOCATION_CODE,
	    NVL(POLL.PRICE_OVERRIDE,POL.UNIT_PRICE)       UNIT_PRICE,
	    POH.CURRENCY_CODE        CURRENCY_CODE,
	    POH.RATE_TYPE        CURRENCY_CONVERSION_TYPE,
	    POH.RATE_DATE        CURRENCY_CONVERSION_DATE,
	    POH.RATE        CURRENCY_CONVERSION_RATE,
	    POH.NOTE_TO_RECEIVER        NOTE_TO_RECEIVER,
	    pod.destination_type_code        DESTINATION_TYPE_CODE,
	    pod.deliver_to_person_id        DELIVER_TO_PERSON_ID,
	    pod.deliver_to_location_id        DELIVER_TO_LOCATION_ID,
	    pod.destination_subinventory        DESTINATION_SUBINVENTORY,
	    POLL.ATTRIBUTE_CATEGORY        ATTRIBUTE_CATEGORY,
	    POLL.ATTRIBUTE1        ATTRIBUTE1,
	    POLL.ATTRIBUTE2        ATTRIBUTE2,
	    POLL.ATTRIBUTE3        ATTRIBUTE3,
	    POLL.ATTRIBUTE4        ATTRIBUTE4,
	    POLL.ATTRIBUTE5        ATTRIBUTE5,
	    POLL.ATTRIBUTE6        ATTRIBUTE6,
	    POLL.ATTRIBUTE7        ATTRIBUTE7,
	    POLL.ATTRIBUTE8        ATTRIBUTE8,
	    POLL.ATTRIBUTE9        ATTRIBUTE9,
	    POLL.ATTRIBUTE10        ATTRIBUTE10,
	    POLL.ATTRIBUTE11        ATTRIBUTE11,
	    POLL.ATTRIBUTE12        ATTRIBUTE12,
	    POLL.ATTRIBUTE13        ATTRIBUTE13,
	    POLL.ATTRIBUTE14        ATTRIBUTE14,
	    POLL.ATTRIBUTE15        ATTRIBUTE15,
	    POLL.CLOSED_CODE        CLOSED_CODE,
	    NULL       ASN_TYPE,
	    NULL       BILL_OF_LADING,
	    TO_DATE(NULL)       SHIPPED_DATE,
	    NULL       FREIGHT_CARRIER_CODE,
	    NULL       WAYBILL_AIRBILL_NUM,
	    NULL       FREIGHT_BILL_NUM,
	    NULL       VENDOR_LOT_NUM,
	    NULL       CONTAINER_NUM,
	    NULL        TRUCK_NUM,
	    NULL       BAR_CODE_LABEL,
	    ''       RATE_TYPE_DISPLAY,
	    POLL.MATCH_OPTION       MATCH_OPTION,
	    POLL.COUNTRY_OF_ORIGIN_CODE        COUNTRY_OF_ORIGIN_CODE,
	    TO_NUMBER(NULL)        OE_ORDER_HEADER_ID,
	    TO_NUMBER(NULL)        OE_ORDER_NUM,
	    TO_NUMBER(NULL)        OE_ORDER_LINE_ID,
	    TO_NUMBER(NULL)        OE_ORDER_LINE_NUM,
	    TO_NUMBER(NULL)        CUSTOMER_ID,
	    TO_NUMBER(NULL)        CUSTOMER_SITE_ID,
	    NULL        CUSTOMER_ITEM_NUM,
	    NULL pll_note_to_receiver,
	    pod.po_distribution_id,
	    pod.quantity_ordered - pod.quantity_delivered qty_ordered,
	    pod.wip_entity_id,
	    pod.wip_operation_seq_num,
	    pod.wip_resource_seq_num,
	    pod.wip_repetitive_schedule_id,
	    pod.wip_line_id,
	    pod.bom_resource_id,
	    ''      DESTINATION_TYPE,
	    ''      LOCATION,
	    pod.rate currency_conversion_rate_pod,
	    pod.rate_date currency_conversion_date_pod,
	    pod.project_id project_id,
	    pod.task_id task_id
	    FROM
	    PO_HEADERS POH,
	    PO_LINE_LOCATIONS POLL,
	    PO_LINES POL,
	    PO_RELEASES POR,
	    MTL_SYSTEM_ITEMS MSI,
	    MTL_UNITS_OF_MEASURE mum,
	    PO_DISTRIBUTIONS POD
	    WHERE
	    POD.PO_DISTRIBUTION_ID = v_po_distribution_id
	    AND POH.PO_HEADER_ID = POLL.PO_HEADER_ID
	    AND POL.PO_LINE_ID = POLL.PO_LINE_ID
	    AND POLL.PO_RELEASE_ID = POR.PO_RELEASE_ID(+)
	    AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
	    AND MUM.UNIT_OF_MEASURE (+) = POL.UNIT_MEAS_LOOKUP_CODE
	    AND NVL(MSI.ORGANIZATION_ID,POLL.SHIP_TO_ORGANIZATION_ID) = POLL.SHIP_TO_ORGANIZATION_ID
	    AND MSI.INVENTORY_ITEM_ID (+) = POL.ITEM_ID;
BEGIN

   x_status := fnd_api.g_ret_sts_success;
   SAVEPOINT crt_po_rti_sp;
   l_progress := '10';

   -- query po_startup_value
   Begin
      inv_rcv_common_apis.init_startup_values(p_organization_id);
   Exception
      when NO_DATA_FOUND then
	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_PARAM');
	 FND_MSG_PUB.ADD;
	 RAISE ;
   End;

   l_progress := '20';
   -- default l_group_id ? clear group id after done
   IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id is NULL THEN
      SELECT rcv_interface_groups_s.nextval
	INTO   l_group_id
	FROM   dual;
      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
   END IF;

   l_progress := '30';
   OPEN l_curs_rcpt_detail(p_po_distribution_id);
   l_progress := '31';
   FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;

   l_rcv_rcpt_rec.item_id := p_item_id;

   l_progress := '32';
   CLOSE l_curs_rcpt_detail;
   l_progress := '33';

   -- bug 2743146
   -- Make sure that the po_distribution passed does satisfy the tolerance
   -- limits by calling the matching algorithm for that.
   -- initialize input record for matching algorithm
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := p_rcv_qty;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;


   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id := p_organization_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).group_id := l_group_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_header_id := p_po_header_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_release_id := p_po_release_id;

   -- line id, line location id and distribution id will be passed only from the putaway api.
   -- line id however, can also be passed through the UI if the line number
   -- field is enabled on the UI.
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_line_id := l_rcv_rcpt_rec.po_line_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_line_location_id := l_rcv_rcpt_rec.po_line_location_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_distribution_id := p_po_distribution_id;

   IF p_item_id IS NOT NULL THEN
      BEGIN
	 select primary_unit_of_measure
	   into inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
	   from mtl_system_items
	  where mtl_system_items.inventory_item_id = p_item_id
	    and   mtl_system_items.organization_id = p_organization_id;
      EXCEPTION
	 when no_data_found then
	    NULL;

      END;
    ELSE
     inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure := NULL;
   END IF;

   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).revision := p_revision;
   --inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id;
   --inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).task_id := p_task_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := Sysdate;  --?
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?


   l_progress := '40';
   gml_rcv_txn_interface.matching_logic
     (x_return_status       => x_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => x_message,
      x_cascaded_table      => gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross,
      n		            => gml_rcv_std_rcpt_apis.g_receipt_detail_index,
      temp_cascaded_table   => l_rcpt_match_table_detail,
      p_receipt_num         => NULL,
      p_shipment_header_id  => NULL,
      p_lpn_id              => NULL
      );
   -- x_status is not successful if there is any execution error in matching.
   IF x_status = fnd_api.g_ret_sts_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF x_status = fnd_api.g_ret_sts_unexp_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      FND_MESSAGE.SET_NAME('INV', l_err_message);
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_err_message := '@@@';
   FOR i IN inv_rcv_std_rcpt_apis.g_receipt_detail_index..(inv_rcv_std_rcpt_apis.g_receipt_detail_index + l_rcpt_match_table_detail.COUNT - 1) LOOP
      IF l_rcpt_match_table_detail(i-inv_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_status = 'W' THEN
	 x_status := 'W';

	 l_temp_message := l_rcpt_match_table_detail(i-inv_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_message;
	 IF l_temp_message IS NULL THEN
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    l_msg_prod := 'INV';
	    EXIT;
	 END IF;
	 IF l_err_message = '@@@' THEN
	    l_err_message := l_temp_message;
	    l_msg_prod := 'INV';
	  ELSIF l_temp_message <> l_err_message THEN
	    l_msg_prod := 'INV';
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    EXIT;
	 END IF;
      END IF;
   END LOOP;

   IF l_err_message <> '@@@' THEN
      FND_MESSAGE.SET_NAME(l_msg_prod, l_err_message);
      FND_MSG_PUB.ADD;
   END IF;
   -- End bug fix 2743146


   l_progress := '60';


   l_rcv_transaction_rec.po_distribution_id := p_po_distribution_id;

   l_rcv_transaction_rec.transaction_qty := p_rcv_qty;
   l_rcv_transaction_rec.transaction_uom := p_rcv_uom;
   l_rcv_transaction_rec.primary_quantity := rcv_transactions_interface_sv.convert_into_correct_qty(p_rcv_qty,
												    p_rcv_uom,
												    p_item_id,
												    l_rcv_rcpt_rec.primary_uom);
   l_rcv_transaction_rec.primary_uom := l_rcv_rcpt_rec.primary_uom;
   l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;

   l_progress := '64';

   -- update following fields for po_distribution related values
   l_rcv_transaction_rec.currency_conversion_date := l_rcv_rcpt_rec.currency_conversion_date_pod;
   l_rcv_transaction_rec.currency_conversion_rate := l_rcv_rcpt_rec.currency_conversion_rate_pod;
   l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.qty_ordered;
   l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;

   -- wip related fields
   l_rcv_transaction_rec.wip_entity_id := l_rcv_rcpt_rec.wip_entity_id;
   l_rcv_transaction_rec.wip_operation_seq_num := l_rcv_rcpt_rec.wip_operation_seq_num;
   l_rcv_transaction_rec.wip_resource_seq_num := l_rcv_rcpt_rec.wip_resource_seq_num;
   l_rcv_transaction_rec.wip_repetitive_schedule_id := l_rcv_rcpt_rec.wip_repetitive_schedule_id;
   l_rcv_transaction_rec.wip_line_id := l_rcv_rcpt_rec.wip_line_id;
   l_rcv_transaction_rec.bom_resource_id := l_rcv_rcpt_rec.bom_resource_id;

   populate_default_values(p_rcv_transaction_rec => l_rcv_transaction_rec,
			   p_rcv_rcpt_rec => l_rcv_rcpt_rec,
			   p_group_id => l_group_id,
			   p_organization_id => p_organization_id,
			   p_item_id => p_item_id,
			   p_revision => p_revision,
			   p_source_type => p_source_type,
			   p_subinventory_code => NULL,
			   p_locator_id => NULL,
			   p_transaction_temp_id => p_transaction_temp_id,
			   p_lot_control_code => NULL,
			   p_serial_control_code => NULL);

   l_progress := '65';
   inv_rcv_common_apis.do_check
     (p_organization_id => p_organization_id,
      p_inventory_item_id => p_item_id,
      p_transaction_type_id => 18,
      p_primary_quantity => l_total_primary_qty,
      x_return_status => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => x_message);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
   END IF;

   l_progress := '70';

   -- Clear the Lot Rec
   inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error ;
      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );


   WHEN OTHERS THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error ;
      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;
      fnd_msg_pub.count_and_get
	(p_encoded   => FND_API.g_false,
	 p_count     => l_msg_count,
	 p_data      => x_message
	 );


END create_osp_drct_dlvr_rti_rec;


PROCEDURE create_po_drct_dlvr_rti_rec(p_move_order_header_id IN OUT NOCOPY NUMBER,
				      p_organization_id IN NUMBER,
				      p_po_header_id IN NUMBER,
				      p_po_release_id IN NUMBER,
				      p_po_line_id IN NUMBER,
				      p_po_line_location_id IN NUMBER,
				      p_po_distribution_id IN NUMBER,
				      p_item_id IN NUMBER,
				      p_rcv_qty IN NUMBER,
				      p_rcv_sec_qty IN NUMBER,
				      p_rcv_uom IN VARCHAR2,
				      p_rcv_uom_code IN VARCHAR2,
				      p_rcv_sec_uom IN VARCHAR2,
				      p_rcv_sec_uom_code IN VARCHAR2,
				      p_source_type IN VARCHAR2,
				      p_subinventory VARCHAR2,
				      p_locator_id NUMBER,
				      p_transaction_temp_id IN NUMBER,
				      p_lot_control_code IN NUMBER,
				      p_serial_control_code IN NUMBER,
				      p_lpn_id IN NUMBER,
				      p_revision IN VARCHAR2,
				      x_status OUT NOCOPY VARCHAR2,
                                      x_message OUT NOCOPY VARCHAR2,
                                      p_inv_item_id IN NUMBER,
				      p_item_desc IN VARCHAR2,
				      p_location_id IN NUMBER,
				      p_is_expense IN VARCHAR2,
				      p_project_id IN NUMBER,
				      p_task_id    IN NUMBER,
                                      p_country_code IN VARCHAR2 DEFAULT NULL)
   IS

      l_rcpt_match_table_detail GML_RCV_TXN_INTERFACE.cascaded_trans_tab_type;  -- output for matching algorithm

      l_rcv_transaction_rec gml_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block

      l_transaction_type VARCHAR2(20) := 'DELIVER';
      l_total_primary_qty NUMBER := 0;

      l_msg_count NUMBER;
      l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;

      l_group_id NUMBER;
      l_rcv_rcpt_rec gml_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;
      --l_mmtt_rec mtl_material_transactions_temp%ROWTYPE;

      l_err_message VARCHAR2(100);
      l_temp_message VARCHAR2(100);
      l_msg_prod VARCHAR2(5);

      l_progress VARCHAR2(10);

       l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
      l_split_lot_serial_ok      BOOLEAN;   --Return status of lot_serial_split API


      CURSOR l_curs_rcpt_detail
	(v_po_distribution_id NUMBER)
	IS
	   SELECT
	     'N'       LINE_CHKBOX,
	     'VENDOR'        SOURCE_TYPE_CODE,
	     'VENDOR'        RECEIPT_SOURCE_CODE,
	     'PO'        ORDER_TYPE_CODE,
	     ''       ORDER_TYPE,
	     POLL.PO_HEADER_ID        PO_HEADER_ID,
	     POH.SEGMENT1        PO_NUMBER,
	     POLL.PO_LINE_ID        PO_LINE_ID,
	     POL.LINE_NUM        PO_LINE_NUMBER,
	     POLL.LINE_LOCATION_ID        PO_LINE_LOCATION_ID,
	     POLL.SHIPMENT_NUM        PO_SHIPMENT_NUMBER,
	     POLL.PO_RELEASE_ID        PO_RELEASE_ID,
	     POR.RELEASE_NUM        PO_RELEASE_NUMBER,
	     TO_NUMBER(NULL)        REQ_HEADER_ID,
	     NULL        REQ_NUMBER,
	     TO_NUMBER(NULL)        REQ_LINE_ID,
	     TO_NUMBER(NULL)        REQ_LINE,
	     TO_NUMBER(NULL)        REQ_DISTRIBUTION_ID,
	     POH.PO_HEADER_ID        RCV_SHIPMENT_HEADER_ID,
	     POH.SEGMENT1        RCV_SHIPMENT_NUMBER,
	     POL.PO_LINE_ID        RCV_SHIPMENT_LINE_ID,
	     POL.LINE_NUM        RCV_LINE_NUMBER,
	     POH.PO_HEADER_ID        FROM_ORGANIZATION_ID,
	     POLL.SHIP_TO_ORGANIZATION_ID        TO_ORGANIZATION_ID,
	     POH.VENDOR_ID        VENDOR_ID,
	     ''       SOURCE,
	     POH.VENDOR_SITE_ID        VENDOR_SITE_ID,
	     ''       OUTSIDE_OPERATION_FLAG,
	     POL.ITEM_ID        ITEM_ID,
	     -- Bug 2073164
	     NULL uom_code,
	     POL.UNIT_MEAS_LOOKUP_CODE        PRIMARY_UOM,
	     MUM.UOM_CLASS        PRIMARY_UOM_CLASS,
	     NULL       ITEM_ALLOWED_UNITS_LOOKUP_CODE,
	     NULL       ITEM_LOCATOR_CONTROL,
	     ''       RESTRICT_LOCATORS_CODE,
	     ''       RESTRICT_SUBINVENTORIES_CODE,
	     NULL       SHELF_LIFE_CODE,
	     NULL       SHELF_LIFE_DAYS,
	     MSI.SERIAL_NUMBER_CONTROL_CODE        SERIAL_NUMBER_CONTROL_CODE,
	     MSI.LOT_CONTROL_CODE        LOT_CONTROL_CODE,
	     DECODE(MSI.REVISION_QTY_CONTROL_CODE,1,'N',2,'Y','N')        ITEM_REV_CONTROL_FLAG_TO,
	     NULL        ITEM_REV_CONTROL_FLAG_FROM,
	     NULL        ITEM_NUMBER,
	     POL.ITEM_REVISION        ITEM_REVISION,
	     POL.ITEM_DESCRIPTION        ITEM_DESCRIPTION,
	     POL.CATEGORY_ID        ITEM_CATEGORY_ID,
	     ''       HAZARD_CLASS,
	     ''       UN_NUMBER,
	     POL.VENDOR_PRODUCT_NUM        VENDOR_ITEM_NUMBER,
	     POLL.SHIP_TO_LOCATION_ID        SHIP_TO_LOCATION_ID,
	     ''       SHIP_TO_LOCATION,
	     NULL        PACKING_SLIP,
	     POLL.RECEIVING_ROUTING_ID        ROUTING_ID,
	     ''       ROUTING_NAME,
	     POLL.NEED_BY_DATE        NEED_BY_DATE,
	     NVL(POLL.PROMISED_DATE,POLL.NEED_BY_DATE)        EXPECTED_RECEIPT_DATE,
	     POLL.QUANTITY        ORDERED_QTY,
	     POL.UNIT_MEAS_LOOKUP_CODE        ORDERED_UOM,
	     NULL        USSGL_TRANSACTION_CODE,
	     POLL.GOVERNMENT_CONTEXT        GOVERNMENT_CONTEXT,
	     POLL.INSPECTION_REQUIRED_FLAG        INSPECTION_REQUIRED_FLAG,
	     POLL.RECEIPT_REQUIRED_FLAG        RECEIPT_REQUIRED_FLAG,
	     POLL.ENFORCE_SHIP_TO_LOCATION_CODE        ENFORCE_SHIP_TO_LOCATION_CODE,
	     NVL(POLL.PRICE_OVERRIDE,POL.UNIT_PRICE)       UNIT_PRICE,
	     POH.CURRENCY_CODE        CURRENCY_CODE,
	     POH.RATE_TYPE        CURRENCY_CONVERSION_TYPE,
	     POH.RATE_DATE        CURRENCY_CONVERSION_DATE,
	     POH.RATE        CURRENCY_CONVERSION_RATE,
	     POH.NOTE_TO_RECEIVER        NOTE_TO_RECEIVER,
	     pod.destination_type_code        DESTINATION_TYPE_CODE,
	     pod.deliver_to_person_id        DELIVER_TO_PERSON_ID,
	     pod.deliver_to_location_id        DELIVER_TO_LOCATION_ID,
	     pod.destination_subinventory        DESTINATION_SUBINVENTORY,
	     POLL.ATTRIBUTE_CATEGORY        ATTRIBUTE_CATEGORY,
	     POLL.ATTRIBUTE1        ATTRIBUTE1,
	     POLL.ATTRIBUTE2        ATTRIBUTE2,
	     POLL.ATTRIBUTE3        ATTRIBUTE3,
	     POLL.ATTRIBUTE4        ATTRIBUTE4,
	     POLL.ATTRIBUTE5        ATTRIBUTE5,
	     POLL.ATTRIBUTE6        ATTRIBUTE6,
	     POLL.ATTRIBUTE7        ATTRIBUTE7,
	     POLL.ATTRIBUTE8        ATTRIBUTE8,
	     POLL.ATTRIBUTE9        ATTRIBUTE9,
	     POLL.ATTRIBUTE10        ATTRIBUTE10,
	     POLL.ATTRIBUTE11        ATTRIBUTE11,
	     POLL.ATTRIBUTE12        ATTRIBUTE12,
	     POLL.ATTRIBUTE13        ATTRIBUTE13,
	     POLL.ATTRIBUTE14        ATTRIBUTE14,
	     POLL.ATTRIBUTE15        ATTRIBUTE15,
	     POLL.CLOSED_CODE        CLOSED_CODE,
	     NULL       ASN_TYPE,
	     NULL       BILL_OF_LADING,
	     TO_DATE(NULL)       SHIPPED_DATE,
	     NULL       FREIGHT_CARRIER_CODE,
	     NULL       WAYBILL_AIRBILL_NUM,
	     NULL       FREIGHT_BILL_NUM,
	     NULL       VENDOR_LOT_NUM,
	     NULL       CONTAINER_NUM,
	     NULL        TRUCK_NUM,
	     NULL       BAR_CODE_LABEL,
	     ''       RATE_TYPE_DISPLAY,
	     POLL.MATCH_OPTION       MATCH_OPTION,
	     POLL.COUNTRY_OF_ORIGIN_CODE        COUNTRY_OF_ORIGIN_CODE,
	     TO_NUMBER(NULL)        OE_ORDER_HEADER_ID,
	     TO_NUMBER(NULL)        OE_ORDER_NUM,
	     TO_NUMBER(NULL)        OE_ORDER_LINE_ID,
	     TO_NUMBER(NULL)        OE_ORDER_LINE_NUM,
	     TO_NUMBER(NULL)        CUSTOMER_ID,
	     TO_NUMBER(NULL)        CUSTOMER_SITE_ID,
	     NULL        CUSTOMER_ITEM_NUM,
	     NULL pll_note_to_receiver,
	     --POLL.NOTE_TO_RECEIVER PLL_NOTE_TO_RECEIVER,
	     pod.po_distribution_id,
	     pod.quantity_ordered - pod.quantity_delivered qty_ordered,
	     pod.wip_entity_id,
	     pod.wip_operation_seq_num,
	     pod.wip_resource_seq_num,
	     pod.wip_repetitive_schedule_id,
	     pod.wip_line_id,
	     pod.bom_resource_id,
	     ''      DESTINATION_TYPE,
	     ''      LOCATION,
	     pod.rate currency_conversion_rate_pod,
	     pod.rate_date currency_conversion_date_pod,
	     pod.project_id project_id,
	     pod.task_id task_id
	     FROM
	     PO_HEADERS POH,
	     PO_LINE_LOCATIONS POLL,
	     PO_LINES POL,
	     PO_RELEASES POR,
	     MTL_SYSTEM_ITEMS MSI,
	     MTL_UNITS_OF_MEASURE mum,
	     PO_DISTRIBUTIONS POD
	     WHERE
	     POD.PO_DISTRIBUTION_ID = v_po_distribution_id
	     AND POH.PO_HEADER_ID = POLL.PO_HEADER_ID
	     AND POL.PO_LINE_ID = POLL.PO_LINE_ID
	     AND POLL.PO_RELEASE_ID = POR.PO_RELEASE_ID(+)
	     AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
	     AND MUM.UNIT_OF_MEASURE (+) = POL.UNIT_MEAS_LOOKUP_CODE
	     AND NVL(MSI.ORGANIZATION_ID,POLL.SHIP_TO_ORGANIZATION_ID) = POLL.SHIP_TO_ORGANIZATION_ID
	     AND MSI.INVENTORY_ITEM_ID (+) = POL.ITEM_ID
	     AND (p_project_id is null or
		       (p_project_id = -9999 and pod.project_id is null) -- bug 2669021
             or POD.project_id = p_project_id
            )
        and ( p_task_id is null or pod.task_id = p_task_id );
BEGIN

   x_status := fnd_api.g_ret_sts_success;
   SAVEPOINT crt_po_rti_sp;
   l_progress := '10';

   -- query po_startup_value
   Begin
   inv_rcv_common_apis.init_startup_values(p_organization_id);
   Exception
     when NO_DATA_FOUND then
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_PARAM');
      FND_MSG_PUB.ADD;
      RAISE ;
   End;

   l_progress := '20';
   -- default l_group_id ? clear group id after done
   IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id is NULL THEN
      SELECT rcv_interface_groups_s.nextval
	INTO   l_group_id
	FROM   dual;
      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
   END IF;

   l_progress := '30';
   -- initialize input record for matching algorithm
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := p_rcv_qty;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;

   -- OPM changes
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).secondary_quantity := p_rcv_sec_qty;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).secondary_unit_of_measure := p_rcv_sec_uom;

   if p_inv_item_id is not null then -- p_item_id has substitute item id
      gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_inv_item_id;
   else
      IF p_item_id IS NOT NULL THEN
	 gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
       ELSE
	 gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := NULL;
	 gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).item_desc := p_item_desc;
      end if;
   end if;

   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id := p_organization_id;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).group_id := l_group_id;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).po_header_id := p_po_header_id;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).po_release_id := p_po_release_id;

   -- line id, line location id and distribution id will be passed only from the putaway api.
   -- line id however, can also be passed through the UI if the line number
   -- field is enabled on the UI.
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).po_line_id := p_po_line_id;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).po_line_location_id := p_po_line_location_id;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).po_distribution_id := p_po_distribution_id;

   IF p_item_id IS NOT NULL THEN
      BEGIN
	 select primary_unit_of_measure
	   into gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
	   from mtl_system_items
	  where mtl_system_items.inventory_item_id = p_item_id
	    and   mtl_system_items.organization_id = p_organization_id;
      EXCEPTION
	 when no_data_found then
	    NULL;

      END;
    ELSE
     gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure := NULL;
   END IF;

   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).revision := p_revision;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).task_id := p_task_id;
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := Sysdate;  --?
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
   gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?


   l_progress := '40';
  --- OPM Specific version

  gml_rcv_txn_interface.matching_logic
     (x_return_status       => x_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => x_message,
      x_cascaded_table      => gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross,
      n		            => gml_rcv_std_rcpt_apis.g_receipt_detail_index,
      temp_cascaded_table   => l_rcpt_match_table_detail,
      p_receipt_num         => NULL,
      p_shipment_header_id  => NULL,
      p_lpn_id              => NULL
      );

   -- x_status is not successful if there is any execution error in matching.
   IF x_status = fnd_api.g_ret_sts_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF x_status = fnd_api.g_ret_sts_unexp_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := gml_rcv_std_rcpt_apis.g_rcpt_match_table_gross(gml_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      FND_MESSAGE.SET_NAME('INV', l_err_message);
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;


   l_err_message := '@@@';
   FOR i IN gml_rcv_std_rcpt_apis.g_receipt_detail_index..(gml_rcv_std_rcpt_apis.g_receipt_detail_index + l_rcpt_match_table_detail.COUNT - 1) LOOP
      IF l_rcpt_match_table_detail(i-gml_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_status = 'W' THEN
	 x_status := 'W';

	 l_temp_message := l_rcpt_match_table_detail(i-gml_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_message;
	 IF l_temp_message IS NULL THEN
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    l_msg_prod := 'INV';
	    EXIT;
	 END IF;
	 IF l_err_message = '@@@' THEN
	    l_err_message := l_temp_message;
	    l_msg_prod := 'INV';
	  ELSIF l_temp_message <> l_err_message THEN
	    l_msg_prod := 'INV';
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    EXIT;
	 END IF;
      END IF;
   END LOOP;

   IF l_err_message <> '@@@' THEN
      FND_MESSAGE.SET_NAME(l_msg_prod, l_err_message);
      FND_MSG_PUB.ADD;
   END IF;

   -- based on return from matching algorithm,
   -- determine which line in rcv_transaction block to be inserted into RTI


   l_progress := '60';

   -- loop through results returned by matching algorithm
   FOR match_result_count IN 1..l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '62';
      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).po_distribution_id);
      l_progress := '64';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;

      -- Earlier item_id was filled with PO Line Item ID if the parameter p_inv_item_id
      -- is not null, so that matching logic finds shipments. Now, in order to actually
      -- insert RTI, replace item_id with a new value which is nothing but the substitute
      -- item.
      l_rcv_rcpt_rec.item_id := p_item_id;

      l_progress := '66';
      CLOSE l_curs_rcpt_detail;
      l_progress := '68';


      l_rcv_transaction_rec.po_distribution_id := l_rcpt_match_table_detail(match_result_count).po_distribution_id;

      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      l_rcv_transaction_rec.secondary_quantity := l_rcpt_match_table_detail(match_result_count).secondary_quantity;
     l_rcv_transaction_rec.secondary_uom_code := p_rcv_sec_uom_code;
     l_rcv_transaction_rec.secondary_unit_of_measure := p_rcv_sec_uom;

      l_progress := '70';

      l_rcv_transaction_rec.lpn_id := p_lpn_id;
      l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;
      -- update following fields for po_distribution related values
      l_rcv_transaction_rec.currency_conversion_date := l_rcv_rcpt_rec.currency_conversion_date_pod;
      l_rcv_transaction_rec.currency_conversion_rate := l_rcv_rcpt_rec.currency_conversion_rate_pod;
      l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.qty_ordered;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
      l_rcv_transaction_rec.lpn_id := p_lpn_id;

      -- wip related fields
      IF l_rcv_rcpt_rec.wip_entity_id > 0 THEN
	 l_rcv_transaction_rec.wip_entity_id := l_rcv_rcpt_rec.wip_entity_id;
	 l_rcv_transaction_rec.wip_operation_seq_num := l_rcv_rcpt_rec.wip_operation_seq_num;
	 l_rcv_transaction_rec.wip_resource_seq_num := l_rcv_rcpt_rec.wip_resource_seq_num;

	 l_rcv_transaction_rec.wip_repetitive_schedule_id := l_rcv_rcpt_rec.wip_repetitive_schedule_id;
	 l_rcv_transaction_rec.wip_line_id := l_rcv_rcpt_rec.wip_line_id;
	 l_rcv_transaction_rec.bom_resource_id := l_rcv_transaction_rec.bom_resource_id;
	 -- there is getting actual values call for wip
	 -- since they are not inserted in RTI, I am not calling it here
	 -- the code is in
	 -- rcv_transactions_sv.get_wip_info ()
      END IF;

      IF p_country_code IS NOT NULL THEN
        l_rcv_rcpt_rec.COUNTRY_OF_ORIGIN_CODE := p_country_code;
      END IF;
      l_progress := '71';

          if l_rcv_rcpt_rec.destination_type_code = 'EXPENSE' then
                  if l_rcv_transaction_rec.deliver_to_location_id is null and
                      p_location_id is not null then
                     l_rcv_transaction_rec.deliver_to_location_id := p_location_id;
                  End if;
          End if;


      populate_default_values(p_rcv_transaction_rec => l_rcv_transaction_rec,
			      p_rcv_rcpt_rec => l_rcv_rcpt_rec,
			      p_group_id => l_group_id,
			      p_organization_id => p_organization_id,
			      p_item_id => p_item_id,
			      p_revision => p_revision,
			      p_source_type => p_source_type,
			      p_subinventory_code => p_subinventory,
			      p_locator_id => p_locator_id,
			      p_transaction_temp_id => p_transaction_temp_id,
			      p_lot_control_code => p_lot_control_code,
			      p_serial_control_code => p_serial_control_code);
      l_progress := '80';

      /* FP-J Lot/Serial Support Enhancement
       * Populate the table to store the information of the RTIs created used for
       * splitting the lots and serials based on RTI quantity
       */

      l_new_rti_info(match_result_count).orig_interface_trx_id := p_transaction_temp_id;
      l_new_rti_info(match_result_count).new_interface_trx_id := g_interface_transaction_id;
      l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_qty;


   END LOOP;
   -- append index in input table where the line to be detailed needs to be inserted
   --inv_rcv_std_rcpt_apis.g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + inv_rcv_std_rcpt_apis.g_receipt_detail_index;

    l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);

      IF (NOT l_split_lot_serial_ok) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;


   l_progress := '90';

/** Shortage checking not supported by OPM

   inv_rcv_common_apis.do_check
     (p_organization_id => p_organization_id,
      p_inventory_item_id => p_item_id,
      p_transaction_type_id => 18,
      p_primary_quantity => l_total_primary_qty,
      x_return_status => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => x_message);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
   END IF;
*/
   l_progress := '100';

   -- Clear the Lot Rec
   ---inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;
   gml_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error ;
      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );


   WHEN OTHERS THEN
      x_message := SQLERRM;
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error ;
      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;
      fnd_msg_pub.count_and_get
	(p_encoded   => FND_API.g_false,
	 p_count     => l_msg_count,
	 p_data      => x_message
	 );


END create_po_drct_dlvr_rti_rec;



PROCEDURE create_int_shp_dr_del_rti_rec(p_move_order_header_id IN OUT NOCOPY NUMBER,
					p_organization_id IN NUMBER,
					p_shipment_header_id IN NUMBER,
					p_shipment_line_id IN NUMBER,
					p_item_id IN NUMBER,
					p_rcv_qty IN NUMBER,
					p_rcv_uom IN VARCHAR2,
					p_rcv_uom_code IN VARCHAR2,
					p_source_type IN VARCHAR2,
					p_subinventory VARCHAR2,
					p_locator_id NUMBER,
					p_transaction_temp_id IN NUMBER,
					p_lot_control_code IN NUMBER,
					p_serial_control_code IN NUMBER,
					p_lpn_id IN NUMBER,
					p_revision IN VARCHAR2,
               p_project_id IN NUMBER DEFAULT NULL,
               p_task_id  IN NUMBER DEFAULT NULL,
					x_status OUT NOCOPY VARCHAR2,
					x_message OUT NOCOPY VARCHAR2,
               p_country_code IN VARCHAR2 DEFAULT NULL
					)

  IS

     l_rcpt_match_table_detail INV_RCV_COMMON_APIS.cascaded_trans_tab_type;  -- output for matching algorithm

     l_rcv_transaction_rec gml_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block

     l_transaction_type VARCHAR2(20) := 'DELIVER';
     l_total_primary_qty NUMBER := 0;

     l_msg_count NUMBER;
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;

     l_group_id NUMBER;

     l_rcv_rcpt_rec gml_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;
     l_mmtt_rec mtl_material_transactions_temp%ROWTYPE;

     l_err_message VARCHAR2(100);
     l_temp_message VARCHAR2(100);
     l_msg_prod VARCHAR2(5);

     l_progress VARCHAR2(10);
     l_receipt_num VARCHAR2(30);

     CURSOR l_curs_rcpt_detail
       (v_shipment_line_id NUMBER)
       IS
	  SELECT
	    'N'       LINE_CHKBOX,
	    'INTERNAL'       SOURCE_TYPE_CODE,
	    DECODE(RSL.SOURCE_DOCUMENT_CODE,'INVENTORY','INVENTORY','REQ','INTERNAL ORDER')       RECEIPT_SOURCE_CODE,
	    RSL.SOURCE_DOCUMENT_CODE       ORDER_TYPE_CODE,
	    ''       ORDER_TYPE,
	    RSH.SHIPMENT_HEADER_ID       PO_HEADER_ID,
	    RSH.SHIPMENT_NUM       PO_NUMBER,
	    RSL.SHIPMENT_LINE_ID       PO_LINE_ID,
	    RSL.LINE_NUM       PO_LINE_NUMBER,
	    RSL.SHIPMENT_LINE_ID       PO_LINE_LOCATION_ID,
	    RSL.LINE_NUM       PO_SHIPMENT_NUMBER,
	    RSH.SHIPMENT_HEADER_ID       PO_RELEASE_ID,
	    RSH.SHIPMENT_HEADER_ID       PO_RELEASE_NUMBER,
	    PORH.REQUISITION_HEADER_ID       REQ_HEADER_ID,
	    PORH.SEGMENT1       REQ_NUMBER,
	    PORL.REQUISITION_LINE_ID       REQ_LINE_ID,
	    PORL.LINE_NUM       REQ_LINE,
	    RSL.REQ_DISTRIBUTION_ID       REQ_DISTRIBUTION_ID,
	    RSL.SHIPMENT_HEADER_ID       RCV_SHIPMENT_HEADER_ID,
	    RSH.SHIPMENT_NUM       RCV_SHIPMENT_NUMBER,
	    RSL.SHIPMENT_LINE_ID       RCV_SHIPMENT_LINE_ID,
	    RSL.LINE_NUM       RCV_LINE_NUMBER,
	    RSL.FROM_ORGANIZATION_ID       FROM_ORGANIZATION_ID,
	    RSL.TO_ORGANIZATION_ID       TO_ORGANIZATION_ID,
	    RSL.SHIPMENT_LINE_ID       VENDOR_ID,
	    ''       SOURCE,
	    TO_NUMBER(NULL)       VENDOR_SITE_ID,
	    'N'       OUTSIDE_OPERATION_FLAG,
	    RSL.ITEM_ID       ITEM_ID,
	    -- Bug 2073164
	    NULL uom_code,
	    RSL.UNIT_OF_MEASURE       PRIMARY_UOM,
	    MUM.UOM_CLASS       PRIMARY_UOM_CLASS,
	    NVL(MSI.ALLOWED_UNITS_LOOKUP_CODE,2)       ITEM_ALLOWED_UNITS_LOOKUP_CODE,
	    NVL(MSI.LOCATION_CONTROL_CODE,1)       ITEM_LOCATOR_CONTROL,
	    DECODE(MSI.RESTRICT_LOCATORS_CODE,1,'Y','N')       RESTRICT_LOCATORS_CODE,
	    DECODE(MSI.RESTRICT_SUBINVENTORIES_CODE,1,'Y','N')       RESTRICT_SUBINVENTORIES_CODE,
	    NVL(MSI.SHELF_LIFE_CODE,1)       SHELF_LIFE_CODE,
	    NVL(MSI.SHELF_LIFE_DAYS,0)       SHELF_LIFE_DAYS,
	    MSI.SERIAL_NUMBER_CONTROL_CODE       SERIAL_NUMBER_CONTROL_CODE,
	    MSI.LOT_CONTROL_CODE       LOT_CONTROL_CODE,
	    DECODE(MSI.REVISION_QTY_CONTROL_CODE,1,'N',2,'Y','N')       ITEM_REV_CONTROL_FLAG_TO,
	    DECODE(MSI1.REVISION_QTY_CONTROL_CODE, 1,'N',2,'Y','N')       ITEM_REV_CONTROL_FLAG_FROM,
	    NULL       ITEM_NUMBER,
	    RSL.ITEM_REVISION       ITEM_REVISION,
	    RSL.ITEM_DESCRIPTION       ITEM_DESCRIPTION,
	    RSL.CATEGORY_ID       ITEM_CATEGORY_ID,
	    ''       HAZARD_CLASS,
	    ''       UN_NUMBER,
	    RSL.VENDOR_ITEM_NUM       VENDOR_ITEM_NUMBER,
	    RSH.SHIP_TO_LOCATION_ID       SHIP_TO_LOCATION_ID,
	    ''       SHIP_TO_LOCATION,
	    RSH.PACKING_SLIP       PACKING_SLIP,
	    RSL.ROUTING_HEADER_ID       ROUTING_ID,
	    ''       ROUTING_NAME,
	    PORL.NEED_BY_DATE       NEED_BY_DATE,
	    RSH.EXPECTED_RECEIPT_DATE       EXPECTED_RECEIPT_DATE,
	    RSL.QUANTITY_SHIPPED       ORDERED_QTY,
	    RSL.PRIMARY_UNIT_OF_MEASURE       ORDERED_UOM,
	    RSH.USSGL_TRANSACTION_CODE       USSGL_TRANSACTION_CODE,
	    RSH.GOVERNMENT_CONTEXT       GOVERNMENT_CONTEXT,
	    NULL       INSPECTION_REQUIRED_FLAG,
	    NULL       RECEIPT_REQUIRED_FLAG,
	    NULL       ENFORCE_SHIP_TO_LOCATION_CODE,
	    TO_NUMBER(NULL)       UNIT_PRICE,
	    NULL       CURRENCY_CODE,
	    NULL       CURRENCY_CONVERSION_TYPE,
	    TO_DATE(NULL)       CURRENCY_CONVERSION_DATE,
	    TO_NUMBER(NULL)       CURRENCY_CONVERSION_RATE,
	    NULL note_to_receiver,
	    --PORL.NOTE_TO_RECEIVER       NOTE_TO_RECEIVER,
	    RSL.DESTINATION_TYPE_CODE       DESTINATION_TYPE_CODE,
	    RSL.DELIVER_TO_PERSON_ID       DELIVER_TO_PERSON_ID,
	    RSL.DELIVER_TO_LOCATION_ID       DELIVER_TO_LOCATION_ID,
	    RSL.TO_SUBINVENTORY       DESTINATION_SUBINVENTORY,
	    RSL.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
	    RSL.ATTRIBUTE1       ATTRIBUTE1,
	    RSL.ATTRIBUTE2       ATTRIBUTE2,
	    RSL.ATTRIBUTE3       ATTRIBUTE3,
	    RSL.ATTRIBUTE4       ATTRIBUTE4,
	    RSL.ATTRIBUTE5       ATTRIBUTE5,
	    RSL.ATTRIBUTE6       ATTRIBUTE6,
	    RSL.ATTRIBUTE7       ATTRIBUTE7,
	    RSL.ATTRIBUTE8       ATTRIBUTE8,
	    RSL.ATTRIBUTE9       ATTRIBUTE9,
	    RSL.ATTRIBUTE10       ATTRIBUTE10,
	    RSL.ATTRIBUTE11       ATTRIBUTE11,
	    RSL.ATTRIBUTE12       ATTRIBUTE12,
	    RSL.ATTRIBUTE13       ATTRIBUTE13,
	    RSL.ATTRIBUTE14       ATTRIBUTE14,
	    RSL.ATTRIBUTE15       ATTRIBUTE15,
	    'OPEN'       CLOSED_CODE,
	    NULL       ASN_TYPE,
	    RSH.BILL_OF_LADING       BILL_OF_LADING,
	    RSH.SHIPPED_DATE       SHIPPED_DATE,
	    RSH.FREIGHT_CARRIER_CODE       FREIGHT_CARRIER_CODE,
	    RSH.WAYBILL_AIRBILL_NUM       WAYBILL_AIRBILL_NUM,
	    RSH.FREIGHT_BILL_NUMBER       FREIGHT_BILL_NUM,
	    RSL.VENDOR_LOT_NUM       VENDOR_LOT_NUM,
	    RSL.CONTAINER_NUM       CONTAINER_NUM,
	    RSL.TRUCK_NUM       TRUCK_NUM,
	    RSL.BAR_CODE_LABEL       BAR_CODE_LABEL,
	    NULL       RATE_TYPE_DISPLAY,
	    'P'       MATCH_OPTION,
	    NULL        COUNTRY_OF_ORIGIN_CODE,
	    TO_NUMBER(NULL)        OE_ORDER_HEADER_ID,
	    TO_NUMBER(NULL)        OE_ORDER_NUM,
	    TO_NUMBER(NULL)        OE_ORDER_LINE_ID,
	    TO_NUMBER(NULL)        OE_ORDER_LINE_NUM,
	    TO_NUMBER(NULL)        CUSTOMER_ID,
	    TO_NUMBER(NULL)        CUSTOMER_SITE_ID,
	    NULL        CUSTOMER_ITEM_NUM,
	    NULL pll_note_to_receiver,
	    --PORL.NOTE_TO_RECEIVER       PLL_NOTE_TO_RECEIVER,
	    NULL      PO_DISTRIBUTION_ID,
	    NULL      QTY_ORDERED,
	    NULL      WIP_ENTITY_ID,
	    NULL      WIP_OPERATION_SEQ_NUM,
	    NULL      WIP_RESOURCE_SEQ_NUM,
	    NULL       WIP_REPETITIVE_SCHEDULE_ID,
	    NULL      WIP_LINE_ID,
	    NULL      BOM_RESOURCE_ID,
	    ''      DESTINATION_TYPE,
	    ''      LOCATION,
	    NULL      CURRENCY_CONVERSION_RATE_POD,
	    NULL      CURRENCY_CONVERSION_DATE_POD,
	    NULL      PROJECT_ID,
	    NULL      TASK_ID
	    FROM
	    RCV_SHIPMENT_HEADERS RSH,
	    RCV_SHIPMENT_LINES RSL,
	    PO_REQUISITION_HEADERS PORH,
	    PO_REQUISITION_LINES PORL,
	    MTL_SYSTEM_ITEMS MSI,
	    MTL_SYSTEM_ITEMS MSI1,
	    MTL_UNITS_OF_MEASURE MUM
	    WHERE
	    RSH.RECEIPT_SOURCE_CODE <> 'VENDOR'
	    AND RSL.REQUISITION_LINE_ID = PORL.REQUISITION_LINE_ID(+)
	    AND PORL.REQUISITION_HEADER_ID = PORH.REQUISITION_HEADER_ID(+)
	    AND RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID
	    AND MUM.UNIT_OF_MEASURE (+) = RSL.UNIT_OF_MEASURE
	    AND MSI.ORGANIZATION_ID (+) = RSL.TO_ORGANIZATION_ID
	    AND MSI.INVENTORY_ITEM_ID (+) = RSL.ITEM_ID
	    AND MSI1.ORGANIZATION_ID (+) = RSL.FROM_ORGANIZATION_ID
	    AND MSI1.INVENTORY_ITEM_ID (+) = RSL.ITEM_ID
	    AND RSL.SHIPMENT_LINE_ID = v_shipment_line_id
       AND (( rsl.source_document_code = 'REQ' and
              exists
              (select '1'
               from po_req_distributions_all prd
               where (p_project_id is null or
                      (p_project_id = -9999 and prd.project_id is null) or -- bug 2669021
                      prd.project_id = p_project_id
                     )
               and   (p_task_id is null or prd.task_id = p_task_id)
              )
           )or rsl.source_document_code <> 'REQ'
          );
BEGIN
   x_status := fnd_api.g_ret_sts_success;
   l_progress := '10';
   SAVEPOINT crt_intship_rti_sp;

   -- query po_startup_value
   Begin
     /* Bug #2516729
      * Fetch rcv_shipment_headers.receipt_number for the given shipment_header_id.
      * If it exists , assign it to the global variable for receipt # (g_rcv_global_var.receipt_num)
      * in order that a new receipt # is not created everytime and the existing receipt # is used
      */
     BEGIN
       SELECT receipt_num
       INTO   l_receipt_num
       FROM   rcv_shipment_headers
       WHERE  shipment_header_id = p_shipment_header_id
       AND    ship_to_org_id = p_organization_id;

       inv_rcv_common_apis.g_rcv_global_var.receipt_num := l_receipt_num;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_receipt_num := NULL;
     END;
     inv_rcv_common_apis.init_startup_values(p_organization_id);
   Exception
     when NO_DATA_FOUND then
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_PARAM');
      FND_MSG_PUB.ADD;
      RAISE ;
   End;

   l_progress := '20';
   -- default l_group_id ? clear group id after done
   IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id is NULL THEN
      SELECT rcv_interface_groups_s.nextval
	INTO   l_group_id
	FROM   dual;
      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
   END IF;

   l_progress := '30';
   -- initialize input record for matching algorithm
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := p_rcv_qty;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).group_id := l_group_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id := p_organization_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).shipment_header_id := p_shipment_header_id;
   -- line id will be passed only from the putaway api.
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).shipment_line_id := p_shipment_line_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).task_id := p_task_id;

   BEGIN
      select primary_unit_of_measure
	into inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
	from mtl_system_items
       where mtl_system_items.inventory_item_id = p_item_id
	 and   mtl_system_items.organization_id = p_organization_id;
   EXCEPTION
      when no_data_found then
        NULL;
   END;

   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := Sysdate;  --?
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?

/** EOU Commented out as this procedure is not needed by OPM
   l_progress := '40';
   inv_rcv_txn_match.matching_logic
     (x_return_status       => x_status, --?
      x_msg_count           => l_msg_count,
      x_msg_data            => x_message,
      x_cascaded_table      => inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross,
      n		            => inv_rcv_std_rcpt_apis.g_receipt_detail_index,
      temp_cascaded_table   => l_rcpt_match_table_detail,
      p_receipt_num         => NULL,
      p_match_type          => 'INTRANSIT SHIPMENT',
      p_lpn_id              => NULL
      );
*/

   -- x_status is not successful if there is any execution error in matching.
   IF x_status = fnd_api.g_ret_sts_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF x_status = fnd_api.g_ret_sts_unexp_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      FND_MESSAGE.SET_NAME('INV', l_err_message);
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_err_message := '@@@';
   FOR i IN inv_rcv_std_rcpt_apis.g_receipt_detail_index..(inv_rcv_std_rcpt_apis.g_receipt_detail_index + l_rcpt_match_table_detail.COUNT - 1) LOOP
      IF l_rcpt_match_table_detail(i-inv_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_status = 'W' THEN
	 x_status := 'W';

	 l_temp_message := l_rcpt_match_table_detail(i-inv_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_message;
	 IF l_temp_message IS NULL THEN
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    l_msg_prod := 'INV';
	    EXIT;
	 END IF;
	 IF l_err_message = '@@@' THEN
	    l_err_message := l_temp_message;
	    l_msg_prod := 'INV';
	  ELSIF l_temp_message <> l_err_message THEN
	    l_msg_prod := 'INV';
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    EXIT;
	 END IF;
      END IF;
   END LOOP;

   IF l_err_message <> '@@@' THEN
      FND_MESSAGE.SET_NAME(l_msg_prod, l_err_message);
      FND_MSG_PUB.ADD;
   END IF;

   l_progress := '50';


   l_rcv_transaction_rec.rcv_shipment_line_id := l_rcv_rcpt_rec.rcv_shipment_line_id;

   -- loop through results returned by matching algorithm
   l_progress := '60';
   FOR match_result_count IN 1..l_rcpt_match_table_detail.COUNT LOOP

      l_progress := '62';
      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).shipment_line_id);
      l_progress := '64';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      l_progress := '66';
      CLOSE l_curs_rcpt_detail;
      l_progress := '68';


      l_rcv_transaction_rec.rcv_shipment_line_id := l_rcpt_match_table_detail(match_result_count).shipment_line_id;
      -- Get the transfer_cost_group_id from rcv_shipment_lines
      BEGIN
	 SELECT cost_group_id
	   INTO l_rcv_transaction_rec.transfer_cost_group_id
	   FROM rcv_shipment_lines
	  WHERE shipment_line_id = l_rcv_transaction_rec.rcv_shipment_line_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    l_rcv_transaction_rec.transfer_cost_group_id := NULL;
      END;

      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;

      l_progress := '70';


      l_rcv_transaction_rec.lpn_id := p_lpn_id;
      l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;

      IF p_country_code IS NOT NULL  THEN
        l_rcv_rcpt_rec.COUNTRY_OF_ORIGIN_CODE := p_country_code;
      END IF;


      populate_default_values(p_rcv_transaction_rec => l_rcv_transaction_rec,
			      p_rcv_rcpt_rec => l_rcv_rcpt_rec,
			      p_group_id => l_group_id,
			      p_organization_id => p_organization_id,
			      p_item_id => p_item_id,
			      p_revision => p_revision,
			      p_source_type => p_source_type,
			      p_subinventory_code => p_subinventory,
			      p_locator_id => p_locator_id,
			      p_transaction_temp_id => p_transaction_temp_id,
			      p_lot_control_code => p_lot_control_code,
			      p_serial_control_code =>
			      p_serial_control_code);

      IF l_rcv_rcpt_rec.req_line_id IS NOT NULL AND
	p_serial_control_code NOT IN (1, 6) THEN
	 -- update rss for req
	 inv_rcv_std_deliver_apis.update_rcv_serials_supply
	   (
	    x_return_status => l_return_status,
	    x_msg_count => l_msg_count,
	    x_msg_data => x_message,
	    p_shipment_line_id => l_rcv_transaction_rec.rcv_shipment_line_id
	    );

      END IF;


   END LOOP;
   -- append index in input table where the line to be detailed needs to be inserted
   --inv_rcv_std_rcpt_apis.g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + inv_rcv_std_rcpt_apis.g_receipt_detail_index;

   l_progress := '90';
   inv_rcv_common_apis.do_check
     (p_organization_id => p_organization_id,
      p_inventory_item_id => p_item_id,
      p_transaction_type_id => 61,
      p_primary_quantity => l_total_primary_qty,
      x_return_status => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => x_message);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
   END IF;

   l_progress := '100';

   -- Clear the Lot Rec
   inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_intship_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_intship_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error ;
      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );


   WHEN OTHERS THEN
      ROLLBACK TO crt_intship_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error ;
      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;
      fnd_msg_pub.count_and_get
	(p_encoded   => FND_API.g_false,
	 p_count     => l_msg_count,
	 p_data      => x_message
	 );

END create_int_shp_dr_del_rti_rec;



PROCEDURE create_rma_drct_dlvr_rti_rec(p_move_order_header_id IN OUT NOCOPY NUMBER,
				       p_organization_id IN NUMBER,
				       p_oe_order_header_id IN NUMBER,
				       p_oe_order_line_id IN NUMBER,
				       p_item_id IN NUMBER,
				       p_rcv_qty IN NUMBER,
				       p_rcv_uom IN VARCHAR2,
				       p_rcv_uom_code IN VARCHAR2,
				       p_source_type IN VARCHAR2,
				       p_subinventory VARCHAR2,
				       p_locator_id NUMBER,
				       p_transaction_temp_id IN NUMBER,
				       p_lot_control_code IN NUMBER,
				       p_serial_control_code IN NUMBER,
				       p_lpn_id IN NUMBER,
				       p_revision IN VARCHAR2,
				       x_status OUT NOCOPY VARCHAR2,
				       x_message OUT NOCOPY VARCHAR2,
				       p_project_id  IN NUMBER,
				       p_task_id  IN NUMBER,
                                       p_country_code IN VARCHAR2 DEFAULT NULL
				       )
  IS

     l_rcpt_match_table_detail INV_RCV_COMMON_APIS.cascaded_trans_tab_type;  -- output for matching algorithm

     l_rcv_transaction_rec gml_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block

     l_transaction_type VARCHAR2(20) := 'DELIVER';
     l_total_primary_qty NUMBER := 0;

     l_msg_count NUMBER;
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;

     l_group_id NUMBER;

     l_rcv_rcpt_rec gml_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;
     l_mmtt_rec mtl_material_transactions_temp%ROWTYPE;

     l_err_message VARCHAR2(100);
     l_temp_message VARCHAR2(100);
     l_msg_prod VARCHAR2(5);

     l_progress VARCHAR2(10);

     CURSOR l_curs_rcpt_detail
       (V_OE_ORDER_LINE_ID NUMBER)
       IS
	  SELECT
	    'N'   LINE_CHKBOX,
	    'CUSTOMER'      SOURCE_TYPE_CODE,
	    'CUSTOMER'      RECEIPT_SOURCE_CODE,
	    ''      ORDER_TYPE_CODE,
	    ''      ORDER_TYPE,
	    TO_NUMBER(NULL)      PO_HEADER_ID,
	    NULL      PO_NUMBER,
	    TO_NUMBER(NULL)      PO_LINE_ID,
	    TO_NUMBER(NULL)      PO_LINE_NUMBER,
	    TO_NUMBER(NULL)      PO_LINE_LOCATION_ID,
	    TO_NUMBER(NULL)      PO_SHIPMENT_NUMBER,
	    TO_NUMBER(NULL)      PO_RELEASE_ID,
	    TO_NUMBER(NULL)      PO_RELEASE_NUMBER,
	    TO_NUMBER(NULL)      REQ_HEADER_ID,
	    NULL      REQ_NUMBER,
	    TO_NUMBER(NULL)      REQ_LINE_ID,
	    TO_NUMBER(NULL)      REQ_LINE,
	    TO_NUMBER(NULL)      REQ_DISTRIBUTION_ID,
	    TO_NUMBER(NULL)      RCV_SHIPMENT_HEADER_ID,
	    NULL      RCV_SHIPMENT_NUMBER,
	    TO_NUMBER(NULL)      RCV_SHIPMENT_LINE_ID,
	    TO_NUMBER(NULL)      RCV_LINE_NUMBER,
	    NVL(OEL.SHIP_TO_ORG_ID,OEH.SHIP_TO_ORG_ID)      FROM_ORGANIZATION_ID,
	    NVL(OEL.SHIP_FROM_ORG_ID, OEH.SHIP_FROM_ORG_ID)      TO_ORGANIZATION_ID,
	    TO_NUMBER(NULL)      VENDOR_ID,
	    ''	      SOURCE,
	    TO_NUMBER(NULL)      VENDOR_SITE_ID,
	    NULL      OUTSIDE_OPERATION_FLAG,
	    OEL.INVENTORY_ITEM_ID       ITEM_ID,
	    -- Bug 2073164
	    NULL uom_code,
	    MUM.UNIT_OF_MEASURE      PRIMARY_UOM,
	    MUM.UOM_CLASS      PRIMARY_UOM_CLASS,
	    NVL(MSI.ALLOWED_UNITS_LOOKUP_CODE ,2)      ITEM_ALLOWED_UNITS_LOOKUP_CODE,
	    NVL(MSI.LOCATION_CONTROL_CODE ,1)      ITEM_LOCATOR_CONTROL,
	    DECODE(MSI.RESTRICT_LOCATORS_CODE ,1 ,'Y' ,'N')      RESTRICT_LOCATORS_CODE,
	    DECODE(MSI.RESTRICT_SUBINVENTORIES_CODE ,1 ,'Y' ,'N')      RESTRICT_SUBINVENTORIES_CODE,
	    NVL(MSI.SHELF_LIFE_CODE ,1)	     SHELF_LIFE_CODE,
	    NVL(MSI.SHELF_LIFE_DAYS ,0)	     SHELF_LIFE_DAYS,
	    MSI.SERIAL_NUMBER_CONTROL_CODE      SERIAL_NUMBER_CONTROL_CODE,
	    MSI.LOT_CONTROL_CODE	     LOT_CONTROL_CODE,
	    DECODE(MSI.REVISION_QTY_CONTROL_CODE ,1 ,'N' ,2 ,'Y' ,'N')      ITEM_REV_CONTROL_FLAG_TO,
	    NULL	     ITEM_REV_CONTROL_FLAG_FROM,
	    MSI.SEGMENT1	      ITEM_NUMBER,
	    OEL.ITEM_REVISION      ITEM_REVISION,
	    MSI.DESCRIPTION      ITEM_DESCRIPTION,
	    TO_NUMBER(NULL)      ITEM_CATEGORY_ID,
	    NULL      HAZARD_CLASS,
	    NULL      UN_NUMBER,
	    NULL       VENDOR_ITEM_NUMBER,
	    OEL.SHIP_FROM_ORG_ID      SHIP_TO_LOCATION_ID,
	    ''      SHIP_TO_LOCATION,
	    NULL	     PACKING_SLIP,
	    TO_NUMBER(NULL)       ROUTING_ID,
	    NULL       ROUTING_NAME,
	    OEL.REQUEST_DATE      NEED_BY_DATE,
	    NVL(OEL.PROMISE_DATE, OEL.REQUEST_DATE)      EXPECTED_RECEIPT_DATE,
	    OEL.ORDERED_QUANTITY      ORDERED_QTY,
	    ''       ORDERED_UOM,
	    NULL      USSGL_TRANSACTION_CODE,
	    NULL      GOVERNMENT_CONTEXT,
	    MSI.INSPECTION_REQUIRED_FLAG 	     INSPECTION_REQUIRED_FLAG,
	    'Y'      RECEIPT_REQUIRED_FLAG,
	    'N'      ENFORCE_SHIP_TO_LOCATION_CODE,
	    OEL.UNIT_SELLING_PRICE      UNIT_PRICE,
	    OEH.TRANSACTIONAL_CURR_CODE      CURRENCY_CODE,
	    OEH.CONVERSION_TYPE_CODE      CURRENCY_CONVERSION_TYPE,
	    OEH.CONVERSION_RATE_DATE      CURRENCY_CONVERSION_DATE,
	    OEH.CONVERSION_RATE      CURRENCY_CONVERSION_RATE,
	    NULL	     NOTE_TO_RECEIVER,
	    NULL	     DESTINATION_TYPE_CODE,
	    OEL.DELIVER_TO_CONTACT_ID	     DELIVER_TO_PERSON_ID,
	    OEL.DELIVER_TO_ORG_ID      DELIVER_TO_LOCATION_ID,
	    NULL      DESTINATION_SUBINVENTORY,
	    OEL.CONTEXT      ATTRIBUTE_CATEGORY,
	    OEL.ATTRIBUTE1      ATTRIBUTE1,
	    OEL.ATTRIBUTE2      ATTRIBUTE2,
	    OEL.ATTRIBUTE3      ATTRIBUTE3,
	    OEL.ATTRIBUTE4      ATTRIBUTE4,
	    OEL.ATTRIBUTE5      ATTRIBUTE5,
	    OEL.ATTRIBUTE6      ATTRIBUTE6,
	    OEL.ATTRIBUTE7      ATTRIBUTE7,
	    OEL.ATTRIBUTE8      ATTRIBUTE8,
	    OEL.ATTRIBUTE9      ATTRIBUTE9,
	    OEL.ATTRIBUTE10      ATTRIBUTE10,
	    OEL.ATTRIBUTE11      ATTRIBUTE11,
	    OEL.ATTRIBUTE12      ATTRIBUTE12,
	    OEL.ATTRIBUTE13      ATTRIBUTE13,
	    OEL.ATTRIBUTE14      ATTRIBUTE14,
	    OEL.ATTRIBUTE15      ATTRIBUTE15,
	    NULL      CLOSED_CODE,
	    NULL	     ASN_TYPE,
	    NULL	     BILL_OF_LADING,
	    TO_DATE(NULL)	     SHIPPED_DATE,
	    NULL      FREIGHT_CARRIER_CODE,
	    NULL      WAYBILL_AIRBILL_NUM,
	    NULL      FREIGHT_BILL_NUM,
	    NULL      VENDOR_LOT_NUM,
	    NULL      CONTAINER_NUM,
	    NULL      TRUCK_NUM,
	    NULL      BAR_CODE_LABEL,
	    NULL      RATE_TYPE_DISPLAY,
	    NULL      MATCH_OPTION,
	    NULL      COUNTRY_OF_ORIGIN_CODE,
	    OEL.HEADER_ID      OE_ORDER_HEADER_ID,
	    OEH.ORDER_NUMBER      OE_ORDER_NUM,
	    OEL.LINE_ID      OE_ORDER_LINE_ID,
	    OEL.LINE_NUMBER      OE_ORDER_LINE_NUM,
	    OEL.SOLD_TO_ORG_ID             CUSTOMER_ID,
	    NVL(OEL.SHIP_TO_ORG_ID, OEH.SHIP_TO_ORG_ID)      CUSTOMER_SITE_ID,
	    ''       CUSTOMER_ITEM_NUM,
	    ''      PLL_NOTE_TO_RECEIVER,
	    NULL      PO_DISTRIBUTION_ID,
	    NULL      QTY_ORDERED,
	    NULL      WIP_ENTITY_ID,
	    NULL      WIP_OPERATION_SEQ_NUM,
	    NULL      WIP_RESOURCE_SEQ_NUM,
	    NULL       WIP_REPETITIVE_SCHEDULE_ID,
	    NULL      WIP_LINE_ID,
	    NULL      BOM_RESOURCE_ID,
	    ''      DESTINATION_TYPE,
	    ''      LOCATION,
	    NULL      CURRENCY_CONVERSION_RATE_POD,
	    NULL      CURRENCY_CONVERSION_DATE_POD,
	    NULL      PROJECT_ID,
	    NULL      TASK_ID
	    FROM
	    OE_ORDER_LINES_all 			  OEL,
	    OE_ORDER_HEADERS_all 			  OEH,
	    MTL_SYSTEM_ITEMS 			  MSI,
	    MTL_UNITS_OF_MEASURE 			  MUM
	    WHERE OEL.LINE_CATEGORY_CODE='RETURN'
	    AND OEL.HEADER_ID = OEH.HEADER_ID
	    AND OEL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
	    AND OEL.SHIP_FROM_ORG_ID = MSI.ORGANIZATION_ID
	    AND MSI.PRIMARY_UOM_CODE = MUM.UOM_CODE
	    AND OEL.BOOKED_FLAG='Y'
	    AND OEL.ORDERED_QUANTITY > NVL(OEL.SHIPPED_QUANTITY,0)
	    AND MSI.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y'
	    AND OEL.LINE_ID = v_oe_order_line_id
       AND (p_project_id is null or
            (p_project_id = -9999 and oel.project_id is null ) or -- bug 2669021
             OEL.project_id = p_project_id
           )
	    and ( p_task_id is null or OEL.task_id = p_task_id );

BEGIN
   x_status := fnd_api.g_ret_sts_success;
   l_progress := '10';
   SAVEPOINT crt_rma_rti_sp;

   -- query po_startup_value
   Begin
   inv_rcv_common_apis.init_startup_values(p_organization_id);
   Exception
     when NO_DATA_FOUND then
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_PARAM');
      FND_MSG_PUB.ADD;
      RAISE ;
   End;

   l_progress := '20';
   -- default l_group_id ? clear group id after done
   IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id is NULL THEN
      SELECT rcv_interface_groups_s.nextval
	INTO   l_group_id
	FROM   dual;
      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
   END IF;

   -- initialize input record for matching algorithm
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := p_rcv_qty;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).group_id := l_group_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id := p_organization_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).oe_order_header_id := p_oe_order_header_id;
   -- line id will be passed only from the putaway api.
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).oe_order_line_id := p_oe_order_line_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id; --bug# 2794612
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).task_id := p_task_id; --bug# 2794612

   BEGIN
      select primary_unit_of_measure
	into inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
	from mtl_system_items
       where mtl_system_items.inventory_item_id = p_item_id
	 and   mtl_system_items.organization_id = p_organization_id;
   EXCEPTION
      when no_data_found then
        NULL;
   END;

   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := Sysdate;  --?
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?

   l_progress := '40';
   inv_rcv_txn_match.matching_logic
     (x_return_status       => x_status, --?
      x_msg_count           => l_msg_count,
      x_msg_data            => x_message,
      x_cascaded_table      => inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross,
      n		            => inv_rcv_std_rcpt_apis.g_receipt_detail_index,
      temp_cascaded_table   => l_rcpt_match_table_detail,
      p_receipt_num         => NULL,
      p_match_type          => 'RMA',
      p_lpn_id              => NULL
      );

   -- x_status is not successful if there is any execution error in matching.
   IF x_status = fnd_api.g_ret_sts_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF x_status = fnd_api.g_ret_sts_unexp_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      FND_MESSAGE.SET_NAME('INV', l_err_message);
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_err_message := '@@@';
   FOR i IN inv_rcv_std_rcpt_apis.g_receipt_detail_index..(inv_rcv_std_rcpt_apis.g_receipt_detail_index + l_rcpt_match_table_detail.COUNT - 1) LOOP
      IF l_rcpt_match_table_detail(i-inv_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_status = 'W' THEN
	 x_status := 'W';

	 l_temp_message := l_rcpt_match_table_detail(i-inv_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_message;
	 IF l_temp_message IS NULL THEN
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    l_msg_prod := 'INV';
	    EXIT;
	 END IF;
	 IF l_err_message = '@@@' THEN
	    l_err_message := l_temp_message;
	    l_msg_prod := 'INV';
	  ELSIF l_temp_message <> l_err_message THEN
	    l_msg_prod := 'INV';
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    EXIT;
	 END IF;
      END IF;
   END LOOP;

   IF l_err_message <> '@@@' THEN
      FND_MESSAGE.SET_NAME(l_msg_prod, l_err_message);
      FND_MSG_PUB.ADD;
   END IF;

   -- based on return from matching algorithm,
   -- determine which line in rcv_transaction block to be inserted into RTI


   -- loop through results returned by matching algorithm
   l_progress := '60';
   FOR match_result_count IN 1..l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '62';
      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).oe_order_line_id);
      l_progress := '64';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      l_progress := '66';
      CLOSE l_curs_rcpt_detail;
      l_progress := '68';

      l_rcv_transaction_rec.oe_order_line_id := l_rcpt_match_table_detail(match_result_count).oe_order_line_id;


      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;


      l_progress := '70';

      l_rcv_transaction_rec.lpn_id := p_lpn_id;
      l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;

      IF p_country_code IS NOT NULL THEN
        l_rcv_rcpt_rec.COUNTRY_OF_ORIGIN_CODE := p_country_code;
      END IF;

      populate_default_values(p_rcv_transaction_rec => l_rcv_transaction_rec,
			      p_rcv_rcpt_rec => l_rcv_rcpt_rec,
			      p_group_id => l_group_id,
			      p_organization_id => p_organization_id,
			      p_item_id => p_item_id,
			      p_revision => p_revision,
			      p_source_type => p_source_type,
			      p_subinventory_code => p_subinventory,
			      p_locator_id => p_locator_id,
			      p_transaction_temp_id => p_transaction_temp_id,
			      p_lot_control_code => p_lot_control_code,
			      p_serial_control_code => p_serial_control_code);
      l_progress := '80';

   END LOOP;
   -- append index in input table where the line to be detailed needs to be inserted
   --inv_rcv_std_rcpt_apis.g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + inv_rcv_std_rcpt_apis.g_receipt_detail_index;

   l_progress := '90';
   inv_rcv_common_apis.do_check
     (p_organization_id => p_organization_id,
      p_inventory_item_id => p_item_id,
      p_transaction_type_id => 15,
      p_primary_quantity => l_total_primary_qty,
      x_return_status => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => x_message);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
   END IF;

   l_progress := '100';

   -- Clear the Lot Rec
   inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_rma_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_rma_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error ;
      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

   WHEN OTHERS THEN
      ROLLBACK TO crt_rma_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error ;
      IF l_curs_rcpt_detail%isopen THEN
	 CLOSE l_curs_rcpt_detail;
      END IF;
      fnd_msg_pub.count_and_get
	(p_encoded   => FND_API.g_false,
	 p_count     => l_msg_count,
	 p_data      => x_message
	 );

END create_rma_drct_dlvr_rti_rec;


PROCEDURE create_asn_con_dd_intf_rec
  (p_move_order_header_id        IN OUT NOCOPY NUMBER,
   p_organization_id             IN NUMBER,
   p_shipment_header_id          IN NUMBER,
   p_po_header_id                IN NUMBER,
   p_item_id                     IN NUMBER,
   p_rcv_qty                     IN NUMBER,
   p_rcv_uom                     IN VARCHAR2,
   p_rcv_uom_code                IN VARCHAR2,
   p_source_type                 IN VARCHAR2,
   p_subinventory                VARCHAR2,
   p_locator_id                  NUMBER,
   p_lpn_id                      IN NUMBER,
   p_lot_control_code            IN NUMBER,
   p_serial_control_code         IN NUMBER,
   p_revision                    IN VARCHAR2,
   p_transaction_temp_id         IN NUMBER,
   x_status                      OUT NOCOPY VARCHAR2,
   x_message                     OUT NOCOPY VARCHAR2,
   p_project_id			 IN  NUMBER,
   p_task_id			 IN NUMBER,
   p_country_code                IN VARCHAR2 DEFAULT NULL,
   p_item_desc                   IN VARCHAR2 DEFAULT NULL
   )
  IS
     l_rcpt_match_table_detail INV_RCV_COMMON_APIS.cascaded_trans_tab_type;  -- output for matching algorithm

     l_rcv_transaction_rec gml_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block

     l_transaction_type VARCHAR2(20) := 'DELIVER';
     l_total_primary_qty NUMBER := 0;
     l_match_type VARCHAR2(20);

     l_msg_count NUMBER;
     l_msg_data  VARCHAR2(400);
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;

     l_group_id NUMBER;

     l_rcv_rcpt_rec gml_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;
     l_mmtt_rec mtl_material_transactions_temp%ROWTYPE;

     l_err_message VARCHAR2(100);
     l_temp_message VARCHAR2(100);
     l_msg_prod VARCHAR2(5);

     l_progress VARCHAR2(10);
     l_receipt_num VARCHAR2(30);

     CURSOR l_curs_rcpt_detail
       (v_shipment_line_id NUMBER,
	v_po_distribution_id NUMBER)
       IS
	  SELECT
	    'N'       LINE_CHKBOX,
	    'ASN'        SOURCE_TYPE_CODE,
	    'VENDOR'        RECEIPT_SOURCE_CODE,
	    'PO'        ORDER_TYPE_CODE,
	    ''       ORDER_TYPE,
	    POLL.PO_HEADER_ID        PO_HEADER_ID,
	    POH.SEGMENT1        PO_NUMBER,
	    POLL.PO_LINE_ID        PO_LINE_ID,
	    POL.LINE_NUM        PO_LINE_NUMBER,
	    POLL.LINE_LOCATION_ID        PO_LINE_LOCATION_ID,
	    POLL.SHIPMENT_NUM        PO_SHIPMENT_NUMBER,
	    POLL.PO_RELEASE_ID        PO_RELEASE_ID,
	    POR.RELEASE_NUM        PO_RELEASE_NUMBER,
	    TO_NUMBER(NULL)        REQ_HEADER_ID,
	    NULL        REQ_NUMBER,
	    TO_NUMBER(NULL)        REQ_LINE_ID,
	    TO_NUMBER(NULL)        REQ_LINE,
	    TO_NUMBER(NULL)        REQ_DISTRIBUTION_ID,
	    RSH.SHIPMENT_HEADER_ID        RCV_SHIPMENT_HEADER_ID,
	    RSH.SHIPMENT_NUM        RCV_SHIPMENT_NUMBER,
	    RSL.SHIPMENT_LINE_ID        RCV_SHIPMENT_LINE_ID,
	    RSL.LINE_NUM        RCV_LINE_NUMBER,
	    NVL(RSL.FROM_ORGANIZATION_ID,POH.PO_HEADER_ID)        FROM_ORGANIZATION_ID,
	    RSL.TO_ORGANIZATION_ID        TO_ORGANIZATION_ID,
	    RSH.VENDOR_ID        VENDOR_ID,
	    ''       SOURCE,
	    RSH.VENDOR_SITE_ID        VENDOR_SITE_ID,
	    ''       OUTSIDE_OPERATION_FLAG,
	    RSL.ITEM_ID        ITEM_ID,
	    -- Bug 2073164
	    NULL uom_code,
	    RSL.UNIT_OF_MEASURE        PRIMARY_UOM,
	    MUM.UOM_CLASS        PRIMARY_UOM_CLASS,
	    NVL(MSI.ALLOWED_UNITS_LOOKUP_CODE,2)        ITEM_ALLOWED_UNITS_LOOKUP_CODE,
	    NVL(MSI.LOCATION_CONTROL_CODE,1)        ITEM_LOCATOR_CONTROL,
	    DECODE(MSI.RESTRICT_LOCATORS_CODE,1,'Y', 'N')        RESTRICT_LOCATORS_CODE,
	    DECODE(MSI.RESTRICT_SUBINVENTORIES_CODE,1,'Y','N')        RESTRICT_SUBINVENTORIES_CODE,
	    NVL(MSI.SHELF_LIFE_CODE,1)        SHELF_LIFE_CODE,
	    NVL(MSI.SHELF_LIFE_DAYS,0)        SHELF_LIFE_DAYS,
	    MSI.SERIAL_NUMBER_CONTROL_CODE        SERIAL_NUMBER_CONTROL_CODE,
	    MSI.LOT_CONTROL_CODE        LOT_CONTROL_CODE,
	    DECODE(MSI.REVISION_QTY_CONTROL_CODE,1,'N',2,'Y','N')        ITEM_REV_CONTROL_FLAG_TO,
	    NULL        ITEM_REV_CONTROL_FLAG_FROM,
	    NULL       ITEM_NUMBER,
	    RSL.ITEM_REVISION        ITEM_REVISION,
	    RSL.ITEM_DESCRIPTION        ITEM_DESCRIPTION,
	    RSL.CATEGORY_ID        ITEM_CATEGORY_ID,
	    ''       HAZARD_CLASS,
	    ''       UN_NUMBER,
	    RSL.VENDOR_ITEM_NUM        VENDOR_ITEM_NUMBER,
	    RSL.SHIP_TO_LOCATION_ID        SHIP_TO_LOCATION_ID,
	    ''       SHIP_TO_LOCATION,
	    RSL.PACKING_SLIP        PACKING_SLIP,
	    RSL.ROUTING_HEADER_ID        ROUTING_ID,
	    ''       ROUTING_NAME,
	    POLL.NEED_BY_DATE        NEED_BY_DATE,
	    RSH.EXPECTED_RECEIPT_DATE        EXPECTED_RECEIPT_DATE,
	    POLL.QUANTITY        ORDERED_QTY,
	    POL.UNIT_MEAS_LOOKUP_CODE        ORDERED_UOM,
	    RSL.USSGL_TRANSACTION_CODE        USSGL_TRANSACTION_CODE,
	    RSL.GOVERNMENT_CONTEXT        GOVERNMENT_CONTEXT,
	    POLL.INSPECTION_REQUIRED_FLAG        INSPECTION_REQUIRED_FLAG,
	    POLL.RECEIPT_REQUIRED_FLAG        RECEIPT_REQUIRED_FLAG,
	    POLL.ENFORCE_SHIP_TO_LOCATION_CODE        ENFORCE_SHIP_TO_LOCATION_CODE,
	    NVL(POLL.PRICE_OVERRIDE,POL.UNIT_PRICE)        UNIT_PRICE,
	    POH.CURRENCY_CODE        CURRENCY_CODE,
	    POH.RATE_TYPE        CURRENCY_CONVERSION_TYPE,
	    POH.RATE_DATE        CURRENCY_CONVERSION_DATE,
	    POH.RATE        CURRENCY_CONVERSION_RATE,
	    POH.NOTE_TO_RECEIVER        NOTE_TO_RECEIVER,
	    POD.DESTINATION_TYPE_CODE        DESTINATION_TYPE_CODE,
	    POD.DELIVER_TO_PERSON_ID        DELIVER_TO_PERSON_ID,
	    POD.DELIVER_TO_LOCATION_ID        DELIVER_TO_LOCATION_ID,
	    POD.DESTINATION_SUBINVENTORY        DESTINATION_SUBINVENTORY,
	    RSL.ATTRIBUTE_CATEGORY        ATTRIBUTE_CATEGORY,
	    RSL.ATTRIBUTE1        ATTRIBUTE1,
	    RSL.ATTRIBUTE2        ATTRIBUTE2,
	    RSL.ATTRIBUTE3        ATTRIBUTE3,
	    RSL.ATTRIBUTE4        ATTRIBUTE4,
	    RSL.ATTRIBUTE5        ATTRIBUTE5,
	    RSL.ATTRIBUTE6        ATTRIBUTE6,
	    RSL.ATTRIBUTE7        ATTRIBUTE7,
	    RSL.ATTRIBUTE8        ATTRIBUTE8,
	    RSL.ATTRIBUTE9        ATTRIBUTE9,
	    RSL.ATTRIBUTE10        ATTRIBUTE10,
	    RSL.ATTRIBUTE11        ATTRIBUTE11,
	    RSL.ATTRIBUTE12        ATTRIBUTE12,
	    RSL.ATTRIBUTE13        ATTRIBUTE13,
	    RSL.ATTRIBUTE14        ATTRIBUTE14,
	    RSL.ATTRIBUTE15        ATTRIBUTE15,
	    POLL.CLOSED_CODE        CLOSED_CODE,
	    RSH.ASN_TYPE        ASN_TYPE,
	    RSH.BILL_OF_LADING        BILL_OF_LADING,
	    RSH.SHIPPED_DATE        SHIPPED_DATE,
	    RSH.FREIGHT_CARRIER_CODE        FREIGHT_CARRIER_CODE,
	    RSH.WAYBILL_AIRBILL_NUM        WAYBILL_AIRBILL_NUM,
	    RSH.FREIGHT_BILL_NUMBER        FREIGHT_BILL_NUM,
	    RSL.VENDOR_LOT_NUM        VENDOR_LOT_NUM,
	    RSL.CONTAINER_NUM        CONTAINER_NUM,
	    RSL.TRUCK_NUM        TRUCK_NUM,
	    RSL.BAR_CODE_LABEL        BAR_CODE_LABEL,
	    ''       RATE_TYPE_DISPLAY,
	    POLL.MATCH_OPTION        MATCH_OPTION,
	    RSL.COUNTRY_OF_ORIGIN_CODE        COUNTRY_OF_ORIGIN_CODE,
	    TO_NUMBER(NULL)        OE_ORDER_HEADER_ID,
	    TO_NUMBER(NULL)        OE_ORDER_NUM,
	    TO_NUMBER(NULL)        OE_ORDER_LINE_ID,
	    TO_NUMBER(NULL)        OE_ORDER_LINE_NUM,
	    TO_NUMBER(NULL)        CUSTOMER_ID,
	    TO_NUMBER(NULL)        CUSTOMER_SITE_ID,
	    null        CUSTOMER_ITEM_NUM,
	    NULL pll_note_to_receiver,
	    --POLL.NOTE_TO_RECEIVER       PLL_NOTE_TO_RECEIVER,
	    pod.po_distribution_id      PO_DISTRIBUTION_ID,
	    pod.quantity_ordered - pod.quantity_delivered     QTY_ORDERED,
	    pod.wip_entity_id     WIP_ENTITY_ID,
	    pod.wip_operation_seq_num      WIP_OPERATION_SEQ_NUM,
	    pod.wip_resource_seq_num      WIP_RESOURCE_SEQ_NUM,
	    pod.wip_repetitive_schedule_id       WIP_REPETITIVE_SCHEDULE_ID,
	    pod.wip_line_id      WIP_LINE_ID,
	    pod.bom_resource_id      BOM_RESOURCE_ID,
	    ''      DESTINATION_TYPE,
	    ''      LOCATION,
	    pod.rate      CURRENCY_CONVERSION_RATE_POD,
	    pod.rate_date      CURRENCY_CONVERSION_DATE_POD,
	    pod.project_id      PROJECT_ID,
	    pod.task_id      TASK_ID
	    FROM
	    RCV_SHIPMENT_LINES RSL,
	    RCV_SHIPMENT_HEADERS RSH,
	    PO_HEADERS POH,
	    PO_LINE_LOCATIONS POLL,
	    PO_LINES POL,
	    PO_RELEASES POR,
	    MTL_SYSTEM_ITEMS MSI,
	    MTL_UNITS_OF_MEASURE MUM,
	    PO_DISTRIBUTIONS POD
	    WHERE
	    POD.PO_DISTRIBUTION_ID = v_po_distribution_id
	    AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
	    AND NVL(POLL.APPROVED_FLAG,'N') = 'Y'
	    AND NVL(POLL.CANCEL_FLAG,'N') = 'N'
	    AND NVL(POLL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
	    AND POLL.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
	    AND POH.PO_HEADER_ID = POLL.PO_HEADER_ID
	    AND POL.PO_LINE_ID = POLL.PO_LINE_ID
	    AND POLL.PO_RELEASE_ID = POR.PO_RELEASE_ID (+)
	    AND MUM.UNIT_OF_MEASURE (+) = RSL.UNIT_OF_MEASURE
	    AND NVL(MSI.ORGANIZATION_ID,RSL.TO_ORGANIZATION_ID) = RSL.TO_ORGANIZATION_ID
	    AND MSI.INVENTORY_ITEM_ID (+) = RSL.ITEM_ID
	    AND POLL.LINE_LOCATION_ID = RSL.PO_LINE_LOCATION_ID
	    AND RSL.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
	    AND RSH.ASN_TYPE IN ('ASN','ASBN')
	    AND RSL.SHIPMENT_LINE_STATUS_CODE <> 'CANCELLED'
	    AND rsl.shipment_line_id = v_shipment_line_id
	    and (p_project_id is null or
            ( p_project_id = -9999 and pod.project_id is null) or -- bug 2669021
              pod.project_id = p_project_id
           )
	    and (p_task_id is null or pod.task_id = p_task_id)
	UNION
	  SELECT
	    'N'       LINE_CHKBOX,
	    'INTERNAL'       SOURCE_TYPE_CODE,
	    DECODE(RSL.SOURCE_DOCUMENT_CODE,'INVENTORY','INVENTORY','REQ','INTERNAL ORDER')       RECEIPT_SOURCE_CODE,
	    RSL.SOURCE_DOCUMENT_CODE       ORDER_TYPE_CODE,
	    ''       ORDER_TYPE,
	    RSH.SHIPMENT_HEADER_ID       PO_HEADER_ID,
	    RSH.SHIPMENT_NUM       PO_NUMBER,
	    RSL.SHIPMENT_LINE_ID       PO_LINE_ID,
	    RSL.LINE_NUM       PO_LINE_NUMBER,
	    RSL.SHIPMENT_LINE_ID       PO_LINE_LOCATION_ID,
	    RSL.LINE_NUM       PO_SHIPMENT_NUMBER,
	    RSH.SHIPMENT_HEADER_ID       PO_RELEASE_ID,
	    RSH.SHIPMENT_HEADER_ID       PO_RELEASE_NUMBER,
	    PORH.REQUISITION_HEADER_ID       REQ_HEADER_ID,
	    PORH.SEGMENT1       REQ_NUMBER,
	    PORL.REQUISITION_LINE_ID       REQ_LINE_ID,
	    PORL.LINE_NUM       REQ_LINE,
	    RSL.REQ_DISTRIBUTION_ID       REQ_DISTRIBUTION_ID,
	    RSL.SHIPMENT_HEADER_ID       RCV_SHIPMENT_HEADER_ID,
	    RSH.SHIPMENT_NUM       RCV_SHIPMENT_NUMBER,
	    RSL.SHIPMENT_LINE_ID       RCV_SHIPMENT_LINE_ID,
	    RSL.LINE_NUM       RCV_LINE_NUMBER,
	    RSL.FROM_ORGANIZATION_ID       FROM_ORGANIZATION_ID,
	    RSL.TO_ORGANIZATION_ID       TO_ORGANIZATION_ID,
	    RSL.SHIPMENT_LINE_ID       VENDOR_ID,
	    ''       SOURCE,
	    TO_NUMBER(NULL)       VENDOR_SITE_ID,
	    'N'       OUTSIDE_OPERATION_FLAG,
	    RSL.ITEM_ID       ITEM_ID,
	    -- Bug 2073164
	    NULL uom_code,
	    RSL.UNIT_OF_MEASURE       PRIMARY_UOM,
	    MUM.UOM_CLASS       PRIMARY_UOM_CLASS,
	    NVL(MSI.ALLOWED_UNITS_LOOKUP_CODE,2)       ITEM_ALLOWED_UNITS_LOOKUP_CODE,
	    NVL(MSI.LOCATION_CONTROL_CODE,1)       ITEM_LOCATOR_CONTROL,
	    DECODE(MSI.RESTRICT_LOCATORS_CODE,1,'Y','N')       RESTRICT_LOCATORS_CODE,
	    DECODE(MSI.RESTRICT_SUBINVENTORIES_CODE,1,'Y','N')       RESTRICT_SUBINVENTORIES_CODE,
	    NVL(MSI.SHELF_LIFE_CODE,1)       SHELF_LIFE_CODE,
	    NVL(MSI.SHELF_LIFE_DAYS,0)       SHELF_LIFE_DAYS,
	    MSI.SERIAL_NUMBER_CONTROL_CODE       SERIAL_NUMBER_CONTROL_CODE,
	    MSI.LOT_CONTROL_CODE       LOT_CONTROL_CODE,
	    DECODE(MSI.REVISION_QTY_CONTROL_CODE,1,'N',2,'Y','N')       ITEM_REV_CONTROL_FLAG_TO,
	    DECODE(MSI1.REVISION_QTY_CONTROL_CODE, 1,'N',2,'Y','N')       ITEM_REV_CONTROL_FLAG_FROM,
	    NULL       ITEM_NUMBER,
	    RSL.ITEM_REVISION       ITEM_REVISION,
	    RSL.ITEM_DESCRIPTION       ITEM_DESCRIPTION,
	    RSL.CATEGORY_ID       ITEM_CATEGORY_ID,
	    ''       HAZARD_CLASS,
	    ''       UN_NUMBER,
	    RSL.VENDOR_ITEM_NUM       VENDOR_ITEM_NUMBER,
	    RSH.SHIP_TO_LOCATION_ID       SHIP_TO_LOCATION_ID,
	    ''       SHIP_TO_LOCATION,
	    RSH.PACKING_SLIP       PACKING_SLIP,
	    RSL.ROUTING_HEADER_ID       ROUTING_ID,
	    ''       ROUTING_NAME,
	    PORL.NEED_BY_DATE       NEED_BY_DATE,
	    RSH.EXPECTED_RECEIPT_DATE       EXPECTED_RECEIPT_DATE,
	    RSL.QUANTITY_SHIPPED       ORDERED_QTY,
	    RSL.PRIMARY_UNIT_OF_MEASURE       ORDERED_UOM,
	    RSH.USSGL_TRANSACTION_CODE       USSGL_TRANSACTION_CODE,
	    RSH.GOVERNMENT_CONTEXT       GOVERNMENT_CONTEXT,
	    NULL       INSPECTION_REQUIRED_FLAG,
	    NULL       RECEIPT_REQUIRED_FLAG,
	    NULL       ENFORCE_SHIP_TO_LOCATION_CODE,
	    TO_NUMBER(NULL)       UNIT_PRICE,
	    NULL       CURRENCY_CODE,
	    NULL       CURRENCY_CONVERSION_TYPE,
	    TO_DATE(NULL)       CURRENCY_CONVERSION_DATE,
	    TO_NUMBER(NULL)       CURRENCY_CONVERSION_RATE,
	    NULL note_to_receiver,
	    --PORL.NOTE_TO_RECEIVER       NOTE_TO_RECEIVER,
	    RSL.DESTINATION_TYPE_CODE       DESTINATION_TYPE_CODE,
	    RSL.DELIVER_TO_PERSON_ID       DELIVER_TO_PERSON_ID,
	    RSL.DELIVER_TO_LOCATION_ID       DELIVER_TO_LOCATION_ID,
	    RSL.TO_SUBINVENTORY       DESTINATION_SUBINVENTORY,
	    RSL.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
	    RSL.ATTRIBUTE1       ATTRIBUTE1,
	    RSL.ATTRIBUTE2       ATTRIBUTE2,
	    RSL.ATTRIBUTE3       ATTRIBUTE3,
	    RSL.ATTRIBUTE4       ATTRIBUTE4,
	    RSL.ATTRIBUTE5       ATTRIBUTE5,
	    RSL.ATTRIBUTE6       ATTRIBUTE6,
	    RSL.ATTRIBUTE7       ATTRIBUTE7,
	    RSL.ATTRIBUTE8       ATTRIBUTE8,
	    RSL.ATTRIBUTE9       ATTRIBUTE9,
	    RSL.ATTRIBUTE10       ATTRIBUTE10,
	    RSL.ATTRIBUTE11       ATTRIBUTE11,
	    RSL.ATTRIBUTE12       ATTRIBUTE12,
	    RSL.ATTRIBUTE13       ATTRIBUTE13,
	    RSL.ATTRIBUTE14       ATTRIBUTE14,
	    RSL.ATTRIBUTE15       ATTRIBUTE15,
	    'OPEN'       CLOSED_CODE,
	    NULL       ASN_TYPE,
	    RSH.BILL_OF_LADING       BILL_OF_LADING,
	    RSH.SHIPPED_DATE       SHIPPED_DATE,
	    RSH.FREIGHT_CARRIER_CODE       FREIGHT_CARRIER_CODE,
	    RSH.WAYBILL_AIRBILL_NUM       WAYBILL_AIRBILL_NUM,
	    RSH.FREIGHT_BILL_NUMBER       FREIGHT_BILL_NUM,
	    RSL.VENDOR_LOT_NUM       VENDOR_LOT_NUM,
	    RSL.CONTAINER_NUM       CONTAINER_NUM,
	    RSL.TRUCK_NUM       TRUCK_NUM,
	    RSL.BAR_CODE_LABEL       BAR_CODE_LABEL,
	    NULL       RATE_TYPE_DISPLAY,
	    'P'       MATCH_OPTION,
	    NULL        COUNTRY_OF_ORIGIN_CODE,
	    TO_NUMBER(NULL)        OE_ORDER_HEADER_ID,
	    TO_NUMBER(NULL)        OE_ORDER_NUM,
	    TO_NUMBER(NULL)        OE_ORDER_LINE_ID,
	    TO_NUMBER(NULL)        OE_ORDER_LINE_NUM,
	    TO_NUMBER(NULL)        CUSTOMER_ID,
	    TO_NUMBER(NULL)        CUSTOMER_SITE_ID,
	    NULL        CUSTOMER_ITEM_NUM,
	    NULL pll_note_to_receiver,
	    --PORL.NOTE_TO_RECEIVER       PLL_NOTE_TO_RECEIVER,
	    TO_NUMBER(NULL)      PO_DISTRIBUTION_ID,
	    TO_NUMBER(NULL)      QTY_ORDERED,
	    TO_NUMBER(NULL)      WIP_ENTITY_ID,
	    TO_NUMBER(NULL)      WIP_OPERATION_SEQ_NUM,
	    TO_NUMBER(NULL)      WIP_RESOURCE_SEQ_NUM,
	    TO_NUMBER(NULL)       WIP_REPETITIVE_SCHEDULE_ID,
	    TO_NUMBER(NULL)      WIP_LINE_ID,
	    TO_NUMBER(NULL)      BOM_RESOURCE_ID,
	    ''      DESTINATION_TYPE,
	    ''      LOCATION,
	    TO_NUMBER(NULL)      CURRENCY_CONVERSION_RATE_POD,
	    TO_DATE(NULL)     CURRENCY_CONVERSION_DATE_POD,
	    TO_NUMBER(NULL)      PROJECT_ID,
	    TO_NUMBER(NULL)      TASK_ID
	    FROM
	    RCV_SHIPMENT_HEADERS RSH,
	    RCV_SHIPMENT_LINES RSL,
	    PO_REQUISITION_HEADERS PORH,
	    PO_REQUISITION_LINES PORL,
	    MTL_SYSTEM_ITEMS MSI,
	    MTL_SYSTEM_ITEMS MSI1,
	    MTL_UNITS_OF_MEASURE MUM
	    WHERE
	    RSH.RECEIPT_SOURCE_CODE <> 'VENDOR'
	    AND RSL.REQUISITION_LINE_ID = PORL.REQUISITION_LINE_ID(+)
	    AND PORL.REQUISITION_HEADER_ID = PORH.REQUISITION_HEADER_ID(+)
	    AND RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID
	    AND MUM.UNIT_OF_MEASURE (+) = RSL.UNIT_OF_MEASURE
	    AND MSI.ORGANIZATION_ID (+) = RSL.TO_ORGANIZATION_ID
	    AND MSI.INVENTORY_ITEM_ID (+) = RSL.ITEM_ID
	    AND MSI1.ORGANIZATION_ID (+) = RSL.FROM_ORGANIZATION_ID
	    AND MSI1.INVENTORY_ITEM_ID (+) = RSL.ITEM_ID
	    AND RSH.ASN_TYPE IS NULL
	    AND RSL.SHIPMENT_LINE_ID = v_shipment_line_id
        AND (( rsl.source_document_code = 'REQ' and
              exists
              (select '1'
               from po_req_distributions_all prd
               where (p_project_id is null or
                      (p_project_id = -9999 and prd.project_id is null) or -- bug 2669021
                      prd.project_id = p_project_id
                     )
               and   (p_task_id is null or prd.task_id = p_task_id)
              )
           )or rsl.source_document_code <> 'REQ'
          );

BEGIN

   SAVEPOINT crt_asn_con_rti_sp;
   x_status := FND_API.G_RET_STS_SUCCESS;
   l_progress := '10';

   -- query po_startup_value
   Begin
     /* Bug 2516729
      * Fetch rcv_shipment_headers.receipt_number for the given shipment_header_id.
      * If it exists , assign it to the global variable for receipt # (g_rcv_global_var.receipt_num)
      * in order that a new receipt # is not created everytime and the existing receipt # is used
      */
     BEGIN
       SELECT receipt_num
       INTO   l_receipt_num
       FROM   rcv_shipment_headers
       WHERE  shipment_header_id = p_shipment_header_id
       AND    ship_to_org_id = p_organization_id;

       inv_rcv_common_apis.g_rcv_global_var.receipt_num := l_receipt_num;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_receipt_num := NULL;
     END;
     INV_rcv_common_apis.init_startup_values(p_organization_id);
   Exception
     when NO_DATA_FOUND then
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_PARAM');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error ;
   End;

   -- default header level non-DB items in rcv_transaction block
   -- and default other values need to be insert into RTI


   l_progress := '20';

   -- default l_group_id ? clear group id after done
   IF INV_rcv_common_apis.g_rcv_global_var.interface_group_id is NULL THEN
      SELECT rcv_interface_groups_s.nextval
	INTO   l_group_id
	FROM   dual;
      INV_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
         l_group_id := INV_rcv_common_apis.g_rcv_global_var.interface_group_id;
   END IF;

   l_progress := '30';


   -- call matching algorithm   ?

   -- initialize input record for matching algorithm
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).group_id := l_group_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := p_rcv_qty;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;
   IF p_item_id IS NOT NULL THEN
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
    ELSE
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := NULL;
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_desc := p_item_desc;
   end if;
   --inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id := p_organization_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).shipment_header_id := p_shipment_header_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_header_id := p_po_header_id;
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := Sysdate;  --?
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id;--BUG# 2794612
   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).task_id := p_task_id;--BUG# 2794612


   l_progress := '60';

   IF p_item_id IS NOT NULL THEN
      SELECT primary_unit_of_measure
	INTO inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
	FROM mtl_system_items
	WHERE mtl_system_items.inventory_item_id = p_item_id
	AND mtl_system_items.organization_id = p_organization_id;
      l_progress := '70';
    ELSE
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure := NULL;
      l_progress := '71';
   END IF;


   IF p_source_type = 'ASN' THEN
      l_match_type := 'ASN';
    ELSE
      l_match_type := 'INTRANSIT SHIPMENT';
      BEGIN
	 SELECT cost_group_id
	   INTO l_rcv_transaction_rec.cost_group_id
	   FROM wms_lpn_contents wlpnc
	  WHERE organization_id = p_organization_id
	    AND parent_lpn_id = p_lpn_id
	    AND wlpnc.inventory_item_id = p_item_id
	    AND exists (SELECT 1
			  FROM cst_cost_group_accounts
			 WHERE organization_id = p_organization_id
			   AND cost_group_id = wlpnc.cost_group_id);
      EXCEPTION
	 WHEN OTHERS THEN
	    l_rcv_transaction_rec.cost_group_id := NULL;
      END;

      IF l_rcv_transaction_rec.cost_group_id IS NULL THEN
	 UPDATE wms_lpn_contents wlpnc
	    SET cost_group_id = NULL
	  WHERE organization_id = p_organization_id
	    AND parent_lpn_id = p_lpn_id
	    AND wlpnc.inventory_item_id = p_item_id
	    AND NOT exists (SELECT 1
			      FROM cst_cost_group_accounts
			     WHERE organization_id = p_organization_id
			       AND cost_group_id = wlpnc.cost_group_id);

      END IF;
   END IF;

/* EOU Comented out as this procedure is not needed by OPM
   INV_rcv_txn_match.matching_logic
     (x_return_status       => l_return_status, --?
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_cascaded_table      => inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross,
      n		            => inv_rcv_std_rcpt_apis.g_receipt_detail_index,
      temp_cascaded_table   => l_rcpt_match_table_detail,
      p_receipt_num         => NULL,
      p_match_type          => l_match_type,
      p_lpn_id              => p_lpn_id
      );

*/

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_MATCH_ERROR');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      FND_MESSAGE.SET_NAME('INV', l_err_message);
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_err_message := '@@@';
   FOR i IN inv_rcv_std_rcpt_apis.g_receipt_detail_index..(inv_rcv_std_rcpt_apis.g_receipt_detail_index + l_rcpt_match_table_detail.COUNT - 1) LOOP
      IF l_rcpt_match_table_detail(i-inv_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_status = 'W' THEN
	 x_status := 'W';

	 l_temp_message := l_rcpt_match_table_detail(i-inv_rcv_std_rcpt_apis.g_receipt_detail_index+1).error_message;
	 IF l_temp_message IS NULL THEN
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    l_msg_prod := 'INV';
	    EXIT;
	 END IF;
	 IF l_err_message = '@@@' THEN
	    l_err_message := l_temp_message;
	    l_msg_prod := 'INV';
	  ELSIF l_temp_message <> l_err_message THEN
	    l_msg_prod := 'INV';
	    l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
	    EXIT;
	 END IF;
      END IF;
   END LOOP;

   IF l_err_message <> '@@@' THEN
      FND_MESSAGE.SET_NAME(l_msg_prod, l_err_message);
      FND_MSG_PUB.ADD;
   END IF;


   -- load the matching algorithm result into input data structure


   -- based on return from matching algorithm,
   -- determine which line in rcv_transaction block to be inserted into RTI


      -- loop through results returned by matching algorithm
   FOR match_result_count IN 1..l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '72';

      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).shipment_line_id,
			      l_rcpt_match_table_detail(match_result_count).po_distribution_id);

      l_progress := '74';

      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;

      l_progress := '76';

      CLOSE l_curs_rcpt_detail;

      l_progress := '78';

      l_rcv_transaction_rec.rcv_shipment_line_id := l_rcpt_match_table_detail(match_result_count).shipment_line_id;
      l_rcv_transaction_rec.po_distribution_id := l_rcpt_match_table_detail(match_result_count).po_distribution_id;


	 -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      l_rcv_transaction_rec.lpn_id := p_lpn_id;
      l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;
      -- update following fields for po_distribution related values
      l_rcv_transaction_rec.currency_conversion_date := l_rcv_rcpt_rec.currency_conversion_date_pod;
      l_rcv_transaction_rec.currency_conversion_rate := l_rcv_rcpt_rec.currency_conversion_rate_pod;
      -- following fileds can have distribution level values
      -- therefore they are set here instead of in the common insert code
      l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.qty_ordered;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      l_rcv_transaction_rec.lpn_id := p_lpn_id;


      -- wip related fields
      IF l_rcv_rcpt_rec.wip_entity_id > 0 THEN
	 l_rcv_transaction_rec.wip_entity_id := l_rcv_rcpt_rec.wip_entity_id;
	 l_rcv_transaction_rec.wip_operation_seq_num := l_rcv_rcpt_rec.wip_operation_seq_num;
	 l_rcv_transaction_rec.wip_resource_seq_num := l_rcv_rcpt_rec.wip_resource_seq_num;

	 l_rcv_transaction_rec.wip_repetitive_schedule_id := l_rcv_rcpt_rec.wip_repetitive_schedule_id;
	 l_rcv_transaction_rec.wip_line_id := l_rcv_rcpt_rec.wip_line_id;
	 l_rcv_transaction_rec.bom_resource_id := l_rcv_transaction_rec.bom_resource_id;
	 -- there is getting actual values call for wip
	 -- since they are not inserted in RTI, I am not calling it here
	 -- the code is in
	 -- rcv_transactions_sv.get_wip_info ()
      END IF;

      l_progress := '80';
      populate_default_values(p_rcv_transaction_rec => l_rcv_transaction_rec,
			      p_rcv_rcpt_rec => l_rcv_rcpt_rec,
			      p_group_id => l_group_id,
			      p_organization_id => p_organization_id,
			      p_item_id => p_item_id,
			      p_revision => p_revision,
			      p_source_type => p_source_type,
			      p_subinventory_code => p_subinventory,
			      p_locator_id => p_locator_id,
			      p_transaction_temp_id => p_transaction_temp_id,
			      p_lot_control_code => p_lot_control_code,
			      p_serial_control_code => p_serial_control_code);

      l_progress := '90';


   END LOOP;

   IF l_curs_rcpt_detail%isopen THEN
      CLOSE l_curs_rcpt_detail;
   END IF;

   -- append index in input table where the line to be detailed needs to be inserted
   --g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + g_receipt_detail_index;

   -- UPDATE lpn context

   l_progress := '100';

   UPDATE wms_license_plate_numbers
     SET lpn_context = 3
     WHERE lpn_id = p_lpn_id;

   l_progress := '110';


   l_progress := '120';
   inv_rcv_common_apis.do_check
     (p_organization_id => p_organization_id,
      p_inventory_item_id => p_item_id,
      p_transaction_type_id => 18,
      p_primary_quantity => l_total_primary_qty,
      x_return_status => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => x_message);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
   END IF;

   l_progress := '130';

/** Not supported by OPM

   -- Calling The ASN Discrepnacy  Details
   inv_cr_asn_details.CREATE_ASN_DETAILS (
					  p_organization_id,
					  l_group_id,
					  l_rcv_rcpt_rec,
					  l_rcv_transaction_rec,
					  inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb,
					  to_number(null),
					  l_return_status,
					  l_msg_data            );
   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
   END IF;

*/

   l_progress := '140';

   -- Clear the Lot Rec
   inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;


EXCEPTION

    WHEN fnd_api.g_exc_error THEN
       ROLLBACK TO crt_asn_con_rti_sp;
       x_status := fnd_api.g_ret_sts_error;
       IF l_curs_rcpt_detail%isopen THEN
	  CLOSE l_curs_rcpt_detail;
       END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

    WHEN fnd_api.g_exc_unexpected_error THEN
       ROLLBACK TO crt_asn_con_rti_sp;
       x_status := fnd_api.g_ret_sts_unexp_error ;
       IF l_curs_rcpt_detail%isopen THEN
	  CLOSE l_curs_rcpt_detail;
       END IF;

       fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );


    WHEN OTHERS THEN
       ROLLBACK TO crt_asn_con_rti_sp;
       x_status := fnd_api.g_ret_sts_unexp_error ;
       IF l_curs_rcpt_detail%isopen THEN
	  CLOSE l_curs_rcpt_detail;
       END IF;


       fnd_msg_pub.count_and_get
	 (p_encoded   => FND_API.g_false,
	  p_count     => l_msg_count,
	  p_data      => x_message
	  );

END;


PROCEDURE create_asn_exp_dd_intf_rec
  (p_move_order_header_id        IN OUT NOCOPY NUMBER,
   p_organization_id             IN NUMBER,
   p_shipment_header_id          IN NUMBER,
   p_po_header_id                IN NUMBER,
   p_source_type                 IN VARCHAR2,
   p_subinventory                VARCHAR2,
   p_locator_id                  NUMBER,
   p_lpn_id                      IN NUMBER,
   p_transaction_temp_id         IN NUMBER,
   x_status                      OUT NOCOPY VARCHAR2,
   x_message                     OUT NOCOPY VARCHAR2,
   p_project_id			 IN NUMBER,
   p_task_id			 IN NUMBER,
   p_country_code                IN VARCHAR2 DEFAULT NULL
   )
  IS

     -- Bug 2182881
     -- changed the cursor as for lot_numbers it was not joining with
     -- organization_id.
     CURSOR l_curs_asn_lpn_content IS
	SELECT
	  lpnc.lpn_id,
	  lpnc.inventory_item_id,
	  lpnc.revision,
	  lpnc.quantity,
	  lpnc.uom_code,
	  lpnc.lot_control_code,
	  lpnc.serial_number_control_code,
	  lpnc.primary_uom_code,
	  p_po_header_id,
	  lpnc.lot_number,
	  mln.expiration_date
	  FROM
	  mtl_lot_numbers mln,
	  (SELECT wlpn.lpn_id,
	   wlpnc.inventory_item_id,
	   msi.organization_id,
	   msi.lot_control_code,
	   msi.serial_number_control_code,
	   msi.primary_uom_code,
	   wlpnc.revision,
	   wlpnc.quantity,
	   wlpnc.uom_code,
	   wlpnc.lot_number,
	   wlpnc.source_line_id
	   FROM wms_lpn_contents wlpnc
	   , wms_license_plate_numbers wlpn
	   , mtl_system_items msi
	   , rcv_shipment_headers rsh
	   WHERE rsh.shipment_header_id = p_shipment_header_id
	   AND (wlpn.source_header_id = rsh.shipment_header_id
		OR wlpn.source_name = rsh.shipment_num)
	   AND wlpn.lpn_context IN (6, 7)   -- only those pre-ASN receiving ones
	   AND wlpnc.parent_lpn_id = Nvl(p_lpn_id, wlpn.lpn_id)
	   AND wlpnc.inventory_item_id = msi.inventory_item_id
	   AND msi.organization_id = p_organization_id
	   AND wlpn.lpn_id = wlpnc.parent_lpn_id
	   AND (wlpnc.source_line_id IN
		(SELECT pola.po_line_id
		 FROM po_lines_all pola
		 WHERE pola.po_header_id = Nvl(p_po_header_id, pola.po_header_id))
		OR wlpnc.source_line_id IS NULL)
	   ) lpnc
	  WHERE lpnc.inventory_item_id = mln.inventory_item_id(+)
	  AND lpnc.lot_number =mln.lot_number(+)
	  AND lpnc.organization_id =mln.organization_id(+);

     CURSOR l_curs_serial_number
       (v_inventory_item_id NUMBER,
	v_revision VARCHAR2,
	v_lot_number VARCHAR2,
	v_lpn_id NUMBER) IS
	   -- bug 2182881
	   -- added nvl around the cursor
	   SELECT serial_number
	     FROM mtl_serial_numbers
	    WHERE inventory_item_id = v_inventory_item_id
	      AND (revision = v_revision OR (revision IS NULL AND
					     v_revision IS NULL))
	      AND (lot_number = v_lot_number OR (lot_number IS NULL AND
						 v_lot_number IS NULL))
	      AND lpn_id = v_lpn_id;

     TYPE number_tab_tp IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

     TYPE date_tab_tp IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_tp IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;

     l_msnt_transaction_temp_id    number_tab_tp;
     l_msnt_last_update_date   date_tab_tp;
     l_msnt_last_updated_by    number_tab_tp;
     l_msnt_creation_date   date_tab_tp;
     l_msnt_created_by  number_tab_tp ;
     l_msnt_fm_serial_number   varchar_tab_tp;
     l_msnt_to_serial_number   varchar_tab_tp;

     l_lpn_id NUMBER;
     l_inventory_item_id NUMBER;
     l_revision VARCHAR2(30);
     l_quantity NUMBER;
     l_uom_code VARCHAR2(3);
     l_lot_control_code NUMBER;
     l_serial_control_code NUMBER;
     l_unit_of_measure VARCHAR2(25);
     l_po_header_id NUMBER;
     l_lot_number VARCHAR2(30);
     l_lot_expiration_date DATE;

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(400);
     l_progress VARCHAR2(10);

     l_transaction_temp_id NUMBER;
     l_serial_txn_temp_id NUMBER;
     l_primary_uom_code VARCHAR2(3);
     l_primary_qty NUMBER;
     l_uom_conv_ratio NUMBER;
     l_serial_number VARCHAR2(30);
     l_msnt_rec  mtl_serial_numbers_temp%ROWTYPE;
     l_serial_number_count NUMBER;

     l_label_status VARCHAR2(500);
BEGIN

   x_status := fnd_api.g_ret_sts_success;

   l_progress := '10';

   OPEN l_curs_asn_lpn_content;

   l_progress := '20';

   LOOP
      FETCH l_curs_asn_lpn_content INTO
	l_lpn_id,
	l_inventory_item_id,
	l_revision,
	l_quantity,
	l_uom_code,
	l_lot_control_code,
	l_serial_control_code,
	l_primary_uom_code,
	l_po_header_id,
	l_lot_number,
	l_lot_expiration_date;

      EXIT WHEN l_curs_asn_lpn_content%notfound;

      l_progress := '30';

      inv_rcv_std_rcpt_apis.update_lpn_org(p_organization_id => p_organization_id,
					   p_lpn_id => l_lpn_id,
					   x_return_status => l_return_status,
					   x_msg_count => l_msg_count,
					   x_msg_data => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '35';
      SELECT unit_of_measure
	INTO l_unit_of_measure
	FROM mtl_item_uoms_view
	WHERE uom_code = l_uom_code
	AND organization_id = p_organization_id
	AND inventory_item_id = l_inventory_item_id;

      l_progress := '40';


      -- insert into mtlt
      IF l_lot_number IS NOT NULL THEN

	 inv_convert.inv_um_conversion(from_unit => l_uom_code,
				       to_unit => l_primary_uom_code,
				       item_id => l_inventory_item_id,
				       uom_rate => l_uom_conv_ratio);

	 IF l_uom_conv_ratio = -99999 THEN -- uom conversion failure
	    FND_MESSAGE.SET_NAME('INV', 'INV_INT_UOMCONVCODE');
	    FND_MSG_PUB.ADD;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 l_primary_qty := l_quantity * l_uom_conv_ratio;

	 inv_rcv_common_apis.insert_lot
	   (p_transaction_temp_id => l_transaction_temp_id,
	    p_created_by => fnd_global.user_id,
	    p_transaction_qty => l_quantity,
	    p_primary_qty => l_primary_qty,
	    p_lot_number => l_lot_number,
	    p_expiration_date => l_lot_expiration_date,
	    p_status_id => NULL,
	    x_serial_transaction_temp_id => l_serial_txn_temp_id,
	    x_return_status => l_return_status,
	    x_msg_data => l_msg_data);

	 IF l_return_status = FND_API.g_ret_sts_error THEN
	    FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	    FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.g_exc_unexpected_error;
	END IF;

      END IF;

      l_progress := '41';

      -- insert into msnt

      IF l_serial_control_code = 2
	OR  l_serial_control_code = 5 THEN

	 OPEN l_curs_serial_number
	   (l_inventory_item_id,
	    l_revision,
	    l_lot_number,
	    l_lpn_id);
	 l_serial_number_count := 0;

	 IF l_serial_txn_temp_id IS NULL THEN  -- Not lot controlled
	    l_progress := '42';
	    SELECT mtl_material_transactions_s.NEXTVAL
	      INTO l_serial_txn_temp_id
	      FROM dual;
	    l_progress := '44';

	    l_transaction_temp_id := l_serial_txn_temp_id;
	 END IF;

	 LOOP
	    l_progress := '45';

	    FETCH l_curs_serial_number INTO l_serial_number;

	    l_progress := '46';

	    EXIT WHEN l_curs_serial_number%notfound;
	    l_serial_number_count := l_serial_number_count + 1;

	    l_msnt_transaction_temp_id(l_serial_number_count) := l_serial_txn_temp_id;
	    l_msnt_last_update_date(l_serial_number_count) := Sysdate;
	    l_msnt_last_updated_by(l_serial_number_count) := fnd_global.user_id;
	    l_msnt_creation_date(l_serial_number_count) := Sysdate;
	    l_msnt_created_by(l_serial_number_count) := fnd_global.user_id;
	    l_msnt_fm_serial_number(l_serial_number_count) := l_serial_number;
	    l_msnt_to_serial_number(l_serial_number_count) := l_serial_number;

	 END LOOP;


	 CLOSE l_curs_serial_number;

	 l_progress := '47';

	 FORALL i IN 1..l_msnt_transaction_temp_id.COUNT
	   INSERT INTO mtl_serial_numbers_temp
	   (transaction_temp_id,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by,
	    fm_serial_number,
	    to_serial_number
	    )
	   VALUES
	   (l_msnt_transaction_temp_id(i),
	    l_msnt_last_update_date(i),
	    l_msnt_last_updated_by(i),
	    l_msnt_creation_date(i),
	    l_msnt_created_by(i),
	    l_msnt_fm_serial_number(i),
	    l_msnt_to_serial_number(i)
	    );

	 l_progress := '48';

	 FORALL i IN 1..l_msnt_transaction_temp_id.COUNT
	   UPDATE mtl_serial_numbers
	   SET group_mark_id = l_serial_txn_temp_id
	   WHERE inventory_item_id = l_inventory_item_id
	   AND serial_number = l_msnt_fm_serial_number(i);

	 l_progress := '49';

      END IF;


      create_asn_con_dd_intf_rec
	(p_move_order_header_id => p_move_order_header_id,
	 p_organization_id => p_organization_id,
	 p_shipment_header_id => p_shipment_header_id,
	 p_po_header_id => l_po_header_id,
	 p_item_id => l_inventory_item_id,
	 p_rcv_qty => l_quantity,
	 p_rcv_uom => l_unit_of_measure,
	 p_rcv_uom_code => l_uom_code,
	 p_source_type => p_source_type,
	 p_subinventory => p_subinventory,
	 p_locator_id => p_locator_id,
	 p_lpn_id => l_lpn_id,
	 p_lot_control_code => l_lot_control_code,
	 p_serial_control_code => l_serial_control_code,
	 p_revision => l_revision,
	 p_transaction_temp_id => Nvl(l_transaction_temp_id, p_transaction_temp_id),
	 x_status => l_return_status,
	 x_message => l_msg_data ,
	 p_project_id => p_project_id,
	 p_task_id  => p_task_id
	 );

	IF l_return_status = FND_API.g_ret_sts_error THEN
	       FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	   FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.g_exc_unexpected_error;
	END IF;


   END LOOP;

   l_progress := '60';

   IF l_curs_asn_lpn_content%isopen THEN
      CLOSE l_curs_asn_lpn_content;
   END IF;

   l_progress := '70';

   -- UPDATE lpn context

   UPDATE wms_license_plate_numbers
     SET lpn_context = 3
     WHERE source_header_id = p_shipment_header_id
     AND lpn_id = Nvl(p_lpn_id, lpn_id);

   l_progress := '80';

   -- UPDATE the lpn history table with source name as ASNEXP since no packing happened.
   -- This is needed to help the cleanup later on
   -- Nothing else is updated to keep in synch with license_plate_number update


                    update wms_lpn_histories
                    set source_name = 'ASNEXP',
                    source_header_id = INV_rcv_common_apis.g_rcv_global_var.interface_group_id
                    where lpn_context = 7
                      and parent_lpn_id in (select lpn_id
                                               from wms_license_plate_numbers
                                              WHERE source_header_id = p_shipment_header_id
                                                AND lpn_id = Nvl(p_lpn_id, lpn_id)
                                           );





EXCEPTION

    WHEN fnd_api.g_exc_error THEN
       x_status := fnd_api.g_ret_sts_error;
       IF l_curs_asn_lpn_content%isopen THEN
	  CLOSE l_curs_asn_lpn_content;
       END IF;

      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

    WHEN fnd_api.g_exc_unexpected_error THEN
       x_status := fnd_api.g_ret_sts_unexp_error ;
       IF l_curs_asn_lpn_content%isopen THEN
	  CLOSE l_curs_asn_lpn_content;
       END IF;

       fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );


    WHEN OTHERS THEN
       x_status := fnd_api.g_ret_sts_unexp_error ;
       IF l_curs_asn_lpn_content%isopen THEN
	  CLOSE l_curs_asn_lpn_content;
       END IF;


       fnd_msg_pub.count_and_get
	 (p_encoded   => FND_API.g_false,
	  p_count     => l_msg_count,
	  p_data      => x_message
	  );

END create_asn_exp_dd_intf_rec;


PROCEDURE create_osp_direct_rti_rec(p_move_order_header_id IN OUT NOCOPY NUMBER,
				    p_organization_id IN NUMBER,
				    p_po_header_id IN NUMBER,
				    p_po_release_id IN NUMBER,
				    p_po_line_id IN NUMBER,
				    p_item_id IN NUMBER,
				    p_rcv_qty IN NUMBER,
				    p_rcv_uom IN VARCHAR2,
				    p_rcv_uom_code IN VARCHAR2,
				    p_source_type IN VARCHAR2,
				    p_transaction_temp_id IN NUMBER,
				    p_revision IN VARCHAR2,
				    p_po_distribution_id IN NUMBER,
				    x_status OUT NOCOPY VARCHAR2,
				    x_message OUT NOCOPY VARCHAR2
				    )
  IS
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(400);
     l_label_status VARCHAR2(500);
     l_progress VARCHAR2(10);
     l_txn_id_tbl inv_label.transaction_id_rec_type;
     l_counter NUMBER := 0;

     CURSOR c_rti_txn_id IS
         /* Bug 2443163 */
	 /* SELECT MIN(rti.interface_transaction_id) */
         /* Group BY LPN_ID is changed for Express Receipts */
         /* Also  duplicate print of LPN labels is avoided */
	 SELECT MAX(rti.interface_transaction_id)
	   FROM rcv_transactions_interface rti
	  WHERE rti.group_id = INV_rcv_common_apis.g_rcv_global_var.interface_group_id
	  GROUP BY decode(p_source_type, 'ASNEXP',rti.interface_transaction_id,'SHIPMENTEXP',rti.interface_transaction_id,null) ;
	  -- GROUP BY rti.lpn_id;
BEGIN
   x_status := fnd_api.g_ret_sts_success;
   l_progress := '10';

   IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
      select  ood.set_of_books_id
	into  inv_rcv_common_apis.g_po_startup_value.sob_id
	FROM  org_organization_definitions ood,
	      gl_sets_of_books sob
       WHERE  organization_id = p_organization_id
	 AND  sob.set_of_books_id = ood.set_of_books_id;
   END IF;

   l_progress := '10';
   -- first check if the transaction date satisfies the validation.
   inv_rcv_common_apis.validate_trx_date(p_trx_date => Sysdate,
					 p_organization_id => p_organization_id,
					 p_sob_id => inv_rcv_common_apis.g_po_startup_value.sob_id,
					 x_return_status => x_status,
					 x_error_code => x_message);

   IF x_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF p_po_header_id IS NULL AND p_item_id IS NULL THEN
      x_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   l_progress := '30';

   create_osp_drct_dlvr_rti_rec(p_move_order_header_id => p_move_order_header_id,
				p_organization_id => p_organization_id,
				p_po_header_id => p_po_header_id,
				p_po_release_id => p_po_release_id,
				p_po_line_id => p_po_line_id,
				p_po_line_location_id => NULL,
				p_po_distribution_id => p_po_distribution_id,
				p_item_id => p_item_id,
				p_rcv_qty => p_rcv_qty,
				p_rcv_uom => p_rcv_uom,
				p_rcv_uom_code => p_rcv_uom_code,
				p_source_type => p_source_type,
				p_transaction_temp_id => p_transaction_temp_id,
				p_revision => p_revision,
				x_status => l_return_status,
				x_message => x_message);

   IF l_return_status = FND_API.g_ret_sts_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_PO_RTI_FAIL');  -- MSGTBD
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_PO_RTI_FAIL');  -- MSGTBD
      FND_MSG_PUB.ADD;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   l_progress := '40';
   x_status := l_return_status; -- l_return_status can be 'W', we want to carry that over

   -- calling label printing API
   IF l_return_status <> FND_API.g_ret_sts_error THEN
      l_progress := '40';

      l_counter := 1;
      OPEN c_rti_txn_id;
      LOOP
	 FETCH c_rti_txn_id
	   INTO l_txn_id_tbl(l_counter);
	 EXIT WHEN c_rti_txn_id%notfound;
	 l_counter := l_counter + 1;
      END LOOP;
      CLOSE c_rti_txn_id;

      inv_label.print_label
	(x_return_status => l_return_status
	 , x_msg_count => l_msg_count
	 , x_msg_data  => l_msg_data
	 , x_label_status  => l_label_status
	 , p_api_version   => 1.0
	 , p_print_mode => 1
	 , p_business_flow_code => 1
	 , p_transaction_id => l_txn_id_tbl
	 );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');  -- MSGTBD
	 FND_MSG_PUB.ADD;
	 x_status := 'W';
      END IF;

   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

   WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
	(p_encoded   => FND_API.g_false,
	 p_count     => l_msg_count,
	 p_data      => x_message
	 );

END create_osp_direct_rti_rec;


PROCEDURE create_direct_rti_rec(p_move_order_header_id IN OUT NOCOPY NUMBER,
				p_organization_id IN NUMBER,
				p_po_header_id IN NUMBER,
				p_po_release_id IN NUMBER,
				p_po_line_id IN NUMBER,
				p_shipment_header_id IN NUMBER,
				p_oe_order_header_id IN NUMBER,
				p_item_id IN NUMBER,
				p_rcv_qty IN NUMBER,
				p_rcv_sec_qty IN NUMBER,
				p_rcv_uom IN VARCHAR2,
				p_rcv_uom_code IN VARCHAR2,
				p_rcv_sec_uom IN VARCHAR2,
				p_rcv_sec_uom_code IN VARCHAR2,
				p_source_type IN VARCHAR2,
				p_subinventory IN VARCHAR2,
				p_locator_id IN NUMBER,
				p_transaction_temp_id IN NUMBER,
				p_lot_control_code IN NUMBER,
				p_serial_control_code IN NUMBER,
				p_lpn_id IN NUMBER,
				p_revision IN VARCHAR2,
				x_status OUT NOCOPY VARCHAR2,
            x_message OUT NOCOPY VARCHAR2,
            p_inv_item_id IN NUMBER DEFAULT NULL,
				p_item_desc IN VARCHAR2 DEFAULT NULL,
				p_location_id IN NUMBER DEFAULT NULL,
				p_is_expense IN VARCHAR2 DEFAULT NULL,
				p_project_id  IN NUMBER default null,
				p_task_id  IN NUMBER default null,
            p_country_code IN VARCHAR2 DEFAULT NULL
				)
  IS
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(400);
     l_label_status VARCHAR2(500);
     l_progress VARCHAR2(10);
     l_txn_id_tbl inv_label.transaction_id_rec_type;
     l_counter NUMBER := 0;
     l_subinventory VARCHAR2(10);
     l_locator_id NUMBER;

     CURSOR c_rti_txn_id IS
         /* Bug 2443163 */
	 /* SELECT MIN(rti.interface_transaction_id) */
         /* Group BY LPN_ID is changed for Express Receipts */
         /* Also  duplicate print of LPN labels is avoided */

	 SELECT MAX(rti.interface_transaction_id)
	   FROM rcv_transactions_interface rti
	  WHERE rti.group_id = INV_rcv_common_apis.g_rcv_global_var.interface_group_id
	  GROUP BY decode(p_source_type, 'ASNEXP',rti.interface_transaction_id,'SHIPMENTEXP',rti.interface_transaction_id,null) ;
	  -- GROUP BY rti.lpn_id;
BEGIN
   x_status := fnd_api.g_ret_sts_success;
   l_progress := '10';

   IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
      select  ood.set_of_books_id
	into  inv_rcv_common_apis.g_po_startup_value.sob_id
	FROM  org_organization_definitions ood,
	      gl_sets_of_books sob
       WHERE  organization_id = p_organization_id
	 AND  sob.set_of_books_id = ood.set_of_books_id;
   END IF;

   l_progress := '10';
   -- first check if the transaction date satisfies the validation.
   inv_rcv_common_apis.validate_trx_date(p_trx_date => Sysdate,
					 p_organization_id => p_organization_id,
					 p_sob_id => inv_rcv_common_apis.g_po_startup_value.sob_id,
					 x_return_status => x_status,
					 x_error_code => x_message);

   IF x_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF p_shipment_header_id IS NULL THEN -- Added this check to fix bug no. 2159179
      IF p_po_header_id IS NULL AND p_item_id IS NULL THEN
         x_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   l_progress := '30';
   IF p_po_header_id IS NOT NULL
     AND p_source_type <> 'ASNEXP'
     AND p_source_type <> 'ASNCONFM'   -- bug fix 2129249
     THEN
      l_progress := '40';
      IF p_item_id IS NULL AND p_item_desc IS NULL THEN
	 x_status := fnd_api.g_ret_sts_error;
	 RETURN;
      END IF;
      l_subinventory := p_subinventory;
      l_locator_id := p_locator_id;
      IF p_location_id IS NOT NULL THEN
	 l_subinventory := '';
	 l_locator_id := '';
      END IF;
      create_po_drct_dlvr_rti_rec(p_move_order_header_id => p_move_order_header_id,
				  p_organization_id => p_organization_id,
				  p_po_header_id => p_po_header_id,
				  p_po_release_id => p_po_release_id,
				  p_po_line_id => p_po_line_id,
				  p_po_line_location_id => NULL,
				  p_po_distribution_id => NULL,
				  p_item_id => p_item_id,
				  p_rcv_qty => p_rcv_qty,
				  p_rcv_sec_qty => p_rcv_sec_qty,
				  p_rcv_uom => p_rcv_uom,
				  p_rcv_uom_code => p_rcv_uom_code,
				  p_rcv_sec_uom => p_rcv_sec_uom,
				  p_rcv_sec_uom_code => p_rcv_sec_uom_code,
				  p_source_type => p_source_type,
				  p_subinventory => l_subinventory,
				  p_locator_id => l_locator_id,
				  p_transaction_temp_id => p_transaction_temp_id,
				  p_lot_control_code => p_lot_control_code,
				  p_serial_control_code => p_serial_control_code,
				  p_lpn_id => p_lpn_id,
				  p_revision => p_revision,
				  x_status => l_return_status,
                                  x_message => x_message,
                                  p_inv_item_id => p_inv_item_id,
				  p_item_desc => p_item_desc,
				  p_location_id => p_location_id,
				  p_is_expense => p_is_expense,
				  p_project_id => p_project_id,
				  p_task_id  => p_task_id,
                                  p_country_code => p_country_code);

      IF l_return_status = FND_API.g_ret_sts_error THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_PO_RTI_FAIL');  -- MSGTBD
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_PO_RTI_FAIL');  -- MSGTBD
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.g_exc_unexpected_error;
      END IF;

    ELSIF p_shipment_header_id IS NOT NULL THEN
      l_progress := '50';

      IF p_source_type = 'ASNEXP' OR
	p_source_type = 'SHIPMENTEXP' OR
	p_source_type = 'SHIPMENT' OR
	p_source_type = 'REQEXP' THEN

	 IF p_source_type = 'ASNEXP' THEN

	    create_asn_exp_dd_intf_rec
	      (p_move_order_header_id  => p_move_order_header_id,
	       p_organization_id       => p_organization_id,
	       p_shipment_header_id    => p_shipment_header_id,
	       p_po_header_id          => p_po_header_id,
	       p_source_type           => 'ASN',
	       p_subinventory          => p_subinventory,
	       p_locator_id            => p_locator_id,
	       p_lpn_id                => p_lpn_id,
	       p_transaction_temp_id   => p_transaction_temp_id,
	       x_status                => l_return_status,
	       x_message               => l_msg_data,
	       p_project_id	       => p_project_id,
	       p_task_id	       => p_task_id,
	       p_country_code          => p_country_code
	       );

	    IF l_return_status = FND_API.g_ret_sts_error THEN
	       FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');  -- MSGTBD
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;


	    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	       FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');  -- MSGTBD
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.g_exc_unexpected_error;
	    END IF;
	  ELSE
	    l_progress := '50';

	    create_asn_exp_dd_intf_rec
	      (p_move_order_header_id  => p_move_order_header_id,
	       p_organization_id       => p_organization_id,
	       p_shipment_header_id    => p_shipment_header_id,
	       p_po_header_id          => p_po_header_id,
	       p_source_type           => 'INTERNAL',
	       p_subinventory          => p_subinventory,
	       p_locator_id            => p_locator_id,
	       p_lpn_id                => p_lpn_id,
	       p_transaction_temp_id   => p_transaction_temp_id,
	       x_status                => l_return_status,
	       x_message               => l_msg_data,
	       p_project_id	       => p_project_id,
	       p_task_id	       => p_task_id,
	       p_country_code          => p_country_code
	       );

	    IF l_return_status = FND_API.g_ret_sts_error THEN
	       FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_INTSHIPEXP_RTI_FAIL');  -- MSGTBD
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;


	    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	       FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_INTSHIPEXP_RTI_FAIL');  -- MSGTBD
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.g_exc_unexpected_error;
	    END IF;

	 END IF;

       ELSIF p_source_type = 'ASNCONFM' THEN
	 l_progress := '60';

	 create_asn_con_dd_intf_rec
	   (p_move_order_header_id  => p_move_order_header_id,
	    p_organization_id       => p_organization_id,
	    p_shipment_header_id    => p_shipment_header_id,
	    p_po_header_id          => p_po_header_id,
	    p_item_id               => p_item_id,
	    p_rcv_qty               => p_rcv_qty,
	    p_rcv_uom               => p_rcv_uom,
	    p_rcv_uom_code          => p_rcv_uom_code,
	    p_source_type           => 'ASN',
	    p_subinventory          => p_subinventory,
	    p_locator_id            => p_locator_id,
	    p_lpn_id                => p_lpn_id,
	    p_lot_control_code      => p_lot_control_code,
	    p_serial_control_code   => p_serial_control_code,
	    p_revision              => p_revision,
	    p_transaction_temp_id   => p_transaction_temp_id,
	    x_status                => l_return_status,
	    x_message               => l_msg_data,
	    p_project_id	    => p_project_id,
	    p_task_id		    => p_task_id,
            p_country_code          => p_country_code,
	    p_item_desc             => p_item_desc
	    );

	 IF l_return_status = FND_API.g_ret_sts_error THEN
	    FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_ASNCON_RTI_FAIL');  -- MSGTBD
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;


	 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	    FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_INTSHIPEXP_RTI_FAIL');  -- MSGTBD
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.g_exc_unexpected_error;
	 END IF;


       ELSE
	 create_int_shp_dr_del_rti_rec(p_move_order_header_id => p_move_order_header_id,
				       p_organization_id => p_organization_id,
				       p_shipment_header_id => p_shipment_header_id,
				       p_shipment_line_id => NULL,
				       p_item_id => p_item_id,
				       p_rcv_qty => p_rcv_qty,
				       p_rcv_uom => p_rcv_uom,
				       p_rcv_uom_code => p_rcv_uom_code,
				       p_source_type => p_source_type,
				       p_subinventory => p_subinventory,
				       p_locator_id => p_locator_id,
				       p_transaction_temp_id => p_transaction_temp_id,
				       p_lot_control_code => p_lot_control_code,
				       p_serial_control_code => p_serial_control_code,
				       p_lpn_id => p_lpn_id,
				       p_revision => p_revision,
                   p_project_id => p_project_id,
                   p_task_id => p_task_id,
				       x_status => l_return_status,
				       x_message => x_message,
				       p_country_code          => p_country_code);
	 IF l_return_status = FND_API.g_ret_sts_error THEN
	    FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL');  -- MSGTBD
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	    FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL');  -- MSGTBD
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.g_exc_unexpected_error;
	 END IF;

      END IF;


    ELSIF p_oe_order_header_id IS NOT NULL THEN
      l_progress := '60';
      create_rma_drct_dlvr_rti_rec(p_move_order_header_id => p_move_order_header_id,
				   p_organization_id => p_organization_id,
				   p_oe_order_header_id => p_oe_order_header_id,
				   p_oe_order_line_id => NULL,
				   p_item_id => p_item_id,
				   p_rcv_qty => p_rcv_qty,
				   p_rcv_uom => p_rcv_uom,
				   p_rcv_uom_code => p_rcv_uom_code,
				   p_source_type => p_source_type,
				   p_subinventory => p_subinventory,
				   p_locator_id => p_locator_id,
				   p_transaction_temp_id => p_transaction_temp_id,
				   p_lot_control_code => p_lot_control_code,
				   p_serial_control_code => p_serial_control_code,
				   p_lpn_id => p_lpn_id,
				   p_revision => p_revision,
				   x_status => l_return_status,
				   x_message => x_message,
				   p_project_id => p_project_id,
				   p_task_id  => p_task_id,
                                   p_country_code => p_country_code );
       IF l_return_status = FND_API.g_ret_sts_error THEN
	  FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL');  -- MSGTBD
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL');  -- MSGTBD
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.g_exc_unexpected_error;
       END IF;
   END IF;

   l_progress := '80';
   x_status := l_return_status; -- l_return_status can be 'W', we want to carry that over

   -- calling label printing API
   IF l_return_status <> FND_API.g_ret_sts_error THEN
      l_progress := '80';


      l_counter := 1;
      OPEN c_rti_txn_id;
      LOOP
	 FETCH c_rti_txn_id
	  INTO l_txn_id_tbl(l_counter);
	 EXIT WHEN c_rti_txn_id%notfound;
	 l_counter := l_counter + 1;
      END LOOP;
      CLOSE c_rti_txn_id;

      inv_label.print_label
	 (x_return_status => l_return_status
	 , x_msg_count => l_msg_count
	 , x_msg_data  => l_msg_data
	 , x_label_status  => l_label_status
	 , p_api_version   => 1.0
	 , p_print_mode => 1
	 , p_business_flow_code => 1
	 , p_transaction_id => l_txn_id_tbl
	 );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
	 FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');  -- MSGTBD
	 FND_MSG_PUB.ADD;
	 x_status := 'W';
      END IF;

   END IF;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );

   WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
	(p_encoded   => FND_API.g_false,
	 p_count     => l_msg_count,
	 p_data      => x_message
	 );

END create_direct_rti_rec;

/*
PROCEDURE pack_lpn_txn
  IS
     l_proc_msg VARCHAR2(400);
     l_return_status NUMBER;
BEGIN

   l_return_status := inv_lpn_trx_pub.process_lpn_trx
     (p_trx_hdr_id => inv_rcv_common_apis.g_rcv_global_var.transaction_header_id,
      p_mode => 2,  -- putaway mode
      p_commit => 'F',
      x_proc_msg => l_proc_msg);


END pack_lpn_txn;
*/


END gml_rcv_dir_rcpt_apis;

/
