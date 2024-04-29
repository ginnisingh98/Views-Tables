--------------------------------------------------------
--  DDL for Package BEN_EOY_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EOY_RKI" AUTHID CURRENT_USER as
/* $Header: beeoyrhi.pkh 120.0 2005/05/28 02:34:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_othr_ptip_prte_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_only_pls_subj_cobra_flag       in varchar2
 ,p_eligy_prfl_id                  in number
 ,p_ptip_id                        in number
 ,p_business_group_id              in number
 ,p_eoy_attribute_category         in varchar2
 ,p_eoy_attribute1                 in varchar2
 ,p_eoy_attribute2                 in varchar2
 ,p_eoy_attribute3                 in varchar2
 ,p_eoy_attribute4                 in varchar2
 ,p_eoy_attribute5                 in varchar2
 ,p_eoy_attribute6                 in varchar2
 ,p_eoy_attribute7                 in varchar2
 ,p_eoy_attribute8                 in varchar2
 ,p_eoy_attribute9                 in varchar2
 ,p_eoy_attribute10                in varchar2
 ,p_eoy_attribute11                in varchar2
 ,p_eoy_attribute12                in varchar2
 ,p_eoy_attribute13                in varchar2
 ,p_eoy_attribute14                in varchar2
 ,p_eoy_attribute15                in varchar2
 ,p_eoy_attribute16                in varchar2
 ,p_eoy_attribute17                in varchar2
 ,p_eoy_attribute18                in varchar2
 ,p_eoy_attribute19                in varchar2
 ,p_eoy_attribute20                in varchar2
 ,p_eoy_attribute21                in varchar2
 ,p_eoy_attribute22                in varchar2
 ,p_eoy_attribute23                in varchar2
 ,p_eoy_attribute24                in varchar2
 ,p_eoy_attribute25                in varchar2
 ,p_eoy_attribute26                in varchar2
 ,p_eoy_attribute27                in varchar2
 ,p_eoy_attribute28                in varchar2
 ,p_eoy_attribute29                in varchar2
 ,p_eoy_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_eoy_rki;

 

/
