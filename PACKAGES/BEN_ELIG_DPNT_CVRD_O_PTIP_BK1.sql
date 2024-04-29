--------------------------------------------------------
--  DDL for Package BEN_ELIG_DPNT_CVRD_O_PTIP_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DPNT_CVRD_O_PTIP_BK1" AUTHID CURRENT_USER as
/* $Header: beedtapi.pkh 120.0 2005/05/28 02:01:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_DPNT_CVRD_O_PTIP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_DPNT_CVRD_O_PTIP_b
  (
   p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_only_pls_subj_cobra_flag       in  varchar2
  ,p_ptip_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_edt_attribute_category         in  varchar2
  ,p_edt_attribute1                 in  varchar2
  ,p_edt_attribute2                 in  varchar2
  ,p_edt_attribute3                 in  varchar2
  ,p_edt_attribute4                 in  varchar2
  ,p_edt_attribute5                 in  varchar2
  ,p_edt_attribute6                 in  varchar2
  ,p_edt_attribute7                 in  varchar2
  ,p_edt_attribute8                 in  varchar2
  ,p_edt_attribute9                 in  varchar2
  ,p_edt_attribute10                in  varchar2
  ,p_edt_attribute11                in  varchar2
  ,p_edt_attribute12                in  varchar2
  ,p_edt_attribute13                in  varchar2
  ,p_edt_attribute14                in  varchar2
  ,p_edt_attribute15                in  varchar2
  ,p_edt_attribute16                in  varchar2
  ,p_edt_attribute17                in  varchar2
  ,p_edt_attribute18                in  varchar2
  ,p_edt_attribute19                in  varchar2
  ,p_edt_attribute20                in  varchar2
  ,p_edt_attribute21                in  varchar2
  ,p_edt_attribute22                in  varchar2
  ,p_edt_attribute23                in  varchar2
  ,p_edt_attribute24                in  varchar2
  ,p_edt_attribute25                in  varchar2
  ,p_edt_attribute26                in  varchar2
  ,p_edt_attribute27                in  varchar2
  ,p_edt_attribute28                in  varchar2
  ,p_edt_attribute29                in  varchar2
  ,p_edt_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_DPNT_CVRD_O_PTIP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_DPNT_CVRD_O_PTIP_a
  (
   p_elig_dpnt_cvrd_othr_ptip_id    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_only_pls_subj_cobra_flag       in  varchar2
  ,p_ptip_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_edt_attribute_category         in  varchar2
  ,p_edt_attribute1                 in  varchar2
  ,p_edt_attribute2                 in  varchar2
  ,p_edt_attribute3                 in  varchar2
  ,p_edt_attribute4                 in  varchar2
  ,p_edt_attribute5                 in  varchar2
  ,p_edt_attribute6                 in  varchar2
  ,p_edt_attribute7                 in  varchar2
  ,p_edt_attribute8                 in  varchar2
  ,p_edt_attribute9                 in  varchar2
  ,p_edt_attribute10                in  varchar2
  ,p_edt_attribute11                in  varchar2
  ,p_edt_attribute12                in  varchar2
  ,p_edt_attribute13                in  varchar2
  ,p_edt_attribute14                in  varchar2
  ,p_edt_attribute15                in  varchar2
  ,p_edt_attribute16                in  varchar2
  ,p_edt_attribute17                in  varchar2
  ,p_edt_attribute18                in  varchar2
  ,p_edt_attribute19                in  varchar2
  ,p_edt_attribute20                in  varchar2
  ,p_edt_attribute21                in  varchar2
  ,p_edt_attribute22                in  varchar2
  ,p_edt_attribute23                in  varchar2
  ,p_edt_attribute24                in  varchar2
  ,p_edt_attribute25                in  varchar2
  ,p_edt_attribute26                in  varchar2
  ,p_edt_attribute27                in  varchar2
  ,p_edt_attribute28                in  varchar2
  ,p_edt_attribute29                in  varchar2
  ,p_edt_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELIG_DPNT_CVRD_O_PTIP_bk1;

 

/
