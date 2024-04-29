--------------------------------------------------------
--  DDL for Package Body HR_PERIODS_OF_PLACEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERIODS_OF_PLACEMENT_API" as
/* $Header: pepdpapi.pkb 115.3 2003/12/03 07:09:02 adhunter noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_periods_of_placement_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_pdp_details >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pdp_details
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_projected_termination_date   in     date      default hr_api.g_date
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
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
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                       varchar2(72) := g_package||'update_pdp_details';
  l_effective_date             date;
  l_date_start                 date;

  --
  -- Declare out parameters
  --
  l_object_version_number      number;
  l_ovn 			number := p_object_version_number;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Pipe the main IN / IN OUT parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN / IN OUT NOCOPY PARAMETER           '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_effective_date                 '||
                      to_char(p_effective_date));
  hr_utility.trace('  p_object_version_number          '||
                      to_char(p_object_version_number));
  hr_utility.trace('  p_person_id                      '||
                      to_char(p_person_id));
  hr_utility.trace('  p_date_start                     '||
                      to_char(p_date_start));
  hr_utility.trace('  p_termination_reason             '||
                      p_termination_reason);
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  --
  -- Create a savepoint.
  --
  savepoint update_pdp_details;


  l_object_version_number      := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date             := trunc(p_effective_date);
  l_date_start                 := trunc(p_date_start);

  --
  -- Call Before Process User Hook
  --
  begin

    hr_periods_of_placement_bk1.update_pdp_details_b
     (p_object_version_number         => l_object_version_number
     ,p_effective_date                => l_effective_date
     ,p_person_id                     => p_person_id
     ,p_date_start                    => l_date_start
     ,p_projected_termination_date    => null
     ,p_termination_reason            => p_termination_reason
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
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
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
        (p_module_name => 'UPDATE_PDP_DETAILS'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Update Period of Placement
  --
  per_pdp_upd.upd
     (p_object_version_number         => l_object_version_number
     ,p_effective_date                => l_effective_date
     ,p_person_id                     => p_person_id
     ,p_date_start                    => l_date_start
     ,p_projected_termination_date    => null
     ,p_termination_reason            => p_termination_reason
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
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
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

  --
  -- Assign the out parameters
  --
  p_object_version_number     := l_object_version_number;

  hr_utility.set_location(l_proc, 40);

  --
  -- Call After Process User Hook
  --
  begin

    hr_periods_of_placement_bk1.update_pdp_details_a
     (p_object_version_number         => l_object_version_number
     ,p_effective_date                => l_effective_date
     ,p_person_id                     => p_person_id
     ,p_date_start                    => l_date_start
     ,p_projected_termination_date    => null
     ,p_termination_reason            => p_termination_reason
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
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
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
        (p_module_name => 'UPDATE_PDP_DETAILS'
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
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN OUT NOCOPY / OUT NOCOPY PARAMETER          '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_object_version_number          '||
                      to_char(p_object_version_number));
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_pdp_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_pdp_details;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number  := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_pdp_details;
--
--
end hr_periods_of_placement_api;

/
