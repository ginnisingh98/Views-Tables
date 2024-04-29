--------------------------------------------------------
--  DDL for Package PAY_NCR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NCR_RKD" AUTHID CURRENT_USER as
/* $Header: pyncrrhi.pkh 120.0 2005/05/29 06:52:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_net_calculation_rule_id        in number
 ,p_accrual_plan_id_o              in number
 ,p_business_group_id_o            in number
 ,p_input_value_id_o               in number
 ,p_add_or_subtract_o              in varchar2
 ,p_date_input_value_id_o          in number
 ,p_object_version_number_o        in number
  );
--
end pay_ncr_rkd;

 

/
