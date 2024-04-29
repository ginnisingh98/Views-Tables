--------------------------------------------------------
--  DDL for Package Body RCV_ASN_TRX_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ASN_TRX_INSERT" as
/* $Header: RCVAHTXB.pls 115.7 2002/11/25 21:46:22 sbull ship $ */

PROCEDURE HANDLE_RCV_ASN_TRANSACTIONS (V_TRANS_TAB     IN OUT  NOCOPY RCV_SHIPMENT_OBJECT_SV.CASCADED_TRANS_TAB_TYPE,
                                       V_HEADER_RECORD IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.HEADERRECTYPE) IS

V_CURRENT_INTERFACE_ID  NUMBER;
V_PRIOR_INTERFACE_ID    NUMBER;
I                       BINARY_INTEGER := 0;
E_O_T                   BINARY_INTEGER := 0;

X_ROWID                 VARCHAR2(255);
l_wms_return_status  VARCHAR2(1);
l_wms_msg_count      NUMBER;
l_wms_msg_data       VARCHAR2(400);
lorgid               NUMBER;   -- For Bug 2110031
BEGIN

 IF V_TRANS_TAB.COUNT > 0 then

   i := V_TRANS_TAB.FIRST;
   E_O_T := V_TRANS_TAB.LAST;

   V_CURRENT_INTERFACE_ID := -999;
   V_PRIOR_INTERFACE_ID   := -999;

   /* Delete only once from the rcv_transactions_interface table for every
      group of pl/sql table rows that have the same interface id */


   FOR j in i..E_O_T loop

     ASN_DEBUG.PUT_LINE('Transaction Type ' || v_trans_tab(j).transaction_type);

     V_CURRENT_INTERFACE_ID := V_TRANS_TAB(j).INTERFACE_TRANSACTION_ID;

     /* SELECT GROUP_SEQUENCE_ID_S.nextval into V_TRANS_TAB(j).GROUP_ID
     from dual;      -- Check whether this has to be unique  */

     -- Will use the group_id from the header_record as the pre-processor
     -- needs the header and transactions group id to be the same

     V_TRANS_TAB(j).GROUP_ID := V_HEADER_RECORD.HEADER_RECORD.GROUP_ID;
     ASN_DEBUG.PUT_LINE('Group id ' || to_char(V_TRANS_TAB(j).GROUP_ID));

     /* Assigning to_organization_id to lorgid which is passed
        as a parameter to WMS_INSTALL function .Also added
       debug messages .*/

     lorgid := V_TRANS_TAB(j).TO_ORGANIZATION_ID;

      ASN_DEBUG.PUT_LINE('organization id ' || to_char(V_TRANS_TAB(j).TO_ORGANIZATION_ID));
        ASN_DEBUG.PUT_LINE('lorgid ' || to_char(lorgid));


     IF V_CURRENT_INTERFACE_ID <> V_PRIOR_INTERFACE_ID then

        ASN_DEBUG.PUT_LINE('Handle the original interface id ' || to_char(V_TRANS_TAB(j).INTERFACE_TRANSACTION_ID));
        ASN_DEBUG.PUT_LINE('delete from rcv_transactions_interface rowid ' || V_TRANS_TAB(j).ROW_ID);

        RCV_TRX_INTERFACE_DELETE_PKG.Delete_Row(V_TRANS_TAB(j).ROW_ID);

        /* V_TRANS_TAB(j).INTERFACE_TRANSACTION_ID := NULL; */  -- need to maintain the interface transaction id
                                                                -- for error reporting
        X_ROWID := NULL;

        RCV_ASN_INTERFACE_TRX_INS_PKG.INSERT_ROW(
                        V_TRANS_TAB(j).ROW_ID,
                        V_TRANS_TAB(j).INTERFACE_TRANSACTION_ID,
                        V_TRANS_TAB(j).GROUP_ID,
                        V_TRANS_TAB(j).LAST_UPDATE_DATE,
                        V_TRANS_TAB(j).LAST_UPDATED_BY,
                        V_TRANS_TAB(j).CREATION_DATE,
                        V_TRANS_TAB(j).CREATED_BY,
                        V_TRANS_TAB(j).LAST_UPDATE_LOGIN,
                        V_TRANS_TAB(j).REQUEST_ID,
                        V_TRANS_TAB(j).PROGRAM_APPLICATION_ID,
                        V_TRANS_TAB(j).PROGRAM_ID,
                        V_TRANS_TAB(j).PROGRAM_UPDATE_DATE,
                        V_TRANS_TAB(j).TRANSACTION_TYPE,
                        V_TRANS_TAB(j).TRANSACTION_DATE,
                        V_TRANS_TAB(j).PROCESSING_STATUS_CODE,
                        V_TRANS_TAB(j).PROCESSING_MODE_CODE,
                        V_TRANS_TAB(j).PROCESSING_REQUEST_ID,
                        V_TRANS_TAB(j).TRANSACTION_STATUS_CODE,
                        V_TRANS_TAB(j).CATEGORY_ID,
                        V_TRANS_TAB(j).QUANTITY,
                        V_TRANS_TAB(j).UNIT_OF_MEASURE,
                        V_TRANS_TAB(j).INTERFACE_SOURCE_CODE,
                        V_TRANS_TAB(j).INTERFACE_SOURCE_LINE_ID,
                        V_TRANS_TAB(j).INV_TRANSACTION_ID,
                        V_TRANS_TAB(j).ITEM_ID,
                        V_TRANS_TAB(j).ITEM_DESCRIPTION,
                        V_TRANS_TAB(j).ITEM_REVISION,
                        V_TRANS_TAB(j).UOM_CODE,
                        V_TRANS_TAB(j).EMPLOYEE_ID,
                        V_TRANS_TAB(j).AUTO_TRANSACT_CODE,
                        NVL(V_TRANS_TAB(j).SHIPMENT_HEADER_ID,V_HEADER_RECORD.HEADER_RECORD.RECEIPT_HEADER_ID),
                        V_TRANS_TAB(j).SHIPMENT_LINE_ID,
                        V_TRANS_TAB(j).SHIP_TO_LOCATION_ID,
                        V_TRANS_TAB(j).PRIMARY_QUANTITY,
                        V_TRANS_TAB(j).PRIMARY_UNIT_OF_MEASURE,
                        V_TRANS_TAB(j).RECEIPT_SOURCE_CODE,
                        V_TRANS_TAB(j).VENDOR_ID,
                        V_TRANS_TAB(j).VENDOR_SITE_ID,
                        V_TRANS_TAB(j).FROM_ORGANIZATION_ID,
                        V_TRANS_TAB(j).FROM_SUBINVENTORY,
                        V_TRANS_TAB(j).TO_ORGANIZATION_ID,
                        V_TRANS_TAB(j).INTRANSIT_OWNING_ORG_ID,
                        V_TRANS_TAB(j).ROUTING_HEADER_ID,
                        V_TRANS_TAB(j).ROUTING_STEP_ID,
                        V_TRANS_TAB(j).SOURCE_DOCUMENT_CODE,
                        V_TRANS_TAB(j).PARENT_TRANSACTION_ID,
                        V_TRANS_TAB(j).PO_HEADER_ID,
                        V_TRANS_TAB(j).PO_REVISION_NUM,
                        V_TRANS_TAB(j).PO_RELEASE_ID,
                        V_TRANS_TAB(j).PO_LINE_ID,
                        V_TRANS_TAB(j).PO_LINE_LOCATION_ID,
                        V_TRANS_TAB(j).PO_UNIT_PRICE,
                        V_TRANS_TAB(j).CURRENCY_CODE,
                        V_TRANS_TAB(j).CURRENCY_CONVERSION_TYPE,
                        V_TRANS_TAB(j).CURRENCY_CONVERSION_RATE,
                        V_TRANS_TAB(j).CURRENCY_CONVERSION_DATE,
                        V_TRANS_TAB(j).PO_DISTRIBUTION_ID,
                        V_TRANS_TAB(j).REQUISITION_LINE_ID,
                        V_TRANS_TAB(j).REQ_DISTRIBUTION_ID,
                        V_TRANS_TAB(j).CHARGE_ACCOUNT_ID,
                        V_TRANS_TAB(j).SUBSTITUTE_UNORDERED_CODE,
                        V_TRANS_TAB(j).RECEIPT_EXCEPTION_FLAG,
                        V_TRANS_TAB(j).ACCRUAL_STATUS_CODE,
                        V_TRANS_TAB(j).INSPECTION_STATUS_CODE,
                        V_TRANS_TAB(j).INSPECTION_QUALITY_CODE,
                        V_TRANS_TAB(j).DESTINATION_TYPE_CODE,
                        V_TRANS_TAB(j).DELIVER_TO_PERSON_ID,
                        V_TRANS_TAB(j).LOCATION_ID,
                        V_TRANS_TAB(j).DELIVER_TO_LOCATION_ID,
                        V_TRANS_TAB(j).SUBINVENTORY,
                        V_TRANS_TAB(j).LOCATOR_ID,
                        V_TRANS_TAB(j).WIP_ENTITY_ID,
                        V_TRANS_TAB(j).WIP_LINE_ID,
                        V_TRANS_TAB(j).DEPARTMENT_CODE,
                        V_TRANS_TAB(j).WIP_REPETITIVE_SCHEDULE_ID,
                        V_TRANS_TAB(j).WIP_OPERATION_SEQ_NUM,
                        V_TRANS_TAB(j).WIP_RESOURCE_SEQ_NUM,
                        V_TRANS_TAB(j).BOM_RESOURCE_ID,
                        V_TRANS_TAB(j).SHIPMENT_NUM,
                        V_TRANS_TAB(j).FREIGHT_CARRIER_CODE,
                        V_TRANS_TAB(j).BILL_OF_LADING,
                        V_TRANS_TAB(j).PACKING_SLIP,
                        V_TRANS_TAB(j).SHIPPED_DATE,
                        V_TRANS_TAB(j).EXPECTED_RECEIPT_DATE,
                        V_TRANS_TAB(j).ACTUAL_COST,
                        V_TRANS_TAB(j).TRANSFER_COST,
                        V_TRANS_TAB(j).TRANSPORTATION_COST,
                        V_TRANS_TAB(j).TRANSPORTATION_ACCOUNT_ID,
                        V_TRANS_TAB(j).NUM_OF_CONTAINERS,
                        V_TRANS_TAB(j).WAYBILL_AIRBILL_NUM,
                        V_TRANS_TAB(j).VENDOR_ITEM_NUM,
                        V_TRANS_TAB(j).VENDOR_LOT_NUM,
                        V_TRANS_TAB(j).RMA_REFERENCE,
                        V_TRANS_TAB(j).COMMENTS,
                        V_TRANS_TAB(j).ATTRIBUTE_CATEGORY,
                        V_TRANS_TAB(j).ATTRIBUTE1,
                        V_TRANS_TAB(j).ATTRIBUTE2,
                        V_TRANS_TAB(j).ATTRIBUTE3,
                        V_TRANS_TAB(j).ATTRIBUTE4,
                        V_TRANS_TAB(j).ATTRIBUTE5,
                        V_TRANS_TAB(j).ATTRIBUTE6,
                        V_TRANS_TAB(j).ATTRIBUTE7,
                        V_TRANS_TAB(j).ATTRIBUTE8,
                        V_TRANS_TAB(j).ATTRIBUTE9,
                        V_TRANS_TAB(j).ATTRIBUTE10,
                        V_TRANS_TAB(j).ATTRIBUTE11,
                        V_TRANS_TAB(j).ATTRIBUTE12,
                        V_TRANS_TAB(j).ATTRIBUTE13,
                        V_TRANS_TAB(j).ATTRIBUTE14,
                        V_TRANS_TAB(j).ATTRIBUTE15,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE_CATEGORY,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE1,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE2,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE3,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE4,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE5,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE6,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE7,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE8,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE9,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE10,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE11,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE12,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE13,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE14,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE15,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE_CATEGORY,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE1,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE2,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE3,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE4,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE5,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE6,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE7,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE8,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE9,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE10,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE11,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE12,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE13,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE14,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE15,
                        V_TRANS_TAB(j).USSGL_TRANSACTION_CODE,
                        V_TRANS_TAB(j).GOVERNMENT_CONTEXT,
                        V_TRANS_TAB(j).REASON_ID,
                        V_TRANS_TAB(j).DESTINATION_CONTEXT,
                        V_TRANS_TAB(j).SOURCE_DOC_QUANTITY,
                        V_TRANS_TAB(j).SOURCE_DOC_UNIT_OF_MEASURE,
                        V_TRANS_TAB(j).MOVEMENT_ID,
                        V_TRANS_TAB(j).HEADER_INTERFACE_ID,
                        V_TRANS_TAB(j).VENDOR_CUM_SHIPPED_QTY,
                        V_TRANS_TAB(j).ITEM_NUM,
                        V_TRANS_TAB(j).DOCUMENT_NUM,
                        V_TRANS_TAB(j).DOCUMENT_LINE_NUM,
                        V_TRANS_TAB(j).TRUCK_NUM,
                        V_TRANS_TAB(j).SHIP_TO_LOCATION_CODE,
                        V_TRANS_TAB(j).CONTAINER_NUM,
                        V_TRANS_TAB(j).SUBSTITUTE_ITEM_NUM,
                        V_TRANS_TAB(j).NOTICE_UNIT_PRICE,
                        V_TRANS_TAB(j).ITEM_CATEGORY,
                        V_TRANS_TAB(j).LOCATION_CODE,
                        V_TRANS_TAB(j).VENDOR_NAME,
                        V_TRANS_TAB(j).VENDOR_NUM,
                        V_TRANS_TAB(j).VENDOR_SITE_CODE,
                        V_TRANS_TAB(j).FROM_ORGANIZATION_CODE,
                        V_TRANS_TAB(j).TO_ORGANIZATION_CODE,
                        V_TRANS_TAB(j).INTRANSIT_OWNING_ORG_CODE,
                        V_TRANS_TAB(j).ROUTING_CODE,
                        V_TRANS_TAB(j).ROUTING_STEP,
                        V_TRANS_TAB(j).RELEASE_NUM,
                        V_TRANS_TAB(j).DOCUMENT_SHIPMENT_LINE_NUM,
                        V_TRANS_TAB(j).DOCUMENT_DISTRIBUTION_NUM,
                        V_TRANS_TAB(j).DELIVER_TO_PERSON_NAME,
                        V_TRANS_TAB(j).DELIVER_TO_LOCATION_CODE,
                        V_TRANS_TAB(j).USE_MTL_LOT,
                        V_TRANS_TAB(j).USE_MTL_SERIAL,
                        V_TRANS_TAB(j).LOCATOR,
                        V_TRANS_TAB(j).REASON_NAME,
                        V_TRANS_TAB(j).VALIDATION_FLAG,
                        V_TRANS_TAB(j).SUBSTITUTE_ITEM_ID,
                        V_TRANS_TAB(j).QUANTITY_SHIPPED,
                        V_TRANS_TAB(j).QUANTITY_INVOICED,
                        V_TRANS_TAB(j).TAX_NAME,
                        V_TRANS_TAB(j).TAX_AMOUNT,
                        V_TRANS_TAB(j).REQ_NUM,
                        V_TRANS_TAB(j).REQ_LINE_NUM,
                        V_TRANS_TAB(j).REQ_DISTRIBUTION_NUM,
                        V_TRANS_TAB(j).WIP_ENTITY_NAME,
                        V_TRANS_TAB(j).WIP_LINE_CODE,
                        V_TRANS_TAB(j).RESOURCE_CODE,
                        V_TRANS_TAB(j).SHIPMENT_LINE_STATUS_CODE,
                        V_TRANS_TAB(j).BARCODE_LABEL,
			V_TRANS_TAB(j).COUNTRY_OF_ORIGIN_CODE);

        ASN_DEBUG.PUT_LINE('RowId ' || V_TRANS_TAB(j).ROW_ID);
        ASN_DEBUG.PUT_LINE('Interface Id ' || to_char(V_TRANS_TAB(j).INTERFACE_TRANSACTION_ID));

        V_PRIOR_INTERFACE_ID := V_CURRENT_INTERFACE_ID;
        V_TRANS_TAB.delete(j);

     ELSE

        ASN_DEBUG.PUT_LINE('insert into rcv_transactions_interface with new id ');

        /* Since we are inserting 1-> many rows need to generate a new interface id */

        V_TRANS_TAB(j).INTERFACE_TRANSACTION_ID := NULL;
        X_ROWID := NULL;

        RCV_ASN_INTERFACE_TRX_INS_PKG.INSERT_ROW(
                        V_TRANS_TAB(j).ROW_ID,
                        V_TRANS_TAB(j).INTERFACE_TRANSACTION_ID,
                        V_TRANS_TAB(j).GROUP_ID,
                        V_TRANS_TAB(j).LAST_UPDATE_DATE,
                        V_TRANS_TAB(j).LAST_UPDATED_BY,
                        V_TRANS_TAB(j).CREATION_DATE,
                        V_TRANS_TAB(j).CREATED_BY,
                        V_TRANS_TAB(j).LAST_UPDATE_LOGIN,
                        V_TRANS_TAB(j).REQUEST_ID,
                        V_TRANS_TAB(j).PROGRAM_APPLICATION_ID,
                        V_TRANS_TAB(j).PROGRAM_ID,
                        V_TRANS_TAB(j).PROGRAM_UPDATE_DATE,
                        V_TRANS_TAB(j).TRANSACTION_TYPE,
                        V_TRANS_TAB(j).TRANSACTION_DATE,
                        V_TRANS_TAB(j).PROCESSING_STATUS_CODE,
                        V_TRANS_TAB(j).PROCESSING_MODE_CODE,
                        V_TRANS_TAB(j).PROCESSING_REQUEST_ID,
                        V_TRANS_TAB(j).TRANSACTION_STATUS_CODE,
                        V_TRANS_TAB(j).CATEGORY_ID,
                        V_TRANS_TAB(j).QUANTITY,
                        V_TRANS_TAB(j).UNIT_OF_MEASURE,
                        V_TRANS_TAB(j).INTERFACE_SOURCE_CODE,
                        V_TRANS_TAB(j).INTERFACE_SOURCE_LINE_ID,
                        V_TRANS_TAB(j).INV_TRANSACTION_ID,
                        V_TRANS_TAB(j).ITEM_ID,
                        V_TRANS_TAB(j).ITEM_DESCRIPTION,
                        V_TRANS_TAB(j).ITEM_REVISION,
                        V_TRANS_TAB(j).UOM_CODE,
                        V_TRANS_TAB(j).EMPLOYEE_ID,
                        V_TRANS_TAB(j).AUTO_TRANSACT_CODE,
                        NVL(V_TRANS_TAB(j).SHIPMENT_HEADER_ID, V_HEADER_RECORD.HEADER_RECORD.RECEIPT_HEADER_ID),
                        V_TRANS_TAB(j).SHIPMENT_LINE_ID,
                        V_TRANS_TAB(j).SHIP_TO_LOCATION_ID,
                        V_TRANS_TAB(j).PRIMARY_QUANTITY,
                        V_TRANS_TAB(j).PRIMARY_UNIT_OF_MEASURE,
                        V_TRANS_TAB(j).RECEIPT_SOURCE_CODE,
                        V_TRANS_TAB(j).VENDOR_ID,
                        V_TRANS_TAB(j).VENDOR_SITE_ID,
                        V_TRANS_TAB(j).FROM_ORGANIZATION_ID,
                        V_TRANS_TAB(j).FROM_SUBINVENTORY,
                        V_TRANS_TAB(j).TO_ORGANIZATION_ID,
                        V_TRANS_TAB(j).INTRANSIT_OWNING_ORG_ID,
                        V_TRANS_TAB(j).ROUTING_HEADER_ID,
                        V_TRANS_TAB(j).ROUTING_STEP_ID,
                        V_TRANS_TAB(j).SOURCE_DOCUMENT_CODE,
                        V_TRANS_TAB(j).PARENT_TRANSACTION_ID,
                        V_TRANS_TAB(j).PO_HEADER_ID,
                        V_TRANS_TAB(j).PO_REVISION_NUM,
                        V_TRANS_TAB(j).PO_RELEASE_ID,
                        V_TRANS_TAB(j).PO_LINE_ID,
                        V_TRANS_TAB(j).PO_LINE_LOCATION_ID,
                        V_TRANS_TAB(j).PO_UNIT_PRICE,
                        V_TRANS_TAB(j).CURRENCY_CODE,
                        V_TRANS_TAB(j).CURRENCY_CONVERSION_TYPE,
                        V_TRANS_TAB(j).CURRENCY_CONVERSION_RATE,
                        V_TRANS_TAB(j).CURRENCY_CONVERSION_DATE,
                        V_TRANS_TAB(j).PO_DISTRIBUTION_ID,
                        V_TRANS_TAB(j).REQUISITION_LINE_ID,
                        V_TRANS_TAB(j).REQ_DISTRIBUTION_ID,
                        V_TRANS_TAB(j).CHARGE_ACCOUNT_ID,
                        V_TRANS_TAB(j).SUBSTITUTE_UNORDERED_CODE,
                        V_TRANS_TAB(j).RECEIPT_EXCEPTION_FLAG,
                        V_TRANS_TAB(j).ACCRUAL_STATUS_CODE,
                        V_TRANS_TAB(j).INSPECTION_STATUS_CODE,
                        V_TRANS_TAB(j).INSPECTION_QUALITY_CODE,
                        V_TRANS_TAB(j).DESTINATION_TYPE_CODE,
                        V_TRANS_TAB(j).DELIVER_TO_PERSON_ID,
                        V_TRANS_TAB(j).LOCATION_ID,
                        V_TRANS_TAB(j).DELIVER_TO_LOCATION_ID,
                        V_TRANS_TAB(j).SUBINVENTORY,
                        V_TRANS_TAB(j).LOCATOR_ID,
                        V_TRANS_TAB(j).WIP_ENTITY_ID,
                        V_TRANS_TAB(j).WIP_LINE_ID,
                        V_TRANS_TAB(j).DEPARTMENT_CODE,
                        V_TRANS_TAB(j).WIP_REPETITIVE_SCHEDULE_ID,
                        V_TRANS_TAB(j).WIP_OPERATION_SEQ_NUM,
                        V_TRANS_TAB(j).WIP_RESOURCE_SEQ_NUM,
                        V_TRANS_TAB(j).BOM_RESOURCE_ID,
                        V_TRANS_TAB(j).SHIPMENT_NUM,
                        V_TRANS_TAB(j).FREIGHT_CARRIER_CODE,
                        V_TRANS_TAB(j).BILL_OF_LADING,
                        V_TRANS_TAB(j).PACKING_SLIP,
                        V_TRANS_TAB(j).SHIPPED_DATE,
                        V_TRANS_TAB(j).EXPECTED_RECEIPT_DATE,
                        V_TRANS_TAB(j).ACTUAL_COST,
                        V_TRANS_TAB(j).TRANSFER_COST,
                        V_TRANS_TAB(j).TRANSPORTATION_COST,
                        V_TRANS_TAB(j).TRANSPORTATION_ACCOUNT_ID,
                        V_TRANS_TAB(j).NUM_OF_CONTAINERS,
                        V_TRANS_TAB(j).WAYBILL_AIRBILL_NUM,
                        V_TRANS_TAB(j).VENDOR_ITEM_NUM,
                        V_TRANS_TAB(j).VENDOR_LOT_NUM,
                        V_TRANS_TAB(j).RMA_REFERENCE,
                        V_TRANS_TAB(j).COMMENTS,
                        V_TRANS_TAB(j).ATTRIBUTE_CATEGORY,
                        V_TRANS_TAB(j).ATTRIBUTE1,
                        V_TRANS_TAB(j).ATTRIBUTE2,
                        V_TRANS_TAB(j).ATTRIBUTE3,
                        V_TRANS_TAB(j).ATTRIBUTE4,
                        V_TRANS_TAB(j).ATTRIBUTE5,
                        V_TRANS_TAB(j).ATTRIBUTE6,
                        V_TRANS_TAB(j).ATTRIBUTE7,
                        V_TRANS_TAB(j).ATTRIBUTE8,
                        V_TRANS_TAB(j).ATTRIBUTE9,
                        V_TRANS_TAB(j).ATTRIBUTE10,
                        V_TRANS_TAB(j).ATTRIBUTE11,
                        V_TRANS_TAB(j).ATTRIBUTE12,
                        V_TRANS_TAB(j).ATTRIBUTE13,
                        V_TRANS_TAB(j).ATTRIBUTE14,
                        V_TRANS_TAB(j).ATTRIBUTE15,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE_CATEGORY,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE1,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE2,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE3,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE4,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE5,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE6,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE7,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE8,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE9,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE10,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE11,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE12,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE13,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE14,
                        V_TRANS_TAB(j).SHIP_HEAD_ATTRIBUTE15,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE_CATEGORY,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE1,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE2,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE3,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE4,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE5,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE6,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE7,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE8,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE9,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE10,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE11,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE12,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE13,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE14,
                        V_TRANS_TAB(j).SHIP_LINE_ATTRIBUTE15,
                        V_TRANS_TAB(j).USSGL_TRANSACTION_CODE,
                        V_TRANS_TAB(j).GOVERNMENT_CONTEXT,
                        V_TRANS_TAB(j).REASON_ID,
                        V_TRANS_TAB(j).DESTINATION_CONTEXT,
                        V_TRANS_TAB(j).SOURCE_DOC_QUANTITY,
                        V_TRANS_TAB(j).SOURCE_DOC_UNIT_OF_MEASURE,
                        V_TRANS_TAB(j).MOVEMENT_ID,
                        V_TRANS_TAB(j).HEADER_INTERFACE_ID,
                        V_TRANS_TAB(j).VENDOR_CUM_SHIPPED_QTY,
                        V_TRANS_TAB(j).ITEM_NUM,
                        V_TRANS_TAB(j).DOCUMENT_NUM,
                        V_TRANS_TAB(j).DOCUMENT_LINE_NUM,
                        V_TRANS_TAB(j).TRUCK_NUM,
                        V_TRANS_TAB(j).SHIP_TO_LOCATION_CODE,
                        V_TRANS_TAB(j).CONTAINER_NUM,
                        V_TRANS_TAB(j).SUBSTITUTE_ITEM_NUM,
                        V_TRANS_TAB(j).NOTICE_UNIT_PRICE,
                        V_TRANS_TAB(j).ITEM_CATEGORY,
                        V_TRANS_TAB(j).LOCATION_CODE,
                        V_TRANS_TAB(j).VENDOR_NAME,
                        V_TRANS_TAB(j).VENDOR_NUM,
                        V_TRANS_TAB(j).VENDOR_SITE_CODE,
                        V_TRANS_TAB(j).FROM_ORGANIZATION_CODE,
                        V_TRANS_TAB(j).TO_ORGANIZATION_CODE,
                        V_TRANS_TAB(j).INTRANSIT_OWNING_ORG_CODE,
                        V_TRANS_TAB(j).ROUTING_CODE,
                        V_TRANS_TAB(j).ROUTING_STEP,
                        V_TRANS_TAB(j).RELEASE_NUM,
                        V_TRANS_TAB(j).DOCUMENT_SHIPMENT_LINE_NUM,
                        V_TRANS_TAB(j).DOCUMENT_DISTRIBUTION_NUM,
                        V_TRANS_TAB(j).DELIVER_TO_PERSON_NAME,
                        V_TRANS_TAB(j).DELIVER_TO_LOCATION_CODE,
                        V_TRANS_TAB(j).USE_MTL_LOT,
                        V_TRANS_TAB(j).USE_MTL_SERIAL,
                        V_TRANS_TAB(j).LOCATOR,
                        V_TRANS_TAB(j).REASON_NAME,
                        V_TRANS_TAB(j).VALIDATION_FLAG,
                        V_TRANS_TAB(j).SUBSTITUTE_ITEM_ID,
                        V_TRANS_TAB(j).QUANTITY_SHIPPED,
                        V_TRANS_TAB(j).QUANTITY_INVOICED,
                        V_TRANS_TAB(j).TAX_NAME,
                        V_TRANS_TAB(j).TAX_AMOUNT,
                        V_TRANS_TAB(j).REQ_NUM,
                        V_TRANS_TAB(j).REQ_LINE_NUM,
                        V_TRANS_TAB(j).REQ_DISTRIBUTION_NUM,
                        V_TRANS_TAB(j).WIP_ENTITY_NAME,
                        V_TRANS_TAB(j).WIP_LINE_CODE,
                        V_TRANS_TAB(j).RESOURCE_CODE,
                        V_TRANS_TAB(j).SHIPMENT_LINE_STATUS_CODE,
                        V_TRANS_TAB(j).BARCODE_LABEL,
			V_TRANS_TAB(j).COUNTRY_OF_ORIGIN_CODE);

        ASN_DEBUG.PUT_LINE('RowId ' || V_TRANS_TAB(j).ROW_ID);
        ASN_DEBUG.PUT_LINE('Interface Id ' || to_char(V_TRANS_TAB(j).INTERFACE_TRANSACTION_ID));

        V_TRANS_TAB.delete(j);
     END IF;

    /* Checking if WMS is intalled before calling WMS_ASN_INTERFACE_PROCESS
       for Bug 2110031 */

     if( WMS_INSTALL.check_install(l_wms_return_status,l_wms_msg_count,l_wms_msg_data,lorgid) ) then

         begin

            WMS_ASN_INTERFACE.PROCESS(l_wms_return_status, l_wms_msg_count, l_wms_msg_data, v_current_interface_id);

         exception
            when others then
              null;
          end;

      end if;


   END LOOP;

 END IF;

END HANDLE_RCV_ASN_TRANSACTIONS;

PROCEDURE INSERT_CANCELLED_ASN_LINES (V_HEADER_RECORD IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.HEADERRECTYPE) IS

BEGIN

   -- delete any asn lines that have been sent

   asn_debug.put_line('Delete any asn lines that have been sent');

   delete from rcv_transactions_interface
   where header_interface_id = v_header_record.header_record.header_interface_id;

   -- Insert lines from rcv_shipment_lines into rcv_transactions_interface

   -- Make sure we don't inset cancelled lines and lines that are waiting to
   -- be cancelled in rti
   -- The transaction processor will then cancel the lines

   -- Bug 587603 Inserting processing request id for CANCEL otherwise
   -- transaction processor will not look at it.

   INSERT INTO RCV_TRANSACTIONS_INTERFACE
       (Interface_Transaction_Id 	    ,
        Header_interface_id                 ,
        Group_Id 			    ,
        Last_Update_Date	 	    ,
        Last_Updated_By 		    ,
        Last_Update_Login 		    ,
        creation_date                       ,
        created_by                          ,
        Transaction_Type 		    ,
        Transaction_Date 		    ,
        Processing_Status_Code 		    ,
        Processing_Mode_Code 		    ,
        Transaction_Status_Code 	    ,
        Category_Id 			    ,
        Quantity 			    ,
        Unit_Of_Measure 		    ,
        Interface_Source_Code 		    ,
        Item_Id 			    ,
        Item_Description 		    ,
        Employee_Id 			    ,
        Auto_Transact_Code 		    ,
        Receipt_Source_Code 		    ,
        Vendor_Id 			    ,
        To_Organization_Id 		    ,
        Source_Document_Code 		    ,
        Po_Header_Id 			    ,
        Po_Line_Id 			    ,
        Po_Line_Location_Id 		    ,
        Shipment_Header_Id 		    ,
        SHIPMENT_LINE_ID,
        DESTINATION_TYPE_CODE,
        processing_request_id)
   SELECT
        RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL,
        V_header_record.header_record.header_interface_id,
        V_header_record.header_record.group_id,
        V_header_record.header_record.last_update_date,
        V_header_record.header_record.last_updated_by,
        V_header_record.header_record.last_update_login,
        V_header_record.header_record.creation_date,
        V_header_record.header_record.created_by,
        'CANCEL',
        nvl(V_header_record.header_record.notice_creation_date,sysdate),
        'RUNNING', -- This has to be set to running otherwise C code in rvtbm
		   -- will not pick it up
        'BATCH',
        'PENDING',
        rsl.category_id,
        rsl.quantity_shipped,
        rsl.unit_of_measure,
        'RCV',
        rsl.item_id,
        rsl.item_description,
        rsl.employee_id,
        'CANCEL',
        'VENDOR',
        v_header_record.header_record.vendor_id,
        rsl.to_organization_id,
        'PO',
        rsl.po_header_id,
        rsl.po_line_id,
        rsl.po_line_location_id,
        rsl.shipment_header_id,
        rsl.shipment_line_id,
        rsl.destination_type_code, V_header_record.header_record.processing_request_id
   FROM rcv_shipment_lines rsl
   WHERE   rsl.shipment_header_id = V_header_record.header_record.receipt_header_id and
           rsl.shipment_line_status_code <> 'CANCELLED' and
           not exists (select 'x' from rcv_transactions_interface rti
                       where
                           rti.shipment_line_id = rsl.shipment_line_id and
                           rti.shipment_header_id = rsl.shipment_header_id and
                           rti.transaction_type = 'CANCEL' and
                           rti.shipment_header_id = V_header_record.header_record.receipt_header_id) ;

END INSERT_CANCELLED_ASN_LINES;

END RCV_ASN_TRX_INSERT;

/
