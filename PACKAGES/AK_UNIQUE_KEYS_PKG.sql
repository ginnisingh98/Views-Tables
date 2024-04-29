--------------------------------------------------------
--  DDL for Package AK_UNIQUE_KEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_UNIQUE_KEYS_PKG" AUTHID CURRENT_USER as
/* $Header: AKDOBPKS.pls 120.2 2005/09/29 13:59:57 tshort ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Unique_Key_Name               VARCHAR2,
                       X_Database_Object_Name                      VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
		       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category		VARCHAR2,
                       X_Attribute1			VARCHAR2,
                       X_Attribute2			VARCHAR2,
                       X_Attribute3			VARCHAR2,
                       X_Attribute4			VARCHAR2,
                       X_Attribute5			VARCHAR2,
                       X_Attribute6			VARCHAR2,
                       X_Attribute7			VARCHAR2,
                       X_Attribute8			VARCHAR2,
                       X_Attribute9			VARCHAR2,
                       X_Attribute10			VARCHAR2,
                       X_Attribute11			VARCHAR2,
                       X_Attribute12			VARCHAR2,
                       X_Attribute13			VARCHAR2,
                       X_Attribute14			VARCHAR2,
                       X_Attribute15			VARCHAR2
		      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Unique_Key_Name                 VARCHAR2,
                     X_Database_Object_Name                        VARCHAR2,
                     X_Application_Id                   NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Unique_Key_Name               VARCHAR2,
                       X_Database_Object_Name                      VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category		VARCHAR2,
                       X_Attribute1			VARCHAR2,
                       X_Attribute2			VARCHAR2,
                       X_Attribute3			VARCHAR2,
                       X_Attribute4			VARCHAR2,
                       X_Attribute5			VARCHAR2,
                       X_Attribute6			VARCHAR2,
                       X_Attribute7			VARCHAR2,
                       X_Attribute8			VARCHAR2,
                       X_Attribute9			VARCHAR2,
                       X_Attribute10			VARCHAR2,
                       X_Attribute11			VARCHAR2,
                       X_Attribute12			VARCHAR2,
                       X_Attribute13			VARCHAR2,
                       X_Attribute14			VARCHAR2,
                       X_Attribute15			VARCHAR2
		      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END AK_UNIQUE_KEYS_PKG;

 

/
