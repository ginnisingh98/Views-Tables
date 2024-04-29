--------------------------------------------------------
--  DDL for Package BEN_NO_OTHR_CVG_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_NO_OTHR_CVG_RT_BK2" AUTHID CURRENT_USER as
/* $Header: benocapi.pkh 120.0 2005/05/28 09:10:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_NO_OTHR_CVG_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_NO_OTHR_CVG_RT_b
  (
   p_no_othr_cvg_rt_id       in  number
  ,p_coord_ben_no_cvg_flag          in  varchar2
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_noc_attribute_category         in  varchar2
  ,p_noc_attribute1                 in  varchar2
  ,p_noc_attribute2                 in  varchar2
  ,p_noc_attribute3                 in  varchar2
  ,p_noc_attribute4                 in  varchar2
  ,p_noc_attribute5                 in  varchar2
  ,p_noc_attribute6                 in  varchar2
  ,p_noc_attribute7                 in  varchar2
  ,p_noc_attribute8                 in  varchar2
  ,p_noc_attribute9                 in  varchar2
  ,p_noc_attribute10                in  varchar2
  ,p_noc_attribute11                in  varchar2
  ,p_noc_attribute12                in  varchar2
  ,p_noc_attribute13                in  varchar2
  ,p_noc_attribute14                in  varchar2
  ,p_noc_attribute15                in  varchar2
  ,p_noc_attribute16                in  varchar2
  ,p_noc_attribute17                in  varchar2
  ,p_noc_attribute18                in  varchar2
  ,p_noc_attribute19                in  varchar2
  ,p_noc_attribute20                in  varchar2
  ,p_noc_attribute21                in  varchar2
  ,p_noc_attribute22                in  varchar2
  ,p_noc_attribute23                in  varchar2
  ,p_noc_attribute24                in  varchar2
  ,p_noc_attribute25                in  varchar2
  ,p_noc_attribute26                in  varchar2
  ,p_noc_attribute27                in  varchar2
  ,p_noc_attribute28                in  varchar2
  ,p_noc_attribute29                in  varchar2
  ,p_noc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_NO_OTHR_CVG_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_NO_OTHR_CVG_RT_a
  (
   p_no_othr_cvg_rt_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_coord_ben_no_cvg_flag          in  varchar2
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_noc_attribute_category         in  varchar2
  ,p_noc_attribute1                 in  varchar2
  ,p_noc_attribute2                 in  varchar2
  ,p_noc_attribute3                 in  varchar2
  ,p_noc_attribute4                 in  varchar2
  ,p_noc_attribute5                 in  varchar2
  ,p_noc_attribute6                 in  varchar2
  ,p_noc_attribute7                 in  varchar2
  ,p_noc_attribute8                 in  varchar2
  ,p_noc_attribute9                 in  varchar2
  ,p_noc_attribute10                in  varchar2
  ,p_noc_attribute11                in  varchar2
  ,p_noc_attribute12                in  varchar2
  ,p_noc_attribute13                in  varchar2
  ,p_noc_attribute14                in  varchar2
  ,p_noc_attribute15                in  varchar2
  ,p_noc_attribute16                in  varchar2
  ,p_noc_attribute17                in  varchar2
  ,p_noc_attribute18                in  varchar2
  ,p_noc_attribute19                in  varchar2
  ,p_noc_attribute20                in  varchar2
  ,p_noc_attribute21                in  varchar2
  ,p_noc_attribute22                in  varchar2
  ,p_noc_attribute23                in  varchar2
  ,p_noc_attribute24                in  varchar2
  ,p_noc_attribute25                in  varchar2
  ,p_noc_attribute26                in  varchar2
  ,p_noc_attribute27                in  varchar2
  ,p_noc_attribute28                in  varchar2
  ,p_noc_attribute29                in  varchar2
  ,p_noc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_NO_OTHR_CVG_RT_bk2;

 

/