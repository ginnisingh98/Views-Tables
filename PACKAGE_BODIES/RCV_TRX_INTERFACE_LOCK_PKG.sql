--------------------------------------------------------
--  DDL for Package Body RCV_TRX_INTERFACE_LOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRX_INTERFACE_LOCK_PKG" as
/* $Header: RCVTIR2B.pls 120.2 2005/06/21 18:55:08 wkunz noship $ */


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Interface_Transaction_Id         NUMBER,
                     X_Group_Id                         NUMBER,
                     X_Transaction_Type                 VARCHAR2,
                     X_Transaction_Date                 DATE,
                     X_Processing_Status_Code           VARCHAR2,
                     X_Processing_Mode_Code             VARCHAR2,
                     X_Processing_Request_Id            NUMBER,
                     X_Transaction_Status_Code          VARCHAR2,
                     X_Category_Id                      NUMBER,
                     X_Quantity                         NUMBER,
                     X_Unit_Of_Measure                  VARCHAR2,
                     X_Interface_Source_Code            VARCHAR2,
                     X_Interface_Source_Line_Id         NUMBER,
                     X_Inv_Transaction_Id               NUMBER,
                     X_Item_Id                          NUMBER,
                     X_Item_Description                 VARCHAR2,
                     X_Item_Revision                    VARCHAR2,
                     X_Uom_Code                         VARCHAR2,
                     X_Employee_Id                      NUMBER,
                     X_Auto_Transact_Code               VARCHAR2,
                     X_Shipment_Header_Id               NUMBER,
                     X_Shipment_Line_Id                 NUMBER,
                     X_Ship_To_Location_Id              NUMBER,
                     X_Primary_Quantity                 NUMBER,
                     X_Primary_Unit_Of_Measure          VARCHAR2,
                     X_Receipt_Source_Code              VARCHAR2,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Id                   NUMBER,
                     X_From_Organization_Id             NUMBER,
                     X_To_Organization_Id               NUMBER,
                     X_Routing_Header_Id                NUMBER,
                     X_Routing_Step_Id                  NUMBER,
                     X_Source_Document_Code             VARCHAR2,
                     X_Parent_Transaction_Id            NUMBER,
                     X_Po_Header_Id                     NUMBER,
                     X_Po_Revision_Num                  NUMBER,
                     X_Po_Release_Id                    NUMBER,
                     X_Po_Line_Id                       NUMBER,
                     X_Po_Line_Location_Id              NUMBER,
                     X_Po_Unit_Price                    NUMBER,
                     X_Currency_Code                    VARCHAR2,
                     X_Currency_Conversion_Type         VARCHAR2,
                     X_Currency_Conversion_Rate         NUMBER,
                     X_Currency_Conversion_Date         DATE,
                     X_Po_Distribution_Id               NUMBER,
                     X_Requisition_Line_Id              NUMBER,
                     X_Req_Distribution_Id              NUMBER,
                     X_Charge_Account_Id                NUMBER,
                     X_Substitute_Unordered_Code        VARCHAR2,
                     X_Receipt_Exception_Flag           VARCHAR2,
                     X_Accrual_Status_Code              VARCHAR2,
                     X_Inspection_Status_Code           VARCHAR2,
                     X_Inspection_Quality_Code          VARCHAR2,
                     X_Destination_Type_Code            VARCHAR2,
                     X_Deliver_To_Person_Id             NUMBER,
                     X_Location_Id                      NUMBER,
                     X_Deliver_To_Location_Id           NUMBER,
                     X_Subinventory                     VARCHAR2,
                     X_Locator_Id                       NUMBER,
                     X_Wip_Entity_Id                    NUMBER,
                     X_Wip_Line_Id                      NUMBER,
                     X_Department_Code                  VARCHAR2,
                     X_Wip_Repetitive_Schedule_Id       NUMBER,
                     X_Wip_Operation_Seq_Num            NUMBER,
                     X_Wip_Resource_Seq_Num             NUMBER,
                     X_Bom_Resource_Id                  NUMBER,
                     X_Shipment_Num                     VARCHAR2,
                     X_Freight_Carrier_Code             VARCHAR2,
                     X_Bill_Of_Lading                   VARCHAR2,
                     X_Packing_Slip                     VARCHAR2,
                     X_Shipped_Date                     DATE,
                     X_Expected_Receipt_Date            DATE,
                     X_Actual_Cost                      NUMBER,
                     X_Transfer_Cost                    NUMBER,
                     X_Transportation_Cost              NUMBER,
                     X_Transportation_Account_Id        NUMBER,
                     X_Num_Of_Containers                NUMBER,
                     X_Waybill_Airbill_Num              VARCHAR2,
                     X_Vendor_Item_Num                  VARCHAR2,
                     X_Vendor_Lot_Num                   VARCHAR2,
                     X_Rma_Reference                    VARCHAR2,
                     X_Comments                         VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Ship_Head_Attribute_Category     VARCHAR2,
                     X_Ship_Head_Attribute1             VARCHAR2,
                     X_Ship_Head_Attribute2             VARCHAR2,
                     X_Ship_Head_Attribute3             VARCHAR2,
                     X_Ship_Head_Attribute4             VARCHAR2,
                     X_Ship_Head_Attribute5             VARCHAR2,
                     X_Ship_Head_Attribute6             VARCHAR2,
                     X_Ship_Head_Attribute7             VARCHAR2,
                     X_Ship_Head_Attribute8             VARCHAR2,
                     X_Ship_Head_Attribute9             VARCHAR2,
                     X_Ship_Head_Attribute10            VARCHAR2,
                     X_Ship_Head_Attribute11            VARCHAR2,
                     X_Ship_Head_Attribute12            VARCHAR2,
                     X_Ship_Head_Attribute13            VARCHAR2,
                     X_Ship_Head_Attribute14            VARCHAR2,
                     X_Ship_Head_Attribute15            VARCHAR2,
                     X_Ship_Line_Attribute_Category     VARCHAR2,
                     X_Ship_Line_Attribute1             VARCHAR2,
                     X_Ship_Line_Attribute2             VARCHAR2,
                     X_Ship_Line_Attribute3             VARCHAR2,
                     X_Ship_Line_Attribute4             VARCHAR2,
                     X_Ship_Line_Attribute5             VARCHAR2,
                     X_Ship_Line_Attribute6             VARCHAR2,
                     X_Ship_Line_Attribute7             VARCHAR2,
                     X_Ship_Line_Attribute8             VARCHAR2,
                     X_Ship_Line_Attribute9             VARCHAR2,
                     X_Ship_Line_Attribute10            VARCHAR2,
                     X_Ship_Line_Attribute11            VARCHAR2,
                     X_Ship_Line_Attribute12            VARCHAR2,
                     X_Ship_Line_Attribute13            VARCHAR2,
                     X_Ship_Line_Attribute14            VARCHAR2,
                     X_Ship_Line_Attribute15            VARCHAR2,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Reason_Id                        NUMBER,
                     X_Destination_Context              VARCHAR2,
                     X_Source_Doc_Quantity              NUMBER,
                     X_Source_Doc_Unit_Of_Measure       VARCHAR2

  ) IS
    CURSOR C IS
        SELECT *
        FROM   RCV_TRANSACTIONS_INTERFACE
        WHERE  rowid = X_Rowid
        FOR UPDATE of Interface_Transaction_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if ((Recinfo.interface_transaction_id = X_Interface_Transaction_Id)
        AND (   (Recinfo.group_id = X_Group_Id)
             OR (    (Recinfo.group_id IS NULL)

                 AND (X_Group_Id IS NULL)))
        AND (Recinfo.transaction_type = X_Transaction_Type)
        AND (Recinfo.transaction_date = X_Transaction_Date)
        AND (Recinfo.processing_status_code = X_Processing_Status_Code)
        AND (Recinfo.processing_mode_code = X_Processing_Mode_Code)
        AND (   (Recinfo.processing_request_id = X_Processing_Request_Id)
             OR (    (Recinfo.processing_request_id IS NULL)
                 AND (X_Processing_Request_Id IS NULL)))
        AND (Recinfo.transaction_status_code = X_Transaction_Status_Code)
        AND (   (Recinfo.category_id = X_Category_Id)
             OR (    (Recinfo.category_id IS NULL)
                 AND (X_Category_Id IS NULL)))
        AND (Recinfo.quantity = X_Quantity)
        AND (Recinfo.unit_of_measure = X_Unit_Of_Measure)
        AND (   (Recinfo.interface_source_code = X_Interface_Source_Code)
             OR (    (Recinfo.interface_source_code IS NULL)
                 AND (X_Interface_Source_Code IS NULL)))
        AND (   (Recinfo.interface_source_line_id = X_Interface_Source_Line_Id)
             OR (    (Recinfo.interface_source_line_id IS NULL)
                 AND (X_Interface_Source_Line_Id IS NULL)))
        AND (   (Recinfo.inv_transaction_id = X_Inv_Transaction_Id)
             OR (    (Recinfo.inv_transaction_id IS NULL)
                 AND (X_Inv_Transaction_Id IS NULL)))
        AND (   (Recinfo.item_id = X_Item_Id)
             OR (    (Recinfo.item_id IS NULL)
                 AND (X_Item_Id IS NULL)))
        AND (   (Recinfo.item_description = X_Item_Description)
             OR (    (Recinfo.item_description IS NULL)
                 AND (X_Item_Description IS NULL)))
        AND (   (Recinfo.item_revision = X_Item_Revision)
             OR (    (Recinfo.item_revision IS NULL)
                 AND (X_Item_Revision IS NULL)))
        AND (   (Recinfo.uom_code = X_Uom_Code)
             OR (    (Recinfo.uom_code IS NULL)
                 AND (X_Uom_Code IS NULL)))
        AND (   (Recinfo.employee_id = X_Employee_Id)
             OR (    (Recinfo.employee_id IS NULL)
                 AND (X_Employee_Id IS NULL)))) THEN
          IF (   (Recinfo.auto_transact_code = X_Auto_Transact_Code)
               OR (    (Recinfo.auto_transact_code IS NULL)
                   AND (X_Auto_Transact_Code IS NULL)))
          AND (   (Recinfo.shipment_header_id = X_Shipment_Header_Id)
               OR (    (Recinfo.shipment_header_id IS NULL)
                   AND (X_Shipment_Header_Id IS NULL)))
          AND (   (Recinfo.shipment_line_id = X_Shipment_Line_Id)
               OR (    (Recinfo.shipment_line_id IS NULL)
                   AND (X_Shipment_Line_Id IS NULL)))
          AND (   (Recinfo.ship_to_location_id = X_Ship_To_Location_Id)
               OR (    (Recinfo.ship_to_location_id IS NULL)
                   AND (X_Ship_To_Location_Id IS NULL)))
          AND (   (Recinfo.primary_quantity = X_Primary_Quantity)
               OR (    (Recinfo.primary_quantity IS NULL)
                   AND (X_Primary_Quantity IS NULL)))
          AND (   (Recinfo.primary_unit_of_measure = X_Primary_Unit_Of_Measure)
               OR (    (Recinfo.primary_unit_of_measure IS NULL)
                   AND (X_Primary_Unit_Of_Measure IS NULL)))
          AND (   (Recinfo.receipt_source_code = X_Receipt_Source_Code)
               OR (    (Recinfo.receipt_source_code IS NULL)
                   AND (X_Receipt_Source_Code IS NULL)))
          AND (   (Recinfo.vendor_id = X_Vendor_Id)
               OR (    (Recinfo.vendor_id IS NULL)
                   AND (X_Vendor_Id IS NULL)))
          AND (   (Recinfo.vendor_site_id = X_Vendor_Site_Id)
               OR (    (Recinfo.vendor_site_id IS NULL)
                   AND (X_Vendor_Site_Id IS NULL)))
          AND (   (Recinfo.from_organization_id = X_From_Organization_Id)
               OR (    (Recinfo.from_organization_id IS NULL)
                   AND (X_From_Organization_Id IS NULL)))
          AND (   (Recinfo.to_organization_id = X_To_Organization_Id)
               OR (    (Recinfo.to_organization_id IS NULL)
                   AND (X_To_Organization_Id IS NULL)))
          AND (   (Recinfo.routing_header_id = X_Routing_Header_Id)
               OR (    (Recinfo.routing_header_id IS NULL)
                   AND (X_Routing_Header_Id IS NULL)))
          AND (   (Recinfo.routing_step_id = X_Routing_Step_Id)
               OR (    (Recinfo.routing_step_id IS NULL)
                   AND (X_Routing_Step_Id IS NULL)))
          AND (   (Recinfo.source_document_code = X_Source_Document_Code)
               OR (    (Recinfo.source_document_code IS NULL)
                   AND (X_Source_Document_Code IS NULL)))
          AND (   (Recinfo.parent_transaction_id = X_Parent_Transaction_Id)
               OR (    (Recinfo.parent_transaction_id IS NULL)
                   AND (X_Parent_Transaction_Id IS NULL))) THEN
            IF (   (Recinfo.po_header_id = X_Po_Header_Id)
                 OR (    (Recinfo.po_header_id IS NULL)
                     AND (X_Po_Header_Id IS NULL)))
            AND (   (Recinfo.po_revision_num = X_Po_Revision_Num)
                 OR (    (Recinfo.po_revision_num IS NULL)
                     AND (X_Po_Revision_Num IS NULL)))
            AND (   (Recinfo.po_release_id = X_Po_Release_Id)
                 OR (    (Recinfo.po_release_id IS NULL)
                     AND (X_Po_Release_Id IS NULL)))
            AND (   (Recinfo.po_line_id = X_Po_Line_Id)
                 OR (    (Recinfo.po_line_id IS NULL)
                     AND (X_Po_Line_Id IS NULL)))
            AND (   (Recinfo.po_line_location_id = X_Po_Line_Location_Id)
                 OR (    (Recinfo.po_line_location_id IS NULL)
                     AND (X_Po_Line_Location_Id IS NULL)))
            AND (   (Recinfo.po_unit_price = X_Po_Unit_Price)
                 OR (    (Recinfo.po_unit_price IS NULL)
                     AND (X_Po_Unit_Price IS NULL)))
            AND (   (Recinfo.currency_code = X_Currency_Code)
                 OR (    (Recinfo.currency_code IS NULL)
                     AND (X_Currency_Code IS NULL)))
            AND (   (Recinfo.currency_conversion_type = X_Currency_Conversion_Type)
                 OR (    (Recinfo.currency_conversion_type IS NULL)
                     AND (X_Currency_Conversion_Type IS NULL)))
            AND (   (Recinfo.currency_conversion_rate = X_Currency_Conversion_Rate)
                 OR (    (Recinfo.currency_conversion_rate IS NULL)
                     AND (X_Currency_Conversion_Rate IS NULL)))
            AND (   (Recinfo.currency_conversion_date = X_Currency_Conversion_Date)
                 OR (    (Recinfo.currency_conversion_date IS NULL)
                     AND (X_Currency_Conversion_Date IS NULL)))
            AND (   (Recinfo.po_distribution_id = X_Po_Distribution_Id)
                 OR (    (Recinfo.po_distribution_id IS NULL)
                     AND (X_Po_Distribution_Id IS NULL)))
            AND (   (Recinfo.requisition_line_id = X_Requisition_Line_Id)
                 OR (    (Recinfo.requisition_line_id IS NULL)
                     AND (X_Requisition_Line_Id IS NULL)))
            AND (   (Recinfo.req_distribution_id = X_Req_Distribution_Id)
                 OR (    (Recinfo.req_distribution_id IS NULL)
                     AND (X_Req_Distribution_Id IS NULL)))
            AND (   (Recinfo.charge_account_id = X_Charge_Account_Id)
                 OR (    (Recinfo.charge_account_id IS NULL)
                     AND (X_Charge_Account_Id IS NULL)))
            AND (   (Recinfo.substitute_unordered_code = X_Substitute_Unordered_Code)
                 OR (    (Recinfo.substitute_unordered_code IS NULL)
                     AND (X_Substitute_Unordered_Code IS NULL))) THEN
              IF (   (Recinfo.receipt_exception_flag = X_Receipt_Exception_Flag)
                   OR (    (Recinfo.receipt_exception_flag IS NULL)
                       AND (X_Receipt_Exception_Flag IS NULL)))
              AND (   (Recinfo.accrual_status_code = X_Accrual_Status_Code)
                   OR (    (Recinfo.accrual_status_code IS NULL)
                       AND (X_Accrual_Status_Code IS NULL)))
              AND (   (Recinfo.inspection_status_code = X_Inspection_Status_Code)
                   OR (    (Recinfo.inspection_status_code IS NULL)
                       AND (X_Inspection_Status_Code IS NULL)))
              AND (   (Recinfo.inspection_quality_code = X_Inspection_Quality_Code)
                   OR (    (Recinfo.inspection_quality_code IS NULL)
                       AND (X_Inspection_Quality_Code IS NULL)))
              AND (   (Recinfo.destination_type_code = X_Destination_Type_Code)
                   OR (    (Recinfo.destination_type_code IS NULL)
                       AND (X_Destination_Type_Code IS NULL)))
              AND (   (Recinfo.deliver_to_person_id = X_Deliver_To_Person_Id)
                   OR (    (Recinfo.deliver_to_person_id IS NULL)
                       AND (X_Deliver_To_Person_Id IS NULL)))
              AND (   (Recinfo.location_id = X_Location_Id)
                   OR (    (Recinfo.location_id IS NULL)
                       AND (X_Location_Id IS NULL)))
              AND (   (Recinfo.deliver_to_location_id = X_Deliver_To_Location_Id)
                   OR (    (Recinfo.deliver_to_location_id IS NULL)
                       AND (X_Deliver_To_Location_Id IS NULL)))
              AND (   (Recinfo.subinventory = X_Subinventory)
                   OR (    (Recinfo.subinventory IS NULL)
                       AND (X_Subinventory IS NULL)))
              AND (   (Recinfo.locator_id = X_Locator_Id)
                   OR (    (Recinfo.locator_id IS NULL)
                       AND (X_Locator_Id IS NULL)))
              AND (   (Recinfo.wip_entity_id = X_Wip_Entity_Id)
                   OR (    (Recinfo.wip_entity_id IS NULL)
                       AND (X_Wip_Entity_Id IS NULL)))
              AND (   (Recinfo.wip_line_id = X_Wip_Line_Id)
                   OR (    (Recinfo.wip_line_id IS NULL)
                       AND (X_Wip_Line_Id IS NULL)))
              AND (   (Recinfo.department_code = X_Department_Code)
                   OR (    (Recinfo.department_code IS NULL)
                       AND (X_Department_Code IS NULL)))
              AND (   (Recinfo.wip_repetitive_schedule_id = X_Wip_Repetitive_Schedule_Id)
                   OR (    (Recinfo.wip_repetitive_schedule_id IS NULL)
                       AND (X_Wip_Repetitive_Schedule_Id IS NULL)))
              AND (   (Recinfo.wip_operation_seq_num = X_Wip_Operation_Seq_Num)
                   OR (    (Recinfo.wip_operation_seq_num IS NULL)
                       AND (X_Wip_Operation_Seq_Num IS NULL)))
              AND (   (Recinfo.wip_resource_seq_num = X_Wip_Resource_Seq_Num)
                   OR (    (Recinfo.wip_resource_seq_num IS NULL)
                       AND (X_Wip_Resource_Seq_Num IS NULL))) THEN
                IF (   (Recinfo.bom_resource_id = X_Bom_Resource_Id)
                     OR (    (Recinfo.bom_resource_id IS NULL)
                         AND (X_Bom_Resource_Id IS NULL)))
                AND (   (Recinfo.shipment_num = X_Shipment_Num)
                     OR (    (Recinfo.shipment_num IS NULL)
                         AND (X_Shipment_Num IS NULL)))
                AND (   (Recinfo.freight_carrier_code = X_Freight_Carrier_Code)
                     OR (    (Recinfo.freight_carrier_code IS NULL)
                         AND (X_Freight_Carrier_Code IS NULL)))
                AND (   (Recinfo.bill_of_lading = X_Bill_Of_Lading)
                     OR (    (Recinfo.bill_of_lading IS NULL)
                         AND (X_Bill_Of_Lading IS NULL)))
                AND (   (Recinfo.packing_slip = X_Packing_Slip)
                     OR (    (Recinfo.packing_slip IS NULL)
                         AND (X_Packing_Slip IS NULL)))
                AND (   (Recinfo.shipped_date = X_Shipped_Date)
                     OR (    (Recinfo.shipped_date IS NULL)
                         AND (X_Shipped_Date IS NULL)))
                AND (   (Recinfo.expected_receipt_date = X_Expected_Receipt_Date)
                     OR (    (Recinfo.expected_receipt_date IS NULL)
                         AND (X_Expected_Receipt_Date IS NULL)))
                AND (   (Recinfo.actual_cost = X_Actual_Cost)
                     OR (    (Recinfo.actual_cost IS NULL)
                         AND (X_Actual_Cost IS NULL)))
                AND (   (Recinfo.transfer_cost = X_Transfer_Cost)
                     OR (    (Recinfo.transfer_cost IS NULL)
                         AND (X_Transfer_Cost IS NULL)))
                AND (   (Recinfo.transportation_cost = X_Transportation_Cost)
                     OR (    (Recinfo.transportation_cost IS NULL)
                         AND (X_Transportation_Cost IS NULL)))
                AND (   (Recinfo.transportation_account_id = X_Transportation_Account_Id)
                     OR (    (Recinfo.transportation_account_id IS NULL)
                         AND (X_Transportation_Account_Id IS NULL)))
                AND (   (Recinfo.num_of_containers = X_Num_Of_Containers)
                     OR (    (Recinfo.num_of_containers IS NULL)
                         AND (X_Num_Of_Containers IS NULL))) THEN
                  IF (   (Recinfo.waybill_airbill_num = X_Waybill_Airbill_Num)
                       OR (    (Recinfo.waybill_airbill_num IS NULL)
                           AND (X_Waybill_Airbill_Num IS NULL)))
                  AND (   (Recinfo.vendor_item_num = X_Vendor_Item_Num)
                       OR (    (Recinfo.vendor_item_num IS NULL)
                           AND (X_Vendor_Item_Num IS NULL)))
                  AND (   (Recinfo.vendor_lot_num = X_Vendor_Lot_Num)
                       OR (    (Recinfo.vendor_lot_num IS NULL)
                           AND (X_Vendor_Lot_Num IS NULL)))
                  AND (   (Recinfo.rma_reference = X_Rma_Reference)
                       OR (    (Recinfo.rma_reference IS NULL)
                           AND (X_Rma_Reference IS NULL)))
                  AND (   (Recinfo.comments = X_Comments)
                       OR (    (Recinfo.comments IS NULL)
                           AND (X_Comments IS NULL)))
                  AND (   (Recinfo.attribute_category = X_Attribute_Category)
                       OR (    (Recinfo.attribute_category IS NULL)
                           AND (X_Attribute_Category IS NULL)))
                  AND (   (Recinfo.attribute1 = X_Attribute1)
                       OR (    (Recinfo.attribute1 IS NULL)
                           AND (X_Attribute1 IS NULL)))
                  AND (   (Recinfo.attribute2 = X_Attribute2)
                       OR (    (Recinfo.attribute2 IS NULL)
                           AND (X_Attribute2 IS NULL)))
                  AND (   (Recinfo.attribute3 = X_Attribute3)
                       OR (    (Recinfo.attribute3 IS NULL)
                           AND (X_Attribute3 IS NULL)))
                  AND (   (Recinfo.attribute4 = X_Attribute4)
                       OR (    (Recinfo.attribute4 IS NULL)
                           AND (X_Attribute4 IS NULL)))
                  AND (   (Recinfo.attribute5 = X_Attribute5)
                       OR (    (Recinfo.attribute5 IS NULL)
                           AND (X_Attribute5 IS NULL)))
                  AND (   (Recinfo.attribute6 = X_Attribute6)
                       OR (    (Recinfo.attribute6 IS NULL)
                           AND (X_Attribute6 IS NULL)))
                  AND (   (Recinfo.attribute7 = X_Attribute7)
                       OR (    (Recinfo.attribute7 IS NULL)
                           AND (X_Attribute7 IS NULL)))
                  AND (   (Recinfo.attribute8 = X_Attribute8)
                       OR (    (Recinfo.attribute8 IS NULL)
                           AND (X_Attribute8 IS NULL)))
                  AND (   (Recinfo.attribute9 = X_Attribute9)
                       OR (    (Recinfo.attribute9 IS NULL)
                           AND (X_Attribute9 IS NULL)))
                  AND (   (Recinfo.attribute10 = X_Attribute10)
                       OR (    (Recinfo.attribute10 IS NULL)
                           AND (X_Attribute10 IS NULL)))
                  AND (   (Recinfo.attribute11 = X_Attribute11)
                       OR (    (Recinfo.attribute11 IS NULL)
                           AND (X_Attribute11 IS NULL)))
                  AND (   (Recinfo.attribute12 = X_Attribute12)
                       OR (    (Recinfo.attribute12 IS NULL)
                           AND (X_Attribute12 IS NULL)))
                  AND (   (Recinfo.attribute13 = X_Attribute13)
                       OR (    (Recinfo.attribute13 IS NULL)
                           AND (X_Attribute13 IS NULL)))
                  AND (   (Recinfo.attribute14 = X_Attribute14)
                       OR (    (Recinfo.attribute14 IS NULL)
                           AND (X_Attribute14 IS NULL)))
                  AND (   (Recinfo.attribute15 = X_Attribute15)
                       OR (    (Recinfo.attribute15 IS NULL)
                           AND (X_Attribute15 IS NULL))) THEN
                    IF (   (Recinfo.ship_head_attribute_category = X_Ship_Head_Attribute_Category)
                         OR (    (Recinfo.ship_head_attribute_category IS NULL)
                             AND (X_Ship_Head_Attribute_Category IS NULL)))
                    AND (   (Recinfo.ship_head_attribute1 = X_Ship_Head_Attribute1)
                         OR (    (Recinfo.ship_head_attribute1 IS NULL)
                             AND (X_Ship_Head_Attribute1 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute2 = X_Ship_Head_Attribute2)
                         OR (    (Recinfo.ship_head_attribute2 IS NULL)
                             AND (X_Ship_Head_Attribute2 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute3 = X_Ship_Head_Attribute3)
                         OR (    (Recinfo.ship_head_attribute3 IS NULL)
                             AND (X_Ship_Head_Attribute3 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute4 = X_Ship_Head_Attribute4)
                         OR (    (Recinfo.ship_head_attribute4 IS NULL)
                             AND (X_Ship_Head_Attribute4 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute5 = X_Ship_Head_Attribute5)
                         OR (    (Recinfo.ship_head_attribute5 IS NULL)
                             AND (X_Ship_Head_Attribute5 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute6 = X_Ship_Head_Attribute6)
                         OR (    (Recinfo.ship_head_attribute6 IS NULL)
                             AND (X_Ship_Head_Attribute6 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute7 = X_Ship_Head_Attribute7)
                         OR (    (Recinfo.ship_head_attribute7 IS NULL)
                             AND (X_Ship_Head_Attribute7 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute8 = X_Ship_Head_Attribute8)
                         OR (    (Recinfo.ship_head_attribute8 IS NULL)
                             AND (X_Ship_Head_Attribute8 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute9 = X_Ship_Head_Attribute9)
                         OR (    (Recinfo.ship_head_attribute9 IS NULL)
                             AND (X_Ship_Head_Attribute9 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute10 = X_Ship_Head_Attribute10)
                         OR (    (Recinfo.ship_head_attribute10 IS NULL)
                             AND (X_Ship_Head_Attribute10 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute11 = X_Ship_Head_Attribute11)
                         OR (    (Recinfo.ship_head_attribute11 IS NULL)
                             AND (X_Ship_Head_Attribute11 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute12 = X_Ship_Head_Attribute12)
                         OR (    (Recinfo.ship_head_attribute12 IS NULL)
                             AND (X_Ship_Head_Attribute12 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute13 = X_Ship_Head_Attribute13)
                         OR (    (Recinfo.ship_head_attribute13 IS NULL)
                             AND (X_Ship_Head_Attribute13 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute14 = X_Ship_Head_Attribute14)
                         OR (    (Recinfo.ship_head_attribute14 IS NULL)
                             AND (X_Ship_Head_Attribute14 IS NULL)))
                    AND (   (Recinfo.ship_head_attribute15 = X_Ship_Head_Attribute15)
                         OR (    (Recinfo.ship_head_attribute15 IS NULL)
                             AND (X_Ship_Head_Attribute15 IS NULL)))
                    AND (   (Recinfo.ship_line_attribute_category = X_Ship_Line_Attribute_Category)
                         OR (    (Recinfo.ship_line_attribute_category IS NULL)
                             AND (X_Ship_Line_Attribute_Category IS NULL))) THEN
                      IF (   (Recinfo.ship_line_attribute1 = X_Ship_Line_Attribute1)
                           OR (    (Recinfo.ship_line_attribute1 IS NULL)
                               AND (X_Ship_Line_Attribute1 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute2 = X_Ship_Line_Attribute2)
                           OR (    (Recinfo.ship_line_attribute2 IS NULL)
                               AND (X_Ship_Line_Attribute2 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute3 = X_Ship_Line_Attribute3)
                           OR (    (Recinfo.ship_line_attribute3 IS NULL)
                               AND (X_Ship_Line_Attribute3 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute4 = X_Ship_Line_Attribute4)
                           OR (    (Recinfo.ship_line_attribute4 IS NULL)
                               AND (X_Ship_Line_Attribute4 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute5 = X_Ship_Line_Attribute5)
                           OR (    (Recinfo.ship_line_attribute5 IS NULL)
                               AND (X_Ship_Line_Attribute5 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute6 = X_Ship_Line_Attribute6)
                           OR (    (Recinfo.ship_line_attribute6 IS NULL)
                               AND (X_Ship_Line_Attribute6 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute7 = X_Ship_Line_Attribute7)
                           OR (    (Recinfo.ship_line_attribute7 IS NULL)
                               AND (X_Ship_Line_Attribute7 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute8 = X_Ship_Line_Attribute8)
                           OR (    (Recinfo.ship_line_attribute8 IS NULL)
                               AND (X_Ship_Line_Attribute8 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute9 = X_Ship_Line_Attribute9)
                           OR (    (Recinfo.ship_line_attribute9 IS NULL)
                               AND (X_Ship_Line_Attribute9 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute10 = X_Ship_Line_Attribute10)
                           OR (    (Recinfo.ship_line_attribute10 IS NULL)
                               AND (X_Ship_Line_Attribute10 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute11 = X_Ship_Line_Attribute11)
                           OR (    (Recinfo.ship_line_attribute11 IS NULL)
                               AND (X_Ship_Line_Attribute11 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute12 = X_Ship_Line_Attribute12)
                           OR (    (Recinfo.ship_line_attribute12 IS NULL)
                               AND (X_Ship_Line_Attribute12 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute13 = X_Ship_Line_Attribute13)
                           OR (    (Recinfo.ship_line_attribute13 IS NULL)
                               AND (X_Ship_Line_Attribute13 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute14 = X_Ship_Line_Attribute14)
                           OR (    (Recinfo.ship_line_attribute14 IS NULL)
                               AND (X_Ship_Line_Attribute14 IS NULL)))
                      AND (   (Recinfo.ship_line_attribute15 = X_Ship_Line_Attribute15)
                           OR (    (Recinfo.ship_line_attribute15 IS NULL)
                               AND (X_Ship_Line_Attribute15 IS NULL))) THEN
                        IF (   (Recinfo.ussgl_transaction_code = X_Ussgl_Transaction_Code)
                             OR (    (Recinfo.ussgl_transaction_code IS NULL)
                                 AND (X_Ussgl_Transaction_Code IS NULL)))
                        AND (   (Recinfo.government_context = X_Government_Context)
                             OR (    (Recinfo.government_context IS NULL)
                                 AND (X_Government_Context IS NULL)))
                        AND (   (Recinfo.reason_id = X_Reason_Id)
                             OR (    (Recinfo.reason_id IS NULL)
                                 AND (X_Reason_Id IS NULL)))
                        AND (   (Recinfo.destination_context = X_Destination_Context)
                             OR (    (Recinfo.destination_context IS NULL)
                                 AND (X_Destination_Context IS NULL)))
                        AND (   (Recinfo.source_doc_quantity = X_Source_Doc_Quantity)
                             OR (    (Recinfo.source_doc_quantity IS NULL)
                                 AND (X_Source_Doc_Quantity IS NULL)))
                        AND (   (Recinfo.source_doc_unit_of_measure = X_Source_Doc_Unit_Of_Measure)
                             OR (    (Recinfo.source_doc_unit_of_measure IS NULL)
                                 AND (X_Source_Doc_Unit_Of_Measure IS NULL))) then
                                return;
                        else
                           FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                           APP_EXCEPTION.RAISE_EXCEPTION;
                        end if;
                      else
                        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                        APP_EXCEPTION.RAISE_EXCEPTION;
                      end if;
                    else
                      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                      APP_EXCEPTION.RAISE_EXCEPTION;
                    end if;
                  else
                    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                    APP_EXCEPTION.RAISE_EXCEPTION;
                  end if;
                else
                  FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                  APP_EXCEPTION.RAISE_EXCEPTION;
                end if;
              else
                FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                APP_EXCEPTION.RAISE_EXCEPTION;
              end if;
            else
              FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
              APP_EXCEPTION.RAISE_EXCEPTION;
            end if;
          else
            FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
            APP_EXCEPTION.RAISE_EXCEPTION;
          end if;
        else
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        end if;
  END Lock_Row;

END RCV_TRX_INTERFACE_LOCK_PKG;

/
