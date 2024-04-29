--------------------------------------------------------
--  DDL for Package BEN_ABR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABR_RKD" AUTHID CURRENT_USER as
/* $Header: beabrrhi.pkh 120.7 2008/05/15 06:23:00 pvelvano noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_acty_base_rt_id                in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o			   in number
 ,p_acty_typ_cd_o                  in varchar2
 ,p_sub_acty_typ_cd_o              in varchar2
 ,p_name_o                         in varchar2
 ,p_rt_typ_cd_o                    in varchar2
 ,p_bnft_rt_typ_cd_o               in varchar2
 ,p_tx_typ_cd_o                    in varchar2
 ,p_use_to_calc_net_flx_cr_fla_o  in varchar2
 ,p_asn_on_enrt_flag_o             in varchar2
 ,p_abv_mx_elcn_val_alwd_flag_o    in varchar2
 ,p_blw_mn_elcn_alwd_flag_o        in varchar2
 ,p_dsply_on_enrt_flag_o           in varchar2
 ,p_parnt_chld_cd_o                in varchar2
 ,p_use_calc_acty_bs_rt_flag_o     in varchar2
 ,p_uses_ded_sched_flag_o          in varchar2
 ,p_uses_varbl_rt_flag_o           in varchar2
 ,p_vstg_sched_apls_flag_o         in varchar2
 ,p_rt_mlt_cd_o                    in varchar2
 ,p_proc_each_pp_dflt_flag_o       in varchar2
 ,p_prdct_flx_cr_when_elig_fla_o  in varchar2
 ,p_no_std_rt_used_flag_o          in varchar2
 ,p_rcrrg_cd_o                     in varchar2
 ,p_mn_elcn_val_o                  in number
 ,p_mx_elcn_val_o                  in number
 ,p_lwr_lmt_val_o                  in number
 ,p_lwr_lmt_calc_rl_o              in number
 ,p_upr_lmt_val_o                  in number
 ,p_upr_lmt_calc_rl_o              in number
 ,p_ptd_comp_lvl_fctr_id_o         in number
 ,p_clm_comp_lvl_fctr_id_o         in number
 ,p_entr_ann_val_flag_o            in varchar2
 ,p_ann_mn_elcn_val_o              in number
 ,p_ann_mx_elcn_val_o              in number
 ,p_wsh_rl_dy_mo_num_o             in number
 ,p_uses_pymt_sched_flag_o         in varchar2
 ,p_nnmntry_uom_o                  in varchar2
 ,p_val_o                          in number
 ,p_incrmt_elcn_val_o              in number
 ,p_rndg_cd_o                      in varchar2
 ,p_val_ovrid_alwd_flag_o          in varchar2
 ,p_prtl_mo_det_mthd_cd_o          in varchar2
 ,p_acty_base_rt_stat_cd_o         in varchar2
 ,p_procg_src_cd_o                 in varchar2
 ,p_dflt_val_o                     in number
 ,p_dflt_flag_o                    in varchar2
 ,p_frgn_erg_ded_typ_cd_o          in varchar2
 ,p_frgn_erg_ded_name_o            in varchar2
 ,p_frgn_erg_ded_ident_o           in varchar2
 ,p_no_mx_elcn_val_dfnd_flag_o     in varchar2
 ,p_prtl_mo_det_mthd_rl_o          in number
 ,p_entr_val_at_enrt_flag_o        in varchar2
 ,p_prtl_mo_eff_dt_det_rl_o        in number
 ,p_rndg_rl_o                      in number
 ,p_val_calc_rl_o                  in number
 ,p_no_mn_elcn_val_dfnd_flag_o     in varchar2
 ,p_prtl_mo_eff_dt_det_cd_o        in varchar2
 ,p_only_one_bal_typ_alwd_flag_o   in varchar2
 ,p_rt_usg_cd_o                    in varchar2
 ,p_prort_mn_ann_elcn_val_cd_o     in varchar2
 ,p_prort_mn_ann_elcn_val_rl_o     in number
 ,p_prort_mx_ann_elcn_val_cd_o     in varchar2
 ,p_prort_mx_ann_elcn_val_rl_o     in number
 ,p_one_ann_pymt_cd_o              in varchar2
 ,p_det_pl_ytd_cntrs_cd_o          in varchar2
 ,p_asmt_to_use_cd_o               in varchar2
 ,p_ele_rqd_flag_o                 in varchar2
 ,p_subj_to_imptd_incm_flag_o      in varchar2
 ,p_element_type_id_o              in number
 ,p_input_value_id_o               in number
 ,p_input_va_calc_rl_o             in number
 ,p_comp_lvl_fctr_id_o             in number
 ,p_parnt_acty_base_rt_id_o        in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_oipl_id_o                      in number
 ,p_opt_id_o                       in number
 ,p_oiplip_id_o                    in number
 ,p_plip_id_o                      in number
 ,p_ptip_id_o                      in number
 ,p_cmbn_plip_id_o                 in number
 ,p_cmbn_ptip_id_o                 in number
 ,p_cmbn_ptip_opt_id_o             in number
 ,p_vstg_for_acty_rt_id_o          in number
 ,p_actl_prem_id_o                 in number
 ,p_TTL_COMP_LVL_FCTR_ID_o         in number
 ,p_COST_ALLOCATION_KEYFLEX_ID_o   in number
 ,p_ALWS_CHG_CD_o                  in varchar2
 ,p_ele_entry_val_cd_o             in varchar2
 ,p_pay_rate_grade_rule_id_o       in number
 ,p_rate_periodization_cd_o             in varchar2
 ,p_rate_periodization_rl_o             in number
 ,p_mn_mx_elcn_rl_o 		   in number
 ,p_mapping_table_name_o           in varchar2
 ,p_mapping_table_pk_id_o          in number
 ,p_business_group_id_o            in number
 ,p_context_pgm_id_o               in number
 ,p_context_pl_id_o                in number
 ,p_context_opt_id_o               in number
 ,p_element_det_rl_o               in number
 ,p_currency_det_cd_o              in varchar2
 ,p_abr_attribute_category_o       in varchar2
 ,p_abr_attribute1_o               in varchar2
 ,p_abr_attribute2_o               in varchar2
 ,p_abr_attribute3_o               in varchar2
 ,p_abr_attribute4_o               in varchar2
 ,p_abr_attribute5_o               in varchar2
 ,p_abr_attribute6_o               in varchar2
 ,p_abr_attribute7_o               in varchar2
 ,p_abr_attribute8_o               in varchar2
 ,p_abr_attribute9_o               in varchar2
 ,p_abr_attribute10_o              in varchar2
 ,p_abr_attribute11_o              in varchar2
 ,p_abr_attribute12_o              in varchar2
 ,p_abr_attribute13_o              in varchar2
 ,p_abr_attribute14_o              in varchar2
 ,p_abr_attribute15_o              in varchar2
 ,p_abr_attribute16_o              in varchar2
 ,p_abr_attribute17_o              in varchar2
 ,p_abr_attribute18_o              in varchar2
 ,p_abr_attribute19_o              in varchar2
 ,p_abr_attribute20_o              in varchar2
 ,p_abr_attribute21_o              in varchar2
 ,p_abr_attribute22_o              in varchar2
 ,p_abr_attribute23_o              in varchar2
 ,p_abr_attribute24_o              in varchar2
 ,p_abr_attribute25_o              in varchar2
 ,p_abr_attribute26_o              in varchar2
 ,p_abr_attribute27_o              in varchar2
 ,p_abr_attribute28_o              in varchar2
 ,p_abr_attribute29_o              in varchar2
 ,p_abr_attribute30_o              in varchar2
 ,p_abr_seq_num_o                  in  number
 ,p_object_version_number_o        in number
  );
--
end ben_abr_rkd;

/
