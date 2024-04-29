--------------------------------------------------------
--  DDL for Package Body PQH_FR_VALIDATION_EVENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_VALIDATION_EVENTS_API" as
/* $Header: pqvleapi.pkb 115.2 2002/12/05 00:31:10 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_FR_VALIDATION_EVENTS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_Validation_event >---------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_Validation_event
  (p_effective_date               in     date
  ,p_validation_id                  in     number
  ,p_event_type                     in     varchar2
  ,p_event_code                     in     varchar2
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_comments                       in     varchar2 default null
  ,p_validation_event_id               out nocopy number
  ,p_object_version_number             out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)       := g_package||'Insert_Validation_event';
  l_object_Version_Number    PQH_FR_VALIDATION_EVENTS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date           Date;
  l_validation_event_id 	PQH_FR_VALIDATION_EVENTS.VALIDATION_EVENT_ID%TYPE;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_Validation_event;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_FR_VALIDATION_EVENTS_BK1.Insert_Validation_event_b
   (p_effective_date               => l_effective_date
  ,p_validation_id                => p_validation_id
  ,p_event_type                   => p_event_type
  ,p_event_code                   => p_event_code
  ,p_start_date                   => p_start_date
  ,p_end_date                     => p_end_date
  ,p_comments                     => p_comments);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_VALIDATION_EVENTS_API.Insert_Validation_event'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_vle_ins.ins
     (p_effective_date               => l_effective_date
  ,p_validation_id                => p_validation_id
  ,p_event_type                   => p_event_type
  ,p_event_code                   => p_event_code
  ,p_start_date                   => p_start_date
  ,p_end_date                     => p_end_date
  ,p_comments                     => p_comments
  ,p_validation_event_id          => l_validation_event_id
  ,p_object_version_number        => l_object_version_number);

  --
  -- Call After Process User Hook
  --
  begin
     PQH_FR_VALIDATION_EVENTS_BK1.Insert_Validation_event_a
     (p_effective_date               => l_effective_date
  ,p_validation_id                => p_validation_id
  ,p_event_type                   => p_event_type
  ,p_event_code                   => p_event_code
  ,p_start_date                   => p_start_date
  ,p_end_date                     => p_end_date
  ,p_comments                     => p_comments);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_VALIDATION_EVENTS_API.Insert_Validation_event'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
-- Removed p_validate from the generated code to facilitate
-- writing wrappers to selfservice easily.
--
--  if p_validate then
--    raise hr_api.validate_enabled;
--  end if;
  --
  -- Set all output arguments
  --
     p_validation_event_id := l_validation_event_id;
     p_object_version_number := l_object_version_number;


  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_Validation_event;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
  p_validation_event_id := null;
  p_object_version_number := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_Validation_event;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_Validation_event;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Validation_event >---------------------|
-- ----------------------------------------------------------------------------

procedure Update_Validation_event
  (p_effective_date                in     date
  ,p_validation_event_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_validation_id                in     number    default hr_api.g_number
  ,p_event_type                   in     varchar2  default hr_api.g_varchar2
  ,p_event_code                   in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2) Is

  l_proc  varchar2(72)    := g_package||'Update_Validation_event';
  l_object_Version_Number PQH_FR_VALIDATION_EVENTS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date        Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_Validation_event;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

   PQH_FR_VALIDATION_EVENTS_BK2.Update_Validation_event_b
  (p_effective_date                => l_effective_date
  ,p_validation_event_id        => p_validation_event_id
  ,p_object_version_number      => p_object_version_number
  ,p_validation_id              => p_validation_id
  ,p_event_type                 => p_event_type
  ,p_event_code                  => p_event_code
  ,p_start_date                 => p_start_date
  ,p_end_date                  => p_end_date
  ,p_comments                  => p_comments);

 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Validation_event'
        ,p_hook_type   => 'BP'
        );
  end;

  pqh_vle_upd.upd
  (p_effective_date                => l_effective_date
  ,p_validation_event_id        => p_validation_event_id
  ,p_object_version_number      => l_object_version_number
  ,p_validation_id              => p_validation_id
  ,p_event_type                 => p_event_type
  ,p_event_code                  => p_event_code
  ,p_start_date                 => p_start_date
  ,p_end_date                  => p_end_date
  ,p_comments                  => p_comments);

--
--
  -- Call After Process User Hook
  --
  begin

   PQH_FR_VALIDATION_EVENTS_BK2.Update_Validation_event_a
  (p_effective_date                => l_effective_date
  ,p_validation_event_id        => p_validation_event_id
  ,p_object_version_number      => l_object_version_number
  ,p_validation_id              => p_validation_id
  ,p_event_type                 => p_event_type
  ,p_event_code                  => p_event_code
  ,p_start_date                 => p_start_date
  ,p_end_date                  => p_end_date
  ,p_comments                  => p_comments);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Validation_event'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
--  if p_validate then
--    raise hr_api.validate_enabled;
--  end if;
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
    rollback to Update_Validation_event;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Update_Validation_event;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_Validation_event;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_Validation_event>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_Validation_event
  (
  p_validation_event_id                        in     number
  ,p_object_version_number                in     number
  ) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_Validation_event';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_Validation_event;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_FR_VALIDATION_EVENTS_BK3.Delete_Validation_event_b
  (p_validation_event_id            => p_validation_event_id
  ,p_object_version_number   => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Validation_event'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_vle_del.del
    (p_validation_event_id            => p_validation_event_id
  ,p_object_version_number   => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin

   PQH_FR_VALIDATION_EVENTS_BK3.Delete_Validation_event_a
  (p_validation_event_id            => p_validation_event_id
  ,p_object_version_number   => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Validation_event'
        ,p_hook_type   => 'AP');
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
--  if p_validate then
--    raise hr_api.validate_enabled;
--  end if;
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
    rollback to delete_Validation_event;
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
    rollback to delete_Validation_event;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_Validation_event;

end PQH_FR_VALIDATION_EVENTS_API;

/
