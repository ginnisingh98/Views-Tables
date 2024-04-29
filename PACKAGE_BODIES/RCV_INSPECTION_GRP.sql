--------------------------------------------------------
--  DDL for Package Body RCV_INSPECTION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_INSPECTION_GRP" AS
/* $Header: rcvginsb.pls 120.8.12010000.3 2008/10/27 07:15:09 sdpaul ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='RCV_INSPECTION_GRP';
G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;

PROCEDURE Insert_Inspection
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER	 :=
					FND_API.G_VALID_LEVEL_FULL	,
	p_created_by		IN	NUMBER				,
	p_last_updated_by	IN	NUMBER				,
	p_last_update_login	IN	NUMBER				,
	p_employee_id		IN	NUMBER				,
	p_group_id		    IN	NUMBER				,
	p_transaction_id	IN	NUMBER				,
	p_transaction_type	IN	VARCHAR2			,
	p_processing_mode	IN	VARCHAR2 			,
        p_quantity		    IN 	NUMBER   			,
        p_uom			    IN 	VARCHAR2			,
        p_quality_code		IN 	VARCHAR2 := NULL	,
        p_transaction_date	IN	DATE				,
        p_comments		    IN 	VARCHAR2 := NULL	,
        p_reason_id		    IN 	NUMBER	 := NULL	,
        p_vendor_lot		IN	VARCHAR2 := NULL	,
	p_qa_collection_id	IN	NUMBER				,
        p_lpn_id                IN      NUMBER := NULL       ,
        p_transfer_lpn_id       IN      NUMBER := NULL       ,
        p_from_subinventory     IN      VARCHAR2             ,  -- Added bug # 6529950
	p_from_locator_id       IN      NUMBER               ,  -- Added bug # 6529950
	p_subinventory          IN      VARCHAR2             ,  -- Added bug # 6529950
	p_locator_id            IN      NUMBER               ,  -- Added bug # 6529950
	p_return_status		OUT	NOCOPY VARCHAR2	  	,
	p_msg_count		OUT	NOCOPY NUMBER		,
	p_msg_data		OUT	NOCOPY VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'Insert_Inspection';
l_api_version           	CONSTANT NUMBER 	:= 1.1;

--BUG 5219112. Replace the view RCV_TRANSACTIONS_V with base tables
/*CURSOR C1 IS
  SELECT RTV.RECEIPT_SOURCE_CODE,
	 RTV.SOURCE_DOCUMENT_CODE,
	 RTV.SHIPMENT_HEADER_ID,
	 RTV.SHIPMENT_LINE_ID,
	 RTV.SUBSTITUTE_UNORDERED_CODE,
 	 RTV.RCV_TRANSACTION_ID,
	 RTV.PO_HEADER_ID,
	 RTV.PO_RELEASE_ID,
	 RTV.PO_LINE_ID,
	 RTV.PO_LINE_LOCATION_ID,
	 RTV.PO_DISTRIBUTION_ID,
	 RTV.PO_REVISION_NUM,
	 RTV.PO_UNIT_PRICE,
	 RTV.CURRENCY_CODE,
	 RTV.CURRENCY_CONVERSION_RATE,
	 RTV.REQ_LINE_ID,
	 RTV.REQ_DISTRIBUTION_ID,
	 RTV.ROUTING_ID,
	 RTV.ROUTING_STEP_ID,
	 RTV.LOCATION_ID,
	 RTV.CATEGORY_ID,
	 RTV.PRIMARY_UOM,
	 RTV.ITEM_ID,
	 RTV.ITEM_REVISION,
	 RTV.TO_ORGANIZATION_ID,
	 RTV.DELIVER_TO_LOCATION_ID,
	 RTV.VENDOR_ID,
         RTV.VENDOR_SITE_ID,  --Bug 2114669 Also fetching vendor_site_id
	 RTV.LOT_CONTROL_CODE,
	 RTV.SERIAL_NUMBER_CONTROL_CODE,
	 RTV.CURRENCY_CONVERSION_DATE,
         RTV.CURRENCY_CONVERSION_TYPE,
         RTV.OE_ORDER_HEADER_ID,
         RTV.OE_ORDER_NUM,
         RTV.OE_ORDER_LINE_ID,
         RTV.OE_ORDER_LINE_NUM,
         RTV.CUSTOMER_ID,
         RTV.CUSTOMER_SITE_ID,
         RTV.CUSTOMER_ITEM_NUM,
         -- Bug# 1548597
         RTV.SECONDARY_QUANTITY,
         RTV.SECONDARY_UNIT_OF_MEASURE,
         RTV.ORG_ID  --<R12 MOAC>
  FROM RCV_TRANSACTIONS_V RTV
  WHERE RTV.RCV_TRANSACTION_ID = p_transaction_id;
*/

  /* Bug# 7440432
   * Modified the below cursor query to also join with
   * PO_REQUISITION_HEADERS_ALL table and fetch the operating_unit_id
   * as ORG_ID for requisitions
   */

  CURSOR C1 IS
  SELECT  RSH.RECEIPT_SOURCE_CODE
        , RT.SOURCE_DOCUMENT_CODE
        , RSUP.SHIPMENT_HEADER_ID
        , RSUP.SHIPMENT_LINE_ID
        , RT.SUBSTITUTE_UNORDERED_CODE
        , RSUP.RCV_TRANSACTION_ID
        , RSUP.PO_HEADER_ID
        , RSUP.PO_RELEASE_ID
        , RSUP.PO_LINE_ID
        , RSUP.PO_LINE_LOCATION_ID
        , RT.PO_DISTRIBUTION_ID
        , RT.PO_REVISION_NUM
        , NVL(PLL.PRICE_OVERRIDE, POL.UNIT_PRICE) PO_UNIT_PRICE
        , RT.CURRENCY_CODE
        , RT.CURRENCY_CONVERSION_RATE
        , RSUP.REQ_LINE_ID
        , RSL.REQ_DISTRIBUTION_ID
        , RT.ROUTING_HEADER_ID ROUTING_ID
        , RT.ROUTING_STEP_ID
        , RT.LOCATION_ID
        , RSL.CATEGORY_ID
        , RT.PRIMARY_UNIT_OF_MEASURE PRIMARY_UOM
        , RSUP.ITEM_ID
        , RSUP.ITEM_REVISION
        , RSUP.TO_ORGANIZATION_ID
        , RSL.DELIVER_TO_LOCATION_ID
        , RSH.VENDOR_ID
        , RT.VENDOR_SITE_ID
        , MSI.LOT_CONTROL_CODE LOT_CONTROL_CODE
        , MSI.SERIAL_NUMBER_CONTROL_CODE SERIAL_NUMBER_CONTROL_CODE
        , RT.CURRENCY_CONVERSION_DATE
        , RT.CURRENCY_CONVERSION_TYPE
        , RSUP.OE_ORDER_HEADER_ID
        , OEH.ORDER_NUMBER OE_ORDER_NUM
        , RSUP.OE_ORDER_LINE_ID
        , OEL.LINE_NUMBER OE_ORDER_LINE_NUM
        , RSH.CUSTOMER_ID
        , RSH.CUSTOMER_SITE_ID
        , decode(oel.item_identifier_type, 'CUST', MCI.CUSTOMER_ITEM_NUMBER, '') CUSTOMER_ITEM_NUM
        , RT.SECONDARY_QUANTITY
        , RT.SECONDARY_UNIT_OF_MEASURE
        , DECODE(RT.SOURCE_DOCUMENT_CODE, 'PO', PLL.ORG_ID, 'RMA', OEH.ORG_ID, 'REQ', PRHA.ORG_ID, NULL) ORG_ID  -- Bug# 7440432
        , POL.UNIT_MEAS_LOOKUP_CODE --Done to merge C3 into C1
        , RT.ATTRIBUTE_CATEGORY -- Bug 6365501: Start
        , RT.ATTRIBUTE1
        , RT.ATTRIBUTE2
        , RT.ATTRIBUTE3
        , RT.ATTRIBUTE4
        , RT.ATTRIBUTE5
        , RT.ATTRIBUTE6
        , RT.ATTRIBUTE7
        , RT.ATTRIBUTE8
        , RT.ATTRIBUTE9
        , RT.ATTRIBUTE10
        , RT.ATTRIBUTE11
        , RT.ATTRIBUTE12
        , RT.ATTRIBUTE13
        , RT.ATTRIBUTE14
        , RT.ATTRIBUTE15          -- Bug 6365501: End
        , RT.LCM_SHIPMENT_LINE_ID -- lcm changes
        , RT.UNIT_LANDED_COST     -- lcm changes
        FROM
        RCV_SUPPLY RSUP       ,
        RCV_SHIPMENT_LINES RSL,
        RCV_TRANSACTIONS RT   ,
        RCV_SHIPMENT_HEADERS RSH,
        PO_LINES_ALL POL,
        PO_LINE_LOCATIONS_ALL PLL,
        MTL_SYSTEM_ITEMS MSI,
        OE_ORDER_LINES_ALL  OEL,
        OE_ORDER_HEADERS_ALL  OEH,
        MTL_CUSTOMER_ITEMS MCI,
        PO_REQUISITION_HEADERS_ALL PRHA  -- Bug# 7440432
        WHERE  RT.TRANSACTION_ID          = RSUP.RCV_TRANSACTION_ID
        AND    RSUP.SUPPLY_TYPE_CODE      = 'RECEIVING'
        AND    RSL.SHIPMENT_LINE_ID       = RSUP.SHIPMENT_LINE_ID
        AND    RSH.SHIPMENT_HEADER_ID     = RSUP.SHIPMENT_HEADER_ID
        AND    RT.TRANSACTION_TYPE        <> 'UNORDERED'
        AND    POL.PO_LINE_ID(+)          = RSUP.PO_LINE_ID
        AND    PLL.LINE_LOCATION_ID(+)    = RSUP.PO_LINE_LOCATION_ID
        AND    OEL.LINE_ID(+)             = RSUP.OE_ORDER_LINE_ID
        AND    OEH.HEADER_ID(+)           = RSUP.OE_ORDER_HEADER_ID
        AND    OEL.ORDERED_ITEM_ID        = MCI.CUSTOMER_ITEM_ID(+)
        AND PRHA.REQUISITION_HEADER_ID(+) = RSUP.REQ_HEADER_ID  -- Bug# 7440432
        AND    MSI.ORGANIZATION_ID(+)     = RSUP.TO_ORGANIZATION_ID
        AND    MSI.INVENTORY_ITEM_ID(+)   = RSUP.ITEM_ID
        AND    RSUP.RCV_TRANSACTION_ID    = P_TRANSACTION_ID
        AND    NVL(PLL.MATCHING_BASIS(+),'QUANTITY')  <> 'AMOUNT'
        AND    PLL.PAYMENT_TYPE IS NULL;

  -- End Bug# 7440432

  RCVT		C1%ROWTYPE;
   --START BUG 5219112
   --REMOVE CURSOR C2 AND MERGE C3 WITH C1
    /*
    CURSOR C2 IS
    SELECT MOVEMENT_ID
    FROM RCV_TRANSACTIONS
    WHERE TRANSACTION_ID = p_transaction_id;

    CURSOR C3(X_PO_LINE_ID NUMBER) IS
    SELECT UNIT_MEAS_LOOKUP_CODE
    FROM PO_LINES
    WHERE PO_LINE_ID = X_PO_LINE_ID;
    */
    --END BUG 5219112
  l_inspection_status_code 	VARCHAR2(30);
  --l_movement_id 	   	NUMBER; Not being used anywhere in the code
  l_rowid		   	VARCHAR2(30);
  l_interface_id 	   	NUMBER;
  l_source_doc_uom 		VARCHAR2(25):=NULL;
  l_source_doc_quantity		NUMBER;
  l_primary_quantity		NUMBER;

  -- Bug 5018102
  l_project_id                  RCV_TRANSACTIONS_INTERFACE.PROJECT_ID%TYPE;
  l_task_id                     RCV_TRANSACTIONS_INTERFACE.TASK_ID%TYPE;
BEGIN

	--dbms_output.enable('1000000');
	-- Standard Start of API savepoint
    	SAVEPOINT	INSPECTION_GRP;
    	-- Standard call to check for call compatibility.
   	IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
        p_return_status := FND_API.G_RET_STS_SUCCESS;

	if p_transaction_type = 'ACCEPT' then
	  l_inspection_status_code := 'ACCEPTED';
	elsif p_transaction_type = 'REJECT' then
	  l_inspection_status_code := 'REJECTED';
  	else
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	end if;

	OPEN C1;
	FETCH C1 INTO RCVT;
	CLOSE C1;
	--START BUG 5219112
	--REMOVE CURSOR C2 AND MERGE C3 WITH C1
	/*OPEN C2;
	FETCH C2 INTO l_movement_id;
	CLOSE C2;

        OPEN C3(RCVT.PO_LINE_ID);
	FETCH C3 INTO l_source_doc_uom;
	CLOSE C3;
	*/
	--Populate l_source_doc_uom from C1 only.
	--Don't populate l_movement_id as it is not being used anywhere in the code
	l_source_doc_uom := RCVT.UNIT_MEAS_LOOKUP_CODE;
	--END BUG 5219112

	-- Convert to primary quantity
	PO_UOM_S.UOM_CONVERT(p_quantity,
			     p_uom,
			     RCVT.ITEM_ID,
			     RCVT.primary_uom,
			     l_primary_quantity);

	-- Convert to source document quantity
        IF l_source_doc_uom IS NOT NULL THEN
          PO_UOM_S.UOM_CONVERT(p_quantity,
			     p_uom,
			     RCVT.ITEM_ID,
			     l_source_doc_uom,
			     l_source_doc_quantity);
	END IF;

        RCV_TRX_INTERFACE_INSERT_PKG.INSERT_ROW(
		       X_Rowid 				=> l_Rowid,
                       X_Interface_Transaction_Id       => l_interface_id,
                       X_Group_Id                       => p_group_id,
                       X_Last_Update_Date               => sysdate,
                       X_Last_Updated_By                => p_last_updated_by,
                       X_Creation_Date                  => sysdate,
                       X_Created_By                     => p_created_by,
                       X_Last_Update_Login              => p_last_update_login,
                       X_Transaction_Type               => p_transaction_type,
                       X_Transaction_Date               => p_transaction_date,
                       X_Processing_Status_Code         => 'PENDING',
                       X_Processing_Mode_Code           => p_processing_mode,
                       X_Processing_Request_Id          => NULL,
                       X_Transaction_Status_Code        => 'PENDING',
                       X_Category_Id                    => RCVT.CATEGORY_ID,
                       X_Quantity                       => p_quantity,
                       X_Unit_Of_Measure                => p_uom,
                       X_Interface_Source_Code          => 'RCV',
                       X_Interface_Source_Line_Id       => NULL,
                       X_Inv_Transaction_Id             => NULL,
                       X_Item_Id                        => RCVT.ITEM_ID,
                       X_Item_Description               => NULL,
                       X_Item_Revision                  => RCVT.ITEM_REVISION,
                       X_Uom_Code                       => NULL,
                       X_Employee_Id                    => p_employee_id,
                       X_Auto_Transact_Code             => NULL,
                       X_Shipment_Header_Id             => RCVT.SHIPMENT_HEADER_ID,
                       X_Shipment_Line_Id               => RCVT.SHIPMENT_LINE_ID,
                       X_Ship_To_Location_Id            => NULL,
                       X_Primary_Quantity               => l_primary_quantity,
                       X_Primary_Unit_Of_Measure        => RCVT.PRIMARY_UOM,
                       X_Receipt_Source_Code            => RCVT.RECEIPT_SOURCE_CODE,
                       X_Vendor_Id                      => RCVT.VENDOR_ID,
                       X_Vendor_Site_Id                 => RCVT.VENDOR_SITE_ID, /* 2114669 Passing vendor_site_id from cursor RCVT */
                       X_From_Organization_Id           => NULL,
                       X_To_Organization_Id             => RCVT.TO_ORGANIZATION_ID,
                       X_Routing_Header_Id              => RCVT.ROUTING_ID,
                       X_Routing_Step_Id                => RCVT.ROUTING_STEP_ID,
                       X_Source_Document_Code           => RCVT.SOURCE_DOCUMENT_CODE,
                       X_Parent_Transaction_Id          => p_transaction_id,
                       X_Po_Header_Id                   => RCVT.PO_HEADER_ID,
                       X_Po_Revision_Num                => RCVT.PO_REVISION_NUM,
                       X_Po_Release_Id                  => RCVT.PO_RELEASE_ID,
                       X_Po_Line_Id                     => RCVT.PO_LINE_ID,
                       X_Po_Line_Location_Id            => RCVT.PO_LINE_LOCATION_ID,
                       X_Po_Unit_Price                  => RCVT.PO_UNIT_PRICE,
                       X_Currency_Code                  => RCVT.CURRENCY_CODE,
                       X_Currency_Conversion_Type       => RCVT.CURRENCY_CONVERSION_TYPE,
                       X_Currency_Conversion_Rate       => RCVT.CURRENCY_CONVERSION_RATE,
                       X_Currency_Conversion_Date       => RCVT.CURRENCY_CONVERSION_DATE,
                       X_Po_Distribution_Id             => RCVT.PO_DISTRIBUTION_ID,
                       X_Requisition_Line_Id            => RCVT.REQ_LINE_ID,
                       X_Req_Distribution_Id            => RCVT.REQ_DISTRIBUTION_ID,
                       X_Charge_Account_Id              => NULL,
                       X_Substitute_Unordered_Code      => RCVT.SUBSTITUTE_UNORDERED_CODE,
                       X_Receipt_Exception_Flag         => NULL,
                       X_Accrual_Status_Code            => NULL,
                       X_Inspection_Status_Code         => l_inspection_status_code,
                       X_Inspection_Quality_Code        => p_quality_code,
                       X_Destination_Type_Code          => 'RECEIVING',
                       X_Deliver_To_Person_Id           => NULL,
                       X_Location_Id                    => RCVT.LOCATION_ID,
                       X_Deliver_To_Location_Id         => NULL,
                       X_Subinventory                   => p_subinventory, --Inserting the value passed by QA for bug 6529950
                       X_Locator_Id                     => p_locator_id,   --Inserting the value passed by QA for bug 6529950
                       X_Wip_Entity_Id                  => NULL,
                       X_Wip_Line_Id                    => NULL,
                       X_Department_Code                => NULL,
                       X_Wip_Repetitive_Schedule_Id     => NULL,
                       X_Wip_Operation_Seq_Num          => NULL,
                       X_Wip_Resource_Seq_Num           => NULL,
                       X_Bom_Resource_Id                => NULL,
                       X_Shipment_Num                   => NULL,
                       X_Freight_Carrier_Code           => NULL,
                       X_Bill_Of_Lading                 => NULL,
                       X_Packing_Slip                   => NULL,
                       X_Shipped_Date                   => NULL,
                       X_Expected_Receipt_Date          => NULL,
                       X_Actual_Cost                    => NULL,
                       X_Transfer_Cost                  => NULL,
                       X_Transportation_Cost            => NULL,
                       X_Transportation_Account_Id      => NULL,
                       X_Num_Of_Containers              => NULL,
                       X_Waybill_Airbill_Num            => NULL,
                       X_Vendor_Item_Num                => NULL,
                       X_Vendor_Lot_Num                 => p_vendor_lot,
                       X_Rma_Reference                  => NULL,
                       X_Comments                       => p_comments,
                       X_Attribute_Category             => RCVT.ATTRIBUTE_CATEGORY, -- Bug 6365501: Start
                       X_Attribute1                     => RCVT.ATTRIBUTE1,
                       X_Attribute2                     => RCVT.ATTRIBUTE2,
                       X_Attribute3                     => RCVT.ATTRIBUTE3,
                       X_Attribute4                     => RCVT.ATTRIBUTE4,
                       X_Attribute5                     => RCVT.ATTRIBUTE5,
                       X_Attribute6                     => RCVT.ATTRIBUTE6,
                       X_Attribute7                     => RCVT.ATTRIBUTE7,
                       X_Attribute8                     => RCVT.ATTRIBUTE8,
                       X_Attribute9                     => RCVT.ATTRIBUTE9,
                       X_Attribute10                    => RCVT.ATTRIBUTE10,
                       X_Attribute11                    => RCVT.ATTRIBUTE11,
                       X_Attribute12                    => RCVT.ATTRIBUTE12,
                       X_Attribute13                    => RCVT.ATTRIBUTE13,
                       X_Attribute14                    => RCVT.ATTRIBUTE14,
                       X_Attribute15                    => RCVT.ATTRIBUTE15,        -- Bug 6365501: End
                       X_Ship_Head_Attribute_Category   => NULL,
                       X_Ship_Head_Attribute1           => NULL,
                       X_Ship_Head_Attribute2           => NULL,
                       X_Ship_Head_Attribute3           => NULL,
                       X_Ship_Head_Attribute4           => NULL,
                       X_Ship_Head_Attribute5           => NULL,
                       X_Ship_Head_Attribute6           => NULL,
                       X_Ship_Head_Attribute7           => NULL,
                       X_Ship_Head_Attribute8           => NULL,
                       X_Ship_Head_Attribute9           => NULL,
                       X_Ship_Head_Attribute10          => NULL,
                       X_Ship_Head_Attribute11          => NULL,
                       X_Ship_Head_Attribute12          => NULL,
                       X_Ship_Head_Attribute13          => NULL,
                       X_Ship_Head_Attribute14          => NULL,
                       X_Ship_Head_Attribute15          => NULL,
                       X_Ship_Line_Attribute_Category   => NULL,
                       X_Ship_Line_Attribute1           => NULL,
                       X_Ship_Line_Attribute2           => NULL,
                       X_Ship_Line_Attribute3           => NULL,
                       X_Ship_Line_Attribute4           => NULL,
                       X_Ship_Line_Attribute5           => NULL,
                       X_Ship_Line_Attribute6           => NULL,
                       X_Ship_Line_Attribute7           => NULL,
                       X_Ship_Line_Attribute8           => NULL,
                       X_Ship_Line_Attribute9           => NULL,
                       X_Ship_Line_Attribute10          => NULL,
                       X_Ship_Line_Attribute11          => NULL,
                       X_Ship_Line_Attribute12          => NULL,
                       X_Ship_Line_Attribute13          => NULL,
                       X_Ship_Line_Attribute14          => NULL,
                       X_Ship_Line_Attribute15          => NULL,
                       X_Ussgl_Transaction_Code         => NULL,
                       X_Government_Context             => NULL,
                       X_Reason_Id                      => p_reason_id,
                       X_Destination_Context            => 'RECEIVING',
                       X_Source_Doc_Quantity            => l_source_doc_quantity,
                       X_Source_Doc_Unit_Of_Measure     => l_source_doc_uom,
		       X_Lot_Number_CC                  => RCVT.LOT_CONTROL_CODE,
		       X_Serial_Number_CC               => RCVT.SERIAL_NUMBER_CONTROL_CODE,
                       X_Qa_Collection_ID		=> p_qa_collection_id,
		       X_Country_of_origin_code         => NULL,
                       X_oe_order_header_id             => RCVT.OE_ORDER_HEADER_ID,
                       X_oe_order_line_id               => RCVT.OE_ORDER_LINE_ID,
                       X_customer_item_num              => RCVT.CUSTOMER_ITEM_NUM,
                       X_customer_id                    => RCVT.CUSTOMER_ID,
                       X_customer_site_id               => RCVT.CUSTOMER_SITE_ID,
		       X_put_away_rule_id               => NULL,
		       X_put_away_strategy_id           => NULL,
	               X_lpn_id                         => p_lpn_id,
                       X_transfer_lpn_id                => p_transfer_lpn_id,
		       X_cost_group_id			=> NULL,
		       X_mmtt_temp_id			=> NULL,
		       X_mobile_txn			=> NULL,
		       /*bUG# 1548597 */
		       X_secondary_quantity		=> RCVT.SECONDARY_QUANTITY,
		       X_secondary_unit_of_measure	=> RCVT.SECONDARY_UNIT_OF_MEASURE,
                       p_org_id                         => RCVT.ORG_ID, --<R12 MOAC>
		       X_from_subinventory              => p_from_subinventory, -- Added bug # 6529950
		       X_from_locator_id                => p_from_locator_id,  -- Added bug # 6529950
		       X_lcm_shipment_line_id           => RCVT.lcm_shipment_line_id,  -- lcm changes
		       X_unit_landed_cost               => RCVT.UNIT_LANDED_COST       -- lcm changes
		      );

        /* Bug 5018102 : INV process_txn() API expects project_id and task_id populated in RTI for
        **               Inspection transactions. Updating project_id/task_id in RTI from rcv_transactions.
        */

        SELECT project_id
             , task_id
        INTO   l_project_id
             , l_task_id
        FROM rcv_transactions
        WHERE transaction_id = p_transaction_id;

        IF l_project_id IS NOT NULL THEN

          UPDATE rcv_transactions_interface
          SET    project_id = l_project_id
               , task_id    = l_task_id
          WHERE interface_transaction_id = l_interface_id;

        END IF;

        /* End Bug 5018102 */

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      p_msg_count     ,
       		p_data          	=>      p_msg_data
    	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO INSPECTION_GRP;
		p_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      p_msg_count     ,
        		p_data          	=>      p_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INSPECTION_GRP;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      p_msg_count    	,
        		p_data          	=>      p_msg_data
    		);

	WHEN OTHERS THEN
		ROLLBACK TO INSPECTION_GRP;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      p_msg_count    	,
        		p_data          	=>      p_msg_data
    		);

END Insert_Inspection;

END RCV_Inspection_GRP;


/
