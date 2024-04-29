--------------------------------------------------------
--  DDL for Package Body HR_PERSON_ABSENCE_CASE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_ABSENCE_CASE_API" as
/* $Header: peabcapi.pkb 120.1 2006/01/27 12:46:38 snukala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_person_absence_case_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_person_absence_case >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_absence_case
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_name                          in     varchar2
  ,p_business_group_id             in     number
  ,p_incident_id                   in     number   default null
  ,p_absence_category              in     varchar2 default null
  ,p_ac_attribute_category         in     varchar2 default null
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
  ,p_ac_information_category       in     varchar2 default null
  ,p_ac_information1               in     varchar2 default null
  ,p_ac_information2               in     varchar2 default null
  ,p_ac_information3               in     varchar2 default null
  ,p_ac_information4               in     varchar2 default null
  ,p_ac_information5               in     varchar2 default null
  ,p_ac_information6               in     varchar2 default null
  ,p_ac_information7               in     varchar2 default null
  ,p_ac_information8               in     varchar2 default null
  ,p_ac_information9               in     varchar2 default null
  ,p_ac_information10              in     varchar2 default null
  ,p_ac_information11              in     varchar2 default null
  ,p_ac_information12              in     varchar2 default null
  ,p_ac_information13              in     varchar2 default null
  ,p_ac_information14              in     varchar2 default null
  ,p_ac_information15              in     varchar2 default null
  ,p_ac_information16              in     varchar2 default null
  ,p_ac_information17              in     varchar2 default null
  ,p_ac_information18              in     varchar2 default null
  ,p_ac_information19              in     varchar2 default null
  ,p_ac_information20              in     varchar2 default null
  ,p_ac_information21              in     varchar2 default null
  ,p_ac_information22              in     varchar2 default null
  ,p_ac_information23              in     varchar2 default null
  ,p_ac_information24              in     varchar2 default null
  ,p_ac_information25              in     varchar2 default null
  ,p_ac_information26              in     varchar2 default null
  ,p_ac_information27              in     varchar2 default null
  ,p_ac_information28              in     varchar2 default null
  ,p_ac_information29              in     varchar2 default null
  ,p_ac_information30              in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_absence_case_id               out    nocopy    number
  ,p_object_version_number         out    nocopy    number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_person_absence_case';
  l_exists                   number;
  l_occurrence               number;
  l_input_value_id           number;
  --
  -- Declare out parameters
  --
  l_absence_case_id            number;
  l_object_version_number      number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Create a savepoint.
  --
  savepoint create_person_absence_case;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --  NO DATE IN PARAMS AT THIS TIME  - REVIEW AND REMOVE LATER
  --
  -- Call Before Process User Hook
  --
  begin
    hr_person_absence_case_bk1.create_person_absence_case_b
  (p_person_id                      =>   p_person_id
  ,p_name                           =>   p_name
  ,p_business_group_id              =>   p_business_group_id
  ,p_incident_id                    =>   p_incident_id
  ,p_absence_category               =>   p_absence_category
  ,p_ac_attribute_category          =>   p_ac_attribute_category
  ,p_attribute1                     =>   p_attribute1
  ,p_attribute2                     =>   p_attribute2
  ,p_attribute3                     =>   p_attribute3
  ,p_attribute4                     =>   p_attribute4
  ,p_attribute5                     =>   p_attribute5
  ,p_attribute6                     =>   p_attribute6
  ,p_attribute7                     =>   p_attribute7
  ,p_attribute8                     =>   p_attribute8
  ,p_attribute9                     =>   p_attribute9
  ,p_attribute10                    =>   p_attribute10
  ,p_attribute11                    =>   p_attribute11
  ,p_attribute12                    =>   p_attribute12
  ,p_attribute13                    =>   p_attribute13
  ,p_attribute14                    =>   p_attribute14
  ,p_attribute15                    =>   p_attribute15
  ,p_attribute16                    =>   p_attribute16
  ,p_attribute17                    =>   p_attribute17
  ,p_attribute18                    =>   p_attribute18
  ,p_attribute19                    =>   p_attribute19
  ,p_attribute20                    =>   p_attribute20
  ,p_attribute21                    =>   p_attribute21
  ,p_attribute22                    =>   p_attribute22
  ,p_attribute23                    =>   p_attribute23
  ,p_attribute24                    =>   p_attribute24
  ,p_attribute25                    =>   p_attribute25
  ,p_attribute26                    =>   p_attribute26
  ,p_attribute27                    =>   p_attribute27
  ,p_attribute28                    =>   p_attribute28
  ,p_attribute29                    =>   p_attribute29
  ,p_attribute30                    =>   p_attribute30
  ,p_ac_information_category        =>   p_ac_information_category
  ,p_ac_information1                =>   p_ac_information1
  ,p_ac_information2                =>   p_ac_information2
  ,p_ac_information3                =>   p_ac_information3
  ,p_ac_information4                =>   p_ac_information4
  ,p_ac_information5                =>   p_ac_information5
  ,p_ac_information6                =>   p_ac_information6
  ,p_ac_information7                =>   p_ac_information7
  ,p_ac_information8                =>   p_ac_information8
  ,p_ac_information9                =>   p_ac_information9
  ,p_ac_information10               =>   p_ac_information10
  ,p_ac_information11               =>   p_ac_information11
  ,p_ac_information12               =>   p_ac_information12
  ,p_ac_information13               =>   p_ac_information13
  ,p_ac_information14               =>   p_ac_information14
  ,p_ac_information15               =>   p_ac_information15
  ,p_ac_information16               =>   p_ac_information16
  ,p_ac_information17               =>   p_ac_information17
  ,p_ac_information18               =>   p_ac_information18
  ,p_ac_information19               =>   p_ac_information19
  ,p_ac_information20               =>   p_ac_information20
  ,p_ac_information21               =>   p_ac_information21
  ,p_ac_information22               =>   p_ac_information22
  ,p_ac_information23               =>   p_ac_information23
  ,p_ac_information24               =>   p_ac_information24
  ,p_ac_information25               =>   p_ac_information25
  ,p_ac_information26               =>   p_ac_information26
  ,p_ac_information27               =>   p_ac_information27
  ,p_ac_information28               =>   p_ac_information28
  ,p_ac_information29               =>   p_ac_information29
  ,p_ac_information30               =>   p_ac_information30
  ,p_comments                       =>   p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_ABSENCE_CASE'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Insert Person Absence Case
  per_abc_ins.ins
  (p_name                            =>   p_name
  ,p_person_id                       =>   p_person_id
  ,p_business_group_id               =>   p_business_group_id
  ,p_incident_id                     =>   p_incident_id
  ,p_absence_category                =>   p_absence_category
  ,p_ac_information_category         =>   p_ac_information_category
  ,p_ac_information1                 =>   p_ac_information1
  ,p_ac_information2                 =>   p_ac_information2
  ,p_ac_information3                 =>   p_ac_information3
  ,p_ac_information4                 =>   p_ac_information4
  ,p_ac_information5                 =>   p_ac_information5
  ,p_ac_information6                 =>   p_ac_information6
  ,p_ac_information7                 =>   p_ac_information7
  ,p_ac_information8                 =>   p_ac_information8
  ,p_ac_information9                 =>   p_ac_information9
  ,p_ac_information10                =>   p_ac_information10
  ,p_ac_information11                =>   p_ac_information11
  ,p_ac_information12                =>   p_ac_information12
  ,p_ac_information13                =>   p_ac_information13
  ,p_ac_information14                =>   p_ac_information14
  ,p_ac_information15                =>   p_ac_information15
  ,p_ac_information16                =>   p_ac_information16
  ,p_ac_information17                =>   p_ac_information17
  ,p_ac_information18                =>   p_ac_information18
  ,p_ac_information19                =>   p_ac_information19
  ,p_ac_information20                =>   p_ac_information20
  ,p_ac_information21                =>   p_ac_information21
  ,p_ac_information22                =>   p_ac_information22
  ,p_ac_information23                =>   p_ac_information23
  ,p_ac_information24                =>   p_ac_information24
  ,p_ac_information25                =>   p_ac_information25
  ,p_ac_information26                =>   p_ac_information26
  ,p_ac_information27                =>   p_ac_information27
  ,p_ac_information28                =>   p_ac_information28
  ,p_ac_information29                =>   p_ac_information29
  ,p_ac_information30                =>   p_ac_information30
  ,p_ac_attribute_category           =>   p_ac_attribute_category
  ,p_attribute1                      =>   p_attribute1
  ,p_attribute2                      =>   p_attribute2
  ,p_attribute3                      =>   p_attribute3
  ,p_attribute4                      =>   p_attribute4
  ,p_attribute5                      =>   p_attribute5
  ,p_attribute6                      =>   p_attribute6
  ,p_attribute7                      =>   p_attribute7
  ,p_attribute8                      =>   p_attribute8
  ,p_attribute9                      =>   p_attribute9
  ,p_attribute10                     =>   p_attribute10
  ,p_attribute11                     =>   p_attribute11
  ,p_attribute12                     =>   p_attribute12
  ,p_attribute13                     =>   p_attribute13
  ,p_attribute14                     =>   p_attribute14
  ,p_attribute15                     =>   p_attribute15
  ,p_attribute16                     =>   p_attribute16
  ,p_attribute17                     =>   p_attribute17
  ,p_attribute18                     =>   p_attribute18
  ,p_attribute19                     =>   p_attribute19
  ,p_attribute20                     =>   p_attribute20
  ,p_attribute21                     =>   p_attribute21
  ,p_attribute22                     =>   p_attribute22
  ,p_attribute23                     =>   p_attribute23
  ,p_attribute24                     =>   p_attribute24
  ,p_attribute25                     =>   p_attribute25
  ,p_attribute26                     =>   p_attribute26
  ,p_attribute27                     =>   p_attribute27
  ,p_attribute28                     =>   p_attribute28
  ,p_attribute29                     =>   p_attribute29
  ,p_attribute30                     =>   p_attribute30
  ,p_comments                        =>   p_comments
  ,p_absence_case_id                 =>   l_absence_case_id
  ,p_object_version_number           =>   l_object_version_number
  );

  --
  -- Call After Process User Hook
  --

  begin
    hr_person_absence_case_bk1.create_person_absence_case_a
      (p_person_id                     => p_person_id
      ,p_name                          => p_name
      ,p_business_group_id             => p_business_group_id
      ,p_incident_id                   => p_incident_id
      ,p_absence_category              => p_absence_category
      ,p_ac_attribute_category         => p_ac_attribute_category
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
      ,p_ac_information_category       => p_ac_information_category
      ,p_ac_information1               => p_ac_information1
      ,p_ac_information2               => p_ac_information2
      ,p_ac_information3               => p_ac_information3
      ,p_ac_information4               => p_ac_information4
      ,p_ac_information5               => p_ac_information5
      ,p_ac_information6               => p_ac_information6
      ,p_ac_information7               => p_ac_information7
      ,p_ac_information8               => p_ac_information8
      ,p_ac_information9               => p_ac_information9
      ,p_ac_information10              => p_ac_information10
      ,p_ac_information11              => p_ac_information11
      ,p_ac_information12              => p_ac_information12
      ,p_ac_information13              => p_ac_information13
      ,p_ac_information14              => p_ac_information14
      ,p_ac_information15              => p_ac_information15
      ,p_ac_information16              => p_ac_information16
      ,p_ac_information17              => p_ac_information17
      ,p_ac_information18              => p_ac_information18
      ,p_ac_information19              => p_ac_information19
      ,p_ac_information20              => p_ac_information20
      ,p_ac_information21              => p_ac_information21
      ,p_ac_information22              => p_ac_information22
      ,p_ac_information23              => p_ac_information23
      ,p_ac_information24              => p_ac_information24
      ,p_ac_information25              => p_ac_information25
      ,p_ac_information26              => p_ac_information26
      ,p_ac_information27              => p_ac_information27
      ,p_ac_information28              => p_ac_information28
      ,p_ac_information29              => p_ac_information29
      ,p_ac_information30              => p_ac_information30
      ,p_comments                      => p_comments
      ,p_absence_case_id               => l_absence_case_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_ABSENCE_CASE'
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
  p_absence_case_id        := l_absence_case_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_person_absence_case;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_absence_case_id        := null;
    p_object_version_number  := null;
    hr_utility.set_location(l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_absence_case_id               := null;
    p_object_version_number         := null;

    rollback to create_person_absence_case;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_person_absence_case;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_person_absence_case >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_absence_case
  (p_validate                      in     boolean  default false
  ,p_absence_case_id               in     number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_incident_id                   in     number   default hr_api.g_number
  ,p_absence_category              in     varchar2 default null
  ,p_ac_attribute_category         in     varchar2 default hr_api.g_varchar2
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
  ,p_ac_information_category       in     varchar2 default hr_api.g_varchar2
  ,p_ac_information1               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information2               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information3               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information4               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information5               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information6               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information7               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information8               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information9               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information10              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information11              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information12              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information13              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information14              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information15              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information16              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information17              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information18              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information19              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information20              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information21              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information22              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information23              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information24              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information25              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information26              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information27              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information28              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information29              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information30              in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_person_absence_case';
  --
  lv_object_version_number      number;
  -- Declare out parameters
  --
  l_object_version_number      number;
  --

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  lv_object_version_number      := p_object_version_number ;
  -- Issue a savepoint
  --
  savepoint update_person_absence_case;

  --
  -- Truncate the time portion from all IN date parameters
  --
  -- AS OF NOW NO DATE TYPE PARAMS TO TRUNCATE - REMOVE THIS LINE LATER.
  --
  -- Call Before Process User Hook
  --
  begin
    hr_person_absence_case_bk2.update_person_absence_case_b
      (p_absence_case_id               => p_absence_case_id
      ,p_object_version_number         => p_object_version_number
      ,p_name                          => p_name
      ,p_incident_id                   => p_incident_id
      ,p_absence_category              => p_absence_category
      ,p_ac_attribute_category         => p_ac_attribute_category
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
      ,p_ac_information_category       => p_ac_information_category
      ,p_ac_information1               => p_ac_information1
      ,p_ac_information2               => p_ac_information2
      ,p_ac_information3               => p_ac_information3
      ,p_ac_information4               => p_ac_information4
      ,p_ac_information5               => p_ac_information5
      ,p_ac_information6               => p_ac_information6
      ,p_ac_information7               => p_ac_information7
      ,p_ac_information8               => p_ac_information8
      ,p_ac_information9               => p_ac_information9
      ,p_ac_information10              => p_ac_information10
      ,p_ac_information11              => p_ac_information11
      ,p_ac_information12              => p_ac_information12
      ,p_ac_information13              => p_ac_information13
      ,p_ac_information14              => p_ac_information14
      ,p_ac_information15              => p_ac_information15
      ,p_ac_information16              => p_ac_information16
      ,p_ac_information17              => p_ac_information17
      ,p_ac_information18              => p_ac_information18
      ,p_ac_information19              => p_ac_information19
      ,p_ac_information20              => p_ac_information20
      ,p_ac_information21              => p_ac_information21
      ,p_ac_information22              => p_ac_information22
      ,p_ac_information23              => p_ac_information23
      ,p_ac_information24              => p_ac_information24
      ,p_ac_information25              => p_ac_information25
      ,p_ac_information26              => p_ac_information26
      ,p_ac_information27              => p_ac_information27
      ,p_ac_information28              => p_ac_information28
      ,p_ac_information29              => p_ac_information29
      ,p_ac_information30              => p_ac_information30
      ,p_comments                      => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_ABSENCE'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  hr_utility.set_location(l_proc, 30);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Update Person Absence
  per_abc_upd.upd
  (p_absence_case_id              =>   p_absence_case_id
  ,p_object_version_number        =>   l_object_version_number
  ,p_name                         =>   p_name
  ,p_incident_id                  =>   p_incident_id
  ,p_absence_category             =>   p_absence_category
  ,p_ac_information_category      =>   p_ac_information_category
  ,p_ac_information1              =>   p_ac_information1
  ,p_ac_information2              =>   p_ac_information2
  ,p_ac_information3              =>   p_ac_information3
  ,p_ac_information4              =>   p_ac_information4
  ,p_ac_information5              =>   p_ac_information5
  ,p_ac_information6              =>   p_ac_information6
  ,p_ac_information7              =>   p_ac_information7
  ,p_ac_information8              =>   p_ac_information8
  ,p_ac_information9              =>   p_ac_information9
  ,p_ac_information10             =>   p_ac_information10
  ,p_ac_information11             =>   p_ac_information11
  ,p_ac_information12             =>   p_ac_information12
  ,p_ac_information13             =>   p_ac_information13
  ,p_ac_information14             =>   p_ac_information14
  ,p_ac_information15             =>   p_ac_information15
  ,p_ac_information16             =>   p_ac_information16
  ,p_ac_information17             =>   p_ac_information17
  ,p_ac_information18             =>   p_ac_information18
  ,p_ac_information19             =>   p_ac_information19
  ,p_ac_information20             =>   p_ac_information20
  ,p_ac_information21             =>   p_ac_information21
  ,p_ac_information22             =>   p_ac_information22
  ,p_ac_information23             =>   p_ac_information23
  ,p_ac_information24             =>   p_ac_information24
  ,p_ac_information25             =>   p_ac_information25
  ,p_ac_information26             =>   p_ac_information26
  ,p_ac_information27             =>   p_ac_information27
  ,p_ac_information28             =>   p_ac_information28
  ,p_ac_information29             =>   p_ac_information29
  ,p_ac_information30             =>   p_ac_information30
  ,p_ac_attribute_category        =>   p_ac_attribute_category
  ,p_attribute1                   =>   p_attribute1
  ,p_attribute2                   =>   p_attribute2
  ,p_attribute3                   =>   p_attribute3
  ,p_attribute4                   =>   p_attribute4
  ,p_attribute5                   =>   p_attribute5
  ,p_attribute6                   =>   p_attribute6
  ,p_attribute7                   =>   p_attribute7
  ,p_attribute8                   =>   p_attribute8
  ,p_attribute9                   =>   p_attribute9
  ,p_attribute10                  =>   p_attribute10
  ,p_attribute11                  =>   p_attribute11
  ,p_attribute12                  =>   p_attribute12
  ,p_attribute13                  =>   p_attribute13
  ,p_attribute14                  =>   p_attribute14
  ,p_attribute15                  =>   p_attribute15
  ,p_attribute16                  =>   p_attribute16
  ,p_attribute17                  =>   p_attribute17
  ,p_attribute18                  =>   p_attribute18
  ,p_attribute19                  =>   p_attribute19
  ,p_attribute20                  =>   p_attribute20
  ,p_attribute21                  =>   p_attribute21
  ,p_attribute22                  =>   p_attribute22
  ,p_attribute23                  =>   p_attribute23
  ,p_attribute24                  =>   p_attribute24
  ,p_attribute25                  =>   p_attribute25
  ,p_attribute26                  =>   p_attribute26
  ,p_attribute27                  =>   p_attribute27
  ,p_attribute28                  =>   p_attribute28
  ,p_attribute29                  =>   p_attribute29
  ,p_attribute30                  =>   p_attribute30
  ,p_comments                     =>   p_comments
  );

  --
  -- Assign the out parameters.
  --

  p_object_version_number     := l_object_version_number;

  --
  -- Call After Process User Hook
  --
  begin
    hr_person_absence_case_bk2.update_person_absence_case_a
      (p_absence_case_id               => p_absence_case_id
      ,p_object_version_number         => l_object_version_number
      ,p_name                          => p_name
      ,p_incident_id                   => p_incident_id
      ,p_absence_category              => p_absence_category
      ,p_ac_attribute_category         => p_ac_attribute_category
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
      ,p_ac_information_category       => p_ac_information_category
      ,p_ac_information1               => p_ac_information1
      ,p_ac_information2               => p_ac_information2
      ,p_ac_information3               => p_ac_information3
      ,p_ac_information4               => p_ac_information4
      ,p_ac_information5               => p_ac_information5
      ,p_ac_information6               => p_ac_information6
      ,p_ac_information7               => p_ac_information7
      ,p_ac_information8               => p_ac_information8
      ,p_ac_information9               => p_ac_information9
      ,p_ac_information10              => p_ac_information10
      ,p_ac_information11              => p_ac_information11
      ,p_ac_information12              => p_ac_information12
      ,p_ac_information13              => p_ac_information13
      ,p_ac_information14              => p_ac_information14
      ,p_ac_information15              => p_ac_information15
      ,p_ac_information16              => p_ac_information16
      ,p_ac_information17              => p_ac_information17
      ,p_ac_information18              => p_ac_information18
      ,p_ac_information19              => p_ac_information19
      ,p_ac_information20              => p_ac_information20
      ,p_ac_information21              => p_ac_information21
      ,p_ac_information22              => p_ac_information22
      ,p_ac_information23              => p_ac_information23
      ,p_ac_information24              => p_ac_information24
      ,p_ac_information25              => p_ac_information25
      ,p_ac_information26              => p_ac_information26
      ,p_ac_information27              => p_ac_information27
      ,p_ac_information28              => p_ac_information28
      ,p_ac_information29              => p_ac_information29
      ,p_ac_information30              => p_ac_information30
      ,p_comments                      => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_ABSENCE_CASE'
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
  hr_utility.set_location(' Leaving:'||l_proc, 90);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_person_absence_case;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 100);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number      := lv_object_version_number ;

    rollback to update_person_absence_case;
    hr_utility.set_location(' Leaving:'||l_proc, 110);
    raise;
end update_person_absence_case;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_person_absence_case >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_absence_case
  (p_validate                      in     boolean default false
  ,p_absence_case_id               in     number
  ,p_object_version_number         in     number
  ) is

  l_proc                     varchar2(72) := g_package||'delete_person_absence_case';
  l_exists                   number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_person_absence_case;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_person_absence_case_bk3.delete_person_absence_case_b
      (p_absence_case_id               => p_absence_case_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_ABSENCE_CASE'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Delete Person Absence Case
  --

  per_abc_del.del
  (p_absence_case_id                =>   p_absence_case_id
  ,p_object_version_number          =>   p_object_version_number
  );

  --
  -- Update Person Absence Attendances to remove link to Case record.
  --
  hr_utility.set_location(l_proc, 48);

    update per_absence_attendances
    set absence_case_id = null
    where absence_case_id =p_absence_case_id;

  hr_utility.set_location(l_proc, 50);

  --
  -- Call After Process User Hook
  --

  begin
    hr_person_absence_case_bk3.delete_person_absence_case_a
      (p_absence_case_id               => p_absence_case_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_ABSENCE_CASE'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_person_absence_case;
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
    rollback to delete_person_absence_case;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
--
end delete_person_absence_case;

--
end hr_person_absence_case_api;

/
