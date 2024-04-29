--------------------------------------------------------
--  DDL for Package BEN_ELIG_AGE_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_AGE_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beeapapi.pkh 120.0 2005/05/28 01:44:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_AGE_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_AGE_PRTE_b
  (
   p_business_group_id              in  number
  ,p_age_fctr_id                    in  number
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_eap_attribute_category         in  varchar2
  ,p_eap_attribute1                 in  varchar2
  ,p_eap_attribute2                 in  varchar2
  ,p_eap_attribute3                 in  varchar2
  ,p_eap_attribute4                 in  varchar2
  ,p_eap_attribute5                 in  varchar2
  ,p_eap_attribute6                 in  varchar2
  ,p_eap_attribute7                 in  varchar2
  ,p_eap_attribute8                 in  varchar2
  ,p_eap_attribute9                 in  varchar2
  ,p_eap_attribute10                in  varchar2
  ,p_eap_attribute11                in  varchar2
  ,p_eap_attribute12                in  varchar2
  ,p_eap_attribute13                in  varchar2
  ,p_eap_attribute14                in  varchar2
  ,p_eap_attribute15                in  varchar2
  ,p_eap_attribute16                in  varchar2
  ,p_eap_attribute17                in  varchar2
  ,p_eap_attribute18                in  varchar2
  ,p_eap_attribute19                in  varchar2
  ,p_eap_attribute20                in  varchar2
  ,p_eap_attribute21                in  varchar2
  ,p_eap_attribute22                in  varchar2
  ,p_eap_attribute23                in  varchar2
  ,p_eap_attribute24                in  varchar2
  ,p_eap_attribute25                in  varchar2
  ,p_eap_attribute26                in  varchar2
  ,p_eap_attribute27                in  varchar2
  ,p_eap_attribute28                in  varchar2
  ,p_eap_attribute29                in  varchar2
  ,p_eap_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_AGE_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_AGE_PRTE_a
  (
   p_elig_age_prte_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_age_fctr_id                    in  number
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_eap_attribute_category         in  varchar2
  ,p_eap_attribute1                 in  varchar2
  ,p_eap_attribute2                 in  varchar2
  ,p_eap_attribute3                 in  varchar2
  ,p_eap_attribute4                 in  varchar2
  ,p_eap_attribute5                 in  varchar2
  ,p_eap_attribute6                 in  varchar2
  ,p_eap_attribute7                 in  varchar2
  ,p_eap_attribute8                 in  varchar2
  ,p_eap_attribute9                 in  varchar2
  ,p_eap_attribute10                in  varchar2
  ,p_eap_attribute11                in  varchar2
  ,p_eap_attribute12                in  varchar2
  ,p_eap_attribute13                in  varchar2
  ,p_eap_attribute14                in  varchar2
  ,p_eap_attribute15                in  varchar2
  ,p_eap_attribute16                in  varchar2
  ,p_eap_attribute17                in  varchar2
  ,p_eap_attribute18                in  varchar2
  ,p_eap_attribute19                in  varchar2
  ,p_eap_attribute20                in  varchar2
  ,p_eap_attribute21                in  varchar2
  ,p_eap_attribute22                in  varchar2
  ,p_eap_attribute23                in  varchar2
  ,p_eap_attribute24                in  varchar2
  ,p_eap_attribute25                in  varchar2
  ,p_eap_attribute26                in  varchar2
  ,p_eap_attribute27                in  varchar2
  ,p_eap_attribute28                in  varchar2
  ,p_eap_attribute29                in  varchar2
  ,p_eap_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_AGE_PRTE_bk1;

 

/
