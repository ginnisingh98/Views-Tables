--------------------------------------------------------
--  DDL for Package BOM_DEPT_RES_INSTANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEPT_RES_INSTANCES_PKG" AUTHID CURRENT_USER as
/* $Header: bompdris.pls 115.2 2002/11/19 03:13:28 lnarveka ship $ */


PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Instance_Id                    NUMBER,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Serial_Number                  VARCHAR2,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                     X_Attribute1                     VARCHAR2 DEFAULT NULL,
                     X_Attribute2                     VARCHAR2 DEFAULT NULL,
                     X_Attribute3                     VARCHAR2 DEFAULT NULL,
                     X_Attribute4                     VARCHAR2 DEFAULT NULL,
                     X_Attribute5                     VARCHAR2 DEFAULT NULL,
                     X_Attribute6                     VARCHAR2 DEFAULT NULL,
                     X_Attribute7                     VARCHAR2 DEFAULT NULL,
                     X_Attribute8                     VARCHAR2 DEFAULT NULL,
                     X_Attribute9                     VARCHAR2 DEFAULT NULL,
                     X_Attribute10                    VARCHAR2 DEFAULT NULL,
                     X_Attribute11                    VARCHAR2 DEFAULT NULL,
                     X_Attribute12                    VARCHAR2 DEFAULT NULL,
                     X_Attribute13                    VARCHAR2 DEFAULT NULL,
                     X_Attribute14                    VARCHAR2 DEFAULT NULL,
                     X_Attribute15                    VARCHAR2 DEFAULT NULL
                    );


PROCEDURE Lock_Row(  X_Rowid                  	      VARCHAR2,
                     X_Instance_Id                    NUMBER,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Serial_Number                  VARCHAR2,
                     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                     X_Attribute1                     VARCHAR2 DEFAULT NULL,
                     X_Attribute2                     VARCHAR2 DEFAULT NULL,
                     X_Attribute3                     VARCHAR2 DEFAULT NULL,
                     X_Attribute4                     VARCHAR2 DEFAULT NULL,
                     X_Attribute5                     VARCHAR2 DEFAULT NULL,
                     X_Attribute6                     VARCHAR2 DEFAULT NULL,
                     X_Attribute7                     VARCHAR2 DEFAULT NULL,
                     X_Attribute8                     VARCHAR2 DEFAULT NULL,
                     X_Attribute9                     VARCHAR2 DEFAULT NULL,
                     X_Attribute10                    VARCHAR2 DEFAULT NULL,
                     X_Attribute11                    VARCHAR2 DEFAULT NULL,
                     X_Attribute12                    VARCHAR2 DEFAULT NULL,
                     X_Attribute13                    VARCHAR2 DEFAULT NULL,
                     X_Attribute14                    VARCHAR2 DEFAULT NULL,
                     X_Attribute15                    VARCHAR2 DEFAULT NULL
                    );

PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                     X_Instance_Id                    NUMBER,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Serial_Number                  VARCHAR2,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                     X_Attribute1                     VARCHAR2 DEFAULT NULL,
                     X_Attribute2                     VARCHAR2 DEFAULT NULL,
                     X_Attribute3                     VARCHAR2 DEFAULT NULL,
                     X_Attribute4                     VARCHAR2 DEFAULT NULL,
                     X_Attribute5                     VARCHAR2 DEFAULT NULL,
                     X_Attribute6                     VARCHAR2 DEFAULT NULL,
                     X_Attribute7                     VARCHAR2 DEFAULT NULL,
                     X_Attribute8                     VARCHAR2 DEFAULT NULL,
                     X_Attribute9                     VARCHAR2 DEFAULT NULL,
                     X_Attribute10                    VARCHAR2 DEFAULT NULL,
                     X_Attribute11                    VARCHAR2 DEFAULT NULL,
                     X_Attribute12                    VARCHAR2 DEFAULT NULL,
                     X_Attribute13                    VARCHAR2 DEFAULT NULL,
                     X_Attribute14                    VARCHAR2 DEFAULT NULL,
                     X_Attribute15                    VARCHAR2 DEFAULT NULL
                    );


PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE Check_Unique(X_Rowid          VARCHAR2,
                       X_Instance_Id    NUMBER,
                       X_Department_Id  NUMBER,
                       X_Resource_Id    NUMBER,
                       X_Serial_Number  VARCHAR2);


END BOM_DEPT_RES_INSTANCES_PKG;

 

/
