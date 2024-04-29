--------------------------------------------------------
--  DDL for Package FA_RETIRE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RETIRE_PKG" AUTHID CURRENT_USER as
/* $Header: faxrets.pls 120.4.12010000.2 2009/07/19 10:02:20 glchen ship $ */

  PROCEDURE Initialize(X_Book_Type_Code			VARCHAR2,
		       X_Asset_Id			               NUMBER,
		       X_Cost			       OUT NOCOPY NUMBER,
		       X_Current_Units		 OUT NOCOPY NUMBER,
		       X_Date_Retired		 OUT NOCOPY DATE,
		       X_Current_Fiscal_Year		IN OUT NOCOPY NUMBER,
		       X_Book_Class			      IN OUT NOCOPY VARCHAR2,
		       X_FY_Start_Date		         OUT NOCOPY DATE,
		       X_FY_End_Date		            OUT NOCOPY DATE,
		       X_Current_Period_Counter     OUT NOCOPY NUMBER,
		       X_Asset_Added_PC		         OUT NOCOPY NUMBER,
		       X_Calendar_Period_Close_Date OUT NOCOPY DATE,
		       X_Max_Transaction_Date_Entered OUT NOCOPY DATE,
		       X_Asset_Type			         IN OUT NOCOPY VARCHAR2,
		       X_Ret_Prorate_Convention 	   IN OUT NOCOPY VARCHAR2,
		       X_Use_STL_Retirements_Flag	IN OUT NOCOPY VARCHAR2,
		       X_STL_Method_Code		      IN OUT NOCOPY VARCHAR2,
		       X_STL_Life_In_Months	         OUT NOCOPY NUMBER,
		       X_Calling_Fn			                       VARCHAR2
			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
END FA_RETIRE_PKG;

/
