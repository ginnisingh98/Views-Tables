--------------------------------------------------------
--  DDL for Package BEN_ELIG_DPNT_CVD_OTHR_PL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DPNT_CVD_OTHR_PL_BK2" AUTHID CURRENT_USER as
/* $Header: beedpapi.pkh 120.0 2005/05/28 02:00:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_DPNT_CVD_OTHR_PL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_DPNT_CVD_OTHR_PL_b
  (
   p_elig_dpnt_cvrd_othr_pl_id      in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_cvg_det_dt_cd                  in  varchar2
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_pl_id                          in  number
  ,p_edp_attribute_category         in  varchar2
  ,p_edp_attribute1                 in  varchar2
  ,p_edp_attribute2                 in  varchar2
  ,p_edp_attribute3                 in  varchar2
  ,p_edp_attribute4                 in  varchar2
  ,p_edp_attribute5                 in  varchar2
  ,p_edp_attribute6                 in  varchar2
  ,p_edp_attribute7                 in  varchar2
  ,p_edp_attribute8                 in  varchar2
  ,p_edp_attribute9                 in  varchar2
  ,p_edp_attribute10                in  varchar2
  ,p_edp_attribute11                in  varchar2
  ,p_edp_attribute12                in  varchar2
  ,p_edp_attribute13                in  varchar2
  ,p_edp_attribute14                in  varchar2
  ,p_edp_attribute15                in  varchar2
  ,p_edp_attribute16                in  varchar2
  ,p_edp_attribute17                in  varchar2
  ,p_edp_attribute18                in  varchar2
  ,p_edp_attribute19                in  varchar2
  ,p_edp_attribute20                in  varchar2
  ,p_edp_attribute21                in  varchar2
  ,p_edp_attribute22                in  varchar2
  ,p_edp_attribute23                in  varchar2
  ,p_edp_attribute24                in  varchar2
  ,p_edp_attribute25                in  varchar2
  ,p_edp_attribute26                in  varchar2
  ,p_edp_attribute27                in  varchar2
  ,p_edp_attribute28                in  varchar2
  ,p_edp_attribute29                in  varchar2
  ,p_edp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_DPNT_CVD_OTHR_PL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_DPNT_CVD_OTHR_PL_a
  (
   p_elig_dpnt_cvrd_othr_pl_id      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_cvg_det_dt_cd                  in  varchar2
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_pl_id                          in  number
  ,p_edp_attribute_category         in  varchar2
  ,p_edp_attribute1                 in  varchar2
  ,p_edp_attribute2                 in  varchar2
  ,p_edp_attribute3                 in  varchar2
  ,p_edp_attribute4                 in  varchar2
  ,p_edp_attribute5                 in  varchar2
  ,p_edp_attribute6                 in  varchar2
  ,p_edp_attribute7                 in  varchar2
  ,p_edp_attribute8                 in  varchar2
  ,p_edp_attribute9                 in  varchar2
  ,p_edp_attribute10                in  varchar2
  ,p_edp_attribute11                in  varchar2
  ,p_edp_attribute12                in  varchar2
  ,p_edp_attribute13                in  varchar2
  ,p_edp_attribute14                in  varchar2
  ,p_edp_attribute15                in  varchar2
  ,p_edp_attribute16                in  varchar2
  ,p_edp_attribute17                in  varchar2
  ,p_edp_attribute18                in  varchar2
  ,p_edp_attribute19                in  varchar2
  ,p_edp_attribute20                in  varchar2
  ,p_edp_attribute21                in  varchar2
  ,p_edp_attribute22                in  varchar2
  ,p_edp_attribute23                in  varchar2
  ,p_edp_attribute24                in  varchar2
  ,p_edp_attribute25                in  varchar2
  ,p_edp_attribute26                in  varchar2
  ,p_edp_attribute27                in  varchar2
  ,p_edp_attribute28                in  varchar2
  ,p_edp_attribute29                in  varchar2
  ,p_edp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_DPNT_CVD_OTHR_PL_bk2;

 

/
