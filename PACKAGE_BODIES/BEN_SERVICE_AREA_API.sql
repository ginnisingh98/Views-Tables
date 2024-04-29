--------------------------------------------------------
--  DDL for Package Body BEN_SERVICE_AREA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SERVICE_AREA_API" as
/* $Header: besvaapi.pkb 120.0 2005/05/28 11:53:36 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_SERVICE_AREA_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_SERVICE_AREA >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_SERVICE_AREA
  (p_validate                       in  boolean   default false
  ,p_svc_area_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_org_unit_prdct                 in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_sva_attribute_category         in  varchar2  default null
  ,p_sva_attribute1                 in  varchar2  default null
  ,p_sva_attribute2                 in  varchar2  default null
  ,p_sva_attribute3                 in  varchar2  default null
  ,p_sva_attribute4                 in  varchar2  default null
  ,p_sva_attribute5                 in  varchar2  default null
  ,p_sva_attribute6                 in  varchar2  default null
  ,p_sva_attribute7                 in  varchar2  default null
  ,p_sva_attribute8                 in  varchar2  default null
  ,p_sva_attribute9                 in  varchar2  default null
  ,p_sva_attribute10                in  varchar2  default null
  ,p_sva_attribute11                in  varchar2  default null
  ,p_sva_attribute12                in  varchar2  default null
  ,p_sva_attribute13                in  varchar2  default null
  ,p_sva_attribute14                in  varchar2  default null
  ,p_sva_attribute15                in  varchar2  default null
  ,p_sva_attribute16                in  varchar2  default null
  ,p_sva_attribute17                in  varchar2  default null
  ,p_sva_attribute18                in  varchar2  default null
  ,p_sva_attribute19                in  varchar2  default null
  ,p_sva_attribute20                in  varchar2  default null
  ,p_sva_attribute21                in  varchar2  default null
  ,p_sva_attribute22                in  varchar2  default null
  ,p_sva_attribute23                in  varchar2  default null
  ,p_sva_attribute24                in  varchar2  default null
  ,p_sva_attribute25                in  varchar2  default null
  ,p_sva_attribute26                in  varchar2  default null
  ,p_sva_attribute27                in  varchar2  default null
  ,p_sva_attribute28                in  varchar2  default null
  ,p_sva_attribute29                in  varchar2  default null
  ,p_sva_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_svc_area_id ben_svc_area_f.svc_area_id%TYPE;
  l_effective_start_date ben_svc_area_f.effective_start_date%TYPE;
  l_effective_end_date ben_svc_area_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_SERVICE_AREA';
  l_object_version_number ben_svc_area_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_SERVICE_AREA;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_SERVICE_AREA
    --
    ben_SERVICE_AREA_bk1.create_SERVICE_AREA_b
      (
       p_name                           =>  p_name
      ,p_org_unit_prdct                 =>  p_org_unit_prdct
      ,p_business_group_id              =>  p_business_group_id
      ,p_sva_attribute_category         =>  p_sva_attribute_category
      ,p_sva_attribute1                 =>  p_sva_attribute1
      ,p_sva_attribute2                 =>  p_sva_attribute2
      ,p_sva_attribute3                 =>  p_sva_attribute3
      ,p_sva_attribute4                 =>  p_sva_attribute4
      ,p_sva_attribute5                 =>  p_sva_attribute5
      ,p_sva_attribute6                 =>  p_sva_attribute6
      ,p_sva_attribute7                 =>  p_sva_attribute7
      ,p_sva_attribute8                 =>  p_sva_attribute8
      ,p_sva_attribute9                 =>  p_sva_attribute9
      ,p_sva_attribute10                =>  p_sva_attribute10
      ,p_sva_attribute11                =>  p_sva_attribute11
      ,p_sva_attribute12                =>  p_sva_attribute12
      ,p_sva_attribute13                =>  p_sva_attribute13
      ,p_sva_attribute14                =>  p_sva_attribute14
      ,p_sva_attribute15                =>  p_sva_attribute15
      ,p_sva_attribute16                =>  p_sva_attribute16
      ,p_sva_attribute17                =>  p_sva_attribute17
      ,p_sva_attribute18                =>  p_sva_attribute18
      ,p_sva_attribute19                =>  p_sva_attribute19
      ,p_sva_attribute20                =>  p_sva_attribute20
      ,p_sva_attribute21                =>  p_sva_attribute21
      ,p_sva_attribute22                =>  p_sva_attribute22
      ,p_sva_attribute23                =>  p_sva_attribute23
      ,p_sva_attribute24                =>  p_sva_attribute24
      ,p_sva_attribute25                =>  p_sva_attribute25
      ,p_sva_attribute26                =>  p_sva_attribute26
      ,p_sva_attribute27                =>  p_sva_attribute27
      ,p_sva_attribute28                =>  p_sva_attribute28
      ,p_sva_attribute29                =>  p_sva_attribute29
      ,p_sva_attribute30                =>  p_sva_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_SERVICE_AREA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_SERVICE_AREA
    --
  end;
  --
  ben_sva_ins.ins
    (
     p_svc_area_id                   => l_svc_area_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_org_unit_prdct                => p_org_unit_prdct
    ,p_business_group_id             => p_business_group_id
    ,p_sva_attribute_category        => p_sva_attribute_category
    ,p_sva_attribute1                => p_sva_attribute1
    ,p_sva_attribute2                => p_sva_attribute2
    ,p_sva_attribute3                => p_sva_attribute3
    ,p_sva_attribute4                => p_sva_attribute4
    ,p_sva_attribute5                => p_sva_attribute5
    ,p_sva_attribute6                => p_sva_attribute6
    ,p_sva_attribute7                => p_sva_attribute7
    ,p_sva_attribute8                => p_sva_attribute8
    ,p_sva_attribute9                => p_sva_attribute9
    ,p_sva_attribute10               => p_sva_attribute10
    ,p_sva_attribute11               => p_sva_attribute11
    ,p_sva_attribute12               => p_sva_attribute12
    ,p_sva_attribute13               => p_sva_attribute13
    ,p_sva_attribute14               => p_sva_attribute14
    ,p_sva_attribute15               => p_sva_attribute15
    ,p_sva_attribute16               => p_sva_attribute16
    ,p_sva_attribute17               => p_sva_attribute17
    ,p_sva_attribute18               => p_sva_attribute18
    ,p_sva_attribute19               => p_sva_attribute19
    ,p_sva_attribute20               => p_sva_attribute20
    ,p_sva_attribute21               => p_sva_attribute21
    ,p_sva_attribute22               => p_sva_attribute22
    ,p_sva_attribute23               => p_sva_attribute23
    ,p_sva_attribute24               => p_sva_attribute24
    ,p_sva_attribute25               => p_sva_attribute25
    ,p_sva_attribute26               => p_sva_attribute26
    ,p_sva_attribute27               => p_sva_attribute27
    ,p_sva_attribute28               => p_sva_attribute28
    ,p_sva_attribute29               => p_sva_attribute29
    ,p_sva_attribute30               => p_sva_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_SERVICE_AREA
    --
    ben_SERVICE_AREA_bk1.create_SERVICE_AREA_a
      (
       p_svc_area_id                    =>  l_svc_area_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_org_unit_prdct                 =>  p_org_unit_prdct
      ,p_business_group_id              =>  p_business_group_id
      ,p_sva_attribute_category         =>  p_sva_attribute_category
      ,p_sva_attribute1                 =>  p_sva_attribute1
      ,p_sva_attribute2                 =>  p_sva_attribute2
      ,p_sva_attribute3                 =>  p_sva_attribute3
      ,p_sva_attribute4                 =>  p_sva_attribute4
      ,p_sva_attribute5                 =>  p_sva_attribute5
      ,p_sva_attribute6                 =>  p_sva_attribute6
      ,p_sva_attribute7                 =>  p_sva_attribute7
      ,p_sva_attribute8                 =>  p_sva_attribute8
      ,p_sva_attribute9                 =>  p_sva_attribute9
      ,p_sva_attribute10                =>  p_sva_attribute10
      ,p_sva_attribute11                =>  p_sva_attribute11
      ,p_sva_attribute12                =>  p_sva_attribute12
      ,p_sva_attribute13                =>  p_sva_attribute13
      ,p_sva_attribute14                =>  p_sva_attribute14
      ,p_sva_attribute15                =>  p_sva_attribute15
      ,p_sva_attribute16                =>  p_sva_attribute16
      ,p_sva_attribute17                =>  p_sva_attribute17
      ,p_sva_attribute18                =>  p_sva_attribute18
      ,p_sva_attribute19                =>  p_sva_attribute19
      ,p_sva_attribute20                =>  p_sva_attribute20
      ,p_sva_attribute21                =>  p_sva_attribute21
      ,p_sva_attribute22                =>  p_sva_attribute22
      ,p_sva_attribute23                =>  p_sva_attribute23
      ,p_sva_attribute24                =>  p_sva_attribute24
      ,p_sva_attribute25                =>  p_sva_attribute25
      ,p_sva_attribute26                =>  p_sva_attribute26
      ,p_sva_attribute27                =>  p_sva_attribute27
      ,p_sva_attribute28                =>  p_sva_attribute28
      ,p_sva_attribute29                =>  p_sva_attribute29
      ,p_sva_attribute30                =>  p_sva_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SERVICE_AREA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_SERVICE_AREA
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
  p_svc_area_id := l_svc_area_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
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
    ROLLBACK TO create_SERVICE_AREA;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_svc_area_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_SERVICE_AREA;
    --
    p_svc_area_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end create_SERVICE_AREA;
-- ----------------------------------------------------------------------------
-- |------------------------< update_SERVICE_AREA >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_SERVICE_AREA
  (p_validate                       in  boolean   default false
  ,p_svc_area_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_org_unit_prdct                 in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_sva_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_sva_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_SERVICE_AREA';
  l_object_version_number ben_svc_area_f.object_version_number%TYPE;
  l_effective_start_date ben_svc_area_f.effective_start_date%TYPE;
  l_effective_end_date ben_svc_area_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_SERVICE_AREA;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_SERVICE_AREA
    --
    ben_SERVICE_AREA_bk2.update_SERVICE_AREA_b
      (
       p_svc_area_id                    =>  p_svc_area_id
      ,p_name                           =>  p_name
      ,p_org_unit_prdct                 =>  p_org_unit_prdct
      ,p_business_group_id              =>  p_business_group_id
      ,p_sva_attribute_category         =>  p_sva_attribute_category
      ,p_sva_attribute1                 =>  p_sva_attribute1
      ,p_sva_attribute2                 =>  p_sva_attribute2
      ,p_sva_attribute3                 =>  p_sva_attribute3
      ,p_sva_attribute4                 =>  p_sva_attribute4
      ,p_sva_attribute5                 =>  p_sva_attribute5
      ,p_sva_attribute6                 =>  p_sva_attribute6
      ,p_sva_attribute7                 =>  p_sva_attribute7
      ,p_sva_attribute8                 =>  p_sva_attribute8
      ,p_sva_attribute9                 =>  p_sva_attribute9
      ,p_sva_attribute10                =>  p_sva_attribute10
      ,p_sva_attribute11                =>  p_sva_attribute11
      ,p_sva_attribute12                =>  p_sva_attribute12
      ,p_sva_attribute13                =>  p_sva_attribute13
      ,p_sva_attribute14                =>  p_sva_attribute14
      ,p_sva_attribute15                =>  p_sva_attribute15
      ,p_sva_attribute16                =>  p_sva_attribute16
      ,p_sva_attribute17                =>  p_sva_attribute17
      ,p_sva_attribute18                =>  p_sva_attribute18
      ,p_sva_attribute19                =>  p_sva_attribute19
      ,p_sva_attribute20                =>  p_sva_attribute20
      ,p_sva_attribute21                =>  p_sva_attribute21
      ,p_sva_attribute22                =>  p_sva_attribute22
      ,p_sva_attribute23                =>  p_sva_attribute23
      ,p_sva_attribute24                =>  p_sva_attribute24
      ,p_sva_attribute25                =>  p_sva_attribute25
      ,p_sva_attribute26                =>  p_sva_attribute26
      ,p_sva_attribute27                =>  p_sva_attribute27
      ,p_sva_attribute28                =>  p_sva_attribute28
      ,p_sva_attribute29                =>  p_sva_attribute29
      ,p_sva_attribute30                =>  p_sva_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SERVICE_AREA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_SERVICE_AREA
    --
  end;
  --
  ben_sva_upd.upd
    (
     p_svc_area_id                   => p_svc_area_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_org_unit_prdct                => p_org_unit_prdct
    ,p_business_group_id             => p_business_group_id
    ,p_sva_attribute_category        => p_sva_attribute_category
    ,p_sva_attribute1                => p_sva_attribute1
    ,p_sva_attribute2                => p_sva_attribute2
    ,p_sva_attribute3                => p_sva_attribute3
    ,p_sva_attribute4                => p_sva_attribute4
    ,p_sva_attribute5                => p_sva_attribute5
    ,p_sva_attribute6                => p_sva_attribute6
    ,p_sva_attribute7                => p_sva_attribute7
    ,p_sva_attribute8                => p_sva_attribute8
    ,p_sva_attribute9                => p_sva_attribute9
    ,p_sva_attribute10               => p_sva_attribute10
    ,p_sva_attribute11               => p_sva_attribute11
    ,p_sva_attribute12               => p_sva_attribute12
    ,p_sva_attribute13               => p_sva_attribute13
    ,p_sva_attribute14               => p_sva_attribute14
    ,p_sva_attribute15               => p_sva_attribute15
    ,p_sva_attribute16               => p_sva_attribute16
    ,p_sva_attribute17               => p_sva_attribute17
    ,p_sva_attribute18               => p_sva_attribute18
    ,p_sva_attribute19               => p_sva_attribute19
    ,p_sva_attribute20               => p_sva_attribute20
    ,p_sva_attribute21               => p_sva_attribute21
    ,p_sva_attribute22               => p_sva_attribute22
    ,p_sva_attribute23               => p_sva_attribute23
    ,p_sva_attribute24               => p_sva_attribute24
    ,p_sva_attribute25               => p_sva_attribute25
    ,p_sva_attribute26               => p_sva_attribute26
    ,p_sva_attribute27               => p_sva_attribute27
    ,p_sva_attribute28               => p_sva_attribute28
    ,p_sva_attribute29               => p_sva_attribute29
    ,p_sva_attribute30               => p_sva_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_SERVICE_AREA
    --
    ben_SERVICE_AREA_bk2.update_SERVICE_AREA_a
      (
       p_svc_area_id                    =>  p_svc_area_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_org_unit_prdct                 =>  p_org_unit_prdct
      ,p_business_group_id              =>  p_business_group_id
      ,p_sva_attribute_category         =>  p_sva_attribute_category
      ,p_sva_attribute1                 =>  p_sva_attribute1
      ,p_sva_attribute2                 =>  p_sva_attribute2
      ,p_sva_attribute3                 =>  p_sva_attribute3
      ,p_sva_attribute4                 =>  p_sva_attribute4
      ,p_sva_attribute5                 =>  p_sva_attribute5
      ,p_sva_attribute6                 =>  p_sva_attribute6
      ,p_sva_attribute7                 =>  p_sva_attribute7
      ,p_sva_attribute8                 =>  p_sva_attribute8
      ,p_sva_attribute9                 =>  p_sva_attribute9
      ,p_sva_attribute10                =>  p_sva_attribute10
      ,p_sva_attribute11                =>  p_sva_attribute11
      ,p_sva_attribute12                =>  p_sva_attribute12
      ,p_sva_attribute13                =>  p_sva_attribute13
      ,p_sva_attribute14                =>  p_sva_attribute14
      ,p_sva_attribute15                =>  p_sva_attribute15
      ,p_sva_attribute16                =>  p_sva_attribute16
      ,p_sva_attribute17                =>  p_sva_attribute17
      ,p_sva_attribute18                =>  p_sva_attribute18
      ,p_sva_attribute19                =>  p_sva_attribute19
      ,p_sva_attribute20                =>  p_sva_attribute20
      ,p_sva_attribute21                =>  p_sva_attribute21
      ,p_sva_attribute22                =>  p_sva_attribute22
      ,p_sva_attribute23                =>  p_sva_attribute23
      ,p_sva_attribute24                =>  p_sva_attribute24
      ,p_sva_attribute25                =>  p_sva_attribute25
      ,p_sva_attribute26                =>  p_sva_attribute26
      ,p_sva_attribute27                =>  p_sva_attribute27
      ,p_sva_attribute28                =>  p_sva_attribute28
      ,p_sva_attribute29                =>  p_sva_attribute29
      ,p_sva_attribute30                =>  p_sva_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SERVICE_AREA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_SERVICE_AREA
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
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
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
    ROLLBACK TO update_SERVICE_AREA;
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
    ROLLBACK TO update_SERVICE_AREA;
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end update_SERVICE_AREA;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_SERVICE_AREA >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_SERVICE_AREA
  (p_validate                       in  boolean  default false
  ,p_svc_area_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_SERVICE_AREA';
  l_object_version_number ben_svc_area_f.object_version_number%TYPE;
  l_effective_start_date ben_svc_area_f.effective_start_date%TYPE;
  l_effective_end_date ben_svc_area_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_SERVICE_AREA;
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
    -- Start of API User Hook for the before hook of delete_SERVICE_AREA
    --
    ben_SERVICE_AREA_bk3.delete_SERVICE_AREA_b
      (
       p_svc_area_id                    =>  p_svc_area_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SERVICE_AREA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_SERVICE_AREA
    --
  end;
  --
  ben_sva_del.del
    (
     p_svc_area_id                   => p_svc_area_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_SERVICE_AREA
    --
    ben_SERVICE_AREA_bk3.delete_SERVICE_AREA_a
      (
       p_svc_area_id                    =>  p_svc_area_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SERVICE_AREA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_SERVICE_AREA
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
    ROLLBACK TO delete_SERVICE_AREA;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_SERVICE_AREA;
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end delete_SERVICE_AREA;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_svc_area_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_sva_shd.lck
    (
      p_svc_area_id                 => p_svc_area_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_SERVICE_AREA_api;

/
