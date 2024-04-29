--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVG_ELIG_PRFL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVG_ELIG_PRFL_BK2" AUTHID CURRENT_USER as
/* $Header: bedceapi.pkh 120.0.12010000.2 2010/04/07 06:40:30 pvelvano ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_DPNT_CVG_ELIG_PRFL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_DPNT_CVG_ELIG_PRFL_b
  (
   p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_business_group_id              in  number
  ,p_regn_id                        in  number
  ,p_name                           in  varchar2
  ,p_dpnt_cvg_eligy_prfl_stat_cd    in  varchar2
  ,p_dce_desc                       in  varchar2
  ,p_dpnt_cvg_elig_det_rl           in  number
  ,p_dce_attribute_category         in  varchar2
  ,p_dce_attribute1                 in  varchar2
  ,p_dce_attribute2                 in  varchar2
  ,p_dce_attribute3                 in  varchar2
  ,p_dce_attribute4                 in  varchar2
  ,p_dce_attribute5                 in  varchar2
  ,p_dce_attribute6                 in  varchar2
  ,p_dce_attribute7                 in  varchar2
  ,p_dce_attribute8                 in  varchar2
  ,p_dce_attribute9                 in  varchar2
  ,p_dce_attribute10                in  varchar2
  ,p_dce_attribute11                in  varchar2
  ,p_dce_attribute12                in  varchar2
  ,p_dce_attribute13                in  varchar2
  ,p_dce_attribute14                in  varchar2
  ,p_dce_attribute15                in  varchar2
  ,p_dce_attribute16                in  varchar2
  ,p_dce_attribute17                in  varchar2
  ,p_dce_attribute18                in  varchar2
  ,p_dce_attribute19                in  varchar2
  ,p_dce_attribute20                in  varchar2
  ,p_dce_attribute21                in  varchar2
  ,p_dce_attribute22                in  varchar2
  ,p_dce_attribute23                in  varchar2
  ,p_dce_attribute24                in  varchar2
  ,p_dce_attribute25                in  varchar2
  ,p_dce_attribute26                in  varchar2
  ,p_dce_attribute27                in  varchar2
  ,p_dce_attribute28                in  varchar2
  ,p_dce_attribute29                in  varchar2
  ,p_dce_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_dpnt_rlshp_flag	            in  varchar2
  ,p_dpnt_age_flag                  in  varchar2
  ,p_dpnt_stud_flag                 in  varchar2
  ,p_dpnt_dsbld_flag                in  varchar2
  ,p_dpnt_mrtl_flag                 in  varchar2
  ,p_dpnt_mltry_flag                in  varchar2
  ,p_dpnt_pstl_flag                 in  varchar2
  ,p_dpnt_cvrd_in_anthr_pl_flag     in  varchar2
  ,p_dpnt_dsgnt_crntly_enrld_flag   in  varchar2
  ,p_dpnt_crit_flag                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_DPNT_CVG_ELIG_PRFL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_DPNT_CVG_ELIG_PRFL_a
  (
   p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_effective_end_date             in  date
  ,p_effective_start_date           in  date
  ,p_business_group_id              in  number
  ,p_regn_id                        in  number
  ,p_name                           in  varchar2
  ,p_dpnt_cvg_eligy_prfl_stat_cd    in  varchar2
  ,p_dce_desc                       in  varchar2
  ,p_dpnt_cvg_elig_det_rl           in  number
  ,p_dce_attribute_category         in  varchar2
  ,p_dce_attribute1                 in  varchar2
  ,p_dce_attribute2                 in  varchar2
  ,p_dce_attribute3                 in  varchar2
  ,p_dce_attribute4                 in  varchar2
  ,p_dce_attribute5                 in  varchar2
  ,p_dce_attribute6                 in  varchar2
  ,p_dce_attribute7                 in  varchar2
  ,p_dce_attribute8                 in  varchar2
  ,p_dce_attribute9                 in  varchar2
  ,p_dce_attribute10                in  varchar2
  ,p_dce_attribute11                in  varchar2
  ,p_dce_attribute12                in  varchar2
  ,p_dce_attribute13                in  varchar2
  ,p_dce_attribute14                in  varchar2
  ,p_dce_attribute15                in  varchar2
  ,p_dce_attribute16                in  varchar2
  ,p_dce_attribute17                in  varchar2
  ,p_dce_attribute18                in  varchar2
  ,p_dce_attribute19                in  varchar2
  ,p_dce_attribute20                in  varchar2
  ,p_dce_attribute21                in  varchar2
  ,p_dce_attribute22                in  varchar2
  ,p_dce_attribute23                in  varchar2
  ,p_dce_attribute24                in  varchar2
  ,p_dce_attribute25                in  varchar2
  ,p_dce_attribute26                in  varchar2
  ,p_dce_attribute27                in  varchar2
  ,p_dce_attribute28                in  varchar2
  ,p_dce_attribute29                in  varchar2
  ,p_dce_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_dpnt_rlshp_flag	            in  varchar2
  ,p_dpnt_age_flag                  in  varchar2
  ,p_dpnt_stud_flag                 in  varchar2
  ,p_dpnt_dsbld_flag                in  varchar2
  ,p_dpnt_mrtl_flag                 in  varchar2
  ,p_dpnt_mltry_flag                in  varchar2
  ,p_dpnt_pstl_flag                 in  varchar2
  ,p_dpnt_cvrd_in_anthr_pl_flag     in  varchar2
  ,p_dpnt_dsgnt_crntly_enrld_flag   in  varchar2
  ,p_dpnt_crit_flag                 in  varchar2
  );
--
end ben_DPNT_CVG_ELIG_PRFL_bk2;

/
