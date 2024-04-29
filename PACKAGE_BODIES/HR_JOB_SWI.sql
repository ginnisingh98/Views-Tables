--------------------------------------------------------
--  DDL for Package Body HR_JOB_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JOB_SWI" As
/* $Header: hrjobswi.pkb 115.6 2003/09/29 22:55:29 snukala noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_job_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_job >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_job
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number
  ,p_date_from                    in     date
  ,p_comments                     in     varchar2  default null
  ,p_date_to                      in     date      default null
  ,p_approval_authority           in     number    default null
  ,p_benchmark_job_flag           in     varchar2  default null
  ,p_benchmark_job_id             in     number    default null
  ,p_emp_rights_flag              in     varchar2  default null
  ,p_job_group_id                 in     number
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_job_information_category     in     varchar2  default null
  ,p_job_information1             in     varchar2  default null
  ,p_job_information2             in     varchar2  default null
  ,p_job_information3             in     varchar2  default null
  ,p_job_information4             in     varchar2  default null
  ,p_job_information5             in     varchar2  default null
  ,p_job_information6             in     varchar2  default null
  ,p_job_information7             in     varchar2  default null
  ,p_job_information8             in     varchar2  default null
  ,p_job_information9             in     varchar2  default null
  ,p_job_information10            in     varchar2  default null
  ,p_job_information11            in     varchar2  default null
  ,p_job_information12            in     varchar2  default null
  ,p_job_information13            in     varchar2  default null
  ,p_job_information14            in     varchar2  default null
  ,p_job_information15            in     varchar2  default null
  ,p_job_information16            in     varchar2  default null
  ,p_job_information17            in     varchar2  default null
  ,p_job_information18            in     varchar2  default null
  ,p_job_information19            in     varchar2  default null
  ,p_job_information20            in     varchar2  default null
  ,p_segment1                     in     varchar2  default null
  ,p_segment2                     in     varchar2  default null
  ,p_segment3                     in     varchar2  default null
  ,p_segment4                     in     varchar2  default null
  ,p_segment5                     in     varchar2  default null
  ,p_segment6                     in     varchar2  default null
  ,p_segment7                     in     varchar2  default null
  ,p_segment8                     in     varchar2  default null
  ,p_segment9                     in     varchar2  default null
  ,p_segment10                    in     varchar2  default null
  ,p_segment11                    in     varchar2  default null
  ,p_segment12                    in     varchar2  default null
  ,p_segment13                    in     varchar2  default null
  ,p_segment14                    in     varchar2  default null
  ,p_segment15                    in     varchar2  default null
  ,p_segment16                    in     varchar2  default null
  ,p_segment17                    in     varchar2  default null
  ,p_segment18                    in     varchar2  default null
  ,p_segment19                    in     varchar2  default null
  ,p_segment20                    in     varchar2  default null
  ,p_segment21                    in     varchar2  default null
  ,p_segment22                    in     varchar2  default null
  ,p_segment23                    in     varchar2  default null
  ,p_segment24                    in     varchar2  default null
  ,p_segment25                    in     varchar2  default null
  ,p_segment26                    in     varchar2  default null
  ,p_segment27                    in     varchar2  default null
  ,p_segment28                    in     varchar2  default null
  ,p_segment29                    in     varchar2  default null
  ,p_segment30                    in     varchar2  default null
  ,p_concat_segments              in     varchar2  default null
  ,p_job_id                          out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_job_definition_id               out nocopy number
  ,p_name                            out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_job';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_job_swi;
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
  hr_job_api.create_job
    (p_validate                     => l_validate
    ,p_business_group_id            => p_business_group_id
    ,p_date_from                    => p_date_from
    ,p_comments                     => p_comments
    ,p_date_to                      => p_date_to
    ,p_approval_authority           => p_approval_authority
    ,p_benchmark_job_flag           => p_benchmark_job_flag
    ,p_benchmark_job_id             => p_benchmark_job_id
    ,p_emp_rights_flag              => p_emp_rights_flag
    ,p_job_group_id                 => p_job_group_id
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_job_information_category     => p_job_information_category
    ,p_job_information1             => p_job_information1
    ,p_job_information2             => p_job_information2
    ,p_job_information3             => p_job_information3
    ,p_job_information4             => p_job_information4
    ,p_job_information5             => p_job_information5
    ,p_job_information6             => p_job_information6
    ,p_job_information7             => p_job_information7
    ,p_job_information8             => p_job_information8
    ,p_job_information9             => p_job_information9
    ,p_job_information10            => p_job_information10
    ,p_job_information11            => p_job_information11
    ,p_job_information12            => p_job_information12
    ,p_job_information13            => p_job_information13
    ,p_job_information14            => p_job_information14
    ,p_job_information15            => p_job_information15
    ,p_job_information16            => p_job_information16
    ,p_job_information17            => p_job_information17
    ,p_job_information18            => p_job_information18
    ,p_job_information19            => p_job_information19
    ,p_job_information20            => p_job_information20
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    ,p_concat_segments              => p_concat_segments
    ,p_job_id                       => p_job_id
    ,p_object_version_number        => p_object_version_number
    ,p_job_definition_id            => p_job_definition_id
    ,p_name                         => p_name
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
    rollback to create_job_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_job_id                       := null;
    p_object_version_number        := null;
    p_job_definition_id            := null;
    p_name                         := null;
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
    rollback to create_job_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_job_id                       := null;
    p_object_version_number        := null;
    p_job_definition_id            := null;
    p_name                         := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_job;
-- ----------------------------------------------------------------------------
-- |------------------------------< update_job >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_job
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_job_id                       in     number
  ,p_object_version_number        in out nocopy number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_benchmark_job_flag           in     varchar2  default hr_api.g_varchar2
  ,p_benchmark_job_id             in     number    default hr_api.g_number
  ,p_emp_rights_flag              in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_job_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_job_information1             in     varchar2  default hr_api.g_varchar2
  ,p_job_information2             in     varchar2  default hr_api.g_varchar2
  ,p_job_information3             in     varchar2  default hr_api.g_varchar2
  ,p_job_information4             in     varchar2  default hr_api.g_varchar2
  ,p_job_information5             in     varchar2  default hr_api.g_varchar2
  ,p_job_information6             in     varchar2  default hr_api.g_varchar2
  ,p_job_information7             in     varchar2  default hr_api.g_varchar2
  ,p_job_information8             in     varchar2  default hr_api.g_varchar2
  ,p_job_information9             in     varchar2  default hr_api.g_varchar2
  ,p_job_information10            in     varchar2  default hr_api.g_varchar2
  ,p_job_information11            in     varchar2  default hr_api.g_varchar2
  ,p_job_information12            in     varchar2  default hr_api.g_varchar2
  ,p_job_information13            in     varchar2  default hr_api.g_varchar2
  ,p_job_information14            in     varchar2  default hr_api.g_varchar2
  ,p_job_information15            in     varchar2  default hr_api.g_varchar2
  ,p_job_information16            in     varchar2  default hr_api.g_varchar2
  ,p_job_information17            in     varchar2  default hr_api.g_varchar2
  ,p_job_information18            in     varchar2  default hr_api.g_varchar2
  ,p_job_information19            in     varchar2  default hr_api.g_varchar2
  ,p_job_information20            in     varchar2  default hr_api.g_varchar2
  ,p_segment1                     in     varchar2  default hr_api.g_varchar2
  ,p_segment2                     in     varchar2  default hr_api.g_varchar2
  ,p_segment3                     in     varchar2  default hr_api.g_varchar2
  ,p_segment4                     in     varchar2  default hr_api.g_varchar2
  ,p_segment5                     in     varchar2  default hr_api.g_varchar2
  ,p_segment6                     in     varchar2  default hr_api.g_varchar2
  ,p_segment7                     in     varchar2  default hr_api.g_varchar2
  ,p_segment8                     in     varchar2  default hr_api.g_varchar2
  ,p_segment9                     in     varchar2  default hr_api.g_varchar2
  ,p_segment10                    in     varchar2  default hr_api.g_varchar2
  ,p_segment11                    in     varchar2  default hr_api.g_varchar2
  ,p_segment12                    in     varchar2  default hr_api.g_varchar2
  ,p_segment13                    in     varchar2  default hr_api.g_varchar2
  ,p_segment14                    in     varchar2  default hr_api.g_varchar2
  ,p_segment15                    in     varchar2  default hr_api.g_varchar2
  ,p_segment16                    in     varchar2  default hr_api.g_varchar2
  ,p_segment17                    in     varchar2  default hr_api.g_varchar2
  ,p_segment18                    in     varchar2  default hr_api.g_varchar2
  ,p_segment19                    in     varchar2  default hr_api.g_varchar2
  ,p_segment20                    in     varchar2  default hr_api.g_varchar2
  ,p_segment21                    in     varchar2  default hr_api.g_varchar2
  ,p_segment22                    in     varchar2  default hr_api.g_varchar2
  ,p_segment23                    in     varchar2  default hr_api.g_varchar2
  ,p_segment24                    in     varchar2  default hr_api.g_varchar2
  ,p_segment25                    in     varchar2  default hr_api.g_varchar2
  ,p_segment26                    in     varchar2  default hr_api.g_varchar2
  ,p_segment27                    in     varchar2  default hr_api.g_varchar2
  ,p_segment28                    in     varchar2  default hr_api.g_varchar2
  ,p_segment29                    in     varchar2  default hr_api.g_varchar2
  ,p_segment30                    in     varchar2  default hr_api.g_varchar2
  ,p_concat_segments              in     varchar2  default hr_api.g_varchar2
  ,p_approval_authority           in     number    default hr_api.g_number
  ,p_job_definition_id               out nocopy number
  ,p_name                            out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_effective_date		  in 	 date  --Aded for Bug# 1760707
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_valid_grades_changed_warning  boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_job';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_job_swi;
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
  hr_job_api.update_job
    (p_validate                     => l_validate
--
--   Removed param for Bug 3166670.
--  ,p_business_group_id            => p_business_group_id
--
    ,p_job_id                       => p_job_id
    ,p_object_version_number        => l_object_version_number
    ,p_date_from                    => p_date_from
    ,p_comments                     => p_comments
    ,p_date_to                      => p_date_to
    ,p_benchmark_job_flag           => p_benchmark_job_flag
    ,p_benchmark_job_id             => p_benchmark_job_id
    ,p_emp_rights_flag              => p_emp_rights_flag
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_job_information_category     => p_job_information_category
    ,p_job_information1             => p_job_information1
    ,p_job_information2             => p_job_information2
    ,p_job_information3             => p_job_information3
    ,p_job_information4             => p_job_information4
    ,p_job_information5             => p_job_information5
    ,p_job_information6             => p_job_information6
    ,p_job_information7             => p_job_information7
    ,p_job_information8             => p_job_information8
    ,p_job_information9             => p_job_information9
    ,p_job_information10            => p_job_information10
    ,p_job_information11            => p_job_information11
    ,p_job_information12            => p_job_information12
    ,p_job_information13            => p_job_information13
    ,p_job_information14            => p_job_information14
    ,p_job_information15            => p_job_information15
    ,p_job_information16            => p_job_information16
    ,p_job_information17            => p_job_information17
    ,p_job_information18            => p_job_information18
    ,p_job_information19            => p_job_information19
    ,p_job_information20            => p_job_information20
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    ,p_concat_segments              => p_concat_segments
    ,p_approval_authority           => p_approval_authority
    ,p_job_definition_id            => p_job_definition_id
    ,p_name                         => p_name
    ,p_valid_grades_changed_warning => l_valid_grades_changed_warning
    ,p_effective_date		    => p_effective_date
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_valid_grades_changed_warning then
     fnd_message.set_name('PER', 'HR_51092_VGR_JOB_GRD_COMBO');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
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
    rollback to update_job_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_job_definition_id            := null;
    p_name                         := null;
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
    rollback to update_job_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_job_definition_id            := null;
    p_name                         := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_job;
end hr_job_swi;

/
