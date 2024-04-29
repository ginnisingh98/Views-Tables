--------------------------------------------------------
--  DDL for Package BEN_ACTY_RT_DEDUCT_SCHED_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_RT_DEDUCT_SCHED_BK2" AUTHID CURRENT_USER as
/* $Header: beadsapi.pkh 120.0 2005/05/28 00:22:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ACTY_RT_DEDUCT_SCHED_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ACTY_RT_DEDUCT_SCHED_b
  (
   p_acty_rt_ded_sched_id           in  number
  ,p_business_group_id              in  number
  ,p_ded_sched_py_freq_id           in  number
  ,p_acty_base_rt_id                in  number
  ,p_ded_sched_rl                   in  number
  ,p_ded_sched_cd                   in  varchar2
  ,p_ads_attribute_category         in  varchar2
  ,p_ads_attribute1                 in  varchar2
  ,p_ads_attribute2                 in  varchar2
  ,p_ads_attribute3                 in  varchar2
  ,p_ads_attribute4                 in  varchar2
  ,p_ads_attribute5                 in  varchar2
  ,p_ads_attribute6                 in  varchar2
  ,p_ads_attribute7                 in  varchar2
  ,p_ads_attribute8                 in  varchar2
  ,p_ads_attribute9                 in  varchar2
  ,p_ads_attribute10                in  varchar2
  ,p_ads_attribute11                in  varchar2
  ,p_ads_attribute12                in  varchar2
  ,p_ads_attribute13                in  varchar2
  ,p_ads_attribute14                in  varchar2
  ,p_ads_attribute15                in  varchar2
  ,p_ads_attribute16                in  varchar2
  ,p_ads_attribute17                in  varchar2
  ,p_ads_attribute18                in  varchar2
  ,p_ads_attribute19                in  varchar2
  ,p_ads_attribute20                in  varchar2
  ,p_ads_attribute21                in  varchar2
  ,p_ads_attribute22                in  varchar2
  ,p_ads_attribute23                in  varchar2
  ,p_ads_attribute24                in  varchar2
  ,p_ads_attribute25                in  varchar2
  ,p_ads_attribute26                in  varchar2
  ,p_ads_attribute27                in  varchar2
  ,p_ads_attribute28                in  varchar2
  ,p_ads_attribute29                in  varchar2
  ,p_ads_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ACTY_RT_DEDUCT_SCHED_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ACTY_RT_DEDUCT_SCHED_a
  (
   p_acty_rt_ded_sched_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_ded_sched_py_freq_id           in  number
  ,p_acty_base_rt_id                in  number
  ,p_ded_sched_rl                   in  number
  ,p_ded_sched_cd                   in  varchar2
  ,p_ads_attribute_category         in  varchar2
  ,p_ads_attribute1                 in  varchar2
  ,p_ads_attribute2                 in  varchar2
  ,p_ads_attribute3                 in  varchar2
  ,p_ads_attribute4                 in  varchar2
  ,p_ads_attribute5                 in  varchar2
  ,p_ads_attribute6                 in  varchar2
  ,p_ads_attribute7                 in  varchar2
  ,p_ads_attribute8                 in  varchar2
  ,p_ads_attribute9                 in  varchar2
  ,p_ads_attribute10                in  varchar2
  ,p_ads_attribute11                in  varchar2
  ,p_ads_attribute12                in  varchar2
  ,p_ads_attribute13                in  varchar2
  ,p_ads_attribute14                in  varchar2
  ,p_ads_attribute15                in  varchar2
  ,p_ads_attribute16                in  varchar2
  ,p_ads_attribute17                in  varchar2
  ,p_ads_attribute18                in  varchar2
  ,p_ads_attribute19                in  varchar2
  ,p_ads_attribute20                in  varchar2
  ,p_ads_attribute21                in  varchar2
  ,p_ads_attribute22                in  varchar2
  ,p_ads_attribute23                in  varchar2
  ,p_ads_attribute24                in  varchar2
  ,p_ads_attribute25                in  varchar2
  ,p_ads_attribute26                in  varchar2
  ,p_ads_attribute27                in  varchar2
  ,p_ads_attribute28                in  varchar2
  ,p_ads_attribute29                in  varchar2
  ,p_ads_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ACTY_RT_DEDUCT_SCHED_bk2;

 

/
