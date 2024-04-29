--------------------------------------------------------
--  DDL for Package PER_RET_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RET_RKI" AUTHID CURRENT_USER as
/* $Header: peretrhi.pkh 115.1 2002/12/06 11:29:29 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_cagr_retained_right_id      in number
  ,p_assignment_id                in number
  ,p_cagr_entitlement_item_id     in number
  ,p_collective_agreement_id      in number
  ,p_cagr_entitlement_id          in number
  ,p_category_name                in varchar2
  ,p_element_type_id              in number
  ,p_input_value_id               in number
  ,p_cagr_api_id                  in number
  ,p_cagr_api_param_id            in number
  ,p_cagr_entitlement_line_id     in number
  ,p_freeze_flag                  in varchar2
  ,p_value                        in varchar2
  ,p_units_of_measure             in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_parent_spine_id              in number
  ,p_formula_id                   in number
  ,p_oipl_id                      in number
  ,p_step_id                      in number
  ,p_grade_spine_id               in number
  ,p_column_type                  in varchar2
  ,p_column_size                  in number
  ,p_eligy_prfl_id                in number
  ,p_object_version_number        in number
  ,p_cagr_entitlement_result_id   in number
  ,p_business_group_id            in number
  ,p_flex_value_set_id            in number
  );
end per_ret_rki;

 

/
