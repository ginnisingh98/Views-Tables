--------------------------------------------------------
--  DDL for Package Body HR_AUTHORIA_VARIABLEMAP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AUTHORIA_VARIABLEMAP_API" as
/* $Header: hravmapi.pkb 115.1 2002/11/29 13:34:07 apholt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_AUTHORIA_VARIABLEMAP_API.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_VARIABLEMAP >-------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_VARIABLEMAP
  (p_validate                      in     boolean  default false
  ,p_ath_dsn                       in     varchar2
  ,p_ath_tablename                 in     varchar2
  ,p_ath_columnname                in     varchar2
  ,p_ath_varname                   in     varchar2
  ,p_ath_variablemap_id               out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'CREATE_VARIABLEMAP';
  l_ath_variablemap_id   number(15);
  l_object_version_number number(9);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_VARIABLEMAP;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    HR_AUTHORIA_VARIABLEMAP_BK1.CREATE_VARIABLEMAP_b
    (
     p_ath_dsn                       => p_ath_dsn
    ,p_ath_tablename                 => p_ath_tablename
    ,p_ath_columnname                => p_ath_columnname
    ,p_ath_varname                   => p_ath_varname
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VARIABLEMAP'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    hr_avm_ins.ins
    (
     p_ath_dsn                       => p_ath_dsn
    ,p_ath_tablename                 => p_ath_tablename
    ,p_ath_columnname                => p_ath_columnname
    ,p_ath_varname                   => p_ath_varname
    ,p_ath_variablemap_id            => l_ath_variablemap_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    HR_AUTHORIA_VARIABLEMAP_BK1.CREATE_VARIABLEMAP_a
    (
     p_ath_dsn                       => p_ath_dsn
    ,p_ath_tablename                 => p_ath_tablename
    ,p_ath_columnname                => p_ath_columnname
    ,p_ath_varname                   => p_ath_varname
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VARIABLEMAP'
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
  p_ath_variablemap_id     := l_ath_variablemap_id;
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_VARIABLEMAP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ath_variablemap_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_VARIABLEMAP;
    --set OUT parameters
    --
    p_ath_variablemap_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_VARIABLEMAP;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_VARIABLEMAP >------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_VARIABLEMAP
  (p_validate                      in     boolean  default false
  ,p_ath_dsn                       in     varchar2
  ,p_ath_tablename                 in     varchar2
  ,p_ath_columnname                in     varchar2
  ,p_ath_varname                   in     varchar2
  ,p_ath_variablemap_id            in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_VARIABLEMAP';
  l_object_version_number number(9);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_VARIABLEMAP;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    HR_AUTHORIA_VARIABLEMAP_BK2.UPDATE_VARIABLEMAP_b
    (
     p_ath_variablemap_id            => p_ath_variablemap_id
    ,p_ath_dsn                       => p_ath_dsn
    ,p_ath_tablename                 => p_ath_tablename
    ,p_ath_columnname                => p_ath_columnname
    ,p_ath_varname                   => p_ath_varname
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_VARIABLEMAP'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    hr_avm_upd.upd
    (
     p_ath_dsn                       => p_ath_dsn
    ,p_ath_tablename                 => p_ath_tablename
    ,p_ath_columnname                => p_ath_columnname
    ,p_ath_varname                   => p_ath_varname
    ,p_ath_variablemap_id            => p_ath_variablemap_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    HR_AUTHORIA_VARIABLEMAP_BK2.UPDATE_VARIABLEMAP_a
    (
     p_ath_variablemap_id            => p_ath_variablemap_id
    ,p_ath_dsn                       => p_ath_dsn
    ,p_ath_tablename                 => p_ath_tablename
    ,p_ath_columnname                => p_ath_columnname
    ,p_ath_varname                   => p_ath_varname
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_VARIABLEMAP'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_VARIABLEMAP;
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
    rollback to UPDATE_VARIABLEMAP;
    -- set out variables
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_VARIABLEMAP;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< DELETE_VARIABLEMAP >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_VARIABLEMAP
  (p_validate                      in     boolean  default false
  ,p_ath_variablemap_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||
                                               'DELETE_VARIABLEMAP';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_VARIABLEMAP;

  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    HR_AUTHORIA_VARIABLEMAP_BK3.DELETE_VARIABLEMAP_b
    (p_ath_variablemap_id            => p_ath_variablemap_id
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VARIABLEMAP'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    hr_avm_del.del
    (p_ath_variablemap_id            => p_ath_variablemap_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    HR_AUTHORIA_VARIABLEMAP_BK3.DELETE_VARIABLEMAP_a
    (p_ath_variablemap_id            => p_ath_variablemap_id
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VARIABLEMAP'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_VARIABLEMAP;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_VARIABLEMAP;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_VARIABLEMAP;
--
--

end HR_AUTHORIA_VARIABLEMAP_API;

/
