--------------------------------------------------------
--  DDL for Package BEN_EOM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EOM_RKI" AUTHID CURRENT_USER as
/* $Header: beeomrhi.pkh 120.0 2005/05/28 02:32:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_optd_mdcr_prte_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_optd_mdcr_flag                 in varchar2
 ,p_exlcd_flag                     in varchar2
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_eom_attribute_category         in varchar2
 ,p_eom_attribute1                 in varchar2
 ,p_eom_attribute2                 in varchar2
 ,p_eom_attribute3                 in varchar2
 ,p_eom_attribute4                 in varchar2
 ,p_eom_attribute5                 in varchar2
 ,p_eom_attribute6                 in varchar2
 ,p_eom_attribute7                 in varchar2
 ,p_eom_attribute8                 in varchar2
 ,p_eom_attribute9                 in varchar2
 ,p_eom_attribute10                in varchar2
 ,p_eom_attribute11                in varchar2
 ,p_eom_attribute12                in varchar2
 ,p_eom_attribute13                in varchar2
 ,p_eom_attribute14                in varchar2
 ,p_eom_attribute15                in varchar2
 ,p_eom_attribute16                in varchar2
 ,p_eom_attribute17                in varchar2
 ,p_eom_attribute18                in varchar2
 ,p_eom_attribute19                in varchar2
 ,p_eom_attribute20                in varchar2
 ,p_eom_attribute21                in varchar2
 ,p_eom_attribute22                in varchar2
 ,p_eom_attribute23                in varchar2
 ,p_eom_attribute24                in varchar2
 ,p_eom_attribute25                in varchar2
 ,p_eom_attribute26                in varchar2
 ,p_eom_attribute27                in varchar2
 ,p_eom_attribute28                in varchar2
 ,p_eom_attribute29                in varchar2
 ,p_eom_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_eom_rki;

 

/
