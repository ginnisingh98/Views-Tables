--------------------------------------------------------
--  DDL for Package BEN_ELIG_DSBLTY_RSN_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DSBLTY_RSN_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beedrapi.pkh 120.0 2005/05/28 02:00:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_elig_dsblty_rsn_prte_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_elig_dsblty_rsn_prte_b
  (
   p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_reason                         in  varchar2
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_edr_attribute_category         in  varchar2
  ,p_edr_attribute1                 in  varchar2
  ,p_edr_attribute2                 in  varchar2
  ,p_edr_attribute3                 in  varchar2
  ,p_edr_attribute4                 in  varchar2
  ,p_edr_attribute5                 in  varchar2
  ,p_edr_attribute6                 in  varchar2
  ,p_edr_attribute7                 in  varchar2
  ,p_edr_attribute8                 in  varchar2
  ,p_edr_attribute9                 in  varchar2
  ,p_edr_attribute10                in  varchar2
  ,p_edr_attribute11                in  varchar2
  ,p_edr_attribute12                in  varchar2
  ,p_edr_attribute13                in  varchar2
  ,p_edr_attribute14                in  varchar2
  ,p_edr_attribute15                in  varchar2
  ,p_edr_attribute16                in  varchar2
  ,p_edr_attribute17                in  varchar2
  ,p_edr_attribute18                in  varchar2
  ,p_edr_attribute19                in  varchar2
  ,p_edr_attribute20                in  varchar2
  ,p_edr_attribute21                in  varchar2
  ,p_edr_attribute22                in  varchar2
  ,p_edr_attribute23                in  varchar2
  ,p_edr_attribute24                in  varchar2
  ,p_edr_attribute25                in  varchar2
  ,p_edr_attribute26                in  varchar2
  ,p_edr_attribute27                in  varchar2
  ,p_edr_attribute28                in  varchar2
  ,p_edr_attribute29                in  varchar2
  ,p_edr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_elig_dsblty_rsn_prte_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_elig_dsblty_rsn_prte_a
  (
   p_elig_dsblty_rsn_prte_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_reason                         in  varchar2
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_edr_attribute_category         in  varchar2
  ,p_edr_attribute1                 in  varchar2
  ,p_edr_attribute2                 in  varchar2
  ,p_edr_attribute3                 in  varchar2
  ,p_edr_attribute4                 in  varchar2
  ,p_edr_attribute5                 in  varchar2
  ,p_edr_attribute6                 in  varchar2
  ,p_edr_attribute7                 in  varchar2
  ,p_edr_attribute8                 in  varchar2
  ,p_edr_attribute9                 in  varchar2
  ,p_edr_attribute10                in  varchar2
  ,p_edr_attribute11                in  varchar2
  ,p_edr_attribute12                in  varchar2
  ,p_edr_attribute13                in  varchar2
  ,p_edr_attribute14                in  varchar2
  ,p_edr_attribute15                in  varchar2
  ,p_edr_attribute16                in  varchar2
  ,p_edr_attribute17                in  varchar2
  ,p_edr_attribute18                in  varchar2
  ,p_edr_attribute19                in  varchar2
  ,p_edr_attribute20                in  varchar2
  ,p_edr_attribute21                in  varchar2
  ,p_edr_attribute22                in  varchar2
  ,p_edr_attribute23                in  varchar2
  ,p_edr_attribute24                in  varchar2
  ,p_edr_attribute25                in  varchar2
  ,p_edr_attribute26                in  varchar2
  ,p_edr_attribute27                in  varchar2
  ,p_edr_attribute28                in  varchar2
  ,p_edr_attribute29                in  varchar2
  ,p_edr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_elig_dsblty_rsn_prte_bk1;

 

/
