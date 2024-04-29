--------------------------------------------------------
--  DDL for Package FF_DBI_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_DBI_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: ffdbiutl.pkh 120.2 2007/03/29 09:57:17 alogue noship $ */
------------------------------ str2dbiname -------------------------------
--
-- NAME
--   str2dbiname
--
-- DESCRIPTION
--   Function for converting a string to database item name format.
--
--   It is assumed that the string is complete and contains translated
--   parts that may not conform to database item name format.
--
-- NOTES
--   This is the HRDYNDBI code for handling the NAME_TRANSLATIONS lookup
--   meanings put into a function to avoid having to repeat code.
--
--   If stripping out of punctuation does not work, the remaining
--   database item name will be quoted in double quotes "".
--
function str2dbiname
(p_str in varchar2
) return varchar2;

------------------------- translations_supported -------------------------
--
-- NAME
--   translations_supported
--
-- DESCRIPTION
--   Function that indicates whether or not translated database items
--   and the related behaviour changes (e.g. dynamic database generation
--   and formula translated) are supported for a particular legislation.
--
function translations_supported
(p_legislation_code in varchar2
) return boolean;

--
-- Same as above but returns Y or N instaed of a boolean
--
function translation_supported
(p_legislation_code in varchar2
) return varchar2;

end ff_dbi_utils_pkg;

/
