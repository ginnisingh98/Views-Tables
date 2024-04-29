--------------------------------------------------------
--  DDL for Package E_CHANGES_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."E_CHANGES_INT_PKG" AUTHID CURRENT_USER as
/* $Header: bompieis.pls 115.1 99/07/16 05:48:23 porting ship $ */

Procedure Initialize(
  P_Organization in number,
  P_Locator out number,
  P_New out varchar2,
  P_Update out varchar2,
  P_DefaultCategory out varchar2,
  P_DefaultCatStruct out number,
  P_Eng_Install out varchar2);

-- Values needed on form startup

PROCEDURE After_Delete (X_Org_Id 			NUMBER,
                        X_Change_Notice    		VARCHAR2);

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Change_Order_Type_Id           NUMBER,
                       X_Responsible_Organization_Id    NUMBER);

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Change_Notice                    VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Description                      VARCHAR2,
                     X_Change_Order_Type_Id             NUMBER,
                     X_Responsible_Organization_Id      NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Change_Order_Type_Id           NUMBER,
                       X_Responsible_Organization_Id    NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END E_CHANGES_INT_PKG;

 

/
