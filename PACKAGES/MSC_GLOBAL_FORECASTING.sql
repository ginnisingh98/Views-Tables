--------------------------------------------------------
--  DDL for Package MSC_GLOBAL_FORECASTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_GLOBAL_FORECASTING" AUTHID CURRENT_USER AS
/* $Header: MSCPHOGS.pls 120.4 2006/08/29 18:03:15 eychen noship $ */

PROCEDURE populate_horizontal_plan (
                          item_list_id IN NUMBER,
			  arg_plan_id IN NUMBER,
                          arg_plan_organization_id IN NUMBER,
                          arg_plan_instance_id IN NUMBER,
			  arg_cutoff_date IN DATE,
                          enterprize_view IN BOOLEAN := FALSE,
		          arg_res_level IN NUMBER DEFAULT 1,
			  arg_resval1 IN VARCHAR2 DEFAULT NULL,
			  arg_resval2 IN NUMBER DEFAULT NULL,
                          arg_ep_view_also IN BOOLEAN DEFAULT FALSE);

PROCEDURE query_list(
		p_query_id IN NUMBER,
                p_plan_id IN NUMBER,
                p_item_list IN VARCHAR2,
                p_org_list IN  VARCHAR2);

PROCEDURE get_detail_records(p_query_id IN NUMBER,
                p_node_type IN NUMBER,
		p_plan_id IN NUMBER,
                p_org_id IN NUMBER,
                p_inst_id IN NUMBER,
                p_item_id IN NUMBER,
                p_rowtype IN NUMBER,
                p_ship_level IN NUMBER,
                p_ship_id IN VARCHAR2,
                p_start_date IN DATE,
                p_end_date IN DATE) ;

FUNCTION get_ship_to(p_ship_to_level number,
                     p_plan_id number,
                     p_sales_order_id number) return varchar2;


END MSC_GLOBAL_FORECASTING;

 

/
