--------------------------------------------------------
--  DDL for Package Body MTL_CST_TXN_COST_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CST_TXN_COST_DETAILS_PKG" as
/* $Header: CSTEACUB.pls 115.3 2003/08/25 04:29:46 anjgupta ship $ */

  PROCEDURE Insert_Row(
		       X_Rowid 			IN OUT NOCOPY  VARCHAR2,
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
  ) IS

   BEGIN

       X_Rowid := 0;

       INSERT INTO mtl_cst_txn_cost_details(
              transaction_id,
              organization_id,
              cost_element_id,
              level_type,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              inventory_item_id,
              new_average_cost,
              percentage_change,
              value_change,
	      transaction_cost
             ) VALUES (
              X_Transaction_Id,
              X_Organization_Id,
              X_Cost_Element_Id,
              X_Level_Type,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Inventory_Item_Id,
              X_New_Average_Cost,
              X_Percentage_Change,
              X_Value_Change,
	      X_Transaction_Cost
             );

 EXCEPTION
 WHEN others then
   X_Rowid := -1;

  END Insert_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Cost_Element_Id                NUMBER,
                       X_Level_Type                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_New_Average_Cost               NUMBER DEFAULT NULL,
                       X_Percentage_Change              NUMBER DEFAULT NULL,
                       X_Value_Change                   NUMBER DEFAULT NULL

  ) IS
  BEGIN
    UPDATE mtl_cst_txn_cost_details
    SET
       cost_element_id                 =     X_Cost_Element_Id,
       level_type                      =     X_Level_Type,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       new_average_cost                =     X_New_Average_Cost,
       percentage_change               =     X_Percentage_Change,
       value_change                    =     X_Value_Change
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM mtl_cst_txn_cost_details
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE Delete_Rows(X_Transaction_Id NUMBER)
  IS BEGIN
    DELETE FROM mtl_cst_txn_cost_details
    WHERE transaction_id = X_Transaction_Id;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Rows;

END MTL_CST_TXN_COST_DETAILS_PKG;

/
