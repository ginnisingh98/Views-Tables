--------------------------------------------------------
--  DDL for Package PAY_NCR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NCR_RKI" AUTHID CURRENT_USER as
/* $Header: pyncrrhi.pkh 120.0 2005/05/29 06:52:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_net_calculation_rule_id        in number
 ,p_accrual_plan_id                in number
 ,p_business_group_id              in number
 ,p_input_value_id                 in number
 ,p_add_or_subtract                in varchar2
 ,p_date_input_value_id            in number
 ,p_object_version_number          in number
  );
end pay_ncr_rki;

 

/
