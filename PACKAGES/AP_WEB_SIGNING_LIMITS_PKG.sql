--------------------------------------------------------
--  DDL for Package AP_WEB_SIGNING_LIMITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_SIGNING_LIMITS_PKG" AUTHID CURRENT_USER as
/* $Header: apiwslts.pls 115.2 2002/11/14 23:11:15 kwidjaja ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Document_Type                  VARCHAR2,
                       X_Employee_Id                    NUMBER,
                       X_Cost_Center                    VARCHAR2,
                       X_Signing_Limit                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Org_Id                         NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Document_Type                    VARCHAR2,
                     X_Employee_Id                      NUMBER,
                     X_Cost_Center                      VARCHAR2,
                     X_Signing_Limit                    NUMBER,
                     X_Org_Id                           NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Document_Type                  VARCHAR2,
                       X_Employee_Id                    NUMBER,
                       X_Cost_Center                    VARCHAR2,
                       X_Signing_Limit                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Org_Id                         NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  PROCEDURE CHECK_UNIQUE (X_Rowid             VARCHAR2,
                          X_Document_Type     VARCHAR2,
                          X_Employee_Id       NUMBER,
			  X_Cost_Center	      VARCHAR2,
                          X_calling_sequence  VARCHAR2);

END AP_WEB_SIGNING_LIMITS_PKG;

 

/
