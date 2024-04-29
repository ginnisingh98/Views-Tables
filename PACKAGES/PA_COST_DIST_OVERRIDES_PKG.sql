--------------------------------------------------------
--  DDL for Package PA_COST_DIST_OVERRIDES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_DIST_OVERRIDES_PKG" AUTHID CURRENT_USER as
/* $Header: PAXPRORS.pls 120.1 2005/08/03 12:27:03 aaggarwa noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Cost_Dist_Override_Id  IN OUT NOCOPY NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Override_To_Org_Id    NUMBER,
                       X_Start_Date_Active              DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Person_Id                      NUMBER,
                       X_Expenditure_Category           VARCHAR2,
                       X_Override_From_Org_Id   NUMBER,
                       X_End_Date_Active                DATE
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Cost_Dist_Override_Id    NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Override_To_Org_Id      NUMBER,
                     X_Start_Date_Active                DATE,
                     X_Person_Id                        NUMBER,
                     X_Expenditure_Category             VARCHAR2,
                     X_Override_From_Org_Id    NUMBER,
                     X_End_Date_Active                  DATE
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Cost_Dist_Override_Id  NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Override_To_Org_Id    NUMBER,
                       X_Start_Date_Active              DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Person_Id                      NUMBER,
                       X_Expenditure_Category           VARCHAR2,
                       X_Override_From_Org_Id  NUMBER,
                       X_End_Date_Active                DATE
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PA_COST_DIST_OVERRIDES_PKG;
 

/
