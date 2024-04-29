--------------------------------------------------------
--  DDL for Package PA_PROJ_ASSET_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_ASSET_ASSIGN_PKG" AUTHID CURRENT_USER as
/* $Header: PAXASSNS.pls 120.1 2005/08/17 12:58:41 ramurthy noship $ cconlin 26-Oct-95*/


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Project_Asset_Id               NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Project_Asset_Id                 NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Project_Id                       NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Project_Asset_Id               NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PA_PROJ_ASSET_ASSIGN_PKG;
 

/
