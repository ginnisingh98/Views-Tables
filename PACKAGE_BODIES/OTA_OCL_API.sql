--------------------------------------------------------
--  DDL for Package Body OTA_OCL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OCL_API" as
/* $Header: otoclapi.pkb 120.0.12000000.2 2007/02/07 09:17:35 niarora noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_OCL_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_competence_language >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_competence_language
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_competence_language_id            out nocopy number
  ,p_competence_id                 in     number
  ,p_language_code                   in     varchar2
  ,p_business_group_id             in     number
  ,p_min_proficiency_level_id      in     number   default null
  ,p_ocl_information_category      in     varchar2 default null
  ,p_ocl_information1              in     varchar2 default null
  ,p_ocl_information2              in     varchar2 default null
  ,p_ocl_information3              in     varchar2 default null
  ,p_ocl_information4              in     varchar2 default null
  ,p_ocl_information5              in     varchar2 default null
  ,p_ocl_information6              in     varchar2 default null
  ,p_ocl_information7              in     varchar2 default null
  ,p_ocl_information8              in     varchar2 default null
  ,p_ocl_information9              in     varchar2 default null
  ,p_ocl_information10             in     varchar2 default null
  ,p_ocl_information11             in     varchar2 default null
  ,p_ocl_information12             in     varchar2 default null
  ,p_ocl_information13             in     varchar2 default null
  ,p_ocl_information14             in     varchar2 default null
  ,p_ocl_information15             in     varchar2 default null
  ,p_ocl_information16             in     varchar2 default null
  ,p_ocl_information17             in     varchar2 default null
  ,p_ocl_information18             in     varchar2 default null
  ,p_ocl_information19             in     varchar2 default null
  ,p_ocl_information20             in     varchar2 default null
  ,p_object_version_number             out nocopy number
  ,p_some_warning                     out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_competence_language';
  l_effective_date	date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_competence_language;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    OTA_OCL_BK1.create_competence_language_b
  (p_effective_date                =>	l_effective_date
  ,p_competence_language_id        =>	p_competence_language_id
  ,p_competence_id                 => 	p_competence_id
  ,p_language_code                   =>     p_language_code
  ,p_business_group_id             =>	p_business_group_id
  ,p_min_proficiency_level_id      =>	p_min_proficiency_level_id
  ,p_ocl_information_category      =>	p_ocl_information_category
  ,p_ocl_information1              =>	p_ocl_information1
  ,p_ocl_information2              =>	p_ocl_information2
  ,p_ocl_information3              =>	p_ocl_information3
  ,p_ocl_information4              =>	p_ocl_information4
  ,p_ocl_information5              =>	p_ocl_information5
  ,p_ocl_information6              =>	p_ocl_information6
  ,p_ocl_information7              =>	p_ocl_information7
  ,p_ocl_information8              =>	p_ocl_information8
  ,p_ocl_information9              =>	p_ocl_information9
  ,p_ocl_information10             =>	p_ocl_information10
  ,p_ocl_information11             =>	p_ocl_information11
  ,p_ocl_information12             =>	p_ocl_information12
  ,p_ocl_information13             =>	p_ocl_information13
  ,p_ocl_information14             =>	p_ocl_information14
  ,p_ocl_information15             =>	p_ocl_information15
  ,p_ocl_information16             =>	p_ocl_information16
  ,p_ocl_information17             =>	p_ocl_information17
  ,p_ocl_information18             =>	p_ocl_information18
  ,p_ocl_information19             =>	p_ocl_information19
  ,p_ocl_information20             =>	p_ocl_information20
  ,p_object_version_number         =>	p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_competence_language_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

    ota_ocl_ins .ins
  (p_effective_date                =>	l_effective_date
  ,p_competence_language_id        =>	p_competence_language_id
  ,p_competence_id                 => 	p_competence_id
  ,p_language_code                   =>     p_language_code
  ,p_business_group_id             =>	p_business_group_id
  ,p_min_proficiency_level_id      =>	p_min_proficiency_level_id
  ,p_ocl_information_category      =>	p_ocl_information_category
  ,p_ocl_information1              =>	p_ocl_information1
  ,p_ocl_information2              =>	p_ocl_information2
  ,p_ocl_information3              =>	p_ocl_information3
  ,p_ocl_information4              =>	p_ocl_information4
  ,p_ocl_information5              =>	p_ocl_information5
  ,p_ocl_information6              =>	p_ocl_information6
  ,p_ocl_information7              =>	p_ocl_information7
  ,p_ocl_information8              =>	p_ocl_information8
  ,p_ocl_information9              =>	p_ocl_information9
  ,p_ocl_information10             =>	p_ocl_information10
  ,p_ocl_information11             =>	p_ocl_information11
  ,p_ocl_information12             =>	p_ocl_information12
  ,p_ocl_information13             =>	p_ocl_information13
  ,p_ocl_information14             =>	p_ocl_information14
  ,p_ocl_information15             =>	p_ocl_information15
  ,p_ocl_information16             =>	p_ocl_information16
  ,p_ocl_information17             =>	p_ocl_information17
  ,p_ocl_information18             =>	p_ocl_information18
  ,p_ocl_information19             =>	p_ocl_information19
  ,p_ocl_information20             =>	p_ocl_information20
  ,p_object_version_number         =>	p_object_version_number
      );


  --
  -- Process Logic
  --



  --
  -- Call After Process User Hook
  --
  begin
    OTA_OCL_BK1.create_competence_language_a
  (p_effective_date                =>	l_effective_date
  ,p_competence_language_id        =>	p_competence_language_id
  ,p_competence_id                 => 	p_competence_id
  ,p_language_code                   =>     p_language_code
  ,p_business_group_id             =>	p_business_group_id
  ,p_min_proficiency_level_id      =>	p_min_proficiency_level_id
  ,p_ocl_information_category      =>	p_ocl_information_category
  ,p_ocl_information1              =>	p_ocl_information1
  ,p_ocl_information2              =>	p_ocl_information2
  ,p_ocl_information3              =>	p_ocl_information3
  ,p_ocl_information4              =>	p_ocl_information4
  ,p_ocl_information5              =>	p_ocl_information5
  ,p_ocl_information6              =>	p_ocl_information6
  ,p_ocl_information7              =>	p_ocl_information7
  ,p_ocl_information8              =>	p_ocl_information8
  ,p_ocl_information9              =>	p_ocl_information9
  ,p_ocl_information10             =>	p_ocl_information10
  ,p_ocl_information11             =>	p_ocl_information11
  ,p_ocl_information12             =>	p_ocl_information12
  ,p_ocl_information13             =>	p_ocl_information13
  ,p_ocl_information14             =>	p_ocl_information14
  ,p_ocl_information15             =>	p_ocl_information15
  ,p_ocl_information16             =>	p_ocl_information16
  ,p_ocl_information17             =>	p_ocl_information17
  ,p_ocl_information18             =>	p_ocl_information18
  ,p_ocl_information19             =>	p_ocl_information19
  ,p_ocl_information20             =>	p_ocl_information20
  ,p_object_version_number         =>	p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_competence_language_a'
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
  -- Set all output arguments
  --
/*  p_id                     := <local_var_set_in_process_logic>;
  p_object_version_number  := <local_var_set_in_process_logic>;
  p_some_warning           := <local_var_set_in_process_logic>; */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_competence_language ;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  /*  p_id                     := null;
    p_object_version_number  := null;
    p_some_warning           := <local_var_set_in_process_logic>; */
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_competence_language;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_competence_language ;


-- ----------------------------------------------------------------------------
-- |--------------------------< update_competence_language >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_competence_language
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_competence_language_id        in  	number
  ,p_competence_id                 in     number
  ,p_language_code                   in     varchar2
  ,p_business_group_id             in     number
  ,p_min_proficiency_level_id      in     number   default null
  ,p_ocl_information_category      in     varchar2 default null
  ,p_ocl_information1              in     varchar2 default null
  ,p_ocl_information2              in     varchar2 default null
  ,p_ocl_information3              in     varchar2 default null
  ,p_ocl_information4              in     varchar2 default null
  ,p_ocl_information5              in     varchar2 default null
  ,p_ocl_information6              in     varchar2 default null
  ,p_ocl_information7              in     varchar2 default null
  ,p_ocl_information8              in     varchar2 default null
  ,p_ocl_information9              in     varchar2 default null
  ,p_ocl_information10             in     varchar2 default null
  ,p_ocl_information11             in     varchar2 default null
  ,p_ocl_information12             in     varchar2 default null
  ,p_ocl_information13             in     varchar2 default null
  ,p_ocl_information14             in     varchar2 default null
  ,p_ocl_information15             in     varchar2 default null
  ,p_ocl_information16             in     varchar2 default null
  ,p_ocl_information17             in     varchar2 default null
  ,p_ocl_information18             in     varchar2 default null
  ,p_ocl_information19             in     varchar2 default null
  ,p_ocl_information20             in     varchar2 default null
  ,p_object_version_number         in  out nocopy number
  ,p_some_warning                     out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_competence_language';
  l_effective_date	date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_competence_language;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    OTA_OCL_BK2.update_competence_language_b
  (p_effective_date                =>	l_effective_date
  ,p_competence_language_id        =>	p_competence_language_id
  ,p_competence_id                 => 	p_competence_id
  ,p_language_code                  =>     p_language_code
  ,p_business_group_id             =>	p_business_group_id
  ,p_min_proficiency_level_id      =>	p_min_proficiency_level_id
  ,p_ocl_information_category      =>	p_ocl_information_category
  ,p_ocl_information1              =>	p_ocl_information1
  ,p_ocl_information2              =>	p_ocl_information2
  ,p_ocl_information3              =>	p_ocl_information3
  ,p_ocl_information4              =>	p_ocl_information4
  ,p_ocl_information5              =>	p_ocl_information5
  ,p_ocl_information6              =>	p_ocl_information6
  ,p_ocl_information7              =>	p_ocl_information7
  ,p_ocl_information8              =>	p_ocl_information8
  ,p_ocl_information9              =>	p_ocl_information9
  ,p_ocl_information10             =>	p_ocl_information10
  ,p_ocl_information11             =>	p_ocl_information11
  ,p_ocl_information12             =>	p_ocl_information12
  ,p_ocl_information13             =>	p_ocl_information13
  ,p_ocl_information14             =>	p_ocl_information14
  ,p_ocl_information15             =>	p_ocl_information15
  ,p_ocl_information16             =>	p_ocl_information16
  ,p_ocl_information17             =>	p_ocl_information17
  ,p_ocl_information18             =>	p_ocl_information18
  ,p_ocl_information19             =>	p_ocl_information19
  ,p_ocl_information20             =>	p_ocl_information20
  ,p_object_version_number         =>	p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_competence_language_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

    ota_ocl_upd.upd
  (p_effective_date                =>	l_effective_date
  ,p_competence_language_id        =>	p_competence_language_id
  ,p_competence_id                 => 	p_competence_id
  ,p_language_code                   =>     p_language_code
  ,p_business_group_id             =>	p_business_group_id
  ,p_min_proficiency_level_id      =>	p_min_proficiency_level_id
  ,p_ocl_information_category      =>	p_ocl_information_category
  ,p_ocl_information1              =>	p_ocl_information1
  ,p_ocl_information2              =>	p_ocl_information2
  ,p_ocl_information3              =>	p_ocl_information3
  ,p_ocl_information4              =>	p_ocl_information4
  ,p_ocl_information5              =>	p_ocl_information5
  ,p_ocl_information6              =>	p_ocl_information6
  ,p_ocl_information7              =>	p_ocl_information7
  ,p_ocl_information8              =>	p_ocl_information8
  ,p_ocl_information9              =>	p_ocl_information9
  ,p_ocl_information10             =>	p_ocl_information10
  ,p_ocl_information11             =>	p_ocl_information11
  ,p_ocl_information12             =>	p_ocl_information12
  ,p_ocl_information13             =>	p_ocl_information13
  ,p_ocl_information14             =>	p_ocl_information14
  ,p_ocl_information15             =>	p_ocl_information15
  ,p_ocl_information16             =>	p_ocl_information16
  ,p_ocl_information17             =>	p_ocl_information17
  ,p_ocl_information18             =>	p_ocl_information18
  ,p_ocl_information19             =>	p_ocl_information19
  ,p_ocl_information20             =>	p_ocl_information20
  ,p_object_version_number         =>	p_object_version_number
      );


  --
  -- Process Logic
  --



  --
  -- Call After Process User Hook
  --
  begin
    OTA_OCL_BK2.update_competence_language_a
  (p_effective_date                =>	l_effective_date
  ,p_competence_language_id        =>	p_competence_language_id
  ,p_competence_id                 => 	p_competence_id
  ,p_language_code                   =>     p_language_code
  ,p_business_group_id             =>	p_business_group_id
  ,p_min_proficiency_level_id      =>	p_min_proficiency_level_id
  ,p_ocl_information_category      =>	p_ocl_information_category
  ,p_ocl_information1              =>	p_ocl_information1
  ,p_ocl_information2              =>	p_ocl_information2
  ,p_ocl_information3              =>	p_ocl_information3
  ,p_ocl_information4              =>	p_ocl_information4
  ,p_ocl_information5              =>	p_ocl_information5
  ,p_ocl_information6              =>	p_ocl_information6
  ,p_ocl_information7              =>	p_ocl_information7
  ,p_ocl_information8              =>	p_ocl_information8
  ,p_ocl_information9              =>	p_ocl_information9
  ,p_ocl_information10             =>	p_ocl_information10
  ,p_ocl_information11             =>	p_ocl_information11
  ,p_ocl_information12             =>	p_ocl_information12
  ,p_ocl_information13             =>	p_ocl_information13
  ,p_ocl_information14             =>	p_ocl_information14
  ,p_ocl_information15             =>	p_ocl_information15
  ,p_ocl_information16             =>	p_ocl_information16
  ,p_ocl_information17             =>	p_ocl_information17
  ,p_ocl_information18             =>	p_ocl_information18
  ,p_ocl_information19             =>	p_ocl_information19
  ,p_ocl_information20             =>	p_ocl_information20
  ,p_object_version_number         =>	p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_competence_language_a'
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
  -- Set all output arguments
  --
/*  p_id                     := <local_var_set_in_process_logic>;
  p_object_version_number  := <local_var_set_in_process_logic>;
  p_some_warning           := <local_var_set_in_process_logic>; */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_competence_language;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
 /*   p_id                     := null;
    p_object_version_number  := null;
    p_some_warning           := <local_var_set_in_process_logic>; */
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_competence_language;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_competence_language ;


--
end OTA_OCL_API;

/
