--------------------------------------------------------
--  DDL for Package Body FF_GLOBALS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_GLOBALS_API" as
/* $Header: fffglapi.pkb 120.0.12010000.2 2008/08/05 10:20:50 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ff_globals_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_global >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_global
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_global_name                   in     varchar2
  ,p_global_description            in     varchar2
  ,p_data_type                     in     varchar2
  ,p_value                         in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_global_id                        out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'create_global';
  l_global_id             number;
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_global;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
	ff_globals_bk1.create_global_b
	(p_effective_date        =>  l_effective_date
	,p_global_name           =>  p_global_name
	,p_global_description    =>  p_global_description
	,p_data_type             =>  p_data_type
	,p_value                 =>  p_value
	,p_business_group_id     =>  p_business_group_id
	,p_legislation_code      =>  p_legislation_code
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_global'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ff_fgl_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_global_name                    => p_global_name
  ,p_global_description             => p_global_description
  ,p_data_type                      => p_data_type
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_global_value                   => p_value
  ,p_global_id                      => l_global_id
  ,p_object_version_number          => l_object_version_number
  ,p_effective_start_date           => l_effective_start_date
  ,p_effective_end_date             => l_effective_end_date
  ) ;

  --
  -- Call After Process User Hook
  --
  begin
      ff_globals_bk1.create_global_a
        (p_effective_date             =>  l_effective_date
        ,p_global_name                =>  p_global_name
	,p_global_description         =>  p_global_description
	,p_data_type                  =>  p_data_type
	,p_value                      =>  p_value
	,p_business_group_id          =>  p_business_group_id
	,p_legislation_code           =>  p_legislation_code
	,p_global_id                  =>  l_global_id
        ,p_object_version_number      =>  l_object_version_number
        ,p_effective_start_date       =>  l_effective_start_date
        ,p_effective_end_date         =>  l_effective_end_date
	);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_global'
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
   p_global_id               := l_global_id ;
   p_object_version_number   := l_object_version_number ;
   p_effective_start_date    := l_effective_start_date ;
   p_effective_end_date      := l_effective_end_date ;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_global;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_global_id               := null ;
    p_object_version_number   := null ;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_global;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_global_id               := null ;
    p_object_version_number   := null ;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_global;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_global >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_global
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_global_id                     in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_value                         in     varchar2 default HR_API.G_VARCHAR2
  ,p_description                   in     varchar2 default HR_API.G_VARCHAR2
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date       date;
  l_proc                 varchar2(72) := g_package||'update_global';
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_global;
  --
  -- Remember IN OUT parameter IN values
  --
  l_in_out_parameter := p_object_version_number;
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
	ff_globals_bk2.update_global_b
	(p_effective_date             => l_effective_date
	,p_global_id                  => p_global_id
	,p_datetrack_update_mode      => p_datetrack_update_mode
	,p_value                      => p_value
	,p_object_version_number      => l_object_version_number
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_global'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ff_fgl_upd.upd
  (p_effective_date               => l_effective_date
  ,p_datetrack_mode               => p_datetrack_update_mode
  ,p_global_id                    => p_global_id
  ,p_object_version_number        => l_object_version_number
  ,p_global_value                 => p_value
  ,p_global_description           => p_description
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ) ;
  --
  -- Call After Process User Hook
  --
  begin
      ff_globals_bk2.update_global_a
        (p_effective_date             => l_effective_date
	,p_global_id                  => p_global_id
	,p_datetrack_update_mode      => p_datetrack_update_mode
	,p_value                      => p_value
	,p_object_version_number      => l_object_version_number
        ,p_effective_start_date       => l_effective_start_date
        ,p_effective_end_date         => l_effective_end_date
	);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_global'
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
   p_object_version_number   := l_object_version_number ;
   p_effective_start_date    := l_effective_start_date ;
   p_effective_end_date      := l_effective_end_date ;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_global;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := l_in_out_parameter;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_global;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number   := l_in_out_parameter;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_global;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_global >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_global
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_global_id                     in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date       date;
  l_proc                 varchar2(72) := g_package||'delete_global';
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_global;
  --
  -- Remember IN OUT parameter IN values
  --
  l_in_out_parameter := p_object_version_number;
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
	ff_globals_bk3.delete_global_b
	(p_effective_date           =>  l_effective_date
	,p_global_id                =>  p_global_id
	,p_datetrack_update_mode    =>  p_datetrack_update_mode
	,p_object_version_number    =>  l_object_version_number
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_global'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ff_fgl_del.del
    (p_effective_date             => l_effective_date
    ,p_datetrack_mode             => p_datetrack_update_mode
    ,p_global_id                  => p_global_id
    ,p_object_version_number      => l_object_version_number
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    );
  --
  -- Call After Process User Hook
  --
  begin
      ff_globals_bk3.delete_global_a
      	(p_effective_date           =>  l_effective_date
	,p_global_id                =>  p_global_id
	,p_datetrack_update_mode    =>  p_datetrack_update_mode
	,p_object_version_number    =>  l_object_version_number
	,p_effective_start_date     =>  l_effective_start_date
        ,p_effective_end_date       =>  l_effective_end_date
	);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_global'
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
   p_object_version_number   := l_object_version_number ;
   p_effective_start_date    := l_effective_start_date ;
   p_effective_end_date      := l_effective_end_date ;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_global;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := l_in_out_parameter;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_global;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number   := l_in_out_parameter;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_global;
--

end ff_globals_api;

/
