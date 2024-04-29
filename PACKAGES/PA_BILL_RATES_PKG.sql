--------------------------------------------------------
--  DDL for Package PA_BILL_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILL_RATES_PKG" AUTHID CURRENT_USER as
/* $Header: PASUDBRS.pls 120.1 2005/08/19 17:03:20 mwasowic noship $ */

  PROCEDURE Insert_Row(X_Rowid                   	IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		       X_Bill_Rate_Organization_Id	       NUMBER,
		       X_Std_Bill_Rate_Schedule		       VARCHAR2,
		       X_Last_Update_Date		       DATE,
		       X_Last_Updated_By		       NUMBER,
		       X_Creation_Date			       DATE,
		       X_Created_By			       NUMBER,
		       X_Last_Update_Login		       NUMBER,
		       X_Start_Date_Active		       DATE,
		       X_Person_Id			       NUMBER,
		       X_Job_Id				       NUMBER,
		       X_Expenditure_Type		       VARCHAR2,
		       X_Non_Labor_Resource		       VARCHAR2,
		       X_Rate				       NUMBER,
		       X_Bill_Rate_Unit			       VARCHAR2,
		       X_Markup_Percentage		       NUMBER,
		       X_End_Date_Active		       DATE,
                       X_Bill_Rate_Sch_Id                      NUMBER,
                       X_job_group_id                          NUMBER,
		       X_Rate_Currency_Code                    VARCHAR2,
		       X_Resource_Class_Code                   VARCHAR2,
		       X_Res_Class_Organization_Id	       NUMBER
                      );

  PROCEDURE Lock_Row(  X_Rowid                    	       VARCHAR2,
		       X_Bill_Rate_Organization_Id	       NUMBER,
		       X_Std_Bill_Rate_Schedule		       VARCHAR2,
		       X_Start_Date_Active		       DATE,
		       X_Person_Id			       NUMBER,
		       X_Job_Id				       NUMBER,
		       X_Expenditure_Type		       VARCHAR2,
		       X_Non_Labor_Resource		       VARCHAR2,
		       X_Rate				       NUMBER,
		       X_Bill_Rate_Unit			       VARCHAR2,
		       X_Markup_Percentage		       NUMBER,
		       X_End_Date_Active		       DATE,

/* Added parameter for Bug 2078409 */
                       X_Bill_Rate_Sch_Id                      NUMBER,
		       X_Rate_Currency_Code                    VARCHAR2,
       		       X_Resource_Class_Code                   VARCHAR2,
		       X_Res_Class_Organization_Id	       NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                        	       VARCHAR2,
		       X_Bill_Rate_Organization_Id	       NUMBER,
		       X_Std_Bill_Rate_Schedule		       VARCHAR2,
		       X_Last_Update_Date		       DATE,
		       X_Last_Updated_By		       NUMBER,
		       X_Last_Update_Login		       NUMBER,
		       X_Start_Date_Active		       DATE,
		       X_Person_Id			       NUMBER,
		       X_Job_Id				       NUMBER,
		       X_Expenditure_Type		       VARCHAR2,
		       X_Non_Labor_Resource		       VARCHAR2,
		       X_Rate				       NUMBER,
		       X_Bill_Rate_Unit			       VARCHAR2,
		       X_Markup_Percentage		       NUMBER,
		       X_End_Date_Active		       DATE,
                       X_job_group_id                          NUMBER,
		       X_Rate_Currency_Code                    VARCHAR2,
       		       X_Resource_Class_Code                   VARCHAR2,
		       X_Res_Class_Organization_Id	       NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PA_BILL_RATES_PKG;
 

/
