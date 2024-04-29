--------------------------------------------------------
--  DDL for Package PA_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CURRENCY" AUTHID CURRENT_USER AS
/* $Header: PAXGCURS.pls 120.1 2008/03/17 13:57:36 rvelusam ship $ */

  PROCEDURE Set_Currency_Info ; --to set global variables for currency Info.

-- Global variables for currency information

  G_curr_code varchar2(15);   -- holds global currency code
  G_mau       number;         -- holds global minimum accountable unit
  G_sp        number(1);      -- holds global precision
  G_ep        number(2);      -- holds global extended precision

  G_proj_curr_code  varchar2(15); -- holds proj currency code
  G_mau_chr   varchar2(30);   -- minimum accountable unit

  G_org_id    number := NULL;  -- bug 6847113

  FUNCTION get_currency_code  RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (get_currency_code, WNPS, WNDS);

--  The get_currency_code gets the currency code for PA's Set of books

  FUNCTION round_currency_amt ( X_amount  IN NUMBER ) RETURN NUMBER;
  pragma RESTRICT_REFERENCES (round_currency_amt, WNPS, WNDS);

--  The round_currency_amt accepts amount as the parameter and returns the
--  round off amount based on the set of books currency

-- The round_trans_currency_amt accepts amount and currency code as the
-- parameters and returns the round off amount based on the currency code
-- information in fnd_currencies table.

FUNCTION round_trans_currency_amt ( X_amount  IN NUMBER,
                                      X_Curr_Code IN VARCHAR2 ) RETURN NUMBER;
pragma   RESTRICT_REFERENCES (round_trans_currency_amt, WNPS, WNDS);

  FUNCTION currency_fmt_mask(X_length in NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (currency_fmt_mask, WNPS, WNDS);

--  The currency_fmt_mask returns the format mask depending on the
--  standard precision of the currency to a maximum length of X_length
--  Cannot be used in rpt as Org_id has not been sent.

  FUNCTION rpt_currency_fmt_mask(X_org_id in NUMBER, x_length in NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (rpt_currency_fmt_mask, WNPS, WNDS);

--  The currency_fmt_mask returns the format mask depending on the
--  standard precision of the currency to a maximum length of X_length
--  To Be used in rpt Only. Will be Obsolete in future when rpt are
--  converted to srw.

  FUNCTION trans_currency_fmt_mask(X_Curr_Code VARCHAR2,
                                   X_length in NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (trans_currency_fmt_mask, WNPS, WNDS);

  FUNCTION get_mau(X_Curr_Code IN VARCHAR2) RETURN VARCHAR2;
--  pragma RESTRICT_REFERENCES (get_mau, WNPS, WNDS);

  /*
    --Pa-K Changes: Transaction Import Enhancements
    --Added for better performance as the existing Round_Currency_Amt that calls
    --Get_Currency_Code does not use caching. Changing the existing functions
    --will result in removing the PRAGMA constraint that has a lot of impact on
    --other functions.
    --Duplicated 4 functions, new ones are:
    --Get_Currency_Info1, round_currency_amt1, Get_Trans_Currency_Info1 and
    --round_currency_amt1
    --These functions will be removed when the division wide the PRAGMA RESTRICT
    --constraint will be removed from all functions.
    --Till then any changes to the above functions will have to be made here also.
  */

  G_CurrCode1 varchar2(15);   -- holds global currency code
  G_mau1       number;         -- holds global minimum accountable unit
  G_sp1        number(1);      -- holds global precision
  G_ep1        number(2);      -- holds global extended precision

  FUNCTION round_currency_amt1 ( X_amount  IN NUMBER ) RETURN NUMBER;

  G_TransCurrCode varchar2(15);
  G_Transmau       number;
  G_Transsp        number(1);
  G_Transep        number(2);

  FUNCTION round_trans_currency_amt1 ( X_amount  IN NUMBER,
                                      X_Curr_Code IN VARCHAR2 ) RETURN NUMBER;
  FUNCTION round_currency_amt_blk ( p_amount_tab   PA_PLSQL_DATATYPES.NumTabTyp
	                           ,p_currency_tab PA_PLSQL_DATATYPES.Char30TabTyp
                                  ) RETURN PA_PLSQL_DATATYPES.NumTabTyp;
  FUNCTION round_currency_amt_nested_blk ( p_amount_tbl   SYSTEM.pa_num_tbl_type         DEFAULT SYSTEM.pa_num_tbl_type()
	                                  ,p_currency_tbl SYSTEM.pa_varchar2_30_tbl_type DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
                                         ) RETURN SYSTEM.pa_num_tbl_type;
END PA_CURRENCY;

/
