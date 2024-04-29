--------------------------------------------------------
--  DDL for Package Body HR_PERSON_DEPLOYMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_DEPLOYMENT_SWI" As
/* $Header: hrpdtswi.pkb 120.0 2005/09/23 06:45 adhunter noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_person_deployment_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_person_deployment >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_person_deployment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_from_business_group_id       in     number
  ,p_to_business_group_id         in     number
  ,p_from_person_id               in     number
  ,p_to_person_id                 in     number    default null
  ,p_person_type_id               in     number    default null
  ,p_start_date                   in     date
  ,p_end_date                     in     date      default null
  ,p_employee_number              in     varchar2  default null
  ,p_leaving_reason               in     varchar2  default null
  ,p_leaving_person_type_id       in     number    default null
  ,p_permanent                    in     varchar2  default null
  ,p_deplymt_policy_id            in     number    default null
  ,p_organization_id              in     number
  ,p_location_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_position_id                  in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_supervisor_assignment_id     in     number    default null
  ,p_retain_direct_reports        in     varchar2  default null
  ,p_payroll_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_proposed_salary              in     varchar2  default null
  ,p_people_group_id              in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
  ,p_assignment_status_type_id    in     number    default null
  ,p_ass_status_change_reason     in     varchar2  default null
  ,p_assignment_category          in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_deployment_reason            in     varchar2  default null
  ,p_person_deployment_id         in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_policy_duration_warning       boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_person_deployment_id         number;
  l_proc    varchar2(72) := g_package ||'create_person_deployment';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_person_deployment_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  hr_pdt_ins.set_base_key_value
    (p_person_deployment_id => p_person_deployment_id
    );
  --
  -- Call API
  --
  hr_person_deployment_api.create_person_deployment
    (p_validate                     => l_validate
    ,p_from_business_group_id       => p_from_business_group_id
    ,p_to_business_group_id         => p_to_business_group_id
    ,p_from_person_id               => p_from_person_id
    ,p_to_person_id                 => p_to_person_id
    ,p_person_type_id               => p_person_type_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_deployment_reason            => p_deployment_reason
    ,p_employee_number              => p_employee_number
    ,p_leaving_reason               => p_leaving_reason
    ,p_leaving_person_type_id       => p_leaving_person_type_id
    ,p_permanent                    => p_permanent
    ,p_deplymt_policy_id            => p_deplymt_policy_id
    ,p_organization_id              => p_organization_id
    ,p_location_id                  => p_location_id
    ,p_job_id                       => p_job_id
    ,p_position_id                  => p_position_id
    ,p_grade_id                     => p_grade_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    ,p_retain_direct_reports        => p_retain_direct_reports
    ,p_payroll_id                   => p_payroll_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_proposed_salary              => p_proposed_salary
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_ass_status_change_reason     => p_ass_status_change_reason
    ,p_assignment_category          => p_assignment_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
    ,p_person_deployment_id         => l_person_deployment_id
    ,p_object_version_number        => p_object_version_number
    ,p_policy_duration_warning      => l_policy_duration_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
/*
NOT IN USE FOR INITIAL RELEASE
  if l_policy_duration_warning then
     fnd_message.set_name('EDIT HERE: APP_CODE', 'EDIT_HERE: MESSAGE_NAME ');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
*/
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_person_deployment_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_person_deployment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_person_deployment;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_person_deployment >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_person_deployment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_deployment_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_employee_number              in     varchar2  default hr_api.g_varchar2
  ,p_leaving_reason               in     varchar2  default hr_api.g_varchar2
  ,p_leaving_person_type_id       in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_status_change_reason         in     varchar2  default hr_api.g_varchar2
  ,p_deplymt_policy_id            in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_supervisor_assignment_id     in     number    default hr_api.g_number
  ,p_retain_direct_reports        in     varchar2  default hr_api.g_varchar2
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_pay_basis_id                 in     number    default hr_api.g_number
  ,p_proposed_salary              in     varchar2  default hr_api.g_varchar2
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_ass_status_change_reason     in     varchar2  default hr_api.g_varchar2
  ,p_assignment_category          in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ,p_deployment_reason            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_policy_duration_warning       boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_person_deployment';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_person_deployment_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_person_deployment_api.update_person_deployment
    (p_validate                     => l_validate
    ,p_person_deployment_id         => p_person_deployment_id
    ,p_object_version_number        => p_object_version_number
    ,p_person_type_id               => p_person_type_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_deployment_reason            => p_deployment_reason
    ,p_employee_number              => p_employee_number
    ,p_leaving_reason               => p_leaving_reason
    ,p_leaving_person_type_id       => p_leaving_person_type_id
    ,p_status                       => p_status
    ,p_status_change_reason         => p_status_change_reason
    ,p_deplymt_policy_id            => p_deplymt_policy_id
    ,p_organization_id              => p_organization_id
    ,p_location_id                  => p_location_id
    ,p_job_id                       => p_job_id
    ,p_position_id                  => p_position_id
    ,p_grade_id                     => p_grade_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    ,p_retain_direct_reports        => p_retain_direct_reports
    ,p_payroll_id                   => p_payroll_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_proposed_salary              => p_proposed_salary
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_ass_status_change_reason     => p_ass_status_change_reason
    ,p_assignment_category          => p_assignment_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
    ,p_policy_duration_warning      => l_policy_duration_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
/*
NOT IN USE FOR INITIAL RELEASE
  if l_policy_duration_warning then
     fnd_message.set_name('EDIT HERE: APP_CODE', 'EDIT_HERE: MESSAGE_NAME ');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
*/
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_person_deployment_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_person_deployment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_person_deployment;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_person_deployment >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_person_deployment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_deployment_id         in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_person_deployment';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_person_deployment_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_person_deployment_api.delete_person_deployment
    (p_validate                     => l_validate
    ,p_person_deployment_id         => p_person_deployment_id
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_person_deployment_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_person_deployment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_person_deployment;
-- ----------------------------------------------------------------------------
-- |-----------------------< initiate_deployment >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE initiate_deployment
  (p_validate                      in     number   default hr_api.g_false_num
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_host_person_id                   out nocopy number
  ,p_host_per_ovn                     out nocopy number
  ,p_host_assignment_id               out nocopy number
  ,p_host_asg_ovn                     out nocopy number
  ,p_return_status                    out nocopy varchar2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_already_applicant_warning     boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'initiate_deployment';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint initiate_deployment_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_person_deployment_api.initiate_deployment
     (p_validate                      => l_validate
     ,p_person_deployment_id          => p_person_deployment_id
     ,p_object_version_number         => p_object_version_number
     ,p_host_person_id                => p_host_person_id
     ,p_host_per_ovn                  => p_host_per_ovn
     ,p_host_assignment_id            => p_host_assignment_id
     ,p_host_asg_ovn                  => p_host_asg_ovn
     ,p_already_applicant_warning     => l_already_applicant_warning
     );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_already_applicant_warning then
     fnd_message.set_name('PER','HR_449649_DPL_NO_INIT_APL');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to initiate_deployment_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number         := l_object_version_number;
    p_host_person_id                := null;
    p_host_per_ovn                  := null;
    p_host_assignment_id            := null;
    p_host_asg_ovn                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to initiate_deployment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number         := l_object_version_number;
    p_host_person_id                := null;
    p_host_per_ovn                  := null;
    p_host_assignment_id            := null;
    p_host_asg_ovn                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end initiate_deployment;
-- ----------------------------------------------------------------------------
-- |-----------------------< change_deployment_dates >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE change_deployment_dates
  (p_validate                      in     number     default hr_api.g_false_num
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy     number
  ,p_start_date                    in     date       default hr_api.g_date
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_deplymt_policy_id             in     number     default hr_api.g_number
  ,p_return_status                    out nocopy varchar2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number number;
  --
  -- Other variables
  --
  l_proc    varchar2(72) := g_package ||'change_deployment_dates';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint change_deployment_dates_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_person_deployment_api.change_deployment_dates
    (p_validate                      => l_validate
    ,p_person_deployment_id          => p_person_deployment_id
    ,p_object_version_number         => p_object_version_number
    ,p_start_date                    => p_start_date
    ,p_end_date                      => p_end_date
    ,p_deplymt_policy_id             => p_deplymt_policy_id
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to change_deployment_dates_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to change_deployment_dates_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end change_deployment_dates;
-- ----------------------------------------------------------------------------
-- |-----------------------< return_from_deployment >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE return_from_deployment
  (p_validate                      in     number     default hr_api.g_false_num
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy     number
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_leaving_reason                in     varchar2   default hr_api.g_varchar2
  ,p_leaving_person_type_id        in     number     default hr_api.g_number
  ,p_return_status                    out nocopy varchar2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  l_object_version_number number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'change_deployment_dates';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint return_from_deployment_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_person_deployment_api.return_from_deployment
    (p_validate                      => l_validate
    ,p_person_deployment_id          => p_person_deployment_id
    ,p_object_version_number         => p_object_version_number
    ,p_end_date                      => p_end_date
    ,p_leaving_reason                => p_leaving_reason
    ,p_leaving_person_type_id        => p_leaving_person_type_id
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to return_from_deployment_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to return_from_deployment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end return_from_deployment;

end hr_person_deployment_swi;

/
