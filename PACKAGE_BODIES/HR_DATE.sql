--------------------------------------------------------
--  DDL for Package Body HR_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DATE" AS
/* $Header: hrutldtw.pkb 120.1 2005/06/15 02:42:20 sturlapa noship $ */

  CURSOR gcsr_group_separator(p_parameter in varchar2) IS
  SELECT value
  FROM V$NLS_PARAMETERS
  WHERE parameter = p_parameter;

  g_group_separator   varchar2(2000);

-- ------------------------------------------------------------------------
-- chardate_to_date
-- takes a character in display format and return a date
-- ------------------------------------------------------------------------
FUNCTION chardate_to_date
  (p_chardate     in varchar2)
RETURN date IS

BEGIN

  RETURN TRUNC(TO_DATE(p_chardate, hr_util_misc_web.get_user_date_format()));

END chardate_to_date;

-- ------------------------------------------------------------------------
-- date_to_chardate
-- convert date to display format
-- ------------------------------------------------------------------------
FUNCTION date_to_chardate
  (p_date     in date)
RETURN varchar2 IS

BEGIN

  RETURN TO_CHAR(p_date, hr_util_misc_web.get_user_date_format());

END date_to_chardate;

-- ------------------------------------------------------------------------
-- date_to_canonical
-- convert date to canonical date format
-- ------------------------------------------------------------------------
FUNCTION date_to_canonical
  (p_date     in date)
RETURN varchar2 IS

BEGIN
  RETURN to_char(p_date,'RRRR/MM/DD');
  --RETURN fnd_date.date_to_canonical(p_date);
END date_to_canonical;

-- ------------------------------------------------------------------------
-- canonical_to_date
-- convert canonical date to Oracle date
-- ------------------------------------------------------------------------
FUNCTION canonical_to_date
  (p_canonical     in varchar2)
RETURN date IS

BEGIN
  RETURN trunc(to_date(p_canonical, 'RRRR/MM/DD'));
  --RETURN trunc(fnd_date.canonical_to_date(p_canonical));
END canonical_to_date;

-- ------------------------------------------------------------------------
-- chardate_to_canonical
-- take a character in display format and return a canonical date
-- ------------------------------------------------------------------------
FUNCTION chardate_to_canonical
  (p_chardate     in varchar2)
RETURN varchar2 IS

BEGIN
  RETURN date_to_canonical(chardate_to_date(p_chardate));
END chardate_to_canonical;

-- ------------------------------------------------------------------------
-- canonical_to_chardate
-- convert canonical date to chardate in display format
-- ------------------------------------------------------------------------
FUNCTION canonical_to_chardate
  (p_canonical     in varchar2)
RETURN varchar2 IS

  temp  varchar2(2000);

BEGIN
  -- this fix is for oracle IT. In r11 we use 'DD-MON-RRRR' date format
  -- in r11i, we use 'RRRR/MM/DD'.
  -- we have to convert the old date value into the correct date format
  -- in oracle IT database, all old date values have the 'DD-MON-RRRR'
  -- format.
  -- For other customers, we may need to improve this function.

  if (instr(p_canonical,'-') = 3 and length(p_canonical) = 11) then
  -- bug fix 2132425 start
       temp := to_char(to_date(p_canonical, 'DD-MM-RRRR'),'RRRR/MM/DD');
  -- bug fix 2132425 end
  else
    temp := p_canonical;
  end if;

  RETURN date_to_chardate(canonical_to_date(temp));
EXCEPTION
  WHEN OTHERS THEN
    RETURN p_canonical;
END canonical_to_chardate;

END hr_date;

/
