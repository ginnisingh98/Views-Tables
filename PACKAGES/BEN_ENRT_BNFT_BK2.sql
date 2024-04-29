--------------------------------------------------------
--  DDL for Package BEN_ENRT_BNFT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_BNFT_BK2" AUTHID CURRENT_USER as
/* $Header: beenbapi.pkh 120.0 2005/05/28 02:27:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_enrt_bnft_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_bnft_b
  (
   p_enrt_bnft_id                   in  number
  ,p_dflt_flag                      in  varchar2
  ,p_val_has_bn_prortd_flag         in  varchar2
  ,p_bndry_perd_cd                  in  varchar2
  ,p_val                            in  number
  ,p_nnmntry_uom                    in  varchar2
  ,p_bnft_typ_cd                    in  varchar2
  ,p_entr_val_at_enrt_flag          in  varchar2
  ,p_mn_val                         in  number
  ,p_mx_val                         in  number
  ,p_incrmt_val                     in  number
  ,p_dflt_val                       in  number
  ,p_rt_typ_cd                      in  varchar2
  ,p_cvg_mlt_cd                     in  varchar2
  ,p_ctfn_rqd_flag                  in  varchar2
  ,p_ordr_num                       in  number
  ,p_crntly_enrld_flag              in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_business_group_id              in  number
  ,p_enb_attribute_category         in  varchar2
  ,p_enb_attribute1                 in  varchar2
  ,p_enb_attribute2                 in  varchar2
  ,p_enb_attribute3                 in  varchar2
  ,p_enb_attribute4                 in  varchar2
  ,p_enb_attribute5                 in  varchar2
  ,p_enb_attribute6                 in  varchar2
  ,p_enb_attribute7                 in  varchar2
  ,p_enb_attribute8                 in  varchar2
  ,p_enb_attribute9                 in  varchar2
  ,p_enb_attribute10                in  varchar2
  ,p_enb_attribute11                in  varchar2
  ,p_enb_attribute12                in  varchar2
  ,p_enb_attribute13                in  varchar2
  ,p_enb_attribute14                in  varchar2
  ,p_enb_attribute15                in  varchar2
  ,p_enb_attribute16                in  varchar2
  ,p_enb_attribute17                in  varchar2
  ,p_enb_attribute18                in  varchar2
  ,p_enb_attribute19                in  varchar2
  ,p_enb_attribute20                in  varchar2
  ,p_enb_attribute21                in  varchar2
  ,p_enb_attribute22                in  varchar2
  ,p_enb_attribute23                in  varchar2
  ,p_enb_attribute24                in  varchar2
  ,p_enb_attribute25                in  varchar2
  ,p_enb_attribute26                in  varchar2
  ,p_enb_attribute27                in  varchar2
  ,p_enb_attribute28                in  varchar2
  ,p_enb_attribute29                in  varchar2
  ,p_enb_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_mx_wout_ctfn_val               in  number
  ,p_mx_wo_ctfn_flag                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_enrt_bnft_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_bnft_a
  (
   p_enrt_bnft_id                   in  number
  ,p_dflt_flag                      in  varchar2
  ,p_val_has_bn_prortd_flag         in  varchar2
  ,p_bndry_perd_cd                  in  varchar2
  ,p_val                            in  number
  ,p_nnmntry_uom                    in  varchar2
  ,p_bnft_typ_cd                    in  varchar2
  ,p_entr_val_at_enrt_flag          in  varchar2
  ,p_mn_val                         in  number
  ,p_mx_val                         in  number
  ,p_incrmt_val                     in  number
  ,p_dflt_val                       in  number
  ,p_rt_typ_cd                      in  varchar2
  ,p_cvg_mlt_cd                     in  varchar2
  ,p_ctfn_rqd_flag                  in  varchar2
  ,p_ordr_num                       in  number
  ,p_crntly_enrld_flag              in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_business_group_id              in  number
  ,p_enb_attribute_category         in  varchar2
  ,p_enb_attribute1                 in  varchar2
  ,p_enb_attribute2                 in  varchar2
  ,p_enb_attribute3                 in  varchar2
  ,p_enb_attribute4                 in  varchar2
  ,p_enb_attribute5                 in  varchar2
  ,p_enb_attribute6                 in  varchar2
  ,p_enb_attribute7                 in  varchar2
  ,p_enb_attribute8                 in  varchar2
  ,p_enb_attribute9                 in  varchar2
  ,p_enb_attribute10                in  varchar2
  ,p_enb_attribute11                in  varchar2
  ,p_enb_attribute12                in  varchar2
  ,p_enb_attribute13                in  varchar2
  ,p_enb_attribute14                in  varchar2
  ,p_enb_attribute15                in  varchar2
  ,p_enb_attribute16                in  varchar2
  ,p_enb_attribute17                in  varchar2
  ,p_enb_attribute18                in  varchar2
  ,p_enb_attribute19                in  varchar2
  ,p_enb_attribute20                in  varchar2
  ,p_enb_attribute21                in  varchar2
  ,p_enb_attribute22                in  varchar2
  ,p_enb_attribute23                in  varchar2
  ,p_enb_attribute24                in  varchar2
  ,p_enb_attribute25                in  varchar2
  ,p_enb_attribute26                in  varchar2
  ,p_enb_attribute27                in  varchar2
  ,p_enb_attribute28                in  varchar2
  ,p_enb_attribute29                in  varchar2
  ,p_enb_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_mx_wout_ctfn_val               in  number
  ,p_mx_wo_ctfn_flag                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_enrt_bnft_bk2;

 

/
