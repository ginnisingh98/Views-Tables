--------------------------------------------------------
--  DDL for Package BEN_EPF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPF_RKI" AUTHID CURRENT_USER as
/* $Header: beepfrhi.pkh 120.0 2005/05/28 02:38:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_pct_fl_tm_prte_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_eligy_prfl_id                  in number
 ,p_pct_fl_tm_fctr_id              in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_epf_attribute_category         in varchar2
 ,p_epf_attribute1                 in varchar2
 ,p_epf_attribute2                 in varchar2
 ,p_epf_attribute3                 in varchar2
 ,p_epf_attribute4                 in varchar2
 ,p_epf_attribute5                 in varchar2
 ,p_epf_attribute6                 in varchar2
 ,p_epf_attribute7                 in varchar2
 ,p_epf_attribute8                 in varchar2
 ,p_epf_attribute9                 in varchar2
 ,p_epf_attribute10                in varchar2
 ,p_epf_attribute11                in varchar2
 ,p_epf_attribute12                in varchar2
 ,p_epf_attribute13                in varchar2
 ,p_epf_attribute14                in varchar2
 ,p_epf_attribute15                in varchar2
 ,p_epf_attribute16                in varchar2
 ,p_epf_attribute17                in varchar2
 ,p_epf_attribute18                in varchar2
 ,p_epf_attribute19                in varchar2
 ,p_epf_attribute20                in varchar2
 ,p_epf_attribute21                in varchar2
 ,p_epf_attribute22                in varchar2
 ,p_epf_attribute23                in varchar2
 ,p_epf_attribute24                in varchar2
 ,p_epf_attribute25                in varchar2
 ,p_epf_attribute26                in varchar2
 ,p_epf_attribute27                in varchar2
 ,p_epf_attribute28                in varchar2
 ,p_epf_attribute29                in varchar2
 ,p_epf_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_epf_rki;

 

/
