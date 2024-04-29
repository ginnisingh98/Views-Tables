--------------------------------------------------------
--  DDL for Package Body HR_SP_PLACEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SP_PLACEMENT_API" as
/* $Header: pesppapi.pkb 120.2 2005/12/12 21:13:50 vbanner noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '   HR_SP_PLACEMENT_API .';
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_spinal_point_placement >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_spp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_step_id                       in     number
  ,p_auto_increment_flag           in     varchar2 default 'N'
  ,p_reason                        in     varchar2 default null
  ,p_request_id                    in     number default null
  ,p_program_application_id        in     number default null
  ,p_program_id                    in     number default null
  ,p_program_update_date           in     date default null
  ,p_increment_number              in     number default null
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
  ,p_information_category          in     varchar2 default null
  ,p_placement_id                     out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_replace_future_spp            in     boolean default false --Bug 2977842.
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date	   date;
  l_object_version_number  per_spinal_point_placements_f.object_version_number%TYPE;
  l_placement_id	   per_spinal_point_placements_f.placement_id%TYPE;
  l_effective_start_date   per_spinal_point_placements_f.effective_start_date%TYPE;
  l_effective_end_date     per_spinal_point_placements_f.effective_end_date%TYPE;
  l_gsp_post_process_warning varchar2(30);
  --
  l_proc                varchar2(72) := g_package||'create_spinal_point_placement';
  --
begin

  hr_utility.set_location('Entering:'|| l_proc, 12);

  hr_sp_placement_api.create_spp
  (p_validate                      => p_validate
  ,p_effective_date                => p_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_assignment_id                 => p_assignment_id
  ,p_step_id                       => p_step_id
  ,p_auto_increment_flag           => p_auto_increment_flag
  ,p_reason                        => p_reason
  ,p_request_id                    => p_request_id
  ,p_program_application_id        => p_program_application_id
  ,p_program_id                    => p_program_id
  ,p_program_update_date           => p_program_update_date
  ,p_increment_number              => p_increment_number
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
  ,p_information_category          => p_information_category
  ,p_placement_id                  => l_placement_id
  ,p_object_version_number         => l_object_version_number
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_replace_future_spp            => p_replace_future_spp --Bug 2977842.
  ,p_gsp_post_process_warning      => l_gsp_post_process_warning
  );
  --
  -- Set all output arguments
  --
  p_placement_id           := l_placement_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date	   := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end create_spp;
-- ----------------------------------------------------------------------------
-- |--------------------< create_spinal_point_placement OVERLOAD>-------------|
-- ----------------------------------------------------------------------------
--
procedure create_spp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_step_id                       in     number
  ,p_auto_increment_flag           in     varchar2 default 'N'
  ,p_reason                        in     varchar2 default null
  ,p_request_id                    in     number default null
  ,p_program_application_id        in     number default null
  ,p_program_id                    in     number default null
  ,p_program_update_date           in     date default null
  ,p_increment_number              in     number default null
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
  ,p_information_category          in     varchar2 default null
  ,p_placement_id                     out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_replace_future_spp            in     boolean default false --Bug 2977842.
  ,p_gsp_post_process_warning         out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date	   date;
  l_object_version_number  per_spinal_point_placements_f.object_version_number%TYPE;
  l_placement_id	   per_spinal_point_placements_f.placement_id%TYPE;
  l_effective_start_date   per_spinal_point_placements_f.effective_start_date%TYPE;
  l_effective_end_date     per_spinal_point_placements_f.effective_end_date%TYPE;
  l_gsp_post_process_warning  varchar2(30);
  --
  l_proc                varchar2(72) := g_package||'create_spinal_point_placement';
  --
begin

  hr_utility.set_location('Entering:'|| l_proc, 12);
  hr_utility.set_location('Entering:'|| p_auto_increment_flag, 15);
  --
  -- Issue a savepoint
  --
  savepoint create_spinal_point_placement;
  --
  -- Check that all not null parameters have a variable passed in
  --
  hr_utility.set_location('Entering mandatory arg check', 20);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'assignment_id',
     p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'business_group_id',
     p_argument_value => p_business_group_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'step_id',
     p_argument_value => p_step_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'auto_increment_flag',
     p_argument_value => p_auto_increment_flag);
  --
/*
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'parent_spine_id',
     p_argument_value => p_parent_spine_id);
*/
  --
  l_effective_date := trunc(p_effective_date);
  --
  hr_utility.set_location('Entering: call - create_spinal_point_placement_b ', 30);
  --

  begin

hr_sp_placement_api_bk1.create_sp_placement_b
  (p_effective_date                =>	l_effective_date
  ,p_business_group_id             =>	p_business_group_id
  ,p_assignment_id		   =>   p_assignment_id
  ,p_step_id			   =>   p_step_id
  ,p_auto_increment_flag	   =>   p_auto_increment_flag
  ,p_reason			   =>   p_reason
  ,p_request_id			   =>   p_request_id
  ,p_program_application_id	   =>   p_program_application_id
  ,p_program_id			   =>   p_program_id
  ,p_program_update_date	   =>   p_program_update_date
  ,p_increment_number		   =>   p_increment_number
  ,p_information1                  =>   p_information1
  ,p_information2                  =>   p_information2
  ,p_information3                  =>   p_information3
  ,p_information4                  =>   p_information4
  ,p_information5                  =>   p_information5
  ,p_information6                  =>   p_information6
  ,p_information7                  =>   p_information7
  ,p_information8                  =>   p_information8
  ,p_information9                  =>   p_information9
  ,p_information10                 =>   p_information10
  ,p_information11                 =>   p_information11
  ,p_information12                 =>   p_information12
  ,p_information13                 =>   p_information13
  ,p_information14                 =>   p_information14
  ,p_information15                 =>   p_information15
  ,p_information16                 =>   p_information16
  ,p_information17                 =>   p_information17
  ,p_information18                 =>   p_information18
  ,p_information19                 =>   p_information19
  ,p_information20                 =>   p_information20
  ,p_information21                 =>   p_information21
  ,p_information22                 =>   p_information22
  ,p_information23                 =>   p_information23
  ,p_information24                 =>   p_information24
  ,p_information25                 =>   p_information25
  ,p_information26                 =>   p_information26
  ,p_information27                 =>   p_information27
  ,p_information28                 =>   p_information28
  ,p_information29                 =>   p_information29
  ,p_information30                 =>   p_information30
  ,p_information_category          =>   p_information_category
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SPINAL_POINT_PLACEMENT'
        ,p_hook_type   => 'BP'
        );

  end;

  --
  hr_utility.set_location('Entering: call - per_spp_ins.ins ', 40);
  --
  per_spp_ins.ins
  (p_effective_date                =>   l_effective_date
  ,p_business_group_id             =>   p_business_group_id
  ,p_assignment_id		   =>   p_assignment_id
  ,p_step_id			   =>   p_step_id
  ,p_auto_increment_flag	   =>   p_auto_increment_flag
  ,p_reason 			   =>   p_reason
  ,p_request_id			   =>   p_request_id
  ,p_program_application_id	   =>   p_program_application_id
  ,p_program_id			   =>   p_program_id
  ,p_program_update_date	   =>   p_program_update_date
  ,p_increment_number		   =>   p_increment_number
  ,p_placement_id		   =>   l_placement_id
  ,p_object_version_number	   =>	l_object_version_number
  ,p_effective_start_date	   =>   l_effective_start_date
  ,p_effective_end_date		   =>   l_effective_end_date
  ,p_information1                  =>   p_information1
  ,p_information2                  =>   p_information2
  ,p_information3                  =>   p_information3
  ,p_information4                  =>   p_information4
  ,p_information5                  =>   p_information5
  ,p_information6                  =>   p_information6
  ,p_information7                  =>   p_information7
  ,p_information8                  =>   p_information8
  ,p_information9                  =>   p_information9
  ,p_information10                 =>   p_information10
  ,p_information11                 =>   p_information11
  ,p_information12                 =>   p_information12
  ,p_information13                 =>   p_information13
  ,p_information14                 =>   p_information14
  ,p_information15                 =>   p_information15
  ,p_information16                 =>   p_information16
  ,p_information17                 =>   p_information17
  ,p_information18                 =>   p_information18
  ,p_information19                 =>   p_information19
  ,p_information20                 =>   p_information20
  ,p_information21                 =>   p_information21
  ,p_information22                 =>   p_information22
  ,p_information23                 =>   p_information23
  ,p_information24                 =>   p_information24
  ,p_information25                 =>   p_information25
  ,p_information26                 =>   p_information26
  ,p_information27                 =>   p_information27
  ,p_information28                 =>   p_information28
  ,p_information29                 =>   p_information29
  ,p_information30                 =>   p_information30
  ,p_information_category          =>   p_information_category
  );
  --
  hr_utility.set_location('Entering: call - create_spinal_point_placement_a', 50);
  --

   begin
hr_sp_placement_api_bk1.create_sp_placement_a
  (p_effective_date                =>   l_effective_date
  ,p_business_group_id             =>   p_business_group_id
  ,p_assignment_id                 =>   p_assignment_id
  ,p_step_id                       =>   p_step_id
  ,p_auto_increment_flag           =>   p_auto_increment_flag
  ,p_reason                        =>   p_reason
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_increment_number              =>   p_increment_number
  ,p_placement_id                  =>   l_placement_id
  ,p_object_version_number         =>   l_object_version_number
  ,p_effective_start_date          =>   l_effective_start_date
  ,p_effective_end_date            =>   l_effective_end_date
  ,p_information1                  =>   p_information1
  ,p_information2                  =>   p_information2
  ,p_information3                  =>   p_information3
  ,p_information4                  =>   p_information4
  ,p_information5                  =>   p_information5
  ,p_information6                  =>   p_information6
  ,p_information7                  =>   p_information7
  ,p_information8                  =>   p_information8
  ,p_information9                  =>   p_information9
  ,p_information10                 =>   p_information10
  ,p_information11                 =>   p_information11
  ,p_information12                 =>   p_information12
  ,p_information13                 =>   p_information13
  ,p_information14                 =>   p_information14
  ,p_information15                 =>   p_information15
  ,p_information16                 =>   p_information16
  ,p_information17                 =>   p_information17
  ,p_information18                 =>   p_information18
  ,p_information19                 =>   p_information19
  ,p_information20                 =>   p_information20
  ,p_information21                 =>   p_information21
  ,p_information22                 =>   p_information22
  ,p_information23                 =>   p_information23
  ,p_information24                 =>   p_information24
  ,p_information25                 =>   p_information25
  ,p_information26                 =>   p_information26
  ,p_information27                 =>   p_information27
  ,p_information28                 =>   p_information28
  ,p_information29                 =>   p_information29
  ,p_information30                 =>   p_information30
  ,p_information_category          =>   p_information_category
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SPINAL_POINT_PLACEMENT'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- call pqh post process procedure -- bug 2999562
  --
  pqh_gsp_post_process.call_pp_from_assignments(
      p_effective_date    => l_effective_date
     ,p_assignment_id     => p_assignment_id
     ,p_date_track_mode   => NULL
     ,p_warning_mesg      => l_gsp_post_process_warning
  );

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_placement_id           := l_placement_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date	   := l_effective_end_date;
  p_gsp_post_process_warning   := l_gsp_post_process_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_spinal_point_placement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_placement_id           := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_gsp_post_process_warning := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_placement_id           := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_gsp_post_process_warning := null;
    rollback to create_spinal_point_placement;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_spp;
--

-- ----------------------------------------------------------------------------
-- |--------------------< update_spinal_point_placement >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_spp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode		   in     varchar2 default hr_api.g_update
  ,p_placement_id                  in     number
  ,p_object_version_number	   in out nocopy number
  ,p_step_id                       in     number   default hr_api.g_number
  ,p_auto_increment_flag           in     varchar2 default hr_api.g_varchar2
  ,p_reason                        in     varchar2 default hr_api.g_varchar2
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_increment_number              in     number   default hr_api.g_number
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
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date          in out nocopy date
  ,p_effective_end_date            in out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
   l_object_version_number per_spinal_point_placements_f.object_version_number%TYPE;
   l_effective_start_date  per_spinal_point_placements_f.effective_start_date%TYPE;
   l_effective_end_date    per_spinal_point_placements_f.effective_end_date%TYPE;
   l_sequence_number	   number;
   l_next_sequence	   number;
   l_parent_spine_id	   per_spinal_point_placements_f.parent_spine_id%TYPE;
   l_next_parent_spine_id  per_spinal_point_placements_f.parent_spine_id%TYPE;
   l_step_id		   per_spinal_point_placements_f.step_id%TYPE;
   l_placement_id	   per_spinal_point_placements_f.placement_id%TYPE;
   l_assignment_id	   per_spinal_point_placements_f.assignment_id%TYPE;
   l_business_group_id     per_spinal_point_placements_f.business_group_id%TYPE;
   l_datetrack_mode        varchar2(30);
   l_temp_ovn              number := p_object_version_number;
   l_effective_end_date_temp  per_spinal_point_placements_f.effective_end_date%TYPE
                              := trunc(p_effective_end_date);
   l_effective_start_date_temp per_spinal_point_placements_f.effective_start_date%TYPE
                              := trunc(p_effective_start_date);
   l_gsp_post_process_warning varchar2(30);
  --

  --
  -- Declare out parameters
  l_effective_date              date;
  --
  l_proc                varchar2(72) := g_package||'update_spinal_point_placement';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_effective_date := trunc(p_effective_date);
  l_effective_start_date := p_effective_start_date;
  l_effective_end_date := p_effective_end_date;
  l_object_version_number := p_object_version_number;

  hr_sp_placement_api.update_spp
  (p_validate                      =>   p_validate
  ,p_effective_date                =>   l_effective_date
  ,p_datetrack_mode                =>   p_datetrack_mode
  ,p_placement_id		   =>   p_placement_id
  ,p_object_version_number	   =>	l_object_version_number
  ,p_step_id                       =>   p_step_id
  ,p_auto_increment_flag           =>   p_auto_increment_flag
  ,p_reason                        =>   p_reason
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_increment_number              =>   p_increment_number
  ,p_information1                  =>   p_information1
  ,p_information2                  =>   p_information2
  ,p_information3                  =>   p_information3
  ,p_information4                  =>   p_information4
  ,p_information5                  =>   p_information5
  ,p_information6                  =>   p_information6
  ,p_information7                  =>   p_information7
  ,p_information8                  =>   p_information8
  ,p_information9                  =>   p_information9
  ,p_information10                 =>   p_information10
  ,p_information11                 =>   p_information11
  ,p_information12                 =>   p_information12
  ,p_information13                 =>   p_information13
  ,p_information14                 =>   p_information14
  ,p_information15                 =>   p_information15
  ,p_information16                 =>   p_information16
  ,p_information17                 =>   p_information17
  ,p_information18                 =>   p_information18
  ,p_information19                 =>   p_information19
  ,p_information20                 =>   p_information20
  ,p_information21                 =>   p_information21
  ,p_information22                 =>   p_information22
  ,p_information23                 =>   p_information23
  ,p_information24                 =>   p_information24
  ,p_information25                 =>   p_information25
  ,p_information26                 =>   p_information26
  ,p_information27                 =>   p_information27
  ,p_information28                 =>   p_information28
  ,p_information29                 =>   p_information29
  ,p_information30                 =>   p_information30
  ,p_information_category          =>   p_information_category
  ,p_effective_start_date 	   =>   l_effective_start_date
  ,p_effective_end_date		   =>   l_effective_end_date
  ,p_gsp_post_process_warning      =>   l_gsp_post_process_warning
  );

  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
--
end update_spp;

--
-- ----------------------------------------------------------------------------
-- |--------------------< update_spinal_point_placement  OVERLOAD>------------|
-- ----------------------------------------------------------------------------
--
procedure update_spp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode		   in     varchar2 default hr_api.g_update
  ,p_placement_id                  in     number
  ,p_object_version_number	   in out nocopy number
  ,p_step_id                       in     number   default hr_api.g_number
  ,p_auto_increment_flag           in     varchar2 default hr_api.g_varchar2
  ,p_reason                        in     varchar2 default hr_api.g_varchar2
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_increment_number              in     number   default hr_api.g_number
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
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date          in out nocopy date
  ,p_effective_end_date            in out nocopy date
  ,p_gsp_post_process_warning         out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
   l_object_version_number per_spinal_point_placements_f.object_version_number%TYPE;
   l_effective_start_date  per_spinal_point_placements_f.effective_start_date%TYPE;
   l_effective_end_date    per_spinal_point_placements_f.effective_end_date%TYPE;
   l_sequence_number	   number;
   l_next_sequence	   number;
   l_parent_spine_id	   per_spinal_point_placements_f.parent_spine_id%TYPE;
   l_next_parent_spine_id  per_spinal_point_placements_f.parent_spine_id%TYPE;
   l_step_id		   per_spinal_point_placements_f.step_id%TYPE;
   l_placement_id	   per_spinal_point_placements_f.placement_id%TYPE;
   l_assignment_id	   per_spinal_point_placements_f.assignment_id%TYPE;
   l_business_group_id     per_spinal_point_placements_f.business_group_id%TYPE;
   l_datetrack_mode        varchar2(30);
   l_temp_ovn              number := p_object_version_number;
   l_effective_end_date_temp  per_spinal_point_placements_f.effective_end_date%TYPE
                              := trunc(p_effective_end_date);
   l_effective_start_date_temp per_spinal_point_placements_f.effective_start_date%TYPE
                              := trunc(p_effective_start_date);
   l_gsp_post_process_warning varchar2(30);
  --

  --
  -- Declare out parameters
  l_effective_date              date;
  --
  l_proc                varchar2(72) := g_package||'update_spinal_point_placement';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_spinal_point_placement;
  --
  -- Check that all required parameters are not null
  --
  hr_utility.set_location('Entering mandatory arg check', 20);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'placement_id',
     p_argument_value => p_placement_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);
  --
  l_effective_date := trunc(p_effective_date);
  l_effective_start_date := p_effective_start_date;
  l_effective_end_date := p_effective_end_date;
  l_object_version_number := p_object_version_number;
  l_datetrack_mode := p_datetrack_mode;
  --
  hr_utility.set_location('Entering: call - update_spinal_point_placement_b ', 30);
  hr_utility.set_location('Increment Number:'||p_increment_number,1);
  hr_utility.set_location('Effective_date:'||l_effective_date,9);
  hr_utility.set_location('EFFECTIVE_END_DATE : '||p_effective_end_date,9);
  --

  --
  -- Get the non passed parameters
  --

  hr_utility.set_location(p_placement_id,33);
  --
  hr_utility.set_location(l_proc,20);
  select parent_spine_id, business_group_id, assignment_id
  into l_parent_spine_id, l_business_group_id, l_assignment_id
  from per_spinal_point_placements_f
  where placement_id = p_placement_id
  and l_effective_date between effective_start_date
                           and effective_end_date;
  --
  -- Call the user hook before update process
  --
  hr_utility.set_location(l_assignment_id,22);

  begin

hr_sp_placement_api_bk2.update_sp_placement_b
  (p_effective_date                =>   l_effective_date
  ,p_datetrack_mode                =>   p_datetrack_mode
  ,p_placement_id		   =>   p_placement_id
  ,p_object_version_number	   =>	p_object_version_number
  ,p_business_group_id             =>   l_business_group_id
  ,p_assignment_id                 =>   l_assignment_id
  ,p_step_id                       =>   p_step_id
  ,p_auto_increment_flag           =>   p_auto_increment_flag
  ,p_parent_spine_id               =>   l_parent_spine_id
  ,p_reason                        =>   p_reason
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_increment_number              =>   p_increment_number
  ,p_information1                  =>   p_information1
  ,p_information2                  =>   p_information2
  ,p_information3                  =>   p_information3
  ,p_information4                  =>   p_information4
  ,p_information5                  =>   p_information5
  ,p_information6                  =>   p_information6
  ,p_information7                  =>   p_information7
  ,p_information8                  =>   p_information8
  ,p_information9                  =>   p_information9
  ,p_information10                 =>   p_information10
  ,p_information11                 =>   p_information11
  ,p_information12                 =>   p_information12
  ,p_information13                 =>   p_information13
  ,p_information14                 =>   p_information14
  ,p_information15                 =>   p_information15
  ,p_information16                 =>   p_information16
  ,p_information17                 =>   p_information17
  ,p_information18                 =>   p_information18
  ,p_information19                 =>   p_information19
  ,p_information20                 =>   p_information20
  ,p_information21                 =>   p_information21
  ,p_information22                 =>   p_information22
  ,p_information23                 =>   p_information23
  ,p_information24                 =>   p_information24
  ,p_information25                 =>   p_information25
  ,p_information26                 =>   p_information26
  ,p_information27                 =>   p_information27
  ,p_information28                 =>   p_information28
  ,p_information29                 =>   p_information29
  ,p_information30                 =>   p_information30
  ,p_information_category          =>   p_information_category
  -- ,p_effective_start_date 	   =>   l_effective_start_date
  -- ,p_effetcive_end_date		   =>   l_effective_end_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SPINAL_POINT_PLACEMENT'
        ,p_hook_type   => 'BP'
        );

  end;
  hr_utility.set_location(l_proc,21);
  hr_utility.set_location('Entering: call - per_spp_upd.upd ', 40);
  --

  per_spp_upd.upd
  (p_effective_date                =>   l_effective_date
  ,p_datetrack_mode		   =>   l_datetrack_mode
  ,p_placement_id                  =>   p_placement_id
  ,p_object_version_number         =>   l_object_version_number
  ,p_step_id                       =>   p_step_id
  ,p_auto_increment_flag           =>   p_auto_increment_flag
  ,p_assignment_id   		   =>   l_assignment_id
  ,p_reason                        =>   p_reason
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_increment_number              =>   p_increment_number
  ,p_effective_start_date	   =>   l_effective_start_date
  ,p_effective_end_date		   =>   l_effective_end_date
  ,p_information1                  =>   p_information1
  ,p_information2                  =>   p_information2
  ,p_information3                  =>   p_information3
  ,p_information4                  =>   p_information4
  ,p_information5                  =>   p_information5
  ,p_information6                  =>   p_information6
  ,p_information7                  =>   p_information7
  ,p_information8                  =>   p_information8
  ,p_information9                  =>   p_information9
  ,p_information10                 =>   p_information10
  ,p_information11                 =>   p_information11
  ,p_information12                 =>   p_information12
  ,p_information13                 =>   p_information13
  ,p_information14                 =>   p_information14
  ,p_information15                 =>   p_information15
  ,p_information16                 =>   p_information16
  ,p_information17                 =>   p_information17
  ,p_information18                 =>   p_information18
  ,p_information19                 =>   p_information19
  ,p_information20                 =>   p_information20
  ,p_information21                 =>   p_information21
  ,p_information22                 =>   p_information22
  ,p_information23                 =>   p_information23
  ,p_information24                 =>   p_information24
  ,p_information25                 =>   p_information25
  ,p_information26                 =>   p_information26
  ,p_information27                 =>   p_information27
  ,p_information28                 =>   p_information28
  ,p_information29                 =>   p_information29
  ,p_information30                 =>   p_information30
  ,p_information_category          =>   p_information_category
  );

  --
  hr_utility.set_location('l_placement_id'||l_placement_id,52);
  --
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  -- p_datetrack_mode	  := l_datetrack_mode;
  --
  hr_utility.set_location('p_effective_start_date'||p_effective_start_date,55);
  hr_utility.set_location('Entering: call - update_spinal_point_placement_a', 50);
 --

  begin
  --
hr_sp_placement_api_bk2.update_sp_placement_a
  (p_effective_date                =>   l_effective_date
  ,p_datetrack_mode		   =>   p_datetrack_mode
  ,p_placement_id                  =>   p_placement_id
  ,p_object_version_number         =>   p_object_version_number
  ,p_business_group_id             =>   l_business_group_id
  ,p_assignment_id                 =>   l_assignment_id
  ,p_step_id                       =>   p_step_id
  ,p_auto_increment_flag           =>   p_auto_increment_flag
  ,p_parent_spine_id               =>   l_parent_spine_id
  ,p_reason                        =>   p_reason
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_increment_number              =>   p_increment_number
  ,p_effective_start_date          =>   l_effective_start_date
  ,p_effective_end_date            =>   l_effective_end_date
  ,p_information1                  =>   p_information1
  ,p_information2                  =>   p_information2
  ,p_information3                  =>   p_information3
  ,p_information4                  =>   p_information4
  ,p_information5                  =>   p_information5
  ,p_information6                  =>   p_information6
  ,p_information7                  =>   p_information7
  ,p_information8                  =>   p_information8
  ,p_information9                  =>   p_information9
  ,p_information10                 =>   p_information10
  ,p_information11                 =>   p_information11
  ,p_information12                 =>   p_information12
  ,p_information13                 =>   p_information13
  ,p_information14                 =>   p_information14
  ,p_information15                 =>   p_information15
  ,p_information16                 =>   p_information16
  ,p_information17                 =>   p_information17
  ,p_information18                 =>   p_information18
  ,p_information19                 =>   p_information19
  ,p_information20                 =>   p_information20
  ,p_information21                 =>   p_information21
  ,p_information22                 =>   p_information22
  ,p_information23                 =>   p_information23
  ,p_information24                 =>   p_information24
  ,p_information25                 =>   p_information25
  ,p_information26                 =>   p_information26
  ,p_information27                 =>   p_information27
  ,p_information28                 =>   p_information28
  ,p_information29                 =>   p_information29
  ,p_information30                 =>   p_information30
  ,p_information_category          =>   p_information_category
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SPINAL_POINT_PLACEMENT'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(' Leaving:'||l_proc, 60);

  --
  -- call pqh post process procedure -- bug 2999562
  --
  pqh_gsp_post_process.call_pp_from_assignments(
     p_effective_date    => l_effective_date
    ,p_assignment_id     => l_assignment_id
    ,p_date_track_mode   => p_datetrack_mode
    ,p_warning_mesg      => l_gsp_post_process_warning
  );

  hr_utility.set_location(' Leaving:'||l_proc, 65);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --
  p_gsp_post_process_warning := l_gsp_post_process_warning;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_spinal_point_placement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number   := l_temp_ovn;
    p_effective_start_date    := l_effective_start_date_temp;
    p_effective_end_date      := l_effective_end_date_temp;
    p_gsp_post_process_warning   := l_gsp_post_process_warning;
    rollback to update_spinal_point_placement;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_spp;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_spinal_point_placement >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_spp
  (p_validate			    in	   boolean  default false
  ,p_effective_date		    in	   date
  ,p_datetrack_mode		    in     varchar2 default hr_api.g_delete
  ,p_placement_id		    in     number
  ,p_object_version_number          in out nocopy number
  ,p_effective_start_date	       out nocopy date
  ,p_effective_end_date		       out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := (g_package||'delete_spinal_point_placement');
  l_effective_date date := trunc(p_effective_date);
  l_object_version_number  per_spinal_point_placements_f.object_version_number%TYPE;
  l_effective_start_date   per_spinal_point_placements_f.effective_start_date%TYPE;
  l_effective_end_date     per_spinal_point_placements_f.effective_end_date%TYPE;
  l_temp_ovn       number := p_object_version_number;
  --
begin
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'placement_id',
     p_argument_value => p_placement_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_spinal_point_placement;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_object_version_number := p_object_version_number;
  -- Process Logic
  --
  --

  begin
    --
    -- Start of API User Hook for the before hook of delete_spinal_point_placement
    --
    hr_sp_placement_api_bk3.delete_sp_placement_b
      (p_effective_date			=>  l_effective_date
      ,p_datetrack_mode			=>  p_datetrack_mode
      ,p_placement_id			=>  p_placement_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_spinal_point_placement'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_spinal_point_placement
    --
  end;

  --
  per_spp_del.del
    (p_effective_date			=>  l_effective_date
    ,p_datetrack_mode			=>  p_datetrack_mode
    ,p_placement_id			=>  p_placement_id
    ,p_object_version_number		=>  p_object_version_number
    ,p_effective_start_date		=>  l_effective_start_date
    ,p_effective_end_date		=>  l_effective_end_date
    );
  --

  begin
    --
    -- Start of API User Hook for the after hook of delete_spinal_point_placement
    --
    hr_sp_placement_api_bk3.delete_sp_placement_a
      (p_effective_date                 =>  l_effective_date
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_placement_id                   =>  p_placement_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_spinal_point_placement'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_spinal_point_placement
    --
  end;

  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_spinal_point_placement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := l_temp_ovn;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    ROLLBACK TO delete_spinal_point_placement;
    raise;
    --
end delete_spp;
--
--
end hr_sp_placement_api;

/
