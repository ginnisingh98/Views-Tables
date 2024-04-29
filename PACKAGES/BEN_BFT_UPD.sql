--------------------------------------------------------
--  DDL for Package BEN_BFT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BFT_UPD" AUTHID CURRENT_USER as
/* $Header: bebftrhi.pkh 120.0 2005/05/28 00:40:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
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
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  (
  p_effective_date               in date,
  p_rec        in out nocopy ben_bft_shd.g_rec_type
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
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  (
  p_effective_date               in date,
  p_benefit_action_id            in number,
  p_process_date                 in date             default hr_api.g_date,
  p_uneai_effective_date         in date             default hr_api.g_date,
  p_mode_cd                      in varchar2         default hr_api.g_varchar2,
  p_derivable_factors_flag       in varchar2         default hr_api.g_varchar2,
  p_close_uneai_flag             in varchar2         default hr_api.g_varchar2,
  p_validate_flag                in varchar2         default hr_api.g_varchar2,
  p_person_id                    in number           default hr_api.g_number,
  p_person_type_id               in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_popl_enrt_typ_cycl_id        in number           default hr_api.g_number,
  p_no_programs_flag             in varchar2         default hr_api.g_varchar2,
  p_no_plans_flag                in varchar2         default hr_api.g_varchar2,
  p_comp_selection_rl            in number           default hr_api.g_number,
  p_person_selection_rl          in number           default hr_api.g_number,
  p_ler_id                       in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_benfts_grp_id                in number           default hr_api.g_number,
  p_location_id                  in number           default hr_api.g_number,
  p_pstl_zip_rng_id              in number           default hr_api.g_number,
  p_rptg_grp_id                  in number           default hr_api.g_number,
  p_pl_typ_id                    in number           default hr_api.g_number,
  p_opt_id                       in number           default hr_api.g_number,
  p_eligy_prfl_id                in number           default hr_api.g_number,
  p_vrbl_rt_prfl_id              in number           default hr_api.g_number,
  p_legal_entity_id              in number           default hr_api.g_number,
  p_payroll_id                   in number           default hr_api.g_number,
  p_debug_messages_flag          in varchar2         default hr_api.g_varchar2,
  p_cm_trgr_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_cm_typ_id                    in number           default hr_api.g_number,
  p_age_fctr_id                  in number           default hr_api.g_number,
  p_min_age                      in number           default hr_api.g_number,
  p_max_age                      in number           default hr_api.g_number,
  p_los_fctr_id                  in number           default hr_api.g_number,
  p_min_los                      in number           default hr_api.g_number,
  p_max_los                      in number           default hr_api.g_number,
  p_cmbn_age_los_fctr_id         in number           default hr_api.g_number,
  p_min_cmbn                     in number           default hr_api.g_number,
  p_max_cmbn                     in number           default hr_api.g_number,
  p_date_from                    in date             default hr_api.g_date,
  p_elig_enrol_cd                in varchar2         default hr_api.g_varchar2,
  p_actn_typ_id                  in number           default hr_api.g_number,
  p_use_fctr_to_sel_flag         in varchar2         default hr_api.g_varchar2,
  p_los_det_to_use_cd            in varchar2         default hr_api.g_varchar2,
  p_audit_log_flag               in varchar2         default hr_api.g_varchar2,
  p_lmt_prpnip_by_org_flag       in varchar2         default hr_api.g_varchar2,
  p_lf_evt_ocrd_dt               in date             default hr_api.g_date,
  p_ptnl_ler_for_per_stat_cd     in varchar2         default hr_api.g_varchar2,
  p_bft_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_bft_attribute1               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute3               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute4               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute5               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute6               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute7               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute8               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute9               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute10              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute11              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute12              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute13              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute14              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute15              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute16              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute17              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute18              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute19              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute20              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute21              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute22              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute23              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute24              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute25              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute26              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute27              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute28              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute29              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute30              in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_enrt_perd_id                 in number           default hr_api.g_number,
  p_inelg_action_cd              in varchar2         default hr_api.g_varchar2,
  p_org_hierarchy_id              in number         default hr_api.g_number,
  p_org_starting_node_id              in number         default hr_api.g_number,
  p_grade_ladder_id              in number         default hr_api.g_number,
  p_asg_events_to_all_sel_dt              in varchar2         default hr_api.g_varchar2,
  p_rate_id              in number         default hr_api.g_number,
  p_per_sel_dt_cd              in varchar2         default hr_api.g_varchar2,
  p_per_sel_freq_cd              in varchar2         default hr_api.g_varchar2,
  p_per_sel_dt_from              in date         default hr_api.g_date,
  p_per_sel_dt_to              in date         default hr_api.g_date,
  p_year_from              in number         default hr_api.g_number,
  p_year_to              in number         default hr_api.g_number,
  p_cagr_id              in number         default hr_api.g_number,
  p_qual_type              in number         default hr_api.g_number,
  p_qual_status              in varchar2         default hr_api.g_varchar2,
  p_concat_segs              in varchar2         default hr_api.g_varchar2,
  p_grant_price_val              in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number
  );
--
end ben_bft_upd;

 

/
