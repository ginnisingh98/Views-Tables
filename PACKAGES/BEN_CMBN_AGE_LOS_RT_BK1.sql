--------------------------------------------------------
--  DDL for Package BEN_CMBN_AGE_LOS_RT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMBN_AGE_LOS_RT_BK1" AUTHID CURRENT_USER as
/* $Header: becmrapi.pkh 120.0 2005/05/28 01:06:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_CMBN_AGE_LOS_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_CMBN_AGE_LOS_RT_b
  (
   p_vrbl_rt_prfl_id                in  number
  ,p_cmbn_age_los_fctr_id           in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_cmr_attribute_category         in  varchar2
  ,p_cmr_attribute1                 in  varchar2
  ,p_cmr_attribute2                 in  varchar2
  ,p_cmr_attribute3                 in  varchar2
  ,p_cmr_attribute4                 in  varchar2
  ,p_cmr_attribute5                 in  varchar2
  ,p_cmr_attribute6                 in  varchar2
  ,p_cmr_attribute7                 in  varchar2
  ,p_cmr_attribute8                 in  varchar2
  ,p_cmr_attribute9                 in  varchar2
  ,p_cmr_attribute10                in  varchar2
  ,p_cmr_attribute11                in  varchar2
  ,p_cmr_attribute12                in  varchar2
  ,p_cmr_attribute13                in  varchar2
  ,p_cmr_attribute14                in  varchar2
  ,p_cmr_attribute15                in  varchar2
  ,p_cmr_attribute16                in  varchar2
  ,p_cmr_attribute17                in  varchar2
  ,p_cmr_attribute18                in  varchar2
  ,p_cmr_attribute19                in  varchar2
  ,p_cmr_attribute20                in  varchar2
  ,p_cmr_attribute21                in  varchar2
  ,p_cmr_attribute22                in  varchar2
  ,p_cmr_attribute23                in  varchar2
  ,p_cmr_attribute24                in  varchar2
  ,p_cmr_attribute25                in  varchar2
  ,p_cmr_attribute26                in  varchar2
  ,p_cmr_attribute27                in  varchar2
  ,p_cmr_attribute28                in  varchar2
  ,p_cmr_attribute29                in  varchar2
  ,p_cmr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_CMBN_AGE_LOS_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_CMBN_AGE_LOS_RT_a
  (
   p_cmbn_age_los_rt_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                in  number
  ,p_cmbn_age_los_fctr_id           in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_cmr_attribute_category         in  varchar2
  ,p_cmr_attribute1                 in  varchar2
  ,p_cmr_attribute2                 in  varchar2
  ,p_cmr_attribute3                 in  varchar2
  ,p_cmr_attribute4                 in  varchar2
  ,p_cmr_attribute5                 in  varchar2
  ,p_cmr_attribute6                 in  varchar2
  ,p_cmr_attribute7                 in  varchar2
  ,p_cmr_attribute8                 in  varchar2
  ,p_cmr_attribute9                 in  varchar2
  ,p_cmr_attribute10                in  varchar2
  ,p_cmr_attribute11                in  varchar2
  ,p_cmr_attribute12                in  varchar2
  ,p_cmr_attribute13                in  varchar2
  ,p_cmr_attribute14                in  varchar2
  ,p_cmr_attribute15                in  varchar2
  ,p_cmr_attribute16                in  varchar2
  ,p_cmr_attribute17                in  varchar2
  ,p_cmr_attribute18                in  varchar2
  ,p_cmr_attribute19                in  varchar2
  ,p_cmr_attribute20                in  varchar2
  ,p_cmr_attribute21                in  varchar2
  ,p_cmr_attribute22                in  varchar2
  ,p_cmr_attribute23                in  varchar2
  ,p_cmr_attribute24                in  varchar2
  ,p_cmr_attribute25                in  varchar2
  ,p_cmr_attribute26                in  varchar2
  ,p_cmr_attribute27                in  varchar2
  ,p_cmr_attribute28                in  varchar2
  ,p_cmr_attribute29                in  varchar2
  ,p_cmr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_CMBN_AGE_LOS_RT_bk1;

 

/
