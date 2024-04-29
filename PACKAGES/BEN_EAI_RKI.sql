--------------------------------------------------------
--  DDL for Package BEN_EAI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EAI_RKI" AUTHID CURRENT_USER as
/* $Header: beeairhi.pkh 120.0 2005/05/28 01:42:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_enrld_anthr_plip_id       in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_enrl_det_dt_cd                 in varchar2
 ,p_ordr_num                       in number
 ,p_plip_id                        in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_eai_attribute_category         in varchar2
 ,p_eai_attribute1                 in varchar2
 ,p_eai_attribute2                 in varchar2
 ,p_eai_attribute3                 in varchar2
 ,p_eai_attribute4                 in varchar2
 ,p_eai_attribute5                 in varchar2
 ,p_eai_attribute6                 in varchar2
 ,p_eai_attribute7                 in varchar2
 ,p_eai_attribute8                 in varchar2
 ,p_eai_attribute9                 in varchar2
 ,p_eai_attribute10                in varchar2
 ,p_eai_attribute11                in varchar2
 ,p_eai_attribute12                in varchar2
 ,p_eai_attribute13                in varchar2
 ,p_eai_attribute14                in varchar2
 ,p_eai_attribute15                in varchar2
 ,p_eai_attribute16                in varchar2
 ,p_eai_attribute17                in varchar2
 ,p_eai_attribute18                in varchar2
 ,p_eai_attribute19                in varchar2
 ,p_eai_attribute20                in varchar2
 ,p_eai_attribute21                in varchar2
 ,p_eai_attribute22                in varchar2
 ,p_eai_attribute23                in varchar2
 ,p_eai_attribute24                in varchar2
 ,p_eai_attribute25                in varchar2
 ,p_eai_attribute26                in varchar2
 ,p_eai_attribute27                in varchar2
 ,p_eai_attribute28                in varchar2
 ,p_eai_attribute29                in varchar2
 ,p_eai_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_eai_rki;

 

/
