--------------------------------------------------------
--  DDL for Package AR_LATE_CHARGES_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_LATE_CHARGES_REPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: ARLCRPTS.pls 120.0 2006/03/28 00:47:31 kmaheswa noship $ */

--+=====================================================================+
--|                                                                     |
--|                                                                     |
--| Global Variables  referenced in ARLCRPT.xml                         |
--|                                                                     |
--|                                                                     |
--+=====================================================================+

--======================================================================+
--                                                                      |
-- Report Lexical Parameters                                            |
--                                                                      |
--======================================================================+
P_QUERY_WHERE               VARCHAR2(240);

--======================================================================+
--                                                                      |
-- Report Input Parameters                                              |
--                                                                      |
--======================================================================+
p_request_id                NUMBER(15);
p_interest_batch_id         NUMBER(15);

--======================================================================+
--                                                                      |
-- Displayed Parameter Values                                           |
--                                                                      |
--======================================================================+
p_batch_name_dsp        VARCHAR2(1000);


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Before_Report                                                         |
|                                                                       |
| Logic for Before Report Trigger                                       |
|                                                                       |
+======================================================================*/
FUNCTION before_report
RETURN BOOLEAN;

END AR_LATE_CHARGES_REPORT_PVT;

 

/
