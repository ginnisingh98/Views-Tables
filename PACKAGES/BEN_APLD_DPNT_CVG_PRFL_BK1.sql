--------------------------------------------------------
--  DDL for Package BEN_APLD_DPNT_CVG_PRFL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_APLD_DPNT_CVG_PRFL_BK1" AUTHID CURRENT_USER as
/* $Header: beadeapi.pkh 120.0 2005/05/28 00:21:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Apld_Dpnt_Cvg_Prfl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Apld_Dpnt_Cvg_Prfl_b
  (
   p_business_group_id              in  number
  ,p_apld_dpnt_cvg_elig_rl          in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_ptip_id                        in  number
  ,p_ade_attribute_category         in  varchar2
  ,p_ade_attribute1                 in  varchar2
  ,p_ade_attribute2                 in  varchar2
  ,p_ade_attribute3                 in  varchar2
  ,p_ade_attribute4                 in  varchar2
  ,p_ade_attribute5                 in  varchar2
  ,p_ade_attribute6                 in  varchar2
  ,p_ade_attribute7                 in  varchar2
  ,p_ade_attribute8                 in  varchar2
  ,p_ade_attribute9                 in  varchar2
  ,p_ade_attribute10                in  varchar2
  ,p_ade_attribute11                in  varchar2
  ,p_ade_attribute12                in  varchar2
  ,p_ade_attribute13                in  varchar2
  ,p_ade_attribute14                in  varchar2
  ,p_ade_attribute15                in  varchar2
  ,p_ade_attribute16                in  varchar2
  ,p_ade_attribute17                in  varchar2
  ,p_ade_attribute18                in  varchar2
  ,p_ade_attribute19                in  varchar2
  ,p_ade_attribute20                in  varchar2
  ,p_ade_attribute21                in  varchar2
  ,p_ade_attribute22                in  varchar2
  ,p_ade_attribute23                in  varchar2
  ,p_ade_attribute24                in  varchar2
  ,p_ade_attribute25                in  varchar2
  ,p_ade_attribute26                in  varchar2
  ,p_ade_attribute27                in  varchar2
  ,p_ade_attribute28                in  varchar2
  ,p_ade_attribute29                in  varchar2
  ,p_ade_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Apld_Dpnt_Cvg_Prfl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Apld_Dpnt_Cvg_Prfl_a
  (
   p_apld_dpnt_cvg_elig_prfl_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_apld_dpnt_cvg_elig_rl          in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_ptip_id                        in  number
  ,p_ade_attribute_category         in  varchar2
  ,p_ade_attribute1                 in  varchar2
  ,p_ade_attribute2                 in  varchar2
  ,p_ade_attribute3                 in  varchar2
  ,p_ade_attribute4                 in  varchar2
  ,p_ade_attribute5                 in  varchar2
  ,p_ade_attribute6                 in  varchar2
  ,p_ade_attribute7                 in  varchar2
  ,p_ade_attribute8                 in  varchar2
  ,p_ade_attribute9                 in  varchar2
  ,p_ade_attribute10                in  varchar2
  ,p_ade_attribute11                in  varchar2
  ,p_ade_attribute12                in  varchar2
  ,p_ade_attribute13                in  varchar2
  ,p_ade_attribute14                in  varchar2
  ,p_ade_attribute15                in  varchar2
  ,p_ade_attribute16                in  varchar2
  ,p_ade_attribute17                in  varchar2
  ,p_ade_attribute18                in  varchar2
  ,p_ade_attribute19                in  varchar2
  ,p_ade_attribute20                in  varchar2
  ,p_ade_attribute21                in  varchar2
  ,p_ade_attribute22                in  varchar2
  ,p_ade_attribute23                in  varchar2
  ,p_ade_attribute24                in  varchar2
  ,p_ade_attribute25                in  varchar2
  ,p_ade_attribute26                in  varchar2
  ,p_ade_attribute27                in  varchar2
  ,p_ade_attribute28                in  varchar2
  ,p_ade_attribute29                in  varchar2
  ,p_ade_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Apld_Dpnt_Cvg_Prfl_bk1;

 

/
