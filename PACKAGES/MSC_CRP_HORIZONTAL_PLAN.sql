--------------------------------------------------------
--  DDL for Package MSC_CRP_HORIZONTAL_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CRP_HORIZONTAL_PLAN" AUTHID CURRENT_USER AS
/*	$Header: MSCHCPLS.pls 120.1 2005/06/10 14:02:45 appldev  $ */

FUNCTION populate_horizontal_plan(
                        p_batchable		IN NUMBER,
			p_item_list_id		IN NUMBER,
			p_org_id		IN NUMBER,
			p_inst_id		IN NUMBER,
			p_plan_id		IN NUMBER,
			p_bucket_type		IN NUMBER,
			p_cutoff_date		IN DATE,
			p_current_data		IN NUMBER DEFAULT 2) RETURN NUMBER;
                   --     p_inst_list             IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION compute_days_between(
            spread_load NUMBER,
            start_date  DATE,
            end_date    DATE) RETURN NUMBER ;

PROCEDURE query_list(p_query_id IN NUMBER,
                p_plan_id IN NUMBER,
                p_org_list IN VARCHAR2,
                p_dept_list IN VARCHAR2,
                p_res_list IN VARCHAR2,
                p_data IN NUMBER,
                p_inst_list IN VARCHAR2 DEFAULT NULL,
                p_serial_num_list IN VARCHAR2 DEFAULT NULL);

END msc_crp_horizontal_plan;

 

/
