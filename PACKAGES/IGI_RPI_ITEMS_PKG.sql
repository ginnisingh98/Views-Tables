--------------------------------------------------------
--  DDL for Package IGI_RPI_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_RPI_ITEMS_PKG" AUTHID CURRENT_USER AS
--- $Header: igiritms.pls 120.3.12000000.1 2007/08/31 05:52:47 mbremkum ship $
  PROCEDURE Insert_Row( X_Item_Id                     IN NUMBER
                      , X_Set_Of_Books_Id             IN NUMBER
                      , X_Item_Code                   IN VARCHAR2
                      , X_Price                       IN NUMBER
                      , X_Price_Effective_Date        IN DATE
                      , X_Unit_Of_Measure             IN VARCHAR2
                      , X_Start_Effective_Date        IN DATE
                      , X_Creation_Date               IN DATE
                      , X_Created_By                  IN NUMBER
                      , X_Last_Update_Date            IN DATE
                      , X_Last_Updated_By             IN NUMBER
                      , X_Last_Update_Login           IN NUMBER
                      , X_Revised_Price_Eff_Date      IN DATE
                      , X_Revised_Price               IN NUMBER
                      , X_Description                 IN VARCHAR2
                      , X_Vat_Tax_Id                  IN NUMBER
                      , X_Revenue_Code_Combination_Id IN NUMBER
                      , X_Inactive_Date               IN DATE
                      , X_Enabled_Flag                IN VARCHAR2
			/*Added for MOAC Impact Bug No 5905216*/
                      , X_Org_Id		      IN NUMBER
                      );

  PROCEDURE Update_Row( X_Item_Id                     IN NUMBER
                      , X_Set_Of_Books_Id             IN NUMBER
                      , X_Item_Code                   IN VARCHAR2
                      , X_Price                       IN NUMBER
                      , X_Price_Effective_Date        IN DATE
                      , X_Unit_Of_Measure             IN VARCHAR2
                      , X_Start_Effective_Date        IN DATE
                      , X_Last_Update_Date            IN DATE
                      , X_Last_Updated_By             IN NUMBER
                      , X_Last_Update_Login           IN NUMBER
                      , X_Revised_Price_Eff_Date      IN DATE
                      , X_Revised_Price               IN NUMBER
                      , X_Description                 IN VARCHAR2
                      , X_Vat_Tax_Id                  IN NUMBER
                      , X_Revenue_Code_Combination_Id IN NUMBER
                      , X_Inactive_Date               IN DATE
                      , X_Enabled_Flag                IN VARCHAR2
                      );

  PROCEDURE Delete_Row( X_Item_Id IN NUMBER);

END IGI_RPI_ITEMS_PKG;

 

/
