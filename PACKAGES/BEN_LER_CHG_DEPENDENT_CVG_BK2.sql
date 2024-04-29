--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_DEPENDENT_CVG_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_DEPENDENT_CVG_BK2" AUTHID CURRENT_USER as
/* $Header: beldcapi.pkh 120.0 2005/05/28 03:19:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Ler_Chg_Dependent_Cvg_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Chg_Dependent_Cvg_b
  (
   p_ler_chg_dpnt_cvg_id            in  number
  ,p_pl_id                          in  number
  ,p_pgm_id                         in  number
  ,p_business_group_id              in  number
  ,p_ler_id                         in  number
  ,p_ptip_id                        in  number
  ,p_add_rmv_cvg_cd                 in  varchar2
  ,p_cvg_eff_end_cd                 in  varchar2
  ,p_cvg_eff_strt_cd                in  varchar2
  ,p_ler_chg_dpnt_cvg_rl            in  number
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2
  ,p_cvg_eff_strt_rl                in  number
  ,p_cvg_eff_end_rl                 in  number
  ,p_ldc_attribute_category         in  varchar2
  ,p_ldc_attribute1                 in  varchar2
  ,p_ldc_attribute2                 in  varchar2
  ,p_ldc_attribute3                 in  varchar2
  ,p_ldc_attribute4                 in  varchar2
  ,p_ldc_attribute5                 in  varchar2
  ,p_ldc_attribute6                 in  varchar2
  ,p_ldc_attribute7                 in  varchar2
  ,p_ldc_attribute8                 in  varchar2
  ,p_ldc_attribute9                 in  varchar2
  ,p_ldc_attribute10                in  varchar2
  ,p_ldc_attribute11                in  varchar2
  ,p_ldc_attribute12                in  varchar2
  ,p_ldc_attribute13                in  varchar2
  ,p_ldc_attribute14                in  varchar2
  ,p_ldc_attribute15                in  varchar2
  ,p_ldc_attribute16                in  varchar2
  ,p_ldc_attribute17                in  varchar2
  ,p_ldc_attribute18                in  varchar2
  ,p_ldc_attribute19                in  varchar2
  ,p_ldc_attribute20                in  varchar2
  ,p_ldc_attribute21                in  varchar2
  ,p_ldc_attribute22                in  varchar2
  ,p_ldc_attribute23                in  varchar2
  ,p_ldc_attribute24                in  varchar2
  ,p_ldc_attribute25                in  varchar2
  ,p_ldc_attribute26                in  varchar2
  ,p_ldc_attribute27                in  varchar2
  ,p_ldc_attribute28                in  varchar2
  ,p_ldc_attribute29                in  varchar2
  ,p_ldc_attribute30                in  varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2
  ,p_ctfn_determine_cd              in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Ler_Chg_Dependent_Cvg_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Chg_Dependent_Cvg_a
  (
   p_ler_chg_dpnt_cvg_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_pl_id                          in  number
  ,p_pgm_id                         in  number
  ,p_business_group_id              in  number
  ,p_ler_id                         in  number
  ,p_ptip_id                        in  number
  ,p_add_rmv_cvg_cd                 in  varchar2
  ,p_cvg_eff_end_cd                 in  varchar2
  ,p_cvg_eff_strt_cd                in  varchar2
  ,p_ler_chg_dpnt_cvg_rl            in  number
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2
  ,p_cvg_eff_strt_rl                in  number
  ,p_cvg_eff_end_rl                 in  number
  ,p_ldc_attribute_category         in  varchar2
  ,p_ldc_attribute1                 in  varchar2
  ,p_ldc_attribute2                 in  varchar2
  ,p_ldc_attribute3                 in  varchar2
  ,p_ldc_attribute4                 in  varchar2
  ,p_ldc_attribute5                 in  varchar2
  ,p_ldc_attribute6                 in  varchar2
  ,p_ldc_attribute7                 in  varchar2
  ,p_ldc_attribute8                 in  varchar2
  ,p_ldc_attribute9                 in  varchar2
  ,p_ldc_attribute10                in  varchar2
  ,p_ldc_attribute11                in  varchar2
  ,p_ldc_attribute12                in  varchar2
  ,p_ldc_attribute13                in  varchar2
  ,p_ldc_attribute14                in  varchar2
  ,p_ldc_attribute15                in  varchar2
  ,p_ldc_attribute16                in  varchar2
  ,p_ldc_attribute17                in  varchar2
  ,p_ldc_attribute18                in  varchar2
  ,p_ldc_attribute19                in  varchar2
  ,p_ldc_attribute20                in  varchar2
  ,p_ldc_attribute21                in  varchar2
  ,p_ldc_attribute22                in  varchar2
  ,p_ldc_attribute23                in  varchar2
  ,p_ldc_attribute24                in  varchar2
  ,p_ldc_attribute25                in  varchar2
  ,p_ldc_attribute26                in  varchar2
  ,p_ldc_attribute27                in  varchar2
  ,p_ldc_attribute28                in  varchar2
  ,p_ldc_attribute29                in  varchar2
  ,p_ldc_attribute30                in  varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2
  ,p_ctfn_determine_cd              in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Ler_Chg_Dependent_Cvg_bk2;

 

/
