--------------------------------------------------------
--  DDL for Package WMS_DEPT_SUBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DEPT_SUBS_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSDPZNS.pls 120.1 2005/06/20 05:58:47 appldev ship $ */
--
PROCEDURE INSERT_ROW
   (X_Rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Organization_Id		     NUMBER,
    X_subinventory_code              VARCHAR2 ,
    X_department_Id		     NUMBER,
    X_Effective_From_date            DATE DEFAULT NULL,
    X_Effective_To_date              DATE DEFAULT NULL,
    X_Created_By                     NUMBER,
    X_Creation_Date                  DATE,
    X_Last_Updated_By                NUMBER,
    X_Last_Update_Date               DATE,
    X_Last_Update_Login              NUMBER DEFAULT NULL,
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
    X_Attribute_Category             VARCHAR2 DEFAULT NULL
  );
--
PROCEDURE LOCK_ROW
   (X_Rowid                          IN VARCHAR2,
    X_Organization_Id		     NUMBER,
    X_subinventory_code              VARCHAR2 ,
    X_department_Id		     NUMBER,
    X_Effective_From_date            DATE DEFAULT NULL,
    X_Effective_To_date              DATE DEFAULT NULL,
    X_Created_By                     NUMBER,
    X_Creation_Date                  DATE,
    X_Last_Updated_By                NUMBER,
    X_Last_Update_Date               DATE,
    X_Last_Update_Login              NUMBER DEFAULT NULL,
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
    X_Attribute_Category             VARCHAR2 DEFAULT NULL
  );
--
PROCEDURE update_row
   (X_Rowid                          IN VARCHAR2,
    X_Organization_Id		     NUMBER,
    X_subinventory_code              VARCHAR2 ,
    X_department_Id		     NUMBER,
    X_Effective_From_date            DATE DEFAULT NULL,
    X_Effective_To_date              DATE DEFAULT NULL,
    X_Created_By                     NUMBER,
    X_Creation_Date                  DATE,
    X_Last_Updated_By                NUMBER,
    X_Last_Update_Date               DATE,
    X_Last_Update_Login              NUMBER DEFAULT NULL,
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
    X_Attribute_Category             VARCHAR2 DEFAULT NULL
  );
--
PROCEDURE DELETE_ROW (
   x_rowid IN VARCHAR2
  );
END WMS_DEPT_SUBS_PKG;

 

/
