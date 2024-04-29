--------------------------------------------------------
--  DDL for Package Body HR_KI_OPTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_OPTIONS_API" as
/* $Header: hroptapi.pkb 115.0 2004/01/09 02:36:29 vkarandi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_OPTIONS_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_OPTION >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_option
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_option_type_id                in     number
  ,p_option_level                  in     number
  ,p_option_level_id               in     varchar2 default null
  ,p_value                         in     varchar2 default null
  ,p_encrypted                     in     varchar2 default 'N'
  ,p_integration_id                in     number
  ,p_option_id                     out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  )  is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_option';
  l_option_id             number;
  l_effective_date        date;
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_option;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  l_effective_date := trunc(p_effective_date);

  -- Call Before Process User Hook
  --
  begin
    hr_ki_options_bk1.create_option_b
      (
       p_effective_date                => p_effective_date
      ,p_option_type_id                => p_option_type_id
      ,p_option_level                  => p_option_level
      ,p_option_level_id               => p_option_level_id
      ,p_value                         => p_value
      ,p_encrypted                     => p_encrypted
      ,p_integration_id                => p_integration_id
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_option'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_opt_ins.ins
     (
       p_effective_date                => l_effective_date
      ,p_option_type_id                => p_option_type_id
      ,p_option_level                  => p_option_level
      ,p_option_level_id               => p_option_level_id
      ,p_value                         => p_value
      ,p_encrypted                     => p_encrypted
      ,p_integration_id                => p_integration_id
      ,p_option_id                     => l_option_id
      ,p_object_version_number         => l_object_version_number
     );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_options_bk1.create_option_a
      (
       p_effective_date                => l_effective_date
      ,p_option_type_id                => p_option_type_id
      ,p_option_level                  => p_option_level
      ,p_option_level_id               => p_option_level_id
      ,p_value                         => p_value
      ,p_encrypted                     => p_encrypted
      ,p_integration_id                => p_integration_id
      ,p_option_id                     => l_option_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_option'
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
  p_option_id              := l_option_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_option;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_option_id              := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_option;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_option_id              := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_option;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_OPTION >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_option
  (
   p_validate                      in     boolean  default false
  ,p_option_id                     in     number
  ,p_value                         in     varchar2 default hr_api.g_varchar2
  ,p_encrypted                     in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_option';
  l_object_version_number number := p_object_version_number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_option;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_options_bk2.update_option_b
      (
       p_value                         => p_value
      ,p_encrypted                     => p_encrypted
      ,p_option_id                     => p_option_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_option'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_opt_upd.upd
     (
     p_option_id                     => p_option_id
    ,p_value                         => p_value
    ,p_encrypted                     => p_encrypted
    ,p_object_version_number         => p_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_options_bk2.update_option_a
      (
       p_value                         => p_value
      ,p_encrypted                     => p_encrypted
      ,p_option_id                     => p_option_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_option'
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

  -- p_object_version_number  := p_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_option;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_option;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_option;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_OPTION >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option
  (
   P_VALIDATE                 in boolean         default false
  ,P_OPTION_ID                in number
  ,P_OBJECT_VERSION_NUMBER    in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_option';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_option;
  --
  -- Remember IN OUT parameter IN values
  --

  -- Call Before Process User Hook
  --
  begin
    hr_ki_options_bk3.delete_option_b
      (
       p_option_id               => p_option_id
       ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_option'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_opt_del.del
     (
      p_option_id               => p_option_id
     ,p_object_version_number   => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_options_bk3.delete_option_a
      (
       p_option_id               =>    p_option_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_option'
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
    rollback to delete_option;
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
    rollback to delete_option;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_option;
end HR_KI_OPTIONS_API;

/
