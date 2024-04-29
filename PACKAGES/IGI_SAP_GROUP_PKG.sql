--------------------------------------------------------
--  DDL for Package IGI_SAP_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SAP_GROUP_PKG" AUTHID CURRENT_USER as
-- $Header: igisiabs.pls 120.5.12000000.1 2007/09/12 11:47:21 mbremkum ship $
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Group_Id                       IN OUT NOCOPY NUMBER,
                       X_Group_Name                     VARCHAR2,
                       X_Org_Id                         NUMBER,  /* bug # 5905278 SIA R12 uptake */
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Group_Id                         NUMBER,
                     X_Group_Name                       VARCHAR2
                    );
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Group_Id                       NUMBER,
                       X_Group_Name                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END IGI_SAP_GROUP_PKG;

 

/
