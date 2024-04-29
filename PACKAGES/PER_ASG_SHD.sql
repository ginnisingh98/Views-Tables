--------------------------------------------------------
--  DDL for Package PER_ASG_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_SHD" AUTHID CURRENT_USER as
/* $Header: peasgrhi.pkh 120.4.12010000.2 2009/11/20 06:56:26 sidsaxen ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  assignment_id                     per_all_assignments_f.assignment_id%TYPE,
  effective_start_date              date,
  effective_end_date                date,
  business_group_id                 number(15),
  recruiter_id                      per_all_assignments_f.recruiter_id%TYPE,
  grade_id                          number(15),
  position_id                       number(15),
  job_id                            number(15),
  assignment_status_type_id         number(9),
  payroll_id                        number(9),
  location_id                       number(15),
  person_referred_by_id             per_all_assignments_f.person_referred_by_id%TYPE,
  supervisor_id                     per_all_assignments_f.supervisor_id%TYPE,
  special_ceiling_step_id           number(15),
  person_id                         per_all_assignments_f.person_id%TYPE,
  recruitment_activity_id           number(15),
  source_organization_id            number(15),
  organization_id                   number(15),
  people_group_id                   number(15),
  soft_coding_keyflex_id            number(15),
  vacancy_id                        number(15),
  pay_basis_id                      number(9),
  assignment_sequence               number(15),
  assignment_type                   varchar2(9),      -- Increased length
  primary_flag                      varchar2(30),
  application_id                    number(15),
  assignment_number                 varchar2(30),
  change_reason                     varchar2(30),
  comment_id                        number(15),
  comment_text                      varchar2(2000),   -- pseudo column
  date_probation_end                date,
  default_code_comb_id              number(15),
  employment_category               varchar2(30),
  frequency                         varchar2(30),
  internal_address_line             varchar2(80),
  manager_flag                      varchar2(30),
  normal_hours                      number(22,3),
  perf_review_period                number(15),
  perf_review_period_frequency      varchar2(30),
  period_of_service_id              number(15),
  probation_period                  number(22,2),
  probation_unit                    varchar2(30),
  sal_review_period                 number(15),
  sal_review_period_frequency       varchar2(30),
  set_of_books_id                   number(15),
  source_type                       varchar2(30),
  time_normal_finish                varchar2(9),      -- Increased length
  time_normal_start                 varchar2(9),      -- Increased length
  bargaining_unit_code              varchar2(30),
  labour_union_member_flag          varchar2(30),
  hourly_salaried_code              varchar2(30),
  request_id                        number(15),
  program_application_id            number(15),
  program_id                        number(15),
  program_update_date               date,
  ass_attribute_category            varchar2(30),
  ass_attribute1                    varchar2(150),
  ass_attribute2                    varchar2(150),
  ass_attribute3                    varchar2(150),
  ass_attribute4                    varchar2(150),
  ass_attribute5                    varchar2(150),
  ass_attribute6                    varchar2(150),
  ass_attribute7                    varchar2(150),
  ass_attribute8                    varchar2(150),
  ass_attribute9                    varchar2(150),
  ass_attribute10                   varchar2(150),
  ass_attribute11                   varchar2(150),
  ass_attribute12                   varchar2(150),
  ass_attribute13                   varchar2(150),
  ass_attribute14                   varchar2(150),
  ass_attribute15                   varchar2(150),
  ass_attribute16                   varchar2(150),
  ass_attribute17                   varchar2(150),
  ass_attribute18                   varchar2(150),
  ass_attribute19                   varchar2(150),
  ass_attribute20                   varchar2(150),
  ass_attribute21                   varchar2(150),
  ass_attribute22                   varchar2(150),
  ass_attribute23                   varchar2(150),
  ass_attribute24                   varchar2(150),
  ass_attribute25                   varchar2(150),
  ass_attribute26                   varchar2(150),
  ass_attribute27                   varchar2(150),
  ass_attribute28                   varchar2(150),
  ass_attribute29                   varchar2(150),
  ass_attribute30                   varchar2(150),
  title                             varchar2(30),
  object_version_number             number(9),
  contract_id                       number(15),
  establishment_id                  number(15),
  collective_agreement_id           number(15),
  cagr_grade_def_id                 number(15),
  cagr_id_flex_num                  number(15),
  notice_period                     number(15),
  notice_period_uom                 varchar2(30),
  employee_category                 varchar2(30),
  work_at_home                      varchar2(30),
  job_post_source_name              varchar2(240),
  posting_content_id                number(15),
  period_of_placement_date_start    date,
  vendor_id                         number(15),
  vendor_employee_number            varchar2(30),
  vendor_assignment_number          varchar2(30),
  assignment_category               varchar2(30),
  project_title                     varchar2(30),
  applicant_rank                    number(15),
  grade_ladder_pgm_id               number(15),
  supervisor_assignment_id          number(15),
  vendor_site_id                    number(15),
  po_header_id                      number(15),
  po_line_id                        number(15),
  projected_assignment_end          date
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_tab_nam  constant varchar2(30) := 'PER_ALL_ASSIGNMENTS_F';
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
-- Pre Conditions:
--   None.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
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
-- Pre Conditions:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which correspond with a constraint error.
--
-- In Arguments:
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
--   This function is used to populate the g_old_rec record with the current
--   row from the database for the specified primary key provided that the
--   primary key exists and is valid and does not already match the current
--   g_old_rec.
--   The function will always return a TRUE value if the g_old_rec is
--   populated with the current row. A FALSE value will be returned if all of
--   the primary key arguments are null.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec is
--   current.
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
  (p_effective_date             in date,
   p_assignment_id              in number,
   p_object_version_number      in number
  ) Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack delete modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the delete modes
--   available where TRUE indicates that the corresponding delete mode is
--   available.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :assignment_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack delete mode of
--   ZAP. To implement this you would have to set and return a Boolean value
--   of FALSE after the call to the dt_api.find_dt_del_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
        (p_effective_date       in  date,
         p_base_key_value       in  number,
         p_zap           out nocopy boolean,
         p_delete        out nocopy boolean,
         p_future_change out nocopy boolean,
         p_delete_next_change out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack update modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the update modes
--   available where TRUE indicates that the corresponding update mode
--   is available.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :assignment_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack update mode of
--   UPDATE. To implement this you would have to set and return a Boolean
--   value of FALSE after the call to the dt_api.find_dt_upd_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
        (p_effective_date       in  date,
         p_base_key_value       in  number,
         p_correction    out nocopy boolean,
         p_update        out nocopy boolean,
         p_update_override out nocopy boolean,
         p_update_change_insert out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will update the specified datetrack row with the
--   specified new effective end date. The object version number is also
--   set to the next object version number. DateTrack modes which call
--   this procedure are: UPDATE, UPDATE_CHANGE_INSERT,
--   UPDATE_OVERRIDE, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE.
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_new_effective_end_date
--     Specifies the new effective end date which will be set for the
--     row as of the effective date.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :assignment_id).
--
-- Post Success:
--   The specified row will be updated with the new effective end date and
--   object_version_number.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
        (p_effective_date               in date,
         p_base_key_value               in number,
         p_new_effective_end_date       in date,
         p_validation_start_date        in date,
         p_validation_end_date          in date,
         p_object_version_number       out nocopy number);
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< lck >----------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   The Lck process for datetrack is complicated and comprises of the
--   following processing
--   The processing steps are as follows:
--   1) The row to be updated or deleted must be locked.
--      By locking this row, the g_old_rec record data type is populated.
--   2) If a comment exists the text is selected from hr_comments.
--   3) The datetrack mode is then validated to ensure the operation is
--      valid. If the mode is valid the validation start and end dates for
--      the mode will be derived and returned. Any required locking is
--      completed when the datetrack mode is validated.
--
-- Pre Conditions:
--   When attempting to call the lck procedure the object version number,
--   primary key, effective date and datetrack mode must be specified.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update or delete mode.
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
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure lck
        (p_effective_date        in  date,
         p_datetrack_mode        in  varchar2,
         p_assignment_id         in  number,
         p_object_version_number in  number,
         p_validation_start_date out nocopy date,
         p_validation_end_date   out nocopy date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
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
        p_assignment_id                 in number,
        p_effective_start_date          in date,
        p_effective_end_date            in date,
        p_business_group_id             in number,
        p_recruiter_id                  in number,
        p_grade_id                      in number,
        p_position_id                   in number,
        p_job_id                        in number,
        p_assignment_status_type_id     in number,
        p_payroll_id                    in number,
        p_location_id                   in number,
        p_person_referred_by_id         in number,
        p_supervisor_id                 in number,
        p_special_ceiling_step_id       in number,
        p_person_id                     in number,
        p_recruitment_activity_id       in number,
        p_source_organization_id        in number,
        p_organization_id               in number,
        p_people_group_id               in number,
        p_soft_coding_keyflex_id        in number,
        p_vacancy_id                    in number,
        p_pay_basis_id                  in number,
        p_assignment_sequence           in number,
        p_assignment_type               in varchar2,
        p_primary_flag                  in varchar2,
        p_application_id                in number,
        p_assignment_number             in varchar2,
        p_change_reason                 in varchar2,
        p_comment_id                    in number,
        --
        -- 70.2 change b start.
        --
        p_comments                      in varchar2,
        --
        -- 70.2 change b end.
        --
        p_date_probation_end            in date,
        p_default_code_comb_id          in number,
        p_employment_category           in varchar2,
        p_frequency                     in varchar2,
        p_internal_address_line         in varchar2,
        p_manager_flag                  in varchar2,
        p_normal_hours                  in number,
        p_perf_review_period            in number,
        p_perf_review_period_frequency  in varchar2,
        p_period_of_service_id          in number,
        p_probation_period              in number,
        p_probation_unit                in varchar2,
        p_sal_review_period             in number,
        p_sal_review_period_frequency   in varchar2,
        p_set_of_books_id               in number,
        p_source_type                   in varchar2,
        p_time_normal_finish            in varchar2,
        p_time_normal_start             in varchar2,
        p_bargaining_unit_code          in varchar2,
        p_labour_union_member_flag      in varchar2,
        p_hourly_salaried_code          in varchar2,
        p_request_id                    in number,
        p_program_application_id        in number,
        p_program_id                    in number,
        p_program_update_date           in date,
        p_ass_attribute_category        in varchar2,
        p_ass_attribute1                in varchar2,
        p_ass_attribute2                in varchar2,
        p_ass_attribute3                in varchar2,
        p_ass_attribute4                in varchar2,
        p_ass_attribute5                in varchar2,
        p_ass_attribute6                in varchar2,
        p_ass_attribute7                in varchar2,
        p_ass_attribute8                in varchar2,
        p_ass_attribute9                in varchar2,
        p_ass_attribute10               in varchar2,
        p_ass_attribute11               in varchar2,
        p_ass_attribute12               in varchar2,
        p_ass_attribute13               in varchar2,
        p_ass_attribute14               in varchar2,
        p_ass_attribute15               in varchar2,
        p_ass_attribute16               in varchar2,
        p_ass_attribute17               in varchar2,
        p_ass_attribute18               in varchar2,
        p_ass_attribute19               in varchar2,
        p_ass_attribute20               in varchar2,
        p_ass_attribute21               in varchar2,
        p_ass_attribute22               in varchar2,
        p_ass_attribute23               in varchar2,
        p_ass_attribute24               in varchar2,
        p_ass_attribute25               in varchar2,
        p_ass_attribute26               in varchar2,
        p_ass_attribute27               in varchar2,
        p_ass_attribute28               in varchar2,
        p_ass_attribute29               in varchar2,
        p_ass_attribute30               in varchar2,
        p_title                         in varchar2,
        p_object_version_number         in number,
        p_contract_id                   in number,
        p_establishment_id              in number,
        p_collective_agreement_id       in number,
        p_cagr_grade_def_id             in number,
        p_cagr_id_flex_num              in number,
        p_notice_period                 in number,
        p_notice_period_uom             in varchar2,
        p_employee_category             in varchar2,
        p_work_at_home                  in varchar2,
        p_job_post_source_name          in varchar2,
        p_posting_content_id            in number,
        p_placement_date_start          in date,
        p_vendor_id                     in number,
        p_vendor_employee_number        in varchar2,
        p_vendor_assignment_number      in varchar2,
        p_assignment_category           in varchar2,
        p_project_title                 in varchar2,
        p_applicant_rank                in number,
        p_grade_ladder_pgm_id           in number,
        p_supervisor_assignment_id      in number,
        p_vendor_site_id                in number,
        p_po_header_id                  in number,
        p_po_line_id                    in number,
        p_projected_assignment_end      in date)
        Return g_rec_type;
--
end per_asg_shd;

/
