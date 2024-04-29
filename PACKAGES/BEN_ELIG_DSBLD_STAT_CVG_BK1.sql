--------------------------------------------------------
--  DDL for Package BEN_ELIG_DSBLD_STAT_CVG_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DSBLD_STAT_CVG_BK1" AUTHID CURRENT_USER as
/* $Header: beedcapi.pkh 120.0 2005/05/28 01:56:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_DSBLD_STAT_CVG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_DSBLD_STAT_CVG_b
  (
   p_business_group_id              in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_cvg_strt_cd                    in  varchar2
  ,p_cvg_strt_rl                    in  number
  ,p_cvg_thru_cd                    in  varchar2
  ,p_cvg_thru_rl                    in  number
  ,p_dsbld_cd                       in  varchar2
  ,p_edc_attribute_category         in  varchar2
  ,p_edc_attribute1                 in  varchar2
  ,p_edc_attribute2                 in  varchar2
  ,p_edc_attribute3                 in  varchar2
  ,p_edc_attribute4                 in  varchar2
  ,p_edc_attribute5                 in  varchar2
  ,p_edc_attribute6                 in  varchar2
  ,p_edc_attribute7                 in  varchar2
  ,p_edc_attribute8                 in  varchar2
  ,p_edc_attribute9                 in  varchar2
  ,p_edc_attribute10                in  varchar2
  ,p_edc_attribute11                in  varchar2
  ,p_edc_attribute12                in  varchar2
  ,p_edc_attribute13                in  varchar2
  ,p_edc_attribute14                in  varchar2
  ,p_edc_attribute15                in  varchar2
  ,p_edc_attribute16                in  varchar2
  ,p_edc_attribute17                in  varchar2
  ,p_edc_attribute18                in  varchar2
  ,p_edc_attribute19                in  varchar2
  ,p_edc_attribute20                in  varchar2
  ,p_edc_attribute21                in  varchar2
  ,p_edc_attribute22                in  varchar2
  ,p_edc_attribute23                in  varchar2
  ,p_edc_attribute24                in  varchar2
  ,p_edc_attribute25                in  varchar2
  ,p_edc_attribute26                in  varchar2
  ,p_edc_attribute27                in  varchar2
  ,p_edc_attribute28                in  varchar2
  ,p_edc_attribute29                in  varchar2
  ,p_edc_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_DSBLD_STAT_CVG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_DSBLD_STAT_CVG_a
  (
   p_elig_dsbld_stat_cvg_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_cvg_strt_cd                    in  varchar2
  ,p_cvg_strt_rl                    in  number
  ,p_cvg_thru_cd                    in  varchar2
  ,p_cvg_thru_rl                    in  number
  ,p_dsbld_cd                       in  varchar2
  ,p_edc_attribute_category         in  varchar2
  ,p_edc_attribute1                 in  varchar2
  ,p_edc_attribute2                 in  varchar2
  ,p_edc_attribute3                 in  varchar2
  ,p_edc_attribute4                 in  varchar2
  ,p_edc_attribute5                 in  varchar2
  ,p_edc_attribute6                 in  varchar2
  ,p_edc_attribute7                 in  varchar2
  ,p_edc_attribute8                 in  varchar2
  ,p_edc_attribute9                 in  varchar2
  ,p_edc_attribute10                in  varchar2
  ,p_edc_attribute11                in  varchar2
  ,p_edc_attribute12                in  varchar2
  ,p_edc_attribute13                in  varchar2
  ,p_edc_attribute14                in  varchar2
  ,p_edc_attribute15                in  varchar2
  ,p_edc_attribute16                in  varchar2
  ,p_edc_attribute17                in  varchar2
  ,p_edc_attribute18                in  varchar2
  ,p_edc_attribute19                in  varchar2
  ,p_edc_attribute20                in  varchar2
  ,p_edc_attribute21                in  varchar2
  ,p_edc_attribute22                in  varchar2
  ,p_edc_attribute23                in  varchar2
  ,p_edc_attribute24                in  varchar2
  ,p_edc_attribute25                in  varchar2
  ,p_edc_attribute26                in  varchar2
  ,p_edc_attribute27                in  varchar2
  ,p_edc_attribute28                in  varchar2
  ,p_edc_attribute29                in  varchar2
  ,p_edc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELIG_DSBLD_STAT_CVG_bk1;

 

/
