--------------------------------------------------------
--  DDL for Package BEN_ENRLD_ANTHR_PLIP_RT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRLD_ANTHR_PLIP_RT_BK1" AUTHID CURRENT_USER as
/* $Header: beearapi.pkh 120.0 2005/05/28 01:45:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ENRLD_ANTHR_PLIP_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ENRLD_ANTHR_PLIP_RT_b
  (
   p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_ordr_num                       in  number
  ,p_plip_id                        in  number
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_ear_attribute_category         in  varchar2
  ,p_ear_attribute1                 in  varchar2
  ,p_ear_attribute2                 in  varchar2
  ,p_ear_attribute3                 in  varchar2
  ,p_ear_attribute4                 in  varchar2
  ,p_ear_attribute5                 in  varchar2
  ,p_ear_attribute6                 in  varchar2
  ,p_ear_attribute7                 in  varchar2
  ,p_ear_attribute8                 in  varchar2
  ,p_ear_attribute9                 in  varchar2
  ,p_ear_attribute10                in  varchar2
  ,p_ear_attribute11                in  varchar2
  ,p_ear_attribute12                in  varchar2
  ,p_ear_attribute13                in  varchar2
  ,p_ear_attribute14                in  varchar2
  ,p_ear_attribute15                in  varchar2
  ,p_ear_attribute16                in  varchar2
  ,p_ear_attribute17                in  varchar2
  ,p_ear_attribute18                in  varchar2
  ,p_ear_attribute19                in  varchar2
  ,p_ear_attribute20                in  varchar2
  ,p_ear_attribute21                in  varchar2
  ,p_ear_attribute22                in  varchar2
  ,p_ear_attribute23                in  varchar2
  ,p_ear_attribute24                in  varchar2
  ,p_ear_attribute25                in  varchar2
  ,p_ear_attribute26                in  varchar2
  ,p_ear_attribute27                in  varchar2
  ,p_ear_attribute28                in  varchar2
  ,p_ear_attribute29                in  varchar2
  ,p_ear_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ENRLD_ANTHR_PLIP_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ENRLD_ANTHR_PLIP_RT_a
  (
   p_enrld_anthr_plip_rt_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_ordr_num                       in  number
  ,p_plip_id                        in  number
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_ear_attribute_category         in  varchar2
  ,p_ear_attribute1                 in  varchar2
  ,p_ear_attribute2                 in  varchar2
  ,p_ear_attribute3                 in  varchar2
  ,p_ear_attribute4                 in  varchar2
  ,p_ear_attribute5                 in  varchar2
  ,p_ear_attribute6                 in  varchar2
  ,p_ear_attribute7                 in  varchar2
  ,p_ear_attribute8                 in  varchar2
  ,p_ear_attribute9                 in  varchar2
  ,p_ear_attribute10                in  varchar2
  ,p_ear_attribute11                in  varchar2
  ,p_ear_attribute12                in  varchar2
  ,p_ear_attribute13                in  varchar2
  ,p_ear_attribute14                in  varchar2
  ,p_ear_attribute15                in  varchar2
  ,p_ear_attribute16                in  varchar2
  ,p_ear_attribute17                in  varchar2
  ,p_ear_attribute18                in  varchar2
  ,p_ear_attribute19                in  varchar2
  ,p_ear_attribute20                in  varchar2
  ,p_ear_attribute21                in  varchar2
  ,p_ear_attribute22                in  varchar2
  ,p_ear_attribute23                in  varchar2
  ,p_ear_attribute24                in  varchar2
  ,p_ear_attribute25                in  varchar2
  ,p_ear_attribute26                in  varchar2
  ,p_ear_attribute27                in  varchar2
  ,p_ear_attribute28                in  varchar2
  ,p_ear_attribute29                in  varchar2
  ,p_ear_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ENRLD_ANTHR_PLIP_RT_bk1;

 

/
