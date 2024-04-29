--------------------------------------------------------
--  DDL for Package BEN_EHW_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EHW_RKI" AUTHID CURRENT_USER as
/* $Header: beehwrhi.pkh 120.0 2005/05/28 02:15:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_hrs_wkd_prte_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_eligy_prfl_id                  in number
 ,p_hrs_wkd_in_perd_fctr_id        in number
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_ehw_attribute_category         in varchar2
 ,p_ehw_attribute1                 in varchar2
 ,p_ehw_attribute2                 in varchar2
 ,p_ehw_attribute3                 in varchar2
 ,p_ehw_attribute4                 in varchar2
 ,p_ehw_attribute5                 in varchar2
 ,p_ehw_attribute6                 in varchar2
 ,p_ehw_attribute7                 in varchar2
 ,p_ehw_attribute8                 in varchar2
 ,p_ehw_attribute9                 in varchar2
 ,p_ehw_attribute10                in varchar2
 ,p_ehw_attribute11                in varchar2
 ,p_ehw_attribute12                in varchar2
 ,p_ehw_attribute13                in varchar2
 ,p_ehw_attribute14                in varchar2
 ,p_ehw_attribute15                in varchar2
 ,p_ehw_attribute16                in varchar2
 ,p_ehw_attribute17                in varchar2
 ,p_ehw_attribute18                in varchar2
 ,p_ehw_attribute19                in varchar2
 ,p_ehw_attribute20                in varchar2
 ,p_ehw_attribute21                in varchar2
 ,p_ehw_attribute22                in varchar2
 ,p_ehw_attribute23                in varchar2
 ,p_ehw_attribute24                in varchar2
 ,p_ehw_attribute25                in varchar2
 ,p_ehw_attribute26                in varchar2
 ,p_ehw_attribute27                in varchar2
 ,p_ehw_attribute28                in varchar2
 ,p_ehw_attribute29                in varchar2
 ,p_ehw_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_ehw_rki;

 

/
