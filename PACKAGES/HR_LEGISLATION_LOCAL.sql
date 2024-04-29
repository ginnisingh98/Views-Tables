--------------------------------------------------------
--  DDL for Package HR_LEGISLATION_LOCAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEGISLATION_LOCAL" AUTHID CURRENT_USER AS
/* $Header: pelegloc.pkh 115.6 2002/06/14 16:43:09 pkm ship      $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
-- ---------------------------------------------------------------------------
-- NAME : pelegloc.pkh
--
-- DESCRIPTION
--	Procedures used for the delivery of legislative startup data. The
--	same procedures are also used for legislative refreshes.
--	This package is to make specific calls to localization packages
--	or procedures.
-- MODIFIED
--	70.0  Ian Carline  14-09-1993	- Created
--	70.1  Ian Carline  13-12-1993   - Corrected header
--      70.2  Ian Carline  06-01-1994   - Place the 'AS' on the same line as
--                                        the create statement.
--	70.3  Tim Eyres	   02-01-1996	- Moved arcs header to directly after
--					  'create or replace' line
--					  Fix to bug 434902
--     110.1  J Alloun     23-07-1997   - Removed SHOW ERROR and SELECT FROM
--
--                                       USER_ERROR statements for Release 11.
--            Daniel J     03-30-1999   - added new routine install_us_new
--                                        for release 11.5
--            Vipin M      11-10-1999   - Added two new functions
---                                       decode_us_element_information and
--                                        translate_us_ele_dev_df
--    115.4   RThirlby     11-APR-2000    Added new procedure translate_ca_ele-
--                                        _dev_df. This is a copy of us function--                                        translate_us_ele_dev_df, modified for
--                                        CA use.
--    115.5   DVickers     09-MAY-2002    dbdrv added
--    115.6   PGanguly     13-JUN-2002    Added set verify off/whenever
--                                        oserror
-- ===========================================================================
--
TYPE   character_data_table IS TABLE OF varchar2(50)
                                INDEX BY BINARY_INTEGER;

PROCEDURE install_us_new
(p_phase number);

PROCEDURE install
(p_phase number);

FUNCTION decode_elmnt_bal_information (p_legislation_code VARCHAR2,
   p_information_type VARCHAR2,
   p_code NUMBER DEFAULT NULL,
   p_meaning VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 ;

PROCEDURE translate_us_ele_dev_df
(p_mode varchar2);
--
PROCEDURE translate_ca_ele_dev_df
(p_mode varchar2);
--
end hr_legislation_local;

 

/
