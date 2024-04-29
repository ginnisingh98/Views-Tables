--------------------------------------------------------
--  DDL for Package Body MTL_TRANSACTIONS_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_TRANSACTIONS_INTERFACE_PKG" as
/* $Header: INVTVPTB.pls 120.2 2006/05/23 13:05:46 pannapra noship $ */
/* 31-May-2000 Added three columns Lpn_Id, Transfer_Lpn_Id, Transfer_Cost_Group_Id
   to take care of inventory enhancements related to WMS changes                  */

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Source_Code                      VARCHAR2,
                     X_Source_Line_Id                   NUMBER,
                     X_Source_Header_Id                 NUMBER,
                     X_Process_Flag                     NUMBER,
                     X_Transaction_Mode                 NUMBER,
                     X_Lock_Flag                        NUMBER,
                     X_Inventory_Item_Id                NUMBER,
                     X_Item_Segment1                    VARCHAR2,
                     X_Item_Segment2                    VARCHAR2,
                     X_Item_Segment3                    VARCHAR2,
                     X_Item_Segment4                    VARCHAR2,
                     X_Item_Segment5                    VARCHAR2,
                     X_Item_Segment6                    VARCHAR2,
                     X_Item_Segment7                    VARCHAR2,
                     X_Item_Segment8                    VARCHAR2,
                     X_Item_Segment9                    VARCHAR2,
                     X_Item_Segment10                   VARCHAR2,
                     X_Item_Segment11                   VARCHAR2,
                     X_Item_Segment12                   VARCHAR2,
                     X_Item_Segment13                   VARCHAR2,
                     X_Item_Segment14                   VARCHAR2,
                     X_Item_Segment15                   VARCHAR2,
                     X_Item_Segment16                   VARCHAR2,
                     X_Item_Segment17                   VARCHAR2,
                     X_Item_Segment18                   VARCHAR2,
                     X_Item_Segment19                   VARCHAR2,
                     X_Item_Segment20                   VARCHAR2,
                     X_Revision                         VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Transaction_Quantity             NUMBER,
                     X_Primary_Quantity                 NUMBER,
                     X_Transaction_Uom                  VARCHAR2,
                     X_Transaction_Date                 DATE,
                     X_Subinventory_Code                VARCHAR2,
                     X_Locator_Id                       NUMBER,
                     X_Loc_Segment1                     VARCHAR2,
                     X_Loc_Segment2                     VARCHAR2,
                     X_Loc_Segment3                     VARCHAR2,
                     X_Loc_Segment4                     VARCHAR2,
                     X_Loc_Segment5                     VARCHAR2,
                     X_Loc_Segment6                     VARCHAR2,
                     X_Loc_Segment7                     VARCHAR2,
                     X_Loc_Segment8                     VARCHAR2,
                     X_Loc_Segment9                     VARCHAR2,
                     X_Loc_Segment10                    VARCHAR2,
                     X_Loc_Segment11                    VARCHAR2,
                     X_Loc_Segment12                    VARCHAR2,
                     X_Loc_Segment13                    VARCHAR2,
                     X_Loc_Segment14                    VARCHAR2,
                     X_Loc_Segment15                    VARCHAR2,
                     X_Loc_Segment16                    VARCHAR2,
                     X_Loc_Segment17                    VARCHAR2,
                     X_Loc_Segment18                    VARCHAR2,
                     X_Loc_Segment19                    VARCHAR2,
                     X_Loc_Segment20                    VARCHAR2,
                     X_Transaction_Source_Id            NUMBER,
                     X_Dsp_Segment1                     VARCHAR2,
                     X_Dsp_Segment2                     VARCHAR2,
                     X_Dsp_Segment3                     VARCHAR2,
                     X_Dsp_Segment4                     VARCHAR2,
                     X_Dsp_Segment5                     VARCHAR2,
                     X_Dsp_Segment6                     VARCHAR2,
                     X_Dsp_Segment7                     VARCHAR2,
                     X_Dsp_Segment8                     VARCHAR2,
                     X_Dsp_Segment9                     VARCHAR2,
                     X_Dsp_Segment10                    VARCHAR2,
                     X_Dsp_Segment11                    VARCHAR2,
                     X_Dsp_Segment12                    VARCHAR2,
                     X_Dsp_Segment13                    VARCHAR2,
                     X_Dsp_Segment14                    VARCHAR2,
                     X_Dsp_Segment15                    VARCHAR2,
                     X_Dsp_Segment16                    VARCHAR2,
                     X_Dsp_Segment17                    VARCHAR2,
                     X_Dsp_Segment18                    VARCHAR2,
                     X_Dsp_Segment19                    VARCHAR2,
                     X_Dsp_Segment20                    VARCHAR2,
                     X_Dsp_Segment21                    VARCHAR2,
                     X_Dsp_Segment22                    VARCHAR2,
                     X_Dsp_Segment23                    VARCHAR2,
                     X_Dsp_Segment24                    VARCHAR2,
                     X_Dsp_Segment25                    VARCHAR2,
                     X_Dsp_Segment26                    VARCHAR2,
                     X_Dsp_Segment27                    VARCHAR2,
                     X_Dsp_Segment28                    VARCHAR2,
                     X_Dsp_Segment29                    VARCHAR2,
                     X_Dsp_Segment30                    VARCHAR2,
                     X_Transaction_Source_Name          VARCHAR2,
                     X_Transaction_Source_Type_Id       NUMBER,
                     X_Transaction_Action_Id            NUMBER,
                     X_Transaction_Type_Id              NUMBER,
                     X_Reason_Id                        NUMBER,
                     X_Transaction_Reference            VARCHAR2,
                     X_Transaction_Cost                 NUMBER,
                     X_cost_group_id                    NUMBER,
                     X_Distribution_Account_Id          NUMBER,
                     X_Dst_Segment1                     VARCHAR2,
                     X_Dst_Segment2                     VARCHAR2,
                     X_Dst_Segment3                     VARCHAR2,
                     X_Dst_Segment4                     VARCHAR2,
                     X_Dst_Segment5                     VARCHAR2,
                     X_Dst_Segment6                     VARCHAR2,
                     X_Dst_Segment7                     VARCHAR2,
                     X_Dst_Segment8                     VARCHAR2,
                     X_Dst_Segment9                     VARCHAR2,
                     X_Dst_Segment10                    VARCHAR2,
                     X_Dst_Segment11                    VARCHAR2,
                     X_Dst_Segment12                    VARCHAR2,
                     X_Dst_Segment13                    VARCHAR2,
                     X_Dst_Segment14                    VARCHAR2,
                     X_Dst_Segment15                    VARCHAR2,
                     X_Dst_Segment16                    VARCHAR2,
                     X_Dst_Segment17                    VARCHAR2,
                     X_Dst_Segment18                    VARCHAR2,
                     X_Dst_Segment19                    VARCHAR2,
                     X_Dst_Segment20                    VARCHAR2,
                     X_Dst_Segment21                    VARCHAR2,
                     X_Dst_Segment22                    VARCHAR2,
                     X_Dst_Segment23                    VARCHAR2,
                     X_Dst_Segment24                    VARCHAR2,
                     X_Dst_Segment25                    VARCHAR2,
                     X_Dst_Segment26                    VARCHAR2,
                     X_Dst_Segment27                    VARCHAR2,
                     X_Dst_Segment28                    VARCHAR2,
                     X_Dst_Segment29                    VARCHAR2,
                     X_Dst_Segment30                    VARCHAR2,
                     X_Currency_Code                    VARCHAR2,
                     X_Currency_Conversion_Type         VARCHAR2,
                     X_Currency_Conversion_Rate         NUMBER,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Wip_Entity_Type                  NUMBER,
                     X_Schedule_Id                      NUMBER,
                     X_Employee_Code                    VARCHAR2,
                     X_Department_Id                    NUMBER,
                     X_Schedule_Update_Code             NUMBER,
                     X_Setup_Teardown_Code              NUMBER,
                     X_Primary_Switch                   NUMBER,
                     X_Mrp_Code                         NUMBER,
                     X_Operation_Seq_Num                NUMBER,
                     X_Repetitive_Line_Id               NUMBER,
                     X_Line_Item_Num                    NUMBER,
                     X_Ship_To_Location_Id              NUMBER,
                     X_Encumbrance_Account              NUMBER,
                     X_Encumbrance_Amount               NUMBER,
                     X_Transfer_Subinventory            VARCHAR2,
                     X_Transfer_Organization            NUMBER,
                     X_Transfer_Locator                 NUMBER,
                     X_Xfer_Loc_Segment1                VARCHAR2,
                     X_Xfer_Loc_Segment2                VARCHAR2,
                     X_Xfer_Loc_Segment3                VARCHAR2,
                     X_Xfer_Loc_Segment4                VARCHAR2,
                     X_Xfer_Loc_Segment5                VARCHAR2,
                     X_Xfer_Loc_Segment6                VARCHAR2,
                     X_Xfer_Loc_Segment7                VARCHAR2,
                     X_Xfer_Loc_Segment8                VARCHAR2,
                     X_Xfer_Loc_Segment9                VARCHAR2,
                     X_Xfer_Loc_Segment10               VARCHAR2,
                     X_Xfer_Loc_Segment11               VARCHAR2,
                     X_Xfer_Loc_Segment12               VARCHAR2,
                     X_Xfer_Loc_Segment13               VARCHAR2,
                     X_Xfer_Loc_Segment14               VARCHAR2,
                     X_Xfer_Loc_Segment15               VARCHAR2,
                     X_Xfer_Loc_Segment16               VARCHAR2,
                     X_Xfer_Loc_Segment17               VARCHAR2,
                     X_Xfer_Loc_Segment18               VARCHAR2,
                     X_Xfer_Loc_Segment19               VARCHAR2,
                     X_Xfer_Loc_Segment20               VARCHAR2,
                     X_Shipment_Number                  VARCHAR2,
                     X_Transportation_Cost              NUMBER,
                     X_Transportation_Account           NUMBER,
                     X_Transfer_Cost                    NUMBER,
                     X_Freight_Code                     VARCHAR2,
                     X_Containers                       NUMBER,
                     X_Waybill_Airbill                  VARCHAR2,
                     X_Expected_Arrival_Date            DATE,
                     X_New_Average_Cost                 NUMBER,
                     X_Value_Change                     NUMBER,
                     X_Percentage_Change                NUMBER,
                     X_Required_Flag                    VARCHAR2,
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
                     X_Validation_Required              NUMBER,
                     X_Negative_Req_Flag                NUMBER,
                     X_Shippable_Flag                   VARCHAR2,
                     X_Currency_Conversion_Date         DATE,
                     X_Movement_Id                      NUMBER,
                     X_Source_Project_Id                NUMBER,
                     X_Source_Task_Id                   NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Task_Id                          NUMBER,
                     X_To_Project_Id                    NUMBER,
                     X_To_Task_Id                       NUMBER,
                     X_Pa_Expenditure_Org_Id            NUMBER,
                     X_Expenditure_Type                 VARCHAR2,
                     X_Lpn_Id                           NUMBER,
                     X_Transfer_Lpn_Id                  NUMBER,
                     X_Transfer_Cost_Group_Id           NUMBER,
                     X_content_lpn_id                   NUMBER,
                     X_demand_source_header_id          NUMBER,     --2520630
                     X_demand_source_line               VARCHAR2,   --2520630
                     X_demand_source_delivery           VARCHAR2,   --2520630
                     x_owning_organization_id           NUMBER,
                     x_owning_tp_type                   NUMBER,
                     x_planning_organization_id         NUMBER,
                     x_planning_tp_type                 NUMBER,
                     ---INVCON kkillams
                     x_secondary_qty      NUMBER,
                     x_secondary_uom_code               VARCHAR2
                     ---END INVCON kkillams
  ) IS
    CURSOR C IS
        SELECT *
        FROM   MTL_TRANSACTIONS_INTERFACE
        WHERE  rowid = X_Rowid
        FOR UPDATE of transaction_header_id NOWAIT;
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

    if (
        (Recinfo.source_code =  X_Source_Code)
        AND (Recinfo.source_line_id =  X_Source_Line_Id)
        AND (Recinfo.source_header_id =  X_Source_Header_Id)
        AND (Recinfo.process_flag =  X_Process_Flag)
        AND (Recinfo.transaction_mode =  X_Transaction_Mode)
        AND (   (Recinfo.lock_flag =  X_Lock_Flag)
                OR (    (Recinfo.lock_flag IS NULL)
                        AND (X_Lock_Flag IS NULL)))
        AND (   (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
                OR (    (Recinfo.inventory_item_id IS NULL)
                        AND (X_Inventory_Item_Id IS NULL)))
        AND (   (Recinfo.item_segment1 =  X_Item_Segment1)
                OR (    (Recinfo.item_segment1 IS NULL)
                        AND (X_Item_Segment1 IS NULL)))
        AND (   (Recinfo.item_segment2 =  X_Item_Segment2)
                OR (    (Recinfo.item_segment2 IS NULL)
                        AND (X_Item_Segment2 IS NULL)))
        AND (   (Recinfo.item_segment3 =  X_Item_Segment3)
                OR (    (Recinfo.item_segment3 IS NULL)
                        AND (X_Item_Segment3 IS NULL)))
        AND (   (Recinfo.item_segment4 =  X_Item_Segment4)
                OR (    (Recinfo.item_segment4 IS NULL)
                        AND (X_Item_Segment4 IS NULL)))
        AND (   (Recinfo.item_segment5 =  X_Item_Segment5)
                OR (    (Recinfo.item_segment5 IS NULL)
                        AND (X_Item_Segment5 IS NULL)))
        AND (   (Recinfo.item_segment6 =  X_Item_Segment6)
                OR (    (Recinfo.item_segment6 IS NULL)
        AND (X_Item_Segment6 IS NULL)))
          AND (   (Recinfo.item_segment7 =  X_Item_Segment7)
                  OR (    (Recinfo.item_segment7 IS NULL)
                          AND (X_Item_Segment7 IS NULL)))
         AND (   (Recinfo.item_segment8 =  X_Item_Segment8)
                OR (    (Recinfo.item_segment8 IS NULL)
                    AND (X_Item_Segment8 IS NULL)))
           AND (   (Recinfo.item_segment9 =  X_Item_Segment9)
                OR (    (Recinfo.item_segment9 IS NULL)
                    AND (X_Item_Segment9 IS NULL)))
           AND (   (Recinfo.item_segment10 =  X_Item_Segment10)
                OR (    (Recinfo.item_segment10 IS NULL)
                    AND (X_Item_Segment10 IS NULL)))
           AND (   (Recinfo.item_segment11 =  X_Item_Segment11)
                OR (    (Recinfo.item_segment11 IS NULL)
                    AND (X_Item_Segment11 IS NULL)))
           AND (   (Recinfo.item_segment12 =  X_Item_Segment12)
                OR (    (Recinfo.item_segment12 IS NULL)
                    AND (X_Item_Segment12 IS NULL)))
           AND (   (Recinfo.item_segment13 =  X_Item_Segment13)
                OR (    (Recinfo.item_segment13 IS NULL)
                    AND (X_Item_Segment13 IS NULL)))
           AND (   (Recinfo.item_segment14 =  X_Item_Segment14)
                OR (    (Recinfo.item_segment14 IS NULL)
                    AND (X_Item_Segment14 IS NULL)))
           AND (   (Recinfo.item_segment15 =  X_Item_Segment15)
                OR (    (Recinfo.item_segment15 IS NULL)
                    AND (X_Item_Segment15 IS NULL)))
           AND (   (Recinfo.item_segment16 =  X_Item_Segment16)
                OR (    (Recinfo.item_segment16 IS NULL)
                    AND (X_Item_Segment16 IS NULL)))
           AND (   (Recinfo.item_segment17 =  X_Item_Segment17)
                OR (    (Recinfo.item_segment17 IS NULL)
                    AND (X_Item_Segment17 IS NULL)))
           AND (   (Recinfo.item_segment18 =  X_Item_Segment18)
                OR (    (Recinfo.item_segment18 IS NULL)
                    AND (X_Item_Segment18 IS NULL)))
           AND (   (Recinfo.item_segment19 =  X_Item_Segment19)
                OR (    (Recinfo.item_segment19 IS NULL)
                    AND (X_Item_Segment19 IS NULL)))
           AND (   (Recinfo.item_segment20 =  X_Item_Segment20)
                OR (    (Recinfo.item_segment20 IS NULL)
                    AND (X_Item_Segment20 IS NULL)))
           AND (   (Recinfo.revision =  X_Revision)
                OR (    (Recinfo.revision IS NULL)
                    AND (X_Revision IS NULL)))
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (Recinfo.transaction_quantity =  X_Transaction_Quantity)
           AND (   (Recinfo.primary_quantity =  X_Primary_Quantity)
                OR (    (Recinfo.primary_quantity IS NULL)
                    AND (X_Primary_Quantity IS NULL)))
           AND (Recinfo.transaction_uom =  X_Transaction_Uom)
           AND (Recinfo.transaction_date =  X_Transaction_Date)
           AND (   (Recinfo.subinventory_code =  X_Subinventory_Code)
                OR (    (Recinfo.subinventory_code IS NULL)
                    AND (X_Subinventory_Code IS NULL)))
           AND (   (Recinfo.locator_id =  X_Locator_Id)
                OR (    (Recinfo.locator_id IS NULL)
                    AND (X_Locator_Id IS NULL)))
           AND (   (Recinfo.loc_segment1 =  X_Loc_Segment1)
                OR (    (Recinfo.loc_segment1 IS NULL)
                    AND (X_Loc_Segment1 IS NULL)))
           AND (   (Recinfo.loc_segment2 =  X_Loc_Segment2)
                OR (    (Recinfo.loc_segment2 IS NULL)
                    AND (X_Loc_Segment2 IS NULL)))
           AND (   (Recinfo.loc_segment3 =  X_Loc_Segment3)
                OR (    (Recinfo.loc_segment3 IS NULL)
                    AND (X_Loc_Segment3 IS NULL)))
           AND (   (Recinfo.loc_segment4 =  X_Loc_Segment4)
                OR (    (Recinfo.loc_segment4 IS NULL)
                    AND (X_Loc_Segment4 IS NULL)))
           AND (   (Recinfo.loc_segment5 =  X_Loc_Segment5)
                OR (    (Recinfo.loc_segment5 IS NULL)
                    AND (X_Loc_Segment5 IS NULL)))
           AND (   (Recinfo.loc_segment6 =  X_Loc_Segment6)
                OR (    (Recinfo.loc_segment6 IS NULL)
                    AND (X_Loc_Segment6 IS NULL)))
           AND (   (Recinfo.loc_segment7 =  X_Loc_Segment7)
                OR (    (Recinfo.loc_segment7 IS NULL)
                    AND (X_Loc_Segment7 IS NULL)))
           AND (   (Recinfo.loc_segment8 =  X_Loc_Segment8)
                OR (    (Recinfo.loc_segment8 IS NULL)
                    AND (X_Loc_Segment8 IS NULL)))
           AND (   (Recinfo.loc_segment9 =  X_Loc_Segment9)
                OR (    (Recinfo.loc_segment9 IS NULL)
                    AND (X_Loc_Segment9 IS NULL)))
           AND (   (Recinfo.loc_segment10 =  X_Loc_Segment10)
                OR (    (Recinfo.loc_segment10 IS NULL)
                    AND (X_Loc_Segment10 IS NULL)))
           AND (   (Recinfo.loc_segment11 =  X_Loc_Segment11)
                OR (    (Recinfo.loc_segment11 IS NULL)
                    AND (X_Loc_Segment11 IS NULL)))
           AND (   (Recinfo.loc_segment12 =  X_Loc_Segment12)
                OR (    (Recinfo.loc_segment12 IS NULL)
                    AND (X_Loc_Segment12 IS NULL)))
           AND (   (Recinfo.loc_segment13 =  X_Loc_Segment13)
                OR (    (Recinfo.loc_segment13 IS NULL)
                    AND (X_Loc_Segment13 IS NULL)))
           AND (   (Recinfo.loc_segment14 =  X_Loc_Segment14)
                OR (    (Recinfo.loc_segment14 IS NULL)
                    AND (X_Loc_Segment14 IS NULL)))
           AND (   (Recinfo.loc_segment15 =  X_Loc_Segment15)
                OR (    (Recinfo.loc_segment15 IS NULL)
                    AND (X_Loc_Segment15 IS NULL)))
           AND (   (Recinfo.loc_segment16 =  X_Loc_Segment16)
                OR (    (Recinfo.loc_segment16 IS NULL)
                    AND (X_Loc_Segment16 IS NULL)))
           AND (   (Recinfo.loc_segment17 =  X_Loc_Segment17)
                OR (    (Recinfo.loc_segment17 IS NULL)
                    AND (X_Loc_Segment17 IS NULL)))
           AND (   (Recinfo.loc_segment18 =  X_Loc_Segment18)
                OR (    (Recinfo.loc_segment18 IS NULL)
                    AND (X_Loc_Segment18 IS NULL)))
           AND (   (Recinfo.loc_segment19 =  X_Loc_Segment19)
                OR (    (Recinfo.loc_segment19 IS NULL)
                    AND (X_Loc_Segment19 IS NULL)))
           AND (   (Recinfo.loc_segment20 =  X_Loc_Segment20)
                OR (    (Recinfo.loc_segment20 IS NULL)
                    AND (X_Loc_Segment20 IS NULL)))
           AND (   (Recinfo.transaction_source_id =  X_Transaction_Source_Id)
                OR (    (Recinfo.transaction_source_id IS NULL)
                    AND (X_Transaction_Source_Id IS NULL)))
           ---INVCON kkillams
           AND (   (Recinfo.secondary_transaction_quantity =  x_secondary_qty)
                OR (    (Recinfo.secondary_transaction_quantity IS NULL)
                    AND (x_secondary_qty IS NULL)))
/*INVCON Nsinha
          AND (   (Recinfo.secondary_uom_code =  X_secondary_uom_code)
                OR (    (Recinfo.secondary_uom_code IS NULL)
                    AND (X_secondary_uom_code IS NULL)))
*/
           ---END INVCON kkillams
       ) THEN
             if (
                  (   (Recinfo.dsp_segment1 =  X_Dsp_Segment1)
                   OR (    (Recinfo.dsp_segment1 IS NULL)
                       AND (X_Dsp_Segment1 IS NULL)))
              AND (   (Recinfo.dsp_segment2 =  X_Dsp_Segment2)
                   OR (    (Recinfo.dsp_segment2 IS NULL)
                       AND (X_Dsp_Segment2 IS NULL)))
              AND (   (Recinfo.dsp_segment3 =  X_Dsp_Segment3)
                   OR (    (Recinfo.dsp_segment3 IS NULL)
                       AND (X_Dsp_Segment3 IS NULL)))
              AND (   (Recinfo.dsp_segment4 =  X_Dsp_Segment4)
                   OR (    (Recinfo.dsp_segment4 IS NULL)
                       AND (X_Dsp_Segment4 IS NULL)))
              AND (   (Recinfo.dsp_segment5 =  X_Dsp_Segment5)
                   OR (    (Recinfo.dsp_segment5 IS NULL)
                       AND (X_Dsp_Segment5 IS NULL)))
              AND (   (Recinfo.dsp_segment6 =  X_Dsp_Segment6)
                   OR (    (Recinfo.dsp_segment6 IS NULL)
                       AND (X_Dsp_Segment6 IS NULL)))
              AND (   (Recinfo.dsp_segment7 =  X_Dsp_Segment7)
                   OR (    (Recinfo.dsp_segment7 IS NULL)
                       AND (X_Dsp_Segment7 IS NULL)))
              AND (   (Recinfo.dsp_segment8 =  X_Dsp_Segment8)
                   OR (    (Recinfo.dsp_segment8 IS NULL)
                       AND (X_Dsp_Segment8 IS NULL)))
              AND (   (Recinfo.dsp_segment9 =  X_Dsp_Segment9)
                   OR (    (Recinfo.dsp_segment9 IS NULL)
                       AND (X_Dsp_Segment9 IS NULL)))
              AND (   (Recinfo.dsp_segment10 =  X_Dsp_Segment10)
                   OR (    (Recinfo.dsp_segment10 IS NULL)
                       AND (X_Dsp_Segment10 IS NULL)))
              AND (   (Recinfo.dsp_segment11 =  X_Dsp_Segment11)
                   OR (    (Recinfo.dsp_segment11 IS NULL)
                       AND (X_Dsp_Segment11 IS NULL)))
              AND (   (Recinfo.dsp_segment12 =  X_Dsp_Segment12)
                   OR (    (Recinfo.dsp_segment12 IS NULL)
                       AND (X_Dsp_Segment12 IS NULL)))
              AND (   (Recinfo.dsp_segment13 =  X_Dsp_Segment13)
                   OR (    (Recinfo.dsp_segment13 IS NULL)
                       AND (X_Dsp_Segment13 IS NULL)))
              AND (   (Recinfo.dsp_segment14 =  X_Dsp_Segment14)
                   OR (    (Recinfo.dsp_segment14 IS NULL)
                       AND (X_Dsp_Segment14 IS NULL)))
              AND (   (Recinfo.dsp_segment15 =  X_Dsp_Segment15)
                   OR (    (Recinfo.dsp_segment15 IS NULL)
                       AND (X_Dsp_Segment15 IS NULL)))
              AND (   (Recinfo.dsp_segment16 =  X_Dsp_Segment16)
                   OR (    (Recinfo.dsp_segment16 IS NULL)
                       AND (X_Dsp_Segment16 IS NULL)))
              AND (   (Recinfo.dsp_segment17 =  X_Dsp_Segment17)
                   OR (    (Recinfo.dsp_segment17 IS NULL)
                       AND (X_Dsp_Segment17 IS NULL)))
              AND (   (Recinfo.dsp_segment18 =  X_Dsp_Segment18)
                   OR (    (Recinfo.dsp_segment18 IS NULL)
                       AND (X_Dsp_Segment18 IS NULL)))
              AND (   (Recinfo.dsp_segment19 =  X_Dsp_Segment19)
                   OR (    (Recinfo.dsp_segment19 IS NULL)
                       AND (X_Dsp_Segment19 IS NULL)))
              AND (   (Recinfo.dsp_segment20 =  X_Dsp_Segment20)
                   OR (    (Recinfo.dsp_segment20 IS NULL)
                       AND (X_Dsp_Segment20 IS NULL)))
              AND (   (Recinfo.dsp_segment21 =  X_Dsp_Segment21)
                   OR (    (Recinfo.dsp_segment21 IS NULL)
                       AND (X_Dsp_Segment21 IS NULL)))
              AND (   (Recinfo.dsp_segment22 =  X_Dsp_Segment22)
                   OR (    (Recinfo.dsp_segment22 IS NULL)
                       AND (X_Dsp_Segment22 IS NULL)))
              AND (   (Recinfo.dsp_segment23 =  X_Dsp_Segment23)
                   OR (    (Recinfo.dsp_segment23 IS NULL)
                       AND (X_Dsp_Segment23 IS NULL)))
              AND (   (Recinfo.dsp_segment24 =  X_Dsp_Segment24)
                   OR (    (Recinfo.dsp_segment24 IS NULL)
                       AND (X_Dsp_Segment24 IS NULL)))
              AND (   (Recinfo.dsp_segment25 =  X_Dsp_Segment25)
                   OR (    (Recinfo.dsp_segment25 IS NULL)
                       AND (X_Dsp_Segment25 IS NULL)))
              AND (   (Recinfo.dsp_segment26 =  X_Dsp_Segment26)
                   OR (    (Recinfo.dsp_segment26 IS NULL)
                       AND (X_Dsp_Segment26 IS NULL)))
              AND (   (Recinfo.dsp_segment27 =  X_Dsp_Segment27)
                   OR (    (Recinfo.dsp_segment27 IS NULL)
                       AND (X_Dsp_Segment27 IS NULL)))
              AND (   (Recinfo.dsp_segment28 =  X_Dsp_Segment28)
                   OR (    (Recinfo.dsp_segment28 IS NULL)
                       AND (X_Dsp_Segment28 IS NULL)))
              AND (   (Recinfo.dsp_segment29 =  X_Dsp_Segment29)
                   OR (    (Recinfo.dsp_segment29 IS NULL)
                       AND (X_Dsp_Segment29 IS NULL)))
              AND (   (Recinfo.dsp_segment30 =  X_Dsp_Segment30)
                   OR (    (Recinfo.dsp_segment30 IS NULL)
                       AND (X_Dsp_Segment30 IS NULL)))
              AND (   (Recinfo.transaction_source_name =  X_Transaction_Source_Name)
                   OR (    (Recinfo.transaction_source_name IS NULL)
                       AND (X_Transaction_Source_Name IS NULL)))
              AND (   (Recinfo.transaction_source_type_id =  X_Transaction_Source_Type_Id)
                   OR (    (Recinfo.transaction_source_type_id IS NULL)
                       AND (X_Transaction_Source_Type_Id IS NULL)))
              AND (   (Recinfo.transaction_action_id =  X_Transaction_Action_Id)
                   OR (    (Recinfo.transaction_action_id IS NULL)
                       AND (X_Transaction_Action_Id IS NULL)))
              AND (Recinfo.transaction_type_id =  X_Transaction_Type_Id)
              AND (   (Recinfo.reason_id =  X_Reason_Id)
                   OR (    (Recinfo.reason_id IS NULL)
                       AND (X_Reason_Id IS NULL)))
              AND (   (Recinfo.transaction_reference =  X_Transaction_Reference)
                   OR (    (Recinfo.transaction_reference IS NULL)
                       AND (X_Transaction_Reference IS NULL)))
              AND (   (Recinfo.transaction_cost =  X_Transaction_Cost)
                   OR (    (Recinfo.transaction_cost IS NULL)
                       AND (X_Transaction_Cost IS NULL)))
              AND (   (Recinfo.cost_group_id =  X_cost_group_id)
                   OR (    (Recinfo.cost_group_id IS NULL)
                       AND (X_cost_group_id IS NULL)))
              AND (   (Recinfo.distribution_account_id =  X_Distribution_Account_Id)
                   OR (    (Recinfo.distribution_account_id IS NULL)
                       AND (X_Distribution_Account_Id IS NULL)))
              AND (   (Recinfo.dst_segment1 =  X_Dst_Segment1)
                   OR (    (Recinfo.dst_segment1 IS NULL)
                       AND (X_Dst_Segment1 IS NULL)))
              AND (   (Recinfo.dst_segment2 =  X_Dst_Segment2)
                   OR (    (Recinfo.dst_segment2 IS NULL)
                       AND (X_Dst_Segment2 IS NULL)))
              AND (   (Recinfo.dst_segment3 =  X_Dst_Segment3)
                   OR (    (Recinfo.dst_segment3 IS NULL)
                       AND (X_Dst_Segment3 IS NULL)))
              AND (   (Recinfo.dst_segment4 =  X_Dst_Segment4)
                   OR (    (Recinfo.dst_segment4 IS NULL)
                       AND (X_Dst_Segment4 IS NULL)))
              AND (   (Recinfo.dst_segment5 =  X_Dst_Segment5)
                   OR (    (Recinfo.dst_segment5 IS NULL)
                       AND (X_Dst_Segment5 IS NULL)))
              AND (   (Recinfo.dst_segment6 =  X_Dst_Segment6)
                   OR (    (Recinfo.dst_segment6 IS NULL)
                       AND (X_Dst_Segment6 IS NULL)))
              AND (   (Recinfo.dst_segment7 =  X_Dst_Segment7)
                   OR (    (Recinfo.dst_segment7 IS NULL)
                       AND (X_Dst_Segment7 IS NULL)))
              AND (   (Recinfo.dst_segment8 =  X_Dst_Segment8)
                   OR (    (Recinfo.dst_segment8 IS NULL)
                       AND (X_Dst_Segment8 IS NULL)))
              AND (   (Recinfo.dst_segment9 =  X_Dst_Segment9)
                   OR (    (Recinfo.dst_segment9 IS NULL)
                    AND (X_Dst_Segment9 IS NULL)))
              AND (   (Recinfo.dst_segment10 =  X_Dst_Segment10)
                   OR (    (Recinfo.dst_segment10 IS NULL)
                       AND (X_Dst_Segment10 IS NULL)))
              AND (   (Recinfo.dst_segment11 =  X_Dst_Segment11)
                   OR (    (Recinfo.dst_segment11 IS NULL)
                       AND (X_Dst_Segment11 IS NULL)))
              AND (   (Recinfo.dst_segment12 =  X_Dst_Segment12)
                   OR (    (Recinfo.dst_segment12 IS NULL)
                       AND (X_Dst_Segment12 IS NULL)))
              AND (   (Recinfo.dst_segment13 =  X_Dst_Segment13)
                   OR (    (Recinfo.dst_segment13 IS NULL)
                       AND (X_Dst_Segment13 IS NULL)))
              AND (   (Recinfo.lpn_id =  X_Lpn_Id)
                   OR (    (Recinfo.Lpn_Id IS NULL)
                       AND (X_Lpn_Id IS NULL)))
              AND (   (Recinfo.Transfer_lpn_id =  X_Transfer_Lpn_Id)
                   OR (    (Recinfo.Transfer_Lpn_Id IS NULL)
                       AND (X_Transfer_Lpn_Id IS NULL)))
              AND (   (Recinfo.Transfer_Cost_Group_Id =  X_Transfer_Cost_Group_Id)
                   OR (    (Recinfo.Transfer_Cost_Group_Id IS NULL)
                       AND (X_Transfer_Cost_Group_Id IS NULL)))
              AND (   (Recinfo.content_lpn_id =  X_content_lpn_id)
                   OR ((Recinfo.content_lpn_id IS NULL)
                       AND (X_content_lpn_id IS NULL)))
              AND ((recinfo.owning_tp_type =x_owning_tp_type)
                   OR ( (Recinfo.owning_tp_type IS NULL)
                        AND (x_owning_tp_type IS NULL)))
              AND ((recinfo.planning_tp_type = x_planning_tp_type)
                   OR ( (Recinfo.planning_tp_type IS NULL)
                        AND (x_planning_tp_type IS
                             NULL)))
              AND ((recinfo.planning_organization_id = x_planning_organization_id)
                   OR ( (Recinfo.planning_organization_id IS NULL)
                        AND (x_planning_organization_id IS NULL)))
              AND ((recinfo.owning_organization_id = x_owning_organization_id)
                   OR ( (recinfo.owning_organization_id IS NULL)
                        AND (x_owning_organization_id IS NULL)))

              ---INVCON kkillams
              AND ((recinfo.secondary_transaction_quantity = x_secondary_qty)
                   OR ( (recinfo.secondary_transaction_quantity IS NULL)
                        AND (x_secondary_qty IS NULL)))
/*INVCON Nsinha
              AND ((recinfo.secondary_uom_code = x_secondary_uom_code)
                   OR ( (recinfo.secondary_uom_code IS NULL)
                        AND (x_secondary_uom_code IS NULL)))
*/
              ---END  INVCON kkillams

                ) then
                      if (
                           (   (Recinfo.dst_segment14 =  X_Dst_Segment14)
                            OR (    (Recinfo.dst_segment14 IS NULL)
                                AND (X_Dst_Segment14 IS NULL)))
                       AND (   (Recinfo.dst_segment15 =  X_Dst_Segment15)
                            OR (    (Recinfo.dst_segment15 IS NULL)
                                AND (X_Dst_Segment15 IS NULL)))
                       AND (   (Recinfo.dst_segment16 =  X_Dst_Segment16)
                            OR (    (Recinfo.dst_segment16 IS NULL)
                                AND (X_Dst_Segment16 IS NULL)))
                       AND (   (Recinfo.dst_segment17 =  X_Dst_Segment17)
                            OR (    (Recinfo.dst_segment17 IS NULL)
                                AND (X_Dst_Segment17 IS NULL)))
                       AND (   (Recinfo.dst_segment18 =  X_Dst_Segment18)
                            OR (    (Recinfo.dst_segment18 IS NULL)
                                AND (X_Dst_Segment18 IS NULL)))
                       AND (   (Recinfo.dst_segment19 =  X_Dst_Segment19)
                            OR (    (Recinfo.dst_segment19 IS NULL)
                                AND (X_Dst_Segment19 IS NULL)))
                       AND (   (Recinfo.dst_segment20 =  X_Dst_Segment20)
                            OR (    (Recinfo.dst_segment20 IS NULL)
                                AND (X_Dst_Segment20 IS NULL)))
                       AND (   (Recinfo.dst_segment21 =  X_Dst_Segment21)
                            OR (    (Recinfo.dst_segment21 IS NULL)
                                AND (X_Dst_Segment21 IS NULL)))
                       AND (   (Recinfo.dst_segment22 =  X_Dst_Segment22)
                            OR (    (Recinfo.dst_segment22 IS NULL)
                                AND (X_Dst_Segment22 IS NULL)))
                       AND (   (Recinfo.dst_segment23 =  X_Dst_Segment23)
                            OR (    (Recinfo.dst_segment23 IS NULL)
                                AND (X_Dst_Segment23 IS NULL)))
                       AND (   (Recinfo.dst_segment24 =  X_Dst_Segment24)
                            OR (    (Recinfo.dst_segment24 IS NULL)
                                AND (X_Dst_Segment24 IS NULL)))
                       AND (   (Recinfo.dst_segment25 =  X_Dst_Segment25)
                            OR (    (Recinfo.dst_segment25 IS NULL)
                                AND (X_Dst_Segment25 IS NULL)))
                       AND (   (Recinfo.dst_segment26 =  X_Dst_Segment26)
                            OR (    (Recinfo.dst_segment26 IS NULL)
                                AND (X_Dst_Segment26 IS NULL)))
                       AND (   (Recinfo.dst_segment27 =  X_Dst_Segment27)
                            OR (    (Recinfo.dst_segment27 IS NULL)
                                AND (X_Dst_Segment27 IS NULL)))
                       AND (   (Recinfo.dst_segment28 =  X_Dst_Segment28)
                            OR (    (Recinfo.dst_segment28 IS NULL)
                                AND (X_Dst_Segment28 IS NULL)))
                       AND (   (Recinfo.dst_segment29 =  X_Dst_Segment29)
                            OR (    (Recinfo.dst_segment29 IS NULL)
                                AND (X_Dst_Segment29 IS NULL)))
                       AND (   (Recinfo.dst_segment30 =  X_Dst_Segment30)
                            OR (    (Recinfo.dst_segment30 IS NULL)
                                AND (X_Dst_Segment30 IS NULL)))
                       AND (   (Recinfo.currency_code =  X_Currency_Code)
                            OR (    (Recinfo.currency_code IS NULL)
                                AND (X_Currency_Code IS NULL)))
                       AND (   (Recinfo.currency_conversion_type =  X_Currency_Conversion_Type)
                            OR (    (Recinfo.currency_conversion_type IS NULL)
                                AND (X_Currency_Conversion_Type IS NULL)))
                       AND (   (Recinfo.currency_conversion_rate =  X_Currency_Conversion_Rate)
                            OR (    (Recinfo.currency_conversion_rate IS NULL)
                                AND (X_Currency_Conversion_Rate IS NULL)))
                       AND (   (Recinfo.ussgl_transaction_code =  X_Ussgl_Transaction_Code)
                            OR (    (Recinfo.ussgl_transaction_code IS NULL)
                                AND (X_Ussgl_Transaction_Code IS NULL)))
                       AND (   (Recinfo.wip_entity_type =  X_Wip_Entity_Type)
                            OR (    (Recinfo.wip_entity_type IS NULL)
                                AND (X_Wip_Entity_Type IS NULL)))
                       AND (   (Recinfo.schedule_id =  X_Schedule_Id)
                            OR (    (Recinfo.schedule_id IS NULL)
                                AND (X_Schedule_Id IS NULL)))
                       AND (   (Recinfo.employee_code =  X_Employee_Code)
                            OR (    (Recinfo.employee_code IS NULL)
                                AND (X_Employee_Code IS NULL)))
                       AND (   (Recinfo.department_id =  X_Department_Id)
                            OR (    (Recinfo.department_id IS NULL)
                                AND (X_Department_Id IS NULL)))
                       AND (   (Recinfo.schedule_update_code =  X_Schedule_Update_Code)
                            OR (    (Recinfo.schedule_update_code IS NULL)
                                AND (X_Schedule_Update_Code IS NULL)))
                       AND (   (Recinfo.setup_teardown_code =  X_Setup_Teardown_Code)
                            OR (    (Recinfo.setup_teardown_code IS NULL)
                                AND (X_Setup_Teardown_Code IS NULL)))
                       AND (   (Recinfo.primary_switch =  X_Primary_Switch)
                            OR (    (Recinfo.primary_switch IS NULL)
                                AND (X_Primary_Switch IS NULL)))
                       AND (   (Recinfo.mrp_code =  X_Mrp_Code)
                            OR (    (Recinfo.mrp_code IS NULL)
                                AND (X_Mrp_Code IS NULL)))
                       AND (   (Recinfo.operation_seq_num =  X_Operation_Seq_Num)
                            OR (    (Recinfo.operation_seq_num IS NULL)
                                AND (X_Operation_Seq_Num IS NULL)))
                       AND (   (Recinfo.repetitive_line_id =  X_Repetitive_Line_Id)
                            OR (    (Recinfo.repetitive_line_id IS NULL)
                                AND (X_Repetitive_Line_Id IS NULL)))
                       AND (   (Recinfo.line_item_num =  X_Line_Item_Num)
                            OR (    (Recinfo.line_item_num IS NULL)
                                AND (X_Line_Item_Num IS NULL)))
                       AND (   (Recinfo.ship_to_location_id =  X_Ship_To_Location_Id)
                            OR (    (Recinfo.ship_to_location_id IS NULL)
                                AND (X_Ship_To_Location_Id IS NULL)))
                       AND (   (Recinfo.encumbrance_account =  X_Encumbrance_Account)
                            OR (    (Recinfo.encumbrance_account IS NULL)
                                AND (X_Encumbrance_Account IS NULL)))
                       AND (   (Recinfo.encumbrance_amount =  X_Encumbrance_Amount)
                            OR (    (Recinfo.encumbrance_amount IS NULL)
                                AND (X_Encumbrance_Amount IS NULL)))
                       AND (   (Recinfo.transfer_subinventory =  X_Transfer_Subinventory)
                            OR (    (Recinfo.transfer_subinventory IS NULL)
                                AND (X_Transfer_Subinventory IS NULL)))
                       AND (   (Recinfo.transfer_organization =  X_Transfer_Organization)
                            OR (    (Recinfo.transfer_organization IS NULL)
                                AND (X_Transfer_Organization IS NULL)))
                       AND (   (Recinfo.transfer_locator =  X_Transfer_Locator)
                            OR (    (Recinfo.transfer_locator IS NULL)
                                AND (X_Transfer_Locator IS NULL)))
                       AND (   (Recinfo.xfer_loc_segment1 =  X_Xfer_Loc_Segment1)
                            OR (    (Recinfo.xfer_loc_segment1 IS NULL)
                                AND (X_Xfer_Loc_Segment1 IS NULL)))
                       AND (   (Recinfo.xfer_loc_segment2 =  X_Xfer_Loc_Segment2)
                            OR (    (Recinfo.xfer_loc_segment2 IS NULL)
                                AND (X_Xfer_Loc_Segment2 IS NULL)))
                       AND (   (Recinfo.xfer_loc_segment3 =  X_Xfer_Loc_Segment3)
                            OR (    (Recinfo.xfer_loc_segment3 IS NULL)
                                AND (X_Xfer_Loc_Segment3 IS NULL)))
                       AND (   (Recinfo.xfer_loc_segment4 =  X_Xfer_Loc_Segment4)
                            OR (    (Recinfo.xfer_loc_segment4 IS NULL)
                                AND (X_Xfer_Loc_Segment4 IS NULL)))
                       AND (   (Recinfo.xfer_loc_segment5 =  X_Xfer_Loc_Segment5)
                            OR (    (Recinfo.xfer_loc_segment5 IS NULL)
                                AND (X_Xfer_Loc_Segment5 IS NULL)))
                       AND (   (Recinfo.xfer_loc_segment6 =  X_Xfer_Loc_Segment6)
                            OR (    (Recinfo.xfer_loc_segment6 IS NULL)
                                AND (X_Xfer_Loc_Segment6 IS NULL)))
                       AND (   (Recinfo.xfer_loc_segment7 =  X_Xfer_Loc_Segment7)
                            OR (    (Recinfo.xfer_loc_segment7 IS NULL)
                                AND (X_Xfer_Loc_Segment7 IS NULL)))
                       AND (   (Recinfo.xfer_loc_segment8 =  X_Xfer_Loc_Segment8)
                            OR (    (Recinfo.xfer_loc_segment8 IS NULL)
                                AND (X_Xfer_Loc_Segment8 IS NULL)))
                       AND (   (Recinfo.xfer_loc_segment9 =  X_Xfer_Loc_Segment9)
                            OR (    (Recinfo.xfer_loc_segment9 IS NULL)
                                AND (X_Xfer_Loc_Segment9 IS NULL)))
                         ) then
                               if (
                                    (   (Recinfo.xfer_loc_segment10 = X_Xfer_Loc_Segment10)
                                     OR (    (Recinfo.xfer_loc_segment10 IS NULL)
                                         AND (X_Xfer_Loc_Segment10 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment11 = X_Xfer_Loc_Segment11)
                                     OR (    (Recinfo.xfer_loc_segment11 IS NULL)
                                         AND (X_Xfer_Loc_Segment11 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment12 = X_Xfer_Loc_Segment12)
                                     OR (    (Recinfo.xfer_loc_segment12 IS NULL)
                                         AND (X_Xfer_Loc_Segment12 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment13 = X_Xfer_Loc_Segment13)
                                     OR (    (Recinfo.xfer_loc_segment13 IS NULL)
                                         AND (X_Xfer_Loc_Segment13 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment14 = X_Xfer_Loc_Segment14)
                                     OR (    (Recinfo.xfer_loc_segment14 IS NULL)
                                         AND (X_Xfer_Loc_Segment14 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment15 = X_Xfer_Loc_Segment15)
                                     OR (    (Recinfo.xfer_loc_segment15 IS NULL)
                                         AND (X_Xfer_Loc_Segment15 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment16 = X_Xfer_Loc_Segment16)
                                     OR (    (Recinfo.xfer_loc_segment16 IS NULL)
                                         AND (X_Xfer_Loc_Segment16 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment17 = X_Xfer_Loc_Segment17)
                                     OR (    (Recinfo.xfer_loc_segment17 IS NULL)
                                         AND (X_Xfer_Loc_Segment17 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment18 = X_Xfer_Loc_Segment18)
                                     OR (    (Recinfo.xfer_loc_segment18 IS NULL)
                                         AND (X_Xfer_Loc_Segment18 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment19 = X_Xfer_Loc_Segment19)
                                     OR (    (Recinfo.xfer_loc_segment19 IS NULL)
                                         AND (X_Xfer_Loc_Segment19 IS NULL)))
                                AND (   (Recinfo.xfer_loc_segment20 = X_Xfer_Loc_Segment20)
                                     OR (    (Recinfo.xfer_loc_segment20 IS NULL)
                                         AND (X_Xfer_Loc_Segment20 IS NULL)))
                                AND (   (Recinfo.shipment_number =  X_Shipment_Number)
                                     OR (    (Recinfo.shipment_number IS NULL)
                                         AND (X_Shipment_Number IS NULL)))
                                AND (   (Recinfo.transportation_cost =  X_Transportation_Cost)
                                     OR (    (Recinfo.transportation_cost IS NULL)
                                         AND (X_Transportation_Cost IS NULL)))
                                AND (   (Recinfo.transportation_account =  X_Transportation_Account)
                                     OR (    (Recinfo.transportation_account IS NULL)
                                         AND (X_Transportation_Account IS NULL)))
                                AND (   (Recinfo.transfer_cost =  X_Transfer_Cost)
                                     OR (    (Recinfo.transfer_cost IS NULL)
                                         AND (X_Transfer_Cost IS NULL)))
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
                                AND (   (Recinfo.new_average_cost =  X_New_Average_Cost)
                                     OR (    (Recinfo.new_average_cost IS NULL)
                                         AND (X_New_Average_Cost IS NULL)))
                                AND (   (Recinfo.value_change =  X_Value_Change)
                                     OR (    (Recinfo.value_change IS NULL)
                                         AND (X_Value_Change IS NULL)))
                                AND (   (Recinfo.percentage_change =  X_Percentage_Change)
                                     OR (    (Recinfo.percentage_change IS NULL)
                                         AND (X_Percentage_Change IS NULL)))
                                AND (   (Recinfo.required_flag =  X_Required_Flag)
                                     OR (    (Recinfo.required_flag IS NULL)
                                         AND (X_Required_Flag IS NULL)))
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
                                AND (   (Recinfo.validation_required =  X_Validation_Required)
                                     OR (    (Recinfo.validation_required IS NULL)
                                         AND (X_Validation_Required IS NULL)))
                                AND (   (Recinfo.negative_req_flag =  X_Negative_Req_Flag)
                                     OR (    (Recinfo.negative_req_flag IS NULL)
                                         AND (X_Negative_Req_Flag IS NULL)))
                                AND (   (Recinfo.shippable_flag =  X_Shippable_Flag)
                                     OR (    (Recinfo.shippable_flag IS NULL)
                                         AND (X_Shippable_Flag IS NULL)))
                                AND (   (Recinfo.currency_conversion_date =  X_Currency_Conversion_Date)
                                     OR (    (Recinfo.currency_conversion_date IS NULL)
                                         AND (X_Currency_Conversion_Date IS NULL)))
                                AND (   (Recinfo.movement_id =  X_Movement_Id)
                                     OR (    (Recinfo.movement_id IS NULL)
                                         AND (X_Movement_Id IS NULL)))
                                AND (   (Recinfo.source_project_id = X_Source_Project_Id)
                                     OR (    (Recinfo.source_project_id IS NULL)
                                         AND (X_Source_Project_Id IS NULL)))
                                AND (   (Recinfo.source_task_id = X_Source_Task_Id)
                                     OR (    (Recinfo.source_task_id IS NULL)
                                         AND (X_Source_Task_Id IS NULL)))
                                AND (   (Recinfo.project_id = X_Project_Id)
                                     OR (    (Recinfo.project_id IS NULL)
                                         AND (X_Project_Id IS NULL)))
                                AND (   (Recinfo.task_id = X_Task_Id)
                                     OR (    (Recinfo.task_id IS NULL)
                                         AND (X_Task_Id IS NULL)))
                                AND (   (Recinfo.to_project_id = X_To_Project_Id)
                                     OR (    (Recinfo.to_project_id IS NULL)
                                         AND (X_To_Project_Id IS NULL)))
                                AND (   (Recinfo.to_task_id = X_To_Task_Id)
                                     OR (    (Recinfo.to_task_id IS NULL)
                                         AND (X_To_Task_Id IS NULL)))
                                AND (   (Recinfo.pa_expenditure_org_id = X_Pa_Expenditure_Org_Id)
                                     OR (    (Recinfo.pa_expenditure_org_id IS NULL)
                                         AND (X_Pa_Expenditure_Org_Id IS NULL)))
                                AND (   (Recinfo.expenditure_type = X_Expenditure_Type)
                                     OR (    (Recinfo.expenditure_type IS NULL)
                                         AND (X_Expenditure_Type IS NULL)))
                                             --2520630
                                         AND (  (Recinfo.demand_source_header_id = X_demand_source_header_id)
                                                          OR (    (Recinfo.demand_source_header_id IS NULL)
                                                                   AND (X_demand_source_header_id IS NULL)))
                                AND (   (Recinfo.demand_source_line = X_demand_source_line)
                                     OR (    (Recinfo.demand_source_line IS NULL)
                                         AND (X_demand_source_line IS NULL)))
                                AND (   (Recinfo.demand_source_delivery = X_demand_source_delivery)
                                     OR (    (Recinfo.demand_source_delivery IS NULL)
                                         AND (X_demand_source_delivery IS NULL)))
                                --2520630


                                  ) then
                                    return;
                              else
                                 FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                                 APP_EXCEPTION.Raise_Exception;
                               end if;
                      else
                         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                         APP_EXCEPTION.Raise_Exception;
                      end if;
              else
                 FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                 APP_EXCEPTION.Raise_Exception;
              end if;
      else
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
         APP_EXCEPTION.Raise_Exception;
      end if;

  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Source_Code                    VARCHAR2,
                       X_Source_Line_Id                 NUMBER,
                       X_Source_Header_Id               NUMBER,
                       X_Process_Flag                   NUMBER,
                       X_Transaction_Mode               NUMBER,
                       X_Lock_Flag                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Item_Segment1                  VARCHAR2,
                       X_Item_Segment2                  VARCHAR2,
                       X_Item_Segment3                  VARCHAR2,
                       X_Item_Segment4                  VARCHAR2,
                       X_Item_Segment5                  VARCHAR2,
                       X_Item_Segment6                  VARCHAR2,
                       X_Item_Segment7                  VARCHAR2,
                       X_Item_Segment8                  VARCHAR2,
                       X_Item_Segment9                  VARCHAR2,
                       X_Item_Segment10                 VARCHAR2,
                       X_Item_Segment11                 VARCHAR2,
                       X_Item_Segment12                 VARCHAR2,
                       X_Item_Segment13                 VARCHAR2,
                       X_Item_Segment14                 VARCHAR2,
                       X_Item_Segment15                 VARCHAR2,
                       X_Item_Segment16                 VARCHAR2,
                       X_Item_Segment17                 VARCHAR2,
                       X_Item_Segment18                 VARCHAR2,
                       X_Item_Segment19                 VARCHAR2,
                       X_Item_Segment20                 VARCHAR2,
                       X_Revision                       VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Transaction_Quantity           NUMBER,
                       X_Primary_Quantity               NUMBER,
                       X_Transaction_Uom                VARCHAR2,
                       X_Transaction_Date               DATE,
                       X_Subinventory_Code              VARCHAR2,
                       X_Locator_Id                     NUMBER,
                       X_Loc_Segment1                   VARCHAR2,
                       X_Loc_Segment2                   VARCHAR2,
                       X_Loc_Segment3                   VARCHAR2,
                       X_Loc_Segment4                   VARCHAR2,
                       X_Loc_Segment5                   VARCHAR2,
                       X_Loc_Segment6                   VARCHAR2,
                       X_Loc_Segment7                   VARCHAR2,
                       X_Loc_Segment8                   VARCHAR2,
                       X_Loc_Segment9                   VARCHAR2,
                       X_Loc_Segment10                  VARCHAR2,
                       X_Loc_Segment11                  VARCHAR2,
                       X_Loc_Segment12                  VARCHAR2,
                       X_Loc_Segment13                  VARCHAR2,
                       X_Loc_Segment14                  VARCHAR2,
                       X_Loc_Segment15                  VARCHAR2,
                       X_Loc_Segment16                  VARCHAR2,
                       X_Loc_Segment17                  VARCHAR2,
                       X_Loc_Segment18                  VARCHAR2,
                       X_Loc_Segment19                  VARCHAR2,
                       X_Loc_Segment20                  VARCHAR2,
                       X_Transaction_Source_Id          NUMBER,
                       X_Dsp_Segment1                   VARCHAR2,
                       X_Dsp_Segment2                   VARCHAR2,
                       X_Dsp_Segment3                   VARCHAR2,
                       X_Dsp_Segment4                   VARCHAR2,
                       X_Dsp_Segment5                   VARCHAR2,
                       X_Dsp_Segment6                   VARCHAR2,
                       X_Dsp_Segment7                   VARCHAR2,
                       X_Dsp_Segment8                   VARCHAR2,
                       X_Dsp_Segment9                   VARCHAR2,
                       X_Dsp_Segment10                  VARCHAR2,
                       X_Dsp_Segment11                  VARCHAR2,
                       X_Dsp_Segment12                  VARCHAR2,
                       X_Dsp_Segment13                  VARCHAR2,
                       X_Dsp_Segment14                  VARCHAR2,
                       X_Dsp_Segment15                  VARCHAR2,
                       X_Dsp_Segment16                  VARCHAR2,
                       X_Dsp_Segment17                  VARCHAR2,
                       X_Dsp_Segment18                  VARCHAR2,
                       X_Dsp_Segment19                  VARCHAR2,
                       X_Dsp_Segment20                  VARCHAR2,
                       X_Dsp_Segment21                  VARCHAR2,
                       X_Dsp_Segment22                  VARCHAR2,
                       X_Dsp_Segment23                  VARCHAR2,
                       X_Dsp_Segment24                  VARCHAR2,
                       X_Dsp_Segment25                  VARCHAR2,
                       X_Dsp_Segment26                  VARCHAR2,
                       X_Dsp_Segment27                  VARCHAR2,
                       X_Dsp_Segment28                  VARCHAR2,
                       X_Dsp_Segment29                  VARCHAR2,
                       X_Dsp_Segment30                  VARCHAR2,
                       X_Transaction_Source_Name        VARCHAR2,
                       X_Transaction_Source_Type_Id     NUMBER,
                       X_Transaction_Action_Id          NUMBER,
                       X_Transaction_Type_Id            NUMBER,
                       X_Reason_Id                      NUMBER,
                       X_Transaction_Reference          VARCHAR2,
                       X_Transaction_Cost               NUMBER,
                       X_cost_group_id                  NUMBER,
                       X_Distribution_Account_Id        NUMBER,
                       X_Dst_Segment1                   VARCHAR2,
                       X_Dst_Segment2                   VARCHAR2,
                       X_Dst_Segment3                   VARCHAR2,
                       X_Dst_Segment4                   VARCHAR2,
                       X_Dst_Segment5                   VARCHAR2,
                       X_Dst_Segment6                   VARCHAR2,
                       X_Dst_Segment7                   VARCHAR2,
                       X_Dst_Segment8                   VARCHAR2,
                       X_Dst_Segment9                   VARCHAR2,
                       X_Dst_Segment10                  VARCHAR2,
                       X_Dst_Segment11                  VARCHAR2,
                       X_Dst_Segment12                  VARCHAR2,
                       X_Dst_Segment13                  VARCHAR2,
                       X_Dst_Segment14                  VARCHAR2,
                       X_Dst_Segment15                  VARCHAR2,
                       X_Dst_Segment16                  VARCHAR2,
                       X_Dst_Segment17                  VARCHAR2,
                       X_Dst_Segment18                  VARCHAR2,
                       X_Dst_Segment19                  VARCHAR2,
                       X_Dst_Segment20                  VARCHAR2,
                       X_Dst_Segment21                  VARCHAR2,
                       X_Dst_Segment22                  VARCHAR2,
                       X_Dst_Segment23                  VARCHAR2,
                       X_Dst_Segment24                  VARCHAR2,
                       X_Dst_Segment25                  VARCHAR2,
                       X_Dst_Segment26                  VARCHAR2,
                       X_Dst_Segment27                  VARCHAR2,
                       X_Dst_Segment28                  VARCHAR2,
                       X_Dst_Segment29                  VARCHAR2,
                       X_Dst_Segment30                  VARCHAR2,
                       X_Currency_Code                  VARCHAR2,
                       X_Currency_Conversion_Type       VARCHAR2,
                       X_Currency_Conversion_Rate       NUMBER,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Wip_Entity_Type                NUMBER,
                       X_Schedule_Id                    NUMBER,
                       X_Employee_Code                  VARCHAR2,
                       X_Department_Id                  NUMBER,
                       X_Schedule_Update_Code           NUMBER,
                       X_Setup_Teardown_Code            NUMBER,
                       X_Primary_Switch                 NUMBER,
                       X_Mrp_Code                       NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Repetitive_Line_Id             NUMBER,
                       X_Line_Item_Num                  NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Encumbrance_Account            NUMBER,
                       X_Encumbrance_Amount             NUMBER,
                       X_Transfer_Subinventory          VARCHAR2,
                       X_Transfer_Organization          NUMBER,
                       X_Transfer_Locator               NUMBER,
                       X_Xfer_Loc_Segment1              VARCHAR2,
                       X_Xfer_Loc_Segment2              VARCHAR2,
                       X_Xfer_Loc_Segment3              VARCHAR2,
                       X_Xfer_Loc_Segment4              VARCHAR2,
                       X_Xfer_Loc_Segment5              VARCHAR2,
                       X_Xfer_Loc_Segment6              VARCHAR2,
                       X_Xfer_Loc_Segment7              VARCHAR2,
                       X_Xfer_Loc_Segment8              VARCHAR2,
                       X_Xfer_Loc_Segment9              VARCHAR2,
                       X_Xfer_Loc_Segment10             VARCHAR2,
                       X_Xfer_Loc_Segment11             VARCHAR2,
                       X_Xfer_Loc_Segment12             VARCHAR2,
                       X_Xfer_Loc_Segment13             VARCHAR2,
                       X_Xfer_Loc_Segment14             VARCHAR2,
                       X_Xfer_Loc_Segment15             VARCHAR2,
                       X_Xfer_Loc_Segment16             VARCHAR2,
                       X_Xfer_Loc_Segment17             VARCHAR2,
                       X_Xfer_Loc_Segment18             VARCHAR2,
                       X_Xfer_Loc_Segment19             VARCHAR2,
                       X_Xfer_Loc_Segment20             VARCHAR2,
                       X_Shipment_Number                VARCHAR2,
                       X_Transportation_Cost            NUMBER,
                       X_Transportation_Account         NUMBER,
                       X_Transfer_Cost                  NUMBER,
                       X_Freight_Code                   VARCHAR2,
                       X_Containers                     NUMBER,
                       X_Waybill_Airbill                VARCHAR2,
                       X_Expected_Arrival_Date          DATE,
                       X_New_Average_Cost               NUMBER,
                       X_Value_Change                   NUMBER,
                       X_Percentage_Change              NUMBER,
                       X_Required_Flag                  VARCHAR2,
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
                       X_Validation_Required            NUMBER,
                       X_Negative_Req_Flag              NUMBER,
                       X_Shippable_Flag                 VARCHAR2,
                       X_Currency_Conversion_Date       DATE,
                       X_Movement_Id                    NUMBER,
                       X_Source_Project_Id              NUMBER,
                       X_Source_Task_Id                 NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_To_Project_Id                  NUMBER,
                       X_To_Task_Id                     NUMBER,
                       X_Pa_Expenditure_Org_Id          NUMBER,
                       X_Expenditure_Type               VARCHAR2,
                       X_Lpn_Id                         NUMBER,
                       X_Transfer_Lpn_Id                NUMBER,
                       X_Transfer_Cost_Group_Id         NUMBER,
                       X_content_lpn_id                 NUMBER,
                       X_demand_source_header_id        NUMBER,     --2520630
                       X_demand_source_line             VARCHAR2,   --2520630
                       X_demand_source_delivery         VARCHAR2,   --2520630
                       x_owning_organization_id         NUMBER,
                       x_owning_tp_type                 NUMBER,
                       x_planning_organization_id       NUMBER,
                       x_planning_tp_type               NUMBER,
                       x_material_account               NUMBER,  --Bug#5208421
--- INVCON kkillams
                       x_secondary_qty                  NUMBER,
                       x_secondary_uom_code             VARCHAR2
---END  INVCON kkillams



  ) IS

  number_of_components NUMBER := 0;
  l_transaction_batch_id NUMBER;
  l_transaction_header_id NUMBER;
  BEGIN
    UPDATE MTL_TRANSACTIONS_INTERFACE
    SET
       source_code                     =     X_Source_Code,
       source_line_id                  =     X_Source_Line_Id,
       source_header_id                =     X_Source_Header_Id,
       process_flag                    =     X_Process_Flag,
       transaction_mode                =     X_Transaction_Mode,
       lock_flag                       =     X_Lock_Flag,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       inventory_item_id               =     X_Inventory_Item_Id,
       item_segment1                   =     X_Item_Segment1,
       item_segment2                   =     X_Item_Segment2,
       item_segment3                   =     X_Item_Segment3,
       item_segment4                   =     X_Item_Segment4,
       item_segment5                   =     X_Item_Segment5,
       item_segment6                   =     X_Item_Segment6,
       item_segment7                   =     X_Item_Segment7,
       item_segment8                   =     X_Item_Segment8,
       item_segment9                   =     X_Item_Segment9,
       item_segment10                  =     X_Item_Segment10,
       item_segment11                  =     X_Item_Segment11,
       item_segment12                  =     X_Item_Segment12,
       item_segment13                  =     X_Item_Segment13,
       item_segment14                  =     X_Item_Segment14,
       item_segment15                  =     X_Item_Segment15,
       item_segment16                  =     X_Item_Segment16,
       item_segment17                  =     X_Item_Segment17,
       item_segment18                  =     X_Item_Segment18,
       item_segment19                  =     X_Item_Segment19,
       item_segment20                  =     X_Item_Segment20,
       revision                        =     X_Revision,
       organization_id                 =     X_Organization_Id,
       transaction_quantity            =     X_Transaction_Quantity,
       primary_quantity                =     X_Primary_Quantity,
       transaction_uom                 =     X_Transaction_Uom,
       transaction_date                =     X_Transaction_Date,
       subinventory_code               =     X_Subinventory_Code,
       locator_id                      =     X_Locator_Id,
       loc_segment1                    =     X_Loc_Segment1,
       loc_segment2                    =     X_Loc_Segment2,
       loc_segment3                    =     X_Loc_Segment3,
       loc_segment4                    =     X_Loc_Segment4,
       loc_segment5                    =     X_Loc_Segment5,
       loc_segment6                    =     X_Loc_Segment6,
       loc_segment7                    =     X_Loc_Segment7,
       loc_segment8                    =     X_Loc_Segment8,
       loc_segment9                    =     X_Loc_Segment9,
       loc_segment10                   =     X_Loc_Segment10,
       loc_segment11                   =     X_Loc_Segment11,
       loc_segment12                   =     X_Loc_Segment12,
       loc_segment13                   =     X_Loc_Segment13,
       loc_segment14                   =     X_Loc_Segment14,
       loc_segment15                   =     X_Loc_Segment15,
       loc_segment16                   =     X_Loc_Segment16,
       loc_segment17                   =     X_Loc_Segment17,
       loc_segment18                   =     X_Loc_Segment18,
       loc_segment19                   =     X_Loc_Segment19,
       loc_segment20                   =     X_Loc_Segment20,
       transaction_source_id           =     X_Transaction_Source_Id,
       dsp_segment1                    =     X_Dsp_Segment1,
       dsp_segment2                    =     X_Dsp_Segment2,
       dsp_segment3                    =     X_Dsp_Segment3,
       dsp_segment4                    =     X_Dsp_Segment4,
       dsp_segment5                    =     X_Dsp_Segment5,
       dsp_segment6                    =     X_Dsp_Segment6,
       dsp_segment7                    =     X_Dsp_Segment7,
       dsp_segment8                    =     X_Dsp_Segment8,
       dsp_segment9                    =     X_Dsp_Segment9,
       dsp_segment10                   =     X_Dsp_Segment10,
       dsp_segment11                   =     X_Dsp_Segment11,
       dsp_segment12                   =     X_Dsp_Segment12,
       dsp_segment13                   =     X_Dsp_Segment13,
       dsp_segment14                   =     X_Dsp_Segment14,
       dsp_segment15                   =     X_Dsp_Segment15,
       dsp_segment16                   =     X_Dsp_Segment16,
       dsp_segment17                   =     X_Dsp_Segment17,
       dsp_segment18                   =     X_Dsp_Segment18,
       dsp_segment19                   =     X_Dsp_Segment19,
       dsp_segment20                   =     X_Dsp_Segment20,
       dsp_segment21                   =     X_Dsp_Segment21,
       dsp_segment22                   =     X_Dsp_Segment22,
       dsp_segment23                   =     X_Dsp_Segment23,
       dsp_segment24                   =     X_Dsp_Segment24,
       dsp_segment25                   =     X_Dsp_Segment25,
       dsp_segment26                   =     X_Dsp_Segment26,
       dsp_segment27                   =     X_Dsp_Segment27,
       dsp_segment28                   =     X_Dsp_Segment28,
       dsp_segment29                   =     X_Dsp_Segment29,
       dsp_segment30                   =     X_Dsp_Segment30,
       transaction_source_name         =     X_Transaction_Source_Name,
       transaction_source_type_id      =     X_Transaction_Source_Type_Id,
       transaction_action_id           =     X_Transaction_Action_Id,
       transaction_type_id             =     X_Transaction_Type_Id,
       reason_id                       =     X_Reason_Id,
       transaction_reference           =     X_Transaction_Reference,
       transaction_cost                =     X_Transaction_Cost,
       cost_group_id                   =     X_cost_group_id,
       distribution_account_id         =     X_Distribution_Account_Id,
       dst_segment1                    =     X_Dst_Segment1,
       dst_segment2                    =     X_Dst_Segment2,
       dst_segment3                    =     X_Dst_Segment3,
       dst_segment4                    =     X_Dst_Segment4,
       dst_segment5                    =     X_Dst_Segment5,
       dst_segment6                    =     X_Dst_Segment6,
       dst_segment7                    =     X_Dst_Segment7,
       dst_segment8                    =     X_Dst_Segment8,
       dst_segment9                    =     X_Dst_Segment9,
       dst_segment10                   =     X_Dst_Segment10,
       dst_segment11                   =     X_Dst_Segment11,
       dst_segment12                   =     X_Dst_Segment12,
       dst_segment13                   =     X_Dst_Segment13,
       dst_segment14                   =     X_Dst_Segment14,
       dst_segment15                   =     X_Dst_Segment15,
       dst_segment16                   =     X_Dst_Segment16,
       dst_segment17                   =     X_Dst_Segment17,
       dst_segment18                   =     X_Dst_Segment18,
       dst_segment19                   =     X_Dst_Segment19,
       dst_segment20                   =     X_Dst_Segment20,
       dst_segment21                   =     X_Dst_Segment21,
       dst_segment22                   =     X_Dst_Segment22,
       dst_segment23                   =     X_Dst_Segment23,
       dst_segment24                   =     X_Dst_Segment24,
       dst_segment25                   =     X_Dst_Segment25,
       dst_segment26                   =     X_Dst_Segment26,
       dst_segment27                   =     X_Dst_Segment27,
       dst_segment28                   =     X_Dst_Segment28,
       dst_segment29                   =     X_Dst_Segment29,
       dst_segment30                   =     X_Dst_Segment30,
       currency_code                   =     X_Currency_Code,
       currency_conversion_type        =     X_Currency_Conversion_Type,
       currency_conversion_rate        =     X_Currency_Conversion_Rate,
       ussgl_transaction_code          =     X_Ussgl_Transaction_Code,
       wip_entity_type                 =     X_Wip_Entity_Type,
       schedule_id                     =     X_Schedule_Id,
       employee_code                   =     X_Employee_Code,
       department_id                   =     X_Department_Id,
       schedule_update_code            =     X_Schedule_Update_Code,
       setup_teardown_code             =     X_Setup_Teardown_Code,
       primary_switch                  =     X_Primary_Switch,
       mrp_code                        =     X_Mrp_Code,
       operation_seq_num               =     X_Operation_Seq_Num,
       repetitive_line_id              =     X_Repetitive_Line_Id,
       line_item_num                   =     X_Line_Item_Num,
       ship_to_location_id             =     X_Ship_To_Location_Id,
       encumbrance_account             =     X_Encumbrance_Account,
       encumbrance_amount              =     X_Encumbrance_Amount,
       transfer_subinventory           =     X_Transfer_Subinventory,
       transfer_organization           =     X_Transfer_Organization,
       transfer_locator                =     X_Transfer_Locator,
       xfer_loc_segment1               =     X_Xfer_Loc_Segment1,
       xfer_loc_segment2               =     X_Xfer_Loc_Segment2,
       xfer_loc_segment3               =     X_Xfer_Loc_Segment3,
       xfer_loc_segment4               =     X_Xfer_Loc_Segment4,
       xfer_loc_segment5               =     X_Xfer_Loc_Segment5,
       xfer_loc_segment6               =     X_Xfer_Loc_Segment6,
       xfer_loc_segment7               =     X_Xfer_Loc_Segment7,
       xfer_loc_segment8               =     X_Xfer_Loc_Segment8,
       xfer_loc_segment9               =     X_Xfer_Loc_Segment9,
       xfer_loc_segment10              =     X_Xfer_Loc_Segment10,
       xfer_loc_segment11              =     X_Xfer_Loc_Segment11,
       xfer_loc_segment12              =     X_Xfer_Loc_Segment12,
       xfer_loc_segment13              =     X_Xfer_Loc_Segment13,
       xfer_loc_segment14              =     X_Xfer_Loc_Segment14,
       xfer_loc_segment15              =     X_Xfer_Loc_Segment15,
       xfer_loc_segment16              =     X_Xfer_Loc_Segment16,
       xfer_loc_segment17              =     X_Xfer_Loc_Segment17,
       xfer_loc_segment18              =     X_Xfer_Loc_Segment18,
       xfer_loc_segment19              =     X_Xfer_Loc_Segment19,
       xfer_loc_segment20              =     X_Xfer_Loc_Segment20,
       shipment_number                 =     X_Shipment_Number,
       transportation_cost             =     X_Transportation_Cost,
       transportation_account          =     X_Transportation_Account,
       transfer_cost                   =     X_Transfer_Cost,
       freight_code                    =     X_Freight_Code,
       containers                      =     X_Containers,
       waybill_airbill                 =     X_Waybill_Airbill,
       expected_arrival_date           =     X_Expected_Arrival_Date,
       new_average_cost                =     X_New_Average_Cost,
       value_change                    =     X_Value_Change,
       percentage_change               =     X_Percentage_Change,
       required_flag                   =     X_Required_Flag,
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
       validation_required             =     X_Validation_Required,
       negative_req_flag               =     X_Negative_Req_Flag,
       shippable_flag                  =     X_Shippable_Flag,
       currency_conversion_date        =     X_Currency_Conversion_Date,
       movement_id                     =     X_Movement_Id,
       source_project_id               =     X_Source_Project_Id,
       source_task_id                  =     X_Source_Task_Id,
       project_id                      =     X_Project_Id,
       task_id                         =     X_Task_Id,
       to_project_id                   =     X_To_Project_Id,
       to_task_id                      =     X_To_Task_Id,
       pa_expenditure_org_id           =     X_Pa_Expenditure_Org_Id,
       expenditure_type                =     X_Expenditure_Type,
       lpn_id                          =     X_Lpn_Id,
       transfer_lpn_id                 =     X_Transfer_lpn_id,
       transfer_cost_group_id          =     X_Transfer_Cost_Group_Id,
       content_lpn_id                  =     x_content_lpn_id,
       owning_tp_type                  =     x_owning_tp_type,
       owning_organization_id          =     x_owning_organization_id,
       planning_organization_id        =     x_planning_organization_id,
       planning_tp_type                =     x_planning_tp_type,
       demand_source_header_id         =     X_demand_source_header_id, --2520630
       demand_source_line              =     X_demand_source_line, --2520630
       demand_source_delivery          =     X_demand_source_delivery,  --2520630
       material_account                =     x_material_account, --Bug#5208421
       --INVCON kkillams
       secondary_transaction_quantity  =     x_secondary_qty,
       secondary_uom_code              =     x_secondary_uom_code
       --END INVCON kkillams

    WHERE rowid = X_Rowid;

    --resubmit dependent records
    -- Bug Fix:4209056

    select  transaction_batch_id,transaction_header_id
      into l_transaction_batch_id,l_transaction_header_id
      from mtl_transactions_interface
      where  rowid = X_Rowid;

    IF (l_transaction_batch_id IS NOT NULL) THEN

       UPDATE mtl_transactions_interface
         SET process_flag = 1
         , transaction_mode = 3
         , lock_flag = 2
         WHERE transaction_header_id = l_transaction_header_id
         AND transaction_batch_id=l_transaction_batch_id
         AND Nvl(lock_flag,2) <> 1;
     ELSE
       UPDATE mtl_transactions_interface
         SET process_flag = 1
         , transaction_mode = 3
         , lock_flag = 2
         where  rowid = X_Rowid;
    END IF;

    --end of resubmit dependent records (Bug Fix:4209056)


/* Removing this code for the Bug Fix-4209056
-- Begin for the bug 2203608
    if (X_Process_Flag = 1 and X_Transaction_Type_Id in (44,90,91,17)) then

           SELECT COUNT(*)
           INTO   NUMBER_OF_COMPONENTS
           FROM   MTL_TRANSACTIONS_INTERFACE
           WHERE PARENT_ID = (SELECT nvl(TRANSACTION_INTERFACE_ID,-9999)
                                 FROM MTL_TRANSACTIONS_INTERFACE
                                 WHERE ROWID = X_Rowid)
           AND FLOW_SCHEDULE = 'Y';

           if nvl(NUMBER_OF_COMPONENTS,0) > 0 then
               UPDATE  MTL_TRANSACTIONS_INTERFACE
               SET     PROCESS_FLAG = 2,
                       TRANSACTION_MODE   =  3,
                       LOCK_FLAG   =     2,
                       ERROR_CODE = NULL ,
                       ERROR_EXPLANATION = NULL
               WHERE   PARENT_ID = (SELECT nvl(TRANSACTION_INTERFACE_ID,-9999)
                                  FROM MTL_TRANSACTIONS_INTERFACE
                                 WHERE ROWID = X_Rowid)
               AND     FLOW_SCHEDULE = 'Y';
          end if;
    end if;
--End for the bug 2203608
End of removing code for Bug Fix-4209056*/

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

  x_tran_type_id NUMBER ;
  number_of_components NUMBER:= 0 ;

  BEGIN

-- Begin for the bug 2203608
    select transaction_Type_id into x_tran_type_id from mtl_Transactions_interface
    WHERE rowid = X_Rowid;

    if (x_tran_type_id in (44,90,91,17)) then

           SELECT COUNT(*)
           INTO   NUMBER_OF_COMPONENTS
           FROM   MTL_TRANSACTIONS_INTERFACE
           WHERE PARENT_ID = (SELECT nvl(TRANSACTION_INTERFACE_ID,-9999)
                                 FROM MTL_TRANSACTIONS_INTERFACE
                                 WHERE ROWID = X_Rowid)
           AND FLOW_SCHEDULE = 'Y';

           if nvl(NUMBER_OF_COMPONENTS,0) > 0 then
               DELETE  FROM MTL_TRANSACTIONS_INTERFACE
               WHERE   PARENT_ID = (SELECT nvl(TRANSACTION_INTERFACE_ID,-9999)
                                  FROM MTL_TRANSACTIONS_INTERFACE
                                 WHERE ROWID = X_Rowid)
               AND     FLOW_SCHEDULE = 'Y';
          end if;
    end if;
--End for the bug 2203608


    DELETE FROM MTL_TRANSACTIONS_INTERFACE
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END MTL_TRANSACTIONS_INTERFACE_PKG;

/
