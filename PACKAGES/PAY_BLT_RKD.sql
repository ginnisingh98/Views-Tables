--------------------------------------------------------
--  DDL for Package PAY_BLT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BLT_RKD" AUTHID CURRENT_USER as
/* $Header: pybltrhi.pkh 120.0 2005/05/29 03:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_balance_type_id              in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_currency_code_o              in varchar2
  ,p_assignment_remuneration_fl_o in varchar2
  ,p_balance_name_o               in varchar2
  ,p_balance_uom_o                in varchar2
  ,p_comments_o                   in varchar2
  ,p_legislation_subgroup_o       in varchar2
  ,p_reporting_name_o             in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_jurisdiction_level_o         in number
  ,p_tax_type_o                   in varchar2
  ,p_object_version_number_o      in number
  ,p_balance_category_id_o        in number
  ,p_base_balance_type_id_o       in number
  ,p_input_value_id_o             in number
  );
--
end pay_blt_rkd;

 

/
