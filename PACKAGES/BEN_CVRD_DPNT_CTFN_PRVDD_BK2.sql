--------------------------------------------------------
--  DDL for Package BEN_CVRD_DPNT_CTFN_PRVDD_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CVRD_DPNT_CTFN_PRVDD_BK2" AUTHID CURRENT_USER as
/* $Header: beccpapi.pkh 120.0 2005/05/28 00:58:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_CVRD_DPNT_CTFN_PRVDD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_CVRD_DPNT_CTFN_PRVDD_b
  (
   p_cvrd_dpnt_ctfn_prvdd_id        in  number
  ,p_dpnt_dsgn_ctfn_typ_cd          in  varchar2
  ,p_dpnt_dsgn_ctfn_rqd_flag        in  varchar2
  ,p_dpnt_dsgn_ctfn_recd_dt         in  date
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_prtt_enrt_actn_id              in  number
  ,p_business_group_id              in  number
  ,p_ccp_attribute_category         in  varchar2
  ,p_ccp_attribute1                 in  varchar2
  ,p_ccp_attribute2                 in  varchar2
  ,p_ccp_attribute3                 in  varchar2
  ,p_ccp_attribute4                 in  varchar2
  ,p_ccp_attribute5                 in  varchar2
  ,p_ccp_attribute6                 in  varchar2
  ,p_ccp_attribute7                 in  varchar2
  ,p_ccp_attribute8                 in  varchar2
  ,p_ccp_attribute9                 in  varchar2
  ,p_ccp_attribute10                in  varchar2
  ,p_ccp_attribute11                in  varchar2
  ,p_ccp_attribute12                in  varchar2
  ,p_ccp_attribute13                in  varchar2
  ,p_ccp_attribute14                in  varchar2
  ,p_ccp_attribute15                in  varchar2
  ,p_ccp_attribute16                in  varchar2
  ,p_ccp_attribute17                in  varchar2
  ,p_ccp_attribute18                in  varchar2
  ,p_ccp_attribute19                in  varchar2
  ,p_ccp_attribute20                in  varchar2
  ,p_ccp_attribute21                in  varchar2
  ,p_ccp_attribute22                in  varchar2
  ,p_ccp_attribute23                in  varchar2
  ,p_ccp_attribute24                in  varchar2
  ,p_ccp_attribute25                in  varchar2
  ,p_ccp_attribute26                in  varchar2
  ,p_ccp_attribute27                in  varchar2
  ,p_ccp_attribute28                in  varchar2
  ,p_ccp_attribute29                in  varchar2
  ,p_ccp_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_CVRD_DPNT_CTFN_PRVDD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_CVRD_DPNT_CTFN_PRVDD_a
  (
   p_cvrd_dpnt_ctfn_prvdd_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_dpnt_dsgn_ctfn_typ_cd          in  varchar2
  ,p_dpnt_dsgn_ctfn_rqd_flag        in  varchar2
  ,p_dpnt_dsgn_ctfn_recd_dt         in  date
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_prtt_enrt_actn_id              in  number
  ,p_business_group_id              in  number
  ,p_ccp_attribute_category         in  varchar2
  ,p_ccp_attribute1                 in  varchar2
  ,p_ccp_attribute2                 in  varchar2
  ,p_ccp_attribute3                 in  varchar2
  ,p_ccp_attribute4                 in  varchar2
  ,p_ccp_attribute5                 in  varchar2
  ,p_ccp_attribute6                 in  varchar2
  ,p_ccp_attribute7                 in  varchar2
  ,p_ccp_attribute8                 in  varchar2
  ,p_ccp_attribute9                 in  varchar2
  ,p_ccp_attribute10                in  varchar2
  ,p_ccp_attribute11                in  varchar2
  ,p_ccp_attribute12                in  varchar2
  ,p_ccp_attribute13                in  varchar2
  ,p_ccp_attribute14                in  varchar2
  ,p_ccp_attribute15                in  varchar2
  ,p_ccp_attribute16                in  varchar2
  ,p_ccp_attribute17                in  varchar2
  ,p_ccp_attribute18                in  varchar2
  ,p_ccp_attribute19                in  varchar2
  ,p_ccp_attribute20                in  varchar2
  ,p_ccp_attribute21                in  varchar2
  ,p_ccp_attribute22                in  varchar2
  ,p_ccp_attribute23                in  varchar2
  ,p_ccp_attribute24                in  varchar2
  ,p_ccp_attribute25                in  varchar2
  ,p_ccp_attribute26                in  varchar2
  ,p_ccp_attribute27                in  varchar2
  ,p_ccp_attribute28                in  varchar2
  ,p_ccp_attribute29                in  varchar2
  ,p_ccp_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_CVRD_DPNT_CTFN_PRVDD_bk2;

 

/
