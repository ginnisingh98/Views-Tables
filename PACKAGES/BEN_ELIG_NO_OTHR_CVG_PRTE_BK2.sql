--------------------------------------------------------
--  DDL for Package BEN_ELIG_NO_OTHR_CVG_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_NO_OTHR_CVG_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beenoapi.pkh 120.0 2005/05/28 02:29:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_NO_OTHR_CVG_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_NO_OTHR_CVG_PRTE_b
  (
   p_elig_no_othr_cvg_prte_id       in  number
  ,p_coord_ben_no_cvg_flag          in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eno_attribute_category         in  varchar2
  ,p_eno_attribute1                 in  varchar2
  ,p_eno_attribute2                 in  varchar2
  ,p_eno_attribute3                 in  varchar2
  ,p_eno_attribute4                 in  varchar2
  ,p_eno_attribute5                 in  varchar2
  ,p_eno_attribute6                 in  varchar2
  ,p_eno_attribute7                 in  varchar2
  ,p_eno_attribute8                 in  varchar2
  ,p_eno_attribute9                 in  varchar2
  ,p_eno_attribute10                in  varchar2
  ,p_eno_attribute11                in  varchar2
  ,p_eno_attribute12                in  varchar2
  ,p_eno_attribute13                in  varchar2
  ,p_eno_attribute14                in  varchar2
  ,p_eno_attribute15                in  varchar2
  ,p_eno_attribute16                in  varchar2
  ,p_eno_attribute17                in  varchar2
  ,p_eno_attribute18                in  varchar2
  ,p_eno_attribute19                in  varchar2
  ,p_eno_attribute20                in  varchar2
  ,p_eno_attribute21                in  varchar2
  ,p_eno_attribute22                in  varchar2
  ,p_eno_attribute23                in  varchar2
  ,p_eno_attribute24                in  varchar2
  ,p_eno_attribute25                in  varchar2
  ,p_eno_attribute26                in  varchar2
  ,p_eno_attribute27                in  varchar2
  ,p_eno_attribute28                in  varchar2
  ,p_eno_attribute29                in  varchar2
  ,p_eno_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_NO_OTHR_CVG_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_NO_OTHR_CVG_PRTE_a
  (
   p_elig_no_othr_cvg_prte_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_coord_ben_no_cvg_flag          in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eno_attribute_category         in  varchar2
  ,p_eno_attribute1                 in  varchar2
  ,p_eno_attribute2                 in  varchar2
  ,p_eno_attribute3                 in  varchar2
  ,p_eno_attribute4                 in  varchar2
  ,p_eno_attribute5                 in  varchar2
  ,p_eno_attribute6                 in  varchar2
  ,p_eno_attribute7                 in  varchar2
  ,p_eno_attribute8                 in  varchar2
  ,p_eno_attribute9                 in  varchar2
  ,p_eno_attribute10                in  varchar2
  ,p_eno_attribute11                in  varchar2
  ,p_eno_attribute12                in  varchar2
  ,p_eno_attribute13                in  varchar2
  ,p_eno_attribute14                in  varchar2
  ,p_eno_attribute15                in  varchar2
  ,p_eno_attribute16                in  varchar2
  ,p_eno_attribute17                in  varchar2
  ,p_eno_attribute18                in  varchar2
  ,p_eno_attribute19                in  varchar2
  ,p_eno_attribute20                in  varchar2
  ,p_eno_attribute21                in  varchar2
  ,p_eno_attribute22                in  varchar2
  ,p_eno_attribute23                in  varchar2
  ,p_eno_attribute24                in  varchar2
  ,p_eno_attribute25                in  varchar2
  ,p_eno_attribute26                in  varchar2
  ,p_eno_attribute27                in  varchar2
  ,p_eno_attribute28                in  varchar2
  ,p_eno_attribute29                in  varchar2
  ,p_eno_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_NO_OTHR_CVG_PRTE_bk2;

 

/
