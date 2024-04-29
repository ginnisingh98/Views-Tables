--------------------------------------------------------
--  DDL for Package BEN_ELIGY_JOB_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGY_JOB_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beejpapi.pkh 120.0 2005/05/28 02:17:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIGY_JOB_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIGY_JOB_PRTE_b
  (
   p_elig_job_prte_id               in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_job_id                         in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_ejp_attribute_category         in  varchar2
  ,p_ejp_attribute1                 in  varchar2
  ,p_ejp_attribute2                 in  varchar2
  ,p_ejp_attribute3                 in  varchar2
  ,p_ejp_attribute4                 in  varchar2
  ,p_ejp_attribute5                 in  varchar2
  ,p_ejp_attribute6                 in  varchar2
  ,p_ejp_attribute7                 in  varchar2
  ,p_ejp_attribute8                 in  varchar2
  ,p_ejp_attribute9                 in  varchar2
  ,p_ejp_attribute10                in  varchar2
  ,p_ejp_attribute11                in  varchar2
  ,p_ejp_attribute12                in  varchar2
  ,p_ejp_attribute13                in  varchar2
  ,p_ejp_attribute14                in  varchar2
  ,p_ejp_attribute15                in  varchar2
  ,p_ejp_attribute16                in  varchar2
  ,p_ejp_attribute17                in  varchar2
  ,p_ejp_attribute18                in  varchar2
  ,p_ejp_attribute19                in  varchar2
  ,p_ejp_attribute20                in  varchar2
  ,p_ejp_attribute21                in  varchar2
  ,p_ejp_attribute22                in  varchar2
  ,p_ejp_attribute23                in  varchar2
  ,p_ejp_attribute24                in  varchar2
  ,p_ejp_attribute25                in  varchar2
  ,p_ejp_attribute26                in  varchar2
  ,p_ejp_attribute27                in  varchar2
  ,p_ejp_attribute28                in  varchar2
  ,p_ejp_attribute29                in  varchar2
  ,p_ejp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIGY_JOB_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIGY_JOB_PRTE_a
  (
   p_elig_job_prte_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_job_id                         in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_ejp_attribute_category         in  varchar2
  ,p_ejp_attribute1                 in  varchar2
  ,p_ejp_attribute2                 in  varchar2
  ,p_ejp_attribute3                 in  varchar2
  ,p_ejp_attribute4                 in  varchar2
  ,p_ejp_attribute5                 in  varchar2
  ,p_ejp_attribute6                 in  varchar2
  ,p_ejp_attribute7                 in  varchar2
  ,p_ejp_attribute8                 in  varchar2
  ,p_ejp_attribute9                 in  varchar2
  ,p_ejp_attribute10                in  varchar2
  ,p_ejp_attribute11                in  varchar2
  ,p_ejp_attribute12                in  varchar2
  ,p_ejp_attribute13                in  varchar2
  ,p_ejp_attribute14                in  varchar2
  ,p_ejp_attribute15                in  varchar2
  ,p_ejp_attribute16                in  varchar2
  ,p_ejp_attribute17                in  varchar2
  ,p_ejp_attribute18                in  varchar2
  ,p_ejp_attribute19                in  varchar2
  ,p_ejp_attribute20                in  varchar2
  ,p_ejp_attribute21                in  varchar2
  ,p_ejp_attribute22                in  varchar2
  ,p_ejp_attribute23                in  varchar2
  ,p_ejp_attribute24                in  varchar2
  ,p_ejp_attribute25                in  varchar2
  ,p_ejp_attribute26                in  varchar2
  ,p_ejp_attribute27                in  varchar2
  ,p_ejp_attribute28                in  varchar2
  ,p_ejp_attribute29                in  varchar2
  ,p_ejp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIGY_JOB_PRTE_bk2;

 

/
