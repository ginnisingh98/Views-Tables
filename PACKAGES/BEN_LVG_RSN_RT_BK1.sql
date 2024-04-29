--------------------------------------------------------
--  DDL for Package BEN_LVG_RSN_RT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LVG_RSN_RT_BK1" AUTHID CURRENT_USER as
/* $Header: belrnapi.pkh 120.0 2005/05/28 03:35:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_lvg_rsn_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_lvg_rsn_rt_b
  (
   p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_lvg_rsn_cd                     in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_lrn_attribute_category         in  varchar2
  ,p_lrn_attribute1                 in  varchar2
  ,p_lrn_attribute2                 in  varchar2
  ,p_lrn_attribute3                 in  varchar2
  ,p_lrn_attribute4                 in  varchar2
  ,p_lrn_attribute5                 in  varchar2
  ,p_lrn_attribute6                 in  varchar2
  ,p_lrn_attribute7                 in  varchar2
  ,p_lrn_attribute8                 in  varchar2
  ,p_lrn_attribute9                 in  varchar2
  ,p_lrn_attribute10                in  varchar2
  ,p_lrn_attribute11                in  varchar2
  ,p_lrn_attribute12                in  varchar2
  ,p_lrn_attribute13                in  varchar2
  ,p_lrn_attribute14                in  varchar2
  ,p_lrn_attribute15                in  varchar2
  ,p_lrn_attribute16                in  varchar2
  ,p_lrn_attribute17                in  varchar2
  ,p_lrn_attribute18                in  varchar2
  ,p_lrn_attribute19                in  varchar2
  ,p_lrn_attribute20                in  varchar2
  ,p_lrn_attribute21                in  varchar2
  ,p_lrn_attribute22                in  varchar2
  ,p_lrn_attribute23                in  varchar2
  ,p_lrn_attribute24                in  varchar2
  ,p_lrn_attribute25                in  varchar2
  ,p_lrn_attribute26                in  varchar2
  ,p_lrn_attribute27                in  varchar2
  ,p_lrn_attribute28                in  varchar2
  ,p_lrn_attribute29                in  varchar2
  ,p_lrn_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_lvg_rsn_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_lvg_rsn_rt_a
  (
   p_lvg_rsn_rt_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_lvg_rsn_cd                     in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_lrn_attribute_category         in  varchar2
  ,p_lrn_attribute1                 in  varchar2
  ,p_lrn_attribute2                 in  varchar2
  ,p_lrn_attribute3                 in  varchar2
  ,p_lrn_attribute4                 in  varchar2
  ,p_lrn_attribute5                 in  varchar2
  ,p_lrn_attribute6                 in  varchar2
  ,p_lrn_attribute7                 in  varchar2
  ,p_lrn_attribute8                 in  varchar2
  ,p_lrn_attribute9                 in  varchar2
  ,p_lrn_attribute10                in  varchar2
  ,p_lrn_attribute11                in  varchar2
  ,p_lrn_attribute12                in  varchar2
  ,p_lrn_attribute13                in  varchar2
  ,p_lrn_attribute14                in  varchar2
  ,p_lrn_attribute15                in  varchar2
  ,p_lrn_attribute16                in  varchar2
  ,p_lrn_attribute17                in  varchar2
  ,p_lrn_attribute18                in  varchar2
  ,p_lrn_attribute19                in  varchar2
  ,p_lrn_attribute20                in  varchar2
  ,p_lrn_attribute21                in  varchar2
  ,p_lrn_attribute22                in  varchar2
  ,p_lrn_attribute23                in  varchar2
  ,p_lrn_attribute24                in  varchar2
  ,p_lrn_attribute25                in  varchar2
  ,p_lrn_attribute26                in  varchar2
  ,p_lrn_attribute27                in  varchar2
  ,p_lrn_attribute28                in  varchar2
  ,p_lrn_attribute29                in  varchar2
  ,p_lrn_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_lvg_rsn_rt_bk1;

 

/
