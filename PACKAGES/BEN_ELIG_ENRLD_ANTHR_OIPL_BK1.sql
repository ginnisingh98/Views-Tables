--------------------------------------------------------
--  DDL for Package BEN_ELIG_ENRLD_ANTHR_OIPL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_ENRLD_ANTHR_OIPL_BK1" AUTHID CURRENT_USER as
/* $Header: beeeiapi.pkh 120.0 2005/05/28 02:04:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_ENRLD_ANTHR_OIPL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_ENRLD_ANTHR_OIPL_b
  (
   p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_business_group_id              in  number
  ,p_oipl_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_eei_attribute_category         in  varchar2
  ,p_eei_attribute1                 in  varchar2
  ,p_eei_attribute2                 in  varchar2
  ,p_eei_attribute3                 in  varchar2
  ,p_eei_attribute4                 in  varchar2
  ,p_eei_attribute5                 in  varchar2
  ,p_eei_attribute6                 in  varchar2
  ,p_eei_attribute7                 in  varchar2
  ,p_eei_attribute8                 in  varchar2
  ,p_eei_attribute9                 in  varchar2
  ,p_eei_attribute10                in  varchar2
  ,p_eei_attribute11                in  varchar2
  ,p_eei_attribute12                in  varchar2
  ,p_eei_attribute13                in  varchar2
  ,p_eei_attribute14                in  varchar2
  ,p_eei_attribute15                in  varchar2
  ,p_eei_attribute16                in  varchar2
  ,p_eei_attribute17                in  varchar2
  ,p_eei_attribute18                in  varchar2
  ,p_eei_attribute19                in  varchar2
  ,p_eei_attribute20                in  varchar2
  ,p_eei_attribute21                in  varchar2
  ,p_eei_attribute22                in  varchar2
  ,p_eei_attribute23                in  varchar2
  ,p_eei_attribute24                in  varchar2
  ,p_eei_attribute25                in  varchar2
  ,p_eei_attribute26                in  varchar2
  ,p_eei_attribute27                in  varchar2
  ,p_eei_attribute28                in  varchar2
  ,p_eei_attribute29                in  varchar2
  ,p_eei_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_ENRLD_ANTHR_OIPL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_ENRLD_ANTHR_OIPL_a
  (
   p_elig_enrld_anthr_oipl_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_business_group_id              in  number
  ,p_oipl_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_eei_attribute_category         in  varchar2
  ,p_eei_attribute1                 in  varchar2
  ,p_eei_attribute2                 in  varchar2
  ,p_eei_attribute3                 in  varchar2
  ,p_eei_attribute4                 in  varchar2
  ,p_eei_attribute5                 in  varchar2
  ,p_eei_attribute6                 in  varchar2
  ,p_eei_attribute7                 in  varchar2
  ,p_eei_attribute8                 in  varchar2
  ,p_eei_attribute9                 in  varchar2
  ,p_eei_attribute10                in  varchar2
  ,p_eei_attribute11                in  varchar2
  ,p_eei_attribute12                in  varchar2
  ,p_eei_attribute13                in  varchar2
  ,p_eei_attribute14                in  varchar2
  ,p_eei_attribute15                in  varchar2
  ,p_eei_attribute16                in  varchar2
  ,p_eei_attribute17                in  varchar2
  ,p_eei_attribute18                in  varchar2
  ,p_eei_attribute19                in  varchar2
  ,p_eei_attribute20                in  varchar2
  ,p_eei_attribute21                in  varchar2
  ,p_eei_attribute22                in  varchar2
  ,p_eei_attribute23                in  varchar2
  ,p_eei_attribute24                in  varchar2
  ,p_eei_attribute25                in  varchar2
  ,p_eei_attribute26                in  varchar2
  ,p_eei_attribute27                in  varchar2
  ,p_eei_attribute28                in  varchar2
  ,p_eei_attribute29                in  varchar2
  ,p_eei_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELIG_ENRLD_ANTHR_OIPL_bk1;

 

/
