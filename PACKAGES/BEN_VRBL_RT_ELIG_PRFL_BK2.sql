--------------------------------------------------------
--  DDL for Package BEN_VRBL_RT_ELIG_PRFL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRBL_RT_ELIG_PRFL_BK2" AUTHID CURRENT_USER as
/* $Header: bevepapi.pkh 120.0 2005/05/28 12:02:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_vrbl_rt_elig_prfl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_vrbl_rt_elig_prfl_b
  (
   p_vrbl_rt_elig_prfl_id                       in  number
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                      in  number
  ,p_eligy_prfl_id                         in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_vep_attribute_category         in  varchar2
  ,p_vep_attribute1                 in  varchar2
  ,p_vep_attribute2                 in  varchar2
  ,p_vep_attribute3                 in  varchar2
  ,p_vep_attribute4                 in  varchar2
  ,p_vep_attribute5                 in  varchar2
  ,p_vep_attribute6                 in  varchar2
  ,p_vep_attribute7                 in  varchar2
  ,p_vep_attribute8                 in  varchar2
  ,p_vep_attribute9                 in  varchar2
  ,p_vep_attribute10                in  varchar2
  ,p_vep_attribute11                in  varchar2
  ,p_vep_attribute12                in  varchar2
  ,p_vep_attribute13                in  varchar2
  ,p_vep_attribute14                in  varchar2
  ,p_vep_attribute15                in  varchar2
  ,p_vep_attribute16                in  varchar2
  ,p_vep_attribute17                in  varchar2
  ,p_vep_attribute18                in  varchar2
  ,p_vep_attribute19                in  varchar2
  ,p_vep_attribute20                in  varchar2
  ,p_vep_attribute21                in  varchar2
  ,p_vep_attribute22                in  varchar2
  ,p_vep_attribute23                in  varchar2
  ,p_vep_attribute24                in  varchar2
  ,p_vep_attribute25                in  varchar2
  ,p_vep_attribute26                in  varchar2
  ,p_vep_attribute27                in  varchar2
  ,p_vep_attribute28                in  varchar2
  ,p_vep_attribute29                in  varchar2
  ,p_vep_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_vrbl_rt_elig_prfl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_vrbl_rt_elig_prfl_a
  (
   p_vrbl_rt_elig_prfl_id                       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                      in  number
  ,p_eligy_prfl_id                         in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_vep_attribute_category         in  varchar2
  ,p_vep_attribute1                 in  varchar2
  ,p_vep_attribute2                 in  varchar2
  ,p_vep_attribute3                 in  varchar2
  ,p_vep_attribute4                 in  varchar2
  ,p_vep_attribute5                 in  varchar2
  ,p_vep_attribute6                 in  varchar2
  ,p_vep_attribute7                 in  varchar2
  ,p_vep_attribute8                 in  varchar2
  ,p_vep_attribute9                 in  varchar2
  ,p_vep_attribute10                in  varchar2
  ,p_vep_attribute11                in  varchar2
  ,p_vep_attribute12                in  varchar2
  ,p_vep_attribute13                in  varchar2
  ,p_vep_attribute14                in  varchar2
  ,p_vep_attribute15                in  varchar2
  ,p_vep_attribute16                in  varchar2
  ,p_vep_attribute17                in  varchar2
  ,p_vep_attribute18                in  varchar2
  ,p_vep_attribute19                in  varchar2
  ,p_vep_attribute20                in  varchar2
  ,p_vep_attribute21                in  varchar2
  ,p_vep_attribute22                in  varchar2
  ,p_vep_attribute23                in  varchar2
  ,p_vep_attribute24                in  varchar2
  ,p_vep_attribute25                in  varchar2
  ,p_vep_attribute26                in  varchar2
  ,p_vep_attribute27                in  varchar2
  ,p_vep_attribute28                in  varchar2
  ,p_vep_attribute29                in  varchar2
  ,p_vep_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_vrbl_rt_elig_prfl_bk2;

 

/
