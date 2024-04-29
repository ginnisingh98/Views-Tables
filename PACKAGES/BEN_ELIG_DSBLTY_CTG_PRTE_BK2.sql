--------------------------------------------------------
--  DDL for Package BEN_ELIG_DSBLTY_CTG_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DSBLTY_CTG_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beectapi.pkh 120.0 2005/05/28 01:54:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_dsblty_ctg_PRTE_b >--------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_ELIG_DSBLTY_CTG_PRTE_B
  (
   p_ELIG_dsblty_ctg_PRTE_id        in  number
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_category                       in  varchar2
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_ect_attribute_category         in  varchar2
  ,p_ect_attribute1                 in  varchar2
  ,p_ect_attribute2                 in  varchar2
  ,p_ect_attribute3                 in  varchar2
  ,p_ect_attribute4                 in  varchar2
  ,p_ect_attribute5                 in  varchar2
  ,p_ect_attribute6                 in  varchar2
  ,p_ect_attribute7                 in  varchar2
  ,p_ect_attribute8                 in  varchar2
  ,p_ect_attribute9                 in  varchar2
  ,p_ect_attribute10                in  varchar2
  ,p_ect_attribute11                in  varchar2
  ,p_ect_attribute12                in  varchar2
  ,p_ect_attribute13                in  varchar2
  ,p_ect_attribute14                in  varchar2
  ,p_ect_attribute15                in  varchar2
  ,p_ect_attribute16                in  varchar2
  ,p_ect_attribute17                in  varchar2
  ,p_ect_attribute18                in  varchar2
  ,p_ect_attribute19                in  varchar2
  ,p_ect_attribute20                in  varchar2
  ,p_ect_attribute21                in  varchar2
  ,p_ect_attribute22                in  varchar2
  ,p_ect_attribute23                in  varchar2
  ,p_ect_attribute24                in  varchar2
  ,p_ect_attribute25                in  varchar2
  ,p_ect_attribute26                in  varchar2
  ,p_ect_attribute27                in  varchar2
  ,p_ect_attribute28                in  varchar2
  ,p_ect_attribute29                in  varchar2
  ,p_ect_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_dsblty_ctg_PRTE_a >---------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_ELIG_DSBLTY_CTG_PRTE_A
  (
   p_elig_dsblty_ctg_PRTE_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_category                       in  varchar2
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_ect_attribute_category         in  varchar2
  ,p_ect_attribute1                 in  varchar2
  ,p_ect_attribute2                 in  varchar2
  ,p_ect_attribute3                 in  varchar2
  ,p_ect_attribute4                 in  varchar2
  ,p_ect_attribute5                 in  varchar2
  ,p_ect_attribute6                 in  varchar2
  ,p_ect_attribute7                 in  varchar2
  ,p_ect_attribute8                 in  varchar2
  ,p_ect_attribute9                 in  varchar2
  ,p_ect_attribute10                in  varchar2
  ,p_ect_attribute11                in  varchar2
  ,p_ect_attribute12                in  varchar2
  ,p_ect_attribute13                in  varchar2
  ,p_ect_attribute14                in  varchar2
  ,p_ect_attribute15                in  varchar2
  ,p_ect_attribute16                in  varchar2
  ,p_ect_attribute17                in  varchar2
  ,p_ect_attribute18                in  varchar2
  ,p_ect_attribute19                in  varchar2
  ,p_ect_attribute20                in  varchar2
  ,p_ect_attribute21                in  varchar2
  ,p_ect_attribute22                in  varchar2
  ,p_ect_attribute23                in  varchar2
  ,p_ect_attribute24                in  varchar2
  ,p_ect_attribute25                in  varchar2
  ,p_ect_attribute26                in  varchar2
  ,p_ect_attribute27                in  varchar2
  ,p_ect_attribute28                in  varchar2
  ,p_ect_attribute29                in  varchar2
  ,p_ect_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end BEN_ELIG_DSBLTY_CTG_PRTE_BK2;

 

/
