--------------------------------------------------------
--  DDL for Package JTF_PC_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PC_CATEGORIES_PKG" AUTHID CURRENT_USER AS
/*$Header: jtfpjpcs.pls 120.2 2005/08/18 22:54:53 stopiwal ship $*/

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                       X_Category_Id                    NUMBER,
                       X_Internal_Name                  VARCHAR2 DEFAULT NULL,
                       X_Start_Date_Effective           DATE,
                       X_End_Date_Effective             DATE DEFAULT NULL,
                       X_Category_Name                  VARCHAR2,
                       X_Category_Description           VARCHAR2 DEFAULT NULL,
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
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER DEFAULT NULL
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                       X_Category_Id                    NUMBER,
                       X_Internal_Name                  VARCHAR2 DEFAULT NULL,
                       X_Start_Date_Effective           DATE,
                       X_End_Date_Effective             DATE DEFAULT NULL,
                       X_Category_Name                  VARCHAR2,
                       X_Category_Description           VARCHAR2 DEFAULT NULL,
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


  -- syoung: added x_return_status.
  PROCEDURE Update_Row(X_Category_Id                    NUMBER,
                       X_Internal_Name                  VARCHAR2 DEFAULT NULL,
                       X_Start_Date_Effective           DATE,
                       X_End_Date_Effective             DATE DEFAULT NULL,
                       X_Category_Name                  VARCHAR2,
                       X_Category_Description           VARCHAR2 DEFAULT NULL,
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
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Object_Version_Number          NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER DEFAULT NULL
                      );

  PROCEDURE Delete_Row( X_Category_Id	NUMBER,
                        X_Object_Version_Number  NUMBER);

  PROCEDURE ADD_LANGUAGE;

  PROCEDURE LOAD_ROW  (X_Category_Id                    NUMBER,
                       X_Internal_Name                  VARCHAR2 DEFAULT NULL,
                       X_Start_Date_Effective           DATE,
                       X_End_Date_Effective             DATE DEFAULT NULL,
                       X_Category_Name                  VARCHAR2,
                       X_Category_Description           VARCHAR2 DEFAULT NULL,
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
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Owner                          VARCHAR2
                      );

  PROCEDURE TRANSLATE_ROW(X_Category_Id                      IN NUMBER,
                          X_Category_Name                    IN VARCHAR2,
                          X_Category_Description             IN VARCHAR2,
                          X_Owner                            IN VARCHAR2
                      );


END JTF_PC_CATEGORIES_PKG;

 

/
