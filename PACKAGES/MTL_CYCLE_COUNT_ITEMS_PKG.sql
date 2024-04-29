--------------------------------------------------------
--  DDL for Package MTL_CYCLE_COUNT_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CYCLE_COUNT_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: INVADC2S.pls 120.1 2005/06/19 00:53:23 appldev  $ */
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
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Cycle_Count_Header_Id            NUMBER,
                     X_Inventory_Item_Id                NUMBER,
                     X_Abc_Class_Id                     NUMBER,
                     X_Item_Last_Schedule_Date          DATE,
                     X_Schedule_Order                   NUMBER,
                     X_Approval_Tolerance_Positive      NUMBER,
                     X_Approval_Tolerance_Negative      NUMBER,
                     X_Control_Group_Flag               NUMBER
                    );


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
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END MTL_CYCLE_COUNT_ITEMS_PKG;

 

/
