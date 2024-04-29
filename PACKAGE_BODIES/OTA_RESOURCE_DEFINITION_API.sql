--------------------------------------------------------
--  DDL for Package Body OTA_RESOURCE_DEFINITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RESOURCE_DEFINITION_API" as
    /* $Header: ottsrapi.pkb 120.3 2006/02/13 02:49:59 jbharath noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_RESOURCE_DEFINITION_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_RESOURCE_DEFINITION >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_RESOURCE_DEFINITION
  (  p_supplied_resource_id          out nocopy number
  ,p_vendor_id                    in number
  ,p_business_group_id            in number
  ,p_resource_definition_id       in number
  ,p_consumable_flag              in varchar2 default null
  ,p_object_version_number        out nocopy number
  ,p_resource_type                in varchar2 default null
  ,p_start_date                   in date default null
  ,p_comments                     in varchar2 default null
  ,p_cost                         in number
  ,p_cost_unit                    in varchar2 default null
  ,p_currency_code                in varchar2 default null
  ,p_end_date                     in date default null
  ,p_internal_address_line        in varchar2 default null
  ,p_lead_time                    in number
  ,p_name                         in varchar2 default null
  ,p_supplier_reference           in varchar2 default null
  ,p_tsr_information_category     in varchar2 default null
  ,p_tsr_information1             in varchar2 default null
  ,p_tsr_information2             in varchar2 default null
  ,p_tsr_information3             in varchar2 default null
  ,p_tsr_information4             in varchar2 default null
  ,p_tsr_information5             in varchar2 default null
  ,p_tsr_information6             in varchar2 default null
  ,p_tsr_information7             in varchar2 default null
  ,p_tsr_information8             in varchar2 default null
  ,p_tsr_information9             in varchar2 default null
  ,p_tsr_information10            in varchar2 default null
  ,p_tsr_information11            in varchar2 default null
  ,p_tsr_information12            in varchar2 default null
  ,p_tsr_information13            in varchar2 default null
  ,p_tsr_information14            in varchar2 default null
  ,p_tsr_information15            in varchar2 default null
  ,p_tsr_information16            in varchar2 default null
  ,p_tsr_information17            in varchar2 default null
  ,p_tsr_information18            in varchar2 default null
  ,p_tsr_information19            in varchar2 default null
  ,p_tsr_information20            in varchar2 default null
  ,p_training_center_id           in number
  ,p_location_id	          in number
  ,p_trainer_id                   in number
  ,p_special_instruction          in varchar2 default null
  ,p_validate                     in boolean
  ,p_effective_date               in date
  ,p_data_source                  in varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Resource Definition';
  l_supplied_resource_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_name ota_suppliable_resources_tl.name%type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_RESOURCE_DEFINITION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  l_name := rtrim(p_name);
  --
  -- Call Before Process User Hook
  --

  begin
    OTA_RESOURCE_DEFINITION_BK1.CREATE_RESOURCE_DEFINITION_B
  (   p_vendor_id                   => p_vendor_id
,p_business_group_id           => p_business_group_id
,p_consumable_flag             => p_consumable_flag
,p_resource_type               => p_resource_type
,p_start_date                  => p_start_date
,p_comments                    => p_comments
,p_cost                        => p_cost
,p_cost_unit                   => p_cost_unit
,p_currency_code               => p_currency_code
,p_end_date                    => p_end_date
,p_internal_address_line       => p_internal_address_line
,p_lead_time                   => p_lead_time
,p_name                        => p_name
,p_supplier_reference          => p_supplier_reference
,p_tsr_information_category    => p_tsr_information_category
,p_tsr_information1            => p_tsr_information1
,p_tsr_information2            => p_tsr_information2
,p_tsr_information3            => p_tsr_information3
,p_tsr_information4            => p_tsr_information4
,p_tsr_information5            => p_tsr_information5
,p_tsr_information6            => p_tsr_information6
,p_tsr_information7            => p_tsr_information7
,p_tsr_information8            => p_tsr_information8
,p_tsr_information9            => p_tsr_information9
,p_tsr_information10           => p_tsr_information10
,p_tsr_information11           => p_tsr_information11
,p_tsr_information12           => p_tsr_information12
,p_tsr_information13           => p_tsr_information13
,p_tsr_information14           => p_tsr_information14
,p_tsr_information15           => p_tsr_information15
,p_tsr_information16           => p_tsr_information16
,p_tsr_information17           => p_tsr_information17
,p_tsr_information18           => p_tsr_information18
,p_tsr_information19           => p_tsr_information19
,p_tsr_information20           => p_tsr_information20
,p_training_center_id          => p_training_center_id
,p_location_id	               => p_location_id
,p_trainer_id                  => p_trainer_id
,p_special_instruction         => p_special_instruction
,p_effective_date              => p_effective_date
,p_data_source                 => p_data_source
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RESOURCE_DEFINITION'
        ,p_hook_type   => 'BP'
        );
  end;

  ota_tsr_ins.ins
  (   p_supplied_resource_id        => l_supplied_resource_id
,p_vendor_id                   => p_vendor_id
,p_business_group_id           => p_business_group_id
,p_resource_definition_id      => p_resource_definition_id
,p_consumable_flag             => p_consumable_flag
,p_object_version_number       => p_object_version_number
,p_resource_type               => p_resource_type
,p_start_date                  => p_start_date
,p_comments                    => p_comments
,p_cost                        => p_cost
,p_cost_unit                   => p_cost_unit
,p_currency_code               => p_currency_code
,p_end_date                    => p_end_date
,p_internal_address_line       => p_internal_address_line
,p_lead_time                   => p_lead_time
,p_name                        => p_name
,p_supplier_reference          => p_supplier_reference
,p_tsr_information_category    => p_tsr_information_category
,p_tsr_information1            => p_tsr_information1
,p_tsr_information2            => p_tsr_information2
,p_tsr_information3            => p_tsr_information3
,p_tsr_information4            => p_tsr_information4
,p_tsr_information5            => p_tsr_information5
,p_tsr_information6            => p_tsr_information6
,p_tsr_information7            => p_tsr_information7
,p_tsr_information8            => p_tsr_information8
,p_tsr_information9            => p_tsr_information9
,p_tsr_information10           => p_tsr_information10
,p_tsr_information11           => p_tsr_information11
,p_tsr_information12           => p_tsr_information12
,p_tsr_information13           => p_tsr_information13
,p_tsr_information14           => p_tsr_information14
,p_tsr_information15           => p_tsr_information15
,p_tsr_information16           => p_tsr_information16
,p_tsr_information17           => p_tsr_information17
,p_tsr_information18           => p_tsr_information18
,p_tsr_information19           => p_tsr_information19
,p_tsr_information20           => p_tsr_information20
,p_training_center_id          => p_training_center_id
,p_location_id	               => p_location_id
,p_trainer_id                  => p_trainer_id
,p_special_instruction         => p_special_instruction
,p_validate		       => p_validate
  );

   ota_srt_ins.ins_tl
    (p_effective_date               => l_effective_date
  ,p_language_code                  => USERENV('LANG')
  ,p_supplied_resource_id                    => l_supplied_resource_id
  ,p_name                           => l_name );
  --
  -- Call After Process User Hook
  --

  begin
  OTA_RESOURCE_DEFINITION_BK1.CREATE_RESOURCE_DEFINITION_A
  (     p_supplied_resource_id        => l_supplied_resource_id
,p_vendor_id                   => p_vendor_id
,p_business_group_id           => p_business_group_id
,p_resource_definition_id      => p_resource_definition_id
,p_consumable_flag             => p_consumable_flag
,p_object_version_number       => p_object_version_number
,p_resource_type               => p_resource_type
,p_start_date                  => p_start_date
,p_comments                    => p_comments
,p_cost                        => p_cost
,p_cost_unit                   => p_cost_unit
,p_currency_code               => p_currency_code
,p_end_date                    => p_end_date
,p_internal_address_line       => p_internal_address_line
,p_lead_time                   => p_lead_time
,p_name                        => p_name
,p_supplier_reference          => p_supplier_reference
,p_tsr_information_category    => p_tsr_information_category
,p_tsr_information1            => p_tsr_information1
,p_tsr_information2            => p_tsr_information2
,p_tsr_information3            => p_tsr_information3
,p_tsr_information4            => p_tsr_information4
,p_tsr_information5            => p_tsr_information5
,p_tsr_information6            => p_tsr_information6
,p_tsr_information7            => p_tsr_information7
,p_tsr_information8            => p_tsr_information8
,p_tsr_information9            => p_tsr_information9
,p_tsr_information10           => p_tsr_information10
,p_tsr_information11           => p_tsr_information11
,p_tsr_information12           => p_tsr_information12
,p_tsr_information13           => p_tsr_information13
,p_tsr_information14           => p_tsr_information14
,p_tsr_information15           => p_tsr_information15
,p_tsr_information16           => p_tsr_information16
,p_tsr_information17           => p_tsr_information17
,p_tsr_information18           => p_tsr_information18
,p_tsr_information19           => p_tsr_information19
,p_tsr_information20           => p_tsr_information20
,p_training_center_id          => p_training_center_id
,p_location_id	               => p_location_id
,p_trainer_id                  => p_trainer_id
,p_special_instruction         => p_special_instruction
,p_validate                    => p_validate
,p_effective_date              => l_effective_date
,p_data_source                 => p_data_source


  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RESOURCE_DEFINITION'
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
  p_supplied_resource_id        := l_supplied_resource_id;
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_RESOURCE_DEFINITION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_supplied_resource_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_RESOURCE_DEFINITION;
    p_supplied_resource_id        := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_RESOURCE_DEFINITION;
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_RESOURCE_DEFINITION >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_RESOURCE_DEFINITION
  (p_supplied_resource_id          in number
  ,p_vendor_id                    in number
  ,p_business_group_id            in number
  ,p_resource_definition_id       in number
  ,p_consumable_flag              in varchar2
  ,p_object_version_number        in out nocopy number
  ,p_resource_type                in varchar2
  ,p_start_date                   in date default hr_api.g_date
  ,p_comments                     in varchar2
  ,p_cost                         in number
  ,p_cost_unit                    in varchar2
  ,p_currency_code                in varchar2
  ,p_end_date                     in date default hr_api.g_date
  ,p_internal_address_line        in varchar2
  ,p_lead_time                    in number
  ,p_name                         in varchar2
  ,p_supplier_reference           in varchar2
  ,p_tsr_information_category     in varchar2
  ,p_tsr_information1             in varchar2
  ,p_tsr_information2             in varchar2
  ,p_tsr_information3             in varchar2
  ,p_tsr_information4             in varchar2
  ,p_tsr_information5             in varchar2
  ,p_tsr_information6             in varchar2
  ,p_tsr_information7             in varchar2
  ,p_tsr_information8             in varchar2
  ,p_tsr_information9             in varchar2
  ,p_tsr_information10            in varchar2
  ,p_tsr_information11            in varchar2
  ,p_tsr_information12            in varchar2
  ,p_tsr_information13            in varchar2
  ,p_tsr_information14            in varchar2
  ,p_tsr_information15            in varchar2
  ,p_tsr_information16            in varchar2
  ,p_tsr_information17            in varchar2
  ,p_tsr_information18            in varchar2
  ,p_tsr_information19            in varchar2
  ,p_tsr_information20            in varchar2
  ,p_training_center_id           in number
  ,p_location_id	          in number
  ,p_trainer_id                   in number
  ,p_special_instruction          in varchar2
  ,p_validate                     in boolean
  ,p_effective_date               in date
  ,p_data_source                  in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Resource Definition';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
  l_name ota_suppliable_resources_tl.name%Type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_RESOURCE_DEFINITION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_name := rtrim(p_name);
  --
  -- Call Before Process User Hook
  --

  begin
    OTA_RESOURCE_DEFINITION_BK2.UPDATE_RESOURCE_DEFINITION_B
  ( p_supplied_resource_id        => p_supplied_resource_id
,p_vendor_id                   => p_vendor_id
,p_business_group_id           => p_business_group_id
,p_resource_definition_id      => p_resource_definition_id
,p_consumable_flag             => p_consumable_flag
,p_object_version_number       => p_object_version_number
,p_resource_type               => p_resource_type
,p_start_date                  => p_start_date
,p_comments                    => p_comments
,p_cost                        => p_cost
,p_cost_unit                   => p_cost_unit
,p_currency_code               => p_currency_code
,p_end_date                    => p_end_date
,p_internal_address_line       => p_internal_address_line
,p_lead_time                   => p_lead_time
,p_name                        => p_name
,p_supplier_reference          => p_supplier_reference
,p_tsr_information_category    => p_tsr_information_category
,p_tsr_information1            => p_tsr_information1
,p_tsr_information2            => p_tsr_information2
,p_tsr_information3            => p_tsr_information3
,p_tsr_information4            => p_tsr_information4
,p_tsr_information5            => p_tsr_information5
,p_tsr_information6            => p_tsr_information6
,p_tsr_information7            => p_tsr_information7
,p_tsr_information8            => p_tsr_information8
,p_tsr_information9            => p_tsr_information9
,p_tsr_information10           => p_tsr_information10
,p_tsr_information11           => p_tsr_information11
,p_tsr_information12           => p_tsr_information12
,p_tsr_information13           => p_tsr_information13
,p_tsr_information14           => p_tsr_information14
,p_tsr_information15           => p_tsr_information15
,p_tsr_information16           => p_tsr_information16
,p_tsr_information17           => p_tsr_information17
,p_tsr_information18           => p_tsr_information18
,p_tsr_information19           => p_tsr_information19
,p_tsr_information20           => p_tsr_information20
,p_training_center_id          => p_training_center_id
,p_location_id	               => p_location_id
,p_trainer_id                  => p_trainer_id
,p_special_instruction         => p_special_instruction
,p_effective_date              => l_effective_date
,p_data_source                 => p_data_source
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RESOURCE_DEFINITION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_tsr_upd.upd
    (p_supplied_resource_id        => p_supplied_resource_id
,p_vendor_id                   => p_vendor_id
,p_business_group_id           => p_business_group_id
,p_resource_definition_id      => p_resource_definition_id
,p_consumable_flag             => p_consumable_flag
,p_object_version_number       => p_object_version_number
,p_resource_type               => p_resource_type
,p_start_date                  => p_start_date
,p_comments                    => p_comments
,p_cost                        => p_cost
,p_cost_unit                   => p_cost_unit
,p_currency_code               => p_currency_code
,p_end_date                    => p_end_date
,p_internal_address_line       => p_internal_address_line
,p_lead_time                   => p_lead_time
,p_name                        => p_name
,p_supplier_reference          => p_supplier_reference
,p_tsr_information_category    => p_tsr_information_category
,p_tsr_information1            => p_tsr_information1
,p_tsr_information2            => p_tsr_information2
,p_tsr_information3            => p_tsr_information3
,p_tsr_information4            => p_tsr_information4
,p_tsr_information5            => p_tsr_information5
,p_tsr_information6            => p_tsr_information6
,p_tsr_information7            => p_tsr_information7
,p_tsr_information8            => p_tsr_information8
,p_tsr_information9            => p_tsr_information9
,p_tsr_information10           => p_tsr_information10
,p_tsr_information11           => p_tsr_information11
,p_tsr_information12           => p_tsr_information12
,p_tsr_information13           => p_tsr_information13
,p_tsr_information14           => p_tsr_information14
,p_tsr_information15           => p_tsr_information15
,p_tsr_information16           => p_tsr_information16
,p_tsr_information17           => p_tsr_information17
,p_tsr_information18           => p_tsr_information18
,p_tsr_information19           => p_tsr_information19
,p_tsr_information20           => p_tsr_information20
,p_training_center_id          => p_training_center_id
,p_location_id	               => p_location_id
,p_trainer_id                  => p_trainer_id
,p_special_instruction         => p_special_instruction
,p_validate		       => p_validate
    );

  ota_srt_upd.upd_tl(p_effective_date   =>  p_effective_date
    ,p_language_code     =>  USERENV('LANG')
    ,p_supplied_resource_id => P_supplied_resource_id
    ,p_name           =>    l_name           );
  --
  -- Call After Process User Hook
  --
  begin
  OTA_RESOURCE_DEFINITION_BK2.UPDATE_RESOURCE_DEFINITION_A
  ( p_supplied_resource_id        => p_supplied_resource_id
,p_vendor_id                   => p_vendor_id
,p_business_group_id           => p_business_group_id
,p_resource_definition_id      => p_resource_definition_id
,p_consumable_flag             => p_consumable_flag
,p_object_version_number       => p_object_version_number
,p_resource_type               => p_resource_type
,p_start_date                  => p_start_date
,p_comments                    => p_comments
,p_cost                        => p_cost
,p_cost_unit                   => p_cost_unit
,p_currency_code               => p_currency_code
,p_end_date                    => p_end_date
,p_internal_address_line       => p_internal_address_line
,p_lead_time                   => p_lead_time
,p_name                        => p_name
,p_supplier_reference          => p_supplier_reference
,p_tsr_information_category    => p_tsr_information_category
,p_tsr_information1            => p_tsr_information1
,p_tsr_information2            => p_tsr_information2
,p_tsr_information3            => p_tsr_information3
,p_tsr_information4            => p_tsr_information4
,p_tsr_information5            => p_tsr_information5
,p_tsr_information6            => p_tsr_information6
,p_tsr_information7            => p_tsr_information7
,p_tsr_information8            => p_tsr_information8
,p_tsr_information9            => p_tsr_information9
,p_tsr_information10           => p_tsr_information10
,p_tsr_information11           => p_tsr_information11
,p_tsr_information12           => p_tsr_information12
,p_tsr_information13           => p_tsr_information13
,p_tsr_information14           => p_tsr_information14
,p_tsr_information15           => p_tsr_information15
,p_tsr_information16           => p_tsr_information16
,p_tsr_information17           => p_tsr_information17
,p_tsr_information18           => p_tsr_information18
,p_tsr_information19           => p_tsr_information19
,p_tsr_information20           => p_tsr_information20
,p_training_center_id          => p_training_center_id
,p_location_id	               => p_location_id
,p_trainer_id                  => p_trainer_id
,p_special_instruction         => p_special_instruction
,p_effective_date              => l_effective_date
,p_data_source                 => p_data_source
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RESOURCE_DEFINITION'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_RESOURCE_DEFINITION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_RESOURCE_DEFINITION;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_RESOURCE_DEFINITION;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_RESOURCE_DEFINITION >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_RESOURCE_DEFINITION
  (p_validate                      in     boolean  default false
  ,p_supplied_resource_id                   in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Training Plan';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_RESOURCE_DEFINITION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  --
  begin
    OTA_RESOURCE_DEFINITION_BK3.DELETE_RESOURCE_DEFINITION_B
  (p_supplied_resource_id            => p_supplied_resource_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RESOURCE_DEFINITION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tsr_del.del
  (p_supplied_resource_id        => p_supplied_resource_id
  ,p_object_version_number   => p_object_version_number
  );

  ota_srt_del.del_tl
  (p_supplied_resource_id        => p_supplied_resource_id
   --,p_language =>  USERENV('LANG')
  );
  --
  -- Call After Process User Hook
  --
  begin
  OTA_RESOURCE_DEFINITION_BK3.DELETE_RESOURCE_DEFINITION_A
  (p_supplied_resource_id            => p_supplied_resource_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RESOURCE_DEFINITION'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_RESOURCE_DEFINITION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_RESOURCE_DEFINITION;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_RESOURCE_DEFINITION;
--


END OTA_RESOURCE_DEFINITION_API;

/
