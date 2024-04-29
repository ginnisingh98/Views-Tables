--------------------------------------------------------
--  DDL for Package BEN_ELIG_BRGNG_UNIT_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_BRGNG_UNIT_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beebuapi.pkh 120.0 2005/05/28 01:47:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_BRGNG_UNIT_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_BRGNG_UNIT_PRTE_b
  (
   p_business_group_id              in  number
  ,p_brgng_unit_cd                  in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_ebu_attribute_category         in  varchar2
  ,p_ebu_attribute1                 in  varchar2
  ,p_ebu_attribute2                 in  varchar2
  ,p_ebu_attribute3                 in  varchar2
  ,p_ebu_attribute4                 in  varchar2
  ,p_ebu_attribute5                 in  varchar2
  ,p_ebu_attribute6                 in  varchar2
  ,p_ebu_attribute7                 in  varchar2
  ,p_ebu_attribute8                 in  varchar2
  ,p_ebu_attribute9                 in  varchar2
  ,p_ebu_attribute10                in  varchar2
  ,p_ebu_attribute11                in  varchar2
  ,p_ebu_attribute12                in  varchar2
  ,p_ebu_attribute13                in  varchar2
  ,p_ebu_attribute14                in  varchar2
  ,p_ebu_attribute15                in  varchar2
  ,p_ebu_attribute16                in  varchar2
  ,p_ebu_attribute17                in  varchar2
  ,p_ebu_attribute18                in  varchar2
  ,p_ebu_attribute19                in  varchar2
  ,p_ebu_attribute20                in  varchar2
  ,p_ebu_attribute21                in  varchar2
  ,p_ebu_attribute22                in  varchar2
  ,p_ebu_attribute23                in  varchar2
  ,p_ebu_attribute24                in  varchar2
  ,p_ebu_attribute25                in  varchar2
  ,p_ebu_attribute26                in  varchar2
  ,p_ebu_attribute27                in  varchar2
  ,p_ebu_attribute28                in  varchar2
  ,p_ebu_attribute29                in  varchar2
  ,p_ebu_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_BRGNG_UNIT_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_BRGNG_UNIT_PRTE_a
  (
   p_elig_brgng_unit_prte_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_brgng_unit_cd                  in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_ebu_attribute_category         in  varchar2
  ,p_ebu_attribute1                 in  varchar2
  ,p_ebu_attribute2                 in  varchar2
  ,p_ebu_attribute3                 in  varchar2
  ,p_ebu_attribute4                 in  varchar2
  ,p_ebu_attribute5                 in  varchar2
  ,p_ebu_attribute6                 in  varchar2
  ,p_ebu_attribute7                 in  varchar2
  ,p_ebu_attribute8                 in  varchar2
  ,p_ebu_attribute9                 in  varchar2
  ,p_ebu_attribute10                in  varchar2
  ,p_ebu_attribute11                in  varchar2
  ,p_ebu_attribute12                in  varchar2
  ,p_ebu_attribute13                in  varchar2
  ,p_ebu_attribute14                in  varchar2
  ,p_ebu_attribute15                in  varchar2
  ,p_ebu_attribute16                in  varchar2
  ,p_ebu_attribute17                in  varchar2
  ,p_ebu_attribute18                in  varchar2
  ,p_ebu_attribute19                in  varchar2
  ,p_ebu_attribute20                in  varchar2
  ,p_ebu_attribute21                in  varchar2
  ,p_ebu_attribute22                in  varchar2
  ,p_ebu_attribute23                in  varchar2
  ,p_ebu_attribute24                in  varchar2
  ,p_ebu_attribute25                in  varchar2
  ,p_ebu_attribute26                in  varchar2
  ,p_ebu_attribute27                in  varchar2
  ,p_ebu_attribute28                in  varchar2
  ,p_ebu_attribute29                in  varchar2
  ,p_ebu_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_BRGNG_UNIT_PRTE_bk1;

 

/
