--------------------------------------------------------
--  DDL for Package PQH_CRD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRD_RKU" AUTHID CURRENT_USER as
/* $Header: pqcrdrhi.pkh 120.0 2005/05/29 01:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_criteria_rate_defn_id        in number
  ,p_short_name                   in varchar2
  ,p_uom                          in varchar2
  ,p_currency_code                in varchar2
  ,p_reference_period_cd          in varchar2
  ,p_define_max_rate_flag         in varchar2
  ,p_define_min_rate_flag         in varchar2
  ,p_define_mid_rate_flag         in varchar2
  ,p_define_std_rate_flag         in varchar2
  ,p_rate_calc_cd                 in varchar2
  ,p_rate_calc_rule               in number
  ,p_preferential_rate_cd         in varchar2
  ,p_preferential_rate_rule       in number
  ,p_rounding_cd                  in varchar2
  ,p_rounding_rule                in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  ,p_object_version_number        in number
  ,p_short_name_o                 in varchar2
  ,p_uom_o                        in varchar2
  ,p_currency_code_o              in varchar2
  ,p_reference_period_cd_o        in varchar2
  ,p_define_max_rate_flag_o       in varchar2
  ,p_define_min_rate_flag_o       in varchar2
  ,p_define_mid_rate_flag_o       in varchar2
  ,p_define_std_rate_flag_o       in varchar2
  ,p_rate_calc_cd_o               in varchar2
  ,p_rate_calc_rule_o             in number
  ,p_preferential_rate_cd_o       in varchar2
  ,p_preferential_rate_rule_o     in number
  ,p_rounding_cd_o                in varchar2
  ,p_rounding_rule_o              in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
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
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_crd_rku;

 

/