--------------------------------------------------------
--  DDL for Package PER_APT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APT_SHD" AUTHID CURRENT_USER as
/* $Header: peaptrhi.pkh 120.2.12010000.4 2010/02/09 15:10:29 psugumar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  appraisal_template_id             number(15),
  business_group_id                 number(15),
  object_version_number             number(9),
  name                              varchar2(80),
  description                       varchar2(2000),
  instructions                      varchar2(2000),
  date_from                         date,
  date_to                           date,
  assessment_type_id                number(9),
  rating_scale_id                   number(9),
  questionnaire_template_id         number,
  attribute_category                varchar2(30),
  attribute1                        varchar2(150),
  attribute2                        varchar2(150),
  attribute3                        varchar2(150),
  attribute4                        varchar2(150),
  attribute5                        varchar2(150),
  attribute6                        varchar2(150),
  attribute7                        varchar2(150),
  attribute8                        varchar2(150),
  attribute9                        varchar2(150),
  attribute10                       varchar2(150),
  attribute11                       varchar2(150),
  attribute12                       varchar2(150),
  attribute13                       varchar2(150),
  attribute14                       varchar2(150),
  attribute15                       varchar2(150),
  attribute16                       varchar2(150),
  attribute17                       varchar2(150),
  attribute18                       varchar2(150),
  attribute19                       varchar2(150),
  attribute20                       varchar2(150),
  objective_asmnt_type_id         number(9),
  ma_quest_template_id            number,
  link_appr_to_learning_path      varchar2(30),
  final_score_formula_id          number(9),
  update_personal_comp_profile    varchar2(30),
  comp_profile_source_type        varchar2(150),
  show_competency_ratings         varchar2(30),
  show_objective_ratings          varchar2(30),
  show_overall_ratings            varchar2(30),
  show_overall_comments           varchar2(30),
  provide_overall_feedback        varchar2(30),
  show_participant_details        varchar2(30),
  allow_add_participant           varchar2(30),
  show_additional_details         varchar2(30),
  show_participant_names          varchar2(30),
  show_participant_ratings        varchar2(30),
  available_flag                  varchar2(30),
  show_questionnaire_info         varchar2(30),
  ma_off_template_code			      varchar2(80),
  appraisee_off_template_code	    varchar2(80),
  other_part_off_template_code	  varchar2(80),
  part_rev_off_template_code	    varchar2(80),
  part_app_off_template_code  	  varchar2(80),
show_participant_comments          varchar2(30)  -- 8651478 bug fix

    ,show_term_employee            varchar2(30) -- 6181267 bug fix
    ,show_term_contigent           varchar2(30)  -- 6181267 bug fix
    ,disp_term_emp_period_from     number(30)   -- 6181267 bug fix
    ,SHOW_FUTURE_TERM_EMPLOYEE          varchar2(30) -- 6181267 bug fix

  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Pre Conditions:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which corresponds with a constraint error.
--
-- In Parameter:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_appraisal_template_id              in number,
  p_object_version_number              in number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from the
--   server to be available to the api.
--
-- Pre Conditions:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Parameters:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version number of row.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   For each primary key and the object version number arguments add a
--   call to hr_api.mandatory_arg_error procedure to ensure that these
--   argument values are not null.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_appraisal_template_id              in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute parameters into the record
--   structure parameter g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_appraisal_template_id         in number,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_name                          in varchar2,
	p_description                   in varchar2,
	p_instructions                  in varchar2,
	p_date_from                     in date,
	p_date_to                       in date,
	p_assessment_type_id            in number,
	p_rating_scale_id               in number,
	p_questionnaire_template_id     in number,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
	p_objective_asmnt_type_id        in number,
	p_ma_quest_template_id           in number,
	p_link_appr_to_learning_path     in varchar2,
	p_final_score_formula_id         in number,
	p_update_personal_comp_profile   in varchar2,
	p_comp_profile_source_type       in varchar2,
	p_show_competency_ratings        in varchar2,
	p_show_objective_ratings         in varchar2,
	p_show_overall_ratings           in varchar2,
	p_show_overall_comments          in varchar2,
	p_provide_overall_feedback       in varchar2,
	p_show_participant_details       in varchar2,
	p_allow_add_participant          in varchar2,
	p_show_additional_details        in varchar2,
	p_show_participant_names         in varchar2,
	p_show_participant_ratings       in varchar2,
	p_available_flag                 in varchar2,
	p_show_questionnaire_info        in varchar2,
  p_ma_off_template_code			     in varchar2,
  p_apraisee_off_template_code 	   in	varchar2,
  p_other_part_off_template_code	 in	varchar2,
  p_part_app_off_template_code  	 in varchar2,
  p_part_rev_off_template_code	   in	varchar2,
p_show_participant_comments     in varchar2   -- 8651478 bug fix

  ,p_show_term_employee            in varchar2 -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2 -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2 -- 6181267 bug fix
	)
	Return g_rec_type;
--
end per_apt_shd;

/
