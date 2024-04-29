--------------------------------------------------------
--  DDL for Package PER_APR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APR_INS" AUTHID CURRENT_USER as
/* $Header: peaprrhi.pkh 120.2.12010000.3 2009/08/12 14:18:24 rvagvala ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_appraisal_id  in  number);
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< ins >----------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) If the p_validate parameter has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   6) If the p_validate parameter has been set to true an exception is
--      raised which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.

-- Pre Conditions:
--   The main parameters to the this process have to be in the record
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
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     parameters being set.

-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate parameter has been set to true
--   then all the work will be rolled back.

-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.

-- Developer Implementation Notes:
--   None.

-- Access Status:
--   Internal Development Use Only.

-- {End Of Comments}

-- ---------------------------------------------------------------------------+
Procedure ins
  (
  p_rec        		in out nocopy per_apr_shd.g_rec_type,
  p_effective_date 	in date ,
  p_validate   		in     boolean default false
  );

-- ---------------------------------------------------------------------------+
-- |---------------------------------< ins >----------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

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

-- Pre Conditions:

-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.

-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (
  p_appraisal_id                 out nocopy number,
  p_business_group_id            in number,
  p_object_version_number        out nocopy number,
  p_appraisal_template_id        in number,
  p_appraisee_person_id          in number,
  p_appraiser_person_id          in number,
  p_appraisal_date               in date	     default null,
  p_appraisal_period_end_date    in date,
  p_appraisal_period_start_date  in date,
  p_type                         in varchar2         default null,
  p_next_appraisal_date          in date             default null,
  p_status                       in varchar2         default null,
  p_group_date			 in date 	     default null,
  p_group_initiator_id	 	 in number	     default null,
  p_comments                     in varchar2         default null,
  p_overall_performance_level_id in number           default null,
  p_open                         in varchar2         default 'Y',
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_effective_date		 in date,
  p_system_type                  in varchar2        default null,
  p_system_params                in varchar2        default null,
  p_appraisee_access             in varchar2        default null,
  p_main_appraiser_id            in number          default null,
  p_assignment_id                in number          default null,
  p_assignment_start_date        in date            default null,
  p_asg_business_group_id        in number          default null,
  p_assignment_organization_id   in number          default null,
  p_assignment_job_id            in number          default null,
  p_assignment_position_id       in number          default null,
  p_assignment_grade_id          in number          default null,
  p_appraisal_system_status      in varchar2        default null,
  p_potential_readiness_level    in varchar2        default null,
  p_potential_short_term_workopp in varchar2        default null,
  p_potential_long_term_workopp  in varchar2        default null,
  p_potential_details            in varchar2        default null,
  p_event_id                     in number          default null,
  p_show_competency_ratings      in varchar2        default null,
  p_show_objective_ratings       in varchar2        default null,
  p_show_questionnaire_info      in varchar2        default null,
  p_show_participant_details     in varchar2        default null,
  p_show_participant_ratings     in varchar2        default null,
  p_show_participant_names       in varchar2        default null,
  p_show_overall_ratings         in varchar2        default null,
  p_show_overall_comments        in varchar2        default null,
  p_update_appraisal             in varchar2        default null,
  p_provide_overall_feedback     in varchar2        default null,
  p_appraisee_comments           in varchar2        default null,
  p_plan_id                      in number          default null,
  p_offline_status               in varchar2        default null,
  p_retention_potential          in varchar2           default null,
  p_validate                     in boolean         default false,
p_show_participant_comments     in varchar2            default null  -- 8651478 bug fix
    );

end per_apr_ins;

/
