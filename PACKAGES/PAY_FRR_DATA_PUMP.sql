--------------------------------------------------------
--  DDL for Package PAY_FRR_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FRR_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: pyfrrdpm.pkh 115.0 2003/04/08 07:07:36 scchakra noship $ */
--
Function get_status_processing_rule_id
  (p_source_element_name  in varchar2
  ,p_user_status          in varchar2
  ,p_effective_date       in date
  ,p_business_group_id    in number
  ,p_language_code        in varchar2
  )
  return number;
--
Function get_element_type_id
  (p_element_name         in varchar2
  ,p_business_group_id    in number
  ,p_language_code        in varchar2
  )
  return number;
--
Function get_input_value_id
  (p_data_pump_always_call in varchar2
  ,p_input_value_name      in varchar2
  ,p_source_element_name   in varchar2
  ,p_element_name          in varchar2
  ,p_result_rule_type      in varchar2
  ,p_business_group_id     in number
  ,p_effective_date        in date
  ,p_language_code         in varchar2
  )
  return number;
--
Function get_formula_result_rule_ovn
  (p_formula_result_rule_user_key in varchar2
  ,p_effective_date               in date
  )
  return number;
--
Function get_formula_result_rule_id
  (p_formula_result_rule_user_key in varchar2
  )
  return number;
--
END pay_frr_data_pump;

 

/
