--------------------------------------------------------
--  DDL for Package BEN_ELIG_ENRLD_ANTHR_PTIP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_ENRLD_ANTHR_PTIP_BK2" AUTHID CURRENT_USER as
/* $Header: beeetapi.pkh 120.0 2005/05/28 02:06:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_ENRLD_ANTHR_PTIP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_ENRLD_ANTHR_PTIP_b
  (
   p_elig_enrld_anthr_ptip_id       in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_only_pls_subj_cobra_flag       in  varchar2
  ,p_ptip_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eet_attribute_category         in  varchar2
  ,p_eet_attribute1                 in  varchar2
  ,p_eet_attribute2                 in  varchar2
  ,p_eet_attribute3                 in  varchar2
  ,p_eet_attribute4                 in  varchar2
  ,p_eet_attribute5                 in  varchar2
  ,p_eet_attribute6                 in  varchar2
  ,p_eet_attribute7                 in  varchar2
  ,p_eet_attribute8                 in  varchar2
  ,p_eet_attribute9                 in  varchar2
  ,p_eet_attribute10                in  varchar2
  ,p_eet_attribute11                in  varchar2
  ,p_eet_attribute12                in  varchar2
  ,p_eet_attribute13                in  varchar2
  ,p_eet_attribute14                in  varchar2
  ,p_eet_attribute15                in  varchar2
  ,p_eet_attribute16                in  varchar2
  ,p_eet_attribute17                in  varchar2
  ,p_eet_attribute18                in  varchar2
  ,p_eet_attribute19                in  varchar2
  ,p_eet_attribute20                in  varchar2
  ,p_eet_attribute21                in  varchar2
  ,p_eet_attribute22                in  varchar2
  ,p_eet_attribute23                in  varchar2
  ,p_eet_attribute24                in  varchar2
  ,p_eet_attribute25                in  varchar2
  ,p_eet_attribute26                in  varchar2
  ,p_eet_attribute27                in  varchar2
  ,p_eet_attribute28                in  varchar2
  ,p_eet_attribute29                in  varchar2
  ,p_eet_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_ENRLD_ANTHR_PTIP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_ENRLD_ANTHR_PTIP_a
  (
   p_elig_enrld_anthr_ptip_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_only_pls_subj_cobra_flag       in  varchar2
  ,p_ptip_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eet_attribute_category         in  varchar2
  ,p_eet_attribute1                 in  varchar2
  ,p_eet_attribute2                 in  varchar2
  ,p_eet_attribute3                 in  varchar2
  ,p_eet_attribute4                 in  varchar2
  ,p_eet_attribute5                 in  varchar2
  ,p_eet_attribute6                 in  varchar2
  ,p_eet_attribute7                 in  varchar2
  ,p_eet_attribute8                 in  varchar2
  ,p_eet_attribute9                 in  varchar2
  ,p_eet_attribute10                in  varchar2
  ,p_eet_attribute11                in  varchar2
  ,p_eet_attribute12                in  varchar2
  ,p_eet_attribute13                in  varchar2
  ,p_eet_attribute14                in  varchar2
  ,p_eet_attribute15                in  varchar2
  ,p_eet_attribute16                in  varchar2
  ,p_eet_attribute17                in  varchar2
  ,p_eet_attribute18                in  varchar2
  ,p_eet_attribute19                in  varchar2
  ,p_eet_attribute20                in  varchar2
  ,p_eet_attribute21                in  varchar2
  ,p_eet_attribute22                in  varchar2
  ,p_eet_attribute23                in  varchar2
  ,p_eet_attribute24                in  varchar2
  ,p_eet_attribute25                in  varchar2
  ,p_eet_attribute26                in  varchar2
  ,p_eet_attribute27                in  varchar2
  ,p_eet_attribute28                in  varchar2
  ,p_eet_attribute29                in  varchar2
  ,p_eet_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_ENRLD_ANTHR_PTIP_bk2;

 

/