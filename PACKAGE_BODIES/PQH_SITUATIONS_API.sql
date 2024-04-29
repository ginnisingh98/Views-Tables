--------------------------------------------------------
--  DDL for Package Body PQH_SITUATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SITUATIONS_API" as
/* $Header: pqlosapi.pkb 115.1 2002/12/03 00:08:02 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_SITUATIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<  create_situation  >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_situation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_situation                      in     varchar2
  ,p_effective_start_date           in     date
  ,p_business_group_id              in     number
  ,p_situation_type                 in     varchar2
  ,p_length_of_service              in     varchar2
  ,p_effective_end_date             in     date     default null
  ,p_employee_type                  in     varchar2 default null
  ,p_entitlement_flag               in     varchar2 default null
  ,p_worktime_proportional          in     varchar2 default null
  ,p_entitlement_value              in     number   default null
  ,p_information_category           in     varchar2 default null
  ,p_information1                   in     varchar2 default null
  ,p_information2                   in     varchar2 default null
  ,p_information3                   in     varchar2 default null
  ,p_information4                   in     varchar2 default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     varchar2 default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_situation_id                   out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'CREATE_SITUATION';
  l_situation_id           pqh_situations.situation_id%TYPE;
  l_object_version_number  pqh_situations.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_SITUATION;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_SITUATIONS_BK1.create_situation_b
      (p_effective_date                => p_effective_date
      ,p_situation                     => p_situation
      ,p_effective_start_date          => p_effective_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_situation_type                => p_situation_type
      ,p_length_of_service             => p_length_of_service
      ,p_effective_end_date            => p_effective_end_date
      ,p_employee_type                 => p_employee_type
      ,p_entitlement_flag              => p_entitlement_flag
      ,p_worktime_proportional         => p_worktime_proportional
      ,p_entitlement_value             => p_entitlement_value
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
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SITUATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqh_los_ins.ins
      (p_effective_date                => p_effective_date
      ,p_situation                     => p_situation
      ,p_effective_start_date          => p_effective_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_situation_type                => p_situation_type
      ,p_length_of_service             => p_length_of_service
      ,p_effective_end_date            => p_effective_end_date
      ,p_employee_type                 => p_employee_type
      ,p_entitlement_flag              => p_entitlement_flag
      ,p_worktime_proportional         => p_worktime_proportional
      ,p_entitlement_value             => p_entitlement_value
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
      ,p_situation_id                  => l_situation_id
      ,p_object_version_number         => l_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_SITUATIONS_BK1.create_situation_a
      (p_effective_date                => p_effective_date
      ,p_situation                     => p_situation
      ,p_effective_start_date          => p_effective_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_situation_type                => p_situation_type
      ,p_length_of_service             => p_length_of_service
      ,p_effective_end_date            => p_effective_end_date
      ,p_employee_type                 => p_employee_type
      ,p_entitlement_flag              => p_entitlement_flag
      ,p_worktime_proportional         => p_worktime_proportional
      ,p_entitlement_value             => p_entitlement_value
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
      ,p_situation_id                  => l_situation_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SITUATION'
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
  p_situation_id           := l_situation_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_SITUATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_situation_id           := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    p_situation_id           := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_SITUATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_situation;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------<  update_situation  >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_situation
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_situation_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_situation                    in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         in     date      default hr_api.g_date
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_situation_type               in     varchar2  default hr_api.g_varchar2
  ,p_length_of_service            in     varchar2  default hr_api.g_varchar2
  ,p_effective_end_date           in     date      default hr_api.g_date
  ,p_employee_type                in     varchar2  default hr_api.g_varchar2
  ,p_entitlement_flag             in     varchar2  default hr_api.g_varchar2
  ,p_worktime_proportional        in     varchar2  default hr_api.g_varchar2
  ,p_entitlement_value            in     number    default hr_api.g_number
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
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'UPDATE_SITUATION';
  l_object_version_number number := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_SITUATION;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_SITUATIONS_BK2.update_situation_b
      (p_effective_date                => p_effective_date
      ,p_situation                     => p_situation
      ,p_effective_start_date          => p_effective_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_situation_type                => p_situation_type
      ,p_length_of_service             => p_length_of_service
      ,p_effective_end_date            => p_effective_end_date
      ,p_employee_type                 => p_employee_type
      ,p_entitlement_flag              => p_entitlement_flag
      ,p_worktime_proportional         => p_worktime_proportional
      ,p_entitlement_value             => p_entitlement_value
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
      ,p_situation_id                  => p_situation_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SITUATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqh_los_upd.upd
      (p_effective_date                => p_effective_date
      ,p_situation                     => p_situation
      ,p_effective_start_date          => p_effective_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_situation_type                => p_situation_type
      ,p_length_of_service             => p_length_of_service
      ,p_effective_end_date            => p_effective_end_date
      ,p_employee_type                 => p_employee_type
      ,p_entitlement_flag              => p_entitlement_flag
      ,p_worktime_proportional         => p_worktime_proportional
      ,p_entitlement_value             => p_entitlement_value
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
      ,p_situation_id                  => p_situation_id
      ,p_object_version_number         => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_SITUATIONS_BK2.update_situation_a
      (p_effective_date                => p_effective_date
      ,p_situation                     => p_situation
      ,p_effective_start_date          => p_effective_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_situation_type                => p_situation_type
      ,p_length_of_service             => p_length_of_service
      ,p_effective_end_date            => p_effective_end_date
      ,p_employee_type                 => p_employee_type
      ,p_entitlement_flag              => p_entitlement_flag
      ,p_worktime_proportional         => p_worktime_proportional
      ,p_entitlement_value             => p_entitlement_value
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
      ,p_situation_id                  => p_situation_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SITUATION'
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
  p_object_version_number  := p_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_SITUATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_SITUATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_situation;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------<  delete_situation  >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_situation
  (p_validate                     in     boolean  default false
  ,p_situation_id                 in     number
  ,p_object_version_number        in     number
   ) is
  --
  -- Declare cursors and local variables
  --

  l_proc      varchar2(72) := g_package||'DELETE_SITUATION';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_SITUATION;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_SITUATIONS_BK3.delete_situation_b
      (p_situation_id                  => p_situation_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SITUATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqh_los_del.del
      (p_situation_id                  => p_situation_id
      ,p_object_version_number         => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_SITUATIONS_BK3.delete_situation_a
      (p_situation_id                  => p_situation_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SITUATION'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_SITUATION;
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
    rollback to DELETE_SITUATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_situation;
--
end pqh_situations_api;

/
