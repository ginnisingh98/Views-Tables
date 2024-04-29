--------------------------------------------------------
--  DDL for Package Body MTL_CYCLE_COUNT_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CYCLE_COUNT_ITEMS_PKG" as
/* $Header: INVADC2B.pls 120.1 2005/06/19 01:01:08 appldev  $ */
--Added NOCOPY hint to X_Rowid to comply with GSCC File.Sql.39
--standard Bug:4410902
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY  VARCHAR2,
                       X_Cycle_Count_Header_Id                  NUMBER,
                       X_Inventory_Item_Id                      NUMBER,
                       X_Last_Update_Date                       DATE,
                       X_Last_Updated_By                        NUMBER,
                       X_Creation_Date                          DATE,
                       X_Created_By                             NUMBER,
                       X_Last_Update_Login                      NUMBER,
                       X_Abc_Class_Id                           NUMBER,
                       X_Item_Last_Schedule_Date                DATE,
                       X_Schedule_Order                         NUMBER,
                       X_Approval_Tolerance_Positive            NUMBER,
                       X_Approval_Tolerance_Negative            NUMBER,
                       X_Control_Group_Flag                     NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM mtl_cycle_count_items
                 WHERE cycle_count_header_id = X_Cycle_Count_Header_Id;

   BEGIN
       INSERT INTO mtl_cycle_count_items(
              cycle_count_header_id,
              inventory_item_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              abc_class_id,
              item_last_schedule_date,
              schedule_order,
              approval_tolerance_positive,
              approval_tolerance_negative,
              control_group_flag
             ) VALUES (
              X_Cycle_Count_Header_Id,
              X_Inventory_Item_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Abc_Class_Id,
              X_Item_Last_Schedule_Date,
              X_Schedule_Order,
              X_Approval_Tolerance_Positive,
              X_Approval_Tolerance_Negative,
              X_Control_Group_Flag
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Cycle_Count_Header_Id            NUMBER,
                     X_Inventory_Item_Id                NUMBER,
                     X_Abc_Class_Id                     NUMBER,
                     X_Item_Last_Schedule_Date          DATE,
                     X_Schedule_Order                   NUMBER,
                     X_Approval_Tolerance_Positive      NUMBER,
                     X_Approval_Tolerance_Negative      NUMBER,
                     X_Control_Group_Flag               NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   mtl_cycle_count_items
        WHERE  rowid = X_Rowid
        FOR UPDATE of Cycle_Count_Header_Id NOWAIT;
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
               (Recinfo.cycle_count_header_id =  X_Cycle_Count_Header_Id)
           AND (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
           AND (Recinfo.abc_class_id =  X_Abc_Class_Id)
           AND (   (Recinfo.item_last_schedule_date =  X_Item_Last_Schedule_Date)
                OR (    (Recinfo.item_last_schedule_date IS NULL)
                    AND (X_Item_Last_Schedule_Date IS NULL)))
           AND (   (Recinfo.schedule_order =  X_Schedule_Order)
                OR (    (Recinfo.schedule_order IS NULL)
                    AND (X_Schedule_Order IS NULL)))
           AND (   (Recinfo.approval_tolerance_positive =  X_Approval_Tolerance_Positive)
                OR (    (Recinfo.approval_tolerance_positive IS NULL)
                    AND (X_Approval_Tolerance_Positive IS NULL)))
           AND (   (Recinfo.approval_tolerance_negative =  X_Approval_Tolerance_Negative)
                OR (    (Recinfo.approval_tolerance_negative IS NULL)
                    AND (X_Approval_Tolerance_Negative IS NULL)))
           AND (   (Recinfo.control_group_flag =  X_Control_Group_Flag)
                OR (    (Recinfo.control_group_flag IS NULL)
                    AND (X_Control_Group_Flag IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Cycle_Count_Header_Id          NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Abc_Class_Id                   NUMBER,
                       X_Item_Last_Schedule_Date        DATE,
                       X_Schedule_Order                 NUMBER,
                       X_Approval_Tolerance_Positive    NUMBER,
                       X_Approval_Tolerance_Negative    NUMBER,
                       X_Control_Group_Flag             NUMBER
  ) IS
  BEGIN
    UPDATE mtl_cycle_count_items
    SET
       cycle_count_header_id           =     X_Cycle_Count_Header_Id,
       inventory_item_id               =     X_Inventory_Item_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       abc_class_id                    =     X_Abc_Class_Id,
       item_last_schedule_date         =     X_Item_Last_Schedule_Date,
       schedule_order                  =     X_Schedule_Order,
       approval_tolerance_positive     =     X_Approval_Tolerance_Positive,
       approval_tolerance_negative     =     X_Approval_Tolerance_Negative,
       control_group_flag              =     X_Control_Group_Flag
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM mtl_cycle_count_items
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END MTL_CYCLE_COUNT_ITEMS_PKG;

/
