--------------------------------------------------------
--  DDL for Package QA_PC_RESULTS_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PC_RESULTS_REL_PKG" AUTHID CURRENT_USER as
/* $Header: qapcress.pls 115.5 2003/08/26 13:55:24 rponnusa ship $ */
 PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Parent_Collection_Id           NUMBER,
                       X_Parent_Occurrence              NUMBER,
                       X_Child_Plan_Id                  NUMBER,
                       X_Child_Collection_Id            NUMBER,
                       X_Child_Occurrence               NUMBER,
                       X_Enabled_Flag                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Child_Txn_Header_Id            NUMBER
                      );

 PROCEDURE Lock_Row(X_Rowid                             VARCHAR2,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Parent_Collection_Id           NUMBER,
                       X_Parent_Occurrence              NUMBER,
                       X_Child_Plan_Id                  NUMBER,
                       X_Child_Collection_Id            NUMBER,
                       X_Child_Occurrence               NUMBER,
                       X_Enabled_Flag                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Child_Txn_Header_Id            NUMBER
                      );

 PROCEDURE Update_Row(X_Rowid                           VARCHAR2,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Parent_Collection_Id           NUMBER,
                       X_Parent_Occurrence              NUMBER,
                       X_Child_Plan_Id                  NUMBER,
                       X_Child_Collection_Id            NUMBER,
                       X_Child_Occurrence               NUMBER,
                       X_Enabled_Flag                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Child_Txn_Header_Id            NUMBER
                      );
 PROCEDURE Delete_Row(X_Rowid VARCHAR2);


END QA_PC_RESULTS_REL_PKG;

 

/
