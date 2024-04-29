--------------------------------------------------------
--  DDL for Package PAY_NET_CALC_RULE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NET_CALC_RULE_BK1" AUTHID CURRENT_USER as
/* $Header: pyncrapi.pkh 120.0.12010.3 2006/06/21 11:27:54 rvarshne noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pay_net_calc_rule_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pay_net_calc_rule_b
  (p_business_group_id             in     number
  ,p_accrual_plan_id               in     number
  ,p_input_value_id                in     number
  ,p_add_or_subtract               in     varchar2
  ,p_date_input_value_id           in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pay_net_calc_rule_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pay_net_calc_rule_a
  (p_business_group_id             in     number
  ,p_accrual_plan_id               in     number
  ,p_input_value_id                in     number
  ,p_add_or_subtract               in     varchar2
  ,p_date_input_value_id           in     number
  ,p_net_calculation_rule_id       in     number
  ,p_object_version_number         in     number
  );
--
end PAY_NET_CALC_RULE_BK1;

 

/
