--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_INFORMATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_INFORMATION_API" AS
/* $Header: pecniapi.pkb 120.0 2005/05/31 06:48:18 appldev noship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := 'per_ri_config_information_api.';
--
--------------------------------------------------------------------------------
g_dummy number(1);      -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- |-----------------------------< create_workbench_items >--------------------------|
-- ----------------------------------------------------------------------------------
--
Procedure create_config_information
  (   p_validate                       In  Boolean   Default False
     ,p_configuration_code             In  Varchar2
     ,p_config_information_category    In  Varchar2
     ,p_config_sequence                In  Number
     ,p_config_information1            In  Varchar2  Default Null
     ,p_config_information2            In  Varchar2  Default Null
     ,p_config_information3            In  Varchar2  Default Null
     ,p_config_information4            In  Varchar2  Default Null
     ,p_config_information5            In  Varchar2  Default Null
     ,p_config_information6            In  Varchar2  Default Null
     ,p_config_information7            In  Varchar2  Default Null
     ,p_config_information8            In  Varchar2  Default Null
     ,p_config_information9            In  Varchar2  Default Null
     ,p_config_information10           In  Varchar2  Default Null
     ,p_config_information11           In  Varchar2  Default Null
     ,p_config_information12           In  Varchar2  Default Null
     ,p_config_information13           In  Varchar2  Default Null
     ,p_config_information14           In  Varchar2  Default Null
     ,p_config_information15           In  Varchar2  Default Null
     ,p_config_information16           In  Varchar2  Default Null
     ,p_config_information17           In  Varchar2  Default Null
     ,p_config_information18           In  Varchar2  Default Null
     ,p_config_information19           In  Varchar2  Default Null
     ,p_config_information20           In  Varchar2  Default Null
     ,p_config_information21           In  Varchar2  Default Null
     ,p_config_information22           In  Varchar2  Default Null
     ,p_config_information23           In  Varchar2  Default Null
     ,p_config_information24           In  Varchar2  Default Null
     ,p_config_information25           In  Varchar2  Default Null
     ,p_config_information26           In  Varchar2  Default Null
     ,p_config_information27           In  Varchar2  Default Null
     ,p_config_information28           In  Varchar2  Default Null
     ,p_config_information29           In  Varchar2  Default Null
     ,p_config_information30           In  Varchar2  Default Null
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_config_information_id          Out Nocopy Number
     ,p_object_version_number          Out Nocopy Number
  ) Is
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
  -- Insert non-translatable rows into PER_RI_CONFIG_INFORMATION first
   per_cni_ins.ins
    ( p_effective_date                   => p_effective_date
     ,p_configuration_code               => p_configuration_code
     ,p_config_information_category      => p_config_information_category
     ,p_config_sequence                  => p_config_sequence
     ,p_config_information1              => p_config_information1
     ,p_config_information2              => p_config_information2
     ,p_config_information3              => p_config_information3
     ,p_config_information4              => p_config_information4
     ,p_config_information5              => p_config_information5
     ,p_config_information6              => p_config_information6
     ,p_config_information7              => p_config_information7
     ,p_config_information8              => p_config_information8
     ,p_config_information9              => p_config_information9
     ,p_config_information10             => p_config_information10
     ,p_config_information11             => p_config_information11
     ,p_config_information12             => p_config_information12
     ,p_config_information13             => p_config_information13
     ,p_config_information14             => p_config_information14
     ,p_config_information15             => p_config_information15
     ,p_config_information16             => p_config_information16
     ,p_config_information17             => p_config_information17
     ,p_config_information18             => p_config_information18
     ,p_config_information19             => p_config_information19
     ,p_config_information20             => p_config_information20
     ,p_config_information21             => p_config_information21
     ,p_config_information22             => p_config_information22
     ,p_config_information23             => p_config_information23
     ,p_config_information24             => p_config_information24
     ,p_config_information25             => p_config_information25
     ,p_config_information26             => p_config_information26
     ,p_config_information27             => p_config_information27
     ,p_config_information28             => p_config_information28
     ,p_config_information29             => p_config_information29
     ,p_config_information30             => p_config_information30
     ,p_config_information_id            => p_config_information_id
     ,p_object_version_number            => l_object_version_number
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
End create_config_information;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_config_information >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_config_information
  (   p_validate                       In  Boolean   Default False
     ,p_config_information_id          In  Number
     ,p_configuration_code             In  Varchar2
     ,p_config_information_category    In  Varchar2
     ,p_config_sequence                In  Number    Default hr_api.g_number
     ,p_config_information1            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information2            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information3            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information4            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information5            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information6            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information7            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information8            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information9            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information10           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information11           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information12           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information13           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information14           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information15           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information16           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information17           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information18           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information19           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information20           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information21           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information22           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information23           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information24           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information25           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information26           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information27           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information28           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information29           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information30           In  Varchar2  Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In Out Nocopy Number
  ) Is
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_workbench_item';
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
  savepoint update_config_information;
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
     per_cni_upd.upd
          ( p_effective_date                   => p_effective_date
           ,p_config_information_id            => p_config_information_id
           ,p_configuration_code               => p_configuration_code
           ,p_config_information_category      => p_config_information_category
           ,p_config_sequence                  => p_config_sequence
           ,p_config_information1              => p_config_information1
           ,p_config_information2              => p_config_information2
           ,p_config_information3              => p_config_information3
           ,p_config_information4              => p_config_information4
           ,p_config_information5              => p_config_information5
           ,p_config_information6              => p_config_information6
           ,p_config_information7              => p_config_information7
           ,p_config_information8              => p_config_information8
           ,p_config_information9              => p_config_information9
           ,p_config_information10             => p_config_information10
           ,p_config_information11             => p_config_information11
           ,p_config_information12             => p_config_information12
           ,p_config_information13             => p_config_information13
           ,p_config_information14             => p_config_information14
           ,p_config_information15             => p_config_information15
           ,p_config_information16             => p_config_information16
           ,p_config_information17             => p_config_information17
           ,p_config_information18             => p_config_information18
           ,p_config_information19             => p_config_information19
           ,p_config_information20             => p_config_information20
           ,p_config_information21             => p_config_information21
           ,p_config_information22             => p_config_information22
           ,p_config_information23             => p_config_information23
           ,p_config_information24             => p_config_information24
           ,p_config_information25             => p_config_information25
           ,p_config_information26             => p_config_information26
           ,p_config_information27             => p_config_information27
           ,p_config_information28             => p_config_information28
           ,p_config_information29             => p_config_information29
           ,p_config_information30             => p_config_information30
           ,p_object_version_number            => l_object_version_number
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
    Rollback To update_config_information;
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
    Rollback To update_config_information;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
    --
End update_config_information;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_config_information >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_config_information
   (  p_validate                     In Boolean Default False
     ,p_config_information_id        In Number
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

  per_cni_del.del(p_config_information_id => p_config_information_id
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
    Rollback To delete_config_information;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occurred
    Rollback To delete_config_information;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
End delete_config_information;

--

End per_ri_config_information_api;

/
