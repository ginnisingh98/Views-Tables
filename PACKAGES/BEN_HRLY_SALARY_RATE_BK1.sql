--------------------------------------------------------
--  DDL for Package BEN_HRLY_SALARY_RATE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HRLY_SALARY_RATE_BK1" AUTHID CURRENT_USER as
/* $Header: behsrapi.pkh 120.0 2005/05/28 03:11:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_HRLY_SALARY_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_HRLY_SALARY_RATE_b
  (
   p_vrbl_rt_prfl_id                in  number
  ,p_hrly_slrd_cd                   in  varchar2
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_hsr_attribute_category         in  varchar2
  ,p_hsr_attribute1                 in  varchar2
  ,p_hsr_attribute2                 in  varchar2
  ,p_hsr_attribute3                 in  varchar2
  ,p_hsr_attribute4                 in  varchar2
  ,p_hsr_attribute5                 in  varchar2
  ,p_hsr_attribute6                 in  varchar2
  ,p_hsr_attribute7                 in  varchar2
  ,p_hsr_attribute8                 in  varchar2
  ,p_hsr_attribute9                 in  varchar2
  ,p_hsr_attribute10                in  varchar2
  ,p_hsr_attribute11                in  varchar2
  ,p_hsr_attribute12                in  varchar2
  ,p_hsr_attribute13                in  varchar2
  ,p_hsr_attribute14                in  varchar2
  ,p_hsr_attribute15                in  varchar2
  ,p_hsr_attribute16                in  varchar2
  ,p_hsr_attribute17                in  varchar2
  ,p_hsr_attribute18                in  varchar2
  ,p_hsr_attribute19                in  varchar2
  ,p_hsr_attribute20                in  varchar2
  ,p_hsr_attribute21                in  varchar2
  ,p_hsr_attribute22                in  varchar2
  ,p_hsr_attribute23                in  varchar2
  ,p_hsr_attribute24                in  varchar2
  ,p_hsr_attribute25                in  varchar2
  ,p_hsr_attribute26                in  varchar2
  ,p_hsr_attribute27                in  varchar2
  ,p_hsr_attribute28                in  varchar2
  ,p_hsr_attribute29                in  varchar2
  ,p_hsr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_HRLY_SALARY_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_HRLY_SALARY_RATE_a
  (
   p_hrly_slrd_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                in  number
  ,p_hrly_slrd_cd                   in  varchar2
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_hsr_attribute_category         in  varchar2
  ,p_hsr_attribute1                 in  varchar2
  ,p_hsr_attribute2                 in  varchar2
  ,p_hsr_attribute3                 in  varchar2
  ,p_hsr_attribute4                 in  varchar2
  ,p_hsr_attribute5                 in  varchar2
  ,p_hsr_attribute6                 in  varchar2
  ,p_hsr_attribute7                 in  varchar2
  ,p_hsr_attribute8                 in  varchar2
  ,p_hsr_attribute9                 in  varchar2
  ,p_hsr_attribute10                in  varchar2
  ,p_hsr_attribute11                in  varchar2
  ,p_hsr_attribute12                in  varchar2
  ,p_hsr_attribute13                in  varchar2
  ,p_hsr_attribute14                in  varchar2
  ,p_hsr_attribute15                in  varchar2
  ,p_hsr_attribute16                in  varchar2
  ,p_hsr_attribute17                in  varchar2
  ,p_hsr_attribute18                in  varchar2
  ,p_hsr_attribute19                in  varchar2
  ,p_hsr_attribute20                in  varchar2
  ,p_hsr_attribute21                in  varchar2
  ,p_hsr_attribute22                in  varchar2
  ,p_hsr_attribute23                in  varchar2
  ,p_hsr_attribute24                in  varchar2
  ,p_hsr_attribute25                in  varchar2
  ,p_hsr_attribute26                in  varchar2
  ,p_hsr_attribute27                in  varchar2
  ,p_hsr_attribute28                in  varchar2
  ,p_hsr_attribute29                in  varchar2
  ,p_hsr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_HRLY_SALARY_RATE_bk1;

 

/
