--------------------------------------------------------
--  DDL for Package BOM_RES_INSTANCE_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RES_INSTANCE_CHANGES_PKG" AUTHID CURRENT_USER as
/* $Header: bomprics.pls 115.5 2002/11/27 01:24:44 chrng ship $ */

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Shift_Num                      NUMBER,
                     X_Simulation_Set                 VARCHAR2,
                     X_From_Date                      DATE,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Date                        DATE   DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Instance_Id                    NUMBER,
                     X_Serial_Number                  VARCHAR2 DEFAULT NULL,
                     X_Action_Type                    NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER   DEFAULT NULL,
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
                     X_Capacity_Change                NUMBER   DEFAULT NULL,
                     X_Reason_Code		      VARCHAR2 DEFAULT NULL,
			-- chrng: added the Source fields
			X_Maintenance_Organization_Id	NUMBER	DEFAULT NULL,
			X_Wip_Entity_Id			NUMBER	DEFAULT NULL,
			X_Operation_Seq_Num		NUMBER	DEFAULT NULL
                    );



PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Shift_Num                      NUMBER,
                     X_Simulation_Set                 VARCHAR2,
                     X_From_Date                      DATE,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Date                        DATE   DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Instance_Id                    NUMBER,
                     X_Serial_Number                  VARCHAR2 DEFAULT NULL,
                     X_Action_Type                    NUMBER,
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
                     X_Capacity_Change                NUMBER   DEFAULT NULL,
                     X_Reason_Code                    VARCHAR2 DEFAULT NULL,
			-- chrng: added the Source fields
			X_Maintenance_Organization_Id	NUMBER	DEFAULT NULL,
			X_Wip_Entity_Id			NUMBER	DEFAULT NULL,
			X_Operation_Seq_Num		NUMBER	DEFAULT NULL
                    );


PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Shift_Num                      NUMBER,
                     X_Simulation_Set                 VARCHAR2,
                     X_From_Date                      DATE,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Date                        DATE   DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Instance_Id                    NUMBER,
                     X_Serial_Number                  VARCHAR2 DEFAULT NULL,
                     X_Action_Type                    NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER   DEFAULT NULL,
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
                     X_Capacity_Change                NUMBER   DEFAULT NULL,
                     X_Reason_Code                    VARCHAR2 DEFAULT NULL,
			-- chrng: added the Source fields
			X_Maintenance_Organization_Id	NUMBER	DEFAULT NULL,
			X_Wip_Entity_Id			NUMBER	DEFAULT NULL,
			X_Operation_Seq_Num		NUMBER	DEFAULT NULL
                    );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE Check_Unique(X_Rowid VARCHAR2,
                       X_Department_Id   NUMBER,
                       X_Resource_Id     NUMBER,
                       X_Shift_Num  	 NUMBER,
                       X_Simulation_Set  VARCHAR2,
                       X_From_Date 	 DATE,
                       X_From_Time  	 NUMBER,
                       X_To_Date 	 DATE,
                       X_To_Time 	 NUMBER,
                       X_Instance_Id     NUMBER,
                       X_Serial_Number   VARCHAR2,
                       X_Action_Type     NUMBER);


END BOM_RES_INSTANCE_CHANGES_PKG;

 

/
