--------------------------------------------------------
--  DDL for Package BEN_ELIG_QUA_IN_GR_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_QUA_IN_GR_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beeqgapi.pkh 120.0 2005/05/28 02:49:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_QUA_IN_GR_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_QUA_IN_GR_PRTE_b
  (
   p_quar_in_grade_cd                       in  varchar2
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eqg_attribute_category         in  varchar2
  ,p_eqg_attribute1                 in  varchar2
  ,p_eqg_attribute2                 in  varchar2
  ,p_eqg_attribute3                 in  varchar2
  ,p_eqg_attribute4                 in  varchar2
  ,p_eqg_attribute5                 in  varchar2
  ,p_eqg_attribute6                 in  varchar2
  ,p_eqg_attribute7                 in  varchar2
  ,p_eqg_attribute8                 in  varchar2
  ,p_eqg_attribute9                 in  varchar2
  ,p_eqg_attribute10                in  varchar2
  ,p_eqg_attribute11                in  varchar2
  ,p_eqg_attribute12                in  varchar2
  ,p_eqg_attribute13                in  varchar2
  ,p_eqg_attribute14                in  varchar2
  ,p_eqg_attribute15                in  varchar2
  ,p_eqg_attribute16                in  varchar2
  ,p_eqg_attribute17                in  varchar2
  ,p_eqg_attribute18                in  varchar2
  ,p_eqg_attribute19                in  varchar2
  ,p_eqg_attribute20                in  varchar2
  ,p_eqg_attribute21                in  varchar2
  ,p_eqg_attribute22                in  varchar2
  ,p_eqg_attribute23                in  varchar2
  ,p_eqg_attribute24                in  varchar2
  ,p_eqg_attribute25                in  varchar2
  ,p_eqg_attribute26                in  varchar2
  ,p_eqg_attribute27                in  varchar2
  ,p_eqg_attribute28                in  varchar2
  ,p_eqg_attribute29                in  varchar2
  ,p_eqg_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_QUA_IN_GR_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_QUA_IN_GR_PRTE_a
  (
   p_ELIG_QUA_IN_GR_PRTE_id             in  number
  ,p_quar_in_grade_cd                       in  varchar2
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eqg_attribute_category         in  varchar2
  ,p_eqg_attribute1                 in  varchar2
  ,p_eqg_attribute2                 in  varchar2
  ,p_eqg_attribute3                 in  varchar2
  ,p_eqg_attribute4                 in  varchar2
  ,p_eqg_attribute5                 in  varchar2
  ,p_eqg_attribute6                 in  varchar2
  ,p_eqg_attribute7                 in  varchar2
  ,p_eqg_attribute8                 in  varchar2
  ,p_eqg_attribute9                 in  varchar2
  ,p_eqg_attribute10                in  varchar2
  ,p_eqg_attribute11                in  varchar2
  ,p_eqg_attribute12                in  varchar2
  ,p_eqg_attribute13                in  varchar2
  ,p_eqg_attribute14                in  varchar2
  ,p_eqg_attribute15                in  varchar2
  ,p_eqg_attribute16                in  varchar2
  ,p_eqg_attribute17                in  varchar2
  ,p_eqg_attribute18                in  varchar2
  ,p_eqg_attribute19                in  varchar2
  ,p_eqg_attribute20                in  varchar2
  ,p_eqg_attribute21                in  varchar2
  ,p_eqg_attribute22                in  varchar2
  ,p_eqg_attribute23                in  varchar2
  ,p_eqg_attribute24                in  varchar2
  ,p_eqg_attribute25                in  varchar2
  ,p_eqg_attribute26                in  varchar2
  ,p_eqg_attribute27                in  varchar2
  ,p_eqg_attribute28                in  varchar2
  ,p_eqg_attribute29                in  varchar2
  ,p_eqg_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_QUA_IN_GR_PRTE_bk1;

 

/
