--------------------------------------------------------
--  DDL for Package BEN_PLAN_BENEFICIARY_CTFN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_BENEFICIARY_CTFN_BK2" AUTHID CURRENT_USER as
/* $Header: bepcxapi.pkh 120.0 2005/05/28 10:20:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_Beneficiary_Ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_Beneficiary_Ctfn_b
  (
   p_pl_bnf_ctfn_id                 in  number
  ,p_pl_id                          in  number
  ,p_bnf_ctfn_typ_cd                in  varchar2
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2
  ,p_pfd_flag                       in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_bnf_typ_cd                     in  varchar2
  ,p_rlshp_typ_cd                   in  varchar2
  ,p_business_group_id              in  number
  ,p_pcx_attribute_category         in  varchar2
  ,p_pcx_attribute1                 in  varchar2
  ,p_pcx_attribute2                 in  varchar2
  ,p_pcx_attribute3                 in  varchar2
  ,p_pcx_attribute4                 in  varchar2
  ,p_pcx_attribute5                 in  varchar2
  ,p_pcx_attribute6                 in  varchar2
  ,p_pcx_attribute7                 in  varchar2
  ,p_pcx_attribute8                 in  varchar2
  ,p_pcx_attribute9                 in  varchar2
  ,p_pcx_attribute10                in  varchar2
  ,p_pcx_attribute11                in  varchar2
  ,p_pcx_attribute12                in  varchar2
  ,p_pcx_attribute13                in  varchar2
  ,p_pcx_attribute14                in  varchar2
  ,p_pcx_attribute15                in  varchar2
  ,p_pcx_attribute16                in  varchar2
  ,p_pcx_attribute17                in  varchar2
  ,p_pcx_attribute18                in  varchar2
  ,p_pcx_attribute19                in  varchar2
  ,p_pcx_attribute20                in  varchar2
  ,p_pcx_attribute21                in  varchar2
  ,p_pcx_attribute22                in  varchar2
  ,p_pcx_attribute23                in  varchar2
  ,p_pcx_attribute24                in  varchar2
  ,p_pcx_attribute25                in  varchar2
  ,p_pcx_attribute26                in  varchar2
  ,p_pcx_attribute27                in  varchar2
  ,p_pcx_attribute28                in  varchar2
  ,p_pcx_attribute29                in  varchar2
  ,p_pcx_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_Beneficiary_Ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_Beneficiary_Ctfn_a
  (
   p_pl_bnf_ctfn_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_pl_id                          in  number
  ,p_bnf_ctfn_typ_cd                in  varchar2
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2
  ,p_pfd_flag                       in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_bnf_typ_cd                     in  varchar2
  ,p_rlshp_typ_cd                   in  varchar2
  ,p_business_group_id              in  number
  ,p_pcx_attribute_category         in  varchar2
  ,p_pcx_attribute1                 in  varchar2
  ,p_pcx_attribute2                 in  varchar2
  ,p_pcx_attribute3                 in  varchar2
  ,p_pcx_attribute4                 in  varchar2
  ,p_pcx_attribute5                 in  varchar2
  ,p_pcx_attribute6                 in  varchar2
  ,p_pcx_attribute7                 in  varchar2
  ,p_pcx_attribute8                 in  varchar2
  ,p_pcx_attribute9                 in  varchar2
  ,p_pcx_attribute10                in  varchar2
  ,p_pcx_attribute11                in  varchar2
  ,p_pcx_attribute12                in  varchar2
  ,p_pcx_attribute13                in  varchar2
  ,p_pcx_attribute14                in  varchar2
  ,p_pcx_attribute15                in  varchar2
  ,p_pcx_attribute16                in  varchar2
  ,p_pcx_attribute17                in  varchar2
  ,p_pcx_attribute18                in  varchar2
  ,p_pcx_attribute19                in  varchar2
  ,p_pcx_attribute20                in  varchar2
  ,p_pcx_attribute21                in  varchar2
  ,p_pcx_attribute22                in  varchar2
  ,p_pcx_attribute23                in  varchar2
  ,p_pcx_attribute24                in  varchar2
  ,p_pcx_attribute25                in  varchar2
  ,p_pcx_attribute26                in  varchar2
  ,p_pcx_attribute27                in  varchar2
  ,p_pcx_attribute28                in  varchar2
  ,p_pcx_attribute29                in  varchar2
  ,p_pcx_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Plan_Beneficiary_Ctfn_bk2;

 

/
