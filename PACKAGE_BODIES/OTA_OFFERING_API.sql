--------------------------------------------------------
--  DDL for Package Body OTA_OFFERING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OFFERING_API" as
/* $Header: otoffapi.pkb 120.1.12000000.2 2007/02/06 15:27:35 vkkolla noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_OFFERING_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_OFFERING >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_offering(
  p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_name                          in     varchar2
  ,p_start_date                     in     date
  ,p_activity_version_id            in     number   default null
  ,p_end_date                       in     date     default null
  ,p_owner_id                       in     number   default null
  ,p_delivery_mode_id               in     number   default null
  ,p_language_id                    in     number   default null
  ,p_duration                       in     number   default null
  ,p_duration_units                 in     varchar2 default null
  ,p_learning_object_id             in     number   default null
  ,p_player_toolbar_flag            in     varchar2 default null
  ,p_player_toolbar_bitset          in     number   default null
  ,p_player_new_window_flag         in     varchar2 default null
  ,p_maximum_attendees              in     number   default null
  ,p_maximum_internal_attendees     in     number   default null
  ,p_minimum_attendees              in     number   default null
  ,p_actual_cost                    in     number   default null
  ,p_budget_cost                    in     number   default null
  ,p_budget_currency_code           in     varchar2 default null
  ,p_price_basis                    in     varchar2 default null
  ,p_currency_code                  in     varchar2 default null
  ,p_standard_price                 in     number   default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_offering_id                       out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_data_source                    in     varchar2 default null
  ,p_vendor_id                      in number default null
  ,p_description		  in     varchar2  default null
  ,p_competency_update_level      in     varchar2  default null
  ,p_language_code                in     varchar2  default null   -- 2733966
  ) is
  --
  -- Declare cursors and local variables
  --bug 5435877 l_proc variable changed from 'Create Training Plan' to 'Create Offering'
  l_proc                    varchar2(72) := g_package||' Create Offering';
  l_offering_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_name varchar2(80);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_OFFERING;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  l_name := rtrim(p_name);
  --
  -- Call Before Process User Hook
  --

  begin
    ota_offering_bk1.create_offering_b
  (p_effective_date               => l_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => l_name
    ,p_start_date                   => p_start_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_end_date                     => p_end_date
    ,p_owner_id                     => p_owner_id
    ,p_delivery_mode_id             => p_delivery_mode_id
    ,p_language_id                  => p_language_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_learning_object_id           => p_learning_object_id
    ,p_player_toolbar_flag          => p_player_toolbar_flag
    ,p_player_toolbar_bitset        => p_player_toolbar_bitset
    ,p_player_new_window_flag       => p_player_new_window_flag
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_standard_price               => p_standard_price
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_data_source                  => p_data_source
    ,p_vendor_id                    => p_vendor_id
    ,p_description		    => p_description
    ,p_competency_update_level      => p_competency_update_level
    ,p_language_code                => p_language_code  -- 2733966
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OFFERING'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
/*
  l_end_date :=  END_DATE(
                        p_start_date ,
                        p_end_date ,
                        p_duration    ,
                        p_duration_units         );
*/
  ota_off_ins.ins
  (  p_effective_date               => l_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => l_name
    ,p_start_date                   => p_start_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_end_date                     => p_end_date
    ,p_owner_id                     => p_owner_id
    ,p_delivery_mode_id             => p_delivery_mode_id
    ,p_language_id                  => p_language_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_learning_object_id           => p_learning_object_id
    ,p_player_toolbar_flag          => p_player_toolbar_flag
    ,p_player_toolbar_bitset        => p_player_toolbar_bitset
    ,p_player_new_window_flag       => p_player_new_window_flag
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_standard_price               => p_standard_price
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_offering_id                  => l_offering_id
    ,p_object_version_number        => p_object_version_number
    ,p_data_source                  => p_data_source
    ,p_vendor_id                    => p_vendor_id
    ,p_competency_update_level      => p_competency_update_level
    ,p_language_code                => p_language_code -- 2733966
  );

   ota_ont_ins.ins_tl
    (p_effective_date               => l_effective_date
  ,p_language_code                  => USERENV('LANG')
  ,p_offering_id                    => l_offering_id
  ,p_name                           => l_name
  ,p_description		    => p_description);
  --
  -- Call After Process User Hook
  --

  begin
  ota_offering_bk1.create_offering_a
  (p_effective_date               => l_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => l_name
    ,p_start_date                   => p_start_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_end_date                     => p_end_date
    ,p_owner_id                     => p_owner_id
    ,p_delivery_mode_id             => p_delivery_mode_id
    ,p_language_id                  => p_language_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_learning_object_id           => p_learning_object_id
    ,p_player_toolbar_flag          => p_player_toolbar_flag
    ,p_player_toolbar_bitset        => p_player_toolbar_bitset
    ,p_player_new_window_flag       => p_player_new_window_flag
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_standard_price               => p_standard_price
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_offering_id                  => l_offering_id
    ,p_object_version_number        => p_object_version_number
    ,p_data_source                  => p_data_source
    ,p_vendor_id                    => p_vendor_id
    ,p_description                  => p_description
    ,p_competency_update_level      => p_competency_update_level
    ,p_language_code                => p_language_code -- 2733966
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OFFERING'
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
  p_offering_id        := l_offering_id;
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_OFFERING;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_offering_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_OFFERING;
    p_offering_id        := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_offering;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_offering >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_offering
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_offering_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_owner_id                     in     number    default hr_api.g_number
  ,p_delivery_mode_id             in     number    default hr_api.g_number
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_learning_object_id           in     number    default hr_api.g_number
  ,p_player_toolbar_flag          in     varchar2  default hr_api.g_varchar2
  ,p_player_toolbar_bitset        in     number    default hr_api.g_number
  ,p_player_new_window_flag       in     varchar2  default hr_api.g_varchar2
  ,p_maximum_attendees            in     number    default hr_api.g_number
  ,p_maximum_internal_attendees   in     number    default hr_api.g_number
  ,p_minimum_attendees            in     number    default hr_api.g_number
  ,p_actual_cost                  in     number    default hr_api.g_number
  ,p_budget_cost                  in     number    default hr_api.g_number
  ,p_budget_currency_code         in     varchar2  default hr_api.g_varchar2
  ,p_price_basis                  in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_standard_price               in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_description		  in     varchar2  default hr_api.g_varchar2
   ,p_competency_update_level      in     varchar2  default hr_api.g_varchar2
   ,p_language_code                in     varchar2  default hr_api.g_varchar2  -- 2733966
  ) is
  --
  -- Declare cursors and local variables
  --bug 5435877 l_proc variable changed from 'Update Training Plan' to 'Update Offering'
  l_proc                    varchar2(72) := g_package||' Update Offering';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
  l_name varchar2(80);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_OFFERING;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_name := rtrim(p_name);
  --
  -- Call Before Process User Hook
  --

  begin
    ota_offering_bk2.update_offering_b
  (p_effective_date               => l_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => l_name
    ,p_start_date                   => p_start_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_end_date                     => p_end_date
    ,p_owner_id                     => p_owner_id
    ,p_delivery_mode_id             => p_delivery_mode_id
    ,p_language_id                  => p_language_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_learning_object_id           => p_learning_object_id
    ,p_player_toolbar_flag          => p_player_toolbar_flag
    ,p_player_toolbar_bitset        => p_player_toolbar_bitset
    ,p_player_new_window_flag       => p_player_new_window_flag
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_standard_price               => p_standard_price
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_offering_id                  => p_offering_id
    ,p_object_version_number        => p_object_version_number
    ,p_data_source                  => p_data_source
    ,p_vendor_id                    => p_vendor_id
    ,p_description                  => p_description
    ,p_competency_update_level      => p_competency_update_level
    ,p_language_code                => p_language_code  -- 2733966
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OFFERING'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_off_upd.upd
    (p_effective_date               => p_effective_date
    ,p_offering_id                  => p_offering_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => l_name
    ,p_start_date                   => p_start_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_end_date                     => p_end_date
    ,p_owner_id                     => p_owner_id
    ,p_delivery_mode_id             => p_delivery_mode_id
    ,p_language_id                  => p_language_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_learning_object_id           => p_learning_object_id
    ,p_player_toolbar_flag          => p_player_toolbar_flag
    ,p_player_toolbar_bitset        => p_player_toolbar_bitset
    ,p_player_new_window_flag       => p_player_new_window_flag
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_standard_price               => p_standard_price
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_data_source                  => p_data_source
    ,p_vendor_id                    => p_vendor_id
    ,p_competency_update_level      => p_competency_update_level
    ,p_language_code                => p_language_code  -- 2733966
    );

  ota_ont_upd.upd_tl(p_effective_date   =>  p_effective_date
    ,p_language_code     =>  USERENV('LANG')
    ,p_offering_id    =>    p_offering_id
    ,p_name           =>    l_name
    ,p_description                  => p_description
    );
  --
  -- Call After Process User Hook
  --
  begin
  ota_offering_bk2.update_offering_a
  (p_effective_date               => l_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => l_name
    ,p_start_date                   => p_start_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_end_date                     => p_end_date
    ,p_owner_id                     => p_owner_id
    ,p_delivery_mode_id             => p_delivery_mode_id
    ,p_language_id                  => p_language_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_learning_object_id           => p_learning_object_id
    ,p_player_toolbar_flag          => p_player_toolbar_flag
    ,p_player_toolbar_bitset        => p_player_toolbar_bitset
    ,p_player_new_window_flag       => p_player_new_window_flag
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_standard_price               => p_standard_price
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_offering_id                  => p_offering_id
    ,p_object_version_number        => p_object_version_number
    ,p_data_source                  => p_data_source
    ,p_vendor_id                    => p_vendor_id
    ,p_description                  => p_description
    ,p_competency_update_level      => p_competency_update_level
    ,p_language_code                => p_language_code -- 2733966
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OFFERING'
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
    rollback to UPDATE_OFFERING;
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
    rollback to UPDATE_OFFERING;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_offering;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_OFFERING >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_offering
  (p_validate                      in     boolean  default false
  ,p_offering_id                   in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --bug 5435877 l_proc variable changed from 'Delete Training Plan' to 'Delete Offering'
  l_proc                    varchar2(72) := g_package||' Delete Offering';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_OFFERING;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  --
  begin
    ota_offering_bk3.delete_offering_b
  (p_offering_id            => p_offering_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OFFERING'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_off_del.del
  (p_offering_id        => p_offering_id
  ,p_object_version_number   => p_object_version_number
  );

  ota_ont_del.del_tl
  (p_offering_id        => p_offering_id
   --,p_language =>  USERENV('LANG')
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_offering_bk3.delete_offering_a
  (p_offering_id            => p_offering_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OFFERING'
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
    rollback to DELETE_OFFERING;
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
    rollback to DELETE_OFFERING;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_offering;
--


end ota_offering_api;

/
