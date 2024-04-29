--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_DEPRN_EXP_OVR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_DEPRN_EXP_OVR" AS
-- $Header: PACCXDEB.pls 115.2 2003/08/18 14:31:08 ajdas noship $

FUNCTION DEPRN_EXPENSE_ACCT_OVERRIDE
                           (p_project_asset_id      IN      NUMBER DEFAULT NULL,
                           p_book_type_code         IN      VARCHAR2,
                           p_asset_category_id      IN      NUMBER,
                           p_date_placed_in_service IN      DATE,
                           p_deprn_expense_acct_ccid IN     NUMBER DEFAULT NULL) RETURN NUMBER IS

BEGIN
 /* This is a client extension function called by the INTERFACE_ASSET_LINES procedure,
    prior to the validation of complete asset information, including the Depreciation
    Expense Account.  The extension is called once for every Project Asset processed.

    The intended use of this extension is to provide clients with the ability to either
    override the existing Depreciation Expense account value on the Project Asset, or to
    derive a default account value if no account is currently specified.  One approach to
    deriving this account would be to select the segments for the Asset Cost Account for
    the Asset Category and Book Type Code specified, determine the Depreciation Expense
    Account segment value for the Asset Category and Book specified, and create a new
    code combination by replacing the natural account segment in the Asset Cost CCID with
    the Depreciation Expense Account.  If this CCID is valid for the current Set of Books,
    then it can be returned as the override Deprn Expense Account CCID.

    Note that the Project Asset ID parameter may be NULL if the client extension is being
    called prior to the initial insert of the project asset.
 */


    RETURN(p_deprn_expense_acct_ccid);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

END;

/
