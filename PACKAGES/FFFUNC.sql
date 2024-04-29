--------------------------------------------------------
--  DDL for Package FFFUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FFFUNC" AUTHID CURRENT_USER as
/* $Header: fffunc.pkh 115.6 2002/07/11 17:32:49 arashid ship $ */
/*
  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All rights reserved

  Name:   fffunc

  Description:  All functions which are called, but are not built-in pl/sql
                functions are defined here, so that formula can call them as
                External functions rather than UDF's

  Change List
  -----------
  P Gowers       21-JAN-1993     Creation
  A Roussel      27-OCT-1994     Moved header to after create/replace
  A Rashid       30-MAR-1999     Added nc, tn, td, and dc functions.
                                 Added pragmas to allow these functions to
                                 be callable from SQL.
  A Rashid       27-APR-1999     Added cn/cd functions and corrected
                                 comments on other conversion functions that
                                 now do native conversions.
  A Rashid       19-AUG-1999     Correct function header comments.
  A Rashid       11-JUL-2002     Added gfm for translated message handling.
*/
---------------------------------- nc -----------------------------------
/*
  NAME
    nc - Number to Character
  DESCRIPTION
    Converts to string in canonical format.
  NOTES
    Short name to keep formula text short.
*/
function nc (p_number in number) return varchar2;
pragma restrict_references(nc, WNDS, WNPS, RNDS);
------------------------------ date_to_char ------------------------------
/*
  NAME
    date_to_char
  DESCRIPTION
    Calls dc.
*/
function date_to_char (datevar in date) return varchar2;
pragma restrict_references(date_to_char, WNDS, WNPS, RNDS);
--------------------------------- dc -------------------------------------
/*
  NAME
    dc - Date to Char
  DESCRIPTION
    Returns date string in canonical format.
  NOTES
    Shortened name to keep formula text short.
*/
function dc (p_date in date) return varchar2;
pragma restrict_references(dc, WNDS, WNPS, RNDS);
------------------------------ round_up ------------------------------
/*
  NAME
    round_up
  DESCRIPTION
    Special rounding function not available in pl/sql
*/
function round_up (num in number, places in number ) return number;
pragma restrict_references(round_up, WNDS, WNPS, RNDS);
------------------------------ add_days ------------------------------
/*
  NAME
    add_days
  DESCRIPTION
    No equivalent function in pl/sql. Adding days to a date is a simple
    addition of a number to a date, but a function is needed for FastFormula
*/
function add_days (datevar in date, days in number) return date;
pragma restrict_references(add_days, WNDS, WNPS, RNDS);
------------------------------ add_years ------------------------------
/*
  NAME
    add_years
  DESCRIPTION
    No equivalent function in pl/sql. Need to call add_months but multiply
    the passed year count by 12
*/
function add_years (datevar in date, years in number) return date;
pragma restrict_references(add_years, WNDS, WNPS, RNDS);
------------------------------ days_between ------------------------------
/*
  NAME
    days_between
  DESCRIPTION
    No equivalent function in pl/sql. Normally evaluate by subtracting
    one date from the other, but a function is needed for FastFormula
*/
function days_between (date1 in date, date2 in date) return number;
pragma restrict_references(days_between, WNDS, WNPS, RNDS);
---------------------------------- tn -----------------------------------
/*
  NAME
    tn - Text to Number
  DESCRIPTION
    Converts a string in the canonical format to a number.
  NOTES
    Short name to keep formula text short.
*/
function tn (p_numstr in varchar2) return number;
pragma restrict_references(tn, WNDS, WNPS, RNDS);
------------------------- text_to_date ----------------------------------
/*
  NAME
    text_to_date
  DESCRIPTION
    Accepts the 11 character date format specifier 'DD-MON-YYYY', or the
    canonical format.
*/
function text_to_date (datestr in varchar2) return date;
pragma restrict_references(text_to_date, WNDS, WNPS, RNDS);
---------------------------------- td -----------------------------------
/*
  NAME
    td - Text to Date
  DESCRIPTION
    Called by text_to_date.
  NOTES
    Shortened name to keep formula text short.
*/
function td (p_datestr in varchar2) return date;
pragma restrict_references(td, WNDS, WNPS, RNDS);
---------------------------------- cd -----------------------------------
/*
  NAME
    cd - Canonical string to Date
  DESCRIPTION
    Converts a string, in the canonical date format, to a date.
*/
function cd (p_datestr in varchar2) return date;
pragma restrict_references(cd, WNDS, WNPS, RNDS);
---------------------------------- cn -----------------------------------
/*
  NAME
    cn - Canonical string to Number
  DESCRIPTION
    Converts a string, in the canonical number format, to a number.
*/
function cn (p_numstr in varchar2) return number;
pragma restrict_references(cn, WNDS, WNPS, RNDS);
--------------------------------- gfm -----------------------------------
/*
  NAME
    gfm - Get Fnd Message
  DESCRIPTION
    Gets a translated FND message (supplying up to 5 tokens). Tokens are
    not translated.
    p_application  - application short name e.g. 'PAY', 'PER'.
    p_message      - message name e.g. 'HR_6153_ALL_PROCEDURE_FAIL'
    p_token_nameN  - name of Nth token.
    p_token_valueN - (string) value for Nth token.
  NOTES
    Returns p_message if the translated message evaluates as null.
*/
function gfm
(p_application  in varchar2
,p_message      in varchar2
,p_token_name1  in varchar2 default null
,p_token_value1 in varchar2 default null
,p_token_name2  in varchar2 default null
,p_token_value2 in varchar2 default null
,p_token_name3  in varchar2 default null
,p_token_value3 in varchar2 default null
,p_token_name4  in varchar2 default null
,p_token_value4 in varchar2 default null
,p_token_name5  in varchar2 default null
,p_token_value5 in varchar2 default null
) return varchar2;
end fffunc;

 

/
