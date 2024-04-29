--------------------------------------------------------
--  DDL for Package PER_APT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APT_UPD" AUTHID CURRENT_USER as
/* $Header: peaptrhi.pkh 120.2.12010000.4 2010/02/09 15:10:29 psugumar ship $ */
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
--   1) If the p_validate parameter has been set to true then a savepoint
--      is issued.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--   8) If the p_validate parameter has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     process and is rollbacked at the end of the process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the
--     process, we can exit successfully without having any of the 'OUT'
--     parameters being set.
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
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
  p_rec        		in out nocopy per_apt_shd.g_rec_type,
  p_effective_date	in date,
  p_validate   		in     boolean default false
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
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Pre Conditions:
--
-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
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
  p_appraisal_template_id        in number,

  p_object_version_number        in out nocopy number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_instructions                 in varchar2         default hr_api.g_varchar2,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_assessment_type_id           in number           default hr_api.g_number,
  p_rating_scale_id              in number           default hr_api.g_number,
  p_questionnaire_template_id    in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2
  ,p_objective_asmnt_type_id      in     number    default hr_api.g_number
  ,p_ma_quest_template_id         in     number    default hr_api.g_number
  ,p_link_appr_to_learning_path   in     varchar2  default hr_api.g_varchar2
  ,p_final_score_formula_id       in     number    default hr_api.g_number
  ,p_update_personal_comp_profile in     varchar2  default hr_api.g_varchar2
  ,p_comp_profile_source_type     in     varchar2  default hr_api.g_varchar2
  ,p_show_competency_ratings      in     varchar2  default hr_api.g_varchar2
  ,p_show_objective_ratings       in     varchar2  default hr_api.g_varchar2
  ,p_show_overall_ratings         in     varchar2  default hr_api.g_varchar2
  ,p_show_overall_comments        in     varchar2  default hr_api.g_varchar2
  ,p_provide_overall_feedback     in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_details     in     varchar2  default hr_api.g_varchar2
  ,p_allow_add_participant        in     varchar2  default hr_api.g_varchar2
  ,p_show_additional_details      in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_names       in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_ratings     in     varchar2  default hr_api.g_varchar2
  ,p_available_flag               in     varchar2  default hr_api.g_varchar2
  ,p_show_questionnaire_info        in varchar2 default hr_api.g_varchar2,
  p_effective_date		 in date
  ,p_ma_off_template_code		      in varchar2 	  default hr_api.g_varchar2
  ,p_appraisee_off_template_code  in varchar2	    default hr_api.g_varchar2
  ,p_other_part_off_template_code in varchar2	    default hr_api.g_varchar2
  ,p_part_app_off_template_code	  in varchar2	    default hr_api.g_varchar2
  ,p_part_rev_off_template_code	  in varchar2	    default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  ,p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix

  ,p_show_term_employee            in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default hr_api.g_number  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix

  );
--
end per_apt_upd;

/
