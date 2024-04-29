--------------------------------------------------------
--  DDL for Package Body MTL_MOVEMENT_STATISTICS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MOVEMENT_STATISTICS2_PKG" as
/* $Header: INVTTM2B.pls 120.1 2005/07/01 13:23:42 appldev ship $ */

procedure lock_row(v_rowid varchar2,
	v_movement_id number,
	v_parent_movement_id number,
	v_Organization_Id      number,
      v_Last_Update_Date date,
      v_Last_Updated_By  number,
      v_Creation_Date    date,
      v_Created_By       number,
      v_Last_Update_Login number,
	v_movement_type varchar2,
	v_document_source_type varchar2,
	v_entity_org_id number,
	v_Transaction_date date,
	v_movement_status varchar2,
	v_go_detail varchar2,
	v_from_org_id number,
	v_from_org_name varchar2,
	v_to_org_id number,
	v_to_org_name varchar2,
	v_customer_name varchar2,
	v_customer_number varchar2,
	v_customer_location varchar2,
	v_ship_to_customer_id number,
	v_ship_to_site_use_id number,
	v_vendor_name varchar2,
	v_vendor_number varchar2,
	v_vendor_site varchar2,
	v_vendor_id number,
	v_vendor_site_id number,
	v_po_header_id number,
	v_order_header_id number,
	v_requisition_header_id number,
	v_doc_reference varchar2,
        v_po_line_id number,
	v_order_line_id number,
	v_requisition_line_id number,
	v_doc_line_reference varchar2,
	v_shipment_header_id number,
	v_shipment_reference varchar2,
	v_shipment_line_id number,
	v_shipment_line_reference varchar2,
	v_po_line_location_id number,
	v_picking_line_id number,
	v_picking_line_detail_id number,
	v_pick_slip_reference varchar2,
	v_bill_to_name varchar2,
	v_bill_to_number varchar2,
	v_bill_to_site varchar2,
	v_bill_to_customer_id number,
	v_bill_to_site_use_id number,
	v_invoice_batch_id number,
	v_invoice_batch_reference varchar2,
	v_invoice_id number,
	v_invoice_reference varchar2,
	v_customer_trx_line_id number,
	v_invoice_line_reference varchar2,
 	v_invoice_qty number,
 	v_invoice_unit_price number,
 	v_invoice_line_ext_val number,
	v_invoice_date_reference date,
	v_inventory_item_id number,
	v_item_cost number,
	v_item_desc varchar2,
	v_commodity_code varchar2,
	v_commodity_description varchar2,
	v_category_id number,
	v_transaction_uom_code varchar2,
	v_transaction_qty number,
 	v_document_unit_price number,
	v_document_line_ext_value number,
	v_primary_qty number,
	v_dispatch_terr_code varchar2,
	v_destination_terr_code varchar2,
	v_origin_terr_code varchar2,
	v_txn_nature varchar2,
	v_delivery_terms varchar2,
	v_transport_mode varchar2,
	v_area varchar2,
	v_port varchar2,
	v_stat_type varchar2,
	v_weight_method varchar2,
	v_unit_weight number ,
	v_total_weight number ,
 	v_stat_adj_pct number ,
 	v_stat_adj_amt number ,
	v_stat_ext_val number ,
	v_stat_method varchar2,
	v_comments varchar2,
	v_alt_qty number,
	v_alt_uom_code varchar2,
	v_outside_code varchar2,
 	v_outside_unit_price number,
 	v_outside_ext_val number,
	v_currency_code varchar2,
	v_attribute_category varchar2,
	v_attribute1 varchar2 ,
	v_attribute2 varchar2 ,
	v_attribute3 varchar2 ,
	v_attribute4 varchar2 ,
	v_attribute5 varchar2 ,
	v_attribute6 varchar2 ,
	v_attribute7 varchar2 ,
	v_attribute8 varchar2 ,
	v_attribute9 varchar2 ,
	v_attribute10 varchar2 ,
	v_attribute11 varchar2 ,
	v_attribute12 varchar2 ,
	v_attribute13 varchar2 ,
	v_attribute14 varchar2 ,
	v_attribute15 varchar2
      , v_triangulation_country_code VARCHAR2
      , v_csa_code                   VARCHAR2
      , v_set_of_books_period        VARCHAR2
      , v_oil_reference_code         VARCHAR2
      , v_container_type_code        VARCHAR2
      , v_flow_indicator_code        VARCHAR2
      , v_affiliation_reference_code VARCHAR2
) IS

    CURSOR C IS
    SELECT
	 MOVEMENT_ID			,
 ORGANIZATION_ID		,
 ENTITY_ORG_ID			,
 MOVEMENT_TYPE			,
 MOVEMENT_STATUS		,
 TRANSACTION_DATE		,
 LAST_UPDATE_DATE		,
 LAST_UPDATED_BY		,
 CREATION_DATE			,
 CREATED_BY			,
 LAST_UPDATE_LOGIN		,
 DOCUMENT_SOURCE_TYPE		,
 CREATION_METHOD		,
 DOCUMENT_REFERENCE		,
 DOCUMENT_LINE_REFERENCE	,
 DOCUMENT_UNIT_PRICE		,
 DOCUMENT_LINE_EXT_VALUE	,
 RECEIPT_REFERENCE		,
 SHIPMENT_REFERENCE		,
 SHIPMENT_LINE_REFERENCE	,
 PICK_SLIP_REFERENCE		,
 CUSTOMER_NAME			,
 CUSTOMER_NUMBER		,
 CUSTOMER_LOCATION		,
 TRANSACTING_FROM_ORG		,
 TRANSACTING_TO_ORG		,
 VENDOR_NAME			,
 VENDOR_NUMBER			,
 VENDOR_SITE			,
 BILL_TO_NAME			,
 BILL_TO_NUMBER 		,
 BILL_TO_SITE			,
 PO_HEADER_ID			,
 PO_LINE_ID			,
 PO_LINE_LOCATION_ID		,
 ORDER_HEADER_ID		,
 ORDER_LINE_ID			,
 REQUISITION_HEADER_ID		,
 REQUISITION_LINE_ID		,
 PICKING_LINE_ID		,
 PICKING_LINE_DETAIL_ID		,
 SHIPMENT_HEADER_ID		,
 SHIPMENT_LINE_ID		,
 SHIP_TO_CUSTOMER_ID		,
 SHIP_TO_SITE_USE_ID		,
 BILL_TO_CUSTOMER_ID		,
 BILL_TO_SITE_USE_ID		,
 VENDOR_ID			,
 VENDOR_SITE_ID 		,
 FROM_ORGANIZATION_ID		,
 TO_ORGANIZATION_ID		,
 PARENT_MOVEMENT_ID		,
 INVENTORY_ITEM_ID		,
 ITEM_DESCRIPTION		,
 ITEM_COST			,
 TRANSACTION_QUANTITY		,
 TRANSACTION_UOM_CODE		,
 PRIMARY_QUANTITY		,
 INVOICE_BATCH_ID		,
 INVOICE_ID			,
 CUSTOMER_TRX_LINE_ID		,
 INVOICE_BATCH_REFERENCE	,
 INVOICE_REFERENCE		,
 INVOICE_LINE_REFERENCE 	,
 INVOICE_DATE_REFERENCE 	,
 INVOICE_QUANTITY		,
 INVOICE_UNIT_PRICE		,
 INVOICE_LINE_EXT_VALUE 	,
 OUTSIDE_CODE			,
 OUTSIDE_EXT_VALUE		,
 OUTSIDE_UNIT_PRICE		,
 CURRENCY_CODE			,
 CATEGORY_ID			,
 COMMODITY_CODE 		,
 COMMODITY_DESCRIPTION		,
 WEIGHT_METHOD			,
 UNIT_WEIGHT			,
 TOTAL_WEIGHT			,
 TRANSACTION_NATURE		,
 DELIVERY_TERMS 		,
 TRANSPORT_MODE 		,
 ALTERNATE_QUANTITY		,
 ALTERNATE_UOM_CODE		,
 DISPATCH_TERRITORY_CODE	,
 DESTINATION_TERRITORY_CODE	,
 ORIGIN_TERRITORY_CODE		,
 STAT_METHOD			,
 STAT_ADJ_PERCENT		,
 STAT_ADJ_AMOUNT		,
 STAT_EXT_VALUE 		,
 AREA				,
 PORT				,
 STAT_TYPE			,
 COMMENTS			,
 ATTRIBUTE_CATEGORY		,
 ATTRIBUTE1			,
 ATTRIBUTE2			,
 ATTRIBUTE3			,
 ATTRIBUTE4			,
 ATTRIBUTE5			,
 ATTRIBUTE6			,
 ATTRIBUTE7			,
 ATTRIBUTE8			,
 ATTRIBUTE9			,
 ATTRIBUTE10			,
 ATTRIBUTE11			,
 ATTRIBUTE12			,
 ATTRIBUTE13			,
 ATTRIBUTE14			,
 ATTRIBUTE15
, TRIANGULATION_COUNTRY_CODE
, CSA_CODE
, SET_OF_BOOKS_PERIOD
, OIL_REFERENCE_CODE
, CONTAINER_TYPE_CODE
, FLOW_INDICATOR_CODE
, AFFILIATION_REFERENCE_CODE

FROM mtl_movement_statistics
        WHERE  rowid = v_RowId
        FOR UPDATE of  movement_id NOWAIT;


    Recinfo C%ROWTYPE;
    partone boolean := FALSE;
    parttwo boolean := FALSE;

  BEGIN
        OPEN C;
        FETCH C INTO Recinfo;
        if (C%NOTFOUND) then
          CLOSE C;
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	  app_exception.raise_exception;
        end if;
        CLOSE C;

	/* This was split in to two sections because for some reason,
	the PL/SQL compiler was unable to handle the entire section at
	once */
        if (
               (Recinfo.movement_id =  v_Movement_Id)
           AND (Recinfo.organization_id =  v_Organization_Id)
           AND (Recinfo.entity_org_id =  v_Entity_Org_Id)
           AND (Recinfo.movement_type =  v_Movement_Type)
           AND (Recinfo.movement_status =  v_Movement_Status)
           AND (Recinfo.transaction_date =  v_Transaction_Date)
           AND (Recinfo.document_source_type =  v_Document_Source_Type)
           AND (   (Recinfo.document_reference =  v_Doc_Reference)
                OR (    (Recinfo.document_reference IS NULL)))
           AND (   (Recinfo.document_line_reference =  v_Doc_Line_Reference)
                OR (    (Recinfo.document_line_reference IS NULL)))
           AND (   (Recinfo.document_unit_price =  v_Document_Unit_Price)
                OR (    (Recinfo.document_unit_price IS NULL)
                    AND (v_Document_Unit_Price IS NULL)))
           AND (   (Recinfo.document_line_ext_value =  v_Document_Line_Ext_Value)
                OR (    (Recinfo.document_line_ext_value IS NULL)
                    AND (v_Document_Line_Ext_Value IS NULL)))
           AND (   (Recinfo.shipment_reference =  v_Shipment_Reference)
                OR (    (Recinfo.shipment_reference IS NULL)))
           AND (   (Recinfo.shipment_line_reference =  v_Shipment_Line_Reference)
                OR (    (Recinfo.shipment_line_reference IS NULL)))
           AND (   (Recinfo.pick_slip_reference =  v_Pick_Slip_Reference)
                OR (    (Recinfo.pick_slip_reference IS NULL)))
           AND (   (Recinfo.customer_name =  v_Customer_Name)
                OR (    (Recinfo.customer_name IS NULL)))
           AND (   (Recinfo.customer_number =  v_Customer_Number)
                OR (    (Recinfo.customer_number IS NULL)))
           AND (   (Recinfo.customer_location =  v_Customer_Location)
                OR (    (Recinfo.customer_location IS NULL)))
           AND (   (Recinfo.transacting_from_org =  v_From_Org_Name)
                OR (    (Recinfo.transacting_from_org IS NULL)))
           AND (   (Recinfo.transacting_to_org =  v_To_Org_Name)
                OR (    (Recinfo.transacting_to_org IS NULL)))
           AND (   (Recinfo.vendor_name =  v_Vendor_Name)
                OR (    (Recinfo.vendor_name IS NULL)))
           AND (   (Recinfo.vendor_number =  v_Vendor_Number)
                OR (    (Recinfo.vendor_number IS NULL)))
           AND (   (Recinfo.vendor_site =  v_Vendor_Site)
                OR (    (Recinfo.vendor_site IS NULL)))
           AND (   (Recinfo.bill_to_name =  v_Bill_To_Name)
                OR (    (Recinfo.bill_to_name IS NULL)))
           AND (   (Recinfo.bill_to_number =  v_Bill_To_Number)
                OR (    (Recinfo.bill_to_number IS NULL)))
           AND (   (Recinfo.bill_to_site =  v_Bill_To_Site)
                OR (    (Recinfo.bill_to_site IS NULL)))
           AND (   (Recinfo.po_header_id =  v_Po_Header_Id)
                OR (    (Recinfo.po_header_id IS NULL)
                    AND (v_Po_Header_Id IS NULL)))
           AND (   (Recinfo.po_line_id =  v_Po_Line_Id)
                OR (    (Recinfo.po_line_id IS NULL)
                    AND (v_Po_Line_Id IS NULL)))
           AND (   (Recinfo.po_line_location_id =  v_Po_Line_Location_Id)
                OR (    (Recinfo.po_line_location_id IS NULL)
                    AND (v_Po_Line_Location_Id IS NULL)))
           AND (   (Recinfo.order_header_id =  v_Order_Header_Id)
                OR (    (Recinfo.order_header_id IS NULL)
                    AND (v_Order_Header_Id IS NULL)))
           AND (   (Recinfo.order_line_id =  v_Order_Line_Id)
                OR (    (Recinfo.order_line_id IS NULL)
                    AND (v_Order_Line_Id IS NULL)))
	   AND (   (Recinfo.requisition_header_id =  v_Requisition_Header_Id)
                OR (    (Recinfo.requisition_header_id IS NULL)
                    AND (v_Requisition_Header_Id IS NULL)))
           AND (   (Recinfo.requisition_line_id =  v_Requisition_Line_Id)
                OR (    (Recinfo.requisition_line_id IS NULL)
                    AND (v_Requisition_Line_Id IS NULL)))
           AND (   (Recinfo.picking_line_id =  v_Picking_Line_Id)
                OR (    (Recinfo.picking_line_id IS NULL)
                    AND (v_Picking_Line_Id IS NULL)))
	   AND (   (Recinfo.picking_line_detail_id =  v_Picking_Line_Detail_Id)
                OR (    (Recinfo.picking_line_detail_id IS NULL)
                    AND (v_Picking_Line_Detail_Id IS NULL)))
           AND (   (Recinfo.shipment_header_id =  v_Shipment_Header_Id)
                OR (    (Recinfo.shipment_header_id IS NULL)
                    AND (v_Shipment_Header_Id IS NULL)))
           AND (   (Recinfo.shipment_line_id =  v_Shipment_Line_Id)
                OR (    (Recinfo.shipment_line_id IS NULL)
                    AND (v_Shipment_Line_Id IS NULL)))
           AND (   (Recinfo.ship_to_customer_id =  v_Ship_To_Customer_Id)
                OR (    (Recinfo.ship_to_customer_id IS NULL)
                    AND (v_Ship_To_Customer_Id IS NULL)))
           AND (   (Recinfo.ship_to_site_use_id =  v_Ship_To_Site_Use_Id)
                OR (    (Recinfo.ship_to_site_use_id IS NULL)
                    AND (v_Ship_To_Site_Use_Id IS NULL)))
           AND (   (Recinfo.bill_to_customer_id =  v_Bill_To_Customer_Id)
                OR (    (Recinfo.bill_to_customer_id IS NULL)
                    AND (v_Bill_To_Customer_Id IS NULL)))
           AND (   (Recinfo.bill_to_site_use_id =  v_Bill_To_Site_Use_Id)
                OR (    (Recinfo.bill_to_site_use_id IS NULL)
                    AND (v_Bill_To_Site_Use_Id IS NULL)))
           AND (   (Recinfo.vendor_id =  v_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (v_Vendor_Id IS NULL)))
           AND (   (Recinfo.vendor_site_id =  v_Vendor_Site_Id)
                OR (    (Recinfo.vendor_site_id IS NULL)
                    AND (v_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.from_organization_id =  v_From_Org_Id)
                OR (    (Recinfo.from_organization_id IS NULL)
                    AND (v_From_Org_Id IS NULL)))
           AND (   (Recinfo.to_organization_id =  v_To_Org_Id)
                OR (    (Recinfo.to_organization_id IS NULL)
                    AND (v_To_Org_Id IS NULL)))
           AND (Recinfo.parent_movement_id =  v_Parent_Movement_Id)
           AND (   (Recinfo.inventory_item_id =  v_Inventory_Item_Id)
                OR (    (Recinfo.inventory_item_id IS NULL)
                    AND (v_Inventory_Item_Id IS NULL)))
           AND (   (Recinfo.item_description =  v_Item_Desc)
                OR (    (Recinfo.item_description IS NULL)
                    AND (v_Item_Desc IS NULL)))
           AND (   (Recinfo.item_cost =  v_Item_Cost)
                OR (    (Recinfo.item_cost IS NULL)
                    AND (v_Item_Cost IS NULL)))
           AND (   (Recinfo.transaction_quantity =  v_Transaction_Qty)
                OR (    (Recinfo.transaction_quantity IS NULL)
                    AND (v_Transaction_Qty IS NULL)))
           AND (   (Recinfo.transaction_uom_code =  v_Transaction_Uom_Code)
                OR (    (Recinfo.transaction_uom_code IS NULL)
                    AND (v_Transaction_Uom_Code IS NULL)))
           AND (   (Recinfo.primary_quantity =  v_Primary_Qty)
                OR (    (Recinfo.primary_quantity IS NULL)
                    AND (v_Primary_Qty IS NULL)))
           AND (   (Recinfo.invoice_batch_id =  v_Invoice_Batch_Id)
                OR (    (Recinfo.invoice_batch_id IS NULL)
                    AND (v_Invoice_Batch_Id IS NULL)))
           AND (   (Recinfo.invoice_id =  v_Invoice_Id)
                OR (    (Recinfo.invoice_id IS NULL)
                    AND (v_Invoice_Id IS NULL)))
           AND (   (Recinfo.customer_trx_line_id =  v_Customer_Trx_Line_Id)
                OR (    (Recinfo.customer_trx_line_id IS NULL)
                    AND (v_Customer_Trx_Line_Id IS NULL)))
           AND (   (Recinfo.invoice_batch_reference =  v_Invoice_Batch_Reference)
                OR (    (Recinfo.invoice_batch_reference IS NULL)))
           AND (   (Recinfo.invoice_reference =  v_Invoice_Reference)
                OR (    (Recinfo.invoice_reference IS NULL)))
           AND (   (Recinfo.invoice_line_reference =  v_Invoice_Line_Reference)
                OR (    (Recinfo.invoice_line_reference IS NULL)))
           AND (   (Recinfo.invoice_date_reference =  v_Invoice_Date_Reference)
                OR (    (Recinfo.invoice_date_reference IS NULL)
                    AND (v_Invoice_Date_Reference IS NULL)))
           AND (   (Recinfo.invoice_quantity =  v_Invoice_Qty)
                OR (    (Recinfo.invoice_quantity IS NULL)
                    AND (v_Invoice_Qty IS NULL)))
           AND (   (Recinfo.invoice_unit_price =  v_Invoice_Unit_Price)
                OR (    (Recinfo.invoice_unit_price IS NULL)
                    AND (v_Invoice_Unit_Price IS NULL)))
           AND (   (Recinfo.invoice_line_ext_value =  v_Invoice_Line_Ext_Val)
                OR (    (Recinfo.invoice_line_ext_value IS NULL)
                    AND (v_Invoice_Line_Ext_Val IS NULL)))
           AND (   (Recinfo.outside_code =  v_Outside_Code)
                OR (    (Recinfo.outside_code IS NULL)
                    AND (v_Outside_Code IS NULL)))
	) then
		partone := TRUE;
	end if;
	if (
           (   (Recinfo.outside_ext_value =  v_Outside_Ext_Val)
                OR (    (Recinfo.outside_ext_value IS NULL)
                    AND (v_Outside_Ext_Val IS NULL)))
           AND (   (Recinfo.outside_unit_price =  v_Outside_Unit_Price)
                OR (    (Recinfo.outside_unit_price IS NULL)
                    AND (v_Outside_Unit_Price IS NULL)))
           AND (   (Recinfo.currency_code =  v_Currency_Code)
                OR (    (Recinfo.currency_code IS NULL)
                    AND (v_Currency_Code IS NULL)))
           AND (   (Recinfo.category_id =  v_Category_Id)
                OR (    (Recinfo.category_id IS NULL)
                    AND (v_Category_Id IS NULL)))
           AND (   (Recinfo.commodity_code =  v_Commodity_Code)
                OR (    (Recinfo.commodity_code IS NULL)
                    AND (v_Commodity_Code IS NULL)))
           AND (   (Recinfo.commodity_description =  v_Commodity_Description)
                OR (    (Recinfo.commodity_description IS NULL)
                    AND (v_Commodity_Description IS NULL)))
           AND (   (Recinfo.weight_method =  v_Weight_Method)
                OR (    (Recinfo.weight_method IS NULL)
                    AND (v_Weight_Method IS NULL)))
           AND (   (Recinfo.unit_weight =  v_Unit_Weight)
                OR (    (Recinfo.unit_weight IS NULL)
                    AND (v_Unit_Weight IS NULL)))
           AND (   (Recinfo.total_weight =  v_Total_Weight)
                OR (    (Recinfo.total_weight IS NULL)
                    AND (v_Total_Weight IS NULL)))
           AND (   (Recinfo.transaction_nature =  v_Txn_Nature)
                OR (    (Recinfo.transaction_nature IS NULL)
                    AND (v_Txn_Nature IS NULL)))
           AND (   (Recinfo.delivery_terms =  v_Delivery_Terms)
                OR (    (Recinfo.delivery_terms IS NULL)
                    AND (v_Delivery_Terms IS NULL)))
           AND (   (Recinfo.transport_mode =  v_Transport_Mode)
                OR (    (Recinfo.transport_mode IS NULL)
                    AND (v_Transport_Mode IS NULL)))
           AND (   (Recinfo.alternate_quantity =  v_Alt_Qty)
                OR (    (Recinfo.alternate_quantity IS NULL)
                    AND (v_Alt_Qty IS NULL)))
           AND (   (Recinfo.alternate_uom_code =  v_Alt_Uom_Code)
                OR (    (Recinfo.alternate_uom_code IS NULL)
                    AND (v_Alt_Uom_Code IS NULL)))
           AND (   (Recinfo.dispatch_territory_code =  v_Dispatch_Terr_Code)
                OR (    (Recinfo.dispatch_territory_code IS NULL)
                    AND (v_Dispatch_Terr_Code IS NULL)))
           AND (   (Recinfo.destination_territory_code =  v_Destination_Terr_Code)
                OR (    (Recinfo.destination_territory_code IS NULL)
                    AND (v_Destination_Terr_Code IS NULL)))
           AND (   (Recinfo.origin_territory_code =  v_Origin_Terr_Code)
                OR (    (Recinfo.origin_territory_code IS NULL)
                    AND (v_Origin_Terr_Code IS NULL)))
           AND (   (Recinfo.stat_adj_percent =  v_Stat_Adj_Pct)
                OR (    (Recinfo.stat_adj_percent IS NULL)
                    AND (v_Stat_Adj_Pct IS NULL)))
           AND (   (Recinfo.stat_adj_amount =  v_Stat_Adj_Amt)
                OR (    (Recinfo.stat_adj_amount IS NULL)
                    AND (v_Stat_Adj_Amt IS NULL)))
           AND (   (Recinfo.stat_ext_value =  v_Stat_Ext_Val)
                OR (    (Recinfo.stat_ext_value IS NULL)
                    AND (v_Stat_Ext_Val IS NULL)))
           AND (   (Recinfo.area =  v_Area)
                OR (    (Recinfo.area IS NULL)
                    AND (v_Area IS NULL)))
           AND (   (Recinfo.port =  v_Port)
                OR (    (Recinfo.port IS NULL)
                    AND (v_Port IS NULL)))
           AND (   (Recinfo.stat_type =  v_Stat_Type)
                OR (    (Recinfo.stat_type IS NULL)
                    AND (v_Stat_Type IS NULL)))
           AND (   (Recinfo.comments =  v_Comments)
                OR (    (Recinfo.comments IS NULL)
                    AND (v_Comments IS NULL)))
           AND (   (Recinfo.attribute_category =  v_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (v_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  v_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (v_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  v_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (v_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  v_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (v_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  v_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (v_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  v_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (v_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  v_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (v_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  v_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (v_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  v_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (v_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  v_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (v_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  v_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (v_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  v_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (v_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  v_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (v_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  v_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (v_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  v_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (v_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  v_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (v_Attribute15 IS NULL)))
           AND (   (Recinfo.triangulation_country_code = v_Triangulation_Country_Code)
               OR  (    (Recinfo.triangulation_country_code IS NULL)
                   AND  (v_Triangulation_Country_Code IS NULL)))
           AND (   (Recinfo.csa_code = v_Csa_Code)
               OR  (    (Recinfo.csa_code IS NULL)
                   AND  (v_Csa_Code IS NULL)))
           AND (   (Recinfo.set_of_books_period = v_Set_Of_Books_Period)
               OR  (    (Recinfo.set_of_books_period IS NULL)
                   AND  (v_Set_Of_Books_Period IS NULL)))
           AND (   (Recinfo.oil_reference_code = v_Oil_Reference_Code)
               OR  (    (Recinfo.oil_reference_code IS NULL)
                   AND  (v_Oil_Reference_Code IS NULL)))
           AND (   (Recinfo.flow_indicator_code = v_Flow_Indicator_Code)
               OR  (    (Recinfo.flow_indicator_code  IS NULL)
                   AND  (v_Flow_Indicator_Code IS NULL)))
           AND (   (Recinfo.container_type_code = v_Container_Type_Code)
               OR  (    (Recinfo.container_type_code IS NULL)
                   AND  (v_Container_Type_Code IS NULL)))
           AND (   (Recinfo.affiliation_reference_code = v_Affiliation_Reference_Code)
               OR  (    (Recinfo.affiliation_reference_code IS NULL)
                   AND  (v_Affiliation_Reference_Code IS NULL)))
	) then
          parttwo := TRUE;
	end if;
	if (partone and parttwo) then
		return;
        else
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
	  app_exception.raise_exception;
        end if;
  END Lock_Row;

END MTL_MOVEMENT_STATISTICS2_PKG;

/
