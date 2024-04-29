--------------------------------------------------------
--  DDL for Package BEN_CPD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPD_UPD" AUTHID CURRENT_USER as
/* $Header: becpdrhi.pkh 120.1.12010000.3 2010/03/12 06:10:29 sgnanama ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< upd >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy ben_cpd_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_pl_id                          in     number
  ,p_oipl_id                        in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_object_version_number          in out nocopy number
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
  ,p_ovrid_rt_strt_dt               in     date      default hr_api.g_date
  ,p_do_not_process_flag            in     varchar2  default hr_api.g_varchar2
  ,p_ovr_perf_revw_strt_dt          in     date      default hr_api.g_date
  ,p_post_zero_salary_increase      in     varchar2  default hr_api.g_varchar2
  ,p_show_appraisals_n_days         in     number    default hr_api.g_number
  ,p_grade_range_validation         in     varchar2  default hr_api.g_varchar2
  );
--
end ben_cpd_upd;

/
