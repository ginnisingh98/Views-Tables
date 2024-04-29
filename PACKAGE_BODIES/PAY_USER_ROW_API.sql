--------------------------------------------------------
--  DDL for Package Body PAY_USER_ROW_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_ROW_API" as
/* $Header: pypurapi.pkb 120.5 2008/04/08 09:44:58 salogana noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_user_row_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_user_row >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_row
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_user_table_id                 in     number
  ,p_row_low_range_or_name         in     varchar2
  ,p_display_sequence              in out nocopy NUMBER
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_disable_range_overlap_check   in     boolean  default false
  ,p_disable_units_check           in     boolean  default false
  ,p_row_high_range                in     varchar2 default null
  ,p_user_row_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
    /* Added for bug no: 6735596 */
  ,p_base_row_low_range_or_name    in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'create_user_row';
  l_user_row_id number;
  l_display_sequence number;
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_user_row;
  --
  -- Remember IN OUT parameter IN values
  --
  l_in_out_parameter := p_display_sequence;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Round the Display Sequence
  --
  l_display_sequence := round(p_display_sequence);

  --
  -- Call Before Process User Hook
  --
  begin
	pay_user_row_bk1.create_user_row_b
	(p_effective_date                => l_effective_date
	,p_user_table_id                 => p_user_table_id
	,p_row_low_range_or_name         => p_base_row_low_range_or_name
	,p_display_sequence              => l_display_sequence
	,p_business_group_id             => p_business_group_id
	,p_legislation_code              => p_legislation_code
	,p_disable_range_overlap_check   => p_disable_range_overlap_check
	,p_disable_units_check           => p_disable_units_check
	,p_row_high_range                => p_row_high_range
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_row'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_pur_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_user_table_id                  => p_user_table_id
  ,p_row_low_range_or_name          => p_base_row_low_range_or_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_display_sequence               => l_display_sequence
  ,p_row_high_range                 => p_row_high_range
  ,p_disable_units_check            => p_disable_units_check
  ,p_disable_range_overlap_check    => p_disable_range_overlap_check
  ,p_user_row_id                    => l_user_row_id
  ,p_object_version_number          => l_object_version_number
  ,p_effective_start_date           => l_effective_start_date
  ,p_effective_end_date             => l_effective_end_date
  ) ;
  --
  -- Call After Process User Hook
  --
  begin
      pay_user_row_bk1.create_user_row_a
      	(p_effective_date                => l_effective_date
	,p_user_table_id                 => p_user_table_id
	,p_row_low_range_or_name         => p_base_row_low_range_or_name
	,p_display_sequence              => l_display_sequence
	,p_business_group_id             => p_business_group_id
	,p_legislation_code              => p_legislation_code
	,p_disable_range_overlap_check   => p_disable_range_overlap_check
	,p_disable_units_check           => p_disable_units_check
	,p_row_high_range                => p_row_high_range
        ,p_user_row_id                   => l_user_row_id
        ,p_object_version_number         => l_object_version_number
        ,p_effective_start_date          => l_effective_start_date
        ,p_effective_end_date            => l_effective_end_date
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_row'
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
   p_display_sequence        := l_display_sequence ;
   p_user_row_id             := l_user_row_id ;
   p_object_version_number   := l_object_version_number ;
   p_effective_start_date    := l_effective_start_date ;
   p_effective_end_date      := l_effective_end_date ;

  --
----For MLS---------------------------------------------------------------------
  pay_urt_ins.ins_tl(userenv('lang'), p_user_row_id, p_row_low_range_or_name);
--------------------------------------------------------------------------------
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_user_row;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_display_sequence        := l_in_out_parameter;
    p_user_row_id             := null ;
    p_object_version_number   := null ;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_user_row;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_display_sequence        := l_in_out_parameter;
    p_user_row_id             := null ;
    p_object_version_number   := null ;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_user_row;

/* Since we added a parameter in create_user_row for bug fix 6735596
localization teams had issues.So we overloaded the create_user_row
to take 14 arguments and will call the package which has
15 arguments */

procedure create_user_row
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_user_table_id                 in     number
  ,p_row_low_range_or_name         in     varchar2
  ,p_display_sequence              in out nocopy NUMBER
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_disable_range_overlap_check   in     boolean  default false
  ,p_disable_units_check           in     boolean  default false
  ,p_row_high_range                in     varchar2 default null
  ,p_user_row_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  begin
  create_user_row
  (p_validate=>p_validate
  ,p_effective_date=>p_effective_date
  ,p_user_table_id =>p_user_table_id
  ,p_row_low_range_or_name=>p_row_low_range_or_name
  ,p_display_sequence=>p_display_sequence
  ,p_business_group_id=>p_business_group_id
  ,p_legislation_code=>p_legislation_code
  ,p_disable_range_overlap_check=>p_disable_range_overlap_check
  ,p_disable_units_check=>p_disable_units_check
  ,p_row_high_range=>p_row_high_range
  ,p_user_row_id=>p_user_row_id
  ,p_object_version_number=>p_object_version_number
  ,p_effective_start_date=>p_effective_start_date
  ,p_effective_end_date=>p_effective_end_date
    /* Added for bug no: 6735596 */
  ,p_base_row_low_range_or_name=>p_row_low_range_or_name);
  end;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_user_row >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_row
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_user_row_id                   in     number
  ,p_display_sequence              in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_row_low_range_or_name         in     varchar2 default hr_api.g_varchar2
  ,p_base_row_low_range_or_name    in     varchar2 default hr_api.g_varchar2
  ,p_disable_range_overlap_check   in     boolean  default false
  ,p_disable_units_check           in     boolean  default false
  ,p_row_high_range                in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter1    number;
  l_in_out_parameter2    number;
  l_effective_date       date;
  l_proc                 varchar2(72) := g_package||'update_user_row';
  l_display_sequence number;
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_user_row;
  --
  -- Remember IN OUT parameter IN values
  --
  l_in_out_parameter1 := p_display_sequence;
  l_in_out_parameter2 := p_object_version_number;
  --
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Round the Display Sequence
  --
  l_display_sequence := round(p_display_sequence);

  --
  -- Call Before Process User Hook
  --
  begin
	pay_user_row_bk2.update_user_row_b
	(p_effective_date                => l_effective_date
	,p_datetrack_update_mode         => p_datetrack_update_mode
	,p_user_row_id                   => p_user_row_id
	,p_display_sequence              => l_display_sequence
	,p_object_version_number         => l_object_version_number
	,p_row_low_range_or_name         => p_base_row_low_range_or_name
	,p_disable_range_overlap_check   => p_disable_range_overlap_check
	,p_disable_units_check           => p_disable_units_check
	,p_row_high_range                => p_row_high_range
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_row'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_pur_upd.upd
  (p_effective_date               => l_effective_date
  ,p_datetrack_mode               => p_datetrack_update_mode
  ,p_user_row_id                  => p_user_row_id
  ,p_object_version_number        => l_object_version_number
  ,p_row_low_range_or_name        => p_base_row_low_range_or_name
  ,p_display_sequence             => l_display_sequence
  ,p_row_high_range               => p_row_high_range
  ,p_disable_units_check          => p_disable_units_check
  ,p_disable_range_overlap_check  => p_disable_range_overlap_check
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ) ;
  --
  -- Call After Process User Hook
  --
  begin
      pay_user_row_bk2.update_user_row_a
        (p_effective_date                => l_effective_date
	,p_datetrack_update_mode         => p_datetrack_update_mode
	,p_user_row_id                   => p_user_row_id
	,p_display_sequence              => l_display_sequence
	,p_object_version_number         => l_object_version_number
	,p_row_low_range_or_name         => p_base_row_low_range_or_name
	,p_disable_range_overlap_check   => p_disable_range_overlap_check
	,p_disable_units_check           => p_disable_units_check
	,p_row_high_range                => p_row_high_range
	,p_effective_start_date          => l_effective_start_date
	,p_effective_end_date            => l_effective_end_date
	);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_row'
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
   p_display_sequence        := l_display_sequence ;
   p_object_version_number   := l_object_version_number ;
   p_effective_start_date    := l_effective_start_date ;
   p_effective_end_date      := l_effective_end_date ;

  --
----For MLS---------------------------------------------------------------------
  pay_urt_upd.upd_tl(userenv('lang'), p_user_row_id, p_row_low_range_or_name);
--------------------------------------------------------------------------------
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_user_row;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_display_sequence        := l_in_out_parameter1;
    p_object_version_number   := l_in_out_parameter2;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_user_row;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_display_sequence        := l_in_out_parameter1;
    p_object_version_number   := l_in_out_parameter2;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_user_row;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_user_row >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_row
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_user_row_id                   in     number
  ,p_object_version_number         in out nocopy number
  ,p_disable_range_overlap_check   in     boolean  default false
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date       date;
  l_proc                 varchar2(72) := g_package||'delete_user_row';
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_user_row;
  --
  -- Remember IN OUT parameter IN values
  --
  l_in_out_parameter := p_object_version_number;
  --
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
	pay_user_row_bk3.delete_user_row_b
	(p_effective_date              => l_effective_date
	,p_datetrack_update_mode       => p_datetrack_update_mode
	,p_user_row_id                 => p_user_row_id
	,p_object_version_number       => l_object_version_number
	,p_disable_range_overlap_check => p_disable_range_overlap_check
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_row'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_pur_del.del
     (p_effective_date              => l_effective_date
     ,p_datetrack_mode              => p_datetrack_update_mode
     ,p_user_row_id                 => p_user_row_id
     ,p_object_version_number       => l_object_version_number
     ,p_disable_range_overlap_check => p_disable_range_overlap_check
     ,p_effective_start_date        => l_effective_start_date
     ,p_effective_end_date          => l_effective_end_date
     );
  --
  -- Call After Process User Hook
  --
  begin
      pay_user_row_bk3.delete_user_row_a
        (p_effective_date              => l_effective_date
        ,p_datetrack_update_mode       => p_datetrack_update_mode
        ,p_user_row_id                 => p_user_row_id
	,p_object_version_number       => l_object_version_number
	,p_disable_range_overlap_check => p_disable_range_overlap_check
	,p_effective_start_date        => l_effective_start_date
        ,p_effective_end_date          => l_effective_end_date
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_row'
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
----For MLS---------------------------------------------------------------------
  if (UPPER(p_datetrack_update_mode) = 'ZAP') then
  pay_urt_del.del_tl(p_user_row_id);
  end if;
--------------------------------------------------------------------------------
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_user_row;
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
    rollback to delete_user_row;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number   := l_in_out_parameter;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_user_row;
--

end pay_user_row_api;

/
