--------------------------------------------------------
--  DDL for Package PER_CEI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CEI_RKI" AUTHID CURRENT_USER as
/* $Header: peceirhi.pkh 120.1 2006/10/18 09:02:59 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_cagr_entitlement_item_id     in number
  ,p_item_name                    in varchar2
  ,p_element_type_id              in number
  ,p_input_value_id               in varchar2
  ,p_column_type                  in varchar2
  ,p_column_size                  in number
  ,p_legislation_code                  in varchar2
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
  );
  --
end per_cei_rki;

/
