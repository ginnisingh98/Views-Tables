--------------------------------------------------------
--  DDL for Package PA_PROJ_RETN_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_RETN_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: PAPJRETS.pls 120.1 2005/08/19 16:41:22 mwasowic noship $ */

  PROCEDURE Insert_Row (
       X_Rowid                   	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Project_ID				NUMBER,
       P_Task_Number				VARCHAR2,
       P_Task_Name				VARCHAR2,
       P_Customer_ID				NUMBER,
       P_Retention_Level_Code		IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Expenditure_Category		IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Expenditure_Type		IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Non_Labor_Resource		IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Revenue_Category     	 	IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Event_Type			IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Retention_Percentage			NUMBER,
       P_Retention_Amount			NUMBER,
       P_Threshold_Amount			NUMBER,
       P_Effective_Start_Date			DATE,
       P_Effective_End_Date			DATE,
       P_Task_Flag				VARCHAR2,
       X_Return_Status_Code		IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       X_Error_Message_Code		IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE Update_Row (
       P_Rowid                   		VARCHAR2,
       P_Project_ID				NUMBER,
       P_Customer_ID				NUMBER,
       P_Expenditure_Category		IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Expenditure_Type		IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Non_Labor_Resource		IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Revenue_Category     	 	IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Event_Type			IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       P_Retention_Percentage			NUMBER,
       P_Retention_Amount			NUMBER,
       P_Threshold_Amount			NUMBER,
       P_Effective_Start_Date			DATE,
       P_Effective_End_Date			DATE,
       X_Return_Status_Code		IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       X_Error_Message_Code		IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE Delete_Row (
       P_Rowid                   		VARCHAR2,
       X_Return_Status_Code		IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       X_Error_Message_Code		IN OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

END PA_PROJ_RETN_RULES_PKG;
 

/
