--------------------------------------------------------
--  DDL for Package BEN_ELIG_DPNT_CVRD_PLIP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DPNT_CVRD_PLIP_BK2" AUTHID CURRENT_USER as
/* $Header: beediapi.pkh 120.0 2005/05/28 01:59:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_DPNT_CVRD_PLIP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_DPNT_CVRD_PLIP_b
  (
   p_elig_dpnt_cvrd_plip_id         in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_plip_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_edi_attribute_category         in  varchar2
  ,p_edi_attribute1                 in  varchar2
  ,p_edi_attribute2                 in  varchar2
  ,p_edi_attribute3                 in  varchar2
  ,p_edi_attribute4                 in  varchar2
  ,p_edi_attribute5                 in  varchar2
  ,p_edi_attribute6                 in  varchar2
  ,p_edi_attribute7                 in  varchar2
  ,p_edi_attribute8                 in  varchar2
  ,p_edi_attribute9                 in  varchar2
  ,p_edi_attribute10                in  varchar2
  ,p_edi_attribute11                in  varchar2
  ,p_edi_attribute12                in  varchar2
  ,p_edi_attribute13                in  varchar2
  ,p_edi_attribute14                in  varchar2
  ,p_edi_attribute15                in  varchar2
  ,p_edi_attribute16                in  varchar2
  ,p_edi_attribute17                in  varchar2
  ,p_edi_attribute18                in  varchar2
  ,p_edi_attribute19                in  varchar2
  ,p_edi_attribute20                in  varchar2
  ,p_edi_attribute21                in  varchar2
  ,p_edi_attribute22                in  varchar2
  ,p_edi_attribute23                in  varchar2
  ,p_edi_attribute24                in  varchar2
  ,p_edi_attribute25                in  varchar2
  ,p_edi_attribute26                in  varchar2
  ,p_edi_attribute27                in  varchar2
  ,p_edi_attribute28                in  varchar2
  ,p_edi_attribute29                in  varchar2
  ,p_edi_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_DPNT_CVRD_PLIP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_DPNT_CVRD_PLIP_a
  (
   p_elig_dpnt_cvrd_plip_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_plip_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_edi_attribute_category         in  varchar2
  ,p_edi_attribute1                 in  varchar2
  ,p_edi_attribute2                 in  varchar2
  ,p_edi_attribute3                 in  varchar2
  ,p_edi_attribute4                 in  varchar2
  ,p_edi_attribute5                 in  varchar2
  ,p_edi_attribute6                 in  varchar2
  ,p_edi_attribute7                 in  varchar2
  ,p_edi_attribute8                 in  varchar2
  ,p_edi_attribute9                 in  varchar2
  ,p_edi_attribute10                in  varchar2
  ,p_edi_attribute11                in  varchar2
  ,p_edi_attribute12                in  varchar2
  ,p_edi_attribute13                in  varchar2
  ,p_edi_attribute14                in  varchar2
  ,p_edi_attribute15                in  varchar2
  ,p_edi_attribute16                in  varchar2
  ,p_edi_attribute17                in  varchar2
  ,p_edi_attribute18                in  varchar2
  ,p_edi_attribute19                in  varchar2
  ,p_edi_attribute20                in  varchar2
  ,p_edi_attribute21                in  varchar2
  ,p_edi_attribute22                in  varchar2
  ,p_edi_attribute23                in  varchar2
  ,p_edi_attribute24                in  varchar2
  ,p_edi_attribute25                in  varchar2
  ,p_edi_attribute26                in  varchar2
  ,p_edi_attribute27                in  varchar2
  ,p_edi_attribute28                in  varchar2
  ,p_edi_attribute29                in  varchar2
  ,p_edi_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_DPNT_CVRD_PLIP_bk2;

 

/