--------------------------------------------------------
--  DDL for Package HXC_TIME_CATEGORY_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_CATEGORY_HOOK" AUTHID CURRENT_USER as
/* $Header: hxchtchk.pkh 120.0 2005/05/29 04:58:43 appldev noship $ */

g_package VARCHAR2(72) := 'hxc_time_category_hook.';

procedure create_pto_time_category_a (
		p_accrual_plan_id	  NUMBER default null
	,	p_net_calculation_rule_id NUMBER default null );

procedure update_pto_time_category_b (
		p_accrual_plan_id	  NUMBER default null
	,	p_net_calculation_rule_id NUMBER default null );

procedure update_pto_time_category_a (
		p_accrual_plan_id	  NUMBER default null
	,	p_net_calculation_rule_id NUMBER default null );

procedure delete_pto_time_category_b (
		p_net_calculation_rule_id NUMBER default null );

end hxc_time_category_hook;

 

/
