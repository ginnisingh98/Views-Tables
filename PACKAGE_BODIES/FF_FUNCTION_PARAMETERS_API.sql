--------------------------------------------------------
--  DDL for Package Body FF_FUNCTION_PARAMETERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FUNCTION_PARAMETERS_API" as
/* $Header: ffffpapi.pkb 120.0 2005/05/27 23:23:54 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  FF_FUNCTION_PARAMETERS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_PARAMETER >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_parameter
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_function_id                   in     number
  ,p_class                         in     varchar2
  ,p_data_type                     in     varchar2
  ,p_name                          in     varchar2
  ,p_optional                      in     varchar2 default 'N'
  ,p_continuing_parameter          in     varchar2 default 'N'
  ,p_sequence_number                  out nocopy   number
  ,p_object_version_number            out nocopy   number
  )
 is
  --
  -- Declare cursors and local variables
  --
  l_sequence_number            ff_function_parameters.sequence_number%type;
  l_optional                   ff_function_parameters.optional%type;
  l_continuing_parameter       ff_function_parameters.continuing_parameter%type;
  l_object_version_number      ff_function_parameters.object_version_number%type;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'CREATE_PARAMETER';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_PARAMETER;
  --
  -- Remember IN OUT parameter IN values
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --

  begin
    FF_FUNCTION_PARAMETERS_BK1.CREATE_PARAMETER_b
      (p_effective_date            => l_effective_date
      ,p_function_id               => p_function_id
      ,p_class                     => p_class
      ,p_data_type                 => p_data_type
      ,p_name                      => p_name
      ,p_optional                  => p_optional
      ,p_continuing_parameter      => p_continuing_parameter
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PARAMETER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- if parameter class is 'OUT' or 'IN/OUT' type then optional must be 'N'
  if (p_class <> 'I' ) then
     l_optional := 'N';
     l_continuing_parameter := 'N';
  else
     l_optional := p_optional;
     l_continuing_parameter := p_continuing_parameter;
  end if;
  --
  -- Process Logic
  --

  ff_ffp_ins.ins
      (p_effective_date            => l_effective_date
      ,p_function_id               => p_function_id
      ,p_class                     => p_class
      ,p_continuing_parameter      => l_continuing_parameter
      ,p_data_type                 => p_data_type
      ,p_name                      => p_name
      ,p_optional                  => l_optional
      ,p_sequence_number           => l_sequence_number
      ,p_object_version_number     => l_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
    FF_FUNCTION_PARAMETERS_BK1.CREATE_PARAMETER_a
      (p_effective_date            => l_effective_date
      ,p_function_id               => p_function_id
      ,p_class                     => p_class
      ,p_data_type                 => p_data_type
      ,p_name                      => p_name
      ,p_optional                  => l_optional
      ,p_continuing_parameter      => l_continuing_parameter
      ,p_sequence_number           => l_sequence_number
      ,p_object_version_number     => l_object_version_number
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PARAMETER'
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
    rollback to CREATE_PARAMETER;
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
    rollback to CREATE_PARAMETER;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
     p_sequence_number        := null;
    p_object_version_number  := null;

   hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_PARAMETER;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_PARAMETER >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_PARAMETER
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_class                         in     varchar2 default hr_api.g_varchar2
  ,p_data_type                     in     varchar2 default hr_api.g_varchar2
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_optional                      in     varchar2 default hr_api.g_varchar2
  ,p_continuing_parameter          in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_optional                   ff_function_parameters.optional%type;
  l_continuing_parameter       ff_function_parameters.continuing_parameter%type;
  l_object_version_number      ff_function_parameters.object_version_number%type;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'UPDATE_PARAMETER';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_PARAMETER;
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
    FF_FUNCTION_PARAMETERS_BK2.UPDATE_PARAMETER_b
       (p_effective_date           => l_effective_date
       ,p_function_id              => p_function_id
       ,p_sequence_number          => p_sequence_number
       ,p_object_version_number    => l_object_version_number
       ,p_class                    => p_class
       ,p_data_type                => p_data_type
       ,p_name                     => p_name
       ,p_optional                 => p_optional
       ,p_continuing_parameter     => p_continuing_parameter
  );  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PARAMETER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- if parameter class is 'OUT' or 'IN/OUT' type then optional must be 'N'
  if (p_class <> 'I' ) then
     l_optional := 'N';
     l_continuing_parameter := 'N';
  else
     l_optional := p_optional;
     l_continuing_parameter := p_continuing_parameter;
  end if;
  --
  ff_ffp_upd.upd
       (p_effective_date           => l_effective_date
       ,p_function_id              => p_function_id
       ,p_sequence_number          => p_sequence_number
       ,p_object_version_number    => l_object_version_number
       ,p_class                    => p_class
       ,p_continuing_parameter     => l_continuing_parameter
       ,p_data_type                => p_data_type
       ,p_name                     => p_name
       ,p_optional                 => l_optional
       );

  --
  -- Process Logic
  --

  --
  -- Call After Process User Hook
  --
  begin
    FF_FUNCTION_PARAMETERS_BK2.UPDATE_PARAMETER_a
       (p_effective_date           => l_effective_date
       ,p_function_id              => p_function_id
       ,p_sequence_number          => p_sequence_number
       ,p_object_version_number    => l_object_version_number
       ,p_class                    => p_class
       ,p_data_type                => p_data_type
       ,p_name                     => p_name
       ,p_optional                 => l_optional
       ,p_continuing_parameter     => l_continuing_parameter
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PARAMETER'
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
    rollback to UPDATE_PARAMETER;
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
    rollback to UPDATE_PARAMETER;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_PARAMETER;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_PARAMETER >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_PARAMETER
  (p_validate                      in     boolean  default false
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'DELETE_PARAMETER';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_PARAMETER;
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
    FF_FUNCTION_PARAMETERS_BK3.DELETE_PARAMETER_b
       (p_function_id              => p_function_id
       ,p_sequence_number          => p_sequence_number
       ,p_object_version_number    => p_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PARAMETER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ff_ffp_del.del
       (p_function_id              => p_function_id
       ,p_sequence_number          => p_sequence_number
       ,p_object_version_number    => p_object_version_number
       );

  --
  -- Call After Process User Hook
  --
  begin
    FF_FUNCTION_PARAMETERS_BK3.DELETE_PARAMETER_a
       (p_function_id              => p_function_id
       ,p_sequence_number          => p_sequence_number
       ,p_object_version_number    => p_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PARAMETER'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_PARAMETER;
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
    rollback to DELETE_PARAMETER;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_PARAMETER;
--

end FF_FUNCTION_PARAMETERS_API;

/
