--------------------------------------------------------
--  DDL for Package BEN_COMP_LEVEL_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_LEVEL_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: beclrapi.pkh 120.0 2005/05/28 01:05:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_COMP_LEVEL_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_COMP_LEVEL_RATE_b
  (
   p_comp_lvl_rt_id                 in  number
  ,p_business_group_id              in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_clr_attribute_category         in  varchar2
  ,p_clr_attribute1                 in  varchar2
  ,p_clr_attribute2                 in  varchar2
  ,p_clr_attribute3                 in  varchar2
  ,p_clr_attribute4                 in  varchar2
  ,p_clr_attribute5                 in  varchar2
  ,p_clr_attribute6                 in  varchar2
  ,p_clr_attribute7                 in  varchar2
  ,p_clr_attribute8                 in  varchar2
  ,p_clr_attribute9                 in  varchar2
  ,p_clr_attribute10                in  varchar2
  ,p_clr_attribute11                in  varchar2
  ,p_clr_attribute12                in  varchar2
  ,p_clr_attribute13                in  varchar2
  ,p_clr_attribute14                in  varchar2
  ,p_clr_attribute15                in  varchar2
  ,p_clr_attribute16                in  varchar2
  ,p_clr_attribute17                in  varchar2
  ,p_clr_attribute18                in  varchar2
  ,p_clr_attribute19                in  varchar2
  ,p_clr_attribute20                in  varchar2
  ,p_clr_attribute21                in  varchar2
  ,p_clr_attribute22                in  varchar2
  ,p_clr_attribute23                in  varchar2
  ,p_clr_attribute24                in  varchar2
  ,p_clr_attribute25                in  varchar2
  ,p_clr_attribute26                in  varchar2
  ,p_clr_attribute27                in  varchar2
  ,p_clr_attribute28                in  varchar2
  ,p_clr_attribute29                in  varchar2
  ,p_clr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_COMP_LEVEL_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_COMP_LEVEL_RATE_a
  (
   p_comp_lvl_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_clr_attribute_category         in  varchar2
  ,p_clr_attribute1                 in  varchar2
  ,p_clr_attribute2                 in  varchar2
  ,p_clr_attribute3                 in  varchar2
  ,p_clr_attribute4                 in  varchar2
  ,p_clr_attribute5                 in  varchar2
  ,p_clr_attribute6                 in  varchar2
  ,p_clr_attribute7                 in  varchar2
  ,p_clr_attribute8                 in  varchar2
  ,p_clr_attribute9                 in  varchar2
  ,p_clr_attribute10                in  varchar2
  ,p_clr_attribute11                in  varchar2
  ,p_clr_attribute12                in  varchar2
  ,p_clr_attribute13                in  varchar2
  ,p_clr_attribute14                in  varchar2
  ,p_clr_attribute15                in  varchar2
  ,p_clr_attribute16                in  varchar2
  ,p_clr_attribute17                in  varchar2
  ,p_clr_attribute18                in  varchar2
  ,p_clr_attribute19                in  varchar2
  ,p_clr_attribute20                in  varchar2
  ,p_clr_attribute21                in  varchar2
  ,p_clr_attribute22                in  varchar2
  ,p_clr_attribute23                in  varchar2
  ,p_clr_attribute24                in  varchar2
  ,p_clr_attribute25                in  varchar2
  ,p_clr_attribute26                in  varchar2
  ,p_clr_attribute27                in  varchar2
  ,p_clr_attribute28                in  varchar2
  ,p_clr_attribute29                in  varchar2
  ,p_clr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_COMP_LEVEL_RATE_bk2;

 

/