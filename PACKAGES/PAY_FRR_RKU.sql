--------------------------------------------------------
--  DDL for Package PAY_FRR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FRR_RKU" AUTHID CURRENT_USER as
/* $Header: pyfrrrhi.pkh 120.0 2005/05/29 05:08:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_formula_result_rule_id       in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_element_type_id              in number
  ,p_status_processing_rule_id    in number
  ,p_result_name                  in varchar2
  ,p_result_rule_type             in varchar2
  ,p_legislation_subgroup         in varchar2
  ,p_severity_level               in varchar2
  ,p_input_value_id               in number
  ,p_object_version_number        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_element_type_id_o            in number
  ,p_status_processing_rule_id_o  in number
  ,p_result_name_o                in varchar2
  ,p_result_rule_type_o           in varchar2
  ,p_legislation_subgroup_o       in varchar2
  ,p_severity_level_o             in varchar2
  ,p_input_value_id_o             in number
  ,p_object_version_number_o      in number
  );
--
end pay_frr_rku;

 

/
