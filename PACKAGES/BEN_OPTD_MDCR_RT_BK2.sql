--------------------------------------------------------
--  DDL for Package BEN_OPTD_MDCR_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPTD_MDCR_RT_BK2" AUTHID CURRENT_USER as
/* $Header: beomrapi.pkh 120.0 2005/05/28 09:51:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_OPTD_MDCR_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_OPTD_MDCR_RT_b
  (
   p_optd_mdcr_rt_id         in  number
  ,p_optd_mdcr_flag                 in  varchar2
  ,p_exlcd_flag                     in  varchar2
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_omr_attribute_category         in  varchar2
  ,p_omr_attribute1                 in  varchar2
  ,p_omr_attribute2                 in  varchar2
  ,p_omr_attribute3                 in  varchar2
  ,p_omr_attribute4                 in  varchar2
  ,p_omr_attribute5                 in  varchar2
  ,p_omr_attribute6                 in  varchar2
  ,p_omr_attribute7                 in  varchar2
  ,p_omr_attribute8                 in  varchar2
  ,p_omr_attribute9                 in  varchar2
  ,p_omr_attribute10                in  varchar2
  ,p_omr_attribute11                in  varchar2
  ,p_omr_attribute12                in  varchar2
  ,p_omr_attribute13                in  varchar2
  ,p_omr_attribute14                in  varchar2
  ,p_omr_attribute15                in  varchar2
  ,p_omr_attribute16                in  varchar2
  ,p_omr_attribute17                in  varchar2
  ,p_omr_attribute18                in  varchar2
  ,p_omr_attribute19                in  varchar2
  ,p_omr_attribute20                in  varchar2
  ,p_omr_attribute21                in  varchar2
  ,p_omr_attribute22                in  varchar2
  ,p_omr_attribute23                in  varchar2
  ,p_omr_attribute24                in  varchar2
  ,p_omr_attribute25                in  varchar2
  ,p_omr_attribute26                in  varchar2
  ,p_omr_attribute27                in  varchar2
  ,p_omr_attribute28                in  varchar2
  ,p_omr_attribute29                in  varchar2
  ,p_omr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_OPTD_MDCR_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_OPTD_MDCR_RT_a
  (
   p_optd_mdcr_rt_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_optd_mdcr_flag                 in  varchar2
  ,p_exlcd_flag                     in  varchar2
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_omr_attribute_category         in  varchar2
  ,p_omr_attribute1                 in  varchar2
  ,p_omr_attribute2                 in  varchar2
  ,p_omr_attribute3                 in  varchar2
  ,p_omr_attribute4                 in  varchar2
  ,p_omr_attribute5                 in  varchar2
  ,p_omr_attribute6                 in  varchar2
  ,p_omr_attribute7                 in  varchar2
  ,p_omr_attribute8                 in  varchar2
  ,p_omr_attribute9                 in  varchar2
  ,p_omr_attribute10                in  varchar2
  ,p_omr_attribute11                in  varchar2
  ,p_omr_attribute12                in  varchar2
  ,p_omr_attribute13                in  varchar2
  ,p_omr_attribute14                in  varchar2
  ,p_omr_attribute15                in  varchar2
  ,p_omr_attribute16                in  varchar2
  ,p_omr_attribute17                in  varchar2
  ,p_omr_attribute18                in  varchar2
  ,p_omr_attribute19                in  varchar2
  ,p_omr_attribute20                in  varchar2
  ,p_omr_attribute21                in  varchar2
  ,p_omr_attribute22                in  varchar2
  ,p_omr_attribute23                in  varchar2
  ,p_omr_attribute24                in  varchar2
  ,p_omr_attribute25                in  varchar2
  ,p_omr_attribute26                in  varchar2
  ,p_omr_attribute27                in  varchar2
  ,p_omr_attribute28                in  varchar2
  ,p_omr_attribute29                in  varchar2
  ,p_omr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_OPTD_MDCR_RT_bk2;

 

/
