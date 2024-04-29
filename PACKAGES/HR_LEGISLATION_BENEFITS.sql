--------------------------------------------------------
--  DDL for Package HR_LEGISLATION_BENEFITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEGISLATION_BENEFITS" AUTHID CURRENT_USER AS
/* $Header: pelegben.pkh 115.1 2002/07/29 13:22:48 divicker ship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
-- NAME
--    pelegben.pkh
--
-- DESCRIPTION
-- Procedures required to deliver startup data for
-- COBRA Qualifying Events
-- Benefit Classifications
-- Valid Dependent Types
--
-- MODIFIED
--	80.0  J.Rhodes     07-10-1993	- Created
--	80.1  I.Carline    15-11-1993   - Debugged for US Bechtel delivery
--      80.2  I.Carline    13-12-1993   - Corrected header
--	80.3  Rod Fine     16-12-1993   - Put AS on same line as CREATE stmt
--					  to workaround export WWBUG #178613.
--	70.1  Tim Eyres	   02-01-1996	- Moved arcs header to directly after
--                                        'create or replace' line
--                                        Fix to bug 434902
--     110.1  J Alloun     23-07-1997   - For Release 11, removed SHOW ERROR
--                                        and SELECT FROM USER_ERROR
--                                        statements.
--- ===========================================================================
--
PROCEDURE install
(p_phase number);
--
end hr_legislation_benefits;

 

/
