--------------------------------------------------------
--  DDL for Package BEN_WORK_LOC_RATE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WORK_LOC_RATE_BK1" AUTHID CURRENT_USER as
/* $Header: bewlrapi.pkh 120.0 2005/05/28 12:17:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WORK_LOC_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORK_LOC_RATE_b
  (
   p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_location_id                    in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_wlr_attribute_category         in  varchar2
  ,p_wlr_attribute1                 in  varchar2
  ,p_wlr_attribute2                 in  varchar2
  ,p_wlr_attribute3                 in  varchar2
  ,p_wlr_attribute4                 in  varchar2
  ,p_wlr_attribute5                 in  varchar2
  ,p_wlr_attribute6                 in  varchar2
  ,p_wlr_attribute7                 in  varchar2
  ,p_wlr_attribute8                 in  varchar2
  ,p_wlr_attribute9                 in  varchar2
  ,p_wlr_attribute10                in  varchar2
  ,p_wlr_attribute11                in  varchar2
  ,p_wlr_attribute12                in  varchar2
  ,p_wlr_attribute13                in  varchar2
  ,p_wlr_attribute14                in  varchar2
  ,p_wlr_attribute15                in  varchar2
  ,p_wlr_attribute16                in  varchar2
  ,p_wlr_attribute17                in  varchar2
  ,p_wlr_attribute18                in  varchar2
  ,p_wlr_attribute19                in  varchar2
  ,p_wlr_attribute20                in  varchar2
  ,p_wlr_attribute21                in  varchar2
  ,p_wlr_attribute22                in  varchar2
  ,p_wlr_attribute23                in  varchar2
  ,p_wlr_attribute24                in  varchar2
  ,p_wlr_attribute25                in  varchar2
  ,p_wlr_attribute26                in  varchar2
  ,p_wlr_attribute27                in  varchar2
  ,p_wlr_attribute28                in  varchar2
  ,p_wlr_attribute29                in  varchar2
  ,p_wlr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WORK_LOC_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORK_LOC_RATE_a
  (
   p_wk_loc_rt_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_location_id                    in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_wlr_attribute_category         in  varchar2
  ,p_wlr_attribute1                 in  varchar2
  ,p_wlr_attribute2                 in  varchar2
  ,p_wlr_attribute3                 in  varchar2
  ,p_wlr_attribute4                 in  varchar2
  ,p_wlr_attribute5                 in  varchar2
  ,p_wlr_attribute6                 in  varchar2
  ,p_wlr_attribute7                 in  varchar2
  ,p_wlr_attribute8                 in  varchar2
  ,p_wlr_attribute9                 in  varchar2
  ,p_wlr_attribute10                in  varchar2
  ,p_wlr_attribute11                in  varchar2
  ,p_wlr_attribute12                in  varchar2
  ,p_wlr_attribute13                in  varchar2
  ,p_wlr_attribute14                in  varchar2
  ,p_wlr_attribute15                in  varchar2
  ,p_wlr_attribute16                in  varchar2
  ,p_wlr_attribute17                in  varchar2
  ,p_wlr_attribute18                in  varchar2
  ,p_wlr_attribute19                in  varchar2
  ,p_wlr_attribute20                in  varchar2
  ,p_wlr_attribute21                in  varchar2
  ,p_wlr_attribute22                in  varchar2
  ,p_wlr_attribute23                in  varchar2
  ,p_wlr_attribute24                in  varchar2
  ,p_wlr_attribute25                in  varchar2
  ,p_wlr_attribute26                in  varchar2
  ,p_wlr_attribute27                in  varchar2
  ,p_wlr_attribute28                in  varchar2
  ,p_wlr_attribute29                in  varchar2
  ,p_wlr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_WORK_LOC_RATE_bk1;

 

/
