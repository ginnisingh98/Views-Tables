--------------------------------------------------------
--  DDL for Package BEN_PRTN_ELIG_PRFL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTN_ELIG_PRFL_BK2" AUTHID CURRENT_USER as
/* $Header: becepapi.pkh 120.0 2005/05/28 00:59:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PRTN_ELIG_PRFL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTN_ELIG_PRFL_b
  (
   p_prtn_elig_prfl_id              in  number
  ,p_business_group_id              in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_prtn_elig_id                   in  number
  ,p_eligy_prfl_id                  in  number
  ,p_Elig_prfl_type_cd              in  varchar2
  ,p_cep_attribute_category         in  varchar2
  ,p_cep_attribute1                 in  varchar2
  ,p_cep_attribute2                 in  varchar2
  ,p_cep_attribute3                 in  varchar2
  ,p_cep_attribute4                 in  varchar2
  ,p_cep_attribute5                 in  varchar2
  ,p_cep_attribute6                 in  varchar2
  ,p_cep_attribute7                 in  varchar2
  ,p_cep_attribute8                 in  varchar2
  ,p_cep_attribute9                 in  varchar2
  ,p_cep_attribute10                in  varchar2
  ,p_cep_attribute11                in  varchar2
  ,p_cep_attribute12                in  varchar2
  ,p_cep_attribute13                in  varchar2
  ,p_cep_attribute14                in  varchar2
  ,p_cep_attribute15                in  varchar2
  ,p_cep_attribute16                in  varchar2
  ,p_cep_attribute17                in  varchar2
  ,p_cep_attribute18                in  varchar2
  ,p_cep_attribute19                in  varchar2
  ,p_cep_attribute20                in  varchar2
  ,p_cep_attribute21                in  varchar2
  ,p_cep_attribute22                in  varchar2
  ,p_cep_attribute23                in  varchar2
  ,p_cep_attribute24                in  varchar2
  ,p_cep_attribute25                in  varchar2
  ,p_cep_attribute26                in  varchar2
  ,p_cep_attribute27                in  varchar2
  ,p_cep_attribute28                in  varchar2
  ,p_cep_attribute29                in  varchar2
  ,p_cep_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_compute_score_flag             in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PRTN_ELIG_PRFL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTN_ELIG_PRFL_a
  (
   p_prtn_elig_prfl_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_prtn_elig_id                   in  number
  ,p_eligy_prfl_id                  in  number
  ,p_Elig_prfl_type_cd              in  varchar2
  ,p_cep_attribute_category         in  varchar2
  ,p_cep_attribute1                 in  varchar2
  ,p_cep_attribute2                 in  varchar2
  ,p_cep_attribute3                 in  varchar2
  ,p_cep_attribute4                 in  varchar2
  ,p_cep_attribute5                 in  varchar2
  ,p_cep_attribute6                 in  varchar2
  ,p_cep_attribute7                 in  varchar2
  ,p_cep_attribute8                 in  varchar2
  ,p_cep_attribute9                 in  varchar2
  ,p_cep_attribute10                in  varchar2
  ,p_cep_attribute11                in  varchar2
  ,p_cep_attribute12                in  varchar2
  ,p_cep_attribute13                in  varchar2
  ,p_cep_attribute14                in  varchar2
  ,p_cep_attribute15                in  varchar2
  ,p_cep_attribute16                in  varchar2
  ,p_cep_attribute17                in  varchar2
  ,p_cep_attribute18                in  varchar2
  ,p_cep_attribute19                in  varchar2
  ,p_cep_attribute20                in  varchar2
  ,p_cep_attribute21                in  varchar2
  ,p_cep_attribute22                in  varchar2
  ,p_cep_attribute23                in  varchar2
  ,p_cep_attribute24                in  varchar2
  ,p_cep_attribute25                in  varchar2
  ,p_cep_attribute26                in  varchar2
  ,p_cep_attribute27                in  varchar2
  ,p_cep_attribute28                in  varchar2
  ,p_cep_attribute29                in  varchar2
  ,p_cep_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_compute_score_flag             in  varchar2
  );
--
end ben_PRTN_ELIG_PRFL_bk2;

 

/
