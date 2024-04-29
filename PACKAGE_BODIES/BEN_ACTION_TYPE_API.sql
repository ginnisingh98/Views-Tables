--------------------------------------------------------
--  DDL for Package Body BEN_ACTION_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ACTION_TYPE_API" as
/* $Header: beeatapi.pkb 115.4 2002/12/16 09:36:22 hnarayan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ACTION_TYPE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ACTION_TYPE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ACTION_TYPE
  (p_validate                       in  boolean   default false
  ,p_actn_typ_id                    out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_type_cd                        in  varchar2  default null
  ,p_name                           in  varchar2  default null
  ,p_description                    in  varchar2  default null
  ,p_eat_attribute_category         in  varchar2  default null
  ,p_eat_attribute1                 in  varchar2  default null
  ,p_eat_attribute2                 in  varchar2  default null
  ,p_eat_attribute3                 in  varchar2  default null
  ,p_eat_attribute4                 in  varchar2  default null
  ,p_eat_attribute5                 in  varchar2  default null
  ,p_eat_attribute6                 in  varchar2  default null
  ,p_eat_attribute7                 in  varchar2  default null
  ,p_eat_attribute8                 in  varchar2  default null
  ,p_eat_attribute9                 in  varchar2  default null
  ,p_eat_attribute10                in  varchar2  default null
  ,p_eat_attribute11                in  varchar2  default null
  ,p_eat_attribute12                in  varchar2  default null
  ,p_eat_attribute13                in  varchar2  default null
  ,p_eat_attribute14                in  varchar2  default null
  ,p_eat_attribute15                in  varchar2  default null
  ,p_eat_attribute16                in  varchar2  default null
  ,p_eat_attribute17                in  varchar2  default null
  ,p_eat_attribute18                in  varchar2  default null
  ,p_eat_attribute19                in  varchar2  default null
  ,p_eat_attribute20                in  varchar2  default null
  ,p_eat_attribute21                in  varchar2  default null
  ,p_eat_attribute22                in  varchar2  default null
  ,p_eat_attribute23                in  varchar2  default null
  ,p_eat_attribute24                in  varchar2  default null
  ,p_eat_attribute25                in  varchar2  default null
  ,p_eat_attribute26                in  varchar2  default null
  ,p_eat_attribute27                in  varchar2  default null
  ,p_eat_attribute28                in  varchar2  default null
  ,p_eat_attribute29                in  varchar2  default null
  ,p_eat_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_actn_typ_id ben_actn_typ.actn_typ_id%TYPE;
  l_proc varchar2(72) := g_package||'create_ACTION_TYPE';
  l_object_version_number ben_actn_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ACTION_TYPE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ACTION_TYPE
    --
    ben_ACTION_TYPE_bk1.create_ACTION_TYPE_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_type_cd                        =>  p_type_cd
      ,p_name                           =>  p_name
      ,p_description                    =>  p_description
      ,p_eat_attribute_category         =>  p_eat_attribute_category
      ,p_eat_attribute1                 =>  p_eat_attribute1
      ,p_eat_attribute2                 =>  p_eat_attribute2
      ,p_eat_attribute3                 =>  p_eat_attribute3
      ,p_eat_attribute4                 =>  p_eat_attribute4
      ,p_eat_attribute5                 =>  p_eat_attribute5
      ,p_eat_attribute6                 =>  p_eat_attribute6
      ,p_eat_attribute7                 =>  p_eat_attribute7
      ,p_eat_attribute8                 =>  p_eat_attribute8
      ,p_eat_attribute9                 =>  p_eat_attribute9
      ,p_eat_attribute10                =>  p_eat_attribute10
      ,p_eat_attribute11                =>  p_eat_attribute11
      ,p_eat_attribute12                =>  p_eat_attribute12
      ,p_eat_attribute13                =>  p_eat_attribute13
      ,p_eat_attribute14                =>  p_eat_attribute14
      ,p_eat_attribute15                =>  p_eat_attribute15
      ,p_eat_attribute16                =>  p_eat_attribute16
      ,p_eat_attribute17                =>  p_eat_attribute17
      ,p_eat_attribute18                =>  p_eat_attribute18
      ,p_eat_attribute19                =>  p_eat_attribute19
      ,p_eat_attribute20                =>  p_eat_attribute20
      ,p_eat_attribute21                =>  p_eat_attribute21
      ,p_eat_attribute22                =>  p_eat_attribute22
      ,p_eat_attribute23                =>  p_eat_attribute23
      ,p_eat_attribute24                =>  p_eat_attribute24
      ,p_eat_attribute25                =>  p_eat_attribute25
      ,p_eat_attribute26                =>  p_eat_attribute26
      ,p_eat_attribute27                =>  p_eat_attribute27
      ,p_eat_attribute28                =>  p_eat_attribute28
      ,p_eat_attribute29                =>  p_eat_attribute29
      ,p_eat_attribute30                =>  p_eat_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ACTION_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ACTION_TYPE
    --
  end;
  --
  ben_eat_ins.ins
    (
     p_actn_typ_id                   => l_actn_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_type_cd                       => p_type_cd
    ,p_name                          => p_name
    ,p_description                   => p_description
    ,p_eat_attribute_category        => p_eat_attribute_category
    ,p_eat_attribute1                => p_eat_attribute1
    ,p_eat_attribute2                => p_eat_attribute2
    ,p_eat_attribute3                => p_eat_attribute3
    ,p_eat_attribute4                => p_eat_attribute4
    ,p_eat_attribute5                => p_eat_attribute5
    ,p_eat_attribute6                => p_eat_attribute6
    ,p_eat_attribute7                => p_eat_attribute7
    ,p_eat_attribute8                => p_eat_attribute8
    ,p_eat_attribute9                => p_eat_attribute9
    ,p_eat_attribute10               => p_eat_attribute10
    ,p_eat_attribute11               => p_eat_attribute11
    ,p_eat_attribute12               => p_eat_attribute12
    ,p_eat_attribute13               => p_eat_attribute13
    ,p_eat_attribute14               => p_eat_attribute14
    ,p_eat_attribute15               => p_eat_attribute15
    ,p_eat_attribute16               => p_eat_attribute16
    ,p_eat_attribute17               => p_eat_attribute17
    ,p_eat_attribute18               => p_eat_attribute18
    ,p_eat_attribute19               => p_eat_attribute19
    ,p_eat_attribute20               => p_eat_attribute20
    ,p_eat_attribute21               => p_eat_attribute21
    ,p_eat_attribute22               => p_eat_attribute22
    ,p_eat_attribute23               => p_eat_attribute23
    ,p_eat_attribute24               => p_eat_attribute24
    ,p_eat_attribute25               => p_eat_attribute25
    ,p_eat_attribute26               => p_eat_attribute26
    ,p_eat_attribute27               => p_eat_attribute27
    ,p_eat_attribute28               => p_eat_attribute28
    ,p_eat_attribute29               => p_eat_attribute29
    ,p_eat_attribute30               => p_eat_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ACTION_TYPE
    --
    ben_ACTION_TYPE_bk1.create_ACTION_TYPE_a
      (
       p_actn_typ_id                    =>  l_actn_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_type_cd                        =>  p_type_cd
      ,p_name                           =>  p_name
      ,p_description                    =>  p_description
      ,p_eat_attribute_category         =>  p_eat_attribute_category
      ,p_eat_attribute1                 =>  p_eat_attribute1
      ,p_eat_attribute2                 =>  p_eat_attribute2
      ,p_eat_attribute3                 =>  p_eat_attribute3
      ,p_eat_attribute4                 =>  p_eat_attribute4
      ,p_eat_attribute5                 =>  p_eat_attribute5
      ,p_eat_attribute6                 =>  p_eat_attribute6
      ,p_eat_attribute7                 =>  p_eat_attribute7
      ,p_eat_attribute8                 =>  p_eat_attribute8
      ,p_eat_attribute9                 =>  p_eat_attribute9
      ,p_eat_attribute10                =>  p_eat_attribute10
      ,p_eat_attribute11                =>  p_eat_attribute11
      ,p_eat_attribute12                =>  p_eat_attribute12
      ,p_eat_attribute13                =>  p_eat_attribute13
      ,p_eat_attribute14                =>  p_eat_attribute14
      ,p_eat_attribute15                =>  p_eat_attribute15
      ,p_eat_attribute16                =>  p_eat_attribute16
      ,p_eat_attribute17                =>  p_eat_attribute17
      ,p_eat_attribute18                =>  p_eat_attribute18
      ,p_eat_attribute19                =>  p_eat_attribute19
      ,p_eat_attribute20                =>  p_eat_attribute20
      ,p_eat_attribute21                =>  p_eat_attribute21
      ,p_eat_attribute22                =>  p_eat_attribute22
      ,p_eat_attribute23                =>  p_eat_attribute23
      ,p_eat_attribute24                =>  p_eat_attribute24
      ,p_eat_attribute25                =>  p_eat_attribute25
      ,p_eat_attribute26                =>  p_eat_attribute26
      ,p_eat_attribute27                =>  p_eat_attribute27
      ,p_eat_attribute28                =>  p_eat_attribute28
      ,p_eat_attribute29                =>  p_eat_attribute29
      ,p_eat_attribute30                =>  p_eat_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ACTION_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ACTION_TYPE
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
  p_actn_typ_id := l_actn_typ_id;
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
    ROLLBACK TO create_ACTION_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_actn_typ_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ACTION_TYPE;
    p_actn_typ_id := null;
    p_object_version_number  := null;
raise;
    --
end create_ACTION_TYPE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ACTION_TYPE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ACTION_TYPE
  (p_validate                       in  boolean   default false
  ,p_actn_typ_id                    in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_type_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_eat_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ACTION_TYPE';
  l_object_version_number ben_actn_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ACTION_TYPE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ACTION_TYPE
    --
    ben_ACTION_TYPE_bk2.update_ACTION_TYPE_b
      (
       p_actn_typ_id                    =>  p_actn_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_type_cd                        =>  p_type_cd
      ,p_name                           =>  p_name
      ,p_description                    =>  p_description
      ,p_eat_attribute_category         =>  p_eat_attribute_category
      ,p_eat_attribute1                 =>  p_eat_attribute1
      ,p_eat_attribute2                 =>  p_eat_attribute2
      ,p_eat_attribute3                 =>  p_eat_attribute3
      ,p_eat_attribute4                 =>  p_eat_attribute4
      ,p_eat_attribute5                 =>  p_eat_attribute5
      ,p_eat_attribute6                 =>  p_eat_attribute6
      ,p_eat_attribute7                 =>  p_eat_attribute7
      ,p_eat_attribute8                 =>  p_eat_attribute8
      ,p_eat_attribute9                 =>  p_eat_attribute9
      ,p_eat_attribute10                =>  p_eat_attribute10
      ,p_eat_attribute11                =>  p_eat_attribute11
      ,p_eat_attribute12                =>  p_eat_attribute12
      ,p_eat_attribute13                =>  p_eat_attribute13
      ,p_eat_attribute14                =>  p_eat_attribute14
      ,p_eat_attribute15                =>  p_eat_attribute15
      ,p_eat_attribute16                =>  p_eat_attribute16
      ,p_eat_attribute17                =>  p_eat_attribute17
      ,p_eat_attribute18                =>  p_eat_attribute18
      ,p_eat_attribute19                =>  p_eat_attribute19
      ,p_eat_attribute20                =>  p_eat_attribute20
      ,p_eat_attribute21                =>  p_eat_attribute21
      ,p_eat_attribute22                =>  p_eat_attribute22
      ,p_eat_attribute23                =>  p_eat_attribute23
      ,p_eat_attribute24                =>  p_eat_attribute24
      ,p_eat_attribute25                =>  p_eat_attribute25
      ,p_eat_attribute26                =>  p_eat_attribute26
      ,p_eat_attribute27                =>  p_eat_attribute27
      ,p_eat_attribute28                =>  p_eat_attribute28
      ,p_eat_attribute29                =>  p_eat_attribute29
      ,p_eat_attribute30                =>  p_eat_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ACTION_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ACTION_TYPE
    --
  end;
  --
  ben_eat_upd.upd
    (
     p_actn_typ_id                   => p_actn_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_type_cd                       => p_type_cd
    ,p_name                          => p_name
    ,p_description                   => p_description
    ,p_eat_attribute_category        => p_eat_attribute_category
    ,p_eat_attribute1                => p_eat_attribute1
    ,p_eat_attribute2                => p_eat_attribute2
    ,p_eat_attribute3                => p_eat_attribute3
    ,p_eat_attribute4                => p_eat_attribute4
    ,p_eat_attribute5                => p_eat_attribute5
    ,p_eat_attribute6                => p_eat_attribute6
    ,p_eat_attribute7                => p_eat_attribute7
    ,p_eat_attribute8                => p_eat_attribute8
    ,p_eat_attribute9                => p_eat_attribute9
    ,p_eat_attribute10               => p_eat_attribute10
    ,p_eat_attribute11               => p_eat_attribute11
    ,p_eat_attribute12               => p_eat_attribute12
    ,p_eat_attribute13               => p_eat_attribute13
    ,p_eat_attribute14               => p_eat_attribute14
    ,p_eat_attribute15               => p_eat_attribute15
    ,p_eat_attribute16               => p_eat_attribute16
    ,p_eat_attribute17               => p_eat_attribute17
    ,p_eat_attribute18               => p_eat_attribute18
    ,p_eat_attribute19               => p_eat_attribute19
    ,p_eat_attribute20               => p_eat_attribute20
    ,p_eat_attribute21               => p_eat_attribute21
    ,p_eat_attribute22               => p_eat_attribute22
    ,p_eat_attribute23               => p_eat_attribute23
    ,p_eat_attribute24               => p_eat_attribute24
    ,p_eat_attribute25               => p_eat_attribute25
    ,p_eat_attribute26               => p_eat_attribute26
    ,p_eat_attribute27               => p_eat_attribute27
    ,p_eat_attribute28               => p_eat_attribute28
    ,p_eat_attribute29               => p_eat_attribute29
    ,p_eat_attribute30               => p_eat_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ACTION_TYPE
    --
    ben_ACTION_TYPE_bk2.update_ACTION_TYPE_a
      (
       p_actn_typ_id                    =>  p_actn_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_type_cd                        =>  p_type_cd
      ,p_name                           =>  p_name
      ,p_description                    =>  p_description
      ,p_eat_attribute_category         =>  p_eat_attribute_category
      ,p_eat_attribute1                 =>  p_eat_attribute1
      ,p_eat_attribute2                 =>  p_eat_attribute2
      ,p_eat_attribute3                 =>  p_eat_attribute3
      ,p_eat_attribute4                 =>  p_eat_attribute4
      ,p_eat_attribute5                 =>  p_eat_attribute5
      ,p_eat_attribute6                 =>  p_eat_attribute6
      ,p_eat_attribute7                 =>  p_eat_attribute7
      ,p_eat_attribute8                 =>  p_eat_attribute8
      ,p_eat_attribute9                 =>  p_eat_attribute9
      ,p_eat_attribute10                =>  p_eat_attribute10
      ,p_eat_attribute11                =>  p_eat_attribute11
      ,p_eat_attribute12                =>  p_eat_attribute12
      ,p_eat_attribute13                =>  p_eat_attribute13
      ,p_eat_attribute14                =>  p_eat_attribute14
      ,p_eat_attribute15                =>  p_eat_attribute15
      ,p_eat_attribute16                =>  p_eat_attribute16
      ,p_eat_attribute17                =>  p_eat_attribute17
      ,p_eat_attribute18                =>  p_eat_attribute18
      ,p_eat_attribute19                =>  p_eat_attribute19
      ,p_eat_attribute20                =>  p_eat_attribute20
      ,p_eat_attribute21                =>  p_eat_attribute21
      ,p_eat_attribute22                =>  p_eat_attribute22
      ,p_eat_attribute23                =>  p_eat_attribute23
      ,p_eat_attribute24                =>  p_eat_attribute24
      ,p_eat_attribute25                =>  p_eat_attribute25
      ,p_eat_attribute26                =>  p_eat_attribute26
      ,p_eat_attribute27                =>  p_eat_attribute27
      ,p_eat_attribute28                =>  p_eat_attribute28
      ,p_eat_attribute29                =>  p_eat_attribute29
      ,p_eat_attribute30                =>  p_eat_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ACTION_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ACTION_TYPE
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
    ROLLBACK TO update_ACTION_TYPE;
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
    ROLLBACK TO update_ACTION_TYPE;
    raise;
    --
end update_ACTION_TYPE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ACTION_TYPE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ACTION_TYPE
  (p_validate                       in  boolean  default false
  ,p_actn_typ_id                    in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ACTION_TYPE';
  l_object_version_number ben_actn_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ACTION_TYPE;
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
    -- Start of API User Hook for the before hook of delete_ACTION_TYPE
    --
    ben_ACTION_TYPE_bk3.delete_ACTION_TYPE_b
      (
       p_actn_typ_id                    =>  p_actn_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ACTION_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ACTION_TYPE
    --
  end;
  --
  ben_eat_del.del
    (
     p_actn_typ_id                   => p_actn_typ_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ACTION_TYPE
    --
    ben_ACTION_TYPE_bk3.delete_ACTION_TYPE_a
      (
       p_actn_typ_id                    =>  p_actn_typ_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ACTION_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ACTION_TYPE
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
    ROLLBACK TO delete_ACTION_TYPE;
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
    ROLLBACK TO delete_ACTION_TYPE;
    raise;
    --
end delete_ACTION_TYPE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_actn_typ_id                   in     number
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
  ben_eat_shd.lck
    (
      p_actn_typ_id                 => p_actn_typ_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_ACTION_TYPE_api;

/
