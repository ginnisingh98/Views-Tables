--------------------------------------------------------
--  DDL for Package BEN_PCT_FULL_TIME_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCT_FULL_TIME_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: bepfrapi.pkh 120.0 2005/05/28 10:43:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PCT_FULL_TIME_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PCT_FULL_TIME_RATE_b
  (
   p_pct_fl_tm_rt_id                in  number
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_pct_fl_tm_fctr_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_pfr_attribute_category         in  varchar2
  ,p_pfr_attribute1                 in  varchar2
  ,p_pfr_attribute2                 in  varchar2
  ,p_pfr_attribute3                 in  varchar2
  ,p_pfr_attribute4                 in  varchar2
  ,p_pfr_attribute5                 in  varchar2
  ,p_pfr_attribute6                 in  varchar2
  ,p_pfr_attribute7                 in  varchar2
  ,p_pfr_attribute8                 in  varchar2
  ,p_pfr_attribute9                 in  varchar2
  ,p_pfr_attribute10                in  varchar2
  ,p_pfr_attribute11                in  varchar2
  ,p_pfr_attribute12                in  varchar2
  ,p_pfr_attribute13                in  varchar2
  ,p_pfr_attribute14                in  varchar2
  ,p_pfr_attribute15                in  varchar2
  ,p_pfr_attribute16                in  varchar2
  ,p_pfr_attribute17                in  varchar2
  ,p_pfr_attribute18                in  varchar2
  ,p_pfr_attribute19                in  varchar2
  ,p_pfr_attribute20                in  varchar2
  ,p_pfr_attribute21                in  varchar2
  ,p_pfr_attribute22                in  varchar2
  ,p_pfr_attribute23                in  varchar2
  ,p_pfr_attribute24                in  varchar2
  ,p_pfr_attribute25                in  varchar2
  ,p_pfr_attribute26                in  varchar2
  ,p_pfr_attribute27                in  varchar2
  ,p_pfr_attribute28                in  varchar2
  ,p_pfr_attribute29                in  varchar2
  ,p_pfr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PCT_FULL_TIME_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PCT_FULL_TIME_RATE_a
  (
   p_pct_fl_tm_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_pct_fl_tm_fctr_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_pfr_attribute_category         in  varchar2
  ,p_pfr_attribute1                 in  varchar2
  ,p_pfr_attribute2                 in  varchar2
  ,p_pfr_attribute3                 in  varchar2
  ,p_pfr_attribute4                 in  varchar2
  ,p_pfr_attribute5                 in  varchar2
  ,p_pfr_attribute6                 in  varchar2
  ,p_pfr_attribute7                 in  varchar2
  ,p_pfr_attribute8                 in  varchar2
  ,p_pfr_attribute9                 in  varchar2
  ,p_pfr_attribute10                in  varchar2
  ,p_pfr_attribute11                in  varchar2
  ,p_pfr_attribute12                in  varchar2
  ,p_pfr_attribute13                in  varchar2
  ,p_pfr_attribute14                in  varchar2
  ,p_pfr_attribute15                in  varchar2
  ,p_pfr_attribute16                in  varchar2
  ,p_pfr_attribute17                in  varchar2
  ,p_pfr_attribute18                in  varchar2
  ,p_pfr_attribute19                in  varchar2
  ,p_pfr_attribute20                in  varchar2
  ,p_pfr_attribute21                in  varchar2
  ,p_pfr_attribute22                in  varchar2
  ,p_pfr_attribute23                in  varchar2
  ,p_pfr_attribute24                in  varchar2
  ,p_pfr_attribute25                in  varchar2
  ,p_pfr_attribute26                in  varchar2
  ,p_pfr_attribute27                in  varchar2
  ,p_pfr_attribute28                in  varchar2
  ,p_pfr_attribute29                in  varchar2
  ,p_pfr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_PCT_FULL_TIME_RATE_bk2;

 

/
