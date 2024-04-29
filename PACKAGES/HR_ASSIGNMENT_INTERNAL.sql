--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_INTERNAL" AUTHID CURRENT_USER as
/* $Header: peasgbsi.pkh 120.3.12010000.1 2008/07/28 04:09:27 appldev ship $ */
--
-- 70.2 change a start.
--
-- Start of 3335915
   g_called_from_spp_asg boolean := false;
-- End of 3335915
-- ----------------------------------------------------------------------------
-- |------------------< actual_term_emp_asg_sup (overloaded) >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
-- {End Of Comments}
--
procedure actual_term_emp_asg_sup
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in     date
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  );
-- ----------------------------------------------------------------------------
-- |------------------------< actual_term_emp_asg_sup >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure processes one employee assignment when the actual
--   termination date is entered. This logic is common to the
--   'actual_termination_emp_asg' and 'actual_termination_emp' business
--   processes.
--
--   The 'actual_termination_emp_asg' business process only allows the user to
--   terminate one non-primary assignment at a time. Where as the
--   'actual_termination_emp' business process needs to terminate all
--   non-primary assignments and the primary assignment.
--
--   This business support process assumes the p_actual_termination_date,
--   p_last_standard_process_date and p_assignment_status_type_id parameters
--   have been correctly validated or derived by the calling logic. For US
--   legislation p_last_standard_process_date should always be set to null.
--   This will ensure unnecessary logic is not executed.
--
--   This business support process updates the assignment, date effectively
--   deletes element entries where the corresponding element termination rule
--   is actual_termination or last_standard_process, deletes affected
--   unprocessed run results, deletes affected pay proposals and deletes
--   affected assignment link usages.
--
-- Prerequisites:
--   A valid assignment (p_assignment_id) must exist as of the actual
--   termination date (p_actual_termination_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_actual_termination_date       Yes date
--   p_last_standard_process_date    Yes date
--   p_assignment_status_type_id     Yes number
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        number   The version number of this
--                                           assignment, as of the actual
--                                           termination date + 1.
--   p_effective_start_date         date     Effective start date of the
--                                           assignment row, which exists as of
--                                           the actual termination date.
--   p_effective_end_date           date     Effective end date of the
--                                           assignment row, which exists as of
--                                           the actual termination date.
--   p_asg_future_changes_warning   boolean  Set to true if at least one
--                                           assignment change, after the
--                                           actual termination date, has been
--                                           overwritten with the new
--                                           assignment status type. Set to
--                                           false when there are no changes in
--                                           the future.
--   p_entries_changed_warning      varchar2 Set to 'Y' when at least one
--                                           element entry was altered due to
--                                           the assignment change.
--                                           Set to 'S' if at least one salary
--                                           element entry was affected.
--                                           ('S' is a more specific case of
--                                           'Y' because non-salary entries may
--                                           or may not have been affected at
--                                           the same time). Otherwise set to
--                                           'N', when no element entries were
--                                           changed.
--   p_pay_proposal_warning         boolean  Set to true if any pay proposals
--                                           existing after the
--					     actual_termination_date,has been
--                                           deleted. Set to false when there
--                                           are no pay proposals after actual_
--                                           termination_date.
--   p_alu_change_warning           varchar2 Set to 'Y' when the termination
--                                           date will result in elements not
--                                           getting picked in the costing run
-- Post Failure:
--   The process will not process the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure actual_term_emp_asg_sup
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in     date
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ,p_alu_change_warning              out nocopy varchar2
  );
-- 70.2 change a end.
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_first_spp >---------------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- This is used in the case that you need to remove next change on the assignemnt
-- form and the next record has a grade step placement assigned which is the
-- the first date tracked fecord for this assignment on the table
-- per_spinal_point_placements_f.
-- The process removes next changes until the effective end date of the record
-- on per_spinal_point_placements_f matches the validation end date and then
-- this single record is then deleted using DML.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_effective_date		    Yes  Date     Effective date that assigment
--						  record was updated.
--   p_assignment_id		    Yes  Number   Assignment id number
--   p_validation_start_date	    Yes  Date	  Start date of assignment record
--						  that is being removed.
--   p_validation_end_date	    Yes  Date	  End date of assignment record
--                                                that is being removed.
--
-- Out Parameters
--   Name                           Reqd Type     Description
--   p_future_spp_warning	    Yes  boolean  Set to yes if there are changes
--						  to the step for the period
--						  based on the validations dates
--						  other than the one starting
--						  on the validation_start_date.
--
-- Post Success
--  First record from spp deleted
--
-- Post Failure:
--  Nothing is modified.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_first_spp
  (p_effective_date             in     date
  ,p_assignment_id              in     number
  ,p_validation_start_date      in     date
  ,p_validation_end_date        in     date
  ,p_future_spp_warning            out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_default_emp_asg >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This business support process creates a default employee assignment,
--  including the relevant standard element entries and assignment budget
--  values. This process only contains the common functionality for business
--  processes which need to create an initial primary assignment for an
--  employee, eg. 'create_employee'.
--
-- Prerequisites:
--   A valid person (p_person_id) must exist as of the effective insert date
--   (p_effective_date).
--   A valid period of service (p_period_of_service_id) must exist for this
--   person (p_person_id).
--   A valid business group (p_business_group_id)i must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date                Yes date     The date from which this
--                                                assignment applies.
--   p_person_id                     Yes number
--   p_business_group_id             Yes number
--   p_period_of_service_id          Yes number
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_assignment_id                number   Uniquely identifies the assignment
--                                           created.
--   p_object_version_number        number   The version number of this
--                                           assignment.
--   p_assignment_sequence          number   Assignment sequence
--   p_assignment_number            varchar2 Assignment number
--
--
-- Post Failure:
--   The process will not create the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_default_emp_asg
  (p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_business_group_id            in     number
  ,p_period_of_service_id         in     number
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_default_cwk_asg >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This business support process creates a default non payrolled worker
--  assignment,including the relevant standard element entries and assignment
--  budget values. This process only contains the common functionality for
--  business processes which need to create an initial primary assignment for
--  an employee, eg. 'create_employee'.
--
-- Prerequisites:
--   A valid person (p_person_id) must exist as of the effective insert date
--   (p_effective_date).
--   A valid period of placement (p_period_of_placement_id) must exist for this
--   person (p_person_id).
--   A valid business group (p_business_group_id)i must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date                Yes date     The date from which this
--                                                assignment applies.
--   p_person_id                     Yes number
--   p_business_group_id             Yes number
--   p_placement_date_start          Yes date
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_assignment_id                number   Uniquely identifies the assignment
--                                           created.
--   p_object_version_number        number   The version number of this
--                                           assignment.
--   p_assignment_sequence          number   Assignment sequence
--   p_assignment_number            varchar2 Assignment number
--
--
-- Post Failure:
--   The process will not create the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_default_cwk_asg
  (p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_business_group_id              in     number
  ,p_placement_date_start           in     date
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cwk_asg >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This is a common intermal routine used by create_default_cwk_asg
--  and create_secondary_cwk_asg to handle the insert of the assignment row.
--
-- Prerequisites:
--   A valid person (p_person_id) must exist as of the effective insert date
--   (p_effective_date).
--   A valid period of placement (p_placement_date_start) must exist for this
--   person (p_person_id).
--   A valid business group (p_business_group_id)i must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date                 Yes date     The date from which this
--                                                 assignment applies.
--   p_person_id                      Yes number   Person
--   p_business_group_id              Yes number   Business Group
--   p_legislation_code               Yes varchar2 used to validate asg. status
--   p_placement_date_start           Yes date     Date of Period of placement for this asg.
--   p_organization_id                   number   Organization
--   p_primary_flag                      varchar2 marks primary assignment
--   p_assignment_number                 varchar2
--   p_assignment_category               varchar2
--   p_assignment_status_type_id         number
--   p_change_reason                     varchar2 reason for change of status
--   p_comments                          varchar2
--   p_default_code_comb_id              number
--   p_employment_category               varchar2
--   p_establishment_id                  number
--   p_frequency                         varchar2
--   p_internal_address_flag             varchar2
--   p_job_id                            number
--   p_labour_union_member_flag          varchar2
--   p_location_id                       number
--   p_manager_flag                      varchar2
--   p_normal_hours                      number
--   p_position_id                       number
--   p_grade_id                          number   This parameter is obsoleted.
--                                                Grade should not be maintained for CWK asg.
--   p_project_title                     varchar2
--   p_title                             varchar2
--   p_set_of_books_id                   number
--   p_source_type                       varchar2
--   p_supervisor_id                     number
--   p_time_normal_finish                varchar2
--   p_time_normal_start                 varchar2
--   p_vendor_assignment_number          varchar2
--   p_vendor_employee_number            varcahr2
--   p_vendor_id                         number  Supplier of assignment
--   p_vendor_site_id                    number  Supplier site of assignment
--   p_po_header_id                      number  Purchase Order ref for assignment
--   p_po_line_id                        number  Purchase Order line for assignment
--   p_projected_assignment_end          date    Projected end date of assignment
--   p_people_group_id                   number
--   p_soft_coding_keyflex_id            number
--   p_ass_attribute_category            varchar2
--   p_ass_attribute1                    varchar2 Descriptive flexfield.
--   p_ass_attribute2                    varchar2 Descriptive flexfield.
--   p_ass_attribute3                    varchar2 Descriptive flexfield.
--   p_ass_attribute4                    varchar2 Descriptive flexfield.
--   p_ass_attribute5                    varchar2 Descriptive flexfield.
--   p_ass_attribute6                    varchar2 Descriptive flexfield.
--   p_ass_attribute7                    varchar2 Descriptive flexfield.
--   p_ass_attribute8                    varchar2 Descriptive flexfield.
--   p_ass_attribute9                    varchar2 Descriptive flexfield.
--   p_ass_attribute10                   varchar2 Descriptive flexfield.
--   p_ass_attribute11                   varchar2 Descriptive flexfield.
--   p_ass_attribute12                   varchar2 Descriptive flexfield.
--   p_ass_attribute13                   varchar2 Descriptive flexfield.
--   p_ass_attribute14                   varchar2 Descriptive flexfield.
--   p_ass_attribute15                   varchar2 Descriptive flexfield.
--   p_ass_attribute16                   varchar2 Descriptive flexfield.
--   p_ass_attribute17                   varchar2 Descriptive flexfield.
--   p_ass_attribute18                   varchar2 Descriptive flexfield.
--   p_ass_attribute19                   varchar2 Descriptive flexfield.
--   p_ass_attribute20                   varchar2 Descriptive flexfield.
--   p_ass_attribute21                   varchar2 Descriptive flexfield.
--   p_ass_attribute22                   varchar2 Descriptive flexfield.
--   p_ass_attribute23                   varchar2 Descriptive flexfield.
--   p_ass_attribute24                   varchar2 Descriptive flexfield.
--   p_ass_attribute25                   varchar2 Descriptive flexfield.
--   p_ass_attribute26                   varchar2 Descriptive flexfield.
--   p_ass_attribute27                   varchar2 Descriptive flexfield.
--   p_ass_attribute28                   varchar2 Descriptive flexfield.
--   p_ass_attribute29                   varchar2 Descriptive flexfield.
--   p_ass_attribute30                   varchar2 Descriptive flexfield.
--   p_validate_df_flex                  boolean  perform/bypass descriptive
--                                                flexfield validation
--   p_supervisor_assignment_id          number   default null
--
-- Post Success:
--
--   Name                           Type     Description
--   p_assignment_id                number   Uniquely identifies the assignment
--                                           created.
--   p_object_version_number        number   The version number of this
--                                           assignment.
--   p_effective_start_date         date     The date from which this
--                                           assignment row is applied.
--   p_effective_end_date           date     The last date on which this
--                                           assignment row applies.
--   p_assignment_sequence          number   Assignment sequence
--   p_assignment_number            varchar2 Assignment number
--   p_comment_id                   number   Comments for this assignment
--   p_other_manager_warning        boolean  Set to true if manager_flag is 'Y'
--                                           and a manager already exists in
--                                           the organization
--                                           (p_organization_id) as of
--                                           p_effective_date.
--
-- Post Failure:
--   The process will not create the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_cwk_asg
  (p_validate                        in     boolean    default false
  ,p_effective_date                  in     date
  ,p_business_group_id               in     number
  ,p_legislation_code                in     varchar2
  ,p_person_id                       in     number
  ,p_placement_date_start            in     date
  ,p_organization_id                 in     number
  ,p_primary_flag                    in     varchar2
  ,p_assignment_number               in out nocopy varchar2
  ,p_assignment_category             in     varchar2 default null
  ,p_assignment_status_type_id       in     number   default null
  ,p_change_reason                   in     varchar2 default null
  ,p_comments                        in     varchar2 default null
  ,p_default_code_comb_id            in     number   default null
  ,p_employment_category             in     varchar2 default null
  ,p_establishment_id                in     number   default null
  ,p_frequency                       in     varchar2 default null
  ,p_internal_address_line           in     varchar2 default null
  ,p_job_id                          in     number   default null
  ,p_labor_union_member_flag         in     varchar2 default null
  ,p_location_id                     in     number   default null
  ,p_manager_flag                    in     varchar2 default null
  ,p_normal_hours                    in     number   default null
  ,p_position_id                     in     number   default null
  ,p_grade_id                        in     number   default null
  ,p_project_title                   in     varchar2 default null
  ,p_title                           in     varchar2 default null
  ,p_set_of_books_id                 in     number   default null
  ,p_source_type                     in     varchar2 default null
  ,p_supervisor_id                   in     number   default null
  ,p_time_normal_start               in     varchar2 default null
  ,p_time_normal_finish              in     varchar2 default null
  ,p_vendor_assignment_number        in     varchar2 default null
  ,p_vendor_employee_number          in     varchar2 default null
  ,p_vendor_id                       in     number   default null
  ,p_vendor_site_id                  in     number   default null
  ,p_po_header_id                    in     number   default null
  ,p_po_line_id                      in     number   default null
  ,p_projected_assignment_end        in     date     default null
  ,p_people_group_id                 in     number   default null
  ,p_soft_coding_keyflex_id          in     number   default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_validate_df_flex             in     boolean  default true
  ,p_supervisor_assignment_id     in     number   default null
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_emp_asg >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This business support process creates a new employee assignment, including
--  the relevant standard element entries and assignment budget values. This
--  process can be called in one of two situations from other business support
--  processes:
--      create_default_emp_asg   - part of creating a new employee
--      create_secondary_emp_asg - create a non-primary employee assignment.
--  This process only contains the common functionality for the above two
--  processes.
--
-- Prerequisites:
--   A valid person (p_person_id) must exist as of the effective insert date
--   (p_effective_date).
--   A valid period of service (p_period_of_service_id) must exist for this
--   person (p_person_id).
--   A valid legislation (p_legislation_code) must exist for the assignment's
--   business group (p_business_group_id).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date                Yes date     The date from which this
--                                                assignment applies.
--   p_legislation_code              Yes varchar2
--   p_business_group_id             Yes number
--   p_person_id                     Yes number
--   p_organization_id               Yes number
--   p_primary_flag                  Yes varchar2
--   p_period_of_service_id          Yes number
--   p_grade_id                          number
--   p_position_id                       number
--   p_job_id                            number
--   p_assignment_status_type_id         number
--   p_payroll_id                        number
--   p_location_id                       number
--   p_supervisor_id                     number
--   p_special_ceiling_step_id           number
--   p_people_group_id                   number
--   p_soft_coding_keyflex_id            number
--   p_pay_basis_id                      number
--   p_assignment_number                 varchar2
--   p_change_reason                     varchar2
--   p_comments                          varchar2
--   p_date_probation_end                date
--   p_default_code_comb_id              number
--   p_employment_category               varchar2
--   p_frequency                         varchar2
--   p_internal_address_line             varchar2
--   p_manager_flag                      varchar2
--   p_normal_hours                      number
--   p_perf_review_period                number
--   p_perf_review_period_frequency      varchar2
--   p_probation_period                  number
--   p_probation_unit                    varchar2
--   p_sal_review_period                 number
--   p_sal_review_period_frequency       varchar2
--   p_set_of_books_id                   number
--   p_source_type                       varchar2
--   p_time_normal_finish                varchar2
--   p_time_normal_start                 varchar2
--   p_bargaining_unit_code              varchar2
--   p_labour_union_member_flag          varchar2
--   p_hourly_salaried_code              varchar2
--   p_ass_attribute_category            varchar2
--   p_ass_attribute1                    varchar2 Descriptive flexfield.
--   p_ass_attribute2                    varchar2 Descriptive flexfield.
--   p_ass_attribute3                    varchar2 Descriptive flexfield.
--   p_ass_attribute4                    varchar2 Descriptive flexfield.
--   p_ass_attribute5                    varchar2 Descriptive flexfield.
--   p_ass_attribute6                    varchar2 Descriptive flexfield.
--   p_ass_attribute7                    varchar2 Descriptive flexfield.
--   p_ass_attribute8                    varchar2 Descriptive flexfield.
--   p_ass_attribute9                    varchar2 Descriptive flexfield.
--   p_ass_attribute10                   varchar2 Descriptive flexfield.
--   p_ass_attribute11                   varchar2 Descriptive flexfield.
--   p_ass_attribute12                   varchar2 Descriptive flexfield.
--   p_ass_attribute13                   varchar2 Descriptive flexfield.
--   p_ass_attribute14                   varchar2 Descriptive flexfield.
--   p_ass_attribute15                   varchar2 Descriptive flexfield.
--   p_ass_attribute16                   varchar2 Descriptive flexfield.
--   p_ass_attribute17                   varchar2 Descriptive flexfield.
--   p_ass_attribute18                   varchar2 Descriptive flexfield.
--   p_ass_attribute19                   varchar2 Descriptive flexfield.
--   p_ass_attribute20                   varchar2 Descriptive flexfield.
--   p_ass_attribute21                   varchar2 Descriptive flexfield.
--   p_ass_attribute22                   varchar2 Descriptive flexfield.
--   p_ass_attribute23                   varchar2 Descriptive flexfield.
--   p_ass_attribute24                   varchar2 Descriptive flexfield.
--   p_ass_attribute25                   varchar2 Descriptive flexfield.
--   p_ass_attribute26                   varchar2 Descriptive flexfield.
--   p_ass_attribute27                   varchar2 Descriptive flexfield.
--   p_ass_attribute28                   varchar2 Descriptive flexfield.
--   p_ass_attribute29                   varchar2 Descriptive flexfield.
--   p_ass_attribute30                   varchar2 Descriptive flexfield.
--   p_title                             varchar2
--   p_contract_id                       number
--   p_establishment_id                  number
--   p_collective_agreement_id           number
--   p_cagr_id_flex_num                  number
--   p_cagr_grade_def_id                 number
--   p_notice_period                     in number   Notice Period
--   p_notice_period_uom                 in varchar2 Notice Period Units
--   p_employee_category                 in varchar2 Employee Category
--   p_work_at_home                      in varchar2 Work At Home
--   p_job_post_source_name		 in varchar2 Job Source
--   p_validate_df_flex                  boolean  perform/bypass descriptive
--                                                flexfield validation
--   p_grade_ladder_pgm_id               number
--   p_supervisor_assignment_id          number
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_assignment_id                number   Uniquely identifies the assignment
--                                           created.
--   p_object_version_number        number   The version number of this
--                                           assignment.
--   p_effective_start_date         date     The date from which this
--                                           assignment row is applied.
--   p_effective_end_date           date     The last date on which this
--                                           assignment row applies.
--   p_assignment_sequence          number
--   p_assignment_number            varchar2 Validated or generated
--                                           assignment number.
--   p_comment_id                   number
--   p_other_manager_warning        boolean  Set to true if manager_flag is 'Y'
--                                           and a manager already exists in
--                                           the organization
--                                           (p_organization_id) as of
--                                           p_effective_date.
--
--
-- Post Failure:
--   The process will not create the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_emp_asg
  (p_effective_date               in     date
  ,p_legislation_code             in     varchar2
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_primary_flag                 in     varchar2
  ,p_period_of_service_id         in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_people_group_id              in     number   default null
  ,p_soft_coding_keyflex_id       in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_contract_id                  in     number   default null
  ,p_establishment_id             in     number   default null
  ,p_collective_agreement_id      in     number   default null
  ,p_cagr_id_flex_num             in     number   default null
  ,p_cagr_grade_def_id            in     number   default null
-- added for collective agreeemnt module
  ,p_notice_period		  in	 number   default null
  ,p_notice_period_uom		  in     varchar2 default null
  ,p_employee_category		  in     varchar2 default null
  ,p_work_at_home		  in	 varchar2 default null
  ,p_job_post_source_name         in     varchar2 default null
  ,p_validate_df_flex             in     boolean  default true
  ,p_grade_ladder_pgm_id	  in	 number   default null
  ,p_supervisor_assignment_id	  in	 number   default null
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_emp_asg >-----------OVERLOADED------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This Procedure was overloaded to add new parameter to cre_emp_asg proc.
--  Hourly_salaried warning shows error for invalid pay_basis and
--     hourly_salaried code combinations

procedure create_emp_asg
  (p_effective_date               in     date
  ,p_legislation_code             in     varchar2
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_primary_flag                 in     varchar2
  ,p_period_of_service_id         in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_people_group_id              in     number   default null
  ,p_soft_coding_keyflex_id       in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_contract_id                  in     number   default null
  ,p_establishment_id             in     number   default null
  ,p_collective_agreement_id      in     number   default null
  ,p_cagr_id_flex_num             in     number   default null
  ,p_cagr_grade_def_id            in     number   default null
-- added for collective agreeemnt module
  ,p_notice_period		  in	 number   default null
  ,p_notice_period_uom		  in     varchar2 default null
  ,p_employee_category		  in     varchar2 default null
  ,p_work_at_home		  in	 varchar2 default null
  ,p_job_post_source_name         in     varchar2 default null
  ,p_validate_df_flex             in     boolean  default true
  ,p_grade_ladder_pgm_id	  in	 number   default null
  ,p_supervisor_assignment_id	  in	 number   default null
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< final_process_emp_asg_sup >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure processes one employee assignment when the final process
--   date is entered. This logic is common to the 'final_process_emp_asg' and
--   'final_process_emp' business processes.
--
--   The 'final_process_emp_asg' business process only allows the user to end
--   one non-primary assignment at a time. Whereas the 'final_process_emp'
--   business process needs to terminate all non-primary assignments and the
--   primary assignment.
--
--   The employee assignment must already have an assignment status which
--   corresponds to the TERM_ASSIGN system status. (This is set by calling the
--   'actual_termination_emp_asg' or 'actual_termination_emp' business
--   process.) No changes will be allowed if the assignment status is not
--   TERM_ASSIGN on the date after the final process date.
--
--   This business support process date effectively deletes the assignment,
--   date effectively deletes element entries where the corresponding element
--   termination rule is last_standard_process or final_process, deletes
--   affected unprocessed run results, deletes affected pay proposals and
--   deletes affected assignment link usages.
--
--   Element entries which have a corresponding 'Last Standard Process'
--   termination rule will have already been date effectively deleted by the
--   'actual_term_emp_asg_sup' business support process. It is still necessary
--   for this procedure to process these element entries because the final
--   process date may come before the defaulted last_standard_process date.
--
-- Prerequisites:
--   A valid assignment (p_assignment_id) must exist as of the final process
--   date (p_final_process_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_final_process_date            Yes date
--   p_actual_termination_date       Yes date
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        number   The version number of this
--                                           assignment.
--   p_effective_start_date         date
--   p_effective_end_date           date
--   p_org_now_no_manager_warning   boolean  Set to true if this assignment
--                                           was a manager and due to its
--                                           termination there will be no
--                                           managers in assignment's
--                                           organization. Set to false if
--                                           there is still another manager
--                                           in the assignment's organization
--                                           or this assignment was not a
--                                           manager. The warning value only
--                                           applies as of
--                                           p_final_process_date.
--   p_asg_future_changes_warning   boolean  Set to true if at least one
--                                           assignment change, after the
--                                           actual termination date, has been
--                                           overwritten with the new
--                                           assignment status type. Set to
--                                           false when there are no changes in
--                                           the future.
--   p_entries_changed_warning      varchar2 Set to 'Y' when at least one
--                                           element entry was altered due to
--                                           the assignment change.
--                                           Set to 'S' if at least one salary
--                                           element entry was affected.
--                                           ('S' is a more specific case of
--                                           'Y' because non-salary entries may
--                                           or may not have been affected at
--                                           the same time). Otherwise set to
--                                           'N', when no element entries were
--                                           changed.
--
--
-- Post Failure:
--   The process will not process the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--
procedure final_process_emp_asg_sup
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in     date
  ,p_actual_termination_date      in     date
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< maintain_spp_asg >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process maintains spinal point placements when an
--   employee assignment is altered. It should be called when the assignment
--   rows are deleted; this includes all the DateTrack delete modes.
--
--   For updates it should only be called when the assignment's grade_id is
--   actually updated, i.e. when grade_id is updated from not null to null or
--   a not null value. It should not be called when the grade_id is being
--   updated from a null to a not null value because there cannot be any
--   spinal point placements which will be affected.
--
-- Prerequisites:
--   A valid assignment (p_assignment_id) must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_datetrack_mode                Yes varchar2 The mode of update.
--   p_validation_start_date         Yes date
--   p_validation_end_date           Yes date
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_spp_delelete_warning         boolean  Only set to true if any spinal
--                                           point placement rows have been
--                                           affected.
--
-- Post Failure:
--   The process will not update the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure maintain_spp_asg
  (p_assignment_id                in     number
  ,p_datetrack_mode               in     varchar2
  ,p_validation_start_date        in     date
  ,p_validation_end_date          in     date
  ,p_grade_id			  in     number
  ,p_spp_delete_warning              out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_status_type_emp_asg >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process updates one employee assignment with a
--   suspend or active assignment status type.
--
--   This is a supporting process for the 'suspend_emp_asg' and
--   'activate_emp_asg' business processes. The logic required by both
--   processes is very similar. The only difference is that the internal
--   assignment status must be SUSP_ASSIGN for 'suspend_emp_asg' and
--   ACTIVE_ASSIGN' for 'activate_emp_asg'.
--
--   If the caller does not explicitly pass in a status type, the process will
--   use the default SUSP_ASSIGN or ACTIVE_ASSIGN status for the assignment's
--   business group.
--
--   If the assignment's status is already of the correct type this process can
--   be used to set a different suspend or active status. Updates from an
--   applicant assignment status (ACCEPTED, ACTIVE_APL, TERM_APL and OFFER) are
--   not allowed. Only employee assignments can be altered with this business
--   support process.
--
-- Prerequisites:
--   A valid assignment (p_assignment_id) must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date                Yes date     The operation date.
--   p_datetrack_update_mode         Yes varchar2 The mode of update.
--   p_assignment_id                 Yes number
--   p_object_version_number         Yes number
--   p_expected_system_status        Yes varchar2 The intended system status of
--                                                the assignment as a result of
--                                                the update. Either
--                                                ACTIVE_ASSIGN or SUSP_ASSIGN.
--   p_assignment_status_type_id      No number   The new assignment status.
--   p_change_reason                  No varchar2 New change reason
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        number   The version number of this
--                                           assignment.
--   p_effective_start_date         date     The date from which this change
--                                           applies.
--   p_effective_end_date           date     The last date on which this change
--                                           applies.
--
-- Post Failure:
--   The process will not update the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_status_type_emp_asg
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_expected_system_status       in     varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_status_type_cwk_asg >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process updates one cwk assignment with a
--   suspend or active assignment status type.
--
--   This is a supporting process for the 'suspend_cwk_asg' and
--   'activate_cwk_asg' business processes. The logic required by both
--   processes is very similar. The only difference is that the internal
--   assignment status must be SUSP_CWK_ASG for 'suspend_cwk_asg' and
--   ACTIVE_CWK' for 'activate_cwk_asg'.
--
--   If the caller does not explicitly pass in a status type, the process will
--   use the default SUSP_CWK_ASG or ACTIVE_CWK status for the assignment's
--   business group.
--
--   If the assignment's status is already of the correct type this process can
--   be used to set a different suspend or active status. Updates from an
--   applicant assignment status (ACCEPTED, ACTIVE_APL, TERM_APL and OFFER) are
--   not allowed nor are updates from emp statuses.  Only cwk assignments can be
--   altered with this business support process.
--
-- Prerequisites:
--   A valid assignment (p_assignment_id) must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date                Yes date     The operation date.
--   p_datetrack_update_mode         Yes varchar2 The mode of update.
--   p_assignment_id                 Yes number
--   p_object_version_number         Yes number
--   p_expected_system_status        Yes varchar2 The intended system status of
--                                                the assignment as a result of
--                                                the update. Either
--                                                ACTIVE_CWK or SUSP_CWK_ASG.
--   p_assignment_status_type_id      No number   The new assignment status.
--   p_change_reason                  No varchar2 New change reason
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        number   The version number of this
--                                           assignment.
--   p_effective_start_date         date     The date from which this change
--                                           applies.
--   p_effective_end_date           date     The last date on which this change
--                                           applies.
--
-- Post Failure:
--   The process will not update the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_status_type_cwk_asg
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_expected_system_status       in     varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_apl_asg >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process creates a new applicant assignment and if
--   neccessary, assignment budget values and a letter request. This
--   process can be called in one of two situations from other business support
--   processes:
--      create_default_apl_asg   - part of creating a new applicant
--      create_secondary_apl_asg - create additional applicant assignments.
--   This process only contains the common functionality for the above two
--   processes.
--
-- Prerequisites:
--   A valid person (p_person_id) must exist as of the effective_date
--   (p_effective_date).
--   The legislation (p_legislation_code), must be the value for the person's
--   business group (p_business_group_id).
--   The business group (p_business_group_id) is for the person (p_person_id).
--   A valid application (p_application_id) must exist for the person
--   (p_person_id) as of the effective_date (p_effective_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date                Yes date     The date from which this
--                                                assignment applies.
--   p_legislation_code              Yes varchar2 Legislation for the person's
--                                                business group.
--   p_business_group_id             Yes number   The person's business group.
--                                                reccord.
--   p_recruiter_id                  No  number
--   p_grade_id                      No  number
--   p_position_id                   No  number
--   p_job_id                        No  number
--   p_assignment_status_type_id     No  number
--   p_payroll_id                    No  number   Payroll
--   p_location_id                   No  number
--   p_person_referred_by_id         No  number
--   p_supervisor_id                 No  number
--   p_special_ceiling_step_id       No  number   Ceiling step
--   p_person_id                     Yes number   Person.
--   p_recruitment_activity_id       No  number
--   p_source_organization_id        No  number
--   p_organization_id               Yes number
--   p_people_group_id               No  number
--   p_soft_coding_keyflex_id        No  number   Soft coding keyflexfield
--   p_vacancy_id                    No  number
--   p_pay_basis_id                  No  number   Pay Basis
--   p_application_id                Yes number   The person's application
--   p_change_reason                 No  varchar2
--   p_comments                      No  varchar2
--   p_date_probation_end            No  date
--   p_default_code_comb_id          No  number
--   p_employment_category           No  varchar2
--   p_frequency                     No  varchar2
--   p_internal_address_line         No  varchar2 Internal address line
--   p_manager_flag                  No  varchar2
--   p_normal_hours                  No  number
--   p_perf_review_period            No  number   Performance review period
--   p_perf_review_period_frequency  No  varchar2 Performance review period
--   p_probation_period              No  number
--   p_probation_unit                No  varchar2
--   p_sal_review_period             No  number   Salary review period
--   p_sal_review_period_frequency   No  varchar2 Salary review period frequency
--   p_set_of_books_id               No  number
--   p_source_type                   No  varchar2
--   p_time_normal_finish            No  varchar2
--   p_time_normal_start             No  varchar2
--   p_bargaining_unit_code          No  varchar2
--   p_labour_union_member_flag      No  varchar2
--   p_hourly_salaried_code          No  varchar2
--   p_ass_attribute_category        No  varchar2
--   p_ass_attribute1                No  varchar2 Descriptive flexfield.
--   p_ass_attribute2                No  varchar2 Descriptive flexfield.
--   p_ass_attribute3                No  varchar2 Descriptive flexfield.
--   p_ass_attribute4                No  varchar2 Descriptive flexfield.
--   p_ass_attribute5                No  varchar2 Descriptive flexfield.
--   p_ass_attribute6                No  varchar2 Descriptive flexfield.
--   p_ass_attribute7                No  varchar2 Descriptive flexfield.
--   p_ass_attribute8                No  varchar2 Descriptive flexfield.
--   p_ass_attribute9                No  varchar2 Descriptive flexfield.
--   p_ass_attribute10               No  varchar2 Descriptive flexfield.
--   p_ass_attribute11               No  varchar2 Descriptive flexfield.
--   p_ass_attribute12               No  varchar2 Descriptive flexfield.
--   p_ass_attribute13               No  varchar2 Descriptive flexfield.
--   p_ass_attribute14               No  varchar2 Descriptive flexfield.
--   p_ass_attribute15               No  varchar2 Descriptive flexfield.
--   p_ass_attribute16               No  varchar2 Descriptive flexfield.
--   p_ass_attribute17               No  varchar2 Descriptive flexfield.
--   p_ass_attribute18               No  varchar2 Descriptive flexfield.
--   p_ass_attribute19               No  varchar2 Descriptive flexfield.
--   p_ass_attribute20               No  varchar2 Descriptive flexfield.
--   p_ass_attribute21               No  varchar2 Descriptive flexfield.
--   p_ass_attribute22               No  varchar2 Descriptive flexfield.
--   p_ass_attribute23               No  varchar2 Descriptive flexfield.
--   p_ass_attribute24               No  varchar2 Descriptive flexfield.
--   p_ass_attribute25               No  varchar2 Descriptive flexfield.
--   p_ass_attribute26               No  varchar2 Descriptive flexfield.
--   p_ass_attribute27               No  varchar2 Descriptive flexfield.
--   p_ass_attribute28               No  varchar2 Descriptive flexfield.
--   p_ass_attribute29               No  varchar2 Descriptive flexfield.
--   p_ass_attribute30               No  varchar2 Descriptive flexfield.
--   p_title                         No  varchar2
--   p_contract_id                   No  number
--   p_establishment_id              No  number
--   p_collective_agreement_id       No  number
--   p_cagr_id_flex_num              No  number
--   p_cagr_grade_def_id             No  number
--   p_notice_period                 No  number   Notice Period
--   p_notice_period_uom             No  varchar2 Notice Period Units
--   p_employee_category             No  varchar2 Employee Category
--   p_work_at_home                  No  varchar2 Work At Home
--   p_job_post_source_name	     No  varchar2 Job Source
--   p_validate_df_flex              No  boolean  perform/bypass descriptive
--                                                flexfield validation
--   p_grade_ladder_pgm_id	     No	 number   grade ladder id
--   p_supervisor_assignment_id	     No	 number   supervisor assignment id
--
--
-- Post Success:
--
--   The API creates the applicant assignment record, and if required,
--   assignment budget values and a letter request.  The following out
--   parameters are set.
--
--   Name                           Type     Description
--   p_assignment_id                number   Uniquely identifies the assignment
--                                           created.
--   p_object_version_number        number   The version number of this
--                                           assignment record.
--   p_effective_start_date         date     The date from which this
--                                           assignment row is applied.
--   p_effective_end_date           date     The last date on which this
--                                           assignment row applies.
--   p_assignment_sequence          number   The assignment sequence number.
--   p_assignment_number            varchar2 Validated or generated
--                                           assignment number.
--   p_comment_id                   number   The comment id if comment text
--                                           was provided.
--
-- Post Failure:
--   The process will not create the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_apl_asg
  (p_effective_date               in     date
  ,p_legislation_code             in     varchar2
  ,p_business_group_id            in     number
  ,p_recruiter_id                 in     number   default null
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_person_referred_by_id        in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_person_id                    in     number
  ,p_recruitment_activity_id      in     number   default null
  ,p_source_organization_id       in     number   default null
  ,p_organization_id              in     number
  ,p_people_group_id              in     number   default null
  ,p_soft_coding_keyflex_id       in     number   default null
  ,p_vacancy_id                   in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_application_id               in     number
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_contract_id                  in     number   default null
  ,p_establishment_id             in     number   default null
  ,p_collective_agreement_id      in     number   default null
  ,p_cagr_id_flex_num             in     number   default null
  ,p_cagr_grade_def_id            in     number   default null
-- added for collective agreeemnt module
  ,p_notice_period		  in	 number   default null
  ,p_notice_period_uom		  in     varchar2 default null
  ,p_employee_category		  in     varchar2 default null
  ,p_work_at_home		  in	 varchar2 default null
  ,p_job_post_source_name         in     varchar2 default null
  ,p_validate_df_flex             in     boolean  default true
  ,p_posting_content_id           in     number   default null
  ,p_applicant_rank               in     number   default null
  ,p_grade_ladder_pgm_id	  in	 number   default null
  ,p_supervisor_assignment_id	  in	 number   default null
  ,p_object_version_number           out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_default_apl_asg >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process creates a default applicant assignment and
--   if neccessary, assignment budget values and a letter request. This process
--   only contains the common functionality for business processes which need
--   to create an initial assignment for an applicant (e.g. create_applicant).
--
-- Prerequisites:
--
--   A valid person (p_person_id) must exist as of the effective_date
--   (p_effective_date).
--   The legislation (p_legislation_code), must be the value for the person's
--   business group (p_business_group_id).
--   The business group (p_business_group_id) is for the person (p_person_id).
--   A valid application (p_application_id) must exist for the person
--   (p_person_id) as of the effective_date (p_effective_date).

-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date                Yes date     The date from which this
--                                                assignment applies.
--   p_person_id                     Yes number   Person.
--   p_business_group_id             Yes number   The person's business group.
--   p_application_id                Yes number   The person's application
--                                                record.
--   p_vacancy_id                    No  Number   Vacancy_id for which this
--                                                applicant is applying for.
-- Post Success:
--
--   The API creates the applicant assignment record, and if required,
--   assignment budget values and a letter request.  The following out
--   parameters are set.
--
--   Name                           Type     Description
--   p_assignment_id                number   Uniquely identifies the assignment
--                                           created.
--   p_object_version_number        number   The version number of this
--                                           assignment.
--   p_assignment_sequence          number   Assignment sequence.
--
-- Post Failure:
--   The process will not create the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_default_apl_asg
  (p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_business_group_id            in     number
  ,p_application_id               in     number
  ,p_vacancy_id                   in     number default null
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_assignment_sequence             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_status_type_apl_asg >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process updates an applicant assignment with an
--   active, offer or accepted assignment status type.
--
--   Any out-of-date letter requests for the assignment will be removed.
--   (i.e. If there is a pending letter request line, where the conditions for
--   sending it are no longer met then the request line will be deleted.)
--
--   If a letter definition exists for the new assignment status type then a
--   new letter request line will be created for this assignment.
--
--   This is a supporting process for business processes like 'offer_apl_asg'.
--   The common features required by these business processes have been
--   implemented in here to save duplication and dual maintenance.
--
--   If the caller does not explicitly pass in a status type, the process will
--   use the default ACTIVE_APL, OFFER or ACCEPTED status for the assignment's
--   business group will be used.
--
--   If the assignment's status is already of the correct system type this
--   process can be used to set a different active, offer or accepted status.
--   Updates from an employee assignment status (ACTIVE_ASSIGN, SUSP_ASSIGN,
--   TERM_ASSIGN and END) are not allowed. Only applicant assignments can be
--   altered with this process.  The 'update_status_type_emp_asg' business
--   support process should be used for modifying employee assignments.
--
-- Prerequisites:
--   A valid assignment (p_assignment_id) must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date                Yes date     The operation date.
--   p_datetrack_update_mode         Yes varchar2 The mode of update.
--   p_assignment_id                 Yes number   Assignment
--   p_object_version_number         Yes number   Version number of the
--                                                assignment record.
--   p_expected_system_status        Yes varchar2 The intended system status of
--                                                the assignment as a result of
--                                                the update. Either ACTIVE_APL,
--                                                OFFER or ACCEPTED.
--   p_assignment_status_type_id      No number   The new assignment status.
--   p_change_reason                  No varchar2 Applicant assignment status
--                                                change reason.
--
--
-- Post Success:
--
--   The API updates the assignment record and if required, maintains the
--   letter requests.  The following out parameters are set.
--
--   Name                           Type     Description
--   p_effective_start_date         date     The date from which this change
--                                           applies.
--   p_effective_end_date           date     The last date on which this change
--                                           applies.
--
-- Post Failure:
--   The process will not update the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_status_type_apl_asg
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_expected_system_status       in     varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< actual_term_cwk_asg >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure processes one contingent worker assignment when the actual
--   termination date is entered. This logic is common to the
--   'actual_termination_cwk_asg' and 'actual_termination_cwk' business
--   processes.
--
--   The 'actual_termination_cwk_asg' business process only allows the user to
--   terminate one non-primary assignment at a time. Where as the
--   'actual_termination_cwk' business process needs to terminate all
--   non-primary assignments and the primary assignment.
--
--   This business support process assumes the p_actual_termination_date,
--   p_last_standard_process_date and p_assignment_status_type_id parameters
--   have been correctly validated or derived by the calling logic. For US
--   legislation p_last_standard_process_date should always be set to null.
--   This will ensure unnecessary logic is not executed.
--
--   This business support process updates the assignment, date effectively
--   deletes element entries where the corresponding element termination rule
--   is actual_termination or last_standard_process, deletes affected
--   unprocessed run results, deletes affected pay proposals and deletes
--   affected assignment link usages.
--
-- Prerequisites:
--   A valid assignment (p_assignment_id) must exist as of the actual
--   termination date (p_actual_termination_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_actual_termination_date       Yes date
--   p_last_standard_process_date    Yes date
--   p_assignment_status_type_id     Yes number
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        number   The version number of this
--                                           assignment, as of the actual
--                                           termination date + 1.
--   p_effective_start_date         date     Effective start date of the
--                                           assignment row, which exists as of
--                                           the actual termination date.
--   p_effective_end_date           date     Effective end date of the
--                                           assignment row, which exists as of
--                                           the actual termination date.
--   p_asg_future_changes_warning   boolean  Set to true if at least one
--                                           assignment change, after the
--                                           actual termination date, has been
--                                           overwritten with the new
--                                           assignment status type. Set to
--                                           false when there are no changes in
--                                           the future.
--   p_entries_changed_warning      varchar2 Set to 'Y' when at least one
--                                           element entry was altered due to
--                                           the assignment change.
--                                           Set to 'S' if at least one salary
--                                           element entry was affected.
--                                           ('S' is a more specific case of
--                                           'Y' because non-salary entries may
--                                           or may not have been affected at
--                                           the same time). Otherwise set to
--                                           'N', when no element entries were
--                                           changed.
--   p_pay_proposal_warning         boolean  Set to true if any pay proposals
--                                           existing after the
--					     actual_termination_date,has been
--                                           deleted. Set to false when there
--                                           are no pay proposals after actual_
--                                           termination_date.
-- Post Failure:
--   The process will not process the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure actual_term_cwk_asg
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in     date
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< final_process_cwk_asg >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure processes one contingent worker assignment when the final
--   process date is entered. This logic is common to the
--   'final_process_cwk_asg' and 'final_process_cwk' business processes.
--
--   The 'final_process_cwk_asg' business process only allows the user to end
--   one non-primary assignment at a time. Whereas the 'final_process_emp'
--   business process needs to terminate all non-primary assignments and the
--   primary assignment.
--
--   The person assignment must already have an assignment status which
--   corresponds to the TERM_CWK_ASSIGN system status. (This is set by calling
--   the 'actual_termination_cwk_asg' or 'actual_termination_cwk' business
--   process).  No changes will be allowed if the assignment status is not
--   TERM_CWK_ASSIGN on the date after the final process date.
--
--   This business support process date effectively deletes the assignment,
--   date effectively deletes element entries where the corresponding element
--   termination rule is last_standard_process or final_process, deletes
--   affected unprocessed run results, deletes affected pay proposals and
--   deletes affected assignment link usages.
--
--   Element entries which have a corresponding 'Last Standard Process'
--   termination rule will have already been date effectively deleted by the
--   'actual_term_cwk_asg' business support process. It is still necessary
--   for this procedure to process these element entries because the final
--   process date may come before the defaulted last_standard_process date.
--
-- Prerequisites:
--   A valid assignment (p_assignment_id) must exist as of the final process
--   date (p_final_process_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_final_process_date            Yes date
--   p_actual_termination_date       Yes date
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        number   The version number of this
--                                           assignment.
--   p_effective_start_date         date
--   p_effective_end_date           date
--   p_org_now_no_manager_warning   boolean  Set to true if this assignment
--                                           was a manager and due to its
--                                           termination there will be no
--                                           managers in assignment's
--                                           organization. Set to false if
--                                           there is still another manager
--                                           in the assignment's organization
--                                           or this assignment was not a
--                                           manager. The warning value only
--                                           applies as of
--                                           p_final_process_date.
--   p_asg_future_changes_warning   boolean  Set to true if at least one
--                                           assignment change, after the
--                                           actual termination date, has been
--                                           overwritten with the new
--                                           assignment status type. Set to
--                                           false when there are no changes in
--                                           the future.
--   p_entries_changed_warning      varchar2 Set to 'Y' when at least one
--                                           element entry was altered due to
--                                           the assignment change.
--                                           Set to 'S' if at least one salary
--                                           element entry was affected.
--                                           ('S' is a more specific case of
--                                           'Y' because non-salary entries may
--                                           or may not have been affected at
--                                           the same time). Otherwise set to
--                                           'N', when no element entries were
--                                           changed.
--
--
-- Post Failure:
--   The process will not process the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--
procedure final_process_cwk_asg
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in     date
  ,p_actual_termination_date      in     date
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< cleanup_spp >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This procedure will remove invalid SPP records for the given assignment.
--
-- Prerequisites:
--
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_datetrack_mode                Yes varchar2
--   p_validation_start_date         Yes date
--
--
-- Post Success:
--
--   Will remove all invalid SPP records for the given assignment id.
--   Name                           Type          Description
--   p_del_end_future_spp           boolean       Set to true if any
--                                                invalid or future SPP
--                                                records are deleted
--                                                depends on DT mode
--
-- Post Failure:
--
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure cleanup_spp
   (p_assignment_id          in  per_all_assignments_f.assignment_id%Type
   ,p_datetrack_mode         in  varchar2
   ,p_validation_start_date  in  date
   ,p_del_end_future_spp     in  out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_valid_placement_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This procedure will remove invalid SPP records for the given assignment.
--
-- Prerequisites:
--
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_datetrack_mode                Yes varchar2
--   p_validation_start_date         Yes date
--
--
-- Post Success:
--
--   Will remove all invalid SPP records for the given assignment id.
--   Name                           Type          Description
--   p_del_end_future_spp           boolean       Set to true if any
--                                                invalid or future SPP
--                                                records are deleted
--                                                depends on DT mode
--
-- Post Failure:
--
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_valid_placement_id
   (p_assignment_id          in  per_all_assignments_f.assignment_id%Type
   ,p_placement_id           in  per_spinal_point_placements_f.placement_id%Type
   ,p_validation_start_date  in  date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< ben_delete_assgt_checks >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This procedure will set the out parameter p_life_events_exists if there
--   are any Started Life Events exists for the assignment that is beign deleted.
--
-- Prerequisites:
--
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_datetrack_mode                Yes varchar2
--
--
-- Post Success:
--
--   Name                           Type          Description
--   p_life_events_exists           boolean       Set to true if any
--                                                invalid or future SPP
--                                                records are deleted
--                                                depends on DT mode
--
-- Post Failure:
--
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure ben_delete_assgt_checks
   (p_assignment_id         in  per_all_assignments_f.assignment_id%Type
   ,p_datetrack_mode        in  varchar2
   ,p_life_events_exists    out NOCOPY boolean);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< irc_delete_assgt_checks  >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   If there is an Offer for an Assignment that is selected for Deletion, then
--   User should not be allowed to process the Delete operation further.
--
--   When Deleting an Assignment or Date Track range of an Assignment, application
--   should delete the corresponding Assignment Status History Rows.
--
--   If the Assignment that is selected for Deletion has any life events with status
--   'Started', then user should be notified by setting a warning to back out the
--   life events.
--
-- Prerequisites:
--
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_datetrack_mode                Yes varchar2
--   p_validation_start_date         Yes date
--
--
-- Post Success:
--
--   Will remove all the corresponding rows in irc_assignment_statuses
--
-- Post Failure:
--
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure irc_delete_assgt_checks
   (p_assignment_id         in per_all_assignments_f.assignment_id%Type
   ,p_datetrack_mode        in varchar2
   ,p_validation_start_date in date );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This procedure will remove invalid SPP records for the given assignment.
--
-- Prerequisites:
--
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_rec                          Yes per_asg_shd.g_rec_type
--   p_datetrack_mode               Yes varchar2
--   p_validation_start_date        Yes date
--   p_validation_end_date          Yes date
--
--
-- Post Success:
--
--   Name                           Type          Description
--   p_org_now_no_manager_warning   boolean       Set to true if organization
--                                                do not have a manager now
--   p_loc_change_tax_issues        boolean       Set to true if there is any
--                                                affect on fed tax records due
--                                                to the location change
--   p_delete_asg_budgets           boolean       Set to true if assignment budget
--                                                values are deleted
--   p_element_salary_warning       boolean       Set to true if salary elements
--                                                have an impact of the provided
--                                                Delete operation.
--   p_element_entries_warning      boolean       Set to true if any elements entries
--                                                have an impact of the provided
--                                                Delete operation.
--   p_spp_warning                  boolean       Set to true if any grade step
--                                                progression records have an
--                                                impact due to the current Delete
--   p_cost_warning                 boolean       Set to true if Cost records are
--                                                not adjusted as per the assignment
--   p_life_events_exists   	    boolean       Set to true if there are any
--                                                Life Events with status "Started"
--                                                are available for the deleted assignment
--   p_cobra_coverage_elements      boolean       Set to true if COBRA coverage elements
--                                                got Invalidated
--   p_assgt_term_elements          boolean       Set to true if an Assignment with
--                                                status "TERM_ASSIGN" has been
--                                                deleted and elements are not adjusted
--   Post Failure:
--
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure pre_delete
    (p_rec                         in  per_asg_shd.g_rec_type,
     p_effective_date              in  date,
     p_datetrack_mode              in  varchar2,
     p_validation_start_date       in  date,
     p_validation_end_date         in  date,
     p_org_now_no_manager_warning  out nocopy boolean,
     p_loc_change_tax_issues       OUT nocopy boolean,
     p_delete_asg_budgets          OUT nocopy boolean,
     p_element_salary_warning      OUT nocopy boolean,
     p_element_entries_warning     OUT nocopy boolean,
     p_spp_warning                 OUT nocopy boolean,
     p_cost_warning                OUT nocopy boolean,
     p_life_events_exists   	   OUT nocopy boolean,
     p_cobra_coverage_elements     OUT nocopy boolean,
     p_assgt_term_elements         OUT nocopy boolean,
     --
     p_new_prim_ass_id             OUT nocopy number,
     p_prim_change_flag            OUT nocopy varchar2,
     p_new_end_date                OUT nocopy date,
     p_new_primary_flag            OUT nocopy varchar2,
     p_s_pay_id                    OUT nocopy number,
     p_cancel_atd                  OUT nocopy date,
     p_cancel_lspd                 OUT nocopy date,
     p_reterm_atd                  OUT nocopy date,
     p_reterm_lspd                 OUT nocopy date,
     ---
     p_appl_asg_new_end_date       OUT nocopy date );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< post_delete >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This procedure will remove invalid SPP records for the given assignment.
--
-- Prerequisites:
--
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_rec                          Yes per_asg_shd.g_rec_type
--   p_datetrack_mode               Yes varchar2
--   p_validation_start_date        Yes date
--   p_validation_end_date        Yes date
--
--
-- Post Success:
--
--   Name                           Type          Description
--   p_org_now_no_manager_warning   boolean       Set to true if organization
--                                                do not have a manager now
--   p_loc_change_tax_issues        boolean       Set to true if there is any
--                                                affect on fed tax records due
--                                                to the location change
--   p_delete_asg_budgets           boolean       Set to true if assignment budget
--                                                values are deleted
--   p_element_salary_warning       boolean       Set to true if salary elements
--                                                have an impact of the provided
--                                                Delete operation.
--   p_element_entries_warning      boolean       Set to true if any elements entries
--                                                have an impact of the provided
--                                                Delete operation.
--   p_spp_warning                  boolean       Set to true if any grade step
--                                                progression records have an
--                                                impact due to the current Delete
--   p_cost_warning                 boolean       Set to true if Cost records are
--                                                not adjusted as per the assignment
--   p_life_events_exists   	    boolean       Set to true if there are any
--                                                Life Events with status "Started"
--                                                are available for the deleted assignment
--   p_cobra_coverage_elements      boolean       Set to true if COBRA coverage elements
--                                                got Invalidated
--   p_assgt_term_elements          boolean       Set to true if an Assignment with
--                                                status "TERM_ASSIGN" has been
--                                                deleted and elements are not adjusted
--
-- Post Failure:
--
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure post_delete
    (p_rec                         in per_asg_shd.g_rec_type,
     p_effective_date              in date,
     p_datetrack_mode              in varchar2,
     p_validation_start_date       in date,
     p_validation_end_date         in date,
     p_org_now_no_manager_warning  out nocopy boolean,
     p_loc_change_tax_issues       OUT nocopy boolean,
     p_delete_asg_budgets          OUT nocopy boolean,
     p_element_salary_warning      OUT nocopy boolean,
     p_element_entries_warning     OUT nocopy boolean,
     p_spp_warning                 OUT nocopy boolean,
     p_cost_warning                OUT nocopy boolean,
     p_life_events_exists   	   OUT nocopy boolean,
     p_cobra_coverage_elements     OUT nocopy boolean,
     p_assgt_term_elements         OUT nocopy boolean,
     --
     p_new_prim_ass_id             IN number,
     p_prim_change_flag            IN varchar2,
     p_new_end_date                IN date,
     p_new_primary_flag            IN varchar2,
     p_s_pay_id                    IN number,
     p_cancel_atd                  IN date,
     p_cancel_lspd                 IN date,
     p_reterm_atd                  IN date,
     p_reterm_lspd                 IN date,
     ---
     p_appl_asg_new_end_date       IN date );
--
end hr_assignment_internal;

/
