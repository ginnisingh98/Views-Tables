--------------------------------------------------------
--  DDL for Package HR_LEGISLATION_ELEMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEGISLATION_ELEMENTS" AUTHID CURRENT_USER AS
/* $Header: pelegele.pkh 115.2 2003/04/15 15:59:00 rthirlby ship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
-- ---------------------------------------------------------------------------
-- NAME : pelegele.pkh
--
-- DESCRIPTION
--	Procedures used for the delivery of legislative startup data. The
--	same procedures are also used for legislative refreshes.
-- 	This package installs element related details.
-- MODIFIED
--	70.1  Ian Carline  14-09-1993	- Cretaed
--      70.2  Ian Carline  06-01-1994   - Place the 'AS' on the same line as
--                                        the create statement.
--      70.3  Tim Eyres    02-01-1997   - Moved arcs header to directly after
--                                        'create or replace' line
--                                        Fix to bug 434902
--	70.5  Tim Eyres	   02-01-1997   - Correction to version number
--     110.1  J Alloun     24-07-1997   - Removed SHOW ERRORS and SELECT FROM
--      70.6 (10SC)                       USER_ERROR statements.
--     115.2  RThirlby     15-APR-2003    Bug 2888183 - changes for gscc
--                                        standards.
-- ---------------------------------------------------------------------------
--
PROCEDURE install
(p_phase number);
--
end hr_legislation_elements;

 

/
