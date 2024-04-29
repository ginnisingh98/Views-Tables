--------------------------------------------------------
--  DDL for Package PA_MU_DETAILS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MU_DETAILS_V_PKG" AUTHID CURRENT_USER as
-- $Header: PAXBAULS.pls 120.1 2005/08/19 17:08:40 mwasowic noship $

  PROCEDURE Insert_Row(	X_Rowid                 IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Line_ID		IN OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Batch_ID		 	NUMBER,
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Updated_By		NUMBER,
			X_Last_Update_Date		DATE,
			X_Last_Update_Login		NUMBER,
			X_Project_ID			NUMBER,
			X_Task_ID			NUMBER,
			X_Old_Attribute_Value		VARCHAR2,
			X_New_Attribute_Value		VARCHAR2,
			X_Update_Flag			VARCHAR2,
			X_Recalculate_Flag		VARCHAR2 );


  PROCEDURE Update_Row(	X_Rowid                         VARCHAR2,
			X_Last_Updated_By		NUMBER,
			X_Last_Update_Date		DATE,
			X_Last_Update_Login		NUMBER,
			X_Project_ID			NUMBER,
			X_Task_ID			NUMBER,
			X_Old_Attribute_Value		VARCHAR2,
			X_New_Attribute_Value		VARCHAR2,
			X_Update_Flag			VARCHAR2,
			X_Recalculate_Flag		VARCHAR2,
			X_Rejection_Reason		VARCHAR2 );


  PROCEDURE Lock_Row(	X_Rowid                         VARCHAR2,
			X_Project_ID			NUMBER,
			X_Task_ID			NUMBER,
			X_Old_Attribute_Value		VARCHAR2,
			X_New_Attribute_Value		VARCHAR2,
			X_Update_Flag			VARCHAR2,
			X_Recalculate_Flag		VARCHAR2,
			X_Rejection_Reason		VARCHAR2 );


  PROCEDURE Delete_Row(	X_Rowid VARCHAR2 );

  PROCEDURE Generate_Lines(
			X_Batch_ID			NUMBER,
			X_Project_Selection		VARCHAR2,
			X_Search_Project_ID		NUMBER    Default NULL,
			X_Search_Organization_ID	NUMBER    Default NULL,
			X_Task_Selection		VARCHAR2,
			X_New_Organization_ID		NUMBER    Default NULL,
			X_Recalculate_Flag		VARCHAR2  Default 'Y',
			X_Err_Code		 IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Err_Stage		 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Err_Stack		 IN OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

END PA_MU_DETAILS_V_PKG;

 

/
