--------------------------------------------------------
--  DDL for Package BEN_LENGTH_OF_SVC_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LENGTH_OF_SVC_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: belsrapi.pkh 120.0 2005/05/28 03:38:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_LENGTH_OF_SVC_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_LENGTH_OF_SVC_RATE_b
  (
   p_los_rt_id                      in  number
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_los_fctr_id                    in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_lsr_attribute_category         in  varchar2
  ,p_lsr_attribute1                 in  varchar2
  ,p_lsr_attribute2                 in  varchar2
  ,p_lsr_attribute3                 in  varchar2
  ,p_lsr_attribute4                 in  varchar2
  ,p_lsr_attribute5                 in  varchar2
  ,p_lsr_attribute6                 in  varchar2
  ,p_lsr_attribute7                 in  varchar2
  ,p_lsr_attribute8                 in  varchar2
  ,p_lsr_attribute9                 in  varchar2
  ,p_lsr_attribute10                in  varchar2
  ,p_lsr_attribute11                in  varchar2
  ,p_lsr_attribute12                in  varchar2
  ,p_lsr_attribute13                in  varchar2
  ,p_lsr_attribute14                in  varchar2
  ,p_lsr_attribute15                in  varchar2
  ,p_lsr_attribute16                in  varchar2
  ,p_lsr_attribute17                in  varchar2
  ,p_lsr_attribute18                in  varchar2
  ,p_lsr_attribute19                in  varchar2
  ,p_lsr_attribute20                in  varchar2
  ,p_lsr_attribute21                in  varchar2
  ,p_lsr_attribute22                in  varchar2
  ,p_lsr_attribute23                in  varchar2
  ,p_lsr_attribute24                in  varchar2
  ,p_lsr_attribute25                in  varchar2
  ,p_lsr_attribute26                in  varchar2
  ,p_lsr_attribute27                in  varchar2
  ,p_lsr_attribute28                in  varchar2
  ,p_lsr_attribute29                in  varchar2
  ,p_lsr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_LENGTH_OF_SVC_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_LENGTH_OF_SVC_RATE_a
  (
   p_los_rt_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_los_fctr_id                    in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_lsr_attribute_category         in  varchar2
  ,p_lsr_attribute1                 in  varchar2
  ,p_lsr_attribute2                 in  varchar2
  ,p_lsr_attribute3                 in  varchar2
  ,p_lsr_attribute4                 in  varchar2
  ,p_lsr_attribute5                 in  varchar2
  ,p_lsr_attribute6                 in  varchar2
  ,p_lsr_attribute7                 in  varchar2
  ,p_lsr_attribute8                 in  varchar2
  ,p_lsr_attribute9                 in  varchar2
  ,p_lsr_attribute10                in  varchar2
  ,p_lsr_attribute11                in  varchar2
  ,p_lsr_attribute12                in  varchar2
  ,p_lsr_attribute13                in  varchar2
  ,p_lsr_attribute14                in  varchar2
  ,p_lsr_attribute15                in  varchar2
  ,p_lsr_attribute16                in  varchar2
  ,p_lsr_attribute17                in  varchar2
  ,p_lsr_attribute18                in  varchar2
  ,p_lsr_attribute19                in  varchar2
  ,p_lsr_attribute20                in  varchar2
  ,p_lsr_attribute21                in  varchar2
  ,p_lsr_attribute22                in  varchar2
  ,p_lsr_attribute23                in  varchar2
  ,p_lsr_attribute24                in  varchar2
  ,p_lsr_attribute25                in  varchar2
  ,p_lsr_attribute26                in  varchar2
  ,p_lsr_attribute27                in  varchar2
  ,p_lsr_attribute28                in  varchar2
  ,p_lsr_attribute29                in  varchar2
  ,p_lsr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_LENGTH_OF_SVC_RATE_bk2;

 

/
