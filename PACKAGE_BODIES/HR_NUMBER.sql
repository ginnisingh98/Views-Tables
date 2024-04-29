--------------------------------------------------------
--  DDL for Package Body HR_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NUMBER" AS
/* $Header: hrutlnmw.pkb 120.4 2005/08/05 00:07:47 raranjan noship $ */

  CURSOR gcsr_group_separator(p_parameter in varchar2) IS
  SELECT value
  FROM V$NLS_PARAMETERS
  WHERE parameter = p_parameter;

  g_group_separator   V$NLS_PARAMETERS.VALUE%TYPE;
  g_currency          V$NLS_PARAMETERS.VALUE%TYPE;

-- ------------------------------------------------------------------------
-- number_to_canonical
-- convert number to canonical format number string
-- ------------------------------------------------------------------------
FUNCTION number_to_canonical
  (p_number     in number)
RETURN varchar2 IS
BEGIN

  OPEN gcsr_group_separator('NLS_NUMERIC_CHARACTERS');
  FETCH gcsr_group_separator INTO g_group_separator;
  CLOSE gcsr_group_separator;

  RETURN REPLACE(TO_CHAR(p_number),SUBSTR(g_group_separator,1,1),'.');

END number_to_canonical;

-- ------------------------------------------------------------------------
-- canonical_to_number
-- convert canonical number to Oracle number
-- ------------------------------------------------------------------------
FUNCTION canonical_to_number
  (p_canonical     in varchar2)
RETURN number IS

  l_canonical  varchar2(2000);

BEGIN

  OPEN gcsr_group_separator('NLS_NUMERIC_CHARACTERS');
  FETCH gcsr_group_separator INTO g_group_separator;
  CLOSE gcsr_group_separator;

  l_canonical := REPLACE(p_canonical, ',');

  RETURN TO_NUMBER(REPLACE(l_canonical, '.', SUBSTR(g_group_separator,1,1)));

END canonical_to_number;

-- ------------------------------------------------------------------------
-- charnumber_to_number
-- convert character number in display format to Oracle number
-- ------------------------------------------------------------------------
FUNCTION charnumber_to_number
  (p_charnumber     in varchar2)
RETURN number IS

BEGIN

  IF hr_util_misc_web.is_valid_number(p_charnumber) = TRUE THEN

    OPEN gcsr_group_separator('NLS_NUMERIC_CHARACTERS');
    FETCH gcsr_group_separator INTO g_group_separator;
    CLOSE gcsr_group_separator;

    RETURN TO_NUMBER(REPLACE(p_charnumber, SUBSTR(g_group_separator,2,1)));

  ELSE
    RAISE hr_util_web.g_error_handled;
  END IF;

END charnumber_to_number;

-- ------------------------------------------------------------------------
-- charnumber_to_canonical
-- convert character number in display format to canonical number
-- ------------------------------------------------------------------------
FUNCTION charnumber_to_canonical
  (p_charnumber     in varchar2)
RETURN varchar2 IS
BEGIN

  RETURN number_to_canonical(charnumber_to_number(p_charnumber));

END charnumber_to_canonical;

-- ------------------------------------------------------------------------
-- canonical_to_charnumber
-- convert canonical number string to character number string
-- ------------------------------------------------------------------------
FUNCTION canonical_to_charnumber
  (p_canonical     in varchar2)
RETURN varchar2 IS
BEGIN

  RETURN TO_CHAR(canonical_to_number(p_canonical));

END canonical_to_charnumber;

-- ------------------------------------------------------------------------
-- charcurrency_to_canonical
-- convert character currency in display format to canonical number string
-- ------------------------------------------------------------------------
FUNCTION charcurrency_to_canonical
  (p_charcurrency     in varchar2)
RETURN varchar2 IS

BEGIN

  OPEN gcsr_group_separator('NLS_CURRENCY');
  FETCH gcsr_group_separator INTO g_currency;
  CLOSE gcsr_group_separator;

  RETURN charnumber_to_canonical
           (REPLACE(p_charcurrency,SUBSTR(g_currency,1,1)));

END charcurrency_to_canonical;

-- ------------------------------------------------------------------------
-- canonical_to_charcurrency
-- convert canonical number string to character currency string
-- ------------------------------------------------------------------------
FUNCTION canonical_to_charcurrency
  (p_canonical     in varchar2)
RETURN varchar2 IS

  l_currency  varchar2(2000);

BEGIN

  l_currency := canonical_to_charnumber(p_canonical);
  l_currency := to_char(to_number(p_canonical),'FML999G999G999D00');

  RETURN l_currency;

END canonical_to_charcurrency;

END hr_number;

/

  GRANT EXECUTE ON "APPS"."HR_NUMBER" TO "EBSBI";
