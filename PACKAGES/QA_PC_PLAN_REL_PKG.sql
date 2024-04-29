--------------------------------------------------------
--  DDL for Package QA_PC_PLAN_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PC_PLAN_REL_PKG" AUTHID CURRENT_USER as
/* $Header: qapcplns.pls 115.5 2003/09/16 00:16:57 rkaza ship $ */
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Plan_Relationship_Id    IN OUT NOCOPY NUMBER,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Child_Plan_id                  NUMBER,
                       X_Plan_Relationship_Type         NUMBER,
                       X_Data_Entry_Mode                NUMBER,
                       X_Layout_mode                    NUMBER,
                       X_Auto_Row_Count                 NUMBER,
		       X_Default_Parent_Spec            NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                      );


 PROCEDURE Lock_Row(   X_Rowid                          VARCHAR2,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Child_Plan_id                  NUMBER,
                       X_Plan_Relationship_Type         NUMBER,
                       X_Data_Entry_Mode                NUMBER,
                       X_Layout_mode                    NUMBER,
                       X_Auto_Row_Count                 NUMBER,
                       X_Default_Parent_Spec            NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER
                      );

 PROCEDURE Update_Row( X_Rowid                          VARCHAR2,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Child_Plan_id                  NUMBER,
                       X_Plan_Relationship_Type         NUMBER,
                       X_Data_Entry_Mode                NUMBER,
                       X_Layout_mode                    NUMBER,
                       X_Auto_Row_Count                 NUMBER,
                       X_Default_Parent_Spec            NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                      );


 PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END QA_PC_PLAN_REL_PKG;

 

/
