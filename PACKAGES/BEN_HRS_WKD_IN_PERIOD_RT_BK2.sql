--------------------------------------------------------
--  DDL for Package BEN_HRS_WKD_IN_PERIOD_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HRS_WKD_IN_PERIOD_RT_BK2" AUTHID CURRENT_USER as
/* $Header: behwrapi.pkh 120.0 2005/05/28 03:12:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_HRS_WKD_IN_PERIOD_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_HRS_WKD_IN_PERIOD_RT_b
  (
   p_hrs_wkd_in_perd_rt_id          in  number
  ,p_business_group_id              in  number
  ,p_hrs_wkd_in_perd_fctr_id        in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_hwr_attribute_category         in  varchar2
  ,p_hwr_attribute1                 in  varchar2
  ,p_hwr_attribute2                 in  varchar2
  ,p_hwr_attribute3                 in  varchar2
  ,p_hwr_attribute4                 in  varchar2
  ,p_hwr_attribute5                 in  varchar2
  ,p_hwr_attribute6                 in  varchar2
  ,p_hwr_attribute7                 in  varchar2
  ,p_hwr_attribute8                 in  varchar2
  ,p_hwr_attribute9                 in  varchar2
  ,p_hwr_attribute10                in  varchar2
  ,p_hwr_attribute11                in  varchar2
  ,p_hwr_attribute12                in  varchar2
  ,p_hwr_attribute13                in  varchar2
  ,p_hwr_attribute14                in  varchar2
  ,p_hwr_attribute15                in  varchar2
  ,p_hwr_attribute16                in  varchar2
  ,p_hwr_attribute17                in  varchar2
  ,p_hwr_attribute18                in  varchar2
  ,p_hwr_attribute19                in  varchar2
  ,p_hwr_attribute20                in  varchar2
  ,p_hwr_attribute21                in  varchar2
  ,p_hwr_attribute22                in  varchar2
  ,p_hwr_attribute23                in  varchar2
  ,p_hwr_attribute24                in  varchar2
  ,p_hwr_attribute25                in  varchar2
  ,p_hwr_attribute26                in  varchar2
  ,p_hwr_attribute27                in  varchar2
  ,p_hwr_attribute28                in  varchar2
  ,p_hwr_attribute29                in  varchar2
  ,p_hwr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_HRS_WKD_IN_PERIOD_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_HRS_WKD_IN_PERIOD_RT_a
  (
   p_hrs_wkd_in_perd_rt_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_hrs_wkd_in_perd_fctr_id        in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_hwr_attribute_category         in  varchar2
  ,p_hwr_attribute1                 in  varchar2
  ,p_hwr_attribute2                 in  varchar2
  ,p_hwr_attribute3                 in  varchar2
  ,p_hwr_attribute4                 in  varchar2
  ,p_hwr_attribute5                 in  varchar2
  ,p_hwr_attribute6                 in  varchar2
  ,p_hwr_attribute7                 in  varchar2
  ,p_hwr_attribute8                 in  varchar2
  ,p_hwr_attribute9                 in  varchar2
  ,p_hwr_attribute10                in  varchar2
  ,p_hwr_attribute11                in  varchar2
  ,p_hwr_attribute12                in  varchar2
  ,p_hwr_attribute13                in  varchar2
  ,p_hwr_attribute14                in  varchar2
  ,p_hwr_attribute15                in  varchar2
  ,p_hwr_attribute16                in  varchar2
  ,p_hwr_attribute17                in  varchar2
  ,p_hwr_attribute18                in  varchar2
  ,p_hwr_attribute19                in  varchar2
  ,p_hwr_attribute20                in  varchar2
  ,p_hwr_attribute21                in  varchar2
  ,p_hwr_attribute22                in  varchar2
  ,p_hwr_attribute23                in  varchar2
  ,p_hwr_attribute24                in  varchar2
  ,p_hwr_attribute25                in  varchar2
  ,p_hwr_attribute26                in  varchar2
  ,p_hwr_attribute27                in  varchar2
  ,p_hwr_attribute28                in  varchar2
  ,p_hwr_attribute29                in  varchar2
  ,p_hwr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_HRS_WKD_IN_PERIOD_RT_bk2;

 

/
