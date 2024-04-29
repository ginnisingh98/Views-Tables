--------------------------------------------------------
--  DDL for Package HR_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DATE" AUTHID CURRENT_USER AS
/* $Header: hrutldtw.pkh 120.1 2005/06/15 02:42:27 sturlapa noship $ */

-- ------------------------------------------------------------------------
-- chardate_to_date
-- takes a character in display format and return a date
-- ------------------------------------------------------------------------
FUNCTION chardate_to_date
  (p_chardate     in varchar2)
RETURN date;

-- ------------------------------------------------------------------------
-- date_to_chardate
-- convert date to display format
-- ------------------------------------------------------------------------
FUNCTION date_to_chardate
  (p_date     in date)
RETURN varchar2;

-- ------------------------------------------------------------------------
-- date_to_canonical
-- convert date to canonical format 'YYYY/MM/DD'
-- ------------------------------------------------------------------------
FUNCTION date_to_canonical
  (p_date     in date)
RETURN varchar2;

-- ------------------------------------------------------------------------
-- canonical_to_date
-- convert canonical date 'YYYY/MM/DD' to Oracle date
-- ------------------------------------------------------------------------
FUNCTION canonical_to_date
  (p_canonical     in varchar2)
RETURN date;

-- ------------------------------------------------------------------------
-- chardate_to_canonical
-- take a character in display format and return a canonical date 'YYYY/MM/DD'
-- ------------------------------------------------------------------------
FUNCTION chardate_to_canonical
  (p_chardate     in varchar2)
RETURN varchar2;

-- ------------------------------------------------------------------------
-- canonical_to_chardate
-- convert canonical date 'YYYY/MM/DD' to chardate in display format
-- ------------------------------------------------------------------------
FUNCTION canonical_to_chardate
  (p_canonical     in varchar2)
RETURN varchar2;

END hr_date;

 

/
