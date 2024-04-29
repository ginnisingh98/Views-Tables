--------------------------------------------------------
--  DDL for Package Body CSD_BULK_RECEIVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_BULK_RECEIVE_UTIL" AS
/* $Header: csdubrub.pls 120.24.12010000.6 2010/04/12 22:18:34 nnadig ship $ */

-- private procedure declarations.
/*-----------------------------------------------------------------------*/
/**Procedure Name: after_under_receipt_prcs                 			 */
/**Description: This routine is called for all under-receipts.			 */
/**             The routine will update the existing charge line quantity*/
/**             and then link it to OM line 							 */
/*-----------------------------------------------------------------------*/

procedure after_under_receipt_prcs (p_repair_line_id  IN NUMBER,
                                    p_order_header_id IN NUMBER,
                                    p_order_line_id   IN NUMBER,
                                    p_received_qty    IN NUMBER
                                    );

procedure after_under_receipt_prcs (
    p_repair_line_id  IN NUMBER,
    p_order_header_id IN NUMBER,
    p_order_line_id   IN NUMBER,
    p_received_qty    IN NUMBER
) IS
l_Charge_Details_rec       CS_Charge_Details_PUB.Charges_Rec_Type;
l_Charge_Details_rec_upd  CS_Charge_Details_PUB.Charges_Rec_Type;

l_prod_txns_rec           CSD_PRODUCT_TRANSACTIONS%ROWTYPE;
-- default out params.
x_return_status VARCHAR2(5);
x_msg_data      VARCHAR2(2000);
x_msg_count     NUMBER;
x_object_version_number NUMBER;

x_line_number number;
x_estimate_detail_id number;
x_msg_index_out number;
l_update_charge_err exception;
l_create_charge_err exception;
BEGIN
  -- entered
  savepoint after_under_receipt_prcs;
  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
     fnd_log.STRING (fnd_log.level_procedure,
     'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
     'Under-receipt: Entered the routine');
  End if;
  -- get the charges default values for the line to be updated/created.
  -- fetch all the details required in a single sql.
  BEGIN
   SELECT  estimate_detail_id,
           charge_line_type,
           org_id,
           transaction_inventory_org,
           business_process_id,
           transaction_type_id,
           inventory_item_id,
           return_reason_code,
           incident_id,
           no_charge_flag,
           currency_code,
           price_list_header_id,
           contract_id,
           coverage_id,
           bill_to_party_id,
           --bill_to_account_id,
           ship_to_party_id,
           ship_to_account_id,
           ship_to_org_id
    INTO   l_Charge_Details_rec.estimate_detail_id,
           l_Charge_Details_rec.charge_line_type,
           l_Charge_Details_rec.org_id,
           l_Charge_Details_rec.transaction_inventory_org,
           l_Charge_Details_rec.business_process_id,
           l_Charge_Details_rec.transaction_type_id,
           l_Charge_Details_rec.inventory_item_id_in,
           l_Charge_Details_rec.return_reason_code,
           l_Charge_Details_rec.incident_id,
           l_Charge_Details_rec.no_charge_flag,
           l_Charge_Details_rec.currency_code,
           l_Charge_Details_rec.price_list_id,
           l_Charge_Details_rec.contract_id,
           l_Charge_Details_rec.coverage_id,
           l_Charge_Details_rec.bill_to_party_id,
          -- l_Charge_Details_rec.bill_to_account_id,
           l_Charge_Details_rec.ship_to_party_id,
           l_Charge_Details_rec.ship_to_account_id,
           l_Charge_Details_rec.ship_to_org_id
    FROM cs_estimate_details
    WHERE source_id = p_repair_line_id
    AND   order_header_id = p_order_header_id
    AND   order_line_id = p_order_line_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- cannot be possible. And we cant get in here.
      null;
  END;
  -- update the estimate_quantity to quantity received.
  l_Charge_Details_rec_upd.quantity_required := p_received_qty;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
     fnd_log.STRING (fnd_log.level_procedure,
     'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
     'Under-receipt: before updating order header_id');
  End if;
  -- need to fake as if the charges line is not submitted to OM.
  update cs_estimate_details
  set order_line_id = null --, order_header_id = null
  where estimate_detail_id = l_Charge_Details_rec.estimate_detail_id;

  -- from the create rec, copy the details required for update.
  l_Charge_Details_rec_upd.estimate_detail_id := l_Charge_Details_rec.estimate_detail_id;
  l_Charge_Details_rec_upd.charge_line_type := l_Charge_Details_rec.charge_line_type;
  l_Charge_Details_rec_upd.org_id := l_Charge_Details_rec.org_id;
  l_Charge_Details_rec_upd.transaction_inventory_org := l_Charge_Details_rec.transaction_inventory_org;
  l_Charge_Details_rec_upd.business_process_id := l_Charge_Details_rec.business_process_id;
  l_Charge_Details_rec_upd.transaction_type_id := l_Charge_Details_rec.transaction_type_id;
  l_Charge_Details_rec_upd.inventory_item_id_in := l_Charge_Details_rec.inventory_item_id_in;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
     fnd_log.STRING (fnd_log.level_procedure,
     'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
     'Under-receipt: Calling update charges API to update the quantity');
  End if;
  savepoint update_charge;
  -- call charges API.
  	CS_Charge_Details_PUB.Update_Charge_Details
	(
		p_api_version              => 1.0,
		p_init_msg_list            => 'F',
		p_commit                   => 'F',
		p_validation_level         => 100,
		x_return_status            => x_return_status,
		x_msg_count                => x_msg_count,
		x_object_version_number    => x_object_version_number,
		x_msg_data                 => x_msg_data,
    	p_transaction_control      => 'T',
		p_Charges_Rec              => l_Charge_Details_rec_upd
		--p_update_cost_detail       => 'N'
	);
--

  if x_return_status <> 'S' THEN
  	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
	     fnd_log.STRING (fnd_log.level_procedure,
	     'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
	     'Under-receipt: Return Status '||x_return_status||' Message '||x_msg_data);
  	End if;
    raise l_update_charge_err;
  end if;

  -- reset the order number and order line values.
  update cs_estimate_details
  set order_header_id = p_order_header_id, order_line_id = p_order_line_id
  where estimate_detail_id = l_Charge_Details_rec.estimate_detail_id;

  -- Need to create a new charge line and associate it to existing OM line.

   l_Charge_Details_rec.estimate_detail_id := null;

   -- get the order line id for the new line.
   begin
    select oel2.line_id,
           oel2.ordered_quantity,
           oel2.order_quantity_uom
    into   l_Charge_Details_rec.order_line_id,
           l_Charge_Details_rec.quantity_required,
           l_Charge_Details_rec.unit_of_measure_code
    from   oe_order_lines_all oel1,
           oe_order_lines_all oel2
    where  oel1.line_id = p_order_line_id
    and    oel1.line_set_id = oel2.line_set_id
    and    oel2.line_id <> p_order_line_id
    and    oel2.flow_status_code = 'AWAITING_RETURN';
  exception
    when no_data_found then
      -- the OM line was not split.
      null;
  end;
  l_Charge_Details_rec.order_header_id := p_order_header_id;
  l_charge_details_rec.add_to_order_flag := 'Y';
  l_Charge_Details_rec.source_code := 'DR';
  l_Charge_Details_rec.original_source_code := 'DR';
  l_Charge_Details_rec.interface_to_oe_flag  := 'Y';
  l_Charge_Details_rec.original_source_id := p_repair_line_id;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
     fnd_log.STRING (fnd_log.level_procedure,
     'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
     'Under-receipt: before calling create charge details');
  End if;
  -- call the create charges API
  savepoint create_charge;
  cs_charge_details_pub.create_charge_details
    (
      p_api_version           => 1.0,
      p_init_msg_list         => 'F',
      p_commit                => 'F',
      p_validation_level      => 100,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_object_version_number => x_object_version_number,
      x_msg_data              => x_msg_data,
      x_estimate_detail_id    => x_estimate_detail_id,
      x_line_number           => x_line_number,
      p_Charges_Rec           => l_Charge_Details_rec
    );

  if x_return_status <> fnd_api.g_ret_sts_success then
    If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
       fnd_log.STRING (fnd_log.level_procedure,
       'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
       'Under-receipt: Error in creating charge lines: '|| x_msg_data);
    End if;
    raise l_create_charge_err;
  end if;

  -- need to create the corresponding record in the CSD_PRODUCT_TRANSACTIONS table.
  -- Essentially all the values will be same as the existing record minus
  -- estimate_detail_id and PROD_TXN_STATUS.
  begin
    select
           CSD_PRODUCT_TRANSACTIONS_S1.nextval,
           REPAIR_LINE_ID,
           ACTION_TYPE,
           ACTION_CODE,
           LOT_NUMBER,
           SUB_INVENTORY,
           INTERFACE_TO_OM_FLAG,
           BOOK_SALES_ORDER_FLAG,
           RELEASE_SALES_ORDER_FLAG,
           SHIP_SALES_ORDER_FLAG,
           'BOOKED',
           PROD_TXN_CODE,
           SYSDATE,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.USER_ID,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CONTEXT,
           1,
      		 REQ_HEADER_ID            ,
      		 REQ_LINE_ID              ,
      		 ORDER_HEADER_ID          ,
      		 SOURCE_SERIAL_NUMBER     ,
      		 SOURCE_INSTANCE_ID   ,
      		 NON_SOURCE_SERIAL_NUMBER ,
      		 NON_SOURCE_INSTANCE_ID ,
           LOCATOR_ID               ,
      		 PICKING_RULE_ID,
           PROJECT_ID,
           TASK_ID,
           UNIT_NUMBER,
           INTERNAL_PO_HEADER_ID

    into
           l_prod_txns_rec.product_transaction_id,
           l_prod_txns_rec.REPAIR_LINE_ID,
           l_prod_txns_rec.ACTION_TYPE,
           l_prod_txns_rec.ACTION_CODE,
           l_prod_txns_rec.LOT_NUMBER,
           l_prod_txns_rec.SUB_INVENTORY,
           l_prod_txns_rec.INTERFACE_TO_OM_FLAG,
           l_prod_txns_rec.BOOK_SALES_ORDER_FLAG,
           l_prod_txns_rec.RELEASE_SALES_ORDER_FLAG,
           l_prod_txns_rec.SHIP_SALES_ORDER_FLAG,
           l_prod_txns_rec.PROD_TXN_STATUS,
           l_prod_txns_rec.PROD_TXN_CODE,
           l_prod_txns_rec.LAST_UPDATE_DATE,
           l_prod_txns_rec.CREATION_DATE,
           l_prod_txns_rec.LAST_UPDATED_BY,
           l_prod_txns_rec.CREATED_BY,
           l_prod_txns_rec.LAST_UPDATE_LOGIN,
           l_prod_txns_rec.ATTRIBUTE1,
           l_prod_txns_rec.ATTRIBUTE2,
           l_prod_txns_rec.ATTRIBUTE3,
           l_prod_txns_rec.ATTRIBUTE4,
           l_prod_txns_rec.ATTRIBUTE5,
           l_prod_txns_rec.ATTRIBUTE6,
           l_prod_txns_rec.ATTRIBUTE7,
           l_prod_txns_rec.ATTRIBUTE8,
           l_prod_txns_rec.ATTRIBUTE9,
           l_prod_txns_rec.ATTRIBUTE10,
           l_prod_txns_rec.ATTRIBUTE11,
           l_prod_txns_rec.ATTRIBUTE12,
           l_prod_txns_rec.ATTRIBUTE13,
           l_prod_txns_rec.ATTRIBUTE14,
           l_prod_txns_rec.ATTRIBUTE15,
           l_prod_txns_rec.CONTEXT,
           l_prod_txns_rec.OBJECT_VERSION_NUMBER,
      		 l_prod_txns_rec.REQ_HEADER_ID            ,
      		 l_prod_txns_rec.REQ_LINE_ID              ,
      		 l_prod_txns_rec.ORDER_HEADER_ID          ,
      		 l_prod_txns_rec.SOURCE_SERIAL_NUMBER     ,
      		 l_prod_txns_rec.SOURCE_INSTANCE_ID   ,
      		 l_prod_txns_rec.NON_SOURCE_SERIAL_NUMBER ,
      		 l_prod_txns_rec.NON_SOURCE_INSTANCE_ID ,
           l_prod_txns_rec.LOCATOR_ID               ,
      		 l_prod_txns_rec.PICKING_RULE_ID,
           l_prod_txns_rec.PROJECT_ID,
           l_prod_txns_rec.TASK_ID,
           l_prod_txns_rec.UNIT_NUMBER,
           l_prod_txns_rec.INTERNAL_PO_HEADER_ID
    from csd_product_transactions
    where estimate_detail_id = l_charge_details_rec_upd.estimate_detail_id;
  exception
    when no_data_found then
      -- somebody removed the row. should not happen.
      null;
  end;

  l_prod_txns_rec.estimate_detail_id := x_estimate_detail_id;
  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
       fnd_log.STRING (fnd_log.level_procedure,
       'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
       'Under-receipt: before calling insert: product txn id :'||l_prod_txns_rec.product_transaction_id);
      End if;
  -- insert the values into csd_product_transactions.
  INSERT INTO CSD_PRODUCT_TRANSACTIONS(
           PRODUCT_TRANSACTION_ID,
           REPAIR_LINE_ID,
           ESTIMATE_DETAIL_ID,
           ACTION_TYPE,
           ACTION_CODE,
           LOT_NUMBER,
           SUB_INVENTORY,
           INTERFACE_TO_OM_FLAG,
           BOOK_SALES_ORDER_FLAG,
           RELEASE_SALES_ORDER_FLAG,
           SHIP_SALES_ORDER_FLAG,
           PROD_TXN_STATUS,
           PROD_TXN_CODE,
           LAST_UPDATE_DATE,
           CREATION_DATE,
           LAST_UPDATED_BY,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CONTEXT,
           OBJECT_VERSION_NUMBER,
      		 REQ_HEADER_ID            ,
      		 REQ_LINE_ID              ,
      		 ORDER_HEADER_ID          ,
      		 SOURCE_SERIAL_NUMBER     ,
      		 SOURCE_INSTANCE_ID   ,
      		 NON_SOURCE_SERIAL_NUMBER ,
      		 NON_SOURCE_INSTANCE_ID ,
           LOCATOR_ID               ,
      		 PICKING_RULE_ID,
           PROJECT_ID,
           TASK_ID,
           UNIT_NUMBER,
           INTERNAL_PO_HEADER_ID
  ) VALUES (
           l_prod_txns_rec.product_transaction_id,
           l_prod_txns_rec.REPAIR_LINE_ID,
           l_prod_txns_rec.estimate_detail_id,
           l_prod_txns_rec.ACTION_TYPE,
           l_prod_txns_rec.ACTION_CODE,
           l_prod_txns_rec.LOT_NUMBER,
           l_prod_txns_rec.SUB_INVENTORY,
           l_prod_txns_rec.INTERFACE_TO_OM_FLAG,
           l_prod_txns_rec.BOOK_SALES_ORDER_FLAG,
           l_prod_txns_rec.RELEASE_SALES_ORDER_FLAG,
           l_prod_txns_rec.SHIP_SALES_ORDER_FLAG,
           l_prod_txns_rec.PROD_TXN_STATUS,
           l_prod_txns_rec.PROD_TXN_CODE,
           l_prod_txns_rec.LAST_UPDATE_DATE,
           l_prod_txns_rec.CREATION_DATE,
           l_prod_txns_rec.LAST_UPDATED_BY,
           l_prod_txns_rec.CREATED_BY,
           l_prod_txns_rec.LAST_UPDATE_LOGIN,
           l_prod_txns_rec.ATTRIBUTE1,
           l_prod_txns_rec.ATTRIBUTE2,
           l_prod_txns_rec.ATTRIBUTE3,
           l_prod_txns_rec.ATTRIBUTE4,
           l_prod_txns_rec.ATTRIBUTE5,
           l_prod_txns_rec.ATTRIBUTE6,
           l_prod_txns_rec.ATTRIBUTE7,
           l_prod_txns_rec.ATTRIBUTE8,
           l_prod_txns_rec.ATTRIBUTE9,
           l_prod_txns_rec.ATTRIBUTE10,
           l_prod_txns_rec.ATTRIBUTE11,
           l_prod_txns_rec.ATTRIBUTE12,
           l_prod_txns_rec.ATTRIBUTE13,
           l_prod_txns_rec.ATTRIBUTE14,
           l_prod_txns_rec.ATTRIBUTE15,
           l_prod_txns_rec.CONTEXT,
           l_prod_txns_rec.OBJECT_VERSION_NUMBER,
      		 l_prod_txns_rec.REQ_HEADER_ID            ,
      		 l_prod_txns_rec.REQ_LINE_ID              ,
      		 l_prod_txns_rec.ORDER_HEADER_ID          ,
      		 l_prod_txns_rec.SOURCE_SERIAL_NUMBER     ,
      		 l_prod_txns_rec.SOURCE_INSTANCE_ID   ,
      		 l_prod_txns_rec.NON_SOURCE_SERIAL_NUMBER ,
      		 l_prod_txns_rec.NON_SOURCE_INSTANCE_ID ,
           l_prod_txns_rec.LOCATOR_ID               ,
      		 l_prod_txns_rec.PICKING_RULE_ID,
           l_prod_txns_rec.PROJECT_ID,
           l_prod_txns_rec.TASK_ID,
           l_prod_txns_rec.UNIT_NUMBER,
           l_prod_txns_rec.INTERNAL_PO_HEADER_ID) ;


EXCEPTION
  WHEN l_update_charge_err THEN
    -- write the error message to bulk receive log.
    write_to_conc_log(x_msg_count,x_msg_data);

    If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    FOR j in 1 ..x_msg_count
    LOOP
       FND_MSG_PUB.Get(
	   				      	p_msg_index     => j,
	   				       	p_encoded       => 'F',
	   					      p_data          => x_msg_data,
					      p_msg_index_out => x_msg_index_out);
       fnd_log.STRING (fnd_log.level_procedure,
       'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
       'Under-receipt: Return Status '||x_msg_count||' Message '||x_msg_data);
     END LOOP;
     End if;
     rollback to update_charge;

   WHEN l_create_charge_err THEN
     write_to_conc_log(x_msg_count,x_msg_data);

     If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
       FOR j in 1 ..x_msg_count
       LOOP
         FND_MSG_PUB.Get(
   				      	p_msg_index     => j,
   				       	p_encoded       => 'F',
   					      p_data          => x_msg_data,
   					      p_msg_index_out => x_msg_index_out);
          fnd_log.STRING (fnd_log.level_procedure,
          'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
          'Under-receipt: create charge err '||x_msg_count||' Message '||x_msg_data);
        END LOOP;
      End if;
     rollback to create_charge;
   WHEN OTHERS THEN
      If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
       fnd_log.STRING (fnd_log.level_procedure,
       'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.AFTER_UNDER_RECEIPT_PRCS',
       'Under-receipt: WHEN OTHERS : Message '||SQLERRM);
      End if;
      raise;

END after_under_receipt_prcs;

/*-----------------------------------------------------------------*/
/* procedure name: validate_bulk_receive_rec                       */
/* description   : Validate Bulk Receive record definition         */
/*                                                                 */
/*-----------------------------------------------------------------*/

PROCEDURE validate_bulk_receive_rec
(
  p_party_id             IN   NUMBER,
  p_quantity             IN   NUMBER,
  p_serial_number        IN   VARCHAR2,
  p_inventory_item_id    IN   NUMBER,
  x_warning_flag         OUT  NOCOPY VARCHAR2,
  x_warning_reason_code  OUT  NOCOPY VARCHAR2,
  x_change_owner_flag    OUT  NOCOPY VARCHAR2,
  x_internal_sr_flag     OUT  NOCOPY VARCHAR2)
IS

-- Cursor to get item attributes
Cursor c_get_item_attributes (p_inventory_item_id in Number) IS
select serial_number_control_code,
       comms_nl_trackable_flag
from mtl_system_items_kfv
where inventory_item_id = p_inventory_item_id
and organization_id = cs_std.get_item_valdn_orgzn_id;

-- Cursor to derive the Instance and IB Owner
Cursor c_get_ib_info ( p_inventory_item_id in Number,p_serial_number in Varchar2) is
Select
  owner_party_id,
  instance_id
from csi_item_instances
where serial_number = p_serial_number
and inventory_item_id = p_inventory_item_id;

-- Cursor to verify the Serial number against the Item
Cursor c_validate_sn_item (p_inventory_item_id in Number,p_serial_number in Varchar2) is
Select
  inventory_item_id
from mtl_serial_numbers
where serial_number = p_serial_number
and inventory_item_id = p_inventory_item_id;

-- Local variables
l_serial_num_control_code  Number;
l_install_base_flag        Varchar2(1);
l_owner_party_id           Number;
l_instance_id              Number;
l_inventory_item_id        Number;
c_serialized_predefined    CONSTANT Number := 2;
c_non_serialized           CONSTANT Number := 1;
c_ib                       CONSTANT Varchar2(1) := 'Y';
c_non_ib                   CONSTANT Varchar2(1) := 'N';

BEGIN

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_procedure,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.VALIDATE_BULK_RECEIVE_REC.BEGIN',
                      'Enter - Validate bulk receive rec');
  End if;
  --
  -- Initialize the flags
  --
  x_warning_flag        := 'N';
  x_warning_reason_code := Null;
  x_internal_sr_flag    := 'N';
  x_change_owner_flag   := 'N';

  --
  -- Derive the Item attributes
  --
  If ( p_inventory_item_id is not null ) then

    l_serial_num_control_code := null;
    l_install_base_flag := null;

    Open c_get_item_attributes (p_inventory_item_id);
    Fetch c_get_item_attributes into
          l_serial_num_control_code,
          l_install_base_flag;

    If c_get_item_attributes%ISOPEN THEN
      Close c_get_item_attributes;
    End If;
  End if;

  -- If Inventory_item_id is NULL
  If ( p_inventory_item_id is null) then

    x_warning_flag        := 'Y';
    x_warning_reason_code := 'ITEM_NOT_ENTERED';
    x_internal_sr_flag    := 'Y';
    x_change_owner_flag   := 'N';

  End if;


  -- If Inventory_item_id is NOT NULL and Serial_Number is NULL
  If ( p_inventory_item_id is not null and p_serial_number is null ) then

    If ( l_serial_num_control_code <> c_non_serialized and p_quantity > 1) then
      x_warning_flag        := 'Y';
      x_warning_reason_code := 'CREATE_DRAFT_RO';
      x_internal_sr_flag    := 'N';
      x_change_owner_flag   := 'N';
    End if;

  End if;


  -- If Serial_Number is NOT NULL and Inventory_item_id is NOT NULL
  If ( p_inventory_item_id is not null and p_serial_number is not null ) then

    -- For NON Serialized Item
    If ( l_serial_num_control_code = c_non_serialized ) then
      x_warning_flag        := 'Y';
      x_warning_reason_code := 'NON_SN_ITEM';
      x_internal_sr_flag    := 'Y';
      x_change_owner_flag   := 'N';
    End if;

    -- For Serialized IB Item
    -- Verify if Instance exists,if not then Create new Instance Else
    -- Verify if Change IB Owner is required
    If ( l_serial_num_control_code <> c_non_serialized and l_install_base_flag = c_ib ) then

      l_owner_party_id := null;
      l_instance_id    := null;

      Open c_get_ib_info(p_inventory_item_id,p_serial_number);
      Fetch c_get_ib_info into l_owner_party_id,l_instance_id;

      If ( c_get_ib_info%NOTFOUND) then

        x_warning_flag        := 'Y';
        x_warning_reason_code := 'CREATE_IB_INSTANCE';
        x_internal_sr_flag    := 'N';
        x_change_owner_flag   := 'N';

      Else
        -- If the Owner party <> Entered Party and if the
        -- Change IB Owner profile is set to Yes then
        -- Change the IB Owner.
        If ( l_owner_party_id <> p_party_id ) then
          If ( fnd_profile.value('CSD_BLK_RCV_CHG_IB_OWNER') = 'Y') then
            x_warning_flag        := 'Y';
            x_warning_reason_code := 'CHANGE_IB_OWNER';
            x_internal_sr_flag    := 'N';
            x_change_owner_flag   := 'Y';
          End if;
        End  if;

      End if;

      Close c_get_ib_info;

    End if;

    If ( l_serial_num_control_code <> c_non_serialized and p_serial_number is not null) then

      -- check the SN status ( @receipt,@pre-defined,@So issue )
      l_inventory_item_id := null;

      Open c_validate_sn_item(p_inventory_item_id,p_serial_number);
      Fetch c_validate_sn_item into l_inventory_item_id;

      If ( c_validate_sn_item%NOTFOUND )then

        If ( l_serial_num_control_code = c_serialized_predefined )then

          x_warning_flag        := 'Y';
          x_warning_reason_code := 'CANNOT_CREATE_PRE_DEFINED_SN';
          x_internal_sr_flag    := 'Y';
          x_change_owner_flag   := 'N';

        Else

          If ( nvl(l_install_base_flag,c_non_ib) = c_non_ib ) then
            x_warning_flag        := 'Y';
            x_warning_reason_code := 'CREATE_SN';
            x_internal_sr_flag    := 'N';
            x_change_owner_flag   := 'N';
          End if;

        End if;

      End if;

      Close c_validate_sn_item;

    End if;

  End if;

  If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_statement,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.VALIDATE_BULK_RECEIVE_REC',
	            'Warning Flag - '||x_warning_flag||
	            ',Warning Reason Code - '||x_warning_reason_code||
	            ',Internal SR Flag - '||x_internal_sr_flag||
	            ',Change Owner Flag - '||x_change_owner_flag);
  End if;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_procedure,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.VALIDATE_BULK_RECEIVE_REC.END',
                      'Exit - Validate bulk receive rec');
  End if;

END validate_bulk_receive_rec;


/*-----------------------------------------------------------------*/
/* procedure name: create_blkrcv_sr                                */
/* description   : Procedure to create Service Request             */
/*                                                                 */
/*-----------------------------------------------------------------*/

PROCEDURE create_blkrcv_sr
(
  p_bulk_receive_rec    IN     csd_bulk_receive_util.bulk_receive_rec,
  p_sr_notes_tbl        IN     cs_servicerequest_pub.notes_table,
  x_incident_id         OUT    NOCOPY NUMBER,
  x_incident_number     OUT    NOCOPY VARCHAR2,
  x_return_status       OUT    NOCOPY VARCHAR2,
  x_msg_count           OUT    NOCOPY NUMBER,
  x_msg_data            OUT    NOCOPY VARCHAR2

 )
IS

-- Cursor to derive party type
Cursor c_sr_party(p_party_id number) is
select party_type from hz_parties
where party_id = p_party_id;

-- Cursor to derive primary bill to site id
Cursor c_bill_to_site(p_party_id number) is
Select hpu.party_site_use_id
from hz_party_sites hps,
     hz_party_site_uses hpu
where
hps.party_id = p_party_id
and hps.party_site_id = hpu.party_site_id
and hpu.site_use_type = 'BILL_TO'
and hpu.primary_per_type = 'Y';

-- Cursor to derive primary ship to site id
Cursor c_ship_to_site(p_party_id number) is
Select hpu.party_site_use_id
from hz_party_sites hps,
     hz_party_site_uses hpu
where
hps.party_id = p_party_id
and hps.party_site_id = hpu.party_site_id
and hpu.site_use_type = 'SHIP_TO'
and hpu.primary_per_type = 'Y';

-- Local variables
l_api_name               CONSTANT VARCHAR2(30)   := 'CREATE_BLKRCV_SR';
l_api_version            CONSTANT NUMBER         := 1.0;
l_party_type             Varchar2(30);
l_bill_to_site_use_id    Number;
l_ship_to_site_use_id    Number;
l_service_request_rec    CSD_PROCESS_PVT.SERVICE_REQUEST_REC := CSD_PROCESS_UTIL.SR_REC;

BEGIN

  savepoint create_blkrcv_sr;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_procedure,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_SR.BEGIN',
                      'Enter - Create Blkrcv SR');
  End if;

  -- Derive the party type
  l_party_type := null;

  Open c_sr_party (p_bulk_receive_rec.party_id);
  Fetch c_sr_party into l_party_type;
  Close c_sr_party;

  -- Derive the Primary Bill To Site Use Id
  l_bill_to_site_use_id := null;

  Open c_bill_to_site (p_bulk_receive_rec.party_id);
  Fetch c_bill_to_site into l_bill_to_site_use_id;
  Close c_bill_to_site;

  -- Derive the Primary Ship To Site Use Id
  l_ship_to_site_use_id := null;

  Open c_ship_to_site (p_bulk_receive_rec.party_id);
  Fetch c_ship_to_site into l_ship_to_site_use_id;
  Close c_ship_to_site;

  -- Assign / Initialize the Service request Rec
  l_service_request_rec.request_date          := sysdate;
  l_service_request_rec.type_id               := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_TYPE');
  l_service_request_rec.status_id             := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_STATUS');
  l_service_request_rec.severity_id           := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_SEVERITY');
  l_service_request_rec.urgency_id            := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_URGENCY');
  l_service_request_rec.closed_date           := null;
  l_service_request_rec.owner_id              := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_OWNER');
  l_service_request_rec.owner_group_id        := NULL;
  l_service_request_rec.publish_flag          := '';
  l_service_request_rec.summary               := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_SUMMARY');
  l_service_request_rec.caller_type           := l_party_type;
  l_service_request_rec.customer_id           := p_bulk_receive_rec.party_id;
  l_service_request_rec.customer_number       := null;
  l_service_request_rec.customer_product_id   := null;
  l_service_request_rec.cp_ref_number         := null;
  l_service_request_rec.inv_item_revision     := null;
  l_service_request_rec.inventory_item_id     := null;
  l_service_request_rec.inventory_org_id      := null;
  l_service_request_rec.current_serial_number := null;
  l_service_request_rec.original_order_number := null;
  l_service_request_rec.purchase_order_num    := null;
  l_service_request_rec.problem_code          := null;
  l_service_request_rec.exp_resolution_date   := null;
  l_service_request_rec.bill_to_site_use_id   := l_bill_to_site_use_id;
  l_service_request_rec.ship_to_site_use_id   := l_ship_to_site_use_id;
  l_service_request_rec.contract_id           := null;
  l_service_request_rec.account_id            := p_bulk_receive_rec.cust_account_id;
  l_service_request_rec.cust_po_number        := null;
  l_service_request_rec.cp_revision_id        := null;
  l_service_request_rec.sr_contact_point_id   := null;
  l_service_request_rec.party_id              := null;
  l_service_request_rec.contact_point_id      := null;
  l_service_request_rec.contact_point_type    := null;
  l_service_request_rec.primary_flag          := null;
  l_service_request_rec.contact_type          := null;
  l_service_request_rec.sr_creation_channel   := 'PHONE';
  l_service_request_rec.resource_type         := FND_PROFILE.value('CS_SR_DEFAULT_OWNER_TYPE');


  -- Call the Service Request API
  CSD_PROCESS_PVT.process_service_request
    ( p_api_version          => 1.0,
      p_commit               => fnd_api.g_false,
      p_init_msg_list        => fnd_api.g_true,
      p_validation_level     => fnd_api.g_valid_level_full,
      p_action               => 'CREATE',
      p_incident_id          => NULL,
      p_service_request_rec  => l_service_request_rec,
      p_notes_tbl            => p_sr_notes_tbl,
      x_incident_id          => x_incident_id,
      x_incident_number      => x_incident_number,
      x_return_status        => x_return_status,
      x_msg_count            => x_msg_count,
      x_msg_data             => x_msg_data
    );

  If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  End If;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_procedure,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_SR.END',
                      'Exit - Create Blkrcv SR');
  End if;

EXCEPTION
  When FND_API.G_EXC_ERROR then
    Rollback To create_blkrcv_sr;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
      (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data  );

  When FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO create_blkrcv_sr;
    FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

  When OTHERS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    Rollback To create_blkrcv_sr;
    If  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)then
      FND_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME,
         l_api_name  );
     End If;
     FND_MSG_PUB.Count_And_Get
       (p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

END create_blkrcv_sr;


/*-----------------------------------------------------------------*/
/* procedure name: create_blkrcv_ro                                */
/* description   : Procedure to create a Repair Order              */
/*                                                                 */
/*-----------------------------------------------------------------*/

PROCEDURE create_blkrcv_ro
(
  p_bulk_receive_id     IN     NUMBER,
  x_repair_line_id      OUT    NOCOPY NUMBER,
  x_repair_number       OUT    NOCOPY VARCHAR2,
  x_ro_status           OUT    NOCOPY VARCHAR2,
  x_return_status       OUT    NOCOPY VARCHAR2,
  x_msg_count           OUT    NOCOPY NUMBER,
  x_msg_data            OUT    NOCOPY VARCHAR2

 )
IS

-- Cursor to derive Bulk Receive record
Cursor c_create_blkrcv_ro(p_bulk_receive_id Number) IS
Select * from csd_bulk_receive_items_b
where bulk_receive_id = p_bulk_receive_id;

-- Cursor to derive item attributes
Cursor c_get_item_attributes(p_inventory_item_id number) IS
Select serial_number_control_code,
       comms_nl_trackable_flag,
       revision_qty_control_code
from mtl_system_items_kfv
where inventory_item_id = p_inventory_item_id
and organization_id = cs_std.get_item_valdn_orgzn_id;

-- Fix for bug#6082836
-- Added business_process_id
-- Cursor to derive repair type attribute
Cursor c_get_repair_type_attr(p_repair_type_id number) is
Select price_list_header_id,
       repair_mode,
       business_process_id
from csd_repair_types_b
where repair_type_id = p_repair_type_id;

-- Cursor to get IB details
Cursor c_get_ib_info ( p_inventory_item_id in Number,p_serial_number in Varchar2) is
Select
  owner_party_id,
  instance_id
from csi_item_instances
where serial_number = p_serial_number
and inventory_item_id = p_inventory_item_id;

-- Cursor to get Item Revision
Cursor c_get_item_revision ( p_inventory_item_id in Number,p_serial_number in Varchar2) is
Select
  revision
from mtl_serial_numbers
where serial_number = p_serial_number
and inventory_item_id = p_inventory_item_id;

-- Cursor to get Party site use id
Cursor c_get_party_site_use_id (p_incident_id number )is
Select ship_to_site_use_id
from  cs_incidents_all_b
where incident_id = p_incident_id;

-- Cursor to derive Primary UOM code
Cursor c_get_item_uom_code (p_inventory_item_id number) is
Select primary_uom_code
from mtl_system_items_kfv
where inventory_item_id = p_inventory_item_id
and organization_id = cs_std.get_item_valdn_orgzn_id;

-- Fix for bug#6082836
-- Cursor to get sr details
Cursor c_get_sr_details (p_incident_id in number) is
Select customer_id,account_id,incident_date,
       incident_severity_id,contract_id,contract_service_id
from csd_incidents_v
where incident_id = p_incident_id;

Cursor c_get_install_site_use_id(p_instance_id in number) is
Select location_id
from csi_item_instances
where instance_id = p_instance_id;

l_ent_contracts               OKS_ENTITLEMENTS_PUB.GET_CONTOP_TBL;
l_calc_resptime_flag          Varchar2(1)    := 'Y';
l_server_tz_id                Number;
l_customer_id                 Number;
l_account_id                  Number;
l_incident_date               Date;
l_severity_id                 Number;
l_sr_contract_id              Number;
l_sr_contract_service_id      Number;
l_contract_pl_id              Number;
l_profile_pl_id               Number;
l_install_site_use_id         Number;
l_currency_code               Varchar2(30);
l_business_process_id         Number;

-- Local variables
l_api_name          CONSTANT  Varchar2(30)   := 'CREATE_BLKRCV_RO';
l_api_version       CONSTANT  Number         := 1.0;
l_repair_type_pl              Number;
l_serial_number_control_code  Number;
l_owner_party_id              Number;
l_instance_id                 Number;
l_revision_qty_control_code   Number;
l_install_base_flag           Varchar2(1);
l_repln_rec                   csd_repairs_pub.repln_rec_type;
l_blkrcv_rec                  csd_bulk_receive_items_b%ROWTYPE;
c_non_serialized              CONSTANT Number := 1;
l_instance_rec                csd_mass_rcv_pvt.instance_rec_type;
l_revision                    Varchar2(30);
l_party_site_use_id           Number;
l_repair_mode                 Varchar2(30);
l_repair_type_id              Number;
l_uom_code                    Varchar2(3);
c_ib                          CONSTANT Varchar2(1) := 'Y';

-- BR ER FP changes, subhat
l_lot_num                     varchar2(30);

BEGIN

  savepoint create_blkrcv_ro;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_procedure,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_RO.BEGIN',
                      'Enter - Create Blkrcv RO');
  End if;

  Open c_create_blkrcv_ro (p_bulk_receive_id);
  Fetch c_create_blkrcv_ro into l_blkrcv_rec;
  Close c_create_blkrcv_ro;

  l_serial_number_control_code := null;
  l_install_base_flag          := null;
  l_revision_qty_control_code  := null;

  Open c_get_item_attributes (l_blkrcv_rec.inventory_item_id);
  Fetch c_get_item_attributes into l_serial_number_control_code,
                                   l_install_base_flag,
                                   l_revision_qty_control_code;
  Close c_get_item_attributes;


  -- If the item is Revision control
  -- derive the Revision from the entered serial number
  If ( l_revision_qty_control_code <> 1) then

    l_revision := null;

    -- BR ER FP changes, subhat.
    begin
		select item_revision,lot_number
		into l_revision,l_lot_num
		from csd_bulk_receive_items_b
		where bulk_receive_id = p_bulk_receive_id;

	exception
		when no_data_found then
			l_revision := null;
	end;
    if l_revision is null then
		Open c_get_item_revision(l_blkrcv_rec.inventory_item_id,
								   l_blkrcv_rec.serial_number);
		Fetch c_get_item_revision into l_revision;
		Close c_get_item_revision;

		If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
		  fnd_log.STRING (fnd_log.level_statement,
						  'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_RO',
					  'Derived Revision - '||l_revision||
					  'for Item id - '||l_blkrcv_rec.inventory_item_id);
		End if;
    end if;
  End if;


  -- Derive the IB Instance ID
  -- for  a IB item
  If (l_blkrcv_rec.instance_id is null and l_install_base_flag = c_ib
      and l_blkrcv_rec.serial_number is not null) then

    l_owner_party_id := null;
    l_instance_id    := null;

    Open c_get_ib_info(l_blkrcv_rec.inventory_item_id,
                       l_blkrcv_rec.serial_number);
    Fetch c_get_ib_info into l_owner_party_id,
                             l_instance_id;
    Close c_get_ib_info;

    If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_statement,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_RO',
  	              'Derived Instance Id - '||l_instance_id||
  	              'for Item id - '||l_blkrcv_rec.inventory_item_id||
  	              ',Serial number - '||l_blkrcv_rec.serial_number);
    End if;

  Else
    l_instance_id := l_blkrcv_rec.instance_id;
  End if;


  -- Derive the Primary UOM code if UOM is null
  If ( l_blkrcv_rec.uom_code is null ) then

    l_uom_code := null;

    Open c_get_item_uom_code (l_blkrcv_rec.inventory_item_id);
    Fetch c_get_item_uom_code into l_uom_code;
    Close c_get_item_uom_code;

    If (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_statement,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_RO',
  	              'Derived Uom code - '||l_uom_code||
  	              'for Item id - '||l_blkrcv_rec.inventory_item_id);
    End if;

  Else
    l_uom_code := l_blkrcv_rec.uom_code;
  End if;

  -- If instance id is null then call create IB
  -- for a IB item
  If ( l_instance_id is null and l_install_base_flag = c_ib) then

    l_party_site_use_id := null;

    Open c_get_party_site_use_id(l_blkrcv_rec.incident_id);
    Fetch c_get_party_site_use_id into l_party_site_use_id;
    Close c_get_party_site_use_id;

    l_instance_rec.inventory_item_id       := l_blkrcv_rec.inventory_item_id;
    l_instance_rec.instance_id             := null;
    l_instance_rec.instance_number         := null;
    l_instance_rec.serial_number           := l_blkrcv_rec.serial_number;
    l_instance_rec.lot_number              := null;
    l_instance_rec.quantity                := 1;
    l_instance_rec.uom                     := l_uom_code;
    l_instance_rec.party_site_use_id       := l_party_site_use_id;
    l_instance_rec.party_id                := l_blkrcv_rec.party_id;
    l_instance_rec.account_id              := l_blkrcv_rec.cust_account_id;
    l_instance_rec.mfg_serial_number_flag  := 'N';
    -- Bulk Rcv enhancement changes, subhat.
    l_instance_rec.external_reference      := l_blkrcv_rec.external_reference;
    l_instance_rec.item_revision           := l_revision;
    l_instance_rec.lot_number              := l_lot_num;
    -- end Bulk Rcv enhancement changes, subhat.

    If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
      fnd_log.STRING (fnd_log.level_event,
                      'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_RO',
  	              'Calling create item instance api');
    End if;


    csd_mass_rcv_pvt.create_item_instance (
      p_api_version        => 1.0,
      p_init_msg_list      => fnd_api.g_false,
      p_commit             => fnd_api.g_false,
      p_validation_level   => fnd_api.g_valid_level_full,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      px_instance_rec      => l_instance_rec,
      x_instance_id        => l_instance_id );

  If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
      RAISE FND_API.G_EXC_ERROR;
    End if;

  End if;

  -- swai: bug 7657379 use defaulting rules to get the repair type
  --l_repair_type_id := fnd_profile.value('CSD_BLK_RCV_DEFAULT_REPAIR_TYPE');
  l_repair_type_id := get_bulk_rcv_def_repair_type (
                           p_incident_id          => l_blkrcv_rec.incident_id,
                           p_ro_inventory_item_id => l_blkrcv_rec.inventory_item_id);

  l_repair_type_pl := null;
  l_repair_mode    := null;

  Open c_get_repair_type_attr(l_repair_type_id);
  Fetch c_get_repair_type_attr into l_repair_type_pl,l_repair_mode,l_business_process_id;
  Close c_get_repair_type_attr;

  -- Fix for bug#6082836
  -- Derive the Currency code
  --If ( l_repair_type_pl is null ) then
  --  l_repln_rec.currency_code := CSD_CHARGE_LINE_UTIL.GET_PLCURRCODE(fnd_profile.value('CSD_DEFAULT_PRICE_LIST'));
  --Else
  --  l_repln_rec.currency_code := CSD_CHARGE_LINE_UTIL.GET_PLCURRCODE(l_repair_type_pl);
  --End if;

  -- Fix for bug#6082836
  -- Default Contract, Price list and Currency

  Open c_get_sr_details(l_blkrcv_rec.incident_id);
  Fetch c_get_sr_details into l_customer_id,l_account_id,l_incident_date,
                              l_severity_id,l_sr_contract_id,l_sr_contract_service_id;
  Close c_get_sr_details;

  Open c_get_install_site_use_id(l_instance_id);
  Fetch c_get_install_site_use_id into l_install_site_use_id;
  Close c_get_install_site_use_id;

  fnd_profile.get('SERVER_TIMEZONE_ID', l_server_tz_id);

  CSD_REPAIRS_UTIL.GET_ENTITLEMENTS(
                  p_api_version_number  => 1.0,
                  p_init_msg_list       => fnd_api.g_false,
                  p_commit              => fnd_api.g_false,
                  p_contract_number     => null,
                  p_service_line_id     => null,
                  p_customer_id         => l_customer_id,
                  p_site_id             => l_install_site_use_id,
                  p_customer_account_id => l_account_id,
                  p_system_id           => null,
                  p_inventory_item_id   => l_blkrcv_rec.inventory_item_id,
                  p_customer_product_id => l_instance_id,
                  p_request_date        =>  trunc(l_incident_date),
                  p_validate_flag       => 'Y',
                  p_business_process_id => l_business_process_id,
                  p_severity_id         => l_severity_id,
                  p_time_zone_id        => l_server_tz_id,
                  P_CALC_RESPTIME_FLAG  => l_calc_resptime_flag,
                  x_ent_contracts       => l_ent_contracts,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data);

  If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  End if;

  If (l_ent_contracts.count = 0 ) then

    l_repln_rec.contract_line_id := null;

  Else

    For l_index in l_ent_contracts.FIRST..l_Ent_contracts.LAST Loop
      if (l_sr_contract_id = l_ent_contracts(l_index).contract_id  and
          l_sr_contract_service_id = l_ent_contracts(l_index).service_line_id) then

        l_repln_rec.contract_line_id := l_ent_contracts(l_index).service_line_id;
        exit;

      end if;
    End Loop;

    If (l_repln_rec.contract_line_id is null or
        l_repln_rec.contract_line_id = fnd_api.g_miss_num) then
      l_repln_rec.contract_line_id := l_ent_contracts(1).service_line_id;
    End if;

  End if;

  --
  -- Default PL and Currency
  --
  csd_process_util.get_ro_default_curr_pl
    (  p_api_version          => 1.0,
       p_init_msg_list        => fnd_api.g_false,
       p_incident_id          => l_blkrcv_rec.incident_id,
       p_repair_type_id       => l_repair_type_id,
       p_ro_contract_line_id  => l_repln_rec.contract_line_id,
       x_contract_pl_id       => l_contract_pl_id,
       x_profile_pl_id        => l_profile_pl_id,
       x_currency_code        => l_currency_code,
       x_return_status        => x_return_status,
       x_msg_count            => x_msg_count,
       x_msg_data             => x_msg_data );

  If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  End if;

  If ( l_contract_pl_id is not null) then
    l_repln_rec.price_list_header_id := l_contract_pl_id;
  Elsif ( l_profile_pl_id is not null ) then
    l_repln_rec.price_list_header_id := l_profile_pl_id;
  End if;

  l_repln_rec.currency_code := l_currency_code;

  -- Set the Repair Order Status
  If ((l_blkrcv_rec.serial_number is null) and (l_serial_number_control_code <> c_non_serialized)
      and (l_blkrcv_rec.quantity > 1)) then
    l_repln_rec.status  := 'D';
    x_ro_status         := 'DRAFT';
  Else
    l_repln_rec.status := 'O';
    x_ro_status        := 'OPEN';
  End if;

  --
  -- Inventory org id
  --
  -- swai: bug 7657379 - use defaulting rules to get the inventory org
  -- l_repln_rec.inventory_org_id := fnd_profile.value('CSD_DEF_REP_INV_ORG');
  l_repln_rec.inventory_org_id := fnd_api.g_miss_num;

  --
  -- Initialize / Assign the values to Repair Rec type
  --
  l_repln_rec.incident_id            := l_blkrcv_rec.incident_id;
  l_repln_rec.inventory_item_id      := l_blkrcv_rec.inventory_item_id;
  l_repln_rec.customer_product_id    := l_instance_id;
  l_repln_rec.unit_of_measure        := l_uom_code;
  l_repln_rec.serial_number          := l_blkrcv_rec.serial_number;
  l_repln_rec.quantity               := l_blkrcv_rec.quantity;
  l_repln_rec.auto_process_rma       := 'Y';
  l_repln_rec.approval_required_flag := 'Y';
  l_repln_rec.repair_type_id         := l_repair_type_id;  -- swai: bug 7657379
  -- l_repln_rec.repair_type_id         := fnd_profile.value('CSD_BLK_RCV_DEFAULT_REPAIR_TYPE');
  l_repln_rec.repair_group_id        := null;
  l_repln_rec.item_revision          := l_revision;
  l_repln_rec.repair_mode            := l_repair_mode;

  If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_event,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_RO',
	              'Calling create repair order api');
  End if;


  -- Call the Repairs private API
  CSD_REPAIRS_PVT.Create_Repair_Order
    (p_api_version_number => 1.0,
     p_commit             => fnd_api.g_false,
     p_init_msg_list      => fnd_api.g_true,
     p_validation_level   => fnd_api.g_valid_level_full,
     p_repair_line_id     => x_repair_line_id,
     p_Repln_Rec          => l_repln_rec,
     x_repair_line_id     => x_repair_line_id,
     x_repair_number      => x_repair_number,
     x_return_status      => x_return_status,
     x_msg_count          => x_msg_count,
     x_msg_data           => x_msg_data
  );

  If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  End If;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_RO.END',
                    'Exit - Create Blkrcv RO');
  End if;

EXCEPTION
  When FND_API.G_EXC_ERROR then
    Rollback To create_blkrcv_ro;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
      (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data  );

  When FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO create_blkrcv_ro;
    FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

  When OTHERS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    Rollback To create_blkrcv_ro;
    If  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)then
      FND_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME,
         l_api_name  );
     End If;
     FND_MSG_PUB.Count_And_Get
       (p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

END create_blkrcv_ro;


/*-----------------------------------------------------------------*/
/* procedure name: create_blkrcv_default_prod_txn                  */
/* description   : Procedure to create Default product txn         */
/*                 for a Repair Order                              */
/*                                                                 */
/*-----------------------------------------------------------------*/

PROCEDURE create_blkrcv_default_prod_txn
(
  p_bulk_receive_id     IN     NUMBER,
  x_return_status       OUT    NOCOPY VARCHAR2,
  x_msg_count           OUT    NOCOPY NUMBER,
  x_msg_data            OUT    NOCOPY VARCHAR2
 )
IS

-- Cursor to derive Bulk Receive record
Cursor c_create_blkrcv_prod_txn(p_bulk_receive_id Number) IS
select * from csd_bulk_receive_items_b
where bulk_receive_id = p_bulk_receive_id;

-- Local variables
l_api_name          CONSTANT VARCHAR2(30)   := 'CREATE_BLKRCV_DEFAULT_PROD_TXN';
l_api_version       CONSTANT NUMBER         := 1.0;
l_blkrcv_rec        csd_bulk_receive_items_b%ROWTYPE;

BEGIN

  savepoint create_blkrcv_default_prod_txn;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_DEFAULT_PROD_TXN.BEGIN',
                    'Enter - Create Blkrcv Default Prod Txn');
  End if;

  Open c_create_blkrcv_prod_txn(p_bulk_receive_id );
  Fetch c_create_blkrcv_prod_txn into l_blkrcv_rec;
  Close c_create_blkrcv_prod_txn;

  -- Call the Create default prod txn api
  csd_process_pvt.create_default_prod_txn
  (p_api_version      => 1.0,
   p_commit           => fnd_api.g_false,
   p_init_msg_list    => fnd_api.g_true,
   p_validation_level => fnd_api.g_valid_level_full,
   p_repair_line_id   => l_blkrcv_rec.repair_line_id,
   x_return_status    => x_return_status,
   x_msg_count        => x_msg_count,
   x_msg_data         => x_msg_data);

  If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  End If;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CREATE_BULKRCV_DEFAULT_PROD_TXN.END',
                    'Exit - Create Blkrcv Default Prod Txn');
  End if;

EXCEPTION
  When FND_API.G_EXC_ERROR then
    Rollback To create_blkrcv_default_prod_txn;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
      (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data  );

  When FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO create_blkrcv_default_prod_txn;
    FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

  When OTHERS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    Rollback To create_blkrcv_default_prod_txn;
    If  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)then
      FND_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME,
         l_api_name  );
     End If;
     FND_MSG_PUB.Count_And_Get
       (p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

END create_blkrcv_default_prod_txn;


/*-----------------------------------------------------------------*/
/* procedure name: change_blkrcv_ib_owner                          */
/* description   : Procedure to Change the Install Base Owner      */
/*                                                                 */
/*-----------------------------------------------------------------*/

PROCEDURE change_blkrcv_ib_owner
(
 p_bulk_receive_id       IN     NUMBER,
 x_return_status         OUT    NOCOPY VARCHAR2,
 x_msg_count             OUT    NOCOPY NUMBER,
 x_msg_data              OUT    NOCOPY VARCHAR2
)
IS

-- Local variables
l_instance_rec           csi_datastructures_pub.instance_rec;
l_ext_attrib_values_tbl  csi_datastructures_pub.extend_attrib_values_tbl;
l_party_tbl              csi_datastructures_pub.party_tbl;
l_account_tbl            csi_datastructures_pub.party_account_tbl;
l_pricing_attrib_tbl     csi_datastructures_pub.pricing_attribs_tbl;
l_org_assignments_tbl    csi_datastructures_pub.organization_units_tbl;
l_asset_assignment_tbl   csi_datastructures_pub.instance_asset_tbl;
l_txn_rec                csi_datastructures_pub.transaction_rec;
x_instance_id_lst        csi_datastructures_pub.id_tbl;
l_instance_party_id      Number;
l_object_version_number  Number;
l_api_name               CONSTANT Varchar(30)   := 'CHANGE_BLKRCV_IB_OWNER';
l_api_version            CONSTANT Number        := 1.0;
l_blkrcv_rec             csd_bulk_receive_items_b%ROWTYPE;
l_instance_account_id    Number;
l_inst_party_obj_ver_num Number;
l_inst_acct_obj_ver_num  Number;
l_instance_id            Number;

--bug#8508030
  l_bill_to_address          Number;
  l_ship_to_address          Number;
--bug#8508030


-- Cursor to select the Instance party id
Cursor c_instance_party(p_instance_id number) IS
Select instance_party_id,
       object_version_number
from csi_i_parties
where instance_id = p_instance_id
and relationship_type_code = 'OWNER';

-- Cursor to derive the Instance details
Cursor c_instance_details(p_instance_id number) IS
Select object_version_number from csi_item_instances
where instance_id = p_instance_id;

-- Cursor to derive the Bulk Receive rec
Cursor c_bulk_receive_items(p_bulk_receive_id Number) IS
select * from csd_bulk_receive_items_b
where bulk_receive_id = p_bulk_receive_id;

-- Cursor to derive the Instance Account Id
Cursor c_instance_account(p_instance_party_id number) is
Select ip_account_id,
       object_version_number
from csi_ip_accounts
where instance_party_id = p_instance_party_id;

-- Cursor to get IB details
Cursor c_get_ib_info ( p_inventory_item_id in Number,p_serial_number in Varchar2) is
Select instance_id
from csi_item_instances
where serial_number = p_serial_number
and inventory_item_id = p_inventory_item_id;

--bug#8508030
  Cursor get_bill_to_ship_to_address(p_instance_id number) IS
    SELECT bill_to_address,ship_to_address
    FROM CSI_IP_ACCOUNTS
    WHERE INSTANCE_PARTY_ID =
            (SELECT instance_party_id FROM CSI_I_PARTIES
            WHERE INSTANCE_ID=p_instance_id
            AND relationship_type_code='OWNER');
--bug#8508030


BEGIN

  savepoint change_blkrcv_ib_owner;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CHANGE_BULKRCV_IB_OWNER.BEGIN',
                    'Enter - Change Blkrcv IB Owner');
  End if;

  Open c_bulk_receive_items(p_bulk_receive_id);
  Fetch c_bulk_receive_items into l_blkrcv_rec;
  Close c_bulk_receive_items;

  -- Derive the IB Instance ID
  -- for  a IB item
  If (l_blkrcv_rec.instance_id is null
      and l_blkrcv_rec.serial_number is not null) then

    l_instance_id := null;

    Open c_get_ib_info(l_blkrcv_rec.inventory_item_id,
                       l_blkrcv_rec.serial_number);
    Fetch c_get_ib_info into l_instance_id;
    Close c_get_ib_info;
  Else
    l_instance_id := l_blkrcv_rec.instance_id;
  End if;

  l_instance_party_id      := null;
  l_inst_party_obj_ver_num := null;

  Open c_instance_party(l_instance_id);
  Fetch c_instance_party into l_instance_party_id,
                        l_inst_party_obj_ver_num;
  Close c_instance_party;

  l_instance_account_id   := null;
  l_inst_acct_obj_ver_num := null;

  Open c_instance_account(l_instance_party_id);
  Fetch c_instance_account into l_instance_account_id,
                          l_inst_acct_obj_ver_num;
  Close c_instance_account;

  l_object_version_number := null;

  Open c_instance_details(l_instance_id);
  Fetch c_instance_details into l_object_version_number;
  Close c_instance_details;


  -- Assign / Initialize values to the IB Rec type
  l_instance_rec.instance_id              := l_instance_id;
  l_instance_rec.object_version_number    := l_object_version_number;

  l_party_tbl(1).instance_party_id        := l_instance_party_id;
  l_party_tbl(1).instance_id              := l_instance_id;
  l_party_tbl(1).party_source_table       := 'HZ_PARTIES';
  l_party_tbl(1).party_id                 := l_blkrcv_rec.orig_party_id;
  l_party_tbl(1).relationship_type_code   := 'OWNER';
  l_party_tbl(1).contact_flag             := 'N';
  l_party_tbl(1).object_version_number    := l_inst_party_obj_ver_num;

  l_account_tbl(1).ip_account_id          := l_instance_account_id;
  l_account_tbl(1).parent_tbl_index       := 1;
  l_account_tbl(1).instance_party_id      := l_instance_party_id;
  l_account_tbl(1).party_account_id       := l_blkrcv_rec.orig_cust_account_id;
  l_account_tbl(1).relationship_type_code := 'OWNER';
  l_account_tbl(1).object_version_number  := l_inst_acct_obj_ver_num;

  --bug#8508030
  -- Get existing bill_to and ship_to address of the IB instancee
  Open get_bill_to_ship_to_address(l_instance_id);
  Fetch get_bill_to_ship_to_address into l_bill_to_address, l_ship_to_address;
  Close get_bill_to_ship_to_address;

  --pass the original bill_to and ship_to address back. If this not pass,
  --it will set the bill to and shipp to address to null value
  l_account_tbl(1).bill_to_address := l_bill_to_address;
  l_account_tbl(1).ship_to_address := l_ship_to_address;
  --bug#8508030


  l_txn_rec.transaction_date        := sysdate;
  l_txn_rec.source_transaction_date := sysdate;
  l_txn_rec.transaction_type_id     := 1;

  -- Call the Update item instance API
  csi_item_instance_pub.update_item_instance
  (
    p_api_version           =>  1.0,
    p_commit                =>  fnd_api.g_false,
    p_init_msg_list         =>  fnd_api.g_true,
    p_validation_level      =>  fnd_api.g_valid_level_full,
    p_instance_rec          =>  l_instance_rec,
    p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
    p_party_tbl             =>  l_party_tbl,
    p_account_tbl           =>  l_account_tbl,
    p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
    p_org_assignments_tbl   =>  l_org_assignments_tbl,
    p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
    p_txn_rec               =>  l_txn_rec,
    x_instance_id_lst       =>  x_instance_id_lst,
    x_return_status         =>  x_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data
  );

  If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  End If;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.CHANGE_BULKRCV_IB_OWNER.END',
                    'Exit - Change Blkrcv IB Owner');
  End if;

EXCEPTION
  When FND_API.G_EXC_ERROR then
    Rollback To change_blkrcv_ib_owner;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
      (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data  );

  When FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO change_blkrcv_ib_owner;
    FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

  When OTHERS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    Rollback To change_blkrcv_ib_owner;
    If  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)then
      FND_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME,
         l_api_name  );
     End If;
     FND_MSG_PUB.Count_And_Get
       (p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

END;


/*-----------------------------------------------------------------*/
/* procedure name: bulk_auto_receive                               */
/* description   : Procedure to Auto Receive                       */
/*                                                                 */
/*-----------------------------------------------------------------*/
 PROCEDURE bulk_auto_receive
 (
   p_bulk_autorcv_tbl IN OUT NOCOPY csd_bulk_receive_util.bulk_autorcv_tbl,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
 )

 IS

 -- Local variables
 l_msg_count          Number;
 l_rcv_rec_tbl        csd_receive_util.rcv_tbl_type;
 l_msg_data           Varchar2(2000);
 i                    Number;
 l_org_id             Number;
 l_api_name           CONSTANT Varchar(30)   := 'BULK_AUTO_RECEIVE';
 l_api_version        CONSTANT Number        := 1.0;
 l_header_error       Boolean;
 l_errored            Boolean;
 l_rcv_error_msg_tbl  csd_receive_util.rcv_error_msg_tbl;
 l_item_name          Varchar2(40);
 l_customer_id        Number;
 l_account_id         Number;
 l_estimate_quantity  Number;
 l_unit_of_measure    Varchar2(3);
 l_inventory_item_id  Number;
 l_order_header_id    Number;
 l_order_line_id      Number;
 l_order_number       Number;
 l_serial_number      Varchar2(40);
 l_return_status      Varchar2(3);
 l_prod_txn_status    Varchar2(30);

 -- 12.2 changes, subhat
 l_item_revision      varchar2(3);
 l_lot_number         varchar2(30);
 l_phase varchar2(30);
 l_status varchar2(30);
 l_dev_phase varchar2(30);
 l_dev_status varchar2(30);
 l_message varchar2(500);

 Cursor c_ro_prodtxn(p_repair_line_id  number,
                     p_order_header_id number,
                     p_order_line_id   number) is
 select
   cib.customer_id,
   cib.account_id, -- Fix for bug#5848406
   cpt.estimate_quantity,
   cpt.unit_of_measure,
   cpt.inventory_item_id,
   cpt.order_header_id,
   cpt.order_line_id,
   cpt.order_number,
   cpt.serial_number,
   mtl.concatenated_segments item_name,
   -- subhat, 12.2 changes
   cpt.revision,
   cpt.lot_number
   -- end 12.2 changes, subhat
 from
 csd_product_txns_v cpt,
 cs_incidents_all_b cib,
 csd_repairs cr,
 mtl_system_items_kfv mtl
 where cpt.repair_line_id = p_repair_line_id
 and cr.repair_line_id = cpt.repair_line_id
 and cib.incident_id = cr.incident_id
 and cpt.order_header_id  = p_order_header_id
 and cpt.order_line_id = p_order_line_id
 and mtl.inventory_item_id = cpt.inventory_item_id
 and mtl.organization_id = cs_std.get_item_valdn_orgzn_id;

 Cursor c_get_org (p_order_header_id number) is
 Select nvl(b.ship_from_org_id,a.ship_from_org_id)
 from   oe_order_headers_all a,
        oe_order_lines_all b
 where a.header_id = b.header_id
 and   a.header_id = p_order_header_id;

 Cursor c_get_prod_txn_status ( p_repair_line_id number ) is
 Select prod_txn_status
 from csd_product_transactions
 where repair_line_id = p_repair_line_id
 and action_type = 'RMA';

 BEGIN

   Savepoint bulk_auto_receive;

   If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
     fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.BULK_AUTO_RECEIVE.BEGIN',
                    'Enter - Bulk auto receive');
   End if;

   i := 0;

   For l_tbl_id in 1..p_bulk_autorcv_tbl.count
   Loop

     -- Assign values to the Auto Receive rec table

     For c_ro_prdtxn_rec in c_ro_prodtxn( p_bulk_autorcv_tbl(l_tbl_id).repair_line_id,
                                          p_bulk_autorcv_tbl(l_tbl_id).order_header_id,
                                          p_bulk_autorcv_tbl(l_tbl_id).order_line_id)
     Loop

       -- Derive the Org id
       l_org_id := null;

       Open c_get_org (c_ro_prdtxn_rec.order_header_id);
       Fetch c_get_org into l_org_id;
       Close c_get_org;

       i := i + 1;
       -- l_rcv_rec_tbl(i).customer_id            := c_ro_prdtxn_rec.customer_id;
       -- Fix for bug#5848406
       l_rcv_rec_tbl(i).customer_id            := c_ro_prdtxn_rec.account_id;
       l_rcv_rec_tbl(i).customer_site_id       := null;
       l_rcv_rec_tbl(i).employee_id            := null;
       --l_rcv_rec_tbl(i).quantity               := abs(c_ro_prdtxn_rec.estimate_quantity);
       -- 12.2 bulk receiving enhancements. subhat
	   IF NVL(p_bulk_autorcv_tbl(l_tbl_id).under_receipt_flag,'N') = 'Y' THEN
	   		l_rcv_rec_tbl(i).quantity            := p_bulk_autorcv_tbl(l_tbl_id).receipt_qty;
	   ELSE
	        l_rcv_rec_tbl(i).quantity            := abs(c_ro_prdtxn_rec.estimate_quantity);
       END IF;
       l_rcv_rec_tbl(i).uom_code               := c_ro_prdtxn_rec.unit_of_measure;
       l_rcv_rec_tbl(i).inventory_item_id      := c_ro_prdtxn_rec.inventory_item_id;
       -- subhat, 12.2. When the revision is captured, it should be passed on.
       --l_rcv_rec_tbl(i).item_revision          := null;
       l_rcv_rec_tbl(i).item_revision          := p_bulk_autorcv_tbl(l_tbl_id).item_revision;
       l_rcv_rec_tbl(i).to_organization_id     := l_org_id;
       l_rcv_rec_tbl(i).destination_type_code  := null;
       -- swai: bug 7663674
       --l_rcv_rec_tbl(i).subinventory           := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SUB_INV');
       l_rcv_rec_tbl(i).subinventory           := get_bulk_rcv_def_sub_inv( p_bulk_autorcv_tbl(l_tbl_id).repair_line_id);
       --l_rcv_rec_tbl(i).locator_id             := null;
       l_rcv_rec_tbl(i).deliver_to_location_id := null;
       l_rcv_rec_tbl(i).requisition_number     := null;
       l_rcv_rec_tbl(i).order_header_id        := c_ro_prdtxn_rec.order_header_id;
       l_rcv_rec_tbl(i).order_line_id          := c_ro_prdtxn_rec.order_line_id;
       l_rcv_rec_tbl(i).order_number           := c_ro_prdtxn_rec.order_number;
       l_rcv_rec_tbl(i).doc_number             := c_ro_prdtxn_rec.order_number;
       l_rcv_rec_tbl(i).internal_order_flag    := 'N';
       l_rcv_rec_tbl(i).from_organization_id   := null;
       l_rcv_rec_tbl(i).expected_receipt_date  := sysdate;
       l_rcv_rec_tbl(i).transaction_date       := sysdate;
       l_rcv_rec_tbl(i).ship_to_location_id    := null;
       if c_ro_prdtxn_rec.serial_number is null and p_bulk_autorcv_tbl(l_tbl_id).serial_number is not null then
       		l_rcv_rec_tbl(i).serial_number     := p_bulk_autorcv_tbl(l_tbl_id).serial_number ;
       else
       		l_rcv_rec_tbl(i).serial_number     := c_ro_prdtxn_rec.serial_number;
       end if;
       -- 12.2 subhat. pass the lot number information also.
       l_rcv_rec_tbl(i).lot_number             := p_bulk_autorcv_tbl(l_tbl_id).lot_number;
       l_rcv_rec_tbl(i).locator_id             := p_bulk_autorcv_tbl(l_tbl_id).locator_id;

     End Loop;

   End Loop;

   -- Call the Receive API
   If (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
     fnd_log.STRING (fnd_log.level_event,
                     'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.BULK_AUTO_RECEIVE.BEGIN',
                     'Call receive item api');
   End if;

   If(l_rcv_rec_tbl.count > 0 ) then
     -- we will mark a global variable to say that this is called from bulk rcv.
     csd_bulk_receive_pvt.g_bulk_rcv_conc := 'Y';

     csd_receive_pvt.receive_item ( p_api_version       => 1.0,
                                    p_init_msg_list     => csd_process_util.g_false,
                                    p_commit            => csd_process_util.g_false,
                                    p_validation_level  => csd_process_util.g_valid_level_full,
                                    x_return_status     => x_return_status,
                                    x_msg_count         => l_msg_count,
                                    x_msg_data          => l_msg_data,
                                    x_rcv_error_msg_tbl => l_rcv_error_msg_tbl,
                                    p_receive_tbl       => l_rcv_rec_tbl);

    -- reset it here.
    csd_bulk_receive_pvt.g_bulk_rcv_conc := 'N';

	-- if the request is submitted successfully, no need to do anything here.
	if csd_bulk_receive_pvt.g_conc_req_id is not null then
    	return;
    end if;

     If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then  -- Status check If statement

     -- Verify if there are any errors in header

       csd_bulk_receive_util.write_to_conc_log
        ( p_msg_count  => l_msg_count,
          p_msg_data   => l_msg_data);


       If ( l_rcv_error_msg_tbl.count > 0 ) then

         l_header_error := FALSE;

         For i in 1..l_rcv_error_msg_tbl.count
         Loop
           If ( l_rcv_error_msg_tbl(i).header_interface_id  is not null and
                l_rcv_error_msg_tbl(i).interface_transaction_id  is null ) then

             l_header_error := TRUE;

             -- Display the message
             Fnd_file.put_line(fnd_file.log,'Error:Auto Receive failed - Header');
             Fnd_file.put(fnd_file.log,'Column name:');
             Fnd_file.put_line(fnd_file.log,l_rcv_error_msg_tbl(i).column_name);
             Fnd_file.put(fnd_file.log,'Error Message:');
             Fnd_file.put_line(fnd_file.log,l_rcv_error_msg_tbl(i).error_message);

           End if;
         End Loop;

         -- If there is header error the update all the Auto Receive lines
         -- in Bulk Rcv table to Errored
         If (l_header_error) then

           -- Update all the auto receive records to error
           For i in 1..p_bulk_autorcv_tbl.count
           Loop

             Update csd_bulk_receive_items_b
             set status = 'ERRORED'
             where bulk_receive_id = p_bulk_autorcv_tbl(i).bulk_receive_id;

           End loop;

         Else

           -- If there are no header errors then check for
           -- line errors and update the records
           For i in 1..p_bulk_autorcv_tbl.count
           Loop

             l_errored := FALSE;

             For j in 1..l_rcv_error_msg_tbl.count
             Loop

               If ( p_bulk_autorcv_tbl(i).order_header_id = l_rcv_error_msg_tbl(j).order_header_id and
                    p_bulk_autorcv_tbl(i).order_line_id   = l_rcv_error_msg_tbl(j).order_line_id ) then

                 l_errored := TRUE;

                -- Display the error message

                 l_customer_id       := null;
                 l_estimate_quantity := null;
                 l_unit_of_measure   := null;
                 l_inventory_item_id := null;
                 l_order_header_id   := null;
                 l_order_line_id     := null;
                 l_order_number      := null;
                 l_serial_number     := null;
                 l_item_name         := null;

                 Open c_ro_prodtxn(p_bulk_autorcv_tbl(i).repair_line_id,
                                   p_bulk_autorcv_tbl(i).order_header_id,
                                   p_bulk_autorcv_tbl(i).order_line_id);

                 -- 12.2 changes, subhat, added lot number and item revision
                 Fetch c_ro_prodtxn into l_customer_id,l_account_id,l_estimate_quantity,
                                    l_unit_of_measure,l_inventory_item_id,l_order_header_id,
                                    l_order_line_id,l_order_number,l_serial_number,l_item_name,l_item_revision,l_lot_number;
                 Close c_ro_prodtxn;

                 Fnd_file.put_line(fnd_file.log,'Error:Auto Receive failed - Line');
                 Fnd_file.put(fnd_file.log,'Serial Number :'||l_serial_number||',');
                 Fnd_file.put(fnd_file.log,'Inventory Item :'||l_item_name||',');
                 Fnd_file.put_line(fnd_file.log,'Qty :'||l_estimate_quantity);
                 Fnd_file.put(fnd_file.log,'Column name:');
                 Fnd_file.put_line(fnd_file.log,l_rcv_error_msg_tbl(i).column_name);
                 Fnd_file.put(fnd_file.log,'Error Message:');
                 Fnd_file.put_line(fnd_file.log,l_rcv_error_msg_tbl(i).error_message);

               End If;

             End Loop;

             If (l_errored) then

               Update csd_bulk_receive_items_b
               set status = 'ERRORED'
               where bulk_receive_id = p_bulk_autorcv_tbl(i).bulk_receive_id;

             Else

               -- fix for bug 5227347
               -- Update csd_bulk_receive_items_b
      	       -- set status = 'PROCESSED'
               -- where bulk_receive_id = p_bulk_autorcv_tbl(i).bulk_receive_id;
               -- 12.2 changes, subhat
			   if nvl(p_bulk_autorcv_tbl(i).under_receipt_flag,'N') = 'Y' then
                  after_under_receipt_prcs(p_repair_line_id => p_bulk_autorcv_tbl(i).repair_line_id,
                                          p_order_header_id => p_bulk_autorcv_tbl(i).order_header_id,
                                          p_order_line_id => p_bulk_autorcv_tbl(i).order_line_id,
                                          p_received_qty  => p_bulk_autorcv_tbl(i).receipt_qty);
               end if;
               -- end changes, subhat
               -- Call Update receipts program
               CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE
                 ( p_api_version          => 1.0,
                   p_commit               => fnd_api.g_false,
                   p_init_msg_list        => fnd_api.g_true,
                   p_validation_level     => 0,
                   x_return_status        => l_return_status,
                   x_msg_count            => l_msg_count,
                   x_msg_data             => l_msg_data,
                   p_internal_order_flag  => 'N',
                   p_order_header_id      => null,
                   p_repair_line_id       => p_bulk_autorcv_tbl(i).repair_line_id);

               -- fix for bug 5227347
               If NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) then

                 Fnd_file.put_line(fnd_file.log,'Error : CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE failed');
                 csd_bulk_receive_util.write_to_conc_log
                   ( p_msg_count  => l_msg_count,
                     p_msg_data   => l_msg_data);

               Else

                 -- Get Product Txn Status
                 Open c_get_prod_txn_status ( p_bulk_autorcv_tbl(i).repair_line_id );
                 Fetch c_get_prod_txn_status into l_prod_txn_status;
                 Close c_get_prod_txn_status;

                 If ( l_prod_txn_status = 'RECEIVED' ) then

                   Update csd_bulk_receive_items_b
      	           set status = 'PROCESSED'
                   where bulk_receive_id = p_bulk_autorcv_tbl(i).bulk_receive_id;

                 End if;

               End if;

             End if;
           End Loop;

         End if; -- End if of l_header_error

       Else
         -- Unexpected/Internal Error
         For i in 1..p_bulk_autorcv_tbl.count
           Loop

             Update csd_bulk_receive_items_b
             set status = 'ERRORED'
             where bulk_receive_id = p_bulk_autorcv_tbl(i).bulk_receive_id;

          End loop;

       End if;  -- End if of the l_rcv_error_msg_tbl.count > 0

     Else

       -- Update all the auto receive records to processed
       For i in 1..p_bulk_autorcv_tbl.count
       Loop

         -- fix for bug 5227347
         -- Update csd_bulk_receive_items_b
         -- set status = 'PROCESSED'
         -- where bulk_receive_id = p_bulk_autorcv_tbl(i).bulk_receive_id;

		 -- 12.2 changes,subhat.
		 -- process under receipts.
		    if nvl(p_bulk_autorcv_tbl(i).under_receipt_flag,'N') = 'Y' then
		          after_under_receipt_prcs(p_repair_line_id => p_bulk_autorcv_tbl(i).repair_line_id,
		                                   p_order_header_id => p_bulk_autorcv_tbl(i).order_header_id,
		                                   p_order_line_id => p_bulk_autorcv_tbl(i).order_line_id,
		                                   p_received_qty  => p_bulk_autorcv_tbl(i).receipt_qty);
            end if;
         -- 12.2 changes,subhat

         -- Call Update receipts program
         CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE
          ( p_api_version          => 1.0,
            p_commit               => fnd_api.g_false,
            p_init_msg_list        => fnd_api.g_true,
            p_validation_level     => 0,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_internal_order_flag  => 'N',
            p_order_header_id      => null,
            p_repair_line_id       => p_bulk_autorcv_tbl(i).repair_line_id);

         -- fix for bug 5227347
         If NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) then

           Fnd_file.put_line(fnd_file.log,'Error : CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE failed');
           csd_bulk_receive_util.write_to_conc_log
             ( p_msg_count  => l_msg_count,
               p_msg_data   => l_msg_data);

         Else

           -- Get Product Txn Status
           Open c_get_prod_txn_status ( p_bulk_autorcv_tbl(i).repair_line_id );
           Fetch c_get_prod_txn_status into l_prod_txn_status;
           Close c_get_prod_txn_status;

           If ( l_prod_txn_status = 'RECEIVED' ) then

             Update csd_bulk_receive_items_b
      	     set status = 'PROCESSED'
             where bulk_receive_id = p_bulk_autorcv_tbl(i).bulk_receive_id;

           End if;

         End if;

       End loop;

     End if; -- End if of the Status check

   End if; -- End if of the l_rcv_rec_tbl.count > 0

   If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
     fnd_log.STRING (fnd_log.level_procedure,
                   'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.BULK_AUTO_RECEIVE.END',
                   'Exit - Bulk auto receive');
   End if;

EXCEPTION
  When FND_API.G_EXC_ERROR then
    Rollback To bulk_auto_receive;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
      (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data  );

  When FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO bulk_auto_receive;
    FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

  When OTHERS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    Rollback To bulk_auto_receive;
    If  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)then
      FND_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME,
         l_api_name  );
     End If;
     FND_MSG_PUB.Count_And_Get
       (p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

 END;


/*-----------------------------------------------------------------*/
/* procedure name: write_to_conc_log                               */
/* description   : Procedure to write into Concurrent log          */
/*                 It reads the message from the stack and writes  */
/*                 to Concurrent log.                              */
/*-----------------------------------------------------------------*/
PROCEDURE write_to_conc_log
 (
  p_msg_count  IN NUMBER,
  p_msg_data   IN VARCHAR2
 )
IS

l_msg   Varchar2(2000);

BEGIN

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                   'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.WRITE_TO_CONC_LOG.BEGIN',
                   'Enter - Write to conc log');
  End if;

  If p_msg_count is not null then

    If p_msg_count = 1 then

      l_msg :=  fnd_msg_pub.get(p_msg_index => 1,
                                p_encoded => 'F' );
      Fnd_file.put_line(fnd_file.log,l_msg);

    Elsif p_msg_count > 1 then

      For i in 1..p_msg_count

      Loop
        l_msg := fnd_msg_pub.get(p_msg_index => i,
                                 p_encoded => 'F' );
        Fnd_file.put_line(fnd_file.log,l_msg);
      End loop;

    End If;

  End If;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                   'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.WRITE_TO_CONC_LOG.END',
                   'Exit - Write to conc log');
  End if;

END;

/*-----------------------------------------------------------------*/
/* procedure name: write_to_conc_output                            */
/* description   : Procedure to write the output to the Concurrent */
/*                 Output                                          */
/*-----------------------------------------------------------------*/
 PROCEDURE write_to_conc_output
 (
  p_transaction_number  IN NUMBER
 )
 IS

 -- Local variables
 l_item_desc        Varchar2(40);
 l_repair_number    Varchar2(30);
 l_ro_status        Varchar2(30);
 l_incident_number  Varchar2(64);
 l_status           Varchar2(60);
 l_serial_label     Varchar2(30);
 l_txn_label        Varchar2(30);
 l_item_label       Varchar2(30);
 l_qty_label        Varchar2(30);
 l_sr_label         Varchar2(30);
 l_ro_label         Varchar2(30);
 l_status_label     Varchar2(30);

 -- Cursor to get the Bulk Receive record
 Cursor c_get_bulk_receive(p_transaction_number in number) is
 Select *
 from csd_bulk_receive_items_b
 where transaction_number = p_transaction_number;

 -- Cursor to get Incident number
 Cursor c_get_sr_details(p_incident_id in number) is
 Select incident_number
 from cs_incidents_all_b
 where incident_id = p_incident_id;

 -- Cursor to get Repair Order number
 Cursor c_get_ro_details(p_repair_line_id in number) is
 Select repair_number
        ,status
 from csd_repairs
 where repair_line_id = p_repair_line_id;

 -- Cursor to get Item description
  Cursor c_get_item_desc(p_inventory_item_id in number) is
  Select concatenated_segments
  from mtl_system_items_kfv
  where inventory_item_id = p_inventory_item_id;


 BEGIN

   If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
     fnd_log.STRING (fnd_log.level_procedure,
                   'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.WRITE_TO_CONC_OUTPUT.BEGIN',
                   'Enter - Write to conc output');
   End if;

   fnd_message.set_name('CSD','CSD_BULK_RCV_SERIAL_CONC_LABEL');
   l_serial_label := fnd_message.get;

   fnd_message.set_name('CSD','CSD_BULK_RCV_TXN_CONC_LABEL');
   l_txn_label    := fnd_message.get;

   fnd_message.set_name('CSD','CSD_BULK_RCV_ITEM_CONC_LABEL');
   l_item_label   := fnd_message.get;

   fnd_message.set_name('CSD','CSD_BULK_RCV_QTY_CONC_LABEL');
   l_qty_label    := fnd_message.get;

   fnd_message.set_name('CSD','CSD_BULK_RCV_SR_CONC_LABEL');
   l_sr_label     := fnd_message.get;

   fnd_message.set_name('CSD','CSD_BULK_RCV_RO_CONC_LABEL');
   l_ro_label     := fnd_message.get;

   fnd_message.set_name('CSD','CSD_BULK_RCV_STATUS_CONC_LABEL');
   l_status_label := fnd_message.get;

   Fnd_file.put_line(fnd_file.output,rtrim(l_txn_label)||' : '||p_transaction_number);
   Fnd_file.put_line(fnd_file.output,'');
   Fnd_file.put(fnd_file.output,rpad(rtrim(l_serial_label),18,' '));
   Fnd_file.put(fnd_file.output,rpad(rtrim(l_item_label),14,' '));
   Fnd_file.put(fnd_file.output,rpad(rtrim(l_qty_label),13,' '));
   Fnd_file.put(fnd_file.output,rpad(rtrim(l_sr_label),25,' '));
   Fnd_file.put(fnd_file.output,rpad(rtrim(l_ro_label),25,' '));
   -- 12.1.2 changes, subhat.
   fnd_file.put(fnd_file.output,rpad('Unplanned Receipt',22,' ') );
   fnd_file.put(fnd_file.output,rpad('Over Receipt', 15, ' '));
   fnd_file.put(fnd_file.output,rpad('Under Receipt', 15, ' '));
   -- end 12.1.2 changes subhat
   Fnd_file.put_line(fnd_file.output,rpad(rtrim(l_status_label),28,' '));
   --Fnd_file.put_line(fnd_file.output,rpad('-',110,'-'));
   Fnd_file.put_line(fnd_file.output,rpad('-',170,'-'));


   For c_get_bulk_receive_rec in c_get_bulk_receive( p_transaction_number)
   Loop

     -- Reinitialize the variable
     l_incident_number := null;
     l_repair_number   := null;
     l_ro_status       := null;
     l_item_desc       := null;

     Open c_get_sr_details(c_get_bulk_receive_rec.incident_id);
     Fetch c_get_sr_details into l_incident_number;
     Close c_get_sr_details;

     Open c_get_ro_details(c_get_bulk_receive_rec.repair_line_id);
     Fetch c_get_ro_details into l_repair_number,l_ro_status;
     Close c_get_ro_details;

     Open c_get_item_desc(c_get_bulk_receive_rec.inventory_item_id);
     Fetch c_get_item_desc into l_item_desc;
     Close c_get_item_desc;


     Fnd_file.put(fnd_file.output,rpad(nvl(c_get_bulk_receive_rec.serial_number,' '),18));
     Fnd_file.put(fnd_file.output,rpad(nvl(l_item_desc,' '),14,' '));
     Fnd_file.put(fnd_file.output,rpad(nvl(to_char(c_get_bulk_receive_rec.quantity),' '),13,' '));
     Fnd_file.put(fnd_file.output,rpad(nvl(l_incident_number,' '),25,' '));
     Fnd_file.put(fnd_file.output,rpad(nvl(l_repair_number,' '),25,' '));

     --12.1.2 changes, subhat.
	 if nvl(c_get_bulk_receive_rec.unplanned_receipt_flag,'N') = 'Y' then
     	Fnd_file.put(fnd_file.output,rpad('Yes',22,' '));
     else
     	Fnd_file.put(fnd_file.output,rpad('No',22,' '));
     end if;

     if nvl(c_get_bulk_receive_rec.over_receipt_flag,'N') = 'Y' then
     	Fnd_file.put(fnd_file.output,rpad('Yes',15,' '));
     else
     	Fnd_file.put(fnd_file.output,rpad('No',15,' '));
     end if;

     if nvl(c_get_bulk_receive_rec.under_receipt_flag,'N') = 'Y' then
     	Fnd_file.put(fnd_file.output,rpad('Yes',15,' '));
     else
     	Fnd_file.put(fnd_file.output,rpad('No',15,' '));
     end if;
     If ( c_get_bulk_receive_rec.status = 'ERRORED' ) then

       fnd_message.set_name('CSD','CSD_BULK_RCV_ERROR_STATUS');
       l_status     := fnd_message.get;

     Elsif ( c_get_bulk_receive_rec.status = 'PROCESSED' ) then

       If ( c_get_bulk_receive_rec.internal_sr_flag = 'Y') then
         fnd_message.set_name('CSD','CSD_BULK_RCV_INTR_SR_STATUS');
         l_status     := fnd_message.get;
       Elsif (l_ro_status = 'D' ) then
         fnd_message.set_name('CSD','CSD_BULK_RCV_DRAFT_RO_STATUS');
         l_status     := fnd_message.get;
       Else
         fnd_message.set_name('CSD','CSD_BULK_RCV_RECEIVED_STATUS');
         l_status     := fnd_message.get;
       End if;

     Elsif ( c_get_bulk_receive_rec.status = 'NEW' ) then

       fnd_message.set_name('CSD','CSD_BULK_RCV_NEW_STATUS');
       l_status     := fnd_message.get;

     End if;

     Fnd_file.put_line(fnd_file.output,rpad(rtrim(l_status),28,' '));

   End Loop;

   If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
     fnd_log.STRING (fnd_log.level_procedure,
                   'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.WRITE_TO_CONC_OUTPUT.END',
                   'Exit - Write to conc output');
   End if;

 END;

 FUNCTION get_bulk_rcv_def_repair_type
 (
   p_incident_id              IN     NUMBER,
   p_ro_inventory_item_id     IN     NUMBER
 )
 return NUMBER
 IS
  CURSOR c_get_sr_info(p_incident_id number) is
    select customer_id,
           account_id,
           bill_to_site_use_id,
           ship_to_site_use_id,
           inventory_item_id,
           category_id,
           contract_id,
           problem_code,
           customer_product_id
    from CS_INCIDENTS_ALL_VL
    where incident_id = p_incident_id;

  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_rule_input_rec   CSD_RULES_ENGINE_PVT.CSD_RULE_INPUT_REC_TYPE;
  l_default_val_num  NUMBER;
  l_default_rule_id  NUMBER;
  l_repair_org       NUMBER;                -- repair org id
  l_repair_type_id   NUMBER := null;        -- repair type id

 BEGIN
    -- Assume SR Incident Id is available to get info for defaulting RO attributes
    open c_get_sr_info(p_incident_id);
        fetch c_get_sr_info into
            l_rule_input_rec.SR_CUSTOMER_ID,
            l_rule_input_rec.SR_CUSTOMER_ACCOUNT_ID,
            l_rule_input_rec.SR_BILL_TO_SITE_USE_ID,
            l_rule_input_rec.SR_SHIP_TO_SITE_USE_ID,
            l_rule_input_rec.SR_ITEM_ID,
            l_rule_input_rec.SR_ITEM_CATEGORY_ID,
            l_rule_input_rec.SR_CONTRACT_ID,
            l_rule_input_rec.SR_PROBLEM_CODE,
            l_rule_input_rec.SR_INSTANCE_ID;
    close c_get_sr_info;

    l_rule_input_rec.RO_ITEM_ID                 :=  p_ro_inventory_item_id;

    l_default_val_num := null;
    CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE(
        p_api_version_number    => 1.0,
        p_init_msg_list         => fnd_api.g_false,
        p_commit                => fnd_api.g_false,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_entity_attribute_type => 'CSD_DEF_ENTITY_ATTR_RO',
        p_entity_attribute_code => 'REPAIR_TYPE',
        p_rule_input_rec        => l_rule_input_rec,
        x_default_value         => l_default_val_num,
        x_rule_id               => l_default_rule_id,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data
    );

    -- if default rule id is null, then no defaulting rule was found, and the
    -- profile for regular repair types was returned.  We want the bulk receive
    -- profile option, so need to check default rule id.
    if (l_return_status = fnd_api.g_ret_sts_success) and
        (l_default_val_num is not null) and
        (l_default_rule_id is not null)
    then
        l_repair_type_id := l_default_val_num;
    else
        l_repair_type_id := to_number(fnd_profile.value('CSD_BLK_RCV_DEFAULT_REPAIR_TYPE'));
    end if;

    return l_repair_type_id;

 END get_bulk_rcv_def_repair_type;

 -- swai: bug 7663674
 -- added function to get default rma subinv and use bulk receiving
 -- profile option value as backup default value.
 /*-----------------------------------------------------------------*/
 /* function name:  get_bulk_rcv_def_sub_inv                        */
 /* description   : Function to get the default rma subinv for      */
 /*                 bulk receiving, based on defaulting rules and   */
 /*                 bulk receiving profile option.                  */
 /*                 Output    RMA Subinventory Code                 */
/*-----------------------------------------------------------------*/
 FUNCTION get_bulk_rcv_def_sub_inv
 (
   p_repair_line_id              IN     NUMBER
 )
 return VARCHAR2
 IS
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_rule_input_rec   CSD_RULES_ENGINE_PVT.CSD_RULE_INPUT_REC_TYPE;
  l_default_val_str  VARCHAR2(30);
  l_default_rule_id  NUMBER := null;
  l_rma_subinv   VARCHAR2(30) := null;        -- repair type id

 BEGIN
    l_rule_input_rec.repair_line_id := p_repair_line_id;
    l_default_val_str := null;
    CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE(
        p_api_version_number    => 1.0,
        p_init_msg_list         => fnd_api.g_false,
        p_commit                => fnd_api.g_false,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_entity_attribute_type => 'CSD_DEF_ENTITY_ATTR_RO',
        p_entity_attribute_code => 'RMA_RCV_SUBINV',
        p_rule_input_rec        => l_rule_input_rec,
        x_default_value         => l_default_val_str,
        x_rule_id               => l_default_rule_id,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data
    );

    -- if default rule id is null, then no defaulting rule was found, and the
    -- profile for regular rma subinv was returned.  We want the bulk receive
    -- profile option, so need to check default rule id.
    if (l_return_status = fnd_api.g_ret_sts_success) and
        (l_default_val_str is not null) and
        (l_default_rule_id is not null)
    then
        l_rma_subinv := l_default_val_str;
    else
        l_rma_subinv := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SUB_INV');
    end if;

    return l_rma_subinv;

 END get_bulk_rcv_def_sub_inv;

-- subhat, new procedures.
/*-----------------------------------------------------------------*/
/* procedure name: get_sr_ro_rma_details                            */
/* description   : Procedure to get the existing SR,RO,RMA          */
/*                 combination                                      */
/* Called from link_sr_ro_rma_oa_wrapper.                           */
/*-----------------------------------------------------------------*/

 PROCEDURE get_sr_ro_rma_details
  (
    p_transaction_number IN NUMBER,
    x_sr_ro_rma_tbl      IN OUT NOCOPY sr_ro_rma_tbl
  ) IS

  l_inventory_item_id NUMBER;
  l_instance_id      NUMBER;
  l_counter          NUMBER := 0;
  l_check_ro         VARCHAR2(3);

  l_no_exact_match  varchar2(3) := 'N';


  lc_sql_string_ro varchar2(2000) :=' select sr.incident_id,cr.repair_line_id,cr.quantity,''N'',''N''' ||
                     ' from cs_incidents_all_b sr,csd_repairs cr,csd_repair_types_b crt '||
                     ' where cr.inventory_item_id = :p_inv_item_id '||
                     ' and cr.status = ''O'' '||
                     ' and cr.incident_id = sr.incident_id '||
                     ' and sr.account_id = :p_acc_id '||
                     ' and sr.customer_id = :p_party_id '||
                     ' AND cr.repair_type_id = crt.repair_type_id '||
                     ' and not exists ( '||
                     ' select repair_line_id '||
                     ' from csd_product_transactions cpt '||
                     ' where crt.repair_type_ref <> ''ARR'' '||
                     ' and cpt.repair_line_id = cr.repair_line_id '||
                     ' and cpt.action_type = ''RMA'' '||
                     ' and cpt.prod_txn_status in (''CANCELLED'' ,''RECEIVED'') '||
                     ' UNION ALL '||
                     ' SELECT repair_line_id '||
                     ' from csd_product_transactions cpt1' ||
                     ' where crt.repair_type_ref = ''ARR''' ||
                     ' AND cpt1.repair_line_id = cr.repair_line_id '||
                     ' AND cpt1.action_type = ''RMA'' '||
                     ' AND ((cpt1.action_code = ''LOANER'' AND cpt1.prod_txn_status IN (''CANCELLED'',''RECEIVED''))AND ' ||
                     ' (cpt1.action_code = ''CUST_PROD'' AND cpt1.prod_txn_status IN (''CANCELLED'',''RECEIVED'')) )) ';

  l_ro_query_sql varchar2(2000) := ' select repair_line_id from csd_repairs where '||
                                   ' incident_id := :b_incident_id and '||
                                   ' status := ''O'' ' ;
  l_sql_string_tmp    varchar2(2000);
  l_repair_line_ids_in varchar2(2000);

  lc_api_name varchar2(200) := 'csd.plsql.csd_bulk_receive_util.get_sr_ro_rma_details';

  l_in_progress_ro   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

  l_check_loaner_sn varchar2(3) := 'N';
  l_check_loaner_non_sn varchar2(3) := 'N';

 begin
  -- program logic
  -- A.find out the records available for processing.
  -- find out the item attributes for the records.
  -- depending on the type of item fire search for SR, RO and RMA's.
  -- populate the rec with relevant details and send back the control to the caller.

  -- Need to exclude those repair line_id's which are already picked up for processing,
  -- and concurrent manager is processing them.
  begin
  	select repair_line_id
  	bulk collect into l_in_progress_ro
	from csd_bulk_receive_items_b
	where transaction_number in
	  (
	    select argument1
	    from fnd_concurrent_requests fcr,
	         fnd_concurrent_programs fcp
	    where fcp.concurrent_program_name = 'CSDBLKRCV'
	    and   fcp.application_id = 512
	    and   fcr.program_application_id = fcp.application_id
	    and   fcp.concurrent_program_id = fcr.concurrent_program_id
	    and   fcr.status_code <> 'C'
  	  );
   exception
   	 when no_data_found then
   	 	null;
   end;
  -- get the records for the processing.

  for i in 1 ..x_sr_ro_rma_tbl.COUNT
  loop

  l_counter := l_counter + 1;
  	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
  		fnd_log.STRING (fnd_log.level_procedure,
  		lc_api_name,'Start processing bulk receive id '||x_sr_ro_rma_tbl(l_counter).bulk_receive_id);
	End if;
    if x_sr_ro_rma_tbl(l_counter).inventory_item_id is not null then

      if (x_sr_ro_rma_tbl(l_counter).serial_number is not null and x_sr_ro_rma_tbl(l_counter).instance_id is not null) then
        -- case1.
        -- We will look for the exact matching RO. If we find it we will return it else,
        -- we will try to find the latest open SR for the customer account and party combination.
		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			fnd_log.STRING (fnd_log.level_procedure,
			lc_api_name,'Searching the match for SN '||x_sr_ro_rma_tbl(l_counter).Serial_number);
		End if;
        l_sql_string_tmp := 'select repair_line_id,incident_id,''N'',''N'' from (' ||lc_sql_string_ro||
        							 ' and cr.serial_number = :p_serial_number '||
        							 ' and cr.customer_product_id = :p_instance_id '||
        							 ' order by cr.creation_date desc ) where rownum = 1' ;
        begin
        	execute immediate l_sql_string_tmp INTO x_sr_ro_rma_tbl(l_counter).repair_line_id,
              	x_sr_ro_rma_tbl(l_counter).incident_id,x_sr_ro_rma_tbl(l_counter).create_sr_flag,
              	x_sr_ro_rma_tbl(l_counter).create_ro_flag
        	using x_sr_ro_rma_tbl(l_counter).inventory_item_id,x_sr_ro_rma_tbl(l_counter).cust_acct_id,
                x_sr_ro_rma_tbl(l_counter).party_id,x_sr_ro_rma_tbl(l_counter).serial_number,
                x_sr_ro_rma_tbl(l_counter).instance_id;
        exception
        	when no_data_found then
        		-- special case.
        		-- the SN being searched upon may not be on any of the open repair orders.
        		-- but that SN could possibly be on any of the loaner RMA's.
        		l_check_loaner_sn := 'Y';

        end;

      elsif (x_sr_ro_rma_tbl(l_counter).serial_number is not null and x_sr_ro_rma_tbl(l_counter).instance_id is null) then
		-- the instance number is null.
		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			fnd_log.STRING (fnd_log.level_procedure,
			lc_api_name,'Searching the match for SN(Non-IB) '||x_sr_ro_rma_tbl(l_counter).Serial_number);
		End if;
        l_sql_string_tmp := NULL;
        l_sql_string_tmp := ' select repair_line_id,incident_id,''N'',''N'' from ( '||
                            lc_sql_string_ro||' and cr.serial_number = :p_serial_number '||
                            ' order by cr.creation_date desc ) where rownum = 1 ';
        begin
          execute immediate l_sql_string_tmp into x_sr_ro_rma_tbl(l_counter).repair_line_id,
              	x_sr_ro_rma_tbl(l_counter).incident_id,x_sr_ro_rma_tbl(l_counter).create_sr_flag,
              	x_sr_ro_rma_tbl(l_counter).create_ro_flag
          using x_sr_ro_rma_tbl(l_counter).inventory_item_id,x_sr_ro_rma_tbl(l_counter).cust_acct_id,
                x_sr_ro_rma_tbl(l_counter).party_id,x_sr_ro_rma_tbl(l_counter).serial_number;
        exception
          when no_data_found then
        		-- special case.
        		-- the SN being searched upon may not be on any of the open repair orders.
        		-- but that SN could possibly be on any of the loaner RMA's.
        		l_check_loaner_sn := 'Y';
        end;

      elsif x_sr_ro_rma_tbl(l_counter).serial_number is null and
      			x_sr_ro_rma_tbl(l_counter).serial_control_flag <> 1 then
      		-- item is serial controlled, but no serial number was keyed in.
      		if x_sr_ro_rma_tbl(l_counter).quantity > 1 then
        		if x_sr_ro_rma_tbl(l_counter).ui_incident_id is not null then
        			x_sr_ro_rma_tbl(l_counter).incident_id := x_sr_ro_rma_tbl(l_counter).ui_incident_id;
        		else
        			x_sr_ro_rma_tbl(l_counter).incident_id := get_latest_open_sr(x_sr_ro_rma_tbl(l_counter).cust_acct_id,
        																		 x_sr_ro_rma_tbl(l_counter).party_id);
                end if;

        		if x_sr_ro_rma_tbl(l_counter).incident_id is null then
        			x_sr_ro_rma_tbl(l_counter).create_sr_flag := 'Y';
        		end if;
      			x_sr_ro_rma_tbl(l_counter).create_ro_flag := 'Y';
      	    end if;

      elsif x_sr_ro_rma_tbl(l_counter).serial_number is null then
        l_sql_string_tmp := NULL;
        l_sql_string_tmp := ' select incident_id,repair_line_id,''N'',''N'' from ('||lc_sql_string_ro||
                            ' and cr.quantity = :p_quantity order by sr.incident_id desc ) where rownum = 1';
        begin
        If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
           fnd_log.STRING (fnd_log.level_procedure,
           lc_api_name,
           'RO-SR Match: begin matching non-serial controlled items');
        End if;
          select incident_id,repair_line_id, create_sr_flag,create_ro_flag
          into  x_sr_ro_rma_tbl(l_counter).incident_id,x_sr_ro_rma_tbl(l_counter).repair_line_id,
                x_sr_ro_rma_tbl(l_counter).create_sr_flag,x_sr_ro_rma_tbl(l_counter).create_ro_flag
          from (
          select sr.incident_id,cr.repair_line_id,'N' create_sr_flag,'N' create_ro_flag
          from csd_repairs cr,cs_incidents_all_b sr
          where cr.inventory_item_id = x_sr_ro_rma_tbl(l_counter).inventory_item_id
          and   cr.status = 'O'
          and   cr.incident_id = sr.incident_id
          and   sr.account_id = x_sr_ro_rma_tbl(l_counter).cust_acct_id
          and   sr.customer_id = x_sr_ro_rma_tbl(l_counter).party_id
          and not exists (
                  select repair_line_id
                  from csd_product_transactions cpt
                  where cpt.repair_line_id = cr.repair_line_id
                  and cpt.action_type = 'RMA'
                  and cpt.prod_txn_status in ('RECEIVED','CANCELLED'))
          and    cr.quantity = x_sr_ro_rma_tbl(l_counter).quantity
          and    cr.repair_line_id not in (
                  select * from TABLE(cast(get_num_in_list(l_repair_line_ids_in) as JTF_NUMBER_TABLE))
                  union all select * from table(cast(l_in_progress_ro as JTF_NUMBER_TABLE)))
                  order by cr.creation_date desc ) where rownum = 1;

          l_repair_line_ids_in := x_sr_ro_rma_tbl(l_counter).repair_line_id||',';

          If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
           fnd_log.STRING (fnd_log.level_procedure,
           lc_api_name,
           'RO-SR Match: found a row for non serial controlled item '||l_repair_line_ids_in);
        End if;
        exception
        -- there are no exact match found. Now look for the recent most open RO,RMA for the
        -- customer, and Item. Start from RO and proceed.
          when no_data_found then
              l_check_loaner_non_sn := 'Y';
              --l_no_exact_match := 'Y';
        If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
           fnd_log.STRING (fnd_log.level_procedure,
           lc_api_name,
           'RO-SR Match: In no data found');
        End if;
        end;

       if l_check_loaner_non_sn = 'Y' then
		 begin
			 SELECT sr.incident_id ,
					cr.repair_line_id    ,
					'N'                  ,
					'N'
			 into
					x_sr_ro_rma_tbl(l_counter).incident_id,
					x_sr_ro_rma_tbl(l_counter).repair_line_id,
					x_sr_ro_rma_tbl(l_counter).create_sr_flag,
					x_sr_ro_rma_tbl(l_counter).create_ro_flag
			 from csd_repairs cr,
				  csd_product_transactions cpt,
				  cs_incidents_all_b sr,
				  cs_estimate_details ced
			 where cr.incident_id = sr.incident_id
			 and   sr.account_id = x_sr_ro_rma_tbl(l_counter).cust_acct_id
			 and   sr.customer_id = x_sr_ro_rma_tbl(l_counter).party_id
			 and   cpt.repair_line_id = cr.repair_line_id
			 and   cpt.estimate_detail_id = ced.estimate_detail_id
			 and   abs(ced.quantity_required) = x_sr_ro_rma_tbl(l_counter).quantity
			 and   ced.inventory_item_id = x_sr_ro_rma_tbl(l_counter).inventory_item_id
			 and   cpt.action_type = 'SHIP'
			 and   cpt.action_code = 'LOANER'
			 and   cpt.prod_txn_status = 'SHIPPED'
			 and not exists
				  ( select 'Y' from csd_product_transactions cpt1
					where cpt1.repair_line_id = cpt.repair_line_id
					and   cpt1.action_type = 'RMA'
					and   cpt1.action_code = 'LOANER'
					and   cpt1.prod_txn_status in ('RECEIVED','CANCELLED')
				   )
			and    cr.repair_line_id not in (
                  select * from TABLE(cast(get_num_in_list(l_repair_line_ids_in) as JTF_NUMBER_TABLE))
                  union all select * from table(cast(l_in_progress_ro as JTF_NUMBER_TABLE)));

			l_check_loaner_non_sn := 'N';
			l_repair_line_ids_in := x_sr_ro_rma_tbl(l_counter).repair_line_id||',';
       	exception
       		when no_data_found then
       			l_no_exact_match := 'Y';
       			l_check_loaner_non_sn := 'N';
       	end;
       end if;

       if l_no_exact_match = 'Y' then
        If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
           fnd_log.STRING (fnd_log.level_procedure,
           lc_api_name,
           'RO-SR Match: look for the latest match: Ignore quantity');
        End if;
            /*l_sql_string_tmp := NULL;
            l_sql_string_tmp := ' select incident_id,repair_line_id, quantity,''N'',''N'' from ('||lc_sql_string_ro||
                                ' order by cr.creation_date desc ) where rownum = 1 ';*/
            begin
              select incident_id,repair_line_id, create_sr_flag,create_ro_flag
			  into  x_sr_ro_rma_tbl(l_counter).incident_id,x_sr_ro_rma_tbl(l_counter).repair_line_id,
                    x_sr_ro_rma_tbl(l_counter).create_sr_flag,x_sr_ro_rma_tbl(l_counter).create_ro_flag
              from(
              select sr.incident_id,cr.repair_line_id,'N' create_sr_flag,'N' create_ro_flag
              from csd_repairs cr,cs_incidents_all_b sr
              where cr.inventory_item_id = x_sr_ro_rma_tbl(l_counter).inventory_item_id
              and   cr.status = 'O'
              and   cr.incident_id = sr.incident_id
              and   sr.account_id = x_sr_ro_rma_tbl(l_counter).cust_acct_id
              and   sr.customer_id = x_sr_ro_rma_tbl(l_counter).party_id
              and not exists (
                      select repair_line_id
                      from csd_product_transactions cpt
                      where cpt.repair_line_id = cr.repair_line_id
                      and cpt.action_type = 'RMA'
                      and cpt.prod_txn_status in ('RECEIVED','CANCELLED'))
              and    cr.repair_line_id not in (
                      select * from TABLE(cast(get_num_in_list(l_repair_line_ids_in) as JTF_NUMBER_TABLE))
                      union all select * from table(cast(l_in_progress_ro as JTF_NUMBER_TABLE)))
                      order by cr.creation_date desc) where rownum = 1;
             -- bug#8978204, subhat.
             l_repair_line_ids_in := x_sr_ro_rma_tbl(l_counter).repair_line_id||',';

            exception
              when no_data_found then
        		if x_sr_ro_rma_tbl(l_counter).ui_incident_id is not null then
        			x_sr_ro_rma_tbl(l_counter).incident_id := x_sr_ro_rma_tbl(l_counter).ui_incident_id;
        		else
        			x_sr_ro_rma_tbl(l_counter).incident_id := get_latest_open_sr(x_sr_ro_rma_tbl(l_counter).cust_acct_id,
        																		 x_sr_ro_rma_tbl(l_counter).party_id);
                end if;
                x_sr_ro_rma_tbl(l_counter).incident_id := get_latest_open_sr(x_sr_ro_rma_tbl(l_counter).cust_acct_id,x_sr_ro_rma_tbl(l_counter).party_id);
                if x_sr_ro_rma_tbl(l_counter).incident_id is null then
                  x_sr_ro_rma_tbl(l_counter).create_sr_flag := 'Y';
                end if;
                x_sr_ro_rma_tbl(l_counter).create_ro_flag := 'Y';
            end;
         end if;
      end if;

   end if;

   -- special search for the loaner items.
   	if l_check_loaner_sn = 'Y' THEN
        	begin
        		SELECT sr.incident_id ,
					cr.repair_line_id    ,
					'N'                  ,
				    'N'
				INTO
					x_sr_ro_rma_tbl(l_counter).incident_id,
					x_sr_ro_rma_tbl(l_counter).repair_line_id,
					x_sr_ro_rma_tbl(l_counter).create_sr_flag,
					x_sr_ro_rma_tbl(l_counter).create_ro_flag
				FROM csd_repairs cr,
				     csd_product_transactions cpt,
				     cs_incidents_all_b sr
				WHERE cr.incident_id = sr.incident_id
					AND   sr.account_id = x_sr_ro_rma_tbl(l_counter).cust_acct_id
				 	AND   sr.customer_id = x_sr_ro_rma_tbl(l_counter).party_id
				 	AND   cpt.repair_line_id = cr.repair_line_id
				 	AND   cpt.source_serial_number = x_sr_ro_rma_tbl(l_counter).serial_number
				 	AND   cpt.action_type = 'SHIP'
				 	AND   cpt.action_code = 'LOANER'
				 	AND   cpt.prod_txn_status = 'SHIPPED'
				 	AND NOT EXISTS
				      ( SELECT 'Y' FROM csd_product_transactions cpt1
				        WHERE cpt1.repair_line_id = cpt.repair_line_id
				        AND   cpt1.action_type = 'RMA'
				        AND   cpt1.action_code = 'LOANER'
				        AND   cpt1.prod_txn_status in ('RECEIVED','CANCELLED')
       				  )
       				and    cr.repair_line_id not in (
                  		select * from TABLE(cast(get_num_in_list(l_repair_line_ids_in) as JTF_NUMBER_TABLE))
                  		union all select * from table(cast(l_in_progress_ro as JTF_NUMBER_TABLE)));

       			l_check_loaner_sn := 'N';
       			l_repair_line_ids_in := x_sr_ro_rma_tbl(l_counter).repair_line_id||',';

        	exception
        		when no_data_found then
        			if x_sr_ro_rma_tbl(l_counter).ui_incident_id is not null then
        				x_sr_ro_rma_tbl(l_counter).incident_id := x_sr_ro_rma_tbl(l_counter).ui_incident_id;
        			else
        				x_sr_ro_rma_tbl(l_counter).incident_id := get_latest_open_sr(x_sr_ro_rma_tbl(l_counter).cust_acct_id,
        																		 x_sr_ro_rma_tbl(l_counter).party_id);
                	end if;
        			if x_sr_ro_rma_tbl(l_counter).incident_id is null then
        				x_sr_ro_rma_tbl(l_counter).create_sr_flag := 'Y';
        			end if;
        	   		x_sr_ro_rma_tbl(l_counter).create_ro_flag := 'Y';
        	end;
   	end if;

  -- populate the RO details if its not already populated.
  -- logic
  -- *
  if x_sr_ro_rma_tbl(l_counter).incident_id is not null and x_sr_ro_rma_tbl(l_counter).repair_line_id is null
     and nvl(x_sr_ro_rma_tbl(l_counter).create_ro_flag,'N') <> 'Y' then
        if x_sr_ro_rma_tbl(l_counter).serial_number is not null then
          l_ro_query_sql := l_ro_query_sql ||' and serial_number := :serial_number '||
                            ' order by creation_date desc';
        elsif x_sr_ro_rma_tbl(l_counter).serial_number is null then
          l_ro_query_sql := l_ro_query_sql||' order by creation_date desc ';
        end if;
          l_ro_query_sql := 'select repair_line_id from ( '||l_ro_query_sql||
                            ' ) where rownum = 1 ';
        begin
          if x_sr_ro_rma_tbl(l_counter).serial_number is not null then
            execute immediate l_ro_query_sql into x_sr_ro_rma_tbl(l_counter).repair_line_id
                    using x_sr_ro_rma_tbl(l_counter).incident_id,x_sr_ro_rma_tbl(l_counter).serial_number;
          else
            execute immediate l_ro_query_sql into x_sr_ro_rma_tbl(l_counter).repair_line_id
                    using x_sr_ro_rma_tbl(l_counter).incident_id;
            end if;
        exception
          when no_data_found then
            x_sr_ro_rma_tbl(l_counter).create_ro_flag := 'Y';
            x_sr_ro_rma_tbl(l_counter).found_rma_flag := 'Y';
        end;
  end if;
   x_sr_ro_rma_tbl(l_counter).bulk_receive_id := x_sr_ro_rma_tbl(l_counter).bulk_receive_id;
  --end if;
  end loop;

end get_sr_ro_rma_details;

PROCEDURE matching_rma_found
  (
    p_repair_line_id        IN NUMBER,
    p_blk_rec_qty           IN NUMBER,
    p_blk_rec_serial_number IN VARCHAR2,
    p_blk_rec_instance_id   IN NUMBER,
    p_blk_rec_inv_id        IN NUMBER,
    x_rma_found             OUT NOCOPY VARCHAR2,
    x_new_rma               OUT NOCOPY VARCHAR2,
    x_split_rma_qty         OUT NOCOPY NUMBER,
    x_new_rma_qty           OUT NOCOPY NUMBER,
    x_split_rma             OUT NOCOPY VARCHAR2,
    x_order_header_id       OUT NOCOPY NUMBER,
    x_order_line_id         OUT NOCOPY NUMBER
  ) IS

  order_booked varchar2(3);
  l_matching_rma_tbl MATCHING_RMA_TBL;
  l_prod_txn_rec csd_process_pvt.product_txn_rec;
  l_msg_count number;
  l_msg_data  varchar2(2000);
  l_return_status varchar2(3);

  l_check_loaner varchar2(2) := 'N';

  x_msg_index_out number;


 begin
 -- fetch all applicable records in a one single go.
 -- match SN,Quantity etc on the matched records.

  --begin
   select cpt.prod_txn_status,
          cpt.source_serial_number,
          cpt.source_instance_id,
          abs(ced.quantity_required) rma_quantity,
          ool.header_id,
          ool.line_id,
          ool.inventory_item_id
   bulk collect into
          l_matching_rma_tbl
   from csd_product_transactions cpt,
         cs_estimate_details ced,
         oe_order_lines_all ool,
         csd_repairs cr,
         csd_repair_types_b crtb
   where
        cpt.repair_line_id = p_repair_line_id and
        cpt.action_type = 'RMA' and
        crtb.repair_type_id = cr.repair_type_id and
        cpt.action_code = decode(crtb.repair_type_ref,'RR','CUST_PROD','ARR','CUST_PROD','E','EXCHANGE','AE','EXCHANGE','CUST_PROD') and
        cpt.prod_txn_status <> 'RECEIVED' and
        cpt.estimate_detail_id = ced.estimate_detail_id and
        ced.order_header_id = ool.header_id and
        ced.order_line_id   = ool.line_id and
        cr.repair_line_id   = cpt.repair_line_id and
        decode(cr.serial_number,null,'-1',cr.serial_number) = decode(cpt.source_serial_number,null,'-1',cpt.source_serial_number);

    if l_matching_rma_tbl.COUNT = 0 then
      -- no RMA's exist which are already interfaced to OM.
      -- there may be lines which are just entered in Charges and Depot. Look for them too.
     --dbms_output.put_line('No data found');
     begin
      select cpt.prod_txn_status,
      		 cpt.product_transaction_id,
      		 ced.estimate_detail_id,
      		 ced.inventory_item_id,
      		 ced.incident_id,
      		 ced.invoice_to_org_id,
      		 ced.ship_to_org_id,
      		 ced.org_id,
      		 ced.transaction_inventory_org

      into l_prod_txn_rec.prod_txn_status,
           l_prod_txn_rec.product_transaction_id,
           l_prod_txn_rec.estimate_detail_id,
           l_prod_txn_rec.inventory_item_id,
           l_prod_txn_rec.incident_id,
           l_prod_txn_rec.invoice_to_org_id,
           l_prod_txn_rec.ship_to_org_id,
           l_prod_txn_rec.organization_id,
           l_prod_txn_rec.inventory_org_id

      from csd_product_transactions cpt,
      	   cs_estimate_details ced
      where cpt.repair_line_id = p_repair_line_id and
			cpt.action_type = 'RMA' and
			cpt.action_code in ('CUST_PROD','EXCHANGE') and
			cpt.prod_txn_status <> 'RECEIVED' and
			cpt.estimate_detail_id = ced.estimate_detail_id and
			nvl(cpt.interface_to_om_flag,'N') = 'N' and
			rownum < 2;

      x_rma_found := 'Y';

	exception
	 	when no_data_found then
	 		l_check_loaner := 'Y';
	 		--x_rma_found := 'N';
	 		--return;
	end;
   end if;

   if l_check_loaner = 'Y' then
   		select cpt.prod_txn_status,
		       cpt.source_serial_number,
		       cpt.source_instance_id,
		       abs(ced.quantity_required) rma_quantity,
		       ool.header_id,
		       ool.line_id,
		       ool.inventory_item_id
		bulk collect into
		       l_matching_rma_tbl
		from csd_product_transactions cpt,
		        cs_estimate_details ced,
		        oe_order_lines_all ool,
		        csd_repairs cr
		where
		        cpt.repair_line_id = p_repair_line_id and
		        cpt.action_type = 'RMA' and
		        cpt.action_code = 'LOANER' and
		        cpt.prod_txn_status <> 'RECEIVED' and
		        cpt.estimate_detail_id = ced.estimate_detail_id and
		        ced.order_header_id = ool.header_id and
		        ced.order_line_id   = ool.line_id and
		        cr.repair_line_id   = cpt.repair_line_id ;
        --decode(cr.serial_number,null,'-1',cr.serial_number) = decode(cpt.source_serial_number,null,'-1',cpt.source_serial_number);

        if l_matching_rma_tbl.COUNT = 0 then
        	begin
				select 'Y'
				into   x_rma_found
				from csd_product_transactions cpt,
					 cs_estimate_details ced
				where cpt.repair_line_id = p_repair_line_id and
					cpt.action_type = 'RMA' and
					cpt.action_code = 'LOANER' and
					cpt.prod_txn_status <> 'RECEIVED' and
					cpt.estimate_detail_id = ced.estimate_detail_id and
					nvl(cpt.interface_to_om_flag,'N') = 'N' and
					rownum < 2;
			exception
				when no_data_found then
					x_rma_found := 'N';
	 				return;
			end;
		end if;
	end if;
  -- check whether the found RMA matches the bulk receive quantity and SR and Item.

  for l_counter in 1 ..l_matching_rma_tbl.COUNT
    loop
      IF p_blk_rec_serial_number is not null then
        IF l_matching_rma_tbl(l_counter).source_serial_number = p_blk_rec_serial_number THEN
          x_rma_found := 'Y';
          x_order_header_id := l_matching_rma_tbl(l_counter).header_id;
          x_order_line_id   := l_matching_rma_tbl(l_counter).line_id;
        ELSE
          x_rma_found := 'N';
        END IF;
      ELSIF p_blk_rec_serial_number is NULL then
        IF l_matching_rma_tbl(l_counter).rma_quantity = p_blk_rec_qty then
          x_rma_found := 'Y';
          x_order_header_id := l_matching_rma_tbl(l_counter).header_id;
          x_order_line_id   := l_matching_rma_tbl(l_counter).line_id;
        elsif l_matching_rma_tbl(l_counter).rma_quantity > p_blk_rec_qty then
          x_split_rma := 'Y';
          x_order_header_id := l_matching_rma_tbl(l_counter).header_id;
          x_order_line_id   := l_matching_rma_tbl(l_counter).line_id;
          x_split_rma_qty := l_matching_rma_tbl(l_counter).rma_quantity - p_blk_rec_qty ;
        elsif l_matching_rma_tbl(l_counter).rma_quantity < p_blk_rec_qty then
          x_new_rma := 'Y';
          x_order_header_id := l_matching_rma_tbl(l_counter).header_id;
          x_order_line_id   := l_matching_rma_tbl(l_counter).line_id;
          x_new_rma_qty := p_blk_rec_qty - l_matching_rma_tbl(l_counter).rma_quantity;
        else
          x_rma_found := 'N';
        end if;
      END IF;
    end loop;

end matching_rma_found;

PROCEDURE create_new_rma
 (
    p_api_version    IN NUMBER DEFAULT 1,
    p_init_msg_list   IN VARCHAR2 DEFAULT 'F',
    p_commit          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_order_header_id IN NUMBER,
    p_new_rma_qty     IN NUMBER,
    p_repair_line_id  IN NUMBER,
    p_incident_id     IN NUMBER,
    p_rma_quantity    IN NUMBER,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_order_line_id   OUT NOCOPY NUMBER,
    x_order_header_id OUT NOCOPY NUMBER
 ) IS

 l_prod_txn_rec CSD_PROCESS_PVT.PRODUCT_TXN_REC;
 l_add_to_order boolean default false;
 l_add_to_order_ro varchar2(2) default fnd_profile.value('CSD_ADD_TO_SO_WITHIN_RO');
 l_add_to_order_sr varchar2(2) default fnd_profile.value('CSD_ADD_TO_SO_WITHIN_SR');

 l_add_to_order_id number default p_order_header_id;

 BEGIN
  -- establish the savepoint.
  savepoint create_new_rma;
  -- get the default values from the existing RMA line

  l_prod_txn_rec.quantity := p_new_rma_qty;
  l_prod_txn_rec.process_txn_flag := 'Y';
  if l_add_to_order_ro = 'Y' then
  	l_add_to_order := true;
  elsif l_add_to_order_sr = 'Y' and NOT(l_add_to_order) then
  	l_add_to_order := true;
  end if;
  if l_add_to_order then
  	l_prod_txn_rec.order_header_id := l_add_to_order_id;
	l_prod_txn_rec.add_to_order_id := l_add_to_order_id;
	l_prod_txn_rec.add_to_order_flag := 'T';
	l_prod_txn_rec.new_order_flag := 'N';
  else
  	l_prod_txn_rec.order_header_id := null;
	l_prod_txn_rec.add_to_order_id := null;
	l_prod_txn_rec.add_to_order_flag := 'F';
	l_prod_txn_rec.new_order_flag := 'Y';
  end if;
  l_prod_txn_rec.interface_to_om_flag := 'Y';
  l_prod_txn_rec.book_sales_order_flag := 'Y';
  l_prod_txn_rec.repair_line_id := p_repair_line_id;
  l_prod_txn_rec.organization_id := csd_process_util.get_org_id(p_incident_id);
  l_prod_txn_rec.inventory_org_id := csd_process_util.get_inv_org_id;

    begin
      --bug#8585307, subhat, include contract_line_id

      select cpt.action_type,cpt.action_code,
          cpt.picking_rule_id,cpt.project_id,
          cpt.task_id,cpt.unit_number,
          ced.inventory_item_id,ced.unit_of_measure_code,
          ced.contract_id,ced.coverage_id,
          ced.price_list_header_id,ced.txn_billing_type_id,
          ced.business_process_id,ced.currency_code,
          ced.ship_to_party_id,ced.ship_to_account_id,
          ced.return_reason_code,ced.contract_line_id
      into l_prod_txn_rec.action_type,l_prod_txn_rec.action_code,
           l_prod_txn_rec.picking_rule_id,l_prod_txn_rec.project_id,
           l_prod_txn_rec.task_id,l_prod_txn_rec.unit_number,
           l_prod_txn_rec.inventory_item_id,l_prod_txn_rec.unit_of_measure_code,
           l_prod_txn_rec.contract_id,l_prod_txn_rec.coverage_id,
           l_prod_txn_rec.price_list_id,l_prod_txn_rec.txn_billing_type_id,
           l_prod_txn_rec.business_process_id,l_prod_txn_rec.currency_code,
           l_prod_txn_rec.ship_to_party_id,l_prod_txn_rec.ship_to_account_id,
           l_prod_txn_rec.return_reason,l_prod_txn_rec.contract_line_id
      from csd_product_transactions cpt,
           cs_estimate_details ced
      where cpt.repair_line_id = p_repair_line_id and
            ced.estimate_detail_id = cpt.estimate_detail_id and
            cpt.action_type IN ('RMA','RMA_THIRD_PARTY') and
            abs(ced.quantity_required) = p_rma_quantity
            and rownum < 2;
    exception
      when no_data_found then
        -- the program cannot find the existing RMA line. Cannot get in here.
        NULL;
    end;
    l_prod_txn_rec.bill_to_party_id := l_prod_txn_rec.ship_to_party_id;
    l_prod_txn_rec.bill_to_account_id := l_prod_txn_rec.ship_to_account_id;
 -- before calling the product transactions api, need to update the repair order quantity.
 -- otherwise the quantity validations will fail in the prod txn api.

 update csd_repairs
 set quantity = (p_rma_quantity + p_new_rma_qty)
 where repair_line_id = p_repair_line_id
 and quantity = p_rma_quantity;

  -- call the routine to create the additional RMA.
  csd_process_pvt.create_product_txn(
        p_api_version => 1.0,
        p_commit      => 'F',
        p_init_msg_list => 'T',
        p_validation_level => 100,
        x_product_txn_rec => l_prod_txn_rec,
        x_return_status  => x_return_status,
        x_msg_data       => x_msg_data,
        x_msg_count      => x_msg_count
    );

  if x_return_status <> FND_API.g_ret_sts_success then
    -- to do.
    -- Need to put a note with the error message.
    raise FND_API.G_EXC_ERROR;
  end if;
  -- bug#8599965, get the order header from DB.
  -- x_order_header_id := l_prod_txn_rec.order_header_id;
  -- fetch order line id into the l_order_line_id variable.
  begin
    select ced.order_line_id,
    	   ced.order_header_id
    into x_order_line_id,
    	 x_order_header_id
    from cs_estimate_details ced,csd_product_transactions cpt
    where cpt.product_transaction_id = l_prod_txn_rec.product_transaction_id
    and ced.estimate_detail_id = cpt.estimate_detail_id;
  exception
    when no_data_found then
      null;
  end;
 EXCEPTION
  when FND_API.G_EXC_ERROR THEN
    -- an error occured during creation of new RMA.
    ROLLBACK TO create_new_rma;
  when others then
  	ROLLBACK TO create_new_rma;

 END create_new_rma;

 PROCEDURE link_sr_ro_rma_oa_wrapper(
    p_bulk_rcv_dtls_tbl IN  VARCHAR2_TABLE_200,
    p_mode              IN  VARCHAR2,
    p_incident_id       IN  NUMBER DEFAULT NULL,
    x_repair_line_id    OUT NOCOPY JTF_NUMBER_TABLE,
    x_incident_id       OUT NOCOPY JTF_NUMBER_TABLE,
    x_unplanned_receipt_flag OUT NOCOPY VARCHAR2_TABLE_100,
    x_over_receipt_flag      OUT NOCOPY VARCHAR2_TABLE_100,
    x_under_receipt_flag     OUT NOCOPY VARCHAR2_TABLE_100,
    x_order_header_id        OUT NOCOPY JTF_NUMBER_TABLE,
    x_order_line_id          OUT NOCOPY JTF_NUMBER_TABLE,
    x_over_receipt_qty       OUT NOCOPY JTF_NUMBER_TABLE,
    x_under_receipt_qty      OUT NOCOPY JTF_NUMBER_TABLE
 ) IS

 x_sr_ro_rma_tbl SR_RO_RMA_TBL;
 l_sr_ro_rma_tbl SR_RO_RMA_TBL;
 l_bulk_rcv_dtls_tbl VARCHAR2_TABLE_200 := p_bulk_rcv_dtls_tbl;
 l_count number;
 l_bulk_receive_ids varchar2(2000);

 begin
 l_count := l_bulk_rcv_dtls_tbl.COUNT;
     -- initialize the out collection types;
     x_repair_line_id         := JTF_NUMBER_TABLE() ;
     x_incident_id            := JTF_NUMBER_TABLE();
     x_unplanned_receipt_flag := VARCHAR2_TABLE_100();
     x_over_receipt_flag      := VARCHAR2_TABLE_100();
     x_under_receipt_flag     := VARCHAR2_TABLE_100();
     x_order_header_id        := JTF_NUMBER_TABLE();
     x_order_line_id          := JTF_NUMBER_TABLE();
     x_under_receipt_qty      := JTF_NUMBER_TABLE();
     x_over_receipt_qty       := JTF_NUMBER_TABLE();

 for i in 1 ..l_count
  loop
    -- extend the collections
     x_repair_line_id.extend;
     x_incident_id.extend;
     x_unplanned_receipt_flag.extend;
     x_over_receipt_flag.extend;
     x_under_receipt_flag.extend;
     x_order_header_id.extend;
     x_order_line_id.extend;
     x_under_receipt_qty.extend;
     x_over_receipt_qty.extend;

     -- derive the values using the input rec.
     x_sr_ro_rma_tbl(i).bulk_receive_id   := to_number(split_varchar2_tbl(l_bulk_rcv_dtls_tbl(i),':'));
     x_sr_ro_rma_tbl(i).serial_number     := split_varchar2_tbl(l_bulk_rcv_dtls_tbl(i),':');
     x_sr_ro_rma_tbl(i).inventory_item_id := to_number(split_varchar2_tbl(l_bulk_rcv_dtls_tbl(i),':'));
     x_sr_ro_rma_tbl(i).instance_id       := to_number(split_varchar2_tbl(l_bulk_rcv_dtls_tbl(i),':'));
     x_sr_ro_rma_tbl(i).quantity          := to_number(split_varchar2_tbl(l_bulk_rcv_dtls_tbl(i),':'));
     x_sr_ro_rma_tbl(i).party_id          := to_number(split_varchar2_tbl(l_bulk_rcv_dtls_tbl(i),':'));
     x_sr_ro_rma_tbl(i).cust_acct_id      := to_number(split_varchar2_tbl(l_bulk_rcv_dtls_tbl(i),':'));
     x_sr_ro_rma_tbl(i).rev_control_flag  := split_varchar2_tbl(l_bulk_rcv_dtls_tbl(i),':');
     x_sr_ro_rma_tbl(i).revision          := l_bulk_rcv_dtls_tbl(i);
     x_sr_ro_rma_tbl(i).ui_incident_id    := p_incident_id;

     l_bulk_receive_ids := x_sr_ro_rma_tbl(i).bulk_receive_id||',';

  --dbms_output.put_line(x_sr_ro_rma_tbl(i).bulk_receive_id||x_sr_ro_rma_tbl(i).serial_number||
  --              x_sr_ro_rma_tbl(i).instance_id||x_sr_ro_rma_tbl(i).quantity||x_sr_ro_rma_tbl(i).party_id||x_sr_ro_rma_tbl(i).cust_acct_id);
     -- need to populate the serial_control_flag in the rec.
     if g_serial_control_flag.exists(x_sr_ro_rma_tbl(i).inventory_item_id) then
     	x_sr_ro_rma_tbl(i).serial_control_flag := g_serial_control_flag(x_sr_ro_rma_tbl(i).inventory_item_id);
     else
     	begin
     		select serial_number_control_code
     		into  x_sr_ro_rma_tbl(i).serial_control_flag
     		from mtl_system_items_b
     		where inventory_item_id = x_sr_ro_rma_tbl(i).inventory_item_id
     		and   organization_id = FND_PROFILE.VALUE('ORG_ID');
     		-- cache the serial flag for this inventory item id.
     		g_serial_control_flag(x_sr_ro_rma_tbl(i).inventory_item_id) := x_sr_ro_rma_tbl(i).serial_control_flag;
     	exception
     		when no_data_found then
     			null;
        end;
      end if;
  end loop;
 -- if its update mode and the record was unchanged then no need to re-run
 -- matching for them
 if p_mode = 'UPDATE' then
  l_count := 1;
  for k in (select bulk_receive_id,serial_number,inventory_item_id,quantity
            from csd_bulk_receive_items_b where bulk_receive_id in
            (select * from table(cast(get_num_in_list(l_bulk_receive_ids)as JTF_NUMBER_TABLE)) ) )
  LOOP
    if (k.bulk_receive_id = x_sr_ro_rma_tbl(l_count).bulk_receive_id and
        nvl(k.serial_number,1) = nvl(x_sr_ro_rma_tbl(l_count).serial_number,1) and
        k.inventory_item_id = x_sr_ro_rma_tbl(l_count).inventory_item_id and
        k.quantity = x_sr_ro_rma_tbl(l_count).quantity) THEN

        -- in the warning or unplanned receipts UI, no data was changed.
        -- no need to call the matching program for this rec.
        x_sr_ro_rma_tbl.DELETE(l_count);
        l_count := l_count+1;
    else
        l_count := l_count+1;
    end if;
   END LOOP;
 end if;
 -- call the find sr,ro routine to link to existing sr,ro's if any.
   if x_sr_ro_rma_tbl.count >= 1 then
      get_sr_ro_rma_details(1,x_sr_ro_rma_tbl);
   end if;
 -- call the match RMA procedure to find the matching RMA's for the RO,RMA's.

  for j in 1 ..x_sr_ro_rma_tbl.count
  loop

    if x_sr_ro_rma_tbl(j).incident_id is not null and x_sr_ro_rma_tbl(j).repair_line_id is not null
	      	 then
	      	 	-- call the procedure to find the matching RMA.
	      	 	csd_bulk_receive_util.matching_rma_found(
	      	 		p_repair_line_id        => x_sr_ro_rma_tbl(j).repair_line_id,
	      	 		p_blk_rec_qty           => x_sr_ro_rma_tbl(j).quantity,
	      	 		p_blk_rec_serial_number => x_sr_ro_rma_tbl(j).serial_number,
	      	 		p_blk_rec_instance_id   => x_sr_ro_rma_tbl(j).instance_id,
	      	 		p_blk_rec_inv_id        => x_sr_ro_rma_tbl(j).inventory_item_id,
	      	 		x_rma_found             => x_sr_ro_rma_tbl(j).found_rma_flag,
	      	 		x_new_rma               => x_sr_ro_rma_tbl(j).new_rma,
	      	 		x_split_rma_qty         => x_sr_ro_rma_tbl(j).split_rma_qty,
	      	 		x_new_rma_qty           => x_sr_ro_rma_tbl(j).new_rma_qty,
	      	 		x_split_rma             => x_sr_ro_rma_tbl(j).split_rma,
	      	 		x_order_header_id       => x_sr_ro_rma_tbl(j).order_header_id,
	      	 		x_order_line_id         => x_sr_ro_rma_tbl(j).order_line_id
	      	 		);
	      	 IF NVL(x_sr_ro_rma_tbl(j).found_rma_flag,'N') = 'Y' THEN
	      	 	  if x_sr_ro_rma_tbl(j).order_header_id is null then
	      	 	  	-- there is a line which is not yet booked or submitted to OM.
 	              	  x_unplanned_receipt_flag(j) := 'N';
	      	 	  else
					  x_order_header_id(j) := x_sr_ro_rma_tbl(j).order_header_id;
					  x_order_line_id(j) := x_sr_ro_rma_tbl(j).order_line_id;
					  x_unplanned_receipt_flag(j) := 'N';
				  end if;

	      	  -- over-receipt.
	      	  ELSIF NVL(x_sr_ro_rma_tbl(j).new_rma,'N') = 'Y' THEN
	      	      x_over_receipt_flag(j) := 'Y';
	      	      x_order_header_id(j) := x_sr_ro_rma_tbl(j).order_header_id;
	      	 	  x_order_line_id(j) := x_sr_ro_rma_tbl(j).order_line_id;
                  x_over_receipt_qty(j) := x_sr_ro_rma_tbl(j).new_rma_qty;
	      	  -- under-receipt. Split the RMA.
	      	  ELSIF NVL(x_sr_ro_rma_tbl(j).split_rma,'N') = 'Y' THEN
	      	      x_under_receipt_flag(j) := 'Y';
	      	      x_order_header_id(j) := x_sr_ro_rma_tbl(j).order_header_id;
	      	      x_order_line_id(j) := x_sr_ro_rma_tbl(j).order_line_id;
                  x_under_receipt_qty(j) := x_sr_ro_rma_tbl(j).split_rma_qty;

	      	  -- no rma found. Need to create one.
	      	  ELSE
	      	      x_unplanned_receipt_flag(j) := 'Y';
	      	  END IF;
	  elsif x_sr_ro_rma_tbl(j).incident_id is not null and x_sr_ro_rma_tbl(j).repair_line_id is  null then
      x_unplanned_receipt_flag(j) := 'Y';
    else
      x_unplanned_receipt_flag(j) := 'Y';
    end if;
    x_repair_line_id(j) := x_sr_ro_rma_tbl(j).repair_line_id;
    x_incident_id(j) := x_sr_ro_rma_tbl(j).incident_id;
  end loop;
end link_sr_ro_rma_oa_wrapper;

 /* ************************************************************************************/
 /* Procedure Name: after_receipt.														*/
 /* Description: Performs the action after the PO Receipt concurrent program is finished*/
 /*              Not a public API. Intended to be used by Bulk Receive conc program only*/
 /* params: @p_request_group_id: Group Id for receipts submitted.                      */
 /*         @p_transaction_number: Bulk Receive Transaction Number.                    */
 /* ************************************************************************************/

 procedure after_receipt(p_request_group_id IN NUMBER,
 						p_transaction_number IN NUMBER
						)
 IS

 Cursor c_ro_prodtxn(p_repair_line_id  number,
                      p_order_header_id number,
                      p_order_line_id   number) is
  select
    cib.customer_id,
    cib.account_id,
    cpt.estimate_quantity,
    cpt.unit_of_measure,
    cpt.inventory_item_id,
    cpt.order_header_id,
    cpt.order_line_id,
    cpt.order_number,
    cpt.serial_number,
    mtl.concatenated_segments item_name,
    cpt.revision,
    cpt.lot_number
  from
  csd_product_txns_v cpt,
  cs_incidents_all_b cib,
  csd_repairs cr,
  mtl_system_items_kfv mtl
  where cpt.repair_line_id = p_repair_line_id
  and cr.repair_line_id = cpt.repair_line_id
  and cib.incident_id = cr.incident_id
  and cpt.order_header_id  = p_order_header_id
  and cpt.order_line_id = p_order_line_id
  and mtl.inventory_item_id = cpt.inventory_item_id
  and mtl.organization_id = cs_std.get_item_valdn_orgzn_id;

  Cursor c_get_org (p_order_header_id number) is
  Select nvl(b.ship_from_org_id,a.ship_from_org_id)
  from   oe_order_headers_all a,
         oe_order_lines_all b
  where a.header_id = b.header_id
  and   a.header_id = p_order_header_id;

  Cursor c_get_prod_txn_status ( p_repair_line_id number ) is
  Select prod_txn_status
  from csd_product_transactions
  where repair_line_id = p_repair_line_id
  and action_type = 'RMA';

  l_rcv_error_msg_tbl  csd_receive_util.rcv_error_msg_tbl;
  l_header_error boolean;

  l_bulk_autorcv_tbl csd_bulk_receive_util.BULK_AUTORCV_TBL;

  l_msg_count number;
  l_msg_data varchar2(2000);
  l_return_status varchar2(3);
  l_errored boolean;
  l_prod_txn_status varchar2(30);

  lc_api_name CONSTANT varchar2(100)  := 'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.after_receipt';

begin

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			 	fnd_log.STRING (fnd_log.level_procedure,
			    lc_api_name,
				'Begin execution, populating bulk receive rec');
  End if;
  -- build bulk autorecv tbl.
  select cbr.bulk_receive_id,
  		 cbr.repair_line_id,
  		 ced.order_line_id,
  		 ced.order_header_id,
  		 cbr.under_receipt_flag,
  		 cbr.quantity,
  		 null,
  		 null,
  		 null,
  		 null,
  		 cbr.serial_number
  bulk collect into
  		 l_bulk_autorcv_tbl
  from csd_bulk_receive_items_b cbr,
       csd_product_transactions cpt,
       cs_estimate_details ced
  where cbr.transaction_number = p_transaction_number
  and   cbr.repair_line_id = cpt.repair_line_id
  and   cpt.action_type = 'RMA'
  and   cpt.estimate_detail_id = ced.estimate_detail_id;

  -- get the errors message table.

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			 	fnd_log.STRING (fnd_log.level_procedure,
			    lc_api_name,
				'Calling csd_receive_util.check_rcv_errors');
  End if;
  csd_receive_util.check_rcv_errors(x_return_status => l_return_Status,
  								    x_rcv_error_msg_tbl => l_rcv_error_msg_tbl,
  								    p_request_group_id => p_request_group_id
  									);

  If ( l_rcv_error_msg_tbl.count > 0 ) then

         l_header_error := FALSE;

         For i in 1..l_rcv_error_msg_tbl.count
         Loop
           If ( l_rcv_error_msg_tbl(i).header_interface_id  is not null and
                l_rcv_error_msg_tbl(i).interface_transaction_id  is null ) then

             l_header_error := TRUE;

             -- Display the message
             Fnd_file.put_line(fnd_file.log,'Error:Auto Receive failed - Header');
             Fnd_file.put(fnd_file.log,'Column name:');
             Fnd_file.put_line(fnd_file.log,l_rcv_error_msg_tbl(i).column_name);
             Fnd_file.put(fnd_file.log,'Error Message:');
             Fnd_file.put_line(fnd_file.log,l_rcv_error_msg_tbl(i).error_message);

           End if;
         End Loop;

         -- If there is header error the update all the Auto Receive lines
         -- in Bulk Rcv table to Errored
         If (l_header_error) then
			  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
							fnd_log.STRING (fnd_log.level_procedure,
							lc_api_name,
							'Header error, updating all the records to errored ');
			  End if;
           -- Update all the auto receive records to error
             Update csd_bulk_receive_items_b
             set status = 'ERRORED'
             where transaction_number = p_transaction_number;


         Else

           -- If there are no header errors then check for
           -- line errors and update the records
           For i in 1..l_bulk_autorcv_tbl.count
           Loop

             l_errored := FALSE;

             For j in 1..l_rcv_error_msg_tbl.count
             Loop

               If ( l_bulk_autorcv_tbl(i).order_header_id = l_rcv_error_msg_tbl(j).order_header_id and
                    l_bulk_autorcv_tbl(i).order_line_id   = l_rcv_error_msg_tbl(j).order_line_id ) then

                 l_errored := TRUE;

                -- Display the error message

                 /*l_customer_id       := null;
                 l_estimate_quantity := null;
                 l_unit_of_measure   := null;
                 l_inventory_item_id := null;
                 l_order_header_id   := null;
                 l_order_line_id     := null;
                 l_order_number      := null;
                 l_serial_number     := null;
                 l_item_name         := null;

                 Open c_ro_prodtxn(p_bulk_autorcv_tbl(i).repair_line_id,
                                   p_bulk_autorcv_tbl(i).order_header_id,
                                   p_bulk_autorcv_tbl(i).order_line_id);

                 -- 12.0 changes, subhat, added lot number and item revision
                 Fetch c_ro_prodtxn into l_customer_id,l_account_id,l_estimate_quantity,
                                    l_unit_of_measure,l_inventory_item_id,l_order_header_id,
                                    l_order_line_id,l_order_number,l_serial_number,l_item_name,l_item_revision,l_lot_number;
                 Close c_ro_prodtxn;

                 Fnd_file.put_line(fnd_file.log,'Error:Auto Receive failed - Line');
                 Fnd_file.put(fnd_file.log,'Serial Number :'||l_serial_number||',');
                 Fnd_file.put(fnd_file.log,'Inventory Item :'||l_item_name||',');
                 Fnd_file.put_line(fnd_file.log,'Qty :'||l_estimate_quantity);
                 Fnd_file.put(fnd_file.log,'Column name:');
                 Fnd_file.put_line(fnd_file.log,l_rcv_error_msg_tbl(i).column_name);
                 Fnd_file.put(fnd_file.log,'Error Message:');
                 Fnd_file.put_line(fnd_file.log,l_rcv_error_msg_tbl(i).error_message); */

               End If;

             End Loop;

             If (l_errored) then

			  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
							fnd_log.STRING (fnd_log.level_procedure,
							lc_api_name,
							'Bulk receive line ['||l_bulk_autorcv_tbl(i).bulk_receive_id||' ] is errored');
			  End if;
               Update csd_bulk_receive_items_b
               set status = 'ERRORED'
               where bulk_receive_id = l_bulk_autorcv_tbl(i).bulk_receive_id;

             Else

			   if nvl(l_bulk_autorcv_tbl(i).under_receipt_flag,'N') = 'Y' then
				  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
								fnd_log.STRING (fnd_log.level_procedure,
								lc_api_name,
								'Calling after_under_receipt_prcs for processing under-receipts');
				  End if;
                  after_under_receipt_prcs(p_repair_line_id => l_bulk_autorcv_tbl(i).repair_line_id,
                                          p_order_header_id => l_bulk_autorcv_tbl(i).order_header_id,
                                          p_order_line_id => l_bulk_autorcv_tbl(i).order_line_id,
                                          p_received_qty  => l_bulk_autorcv_tbl(i).receipt_qty
                                          );
               end if;

				If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
					fnd_log.STRING (fnd_log.level_procedure,
					lc_api_name,
					'Calling CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE');
				End if;
               -- Call Update receipts program
               CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE
                 ( p_api_version          => 1.0,
                   p_commit               => fnd_api.g_false,
                   p_init_msg_list        => fnd_api.g_true,
                   p_validation_level     => 0,
                   x_return_status        => l_return_status,
                   x_msg_count            => l_msg_count,
                   x_msg_data             => l_msg_data,
                   p_internal_order_flag  => 'N',
                   p_order_header_id      => null,
                   p_repair_line_id       => l_bulk_autorcv_tbl(i).repair_line_id);


               If NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) then
				If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
					fnd_log.STRING (fnd_log.level_procedure,
					lc_api_name,
					'Error in CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE: Return status '||l_return_status);
				End if;

                 Fnd_file.put_line(fnd_file.log,'Error : CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE failed');
                 csd_bulk_receive_util.write_to_conc_log
                   ( p_msg_count  => l_msg_count,
                     p_msg_data   => l_msg_data);

               Else

                 -- Get Product Txn Status
                 Open c_get_prod_txn_status ( l_bulk_autorcv_tbl(i).repair_line_id );
                 Fetch c_get_prod_txn_status into l_prod_txn_status;
                 Close c_get_prod_txn_status;

                 If ( l_prod_txn_status = 'RECEIVED' ) then

                   Update csd_bulk_receive_items_b
      	           set status = 'PROCESSED'
                   where bulk_receive_id = l_bulk_autorcv_tbl(i).bulk_receive_id;

                 End if;

               End if;

             End if;
           End Loop;

         End if; -- End if of l_header_error

    end if; -- end if of check for errors.
       -- Update all the auto receive records to processed
       For i in 1..l_bulk_autorcv_tbl.count
       Loop

		 -- process under receipts.
		    if nvl(l_bulk_autorcv_tbl(i).under_receipt_flag,'N') = 'Y' then
		          after_under_receipt_prcs(p_repair_line_id => l_bulk_autorcv_tbl(i).repair_line_id,
		                                   p_order_header_id => l_bulk_autorcv_tbl(i).order_header_id,
		                                   p_order_line_id => l_bulk_autorcv_tbl(i).order_line_id,
		                                   p_received_qty  => l_bulk_autorcv_tbl(i).receipt_qty);
            end if;


         -- Call Update receipts program
         CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE
          ( p_api_version          => 1.0,
            p_commit               => fnd_api.g_false,
            p_init_msg_list        => fnd_api.g_true,
            p_validation_level     => 0,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_internal_order_flag  => 'N',
            p_order_header_id      => null,
            p_repair_line_id       => l_bulk_autorcv_tbl(i).repair_line_id);


         If NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) then
		 	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
				fnd_log.STRING (fnd_log.level_procedure,
				lc_api_name,
				'Error in CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE: Return status '||l_return_status);
			End if;

           Fnd_file.put_line(fnd_file.log,'Error : CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE failed');
           csd_bulk_receive_util.write_to_conc_log
             ( p_msg_count  => l_msg_count,
               p_msg_data   => l_msg_data);

         Else

           -- Get Product Txn Status
           Open c_get_prod_txn_status ( l_bulk_autorcv_tbl(i).repair_line_id );
           Fetch c_get_prod_txn_status into l_prod_txn_status;
           Close c_get_prod_txn_status;

           If ( l_prod_txn_status = 'RECEIVED' ) then
				If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
					fnd_log.STRING (fnd_log.level_procedure,
					lc_api_name,
					'No errors during receiving,update the line as processed: id = '||l_bulk_autorcv_tbl(i).bulk_receive_id);
				End if;

             Update csd_bulk_receive_items_b
      	     set status = 'PROCESSED'
             where bulk_receive_id = l_bulk_autorcv_tbl(i).bulk_receive_id;

           End if;

         End if;

       End loop;

    /* End if; -- End if of the Status check

   End if; -- End if of the l_rcv_rec_tbl.count > 0  */

end after_receipt;

/* ***************************************************************************/
/* Procedure Name: pre_process_rma.                                          */
/* Description: Checks if the RMA is ready to be received. If the RMA is in  */
/*              SUBMITTED status, books the RMA and if the RMA is in ENTERED */
/*              status, then it submits the RMA to OM and books it.          */
/* ***************************************************************************/

procedure pre_process_rma (p_repair_line_id  IN NUMBER,
						   px_order_header_id IN OUT NOCOPY NUMBER,
						   px_order_line_id   IN OUT NOCOPY NUMBER,
						   x_return_status   OUT NOCOPY VARCHAR2,
						   x_msg_count       OUT NOCOPY NUMBER,
						   x_msg_data        OUT NOCOPY VARCHAR2
						   )
IS

l_rma_status varchar2(30);
l_book_order_flag   varchar2(3) := 'N';
l_prod_txn_rec csd_process_pvt.product_txn_rec;
lc_api_name varchar2(60) := 'CSD.PLSQL.CSD_BULK_RECEIVE_UTIL.PRE_PROCESS_RMA';
l_order_header_id number := px_order_header_id;
l_order_line_id number   := px_order_line_id;
l_check_loaner varchar2(2) := 'N';

l_add_to_order boolean := false;
l_add_to_order_ro varchar2(2) := fnd_profile.value('CSD_ADD_TO_SO_WITHIN_RO');
l_add_to_order_sr varchar2(2) := fnd_profile.value('CSD_ADD_TO_SO_WITHIN_SR');

begin

	savepoint pre_process_rma;

	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
		fnd_log.STRING (fnd_log.level_procedure,
		lc_api_name,
		'Begin pre_process_rma');
	End if;
	-- initialize the return status.
	x_return_status := fnd_api.g_ret_sts_success;

	if l_order_header_id is not null and l_order_line_id is not null then
		select cpt.prod_txn_status
		into l_rma_status
		from csd_product_transactions cpt,
			 cs_estimate_details ced
		where cpt.repair_line_id = p_repair_line_id
		and   cpt.estimate_detail_id = ced.estimate_detail_id
		and   ced.order_header_id = l_order_header_id
		and   ced.order_line_id = l_order_line_id;

		if l_rma_status = 'BOOKED' then
			return;
		elsif l_rma_status = 'SUBMITTED' then
			l_book_order_flag := 'Y';
		end if;

	elsif px_order_header_id is null and p_repair_line_id is not null then
		l_rma_status := 'ENTERED';
    end if;

	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
		fnd_log.STRING (fnd_log.level_procedure,
		lc_api_name,
		'Finding the existing RMA line');
	End if;
 	begin
		select cpt.prod_txn_status,
			   cpt.product_transaction_id,
			   ced.estimate_detail_id,
			   ced.inventory_item_id,
			   ced.incident_id,
			   ced.invoice_to_org_id,
			   ced.ship_to_org_id,
			   ced.org_id,
			   ced.transaction_inventory_org,
			   ced.business_process_id,
			   ced.txn_billing_type_id,
			   null bill_to_party_id,
			   null bill_to_account_id,
			   ced.order_header_id,
			   ced.order_line_id,
			   cpt.project_id,
			   cpt.unit_number
		into   l_prod_txn_rec.prod_txn_status,
			   l_prod_txn_rec.product_transaction_id,
			   l_prod_txn_rec.estimate_detail_id,
			   l_prod_txn_rec.inventory_item_id,
			   l_prod_txn_rec.incident_id,
			   l_prod_txn_rec.invoice_to_org_id,
			   l_prod_txn_rec.ship_to_org_id,
			   l_prod_txn_rec.organization_id,
			   l_prod_txn_rec.inventory_org_id,
			   l_prod_txn_rec.business_process_id,
			   l_prod_txn_rec.txn_billing_type_id,
			   l_prod_txn_rec.bill_to_party_id,
			   l_prod_txn_rec.bill_to_account_id,
			   l_prod_txn_rec.order_header_id,
			   l_prod_txn_rec.order_line_id,
			   l_prod_txn_rec.project_id,
			   l_prod_txn_rec.unit_number
		from csd_product_transactions cpt,
			 cs_estimate_details ced
		where cpt.repair_line_id = p_repair_line_id and
			   cpt.action_type = 'RMA' and
			   cpt.action_code = 'CUST_PROD' and
			   cpt.prod_txn_status <> 'RECEIVED' and
			   cpt.estimate_detail_id = ced.estimate_detail_id and
			   nvl(ced.order_header_id,-1) = nvl(l_order_header_id,-1)  and
			   nvl(ced.order_line_id,-1)  = nvl(l_order_line_id,-1) and
			   rownum < 2;
    exception
    	when no_data_found then
    		l_check_loaner := 'Y';
    end;

    if l_check_loaner = 'Y' then
		select cpt.prod_txn_status,
			   cpt.product_transaction_id,
			   ced.estimate_detail_id,
			   ced.inventory_item_id,
			   ced.incident_id,
			   ced.invoice_to_org_id,
			   ced.ship_to_org_id,
			   ced.org_id,
			   ced.transaction_inventory_org,
			   ced.business_process_id,
			   ced.txn_billing_type_id,
			   null bill_to_party_id,
			   null bill_to_account_id,
			   ced.order_header_id,
			   ced.order_line_id,
			   cpt.project_id

		into   l_prod_txn_rec.prod_txn_status,
			   l_prod_txn_rec.product_transaction_id,
			   l_prod_txn_rec.estimate_detail_id,
			   l_prod_txn_rec.inventory_item_id,
			   l_prod_txn_rec.incident_id,
			   l_prod_txn_rec.invoice_to_org_id,
			   l_prod_txn_rec.ship_to_org_id,
			   l_prod_txn_rec.organization_id,
			   l_prod_txn_rec.inventory_org_id,
			   l_prod_txn_rec.business_process_id,
			   l_prod_txn_rec.txn_billing_type_id,
			   l_prod_txn_rec.bill_to_party_id,
			   l_prod_txn_rec.bill_to_account_id,
			   l_prod_txn_rec.order_header_id,
			   l_prod_txn_rec.order_line_id,
			   l_prod_txn_rec.project_id
		from csd_product_transactions cpt,
			 cs_estimate_details ced
		where cpt.repair_line_id = p_repair_line_id and
			   cpt.action_type = 'RMA' and
			   cpt.action_code = 'LOANER' and
			   cpt.prod_txn_status <> 'RECEIVED' and
			   cpt.estimate_detail_id = ced.estimate_detail_id and
			   nvl(ced.order_header_id,-1) = nvl(l_order_header_id,-1)  and
			   nvl(ced.order_line_id,-1)  = nvl(l_order_line_id,-1) and
			   rownum < 2;
		l_check_loaner := 'N';
	end if;

	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
		fnd_log.STRING (fnd_log.level_procedure,
		lc_api_name,
		'Populating l_prod_txn_rec with the default values');
	End if;
	l_prod_txn_rec.source_id := p_repair_line_id;
	l_prod_txn_rec.original_source_id := p_repair_line_id;
	l_prod_txn_rec.repair_line_id := p_repair_line_id;
	l_prod_txn_rec.process_txn_flag := 'Y';
	l_prod_txn_rec.interface_to_om_flag := 'Y';
	l_prod_txn_rec.book_sales_order_flag := 'Y';

    if l_rma_status = 'SUBMITTED' then
    -- the order is already interfaced to OM. Just need to Book it.
    	l_prod_txn_rec.new_order_flag := 'N';
    elsif l_rma_status = 'ENTERED' then

    	if l_add_to_order_ro = 'Y' then
			Select max(ced.order_header_id)
			into  l_prod_txn_rec.add_to_order_id
			from csd_product_transactions cpt,
				cs_estimate_details ced,
				oe_order_headers_all ooh,
				oe_order_types_v oot,
				cs_incidents_all_b sr
			where cpt.estimate_detail_id = ced.estimate_detail_id
				and  cpt.repair_line_id = p_repair_line_id
				and  ced.order_header_id is not null
				and  ced.interface_to_oe_flag = 'Y'
				and  ooh.open_flag = 'Y'
				and  nvl(ooh.cancelled_flag,'N') = 'N'
				and  ooh.header_id = ced.order_header_id
				and  ooh.order_type_id = oot.order_type_id
				and  ced.incident_id = sr.incident_id
				and  ooh.sold_to_org_id = sr.account_id
				and  oot.order_category_code in ('MIXED','RETURN');
			if nvl(l_prod_txn_rec.add_to_order_id,-1) > 0 then
				l_add_to_order := true;
			else
				l_add_to_order := false;
			end if;
		 end if;

		 if l_add_to_order_sr = 'Y' and NOT(l_add_to_order) then
		 	l_prod_txn_rec.add_to_order_id := csd_process_util.Get_Sr_add_to_order
		 												(p_repair_line_id,'RMA');
		 	if nvl(l_prod_txn_rec.add_to_order_id,-1) > 0 then
            	l_add_to_order := true;
            else
            	l_add_to_order := false;
            end if;
         end if;

    	if l_add_to_order then
    		l_prod_txn_rec.new_order_flag := 'N';
    		l_prod_txn_rec.order_header_id := l_prod_txn_rec.add_to_order_id;
    		l_prod_txn_rec.add_to_order_flag := 'T';
    	else
    		l_prod_txn_rec.new_order_flag := 'Y';
    	end if;
    end if;

	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
		fnd_log.STRING (fnd_log.level_procedure,
		lc_api_name,
		'Calling csd_process_pvt.update_product_txn to book the order');
	End if;

	csd_process_pvt.update_product_txn
		( p_api_version     => 1,
		  p_commit          => FND_API.G_FALSE,
		  p_init_msg_list   => FND_API.G_TRUE,
		  p_validation_level=> fnd_api.g_valid_level_full,
		  x_product_txn_rec => l_prod_txn_rec,
		  x_return_status   => x_return_status,
		  x_msg_count       => x_msg_count,
		  x_msg_data        => x_msg_data
	    );
	if x_return_status <> fnd_api.g_ret_sts_success then
		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			fnd_log.STRING (fnd_log.level_procedure,
			lc_api_name,
			'Error while trying to book the existing line ');
		End if;
		raise fnd_api.g_exc_error;
	end if;

	select ced.order_header_id,ced.order_line_id
    into px_order_header_id,px_order_line_id
	from csd_product_transactions cpt,
		 cs_estimate_details ced
	where cpt.repair_line_id = p_repair_line_id
	and   ced.estimate_detail_id = cpt.estimate_detail_id
	and   ced.estimate_detail_id = l_prod_txn_rec.estimate_detail_id
	and   cpt.action_type = 'RMA';

exception
	when fnd_api.g_exc_error then
		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			fnd_log.STRING (fnd_log.level_procedure,
			lc_api_name,
			'In g_exc_error exception, rolling back to pre_process_rma ');
		End if;
		x_return_status := fnd_api.g_ret_sts_error;
		rollback to pre_process_rma;
	when no_data_found then
		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			fnd_log.STRING (fnd_log.level_procedure,
			lc_api_name,
			'In no_data_found exception.');
		End if;
		x_return_status := fnd_api.g_ret_sts_error;
		rollback to pre_process_rma;
	when others then
		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			fnd_log.STRING (fnd_log.level_procedure,
			lc_api_name,
			'In when others exception and the error message is '||SQLERRM);
		End if;
		raise;
end pre_process_rma;

/* ***************************************************************************/
/* Procedure Name: create_new_ship_line.                                     */
/* Description : Creates a new Ship line for the over-receipt quantity       */
/* ***************************************************************************/

procedure create_new_ship_line
					(
             		 p_api_version 	   IN VARCHAR2,
             		 p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
             		 p_commit      	   IN VARCHAR2 DEFAULT  FND_API.G_FALSE,
             		 p_order_header_id IN NUMBER,
             		 p_new_ship_qty    IN NUMBER,
             		 p_repair_line_id  IN NUMBER,
             		 p_incident_id     IN NUMBER,
             		 x_return_status   OUT NOCOPY VARCHAR2,
					 x_msg_count       OUT NOCOPY NUMBER,
                     x_msg_data        OUT NOCOPY VARCHAR2
                     )
IS

l_prod_txn_rec CSD_PROCESS_PVT.PRODUCT_TXN_REC;
lc_api_name varchar2(100) := 'CSD_BULK_RECEIVE_UTIL.create_new_ship_line';

BEGIN
 savepoint create_new_ship_line;
  -- get the default values from the existing SHIP line
  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			fnd_log.STRING (fnd_log.level_procedure,
			lc_api_name,
			'Begin creating new ship line');
  End if;

  l_prod_txn_rec.quantity := p_new_ship_qty;
  l_prod_txn_rec.process_txn_flag := 'Y';
  l_prod_txn_rec.new_order_flag := 'N';
  l_prod_txn_rec.interface_to_om_flag := 'N';
  l_prod_txn_rec.book_sales_order_flag := 'N';
  l_prod_txn_rec.repair_line_id := p_repair_line_id;
  l_prod_txn_rec.organization_id := csd_process_util.get_org_id(p_incident_id);
  l_prod_txn_rec.inventory_org_id := csd_process_util.get_inv_org_id;

    begin

      select cpt.action_type,cpt.action_code,
          cpt.picking_rule_id,cpt.project_id,
          cpt.task_id,cpt.unit_number,
          ced.inventory_item_id,ced.unit_of_measure_code,
          ced.contract_id,ced.coverage_id,
          ced.price_list_header_id,ced.txn_billing_type_id,
          ced.business_process_id,ced.currency_code,
          ced.ship_to_party_id,ced.ship_to_account_id,
          ced.return_reason_code,ced.contract_line_id
      into l_prod_txn_rec.action_type,l_prod_txn_rec.action_code,
           l_prod_txn_rec.picking_rule_id,l_prod_txn_rec.project_id,
           l_prod_txn_rec.task_id,l_prod_txn_rec.unit_number,
           l_prod_txn_rec.inventory_item_id,l_prod_txn_rec.unit_of_measure_code,
           l_prod_txn_rec.contract_id,l_prod_txn_rec.coverage_id,
           l_prod_txn_rec.price_list_id,l_prod_txn_rec.txn_billing_type_id,
           l_prod_txn_rec.business_process_id,l_prod_txn_rec.currency_code,
           l_prod_txn_rec.ship_to_party_id,l_prod_txn_rec.ship_to_account_id,
           l_prod_txn_rec.return_reason,l_prod_txn_rec.contract_line_id
      from csd_product_transactions cpt,
           cs_estimate_details ced
      where cpt.repair_line_id = p_repair_line_id and
            ced.estimate_detail_id = cpt.estimate_detail_id and
            cpt.action_type = 'SHIP' and
            rownum < 2;
    exception
      when no_data_found then
        -- the program cannot find the existing RMA line. Cannot get in here.
        NULL;
    end;
    l_prod_txn_rec.bill_to_party_id := l_prod_txn_rec.ship_to_party_id;
    l_prod_txn_rec.bill_to_account_id := l_prod_txn_rec.ship_to_account_id;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			fnd_log.STRING (fnd_log.level_procedure,
			lc_api_name,
			'Before calling csd_process_pvt.create_product_txn');
  End if;
 -- call the routine to create the additional RMA.
  csd_process_pvt.create_product_txn(
        p_api_version => 1.0,
        p_commit      => 'F',
        p_init_msg_list => 'T',
        p_validation_level => 100,
        x_product_txn_rec => l_prod_txn_rec,
        x_return_status  => x_return_status,
        x_msg_data       => x_msg_data,
        x_msg_count      => x_msg_count
    );

  if x_return_status <> FND_API.g_ret_sts_success then
	  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
				fnd_log.STRING (fnd_log.level_procedure,
				lc_api_name,
				'Error in csd_process_pvt.create_product_txn');
	  End if;
    raise FND_API.G_EXC_ERROR;
  end if;

 EXCEPTION
  when FND_API.G_EXC_ERROR THEN
    -- an error occured during creation of new RMA.
	  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
				fnd_log.STRING (fnd_log.level_procedure,
				lc_api_name,
				'Error encountered during creation of new ship line.');
				fnd_log.STRING (fnd_log.level_procedure,
				lc_api_name,
				'Message count '||x_msg_count||' message '|| x_msg_data);
	  End if;
    ROLLBACK TO create_new_ship_line;
  when others then
  	ROLLBACK TO create_new_ship_line;
 END create_new_ship_line;

--12.2. New functions, subhat
function split_varchar2_tbl (
        px_tbl_type IN OUT NOCOPY VARCHAR2,
        p_delimiter IN VARCHAR2
) RETURN VARCHAR2
IS

l_return_value VARCHAR2(200);

begin
  l_return_value := SUBSTR(px_tbl_type,1,INSTR(px_tbl_type,p_delimiter)-1);
  px_tbl_type := SUBSTR(px_tbl_type,INSTR(px_tbl_type,p_delimiter)+1);
  return l_return_value;
end split_varchar2_tbl;

FUNCTION get_latest_open_sr
  (
   p_account_id in NUMBER,
   p_party_id   in NUMBER) RETURN NUMBER
   IS
  l_incident_id NUMBER;

  begin
    select incident_id
    into l_incident_id
    from (
        select incident_id
        from cs_incidents_all_b
        where customer_id = p_party_id
        and account_id = p_account_id
        and status_flag = 'O'
        order by incident_id desc
        )
    where rownum = 1;

    return l_incident_id;

  exception
      when no_data_found then
        return l_incident_id;
end get_latest_open_sr;

FUNCTION get_num_in_list(p_in_string IN varchar2)
  RETURN JTF_NUMBER_TABLE
  IS

  l_in_string long default p_in_string;
  l_return_type JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  n number;
  BEGIN
    loop
      exit when l_in_string is null;
      n := instr(l_in_string,',');
      l_return_type.extend;
      l_return_type(l_return_type.count) := ltrim(rtrim(substr(l_in_string,1,n-1)));
      l_in_string := substr(l_in_string,n+1);
    end loop;
   return l_return_type;
END get_num_in_list;

END CSD_BULK_RECEIVE_UTIL;

/
