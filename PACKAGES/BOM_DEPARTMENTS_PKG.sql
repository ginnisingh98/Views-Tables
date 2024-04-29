--------------------------------------------------------
--  DDL for Package BOM_DEPARTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEPARTMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: bompodps.pls 115.8 2002/11/19 03:14:56 lnarveka ship $ */


PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                     X_Department_Id                  IN OUT NOCOPY NUMBER,
                     X_Department_Code                VARCHAR2,
                     X_Organization_Id                NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Description                    VARCHAR2 DEFAULT NULL,
                     X_Disable_Date                   DATE DEFAULT NULL,
                     X_Department_Class_Code          VARCHAR2 DEFAULT NULL,
		     X_Pa_Expenditure_Org_Id          NUMBER   DEFAULT NULL,
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
                     X_Location_Id                    NUMBER DEFAULT NULL,
		     X_Scrap_Account		      NUMBER DEFAULT NULL,
		     X_Est_Absorption_Account	      NUMBER DEFAULT NULL,
                     X_Maint_Cost_Category            VARCHAR2 DEFAULT NULL
                    );


PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                   X_Department_Id                    NUMBER,
                   X_Department_Code                  VARCHAR2,
                   X_Organization_Id                  NUMBER,
                   X_Description                      VARCHAR2 DEFAULT NULL,
                   X_Disable_Date                     DATE DEFAULT NULL,
                   X_Department_Class_Code            VARCHAR2 DEFAULT NULL,
		   X_Pa_Expenditure_Org_Id            NUMBER   DEFAULT NULL,
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
                   X_Location_Id                      NUMBER DEFAULT NULL,
		   X_Scrap_Account		      NUMBER DEFAULT NULL,
		   X_Est_Absorption_Account	      NUMBER DEFAULT NULL,
                   X_Maint_Cost_Category              VARCHAR2 DEFAULT NULL

                  );


PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Department_Code                VARCHAR2,
                     X_Organization_Id                NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Description                    VARCHAR2 DEFAULT NULL,
                     X_Disable_Date                   DATE DEFAULT NULL,
                     X_Department_Class_Code          VARCHAR2 DEFAULT NULL,
		     X_Pa_Expenditure_Org_Id          NUMBER   DEFAULT NULL,
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
                     X_Location_Id                    NUMBER DEFAULT NULL,
		     X_Scrap_Account		      NUMBER DEFAULT NULL,
		     X_Est_Absorption_Account	      NUMBER DEFAULT NULL,
                     X_Maint_Cost_Category            VARCHAR2 DEFAULT NULL
                    );


PROCEDURE Delete_Row(X_Rowid VARCHAR2);


PROCEDURE Check_Unique(X_Rowid VARCHAR2,
		       X_Organization_Id NUMBER,
		       X_Department_Code VARCHAR2);


FUNCTION Resources_OSP_POReceipt(X_Department_Id NUMBER,
				 X_Organization_Id NUMBER) RETURN NUMBER;


END BOM_DEPARTMENTS_PKG;

 

/
