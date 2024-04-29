--------------------------------------------------------
--  DDL for Package Body MTL_MOVEMENT_STATISTICS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MOVEMENT_STATISTICS1_PKG" as
/* $Header: INVTTM1B.pls 120.1 2005/06/11 12:53:42 appldev  $ */

procedure insert_row (	v_rowid IN OUT NOCOPY /* file.sql.39 change */ varchar2,
	v_movement_id IN OUT NOCOPY /* file.sql.39 change */ number,
	v_parent_movement_id IN OUT NOCOPY /* file.sql.39 change */ number,
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
	v_transacting_from_org varchar2,
	v_to_org_id number,
	v_transacting_to_org varchar2,
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
	v_commodity_code_description varchar2,
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
	v_attribute15 varchar2) is


	 CURSOR C IS SELECT rowid FROM mtl_movement_statistics
                 WHERE  movement_id = v_movement_id;

  CURSOR C2 IS SELECT mtl_movement_statistics_s.nextval FROM dual;

   BEGIN
     if (v_movement_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO v_movement_Id;
        CLOSE C2;
      end if;

       INSERT INTO mtl_movement_statistics(
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
 ATTRIBUTE15)
	VALUES (
	v_movement_id,
	v_organization_id,
	v_entity_org_id,
	v_movement_type,
	v_movement_status,
	v_transaction_date,
	v_last_update_date,
	v_last_updated_by,
	v_creation_date,
	v_created_by,
	v_last_update_login,
	v_document_source_type,
	decode(v_go_detail, null, 'M', 'Z'),
	v_doc_reference,
	v_doc_line_reference,
	v_document_unit_price,
	v_document_line_ext_value,
	null,
	v_shipment_reference,
	v_shipment_line_reference,
	v_pick_slip_reference,
	v_customer_name,
	v_customer_number,
	v_customer_location,
	v_transacting_from_org,
	v_transacting_to_org,
	v_vendor_name,
	v_vendor_number,
	v_vendor_site,
	v_bill_to_name,
	v_bill_to_number,
	v_bill_to_site,
 	v_po_header_id,
	v_po_line_id,
	v_po_line_location_id,
	v_order_header_id,
	v_order_line_id,
	v_requisition_header_id,
	v_requisition_line_id,
	v_picking_line_id,
	v_picking_line_detail_id,
	v_shipment_header_id,
	v_shipment_line_id,
	v_ship_to_customer_id,
	v_ship_to_site_use_id,
	v_bill_to_customer_id,
	v_bill_to_site_use_id,
	v_vendor_id,
	v_vendor_site_id,
	v_from_org_id,
	v_to_org_id,
	decode(v_parent_movement_id, null, v_movement_id, v_parent_movement_id),
	v_inventory_item_id,
	v_item_desc,
	v_item_cost,
	v_transaction_qty,
	v_transaction_uom_code,
	v_primary_qty,
	v_invoice_batch_id,
	v_invoice_id,
	v_customer_trx_line_id,
	v_invoice_batch_reference,
	v_invoice_reference,
	v_invoice_line_reference,
	v_invoice_date_reference,
	v_invoice_qty,
	v_invoice_unit_price,
	v_invoice_line_ext_val,
	v_outside_code,
	v_outside_ext_val,
	v_outside_unit_price,
	v_currency_code,
	v_category_id,
	v_commodity_code,
	v_commodity_code_description,
	v_weight_method,
	v_unit_weight,
	v_total_weight,
	v_txn_nature,
	v_delivery_terms,
	v_transport_mode,
	v_alt_qty,
	v_alt_uom_code,
	v_dispatch_terr_code,
	v_destination_terr_code,
	v_origin_terr_code,
	v_stat_method,
	v_stat_adj_pct,
	v_stat_adj_amt,
	v_stat_ext_val,
	v_area,
	v_port,
	v_stat_type,
	v_comments,
	v_attribute_category,
	v_attribute1,
	v_attribute2,
	v_attribute3,
	v_attribute4,
	v_attribute5,
	v_attribute6,
	v_attribute7,
	v_attribute8,
	v_attribute9,
	v_attribute10,
	v_attribute11,
	v_attribute12,
	v_attribute13,
	v_attribute14,
	v_attribute15);

    OPEN C;
    FETCH C INTO v_RowId;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

END insert_row;

  procedure delete_row(v_rowid varchar2) is
   begin

    DELETE FROM mtl_movement_statistics
    WHERE rowid = v_RowId;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END MTL_MOVEMENT_STATISTICS1_PKG;

/
