--------------------------------------------------------
--  DDL for Package PER_RES_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RES_RKD" AUTHID CURRENT_USER as
/* $Header: peresrhi.pkh 115.2 2003/04/02 13:37:20 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cagr_entitlement_result_id   in number
  ,p_assignment_id_o              in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_collective_agreement_id_o    in number
  ,p_cagr_entitlement_item_id_o   in number
  ,p_element_type_id_o            in number
  ,p_input_value_id_o             in number
  ,p_cagr_api_id_o                in number
  ,p_cagr_api_param_id_o          in number
  ,p_category_name_o              in varchar2
  ,p_cagr_entitlement_id_o        in number
  ,p_cagr_entitlement_line_id_o   in number
  ,p_value_o                      in varchar2
  ,p_units_of_measure_o           in varchar2
  ,p_range_from_o                 in varchar2
  ,p_range_to_o                   in varchar2
  ,p_grade_spine_id_o             in number
  ,p_parent_spine_id_o            in number
  ,p_step_id_o                    in number
  ,p_from_step_id_o               in number
  ,p_to_step_id_o                 in number
  ,p_beneficial_flag_o            in varchar2
  ,p_oipl_id_o                    in number
  ,p_chosen_flag_o                in varchar2
  ,p_column_type_o                in varchar2
  ,p_column_size_o                in number
  ,p_cagr_request_id_o            in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_eligy_prfl_id_o              in number
  ,p_formula_id_o                 in number
  ,p_object_version_number_o      in number
  );
--
end per_res_rkd;

 

/
