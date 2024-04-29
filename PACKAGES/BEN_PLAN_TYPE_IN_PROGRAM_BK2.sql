--------------------------------------------------------
--  DDL for Package BEN_PLAN_TYPE_IN_PROGRAM_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_TYPE_IN_PROGRAM_BK2" AUTHID CURRENT_USER as
/* $Header: bectpapi.pkh 120.0 2005/05/28 01:25:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_Type_In_Program_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_Type_In_Program_b
  (
   p_ptip_id                        in  number
  ,p_coord_cvg_for_all_pls_flag     in  varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2
  ,p_dpnt_cvg_no_ctfn_rqd_flag      in  varchar2
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2
  ,p_rt_end_dt_cd            in  varchar2
  ,p_rt_strt_dt_cd            in  varchar2
  ,p_enrt_cvg_end_dt_cd            in  varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  number
  ,p_dpnt_cvg_end_dt_cd             in  varchar2
  ,p_dpnt_cvg_end_dt_rl             in  number
  ,p_dpnt_adrs_rqd_flag             in  varchar2
  ,p_dpnt_legv_id_rqd_flag          in  varchar2
  ,p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2
  ,p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2
  ,p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2
  ,p_susp_if_ctfn_not_dpnt_flag     in  varchar2
  ,p_dpnt_ctfn_determine_cd         in  varchar2
  ,p_postelcn_edit_rl               in  number
  ,p_rt_end_dt_rl               in  number
  ,p_rt_strt_dt_rl               in  number
  ,p_enrt_cvg_end_dt_rl               in  number
  ,p_enrt_cvg_strt_dt_rl               in  number
  ,p_rqd_perd_enrt_nenrt_rl               in  number
  ,p_auto_enrt_mthd_rl              in   number
  ,p_enrt_mthd_cd                   in   varchar2
  ,p_enrt_cd                        in   varchar2
  ,p_enrt_rl                        in   number
  ,p_dflt_enrt_cd                   in   varchar2
  ,p_dflt_enrt_det_rl               in   number
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2
  ,p_elig_apls_flag                 in  varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2
  ,p_trk_inelig_per_flag            in  varchar2
  ,p_dpnt_dob_rqd_flag              in  varchar2
  ,p_crs_this_pl_typ_only_flag      in  varchar2
  ,p_ptip_stat_cd                   in  varchar2
  ,p_mx_cvg_alwd_amt                in  number
  ,p_mx_enrd_alwd_ovrid_num         in  number
  ,p_mn_enrd_rqd_ovrid_num          in  number
  ,p_no_mx_pl_typ_ovrid_flag        in  varchar2
  ,p_ordr_num                       in  number
  ,p_prvds_cr_flag                  in  varchar2
  ,p_rqd_perd_enrt_nenrt_val        in  number
  ,p_rqd_perd_enrt_nenrt_tm_uom     in  varchar2
  ,p_wvbl_flag                      in  varchar2
  ,p_drvd_fctr_dpnt_cvg_flag        in  varchar2
  ,p_no_mn_pl_typ_overid_flag       in  varchar2
  ,p_sbj_to_sps_lf_ins_mx_flag      in  varchar2
  ,p_sbj_to_dpnt_lf_ins_mx_flag     in  varchar2
  ,p_use_to_sum_ee_lf_ins_flag      in  varchar2
  ,p_per_cvrd_cd                    in  varchar2
  ,p_short_name                    in  varchar2
  ,p_short_code                    in  varchar2
    ,p_legislation_code                    in  varchar2
    ,p_legislation_subgroup                    in  varchar2
  ,p_vrfy_fmly_mmbr_cd              in  varchar2
  ,p_vrfy_fmly_mmbr_rl              in  number
  ,p_ivr_ident                      in  varchar2
  ,p_url_ref_name                   in  varchar2
  ,p_rqd_enrt_perd_tco_cd           in  varchar2
  ,p_pgm_id                         in  number
  ,p_pl_typ_id                      in  number
  ,p_cmbn_ptip_id                   in  number
  ,p_cmbn_ptip_opt_id               in  number
  ,p_acrs_ptip_cvg_id               in  number
  ,p_business_group_id              in  number
  ,p_ctp_attribute_category         in  varchar2
  ,p_ctp_attribute1                 in  varchar2
  ,p_ctp_attribute2                 in  varchar2
  ,p_ctp_attribute3                 in  varchar2
  ,p_ctp_attribute4                 in  varchar2
  ,p_ctp_attribute5                 in  varchar2
  ,p_ctp_attribute6                 in  varchar2
  ,p_ctp_attribute7                 in  varchar2
  ,p_ctp_attribute8                 in  varchar2
  ,p_ctp_attribute9                 in  varchar2
  ,p_ctp_attribute10                in  varchar2
  ,p_ctp_attribute11                in  varchar2
  ,p_ctp_attribute12                in  varchar2
  ,p_ctp_attribute13                in  varchar2
  ,p_ctp_attribute14                in  varchar2
  ,p_ctp_attribute15                in  varchar2
  ,p_ctp_attribute16                in  varchar2
  ,p_ctp_attribute17                in  varchar2
  ,p_ctp_attribute18                in  varchar2
  ,p_ctp_attribute19                in  varchar2
  ,p_ctp_attribute20                in  varchar2
  ,p_ctp_attribute21                in  varchar2
  ,p_ctp_attribute22                in  varchar2
  ,p_ctp_attribute23                in  varchar2
  ,p_ctp_attribute24                in  varchar2
  ,p_ctp_attribute25                in  varchar2
  ,p_ctp_attribute26                in  varchar2
  ,p_ctp_attribute27                in  varchar2
  ,p_ctp_attribute28                in  varchar2
  ,p_ctp_attribute29                in  varchar2
  ,p_ctp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_Type_In_Program_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_Type_In_Program_a
  (
   p_ptip_id                        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_coord_cvg_for_all_pls_flag     in  varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2
  ,p_dpnt_cvg_no_ctfn_rqd_flag      in  varchar2
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2
  ,p_rt_end_dt_cd            in  varchar2
  ,p_rt_strt_dt_cd            in  varchar2
  ,p_enrt_cvg_end_dt_cd            in  varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  number
  ,p_dpnt_cvg_end_dt_cd             in  varchar2
  ,p_dpnt_cvg_end_dt_rl             in  number
  ,p_dpnt_adrs_rqd_flag             in  varchar2
  ,p_dpnt_legv_id_rqd_flag          in  varchar2
  ,p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2
  ,p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2
  ,p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2
  ,p_susp_if_ctfn_not_dpnt_flag     in  varchar2
  ,p_dpnt_ctfn_determine_cd         in  varchar2
  ,p_postelcn_edit_rl               in  number
  ,p_rt_end_dt_rl               in  number
  ,p_rt_strt_dt_rl               in  number
  ,p_enrt_cvg_end_dt_rl               in  number
  ,p_enrt_cvg_strt_dt_rl               in  number
  ,p_rqd_perd_enrt_nenrt_rl               in  number
  ,p_auto_enrt_mthd_rl              in   number
  ,p_enrt_mthd_cd                   in   varchar2
  ,p_enrt_cd                        in   varchar2
  ,p_enrt_rl                        in   number
  ,p_dflt_enrt_cd                   in   varchar2
  ,p_dflt_enrt_det_rl               in   number
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2
  ,p_elig_apls_flag                 in  varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2
  ,p_trk_inelig_per_flag            in  varchar2
  ,p_dpnt_dob_rqd_flag              in  varchar2
  ,p_crs_this_pl_typ_only_flag      in  varchar2
  ,p_ptip_stat_cd                   in  varchar2
  ,p_mx_cvg_alwd_amt                in  number
  ,p_mx_enrd_alwd_ovrid_num         in  number
  ,p_mn_enrd_rqd_ovrid_num          in  number
  ,p_no_mx_pl_typ_ovrid_flag        in  varchar2
  ,p_ordr_num                       in  number
  ,p_prvds_cr_flag                  in  varchar2
  ,p_rqd_perd_enrt_nenrt_val        in  number
  ,p_rqd_perd_enrt_nenrt_tm_uom     in  varchar2
  ,p_wvbl_flag                      in  varchar2
  ,p_drvd_fctr_dpnt_cvg_flag        in  varchar2
  ,p_no_mn_pl_typ_overid_flag       in  varchar2
  ,p_sbj_to_sps_lf_ins_mx_flag      in  varchar2
  ,p_sbj_to_dpnt_lf_ins_mx_flag     in  varchar2
  ,p_use_to_sum_ee_lf_ins_flag      in  varchar2
  ,p_per_cvrd_cd                    in varchar2
  ,p_short_name                    in varchar2
  ,p_short_code                    in varchar2
    ,p_legislation_code                    in varchar2
    ,p_legislation_subgroup                    in varchar2
  ,p_vrfy_fmly_mmbr_cd              in varchar2
  ,p_vrfy_fmly_mmbr_rl              in number
  ,p_ivr_ident                      in  varchar2
  ,p_url_ref_name                   in  varchar2
  ,p_rqd_enrt_perd_tco_cd           in  varchar2
  ,p_pgm_id                         in  number
  ,p_pl_typ_id                      in  number
  ,p_cmbn_ptip_id                   in  number
  ,p_cmbn_ptip_opt_id               in  number
  ,p_acrs_ptip_cvg_id               in  number
  ,p_business_group_id              in  number
  ,p_ctp_attribute_category         in  varchar2
  ,p_ctp_attribute1                 in  varchar2
  ,p_ctp_attribute2                 in  varchar2
  ,p_ctp_attribute3                 in  varchar2
  ,p_ctp_attribute4                 in  varchar2
  ,p_ctp_attribute5                 in  varchar2
  ,p_ctp_attribute6                 in  varchar2
  ,p_ctp_attribute7                 in  varchar2
  ,p_ctp_attribute8                 in  varchar2
  ,p_ctp_attribute9                 in  varchar2
  ,p_ctp_attribute10                in  varchar2
  ,p_ctp_attribute11                in  varchar2
  ,p_ctp_attribute12                in  varchar2
  ,p_ctp_attribute13                in  varchar2
  ,p_ctp_attribute14                in  varchar2
  ,p_ctp_attribute15                in  varchar2
  ,p_ctp_attribute16                in  varchar2
  ,p_ctp_attribute17                in  varchar2
  ,p_ctp_attribute18                in  varchar2
  ,p_ctp_attribute19                in  varchar2
  ,p_ctp_attribute20                in  varchar2
  ,p_ctp_attribute21                in  varchar2
  ,p_ctp_attribute22                in  varchar2
  ,p_ctp_attribute23                in  varchar2
  ,p_ctp_attribute24                in  varchar2
  ,p_ctp_attribute25                in  varchar2
  ,p_ctp_attribute26                in  varchar2
  ,p_ctp_attribute27                in  varchar2
  ,p_ctp_attribute28                in  varchar2
  ,p_ctp_attribute29                in  varchar2
  ,p_ctp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Plan_Type_In_Program_bk2;

 

/
