--------------------------------------------------------
--  DDL for Package BEN_PEP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEP_RKD" AUTHID CURRENT_USER as
/* $Header: bepeprhi.pkh 120.0 2005/05/28 10:40:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_per_id                    in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_pl_id_o                        in number
 ,p_pgm_id_o                       in number
 ,p_plip_id_o                      in number
 ,p_ptip_id_o                      in number
 ,p_ler_id_o                       in number
 ,p_person_id_o                    in number
 ,p_per_in_ler_id_o                    in number
 ,p_dpnt_othr_pl_cvrd_rl_flag_o    in varchar2
 ,p_prtn_ovridn_thru_dt_o          in date
 ,p_pl_key_ee_flag_o               in varchar2
 ,p_pl_hghly_compd_flag_o          in varchar2
 ,p_elig_flag_o                    in varchar2
 ,p_comp_ref_amt_o                 in number
 ,p_cmbn_age_n_los_val_o           in number
 ,p_comp_ref_uom_o                 in varchar2
 ,p_age_val_o                      in number
 ,p_los_val_o                      in number
 ,p_prtn_end_dt_o                  in date
 ,p_prtn_strt_dt_o                 in date
 ,p_wait_perd_cmpltn_dt_o          in date
 ,p_wait_perd_strt_dt_o            in date
 ,p_wv_ctfn_typ_cd_o               in varchar2
 ,p_hrs_wkd_val_o                  in number
 ,p_hrs_wkd_bndry_perd_cd_o        in varchar2
 ,p_prtn_ovridn_flag_o             in varchar2
 ,p_no_mx_prtn_ovrid_thru_flag_o   in varchar2
 ,p_prtn_ovridn_rsn_cd_o           in varchar2
 ,p_age_uom_o                      in varchar2
 ,p_los_uom_o                      in varchar2
 ,p_ovrid_svc_dt_o                 in date
 ,p_inelg_rsn_cd_o                 in varchar2
 ,p_frz_los_flag_o                 in varchar2
 ,p_frz_age_flag_o                 in varchar2
 ,p_frz_cmp_lvl_flag_o             in varchar2
 ,p_frz_pct_fl_tm_flag_o           in varchar2
 ,p_frz_hrs_wkd_flag_o             in varchar2
 ,p_frz_comb_age_and_los_flag_o    in varchar2
 ,p_dstr_rstcn_flag_o              in varchar2
 ,p_pct_fl_tm_val_o                in number
 ,p_wv_prtn_rsn_cd_o               in varchar2
 ,p_pl_wvd_flag_o                  in varchar2
 ,p_rt_comp_ref_amt_o              in number
 ,p_rt_cmbn_age_n_los_val_o        in number
 ,p_rt_comp_ref_uom_o              in varchar2
 ,p_rt_age_val_o                   in number
 ,p_rt_los_val_o                   in number
 ,p_rt_hrs_wkd_val_o               in number
 ,p_rt_hrs_wkd_bndry_perd_cd_o     in varchar2
 ,p_rt_age_uom_o                   in varchar2
 ,p_rt_los_uom_o                   in varchar2
 ,p_rt_pct_fl_tm_val_o             in number
 ,p_rt_frz_los_flag_o              in varchar2
 ,p_rt_frz_age_flag_o              in varchar2
 ,p_rt_frz_cmp_lvl_flag_o          in varchar2
 ,p_rt_frz_pct_fl_tm_flag_o        in varchar2
 ,p_rt_frz_hrs_wkd_flag_o          in varchar2
 ,p_rt_frz_comb_age_and_los_fl_o   in varchar2
 ,p_once_r_cntug_cd_o              in varchar2
 ,p_pl_ordr_num_o                    in number
 ,p_plip_ordr_num_o                  in number
 ,p_ptip_ordr_num_o                  in number
 ,p_pep_attribute_category_o       in varchar2
 ,p_pep_attribute1_o               in varchar2
 ,p_pep_attribute2_o               in varchar2
 ,p_pep_attribute3_o               in varchar2
 ,p_pep_attribute4_o               in varchar2
 ,p_pep_attribute5_o               in varchar2
 ,p_pep_attribute6_o               in varchar2
 ,p_pep_attribute7_o               in varchar2
 ,p_pep_attribute8_o               in varchar2
 ,p_pep_attribute9_o               in varchar2
 ,p_pep_attribute10_o              in varchar2
 ,p_pep_attribute11_o              in varchar2
 ,p_pep_attribute12_o              in varchar2
 ,p_pep_attribute13_o              in varchar2
 ,p_pep_attribute14_o              in varchar2
 ,p_pep_attribute15_o              in varchar2
 ,p_pep_attribute16_o              in varchar2
 ,p_pep_attribute17_o              in varchar2
 ,p_pep_attribute18_o              in varchar2
 ,p_pep_attribute19_o              in varchar2
 ,p_pep_attribute20_o              in varchar2
 ,p_pep_attribute21_o              in varchar2
 ,p_pep_attribute22_o              in varchar2
 ,p_pep_attribute23_o              in varchar2
 ,p_pep_attribute24_o              in varchar2
 ,p_pep_attribute25_o              in varchar2
 ,p_pep_attribute26_o              in varchar2
 ,p_pep_attribute27_o              in varchar2
 ,p_pep_attribute28_o              in varchar2
 ,p_pep_attribute29_o              in varchar2
 ,p_pep_attribute30_o              in varchar2
 ,p_request_id_o                   in  number
 ,p_program_application_id_o       in  number
 ,p_program_id_o                   in  number
 ,p_program_update_date_o          in  date
 ,p_object_version_number_o        in number
  );
--
end ben_pep_rkd;

 

/
