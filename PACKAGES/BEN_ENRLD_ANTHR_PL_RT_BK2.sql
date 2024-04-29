--------------------------------------------------------
--  DDL for Package BEN_ENRLD_ANTHR_PL_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRLD_ANTHR_PL_RT_BK2" AUTHID CURRENT_USER as
/* $Header: beenlapi.pkh 120.0 2005/05/28 02:28:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ENRLD_ANTHR_PL_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ENRLD_ANTHR_PL_RT_b
  (
   p_enrld_anthr_pl_rt_id         in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_pl_id                          in  number
  ,p_enl_attribute_category         in  varchar2
  ,p_enl_attribute1                 in  varchar2
  ,p_enl_attribute2                 in  varchar2
  ,p_enl_attribute3                 in  varchar2
  ,p_enl_attribute4                 in  varchar2
  ,p_enl_attribute5                 in  varchar2
  ,p_enl_attribute6                 in  varchar2
  ,p_enl_attribute7                 in  varchar2
  ,p_enl_attribute8                 in  varchar2
  ,p_enl_attribute9                 in  varchar2
  ,p_enl_attribute10                in  varchar2
  ,p_enl_attribute11                in  varchar2
  ,p_enl_attribute12                in  varchar2
  ,p_enl_attribute13                in  varchar2
  ,p_enl_attribute14                in  varchar2
  ,p_enl_attribute15                in  varchar2
  ,p_enl_attribute16                in  varchar2
  ,p_enl_attribute17                in  varchar2
  ,p_enl_attribute18                in  varchar2
  ,p_enl_attribute19                in  varchar2
  ,p_enl_attribute20                in  varchar2
  ,p_enl_attribute21                in  varchar2
  ,p_enl_attribute22                in  varchar2
  ,p_enl_attribute23                in  varchar2
  ,p_enl_attribute24                in  varchar2
  ,p_enl_attribute25                in  varchar2
  ,p_enl_attribute26                in  varchar2
  ,p_enl_attribute27                in  varchar2
  ,p_enl_attribute28                in  varchar2
  ,p_enl_attribute29                in  varchar2
  ,p_enl_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ENRLD_ANTHR_PL_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ENRLD_ANTHR_PL_RT_a
  (
   p_enrld_anthr_pl_rt_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_pl_id                          in  number
  ,p_enl_attribute_category         in  varchar2
  ,p_enl_attribute1                 in  varchar2
  ,p_enl_attribute2                 in  varchar2
  ,p_enl_attribute3                 in  varchar2
  ,p_enl_attribute4                 in  varchar2
  ,p_enl_attribute5                 in  varchar2
  ,p_enl_attribute6                 in  varchar2
  ,p_enl_attribute7                 in  varchar2
  ,p_enl_attribute8                 in  varchar2
  ,p_enl_attribute9                 in  varchar2
  ,p_enl_attribute10                in  varchar2
  ,p_enl_attribute11                in  varchar2
  ,p_enl_attribute12                in  varchar2
  ,p_enl_attribute13                in  varchar2
  ,p_enl_attribute14                in  varchar2
  ,p_enl_attribute15                in  varchar2
  ,p_enl_attribute16                in  varchar2
  ,p_enl_attribute17                in  varchar2
  ,p_enl_attribute18                in  varchar2
  ,p_enl_attribute19                in  varchar2
  ,p_enl_attribute20                in  varchar2
  ,p_enl_attribute21                in  varchar2
  ,p_enl_attribute22                in  varchar2
  ,p_enl_attribute23                in  varchar2
  ,p_enl_attribute24                in  varchar2
  ,p_enl_attribute25                in  varchar2
  ,p_enl_attribute26                in  varchar2
  ,p_enl_attribute27                in  varchar2
  ,p_enl_attribute28                in  varchar2
  ,p_enl_attribute29                in  varchar2
  ,p_enl_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ENRLD_ANTHR_PL_RT_bk2;

 

/
