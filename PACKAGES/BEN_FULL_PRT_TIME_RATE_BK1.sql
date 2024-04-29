--------------------------------------------------------
--  DDL for Package BEN_FULL_PRT_TIME_RATE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_FULL_PRT_TIME_RATE_BK1" AUTHID CURRENT_USER as
/* $Header: beftrapi.pkh 120.0 2005/05/28 03:05:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_FULL_PRT_TIME_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_FULL_PRT_TIME_RATE_b
  (
   p_business_group_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_fl_tm_pt_tm_cd                 in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ftr_attribute_category         in  varchar2
  ,p_ftr_attribute1                 in  varchar2
  ,p_ftr_attribute2                 in  varchar2
  ,p_ftr_attribute3                 in  varchar2
  ,p_ftr_attribute4                 in  varchar2
  ,p_ftr_attribute5                 in  varchar2
  ,p_ftr_attribute6                 in  varchar2
  ,p_ftr_attribute7                 in  varchar2
  ,p_ftr_attribute8                 in  varchar2
  ,p_ftr_attribute9                 in  varchar2
  ,p_ftr_attribute10                in  varchar2
  ,p_ftr_attribute11                in  varchar2
  ,p_ftr_attribute12                in  varchar2
  ,p_ftr_attribute13                in  varchar2
  ,p_ftr_attribute14                in  varchar2
  ,p_ftr_attribute15                in  varchar2
  ,p_ftr_attribute16                in  varchar2
  ,p_ftr_attribute17                in  varchar2
  ,p_ftr_attribute18                in  varchar2
  ,p_ftr_attribute19                in  varchar2
  ,p_ftr_attribute20                in  varchar2
  ,p_ftr_attribute21                in  varchar2
  ,p_ftr_attribute22                in  varchar2
  ,p_ftr_attribute23                in  varchar2
  ,p_ftr_attribute24                in  varchar2
  ,p_ftr_attribute25                in  varchar2
  ,p_ftr_attribute26                in  varchar2
  ,p_ftr_attribute27                in  varchar2
  ,p_ftr_attribute28                in  varchar2
  ,p_ftr_attribute29                in  varchar2
  ,p_ftr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_FULL_PRT_TIME_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_FULL_PRT_TIME_RATE_a
  (
   p_fl_tm_pt_tm_rt_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_fl_tm_pt_tm_cd                 in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ftr_attribute_category         in  varchar2
  ,p_ftr_attribute1                 in  varchar2
  ,p_ftr_attribute2                 in  varchar2
  ,p_ftr_attribute3                 in  varchar2
  ,p_ftr_attribute4                 in  varchar2
  ,p_ftr_attribute5                 in  varchar2
  ,p_ftr_attribute6                 in  varchar2
  ,p_ftr_attribute7                 in  varchar2
  ,p_ftr_attribute8                 in  varchar2
  ,p_ftr_attribute9                 in  varchar2
  ,p_ftr_attribute10                in  varchar2
  ,p_ftr_attribute11                in  varchar2
  ,p_ftr_attribute12                in  varchar2
  ,p_ftr_attribute13                in  varchar2
  ,p_ftr_attribute14                in  varchar2
  ,p_ftr_attribute15                in  varchar2
  ,p_ftr_attribute16                in  varchar2
  ,p_ftr_attribute17                in  varchar2
  ,p_ftr_attribute18                in  varchar2
  ,p_ftr_attribute19                in  varchar2
  ,p_ftr_attribute20                in  varchar2
  ,p_ftr_attribute21                in  varchar2
  ,p_ftr_attribute22                in  varchar2
  ,p_ftr_attribute23                in  varchar2
  ,p_ftr_attribute24                in  varchar2
  ,p_ftr_attribute25                in  varchar2
  ,p_ftr_attribute26                in  varchar2
  ,p_ftr_attribute27                in  varchar2
  ,p_ftr_attribute28                in  varchar2
  ,p_ftr_attribute29                in  varchar2
  ,p_ftr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_FULL_PRT_TIME_RATE_bk1;

 

/
