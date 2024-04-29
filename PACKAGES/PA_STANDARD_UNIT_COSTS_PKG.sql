--------------------------------------------------------
--  DDL for Package PA_STANDARD_UNIT_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STANDARD_UNIT_COSTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXSUCSS.pls 120.1 2005/08/09 04:32:05 avajain noship $ jpultorak 06-Jan-03*/


  PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Category_ID              NUMBER,
                       X_Standard_Unit_Cost             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            IN OUT NOCOPY VARCHAR2,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Category_ID              NUMBER,
                       X_Standard_Unit_Cost             NUMBER
                      );

  PROCEDURE Update_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Category_ID              NUMBER,
                       X_Standard_Unit_Cost             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid                          VARCHAR2,
			           X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Category_ID              NUMBER
                       );

END PA_STANDARD_UNIT_COSTS_PKG;

 

/
