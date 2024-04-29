--------------------------------------------------------
--  DDL for Package BEN_ELIG_HRLY_SLRD_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_HRLY_SLRD_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beehsapi.pkh 120.0 2005/05/28 02:14:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_HRLY_SLRD_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_HRLY_SLRD_PRTE_b
  (
   p_elig_hrly_slrd_prte_id         in  number
  ,p_ordr_num                       in  number
  ,p_hrly_slrd_cd                   in  varchar2
  ,p_excld_flag                     in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_ehs_attribute_category         in  varchar2
  ,p_ehs_attribute1                 in  varchar2
  ,p_ehs_attribute2                 in  varchar2
  ,p_ehs_attribute3                 in  varchar2
  ,p_ehs_attribute4                 in  varchar2
  ,p_ehs_attribute5                 in  varchar2
  ,p_ehs_attribute6                 in  varchar2
  ,p_ehs_attribute7                 in  varchar2
  ,p_ehs_attribute8                 in  varchar2
  ,p_ehs_attribute9                 in  varchar2
  ,p_ehs_attribute10                in  varchar2
  ,p_ehs_attribute11                in  varchar2
  ,p_ehs_attribute12                in  varchar2
  ,p_ehs_attribute13                in  varchar2
  ,p_ehs_attribute14                in  varchar2
  ,p_ehs_attribute15                in  varchar2
  ,p_ehs_attribute16                in  varchar2
  ,p_ehs_attribute17                in  varchar2
  ,p_ehs_attribute18                in  varchar2
  ,p_ehs_attribute19                in  varchar2
  ,p_ehs_attribute20                in  varchar2
  ,p_ehs_attribute21                in  varchar2
  ,p_ehs_attribute22                in  varchar2
  ,p_ehs_attribute23                in  varchar2
  ,p_ehs_attribute24                in  varchar2
  ,p_ehs_attribute25                in  varchar2
  ,p_ehs_attribute26                in  varchar2
  ,p_ehs_attribute27                in  varchar2
  ,p_ehs_attribute28                in  varchar2
  ,p_ehs_attribute29                in  varchar2
  ,p_ehs_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_HRLY_SLRD_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_HRLY_SLRD_PRTE_a
  (
   p_elig_hrly_slrd_prte_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_hrly_slrd_cd                   in  varchar2
  ,p_excld_flag                     in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_ehs_attribute_category         in  varchar2
  ,p_ehs_attribute1                 in  varchar2
  ,p_ehs_attribute2                 in  varchar2
  ,p_ehs_attribute3                 in  varchar2
  ,p_ehs_attribute4                 in  varchar2
  ,p_ehs_attribute5                 in  varchar2
  ,p_ehs_attribute6                 in  varchar2
  ,p_ehs_attribute7                 in  varchar2
  ,p_ehs_attribute8                 in  varchar2
  ,p_ehs_attribute9                 in  varchar2
  ,p_ehs_attribute10                in  varchar2
  ,p_ehs_attribute11                in  varchar2
  ,p_ehs_attribute12                in  varchar2
  ,p_ehs_attribute13                in  varchar2
  ,p_ehs_attribute14                in  varchar2
  ,p_ehs_attribute15                in  varchar2
  ,p_ehs_attribute16                in  varchar2
  ,p_ehs_attribute17                in  varchar2
  ,p_ehs_attribute18                in  varchar2
  ,p_ehs_attribute19                in  varchar2
  ,p_ehs_attribute20                in  varchar2
  ,p_ehs_attribute21                in  varchar2
  ,p_ehs_attribute22                in  varchar2
  ,p_ehs_attribute23                in  varchar2
  ,p_ehs_attribute24                in  varchar2
  ,p_ehs_attribute25                in  varchar2
  ,p_ehs_attribute26                in  varchar2
  ,p_ehs_attribute27                in  varchar2
  ,p_ehs_attribute28                in  varchar2
  ,p_ehs_attribute29                in  varchar2
  ,p_ehs_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_HRLY_SLRD_PRTE_bk2;

 

/
