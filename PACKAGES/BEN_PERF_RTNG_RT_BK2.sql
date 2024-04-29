--------------------------------------------------------
--  DDL for Package BEN_PERF_RTNG_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERF_RTNG_RT_BK2" AUTHID CURRENT_USER as
/* $Header: beprrapi.pkh 120.0 2005/05/28 11:12:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_perf_rtng_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_perf_rtng_rt_b
  (
   p_perf_rtng_rt_id                in  number
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_event_type          	    in  varchar2
  ,p_perf_rtng_cd                   in  varchar2
  ,p_prr_attribute_category         in  varchar2
  ,p_prr_attribute1                 in  varchar2
  ,p_prr_attribute2                 in  varchar2
  ,p_prr_attribute3                 in  varchar2
  ,p_prr_attribute4                 in  varchar2
  ,p_prr_attribute5                 in  varchar2
  ,p_prr_attribute6                 in  varchar2
  ,p_prr_attribute7                 in  varchar2
  ,p_prr_attribute8                 in  varchar2
  ,p_prr_attribute9                 in  varchar2
  ,p_prr_attribute10                in  varchar2
  ,p_prr_attribute11                in  varchar2
  ,p_prr_attribute12                in  varchar2
  ,p_prr_attribute13                in  varchar2
  ,p_prr_attribute14                in  varchar2
  ,p_prr_attribute15                in  varchar2
  ,p_prr_attribute16                in  varchar2
  ,p_prr_attribute17                in  varchar2
  ,p_prr_attribute18                in  varchar2
  ,p_prr_attribute19                in  varchar2
  ,p_prr_attribute20                in  varchar2
  ,p_prr_attribute21                in  varchar2
  ,p_prr_attribute22                in  varchar2
  ,p_prr_attribute23                in  varchar2
  ,p_prr_attribute24                in  varchar2
  ,p_prr_attribute25                in  varchar2
  ,p_prr_attribute26                in  varchar2
  ,p_prr_attribute27                in  varchar2
  ,p_prr_attribute28                in  varchar2
  ,p_prr_attribute29                in  varchar2
  ,p_prr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_perf_rtng_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_perf_rtng_rt_a
  (
   p_perf_rtng_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_event_type          	    in  varchar2
  ,p_perf_rtng_cd                   in  varchar2
  ,p_prr_attribute_category         in  varchar2
  ,p_prr_attribute1                 in  varchar2
  ,p_prr_attribute2                 in  varchar2
  ,p_prr_attribute3                 in  varchar2
  ,p_prr_attribute4                 in  varchar2
  ,p_prr_attribute5                 in  varchar2
  ,p_prr_attribute6                 in  varchar2
  ,p_prr_attribute7                 in  varchar2
  ,p_prr_attribute8                 in  varchar2
  ,p_prr_attribute9                 in  varchar2
  ,p_prr_attribute10                in  varchar2
  ,p_prr_attribute11                in  varchar2
  ,p_prr_attribute12                in  varchar2
  ,p_prr_attribute13                in  varchar2
  ,p_prr_attribute14                in  varchar2
  ,p_prr_attribute15                in  varchar2
  ,p_prr_attribute16                in  varchar2
  ,p_prr_attribute17                in  varchar2
  ,p_prr_attribute18                in  varchar2
  ,p_prr_attribute19                in  varchar2
  ,p_prr_attribute20                in  varchar2
  ,p_prr_attribute21                in  varchar2
  ,p_prr_attribute22                in  varchar2
  ,p_prr_attribute23                in  varchar2
  ,p_prr_attribute24                in  varchar2
  ,p_prr_attribute25                in  varchar2
  ,p_prr_attribute26                in  varchar2
  ,p_prr_attribute27                in  varchar2
  ,p_prr_attribute28                in  varchar2
  ,p_prr_attribute29                in  varchar2
  ,p_prr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_perf_rtng_rt_bk2;

 

/
