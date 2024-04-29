--------------------------------------------------------
--  DDL for Package BEN_OTHR_PTIP_RT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OTHR_PTIP_RT_BK1" AUTHID CURRENT_USER as
/* $Header: beoprapi.pkh 120.0 2005/05/28 09:55:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_OTHR_PTIP_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_OTHR_PTIP_RT_b
  (
   p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_only_pls_subj_cobra_flag       in  varchar2
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_ptip_id                        in  number
  ,p_business_group_id              in  number
  ,p_opr_attribute_category         in  varchar2
  ,p_opr_attribute1                 in  varchar2
  ,p_opr_attribute2                 in  varchar2
  ,p_opr_attribute3                 in  varchar2
  ,p_opr_attribute4                 in  varchar2
  ,p_opr_attribute5                 in  varchar2
  ,p_opr_attribute6                 in  varchar2
  ,p_opr_attribute7                 in  varchar2
  ,p_opr_attribute8                 in  varchar2
  ,p_opr_attribute9                 in  varchar2
  ,p_opr_attribute10                in  varchar2
  ,p_opr_attribute11                in  varchar2
  ,p_opr_attribute12                in  varchar2
  ,p_opr_attribute13                in  varchar2
  ,p_opr_attribute14                in  varchar2
  ,p_opr_attribute15                in  varchar2
  ,p_opr_attribute16                in  varchar2
  ,p_opr_attribute17                in  varchar2
  ,p_opr_attribute18                in  varchar2
  ,p_opr_attribute19                in  varchar2
  ,p_opr_attribute20                in  varchar2
  ,p_opr_attribute21                in  varchar2
  ,p_opr_attribute22                in  varchar2
  ,p_opr_attribute23                in  varchar2
  ,p_opr_attribute24                in  varchar2
  ,p_opr_attribute25                in  varchar2
  ,p_opr_attribute26                in  varchar2
  ,p_opr_attribute27                in  varchar2
  ,p_opr_attribute28                in  varchar2
  ,p_opr_attribute29                in  varchar2
  ,p_opr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_OTHR_PTIP_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_OTHR_PTIP_RT_a
  (
   p_othr_ptip_rt_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_only_pls_subj_cobra_flag       in  varchar2
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_ptip_id                        in  number
  ,p_business_group_id              in  number
  ,p_opr_attribute_category         in  varchar2
  ,p_opr_attribute1                 in  varchar2
  ,p_opr_attribute2                 in  varchar2
  ,p_opr_attribute3                 in  varchar2
  ,p_opr_attribute4                 in  varchar2
  ,p_opr_attribute5                 in  varchar2
  ,p_opr_attribute6                 in  varchar2
  ,p_opr_attribute7                 in  varchar2
  ,p_opr_attribute8                 in  varchar2
  ,p_opr_attribute9                 in  varchar2
  ,p_opr_attribute10                in  varchar2
  ,p_opr_attribute11                in  varchar2
  ,p_opr_attribute12                in  varchar2
  ,p_opr_attribute13                in  varchar2
  ,p_opr_attribute14                in  varchar2
  ,p_opr_attribute15                in  varchar2
  ,p_opr_attribute16                in  varchar2
  ,p_opr_attribute17                in  varchar2
  ,p_opr_attribute18                in  varchar2
  ,p_opr_attribute19                in  varchar2
  ,p_opr_attribute20                in  varchar2
  ,p_opr_attribute21                in  varchar2
  ,p_opr_attribute22                in  varchar2
  ,p_opr_attribute23                in  varchar2
  ,p_opr_attribute24                in  varchar2
  ,p_opr_attribute25                in  varchar2
  ,p_opr_attribute26                in  varchar2
  ,p_opr_attribute27                in  varchar2
  ,p_opr_attribute28                in  varchar2
  ,p_opr_attribute29                in  varchar2
  ,p_opr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_OTHR_PTIP_RT_bk1;

 

/
