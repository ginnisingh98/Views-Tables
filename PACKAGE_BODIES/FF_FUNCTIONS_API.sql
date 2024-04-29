--------------------------------------------------------
--  DDL for Package Body FF_FUNCTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FUNCTIONS_API" as
/* $Header: ffffnapi.pkb 120.0 2005/05/27 23:23:16 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  FF_FUNCTIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_FUNCTION >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_FUNCTION
  (p_validate                      in      boolean  default false
  ,p_effective_date                in      date
  ,p_name                          in      varchar2
  ,p_class                         in      varchar2
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_alias_name                     in     varchar2 default null
  ,p_data_type                      in     varchar2 default null
  ,p_definition                     in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_function_id                       out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_function_id            ff_functions.function_id%type;
  l_object_version_number  ff_functions.object_version_number%type;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'CREATE_FUNCTION';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_FUNCTION;
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
    FF_FUNCTIONS_BK1.CREATE_FUNCTION_b
       (p_effective_date           => l_effective_date
       ,p_name                     => p_name
       ,p_class                    => p_class
       ,p_business_group_id        => p_business_group_id
       ,p_legislation_code         => p_legislation_code
       ,p_alias_name               => p_alias_name
       ,p_data_type                => p_data_type
       ,p_definition               => p_definition
       ,p_description              => p_description
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FUNCTION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  ff_ffn_ins.ins
       (p_effective_date           => l_effective_date
       ,p_name                     => p_name
       ,p_class                    => p_class
       ,p_business_group_id        => p_business_group_id
       ,p_legislation_code         => p_legislation_code
       ,p_alias_name               => p_alias_name
       ,p_data_type                => p_data_type
       ,p_definition               => p_definition
       ,p_description              => p_description
       ,p_function_id              => l_function_id
       ,p_object_version_number    => l_object_version_number
       );


  --
  -- Call After Process User Hook
  --
  begin
    FF_FUNCTIONS_BK1.CREATE_FUNCTION_a
       (p_effective_date           => l_effective_date
       ,p_name                     => p_name
       ,p_class                    => p_class
       ,p_business_group_id        => p_business_group_id
       ,p_legislation_code         => p_legislation_code
       ,p_alias_name               => p_alias_name
       ,p_data_type                => p_data_type
       ,p_definition               => p_definition
       ,p_description              => p_description
       ,p_function_id              => l_function_id
       ,p_object_version_number    => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FUNCTION'
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
  p_function_id            := l_function_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_FUNCTION;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_function_id            := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_FUNCTION;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_function_id            := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_FUNCTION;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_FUNCTION >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_FUNCTION
  (p_validate                     in      boolean  default false
  ,p_effective_date               in      date
  ,p_function_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_class                        in     varchar2  default hr_api.g_varchar2
  ,p_alias_name                   in     varchar2  default hr_api.g_varchar2
  ,p_data_type                    in     varchar2  default hr_api.g_varchar2
  ,p_definition                   in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number   ff_functions.object_version_number%type;
  l_effective_date          date;
  l_proc                    varchar2(72) := g_package||'UPDATE_FUNCTION';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_FUNCTION;
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
    FF_FUNCTIONS_BK2.UPDATE_FUNCTION_b
       (p_effective_date           => l_effective_date
       ,p_function_id              => p_function_id
       ,p_object_version_number    => l_object_version_number
       ,p_name                     => p_name
       ,p_class                    => p_class
       ,p_alias_name               => p_alias_name
       ,p_data_type                => p_data_type
       ,p_definition               => p_definition
       ,p_description              => p_description
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FUNCTION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  ff_ffn_upd.upd
     (p_effective_date           => l_effective_date
     ,p_function_id              => p_function_id
     ,p_object_version_number    => l_object_version_number
     ,p_name                     => p_name
     ,p_class                    => p_class
--  ,p_business_group_id         => hr_api.g_number
--  ,p_legislation_code          => hr_api.g_varchar2
     ,p_alias_name               => p_alias_name
     ,p_data_type                => p_data_type
     ,p_definition               => p_definition
     ,p_description              => p_description
     );


  --
  -- Call After Process User Hook
  --
  begin
    FF_FUNCTIONS_BK2.UPDATE_FUNCTION_a
       (p_effective_date           => l_effective_date
       ,p_function_id              => p_function_id
       ,p_object_version_number    => l_object_version_number
       ,p_name                     => p_name
       ,p_class                    => p_class
       ,p_alias_name               => p_alias_name
       ,p_data_type                => p_data_type
       ,p_definition               => p_definition
       ,p_description              => p_description
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FUNCTION'
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
    rollback to UPDATE_FUNCTION;
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
    rollback to UPDATE_FUNCTION;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_FUNCTION;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_FUNCTION >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_FUNCTION
  (p_validate                     in      boolean  default false
  ,p_function_id                  in      number
  ,p_object_version_number        in      number
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor csr_function_context  is
    select function_id
          ,sequence_number
	  ,object_version_number
    from ff_function_context_usages
    where function_id = p_function_id;

  cursor csr_function_parameter
  is
    select function_id
          ,sequence_number
	  ,object_version_number
    from ff_function_parameters
    where function_id = p_function_id;

  l_function_id                 ff_functions.function_id%type;
  l_context_sequence_number     ff_function_context_usages.sequence_number%type;
  l_context_ovn                 ff_function_context_usages.object_version_number%type;
  l_parameter_sequence_number   ff_function_parameters.sequence_number%type;
  l_parameter_ovn               ff_function_parameters.object_version_number%type;
  l_proc                        varchar2(72) := g_package||'DELETE_FUNCTION';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_FUNCTION;
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
    FF_FUNCTIONS_BK3.DELETE_FUNCTION_b
      ( p_function_id              => p_function_id
       ,p_object_version_number    => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FUNCTION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- delete all context usages for this function before deleting function
  --
  open csr_function_context;
  loop
  fetch csr_function_context into l_function_id
                                 ,l_context_sequence_number
				 ,l_context_ovn;
  exit when csr_function_context%notfound;
      FF_FUNCTION_CONTEXT_USG_API.DELETE_CONTEXT
         (p_validate               => p_validate
         ,p_function_id            => l_function_id
         ,p_sequence_number        => l_context_sequence_number
         ,p_object_version_number  => l_context_ovn
         );
  end loop;
  close csr_function_context;

  -- delete all parameter for this function before deleting function
  --
  open csr_function_parameter;
  loop
  fetch csr_function_parameter into l_function_id
                                   ,l_parameter_sequence_number
				   ,l_parameter_ovn;
  exit when csr_function_parameter%notfound;
      FF_FUNCTION_PARAMETERS_API.DELETE_PARAMETER
         (p_validate               => p_validate
         ,p_function_id            => l_function_id
         ,p_sequence_number        => l_parameter_sequence_number
         ,p_object_version_number  => l_parameter_ovn
         );
  end loop;
  close csr_function_parameter;

  --
  -- Process Logic
  --

  ff_ffn_del.del
      ( p_function_id              => p_function_id
       ,p_object_version_number    => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    FF_FUNCTIONS_BK3.DELETE_FUNCTION_a
      ( p_function_id              => p_function_id
       ,p_object_version_number    => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FUNCTION'
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
    rollback to DELETE_FUNCTION;
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
    rollback to DELETE_FUNCTION;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_FUNCTION;
--

end FF_FUNCTIONS_API;

/
