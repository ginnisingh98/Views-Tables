--------------------------------------------------------
--  DDL for Package Body PQP_PCV_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PCV_API" as
/* $Header: pqpcvapi.pkb 120.0 2005/05/29 01:54:57 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqp_pcv_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_configuration_value >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_configuration_value
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2 default null
  ,p_pcv_attribute_category         in     varchar2 default null
  ,p_pcv_attribute1                 in     varchar2 default null
  ,p_pcv_attribute2                 in     varchar2 default null
  ,p_pcv_attribute3                 in     varchar2 default null
  ,p_pcv_attribute4                 in     varchar2 default null
  ,p_pcv_attribute5                 in     varchar2 default null
  ,p_pcv_attribute6                 in     varchar2 default null
  ,p_pcv_attribute7                 in     varchar2 default null
  ,p_pcv_attribute8                 in     varchar2 default null
  ,p_pcv_attribute9                 in     varchar2 default null
  ,p_pcv_attribute10                in     varchar2 default null
  ,p_pcv_attribute11                in     varchar2 default null
  ,p_pcv_attribute12                in     varchar2 default null
  ,p_pcv_attribute13                in     varchar2 default null
  ,p_pcv_attribute14                in     varchar2 default null
  ,p_pcv_attribute15                in     varchar2 default null
  ,p_pcv_attribute16                in     varchar2 default null
  ,p_pcv_attribute17                in     varchar2 default null
  ,p_pcv_attribute18                in     varchar2 default null
  ,p_pcv_attribute19                in     varchar2 default null
  ,p_pcv_attribute20                in     varchar2 default null
  ,p_pcv_information_category       in     varchar2 default null
  ,p_pcv_information1               in     varchar2 default null
  ,p_pcv_information2               in     varchar2 default null
  ,p_pcv_information3               in     varchar2 default null
  ,p_pcv_information4               in     varchar2 default null
  ,p_pcv_information5               in     varchar2 default null
  ,p_pcv_information6               in     varchar2 default null
  ,p_pcv_information7               in     varchar2 default null
  ,p_pcv_information8               in     varchar2 default null
  ,p_pcv_information9               in     varchar2 default null
  ,p_pcv_information10              in     varchar2 default null
  ,p_pcv_information11              in     varchar2 default null
  ,p_pcv_information12              in     varchar2 default null
  ,p_pcv_information13              in     varchar2 default null
  ,p_pcv_information14              in     varchar2 default null
  ,p_pcv_information15              in     varchar2 default null
  ,p_pcv_information16              in     varchar2 default null
  ,p_pcv_information17              in     varchar2 default null
  ,p_pcv_information18              in     varchar2 default null
  ,p_pcv_information19              in     varchar2 default null
  ,p_pcv_information20              in     varchar2 default null
  ,p_configuration_value_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_configuration_name             in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_configuration_value_id number;
  l_object_version_number  number;
  l_effective_date         date;
  l_proc                varchar2(72) := g_package||'create_configuration_value';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_configuration_value;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
   l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --

  begin
    pqp_pcv_bk1.create_configuration_value_b
      (p_configuration_value_id         =>     l_configuration_value_id
      ,p_effective_date                 =>     l_effective_date
      ,p_object_version_number          =>     l_object_version_number
      ,p_business_group_id              =>     p_business_group_id
      ,p_legislation_code               =>     p_legislation_code
      ,p_pcv_attribute_category         =>     p_pcv_attribute_category
      ,p_pcv_attribute1                 =>     p_pcv_attribute1
      ,p_pcv_attribute2                 =>     p_pcv_attribute2
      ,p_pcv_attribute3                 =>     p_pcv_attribute3
      ,p_pcv_attribute4                 =>     p_pcv_attribute4
      ,p_pcv_attribute5                 =>     p_pcv_attribute5
      ,p_pcv_attribute6                 =>     p_pcv_attribute6
      ,p_pcv_attribute7                 =>     p_pcv_attribute7
      ,p_pcv_attribute8                 =>     p_pcv_attribute8
      ,p_pcv_attribute9                 =>     p_pcv_attribute9
      ,p_pcv_attribute10                =>     p_pcv_attribute10
      ,p_pcv_attribute11                =>     p_pcv_attribute11
      ,p_pcv_attribute12                =>     p_pcv_attribute12
      ,p_pcv_attribute13                =>     p_pcv_attribute13
      ,p_pcv_attribute14                =>     p_pcv_attribute14
      ,p_pcv_attribute15                =>     p_pcv_attribute15
      ,p_pcv_attribute16                =>     p_pcv_attribute16
      ,p_pcv_attribute17                =>     p_pcv_attribute17
      ,p_pcv_attribute18                =>     p_pcv_attribute18
      ,p_pcv_attribute19                =>     p_pcv_attribute19
      ,p_pcv_attribute20                =>     p_pcv_attribute20
      ,p_pcv_information_category       =>     p_pcv_information_category
      ,p_pcv_information1               =>     p_pcv_information1
      ,p_pcv_information2               =>     p_pcv_information2
      ,p_pcv_information3               =>     p_pcv_information3
      ,p_pcv_information4               =>     p_pcv_information4
      ,p_pcv_information5               =>     p_pcv_information5
      ,p_pcv_information6               =>     p_pcv_information6
      ,p_pcv_information7               =>     p_pcv_information7
      ,p_pcv_information8               =>     p_pcv_information8
      ,p_pcv_information9               =>     p_pcv_information9
      ,p_pcv_information10              =>     p_pcv_information10
      ,p_pcv_information11              =>     p_pcv_information11
      ,p_pcv_information12              =>     p_pcv_information12
      ,p_pcv_information13              =>     p_pcv_information13
      ,p_pcv_information14              =>     p_pcv_information14
      ,p_pcv_information15              =>     p_pcv_information15
      ,p_pcv_information16              =>     p_pcv_information16
      ,p_pcv_information17              =>     p_pcv_information17
      ,p_pcv_information18              =>     p_pcv_information18
      ,p_pcv_information19              =>     p_pcv_information19
      ,p_pcv_information20              =>     p_pcv_information20
      ,p_configuration_name		=>     p_configuration_name

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_configuration_value'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqp_pcv_ins.ins
      (p_business_group_id              =>     p_business_group_id
      ,p_effective_date                 =>     l_effective_date
      ,p_legislation_code               =>     p_legislation_code
      ,p_pcv_attribute_category         =>     p_pcv_attribute_category
      ,p_pcv_attribute1                 =>     p_pcv_attribute1
      ,p_pcv_attribute2                 =>     p_pcv_attribute2
      ,p_pcv_attribute3                 =>     p_pcv_attribute3
      ,p_pcv_attribute4                 =>     p_pcv_attribute4
      ,p_pcv_attribute5                 =>     p_pcv_attribute5
      ,p_pcv_attribute6                 =>     p_pcv_attribute6
      ,p_pcv_attribute7                 =>     p_pcv_attribute7
      ,p_pcv_attribute8                 =>     p_pcv_attribute8
      ,p_pcv_attribute9                 =>     p_pcv_attribute9
      ,p_pcv_attribute10                =>     p_pcv_attribute10
      ,p_pcv_attribute11                =>     p_pcv_attribute11
      ,p_pcv_attribute12                =>     p_pcv_attribute12
      ,p_pcv_attribute13                =>     p_pcv_attribute13
      ,p_pcv_attribute14                =>     p_pcv_attribute14
      ,p_pcv_attribute15                =>     p_pcv_attribute15
      ,p_pcv_attribute16                =>     p_pcv_attribute16
      ,p_pcv_attribute17                =>     p_pcv_attribute17
      ,p_pcv_attribute18                =>     p_pcv_attribute18
      ,p_pcv_attribute19                =>     p_pcv_attribute19
      ,p_pcv_attribute20                =>     p_pcv_attribute20
      ,p_pcv_information_category       =>     p_pcv_information_category
      ,p_pcv_information1               =>     p_pcv_information1
      ,p_pcv_information2               =>     p_pcv_information2
      ,p_pcv_information3               =>     p_pcv_information3
      ,p_pcv_information4               =>     p_pcv_information4
      ,p_pcv_information5               =>     p_pcv_information5
      ,p_pcv_information6               =>     p_pcv_information6
      ,p_pcv_information7               =>     p_pcv_information7
      ,p_pcv_information8               =>     p_pcv_information8
      ,p_pcv_information9               =>     p_pcv_information9
      ,p_pcv_information10              =>     p_pcv_information10
      ,p_pcv_information11              =>     p_pcv_information11
      ,p_pcv_information12              =>     p_pcv_information12
      ,p_pcv_information13              =>     p_pcv_information13
      ,p_pcv_information14              =>     p_pcv_information14
      ,p_pcv_information15              =>     p_pcv_information15
      ,p_pcv_information16              =>     p_pcv_information16
      ,p_pcv_information17              =>     p_pcv_information17
      ,p_pcv_information18              =>     p_pcv_information18
      ,p_pcv_information19              =>     p_pcv_information19
      ,p_pcv_information20              =>     p_pcv_information20
      ,p_configuration_value_id         =>     l_configuration_value_id
      ,p_object_version_number          =>     l_object_version_number
      ,p_configuration_name		=>     p_configuration_name
      );

  --
  -- Call After Process User Hook
  --
  begin
    pqp_pcv_bk1.create_configuration_value_a
      (p_configuration_value_id         =>     l_configuration_value_id
      ,p_effective_date                 =>     l_effective_date
      ,p_object_version_number          =>     l_object_version_number
      ,p_business_group_id              =>     p_business_group_id
      ,p_legislation_code               =>     p_legislation_code
      ,p_pcv_attribute_category         =>     p_pcv_attribute_category
      ,p_pcv_attribute1                 =>     p_pcv_attribute1
      ,p_pcv_attribute2                 =>     p_pcv_attribute2
      ,p_pcv_attribute3                 =>     p_pcv_attribute3
      ,p_pcv_attribute4                 =>     p_pcv_attribute4
      ,p_pcv_attribute5                 =>     p_pcv_attribute5
      ,p_pcv_attribute6                 =>     p_pcv_attribute6
      ,p_pcv_attribute7                 =>     p_pcv_attribute7
      ,p_pcv_attribute8                 =>     p_pcv_attribute8
      ,p_pcv_attribute9                 =>     p_pcv_attribute9
      ,p_pcv_attribute10                =>     p_pcv_attribute10
      ,p_pcv_attribute11                =>     p_pcv_attribute11
      ,p_pcv_attribute12                =>     p_pcv_attribute12
      ,p_pcv_attribute13                =>     p_pcv_attribute13
      ,p_pcv_attribute14                =>     p_pcv_attribute14
      ,p_pcv_attribute15                =>     p_pcv_attribute15
      ,p_pcv_attribute16                =>     p_pcv_attribute16
      ,p_pcv_attribute17                =>     p_pcv_attribute17
      ,p_pcv_attribute18                =>     p_pcv_attribute18
      ,p_pcv_attribute19                =>     p_pcv_attribute19
      ,p_pcv_attribute20                =>     p_pcv_attribute20
      ,p_pcv_information_category       =>     p_pcv_information_category
      ,p_pcv_information1               =>     p_pcv_information1
      ,p_pcv_information2               =>     p_pcv_information2
      ,p_pcv_information3               =>     p_pcv_information3
      ,p_pcv_information4               =>     p_pcv_information4
      ,p_pcv_information5               =>     p_pcv_information5
      ,p_pcv_information6               =>     p_pcv_information6
      ,p_pcv_information7               =>     p_pcv_information7
      ,p_pcv_information8               =>     p_pcv_information8
      ,p_pcv_information9               =>     p_pcv_information9
      ,p_pcv_information10              =>     p_pcv_information10
      ,p_pcv_information11              =>     p_pcv_information11
      ,p_pcv_information12              =>     p_pcv_information12
      ,p_pcv_information13              =>     p_pcv_information13
      ,p_pcv_information14              =>     p_pcv_information14
      ,p_pcv_information15              =>     p_pcv_information15
      ,p_pcv_information16              =>     p_pcv_information16
      ,p_pcv_information17              =>     p_pcv_information17
      ,p_pcv_information18              =>     p_pcv_information18
      ,p_pcv_information19              =>     p_pcv_information19
      ,p_pcv_information20              =>     p_pcv_information20
      ,p_configuration_name		=>     p_configuration_name

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_configuration_value'
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
  p_configuration_value_id := l_configuration_value_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_configuration_value;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_configuration_value_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_configuration_value;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_configuration_value_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_configuration_value;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_configuration_value >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_configuration_value
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_configuration_value_id         in     number
  ,p_legislation_code               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute_category         in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute1                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute2                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute3                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute4                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute5                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute6                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute7                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute8                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute9                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute10                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute11                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute12                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute13                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute14                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute15                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute16                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute17                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute18                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute19                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute20                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information_category       in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information1               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information2               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information3               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information4               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information5               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information6               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information7               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information8               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information9               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information10              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information11              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information12              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information13              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information14              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information15              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information16              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information17              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information18              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information19              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information20              in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_configuration_name             in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  number;
  l_effective_date         date;
  l_proc                varchar2(72) := g_package||'update_configuration_value';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_configuration_value;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pqp_pcv_bk2.update_configuration_value_b
      (p_configuration_value_id         =>     p_configuration_value_id
      ,p_effective_date                 =>     l_effective_date
      ,p_object_version_number          =>     l_object_version_number
      ,p_business_group_id              =>     p_business_group_id
      ,p_legislation_code               =>     p_legislation_code
      ,p_pcv_attribute_category         =>     p_pcv_attribute_category
      ,p_pcv_attribute1                 =>     p_pcv_attribute1
      ,p_pcv_attribute2                 =>     p_pcv_attribute2
      ,p_pcv_attribute3                 =>     p_pcv_attribute3
      ,p_pcv_attribute4                 =>     p_pcv_attribute4
      ,p_pcv_attribute5                 =>     p_pcv_attribute5
      ,p_pcv_attribute6                 =>     p_pcv_attribute6
      ,p_pcv_attribute7                 =>     p_pcv_attribute7
      ,p_pcv_attribute8                 =>     p_pcv_attribute8
      ,p_pcv_attribute9                 =>     p_pcv_attribute9
      ,p_pcv_attribute10                =>     p_pcv_attribute10
      ,p_pcv_attribute11                =>     p_pcv_attribute11
      ,p_pcv_attribute12                =>     p_pcv_attribute12
      ,p_pcv_attribute13                =>     p_pcv_attribute13
      ,p_pcv_attribute14                =>     p_pcv_attribute14
      ,p_pcv_attribute15                =>     p_pcv_attribute15
      ,p_pcv_attribute16                =>     p_pcv_attribute16
      ,p_pcv_attribute17                =>     p_pcv_attribute17
      ,p_pcv_attribute18                =>     p_pcv_attribute18
      ,p_pcv_attribute19                =>     p_pcv_attribute19
      ,p_pcv_attribute20                =>     p_pcv_attribute20
      ,p_pcv_information_category       =>     p_pcv_information_category
      ,p_pcv_information1               =>     p_pcv_information1
      ,p_pcv_information2               =>     p_pcv_information2
      ,p_pcv_information3               =>     p_pcv_information3
      ,p_pcv_information4               =>     p_pcv_information4
      ,p_pcv_information5               =>     p_pcv_information5
      ,p_pcv_information6               =>     p_pcv_information6
      ,p_pcv_information7               =>     p_pcv_information7
      ,p_pcv_information8               =>     p_pcv_information8
      ,p_pcv_information9               =>     p_pcv_information9
      ,p_pcv_information10              =>     p_pcv_information10
      ,p_pcv_information11              =>     p_pcv_information11
      ,p_pcv_information12              =>     p_pcv_information12
      ,p_pcv_information13              =>     p_pcv_information13
      ,p_pcv_information14              =>     p_pcv_information14
      ,p_pcv_information15              =>     p_pcv_information15
      ,p_pcv_information16              =>     p_pcv_information16
      ,p_pcv_information17              =>     p_pcv_information17
      ,p_pcv_information18              =>     p_pcv_information18
      ,p_pcv_information19              =>     p_pcv_information19
      ,p_pcv_information20              =>     p_pcv_information20
      ,p_configuration_name		=>     p_configuration_name

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_configuration_value'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqp_pcv_upd.upd
      (p_configuration_value_id         =>     p_configuration_value_id
      ,p_effective_date                 =>     l_effective_date
      ,p_object_version_number          =>     l_object_version_number
      ,p_business_group_id              =>     p_business_group_id
      ,p_legislation_code               =>     p_legislation_code
      ,p_pcv_attribute_category         =>     p_pcv_attribute_category
      ,p_pcv_attribute1                 =>     p_pcv_attribute1
      ,p_pcv_attribute2                 =>     p_pcv_attribute2
      ,p_pcv_attribute3                 =>     p_pcv_attribute3
      ,p_pcv_attribute4                 =>     p_pcv_attribute4
      ,p_pcv_attribute5                 =>     p_pcv_attribute5
      ,p_pcv_attribute6                 =>     p_pcv_attribute6
      ,p_pcv_attribute7                 =>     p_pcv_attribute7
      ,p_pcv_attribute8                 =>     p_pcv_attribute8
      ,p_pcv_attribute9                 =>     p_pcv_attribute9
      ,p_pcv_attribute10                =>     p_pcv_attribute10
      ,p_pcv_attribute11                =>     p_pcv_attribute11
      ,p_pcv_attribute12                =>     p_pcv_attribute12
      ,p_pcv_attribute13                =>     p_pcv_attribute13
      ,p_pcv_attribute14                =>     p_pcv_attribute14
      ,p_pcv_attribute15                =>     p_pcv_attribute15
      ,p_pcv_attribute16                =>     p_pcv_attribute16
      ,p_pcv_attribute17                =>     p_pcv_attribute17
      ,p_pcv_attribute18                =>     p_pcv_attribute18
      ,p_pcv_attribute19                =>     p_pcv_attribute19
      ,p_pcv_attribute20                =>     p_pcv_attribute20
      ,p_pcv_information_category       =>     p_pcv_information_category
      ,p_pcv_information1               =>     p_pcv_information1
      ,p_pcv_information2               =>     p_pcv_information2
      ,p_pcv_information3               =>     p_pcv_information3
      ,p_pcv_information4               =>     p_pcv_information4
      ,p_pcv_information5               =>     p_pcv_information5
      ,p_pcv_information6               =>     p_pcv_information6
      ,p_pcv_information7               =>     p_pcv_information7
      ,p_pcv_information8               =>     p_pcv_information8
      ,p_pcv_information9               =>     p_pcv_information9
      ,p_pcv_information10              =>     p_pcv_information10
      ,p_pcv_information11              =>     p_pcv_information11
      ,p_pcv_information12              =>     p_pcv_information12
      ,p_pcv_information13              =>     p_pcv_information13
      ,p_pcv_information14              =>     p_pcv_information14
      ,p_pcv_information15              =>     p_pcv_information15
      ,p_pcv_information16              =>     p_pcv_information16
      ,p_pcv_information17              =>     p_pcv_information17
      ,p_pcv_information18              =>     p_pcv_information18
      ,p_pcv_information19              =>     p_pcv_information19
      ,p_pcv_information20              =>     p_pcv_information20
      ,p_configuration_name             =>     p_configuration_name
      );

  --
  -- Call After Process User Hook
  --
  begin
    pqp_pcv_bk2.update_configuration_value_a
      (p_configuration_value_id         =>     p_configuration_value_id
      ,p_effective_date                 =>     l_effective_date
      ,p_object_version_number          =>     l_object_version_number
      ,p_business_group_id              =>     p_business_group_id
      ,p_legislation_code               =>     p_legislation_code
      ,p_pcv_attribute_category         =>     p_pcv_attribute_category
      ,p_pcv_attribute1                 =>     p_pcv_attribute1
      ,p_pcv_attribute2                 =>     p_pcv_attribute2
      ,p_pcv_attribute3                 =>     p_pcv_attribute3
      ,p_pcv_attribute4                 =>     p_pcv_attribute4
      ,p_pcv_attribute5                 =>     p_pcv_attribute5
      ,p_pcv_attribute6                 =>     p_pcv_attribute6
      ,p_pcv_attribute7                 =>     p_pcv_attribute7
      ,p_pcv_attribute8                 =>     p_pcv_attribute8
      ,p_pcv_attribute9                 =>     p_pcv_attribute9
      ,p_pcv_attribute10                =>     p_pcv_attribute10
      ,p_pcv_attribute11                =>     p_pcv_attribute11
      ,p_pcv_attribute12                =>     p_pcv_attribute12
      ,p_pcv_attribute13                =>     p_pcv_attribute13
      ,p_pcv_attribute14                =>     p_pcv_attribute14
      ,p_pcv_attribute15                =>     p_pcv_attribute15
      ,p_pcv_attribute16                =>     p_pcv_attribute16
      ,p_pcv_attribute17                =>     p_pcv_attribute17
      ,p_pcv_attribute18                =>     p_pcv_attribute18
      ,p_pcv_attribute19                =>     p_pcv_attribute19
      ,p_pcv_attribute20                =>     p_pcv_attribute20
      ,p_pcv_information_category       =>     p_pcv_information_category
      ,p_pcv_information1               =>     p_pcv_information1
      ,p_pcv_information2               =>     p_pcv_information2
      ,p_pcv_information3               =>     p_pcv_information3
      ,p_pcv_information4               =>     p_pcv_information4
      ,p_pcv_information5               =>     p_pcv_information5
      ,p_pcv_information6               =>     p_pcv_information6
      ,p_pcv_information7               =>     p_pcv_information7
      ,p_pcv_information8               =>     p_pcv_information8
      ,p_pcv_information9               =>     p_pcv_information9
      ,p_pcv_information10              =>     p_pcv_information10
      ,p_pcv_information11              =>     p_pcv_information11
      ,p_pcv_information12              =>     p_pcv_information12
      ,p_pcv_information13              =>     p_pcv_information13
      ,p_pcv_information14              =>     p_pcv_information14
      ,p_pcv_information15              =>     p_pcv_information15
      ,p_pcv_information16              =>     p_pcv_information16
      ,p_pcv_information17              =>     p_pcv_information17
      ,p_pcv_information18              =>     p_pcv_information18
      ,p_pcv_information19              =>     p_pcv_information19
      ,p_pcv_information20              =>     p_pcv_information20
      ,p_configuration_name		=>     p_configuration_name

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_configuration_value'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_configuration_value;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_configuration_value;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_configuration_value;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_configuration_value >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_configuration_value
  (p_validate                       in     boolean  default false
  ,p_business_group_id              in     number
  ,p_configuration_value_id         in     number
  ,p_object_version_number          in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  number;
  l_proc                varchar2(72) := g_package||'delete_configuration_value';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_configuration_value;
  --
  -- Remember IN OUT parameter IN values
  --
  -- l_in_out_parameter := p_in_out_parameter;

  --
  -- Call Before Process User Hook
  --
  begin
    pqp_pcv_bk3.delete_configuration_value_b
      (p_configuration_value_id         =>     p_configuration_value_id
      ,p_object_version_number          =>     p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_configuration_value'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqp_pcv_del.del
      (p_configuration_value_id         =>     p_configuration_value_id
      ,p_object_version_number          =>     p_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    pqp_pcv_bk3.delete_configuration_value_a
      (p_configuration_value_id         =>     p_configuration_value_id
      ,p_object_version_number          =>     p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_configuration_value'
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
  -- p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_configuration_value;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_configuration_value;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    -- p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_configuration_value;
--
end pqp_pcv_api;

/
