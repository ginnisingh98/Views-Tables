--------------------------------------------------------
--  DDL for Package FF_DATA_DICT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_DATA_DICT" AUTHID CURRENT_USER AS
/* $Header: peffdict.pkh 120.2.12010000.1 2008/07/28 04:40:43 appldev ship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
-- ---------------------------------------------------------------------------
-- NAME : ff_data_dict.pkh
--
-- DESCRIPTION
--	Procedures used for the delivery of legislative startup data. The
--	same procedures are also used for legislative refreshes.
--
-- MODIFIED
--	80.1  Ian Carline  06-08-1993	- Cretaed
--      80.2  Ian Carline  15-11-1993   - Debugged for US Bechtel delivery
--	80.3  Rod Fine     16-12-1993   - Put AS on same line as CREATE stmt
--					  to workaround export WWBUG #178613.
--      70.5  Ian Carline  09-06-1994   - Reworked header layout.
--	70.6  Tim Eyres	   02-01-1997	- Moved arcs header to directly after
--                                        'create or replace' line
--                                        Fix to bug 434902
--      70.8  Tim Eyres	   02-01-1997   - Correction to version number
--     110.1  J Alloun     11-08-1997   - Removed the SHOW ERRORS and
--                                        SELECT FROM USER_ERROR statements.
--     115.5  D Vickers    23-MAR-2006  - hrrunprc rerunnability
------------------------------------------------------------------------------
PROCEDURE install
(p_phase number);
--
procedure disable_ffuebru_trig;
procedure enable_ffuebru_trig;
--
--
end ff_data_dict;

/
