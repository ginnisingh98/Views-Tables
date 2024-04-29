--------------------------------------------------------
--  DDL for Package Body B_STD_OP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."B_STD_OP_PKG" as
/* $Header: BOMPISOB.pls 120.3.12010000.3 2008/11/13 10:05:41 sisankar ship $ */

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Standard_Operation_Id        IN OUT NOCOPY NUMBER,
                     X_Operation_Code                      VARCHAR2,
	  	                 X_Operation_Type                      NUMBER,
		                   X_Line_Id	                   	        NUMBER DEFAULT NULL,
 	 	                 X_Sequence_Num			                     NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER,
                     X_Department_Id                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Minimum_Transfer_Quantity           NUMBER DEFAULT NULL,
                     X_Count_Point_Type                    NUMBER DEFAULT NULL,
                     X_Operation_Description               VARCHAR2 DEFAULT NULL,
                     X_Option_Dependent_Flag               NUMBER DEFAULT NULL,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL,
                     X_Backflush_Flag                      NUMBER DEFAULT NULL,
                     X_Wms_Task_Type                       NUMBER DEFAULT NULL,
                     X_Yield                               NUMBER DEFAULT NULL,
                     X_Operation_Yield_Enabled             NUMBER DEFAULT NULL,
                     X_Shutdown_Type                       VARCHAR2 DEFAULT NULL

 ) IS
   CURSOR C IS SELECT rowid FROM BOM_STANDARD_OPERATIONS
             WHERE standard_operation_id = X_Standard_Operation_Id;
   CURSOR C2 IS SELECT bom_standard_operations_s.nextval FROM sys.dual;
BEGIN
   if (X_Standard_Operation_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Standard_Operation_Id;
     CLOSE C2;
   end if;
   INSERT INTO BOM_STANDARD_OPERATIONS(
          standard_operation_id,
          operation_code,
          operation_type,
          line_id,
          sequence_num,
          organization_id,
          department_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          minimum_transfer_quantity,
          count_point_type,
          operation_description,
          option_dependent_flag,
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
          backflush_flag,
										wms_task_type,
										yield,
										operation_yield_enabled,
          shutdown_type
         ) VALUES (
	         X_Standard_Operation_Id,
          X_Operation_Code,
	         X_Operation_Type,
          X_Line_Id,
 	        X_Sequence_Num,
          X_Organization_Id,
          X_Department_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Minimum_Transfer_Quantity,
          X_Count_Point_Type,
          X_Operation_Description,
          X_Option_Dependent_Flag,
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
          X_Backflush_Flag,
										X_Wms_Task_Type,
										X_Yield,
										X_Operation_Yield_Enabled,
          X_Shutdown_Type
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Standard_Operation_Id        IN OUT NOCOPY NUMBER,
                     X_Operation_Code                      VARCHAR2,
																					X_Operation_Type                      NUMBER,
																			  X_Line_Id                   	         NUMBER DEFAULT NULL,
																					X_Sequence_Num			                     NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER,
                     X_Department_Id                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Minimum_Transfer_Quantity           NUMBER DEFAULT NULL,
                     X_Count_Point_Type                    NUMBER DEFAULT NULL,
                     X_Operation_Description               VARCHAR2 DEFAULT NULL,
                     X_Option_Dependent_Flag               NUMBER DEFAULT NULL,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL,
                     X_Backflush_Flag                      NUMBER DEFAULT NULL,
                     X_Wms_Task_Type                       NUMBER DEFAULT NULL,
                     X_Yield                               NUMBER DEFAULT NULL,
                     X_Operation_Yield_Enabled             NUMBER DEFAULT NULL,
                     X_Shutdown_Type                       VARCHAR2 DEFAULT NULL,
                     X_Default_SubInventory                VARCHAR2,
                     X_Default_Locator_Id                  NUMBER,
                     X_Value_added			                      VARCHAR2 DEFAULT NULL,
                     X_Critical_To_Quality		               VARCHAR2 DEFAULT NULL
 ) IS
BEGIN
	Insert_Row(
		   X_Rowid				   => X_Rowid,
		   X_Operation_type			   => X_Operation_type,
		   X_Line_Id				   => X_Line_Id,
		   X_Sequence_Num			   => X_Sequence_Num,
		   X_Standard_Operation_Id		   => X_Standard_Operation_Id,
		   X_Operation_Code			   => X_Operation_Code,
		   X_Organization_Id			   => X_Organization_Id,
		   X_Department_Id			   => X_Department_Id,
		   X_Last_Update_Date			   => X_Last_Update_Date,
		   X_Last_Updated_By			   => X_Last_Updated_By,
		   X_Creation_Date			   => X_Creation_Date,
		   X_Created_By				   => X_Created_By,
		   X_Last_Update_Login			   => X_Last_Update_Login,
		   X_Minimum_Transfer_Quantity		   => X_Minimum_Transfer_Quantity,
		   X_Count_Point_Type			   => X_Count_Point_Type,
		   X_Operation_Description		   => X_Operation_Description,
		   X_Option_Dependent_Flag		   => X_Option_Dependent_Flag,
		   X_Attribute_Category			   => X_Attribute_Category,
		   X_Attribute1				   => X_Attribute1,
		   X_Attribute2				   => X_Attribute2,
		   X_Attribute3				   => X_Attribute3,
		   X_Attribute4				   => X_Attribute4,
		   X_Attribute5				   => X_Attribute5,
		   X_Attribute6				   => X_Attribute6,
		   X_Attribute7				   => X_Attribute7,
		   X_Attribute8				   => X_Attribute8,
		   X_Attribute9				   => X_Attribute9,
		   X_Attribute10			   => X_Attribute10,
		   X_Attribute11			   => X_Attribute11,
		   X_Attribute12			   => X_Attribute12,
		   X_Attribute13			   => X_Attribute13,
		   X_Attribute14			   => X_Attribute14,
		   X_Attribute15			   => X_Attribute15,
		   X_Backflush_Flag			   => X_Backflush_Flag,
		   X_Wms_Task_Type			   => X_Wms_Task_Type,
		   X_Yield	     			   => X_Yield,
		   X_Operation_Yield_Enabled		   => X_Operation_Yield_Enabled,
		   X_Shutdown_Type			   => X_Shutdown_Type,
		   X_Default_Subinventory		   => X_Default_Subinventory,
		   X_Default_locator_id			   => X_Default_locator_id,
		   X_value_added			   => X_value_added,
		   X_Critical_To_Quality		   => X_Critical_To_Quality,
		   X_Lowest_Acceptable_Yield		   => NULL,
		   X_Use_Org_Settings			   => NULL,
		   X_Queue_Mandatory_Flag		   => NULL,
		   X_Run_Mandatory_Flag			   => NULL,
		   X_To_Move_Mandatory_Flag		   => NULL,
		   X_Show_Next_Op_By_Default		   => NULL,
		   X_Show_Scrap_Code			   => NULL,
	    X_Show_Lot_Attrib			   => NULL,
		   X_Track_Multiple_Res_Usage_Dts	   => NULL);
END Insert_Row;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Standard_Operation_Id        IN OUT NOCOPY NUMBER,
                     X_Operation_Code                      VARCHAR2,
																					X_Operation_Type                      NUMBER,
																			  X_Line_Id	                   	        NUMBER DEFAULT NULL,
																					X_Sequence_Num			                     NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER,
                     X_Department_Id                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Minimum_Transfer_Quantity           NUMBER DEFAULT NULL,
                     X_Count_Point_Type                    NUMBER DEFAULT NULL,
                     X_Operation_Description               VARCHAR2 DEFAULT NULL,
                     X_Option_Dependent_Flag               NUMBER DEFAULT NULL,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL,
                     X_Backflush_Flag                      NUMBER DEFAULT NULL,
                     X_Wms_Task_Type                       NUMBER DEFAULT NULL,
                     X_Yield                               NUMBER DEFAULT NULL,
                     X_Operation_Yield_Enabled             NUMBER DEFAULT NULL,
                     X_Shutdown_Type                       VARCHAR2 DEFAULT NULL,
                     X_Default_SubInventory                VARCHAR2,
                     X_Default_Locator_Id                  NUMBER,
                     X_Value_added			   VARCHAR2 DEFAULT NULL,
                     X_Critical_To_Quality		   VARCHAR2 DEFAULT NULL,
																					--OSFM-MES:Following new arguments are added
																					X_LOWEST_ACCEPTABLE_YIELD              NUMBER,
																					X_USE_ORG_SETTINGS                     NUMBER,
																					X_QUEUE_MANDATORY_FLAG                 NUMBER,
																					X_RUN_MANDATORY_FLAG                   NUMBER,
																					X_TO_MOVE_MANDATORY_FLAG               NUMBER,
																					X_SHOW_NEXT_OP_BY_DEFAULT              NUMBER,
																					X_SHOW_SCRAP_CODE                      NUMBER,
																					X_SHOW_LOT_ATTRIB                      NUMBER,
																					X_TRACK_MULTIPLE_RES_USAGE_DTS       NUMBER,
																					-- Added for labor skills validation project
																					X_CHECK_SKILL                        NUMBER DEFAULT NULL
 ) IS
   CURSOR C IS SELECT rowid FROM BOM_STANDARD_OPERATIONS
             WHERE standard_operation_id = X_Standard_Operation_Id;
   CURSOR C2 IS SELECT bom_standard_operations_s.nextval FROM sys.dual;
BEGIN
   if (X_Standard_Operation_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Standard_Operation_Id;
     CLOSE C2;
   end if;
   INSERT INTO BOM_STANDARD_OPERATIONS(
          standard_operation_id,
          operation_code,
          operation_type,
          line_id,
          sequence_num,
          organization_id,
          department_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          minimum_transfer_quantity,
          count_point_type,
          operation_description,
          option_dependent_flag,
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
          backflush_flag,
										wms_task_type,
										yield,
										operation_yield_enabled,
          shutdown_type,
          default_subinventory,
          default_locator_id,
          value_added,
          critical_to_quality,
										--OSFM-MES:Following new Colunbs are added
										LOWEST_ACCEPTABLE_YIELD,
										USE_ORG_SETTINGS,
										QUEUE_MANDATORY_FLAG,
										RUN_MANDATORY_FLAG ,
										TO_MOVE_MANDATORY_FLAG ,
										SHOW_NEXT_OP_BY_DEFAULT,
										SHOW_SCRAP_CODE ,
										SHOW_LOT_ATTRIB ,
										TRACK_MULTIPLE_RES_USAGE_DATES,
										-- Added for labor skills validation project
										CHECK_SKILL
         ) VALUES (
	         X_Standard_Operation_Id,
          X_Operation_Code,
	         X_Operation_Type,
          X_Line_Id,
 	        X_Sequence_Num,
          X_Organization_Id,
          X_Department_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Minimum_Transfer_Quantity,
          X_Count_Point_Type,
          X_Operation_Description,
          X_Option_Dependent_Flag,
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
          X_Backflush_Flag,
										X_Wms_Task_Type,
										X_Yield,
										X_Operation_Yield_Enabled,
          X_Shutdown_Type,
          X_Default_SubInventory,
          X_Default_Locator_Id,
          X_Value_added,
          X_Critical_to_Quality,
										--OSFM-MES:Following new Colunbs are added
										X_LOWEST_ACCEPTABLE_YIELD,
										X_USE_ORG_SETTINGS,
										X_QUEUE_MANDATORY_FLAG,
										X_RUN_MANDATORY_FLAG ,
										X_TO_MOVE_MANDATORY_FLAG ,
										X_SHOW_NEXT_OP_BY_DEFAULT,
										X_SHOW_SCRAP_CODE ,
										X_SHOW_LOT_ATTRIB ,
										X_TRACK_MULTIPLE_RES_USAGE_DTS,
										-- Added for labor skills validation project
										X_CHECK_SKILL
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Standard_Operation_Id                 NUMBER,
                   X_Operation_Code                        VARCHAR2,
	  	               X_Operation_Type                        NUMBER,
		                 X_Line_Id	                   	          NUMBER DEFAULT NULL,
 	 	               X_Sequence_Num			                       NUMBER DEFAULT NULL,
                   X_Organization_Id                       NUMBER,
                   X_Department_Id                         NUMBER,
                   X_Minimum_Transfer_Quantity             NUMBER DEFAULT NULL,
                   X_Count_Point_Type                      NUMBER DEFAULT NULL,
                   X_Operation_Description                 VARCHAR2 DEFAULT NULL,
                   X_Option_Dependent_Flag                 NUMBER DEFAULT NULL,
                   X_Attribute_Category                    VARCHAR2 DEFAULT NULL,
                   X_Attribute1                            VARCHAR2 DEFAULT NULL,
                   X_Attribute2                            VARCHAR2 DEFAULT NULL,
                   X_Attribute3                            VARCHAR2 DEFAULT NULL,
                   X_Attribute4                            VARCHAR2 DEFAULT NULL,
                   X_Attribute5                            VARCHAR2 DEFAULT NULL,
                   X_Attribute6                            VARCHAR2 DEFAULT NULL,
                   X_Attribute7                            VARCHAR2 DEFAULT NULL,
                   X_Attribute8                            VARCHAR2 DEFAULT NULL,
                   X_Attribute9                            VARCHAR2 DEFAULT NULL,
                   X_Attribute10                           VARCHAR2 DEFAULT NULL,
                   X_Attribute11                           VARCHAR2 DEFAULT NULL,
                   X_Attribute12                           VARCHAR2 DEFAULT NULL,
                   X_Attribute13                           VARCHAR2 DEFAULT NULL,
                   X_Attribute14                           VARCHAR2 DEFAULT NULL,
                   X_Attribute15                           VARCHAR2 DEFAULT NULL,
                   X_Backflush_Flag                        NUMBER DEFAULT NULL,
                   X_Wms_Task_Type                         NUMBER DEFAULT NULL,
                   X_Yield                                 NUMBER DEFAULT NULL,
                   X_Operation_Yield_Enabled               NUMBER DEFAULT NULL,
                   X_Shutdown_Type                         VARCHAR2 DEFAULT NULL

) IS
  CURSOR C IS
      SELECT *
      FROM   BOM_STANDARD_OPERATIONS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Standard_Operation_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.standard_operation_id = X_Standard_Operation_Id)
           OR (    (Recinfo.standard_operation_id IS NULL)
               AND (X_Standard_Operation_Id IS NULL)))
      AND (   (Recinfo.operation_code = X_Operation_Code)
           OR (    (Recinfo.operation_code IS NULL)
               AND (X_Operation_Code IS NULL)))
      AND (   (Recinfo.operation_type = X_Operation_Type)
           OR (    (Recinfo.operation_type IS NULL)
               AND (X_Operation_Type IS NULL)))
      AND (   (Recinfo.line_id = X_Line_Id)
           OR (    (Recinfo.line_id IS NULL)
               AND (X_Line_Id IS NULL)))
      AND (   (Recinfo.sequence_num = X_Sequence_Num)
           OR (    (Recinfo.sequence_num IS NULL)
               AND (X_Sequence_Num IS NULL)))
      AND (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.department_id = X_Department_Id)
           OR (    (Recinfo.department_id IS NULL)
               AND (X_Department_Id IS NULL)))
      AND (   (Recinfo.minimum_transfer_quantity = X_Minimum_Transfer_Quantity)
           OR (    (Recinfo.minimum_transfer_quantity IS NULL)
               AND (X_Minimum_Transfer_Quantity IS NULL)))
      AND (   (Recinfo.count_point_type = X_Count_Point_type)
           OR (    (Recinfo.count_point_type IS NULL)
               AND (X_Count_Point_Type IS NULL)))
      AND (   (Recinfo.operation_description = X_Operation_Description)
           OR (    (Recinfo.operation_description IS NULL)
               AND (X_Operation_Description IS NULL)))
      AND (   (Recinfo.option_dependent_flag = X_Option_Dependent_Flag)
           OR (    (Recinfo.option_dependent_flag IS NULL)
               AND (X_Option_Dependent_Flag IS NULL)))
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
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.backflush_flag = X_Backflush_Flag)
           OR (    (Recinfo.backflush_flag IS NULL)
               AND (X_Backflush_Flag IS NULL)))
      AND (   (Recinfo.wms_task_type = X_Wms_Task_Type)
           OR (    (Recinfo.wms_task_type IS NULL)
               AND (X_Wms_Task_Type IS NULL)))
      AND (   (Recinfo.yield = X_Yield)
           OR (    (Recinfo.yield IS NULL)
               AND (X_Yield IS NULL)))
      AND (   (Recinfo.Operation_Yield_Enabled = X_Operation_Yield_Enabled)
           OR (    (Recinfo.Operation_Yield_Enabled IS NULL)
               AND (X_Operation_Yield_Enabled IS NULL)))
      AND (   (Recinfo.Shutdown_Type = X_Shutdown_Type)
           OR (    (Recinfo.Shutdown_Type IS NULL)
               AND (X_Shutdown_Type IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Standard_Operation_Id                 NUMBER,
                   X_Operation_Code                        VARCHAR2,
																			X_Operation_Type                        NUMBER,
																	  X_Line_Id	                   	          NUMBER DEFAULT NULL,
																			X_Sequence_Num			                       NUMBER DEFAULT NULL,
                   X_Organization_Id                       NUMBER,
                   X_Department_Id                         NUMBER,
                   X_Minimum_Transfer_Quantity             NUMBER DEFAULT NULL,
                   X_Count_Point_Type                      NUMBER DEFAULT NULL,
                   X_Operation_Description                 VARCHAR2 DEFAULT NULL,
                   X_Option_Dependent_Flag                 NUMBER DEFAULT NULL,
                   X_Attribute_Category                    VARCHAR2 DEFAULT NULL,
                   X_Attribute1                            VARCHAR2 DEFAULT NULL,
                   X_Attribute2                            VARCHAR2 DEFAULT NULL,
                   X_Attribute3                            VARCHAR2 DEFAULT NULL,
                   X_Attribute4                            VARCHAR2 DEFAULT NULL,
                   X_Attribute5                            VARCHAR2 DEFAULT NULL,
                   X_Attribute6                            VARCHAR2 DEFAULT NULL,
                   X_Attribute7                            VARCHAR2 DEFAULT NULL,
                   X_Attribute8                            VARCHAR2 DEFAULT NULL,
                   X_Attribute9                            VARCHAR2 DEFAULT NULL,
                   X_Attribute10                           VARCHAR2 DEFAULT NULL,
                   X_Attribute11                           VARCHAR2 DEFAULT NULL,
                   X_Attribute12                           VARCHAR2 DEFAULT NULL,
                   X_Attribute13                           VARCHAR2 DEFAULT NULL,
                   X_Attribute14                           VARCHAR2 DEFAULT NULL,
                   X_Attribute15                           VARCHAR2 DEFAULT NULL,
                   X_Backflush_Flag                        NUMBER DEFAULT NULL,
                   X_Wms_Task_Type                         NUMBER DEFAULT NULL,
                   X_Yield                                 NUMBER DEFAULT NULL,
                   X_Operation_Yield_Enabled               NUMBER DEFAULT NULL,
                   X_Shutdown_Type                         VARCHAR2 DEFAULT NULL,
                   X_Default_SubInventory                  VARCHAR2,
                   X_Default_Locator_Id                    NUMBER,
                   X_Value_added			                        VARCHAR2 DEFAULT NULL,
                   X_Critical_To_Quality		                 VARCHAR2 DEFAULT NULL
) IS
BEGIN
	  Lock_Row(
		                 X_Rowid                                 => X_Rowid,
                   X_Standard_Operation_Id                 => X_Standard_Operation_Id,
                   X_Operation_Code                        => X_Operation_Code,
																			X_Operation_Type                        => X_Operation_Type,
																	  X_Line_Id	                   	   => X_Line_Id,
																			X_Sequence_Num			   => X_Sequence_Num,
                   X_Organization_Id                       => X_Organization_Id ,
                   X_Department_Id                         => X_Department_Id ,
                   X_Minimum_Transfer_Quantity		   => X_Minimum_Transfer_Quantity,
                   X_Count_Point_Type                      => X_Count_Point_Type  ,
                   X_Operation_Description                 => X_Operation_Description ,
                   X_Option_Dependent_Flag                 => X_Option_Dependent_Flag ,
                   X_Attribute_Category                    => X_Attribute_Category,
                   X_Attribute1                            => X_Attribute1,
                   X_Attribute2                            => X_Attribute2,
                   X_Attribute3                            => X_Attribute3,
                   X_Attribute4                            => X_Attribute4,
                   X_Attribute5                            => X_Attribute5,
                   X_Attribute6                            => X_Attribute6,
                   X_Attribute7                            => X_Attribute7,
                   X_Attribute8                            => X_Attribute8,
                   X_Attribute9                            => X_Attribute9,
                   X_Attribute10                           => X_Attribute10,
                   X_Attribute11                           => X_Attribute11,
                   X_Attribute12                           => X_Attribute12,
                   X_Attribute13                           => X_Attribute13,
                   X_Attribute14                           => X_Attribute14,
                   X_Attribute15                           => X_Attribute15,
                   X_Backflush_Flag                        => X_Backflush_Flag,
                   X_Wms_Task_Type                         => X_Wms_Task_Type,
                   X_Yield                                 => X_Yield,
                   X_Operation_Yield_Enabled               => X_Operation_Yield_Enabled,
                   X_Shutdown_Type                         => X_Shutdown_Type,
                   X_Default_SubInventory                  => X_Default_SubInventory,
                   X_Default_Locator_Id                    => X_Default_Locator_Id,
                   X_Value_added			   => X_Value_added,
                   X_Critical_To_Quality		   => X_Critical_To_Quality,
																			X_Lowest_Acceptable_Yield               => NULL,
																			X_Use_Org_Settings                      => NULL,
																			X_Queue_Mandatory_Flag                  => NULL,
																			X_Run_Mandatory_Flag                    => NULL,
																			X_To_Move_Mandatory_Flag                => NULL,
																			X_Show_Next_Op_By_Default               => NULL,
																			X_Show_Scrap_Code                       => NULL,
																			X_Show_Lot_Attrib                       => NULL,
																			X_Track_Multiple_Res_Usage_Dts          => NULL);
END Lock_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Standard_Operation_Id                 NUMBER,
                   X_Operation_Code                        VARCHAR2,
																			X_Operation_Type                        NUMBER,
																	  X_Line_Id	                   	          NUMBER DEFAULT NULL,
																			X_Sequence_Num			                       NUMBER DEFAULT NULL,
                   X_Organization_Id                       NUMBER,
                   X_Department_Id                         NUMBER,
                   X_Minimum_Transfer_Quantity             NUMBER DEFAULT NULL,
                   X_Count_Point_Type                      NUMBER DEFAULT NULL,
                   X_Operation_Description                 VARCHAR2 DEFAULT NULL,
                   X_Option_Dependent_Flag                 NUMBER DEFAULT NULL,
                   X_Attribute_Category                    VARCHAR2 DEFAULT NULL,
                   X_Attribute1                            VARCHAR2 DEFAULT NULL,
                   X_Attribute2                            VARCHAR2 DEFAULT NULL,
                   X_Attribute3                            VARCHAR2 DEFAULT NULL,
                   X_Attribute4                            VARCHAR2 DEFAULT NULL,
                   X_Attribute5                            VARCHAR2 DEFAULT NULL,
                   X_Attribute6                            VARCHAR2 DEFAULT NULL,
                   X_Attribute7                            VARCHAR2 DEFAULT NULL,
                   X_Attribute8                            VARCHAR2 DEFAULT NULL,
                   X_Attribute9                            VARCHAR2 DEFAULT NULL,
                   X_Attribute10                           VARCHAR2 DEFAULT NULL,
                   X_Attribute11                           VARCHAR2 DEFAULT NULL,
                   X_Attribute12                           VARCHAR2 DEFAULT NULL,
                   X_Attribute13                           VARCHAR2 DEFAULT NULL,
                   X_Attribute14                           VARCHAR2 DEFAULT NULL,
                   X_Attribute15                           VARCHAR2 DEFAULT NULL,
                   X_Backflush_Flag                        NUMBER DEFAULT NULL,
                   X_Wms_Task_Type                         NUMBER DEFAULT NULL,
                   X_Yield                                 NUMBER DEFAULT NULL,
                   X_Operation_Yield_Enabled               NUMBER DEFAULT NULL,
                   X_Shutdown_Type                         VARCHAR2 DEFAULT NULL,
                   X_Default_SubInventory                  VARCHAR2,
                   X_Default_Locator_Id                    NUMBER,
                   X_Value_added			   VARCHAR2 DEFAULT NULL,
                   X_Critical_To_Quality		   VARCHAR2 DEFAULT NULL,
																			--OSFM-MES:Following new arguments are added
																			X_LOWEST_ACCEPTABLE_YIELD              NUMBER,
																			X_USE_ORG_SETTINGS                     NUMBER,
																			X_QUEUE_MANDATORY_FLAG                 NUMBER,
																			X_RUN_MANDATORY_FLAG                   NUMBER,
																			X_TO_MOVE_MANDATORY_FLAG               NUMBER,
																			X_SHOW_NEXT_OP_BY_DEFAULT              NUMBER,
																			X_SHOW_SCRAP_CODE                      NUMBER,
																			X_SHOW_LOT_ATTRIB                      NUMBER,
																			X_TRACK_MULTIPLE_RES_USAGE_DTS       NUMBER,
																			-- Added for labor skills validation project
																			X_CHECK_SKILL                          NUMBER DEFAULT NULL
) IS
  CURSOR C IS
      SELECT *
      FROM   BOM_STANDARD_OPERATIONS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Standard_Operation_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.standard_operation_id = X_Standard_Operation_Id)
           OR (    (Recinfo.standard_operation_id IS NULL)
               AND (X_Standard_Operation_Id IS NULL)))
      AND (   (Recinfo.operation_code = X_Operation_Code)
           OR (    (Recinfo.operation_code IS NULL)
               AND (X_Operation_Code IS NULL)))
      AND (   (Recinfo.operation_type = X_Operation_Type)
           OR (    (Recinfo.operation_type IS NULL)
               AND (X_Operation_Type IS NULL)))
      AND (   (Recinfo.line_id = X_Line_Id)
           OR (    (Recinfo.line_id IS NULL)
               AND (X_Line_Id IS NULL)))
      AND (   (Recinfo.sequence_num = X_Sequence_Num)
           OR (    (Recinfo.sequence_num IS NULL)
               AND (X_Sequence_Num IS NULL)))
      AND (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.department_id = X_Department_Id)
           OR (    (Recinfo.department_id IS NULL)
               AND (X_Department_Id IS NULL)))
      AND (   (Recinfo.minimum_transfer_quantity = X_Minimum_Transfer_Quantity)
           OR (    (Recinfo.minimum_transfer_quantity IS NULL)
               AND (X_Minimum_Transfer_Quantity IS NULL)))
      AND (   (Recinfo.count_point_type = X_Count_Point_type)
           OR (    (Recinfo.count_point_type IS NULL)
               AND (X_Count_Point_Type IS NULL)))
      AND (   (Recinfo.operation_description = X_Operation_Description)
           OR (    (Recinfo.operation_description IS NULL)
               AND (X_Operation_Description IS NULL)))
      AND (   (Recinfo.option_dependent_flag = X_Option_Dependent_Flag)
           OR (    (Recinfo.option_dependent_flag IS NULL)
               AND (X_Option_Dependent_Flag IS NULL)))
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
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.backflush_flag = X_Backflush_Flag)
           OR (    (Recinfo.backflush_flag IS NULL)
               AND (X_Backflush_Flag IS NULL)))
      AND (   (Recinfo.wms_task_type = X_Wms_Task_Type)
           OR (    (Recinfo.wms_task_type IS NULL)
               AND (X_Wms_Task_Type IS NULL)))
      AND (   (Recinfo.yield = X_Yield)
           OR (    (Recinfo.yield IS NULL)
               AND (X_Yield IS NULL)))
      AND (   (Recinfo.Operation_Yield_Enabled = X_Operation_Yield_Enabled)
           OR (    (Recinfo.Operation_Yield_Enabled IS NULL)
               AND (X_Operation_Yield_Enabled IS NULL)))
      AND (   (Recinfo.Shutdown_Type = X_Shutdown_Type)
           OR (    (Recinfo.Shutdown_Type IS NULL)
               AND (X_Shutdown_Type IS NULL)))
      AND (   (Recinfo.Default_SubInventory = X_Default_SubInventory)
           OR (    (Recinfo.Default_SubInventory IS NULL)
               AND (X_Default_SubInventory IS NULL)))
      AND (   (Recinfo.Default_Locator_Id = X_Default_Locator_Id)
           OR (    (Recinfo.Default_Locator_Id IS NULL)
               AND (X_Default_Locator_Id IS NULL)))
      AND (   (Recinfo.Value_added = X_Value_added)
           OR (    (Recinfo.Value_added IS NULL)
               AND (X_Value_added IS NULL)))
      AND (   (Recinfo.Critical_To_Quality = X_Critical_To_Quality)
           OR (    (Recinfo.Critical_To_Quality IS NULL)
               AND (X_Critical_To_Quality IS NULL)))
      --OSFM-MES:Following New columns are added...
      AND	(Recinfo.LOWEST_ACCEPTABLE_YIELD        =  X_LOWEST_ACCEPTABLE_YIELD
      OR	 (Recinfo.LOWEST_ACCEPTABLE_YIELD IS NULL
      AND 	X_LOWEST_ACCEPTABLE_YIELD IS NULL))
      AND	(Recinfo.USE_ORG_SETTINGS               =  X_USE_ORG_SETTINGS
       OR	 (Recinfo.USE_ORG_SETTINGS IS NULL
      AND 	X_USE_ORG_SETTINGS IS NULL))
      AND	(Recinfo.QUEUE_MANDATORY_FLAG           =  X_QUEUE_MANDATORY_FLAG
        OR	 (Recinfo.QUEUE_MANDATORY_FLAG IS NULL
      AND 	X_QUEUE_MANDATORY_FLAG IS NULL))
      AND	(Recinfo.RUN_MANDATORY_FLAG             =  X_RUN_MANDATORY_FLAG
       OR	 (Recinfo.RUN_MANDATORY_FLAG IS NULL
      AND 	X_RUN_MANDATORY_FLAG IS NULL))
      AND	(Recinfo.TO_MOVE_MANDATORY_FLAG         =  X_TO_MOVE_MANDATORY_FLAG
       OR	 (Recinfo.TO_MOVE_MANDATORY_FLAG IS NULL
      AND 	X_TO_MOVE_MANDATORY_FLAG IS NULL))
      AND	(Recinfo.SHOW_NEXT_OP_BY_DEFAULT        =  X_SHOW_NEXT_OP_BY_DEFAULT
        OR	 (Recinfo.SHOW_NEXT_OP_BY_DEFAULT IS NULL
      AND 	X_SHOW_NEXT_OP_BY_DEFAULT IS NULL))
      AND	(Recinfo.SHOW_SCRAP_CODE                =  X_SHOW_SCRAP_CODE
      OR	 (Recinfo.SHOW_SCRAP_CODE IS NULL
      AND 	X_SHOW_SCRAP_CODE IS NULL))
      AND	(Recinfo.SHOW_LOT_ATTRIB                =  X_SHOW_LOT_ATTRIB
      OR	 (Recinfo.SHOW_LOT_ATTRIB IS NULL
      AND 	X_SHOW_LOT_ATTRIB IS NULL))
      AND	(Recinfo.TRACK_MULTIPLE_RES_USAGE_DATES =  X_TRACK_MULTIPLE_RES_USAGE_DTS
     OR	 	(Recinfo.TRACK_MULTIPLE_RES_USAGE_DATES IS NULL
      AND 	X_TRACK_MULTIPLE_RES_USAGE_DTS IS NULL))
      -- Added for labor skills validation project
						AND	(Recinfo.CHECK_SKILL =  X_CHECK_SKILL
     OR	 	(Recinfo.CHECK_SKILL IS NULL
      AND 	(X_CHECK_SKILL IS NULL OR X_CHECK_SKILL=2)))

          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Standard_Operation_Id               NUMBER,
                     X_Operation_Code                      VARCHAR2,
																					X_Operation_Type                      NUMBER,
																			  X_Line_Id	                            NUMBER DEFAULT NULL,
																					X_Sequence_Num			                     NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER,
                     X_Department_Id                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Minimum_Transfer_Quantity           NUMBER DEFAULT NULL,
                     X_Count_Point_Type                    NUMBER DEFAULT NULL,
                     X_Operation_Description               VARCHAR2 DEFAULT NULL,
                     X_Option_Dependent_Flag               NUMBER DEFAULT NULL,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL,
                     X_Backflush_Flag                      NUMBER DEFAULT NULL,
                     X_Wms_Task_Type                       NUMBER DEFAULT NULL,
                     X_Yield                               NUMBER DEFAULT NULL,
                     X_Operation_Yield_Enabled             NUMBER DEFAULT NULL,
                     X_Shutdown_Type                       VARCHAR2 DEFAULT NULL

) IS
BEGIN
  UPDATE BOM_STANDARD_OPERATIONS
  SET
    standard_operation_id                     =    X_Standard_Operation_Id,
    operation_code                            =    X_Operation_Code,
    operation_type			                         =    X_Operation_Type,
    line_id                                   =    X_Line_Id,
    sequence_num			                           =    X_Sequence_Num,
    organization_id                           =    X_Organization_Id,
    department_id                             =    X_Department_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    minimum_transfer_quantity                 =    X_Minimum_Transfer_Quantity,
    count_point_type                          =    X_Count_Point_Type,
    operation_description                     =    X_Operation_Description,
    option_dependent_flag                     =    X_Option_Dependent_Flag,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    backflush_flag                            =    X_Backflush_Flag,
    wms_task_type                             =    X_Wms_Task_Type,
    yield				                                 =    X_Yield,
    operation_yield_enabled		                 =    X_Operation_Yield_Enabled,
    shutdown_type                             =    X_Shutdown_Type
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Standard_Operation_Id               NUMBER,
                     X_Operation_Code                      VARCHAR2,
																					X_Operation_Type                      NUMBER,
																			  X_Line_Id	                            NUMBER DEFAULT NULL,
																					X_Sequence_Num			                     NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER,
                     X_Department_Id                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Minimum_Transfer_Quantity           NUMBER DEFAULT NULL,
                     X_Count_Point_Type                    NUMBER DEFAULT NULL,
                     X_Operation_Description               VARCHAR2 DEFAULT NULL,
                     X_Option_Dependent_Flag               NUMBER DEFAULT NULL,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL,
                     X_Backflush_Flag                      NUMBER DEFAULT NULL,
                     X_Wms_Task_Type                       NUMBER DEFAULT NULL,
                     X_Yield                               NUMBER DEFAULT NULL,
                     X_Operation_Yield_Enabled             NUMBER DEFAULT NULL,
                     X_Shutdown_Type                       VARCHAR2 DEFAULT NULL,
                     X_Default_SubInventory                VARCHAR2,
                     X_Default_Locator_Id                  NUMBER,
                     X_Value_added			                      VARCHAR2 DEFAULT NULL,
                     X_Critical_To_quality		               VARCHAR2 DEFAULT NULL
) IS
BEGIN
	  Update_Row(
		                 X_Rowid                                 => X_Rowid,
                   X_Standard_Operation_Id                 => X_Standard_Operation_Id,
                   X_Operation_Code                        => X_Operation_Code,
	  	               X_Operation_Type                        => X_Operation_Type,
		                 X_Line_Id	                   	          => X_Line_Id,
 	 	               X_Sequence_Num			                       => X_Sequence_Num,
                   X_Organization_Id                       => X_Organization_Id ,
                   X_Department_Id                         => X_Department_Id ,
                   X_Last_Update_Date                      => X_Last_Update_Date ,
                   X_Last_Updated_By                       => X_Last_Updated_By ,
                   X_Last_Update_Login                     => X_Last_Update_Login ,
                   X_Minimum_Transfer_Quantity		           => X_Minimum_Transfer_Quantity,
                   X_Count_Point_Type                      => X_Count_Point_Type  ,
                   X_Operation_Description                 => X_Operation_Description ,
                   X_Option_Dependent_Flag                 => X_Option_Dependent_Flag ,
                   X_Attribute_Category                    => X_Attribute_Category,
                   X_Attribute1                            => X_Attribute1,
                   X_Attribute2                            => X_Attribute2,
                   X_Attribute3                            => X_Attribute3,
                   X_Attribute4                            => X_Attribute4,
                   X_Attribute5                            => X_Attribute5,
                   X_Attribute6                            => X_Attribute6,
                   X_Attribute7                            => X_Attribute7,
                   X_Attribute8                            => X_Attribute8,
                   X_Attribute9                            => X_Attribute9,
                   X_Attribute10                           => X_Attribute10,
                   X_Attribute11                           => X_Attribute11,
                   X_Attribute12                           => X_Attribute12,
                   X_Attribute13                           => X_Attribute13,
                   X_Attribute14                           => X_Attribute14,
                   X_Attribute15                           => X_Attribute15,
                   X_Backflush_Flag                        => X_Backflush_Flag,
                   X_Wms_Task_Type                         => X_Wms_Task_Type,
                   X_Yield                                 => X_Yield,
                   X_Operation_Yield_Enabled               => X_Operation_Yield_Enabled,
                   X_Shutdown_Type                         => X_Shutdown_Type,
                   X_Default_SubInventory                  => X_Default_SubInventory,
                   X_Default_Locator_Id                    => X_Default_Locator_Id,
                   X_Value_added			                        => X_Value_added,
                   X_Critical_To_Quality		                 => X_Critical_To_Quality,
																			X_Lowest_Acceptable_Yield               => NULL,
																			X_Use_Org_Settings                      => NULL,
																			X_Queue_Mandatory_Flag                  => NULL,
																			X_Run_Mandatory_Flag                    => NULL,
																			X_To_Move_Mandatory_Flag                => NULL,
																			X_Show_Next_Op_By_Default               => NULL,
																			X_Show_Scrap_Code                       => NULL,
																			X_Show_Lot_Attrib                       => NULL,
																			X_Track_Multiple_Res_Usage_Dts          => NULL);
END Update_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Standard_Operation_Id               NUMBER,
                     X_Operation_Code                      VARCHAR2,
																					X_Operation_Type                      NUMBER,
																			  X_Line_Id	                            NUMBER DEFAULT NULL,
																					X_Sequence_Num			                     NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER,
                     X_Department_Id                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Minimum_Transfer_Quantity           NUMBER DEFAULT NULL,
                     X_Count_Point_Type                    NUMBER DEFAULT NULL,
                     X_Operation_Description               VARCHAR2 DEFAULT NULL,
                     X_Option_Dependent_Flag               NUMBER DEFAULT NULL,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL,
                     X_Backflush_Flag                      NUMBER DEFAULT NULL,
                     X_Wms_Task_Type                       NUMBER DEFAULT NULL,
                     X_Yield                               NUMBER DEFAULT NULL,
                     X_Operation_Yield_Enabled             NUMBER DEFAULT NULL,
                     X_Shutdown_Type                       VARCHAR2 DEFAULT NULL,
                     X_Default_SubInventory                VARCHAR2,
                     X_Default_Locator_Id                  NUMBER,
                     X_Value_added			                      VARCHAR2 DEFAULT NULL,
                     X_Critical_To_quality		               VARCHAR2 DEFAULT NULL,
		                   --OSFM-MES:Following new arguments are added
																					X_LOWEST_ACCEPTABLE_YIELD              NUMBER,
																					X_USE_ORG_SETTINGS                     NUMBER,
																					X_QUEUE_MANDATORY_FLAG                 NUMBER,
																					X_RUN_MANDATORY_FLAG                   NUMBER,
																					X_TO_MOVE_MANDATORY_FLAG               NUMBER,
																					X_SHOW_NEXT_OP_BY_DEFAULT              NUMBER,
																					X_SHOW_SCRAP_CODE                      NUMBER,
																					X_SHOW_LOT_ATTRIB                      NUMBER,
																					X_TRACK_MULTIPLE_RES_USAGE_DTS         NUMBER,
																					X_CHECK_SKILL                          NUMBER DEFAULT NULL
) IS
BEGIN
  UPDATE BOM_STANDARD_OPERATIONS
  SET
    standard_operation_id                     =    X_Standard_Operation_Id,
    operation_code                            =    X_Operation_Code,
    operation_type			                         =    X_Operation_Type,
    line_id                                   =    X_Line_Id,
    sequence_num			                           =    X_Sequence_Num,
    organization_id                           =    X_Organization_Id,
    department_id                             =    X_Department_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    minimum_transfer_quantity                 =    X_Minimum_Transfer_Quantity,
    count_point_type                          =    X_Count_Point_Type,
    operation_description                     =    X_Operation_Description,
    option_dependent_flag                     =    X_Option_Dependent_Flag,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    backflush_flag                            =    X_Backflush_Flag,
    wms_task_type                             =    X_Wms_Task_Type,
    yield				                                 =    X_Yield,
    operation_yield_enabled		                 =    X_Operation_Yield_Enabled,
    shutdown_type                             =    X_Shutdown_Type,
    default_subinventory                      =    X_Default_SubInventory,
    default_locator_id                        =    X_Default_Locator_Id,
    value_added				                           =    X_Value_Added,
    critical_to_quality			                    =    X_Critical_To_Quality,
    LOWEST_ACCEPTABLE_YIELD       	           =    X_LOWEST_ACCEPTABLE_YIELD,
    USE_ORG_SETTINGS              	           =    X_USE_ORG_SETTINGS,
    QUEUE_MANDATORY_FLAG          	           =    X_QUEUE_MANDATORY_FLAG,
    RUN_MANDATORY_FLAG            	           =    X_RUN_MANDATORY_FLAG,
    TO_MOVE_MANDATORY_FLAG        	           =    X_TO_MOVE_MANDATORY_FLAG ,
    SHOW_NEXT_OP_BY_DEFAULT       	           =    X_SHOW_NEXT_OP_BY_DEFAULT ,
    SHOW_SCRAP_CODE               	           =    X_SHOW_SCRAP_CODE ,
    SHOW_LOT_ATTRIB               	           =    X_SHOW_LOT_ATTRIB,
    TRACK_MULTIPLE_RES_USAGE_DATES	           =    X_TRACK_MULTIPLE_RES_USAGE_DTS,
    CHECK_SKILL                               =    X_CHECK_SKILL
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;


PROCEDURE Delete_Row(X_Rowid                 VARCHAR2,
  		     X_Standard_Operation_Id NUMBER) IS
BEGIN
  DELETE FROM BOM_STANDARD_OPERATIONS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  elsif (SQL%FOUND) then
    Delete_Details(X_Standard_Operation_Id);
  end if;
END Delete_Row;


PROCEDURE Check_Unique(X_Rowid VARCHAR2,
		       X_Organization_Id NUMBER,
	       	       X_Operation_Code VARCHAR2,
                       X_Line_Id      NUMBER,
                       X_Operation_Type Number) IS
  dummy 	NUMBER;
BEGIN
-- Added If condition and wrote seperate sql's to handle x_line_id NULL condition.
-- Bug 4173389
 If (X_Line_Id is NULL) Then
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_STANDARD_OPERATIONS
     WHERE Organization_Id = X_Organization_Id
       AND Operation_Code  = X_Operation_Code
       AND (Operation_Type  = X_Operation_Type
       OR   Operation_Type  IS NULL)
       AND   Line_Id  IS NULL
       AND ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
    );
  Else
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_STANDARD_OPERATIONS
     WHERE Organization_Id = X_Organization_Id
       AND Operation_Code  = X_Operation_Code
       AND (Operation_Type  = X_Operation_Type
       OR   Operation_Type  IS NULL)
       AND  Line_Id         = X_Line_Id
       -- OR   Line_Id  IS NULL) Commented for bug 4173389 and modified above line.
       AND ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
    );
  End If;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('BOM', 'BOM_ALREADY_EXISTS');
      if (( X_Operation_type =1) and (X_Line_Id is null )) then
         FND_MESSAGE.SET_TOKEN('ENTITY1', 'STANDARD OPERATION_CAP', TRUE);
      elsif (X_Operation_type =3) then
         FND_MESSAGE.SET_TOKEN('ENTITY1', 'STANDARD LINE_OP_CAP', TRUE);
      elsif (X_Operation_type =2) then
         FND_MESSAGE.SET_TOKEN('ENTITY1', 'STANDARD PROCESS_CAP', TRUE);
      else
         FND_MESSAGE.SET_TOKEN('ENTITY1', 'STANDARD EVENT_CAP', TRUE);
      end if;
      FND_MESSAGE.SET_TOKEN('ENTITY2', X_Operation_Code);
      APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique;


PROCEDURE Check_Unique_Seq(X_Rowid VARCHAR2,
		           X_Organization_Id NUMBER,
	       	           X_Operation_Code VARCHAR2,
                           X_Line_Id      NUMBER,
                           X_Operation_Type Number,
		           X_Sequence_Num   Number) IS
  dummy 	NUMBER;
  x_line_code     VARCHAR2(10);
BEGIN

   SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_STANDARD_OPERATIONS
     WHERE Organization_Id = X_Organization_Id
       AND (Operation_Type  = X_Operation_Type
       OR   Operation_Type IS NULL)
       AND (Line_Id         = X_Line_Id
       OR   Line_Id  IS NULL)
       AND Sequence_Num    = X_Sequence_Num
       AND ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
    );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT LINE_CODE into x_line_code from WIP_LINES  where LINE_ID = X_Line_id;
      FND_MESSAGE.SET_NAME('BOM', 'BOM_ALREADY_EXISTS');
      FND_MESSAGE.SET_TOKEN('ENTITY1', X_Sequence_Num);
      FND_MESSAGE.SET_TOKEN('ENTITY2', x_line_code);
      APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique_Seq;


PROCEDURE Check_References(X_Standard_Operation_Id NUMBER,
		           X_Operation_Code VARCHAR2	) IS
  	dummy 		NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_OPERATION_SEQUENCES
     WHERE STANDARD_OPERATION_ID = X_Standard_Operation_Id
       AND ((DISABLE_DATE > SYSDATE) OR (DISABLE_DATE IS NULL))
    );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('BOM', 'BOM_STD_OP_IN_USE');
    FND_MESSAGE.SET_TOKEN('ENTITY', X_Operation_Code);
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_References;

PROCEDURE Delete_Details(X_Standard_Operation_Id NUMBER) IS
BEGIN
  DELETE FROM BOM_STD_OP_RESOURCES
  WHERE STANDARD_OPERATION_ID = X_Standard_Operation_Id;
		DELETE FROM BOM_OPERATION_SKILLS
		WHERE STANDARD_OPERATION_ID = X_Standard_Operation_Id
		and LEVEL_ID=1;
END Delete_Details;

-- Added the following Function for BUG 3986337
FUNCTION Check_Wms_exists(p_std_operation_id IN NUMBER) RETURN BOOLEAN IS
l_wms_install NUMBER;
v_sqlstr VARCHAR2(100);
v_result NUMBER;
CURSOR wms_inst_cur IS
SELECT 1 FROM fnd_application app, fnd_product_installations inst
WHERE  app.application_short_name = 'WMS'
AND    inst.application_id = app.application_id
AND    inst.status <> 'N';
BEGIN
OPEN wms_inst_cur;
FETCH wms_inst_cur INTO l_wms_install;
CLOSE wms_inst_cur;
v_sqlstr := 'SELECT 1 FROM wms_rules_b WHERE type_hdr_id = :a AND type_code = 3 AND rownum < 2';
IF l_wms_install = 1 THEN
  EXECUTE IMMEDIATE v_sqlstr INTO v_result USING p_std_operation_id;
  IF v_result = 1 THEN
	RETURN TRUE;
  ELSE
	RETURN FALSE;
  END IF;
ELSE /*bug:4318462 - If l_wms_install is not 1 (i.e.) when WMS is not installed, then return false.*/
	RETURN FALSE;
END IF;
EXCEPTION
WHEN OTHERS THEN
	RETURN FALSE;
END Check_Wms_exists;

PROCEDURE Check_Setup_Std_Op_Ref( P_Standard_Operation_Id NUMBER,   -- BUG 4256393
                                  P_Operation_Code VARCHAR2 ) IS
	l_dummy		NUMBER;
BEGIN
  SELECT 1 INTO l_dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_SETUP_TRANSITIONS
     WHERE OPERATION_ID = P_Standard_Operation_Id
    );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('BOM', 'BOM_SETUP_STD_OP_IN_USE');
    FND_MESSAGE.SET_TOKEN('ENTITY', P_Operation_Code);
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Setup_Std_Op_Ref;

END B_STD_OP_PKG;

/
