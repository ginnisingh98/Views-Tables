--------------------------------------------------------
--  DDL for Package MTL_CST_TXN_COST_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CST_TXN_COST_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: CSTEACUS.pls 115.3 2002/11/08 18:42:35 awwang ship $ */


  PROCEDURE Insert_Row(X_Rowid			IN OUT NOCOPY  VARCHAR2,
                       X_Transaction_Id                 NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Cost_Element_Id                NUMBER,
                       X_Level_Type                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_New_Average_Cost               NUMBER DEFAULT NULL,
                       X_Percentage_Change              NUMBER DEFAULT NULL,
                       X_Value_Change                   NUMBER DEFAULT NULL,
		       X_Transaction_Cost		NUMBER
                      );


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Cost_Element_Id                NUMBER,
                       X_Level_Type                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_New_Average_Cost               NUMBER DEFAULT NULL,
                       X_Percentage_Change              NUMBER DEFAULT NULL,
                       X_Value_Change                   NUMBER DEFAULT NULL
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);
  PROCEDURE Delete_Rows(X_transaction_id NUMBER);

END MTL_CST_TXN_COST_DETAILS_PKG;

 

/
