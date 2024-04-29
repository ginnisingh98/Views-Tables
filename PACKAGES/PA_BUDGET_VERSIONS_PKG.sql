--------------------------------------------------------
--  DDL for Package PA_BUDGET_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_VERSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXBUBVS.pls 120.1 2005/08/19 17:10:34 mwasowic noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Budget_Version_Id              IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Project_Id                     NUMBER,
                       X_Budget_Type_Code               VARCHAR2,
                       X_Version_Number                 NUMBER,
                       X_Budget_Status_Code             VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Current_Flag                   VARCHAR2,
                       X_Original_Flag                  VARCHAR2,
                       X_Current_Original_Flag          VARCHAR2,
                       X_Resource_Accumulated_Flag      VARCHAR2,
                       X_Resource_List_Id               NUMBER,
                       X_Version_Name                   VARCHAR2,
                       X_Budget_Entry_Method_Code       VARCHAR2,
                       X_Baselined_By_Person_Id         NUMBER,
                       X_Baselined_Date                 DATE,
                       X_Change_Reason_Code             VARCHAR2,
                       X_Labor_Quantity                 NUMBER,
                       X_Labor_Unit_Of_Measure          VARCHAR2,
                       X_Raw_Cost                       NUMBER,
                       X_Burdened_Cost                  NUMBER,
                       X_Revenue                        NUMBER,
                       X_Description                    VARCHAR2,
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
                       X_First_Budget_Period             VARCHAR2,
	       X_Pm_Product_Code                VARCHAR2 DEFAULT NULL,
	       X_Pm_Budget_Reference            VARCHAR2 DEFAULT NULL,
	        X_wf_status_code		VARCHAR2 DEFAULT NULL,
			x_adw_notify_flag	VARCHAR2 DEFAULT NULL,
			x_prc_generated_flag	VARCHAR2 DEFAULT NULL,
			x_plan_run_date		DATE DEFAULT NULL,
			x_plan_processing_code	VARCHAR2 DEFAULT NULL
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Budget_Version_Id                NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Budget_Type_Code                 VARCHAR2,
                     X_Version_Number                   NUMBER,
                     X_Budget_Status_Code               VARCHAR2,
                     X_Current_Flag                     VARCHAR2,
                     X_Original_Flag                    VARCHAR2,
                     X_Current_Original_Flag            VARCHAR2,
                     X_Resource_Accumulated_Flag        VARCHAR2,
                     X_Resource_List_Id                 NUMBER,
                     X_Version_Name                     VARCHAR2,
                     X_Budget_Entry_Method_Code         VARCHAR2,
                     X_Baselined_By_Person_Id           NUMBER,
                     X_Baselined_Date                   DATE,
                     X_Change_Reason_Code               VARCHAR2,
                     X_Labor_Quantity                   NUMBER,
                     X_Labor_Unit_Of_Measure            VARCHAR2,
                     X_Raw_Cost                         NUMBER,
                     X_Burdened_Cost                    NUMBER,
                     X_Revenue                          NUMBER,
                     X_Description                      VARCHAR2,
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
                     X_Attribute15                      VARCHAR2,
                     X_First_Budget_Period               VARCHAR2
                    );


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Budget_Type_Code               VARCHAR2,
                       X_Version_Number                 NUMBER,
                       X_Budget_Status_Code             VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Current_Flag                   VARCHAR2,
                       X_Original_Flag                  VARCHAR2,
                       X_Current_Original_Flag          VARCHAR2,
                       X_Resource_Accumulated_Flag      VARCHAR2,
                       X_Resource_List_Id               NUMBER,
                       X_Version_Name                   VARCHAR2,
                       X_Budget_Entry_Method_Code       VARCHAR2,
                       X_Baselined_By_Person_Id         NUMBER,
                       X_Baselined_Date                 DATE,
                       X_Change_Reason_Code             VARCHAR2,
                       X_Labor_Quantity                 NUMBER,
                       X_Labor_Unit_Of_Measure          VARCHAR2,
                       X_Raw_Cost                       NUMBER,
                       X_Burdened_Cost                  NUMBER,
                       X_Revenue                        NUMBER,
                       X_Description                    VARCHAR2,
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
                       X_First_Budget_Period             VARCHAR2,
	         X_wf_status_code		VARCHAR2,
                        x_adw_notify_flag       VARCHAR2 DEFAULT NULL,
                        x_prc_generated_flag    VARCHAR2 DEFAULT NULL,
                        x_plan_run_date         DATE DEFAULT NULL,
                        x_plan_processing_code  VARCHAR2 DEFAULT NULL
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PA_BUDGET_VERSIONS_PKG;
 

/