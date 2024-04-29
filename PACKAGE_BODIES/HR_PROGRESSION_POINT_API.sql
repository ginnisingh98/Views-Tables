--------------------------------------------------------
--  DDL for Package Body HR_PROGRESSION_POINT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROGRESSION_POINT_API" as
/* $Header: pepspapi.pkb 115.1 2003/11/17 13:06:36 tpapired noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_progression_point.';
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_progression_point >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_progression_point
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date     default null
  ,p_business_group_id              in     number
  ,p_parent_spine_id                in     number
  ,p_sequence                       in     number
  ,p_spinal_point                   in     varchar2
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
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
  ,p_spinal_point_id                out nocopy number
  ,p_object_version_number          out nocopy number
 ) is

   --
   -- Declare cursors and local variables
   --
   l_proc                     varchar2(72) := g_package||'create_progression_point';
   l_effective_date           date;

   --
   -- Declare out parameters
   --
   l_spinal_point_id          per_spinal_points.spinal_point_id%TYPE;
   l_object_version_number    per_spinal_points.object_version_number%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_progression_point;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- Call Before Process User hook for create_progression_point
  --
  begin
  hr_progression_point_bk1.create_progression_point_b
    (p_business_group_id             => p_business_group_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_sequence                      => p_sequence
    ,p_spinal_point                  => p_spinal_point
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_effective_date		     => l_effective_date
    ,p_information_category            => p_information_category
    ,p_information1                    => p_information1
    ,p_information2                    => p_information2
    ,p_information3                    => p_information3
    ,p_information4                    => p_information4
    ,p_information5                    => p_information5
    ,p_information6                    => p_information6
    ,p_information7                    => p_information7
    ,p_information8                    => p_information8
    ,p_information9                    => p_information9
    ,p_information10                   => p_information10
    ,p_information11                   => p_information11
    ,p_information12                   => p_information12
    ,p_information13                   => p_information13
    ,p_information14                   => p_information14
    ,p_information15                   => p_information15
    ,p_information16                   => p_information16
    ,p_information17                   => p_information17
    ,p_information18                   => p_information18
    ,p_information19                   => p_information19
    ,p_information20                   => p_information20
    ,p_information21                   => p_information21
    ,p_information22                   => p_information22
    ,p_information23                   => p_information23
    ,p_information24                   => p_information24
    ,p_information25                   => p_information25
    ,p_information26                   => p_information26
    ,p_information27                   => p_information27
    ,p_information28                   => p_information28
    ,p_information29                   => p_information29
    ,p_information30                   => p_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PROGRESSION_POINT'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (create_progression_point)
  --
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --

  --
  -- Insert Progression Point
  --
  --
  per_psp_ins.ins
  (p_effective_date                => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_parent_spine_id               => p_parent_spine_id
  ,p_sequence                      => p_sequence
  ,p_spinal_point                  => p_spinal_point
  ,p_request_id	                   => p_request_id
  ,p_program_application_id        => p_program_application_id
  ,p_program_id                    => p_program_id
  ,p_program_update_date           => p_program_update_date
  ,p_spinal_point_id               => l_spinal_point_id
  ,p_object_version_number         => l_object_version_number
  ,p_information_category            => p_information_category
    ,p_information1                    => p_information1
    ,p_information2                    => p_information2
    ,p_information3                    => p_information3
    ,p_information4                    => p_information4
    ,p_information5                    => p_information5
    ,p_information6                    => p_information6
    ,p_information7                    => p_information7
    ,p_information8                    => p_information8
    ,p_information9                    => p_information9
    ,p_information10                   => p_information10
    ,p_information11                   => p_information11
    ,p_information12                   => p_information12
    ,p_information13                   => p_information13
    ,p_information14                   => p_information14
    ,p_information15                   => p_information15
    ,p_information16                   => p_information16
    ,p_information17                   => p_information17
    ,p_information18                   => p_information18
    ,p_information19                   => p_information19
    ,p_information20                   => p_information20
    ,p_information21                   => p_information21
    ,p_information22                   => p_information22
    ,p_information23                   => p_information23
    ,p_information24                   => p_information24
    ,p_information25                   => p_information25
    ,p_information26                   => p_information26
    ,p_information27                   => p_information27
    ,p_information28                   => p_information28
    ,p_information29                   => p_information29
    ,p_information30                   => p_information30
  );

  hr_utility.set_location(l_proc, 40);

  --
  --
  -- Call After Process hook for create_progression_point
  --

  begin
  hr_progression_point_bk1.create_progression_point_a
    (p_business_group_id             => p_business_group_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_sequence                      => p_sequence
    ,p_spinal_point                  => p_spinal_point
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_spinal_point_id               => l_spinal_point_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date		     => l_effective_date
    ,p_information_category            => p_information_category
    ,p_information1                    => p_information1
    ,p_information2                    => p_information2
    ,p_information3                    => p_information3
    ,p_information4                    => p_information4
    ,p_information5                    => p_information5
    ,p_information6                    => p_information6
    ,p_information7                    => p_information7
    ,p_information8                    => p_information8
    ,p_information9                    => p_information9
    ,p_information10                   => p_information10
    ,p_information11                   => p_information11
    ,p_information12                   => p_information12
    ,p_information13                   => p_information13
    ,p_information14                   => p_information14
    ,p_information15                   => p_information15
    ,p_information16                   => p_information16
    ,p_information17                   => p_information17
    ,p_information18                   => p_information18
    ,p_information19                   => p_information19
    ,p_information20                   => p_information20
    ,p_information21                   => p_information21
    ,p_information22                   => p_information22
    ,p_information23                   => p_information23
    ,p_information24                   => p_information24
    ,p_information25                   => p_information25
    ,p_information26                   => p_information26
    ,p_information27                   => p_information27
    ,p_information28                   => p_information28
    ,p_information29                   => p_information29
    ,p_information30                   => p_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PREGORESSION_POINT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (create_progression_point)
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
  p_spinal_point_id       := l_spinal_point_id;
  p_object_version_number := l_object_version_number;
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
     ROLLBACK TO create_progression_point;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_spinal_point_id           := null;
     p_object_version_number     := null;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     --
     --
     ROLLBACK TO create_progression_point;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     --
     raise;
     --
end create_progression_point;
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_progression_point >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_progression_point
  (p_validate                       in     boolean  default false
  ,p_spinal_point_id                in     number
  ,p_effective_date                 in     date     default hr_api.g_date
  ,p_business_group_id              in     number   default hr_api.g_number
  ,p_parent_spine_id                in     number   default hr_api.g_number
  ,p_sequence                       in     number   default hr_api.g_number
  ,p_spinal_point                   in     varchar2 default hr_api.g_varchar2
  ,p_request_id                     in     number   default hr_api.g_number
  ,p_program_application_id         in     number   default hr_api.g_number
  ,p_program_id                     in     number   default hr_api.g_number
  ,p_program_update_date            in     date     default hr_api.g_date
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
  ,p_object_version_number          in out nocopy number
  ) is

   --
   -- Declare cursors and local variables
   --
   l_proc                     varchar2(72) := g_package||'update_progression_point';
   l_effective_date           date;
   lv_object_version_number   per_spinal_points.object_version_number%TYPE;

   --
   -- Declare out parameters
   --
   l_object_version_number    per_spinal_points.object_version_number%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint update_progression_point;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- Call Before Process User hook for create_progression_point
  --
  begin
  hr_progression_point_bk2.update_progression_point_b
    (p_business_group_id             => p_business_group_id
    ,p_spinal_point_id               => p_spinal_point_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_sequence                      => p_sequence
    ,p_spinal_point                  => p_spinal_point
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => p_object_version_number
    ,p_effective_date		     => l_effective_date
    ,p_information_category            => p_information_category
    ,p_information1                    => p_information1
    ,p_information2                    => p_information2
    ,p_information3                    => p_information3
    ,p_information4                    => p_information4
    ,p_information5                    => p_information5
    ,p_information6                    => p_information6
    ,p_information7                    => p_information7
    ,p_information8                    => p_information8
    ,p_information9                    => p_information9
    ,p_information10                   => p_information10
    ,p_information11                   => p_information11
    ,p_information12                   => p_information12
    ,p_information13                   => p_information13
    ,p_information14                   => p_information14
    ,p_information15                   => p_information15
    ,p_information16                   => p_information16
    ,p_information17                   => p_information17
    ,p_information18                   => p_information18
    ,p_information19                   => p_information19
    ,p_information20                   => p_information20
    ,p_information21                   => p_information21
    ,p_information22                   => p_information22
    ,p_information23                   => p_information23
    ,p_information24                   => p_information24
    ,p_information25                   => p_information25
    ,p_information26                   => p_information26
    ,p_information27                   => p_information27
    ,p_information28                   => p_information28
    ,p_information29                   => p_information29
    ,p_information30                   => p_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PROGRESSION_POINT'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (update_progression_point)
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
  per_psp_upd.upd
  (p_business_group_id             => p_business_group_id
  ,p_spinal_point_id               => p_spinal_point_id
  ,p_parent_spine_id               => p_parent_spine_id
  ,p_sequence                      => p_sequence
  ,p_spinal_point                  => p_spinal_point
  ,p_request_id	                   => p_request_id
  ,p_program_application_id        => p_program_application_id
  ,p_program_id                    => p_program_id
  ,p_program_update_date           => p_program_update_date
  ,p_object_version_number         => l_object_version_number
  ,p_effective_date	           => l_effective_date
  ,p_information_category            => p_information_category
    ,p_information1                    => p_information1
    ,p_information2                    => p_information2
    ,p_information3                    => p_information3
    ,p_information4                    => p_information4
    ,p_information5                    => p_information5
    ,p_information6                    => p_information6
    ,p_information7                    => p_information7
    ,p_information8                    => p_information8
    ,p_information9                    => p_information9
    ,p_information10                   => p_information10
    ,p_information11                   => p_information11
    ,p_information12                   => p_information12
    ,p_information13                   => p_information13
    ,p_information14                   => p_information14
    ,p_information15                   => p_information15
    ,p_information16                   => p_information16
    ,p_information17                   => p_information17
    ,p_information18                   => p_information18
    ,p_information19                   => p_information19
    ,p_information20                   => p_information20
    ,p_information21                   => p_information21
    ,p_information22                   => p_information22
    ,p_information23                   => p_information23
    ,p_information24                   => p_information24
    ,p_information25                   => p_information25
    ,p_information26                   => p_information26
    ,p_information27                   => p_information27
    ,p_information28                   => p_information28
    ,p_information29                   => p_information29
    ,p_information30                   => p_information30
  );

  --
  -- Assign the out parameters.
  --
  p_object_version_number     := l_object_version_number;

  hr_utility.set_location(l_proc, 40);

  --
  --
  -- Call After Process hook for create_grade
  --

  begin
  hr_progression_point_bk2.update_progression_point_a
    (p_business_group_id             => p_business_group_id
    ,p_spinal_point_id               => p_spinal_point_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_sequence                      => p_sequence
    ,p_spinal_point                  => p_spinal_point
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date	             => l_effective_date
    ,p_information_category            => p_information_category
    ,p_information1                    => p_information1
    ,p_information2                    => p_information2
    ,p_information3                    => p_information3
    ,p_information4                    => p_information4
    ,p_information5                    => p_information5
    ,p_information6                    => p_information6
    ,p_information7                    => p_information7
    ,p_information8                    => p_information8
    ,p_information9                    => p_information9
    ,p_information10                   => p_information10
    ,p_information11                   => p_information11
    ,p_information12                   => p_information12
    ,p_information13                   => p_information13
    ,p_information14                   => p_information14
    ,p_information15                   => p_information15
    ,p_information16                   => p_information16
    ,p_information17                   => p_information17
    ,p_information18                   => p_information18
    ,p_information19                   => p_information19
    ,p_information20                   => p_information20
    ,p_information21                   => p_information21
    ,p_information22                   => p_information22
    ,p_information23                   => p_information23
    ,p_information24                   => p_information24
    ,p_information25                   => p_information25
    ,p_information26                   => p_information26
    ,p_information27                   => p_information27
    ,p_information28                   => p_information28
    ,p_information29                   => p_information29
    ,p_information30                   => p_information30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PROGRESSION_POINT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (update_progression_point)
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
     rollback to update_progression_point;
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
     --
     --
     rollback to update_progression_point;
     --
     p_object_version_number     := lv_object_version_number;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     --
     raise;
     --
end update_progression_point;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_progression_point >---------------------------|
-- ----------------------------------------------------------------------------
--

procedure delete_progression_point
  (p_validate                      in     boolean
  ,p_spinal_point_id               in     number
  ,p_object_version_number         in     number
) IS

  --
  -- Declare cursors and local variables
  --
  l_proc       varchar2(72) := g_package||'delete_progression_point';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint delete_progression_point;

  --
  -- Call Before Process User Hook
  --
  begin
  hr_progression_point_bk3.delete_progression_point_b
    (p_validate                   =>  p_validate
    ,p_spinal_point_id            =>  p_spinal_point_id
    ,p_object_version_number      =>  p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROGRESSSION_POINT'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 20);

  --
  -- Process Logic
  --

  per_psp_del.del
  (p_spinal_point_id               => p_spinal_point_id
  ,p_object_version_number         => p_object_version_number);

  hr_utility.set_location(l_proc, 30);

  --
  -- Call After Process User Hook
  --
 begin
  hr_progression_point_bk3.delete_progression_point_a
    (p_validate                   =>  p_validate
    ,p_spinal_point_id            =>  p_spinal_point_id
    ,p_object_version_number      =>  p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROGRESSSION_POINT'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 40);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    hr_utility.set_location(' Leaving...:'||l_proc, 50);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_progression_point;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  when others then
    hr_utility.set_location(' Leaving...:'||l_proc, 60);
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_progression_point;
    raise;
--
end delete_progression_point;
--
end hr_progression_point_api;

/
