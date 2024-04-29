--------------------------------------------------------
--  DDL for Package Body PSP_SALARY_CAPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_SALARY_CAPS_API" as
/* $Header: PSPSCAIB.pls 120.0 2005/11/20 23:56:00 dpaudel noship $ */
--
-- Package Variables
--
  g_package  varchar2(33) := '    psp_salary_caps_api.';
  p_legislation_code  varchar(50):=hr_api.userenv_lang;

--
-- ----------------------------------------------------------------------------
-- |-------------------------- create_salary_cap --------------------|
-- ----------------------------------------------------------------------------
--
procedure create_salary_cap
  ( p_validate                  in     boolean  default false
  , p_funding_source_code    	in	varchar2
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  , p_seed_flag              	in	varchar2
  , p_object_version_number  	in out nocopy number
  , p_salary_cap_id          	out	nocopy   number
  , p_return_status             out	nocopy  boolean
  )
 IS
	--
	-- Declare cursors and local variables
	--
  l_object_version_number  number(9);
  l_proc                varchar2(72) := g_package||'create_salary_cap';
  l_start_date		date;
  l_end_date		date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_salary_cap;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date := trunc(p_start_date);
  l_end_date := trunc(p_end_date);

  --
  -- Call Before Process User Hook
  --
  begin
    psp_salary_caps_bk1.create_salary_cap_b
		  ( p_funding_source_code       =>     p_funding_source_code
		  , p_start_date         	=>     l_start_date
		  , p_end_date           	=>     l_end_date
		  , p_currency_code      	=>     p_currency_code
		  , p_annual_salary_cap  	=>     p_annual_salary_cap
		  , p_seed_flag          	=>     p_seed_flag
		  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_salary_cap'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	psp_psc_ins.ins
		  ( p_salary_cap_id             =>   p_salary_cap_id
		  , p_funding_source_code       =>   p_funding_source_code
		  , p_start_date         	=>   l_start_date
		  , p_end_date           	=>   l_end_date
		  , p_currency_code      	=>   p_currency_code
		  , p_annual_salary_cap  	=>   p_annual_salary_cap
		  , p_seed_flag          	=>   p_seed_flag
		  , p_object_version_number     =>   p_object_version_number
		  );

  --
  -- Call After Process User Hook
  --
  begin
     psp_salary_caps_bk1.create_salary_cap_a
		  ( p_salary_cap_id             =>     p_salary_cap_id
		  , p_funding_source_code       =>     p_funding_source_code
		  , p_start_date         	=>     l_start_date
		  , p_end_date           	=>     l_end_date
		  , p_currency_code      	=>     p_currency_code
		  , p_annual_salary_cap  	=>     p_annual_salary_cap
		  , p_seed_flag          	=>     p_seed_flag
		  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_salary_cap'
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
--  p_object_version_number  := l_object_version_number;

	--
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_salary_cap;
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
    rollback to create_salary_cap;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_salary_cap;








--
-- ----------------------------------------------------------------------------
-- |---------------------- update_salary_cap ----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_salary_cap
  ( p_validate                  in     boolean  default false
  , p_salary_cap_id          	in	number
  , p_funding_source_code    	in	varchar2
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  , p_seed_flag              	in	varchar2
  , p_object_version_number  	in out nocopy number
  , p_return_status             out	nocopy  boolean
) is
  --
  -- Declare cursors and local variables
  --
	l_object_version_number number(9);
	l_proc                  varchar2(72) := g_package||'update_salary_cap';
	l_start_date		date;
	l_end_date		date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_salary_cap;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date := trunc(p_start_date);
  l_end_date := trunc(p_end_date);

  --
  -- Call Before Process User Hook
  --
  begin
    psp_salary_caps_bk2.update_salary_cap_b
		  ( p_salary_cap_id             =>     p_salary_cap_id
		  , p_funding_source_code       =>     p_funding_source_code
		  , p_start_date         	=>     l_start_date
		  , p_end_date           	=>     l_end_date
		  , p_currency_code      	=>     p_currency_code
		  , p_annual_salary_cap  	=>     p_annual_salary_cap
		  , p_seed_flag          	=>     p_seed_flag
		  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_salary_cap'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler upd procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   psp_psc_upd.upd
		  ( p_salary_cap_id             =>   p_salary_cap_id
		  , p_funding_source_code       =>   p_funding_source_code
		  , p_start_date         	=>   l_start_date
		  , p_end_date           	=>   l_end_date
		  , p_currency_code      	=>   p_currency_code
		  , p_annual_salary_cap  	=>   p_annual_salary_cap
		  , p_seed_flag          	=>   p_seed_flag
		  , p_object_version_number     =>   p_object_version_number
		  );


  --
  -- Call After Process User Hook
  --
  begin
     psp_salary_caps_bk2.update_salary_cap_a
		  ( p_salary_cap_id             =>     p_salary_cap_id
		  , p_funding_source_code       =>     p_funding_source_code
		  , p_start_date         	=>     l_start_date
		  , p_end_date           	=>     l_end_date
		  , p_currency_code      	=>     p_currency_code
		  , p_annual_salary_cap  	=>     p_annual_salary_cap
		  , p_seed_flag          	=>     p_seed_flag
		  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_salary_cap'
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

	hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_salary_cap;
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
    rollback to update_salary_cap;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_salary_cap;





--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_salary_cap >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_cap
  ( p_validate                  in     boolean  default false
  , p_salary_cap_id          	in	number
  , p_object_version_number  	in out nocopy number
  , p_return_status             out	nocopy  boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  number(9);
  l_proc                varchar2(72) := g_package||'delete_salary_cap';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_salary_cap;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
    psp_salary_caps_bk3.delete_salary_cap_b
    (  	 p_salary_cap_id      	=>	p_salary_cap_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_salary_cap'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler del procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  psp_psc_del.del
   ( p_salary_cap_id   =>  p_salary_cap_id
   , p_object_version_number		=>  p_object_version_number
   );


  --
  -- Call After Process User Hook
  --
  begin
     psp_salary_caps_bk3.delete_salary_cap_a
      (	 p_salary_cap_id  =>	 p_salary_cap_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_salary_cap'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_salary_cap;
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
    rollback to delete_salary_cap;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_salary_cap;
--
end psp_salary_caps_api;

/
