--------------------------------------------------------
--  DDL for Package Body OTA_RESOURCE_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RESOURCE_USAGE_API" as
/* $Header: otrudapi.pkb 115.1 2003/12/30 19:10:38 dhmulia noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_RESOURCE_USAGE_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Create_resource >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure Create_resource
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_activity_version_id            in     number  default null
  ,p_required_flag                  in     varchar2
  ,p_start_date                     in     date
  ,p_supplied_resource_id           in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_end_date                       in     date     default null
  ,p_quantity                       in     number   default null
  ,p_resource_type                  in     varchar2 default null
  ,p_role_to_play                   in     varchar2 default null
  ,p_usage_reason                   in     varchar2 default null
  ,p_rud_information_category       in     varchar2 default null
  ,p_rud_information1               in     varchar2 default null
  ,p_rud_information2               in     varchar2 default null
  ,p_rud_information3               in     varchar2 default null
  ,p_rud_information4               in     varchar2 default null
  ,p_rud_information5               in     varchar2 default null
  ,p_rud_information6               in     varchar2 default null
  ,p_rud_information7               in     varchar2 default null
  ,p_rud_information8               in     varchar2 default null
  ,p_rud_information9               in     varchar2 default null
  ,p_rud_information10              in     varchar2 default null
  ,p_rud_information11              in     varchar2 default null
  ,p_rud_information12              in     varchar2 default null
  ,p_rud_information13              in     varchar2 default null
  ,p_rud_information14              in     varchar2 default null
  ,p_rud_information15              in     varchar2 default null
  ,p_rud_information16              in     varchar2 default null
  ,p_rud_information17              in     varchar2 default null
  ,p_rud_information18              in     varchar2 default null
  ,p_rud_information19              in     varchar2 default null
  ,p_rud_information20              in     varchar2 default null
  ,p_resource_usage_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_offering_id                    in     number   default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'Create_resource';
  l_resource_usage_id number;
  l_object_version_number   number;
  l_effective_date          date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_RESOURCE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    ota_resource_usage_bk1.Create_resource_b
  (p_effective_date                   	       => l_effective_date
  ,p_activity_version_id           	       => p_activity_version_id
  ,p_required_flag                 	       => p_required_flag
  ,p_start_date                    	       => p_start_date
  ,p_supplied_resource_id          	       => p_supplied_resource_id
  ,p_comments                      	       => p_comments
  ,p_end_date                                  => p_end_date
  ,p_quantity                                  => p_quantity
  ,p_resource_type                             => p_resource_type
  ,p_role_to_play                              => p_role_to_play
  ,p_usage_reason                              => p_usage_reason
  ,p_rud_information_category                  => p_rud_information_category
  ,p_rud_information1                          => p_rud_information1
  ,p_rud_information2                          => p_rud_information2
  ,p_rud_information3                          => p_rud_information3
  ,p_rud_information4                          => p_rud_information4
  ,p_rud_information5                          => p_rud_information5
  ,p_rud_information6                          => p_rud_information6
  ,p_rud_information7                          => p_rud_information7
  ,p_rud_information8                          => p_rud_information8
  ,p_rud_information9                          => p_rud_information9
  ,p_rud_information10                         => p_rud_information10
  ,p_rud_information11                         => p_rud_information11
  ,p_rud_information12                         => p_rud_information12
  ,p_rud_information13                         => p_rud_information13
  ,p_rud_information14                         => p_rud_information14
  ,p_rud_information15                         => p_rud_information15
  ,p_rud_information16                         => p_rud_information16
  ,p_rud_information17                         => p_rud_information17
  ,p_rud_information18                         => p_rud_information18
  ,p_rud_information19             	       => p_rud_information19
  ,p_rud_information20             	       => p_rud_information20
  ,p_offering_id                           => p_offering_id
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RESOURCE'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic (Base table)
  --
  ota_rud_ins.ins
  (p_effective_date              => l_effective_date
  ,p_activity_version_id         => p_activity_version_id
  ,p_required_flag               => p_required_flag
  ,p_start_date                  => p_start_date
  ,p_supplied_resource_id        => p_supplied_resource_id
  ,p_comments                    => p_comments
  ,p_end_date                    => p_end_date
  ,p_quantity                    => p_quantity
  ,p_resource_type               => p_resource_type
  ,p_role_to_play                => p_role_to_play
  ,p_usage_reason                => p_usage_reason
  ,p_rud_information_category    => p_rud_information_category
  ,p_rud_information1            => p_rud_information1
  ,p_rud_information2            => p_rud_information2
  ,p_rud_information3            => p_rud_information3
  ,p_rud_information4            => p_rud_information4
  ,p_rud_information5            => p_rud_information5
  ,p_rud_information6            => p_rud_information6
  ,p_rud_information7            => p_rud_information7
  ,p_rud_information8            => p_rud_information8
  ,p_rud_information9            => p_rud_information9
  ,p_rud_information10           => p_rud_information10
  ,p_rud_information11           => p_rud_information11
  ,p_rud_information12           => p_rud_information12
  ,p_rud_information13           => p_rud_information13
  ,p_rud_information14           => p_rud_information14
  ,p_rud_information15           => p_rud_information15
  ,p_rud_information16           => p_rud_information16
  ,p_rud_information17           => p_rud_information17
  ,p_rud_information18           => p_rud_information18
  ,p_rud_information19           => p_rud_information19
  ,p_rud_information20           => p_rud_information20
  ,p_resource_usage_id           => l_resource_usage_id
  ,p_object_version_number       => l_object_version_number
  ,p_offering_id                 => p_offering_id
  );

  --
  -- Call After Process User Hook
  --

  begin
  ota_resource_usage_bk1.Create_resource_a
  (p_effective_date              => l_effective_date
  ,p_activity_version_id         => p_activity_version_id
  ,p_required_flag               => p_required_flag
  ,p_start_date                  => p_start_date
  ,p_supplied_resource_id        => p_supplied_resource_id
  ,p_comments                    => p_comments
  ,p_end_date                    => p_end_date
  ,p_quantity                    => p_quantity
  ,p_resource_type               => p_resource_type
  ,p_role_to_play                => p_role_to_play
  ,p_usage_reason                => p_usage_reason
  ,p_rud_information_category    => p_rud_information_category
  ,p_rud_information1            => p_rud_information1
  ,p_rud_information2            => p_rud_information2
  ,p_rud_information3            => p_rud_information3
  ,p_rud_information4            => p_rud_information4
  ,p_rud_information5            => p_rud_information5
  ,p_rud_information6            => p_rud_information6
  ,p_rud_information7            => p_rud_information7
  ,p_rud_information8            => p_rud_information8
  ,p_rud_information9            => p_rud_information9
  ,p_rud_information10           => p_rud_information10
  ,p_rud_information11           => p_rud_information11
  ,p_rud_information12           => p_rud_information12
  ,p_rud_information13           => p_rud_information13
  ,p_rud_information14           => p_rud_information14
  ,p_rud_information15           => p_rud_information15
  ,p_rud_information16           => p_rud_information16
  ,p_rud_information17           => p_rud_information17
  ,p_rud_information18           => p_rud_information18
  ,p_rud_information19           => p_rud_information19
  ,p_rud_information20           => p_rud_information20
  ,p_resource_usage_id           => l_resource_usage_id
  ,p_object_version_number       => l_object_version_number
  ,p_offering_id                 => p_offering_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RESOURCE'
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
  p_resource_usage_id        := l_resource_usage_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_RESOURCE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_resource_usage_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_RESOURCE;
    p_resource_usage_id        := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Create_resource;
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_resource >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_resource
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_resource_usage_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_required_flag                in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_supplied_resource_id         in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_quantity                     in     number    default hr_api.g_number
  ,p_resource_type                in     varchar2  default hr_api.g_varchar2
  ,p_role_to_play                 in     varchar2  default hr_api.g_varchar2
  ,p_usage_reason                 in     varchar2  default hr_api.g_varchar2
  ,p_rud_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_rud_information1             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information2             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information3             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information4             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information5             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information6             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information7             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information8             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information9             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information10            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information11            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information12            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information13            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information14            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information15            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information16            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information17            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information18            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information19            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information20            in     varchar2  default hr_api.g_varchar2
  ,p_offering_id                  in     number    default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'Update_resource';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_RESOURCE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    ota_resource_usage_bk2.Update_resource_b
  (p_effective_date                    => l_effective_date
  ,p_resource_usage_id                 => p_resource_usage_id
  ,p_object_version_number             => p_object_version_number
  ,p_activity_version_id               => p_activity_version_id
  ,p_required_flag                     => p_required_flag
  ,p_start_date                        => p_start_date
  ,p_supplied_resource_id              => p_supplied_resource_id
  ,p_comments                          => p_comments
  ,p_end_date                          => p_end_date
  ,p_quantity                          => p_quantity
  ,p_resource_type                     => p_resource_type
  ,p_role_to_play                      => p_role_to_play
  ,p_usage_reason                      => p_usage_reason
  ,p_rud_information_category          => p_rud_information_category
  ,p_rud_information1                  => p_rud_information1
  ,p_rud_information2                  => p_rud_information2
  ,p_rud_information3                  => p_rud_information3
  ,p_rud_information4                  => p_rud_information4
  ,p_rud_information5                  => p_rud_information5
  ,p_rud_information6                  => p_rud_information6
  ,p_rud_information7                  => p_rud_information7
  ,p_rud_information8                  => p_rud_information8
  ,p_rud_information9                  => p_rud_information9
  ,p_rud_information10                 => p_rud_information10
  ,p_rud_information11                 => p_rud_information11
  ,p_rud_information12                 => p_rud_information12
  ,p_rud_information13                 => p_rud_information13
  ,p_rud_information14                 => p_rud_information14
  ,p_rud_information15                 => p_rud_information15
  ,p_rud_information16                 => p_rud_information16
  ,p_rud_information17                 => p_rud_information17
  ,p_rud_information18                 => p_rud_information18
  ,p_rud_information19       	       => p_rud_information19
  ,p_rud_information20       	       => p_rud_information20
  ,p_offering_id                       => p_offering_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RESOURCE'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic (Base table)
  --
  ota_rud_upd.upd
  (p_effective_date                    => l_effective_date
  ,p_resource_usage_id                 => p_resource_usage_id
  ,p_object_version_number             => p_object_version_number
  ,p_activity_version_id               => p_activity_version_id
  ,p_required_flag                     => p_required_flag
  ,p_start_date                        => p_start_date
  ,p_supplied_resource_id              => p_supplied_resource_id
  ,p_comments                          => p_comments
  ,p_end_date                          => p_end_date
  ,p_quantity                          => p_quantity
  ,p_resource_type                     => p_resource_type
  ,p_role_to_play                      => p_role_to_play
  ,p_usage_reason                      => p_usage_reason
  ,p_rud_information_category          => p_rud_information_category
  ,p_rud_information1                  => p_rud_information1
  ,p_rud_information2                  => p_rud_information2
  ,p_rud_information3                  => p_rud_information3
  ,p_rud_information4                  => p_rud_information4
  ,p_rud_information5                  => p_rud_information5
  ,p_rud_information6                  => p_rud_information6
  ,p_rud_information7                  => p_rud_information7
  ,p_rud_information8                  => p_rud_information8
  ,p_rud_information9                  => p_rud_information9
  ,p_rud_information10                 => p_rud_information10
  ,p_rud_information11                 => p_rud_information11
  ,p_rud_information12                 => p_rud_information12
  ,p_rud_information13                 => p_rud_information13
  ,p_rud_information14                 => p_rud_information14
  ,p_rud_information15                 => p_rud_information15
  ,p_rud_information16                 => p_rud_information16
  ,p_rud_information17                 => p_rud_information17
  ,p_rud_information18                 => p_rud_information18
  ,p_rud_information19       	       => p_rud_information19
  ,p_rud_information20       	       => p_rud_information20
  ,p_offering_id                       => p_offering_id
  );
  --
  -- Call After Process User Hook
  --

  begin
  ota_resource_usage_bk2.Update_resource_a
  (p_effective_date                    => l_effective_date
  ,p_resource_usage_id                 => p_resource_usage_id
  ,p_object_version_number             => p_object_version_number
  ,p_activity_version_id               => p_activity_version_id
  ,p_required_flag                     => p_required_flag
  ,p_start_date                        => p_start_date
  ,p_supplied_resource_id              => p_supplied_resource_id
  ,p_comments                          => p_comments
  ,p_end_date                          => p_end_date
  ,p_quantity                          => p_quantity
  ,p_resource_type                     => p_resource_type
  ,p_role_to_play                      => p_role_to_play
  ,p_usage_reason                      => p_usage_reason
  ,p_rud_information_category          => p_rud_information_category
  ,p_rud_information1                  => p_rud_information1
  ,p_rud_information2                  => p_rud_information2
  ,p_rud_information3                  => p_rud_information3
  ,p_rud_information4                  => p_rud_information4
  ,p_rud_information5                  => p_rud_information5
  ,p_rud_information6                  => p_rud_information6
  ,p_rud_information7                  => p_rud_information7
  ,p_rud_information8                  => p_rud_information8
  ,p_rud_information9                  => p_rud_information9
  ,p_rud_information10                 => p_rud_information10
  ,p_rud_information11                 => p_rud_information11
  ,p_rud_information12                 => p_rud_information12
  ,p_rud_information13                 => p_rud_information13
  ,p_rud_information14                 => p_rud_information14
  ,p_rud_information15                 => p_rud_information15
  ,p_rud_information16                 => p_rud_information16
  ,p_rud_information17                 => p_rud_information17
  ,p_rud_information18                 => p_rud_information18
  ,p_rud_information19       	       => p_rud_information19
  ,p_rud_information20       	       => p_rud_information20
  ,p_offering_id                       => p_offering_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RESOURCE'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_RESOURCE;
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
    rollback to UPDATE_RESOURCE;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_resource;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Delete_resource >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure Delete_resource
  (p_validate                      in     boolean  default false
  ,p_resource_usage_id             in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'Delete_resource';
  l_budget_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_RESOURCE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --

  begin
    ota_resource_usage_bk3.Delete_resource_b
  (p_resource_usage_id           => p_resource_usage_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RESOURCE'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic (Base table)
  --
  ota_rud_del.del
  (p_resource_usage_id       => p_resource_usage_id
  ,p_object_version_number   => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --

  begin
  ota_resource_usage_bk3.Delete_resource_a
  (p_resource_usage_id           => p_resource_usage_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RESOURCE'
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
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_RESOURCE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_RESOURCE;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end Delete_resource;
--
end OTA_RESOURCE_USAGE_API;

/
