--------------------------------------------------------
--  DDL for Package PER_CEI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CEI_RKU" AUTHID CURRENT_USER as
/* $Header: peceirhi.pkh 120.1 2006/10/18 09:02:59 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
/*
   per_cei_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_cagr_entitlement_item_id    => p_rec.cagr_entitlement_item_id
      ,p_item_name                   => p_rec.item_name
      ,p_element_type_id             => p_rec.element_type_id
      ,p_input_value_id              => p_rec.input_value_id
      ,p_legislation_code            => p_rec.legislation_code
      ,p_cagr_api_id                 => p_rec.cagr_api_id
      ,p_cagr_api_param_id           => p_rec.cagr_api_param_id
      ,p_business_group_id           => p_rec.business_group_id
      ,p_beneficial_rule             => p_rec.beneficial_rule
      ,p_category_name               => p_rec.category_name
      ,p_uom                         => p_rec.uom
      ,p_flex_value_set_id           => p_rec.flex_value_set_id
      ,p_object_version_number       => p_rec.object_version_number
      ,p_beneficial_formula_id       => p_rec.beneficial_formula_id
      ,p_ben_rule_value_set_id  => p_rec.ben_rule_value_set_id
      ,p_mult_entries_allowed_flag => p_rec.mult_entries_allowed_flag
      ,p_item_name_o                 => per_cei_shd.g_old_rec.item_name
      ,p_element_type_id_o           => per_cei_shd.g_old_rec.element_type_id
      ,p_input_value_id_o            => per_cei_shd.g_old_rec.input_value_id
      ,p_legislation_code_o          => per_cei_shd.g_old_rec.legislation_code
      ,p_cagr_api_id_o               => per_cei_shd.g_old_rec.cagr_api_id
      ,p_cagr_api_param_id_o         => per_cei_shd.g_old_rec.cagr_api_param_id
      ,p_business_group_id_o         => per_cei_shd.g_old_rec.business_group_id
      ,p_beneficial_rule_o           => per_cei_shd.g_old_rec.beneficial_rule
      ,p_category_name_o             => per_cei_shd.g_old_rec.category_name
      ,p_uom_o                       => per_cei_shd.g_old_rec.uom
      ,p_flex_value_set_id_o         => per_cei_shd.g_old_rec.flex_value_set_id
      ,p_object_version_number_o     => per_cei_shd.g_old_rec.object_version_number
      ,p_beneficial_formula_id_o     => per_cei_shd.g_old_rec.beneficial_formula_id
      ,p_ben_rule_value_set_id_o  => per_cei_shd.g_old_rec.ben_rule_value_set_id
      ,p_mult_entries_allowed_flag_o =>   per_cei_shd.g_old_rec.mult_entries_allowed_flag
      ); */
procedure after_update
  (p_effective_date               in date
  ,p_cagr_entitlement_item_id     in number
  ,p_item_name                    in varchar2
  ,p_element_type_id              in number
  ,p_input_value_id               in varchar2
  ,p_column_type                  in varchar2
  ,p_column_size                  in number
  ,p_legislation_code             in varchar2
  ,p_cagr_api_id                  in number
  ,p_cagr_api_param_id            in number
  ,p_beneficial_formula_id        in number
  ,p_business_group_id            in number
  ,p_beneficial_rule              in varchar2
  ,p_category_name                in varchar2
  ,p_uom                          in varchar2
  ,p_flex_value_set_id            in number
  ,p_object_version_number        in number
  ,p_ben_rule_value_set_id        in number
  ,p_mult_entries_allowed_flag    in varchar2
  ,p_auto_create_entries_flag     in varchar2 -- Added for CEI enhancement
  ,p_opt_id                       in number
  ,p_item_name_o                  in varchar2
  ,p_element_type_id_o            in number
  ,p_input_value_id_o             in varchar2
  ,p_column_type_o                in varchar2
  ,p_column_size_o                in number
  ,p_legislation_code_o           in varchar2
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
  ,p_opt_id_o                     in number);
--
end per_cei_rku;

/
