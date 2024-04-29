--------------------------------------------------------
--  DDL for Package PER_APR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APR_UPD" AUTHID CURRENT_USER as
/* $Header: peaprrhi.pkh 120.2.12010000.3 2009/08/12 14:18:24 rvagvala ship $ */

-- ---------------------------------------------------------------------------+
-- |---------------------------------< upd >----------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

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

-- Pre Conditions:
--   The main parameters to the business process have to be in the record
--   format.

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

-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.

-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.

-- Developer Implementation Notes:
--   None.

-- Access Status:
--   Internal Development Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure upd
  (
  p_rec        		in out nocopy per_apr_shd.g_rec_type,
  p_effective_date	in date,
  p_validate   		in     boolean default false
  );

-- ---------------------------------------------------------------------------+
-- |---------------------------------< upd >----------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

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

-- Pre Conditions:

-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.

-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).

-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.

-- Developer Implementation Notes:
--   None.

-- Access Status:
--   Internal Development Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure upd
  (
  p_appraisal_id                 in number,
  p_object_version_number        in out nocopy number,
  p_appraiser_person_id          in number,
  p_appraisal_date    		 in date             default hr_api.g_date,
  p_appraisal_period_end_date    in date             default hr_api.g_date,
  p_appraisal_period_start_date  in date             default hr_api.g_date,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_next_appraisal_date          in date             default hr_api.g_date,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_overall_performance_level_id in number           default hr_api.g_number,
  p_open                         in varchar2         default hr_api.g_varchar2,
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
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_effective_date		 in date,
  p_system_type                  in varchar2         default hr_api.g_varchar2,
  p_system_params                in varchar2         default hr_api.g_varchar2,
  p_appraisee_access             in varchar2         default hr_api.g_varchar2,
  p_main_appraiser_id            in number           default hr_api.g_number,
  p_assignment_id                in number           default hr_api.g_number,
  p_assignment_start_date        in date             default hr_api.g_date,
  p_asg_business_group_id        in number 	     default hr_api.g_number,
  p_assignment_organization_id   in number           default hr_api.g_number,
  p_assignment_job_id            in number           default hr_api.g_number,
  p_assignment_position_id       in number           default hr_api.g_number,
  p_assignment_grade_id          in number           default hr_api.g_number,
  p_appraisal_system_status      in varchar2         default hr_api.g_varchar2,
  p_potential_readiness_level    in varchar2         default hr_api.g_varchar2,
  p_potential_short_term_workopp in varchar2         default hr_api.g_varchar2,
  p_potential_long_term_workopp  in varchar2         default hr_api.g_varchar2,
  p_potential_details            in varchar2         default hr_api.g_varchar2,
  p_event_id                     in number           default hr_api.g_number,
  p_show_competency_ratings      in varchar2         default hr_api.g_varchar2,
  p_show_objective_ratings       in varchar2         default hr_api.g_varchar2,
  p_show_questionnaire_info      in varchar2         default hr_api.g_varchar2,
  p_show_participant_details     in varchar2         default hr_api.g_varchar2,
  p_show_participant_ratings     in varchar2         default hr_api.g_varchar2,
  p_show_participant_names       in varchar2         default hr_api.g_varchar2,
  p_show_overall_ratings         in varchar2         default hr_api.g_varchar2,
  p_show_overall_comments        in varchar2         default hr_api.g_varchar2,
  p_update_appraisal             in varchar2         default hr_api.g_varchar2,
  p_provide_overall_feedback     in varchar2         default hr_api.g_varchar2,
  p_appraisee_comments           in varchar2         default hr_api.g_varchar2,
  p_plan_id                      in number           default hr_api.g_number,
  p_offline_status               in varchar2         default hr_api.g_varchar2,
  p_retention_potential                in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
 p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix
  );

end per_apr_upd;

/
