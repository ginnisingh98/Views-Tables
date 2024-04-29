--------------------------------------------------------
--  DDL for Package BEN_REIMBMT_CTFN_PRVDD_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REIMBMT_CTFN_PRVDD_BK2" AUTHID CURRENT_USER as
/* $Header: bepqcapi.pkh 120.0 2005/05/28 11:02:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_reimbmt_ctfn_prvdd_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_reimbmt_ctfn_prvdd_b
  (
   p_prtt_rmt_rqst_ctfn_prvdd_id    in  number
  ,p_prtt_clm_gd_or_svc_typ_id      in  number
  ,p_pl_gd_r_svc_ctfn_id            in  number
  ,p_reimbmt_ctfn_rqd_flag          in  varchar2
  ,p_business_group_id              in  number
  ,p_prtt_enrt_actn_id              in  number
  ,p_reimbmt_ctfn_recd_dt           in  date
  ,p_reimbmt_ctfn_dnd_dt            in  date
  ,p_reimbmt_ctfn_typ_cd            in  varchar2
  ,p_pqc_attribute_category         in  varchar2
  ,p_pqc_attribute1                 in  varchar2
  ,p_pqc_attribute2                 in  varchar2
  ,p_pqc_attribute3                 in  varchar2
  ,p_pqc_attribute4                 in  varchar2
  ,p_pqc_attribute5                 in  varchar2
  ,p_pqc_attribute6                 in  varchar2
  ,p_pqc_attribute7                 in  varchar2
  ,p_pqc_attribute8                 in  varchar2
  ,p_pqc_attribute9                 in  varchar2
  ,p_pqc_attribute10                in  varchar2
  ,p_pqc_attribute11                in  varchar2
  ,p_pqc_attribute12                in  varchar2
  ,p_pqc_attribute13                in  varchar2
  ,p_pqc_attribute14                in  varchar2
  ,p_pqc_attribute15                in  varchar2
  ,p_pqc_attribute16                in  varchar2
  ,p_pqc_attribute17                in  varchar2
  ,p_pqc_attribute18                in  varchar2
  ,p_pqc_attribute19                in  varchar2
  ,p_pqc_attribute20                in  varchar2
  ,p_pqc_attribute21                in  varchar2
  ,p_pqc_attribute22                in  varchar2
  ,p_pqc_attribute23                in  varchar2
  ,p_pqc_attribute24                in  varchar2
  ,p_pqc_attribute25                in  varchar2
  ,p_pqc_attribute26                in  varchar2
  ,p_pqc_attribute27                in  varchar2
  ,p_pqc_attribute28                in  varchar2
  ,p_pqc_attribute29                in  varchar2
  ,p_pqc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_reimbmt_ctfn_prvdd_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_reimbmt_ctfn_prvdd_a
  (
   p_prtt_rmt_rqst_ctfn_prvdd_id    in  number
  ,p_prtt_clm_gd_or_svc_typ_id      in  number
  ,p_pl_gd_r_svc_ctfn_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_reimbmt_ctfn_rqd_flag          in  varchar2
  ,p_business_group_id              in  number
  ,p_prtt_enrt_actn_id              in  number
  ,p_reimbmt_ctfn_recd_dt           in  date
  ,p_reimbmt_ctfn_dnd_dt            in  date
  ,p_reimbmt_ctfn_typ_cd            in  varchar2
  ,p_pqc_attribute_category         in  varchar2
  ,p_pqc_attribute1                 in  varchar2
  ,p_pqc_attribute2                 in  varchar2
  ,p_pqc_attribute3                 in  varchar2
  ,p_pqc_attribute4                 in  varchar2
  ,p_pqc_attribute5                 in  varchar2
  ,p_pqc_attribute6                 in  varchar2
  ,p_pqc_attribute7                 in  varchar2
  ,p_pqc_attribute8                 in  varchar2
  ,p_pqc_attribute9                 in  varchar2
  ,p_pqc_attribute10                in  varchar2
  ,p_pqc_attribute11                in  varchar2
  ,p_pqc_attribute12                in  varchar2
  ,p_pqc_attribute13                in  varchar2
  ,p_pqc_attribute14                in  varchar2
  ,p_pqc_attribute15                in  varchar2
  ,p_pqc_attribute16                in  varchar2
  ,p_pqc_attribute17                in  varchar2
  ,p_pqc_attribute18                in  varchar2
  ,p_pqc_attribute19                in  varchar2
  ,p_pqc_attribute20                in  varchar2
  ,p_pqc_attribute21                in  varchar2
  ,p_pqc_attribute22                in  varchar2
  ,p_pqc_attribute23                in  varchar2
  ,p_pqc_attribute24                in  varchar2
  ,p_pqc_attribute25                in  varchar2
  ,p_pqc_attribute26                in  varchar2
  ,p_pqc_attribute27                in  varchar2
  ,p_pqc_attribute28                in  varchar2
  ,p_pqc_attribute29                in  varchar2
  ,p_pqc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_reimbmt_ctfn_prvdd_bk2;

 

/
