--------------------------------------------------------
--  DDL for Package MSC_DRP_HORI_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_DRP_HORI_PLAN" AUTHID CURRENT_USER AS
/* $Header: MSCDRPHS.pls 120.1 2005/09/15 11:40:51 eychen noship $ */
PROCEDURE populate_horizontal_plan (
			  arg_query_id IN NUMBER,
			  arg_plan_id IN NUMBER,
                          arg_plan_organization_id IN NUMBER,
                          arg_plan_instance_id IN NUMBER,
			  arg_cutoff_date IN DATE,
                          arg_query_type IN NUMBER);

PROCEDURE dem_priority(p_plan_id number, p_org_id number,
                       p_inst_id number, p_item_id number,
                       p_plan_end_date date,
                       p_query_id number,
                       p_date_string varchar2,
                       p_out_string OUT NOCOPY varchar2) ;

END MSC_DRP_HORI_PLAN;

 

/
