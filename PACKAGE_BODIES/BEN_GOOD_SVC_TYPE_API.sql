--------------------------------------------------------
--  DDL for Package Body BEN_GOOD_SVC_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GOOD_SVC_TYPE_API" as
/* $Header: begosapi.pkb 120.0 2005/05/28 03:08:01 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_GOOD_SVC_TYPE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_GOOD_SVC_TYPE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_GOOD_SVC_TYPE
  (p_validate                       in  boolean   default false
  ,p_gd_or_svc_typ_id               out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_typ_cd                         in  varchar2  default null
  ,p_description                    in  varchar2  default null
  ,p_gos_attribute_category         in  varchar2  default null
  ,p_gos_attribute1                 in  varchar2  default null
  ,p_gos_attribute2                 in  varchar2  default null
  ,p_gos_attribute3                 in  varchar2  default null
  ,p_gos_attribute4                 in  varchar2  default null
  ,p_gos_attribute5                 in  varchar2  default null
  ,p_gos_attribute6                 in  varchar2  default null
  ,p_gos_attribute7                 in  varchar2  default null
  ,p_gos_attribute8                 in  varchar2  default null
  ,p_gos_attribute9                 in  varchar2  default null
  ,p_gos_attribute10                in  varchar2  default null
  ,p_gos_attribute11                in  varchar2  default null
  ,p_gos_attribute12                in  varchar2  default null
  ,p_gos_attribute13                in  varchar2  default null
  ,p_gos_attribute14                in  varchar2  default null
  ,p_gos_attribute15                in  varchar2  default null
  ,p_gos_attribute16                in  varchar2  default null
  ,p_gos_attribute17                in  varchar2  default null
  ,p_gos_attribute18                in  varchar2  default null
  ,p_gos_attribute19                in  varchar2  default null
  ,p_gos_attribute20                in  varchar2  default null
  ,p_gos_attribute21                in  varchar2  default null
  ,p_gos_attribute22                in  varchar2  default null
  ,p_gos_attribute23                in  varchar2  default null
  ,p_gos_attribute24                in  varchar2  default null
  ,p_gos_attribute25                in  varchar2  default null
  ,p_gos_attribute26                in  varchar2  default null
  ,p_gos_attribute27                in  varchar2  default null
  ,p_gos_attribute28                in  varchar2  default null
  ,p_gos_attribute29                in  varchar2  default null
  ,p_gos_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_gd_or_svc_typ_id ben_gd_or_svc_typ.gd_or_svc_typ_id%TYPE;
  l_proc varchar2(72) := g_package||'create_GOOD_SVC_TYPE';
  l_object_version_number ben_gd_or_svc_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_GOOD_SVC_TYPE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_GOOD_SVC_TYPE
    --
    ben_GOOD_SVC_TYPE_bk1.create_GOOD_SVC_TYPE_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_name                           =>  p_name
      ,p_typ_cd                         =>  p_typ_cd
      ,p_description                    =>  p_description
      ,p_gos_attribute_category         =>  p_gos_attribute_category
      ,p_gos_attribute1                 =>  p_gos_attribute1
      ,p_gos_attribute2                 =>  p_gos_attribute2
      ,p_gos_attribute3                 =>  p_gos_attribute3
      ,p_gos_attribute4                 =>  p_gos_attribute4
      ,p_gos_attribute5                 =>  p_gos_attribute5
      ,p_gos_attribute6                 =>  p_gos_attribute6
      ,p_gos_attribute7                 =>  p_gos_attribute7
      ,p_gos_attribute8                 =>  p_gos_attribute8
      ,p_gos_attribute9                 =>  p_gos_attribute9
      ,p_gos_attribute10                =>  p_gos_attribute10
      ,p_gos_attribute11                =>  p_gos_attribute11
      ,p_gos_attribute12                =>  p_gos_attribute12
      ,p_gos_attribute13                =>  p_gos_attribute13
      ,p_gos_attribute14                =>  p_gos_attribute14
      ,p_gos_attribute15                =>  p_gos_attribute15
      ,p_gos_attribute16                =>  p_gos_attribute16
      ,p_gos_attribute17                =>  p_gos_attribute17
      ,p_gos_attribute18                =>  p_gos_attribute18
      ,p_gos_attribute19                =>  p_gos_attribute19
      ,p_gos_attribute20                =>  p_gos_attribute20
      ,p_gos_attribute21                =>  p_gos_attribute21
      ,p_gos_attribute22                =>  p_gos_attribute22
      ,p_gos_attribute23                =>  p_gos_attribute23
      ,p_gos_attribute24                =>  p_gos_attribute24
      ,p_gos_attribute25                =>  p_gos_attribute25
      ,p_gos_attribute26                =>  p_gos_attribute26
      ,p_gos_attribute27                =>  p_gos_attribute27
      ,p_gos_attribute28                =>  p_gos_attribute28
      ,p_gos_attribute29                =>  p_gos_attribute29
      ,p_gos_attribute30                =>  p_gos_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_GOOD_SVC_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_GOOD_SVC_TYPE
    --
  end;
  --
  ben_gos_ins.ins
    (
     p_gd_or_svc_typ_id              => l_gd_or_svc_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_name                          => p_name
    ,p_typ_cd                        => p_typ_cd
    ,p_description                   => p_description
    ,p_gos_attribute_category        => p_gos_attribute_category
    ,p_gos_attribute1                => p_gos_attribute1
    ,p_gos_attribute2                => p_gos_attribute2
    ,p_gos_attribute3                => p_gos_attribute3
    ,p_gos_attribute4                => p_gos_attribute4
    ,p_gos_attribute5                => p_gos_attribute5
    ,p_gos_attribute6                => p_gos_attribute6
    ,p_gos_attribute7                => p_gos_attribute7
    ,p_gos_attribute8                => p_gos_attribute8
    ,p_gos_attribute9                => p_gos_attribute9
    ,p_gos_attribute10               => p_gos_attribute10
    ,p_gos_attribute11               => p_gos_attribute11
    ,p_gos_attribute12               => p_gos_attribute12
    ,p_gos_attribute13               => p_gos_attribute13
    ,p_gos_attribute14               => p_gos_attribute14
    ,p_gos_attribute15               => p_gos_attribute15
    ,p_gos_attribute16               => p_gos_attribute16
    ,p_gos_attribute17               => p_gos_attribute17
    ,p_gos_attribute18               => p_gos_attribute18
    ,p_gos_attribute19               => p_gos_attribute19
    ,p_gos_attribute20               => p_gos_attribute20
    ,p_gos_attribute21               => p_gos_attribute21
    ,p_gos_attribute22               => p_gos_attribute22
    ,p_gos_attribute23               => p_gos_attribute23
    ,p_gos_attribute24               => p_gos_attribute24
    ,p_gos_attribute25               => p_gos_attribute25
    ,p_gos_attribute26               => p_gos_attribute26
    ,p_gos_attribute27               => p_gos_attribute27
    ,p_gos_attribute28               => p_gos_attribute28
    ,p_gos_attribute29               => p_gos_attribute29
    ,p_gos_attribute30               => p_gos_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_GOOD_SVC_TYPE
    --
    ben_GOOD_SVC_TYPE_bk1.create_GOOD_SVC_TYPE_a
      (
       p_gd_or_svc_typ_id               =>  l_gd_or_svc_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_name                           =>  p_name
      ,p_typ_cd                         =>  p_typ_cd
      ,p_description                    =>  p_description
      ,p_gos_attribute_category         =>  p_gos_attribute_category
      ,p_gos_attribute1                 =>  p_gos_attribute1
      ,p_gos_attribute2                 =>  p_gos_attribute2
      ,p_gos_attribute3                 =>  p_gos_attribute3
      ,p_gos_attribute4                 =>  p_gos_attribute4
      ,p_gos_attribute5                 =>  p_gos_attribute5
      ,p_gos_attribute6                 =>  p_gos_attribute6
      ,p_gos_attribute7                 =>  p_gos_attribute7
      ,p_gos_attribute8                 =>  p_gos_attribute8
      ,p_gos_attribute9                 =>  p_gos_attribute9
      ,p_gos_attribute10                =>  p_gos_attribute10
      ,p_gos_attribute11                =>  p_gos_attribute11
      ,p_gos_attribute12                =>  p_gos_attribute12
      ,p_gos_attribute13                =>  p_gos_attribute13
      ,p_gos_attribute14                =>  p_gos_attribute14
      ,p_gos_attribute15                =>  p_gos_attribute15
      ,p_gos_attribute16                =>  p_gos_attribute16
      ,p_gos_attribute17                =>  p_gos_attribute17
      ,p_gos_attribute18                =>  p_gos_attribute18
      ,p_gos_attribute19                =>  p_gos_attribute19
      ,p_gos_attribute20                =>  p_gos_attribute20
      ,p_gos_attribute21                =>  p_gos_attribute21
      ,p_gos_attribute22                =>  p_gos_attribute22
      ,p_gos_attribute23                =>  p_gos_attribute23
      ,p_gos_attribute24                =>  p_gos_attribute24
      ,p_gos_attribute25                =>  p_gos_attribute25
      ,p_gos_attribute26                =>  p_gos_attribute26
      ,p_gos_attribute27                =>  p_gos_attribute27
      ,p_gos_attribute28                =>  p_gos_attribute28
      ,p_gos_attribute29                =>  p_gos_attribute29
      ,p_gos_attribute30                =>  p_gos_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GOOD_SVC_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_GOOD_SVC_TYPE
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
  p_gd_or_svc_typ_id := l_gd_or_svc_typ_id;
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
    ROLLBACK TO create_GOOD_SVC_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_gd_or_svc_typ_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_GOOD_SVC_TYPE;
    raise;
    --
end create_GOOD_SVC_TYPE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_GOOD_SVC_TYPE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_GOOD_SVC_TYPE
  (p_validate                       in  boolean   default false
  ,p_gd_or_svc_typ_id               in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_typ_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_gos_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_GOOD_SVC_TYPE';
  l_object_version_number ben_gd_or_svc_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_GOOD_SVC_TYPE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_GOOD_SVC_TYPE
    --
    ben_GOOD_SVC_TYPE_bk2.update_GOOD_SVC_TYPE_b
      (
       p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_name                           =>  p_name
      ,p_typ_cd                         =>  p_typ_cd
      ,p_description                    =>  p_description
      ,p_gos_attribute_category         =>  p_gos_attribute_category
      ,p_gos_attribute1                 =>  p_gos_attribute1
      ,p_gos_attribute2                 =>  p_gos_attribute2
      ,p_gos_attribute3                 =>  p_gos_attribute3
      ,p_gos_attribute4                 =>  p_gos_attribute4
      ,p_gos_attribute5                 =>  p_gos_attribute5
      ,p_gos_attribute6                 =>  p_gos_attribute6
      ,p_gos_attribute7                 =>  p_gos_attribute7
      ,p_gos_attribute8                 =>  p_gos_attribute8
      ,p_gos_attribute9                 =>  p_gos_attribute9
      ,p_gos_attribute10                =>  p_gos_attribute10
      ,p_gos_attribute11                =>  p_gos_attribute11
      ,p_gos_attribute12                =>  p_gos_attribute12
      ,p_gos_attribute13                =>  p_gos_attribute13
      ,p_gos_attribute14                =>  p_gos_attribute14
      ,p_gos_attribute15                =>  p_gos_attribute15
      ,p_gos_attribute16                =>  p_gos_attribute16
      ,p_gos_attribute17                =>  p_gos_attribute17
      ,p_gos_attribute18                =>  p_gos_attribute18
      ,p_gos_attribute19                =>  p_gos_attribute19
      ,p_gos_attribute20                =>  p_gos_attribute20
      ,p_gos_attribute21                =>  p_gos_attribute21
      ,p_gos_attribute22                =>  p_gos_attribute22
      ,p_gos_attribute23                =>  p_gos_attribute23
      ,p_gos_attribute24                =>  p_gos_attribute24
      ,p_gos_attribute25                =>  p_gos_attribute25
      ,p_gos_attribute26                =>  p_gos_attribute26
      ,p_gos_attribute27                =>  p_gos_attribute27
      ,p_gos_attribute28                =>  p_gos_attribute28
      ,p_gos_attribute29                =>  p_gos_attribute29
      ,p_gos_attribute30                =>  p_gos_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GOOD_SVC_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_GOOD_SVC_TYPE
    --
  end;
  --
  ben_gos_upd.upd
    (
     p_gd_or_svc_typ_id              => p_gd_or_svc_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_name                          => p_name
    ,p_typ_cd                        => p_typ_cd
    ,p_description                   => p_description
    ,p_gos_attribute_category        => p_gos_attribute_category
    ,p_gos_attribute1                => p_gos_attribute1
    ,p_gos_attribute2                => p_gos_attribute2
    ,p_gos_attribute3                => p_gos_attribute3
    ,p_gos_attribute4                => p_gos_attribute4
    ,p_gos_attribute5                => p_gos_attribute5
    ,p_gos_attribute6                => p_gos_attribute6
    ,p_gos_attribute7                => p_gos_attribute7
    ,p_gos_attribute8                => p_gos_attribute8
    ,p_gos_attribute9                => p_gos_attribute9
    ,p_gos_attribute10               => p_gos_attribute10
    ,p_gos_attribute11               => p_gos_attribute11
    ,p_gos_attribute12               => p_gos_attribute12
    ,p_gos_attribute13               => p_gos_attribute13
    ,p_gos_attribute14               => p_gos_attribute14
    ,p_gos_attribute15               => p_gos_attribute15
    ,p_gos_attribute16               => p_gos_attribute16
    ,p_gos_attribute17               => p_gos_attribute17
    ,p_gos_attribute18               => p_gos_attribute18
    ,p_gos_attribute19               => p_gos_attribute19
    ,p_gos_attribute20               => p_gos_attribute20
    ,p_gos_attribute21               => p_gos_attribute21
    ,p_gos_attribute22               => p_gos_attribute22
    ,p_gos_attribute23               => p_gos_attribute23
    ,p_gos_attribute24               => p_gos_attribute24
    ,p_gos_attribute25               => p_gos_attribute25
    ,p_gos_attribute26               => p_gos_attribute26
    ,p_gos_attribute27               => p_gos_attribute27
    ,p_gos_attribute28               => p_gos_attribute28
    ,p_gos_attribute29               => p_gos_attribute29
    ,p_gos_attribute30               => p_gos_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_GOOD_SVC_TYPE
    --
    ben_GOOD_SVC_TYPE_bk2.update_GOOD_SVC_TYPE_a
      (
       p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_name                           =>  p_name
      ,p_typ_cd                         =>  p_typ_cd
      ,p_description                    =>  p_description
      ,p_gos_attribute_category         =>  p_gos_attribute_category
      ,p_gos_attribute1                 =>  p_gos_attribute1
      ,p_gos_attribute2                 =>  p_gos_attribute2
      ,p_gos_attribute3                 =>  p_gos_attribute3
      ,p_gos_attribute4                 =>  p_gos_attribute4
      ,p_gos_attribute5                 =>  p_gos_attribute5
      ,p_gos_attribute6                 =>  p_gos_attribute6
      ,p_gos_attribute7                 =>  p_gos_attribute7
      ,p_gos_attribute8                 =>  p_gos_attribute8
      ,p_gos_attribute9                 =>  p_gos_attribute9
      ,p_gos_attribute10                =>  p_gos_attribute10
      ,p_gos_attribute11                =>  p_gos_attribute11
      ,p_gos_attribute12                =>  p_gos_attribute12
      ,p_gos_attribute13                =>  p_gos_attribute13
      ,p_gos_attribute14                =>  p_gos_attribute14
      ,p_gos_attribute15                =>  p_gos_attribute15
      ,p_gos_attribute16                =>  p_gos_attribute16
      ,p_gos_attribute17                =>  p_gos_attribute17
      ,p_gos_attribute18                =>  p_gos_attribute18
      ,p_gos_attribute19                =>  p_gos_attribute19
      ,p_gos_attribute20                =>  p_gos_attribute20
      ,p_gos_attribute21                =>  p_gos_attribute21
      ,p_gos_attribute22                =>  p_gos_attribute22
      ,p_gos_attribute23                =>  p_gos_attribute23
      ,p_gos_attribute24                =>  p_gos_attribute24
      ,p_gos_attribute25                =>  p_gos_attribute25
      ,p_gos_attribute26                =>  p_gos_attribute26
      ,p_gos_attribute27                =>  p_gos_attribute27
      ,p_gos_attribute28                =>  p_gos_attribute28
      ,p_gos_attribute29                =>  p_gos_attribute29
      ,p_gos_attribute30                =>  p_gos_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GOOD_SVC_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_GOOD_SVC_TYPE
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
    ROLLBACK TO update_GOOD_SVC_TYPE;
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
    ROLLBACK TO update_GOOD_SVC_TYPE;
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_GOOD_SVC_TYPE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_GOOD_SVC_TYPE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GOOD_SVC_TYPE
  (p_validate                       in  boolean  default false
  ,p_gd_or_svc_typ_id               in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_GOOD_SVC_TYPE';
  l_object_version_number ben_gd_or_svc_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_GOOD_SVC_TYPE;
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
    -- Start of API User Hook for the before hook of delete_GOOD_SVC_TYPE
    --
    ben_GOOD_SVC_TYPE_bk3.delete_GOOD_SVC_TYPE_b
      (
       p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GOOD_SVC_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_GOOD_SVC_TYPE
    --
  end;
  --
  ben_gos_del.del
    (
     p_gd_or_svc_typ_id              => p_gd_or_svc_typ_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_GOOD_SVC_TYPE
    --
    ben_GOOD_SVC_TYPE_bk3.delete_GOOD_SVC_TYPE_a
      (
       p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GOOD_SVC_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_GOOD_SVC_TYPE
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
    ROLLBACK TO delete_GOOD_SVC_TYPE;
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
    ROLLBACK TO delete_GOOD_SVC_TYPE;
    p_object_version_number := l_object_version_number;

    raise;
    --
end delete_GOOD_SVC_TYPE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_gd_or_svc_typ_id                   in     number
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
  ben_gos_shd.lck
    (
      p_gd_or_svc_typ_id                 => p_gd_or_svc_typ_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_GOOD_SVC_TYPE_api;

/
