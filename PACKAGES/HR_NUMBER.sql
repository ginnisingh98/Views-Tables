--------------------------------------------------------
--  DDL for Package HR_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NUMBER" AUTHID CURRENT_USER AS
/* $Header: hrutlnmw.pkh 115.0 99/07/17 18:20:18 porting ship $ */

-- ------------------------------------------------------------------------
-- number_to_canonical
-- convert number to US format number string
-- ------------------------------------------------------------------------
FUNCTION number_to_canonical
  (p_number     in number)
RETURN varchar2;

-- ------------------------------------------------------------------------
-- canonical_to_number
-- convert canonical number to Oracle number
-- ------------------------------------------------------------------------
FUNCTION canonical_to_number
  (p_canonical     in varchar2)
RETURN number;

-- ------------------------------------------------------------------------
-- charnumber_to_number
-- convert character number in display format to Oracle number
-- ------------------------------------------------------------------------
FUNCTION charnumber_to_number
  (p_charnumber     in varchar2)
RETURN number;

-- ------------------------------------------------------------------------
-- charnumber_to_canonical
-- convert character number in display format to canonical number string
-- ------------------------------------------------------------------------
FUNCTION charnumber_to_canonical
  (p_charnumber     in varchar2)
RETURN varchar2;

-- ------------------------------------------------------------------------
-- canonical_to_charnumber
-- convert canonical number string to character number string
-- ------------------------------------------------------------------------
FUNCTION canonical_to_charnumber
  (p_canonical     in varchar2)
RETURN varchar2;

-- ------------------------------------------------------------------------
-- canonical_to_charcurrency
-- convert canonical number string to character currency string
-- ------------------------------------------------------------------------
FUNCTION canonical_to_charcurrency
  (p_canonical     in varchar2)
RETURN varchar2;

-- ------------------------------------------------------------------------
-- charcurrency_to_canonical
-- convert character currency in display format to canonical number string
-- ------------------------------------------------------------------------
FUNCTION charcurrency_to_canonical
  (p_charcurrency     in varchar2)
RETURN varchar2;

END hr_number;

 

/

  GRANT EXECUTE ON "APPS"."HR_NUMBER" TO "EBSBI";
