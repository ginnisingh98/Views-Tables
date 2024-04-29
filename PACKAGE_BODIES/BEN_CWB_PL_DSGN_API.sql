--------------------------------------------------------
--  DDL for Package Body BEN_CWB_PL_DSGN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_PL_DSGN_API" as
/* $Header: becpdapi.pkb 120.1.12010000.3 2010/03/12 06:09:24 sgnanama ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  BEN_CWB_PL_DSGN_API.';
g_debug boolean := hr_utility.debug_enabled;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_plan_or_option >------------------------|
-- ----------------------------------------------------------------------------
procedure create_plan_or_option
  (p_validate                          in     boolean  default false
  ,p_pl_id                             in     number
  ,p_oipl_id                           in     number
  ,p_lf_evt_ocrd_dt                    in     date
  ,p_effective_date                    in     date      default null
  ,p_name                              in     varchar2  default null
  ,p_group_pl_id                       in     number    default null
  ,p_group_oipl_id                     in     number    default null
  ,p_opt_hidden_flag                   in     varchar2  default null
  ,p_opt_id                            in     number    default null
  ,p_pl_uom                            in     varchar2  default null
  ,p_pl_ordr_num                       in     number    default null
  ,p_oipl_ordr_num                     in     number    default null
  ,p_pl_xchg_rate                      in     number    default null
  ,p_opt_count                         in     number    default null
  ,p_uses_bdgt_flag                    in     varchar2  default null
  ,p_prsrv_bdgt_cd                     in     varchar2  default null
  ,p_upd_start_dt                      in     date      default null
  ,p_upd_end_dt                        in     date      default null
  ,p_approval_mode                     in     varchar2  default null
  ,p_enrt_perd_start_dt                in     date      default null
  ,p_enrt_perd_end_dt                  in     date      default null
  ,p_yr_perd_start_dt                  in     date      default null
  ,p_yr_perd_end_dt                    in     date      default null
  ,p_wthn_yr_start_dt                  in     date      default null
  ,p_wthn_yr_end_dt                    in     date      default null
  ,p_enrt_perd_id                      in     number    default null
  ,p_yr_perd_id                        in     number    default null
  ,p_business_group_id                 in     number    default null
  ,p_perf_revw_strt_dt                 in     date      default null
  ,p_asg_updt_eff_date                 in     date      default null
  ,p_emp_interview_typ_cd              in     varchar2  default null
  ,p_salary_change_reason              in     varchar2  default null
  ,p_ws_abr_id                         in     number    default null
  ,p_ws_nnmntry_uom                    in     varchar2  default null
  ,p_ws_rndg_cd                        in     varchar2  default null
  ,p_ws_sub_acty_typ_cd                in     varchar2  default null
  ,p_dist_bdgt_abr_id                  in     number    default null
  ,p_dist_bdgt_nnmntry_uom             in     varchar2  default null
  ,p_dist_bdgt_rndg_cd                 in     varchar2  default null
  ,p_ws_bdgt_abr_id                    in     number    default null
  ,p_ws_bdgt_nnmntry_uom               in     varchar2  default null
  ,p_ws_bdgt_rndg_cd                   in     varchar2  default null
  ,p_rsrv_abr_id                       in     number    default null
  ,p_rsrv_nnmntry_uom                  in     varchar2  default null
  ,p_rsrv_rndg_cd                      in     varchar2  default null
  ,p_elig_sal_abr_id                   in     number    default null
  ,p_elig_sal_nnmntry_uom              in     varchar2  default null
  ,p_elig_sal_rndg_cd                  in     varchar2  default null
  ,p_misc1_abr_id                      in     number    default null
  ,p_misc1_nnmntry_uom                 in     varchar2  default null
  ,p_misc1_rndg_cd                     in     varchar2  default null
  ,p_misc2_abr_id                      in     number    default null
  ,p_misc2_nnmntry_uom                 in     varchar2  default null
  ,p_misc2_rndg_cd                     in     varchar2  default null
  ,p_misc3_abr_id                      in     number    default null
  ,p_misc3_nnmntry_uom                 in     varchar2  default null
  ,p_misc3_rndg_cd                     in     varchar2  default null
  ,p_stat_sal_abr_id                   in     number    default null
  ,p_stat_sal_nnmntry_uom              in     varchar2  default null
  ,p_stat_sal_rndg_cd                  in     varchar2  default null
  ,p_rec_abr_id                        in     number    default null
  ,p_rec_nnmntry_uom                   in     varchar2  default null
  ,p_rec_rndg_cd                       in     varchar2  default null
  ,p_tot_comp_abr_id                   in     number    default null
  ,p_tot_comp_nnmntry_uom              in     varchar2  default null
  ,p_tot_comp_rndg_cd                  in     varchar2  default null
  ,p_oth_comp_abr_id                   in     number    default null
  ,p_oth_comp_nnmntry_uom              in     varchar2  default null
  ,p_oth_comp_rndg_cd                  in     varchar2  default null
  ,p_actual_flag                       in     varchar2  default null
  ,p_acty_ref_perd_cd                  in     varchar2  default null
  ,p_legislation_code                  in     varchar2  default null
  ,p_pl_annulization_factor            in     number    default null
  ,p_pl_stat_cd                        in     varchar2  default null
  ,p_uom_precision                     in     number    default null
  ,p_ws_element_type_id                in     number    default null
  ,p_ws_input_value_id                 in     number    default null
  ,p_data_freeze_date                  in     date      default null
  ,p_ws_amt_edit_cd                    in     varchar2  default null
  ,p_ws_amt_edit_enf_cd_for_nul        in     varchar2  default null
  ,p_ws_over_budget_edit_cd            in     varchar2  default null
  ,p_ws_over_budget_tol_pct            in     number    default null
  ,p_bdgt_over_budget_edit_cd          in     varchar2  default null
  ,p_bdgt_over_budget_tol_pct          in     number    default null
  ,p_auto_distr_flag                   in     varchar2  default null
  ,p_pqh_document_short_name           in     varchar2  default null
  ,p_ovrid_rt_strt_dt                  in     date      default null
  ,p_do_not_process_flag               in     varchar2  default null
  ,p_ovr_perf_revw_strt_dt             in     date      default null
  ,p_post_zero_salary_increase         in     varchar2  default null
  ,p_show_appraisals_n_days            in     number    default null
  ,p_grade_range_validation            in     varchar2  default null
  ,p_object_version_number             out    nocopy number
  ) is
  --
  l_object_version_number number;
  --
  l_proc                varchar2(72) := g_package||'create_plan_or_option';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_plan_or_option;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_pl_dsgn_bk1.create_plan_or_option_b
        (p_pl_id                          => p_pl_id
        ,p_oipl_id                        => p_oipl_id
        ,p_lf_evt_ocrd_dt                 => p_lf_evt_ocrd_dt
        ,p_effective_date                 => p_effective_date
        ,p_name                           => p_name
        ,p_group_pl_id                    => p_group_pl_id
        ,p_group_oipl_id                  => p_group_oipl_id
        ,p_opt_hidden_flag                => p_opt_hidden_flag
        ,p_opt_id                         => p_opt_id
        ,p_pl_uom                         => p_pl_uom
        ,p_pl_ordr_num                    => p_pl_ordr_num
        ,p_oipl_ordr_num                  => p_oipl_ordr_num
        ,p_pl_xchg_rate                   => p_pl_xchg_rate
        ,p_opt_count                      => p_opt_count
        ,p_uses_bdgt_flag                 => p_uses_bdgt_flag
        ,p_prsrv_bdgt_cd                  => p_prsrv_bdgt_cd
        ,p_upd_start_dt                   => p_upd_start_dt
        ,p_upd_end_dt                     => p_upd_end_dt
        ,p_approval_mode                  => p_approval_mode
        ,p_enrt_perd_start_dt             => p_enrt_perd_start_dt
        ,p_enrt_perd_end_dt               => p_enrt_perd_end_dt
        ,p_yr_perd_start_dt               => p_yr_perd_start_dt
        ,p_yr_perd_end_dt                 => p_yr_perd_end_dt
        ,p_wthn_yr_start_dt               => p_wthn_yr_start_dt
        ,p_wthn_yr_end_dt                 => p_wthn_yr_end_dt
        ,p_enrt_perd_id                   => p_enrt_perd_id
        ,p_yr_perd_id                     => p_yr_perd_id
        ,p_business_group_id              => p_business_group_id
        ,p_perf_revw_strt_dt              => p_perf_revw_strt_dt
        ,p_asg_updt_eff_date              => p_asg_updt_eff_date
        ,p_emp_interview_typ_cd           => p_emp_interview_typ_cd
        ,p_salary_change_reason           => p_salary_change_reason
        ,p_ws_abr_id                      => p_ws_abr_id
        ,p_ws_nnmntry_uom                 => p_ws_nnmntry_uom
        ,p_ws_rndg_cd                     => p_ws_rndg_cd
        ,p_ws_sub_acty_typ_cd             => p_ws_sub_acty_typ_cd
        ,p_dist_bdgt_abr_id               => p_dist_bdgt_abr_id
        ,p_dist_bdgt_nnmntry_uom          => p_dist_bdgt_nnmntry_uom
        ,p_dist_bdgt_rndg_cd              => p_dist_bdgt_rndg_cd
        ,p_ws_bdgt_abr_id                 => p_ws_bdgt_abr_id
        ,p_ws_bdgt_nnmntry_uom            => p_ws_bdgt_nnmntry_uom
        ,p_ws_bdgt_rndg_cd                => p_ws_bdgt_rndg_cd
        ,p_rsrv_abr_id                    => p_rsrv_abr_id
        ,p_rsrv_nnmntry_uom               => p_rsrv_nnmntry_uom
        ,p_rsrv_rndg_cd                   => p_rsrv_rndg_cd
        ,p_elig_sal_abr_id                => p_elig_sal_abr_id
        ,p_elig_sal_nnmntry_uom           => p_elig_sal_nnmntry_uom
        ,p_elig_sal_rndg_cd               => p_elig_sal_rndg_cd
        ,p_misc1_abr_id                   => p_misc1_abr_id
        ,p_misc1_nnmntry_uom              => p_misc1_nnmntry_uom
        ,p_misc1_rndg_cd                  => p_misc1_rndg_cd
        ,p_misc2_abr_id                   => p_misc2_abr_id
        ,p_misc2_nnmntry_uom              => p_misc2_nnmntry_uom
        ,p_misc2_rndg_cd                  => p_misc2_rndg_cd
        ,p_misc3_abr_id                   => p_misc3_abr_id
        ,p_misc3_nnmntry_uom              => p_misc3_nnmntry_uom
        ,p_misc3_rndg_cd                  => p_misc3_rndg_cd
        ,p_stat_sal_abr_id                => p_stat_sal_abr_id
        ,p_stat_sal_nnmntry_uom           => p_stat_sal_nnmntry_uom
        ,p_stat_sal_rndg_cd               => p_stat_sal_rndg_cd
        ,p_rec_abr_id                     => p_rec_abr_id
        ,p_rec_nnmntry_uom                => p_rec_nnmntry_uom
        ,p_rec_rndg_cd                    => p_rec_rndg_cd
        ,p_tot_comp_abr_id                => p_tot_comp_abr_id
        ,p_tot_comp_nnmntry_uom           => p_tot_comp_nnmntry_uom
        ,p_tot_comp_rndg_cd               => p_tot_comp_rndg_cd
        ,p_oth_comp_abr_id                => p_oth_comp_abr_id
        ,p_oth_comp_nnmntry_uom           => p_oth_comp_nnmntry_uom
        ,p_oth_comp_rndg_cd               => p_oth_comp_rndg_cd
        ,p_actual_flag                    => p_actual_flag
        ,p_acty_ref_perd_cd               => p_acty_ref_perd_cd
        ,p_legislation_code               => p_legislation_code
        ,p_pl_annulization_factor         => p_pl_annulization_factor
        ,p_pl_stat_cd                     => p_pl_stat_cd
        ,p_uom_precision                  => p_uom_precision
        ,p_ws_element_type_id             => p_ws_element_type_id
        ,p_ws_input_value_id              => p_ws_input_value_id
        ,p_data_freeze_date               => p_data_freeze_date
        ,p_ws_amt_edit_cd                 => p_ws_amt_edit_cd
        ,p_ws_amt_edit_enf_cd_for_nul     => p_ws_amt_edit_enf_cd_for_nul
        ,p_ws_over_budget_edit_cd         => p_ws_over_budget_edit_cd
        ,p_ws_over_budget_tol_pct         => p_ws_over_budget_tol_pct
        ,p_bdgt_over_budget_edit_cd       => p_bdgt_over_budget_edit_cd
        ,p_bdgt_over_budget_tol_pct       => p_bdgt_over_budget_tol_pct
        ,p_auto_distr_flag                => p_auto_distr_flag
        ,p_pqh_document_short_name        => p_pqh_document_short_name
        ,p_ovrid_rt_strt_dt               => p_ovrid_rt_strt_dt
        ,p_do_not_process_flag            => p_do_not_process_flag
	,p_ovr_perf_revw_strt_dt          => p_ovr_perf_revw_strt_dt
	,p_post_zero_salary_increase      => p_post_zero_salary_increase
        ,p_show_appraisals_n_days         => p_show_appraisals_n_days
	,p_grade_range_validation         => p_grade_range_validation
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_plan_or_option'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ben_cpd_ins.ins
        (p_pl_id                          => p_pl_id
        ,p_oipl_id                        => p_oipl_id
        ,p_lf_evt_ocrd_dt                 => p_lf_evt_ocrd_dt
        ,p_effective_date                 => p_effective_date
        ,p_name                           => p_name
        ,p_group_pl_id                    => p_group_pl_id
        ,p_group_oipl_id                  => p_group_oipl_id
        ,p_opt_hidden_flag                => p_opt_hidden_flag
        ,p_opt_id                         => p_opt_id
        ,p_pl_uom                         => p_pl_uom
        ,p_pl_ordr_num                    => p_pl_ordr_num
        ,p_oipl_ordr_num                  => p_oipl_ordr_num
        ,p_pl_xchg_rate                   => p_pl_xchg_rate
        ,p_opt_count                      => p_opt_count
        ,p_uses_bdgt_flag                 => p_uses_bdgt_flag
        ,p_prsrv_bdgt_cd                  => p_prsrv_bdgt_cd
        ,p_upd_start_dt                   => p_upd_start_dt
        ,p_upd_end_dt                     => p_upd_end_dt
        ,p_approval_mode                  => p_approval_mode
        ,p_enrt_perd_start_dt             => p_enrt_perd_start_dt
        ,p_enrt_perd_end_dt               => p_enrt_perd_end_dt
        ,p_yr_perd_start_dt               => p_yr_perd_start_dt
        ,p_yr_perd_end_dt                 => p_yr_perd_end_dt
        ,p_wthn_yr_start_dt               => p_wthn_yr_start_dt
        ,p_wthn_yr_end_dt                 => p_wthn_yr_end_dt
        ,p_enrt_perd_id                   => p_enrt_perd_id
        ,p_yr_perd_id                     => p_yr_perd_id
        ,p_business_group_id              => p_business_group_id
        ,p_perf_revw_strt_dt              => p_perf_revw_strt_dt
        ,p_asg_updt_eff_date              => p_asg_updt_eff_date
        ,p_emp_interview_typ_cd           => p_emp_interview_typ_cd
        ,p_salary_change_reason           => p_salary_change_reason
        ,p_ws_abr_id                      => p_ws_abr_id
        ,p_ws_nnmntry_uom                 => p_ws_nnmntry_uom
        ,p_ws_rndg_cd                     => p_ws_rndg_cd
        ,p_ws_sub_acty_typ_cd             => p_ws_sub_acty_typ_cd
        ,p_dist_bdgt_abr_id               => p_dist_bdgt_abr_id
        ,p_dist_bdgt_nnmntry_uom          => p_dist_bdgt_nnmntry_uom
        ,p_dist_bdgt_rndg_cd              => p_dist_bdgt_rndg_cd
        ,p_ws_bdgt_abr_id                 => p_ws_bdgt_abr_id
        ,p_ws_bdgt_nnmntry_uom            => p_ws_bdgt_nnmntry_uom
        ,p_ws_bdgt_rndg_cd                => p_ws_bdgt_rndg_cd
        ,p_rsrv_abr_id                    => p_rsrv_abr_id
        ,p_rsrv_nnmntry_uom               => p_rsrv_nnmntry_uom
        ,p_rsrv_rndg_cd                   => p_rsrv_rndg_cd
        ,p_elig_sal_abr_id                => p_elig_sal_abr_id
        ,p_elig_sal_nnmntry_uom           => p_elig_sal_nnmntry_uom
        ,p_elig_sal_rndg_cd               => p_elig_sal_rndg_cd
        ,p_misc1_abr_id                   => p_misc1_abr_id
        ,p_misc1_nnmntry_uom              => p_misc1_nnmntry_uom
        ,p_misc1_rndg_cd                  => p_misc1_rndg_cd
        ,p_misc2_abr_id                   => p_misc2_abr_id
        ,p_misc2_nnmntry_uom              => p_misc2_nnmntry_uom
        ,p_misc2_rndg_cd                  => p_misc2_rndg_cd
        ,p_misc3_abr_id                   => p_misc3_abr_id
        ,p_misc3_nnmntry_uom              => p_misc3_nnmntry_uom
        ,p_misc3_rndg_cd                  => p_misc3_rndg_cd
        ,p_stat_sal_abr_id                => p_stat_sal_abr_id
        ,p_stat_sal_nnmntry_uom           => p_stat_sal_nnmntry_uom
        ,p_stat_sal_rndg_cd               => p_stat_sal_rndg_cd
        ,p_rec_abr_id                     => p_rec_abr_id
        ,p_rec_nnmntry_uom                => p_rec_nnmntry_uom
        ,p_rec_rndg_cd                    => p_rec_rndg_cd
        ,p_tot_comp_abr_id                => p_tot_comp_abr_id
        ,p_tot_comp_nnmntry_uom           => p_tot_comp_nnmntry_uom
        ,p_tot_comp_rndg_cd               => p_tot_comp_rndg_cd
        ,p_oth_comp_abr_id                => p_oth_comp_abr_id
        ,p_oth_comp_nnmntry_uom           => p_oth_comp_nnmntry_uom
        ,p_oth_comp_rndg_cd               => p_oth_comp_rndg_cd
        ,p_actual_flag                    => p_actual_flag
        ,p_acty_ref_perd_cd               => p_acty_ref_perd_cd
        ,p_legislation_code               => p_legislation_code
        ,p_pl_annulization_factor         => p_pl_annulization_factor
        ,p_pl_stat_cd                     => p_pl_stat_cd
        ,p_uom_precision                  => p_uom_precision
        ,p_ws_element_type_id             => p_ws_element_type_id
        ,p_ws_input_value_id              => p_ws_input_value_id
        ,p_data_freeze_date               => p_data_freeze_date
        ,p_ws_amt_edit_cd                 => p_ws_amt_edit_cd
        ,p_ws_amt_edit_enf_cd_for_nul     => p_ws_amt_edit_enf_cd_for_nul
        ,p_ws_over_budget_edit_cd         => p_ws_over_budget_edit_cd
        ,p_ws_over_budget_tol_pct         => p_ws_over_budget_tol_pct
        ,p_bdgt_over_budget_edit_cd       => p_bdgt_over_budget_edit_cd
        ,p_bdgt_over_budget_tol_pct       => p_bdgt_over_budget_tol_pct
        ,p_auto_distr_flag                => p_auto_distr_flag
        ,p_pqh_document_short_name        => p_pqh_document_short_name
        ,p_ovrid_rt_strt_dt               => p_ovrid_rt_strt_dt
        ,p_do_not_process_flag            => p_do_not_process_flag
	,p_ovr_perf_revw_strt_dt          => p_ovr_perf_revw_strt_dt
	,p_post_zero_salary_increase      => p_post_zero_salary_increase
        ,p_show_appraisals_n_days         => p_show_appraisals_n_days
	,p_grade_range_validation         => p_grade_range_validation
        ,p_object_version_number          => l_object_version_number
        );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_pl_dsgn_bk1.create_plan_or_option_a
        (p_pl_id                          => p_pl_id
        ,p_oipl_id                        => p_oipl_id
        ,p_lf_evt_ocrd_dt                 => p_lf_evt_ocrd_dt
        ,p_effective_date                 => p_effective_date
        ,p_name                           => p_name
        ,p_group_pl_id                    => p_group_pl_id
        ,p_group_oipl_id                  => p_group_oipl_id
        ,p_opt_hidden_flag                => p_opt_hidden_flag
        ,p_opt_id                         => p_opt_id
        ,p_pl_uom                         => p_pl_uom
        ,p_pl_ordr_num                    => p_pl_ordr_num
        ,p_oipl_ordr_num                  => p_oipl_ordr_num
        ,p_pl_xchg_rate                   => p_pl_xchg_rate
        ,p_opt_count                      => p_opt_count
        ,p_uses_bdgt_flag                 => p_uses_bdgt_flag
        ,p_prsrv_bdgt_cd                  => p_prsrv_bdgt_cd
        ,p_upd_start_dt                   => p_upd_start_dt
        ,p_upd_end_dt                     => p_upd_end_dt
        ,p_approval_mode                  => p_approval_mode
        ,p_enrt_perd_start_dt             => p_enrt_perd_start_dt
        ,p_enrt_perd_end_dt               => p_enrt_perd_end_dt
        ,p_yr_perd_start_dt               => p_yr_perd_start_dt
        ,p_yr_perd_end_dt                 => p_yr_perd_end_dt
        ,p_wthn_yr_start_dt               => p_wthn_yr_start_dt
        ,p_wthn_yr_end_dt                 => p_wthn_yr_end_dt
        ,p_enrt_perd_id                   => p_enrt_perd_id
        ,p_yr_perd_id                     => p_yr_perd_id
        ,p_business_group_id              => p_business_group_id
        ,p_perf_revw_strt_dt              => p_perf_revw_strt_dt
        ,p_asg_updt_eff_date              => p_asg_updt_eff_date
        ,p_emp_interview_typ_cd           => p_emp_interview_typ_cd
        ,p_salary_change_reason           => p_salary_change_reason
        ,p_ws_abr_id                      => p_ws_abr_id
        ,p_ws_nnmntry_uom                 => p_ws_nnmntry_uom
        ,p_ws_rndg_cd                     => p_ws_rndg_cd
        ,p_ws_sub_acty_typ_cd             => p_ws_sub_acty_typ_cd
        ,p_dist_bdgt_abr_id               => p_dist_bdgt_abr_id
        ,p_dist_bdgt_nnmntry_uom          => p_dist_bdgt_nnmntry_uom
        ,p_dist_bdgt_rndg_cd              => p_dist_bdgt_rndg_cd
        ,p_ws_bdgt_abr_id                 => p_ws_bdgt_abr_id
        ,p_ws_bdgt_nnmntry_uom            => p_ws_bdgt_nnmntry_uom
        ,p_ws_bdgt_rndg_cd                => p_ws_bdgt_rndg_cd
        ,p_rsrv_abr_id                    => p_rsrv_abr_id
        ,p_rsrv_nnmntry_uom               => p_rsrv_nnmntry_uom
        ,p_rsrv_rndg_cd                   => p_rsrv_rndg_cd
        ,p_elig_sal_abr_id                => p_elig_sal_abr_id
        ,p_elig_sal_nnmntry_uom           => p_elig_sal_nnmntry_uom
        ,p_elig_sal_rndg_cd               => p_elig_sal_rndg_cd
        ,p_misc1_abr_id                   => p_misc1_abr_id
        ,p_misc1_nnmntry_uom              => p_misc1_nnmntry_uom
        ,p_misc1_rndg_cd                  => p_misc1_rndg_cd
        ,p_misc2_abr_id                   => p_misc2_abr_id
        ,p_misc2_nnmntry_uom              => p_misc2_nnmntry_uom
        ,p_misc2_rndg_cd                  => p_misc2_rndg_cd
        ,p_misc3_abr_id                   => p_misc3_abr_id
        ,p_misc3_nnmntry_uom              => p_misc3_nnmntry_uom
        ,p_misc3_rndg_cd                  => p_misc3_rndg_cd
        ,p_stat_sal_abr_id                => p_stat_sal_abr_id
        ,p_stat_sal_nnmntry_uom           => p_stat_sal_nnmntry_uom
        ,p_stat_sal_rndg_cd               => p_stat_sal_rndg_cd
        ,p_rec_abr_id                     => p_rec_abr_id
        ,p_rec_nnmntry_uom                => p_rec_nnmntry_uom
        ,p_rec_rndg_cd                    => p_rec_rndg_cd
        ,p_tot_comp_abr_id                => p_tot_comp_abr_id
        ,p_tot_comp_nnmntry_uom           => p_tot_comp_nnmntry_uom
        ,p_tot_comp_rndg_cd               => p_tot_comp_rndg_cd
        ,p_oth_comp_abr_id                => p_oth_comp_abr_id
        ,p_oth_comp_nnmntry_uom           => p_oth_comp_nnmntry_uom
        ,p_oth_comp_rndg_cd               => p_oth_comp_rndg_cd
        ,p_actual_flag                    => p_actual_flag
        ,p_acty_ref_perd_cd               => p_acty_ref_perd_cd
        ,p_legislation_code               => p_legislation_code
        ,p_pl_annulization_factor         => p_pl_annulization_factor
        ,p_pl_stat_cd                     => p_pl_stat_cd
        ,p_uom_precision                  => p_uom_precision
        ,p_ws_element_type_id             => p_ws_element_type_id
        ,p_ws_input_value_id              => p_ws_input_value_id
        ,p_data_freeze_date               => p_data_freeze_date
        ,p_ws_amt_edit_cd                 => p_ws_amt_edit_cd
        ,p_ws_amt_edit_enf_cd_for_nul     => p_ws_amt_edit_enf_cd_for_nul
        ,p_ws_over_budget_edit_cd         => p_ws_over_budget_edit_cd
        ,p_ws_over_budget_tol_pct         => p_ws_over_budget_tol_pct
        ,p_bdgt_over_budget_edit_cd       => p_bdgt_over_budget_edit_cd
        ,p_bdgt_over_budget_tol_pct       => p_bdgt_over_budget_tol_pct
        ,p_auto_distr_flag                => p_auto_distr_flag
        ,p_pqh_document_short_name        => p_pqh_document_short_name
        ,p_ovrid_rt_strt_dt               => p_ovrid_rt_strt_dt
        ,p_do_not_process_flag            => p_do_not_process_flag
	,p_ovr_perf_revw_strt_dt          => p_ovr_perf_revw_strt_dt
	,p_post_zero_salary_increase      => p_post_zero_salary_increase
        ,p_show_appraisals_n_days         => p_show_appraisals_n_days
	,p_grade_range_validation         => p_grade_range_validation
        ,p_object_version_number          => l_object_version_number
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_plan_or_option'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_plan_or_option;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_plan_or_option;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_plan_or_option;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< data_syncopation >---------------------------|
-- ----------------------------------------------------------------------------
-- This is an internal procedure called by update_plan_or_option. This
-- procedure makes sure that all the child rows get correct data from parent
-- rows.
--
procedure data_syncopation(p_pl_id                    in    number
                          ,p_oipl_id                  in    number
                          ,p_lf_evt_ocrd_dt           in    date
                          ,p_effective_date           in    date
                          ,p_group_pl_id              in    number
                          ,p_group_oipl_id            in    number
                          ,p_pl_uom                   in    varchar2
                          ,p_pl_ordr_num              in    varchar2
                          ,p_oipl_ordr_num            in    number
                          ,p_pl_xchg_rate             in    number
                          ,p_upd_start_dt             in    date
                          ,p_upd_end_dt               in    date
                          ,p_approval_mode            in    varchar2
                          ,p_enrt_perd_start_dt       in    date
                          ,p_enrt_perd_end_dt         in    date
                          ,p_yr_perd_start_dt         in    date
                          ,p_yr_perd_end_dt           in    date
                          ,p_wthn_yr_start_dt         in    date
                          ,p_wthn_yr_end_dt           in    date
                          ,p_business_group_id        in    number
                          ,p_perf_revw_strt_dt        in    date
                          ,p_asg_updt_eff_date        in    date
                          ,p_emp_interview_typ_cd     in    varchar2
                          ,p_salary_change_reason     in    varchar2
                          ,p_actual_flag              in    varchar2
                          ,p_acty_ref_perd_cd         in    varchar2
                          ,p_legislation_code         in    varchar2
                          ,p_pl_annulization_factor   in    number
                          ,p_pl_stat_cd               in    varchar2
                          ,p_uom_precision            in    number
                          ,p_data_freeze_date         in    date
                         ) is
-- cursor to fetch the local plans of a group plan
cursor csr_plans(p_group_pl_id number
                      ,p_lf_evt_ocrd_dt date) is
select pl_id
from ben_cwb_pl_dsgn
where group_pl_id = p_group_pl_id
and   pl_id <> group_pl_id       -- Exclude group plan
and   oipl_id = -1
and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;

-- cursor to fetch the options of a plan
cursor csr_options(p_pl_id    number
                  ,p_lf_evt_ocrd_dt date) is
select oipl_id
from ben_cwb_pl_dsgn
where pl_id = p_pl_id
and   oipl_id <> -1     -- Exclude Plans
and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;

-- cursor to fetch local option of a group plan
cursor csr_grp_pl_local_options(p_group_pl_id    number
                               ,p_lf_evt_ocrd_dt date) is
select pl_id
      ,oipl_id
from ben_cwb_pl_dsgn
where group_pl_id = p_group_pl_id
and   oipl_id <> -1     -- Exclude Plans
and   pl_id   <> p_group_pl_id   -- Exclude Group Options
and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;

-- cursor to fetch local option of a group option
cursor csr_grp_opt_local_options(p_group_pl_id    number
                                ,p_group_oipl_id  number
                                ,p_lf_evt_ocrd_dt date) is
select pl_id
      ,oipl_id
from ben_cwb_pl_dsgn
where group_pl_id = p_group_pl_id
and   oipl_id <> -1     -- Exclude Plans
and   pl_id   <> p_group_pl_id   -- Exclude Group Options
and   group_oipl_id = p_group_oipl_id
and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
--
   l_is_group_plan boolean;
   l_is_local_plan boolean;
   l_is_group_option boolean;
   l_ovn number;
--
   l_proc     varchar2(72) := g_package||'data_syncopation';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if(p_pl_id = p_group_pl_id) then
      -- Group Plan or Option
      if (p_oipl_id = -1) then
         -- Group Plan
         l_is_group_plan := true;
       else
         -- Group Option
         l_is_group_option := true;
       end if;
   else
      -- Local Plan or Option
      if (p_oipl_id = -1) then
         -- Local Plan
         l_is_local_plan := true;
      end if;
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   if (l_is_group_plan) then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --
      -- Pass the values of to local plan : group_pl_id, effective_date,
      -- upd_start_dt, upd_end_dt, approval_mode, enrt_perd_start-dt,
      -- enrt_perd_end_dt, yr_perd_start_dt, yr_perd_end_dt, wthn_yr_start_dt,
      -- wthn_yr_end_dt, perf_review_start_dt, asg_updt_eff_date,
      -- emp_interview_typ_cd, salary_change_reason
      for pl in csr_plans(p_pl_id, p_lf_evt_ocrd_dt)
      loop
         --
         if g_debug then
            hr_utility.set_location(l_proc, 40);
         end if;
         --
         select object_version_number
         into l_ovn
         from ben_cwb_pl_dsgn
         where pl_id = pl.pl_id
         and   oipl_id = -1
         and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
         --
         update_plan_or_option
              (p_call_data_syncopation        => 'N'     -- no recursive calls
              ,p_pl_id                        => pl.pl_id
              ,p_oipl_id                      => -1
              ,p_group_pl_id                  => p_group_pl_id
              ,p_lf_evt_ocrd_dt               => p_lf_evt_ocrd_dt
              ,p_effective_date               => p_effective_date
              ,p_upd_start_dt                 => p_upd_start_dt
              ,p_upd_end_dt                   => p_upd_end_dt
              ,p_approval_mode                => p_approval_mode
              ,p_enrt_perd_start_dt           => p_enrt_perd_start_dt
              ,p_enrt_perd_end_dt             => p_enrt_perd_end_dt
              ,p_yr_perd_start_dt             => p_yr_perd_start_dt
              ,p_yr_perd_end_dt               => p_yr_perd_end_dt
              ,p_wthn_yr_start_dt             => p_wthn_yr_start_dt
              ,p_wthn_yr_end_dt               => p_wthn_yr_end_dt
              ,p_perf_revw_strt_dt            => p_perf_revw_strt_dt
              ,p_asg_updt_eff_date            => p_asg_updt_eff_date
              ,p_emp_interview_typ_cd         => p_emp_interview_typ_cd
              ,p_salary_change_reason         => p_salary_change_reason
              ,p_data_freeze_date             => p_data_freeze_date
              ,p_object_version_number        => l_ovn);
      end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 50);
      end if;
      --
      -- Pass the values to the Group Option : effective_date, group_pl_id,
      --  pl_uom, pl_xchg_rate, business_group_id, actual_flag,
      -- acty_ref_perd_cd, legilsation_code, pl_annulization_factor,
      -- pl_stat_cd, uom_precision
      for oipl in csr_options(p_pl_id, p_lf_evt_ocrd_dt)
      loop
         --
         if g_debug then
            hr_utility.set_location(l_proc, 60);
         end if;
         --
         select object_version_number
         into l_ovn
         from ben_cwb_pl_dsgn
         where pl_id = p_pl_id
         and   oipl_id = oipl.oipl_id
         and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
         --
         update_plan_or_option
               (p_call_data_syncopation      => 'N'   -- no recursive calls
               ,p_pl_id                      => p_pl_id
               ,p_oipl_id                    => oipl.oipl_id
               ,p_lf_evt_ocrd_dt             => p_lf_evt_ocrd_dt
               ,p_effective_date             => p_effective_date
               ,p_group_pl_id                => p_group_pl_id
               ,p_pl_uom                     => p_pl_uom
               ,p_pl_xchg_rate               => p_pl_xchg_rate
               ,p_business_group_id          => p_business_group_id
               ,p_actual_flag                => p_actual_flag
               ,p_acty_ref_perd_cd           => p_acty_ref_perd_cd
               ,p_legislation_code           => p_legislation_code
               ,p_pl_annulization_factor     => p_pl_annulization_factor
               ,p_pl_stat_cd                 => p_pl_stat_cd
               ,p_uom_precision              => p_uom_precision
               ,p_object_version_number      => l_ovn);
      end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 70);
      end if;
      --
      -- Pass the following values to local options : effective_date,
      -- group_pl_id
      for opt in csr_grp_pl_local_options(p_pl_id, p_lf_evt_ocrd_dt)
      loop
         select object_version_number
         into l_ovn
         from ben_cwb_pl_dsgn
         where pl_id = opt.pl_id
         and   oipl_id = opt.oipl_id
         and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
         --
         update_plan_or_option
               (p_call_data_syncopation      => 'N'   -- no recursive calls
               ,p_pl_id                      => opt.pl_id
               ,p_oipl_id                    => opt.oipl_id
               ,p_lf_evt_ocrd_dt             => p_lf_evt_ocrd_dt
               ,p_effective_date             => p_effective_date
               ,p_group_pl_id                => p_group_pl_id
               ,p_object_version_number      => l_ovn);
      end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 80);
      end if;
      --
   elsif (l_is_local_plan) then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 90);
      end if;
      --
      -- Pass the following values to local option : effective_date,
      -- group_pl_id, pl_uom, pl_ordr_num, pl_xchg_rate, business_group_id,
      -- actual_flag, acty_ref_perd_cd, legislation_code,
      -- pl_annulization_factor, pl_stat_cd, uom_precision
      for oipl in csr_options(p_pl_id, p_lf_evt_ocrd_dt)
      loop
         select object_version_number
         into l_ovn
         from ben_cwb_pl_dsgn
         where pl_id = p_pl_id
         and   oipl_id = oipl.oipl_id
         and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
         --
         update_plan_or_option
               (p_call_data_syncopation      => 'N'   -- no recursive calls
               ,p_pl_id                      => p_pl_id
               ,p_oipl_id                    => oipl.oipl_id
               ,p_lf_evt_ocrd_dt             => p_lf_evt_ocrd_dt
               ,p_effective_date             => p_effective_date
               ,p_group_pl_id                => p_group_pl_id
               ,p_pl_uom                     => p_pl_uom
               ,p_pl_ordr_num                => p_pl_ordr_num
               ,p_pl_xchg_rate               => p_pl_xchg_rate
               ,p_business_group_id          => p_business_group_id
               ,p_actual_flag                => p_actual_flag
               ,p_acty_ref_perd_cd           => p_acty_ref_perd_cd
               ,p_legislation_code           => p_legislation_code
               ,p_pl_annulization_factor     => p_pl_annulization_factor
               ,p_pl_stat_cd                 => p_pl_stat_cd
               ,p_uom_precision              => p_uom_precision
               ,p_object_version_number      => l_ovn);
      end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 100);
      end if;
      --
   elsif (l_is_group_option) then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 110);
      end if;
      --
      -- Pass the following values to local option : effective_date,
      -- group_pl_id, group_oipl_id, oipl_ordr_num
      for opt in csr_grp_opt_local_options(p_pl_id
                                          ,p_oipl_id
                                          ,p_lf_evt_ocrd_dt)
      loop
         select object_version_number
         into l_ovn
         from ben_cwb_pl_dsgn
         where pl_id = opt.pl_id
         and   oipl_id = opt.oipl_id
         and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
         --
         update_plan_or_option
               (p_call_data_syncopation      => 'N'   -- no recursive calls
               ,p_pl_id                      => opt.pl_id
               ,p_oipl_id                    => opt.oipl_id
               ,p_lf_evt_ocrd_dt             => p_lf_evt_ocrd_dt
               ,p_effective_date             => p_effective_date
               ,p_group_pl_id                => p_group_pl_id
               ,p_group_oipl_id              => p_group_oipl_id
               ,p_oipl_ordr_num              => p_oipl_ordr_num
               ,p_object_version_number      => l_ovn);
      end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 120);
      end if;
      --
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 999);
   end if;
end;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_plan_or_option >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_plan_or_option
  (p_validate                       in   boolean   default false
  ,p_pl_id                          in   number
  ,p_oipl_id                        in   number
  ,p_lf_evt_ocrd_dt                 in   date
  ,p_effective_date                 in   date      default hr_api.g_date
  ,p_name                           in   varchar2  default hr_api.g_varchar2
  ,p_group_pl_id                    in   number    default hr_api.g_number
  ,p_group_oipl_id                  in   number    default hr_api.g_number
  ,p_opt_hidden_flag                in   varchar2  default hr_api.g_varchar2
  ,p_opt_id                         in   number    default hr_api.g_number
  ,p_pl_uom                         in   varchar2  default hr_api.g_varchar2
  ,p_pl_ordr_num                    in   number    default hr_api.g_number
  ,p_oipl_ordr_num                  in   number    default hr_api.g_number
  ,p_pl_xchg_rate                   in   number    default hr_api.g_number
  ,p_opt_count                      in   number    default hr_api.g_number
  ,p_uses_bdgt_flag                 in   varchar2  default hr_api.g_varchar2
  ,p_prsrv_bdgt_cd                  in   varchar2  default hr_api.g_varchar2
  ,p_upd_start_dt                   in   date      default hr_api.g_date
  ,p_upd_end_dt                     in   date      default hr_api.g_date
  ,p_approval_mode                  in   varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_start_dt             in   date      default hr_api.g_date
  ,p_enrt_perd_end_dt               in   date      default hr_api.g_date
  ,p_yr_perd_start_dt               in   date      default hr_api.g_date
  ,p_yr_perd_end_dt                 in   date      default hr_api.g_date
  ,p_wthn_yr_start_dt               in   date      default hr_api.g_date
  ,p_wthn_yr_end_dt                 in   date      default hr_api.g_date
  ,p_enrt_perd_id                   in   number    default hr_api.g_number
  ,p_yr_perd_id                     in   number    default hr_api.g_number
  ,p_business_group_id              in   number    default hr_api.g_number
  ,p_perf_revw_strt_dt              in   date      default hr_api.g_date
  ,p_asg_updt_eff_date              in   date      default hr_api.g_date
  ,p_emp_interview_typ_cd           in   varchar2  default hr_api.g_varchar2
  ,p_salary_change_reason           in   varchar2  default hr_api.g_varchar2
  ,p_ws_abr_id                      in   number    default hr_api.g_number
  ,p_ws_nnmntry_uom                 in   varchar2  default hr_api.g_varchar2
  ,p_ws_rndg_cd                     in   varchar2  default hr_api.g_varchar2
  ,p_ws_sub_acty_typ_cd             in   varchar2  default hr_api.g_varchar2
  ,p_dist_bdgt_abr_id               in   number    default hr_api.g_number
  ,p_dist_bdgt_nnmntry_uom          in   varchar2  default hr_api.g_varchar2
  ,p_dist_bdgt_rndg_cd              in   varchar2  default hr_api.g_varchar2
  ,p_ws_bdgt_abr_id                 in   number    default hr_api.g_number
  ,p_ws_bdgt_nnmntry_uom            in   varchar2  default hr_api.g_varchar2
  ,p_ws_bdgt_rndg_cd                in   varchar2  default hr_api.g_varchar2
  ,p_rsrv_abr_id                    in   number    default hr_api.g_number
  ,p_rsrv_nnmntry_uom               in   varchar2  default hr_api.g_varchar2
  ,p_rsrv_rndg_cd                   in   varchar2  default hr_api.g_varchar2
  ,p_elig_sal_abr_id                in   number    default hr_api.g_number
  ,p_elig_sal_nnmntry_uom           in   varchar2  default hr_api.g_varchar2
  ,p_elig_sal_rndg_cd               in   varchar2  default hr_api.g_varchar2
  ,p_misc1_abr_id                   in   number    default hr_api.g_number
  ,p_misc1_nnmntry_uom              in   varchar2  default hr_api.g_varchar2
  ,p_misc1_rndg_cd                  in   varchar2  default hr_api.g_varchar2
  ,p_misc2_abr_id                   in   number    default hr_api.g_number
  ,p_misc2_nnmntry_uom              in   varchar2  default hr_api.g_varchar2
  ,p_misc2_rndg_cd                  in   varchar2  default hr_api.g_varchar2
  ,p_misc3_abr_id                   in   number    default hr_api.g_number
  ,p_misc3_nnmntry_uom              in   varchar2  default hr_api.g_varchar2
  ,p_misc3_rndg_cd                  in   varchar2  default hr_api.g_varchar2
  ,p_stat_sal_abr_id                in   number    default hr_api.g_number
  ,p_stat_sal_nnmntry_uom           in   varchar2  default hr_api.g_varchar2
  ,p_stat_sal_rndg_cd               in   varchar2  default hr_api.g_varchar2
  ,p_rec_abr_id                     in   number    default hr_api.g_number
  ,p_rec_nnmntry_uom                in   varchar2  default hr_api.g_varchar2
  ,p_rec_rndg_cd                    in   varchar2  default hr_api.g_varchar2
  ,p_tot_comp_abr_id                in   number    default hr_api.g_number
  ,p_tot_comp_nnmntry_uom           in   varchar2  default hr_api.g_varchar2
  ,p_tot_comp_rndg_cd               in   varchar2  default hr_api.g_varchar2
  ,p_oth_comp_abr_id                in   number    default hr_api.g_number
  ,p_oth_comp_nnmntry_uom           in   varchar2  default hr_api.g_varchar2
  ,p_oth_comp_rndg_cd               in   varchar2  default hr_api.g_varchar2
  ,p_actual_flag                    in   varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in   varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in   varchar2  default hr_api.g_varchar2
  ,p_pl_annulization_factor         in   number    default hr_api.g_number
  ,p_pl_stat_cd                     in   varchar2  default hr_api.g_varchar2
  ,p_uom_precision                  in   number    default hr_api.g_number
  ,p_ws_element_type_id             in   number    default hr_api.g_number
  ,p_ws_input_value_id              in   number    default hr_api.g_number
  ,p_data_freeze_date               in   date      default hr_api.g_date
  ,p_ws_amt_edit_cd                 in   varchar2  default hr_api.g_varchar2
  ,p_ws_amt_edit_enf_cd_for_nul     in   varchar2  default hr_api.g_varchar2
  ,p_ws_over_budget_edit_cd         in   varchar2  default hr_api.g_varchar2
  ,p_ws_over_budget_tol_pct         in   number    default hr_api.g_number
  ,p_bdgt_over_budget_edit_cd       in   varchar2  default hr_api.g_varchar2
  ,p_bdgt_over_budget_tol_pct       in   number    default hr_api.g_number
  ,p_auto_distr_flag                in   varchar2  default hr_api.g_varchar2
  ,p_pqh_document_short_name        in   varchar2  default hr_api.g_varchar2
  ,p_call_data_syncopation          in   varchar2  default 'Y'
  ,p_ovrid_rt_strt_dt               in   date      default hr_api.g_date
  ,p_do_not_process_flag            in   varchar2  default 'N'
  ,p_ovr_perf_revw_strt_dt          in   date      default hr_api.g_date
  ,p_post_zero_salary_increase      in   varchar2  default hr_api.g_varchar2
  ,p_show_appraisals_n_days         in   number    default hr_api.g_number
  ,p_grade_range_validation         in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  --
  l_proc                varchar2(72) := g_package||'update_plan_or_option';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_plan_or_option;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_pl_dsgn_bk2.update_plan_or_option_b
        (p_pl_id                          => p_pl_id
        ,p_oipl_id                        => p_oipl_id
        ,p_lf_evt_ocrd_dt                 => p_lf_evt_ocrd_dt
        ,p_effective_date                 => p_effective_date
        ,p_name                           => p_name
        ,p_group_pl_id                    => p_group_pl_id
        ,p_group_oipl_id                  => p_group_oipl_id
        ,p_opt_hidden_flag                => p_opt_hidden_flag
        ,p_opt_id                         => p_opt_id
        ,p_pl_uom                         => p_pl_uom
        ,p_pl_ordr_num                    => p_pl_ordr_num
        ,p_oipl_ordr_num                  => p_oipl_ordr_num
        ,p_pl_xchg_rate                   => p_pl_xchg_rate
        ,p_opt_count                      => p_opt_count
        ,p_uses_bdgt_flag                 => p_uses_bdgt_flag
        ,p_prsrv_bdgt_cd                  => p_prsrv_bdgt_cd
        ,p_upd_start_dt                   => p_upd_start_dt
        ,p_upd_end_dt                     => p_upd_end_dt
        ,p_approval_mode                  => p_approval_mode
        ,p_enrt_perd_start_dt             => p_enrt_perd_start_dt
        ,p_enrt_perd_end_dt               => p_enrt_perd_end_dt
        ,p_yr_perd_start_dt               => p_yr_perd_start_dt
        ,p_yr_perd_end_dt                 => p_yr_perd_end_dt
        ,p_wthn_yr_start_dt               => p_wthn_yr_start_dt
        ,p_wthn_yr_end_dt                 => p_wthn_yr_end_dt
        ,p_enrt_perd_id                   => p_enrt_perd_id
        ,p_yr_perd_id                     => p_yr_perd_id
        ,p_business_group_id              => p_business_group_id
        ,p_perf_revw_strt_dt              => p_perf_revw_strt_dt
        ,p_asg_updt_eff_date              => p_asg_updt_eff_date
        ,p_emp_interview_typ_cd           => p_emp_interview_typ_cd
        ,p_salary_change_reason           => p_salary_change_reason
        ,p_ws_abr_id                      => p_ws_abr_id
        ,p_ws_nnmntry_uom                 => p_ws_nnmntry_uom
        ,p_ws_rndg_cd                     => p_ws_rndg_cd
        ,p_ws_sub_acty_typ_cd             => p_ws_sub_acty_typ_cd
        ,p_dist_bdgt_abr_id               => p_dist_bdgt_abr_id
        ,p_dist_bdgt_nnmntry_uom          => p_dist_bdgt_nnmntry_uom
        ,p_dist_bdgt_rndg_cd              => p_dist_bdgt_rndg_cd
        ,p_ws_bdgt_abr_id                 => p_ws_bdgt_abr_id
        ,p_ws_bdgt_nnmntry_uom            => p_ws_bdgt_nnmntry_uom
        ,p_ws_bdgt_rndg_cd                => p_ws_bdgt_rndg_cd
        ,p_rsrv_abr_id                    => p_rsrv_abr_id
        ,p_rsrv_nnmntry_uom               => p_rsrv_nnmntry_uom
        ,p_rsrv_rndg_cd                   => p_rsrv_rndg_cd
        ,p_elig_sal_abr_id                => p_elig_sal_abr_id
        ,p_elig_sal_nnmntry_uom           => p_elig_sal_nnmntry_uom
        ,p_elig_sal_rndg_cd               => p_elig_sal_rndg_cd
        ,p_misc1_abr_id                   => p_misc1_abr_id
        ,p_misc1_nnmntry_uom              => p_misc1_nnmntry_uom
        ,p_misc1_rndg_cd                  => p_misc1_rndg_cd
        ,p_misc2_abr_id                   => p_misc2_abr_id
        ,p_misc2_nnmntry_uom              => p_misc2_nnmntry_uom
        ,p_misc2_rndg_cd                  => p_misc2_rndg_cd
        ,p_misc3_abr_id                   => p_misc3_abr_id
        ,p_misc3_nnmntry_uom              => p_misc3_nnmntry_uom
        ,p_misc3_rndg_cd                  => p_misc3_rndg_cd
        ,p_stat_sal_abr_id                => p_stat_sal_abr_id
        ,p_stat_sal_nnmntry_uom           => p_stat_sal_nnmntry_uom
        ,p_stat_sal_rndg_cd               => p_stat_sal_rndg_cd
        ,p_rec_abr_id                     => p_rec_abr_id
        ,p_rec_nnmntry_uom                => p_rec_nnmntry_uom
        ,p_rec_rndg_cd                    => p_rec_rndg_cd
        ,p_tot_comp_abr_id                => p_tot_comp_abr_id
        ,p_tot_comp_nnmntry_uom           => p_tot_comp_nnmntry_uom
        ,p_tot_comp_rndg_cd               => p_tot_comp_rndg_cd
        ,p_oth_comp_abr_id                => p_oth_comp_abr_id
        ,p_oth_comp_nnmntry_uom           => p_oth_comp_nnmntry_uom
        ,p_oth_comp_rndg_cd               => p_oth_comp_rndg_cd
        ,p_actual_flag                    => p_actual_flag
        ,p_acty_ref_perd_cd               => p_acty_ref_perd_cd
        ,p_legislation_code               => p_legislation_code
        ,p_pl_annulization_factor         => p_pl_annulization_factor
        ,p_pl_stat_cd                     => p_pl_stat_cd
        ,p_uom_precision                  => p_uom_precision
        ,p_ws_element_type_id             => p_ws_element_type_id
        ,p_ws_input_value_id              => p_ws_input_value_id
        ,p_data_freeze_date               => p_data_freeze_date
        ,p_ws_amt_edit_cd                 => p_ws_amt_edit_cd
        ,p_ws_amt_edit_enf_cd_for_nul     => p_ws_amt_edit_enf_cd_for_nul
        ,p_ws_over_budget_edit_cd         => p_ws_over_budget_edit_cd
        ,p_ws_over_budget_tol_pct         => p_ws_over_budget_tol_pct
        ,p_bdgt_over_budget_edit_cd       => p_bdgt_over_budget_edit_cd
        ,p_bdgt_over_budget_tol_pct       => p_bdgt_over_budget_tol_pct
        ,p_auto_distr_flag                => p_auto_distr_flag
        ,p_pqh_document_short_name        => p_pqh_document_short_name
        ,p_ovrid_rt_strt_dt               => p_ovrid_rt_strt_dt
        ,p_do_not_process_flag            => p_do_not_process_flag
	,p_ovr_perf_revw_strt_dt          => p_ovr_perf_revw_strt_dt
	,p_post_zero_salary_increase      => p_post_zero_salary_increase
        ,p_show_appraisals_n_days         => p_show_appraisals_n_days
	,p_grade_range_validation         => p_grade_range_validation
        ,p_object_version_number          => l_object_version_number
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_plan_or_option'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ben_cpd_upd.upd
        (p_pl_id                          => p_pl_id
        ,p_oipl_id                        => p_oipl_id
        ,p_lf_evt_ocrd_dt                 => p_lf_evt_ocrd_dt
        ,p_effective_date                 => p_effective_date
        ,p_name                           => p_name
        ,p_group_pl_id                    => p_group_pl_id
        ,p_group_oipl_id                  => p_group_oipl_id
        ,p_opt_hidden_flag                => p_opt_hidden_flag
        ,p_opt_id                         => p_opt_id
        ,p_pl_uom                         => p_pl_uom
        ,p_pl_ordr_num                    => p_pl_ordr_num
        ,p_oipl_ordr_num                  => p_oipl_ordr_num
        ,p_pl_xchg_rate                   => p_pl_xchg_rate
        ,p_opt_count                      => p_opt_count
        ,p_uses_bdgt_flag                 => p_uses_bdgt_flag
        ,p_prsrv_bdgt_cd                  => p_prsrv_bdgt_cd
        ,p_upd_start_dt                   => p_upd_start_dt
        ,p_upd_end_dt                     => p_upd_end_dt
        ,p_approval_mode                  => p_approval_mode
        ,p_enrt_perd_start_dt             => p_enrt_perd_start_dt
        ,p_enrt_perd_end_dt               => p_enrt_perd_end_dt
        ,p_yr_perd_start_dt               => p_yr_perd_start_dt
        ,p_yr_perd_end_dt                 => p_yr_perd_end_dt
        ,p_wthn_yr_start_dt               => p_wthn_yr_start_dt
        ,p_wthn_yr_end_dt                 => p_wthn_yr_end_dt
        ,p_enrt_perd_id                   => p_enrt_perd_id
        ,p_yr_perd_id                     => p_yr_perd_id
        ,p_business_group_id              => p_business_group_id
        ,p_perf_revw_strt_dt              => p_perf_revw_strt_dt
        ,p_asg_updt_eff_date              => p_asg_updt_eff_date
        ,p_emp_interview_typ_cd           => p_emp_interview_typ_cd
        ,p_salary_change_reason           => p_salary_change_reason
        ,p_ws_abr_id                      => p_ws_abr_id
        ,p_ws_nnmntry_uom                 => p_ws_nnmntry_uom
        ,p_ws_rndg_cd                     => p_ws_rndg_cd
        ,p_ws_sub_acty_typ_cd             => p_ws_sub_acty_typ_cd
        ,p_dist_bdgt_abr_id               => p_dist_bdgt_abr_id
        ,p_dist_bdgt_nnmntry_uom          => p_dist_bdgt_nnmntry_uom
        ,p_dist_bdgt_rndg_cd              => p_dist_bdgt_rndg_cd
        ,p_ws_bdgt_abr_id                 => p_ws_bdgt_abr_id
        ,p_ws_bdgt_nnmntry_uom            => p_ws_bdgt_nnmntry_uom
        ,p_ws_bdgt_rndg_cd                => p_ws_bdgt_rndg_cd
        ,p_rsrv_abr_id                    => p_rsrv_abr_id
        ,p_rsrv_nnmntry_uom               => p_rsrv_nnmntry_uom
        ,p_rsrv_rndg_cd                   => p_rsrv_rndg_cd
        ,p_elig_sal_abr_id                => p_elig_sal_abr_id
        ,p_elig_sal_nnmntry_uom           => p_elig_sal_nnmntry_uom
        ,p_elig_sal_rndg_cd               => p_elig_sal_rndg_cd
        ,p_misc1_abr_id                   => p_misc1_abr_id
        ,p_misc1_nnmntry_uom              => p_misc1_nnmntry_uom
        ,p_misc1_rndg_cd                  => p_misc1_rndg_cd
        ,p_misc2_abr_id                   => p_misc2_abr_id
        ,p_misc2_nnmntry_uom              => p_misc2_nnmntry_uom
        ,p_misc2_rndg_cd                  => p_misc2_rndg_cd
        ,p_misc3_abr_id                   => p_misc3_abr_id
        ,p_misc3_nnmntry_uom              => p_misc3_nnmntry_uom
        ,p_misc3_rndg_cd                  => p_misc3_rndg_cd
        ,p_stat_sal_abr_id                => p_stat_sal_abr_id
        ,p_stat_sal_nnmntry_uom           => p_stat_sal_nnmntry_uom
        ,p_stat_sal_rndg_cd               => p_stat_sal_rndg_cd
        ,p_rec_abr_id                     => p_rec_abr_id
        ,p_rec_nnmntry_uom                => p_rec_nnmntry_uom
        ,p_rec_rndg_cd                    => p_rec_rndg_cd
        ,p_tot_comp_abr_id                => p_tot_comp_abr_id
        ,p_tot_comp_nnmntry_uom           => p_tot_comp_nnmntry_uom
        ,p_tot_comp_rndg_cd               => p_tot_comp_rndg_cd
        ,p_oth_comp_abr_id                => p_oth_comp_abr_id
        ,p_oth_comp_nnmntry_uom           => p_oth_comp_nnmntry_uom
        ,p_oth_comp_rndg_cd               => p_oth_comp_rndg_cd
        ,p_actual_flag                    => p_actual_flag
        ,p_acty_ref_perd_cd               => p_acty_ref_perd_cd
        ,p_legislation_code               => p_legislation_code
        ,p_pl_annulization_factor         => p_pl_annulization_factor
        ,p_pl_stat_cd                     => p_pl_stat_cd
        ,p_uom_precision                  => p_uom_precision
        ,p_ws_element_type_id             => p_ws_element_type_id
        ,p_ws_input_value_id              => p_ws_input_value_id
        ,p_data_freeze_date               => p_data_freeze_date
        ,p_ws_amt_edit_cd                 => p_ws_amt_edit_cd
        ,p_ws_amt_edit_enf_cd_for_nul     => p_ws_amt_edit_enf_cd_for_nul
        ,p_ws_over_budget_edit_cd         => p_ws_over_budget_edit_cd
        ,p_ws_over_budget_tol_pct         => p_ws_over_budget_tol_pct
        ,p_bdgt_over_budget_edit_cd       => p_bdgt_over_budget_edit_cd
        ,p_bdgt_over_budget_tol_pct       => p_bdgt_over_budget_tol_pct
        ,p_auto_distr_flag                => p_auto_distr_flag
        ,p_pqh_document_short_name        => p_pqh_document_short_name
        ,p_ovrid_rt_strt_dt               => p_ovrid_rt_strt_dt
        ,p_do_not_process_flag            => p_do_not_process_flag
	,p_ovr_perf_revw_strt_dt          => p_ovr_perf_revw_strt_dt
	,p_post_zero_salary_increase      => p_post_zero_salary_increase
        ,p_show_appraisals_n_days         => p_show_appraisals_n_days
	,p_grade_range_validation         => p_grade_range_validation
        ,p_object_version_number          => l_object_version_number
        );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_pl_dsgn_bk2.update_plan_or_option_a
        (p_pl_id                          => p_pl_id
        ,p_oipl_id                        => p_oipl_id
        ,p_lf_evt_ocrd_dt                 => p_lf_evt_ocrd_dt
        ,p_effective_date                 => p_effective_date
        ,p_name                           => p_name
        ,p_group_pl_id                    => p_group_pl_id
        ,p_group_oipl_id                  => p_group_oipl_id
        ,p_opt_hidden_flag                => p_opt_hidden_flag
        ,p_opt_id                         => p_opt_id
        ,p_pl_uom                         => p_pl_uom
        ,p_pl_ordr_num                    => p_pl_ordr_num
        ,p_oipl_ordr_num                  => p_oipl_ordr_num
        ,p_pl_xchg_rate                   => p_pl_xchg_rate
        ,p_opt_count                      => p_opt_count
        ,p_uses_bdgt_flag                 => p_uses_bdgt_flag
        ,p_prsrv_bdgt_cd                  => p_prsrv_bdgt_cd
        ,p_upd_start_dt                   => p_upd_start_dt
        ,p_upd_end_dt                     => p_upd_end_dt
        ,p_approval_mode                  => p_approval_mode
        ,p_enrt_perd_start_dt             => p_enrt_perd_start_dt
        ,p_enrt_perd_end_dt               => p_enrt_perd_end_dt
        ,p_yr_perd_start_dt               => p_yr_perd_start_dt
        ,p_yr_perd_end_dt                 => p_yr_perd_end_dt
        ,p_wthn_yr_start_dt               => p_wthn_yr_start_dt
        ,p_wthn_yr_end_dt                 => p_wthn_yr_end_dt
        ,p_enrt_perd_id                   => p_enrt_perd_id
        ,p_yr_perd_id                     => p_yr_perd_id
        ,p_business_group_id              => p_business_group_id
        ,p_perf_revw_strt_dt              => p_perf_revw_strt_dt
        ,p_asg_updt_eff_date              => p_asg_updt_eff_date
        ,p_emp_interview_typ_cd           => p_emp_interview_typ_cd
        ,p_salary_change_reason           => p_salary_change_reason
        ,p_ws_abr_id                      => p_ws_abr_id
        ,p_ws_nnmntry_uom                 => p_ws_nnmntry_uom
        ,p_ws_rndg_cd                     => p_ws_rndg_cd
        ,p_ws_sub_acty_typ_cd             => p_ws_sub_acty_typ_cd
        ,p_dist_bdgt_abr_id               => p_dist_bdgt_abr_id
        ,p_dist_bdgt_nnmntry_uom          => p_dist_bdgt_nnmntry_uom
        ,p_dist_bdgt_rndg_cd              => p_dist_bdgt_rndg_cd
        ,p_ws_bdgt_abr_id                 => p_ws_bdgt_abr_id
        ,p_ws_bdgt_nnmntry_uom            => p_ws_bdgt_nnmntry_uom
        ,p_ws_bdgt_rndg_cd                => p_ws_bdgt_rndg_cd
        ,p_rsrv_abr_id                    => p_rsrv_abr_id
        ,p_rsrv_nnmntry_uom               => p_rsrv_nnmntry_uom
        ,p_rsrv_rndg_cd                   => p_rsrv_rndg_cd
        ,p_elig_sal_abr_id                => p_elig_sal_abr_id
        ,p_elig_sal_nnmntry_uom           => p_elig_sal_nnmntry_uom
        ,p_elig_sal_rndg_cd               => p_elig_sal_rndg_cd
        ,p_misc1_abr_id                   => p_misc1_abr_id
        ,p_misc1_nnmntry_uom              => p_misc1_nnmntry_uom
        ,p_misc1_rndg_cd                  => p_misc1_rndg_cd
        ,p_misc2_abr_id                   => p_misc2_abr_id
        ,p_misc2_nnmntry_uom              => p_misc2_nnmntry_uom
        ,p_misc2_rndg_cd                  => p_misc2_rndg_cd
        ,p_misc3_abr_id                   => p_misc3_abr_id
        ,p_misc3_nnmntry_uom              => p_misc3_nnmntry_uom
        ,p_misc3_rndg_cd                  => p_misc3_rndg_cd
        ,p_stat_sal_abr_id                => p_stat_sal_abr_id
        ,p_stat_sal_nnmntry_uom           => p_stat_sal_nnmntry_uom
        ,p_stat_sal_rndg_cd               => p_stat_sal_rndg_cd
        ,p_rec_abr_id                     => p_rec_abr_id
        ,p_rec_nnmntry_uom                => p_rec_nnmntry_uom
        ,p_rec_rndg_cd                    => p_rec_rndg_cd
        ,p_tot_comp_abr_id                => p_tot_comp_abr_id
        ,p_tot_comp_nnmntry_uom           => p_tot_comp_nnmntry_uom
        ,p_tot_comp_rndg_cd               => p_tot_comp_rndg_cd
        ,p_oth_comp_abr_id                => p_oth_comp_abr_id
        ,p_oth_comp_nnmntry_uom           => p_oth_comp_nnmntry_uom
        ,p_oth_comp_rndg_cd               => p_oth_comp_rndg_cd
        ,p_actual_flag                    => p_actual_flag
        ,p_acty_ref_perd_cd               => p_acty_ref_perd_cd
        ,p_legislation_code               => p_legislation_code
        ,p_pl_annulization_factor         => p_pl_annulization_factor
        ,p_pl_stat_cd                     => p_pl_stat_cd
        ,p_uom_precision                  => p_uom_precision
        ,p_ws_element_type_id             => p_ws_element_type_id
        ,p_ws_input_value_id              => p_ws_input_value_id
        ,p_data_freeze_date               => p_data_freeze_date
        ,p_ws_amt_edit_cd                 => p_ws_amt_edit_cd
        ,p_ws_amt_edit_enf_cd_for_nul     => p_ws_amt_edit_enf_cd_for_nul
        ,p_ws_over_budget_edit_cd         => p_ws_over_budget_edit_cd
        ,p_ws_over_budget_tol_pct         => p_ws_over_budget_tol_pct
        ,p_bdgt_over_budget_edit_cd       => p_bdgt_over_budget_edit_cd
        ,p_bdgt_over_budget_tol_pct       => p_bdgt_over_budget_tol_pct
        ,p_auto_distr_flag                => p_auto_distr_flag
        ,p_pqh_document_short_name        => p_pqh_document_short_name
        ,p_ovrid_rt_strt_dt               => p_ovrid_rt_strt_dt
        ,p_do_not_process_flag            => p_do_not_process_flag
	,p_ovr_perf_revw_strt_dt          => p_ovr_perf_revw_strt_dt
	,p_post_zero_salary_increase      => p_post_zero_salary_increase
        ,p_show_appraisals_n_days         => p_show_appraisals_n_days
	,p_grade_range_validation         => p_grade_range_validation
        ,p_object_version_number          => l_object_version_number
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_plan_or_option'
        ,p_hook_type   => 'AP'
        );
  end;
  -- call the data_syncopation procedure
  if (p_call_data_syncopation = 'Y') then
    data_syncopation(p_pl_id                  =>    p_pl_id
                    ,p_oipl_id                =>    p_oipl_id
                    ,p_lf_evt_ocrd_dt         =>    p_lf_evt_ocrd_dt
                    ,p_effective_date         =>    p_effective_date
                    ,p_group_pl_id            =>    p_group_pl_id
                    ,p_group_oipl_id          =>    p_group_oipl_id
                    ,p_pl_uom                 =>    p_pl_uom
                    ,p_pl_ordr_num            =>    p_pl_ordr_num
                    ,p_oipl_ordr_num          =>    p_oipl_ordr_num
                    ,p_pl_xchg_rate           =>    p_pl_xchg_rate
                    ,p_upd_start_dt           =>    p_upd_start_dt
                    ,p_upd_end_dt             =>    p_upd_end_dt
                    ,p_approval_mode          =>    p_approval_mode
                    ,p_enrt_perd_start_dt     =>    p_enrt_perd_start_dt
                    ,p_enrt_perd_end_dt       =>    p_enrt_perd_end_dt
                    ,p_yr_perd_start_dt       =>    p_yr_perd_start_dt
                    ,p_yr_perd_end_dt         =>    p_yr_perd_end_dt
                    ,p_wthn_yr_start_dt       =>    p_wthn_yr_start_dt
                    ,p_wthn_yr_end_dt         =>    p_wthn_yr_end_dt
                    ,p_business_group_id      =>    p_business_group_id
                    ,p_perf_revw_strt_dt      =>    p_perf_revw_strt_dt
                    ,p_asg_updt_eff_date      =>    p_asg_updt_eff_date
                    ,p_emp_interview_typ_cd   =>    p_emp_interview_typ_cd
                    ,p_salary_change_reason   =>    p_salary_change_reason
                    ,p_actual_flag            =>    p_actual_flag
                    ,p_acty_ref_perd_cd       =>    p_acty_ref_perd_cd
                    ,p_legislation_code       =>    p_legislation_code
                    ,p_pl_annulization_factor =>    p_pl_annulization_factor
                    ,p_pl_stat_cd             =>    p_pl_stat_cd
                    ,p_uom_precision          =>    p_uom_precision
                    ,p_data_freeze_date       =>    p_data_freeze_date);
   end if;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 80);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_plan_or_option;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_plan_or_option;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 99);
    end if;
    raise;
end update_plan_or_option;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_plan_or_option >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_plan_or_option
  (p_validate                     in     boolean  default false
  ,p_pl_id                        in     number
  ,p_oipl_id                      in     number
  ,p_lf_evt_ocrd_dt               in     date
  ,p_object_version_number        in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'delete_plan_or_option';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_plan_or_option;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    BEN_CWB_PL_DSGN_BK3.delete_plan_or_option_b
        (p_pl_id                   =>   p_pl_id
        ,p_oipl_id                 =>   p_oipl_id
        ,p_lf_evt_ocrd_dt          =>   p_lf_evt_ocrd_dt
        ,p_object_version_number   =>   l_object_version_number
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_plan_or_option'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ben_cpd_del.del
        (p_pl_id                   =>   p_pl_id
        ,p_oipl_id                 =>   p_oipl_id
        ,p_lf_evt_ocrd_dt          =>   p_lf_evt_ocrd_dt
        ,p_object_version_number   =>   l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_pl_dsgn_bk3.delete_plan_or_option_a
        (p_pl_id                   =>   p_pl_id
        ,p_oipl_id                 =>   p_oipl_id
        ,p_lf_evt_ocrd_dt          =>   p_lf_evt_ocrd_dt
        ,p_object_version_number   =>   l_object_version_number
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_plan_or_option'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_plan_or_option;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_plan_or_option;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_plan_or_option;
--
end ben_cwb_pl_dsgn_api;

/
