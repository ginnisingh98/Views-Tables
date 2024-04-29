--------------------------------------------------------
--  DDL for Package Body OTA_ACTIVITY_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ACTIVITY_CATEGORY_API" as
/* $Header: otaciapi.pkb 120.0 2005/05/29 06:50:49 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_ACTIVITY_CATEGORY_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_act_cat_inclusion >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_act_cat_inclusion
  (p_validate                      in     boolean  default false,
  p_effective_date                in     date,
  p_activity_version_id          in  number,
  p_activity_category            in  varchar2,
  p_comments                     in  varchar2  default null,
  p_object_version_number        out nocopy number,
  p_aci_information_category     in  varchar2  default null,
  p_aci_information1             in  varchar2  default null,
  p_aci_information2             in  varchar2  default null,
  p_aci_information3             in  varchar2  default null,
  p_aci_information4             in  varchar2  default null,
  p_aci_information5             in  varchar2  default null,
  p_aci_information6             in  varchar2  default null,
  p_aci_information7             in  varchar2  default null,
  p_aci_information8             in  varchar2  default null,
  p_aci_information9             in  varchar2  default null,
  p_aci_information10            in  varchar2  default null,
  p_aci_information11            in  varchar2  default null,
  p_aci_information12            in  varchar2  default null,
  p_aci_information13            in  varchar2  default null,
  p_aci_information14            in  varchar2  default null,
  p_aci_information15            in  varchar2  default null,
  p_aci_information16            in  varchar2  default null,
  p_aci_information17            in  varchar2  default null,
  p_aci_information18            in  varchar2  default null,
  p_aci_information19            in  varchar2  default null,
  p_aci_information20            in  varchar2  default null,
  p_start_date_active            in  date      default null,
  p_end_date_active              in  date      default null,
  p_primary_flag                 in  varchar2  default 'N',
  p_category_usage_id            in  number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_act_cat_inclusion ';
  l_object_version_number   number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_act_cat_inclusion;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    ota_activity_category_bk1.create_act_cat_inclusion_b
  (p_effective_date             => l_effective_date,
   p_activity_version_id        => p_activity_version_id ,
  p_activity_category           => p_activity_category,
  p_comments                    => p_comments,
  p_object_version_number       => l_object_version_number,
  p_aci_information_category    => p_aci_information_category,
  p_aci_information1            => p_aci_information1,
  p_aci_information2            => p_aci_information2,
  p_aci_information3            => p_aci_information3,
  p_aci_information4            => p_aci_information4,
  p_aci_information5            => p_aci_information5 ,
  p_aci_information6            => p_aci_information6,
  p_aci_information7            => p_aci_information7,
  p_aci_information8            => p_aci_information8,
  p_aci_information9            => p_aci_information9,
  p_aci_information10           => p_aci_information10,
  p_aci_information11           => p_aci_information11,
  p_aci_information12           => p_aci_information12,
  p_aci_information13           => p_aci_information13,
  p_aci_information14           => p_aci_information14,
  p_aci_information15           => p_aci_information15,
  p_aci_information16           => p_aci_information16,
  p_aci_information17           => p_aci_information17,
  p_aci_information18           => p_aci_information18,
  p_aci_information19           => p_aci_information19,
  p_aci_information20           => p_aci_information20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_act_cat_inclusion_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_aci_ins.ins
  (p_effective_date             => l_effective_date,
   p_activity_version_id        => p_activity_version_id ,
  p_activity_category           => p_activity_category,
  p_comments                    => p_comments,
  p_object_version_number       => l_object_version_number,
  p_aci_information_category    => p_aci_information_category,
  p_aci_information1            => p_aci_information1,
  p_aci_information2            => p_aci_information2,
  p_aci_information3            => p_aci_information3,
  p_aci_information4            => p_aci_information4,
  p_aci_information5            => p_aci_information5 ,
  p_aci_information6            => p_aci_information6,
  p_aci_information7            => p_aci_information7,
  p_aci_information8            => p_aci_information8,
  p_aci_information9            => p_aci_information9,
  p_aci_information10           => p_aci_information10,
  p_aci_information11           => p_aci_information11,
  p_aci_information12           => p_aci_information12,
  p_aci_information13           => p_aci_information13,
  p_aci_information14           => p_aci_information14,
  p_aci_information15           => p_aci_information15,
  p_aci_information16           => p_aci_information16,
  p_aci_information17           => p_aci_information17,
  p_aci_information18           => p_aci_information18,
  p_aci_information19           => p_aci_information19,
  p_aci_information20           => p_aci_information20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
);

  --
  -- Call After Process User Hook
  --
  begin
  OTA_activity_category_bk1.create_act_cat_inclusion_a
  (p_effective_date             => l_effective_date,
   p_activity_version_id        => p_activity_version_id ,
  p_activity_category           => p_activity_category,
  p_comments                    => p_comments,
  p_object_version_number       => l_object_version_number,
  p_aci_information_category    => p_aci_information_category,
  p_aci_information1            => p_aci_information1,
  p_aci_information2            => p_aci_information2,
  p_aci_information3            => p_aci_information3,
  p_aci_information4            => p_aci_information4,
  p_aci_information5            => p_aci_information5 ,
  p_aci_information6            => p_aci_information6,
  p_aci_information7            => p_aci_information7,
  p_aci_information8            => p_aci_information8,
  p_aci_information9            => p_aci_information9,
  p_aci_information10           => p_aci_information10,
  p_aci_information11           => p_aci_information11,
  p_aci_information12           => p_aci_information12,
  p_aci_information13           => p_aci_information13,
  p_aci_information14           => p_aci_information14,
  p_aci_information15           => p_aci_information15,
  p_aci_information16           => p_aci_information16,
  p_aci_information17           => p_aci_information17,
  p_aci_information18           => p_aci_information18,
  p_aci_information19           => p_aci_information19,
  p_aci_information20           => p_aci_information20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_act_cat_inclusion_a'
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
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_act_cat_inclusion;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_act_cat_inclusion;
    p_object_version_number :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_act_cat_inclusion ;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_act_cat_inclusion >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_act_cat_inclusion
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_activity_version_id          in number
  ,p_activity_category            in varchar2
  ,p_comments                     in varchar2     default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_aci_information_category     in varchar2     default hr_api.g_varchar2
  ,p_aci_information1             in varchar2     default hr_api.g_varchar2
  ,p_aci_information2             in varchar2     default hr_api.g_varchar2
  ,p_aci_information3             in varchar2     default hr_api.g_varchar2
  ,p_aci_information4             in varchar2     default hr_api.g_varchar2
  ,p_aci_information5             in varchar2     default hr_api.g_varchar2
  ,p_aci_information6             in varchar2     default hr_api.g_varchar2
  ,p_aci_information7             in varchar2     default hr_api.g_varchar2
  ,p_aci_information8             in varchar2     default hr_api.g_varchar2
  ,p_aci_information9             in varchar2     default hr_api.g_varchar2
  ,p_aci_information10            in varchar2     default hr_api.g_varchar2
  ,p_aci_information11            in varchar2     default hr_api.g_varchar2
  ,p_aci_information12            in varchar2     default hr_api.g_varchar2
  ,p_aci_information13            in varchar2     default hr_api.g_varchar2
  ,p_aci_information14            in varchar2     default hr_api.g_varchar2
  ,p_aci_information15            in varchar2     default hr_api.g_varchar2
  ,p_aci_information16            in varchar2     default hr_api.g_varchar2
  ,p_aci_information17            in varchar2     default hr_api.g_varchar2
  ,p_aci_information18            in varchar2     default hr_api.g_varchar2
  ,p_aci_information19            in varchar2     default hr_api.g_varchar2
  ,p_aci_information20            in varchar2     default hr_api.g_varchar2
  ,p_start_date_active            in date         default hr_api.g_date
  ,p_end_date_active              in date         default hr_api.g_date
  ,p_primary_flag                 in varchar2     default hr_api.g_varchar2
  ,p_category_usage_id            in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_act_cat_inclusion ';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_act_cat_inclusion ;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --

  -- Call Before Process User Hook
  --
  begin
    ota_activity_category_bk2.update_act_cat_inclusion_b
   (p_effective_date             => l_effective_date,
   p_activity_version_id        => p_activity_version_id ,
  p_activity_category           => p_activity_category,
  p_comments                    => p_comments,
  p_object_version_number       => p_object_version_number,
  p_aci_information_category    => p_aci_information_category,
  p_aci_information1            => p_aci_information1,
  p_aci_information2            => p_aci_information2,
  p_aci_information3            => p_aci_information3,
  p_aci_information4            => p_aci_information4,
  p_aci_information5            => p_aci_information5 ,
  p_aci_information6            => p_aci_information6,
  p_aci_information7            => p_aci_information7,
  p_aci_information8            => p_aci_information8,
  p_aci_information9            => p_aci_information9,
  p_aci_information10           => p_aci_information10,
  p_aci_information11           => p_aci_information11,
  p_aci_information12           => p_aci_information12,
  p_aci_information13           => p_aci_information13,
  p_aci_information14           => p_aci_information14,
  p_aci_information15           => p_aci_information15,
  p_aci_information16           => p_aci_information16,
  p_aci_information17           => p_aci_information17,
  p_aci_information18           => p_aci_information18,
  p_aci_information19           => p_aci_information19,
  p_aci_information20           => p_aci_information20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_act_cat_inclusion_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_aci_upd.upd
   (p_effective_date             => l_effective_date,
   p_activity_version_id        => p_activity_version_id ,
  p_activity_category           => p_activity_category,
  p_comments                    => p_comments,
  p_object_version_number       => p_object_version_number,
  p_aci_information_category    => p_aci_information_category,
  p_aci_information1            => p_aci_information1,
  p_aci_information2            => p_aci_information2,
  p_aci_information3            => p_aci_information3,
  p_aci_information4            => p_aci_information4,
  p_aci_information5            => p_aci_information5 ,
  p_aci_information6            => p_aci_information6,
  p_aci_information7            => p_aci_information7,
  p_aci_information8            => p_aci_information8,
  p_aci_information9            => p_aci_information9,
  p_aci_information10           => p_aci_information10,
  p_aci_information11           => p_aci_information11,
  p_aci_information12           => p_aci_information12,
  p_aci_information13           => p_aci_information13,
  p_aci_information14           => p_aci_information14,
  p_aci_information15           => p_aci_information15,
  p_aci_information16           => p_aci_information16,
  p_aci_information17           => p_aci_information17,
  p_aci_information18           => p_aci_information18,
  p_aci_information19           => p_aci_information19,
  p_aci_information20           => p_aci_information20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  OTA_activity_category_bk2.update_act_cat_inclusion_a
   (p_effective_date             => l_effective_date,
   p_activity_version_id        => p_activity_version_id ,
  p_activity_category           => p_activity_category,
  p_comments                    => p_comments,
  p_object_version_number       => p_object_version_number,
  p_aci_information_category    => p_aci_information_category,
  p_aci_information1            => p_aci_information1,
  p_aci_information2            => p_aci_information2,
  p_aci_information3            => p_aci_information3,
  p_aci_information4            => p_aci_information4,
  p_aci_information5            => p_aci_information5 ,
  p_aci_information6            => p_aci_information6,
  p_aci_information7            => p_aci_information7,
  p_aci_information8            => p_aci_information8,
  p_aci_information9            => p_aci_information9,
  p_aci_information10           => p_aci_information10,
  p_aci_information11           => p_aci_information11,
  p_aci_information12           => p_aci_information12,
  p_aci_information13           => p_aci_information13,
  p_aci_information14           => p_aci_information14,
  p_aci_information15           => p_aci_information15,
  p_aci_information16           => p_aci_information16,
  p_aci_information17           => p_aci_information17,
  p_aci_information18           => p_aci_information18,
  p_aci_information19           => p_aci_information19,
  p_aci_information20           => p_aci_information20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_act_cat_inclusion'
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
  -- p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_act_cat_inclusion ;
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
    rollback to update_act_cat_inclusion ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_object_version_number := l_object_version_number;
    raise;
end update_act_cat_inclusion ;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_act_cat_inclusion >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_act_cat_inclusion
( p_activity_version_id                in number,
  p_category_usage_id                   in varchar2,
  p_object_version_number              in number,
  p_validate                           in boolean default false

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' delete_act_cat_inclusion ';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_act_cat_inclusion ;
  --
  -- Call Before Process User Hook
  --
  begin
    OTA_activity_category_bk3.delete_act_cat_inclusion_b
    (p_activity_version_id        => p_activity_version_id ,
     p_category_usage_id           => p_category_usage_id,
     p_object_version_number       => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_act_cat_inclusion_b '
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  OTA_aci_del.del
    (p_activity_version_id        => p_activity_version_id ,
     p_category_usage_id           => p_category_usage_id,
     p_object_version_number       => p_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
  OTA_activity_category_bk3.delete_act_cat_inclusion_a
    (p_activity_version_id        => p_activity_version_id ,
     p_category_usage_id           => p_category_usage_id,
     p_object_version_number       => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_act_cat_inclusion_a '
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
    rollback to delete_act_cat_inclusion ;
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
    rollback to delete_act_cat_inclusion ;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_act_cat_inclusion;
--
end ota_activity_category_api;

/
