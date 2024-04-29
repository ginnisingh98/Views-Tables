--------------------------------------------------------
--  DDL for Package MTL_CYCLE_COUNT_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CYCLE_COUNT_HEADERS_PKG" AUTHID CURRENT_USER as
/* $Header: INVADCYS.pls 120.1 2005/06/19 05:35:23 appldev  $ */

--Added NOCOPY hint to X_Rowid IN OUT parameter to comply with
--GSCC File.Sql.39 standard  Bug:4410902
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY  VARCHAR2,
                       X_Cycle_Count_Header_Id                  NUMBER,
                       X_Organization_Id                        NUMBER,
                       X_Last_Update_Date                       DATE,
                       X_Last_Updated_By                        NUMBER,
                       X_Creation_Date                          DATE,
                       X_Created_By                             NUMBER,
                       X_Last_Update_Login                      NUMBER,
                       X_Cycle_Count_Header_Name                VARCHAR2,
                       X_Inventory_Adjustment_Account           NUMBER,
                       X_Orientation_Code                       NUMBER,
                       X_Abc_Assignment_Group_Id                NUMBER,
                       X_Onhand_Visible_Flag                    NUMBER,
                       X_Days_Until_Late                        NUMBER,
                       X_Autoschedule_Enabled_Flag              NUMBER,
                       X_Schedule_Interval_Time                 NUMBER,
                       X_Zero_Count_Flag                        NUMBER,
                       X_Header_Last_Schedule_Date              DATE,
                       X_Header_Next_Schedule_Date              DATE,
                       X_Disable_Date                           DATE,
                       X_Approval_Option_Code                   NUMBER,
                       X_Automatic_Recount_Flag                 NUMBER,
                       X_Next_User_Count_Sequence               NUMBER,
                       X_Unscheduled_Count_Entry                NUMBER,
                       X_Cycle_Count_Calendar                   VARCHAR2,
                       X_Calendar_Exception_Set                 NUMBER,
                       X_Approval_Tolerance_Positive            NUMBER,
                       X_Approval_Tolerance_Negative            NUMBER,
                       X_Cost_Tolerance_Positive                NUMBER,
                       X_Cost_Tolerance_Negative                NUMBER,
                       X_Hit_Miss_Tolerance_Positive            NUMBER,
                       X_Hit_Miss_Tolerance_Negative            NUMBER,
                       X_Abc_Initialization_Status              NUMBER,
                       X_Description                            VARCHAR2,
                       X_Attribute_Category                     VARCHAR2,
                       X_Attribute1                             VARCHAR2,
                       X_Attribute2                             VARCHAR2,
                       X_Attribute3                             VARCHAR2,
                       X_Attribute4                             VARCHAR2,
                       X_Attribute5                             VARCHAR2,
                       X_Attribute6                             VARCHAR2,
                       X_Attribute7                             VARCHAR2,
                       X_Attribute8                             VARCHAR2,
                       X_Attribute9                             VARCHAR2,
                       X_Attribute10                            VARCHAR2,
                       X_Attribute11                            VARCHAR2,
                       X_Attribute12                            VARCHAR2,
                       X_Attribute13                            VARCHAR2,
                       X_Attribute14                            VARCHAR2,
                       X_Attribute15                            VARCHAR2,
                       X_Maximum_Auto_Recounts                  NUMBER,
                       X_Serial_Count_Option                    NUMBER,
                       X_Serial_Detail_Option                   NUMBER,
                       X_Serial_Adjustment_Option               NUMBER,
                       X_Serial_Discrepancy_Option              NUMBER

                      -- WMS
                       , X_Container_Enabled_Flag               NUMBER DEFAULT NULL
                       , X_Container_Adjustment_Option          NUMBER DEFAULT NULL
                       , X_Container_Discrepancy_Option         NUMBER DEFAULT NULL
                      );

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

                      -- WMS
                     , X_Container_Enabled_Flag       NUMBER DEFAULT NULL
                     , X_Container_Adjustment_Option  NUMBER DEFAULT NULL
                     , X_Container_Discrepancy_Option NUMBER DEFAULT NULL
                    );


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

                      -- WMS
                       , X_Container_Enabled_Flag       NUMBER DEFAULT NULL
                       , X_Container_Adjustment_Option  NUMBER DEFAULT NULL
                       , X_Container_Discrepancy_Option NUMBER DEFAULT NULL
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END MTL_CYCLE_COUNT_HEADERS_PKG;

 

/
