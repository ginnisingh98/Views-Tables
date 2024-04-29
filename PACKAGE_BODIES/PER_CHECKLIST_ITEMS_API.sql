--------------------------------------------------------
--  DDL for Package Body PER_CHECKLIST_ITEMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CHECKLIST_ITEMS_API" as
/* $Header: pechkapi.pkb 115.12 2002/12/10 15:06:28 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_checklist_items_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_checklist_items >----------------------|
-- ----------------------------------------------------------------------------
--
-- Made people , status and item mandatory
procedure create_checklist_items
  (p_validate                       in  boolean   --default false
  ,p_effective_date                 in  date
  ,p_person_id                      in  number
  ,p_item_code                      in  varchar2
  ,p_date_due                       in  date      --default null
  ,p_date_done                      in  date      --default null
  ,p_status                         in  varchar2  --default null
  ,p_notes                          in  varchar2  --default null
  ,p_attribute_category             in  varchar2  --default null
  ,p_attribute1                     in  varchar2  --default null
  ,p_attribute2                     in  varchar2  --default null
  ,p_attribute3                     in  varchar2  --default null
  ,p_attribute4                     in  varchar2  --default null
  ,p_attribute5                     in  varchar2  --default null
  ,p_attribute6                     in  varchar2  --default null
  ,p_attribute7                     in  varchar2  --default null
  ,p_attribute8                     in  varchar2  --default null
  ,p_attribute9                     in  varchar2  --default null
  ,p_attribute10                    in  varchar2  --default null
  ,p_attribute11                    in  varchar2  --default null
  ,p_attribute12                    in  varchar2  --default null
  ,p_attribute13                    in  varchar2  --default null
  ,p_attribute14                    in  varchar2  --default null
  ,p_attribute15                    in  varchar2  --default null
  ,p_attribute16                    in  varchar2  --default null
  ,p_attribute17                    in  varchar2  --default null
  ,p_attribute18                    in  varchar2  --default null
  ,p_attribute19                    in  varchar2  --default null
  ,p_attribute20                    in  varchar2  --default null
  ,p_attribute21                    in  varchar2  --default null
  ,p_attribute22                    in  varchar2  --default null
  ,p_attribute23                    in  varchar2  --default null
  ,p_attribute24                    in  varchar2  --default null
  ,p_attribute25                    in  varchar2  --default null
  ,p_attribute26                    in  varchar2  --default null
  ,p_attribute27                    in  varchar2  --default null
  ,p_attribute28                    in  varchar2  --default null
  ,p_attribute29                    in  varchar2  --default null
  ,p_attribute30                    in  varchar2  --default null
  ,p_checklist_item_id              out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_checklist_item_id per_checklist_items.checklist_item_id%TYPE;
  l_proc varchar2(72) := g_package||'create_checklist_items';
  l_object_version_number per_checklist_items.object_version_number%TYPE;
  -- l_language_code         hr_locations_all_tl.language%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_checklist_items;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_checklist_items
    --
    per_checklist_items_bk1.create_checklist_items_b
      (
       p_effective_date                 =>  TRUNC(p_effective_date)
      ,p_person_id                      =>  p_person_id
      ,p_item_code                      =>  p_item_code
      ,p_date_due                       =>  p_date_due
      ,p_date_done                      =>  p_date_done
      ,p_status                         =>  p_status
      ,p_notes                          =>  p_notes
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_checklist_items'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_checklist_items
    --
  end;
  --
  per_chk_ins.ins
    (
    p_effective_date                 =>  TRUNC(p_effective_date)
    ,p_checklist_item_id             => l_checklist_item_id
    ,p_person_id                     => p_person_id
    ,p_item_code                     => p_item_code
    ,p_date_due                      => p_date_due
    ,p_date_done                     => p_date_done
    ,p_status                        => p_status
    ,p_notes                         => p_notes
    ,p_object_version_number         => l_object_version_number
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    );
--
  begin
    --
    -- Start of API User Hook for the after hook of create_checklist_items
    --
    per_checklist_items_bk1.create_checklist_items_a
      (
      p_effective_date                 =>  TRUNC(p_effective_date)
      ,p_person_id                      =>  p_person_id
      ,p_item_code                      =>  p_item_code
      ,p_date_due                       =>  p_date_due
      ,p_date_done                      =>  p_date_done
      ,p_status                         =>  p_status
      ,p_notes                          =>  p_notes
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_checklist_item_id              =>  l_checklist_item_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_checklist_items'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_checklist_items
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_checklist_item_id := l_checklist_item_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_checklist_items;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_checklist_item_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_checklist_items;
    -- Reset IN OUT parameters and set OUT parameters
     p_checklist_item_id := null;
     p_object_version_number  := null;
     hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_checklist_items;
-- ----------------------------------------------------------------------------
-- |------------------------< update_checklist_items >------------------------|
-- ----------------------------------------------------------------------------
--
-- Made people , status and item code mandatory
procedure update_checklist_items
  (p_validate                       in  boolean   --default false
  ,p_effective_date                 in  date
  ,p_checklist_item_id              in  number
  ,p_person_id                      in  number    --default hr_api.g_number
  ,p_item_code                      in  varchar2  --default hr_api.g_varchar2
  ,p_date_due                       in  date      --default hr_api.g_date
  ,p_date_done                      in  date      --default hr_api.g_date
  ,p_status                         in  varchar2  --default hr_api.g_varchar2
  ,p_notes                          in  varchar2  --default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  --default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute21                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  --default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_checklist_items';
  l_object_version_number per_checklist_items.object_version_number%TYPE;
  l_temp_object_version_number per_checklist_items.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_checklist_items;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_temp_object_version_number := p_object_version_number;
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_checklist_items
    --
    per_checklist_items_bk2.update_checklist_items_b
      (
      p_effective_date                  =>  TRUNC(p_effective_date)
      ,p_checklist_item_id              =>  p_checklist_item_id
      ,p_person_id                      =>  p_person_id
      ,p_item_code                      =>  p_item_code
      ,p_date_due                       =>  p_date_due
      ,p_date_done                      =>  p_date_done
      ,p_status                         =>  p_status
      ,p_notes                          =>  p_notes
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_checklist_items'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_checklist_items
    --
  end;
  --
  per_chk_upd.upd
    (
    p_effective_date                 =>  TRUNC(p_effective_date)
    ,p_checklist_item_id             => p_checklist_item_id
    ,p_person_id                     => p_person_id
    ,p_item_code                     => p_item_code
    ,p_date_due                      => p_date_due
    ,p_date_done                     => p_date_done
    ,p_status                        => p_status
    ,p_notes                         => p_notes
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_checklist_items
    --
    per_checklist_items_bk2.update_checklist_items_a
      (
      p_effective_date                  =>  TRUNC(p_effective_date)
      ,p_checklist_item_id              =>  p_checklist_item_id
      ,p_person_id                      =>  p_person_id
      ,p_item_code                      =>  p_item_code
      ,p_date_due                       =>  p_date_due
      ,p_date_done                      =>  p_date_done
      ,p_status                         =>  p_status
      ,p_notes                          =>  p_notes
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_checklist_items'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_checklist_items
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_checklist_items;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_checklist_items;

    -- Reset IN OUT parameters and set out OUT parameters
    p_object_version_number 	:= l_temp_object_version_number;

    raise;
    --
end update_checklist_items;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_checklist_items >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_checklist_items
  (p_validate                       in  boolean  --default false
  ,p_checklist_item_id              in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_checklist_items';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_checklist_items;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_checklist_items
    --
    per_checklist_items_bk3.delete_checklist_items_b
      (
       p_checklist_item_id              =>  p_checklist_item_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_checklist_items'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_checklist_items
    --
  end;
  --
  per_chk_del.del
    (
     p_checklist_item_id             => p_checklist_item_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_checklist_items
    --
    per_checklist_items_bk3.delete_checklist_items_a
      (
       p_checklist_item_id              =>  p_checklist_item_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_checklist_items'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_checklist_items
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_checklist_items;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_checklist_items;
    raise;
    --
end delete_checklist_items;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_checklist_item_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  per_chk_shd.lck
    (
      p_checklist_item_id                 => p_checklist_item_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
-- ----------------------------------------------------------------------------
-- |------------------------< cre_upd_checklist_items >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure cre_or_upd_checklist_items
  (
   p_validate                       in boolean    --default false
  ,p_effective_date                 in date
  ,p_person_id                      in  number    --default hr_api.g_number
  ,p_item_code                      in  varchar2  --default hr_api.g_varchar2
  ,p_date_due                       in  date      --default hr_api.g_date
  ,p_date_done                      in  date      --default hr_api.g_date
  ,p_status                         in  varchar2  --default hr_api.g_varchar2
  ,p_notes                          in  varchar2  --default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  --default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  --default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute21                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  --default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  --default hr_api.g_varchar2
  ,p_checklist_item_id              in out nocopy number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  l_chk_rec    per_chk_shd.g_rec_type;
  l_null_chk_rec    per_chk_shd.g_rec_type;
  l_proc varchar2(72) := g_package||'cre_or_upd_checklist_items';
  l_api_updating boolean;
  l_checklist_item_id number;
  l_object_version_number number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint cre_or_upd_checklist_items;
  --
  l_checklist_item_id := p_checklist_item_id;
  l_object_version_number:= p_object_version_number;
  l_api_updating:=per_chk_shd.api_updating
  (p_checklist_item_id     => p_checklist_item_id
  ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_chk_rec :=
  per_chk_shd.convert_args
  (p_checklist_item_id
  ,p_person_id
  ,p_item_code
  ,p_date_due
  ,p_date_done
  ,p_status
  ,p_notes
  ,p_object_version_number
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  );
  --
  if not l_api_updating then
    --
    -- set g_old_rec to null;
    --
    per_chk_shd.g_old_rec:=l_null_chk_rec;
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- convert the null values
    --
    hr_utility.set_location(l_proc, 40);
    per_chk_upd.convert_defs(l_chk_rec);
    --
    -- insert the data
    --
    hr_utility.set_location(l_proc, 50);
    --
    per_checklist_items_api.create_checklist_items
    (p_validate              => FALSE
    ,p_effective_date        => TRUNC(p_effective_date)
    ,p_person_id             => l_chk_rec.person_id
    ,p_item_code             => l_chk_rec.item_code
    ,p_date_due              => l_chk_rec.date_due
    ,p_date_done             => l_chk_rec.date_done
    ,p_status                => l_chk_rec.status
    ,p_notes                 => l_chk_rec.notes
    ,p_attribute_category    => l_chk_rec.attribute_category
    ,p_attribute1            => l_chk_rec.attribute1
    ,p_attribute2            => l_chk_rec.attribute2
    ,p_attribute3            => l_chk_rec.attribute3
    ,p_attribute4            => l_chk_rec.attribute4
    ,p_attribute5            => l_chk_rec.attribute5
    ,p_attribute6            => l_chk_rec.attribute6
    ,p_attribute7            => l_chk_rec.attribute7
    ,p_attribute8            => l_chk_rec.attribute8
    ,p_attribute9            => l_chk_rec.attribute9
    ,p_attribute10           => l_chk_rec.attribute10
    ,p_attribute11           => l_chk_rec.attribute11
    ,p_attribute12           => l_chk_rec.attribute12
    ,p_attribute13           => l_chk_rec.attribute13
    ,p_attribute14           => l_chk_rec.attribute14
    ,p_attribute15           => l_chk_rec.attribute15
    ,p_attribute16           => l_chk_rec.attribute16
    ,p_attribute17           => l_chk_rec.attribute17
    ,p_attribute18           => l_chk_rec.attribute18
    ,p_attribute19           => l_chk_rec.attribute19
    ,p_attribute20           => l_chk_rec.attribute20
    ,p_attribute21           => l_chk_rec.attribute21
    ,p_attribute22           => l_chk_rec.attribute22
    ,p_attribute23           => l_chk_rec.attribute23
    ,p_attribute24           => l_chk_rec.attribute24
    ,p_attribute25           => l_chk_rec.attribute25
    ,p_attribute26           => l_chk_rec.attribute26
    ,p_attribute27           => l_chk_rec.attribute27
    ,p_attribute28           => l_chk_rec.attribute28
    ,p_attribute29           => l_chk_rec.attribute29
    ,p_attribute30           => l_chk_rec.attribute30
    ,p_checklist_item_id     => l_chk_rec.checklist_item_id
    ,p_object_version_number => l_chk_rec.object_version_number);
    hr_utility.set_location(l_proc, 60);
  else
  --
  -- updating not inserting
  --
    hr_utility.set_location(l_proc, 70);
    per_chk_shd.lck
      (p_checklist_item_id         => p_checklist_item_id
      ,p_object_version_number     => p_object_version_number);
    --
    -- convert the null values
    --
    hr_utility.set_location(l_proc, 80);
    per_chk_upd.convert_defs(l_chk_rec);
    --
    -- update the data
    --
    hr_utility.set_location(l_proc, 90);
    --
    per_checklist_items_api.update_checklist_items
    (p_validate              => FALSE
    ,p_effective_date        => TRUNC(p_effective_date)
    ,p_checklist_item_id     => l_chk_rec.checklist_item_id
    ,p_person_id             => l_chk_rec.person_id
    ,p_item_code             => l_chk_rec.item_code
    ,p_date_due              => l_chk_rec.date_due
    ,p_date_done             => l_chk_rec.date_done
    ,p_status                => l_chk_rec.status
    ,p_notes                 => l_chk_rec.notes
    ,p_attribute_category    => l_chk_rec.attribute_category
    ,p_attribute1            => l_chk_rec.attribute1
    ,p_attribute2            => l_chk_rec.attribute2
    ,p_attribute3            => l_chk_rec.attribute3
    ,p_attribute4            => l_chk_rec.attribute4
    ,p_attribute5            => l_chk_rec.attribute5
    ,p_attribute6            => l_chk_rec.attribute6
    ,p_attribute7            => l_chk_rec.attribute7
    ,p_attribute8            => l_chk_rec.attribute8
    ,p_attribute9            => l_chk_rec.attribute9
    ,p_attribute10           => l_chk_rec.attribute10
    ,p_attribute11           => l_chk_rec.attribute11
    ,p_attribute12           => l_chk_rec.attribute12
    ,p_attribute13           => l_chk_rec.attribute13
    ,p_attribute14           => l_chk_rec.attribute14
    ,p_attribute15           => l_chk_rec.attribute15
    ,p_attribute16           => l_chk_rec.attribute16
    ,p_attribute17           => l_chk_rec.attribute17
    ,p_attribute18           => l_chk_rec.attribute18
    ,p_attribute19           => l_chk_rec.attribute19
    ,p_attribute20           => l_chk_rec.attribute20
    ,p_attribute21           => l_chk_rec.attribute21
    ,p_attribute22           => l_chk_rec.attribute22
    ,p_attribute23           => l_chk_rec.attribute23
    ,p_attribute24           => l_chk_rec.attribute24
    ,p_attribute25           => l_chk_rec.attribute25
    ,p_attribute26           => l_chk_rec.attribute26
    ,p_attribute27           => l_chk_rec.attribute27
    ,p_attribute28           => l_chk_rec.attribute28
    ,p_attribute29           => l_chk_rec.attribute29
    ,p_attribute30           => l_chk_rec.attribute30
    ,p_object_version_number => l_chk_rec.object_version_number);
    --
    hr_utility.set_location(l_proc, 100);
    --
  end if;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 110);
  --
  p_checklist_item_id := l_chk_rec.checklist_item_id;
  p_object_version_number := l_chk_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 120);
  --
exception
  when hr_api.validate_enabled then
    rollback to cre_or_upd_checklist_items;
    p_checklist_item_id := null;
    p_object_version_number:=null;
    hr_utility.set_location('Leaving:'||l_proc, 130);
  when others then
    rollback to cre_or_upd_checklist_items;
        --
    -- set in out parameters and set out parameters
    --
    p_checklist_item_id := l_checklist_item_id;
    p_object_version_number := l_object_version_number;
    hr_utility.set_location('Leaving:'||l_proc, 140);
    raise;
  --
end cre_or_upd_checklist_items;
--
end per_checklist_items_api;

/
