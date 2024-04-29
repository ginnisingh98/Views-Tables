--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIGURATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIGURATION_API" AS
/* $Header: pecnfapi.pkb 120.0 2005/05/31 06:46:23 appldev noship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := 'per_ri_configuration_api.';
--
--------------------------------------------------------------------------------
g_dummy number(1);      -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- |-----------------------------< create_configurations >--------------------------|
-- ----------------------------------------------------------------------------------
--
Procedure create_configuration
  (   p_validate                      In  Boolean   Default False
     ,p_configuration_code            In  Varchar2
     ,p_configuration_type            In  Varchar2
     ,p_configuration_status          In  Varchar2
     ,p_configuration_name            In  Varchar2
     ,p_configuration_description     In  Varchar2
     ,p_language_code                 In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                In  Date
     ,p_object_version_number         Out Nocopy Number

  ) Is
  --
  -- Declare cursors and local variables
  --
  l_proc                  Varchar2(72) := g_package||'create_configuration';
  l_object_version_number hr_locations_all.object_version_number%TYPE;
  l_language_code         per_ri_configurations_tl.language%TYPE;
  l_effective_date        Date;

  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  Savepoint create_configuration;
  --
  hr_utility.set_location(l_proc, 15);
  per_cnf_ins.set_base_key_value (p_configuration_code  => p_configuration_code );
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_effective_date := trunc (p_effective_date);
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
  -- Insert non-translatable rows into PER_RI_configurationS first
   per_cnf_ins.ins
    (p_effective_date                 => l_effective_date
    ,p_configuration_code             => p_configuration_code
    ,p_configuration_type             => p_configuration_type
    ,p_configuration_status           => p_configuration_status
    ,p_object_version_number          => l_object_version_number
   );
  --
  --  Now insert translatable rows in PER_RI_configurationS_TL table
  per_cnt_ins.ins_tl
    ( p_effective_date            => l_effective_date
     ,p_configuration_code        => p_configuration_code
     ,p_configuration_name        => p_configuration_name
     ,p_configuration_description => p_configuration_description
     ,p_language_code              => l_language_code
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
    Rollback To create_configuration;
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
    Rollback To create_configuration;
    -- Set OUT parameters.
    p_object_version_number  := Null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
   --
End create_configuration;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_configurations >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_configuration
  (   p_validate                       In  Boolean   Default False
     ,p_configuration_code             In  Varchar2
     ,p_configuration_type             In  Varchar2  Default hr_api.g_varchar2
     ,p_configuration_status           In  Varchar2  Default hr_api.g_varchar2
     ,p_configuration_name             In  Varchar2  Default hr_api.g_varchar2
     ,p_configuration_description      In  Varchar2  Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In Out Nocopy Number
  ) Is
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_configuration';
  l_object_version_number hr_locations.object_version_number%TYPE;
  l_language_code         hr_locations_all_tl.language%TYPE;
  l_configuration_creation_date Date;
  l_effective_date        DATE;

  l_temp_ovn   number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_configuration;
  --
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_effective_date := trunc (p_effective_date);

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
  -- Insert non-translatable rows in PER_RI_configurationS Table
  --
     per_cnf_upd.upd
          ( p_configuration_code             => p_configuration_code
           ,p_configuration_type             => p_configuration_type
           ,p_configuration_status           => p_configuration_status
           ,p_effective_date                 => l_effective_date
           ,p_object_version_number          => l_object_version_number);
  --
  --  Now insert translatable rows in PER_RI_configurationS_TL table

  per_cnt_upd.upd_tl
    ( p_configuration_code         => p_configuration_code
     ,p_configuration_name         => p_configuration_name
     ,p_configuration_description  => p_configuration_description
     ,p_language_code              => l_language_code
     ,p_effective_date             => l_effective_date
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
    Rollback To update_configuration;
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
    Rollback To update_configuration;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
    --
End update_configuration;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_location >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_configuration
   (  p_validate                     In Boolean Default False
     ,p_configuration_code          In Varchar2
     ,p_object_version_number        IN Number )

Is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc Varchar2(72) := g_package||'delete_configuration';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  Savepoint delete_configuration;

 --
  -- Process Logic
  -- =============
  --
  --  Need to lock main table to maintain the locking ladder order
  --
  hr_utility.set_location( l_proc, 30);
  per_cnf_shd.lck ( p_configuration_code    => p_configuration_code,
                    p_object_version_number  => p_object_version_number );
  --
  --  Remove all matching translation rows
  --
  hr_utility.set_location( l_proc, 35);

  per_cnt_del.del_tl( p_configuration_code => p_configuration_code );
  --
  --  Remove non-translated data row
  --
  hr_utility.set_location( l_proc, 40);

  per_cnf_del.del(p_configuration_code   => p_configuration_code,
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
    Rollback To delete_configuration;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occurred
    Rollback To delete_configuration;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
End delete_configuration;

--

End per_ri_configuration_api;

/
