--------------------------------------------------------
--  DDL for Package MRP_REPORT_INV_TURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_REPORT_INV_TURNS" AUTHID CURRENT_USER AS
/* $Header: MRPPRINS.pls 115.0 99/07/16 12:34:06 porting ship $ */
	PROCEDURE mrp_calculate_inventory_turns(
                                arg_query_id        IN NUMBER,
                                arg_org_id          IN NUMBER,
                                arg_compile_desig   IN VARCHAR2,
                                arg_sched_desig     IN VARCHAR2,
                                arg_cost_type       IN NUMBER,
				arg_def_cost_type   IN NUMBER);

END mrp_report_inv_turns;

 

/
