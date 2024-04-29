--------------------------------------------------------
--  DDL for Package BEN_CPI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPI_SHD" AUTHID CURRENT_USER as
/* $Header: becpirhi.pkh 120.0 2005/05/28 01:13:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (group_per_in_ler_id             number(15)
  ,assignment_id                   number(15)
  ,person_id                       number(15)
  ,supervisor_id                   number(15)
  ,effective_date                  date
  ,full_name                       varchar2(240)
  ,brief_name                      varchar2(360)
  ,custom_name                     varchar2(480)
  ,supervisor_full_name            varchar2(240)
  ,supervisor_brief_name           varchar2(360)
  ,supervisor_custom_name          varchar2(480)
  ,legislation_code                varchar2(30)
  ,years_employed                  number
  ,years_in_job                    number
  ,years_in_position               number
  ,years_in_grade                  number
  ,employee_number                 varchar2(30)
  ,start_date                      date
  ,original_start_date             date
  ,adjusted_svc_date               date
  ,base_salary                     number
  ,base_salary_change_date         date
  ,payroll_name                    varchar2(80)
  ,performance_rating              varchar2(30)
  ,performance_rating_type         varchar2(30)
  ,performance_rating_date         date
  ,business_group_id               number(15)
  ,organization_id                 number(15)
  ,job_id                          number(15)
  ,grade_id                        number(15)
  ,position_id                     number(15)
  ,people_group_id                 number(15)
  ,soft_coding_keyflex_id          number(15)
  ,location_id                     number(15)
  ,pay_rate_id                     number(15)
  ,assignment_status_type_id       number(15)
  ,frequency                       varchar2(30)
  ,grade_annulization_factor       number
  ,pay_annulization_factor         number
  ,grd_min_val                     number
  ,grd_max_val                     number
  ,grd_mid_point                   number
  ,grd_quartile                    varchar2(30)
  ,grd_comparatio                  number
  ,emp_category                    varchar2(30)
  ,change_reason                   varchar2(30)
  ,normal_hours                    number
  ,email_address                   varchar2(240)
  ,base_salary_frequency           varchar2(30)
  ,new_assgn_ovn                   number(9)
  ,new_perf_event_id               number(15)
  ,new_perf_review_id              number(15)
  ,post_process_stat_cd            varchar2(30)
  ,feedback_rating                 varchar2(30)
  ,feedback_comments               varchar2(2000)
  ,object_version_number           number(9)
  ,custom_segment1                 varchar2(150)
  ,custom_segment2                 varchar2(150)
  ,custom_segment3                 varchar2(150)
  ,custom_segment4                 varchar2(150)
  ,custom_segment5                 varchar2(150)
  ,custom_segment6                 varchar2(150)
  ,custom_segment7                 varchar2(150)
  ,custom_segment8                 varchar2(150)
  ,custom_segment9                 varchar2(150)
  ,custom_segment10                varchar2(150)
  ,custom_segment11                number
  ,custom_segment12                number
  ,custom_segment13                number
  ,custom_segment14                number
  ,custom_segment15                number
  ,custom_segment16                number
  ,custom_segment17                number
  ,custom_segment18                number
  ,custom_segment19                number
  ,custom_segment20                number
  ,people_group_name               varchar2(240)
  ,people_group_segment1           varchar2(60)
  ,people_group_segment2           varchar2(60)
  ,people_group_segment3           varchar2(60)
  ,people_group_segment4           varchar2(60)
  ,people_group_segment5           varchar2(60)
  ,people_group_segment6           varchar2(60)
  ,people_group_segment7           varchar2(60)
  ,people_group_segment8           varchar2(60)
  ,people_group_segment9           varchar2(60)
  ,people_group_segment10          varchar2(60)
  ,people_group_segment11          varchar2(60)
  ,ass_attribute_category          varchar2(30)
  ,ass_attribute1                  varchar2(150)
  ,ass_attribute2                  varchar2(150)
  ,ass_attribute3                  varchar2(150)
  ,ass_attribute4                  varchar2(150)
  ,ass_attribute5                  varchar2(150)
  ,ass_attribute6                  varchar2(150)
  ,ass_attribute7                  varchar2(150)
  ,ass_attribute8                  varchar2(150)
  ,ass_attribute9                  varchar2(150)
  ,ass_attribute10                 varchar2(150)
  ,ass_attribute11                 varchar2(150)
  ,ass_attribute12                 varchar2(150)
  ,ass_attribute13                 varchar2(150)
  ,ass_attribute14                 varchar2(150)
  ,ass_attribute15                 varchar2(150)
  ,ass_attribute16                 varchar2(150)
  ,ass_attribute17                 varchar2(150)
  ,ass_attribute18                 varchar2(150)
  ,ass_attribute19                 varchar2(150)
  ,ass_attribute20                 varchar2(150)
  ,ass_attribute21                 varchar2(150)
  ,ass_attribute22                 varchar2(150)
  ,ass_attribute23                 varchar2(150)
  ,ass_attribute24                 varchar2(150)
  ,ass_attribute25                 varchar2(150)
  ,ass_attribute26                 varchar2(150)
  ,ass_attribute27                 varchar2(150)
  ,ass_attribute28                 varchar2(150)
  ,ass_attribute29                 varchar2(150)
  ,ass_attribute30                 varchar2(150)
  ,ws_comments                     varchar2(2000)
  ,cpi_attribute_category          varchar2(30)
  ,cpi_attribute1                  varchar2(150)
  ,cpi_attribute2                  varchar2(150)
  ,cpi_attribute3                  varchar2(150)
  ,cpi_attribute4                  varchar2(150)
  ,cpi_attribute5                  varchar2(150)
  ,cpi_attribute6                  varchar2(150)
  ,cpi_attribute7                  varchar2(150)
  ,cpi_attribute8                  varchar2(150)
  ,cpi_attribute9                  varchar2(150)
  ,cpi_attribute10                 varchar2(150)
  ,cpi_attribute11                 varchar2(150)
  ,cpi_attribute12                 varchar2(150)
  ,cpi_attribute13                 varchar2(150)
  ,cpi_attribute14                 varchar2(150)
  ,cpi_attribute15                 varchar2(150)
  ,cpi_attribute16                 varchar2(150)
  ,cpi_attribute17                 varchar2(150)
  ,cpi_attribute18                 varchar2(150)
  ,cpi_attribute19                 varchar2(150)
  ,cpi_attribute20                 varchar2(150)
  ,cpi_attribute21                 varchar2(150)
  ,cpi_attribute22                 varchar2(150)
  ,cpi_attribute23                 varchar2(150)
  ,cpi_attribute24                 varchar2(150)
  ,cpi_attribute25                 varchar2(150)
  ,cpi_attribute26                 varchar2(150)
  ,cpi_attribute27                 varchar2(150)
  ,cpi_attribute28                 varchar2(150)
  ,cpi_attribute29                 varchar2(150)
  ,cpi_attribute30                 varchar2(150)
  ,feedback_date                   date
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'BEN_CWB_PERSON_INFO';
g_api_dml  boolean;                               -- Global api dml status
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean;
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
-- Prerequisites:
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
--  {Start Of Comments}
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
-- Prerequisites:
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
  (p_group_per_in_ler_id                  in     number
  ,p_object_version_number                in     number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from
--   the server to be available to the api.
--
-- Prerequisites:
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
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (p_group_per_in_ler_id                  in     number
  ,p_object_version_number                in     number
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
-- Prerequisites:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function.  Any possible
--   errors within this function will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
  (p_group_per_in_ler_id            in number
  ,p_assignment_id                  in number
  ,p_person_id                      in number
  ,p_supervisor_id                  in number
  ,p_effective_date                 in date
  ,p_full_name                      in varchar2
  ,p_brief_name                     in varchar2
  ,p_custom_name                    in varchar2
  ,p_supervisor_full_name           in varchar2
  ,p_supervisor_brief_name          in varchar2
  ,p_supervisor_custom_name         in varchar2
  ,p_legislation_code               in varchar2
  ,p_years_employed                 in number
  ,p_years_in_job                   in number
  ,p_years_in_position              in number
  ,p_years_in_grade                 in number
  ,p_employee_number                in varchar2
  ,p_start_date                     in date
  ,p_original_start_date            in date
  ,p_adjusted_svc_date              in date
  ,p_base_salary                    in number
  ,p_base_salary_change_date        in date
  ,p_payroll_name                   in varchar2
  ,p_performance_rating             in varchar2
  ,p_performance_rating_type        in varchar2
  ,p_performance_rating_date        in date
  ,p_business_group_id              in number
  ,p_organization_id                in number
  ,p_job_id                         in number
  ,p_grade_id                       in number
  ,p_position_id                    in number
  ,p_people_group_id                in number
  ,p_soft_coding_keyflex_id         in number
  ,p_location_id                    in number
  ,p_pay_rate_id                    in number
  ,p_assignment_status_type_id      in number
  ,p_frequency                      in varchar2
  ,p_grade_annulization_factor      in number
  ,p_pay_annulization_factor        in number
  ,p_grd_min_val                    in number
  ,p_grd_max_val                    in number
  ,p_grd_mid_point                  in number
  ,p_grd_quartile                   in varchar2
  ,p_grd_comparatio                 in number
  ,p_emp_category                   in varchar2
  ,p_change_reason                  in varchar2
  ,p_normal_hours                   in number
  ,p_email_address                  in varchar2
  ,p_base_salary_frequency          in varchar2
  ,p_new_assgn_ovn                  in number
  ,p_new_perf_event_id              in number
  ,p_new_perf_review_id             in number
  ,p_post_process_stat_cd           in varchar2
  ,p_feedback_rating                in varchar2
  ,p_feedback_comments              in varchar2
  ,p_object_version_number          in number
  ,p_custom_segment1                in varchar2
  ,p_custom_segment2                in varchar2
  ,p_custom_segment3                in varchar2
  ,p_custom_segment4                in varchar2
  ,p_custom_segment5                in varchar2
  ,p_custom_segment6                in varchar2
  ,p_custom_segment7                in varchar2
  ,p_custom_segment8                in varchar2
  ,p_custom_segment9                in varchar2
  ,p_custom_segment10               in varchar2
  ,p_custom_segment11               in number
  ,p_custom_segment12               in number
  ,p_custom_segment13               in number
  ,p_custom_segment14               in number
  ,p_custom_segment15               in number
  ,p_custom_segment16               in number
  ,p_custom_segment17               in number
  ,p_custom_segment18               in number
  ,p_custom_segment19               in number
  ,p_custom_segment20               in number
  ,p_people_group_name              in varchar2
  ,p_people_group_segment1          in varchar2
  ,p_people_group_segment2          in varchar2
  ,p_people_group_segment3          in varchar2
  ,p_people_group_segment4          in varchar2
  ,p_people_group_segment5          in varchar2
  ,p_people_group_segment6          in varchar2
  ,p_people_group_segment7          in varchar2
  ,p_people_group_segment8          in varchar2
  ,p_people_group_segment9          in varchar2
  ,p_people_group_segment10         in varchar2
  ,p_people_group_segment11         in varchar2
  ,p_ass_attribute_category         in varchar2
  ,p_ass_attribute1                 in varchar2
  ,p_ass_attribute2                 in varchar2
  ,p_ass_attribute3                 in varchar2
  ,p_ass_attribute4                 in varchar2
  ,p_ass_attribute5                 in varchar2
  ,p_ass_attribute6                 in varchar2
  ,p_ass_attribute7                 in varchar2
  ,p_ass_attribute8                 in varchar2
  ,p_ass_attribute9                 in varchar2
  ,p_ass_attribute10                in varchar2
  ,p_ass_attribute11                in varchar2
  ,p_ass_attribute12                in varchar2
  ,p_ass_attribute13                in varchar2
  ,p_ass_attribute14                in varchar2
  ,p_ass_attribute15                in varchar2
  ,p_ass_attribute16                in varchar2
  ,p_ass_attribute17                in varchar2
  ,p_ass_attribute18                in varchar2
  ,p_ass_attribute19                in varchar2
  ,p_ass_attribute20                in varchar2
  ,p_ass_attribute21                in varchar2
  ,p_ass_attribute22                in varchar2
  ,p_ass_attribute23                in varchar2
  ,p_ass_attribute24                in varchar2
  ,p_ass_attribute25                in varchar2
  ,p_ass_attribute26                in varchar2
  ,p_ass_attribute27                in varchar2
  ,p_ass_attribute28                in varchar2
  ,p_ass_attribute29                in varchar2
  ,p_ass_attribute30                in varchar2
  ,p_ws_comments                    in varchar2
  ,p_cpi_attribute_category         in varchar2
  ,p_cpi_attribute1                 in varchar2
  ,p_cpi_attribute2                 in varchar2
  ,p_cpi_attribute3                 in varchar2
  ,p_cpi_attribute4                 in varchar2
  ,p_cpi_attribute5                 in varchar2
  ,p_cpi_attribute6                 in varchar2
  ,p_cpi_attribute7                 in varchar2
  ,p_cpi_attribute8                 in varchar2
  ,p_cpi_attribute9                 in varchar2
  ,p_cpi_attribute10                in varchar2
  ,p_cpi_attribute11                in varchar2
  ,p_cpi_attribute12                in varchar2
  ,p_cpi_attribute13                in varchar2
  ,p_cpi_attribute14                in varchar2
  ,p_cpi_attribute15                in varchar2
  ,p_cpi_attribute16                in varchar2
  ,p_cpi_attribute17                in varchar2
  ,p_cpi_attribute18                in varchar2
  ,p_cpi_attribute19                in varchar2
  ,p_cpi_attribute20                in varchar2
  ,p_cpi_attribute21                in varchar2
  ,p_cpi_attribute22                in varchar2
  ,p_cpi_attribute23                in varchar2
  ,p_cpi_attribute24                in varchar2
  ,p_cpi_attribute25                in varchar2
  ,p_cpi_attribute26                in varchar2
  ,p_cpi_attribute27                in varchar2
  ,p_cpi_attribute28                in varchar2
  ,p_cpi_attribute29                in varchar2
  ,p_cpi_attribute30                in varchar2
  ,p_feedback_date                  in date
  )
  Return g_rec_type;
--
end ben_cpi_shd;

 

/
