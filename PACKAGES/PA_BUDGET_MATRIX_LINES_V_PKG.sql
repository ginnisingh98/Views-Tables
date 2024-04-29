--------------------------------------------------------
--  DDL for Package PA_BUDGET_MATRIX_LINES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_MATRIX_LINES_V_PKG" AUTHID CURRENT_USER as
 -- $Header: PAXBUMLS.pls 120.1 2005/09/30 10:09:55 rnamburi noship $
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Resource_Assignment_Id         NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Resource_List_Member_Id        NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Quantity                       NUMBER,
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Track_As_Labor_Flag            VARCHAR2,
                       X_Raw_Cost                       NUMBER,
                       X_Burdened_Cost                  NUMBER,
                       X_Revenue                        NUMBER,
                       X_Change_Reason_Code             VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Calling_Process                VARCHAR2 DEFAULT 'PR',
                       X_amt_type                       VARCHAR2,
                       X_raw_cost_source                VARCHAR2 DEFAULT 'M',
		       X_burdened_cost_source           VARCHAR2 DEFAULT 'M',
		       X_quantity_source                VARCHAR2 DEFAULT 'M',
		       X_revenue_source                 VARCHAR2 DEFAULT 'M');
			   -- Bug Fix: 4569365. Removed MRC code.
			   -- ,X_mrc_flag                       VARCHAR2 /* FPB2: MRC */
               --       );

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       X_Calling_Process VARCHAR2 DEFAULT 'PR',
                       X_amt_type VARCHAR2);
					   -- Bug Fix: 4569365. Removed MRC code.
					   -- ,X_mrc_flag VARCHAR2); /* FPB2: MRC */


PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Resource_Assignment_Id           NUMBER,
                     X_Budget_Version_Id                NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Resource_List_Member_Id          NUMBER,
                     X_Description                      VARCHAR2,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Period_Name                      VARCHAR2,
                     X_Quantity                         NUMBER,
                     X_Unit_Of_Measure                  VARCHAR2,
                     X_Track_As_Labor_Flag              VARCHAR2,
                     X_Raw_Cost                         NUMBER,
                     X_Burdened_Cost                    NUMBER,
                     X_Revenue                          NUMBER,
                     X_Change_Reason_Code               VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
  );
END PA_BUDGET_MATRIX_LINES_V_PKG;
 

/
