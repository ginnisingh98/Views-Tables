--------------------------------------------------------
--  DDL for Package BEN_ELIG_STDNT_STAT_CVG_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_STDNT_STAT_CVG_BK1" AUTHID CURRENT_USER as
/* $Header: beescapi.pkh 120.0 2005/05/28 02:54:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_STDNT_STAT_CVG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_STDNT_STAT_CVG_b
  (
   p_business_group_id              in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_cvg_strt_cd                    in  varchar2
  ,p_cvg_strt_rl                    in  number
  ,p_cvg_thru_cd                    in  varchar2
  ,p_cvg_thru_rl                    in  number
  ,p_stdnt_stat_cd                  in  varchar2
  ,p_esc_attribute_category         in  varchar2
  ,p_esc_attribute1                 in  varchar2
  ,p_esc_attribute2                 in  varchar2
  ,p_esc_attribute3                 in  varchar2
  ,p_esc_attribute4                 in  varchar2
  ,p_esc_attribute5                 in  varchar2
  ,p_esc_attribute6                 in  varchar2
  ,p_esc_attribute7                 in  varchar2
  ,p_esc_attribute8                 in  varchar2
  ,p_esc_attribute9                 in  varchar2
  ,p_esc_attribute10                in  varchar2
  ,p_esc_attribute11                in  varchar2
  ,p_esc_attribute12                in  varchar2
  ,p_esc_attribute13                in  varchar2
  ,p_esc_attribute14                in  varchar2
  ,p_esc_attribute15                in  varchar2
  ,p_esc_attribute16                in  varchar2
  ,p_esc_attribute17                in  varchar2
  ,p_esc_attribute18                in  varchar2
  ,p_esc_attribute19                in  varchar2
  ,p_esc_attribute20                in  varchar2
  ,p_esc_attribute21                in  varchar2
  ,p_esc_attribute22                in  varchar2
  ,p_esc_attribute23                in  varchar2
  ,p_esc_attribute24                in  varchar2
  ,p_esc_attribute25                in  varchar2
  ,p_esc_attribute26                in  varchar2
  ,p_esc_attribute27                in  varchar2
  ,p_esc_attribute28                in  varchar2
  ,p_esc_attribute29                in  varchar2
  ,p_esc_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_STDNT_STAT_CVG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_STDNT_STAT_CVG_a
  (
   p_elig_stdnt_stat_cvg_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_cvg_strt_cd                    in  varchar2
  ,p_cvg_strt_rl                    in  number
  ,p_cvg_thru_cd                    in  varchar2
  ,p_cvg_thru_rl                    in  number
  ,p_stdnt_stat_cd                  in  varchar2
  ,p_esc_attribute_category         in  varchar2
  ,p_esc_attribute1                 in  varchar2
  ,p_esc_attribute2                 in  varchar2
  ,p_esc_attribute3                 in  varchar2
  ,p_esc_attribute4                 in  varchar2
  ,p_esc_attribute5                 in  varchar2
  ,p_esc_attribute6                 in  varchar2
  ,p_esc_attribute7                 in  varchar2
  ,p_esc_attribute8                 in  varchar2
  ,p_esc_attribute9                 in  varchar2
  ,p_esc_attribute10                in  varchar2
  ,p_esc_attribute11                in  varchar2
  ,p_esc_attribute12                in  varchar2
  ,p_esc_attribute13                in  varchar2
  ,p_esc_attribute14                in  varchar2
  ,p_esc_attribute15                in  varchar2
  ,p_esc_attribute16                in  varchar2
  ,p_esc_attribute17                in  varchar2
  ,p_esc_attribute18                in  varchar2
  ,p_esc_attribute19                in  varchar2
  ,p_esc_attribute20                in  varchar2
  ,p_esc_attribute21                in  varchar2
  ,p_esc_attribute22                in  varchar2
  ,p_esc_attribute23                in  varchar2
  ,p_esc_attribute24                in  varchar2
  ,p_esc_attribute25                in  varchar2
  ,p_esc_attribute26                in  varchar2
  ,p_esc_attribute27                in  varchar2
  ,p_esc_attribute28                in  varchar2
  ,p_esc_attribute29                in  varchar2
  ,p_esc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELIG_STDNT_STAT_CVG_bk1;

 

/
