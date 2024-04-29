--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVRD_PLIP_RT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVRD_PLIP_RT_BK1" AUTHID CURRENT_USER as
/* $Header: bedcpapi.pkh 120.0 2005/05/28 01:33:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_DPNT_CVRD_PLIP_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_DPNT_CVRD_PLIP_RT_b
  (
   p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_plip_id                        in  number
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_dcp_attribute_category         in  varchar2
  ,p_dcp_attribute1                 in  varchar2
  ,p_dcp_attribute2                 in  varchar2
  ,p_dcp_attribute3                 in  varchar2
  ,p_dcp_attribute4                 in  varchar2
  ,p_dcp_attribute5                 in  varchar2
  ,p_dcp_attribute6                 in  varchar2
  ,p_dcp_attribute7                 in  varchar2
  ,p_dcp_attribute8                 in  varchar2
  ,p_dcp_attribute9                 in  varchar2
  ,p_dcp_attribute10                in  varchar2
  ,p_dcp_attribute11                in  varchar2
  ,p_dcp_attribute12                in  varchar2
  ,p_dcp_attribute13                in  varchar2
  ,p_dcp_attribute14                in  varchar2
  ,p_dcp_attribute15                in  varchar2
  ,p_dcp_attribute16                in  varchar2
  ,p_dcp_attribute17                in  varchar2
  ,p_dcp_attribute18                in  varchar2
  ,p_dcp_attribute19                in  varchar2
  ,p_dcp_attribute20                in  varchar2
  ,p_dcp_attribute21                in  varchar2
  ,p_dcp_attribute22                in  varchar2
  ,p_dcp_attribute23                in  varchar2
  ,p_dcp_attribute24                in  varchar2
  ,p_dcp_attribute25                in  varchar2
  ,p_dcp_attribute26                in  varchar2
  ,p_dcp_attribute27                in  varchar2
  ,p_dcp_attribute28                in  varchar2
  ,p_dcp_attribute29                in  varchar2
  ,p_dcp_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_DPNT_CVRD_PLIP_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_DPNT_CVRD_PLIP_RT_a
  (
   p_dpnt_cvrd_plip_rt_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_plip_id                        in  number
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_dcp_attribute_category         in  varchar2
  ,p_dcp_attribute1                 in  varchar2
  ,p_dcp_attribute2                 in  varchar2
  ,p_dcp_attribute3                 in  varchar2
  ,p_dcp_attribute4                 in  varchar2
  ,p_dcp_attribute5                 in  varchar2
  ,p_dcp_attribute6                 in  varchar2
  ,p_dcp_attribute7                 in  varchar2
  ,p_dcp_attribute8                 in  varchar2
  ,p_dcp_attribute9                 in  varchar2
  ,p_dcp_attribute10                in  varchar2
  ,p_dcp_attribute11                in  varchar2
  ,p_dcp_attribute12                in  varchar2
  ,p_dcp_attribute13                in  varchar2
  ,p_dcp_attribute14                in  varchar2
  ,p_dcp_attribute15                in  varchar2
  ,p_dcp_attribute16                in  varchar2
  ,p_dcp_attribute17                in  varchar2
  ,p_dcp_attribute18                in  varchar2
  ,p_dcp_attribute19                in  varchar2
  ,p_dcp_attribute20                in  varchar2
  ,p_dcp_attribute21                in  varchar2
  ,p_dcp_attribute22                in  varchar2
  ,p_dcp_attribute23                in  varchar2
  ,p_dcp_attribute24                in  varchar2
  ,p_dcp_attribute25                in  varchar2
  ,p_dcp_attribute26                in  varchar2
  ,p_dcp_attribute27                in  varchar2
  ,p_dcp_attribute28                in  varchar2
  ,p_dcp_attribute29                in  varchar2
  ,p_dcp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_DPNT_CVRD_PLIP_RT_bk1;

 

/
