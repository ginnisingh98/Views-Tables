--------------------------------------------------------
--  DDL for Package PAY_NET_CALC_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NET_CALC_RULE_BK3" AUTHID CURRENT_USER as
/* $Header: pyncrapi.pkh 120.0.12010.3 2006/06/21 11:27:54 rvarshne noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pay_net_calc_rule_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pay_net_calc_rule_b
  (p_net_calculation_rule_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pay_net_calc_rule_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pay_net_calc_rule_a
  (p_net_calculation_rule_id       in     number
  ,p_object_version_number         in     number
  );
--
end PAY_NET_CALC_RULE_BK3;

 

/
