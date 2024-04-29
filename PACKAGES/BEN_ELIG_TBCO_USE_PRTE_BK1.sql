--------------------------------------------------------
--  DDL for Package BEN_ELIG_TBCO_USE_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_TBCO_USE_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beetuapi.pkh 120.0 2005/05/28 03:03:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_TBCO_USE_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_TBCO_USE_PRTE_b
  (
   p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_uses_tbco_flag                 in  varchar2
  ,p_etu_attribute_category         in  varchar2
  ,p_etu_attribute1                 in  varchar2
  ,p_etu_attribute2                 in  varchar2
  ,p_etu_attribute3                 in  varchar2
  ,p_etu_attribute4                 in  varchar2
  ,p_etu_attribute5                 in  varchar2
  ,p_etu_attribute6                 in  varchar2
  ,p_etu_attribute7                 in  varchar2
  ,p_etu_attribute8                 in  varchar2
  ,p_etu_attribute9                 in  varchar2
  ,p_etu_attribute10                in  varchar2
  ,p_etu_attribute11                in  varchar2
  ,p_etu_attribute12                in  varchar2
  ,p_etu_attribute13                in  varchar2
  ,p_etu_attribute14                in  varchar2
  ,p_etu_attribute15                in  varchar2
  ,p_etu_attribute16                in  varchar2
  ,p_etu_attribute17                in  varchar2
  ,p_etu_attribute18                in  varchar2
  ,p_etu_attribute19                in  varchar2
  ,p_etu_attribute20                in  varchar2
  ,p_etu_attribute21                in  varchar2
  ,p_etu_attribute22                in  varchar2
  ,p_etu_attribute23                in  varchar2
  ,p_etu_attribute24                in  varchar2
  ,p_etu_attribute25                in  varchar2
  ,p_etu_attribute26                in  varchar2
  ,p_etu_attribute27                in  varchar2
  ,p_etu_attribute28                in  varchar2
  ,p_etu_attribute29                in  varchar2
  ,p_etu_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_TBCO_USE_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_TBCO_USE_PRTE_a
  (
   p_elig_tbco_use_prte_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_uses_tbco_flag                 in  varchar2
  ,p_etu_attribute_category         in  varchar2
  ,p_etu_attribute1                 in  varchar2
  ,p_etu_attribute2                 in  varchar2
  ,p_etu_attribute3                 in  varchar2
  ,p_etu_attribute4                 in  varchar2
  ,p_etu_attribute5                 in  varchar2
  ,p_etu_attribute6                 in  varchar2
  ,p_etu_attribute7                 in  varchar2
  ,p_etu_attribute8                 in  varchar2
  ,p_etu_attribute9                 in  varchar2
  ,p_etu_attribute10                in  varchar2
  ,p_etu_attribute11                in  varchar2
  ,p_etu_attribute12                in  varchar2
  ,p_etu_attribute13                in  varchar2
  ,p_etu_attribute14                in  varchar2
  ,p_etu_attribute15                in  varchar2
  ,p_etu_attribute16                in  varchar2
  ,p_etu_attribute17                in  varchar2
  ,p_etu_attribute18                in  varchar2
  ,p_etu_attribute19                in  varchar2
  ,p_etu_attribute20                in  varchar2
  ,p_etu_attribute21                in  varchar2
  ,p_etu_attribute22                in  varchar2
  ,p_etu_attribute23                in  varchar2
  ,p_etu_attribute24                in  varchar2
  ,p_etu_attribute25                in  varchar2
  ,p_etu_attribute26                in  varchar2
  ,p_etu_attribute27                in  varchar2
  ,p_etu_attribute28                in  varchar2
  ,p_etu_attribute29                in  varchar2
  ,p_etu_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_TBCO_USE_PRTE_bk1;

 

/
