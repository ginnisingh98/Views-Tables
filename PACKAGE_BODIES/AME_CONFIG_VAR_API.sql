--------------------------------------------------------
--  DDL for Package Body AME_CONFIG_VAR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CONFIG_VAR_API" as
/* $Header: amcfvapi.pkb 120.0 2005/09/02 03:54 mbocutt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'AME_CONFIG_VAR_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------<UPDATE_AME_CONFIG_VARIABLE>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_config_variable
  (p_validate                    in     boolean   default false
  ,p_application_id              in     number
  ,p_variable_name               in     varchar2
  ,p_variable_value              in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number       in out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor csr_isAlreadyDefined is
    select 'Y'
      from ame_config_vars
     where application_id = p_application_id
       and variable_name  = p_variable_name
       and sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate);
  l_proc                      varchar2(72) := g_package||'update_ame_config_variable';
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  l_key                       varchar2(1);
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_ame_config_variable;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_config_var_bk1.update_ame_config_variable_b
        (p_application_id        => p_application_id
        ,p_variable_name         => p_variable_name
        ,p_variable_value        => p_variable_value
        ,p_object_version_number => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'update_ame_config_variable'
                              ,p_hook_type   => 'BP'
                              );
    end;
    --
    -- Process Logic. Determine whether its an 'insert' or 'update' process.
    --
    open csr_isAlreadyDefined;
    fetch csr_isAlreadyDefined into l_key;
    if(csr_isAlreadyDefined%notfound) then
      ame_cfv_ins.ins(p_effective_date        => sysdate
                     ,p_application_id        => p_application_id
                     ,p_variable_name         => p_variable_name
                     ,p_variable_value        => p_variable_value
                     ,p_security_group_id     => null
                     ,p_object_version_number => p_object_version_number
                     ,p_start_date            => l_start_date
                     ,p_end_date              => l_end_date
                     );
    else
      ame_cfv_upd.upd(p_effective_date        => sysdate
                     ,p_datetrack_mode        => hr_api.g_update
                     ,p_application_id        => p_application_id
                     ,p_variable_name         => p_variable_name
                     ,p_variable_value        => p_variable_value
                     ,p_security_group_id     => null
                     ,p_object_version_number => p_object_version_number
                     ,p_start_date            => l_start_date
                     ,p_end_date              => l_end_date
                     );
    end if;
    close csr_isAlreadyDefined;
    --
    -- Call After Process User Hook
    --
    begin
      ame_config_var_bk1.update_ame_config_variable_a
        (p_application_id        => p_application_id
        ,p_variable_name         => p_variable_name
        ,p_variable_value        => p_variable_value
        ,p_object_version_number => p_object_version_number
        ,p_start_date            => l_start_date
        ,p_end_date              => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'update_ame_config_variable'
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
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date   := l_start_date;
    p_end_date     := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to update_ame_config_variable;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to update_ame_config_variable;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end update_ame_config_variable;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------< DELETE_AME_CONFIG_VARIABLE >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_config_variable
  (p_validate              in     boolean  default false
  ,p_application_id        in     number
  ,p_variable_name         in     varchar2
  ,p_object_version_number in out nocopy   number
  ,p_start_date               out nocopy   date
  ,p_end_date                 out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'delete_ame_config_variable';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint delete_ame_config_variable;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_config_var_bk2.delete_ame_config_variable_b
        (p_application_id           => p_application_id
        ,p_variable_name            => p_variable_name
        ,p_object_version_number    => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'delete_ame_config_variable'
                              ,p_hook_type   => 'BP'
                              );
    end;
    --
    -- Process Logic
    --
    ame_cfv_del.del(p_effective_date          => sysdate
                   ,p_datetrack_mode          => hr_api.g_delete
                   ,p_application_id          => p_application_id
                   ,p_variable_name           => p_variable_name
                   ,p_object_version_number   => p_object_version_number
                   ,p_start_date              => l_start_date
                   ,p_end_date                => l_end_date
                   );
    --
    -- Call After Process User Hook
    --
    begin
      ame_config_var_bk2.delete_ame_config_variable_a
      (p_application_id          => p_application_id
      ,p_variable_name           => p_variable_name
      ,p_object_version_number   => p_object_version_number
      ,p_start_date              => l_start_date
      ,p_end_date                => l_end_date
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'delete_ame_config_variable'
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
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date  := l_start_date;
    p_end_date    := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to delete_ame_config_variable;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to delete_ame_config_variable;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end delete_ame_config_variable;
end AME_CONFIG_VAR_API;

/
