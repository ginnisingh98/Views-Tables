--------------------------------------------------------
--  DDL for Package PER_CEI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CEI_RKD" AUTHID CURRENT_USER as
/* $Header: peceirhi.pkh 120.1 2006/10/18 09:02:59 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cagr_entitlement_item_id     in number
  ,p_item_name_o                  in varchar2
  ,p_element_type_id_o            in number
  ,p_input_value_id_o             in varchar2
  ,p_column_type_o                in varchar2
  ,p_column_size_o                in number
  ,p_legislation_code_o                in varchar2
  ,p_cagr_api_id_o                in number
  ,p_cagr_api_param_id_o          in number
  ,p_beneficial_formula_id_o      in number
  ,p_business_group_id_o          in number
  ,p_beneficial_rule_o            in varchar2
  ,p_category_name_o              in varchar2
  ,p_uom_o                        in varchar2
  ,p_flex_value_set_id_o          in number
  ,p_object_version_number_o      in number
  ,p_ben_rule_value_set_id_o      in number
  ,p_mult_entries_allowed_flag_o  in varchar2
  ,p_auto_create_entries_flag_o   in varchar2 -- Added for CEI enhancement
  ,p_opt_id_o                     in number
  );
--
end per_cei_rkd;

/
