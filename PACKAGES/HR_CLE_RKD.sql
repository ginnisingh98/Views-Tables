--------------------------------------------------------
--  DDL for Package HR_CLE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CLE_RKD" AUTHID CURRENT_USER as
/* $Header: hrclerhi.pkh 120.0 2005/05/30 23:14:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_soc_ins_contr_lvls_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_organization_id_o            in number
  ,p_normal_percentage_o          in number
  ,p_normal_amount_o              in number
  ,p_increased_percentage_o       in number
  ,p_increased_amount_o           in number
  ,p_reduced_percentage_o         in number
  ,p_reduced_amount_o             in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
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
  ,p_object_version_number_o      in number
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
  ,p_flat_tax_limit_per_month_o	  in number
  ,p_flat_tax_limit_per_year_o	  in number
  ,p_min_increased_contribution_o in number
  ,p_max_increased_contribution_o in number
  ,p_month1_o			  in varchar2
  ,p_month1_min_contribution_o in number
  ,p_month1_max_contribution_o in number
  ,p_month2_o			  in varchar2
  ,p_month2_min_contribution_o  in number
  ,p_month2_max_contribution_o  in number
  ,p_employee_contribution_o	  in number
  ,p_contribution_level_type_o   in varchar2
  );
--
end hr_cle_rkd;

 

/
