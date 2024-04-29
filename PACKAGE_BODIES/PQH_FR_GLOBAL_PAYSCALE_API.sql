--------------------------------------------------------
--  DDL for Package Body PQH_FR_GLOBAL_PAYSCALE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_GLOBAL_PAYSCALE_API" as
/* $Header: pqginapi.pkb 115.3 2004/02/23 03:22:46 svorugan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_fr_global_payscale_api.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_indemnity_rate>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_indemnity_rate
  ( p_validate                      in     boolean  default false
   ,p_effective_date                 in     date
   ,p_basic_salary_rate              in     number   default null
   ,p_housing_indemnity_rate              in     number   default null
   ,p_currency_code                  in     varchar2
   ,p_global_index_id                   out nocopy number
   ,p_object_version_number             out nocopy number
   ,p_effective_start_date              out nocopy date
   ,p_effective_end_date                out nocopy date
   )
   is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'create_indemnity_rate';
  l_object_version_number number(9);
  l_global_index_id     pqh_fr_global_indices_f.global_index_id%type;
  l_effective_start_date date;
  l_effective_end_date   date;

begin

  g_debug := hr_utility.debug_enabled;

 if g_debug then
 --
  hr_utility.set_location('Entering:'|| l_proc, 10);
 --
 End if;

  --
  -- Issue a savepoint
  --
  savepoint create_indemnity_rate;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_global_payscale_bk1.create_indemnity_rate_b
        (
          p_effective_date               =>  l_effective_date
	 ,p_basic_salary_rate            =>  p_basic_salary_rate
	 ,p_housing_indemnity_rate            =>  p_housing_indemnity_rate
	 ,p_currency_code                =>  p_currency_code
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_INDEMNITY_RATE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
     pqh_gin_ins.ins
            (p_effective_date                 => l_effective_date
	    ,p_type_of_record                 => 'INM'
	    ,p_basic_salary_rate              => p_basic_salary_rate
	    ,p_housing_indemnity_rate         => p_housing_indemnity_rate
	    ,p_currency_code		      => p_currency_code
	    ,p_global_index_id                => l_global_index_id
	    ,p_object_version_number          => l_object_version_number
	    ,p_effective_start_date           => l_effective_start_date
	    ,p_effective_end_date             => l_effective_end_date
	    );

  --
  -- Call After Process User Hook
  --
  begin

  pqh_fr_global_payscale_bk1.create_indemnity_rate_a
    ( p_effective_date                 => l_effective_date
     ,p_basic_salary_rate              => p_basic_salary_rate
     ,p_housing_indemnity_rate         => p_housing_indemnity_rate
     ,p_currency_code                  => p_currency_code
     ,p_global_index_id                => l_global_index_id
     ,p_object_version_number          => l_object_version_number
     ,p_effective_start_date           => l_effective_start_date
     ,p_effective_end_date             => l_effective_end_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_INDEMNITY_RATE'
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
  p_global_index_id := l_global_index_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
    --
 if g_debug then
 --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
 --
 End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_indemnity_rate;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_global_index_id := null;
  p_object_version_number  := null;
  p_effective_start_date   := null;
  p_effective_end_date     := null;

  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
  End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_indemnity_rate;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_global_index_id := null;
  p_object_version_number  := null;
  p_effective_start_date   := null;
  p_effective_end_date     := null;

    raise;

end create_indemnity_rate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_global_index >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_global_index
  (p_validate                      in     boolean  default false
   ,p_effective_date                 in     date
   ,p_gross_index                    in     number   default null
   ,p_increased_index                in     number   default null
   ,p_global_index_id                   out nocopy number
   ,p_object_version_number             out nocopy number
   ,p_effective_start_date              out nocopy date
   ,p_effective_end_date                out nocopy date
   ) is

  --
  -- Declare cursors and local variables
  --
    l_in_out_parameter    number;
    l_effective_date      date;
    l_proc                varchar2(72) := g_package||'create_global_index';
    l_object_version_number number(9);
    l_global_index_id     pqh_fr_global_indices_f.global_index_id%type;
    l_effective_start_date date;
    l_effective_end_date   date;

  begin

    g_debug := hr_utility.debug_enabled;

   if g_debug then
   --
    hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   End if;

    --
    -- Issue a savepoint
    --
    savepoint create_global_index;
    --
    --
    -- Remember IN OUT parameter IN values
    --
    --
    -- Truncate the time portion from all IN date parameters
    --
    l_effective_date := trunc(p_effective_date);

    --
    -- Call Before Process User Hook
    --
    begin
         pqh_fr_global_payscale_bk2.create_global_index_b
            (p_effective_date                 => l_effective_date
	    ,p_gross_index                    => p_gross_index
	    ,p_increased_index                => p_increased_index
	    );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GLOBAL_INDEX'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location('After Before Hook :'|| l_proc, 11);
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
     pqh_gin_ins.ins
            (p_effective_date                 => l_effective_date
     	    ,p_type_of_record                 => 'IND'
	    ,p_gross_index                    => p_gross_index
	    ,p_increased_index                => p_increased_index
     	    ,p_global_index_id                => l_global_index_id
     	    ,p_object_version_number          => l_object_version_number
     	    ,p_effective_start_date           => l_effective_start_date
     	    ,p_effective_end_date             => l_effective_end_date
     	    );
  --
  hr_utility.set_location('After Process Logic:'|| l_proc, 12);
  -- Call After Process User Hook
  --
  begin

  pqh_fr_global_payscale_bk2.create_global_index_a
            (p_effective_date                 => l_effective_date
	    ,p_gross_index                    => p_gross_index
	    ,p_increased_index                => p_increased_index
     	    ,p_global_index_id                => l_global_index_id
     	    ,p_object_version_number          => l_object_version_number
     	    ,p_effective_start_date           => l_effective_start_date
     	    ,p_effective_end_date             => l_effective_end_date
	    );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GLOBAL_INDEX'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  --
  hr_utility.set_location('After After Hook:'|| l_proc, 13);
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_global_index_id := l_global_index_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
    --
 if g_debug then
 --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
 --
 End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_global_index;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_global_index_id := null;
  p_object_version_number  := null;
  p_effective_start_date   := null;
  p_effective_end_date     := null;

  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
  End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_global_index;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_global_index_id := null;
  p_object_version_number  := null;
  p_effective_start_date   := null;
  p_effective_end_date     := null;

    raise;

end create_global_index;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<update_indemnity_rate >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_indemnity_rate
  (p_validate                      in     boolean  default false
   ,p_effective_date               in     date
   ,p_datetrack_mode               in     varchar2
   ,p_global_index_id              in     number
   ,p_object_version_number        in out nocopy number
   ,p_basic_salary_rate            in     number    default hr_api.g_number
   ,p_housing_indemnity_rate            in     number    default hr_api.g_number
   ,p_currency_code                in     varchar2
   ,p_effective_start_date            out nocopy date
   ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_indemnity_rate';
  l_object_version_number number(9);
  l_global_index_id     pqh_fr_global_indices_f.global_index_id%type;
  l_effective_start_date date;
  l_effective_end_date   date;

begin

  g_debug := hr_utility.debug_enabled;

 if g_debug then
 --
  hr_utility.set_location('Entering:'|| l_proc, 10);
 --
 End if;

  --
  -- Issue a savepoint
  --
  savepoint update_indemnity_rate;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  l_object_version_number := p_object_version_number;
  l_global_index_id	  := p_global_index_id;


  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_global_payscale_bk3.update_indemnity_rate_b
          (
	   p_effective_date               => l_effective_date
	   ,p_datetrack_mode              => p_datetrack_mode
	   ,p_global_index_id             => p_global_index_id
	   ,p_object_version_number       => p_object_version_number
	   ,p_basic_salary_rate           => p_basic_salary_rate
	   ,p_housing_indemnity_rate           => p_housing_indemnity_rate
	   ,p_currency_code               => p_currency_code
	   );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_INDEMNITY_RATE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
	pqh_gin_upd.upd
  		(p_effective_date         => l_effective_date
  		,p_datetrack_mode         => p_datetrack_mode
		,p_global_index_id        => p_global_index_id
  		,p_object_version_number  => p_object_version_number
  		,p_type_of_record         => 'INM'
  		,p_basic_salary_rate      => p_basic_salary_rate
  		,p_housing_indemnity_rate      => p_housing_indemnity_rate
  		,p_currency_code	  => p_currency_code
  		,p_effective_start_date   => l_effective_start_date
  		,p_effective_end_date     => l_effective_end_date
  		);

  --
  -- Call After Process User Hook
  --
  begin
       pqh_fr_global_payscale_bk3.update_indemnity_rate_a
          (
	   p_effective_date               => l_effective_date
	   ,p_datetrack_mode              => p_datetrack_mode
	   ,p_global_index_id             => p_global_index_id
	   ,p_object_version_number       => p_object_version_number
	   ,p_basic_salary_rate           => p_basic_salary_rate
	   ,p_housing_indemnity_rate           => p_housing_indemnity_rate
	   ,p_currency_code               => p_currency_code
	   ,p_effective_start_date        => l_effective_start_date
	   ,p_effective_end_date          => l_effective_end_date

	   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_INDEMNITY_RATE'
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
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_indemnity_rate;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
   p_object_version_number  := l_object_version_number;


   if g_debug then
   --
   hr_utility.set_location(' Leaving:'||l_proc, 80);
   --
   End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_indemnity_rate;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
     p_object_version_number  := l_object_version_number;

    raise;

end update_indemnity_rate;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_global_index >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_global_index
  (p_validate                      in     boolean  default false
   ,p_effective_date               in     date
   ,p_datetrack_mode               in     varchar2
   ,p_global_index_id              in     number
   ,p_object_version_number        in out nocopy number
   ,p_gross_index                  in     number    default hr_api.g_number
   ,p_increased_index              in     number    default hr_api.g_number
   ,p_effective_start_date            out nocopy date
   ,p_effective_end_date              out nocopy date
   ) is

  --
  -- Declare cursors and local variables
  --
    l_in_out_parameter    number;
    l_effective_date      date;
    l_proc                varchar2(72) := g_package||'update_global_index';
    l_object_version_number number(9);
    l_global_index_id     pqh_fr_global_indices_f.global_index_id%type;
    l_effective_start_date date;
    l_effective_end_date   date;

  begin

    g_debug := hr_utility.debug_enabled;

   if g_debug then
   --
    hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   End if;

    --
    -- Issue a savepoint
    --
    savepoint update_global_index;
    --
    --
    -- Remember IN OUT parameter IN values
    --
    --
    -- Truncate the time portion from all IN date parameters
    --
    l_effective_date := trunc(p_effective_date);

    --
    -- Call Before Process User Hook
    --
    begin
         pqh_fr_global_payscale_bk4.update_global_index_b
            (p_effective_date                 => l_effective_date
	    ,p_gross_index                    => p_gross_index
	    ,p_increased_index                => p_increased_index
	    ,p_datetrack_mode		      => p_datetrack_mode
	    ,p_global_index_id		      => p_global_index_id
	    ,p_object_version_number	      => p_object_version_number
	    ,p_effective_start_date         => p_effective_start_date
	    ,p_effective_end_date           => p_effective_end_date

	    );

   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GLOBAL_INDEX'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
     pqh_gin_upd.upd
            (p_effective_date                 => l_effective_date
     	    ,p_type_of_record                 => 'IND'
	    ,p_gross_index                    => p_gross_index
	    ,p_datetrack_mode		      => p_datetrack_mode
	    ,p_increased_index                => p_increased_index
     	    ,p_global_index_id                => p_global_index_id
     	    ,p_object_version_number          => p_object_version_number
     	    ,p_effective_start_date           => l_effective_start_date
     	    ,p_effective_end_date             => l_effective_end_date
     	    );
  --
  -- Call After Process User Hook
  --
  begin

   pqh_fr_global_payscale_bk4.update_global_index_a
            (p_effective_date                 => l_effective_date
	    ,p_gross_index                    => p_gross_index
	    ,p_increased_index                => p_increased_index
	    ,p_datetrack_mode		      => p_datetrack_mode
	    ,p_global_index_id		      => p_global_index_id
	    ,p_object_version_number	      => p_object_version_number
	    ,p_effective_start_date         => p_effective_start_date
	    ,p_effective_end_date           => p_effective_end_date
	    );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GLOBAL_INDEX'
        ,p_hook_type   => 'AP'
        );
  end;
  --
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
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
    --
 if g_debug then
 --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
 --
 End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_global_index;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_object_version_number  := null;
  p_effective_start_date   := null;
  p_effective_end_date     := null;

  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
  End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_global_index;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

  p_object_version_number  := null;
  p_effective_start_date   := null;
  p_effective_end_date     := null;

    raise;

end update_global_index;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<delete_indemnity_rate >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_indemnity_rate
   (p_validate                      in     boolean  default false
   ,p_effective_date                   in     date
   ,p_datetrack_mode                   in     varchar2
   ,p_global_index_id                  in     number
   ,p_object_version_number            in out nocopy number
   ,p_effective_start_date                out nocopy date
   ,p_effective_end_date                  out nocopy date
  )
    is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_indemnity_rate';
  l_object_version_number number(9);


begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  End if;

  --
  -- Issue a savepoint
  --
  savepoint delete_indemnity_rate;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

    l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --

  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_global_payscale_bk5.delete_indemnity_rate_b
         (p_effective_date                   => l_effective_date
          ,p_datetrack_mode                  => p_datetrack_mode
          ,p_global_index_id                 => p_global_index_id
          ,p_object_version_number           => p_object_version_number
         );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_INDEMNITY_RATE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

	   pqh_gin_del.del
	      (p_effective_date                   => l_effective_date
	      ,p_datetrack_mode                   => p_datetrack_mode
	      ,p_global_index_id                  => p_global_index_id
	      ,p_object_version_number            => p_object_version_number
	      ,p_effective_start_date             => p_effective_start_date
	      ,p_effective_end_date               => p_effective_end_date
	      );

  --
  -- Call After Process User Hook
  --
  begin
       pqh_fr_global_payscale_bk5.delete_indemnity_rate_a
         (p_effective_date                   => l_effective_date
          ,p_datetrack_mode                  => p_datetrack_mode
          ,p_global_index_id                 => p_global_index_id
          ,p_object_version_number           => p_object_version_number
	  ,p_effective_start_date            => p_effective_start_date
	  ,p_effective_end_date              => p_effective_end_date

         );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_INDEMNITY_RATE'
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
  -- p_object_version_number  := l_object_version_number;
    --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_indemnity_rate;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  if g_debug then
  --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
  End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_indemnity_rate;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
   raise;

end delete_indemnity_rate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<delete_global_index >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_global_index
  (p_validate                      in     boolean  default false
   ,p_effective_date                   in     date
   ,p_datetrack_mode                   in     varchar2
   ,p_global_index_id                  in     number
   ,p_object_version_number            in out nocopy number
   ,p_effective_start_date                out nocopy date
   ,p_effective_end_date                  out nocopy date
  )
Is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_global_index';
  l_object_version_number number(9);


begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  End if;

  --
  -- Issue a savepoint
  --
  savepoint delete_global_index;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

    l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --

  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_global_payscale_bk6.delete_global_index_b
         (p_effective_date                => l_effective_date
          ,p_datetrack_mode               => p_datetrack_mode
          ,p_global_index_id              => p_global_index_id
          ,p_object_version_number        => p_object_version_number
         );
exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GLOBAL_INDEX'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

	   pqh_gin_del.del
	      (p_effective_date                   => l_effective_date
	      ,p_datetrack_mode                   => p_datetrack_mode
	      ,p_global_index_id                  => p_global_index_id
	      ,p_object_version_number            => p_object_version_number
	      ,p_effective_start_date             => p_effective_start_date
	      ,p_effective_end_date               => p_effective_end_date
	      );
  --
  -- Call After Process User Hook
  --
  begin
       pqh_fr_global_payscale_bk6.delete_global_index_a
  	  (p_effective_date                => l_effective_date
          ,p_datetrack_mode                => p_datetrack_mode
          ,p_global_index_id               => p_global_index_id
          ,p_object_version_number         => p_object_version_number
	  ,p_effective_start_date          => p_effective_start_date
	  ,p_effective_end_date            => p_effective_end_date
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GLOBAL_INDEX'
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
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_global_index;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  if g_debug then
  --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
  End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_global_index;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null

    raise;

end delete_global_index;
--

end pqh_fr_global_payscale_api;

/
