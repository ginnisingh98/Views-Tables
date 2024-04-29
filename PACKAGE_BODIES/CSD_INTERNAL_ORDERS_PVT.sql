--------------------------------------------------------
--  DDL for Package Body CSD_INTERNAL_ORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_INTERNAL_ORDERS_PVT" AS
/* $Header: csdviorb.pls 120.0.12010000.9 2010/06/25 09:29:09 subhat noship $ */
-- Start of Comments
-- Package name     : CSD_INTERNAL_ORDERS_PVT
-- Purpose          : This package will contain all the procedures and functions used by the Internal.
--		      		  Orders. Usage of this package is strictly confined to Oracle Depot Repair
--		      		  Development.
--
-- History          : 06/04/2010, Created by Sudheer Bhat
-- NOTE             :
-- End of Comments

-- logging globals.
G_LEVEL_PROCEDURE NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_RUNTIME_LEVEL   NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_RET_STS_SUCCESS VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;

TYPE SN_ASSOCIATIVE_ARRAY IS TABLE OF VARCHAR2(3) INDEX BY VARCHAR2(30);

PROCEDURE populate_rcv_int_tables(p_product_txn_id  IN NUMBER,
								  x_request_group_id OUT NOCOPY NUMBER)
IS
l_hdr_interface_id		JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_to_org_id				NUMBER;
l_destn_ou				NUMBER;
l_process_sts_pending   CONSTANT VARCHAR2(10) := 'PENDING';
l_txn_type_new          CONSTANT VARCHAR2(10) := 'NEW';
l_validation_flag       CONSTANT VARCHAR2(1)  := 'Y';
l_emp_id 				NUMBER;
l_lot_control_flag 		NUMBER;
l_serial_control_flag	NUMBER;
l_primary_uom			VARCHAR2(5);
l_inventory_item_id		NUMBER;
l_subinventory			VARCHAR2(30);
l_quantity				JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_uom					VARCHAR2(15);
l_from_org				NUMBER;
l_requisition_line_id   NUMBER;
l_deliver_to_location_id NUMBER;
l_intf_txn_id			JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_fm_serial_num_tbl		JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_to_serial_num_tbl		JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
lc_api_name 			CONSTANT VARCHAR2(100) := 'CSD_INTERNAL_ORDERS_PVT.populate_rcv_int_tables';
l_shipment_header_id 	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_shipment_line_id   	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_shipment_num      	JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_shipped_date      	JTF_DATE_TABLE   := JTF_DATE_TABLE();

BEGIN
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Getting item controls');
	END IF;
	 -- get the item controls.
	 SELECT msi.serial_number_control_code, msi.lot_control_code, msi.primary_uom_code,
	 		msi.inventory_item_id,mis.subinventory_code,cpt.rcv_into_org,cpt.rcv_into_ou,
	 		msi.primary_unit_of_measure
	 INTO l_serial_control_flag,l_lot_control_flag,l_primary_uom,
	 	  l_inventory_item_id,l_subinventory,l_to_org_id,l_destn_ou,l_uom
	 FROM mtl_system_items_b msi, mtl_item_sub_defaults mis,csd_product_transactions cpt
	 WHERE cpt.product_transaction_id = p_product_txn_id
	 AND   cpt.rcv_into_org			  = msi.organization_id
	 AND   cpt.inventory_item_id	  = msi.inventory_item_id
	 AND   msi.organization_id 		  = mis.organization_id
	 AND   msi.inventory_item_id	  = mis.inventory_item_id;

  	 -- 1. Get the requisition line id and from org information.
	 SELECT cpt.ship_from_org,prl.requisition_line_id,prl.deliver_to_location_id
	 INTO l_from_org,l_requisition_line_id,l_deliver_to_location_id
	 FROM csd_product_transactions cpt, po_requisition_lines_all prl
	 WHERE cpt.product_transaction_id = p_product_txn_id
	 AND   cpt.req_header_id	      = prl.requisition_header_id;

  -- 2 .get the shipment header id and line id.
	 SELECT rsh.shipment_header_id, rsl.shipment_line_id,rsh.shipment_num,rsh.shipped_date,rsl.quantity_shipped
	 BULK COLLECT INTO l_shipment_header_id,l_shipment_line_id,l_shipment_num,l_shipped_date,l_quantity
	 FROM rcv_shipment_headers rsh, rcv_shipment_lines rsl
	 WHERE rsl.requisition_line_id = l_requisition_line_id
	 AND  rsh.shipment_header_id = rsl.shipment_header_id
	 AND nvl(rsl.quantity_received,0) = 0;

	 IF l_shipment_header_id.COUNT = 0
	 THEN
		 FND_MESSAGE.SET_NAME('CSD','CSD_INT_SHIPMENT_MIS');
		 FND_MSG_PUB.ADD;
		 RAISE fnd_api.g_exc_error;
	 END IF;

	 IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Inserting into rcv_headers_interface');
	 END IF;

	-- populate the rcv transactions header.
	SELECT rcv_interface_groups_s.NEXTVAL INTO x_request_group_id FROM dual;

	l_hdr_interface_id.EXTEND(l_shipment_num.COUNT);

	FOR k IN l_shipment_num.FIRST ..l_shipment_num.LAST
	LOOP
		INSERT INTO rcv_headers_interface (
						   header_interface_id,
						   group_id,
						   ship_to_organization_id,
						   expected_receipt_date, last_update_date,
						   last_updated_by, last_update_login, creation_date,
						   created_by, validation_flag, processing_status_code,
						   receipt_source_code, transaction_type,
						   shipped_Date,
						   shipment_num)
			VALUES   (rcv_headers_interface_s.NEXTVAL,
					  x_request_group_id,
					  l_to_org_id,
					  SYSDATE,SYSDATE,
					  fnd_global.user_id,fnd_global.login_id,SYSDATE,
					  fnd_global.user_id,l_validation_flag,l_process_sts_pending,
					  'INTERNAL ORDER',l_txn_type_new,
					  l_shipped_date(k),
					  l_shipment_num(k))
			RETURNING header_interface_id
			INTO l_hdr_interface_id(k);
	END LOOP;

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Getting employee id and requisition information '||x_request_group_id);
	END IF;

     -- 2. get the employee id
	 csd_receive_util.get_employee_id (fnd_global.user_id, l_emp_id);


	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Inserting into rcv_transactions_interface');
	END IF;

	 -- 3. insert into rcv transactions interface table.
	 l_intf_txn_id.EXTEND(l_shipment_header_id.COUNT);

	 FOR i IN l_shipment_header_id.FIRST ..l_shipment_header_id.LAST
	 LOOP
		 INSERT INTO rcv_transactions_interface
						 (interface_transaction_id,
						  header_interface_id,
						  GROUP_ID,
						  transaction_date,
						  quantity,
						  unit_of_measure,
						  item_id,
						  item_revision,
						  to_organization_id,
						  ship_to_location_id,
						  subinventory,
						  last_update_date,
						  last_updated_by,
						  creation_date,
						  created_by,
						  last_update_login,
						  validation_flag,
						  source_document_code,
						  interface_source_code,
						  auto_transact_code,
						  receipt_source_code,
						  transaction_type,
						  processing_status_code,
						  processing_mode_code,
						  transaction_status_code,
						  category_id,
						  uom_code,
						  employee_id,
						  primary_quantity,
						  primary_unit_of_measure,
						  routing_header_id,
						  routing_step_id,
						  inspection_status_code,
						  destination_type_code,
						  expected_receipt_date,
						  destination_context,
						  use_mtl_lot,
						  use_mtl_serial,
						  source_doc_quantity,
						  source_doc_unit_of_measure,
						  requisition_line_id,
						  shipped_date,
						  shipment_num,
						  from_organization_id,
						  locator_id,
						  deliver_to_location_id,
						  shipment_header_id,
						  shipment_line_id,
						  org_id
						 )
				  VALUES (rcv_transactions_interface_s.NEXTVAL,
						  l_hdr_interface_id(i),
						  x_request_group_id,
						  SYSDATE,
						  l_quantity(i),
						  l_uom,
						  l_inventory_item_id,
						  null,
						  l_to_org_id,
						  null,
						  l_subinventory,
						  SYSDATE,
						  fnd_global.user_id,
						  SYSDATE,
						  fnd_global.user_id,
						  fnd_global.login_id,
						   'Y'
						  , 'REQ'
						  , 'RCV'
						  , 'DELIVER'
						  , 'INTERNAL ORDER'
						  , 'RECEIVE'
						  , 'PENDING'
						  , 'ONLINE'
						  , 'PENDING'
						  , null
						  , l_primary_uom
						  , l_emp_id
						  ,l_quantity(i)
						  ,l_uom
						  , 1
						  , 1
						  , 'NOT INSPECTED'
						  , 'INVENTORY'
						  , SYSDATE
						  , 'INVENTORY'
						  , l_lot_control_flag
						  , l_serial_control_flag
						  , l_quantity(i)
						  , l_uom
						  , l_requisition_line_id
						  , l_shipped_date(i)
						  , l_shipment_num(i)
						  , l_from_org
						  , null
						  , l_deliver_to_location_id
						  , l_shipment_header_id(i)
						  , l_shipment_line_id(i)
						  , l_destn_ou
						 )
			   RETURNING interface_transaction_id
			   INTO l_intf_txn_id(i);

		-- no support for Lot numbers yet.

		-- Populate the serial numbers interface.

		IF l_serial_control_flag IN (2,5,6)
		THEN
			SELECT wsn.fm_serial_number,
			  wsn.to_serial_number
			BULK COLLECT INTO
			  l_fm_serial_num_tbl,
			  l_to_serial_num_tbl
			FROM wsh_delivery_details wdd,
			  wsh_serial_numbers wsn,
			  wsh_delivery_assignments wda
			WHERE wda.delivery_id 			 = to_number(l_shipment_num(i))
			AND wda.delivery_detail_id 		 = wdd.delivery_detail_id
			AND wdd.source_code              = 'OE'
			AND wdd.delivery_detail_id       = wsn.delivery_detail_id;

			-- insert into mtl serial number interface.
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Inserting into mtl_serial_numbers_interface total of '||l_fm_serial_num_tbl.COUNT||' records');
		END IF;
			FORALL j in 1 ..l_fm_serial_num_tbl.COUNT
				INSERT INTO mtl_serial_numbers_interface
							(transaction_interface_id, source_code,
							 source_line_id, last_update_date, last_updated_by,
							 creation_date, created_by, last_update_login,
							 fm_serial_number,
							 to_serial_number,
							 process_flag,
							 product_transaction_id,
							 product_code
							)
					VALUES(l_intf_txn_id(i),'CSD',
						   1,SYSDATE,fnd_global.user_id,
						   SYSDATE,fnd_global.user_id,fnd_global.login_id,
						   l_fm_serial_num_tbl(j),
						   l_to_serial_num_tbl(j),
						   1,
						   l_intf_txn_id(i),
						   'RCV');

		END IF;
	END LOOP;
	-- commit after all the interface tables are populated
	COMMIT WORK;

END populate_rcv_int_tables;

PROCEDURE create_internal_requisition(
								p_api_version 			IN NUMBER,
								p_init_msg_list			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_product_txn_id        IN NUMBER,
								p_destination_ou        IN NUMBER,
								p_destination_org       IN NUMBER,
								p_destination_loc_id    IN NUMBER,
								p_source_ou				IN NUMBER,
								p_source_org            IN NUMBER,
								p_need_by_date			IN DATE,
								x_requisition           OUT NOCOPY VARCHAR2,
								x_requisition_id		OUT NOCOPY NUMBER,
								x_msg_count             OUT NOCOPY NUMBER,
								x_msg_data              OUT NOCOPY VARCHAR2,
								x_return_status         OUT NOCOPY VARCHAR2)
IS
lc_api_name CONSTANT    VARCHAR2(80) := 'CSD_INTERNAL_ORDERS_PVT.create_internal_requisition';
lc_api_version CONSTANT NUMBER   	 := 1.0;
l_user_id 	   			NUMBER		 := fnd_global.user_id;
l_person_id				NUMBER;
l_currency_code			VARCHAR2(15);
l_quantity				NUMBER;
l_item_description      VARCHAR2(240);
l_uom_code 				VARCHAR2(3);
l_inventory_item_id     NUMBER;
l_request_id            NUMBER;
l_material_account 		NUMBER;
l_success				BOOLEAN := TRUE;
x_phase					VARCHAR2(15);
x_status				VARCHAR2(10);
x_dev_phase				VARCHAR2(15);
x_dev_status			VARCHAR2(10);
x_message				VARCHAR2(2000);

BEGIN

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Begin API');
	END IF;

	-- standard check for API compatibility.
	IF NOT Fnd_Api.Compatible_API_Call
				(lc_api_version,
				 p_api_version,
				 lc_api_name,
				 G_PKG_NAME)
	THEN
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF Fnd_Api.to_Boolean(p_init_msg_list)
	THEN
		Fnd_Msg_Pub.initialize;
	END IF;

	x_return_status := G_RET_STS_SUCCESS;
	-- the program logic. First create the internal requisition.
	-- we dont do any validations here. We let the REQIMPORT program validate all
	-- the values for us.
	-- step 1. Get the person_id
	SELECT employee_id
	INTO   l_person_id
	FROM   fnd_user
	WHERE  user_id = l_user_id;

	-- step 2. get the currency code for the destination OU.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Getting currency code');
	END IF;

	SELECT currency_code
	INTO   l_currency_code
	FROM gl_sets_of_books,hr_organization_information
	WHERE set_of_books_id = org_information1
		AND organization_id = p_destination_ou
		AND org_information_context = 'Accounting Information';

	-- step 3. get the quantity required.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Currency code='||l_currency_code||'. Getting required quantity');
	END IF;

	BEGIN
		SELECT cpt.exp_quantity,cpt.inventory_item_id,msi.description,msi.primary_uom_code
		INTO   l_quantity,l_inventory_item_id,l_item_description,l_uom_code
		FROM csd_product_transactions cpt,mtl_system_items_b msi
		WHERE cpt.product_transaction_id = p_product_txn_id
			AND cpt.inventory_item_id = msi.inventory_item_id
			AND msi.organization_id = p_destination_org;
	EXCEPTION
		WHEN no_data_found THEN
			FND_MESSAGE.SET_NAME('CSD','CSD_MIS_ITEM_ORG_ASG');
			FND_MSG_PUB.ADD;
			RAISE fnd_api.g_exc_error;
	END;

	-- step 4. get the material account id.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Getting material account Id');
	END IF;

	SELECT material_account
	into l_material_account
	FROM mtl_parameters
	WHERE organization_id = p_destination_org;

	-- step 4. insert the records into requisitions interface.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Before inserting into requisitions interface.');
	END IF;

	INSERT INTO po_requisitions_interface_all (
	             interface_source_code,
	             destination_type_code,
	             authorization_status,
	             preparer_id,  -- person id of the user name
	             quantity,
	             destination_organization_id,
	             deliver_to_location_id,
	             deliver_to_requestor_id,
	             source_type_code,
	             category_id,
	             item_description,
	             uom_code,
	             unit_price,
	             need_by_date,
	             wip_entity_id,
	             wip_operation_seq_num,
	             charge_account_id,
	             variance_account_id,
	             item_id,
	             wip_resource_seq_num,
	             suggested_vendor_id,
	             suggested_vendor_name,
	             suggested_vendor_site,
	             suggested_vendor_phone,
	             suggested_vendor_item_num,
	             currency_code,
	             project_id,
	             task_id,
		     	 project_accounting_context,
	             last_updated_by,
	             last_update_date,
	             created_by,
	             creation_date,
	             org_id,
		     	 reference_num,
		     	 interface_source_line_id,
		     	 source_organization_id)
	VALUES (
				'CSD',
				'INVENTORY',
				'APPROVED',
				l_person_id,
				l_quantity,
				p_destination_org,
				p_destination_loc_id,
				l_person_id,
				'INVENTORY',
				null,
				l_item_description,
				l_uom_code,
				null,
				p_need_by_date,
				null,
				null,
				l_material_account,
				null,
				l_inventory_item_id,
				null,
				null,
				null,
				null,
				null,
				null,
				l_currency_code,
				null,
				null,
				null,
				l_user_id,
				sysdate,
				l_user_id,
				sysdate,
				p_destination_ou,
				null,
				p_product_txn_id,
				p_source_org
				);
	commit;
	-- step 5. Call the concurrent program.
	fnd_request.set_org_id (p_destination_ou);

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Calling REQIMPORT CP.');
	END IF;
	l_request_id := fnd_request.submit_request(
						'PO', 'REQIMPORT', NULL, NULL, FALSE,'CSD', NULL, 'ALL',
						NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
						) ;

	commit;

	-- step 6. Wait for the requisition import to complete.
	l_success := fnd_concurrent.wait_for_request(
										request_id     => l_request_id,
										interval	   => 5,
										phase          => x_phase,
										status         => x_status,
										dev_phase	   => x_dev_phase,
										dev_status	   => x_dev_status,
										message		   => x_message );
	IF NOT l_success
	THEN
		x_return_status := G_RET_STS_ERROR;
		x_msg_data		:= x_message;
		RETURN;
	END IF;

	-- step 7. Get the requisition number.
	BEGIN
		SELECT segment1,requisition_header_id
		INTO x_requisition,x_requisition_id
		FROM po_requisition_headers_all
		WHERE interface_source_line_id = p_product_txn_id;
	EXCEPTION
		WHEN no_data_found THEN
			fnd_message.set_name('CSD','CSD_INT_REQ_FAIL');
			fnd_msg_pub.add;
			RAISE fnd_api.g_exc_error;
	END;
EXCEPTION
	WHEN fnd_api.g_exc_error THEN
		x_return_status := G_RET_STS_ERROR;

END create_internal_requisition;


PROCEDURE create_internal_move_orders(
								errbuf 		   			OUT NOCOPY VARCHAR2,
	                            retcode 		   		OUT NOCOPY VARCHAR2,
	                            p_product_txn_id        IN NUMBER,
								p_destination_ou        IN NUMBER,
								p_destination_org       IN NUMBER,
								p_destination_loc_id    IN NUMBER,
								p_source_ou				IN NUMBER,
								p_source_org            IN NUMBER,
								p_need_by_date			IN DATE
								)
IS
lc_api_name				VARCHAR2(80) := 'CSD_INTERNAL_ORDERS_PVT.create_internal_move_orders';
x_msg_data 				VARCHAR2(2000);
x_return_status 		VARCHAR2(1);
x_msg_count   			NUMBER;
x_requisition_number 	VARCHAR2(30);
x_requisition_id		NUMBER;
x_phase					VARCHAR2(15);
x_status				VARCHAR2(10);
x_dev_phase				VARCHAR2(15);
x_dev_status			VARCHAR2(10);
x_message				VARCHAR2(2000);
l_request_id			NUMBER;
l_success 				BOOLEAN := TRUE;
l_iso_header_id			NUMBER;
l_iso_line_id			NUMBER;
l_current_ou			NUMBER := fnd_global.org_id;


BEGIN

	-- create internal requisition.
	-- update the csd_product_transactions.
	-- Create Internal Order po program.
	-- order import program.
	-- update csd_product_transactions.

	-- Step 1. Create internal requisition.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Calling CSD_INTERNAL_ORDERS_PVT.create_internal_requisition');
	END IF;
	CSD_INTERNAL_ORDERS_PVT.create_internal_requisition(
	  									  p_api_version 		=> 1.0,
										  p_product_txn_id 		=> p_product_txn_id,
										  p_destination_ou 		=> p_destination_ou,
										  p_destination_org 	=> p_destination_org,
										  p_destination_loc_id 	=> p_destination_loc_id,
										  p_source_ou 			=> p_source_ou,
										  p_source_org 			=> p_source_org,
										  p_need_by_date 		=> p_need_by_date,
										  x_requisition 		=> x_requisition_number,
										  x_requisition_id		=> x_requisition_id,
										  x_msg_count 			=> x_msg_count,
										  x_msg_data 			=> x_msg_data,
										  x_return_status 		=> x_return_status );

	IF x_return_status <> G_RET_STS_SUCCESS
	THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Requisition creation has failed');
		END IF;
		RAISE fnd_api.g_exc_error;
	END IF;

	-- Step 2. Update the product transaction table with the requisition id.

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Requisition created.Update prod txn tbl with req id='||x_requisition_id);
	END IF;
	UPDATE csd_product_transactions SET req_header_id = x_requisition_id
		WHERE product_transaction_id = p_product_txn_id;

	-- Step 3. Launch the Create Internal Orders program.
	fnd_request.set_org_id (p_destination_ou);
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Calling POCISO to populate OM interface tables');
	END IF;
	l_request_id := fnd_request.submit_request(
							'PO', 'POCISO', NULL, NULL, FALSE );
	COMMIT;

	-- wait for the request to complete.
	l_success := fnd_concurrent.wait_for_request(
										request_id     => l_request_id,
										interval	   => 3,
										phase          => x_phase,
										status         => x_status,
										dev_phase	   => x_dev_phase,
										dev_status	   => x_dev_status,
										message		   => x_message );
	IF NOT l_success
	THEN
		errbuf := x_message;
		retcode := 2;
		return;
	END IF;

	-- step 4. Create the internal sales order. Call Import Orders CP.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Calling OEOIMP to create ISO');
	END IF;

	l_request_id := fnd_request.submit_request(
							'ONT', 'OEOIMP', NULL, NULL, FALSE,p_destination_ou,10, x_requisition_id,
							NULL,'N',1,4,NULL,NULL,NULL,'Y','N','Y',l_current_ou,'Y');

	--dbms_output.put_line('launched cp '||l_request_id);
	COMMIT;

	-- wait for the ISO creation to complete.
	l_success := fnd_concurrent.wait_for_request(
										request_id     => l_request_id,
										interval	   => 3,
										phase          => x_phase,
										status         => x_status,
										dev_phase	   => x_dev_phase,
										dev_status	   => x_dev_status,
										message		   => x_message );
	IF NOT l_success
	THEN
		errbuf := x_message;
		retcode := 2;
		return;
	END IF;

	-- Step 6. Get the ISO order header id and line id and update csd_product_transactions.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'Getting ISO created and updating prod txn tbl.');
	END IF;

	SELECT ooh.header_id,
	  ool.line_id
	INTO l_iso_header_id,
	  l_iso_line_id
	FROM oe_order_headers_all ooh,
	  oe_order_lines_all ool
	WHERE ooh.orig_sys_document_ref = x_requisition_number
	AND   ooh.source_document_id    = x_requisition_id
	AND ooh.header_id               = ool.header_id;

	UPDATE csd_product_transactions SET
				order_header_id = l_iso_header_id, order_line_id = l_iso_line_id
	WHERE product_transaction_id = p_product_txn_id;

	COMMIT WORK;

EXCEPTION
	WHEN no_data_found THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'ISO creation failed.');
		END IF;
		fnd_message.set_name('CSD','CSD_CREATE_ISO_FAIL');
		fnd_msg_pub.add;
		fnd_msg_pub.count_and_get(p_count => x_msg_count,
						  		  p_data  => x_msg_data);
		retcode := 2;
	WHEN fnd_api.g_exc_error THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   Fnd_Log.STRING(G_LEVEL_PROCEDURE, lc_api_name,'In g_exc_error');
		END IF;
		retcode := 2;
		fnd_msg_pub.count_and_get(p_count => x_msg_count,
						  		  p_data  => x_msg_data);
	WHEN fnd_api.g_exc_unexpected_error THEN
		null;
	-- when others is specifically skipped here. Some thing totally unexpected has happened. Let the
	-- plsql engine know the caller what it is along with the line number.
END create_internal_move_orders;


PROCEDURE pick_release_internal_order(
								p_api_version 			IN NUMBER,
								p_init_msg_list			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_product_txn_id        IN NUMBER,
								p_order_header_id       IN NUMBER,
								p_orig_quantity   		IN NUMBER,
								p_shipped_quantity      IN NUMBER,
								p_order_line_id         IN NUMBER,
								x_msg_count             OUT NOCOPY NUMBER,
								x_msg_data              OUT NOCOPY VARCHAR2,
								x_return_status         OUT NOCOPY VARCHAR2)
IS
l_order_rec   		csd_process_pvt.om_interface_rec;
l_prod_txn_rec		csd_process_pvt.product_txn_rec;
lc_api_name 		CONSTANT    VARCHAR2(80) := 'CSD_INTERNAL_ORDERS_PVT.pick_release_internal_order';
lc_api_version 		CONSTANT NUMBER   	 := 1.0;
l_user_id  			NUMBER := fnd_global.user_id;
l_login_id 			NUMBER := fnd_global.conc_login_id;
l_document_set_id   NUMBER;
l_order_type_id   	NUMBER;
l_dummy 			VARCHAR2(1);
BEGIN

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Begin API');
	END IF;

	-- standard check for API compatibility.
	IF NOT Fnd_Api.Compatible_API_Call
				(lc_api_version,
				 p_api_version,
				 lc_api_name,
				 G_PKG_NAME)
	THEN
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF fnd_api.to_boolean(p_init_msg_list)
	THEN
		fnd_msg_pub.initialize;
	END IF;

	-- if the shipped quantity is > 0 and < orig_quantity, then the OM order line was split.
	-- from a partial shipment/pick release of the previous transaction.

	IF p_shipped_quantity > 0 AND p_shipped_quantity <> p_orig_quantity
	THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Getting the split line id');
		END IF;
		SELECT line_id
		INTO l_order_rec.order_line_id
		FROM oe_order_lines_all
		WHERE split_from_line_id = p_order_line_id
		AND   header_id  = p_order_header_id;
    ELSE
    	l_order_rec.order_line_id := p_order_line_id;
	END IF;

	-- get the default picking rule id.
	fnd_profile.get('CSD_DEF_PICK_RELEASE_RULE',l_order_rec.picking_rule_id);

	IF l_order_rec.picking_rule_id IS NULL
	THEN
		fnd_message.set_name('CSD', 'CSD_INV_PICKING_RULE_ID');
		fnd_message.set_token('PICKING_RULE_ID',l_order_rec.picking_rule_id );
		fnd_msg_pub.add;
		RAISE fnd_api.g_exc_error;
	END IF;

	l_order_rec.order_header_id := p_order_header_id;

	-- call the API to pick release the sales order.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Calling csd_process_pvt.process_sales_order to pick release');
	END IF;
	csd_process_pvt.process_sales_order(
								p_api_version		=> 1.0,
								p_commit			=> fnd_api.g_false,
								p_init_msg_list		=> fnd_api.g_true,
								p_validation_level 	=> fnd_api.g_valid_level_full,
								p_action			=> 'PICK-RELEASE',
								p_product_txn_rec	=> l_prod_txn_rec,
								p_order_rec			=> l_order_rec,
								x_return_status		=> x_return_status,
								x_msg_count			=> x_msg_count,
								x_msg_data			=> x_msg_data
								);
	IF 	x_return_status <> G_RET_STS_SUCCESS
	THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Pick release errored.'||x_msg_data);
		END IF;
		RAISE fnd_api.g_exc_error;
	END IF;
	-- check if the line is back ordered.
	SELECT released_status
	INTO l_dummy
	FROM wsh_delivery_details
	WHERE source_header_id = p_order_header_id
	AND   source_line_id   = p_order_line_id
	AND   source_code 	   = 'OE';

	IF l_dummy = 'B'
	THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'The delivery has been backordered.');
		END IF;
		fnd_message.set_name('CSD','CSD_NOT_PICK_RELEASED');
		fnd_msg_pub.add;
		RAISE fnd_api.g_exc_error;
	END IF;

	-- currently partial picking is not allowed.
	-- update the product transaction record. Mark it as picked.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Updating ISO as released.');
	END IF;
	UPDATE csd_product_transactions SET release_sales_order_flag = 'Y',
											prod_txn_status = 'RELEASED'
		WHERE product_transaction_id = p_product_txn_id;

	IF p_commit = fnd_api.g_true
	THEN
		COMMIT WORK;
	END IF;

EXCEPTION
	WHEN fnd_api.g_exc_error
	THEN
		x_return_status := G_RET_STS_ERROR;
		fnd_msg_pub.count_and_get(p_count => x_msg_count,
						  		  p_data  => x_msg_data);

END pick_release_internal_order;


PROCEDURE ship_confirm_internal_order(
								p_api_version 			IN NUMBER,
								p_init_msg_list			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_product_txn_id        IN NUMBER,
								p_order_header_id       IN NUMBER,
								p_orig_quantity   		IN NUMBER,
								p_shipped_quantity      IN NUMBER,
								p_order_line_id         IN NUMBER,
								p_fm_serial_num_tbl		IN JTF_VARCHAR2_TABLE_100,
								p_to_serial_num_tbl		IN JTF_VARCHAR2_TABLE_100,
								p_is_sn_range			IN VARCHAR2,
								p_is_reservable			IN VARCHAR2,
								p_lot_num				IN VARCHAR2,
								p_rev					IN VARCHAR2,
								p_quantity_tbl			IN JTF_NUMBER_TABLE,
								x_msg_count             OUT NOCOPY NUMBER,
								x_msg_data              OUT NOCOPY VARCHAR2,
								x_return_status         OUT NOCOPY VARCHAR2)
IS

lc_api_version CONSTANT   NUMBER := 1.0;
lc_api_name    CONSTANT   VARCHAR2(80) := 'CSD_INTERNAL_ORDERS_PVT.ship_confirm_internal_order';
l_serial_control_flag     VARCHAR2(1);
l_lot_control_flag		  VARCHAR2(1);
l_rev_control_flag		  VARCHAR2(1);
l_item_name				  VARCHAR2(240);
l_order_rec   			  csd_process_pvt.om_interface_rec;
l_prod_txn_rec			  csd_process_pvt.product_txn_rec;
l_counter				  NUMBER := 0;
source_code        		  VARCHAR2(15) := 'OE';
changed_attributes 		  wsh_delivery_details_pub.changedattributetabtype;
l_serial_num_range_tab	  wsh_glbl_var_strct_grp.ddserialrangetabtype;
l_attribs_changed_flag	  BOOLEAN := FALSE;
p_delivery_id             NUMBER;
p_action_code             VARCHAR2(15);
p_delivery_name           VARCHAR2(30);
p_asg_trip_id             NUMBER;
p_asg_trip_name           VARCHAR2(30);
p_asg_pickup_stop_id      NUMBER;
p_asg_pickup_loc_id       NUMBER;
p_asg_pickup_loc_code     VARCHAR2(30);
p_asg_pickup_arr_date     DATE;
p_asg_pickup_dep_date     DATE;
p_asg_dropoff_stop_id     NUMBER;
p_asg_dropoff_loc_id      NUMBER;
p_asg_dropoff_loc_code    VARCHAR2(30);
p_asg_dropoff_arr_date    DATE;
p_asg_dropoff_dep_date    DATE;
p_sc_action_flag          VARCHAR2(10);
p_sc_intransit_flag       VARCHAR2(10);
p_sc_close_trip_flag      VARCHAR2(10);
p_sc_create_bol_flag      VARCHAR2(10);
p_sc_stage_del_flag       VARCHAR2(10) := 'Y';
p_sc_trip_ship_method     VARCHAR2(30);
p_sc_actual_dep_date      VARCHAR2(30);
p_sc_defer_interface_flag VARCHAR2(1);
p_sc_report_set_id        NUMBER;
p_sc_report_set_name      VARCHAR2(60);
p_wv_override_flag        VARCHAR2(10);
x_trip_id                 VARCHAR2(30);
x_trip_name               VARCHAR2(30);
x_msg_details             VARCHAR2(3000);
x_msg_summary             VARCHAR2(3000);
l_delivery_detail_id	  NUMBER;
l_shipped_flag			  VARCHAR2(1) := 'Y';
l_del_split_flag		  BOOLEAN := FALSE;
l_quantity_shipped		  NUMBER;

BEGIN

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Begin API');
	END IF;

	-- standard check for API compatibility.
	IF NOT Fnd_Api.Compatible_API_Call
				(lc_api_version,
				 p_api_version,
				 lc_api_name,
				 G_PKG_NAME)
	THEN
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF fnd_api.to_boolean(p_init_msg_list)
	THEN
		fnd_msg_pub.initialize;
	END IF;

	-- if the item is reservable, the item would have been reserved as part of the pick release activity.
	-- if the item is not reservable, then we would need to pass in the serial number, revision and lot number
	-- information.
	IF NOT fnd_api.to_boolean(p_is_reservable)
	THEN
		-- get the item attributes.
		SELECT msi.serial_number_control_code,
			   msi.revision_qty_control_code,
			   msi.lot_control_code,
			   msi.concatenated_segments
		INTO l_serial_control_flag,
			 l_rev_control_flag,
			 l_lot_control_flag,
			 l_item_name
		FROM mtl_system_items_kfv msi, csd_product_transactions cpt
		WHERE cpt.product_transaction_id = p_product_txn_id
			AND cpt.inventory_item_id    = msi.inventory_item_id
			AND msi.organization_id = fnd_profile.value('CSD_DEF_REP_INV_ORG');

		-- item is serial controlled.
		IF l_serial_control_flag IN (2,5,6)
		THEN
			IF p_fm_serial_num_tbl.COUNT = 0
			THEN
				FND_MESSAGE.SET_NAME('CSD','CSD_API_SERIAL_NUM_REQD');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;

		-- item is lot controlled.
		IF l_lot_control_flag = 2
		THEN
			IF p_lot_num IS NULL
			THEN
				FND_MESSAGE.SET_NAME('CSD','CSD_LOT_NUMBER_REQD');
				FND_MESSAGE.SET_TOKEN('ITEM',l_item_name);
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;

		-- item is revision controlled.
		IF l_rev_control_flag = 2
		THEN
			IF p_rev IS NULL
			THEN
				FND_MESSAGE.SET_NAME('CSD','CSD_ITEM_REVISION_REQD');
				FND_MESSAGE.SET_TOKEN('ITEM',l_item_name);
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;
	END IF; -- reservable check over.

	-- get the delivery detail id.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Getting the delivery detail id for order header '||p_order_header_id);
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Getting the delivery detail id for order line '||p_order_line_id);
	END IF;

	BEGIN
		SELECT wdd.delivery_detail_id,wda.delivery_id
		INTO   l_delivery_detail_id,p_delivery_id
		FROM wsh_delivery_assignments wda,
		  wsh_delivery_details wdd
		WHERE wdd.source_header_id = p_order_header_id
		AND wdd.source_line_id     = p_order_line_id
		AND wdd.delivery_detail_id = wda.delivery_detail_id
		AND wdd.released_status    = 'Y'
		AND wdd.source_code        = 'OE';
	EXCEPTION
		WHEN no_data_found THEN
			-- the order was possibly split.
			-- assumption. We assume that at any point, we will have one open delivery line.
			SELECT wdd.delivery_detail_id,wda.delivery_id
			INTO   l_delivery_detail_id,p_delivery_id
			FROM wsh_delivery_assignments wda,
			  wsh_delivery_details wdd
			WHERE wdd.source_header_id = p_order_header_id
			AND wdd.delivery_detail_id = wda.delivery_detail_id
			AND wdd.released_status    = 'Y'
			AND wdd.source_code        = 'OE';
	END;
	-- populate the SN's
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Populating the serial numbers');
	END IF;
	IF fnd_api.to_boolean(p_is_sn_range) AND p_fm_serial_num_tbl IS NOT NULL
	THEN
		FOR j IN 1 ..p_fm_serial_num_tbl.COUNT
		LOOP
			l_serial_num_range_tab(j).delivery_detail_id := l_delivery_detail_id;
			l_serial_num_range_tab(j).from_serial_number := p_fm_serial_num_tbl(j);
			l_serial_num_range_tab(j).to_serial_number   := p_to_serial_num_tbl(j);
			l_serial_num_range_tab(j).quantity			 := p_quantity_tbl(j);
			l_counter 									 := l_counter + p_quantity_tbl(j);
		END LOOP;

	ELSIF p_fm_serial_num_tbl IS NOT NULL
	THEN
		FOR j IN 1 ..p_fm_serial_num_tbl.COUNT
		LOOP
			l_serial_num_range_tab(j).delivery_detail_id := l_delivery_detail_id;
			l_serial_num_range_tab(j).from_serial_number := p_fm_serial_num_tbl(j);
			l_serial_num_range_tab(j).quantity			 := p_quantity_tbl(j);
			l_counter := l_counter+1;
		END LOOP;
	END IF;

	-- call the update attributes API to update the shipping attributes.
	changed_attributes(1).delivery_detail_id := l_delivery_detail_id;
	l_attribs_changed_flag := TRUE;
	IF l_counter > 0
	THEN
		changed_attributes(1).shipped_quantity   := l_counter;

	END IF;
	IF p_orig_quantity > l_counter
	THEN
		changed_attributes(1).cycle_count_quantity := 0;
		l_del_split_flag := TRUE;
	END IF;
	IF p_rev IS NOT NULL
	THEN
		changed_attributes(1).revision	 		 := p_rev;
	END IF;
	IF p_lot_num IS NOT NULL
	THEN
		changed_attributes(1).lot_number		 := p_lot_num;
	END IF;

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Calling WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes');
	END IF;

	IF l_attribs_changed_flag
	THEN
		WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes(
			   p_api_version_number => 1.0,
			   p_init_msg_list      => p_init_msg_list,
			   p_commit             => p_commit,
			   x_return_status      => x_return_status,
			   x_msg_count          => x_msg_count,
			   x_msg_data           => x_msg_data,
			   p_changed_attributes => changed_attributes,
			   p_source_code        => source_code,
			   p_serial_range_tab	=> l_serial_num_range_tab);
	END IF;

  	IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Update shipping attributes failed '||x_msg_data);
		END IF;
		--dbms_output.put_line('Update shipping attributes failed '||x_msg_data);
	    fnd_message.set_name('CSD','CSD_UPDATE_SHIPPING_FAILED');
	    fnd_message.set_token('err_msg', x_msg_data);
	    Fnd_Msg_Pub.ADD;
	    RAISE fnd_api.g_exc_error;
    END IF;
    -- Return status check.

    -- call the delivery action API.

    p_action_code             := 'CONFIRM';
    --p_delivery_id             := l_delivery_id;
    p_delivery_name           := TO_CHAR(p_delivery_id);
    p_sc_action_flag          := 'S';
    p_sc_intransit_flag       := 'Y';
    p_sc_close_trip_flag      := 'Y';
    p_sc_defer_interface_flag := 'N';

	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Calling wsh_deliveries_pub.delivery_action for ship confirm action');
	END IF;

	wsh_deliveries_pub.delivery_action(
		   p_api_version_number      => 1.0,
		   p_init_msg_list           => p_init_msg_list,
		   x_return_status           => x_return_status,
		   x_msg_count               => x_msg_count,
		   x_msg_data                => x_msg_data,
		   p_action_code             => p_action_code,
		   p_delivery_id             => p_delivery_id,
		   p_delivery_name           => p_delivery_name,
		   p_asg_trip_id             => p_asg_trip_id,
		   p_asg_trip_name           => p_asg_trip_name,
		   p_asg_pickup_stop_id      => p_asg_pickup_stop_id,
		   p_asg_pickup_loc_id       => p_asg_pickup_loc_id,
		   p_asg_pickup_loc_code     => p_asg_pickup_loc_code,
		   p_asg_pickup_arr_date     => p_asg_pickup_arr_date,
		   p_asg_pickup_dep_date     => p_asg_pickup_dep_date,
		   p_asg_dropoff_stop_id     => p_asg_dropoff_stop_id,
		   p_asg_dropoff_loc_id      => p_asg_dropoff_loc_id,
		   p_asg_dropoff_loc_code    => p_asg_dropoff_loc_code,
		   p_asg_dropoff_arr_date    => p_asg_dropoff_arr_date,
		   p_asg_dropoff_dep_date    => p_asg_dropoff_dep_date,
		   p_sc_action_flag          => p_sc_action_flag,
		   p_sc_intransit_flag       => p_sc_intransit_flag,
		   p_sc_close_trip_flag      => p_sc_close_trip_flag,
		   p_sc_create_bol_flag      => p_sc_create_bol_flag,
		   p_sc_stage_del_flag       => p_sc_stage_del_flag,
		   p_sc_trip_ship_method     => p_sc_trip_ship_method,
		   p_sc_actual_dep_date      => p_sc_actual_dep_date,
		   p_sc_report_set_id        => p_sc_report_set_id,
		   p_sc_report_set_name      => p_sc_report_set_name,
		   p_sc_defer_interface_flag => p_sc_defer_interface_flag,
		   p_wv_override_flag        => p_wv_override_flag,
		   x_trip_id                 => x_trip_id,
		   x_trip_name               => x_trip_name);

	IF (x_return_status <> Wsh_Util_Core.G_RET_STS_SUCCESS)
	THEN
		--debug(lc_api_name,'Ship confirm failed');
		BEGIN
		  SELECT 'N'
		  INTO l_shipped_flag
		  FROM wsh_delivery_details wdd
		  WHERE wdd.delivery_detail_id = l_delivery_detail_id
		  AND wdd.released_status     <> 'C';
		EXCEPTION
		WHEN no_data_found THEN
		  l_shipped_flag :='Y';
		  x_return_status := G_RET_STS_SUCCESS;
		END;
		IF l_shipped_flag = 'N' then
		  FND_MESSAGE.SET_NAME('CSD','CSD_SHIP_CONFIRM_FAILED');
		  FND_MESSAGE.SET_TOKEN('ERR_MSG',x_msg_data);
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	-- update the csd_product_transactions table with the shipped quantity information.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Updating quantity shipped in prod txn tbl');
	END IF;

	SELECT shipped_quantity
	INTO l_quantity_shipped
	FROM wsh_delivery_details
    WHERE delivery_detail_id = l_delivery_detail_id;

	UPDATE csd_product_transactions SET quantity_shipped =
					(l_quantity_shipped + nvl(quantity_shipped,0) )
		WHERE product_transaction_id = p_product_txn_id;

	IF l_del_split_flag
	THEN
		null;
	END IF;
	IF fnd_api.to_boolean(p_commit)
	THEN
		COMMIT WORK;
	END IF;

EXCEPTION
	WHEN fnd_api.g_exc_error THEN
		/*wsh_util_core.get_messages('Y',
								   x_msg_summary,
								   x_msg_details,
								   x_msg_count);
		IF x_msg_count > 1
		THEN
			x_msg_data := x_msg_summary || x_msg_details;
		ELSE
			x_msg_data := x_msg_summary;
		END IF;*/
		fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Error in ship confirm action '||x_msg_data);
		END IF;

		x_return_status := fnd_api.g_ret_sts_error;
	WHEN no_data_found THEN
		FND_MESSAGE.SET_NAME('CSD','CSD_MISSING_DELIVERY');
		FND_MSG_PUB.ADD;
		fnd_msg_pub.count_and_get(p_count => x_msg_count,
		                                   p_data  => x_msg_data);
		x_return_status := fnd_api.g_ret_sts_error;
END ship_confirm_internal_order;

/********************************************************************************************/
/* Function Name: IS_SERIAL_RANGE_VALID														*/
/* Description: Validates if the generated SN range is valid or not. The moment we find the */
/* 				range invalid, then we break.												*/
/* Returns: 1 if the range is valid, 0 if its not											*/
/********************************************************************************************/

PROCEDURE IS_SERIAL_RANGE_VALID(p_sn_range_tbl			IN JTF_VARCHAR2_TABLE_100,
							   p_inv_item_id			IN NUMBER,
							   p_current_org_id			IN NUMBER,
							   p_subinventory			IN VARCHAR2 DEFAULT NULL,
							   p_out					OUT NOCOPY NUMBER)
IS
l_db_sns JTF_VARCHAR2_TABLE_100;
--l_in_sn_associative_array SN_ASSOCIATIVE_ARRAY;
l_db_sn_associative_array SN_ASSOCIATIVE_ARRAY;
l_limit CONSTANT NUMBER := 1000;

CURSOR db_sn IS
SELECT serial_number
FROM mtl_serial_numbers
WHERE inventory_item_id = p_inv_item_id
AND   current_organization_id = p_current_org_id
AND   current_status = 3 -- resides in stores.
AND   current_subinventory_code = nvl(p_subinventory,current_subinventory_code)
AND   serial_number IN (SELECT * FROM TABLE(CAST(p_sn_range_tbl as JTF_VARCHAR2_TABLE_100)));

BEGIN
	-- bulk collect 1000 SN's at a time from the DB.

	OPEN db_sn;
		LOOP

			FETCH db_sn
				 BULK COLLECT INTO l_db_sns LIMIT l_limit;
					 -- turn the collection into associative array.

					 FOR i IN 1 ..l_db_sns.COUNT
					 LOOP
					 	l_db_sn_associative_array(l_db_sns(i)) := 'Y';
					 END LOOP;

					 -- lookup the associative array to validate the range.
					 FOR j IN 1 ..p_sn_range_tbl.COUNT
					 LOOP
					 	IF NOT l_db_sn_associative_array(p_sn_range_tbl(j)) = 'Y'
					 	THEN
					 		p_out := 0;
					 		RETURN;
					 	END IF;
					 END LOOP;
			EXIT WHEN l_db_sns.COUNT < l_limit;
		END LOOP;
	CLOSE db_sn;
	p_out := 1;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		p_out := 0;

END IS_SERIAL_RANGE_VALID;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: RECEIVE_INTERNAL_ORDER                                                                    */
/* description   : Receives an item specified via Internal Sales Order.										 */
/* Called from   : Internal move orders API.                                                                 */
/* Input Parm    :                                                                                           */
/*                 												                                             */
/* Output Parm   : x_return_status               VARCHAR2    Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/

PROCEDURE RECEIVE_INTERNAL_ORDER(p_api_version 		IN NUMBER,
								 p_init_msg_list	IN VARCHAR2 DEFAULT fnd_api.g_false,
								 p_commit			IN VARCHAR2 DEFAULT fnd_api.g_false,
								 p_product_txn_id   IN NUMBER,
								 p_order_header_id	IN NUMBER,
								 p_order_line_id	IN NUMBER,
								 x_return_status	OUT NOCOPY VARCHAR2,
								 x_msg_count		OUT NOCOPY NUMBER,
								 x_msg_data			OUT NOCOPY VARCHAR2
								 )
IS
lc_api_version          CONSTANT NUMBER := 1.0;
l_receive_tbl 			csd_receive_util.rcv_tbl_type;
x_rcv_error_msg_tbl  	csd_receive_util.rcv_error_msg_tbl;
l_dummy 				NUMBER;
l_validation			EXCEPTION;
lc_api_name				VARCHAR2(80) := 'CSD_INTERNAL_ORDERS_PVT.RECEIVE_INTERNAL_ORDER';
x_request_group_id 	    NUMBER;
l_received_quantity		NUMBER;
BEGIN
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Begin API');
	END IF;

	-- standard check for API compatibility.
	IF NOT Fnd_Api.Compatible_API_Call
				(lc_api_version,
				 p_api_version,
				 lc_api_name,
				 G_PKG_NAME)
	THEN
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF fnd_api.to_boolean(p_init_msg_list)
	THEN
		fnd_msg_pub.initialize;
	END IF;

	x_return_status := G_RET_STS_SUCCESS;
	-- find if there is atleast quantity of 1 shipped for this internal order.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Checking for quantity to be received.');
	END IF;

	SELECT nvl(quantity_shipped,0)
	INTO l_dummy
	FROM csd_product_transactions
	WHERE product_transaction_id = p_product_txn_id
	AND   order_header_id = p_order_header_id
	AND   order_line_id   = p_order_line_id;

	IF l_dummy = 0
	THEN
		FND_MESSAGE.SET_NAME('CSD','CSD_INT_ORD_NOT_SHIPPED');
		FND_MSG_PUB.ADD;
		RAISE l_validation;
	END IF;

	-- validate if the internal requisition is already received based on shipping networks setup.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Validating if the IR is already received via shipping networks setup.');
	END IF;
	BEGIN

		SELECT SUM(rt.quantity)
		INTO l_received_quantity
		FROM csd_product_transactions cpt,
			 po_requisition_lines_all prl,
			 rcv_transactions rt
		WHERE cpt.product_transaction_id = p_product_txn_id
		AND   cpt.req_header_id 		 = prl.requisition_header_id
		AND   prl.requisition_line_id	 = rt.requisition_line_id
		AND   rt.transaction_type		 = 'RECEIVE';

	EXCEPTION
		WHEN no_data_found THEN
			l_received_quantity := 0;
	END;

  	IF l_received_quantity > 0 then
  		-- update the received quantity on product transactions.
  		IF (l_dummy - l_received_quantity)  >= 0
  		THEN
			UPDATE csd_product_transactions SET quantity_received = l_received_quantity
				WHERE product_transaction_id = p_product_txn_id;

			IF fnd_api.to_boolean(p_commit)
			THEN
				COMMIT WORK;
			END IF;
		END IF;

		IF l_received_quantity = l_dummy
		THEN
			FND_MESSAGE.SET_NAME('CSD','CSD_INT_ORD_RECEIVED');
			FND_MSG_PUB.ADD;
			x_msg_data := fnd_message.get;
			RETURN;
		END IF;
	END IF;

	-- populate the rcv int tables.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Calling populate_rcv_int_tables to populate the receiving interfaces.');
	END IF;
	populate_rcv_int_tables(p_product_txn_id   => p_product_txn_id,
							x_request_group_id => x_request_group_id);

	-- call the receive API to receive the lines.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Calling csd_receive_pvt.rcv_req_online to auto receive internal requisitions');
	END IF;
	csd_receive_pvt.rcv_req_online
				   (p_api_version           => 1.0,
				    p_init_msg_list         => fnd_api.g_false,
				    p_commit                => fnd_api.g_false,
				    p_validation_level      => fnd_api.g_valid_level_full,
				    x_return_status         => x_return_status,
				    x_msg_count             => x_msg_count,
				    x_msg_data              => x_msg_data,
				    p_request_group_id      => x_request_group_id
				 );
    IF x_return_status <> G_RET_STS_SUCCESS
    THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Error in online receipt of IR.');
		END IF;
		RAISE fnd_api.g_exc_error;
	END IF;

	-- update the quantity received field in csd_product_transactions with receipt quantity.
	IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
	       fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Updating csd_product_transactions.received_quantity');
	END IF;

	-- find out the transacted quantity from the rcv_transactions.
	SELECT SUM(quantity)
	INTO l_received_quantity
	FROM rcv_transactions
	WHERE group_id = x_request_group_id
		AND transaction_type = 'RECEIVE';

	UPDATE csd_product_transactions SET quantity_received = (
						l_received_quantity + nvl(quantity_received,0))
		WHERE product_transaction_id = p_product_txn_id;
	IF fnd_api.to_boolean(p_commit)
	THEN
		COMMIT WORK;
	END IF;
EXCEPTION
	WHEN fnd_api.g_exc_error THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Execution error:'||x_msg_data);
		END IF;
		-- message has been already set and retrieved.
		x_return_status := G_RET_STS_ERROR;

	WHEN l_validation THEN
		IF (G_LEVEL_PROCEDURE >= G_RUNTIME_LEVEL) THEN
			   fnd_log.string(G_LEVEL_PROCEDURE, lc_api_name,'Validation error:'||x_msg_data);
		END IF;
		fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        x_return_status := G_RET_STS_ERROR;

END RECEIVE_INTERNAL_ORDER;

END CSD_INTERNAL_ORDERS_PVT;

/
