--------------------------------------------------------
--  DDL for Package HR_EX_EMPLOYEE_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EX_EMPLOYEE_INTERNAL" AUTHID CURRENT_USER as
/* $Header: peexebsi.pkh 120.4.12010000.1 2008/07/28 04:40:30 appldev ship $ */
--
-- Package globals
--
g_mask_pds_ler boolean := FALSE;
g_actual_termination_date date;
--
-- ----------------------------------------------------------------------------
-- |--------------------< Terminate_Employee (overloaded) >-------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure terminate_employee
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_actual_termination_date       in     date     default hr_api.g_date
  ,p_final_process_date            in out nocopy date
  ,p_last_standard_process_date    in out nocopy date
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ,p_adjusted_svc_date             in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_pds_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pds_information1              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information2              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information3              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information4              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information5              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information6              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information7              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information8              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information9              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information10             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information11             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information12             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information13             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information30             in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_addl_rights_warning              out nocopy boolean  -- Fix 1370960
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Terminate_Employee >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process has been written to provide a single
--   call point for the 'End Employment' form when performing employee
--   termination which involves calling the following APIs :
--
--      actual_termination_emp
--      final_process_emp
--      update_term_details_emp
--      update_pds_details
--
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged.  If false
--                                                then the period of service,
--                                                person, assignment and
--                                                element entries are
--                                                updated.
--   p_period_of_service_id         Yes  number   ID of the period of service
--   p_object_version_number        Yes  number   Version number of the
--                                                period of service
--
-- Post Success:
--   The API updates the period of service, modifies the person, assignments,
--   element entries and sets the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of the
--                                           updated period of service record.
--                                           If p_validate is true, set to the
--                                           same value you passed in.
--
-- Post Failure:
--   The API does not update the period of service, person, assignments, or
--   element entries and raises an error.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure terminate_employee
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_actual_termination_date       in     date     default hr_api.g_date
  ,p_final_process_date            in out nocopy date
  ,p_last_standard_process_date    in out nocopy date
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ,p_adjusted_svc_date             in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_pds_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pds_information1              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information2              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information3              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information4              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information5              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information6              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information7              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information8              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information9              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information10             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information11             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information12             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information13             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information30             in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_addl_rights_warning              out nocopy boolean  -- Fix 1370960
  ,p_alu_change_warning               out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< reverse_terminate_employee >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--  This business support process is not published, hence not meant for public calls.
--
-- Prerequisites:
--   The employee must exist in the database.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  Number   person_id
--   p_actual_termination_date      Yes  date     Actual termination date
--   p_clear_details                Yes  varchar2
--
-- Post Success:
--   The procedure will raise a Business Event when an employee's termination
--   is cancelled.
--
-- Access Status:
--   Internal development use only
--
-- {End Of Comments}

procedure reverse_terminate_employee
  (p_person_id                     in     number
  ,p_actual_termination_date       in     date
  ,p_clear_details                 in     varchar2
  );
--
end hr_ex_employee_internal;

/
