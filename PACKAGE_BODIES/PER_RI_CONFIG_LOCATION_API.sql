--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_LOCATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_LOCATION_API" AS
/* $Header: pecnlapi.pkb 120.0 2005/05/31 06:50:56 appldev noship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := 'per_ri_config_location_api.';
--
--------------------------------------------------------------------------------
g_dummy number(1);      -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- |-----------------------------< create_location >--------------------------|
-- ----------------------------------------------------------------------------------
--
Procedure create_location
  (   p_validate                       In  Boolean   Default False
     ,p_configuration_code             In  Varchar2
     ,p_configuration_context          In  Varchar2
     ,p_location_code                  In  Varchar2
     ,p_description                    In  Varchar2  Default Null
     ,p_style                          In  Varchar2  Default Null
     ,p_address_line_1                 In  Varchar2  Default Null
     ,p_address_line_2                 In  Varchar2  Default Null
     ,p_address_line_3                 In  Varchar2  Default Null
     ,p_town_or_city                   In  Varchar2  Default Null
     ,p_country                        In  Varchar2  Default Null
     ,p_postal_code                    In  Varchar2  Default Null
     ,p_region_1                       In  Varchar2  Default Null
     ,p_region_2                       In  Varchar2  Default Null
     ,p_region_3                       In  Varchar2  Default Null
     ,p_telephone_number_1             In  Varchar2  Default Null
     ,p_telephone_number_2             In  Varchar2  Default Null
     ,p_telephone_number_3             In  Varchar2  Default Null
     ,p_loc_information13              In  Varchar2  Default Null
     ,p_loc_information14              In  Varchar2  Default Null
     ,p_loc_information15              In  Varchar2  Default Null
     ,p_loc_information16              In  Varchar2  Default Null
     ,p_loc_information17              In  Varchar2  Default Null
     ,p_loc_information18              In  Varchar2  Default Null
     ,p_loc_information19              In  Varchar2  Default Null
     ,p_loc_information20              In  Varchar2  Default Null
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          Out Nocopy Number
     ,p_location_id                    Out Nocopy Number
     )
     Is
  --
  -- Declare cursors and local variables
  --
  l_proc                  Varchar2(72) := g_package||'create_config_information';
  l_object_version_number hr_locations_all.object_version_number%TYPE;
  l_language_code         per_ri_workbench_items_tl.language%TYPE;
  l_effective_date        Date;

  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  Savepoint create_config_information;
  --
  hr_utility.set_location(l_proc, 15);
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
  -- Insert non-translatable rows into PER_RI_CONFIG_LOCATION first
   per_cnl_ins.ins
    (  p_effective_date                  => p_effective_date
      ,p_configuration_code              => p_configuration_code
      ,p_configuration_context           => p_configuration_context
      ,p_location_code                   => p_location_code
      ,p_description                     => p_description
      ,p_style                           => p_style
      ,p_address_line_1                  => p_address_line_1
      ,p_address_line_2                  => p_address_line_2
      ,p_address_line_3                  => p_address_line_3
      ,p_town_or_city                    => p_town_or_city
      ,p_country                         => p_country
      ,p_postal_code                     => p_postal_code
      ,p_region_1                        => p_region_1
      ,p_region_2                        => p_region_2
      ,p_region_3                        => p_region_3
      ,p_telephone_number_1              => p_telephone_number_1
      ,p_telephone_number_2              => p_telephone_number_2
      ,p_telephone_number_3              => p_telephone_number_3
      ,p_loc_information13               => p_loc_information13
      ,p_loc_information14               => p_loc_information14
      ,p_loc_information15               => p_loc_information15
      ,p_loc_information16               => p_loc_information16
      ,p_loc_information17               => p_loc_information17
      ,p_loc_information18               => p_loc_information18
      ,p_loc_information19               => p_loc_information19
      ,p_loc_information20               => p_loc_information20
      ,p_location_id                     => p_location_id
      ,p_object_version_number           => l_object_version_number
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
    Rollback To create_config_information;
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
    Rollback To create_config_information;
    -- Set OUT parameters.
    p_object_version_number  := Null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
   --
End create_location;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_location >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_location
  (   p_validate                       In  Boolean   Default False
     ,p_location_id                    In  Number
     ,p_configuration_code             In  Varchar2
     ,p_configuration_context          In  Varchar2
     ,p_location_code                  In  Varchar2
     ,p_description                    In  Varchar2  Default hr_api.g_varchar2
     ,p_style                          In  Varchar2  Default hr_api.g_varchar2
     ,p_address_line_1                 In  Varchar2  Default hr_api.g_varchar2
     ,p_address_line_2                 In  Varchar2  Default hr_api.g_varchar2
     ,p_address_line_3                 In  Varchar2  Default hr_api.g_varchar2
     ,p_town_or_city                   In  Varchar2  Default hr_api.g_varchar2
     ,p_country                        In  Varchar2  Default hr_api.g_varchar2
     ,p_postal_code                    In  Varchar2  Default hr_api.g_varchar2
     ,p_region_1                       In  Varchar2  Default hr_api.g_varchar2
     ,p_region_2                       In  Varchar2  Default hr_api.g_varchar2
     ,p_region_3                       In  Varchar2  Default hr_api.g_varchar2
     ,p_telephone_number_1             In  Varchar2  Default hr_api.g_varchar2
     ,p_telephone_number_2             In  Varchar2  Default hr_api.g_varchar2
     ,p_telephone_number_3             In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information13              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information14              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information15              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information16              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information17              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information18              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information19              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information20              In  Varchar2  Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In Out Nocopy Number
  ) Is
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_location';
  l_object_version_number hr_locations.object_version_number%TYPE;
  l_language_code         hr_locations_all_tl.language%TYPE;
  l_workbench_item_creation_date Date;
  l_effective_date        DATE;

  l_temp_ovn   number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_location;
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
  -- Insert non-translatable rows in PER_RI_CONFIG_INFORMATION Table
  --
     per_cnl_upd.upd
          ( p_effective_date            =>  p_effective_date
           ,p_location_id               =>  p_location_id
           ,p_object_version_number     =>  p_object_version_number
           ,p_configuration_code        =>  p_configuration_code
           ,p_configuration_context     =>  p_configuration_context
           ,p_location_code             =>  p_location_code
           ,p_description               =>  p_description
           ,p_style                     =>  p_style
           ,p_address_line_1            =>  p_address_line_1
           ,p_address_line_2            =>  p_address_line_2
           ,p_address_line_3            =>  p_address_line_3
           ,p_town_or_city              =>  p_town_or_city
           ,p_country                   =>  p_country
           ,p_postal_code               =>  p_postal_code
           ,p_region_1                  =>  p_region_1
           ,p_region_2                  =>  p_region_2
           ,p_region_3                  =>  p_region_3
           ,p_telephone_number_1        =>  p_telephone_number_1
           ,p_telephone_number_2        =>  p_telephone_number_2
           ,p_telephone_number_3        =>  p_telephone_number_3
           ,p_loc_information13         =>  p_loc_information13
           ,p_loc_information14         =>  p_loc_information14
           ,p_loc_information15         =>  p_loc_information15
           ,p_loc_information16         =>  p_loc_information16
           ,p_loc_information17         =>  p_loc_information17
           ,p_loc_information18         =>  p_loc_information18
           ,p_loc_information19         =>  p_loc_information19
           ,p_loc_information20         =>  p_loc_information20
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
    Rollback To update_location;
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
    Rollback To update_location;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
    --
End update_location;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_location >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_location
   (  p_validate                     In Boolean Default False
     ,p_location_id                  In Number
     ,p_object_version_number        IN Number )

Is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc Varchar2(72) := g_package||'delete_config_information';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  Savepoint delete_workbench_item;


  --

  hr_utility.set_location( l_proc, 40);

  per_cnl_del.del(p_location_id           => p_location_id
                 ,p_object_version_number => p_object_version_number);


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
    Rollback To delete_location;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occurred
    Rollback To delete_location;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
End delete_location;

--

End per_ri_config_location_api;

/
