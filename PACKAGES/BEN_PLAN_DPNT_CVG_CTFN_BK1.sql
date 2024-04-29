--------------------------------------------------------
--  DDL for Package BEN_PLAN_DPNT_CVG_CTFN_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_DPNT_CVG_CTFN_BK1" AUTHID CURRENT_USER as
/* $Header: bepndapi.pkh 120.0 2005/05/28 10:55:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Plan_Dpnt_Cvg_Ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Plan_Dpnt_Cvg_Ctfn_b
  (
   p_pl_id                          in  number
  ,p_pfd_flag                       in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2
  ,p_dpnt_cvg_ctfn_typ_cd           in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_rlshp_typ_cd                   in  varchar2
  ,p_business_group_id              in  number
  ,p_pnd_attribute_category         in  varchar2
  ,p_pnd_attribute1                 in  varchar2
  ,p_pnd_attribute2                 in  varchar2
  ,p_pnd_attribute3                 in  varchar2
  ,p_pnd_attribute4                 in  varchar2
  ,p_pnd_attribute5                 in  varchar2
  ,p_pnd_attribute6                 in  varchar2
  ,p_pnd_attribute7                 in  varchar2
  ,p_pnd_attribute8                 in  varchar2
  ,p_pnd_attribute9                 in  varchar2
  ,p_pnd_attribute10                in  varchar2
  ,p_pnd_attribute11                in  varchar2
  ,p_pnd_attribute12                in  varchar2
  ,p_pnd_attribute13                in  varchar2
  ,p_pnd_attribute14                in  varchar2
  ,p_pnd_attribute15                in  varchar2
  ,p_pnd_attribute16                in  varchar2
  ,p_pnd_attribute17                in  varchar2
  ,p_pnd_attribute18                in  varchar2
  ,p_pnd_attribute19                in  varchar2
  ,p_pnd_attribute20                in  varchar2
  ,p_pnd_attribute21                in  varchar2
  ,p_pnd_attribute22                in  varchar2
  ,p_pnd_attribute23                in  varchar2
  ,p_pnd_attribute24                in  varchar2
  ,p_pnd_attribute25                in  varchar2
  ,p_pnd_attribute26                in  varchar2
  ,p_pnd_attribute27                in  varchar2
  ,p_pnd_attribute28                in  varchar2
  ,p_pnd_attribute29                in  varchar2
  ,p_pnd_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Plan_Dpnt_Cvg_Ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Plan_Dpnt_Cvg_Ctfn_a
  (
   p_pl_dpnt_cvg_ctfn_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_pl_id                          in  number
  ,p_pfd_flag                       in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2
  ,p_dpnt_cvg_ctfn_typ_cd           in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_rlshp_typ_cd                   in  varchar2
  ,p_business_group_id              in  number
  ,p_pnd_attribute_category         in  varchar2
  ,p_pnd_attribute1                 in  varchar2
  ,p_pnd_attribute2                 in  varchar2
  ,p_pnd_attribute3                 in  varchar2
  ,p_pnd_attribute4                 in  varchar2
  ,p_pnd_attribute5                 in  varchar2
  ,p_pnd_attribute6                 in  varchar2
  ,p_pnd_attribute7                 in  varchar2
  ,p_pnd_attribute8                 in  varchar2
  ,p_pnd_attribute9                 in  varchar2
  ,p_pnd_attribute10                in  varchar2
  ,p_pnd_attribute11                in  varchar2
  ,p_pnd_attribute12                in  varchar2
  ,p_pnd_attribute13                in  varchar2
  ,p_pnd_attribute14                in  varchar2
  ,p_pnd_attribute15                in  varchar2
  ,p_pnd_attribute16                in  varchar2
  ,p_pnd_attribute17                in  varchar2
  ,p_pnd_attribute18                in  varchar2
  ,p_pnd_attribute19                in  varchar2
  ,p_pnd_attribute20                in  varchar2
  ,p_pnd_attribute21                in  varchar2
  ,p_pnd_attribute22                in  varchar2
  ,p_pnd_attribute23                in  varchar2
  ,p_pnd_attribute24                in  varchar2
  ,p_pnd_attribute25                in  varchar2
  ,p_pnd_attribute26                in  varchar2
  ,p_pnd_attribute27                in  varchar2
  ,p_pnd_attribute28                in  varchar2
  ,p_pnd_attribute29                in  varchar2
  ,p_pnd_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Plan_Dpnt_Cvg_Ctfn_bk1;

 

/
