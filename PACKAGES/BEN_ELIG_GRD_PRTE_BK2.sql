--------------------------------------------------------
--  DDL for Package BEN_ELIG_GRD_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_GRD_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beegrapi.pkh 120.0 2005/05/28 02:13:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_GRD_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_GRD_PRTE_b
  (
   p_elig_grd_prte_id               in  number
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_grade_id                       in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_egr_attribute_category         in  varchar2
  ,p_egr_attribute1                 in  varchar2
  ,p_egr_attribute2                 in  varchar2
  ,p_egr_attribute3                 in  varchar2
  ,p_egr_attribute4                 in  varchar2
  ,p_egr_attribute5                 in  varchar2
  ,p_egr_attribute6                 in  varchar2
  ,p_egr_attribute7                 in  varchar2
  ,p_egr_attribute8                 in  varchar2
  ,p_egr_attribute9                 in  varchar2
  ,p_egr_attribute10                in  varchar2
  ,p_egr_attribute11                in  varchar2
  ,p_egr_attribute12                in  varchar2
  ,p_egr_attribute13                in  varchar2
  ,p_egr_attribute14                in  varchar2
  ,p_egr_attribute15                in  varchar2
  ,p_egr_attribute16                in  varchar2
  ,p_egr_attribute17                in  varchar2
  ,p_egr_attribute18                in  varchar2
  ,p_egr_attribute19                in  varchar2
  ,p_egr_attribute20                in  varchar2
  ,p_egr_attribute21                in  varchar2
  ,p_egr_attribute22                in  varchar2
  ,p_egr_attribute23                in  varchar2
  ,p_egr_attribute24                in  varchar2
  ,p_egr_attribute25                in  varchar2
  ,p_egr_attribute26                in  varchar2
  ,p_egr_attribute27                in  varchar2
  ,p_egr_attribute28                in  varchar2
  ,p_egr_attribute29                in  varchar2
  ,p_egr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_GRD_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_GRD_PRTE_a
  (
   p_elig_grd_prte_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_grade_id                       in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_egr_attribute_category         in  varchar2
  ,p_egr_attribute1                 in  varchar2
  ,p_egr_attribute2                 in  varchar2
  ,p_egr_attribute3                 in  varchar2
  ,p_egr_attribute4                 in  varchar2
  ,p_egr_attribute5                 in  varchar2
  ,p_egr_attribute6                 in  varchar2
  ,p_egr_attribute7                 in  varchar2
  ,p_egr_attribute8                 in  varchar2
  ,p_egr_attribute9                 in  varchar2
  ,p_egr_attribute10                in  varchar2
  ,p_egr_attribute11                in  varchar2
  ,p_egr_attribute12                in  varchar2
  ,p_egr_attribute13                in  varchar2
  ,p_egr_attribute14                in  varchar2
  ,p_egr_attribute15                in  varchar2
  ,p_egr_attribute16                in  varchar2
  ,p_egr_attribute17                in  varchar2
  ,p_egr_attribute18                in  varchar2
  ,p_egr_attribute19                in  varchar2
  ,p_egr_attribute20                in  varchar2
  ,p_egr_attribute21                in  varchar2
  ,p_egr_attribute22                in  varchar2
  ,p_egr_attribute23                in  varchar2
  ,p_egr_attribute24                in  varchar2
  ,p_egr_attribute25                in  varchar2
  ,p_egr_attribute26                in  varchar2
  ,p_egr_attribute27                in  varchar2
  ,p_egr_attribute28                in  varchar2
  ,p_egr_attribute29                in  varchar2
  ,p_egr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_GRD_PRTE_bk2;

 

/
