--------------------------------------------------------
--  DDL for Package Body FF_FUNCTION_CONTEXT_USG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FUNCTION_CONTEXT_USG_API" as
/* $Header: fffcuapi.pkb 120.0 2005/05/27 23:22:38 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  FF_FUNCTION_CONTEXT_USG_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_CONTEXT >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_CONTEXT
  (p_validate                      in     boolean  default false
  ,p_function_id                   in     number
  ,p_context_id                    in     number
  ,p_sequence_number                  out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is

  l_object_version_number ff_function_context_usages.object_version_number%type;
  l_sequence_number       ff_function_context_usages.sequence_number%type;

  l_proc                  varchar2(72) := g_package||'CREATE_CONTEXT';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_CONTEXT;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    FF_FUNCTION_CONTEXT_USG_BK1.CREATE_CONTEXT_b
       (p_function_id               => p_function_id
       ,p_context_id                => p_context_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CONTEXT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  ff_fcu_ins.ins
     (p_function_id               => p_function_id
     ,p_context_id                => p_context_id
     ,p_sequence_number           => l_sequence_number
     ,p_object_version_number     => l_object_version_number
     );

  --
  -- Call After Process User Hook
  --
  begin
    FF_FUNCTION_CONTEXT_USG_BK1.CREATE_CONTEXT_a
       (p_function_id               => p_function_id
       ,p_context_id                => p_context_id
       ,p_sequence_number           => l_sequence_number
       ,p_object_version_number     => l_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CONTEXT'
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
  p_sequence_number        := l_sequence_number;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_CONTEXT;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_sequence_number        := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_CONTEXT;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_sequence_number        := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_CONTEXT;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_CONTEXT >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_CONTEXT
  (p_validate                      in     boolean  default false
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_context_id                    in     number   default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number      ff_function_context_usages.object_version_number%type;
  l_proc                varchar2(72) := g_package||'UPDATE_CONTEXT';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_CONTEXT;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    FF_FUNCTION_CONTEXT_USG_BK2.UPDATE_CONTEXT_b
       (p_function_id               => p_function_id
       ,p_sequence_number           => p_sequence_number
       ,p_object_version_number     => l_object_version_number
       ,p_context_id                => p_context_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CONTEXT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  ff_fcu_upd.upd
     (p_function_id               => p_function_id
     ,p_sequence_number           => p_sequence_number
     ,p_object_version_number     => l_object_version_number
     ,p_context_id                => p_context_id
     );


  --
  -- Call After Process User Hook
  --
  begin
    FF_FUNCTION_CONTEXT_USG_BK2.UPDATE_CONTEXT_a
       (p_function_id               => p_function_id
       ,p_sequence_number           => p_sequence_number
       ,p_object_version_number     => l_object_version_number
       ,p_context_id                => p_context_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CONTEXT'
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
    rollback to UPDATE_CONTEXT;
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
    rollback to UPDATE_CONTEXT;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_CONTEXT;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_CONTEXT >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_CONTEXT
  (p_validate                      in     boolean  default false
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'DELETE_CONTEXT';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_CONTEXT;
  --
  -- Remember IN OUT parameter IN values
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    FF_FUNCTION_CONTEXT_USG_BK3.DELETE_CONTEXT_b
       (p_function_id               => p_function_id
       ,p_sequence_number           => p_sequence_number
       ,p_object_version_number     => p_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CONTEXT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  ff_fcu_del.del
     (p_function_id               => p_function_id
     ,p_sequence_number           => p_sequence_number
     ,p_object_version_number     => p_object_version_number
     );


  --
  -- Call After Process User Hook
  --
  begin
    FF_FUNCTION_CONTEXT_USG_BK3.DELETE_CONTEXT_a
       (p_function_id               => p_function_id
       ,p_sequence_number           => p_sequence_number
       ,p_object_version_number     => p_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CONTEXT'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_CONTEXT;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_CONTEXT;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_CONTEXT;
--

end FF_FUNCTION_CONTEXT_USG_API;

/
