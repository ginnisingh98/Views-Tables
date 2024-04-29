--------------------------------------------------------
--  DDL for Package CST_DEPARTMENT_OVERHEADS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_DEPARTMENT_OVERHEADS_PKG" AUTHID CURRENT_USER as
/* $Header: cstpcdos.pls 115.3 2002/11/11 23:20:20 awwang ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Department_Id                  NUMBER,
                       X_Cost_Type_Id                   NUMBER,
                       X_Overhead_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Organization_Id                NUMBER,
                       X_Basis_Type                     NUMBER,
                       X_Rate_Or_Amount                 NUMBER,
                       X_Activity_Id                    NUMBER DEFAULT NULL,
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


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Department_Id                    NUMBER,
                     X_Cost_Type_Id                     NUMBER,
                     X_Overhead_Id                      NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Basis_Type                       NUMBER,
                     X_Rate_Or_Amount                   NUMBER,
                     X_Activity_Id                      NUMBER DEFAULT NULL,
                     X_Attribute_Category               VARCHAR2 DEFAULT NULL,
                     X_Attribute1                       VARCHAR2 DEFAULT NULL,
                     X_Attribute2                       VARCHAR2 DEFAULT NULL,
                     X_Attribute3                       VARCHAR2 DEFAULT NULL,
                     X_Attribute4                       VARCHAR2 DEFAULT NULL,
                     X_Attribute5                       VARCHAR2 DEFAULT NULL,
                     X_Attribute6                       VARCHAR2 DEFAULT NULL,
                     X_Attribute7                       VARCHAR2 DEFAULT NULL,
                     X_Attribute8                       VARCHAR2 DEFAULT NULL,
                     X_Attribute9                       VARCHAR2 DEFAULT NULL,
                     X_Attribute10                      VARCHAR2 DEFAULT NULL,
                     X_Attribute11                      VARCHAR2 DEFAULT NULL,
                     X_Attribute12                      VARCHAR2 DEFAULT NULL,
                     X_Attribute13                      VARCHAR2 DEFAULT NULL,
                     X_Attribute14                      VARCHAR2 DEFAULT NULL,
                     X_Attribute15                      VARCHAR2 DEFAULT NULL
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Department_Id                  NUMBER,
                       X_Cost_Type_Id                   NUMBER,
                       X_Overhead_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Organization_Id                NUMBER,
                       X_Basis_Type                     NUMBER,
                       X_Rate_Or_Amount                 NUMBER,
                       X_Activity_Id                    NUMBER DEFAULT NULL,
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

END CST_DEPARTMENT_OVERHEADS_PKG;

 

/
