--------------------------------------------------------
--  DDL for Package FA_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TRANSFERS_PKG" AUTHID CURRENT_USER as
/* $Header: faxtfrs.pls 120.3.12010000.2 2009/07/19 13:09:04 glchen ship $ */

  PROCEDURE INITIALIZE(X_Asset_Id			NUMBER,
			X_Book_Type_Code		IN OUT NOCOPY VARCHAR2,
			X_From_Block			VARCHAR2,
			X_Transaction_Date_Entered 	IN OUT NOCOPY DATE,
			X_Acct_Flex_Num			IN OUT NOCOPY NUMBER,
			X_Calendar_Period_Open_Date	IN OUT NOCOPY DATE,
			X_Calendar_Period_Close_Date	IN OUT NOCOPY DATE,
			X_Transfer_In_PC		IN OUT NOCOPY NUMBER,
			X_Current_PC			IN OUT NOCOPY NUMBER,
			X_FY_Start_Date			IN OUT NOCOPY DATE,
			X_FY_End_Date			IN OUT NOCOPY DATE,
			X_Max_Transaction_Date		IN OUT NOCOPY DATE,
			X_Just_Added_To_Tax_Book	IN OUT NOCOPY VARCHAR2,
			X_Asset_Type			IN OUT NOCOPY VARCHAR2,
			X_Category_Id			IN OUT NOCOPY NUMBER,
			X_Calling_Fn			VARCHAR2
			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
END FA_TRANSFERS_PKG;

/
