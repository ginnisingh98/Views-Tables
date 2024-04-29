--------------------------------------------------------
--  DDL for Package MTL_CYCLE_COUNT_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CYCLE_COUNT_CLASSES_PKG" AUTHID CURRENT_USER as
/* $Header: INVADC3S.pls 120.1 2005/06/19 05:04:53 appldev  $ */
--Added NOCOPY hint to X_Rowid IN OUT parameter to comply with
--GSCC standard File.Sql.39. BUg:4410902
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY  VARCHAR2,
                       X_Abc_Class_Id                           NUMBER,
                       X_Cycle_Count_Header_Id                  NUMBER,
                       X_Organization_Id                        NUMBER,
                       X_Last_Update_Date                       DATE,
                       X_Last_Updated_By                        NUMBER,
                       X_Creation_Date                          DATE,
                       X_Created_By                             NUMBER,
                       X_Last_Update_Login                      NUMBER,
                       X_Num_Counts_Per_Year                    NUMBER,
                       X_Approval_Tolerance_Positive            NUMBER,
                       X_Approval_Tolerance_Negative            NUMBER,
                       X_Cost_Tolerance_Positive                NUMBER,
                       X_Cost_Tolerance_Negative                NUMBER,
                       X_Hit_Miss_Tolerance_Positive            NUMBER,
                       X_Hit_Miss_Tolerance_Negative            NUMBER,
                       X_Abc_Assignment_Group_Id                NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Abc_Class_Id                     NUMBER,
                     X_Cycle_Count_Header_Id            NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Num_Counts_Per_Year              NUMBER,
                     X_Approval_Tolerance_Positive      NUMBER,
                     X_Approval_Tolerance_Negative      NUMBER,
                     X_Cost_Tolerance_Positive          NUMBER,
                     X_Cost_Tolerance_Negative          NUMBER,
                     X_Hit_Miss_Tolerance_Positive      NUMBER,
                     X_Hit_Miss_Tolerance_Negative      NUMBER,
                     X_Abc_Assignment_Group_Id          NUMBER
                    );


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Abc_Class_Id                   NUMBER,
                       X_Cycle_Count_Header_Id          NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Num_Counts_Per_Year            NUMBER,
                       X_Approval_Tolerance_Positive    NUMBER,
                       X_Approval_Tolerance_Negative    NUMBER,
                       X_Cost_Tolerance_Positive        NUMBER,
                       X_Cost_Tolerance_Negative        NUMBER,
                       X_Hit_Miss_Tolerance_Positive    NUMBER,
                       X_Hit_Miss_Tolerance_Negative    NUMBER,
                       X_Abc_Assignment_Group_Id        NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END MTL_CYCLE_COUNT_CLASSES_PKG;

 

/
