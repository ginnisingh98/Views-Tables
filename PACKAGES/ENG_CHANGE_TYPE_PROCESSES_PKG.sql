--------------------------------------------------------
--  DDL for Package ENG_CHANGE_TYPE_PROCESSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_TYPE_PROCESSES_PKG" AUTHID CURRENT_USER as
/* $Header: engpects.pls 120.0 2005/05/26 19:04:44 appldev noship $ */

  PROCEDURE Check_Unique(X_Rowid varchar2,
			 X_change_order_type_id number,
                         X_Eng_Change_Priority_Code varchar2,
                         X_Organization_Id number);

  PROCEDURE Insert_Row(X_Rowid                   IN OUT  NOCOPY VARCHAR2,
                       X_Change_Order_Type_Id           NUMBER,
                       X_Eng_Change_Priority_Code       VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Process_Name                   VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Change_Order_Type_Id             NUMBER,
                     X_Eng_Change_Priority_Code         VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Process_Name                     VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Change_Order_Type_Id           NUMBER,
                       X_Eng_Change_Priority_Code       VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Process_Name                   VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END ENG_CHANGE_TYPE_PROCESSES_PKG;

 

/
