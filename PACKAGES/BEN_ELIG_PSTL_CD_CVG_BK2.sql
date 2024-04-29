--------------------------------------------------------
--  DDL for Package BEN_ELIG_PSTL_CD_CVG_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_PSTL_CD_CVG_BK2" AUTHID CURRENT_USER as
/* $Header: beeplapi.pkh 120.0 2005/05/28 02:39:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_PSTL_CD_CVG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_PSTL_CD_CVG_b
  (
   p_elig_pstl_cd_r_rng_cvg_id      in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_pstl_zip_rng_id                in  number
  ,p_business_group_id              in  number
  ,p_epl_attribute_category         in  varchar2
  ,p_epl_attribute1                 in  varchar2
  ,p_epl_attribute2                 in  varchar2
  ,p_epl_attribute3                 in  varchar2
  ,p_epl_attribute4                 in  varchar2
  ,p_epl_attribute5                 in  varchar2
  ,p_epl_attribute6                 in  varchar2
  ,p_epl_attribute7                 in  varchar2
  ,p_epl_attribute8                 in  varchar2
  ,p_epl_attribute9                 in  varchar2
  ,p_epl_attribute10                in  varchar2
  ,p_epl_attribute11                in  varchar2
  ,p_epl_attribute12                in  varchar2
  ,p_epl_attribute13                in  varchar2
  ,p_epl_attribute14                in  varchar2
  ,p_epl_attribute15                in  varchar2
  ,p_epl_attribute16                in  varchar2
  ,p_epl_attribute17                in  varchar2
  ,p_epl_attribute18                in  varchar2
  ,p_epl_attribute19                in  varchar2
  ,p_epl_attribute20                in  varchar2
  ,p_epl_attribute21                in  varchar2
  ,p_epl_attribute22                in  varchar2
  ,p_epl_attribute23                in  varchar2
  ,p_epl_attribute24                in  varchar2
  ,p_epl_attribute25                in  varchar2
  ,p_epl_attribute26                in  varchar2
  ,p_epl_attribute27                in  varchar2
  ,p_epl_attribute28                in  varchar2
  ,p_epl_attribute29                in  varchar2
  ,p_epl_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_PSTL_CD_CVG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_PSTL_CD_CVG_a
  (
   p_elig_pstl_cd_r_rng_cvg_id      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_pstl_zip_rng_id                in  number
  ,p_business_group_id              in  number
  ,p_epl_attribute_category         in  varchar2
  ,p_epl_attribute1                 in  varchar2
  ,p_epl_attribute2                 in  varchar2
  ,p_epl_attribute3                 in  varchar2
  ,p_epl_attribute4                 in  varchar2
  ,p_epl_attribute5                 in  varchar2
  ,p_epl_attribute6                 in  varchar2
  ,p_epl_attribute7                 in  varchar2
  ,p_epl_attribute8                 in  varchar2
  ,p_epl_attribute9                 in  varchar2
  ,p_epl_attribute10                in  varchar2
  ,p_epl_attribute11                in  varchar2
  ,p_epl_attribute12                in  varchar2
  ,p_epl_attribute13                in  varchar2
  ,p_epl_attribute14                in  varchar2
  ,p_epl_attribute15                in  varchar2
  ,p_epl_attribute16                in  varchar2
  ,p_epl_attribute17                in  varchar2
  ,p_epl_attribute18                in  varchar2
  ,p_epl_attribute19                in  varchar2
  ,p_epl_attribute20                in  varchar2
  ,p_epl_attribute21                in  varchar2
  ,p_epl_attribute22                in  varchar2
  ,p_epl_attribute23                in  varchar2
  ,p_epl_attribute24                in  varchar2
  ,p_epl_attribute25                in  varchar2
  ,p_epl_attribute26                in  varchar2
  ,p_epl_attribute27                in  varchar2
  ,p_epl_attribute28                in  varchar2
  ,p_epl_attribute29                in  varchar2
  ,p_epl_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_PSTL_CD_CVG_bk2;

 

/
