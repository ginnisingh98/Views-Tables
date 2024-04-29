--------------------------------------------------------
--  DDL for Package BEN_PTIP_DPNT_CVG_CTFN_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PTIP_DPNT_CVG_CTFN_BK1" AUTHID CURRENT_USER as
/* $Header: bepydapi.pkh 120.0 2005/05/28 11:27:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Ptip_Dpnt_Cvg_Ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Ptip_Dpnt_Cvg_Ctfn_b
  (
   p_business_group_id              in  number
  ,p_ptip_id                        in  number
  ,p_pfd_flag                       in  varchar2
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_dpnt_cvg_ctfn_typ_cd           in  varchar2
  ,p_rlshp_typ_cd                   in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_pyd_attribute_category         in  varchar2
  ,p_pyd_attribute1                 in  varchar2
  ,p_pyd_attribute2                 in  varchar2
  ,p_pyd_attribute3                 in  varchar2
  ,p_pyd_attribute4                 in  varchar2
  ,p_pyd_attribute5                 in  varchar2
  ,p_pyd_attribute6                 in  varchar2
  ,p_pyd_attribute7                 in  varchar2
  ,p_pyd_attribute8                 in  varchar2
  ,p_pyd_attribute9                 in  varchar2
  ,p_pyd_attribute10                in  varchar2
  ,p_pyd_attribute11                in  varchar2
  ,p_pyd_attribute12                in  varchar2
  ,p_pyd_attribute13                in  varchar2
  ,p_pyd_attribute14                in  varchar2
  ,p_pyd_attribute15                in  varchar2
  ,p_pyd_attribute16                in  varchar2
  ,p_pyd_attribute17                in  varchar2
  ,p_pyd_attribute18                in  varchar2
  ,p_pyd_attribute19                in  varchar2
  ,p_pyd_attribute20                in  varchar2
  ,p_pyd_attribute21                in  varchar2
  ,p_pyd_attribute22                in  varchar2
  ,p_pyd_attribute23                in  varchar2
  ,p_pyd_attribute24                in  varchar2
  ,p_pyd_attribute25                in  varchar2
  ,p_pyd_attribute26                in  varchar2
  ,p_pyd_attribute27                in  varchar2
  ,p_pyd_attribute28                in  varchar2
  ,p_pyd_attribute29                in  varchar2
  ,p_pyd_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Ptip_Dpnt_Cvg_Ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Ptip_Dpnt_Cvg_Ctfn_a
  (
   p_ptip_dpnt_cvg_ctfn_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_ptip_id                        in  number
  ,p_pfd_flag                       in  varchar2
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_dpnt_cvg_ctfn_typ_cd           in  varchar2
  ,p_rlshp_typ_cd                   in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_pyd_attribute_category         in  varchar2
  ,p_pyd_attribute1                 in  varchar2
  ,p_pyd_attribute2                 in  varchar2
  ,p_pyd_attribute3                 in  varchar2
  ,p_pyd_attribute4                 in  varchar2
  ,p_pyd_attribute5                 in  varchar2
  ,p_pyd_attribute6                 in  varchar2
  ,p_pyd_attribute7                 in  varchar2
  ,p_pyd_attribute8                 in  varchar2
  ,p_pyd_attribute9                 in  varchar2
  ,p_pyd_attribute10                in  varchar2
  ,p_pyd_attribute11                in  varchar2
  ,p_pyd_attribute12                in  varchar2
  ,p_pyd_attribute13                in  varchar2
  ,p_pyd_attribute14                in  varchar2
  ,p_pyd_attribute15                in  varchar2
  ,p_pyd_attribute16                in  varchar2
  ,p_pyd_attribute17                in  varchar2
  ,p_pyd_attribute18                in  varchar2
  ,p_pyd_attribute19                in  varchar2
  ,p_pyd_attribute20                in  varchar2
  ,p_pyd_attribute21                in  varchar2
  ,p_pyd_attribute22                in  varchar2
  ,p_pyd_attribute23                in  varchar2
  ,p_pyd_attribute24                in  varchar2
  ,p_pyd_attribute25                in  varchar2
  ,p_pyd_attribute26                in  varchar2
  ,p_pyd_attribute27                in  varchar2
  ,p_pyd_attribute28                in  varchar2
  ,p_pyd_attribute29                in  varchar2
  ,p_pyd_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Ptip_Dpnt_Cvg_Ctfn_bk1;

 

/
