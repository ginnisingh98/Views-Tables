--------------------------------------------------------
--  DDL for Package Body MTL_TXNS_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_TXNS_TEMP_PKG" as
/* $Header: INVTVTMB.pls 120.2.12000000.2 2007/02/21 06:51:50 rkatoori ship $ */
/* 31-May-2000   Added three column lpn_id, transfer_lpn_id and transfer_cost_group_id
to take care of 11i related inventory enhancements  					*/

  PROCEDURE Lock_Row(
 X_ROWID                                    VARCHAR2,
 X_TRANSACTION_HEADER_ID                    NUMBER,
 X_TRANSACTION_TEMP_ID                      NUMBER,
 X_SOURCE_CODE                              VARCHAR2,
 X_SOURCE_LINE_ID                           NUMBER,
 X_TRANSACTION_MODE                         NUMBER,
 X_LOCK_FLAG                                VARCHAR2,
 X_LAST_UPDATE_DATE                	    DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_CREATION_DATE                            DATE,
 X_CREATED_BY                               NUMBER,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_REQUEST_ID                               NUMBER,
 X_PROGRAM_APPLICATION_ID                   NUMBER,
 X_PROGRAM_ID                               NUMBER,
 X_PROGRAM_UPDATE_DATE                      DATE,
 X_INVENTORY_ITEM_ID                        NUMBER,
 X_REVISION                                 VARCHAR2,
 X_ORGANIZATION_ID                          NUMBER,
 X_SUBINVENTORY_CODE                        VARCHAR2,
 X_LOCATOR_ID                               NUMBER,
 X_TRANSACTION_QUANTITY                     NUMBER,
 X_PRIMARY_QUANTITY                         NUMBER,
 X_TRANSACTION_UOM                          VARCHAR2,
 X_TRANSACTION_COST                         NUMBER,
 X_COST_GROUP_ID                            NUMBER,
 X_TRANSACTION_TYPE_ID                      NUMBER,
 X_TRANSACTION_ACTION_ID                    NUMBER,
 X_TRANSACTION_SOURCE_TYPE_ID               NUMBER,
 X_TRANSACTION_SOURCE_ID                    NUMBER,
 X_TRANSACTION_SOURCE_NAME                  VARCHAR2,
 X_TRANSACTION_DATE                         DATE,
 X_ACCT_PERIOD_ID                           NUMBER,
 X_DISTRIBUTION_ACCOUNT_ID                  NUMBER,
 X_TRANSACTION_REFERENCE                    VARCHAR2,
 X_REASON_ID                                NUMBER,
 X_LOT_NUMBER                               VARCHAR2,
 X_LOT_EXPIRATION_DATE                      DATE,
 X_SERIAL_NUMBER                            VARCHAR2,
 X_RECEIVING_DOCUMENT                       VARCHAR2,
 X_RCV_TRANSACTION_ID                       NUMBER,
 X_MOVE_TRANSACTION_ID                      NUMBER,
 X_COMPLETION_TRANSACTION_ID                NUMBER,
 X_WIP_ENTITY_TYPE                          NUMBER,
 X_SCHEDULE_ID                              NUMBER,
 X_EMPLOYEE_CODE                            VARCHAR2,
 X_SCHEDULE_UPDATE_CODE                     NUMBER,
 X_SETUP_TEARDOWN_CODE                      NUMBER,
 X_OPERATION_SEQ_NUM                        NUMBER,
 X_PICKING_LINE_ID                          NUMBER,
 X_TRX_SOURCE_LINE_ID                       NUMBER,
 X_TRX_SOURCE_DELIVERY_ID                   NUMBER,
 X_PHYSICAL_ADJUSTMENT_ID                   NUMBER,
 X_CYCLE_COUNT_ID                           NUMBER,
 X_RMA_LINE_ID                              NUMBER,
 X_CUSTOMER_SHIP_ID                         NUMBER,
 X_CURRENCY_CODE                            VARCHAR2,
 X_CURRENCY_CONVERSION_RATE                 NUMBER,
 X_CURRENCY_CONVERSION_TYPE                 VARCHAR2,
 X_CURRENCY_CONVERSION_DATE                 DATE,
 X_USSGL_TRANSACTION_CODE                   VARCHAR2,
 X_VENDOR_LOT_NUMBER                        VARCHAR2,
 X_ENCUMBRANCE_ACCOUNT                      NUMBER,
 X_ENCUMBRANCE_AMOUNT                       NUMBER,
 X_SHIPMENT_NUMBER                          VARCHAR2,
 X_TRANSFER_COST                            NUMBER,
 X_TRANSPORTATION_COST                      NUMBER,
 X_TRANSPORTATION_ACCOUNT                   NUMBER,
 X_FREIGHT_CODE                             VARCHAR2,
 X_CONTAINERS                               NUMBER,
 X_WAYBILL_AIRBILL                          VARCHAR2,
 X_EXPECTED_ARRIVAL_DATE                    DATE,
 X_TRANSFER_SUBINVENTORY                    VARCHAR2,
 X_TRANSFER_ORGANIZATION                    NUMBER,
 X_TRANSFER_TO_LOCATION                     NUMBER,
 X_NEW_AVERAGE_COST                         NUMBER,
 X_VALUE_CHANGE                             NUMBER,
 X_PERCENTAGE_CHANGE                        NUMBER,
 X_MATERIAL_ALLOCATION_TEMP_ID              NUMBER,
 X_DEMAND_SOURCE_HEADER_ID                  NUMBER,
 X_DEMAND_SOURCE_LINE                       VARCHAR2,
 X_DEMAND_SOURCE_DELIVERY                   VARCHAR2,
 X_ITEM_DESCRIPTION                         VARCHAR2,
 X_WIP_SUPPLY_TYPE                          NUMBER,
 X_POSTING_FLAG                             VARCHAR2,
 X_PROCESS_FLAG                             VARCHAR2,
 X_ERROR_CODE                               VARCHAR2,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2,
 X_PRIMARY_SWITCH                           NUMBER,
 X_DEPARTMENT_CODE                          VARCHAR2,
 X_ERROR_EXPLANATION                        VARCHAR2,
 X_DEMAND_ID                                NUMBER,
 X_REQUISITION_LINE_ID                      NUMBER,
 X_REQUISITION_DISTRIBUTION_ID              NUMBER,
 X_MOVEMENT_ID                              NUMBER,
 X_SOURCE_PROJECT_ID                        NUMBER,
 X_SOURCE_TASK_ID                           NUMBER,
 X_PROJECT_ID                               NUMBER,
 X_TASK_ID                                  NUMBER,
 X_TO_PROJECT_ID                            NUMBER,
 X_TO_TASK_ID                               NUMBER,
 X_PA_EXPENDITURE_ORG_ID                    NUMBER,
 X_EXPENDITURE_TYPE                         VARCHAR2,
 X_LPN_ID				    NUMBER,
 X_TRANSFER_LPN_ID			    NUMBER,
 X_TRANSFER_COST_GROUP_ID	 	    NUMBER,
 X_CONTENT_LPN_ID			    NUMBER
) IS
    CURSOR C IS
        SELECT *
        FROM   mtl_material_transactions_temp
        WHERE  rowid = X_Rowid
        FOR UPDATE of Transaction_Header_Id NOWAIT;
   Recinfo C%ROWTYPE;
   RECORD_CHANGED EXCEPTION;

  BEGIN
        OPEN C;
        FETCH C INTO Recinfo;
        if (C%NOTFOUND) then
          CLOSE C;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	 APP_EXCEPTION.Raise_Exception;
        end if;
        CLOSE C;
        if not (
              (   (Recinfo.transaction_header_id =  X_Transaction_Header_Id)
                OR (    (Recinfo.transaction_header_id IS NULL)
                    AND (X_Transaction_Header_Id IS NULL)))
           AND (   (Recinfo.transaction_temp_id =  X_Transaction_Temp_Id)
                OR (    (Recinfo.transaction_temp_id IS NULL)
                    AND (X_Transaction_Temp_Id IS NULL)))
          AND (   (Recinfo.source_code =  X_Source_Code)
                OR (    (Recinfo.source_code IS NULL)
                    AND (X_Source_Code IS NULL)))
           AND (   (Recinfo.source_line_id =  X_Source_Line_Id)
                OR (    (Recinfo.source_line_id IS NULL)
                    AND (X_Source_Line_Id IS NULL)))
          AND (   (Recinfo.transaction_mode =  X_Transaction_Mode)
                OR (    (Recinfo.transaction_mode IS NULL)
                    AND (X_Transaction_Mode IS NULL)))
           AND (   (Recinfo.lock_flag =  X_Lock_Flag)
                OR (    (Recinfo.lock_flag IS NULL)
                    AND (X_Lock_Flag IS NULL)))
          AND (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
           AND (   (Recinfo.revision =  X_Revision)
                OR (    (Recinfo.revision IS NULL)
                    AND (X_Revision IS NULL)))
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (   (Recinfo.subinventory_code =  X_Subinventory_Code)
               OR (    (Recinfo.subinventory_code IS NULL)
                    AND (X_Subinventory_Code IS NULL)))
           AND (   (Recinfo.locator_id =  X_Locator_Id)
                OR (    (Recinfo.locator_id IS NULL)
                    AND (X_Locator_Id IS NULL)))
           AND (Recinfo.transaction_quantity =  X_Transaction_Quantity)
          AND (Recinfo.primary_quantity =  X_Primary_Quantity)
           AND (Recinfo.transaction_uom =  X_Transaction_Uom)
           AND (   (Recinfo.transaction_cost =  X_Transaction_Cost)
                OR (    (Recinfo.transaction_cost IS NULL)
                    AND (X_Transaction_Cost IS NULL)))
           AND (   (Recinfo.cost_group_id =  X_cost_group_id)
                OR (    (Recinfo.cost_group_id IS NULL)
                    AND (X_cost_group_id IS NULL)))
           AND (Recinfo.transaction_type_id =  X_Transaction_Type_Id)
          AND (Recinfo.transaction_action_id =  X_Transaction_Action_Id)
           AND (Recinfo.transaction_source_type_id =  X_Transaction_Source_Type_Id)
           AND (   (Recinfo.transaction_source_id =  X_Transaction_Source_Id)
                OR (    (Recinfo.transaction_source_id IS NULL)
                    AND (X_Transaction_Source_Id IS NULL)))
           AND (   (Recinfo.transaction_source_name =  X_Transaction_Source_Name)
               OR (    (Recinfo.transaction_source_name IS NULL)
                    AND (X_Transaction_Source_Name IS NULL)))
           AND (Recinfo.transaction_date =  X_Transaction_Date)
           AND (Recinfo.acct_period_id =  X_Acct_Period_Id)
           AND (   (Recinfo.distribution_account_id =  X_Distribution_Account_Id)
                OR (    (Recinfo.distribution_account_id IS NULL)
                   AND (X_Distribution_Account_Id IS NULL)))
           AND (   (Recinfo.transaction_reference =  X_Transaction_Reference)
                OR (    (Recinfo.transaction_reference IS NULL)
                    AND (X_Transaction_Reference IS NULL)))
           AND (   (Recinfo.reason_id =  X_Reason_Id)
                OR (    (Recinfo.reason_id IS NULL)
                   AND (X_Reason_Id IS NULL)))
           AND (   (Recinfo.lot_number =  X_Lot_Number)
                OR (    (Recinfo.lot_number IS NULL)
                    AND (X_Lot_Number IS NULL)))
           AND (   (Recinfo.lot_expiration_date =  X_Lot_Expiration_Date)
                OR (    (Recinfo.lot_expiration_date IS NULL)
                   AND (X_Lot_Expiration_Date IS NULL)))
           AND (   (Recinfo.serial_number =  X_Serial_Number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_Serial_Number IS NULL)))
           AND (   (Recinfo.receiving_document =  X_Receiving_Document)
                OR (    (Recinfo.receiving_document IS NULL)
                   AND (X_Receiving_Document IS NULL)))
           AND (   (Recinfo.rcv_transaction_id =  X_Rcv_Transaction_Id)
                OR (    (Recinfo.rcv_transaction_id IS NULL)
                    AND (X_Rcv_Transaction_Id IS NULL)))
           AND (   (Recinfo.move_transaction_id =  X_Move_Transaction_Id)
                OR (    (Recinfo.move_transaction_id IS NULL)
                   AND (X_Move_Transaction_Id IS NULL)))
           AND (   (Recinfo.completion_transaction_id =  X_Completion_Transaction_Id)
                OR (    (Recinfo.completion_transaction_id IS NULL)
                    AND (X_Completion_Transaction_Id IS NULL)))
           AND (   (Recinfo.wip_entity_type =  X_Wip_Entity_Type)
                OR (    (Recinfo.wip_entity_type IS NULL)
                   AND (X_Wip_Entity_Type IS NULL)))
           AND (   (Recinfo.schedule_id =  X_Schedule_Id)
                OR (    (Recinfo.schedule_id IS NULL)
                    AND (X_Schedule_Id IS NULL)))
           AND (   (Recinfo.employee_code =  X_Employee_Code)
                OR (    (Recinfo.employee_code IS NULL)
                    AND (X_Employee_Code IS NULL)))
           AND (   (Recinfo.schedule_update_code =  X_Schedule_Update_Code)
                OR (    (Recinfo.schedule_update_code IS NULL)
                   AND (X_Schedule_Update_Code IS NULL)))
           AND (   (Recinfo.lpn_id =  X_lpn_id)
                OR (    (Recinfo.lpn_id IS NULL)
                   AND (X_lpn_id IS NULL)))
           AND (   (Recinfo.content_lpn_id =  X_content_lpn_id)
                OR (    (Recinfo.content_lpn_id IS NULL)
                   AND (X_content_lpn_id IS NULL)))
           AND (   (Recinfo.transfer_lpn_id =  X_transfer_lpn_id)
                OR (    (Recinfo.transfer_lpn_id IS NULL)
                   AND (X_transfer_lpn_id IS NULL)))
           AND (   (Recinfo.transfer_cost_group_id =  X_transfer_cost_group_id)
                OR (    (Recinfo.transfer_cost_group_id IS NULL)
                   AND (X_transfer_cost_group_id IS NULL)))
	) then
                RAISE RECORD_CHANGED;
                end if;
	  if not (
            (   (Recinfo.setup_teardown_code =  X_Setup_Teardown_Code)
                OR (    (Recinfo.setup_teardown_code IS NULL)
                    AND (X_Setup_Teardown_Code IS NULL)))
           AND (   (Recinfo.operation_seq_num =  X_Operation_Seq_Num)
                OR (    (Recinfo.operation_seq_num IS NULL)
                   AND (X_Operation_Seq_Num IS NULL)))
           AND (   (Recinfo.picking_line_id =  X_Picking_Line_Id)
                OR (    (Recinfo.picking_line_id IS NULL)
                    AND (X_Picking_Line_Id IS NULL)))
           AND (   (Recinfo.trx_source_line_id =  X_Trx_Source_Line_Id)
                OR (    (Recinfo.trx_source_line_id IS NULL)
                   AND (X_Trx_Source_Line_Id IS NULL)))
           AND (   (Recinfo.trx_source_delivery_id =  X_Trx_Source_Delivery_Id)
                OR (    (Recinfo.trx_source_delivery_id IS NULL)
                    AND (X_Trx_Source_Delivery_Id IS NULL)))
           AND (   (Recinfo.physical_adjustment_id =  X_Physical_Adjustment_Id)
                OR (    (Recinfo.physical_adjustment_id IS NULL)
                   AND (X_Physical_Adjustment_Id IS NULL)))
           AND (   (Recinfo.cycle_count_id =  X_Cycle_Count_Id)
                OR (    (Recinfo.cycle_count_id IS NULL)
                    AND (X_Cycle_Count_Id IS NULL)))
           AND (   (Recinfo.rma_line_id =  X_Rma_Line_Id)
                OR (    (Recinfo.rma_line_id IS NULL)
                   AND (X_Rma_Line_Id IS NULL)))
           AND (   (Recinfo.customer_ship_id =  X_Customer_Ship_Id)
                OR (    (Recinfo.customer_ship_id IS NULL)
                    AND (X_Customer_Ship_Id IS NULL)))
           AND (   (Recinfo.currency_code =  X_Currency_Code)
                OR (    (Recinfo.currency_code IS NULL)
                   AND (X_Currency_Code IS NULL)))
           AND (   (Recinfo.currency_conversion_rate =  X_Currency_Conversion_Rate)
                OR (    (Recinfo.currency_conversion_rate IS NULL)
                    AND (X_Currency_Conversion_Rate IS NULL)))
           AND (   (Recinfo.currency_conversion_type =  X_Currency_Conversion_Type)
                OR (    (Recinfo.currency_conversion_type IS NULL)
                   AND (X_Currency_Conversion_Type IS NULL)))
           AND (   (Recinfo.currency_conversion_date =  X_Currency_Conversion_Date)
                OR (    (Recinfo.currency_conversion_date IS NULL)
                    AND (X_Currency_Conversion_Date IS NULL)))
           AND (   (Recinfo.ussgl_transaction_code =  X_Ussgl_Transaction_Code)
                OR (    (Recinfo.ussgl_transaction_code IS NULL)
                   AND (X_Ussgl_Transaction_Code IS NULL)))
           AND (   (Recinfo.vendor_lot_number =  X_Vendor_Lot_Number)
                OR (    (Recinfo.vendor_lot_number IS NULL)
                    AND (X_Vendor_Lot_Number IS NULL)))
           AND (   (Recinfo.encumbrance_account =  X_Encumbrance_Account)
                OR (    (Recinfo.encumbrance_account IS NULL)
                   AND (X_Encumbrance_Account IS NULL)))
           AND (   (Recinfo.encumbrance_amount =  X_Encumbrance_Amount)
                OR (    (Recinfo.encumbrance_amount IS NULL)
                    AND (X_Encumbrance_Amount IS NULL)))
           AND (   (Recinfo.shipment_number =  X_Shipment_Number)
                OR (    (Recinfo.shipment_number IS NULL)
                    AND (X_Shipment_Number IS NULL)))
           AND (   (Recinfo.transfer_cost =  X_Transfer_Cost)
                OR (    (Recinfo.transfer_cost IS NULL)
                   AND (X_Transfer_Cost IS NULL)))
           AND (   (Recinfo.transportation_cost =  X_Transportation_Cost)
                OR (    (Recinfo.transportation_cost IS NULL)
                    AND (X_Transportation_Cost IS NULL)))
           AND (   (Recinfo.transportation_account =  X_Transportation_Account)
                OR (    (Recinfo.transportation_account IS NULL)
                   AND (X_Transportation_Account IS NULL)))
           AND (   (Recinfo.freight_code =  X_Freight_Code)
                OR (    (Recinfo.freight_code IS NULL)
                    AND (X_Freight_Code IS NULL)))
           AND (   (Recinfo.containers =  X_Containers)
                OR (    (Recinfo.containers IS NULL)
                   AND (X_Containers IS NULL)))
           AND (   (Recinfo.waybill_airbill =  X_Waybill_Airbill)
                OR (    (Recinfo.waybill_airbill IS NULL)
                    AND (X_Waybill_Airbill IS NULL)))
           AND (   (Recinfo.expected_arrival_date =  X_Expected_Arrival_Date)
                OR (    (Recinfo.expected_arrival_date IS NULL)
                   AND (X_Expected_Arrival_Date IS NULL)))
           AND (   (Recinfo.transfer_subinventory =  X_Transfer_Subinventory)
                OR (    (Recinfo.transfer_subinventory IS NULL)
                    AND (X_Transfer_Subinventory IS NULL)))
           AND (   (Recinfo.transfer_organization =  X_Transfer_Organization)
                OR (    (Recinfo.transfer_organization IS NULL)
                   AND (X_Transfer_Organization IS NULL)))
           AND (   (Recinfo.transfer_to_location =  X_Transfer_To_Location)
                OR (    (Recinfo.transfer_to_location IS NULL)
                    AND (X_Transfer_To_Location IS NULL)))
	) then
                RAISE RECORD_CHANGED;
                end if;
	  if not (
            (   (Recinfo.new_average_cost =  X_New_Average_Cost)
                OR (    (Recinfo.new_average_cost IS NULL)
                   AND (X_New_Average_Cost IS NULL)))
           AND (   (Recinfo.value_change =  X_Value_Change)
                OR (    (Recinfo.value_change IS NULL)
                    AND (X_Value_Change IS NULL)))
           AND (   (Recinfo.percentage_change =  X_Percentage_Change)
                OR (    (Recinfo.percentage_change IS NULL)
                   AND (X_Percentage_Change IS NULL)))
           AND (   (Recinfo.material_allocation_temp_id =  X_Material_Allocation_Temp_Id)
                OR (    (Recinfo.material_allocation_temp_id IS NULL)
                    AND (X_Material_Allocation_Temp_Id IS NULL)))
           AND (   (Recinfo.demand_source_header_id =  X_Demand_Source_Header_Id)
                OR (    (Recinfo.demand_source_header_id IS NULL)
                   AND (X_Demand_Source_Header_Id IS NULL)))
           AND (   (Recinfo.demand_source_line =  X_Demand_Source_Line)
                OR (    (Recinfo.demand_source_line IS NULL)
                    AND (X_Demand_Source_Line IS NULL)))
           AND (   (Recinfo.demand_source_delivery =  X_Demand_Source_Delivery)
                OR (    (Recinfo.demand_source_delivery IS NULL)
                   AND (X_Demand_Source_Delivery IS NULL)))
--           AND (   (Recinfo.item_description =  X_Item_Description)
  --              OR (    (Recinfo.item_description IS NULL)
    --               AND (X_Item_Description IS NULL)))
    -- commented the above code for the bug # 5842519
           AND (   (Recinfo.wip_supply_type =  X_Wip_Supply_Type)
                OR (    (Recinfo.wip_supply_type IS NULL)
                   AND (X_Wip_Supply_Type IS NULL)))
           AND (   (Recinfo.posting_flag =  X_Posting_Flag)
                OR (    (Recinfo.posting_flag IS NULL)
                    AND (X_Posting_Flag IS NULL)))
           AND (   (Recinfo.process_flag =  X_Process_Flag)
                OR (    (Recinfo.process_flag IS NULL)
                    AND (X_Process_Flag IS NULL)))
           AND (   (trim(Recinfo.error_code) =  X_Error_Code)
                OR (    (Recinfo.error_code IS NULL)
                   AND (X_Error_Code IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                   AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                   AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                   AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                   AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                   AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                   AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                   AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                   AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.primary_switch =  X_Primary_Switch)
                OR (    (Recinfo.primary_switch IS NULL)
                    AND (X_Primary_Switch IS NULL)))
           AND (   (Recinfo.department_code =  X_Department_Code)
                OR (    (Recinfo.department_code IS NULL)
                   AND (X_Department_Code IS NULL)))
           AND (   (trim(Recinfo.error_explanation) =  X_Error_Explanation)
                OR (    (Recinfo.error_explanation IS NULL)
                    AND (X_Error_Explanation IS NULL)))
           AND (   (Recinfo.demand_id =  X_Demand_Id)
                OR (    (Recinfo.demand_id IS NULL)
                   AND (X_Demand_Id IS NULL)))
           AND (   (Recinfo.requisition_line_id =  X_Requisition_Line_Id)
                OR (    (Recinfo.requisition_line_id IS NULL)
                    AND (X_Requisition_Line_Id IS NULL)))
           AND (   (Recinfo.requisition_distribution_id =  X_Requisition_Distribution_Id)
                OR (    (Recinfo.requisition_distribution_id IS NULL)
                   AND (X_Requisition_Distribution_Id IS NULL)))
           AND (   (Recinfo.movement_id =  X_Movement_Id)
                OR (    (Recinfo.movement_id IS NULL)
                    AND (X_Movement_Id IS NULL)))
          ) then
      RAISE RECORD_CHANGED;
      end if;
          if not (
            (   (Recinfo.source_project_id =  X_Source_Project_Id)
                OR (    (Recinfo.source_project_id IS NULL)
                   AND (X_Source_Project_Id IS NULL)))
           AND (   (Recinfo.source_task_id =  X_Source_Task_Id)
                OR (    (Recinfo.source_task_id IS NULL)
                    AND (X_Source_Task_Id IS NULL)))
           AND (   (Recinfo.project_id =  X_Project_Id)
                OR (    (Recinfo.project_id IS NULL)
                    AND (X_Project_Id IS NULL)))
           AND (   (Recinfo.task_id =  X_Task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_Task_Id IS NULL)))
           AND (   (Recinfo.to_project_id =  X_To_Project_Id)
                OR (    (Recinfo.to_project_id IS NULL)
                    AND (X_To_Project_Id IS NULL)))
           AND (   (Recinfo.to_task_id =  X_To_Task_Id)
                OR (    (Recinfo.to_task_id IS NULL)
                    AND (X_To_Task_Id IS NULL)))
           AND (   (Recinfo.pa_expenditure_org_id =  X_Pa_Expenditure_Org_Id)
                OR (    (Recinfo.pa_expenditure_org_id IS NULL)
                    AND (X_Pa_Expenditure_Org_Id IS NULL)))
           AND (   (Recinfo.expenditure_type =  X_Expenditure_Type)
                OR (    (Recinfo.expenditure_type IS NULL)
                    AND (X_Expenditure_Type IS NULL)))
          ) then
      RAISE RECORD_CHANGED;
      end if;
    exception
    WHEN RECORD_CHANGED then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    WHEN OTHERS then
      raise;
  END Lock_Row;




  PROCEDURE Update_Row(
 X_ROWID                                    VARCHAR2,
 X_TRANSACTION_HEADER_ID                    NUMBER,
 X_TRANSACTION_TEMP_ID                      NUMBER,
 X_SOURCE_CODE                              VARCHAR2,
 X_SOURCE_LINE_ID                           NUMBER,
 X_TRANSACTION_MODE                         NUMBER,
 X_LOCK_FLAG                                VARCHAR2,
 X_LAST_UPDATE_DATE                	    DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_CREATION_DATE                            DATE,
 X_CREATED_BY                               NUMBER,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_REQUEST_ID                               NUMBER,
 X_PROGRAM_APPLICATION_ID                   NUMBER,
 X_PROGRAM_ID                               NUMBER,
 X_PROGRAM_UPDATE_DATE                      DATE,
 X_INVENTORY_ITEM_ID                        NUMBER,
 X_REVISION                                 VARCHAR2,
 X_ORGANIZATION_ID                          NUMBER,
 X_SUBINVENTORY_CODE                        VARCHAR2,
 X_LOCATOR_ID                               NUMBER,
 X_TRANSACTION_QUANTITY                     NUMBER,
 X_PRIMARY_QUANTITY                         NUMBER,
 X_TRANSACTION_UOM                          VARCHAR2,
 X_TRANSACTION_COST                         NUMBER,
 X_COST_GROUP_ID                            NUMBER,
 X_TRANSACTION_TYPE_ID                      NUMBER,
 X_TRANSACTION_ACTION_ID                    NUMBER,
 X_TRANSACTION_SOURCE_TYPE_ID               NUMBER,
 X_TRANSACTION_SOURCE_ID                    NUMBER,
 X_TRANSACTION_SOURCE_NAME                  VARCHAR2,
 X_TRANSACTION_DATE                         DATE,
 X_ACCT_PERIOD_ID                           NUMBER,
 X_DISTRIBUTION_ACCOUNT_ID                  NUMBER,
 X_TRANSACTION_REFERENCE                    VARCHAR2,
 X_REASON_ID                                NUMBER,
 X_LOT_NUMBER                               VARCHAR2,
 X_LOT_EXPIRATION_DATE                      DATE,
 X_SERIAL_NUMBER                            VARCHAR2,
 X_RECEIVING_DOCUMENT                       VARCHAR2,
 X_RCV_TRANSACTION_ID                       NUMBER,
 X_MOVE_TRANSACTION_ID                      NUMBER,
 X_COMPLETION_TRANSACTION_ID                NUMBER,
 X_WIP_ENTITY_TYPE                          NUMBER,
 X_SCHEDULE_ID                              NUMBER,
 X_EMPLOYEE_CODE                            VARCHAR2,
 X_SCHEDULE_UPDATE_CODE                     NUMBER,
 X_SETUP_TEARDOWN_CODE                      NUMBER,
 X_OPERATION_SEQ_NUM                        NUMBER,
 X_PICKING_LINE_ID                          NUMBER,
 X_TRX_SOURCE_LINE_ID                       NUMBER,
 X_TRX_SOURCE_DELIVERY_ID                   NUMBER,
 X_PHYSICAL_ADJUSTMENT_ID                   NUMBER,
 X_CYCLE_COUNT_ID                           NUMBER,
 X_RMA_LINE_ID                              NUMBER,
 X_CUSTOMER_SHIP_ID                         NUMBER,
 X_CURRENCY_CODE                            VARCHAR2,
 X_CURRENCY_CONVERSION_RATE                 NUMBER,
 X_CURRENCY_CONVERSION_TYPE                 VARCHAR2,
 X_CURRENCY_CONVERSION_DATE                 DATE,
 X_USSGL_TRANSACTION_CODE                   VARCHAR2,
 X_VENDOR_LOT_NUMBER                        VARCHAR2,
 X_ENCUMBRANCE_ACCOUNT                      NUMBER,
 X_ENCUMBRANCE_AMOUNT                       NUMBER,
 X_SHIPMENT_NUMBER                          VARCHAR2,
 X_TRANSFER_COST                            NUMBER,
 X_TRANSPORTATION_COST                      NUMBER,
 X_TRANSPORTATION_ACCOUNT                   NUMBER,
 X_FREIGHT_CODE                             VARCHAR2,
 X_CONTAINERS                               NUMBER,
 X_WAYBILL_AIRBILL                          VARCHAR2,
 X_EXPECTED_ARRIVAL_DATE                    DATE,
 X_TRANSFER_SUBINVENTORY                    VARCHAR2,
 X_TRANSFER_ORGANIZATION                    NUMBER,
 X_TRANSFER_TO_LOCATION                     NUMBER,
 X_NEW_AVERAGE_COST                         NUMBER,
 X_VALUE_CHANGE                             NUMBER,
 X_PERCENTAGE_CHANGE                        NUMBER,
 X_MATERIAL_ALLOCATION_TEMP_ID              NUMBER,
 X_DEMAND_SOURCE_HEADER_ID                  NUMBER,
 X_DEMAND_SOURCE_LINE                       VARCHAR2,
 X_DEMAND_SOURCE_DELIVERY                   VARCHAR2,
 X_ITEM_DESCRIPTION                         VARCHAR2,
 X_WIP_SUPPLY_TYPE                          NUMBER,
 X_POSTING_FLAG                             VARCHAR2,
 X_PROCESS_FLAG                             VARCHAR2,
 X_ERROR_CODE                               VARCHAR2,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2,
 X_PRIMARY_SWITCH                           NUMBER,
 X_DEPARTMENT_CODE                          VARCHAR2,
 X_ERROR_EXPLANATION                        VARCHAR2,
 X_DEMAND_ID                                NUMBER,
 X_REQUISITION_LINE_ID                      NUMBER,
 X_REQUISITION_DISTRIBUTION_ID              NUMBER,
 X_MOVEMENT_ID                              NUMBER,
 X_SOURCE_PROJECT_ID                        NUMBER,
 X_SOURCE_TASK_ID                           NUMBER,
 X_PROJECT_ID                               NUMBER,
 X_TASK_ID                                  NUMBER,
 X_TO_PROJECT_ID                            NUMBER,
 X_TO_TASK_ID                               NUMBER,
 X_PA_EXPENDITURE_ORG_ID                    NUMBER,
 X_EXPENDITURE_TYPE                         VARCHAR2,
 X_LPN_ID				    NUMBER,
 X_TRANSFER_LPN_ID			    NUMBER,
 X_TRANSFER_COST_GROUP_ID		    NUMBER,
 X_CONTENT_LPN_ID			    NUMBER
) IS
  BEGIN
    UPDATE mtl_material_transactions_temp
    SET
       transaction_header_id           =     X_Transaction_Header_Id,
       transaction_temp_id             =     X_Transaction_Temp_Id,
       source_code                     =     X_Source_Code,
       source_line_id                  =     X_Source_Line_Id,
       transaction_mode                =     X_Transaction_Mode,
       lock_flag                       =     X_Lock_Flag,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       inventory_item_id               =     X_Inventory_Item_Id,
       revision                        =     X_Revision,
       organization_id                 =     X_Organization_Id,
       subinventory_code               =     X_Subinventory_Code,
       locator_id                      =     X_Locator_Id,
       transaction_quantity            =     X_Transaction_Quantity,
       primary_quantity                =     X_Primary_Quantity,
       transaction_uom                 =     X_Transaction_Uom,
       transaction_cost                =     X_Transaction_Cost,
       cost_group_id                   =     X_cost_group_id,
       transaction_type_id             =     X_Transaction_Type_Id,
       transaction_action_id           =     X_Transaction_Action_Id,
       transaction_source_type_id      =     X_Transaction_Source_Type_Id,
       transaction_source_id           =     X_Transaction_Source_Id,
       transaction_source_name         =     X_Transaction_Source_Name,
       transaction_date                =     X_Transaction_Date,
       acct_period_id                  =     X_Acct_Period_Id,
       distribution_account_id         =     X_Distribution_Account_Id,
       transaction_reference           =     X_Transaction_Reference,
       reason_id                       =     X_Reason_Id,
       lot_number                      =     X_Lot_Number,
       lot_expiration_date             =     X_Lot_Expiration_Date,
       serial_number                   =     X_Serial_Number,
       receiving_document              =     X_Receiving_Document,
       rcv_transaction_id              =     X_Rcv_Transaction_Id,
       move_transaction_id             =     X_Move_Transaction_Id,
       completion_transaction_id       =     X_Completion_Transaction_Id,
        wip_entity_type                 =     X_Wip_Entity_Type,
       schedule_id                     =     X_Schedule_Id,
       employee_code                   =     X_Employee_Code,
       schedule_update_code            =     X_Schedule_Update_Code,
       setup_teardown_code             =     X_Setup_Teardown_Code,
       operation_seq_num               =     X_Operation_Seq_Num,
       picking_line_id                 =     X_Picking_Line_Id,
       trx_source_line_id              =     X_Trx_Source_Line_Id,
       trx_source_delivery_id          =     X_Trx_Source_Delivery_Id,
       physical_adjustment_id          =     X_Physical_Adjustment_Id,
       cycle_count_id                  =     X_Cycle_Count_Id,
       rma_line_id                     =     X_Rma_Line_Id,
       customer_ship_id                =     X_Customer_Ship_Id,
       currency_code                   =     X_Currency_Code,
       currency_conversion_rate        =     X_Currency_Conversion_Rate,
       currency_conversion_type        =     X_Currency_Conversion_Type,
       currency_conversion_date        =     X_Currency_Conversion_Date,
       ussgl_transaction_code          =     X_Ussgl_Transaction_Code,
       vendor_lot_number               =     X_Vendor_Lot_Number,
       encumbrance_account             =     X_Encumbrance_Account,
       encumbrance_amount              =     X_Encumbrance_Amount,
       shipment_number                 =     X_Shipment_Number,
       transfer_cost                   =     X_Transfer_Cost,
       transportation_cost             =     X_Transportation_Cost,
       transportation_account          =     X_Transportation_Account,
       freight_code                    =     X_Freight_Code,
       containers                      =     X_Containers,
       waybill_airbill                 =     X_Waybill_Airbill,
       expected_arrival_date           =     X_Expected_Arrival_Date,
       transfer_subinventory           =     X_Transfer_Subinventory,
       transfer_organization           =     X_Transfer_Organization,
       transfer_to_location            =     X_Transfer_To_Location,
       new_average_cost                =     X_New_Average_Cost,
       value_change                    =     X_Value_Change,
       percentage_change               =     X_Percentage_Change,
       material_allocation_temp_id     =     X_Material_Allocation_Temp_Id,
       demand_source_header_id         =     X_Demand_Source_Header_Id,
       demand_source_line              =     X_Demand_Source_Line,
       demand_source_delivery          =     X_Demand_Source_Delivery,
       item_description                =     X_Item_Description,
       wip_supply_type                 =     X_Wip_Supply_Type,
       posting_flag                    =     X_Posting_Flag,
       process_flag                    =     X_Process_Flag,
       error_code                      =     X_Error_Code,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       primary_switch                  =     X_Primary_Switch,
       department_code                 =     X_Department_Code,
       error_explanation               =     X_Error_Explanation,
       demand_id                       =     X_Demand_Id,
       requisition_line_id             =     X_Requisition_Line_Id,
       requisition_distribution_id     =     X_Requisition_Distribution_Id,
       movement_id                     =     X_Movement_Id,
       source_project_id               =     X_Source_Project_Id,
       source_task_id                  =     X_Source_Task_Id,
       project_id                      =     X_Project_Id,
       task_id                         =     X_Task_Id,
       to_project_id                   =     X_To_Project_Id,
       to_task_id                      =     X_To_Task_Id,
       pa_expenditure_org_id           =     X_Pa_Expenditure_Org_Id,
       expenditure_type                =     X_Expenditure_Type,
       lpn_id			       =     X_lpn_id,
       transfer_lpn_id		       =     X_transfer_lpn_id,
       transfer_cost_group_id	       =     X_transfer_cost_group_id,
       content_lpn_id		       =     X_content_lpn_id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

END MTL_TXNS_TEMP_PKG;

/
