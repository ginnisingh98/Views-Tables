--------------------------------------------------------
--  DDL for Package Body HR_GRADE_STEP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GRADE_STEP_API" as
/* $Header: pespsapi.pkb 120.1.12000000.1 2007/01/22 04:39:14 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_grade_step.';
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_grade_step >------------------------------|
-- ----------------------------------------------------------------------------
procedure create_grade_step
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_spinal_point_id               in     number
  ,p_grade_spine_id                in     number
  ,p_sequence                      in     number
  ,p_request_id                    in     number   default null
  ,p_program_application_id        in     number   default null
  ,p_program_id                    in     number   default null
  ,p_program_update_date           in     date     default null
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
  ,p_information21                 in     varchar2 default null
  ,p_information22                 in     varchar2 default null
  ,p_information23                 in     varchar2 default null
  ,p_information24                 in     varchar2 default null
  ,p_information25                 in     varchar2 default null
  ,p_information26                 in     varchar2 default null
  ,p_information27                 in     varchar2 default null
  ,p_information28                 in     varchar2 default null
  ,p_information29                 in     varchar2 default null
  ,p_information30                 in     varchar2 default null
  ,p_step_id                       in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
 ) is

   --
   -- Declare cursors and local variables
   --
   l_proc                     varchar2(72) := g_package||'create_grade_step';
   l_effective_date           date;

   --
   -- Declare out parameters
   --
   l_step_id                  per_spinal_point_steps_f.step_id%TYPE;
   l_object_version_number    per_spinal_point_steps_f.object_version_number%TYPE;
   l_effective_start_date     date;
   l_effective_end_date       date;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_step_id := p_step_id;

  --
  -- Issue a savepoint
  --
  savepoint create_grade_step;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- Call Before Process User hook for create_grade_step
  --
  begin
  hr_grade_step_bk1.create_grade_step_b
    (p_effective_date		     => l_effective_date
    ,p_business_group_id             => p_business_group_id
    ,p_spinal_point_id               => p_spinal_point_id
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_sequence                      => p_sequence
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
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
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GRADE_STEP'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (create_grade_step)
  --
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --

  --
  -- Insert Grade scale
  --
  --
  per_sps_ins.ins
    (p_effective_date                => l_effective_date
    ,p_business_group_id             => p_business_group_id
    ,p_spinal_point_id               => p_spinal_point_id
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_sequence                      => p_sequence
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
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
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_step_id                       => l_step_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    );

  hr_utility.set_location(l_proc, 40);

  --
  --
  -- Call After Process hook for create_grade_step
  --

  begin
  hr_grade_step_bk1.create_grade_step_a
    (p_effective_date                => l_effective_date
    ,p_business_group_id             => p_business_group_id
    ,p_spinal_point_id               => p_spinal_point_id
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_sequence                      => p_sequence
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
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
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_step_id                       => l_step_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GRADE_STEP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (create_grade_step)
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Set OUT parameters
  --
  p_step_id               := l_step_id;
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 60);
  --
  exception
  --
  when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO create_grade_step;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_step_id                   := null;
     p_object_version_number     := null;
     p_effective_start_date      := null;
     p_effective_end_date        := null;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     ROLLBACK TO create_grade_step;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     --
     p_step_id                   := null;
     p_object_version_number     := null;
     p_effective_start_date      := null;
     p_effective_end_date        := null;
     --
     raise;
     --
end create_grade_step;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_grade_step >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade_step
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date     default hr_api.g_date
  ,p_datetrack_mode                in     varchar2
  ,p_step_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_spinal_point_id               in     number   default hr_api.g_number
  ,p_grade_spine_id                in     number   default hr_api.g_number
  ,p_sequence                      in     number   default hr_api.g_number
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is

   --
   -- Declare cursors and local variables
   --
   l_proc                     varchar2(72) := g_package||'update_grade_step';
   l_effective_date           date;
   lv_object_version_number   per_spinal_point_steps_f.object_version_number%TYPE;

   --
   -- Declare out parameters
   --
   l_object_version_number    per_spinal_point_steps_f.object_version_number%TYPE;
   l_effective_start_date     per_spinal_point_steps_f.effective_start_date%TYPE;
   l_effective_end_date       per_spinal_point_steps_f.effective_end_date%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint update_grade_step;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- store object version number passed in
  --
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User hook for create_grade_step
  --
  begin
  hr_grade_step_bk2.update_grade_step_b
    (p_effective_date		     => l_effective_date
    ,p_step_id                       => p_step_id
    ,p_business_group_id             => p_business_group_id
    ,p_spinal_point_id               => p_spinal_point_id
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_sequence                      => p_sequence
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
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
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_object_version_number         => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GRADE_STEP'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (update_grade_step)
  --
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --

  l_object_version_number := p_object_version_number;

  --
  -- Update Progression Point
  --
  --
  per_sps_upd.upd
    (p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_step_id                       => p_step_id
    ,p_object_version_number         => l_object_version_number
    ,p_business_group_id             => p_business_group_id
    ,p_spinal_point_id               => p_spinal_point_id
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_sequence                      => p_sequence
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
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
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    );

  --
  -- Assign the out parameters.
  --
  p_object_version_number     := l_object_version_number;

  hr_utility.set_location(l_proc, 40);

  --
  --
  -- Call After Process hook for update_grade_step
  --

  begin
  hr_grade_step_bk2.update_grade_step_a
    (p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_step_id                       => p_step_id
    ,p_object_version_number         => l_object_version_number
    ,p_business_group_id             => p_business_group_id
    ,p_spinal_point_id               => p_spinal_point_id
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_sequence                      => p_sequence
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
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
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GRADE_STEP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (update_grade_step)
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Set OUT parameters
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 60);
  --
  exception
  --
  when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     rollback to update_grade_step;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_object_version_number     := p_object_version_number;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     rollback to update_grade_step;
     --
     p_object_version_number     := lv_object_version_number;
     p_effective_start_date      := null;
     p_effective_end_date        := null;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     --
     raise;
     --
end update_grade_step;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_grade_step >---------------------------|
-- ----------------------------------------------------------------------------
--

procedure delete_grade_step
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_step_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
) IS


 l_proc                varchar2(72) := g_package||'delete_grade_step';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  delete_grade_step
  (p_validate          => p_validate
  ,p_effective_date    => p_effective_date
  ,p_datetrack_mode    => p_datetrack_mode
  ,p_step_id           => p_step_id
  ,p_object_version_number => p_object_version_number
  ,p_effective_start_date => p_effective_start_date
  ,p_effective_end_date => p_effective_end_date
  ,p_called_from_del_grd_scale => FALSE
  );
    hr_utility.set_location('Leaving:'|| l_proc, 10);

end;
  --
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_grade_step >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_grade_step
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_step_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_called_from_del_grd_scale       in   boolean --bug 4096238
) IS

  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'delete_grade_step';
  l_effective_date         date;
  lv_object_version_number per_spinal_point_steps_f.object_version_number%TYPE;


  --
  -- Declare out variables
  --
  l_object_version_number    per_spinal_point_steps_f.object_version_number%TYPE;
  l_effective_start_date     per_spinal_point_steps_f.effective_start_date%TYPE;
  l_effective_end_date       per_spinal_point_steps_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_effective_date := trunc(p_effective_date);
  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint delete_grade_step;

  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
  hr_grade_step_bk3.delete_grade_step_b
    (p_effective_date             =>  l_effective_date
    ,p_datetrack_mode             =>  p_datetrack_mode
    ,p_step_id                    =>  p_step_id
    ,p_object_version_number      =>  l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GRADE_STEP'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 20);

  --
  -- Process Logic
  --

  per_sps_del.del
    (p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_step_id                       => p_step_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_called_from_del_grd_scale     => p_called_from_del_grd_scale -- BUG 4096238
    );

  hr_utility.set_location(l_proc, 30);

  --
  -- Call After Process User Hook
  --
 begin
  hr_grade_step_bk3.delete_grade_step_a
    (p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_step_id                       => p_step_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GRADE_STEP'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 40);

  p_object_version_number := l_object_version_number;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all output arguments (returned by some dt modes only)
  --
  p_object_version_number  := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    hr_utility.set_location(' Leaving...:'||l_proc, 50);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_grade_step;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    p_object_version_number := null;
    --
  when others then
    hr_utility.set_location(' Leaving...:'||l_proc, 60);
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_grade_step;
     --
    -- set in out parameters and set out parameters
    --
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    p_object_version_number := lv_object_version_number;
    --
    raise;
--
end delete_grade_step;
--
end hr_grade_step_api;

/
