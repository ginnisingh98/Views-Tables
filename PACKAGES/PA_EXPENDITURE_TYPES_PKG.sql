--------------------------------------------------------
--  DDL for Package PA_EXPENDITURE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXPENDITURE_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: PAXTETSS.pls 120.2 2005/06/16 21:25:57 dlanka noship $ */


  PROCEDURE Insert_Row(X_Rowid               IN OUT NOCOPY VARCHAR2,
                       X_Expenditure_Type           VARCHAR2,
                       X_Last_Update_Date           DATE,
                       X_Last_Updated_By            NUMBER,
                       X_Creation_Date              DATE,
                       X_Created_By                 NUMBER,
                       X_Last_Update_Login          NUMBER,
                       X_Expenditure_Category       VARCHAR2,
                       X_Revenue_Category_Code      VARCHAR2,
                       X_System_Linkage_Function    VARCHAR2,
                       X_Unit_Of_Measure            VARCHAR2,
                       X_Start_Date_Active          DATE,
                       X_Cost_Rate_Flag             VARCHAR2,
                       X_End_Date_Active            DATE,
                       X_Description                VARCHAR2,
                       X_Attribute_Category         VARCHAR2,
                       X_Attribute1                 VARCHAR2,
                       X_Attribute2                 VARCHAR2,
                       X_Attribute3                 VARCHAR2,
                       X_Attribute4                 VARCHAR2,
                       X_Attribute5                 VARCHAR2,
                       X_Attribute6                 VARCHAR2,
                       X_Attribute7                 VARCHAR2,
                       X_Attribute8                 VARCHAR2,
                       X_Attribute9                 VARCHAR2,
                       X_Attribute10                VARCHAR2,
                       X_Attribute11                VARCHAR2,
                       X_Attribute12                VARCHAR2,
                       X_Attribute13                VARCHAR2,
                       X_Attribute14                VARCHAR2,
                       X_Attribute15                VARCHAR2
                     -- MOAC changes
                    -- , X_output_tax_code            VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                        VARCHAR2,
                     X_Expenditure_Type             VARCHAR2,
                     X_Last_Update_Date             DATE,
                     X_Last_Updated_By              NUMBER,
                     X_Creation_Date                DATE,
                     X_Created_By                   NUMBER,
                     X_Last_Update_Login            NUMBER,
                     X_Expenditure_Category         VARCHAR2,
                     X_Revenue_Category_Code        VARCHAR2,
                     X_System_Linkage_Function      VARCHAR2,
                     X_Unit_Of_Measure              VARCHAR2,
                     X_Start_Date_Active            DATE,
                     X_Cost_Rate_Flag               VARCHAR2,
                     X_End_Date_Active              DATE,
                     X_Description                  VARCHAR2,
                     X_Attribute_Category         VARCHAR2,
                     X_Attribute1                 VARCHAR2,
                     X_Attribute2                 VARCHAR2,
                     X_Attribute3                 VARCHAR2,
                     X_Attribute4                 VARCHAR2,
                     X_Attribute5                 VARCHAR2,
                     X_Attribute6                 VARCHAR2,
                     X_Attribute7                 VARCHAR2,
                     X_Attribute8                 VARCHAR2,
                     X_Attribute9                 VARCHAR2,
                     X_Attribute10                VARCHAR2,
                     X_Attribute11                VARCHAR2,
                     X_Attribute12                VARCHAR2,
                     X_Attribute13                VARCHAR2,
                     X_Attribute14                VARCHAR2,
                     X_Attribute15                VARCHAR2
                   -- MOAC changes
                    -- , X_output_tax_code            VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                      VARCHAR2,
                       X_Expenditure_Type           VARCHAR2,
                       X_Last_Update_Date           DATE,
                       X_Last_Updated_By            NUMBER,
                       X_Creation_Date              DATE,
                       X_Created_By                 NUMBER,
                       X_Last_Update_Login          NUMBER,
                       X_Expenditure_Category       VARCHAR2,
                       X_Revenue_Category_Code      VARCHAR2,
                       X_System_Linkage_Function    VARCHAR2,
                       X_Unit_Of_Measure            VARCHAR2,
                       X_Start_Date_Active          DATE,
                       X_Cost_Rate_Flag             VARCHAR2,
                       X_End_Date_Active            DATE,
                       X_Description                VARCHAR2,
                       X_Attribute_Category         VARCHAR2,
                       X_Attribute1                 VARCHAR2,
                       X_Attribute2                 VARCHAR2,
                       X_Attribute3                 VARCHAR2,
                       X_Attribute4                 VARCHAR2,
                       X_Attribute5                 VARCHAR2,
                       X_Attribute6                 VARCHAR2,
                       X_Attribute7                 VARCHAR2,
                       X_Attribute8                 VARCHAR2,
                       X_Attribute9                 VARCHAR2,
                       X_Attribute10                VARCHAR2,
                       X_Attribute11                VARCHAR2,
                       X_Attribute12                VARCHAR2,
                       X_Attribute13                VARCHAR2,
                       X_Attribute14                VARCHAR2,
                       X_Attribute15                VARCHAR2
                      -- MOAC changes
                      -- , X_output_tax_code            VARCHAR2
                      );

END PA_EXPENDITURE_TYPES_PKG;
 

/
