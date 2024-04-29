--------------------------------------------------------
--  DDL for Package BIX_QUEUE_DETAIL_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_QUEUE_DETAIL_REPORT" AUTHID CURRENT_USER AS
/*$Header: bixxrqds.pls 115.2 2003/01/10 00:14:23 achanda ship $*/

PROCEDURE populate(p_context VARCHAR2);

FUNCTION get_heading RETURN VARCHAR2;
END BIX_QUEUE_DETAIL_REPORT;

 

/
