--------------------------------------------------------
--  DDL for Package BEN_TOBACCO_USE_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TOBACCO_USE_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: beturapi.pkh 120.0 2005/05/28 11:58:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_TOBACCO_USE_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_TOBACCO_USE_RATE_b
  (
   p_tbco_use_rt_id                 in  number
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_uses_tbco_flag                 in  varchar2
  ,p_tur_attribute_category         in  varchar2
  ,p_tur_attribute1                 in  varchar2
  ,p_tur_attribute2                 in  varchar2
  ,p_tur_attribute3                 in  varchar2
  ,p_tur_attribute4                 in  varchar2
  ,p_tur_attribute5                 in  varchar2
  ,p_tur_attribute6                 in  varchar2
  ,p_tur_attribute7                 in  varchar2
  ,p_tur_attribute8                 in  varchar2
  ,p_tur_attribute9                 in  varchar2
  ,p_tur_attribute10                in  varchar2
  ,p_tur_attribute11                in  varchar2
  ,p_tur_attribute12                in  varchar2
  ,p_tur_attribute13                in  varchar2
  ,p_tur_attribute14                in  varchar2
  ,p_tur_attribute15                in  varchar2
  ,p_tur_attribute16                in  varchar2
  ,p_tur_attribute17                in  varchar2
  ,p_tur_attribute18                in  varchar2
  ,p_tur_attribute19                in  varchar2
  ,p_tur_attribute20                in  varchar2
  ,p_tur_attribute21                in  varchar2
  ,p_tur_attribute22                in  varchar2
  ,p_tur_attribute23                in  varchar2
  ,p_tur_attribute24                in  varchar2
  ,p_tur_attribute25                in  varchar2
  ,p_tur_attribute26                in  varchar2
  ,p_tur_attribute27                in  varchar2
  ,p_tur_attribute28                in  varchar2
  ,p_tur_attribute29                in  varchar2
  ,p_tur_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_TOBACCO_USE_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_TOBACCO_USE_RATE_a
  (
   p_tbco_use_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_uses_tbco_flag                 in  varchar2
  ,p_tur_attribute_category         in  varchar2
  ,p_tur_attribute1                 in  varchar2
  ,p_tur_attribute2                 in  varchar2
  ,p_tur_attribute3                 in  varchar2
  ,p_tur_attribute4                 in  varchar2
  ,p_tur_attribute5                 in  varchar2
  ,p_tur_attribute6                 in  varchar2
  ,p_tur_attribute7                 in  varchar2
  ,p_tur_attribute8                 in  varchar2
  ,p_tur_attribute9                 in  varchar2
  ,p_tur_attribute10                in  varchar2
  ,p_tur_attribute11                in  varchar2
  ,p_tur_attribute12                in  varchar2
  ,p_tur_attribute13                in  varchar2
  ,p_tur_attribute14                in  varchar2
  ,p_tur_attribute15                in  varchar2
  ,p_tur_attribute16                in  varchar2
  ,p_tur_attribute17                in  varchar2
  ,p_tur_attribute18                in  varchar2
  ,p_tur_attribute19                in  varchar2
  ,p_tur_attribute20                in  varchar2
  ,p_tur_attribute21                in  varchar2
  ,p_tur_attribute22                in  varchar2
  ,p_tur_attribute23                in  varchar2
  ,p_tur_attribute24                in  varchar2
  ,p_tur_attribute25                in  varchar2
  ,p_tur_attribute26                in  varchar2
  ,p_tur_attribute27                in  varchar2
  ,p_tur_attribute28                in  varchar2
  ,p_tur_attribute29                in  varchar2
  ,p_tur_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_TOBACCO_USE_RATE_bk2;

 

/
