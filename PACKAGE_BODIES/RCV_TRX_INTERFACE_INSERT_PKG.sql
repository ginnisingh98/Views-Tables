--------------------------------------------------------
--  DDL for Package Body RCV_TRX_INTERFACE_INSERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRX_INTERFACE_INSERT_PKG" as
/* $Header: RCVTIR1B.pls 120.3.12010000.7 2014/04/29 11:14:44 smididud ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Interface_Transaction_Id       IN OUT NOCOPY NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Transaction_Type               VARCHAR2,
                       X_Transaction_Date               DATE,
                       X_Processing_Status_Code         VARCHAR2,
                       X_Processing_Mode_Code           VARCHAR2,
                       X_Processing_Request_Id          NUMBER,
                       X_Transaction_Status_Code        VARCHAR2,
                       X_Category_Id                    NUMBER,
                       X_Quantity                       NUMBER,
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Interface_Source_Code          VARCHAR2,
                       X_Interface_Source_Line_Id       NUMBER,
                       X_Inv_Transaction_Id             NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Item_Description               VARCHAR2,
                       X_Item_Revision                  VARCHAR2,
                       X_Uom_Code                       VARCHAR2,
                       X_Employee_Id                    NUMBER,
                       X_Auto_Transact_Code             VARCHAR2,
                       X_Shipment_Header_Id             NUMBER,
                       X_Shipment_Line_Id               NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Primary_Quantity               NUMBER,
                       X_Primary_Unit_Of_Measure        VARCHAR2,
                       X_Receipt_Source_Code            VARCHAR2,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_From_Organization_Id           NUMBER,
                       X_To_Organization_Id             NUMBER,
                       X_Routing_Header_Id              NUMBER,
                       X_Routing_Step_Id                NUMBER,
                       X_Source_Document_Code           VARCHAR2,
                       X_Parent_Transaction_Id          NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Po_Revision_Num                NUMBER,
                       X_Po_Release_Id                  NUMBER,
                       X_Po_Line_Id                     NUMBER,
                       X_Po_Line_Location_Id            NUMBER,
                       X_Po_Unit_Price                  NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Currency_Conversion_Type       VARCHAR2,
                       X_Currency_Conversion_Rate       NUMBER,
                       X_Currency_Conversion_Date       DATE,
                       X_Po_Distribution_Id             NUMBER,
                       X_Requisition_Line_Id            NUMBER,
                       X_Req_Distribution_Id            NUMBER,
                       X_Charge_Account_Id              NUMBER,
                       X_Substitute_Unordered_Code      VARCHAR2,
                       X_Receipt_Exception_Flag         VARCHAR2,
                       X_Accrual_Status_Code            VARCHAR2,
                       X_Inspection_Status_Code         VARCHAR2,
                       X_Inspection_Quality_Code        VARCHAR2,
                       X_Destination_Type_Code          VARCHAR2,
                       X_Deliver_To_Person_Id           NUMBER,
                       X_Location_Id                    NUMBER,
                       X_Deliver_To_Location_Id         NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Locator_Id                     NUMBER,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Wip_Line_Id                    NUMBER,
                       X_Department_Code                VARCHAR2,
                       X_Wip_Repetitive_Schedule_Id     NUMBER,
                       X_Wip_Operation_Seq_Num          NUMBER,
                       X_Wip_Resource_Seq_Num           NUMBER,
                       X_Bom_Resource_Id                NUMBER,
                       X_Shipment_Num                   VARCHAR2,
                       X_Freight_Carrier_Code           VARCHAR2,
                       X_Bill_Of_Lading                 VARCHAR2,
                       X_Packing_Slip                   VARCHAR2,
                       X_Shipped_Date                   DATE,
                       X_Expected_Receipt_Date          DATE,
                       X_Actual_Cost                    NUMBER,
                       X_Transfer_Cost                  NUMBER,
                       X_Transportation_Cost            NUMBER,
                       X_Transportation_Account_Id      NUMBER,
                       X_Num_Of_Containers              NUMBER,
                       X_Waybill_Airbill_Num            VARCHAR2,
                       X_Vendor_Item_Num                VARCHAR2,
                       X_Vendor_Lot_Num                 VARCHAR2,
                       X_Rma_Reference                  VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Ship_Head_Attribute_Category   VARCHAR2,
                       X_Ship_Head_Attribute1           VARCHAR2,
                       X_Ship_Head_Attribute2           VARCHAR2,
                       X_Ship_Head_Attribute3           VARCHAR2,
                       X_Ship_Head_Attribute4           VARCHAR2,
                       X_Ship_Head_Attribute5           VARCHAR2,
                       X_Ship_Head_Attribute6           VARCHAR2,
                       X_Ship_Head_Attribute7           VARCHAR2,
                       X_Ship_Head_Attribute8           VARCHAR2,
                       X_Ship_Head_Attribute9           VARCHAR2,
                       X_Ship_Head_Attribute10          VARCHAR2,
                       X_Ship_Head_Attribute11          VARCHAR2,
                       X_Ship_Head_Attribute12          VARCHAR2,
                       X_Ship_Head_Attribute13          VARCHAR2,
                       X_Ship_Head_Attribute14          VARCHAR2,
                       X_Ship_Head_Attribute15          VARCHAR2,
                       X_Ship_Line_Attribute_Category   VARCHAR2,
                       X_Ship_Line_Attribute1           VARCHAR2,
                       X_Ship_Line_Attribute2           VARCHAR2,
                       X_Ship_Line_Attribute3           VARCHAR2,
                       X_Ship_Line_Attribute4           VARCHAR2,
                       X_Ship_Line_Attribute5           VARCHAR2,
                       X_Ship_Line_Attribute6           VARCHAR2,
                       X_Ship_Line_Attribute7           VARCHAR2,
                       X_Ship_Line_Attribute8           VARCHAR2,
                       X_Ship_Line_Attribute9           VARCHAR2,
                       X_Ship_Line_Attribute10          VARCHAR2,
                       X_Ship_Line_Attribute11          VARCHAR2,
                       X_Ship_Line_Attribute12          VARCHAR2,
                       X_Ship_Line_Attribute13          VARCHAR2,
                       X_Ship_Line_Attribute14          VARCHAR2,
                       X_Ship_Line_Attribute15          VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Reason_Id                      NUMBER,
                       X_Destination_Context            VARCHAR2,
                       X_Source_Doc_Quantity            NUMBER,
                       X_Source_Doc_Unit_Of_Measure     VARCHAR2,
		       X_Lot_Number_CC                  NUMBER,
		       X_Serial_Number_CC               NUMBER,
                       X_QA_Collection_Id		NUMBER,
		       X_Country_of_Origin_Code		VARCHAR2,
		       X_oe_order_header_id	   	number,
		       X_oe_order_line_id	   	number,
		       X_customer_item_num	   	varchar2,
		       X_customer_id		   	number,
		       X_customer_site_id	   	number,
		       X_put_away_rule_id		number,
		       X_put_away_strategy_id		number,
		       X_lpn_id				number,
		       X_transfer_lpn_id		number,
                       X_cost_group_id                  NUMBER DEFAULT NULL,
                       X_mmtt_temp_id                   NUMBER DEFAULT NULL,
                       X_mobile_txn                     VARCHAR2 DEFAULT NULL,
                       X_transfer_cost_group_id         NUMBER DEFAULT NULL,
                       /*Bug# 1548597 Preetam B */
                       X_secondary_quantity		number DEFAULT NULL,
                       X_secondary_unit_of_measure	VARCHAR2 DEFAULT NULL,
                       X_lpn_group_id			number DEFAULT NULL,
                       p_org_id                         MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE DEFAULT NULL,--<R12 MOAC>
                       X_from_subinventory              VARCHAR2 DEFAULT NULL, --Added bug # 6529950
                       X_from_locator_id                NUMBER DEFAULT NULL,    --Added bug # 6529950
                       X_lcm_shipment_line_id           NUMBER DEFAULT NULL, -- lcm changes
                       X_unit_landed_cost               NUMBER DEFAULT NULL,  -- lcm changes
                       X_project_id             NUMBER DEFAULT NULL, -- Bug 9226303
                       X_task_id                NUMBER DEFAULT NULL  -- Bug 9226303
    ) IS
     CURSOR C IS SELECT rowid FROM RCV_TRANSACTIONS_INTERFACE
                 WHERE interface_transaction_id = X_Interface_Transaction_Id;





      CURSOR C2 IS SELECT rcv_transactions_interface_s.nextval FROM sys.dual;

    BEGIN
      if (X_Interface_Transaction_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Interface_Transaction_Id;
        CLOSE C2;
      end if;

       INSERT INTO RCV_TRANSACTIONS_INTERFACE(
               interface_transaction_id,
               group_id,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               transaction_type,
               transaction_date,
               processing_status_code,
               processing_mode_code,
               processing_request_id,
               transaction_status_code,
               category_id,
               quantity,
               unit_of_measure,
               interface_source_code,
               interface_source_line_id,
               inv_transaction_id,
               item_id,
               item_description,
               item_revision,
               uom_code,
               employee_id,
               auto_transact_code,
               shipment_header_id,
               shipment_line_id,
               ship_to_location_id,
               primary_quantity,
               primary_unit_of_measure,
               receipt_source_code,
               vendor_id,
               vendor_site_id,
               from_organization_id,
               to_organization_id,
               routing_header_id,
               routing_step_id,
               source_document_code,
               parent_transaction_id,
               po_header_id,
               po_revision_num,
               po_release_id,
               po_line_id,
               po_line_location_id,
               po_unit_price,
               currency_code,
               currency_conversion_type,
               currency_conversion_rate,
               currency_conversion_date,
               po_distribution_id,
               requisition_line_id,
               req_distribution_id,
               charge_account_id,
               substitute_unordered_code,
               receipt_exception_flag,
               accrual_status_code,
               inspection_status_code,
               inspection_quality_code,
               destination_type_code,
               deliver_to_person_id,
               location_id,
               deliver_to_location_id,
               subinventory,
               locator_id,
               wip_entity_id,
               wip_line_id,
               department_code,
               wip_repetitive_schedule_id,
               wip_operation_seq_num,
               wip_resource_seq_num,
               bom_resource_id,
               shipment_num,
               freight_carrier_code,
               bill_of_lading,
               packing_slip,
               shipped_date,
               expected_receipt_date,
               actual_cost,
               transfer_cost,
               transportation_cost,
               transportation_account_id,
               num_of_containers,
               waybill_airbill_num,
               vendor_item_num,
               vendor_lot_num,
               rma_reference,
               comments,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               ship_head_attribute_category,
               ship_head_attribute1,
               ship_head_attribute2,
               ship_head_attribute3,
               ship_head_attribute4,
               ship_head_attribute5,
               ship_head_attribute6,
               ship_head_attribute7,
               ship_head_attribute8,
               ship_head_attribute9,
               ship_head_attribute10,
               ship_head_attribute11,
               ship_head_attribute12,
               ship_head_attribute13,
               ship_head_attribute14,
               ship_head_attribute15,
               ship_line_attribute_category,
               ship_line_attribute1,
               ship_line_attribute2,
               ship_line_attribute3,
               ship_line_attribute4,
               ship_line_attribute5,
               ship_line_attribute6,
               ship_line_attribute7,
               ship_line_attribute8,
               ship_line_attribute9,
               ship_line_attribute10,
               ship_line_attribute11,
               ship_line_attribute12,
               ship_line_attribute13,
               ship_line_attribute14,
               ship_line_attribute15,
               ussgl_transaction_code,
               government_context,
               reason_id,
               destination_context,
               source_doc_quantity,
               source_doc_unit_of_measure,
               use_mtl_lot,
               use_mtl_serial,
               qa_collection_id,
	       country_of_origin_code,
	       oe_order_header_id,
	       oe_order_line_id,
	       customer_item_num,
	       customer_id,
	       customer_site_id,
	       put_away_rule_id,
	       put_away_strategy_id,
	       lpn_id,
	       transfer_lpn_id,
	       cost_group_id,
	       mmtt_temp_id,
	       mobile_txn,
	       transfer_cost_group_id,
	       /*Bug# 1548597 Preetam B */
	       secondary_quantity,
               secondary_unit_of_measure,
	       lpn_group_id,
               org_id,     --<R12 MOAC>
	       from_subinventory, --Added bug # 6529950
	       from_locator_id,    --Added bug # 6529950
	       lcm_shipment_line_id,
	       unit_landed_cost,
               project_id, -- Bug 9226303
               task_id     -- Bug 9226303
             ) VALUES (
               X_Interface_Transaction_Id,
               X_Group_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Transaction_Type,
               X_Transaction_Date,
               X_Processing_Status_Code,
               X_Processing_Mode_Code,
               X_Processing_Request_Id,
               X_Transaction_Status_Code,
               X_Category_Id,
               X_Quantity,
               X_Unit_Of_Measure,
               X_Interface_Source_Code,
               X_Interface_Source_Line_Id,
               X_Inv_Transaction_Id,
               X_Item_Id,
               X_Item_Description,
               X_Item_Revision,
               X_Uom_Code,
               X_Employee_Id,
               X_Auto_Transact_Code,
               X_Shipment_Header_Id,
               X_Shipment_Line_Id,
               X_Ship_To_Location_Id,
               X_Primary_Quantity,
               X_Primary_Unit_Of_Measure,
               X_Receipt_Source_Code,
               X_Vendor_Id,
               X_Vendor_Site_Id,
               X_From_Organization_Id,
               X_To_Organization_Id,
               X_Routing_Header_Id,
               X_Routing_Step_Id,
               X_Source_Document_Code,
               X_Parent_Transaction_Id,
               X_Po_Header_Id,
               X_Po_Revision_Num,
               X_Po_Release_Id,
               X_Po_Line_Id,
               X_Po_Line_Location_Id,
               X_Po_Unit_Price,
               X_Currency_Code,
               X_Currency_Conversion_Type,
               X_Currency_Conversion_Rate,
               X_Currency_Conversion_Date,
               X_Po_Distribution_Id,
               X_Requisition_Line_Id,
               X_Req_Distribution_Id,
               X_Charge_Account_Id,
               X_Substitute_Unordered_Code,
               X_Receipt_Exception_Flag,
               X_Accrual_Status_Code,
               X_Inspection_Status_Code,
               X_Inspection_Quality_Code,
               X_Destination_Type_Code,
               X_Deliver_To_Person_Id,
               X_Location_Id,
               X_Deliver_To_Location_Id,
               X_Subinventory,
               X_Locator_Id,
               X_Wip_Entity_Id,
               X_Wip_Line_Id,
               X_Department_Code,
               X_Wip_Repetitive_Schedule_Id,
               X_Wip_Operation_Seq_Num,
               X_Wip_Resource_Seq_Num,
               X_Bom_Resource_Id,
               X_Shipment_Num,
               X_Freight_Carrier_Code,
               X_Bill_Of_Lading,
               X_Packing_Slip,
               X_Shipped_Date,
               X_Expected_Receipt_Date,
               X_Actual_Cost,
               X_Transfer_Cost,
               X_Transportation_Cost,
               X_Transportation_Account_Id,
               X_Num_Of_Containers,
               X_Waybill_Airbill_Num,
               X_Vendor_Item_Num,
               X_Vendor_Lot_Num,
               X_Rma_Reference,
               X_Comments,
               X_Attribute_Category,
               X_Attribute1,
               X_Attribute2,
               X_Attribute3,
               X_Attribute4,
               X_Attribute5,
               X_Attribute6,
               X_Attribute7,
               X_Attribute8,
               X_Attribute9,
               X_Attribute10,
               X_Attribute11,
               X_Attribute12,
               X_Attribute13,
               X_Attribute14,
               X_Attribute15,
               X_Ship_Head_Attribute_Category,
               X_Ship_Head_Attribute1,
               X_Ship_Head_Attribute2,
               X_Ship_Head_Attribute3,
               X_Ship_Head_Attribute4,
               X_Ship_Head_Attribute5,
               X_Ship_Head_Attribute6,
               X_Ship_Head_Attribute7,
               X_Ship_Head_Attribute8,
               X_Ship_Head_Attribute9,
               X_Ship_Head_Attribute10,
               X_Ship_Head_Attribute11,
               X_Ship_Head_Attribute12,
               X_Ship_Head_Attribute13,
               X_Ship_Head_Attribute14,
               X_Ship_Head_Attribute15,
               X_Ship_Line_Attribute_Category,
               X_Ship_Line_Attribute1,
               X_Ship_Line_Attribute2,
               X_Ship_Line_Attribute3,
               X_Ship_Line_Attribute4,
               X_Ship_Line_Attribute5,
               X_Ship_Line_Attribute6,
               X_Ship_Line_Attribute7,
               X_Ship_Line_Attribute8,
               X_Ship_Line_Attribute9,
               X_Ship_Line_Attribute10,
               X_Ship_Line_Attribute11,
               X_Ship_Line_Attribute12,
               X_Ship_Line_Attribute13,
               X_Ship_Line_Attribute14,
               X_Ship_Line_Attribute15,
               X_Ussgl_Transaction_Code,
               X_Government_Context,
               X_Reason_Id,
               X_Destination_Context,
               X_Source_Doc_Quantity,
               X_Source_Doc_Unit_Of_Measure,
	       X_Lot_Number_CC,
	       X_Serial_Number_CC,
               X_QA_Collection_Id,
	       X_Country_of_Origin_Code,
	       X_oe_order_header_id,
               X_oe_order_line_id,
               X_customer_item_num,
               X_customer_id,
               X_customer_site_id,
	       X_put_away_rule_id,
	       X_put_away_strategy_id,
	       X_lpn_id,
	       X_transfer_lpn_id,
	       X_cost_group_id,
	       X_mmtt_temp_id,
	       X_mobile_txn,
	       X_transfer_cost_group_id,
	       /*Bug# 1548597 Preetam B */
	       X_secondary_quantity,
               X_secondary_unit_of_measure,
	       X_lpn_group_id,
               p_org_id,       --<R12 MOAC>
               X_from_subinventory, --Added bug # 6529950
               X_from_locator_id,    --Added bug # 6529950
	       X_lcm_shipment_line_id,
	       X_unit_landed_cost,
               X_project_id, -- Bug 9226303
               X_task_id     -- Bug 9226303
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  -- Procedure for updating vendor site id in rcv_shipment_headers.
  PROCEDURE UPDATE_SITE_ID(X_GROUP_ID             IN NUMBER,
                           X_SHIPMENT_HEADER_ID   IN NUMBER,
                           X_ADD_RECEIPT          IN VARCHAR2) IS

  x_vendor_site_id         NUMBER;
  x_site_id_count          NUMBER;
  x_rcv_lines_count        NUMBER;
  hdr_vendor_site_id       NUMBER;
  x_count                  NUMBER;
  x_rt_vendor_site_id      NUMBER;    /* Bug 18666225 */
  x_rt_site_id_count       NUMBER;    /* Bug 18666225 */

  BEGIN

       /*
       ** Determining the value of vendor_site_id to be populated in rcv_shipment_headers
       */

       /* The following select statement sequences thru the RTI
       ** for our group_id and determines whether the records have
       ** the same vendor_site_id or not. If the vendor_site_id
       ** is the same, we populate this value in rcv_shipment_headers
       ** else we null it out.
       */

        select count(count(vendor_site_id))
        into   x_site_id_count
        from   rcv_transactions_interface RTI
        where  RTI.group_id = x_group_id
        group  by vendor_site_id;


        select vendor_site_id
        into hdr_vendor_site_id
        from rcv_shipment_headers
        where shipment_header_id = x_shipment_header_id;


        if (x_site_id_count = 1) then

           select distinct vendor_site_id
           into x_vendor_site_id
           from rcv_transactions_interface RTI
           where RTI.group_id = x_group_id;


       	   IF (X_ADD_RECEIPT = 'NEW') THEN
                hdr_vendor_site_id := x_vendor_site_id;
           elsif (Nvl(hdr_vendor_site_id,-999) <> x_vendor_site_id) THEN  /* Start of bug 18666225 */

                  IF hdr_vendor_site_id IS NULL THEN

                     select count(count(vendor_site_id))
                     into   x_rt_site_id_count
                     from   rcv_transactions RT
                     where  RT.shipment_header_id = x_shipment_header_id
                     group  by vendor_site_id;

                     IF (x_rt_site_id_count = 0) then

                         hdr_vendor_site_id :=  x_vendor_site_id;

                     ELSIF (x_rt_site_id_count = 1 ) THEN

                         select DISTINCT(vendor_site_id)
                         into   x_rt_vendor_site_id
                         from   rcv_transactions RT
                         where  RT.shipment_header_id = x_shipment_header_id
                         group  by vendor_site_id;

                         IF (x_rt_vendor_site_id <> x_vendor_site_id) then
                             hdr_vendor_site_id := '';
                         ELSIF
                            (x_rt_vendor_site_id = x_vendor_site_id) then
                             hdr_vendor_site_id := x_vendor_site_id;
                         END IF;

                     ELSIF (x_rt_site_id_count > 1 ) THEN

                            hdr_vendor_site_id := '';

                     END IF;

                  ELSE
                     hdr_vendor_site_id := '';
                  END IF;       /* End of bug 18666225 */

           end if;

         else

	     hdr_vendor_site_id := '';

         end if;

         -- Bug 8340719 : Do not update rsh.vendor_site_id if no line/RTI is selected.
         if (x_site_id_count > 0) then
             update rcv_shipment_headers
             set vendor_site_id = hdr_vendor_site_id
             where shipment_header_id = x_shipment_header_id;
         end if;

  EXCEPTION

    WHEN OTHERS THEN NULL;

  END UPDATE_SITE_ID;

END RCV_TRX_INTERFACE_INSERT_PKG;

/
