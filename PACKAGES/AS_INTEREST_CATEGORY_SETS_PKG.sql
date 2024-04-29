--------------------------------------------------------
--  DDL for Package AS_INTEREST_CATEGORY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_INTEREST_CATEGORY_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: asxldcss.pls 115.5 2002/11/06 00:43:17 appldev ship $ */

PROCEDURE Insert_Row(X_Rowid                         IN OUT VARCHAR2,
                     X_Category_Set_Id                      NUMBER,
                     X_Interest_Type_Id                     NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Enabled_Flag                         VARCHAR2 DEFAULT NULL
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Category_Set_Id                        NUMBER,
                   X_Interest_Type_Id                       NUMBER,
                   X_Enabled_Flag                           VARCHAR2 DEFAULT NULL
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Category_Set_Id                     NUMBER,
                     X_Interest_Type_Id                    NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Enabled_Flag                        VARCHAR2 DEFAULT NULL
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END AS_INTEREST_CATEGORY_SETS_PKG;

 

/
