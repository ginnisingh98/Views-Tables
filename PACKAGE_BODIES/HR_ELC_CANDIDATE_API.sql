--------------------------------------------------------
--  DDL for Package Body HR_ELC_CANDIDATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ELC_CANDIDATE_API" as
/* $Header: peecaapi.pkb 115.4 2002/12/10 16:46:24 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_elc_candidate_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_election_candidate >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_election_candidate
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_election_id                   in     number
  ,p_rank                          in     number
  ,p_role_id                       in     number
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
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
 ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_candidate_info_category      in     varchar2 default null
  ,p_candidate_information1              in     varchar2 default null
  ,p_candidate_information2              in     varchar2 default null
  ,p_candidate_information3              in     varchar2 default null
  ,p_candidate_information4              in     varchar2 default null
  ,p_candidate_information5              in     varchar2 default null
  ,p_candidate_information6              in     varchar2 default null
  ,p_candidate_information7              in     varchar2 default null
  ,p_candidate_information8              in     varchar2 default null
  ,p_candidate_information9              in     varchar2 default null
  ,p_candidate_information10             in     varchar2 default null
  ,p_candidate_information11             in     varchar2 default null
  ,p_candidate_information12             in     varchar2 default null
  ,p_candidate_information13             in     varchar2 default null
  ,p_candidate_information14             in     varchar2 default null
  ,p_candidate_information15             in     varchar2 default null
  ,p_candidate_information16             in     varchar2 default null
  ,p_candidate_information17             in     varchar2 default null
  ,p_candidate_information18             in     varchar2 default null
  ,p_candidate_information19             in     varchar2 default null
  ,p_candidate_information20             in     varchar2 default null
  ,p_candidate_information21             in     varchar2 default null
  ,p_candidate_information22             in     varchar2 default null
  ,p_candidate_information23             in     varchar2 default null
  ,p_candidate_information24             in     varchar2 default null
  ,p_candidate_information25             in     varchar2 default null
  ,p_candidate_information26             in     varchar2 default null
  ,p_candidate_information27             in     varchar2 default null
  ,p_candidate_information28             in     varchar2 default null
  ,p_candidate_information29             in     varchar2 default null
  ,p_candidate_information30             in     varchar2 default null
  ,p_election_candidate_id                  out nocopy number
  ,p_object_version_number                  out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                      varchar2(72) := g_package||'create_election_candidate';
  l_election_candidate_id     per_election_candidates.election_candidate_id%TYPE;
  l_object_version_number     per_election_candidates.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_election_candidate;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hr_elc_candidate_api_bk1.create_election_candidate_b
      (p_business_group_id             => p_business_group_id
      ,p_person_id                     => p_person_id
      ,p_election_id                   => p_election_id
      ,p_rank                          => p_rank
      ,p_role_id                       => p_role_id
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
      ,p_candidate_info_category       => p_candidate_info_category
      ,p_candidate_information1        => p_candidate_information1
      ,p_candidate_information2        => p_candidate_information2
      ,p_candidate_information3        => p_candidate_information3
      ,p_candidate_information4        => p_candidate_information4
      ,p_candidate_information5              => p_candidate_information5
      ,p_candidate_information6              => p_candidate_information6
      ,p_candidate_information7              => p_candidate_information7
      ,p_candidate_information8              => p_candidate_information8
      ,p_candidate_information9              => p_candidate_information9
      ,p_candidate_information10             => p_candidate_information10
      ,p_candidate_information11             => p_candidate_information11
      ,p_candidate_information12             => p_candidate_information12
      ,p_candidate_information13             => p_candidate_information13
      ,p_candidate_information14             => p_candidate_information14
      ,p_candidate_information15             => p_candidate_information15
      ,p_candidate_information16             => p_candidate_information16
      ,p_candidate_information17             => p_candidate_information17
      ,p_candidate_information18             => p_candidate_information18
      ,p_candidate_information19             => p_candidate_information19
      ,p_candidate_information20             => p_candidate_information20
      ,p_candidate_information21             => p_candidate_information21
      ,p_candidate_information22             => p_candidate_information22
      ,p_candidate_information23             => p_candidate_information23
      ,p_candidate_information24             => p_candidate_information24
      ,p_candidate_information25             => p_candidate_information25
      ,p_candidate_information26             => p_candidate_information26
      ,p_candidate_information27             => p_candidate_information27
      ,p_candidate_information28             => p_candidate_information28
      ,p_candidate_information29             => p_candidate_information29
      ,p_candidate_information30             => p_candidate_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_election_candidate_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
per_eca_ins.ins
       (p_business_group_id                     => p_business_group_id
       ,p_election_id                           => p_election_id
       ,p_person_id                             => p_person_id
       ,p_rank                                  => p_rank
       ,p_role_id                               => p_role_id
       ,p_attribute_category                    => p_attribute_category
       ,p_attribute1                            => p_attribute1
       ,p_attribute2                            => p_attribute2
       ,p_attribute3                            => p_attribute3
       ,p_attribute4                            => p_attribute4
       ,p_attribute5                            => p_attribute5
       ,p_attribute6                            => p_attribute6
       ,p_attribute7                            => p_attribute7
       ,p_attribute8                            => p_attribute8
       ,p_attribute9                            => p_attribute9
       ,p_attribute10                           => p_attribute10
       ,p_attribute11                           => p_attribute11
       ,p_attribute12                           => p_attribute12
       ,p_attribute13                           => p_attribute13
       ,p_attribute14                           => p_attribute14
       ,p_attribute15                           => p_attribute15
       ,p_attribute16                           => p_attribute16
       ,p_attribute17                           => p_attribute17
       ,p_attribute18                           => p_attribute18
       ,p_attribute19                           => p_attribute19
       ,p_attribute20                           => p_attribute20
       ,p_attribute21                           => p_attribute21
       ,p_attribute22                           => p_attribute22
       ,p_attribute23                           => p_attribute23
       ,p_attribute24                           => p_attribute24
       ,p_attribute25                           => p_attribute25
       ,p_attribute26                           => p_attribute26
       ,p_attribute27                           => p_attribute27
       ,p_attribute28                           => p_attribute28
       ,p_attribute29                           => p_attribute29
       ,p_attribute30                           => p_attribute30
       ,p_candidate_info_category               => p_candidate_info_category
       ,p_candidate_information1                => p_candidate_information1
       ,p_candidate_information2                => p_candidate_information2
       ,p_candidate_information3                => p_candidate_information3
       ,p_candidate_information4                => p_candidate_information4
       ,p_candidate_information5                => p_candidate_information5
       ,p_candidate_information6                => p_candidate_information6
       ,p_candidate_information7                => p_candidate_information7
       ,p_candidate_information8                => p_candidate_information8
       ,p_candidate_information9                => p_candidate_information9
       ,p_candidate_information10               => p_candidate_information10
       ,p_candidate_information11               => p_candidate_information11
       ,p_candidate_information12               => p_candidate_information12
       ,p_candidate_information13               => p_candidate_information13
       ,p_candidate_information14               => p_candidate_information14
       ,p_candidate_information15               => p_candidate_information15
      ,p_candidate_information16                => p_candidate_information16
       ,p_candidate_information17               => p_candidate_information17
       ,p_candidate_information18               => p_candidate_information18
       ,p_candidate_information19               => p_candidate_information19
       ,p_candidate_information20               => p_candidate_information20
       ,p_candidate_information21               => p_candidate_information21
       ,p_candidate_information22               => p_candidate_information22
       ,p_candidate_information23               => p_candidate_information23
       ,p_candidate_information24               => p_candidate_information24
       ,p_candidate_information25               => p_candidate_information25
       ,p_candidate_information26               => p_candidate_information26
       ,p_candidate_information27               => p_candidate_information27
       ,p_candidate_information28               => p_candidate_information28
       ,p_candidate_information29               => p_candidate_information29
       ,p_candidate_information30               => p_candidate_information30
       ,p_election_candidate_id                 => l_election_candidate_id
       ,p_object_version_number                 => l_object_version_number);



  --
  -- Call After Process User Hook
  --
  begin
    hr_elc_candidate_api_bk1.create_election_candidate_a
      (p_business_group_id                     => p_business_group_id
       ,p_election_id                           => p_election_id
       ,p_person_id                             => p_person_id
       ,p_rank                                  => p_rank
       ,p_role_id                               => p_role_id
       ,p_attribute_category                    => p_attribute_category
       ,p_attribute1                            => p_attribute1
       ,p_attribute2                            => p_attribute2
       ,p_attribute3                            => p_attribute3
       ,p_attribute4                            => p_attribute4
       ,p_attribute5                            => p_attribute5
       ,p_attribute6                            => p_attribute6
       ,p_attribute7                            => p_attribute7
       ,p_attribute8                            => p_attribute8
       ,p_attribute9                            => p_attribute9
       ,p_attribute10                           => p_attribute10
       ,p_attribute11                           => p_attribute11
       ,p_attribute12                           => p_attribute12
       ,p_attribute13                           => p_attribute13
       ,p_attribute14                           => p_attribute14
       ,p_attribute15                           => p_attribute15
       ,p_attribute16                           => p_attribute16
       ,p_attribute17                           => p_attribute17
       ,p_attribute18                           => p_attribute18
       ,p_attribute19                           => p_attribute19
       ,p_attribute20                           => p_attribute20
       ,p_attribute21                           => p_attribute21
       ,p_attribute22                           => p_attribute22
       ,p_attribute23                           => p_attribute23
       ,p_attribute24                           => p_attribute24
       ,p_attribute25                           => p_attribute25
       ,p_attribute26                           => p_attribute26
       ,p_attribute27                           => p_attribute27
       ,p_attribute28                           => p_attribute28
       ,p_attribute29                           => p_attribute29
       ,p_attribute30                           => p_attribute30
       ,p_candidate_info_category               => p_candidate_info_category
       ,p_candidate_information1                => p_candidate_information1
       ,p_candidate_information2                => p_candidate_information2
       ,p_candidate_information3                => p_candidate_information3
       ,p_candidate_information4                => p_candidate_information4
       ,p_candidate_information5                => p_candidate_information5
       ,p_candidate_information6                => p_candidate_information6
       ,p_candidate_information7                => p_candidate_information7
       ,p_candidate_information8                => p_candidate_information8
       ,p_candidate_information9                => p_candidate_information9
       ,p_candidate_information10               => p_candidate_information10
       ,p_candidate_information11               => p_candidate_information11
       ,p_candidate_information12               => p_candidate_information12
       ,p_candidate_information13               => p_candidate_information13
       ,p_candidate_information14               => p_candidate_information14
       ,p_candidate_information15               => p_candidate_information15
      ,p_candidate_information16                => p_candidate_information16
       ,p_candidate_information17               => p_candidate_information17
       ,p_candidate_information18               => p_candidate_information18
       ,p_candidate_information19               => p_candidate_information19
       ,p_candidate_information20               => p_candidate_information20
       ,p_candidate_information21               => p_candidate_information21
       ,p_candidate_information22               => p_candidate_information22
       ,p_candidate_information23               => p_candidate_information23
       ,p_candidate_information24               => p_candidate_information24
       ,p_candidate_information25               => p_candidate_information25
       ,p_candidate_information26               => p_candidate_information26
       ,p_candidate_information27               => p_candidate_information27
       ,p_candidate_information28               => p_candidate_information28
       ,p_candidate_information29               => p_candidate_information29
       ,p_candidate_information30               => p_candidate_information30
       ,p_election_candidate_id                 => l_election_candidate_id
       ,p_object_version_number                 => l_object_version_number);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_election_candidate_a'
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
  -- Set all output arguments
  --
  p_election_candidate_id  := l_election_candidate_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_election_candidate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_election_candidate_id  := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_election_candidate;
    --
    -- set in out parameters and set out parameters
    --
    p_election_candidate_id  := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_election_candidate;
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_election_candidate >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_election_candidate
  (p_validate                      in     boolean  default false
  ,p_election_candidate_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_election_id                   in     number   default hr_api.g_number
  ,p_rank                          in     number   default hr_api.g_number
  ,p_role_id                       in     number   default hr_api.g_number
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
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_candidate_info_category       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information1        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information2        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information3        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information4        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information5        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information6        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information7        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information8        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information9        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information10       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information11       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information12       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information13       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information14       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information15       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information16       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information17       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information18       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information19       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information20       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information21       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information22       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information23       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information24       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information25       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information26       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information27       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information28       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information29       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information30       in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                      varchar2(72) := g_package||'create_election_candidate';
  l_object_version_number     per_election_candidates.object_version_number%TYPE;
 l_ovn per_election_candidates.object_version_number%TYPE := p_object_version_number;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_election_candidate;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Store OVN passed in
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_elc_candidate_api_bk2.update_election_candidate_b
      (p_election_candidate_id         => p_election_candidate_id
      ,p_object_version_number         => l_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_person_id                     => p_person_id
      ,p_election_id                   => p_election_id
      ,p_rank                          => p_rank
      ,p_role_id                       => p_role_id
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
      ,p_candidate_info_category       => p_candidate_info_category
      ,p_candidate_information1        => p_candidate_information1
      ,p_candidate_information2        => p_candidate_information2
      ,p_candidate_information3        => p_candidate_information3
      ,p_candidate_information4        => p_candidate_information4
      ,p_candidate_information5              => p_candidate_information5
      ,p_candidate_information6              => p_candidate_information6
      ,p_candidate_information7              => p_candidate_information7
      ,p_candidate_information8              => p_candidate_information8
      ,p_candidate_information9              => p_candidate_information9
      ,p_candidate_information10             => p_candidate_information10
      ,p_candidate_information11             => p_candidate_information11
      ,p_candidate_information12             => p_candidate_information12
      ,p_candidate_information13             => p_candidate_information13
      ,p_candidate_information14             => p_candidate_information14
      ,p_candidate_information15             => p_candidate_information15
      ,p_candidate_information16             => p_candidate_information16
      ,p_candidate_information17             => p_candidate_information17
      ,p_candidate_information18             => p_candidate_information18
      ,p_candidate_information19             => p_candidate_information19
      ,p_candidate_information20             => p_candidate_information20
      ,p_candidate_information21             => p_candidate_information21
      ,p_candidate_information22             => p_candidate_information22
      ,p_candidate_information23             => p_candidate_information23
      ,p_candidate_information24             => p_candidate_information24
      ,p_candidate_information25             => p_candidate_information25
      ,p_candidate_information26             => p_candidate_information26
      ,p_candidate_information27             => p_candidate_information27
      ,p_candidate_information28             => p_candidate_information28
      ,p_candidate_information29             => p_candidate_information29
      ,p_candidate_information30             => p_candidate_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_election_candidate_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
per_eca_upd.upd
       (p_election_candidate_id                 => p_election_candidate_id
       ,p_object_version_number                 => l_object_version_number
       ,p_business_group_id                     => p_business_group_id
       ,p_election_id                           => p_election_id
       ,p_person_id                             => p_person_id
       ,p_rank                                  => p_rank
       ,p_role_id                               => p_role_id
       ,p_attribute_category                    => p_attribute_category
       ,p_attribute1                            => p_attribute1
       ,p_attribute2                            => p_attribute2
       ,p_attribute3                            => p_attribute3
       ,p_attribute4                            => p_attribute4
       ,p_attribute5                            => p_attribute5
       ,p_attribute6                            => p_attribute6
       ,p_attribute7                            => p_attribute7
       ,p_attribute8                            => p_attribute8
       ,p_attribute9                            => p_attribute9
       ,p_attribute10                           => p_attribute10
       ,p_attribute11                           => p_attribute11
       ,p_attribute12                           => p_attribute12
       ,p_attribute13                           => p_attribute13
       ,p_attribute14                           => p_attribute14
       ,p_attribute15                           => p_attribute15
       ,p_attribute16                           => p_attribute16
       ,p_attribute17                           => p_attribute17
       ,p_attribute18                           => p_attribute18
       ,p_attribute19                           => p_attribute19
       ,p_attribute20                           => p_attribute20
       ,p_attribute21                           => p_attribute21
       ,p_attribute22                           => p_attribute22
       ,p_attribute23                           => p_attribute23
       ,p_attribute24                           => p_attribute24
       ,p_attribute25                           => p_attribute25
       ,p_attribute26                           => p_attribute26
       ,p_attribute27                           => p_attribute27
       ,p_attribute28                           => p_attribute28
       ,p_attribute29                           => p_attribute29
       ,p_attribute30                           => p_attribute30
       ,p_candidate_info_category               => p_candidate_info_category
       ,p_candidate_information1                => p_candidate_information1
       ,p_candidate_information2                => p_candidate_information2
       ,p_candidate_information3                => p_candidate_information3
       ,p_candidate_information4                => p_candidate_information4
       ,p_candidate_information5                => p_candidate_information5
       ,p_candidate_information6                => p_candidate_information6
       ,p_candidate_information7                => p_candidate_information7
       ,p_candidate_information8                => p_candidate_information8
       ,p_candidate_information9                => p_candidate_information9
       ,p_candidate_information10               => p_candidate_information10
       ,p_candidate_information11               => p_candidate_information11
       ,p_candidate_information12               => p_candidate_information12
       ,p_candidate_information13               => p_candidate_information13
       ,p_candidate_information14               => p_candidate_information14
       ,p_candidate_information15               => p_candidate_information15
      ,p_candidate_information16                => p_candidate_information16
       ,p_candidate_information17               => p_candidate_information17
       ,p_candidate_information18               => p_candidate_information18
       ,p_candidate_information19               => p_candidate_information19
       ,p_candidate_information20               => p_candidate_information20
       ,p_candidate_information21               => p_candidate_information21
       ,p_candidate_information22               => p_candidate_information22
       ,p_candidate_information23               => p_candidate_information23
       ,p_candidate_information24               => p_candidate_information24
       ,p_candidate_information25               => p_candidate_information25
       ,p_candidate_information26               => p_candidate_information26
       ,p_candidate_information27               => p_candidate_information27
       ,p_candidate_information28               => p_candidate_information28
       ,p_candidate_information29               => p_candidate_information29
       ,p_candidate_information30               => p_candidate_information30);


  --
  -- Call After Process User Hook
  --
  begin
    hr_elc_candidate_api_bk2.update_election_candidate_a
      (p_election_candidate_id                  => p_election_candidate_id
       ,p_object_version_number                => l_object_version_number
       ,p_business_group_id                     => p_business_group_id
       ,p_election_id                           => p_election_id
       ,p_person_id                             => p_person_id
       ,p_rank                                  => p_rank
       ,p_role_id                               => p_role_id
       ,p_attribute_category                    => p_attribute_category
       ,p_attribute1                            => p_attribute1
       ,p_attribute2                            => p_attribute2
       ,p_attribute3                            => p_attribute3
       ,p_attribute4                            => p_attribute4
       ,p_attribute5                            => p_attribute5
       ,p_attribute6                            => p_attribute6
       ,p_attribute7                            => p_attribute7
       ,p_attribute8                            => p_attribute8
       ,p_attribute9                            => p_attribute9
       ,p_attribute10                           => p_attribute10
       ,p_attribute11                           => p_attribute11
       ,p_attribute12                           => p_attribute12
       ,p_attribute13                           => p_attribute13
       ,p_attribute14                           => p_attribute14
       ,p_attribute15                           => p_attribute15
       ,p_attribute16                           => p_attribute16
       ,p_attribute17                           => p_attribute17
       ,p_attribute18                           => p_attribute18
       ,p_attribute19                           => p_attribute19
       ,p_attribute20                           => p_attribute20
       ,p_attribute21                           => p_attribute21
       ,p_attribute22                           => p_attribute22
       ,p_attribute23                           => p_attribute23
       ,p_attribute24                           => p_attribute24
       ,p_attribute25                           => p_attribute25
       ,p_attribute26                           => p_attribute26
       ,p_attribute27                           => p_attribute27
       ,p_attribute28                           => p_attribute28
       ,p_attribute29                           => p_attribute29
       ,p_attribute30                           => p_attribute30
       ,p_candidate_info_category               => p_candidate_info_category
       ,p_candidate_information1                => p_candidate_information1
       ,p_candidate_information2                => p_candidate_information2
       ,p_candidate_information3                => p_candidate_information3
       ,p_candidate_information4                => p_candidate_information4
       ,p_candidate_information5                => p_candidate_information5
       ,p_candidate_information6                => p_candidate_information6
       ,p_candidate_information7                => p_candidate_information7
       ,p_candidate_information8                => p_candidate_information8
       ,p_candidate_information9                => p_candidate_information9
       ,p_candidate_information10               => p_candidate_information10
       ,p_candidate_information11               => p_candidate_information11
       ,p_candidate_information12               => p_candidate_information12
       ,p_candidate_information13               => p_candidate_information13
       ,p_candidate_information14               => p_candidate_information14
       ,p_candidate_information15               => p_candidate_information15
      ,p_candidate_information16                => p_candidate_information16
       ,p_candidate_information17               => p_candidate_information17
       ,p_candidate_information18               => p_candidate_information18
       ,p_candidate_information19               => p_candidate_information19
       ,p_candidate_information20               => p_candidate_information20
       ,p_candidate_information21               => p_candidate_information21
       ,p_candidate_information22               => p_candidate_information22
       ,p_candidate_information23               => p_candidate_information23
       ,p_candidate_information24               => p_candidate_information24
       ,p_candidate_information25               => p_candidate_information25
       ,p_candidate_information26               => p_candidate_information26
       ,p_candidate_information27               => p_candidate_information27
       ,p_candidate_information28               => p_candidate_information28
       ,p_candidate_information29               => p_candidate_information29
       ,p_candidate_information30               => p_candidate_information30
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_election_candidate_a'
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
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_election_candidate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_election_candidate;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number  := l_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_election_candidate;
--
-- |---------------------------< delete_election_candidate >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_election_candidate
  (p_validate                      in     boolean  default false
  ,p_election_candidate_id         in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_election_candidate';
  l_object_version_number per_election_candidates.object_version_number%TYPE;
  l_ovn per_election_candidates.object_version_number%TYPE := p_object_version_number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_election_candidate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  hr_utility.set_location(l_proc, 30);
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_election_candidate
    --
    hr_elc_candidate_api_bk3.delete_election_candidate_b
      (p_election_candidate_id            =>  p_election_candidate_id
      ,p_object_version_number            =>  l_object_version_number
      );
    --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_election_candidate_b'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_election_candidate
    --
  end;
    --
    per_eca_del.del
      (p_election_candidate_id         => p_election_candidate_id
      ,p_object_version_number         => l_object_version_number
      );
    --
  begin
    --
    -- Start of API User Hook for the after hook of delete_contract
    --
    hr_elc_candidate_api_bk3.delete_election_candidate_a
      (p_election_candidate_id          =>  p_election_candidate_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_election_candidate_a'
        ,p_hook_type   => 'AP'
        );
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  p_object_version_number := l_object_version_number;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments (returned by some dt modes only)
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint    --
    ROLLBACK TO delete_election_candidate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_election_candidate;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    raise;
    --
end delete_election_candidate;
--

end hr_elc_candidate_api;

/
