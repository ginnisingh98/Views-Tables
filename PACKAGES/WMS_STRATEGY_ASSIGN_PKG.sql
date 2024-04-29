--------------------------------------------------------
--  DDL for Package WMS_STRATEGY_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_STRATEGY_ASSIGN_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSPPSAS.pls 120.1 2005/06/20 02:48:11 appldev ship $ */
--
PROCEDURE INSERT_ROW
   (X_Rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Organization_Id		     NUMBER,
    X_Object_Type_Code               NUMBER,
    X_Object_Name                    VARCHAR2 DEFAULT NULL,
    X_Object_Id			     NUMBER,
    X_PK1_Value			     VARCHAR2,
    X_PK2_Value                      VARCHAR2 DEFAULT NULL,
    X_PK3_Value                      VARCHAR2 DEFAULT NULL,
    X_PK4_Value                      VARCHAR2 DEFAULT NULL,
    X_PK5_Value                      VARCHAR2 DEFAULT NULL,
    X_Strategy_Id		     NUMBER,
    X_Strategy_Type_Code             NUMBER,
    X_Effective_From		     DATE DEFAULT NULL,
    X_Effective_To                   DATE DEFAULT NULL,
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
    X_Attribute_Category             VARCHAR2 DEFAULT NULL,
    X_Date_Type_Code		     VARCHAR2 DEFAULT NULL,
    X_Date_Type_Lookup_Type	     VARCHAR2 DEFAULT NULL,
    X_Date_Type_From		     NUMBER DEFAULT NULL,
    X_Date_Type_To		     NUMBER DEFAULT NULL,
    X_Sequence_Number		     NUMBER DEFAULT NULL
  );
--
PROCEDURE LOCK_ROW
    (X_Rowid                            VARCHAR2,
     X_Organization_Id			NUMBER,
     X_Object_Type_Code               	NUMBER,
     X_Object_Name                	VARCHAR2 DEFAULT NULL,
     X_Object_Id			NUMBER,
     X_PK1_Value			VARCHAR2,
     X_PK2_Value                      	VARCHAR2 DEFAULT NULL,
     X_PK3_Value                      	VARCHAR2 DEFAULT NULL,
     X_PK4_Value                      	VARCHAR2 DEFAULT NULL,
     X_PK5_Value                      	VARCHAR2 DEFAULT NULL,
     X_Strategy_Id			NUMBER,
     X_Strategy_Type_Code               NUMBER,
     X_Effective_From			DATE DEFAULT NULL,
     X_Effective_To                 	DATE DEFAULT NULL,
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
     X_Attribute15                      VARCHAR2 DEFAULT NULL,
     X_Attribute_Category               VARCHAR2 DEFAULT NULL,
     X_Date_Type_Code                   VARCHAR2 DEFAULT NULL,
     X_Date_Type_Lookup_Type            VARCHAR2 DEFAULT NULL,
     X_Date_Type_From                   NUMBER DEFAULT NULL,
     X_Date_Type_To                     NUMBER DEFAULT NULL,
     X_Sequence_Number		        NUMBER DEFAULT NULL
  );
--
PROCEDURE update_row
    (X_Rowid                          VARCHAR2,
     X_Organization_Id		NUMBER,
     X_Object_Type_Code               NUMBER,
     X_Object_Name                	VARCHAR2 DEFAULT NULL,
     X_Object_Id			NUMBER,
     X_PK1_Value			VARCHAR2,
     X_PK2_Value                      VARCHAR2 DEFAULT NULL,
     X_PK3_Value                      VARCHAR2 DEFAULT NULL,
     X_PK4_Value                      VARCHAR2 DEFAULT NULL,
     X_PK5_Value                      VARCHAR2 DEFAULT NULL,
     X_Strategy_Id			NUMBER,
     X_Strategy_Type_Code             NUMBER,
     X_Effective_From			DATE DEFAULT NULL,
     X_Effective_To                 	DATE DEFAULT NULL,
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
     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
     X_Date_Type_Code                 VARCHAR2 DEFAULT NULL,
     X_Date_Type_Lookup_Type          VARCHAR2 DEFAULT NULL,
     X_Date_Type_From                 NUMBER DEFAULT NULL,
     X_Date_Type_To                   NUMBER DEFAULT NULL,
     X_Sequence_Number		     NUMBER DEFAULT NULL
  );
--
PROCEDURE DELETE_ROW (
   x_rowid IN VARCHAR2
  );
END WMS_STRATEGY_ASSIGN_PKG;

 

/
