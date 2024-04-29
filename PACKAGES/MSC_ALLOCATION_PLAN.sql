--------------------------------------------------------
--  DDL for Package MSC_ALLOCATION_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ALLOCATION_PLAN" AUTHID CURRENT_USER AS
/* $Header: MSCALPHS.pls 120.1 2005/08/25 10:19:04 eychen noship $ */
 Procedure populate_allocation_plan (
			      arg_query_id IN NUMBER,
			      arg_plan_id IN NUMBER,
                              arg_org_id IN NUMBER,
                              arg_instance_id IN NUMBER,
                              arg_item_id IN NUMBER,
                              arg_group_by IN NUMBER,
                              arg_customer_id IN NUMBER DEFAULT NULL,
                              arg_customer_site_id IN NUMBER DEFAULT NULL,
                              arg_customer_list_id IN NUMBER DEFAULT NULL);

FUNCTION send_dates RETURN varchar2;

PROCEDURE create_planned_arrival(
                       p_plan_id in number, p_org_id in number,
                       p_inst_id in number, p_item_id in number,
                       p_source_org in number, p_source_inst in number,
                       p_bkt_start_date in date,
                       p_allocate_qty in number);

PROCEDURE query_list(
		p_query_id IN NUMBER,
                p_plan_id IN NUMBER,
                p_org_id IN NUMBER,
                p_inst_id IN NUMBER,
                p_category_set IN NUMBER,
                p_category_name IN VARCHAR2);

FUNCTION flush_suggAlloc_drillDown(p_item_query_id number,
                                   p_sub_type number,
                                   p_start_date date, p_end_date date)
                                  return NUMBER;

END MSC_ALLOCATION_PLAN;

 

/
