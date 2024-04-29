--------------------------------------------------------
--  DDL for Package PER_ALLOCATED_TASK_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ALLOCATED_TASK_BK2" AUTHID CURRENT_USER as
/* $Header: pepatapi.pkh 120.2.12010000.2 2008/08/06 09:20:51 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_alloc_task_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alloc_task_b
  (p_effective_date                in     date
  ,p_allocated_checklist_id        in     number
  ,p_task_name                     in     varchar2
  ,p_description                   in     varchar2
  ,p_performer_orig_system         in     varchar2
  ,p_performer_orig_sys_id         in     number
  ,p_task_owner_person_id          in     number
  ,p_task_sequence                 in     number
  ,p_target_start_date             in     date
  ,p_target_end_date               in     date
  ,p_actual_start_date             in     date
  ,p_actual_end_date               in     date
  ,p_action_url                    in     varchar2
  ,p_mandatory_flag                in     varchar2
  ,p_status                        in     varchar2
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
  ,p_allocated_task_id             in number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_alloc_task_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alloc_task_a
  (p_effective_date                in     date
  ,p_allocated_checklist_id        in     number
  ,p_task_name                     in     varchar2
  ,p_description                   in     varchar2
  ,p_performer_orig_system         in     varchar2
  ,p_performer_orig_sys_id         in     number
  ,p_task_owner_person_id          in     number
  ,p_task_sequence                 in     number
  ,p_target_start_date             in     date
  ,p_target_end_date               in     date
  ,p_actual_start_date             in     date
  ,p_actual_end_date               in     date
--
  ,p_action_url                    in     varchar2
  ,p_mandatory_flag                in     varchar2
  ,p_status                        in     varchar2
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
  ,p_allocated_task_id             in number
  ,p_object_version_number         in     number
  );
--
end PER_ALLOCATED_TASK_BK2;

/
