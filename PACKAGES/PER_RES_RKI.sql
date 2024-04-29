--------------------------------------------------------
--  DDL for Package PER_RES_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RES_RKI" AUTHID CURRENT_USER as
/* $Header: peresrhi.pkh 115.2 2003/04/02 13:37:20 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_cagr_entitlement_result_id   in number
  ,p_assignment_id                in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_collective_agreement_id      in number
  ,p_cagr_entitlement_item_id     in number
  ,p_element_type_id              in number
  ,p_input_value_id               in number
  ,p_cagr_api_id                  in number
  ,p_cagr_api_param_id            in number
  ,p_category_name                in varchar2
  ,p_cagr_entitlement_id          in number
  ,p_cagr_entitlement_line_id     in number
  ,p_value                        in varchar2
  ,p_units_of_measure             in varchar2
  ,p_range_from                   in varchar2
  ,p_range_to                     in varchar2
  ,p_grade_spine_id               in number
  ,p_parent_spine_id              in number
  ,p_step_id                      in number
  ,p_from_step_id                 in number
  ,p_to_step_id                   in number
  ,p_beneficial_flag              in varchar2
  ,p_oipl_id                      in number
  ,p_chosen_flag                  in varchar2
  ,p_column_type                  in varchar2
  ,p_column_size                  in number
  ,p_cagr_request_id              in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_eligy_prfl_id                in number
  ,p_formula_id                   in number
  ,p_object_version_number        in number
  );
end per_res_rki;

 

/
