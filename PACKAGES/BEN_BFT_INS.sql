--------------------------------------------------------
--  DDL for Package BEN_BFT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BFT_INS" AUTHID CURRENT_USER as
/* $Header: bebftrhi.pkh 120.0 2005/05/28 00:40:56 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
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
Procedure ins
  (
  p_effective_date               in date,
  p_rec        in out nocopy ben_bft_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (
  p_effective_date               in date,
  p_benefit_action_id            out nocopy number,
  p_process_date                 in date,
  p_uneai_effective_date         in date,
  p_mode_cd                      in varchar2,
  p_derivable_factors_flag       in varchar2,
  p_close_uneai_flag             in varchar2,
  p_validate_flag                in varchar2,
  p_person_id                    in number           default null,
  p_person_type_id               in number           default null,
  p_pgm_id                       in number           default null,
  p_business_group_id            in number,
  p_pl_id                        in number           default null,
  p_popl_enrt_typ_cycl_id        in number           default null,
  p_no_programs_flag             in varchar2,
  p_no_plans_flag                in varchar2,
  p_comp_selection_rl            in number           default null,
  p_person_selection_rl          in number           default null,
  p_ler_id                       in number           default null,
  p_organization_id              in number           default null,
  p_benfts_grp_id                in number           default null,
  p_location_id                  in number           default null,
  p_pstl_zip_rng_id              in number           default null,
  p_rptg_grp_id                  in number           default null,
  p_pl_typ_id                    in number           default null,
  p_opt_id                       in number           default null,
  p_eligy_prfl_id                in number           default null,
  p_vrbl_rt_prfl_id              in number           default null,
  p_legal_entity_id              in number           default null,
  p_payroll_id                   in number           default null,
  p_debug_messages_flag          in varchar2,
  p_cm_trgr_typ_cd               in varchar2         default null,
  p_cm_typ_id                    in number           default null,
  p_age_fctr_id                  in number           default null,
  p_min_age                      in number           default null,
  p_max_age                      in number           default null,
  p_los_fctr_id                  in number           default null,
  p_min_los                      in number           default null,
  p_max_los                      in number           default null,
  p_cmbn_age_los_fctr_id         in number           default null,
  p_min_cmbn                     in number           default null,
  p_max_cmbn                     in number           default null,
  p_date_from                    in date             default null,
  p_elig_enrol_cd                in varchar2         default null,
  p_actn_typ_id                  in number           default null,
  p_use_fctr_to_sel_flag         in varchar2         default 'N',
  p_los_det_to_use_cd            in varchar2         default null,
  p_audit_log_flag               in varchar2         default 'N',
  p_lmt_prpnip_by_org_flag       in varchar2         default 'N',
  p_lf_evt_ocrd_dt               in date             default null,
  p_ptnl_ler_for_per_stat_cd     in varchar2         default null,
  p_bft_attribute_category       in varchar2         default null,
  p_bft_attribute1               in varchar2         default null,
  p_bft_attribute3               in varchar2         default null,
  p_bft_attribute4               in varchar2         default null,
  p_bft_attribute5               in varchar2         default null,
  p_bft_attribute6               in varchar2         default null,
  p_bft_attribute7               in varchar2         default null,
  p_bft_attribute8               in varchar2         default null,
  p_bft_attribute9               in varchar2         default null,
  p_bft_attribute10              in varchar2         default null,
  p_bft_attribute11              in varchar2         default null,
  p_bft_attribute12              in varchar2         default null,
  p_bft_attribute13              in varchar2         default null,
  p_bft_attribute14              in varchar2         default null,
  p_bft_attribute15              in varchar2         default null,
  p_bft_attribute16              in varchar2         default null,
  p_bft_attribute17              in varchar2         default null,
  p_bft_attribute18              in varchar2         default null,
  p_bft_attribute19              in varchar2         default null,
  p_bft_attribute20              in varchar2         default null,
  p_bft_attribute21              in varchar2         default null,
  p_bft_attribute22              in varchar2         default null,
  p_bft_attribute23              in varchar2         default null,
  p_bft_attribute24              in varchar2         default null,
  p_bft_attribute25              in varchar2         default null,
  p_bft_attribute26              in varchar2         default null,
  p_bft_attribute27              in varchar2         default null,
  p_bft_attribute28              in varchar2         default null,
  p_bft_attribute29              in varchar2         default null,
  p_bft_attribute30              in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_enrt_perd_id                 in number           default null,
  p_inelg_action_cd              in varchar2         default null,
  p_org_hierarchy_id              in number         default null,
  p_org_starting_node_id              in number         default null,
  p_grade_ladder_id              in number         default null,
  p_asg_events_to_all_sel_dt              in varchar2         default null,
  p_rate_id              in number         default null,
  p_per_sel_dt_cd              in varchar2         default null,
  p_per_sel_freq_cd              in varchar2         default null,
  p_per_sel_dt_from              in date         default null,
  p_per_sel_dt_to              in date         default null,
  p_year_from              in number         default null,
  p_year_to              in number         default null,
  p_cagr_id              in number         default null,
  p_qual_type              in number         default null,
  p_qual_status              in varchar2         default null,
  p_concat_segs              in varchar2         default null,
  p_grant_price_val              in number           default null,
  p_object_version_number        out nocopy number
  );
--
end ben_bft_ins;

 

/
