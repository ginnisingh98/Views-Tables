--------------------------------------------------------
--  DDL for Package Body OTA_LP_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LP_CATEGORY_API" as
/* $Header: otlciapi.pkb 115.2 2003/12/30 18:49:37 dhmulia noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_LP_CATEGORY_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_lp_cat_inclusion >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_lp_cat_inclusion
  (p_validate                      in     boolean  default false,
  p_effective_date                in     date,
  p_learning_path_id          in  number,
    p_category_usage_id            in  number ,
      p_object_version_number        out nocopy number,
  p_start_date_active            in  date       ,
  p_end_date_active              in  date       ,
  p_primary_flag                 in  varchar2  default 'N',

  p_attribute_category     in  varchar2  ,
  p_attribute1             in  varchar2  ,
  p_attribute2             in  varchar2  ,
  p_attribute3             in  varchar2  ,
  p_attribute4             in  varchar2  ,
  p_attribute5             in  varchar2   ,
  p_attribute6             in  varchar2   ,
  p_attribute7             in  varchar2   ,
  p_attribute8             in  varchar2   ,
  p_attribute9             in  varchar2   ,
  p_attribute10            in  varchar2   ,
  p_attribute11            in  varchar2   ,
  p_attribute12            in  varchar2   ,
  p_attribute13            in  varchar2   ,
  p_attribute14            in  varchar2   ,
  p_attribute15            in  varchar2   ,
  p_attribute16            in  varchar2   ,
  p_attribute17            in  varchar2   ,
  p_attribute18            in  varchar2   ,
  p_attribute19            in  varchar2   ,
  p_attribute20            in  varchar2

  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_lp_cat_inclusion ';
  l_object_version_number   number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_lp_cat_inclusion;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    ota_lp_category_bk1.create_lp_cat_inclusion_b
  (p_effective_date             => l_effective_date,
   p_learning_path_id        => p_learning_path_id ,
  p_object_version_number       => p_object_version_number,
  p_attribute_category    => p_attribute_category,
  p_attribute1            => p_attribute1,
  p_attribute2            => p_attribute2,
  p_attribute3            => p_attribute3,
  p_attribute4            => p_attribute4,
  p_attribute5            => p_attribute5 ,
  p_attribute6            => p_attribute6,
  p_attribute7            => p_attribute7,
  p_attribute8            => p_attribute8,
  p_attribute9            => p_attribute9,
  p_attribute10           => p_attribute10,
  p_attribute11           => p_attribute11,
  p_attribute12           => p_attribute12,
  p_attribute13           => p_attribute13,
  p_attribute14           => p_attribute14,
  p_attribute15           => p_attribute15,
  p_attribute16           => p_attribute16,
  p_attribute17           => p_attribute17,
  p_attribute18           => p_attribute18,
  p_attribute19           => p_attribute19,
  p_attribute20           => p_attribute20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_lp_cat_inclusion_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_lci_ins.ins
  (p_effective_date             => l_effective_date,
   p_learning_path_id        => p_learning_path_id ,
  p_object_version_number       => p_object_version_number,
  p_attribute_category    => p_attribute_category,
  p_attribute1            => p_attribute1,
  p_attribute2            => p_attribute2,
  p_attribute3            => p_attribute3,
  p_attribute4            => p_attribute4,
  p_attribute5            => p_attribute5 ,
  p_attribute6            => p_attribute6,
  p_attribute7            => p_attribute7,
  p_attribute8            => p_attribute8,
  p_attribute9            => p_attribute9,
  p_attribute10           => p_attribute10,
  p_attribute11           => p_attribute11,
  p_attribute12           => p_attribute12,
  p_attribute13           => p_attribute13,
  p_attribute14           => p_attribute14,
  p_attribute15           => p_attribute15,
  p_attribute16           => p_attribute16,
  p_attribute17           => p_attribute17,
  p_attribute18           => p_attribute18,
  p_attribute19           => p_attribute19,
  p_attribute20           => p_attribute20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
);

  --
  -- Call After Process User Hook
  --
  begin
  ota_lp_category_bk1.create_lp_cat_inclusion_a
  (p_effective_date             => l_effective_date,
   p_learning_path_id        => p_learning_path_id ,
  p_object_version_number       => p_object_version_number,
  p_attribute_category    => p_attribute_category,
  p_attribute1            => p_attribute1,
  p_attribute2            => p_attribute2,
  p_attribute3            => p_attribute3,
  p_attribute4            => p_attribute4,
  p_attribute5            => p_attribute5 ,
  p_attribute6            => p_attribute6,
  p_attribute7            => p_attribute7,
  p_attribute8            => p_attribute8,
  p_attribute9            => p_attribute9,
  p_attribute10           => p_attribute10,
  p_attribute11           => p_attribute11,
  p_attribute12           => p_attribute12,
  p_attribute13           => p_attribute13,
  p_attribute14           => p_attribute14,
  p_attribute15           => p_attribute15,
  p_attribute16           => p_attribute16,
  p_attribute17           => p_attribute17,
  p_attribute18           => p_attribute18,
  p_attribute19           => p_attribute19,
  p_attribute20           => p_attribute20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_lp_cat_inclusion_a'
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
    rollback to create_lp_cat_inclusion;
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
    rollback to create_lp_cat_inclusion;
    p_object_version_number :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_lp_cat_inclusion ;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_lp_cat_inclusion >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_lp_cat_inclusion
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_learning_path_id          in number
  ,p_object_version_number        in out nocopy number
  ,p_attribute_category     in varchar2     default hr_api.g_varchar2
  ,p_attribute1             in varchar2     default hr_api.g_varchar2
  ,p_attribute2             in varchar2     default hr_api.g_varchar2
  ,p_attribute3             in varchar2     default hr_api.g_varchar2
  ,p_attribute4             in varchar2     default hr_api.g_varchar2
  ,p_attribute5             in varchar2     default hr_api.g_varchar2
  ,p_attribute6             in varchar2     default hr_api.g_varchar2
  ,p_attribute7             in varchar2     default hr_api.g_varchar2
  ,p_attribute8             in varchar2     default hr_api.g_varchar2
  ,p_attribute9             in varchar2     default hr_api.g_varchar2
  ,p_attribute10            in varchar2     default hr_api.g_varchar2
  ,p_attribute11            in varchar2     default hr_api.g_varchar2
  ,p_attribute12            in varchar2     default hr_api.g_varchar2
  ,p_attribute13            in varchar2     default hr_api.g_varchar2
  ,p_attribute14            in varchar2     default hr_api.g_varchar2
  ,p_attribute15            in varchar2     default hr_api.g_varchar2
  ,p_attribute16            in varchar2     default hr_api.g_varchar2
  ,p_attribute17            in varchar2     default hr_api.g_varchar2
  ,p_attribute18            in varchar2     default hr_api.g_varchar2
  ,p_attribute19            in varchar2     default hr_api.g_varchar2
  ,p_attribute20            in varchar2     default hr_api.g_varchar2
  ,p_start_date_active            in date         default hr_api.g_date
  ,p_end_date_active              in date         default hr_api.g_date
  ,p_primary_flag                 in varchar2     default hr_api.g_varchar2
  ,p_category_usage_id            in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_lp_cat_inclusion ';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_lp_cat_inclusion ;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --

  -- Call Before Process User Hook
  --
  begin
    ota_lp_category_bk2.update_lp_cat_inclusion_b
   (p_effective_date             => l_effective_date,
   p_learning_path_id        => p_learning_path_id ,
  p_object_version_number       => p_object_version_number,
  p_attribute_category    => p_attribute_category,
  p_attribute1            => p_attribute1,
  p_attribute2            => p_attribute2,
  p_attribute3            => p_attribute3,
  p_attribute4            => p_attribute4,
  p_attribute5            => p_attribute5 ,
  p_attribute6            => p_attribute6,
  p_attribute7            => p_attribute7,
  p_attribute8            => p_attribute8,
  p_attribute9            => p_attribute9,
  p_attribute10           => p_attribute10,
  p_attribute11           => p_attribute11,
  p_attribute12           => p_attribute12,
  p_attribute13           => p_attribute13,
  p_attribute14           => p_attribute14,
  p_attribute15           => p_attribute15,
  p_attribute16           => p_attribute16,
  p_attribute17           => p_attribute17,
  p_attribute18           => p_attribute18,
  p_attribute19           => p_attribute19,
  p_attribute20           => p_attribute20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_lp_cat_inclusion_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_lci_upd.upd
   (p_effective_date             => l_effective_date,
   p_learning_path_id        => p_learning_path_id ,
  p_object_version_number       => p_object_version_number,
  p_attribute_category    => p_attribute_category,
  p_attribute1            => p_attribute1,
  p_attribute2            => p_attribute2,
  p_attribute3            => p_attribute3,
  p_attribute4            => p_attribute4,
  p_attribute5            => p_attribute5 ,
  p_attribute6            => p_attribute6,
  p_attribute7            => p_attribute7,
  p_attribute8            => p_attribute8,
  p_attribute9            => p_attribute9,
  p_attribute10           => p_attribute10,
  p_attribute11           => p_attribute11,
  p_attribute12           => p_attribute12,
  p_attribute13           => p_attribute13,
  p_attribute14           => p_attribute14,
  p_attribute15           => p_attribute15,
  p_attribute16           => p_attribute16,
  p_attribute17           => p_attribute17,
  p_attribute18           => p_attribute18,
  p_attribute19           => p_attribute19,
  p_attribute20           => p_attribute20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_lp_category_bk2.update_lp_cat_inclusion_a
   (p_effective_date             => l_effective_date,
   p_learning_path_id        => p_learning_path_id ,
  p_object_version_number       => p_object_version_number,
  p_attribute_category    => p_attribute_category,
  p_attribute1            => p_attribute1,
  p_attribute2            => p_attribute2,
  p_attribute3            => p_attribute3,
  p_attribute4            => p_attribute4,
  p_attribute5            => p_attribute5 ,
  p_attribute6            => p_attribute6,
  p_attribute7            => p_attribute7,
  p_attribute8            => p_attribute8,
  p_attribute9            => p_attribute9,
  p_attribute10           => p_attribute10,
  p_attribute11           => p_attribute11,
  p_attribute12           => p_attribute12,
  p_attribute13           => p_attribute13,
  p_attribute14           => p_attribute14,
  p_attribute15           => p_attribute15,
  p_attribute16           => p_attribute16,
  p_attribute17           => p_attribute17,
  p_attribute18           => p_attribute18,
  p_attribute19           => p_attribute19,
  p_attribute20           => p_attribute20,
  p_start_date_active           => p_start_date_active,
  p_end_date_active             => p_end_date_active,
  p_primary_flag                => p_primary_flag,
  p_category_usage_id           => p_category_usage_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_lp_cat_inclusion'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_lp_cat_inclusion ;
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
    rollback to update_lp_cat_inclusion ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_object_version_number := l_object_version_number;
    raise;
end update_lp_cat_inclusion ;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_lp_cat_inclusion >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lp_cat_inclusion
( p_learning_path_id                in number,
  p_category_usage_id                   in varchar2,
  p_object_version_number              in number,
  p_validate                           in boolean default false

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' delete_lp_cat_inclusion ';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_lp_cat_inclusion ;
  --
  -- Call Before Process User Hook
  --
  begin
    ota_lp_category_bk3.delete_lp_cat_inclusion_b
    (p_learning_path_id        => p_learning_path_id ,
     p_category_usage_id           => p_category_usage_id,
     p_object_version_number       => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_lp_cat_inclusion_b '
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  OTA_lci_del.del
    (p_learning_path_id        => p_learning_path_id ,
     p_category_usage_id           => p_category_usage_id,
     p_object_version_number       => p_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
  ota_lp_category_bk3.delete_lp_cat_inclusion_a
    (p_learning_path_id        => p_learning_path_id ,
     p_category_usage_id           => p_category_usage_id,
     p_object_version_number       => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_lp_cat_inclusion_a '
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
    rollback to delete_lp_cat_inclusion ;
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
    rollback to delete_lp_cat_inclusion ;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_lp_cat_inclusion;
--
end ota_lp_category_api;

/
