--------------------------------------------------------
--  DDL for Package BEN_ELIG_SVC_AREA_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_SVC_AREA_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beesaapi.pkh 120.0 2005/05/28 02:53:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_elig_svc_area_prte_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_elig_svc_area_prte_b
  (
   p_elig_svc_area_prte_id          in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_svc_area_id                    in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_esa_attribute_category         in  varchar2
  ,p_esa_attribute1                 in  varchar2
  ,p_esa_attribute2                 in  varchar2
  ,p_esa_attribute3                 in  varchar2
  ,p_esa_attribute4                 in  varchar2
  ,p_esa_attribute5                 in  varchar2
  ,p_esa_attribute6                 in  varchar2
  ,p_esa_attribute7                 in  varchar2
  ,p_esa_attribute8                 in  varchar2
  ,p_esa_attribute9                 in  varchar2
  ,p_esa_attribute10                in  varchar2
  ,p_esa_attribute11                in  varchar2
  ,p_esa_attribute12                in  varchar2
  ,p_esa_attribute13                in  varchar2
  ,p_esa_attribute14                in  varchar2
  ,p_esa_attribute15                in  varchar2
  ,p_esa_attribute16                in  varchar2
  ,p_esa_attribute17                in  varchar2
  ,p_esa_attribute18                in  varchar2
  ,p_esa_attribute19                in  varchar2
  ,p_esa_attribute20                in  varchar2
  ,p_esa_attribute21                in  varchar2
  ,p_esa_attribute22                in  varchar2
  ,p_esa_attribute23                in  varchar2
  ,p_esa_attribute24                in  varchar2
  ,p_esa_attribute25                in  varchar2
  ,p_esa_attribute26                in  varchar2
  ,p_esa_attribute27                in  varchar2
  ,p_esa_attribute28                in  varchar2
  ,p_esa_attribute29                in  varchar2
  ,p_esa_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_elig_svc_area_prte_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_elig_svc_area_prte_a
  (
   p_elig_svc_area_prte_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_svc_area_id                    in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_esa_attribute_category         in  varchar2
  ,p_esa_attribute1                 in  varchar2
  ,p_esa_attribute2                 in  varchar2
  ,p_esa_attribute3                 in  varchar2
  ,p_esa_attribute4                 in  varchar2
  ,p_esa_attribute5                 in  varchar2
  ,p_esa_attribute6                 in  varchar2
  ,p_esa_attribute7                 in  varchar2
  ,p_esa_attribute8                 in  varchar2
  ,p_esa_attribute9                 in  varchar2
  ,p_esa_attribute10                in  varchar2
  ,p_esa_attribute11                in  varchar2
  ,p_esa_attribute12                in  varchar2
  ,p_esa_attribute13                in  varchar2
  ,p_esa_attribute14                in  varchar2
  ,p_esa_attribute15                in  varchar2
  ,p_esa_attribute16                in  varchar2
  ,p_esa_attribute17                in  varchar2
  ,p_esa_attribute18                in  varchar2
  ,p_esa_attribute19                in  varchar2
  ,p_esa_attribute20                in  varchar2
  ,p_esa_attribute21                in  varchar2
  ,p_esa_attribute22                in  varchar2
  ,p_esa_attribute23                in  varchar2
  ,p_esa_attribute24                in  varchar2
  ,p_esa_attribute25                in  varchar2
  ,p_esa_attribute26                in  varchar2
  ,p_esa_attribute27                in  varchar2
  ,p_esa_attribute28                in  varchar2
  ,p_esa_attribute29                in  varchar2
  ,p_esa_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_elig_svc_area_prte_bk2;

 

/
