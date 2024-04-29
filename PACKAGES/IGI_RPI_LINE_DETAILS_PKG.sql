--------------------------------------------------------
--  DDL for Package IGI_RPI_LINE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_RPI_LINE_DETAILS_PKG" AUTHID CURRENT_USER as
--- $Header: igirldes.pls 120.4.12000000.1 2007/08/31 05:53:02 mbremkum ship $

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Standing_Charge_Id             NUMBER,
                       X_Line_Item_Id                   IN OUT NOCOPY NUMBER,
                       X_Charge_Item_Number             NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Price                          NUMBER,
                       X_Quantity                       NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Current_Effective_Date         DATE,
                       X_Description                    VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Revised_Effective_Date         DATE,
                       X_Revised_Price                  NUMBER,
                       X_Previous_Price                 NUMBER,
                       X_Previous_Effective_date        DATE,
                       X_Vat_Tax_Id                     NUMBER,
                       X_Revenue_Code_Combination_Id    NUMBER,
                       X_Receivable_Code_Combo_Id       NUMBER,
                       X_Additional_Reference           VARCHAR2,
                       X_Accounting_rule_id             NUMBER,
                       X_Start_date                     DATE,
                       X_Duration                       NUMBER,
		       X_Legal_Entity_Id		NUMBER,	--Added for MOAC Impact Bug No 5905216
		       X_Org_Id				NUMBER	--Added for MOAC Impact Bug No 5905216
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Standing_Charge_Id               NUMBER,
                     X_Line_Item_Id                     NUMBER,
                     X_Charge_Item_Number               NUMBER,
                     X_Item_Id                          NUMBER,
                     X_Price                            NUMBER,
                     X_Quantity                         NUMBER,
                     X_Period_Name                      VARCHAR2,
                     X_Current_Effective_Date           DATE,
                     X_Description                      VARCHAR2,
                     X_Revised_Effective_Date           DATE,
                     X_Revised_Price                    NUMBER,
                     X_Previous_Price                   NUMBER,
                     X_Previous_Effective_date          DATE,
                     X_Vat_Tax_Id                       NUMBER,
                     X_Revenue_Code_Combination_Id      NUMBER,
                     X_Receivable_Code_Combo_Id         NUMBER,
                     X_Additional_Reference             VARCHAR2,
                     X_Accounting_rule_id             	NUMBER,
                     X_Start_date                     	DATE,
                     X_Duration                       	NUMBER,
--		     X_Legal_Entity_Id			NUMBER,  --Added for MOAC Impact Bug No 5905216
		     X_Org_Id				NUMBER   --Added for MOAC Impact Bug No 5905216
                    );


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Standing_Charge_Id             NUMBER,
                       X_Line_Item_Id                   NUMBER,
                       X_Charge_Item_Number             NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Price                          NUMBER,
                       X_Quantity                       NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Current_Effective_Date         DATE,
                       X_Description                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Revised_Effective_Date         DATE,
                       X_Revised_Price                  NUMBER,
                       X_Previous_Price                 NUMBER,
                       X_Previous_Effective_Date        DATE,
                       X_Vat_Tax_Id                     NUMBER,
                       X_Revenue_Code_Combination_Id    NUMBER,
                       X_Receivable_Code_Combo_Id       NUMBER,
                       X_Additional_Reference           VARCHAR2,
                       X_Accounting_rule_id             NUMBER,
                       X_Start_date                     DATE,
                       X_Duration                       NUMBER,
		       X_Legal_Entity_Id		NUMBER,	 --Added for MOAC Impact Bug No 5905216
		       X_Org_Id				NUMBER   --Added for MOAC Impact Bug No 5905216
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END IGI_RPI_LINE_DETAILS_PKG;

 

/
