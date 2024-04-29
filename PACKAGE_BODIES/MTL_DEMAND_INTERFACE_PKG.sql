--------------------------------------------------------
--  DDL for Package Body MTL_DEMAND_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_DEMAND_INTERFACE_PKG" as
/* $Header: INVDVINB.pls 120.1 2005/07/01 12:17:18 appldev ship $ */

  PROCEDURE Lock_Row(	X_ROWID   				   VARCHAR2,
			X_SCHEDULE_GROUP_ID                        NUMBER,
 			X_DEMAND_SOURCE_TYPE                       NUMBER,
 			X_DEMAND_SOURCE_HEADER_ID                  NUMBER,
 			X_DEMAND_SOURCE_LINE                       VARCHAR2,
 			X_DEMAND_SOURCE_DELIVERY                   VARCHAR2,
 			X_ATP_CHECK                                NUMBER,
	 		X_ACTION_CODE                              NUMBER,
 			X_VALIDATE_ROWS                            NUMBER,
 			X_TRANSACTION_MODE                         NUMBER,
 			X_PROCESS_FLAG                             NUMBER,
	 		X_SINGLE_LOT_FLAG                          NUMBER,
 			X_DETAIL_RESERVE_FLAG                      NUMBER,
 			X_RESERVE_LEVEL                            NUMBER,
 			X_CHECK_ATR                                NUMBER,
 			X_ERROR_CODE                               NUMBER,
 			X_ERR_EXPLANATION                          VARCHAR2,
 			X_REQUIREMENT_DATE                         DATE,
 			X_LINE_ITEM_UNIT_OF_MEASURE                VARCHAR2,
 			X_LINE_ITEM_UOM                            VARCHAR2,
 			X_LINE_ITEM_QUANTITY              	   NUMBER,
 			X_LINE_ITEM_RESERVATION_QTY                NUMBER,
 			X_PRIMARY_UOM                              VARCHAR2,
 			X_PRIMARY_UOM_QUANTITY                     NUMBER,
 			X_RESERVATION_QUANTITY                     NUMBER,
 			X_ATP_RULE_ID                              NUMBER,
 			X_ORGANIZATION_ID                          NUMBER,
 			X_ORGANIZATION_NAME                        VARCHAR2,
 			X_INVENTORY_ITEM_ID                        NUMBER,
 			X_ITEM_SEGMENT1                            VARCHAR2,
 			X_ITEM_SEGMENT2                            VARCHAR2,
 			X_ITEM_SEGMENT3                            VARCHAR2,
 			X_ITEM_SEGMENT4                            VARCHAR2,
 			X_ITEM_SEGMENT5                            VARCHAR2,
 			X_ITEM_SEGMENT6                            VARCHAR2,
 			X_ITEM_SEGMENT7                            VARCHAR2,
 			X_ITEM_SEGMENT8                            VARCHAR2,
 			X_ITEM_SEGMENT9                            VARCHAR2,
 			X_ITEM_SEGMENT10                           VARCHAR2,
 			X_ITEM_SEGMENT11                           VARCHAR2,
 			X_ITEM_SEGMENT12                           VARCHAR2,
 			X_ITEM_SEGMENT13                           VARCHAR2,
 			X_ITEM_SEGMENT14                           VARCHAR2,
 			X_ITEM_SEGMENT15                           VARCHAR2,
 			X_ITEM_SEGMENT16                           VARCHAR2,
 			X_ITEM_SEGMENT17                           VARCHAR2,
 			X_ITEM_SEGMENT18                           VARCHAR2,
 			X_ITEM_SEGMENT19                           VARCHAR2,
 			X_ITEM_SEGMENT20                           VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT1                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT2                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT3                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT4                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT5                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT6                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT7                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT8                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT9                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT10                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT11                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT12                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT13                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT14                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT15                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT16                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT17                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT18                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT19                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT20                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT21                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT22                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT23                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT24                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT25                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT26                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT27                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT28                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT29                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT30                  VARCHAR2,
 			X_EXTERNAL_SOURCE_CODE                     VARCHAR2,
 			X_EXTERNAL_SOURCE_LINE_ID                  NUMBER,
 			X_SUPPLY_SOURCE_TYPE                       NUMBER,
 			X_SUPPLY_HEADER_ID                         NUMBER,
 			X_USER_LINE_NUM                            VARCHAR2,
 			X_USER_DELIVERY                            VARCHAR2,
 			X_REVISION                                 VARCHAR2,
 			X_LOT_NUMBER                               VARCHAR2,
 			X_SERIAL_NUMBER                            VARCHAR2,
 			X_SUBINVENTORY                             VARCHAR2,
 			X_LOCATOR_ID                               NUMBER,
 			X_LOC_SEGMENT1                             VARCHAR2,
 			X_LOC_SEGMENT2                             VARCHAR2,
 			X_LOC_SEGMENT3                             VARCHAR2,
 			X_LOC_SEGMENT4                             VARCHAR2,
 			X_LOC_SEGMENT5                             VARCHAR2,
 			X_LOC_SEGMENT6                             VARCHAR2,
 			X_LOC_SEGMENT7                             VARCHAR2,
 			X_LOC_SEGMENT8                             VARCHAR2,
 			X_LOC_SEGMENT9                             VARCHAR2,
 			X_LOC_SEGMENT10                            VARCHAR2,
 			X_LOC_SEGMENT11                            VARCHAR2,
 			X_LOC_SEGMENT12                            VARCHAR2,
 			X_LOC_SEGMENT13                            VARCHAR2,
 			X_LOC_SEGMENT14                            VARCHAR2,
 			X_LOC_SEGMENT15                            VARCHAR2,
 			X_LOC_SEGMENT16                            VARCHAR2,
 			X_LOC_SEGMENT17                            VARCHAR2,
 			X_LOC_SEGMENT18                            VARCHAR2,
 			X_LOC_SEGMENT19                            VARCHAR2,
 			X_LOC_SEGMENT20                            VARCHAR2,
 			X_AUTODETAIL_GROUP_ID                      NUMBER,
 			X_COMPONENT_SEQUENCE_ID                    NUMBER,
 			X_PARENT_COMPONENT_SEQ_ID                  NUMBER,
 			X_RTO_MODEL_SOURCE_LINE                    VARCHAR2,
 			X_CONFIG_STATUS                            NUMBER,
 			X_OLD_REVISION                             VARCHAR2,
 			X_OLD_LOT_NUMBER                           VARCHAR2,
 			X_OLD_SUBINVENTORY                         VARCHAR2,
 			X_OLD_LOCATOR_ID                           NUMBER,
 			X_OLD_LOC_SEGMENT1                         VARCHAR2,
 			X_OLD_LOC_SEGMENT2                         VARCHAR2,
 			X_OLD_LOC_SEGMENT3                         VARCHAR2,
 			X_OLD_LOC_SEGMENT4                         VARCHAR2,
 			X_OLD_LOC_SEGMENT5                         VARCHAR2,
 			X_OLD_LOC_SEGMENT6                         VARCHAR2,
 			X_OLD_LOC_SEGMENT7                         VARCHAR2,
 			X_OLD_LOC_SEGMENT8                         VARCHAR2,
 			X_OLD_LOC_SEGMENT9                         VARCHAR2,
 			X_OLD_LOC_SEGMENT10                        VARCHAR2,
 			X_OLD_LOC_SEGMENT11                        VARCHAR2,
 			X_OLD_LOC_SEGMENT12                        VARCHAR2,
 			X_OLD_LOC_SEGMENT13                        VARCHAR2,
 			X_OLD_LOC_SEGMENT14                        VARCHAR2,
 			X_OLD_LOC_SEGMENT15                        VARCHAR2,
 			X_OLD_LOC_SEGMENT16                        VARCHAR2,
 			X_OLD_LOC_SEGMENT17                        VARCHAR2,
 			X_OLD_LOC_SEGMENT18                        VARCHAR2,
 			X_OLD_LOC_SEGMENT19                        VARCHAR2,
 			X_OLD_LOC_SEGMENT20                        VARCHAR2,
 			X_DEMAND_CLASS                             VARCHAR2,
 			X_CUSTOMER_ID                              NUMBER,
 			X_TERRITORY_ID                             NUMBER,
 			X_BILL_TO_SITE_USE_ID                      NUMBER,
 			X_SHIP_TO_SITE_USE_ID                      NUMBER,
 			X_LOT_EXPIRATION_CUTOFF_DATE               DATE,
 			X_PARTIALS_ALLOWED_FLAG                    NUMBER,
 			X_REQUEST_DATE_ATP_QUANTITY                NUMBER,
 			X_EARLIEST_ATP_DATE                        DATE,
 			X_EARLIEST_ATP_DATE_QUANTITY               NUMBER,
 			X_REQUEST_ATP_DATE                         DATE,
 			X_REQUEST_ATP_DATE_QUANTITY                NUMBER,
 			X_GROUP_AVAILABLE_DATE                     DATE,
 			X_ATP_LEAD_TIME                            NUMBER,
 			X_INFINITE_TIME_FENCE_DATE                 DATE,
 			X_GROUP_ATP_CHECK                          NUMBER,
 			X_BOM_LEVEL                                NUMBER,
 			X_EXPLOSION_EFFECTIVITY_DATE               DATE,
			X_ATTRIBUTE_CATEGORY			   VARCHAR2,
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
 			X_C_COLUMN1                                VARCHAR2,
 			X_C_COLUMN2                                VARCHAR2,
 			X_C_COLUMN3                                VARCHAR2,
 			X_C_COLUMN4                                VARCHAR2,
 			X_C_COLUMN5                                VARCHAR2,
 			X_C_COLUMN6                                VARCHAR2,
 			X_C_COLUMN7                                VARCHAR2,
 			X_C_COLUMN8                                VARCHAR2,
 			X_N_COLUMN1                                NUMBER,
 			X_N_COLUMN2                                NUMBER,
 			X_N_COLUMN3                                NUMBER,
 			X_N_COLUMN4                                NUMBER,
 			X_N_COLUMN5                                NUMBER,
 			X_D_COLUMN1                                DATE,
 			X_D_COLUMN2                                DATE,
 			X_D_COLUMN3                                DATE,
 			X_D_COLUMN4                                DATE,
 			X_D_COLUMN5                                DATE,
 			X_TRANSACTION_PROCESS_ORDER                NUMBER,
 			X_DEMAND_ID                                NUMBER,
 			X_DEMAND_SOURCE_NAME                       VARCHAR2,
 			X_DEMAND_TYPE                              NUMBER,
 			X_AVAILABLE_TO_RESERVE                     NUMBER,
 			X_QUANTITY_ON_HAND                         NUMBER,
 			X_ATP_COMPONENTS_FLAG                      NUMBER,
 			X_ATP_CALENDAR_ORGANIZATION_ID             NUMBER,
 			X_AUTODETAIL_EXPENSE_SUBINV                NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   mtl_demand_interface
        WHERE  rowid = X_Rowid
	FOR UPDATE NOWAIT;
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
               (   (Recinfo.schedule_group_id = X_schedule_group_id)
                OR (    (Recinfo.schedule_group_id IS NULL)
                    AND (X_schedule_group_id IS NULL)))
           AND (   (Recinfo.Demand_Source_Type =  X_Demand_Source_Type)
                OR (    (Recinfo.Demand_Source_Type IS NULL)
                    AND (X_Demand_Source_Type IS NULL)))
           AND (   (Recinfo.Demand_Source_Header_Id =  X_Demand_Source_Header_Id)
                OR (    (Recinfo.Demand_Source_Header_Id IS NULL)
                    AND (X_Demand_Source_Header_Id IS NULL)))
           AND (   (Recinfo.Demand_Source_Line =  X_Demand_Source_Line)
                OR (    (Recinfo.Demand_Source_Line IS NULL)
                    AND (X_Demand_Source_Line IS NULL)))
           AND (   (Recinfo.Demand_Source_Delivery =  X_Demand_Source_Delivery)
                OR (    (Recinfo.Demand_Source_Delivery IS NULL)
                    AND (X_Demand_Source_Delivery IS NULL)))
           AND (   (Recinfo.Atp_Check =  X_Atp_Check)
                OR (    (Recinfo.Atp_Check IS NULL)
                    AND (X_Atp_Check IS NULL)))
           AND (   (Recinfo.Action_Code =  X_Action_Code)
                OR (    (Recinfo.Action_Code IS NULL)
                    AND (X_Action_Code IS NULL)))
           AND (   (Recinfo.Validate_Rows =  X_Validate_Rows)
                OR (    (Recinfo.Validate_Rows IS NULL)
                    AND (X_Validate_Rows IS NULL)))
           AND (   (Recinfo.Transaction_Mode =  X_Transaction_Mode)
                OR (    (Recinfo.Transaction_Mode IS NULL)
                    AND (X_Transaction_Mode IS NULL)))
           AND (   (Recinfo.Process_Flag =  X_Process_Flag)
                OR (    (Recinfo.Process_Flag IS NULL)
                    AND (X_Process_Flag IS NULL)))
           AND (   (Recinfo.Single_Lot_Flag =  X_Single_Lot_Flag)
                OR (    (Recinfo.Single_Lot_Flag IS NULL)
                    AND (X_Single_Lot_Flag IS NULL)))
           AND (   (Recinfo.Detail_Reserve_Flag =  X_Detail_Reserve_Flag)
                OR (    (Recinfo.Detail_Reserve_Flag IS NULL)
                    AND (X_Detail_Reserve_Flag IS NULL)))
           AND (   (Recinfo.Reserve_Level =  X_Reserve_Level)
                OR (    (Recinfo.Reserve_Level IS NULL)
                    AND (X_Reserve_Level IS NULL)))
           AND (   (Recinfo.Check_Atr =  X_Check_Atr)
                OR (    (Recinfo.Check_Atr IS NULL)
                    AND (X_Check_Atr IS NULL)))
           AND (   (Recinfo.Error_Code =  X_Error_Code)
                OR (    (Recinfo.Error_Code IS NULL)
                    AND (X_Error_Code IS NULL)))
           AND (   (Recinfo.Err_Explanation =  X_Err_Explanation)
                OR (    (Recinfo.Err_Explanation IS NULL)
                    AND (X_Err_Explanation IS NULL)))
           AND (   (Recinfo.Requirement_Date =  X_Requirement_Date)
                OR (    (Recinfo.Requirement_Date IS NULL)
                    AND (X_Requirement_Date IS NULL)))
           AND (   (Recinfo.Line_Item_Unit_of_Measure =  X_Line_Item_Unit_of_Measure)
                OR (    (Recinfo.Line_Item_Unit_of_Measure IS NULL)
                    AND (X_Line_Item_Unit_of_Measure IS NULL)))
           AND (   (Recinfo.Line_Item_UOM =  X_Line_Item_UOM)
                OR (    (Recinfo.Line_Item_UOM IS NULL)
                    AND (X_Line_Item_UOM IS NULL)))
           AND (Recinfo.Line_Item_Quantity =  X_Line_Item_Quantity)
           AND (   (Recinfo.Line_Item_Reservation_Qty =  X_Line_Item_Reservation_Qty)
                OR (    (Recinfo.Line_Item_Reservation_Qty IS NULL)
                    AND (X_Line_Item_Reservation_Qty IS NULL)))
           AND (   (Recinfo.Primary_UOM =  X_Primary_UOM)
                OR (    (Recinfo.Primary_UOM IS NULL)
                    AND (X_Primary_UOM IS NULL)))
           AND (   (Recinfo.Primary_UOM_Quantity =  X_Primary_UOM_Quantity)
                OR (    (Recinfo.Primary_UOM_Quantity IS NULL)
                    AND (X_Primary_UOM_Quantity IS NULL)))
           AND (   (Recinfo.Reservation_Quantity =  X_Reservation_Quantity)
                OR (    (Recinfo.Reservation_Quantity IS NULL)
                    AND (X_Reservation_Quantity IS NULL)))
           AND (   (Recinfo.ATP_Rule_Id =  X_ATP_Rule_Id)
                OR (    (Recinfo.ATP_Rule_Id IS NULL)
                    AND (X_ATP_Rule_Id IS NULL)))
           AND (   (Recinfo.Organization_Id =  X_Organization_Id)
                OR (    (Recinfo.Organization_Id IS NULL)
                    AND (X_Organization_Id IS NULL)))
           AND (   (Recinfo.Organization_Name =  X_Organization_Name)
                OR (    (Recinfo.Organization_Name IS NULL)
                    AND (X_Organization_Name IS NULL)))
           AND (   (Recinfo.Inventory_Item_Id =  X_Inventory_Item_Id)
                OR (    (Recinfo.Inventory_Item_Id IS NULL)
                    AND (X_Inventory_Item_Id IS NULL)))
	   AND (   (Recinfo.Item_Segment1 =  X_Item_Segment1)
                OR (    (Recinfo.Item_Segment1 IS NULL)
                    AND (X_Item_Segment1 IS NULL)))
           AND (   (Recinfo.Item_Segment2 =  X_Item_Segment2)
                OR (    (Recinfo.Item_Segment2 IS NULL)
                    AND (X_Item_Segment2 IS NULL)))
           AND (   (Recinfo.Item_Segment3 =  X_Item_Segment3)
                OR (    (Recinfo.Item_Segment3 IS NULL)
                    AND (X_Item_Segment3 IS NULL)))
           AND (   (Recinfo.Item_Segment4 =  X_Item_Segment4)
                OR (    (Recinfo.Item_Segment4 IS NULL)
                    AND (X_Item_Segment4 IS NULL)))
           AND (   (Recinfo.Item_Segment5 =  X_Item_Segment5)
                OR (    (Recinfo.Item_Segment5 IS NULL)
                    AND (X_Item_Segment5 IS NULL)))
           AND (   (Recinfo.Item_Segment6 =  X_Item_Segment6)
                OR (    (Recinfo.Item_Segment6 IS NULL)
                    AND (X_Item_Segment6 IS NULL)))
           AND (   (Recinfo.Item_Segment7 =  X_Item_Segment7)
                OR (    (Recinfo.Item_Segment7 IS NULL)
                    AND (X_Item_Segment7 IS NULL)))
           AND (   (Recinfo.Item_Segment8 =  X_Item_Segment8)
                OR (    (Recinfo.Item_Segment8 IS NULL)
                    AND (X_Item_Segment8 IS NULL)))
           AND (   (Recinfo.Item_Segment9 =  X_Item_Segment9)
                OR (    (Recinfo.Item_Segment9 IS NULL)
                    AND (X_Item_Segment9 IS NULL)))
           AND (   (Recinfo.Item_Segment10 =  X_Item_Segment10)
                OR (    (Recinfo.Item_Segment10 IS NULL)
                    AND (X_Item_Segment10 IS NULL)))
           AND (   (Recinfo.Item_Segment11 =  X_Item_Segment11)
                OR (    (Recinfo.Item_Segment11 IS NULL)
                    AND (X_Item_Segment11 IS NULL)))
           AND (   (Recinfo.Item_Segment12 =  X_Item_Segment12)
                OR (    (Recinfo.Item_Segment12 IS NULL)
                    AND (X_Item_Segment12 IS NULL)))
           AND (   (Recinfo.Item_Segment13 =  X_Item_Segment13)
                OR (    (Recinfo.Item_Segment13 IS NULL)
                    AND (X_Item_Segment13 IS NULL)))
           AND (   (Recinfo.Item_Segment14 =  X_Item_Segment14)
                OR (    (Recinfo.Item_Segment14 IS NULL)
                    AND (X_Item_Segment14 IS NULL)))
           AND (   (Recinfo.Item_Segment15 =  X_Item_Segment15)
                OR (    (Recinfo.Item_Segment15 IS NULL)
                    AND (X_Item_Segment15 IS NULL)))
           AND (   (Recinfo.Item_Segment16 =  X_Item_Segment16)
                OR (    (Recinfo.Item_Segment16 IS NULL)
                    AND (X_Item_Segment16 IS NULL)))
           AND (   (Recinfo.Item_Segment17 =  X_Item_Segment17)
                OR (    (Recinfo.Item_Segment17 IS NULL)
                    AND (X_Item_Segment17 IS NULL)))
           AND (   (Recinfo.Item_Segment18 =  X_Item_Segment18)
                OR (    (Recinfo.Item_Segment18 IS NULL)
                    AND (X_Item_Segment18 IS NULL)))
           AND (   (Recinfo.Item_Segment19 =  X_Item_Segment19)
                OR (    (Recinfo.Item_Segment19 IS NULL)
                    AND (X_Item_Segment19 IS NULL)))
           AND (   (Recinfo.Item_Segment20 =  X_Item_Segment20)
                OR (    (Recinfo.Item_Segment20 IS NULL)
                    AND (X_Item_Segment20 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment1 =  X_Demand_Header_Segment1)
                OR (    (Recinfo.Demand_Header_Segment1 IS NULL)
                    AND (X_Demand_Header_Segment1 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment2 =  X_Demand_Header_Segment2)
                OR (    (Recinfo.Demand_Header_Segment2 IS NULL)
                    AND (X_Demand_Header_Segment2 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment3 =  X_Demand_Header_Segment3)
                OR (    (Recinfo.Demand_Header_Segment3 IS NULL)
                    AND (X_Demand_Header_Segment3 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment4 =  X_Demand_Header_Segment4)
                OR (    (Recinfo.Demand_Header_Segment4 IS NULL)
                    AND (X_Demand_Header_Segment4 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment5 =  X_Demand_Header_Segment5)
                OR (    (Recinfo.Demand_Header_Segment5 IS NULL)
                    AND (X_Demand_Header_Segment5 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment6 =  X_Demand_Header_Segment6)
                OR (    (Recinfo.Demand_Header_Segment6 IS NULL)
                    AND (X_Demand_Header_Segment6 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment7 =  X_Demand_Header_Segment7)
                OR (    (Recinfo.Demand_Header_Segment7 IS NULL)
                    AND (X_Demand_Header_Segment7 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment8 =  X_Demand_Header_Segment8)
                OR (    (Recinfo.Demand_Header_Segment8 IS NULL)
                    AND (X_Demand_Header_Segment8 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment9 =  X_Demand_Header_Segment9)
                OR (    (Recinfo.Demand_Header_Segment9 IS NULL)
                    AND (X_Demand_Header_Segment9 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment10 =  X_Demand_Header_Segment10)
                OR (    (Recinfo.Demand_Header_Segment10 IS NULL)
                    AND (X_Demand_Header_Segment10 IS NULL)))
	) then
		RAISE RECORD_CHANGED;
		end if;
	  if not (
               (   (Recinfo.Demand_Header_Segment11 =  X_Demand_Header_Segment11)
                OR (    (Recinfo.Demand_Header_Segment11 IS NULL)
                    AND (X_Demand_Header_Segment11 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment12 =  X_Demand_Header_Segment12)
                OR (    (Recinfo.Demand_Header_Segment12 IS NULL)
                    AND (X_Demand_Header_Segment12 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment13 =  X_Demand_Header_Segment13)
                OR (    (Recinfo.Demand_Header_Segment13 IS NULL)
                    AND (X_Demand_Header_Segment13 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment14 =  X_Demand_Header_Segment14)
                OR (    (Recinfo.Demand_Header_Segment14 IS NULL)
                    AND (X_Demand_Header_Segment14 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment15 =  X_Demand_Header_Segment15)
                OR (    (Recinfo.Demand_Header_Segment15 IS NULL)
                    AND (X_Demand_Header_Segment15 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment16 =  X_Demand_Header_Segment16)
                OR (    (Recinfo.Demand_Header_Segment16 IS NULL)
                    AND (X_Demand_Header_Segment16 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment17 =  X_Demand_Header_Segment17)
                OR (    (Recinfo.Demand_Header_Segment17 IS NULL)
                    AND (X_Demand_Header_Segment17 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment18 =  X_Demand_Header_Segment18)
                OR (    (Recinfo.Demand_Header_Segment18 IS NULL)
                    AND (X_Demand_Header_Segment18 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment19 =  X_Demand_Header_Segment19)
                OR (    (Recinfo.Demand_Header_Segment19 IS NULL)
                    AND (X_Demand_Header_Segment19 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment20 =  X_Demand_Header_Segment20)
                OR (    (Recinfo.Demand_Header_Segment20 IS NULL)
                    AND (X_Demand_Header_Segment20 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment21 =  X_Demand_Header_Segment21)
                OR (    (Recinfo.Demand_Header_Segment21 IS NULL)
                    AND (X_Demand_Header_Segment21 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment22 =  X_Demand_Header_Segment22)
                OR (    (Recinfo.Demand_Header_Segment22 IS NULL)
                    AND (X_Demand_Header_Segment22 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment23 =  X_Demand_Header_Segment23)
                OR (    (Recinfo.Demand_Header_Segment23 IS NULL)
                    AND (X_Demand_Header_Segment23 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment24 =  X_Demand_Header_Segment24)
                OR (    (Recinfo.Demand_Header_Segment24 IS NULL)
                    AND (X_Demand_Header_Segment24 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment25 =  X_Demand_Header_Segment25)
                OR (    (Recinfo.Demand_Header_Segment25 IS NULL)
                    AND (X_Demand_Header_Segment25 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment26 =  X_Demand_Header_Segment26)
                OR (    (Recinfo.Demand_Header_Segment26 IS NULL)
                    AND (X_Demand_Header_Segment26 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment27 =  X_Demand_Header_Segment27)
                OR (    (Recinfo.Demand_Header_Segment27 IS NULL)
                    AND (X_Demand_Header_Segment27 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment28 =  X_Demand_Header_Segment28)
                OR (    (Recinfo.Demand_Header_Segment28 IS NULL)
                    AND (X_Demand_Header_Segment28 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment29 =  X_Demand_Header_Segment29)
                OR (    (Recinfo.Demand_Header_Segment29 IS NULL)
                    AND (X_Demand_Header_Segment29 IS NULL)))
           AND (   (Recinfo.Demand_Header_Segment30 =  X_Demand_Header_Segment30)
                OR (    (Recinfo.Demand_Header_Segment30 IS NULL)
                    AND (X_Demand_Header_Segment30 IS NULL)))
	) then
		RAISE RECORD_CHANGED;
		end if;
	  if not (
               (   (Recinfo.External_Source_Code =  X_External_Source_Code)
                OR (    (Recinfo.External_Source_Code IS NULL)
                    AND (X_External_Source_Code IS NULL)))
           AND (   (Recinfo.External_Source_Line_Id =  X_External_Source_Line_Id)
                OR (    (Recinfo.External_Source_Line_Id IS NULL)
                    AND (X_External_Source_Line_Id IS NULL)))
           AND (   (Recinfo.Supply_Source_Type =  X_Supply_Source_Type)
                OR (    (Recinfo.Supply_Source_Type IS NULL)
                    AND (X_Supply_Source_Type IS NULL)))
           AND (   (Recinfo.Supply_Header_Id =  X_Supply_Header_Id)
                OR (    (Recinfo.Supply_Header_Id IS NULL)
                    AND (X_Supply_Header_Id IS NULL)))
           AND (   (Recinfo.User_Line_Num =  X_User_Line_Num)
                OR (    (Recinfo.User_Line_Num IS NULL)
                    AND (X_User_Line_Num IS NULL)))
           AND (   (Recinfo.User_Delivery =  X_User_Delivery)
                OR (    (Recinfo.User_Delivery IS NULL)
                    AND (X_User_Delivery IS NULL)))
           AND (   (Recinfo.Revision =  X_Revision)
                OR (    (Recinfo.Revision IS NULL)
                    AND (X_Revision IS NULL)))
           AND (   (Recinfo.Lot_Number =  X_Lot_Number)
                OR (    (Recinfo.Lot_Number IS NULL)
                    AND (X_Lot_Number IS NULL)))
           AND (   (Recinfo.Serial_Number =  X_Serial_Number)
                OR (    (Recinfo.Serial_Number IS NULL)
                    AND (X_Serial_Number IS NULL)))
           AND (   (Recinfo.Subinventory =  X_Subinventory)
                OR (    (Recinfo.Subinventory IS NULL)
                    AND (X_Subinventory IS NULL)))
           AND (   (Recinfo.Locator_Id =  X_Locator_Id)
                OR (    (Recinfo.Locator_Id IS NULL)
                    AND (X_Locator_Id IS NULL)))
           AND (   (Recinfo.Loc_Segment1 =  X_Loc_Segment1)
                OR (    (Recinfo.Loc_Segment1 IS NULL)
                    AND (X_Loc_Segment1 IS NULL)))
           AND (   (Recinfo.Loc_Segment2 =  X_Loc_Segment2)
                OR (    (Recinfo.Loc_Segment2 IS NULL)
                    AND (X_Loc_Segment2 IS NULL)))
           AND (   (Recinfo.Loc_Segment3 =  X_Loc_Segment3)
                OR (    (Recinfo.Loc_Segment3 IS NULL)
                    AND (X_Loc_Segment3 IS NULL)))
           AND (   (Recinfo.Loc_Segment4 =  X_Loc_Segment4)
                OR (    (Recinfo.Loc_Segment4 IS NULL)
                    AND (X_Loc_Segment4 IS NULL)))
           AND (   (Recinfo.Loc_Segment5 =  X_Loc_Segment5)
                OR (    (Recinfo.Loc_Segment5 IS NULL)
                    AND (X_Loc_Segment5 IS NULL)))
           AND (   (Recinfo.Loc_Segment6 =  X_Loc_Segment6)
                OR (    (Recinfo.Loc_Segment6 IS NULL)
                    AND (X_Loc_Segment6 IS NULL)))
           AND (   (Recinfo.Loc_Segment7 =  X_Loc_Segment7)
                OR (    (Recinfo.Loc_Segment7 IS NULL)
                    AND (X_Loc_Segment7 IS NULL)))
           AND (   (Recinfo.Loc_Segment8 =  X_Loc_Segment8)
                OR (    (Recinfo.Loc_Segment8 IS NULL)
                    AND (X_Loc_Segment8 IS NULL)))
           AND (   (Recinfo.Loc_Segment9 =  X_Loc_Segment9)
                OR (    (Recinfo.Loc_Segment9 IS NULL)
                    AND (X_Loc_Segment9 IS NULL)))
           AND (   (Recinfo.Loc_Segment10 =  X_Loc_Segment10)
                OR (    (Recinfo.Loc_Segment10 IS NULL)
                    AND (X_Loc_Segment10 IS NULL)))
           AND (   (Recinfo.Loc_Segment11 =  X_Loc_Segment11)
                OR (    (Recinfo.Loc_Segment11 IS NULL)
                    AND (X_Loc_Segment11 IS NULL)))
           AND (   (Recinfo.Loc_Segment12 =  X_Loc_Segment12)
                OR (    (Recinfo.Loc_Segment12 IS NULL)
                    AND (X_Loc_Segment12 IS NULL)))
           AND (   (Recinfo.Loc_Segment13 =  X_Loc_Segment13)
                OR (    (Recinfo.Loc_Segment13 IS NULL)
                    AND (X_Loc_Segment13 IS NULL)))
           AND (   (Recinfo.Loc_Segment14 =  X_Loc_Segment14)
                OR (    (Recinfo.Loc_Segment14 IS NULL)
                    AND (X_Loc_Segment14 IS NULL)))
           AND (   (Recinfo.Loc_Segment15 =  X_Loc_Segment15)
                OR (    (Recinfo.Loc_Segment15 IS NULL)
                    AND (X_Loc_Segment15 IS NULL)))
           AND (   (Recinfo.Loc_Segment16 =  X_Loc_Segment16)
                OR (    (Recinfo.Loc_Segment16 IS NULL)
                    AND (X_Loc_Segment16 IS NULL)))
           AND (   (Recinfo.Loc_Segment17 =  X_Loc_Segment17)
                OR (    (Recinfo.Loc_Segment17 IS NULL)
                    AND (X_Loc_Segment17 IS NULL)))
           AND (   (Recinfo.Loc_Segment18 =  X_Loc_Segment18)
                OR (    (Recinfo.Loc_Segment18 IS NULL)
                    AND (X_Loc_Segment18 IS NULL)))
           AND (   (Recinfo.Loc_Segment19 =  X_Loc_Segment19)
                OR (    (Recinfo.Loc_Segment19 IS NULL)
                    AND (X_Loc_Segment19 IS NULL)))
           AND (   (Recinfo.Loc_Segment20 =  X_Loc_Segment20)
                OR (    (Recinfo.Loc_Segment20 IS NULL)
                    AND (X_Loc_Segment20 IS NULL)))
           AND (   (Recinfo.Autodetail_Group_Id =  X_Autodetail_Group_Id)
                OR (    (Recinfo.Autodetail_Group_Id IS NULL)
                    AND (X_Autodetail_Group_Id IS NULL)))
           AND (   (Recinfo.Component_Sequence_Id =  X_Component_Sequence_Id)
                OR (    (Recinfo.Component_Sequence_Id IS NULL)
                    AND (X_Component_Sequence_Id IS NULL)))
           AND (   (Recinfo.Parent_Component_Seq_Id =  X_Parent_Component_Seq_Id)
                OR (    (Recinfo.Parent_Component_Seq_Id IS NULL)
                    AND (X_Parent_Component_Seq_Id IS NULL)))
           AND (   (Recinfo.RTO_Model_Source_Line =  X_RTO_Model_Source_Line)
                OR (    (Recinfo.RTO_Model_Source_Line IS NULL)
                    AND (X_RTO_Model_Source_Line IS NULL)))
           AND (   (Recinfo.Config_Status =  X_Config_Status)
                OR (    (Recinfo.Config_Status IS NULL)
                    AND (X_Config_Status IS NULL)))
           AND (   (Recinfo.Old_Revision =  X_Old_Revision)
                OR (    (Recinfo.Old_Revision IS NULL)
                    AND (X_Old_Revision IS NULL)))
           AND (   (Recinfo.Old_Lot_Number =  X_Old_Lot_Number)
                OR (    (Recinfo.Old_Lot_Number IS NULL)
                    AND (X_Old_Lot_Number IS NULL)))
           AND (   (Recinfo.Old_Subinventory =  X_Old_Subinventory)
                OR (    (Recinfo.Old_Subinventory IS NULL)
                    AND (X_Old_Subinventory IS NULL)))
           AND (   (Recinfo.Old_Locator_Id =  X_Old_Locator_Id)
                OR (    (Recinfo.Old_Locator_Id IS NULL)
                    AND (X_Old_Locator_Id IS NULL)))
	) then
		RAISE RECORD_CHANGED;
		end if;
	  if not (
               (   (Recinfo.Old_Loc_Segment1 =  X_Old_Loc_Segment1)
                OR (    (Recinfo.Old_Loc_Segment1 IS NULL)
                    AND (X_Old_Loc_Segment1 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment2 =  X_Old_Loc_Segment2)
                OR (    (Recinfo.Old_Loc_Segment2 IS NULL)
                    AND (X_Old_Loc_Segment2 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment3 =  X_Old_Loc_Segment3)
                OR (    (Recinfo.Old_Loc_Segment3 IS NULL)
                    AND (X_Old_Loc_Segment3 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment4 =  X_Old_Loc_Segment4)
                OR (    (Recinfo.Old_Loc_Segment4 IS NULL)
                    AND (X_Old_Loc_Segment4 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment5 =  X_Old_Loc_Segment5)
                OR (    (Recinfo.Old_Loc_Segment5 IS NULL)
                    AND (X_Old_Loc_Segment5 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment6 =  X_Old_Loc_Segment6)
                OR (    (Recinfo.Old_Loc_Segment6 IS NULL)
                    AND (X_Old_Loc_Segment6 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment7 =  X_Old_Loc_Segment7)
                OR (    (Recinfo.Old_Loc_Segment7 IS NULL)
                    AND (X_Old_Loc_Segment7 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment8 =  X_Old_Loc_Segment8)
                OR (    (Recinfo.Old_Loc_Segment8 IS NULL)
                    AND (X_Old_Loc_Segment8 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment9 =  X_Old_Loc_Segment9)
                OR (    (Recinfo.Old_Loc_Segment9 IS NULL)
                    AND (X_Old_Loc_Segment9 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment10 =  X_Old_Loc_Segment10)
                OR (    (Recinfo.Old_Loc_Segment10 IS NULL)
                    AND (X_Old_Loc_Segment10 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment11 =  X_Old_Loc_Segment11)
                OR (    (Recinfo.Old_Loc_Segment11 IS NULL)
                    AND (X_Old_Loc_Segment11 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment12 =  X_Old_Loc_Segment12)
                OR (    (Recinfo.Old_Loc_Segment12 IS NULL)
                    AND (X_Old_Loc_Segment12 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment13 =  X_Old_Loc_Segment13)
                OR (    (Recinfo.Old_Loc_Segment13 IS NULL)
                    AND (X_Old_Loc_Segment13 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment14 =  X_Old_Loc_Segment14)
                OR (    (Recinfo.Old_Loc_Segment14 IS NULL)
                    AND (X_Old_Loc_Segment14 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment15 =  X_Old_Loc_Segment15)
                OR (    (Recinfo.Old_Loc_Segment15 IS NULL)
                    AND (X_Old_Loc_Segment15 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment16 =  X_Old_Loc_Segment16)
                OR (    (Recinfo.Old_Loc_Segment16 IS NULL)
                    AND (X_Old_Loc_Segment16 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment17 =  X_Old_Loc_Segment17)
                OR (    (Recinfo.Old_Loc_Segment17 IS NULL)
                    AND (X_Old_Loc_Segment17 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment18 =  X_Old_Loc_Segment18)
                OR (    (Recinfo.Old_Loc_Segment18 IS NULL)
                    AND (X_Old_Loc_Segment18 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment19 =  X_Old_Loc_Segment19)
                OR (    (Recinfo.Old_Loc_Segment19 IS NULL)
                    AND (X_Old_Loc_Segment19 IS NULL)))
           AND (   (Recinfo.Old_Loc_Segment20 =  X_Old_Loc_Segment20)
                OR (    (Recinfo.Old_Loc_Segment20 IS NULL)
                    AND (X_Old_Loc_Segment20 IS NULL)))
           AND (   (Recinfo.Demand_Class =  X_Demand_Class)
                OR (    (Recinfo.Demand_Class IS NULL)
                    AND (X_Demand_Class IS NULL)))
           AND (   (Recinfo.Customer_Id =  X_Customer_Id)
                OR (    (Recinfo.Customer_Id IS NULL)
                    AND (X_Customer_Id IS NULL)))
           AND (   (Recinfo.Territory_Id =  X_Territory_Id)
                OR (    (Recinfo.Territory_Id IS NULL)
                    AND (X_Territory_Id IS NULL)))
           AND (   (Recinfo.Bill_to_Site_Use_Id =  X_Bill_to_Site_Use_Id)
                OR (    (Recinfo.Bill_to_Site_Use_Id IS NULL)
                    AND (X_Bill_to_Site_Use_Id IS NULL)))
           AND (   (Recinfo.Ship_to_Site_Use_Id =  X_Ship_to_Site_Use_Id)
                OR (    (Recinfo.Ship_to_Site_Use_Id IS NULL)
                    AND (X_Ship_to_Site_Use_Id IS NULL)))
           AND (   (Recinfo.Lot_Expiration_Cutoff_Date =  X_Lot_Expiration_Cutoff_Date)
                OR (    (Recinfo.Lot_Expiration_Cutoff_Date IS NULL)
                    AND (X_Lot_Expiration_Cutoff_Date IS NULL)))
           AND (   (Recinfo.Partials_Allowed_Flag =  X_Partials_Allowed_Flag)
                OR (    (Recinfo.Partials_Allowed_Flag IS NULL)
                    AND (X_Partials_Allowed_Flag IS NULL)))
           AND (   (Recinfo.Request_Date_ATP_Quantity =  X_Request_Date_ATP_Quantity)
                OR (    (Recinfo.Request_Date_ATP_Quantity IS NULL)
                    AND (X_Request_Date_ATP_Quantity IS NULL)))
           AND (   (Recinfo.Earliest_ATP_Date =  X_Earliest_ATP_Date)
                OR (    (Recinfo.Earliest_ATP_Date IS NULL)
                    AND (X_Earliest_ATP_Date IS NULL)))
           AND (   (Recinfo.Earliest_ATP_Date_Quantity =  X_Earliest_ATP_Date_Quantity)
                OR (    (Recinfo.Earliest_ATP_Date_Quantity IS NULL)
                    AND (X_Earliest_ATP_Date_Quantity IS NULL)))
           AND (   (Recinfo.Request_ATP_Date =  X_Request_ATP_Date)
                OR (    (Recinfo.Request_ATP_Date IS NULL)
                    AND (X_Request_ATP_Date IS NULL)))
           AND (   (Recinfo.Request_ATP_Date_Quantity =  X_Request_ATP_Date_Quantity)
                OR (    (Recinfo.Request_ATP_Date_Quantity IS NULL)
                    AND (X_Request_ATP_Date_Quantity IS NULL)))
           AND (   (Recinfo.Group_Available_Date =  X_Group_Available_Date)
                OR (    (Recinfo.Group_Available_Date IS NULL)
                    AND (X_Group_Available_Date IS NULL)))
           AND (   (Recinfo.ATP_Lead_Time =  X_ATP_Lead_Time)
                OR (    (Recinfo.ATP_Lead_Time IS NULL)
                    AND (X_ATP_Lead_Time IS NULL)))
           AND (   (Recinfo.Infinite_Time_Fence_Date =  X_Infinite_Time_Fence_Date)
                OR (    (Recinfo.Infinite_Time_Fence_Date IS NULL)
                    AND (X_Infinite_Time_Fence_Date IS NULL)))
           AND (   (Recinfo.Group_ATP_Check =  X_Group_ATP_Check)
                OR (    (Recinfo.Group_ATP_Check IS NULL)
                    AND (X_Group_ATP_Check IS NULL)))
           AND (   (Recinfo.BOM_Level =  X_BOM_Level)
                OR (    (Recinfo.BOM_Level IS NULL)
                    AND (X_BOM_Level IS NULL)))
           AND (   (Recinfo.Explosion_Effectivity_Date =  X_Explosion_Effectivity_Date)
                OR (    (Recinfo.Explosion_Effectivity_Date IS NULL)
                    AND (X_Explosion_Effectivity_Date IS NULL)))
           AND (   (Recinfo.Attribute_Category =  X_Attribute_Category)
                OR (    (Recinfo.Attribute_Category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
	) then
		RAISE RECORD_CHANGED;
		end if;
	  if not (
               (   (Recinfo.Attribute1 =  X_Attribute1)
                OR (    (Recinfo.Attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.Attribute2 =  X_Attribute2)
                OR (    (Recinfo.Attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.Attribute3 =  X_Attribute3)
                OR (    (Recinfo.Attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.Attribute4 =  X_Attribute4)
                OR (    (Recinfo.Attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.Attribute5 =  X_Attribute5)
                OR (    (Recinfo.Attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.Attribute6 =  X_Attribute6)
                OR (    (Recinfo.Attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.Attribute7 =  X_Attribute7)
                OR (    (Recinfo.Attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.Attribute8 =  X_Attribute8)
                OR (    (Recinfo.Attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.Attribute9 =  X_Attribute9)
                OR (    (Recinfo.Attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.Attribute10 =  X_Attribute10)
                OR (    (Recinfo.Attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.Attribute11 =  X_Attribute11)
                OR (    (Recinfo.Attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.Attribute12 =  X_Attribute12)
                OR (    (Recinfo.Attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.Attribute13 =  X_Attribute13)
                OR (    (Recinfo.Attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.Attribute14 =  X_Attribute14)
                OR (    (Recinfo.Attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.Attribute15 =  X_Attribute15)
                OR (    (Recinfo.Attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.C_Column1 =  X_C_Column1)
                OR (    (Recinfo.C_Column1 IS NULL)
                    AND (X_C_Column1 IS NULL)))
           AND (   (Recinfo.C_Column2 =  X_C_Column2)
                OR (    (Recinfo.C_Column2 IS NULL)
                    AND (X_C_Column2 IS NULL)))
           AND (   (Recinfo.C_Column3 =  X_C_Column3)
                OR (    (Recinfo.C_Column3 IS NULL)
                    AND (X_C_Column3 IS NULL)))
           AND (   (Recinfo.C_Column4 =  X_C_Column4)
                OR (    (Recinfo.C_Column4 IS NULL)
                    AND (X_C_Column4 IS NULL)))
           AND (   (Recinfo.C_Column5 =  X_C_Column5)
                OR (    (Recinfo.C_Column5 IS NULL)
                    AND (X_C_Column5 IS NULL)))
           AND (   (Recinfo.C_Column6 =  X_C_Column6)
                OR (    (Recinfo.C_Column6 IS NULL)
                    AND (X_C_Column6 IS NULL)))
           AND (   (Recinfo.C_Column7 =  X_C_Column7)
                OR (    (Recinfo.C_Column7 IS NULL)
                    AND (X_C_Column7 IS NULL)))
           AND (   (Recinfo.C_Column8 =  X_C_Column8)
                OR (    (Recinfo.C_Column8 IS NULL)
                    AND (X_C_Column8 IS NULL)))
           AND (   (Recinfo.N_Column1 =  X_N_Column1)
                OR (    (Recinfo.N_Column1 IS NULL)
                    AND (X_N_Column2 IS NULL)))
           AND (   (Recinfo.N_Column2 =  X_N_Column2)
                OR (    (Recinfo.N_Column2 IS NULL)
                    AND (X_N_Column3 IS NULL)))
           AND (   (Recinfo.N_Column3 =  X_N_Column3)
                OR (    (Recinfo.N_Column3 IS NULL)
                    AND (X_N_Column3 IS NULL)))
           AND (   (Recinfo.N_Column4 =  X_N_Column4)
                OR (    (Recinfo.N_Column4 IS NULL)
                    AND (X_N_Column4 IS NULL)))
           AND (   (Recinfo.N_Column5 =  X_N_Column5)
                OR (    (Recinfo.N_Column5 IS NULL)
                    AND (X_N_Column5 IS NULL)))
           AND (   (Recinfo.D_Column1 =  X_D_Column1)
                OR (    (Recinfo.D_Column1 IS NULL)
                    AND (X_D_Column2 IS NULL)))
           AND (   (Recinfo.D_Column2 =  X_D_Column2)
                OR (    (Recinfo.D_Column2 IS NULL)
                    AND (X_D_Column3 IS NULL)))
           AND (   (Recinfo.D_Column3 =  X_D_Column3)
                OR (    (Recinfo.D_Column3 IS NULL)
                    AND (X_D_Column3 IS NULL)))
           AND (   (Recinfo.D_Column4 =  X_D_Column4)
                OR (    (Recinfo.D_Column4 IS NULL)
                    AND (X_D_Column4 IS NULL)))
           AND (   (Recinfo.D_Column5 =  X_D_Column5)
                OR (    (Recinfo.D_Column5 IS NULL)
                    AND (X_D_Column5 IS NULL)))
           AND (   (Recinfo.Transaction_Process_Order =  X_Transaction_Process_Order)
                OR (    (Recinfo.Transaction_Process_Order IS NULL)
                    AND (X_Transaction_Process_Order IS NULL)))
           AND (   (Recinfo.Demand_Id =  X_Demand_Id)
                OR (    (Recinfo.Demand_Id IS NULL)
                    AND (X_Demand_Id IS NULL)))
           AND (   (Recinfo.Demand_Source_Name =  X_Demand_Source_Name)
                OR (    (Recinfo.Demand_Source_Name IS NULL)
                    AND (X_Demand_Source_Name IS NULL)))
           AND (   (Recinfo.Demand_Type =  X_Demand_Type)
                OR (    (Recinfo.Demand_Type IS NULL)
                    AND (X_Demand_Type IS NULL)))
           AND (   (Recinfo.Available_to_Reserve =  X_Available_to_Reserve)
                OR (    (Recinfo.Available_to_Reserve IS NULL)
                    AND (X_Available_to_Reserve IS NULL)))
           AND (   (Recinfo.Quantity_on_Hand =  X_Quantity_on_Hand)
                OR (    (Recinfo.Quantity_on_Hand IS NULL)
                    AND (X_Quantity_on_Hand IS NULL)))
           AND (   (Recinfo.ATP_Components_Flag =  X_ATP_Components_Flag)
                OR (    (Recinfo.ATP_Components_Flag IS NULL)
                    AND (X_ATP_Components_Flag IS NULL)))
           AND (   (Recinfo.ATP_Calendar_Organization_Id =  X_ATP_Calendar_Organization_Id)
                OR (    (Recinfo.ATP_Calendar_Organization_Id IS NULL)
                    AND (X_ATP_Calendar_Organization_Id IS NULL)))
           AND (   (Recinfo.Autodetail_Expense_Subinv_Flag =  X_Autodetail_Expense_Subinv)
                OR (    (Recinfo.Autodetail_Expense_Subinv_Flag IS NULL)
                    AND (X_Autodetail_Expense_Subinv IS NULL)))
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


  PROCEDURE Update_Row( X_ROWID 				   VARCHAR2,
			X_SCHEDULE_GROUP_ID                        NUMBER,
 			X_DEMAND_SOURCE_TYPE                       NUMBER,
 			X_DEMAND_SOURCE_HEADER_ID                  NUMBER,
 			X_DEMAND_SOURCE_LINE                       VARCHAR2,
 			X_DEMAND_SOURCE_DELIVERY                   VARCHAR2,
 			X_ATP_CHECK                                NUMBER,
	 		X_ACTION_CODE                              NUMBER,
 			X_VALIDATE_ROWS                            NUMBER,
 			X_TRANSACTION_MODE                         NUMBER,
 			X_PROCESS_FLAG                             NUMBER,
	 		X_SINGLE_LOT_FLAG                          NUMBER,
 			X_DETAIL_RESERVE_FLAG                      NUMBER,
 			X_RESERVE_LEVEL                            NUMBER,
 			X_CHECK_ATR                                NUMBER,
 			X_LAST_UPDATE_DATE                 	   DATE,
 			X_LAST_UPDATED_BY                 	   NUMBER,
 			X_LAST_UPDATE_LOGIN                        NUMBER,
 			X_ERROR_CODE                               NUMBER,
 			X_ERR_EXPLANATION                          VARCHAR2,
 			X_REQUIREMENT_DATE                         DATE,
 			X_LINE_ITEM_UNIT_OF_MEASURE                VARCHAR2,
 			X_LINE_ITEM_UOM                            VARCHAR2,
 			X_LINE_ITEM_QUANTITY              	 NUMBER,
 			X_LINE_ITEM_RESERVATION_QTY                NUMBER,
 			X_PRIMARY_UOM                              VARCHAR2,
 			X_PRIMARY_UOM_QUANTITY                     NUMBER,
 			X_RESERVATION_QUANTITY                     NUMBER,
 			X_ATP_RULE_ID                              NUMBER,
 			X_ORGANIZATION_ID                          NUMBER,
 			X_ORGANIZATION_NAME                        VARCHAR2,
 			X_INVENTORY_ITEM_ID                        NUMBER,
 			X_ITEM_SEGMENT1                            VARCHAR2,
 			X_ITEM_SEGMENT2                            VARCHAR2,
 			X_ITEM_SEGMENT3                            VARCHAR2,
 			X_ITEM_SEGMENT4                            VARCHAR2,
 			X_ITEM_SEGMENT5                            VARCHAR2,
 			X_ITEM_SEGMENT6                            VARCHAR2,
 			X_ITEM_SEGMENT7                            VARCHAR2,
 			X_ITEM_SEGMENT8                            VARCHAR2,
 			X_ITEM_SEGMENT9                            VARCHAR2,
 			X_ITEM_SEGMENT10                           VARCHAR2,
 			X_ITEM_SEGMENT11                           VARCHAR2,
 			X_ITEM_SEGMENT12                           VARCHAR2,
 			X_ITEM_SEGMENT13                           VARCHAR2,
 			X_ITEM_SEGMENT14                           VARCHAR2,
 			X_ITEM_SEGMENT15                           VARCHAR2,
 			X_ITEM_SEGMENT16                           VARCHAR2,
 			X_ITEM_SEGMENT17                           VARCHAR2,
 			X_ITEM_SEGMENT18                           VARCHAR2,
 			X_ITEM_SEGMENT19                           VARCHAR2,
 			X_ITEM_SEGMENT20                           VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT1                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT2                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT3                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT4                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT5                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT6                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT7                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT8                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT9                   VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT10                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT11                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT12                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT13                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT14                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT15                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT16                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT17                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT18                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT19                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT20                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT21                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT22                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT23                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT24                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT25                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT26                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT27                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT28                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT29                  VARCHAR2,
 			X_DEMAND_HEADER_SEGMENT30                  VARCHAR2,
 			X_EXTERNAL_SOURCE_CODE                     VARCHAR2,
 			X_EXTERNAL_SOURCE_LINE_ID                  NUMBER,
 			X_SUPPLY_SOURCE_TYPE                       NUMBER,
 			X_SUPPLY_HEADER_ID                         NUMBER,
 			X_USER_LINE_NUM                            VARCHAR2,
 			X_USER_DELIVERY                            VARCHAR2,
 			X_REVISION                                 VARCHAR2,
 			X_LOT_NUMBER                               VARCHAR2,
 			X_SERIAL_NUMBER                            VARCHAR2,
 			X_SUBINVENTORY                             VARCHAR2,
 			X_LOCATOR_ID                               NUMBER,
 			X_LOC_SEGMENT1                             VARCHAR2,
 			X_LOC_SEGMENT2                             VARCHAR2,
 			X_LOC_SEGMENT3                             VARCHAR2,
 			X_LOC_SEGMENT4                             VARCHAR2,
 			X_LOC_SEGMENT5                             VARCHAR2,
 			X_LOC_SEGMENT6                             VARCHAR2,
 			X_LOC_SEGMENT7                             VARCHAR2,
 			X_LOC_SEGMENT8                             VARCHAR2,
 			X_LOC_SEGMENT9                             VARCHAR2,
 			X_LOC_SEGMENT10                            VARCHAR2,
 			X_LOC_SEGMENT11                            VARCHAR2,
 			X_LOC_SEGMENT12                            VARCHAR2,
 			X_LOC_SEGMENT13                            VARCHAR2,
 			X_LOC_SEGMENT14                            VARCHAR2,
 			X_LOC_SEGMENT15                            VARCHAR2,
 			X_LOC_SEGMENT16                            VARCHAR2,
 			X_LOC_SEGMENT17                            VARCHAR2,
 			X_LOC_SEGMENT18                            VARCHAR2,
 			X_LOC_SEGMENT19                            VARCHAR2,
 			X_LOC_SEGMENT20                            VARCHAR2,
 			X_AUTODETAIL_GROUP_ID                      NUMBER,
 			X_COMPONENT_SEQUENCE_ID                    NUMBER,
 			X_PARENT_COMPONENT_SEQ_ID                  NUMBER,
 			X_RTO_MODEL_SOURCE_LINE                    VARCHAR2,
 			X_CONFIG_STATUS                            NUMBER,
 			X_OLD_REVISION                             VARCHAR2,
 			X_OLD_LOT_NUMBER                           VARCHAR2,
 			X_OLD_SUBINVENTORY                         VARCHAR2,
 			X_OLD_LOCATOR_ID                           NUMBER,
 			X_OLD_LOC_SEGMENT1                         VARCHAR2,
 			X_OLD_LOC_SEGMENT2                         VARCHAR2,
 			X_OLD_LOC_SEGMENT3                         VARCHAR2,
 			X_OLD_LOC_SEGMENT4                         VARCHAR2,
 			X_OLD_LOC_SEGMENT5                         VARCHAR2,
 			X_OLD_LOC_SEGMENT6                         VARCHAR2,
 			X_OLD_LOC_SEGMENT7                         VARCHAR2,
 			X_OLD_LOC_SEGMENT8                         VARCHAR2,
 			X_OLD_LOC_SEGMENT9                         VARCHAR2,
 			X_OLD_LOC_SEGMENT10                        VARCHAR2,
 			X_OLD_LOC_SEGMENT11                        VARCHAR2,
 			X_OLD_LOC_SEGMENT12                        VARCHAR2,
 			X_OLD_LOC_SEGMENT13                        VARCHAR2,
 			X_OLD_LOC_SEGMENT14                        VARCHAR2,
 			X_OLD_LOC_SEGMENT15                        VARCHAR2,
 			X_OLD_LOC_SEGMENT16                        VARCHAR2,
 			X_OLD_LOC_SEGMENT17                        VARCHAR2,
 			X_OLD_LOC_SEGMENT18                        VARCHAR2,
 			X_OLD_LOC_SEGMENT19                        VARCHAR2,
 			X_OLD_LOC_SEGMENT20                        VARCHAR2,
 			X_DEMAND_CLASS                             VARCHAR2,
 			X_CUSTOMER_ID                              NUMBER,
 			X_TERRITORY_ID                             NUMBER,
 			X_BILL_TO_SITE_USE_ID                      NUMBER,
 			X_SHIP_TO_SITE_USE_ID                      NUMBER,
 			X_LOT_EXPIRATION_CUTOFF_DATE               DATE,
 			X_PARTIALS_ALLOWED_FLAG                    NUMBER,
 			X_REQUEST_DATE_ATP_QUANTITY                NUMBER,
 			X_EARLIEST_ATP_DATE                        DATE,
 			X_EARLIEST_ATP_DATE_QUANTITY               NUMBER,
 			X_REQUEST_ATP_DATE                         DATE,
 			X_REQUEST_ATP_DATE_QUANTITY                NUMBER,
 			X_GROUP_AVAILABLE_DATE                     DATE,
 			X_ATP_LEAD_TIME                            NUMBER,
 			X_INFINITE_TIME_FENCE_DATE                 DATE,
 			X_GROUP_ATP_CHECK                          NUMBER,
 			X_BOM_LEVEL                                NUMBER,
 			X_EXPLOSION_EFFECTIVITY_DATE               DATE,
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
 			X_C_COLUMN1                                VARCHAR2,
 			X_C_COLUMN2                                VARCHAR2,
 			X_C_COLUMN3                                VARCHAR2,
 			X_C_COLUMN4                                VARCHAR2,
 			X_C_COLUMN5                                VARCHAR2,
 			X_C_COLUMN6                                VARCHAR2,
 			X_C_COLUMN7                                VARCHAR2,
 			X_C_COLUMN8                                VARCHAR2,
 			X_N_COLUMN1                                NUMBER,
 			X_N_COLUMN2                                NUMBER,
 			X_N_COLUMN3                                NUMBER,
 			X_N_COLUMN4                                NUMBER,
 			X_N_COLUMN5                                NUMBER,
 			X_D_COLUMN1                                DATE,
 			X_D_COLUMN2                                DATE,
 			X_D_COLUMN3                                DATE,
 			X_D_COLUMN4                                DATE,
 			X_D_COLUMN5                                DATE,
 			X_TRANSACTION_PROCESS_ORDER                NUMBER,
 			X_DEMAND_ID                                NUMBER,
 			X_DEMAND_SOURCE_NAME                       VARCHAR2,
 			X_DEMAND_TYPE                              NUMBER,
 			X_AVAILABLE_TO_RESERVE                     NUMBER,
 			X_QUANTITY_ON_HAND                         NUMBER,
 			X_ATP_COMPONENTS_FLAG                      NUMBER,
 			X_ATP_CALENDAR_ORGANIZATION_ID             NUMBER,
 			X_AUTODETAIL_EXPENSE_SUBINV                NUMBER

  ) IS
  BEGIN
    UPDATE mtl_demand_interface
    SET
			SCHEDULE_GROUP_ID         	= X_Schedule_Group_Id,
 			DEMAND_SOURCE_TYPE  		= X_DEMAND_SOURCE_TYPE,
 			DEMAND_SOURCE_HEADER_ID 	= X_DEMAND_SOURCE_HEADER_ID,
 			DEMAND_SOURCE_LINE 		= X_DEMAND_SOURCE_LINE,
 			DEMAND_SOURCE_DELIVERY		= X_DEMAND_SOURCE_DELIVERY,
 			ATP_CHECK			= X_ATP_CHECK,
	 		ACTION_CODE                 	= X_ACTION_CODE,
			VALIDATE_ROWS  			= X_VALIDATE_ROWS,
 			TRANSACTION_MODE  		= X_TRANSACTION_MODE,
 			PROCESS_FLAG  			= X_PROCESS_FLAG,
	 		SINGLE_LOT_FLAG  		= X_SINGLE_LOT_FLAG,
 			DETAIL_RESERVE_FLAG 		= X_DETAIL_RESERVE_FLAG,
 			RESERVE_LEVEL 			= X_RESERVE_LEVEL,
 			CHECK_ATR   			= X_CHECK_ATR,
 			LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
 			LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN,
 			ERROR_CODE    			= X_ERROR_CODE,
 			ERR_EXPLANATION    		= X_ERR_EXPLANATION,
 			REQUIREMENT_DATE		= X_REQUIREMENT_DATE,
 			LINE_ITEM_UNIT_OF_MEASURE	= X_LINE_ITEM_UNIT_OF_MEASURE,
 			LINE_ITEM_UOM 			= X_LINE_ITEM_UOM,
 			LINE_ITEM_QUANTITY 		= X_LINE_ITEM_QUANTITY,
 			LINE_ITEM_RESERVATION_QTY	= X_LINE_ITEM_RESERVATION_QTY,
 			PRIMARY_UOM 			= X_PRIMARY_UOM,
 			PRIMARY_UOM_QUANTITY		= X_PRIMARY_UOM_QUANTITY,
 			RESERVATION_QUANTITY 		= X_RESERVATION_QUANTITY,
 			ATP_RULE_ID  			= X_ATP_RULE_ID,
 			ORGANIZATION_ID  		= X_ORGANIZATION_ID,
 			ORGANIZATION_NAME 		= X_ORGANIZATION_NAME,
 			INVENTORY_ITEM_ID 		= X_INVENTORY_ITEM_ID,
 			ITEM_SEGMENT1			= X_ITEM_SEGMENT1,
 			ITEM_SEGMENT2 			= X_ITEM_SEGMENT2,
 			ITEM_SEGMENT3 			= X_ITEM_SEGMENT3,
 			ITEM_SEGMENT4 			= X_ITEM_SEGMENT4,
 			ITEM_SEGMENT5 			= X_ITEM_SEGMENT5,
 			ITEM_SEGMENT6 			= X_ITEM_SEGMENT6,
 			ITEM_SEGMENT7   		= X_ITEM_SEGMENT7,
 			ITEM_SEGMENT8			= X_ITEM_SEGMENT8,
 			ITEM_SEGMENT9			= X_ITEM_SEGMENT9,
 			ITEM_SEGMENT10			= X_ITEM_SEGMENT10,
 			ITEM_SEGMENT11			= X_ITEM_SEGMENT11,
 			ITEM_SEGMENT12			= X_ITEM_SEGMENT12,
 			ITEM_SEGMENT13			= X_ITEM_SEGMENT13,
 			ITEM_SEGMENT14			= X_ITEM_SEGMENT14,
 			ITEM_SEGMENT15			= X_ITEM_SEGMENT15,
 			ITEM_SEGMENT16			= X_ITEM_SEGMENT16,
 			ITEM_SEGMENT17			= X_ITEM_SEGMENT17,
 			ITEM_SEGMENT18			= X_ITEM_SEGMENT18,
 			ITEM_SEGMENT19			= X_ITEM_SEGMENT19,
 			ITEM_SEGMENT20			= X_ITEM_SEGMENT20,
 			DEMAND_HEADER_SEGMENT1 		= X_DEMAND_HEADER_SEGMENT1,
 			DEMAND_HEADER_SEGMENT2 		= X_DEMAND_HEADER_SEGMENT2,
 			DEMAND_HEADER_SEGMENT3 		= X_DEMAND_HEADER_SEGMENT3,
 			DEMAND_HEADER_SEGMENT4 		= X_DEMAND_HEADER_SEGMENT4,
 			DEMAND_HEADER_SEGMENT5 		= X_DEMAND_HEADER_SEGMENT5,
 			DEMAND_HEADER_SEGMENT6 		= X_DEMAND_HEADER_SEGMENT6,
 			DEMAND_HEADER_SEGMENT7 		= X_DEMAND_HEADER_SEGMENT7,
 			DEMAND_HEADER_SEGMENT8 		= X_DEMAND_HEADER_SEGMENT8,
 			DEMAND_HEADER_SEGMENT9 		= X_DEMAND_HEADER_SEGMENT9,
 			DEMAND_HEADER_SEGMENT10 	= X_DEMAND_HEADER_SEGMENT10,
 			DEMAND_HEADER_SEGMENT11 	= X_DEMAND_HEADER_SEGMENT11,
 			DEMAND_HEADER_SEGMENT12 	= X_DEMAND_HEADER_SEGMENT12,
 			DEMAND_HEADER_SEGMENT13 	= X_DEMAND_HEADER_SEGMENT13,
 			DEMAND_HEADER_SEGMENT14 	= X_DEMAND_HEADER_SEGMENT14,
 			DEMAND_HEADER_SEGMENT15 	= X_DEMAND_HEADER_SEGMENT15,
 			DEMAND_HEADER_SEGMENT16 	= X_DEMAND_HEADER_SEGMENT16,
 			DEMAND_HEADER_SEGMENT17 	= X_DEMAND_HEADER_SEGMENT17,
 			DEMAND_HEADER_SEGMENT18 	= X_DEMAND_HEADER_SEGMENT18,
 			DEMAND_HEADER_SEGMENT19 	= X_DEMAND_HEADER_SEGMENT19,
 			DEMAND_HEADER_SEGMENT20 	= X_DEMAND_HEADER_SEGMENT20,
 			DEMAND_HEADER_SEGMENT21 	= X_DEMAND_HEADER_SEGMENT21,
 			DEMAND_HEADER_SEGMENT22 	= X_DEMAND_HEADER_SEGMENT22,
 			DEMAND_HEADER_SEGMENT23 	= X_DEMAND_HEADER_SEGMENT23,
 			DEMAND_HEADER_SEGMENT24 	= X_DEMAND_HEADER_SEGMENT24,
 			DEMAND_HEADER_SEGMENT25 	= X_DEMAND_HEADER_SEGMENT25,
 			DEMAND_HEADER_SEGMENT26 	= X_DEMAND_HEADER_SEGMENT26,
 			DEMAND_HEADER_SEGMENT27 	= X_DEMAND_HEADER_SEGMENT27,
 			DEMAND_HEADER_SEGMENT28 	= X_DEMAND_HEADER_SEGMENT28,
 			DEMAND_HEADER_SEGMENT29 	= X_DEMAND_HEADER_SEGMENT29,
 			DEMAND_HEADER_SEGMENT30 	= X_DEMAND_HEADER_SEGMENT30,
 			EXTERNAL_SOURCE_CODE 		= X_EXTERNAL_SOURCE_CODE,
 			EXTERNAL_SOURCE_LINE_ID  	= X_EXTERNAL_SOURCE_LINE_ID ,
 			SUPPLY_SOURCE_TYPE		= X_SUPPLY_SOURCE_TYPE,
 			SUPPLY_HEADER_ID		= X_SUPPLY_HEADER_ID,
 			USER_LINE_NUM			= X_USER_LINE_NUM,
 			USER_DELIVERY			= X_USER_DELIVERY,
 			REVISION			= X_REVISION,
 			LOT_NUMBER			= X_LOT_NUMBER,
 			SERIAL_NUMBER			= X_SERIAL_NUMBER,
 			SUBINVENTORY			= X_SUBINVENTORY,
 			LOCATOR_ID			= X_LOCATOR_ID,
 			LOC_SEGMENT1			= X_LOC_SEGMENT1,
 			LOC_SEGMENT2			= X_LOC_SEGMENT2,
 			LOC_SEGMENT3			= X_LOC_SEGMENT3,
 			LOC_SEGMENT4			= X_LOC_SEGMENT4,
 			LOC_SEGMENT5			= X_LOC_SEGMENT5,
 			LOC_SEGMENT6			= X_LOC_SEGMENT6,
 			LOC_SEGMENT7			= X_LOC_SEGMENT7,
 			LOC_SEGMENT8			= X_LOC_SEGMENT8,
 			LOC_SEGMENT9			= X_LOC_SEGMENT9,
 			LOC_SEGMENT10			= X_LOC_SEGMENT10,
 			LOC_SEGMENT11			= X_LOC_SEGMENT11,
 			LOC_SEGMENT12			= X_LOC_SEGMENT12,
 			LOC_SEGMENT13			= X_LOC_SEGMENT13,
 			LOC_SEGMENT14			= X_LOC_SEGMENT14,
 			LOC_SEGMENT15			= X_LOC_SEGMENT15,
 			LOC_SEGMENT16			= X_LOC_SEGMENT16,
 			LOC_SEGMENT17			= X_LOC_SEGMENT17,
 			LOC_SEGMENT18			= X_LOC_SEGMENT18,
 			LOC_SEGMENT19			= X_LOC_SEGMENT19,
 			LOC_SEGMENT20			= X_LOC_SEGMENT20,
 			AUTODETAIL_GROUP_ID		= X_AUTODETAIL_GROUP_ID,
 			COMPONENT_SEQUENCE_ID           = X_COMPONENT_SEQUENCE_ID,
 			PARENT_COMPONENT_SEQ_ID         = X_PARENT_COMPONENT_SEQ_ID,
 			RTO_MODEL_SOURCE_LINE		= X_RTO_MODEL_SOURCE_LINE,
 			CONFIG_STATUS                   = X_CONFIG_STATUS,
 			OLD_REVISION			= X_OLD_REVISION,
 			OLD_LOT_NUMBER			= X_OLD_LOT_NUMBER,
 			OLD_SUBINVENTORY		= X_OLD_SUBINVENTORY,
 			OLD_LOCATOR_ID			= X_OLD_LOCATOR_ID,
 			OLD_LOC_SEGMENT1		= X_OLD_LOC_SEGMENT1,
 			OLD_LOC_SEGMENT2		= X_OLD_LOC_SEGMENT2,
 			OLD_LOC_SEGMENT3		= X_OLD_LOC_SEGMENT3,
 			OLD_LOC_SEGMENT4		= X_OLD_LOC_SEGMENT4,
 			OLD_LOC_SEGMENT5		= X_OLD_LOC_SEGMENT5,
 			OLD_LOC_SEGMENT6		= X_OLD_LOC_SEGMENT6,
 			OLD_LOC_SEGMENT7		= X_OLD_LOC_SEGMENT7,
 			OLD_LOC_SEGMENT8		= X_OLD_LOC_SEGMENT8,
 			OLD_LOC_SEGMENT9		= X_OLD_LOC_SEGMENT9,
 			OLD_LOC_SEGMENT10		= X_OLD_LOC_SEGMENT10,
 			OLD_LOC_SEGMENT11		= X_OLD_LOC_SEGMENT11,
 			OLD_LOC_SEGMENT12		= X_OLD_LOC_SEGMENT12,
 			OLD_LOC_SEGMENT13		= X_OLD_LOC_SEGMENT13,
 			OLD_LOC_SEGMENT14		= X_OLD_LOC_SEGMENT14,
 			OLD_LOC_SEGMENT15		= X_OLD_LOC_SEGMENT15,
 			OLD_LOC_SEGMENT16		= X_OLD_LOC_SEGMENT16,
 			OLD_LOC_SEGMENT17               = X_OLD_LOC_SEGMENT17,
 			OLD_LOC_SEGMENT18               = X_OLD_LOC_SEGMENT18,
 			OLD_LOC_SEGMENT19               = X_OLD_LOC_SEGMENT19,
 			OLD_LOC_SEGMENT20               = X_OLD_LOC_SEGMENT20,
 			DEMAND_CLASS                    = X_DEMAND_CLASS,
 			CUSTOMER_ID                     = X_CUSTOMER_ID,
 			TERRITORY_ID                    = X_TERRITORY_ID,
 			BILL_TO_SITE_USE_ID 		= X_BILL_TO_SITE_USE_ID,
 			SHIP_TO_SITE_USE_ID		= X_SHIP_TO_SITE_USE_ID,
 			LOT_EXPIRATION_CUTOFF_DATE 	= X_LOT_EXPIRATION_CUTOFF_DATE,
 			PARTIALS_ALLOWED_FLAG 		= X_PARTIALS_ALLOWED_FLAG,
 			REQUEST_DATE_ATP_QUANTITY  	= X_REQUEST_DATE_ATP_QUANTITY ,
 			EARLIEST_ATP_DATE 		= X_EARLIEST_ATP_DATE,
 			EARLIEST_ATP_DATE_QUANTITY  	= X_EARLIEST_ATP_DATE_QUANTITY ,
 			REQUEST_ATP_DATE 		= X_REQUEST_ATP_DATE,
 			REQUEST_ATP_DATE_QUANTITY 	= X_REQUEST_ATP_DATE_QUANTITY,
 			GROUP_AVAILABLE_DATE 		= X_GROUP_AVAILABLE_DATE,
 			ATP_LEAD_TIME 			= X_ATP_LEAD_TIME,
 			INFINITE_TIME_FENCE_DATE 	= X_INFINITE_TIME_FENCE_DATE,
 			GROUP_ATP_CHECK 		= X_GROUP_ATP_CHECK,
 			BOM_LEVEL			= X_BOM_LEVEL,
			EXPLOSION_EFFECTIVITY_DATE  	= X_EXPLOSION_EFFECTIVITY_DATE ,
 			ATTRIBUTE_CATEGORY 		= X_ATTRIBUTE_CATEGORY,
 			ATTRIBUTE1 			= X_ATTRIBUTE1,
 			ATTRIBUTE2  			= X_ATTRIBUTE2,
 			ATTRIBUTE3 			= X_ATTRIBUTE3,
 			ATTRIBUTE4 			= X_ATTRIBUTE4,
 			ATTRIBUTE5 			= X_ATTRIBUTE5,
 			ATTRIBUTE6 			= X_ATTRIBUTE6,
 			ATTRIBUTE7 			= X_ATTRIBUTE7,
 			ATTRIBUTE8 			= X_ATTRIBUTE8,
 			ATTRIBUTE9 			= X_ATTRIBUTE9,
 			ATTRIBUTE10  			= X_ATTRIBUTE10,
 			ATTRIBUTE11 			= X_ATTRIBUTE11,
 			ATTRIBUTE12 			= X_ATTRIBUTE12,
 			ATTRIBUTE13 			= X_ATTRIBUTE13,
 			ATTRIBUTE14 			= X_ATTRIBUTE14,
 			ATTRIBUTE15 			= X_ATTRIBUTE15,
 			C_COLUMN1 			= X_C_COLUMN1,
 			C_COLUMN2 			= X_C_COLUMN2,
 			C_COLUMN3  			= X_C_COLUMN3,
 			C_COLUMN4 			= X_C_COLUMN4,
 			C_COLUMN5 			= X_C_COLUMN5,
 			C_COLUMN6 			= X_C_COLUMN6,
 			C_COLUMN7 			= X_C_COLUMN7,
 			C_COLUMN8 			= X_C_COLUMN8,
 			N_COLUMN1 			= X_N_COLUMN1,
 			N_COLUMN2 			= X_N_COLUMN2,
 			N_COLUMN3 			= X_N_COLUMN3,
 			N_COLUMN4 			= X_N_COLUMN4,
 			N_COLUMN5 			= X_N_COLUMN5,
 			D_COLUMN1  			= X_D_COLUMN1 ,
 			D_COLUMN2 			= X_D_COLUMN2,
 			D_COLUMN3 			= X_D_COLUMN3,
 			D_COLUMN4 			= X_D_COLUMN4,
 			D_COLUMN5 			= X_D_COLUMN5,
 			TRANSACTION_PROCESS_ORDER 	= X_TRANSACTION_PROCESS_ORDER,
 			DEMAND_ID 			= X_DEMAND_ID,
 			DEMAND_SOURCE_NAME 		= X_DEMAND_SOURCE_NAME,
 			DEMAND_TYPE 			= X_DEMAND_TYPE,
 			AVAILABLE_TO_RESERVE 		= X_AVAILABLE_TO_RESERVE,
 			QUANTITY_ON_HAND 		= X_QUANTITY_ON_HAND,
 			ATP_COMPONENTS_FLAG 		= X_ATP_COMPONENTS_FLAG,
 			ATP_CALENDAR_ORGANIZATION_ID 	= X_ATP_CALENDAR_ORGANIZATION_ID,
 			AUTODETAIL_EXPENSE_SUBINV_FLAG	= X_AUTODETAIL_EXPENSE_SUBINV
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

END MTL_DEMAND_INTERFACE_PKG;

/
