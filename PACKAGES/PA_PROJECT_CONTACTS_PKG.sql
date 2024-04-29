--------------------------------------------------------
--  DDL for Package PA_PROJECT_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_CONTACTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXPRCOS.pls 120.1 2005/08/19 17:17:15 mwasowic noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Project_Id                     NUMBER,
                       X_Customer_Id                    NUMBER,
		       X_Bill_Ship_Customer_Id          NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Project_Contact_Type_Code      VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Record_Version_Number          NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Project_Id                       NUMBER,
                     X_Customer_Id                      NUMBER,
                     X_Contact_Id                       NUMBER,
                     X_Project_Contact_Type_Code        VARCHAR2,
                     X_Record_Version_Number            NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Project_Id                     NUMBER,
                       X_Customer_Id                    NUMBER,
		       X_Bill_Ship_Customer_Id          NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Project_Contact_Type_Code      VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Record_Version_number          NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       X_Record_Version_number          NUMBER);

END PA_PROJECT_CONTACTS_PKG;
 

/
