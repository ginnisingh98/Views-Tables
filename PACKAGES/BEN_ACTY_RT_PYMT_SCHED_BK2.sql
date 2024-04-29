--------------------------------------------------------
--  DDL for Package BEN_ACTY_RT_PYMT_SCHED_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_RT_PYMT_SCHED_BK2" AUTHID CURRENT_USER as
/* $Header: beapfapi.pkh 120.0 2005/05/28 00:25:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_acty_rt_pymt_sched_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_acty_rt_pymt_sched_b
  (
   p_acty_rt_pymt_sched_id          in  number
  ,p_business_group_id              in  number
  ,p_pymt_sched_rl                  in  number
  ,p_acty_base_rt_id                in  number
  ,p_pymt_sched_cd                  in  varchar2
  ,p_apf_attribute_category         in  varchar2
  ,p_apf_attribute1                 in  varchar2
  ,p_apf_attribute2                 in  varchar2
  ,p_apf_attribute3                 in  varchar2
  ,p_apf_attribute4                 in  varchar2
  ,p_apf_attribute5                 in  varchar2
  ,p_apf_attribute6                 in  varchar2
  ,p_apf_attribute7                 in  varchar2
  ,p_apf_attribute8                 in  varchar2
  ,p_apf_attribute9                 in  varchar2
  ,p_apf_attribute10                in  varchar2
  ,p_apf_attribute11                in  varchar2
  ,p_apf_attribute12                in  varchar2
  ,p_apf_attribute13                in  varchar2
  ,p_apf_attribute14                in  varchar2
  ,p_apf_attribute15                in  varchar2
  ,p_apf_attribute16                in  varchar2
  ,p_apf_attribute17                in  varchar2
  ,p_apf_attribute18                in  varchar2
  ,p_apf_attribute19                in  varchar2
  ,p_apf_attribute20                in  varchar2
  ,p_apf_attribute21                in  varchar2
  ,p_apf_attribute22                in  varchar2
  ,p_apf_attribute23                in  varchar2
  ,p_apf_attribute24                in  varchar2
  ,p_apf_attribute25                in  varchar2
  ,p_apf_attribute26                in  varchar2
  ,p_apf_attribute27                in  varchar2
  ,p_apf_attribute28                in  varchar2
  ,p_apf_attribute29                in  varchar2
  ,p_apf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_acty_rt_pymt_sched_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_acty_rt_pymt_sched_a
  (
   p_acty_rt_pymt_sched_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_pymt_sched_rl                  in  number
  ,p_acty_base_rt_id                in  number
  ,p_pymt_sched_cd                  in  varchar2
  ,p_apf_attribute_category         in  varchar2
  ,p_apf_attribute1                 in  varchar2
  ,p_apf_attribute2                 in  varchar2
  ,p_apf_attribute3                 in  varchar2
  ,p_apf_attribute4                 in  varchar2
  ,p_apf_attribute5                 in  varchar2
  ,p_apf_attribute6                 in  varchar2
  ,p_apf_attribute7                 in  varchar2
  ,p_apf_attribute8                 in  varchar2
  ,p_apf_attribute9                 in  varchar2
  ,p_apf_attribute10                in  varchar2
  ,p_apf_attribute11                in  varchar2
  ,p_apf_attribute12                in  varchar2
  ,p_apf_attribute13                in  varchar2
  ,p_apf_attribute14                in  varchar2
  ,p_apf_attribute15                in  varchar2
  ,p_apf_attribute16                in  varchar2
  ,p_apf_attribute17                in  varchar2
  ,p_apf_attribute18                in  varchar2
  ,p_apf_attribute19                in  varchar2
  ,p_apf_attribute20                in  varchar2
  ,p_apf_attribute21                in  varchar2
  ,p_apf_attribute22                in  varchar2
  ,p_apf_attribute23                in  varchar2
  ,p_apf_attribute24                in  varchar2
  ,p_apf_attribute25                in  varchar2
  ,p_apf_attribute26                in  varchar2
  ,p_apf_attribute27                in  varchar2
  ,p_apf_attribute28                in  varchar2
  ,p_apf_attribute29                in  varchar2
  ,p_apf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_acty_rt_pymt_sched_bk2;

 

/
