--------------------------------------------------------
--  DDL for Package BIX_CAMP_PERF_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_CAMP_PERF_REPORT" AUTHID CURRENT_USER AS
/*$Header: bixxrcps.pls 115.2 2003/01/10 00:14:32 achanda ship $*/

PROCEDURE populate(p_context VARCHAR2);

FUNCTION get_heading return VARCHAR2;
END BIX_CAMP_PERF_REPORT;

 

/
