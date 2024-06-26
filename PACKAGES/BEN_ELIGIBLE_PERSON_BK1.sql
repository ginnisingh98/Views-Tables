--------------------------------------------------------
--  DDL for Package BEN_ELIGIBLE_PERSON_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGIBLE_PERSON_BK1" AUTHID CURRENT_USER as
/* $Header: bepepapi.pkh 120.0 2005/05/28 10:39:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Eligible_Person_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Eligible_Person_b
  (p_business_group_id              in  number
  ,p_pl_id                          in  number
  ,p_pgm_id                         in  number
  ,p_plip_id                        in  number
  ,p_ptip_id                        in  number
  ,p_ler_id                         in  number
  ,p_person_id                      in  number
  ,p_per_in_ler_id                      in  number
  ,p_dpnt_othr_pl_cvrd_rl_flag      in  varchar2
  ,p_prtn_ovridn_thru_dt            in  date
  ,p_pl_key_ee_flag                 in  varchar2
  ,p_pl_hghly_compd_flag            in  varchar2
  ,p_elig_flag                      in  varchar2
  ,p_comp_ref_amt                   in  number
  ,p_cmbn_age_n_los_val             in  number
  ,p_comp_ref_uom                   in  varchar2
  ,p_age_val                        in  number
  ,p_los_val                        in  number
  ,p_prtn_end_dt                    in  date
  ,p_prtn_strt_dt                   in  date
  ,p_wait_perd_cmpltn_dt            in  date
  ,p_wait_perd_strt_dt              in  date
  ,p_wv_ctfn_typ_cd                 in  varchar2
  ,p_hrs_wkd_val                    in  number
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2
  ,p_prtn_ovridn_flag               in  varchar2
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2
  ,p_prtn_ovridn_rsn_cd             in  varchar2
  ,p_age_uom                        in  varchar2
  ,p_los_uom                        in  varchar2
  ,p_ovrid_svc_dt                   in  date
  ,p_inelg_rsn_cd                   in  varchar2
  ,p_frz_los_flag                   in  varchar2
  ,p_frz_age_flag                   in  varchar2
  ,p_frz_cmp_lvl_flag               in  varchar2
  ,p_frz_pct_fl_tm_flag             in  varchar2
  ,p_frz_hrs_wkd_flag               in  varchar2
  ,p_frz_comb_age_and_los_flag      in  varchar2
  ,p_dstr_rstcn_flag                in  varchar2
  ,p_pct_fl_tm_val                  in  number
  ,p_wv_prtn_rsn_cd                 in  varchar2
  ,p_pl_wvd_flag                    in  varchar2
  ,p_rt_comp_ref_amt                in  number
  ,p_rt_cmbn_age_n_los_val          in  number
  ,p_rt_comp_ref_uom                in  varchar2
  ,p_rt_age_val                     in  number
  ,p_rt_los_val                     in  number
  ,p_rt_hrs_wkd_val                 in  number
  ,p_rt_hrs_wkd_bndry_perd_cd       in  varchar2
  ,p_rt_age_uom                     in  varchar2
  ,p_rt_los_uom                     in  varchar2
  ,p_rt_pct_fl_tm_val               in  number
  ,p_rt_frz_los_flag                in  varchar2
  ,p_rt_frz_age_flag                in  varchar2
  ,p_rt_frz_cmp_lvl_flag            in  varchar2
  ,p_rt_frz_pct_fl_tm_flag          in  varchar2
  ,p_rt_frz_hrs_wkd_flag            in  varchar2
  ,p_rt_frz_comb_age_and_los_flag   in  varchar2
  ,p_once_r_cntug_cd                in  varchar2
  ,p_pl_ordr_num                    in  number
  ,p_plip_ordr_num                    in  number
  ,p_ptip_ordr_num                    in  number
  ,p_pep_attribute_category         in  varchar2
  ,p_pep_attribute1                 in  varchar2
  ,p_pep_attribute2                 in  varchar2
  ,p_pep_attribute3                 in  varchar2
  ,p_pep_attribute4                 in  varchar2
  ,p_pep_attribute5                 in  varchar2
  ,p_pep_attribute6                 in  varchar2
  ,p_pep_attribute7                 in  varchar2
  ,p_pep_attribute8                 in  varchar2
  ,p_pep_attribute9                 in  varchar2
  ,p_pep_attribute10                in  varchar2
  ,p_pep_attribute11                in  varchar2
  ,p_pep_attribute12                in  varchar2
  ,p_pep_attribute13                in  varchar2
  ,p_pep_attribute14                in  varchar2
  ,p_pep_attribute15                in  varchar2
  ,p_pep_attribute16                in  varchar2
  ,p_pep_attribute17                in  varchar2
  ,p_pep_attribute18                in  varchar2
  ,p_pep_attribute19                in  varchar2
  ,p_pep_attribute20                in  varchar2
  ,p_pep_attribute21                in  varchar2
  ,p_pep_attribute22                in  varchar2
  ,p_pep_attribute23                in  varchar2
  ,p_pep_attribute24                in  varchar2
  ,p_pep_attribute25                in  varchar2
  ,p_pep_attribute26                in  varchar2
  ,p_pep_attribute27                in  varchar2
  ,p_pep_attribute28                in  varchar2
  ,p_pep_attribute29                in  varchar2
  ,p_pep_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Eligible_Person_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Eligible_Person_a
  (p_elig_per_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_pl_id                          in  number
  ,p_pgm_id                         in  number
  ,p_plip_id                        in  number
  ,p_ptip_id                        in  number
  ,p_ler_id                         in  number
  ,p_person_id                      in  number
  ,p_per_in_ler_id                      in  number
  ,p_dpnt_othr_pl_cvrd_rl_flag      in  varchar2
  ,p_prtn_ovridn_thru_dt            in  date
  ,p_pl_key_ee_flag                 in  varchar2
  ,p_pl_hghly_compd_flag            in  varchar2
  ,p_elig_flag                      in  varchar2
  ,p_comp_ref_amt                   in  number
  ,p_cmbn_age_n_los_val             in  number
  ,p_comp_ref_uom                   in  varchar2
  ,p_age_val                        in  number
  ,p_los_val                        in  number
  ,p_prtn_end_dt                    in  date
  ,p_prtn_strt_dt                   in  date
  ,p_wait_perd_cmpltn_dt            in  date
  ,p_wait_perd_strt_dt              in  date
  ,p_wv_ctfn_typ_cd                 in  varchar2
  ,p_hrs_wkd_val                    in  number
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2
  ,p_prtn_ovridn_flag               in  varchar2
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2
  ,p_prtn_ovridn_rsn_cd             in  varchar2
  ,p_age_uom                        in  varchar2
  ,p_los_uom                        in  varchar2
  ,p_ovrid_svc_dt                   in  date
  ,p_inelg_rsn_cd                   in  varchar2
  ,p_frz_los_flag                   in  varchar2
  ,p_frz_age_flag                   in  varchar2
  ,p_frz_cmp_lvl_flag               in  varchar2
  ,p_frz_pct_fl_tm_flag             in  varchar2
  ,p_frz_hrs_wkd_flag               in  varchar2
  ,p_frz_comb_age_and_los_flag      in  varchar2
  ,p_dstr_rstcn_flag                in  varchar2
  ,p_pct_fl_tm_val                  in  number
  ,p_wv_prtn_rsn_cd                 in  varchar2
  ,p_pl_wvd_flag                    in  varchar2
  ,p_rt_comp_ref_amt                in  number
  ,p_rt_cmbn_age_n_los_val          in  number
  ,p_rt_comp_ref_uom                in  varchar2
  ,p_rt_age_val                     in  number
  ,p_rt_los_val                     in  number
  ,p_rt_hrs_wkd_val                 in  number
  ,p_rt_hrs_wkd_bndry_perd_cd       in  varchar2
  ,p_rt_age_uom                     in  varchar2
  ,p_rt_los_uom                     in  varchar2
  ,p_rt_pct_fl_tm_val               in  number
  ,p_rt_frz_los_flag                in  varchar2
  ,p_rt_frz_age_flag                in  varchar2
  ,p_rt_frz_cmp_lvl_flag            in  varchar2
  ,p_rt_frz_pct_fl_tm_flag          in  varchar2
  ,p_rt_frz_hrs_wkd_flag            in  varchar2
  ,p_rt_frz_comb_age_and_los_flag   in  varchar2
  ,p_once_r_cntug_cd                in  varchar2
  ,p_pl_ordr_num                    in  number
  ,p_plip_ordr_num                    in  number
  ,p_ptip_ordr_num                    in  number
  ,p_pep_attribute_category         in  varchar2
  ,p_pep_attribute1                 in  varchar2
  ,p_pep_attribute2                 in  varchar2
  ,p_pep_attribute3                 in  varchar2
  ,p_pep_attribute4                 in  varchar2
  ,p_pep_attribute5                 in  varchar2
  ,p_pep_attribute6                 in  varchar2
  ,p_pep_attribute7                 in  varchar2
  ,p_pep_attribute8                 in  varchar2
  ,p_pep_attribute9                 in  varchar2
  ,p_pep_attribute10                in  varchar2
  ,p_pep_attribute11                in  varchar2
  ,p_pep_attribute12                in  varchar2
  ,p_pep_attribute13                in  varchar2
  ,p_pep_attribute14                in  varchar2
  ,p_pep_attribute15                in  varchar2
  ,p_pep_attribute16                in  varchar2
  ,p_pep_attribute17                in  varchar2
  ,p_pep_attribute18                in  varchar2
  ,p_pep_attribute19                in  varchar2
  ,p_pep_attribute20                in  varchar2
  ,p_pep_attribute21                in  varchar2
  ,p_pep_attribute22                in  varchar2
  ,p_pep_attribute23                in  varchar2
  ,p_pep_attribute24                in  varchar2
  ,p_pep_attribute25                in  varchar2
  ,p_pep_attribute26                in  varchar2
  ,p_pep_attribute27                in  varchar2
  ,p_pep_attribute28                in  varchar2
  ,p_pep_attribute29                in  varchar2
  ,p_pep_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_Eligible_Person_bk1;

 

/
