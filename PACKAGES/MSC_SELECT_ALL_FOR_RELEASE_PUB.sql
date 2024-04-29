--------------------------------------------------------
--  DDL for Package MSC_SELECT_ALL_FOR_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SELECT_ALL_FOR_RELEASE_PUB" AUTHID CURRENT_USER AS
    /* $Header: MSCSARPS.pls 120.2.12010000.2 2009/10/21 23:34:50 cnazarma ship $ */

	PROCEDURE Update_Implement_Attrib(p_where_clause IN VARCHAR2,
					  p_employee_id IN NUMBER,
					  p_demand_class IN VARCHAR2,
					  p_def_job_class IN VARCHAR2,
					  p_def_firm_jobs IN VARCHAR2,
                                          p_include_so IN VARCHAR2,
					  p_total_rows OUT NOCOPY NUMBER,
					  p_succ_rows OUT NOCOPY NUMBER,
					  p_error_rows OUT NOCOPY NUMBER,
                                          p_current_plan_type IN NUMBER DEFAULT NULL);


	FUNCTION get_alternate_bom(p_plan_id IN number,
                                   p_sr_instance_id in number ,
                                   p_proc_seq_id in number ) return varchar2;

	FUNCTION get_alternate_rtg(p_plan_id IN number,
                                   p_sr_instance_id in number ,
                                   p_proc_seq_id in number ) return varchar2;

        FUNCTION get_wip_job_prefix(p_sr_instance_id IN number) return varchar2;

        FUNCTION child_supplies_onhand(p_plan_id number,
                                   p_transaction_id number) return number;

        FUNCTION get_implement_as(p_order_type number,
                          p_org_id number,
                          p_source_org_id number,
                          p_supplier_id number,
                          p_planning_make_buy_code number,
                          p_build_in_wip_flag number,
                          p_purchasing_enabled_flag number) return number ;

PRAGMA RESTRICT_REFERENCES (get_alternate_rtg, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES (get_alternate_bom, WNDS, WNPS);

END MSC_SELECT_ALL_FOR_RELEASE_PUB;

/
