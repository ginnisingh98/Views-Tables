--------------------------------------------------------
--  DDL for Package PER_BUDGETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BUDGETS_PKG" AUTHID CURRENT_USER as
/* $Header: pebgt01t.pkh 115.3 2004/02/16 10:52:49 nsanghal ship $ */

PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                     X_Budget_Id                      IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Period_Set_Name                      VARCHAR2,
                     X_Name                                 VARCHAR2,
                     X_Comments                             VARCHAR2,
                     X_Unit                                 VARCHAR2,
                     X_Attribute_Category                   VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Attribute16                          VARCHAR2,
                     X_Attribute17                          VARCHAR2,
                     X_Attribute18                          VARCHAR2,
                     X_Attribute19                          VARCHAR2,
                     X_Attribute20                          VARCHAR2,
		     X_Budget_Type_Code                     VARCHAR2);

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Budget_Id                              NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Period_Set_Name                        VARCHAR2,
                   X_Name                                   VARCHAR2,
                   X_Comments                               VARCHAR2,
                   X_Unit                                   VARCHAR2,
                   X_Attribute_Category                     VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2,
                   X_Attribute16                            VARCHAR2,
                   X_Attribute17                            VARCHAR2,
                   X_Attribute18                            VARCHAR2,
                   X_Attribute19                            VARCHAR2,
                   X_Attribute20                            VARCHAR2,
		   X_Budget_Type_Code                       VARCHAR2);

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Budget_Id                           NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Unit                                VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
		     X_Budget_Type_Code                    VARCHAR2);

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

FUNCTION Chk_OTA_Budget_Type(X_Budget_Id         IN NUMBER,
			     X_Budget_Version_Id IN NUMBER,
			     X_Rowid             IN VARCHAR2) RETURN BOOLEAN;
END PER_BUDGETS_PKG;

 

/
