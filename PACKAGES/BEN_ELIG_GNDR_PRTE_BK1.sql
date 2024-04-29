--------------------------------------------------------
--  DDL for Package BEN_ELIG_GNDR_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_GNDR_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beegnapi.pkh 120.0 2005/05/28 02:12:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_elig_gndr_prte_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_elig_gndr_prte_b
  (
   p_excld_flag                     in  varchar2
  ,p_sex                            in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_egn_attribute_category         in  varchar2
  ,p_egn_attribute1                 in  varchar2
  ,p_egn_attribute2                 in  varchar2
  ,p_egn_attribute3                 in  varchar2
  ,p_egn_attribute4                 in  varchar2
  ,p_egn_attribute5                 in  varchar2
  ,p_egn_attribute6                 in  varchar2
  ,p_egn_attribute7                 in  varchar2
  ,p_egn_attribute8                 in  varchar2
  ,p_egn_attribute9                 in  varchar2
  ,p_egn_attribute10                in  varchar2
  ,p_egn_attribute11                in  varchar2
  ,p_egn_attribute12                in  varchar2
  ,p_egn_attribute13                in  varchar2
  ,p_egn_attribute14                in  varchar2
  ,p_egn_attribute15                in  varchar2
  ,p_egn_attribute16                in  varchar2
  ,p_egn_attribute17                in  varchar2
  ,p_egn_attribute18                in  varchar2
  ,p_egn_attribute19                in  varchar2
  ,p_egn_attribute20                in  varchar2
  ,p_egn_attribute21                in  varchar2
  ,p_egn_attribute22                in  varchar2
  ,p_egn_attribute23                in  varchar2
  ,p_egn_attribute24                in  varchar2
  ,p_egn_attribute25                in  varchar2
  ,p_egn_attribute26                in  varchar2
  ,p_egn_attribute27                in  varchar2
  ,p_egn_attribute28                in  varchar2
  ,p_egn_attribute29                in  varchar2
  ,p_egn_attribute30                in  varchar2
  ,p_ordr_num                       in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_elig_gndr_prte_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_elig_gndr_prte_a
  (
   p_elig_gndr_prte_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_sex                            in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_egn_attribute_category         in  varchar2
  ,p_egn_attribute1                 in  varchar2
  ,p_egn_attribute2                 in  varchar2
  ,p_egn_attribute3                 in  varchar2
  ,p_egn_attribute4                 in  varchar2
  ,p_egn_attribute5                 in  varchar2
  ,p_egn_attribute6                 in  varchar2
  ,p_egn_attribute7                 in  varchar2
  ,p_egn_attribute8                 in  varchar2
  ,p_egn_attribute9                 in  varchar2
  ,p_egn_attribute10                in  varchar2
  ,p_egn_attribute11                in  varchar2
  ,p_egn_attribute12                in  varchar2
  ,p_egn_attribute13                in  varchar2
  ,p_egn_attribute14                in  varchar2
  ,p_egn_attribute15                in  varchar2
  ,p_egn_attribute16                in  varchar2
  ,p_egn_attribute17                in  varchar2
  ,p_egn_attribute18                in  varchar2
  ,p_egn_attribute19                in  varchar2
  ,p_egn_attribute20                in  varchar2
  ,p_egn_attribute21                in  varchar2
  ,p_egn_attribute22                in  varchar2
  ,p_egn_attribute23                in  varchar2
  ,p_egn_attribute24                in  varchar2
  ,p_egn_attribute25                in  varchar2
  ,p_egn_attribute26                in  varchar2
  ,p_egn_attribute27                in  varchar2
  ,p_egn_attribute28                in  varchar2
  ,p_egn_attribute29                in  varchar2
  ,p_egn_attribute30                in  varchar2
  ,p_ordr_num                       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_elig_gndr_prte_bk1;

 

/
