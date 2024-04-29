--------------------------------------------------------
--  DDL for Package HR_DE_SOC_INS_CLE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_SOC_INS_CLE_BK2" AUTHID CURRENT_USER as
/* $Header: hrcleapi.pkh 120.1 2005/10/02 02:00:02 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_soc_ins_contributions_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_soc_ins_contributions_b
  (
   p_soc_ins_contr_lvls_id         IN      number
  , p_organization_id              IN      number
  , p_normal_percentage            IN      number
  , p_normal_amount                IN      number
  , p_increased_percentage         IN      number
  , p_increased_amount             IN      number
  , p_reduced_percentage           IN      number
  , p_reduced_amount               IN      number
  , p_attribute_category           IN      varchar2
  , p_attribute1 		   IN      varchar2
  , p_attribute2		   IN      varchar2
  , p_attribute3 		   IN      varchar2
  , p_attribute4		   IN      varchar2
  , p_attribute5		   IN      varchar2
  , p_attribute6 		   IN      varchar2
  , p_attribute7 		   IN      varchar2
  , p_attribute8 		   IN      varchar2
  , p_attribute9 		   IN      varchar2
  , p_attribute10 		   IN      varchar2
  , p_attribute11 		   IN      varchar2
  , p_attribute12 		   IN      varchar2
  , p_attribute13 		   IN      varchar2
  , p_attribute14 		   IN      varchar2
  , p_attribute15 		   IN      varchar2
  , p_attribute16 		   IN      varchar2
  , p_attribute17 		   IN      varchar2
  , p_attribute18 		   IN      varchar2
  , p_attribute19 		   IN      varchar2
  , p_attribute20 		   IN      varchar2
  , p_attribute21 		   IN      varchar2
  , p_attribute22 		   IN      varchar2
  , p_attribute23 		   IN      varchar2
  , p_attribute24 		   IN      varchar2
  , p_attribute25 		   IN      varchar2
  , p_attribute26 		   IN      varchar2
  , p_attribute27 		   IN      varchar2
  , p_attribute28 		   IN      varchar2
  , p_attribute29 		   IN      varchar2
  , p_attribute30 		   IN      varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  , p_flat_tax_limit_per_month	   IN      number
  , p_flat_tax_limit_per_year	   IN      number
  , p_min_increased_contribution   IN      number
  , p_max_increased_contribution   IN      number
  , p_month1			   IN      varchar2
  , p_month1_min_contribution      IN      number
  , p_month1_max_contribution      IN      number
  , p_month2		 	   IN      varchar2
  , p_month2_min_contribution      IN      number
  , p_month2_max_contribution      IN      number
  , p_employee_contribution	   IN      number
  , p_contribution_level_type  		   IN      varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_soc_ins_contributions_a  >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_soc_ins_contributions_a
  (
    p_soc_ins_contr_lvls_id        IN      number
  , p_organization_id              IN      number
  , p_normal_percentage            IN      number
  , p_normal_amount                IN      number
  , p_increased_percentage         IN      number
  , p_increased_amount             IN      number
  , p_reduced_percentage           IN      number
  , p_reduced_amount               IN      number
  , p_attribute_category           IN      varchar2
  , p_attribute1 		   IN      varchar2
  , p_attribute2		   IN      varchar2
  , p_attribute3 		   IN      varchar2
  , p_attribute4		   IN      varchar2
  , p_attribute5		   IN      varchar2
  , p_attribute6 		   IN      varchar2
  , p_attribute7 		   IN      varchar2
  , p_attribute8 		   IN      varchar2
  , p_attribute9 		   IN      varchar2
  , p_attribute10 		   IN      varchar2
  , p_attribute11 		   IN      varchar2
  , p_attribute12 		   IN      varchar2
  , p_attribute13 		   IN      varchar2
  , p_attribute14 		   IN      varchar2
  , p_attribute15 		   IN      varchar2
  , p_attribute16 		   IN      varchar2
  , p_attribute17 		   IN      varchar2
  , p_attribute18 		   IN      varchar2
  , p_attribute19 		   IN      varchar2
  , p_attribute20 		   IN      varchar2
  , p_attribute21 		   IN      varchar2
  , p_attribute22 		   IN      varchar2
  , p_attribute23 		   IN      varchar2
  , p_attribute24 		   IN      varchar2
  , p_attribute25 		   IN      varchar2
  , p_attribute26 		   IN      varchar2
  , p_attribute27 		   IN      varchar2
  , p_attribute28 		   IN      varchar2
  , p_attribute29 		   IN      varchar2
  , p_attribute30 		   IN      varchar2
  , p_effective_start_date         IN      date
  , p_effective_end_date           IN      date
  , p_object_version_number        IN      number
  , p_effective_date               IN      date
  , p_datetrack_mode               IN      varchar2
  , p_flat_tax_limit_per_month	   IN      number
  , p_flat_tax_limit_per_year	   IN      number
  , p_min_increased_contribution   IN      number
  , p_max_increased_contribution   IN      number
  , p_month1			   IN      varchar2
  , p_month1_min_contribution      IN      number
  , p_month1_max_contribution      IN      number
  , p_month2		 	   IN      varchar2
  , p_month2_min_contribution      IN      number
  , p_month2_max_contribution      IN      number
  , p_employee_contribution	   IN      number
  , p_contribution_level_type  		   IN      varchar2
  );
--
end hr_de_soc_ins_cle_bk2;

 

/
