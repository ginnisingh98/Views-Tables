--------------------------------------------------------
--  DDL for Package Body FFFUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FFFUNC" as
/* $Header: fffunc.pkb 120.2 2006/11/10 13:39:11 alogue noship $ */
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
                                 Call fnd_number and fnd_date canonical
                                 functions where appropriate.
  A Rashid       27-APR-1999     Replace fnd_number and fnd_date canonical
                                 calls by standard to_date, to_number,
                                 and to_char calls. Added cn/cd functions
                                 for converting canonical strings to
                                 number/date.
  A Rashid       26-JUL-1999     Have to undo the previous change because
                                 of formulas using TO_NUMBER etc. to
                                 read from user_tables which store data in
                                 canonical format (bug946606).
  A Rashid       19-AUG-1999     Correct function header comments.
  A Rashid       19-JAN-2000     Use explicit format mask
                                 FXYYYY/MM/DD HH24:MI:SS
                                 because the date_to_canonical
                                 function does not use the FX
                                 qualifier which allows certain
                                 DD-MON-YYYY date strings to be
                                 incorrectly accepted.
  A Rashid       11-JUL-2002     Added GFM for FND message handling.
  A Rashid       12-JUL-2002     Hold DD-MON-YYYY date format in a
                                 local variable to get around GSSC
                                 compliance fatal error. DD-MON-YYYY
                                 is the legacy FF date format.
  A Rashid       12-JUL-2002     Use substrb instead of substr for
                                 message text truncation. Use
                                 FF_EXEC.FF_BIND_LEN to truncate the
                                 returned message text.
  A Logue        20-JAN-2006     Remove Group Seperator in tn
                                 before passing to fnd_number
                                 canonical_to_number. Bug 4765352.
  A Logue        10-NOV-2006     Undo last change. Bug 5654185.
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
function nc (p_number in number) return varchar2 is
begin
  return fnd_number.number_to_canonical(p_number);
end nc;
------------------------------ date_to_char ------------------------------
/*
  NAME
    date_to_char
  DESCRIPTION
    Calls dc.
*/
function date_to_char (datevar in date) return varchar2 is
begin
  return dc(p_date => datevar);
end date_to_char;
--------------------------------- dc -------------------------------------
/*
  NAME
    dc - Date to Char
  DESCRIPTION
    Returns date string in canonical format.
  NOTES
    Shortened name to keep formula text short.
*/
function dc (p_date in date) return varchar2 is
begin
  return fnd_date.date_to_canonical(p_date);
end dc;
------------------------------ round_up ------------------------------
/*
  NAME
    round_up
  DESCRIPTION
    Special rounding function not available in pl/sql
*/
function round_up (num in number, places in number ) return number is
pow_res number;
begin
  pow_res:=power(10,places);
  return (ceil(num * pow_res)/pow_res);
end round_up;
------------------------------ add_days ------------------------------
/*
  NAME
    add_days
  DESCRIPTION
    No equivalent function in pl/sql. Adding days to a date is a simple
    addition of a number to a date, but a function is needed for FastFormula
*/
function add_days (datevar in date, days in number) return date is
begin
  return (datevar + days);
end add_days;
------------------------------ add_years ------------------------------
/*
  NAME
    add_years
  DESCRIPTION
    No equivalent function in pl/sql. Need to call add_months but multiply
    the passed year count by 12
*/
function add_years (datevar in date, years in number) return date is
begin
  return (add_months(datevar, trunc(years)*12));
end add_years;
------------------------------ days_between ------------------------------
/*
  NAME
    days_between
  DESCRIPTION
    No equivalent function in pl/sql. Normally evaluate by subtracting
    one date from the other, but a function is needed for FastFormula
*/
function days_between (date1 in date, date2 in date) return number is
begin
  return (date1 - date2);
end days_between;
---------------------------------- tn -----------------------------------
/*
  NAME
    tn - Text to Number
  DESCRIPTION
    Converts a string in the canonical format to a number.
  NOTES
    Short name to keep formula text short.
*/
function tn (p_numstr in varchar2) return number is
begin
  return fnd_number.canonical_to_number(p_numstr);
end tn;
------------------------------ text_to_date ------------------------------
/*
  NAME
    text_to_date
  DESCRIPTION
    Accepts the 11 character date format specifier 'DD-MON-YYYY', or the
    canonical format.
*/
function text_to_date (datestr in varchar2) return date is
  d date;
begin
  return td(p_datestr => datestr);
end text_to_date;
---------------------------------- td -----------------------------------
/*
  NAME
    td - Text to Date
  DESCRIPTION
    Called by text_to_date.
  NOTES
    Shortened name to keep formula text short.
*/
function td (p_datestr in varchar2) return date is
  d date;
  legacy_format varchar2(64) := 'DD-MON-YYYY';
begin
  --
  -- Try the canonical date format first.
  --
  begin
    d := to_date(p_datestr, 'FXYYYY/MM/DD HH24:MI:SS');
    return d;
  exception
    when others then
      null;
  end;
  --
  -- Try the old FF date format.
  --
  begin
    d := to_date(p_datestr,legacy_format);
    return d;
  exception
    when others then
      null;
  end;
  --
  raise value_error;
end td;
---------------------------------- cd -----------------------------------
/*
  NAME
    cd - Canonical string to Date
  DESCRIPTION
    Converts a string, in the canonical date format, to a date.
*/
function cd (p_datestr in varchar2) return date is
begin
  return fnd_date.canonical_to_date(canonical => p_datestr);
end cd;
---------------------------------- cn -----------------------------------
/*
  NAME
    cn - Canonical string to Number
  DESCRIPTION
    Converts a string, in the canonical number format, to a number.
*/
function cn (p_numstr in varchar2) return number is
begin
  return fnd_number.canonical_to_number(canonical => p_numstr);
end cn;
--------------------------------- gfm -----------------------------------
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
) return varchar2 is
begin
  --
  -- Keep this code as simple as possible.
  --
  fnd_message.set_name(p_application, p_message);
  --
  if p_token_name1 is not null and p_token_value1 is not null then
    fnd_message.set_token(p_token_name1, p_token_value1, false);
  end if;
  --
  if p_token_name2 is not null and p_token_value2 is not null then
    fnd_message.set_token(p_token_name2, p_token_value2, false);
  end if;
  --
  if p_token_name3 is not null and p_token_value3 is not null then
    fnd_message.set_token(p_token_name3, p_token_value3, false);
  end if;
  --
  if p_token_name4 is not null and p_token_value4 is not null then
    fnd_message.set_token(p_token_name4, p_token_value4, false);
  end if;
  --
  if p_token_name5 is not null and p_token_value5 is not null then
    fnd_message.set_token(p_token_name5, p_token_value5, false);
  end if;
  --
  -- Just return the message name itself if the text is NULL,
  -- otherwise return the (truncated) message text.
  --
  return substrb(nvl(fnd_message.get, p_message), 1, FF_EXEC.FF_BIND_LEN);
end gfm;
--
end fffunc;

/
