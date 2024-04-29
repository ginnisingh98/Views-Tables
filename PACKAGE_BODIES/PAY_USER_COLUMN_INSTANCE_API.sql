--------------------------------------------------------
--  DDL for Package Body PAY_USER_COLUMN_INSTANCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_COLUMN_INSTANCE_API" as
/* $Header: pyuciapi.pkb 115.0 2003/09/23 07:27 tvankayl noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_user_column_instance_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_user_column_instance >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_column_instance
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_user_row_id                   in     number
  ,p_user_column_id                in     number
  ,p_value                         in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_user_column_instance_id          out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'create_user_column_instance';
  l_user_column_instance_id number;
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_user_column_instance;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
	pay_user_column_instance_bk1.create_user_column_instance_b
	(p_effective_date    =>  l_effective_date
	,p_user_row_id       =>  p_user_row_id
	,p_user_column_id    =>  p_user_column_id
	,p_value             =>  p_value
	,p_business_group_id =>  p_business_group_id
	,p_legislation_code  =>  p_legislation_code
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_column_instance'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_uci_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_user_row_id                    => p_user_row_id
  ,p_user_column_id                 => p_user_column_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_value                          => p_value
  ,p_user_column_instance_id        => l_user_column_instance_id
  ,p_object_version_number          => l_object_version_number
  ,p_effective_start_date           => l_effective_start_date
  ,p_effective_end_date             => l_effective_end_date
  ) ;

  --
  -- Call After Process User Hook
  --
  begin
      pay_user_column_instance_bk1.create_user_column_instance_a
        (p_effective_date             =>  l_effective_date
        ,p_user_row_id                =>  p_user_row_id
	,p_user_column_id             =>  p_user_column_id
	,p_value                      =>  p_value
	,p_business_group_id          =>  p_business_group_id
	,p_legislation_code           =>  p_legislation_code
	,p_user_column_instance_id    => l_user_column_instance_id
        ,p_object_version_number      => l_object_version_number
        ,p_effective_start_date       => l_effective_start_date
        ,p_effective_end_date         => l_effective_end_date
	);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_column_instance'
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
   p_user_column_instance_id := l_user_column_instance_id ;
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
    rollback to create_user_column_instance;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_user_column_instance_id := null ;
    p_object_version_number   := null ;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_user_column_instance;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_user_column_instance_id := null ;
    p_object_version_number   := null ;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_user_column_instance;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_user_column_instance >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_column_instance
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_user_column_instance_id       in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_value                         in     varchar2 default HR_API.G_VARCHAR2
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date       date;
  l_proc                 varchar2(72) := g_package||'update_user_column_instance';
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_user_column_instance;
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
	pay_user_column_instance_bk2.update_user_column_instance_b
	(p_effective_date             => l_effective_date
	,p_user_column_instance_id    => p_user_column_instance_id
	,p_datetrack_update_mode      => p_datetrack_update_mode
	,p_value                      => p_value
	,p_object_version_number      => l_object_version_number
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_column_instance'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_uci_upd.upd
  (p_effective_date               => l_effective_date
  ,p_datetrack_mode               => p_datetrack_update_mode
  ,p_user_column_instance_id      => p_user_column_instance_id
  ,p_object_version_number        => l_object_version_number
  ,p_value                        => p_value
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ) ;
  --
  -- Call After Process User Hook
  --
  begin
      pay_user_column_instance_bk2.update_user_column_instance_a
        (p_effective_date             => l_effective_date
	,p_user_column_instance_id    => p_user_column_instance_id
	,p_datetrack_update_mode      => p_datetrack_update_mode
	,p_value                      => p_value
	,p_object_version_number      => l_object_version_number
        ,p_effective_start_date       => l_effective_start_date
        ,p_effective_end_date         => l_effective_end_date
	);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_column_instance'
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
    rollback to update_user_column_instance;
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
    rollback to update_user_column_instance;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number   := l_in_out_parameter;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_user_column_instance;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_user_column_instance >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_column_instance
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_user_column_instance_id       in     number
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
  l_proc                 varchar2(72) := g_package||'delete_user_column_instance';
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_user_column_instance;
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
	pay_user_column_instance_bk3.delete_user_column_instance_b
	(p_effective_date           =>  l_effective_date
	,p_user_column_instance_id  =>  p_user_column_instance_id
	,p_datetrack_update_mode    =>  p_datetrack_update_mode
	,p_object_version_number    =>  l_object_version_number
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_column_instance'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_uci_del.del
    (p_effective_date             => l_effective_date
    ,p_datetrack_mode             => p_datetrack_update_mode
    ,p_user_column_instance_id    => p_user_column_instance_id
    ,p_object_version_number      => l_object_version_number
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    );
  --
  -- Call After Process User Hook
  --
  begin
      pay_user_column_instance_bk3.delete_user_column_instance_a
      	(p_effective_date           =>  l_effective_date
	,p_user_column_instance_id  =>  p_user_column_instance_id
	,p_datetrack_update_mode    =>  p_datetrack_update_mode
	,p_object_version_number    =>  l_object_version_number
	,p_effective_start_date     =>  l_effective_start_date
        ,p_effective_end_date       =>  l_effective_end_date
	);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_column_instance'
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
    rollback to delete_user_column_instance;
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
    rollback to delete_user_column_instance;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number   := l_in_out_parameter;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_user_column_instance;
--

end pay_user_column_instance_api;

/
