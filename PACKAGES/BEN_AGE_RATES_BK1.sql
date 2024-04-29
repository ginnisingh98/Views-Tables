--------------------------------------------------------
--  DDL for Package BEN_AGE_RATES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_AGE_RATES_BK1" AUTHID CURRENT_USER as
/* $Header: beartapi.pkh 120.0 2005/05/28 00:28:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_age_rates_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_age_rates_b
  (
   p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_age_fctr_id                    in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_art_attribute_category         in  varchar2
  ,p_art_attribute1                 in  varchar2
  ,p_art_attribute2                 in  varchar2
  ,p_art_attribute3                 in  varchar2
  ,p_art_attribute4                 in  varchar2
  ,p_art_attribute5                 in  varchar2
  ,p_art_attribute6                 in  varchar2
  ,p_art_attribute7                 in  varchar2
  ,p_art_attribute8                 in  varchar2
  ,p_art_attribute9                 in  varchar2
  ,p_art_attribute10                in  varchar2
  ,p_art_attribute11                in  varchar2
  ,p_art_attribute12                in  varchar2
  ,p_art_attribute13                in  varchar2
  ,p_art_attribute14                in  varchar2
  ,p_art_attribute15                in  varchar2
  ,p_art_attribute16                in  varchar2
  ,p_art_attribute17                in  varchar2
  ,p_art_attribute18                in  varchar2
  ,p_art_attribute19                in  varchar2
  ,p_art_attribute20                in  varchar2
  ,p_art_attribute21                in  varchar2
  ,p_art_attribute22                in  varchar2
  ,p_art_attribute23                in  varchar2
  ,p_art_attribute24                in  varchar2
  ,p_art_attribute25                in  varchar2
  ,p_art_attribute26                in  varchar2
  ,p_art_attribute27                in  varchar2
  ,p_art_attribute28                in  varchar2
  ,p_art_attribute29                in  varchar2
  ,p_art_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_age_rates_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_age_rates_a
  (
   p_age_rt_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_age_fctr_id                    in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_art_attribute_category         in  varchar2
  ,p_art_attribute1                 in  varchar2
  ,p_art_attribute2                 in  varchar2
  ,p_art_attribute3                 in  varchar2
  ,p_art_attribute4                 in  varchar2
  ,p_art_attribute5                 in  varchar2
  ,p_art_attribute6                 in  varchar2
  ,p_art_attribute7                 in  varchar2
  ,p_art_attribute8                 in  varchar2
  ,p_art_attribute9                 in  varchar2
  ,p_art_attribute10                in  varchar2
  ,p_art_attribute11                in  varchar2
  ,p_art_attribute12                in  varchar2
  ,p_art_attribute13                in  varchar2
  ,p_art_attribute14                in  varchar2
  ,p_art_attribute15                in  varchar2
  ,p_art_attribute16                in  varchar2
  ,p_art_attribute17                in  varchar2
  ,p_art_attribute18                in  varchar2
  ,p_art_attribute19                in  varchar2
  ,p_art_attribute20                in  varchar2
  ,p_art_attribute21                in  varchar2
  ,p_art_attribute22                in  varchar2
  ,p_art_attribute23                in  varchar2
  ,p_art_attribute24                in  varchar2
  ,p_art_attribute25                in  varchar2
  ,p_art_attribute26                in  varchar2
  ,p_art_attribute27                in  varchar2
  ,p_art_attribute28                in  varchar2
  ,p_art_attribute29                in  varchar2
  ,p_art_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_age_rates_bk1;

 

/
