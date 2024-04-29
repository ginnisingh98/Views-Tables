--------------------------------------------------------
--  DDL for Package Body MTL_CYCLE_COUNT_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CYCLE_COUNT_HEADERS_PKG" as
/* $Header: INVADCYB.pls 120.1 2005/06/19 05:43:32 appldev  $ */
--Added NOCOPY hint to X_Rowid IN OUT parameter to comply with
--GSCC File.Sql.39 standard  Bug:4410902
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Cycle_Count_Header_Id                 NUMBER,
                       X_Organization_Id                       NUMBER,
                       X_Last_Update_Date                      DATE,
                       X_Last_Updated_By                       NUMBER,
                       X_Creation_Date                         DATE,
                       X_Created_By                            NUMBER,
                       X_Last_Update_Login                     NUMBER,
                       X_Cycle_Count_Header_Name               VARCHAR2,
                       X_Inventory_Adjustment_Account          NUMBER,
                       X_Orientation_Code                      NUMBER,
                       X_Abc_Assignment_Group_Id               NUMBER,
                       X_Onhand_Visible_Flag                   NUMBER,
                       X_Days_Until_Late                       NUMBER,
                       X_Autoschedule_Enabled_Flag             NUMBER,
                       X_Schedule_Interval_Time                NUMBER,
                       X_Zero_Count_Flag                       NUMBER,
                       X_Header_Last_Schedule_Date             DATE,
                       X_Header_Next_Schedule_Date             DATE,
                       X_Disable_Date                          DATE,
                       X_Approval_Option_Code                  NUMBER,
                       X_Automatic_Recount_Flag                NUMBER,
                       X_Next_User_Count_Sequence              NUMBER,
                       X_Unscheduled_Count_Entry               NUMBER,
                       X_Cycle_Count_Calendar                  VARCHAR2,
                       X_Calendar_Exception_Set                NUMBER,
                       X_Approval_Tolerance_Positive           NUMBER,
                       X_Approval_Tolerance_Negative           NUMBER,
                       X_Cost_Tolerance_Positive               NUMBER,
                       X_Cost_Tolerance_Negative               NUMBER,
                       X_Hit_Miss_Tolerance_Positive           NUMBER,
                       X_Hit_Miss_Tolerance_Negative           NUMBER,
                       X_Abc_Initialization_Status             NUMBER,
                       X_Description                           VARCHAR2,
                       X_Attribute_Category                    VARCHAR2,
                       X_Attribute1                            VARCHAR2,
                       X_Attribute2                            VARCHAR2,
                       X_Attribute3                            VARCHAR2,
                       X_Attribute4                            VARCHAR2,
                       X_Attribute5                            VARCHAR2,
                       X_Attribute6                            VARCHAR2,
                       X_Attribute7                            VARCHAR2,
                       X_Attribute8                            VARCHAR2,
                       X_Attribute9                            VARCHAR2,
                       X_Attribute10                           VARCHAR2,
                       X_Attribute11                           VARCHAR2,
                       X_Attribute12                           VARCHAR2,
                       X_Attribute13                           VARCHAR2,
                       X_Attribute14                           VARCHAR2,
                       X_Attribute15                           VARCHAR2,
                       X_Maximum_Auto_Recounts                 NUMBER,
                       X_Serial_Count_Option                   NUMBER,
                       X_Serial_Detail_Option                  NUMBER,
                       X_Serial_Adjustment_Option              NUMBER,
                       X_Serial_Discrepancy_Option             NUMBER
                       , X_Container_Enabled_Flag              NUMBER DEFAULT NULL
                       , X_Container_Adjustment_Option         NUMBER DEFAULT NULL
                       , X_Container_Discrepancy_Option        NUMBER DEFAULT NULL
  ) IS
    CURSOR C IS SELECT rowid FROM mtl_cycle_count_headers
                 WHERE cycle_count_header_id = X_Cycle_Count_Header_Id;

   BEGIN
       INSERT INTO mtl_cycle_count_headers(
              cycle_count_header_id,
              organization_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              cycle_count_header_name,
              inventory_adjustment_account,
              orientation_code,
              abc_assignment_group_id,
              onhand_visible_flag,
              days_until_late,
              autoschedule_enabled_flag,
              schedule_interval_time,
              zero_count_flag,
              header_last_schedule_date,
              header_next_schedule_date,
              disable_date,
              approval_option_code,
              automatic_recount_flag,
              next_user_count_sequence,
              unscheduled_count_entry,
              cycle_count_calendar,
              calendar_exception_set,
              approval_tolerance_positive,
              approval_tolerance_negative,
              cost_tolerance_positive,
              cost_tolerance_negative,
              hit_miss_tolerance_positive,
              hit_miss_tolerance_negative,
              abc_initialization_status,
              description,
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
              maximum_auto_recounts,
              serial_count_option,
              serial_detail_option,
              serial_adjustment_option,
              serial_discrepancy_option
              , Container_Enabled_Flag
              , Container_Adjustment_Option
              , Container_Discrepancy_Option
             )
	VALUES (
              X_Cycle_Count_Header_Id,
              X_Organization_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Cycle_Count_Header_Name,
              X_Inventory_Adjustment_Account,
              X_Orientation_Code,
              X_Abc_Assignment_Group_Id,
              X_Onhand_Visible_Flag,
              X_Days_Until_Late,
              X_Autoschedule_Enabled_Flag,
              X_Schedule_Interval_Time,
              X_Zero_Count_Flag,
              X_Header_Last_Schedule_Date,
              X_Header_Next_Schedule_Date,
              X_Disable_Date,
              X_Approval_Option_Code,
              X_Automatic_Recount_Flag,
              X_Next_User_Count_Sequence,
              X_Unscheduled_Count_Entry,
              X_Cycle_Count_Calendar,
              X_Calendar_Exception_Set,
              X_Approval_Tolerance_Positive,
              X_Approval_Tolerance_Negative,
              X_Cost_Tolerance_Positive,
              X_Cost_Tolerance_Negative,
              X_Hit_Miss_Tolerance_Positive,
              X_Hit_Miss_Tolerance_Negative,
              X_Abc_Initialization_Status,
              X_Description,
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
              X_Maximum_Auto_Recounts,
              X_Serial_Count_Option,
              X_Serial_Detail_Option,
              X_Serial_Adjustment_Option,
              X_Serial_Discrepancy_Option
              , X_Container_Enabled_Flag
              , X_Container_Adjustment_Option
              , X_Container_Discrepancy_Option
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
                     X_Organization_Id                  NUMBER,
                     X_Cycle_Count_Header_Name          VARCHAR2,
                     X_Inventory_Adjustment_Account     NUMBER,
                     X_Orientation_Code                 NUMBER,
                     X_Abc_Assignment_Group_Id          NUMBER,
                     X_Onhand_Visible_Flag              NUMBER,
                     X_Days_Until_Late                  NUMBER,
                     X_Autoschedule_Enabled_Flag        NUMBER,
                     X_Schedule_Interval_Time           NUMBER,
                     X_Zero_Count_Flag                  NUMBER,
                     X_Header_Last_Schedule_Date        DATE,
                     X_Header_Next_Schedule_Date        DATE,
                     X_Disable_Date                     DATE,
                     X_Approval_Option_Code             NUMBER,
                     X_Automatic_Recount_Flag           NUMBER,
                     X_Next_User_Count_Sequence         NUMBER,
                     X_Unscheduled_Count_Entry          NUMBER,
                     X_Cycle_Count_Calendar             VARCHAR2,
                     X_Calendar_Exception_Set           NUMBER,
                     X_Approval_Tolerance_Positive      NUMBER,
                     X_Approval_Tolerance_Negative      NUMBER,
                     X_Cost_Tolerance_Positive          NUMBER,
                     X_Cost_Tolerance_Negative          NUMBER,
                     X_Hit_Miss_Tolerance_Positive      NUMBER,
                     X_Hit_Miss_Tolerance_Negative      NUMBER,
                     X_Abc_Initialization_Status        NUMBER,
                     X_Description                      VARCHAR2,
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
                     X_Maximum_Auto_Recounts            NUMBER,
                     X_Serial_Count_Option              NUMBER,
                     X_Serial_Detail_Option             NUMBER,
                     X_Serial_Adjustment_Option         NUMBER,
                     X_Serial_Discrepancy_Option        NUMBER
                     , X_Container_Enabled_Flag       NUMBER DEFAULT NULL
                     , X_Container_Adjustment_Option  NUMBER DEFAULT NULL
                     , X_Container_Discrepancy_Option NUMBER DEFAULT NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   mtl_cycle_count_headers
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
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (Recinfo.cycle_count_header_name =  X_Cycle_Count_Header_Name)
           AND (Recinfo.inventory_adjustment_account =  X_Inventory_Adjustment_Account)
           AND (Recinfo.orientation_code =  X_Orientation_Code)
           AND (   (Recinfo.abc_assignment_group_id =  X_Abc_Assignment_Group_Id)
                OR (    (Recinfo.abc_assignment_group_id IS NULL)
                    AND (X_Abc_Assignment_Group_Id IS NULL)))
           AND (   (Recinfo.onhand_visible_flag =  X_Onhand_Visible_Flag)
                OR (    (Recinfo.onhand_visible_flag IS NULL)
                    AND (X_Onhand_Visible_Flag IS NULL)))
           AND (   (Recinfo.days_until_late =  X_Days_Until_Late)
                OR (    (Recinfo.days_until_late IS NULL)
                    AND (X_Days_Until_Late IS NULL)))
           AND (Recinfo.autoschedule_enabled_flag =  X_Autoschedule_Enabled_Flag)
           AND (   (Recinfo.schedule_interval_time =  X_Schedule_Interval_Time)
                OR (    (Recinfo.schedule_interval_time IS NULL)
                    AND (X_Schedule_Interval_Time IS NULL)))
           AND (   (Recinfo.zero_count_flag =  X_Zero_Count_Flag)
                OR (    (Recinfo.zero_count_flag IS NULL)
                    AND (X_Zero_Count_Flag IS NULL)))
           AND (   (Recinfo.header_last_schedule_date =  X_Header_Last_Schedule_Date)
                OR (    (Recinfo.header_last_schedule_date IS NULL)
                    AND (X_Header_Last_Schedule_Date IS NULL)))
           AND (   (Recinfo.header_next_schedule_date =  X_Header_Next_Schedule_Date)
                OR (    (Recinfo.header_next_schedule_date IS NULL)
                    AND (X_Header_Next_Schedule_Date IS NULL)))
           AND (   (Recinfo.disable_date =  X_Disable_Date)
                OR (    (Recinfo.disable_date IS NULL)
                    AND (X_Disable_Date IS NULL)))
           AND (   (Recinfo.approval_option_code =  X_Approval_Option_Code)
                OR (    (Recinfo.approval_option_code IS NULL)
                    AND (X_Approval_Option_Code IS NULL)))
           AND (   (Recinfo.automatic_recount_flag =  X_Automatic_Recount_Flag)
                OR (    (Recinfo.automatic_recount_flag IS NULL)
                    AND (X_Automatic_Recount_Flag IS NULL)))
           AND (   (Recinfo.next_user_count_sequence =  X_Next_User_Count_Sequence)
                OR (    (Recinfo.next_user_count_sequence IS NULL)
                    AND (X_Next_User_Count_Sequence IS NULL)))
           AND (   (Recinfo.unscheduled_count_entry =  X_Unscheduled_Count_Entry)
                OR (    (Recinfo.unscheduled_count_entry IS NULL)
                    AND (X_Unscheduled_Count_Entry IS NULL)))
           AND (   (Recinfo.cycle_count_calendar =  X_Cycle_Count_Calendar)
                OR (    (Recinfo.cycle_count_calendar IS NULL)
                    AND (X_Cycle_Count_Calendar IS NULL)))
           AND (   (Recinfo.calendar_exception_set =  X_Calendar_Exception_Set)
                OR (    (Recinfo.calendar_exception_set IS NULL)
                    AND (X_Calendar_Exception_Set IS NULL)))
           AND (   (Recinfo.approval_tolerance_positive =  X_Approval_Tolerance_Positive)
                OR (    (Recinfo.approval_tolerance_positive IS NULL)
                    AND (X_Approval_Tolerance_Positive IS NULL)))
           AND (   (Recinfo.approval_tolerance_negative =  X_Approval_Tolerance_Negative)
                OR (    (Recinfo.approval_tolerance_negative IS NULL)
                    AND (X_Approval_Tolerance_Negative IS NULL)))
           AND (   (Recinfo.cost_tolerance_positive =  X_Cost_Tolerance_Positive)
                OR (    (Recinfo.cost_tolerance_positive IS NULL)
                    AND (X_Cost_Tolerance_Positive IS NULL)))
           AND (   (Recinfo.cost_tolerance_negative =  X_Cost_Tolerance_Negative)
                OR (    (Recinfo.cost_tolerance_negative IS NULL)
                    AND (X_Cost_Tolerance_Negative IS NULL)))
           AND (   (Recinfo.hit_miss_tolerance_positive =  X_Hit_Miss_Tolerance_Positive)
                OR (    (Recinfo.hit_miss_tolerance_positive IS NULL)
                    AND (X_Hit_Miss_Tolerance_Positive IS NULL)))
           AND (   (Recinfo.hit_miss_tolerance_negative =  X_Hit_Miss_Tolerance_Negative)
                OR (    (Recinfo.hit_miss_tolerance_negative IS NULL)
                    AND (X_Hit_Miss_Tolerance_Negative IS NULL)))
           AND (   (Recinfo.abc_initialization_status =  X_Abc_Initialization_Status)
                OR (    (Recinfo.abc_initialization_status IS NULL)
                    AND (X_Abc_Initialization_Status IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
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
           AND (   (Recinfo.maximum_auto_recounts =  X_Maximum_Auto_Recounts)
                OR (    (Recinfo.maximum_auto_recounts IS NULL)
                    AND (X_Maximum_Auto_Recounts IS NULL)))
           AND (   (Recinfo.serial_count_option =  X_Serial_Count_Option)
                OR (    (Recinfo.serial_count_option IS NULL)
                    AND ( X_Serial_Count_Option IS NULL)))
           AND (   (Recinfo.serial_detail_option =  X_Serial_Detail_Option)
                OR (    (Recinfo.serial_detail_option IS NULL)
                    AND ( X_Serial_Detail_Option IS NULL)))
           AND (   (Recinfo.serial_adjustment_option =  X_Serial_Adjustment_Option)
                OR (    (Recinfo.serial_adjustment_option IS NULL)
                    AND ( X_Serial_Adjustment_Option IS NULL)))
           AND (   (Recinfo.serial_discrepancy_option =  X_Serial_Discrepancy_Option)
                OR (    (Recinfo.serial_discrepancy_option IS NULL)
                    AND ( X_Serial_Discrepancy_Option IS NULL)))
           AND (   (Recinfo.container_enabled_flag = X_container_enabled_flag)
                OR (    (Recinfo.container_enabled_flag IS NULL)
                    AND ( X_container_enabled_flag IS NULL)))
           AND (   (Recinfo.container_adjustment_option =  X_Container_Adjustment_Option)
                OR (    (Recinfo.container_adjustment_option IS NULL)
                    AND ( X_Container_Adjustment_Option IS NULL)))
           AND (   (Recinfo.container_discrepancy_option =  X_Container_Discrepancy_Option)
                OR (    (Recinfo.container_discrepancy_option IS NULL)
                    AND ( X_Container_Discrepancy_Option IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Cycle_Count_Header_Id          NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Cycle_Count_Header_Name        VARCHAR2,
                       X_Inventory_Adjustment_Account   NUMBER,
                       X_Orientation_Code               NUMBER,
                       X_Abc_Assignment_Group_Id        NUMBER,
                       X_Onhand_Visible_Flag            NUMBER,
                       X_Days_Until_Late                NUMBER,
                       X_Autoschedule_Enabled_Flag      NUMBER,
                       X_Schedule_Interval_Time         NUMBER,
                       X_Zero_Count_Flag                NUMBER,
                       X_Header_Last_Schedule_Date      DATE,
                       X_Header_Next_Schedule_Date      DATE,
                       X_Disable_Date                   DATE,
                       X_Approval_Option_Code           NUMBER,
                       X_Automatic_Recount_Flag         NUMBER,
                       X_Next_User_Count_Sequence       NUMBER,
                       X_Unscheduled_Count_Entry        NUMBER,
                       X_Cycle_Count_Calendar           VARCHAR2,
                       X_Calendar_Exception_Set         NUMBER,
                       X_Approval_Tolerance_Positive    NUMBER,
                       X_Approval_Tolerance_Negative    NUMBER,
                       X_Cost_Tolerance_Positive        NUMBER,
                       X_Cost_Tolerance_Negative        NUMBER,
                       X_Hit_Miss_Tolerance_Positive    NUMBER,
                       X_Hit_Miss_Tolerance_Negative    NUMBER,
                       X_Abc_Initialization_Status      NUMBER,
                       X_Description                    VARCHAR2,
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
                       X_Maximum_Auto_Recounts          NUMBER,
                       X_Serial_Count_Option            NUMBER,
                       X_Serial_Detail_Option           NUMBER,
                       X_Serial_Adjustment_Option       NUMBER,
                       X_Serial_Discrepancy_Option      NUMBER
                       , X_Container_Enabled_Flag       NUMBER DEFAULT NULL
                       , X_Container_Adjustment_Option  NUMBER DEFAULT NULL
                       , X_Container_Discrepancy_Option NUMBER DEFAULT NULL
  ) IS

  BEGIN
    UPDATE mtl_cycle_count_headers
    SET
       cycle_count_header_id           =     X_Cycle_Count_Header_Id,
       organization_id                 =     X_Organization_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       cycle_count_header_name         =     X_Cycle_Count_Header_Name,
       inventory_adjustment_account    =     X_Inventory_Adjustment_Account,
       orientation_code                =     X_Orientation_Code,
       abc_assignment_group_id         =     X_Abc_Assignment_Group_Id,
       onhand_visible_flag             =     X_Onhand_Visible_Flag,
       days_until_late                 =     X_Days_Until_Late,
       autoschedule_enabled_flag       =     X_Autoschedule_Enabled_Flag,
       schedule_interval_time          =     X_Schedule_Interval_Time,
       zero_count_flag                 =     X_Zero_Count_Flag,
       header_last_schedule_date       =     X_Header_Last_Schedule_Date,
       header_next_schedule_date       =     X_Header_Next_Schedule_Date,
       disable_date                    =     X_Disable_Date,
       approval_option_code            =     X_Approval_Option_Code,
       automatic_recount_flag          =     X_Automatic_Recount_Flag,
       next_user_count_sequence        =     X_Next_User_Count_Sequence,
       unscheduled_count_entry         =     X_Unscheduled_Count_Entry,
       cycle_count_calendar            =     X_Cycle_Count_Calendar,
       calendar_exception_set          =     X_Calendar_Exception_Set,
       approval_tolerance_positive     =     X_Approval_Tolerance_Positive,
       approval_tolerance_negative     =     X_Approval_Tolerance_Negative,
       cost_tolerance_positive         =     X_Cost_Tolerance_Positive,
       cost_tolerance_negative         =     X_Cost_Tolerance_Negative,
       hit_miss_tolerance_positive     =     X_Hit_Miss_Tolerance_Positive,
       hit_miss_tolerance_negative     =     X_Hit_Miss_Tolerance_Negative,
       abc_initialization_status       =     X_Abc_Initialization_Status,
       description                     =     X_Description,
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
       maximum_auto_recounts           =     X_Maximum_Auto_Recounts,
       serial_count_option             =     X_Serial_Count_Option,
       serial_detail_option            =     X_Serial_Detail_Option,
       serial_adjustment_option        =     X_Serial_Adjustment_Option,
       serial_discrepancy_option       =     X_Serial_Discrepancy_Option
       , Container_Enabled_Flag        =     X_Container_Enabled_Flag
       , Container_Adjustment_Option   =     X_Container_Adjustment_Option
       , Container_Discrepancy_Option  =     X_Container_Discrepancy_Option
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM mtl_cycle_count_headers
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END MTL_CYCLE_COUNT_HEADERS_PKG;

/
