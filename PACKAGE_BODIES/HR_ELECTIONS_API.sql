--------------------------------------------------------
--  DDL for Package Body HR_ELECTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ELECTIONS_API" as
/* $Header: peelcapi.pkb 115.8 2002/12/10 16:56:37 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '   HR_ELECTIONS_API .';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_election_information >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_election_information
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_election_date                 in     date
  ,p_description                   in     varchar2
  ,p_rep_body_id                   in     number
  ,p_previous_election_date        in     date     default null
  ,p_next_election_date            in     date     default null
  ,p_result_publish_date           in     date     default null
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
  ,p_election_info_category        in     varchar2 default null
  ,p_election_information1         in     varchar2 default null
  ,p_election_information2         in     varchar2 default null
  ,p_election_information3         in     varchar2 default null
  ,p_election_information4         in     varchar2 default null
  ,p_election_information5         in     varchar2 default null
  ,p_election_information6         in     varchar2 default null
  ,p_election_information7         in     varchar2 default null
  ,p_election_information8         in     varchar2 default null
  ,p_election_information9         in     varchar2 default null
  ,p_election_information10        in     varchar2 default null
  ,p_election_information11        in     varchar2 default null
  ,p_election_information12        in     varchar2 default null
  ,p_election_information13        in     varchar2 default null
  ,p_election_information14        in     varchar2 default null
  ,p_election_information15        in     varchar2 default null
  ,p_election_information16        in     varchar2 default null
  ,p_election_information17        in     varchar2 default null
  ,p_election_information18        in     varchar2 default null
  ,p_election_information19        in     varchar2 default null
  ,p_election_information20	   in	  varchar2 default null
  ,p_election_information21        in     varchar2 default null
  ,p_election_information22        in     varchar2 default null
  ,p_election_information23        in     varchar2 default null
  ,p_election_information24        in     varchar2 default null
  ,p_election_information25        in     varchar2 default null
  ,p_election_information26        in     varchar2 default null
  ,p_election_information27        in     varchar2 default null
  ,p_election_information28        in     varchar2 default null
  ,p_election_information29        in     varchar2 default null
  ,p_election_information30        in     varchar2 default null
  ,p_election_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date	date;
  l_object_version_number  per_elections.object_version_number%TYPE;
  --
  -- Declare out parameters
  l_election_id		  per_elections.election_id%TYPE;
  --
  l_proc                varchar2(72) := g_package||'create_election_information';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 12);
  --
  -- Issue a savepoint
  --
  savepoint create_election_information;
  --
  -- Check that p_rep_body_id, p_business_group_id, election_date are not null.
  --
  hr_utility.set_location('Entering mandatory arg check', 20);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'rep_body_id',
     p_argument_value => p_rep_body_id);
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
     p_argument       => 'election_date',
     p_argument_value => p_election_date);
  --
  l_effective_date := trunc(p_effective_date);
  --
  hr_utility.set_location('Entering: call - create_election_information_b ', 30);
  --
  begin


hr_elections_api_bk1.create_election_information_b
  (p_effective_date                =>	l_effective_date
  ,p_business_group_id             =>	p_business_group_id
  ,p_election_date		   =>	p_election_date
  ,p_description		   =>   p_description
  ,p_rep_body_id                   =>	p_rep_body_id
  ,p_previous_election_date        =>	p_previous_election_date
  ,p_next_election_date            =>	p_next_election_date
  ,p_result_publish_date           =>	p_result_publish_date
  ,p_attribute_category            =>	p_attribute_category
  ,p_attribute1                    =>	p_attribute1
  ,p_attribute2                    =>   p_attribute2
  ,p_attribute3                    =>   p_attribute3
  ,p_attribute4                    =>   p_attribute4
  ,p_attribute5                    =>   p_attribute5
  ,p_attribute6                    =>   p_attribute6
  ,p_attribute7                    =>   p_attribute7
  ,p_attribute8                    =>   p_attribute8
  ,p_attribute9                    =>   p_attribute9
  ,p_attribute10                   =>   p_attribute10
  ,p_attribute11                   =>   p_attribute11
  ,p_attribute12                   =>   p_attribute12
  ,p_attribute13                   =>   p_attribute13
  ,p_attribute14                   =>   p_attribute14
  ,p_attribute15                   =>   p_attribute15
  ,p_attribute16                   =>   p_attribute16
  ,p_attribute17                   =>   p_attribute17
  ,p_attribute18                   =>   p_attribute18
  ,p_attribute19                   =>   p_attribute19
  ,p_attribute20                   =>   p_attribute20
  ,p_attribute21                   =>   p_attribute21
  ,p_attribute22                   =>   p_attribute22
  ,p_attribute23                   =>   p_attribute23
  ,p_attribute24                   =>   p_attribute24
  ,p_attribute25                   =>   p_attribute25
  ,p_attribute26                   =>   p_attribute26
  ,p_attribute27                   =>   p_attribute27
  ,p_attribute28                   =>   p_attribute28
  ,p_attribute29                   =>   p_attribute29
  ,p_attribute30                   =>   p_attribute30
  ,p_election_info_category        =>	p_election_info_category
  ,p_election_information1         =>	p_election_information1
  ,p_election_information2         =>   p_election_information2
  ,p_election_information3         =>   p_election_information3
  ,p_election_information4         =>   p_election_information4
  ,p_election_information5         =>   p_election_information5
  ,p_election_information6         =>   p_election_information6
  ,p_election_information7         =>   p_election_information7
  ,p_election_information8         =>   p_election_information8
  ,p_election_information9         =>   p_election_information9
  ,p_election_information10        =>   p_election_information10
  ,p_election_information11        =>   p_election_information11
  ,p_election_information12        =>   p_election_information12
  ,p_election_information13        =>   p_election_information13
  ,p_election_information14        =>   p_election_information14
  ,p_election_information15        =>   p_election_information15
  ,p_election_information16        =>   p_election_information16
  ,p_election_information17        =>   p_election_information17
  ,p_election_information18        =>   p_election_information18
  ,p_election_information19        =>   p_election_information19
  ,p_election_information20        =>   p_election_information20
  ,p_election_information21        =>   p_election_information21
  ,p_election_information22        =>   p_election_information22
  ,p_election_information23        =>   p_election_information23
  ,p_election_information24        =>   p_election_information24
  ,p_election_information25        =>   p_election_information25
  ,p_election_information26        =>   p_election_information26
  ,p_election_information27        =>   p_election_information27
  ,p_election_information28        =>   p_election_information28
  ,p_election_information29        =>   p_election_information29
  ,p_election_information30        =>   p_election_information30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELECTION_INFORMATION'
        ,p_hook_type   => 'BP'
        );

  end;
  --
  hr_utility.set_location('Entering: call - per_elc_ins.ins ', 40);
  --
  per_elc_ins.ins
  (p_effective_date                =>   l_effective_date
  ,p_validate                      =>   FALSE
  ,p_business_group_id             =>   p_business_group_id
  ,p_election_date		   =>	p_election_date
  ,p_description		   =>   p_description
  ,p_rep_body_id                   =>   p_rep_body_id
  ,p_previous_election_date        =>   p_previous_election_date
  ,p_next_election_date            =>   p_next_election_date
  ,p_result_publish_date           =>   p_result_publish_date
  ,p_attribute_category            =>   p_attribute_category
  ,p_attribute1                    =>   p_attribute1
  ,p_attribute2                    =>   p_attribute2
  ,p_attribute3                    =>   p_attribute3
  ,p_attribute4                    =>   p_attribute4
  ,p_attribute5                    =>   p_attribute5
  ,p_attribute6                    =>   p_attribute6
  ,p_attribute7                    =>   p_attribute7
  ,p_attribute8                    =>   p_attribute8
  ,p_attribute9                    =>   p_attribute9
  ,p_attribute10                   =>   p_attribute10
  ,p_attribute11                   =>   p_attribute11
  ,p_attribute12                   =>   p_attribute12
  ,p_attribute13                   =>   p_attribute13
  ,p_attribute14                   =>   p_attribute14
  ,p_attribute15                   =>   p_attribute15
  ,p_attribute16                   =>   p_attribute16
  ,p_attribute17                   =>   p_attribute17
  ,p_attribute18                   =>   p_attribute18
  ,p_attribute19                   =>   p_attribute19
  ,p_attribute20                   =>   p_attribute20
  ,p_attribute21                   =>   p_attribute21
  ,p_attribute22                   =>   p_attribute22
  ,p_attribute23                   =>   p_attribute23
  ,p_attribute24                   =>   p_attribute24
  ,p_attribute25                   =>   p_attribute25
  ,p_attribute26                   =>   p_attribute26
  ,p_attribute27                   =>   p_attribute27
  ,p_attribute28                   =>   p_attribute28
  ,p_attribute29                   =>   p_attribute29
  ,p_attribute30                   =>   p_attribute30
  ,p_election_info_category		=>   p_election_info_category
  ,p_election_information1         =>   p_election_information1
  ,p_election_information2         =>   p_election_information2
  ,p_election_information3         =>   p_election_information3
  ,p_election_information4         =>   p_election_information4
  ,p_election_information5         =>   p_election_information5
  ,p_election_information6         =>   p_election_information6
  ,p_election_information7         =>   p_election_information7
  ,p_election_information8         =>   p_election_information8
  ,p_election_information9         =>   p_election_information9
  ,p_election_information10        =>   p_election_information10
  ,p_election_information11        =>   p_election_information11
  ,p_election_information12        =>   p_election_information12
  ,p_election_information13        =>   p_election_information13
  ,p_election_information14        =>   p_election_information14
  ,p_election_information15        =>   p_election_information15
  ,p_election_information16        =>   p_election_information16
  ,p_election_information17        =>   p_election_information17
  ,p_election_information18        =>   p_election_information18
  ,p_election_information19        =>   p_election_information19
  ,p_election_information20        =>   p_election_information20
  ,p_election_information21        =>   p_election_information21
  ,p_election_information22        =>   p_election_information22
  ,p_election_information23        =>   p_election_information23
  ,p_election_information24        =>   p_election_information24
  ,p_election_information25        =>   p_election_information25
  ,p_election_information26        =>   p_election_information26
  ,p_election_information27        =>   p_election_information27
  ,p_election_information28        =>   p_election_information28
  ,p_election_information29        =>   p_election_information29
  ,p_election_information30        =>   p_election_information30
  ,p_election_id		   		=>	l_election_id
  ,p_object_version_number	  	=>	l_object_version_number
  );
  --
  hr_utility.set_location('Entering: call - create_election_information_a', 50);
  --
   begin
hr_elections_api_bk1.create_election_information_a
  (p_effective_date                =>   l_effective_date
  ,p_business_group_id             =>   p_business_group_id
  ,p_election_date		   =>	p_election_date
  ,p_description		   =>   p_description
  ,p_rep_body_id                   =>   p_rep_body_id
  ,p_previous_election_date        =>   p_previous_election_date
  ,p_next_election_date            =>   p_next_election_date
  ,p_result_publish_date           =>   p_result_publish_date
  ,p_attribute_category            =>   p_attribute_category
  ,p_attribute1                    =>   p_attribute1
  ,p_attribute2                    =>   p_attribute2
  ,p_attribute3                    =>   p_attribute3
  ,p_attribute4                    =>   p_attribute4
  ,p_attribute5                    =>   p_attribute5
  ,p_attribute6                    =>   p_attribute6
  ,p_attribute7                    =>   p_attribute7
  ,p_attribute8                    =>   p_attribute8
  ,p_attribute9                    =>   p_attribute9
  ,p_attribute10                   =>   p_attribute10
  ,p_attribute11                   =>   p_attribute11
  ,p_attribute12                   =>   p_attribute12
  ,p_attribute13                   =>   p_attribute13
  ,p_attribute14                   =>   p_attribute14
  ,p_attribute15                   =>   p_attribute15
  ,p_attribute16                   =>   p_attribute16
  ,p_attribute17                   =>   p_attribute17
  ,p_attribute18                   =>   p_attribute18
  ,p_attribute19                   =>   p_attribute19
  ,p_attribute20                   =>   p_attribute20
  ,p_attribute21                   =>   p_attribute21
  ,p_attribute22                   =>   p_attribute22
  ,p_attribute23                   =>   p_attribute23
  ,p_attribute24                   =>   p_attribute24
  ,p_attribute25                   =>   p_attribute25
  ,p_attribute26                   =>   p_attribute26
  ,p_attribute27                   =>   p_attribute27
  ,p_attribute28                   =>   p_attribute28
  ,p_attribute29                   =>   p_attribute29
  ,p_attribute30                   =>   p_attribute30
  ,p_election_info_category 		=>   p_election_info_category
  ,p_election_information1         =>   p_election_information1
  ,p_election_information2         =>   p_election_information2
  ,p_election_information3         =>   p_election_information3
  ,p_election_information4         =>   p_election_information4
  ,p_election_information5         =>   p_election_information5
  ,p_election_information6         =>   p_election_information6
  ,p_election_information7         =>   p_election_information7
  ,p_election_information8         =>   p_election_information8
  ,p_election_information9         =>   p_election_information9
  ,p_election_information10        =>   p_election_information10
  ,p_election_information11        =>   p_election_information11
  ,p_election_information12        =>   p_election_information12
  ,p_election_information13        =>   p_election_information13
  ,p_election_information14        =>   p_election_information14
  ,p_election_information15        =>   p_election_information15
  ,p_election_information16        =>   p_election_information16
  ,p_election_information17        =>   p_election_information17
  ,p_election_information18        =>   p_election_information18
  ,p_election_information19        =>   p_election_information19
  ,p_election_information20        =>   p_election_information20
  ,p_election_information21        =>   p_election_information21
  ,p_election_information22        =>   p_election_information22
  ,p_election_information23        =>   p_election_information23
  ,p_election_information24        =>   p_election_information24
  ,p_election_information25        =>   p_election_information25
  ,p_election_information26        =>   p_election_information26
  ,p_election_information27        =>   p_election_information27
  ,p_election_information28        =>   p_election_information28
  ,p_election_information29        =>   p_election_information29
  ,p_election_information30        =>   p_election_information30
  ,p_election_id		   =>	l_election_id
  ,p_object_version_number	   =>	l_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELECTION_INFORMATION'
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
  p_election_id            := l_election_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_election_information;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_election_id                     := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_election_information;
    --
    -- set in out parameters and set out parameters
    --
    p_election_id                     := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_election_information;
--

-- ----------------------------------------------------------------------------
-- |---------------------< update_election_information >----------------------|
-- ----------------------------------------------------------------------------
--

procedure update_election_information
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_election_id                   in out nocopy number
  ,p_business_group_id             in     number
  ,p_election_date                 in     date
  ,p_description                   in     varchar2
  ,p_rep_body_id                   in     number
  ,p_previous_election_date        in     date     default hr_api.g_date
  ,p_next_election_date            in     date     default hr_api.g_date
  ,p_result_publish_date           in     date     default hr_api.g_date
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
  ,p_election_info_category        in     varchar2 default hr_api.g_varchar2
  ,p_election_information1         in     varchar2 default hr_api.g_varchar2
  ,p_election_information2         in     varchar2 default hr_api.g_varchar2
  ,p_election_information3         in     varchar2 default hr_api.g_varchar2
  ,p_election_information4         in     varchar2 default hr_api.g_varchar2
  ,p_election_information5         in     varchar2 default hr_api.g_varchar2
  ,p_election_information6         in     varchar2 default hr_api.g_varchar2
  ,p_election_information7         in     varchar2 default hr_api.g_varchar2
  ,p_election_information8         in     varchar2 default hr_api.g_varchar2
  ,p_election_information9         in     varchar2 default hr_api.g_varchar2
  ,p_election_information10        in     varchar2 default hr_api.g_varchar2
  ,p_election_information11        in     varchar2 default hr_api.g_varchar2
  ,p_election_information12        in     varchar2 default hr_api.g_varchar2
  ,p_election_information13        in     varchar2 default hr_api.g_varchar2
  ,p_election_information14        in     varchar2 default hr_api.g_varchar2
  ,p_election_information15        in     varchar2 default hr_api.g_varchar2
  ,p_election_information16        in     varchar2 default hr_api.g_varchar2
  ,p_election_information17        in     varchar2 default hr_api.g_varchar2
  ,p_election_information18        in     varchar2 default hr_api.g_varchar2
  ,p_election_information19        in     varchar2 default hr_api.g_varchar2
  ,p_election_information20        in     varchar2 default hr_api.g_varchar2
  ,p_election_information21        in     varchar2 default hr_api.g_varchar2
  ,p_election_information22        in     varchar2 default hr_api.g_varchar2
  ,p_election_information23        in     varchar2 default hr_api.g_varchar2
  ,p_election_information24        in     varchar2 default hr_api.g_varchar2
  ,p_election_information25        in     varchar2 default hr_api.g_varchar2
  ,p_election_information26        in     varchar2 default hr_api.g_varchar2
  ,p_election_information27        in     varchar2 default hr_api.g_varchar2
  ,p_election_information28        in     varchar2 default hr_api.g_varchar2
  ,p_election_information29        in     varchar2 default hr_api.g_varchar2
  ,p_election_information30        in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
   l_object_version_number per_elections.object_version_number%TYPE;
   l_ovn per_elections.object_version_number%TYPE := p_object_version_number;
  --
  -- Declare out parameters
  l_effective_date              date;
  --
  l_proc                varchar2(72) := g_package||'update_election_information';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_election_information;
  --
  -- Check that p_rep_body_id, p_business_group_id, election_date are not null.
  --
  hr_utility.set_location('Entering mandatory arg check', 20);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'rep_body_id',
     p_argument_value => p_rep_body_id);
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
     p_argument       => 'election_date',
     p_argument_value => p_election_date);
  --
  l_effective_date := trunc(p_effective_date);
  --
  hr_utility.set_location('Entering: call - update_election_information_b ', 30);
  --
  begin

hr_elections_api_bk2.update_election_information_b
  (p_effective_date                =>   l_effective_date
  ,p_business_group_id             =>   p_business_group_id
  ,p_election_id		   =>	p_election_id
  ,p_election_date		   =>	p_election_date
  ,p_description		   =>   p_description
  ,p_rep_body_id                   =>   p_rep_body_id
  ,p_previous_election_date        =>   p_previous_election_date
  ,p_next_election_date            =>   p_next_election_date
  ,p_result_publish_date           =>   p_result_publish_date
  ,p_attribute_category            =>   p_attribute_category
  ,p_attribute1                    =>   p_attribute1
  ,p_attribute2                    =>   p_attribute2
  ,p_attribute3                    =>   p_attribute3
  ,p_attribute4                    =>   p_attribute4
  ,p_attribute5                    =>   p_attribute5
  ,p_attribute6                    =>   p_attribute6
  ,p_attribute7                    =>   p_attribute7
  ,p_attribute8                    =>   p_attribute8
  ,p_attribute9                    =>   p_attribute9
  ,p_attribute10                   =>   p_attribute10
  ,p_attribute11                   =>   p_attribute11
  ,p_attribute12                   =>   p_attribute12
  ,p_attribute13                   =>   p_attribute13
  ,p_attribute14                   =>   p_attribute14
  ,p_attribute15                   =>   p_attribute15
  ,p_attribute16                   =>   p_attribute16
  ,p_attribute17                   =>   p_attribute17
  ,p_attribute18                   =>   p_attribute18
  ,p_attribute19                   =>   p_attribute19
  ,p_attribute20                   =>   p_attribute20
  ,p_attribute21                   =>   p_attribute21
  ,p_attribute22                   =>   p_attribute22
  ,p_attribute23                   =>   p_attribute23
  ,p_attribute24                   =>   p_attribute24
  ,p_attribute25                   =>   p_attribute25
  ,p_attribute26                   =>   p_attribute26
  ,p_attribute27                   =>   p_attribute27
  ,p_attribute28                   =>   p_attribute28
  ,p_attribute29                   =>   p_attribute29
  ,p_attribute30                   =>   p_attribute30
  ,p_election_info_category 		=>   p_election_info_category
  ,p_election_information1         =>   p_election_information1
  ,p_election_information2         =>   p_election_information2
  ,p_election_information3         =>   p_election_information3
  ,p_election_information4         =>   p_election_information4
  ,p_election_information5         =>   p_election_information5
  ,p_election_information6         =>   p_election_information6
  ,p_election_information7         =>   p_election_information7
  ,p_election_information8         =>   p_election_information8
  ,p_election_information9         =>   p_election_information9
  ,p_election_information10        =>   p_election_information10
  ,p_election_information11        =>   p_election_information11
  ,p_election_information12        =>   p_election_information12
  ,p_election_information13        =>   p_election_information13
  ,p_election_information14        =>   p_election_information14
  ,p_election_information15        =>   p_election_information15
  ,p_election_information16        =>   p_election_information16
  ,p_election_information17        =>   p_election_information17
  ,p_election_information18        =>   p_election_information18
  ,p_election_information19        =>   p_election_information19
  ,p_election_information20        =>   p_election_information20
  ,p_election_information21        =>   p_election_information21
  ,p_election_information22        =>   p_election_information22
  ,p_election_information23        =>   p_election_information23
  ,p_election_information24        =>   p_election_information24
  ,p_election_information25        =>   p_election_information25
  ,p_election_information26        =>   p_election_information26
  ,p_election_information27        =>   p_election_information27
  ,p_election_information28        =>   p_election_information28
  ,p_election_information29        =>   p_election_information29
  ,p_election_information30        =>   p_election_information30
  ,p_object_version_number	   =>	p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELECTION_INFORMATION'
        ,p_hook_type   => 'BP'
        );

  end;
  --
  hr_utility.set_location('Entering: call - per_elc_upd.upd ', 40);
  --
  l_object_version_number := p_object_version_number;
  --
  --
  per_elc_upd.upd
  (p_effective_date                =>   l_effective_date
  ,p_validate                      =>   FALSE
  ,p_election_id                   =>   p_election_id
  ,p_object_version_number         =>   p_object_version_number
  ,p_business_group_id             =>   p_business_group_id
  ,p_election_date                 =>   p_election_date
  ,p_description		   =>   p_description
  ,p_rep_body_id                   =>   p_rep_body_id
  ,p_previous_election_date        =>   p_previous_election_date
  ,p_next_election_date            =>   p_next_election_date
  ,p_result_publish_date           =>   p_result_publish_date
  ,p_attribute_category            =>   p_attribute_category
  ,p_attribute1                    =>   p_attribute1
  ,p_attribute2                    =>   p_attribute2
  ,p_attribute3                    =>   p_attribute3
  ,p_attribute4                    =>   p_attribute4
  ,p_attribute5                    =>   p_attribute5
  ,p_attribute6                    =>   p_attribute6
  ,p_attribute7                    =>   p_attribute7
  ,p_attribute8                    =>   p_attribute8
  ,p_attribute9                    =>   p_attribute9
  ,p_attribute10                   =>   p_attribute10
  ,p_attribute11                   =>   p_attribute11
  ,p_attribute12                   =>   p_attribute12
  ,p_attribute13                   =>   p_attribute13
  ,p_attribute14                   =>   p_attribute14
  ,p_attribute15                   =>   p_attribute15
  ,p_attribute16                   =>   p_attribute16
  ,p_attribute17                   =>   p_attribute17
  ,p_attribute18                   =>   p_attribute18
  ,p_attribute19                   =>   p_attribute19
  ,p_attribute20                   =>   p_attribute20
  ,p_attribute21                   =>   p_attribute21
  ,p_attribute22                   =>   p_attribute22
  ,p_attribute23                   =>   p_attribute23
  ,p_attribute24                   =>   p_attribute24
  ,p_attribute25                   =>   p_attribute25
  ,p_attribute26                   =>   p_attribute26
  ,p_attribute27                   =>   p_attribute27
  ,p_attribute28                   =>   p_attribute28
  ,p_attribute29                   =>   p_attribute29
  ,p_attribute30                   =>   p_attribute30
  ,p_election_info_category 		=>   p_election_info_category
  ,p_election_information1         =>   p_election_information1
  ,p_election_information2         =>   p_election_information2
  ,p_election_information3         =>   p_election_information3
  ,p_election_information4         =>   p_election_information4
  ,p_election_information5         =>   p_election_information5
  ,p_election_information6         =>   p_election_information6
  ,p_election_information7         =>   p_election_information7
  ,p_election_information8         =>   p_election_information8
  ,p_election_information9         =>   p_election_information9
  ,p_election_information10        =>   p_election_information10
  ,p_election_information11        =>   p_election_information11
  ,p_election_information12        =>   p_election_information12
  ,p_election_information13        =>   p_election_information13
  ,p_election_information14        =>   p_election_information14
  ,p_election_information15        =>   p_election_information15
  ,p_election_information16        =>   p_election_information16
  ,p_election_information17        =>   p_election_information17
  ,p_election_information18        =>   p_election_information18
  ,p_election_information19        =>   p_election_information19
  ,p_election_information20        =>   p_election_information20
  ,p_election_information21        =>   p_election_information21
  ,p_election_information22        =>   p_election_information22
  ,p_election_information23        =>   p_election_information23
  ,p_election_information24        =>   p_election_information24
  ,p_election_information25        =>   p_election_information25
  ,p_election_information26        =>   p_election_information26
  ,p_election_information27        =>   p_election_information27
  ,p_election_information28        =>   p_election_information28
  ,p_election_information29        =>   p_election_information29
  ,p_election_information30        =>   p_election_information30
  );
  --
  hr_utility.set_location('Entering: call - update_election_information_a', 50);
  --
  begin
  --
hr_elections_api_bk2.update_election_information_a
  (p_effective_date                =>   l_effective_date
  ,p_election_id                   =>   p_election_id
  ,p_object_version_number         =>   p_object_version_number
  ,p_business_group_id             =>   p_business_group_id
  ,p_election_date                 =>   p_election_date
  ,p_description		   =>   p_description
  ,p_rep_body_id                   =>   p_rep_body_id
  ,p_previous_election_date        =>   p_previous_election_date
  ,p_next_election_date            =>   p_next_election_date
  ,p_result_publish_date           =>   p_result_publish_date
  ,p_attribute_category            =>   p_attribute_category
  ,p_attribute1                    =>   p_attribute1
  ,p_attribute2                    =>   p_attribute2
  ,p_attribute3                    =>   p_attribute3
  ,p_attribute4                    =>   p_attribute4
  ,p_attribute5                    =>   p_attribute5
  ,p_attribute6                    =>   p_attribute6
  ,p_attribute7                    =>   p_attribute7
  ,p_attribute8                    =>   p_attribute8
  ,p_attribute9                    =>   p_attribute9
  ,p_attribute10                   =>   p_attribute10
  ,p_attribute11                   =>   p_attribute11
  ,p_attribute12                   =>   p_attribute12
  ,p_attribute13                   =>   p_attribute13
  ,p_attribute14                   =>   p_attribute14
  ,p_attribute15                   =>   p_attribute15
  ,p_attribute16                   =>   p_attribute16
  ,p_attribute17                   =>   p_attribute17
  ,p_attribute18                   =>   p_attribute18
  ,p_attribute19                   =>   p_attribute19
  ,p_attribute20                   =>   p_attribute20
  ,p_attribute21                   =>   p_attribute21
  ,p_attribute22                   =>   p_attribute22
  ,p_attribute23                   =>   p_attribute23
  ,p_attribute24                   =>   p_attribute24
  ,p_attribute25                   =>   p_attribute25
  ,p_attribute26                   =>   p_attribute26
  ,p_attribute27                   =>   p_attribute27
  ,p_attribute28                   =>   p_attribute28
  ,p_attribute29                   =>   p_attribute29
  ,p_attribute30                   =>   p_attribute30
  ,p_election_info_category 		=>   p_election_info_category
  ,p_election_information1         =>   p_election_information1
  ,p_election_information2         =>   p_election_information2
  ,p_election_information3         =>   p_election_information3
  ,p_election_information4         =>   p_election_information4
  ,p_election_information5         =>   p_election_information5
  ,p_election_information6         =>   p_election_information6
  ,p_election_information7         =>   p_election_information7
  ,p_election_information8         =>   p_election_information8
  ,p_election_information9         =>   p_election_information9
  ,p_election_information10        =>   p_election_information10
  ,p_election_information11        =>   p_election_information11
  ,p_election_information12        =>   p_election_information12
  ,p_election_information13        =>   p_election_information13
  ,p_election_information14        =>   p_election_information14
  ,p_election_information15        =>   p_election_information15
  ,p_election_information16        =>   p_election_information16
  ,p_election_information17        =>   p_election_information17
  ,p_election_information18        =>   p_election_information18
  ,p_election_information19        =>   p_election_information19
  ,p_election_information20        =>   p_election_information20
  ,p_election_information21        =>   p_election_information21
  ,p_election_information22        =>   p_election_information22
  ,p_election_information23        =>   p_election_information23
  ,p_election_information24        =>   p_election_information24
  ,p_election_information25        =>   p_election_information25
  ,p_election_information26        =>   p_election_information26
  ,p_election_information27        =>   p_election_information27
  ,p_election_information28        =>   p_election_information28
  ,p_election_information29        =>   p_election_information29
  ,p_election_information30        =>   p_election_information30
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELECTION_INFORMATION'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_election_information;
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
    rollback to update_election_information;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number  := l_ovn;
    p_election_id 	     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_election_information;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_election_information >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_election_information
  (p_validate                       in     boolean  default false
  ,p_election_id		    		 in 	   number
  ,p_object_version_number          in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := (g_package||'delete_election_information');
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_election_information;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_election_information
    --
    hr_elections_api_bk3.delete_election_information_b
      (
       p_election_id                    =>  p_election_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_election_information'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_election_information
    --
  end;
  --
  per_elc_del.del
    (
     p_election_id                   => p_election_id
    ,p_validate			       => p_validate
    ,p_object_version_number         => p_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_election_information
    --
    hr_elections_api_bk3.delete_election_information_a
      (
       p_election_id                    =>  p_election_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_election_information'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_election_information
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
    ROLLBACK TO delete_election_information;
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
    ROLLBACK TO delete_election_information;
    raise;
    --
end delete_election_information;
--
--
end hr_elections_api;

/
