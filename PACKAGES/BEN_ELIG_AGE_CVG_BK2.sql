--------------------------------------------------------
--  DDL for Package BEN_ELIG_AGE_CVG_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_AGE_CVG_BK2" AUTHID CURRENT_USER as
/* $Header: beeacapi.pkh 120.0 2005/05/28 01:41:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_AGE_CVG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_AGE_CVG_b
  (
   p_elig_age_cvg_id                in  number
  ,p_business_group_id              in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_age_fctr_id                    in  number
  ,p_cvg_strt_cd                    in  varchar2
  ,p_cvg_strt_rl                    in  number
  ,p_cvg_thru_cd                    in  varchar2
  ,p_cvg_thru_rl                    in  number
  ,p_excld_flag                     in  varchar2
  ,p_eac_attribute_category         in  varchar2
  ,p_eac_attribute1                 in  varchar2
  ,p_eac_attribute2                 in  varchar2
  ,p_eac_attribute3                 in  varchar2
  ,p_eac_attribute4                 in  varchar2
  ,p_eac_attribute5                 in  varchar2
  ,p_eac_attribute6                 in  varchar2
  ,p_eac_attribute7                 in  varchar2
  ,p_eac_attribute8                 in  varchar2
  ,p_eac_attribute9                 in  varchar2
  ,p_eac_attribute10                in  varchar2
  ,p_eac_attribute11                in  varchar2
  ,p_eac_attribute12                in  varchar2
  ,p_eac_attribute13                in  varchar2
  ,p_eac_attribute14                in  varchar2
  ,p_eac_attribute15                in  varchar2
  ,p_eac_attribute16                in  varchar2
  ,p_eac_attribute17                in  varchar2
  ,p_eac_attribute18                in  varchar2
  ,p_eac_attribute19                in  varchar2
  ,p_eac_attribute20                in  varchar2
  ,p_eac_attribute21                in  varchar2
  ,p_eac_attribute22                in  varchar2
  ,p_eac_attribute23                in  varchar2
  ,p_eac_attribute24                in  varchar2
  ,p_eac_attribute25                in  varchar2
  ,p_eac_attribute26                in  varchar2
  ,p_eac_attribute27                in  varchar2
  ,p_eac_attribute28                in  varchar2
  ,p_eac_attribute29                in  varchar2
  ,p_eac_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_AGE_CVG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_AGE_CVG_a
  (
   p_elig_age_cvg_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_age_fctr_id                    in  number
  ,p_cvg_strt_cd                    in  varchar2
  ,p_cvg_strt_rl                    in  number
  ,p_cvg_thru_cd                    in  varchar2
  ,p_cvg_thru_rl                    in  number
  ,p_excld_flag                     in  varchar2
  ,p_eac_attribute_category         in  varchar2
  ,p_eac_attribute1                 in  varchar2
  ,p_eac_attribute2                 in  varchar2
  ,p_eac_attribute3                 in  varchar2
  ,p_eac_attribute4                 in  varchar2
  ,p_eac_attribute5                 in  varchar2
  ,p_eac_attribute6                 in  varchar2
  ,p_eac_attribute7                 in  varchar2
  ,p_eac_attribute8                 in  varchar2
  ,p_eac_attribute9                 in  varchar2
  ,p_eac_attribute10                in  varchar2
  ,p_eac_attribute11                in  varchar2
  ,p_eac_attribute12                in  varchar2
  ,p_eac_attribute13                in  varchar2
  ,p_eac_attribute14                in  varchar2
  ,p_eac_attribute15                in  varchar2
  ,p_eac_attribute16                in  varchar2
  ,p_eac_attribute17                in  varchar2
  ,p_eac_attribute18                in  varchar2
  ,p_eac_attribute19                in  varchar2
  ,p_eac_attribute20                in  varchar2
  ,p_eac_attribute21                in  varchar2
  ,p_eac_attribute22                in  varchar2
  ,p_eac_attribute23                in  varchar2
  ,p_eac_attribute24                in  varchar2
  ,p_eac_attribute25                in  varchar2
  ,p_eac_attribute26                in  varchar2
  ,p_eac_attribute27                in  varchar2
  ,p_eac_attribute28                in  varchar2
  ,p_eac_attribute29                in  varchar2
  ,p_eac_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_AGE_CVG_bk2;

 

/
