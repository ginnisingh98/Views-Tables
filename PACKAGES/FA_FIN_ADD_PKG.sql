--------------------------------------------------------
--  DDL for Package FA_FIN_ADD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FIN_ADD_PKG" AUTHID CURRENT_USER as
/* $Header: faxfadds.pls 120.2.12010000.2 2009/07/19 13:24:13 glchen ship $ */

-- syoung: added x_return_status.
procedure gen_deprn_start_date(
		bks_date_placed_in_service	in date,
		bks_deprn_start_date		in out nocopy date,
		bks_prorate_convention_code	in varchar2,
		bks_fiscal_year_name		in varchar2,
		bks_prorate_date		in date,
		x_return_status		 out nocopy boolean,
		bks_calling_fn			in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
--
PROCEDURE BOOK_VAL(X_Book_Type_Code	VARCHAR2,
		X_ASSET_TYPE		VARCHAR2,
		X_Category_Id		NUMBER,
		X_Asset_Id		NUMBER,
		X_DPIS			IN OUT NOCOPY DATE,
		X_Expense_Acct		IN OUT NOCOPY VARCHAR2,
		X_Acct_Flex_Num		IN OUT NOCOPY NUMBER,
		X_Calling_Fn		VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
--
PROCEDURE DPIS_VAL
	(X_DPIS				DATE,
	X_Category_Id			NUMBER,
	X_Book_Type_Code		VARCHAR2,
	X_Prorate_Convention_Code	IN OUT NOCOPY VARCHAR2,
	X_Prorate_Date			IN OUT NOCOPY DATE,
	X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
--
-- syoung: changed procedure to function.
-- X_Stack_Mesg: Indicates whether to use stacked message or not.
FUNCTION CAT_VAL(X_Book_Type_Code	VARCHAR2,
		X_Asset_Type		VARCHAR2,
		X_Category_Id		NUMBER,
		X_Stack_Mesg		VARCHAR2 DEFAULT 'NO',
		X_Calling_Fn		VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
	RETURN BOOLEAN;
--
END FA_FIN_ADD_PKG;

/
