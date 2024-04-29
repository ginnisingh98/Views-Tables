--------------------------------------------------------
--  DDL for Package PSP_ERD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ERD_SHD" AUTHID CURRENT_USER as
/* $Header: PSPEDRHS.pls 120.3 2006/01/25 01:49 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (effort_report_detail_id         number(15)
  ,effort_report_id                number(15)
  ,object_version_number           number(9)
  ,assignment_id                   number(15)
  ,assignment_number               varchar2(30)
  ,gl_sum_criteria_segment_name    varchar2(2000)
  ,gl_segment1                     varchar2(25)
  ,gl_segment2                     varchar2(25)
  ,gl_segment3                     varchar2(25)
  ,gl_segment4                     varchar2(25)
  ,gl_segment5                     varchar2(25)
  ,gl_segment6                     varchar2(25)
  ,gl_segment7                     varchar2(25)
  ,gl_segment8                     varchar2(25)
  ,gl_segment9                     varchar2(25)
  ,gl_segment10                    varchar2(25)
  ,gl_segment11                    varchar2(25)
  ,gl_segment12                    varchar2(25)
  ,gl_segment13                    varchar2(25)
  ,gl_segment14                    varchar2(25)
  ,gl_segment15                    varchar2(25)
  ,gl_segment16                    varchar2(25)
  ,gl_segment17                    varchar2(25)
  ,gl_segment18                    varchar2(25)
  ,gl_segment19                    varchar2(25)
  ,gl_segment20                    varchar2(25)
  ,gl_segment21                    varchar2(25)
  ,gl_segment22                    varchar2(25)
  ,gl_segment23                    varchar2(25)
  ,gl_segment24                    varchar2(25)
  ,gl_segment25                    varchar2(25)
  ,gl_segment26                    varchar2(25)
  ,gl_segment27                    varchar2(25)
  ,gl_segment28                    varchar2(25)
  ,gl_segment29                    varchar2(25)
  ,gl_segment30                    varchar2(25)
  ,project_id                      number(15)
  ,project_number                  varchar2(25)
  ,project_name                    varchar2(30)
  ,expenditure_organization_id     number(15)
  ,exp_org_name                    varchar2(240)
  ,expenditure_type                varchar2(30)
  ,task_id                         number(15)
  ,task_number                     varchar2(25)
  ,task_name                       varchar2(30)
  ,award_id                        number(15)
  ,award_number                    varchar2(240)
  ,award_short_name                varchar2(30)
  ,actual_salary_amt               number
  ,payroll_percent                 number
  ,proposed_salary_amt             number
  ,proposed_effort_percent         number
  ,committed_cost_share            number
  ,schedule_start_date             date
  ,schedule_end_date               date
  ,ame_transaction_id              varchar2(50)
  ,investigator_name               varchar2(240)
  ,investigator_person_id          number(15)
  ,investigator_org_name           varchar2(240)
  ,investigator_primary_org_id     number(15)
  ,value1                          number
  ,value2                          number
  ,value3                          number
  ,value4                          number
  ,value5                          number
  ,value6                          number
  ,value7                          number
  ,value8                          number
  ,value9                          number
  ,value10                         number
  ,attribute1                      varchar2(1000)
  ,attribute2                      varchar2(1000)
  ,attribute3                      varchar2(1000)
  ,attribute4                      varchar2(1000)
  ,attribute5                      varchar2(1000)
  ,attribute6                      varchar2(1000)
  ,attribute7                      varchar2(1000)
  ,attribute8                      varchar2(1000)
  ,attribute9                      varchar2(1000)
  ,attribute10                     varchar2(1000)
  ,grouping_category               varchar2(30)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'PSP_EFF_REPORT_DETAILS';
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
  (p_effort_report_detail_id              in     number
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
  (p_effort_report_detail_id              in     number
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
  (p_effort_report_detail_id        in number
  ,p_effort_report_id               in number
  ,p_object_version_number          in number
  ,p_assignment_id                  in number
  ,p_assignment_number              in varchar2
  ,p_gl_sum_criteria_segment_name   in varchar2
  ,p_gl_segment1                    in varchar2
  ,p_gl_segment2                    in varchar2
  ,p_gl_segment3                    in varchar2
  ,p_gl_segment4                    in varchar2
  ,p_gl_segment5                    in varchar2
  ,p_gl_segment6                    in varchar2
  ,p_gl_segment7                    in varchar2
  ,p_gl_segment8                    in varchar2
  ,p_gl_segment9                    in varchar2
  ,p_gl_segment10                   in varchar2
  ,p_gl_segment11                   in varchar2
  ,p_gl_segment12                   in varchar2
  ,p_gl_segment13                   in varchar2
  ,p_gl_segment14                   in varchar2
  ,p_gl_segment15                   in varchar2
  ,p_gl_segment16                   in varchar2
  ,p_gl_segment17                   in varchar2
  ,p_gl_segment18                   in varchar2
  ,p_gl_segment19                   in varchar2
  ,p_gl_segment20                   in varchar2
  ,p_gl_segment21                   in varchar2
  ,p_gl_segment22                   in varchar2
  ,p_gl_segment23                   in varchar2
  ,p_gl_segment24                   in varchar2
  ,p_gl_segment25                   in varchar2
  ,p_gl_segment26                   in varchar2
  ,p_gl_segment27                   in varchar2
  ,p_gl_segment28                   in varchar2
  ,p_gl_segment29                   in varchar2
  ,p_gl_segment30                   in varchar2
  ,p_project_id                     in number
  ,p_project_number                 in varchar2
  ,p_project_name                   in varchar2
  ,p_expenditure_organization_id    in number
  ,p_exp_org_name                   in varchar2
  ,p_expenditure_type               in varchar2
  ,p_task_id                        in number
  ,p_task_number                    in varchar2
  ,p_task_name                      in varchar2
  ,p_award_id                       in number
  ,p_award_number                   in varchar2
  ,p_award_short_name               in varchar2
  ,p_actual_salary_amt              in number
  ,p_payroll_percent                in number
  ,p_proposed_salary_amt            in number
  ,p_proposed_effort_percent        in number
  ,p_committed_cost_share           in number
  ,p_schedule_start_date            in date
  ,p_schedule_end_date              in date
  ,p_ame_transaction_id             in varchar2
  ,p_investigator_name              in varchar2
  ,p_investigator_person_id         in number
  ,p_investigator_org_name          in varchar2
  ,p_investigator_primary_org_id    in number
  ,p_value1                         in number
  ,p_value2                         in number
  ,p_value3                         in number
  ,p_value4                         in number
  ,p_value5                         in number
  ,p_value6                         in number
  ,p_value7                         in number
  ,p_value8                         in number
  ,p_value9                         in number
  ,p_value10                        in number
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_grouping_category              in varchar2
  )
  Return g_rec_type;
--
end psp_erd_shd;

 

/
