--------------------------------------------------------
--  DDL for Package BEN_PLAN_IN_PROGRAM_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_IN_PROGRAM_BK2" AUTHID CURRENT_USER as
/* $Header: becppapi.pkh 120.0 2005/05/28 01:16:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_in_Program_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_in_Program_b
  (
   p_plip_id                        in  number
  ,p_dflt_flag                      in  varchar2
  ,p_plip_stat_cd                   in  varchar2
  ,p_dflt_enrt_cd                   in  varchar2
  ,p_dflt_enrt_det_rl               in  number
  ,p_ordr_num                       in  number
  ,p_ivr_ident                      in  varchar2
  ,p_enrt_cd                        in  varchar2
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_auto_enrt_mthd_rl              in  number
  ,p_enrt_rl                        in  number
  ,p_alws_unrstrctd_enrt_flag       in  varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number
  ,p_enrt_cvg_end_dt_cd             in  varchar2
  ,p_enrt_cvg_end_dt_rl             in  number
  ,p_rt_strt_dt_cd                  in  varchar2
  ,p_rt_strt_dt_rl                  in  number
  ,p_rt_end_dt_cd                   in  varchar2
  ,p_rt_end_dt_rl                   in  number
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2
  ,p_elig_apls_flag                 in  varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2
  ,p_trk_inelig_per_flag            in  varchar2
  ,p_postelcn_edit_rl               in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_cmbn_plip_id                   in  number
  ,p_business_group_id              in  number
  ,p_per_cvrd_cd                    in  varchar2
  ,p_short_name                    in  varchar2
  ,p_short_code                    in  varchar2
    ,p_legislation_code                    in  varchar2
    ,p_legislation_subgroup                    in  varchar2
  ,P_vrfy_fmly_mmbr_rl              in  number
  ,P_vrfy_fmly_mmbr_cd              in  varchar2
  ,P_use_csd_rsd_prccng_cd          in  varchar2
  ,p_cpp_attribute_category         in  varchar2
  ,p_cpp_attribute1                 in  varchar2
  ,p_cpp_attribute2                 in  varchar2
  ,p_cpp_attribute3                 in  varchar2
  ,p_cpp_attribute4                 in  varchar2
  ,p_cpp_attribute5                 in  varchar2
  ,p_cpp_attribute6                 in  varchar2
  ,p_cpp_attribute7                 in  varchar2
  ,p_cpp_attribute8                 in  varchar2
  ,p_cpp_attribute9                 in  varchar2
  ,p_cpp_attribute10                in  varchar2
  ,p_cpp_attribute11                in  varchar2
  ,p_cpp_attribute12                in  varchar2
  ,p_cpp_attribute13                in  varchar2
  ,p_cpp_attribute14                in  varchar2
  ,p_cpp_attribute15                in  varchar2
  ,p_cpp_attribute16                in  varchar2
  ,p_cpp_attribute17                in  varchar2
  ,p_cpp_attribute18                in  varchar2
  ,p_cpp_attribute19                in  varchar2
  ,p_cpp_attribute20                in  varchar2
  ,p_cpp_attribute21                in  varchar2
  ,p_cpp_attribute22                in  varchar2
  ,p_cpp_attribute23                in  varchar2
  ,p_cpp_attribute24                in  varchar2
  ,p_cpp_attribute25                in  varchar2
  ,p_cpp_attribute26                in  varchar2
  ,p_cpp_attribute27                in  varchar2
  ,p_cpp_attribute28                in  varchar2
  ,p_cpp_attribute29                in  varchar2
  ,p_cpp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_url_ref_name                   in  varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number
  ,p_mn_cvg_amt                     in  number
  ,p_mn_cvg_rl                      in  number
  ,p_mx_cvg_alwd_amt                in  number
  ,p_mx_cvg_incr_alwd_amt           in  number
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number
  ,p_mx_cvg_mlt_incr_num            in  number
  ,p_mx_cvg_mlt_incr_wcf_num        in  number
  ,p_mx_cvg_rl                      in  number
  ,p_mx_cvg_wcfn_amt                in  number
  ,p_mx_cvg_wcfn_mlt_num            in  number
  ,p_no_mn_cvg_amt_apls_flag        in  varchar2
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2
  ,p_unsspnd_enrt_cd                in  varchar2
  ,p_prort_prtl_yr_cvg_rstrn_cd     in  varchar2
  ,p_prort_prtl_yr_cvg_rstrn_rl     in  number
  ,p_cvg_incr_r_decr_only_cd        in  varchar2
  ,p_bnft_or_option_rstrctn_cd      in  varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_in_Program_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_in_Program_a
  (
   p_plip_id                        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_dflt_flag                      in  varchar2
  ,p_plip_stat_cd                   in  varchar2
  ,p_dflt_enrt_cd                   in  varchar2
  ,p_dflt_enrt_det_rl               in  number
  ,p_ordr_num                       in  number
  ,p_ivr_ident                      in  varchar2
  ,p_enrt_cd                        in  varchar2
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_auto_enrt_mthd_rl              in  number
  ,p_enrt_rl                        in  number
  ,p_alws_unrstrctd_enrt_flag       in  varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number
  ,p_enrt_cvg_end_dt_cd             in  varchar2
  ,p_enrt_cvg_end_dt_rl             in  number
  ,p_rt_strt_dt_cd                  in  varchar2
  ,p_rt_strt_dt_rl                  in  number
  ,p_rt_end_dt_cd                   in  varchar2
  ,p_rt_end_dt_rl                   in  number
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2
  ,p_elig_apls_flag                 in  varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2
  ,p_trk_inelig_per_flag            in  varchar2
  ,p_postelcn_edit_rl               in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_cmbn_plip_id                   in  number
  ,p_business_group_id              in  number
  ,p_per_cvrd_cd                    in  varchar2
  ,p_short_name                    in  varchar2
  ,p_short_code                    in  varchar2
    ,p_legislation_code                    in  varchar2
    ,p_legislation_subgroup                    in  varchar2
  ,P_vrfy_fmly_mmbr_rl              in  number
  ,P_vrfy_fmly_mmbr_cd              in  varchar2
  ,P_use_csd_rsd_prccng_cd          in  varchar2
  ,p_cpp_attribute_category         in  varchar2
  ,p_cpp_attribute1                 in  varchar2
  ,p_cpp_attribute2                 in  varchar2
  ,p_cpp_attribute3                 in  varchar2
  ,p_cpp_attribute4                 in  varchar2
  ,p_cpp_attribute5                 in  varchar2
  ,p_cpp_attribute6                 in  varchar2
  ,p_cpp_attribute7                 in  varchar2
  ,p_cpp_attribute8                 in  varchar2
  ,p_cpp_attribute9                 in  varchar2
  ,p_cpp_attribute10                in  varchar2
  ,p_cpp_attribute11                in  varchar2
  ,p_cpp_attribute12                in  varchar2
  ,p_cpp_attribute13                in  varchar2
  ,p_cpp_attribute14                in  varchar2
  ,p_cpp_attribute15                in  varchar2
  ,p_cpp_attribute16                in  varchar2
  ,p_cpp_attribute17                in  varchar2
  ,p_cpp_attribute18                in  varchar2
  ,p_cpp_attribute19                in  varchar2
  ,p_cpp_attribute20                in  varchar2
  ,p_cpp_attribute21                in  varchar2
  ,p_cpp_attribute22                in  varchar2
  ,p_cpp_attribute23                in  varchar2
  ,p_cpp_attribute24                in  varchar2
  ,p_cpp_attribute25                in  varchar2
  ,p_cpp_attribute26                in  varchar2
  ,p_cpp_attribute27                in  varchar2
  ,p_cpp_attribute28                in  varchar2
  ,p_cpp_attribute29                in  varchar2
  ,p_cpp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_url_ref_name                   in  varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number
  ,p_mn_cvg_amt                     in  number
  ,p_mn_cvg_rl                      in  number
  ,p_mx_cvg_alwd_amt                in  number
  ,p_mx_cvg_incr_alwd_amt           in  number
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number
  ,p_mx_cvg_mlt_incr_num            in  number
  ,p_mx_cvg_mlt_incr_wcf_num        in  number
  ,p_mx_cvg_rl                      in  number
  ,p_mx_cvg_wcfn_amt                in  number
  ,p_mx_cvg_wcfn_mlt_num            in  number
  ,p_no_mn_cvg_amt_apls_flag        in  varchar2
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2
  ,p_unsspnd_enrt_cd                in  varchar2
  ,p_prort_prtl_yr_cvg_rstrn_cd     in  varchar2
  ,p_prort_prtl_yr_cvg_rstrn_rl     in  number
  ,p_cvg_incr_r_decr_only_cd        in  varchar2
  ,p_bnft_or_option_rstrctn_cd      in  varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Plan_in_Program_bk2;

 

/
