--------------------------------------------------------
--  DDL for Package BEN_ASSIGNMENT_SET_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ASSIGNMENT_SET_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: beasrapi.pkh 120.0 2005/05/28 00:30:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ASSIGNMENT_SET_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ASSIGNMENT_SET_RATE_b
  (
   p_asnt_set_rt_id                 in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_assignment_set_id              in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_business_group_id              in  number
  ,p_asr_attribute_category         in  varchar2
  ,p_asr_attribute1                 in  varchar2
  ,p_asr_attribute2                 in  varchar2
  ,p_asr_attribute3                 in  varchar2
  ,p_asr_attribute4                 in  varchar2
  ,p_asr_attribute5                 in  varchar2
  ,p_asr_attribute6                 in  varchar2
  ,p_asr_attribute7                 in  varchar2
  ,p_asr_attribute8                 in  varchar2
  ,p_asr_attribute9                 in  varchar2
  ,p_asr_attribute10                in  varchar2
  ,p_asr_attribute11                in  varchar2
  ,p_asr_attribute12                in  varchar2
  ,p_asr_attribute13                in  varchar2
  ,p_asr_attribute14                in  varchar2
  ,p_asr_attribute15                in  varchar2
  ,p_asr_attribute16                in  varchar2
  ,p_asr_attribute17                in  varchar2
  ,p_asr_attribute18                in  varchar2
  ,p_asr_attribute19                in  varchar2
  ,p_asr_attribute20                in  varchar2
  ,p_asr_attribute21                in  varchar2
  ,p_asr_attribute22                in  varchar2
  ,p_asr_attribute23                in  varchar2
  ,p_asr_attribute24                in  varchar2
  ,p_asr_attribute25                in  varchar2
  ,p_asr_attribute26                in  varchar2
  ,p_asr_attribute27                in  varchar2
  ,p_asr_attribute28                in  varchar2
  ,p_asr_attribute29                in  varchar2
  ,p_asr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ASSIGNMENT_SET_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ASSIGNMENT_SET_RATE_a
  (
   p_asnt_set_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                in  number
  ,p_assignment_set_id              in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_business_group_id              in  number
  ,p_asr_attribute_category         in  varchar2
  ,p_asr_attribute1                 in  varchar2
  ,p_asr_attribute2                 in  varchar2
  ,p_asr_attribute3                 in  varchar2
  ,p_asr_attribute4                 in  varchar2
  ,p_asr_attribute5                 in  varchar2
  ,p_asr_attribute6                 in  varchar2
  ,p_asr_attribute7                 in  varchar2
  ,p_asr_attribute8                 in  varchar2
  ,p_asr_attribute9                 in  varchar2
  ,p_asr_attribute10                in  varchar2
  ,p_asr_attribute11                in  varchar2
  ,p_asr_attribute12                in  varchar2
  ,p_asr_attribute13                in  varchar2
  ,p_asr_attribute14                in  varchar2
  ,p_asr_attribute15                in  varchar2
  ,p_asr_attribute16                in  varchar2
  ,p_asr_attribute17                in  varchar2
  ,p_asr_attribute18                in  varchar2
  ,p_asr_attribute19                in  varchar2
  ,p_asr_attribute20                in  varchar2
  ,p_asr_attribute21                in  varchar2
  ,p_asr_attribute22                in  varchar2
  ,p_asr_attribute23                in  varchar2
  ,p_asr_attribute24                in  varchar2
  ,p_asr_attribute25                in  varchar2
  ,p_asr_attribute26                in  varchar2
  ,p_asr_attribute27                in  varchar2
  ,p_asr_attribute28                in  varchar2
  ,p_asr_attribute29                in  varchar2
  ,p_asr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ASSIGNMENT_SET_RATE_bk2;

 

/
