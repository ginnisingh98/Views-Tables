--------------------------------------------------------
--  DDL for Package BOM_RESOURCE_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RESOURCE_CHANGES_PKG" AUTHID CURRENT_USER as
/* $Header: bompbrcs.pls 115.3 2002/11/19 03:04:15 lnarveka ship $ */

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Shift_Num                      NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_From_Date                      DATE,
                     X_To_Date                        DATE DEFAULT NULL,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Capacity_Change                NUMBER DEFAULT NULL,
                     X_Simulation_Set                 VARCHAR2,
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
                     X_Action_Type                    NUMBER,
		     X_Reason_Code		      VARCHAR2 DEFAULT NULL
                    );



PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                   X_Department_Id                    NUMBER,
                   X_Resource_Id                      NUMBER,
                   X_Shift_Num                        NUMBER,
                   X_From_Date                        DATE,
                   X_To_Date                          DATE DEFAULT NULL,
                   X_From_Time                        NUMBER DEFAULT NULL,
                   X_To_Time                          NUMBER DEFAULT NULL,
                   X_Capacity_Change                  NUMBER DEFAULT NULL,
                   X_Simulation_Set                   VARCHAR2,
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
                   X_Attribute15                      VARCHAR2 DEFAULT NULL,
                   X_Action_Type                      NUMBER,
                   X_Reason_Code                      VARCHAR2 DEFAULT NULL
                  );



PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Shift_Num                      NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_From_Date                      DATE,
                     X_To_Date                        DATE DEFAULT NULL,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Capacity_Change                NUMBER DEFAULT NULL,
                     X_Simulation_Set                 VARCHAR2,
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
                     X_Action_Type                    NUMBER,
                     X_Reason_Code                    VARCHAR2 DEFAULT NULL
                    );



PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE Check_Unique(X_Rowid VARCHAR2,
                       X_Action_Type NUMBER,
                       X_From_Date DATE,
                       X_To_Date DATE,
                       X_From_Time NUMBER,
                       X_To_Time NUMBER,
                       X_Department_Id NUMBER,
                       X_Resource_Id NUMBER,
                       X_Shift_Num NUMBER,
                       X_Simulation_Set VARCHAR2);


END BOM_RESOURCE_CHANGES_PKG;

 

/
