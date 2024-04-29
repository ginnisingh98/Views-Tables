--------------------------------------------------------
--  DDL for Package BEN_ENROLLMENT_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLLMENT_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: beecrapi.pkh 120.0 2005/05/28 01:52:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Enrollment_Rate_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Enrollment_Rate_b
  (
   p_enrt_rt_id                  in  NUMBER
  ,p_ordr_num			    in number
  ,p_acty_typ_cd                 in  VARCHAR2
  ,p_tx_typ_cd                   in  VARCHAR2
  ,p_ctfn_rqd_flag               in  VARCHAR2
  ,p_dflt_flag                   in  VARCHAR2
  ,p_dflt_pndg_ctfn_flag         in  VARCHAR2
  ,p_dsply_on_enrt_flag          in  VARCHAR2
  ,p_use_to_calc_net_flx_cr_flag in  VARCHAR2
  ,p_entr_val_at_enrt_flag       in  VARCHAR2
  ,p_asn_on_enrt_flag            in  VARCHAR2
  ,p_rl_crs_only_flag            in  VARCHAR2
  ,p_dflt_val                    in  NUMBER
  ,p_ann_val                     in  NUMBER
  ,p_ann_mn_elcn_val             in  NUMBER
  ,p_ann_mx_elcn_val             in  NUMBER
  ,p_val                         in  NUMBER
  ,p_nnmntry_uom                 in  VARCHAR2
  ,p_mx_elcn_val                 in  NUMBER
  ,p_mn_elcn_val                 in  NUMBER
  ,p_incrmt_elcn_val             in  NUMBER
  ,p_cmcd_acty_ref_perd_cd       in  VARCHAR2
  ,p_cmcd_mn_elcn_val            in  NUMBER
  ,p_cmcd_mx_elcn_val            in  NUMBER
  ,p_cmcd_val                    in  NUMBER
  ,p_cmcd_dflt_val               in  NUMBER
  ,p_rt_usg_cd                   in  VARCHAR2
  ,p_ann_dflt_val                in  NUMBER
  ,p_bnft_rt_typ_cd              in  VARCHAR2
  ,p_rt_mlt_cd                   in  VARCHAR2
  ,p_dsply_mn_elcn_val           in  NUMBER
  ,p_dsply_mx_elcn_val           in  NUMBER
  ,p_entr_ann_val_flag           in  VARCHAR2
  ,p_rt_strt_dt                  in  DATE
  ,p_rt_strt_dt_cd               in  VARCHAR2
  ,p_rt_strt_dt_rl               in  NUMBER
  ,p_rt_typ_cd                   in  VARCHAR2
  ,p_elig_per_elctbl_chc_id      in  NUMBER
  ,p_acty_base_rt_id             in  NUMBER
  ,p_spcl_rt_enrt_rt_id          in  NUMBER
  ,p_enrt_bnft_id                in  NUMBER
  ,p_prtt_rt_val_id              in  NUMBER
  ,p_decr_bnft_prvdr_pool_id     in  NUMBER
  ,p_cvg_amt_calc_mthd_id        in  NUMBER
  ,p_actl_prem_id                in  NUMBER
  ,p_comp_lvl_fctr_id            in  NUMBER
  ,p_ptd_comp_lvl_fctr_id        in  NUMBER
  ,p_clm_comp_lvl_fctr_id        in  NUMBER
  ,p_business_group_id           in  NUMBER
  ,p_iss_val                     in  number
  ,p_val_last_upd_date           in  date
  ,p_val_last_upd_person_id      in  number
  ,p_pp_in_yr_used_num           in  number
  ,p_ecr_attribute_category      in  VARCHAR2
  ,p_ecr_attribute1              in  VARCHAR2
  ,p_ecr_attribute2              in  VARCHAR2
  ,p_ecr_attribute3              in  VARCHAR2
  ,p_ecr_attribute4              in  VARCHAR2
  ,p_ecr_attribute5              in  VARCHAR2
  ,p_ecr_attribute6              in  VARCHAR2
  ,p_ecr_attribute7              in  VARCHAR2
  ,p_ecr_attribute8              in  VARCHAR2
  ,p_ecr_attribute9              in  VARCHAR2
  ,p_ecr_attribute10             in  VARCHAR2
  ,p_ecr_attribute11             in  VARCHAR2
  ,p_ecr_attribute12             in  VARCHAR2
  ,p_ecr_attribute13             in  VARCHAR2
  ,p_ecr_attribute14             in  VARCHAR2
  ,p_ecr_attribute15             in  VARCHAR2
  ,p_ecr_attribute16             in  VARCHAR2
  ,p_ecr_attribute17             in  VARCHAR2
  ,p_ecr_attribute18             in  VARCHAR2
  ,p_ecr_attribute19             in  VARCHAR2
  ,p_ecr_attribute20             in  VARCHAR2
  ,p_ecr_attribute21             in  VARCHAR2
  ,p_ecr_attribute22             in  VARCHAR2
  ,p_ecr_attribute23             in  VARCHAR2
  ,p_ecr_attribute24             in  VARCHAR2
  ,p_ecr_attribute25             in  VARCHAR2
  ,p_ecr_attribute26             in  VARCHAR2
  ,p_ecr_attribute27             in  VARCHAR2
  ,p_ecr_attribute28             in  VARCHAR2
  ,p_ecr_attribute29             in  VARCHAR2
  ,p_ecr_attribute30             in  VARCHAR2
  ,p_request_id                  in  NUMBER
  ,p_program_application_id      in  NUMBER
  ,p_program_id                  in  NUMBER
  ,p_program_update_date         in  DATE
  ,p_object_version_number       in  NUMBER
  ,p_effective_date              in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Enrollment_Rate_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Enrollment_Rate_a
  (
   p_enrt_rt_id                  in  NUMBER
  ,p_ordr_num			    in number
  ,p_acty_typ_cd                 in  VARCHAR2
  ,p_tx_typ_cd                   in  VARCHAR2
  ,p_ctfn_rqd_flag               in  VARCHAR2
  ,p_dflt_flag                   in  VARCHAR2
  ,p_dflt_pndg_ctfn_flag         in  VARCHAR2
  ,p_dsply_on_enrt_flag          in  VARCHAR2
  ,p_use_to_calc_net_flx_cr_flag in  VARCHAR2
  ,p_entr_val_at_enrt_flag       in  VARCHAR2
  ,p_asn_on_enrt_flag            in  VARCHAR2
  ,p_rl_crs_only_flag            in  VARCHAR2
  ,p_dflt_val                    in  NUMBER
  ,p_ann_val                     in  NUMBER
  ,p_ann_mn_elcn_val             in  NUMBER
  ,p_ann_mx_elcn_val             in  NUMBER
  ,p_val                         in  NUMBER
  ,p_nnmntry_uom                 in  VARCHAR2
  ,p_mx_elcn_val                 in  NUMBER
  ,p_mn_elcn_val                 in  NUMBER
  ,p_incrmt_elcn_val             in  NUMBER
  ,p_cmcd_acty_ref_perd_cd       in  VARCHAR2
  ,p_cmcd_mn_elcn_val            in  NUMBER
  ,p_cmcd_mx_elcn_val            in  NUMBER
  ,p_cmcd_val                    in  NUMBER
  ,p_cmcd_dflt_val               in  NUMBER
  ,p_rt_usg_cd                   in  VARCHAR2
  ,p_ann_dflt_val                in  NUMBER
  ,p_bnft_rt_typ_cd              in  VARCHAR2
  ,p_rt_mlt_cd                   in  VARCHAR2
  ,p_dsply_mn_elcn_val           in  NUMBER
  ,p_dsply_mx_elcn_val           in  NUMBER
  ,p_entr_ann_val_flag           in  VARCHAR2
  ,p_rt_strt_dt                  in  DATE
  ,p_rt_strt_dt_cd               in  VARCHAR2
  ,p_rt_strt_dt_rl               in  NUMBER
  ,p_rt_typ_cd                   in  VARCHAR2
  ,p_elig_per_elctbl_chc_id      in  NUMBER
  ,p_acty_base_rt_id             in  NUMBER
  ,p_spcl_rt_enrt_rt_id          in  NUMBER
  ,p_enrt_bnft_id                in  NUMBER
  ,p_prtt_rt_val_id              in  NUMBER
  ,p_decr_bnft_prvdr_pool_id     in  NUMBER
  ,p_cvg_amt_calc_mthd_id        in  NUMBER
  ,p_actl_prem_id                in  NUMBER
  ,p_comp_lvl_fctr_id            in  NUMBER
  ,p_ptd_comp_lvl_fctr_id        in  NUMBER
  ,p_clm_comp_lvl_fctr_id        in  NUMBER
  ,p_business_group_id           in  NUMBER
  ,p_iss_val                     in  number
  ,p_val_last_upd_date           in  date
  ,p_val_last_upd_person_id      in  number
  ,p_pp_in_yr_used_num           in  number
  ,p_ecr_attribute_category      in  VARCHAR2
  ,p_ecr_attribute1              in  VARCHAR2
  ,p_ecr_attribute2              in  VARCHAR2
  ,p_ecr_attribute3              in  VARCHAR2
  ,p_ecr_attribute4              in  VARCHAR2
  ,p_ecr_attribute5              in  VARCHAR2
  ,p_ecr_attribute6              in  VARCHAR2
  ,p_ecr_attribute7              in  VARCHAR2
  ,p_ecr_attribute8              in  VARCHAR2
  ,p_ecr_attribute9              in  VARCHAR2
  ,p_ecr_attribute10             in  VARCHAR2
  ,p_ecr_attribute11             in  VARCHAR2
  ,p_ecr_attribute12             in  VARCHAR2
  ,p_ecr_attribute13             in  VARCHAR2
  ,p_ecr_attribute14             in  VARCHAR2
  ,p_ecr_attribute15             in  VARCHAR2
  ,p_ecr_attribute16             in  VARCHAR2
  ,p_ecr_attribute17             in  VARCHAR2
  ,p_ecr_attribute18             in  VARCHAR2
  ,p_ecr_attribute19             in  VARCHAR2
  ,p_ecr_attribute20             in  VARCHAR2
  ,p_ecr_attribute21             in  VARCHAR2
  ,p_ecr_attribute22             in  VARCHAR2
  ,p_ecr_attribute23             in  VARCHAR2
  ,p_ecr_attribute24             in  VARCHAR2
  ,p_ecr_attribute25             in  VARCHAR2
  ,p_ecr_attribute26             in  VARCHAR2
  ,p_ecr_attribute27             in  VARCHAR2
  ,p_ecr_attribute28             in  VARCHAR2
  ,p_ecr_attribute29             in  VARCHAR2
  ,p_ecr_attribute30             in  VARCHAR2
  ,p_request_id                  in  NUMBER
  ,p_program_application_id      in  NUMBER
  ,p_program_id                  in  NUMBER
  ,p_program_update_date         in  DATE
  ,p_object_version_number       in  NUMBER
  ,p_effective_date              in  date
  );
--
end ben_Enrollment_Rate_bk2;

 

/
