--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVG_RQD_RLSHP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVG_RQD_RLSHP_BK2" AUTHID CURRENT_USER as
/* $Header: bedcrapi.pkh 120.0 2005/05/28 01:34:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_DPNT_CVG_RQD_RLSHP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_DPNT_CVG_RQD_RLSHP_b
  (
   p_dpnt_cvg_rqd_rlshp_id          in  number
  ,p_business_group_id              in  number
  ,p_per_relshp_typ_cd              in  varchar2
  ,p_cvg_strt_dt_cd                 in  varchar2
  ,p_cvg_thru_dt_rl                 in  number
  ,p_cvg_thru_dt_cd                 in  varchar2
  ,p_cvg_strt_dt_rl                 in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_dcr_attribute_category         in  varchar2
  ,p_dcr_attribute1                 in  varchar2
  ,p_dcr_attribute2                 in  varchar2
  ,p_dcr_attribute3                 in  varchar2
  ,p_dcr_attribute4                 in  varchar2
  ,p_dcr_attribute5                 in  varchar2
  ,p_dcr_attribute6                 in  varchar2
  ,p_dcr_attribute7                 in  varchar2
  ,p_dcr_attribute8                 in  varchar2
  ,p_dcr_attribute9                 in  varchar2
  ,p_dcr_attribute10                in  varchar2
  ,p_dcr_attribute11                in  varchar2
  ,p_dcr_attribute12                in  varchar2
  ,p_dcr_attribute13                in  varchar2
  ,p_dcr_attribute14                in  varchar2
  ,p_dcr_attribute15                in  varchar2
  ,p_dcr_attribute16                in  varchar2
  ,p_dcr_attribute17                in  varchar2
  ,p_dcr_attribute18                in  varchar2
  ,p_dcr_attribute19                in  varchar2
  ,p_dcr_attribute20                in  varchar2
  ,p_dcr_attribute21                in  varchar2
  ,p_dcr_attribute22                in  varchar2
  ,p_dcr_attribute23                in  varchar2
  ,p_dcr_attribute24                in  varchar2
  ,p_dcr_attribute25                in  varchar2
  ,p_dcr_attribute26                in  varchar2
  ,p_dcr_attribute27                in  varchar2
  ,p_dcr_attribute28                in  varchar2
  ,p_dcr_attribute29                in  varchar2
  ,p_dcr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_DPNT_CVG_RQD_RLSHP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_DPNT_CVG_RQD_RLSHP_a
  (
   p_dpnt_cvg_rqd_rlshp_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_per_relshp_typ_cd              in  varchar2
  ,p_cvg_strt_dt_cd                 in  varchar2
  ,p_cvg_thru_dt_rl                 in  number
  ,p_cvg_thru_dt_cd                 in  varchar2
  ,p_cvg_strt_dt_rl                 in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_dcr_attribute_category         in  varchar2
  ,p_dcr_attribute1                 in  varchar2
  ,p_dcr_attribute2                 in  varchar2
  ,p_dcr_attribute3                 in  varchar2
  ,p_dcr_attribute4                 in  varchar2
  ,p_dcr_attribute5                 in  varchar2
  ,p_dcr_attribute6                 in  varchar2
  ,p_dcr_attribute7                 in  varchar2
  ,p_dcr_attribute8                 in  varchar2
  ,p_dcr_attribute9                 in  varchar2
  ,p_dcr_attribute10                in  varchar2
  ,p_dcr_attribute11                in  varchar2
  ,p_dcr_attribute12                in  varchar2
  ,p_dcr_attribute13                in  varchar2
  ,p_dcr_attribute14                in  varchar2
  ,p_dcr_attribute15                in  varchar2
  ,p_dcr_attribute16                in  varchar2
  ,p_dcr_attribute17                in  varchar2
  ,p_dcr_attribute18                in  varchar2
  ,p_dcr_attribute19                in  varchar2
  ,p_dcr_attribute20                in  varchar2
  ,p_dcr_attribute21                in  varchar2
  ,p_dcr_attribute22                in  varchar2
  ,p_dcr_attribute23                in  varchar2
  ,p_dcr_attribute24                in  varchar2
  ,p_dcr_attribute25                in  varchar2
  ,p_dcr_attribute26                in  varchar2
  ,p_dcr_attribute27                in  varchar2
  ,p_dcr_attribute28                in  varchar2
  ,p_dcr_attribute29                in  varchar2
  ,p_dcr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_DPNT_CVG_RQD_RLSHP_bk2;

 

/
