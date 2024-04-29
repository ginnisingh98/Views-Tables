--------------------------------------------------------
--  DDL for Package PAY_IVL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IVL_RKI" AUTHID CURRENT_USER as
/* $Header: pyivlrhi.pkh 120.0 2005/05/29 06:04:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_input_value_id               in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_element_type_id              in number
  ,p_lookup_type                  in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_formula_id                   in number
  ,p_value_set_id                 in number
  ,p_display_sequence             in number
  ,p_generate_db_items_flag       in varchar2
  ,p_hot_default_flag             in varchar2
  ,p_mandatory_flag               in varchar2
  ,p_name                         in varchar2
  ,p_uom                          in varchar2
  ,p_default_value                in varchar2
  ,p_legislation_subgroup         in varchar2
  ,p_max_value                    in varchar2
  ,p_min_value                    in varchar2
  ,p_warning_or_error             in varchar2
  ,p_object_version_number        in number
  );
end pay_ivl_rki;

 

/
