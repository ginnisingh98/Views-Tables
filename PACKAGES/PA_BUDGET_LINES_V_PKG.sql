--------------------------------------------------------
--  DDL for Package PA_BUDGET_LINES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_LINES_V_PKG" AUTHID CURRENT_USER as
-- $Header: PAXBUBLS.pls 120.2 2005/09/23 12:17:50 rnamburi noship $

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Resource_Assignment_Id  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Resource_List_Member_Id        NUMBER,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Quantity                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Track_As_Labor_Flag            VARCHAR2,
                       X_Raw_Cost                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Burdened_Cost           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Revenue                 IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Change_Reason_Code             VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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
                       -- Bug Fix: 4569365. Removed MRC code.
                       -- X_mrc_flag                       VARCHAR2, /* FPB2: MRC */
                       X_Calling_Process                VARCHAR2 DEFAULT 'PR',
                       X_Pm_Product_Code                VARCHAR2 DEFAULT NULL,
                       X_Pm_Budget_Line_Reference       VARCHAR2 DEFAULT NULL,
                       X_raw_cost_source                VARCHAR2 DEFAULT 'M',
                       X_burdened_cost_source           VARCHAR2 DEFAULT 'M',
                       X_quantity_source                VARCHAR2 DEFAULT 'M',
                       X_revenue_source                 VARCHAR2 DEFAULT 'M',
/*Added following 13 columns on 16-mar-2001*/
                   x_standard_bill_rate          NUMBER  DEFAULT NULL,
                   x_average_bill_rate           NUMBER  DEFAULT NULL,
                   x_average_cost_rate           NUMBER  DEFAULT NULL,
                   x_project_assignment_id       NUMBER  DEFAULT -1,
                   x_plan_error_code             VARCHAR2  DEFAULT NULL,
                   x_total_plan_revenue          NUMBER  DEFAULT NULL,
                   x_total_plan_raw_cost         NUMBER  DEFAULT NULL,
                   x_total_plan_burdened_cost    NUMBER  DEFAULT NULL,
                   x_total_plan_quantity         NUMBER  DEFAULT NULL,
                   x_average_discount_percentage NUMBER  DEFAULT NULL,
                   x_cost_rejection_code         VARCHAR2  DEFAULT NULL,
                   x_burden_rejection_code       VARCHAR2  DEFAULT NULL,
                   x_revenue_rejection_code      VARCHAR2  DEFAULT NULL,
                   x_other_rejection_code        VARCHAR2  DEFAULT NULL,
                    X_Code_Combination_Id        NUMBER     DEFAULT NULL,
                    X_CCID_Gen_Status_Code       VARCHAR2   DEFAULT NULL,
                    X_CCID_Gen_Rej_Message       VARCHAR2   DEFAULT NULL
                   );


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


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Resource_Assignment_Id         NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Resource_List_Member_Id        NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Resource_Id_Old                NUMBER,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Quantity              IN OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Quantity_Old          IN OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Track_As_Labor_Flag            VARCHAR2,
                       X_Raw_Cost              IN OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Raw_Cost_Old          IN OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Burdened_Cost         IN OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Burdened_Cost_Old     IN OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Revenue               IN OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Revenue_Old           IN OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
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
                       -- Bug Fix: 4569365. Removed MRC code.
                       -- X_mrc_flag                       VARCHAR2, /* FPB2: MRC */
                       X_Calling_Process                VARCHAR2 DEFAULT 'PR',
                       X_raw_cost_source                VARCHAR2 DEFAULT 'M',
                       X_burdened_cost_source           VARCHAR2 DEFAULT 'M',
                       X_quantity_source                VARCHAR2 DEFAULT 'M',
                       X_revenue_source                 VARCHAR2 DEFAULT 'M',
/*Added following 13 columns on 16-mar-2001*/
                   x_standard_bill_rate          NUMBER  DEFAULT NULL,
                   x_average_bill_rate           NUMBER  DEFAULT NULL,
                   x_average_cost_rate           NUMBER  DEFAULT NULL,
                   x_project_assignment_id       NUMBER  DEFAULT NULL,
                   x_plan_error_code             VARCHAR2  DEFAULT NULL,
                   x_total_plan_revenue          NUMBER  DEFAULT NULL,
                   x_total_plan_raw_cost         NUMBER  DEFAULT NULL,
                   x_total_plan_burdened_cost    NUMBER  DEFAULT NULL,
                   x_total_plan_quantity         NUMBER  DEFAULT NULL,
                   x_average_discount_percentage NUMBER  DEFAULT NULL,
                   x_cost_rejection_code         VARCHAR2  DEFAULT NULL,
                   x_burden_rejection_code       VARCHAR2  DEFAULT NULL,
                   x_revenue_rejection_code      VARCHAR2  DEFAULT NULL,
                   x_other_rejection_code        VARCHAR2  DEFAULT NULL,
                   X_Code_Combination_Id         NUMBER     DEFAULT NULL,
                   X_CCID_Gen_Status_Code        VARCHAR2   DEFAULT NULL,
                   X_CCID_Gen_Rej_Message        VARCHAR2   DEFAULT NULL
                      );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       -- Bug Fix: 4569365. Removed MRC code.
                       -- X_mrc_flag                      VARCHAR2,   /* FPB2: MRC */
                       X_CAlling_Process               VARCHAR2 DEFAULT 'PR'
                      );


  Procedure check_overlapping_dates ( X_Budget_Version_Id          NUMBER,
                                       x_resource_name    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_err_code         IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895


END PA_BUDGET_LINES_V_PKG;
 

/
