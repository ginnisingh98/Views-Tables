--------------------------------------------------------
--  DDL for Package BEN_ELIG_ENRLD_ANTHR_PL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_ENRLD_ANTHR_PL_BK1" AUTHID CURRENT_USER as
/* $Header: beeepapi.pkh 120.0 2005/05/28 02:04:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_ENRLD_ANTHR_PL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_ENRLD_ANTHR_PL_b
  (
   p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_pl_id                          in  number
  ,p_eep_attribute_category         in  varchar2
  ,p_eep_attribute1                 in  varchar2
  ,p_eep_attribute2                 in  varchar2
  ,p_eep_attribute3                 in  varchar2
  ,p_eep_attribute4                 in  varchar2
  ,p_eep_attribute5                 in  varchar2
  ,p_eep_attribute6                 in  varchar2
  ,p_eep_attribute7                 in  varchar2
  ,p_eep_attribute8                 in  varchar2
  ,p_eep_attribute9                 in  varchar2
  ,p_eep_attribute10                in  varchar2
  ,p_eep_attribute11                in  varchar2
  ,p_eep_attribute12                in  varchar2
  ,p_eep_attribute13                in  varchar2
  ,p_eep_attribute14                in  varchar2
  ,p_eep_attribute15                in  varchar2
  ,p_eep_attribute16                in  varchar2
  ,p_eep_attribute17                in  varchar2
  ,p_eep_attribute18                in  varchar2
  ,p_eep_attribute19                in  varchar2
  ,p_eep_attribute20                in  varchar2
  ,p_eep_attribute21                in  varchar2
  ,p_eep_attribute22                in  varchar2
  ,p_eep_attribute23                in  varchar2
  ,p_eep_attribute24                in  varchar2
  ,p_eep_attribute25                in  varchar2
  ,p_eep_attribute26                in  varchar2
  ,p_eep_attribute27                in  varchar2
  ,p_eep_attribute28                in  varchar2
  ,p_eep_attribute29                in  varchar2
  ,p_eep_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_ENRLD_ANTHR_PL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_ENRLD_ANTHR_PL_a
  (
   p_elig_enrld_anthr_pl_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_pl_id                          in  number
  ,p_eep_attribute_category         in  varchar2
  ,p_eep_attribute1                 in  varchar2
  ,p_eep_attribute2                 in  varchar2
  ,p_eep_attribute3                 in  varchar2
  ,p_eep_attribute4                 in  varchar2
  ,p_eep_attribute5                 in  varchar2
  ,p_eep_attribute6                 in  varchar2
  ,p_eep_attribute7                 in  varchar2
  ,p_eep_attribute8                 in  varchar2
  ,p_eep_attribute9                 in  varchar2
  ,p_eep_attribute10                in  varchar2
  ,p_eep_attribute11                in  varchar2
  ,p_eep_attribute12                in  varchar2
  ,p_eep_attribute13                in  varchar2
  ,p_eep_attribute14                in  varchar2
  ,p_eep_attribute15                in  varchar2
  ,p_eep_attribute16                in  varchar2
  ,p_eep_attribute17                in  varchar2
  ,p_eep_attribute18                in  varchar2
  ,p_eep_attribute19                in  varchar2
  ,p_eep_attribute20                in  varchar2
  ,p_eep_attribute21                in  varchar2
  ,p_eep_attribute22                in  varchar2
  ,p_eep_attribute23                in  varchar2
  ,p_eep_attribute24                in  varchar2
  ,p_eep_attribute25                in  varchar2
  ,p_eep_attribute26                in  varchar2
  ,p_eep_attribute27                in  varchar2
  ,p_eep_attribute28                in  varchar2
  ,p_eep_attribute29                in  varchar2
  ,p_eep_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELIG_ENRLD_ANTHR_PL_bk1;

 

/
