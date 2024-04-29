--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVRD_OTHR_PGM_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVRD_OTHR_PGM_RT_BK2" AUTHID CURRENT_USER as
/* $Header: bedopapi.pkh 120.0 2005/05/28 01:37:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_DPNT_CVRD_OTHR_PGM_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_DPNT_CVRD_OTHR_PGM_RT_b
  (
   p_dpnt_cvrd_othr_pgm_rt_id     in  number
  ,p_excld_flag                     in  varchar2
  ,p_only_pls_subj_cobra_flag       in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_ordr_num                       in  number
  ,p_pgm_id                         in  number
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_dop_attribute_category         in  varchar2
  ,p_dop_attribute1                 in  varchar2
  ,p_dop_attribute2                 in  varchar2
  ,p_dop_attribute3                 in  varchar2
  ,p_dop_attribute4                 in  varchar2
  ,p_dop_attribute5                 in  varchar2
  ,p_dop_attribute6                 in  varchar2
  ,p_dop_attribute7                 in  varchar2
  ,p_dop_attribute8                 in  varchar2
  ,p_dop_attribute9                 in  varchar2
  ,p_dop_attribute10                in  varchar2
  ,p_dop_attribute11                in  varchar2
  ,p_dop_attribute12                in  varchar2
  ,p_dop_attribute13                in  varchar2
  ,p_dop_attribute14                in  varchar2
  ,p_dop_attribute15                in  varchar2
  ,p_dop_attribute16                in  varchar2
  ,p_dop_attribute17                in  varchar2
  ,p_dop_attribute18                in  varchar2
  ,p_dop_attribute19                in  varchar2
  ,p_dop_attribute20                in  varchar2
  ,p_dop_attribute21                in  varchar2
  ,p_dop_attribute22                in  varchar2
  ,p_dop_attribute23                in  varchar2
  ,p_dop_attribute24                in  varchar2
  ,p_dop_attribute25                in  varchar2
  ,p_dop_attribute26                in  varchar2
  ,p_dop_attribute27                in  varchar2
  ,p_dop_attribute28                in  varchar2
  ,p_dop_attribute29                in  varchar2
  ,p_dop_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_DPNT_CVRD_OTHR_PGM_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_DPNT_CVRD_OTHR_PGM_RT_a
  (
   p_dpnt_cvrd_othr_pgm_rt_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_only_pls_subj_cobra_flag       in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_ordr_num                       in  number
  ,p_pgm_id                         in  number
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_dop_attribute_category         in  varchar2
  ,p_dop_attribute1                 in  varchar2
  ,p_dop_attribute2                 in  varchar2
  ,p_dop_attribute3                 in  varchar2
  ,p_dop_attribute4                 in  varchar2
  ,p_dop_attribute5                 in  varchar2
  ,p_dop_attribute6                 in  varchar2
  ,p_dop_attribute7                 in  varchar2
  ,p_dop_attribute8                 in  varchar2
  ,p_dop_attribute9                 in  varchar2
  ,p_dop_attribute10                in  varchar2
  ,p_dop_attribute11                in  varchar2
  ,p_dop_attribute12                in  varchar2
  ,p_dop_attribute13                in  varchar2
  ,p_dop_attribute14                in  varchar2
  ,p_dop_attribute15                in  varchar2
  ,p_dop_attribute16                in  varchar2
  ,p_dop_attribute17                in  varchar2
  ,p_dop_attribute18                in  varchar2
  ,p_dop_attribute19                in  varchar2
  ,p_dop_attribute20                in  varchar2
  ,p_dop_attribute21                in  varchar2
  ,p_dop_attribute22                in  varchar2
  ,p_dop_attribute23                in  varchar2
  ,p_dop_attribute24                in  varchar2
  ,p_dop_attribute25                in  varchar2
  ,p_dop_attribute26                in  varchar2
  ,p_dop_attribute27                in  varchar2
  ,p_dop_attribute28                in  varchar2
  ,p_dop_attribute29                in  varchar2
  ,p_dop_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_DPNT_CVRD_OTHR_PGM_RT_bk2;

 

/
