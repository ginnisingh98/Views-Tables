--------------------------------------------------------
--  DDL for Package MSC_BUDGET_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_BUDGET_DETAILS" AUTHID CURRENT_USER AS
/* $Header: MSCBDDTS.pls 115.2 2004/04/23 22:46:02 rvrao noship $  */
PROCEDURE populate_budget_details(
                     p_plan_id     IN number,
                     p_date        IN date,
                     p_item        in number,
                     p_query_id    in number,
                     p_organization_id in number,
                     p_sr_instance_id in number,
                     p_budget_value in number,
                     p_tot_inv in number,
                     p_violation_level in number, -- 1 plan, 2 org, 3 cat
                     p_category_name    in varchar2 default null) ;
END msc_budget_details;

 

/
