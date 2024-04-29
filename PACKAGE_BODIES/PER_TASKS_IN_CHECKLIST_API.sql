--------------------------------------------------------
--  DDL for Package Body PER_TASKS_IN_CHECKLIST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_TASKS_IN_CHECKLIST_API" as
/* $Header: pectkapi.pkb 120.1 2005/10/14 12:00:10 tpapired noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PER_TASKS_IN_CHECKLIST_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_TASK_IN_CKL >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_task_in_ckl
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_checklist_id                  in     number
  ,p_checklist_task_name           in     varchar2
  ,p_eligibility_object_id         in     number default null
  ,p_eligibility_profile_id        in     number default null
  ,p_ame_attribute_identifier      in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_task_sequence                 in     number default null
  ,p_mandatory                     in     varchar2 default null
  ,p_target_duration               in     number   default null
  ,p_target_duration_uom           in     varchar2 default null
  ,p_action_url                    in     varchar2 default null

  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_task_in_checklist_id             out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter          number;
  l_effective_date            date;
  l_object_version_number     number(9);
  l_task_in_checklist_id      number(9);
  l_proc                varchar2(72) := g_package||'Create_task_in_ckl';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_TASK_IN_CKL;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --


  begin
    PER_TASKS_IN_CHECKLIST_BK1.create_task_in_ckl_b
     (p_effective_date                => l_effective_date
     ,p_checklist_id                  => p_checklist_id
     ,p_checklist_task_name           => p_checklist_task_name
     ,p_eligibility_object_id         => p_eligibility_object_id
     ,p_eligibility_profile_id        => p_eligibility_profile_id
     ,p_ame_attribute_identifier      => p_ame_attribute_identifier

     ,p_description                   => p_description
     ,p_task_sequence                 => p_task_sequence
     ,p_mandatory                     => p_mandatory
     ,p_target_duration               => p_target_duration
     ,p_target_duration_uom           => p_target_duration_uom
     ,p_action_url                    => p_action_url
     ,p_attribute_category            => p_attribute_category
     ,p_attribute1                    => p_attribute1
     ,p_attribute2                    => p_attribute2
     ,p_attribute3                    => p_attribute3
     ,p_attribute4                    => p_attribute4
     ,p_attribute5                    => p_attribute5
     ,p_attribute6                    => p_attribute6
     ,p_attribute7                    => p_attribute7
     ,p_attribute8                    => p_attribute8
     ,p_attribute9                    => p_attribute9
     ,p_attribute10                   => p_attribute10
     ,p_attribute11                   => p_attribute11
     ,p_attribute12                   => p_attribute12
     ,p_attribute13                   => p_attribute13
     ,p_attribute14                   => p_attribute14
     ,p_attribute15                   => p_attribute15
     ,p_attribute16                   => p_attribute16
     ,p_attribute17                   => p_attribute17
     ,p_attribute18                   => p_attribute18
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20
     ,p_information_category          => p_information_category
     ,p_information1                  => p_information1
     ,p_information2                  => p_information2
     ,p_information3                  => p_information3
     ,p_information4                  => p_information4
     ,p_information5                  => p_information5
     ,p_information6                  => p_information6
     ,p_information7                  => p_information7
     ,p_information8                  => p_information8
     ,p_information9                  => p_information9
     ,p_information10                 => p_information10
     ,p_information11                 => p_information11
     ,p_information12                 => p_information12
     ,p_information13                 => p_information13
     ,p_information14                 => p_information14
     ,p_information15                 => p_information15
     ,p_information16                 => p_information16
     ,p_information17                 => p_information17
     ,p_information18                 => p_information18
     ,p_information19                 => p_information19
     ,p_information20                 => p_information20
     );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TASK_IN_CKL'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  per_ctk_ins.ins
     (p_effective_date                => l_effective_date
     ,p_checklist_id                  => p_checklist_id
     ,p_checklist_task_name           => p_checklist_task_name
     ,p_eligibility_object_id         => p_eligibility_object_id
     ,p_eligibility_profile_id        => p_eligibility_profile_id
     ,p_ame_attribute_identifier      => p_ame_attribute_identifier
     ,p_description                   => p_description
     ,p_task_sequence                 => p_task_sequence
     ,p_mandatory_flag                => p_mandatory
     ,p_target_duration               => p_target_duration
     ,p_target_duration_uom           => p_target_duration_uom
     ,p_action_url                    => p_action_url
     ,p_attribute_category            => p_attribute_category
     ,p_attribute1                    => p_attribute1
     ,p_attribute2                    => p_attribute2
     ,p_attribute3                    => p_attribute3
     ,p_attribute4                    => p_attribute4
     ,p_attribute5                    => p_attribute5
     ,p_attribute6                    => p_attribute6
     ,p_attribute7                    => p_attribute7
     ,p_attribute8                    => p_attribute8
     ,p_attribute9                    => p_attribute9
     ,p_attribute10                   => p_attribute10
     ,p_attribute11                   => p_attribute11
     ,p_attribute12                   => p_attribute12
     ,p_attribute13                   => p_attribute13
     ,p_attribute14                   => p_attribute14
     ,p_attribute15                   => p_attribute15
     ,p_attribute16                   => p_attribute16
     ,p_attribute17                   => p_attribute17
     ,p_attribute18                   => p_attribute18
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20
     ,p_information_category          => p_information_category
     ,p_information1                  => p_information1
     ,p_information2                  => p_information2
     ,p_information3                  => p_information3
     ,p_information4                  => p_information4
     ,p_information5                  => p_information5
     ,p_information6                  => p_information6
     ,p_information7                  => p_information7
     ,p_information8                  => p_information8
     ,p_information9                  => p_information9
     ,p_information10                 => p_information10
     ,p_information11                 => p_information11
     ,p_information12                 => p_information12
     ,p_information13                 => p_information13
     ,p_information14                 => p_information14
     ,p_information15                 => p_information15
     ,p_information16                 => p_information16
     ,p_information17                 => p_information17
     ,p_information18                 => p_information18
     ,p_information19                 => p_information19
     ,p_information20                 => p_information20
     ,p_task_in_checklist_id          => l_task_in_checklist_id
     ,p_object_version_number         => l_object_version_number
     );


  --
  -- Call After Process User Hook
  --
  begin
    PER_TASKS_IN_CHECKLIST_BK1.CREATE_TASK_IN_CKL_A
     (p_effective_date                => l_effective_date
     ,p_checklist_id                  => p_checklist_id
     ,p_checklist_task_name           => p_checklist_task_name
     ,p_eligibility_object_id         => p_eligibility_object_id
     ,p_eligibility_profile_id        => p_eligibility_profile_id
     ,p_ame_attribute_identifier      => p_ame_attribute_identifier
     ,p_description                   => p_description
     ,p_task_sequence                 => p_task_sequence
     ,p_mandatory                     => p_mandatory
     ,p_target_duration               => p_target_duration
     ,p_target_duration_uom           => p_target_duration_uom
     ,p_action_url                    => p_action_url
     ,p_attribute_category            => p_attribute_category
     ,p_attribute1                    => p_attribute1
     ,p_attribute2                    => p_attribute2
     ,p_attribute3                    => p_attribute3
     ,p_attribute4                    => p_attribute4
     ,p_attribute5                    => p_attribute5
     ,p_attribute6                    => p_attribute6
     ,p_attribute7                    => p_attribute7
     ,p_attribute8                    => p_attribute8
     ,p_attribute9                    => p_attribute9
     ,p_attribute10                   => p_attribute10
     ,p_attribute11                   => p_attribute11
     ,p_attribute12                   => p_attribute12
     ,p_attribute13                   => p_attribute13
     ,p_attribute14                   => p_attribute14
     ,p_attribute15                   => p_attribute15
     ,p_attribute16                   => p_attribute16
     ,p_attribute17                   => p_attribute17
     ,p_attribute18                   => p_attribute18
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20
     ,p_information_category          => p_information_category
     ,p_information1                  => p_information1
     ,p_information2                  => p_information2
     ,p_information3                  => p_information3
     ,p_information4                  => p_information4
     ,p_information5                  => p_information5
     ,p_information6                  => p_information6
     ,p_information7                  => p_information7
     ,p_information8                  => p_information8
     ,p_information9                  => p_information9
     ,p_information10                 => p_information10
     ,p_information11                 => p_information11
     ,p_information12                 => p_information12
     ,p_information13                 => p_information13
     ,p_information14                 => p_information14
     ,p_information15                 => p_information15
     ,p_information16                 => p_information16
     ,p_information17                 => p_information17
     ,p_information18                 => p_information18
     ,p_information19                 => p_information19
     ,p_information20                 => p_information20
     ,p_task_in_checklist_id          => p_task_in_checklist_id
     ,p_object_version_number         => l_object_version_number

     );


/*
=======
      (p_effective_date                => l_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_in_out_parameter              => <local_var_set_in_process_logic>
      ,p_non_mandatory_arg             => p_non_mandatory_arg
      ,p_id                            => <local_var_set_in_process_logic>
      ,p_object_version_number         => <local_var_set_in_process_logic>
      ,p_some_warning                  => <local_var_set_in_process_logic>
      );
*/
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TASK_IN_CKL'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_task_in_checklist_id   := l_task_in_checklist_id;
  --p_in_out_parameter       := <local_var_set_in_process_logic>;
  p_object_version_number  := l_object_version_number;
  --p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_TASK_IN_CKL;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --p_in_out_parameter       := l_in_out_parameter;
    p_task_in_checklist_id        := null;
    p_object_version_number  := null;
    --p_some_warning           := <local_var_set_in_process_logic>;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_TASK_IN_CKL;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    --p_in_out_parameter       := l_in_out_parameter;
    p_task_in_checklist_id     := null;
    p_object_version_number    := null;
    --p_some_warning           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_TASK_IN_CKL;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_TASK_IN_CKL >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_TASK_IN_CKL
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_task_in_checklist_id          in     number
  ,p_checklist_id                  in     number
  ,p_checklist_task_name           in     varchar2
  ,p_eligibility_object_id         in     number default null
  ,p_eligibility_profile_id        in     number default null
  ,p_ame_attribute_identifier      in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_task_sequence                 in     number default null
  ,p_mandatory                     in     varchar2 default null
  ,p_target_duration               in     number   default null
  ,p_target_duration_uom           in     varchar2 default null
  ,p_action_url                    in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_object_version_number         in out nocopy   number
  ) is

  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'update_task_in_ckl';
  l_effective_date            date;
  l_object_version_number     number;
  l_temp_ovn                  number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_TASK_IN_CKL;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date            := TRUNC(p_effective_date);
  l_object_version_number     := p_object_version_number;
  l_temp_ovn                  := p_object_version_number;
/* This needs to be removed, after confirming this is not needed TP
--
--
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
*/
  --
  -- Call Before Process User Hook
  --
  begin
    PER_TASKS_IN_CHECKLIST_BK2.UPDATE_TASK_IN_CKL_B
     (p_effective_date                => l_effective_date
     ,p_task_in_checklist_id          => p_task_in_checklist_id
--
     ,p_checklist_id                  => p_checklist_id
     ,p_checklist_task_name           => p_checklist_task_name
     ,p_eligibility_object_id         => p_eligibility_object_id
     ,p_eligibility_profile_id        => p_eligibility_profile_id
     ,p_ame_attribute_identifier      => p_ame_attribute_identifier
     ,p_description                   => p_description
     ,p_task_sequence                 => p_task_sequence
     ,p_mandatory                     => p_mandatory
     ,p_target_duration               => p_target_duration
     ,p_target_duration_uom           => p_target_duration_uom
     ,p_action_url                    => p_action_url
--
     ,p_attribute_category            => p_attribute_category
     ,p_attribute1                    => p_attribute1
     ,p_attribute2                    => p_attribute2
     ,p_attribute3                    => p_attribute3
     ,p_attribute4                    => p_attribute4
     ,p_attribute5                    => p_attribute5
     ,p_attribute6                    => p_attribute6
     ,p_attribute7                    => p_attribute7
     ,p_attribute8                    => p_attribute8
     ,p_attribute9                    => p_attribute9
     ,p_attribute10                   => p_attribute10
     ,p_attribute11                   => p_attribute11
     ,p_attribute12                   => p_attribute12
     ,p_attribute13                   => p_attribute13
     ,p_attribute14                   => p_attribute14
     ,p_attribute15                   => p_attribute15
     ,p_attribute16                   => p_attribute16
     ,p_attribute17                   => p_attribute17
     ,p_attribute18                   => p_attribute18
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20
     ,p_information_category          => p_information_category
     ,p_information1                  => p_information1
     ,p_information2                  => p_information2
     ,p_information3                  => p_information3
     ,p_information4                  => p_information4
     ,p_information5                  => p_information5
     ,p_information6                  => p_information6
     ,p_information7                  => p_information7
     ,p_information8                  => p_information8
     ,p_information9                  => p_information9
     ,p_information10                 => p_information10
     ,p_information11                 => p_information11
     ,p_information12                 => p_information12
     ,p_information13                 => p_information13
     ,p_information14                 => p_information14
     ,p_information15                 => p_information15
     ,p_information16                 => p_information16
     ,p_information17                 => p_information17
     ,p_information18                 => p_information18
     ,p_information19                 => p_information19
     ,p_information20                 => p_information20
     ,p_object_version_number         => l_object_version_number
     );
     --
     exception
       when hr_Api.cannot_find_prog_unit then
         hr_Api.cannot_find_prog_unit_error
           (p_module_name => 'UPDATE_TASK_IN_CKL'
           ,p_hook_type   => 'BP'
           );
     end;

  --
  -- Process Logic
  --

  per_ctk_upd.upd
    (p_effective_date               => l_effective_date
    ,p_task_in_checklist_id          => p_task_in_checklist_id
    ,p_object_version_number        => l_object_version_number
     ,p_checklist_id                  => p_checklist_id
     ,p_checklist_task_name           => p_checklist_task_name
     ,p_eligibility_object_id         => p_eligibility_object_id
     ,p_eligibility_profile_id        => p_eligibility_profile_id
     ,p_ame_attribute_identifier      => p_ame_attribute_identifier

     ,p_description                   => p_description
     ,p_task_sequence                 => p_task_sequence
     ,p_mandatory_flag                => p_mandatory
     ,p_target_duration               => p_target_duration
     ,p_target_duration_uom           => p_target_duration_uom
     ,p_action_url                    => p_action_url
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
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    );

  --
  -- Call After Process User Hook
  --
  begin
  PER_TASKS_IN_CHECKLIST_BK2.UPDATE_TASK_IN_CKL_A
    (p_effective_date                => l_effective_date
    ,p_task_in_checklist_id          => p_task_in_checklist_id
--
     ,p_checklist_id                  => p_checklist_id
     ,p_checklist_task_name           => p_checklist_task_name
     ,p_eligibility_object_id         => p_eligibility_object_id
     ,p_eligibility_profile_id        => p_eligibility_profile_id
     ,p_ame_attribute_identifier      => p_ame_attribute_identifier
     ,p_description                   => p_description
     ,p_task_sequence                 => p_task_sequence
     ,p_mandatory                     => p_mandatory
     ,p_target_duration               => p_target_duration
     ,p_target_duration_uom           => p_target_duration_uom
     ,p_action_url                    => p_action_url
--
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_object_version_number         => l_object_version_number);
    exception
      when hr_Api.cannot_find_prog_unit then
        hr_Api.cannot_find_prog_unit_error
          (p_module_name => 'UPDATE_TASK_IN_CKL'
          ,p_hook_type   => 'AP'
          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_Api.validate_enabled;
    end if;
    --
    -- Set all output arguements
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_Api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_TASK_IN_CKL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number    := l_temp_ovn;
    rollback to UPDATE_TASK_IN_CKL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end UPDATE_TASK_IN_CKL;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<DELETE_TASK_IN_CKL>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_TASK_IN_CKL
  (p_validate                      in     boolean  default false
  ,p_task_in_checklist_id          in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'delete_task_in_ckl';
  l_object_version_number     number(9) := p_object_version_number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_TASK_IN_CKL;
  --
  -- Call Before Process User Hook
  --
  begin
    PER_TASKS_IN_CHECKLIST_BK3.DELETE_TASK_IN_CKL_B
      (p_task_in_checklist_id          => p_task_in_checklist_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_Api.cannot_find_prog_unit then
      hr_Api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TASK_IN_CKL'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  per_ctk_del.del
    (p_task_in_checklist_id               => p_task_in_checklist_id
    ,p_object_version_number              => p_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin
    PER_TASKS_IN_CHECKLIST_BK3.DELETE_TASK_IN_CKL_A
      (p_task_in_checklist_id          => p_task_in_checklist_id
      ,p_object_version_number         => p_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_Api.cannot_find_prog_unit_error
          (p_module_name => 'DELETE_TASK_IN_CKL'
          ,p_hook_type   => 'AP'
          );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_Api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_Api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_TASK_IN_CKL;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_TASK_IN_CKL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_TASK_IN_CKL;
--
end PER_TASKS_IN_CHECKLIST_API;

/
