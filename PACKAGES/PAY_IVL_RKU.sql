--------------------------------------------------------
--  DDL for Package PAY_IVL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IVL_RKU" AUTHID CURRENT_USER as
/* $Header: pyivlrhi.pkh 120.0 2005/05/29 06:04:54 appldev noship $ */
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
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_element_type_id_o            in number
  ,p_lookup_type_o                in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_formula_id_o                 in number
  ,p_value_set_id_o               in number
  ,p_display_sequence_o           in number
  ,p_generate_db_items_flag_o     in varchar2
  ,p_hot_default_flag_o           in varchar2
  ,p_mandatory_flag_o             in varchar2
  ,p_name_o                       in varchar2
  ,p_uom_o                        in varchar2
  ,p_default_value_o              in varchar2
  ,p_legislation_subgroup_o       in varchar2
  ,p_max_value_o                  in varchar2
  ,p_min_value_o                  in varchar2
  ,p_warning_or_error_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_ivl_rku;

 

/
