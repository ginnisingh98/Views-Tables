--------------------------------------------------------
--  DDL for Package PER_RET_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RET_RKD" AUTHID CURRENT_USER as
/* $Header: peretrhi.pkh 115.1 2002/12/06 11:29:29 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cagr_retained_right_id      in number
  ,p_assignment_id_o              in number
  ,p_cagr_entitlement_item_id_o   in number
  ,p_collective_agreement_id_o    in number
  ,p_cagr_entitlement_id_o        in number
  ,p_category_name_o              in varchar2
  ,p_element_type_id_o            in number
  ,p_input_value_id_o             in number
  ,p_cagr_api_id_o                in number
  ,p_cagr_api_param_id_o          in number
  ,p_cagr_entitlement_line_id_o   in number
  ,p_freeze_flag_o                in varchar2
  ,p_value_o                      in varchar2
  ,p_units_of_measure_o           in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_parent_spine_id_o            in number
  ,p_formula_id_o                 in number
  ,p_oipl_id_o                    in number
  ,p_step_id_o                    in number
  ,p_grade_spine_id_o             in number
  ,p_column_type_o                in varchar2
  ,p_column_size_o                in number
  ,p_eligy_prfl_id_o              in number
  ,p_object_version_number_o      in number
  ,p_cagr_entitlement_result_id_o in number
  ,p_business_group_id_o          in number
  ,p_flex_value_set_id_o          in number
  );
--
end per_ret_rkd;

 

/
