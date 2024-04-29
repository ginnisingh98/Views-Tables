--------------------------------------------------------
--  DDL for Package BEN_ACTY_VRBL_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_VRBL_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: beavrapi.pkh 120.0 2005/05/28 00:32:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_acty_vrbl_rate_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_acty_vrbl_rate_b
  (
   p_acty_vrbl_rt_id                in  number
  ,p_acty_base_rt_id                in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_avr_attribute_category         in  varchar2
  ,p_avr_attribute1                 in  varchar2
  ,p_avr_attribute2                 in  varchar2
  ,p_avr_attribute3                 in  varchar2
  ,p_avr_attribute4                 in  varchar2
  ,p_avr_attribute5                 in  varchar2
  ,p_avr_attribute6                 in  varchar2
  ,p_avr_attribute7                 in  varchar2
  ,p_avr_attribute8                 in  varchar2
  ,p_avr_attribute9                 in  varchar2
  ,p_avr_attribute10                in  varchar2
  ,p_avr_attribute11                in  varchar2
  ,p_avr_attribute12                in  varchar2
  ,p_avr_attribute13                in  varchar2
  ,p_avr_attribute14                in  varchar2
  ,p_avr_attribute15                in  varchar2
  ,p_avr_attribute16                in  varchar2
  ,p_avr_attribute17                in  varchar2
  ,p_avr_attribute18                in  varchar2
  ,p_avr_attribute19                in  varchar2
  ,p_avr_attribute20                in  varchar2
  ,p_avr_attribute21                in  varchar2
  ,p_avr_attribute22                in  varchar2
  ,p_avr_attribute23                in  varchar2
  ,p_avr_attribute24                in  varchar2
  ,p_avr_attribute25                in  varchar2
  ,p_avr_attribute26                in  varchar2
  ,p_avr_attribute27                in  varchar2
  ,p_avr_attribute28                in  varchar2
  ,p_avr_attribute29                in  varchar2
  ,p_avr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_acty_vrbl_rate_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_acty_vrbl_rate_a
  (
   p_acty_vrbl_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_acty_base_rt_id                in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_avr_attribute_category         in  varchar2
  ,p_avr_attribute1                 in  varchar2
  ,p_avr_attribute2                 in  varchar2
  ,p_avr_attribute3                 in  varchar2
  ,p_avr_attribute4                 in  varchar2
  ,p_avr_attribute5                 in  varchar2
  ,p_avr_attribute6                 in  varchar2
  ,p_avr_attribute7                 in  varchar2
  ,p_avr_attribute8                 in  varchar2
  ,p_avr_attribute9                 in  varchar2
  ,p_avr_attribute10                in  varchar2
  ,p_avr_attribute11                in  varchar2
  ,p_avr_attribute12                in  varchar2
  ,p_avr_attribute13                in  varchar2
  ,p_avr_attribute14                in  varchar2
  ,p_avr_attribute15                in  varchar2
  ,p_avr_attribute16                in  varchar2
  ,p_avr_attribute17                in  varchar2
  ,p_avr_attribute18                in  varchar2
  ,p_avr_attribute19                in  varchar2
  ,p_avr_attribute20                in  varchar2
  ,p_avr_attribute21                in  varchar2
  ,p_avr_attribute22                in  varchar2
  ,p_avr_attribute23                in  varchar2
  ,p_avr_attribute24                in  varchar2
  ,p_avr_attribute25                in  varchar2
  ,p_avr_attribute26                in  varchar2
  ,p_avr_attribute27                in  varchar2
  ,p_avr_attribute28                in  varchar2
  ,p_avr_attribute29                in  varchar2
  ,p_avr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_acty_vrbl_rate_bk2;

 

/
