--------------------------------------------------------
--  DDL for Package Body BEN_BENEFITS_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENEFITS_GROUP_API" as
/* $Header: bebngapi.pkb 115.4 2002/12/16 09:35:56 hnarayan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Benefits_Group_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Benefits_Group >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Benefits_Group
  (p_validate                       in  boolean   default false
  ,p_benfts_grp_id                  out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_bng_desc                       in  varchar2  default null
  ,p_bng_attribute_category         in  varchar2  default null
  ,p_bng_attribute1                 in  varchar2  default null
  ,p_bng_attribute2                 in  varchar2  default null
  ,p_bng_attribute3                 in  varchar2  default null
  ,p_bng_attribute4                 in  varchar2  default null
  ,p_bng_attribute5                 in  varchar2  default null
  ,p_bng_attribute6                 in  varchar2  default null
  ,p_bng_attribute7                 in  varchar2  default null
  ,p_bng_attribute8                 in  varchar2  default null
  ,p_bng_attribute9                 in  varchar2  default null
  ,p_bng_attribute10                in  varchar2  default null
  ,p_bng_attribute11                in  varchar2  default null
  ,p_bng_attribute12                in  varchar2  default null
  ,p_bng_attribute13                in  varchar2  default null
  ,p_bng_attribute14                in  varchar2  default null
  ,p_bng_attribute15                in  varchar2  default null
  ,p_bng_attribute16                in  varchar2  default null
  ,p_bng_attribute17                in  varchar2  default null
  ,p_bng_attribute18                in  varchar2  default null
  ,p_bng_attribute19                in  varchar2  default null
  ,p_bng_attribute20                in  varchar2  default null
  ,p_bng_attribute21                in  varchar2  default null
  ,p_bng_attribute22                in  varchar2  default null
  ,p_bng_attribute23                in  varchar2  default null
  ,p_bng_attribute24                in  varchar2  default null
  ,p_bng_attribute25                in  varchar2  default null
  ,p_bng_attribute26                in  varchar2  default null
  ,p_bng_attribute27                in  varchar2  default null
  ,p_bng_attribute28                in  varchar2  default null
  ,p_bng_attribute29                in  varchar2  default null
  ,p_bng_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_benfts_grp_id ben_benfts_grp.benfts_grp_id%TYPE;
  l_proc varchar2(72) := g_package||'create_Benefits_Group';
  l_object_version_number ben_benfts_grp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Benefits_Group;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Benefits_Group
    --
    ben_Benefits_Group_bk1.create_Benefits_Group_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_name                           =>  p_name
      ,p_bng_desc                       =>  p_bng_desc
      ,p_bng_attribute_category         =>  p_bng_attribute_category
      ,p_bng_attribute1                 =>  p_bng_attribute1
      ,p_bng_attribute2                 =>  p_bng_attribute2
      ,p_bng_attribute3                 =>  p_bng_attribute3
      ,p_bng_attribute4                 =>  p_bng_attribute4
      ,p_bng_attribute5                 =>  p_bng_attribute5
      ,p_bng_attribute6                 =>  p_bng_attribute6
      ,p_bng_attribute7                 =>  p_bng_attribute7
      ,p_bng_attribute8                 =>  p_bng_attribute8
      ,p_bng_attribute9                 =>  p_bng_attribute9
      ,p_bng_attribute10                =>  p_bng_attribute10
      ,p_bng_attribute11                =>  p_bng_attribute11
      ,p_bng_attribute12                =>  p_bng_attribute12
      ,p_bng_attribute13                =>  p_bng_attribute13
      ,p_bng_attribute14                =>  p_bng_attribute14
      ,p_bng_attribute15                =>  p_bng_attribute15
      ,p_bng_attribute16                =>  p_bng_attribute16
      ,p_bng_attribute17                =>  p_bng_attribute17
      ,p_bng_attribute18                =>  p_bng_attribute18
      ,p_bng_attribute19                =>  p_bng_attribute19
      ,p_bng_attribute20                =>  p_bng_attribute20
      ,p_bng_attribute21                =>  p_bng_attribute21
      ,p_bng_attribute22                =>  p_bng_attribute22
      ,p_bng_attribute23                =>  p_bng_attribute23
      ,p_bng_attribute24                =>  p_bng_attribute24
      ,p_bng_attribute25                =>  p_bng_attribute25
      ,p_bng_attribute26                =>  p_bng_attribute26
      ,p_bng_attribute27                =>  p_bng_attribute27
      ,p_bng_attribute28                =>  p_bng_attribute28
      ,p_bng_attribute29                =>  p_bng_attribute29
      ,p_bng_attribute30                =>  p_bng_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Benefits_Group'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Benefits_Group
    --
  end;
  --
  ben_bng_ins.ins
    (
     p_benfts_grp_id                 => l_benfts_grp_id
    ,p_business_group_id             => p_business_group_id
    ,p_name                          => p_name
    ,p_bng_desc                      => p_bng_desc
    ,p_bng_attribute_category        => p_bng_attribute_category
    ,p_bng_attribute1                => p_bng_attribute1
    ,p_bng_attribute2                => p_bng_attribute2
    ,p_bng_attribute3                => p_bng_attribute3
    ,p_bng_attribute4                => p_bng_attribute4
    ,p_bng_attribute5                => p_bng_attribute5
    ,p_bng_attribute6                => p_bng_attribute6
    ,p_bng_attribute7                => p_bng_attribute7
    ,p_bng_attribute8                => p_bng_attribute8
    ,p_bng_attribute9                => p_bng_attribute9
    ,p_bng_attribute10               => p_bng_attribute10
    ,p_bng_attribute11               => p_bng_attribute11
    ,p_bng_attribute12               => p_bng_attribute12
    ,p_bng_attribute13               => p_bng_attribute13
    ,p_bng_attribute14               => p_bng_attribute14
    ,p_bng_attribute15               => p_bng_attribute15
    ,p_bng_attribute16               => p_bng_attribute16
    ,p_bng_attribute17               => p_bng_attribute17
    ,p_bng_attribute18               => p_bng_attribute18
    ,p_bng_attribute19               => p_bng_attribute19
    ,p_bng_attribute20               => p_bng_attribute20
    ,p_bng_attribute21               => p_bng_attribute21
    ,p_bng_attribute22               => p_bng_attribute22
    ,p_bng_attribute23               => p_bng_attribute23
    ,p_bng_attribute24               => p_bng_attribute24
    ,p_bng_attribute25               => p_bng_attribute25
    ,p_bng_attribute26               => p_bng_attribute26
    ,p_bng_attribute27               => p_bng_attribute27
    ,p_bng_attribute28               => p_bng_attribute28
    ,p_bng_attribute29               => p_bng_attribute29
    ,p_bng_attribute30               => p_bng_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Benefits_Group
    --
    ben_Benefits_Group_bk1.create_Benefits_Group_a
      (
       p_benfts_grp_id                  =>  l_benfts_grp_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_name                           =>  p_name
      ,p_bng_desc                       =>  p_bng_desc
      ,p_bng_attribute_category         =>  p_bng_attribute_category
      ,p_bng_attribute1                 =>  p_bng_attribute1
      ,p_bng_attribute2                 =>  p_bng_attribute2
      ,p_bng_attribute3                 =>  p_bng_attribute3
      ,p_bng_attribute4                 =>  p_bng_attribute4
      ,p_bng_attribute5                 =>  p_bng_attribute5
      ,p_bng_attribute6                 =>  p_bng_attribute6
      ,p_bng_attribute7                 =>  p_bng_attribute7
      ,p_bng_attribute8                 =>  p_bng_attribute8
      ,p_bng_attribute9                 =>  p_bng_attribute9
      ,p_bng_attribute10                =>  p_bng_attribute10
      ,p_bng_attribute11                =>  p_bng_attribute11
      ,p_bng_attribute12                =>  p_bng_attribute12
      ,p_bng_attribute13                =>  p_bng_attribute13
      ,p_bng_attribute14                =>  p_bng_attribute14
      ,p_bng_attribute15                =>  p_bng_attribute15
      ,p_bng_attribute16                =>  p_bng_attribute16
      ,p_bng_attribute17                =>  p_bng_attribute17
      ,p_bng_attribute18                =>  p_bng_attribute18
      ,p_bng_attribute19                =>  p_bng_attribute19
      ,p_bng_attribute20                =>  p_bng_attribute20
      ,p_bng_attribute21                =>  p_bng_attribute21
      ,p_bng_attribute22                =>  p_bng_attribute22
      ,p_bng_attribute23                =>  p_bng_attribute23
      ,p_bng_attribute24                =>  p_bng_attribute24
      ,p_bng_attribute25                =>  p_bng_attribute25
      ,p_bng_attribute26                =>  p_bng_attribute26
      ,p_bng_attribute27                =>  p_bng_attribute27
      ,p_bng_attribute28                =>  p_bng_attribute28
      ,p_bng_attribute29                =>  p_bng_attribute29
      ,p_bng_attribute30                =>  p_bng_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Benefits_Group'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Benefits_Group
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
  p_benfts_grp_id := l_benfts_grp_id;
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
    ROLLBACK TO create_Benefits_Group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_benfts_grp_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Benefits_Group;
    p_benfts_grp_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_Benefits_Group;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Benefits_Group >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Benefits_Group
  (p_validate                       in  boolean   default false
  ,p_benfts_grp_id                  in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_bng_desc                       in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bng_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Benefits_Group';
  l_object_version_number ben_benfts_grp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Benefits_Group;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Benefits_Group
    --
    ben_Benefits_Group_bk2.update_Benefits_Group_b
      (
       p_benfts_grp_id                  =>  p_benfts_grp_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_name                           =>  p_name
      ,p_bng_desc                       =>  p_bng_desc
      ,p_bng_attribute_category         =>  p_bng_attribute_category
      ,p_bng_attribute1                 =>  p_bng_attribute1
      ,p_bng_attribute2                 =>  p_bng_attribute2
      ,p_bng_attribute3                 =>  p_bng_attribute3
      ,p_bng_attribute4                 =>  p_bng_attribute4
      ,p_bng_attribute5                 =>  p_bng_attribute5
      ,p_bng_attribute6                 =>  p_bng_attribute6
      ,p_bng_attribute7                 =>  p_bng_attribute7
      ,p_bng_attribute8                 =>  p_bng_attribute8
      ,p_bng_attribute9                 =>  p_bng_attribute9
      ,p_bng_attribute10                =>  p_bng_attribute10
      ,p_bng_attribute11                =>  p_bng_attribute11
      ,p_bng_attribute12                =>  p_bng_attribute12
      ,p_bng_attribute13                =>  p_bng_attribute13
      ,p_bng_attribute14                =>  p_bng_attribute14
      ,p_bng_attribute15                =>  p_bng_attribute15
      ,p_bng_attribute16                =>  p_bng_attribute16
      ,p_bng_attribute17                =>  p_bng_attribute17
      ,p_bng_attribute18                =>  p_bng_attribute18
      ,p_bng_attribute19                =>  p_bng_attribute19
      ,p_bng_attribute20                =>  p_bng_attribute20
      ,p_bng_attribute21                =>  p_bng_attribute21
      ,p_bng_attribute22                =>  p_bng_attribute22
      ,p_bng_attribute23                =>  p_bng_attribute23
      ,p_bng_attribute24                =>  p_bng_attribute24
      ,p_bng_attribute25                =>  p_bng_attribute25
      ,p_bng_attribute26                =>  p_bng_attribute26
      ,p_bng_attribute27                =>  p_bng_attribute27
      ,p_bng_attribute28                =>  p_bng_attribute28
      ,p_bng_attribute29                =>  p_bng_attribute29
      ,p_bng_attribute30                =>  p_bng_attribute30
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Benefits_Group'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Benefits_Group
    --
  end;
  --
  ben_bng_upd.upd
    (
     p_benfts_grp_id                 => p_benfts_grp_id
    ,p_business_group_id             => p_business_group_id
    ,p_name                          => p_name
    ,p_bng_desc                      => p_bng_desc
    ,p_bng_attribute_category        => p_bng_attribute_category
    ,p_bng_attribute1                => p_bng_attribute1
    ,p_bng_attribute2                => p_bng_attribute2
    ,p_bng_attribute3                => p_bng_attribute3
    ,p_bng_attribute4                => p_bng_attribute4
    ,p_bng_attribute5                => p_bng_attribute5
    ,p_bng_attribute6                => p_bng_attribute6
    ,p_bng_attribute7                => p_bng_attribute7
    ,p_bng_attribute8                => p_bng_attribute8
    ,p_bng_attribute9                => p_bng_attribute9
    ,p_bng_attribute10               => p_bng_attribute10
    ,p_bng_attribute11               => p_bng_attribute11
    ,p_bng_attribute12               => p_bng_attribute12
    ,p_bng_attribute13               => p_bng_attribute13
    ,p_bng_attribute14               => p_bng_attribute14
    ,p_bng_attribute15               => p_bng_attribute15
    ,p_bng_attribute16               => p_bng_attribute16
    ,p_bng_attribute17               => p_bng_attribute17
    ,p_bng_attribute18               => p_bng_attribute18
    ,p_bng_attribute19               => p_bng_attribute19
    ,p_bng_attribute20               => p_bng_attribute20
    ,p_bng_attribute21               => p_bng_attribute21
    ,p_bng_attribute22               => p_bng_attribute22
    ,p_bng_attribute23               => p_bng_attribute23
    ,p_bng_attribute24               => p_bng_attribute24
    ,p_bng_attribute25               => p_bng_attribute25
    ,p_bng_attribute26               => p_bng_attribute26
    ,p_bng_attribute27               => p_bng_attribute27
    ,p_bng_attribute28               => p_bng_attribute28
    ,p_bng_attribute29               => p_bng_attribute29
    ,p_bng_attribute30               => p_bng_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Benefits_Group
    --
    ben_Benefits_Group_bk2.update_Benefits_Group_a
      (
       p_benfts_grp_id                  =>  p_benfts_grp_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_name                           =>  p_name
      ,p_bng_desc                       =>  p_bng_desc
      ,p_bng_attribute_category         =>  p_bng_attribute_category
      ,p_bng_attribute1                 =>  p_bng_attribute1
      ,p_bng_attribute2                 =>  p_bng_attribute2
      ,p_bng_attribute3                 =>  p_bng_attribute3
      ,p_bng_attribute4                 =>  p_bng_attribute4
      ,p_bng_attribute5                 =>  p_bng_attribute5
      ,p_bng_attribute6                 =>  p_bng_attribute6
      ,p_bng_attribute7                 =>  p_bng_attribute7
      ,p_bng_attribute8                 =>  p_bng_attribute8
      ,p_bng_attribute9                 =>  p_bng_attribute9
      ,p_bng_attribute10                =>  p_bng_attribute10
      ,p_bng_attribute11                =>  p_bng_attribute11
      ,p_bng_attribute12                =>  p_bng_attribute12
      ,p_bng_attribute13                =>  p_bng_attribute13
      ,p_bng_attribute14                =>  p_bng_attribute14
      ,p_bng_attribute15                =>  p_bng_attribute15
      ,p_bng_attribute16                =>  p_bng_attribute16
      ,p_bng_attribute17                =>  p_bng_attribute17
      ,p_bng_attribute18                =>  p_bng_attribute18
      ,p_bng_attribute19                =>  p_bng_attribute19
      ,p_bng_attribute20                =>  p_bng_attribute20
      ,p_bng_attribute21                =>  p_bng_attribute21
      ,p_bng_attribute22                =>  p_bng_attribute22
      ,p_bng_attribute23                =>  p_bng_attribute23
      ,p_bng_attribute24                =>  p_bng_attribute24
      ,p_bng_attribute25                =>  p_bng_attribute25
      ,p_bng_attribute26                =>  p_bng_attribute26
      ,p_bng_attribute27                =>  p_bng_attribute27
      ,p_bng_attribute28                =>  p_bng_attribute28
      ,p_bng_attribute29                =>  p_bng_attribute29
      ,p_bng_attribute30                =>  p_bng_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Benefits_Group'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Benefits_Group
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
    ROLLBACK TO update_Benefits_Group;
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
    ROLLBACK TO update_Benefits_Group;
    raise;
    --
end update_Benefits_Group;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Benefits_Group >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefits_Group
  (p_validate                       in  boolean  default false
  ,p_benfts_grp_id                  in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Benefits_Group';
  l_object_version_number ben_benfts_grp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Benefits_Group;
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
    -- Start of API User Hook for the before hook of delete_Benefits_Group
    --
    ben_Benefits_Group_bk3.delete_Benefits_Group_b
      (
       p_benfts_grp_id                  =>  p_benfts_grp_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Benefits_Group'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Benefits_Group
    --
  end;
  --
  ben_bng_del.del
    (
     p_benfts_grp_id                 => p_benfts_grp_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Benefits_Group
    --
    ben_Benefits_Group_bk3.delete_Benefits_Group_a
      (
       p_benfts_grp_id                  =>  p_benfts_grp_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Benefits_Group'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Benefits_Group
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
    ROLLBACK TO delete_Benefits_Group;
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
    ROLLBACK TO delete_Benefits_Group;
    raise;
    --
end delete_Benefits_Group;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_benfts_grp_id                   in     number
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
  ben_bng_shd.lck
    (
      p_benfts_grp_id                 => p_benfts_grp_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Benefits_Group_api;

/
