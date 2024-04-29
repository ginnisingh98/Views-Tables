--------------------------------------------------------
--  DDL for Package BEN_BFT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BFT_RKD" AUTHID CURRENT_USER as
/* $Header: bebftrhi.pkh 120.0 2005/05/28 00:40:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_benefit_action_id              in number
 ,p_process_date_o                 in date
 ,p_uneai_effective_date_o         in date
 ,p_mode_cd_o                      in varchar2
 ,p_derivable_factors_flag_o       in varchar2
 ,p_close_uneai_flag_o             in varchar2
 ,p_validate_flag_o                in varchar2
 ,p_person_id_o                    in number
 ,p_person_type_id_o               in number
 ,p_pgm_id_o                       in number
 ,p_business_group_id_o            in number
 ,p_pl_id_o                        in number
 ,p_popl_enrt_typ_cycl_id_o        in number
 ,p_no_programs_flag_o             in varchar2
 ,p_no_plans_flag_o                in varchar2
 ,p_comp_selection_rl_o            in number
 ,p_person_selection_rl_o          in number
 ,p_ler_id_o                       in number
 ,p_organization_id_o              in number
 ,p_benfts_grp_id_o                in number
 ,p_location_id_o                  in number
 ,p_pstl_zip_rng_id_o              in number
 ,p_rptg_grp_id_o                  in number
 ,p_pl_typ_id_o                    in number
 ,p_opt_id_o                       in number
 ,p_eligy_prfl_id_o                in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_legal_entity_id_o              in number
 ,p_payroll_id_o                   in number
 ,p_debug_messages_flag_o          in varchar2
 ,p_cm_trgr_typ_cd_o               in varchar2
 ,p_cm_typ_id_o                    in number
 ,p_age_fctr_id_o                  in number
 ,p_min_age_o                      in number
 ,p_max_age_o                      in number
 ,p_los_fctr_id_o                  in number
 ,p_min_los_o                      in number
 ,p_max_los_o                      in number
 ,p_cmbn_age_los_fctr_id_o         in number
 ,p_min_cmbn_o                     in number
 ,p_max_cmbn_o                     in number
 ,p_date_from_o                    in date
 ,p_elig_enrol_cd_o                in varchar2
 ,p_actn_typ_id_o                  in number
 ,p_use_fctr_to_sel_flag_o         in varchar2
 ,p_los_det_to_use_cd_o            in varchar2
 ,p_audit_log_flag_o               in varchar2
 ,p_lmt_prpnip_by_org_flag_o       in varchar2
 ,p_lf_evt_ocrd_dt_o               in date
 ,p_ptnl_ler_for_per_stat_cd_o     in varchar2
 ,p_bft_attribute_category_o       in varchar2
 ,p_bft_attribute1_o               in varchar2
 ,p_bft_attribute3_o               in varchar2
 ,p_bft_attribute4_o               in varchar2
 ,p_bft_attribute5_o               in varchar2
 ,p_bft_attribute6_o               in varchar2
 ,p_bft_attribute7_o               in varchar2
 ,p_bft_attribute8_o               in varchar2
 ,p_bft_attribute9_o               in varchar2
 ,p_bft_attribute10_o              in varchar2
 ,p_bft_attribute11_o              in varchar2
 ,p_bft_attribute12_o              in varchar2
 ,p_bft_attribute13_o              in varchar2
 ,p_bft_attribute14_o              in varchar2
 ,p_bft_attribute15_o              in varchar2
 ,p_bft_attribute16_o              in varchar2
 ,p_bft_attribute17_o              in varchar2
 ,p_bft_attribute18_o              in varchar2
 ,p_bft_attribute19_o              in varchar2
 ,p_bft_attribute20_o              in varchar2
 ,p_bft_attribute21_o              in varchar2
 ,p_bft_attribute22_o              in varchar2
 ,p_bft_attribute23_o              in varchar2
 ,p_bft_attribute24_o              in varchar2
 ,p_bft_attribute25_o              in varchar2
 ,p_bft_attribute26_o              in varchar2
 ,p_bft_attribute27_o              in varchar2
 ,p_bft_attribute28_o              in varchar2
 ,p_bft_attribute29_o              in varchar2
 ,p_bft_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_enrt_perd_id_o                 in number
 ,p_inelg_action_cd_o              in varchar2
 ,p_org_hierarchy_id_o              in number
 ,p_org_starting_node_id_o              in number
 ,p_grade_ladder_id_o              in number
 ,p_asg_events_to_all_sel_dt_o              in varchar2
 ,p_rate_id_o              in number
 ,p_per_sel_dt_cd_o              in varchar2
 ,p_per_sel_freq_cd_o              in varchar2
 ,p_per_sel_dt_from_o              in date
 ,p_per_sel_dt_to_o              in date
 ,p_year_from_o              in number
 ,p_year_to_o              in number
 ,p_cagr_id_o              in number
 ,p_qual_type_o              in number
 ,p_qual_status_o              in varchar2
 ,p_concat_segs_o              in varchar2
 ,p_grant_price_val_o              in number
  );
--
end ben_bft_rkd;

 

/
