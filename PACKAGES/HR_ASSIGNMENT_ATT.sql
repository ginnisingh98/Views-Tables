--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_ATT" AUTHID CURRENT_USER as
/* $Header: peasgati.pkh 115.5 2004/03/07 19:27:12 sgudiwad ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_asg >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API updates the assignment record as identified by p_assignment_id
--   and p_object_version_number using the pseudo datetrack modes of
--   ATTRIBUTE_UPDATE or ATTRIBUTE_CORRECTION. Depending on the pseudo mode
--   specified, the hr_assignment_api.update_assignment API is called with
--   true datetrack modes of either UPDATE, CORRECTION or UPDATE_CHANGE_INSERT.
--   It is important to note that the pseudo modes are not part of DateTrack
--   core. The pseudo mode corresponds to the p_attribute_update_mode
--   parameter.
--
--   The ATTRIBUTE_UPDATE will update the current and all rows in the future
--   where the attribute(s) have the same value. The future update of the
--   attribute(s) will only be completed when either the last row is selected
--   or the attribute(s) value has changed.
--
--   The ATTRIBUTE_CORRECTION works by first updating all rows in the
--   future where the attribute(s) have the same value. The future update of
--   the attribute will only be completed when either the last row is
--   selected or the attribute(s) value has changed. Next, the change has to
--   be applied in the past using the same logic as future rows except
--   it is only complete when either the first row is selected or the
--   attribute value has changed.
--
-- Prerequisites
--   The assignment record, identified by p_assignment_id and
--   p_object_version_number, must already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--   p_effective_date                Yes date     The effective date of the
--                                                change
--   p_attribute_update_mode         Yes varchar2 Update attribute mode
--                                                Valid values are;
--                                                ATTRIBUTE_UPDATE,
--                                                ATTRIBUTE_CORRECTION
--   p_assignment_id                     number   ID of the assignment
--   p_object_version_number         Yes number   Version number of the
--                                                assignment record
--   p_supervisor_id                     number   Supervisor
--   p_assignment_number                 number   Assignment number
--   p_change_reason                     varchar2 Reason for the change
--   p_comments                          varchar2 Comments
--   p_date_probation_end                date     End date of probation period
--   p_default_code_comb_id              number   Foreign key to
--                                                GL_CODE_COMBINATIONS
--   p_frequency                         varchar2 Frequency for quoting working hours (eg per week)
--   p_internal_address_line             varchar2 Internal address line
--   p_manager_flag                      varchar2 Indicates whether the
--                                                employee is a manager
--   p_normal_hours                      number   Normal working hours
--   p_perf_review_period                number   Performance review period
--   p_perf_review_period_frequency      varchar2 Units for quoting  performance
--                                                review period (eg months)
--   p_probation_period                  number   Length of probation period
--   p_probation_unit                    varchar2 Units for quoting probation period (eg months)
--   p_sal_review_period                 number   Salary review period
--   p_sal_review_period_frequency       varchar2 Units for quoting salary review
--                                                period (eg months)
--   p_set_of_books_id                   number   Set of books (GL)
--   p_source_type                       varchar2 Recruitment activity source
--   p_time_normal_finish                varchar2 Normal work finish time
--   p_time_normal_start                 varchar2 Normal work start time
--   p_ass_attribute_category            varchar2 Descriptive flexfield
--                                                attribute category
--   p_ass_attribute1                    varchar2 Descriptive flexfield
--   p_ass_attribute2                    varchar2 Descriptive flexfield
--   p_ass_attribute3                    varchar2 Descriptive flexfield
--   p_ass_attribute4                    varchar2 Descriptive flexfield
--   p_ass_attribute5                    varchar2 Descriptive flexfield
--   p_ass_attribute6                    varchar2 Descriptive flexfield
--   p_ass_attribute7                    varchar2 Descriptive flexfield
--   p_ass_attribute8                    varchar2 Descriptive flexfield
--   p_ass_attribute9                    varchar2 Descriptive flexfield
--   p_ass_attribute10                   varchar2 Descriptive flexfield
--   p_ass_attribute11                   varchar2 Descriptive flexfield
--   p_ass_attribute12                   varchar2 Descriptive flexfield
--   p_ass_attribute13                   varchar2 Descriptive flexfield
--   p_ass_attribute14                   varchar2 Descriptive flexfield
--   p_ass_attribute15                   varchar2 Descriptive flexfield
--   p_ass_attribute16                   varchar2 Descriptive flexfield
--   p_ass_attribute17                   varchar2 Descriptive flexfield
--   p_ass_attribute18                   varchar2 Descriptive flexfield
--   p_ass_attribute19                   varchar2 Descriptive flexfield
--   p_ass_attribute20                   varchar2 Descriptive flexfield
--   p_ass_attribute21                   varchar2 Descriptive flexfield
--   p_ass_attribute22                   varchar2 Descriptive flexfield
--   p_ass_attribute23                   varchar2 Descriptive flexfield
--   p_ass_attribute24                   varchar2 Descriptive flexfield
--   p_ass_attribute25                   varchar2 Descriptive flexfield
--   p_ass_attribute26                   varchar2 Descriptive flexfield
--   p_ass_attribute27                   varchar2 Descriptive flexfield
--   p_ass_attribute28                   varchar2 Descriptive flexfield
--   p_ass_attribute29                   varchar2 Descriptive flexfield
--   p_ass_attribute30                   varchar2 Descriptive flexfield
--   p_title                             varchar2 Title -must be NULL
--   p_project_title                     varchar2 Project Title
--   p_vendor_assignment_number          varchar2 Vendor Assignment Number
--   p_vendor_employee_number            varchar2 Vendor Employee Number
--   p_vendor_id                         number Vendor Id
--   p_assignment_type                   varchar2 Assignment Type
--
-- Post Success:
--
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   New version number of the
--                                           assignment
--   p_comment_id                   number   If p_validate is false and any
--                                           comment text exists, set to the id
--                                           of the corresponding person
--                                           comment row.  If p_validate is
--                                           true, or no comment text exists
--                                           this will be null.
--   p_effective_start_date         date     The effective start date for the
--                                           assignment changes
--   p_effective_end_date           date     The effective end date for the
--                                           assignment changes
--   p_no_managers_warning          boolean  Set to true if manager_flag is
--                                           updated from 'Y' to 'N' and no
--                                           other manager exists in
--                                           p_organization_id.
--                                           Set to false if another manager
--                                           exists in p_organization_id.
--                                           This parameter is always set
--                                           to false if manager_flag is
--                                           not updated. The warning value
--                                           only applies as of
--                                           p_effective_date.
--   p_other_manager_warning        boolean  Set to true if manager_flag is
--                                           changed from 'N' to 'Y' and a
--                                           manager already exists in the
--                                           organization, p_organization_id,
--                                           at p_effective_date.
--                                           Set to false if no other managers
--                                           exist in p_organization_id.
--                                           This is always set to false
--                                           if manager_flag is not updated.
--                                           The warning value only applies as
--                                           of p_effective_date.
-- Post Failure:
--   The API does not update the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_attribute_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  -- Assignment Security
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number

  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_project_title                in     varchar2 default hr_api.g_varchar2
  ,p_vendor_assignment_number     in     varchar2 default hr_api.g_varchar2
  ,p_vendor_employee_number       in     varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in     number default hr_api.g_number
  ,p_assignment_type              in     varchar2
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_asg_criteria >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API updates the assignment record as identified by p_assignment_id
--   and p_object_version_number using the pseudo datetrack modes of
--   ATTRIBUTE_UPDATE or ATTRIBUTE_CORRECTION. Depending on the pseudo mode
--   specified, the hr_assignment_api.update_assignment API is called with
--   true datetrack modes of either UPDATE, CORRECTION or UPDATE_CHANGE_INSERT.
--   It is important to note that the pseudo modes are not part of DateTrack
--   core. The pseudo mode corresponds to the p_attribute_update_mode
--   parameter.
--
--   The ATTRIBUTE_UPDATE will update the current and all rows in the future
--   where the attribute(s) have the same value. The future update of the
--   attribute(s) will only be completed when either the last row is selected
--   or the attribute(s) value has changed.
--
--   The ATTRIBUTE_CORRECTION works by first updating all rows in the
--   future where the attribute(s) have the same value. The future update of
--   the attribute will only be completed when either the last row is
--   selected or the attribute(s) value has changed. Next, the change has to
--   be applied in the past using the same logic as future rows except
--   it is only complete when either the first row is selected or the
--   attribute value has changed.
--
-- Prerequisites
--   The assignment record, identified by p_assignment_id and
--   p_object_version_number, must already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--   p_effective_date                Yes date     The effective date of the
--                                                change
--   p_attribute_update_mode         Yes varchar2 Update attribute mode
--                                                Valid values are;
--                                                ATTRIBUTE_UPDATE,
--                                                ATTRIBUTE_CORRECTION
--   p_assignment_id                     number   ID of the assignment
--   p_object_version_number         Yes number   Version number of the
--                                                assignment record
--   p_grade_id                          number   Grade
--   p_position_id                       number   Position
--   p_job_id                            number   Job
--   p_payroll_id                        number   Payroll
--   p_location_id                       number   Location
--   p_special_ceiling_step_id           number   Special ceiling step as of
--                                                p_effective_date
--   p_organization_id                   number   Organization
--   p_pay_basis_id                      number   Salary basis
--   p_employment_category               varchar2 Employment category
--
-- Post Success:
--
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   New version number of the
--                                           assignment
--   p_comment_id                   number   If p_validate is false and any
--                                           comment text exists, set to the id
--                                           of the corresponding person
--                                           comment row.  If p_validate is
--                                           true, or no comment text exists
--                                           this will be null.
--   p_effective_start_date         date     The effective start date for the
--                                           assignment changes
--   p_effective_end_date           date     The effective end date for the
--                                           assignment changes
--   p_no_managers_warning          boolean  Set to true if manager_flag is
--                                           updated from 'Y' to 'N' and no
--                                           other manager exists in
--                                           p_organization_id.
--                                           Set to false if another manager
--                                           exists in p_organization_id.
--                                           This parameter is always set
--                                           to false if manager_flag is
--                                           not updated. The warning value
--                                           only applies as of
--                                           p_effective_date.
--   p_other_manager_warning        boolean  Set to true if manager_flag is
--                                           changed from 'N' to 'Y' and a
--                                           manager already exists in the
--                                           organization, p_organization_id,
--                                           at p_effective_date.
--                                           Set to false if no other managers
--                                           exist in p_organization_id.
--                                           This is always set to false
--                                           if manager_flag is not updated.
--                                           The warning value only applies as
--                                           of p_effective_date.
--   p_spp_delete_warning           boolean  Set to true when grade step and
--                                           point placements are date
--                                           effectively ended or purged
--                                           by this process.
--                                           Both types of change occur
--                                           when grade_id is changed and
--                                           spinal point placement rows exist
--                                           over the updated date range.
--                                           Set to false when no grade step
--                                           and point placements are affected.
--   p_entries_changed_warning      varchar2 Set to 'Y' when one or more
--                                           element entries are changed due
--                                           to the assignment change.
--                                           Set to 'S' if at least one
--                                           salary element entry is affected.
--                                           ('S' is a more specific case of
--                                           'Y')
--                                           Set to 'N' when no element entries
--                                           are changed.
--   p_tax_district_changed_warning boolean  Set to true if the assignment
--                                           is for a GB legislation business
--                                           group and the old and new payrolls
--                                           are in different tax districts.
--                                           Set to false, if the assignment is
--                                           not for a GB legislation business
--                                           group, or the payroll was not
--                                           updated, or the old and new
--                                           payrolls are in the same tax
--                                           district.
--
-- Post Failure:
--   The API does not update the assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_asg_criteria
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_attribute_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_employment_category          in     varchar2 default hr_api.g_varchar2
  ,p_assignment_type              in     varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  );
--
end hr_assignment_att;

 

/
