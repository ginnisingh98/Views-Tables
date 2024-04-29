--------------------------------------------------------
--  DDL for Package Body RCV_INSERT_RTI_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_INSERT_RTI_SV" as
/* $Header: RCVRTIB.pls 120.2 2005/07/19 00:47:10 usethura noship $*/

/*========================= RCV_INSERT_RTI_SV   =============================*/
/*===========================================================================

  PROCEDURE NAME: insert_into_rti

===========================================================================*/

PROCEDURE insert_into_rti(
X_group_id		 IN  NUMBER,
X_transaction_type       IN  VARCHAR2,
X_transaction_date       IN  DATE,
X_processing_status_code IN  VARCHAR2,
X_processing_mode_code   IN  VARCHAR2,
X_transaction_status_code IN VARCHAR2,
X_last_update_date       IN  DATE,
X_last_updated_by        IN  NUMBER,
X_last_update_login      IN  NUMBER,
X_interface_source_code  IN  VARCHAR2,
X_creation_date          IN  DATE,
X_created_by             IN  NUMBER,
X_auto_transact_code     IN  VARCHAR2,
X_receipt_source_code    IN  VARCHAR2,
X_po_header_id           IN  NUMBER,
X_po_release_id          IN  NUMBER,
X_po_line_id             IN  NUMBER,
X_shipment_line_id       IN  NUMBER,
X_shipment_header_id     IN  NUMBER,
X_po_line_location_id    IN  NUMBER,
X_deliver_to_location_id IN  NUMBER,
X_to_organization_id     IN  NUMBER,
X_item_id                IN  NUMBER,
X_quantity_shipped       IN  NUMBER,
X_source_document_code   IN  VARCHAR2,
X_category_id            IN  NUMBER,
X_unit_of_measure        IN  VARCHAR2,
X_item_description       IN  VARCHAR2,
X_employee_id            IN  NUMBER,
X_destination_type_code  IN  VARCHAR2,
X_destination_context    IN  VARCHAR2,
X_subinventory           IN  VARCHAR2,
X_routing_header_id      IN  NUMBER,
X_primary_unit_of_measure IN  VARCHAR2,
X_ship_to_location_id    IN  NUMBER,
X_vendor_id              IN  NUMBER,
p_operating_unit_id    IN  MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE DEFAULT NULL-- New Parameter <R12 MOAC>

)  IS

X_primary_quantity   NUMBER;

BEGIN

    PO_UOM_S.uom_convert(X_quantity_shipped, X_unit_of_measure, X_item_id,
                         X_primary_unit_of_measure, X_primary_quantity);


    INSERT INTO RCV_TRANSACTIONS_INTERFACE (
         INTERFACE_TRANSACTION_ID       ,
         GROUP_ID			,
         LAST_UPDATE_DATE               ,
         LAST_UPDATED_BY                ,
         LAST_UPDATE_LOGIN              ,
         CREATION_DATE                  ,
         CREATED_BY                     ,
         TRANSACTION_TYPE               ,
         TRANSACTION_DATE               ,
         PROCESSING_STATUS_CODE         ,
         PROCESSING_MODE_CODE           ,
         TRANSACTION_STATUS_CODE        ,
         CATEGORY_ID                    ,
	 QUANTITY                       ,
         UNIT_OF_MEASURE                ,
         INTERFACE_SOURCE_CODE          ,
         ITEM_ID                        ,
         ITEM_DESCRIPTION               ,
         EMPLOYEE_ID                    ,
         AUTO_TRANSACT_CODE             ,
         SHIP_TO_LOCATION_ID            ,
         PRIMARY_QUANTITY               ,
         PRIMARY_UNIT_OF_MEASURE        ,
         RECEIPT_SOURCE_CODE            ,
         VENDOR_ID                      ,
         TO_ORGANIZATION_ID             ,
         ROUTING_HEADER_ID              ,
         SOURCE_DOCUMENT_CODE           ,
         PO_HEADER_ID                   ,
         PO_LINE_ID                     ,
         PO_LINE_LOCATION_ID            ,
         DESTINATION_TYPE_CODE          ,
         LOCATION_ID                    ,
         SUBINVENTORY                   ,
         DESTINATION_CONTEXT            ,
         SHIPMENT_HEADER_ID             ,
         SHIPMENT_LINE_ID               ,
	 ORG_ID) --<R12 MOAC>
 VALUES (
         RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL,
         X_group_id,
         X_last_update_date,
         X_last_updated_by,
         X_last_update_login,
         X_creation_date,
         X_created_by,
         X_transaction_type,
         X_transaction_date,
         X_processing_status_code,
         X_processing_mode_code,
         X_transaction_status_code,
         X_category_id,
         X_quantity_shipped,
         X_unit_of_measure,
         X_interface_source_code,
         X_item_id,
         X_item_description,
         X_employee_id,
         X_auto_transact_code,
         X_ship_to_location_id,
         X_primary_quantity,
         X_primary_unit_of_measure,
         X_receipt_source_code,
         X_vendor_id,
         X_to_organization_id,
	 X_routing_header_id,
         X_source_document_code,
         X_po_header_id,
         X_po_line_id,
         X_po_line_location_id,
         X_destination_type_code,
         X_deliver_to_location_id,
         X_subinventory,
         X_destination_context,
         X_shipment_header_id,
         X_shipment_line_id,
	 p_operating_unit_id --<R12 MOAC>
      );

END insert_into_rti;

END RCV_INSERT_RTI_SV;

/
