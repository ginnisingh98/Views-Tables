--------------------------------------------------------
--  DDL for Package PAY_PROCESSING_RULE_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PROCESSING_RULE_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: pypprdpm.pkh 115.2 2004/02/23 20:38:50 adkumar noship $ */

Function user_key_to_id(p_user_key_value in varchar2)
return number;
--
Function get_element_type_id
  (p_element_name         in varchar2
  ,p_business_group_id    in number
  ,p_language_code        in varchar2
  ,p_effective_date       in date
  )
  return number;
--
Function get_formula_id
  ( p_formula_Name        in varchar2,
    p_business_group_id   in  number
  )
  return number ;
--
Function get_assignment_status_type_id
  (p_assignment_status    in varchar2
  ,p_business_group_id    in number
  ,p_language_code        in varchar2
  ,p_effective_date       in date
  )
  return number;
--
Function get_status_processing_rule_ovn
  (p_status_process_rule_user_key in varchar2
  ,p_effective_date               in date
  )
  return number;
--
Function get_status_processing_rule_id
  (p_status_process_rule_user_key in varchar2
  )
  return number;
--
END pay_processing_rule_data_pump ;

 

/
