--------------------------------------------------------
--  DDL for Package Body OTA_COURSE_PREREQUISITE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_COURSE_PREREQUISITE_API" as
/* $Header: otcprapi.pkb 120.0 2005/05/29 07:07 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_course_prerequisite_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_course_prerequisite >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_course_prerequisite
  (p_validate                       in  boolean  default false
  ,p_effective_date                 in     date
  ,p_activity_version_id            in number
  ,p_prerequisite_course_id         in number
  ,p_business_group_id              in     number
  ,p_prerequisite_type              in     varchar2
  ,p_enforcement_mode               in     varchar2
  ,p_object_version_number          out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_course_prerequisite ';
  l_object_version_number   number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_course_prerequisite;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    ota_course_prerequisite_bk1.create_course_prerequisite_b
    (p_effective_date             => l_effective_date
    ,p_activity_version_id        => p_activity_version_id
    ,p_prerequisite_course_id     => p_prerequisite_course_id
    ,p_business_group_id          => p_business_group_id
    ,p_prerequisite_type          => p_prerequisite_type
    ,p_enforcement_mode           => p_enforcement_mode
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_course_prerequisite_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_cpr_ins.ins
    (p_effective_date             => l_effective_date
    ,p_activity_version_id        => p_activity_version_id
    ,p_prerequisite_course_id     => p_prerequisite_course_id
    ,p_business_group_id          => p_business_group_id
    ,p_prerequisite_type          => p_prerequisite_type
    ,p_enforcement_mode           => p_enforcement_mode
    ,p_object_version_number      => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
  ota_course_prerequisite_bk1.create_course_prerequisite_a
    (p_effective_date             => l_effective_date
    ,p_activity_version_id        => p_activity_version_id
    ,p_prerequisite_course_id     => p_prerequisite_course_id
    ,p_business_group_id          => p_business_group_id
    ,p_prerequisite_type          => p_prerequisite_type
    ,p_enforcement_mode           => p_enforcement_mode
    ,p_object_version_number      => l_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_course_prerequisite_a'
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
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_course_prerequisite;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_course_prerequisite;
    p_object_version_number :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_course_prerequisite ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_course_prerequisite >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_course_prerequisite
  (p_validate                       in  boolean  default false
  ,p_effective_date                 in     date
  ,p_activity_version_id            in number
  ,p_prerequisite_course_id         in number
  ,p_business_group_id              in     number
  ,p_prerequisite_type              in     varchar2
  ,p_enforcement_mode               in     varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_course_prerequisite ';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_course_prerequisite ;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --

  -- Call Before Process User Hook
  --
  begin
    ota_course_prerequisite_bk2.update_course_prerequisite_b
    (p_effective_date             => l_effective_date
    ,p_activity_version_id        => p_activity_version_id
    ,p_prerequisite_course_id     => p_prerequisite_course_id
    ,p_business_group_id          => p_business_group_id
    ,p_prerequisite_type          => p_prerequisite_type
    ,p_enforcement_mode           => p_enforcement_mode
    ,p_object_version_number      => l_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_course_prerequisite_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_cpr_upd.upd
    (p_effective_date             => l_effective_date
    ,p_activity_version_id        => p_activity_version_id
    ,p_prerequisite_course_id     => p_prerequisite_course_id
    ,p_business_group_id          => p_business_group_id
    ,p_prerequisite_type          => p_prerequisite_type
    ,p_enforcement_mode           => p_enforcement_mode
    ,p_object_version_number      => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
  ota_course_prerequisite_bk2.update_course_prerequisite_a
    (p_effective_date             => l_effective_date
    ,p_activity_version_id        => p_activity_version_id
    ,p_prerequisite_course_id     => p_prerequisite_course_id
    ,p_business_group_id          => p_business_group_id
    ,p_prerequisite_type          => p_prerequisite_type
    ,p_enforcement_mode           => p_enforcement_mode
    ,p_object_version_number      => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_course_prerequisite_a'
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
    rollback to update_course_prerequisite ;
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
    rollback to update_course_prerequisite ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_object_version_number := l_object_version_number;
    raise;
end update_course_prerequisite ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_course_prerequisite >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_course_prerequisite
  (p_validate                           in boolean default false
  ,p_activity_version_id                in number
  ,p_prerequisite_course_id             in number
  ,p_object_version_number              in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' delete_course_prerequisite ';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_course_prerequisite ;
  --
  -- Call Before Process User Hook
  --
  begin
    ota_course_prerequisite_bk3.delete_course_prerequisite_b
     (p_activity_version_id        => p_activity_version_id
     ,p_prerequisite_course_id     => p_prerequisite_course_id
     ,p_object_version_number      => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_course_prerequisite_b '
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_cpr_del.del
     (p_activity_version_id        => p_activity_version_id
     ,p_prerequisite_course_id     => p_prerequisite_course_id
     ,p_object_version_number      => p_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin

  ota_course_prerequisite_bk3.delete_course_prerequisite_a
     (p_activity_version_id        => p_activity_version_id
     ,p_prerequisite_course_id     => p_prerequisite_course_id
     ,p_object_version_number      => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_course_prerequisite_a '
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
    rollback to delete_course_prerequisite ;
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
    rollback to delete_course_prerequisite ;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_course_prerequisite;
--
end ota_course_prerequisite_api;

/
