--------------------------------------------------------
--  DDL for Package BEN_ELIG_SUPPL_ROLE_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_SUPPL_ROLE_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beestapi.pkh 120.0 2005/05/28 02:59:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_elig_suppl_role_prte_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_elig_suppl_role_prte_b
  (
   p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_job_group_id                   in  number
  ,p_job_id                         in  number
  ,p_est_attribute_category         in  varchar2
  ,p_est_attribute1                 in  varchar2
  ,p_est_attribute2                 in  varchar2
  ,p_est_attribute3                 in  varchar2
  ,p_est_attribute4                 in  varchar2
  ,p_est_attribute5                 in  varchar2
  ,p_est_attribute6                 in  varchar2
  ,p_est_attribute7                 in  varchar2
  ,p_est_attribute8                 in  varchar2
  ,p_est_attribute9                 in  varchar2
  ,p_est_attribute10                in  varchar2
  ,p_est_attribute11                in  varchar2
  ,p_est_attribute12                in  varchar2
  ,p_est_attribute13                in  varchar2
  ,p_est_attribute14                in  varchar2
  ,p_est_attribute15                in  varchar2
  ,p_est_attribute16                in  varchar2
  ,p_est_attribute17                in  varchar2
  ,p_est_attribute18                in  varchar2
  ,p_est_attribute19                in  varchar2
  ,p_est_attribute20                in  varchar2
  ,p_est_attribute21                in  varchar2
  ,p_est_attribute22                in  varchar2
  ,p_est_attribute23                in  varchar2
  ,p_est_attribute24                in  varchar2
  ,p_est_attribute25                in  varchar2
  ,p_est_attribute26                in  varchar2
  ,p_est_attribute27                in  varchar2
  ,p_est_attribute28                in  varchar2
  ,p_est_attribute29                in  varchar2
  ,p_est_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_elig_suppl_role_prte_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_elig_suppl_role_prte_a
  (
   p_elig_suppl_role_prte_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_job_group_id                   in  number
  ,p_job_id                         in  number
  ,p_est_attribute_category         in  varchar2
  ,p_est_attribute1                 in  varchar2
  ,p_est_attribute2                 in  varchar2
  ,p_est_attribute3                 in  varchar2
  ,p_est_attribute4                 in  varchar2
  ,p_est_attribute5                 in  varchar2
  ,p_est_attribute6                 in  varchar2
  ,p_est_attribute7                 in  varchar2
  ,p_est_attribute8                 in  varchar2
  ,p_est_attribute9                 in  varchar2
  ,p_est_attribute10                in  varchar2
  ,p_est_attribute11                in  varchar2
  ,p_est_attribute12                in  varchar2
  ,p_est_attribute13                in  varchar2
  ,p_est_attribute14                in  varchar2
  ,p_est_attribute15                in  varchar2
  ,p_est_attribute16                in  varchar2
  ,p_est_attribute17                in  varchar2
  ,p_est_attribute18                in  varchar2
  ,p_est_attribute19                in  varchar2
  ,p_est_attribute20                in  varchar2
  ,p_est_attribute21                in  varchar2
  ,p_est_attribute22                in  varchar2
  ,p_est_attribute23                in  varchar2
  ,p_est_attribute24                in  varchar2
  ,p_est_attribute25                in  varchar2
  ,p_est_attribute26                in  varchar2
  ,p_est_attribute27                in  varchar2
  ,p_est_attribute28                in  varchar2
  ,p_est_attribute29                in  varchar2
  ,p_est_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_elig_suppl_role_prte_bk1;

 

/
