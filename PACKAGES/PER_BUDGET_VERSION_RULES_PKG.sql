--------------------------------------------------------
--  DDL for Package PER_BUDGET_VERSION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BUDGET_VERSION_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pebgr01t.pkh 115.2 2002/12/09 14:36:58 raranjan ship $ */

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE Chk_Prev_Rec(X_Budget_Id NUMBER,
                       X_Date_From DATE,
                       X_Date_To   IN OUT NOCOPY DATE,
                       X_Rowid     VARCHAR2,
                       X_Result IN OUT NOCOPY VARCHAR2);

PROCEDURE Get_Id (X_Budget_Version_Id IN OUT NOCOPY NUMBER);

PROCEDURE Chk_Unique(X_Rowid             VARCHAR2,
                     X_Business_Group_Id NUMBER,
                     X_Version_Number    VARCHAR2,
                     X_Budget_Id         NUMBER);


/*PROCEDURE Chk_For_Gap(X_Rowid            VARCHAR2,
                      X_Date_To          DATE,
                      X_End_Of_Time      DATE,
                      X_Budget_Id        NUMBER,
                      X_Date_From        DATE);

PROCEDURE Commit_Chks(X_Rowid            VARCHAR2,
                      X_Date_To          VARCHAR2,
                      X_Date_From        VARCHAR2,
                      X_End_Of_Time      VARCHAR2,
                      X_Budget_Id        NUMBER);*/

PROCEDURE Default_Date_From(X_Date_From  IN OUT NOCOPY DATE,
                            X_Session_Date      DATE,
                            X_Budget_Id         NUMBER);

PROCEDURE Lock_Row(X_Rowid                                   VARCHAR2
	          ,X_Budget_Version_id                       NUMBER
                  ,X_Business_Group_Id                       NUMBER
                  ,X_Budget_Id                               NUMBER
                  ,X_Date_from                               DATE
                  ,X_Version_number                          VARCHAR2
                  ,X_Comments                                VARCHAR2
                  ,X_Date_to                                 DATE
                  ,X_Request_id                              NUMBER
                  ,X_Program_application_id                  NUMBER
                  ,X_Program_id                              NUMBER
                  ,X_Program_update_date                     DATE
                  ,X_Attribute_category                      VARCHAR2
                  ,X_Attribute1                              VARCHAR2
                  ,X_Attribute2                              VARCHAR2
                  ,X_Attribute3                              VARCHAR2
                  ,X_Attribute4                              VARCHAR2
                  ,X_Attribute5                              VARCHAR2
                  ,X_Attribute6                              VARCHAR2
                  ,X_Attribute7                              VARCHAR2
                  ,X_Attribute8                              VARCHAR2
                  ,X_Attribute9                              VARCHAR2
                  ,X_Attribute10                             VARCHAR2
                  ,X_Attribute11                             VARCHAR2
                  ,X_Attribute12                             VARCHAR2
                  ,X_Attribute13                             VARCHAR2
                  ,X_Attribute14                             VARCHAR2
                  ,X_Attribute15                             VARCHAR2
                  ,X_Attribute16                             VARCHAR2
                  ,X_Attribute17                             VARCHAR2
                  ,X_Attribute18                             VARCHAR2
                  ,X_Attribute19                             VARCHAR2
                  ,X_Attribute20                             VARCHAR2);

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY    VARCHAR2
	            ,X_Budget_version_id            IN OUT NOCOPY    NUMBER
	            ,X_Business_group_id                     NUMBER
                    ,X_Budget_id                             NUMBER
                    ,X_Date_from                             DATE
                    ,X_Version_number                        VARCHAR2
                    ,X_Comments                              VARCHAR2
                    ,X_Date_to                               DATE
                    ,X_Request_id                            NUMBER
                    ,X_Program_application_id                NUMBER
                    ,X_Program_id                            NUMBER
                    ,X_Program_update_date                   DATE
                    ,X_Attribute_category                    VARCHAR2
                    ,X_Attribute1                            VARCHAR2
                    ,X_Attribute2                            VARCHAR2
                    ,X_Attribute3                            VARCHAR2
                    ,X_Attribute4                            VARCHAR2
                    ,X_Attribute5                            VARCHAR2
                    ,X_Attribute6                            VARCHAR2
                    ,X_Attribute7                            VARCHAR2
                    ,X_Attribute8                            VARCHAR2
                    ,X_Attribute9                            VARCHAR2
                    ,X_Attribute10                           VARCHAR2
                    ,X_Attribute11                           VARCHAR2
                    ,X_Attribute12                           VARCHAR2
                    ,X_Attribute13                           VARCHAR2
                    ,X_Attribute14                           VARCHAR2
                    ,X_Attribute15                           VARCHAR2
                    ,X_Attribute16                           VARCHAR2
                    ,X_Attribute17                           VARCHAR2
                    ,X_Attribute18                           VARCHAR2
                    ,X_Attribute19                           VARCHAR2
                    ,X_Attribute20                           VARCHAR2);


PROCEDURE Update_Row(X_Rowid                                 VARCHAR2
	            ,X_Budget_Version_id                     NUMBER
                    ,X_Business_Group_Id                     NUMBER
                    ,X_Budget_Id                             NUMBER
                    ,X_Date_from                             DATE
                    ,X_Version_number                        VARCHAR2
                    ,X_Comments                              VARCHAR2
                    ,X_Date_to                               DATE
                    ,X_Request_id                            NUMBER
                    ,X_Program_application_id                NUMBER
                    ,X_Program_id                            NUMBER
                    ,X_Program_update_date                   DATE
                    ,X_Attribute_category                    VARCHAR2
                    ,X_Attribute1                            VARCHAR2
                    ,X_Attribute2                            VARCHAR2
                    ,X_Attribute3                            VARCHAR2
                    ,X_Attribute4                            VARCHAR2
                    ,X_Attribute5                            VARCHAR2
                    ,X_Attribute6                            VARCHAR2
                    ,X_Attribute7                            VARCHAR2
                    ,X_Attribute8                            VARCHAR2
                    ,X_Attribute9                            VARCHAR2
                    ,X_Attribute10                           VARCHAR2
                    ,X_Attribute11                           VARCHAR2
                    ,X_Attribute12                           VARCHAR2
                    ,X_Attribute13                           VARCHAR2
                    ,X_Attribute14                           VARCHAR2
                    ,X_Attribute15                           VARCHAR2
                    ,X_Attribute16                           VARCHAR2
                    ,X_Attribute17                           VARCHAR2
                    ,X_Attribute18                           VARCHAR2
                    ,X_Attribute19                           VARCHAR2
                    ,X_Attribute20                           VARCHAR2);

END PER_BUDGET_VERSION_RULES_PKG;

 

/
