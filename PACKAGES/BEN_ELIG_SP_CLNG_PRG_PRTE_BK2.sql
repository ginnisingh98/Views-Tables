--------------------------------------------------------
--  DDL for Package BEN_ELIG_SP_CLNG_PRG_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_SP_CLNG_PRG_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beespapi.pkh 120.0 2005/05/28 02:57:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_SP_CLNG_PRG_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_elig_sp_clng_prg_prte_b
  (
   p_elig_sp_clng_prg_prte_id       in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_special_ceiling_step_id        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_esp_attribute_category         in  varchar2
  ,p_esp_attribute1                 in  varchar2
  ,p_esp_attribute2                 in  varchar2
  ,p_esp_attribute3                 in  varchar2
  ,p_esp_attribute4                 in  varchar2
  ,p_esp_attribute5                 in  varchar2
  ,p_esp_attribute6                 in  varchar2
  ,p_esp_attribute7                 in  varchar2
  ,p_esp_attribute8                 in  varchar2
  ,p_esp_attribute9                 in  varchar2
  ,p_esp_attribute10                in  varchar2
  ,p_esp_attribute11                in  varchar2
  ,p_esp_attribute12                in  varchar2
  ,p_esp_attribute13                in  varchar2
  ,p_esp_attribute14                in  varchar2
  ,p_esp_attribute15                in  varchar2
  ,p_esp_attribute16                in  varchar2
  ,p_esp_attribute17                in  varchar2
  ,p_esp_attribute18                in  varchar2
  ,p_esp_attribute19                in  varchar2
  ,p_esp_attribute20                in  varchar2
  ,p_esp_attribute21                in  varchar2
  ,p_esp_attribute22                in  varchar2
  ,p_esp_attribute23                in  varchar2
  ,p_esp_attribute24                in  varchar2
  ,p_esp_attribute25                in  varchar2
  ,p_esp_attribute26                in  varchar2
  ,p_esp_attribute27                in  varchar2
  ,p_esp_attribute28                in  varchar2
  ,p_esp_attribute29                in  varchar2
  ,p_esp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_SP_CLNG_PRG_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_SP_CLNG_PRG_PRTE_a
  (
   p_elig_sp_clng_prg_prte_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_special_ceiling_step_id        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_esp_attribute_category         in  varchar2
  ,p_esp_attribute1                 in  varchar2
  ,p_esp_attribute2                 in  varchar2
  ,p_esp_attribute3                 in  varchar2
  ,p_esp_attribute4                 in  varchar2
  ,p_esp_attribute5                 in  varchar2
  ,p_esp_attribute6                 in  varchar2
  ,p_esp_attribute7                 in  varchar2
  ,p_esp_attribute8                 in  varchar2
  ,p_esp_attribute9                 in  varchar2
  ,p_esp_attribute10                in  varchar2
  ,p_esp_attribute11                in  varchar2
  ,p_esp_attribute12                in  varchar2
  ,p_esp_attribute13                in  varchar2
  ,p_esp_attribute14                in  varchar2
  ,p_esp_attribute15                in  varchar2
  ,p_esp_attribute16                in  varchar2
  ,p_esp_attribute17                in  varchar2
  ,p_esp_attribute18                in  varchar2
  ,p_esp_attribute19                in  varchar2
  ,p_esp_attribute20                in  varchar2
  ,p_esp_attribute21                in  varchar2
  ,p_esp_attribute22                in  varchar2
  ,p_esp_attribute23                in  varchar2
  ,p_esp_attribute24                in  varchar2
  ,p_esp_attribute25                in  varchar2
  ,p_esp_attribute26                in  varchar2
  ,p_esp_attribute27                in  varchar2
  ,p_esp_attribute28                in  varchar2
  ,p_esp_attribute29                in  varchar2
  ,p_esp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_SP_CLNG_PRG_PRTE_bk2;

 

/
