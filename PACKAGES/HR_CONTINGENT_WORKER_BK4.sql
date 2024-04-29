--------------------------------------------------------
--  DDL for Package HR_CONTINGENT_WORKER_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTINGENT_WORKER_BK4" AUTHID CURRENT_USER as
/* $Header: pecwkapi.pkh 120.1.12010000.1 2008/07/28 04:28:14 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< terminate_placement_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure terminate_placement_b
    (p_effective_date                in     date
    ,p_person_id                     in     number
    ,p_date_start                    in     date
    ,p_object_version_number         in     number
    ,p_person_type_id                in     number
    ,p_assignment_status_type_id     in     number
    ,p_actual_termination_date       in     date
    ,p_final_process_date            in     date
    ,p_last_standard_process_date    in     date
    ,p_termination_reason            in     varchar2
    ,p_projected_termination_date    in     date
    ,p_attribute_category            in     varchar2
    ,p_attribute1                    in     varchar2
    ,p_attribute2                    in     varchar2
    ,p_attribute3                    in     varchar2
    ,p_attribute4                    in     varchar2
    ,p_attribute5                    in     varchar2
    ,p_attribute6                    in     varchar2
    ,p_attribute7                    in     varchar2
    ,p_attribute8                    in     varchar2
    ,p_attribute9                    in     varchar2
    ,p_attribute10                   in     varchar2
    ,p_attribute11                   in     varchar2
    ,p_attribute12                   in     varchar2
    ,p_attribute13                   in     varchar2
    ,p_attribute14                   in     varchar2
    ,p_attribute15                   in     varchar2
    ,p_attribute16                   in     varchar2
    ,p_attribute17                   in     varchar2
    ,p_attribute18                   in     varchar2
    ,p_attribute19                   in     varchar2
    ,p_attribute20                   in     varchar2
    ,p_attribute21                   in     varchar2
    ,p_attribute22                   in     varchar2
    ,p_attribute23                   in     varchar2
    ,p_attribute24                   in     varchar2
    ,p_attribute25                   in     varchar2
    ,p_attribute26                   in     varchar2
    ,p_attribute27                   in     varchar2
    ,p_attribute28                   in     varchar2
    ,p_attribute29                   in     varchar2
    ,p_attribute30                   in     varchar2
    ,p_information_category          in     varchar2
    ,p_information1                  in     varchar2
    ,p_information2                  in     varchar2
    ,p_information3                  in     varchar2
    ,p_information4                  in     varchar2
    ,p_information5                  in     varchar2
    ,p_information6                  in     varchar2
    ,p_information7                  in     varchar2
    ,p_information8                  in     varchar2
    ,p_information9                  in     varchar2
    ,p_information10                 in     varchar2
    ,p_information11                 in     varchar2
    ,p_information12                 in     varchar2
    ,p_information13                 in     varchar2
    ,p_information14                 in     varchar2
    ,p_information15                 in     varchar2
    ,p_information16                 in     varchar2
    ,p_information17                 in     varchar2
    ,p_information18                 in     varchar2
    ,p_information19                 in     varchar2
    ,p_information20                 in     varchar2
    ,p_information21                 in     varchar2
    ,p_information22                 in     varchar2
    ,p_information23                 in     varchar2
    ,p_information24                 in     varchar2
    ,p_information25                 in     varchar2
    ,p_information26                 in     varchar2
    ,p_information27                 in     varchar2
    ,p_information28                 in     varchar2
    ,p_information29                 in     varchar2
    ,p_information30                 in     varchar2
    );
--
-- ----------------------------------------------------------------------------
-- |---------------------< terminate_placement_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure terminate_placement_a
    (p_effective_date                in     date
    ,p_person_id                     in     number
    ,p_date_start                    in     date
    ,p_object_version_number         in     number
    ,p_person_type_id                in     number
    ,p_assignment_status_type_id     in     number
    ,p_actual_termination_date       in     date
    ,p_final_process_date            in     date
    ,p_last_standard_process_date    in     date
    ,p_termination_reason            in     varchar2
    ,p_projected_termination_date    in     date
    ,p_attribute_category            in     varchar2
    ,p_attribute1                    in     varchar2
    ,p_attribute2                    in     varchar2
    ,p_attribute3                    in     varchar2
    ,p_attribute4                    in     varchar2
    ,p_attribute5                    in     varchar2
    ,p_attribute6                    in     varchar2
    ,p_attribute7                    in     varchar2
    ,p_attribute8                    in     varchar2
    ,p_attribute9                    in     varchar2
    ,p_attribute10                   in     varchar2
    ,p_attribute11                   in     varchar2
    ,p_attribute12                   in     varchar2
    ,p_attribute13                   in     varchar2
    ,p_attribute14                   in     varchar2
    ,p_attribute15                   in     varchar2
    ,p_attribute16                   in     varchar2
    ,p_attribute17                   in     varchar2
    ,p_attribute18                   in     varchar2
    ,p_attribute19                   in     varchar2
    ,p_attribute20                   in     varchar2
    ,p_attribute21                   in     varchar2
    ,p_attribute22                   in     varchar2
    ,p_attribute23                   in     varchar2
    ,p_attribute24                   in     varchar2
    ,p_attribute25                   in     varchar2
    ,p_attribute26                   in     varchar2
    ,p_attribute27                   in     varchar2
    ,p_attribute28                   in     varchar2
    ,p_attribute29                   in     varchar2
    ,p_attribute30                   in     varchar2
    ,p_information_category          in     varchar2
    ,p_information1                  in     varchar2
    ,p_information2                  in     varchar2
    ,p_information3                  in     varchar2
    ,p_information4                  in     varchar2
    ,p_information5                  in     varchar2
    ,p_information6                  in     varchar2
    ,p_information7                  in     varchar2
    ,p_information8                  in     varchar2
    ,p_information9                  in     varchar2
    ,p_information10                 in     varchar2
    ,p_information11                 in     varchar2
    ,p_information12                 in     varchar2
    ,p_information13                 in     varchar2
    ,p_information14                 in     varchar2
    ,p_information15                 in     varchar2
    ,p_information16                 in     varchar2
    ,p_information17                 in     varchar2
    ,p_information18                 in     varchar2
    ,p_information19                 in     varchar2
    ,p_information20                 in     varchar2
    ,p_information21                 in     varchar2
    ,p_information22                 in     varchar2
    ,p_information23                 in     varchar2
    ,p_information24                 in     varchar2
    ,p_information25                 in     varchar2
    ,p_information26                 in     varchar2
    ,p_information27                 in     varchar2
    ,p_information28                 in     varchar2
    ,p_information29                 in     varchar2
    ,p_information30                 in     varchar2
    ,p_supervisor_warning            in     boolean
    ,p_event_warning                 in     boolean
    ,p_interview_warning             in     boolean
    ,p_review_warning                in     boolean
    ,p_recruiter_warning             in     boolean
    ,p_asg_future_changes_warning    in     boolean
    ,p_entries_changed_warning       in     varchar2
    ,p_pay_proposal_warning          in     boolean
    ,p_dod_warning                   in     boolean
    ,p_org_now_no_manager_warning    in     boolean
    ,p_addl_rights_warning           in     boolean -- Fix 1370960
    );
end hr_contingent_worker_bk4;

/
