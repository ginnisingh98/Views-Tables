--------------------------------------------------------
--  DDL for Package BEN_CWB_PL_DSGN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PL_DSGN_API" AUTHID CURRENT_USER as
/* $Header: becpdapi.pkh 120.3.12010000.4 2010/03/12 06:07:31 sgnanama ship $ */
/*#
 * This package contains Compensation Workbench Plan Design APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Compensation Workbench Plan Design
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_plan_or_option >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates compensation workbench plan and option information.
 *
 * This API information is used by all self-service pages that create plan
 * design data.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid plan/option for Compensation Workbench must exist.
 *
 * <p><b>Post Success</b><br>
 * A Compensation Workbench Plan will have been created in the database.
 *
 * <p><b>Post Failure</b><br>
 * A Compensation Workbench Plan will not be created in the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pl_id Specifies the Compensation Workbench Plan.
 * @param p_oipl_id Specifies options for Compensation Workbench Plan.
 * @param p_lf_evt_ocrd_dt {@rep:casecolumn BEN_CWB_PL_DSGN.LF_EVT_OCRD_DT}
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_name This parameter specifies the Compensation Workbench Plan name.
 * @param p_group_pl_id This parameter specifies Compensation Workbench Group
 * Plan.
 * @param p_group_oipl_id Specifies options for a Compensation Workbench Group
 * Plan.
 * @param p_opt_hidden_flag This parameter specifies if the Compensation
 * Workbench Plan options will be displayed in the SS pages.
 * @param p_opt_id This parameter specifies the option and is foreign Key to
 * BEN_OPT_F.
 * @param p_pl_uom This parameter specifies the Compensation Workbench Plan
 * currency.
 * @param p_pl_ordr_num This parameter specifiesthe Compensation Workbench Plan
 * order number.
 * @param p_oipl_ordr_num This parameter specifiesthe Compensation Workbench
 * Plan options order number.
 * @param p_pl_xchg_rate This parameter specifies the exchange rate for
 * Compensation Workbench Plan currency.
 * @param p_opt_count This parameter keeps count of plan options.
 * @param p_uses_bdgt_flag This parameter specifies if budgeting is used or
 * not.
 * @param p_prsrv_bdgt_cd This parameter specifies if budget is stored as
 * amount or percentage of eligible salaries.
 * @param p_upd_start_dt Self Service update start date
 * @param p_upd_end_dt Self Service update end date
 * @param p_approval_mode This parameter specifies approval mode for
 * allocations submission. Valid values are defined in 'BEN_CWB_APPROVAL_MODE'
 * lookup type.
 * @param p_enrt_perd_start_dt {@rep:casecolumn
 * BEN_CWB_PL_DSGN.ENRT_PERD_START_DT}
 * @param p_enrt_perd_end_dt {@rep:casecolumn BEN_CWB_PL_DSGN.ENRT_PERD_END_DT}
 * @param p_yr_perd_start_dt {@rep:casecolumn BEN_CWB_PL_DSGN.YR_PERD_START_DT}
 * @param p_yr_perd_end_dt {@rep:casecolumn BEN_CWB_PL_DSGN.YR_PERD_END_DT}
 * @param p_wthn_yr_start_dt {@rep:casecolumn BEN_CWB_PL_DSGN.WTHN_YR_START_DT}
 * @param p_wthn_yr_end_dt {@rep:casecolumn BEN_CWB_PL_DSGN.WTHN_YR_END_DT}
 * @param p_enrt_perd_id {@rep:casecolumn BEN_CWB_PL_DSGN.ENRT_PERD_ID}
 * @param p_yr_perd_id {@rep:casecolumn BEN_CWB_PL_DSGN.YR_PERD_ID}
 * @param p_business_group_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.BUSINESS_GROUP_ID}
 * @param p_perf_revw_strt_dt {@rep:casecolumn BEN_ENRT_PERD.PERF_REVW_STRT_DT}
 * @param p_asg_updt_eff_date {@rep:casecolumn BEN_ENRT_PERD.ASG_UPDT_EFF_DATE}
 * @param p_emp_interview_typ_cd This parameter specifies performance rating
 * type. It specifies the valid values defined in 'EMP_INTERVIEW_TYPE' lookup
 * type.
 * @param p_salary_change_reason {@rep:casecolumn
 * BEN_CWB_PL_DSGN.SALARY_CHANGE_REASON}
 * @param p_ws_abr_id This parameter specifies worksheet rate. It is null if no
 * worksheet rate is defined.
 * @param p_ws_nnmntry_uom This parameter specifies the non-monetory units of
 * measure such as stocks.
 * @param p_ws_rndg_cd This parameter specifies the numeric rounding parameter.
 * Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_ws_sub_acty_typ_cd This parameter specifies worksheet rate sub
 * activity type code. Valid values are defined in 'BEN_SUB_ACTY_TYP' lookup
 * type.
 * @param p_dist_bdgt_abr_id This parameter specifies distribution budget rate.
 * @param p_dist_bdgt_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_dist_bdgt_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values defined are in 'BEN_RNDG' lookup type.
 * @param p_ws_bdgt_abr_id This parameter specifies worksheet budget rate.
 * @param p_ws_bdgt_nnmntry_uom This parameter specifies the non-monetory units
 * of measure such as stocks.
 * @param p_ws_bdgt_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_rsrv_abr_id This parameter specifies reserve budget rate.
 * @param p_rsrv_nnmntry_uom This parameter specifies the non-monetory units of
 * measure such as stocks.
 * @param p_rsrv_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values defined are in 'BEN_RNDG' lookup type.
 * @param p_elig_sal_abr_id This parameter specifies eligible salary rate.
 * @param p_elig_sal_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_elig_sal_rndg_cd This parameter specifies the non-monetory units of
 * measure such as stocks.
 * @param p_misc1_abr_id This parameter specifies miscellaneous 1 rate.
 * @param p_misc1_nnmntry_uom This parameter specifies the non-monetory units
 * of measure such as stocks.
 * @param p_misc1_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_misc2_abr_id This parameter specifies miscellaneous 2 rate.
 * @param p_misc2_nnmntry_uom This parameter specifies the non-monetory units
 * of measure such as stocks.
 * @param p_misc2_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_misc3_abr_id This parameter specifies miscellaneous 3 rate.
 * @param p_misc3_nnmntry_uom This parameter specifies the non-monetory units
 * of measure such as stocks.
 * @param p_misc3_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values defined in 'BEN_RNDG' lookup type.
 * @param p_stat_sal_abr_id This parameter specifies the stated salary rate.
 * @param p_stat_sal_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_stat_sal_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values defined in 'BEN_RNDG' lookup type.
 * @param p_rec_abr_id This parameter specifies the recommended rate.
 * @param p_rec_nnmntry_uom This parameter specifies the non-monetory units of
 * measure such as stocks.
 * @param p_rec_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_tot_comp_abr_id This parameter specifies the total compensation.
 * @param p_tot_comp_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_tot_comp_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_oth_comp_abr_id This parameter specifies the other compensation.
 * @param p_oth_comp_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_oth_comp_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_actual_flag This parameter specifies if balance type is actual or
 * not.
 * @param p_acty_ref_perd_cd This parameter specifies the activity reference
 * period. Valid values are defined in 'BEN_ACTY_REF_PERD' lookup type.
 * @param p_legislation_code This parameter specifies the legislation to which
 * the information type applies. Foreign key to FND_TERRITORIES.
 * @param p_pl_annulization_factor {@rep:casecolumn
 * BEN_CWB_PL_DSGN.PL_ANNULIZATION_FACTOR}
 * @param p_pl_stat_cd This parameter specifies the plan status code. Valid
 * values are defined in 'BEN_STAT' lookup type.
 * @param p_uom_precision {@rep:casecolumn BEN_CWB_PL_DSGN.UOM_PRECISION}
 * @param p_ws_element_type_id {@rep:casecolumn
 * BEN_CWB_PL_DSGN.WS_ELEMENT_TYPE_ID}
 * @param p_ws_input_value_id {@rep:casecolumn
 * BEN_CWB_PL_DSGN.WS_INPUT_VALUE_ID}
 * @param p_data_freeze_date This parameter specifies the freeze date on which
 * snapshot for Compensation Workbench Person is performed.
 * @param p_ws_amt_edit_cd This parameter specifies the allocations amount edit
 * code.
 * @param p_ws_amt_edit_enf_cd_for_nul This parameter specifies allocations
 * amount edit code for nulls.
 * @param p_ws_over_budget_edit_cd This parameter specifies allocations over
 * budget edit code.
 * @param p_ws_over_budget_tol_pct This parameter specifies allocations over
 * budget tolerance percentage.
 * @param p_bdgt_over_budget_edit_cd This parameter specifies budgets over
 * budget edit code.
 * @param p_bdgt_over_budget_tol_pct This parameter specifies distribution
 * budget over budget tolerance percentage.
 * @param p_auto_distr_flag This parameter specifies a flag for automatic
 * distribution.
 * @param p_pqh_document_short_name This parameter is a short name for PQH
 * (Public sector HR) document.
 * @param p_ovrid_rt_strt_dt This parameter allows the user to override the
 * effective date when post process is run to post data.
 * @param p_do_not_process_flag If yes, then post process skips processing
 * the particular local plan for which it is set.
 * @param p_ovr_perf_revw_strt_dt This parameter overrides the effective date
 * for performance related changes.
 * @param p_post_zero_salary_increase If yes, then post process posts zero
 * salary increase
 * @param p_show_appraisals_n_days This parameter specifies the number of
 * days within which completed appraisals will be shown in worksheet
 * @param p_grade_range_validation This parameter specifies the validation
 * of new salary against the grade range
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Compensation Workbench Plan. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Compensation Workbench Plan
 * @rep:category BUSINESS_ENTITY BEN_CWB_PLAN
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_plan_or_option
  (p_validate                       in     boolean  default false
  ,p_pl_id                          in     number
  ,p_oipl_id                        in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_effective_date                 in     date      default null
  ,p_name                           in     varchar2  default null
  ,p_group_pl_id                    in     number    default null
  ,p_group_oipl_id                  in     number    default null
  ,p_opt_hidden_flag                in     varchar2  default null
  ,p_opt_id                         in     number    default null
  ,p_pl_uom                         in     varchar2  default null
  ,p_pl_ordr_num                    in     number    default null
  ,p_oipl_ordr_num                  in     number    default null
  ,p_pl_xchg_rate                   in     number    default null
  ,p_opt_count                      in     number    default null
  ,p_uses_bdgt_flag                 in     varchar2  default null
  ,p_prsrv_bdgt_cd                  in     varchar2  default null
  ,p_upd_start_dt                   in     date      default null
  ,p_upd_end_dt                     in     date      default null
  ,p_approval_mode                  in     varchar2  default null
  ,p_enrt_perd_start_dt             in     date      default null
  ,p_enrt_perd_end_dt               in     date      default null
  ,p_yr_perd_start_dt               in     date      default null
  ,p_yr_perd_end_dt                 in     date      default null
  ,p_wthn_yr_start_dt               in     date      default null
  ,p_wthn_yr_end_dt                 in     date      default null
  ,p_enrt_perd_id                   in     number    default null
  ,p_yr_perd_id                     in     number    default null
  ,p_business_group_id              in     number    default null
  ,p_perf_revw_strt_dt              in     date      default null
  ,p_asg_updt_eff_date              in     date      default null
  ,p_emp_interview_typ_cd           in     varchar2  default null
  ,p_salary_change_reason           in     varchar2  default null
  ,p_ws_abr_id                      in     number    default null
  ,p_ws_nnmntry_uom                 in     varchar2  default null
  ,p_ws_rndg_cd                     in     varchar2  default null
  ,p_ws_sub_acty_typ_cd             in     varchar2  default null
  ,p_dist_bdgt_abr_id               in     number    default null
  ,p_dist_bdgt_nnmntry_uom          in     varchar2  default null
  ,p_dist_bdgt_rndg_cd              in     varchar2  default null
  ,p_ws_bdgt_abr_id                 in     number    default null
  ,p_ws_bdgt_nnmntry_uom            in     varchar2  default null
  ,p_ws_bdgt_rndg_cd                in     varchar2  default null
  ,p_rsrv_abr_id                    in     number    default null
  ,p_rsrv_nnmntry_uom               in     varchar2  default null
  ,p_rsrv_rndg_cd                   in     varchar2  default null
  ,p_elig_sal_abr_id                in     number    default null
  ,p_elig_sal_nnmntry_uom           in     varchar2  default null
  ,p_elig_sal_rndg_cd               in     varchar2  default null
  ,p_misc1_abr_id                   in     number    default null
  ,p_misc1_nnmntry_uom              in     varchar2  default null
  ,p_misc1_rndg_cd                  in     varchar2  default null
  ,p_misc2_abr_id                   in     number    default null
  ,p_misc2_nnmntry_uom              in     varchar2  default null
  ,p_misc2_rndg_cd                  in     varchar2  default null
  ,p_misc3_abr_id                   in     number    default null
  ,p_misc3_nnmntry_uom              in     varchar2  default null
  ,p_misc3_rndg_cd                  in     varchar2  default null
  ,p_stat_sal_abr_id                in     number    default null
  ,p_stat_sal_nnmntry_uom           in     varchar2  default null
  ,p_stat_sal_rndg_cd               in     varchar2  default null
  ,p_rec_abr_id                     in     number    default null
  ,p_rec_nnmntry_uom                in     varchar2  default null
  ,p_rec_rndg_cd                    in     varchar2  default null
  ,p_tot_comp_abr_id                in     number    default null
  ,p_tot_comp_nnmntry_uom           in     varchar2  default null
  ,p_tot_comp_rndg_cd               in     varchar2  default null
  ,p_oth_comp_abr_id                in     number    default null
  ,p_oth_comp_nnmntry_uom           in     varchar2  default null
  ,p_oth_comp_rndg_cd               in     varchar2  default null
  ,p_actual_flag                    in     varchar2  default null
  ,p_acty_ref_perd_cd               in     varchar2  default null
  ,p_legislation_code               in     varchar2  default null
  ,p_pl_annulization_factor         in     number    default null
  ,p_pl_stat_cd                     in     varchar2  default null
  ,p_uom_precision                  in     number    default null
  ,p_ws_element_type_id             in     number    default null
  ,p_ws_input_value_id              in     number    default null
  ,p_data_freeze_date               in     date      default null
  ,p_ws_amt_edit_cd                 in     varchar2  default null
  ,p_ws_amt_edit_enf_cd_for_nul     in     varchar2  default null
  ,p_ws_over_budget_edit_cd         in     varchar2  default null
  ,p_ws_over_budget_tol_pct         in     number    default null
  ,p_bdgt_over_budget_edit_cd       in     varchar2  default null
  ,p_bdgt_over_budget_tol_pct       in     number    default null
  ,p_auto_distr_flag                in     varchar2  default null
  ,p_pqh_document_short_name        in     varchar2  default null
  ,p_ovrid_rt_strt_dt               in     date      default null
  ,p_do_not_process_flag            in     varchar2  default null
  ,p_ovr_perf_revw_strt_dt          in     date      default null
  ,p_post_zero_salary_increase      in     varchar2  default null
  ,p_show_appraisals_n_days         in     number    default null
  ,p_grade_range_validation         in     varchar2  default null
  ,p_object_version_number          out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_plan_or_option >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates compensation workbench plan and option information.
 *
 * This information is used by all self-service pages that update plan design
 * data.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Plan to update in the database exists.
 *
 * <p><b>Post Success</b><br>
 * The Compensation Workbench Plan will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The Compensation Workbench Plan will be not updated in the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pl_id This parameter specifies the Compensation Workbench Plan.
 * @param p_oipl_id This parameter specifies options for Compensation Workbench
 * Plan.
 * @param p_lf_evt_ocrd_dt {@rep:casecolumn BEN_CWB_PL_DSGN.LF_EVT_OCRD_DT}
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_name This parameter specifies the Compensation Workbench Plan name.
 * @param p_group_pl_id This parameter specifies Compensation Workbench Group
 * Plan.
 * @param p_group_oipl_id This parameter specifies options for a Compensation
 * Workbench Group Plan.
 * @param p_opt_hidden_flag This parameter specifies if the Compensation
 * Workbench Plan options will be displayed in the SS pages.
 * @param p_opt_id This parameter specifies the option and is foreign Key to
 * BEN_OPT_F.
 * @param p_pl_uom This parameter specifies the Compensation Workbench Plan
 * currency.
 * @param p_pl_ordr_num This parameter specifies the Compensation Workbench
 * Plan order number.
 * @param p_oipl_ordr_num This parameter specifies the Compensation Workbench
 * Plan options order number.
 * @param p_pl_xchg_rate This parameter specifies the exchange rate for
 * Compensation Workbench Plan currency.
 * @param p_opt_count This parameter keeps count of plan options.
 * @param p_uses_bdgt_flag This parameter specifies if budgeting is used or
 * not.
 * @param p_prsrv_bdgt_cd This parameter specifies if budget is stored as
 * amount or percentage of eligible salaries.
 * @param p_upd_start_dt Self Service update start date
 * @param p_upd_end_dt Self Service update end date
 * @param p_approval_mode This parameter specifies the approval mode for
 * allocations submission. Valid values are defined in 'BEN_CWB_APPROVAL_MODE'
 * lookup type.
 * @param p_enrt_perd_start_dt {@rep:casecolumn
 * BEN_CWB_PL_DSGN.ENRT_PERD_START_DT}
 * @param p_enrt_perd_end_dt {@rep:casecolumn BEN_CWB_PL_DSGN.ENRT_PERD_END_DT}
 * @param p_yr_perd_start_dt {@rep:casecolumn BEN_CWB_PL_DSGN.YR_PERD_START_DT}
 * @param p_yr_perd_end_dt {@rep:casecolumn BEN_CWB_PL_DSGN.YR_PERD_END_DT}
 * @param p_wthn_yr_start_dt {@rep:casecolumn BEN_CWB_PL_DSGN.WTHN_YR_START_DT}
 * @param p_wthn_yr_end_dt {@rep:casecolumn BEN_CWB_PL_DSGN.WTHN_YR_END_DT}
 * @param p_enrt_perd_id {@rep:casecolumn BEN_CWB_PL_DSGN.ENRT_PERD_ID}
 * @param p_yr_perd_id {@rep:casecolumn BEN_CWB_PL_DSGN.YR_PERD_ID}
 * @param p_business_group_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.BUSINESS_GROUP_ID}
 * @param p_perf_revw_strt_dt {@rep:casecolumn BEN_ENRT_PERD.PERF_REVW_STRT_DT}
 * @param p_asg_updt_eff_date {@rep:casecolumn BEN_ENRT_PERD.ASG_UPDT_EFF_DATE}
 * @param p_emp_interview_typ_cd This parameter specifies the performance
 * rating type. Valid values are defined in 'EMP_INTERVIEW_TYPE' lookup type.
 * @param p_salary_change_reason {@rep:casecolumn
 * BEN_CWB_PL_DSGN.SALARY_CHANGE_REASON}
 * @param p_ws_abr_id This parameter specifies worksheet rate. It is null if no
 * worksheet rate is defined.
 * @param p_ws_nnmntry_uom This parameter specifies the non-monetory units of
 * measure such as stocks.
 * @param p_ws_rndg_cd This parameter specifies the numeric rounding parameter.
 * Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_ws_sub_acty_typ_cd This parameter specifies worksheet rate sub
 * activity type code. Valid values are defined in 'BEN_SUB_ACTY_TYP' lookup
 * type.
 * @param p_dist_bdgt_abr_id This parameter specifies the distribution budget
 * rate.
 * @param p_dist_bdgt_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_dist_bdgt_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_ws_bdgt_abr_id This parameter specifies worksheet budget rate.
 * @param p_ws_bdgt_nnmntry_uom This parameter specifies the non-monetory units
 * of measure such as stocks.
 * @param p_ws_bdgt_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_rsrv_abr_id This parameter specifies the reserve budget rate.
 * @param p_rsrv_nnmntry_uom This parameter specifies the non-monetory units of
 * measure such as stocks.
 * @param p_rsrv_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_elig_sal_abr_id This parameter specifies the eligible salary rate.
 * @param p_elig_sal_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_elig_sal_rndg_cd This parameter specifies the non-monetory units of
 * measure such as stocks.
 * @param p_misc1_abr_id This parameter specifies miscellaneous 1 rate.
 * @param p_misc1_nnmntry_uom This parameter specifies the non-monetory units
 * of measure such as stocks.
 * @param p_misc1_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_misc2_abr_id This parameter specifies miscellaneous 2 rate.
 * @param p_misc2_nnmntry_uom This parameter specifies the non-monetory units
 * of measure such as stocks.
 * @param p_misc2_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_misc3_abr_id This parameter specifies miscellaneous 3 rate.
 * @param p_misc3_nnmntry_uom This parameter specifies the non-monetory units
 * of measure such as stocks.
 * @param p_misc3_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_stat_sal_abr_id This parameter specifies the stated salary rate.
 * @param p_stat_sal_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_stat_sal_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_rec_abr_id This parameter specifies the recommended rate.
 * @param p_rec_nnmntry_uom This parameter specifies the non-monetory units of
 * measure such as stocks.
 * @param p_rec_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_tot_comp_abr_id This parameter specifies the total compensation.
 * @param p_tot_comp_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_tot_comp_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_oth_comp_abr_id This parameter specifies the other compensation.
 * @param p_oth_comp_nnmntry_uom This parameter specifies the non-monetory
 * units of measure such as stocks.
 * @param p_oth_comp_rndg_cd This parameter specifies the numeric rounding
 * parameter. Valid values are defined in 'BEN_RNDG' lookup type.
 * @param p_actual_flag This parameter specifies if balance type is actual or
 * not.
 * @param p_acty_ref_perd_cd This parameter specifies the activity reference
 * period. Valid values are defined in 'BEN_ACTY_REF_PERD' lookup type.
 * @param p_legislation_code This parameter specifies the legislation to which
 * the information type applies. Foreign key is to FND_TERRITORIES.
 * @param p_pl_annulization_factor {@rep:casecolumn
 * BEN_CWB_PL_DSGN.PL_ANNULIZATION_FACTOR}
 * @param p_pl_stat_cd This parameter specifies the plan status code. Valid
 * values are defined in 'BEN_STAT' lookup type.
 * @param p_uom_precision {@rep:casecolumn BEN_CWB_PL_DSGN.UOM_PRECISION}
 * @param p_ws_element_type_id {@rep:casecolumn
 * BEN_CWB_PL_DSGN.WS_ELEMENT_TYPE_ID}
 * @param p_ws_input_value_id {@rep:casecolumn
 * BEN_CWB_PL_DSGN.WS_INPUT_VALUE_ID}
 * @param p_data_freeze_date This parameter specifies the freeze date on which
 * snapshot for Compensation Workbench Person is performed.
 * @param p_ws_amt_edit_cd This parameter specifies the allocations amount edit
 * code.
 * @param p_ws_amt_edit_enf_cd_for_nul This parameter specifies the allocations
 * amount edit code for nulls.
 * @param p_ws_over_budget_edit_cd This parameter specifies allocations over
 * budget edit code.
 * @param p_ws_over_budget_tol_pct This parameter specifies the allocations
 * over budget tolerance percentage.
 * @param p_bdgt_over_budget_edit_cd This parameter specifies the budgets over
 * budget edit code.
 * @param p_bdgt_over_budget_tol_pct This parameter specifies the distribution
 * budget over budget tolerance percentage.
 * @param p_auto_distr_flag This parameter specifies the flag for automatic
 * distribution.
 * @param p_pqh_document_short_name This parameter specifies the short name for
 * PQH (Public sector HR) document.
 * @param p_call_data_syncopation This parameter specifies if the internal
 * procedure, which makes sure that all the child rows, get correct data from
 * parent HR tables.
 * @param p_ovrid_rt_strt_dt This parameter allows the user to override the
 * effective date when post process is run to post data.
 * @param p_do_not_process_flag If yes, then post process skips processing
 * the particular local plan for which it is set.
 * @param p_ovr_perf_revw_strt_dt This parameter overrides the effective date
 * for performance related changes.
 * @param p_post_zero_salary_increase If yes, then post process posts zero
 * salary increase
 * @param p_show_appraisals_n_days This parameter specifies the number of
 * days within which completed appraisals will be shown in worksheet
 * @param p_grade_range_validation This parameter specifies the validation
 * of new salary against the grade range
 * @param p_object_version_number Pass in the current version number of the
 * Compensation Workbench Plan to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Compensation Workbench Plan. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Compensation Workbench Plan
 * @rep:category BUSINESS_ENTITY BEN_CWB_PLAN
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_plan_or_option
  (p_validate                       in     boolean   default false
  ,p_pl_id                          in     number
  ,p_oipl_id                        in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_effective_date                 in     date      default hr_api.g_date
  ,p_name                           in     varchar2  default hr_api.g_varchar2
  ,p_group_pl_id                    in     number    default hr_api.g_number
  ,p_group_oipl_id                  in     number    default hr_api.g_number
  ,p_opt_hidden_flag                in     varchar2  default hr_api.g_varchar2
  ,p_opt_id                         in     number    default hr_api.g_number
  ,p_pl_uom                         in     varchar2  default hr_api.g_varchar2
  ,p_pl_ordr_num                    in     number    default hr_api.g_number
  ,p_oipl_ordr_num                  in     number    default hr_api.g_number
  ,p_pl_xchg_rate                   in     number    default hr_api.g_number
  ,p_opt_count                      in     number    default hr_api.g_number
  ,p_uses_bdgt_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_prsrv_bdgt_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_upd_start_dt                   in     date      default hr_api.g_date
  ,p_upd_end_dt                     in     date      default hr_api.g_date
  ,p_approval_mode                  in     varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_start_dt             in     date      default hr_api.g_date
  ,p_enrt_perd_end_dt               in     date      default hr_api.g_date
  ,p_yr_perd_start_dt               in     date      default hr_api.g_date
  ,p_yr_perd_end_dt                 in     date      default hr_api.g_date
  ,p_wthn_yr_start_dt               in     date      default hr_api.g_date
  ,p_wthn_yr_end_dt                 in     date      default hr_api.g_date
  ,p_enrt_perd_id                   in     number    default hr_api.g_number
  ,p_yr_perd_id                     in     number    default hr_api.g_number
  ,p_business_group_id              in     number    default hr_api.g_number
  ,p_perf_revw_strt_dt              in     date      default hr_api.g_date
  ,p_asg_updt_eff_date              in     date      default hr_api.g_date
  ,p_emp_interview_typ_cd           in     varchar2  default hr_api.g_varchar2
  ,p_salary_change_reason           in     varchar2  default hr_api.g_varchar2
  ,p_ws_abr_id                      in     number    default hr_api.g_number
  ,p_ws_nnmntry_uom                 in     varchar2  default hr_api.g_varchar2
  ,p_ws_rndg_cd                     in     varchar2  default hr_api.g_varchar2
  ,p_ws_sub_acty_typ_cd             in     varchar2  default hr_api.g_varchar2
  ,p_dist_bdgt_abr_id               in     number    default hr_api.g_number
  ,p_dist_bdgt_nnmntry_uom          in     varchar2  default hr_api.g_varchar2
  ,p_dist_bdgt_rndg_cd              in     varchar2  default hr_api.g_varchar2
  ,p_ws_bdgt_abr_id                 in     number    default hr_api.g_number
  ,p_ws_bdgt_nnmntry_uom            in     varchar2  default hr_api.g_varchar2
  ,p_ws_bdgt_rndg_cd                in     varchar2  default hr_api.g_varchar2
  ,p_rsrv_abr_id                    in     number    default hr_api.g_number
  ,p_rsrv_nnmntry_uom               in     varchar2  default hr_api.g_varchar2
  ,p_rsrv_rndg_cd                   in     varchar2  default hr_api.g_varchar2
  ,p_elig_sal_abr_id                in     number    default hr_api.g_number
  ,p_elig_sal_nnmntry_uom           in     varchar2  default hr_api.g_varchar2
  ,p_elig_sal_rndg_cd               in     varchar2  default hr_api.g_varchar2
  ,p_misc1_abr_id                   in     number    default hr_api.g_number
  ,p_misc1_nnmntry_uom              in     varchar2  default hr_api.g_varchar2
  ,p_misc1_rndg_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_misc2_abr_id                   in     number    default hr_api.g_number
  ,p_misc2_nnmntry_uom              in     varchar2  default hr_api.g_varchar2
  ,p_misc2_rndg_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_misc3_abr_id                   in     number    default hr_api.g_number
  ,p_misc3_nnmntry_uom              in     varchar2  default hr_api.g_varchar2
  ,p_misc3_rndg_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_stat_sal_abr_id                in     number    default hr_api.g_number
  ,p_stat_sal_nnmntry_uom           in     varchar2  default hr_api.g_varchar2
  ,p_stat_sal_rndg_cd               in     varchar2  default hr_api.g_varchar2
  ,p_rec_abr_id                     in     number    default hr_api.g_number
  ,p_rec_nnmntry_uom                in     varchar2  default hr_api.g_varchar2
  ,p_rec_rndg_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_tot_comp_abr_id                in     number    default hr_api.g_number
  ,p_tot_comp_nnmntry_uom           in     varchar2  default hr_api.g_varchar2
  ,p_tot_comp_rndg_cd               in     varchar2  default hr_api.g_varchar2
  ,p_oth_comp_abr_id                in     number    default hr_api.g_number
  ,p_oth_comp_nnmntry_uom           in     varchar2  default hr_api.g_varchar2
  ,p_oth_comp_rndg_cd               in     varchar2  default hr_api.g_varchar2
  ,p_actual_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in     varchar2  default hr_api.g_varchar2
  ,p_pl_annulization_factor         in     number    default hr_api.g_number
  ,p_pl_stat_cd                     in     varchar2  default hr_api.g_varchar2
  ,p_uom_precision                  in     number    default hr_api.g_number
  ,p_ws_element_type_id             in     number    default hr_api.g_number
  ,p_ws_input_value_id              in     number    default hr_api.g_number
  ,p_data_freeze_date               in     date      default hr_api.g_date
  ,p_ws_amt_edit_cd                 in     varchar2  default hr_api.g_varchar2
  ,p_ws_amt_edit_enf_cd_for_nul     in     varchar2  default hr_api.g_varchar2
  ,p_ws_over_budget_edit_cd         in     varchar2  default hr_api.g_varchar2
  ,p_ws_over_budget_tol_pct         in     number    default hr_api.g_number
  ,p_bdgt_over_budget_edit_cd       in     varchar2  default hr_api.g_varchar2
  ,p_bdgt_over_budget_tol_pct       in     number    default hr_api.g_number
  ,p_auto_distr_flag                in     varchar2  default hr_api.g_varchar2
  ,p_pqh_document_short_name        in     varchar2  default hr_api.g_varchar2
  ,p_call_data_syncopation          in     varchar2  default 'Y'
  ,p_ovrid_rt_strt_dt               in     date      default hr_api.g_date
  ,p_do_not_process_flag            in     varchar2  default 'N'
  ,p_ovr_perf_revw_strt_dt          in     date      default hr_api.g_date
  ,p_post_zero_salary_increase      in     varchar2  default hr_api.g_varchar2
  ,p_show_appraisals_n_days         in     number    default hr_api.g_number
  ,p_grade_range_validation         in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_plan_or_option >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes compensation workbench plan and option information.
 *
 * Any self-service page which deletes plan design data uses this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Plan to delete exists in the database.
 *
 * <p><b>Post Success</b><br>
 * The Compensation Workbench Plan will be deleted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The Compensation Workbench Plan will be not deleted from the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pl_id This parameter specifies the Compensation Workbench Plan.
 * @param p_oipl_id This Parameter specifies the options for Compensation
 * Workbench Plan.
 * @param p_lf_evt_ocrd_dt {@rep:casecolumn BEN_CWB_PL_DSGN.LF_EVT_OCRD_DT}
 * @param p_object_version_number Current version number of the Compensation
 * Workbench Plan to be deleted.
 * @rep:displayname Delete Compensation Workbench Plan
 * @rep:category BUSINESS_ENTITY BEN_CWB_PLAN
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_plan_or_option
  (p_validate                     in     boolean  default false
  ,p_pl_id                        in     number
  ,p_oipl_id                      in     number
  ,p_lf_evt_ocrd_dt               in     date
  ,p_object_version_number        in     number
  );
end BEN_CWB_PL_DSGN_API;

/
