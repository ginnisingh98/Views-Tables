--------------------------------------------------------
--  DDL for Package BEN_ELIG_CMBN_AGE_LOS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_CMBN_AGE_LOS_BK2" AUTHID CURRENT_USER as
/* $Header: beecpapi.pkh 120.0 2005/05/28 01:51:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_CMBN_AGE_LOS_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_CMBN_AGE_LOS_b
  (
   p_elig_cmbn_age_los_prte_id      in  number
  ,p_business_group_id              in  number
  ,p_cmbn_age_los_fctr_id           in  number
  ,p_eligy_prfl_id                  in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_ecp_attribute_category         in  varchar2
  ,p_ecp_attribute1                 in  varchar2
  ,p_ecp_attribute2                 in  varchar2
  ,p_ecp_attribute3                 in  varchar2
  ,p_ecp_attribute4                 in  varchar2
  ,p_ecp_attribute5                 in  varchar2
  ,p_ecp_attribute6                 in  varchar2
  ,p_ecp_attribute7                 in  varchar2
  ,p_ecp_attribute8                 in  varchar2
  ,p_ecp_attribute9                 in  varchar2
  ,p_ecp_attribute10                in  varchar2
  ,p_ecp_attribute11                in  varchar2
  ,p_ecp_attribute12                in  varchar2
  ,p_ecp_attribute13                in  varchar2
  ,p_ecp_attribute14                in  varchar2
  ,p_ecp_attribute15                in  varchar2
  ,p_ecp_attribute16                in  varchar2
  ,p_ecp_attribute17                in  varchar2
  ,p_ecp_attribute18                in  varchar2
  ,p_ecp_attribute19                in  varchar2
  ,p_ecp_attribute20                in  varchar2
  ,p_ecp_attribute21                in  varchar2
  ,p_ecp_attribute22                in  varchar2
  ,p_ecp_attribute23                in  varchar2
  ,p_ecp_attribute24                in  varchar2
  ,p_ecp_attribute25                in  varchar2
  ,p_ecp_attribute26                in  varchar2
  ,p_ecp_attribute27                in  varchar2
  ,p_ecp_attribute28                in  varchar2
  ,p_ecp_attribute29                in  varchar2
  ,p_ecp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_CMBN_AGE_LOS_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_CMBN_AGE_LOS_a
  (
   p_elig_cmbn_age_los_prte_id      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_cmbn_age_los_fctr_id           in  number
  ,p_eligy_prfl_id                  in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_ecp_attribute_category         in  varchar2
  ,p_ecp_attribute1                 in  varchar2
  ,p_ecp_attribute2                 in  varchar2
  ,p_ecp_attribute3                 in  varchar2
  ,p_ecp_attribute4                 in  varchar2
  ,p_ecp_attribute5                 in  varchar2
  ,p_ecp_attribute6                 in  varchar2
  ,p_ecp_attribute7                 in  varchar2
  ,p_ecp_attribute8                 in  varchar2
  ,p_ecp_attribute9                 in  varchar2
  ,p_ecp_attribute10                in  varchar2
  ,p_ecp_attribute11                in  varchar2
  ,p_ecp_attribute12                in  varchar2
  ,p_ecp_attribute13                in  varchar2
  ,p_ecp_attribute14                in  varchar2
  ,p_ecp_attribute15                in  varchar2
  ,p_ecp_attribute16                in  varchar2
  ,p_ecp_attribute17                in  varchar2
  ,p_ecp_attribute18                in  varchar2
  ,p_ecp_attribute19                in  varchar2
  ,p_ecp_attribute20                in  varchar2
  ,p_ecp_attribute21                in  varchar2
  ,p_ecp_attribute22                in  varchar2
  ,p_ecp_attribute23                in  varchar2
  ,p_ecp_attribute24                in  varchar2
  ,p_ecp_attribute25                in  varchar2
  ,p_ecp_attribute26                in  varchar2
  ,p_ecp_attribute27                in  varchar2
  ,p_ecp_attribute28                in  varchar2
  ,p_ecp_attribute29                in  varchar2
  ,p_ecp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_CMBN_AGE_LOS_bk2;

 

/
