--------------------------------------------------------
--  DDL for Package BEN_GENDER_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GENDER_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: begnrapi.pkh 120.0 2005/05/28 03:07:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_GENDER_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_GENDER_RATE_b
  (
   p_gndr_rt_id                     in  number
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_gndr_cd                        in  varchar2
  ,p_excld_flag                     in  varchar2
  ,p_gnr_attribute_category         in  varchar2
  ,p_gnr_attribute1                 in  varchar2
  ,p_gnr_attribute2                 in  varchar2
  ,p_gnr_attribute3                 in  varchar2
  ,p_gnr_attribute4                 in  varchar2
  ,p_gnr_attribute5                 in  varchar2
  ,p_gnr_attribute6                 in  varchar2
  ,p_gnr_attribute7                 in  varchar2
  ,p_gnr_attribute8                 in  varchar2
  ,p_gnr_attribute9                 in  varchar2
  ,p_gnr_attribute10                in  varchar2
  ,p_gnr_attribute11                in  varchar2
  ,p_gnr_attribute12                in  varchar2
  ,p_gnr_attribute13                in  varchar2
  ,p_gnr_attribute14                in  varchar2
  ,p_gnr_attribute15                in  varchar2
  ,p_gnr_attribute16                in  varchar2
  ,p_gnr_attribute17                in  varchar2
  ,p_gnr_attribute18                in  varchar2
  ,p_gnr_attribute19                in  varchar2
  ,p_gnr_attribute20                in  varchar2
  ,p_gnr_attribute21                in  varchar2
  ,p_gnr_attribute22                in  varchar2
  ,p_gnr_attribute23                in  varchar2
  ,p_gnr_attribute24                in  varchar2
  ,p_gnr_attribute25                in  varchar2
  ,p_gnr_attribute26                in  varchar2
  ,p_gnr_attribute27                in  varchar2
  ,p_gnr_attribute28                in  varchar2
  ,p_gnr_attribute29                in  varchar2
  ,p_gnr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_GENDER_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_GENDER_RATE_a
  (
   p_gndr_rt_id                     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_gndr_cd                        in  varchar2
  ,p_excld_flag                     in  varchar2
  ,p_gnr_attribute_category         in  varchar2
  ,p_gnr_attribute1                 in  varchar2
  ,p_gnr_attribute2                 in  varchar2
  ,p_gnr_attribute3                 in  varchar2
  ,p_gnr_attribute4                 in  varchar2
  ,p_gnr_attribute5                 in  varchar2
  ,p_gnr_attribute6                 in  varchar2
  ,p_gnr_attribute7                 in  varchar2
  ,p_gnr_attribute8                 in  varchar2
  ,p_gnr_attribute9                 in  varchar2
  ,p_gnr_attribute10                in  varchar2
  ,p_gnr_attribute11                in  varchar2
  ,p_gnr_attribute12                in  varchar2
  ,p_gnr_attribute13                in  varchar2
  ,p_gnr_attribute14                in  varchar2
  ,p_gnr_attribute15                in  varchar2
  ,p_gnr_attribute16                in  varchar2
  ,p_gnr_attribute17                in  varchar2
  ,p_gnr_attribute18                in  varchar2
  ,p_gnr_attribute19                in  varchar2
  ,p_gnr_attribute20                in  varchar2
  ,p_gnr_attribute21                in  varchar2
  ,p_gnr_attribute22                in  varchar2
  ,p_gnr_attribute23                in  varchar2
  ,p_gnr_attribute24                in  varchar2
  ,p_gnr_attribute25                in  varchar2
  ,p_gnr_attribute26                in  varchar2
  ,p_gnr_attribute27                in  varchar2
  ,p_gnr_attribute28                in  varchar2
  ,p_gnr_attribute29                in  varchar2
  ,p_gnr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_GENDER_RATE_bk2;

 

/
