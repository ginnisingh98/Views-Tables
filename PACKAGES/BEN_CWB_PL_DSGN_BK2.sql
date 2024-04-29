--------------------------------------------------------
--  DDL for Package BEN_CWB_PL_DSGN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PL_DSGN_BK2" AUTHID CURRENT_USER as
/* $Header: becpdapi.pkh 120.3.12010000.4 2010/03/12 06:07:31 sgnanama ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_plan_or_opption_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_plan_or_option_b
  (p_pl_id                          in     number
  ,p_oipl_id                        in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_effective_date                 in     date
  ,p_name                           in     varchar2
  ,p_group_pl_id                    in     number
  ,p_group_oipl_id                  in     number
  ,p_opt_hidden_flag                in     varchar2
  ,p_opt_id                         in     number
  ,p_pl_uom                         in     varchar2
  ,p_pl_ordr_num                    in     number
  ,p_oipl_ordr_num                  in     number
  ,p_pl_xchg_rate                   in     number
  ,p_opt_count                      in     number
  ,p_uses_bdgt_flag                 in     varchar2
  ,p_prsrv_bdgt_cd                  in     varchar2
  ,p_upd_start_dt                   in     date
  ,p_upd_end_dt                     in     date
  ,p_approval_mode                  in     varchar2
  ,p_enrt_perd_start_dt             in     date
  ,p_enrt_perd_end_dt               in     date
  ,p_yr_perd_start_dt               in     date
  ,p_yr_perd_end_dt                 in     date
  ,p_wthn_yr_start_dt               in     date
  ,p_wthn_yr_end_dt                 in     date
  ,p_enrt_perd_id                   in     number
  ,p_yr_perd_id                     in     number
  ,p_business_group_id              in     number
  ,p_perf_revw_strt_dt              in     date
  ,p_asg_updt_eff_date              in     date
  ,p_emp_interview_typ_cd           in     varchar2
  ,p_salary_change_reason           in     varchar2
  ,p_ws_abr_id                      in     number
  ,p_ws_nnmntry_uom                 in     varchar2
  ,p_ws_rndg_cd                     in     varchar2
  ,p_ws_sub_acty_typ_cd             in     varchar2
  ,p_dist_bdgt_abr_id               in     number
  ,p_dist_bdgt_nnmntry_uom          in     varchar2
  ,p_dist_bdgt_rndg_cd              in     varchar2
  ,p_ws_bdgt_abr_id                 in     number
  ,p_ws_bdgt_nnmntry_uom            in     varchar2
  ,p_ws_bdgt_rndg_cd                in     varchar2
  ,p_rsrv_abr_id                    in     number
  ,p_rsrv_nnmntry_uom               in     varchar2
  ,p_rsrv_rndg_cd                   in     varchar2
  ,p_elig_sal_abr_id                in     number
  ,p_elig_sal_nnmntry_uom           in     varchar2
  ,p_elig_sal_rndg_cd               in     varchar2
  ,p_misc1_abr_id                   in     number
  ,p_misc1_nnmntry_uom              in     varchar2
  ,p_misc1_rndg_cd                  in     varchar2
  ,p_misc2_abr_id                   in     number
  ,p_misc2_nnmntry_uom              in     varchar2
  ,p_misc2_rndg_cd                  in     varchar2
  ,p_misc3_abr_id                   in     number
  ,p_misc3_nnmntry_uom              in     varchar2
  ,p_misc3_rndg_cd                  in     varchar2
  ,p_stat_sal_abr_id                in     number
  ,p_stat_sal_nnmntry_uom           in     varchar2
  ,p_stat_sal_rndg_cd               in     varchar2
  ,p_rec_abr_id                     in     number
  ,p_rec_nnmntry_uom                in     varchar2
  ,p_rec_rndg_cd                    in     varchar2
  ,p_tot_comp_abr_id                in     number
  ,p_tot_comp_nnmntry_uom           in     varchar2
  ,p_tot_comp_rndg_cd               in     varchar2
  ,p_oth_comp_abr_id                in     number
  ,p_oth_comp_nnmntry_uom           in     varchar2
  ,p_oth_comp_rndg_cd               in     varchar2
  ,p_actual_flag                    in     varchar2
  ,p_acty_ref_perd_cd               in     varchar2
  ,p_legislation_code               in     varchar2
  ,p_pl_annulization_factor         in     number
  ,p_pl_stat_cd                     in     varchar2
  ,p_uom_precision                  in     number
  ,p_ws_element_type_id             in     number
  ,p_ws_input_value_id              in     number
  ,p_data_freeze_date               in     date
  ,p_ws_amt_edit_cd                 in     varchar2
  ,p_ws_amt_edit_enf_cd_for_nul     in     varchar2
  ,p_ws_over_budget_edit_cd         in     varchar2
  ,p_ws_over_budget_tol_pct         in     number
  ,p_bdgt_over_budget_edit_cd       in     varchar2
  ,p_bdgt_over_budget_tol_pct       in     number
  ,p_auto_distr_flag                in     varchar2
  ,p_pqh_document_short_name        in     varchar2
  ,p_ovrid_rt_strt_dt               in     date
  ,p_do_not_process_flag            in     varchar2
  ,p_ovr_perf_revw_strt_dt          in     date
  ,p_post_zero_salary_increase           in     varchar2
  ,p_show_appraisals_n_days              in     number
  ,p_grade_range_validation         in  varchar2
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_plan_or_option_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_plan_or_option_a
  (p_pl_id                          in     number
  ,p_oipl_id                        in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_effective_date                 in     date
  ,p_name                           in     varchar2
  ,p_group_pl_id                    in     number
  ,p_group_oipl_id                  in     number
  ,p_opt_hidden_flag                in     varchar2
  ,p_opt_id                         in     number
  ,p_pl_uom                         in     varchar2
  ,p_pl_ordr_num                    in     number
  ,p_oipl_ordr_num                  in     number
  ,p_pl_xchg_rate                   in     number
  ,p_opt_count                      in     number
  ,p_uses_bdgt_flag                 in     varchar2
  ,p_prsrv_bdgt_cd                  in     varchar2
  ,p_upd_start_dt                   in     date
  ,p_upd_end_dt                     in     date
  ,p_approval_mode                  in     varchar2
  ,p_enrt_perd_start_dt             in     date
  ,p_enrt_perd_end_dt               in     date
  ,p_yr_perd_start_dt               in     date
  ,p_yr_perd_end_dt                 in     date
  ,p_wthn_yr_start_dt               in     date
  ,p_wthn_yr_end_dt                 in     date
  ,p_enrt_perd_id                   in     number
  ,p_yr_perd_id                     in     number
  ,p_business_group_id              in     number
  ,p_perf_revw_strt_dt              in     date
  ,p_asg_updt_eff_date              in     date
  ,p_emp_interview_typ_cd           in     varchar2
  ,p_salary_change_reason           in     varchar2
  ,p_ws_abr_id                      in     number
  ,p_ws_nnmntry_uom                 in     varchar2
  ,p_ws_rndg_cd                     in     varchar2
  ,p_ws_sub_acty_typ_cd             in     varchar2
  ,p_dist_bdgt_abr_id               in     number
  ,p_dist_bdgt_nnmntry_uom          in     varchar2
  ,p_dist_bdgt_rndg_cd              in     varchar2
  ,p_ws_bdgt_abr_id                 in     number
  ,p_ws_bdgt_nnmntry_uom            in     varchar2
  ,p_ws_bdgt_rndg_cd                in     varchar2
  ,p_rsrv_abr_id                    in     number
  ,p_rsrv_nnmntry_uom               in     varchar2
  ,p_rsrv_rndg_cd                   in     varchar2
  ,p_elig_sal_abr_id                in     number
  ,p_elig_sal_nnmntry_uom           in     varchar2
  ,p_elig_sal_rndg_cd               in     varchar2
  ,p_misc1_abr_id                   in     number
  ,p_misc1_nnmntry_uom              in     varchar2
  ,p_misc1_rndg_cd                  in     varchar2
  ,p_misc2_abr_id                   in     number
  ,p_misc2_nnmntry_uom              in     varchar2
  ,p_misc2_rndg_cd                  in     varchar2
  ,p_misc3_abr_id                   in     number
  ,p_misc3_nnmntry_uom              in     varchar2
  ,p_misc3_rndg_cd                  in     varchar2
  ,p_stat_sal_abr_id                in     number
  ,p_stat_sal_nnmntry_uom           in     varchar2
  ,p_stat_sal_rndg_cd               in     varchar2
  ,p_rec_abr_id                     in     number
  ,p_rec_nnmntry_uom                in     varchar2
  ,p_rec_rndg_cd                    in     varchar2
  ,p_tot_comp_abr_id                in     number
  ,p_tot_comp_nnmntry_uom           in     varchar2
  ,p_tot_comp_rndg_cd               in     varchar2
  ,p_oth_comp_abr_id                in     number
  ,p_oth_comp_nnmntry_uom           in     varchar2
  ,p_oth_comp_rndg_cd               in     varchar2
  ,p_actual_flag                    in     varchar2
  ,p_acty_ref_perd_cd               in     varchar2
  ,p_legislation_code               in     varchar2
  ,p_pl_annulization_factor         in     number
  ,p_pl_stat_cd                     in     varchar2
  ,p_uom_precision                  in     number
  ,p_ws_element_type_id             in     number
  ,p_ws_input_value_id              in     number
  ,p_data_freeze_date               in     date
  ,p_ws_amt_edit_cd                 in     varchar2
  ,p_ws_amt_edit_enf_cd_for_nul     in     varchar2
  ,p_ws_over_budget_edit_cd         in     varchar2
  ,p_ws_over_budget_tol_pct         in     number
  ,p_bdgt_over_budget_edit_cd       in     varchar2
  ,p_bdgt_over_budget_tol_pct       in     number
  ,p_auto_distr_flag                in     varchar2
  ,p_pqh_document_short_name        in     varchar2
  ,p_ovrid_rt_strt_dt               in     date
  ,p_do_not_process_flag            in     varchar2
  ,p_ovr_perf_revw_strt_dt          in     date
  ,p_post_zero_salary_increase           in     varchar2
  ,p_show_appraisals_n_days              in     number
  ,p_grade_range_validation         in  varchar2
  ,p_object_version_number          in     number
  );
--
end BEN_CWB_PL_DSGN_BK2;

/