--------------------------------------------------------
--  DDL for Package ENG_ECN_APPROVERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ECN_APPROVERS_PKG" AUTHID CURRENT_USER as
/* $Header: ENGAPPRS.pls 115.4 2002/11/22 08:44:49 akumar ship $ */

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Approval_List_Id                     NUMBER,
                     X_Employee_Id                          NUMBER,
                     X_Sequence1                            NUMBER,
                     X_Sequence2                            NUMBER DEFAULT NULL,
                     X_Description                          VARCHAR2 DEFAULT NULL,
                     X_Disable_Date                         DATE DEFAULT NULL,
                     X_Attribute_Category                   VARCHAR2 DEFAULT NULL,
                     X_Attribute1                           VARCHAR2 DEFAULT NULL,
                     X_Attribute2                           VARCHAR2 DEFAULT NULL,
                     X_Attribute3                           VARCHAR2 DEFAULT NULL,
                     X_Attribute4                           VARCHAR2 DEFAULT NULL,
                     X_Attribute5                           VARCHAR2 DEFAULT NULL,
                     X_Attribute6                           VARCHAR2 DEFAULT NULL,
                     X_Attribute7                           VARCHAR2 DEFAULT NULL,
                     X_Attribute8                           VARCHAR2 DEFAULT NULL,
                     X_Attribute9                           VARCHAR2 DEFAULT NULL,
                     X_Attribute10                          VARCHAR2 DEFAULT NULL,
                     X_Attribute11                          VARCHAR2 DEFAULT NULL,
                     X_Attribute12                          VARCHAR2 DEFAULT NULL,
                     X_Attribute13                          VARCHAR2 DEFAULT NULL,
                     X_Attribute14                          VARCHAR2 DEFAULT NULL,
                     X_Attribute15                          VARCHAR2 DEFAULT NULL,
                     X_Creation_Date                          DATE,
                     X_Created_By                             NUMBER,
                     X_Last_Update_Login                      NUMBER DEFAULT NULL,
                     X_Last_Update_Date                       DATE,
                     X_Last_Updated_By                        NUMBER
                     );
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Approval_List_Id                       NUMBER,
                   X_Employee_Id                            NUMBER,
                   X_Sequence1                              NUMBER,
                   X_Sequence2                              NUMBER DEFAULT NULL,
                   X_Description                            VARCHAR2 DEFAULT NULL,
                   X_Disable_Date                           DATE DEFAULT NULL,
                   X_Attribute_Category                     VARCHAR2 DEFAULT NULL,
                   X_Attribute1                             VARCHAR2 DEFAULT NULL,
                   X_Attribute2                             VARCHAR2 DEFAULT NULL,
                   X_Attribute3                             VARCHAR2 DEFAULT NULL,
                   X_Attribute4                             VARCHAR2 DEFAULT NULL,
                   X_Attribute5                             VARCHAR2 DEFAULT NULL,
                   X_Attribute6                             VARCHAR2 DEFAULT NULL,
                   X_Attribute7                             VARCHAR2 DEFAULT NULL,
                   X_Attribute8                             VARCHAR2 DEFAULT NULL,
                   X_Attribute9                             VARCHAR2 DEFAULT NULL,
                   X_Attribute10                            VARCHAR2 DEFAULT NULL,
                   X_Attribute11                            VARCHAR2 DEFAULT NULL,
                   X_Attribute12                            VARCHAR2 DEFAULT NULL,
                   X_Attribute13                            VARCHAR2 DEFAULT NULL,
                   X_Attribute14                            VARCHAR2 DEFAULT NULL,
                   X_Attribute15                            VARCHAR2 DEFAULT NULL
                   );
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Approval_List_Id                    NUMBER,
                     X_Employee_Id                         NUMBER,
                     X_Sequence1                           NUMBER,
                     X_Sequence2                           NUMBER DEFAULT NULL,
                     X_Description                         VARCHAR2 DEFAULT NULL ,
                     X_Disable_Date                        DATE DEFAULT NULL,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL ,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL ,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER
                     );
PROCEDURE Delete_Row(X_Rowid VARCHAR2);
PROCEDURE Check_Unique(X_Rowid               VARCHAR2,
                       X_Approval_List_Id    NUMBER,
                       X_Sequence1           NUMBER);
END ENG_ECN_APPROVERS_PKG ;

 

/
