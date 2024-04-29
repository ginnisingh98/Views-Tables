--------------------------------------------------------
--  DDL for Package PAY_ITR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ITR_RKD" AUTHID CURRENT_USER as
/* $Header: pyitrrhi.pkh 120.0 2005/05/29 06:03:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_iterative_rule_id            in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_element_type_id_o            in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_result_name_o                in varchar2
  ,p_iterative_rule_type_o        in varchar2
  ,p_input_value_id_o             in number
  ,p_severity_level_o             in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_itr_rkd;

 

/
