--------------------------------------------------------
--  DDL for Package PA_PROJECT_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_CLASSES_PKG" AUTHID CURRENT_USER as
/* $Header: PAXCLASS.pls 120.2 2005/08/19 17:11:19 mwasowic ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_object_id                      NUMBER,
                       X_object_type                    VARCHAR2,
                       X_Class_Category                 VARCHAR2,
                       X_Class_Code                     VARCHAR2,
                       X_code_percentage                NUMBER,
                       X_attribute_category             VARCHAR2,
                       X_attribute1                     VARCHAR2,
                       X_attribute2                     VARCHAR2,
                       X_attribute3                     VARCHAR2,
                       X_attribute4                     VARCHAR2,
                       X_attribute5                     VARCHAR2,
                       X_attribute6                     VARCHAR2,
                       X_attribute7                     VARCHAR2,
                       X_attribute8                     VARCHAR2,
                       X_attribute9                     VARCHAR2,
                       X_attribute10                    VARCHAR2,
                       X_attribute11                    VARCHAR2,
                       X_attribute12                    VARCHAR2,
                       X_attribute13                    VARCHAR2,
                       X_attribute14                    VARCHAR2,
                       X_attribute15                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
  ) ;

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_object_id                        NUMBER,
                     X_object_type                      VARCHAR2,
                     X_Class_Category                   VARCHAR2,
                     X_Class_Code                       VARCHAR2
  );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_object_id                      NUMBER,
                       X_object_type                    VARCHAR2,
                       X_Class_Category                 VARCHAR2,
                       X_Class_Code                     VARCHAR2,
                       X_code_percentage                NUMBER,
                       X_attribute_category             VARCHAR2,
                       X_attribute1                     VARCHAR2,
                       X_attribute2                     VARCHAR2,
                       X_attribute3                     VARCHAR2,
                       X_attribute4                     VARCHAR2,
                       X_attribute5                     VARCHAR2,
                       X_attribute6                     VARCHAR2,
                       X_attribute7                     VARCHAR2,
                       X_attribute8                     VARCHAR2,
                       X_attribute9                     VARCHAR2,
                       X_attribute10                    VARCHAR2,
                       X_attribute11                    VARCHAR2,
                       X_attribute12                    VARCHAR2,
                       X_attribute13                    VARCHAR2,
                       X_attribute14                    VARCHAR2,
                       X_attribute15                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_record_version_number          NUMBER
  );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) ;


END PA_PROJECT_CLASSES_PKG;

 

/
