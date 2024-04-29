--------------------------------------------------------
--  DDL for Package MSC_CONC_PROG_MONITOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CONC_PROG_MONITOR" AUTHID CURRENT_USER AS
	/* $Header: MSCCPRGS.pls 120.0 2005/05/25 19:04:26 appldev noship $ */

function child_requests_completed(p_request_id number) return number;
end msc_conc_prog_monitor;
 

/
