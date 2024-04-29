--------------------------------------------------------
--  DDL for Package Body INV_LOGICAL_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOGICAL_TRANSACTIONS_PVT" AS
/* $Header: INVLTPVB.pls 120.3.12010000.2 2009/05/30 21:58:42 musinha ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_LOGICAL_TRANSACTIONS_PVT';

PROCEDURE debug_print(p_message IN VARCHAR2, p_level IN NUMBER := 9) IS
BEGIN
   inv_log_util.TRACE(p_message, 'INV_LOGICAL_TRANSACTIONS_PVT',
		      p_level);
   -- dbms_output.put_line(p_message);
END debug_print;

-- Procedure
--    validate_input_parameters
-- Description
--    validate the inout paremters before populating the
--    inventory transactions table.

PROCEDURE validate_input_parameters
  (
   x_return_status            	        OUT    	NOCOPY VARCHAR2
   , x_msg_count                	OUT    	NOCOPY NUMBER
   , x_msg_data                 	OUT    	NOCOPY VARCHAR2
   , p_api_version_number               IN      NUMBER
   , p_init_msg_lst                     IN      VARCHAR2 DEFAULT fnd_api.g_false
   , p_mtl_trx_tbl                	IN     	inv_logical_transaction_global.mtl_trx_tbl_type
   , p_validation_level         	IN     	VARCHAR2
   , p_logical_trx_type_code	        IN	NUMBER
   ) IS

      l_return_status      VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_count NUMBER := 0;
      l_so_line_id NUMBER := 0;
      l_so_header_id NUMBER := 0;
      l_order_number VARCHAR2(40);
      l_project_id NUMBER := 0;
      l_task_id NUMBER := 0;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_transaction_action_id NUMBER := 0;
      l_transaction_source_type_id NUMBER := 0;
      l_transaction_type_id NUMBER := 0;
      l_acct_period_id NUMBER := 0;
      l_api_version_number CONSTANT NUMBER         := 1.0;
      l_api_name           CONSTANT VARCHAR2(30)   := 'Validate_Input_Parameters';


      -- For transactions that are processed through the transaction
      -- manager the physical reacord has already been validated. So, do
      -- not validate the physical record again. So, if the validation
      -- flag is set to false and if the trx type code is 2 (SO issue
      -- or RMA receipt, we will skip the record where the
      -- paren_transaction_flag is set to 1 (TRUE).
BEGIN

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



   IF (l_debug = 1) THEN
      debug_print('Inside validate input parameters API', 9);
   END IF;

   FOR i IN 1..p_mtl_trx_tbl.COUNT LOOP


      --1. Validate logical transaction type codes
      IF (p_logical_trx_type_code IS NULL OR
	  (p_logical_trx_type_code NOT IN
	   (INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_DSRECEIPT,
	    INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_DSDELIVER,
	    INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_GLOBPROCRTV,
	    INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_RETROPRICEUPD,
	    INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_RMASOISSUE))) THEN

	 IF (l_debug = 1) THEN
	    debug_print('Invalid Logical Transaction Type Code', 9);
	 END IF;
	 fnd_message.set_name('INV', 'INV_INT_LOGTRXCODE');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;

      END IF;

      -- For sales order transactions, we do not have to validate them
      -- since they are already validated by INV TM

      IF (p_validation_level = fnd_api.g_true) THEN

	 --2. Validate Transaction Action, Source and Type

	 IF (p_mtl_trx_tbl(i).transaction_type_id) IS NULL THEN
	    IF (l_debug = 1) THEN
	       debug_print('Transaction Type is null ', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_TRXTYPCODE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

         BEGIN
	    SELECT COUNT(1),transaction_action_id, transaction_source_type_id
	      INTO l_count, l_transaction_action_id, l_transaction_source_type_id
	      FROM mtl_transaction_types mtt
	      WHERE mtt.transaction_type_id =
	      p_mtl_trx_tbl(i).transaction_type_id AND
	      nvl(MTT.DISABLE_DATE,SYSDATE+1) > Sysdate
	      group by transaction_action_id, transaction_source_type_id;
	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug = 1) THEN
		  debug_print('Transaction Type not found ', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_TRXTYPCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	 END;

	 IF l_count <> 1 THEN
	    IF (l_debug = 1) THEN
	       debug_print('Transaction Type not found ', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_TRXTYPCODE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

	 IF (l_debug = 1) THEN
	    debug_print('Transaction Source Type ID : ' ||
			p_mtl_trx_tbl(i).transaction_source_type_id, 9);
	    debug_print('Transaction Action ID : ' ||
			p_mtl_trx_tbl(i).transaction_action_id, 9);
	 END IF;

	 IF ((p_mtl_trx_tbl(i).transaction_source_type_id IS NOT NULL and
	      p_mtl_trx_tbl(i).transaction_source_type_id <> l_transaction_source_type_id) OR
	     (p_mtl_trx_tbl(i).transaction_action_id IS NOT NULL and
	      p_mtl_trx_tbl(i).transaction_action_id <> l_transaction_action_id)) THEN
	    IF (l_debug = 1) THEN
	       debug_print('Transaction Source/Action is incorrect ', 9);
	       debug_print('Transaction Source Type ID : ' ||
			   l_transaction_source_type_id, 9);
	       debug_print('Transaction Action ID : ' ||
			   l_transaction_action_id, 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_TRXTYPCODE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;


	 -- 2.a. Validate all the actions that are for logical transactions.
	 -- Only these should be processed by this API

	 IF (Nvl(p_mtl_trx_tbl(i).transaction_action_id,0) NOT IN
	     (INV_GLOBALS.G_ACTION_LOGICALISSUE,INV_GLOBALS.G_ACTION_LOGICALICSALES ,
	      INV_GLOBALS.G_ACTION_LOGICALICRECEIPT, INV_GLOBALS.G_ACTION_LOGICALDELADJ,
	      INV_GLOBALS.G_ACTION_LOGICALICRCPTRETURN,INV_GLOBALS.G_ACTION_LOGICALICSALESRETURN,
	      INV_GLOBALS.G_ACTION_LOGICALEXPREQRECEIPT, INV_GLOBALS.G_ACTION_RETROPRICEUPDATE,
	      INV_GLOBALS.G_ACTION_LOGICALRECEIPT)) THEN
	    IF (l_debug = 1) THEN
	       debug_print('Transaction Action is invalid', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_TRXACTCODE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;


	 --3. Validate Organization
	 l_count := 0;

         BEGIN
	    SELECT COUNT(1) INTO l_count
	      FROM HR_ORGANIZATION_UNITS HOU, MTL_PARAMETERS MP
	      WHERE MP.ORGANIZATION_ID =  p_mtl_trx_tbl(i).organization_id
	      AND MP.ORGANIZATION_ID =  HOU.ORGANIZATION_ID
	      AND NVL(HOU.DATE_TO, SYSDATE + 1) > Sysdate;

	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug = 1) THEN
		  debug_print('Org. not found :' ||
			      p_mtl_trx_tbl(i).organization_id, 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_ORGCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	 END;

	 IF l_count <> 1 THEN
	    IF (l_debug = 1) THEN
	       debug_print('Invalid Organization :' ||
			   p_mtl_trx_tbl(i).organization_id, 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_XORGCODE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

	 --4. Validate Transfer Organization
	 -- Transfer organization needs to be validated only for
	 -- intercompany transactions. Other transactions would not have
	 -- the transfer organization filled in.

	 l_count := 0;

	 IF (Nvl(p_mtl_trx_tbl(i).transaction_action_id,0) IN
	     (INV_GLOBALS.G_ACTION_LOGICALICSALES, INV_GLOBALS.G_ACTION_LOGICALICRECEIPT,
	      INV_GLOBALS.G_ACTION_LOGICALICRCPTRETURN, INV_GLOBALS.G_ACTION_LOGICALICSALESRETURN,
	      INV_GLOBALS.G_ACTION_LOGICALEXPREQRECEIPT))THEN

	    IF (p_mtl_trx_tbl(i).transfer_organization_id IS NULL) THEN
	       IF (l_debug = 1) THEN
		  debug_print('Transfer Org. is null', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_XORGCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

            BEGIN
	       SELECT COUNT(1) INTO l_count
		 FROM HR_ORGANIZATION_UNITS HOU, MTL_PARAMETERS MP
		 WHERE MP.ORGANIZATION_ID =  p_mtl_trx_tbl(i).transfer_organization_id
		 AND MP.ORGANIZATION_ID =  HOU.ORGANIZATION_ID
		 AND NVL(HOU.DATE_TO, SYSDATE + 1) > Sysdate;

	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Transfer Org. not found :' ||
				 p_mtl_trx_tbl(i).transfer_organization_id, 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_XORGCODE');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN
	       IF (l_debug = 1) THEN
		  debug_print('Invalid Transfer Organization :' ||
			      p_mtl_trx_tbl(i).transfer_organization_id,
			      9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_XORGCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;
	 END IF;

	 --5. Validate Item
	 l_count := 0;

         BEGIN
	    SELECT COUNT(1) INTO l_count FROM MTL_SYSTEM_ITEMS MSI
	      WHERE MSI.INVENTORY_ITEM_ID = p_mtl_trx_tbl(i).inventory_item_id
	      AND MSI.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
	      AND MSI.INVENTORY_ITEM_FLAG = 'Y';
	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug = 1) THEN
		  debug_print('Item not found', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_ITMCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	 END;

	 IF l_count <> 1 THEN
	    IF (l_debug = 1) THEN
	       debug_print('Invalid item in the current Org. :' ||
			   p_mtl_trx_tbl(i).inventory_item_id, 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_ITMCODE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

	 --6. Validate Item for the transfer organization - only if the
	 -- transfer organization is populated.

	 l_count := 0;

	 IF (p_mtl_trx_tbl(i).transaction_action_id IN
	     (INV_GLOBALS.G_ACTION_LOGICALICSALES, INV_GLOBALS.G_ACTION_LOGICALICRECEIPT,
	      INV_GLOBALS.G_ACTION_LOGICALICRCPTRETURN, INV_GLOBALS.G_ACTION_LOGICALICSALESRETURN,
	      INV_GLOBALS.G_ACTION_LOGICALEXPREQRECEIPT))THEN
              BEGIN
		 SELECT COUNT(1) INTO l_count FROM MTL_SYSTEM_ITEMS MSI
		   WHERE MSI.INVENTORY_ITEM_ID = p_mtl_trx_tbl(i).inventory_item_id
		   AND MSI.ORGANIZATION_ID = p_mtl_trx_tbl(i).transfer_organization_id
		   AND MSI.INVENTORY_ITEM_FLAG = 'Y';
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF (l_debug = 1) THEN
		       debug_print('Item not found in the transfer Org. :'
				   || p_mtl_trx_tbl(i).inventory_item_id, 9);
		    END IF;
		    fnd_message.set_name('INV', 'INV_INT_ITMCODE');
		    fnd_msg_pub.ADD;
		    RAISE fnd_api.g_exc_error;
	      END;

	      IF (l_count <> 1) THEN
	         IF (l_debug = 1) THEN
		    debug_print('Invalid item in the transfer Org. :' ||
				p_mtl_trx_tbl(i).inventory_item_id, 9);
		 END IF;
		 fnd_message.set_name('INV', 'INV_INT_ITMCODE');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;

	      END IF;
	 END IF;

	 -- 7. Retroactive Price update specific validations
	 IF (Nvl(p_mtl_trx_tbl(i).transaction_action_id,0) =
	     INV_GLOBALS.G_ACTION_RETROPRICEUPDATE AND
	     Nvl(p_mtl_trx_tbl(i).transaction_source_type_id,0) =
	     INV_GLOBALS.G_SOURCETYPE_PURCHASEORDER) THEN

	    IF (p_mtl_trx_tbl(i).CONSUMPTION_RELEASE_ID IS NULL AND
		p_mtl_trx_tbl(i).CONSUMPTION_PO_HEADER_ID IS NULL) THEN

	       IF (l_debug = 1) THEN
		  debug_print('Both release id and po header id are null. One of them should have a valid value', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_RETCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	    IF (p_mtl_trx_tbl(i).old_po_price IS NULL or
		p_mtl_trx_tbl(i).new_po_price IS NULL) THEN

	       IF (l_debug = 1) THEN
		  debug_print('The old PO price and the new PO price shouldnt be null', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_RETQTYCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	    --8.  Check for invalid PO header ID
	    l_count := 0;

	    IF (p_mtl_trx_tbl(i).transaction_source_id IS NULL) THEN

	       IF (l_debug = 1) THEN
		  debug_print('Transaction Source ID is null', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_PO');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	    BEGIN
	       SELECT COUNT(1) INTO l_count FROM
		 po_headers_all po WHERE
		 po.po_header_id = p_mtl_trx_tbl(i).transaction_source_id  AND
		 NVL(po.START_DATE_ACTIVE, SYSDATE - 1) <= Sysdate AND
		 NVL(po.END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE AND ENABLED_FLAG = 'Y';

	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Cannot find the purchase order information or the po is invalid', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_PO');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN

	       IF (l_debug = 1) THEN
		  debug_print('Invalid puchase order header ID :' || p_mtl_trx_tbl(i).transaction_source_id, 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_PO');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	 END IF;


	 --9.  Validate subinventory if the subinventory is filled in.
	 l_count := 0;

	 IF (p_mtl_trx_tbl(i).subinventory_code IS NOT NULL) THEN
	    BEGIN
	       SELECT COUNT(1) INTO l_count FROM MTL_SECONDARY_INVENTORIES MSI
		 WHERE MSI.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
		 AND MSI.SECONDARY_INVENTORY_NAME = p_mtl_trx_tbl(i).subinventory_code
		 AND TRUNC(p_mtl_trx_tbl(i).transaction_date) <= NVL(MSI.DISABLE_DATE,p_mtl_trx_tbl(i).transaction_date + 1);
	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Cannot find the specified subinventory :'
				 || p_mtl_trx_tbl(i).locator_id, 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_SUBCODE');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN
	       IF (l_debug = 1) THEN
		  debug_print('Invalid subinventory :' ||
			      p_mtl_trx_tbl(i).subinventory_code, 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_SUBCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	    l_count := 0;

	    BEGIN
	       SELECT 1 INTO l_count FROM dual WHERE exists
		 (
		  SELECT null FROM MTL_SECONDARY_INVENTORIES MTSI,
		  MTL_SYSTEM_ITEMS MSI
		  WHERE MSI.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
		  AND MSI.INVENTORY_ITEM_ID = p_mtl_trx_tbl(i).inventory_item_id
		  AND MSI.RESTRICT_SUBINVENTORIES_CODE = 1
		  AND MTSI.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
		  --   AND MTSI.INVENTORY_ITEM_ID = p_mtl_trx_tbl(i).inventory_item_id
		  AND MTSI.ORGANIZATION_ID = MSI.ORGANIZATION_ID
		  --   AND MTSI.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
		  AND MTSI.SECONDARY_INVENTORY_NAME = p_mtl_trx_tbl(i).subinventory_code
		  UNION
		  SELECT NULL FROM MTL_SYSTEM_ITEMS ITM
		  WHERE ITM.RESTRICT_SUBINVENTORIES_CODE = 2
		  AND ITM.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
		  AND ITM.INVENTORY_ITEM_ID = p_mtl_trx_tbl(i).inventory_item_id);
	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Restricted Subinevntory', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_SUBCODE');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN
	       IF (l_debug = 1) THEN
		  debug_print('Invalid subinventory', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_SUBCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	 END IF;

	 --10. Validate Locators if the locator is filled in.
	 l_count := 0;

	 IF (p_mtl_trx_tbl(i).locator_id IS NOT NULL) THEN

	    BEGIN
	       SELECT COUNT(1) INTO l_count FROM MTL_ITEM_LOCATIONS MIL
		 WHERE MIL.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
		 AND MIL.SUBINVENTORY_CODE = p_mtl_trx_tbl(i).subinventory_code
		 AND MIL.INVENTORY_LOCATION_ID = p_mtl_trx_tbl(i).locator_id
		 AND TRUNC(p_mtl_trx_tbl(i).transaction_date) <= NVL(MIL.DISABLE_DATE,p_mtl_trx_tbl(i).transaction_date + 1);
	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Cannot find the specified locator :'
				 || p_mtl_trx_tbl(i).locator_id, 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_LOCCODE');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN
	       IF (l_debug = 1) THEN
		  debug_print('Invalid locator :' ||
			      p_mtl_trx_tbl(i).locator_id, 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_LOCCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	    l_count := 0;

	    BEGIN
	       SELECT 1 INTO l_count FROM dual WHERE exists
		 (
		  SELECT null FROM MTL_SECONDARY_LOCATORS MSL,
		  MTL_SYSTEM_ITEMS MSI
		  WHERE MSI.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
		  AND MSI.INVENTORY_ITEM_ID = p_mtl_trx_tbl(i).inventory_item_id
		  AND MSI.RESTRICT_LOCATORS_CODE = 1
		  AND MSL.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
		  AND MSL.INVENTORY_ITEM_ID = p_mtl_trx_tbl(i).inventory_item_id
		  AND MSL.ORGANIZATION_ID = MSI.ORGANIZATION_ID
		  AND MSL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
		  AND MSL.SUBINVENTORY_CODE = p_mtl_trx_tbl(i).subinventory_code
		  AND MSL.SECONDARY_LOCATOR = p_mtl_trx_tbl(i).locator_id
		  UNION
		  SELECT NULL FROM MTL_SYSTEM_ITEMS ITM
		  WHERE ITM.RESTRICT_LOCATORS_CODE = 2
		  AND ITM.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
		  AND ITM.INVENTORY_ITEM_ID = p_mtl_trx_tbl(i).inventory_item_id);
	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Restricted Sub/loc', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_LOCCODE');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN
	       IF (l_debug = 1) THEN
		  debug_print('Invalid locator', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_LOCCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	 END IF;


	 --11. Validate transaction source type for sales order tied to drop
	 -- ment transactions.
	 IF (p_logical_trx_type_code = INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_DSDELIVER AND
	     (p_mtl_trx_tbl(i).transaction_source_type_id = inv_globals.g_sourcetype_salesorder AND
	     p_mtl_trx_tbl(i).transaction_action_id = inv_globals.g_action_logicalissue)) THEN
	    -- drop shipments across multiple OUs
	    -- get the sales order tied to the logical transaction
	    -- get the start active and end active dates and make sure that
	    -- transaction date is between them.
	    BEGIN
	       SELECT odss.header_id INTO l_so_header_id
		 FROM oe_drop_ship_sources odss, rcv_transactions RT
		 WHERE odss.line_location_id = rt.po_line_location_id AND
		 rt.transaction_id = p_mtl_trx_tbl(i).rcv_transaction_id
		 GROUP BY odss.header_id;
	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Drop Ship Source not found', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_SRCCODE');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    l_count := 0;
	    BEGIN
	       SELECT 1 INTO l_count FROM mtl_sales_orders mso, oe_order_headers_all oeha
		 WHERE oeha.header_id = l_so_header_id
		 AND oeha.order_number = mso.segment1
		 AND mso.sales_order_id = p_mtl_trx_tbl(i).transaction_source_id
		 AND NVL(START_DATE_ACTIVE, SYSDATE - 1)
		 <= Sysdate AND NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE
		 AND ENABLED_FLAG = 'Y';
	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Sales Order is not valid for the current date', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_SALEXP');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN
	       IF (l_debug = 1) THEN
		  debug_print('Cannot find the sales order or sales order IS NOT active', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_SALEXP');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	 END IF;

	 -- Bug 3227829: Removing the check for quantity as the quantity
	 -- can vary depending on whether it is a correction or a receipt.
	 -- 12. Validate transaction quantity being passed.
	 -- For types
/*******
	 IF (p_mtl_trx_tbl(i).transaction_quantity > 0) AND
	   (p_mtl_trx_tbl(i).transaction_action_id in
	    (INV_GLOBALS.G_ACTION_LOGICALISSUE, INV_GLOBALS.G_ACTION_LOGICALICSALES, INV_GLOBALS.G_ACTION_LOGICALICRCPTRETURN)) THEN
	    IF (l_debug = 1) THEN
	       debug_print('Invalid transaction quantity : quantity should be negative', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INVALID_QUANTITY');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 IF (p_mtl_trx_tbl(i).transaction_quantity < 0) AND
	   (p_mtl_trx_tbl(i).transaction_action_id in
	    (INV_GLOBALS.G_ACTION_LOGICALICRECEIPT, INV_GLOBALS.G_ACTION_LOGICALICSALESRETURN,
	     INV_GLOBALS.G_ACTION_LOGICALEXPREQRECEIPT, INV_GLOBALS.G_ACTION_LOGICALRECEIPT)) THEN
	    IF (l_debug = 1) THEN
	       debug_print('Invalid transaction quantity : quantity should be positive', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INVALID_QUANTITY');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	   END IF;
******/
	 --13. Validate distribution account id
	 -- Assumption is that the distribution account id should have been
	 -- populated before passing the record for validation
	 -- check for the distribution account from gl code combinations for
	 -- that oraganization.

	 IF (p_mtl_trx_tbl(i).distribution_account_id IS NULL) THEN
	    IF (l_debug = 1) THEN
	       debug_print('Distribution account is null', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_DISTCODE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 debug_print('Distribution account :' ||
		     p_mtl_trx_tbl(i).distribution_account_id, 9);

	 l_count := 0;
         BEGIN
	    SELECT COUNT(1) INTO l_count FROM GL_CODE_COMBINATIONS GCC
	      WHERE GCC.CODE_COMBINATION_ID = p_mtl_trx_tbl(i).distribution_account_id
	      AND GCC.CHART_OF_ACCOUNTS_ID = (SELECT CHART_OF_ACCOUNTS_ID
					      FROM ORG_ORGANIZATION_DEFINITIONS OOD
					      WHERE OOD.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id)
	      AND GCC.ENABLED_FLAG = 'Y'
	      AND NVL(GCC.START_DATE_ACTIVE, SYSDATE - 1) <= SYSDATE
	      AND NVL(GCC.END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE;
	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug = 1) THEN
		  debug_print('Distribution account not found :' ||
			      p_mtl_trx_tbl(i).distribution_account_id, 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_DISTCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	 END;

	 IF (l_count <> 1) THEN

	    IF (l_debug = 1) THEN
	       debug_print('Invalid distribution account :' ||
			   p_mtl_trx_tbl(i).distribution_account_id, 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_DISTCODE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;


	 -- 14. Validate Account Period ID. The account_period_id should
	 -- be valid in all the organizations (primary and intermediate)
	 -- orgs. Check to see if it open for the date
	 -- specified/transaction date.

	 BEGIN
	    SELECT ACCT_PERIOD_ID
	      INTO   l_acct_period_id
	      FROM   ORG_ACCT_PERIODS
	      WHERE  PERIOD_CLOSE_DATE IS NULL
		AND ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
		AND TRUNC(SCHEDULE_CLOSE_DATE) >=
		TRUNC(nvl(p_mtl_trx_tbl(i).transaction_date,SYSDATE))
		AND TRUNC(PERIOD_START_DATE) <=
		TRUNC(nvl(p_mtl_trx_tbl(i).transaction_date,SYSDATE)) ;
	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       IF (l_debug = 1) THEN
		  debug_print('Invalid Account Period ID :' ||
			      l_acct_period_id, 9);
	       END IF;
	       l_acct_period_id := 0;
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  debug_print('Invalid Account Period ID :' ||
			      l_acct_period_id, 9);
	       END IF;
	       l_acct_period_id  := -1;
	 END;

	 IF (l_acct_period_id = -1 OR l_acct_period_id = 0) THEN
	    IF (l_debug = 1) THEN
	       debug_print('Period not open', 9);
	    END IF;
	    -- FND_MESSAGE.set_name('INV', 'INV_INT_PRDCODE');
	    FND_MESSAGE.set_name('INV', 'INV_NO_OPEN_PERIOD');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

	 IF (((p_mtl_trx_tbl(i).acct_period_id IS NOT NULL) AND
	      (p_mtl_trx_tbl(i).acct_period_id <> l_acct_period_id))
	     OR (p_mtl_trx_tbl(i).acct_period_id IS NULL)) THEN
	    IF (l_debug = 1) THEN
	       debug_print('Invalid Account Period ID passed : ' ||
			   p_mtl_trx_tbl(i).acct_period_id || ' is not the same as ' || l_acct_period_id, 9);
	    END IF;
	    FND_MESSAGE.set_name('INV', 'INV_NO_OPEN_PERIOD');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

	 --15. Validate transaction UOM

	 l_count := 0;

	 BEGIN
	    SELECT COUNT(1) INTO l_count
	      FROM MTL_ITEM_UOMS_VIEW MIUV
	      WHERE MIUV.INVENTORY_ITEM_ID = p_mtl_trx_tbl(i).inventory_item_id
	      AND MIUV.ORGANIZATION_ID = p_mtl_trx_tbl(i).organization_id
	      AND MIUV.UOM_CODE = p_mtl_trx_tbl(i).transaction_uom;
	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug = 1) THEN
		  debug_print('Invalid Transaction UOM : ' ||
			      p_mtl_trx_tbl(i).transaction_uom, 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_UOMCODE');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	 END;

	 IF (l_count) = 0 THEN
	    IF (l_debug = 1) THEN
	       debug_print('Transaction UOM : ' ||
			   p_mtl_trx_tbl(i).transaction_uom || ' not found', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_UOMCODE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

	 --16. Validate cost groups. Cost groups should already be populated
	 -- before validation.

	 IF (p_mtl_trx_tbl(i).cost_group_id IS NULL) THEN
	    IF (l_debug = 1) THEN
	       debug_print('Invalid Cost Group', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_CSTGRP');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

	 l_count := 0;

         BEGIN
	    SELECT COUNT(1) INTO l_count
	      FROM CST_COST_GROUPS CCG
	      WHERE CCG.COST_GROUP_ID = p_mtl_trx_tbl(i).cost_group_id
	      AND NVL(CCG.ORGANIZATION_ID, p_mtl_trx_tbl(i).organization_id) = p_mtl_trx_tbl(i).organization_id
	      AND TRUNC(NVL(CCG.DISABLE_DATE,SYSDATE+1)) >= TRUNC(SYSDATE);
	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug = 1) THEN
		  debug_print('Cost Group not found', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_CSTGRP');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	 END;

	 IF (l_count = 0) THEN
	    IF (l_debug = 1) THEN
	       debug_print('Cost Group not found : ' || p_mtl_trx_tbl(i).cost_group_id, 9);
	    END IF;
	       fnd_message.set_name('INV', 'INV_INT_CSTGRP');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	 END IF;

	 -- 17. Validate cost groups for transfer organziations.
	 -- Cost groups should already be populated before validation.

	 IF (p_mtl_trx_tbl(i).transaction_action_id IN
	     (INV_GLOBALS.G_ACTION_LOGICALICSALES, INV_GLOBALS.G_ACTION_LOGICALICRECEIPT,
	      INV_GLOBALS.G_ACTION_LOGICALICRCPTRETURN, INV_GLOBALS.G_ACTION_LOGICALICSALESRETURN,
	      INV_GLOBALS.G_ACTION_LOGICALEXPREQRECEIPT))THEN

	    IF (p_mtl_trx_tbl(i).transfer_cost_group_id IS NULL) THEN
	       IF (l_debug = 1) THEN
		  debug_print('Invalid Cost Group in the Transfer Org.', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_CSTGRP');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	    l_count := 0;

            BEGIN
	       SELECT COUNT(1) INTO l_count
		 FROM CST_COST_GROUPS CCG
		 WHERE CCG.COST_GROUP_ID = p_mtl_trx_tbl(i).transfer_cost_group_id
		 AND NVL(CCG.ORGANIZATION_ID, p_mtl_trx_tbl(i).transfer_organization_id) = p_mtl_trx_tbl(i).transfer_organization_id
		 AND TRUNC(NVL(CCG.DISABLE_DATE,SYSDATE+1)) >= TRUNC(SYSDATE);
	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Cost Group not found', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_CSTGRP');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count = 0) THEN
	       IF (l_debug = 1) THEN
		  debug_print('Transfer Cost Group not found : ' || p_mtl_trx_tbl(i).transfer_cost_group_id , 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_CSTGRP');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;


	 END IF;

	 --18. Validate transaction batch id and transaction batch sequence

	 IF (p_mtl_trx_tbl(i).transaction_batch_id IS NULL) OR
	   (p_mtl_trx_tbl(i).transaction_batch_seq IS NULL )THEN
	    IF (l_debug = 1) THEN
	       debug_print('Transaction batch and sequence are not populated', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INVALID_BATCH');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

	 --19. If the locator is passed and it is project enabled, we would
	 -- have to make sure that the project and task is stamped on the line
	 --

	 IF (p_mtl_trx_tbl(i).locator_id IS NOT NULL) THEN

	    BEGIN
	       SELECT project_id, task_id INTO l_project_id, l_task_id FROM
		 mtl_item_locations WHERE inventory_location_id =
		 p_mtl_trx_tbl(i).locator_id AND organization_id =
		 p_mtl_trx_tbl(i).organization_id;
	    EXCEPTION
	       WHEN no_data_found THEN

		  IF (l_debug = 1) THEN
		     debug_print('Cannot find the locator information supplied', 9);
		  END IF;
	       WHEN others THEN
		  IF (l_debug = 1) THEN
		     debug_print('Invalid Locator ID', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_LOCCODE');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;


	    IF (l_project_id IS NOT NULL) THEN

	       IF (p_mtl_trx_tbl(i).project_id IS NULL) THEN
		  IF (l_debug = 1) THEN
		     debug_print('Invalid Project', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_NO_PROJECT');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;

	       END IF;

	    END IF;

	    IF (l_task_id IS NOT NULL) THEN

	       IF (p_mtl_trx_tbl(i).task_id IS NULL) then
		  IF (l_debug = 1) THEN
		     debug_print('Invalid Task', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_NO_PROJECT');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;

	       END IF;

	    END IF;

	 END IF;

	 -- Line level validation

	 -- 1. Validate the sales order that is passed for a logical sales
	 -- order issue transaction

	 l_count := 0;

	 IF ((p_mtl_trx_tbl(i).transaction_source_type_id = inv_globals.g_sourcetype_salesorder AND
	     p_mtl_trx_tbl(i).transaction_action_id = inv_globals.g_action_logicalissue) OR
	   (p_mtl_trx_tbl(i).transaction_source_type_id = inv_globals.g_sourcetype_rma AND
	    p_mtl_trx_tbl(i).transaction_action_id = inv_globals.g_action_logicalreceipt)) THEN

	    IF (p_mtl_trx_tbl(i).transaction_source_id IS NULL) THEN

	       IF (l_debug = 1) THEN
		  debug_print('Transaction Source ID is null', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_COULD_NOT_GET_MSO_HEADER');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;


	    BEGIN
	       SELECT COUNT(1) INTO l_count FROM
		 mtl_sales_orders WHERE
		 sales_order_id = p_mtl_trx_tbl(i).transaction_source_id;

	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Cannot find the sales order information', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_COULD_NOT_GET_MSO_HEADER');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN

	       IF (l_debug = 1) THEN
		  debug_print('Invalid sales order ID :' || p_mtl_trx_tbl(i).transaction_source_id, 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_COULD_NOT_GET_MSO_HEADER');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	 END IF;

	 -- 2. Validate the purchase order that is passed for a logical
	 -- po receipt or a logical RTV transaction

	 l_count := 0;

	 IF ((p_mtl_trx_tbl(i).transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder
	     AND p_mtl_trx_tbl(i).transaction_action_id = inv_globals.g_action_logicalreceipt) OR
	   (p_mtl_trx_tbl(i).transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder AND
	    p_mtl_trx_tbl(i).transaction_action_id =
	    inv_globals.g_action_logicalissue)) AND
	   (p_logical_trx_type_code = INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_DSRECEIPT) THEN

	    IF ((p_mtl_trx_tbl(i).transaction_source_id IS NULL) OR (p_mtl_trx_tbl(i).rcv_transaction_id IS NULL))  THEN

	       IF (l_debug = 1) THEN
		  debug_print('Transaction Source ID/rcv_transaction_id is null', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_PO');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	    BEGIN
	       SELECT COUNT(1) INTO l_count FROM
		 po_headers_all po, rcv_transactions rcv WHERE
		 po.po_header_id = rcv.po_header_id AND
		 po.po_header_id = p_mtl_trx_tbl(i).transaction_source_id  AND
		 rcv.transaction_id = p_mtl_trx_tbl(i).rcv_transaction_id AND
		 NVL(po.START_DATE_ACTIVE, SYSDATE - 1) <= Sysdate AND
		 NVL(po.END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE AND ENABLED_FLAG = 'Y';

	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Cannot find the purchase order information', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_INT_PO');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN

	       IF (l_debug = 1) THEN
		  debug_print('Invalid puchase order header ID :' || p_mtl_trx_tbl(i).transaction_source_id, 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_PO');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	 END IF;

	 -- 2. Validate the sales order line that is passed for a drop
	 -- shipment or a global procurement flow.

	 l_count := 0;

	 IF (p_logical_trx_type_code IN
	     (INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_DSDELIVER,
	      INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_RMASOISSUE)) THEN

	     IF (p_mtl_trx_tbl(i).trx_source_line_id IS NULL) THEN

	       IF (l_debug = 1) THEN
		  debug_print('Trx source line ID is null', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_COULD_NOT_GET_MSO_HEADER');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	     END IF;

	     BEGIN
	       SELECT COUNT(1) INTO l_count FROM
		 oe_order_lines_all WHERE
		 line_id = p_mtl_trx_tbl(i).trx_source_line_id;

	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     debug_print('Cannot find the sales order line information', 9);
		  END IF;
		  fnd_message.set_name('INV', 'INV_COULD_NOT_GET_MSO_HEADER');
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_count <> 1) THEN

	       IF (l_debug = 1) THEN
		  debug_print('Invalid sales order line :' || p_mtl_trx_tbl(i).transaction_source_id, 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_COULD_NOT_GET_MSO_HEADER');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;


	 END IF;

	 IF (p_mtl_trx_tbl(i).transaction_action_id IN
	     (inv_globals.g_action_logicalicsales,
	      inv_globals.g_action_logicalicreceipt,
	      inv_globals.g_action_logicalicrcptreturn,
	      inv_globals.g_action_logicalicsalesreturn)) THEN

	    IF (p_mtl_trx_tbl(i).invoiced_flag <> 'N') THEN

	       IF (l_debug = 1) THEN
		  debug_print('Invoiced flag is not set to N ', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_INVOICE_FLAG');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	    IF (p_mtl_trx_tbl(i).intercompany_cost IS NULL) OR
	      (p_mtl_trx_tbl(i).intercompany_cost < 0) THEN

	       IF (l_debug = 1) THEN
		  debug_print('I/C cost cannot be null ', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_INT_IC_COST');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;

	    END IF;

	 END IF;

	 IF (p_mtl_trx_tbl(i).costed_flag <> 'N') THEN

	    IF (l_debug = 1) THEN
	       debug_print('Costed flag is not set to N ', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INT_COSTED_FLAG');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	 END IF;

      END IF; -- If p_validation level set to true.


   END LOOP; -- for loop for every record in the table of records

   x_return_status := l_return_status;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
	 debug_print('Expected Error', 9);
	 debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
	 debug_print('Unexpected Error', 9);
	 debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 debug_print('Error Type Others', 9);
	 debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END validate_input_parameters;


/*==========================================================================*
 | Procedure : INV_MMT_INSERT                                               |
 |                                                                          |
 | Description : This API will be called by INV create logical transactions |
 |               API to do a bulk insert into MTL_MATERIAL_TRANSACTIONS     |
 |               table.                                                     |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_api_version_number - API version number                              |
 |   p_init_msg_lst       - Whether initialize the error message list or not|
 |                          Should be fnd_api.g_false or fnd_api.g_true     |
 |   p_mtl_trx_rec        - An array of mtl_trx_rec_type records            |
 |                                                                          |
 | Output Parameters :                                                      |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded         |
 |                          fnd_api.g_ret_sts_exc_error, if an expected     |
 |                          error occurred                                  |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected |
 |                          eror occurred                                   |
 |   x_msg_count          - Number of error message in the error message    |
 |                          list                                            |
 |   x_msg_data           - If the number of error message in the error     |
 |                          message list is one, the error message is in    |
 |                          this output parameter                           |
 *==========================================================================*/
   PROCEDURE inv_mmt_insert
   (
      x_return_status          OUT NOCOPY  VARCHAR2
    , x_msg_count              OUT NOCOPY  NUMBER
    , x_msg_data               OUT NOCOPY  VARCHAR2
    , p_api_version_number     IN          NUMBER
    , p_init_msg_lst           IN          VARCHAR2 DEFAULT fnd_api.g_false
    , p_mtl_trx_tbl            IN          inv_logical_transaction_global.mtl_trx_tbl_type
    , p_logical_trx_type_code  IN	   NUMBER


    )
   IS
      --  p_mtl_trx_tbl(i) inv_logical_transaction_global.mtl_trx_tbl_type := p_mtl_trx_tbl;
      l_debug NUMBER := NVL(fnd_profile.value('INV_DEBUG_TRACE'),0);
      l_api_version_number CONSTANT NUMBER         := 1.0;
      l_api_name           CONSTANT VARCHAR2(30)   := 'Inv_Mmt_Insert';
      l_logical_transaction NUMBER := 1;
      l_quantity_adjusted NUMBER := 0;
      l_transaction_quantity NUMBER := 0;
      l_primary_quantity NUMBER := 0;

      --
      -- Bug 5044147   umoogala   13-Feb-2006
      -- Issue: For process organizations, costed_flag is getting set to
      --        'N' instead of opm_costed_flag.
      -- Resolution: Added code to get mtl_parameters.process_enabled_flag.
      --             Then in insert stmt, setting the costed_flag's based on
      --             variable value.
      --
      l_prev_organization_id  BINARY_INTEGER := NULL;
      l_process_enabled_flag  VARCHAR2(1)    := NULL;

   BEGIN
      IF (l_debug = 1) THEN
        debug_print('Enter inv_mmt_insert', 9);
        debug_print('p_api_version_number = ' || p_api_version_number, 9);
        debug_print('p_init_msg_lst = ' || p_init_msg_lst, 9);
        debug_print('p_logical_trx_type_code = ' || p_logical_trx_type_code, 9);
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

      IF (p_logical_trx_type_code = INV_LOGICAL_TRANSACTIONS_PUB.G_LOGTRXCODE_RETROPRICEUPD) THEN
          l_logical_transaction := 2;
      ELSE
          l_logical_transaction := 1;
      END IF;


      IF (l_debug = 1) THEN
	 debug_print('Inside inv insert API', 9);
      END IF;

      FOR i in 1..p_mtl_trx_tbl.COUNT LOOP

	 IF (p_logical_trx_type_code = INV_LOGICAL_TRANSACTIONS_PUB.G_LOGTRXCODE_RETROPRICEUPD) THEN
	    l_quantity_adjusted := p_mtl_trx_tbl(i).transaction_quantity;
	    l_transaction_quantity := 0;
	    l_primary_quantity := 0;
	  ELSE
	    l_transaction_quantity := p_mtl_trx_tbl(i).transaction_quantity;
	    l_primary_quantity := p_mtl_trx_tbl(i).primary_quantity;
	    l_quantity_adjusted := NULL;
	 END IF;

         --
         -- Bug 5044147   umoogala   13-Feb-2006
         -- Issue: For process organizations, costed_flag is getting set to
         --        'N' instead of opm_costed_flag.
         -- Resolution: Added code to get mtl_parameters.process_enabled_flag.
         --             Then in insert stmt, setting the costed_flag's based on
         --             variable value.
         --
	 IF l_prev_organization_id IS NULL OR
	    p_mtl_trx_tbl(i).ORGANIZATION_ID <> l_prev_organization_id
	 THEN
	   l_prev_organization_id := p_mtl_trx_tbl(i).ORGANIZATION_ID;

           SELECT NVL(process_enabled_flag, 'N')
	     INTO l_process_enabled_flag
	     FROM mtl_parameters
	    WHERE organization_id = p_mtl_trx_tbl(i).ORGANIZATION_ID;
	 END IF;


	 INSERT
	   INTO   MTL_MATERIAL_TRANSACTIONS
	   ( TRANSACTION_ID
	     ,ORGANIZATION_ID
	     ,INVENTORY_ITEM_ID
             ,REVISION
	     ,SUBINVENTORY_CODE
	     ,LOCATOR_ID
	     ,TRANSACTION_TYPE_ID
	     ,TRANSACTION_ACTION_ID
	     ,TRANSACTION_SOURCE_TYPE_ID
	     ,TRANSACTION_SOURCE_ID
	     ,TRANSACTION_SOURCE_NAME
	     ,TRANSACTION_QUANTITY
	     ,TRANSACTION_UOM
	     ,PRIMARY_QUANTITY
	     ,TRANSACTION_DATE
	     ,ACCT_PERIOD_ID
	     ,DISTRIBUTION_ACCOUNT_ID
	     ,COSTED_FLAG
	     ,ACTUAL_COST
	     ,INVOICED_FLAG
	     ,TRANSACTION_COST
	     ,CURRENCY_CODE
	     ,CURRENCY_CONVERSION_RATE
	     ,CURRENCY_CONVERSION_TYPE
	     ,CURRENCY_CONVERSION_DATE
	     ,PM_COST_COLLECTED
	     ,TRX_SOURCE_LINE_ID
	     ,SOURCE_CODE
	     ,RCV_TRANSACTION_ID
	     ,SOURCE_LINE_ID
	     ,TRANSFER_ORGANIZATION_ID
	     ,TRANSFER_SUBINVENTORY
	     ,TRANSFER_LOCATOR_ID
	     ,COST_GROUP_ID
	     ,TRANSFER_COST_GROUP_ID
	     ,PROJECT_ID
	     ,TASK_ID
	     ,TO_PROJECT_ID
	     ,TO_TASK_ID
	     ,SHIP_TO_LOCATION_ID
	     ,TRANSACTION_MODE
	     ,TRANSACTION_BATCH_ID
	     ,TRANSACTION_BATCH_SEQ
	     ,TRX_FLOW_HEADER_ID
	     ,INTERCOMPANY_COST
             ,INTERCOMPANY_CURRENCY_CODE
	     ,INTERCOMPANY_PRICING_OPTION
	     ,parent_transaction_id
             ,lpn_id
	     ,logical_trx_type_code
             ,logical_transaction
	     ,last_update_date
	     ,last_updated_by
	     ,creation_date
	     ,created_by
	     ,last_update_login
	     ,quantity_adjusted
	     ,so_issue_account_type
	     ,opm_costed_flag
	   )
	   VALUES
	   (  p_mtl_trx_tbl(i).TRANSACTION_ID
	     ,p_mtl_trx_tbl(i).ORGANIZATION_ID
	     ,p_mtl_trx_tbl(i).INVENTORY_ITEM_ID
             ,p_mtl_trx_tbl(i).REVISION
	     ,p_mtl_trx_tbl(i).SUBINVENTORY_CODE
	     ,p_mtl_trx_tbl(i).LOCATOR_ID
	     ,p_mtl_trx_tbl(i).TRANSACTION_TYPE_ID
	     ,p_mtl_trx_tbl(i).TRANSACTION_ACTION_ID
	     ,p_mtl_trx_tbl(i).TRANSACTION_SOURCE_TYPE_ID
	     ,p_mtl_trx_tbl(i).TRANSACTION_SOURCE_ID
	     ,p_mtl_trx_tbl(i).TRANSACTION_SOURCE_NAME
	     ,l_transaction_quantity
	     ,p_mtl_trx_tbl(i).TRANSACTION_UOM
	     ,l_primary_quantity
	     ,p_mtl_trx_tbl(i).TRANSACTION_DATE
	     ,p_mtl_trx_tbl(i).ACCT_PERIOD_ID
	     ,p_mtl_trx_tbl(i).DISTRIBUTION_ACCOUNT_ID
	     ,decode(l_process_enabled_flag, 'N', p_mtl_trx_tbl(i).COSTED_FLAG, NULL)  -- Bug 5044147
	     ,p_mtl_trx_tbl(i).ACTUAL_COST
	     ,p_mtl_trx_tbl(i).INVOICED_FLAG
	     ,p_mtl_trx_tbl(i).TRANSACTION_COST
	     ,p_mtl_trx_tbl(i).CURRENCY_CODE
	     ,p_mtl_trx_tbl(i).CURRENCY_CONVERSION_RATE
	     ,p_mtl_trx_tbl(i).CURRENCY_CONVERSION_TYPE
	     ,p_mtl_trx_tbl(i).CURRENCY_CONVERSION_DATE
	     ,p_mtl_trx_tbl(i).PM_COST_COLLECTED
    	     ,p_mtl_trx_tbl(i).TRX_SOURCE_LINE_ID
  	     ,p_mtl_trx_tbl(i).SOURCE_CODE
	     ,p_mtl_trx_tbl(i).RCV_TRANSACTION_ID
	     ,p_mtl_trx_tbl(i).SOURCE_LINE_ID
  	     ,p_mtl_trx_tbl(i).TRANSFER_ORGANIZATION_ID
	     ,p_mtl_trx_tbl(i).TRANSFER_SUBINVENTORY
	     ,p_mtl_trx_tbl(i).TRANSFER_LOCATOR_ID
	     ,p_mtl_trx_tbl(i).COST_GROUP_ID
	     ,p_mtl_trx_tbl(i).TRANSFER_COST_GROUP_ID
	     ,p_mtl_trx_tbl(i).PROJECT_ID
	     ,p_mtl_trx_tbl(i).TASK_ID
	     ,p_mtl_trx_tbl(i).TO_PROJECT_ID
	     ,p_mtl_trx_tbl(i).TO_TASK_ID
	     ,p_mtl_trx_tbl(i).SHIP_TO_LOCATION_ID
	     ,p_mtl_trx_tbl(i).TRANSACTION_MODE
	     ,p_mtl_trx_tbl(i).TRANSACTION_BATCH_ID
	     ,p_mtl_trx_tbl(i).TRANSACTION_BATCH_SEQ
	     ,p_mtl_trx_tbl(i).TRX_FLOW_HEADER_ID
	     ,p_mtl_trx_tbl(i).INTERCOMPANY_COST
             ,p_mtl_trx_tbl(i).INTERCOMPANY_CURRENCY_CODE
	     ,p_mtl_trx_tbl(i).INTERCOMPANY_PRICING_OPTION
	     ,p_mtl_trx_tbl(i).parent_transaction_id
             ,p_mtl_trx_tbl(i).lpn_id
	     ,p_logical_trx_type_code
             ,l_logical_transaction
	     ,Sysdate
	     ,FND_GLOBAL.user_id
	     ,Sysdate
	     ,FND_GLOBAL.user_id
	     ,FND_GLOBAL.login_id
	     ,l_quantity_adjusted
	     ,2--deffered cogs
	     ,decode(l_process_enabled_flag, 'Y', 'N', NULL)  -- Bug 5044147
	   );

      END LOOP;

      x_return_status := fnd_api.g_ret_sts_success;
      IF (l_debug = 1) THEN
	 debug_print('After inv insert', 9);
	 debug_print('Return Status :' || x_return_status, 9);
      END IF;


   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 IF (l_debug = 1) THEN
	    debug_print('Expected Error', 9);
	    debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
	    debug_print('Return Status :' || x_return_status);
	 END IF;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 IF (l_debug = 1) THEN
	   debug_print('Expected Error', 9);
	   debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
	   debug_print('Return Status :' || x_return_status);
	 END IF;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF (l_debug = 1) THEN
	   debug_print('Error type others', 9);
	   debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
	   debug_print('Return Status :' || x_return_status);
	END IF;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data =>
				  x_msg_data);

   END inv_mmt_insert;

/*==========================================================================*
 | Procedure : INV_LOT_SERIAL_INSERT                                        |
 |                                                                          |
 | Description : This API will be called by INV create_logical_transactions |
 |               API to do a bulk insert into mtl_transaction_lot_numbers if|
 |               the item is lot control and insert into                    |
 |               mtl_unit_transactions if the item is serial control.       |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_api_version_number - API version number                              |
 |   p_init_msg_lst       - Whether initialize the error message list or not|
 |                          Should be fnd_api.g_false or fnd_api.g_true     |
 |   p_parent_transaction_id  - the transaction id of the parent transaction|
 |                              in mmt.                                     |
 |   p_transaction_id     - the transaction id of the new logical           |
 |                          transaction in mmt.                             |
 |   p_lot_control_code   - the lot control code of the item                |
 |   p_serial_control_code - the serial control code of the item            |
 |                                                                          |
 | Output Parameters :                                                      |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded         |
 |                          fnd_api.g_ret_sts_exc_error, if an expected     |
 |                          error occurred                                  |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected |
 |                          eror occurred                                   |
 |   x_msg_count          - Number of error message in the error message    |
 |                          list                                            |
 |   x_msg_data           - If the number of error message in the error     |
 |                          message list is one, the error message is in    |
 |                          this output parameter                           |
 *==========================================================================*/

   PROCEDURE inv_lot_serial_insert
    (
        x_return_status         OUT NOCOPY  VARCHAR2
      , x_msg_count             OUT NOCOPY  NUMBER
      , x_msg_data              OUT NOCOPY  VARCHAR2
      , p_api_version_number    IN          NUMBER := 1.0
      , p_init_msg_lst          IN          VARCHAR2 DEFAULT fnd_api.g_false
      , p_parent_transaction_id IN          NUMBER
      , p_transaction_id        IN          NUMBER
      , p_lot_control_code      IN          NUMBER
      , p_serial_control_code   IN          NUMBER
      , p_organization_id       IN          NUMBER
      , p_inventory_item_id     IN          NUMBER
      , p_primary_quantity      IN          NUMBER
      , p_trx_source_type_id    IN          NUMBER
      , p_revision              IN          VARCHAR2
    )
   IS
      l_debug NUMBER := NVL(fnd_profile.value('INV_DEBUG_TRACE'),0);
      l_api_version_number CONSTANT NUMBER         := 1.0;
      l_api_name           CONSTANT VARCHAR2(30)   := 'Inv_Mmt_Insert';
      l_serial_number_tbl VARCHAR30_TBL;
      l_return_status VARCHAR2(1);
      l_msg_count NUMBER;
      l_msg_data  VARCHAR2(2000);

      /* Bug 8530979: New variables to store the values from MMT */
      l_mmt_trx_qty        NUMBER;
      l_mmt_pri_qty        NUMBER;
      l_mmt_src_id         NUMBER;
      l_mmt_src_type_id    NUMBER;
      l_mmt_src_name       VARCHAR2(240);

      l_serial_transaction_id NUMBER;

      cursor mtln_cur(p_transaction_id NUMBER) IS
         SELECT INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                TRANSACTION_SOURCE_ID,
                TRANSACTION_SOURCE_TYPE_ID,
                TRANSACTION_SOURCE_NAME,
                TRANSACTION_QUANTITY,
                PRIMARY_QUANTITY,
                LOT_NUMBER,
                SERIAL_TRANSACTION_ID,
                DESCRIPTION,
                VENDOR_NAME,
                SUPPLIER_LOT_NUMBER,
                ORIGINATION_DATE,
                DATE_CODE,
                GRADE_CODE,
                CHANGE_DATE,
                MATURITY_DATE,
                STATUS_ID,
                RETEST_DATE,
                AGE,
                ITEM_SIZE,
                COLOR,
                VOLUME,
                VOLUME_UOM,
                PLACE_OF_ORIGIN,
                BEST_BY_DATE,
                LENGTH,
                LENGTH_UOM,
                WIDTH,
                WIDTH_UOM,
                RECYCLED_CONTENT,
                THICKNESS,
                THICKNESS_UOM,
                CURL_WRINKLE_FOLD,
                LOT_ATTRIBUTE_CATEGORY,
                C_ATTRIBUTE1,
                C_ATTRIBUTE2,
                C_ATTRIBUTE3,
                C_ATTRIBUTE4,
                C_ATTRIBUTE5,
                C_ATTRIBUTE6,
                C_ATTRIBUTE7,
                C_ATTRIBUTE8,
                C_ATTRIBUTE9,
                C_ATTRIBUTE10,
                C_ATTRIBUTE11,
                C_ATTRIBUTE12,
                C_ATTRIBUTE13,
                C_ATTRIBUTE14,
                C_ATTRIBUTE15,
                C_ATTRIBUTE16,
                C_ATTRIBUTE17,
                C_ATTRIBUTE18,
                C_ATTRIBUTE19,
                C_ATTRIBUTE20,
                D_ATTRIBUTE1,
                D_ATTRIBUTE2,
                D_ATTRIBUTE3,
                D_ATTRIBUTE4,
                D_ATTRIBUTE5,
                D_ATTRIBUTE6,
                D_ATTRIBUTE7,
                D_ATTRIBUTE8,
                D_ATTRIBUTE9,
                D_ATTRIBUTE10,
                N_ATTRIBUTE1,
                N_ATTRIBUTE2,
                N_ATTRIBUTE3,
                N_ATTRIBUTE4,
                N_ATTRIBUTE5,
                N_ATTRIBUTE6,
                N_ATTRIBUTE7,
                N_ATTRIBUTE8,
                N_ATTRIBUTE9,
                N_ATTRIBUTE10,
                VENDOR_ID,
                TERRITORY_CODE,
                PRODUCT_CODE,
                PRODUCT_TRANSACTION_ID,
                ATTRIBUTE_CATEGORY,
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
                ATTRIBUTE15
         FROM   mtl_transaction_lot_numbers
         WHERE  transaction_id = p_transaction_id;

   BEGIN

      IF (l_debug = 1) THEN
        debug_print('Enter inv_mmt_insert', 9);
        debug_print('p_api_version_number = ' || p_api_version_number, 9);
        debug_print('p_init_msg_lst = ' || p_init_msg_lst, 9);
        debug_print('p_parent_transaction_id = ' || p_parent_transaction_id, 9);
        debug_print('p_transaction_id = ' || p_transaction_id, 9);
        debug_print('p_lot_control_code = ' || p_lot_control_code, 9);
        debug_print('p_serial_control_code = ' || p_serial_control_code, 9);
      END IF;

      IF (p_lot_control_code = 2) THEN
         IF (p_serial_control_code in (2, 5, 6)) THEN
            SELECT mtl_material_transactions_s.nextval
            INTO   l_serial_transaction_id
            FROM   dual;
         ELSE
            l_serial_transaction_id := null;
         END IF;

         IF (l_debug = 1) THEN
            debug_print('l_serial_transaction_id = ' || l_serial_transaction_id, 9);
         END IF;

         For l_mtln IN mtln_cur(p_parent_transaction_id) LOOP
            IF (l_debug = 1) THEN
               debug_print('In the mtln_cur loop: lot_number = ' || l_mtln.lot_number, 9);
            END IF;

            /* Bug 8530979: Getting the quantities and source_id and
             * source_type_id from the corresponding MMT */
            begin
               select transaction_quantity,
                      primary_quantity,
                      transaction_source_id,
                      transaction_source_type_id,
                      transaction_source_name
               into   l_mmt_trx_qty,
                      l_mmt_pri_qty,
                      l_mmt_src_id,
                      l_mmt_src_type_id,
                      l_mmt_src_name
               from   mtl_material_transactions
               where  transaction_id = p_transaction_id;
            exception
               when others then
                   l_mmt_src_id := l_mtln.TRANSACTION_SOURCE_ID;
                   l_mmt_src_type_id := l_mtln.TRANSACTION_SOURCE_TYPE_ID;
                   l_mmt_src_name := l_mtln.TRANSACTION_SOURCE_NAME;
                   l_mmt_trx_qty := l_mtln.TRANSACTION_QUANTITY;
                   l_mmt_pri_qty := l_mtln.PRIMARY_QUANTITY;
            end;

            -- insert into mtln same as the one of parent transaction id
            -- with the logical intercompany issue type
            INSERT INTO mtl_transaction_lot_numbers
              ( TRANSACTION_ID
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,TRANSACTION_DATE
               ,TRANSACTION_SOURCE_ID
               ,TRANSACTION_SOURCE_TYPE_ID
               ,TRANSACTION_SOURCE_NAME
               ,TRANSACTION_QUANTITY
               ,PRIMARY_QUANTITY
               ,LOT_NUMBER
               ,SERIAL_TRANSACTION_ID
               ,DESCRIPTION
               ,VENDOR_NAME
               ,SUPPLIER_LOT_NUMBER
               ,ORIGINATION_DATE
               ,DATE_CODE
               ,GRADE_CODE
               ,CHANGE_DATE
               ,MATURITY_DATE
               ,STATUS_ID
               ,RETEST_DATE
               ,AGE
               ,ITEM_SIZE
               ,COLOR
               ,VOLUME
               ,VOLUME_UOM
               ,PLACE_OF_ORIGIN
               ,BEST_BY_DATE
               ,LENGTH
               ,LENGTH_UOM
               ,WIDTH
               ,WIDTH_UOM
               ,RECYCLED_CONTENT
               ,THICKNESS
               ,THICKNESS_UOM
               ,CURL_WRINKLE_FOLD
               ,LOT_ATTRIBUTE_CATEGORY
               ,C_ATTRIBUTE1
               ,C_ATTRIBUTE2
               ,C_ATTRIBUTE3
               ,C_ATTRIBUTE4
               ,C_ATTRIBUTE5
               ,C_ATTRIBUTE6
               ,C_ATTRIBUTE7
               ,C_ATTRIBUTE8
               ,C_ATTRIBUTE9
               ,C_ATTRIBUTE10
               ,C_ATTRIBUTE11
               ,C_ATTRIBUTE12
               ,C_ATTRIBUTE13
               ,C_ATTRIBUTE14
               ,C_ATTRIBUTE15
               ,C_ATTRIBUTE16
               ,C_ATTRIBUTE17
               ,C_ATTRIBUTE18
               ,C_ATTRIBUTE19
               ,C_ATTRIBUTE20
               ,D_ATTRIBUTE1
               ,D_ATTRIBUTE2
               ,D_ATTRIBUTE3
               ,D_ATTRIBUTE4
               ,D_ATTRIBUTE5
               ,D_ATTRIBUTE6
               ,D_ATTRIBUTE7
               ,D_ATTRIBUTE8
               ,D_ATTRIBUTE9
               ,D_ATTRIBUTE10
               ,N_ATTRIBUTE1
               ,N_ATTRIBUTE2
               ,N_ATTRIBUTE3
               ,N_ATTRIBUTE4
               ,N_ATTRIBUTE5
               ,N_ATTRIBUTE6
               ,N_ATTRIBUTE7
               ,N_ATTRIBUTE8
               ,N_ATTRIBUTE9
               ,N_ATTRIBUTE10
               ,VENDOR_ID
               ,TERRITORY_CODE
               ,PRODUCT_CODE
               ,PRODUCT_TRANSACTION_ID
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
              )
            VALUES(
                p_transaction_id
               ,SYSDATE
               ,FND_GLOBAL.user_id
               ,SYSDATE
               ,FND_GLOBAL.user_id
               ,FND_GLOBAL.login_id
               ,l_mtln.INVENTORY_ITEM_ID
               ,l_mtln.ORGANIZATION_ID
               ,SYSDATE
               /* Bug 8530979 */
               ,l_mmt_src_id
               ,l_mmt_src_type_id
               ,l_mmt_src_name
               ,sign(l_mmt_trx_qty)*abs(l_mtln.TRANSACTION_QUANTITY)
               ,sign(l_mmt_pri_qty)*abs(l_mtln.PRIMARY_QUANTITY)
               /* End Bug 8530979 */
               ,l_mtln.LOT_NUMBER
               ,l_serial_transaction_id
               ,l_mtln.DESCRIPTION
               ,l_mtln.VENDOR_NAME
               ,l_mtln.SUPPLIER_LOT_NUMBER
               ,l_mtln.ORIGINATION_DATE
               ,l_mtln.DATE_CODE
               ,l_mtln.GRADE_CODE
               ,l_mtln.CHANGE_DATE
               ,l_mtln.MATURITY_DATE
               ,l_mtln.STATUS_ID
               ,l_mtln.RETEST_DATE
               ,l_mtln.AGE
               ,l_mtln.ITEM_SIZE
               ,l_mtln.COLOR
               ,l_mtln.VOLUME
               ,l_mtln.VOLUME_UOM
               ,l_mtln.PLACE_OF_ORIGIN
               ,l_mtln.BEST_BY_DATE
               ,l_mtln.LENGTH
               ,l_mtln.LENGTH_UOM
               ,l_mtln.WIDTH
               ,l_mtln.WIDTH_UOM
               ,l_mtln.RECYCLED_CONTENT
               ,l_mtln.THICKNESS
               ,l_mtln.THICKNESS_UOM
               ,l_mtln.CURL_WRINKLE_FOLD
               ,l_mtln.LOT_ATTRIBUTE_CATEGORY
               ,l_mtln.C_ATTRIBUTE1
               ,l_mtln.C_ATTRIBUTE2
               ,l_mtln.C_ATTRIBUTE3
               ,l_mtln.C_ATTRIBUTE4
               ,l_mtln.C_ATTRIBUTE5
               ,l_mtln.C_ATTRIBUTE6
               ,l_mtln.C_ATTRIBUTE7
               ,l_mtln.C_ATTRIBUTE8
               ,l_mtln.C_ATTRIBUTE9
               ,l_mtln.C_ATTRIBUTE10
               ,l_mtln.C_ATTRIBUTE11
               ,l_mtln.C_ATTRIBUTE12
               ,l_mtln.C_ATTRIBUTE13
               ,l_mtln.C_ATTRIBUTE14
               ,l_mtln.C_ATTRIBUTE15
               ,l_mtln.C_ATTRIBUTE16
               ,l_mtln.C_ATTRIBUTE17
               ,l_mtln.C_ATTRIBUTE18
               ,l_mtln.C_ATTRIBUTE19
               ,l_mtln.C_ATTRIBUTE20
               ,l_mtln.D_ATTRIBUTE1
               ,l_mtln.D_ATTRIBUTE2
               ,l_mtln.D_ATTRIBUTE3
               ,l_mtln.D_ATTRIBUTE4
               ,l_mtln.D_ATTRIBUTE5
               ,l_mtln.D_ATTRIBUTE6
               ,l_mtln.D_ATTRIBUTE7
               ,l_mtln.D_ATTRIBUTE8
               ,l_mtln.D_ATTRIBUTE9
               ,l_mtln.D_ATTRIBUTE10
               ,l_mtln.N_ATTRIBUTE1
               ,l_mtln.N_ATTRIBUTE2
               ,l_mtln.N_ATTRIBUTE3
               ,l_mtln.N_ATTRIBUTE4
               ,l_mtln.N_ATTRIBUTE5
               ,l_mtln.N_ATTRIBUTE6
               ,l_mtln.N_ATTRIBUTE7
               ,l_mtln.N_ATTRIBUTE8
               ,l_mtln.N_ATTRIBUTE9
               ,l_mtln.N_ATTRIBUTE10
               ,l_mtln.VENDOR_ID
               ,l_mtln.TERRITORY_CODE
               ,l_mtln.PRODUCT_CODE
               ,l_mtln.PRODUCT_TRANSACTION_ID
               ,l_mtln.ATTRIBUTE_CATEGORY
               ,l_mtln.ATTRIBUTE1
               ,l_mtln.ATTRIBUTE2
               ,l_mtln.ATTRIBUTE3
               ,l_mtln.ATTRIBUTE4
               ,l_mtln.ATTRIBUTE5
               ,l_mtln.ATTRIBUTE6
               ,l_mtln.ATTRIBUTE7
               ,l_mtln.ATTRIBUTE8
               ,l_mtln.ATTRIBUTE9
               ,l_mtln.ATTRIBUTE10
               ,l_mtln.ATTRIBUTE11
               ,l_mtln.ATTRIBUTE12
               ,l_mtln.ATTRIBUTE13
               ,l_mtln.ATTRIBUTE14
               ,l_mtln.ATTRIBUTE15
              );

            -- If it's serial control and the serial_number_control_code is 2, 5
            -- then also insert into the mtl_unit_transactions
            -- serial_number_control_code = 2 -- Predefined serial numbers
            -- serial_number_control_code = 5 -- Dynamic entry at inventory receipt
            IF (p_serial_control_code in (2, 5)) THEN
               IF (l_debug = 1) THEN
                  debug_print('Before calling inv_mut_insert', 9);
                  debug_print('serial_transaction_id is ' || l_mtln.serial_transaction_id, 9);
               END IF;

               inv_mut_insert
                  (   x_return_status         => x_return_status,
                      x_msg_count             => x_msg_count,
                      x_msg_data              => x_msg_data,
                      x_serial_number_tbl     => l_serial_number_tbl,
                      p_parent_serial_trx_id  => l_mtln.serial_transaction_id,
                      p_serial_transaction_id => l_serial_transaction_id,
                      p_organization_id       => null,
                      p_inventory_item_id     => null,
                      p_trx_source_type_id    => null,
                      p_receipt_issue_type    => null);

               IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  IF (l_debug = 1) THEN
                     debug_print('generate_serial_number returns error: ' || x_msg_data, 9);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  IF (l_debug = 1) THEN
                     debug_print('inv_mut_insert returns unexpected error: ' || x_msg_data, 9);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

            ELSIF (p_serial_control_code = 6) THEN
               IF (l_debug = 1) THEN
                  debug_print('serial_transaction_id is ' || l_mtln.serial_transaction_id, 9);
               END IF;

               -- generate serial number with the primary lot qty
               generate_serial_numbers
                  (x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   x_ser_num_tbl   => l_serial_number_tbl,
                   p_org_id        => p_organization_id,
                   p_item_id       => p_inventory_item_id,
                   p_lot_number    => l_mtln.lot_number,
                   p_qty           => p_primary_quantity,
                   p_revision      => p_revision);

               IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  IF (l_debug = 1) THEN
                     debug_print('generate_serial_number returns error: ' || x_msg_data, 9);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  IF (l_debug = 1) THEN
                     debug_print('generate_serial_number returns unexpected error: ' || x_msg_data, 9);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;


               inv_mut_insert
                  (x_return_status         => x_return_status,
                   x_msg_count             => x_msg_count,
                   x_msg_data              => x_msg_data,
                   x_serial_number_tbl     => l_serial_number_tbl,
                   p_parent_serial_trx_id  => null,
                   p_serial_transaction_id => l_serial_transaction_id,
                   p_organization_id       => l_mtln.organization_id,
                   p_inventory_item_id     => l_mtln.inventory_item_id,
                   p_trx_source_type_id    => l_mtln.transaction_source_type_id,
                   p_receipt_issue_type    => 1);

               IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  IF (l_debug = 1) THEN
                     debug_print('inv_mut_insert returns error: ' || x_msg_data, 9);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  IF (l_debug = 1) THEN
                     debug_print('inv_mut_insert returns unexpected error: ' || x_msg_data, 9);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

            END IF;  -- end of if serial_control_code is in (2,5)
         END LOOP; -- end of loop l_mtln
      ELSE  -- not lot controll
         IF (l_debug = 1) THEN
            debug_print('It is not lot controlled', 9);
         END IF;

         IF (p_serial_control_code in (2,5)) THEN
            IF (l_debug = 1) THEN
               debug_print('serial_control_code is ' || p_serial_control_code, 9);
               debug_print('Before calling inv_mut_insert', 9);
            END IF;

            inv_mut_insert
               (  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data,
                  x_serial_number_tbl     => l_serial_number_tbl,
                  p_parent_serial_trx_id  => p_parent_transaction_id,
                  p_serial_transaction_id => p_transaction_id,
                  p_organization_id       => null,
                  p_inventory_item_id     => null,
                  p_trx_source_type_id    => null,
                  p_receipt_issue_type    => null);

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
               IF (l_debug = 1) THEN
                  debug_print('generate_serial_number returns error: ' || x_msg_data, 9);
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               IF (l_debug = 1) THEN
                  debug_print('inv_mut_insert returns unexpected error: ' || x_msg_data, 9);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

         ELSIF (p_serial_control_code = 6) THEN
            IF (l_debug = 1) THEN
               debug_print('Before calling generate_serial_numbers', 9);
               debug_print('serial_transaction_id is ' || p_transaction_id, 9);
            END IF;

            -- generate serial number with the primary lot qty
            generate_serial_numbers
               (x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                x_ser_num_tbl   => l_serial_number_tbl,
                p_org_id        => p_organization_id,
                p_item_id       => p_inventory_item_id,
                p_lot_number    => null,
                p_qty           => p_primary_quantity,
                p_revision      => p_revision);

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
               IF (l_debug = 1) THEN
                  debug_print('generate_serial_number returns error: ' || x_msg_data, 9);
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               IF (l_debug = 1) THEN
                  debug_print('generate_serial_number returns unexpected error: ' || x_msg_data, 9);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (l_debug = 1) THEN
               debug_print('generate_serial_numbers returns success', 9);
               debug_print('Before calling inv_mut_insert', 9);
               debug_print('p_serial_transaction_id = ' || p_transaction_id, 9);
            END IF;

            inv_mut_insert
               (x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                x_serial_number_tbl     => l_serial_number_tbl,
                p_parent_serial_trx_id  => null,
                p_serial_transaction_id => p_transaction_id,
                p_organization_id       => p_organization_id,
                p_inventory_item_id     => p_inventory_item_id,
                p_trx_source_type_id    => p_trx_source_type_id,
                p_receipt_issue_type    => 1);

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
               IF (l_debug = 1) THEN
                  debug_print('inv_mut_insert returns error: ' || x_msg_data, 9);
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               IF (l_debug = 1) THEN
                  debug_print('inv_mut_insert returns unexpected error: ' || x_msg_data, 9);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END IF; -- p_lot_control_code = 2

      IF (p_serial_control_code in (2, 5, 6)) THEN
         IF (l_debug = 1) THEN
            debug_print('serial_control_code = ' || p_serial_control_code, 9);
            debug_print('Before calling update_serial_numbers', 9);
         END IF;

         update_serial_numbers
            (x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_ser_num_tbl       => l_serial_number_tbl,
             p_organization_id   => p_organization_id,
             p_inventory_item_id => p_inventory_item_id);

         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            IF (l_debug = 1) THEN
               debug_print('update_serial_numbers returns error: ' || x_msg_data, 9);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            IF (l_debug = 1) THEN
               debug_print('update_serial_numbers returns unexpected error: ' || x_msg_data, 9);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      IF (l_debug = 1) THEN
         debug_print('Before returning from inv_lot_serial_insert', 9);
         debug_print('Return Status :' || x_return_status, 9);
      END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF (l_debug = 1) THEN
            debug_print('Expected Error', 9);
            debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
            debug_print('Return Status :' || x_return_status);
         END IF;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
           debug_print('Expected Error', 9);
           debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
           debug_print('Return Status :' || x_return_status);
         END IF;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 1) THEN
           debug_print('Error type others', 9);
           debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
           debug_print('Return Status :' || x_return_status);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data =>
                                  x_msg_data);
   END inv_lot_serial_insert;

   PROCEDURE generate_serial_numbers
    (
        x_return_status         OUT NOCOPY  VARCHAR2
      , x_msg_count             OUT NOCOPY  NUMBER
      , x_msg_data              OUT NOCOPY  VARCHAR2
      , x_ser_num_tbl           OUT NOCOPY  VARCHAR30_TBL
      , p_org_id                IN          NUMBER
      , p_item_id               IN          NUMBER
      , p_lot_number            IN          VARCHAR2
      , p_qty                   IN          NUMBER
      , p_revision              IN          VARCHAR2
    )
   IS
      l_debug NUMBER := NVL(fnd_profile.value('INV_DEBUG_TRACE'),0);
      l_start_ser VARCHAR2(30);
      l_end_ser   VARCHAR2(30);
      l_ser_prefix    VARCHAR2(30);
      l_from_ser_num VARCHAR2(30);
      l_to_ser_num   VARCHAR2(30);
      l_ser_suffix_length NUMBER;
      l_qty       VARCHAR2(30);
      l_number    NUMBER;
      l_errorcode NUMBER;
      l_retval    NUMBER;
      l_msg_data  VARCHAR2(2000);
   BEGIN
      IF (l_debug = 1) THEN
         debug_print('Enter generate_serial_numbers', 9);
         debug_print('p_org_id = ' || p_org_id, 9);
         debug_print('p_item_id = ' || p_item_id, 9);
         debug_print('p_lot_number = ' || p_lot_number, 9);
         debug_print('p_qty = ' || p_qty, 9);
         debug_print('p_revision = ' || p_revision, 9);
         debug_print('Before calling INV_SERIAL_NUMBER_PUB.generate_serials', 9);
      END IF;

      -- generate serial number with the primary lot qty
      l_retval := INV_SERIAL_NUMBER_PUB.generate_serials
         (p_org_id  => p_org_id,
          p_item_id => p_item_id,
          p_qty     => abs(p_qty),
          p_wip_id  => null,
          p_rev     => p_revision,
          p_lot     => p_lot_number,
          p_group_mark_id => null,
          p_line_mark_id  => null,
          x_start_ser   => l_start_ser,
          x_end_ser     => l_end_ser,
          x_proc_msg    => l_msg_data,
          p_skip_serial => null);

      IF (l_debug = 1) THEN
         debug_print('INV_SERIAL_NUMBER_PUB.generate_serials returns l_retval = '
                      || l_retval, 9);
         debug_print('l_start_ser = ' || l_start_ser, 9);
         debug_print('l_end_ser = ' || l_end_ser, 9);
         debug_print('Before calling MTL_SERIAL_CHECK.INV_SERIAL_INFO', 9);
      END IF;

      -- get the prefix and from number of the start serial number
      IF NOT MTL_SERIAL_CHECK.INV_SERIAL_INFO
                         (p_from_serial_number => l_start_ser,
                          p_to_serial_number   => l_end_ser,
                          x_prefix             => l_ser_prefix,
                          x_quantity           => l_qty,
                          x_from_number        => l_from_ser_num,
                          x_to_number          => l_to_ser_num,
                          x_errorcode          => l_errorcode) THEN

         IF (l_debug = 1) THEN
            debug_print('MTL_SERIAL_CHECK.INV_SERIAL_INFO returns error', 9);
            debug_print('error code: ' || l_errorcode, 9);
         END IF;

         FND_MESSAGE.SET_NAME('INV', 'INV_GET_SER_INFO_ERR');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 1) THEN
         debug_print('MTL_SERIAL_CHECK.INV_SERIAL_INFO returns true', 9);
         debug_print('l_ser_prefix = ' || l_ser_prefix, 9);
         debug_print('l_qty = ' || l_qty, 9);
         debug_print('l_from_ser_num = ' || l_from_ser_num, 9);
         debug_print('l_to_ser_num = ' || l_to_ser_num, 9);
      END IF;

      l_ser_suffix_length := LENGTH(l_from_ser_num);
      l_number := to_number(l_from_ser_num);
      FOR i in 1..l_qty LOOP
        x_ser_num_tbl(i) := l_ser_prefix || LPAD(TO_CHAR(l_number), l_ser_suffix_length, '0');
        l_number := l_number + 1;
        IF (l_debug = 1) THEN
           debug_print('serial number: ' || x_ser_num_tbl(i), 9);
        END IF;
      END LOOP;

      IF (x_ser_num_tbl(l_qty) <> l_end_ser) THEN
         IF (l_debug = 1) THEN
            debug_print('x_ser_num_tbl(l_qty) is ' || x_ser_num_tbl(l_qty), 9);
            debug_print('l_end_ser is ' || l_end_ser, 9);
         END IF;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      IF (l_debug = 1) THEN
         debug_print('Before return from generate_serial_numbers', 9);
         debug_print('Return Status :' || x_return_status, 9);
      END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF (l_debug = 1) THEN
            debug_print('Expected Error', 9);
            debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
            debug_print('Return Status :' || x_return_status);
         END IF;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
           debug_print('Expected Error', 9);
           debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
           debug_print('Return Status :' || x_return_status);
         END IF;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 1) THEN
           debug_print('Error type others', 9);
           debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
           debug_print('Return Status :' || x_return_status);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data =>
                                  x_msg_data);
   END generate_serial_numbers;

   PROCEDURE inv_mut_insert
    (
        x_return_status         OUT NOCOPY    VARCHAR2
      , x_msg_count             OUT NOCOPY    NUMBER
      , x_msg_data              OUT NOCOPY    VARCHAR2
      , x_serial_number_tbl     IN OUT NOCOPY VARCHAR30_TBL
      , p_parent_serial_trx_id  IN            NUMBER
      , p_serial_transaction_id IN            NUMBER
      , p_organization_id       IN            NUMBER
      , p_inventory_item_id     IN            NUMBER
      , p_trx_source_type_id    IN            NUMBER
      , p_receipt_issue_type    IN            NUMBER
    )
   IS
      l_debug NUMBER := NVL(fnd_profile.value('INV_DEBUG_TRACE'),0);
      l_index NUMBER := 0;
      cursor mut_cur(p_transaction_id NUMBER) IS
         SELECT SERIAL_NUMBER,
                INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                SUBINVENTORY_CODE,
                LOCATOR_ID,
                TRANSACTION_SOURCE_ID,
                TRANSACTION_SOURCE_TYPE_ID,
                TRANSACTION_SOURCE_NAME,
                RECEIPT_ISSUE_TYPE,
                CUSTOMER_ID,
                SHIP_ID,
                SERIAL_ATTRIBUTE_CATEGORY,
                ORIGINATION_DATE,
                C_ATTRIBUTE1,
                C_ATTRIBUTE2,
                C_ATTRIBUTE3,
                C_ATTRIBUTE4,
                C_ATTRIBUTE5,
                C_ATTRIBUTE6,
                C_ATTRIBUTE7,
                C_ATTRIBUTE8,
                C_ATTRIBUTE9,
                C_ATTRIBUTE10,
                C_ATTRIBUTE11,
                C_ATTRIBUTE12,
                C_ATTRIBUTE13,
                C_ATTRIBUTE14,
                C_ATTRIBUTE15,
                C_ATTRIBUTE16,
                C_ATTRIBUTE17,
                C_ATTRIBUTE18,
                C_ATTRIBUTE19,
                C_ATTRIBUTE20,
                D_ATTRIBUTE1,
                D_ATTRIBUTE2,
                D_ATTRIBUTE3,
                D_ATTRIBUTE4,
                D_ATTRIBUTE5,
                D_ATTRIBUTE6,
                D_ATTRIBUTE7,
                D_ATTRIBUTE8,
                D_ATTRIBUTE9,
                D_ATTRIBUTE10,
                N_ATTRIBUTE1,
                N_ATTRIBUTE2,
                N_ATTRIBUTE3,
                N_ATTRIBUTE4,
                N_ATTRIBUTE5,
                N_ATTRIBUTE6,
                N_ATTRIBUTE7,
                N_ATTRIBUTE8,
                N_ATTRIBUTE9,
                N_ATTRIBUTE10,
                STATUS_ID,
                TERRITORY_CODE,
                TIME_SINCE_NEW,
                CYCLES_SINCE_NEW,
                TIME_SINCE_OVERHAUL,
                CYCLES_SINCE_OVERHAUL,
                TIME_SINCE_REPAIR,
                CYCLES_SINCE_REPAIR,
                TIME_SINCE_VISIT,
                CYCLES_SINCE_VISIT,
                TIME_SINCE_MARK,
                CYCLES_SINCE_MARK,
                NUMBER_OF_REPAIRS,
                PRODUCT_CODE,
                PRODUCT_TRANSACTION_ID
         FROM   mtl_unit_transactions
         WHERE  transaction_id = p_transaction_id;
   BEGIN
      IF (l_debug = 1) THEN
         debug_print('Enter inv_mut_insert', 9);
         debug_print('p_parent_serial_trx_id = ' || p_parent_serial_trx_id, 9);
         debug_print('p_serial_transaction_id = ' || p_serial_transaction_id, 9);
         debug_print('p_organization_id = ' || p_organization_id, 9);
         debug_print('p_inventory_item_id = ' || p_inventory_item_id, 9);
         debug_print('p_trx_source_type_id = ' || p_trx_source_type_id, 9);
         debug_print('p_receipt_issue_type = ' || p_receipt_issue_type, 9);
      END IF;

      IF (p_parent_serial_trx_id IS NOT NULL OR p_parent_serial_trx_id > 0) THEN
         FOR l_mut in mut_cur(p_parent_serial_trx_id) LOOP
            INSERT INTO mtl_unit_transactions
              (
                TRANSACTION_ID
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,SERIAL_NUMBER
               ,INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,SUBINVENTORY_CODE
               ,LOCATOR_ID
               ,TRANSACTION_DATE
               ,TRANSACTION_SOURCE_ID
               ,TRANSACTION_SOURCE_TYPE_ID
               ,TRANSACTION_SOURCE_NAME
               ,RECEIPT_ISSUE_TYPE
               ,CUSTOMER_ID
               ,SHIP_ID
               ,SERIAL_ATTRIBUTE_CATEGORY
               ,ORIGINATION_DATE
               ,C_ATTRIBUTE1
               ,C_ATTRIBUTE2
               ,C_ATTRIBUTE3
               ,C_ATTRIBUTE4
               ,C_ATTRIBUTE5
               ,C_ATTRIBUTE6
               ,C_ATTRIBUTE7
               ,C_ATTRIBUTE8
               ,C_ATTRIBUTE9
               ,C_ATTRIBUTE10
               ,C_ATTRIBUTE11
               ,C_ATTRIBUTE12
               ,C_ATTRIBUTE13
               ,C_ATTRIBUTE14
               ,C_ATTRIBUTE15
               ,C_ATTRIBUTE16
               ,C_ATTRIBUTE17
               ,C_ATTRIBUTE18
               ,C_ATTRIBUTE19
               ,C_ATTRIBUTE20
               ,D_ATTRIBUTE1
               ,D_ATTRIBUTE2
               ,D_ATTRIBUTE3
               ,D_ATTRIBUTE4
               ,D_ATTRIBUTE5
               ,D_ATTRIBUTE6
               ,D_ATTRIBUTE7
               ,D_ATTRIBUTE8
               ,D_ATTRIBUTE9
               ,D_ATTRIBUTE10
               ,N_ATTRIBUTE1
               ,N_ATTRIBUTE2
               ,N_ATTRIBUTE3
               ,N_ATTRIBUTE4
               ,N_ATTRIBUTE5
               ,N_ATTRIBUTE6
               ,N_ATTRIBUTE7
               ,N_ATTRIBUTE8
               ,N_ATTRIBUTE9
               ,N_ATTRIBUTE10
               ,STATUS_ID
               ,TERRITORY_CODE
               ,TIME_SINCE_NEW
               ,CYCLES_SINCE_NEW
               ,TIME_SINCE_OVERHAUL
               ,CYCLES_SINCE_OVERHAUL
               ,TIME_SINCE_REPAIR
               ,CYCLES_SINCE_REPAIR
               ,TIME_SINCE_VISIT
               ,CYCLES_SINCE_VISIT
               ,TIME_SINCE_MARK
               ,CYCLES_SINCE_MARK
               ,NUMBER_OF_REPAIRS
               ,PRODUCT_CODE
               ,PRODUCT_TRANSACTION_ID
              )
           VALUES
              (
                p_serial_transaction_id
               ,SYSDATE
               ,FND_GLOBAL.user_id
               ,SYSDATE
               ,FND_GLOBAL.user_id
               ,FND_GLOBAL.login_id
               ,l_mut.SERIAL_NUMBER
               ,l_mut.INVENTORY_ITEM_ID
               ,l_mut.ORGANIZATION_ID
               ,l_mut.SUBINVENTORY_CODE
               ,l_mut.LOCATOR_ID
               ,SYSDATE
               ,l_mut.TRANSACTION_SOURCE_ID
               ,l_mut.TRANSACTION_SOURCE_TYPE_ID
               ,l_mut.TRANSACTION_SOURCE_NAME
               ,l_mut.RECEIPT_ISSUE_TYPE
               ,l_mut.CUSTOMER_ID
               ,l_mut.SHIP_ID
               ,l_mut.SERIAL_ATTRIBUTE_CATEGORY
               ,l_mut.ORIGINATION_DATE
               ,l_mut.C_ATTRIBUTE1
               ,l_mut.C_ATTRIBUTE2
               ,l_mut.C_ATTRIBUTE3
               ,l_mut.C_ATTRIBUTE4
               ,l_mut.C_ATTRIBUTE5
               ,l_mut.C_ATTRIBUTE6
               ,l_mut.C_ATTRIBUTE7
               ,l_mut.C_ATTRIBUTE8
               ,l_mut.C_ATTRIBUTE9
               ,l_mut.C_ATTRIBUTE10
               ,l_mut.C_ATTRIBUTE11
               ,l_mut.C_ATTRIBUTE12
               ,l_mut.C_ATTRIBUTE13
               ,l_mut.C_ATTRIBUTE14
               ,l_mut.C_ATTRIBUTE15
               ,l_mut.C_ATTRIBUTE16
               ,l_mut.C_ATTRIBUTE17
               ,l_mut.C_ATTRIBUTE18
               ,l_mut.C_ATTRIBUTE19
               ,l_mut.C_ATTRIBUTE20
               ,l_mut.D_ATTRIBUTE1
               ,l_mut.D_ATTRIBUTE2
               ,l_mut.D_ATTRIBUTE3
               ,l_mut.D_ATTRIBUTE4
               ,l_mut.D_ATTRIBUTE5
               ,l_mut.D_ATTRIBUTE6
               ,l_mut.D_ATTRIBUTE7
               ,l_mut.D_ATTRIBUTE8
               ,l_mut.D_ATTRIBUTE9
               ,l_mut.D_ATTRIBUTE10
               ,l_mut.N_ATTRIBUTE1
               ,l_mut.N_ATTRIBUTE2
               ,l_mut.N_ATTRIBUTE3
               ,l_mut.N_ATTRIBUTE4
               ,l_mut.N_ATTRIBUTE5
               ,l_mut.N_ATTRIBUTE6
               ,l_mut.N_ATTRIBUTE7
               ,l_mut.N_ATTRIBUTE8
               ,l_mut.N_ATTRIBUTE9
               ,l_mut.N_ATTRIBUTE10
               ,l_mut.STATUS_ID
               ,l_mut.TERRITORY_CODE
               ,l_mut.TIME_SINCE_NEW
               ,l_mut.CYCLES_SINCE_NEW
               ,l_mut.TIME_SINCE_OVERHAUL
               ,l_mut.CYCLES_SINCE_OVERHAUL
               ,l_mut.TIME_SINCE_REPAIR
               ,l_mut.CYCLES_SINCE_REPAIR
               ,l_mut.TIME_SINCE_VISIT
               ,l_mut.CYCLES_SINCE_VISIT
               ,l_mut.TIME_SINCE_MARK
               ,l_mut.CYCLES_SINCE_MARK
               ,l_mut.NUMBER_OF_REPAIRS
               ,l_mut.PRODUCT_CODE
               ,l_mut.PRODUCT_TRANSACTION_ID
              );

            l_index := l_index + 1;
            x_serial_number_tbl(l_index) := l_mut.serial_number;
         END LOOP; -- end of loop l_mut
      ELSE
         forall i IN 1..x_serial_number_tbl.COUNT
            INSERT INTO mtl_unit_transactions
               (
                 TRANSACTION_ID
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_LOGIN
                ,SERIAL_NUMBER
                ,INVENTORY_ITEM_ID
                ,ORGANIZATION_ID
                ,TRANSACTION_SOURCE_TYPE_ID
                ,RECEIPT_ISSUE_TYPE
                ,TRANSACTION_DATE
               )
            VALUES
               (
                 p_serial_transaction_id
                ,SYSDATE
                ,FND_GLOBAL.user_id
                ,SYSDATE
                ,FND_GLOBAL.user_id
                ,FND_GLOBAL.login_id
                ,x_serial_number_tbl(i)
                ,p_inventory_item_id
                ,p_organization_id
                ,p_trx_source_type_id
                ,p_receipt_issue_type
                ,SYSDATE
               );
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      IF (l_debug = 1) THEN
         debug_print('Before return from inv_mut_insert', 9);
         debug_print('Return Status :' || x_return_status, 9);
      END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF (l_debug = 1) THEN
            debug_print('Expected Error', 9);
            debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
            debug_print('Return Status :' || x_return_status);
         END IF;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
           debug_print('Expected Error', 9);
           debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
           debug_print('Return Status :' || x_return_status);
         END IF;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 1) THEN
           debug_print('Error type others', 9);
           debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
           debug_print('Return Status :' || x_return_status);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data =>
                                  x_msg_data);

   END inv_mut_insert;

   PROCEDURE update_serial_numbers
    (
        x_return_status         OUT NOCOPY  VARCHAR2
      , x_msg_count             OUT NOCOPY  NUMBER
      , x_msg_data              OUT NOCOPY  VARCHAR2
      , p_ser_num_tbl           IN          VARCHAR30_TBL
      , p_organization_id       IN          NUMBER
      , p_inventory_item_id     IN          NUMBER
    )
   IS
      l_debug NUMBER := NVL(fnd_profile.value('INV_DEBUG_TRACE'),0);
   BEGIN
      IF (l_debug = 1) THEN
         debug_print('Enter update_serial_numbers', 9);
         debug_print('p_organization_id = ' || p_organization_id, 9);
         debug_print('p_invventory_item_id = ' || p_inventory_item_id, 9);
      END IF;

      forall i in p_ser_num_tbl.FIRST..p_ser_num_tbl.LAST
         UPDATE mtl_serial_numbers
         SET    current_status = 4
         WHERE  current_organization_id = p_organization_id
         AND    serial_number = p_ser_num_tbl(i)
         AND    inventory_item_id = p_inventory_item_id;

      IF (SQL%ROWCOUNT <> p_ser_num_tbl.COUNT) THEN
         IF (l_debug = 1) THEN
            debug_print('The number of rows updated in mtl_serial_numbers is not equals
                         to the number of serial numbers that needed to be updated', 9);
         END IF;
      END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF (l_debug = 1) THEN
            debug_print('Expected Error', 9);
            debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
            debug_print('Return Status :' || x_return_status);
         END IF;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
           debug_print('Expected Error', 9);
           debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
           debug_print('Return Status :' || x_return_status);
         END IF;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 1) THEN
           debug_print('Error type others', 9);
           debug_print('SQL Error: ' || Sqlerrm(SQLCODE),1);
           debug_print('Return Status :' || x_return_status);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data =>
                                  x_msg_data);
   END update_serial_numbers;

END inv_logical_transactions_pvt;


/
