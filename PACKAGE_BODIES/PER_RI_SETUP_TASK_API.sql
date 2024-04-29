--------------------------------------------------------
--  DDL for Package Body PER_RI_SETUP_TASK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_SETUP_TASK_API" AS
/* $Header: pestbapi.pkb 115.0 2003/07/03 06:24:02 kavenkat noship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := 'per_ri_setup_tasks_api.';
--
--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- |-----------------------------< create_setup_task >--------------------------|
-- ----------------------------------------------------------------------------------
--
Procedure create_setup_task
  (p_validate                       In     Boolean  Default False
  ,p_setup_task_code                In     varchar2
  ,p_workbench_item_code            in     varchar2
  ,p_setup_task_name                In     Varchar2
  ,p_setup_task_description         In     Varchar2
  ,p_setup_task_sequence            in     number
  ,p_setup_task_status              in     varchar2 default null
  ,p_setup_task_creation_date       in     date     default null
  ,p_setup_task_last_mod_date       in     date     default null
  ,p_setup_task_type                in     varchar2 default null
  ,p_setup_task_action              in     varchar2 default null
  ,p_language_code                  In     Varchar2  Default hr_api.userenv_lang
  ,p_effective_date                 in     date
  ,p_object_version_number          out    nocopy number
  ) Is
  --
  -- Declare cursors and local variables
  --
  l_proc                  Varchar2(72) := g_package||'create_setup_task';
  l_object_version_number per_ri_setup_tasks.object_version_number%TYPE;
  l_language_code         per_ri_setup_tasks_tl.language%TYPE;
  l_effective_date        Date;
  l_setup_task_creation_date Date;
  l_setup_task_last_mod_date Date;
  l_setup_task_code per_ri_setup_tasks.setup_task_code%TYPE;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  Savepoint create_setup_task;
  --
  hr_utility.set_location(l_proc, 15);
  per_stb_ins.set_base_key_value (p_setup_task_code  => p_setup_task_code );
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_effective_date := trunc (p_effective_date);
  l_setup_task_creation_date := trunc (p_setup_task_creation_date);
  l_setup_task_last_mod_date := trunc(p_setup_task_last_mod_date);
  --
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);

  -- Process Logic
  --
  -- Insert non-translatable rows into PER_RI_SETUP_TASKS first
   per_stb_ins.ins
           (p_workbench_item_code          => p_workbench_item_code
           ,p_setup_task_code              => l_setup_task_code
	   ,p_setup_task_sequence          => p_setup_task_sequence
	   ,p_setup_task_status            => p_setup_task_status
	   ,p_setup_task_creation_date     => l_setup_task_creation_date
	   ,p_setup_task_last_modified_dat => l_setup_task_last_mod_date
	   ,p_setup_task_type              => p_setup_task_type
	   ,p_setup_task_action            => p_setup_task_action
	   ,p_effective_date               => l_effective_date
	   ,p_object_version_number        => l_object_version_number
      );
  --
  --  Now insert translatable rows in PER_RI_SETUP_TASKS table
  per_stl_ins.ins_tl
     (p_setup_task_code                   =>p_setup_task_code
	  ,p_setup_task_name              =>p_setup_task_name
	  ,p_setup_task_description       =>p_setup_task_description
	  ,p_language_code                =>l_language_code
     );
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  If p_validate Then
    Raise hr_api.validate_enabled;
  End If;
  --
  -- Set all output arguments
  --
    p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
Exception
  --
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To create_setup_task;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := Null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occurred
    Rollback To create_setup_task;
    -- Set OUT parameters.
    p_object_version_number  := Null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
   --
End create_setup_task;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_setup_task >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_setup_task
  ( p_validate                    In  Boolean   Default False
  ,p_setup_task_code              in     varchar2
  ,p_workbench_item_code          in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_name              In     Varchar2  default hr_api.g_varchar2
  ,p_setup_task_description       In     Varchar2  default hr_api.g_varchar2
  ,p_setup_task_sequence          in     number    default hr_api.g_number
  ,p_setup_task_status            in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_creation_date     in     date      default hr_api.g_date
  ,p_setup_task_last_mod_date     in     date      default hr_api.g_date
  ,p_setup_task_type              in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_action            in     varchar2  default hr_api.g_varchar2
  ,p_language_code                  In     Varchar2  Default hr_api.userenv_lang
  ,p_effective_date               in     date
  ,p_object_version_number        In Out Nocopy Number
  ) Is
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_setup_task';
  l_object_version_number hr_locations.object_version_number%TYPE;
  l_language_code         hr_locations_all_tl.language%TYPE;
  l_setup_task_last_mod_date Date;
  l_setup_task_creation_date Date;
  l_effective_date        DATE;

  l_temp_ovn   number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_setup_task;
  --
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_effective_date := trunc (p_effective_date);
  l_setup_task_creation_date := trunc (p_setup_task_creation_date);
  l_setup_task_last_mod_date := trunc(p_setup_task_last_mod_date);
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to be
  -- passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Insert non-translatable rows in PER_RI_SETUP_TASKS Table
  --
         per_stb_upd.upd
			 (p_setup_task_code                     => p_setup_task_code
			 ,p_workbench_item_code          	=> p_workbench_item_code
			 ,p_setup_task_sequence          	=> p_setup_task_sequence
			 ,p_setup_task_status            	=> p_setup_task_status
			 ,p_setup_task_creation_date     	=> l_setup_task_creation_date
			 ,p_setup_task_last_modified_dat 	=> l_setup_task_last_mod_date
			 ,p_setup_task_type              	=> p_setup_task_type
			 ,p_setup_task_action            	=> p_setup_task_action
			 ,p_effective_date               	=> l_effective_date
			 ,p_object_version_number        	=> l_object_version_number
			 ) ;
  --
  --  Now insert translatable rows in PER_RI_SETUP_TASKS_TL table

  per_stl_upd.upd_tl
     ( p_setup_task_code               => p_setup_task_code
	   ,p_setup_task_name          => p_setup_task_name
	   ,p_setup_task_description   => p_setup_task_description
	   ,p_language_code            => l_language_code
     );

  --

  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  If p_validate Then
    Raise hr_api.validate_enabled;
  End If;
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
Exception
  --
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To update_setup_task;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occurred
    Rollback To update_setup_task;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
    --
End update_setup_task;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_location >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_setup_task
  ( p_validate                     In Boolean Default False
   ,p_setup_task_code                      in     varchar2
   ,p_object_version_number                in     number
  )

Is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc Varchar2(72) := g_package||'delete_setup_task';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  Savepoint delete_setup_task;

 --
  -- Process Logic
  -- =============
  --
  --  Need to lock main table to maintain the locking ladder order
  --
  hr_utility.set_location( l_proc, 30);
  per_stb_shd.lck ( p_setup_task_code        => p_setup_task_code,
                    p_object_version_number  => p_object_version_number );
  --
  --  Remove all matching translation rows
  --
  hr_utility.set_location( l_proc, 35);

  per_stl_del.del_tl( p_setup_task_code => p_setup_task_code );
  --
  --  Remove non-translated data row
  --
  hr_utility.set_location( l_proc, 40);

  per_stb_del.del(p_setup_task_code       => p_setup_task_code,
                  p_object_version_number => p_object_version_number );
  --
--
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  If p_validate Then
     Raise hr_api.validate_enabled;
  End If;
  --
  --
Exception
  --
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To delete_setup_task;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occurred
    Rollback To delete_setup_task;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
End delete_setup_task;

--

End PER_RI_SETUP_TASK_API;

/
