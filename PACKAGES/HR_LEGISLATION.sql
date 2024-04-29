--------------------------------------------------------
--  DDL for Package HR_LEGISLATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEGISLATION" AUTHID CURRENT_USER AS
/* $Header: pelegins.pkh 120.3.12010000.1 2008/07/28 04:59:13 appldev ship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
-- ---------------------------------------------------------------------------
-- NAME : pelegins.pkh
--
-- DESCRIPTION
--	Procedures used for the delivery of legislative startup data. The
--	same procedures are also used for legislative refreshes.
--	This is the main driving package to call all other startup delivery
--	packages and procedures.
--
-- MODIFIED
--	80.1  Ian Carline  14-09-1993	- Cretaed
--	80.2  Ian Carline  15-11-1993   - Debugged for US Bechtel delivery
--	80.3  Ian Carline  13-12-1993   - Corrected header
--	80.4  Rod Fine     16-12-1993   - Put AS on same line as CREATE stmt
--					  to workaround export WWBUG #178613.
--      70.4  Ian Carline  09-06-1994   - Reworked header layout
--      70.5  Ian Carline  13-06-1994   - Added a new entry level install
--                                        procedure.
--	70.6  Tim Eyres	   02-01-1997	- Moved arcs header to directly after
--					  'create or replace' line
--					  Fix to bug 434902
--      70.8  Tim Eyres    02-01-1997   - Correction to arcs version number
--     115.1  T.Battoo     08-Feb-2000    defined hr_legislation.insert_hr_stu_exceptions
--     115.2  Divicker     31-May-2001  - Added p_true_key parameter
--     115.3  Divicker     26-Jul-2001  - Added public procedure munge_sequence
--                                        to take away the time cost of incrementing a
--                                        sequence to a specific value by increment by 1
--     115.4  Divicker     19-Mar-2002  - Added dbdrv checkfile lines
--     115.6  Divicker     10-AUG-2005  - Add debug var
--     115.7  DIVICKER     21-JUN-2006  - Add g_product_install
--     115.8  divicker     20-FEB-2006  - add comment to force dm into 12 br
-- ===========================================================================
PROCEDURE install
(p_phase number);
--
PROCEDURE install;
PROCEDURE hrrunprc_trace_on;
PROCEDURE hrrunprc_trace_off;
PROCEDURE insert_hr_stu_exceptions (p_table_name varchar2,
				   p_surrogate_id number,
				   p_text varchar2,
                                   p_true_key varchar2 default null);
PROCEDURE munge_sequence(p_seq_name varchar2,
                         p_seq_val number,
                         p_req_val number);
--
g_debug_cnt number;
--
/* g_product_install
   For use in hrglobal lcts that need to check on ownership
   information to decide whether to upload row or not */
g_product_install number;

end hr_legislation;

/
