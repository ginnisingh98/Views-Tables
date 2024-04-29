--------------------------------------------------------
--  DDL for Package HR_CLE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CLE_RKI" AUTHID CURRENT_USER as
/* $Header: hrclerhi.pkh 120.0 2005/05/30 23:14:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_soc_ins_contr_lvls_id        in number
  ,p_organization_id              in number
  ,p_normal_percentage            in number
  ,p_normal_amount                in number
  ,p_increased_percentage         in number
  ,p_increased_amount             in number
  ,p_reduced_percentage           in number
  ,p_reduced_amount               in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
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
  ,p_object_version_number        in number
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
  ,p_flat_tax_limit_per_month	  in number
  ,p_flat_tax_limit_per_year	  in number
  ,p_min_increased_contribution   in number
  ,p_max_increased_contribution   in number
  ,p_month1			  in varchar2
  ,p_month1_min_contribution  in number
  ,p_month1_max_contribution  in number
  ,p_month2			  in varchar2
  ,p_month2_min_contribution  in number
  ,p_month2_max_contribution  in number
  ,p_employee_contribution	  in number
  ,p_contribution_level_type  		  in varchar2
  );
end hr_cle_rki;

 

/
