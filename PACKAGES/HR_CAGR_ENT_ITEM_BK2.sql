--------------------------------------------------------
--  DDL for Package HR_CAGR_ENT_ITEM_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENT_ITEM_BK2" AUTHID CURRENT_USER as
/* $Header: peceiapi.pkh 120.2 2006/10/18 08:49:35 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_cagr_entitlement_item_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cagr_entitlement_item_b
  (
   p_cagr_entitlement_item_id       in  number
  ,p_language_code                  in  varchar2
  ,p_business_group_id              in  number
  ,p_item_name                      in  varchar2
  ,p_element_type_id                in  number
  ,p_input_value_id                 in  varchar2
  ,p_column_type                    in  varchar2
  ,p_column_size                    in  number
  ,p_legislation_code               in  varchar2
  ,p_beneficial_rule                in  varchar2
  ,p_cagr_api_id                    in  number
  ,p_cagr_api_param_id              in  number
  ,p_category_name                  in  varchar2
  ,p_beneficial_formula_id          in  number
  ,p_uom                            in  varchar2
  ,p_flex_value_set_id              in  number
  ,p_object_version_number          in  number
  ,p_ben_rule_value_set_id	        in  number
  ,p_mult_entries_allowed_flag      in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_cagr_entitlement_item_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_cagr_entitlement_item_a
  (p_cagr_entitlement_item_id       in  number
  ,p_language_code                  IN  VARCHAR2
  ,p_business_group_id              in  number
  ,p_item_name                      in  varchar2
  ,p_element_type_id                in  number
  ,p_input_value_id                 in  varchar2
  ,p_column_type                    in  varchar2
  ,p_column_size                    in  number
  ,p_legislation_code               in  varchar2
  ,p_beneficial_rule                in  varchar2
  ,p_cagr_api_id                    in  number
  ,p_cagr_api_param_id              in  number
  ,p_category_name                  in  varchar2
  ,p_beneficial_formula_id          in  number
  ,p_uom                            in  varchar2
  ,p_flex_value_set_id              in  number
  ,p_object_version_number          in  number
  ,p_ben_rule_value_set_id	        in  number
  ,p_mult_entries_allowed_flag      in  varchar2
  );
--
end hr_cagr_ent_item_bk2;

/
