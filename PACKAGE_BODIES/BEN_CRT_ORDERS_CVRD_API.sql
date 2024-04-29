--------------------------------------------------------
--  DDL for Package Body BEN_CRT_ORDERS_CVRD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRT_ORDERS_CVRD_API" as
/* $Header: becrdapi.pkb 115.3 2003/01/16 14:33:41 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_crt_orders_cvrd_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_crt_orders_cvrd >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_crt_orders_cvrd
  (p_validate                       in  boolean   default false
  ,p_crt_ordr_cvrd_per_id           out nocopy number
  ,p_crt_ordr_id                    in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_crd_attribute_category         in  varchar2  default null
  ,p_crd_attribute1                 in  varchar2  default null
  ,p_crd_attribute2                 in  varchar2  default null
  ,p_crd_attribute3                 in  varchar2  default null
  ,p_crd_attribute4                 in  varchar2  default null
  ,p_crd_attribute5                 in  varchar2  default null
  ,p_crd_attribute6                 in  varchar2  default null
  ,p_crd_attribute7                 in  varchar2  default null
  ,p_crd_attribute8                 in  varchar2  default null
  ,p_crd_attribute9                 in  varchar2  default null
  ,p_crd_attribute10                in  varchar2  default null
  ,p_crd_attribute11                in  varchar2  default null
  ,p_crd_attribute12                in  varchar2  default null
  ,p_crd_attribute13                in  varchar2  default null
  ,p_crd_attribute14                in  varchar2  default null
  ,p_crd_attribute15                in  varchar2  default null
  ,p_crd_attribute16                in  varchar2  default null
  ,p_crd_attribute17                in  varchar2  default null
  ,p_crd_attribute18                in  varchar2  default null
  ,p_crd_attribute19                in  varchar2  default null
  ,p_crd_attribute20                in  varchar2  default null
  ,p_crd_attribute21                in  varchar2  default null
  ,p_crd_attribute22                in  varchar2  default null
  ,p_crd_attribute23                in  varchar2  default null
  ,p_crd_attribute24                in  varchar2  default null
  ,p_crd_attribute25                in  varchar2  default null
  ,p_crd_attribute26                in  varchar2  default null
  ,p_crd_attribute27                in  varchar2  default null
  ,p_crd_attribute28                in  varchar2  default null
  ,p_crd_attribute29                in  varchar2  default null
  ,p_crd_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_crt_ordr_cvrd_per_id ben_crt_ordr_cvrd_per.crt_ordr_cvrd_per_id%TYPE;
  l_proc varchar2(72) := g_package||'create_crt_orders_cvrd';
  l_object_version_number ben_crt_ordr_cvrd_per.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_crt_orders_cvrd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_crt_orders_cvrd
    --
    ben_crt_orders_cvrd_bk1.create_crt_orders_cvrd_b
      (
       p_crt_ordr_id                    =>  p_crt_ordr_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_crd_attribute_category         =>  p_crd_attribute_category
      ,p_crd_attribute1                 =>  p_crd_attribute1
      ,p_crd_attribute2                 =>  p_crd_attribute2
      ,p_crd_attribute3                 =>  p_crd_attribute3
      ,p_crd_attribute4                 =>  p_crd_attribute4
      ,p_crd_attribute5                 =>  p_crd_attribute5
      ,p_crd_attribute6                 =>  p_crd_attribute6
      ,p_crd_attribute7                 =>  p_crd_attribute7
      ,p_crd_attribute8                 =>  p_crd_attribute8
      ,p_crd_attribute9                 =>  p_crd_attribute9
      ,p_crd_attribute10                =>  p_crd_attribute10
      ,p_crd_attribute11                =>  p_crd_attribute11
      ,p_crd_attribute12                =>  p_crd_attribute12
      ,p_crd_attribute13                =>  p_crd_attribute13
      ,p_crd_attribute14                =>  p_crd_attribute14
      ,p_crd_attribute15                =>  p_crd_attribute15
      ,p_crd_attribute16                =>  p_crd_attribute16
      ,p_crd_attribute17                =>  p_crd_attribute17
      ,p_crd_attribute18                =>  p_crd_attribute18
      ,p_crd_attribute19                =>  p_crd_attribute19
      ,p_crd_attribute20                =>  p_crd_attribute20
      ,p_crd_attribute21                =>  p_crd_attribute21
      ,p_crd_attribute22                =>  p_crd_attribute22
      ,p_crd_attribute23                =>  p_crd_attribute23
      ,p_crd_attribute24                =>  p_crd_attribute24
      ,p_crd_attribute25                =>  p_crd_attribute25
      ,p_crd_attribute26                =>  p_crd_attribute26
      ,p_crd_attribute27                =>  p_crd_attribute27
      ,p_crd_attribute28                =>  p_crd_attribute28
      ,p_crd_attribute29                =>  p_crd_attribute29
      ,p_crd_attribute30                =>  p_crd_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_crt_orders_cvrd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_crt_orders_cvrd
    --
  end;
  --
  ben_crd_ins.ins
    (
     p_crt_ordr_cvrd_per_id          => l_crt_ordr_cvrd_per_id
    ,p_crt_ordr_id                   => p_crt_ordr_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_crd_attribute_category        => p_crd_attribute_category
    ,p_crd_attribute1                => p_crd_attribute1
    ,p_crd_attribute2                => p_crd_attribute2
    ,p_crd_attribute3                => p_crd_attribute3
    ,p_crd_attribute4                => p_crd_attribute4
    ,p_crd_attribute5                => p_crd_attribute5
    ,p_crd_attribute6                => p_crd_attribute6
    ,p_crd_attribute7                => p_crd_attribute7
    ,p_crd_attribute8                => p_crd_attribute8
    ,p_crd_attribute9                => p_crd_attribute9
    ,p_crd_attribute10               => p_crd_attribute10
    ,p_crd_attribute11               => p_crd_attribute11
    ,p_crd_attribute12               => p_crd_attribute12
    ,p_crd_attribute13               => p_crd_attribute13
    ,p_crd_attribute14               => p_crd_attribute14
    ,p_crd_attribute15               => p_crd_attribute15
    ,p_crd_attribute16               => p_crd_attribute16
    ,p_crd_attribute17               => p_crd_attribute17
    ,p_crd_attribute18               => p_crd_attribute18
    ,p_crd_attribute19               => p_crd_attribute19
    ,p_crd_attribute20               => p_crd_attribute20
    ,p_crd_attribute21               => p_crd_attribute21
    ,p_crd_attribute22               => p_crd_attribute22
    ,p_crd_attribute23               => p_crd_attribute23
    ,p_crd_attribute24               => p_crd_attribute24
    ,p_crd_attribute25               => p_crd_attribute25
    ,p_crd_attribute26               => p_crd_attribute26
    ,p_crd_attribute27               => p_crd_attribute27
    ,p_crd_attribute28               => p_crd_attribute28
    ,p_crd_attribute29               => p_crd_attribute29
    ,p_crd_attribute30               => p_crd_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_crt_orders_cvrd
    --
    ben_crt_orders_cvrd_bk1.create_crt_orders_cvrd_a
      (
       p_crt_ordr_cvrd_per_id           =>  l_crt_ordr_cvrd_per_id
      ,p_crt_ordr_id                    =>  p_crt_ordr_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_crd_attribute_category         =>  p_crd_attribute_category
      ,p_crd_attribute1                 =>  p_crd_attribute1
      ,p_crd_attribute2                 =>  p_crd_attribute2
      ,p_crd_attribute3                 =>  p_crd_attribute3
      ,p_crd_attribute4                 =>  p_crd_attribute4
      ,p_crd_attribute5                 =>  p_crd_attribute5
      ,p_crd_attribute6                 =>  p_crd_attribute6
      ,p_crd_attribute7                 =>  p_crd_attribute7
      ,p_crd_attribute8                 =>  p_crd_attribute8
      ,p_crd_attribute9                 =>  p_crd_attribute9
      ,p_crd_attribute10                =>  p_crd_attribute10
      ,p_crd_attribute11                =>  p_crd_attribute11
      ,p_crd_attribute12                =>  p_crd_attribute12
      ,p_crd_attribute13                =>  p_crd_attribute13
      ,p_crd_attribute14                =>  p_crd_attribute14
      ,p_crd_attribute15                =>  p_crd_attribute15
      ,p_crd_attribute16                =>  p_crd_attribute16
      ,p_crd_attribute17                =>  p_crd_attribute17
      ,p_crd_attribute18                =>  p_crd_attribute18
      ,p_crd_attribute19                =>  p_crd_attribute19
      ,p_crd_attribute20                =>  p_crd_attribute20
      ,p_crd_attribute21                =>  p_crd_attribute21
      ,p_crd_attribute22                =>  p_crd_attribute22
      ,p_crd_attribute23                =>  p_crd_attribute23
      ,p_crd_attribute24                =>  p_crd_attribute24
      ,p_crd_attribute25                =>  p_crd_attribute25
      ,p_crd_attribute26                =>  p_crd_attribute26
      ,p_crd_attribute27                =>  p_crd_attribute27
      ,p_crd_attribute28                =>  p_crd_attribute28
      ,p_crd_attribute29                =>  p_crd_attribute29
      ,p_crd_attribute30                =>  p_crd_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_crt_orders_cvrd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_crt_orders_cvrd
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
  p_crt_ordr_cvrd_per_id := l_crt_ordr_cvrd_per_id;
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
    ROLLBACK TO create_crt_orders_cvrd;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_crt_ordr_cvrd_per_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_crt_orders_cvrd;
    p_crt_ordr_cvrd_per_id := null; --nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_crt_orders_cvrd;
-- ----------------------------------------------------------------------------
-- |------------------------< update_crt_orders_cvrd >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_crt_orders_cvrd
  (p_validate                       in  boolean   default false
  ,p_crt_ordr_cvrd_per_id           in  number
  ,p_crt_ordr_id                    in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_crd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_crd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_crt_orders_cvrd';
  l_object_version_number ben_crt_ordr_cvrd_per.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_crt_orders_cvrd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_crt_orders_cvrd
    --
    ben_crt_orders_cvrd_bk2.update_crt_orders_cvrd_b
      (
       p_crt_ordr_cvrd_per_id           =>  p_crt_ordr_cvrd_per_id
      ,p_crt_ordr_id                    =>  p_crt_ordr_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_crd_attribute_category         =>  p_crd_attribute_category
      ,p_crd_attribute1                 =>  p_crd_attribute1
      ,p_crd_attribute2                 =>  p_crd_attribute2
      ,p_crd_attribute3                 =>  p_crd_attribute3
      ,p_crd_attribute4                 =>  p_crd_attribute4
      ,p_crd_attribute5                 =>  p_crd_attribute5
      ,p_crd_attribute6                 =>  p_crd_attribute6
      ,p_crd_attribute7                 =>  p_crd_attribute7
      ,p_crd_attribute8                 =>  p_crd_attribute8
      ,p_crd_attribute9                 =>  p_crd_attribute9
      ,p_crd_attribute10                =>  p_crd_attribute10
      ,p_crd_attribute11                =>  p_crd_attribute11
      ,p_crd_attribute12                =>  p_crd_attribute12
      ,p_crd_attribute13                =>  p_crd_attribute13
      ,p_crd_attribute14                =>  p_crd_attribute14
      ,p_crd_attribute15                =>  p_crd_attribute15
      ,p_crd_attribute16                =>  p_crd_attribute16
      ,p_crd_attribute17                =>  p_crd_attribute17
      ,p_crd_attribute18                =>  p_crd_attribute18
      ,p_crd_attribute19                =>  p_crd_attribute19
      ,p_crd_attribute20                =>  p_crd_attribute20
      ,p_crd_attribute21                =>  p_crd_attribute21
      ,p_crd_attribute22                =>  p_crd_attribute22
      ,p_crd_attribute23                =>  p_crd_attribute23
      ,p_crd_attribute24                =>  p_crd_attribute24
      ,p_crd_attribute25                =>  p_crd_attribute25
      ,p_crd_attribute26                =>  p_crd_attribute26
      ,p_crd_attribute27                =>  p_crd_attribute27
      ,p_crd_attribute28                =>  p_crd_attribute28
      ,p_crd_attribute29                =>  p_crd_attribute29
      ,p_crd_attribute30                =>  p_crd_attribute30
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_crt_orders_cvrd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_crt_orders_cvrd
    --
  end;
  --
  ben_crd_upd.upd
    (
     p_crt_ordr_cvrd_per_id          => p_crt_ordr_cvrd_per_id
    ,p_crt_ordr_id                   => p_crt_ordr_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_crd_attribute_category        => p_crd_attribute_category
    ,p_crd_attribute1                => p_crd_attribute1
    ,p_crd_attribute2                => p_crd_attribute2
    ,p_crd_attribute3                => p_crd_attribute3
    ,p_crd_attribute4                => p_crd_attribute4
    ,p_crd_attribute5                => p_crd_attribute5
    ,p_crd_attribute6                => p_crd_attribute6
    ,p_crd_attribute7                => p_crd_attribute7
    ,p_crd_attribute8                => p_crd_attribute8
    ,p_crd_attribute9                => p_crd_attribute9
    ,p_crd_attribute10               => p_crd_attribute10
    ,p_crd_attribute11               => p_crd_attribute11
    ,p_crd_attribute12               => p_crd_attribute12
    ,p_crd_attribute13               => p_crd_attribute13
    ,p_crd_attribute14               => p_crd_attribute14
    ,p_crd_attribute15               => p_crd_attribute15
    ,p_crd_attribute16               => p_crd_attribute16
    ,p_crd_attribute17               => p_crd_attribute17
    ,p_crd_attribute18               => p_crd_attribute18
    ,p_crd_attribute19               => p_crd_attribute19
    ,p_crd_attribute20               => p_crd_attribute20
    ,p_crd_attribute21               => p_crd_attribute21
    ,p_crd_attribute22               => p_crd_attribute22
    ,p_crd_attribute23               => p_crd_attribute23
    ,p_crd_attribute24               => p_crd_attribute24
    ,p_crd_attribute25               => p_crd_attribute25
    ,p_crd_attribute26               => p_crd_attribute26
    ,p_crd_attribute27               => p_crd_attribute27
    ,p_crd_attribute28               => p_crd_attribute28
    ,p_crd_attribute29               => p_crd_attribute29
    ,p_crd_attribute30               => p_crd_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_crt_orders_cvrd
    --
    ben_crt_orders_cvrd_bk2.update_crt_orders_cvrd_a
      (
       p_crt_ordr_cvrd_per_id           =>  p_crt_ordr_cvrd_per_id
      ,p_crt_ordr_id                    =>  p_crt_ordr_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_crd_attribute_category         =>  p_crd_attribute_category
      ,p_crd_attribute1                 =>  p_crd_attribute1
      ,p_crd_attribute2                 =>  p_crd_attribute2
      ,p_crd_attribute3                 =>  p_crd_attribute3
      ,p_crd_attribute4                 =>  p_crd_attribute4
      ,p_crd_attribute5                 =>  p_crd_attribute5
      ,p_crd_attribute6                 =>  p_crd_attribute6
      ,p_crd_attribute7                 =>  p_crd_attribute7
      ,p_crd_attribute8                 =>  p_crd_attribute8
      ,p_crd_attribute9                 =>  p_crd_attribute9
      ,p_crd_attribute10                =>  p_crd_attribute10
      ,p_crd_attribute11                =>  p_crd_attribute11
      ,p_crd_attribute12                =>  p_crd_attribute12
      ,p_crd_attribute13                =>  p_crd_attribute13
      ,p_crd_attribute14                =>  p_crd_attribute14
      ,p_crd_attribute15                =>  p_crd_attribute15
      ,p_crd_attribute16                =>  p_crd_attribute16
      ,p_crd_attribute17                =>  p_crd_attribute17
      ,p_crd_attribute18                =>  p_crd_attribute18
      ,p_crd_attribute19                =>  p_crd_attribute19
      ,p_crd_attribute20                =>  p_crd_attribute20
      ,p_crd_attribute21                =>  p_crd_attribute21
      ,p_crd_attribute22                =>  p_crd_attribute22
      ,p_crd_attribute23                =>  p_crd_attribute23
      ,p_crd_attribute24                =>  p_crd_attribute24
      ,p_crd_attribute25                =>  p_crd_attribute25
      ,p_crd_attribute26                =>  p_crd_attribute26
      ,p_crd_attribute27                =>  p_crd_attribute27
      ,p_crd_attribute28                =>  p_crd_attribute28
      ,p_crd_attribute29                =>  p_crd_attribute29
      ,p_crd_attribute30                =>  p_crd_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_crt_orders_cvrd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_crt_orders_cvrd
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
    ROLLBACK TO update_crt_orders_cvrd;
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
    ROLLBACK TO update_crt_orders_cvrd;
    raise;
    --
end update_crt_orders_cvrd;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_crt_orders_cvrd >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_crt_orders_cvrd
  (p_validate                       in  boolean  default false
  ,p_crt_ordr_cvrd_per_id           in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_crt_orders_cvrd';
  l_object_version_number ben_crt_ordr_cvrd_per.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_crt_orders_cvrd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_crt_orders_cvrd
    --
    ben_crt_orders_cvrd_bk3.delete_crt_orders_cvrd_b
      (
       p_crt_ordr_cvrd_per_id           =>  p_crt_ordr_cvrd_per_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_crt_orders_cvrd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_crt_orders_cvrd
    --
  end;
  --
  ben_crd_del.del
    (
     p_crt_ordr_cvrd_per_id          => p_crt_ordr_cvrd_per_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_crt_orders_cvrd
    --
    ben_crt_orders_cvrd_bk3.delete_crt_orders_cvrd_a
      (
       p_crt_ordr_cvrd_per_id           =>  p_crt_ordr_cvrd_per_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_crt_orders_cvrd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_crt_orders_cvrd
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
    ROLLBACK TO delete_crt_orders_cvrd;

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
    ROLLBACK TO delete_crt_orders_cvrd;

    raise;
    --
end delete_crt_orders_cvrd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_crt_ordr_cvrd_per_id                   in     number
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
  ben_crd_shd.lck
    (
      p_crt_ordr_cvrd_per_id                 => p_crt_ordr_cvrd_per_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_crt_orders_cvrd_api;

/
