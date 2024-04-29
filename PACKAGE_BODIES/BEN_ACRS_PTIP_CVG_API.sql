--------------------------------------------------------
--  DDL for Package Body BEN_ACRS_PTIP_CVG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ACRS_PTIP_CVG_API" as
/* $Header: beapcapi.pkb 120.0 2005/05/28 00:24:13 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_acrs_ptip_cvg_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_acrs_ptip_cvg >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_acrs_ptip_cvg
  (p_validate                       in  boolean   default false
  ,p_acrs_ptip_cvg_id               out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_mx_cvg_alwd_amt                in  number    default null
  ,p_mn_cvg_alwd_amt                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_apc_attribute_category         in  varchar2  default null
  ,p_apc_attribute1                 in  varchar2  default null
  ,p_apc_attribute2                 in  varchar2  default null
  ,p_apc_attribute3                 in  varchar2  default null
  ,p_apc_attribute4                 in  varchar2  default null
  ,p_apc_attribute5                 in  varchar2  default null
  ,p_apc_attribute6                 in  varchar2  default null
  ,p_apc_attribute7                 in  varchar2  default null
  ,p_apc_attribute8                 in  varchar2  default null
  ,p_apc_attribute9                 in  varchar2  default null
  ,p_apc_attribute10                in  varchar2  default null
  ,p_apc_attribute11                in  varchar2  default null
  ,p_apc_attribute12                in  varchar2  default null
  ,p_apc_attribute13                in  varchar2  default null
  ,p_apc_attribute14                in  varchar2  default null
  ,p_apc_attribute15                in  varchar2  default null
  ,p_apc_attribute16                in  varchar2  default null
  ,p_apc_attribute17                in  varchar2  default null
  ,p_apc_attribute18                in  varchar2  default null
  ,p_apc_attribute19                in  varchar2  default null
  ,p_apc_attribute20                in  varchar2  default null
  ,p_apc_attribute21                in  varchar2  default null
  ,p_apc_attribute22                in  varchar2  default null
  ,p_apc_attribute23                in  varchar2  default null
  ,p_apc_attribute24                in  varchar2  default null
  ,p_apc_attribute25                in  varchar2  default null
  ,p_apc_attribute26                in  varchar2  default null
  ,p_apc_attribute27                in  varchar2  default null
  ,p_apc_attribute28                in  varchar2  default null
  ,p_apc_attribute29                in  varchar2  default null
  ,p_apc_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_pgm_id                         in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_acrs_ptip_cvg_id ben_acrs_ptip_cvg_f.acrs_ptip_cvg_id%TYPE;
  l_effective_start_date ben_acrs_ptip_cvg_f.effective_start_date%TYPE;
  l_effective_end_date ben_acrs_ptip_cvg_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_acrs_ptip_cvg';
  l_object_version_number ben_acrs_ptip_cvg_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_acrs_ptip_cvg;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_acrs_ptip_cvg
    --
    ben_acrs_ptip_cvg_bk1.create_acrs_ptip_cvg_b
      (
       p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mn_cvg_alwd_amt                =>  p_mn_cvg_alwd_amt
      ,p_business_group_id              =>  p_business_group_id
      ,p_apc_attribute_category         =>  p_apc_attribute_category
      ,p_apc_attribute1                 =>  p_apc_attribute1
      ,p_apc_attribute2                 =>  p_apc_attribute2
      ,p_apc_attribute3                 =>  p_apc_attribute3
      ,p_apc_attribute4                 =>  p_apc_attribute4
      ,p_apc_attribute5                 =>  p_apc_attribute5
      ,p_apc_attribute6                 =>  p_apc_attribute6
      ,p_apc_attribute7                 =>  p_apc_attribute7
      ,p_apc_attribute8                 =>  p_apc_attribute8
      ,p_apc_attribute9                 =>  p_apc_attribute9
      ,p_apc_attribute10                =>  p_apc_attribute10
      ,p_apc_attribute11                =>  p_apc_attribute11
      ,p_apc_attribute12                =>  p_apc_attribute12
      ,p_apc_attribute13                =>  p_apc_attribute13
      ,p_apc_attribute14                =>  p_apc_attribute14
      ,p_apc_attribute15                =>  p_apc_attribute15
      ,p_apc_attribute16                =>  p_apc_attribute16
      ,p_apc_attribute17                =>  p_apc_attribute17
      ,p_apc_attribute18                =>  p_apc_attribute18
      ,p_apc_attribute19                =>  p_apc_attribute19
      ,p_apc_attribute20                =>  p_apc_attribute20
      ,p_apc_attribute21                =>  p_apc_attribute21
      ,p_apc_attribute22                =>  p_apc_attribute22
      ,p_apc_attribute23                =>  p_apc_attribute23
      ,p_apc_attribute24                =>  p_apc_attribute24
      ,p_apc_attribute25                =>  p_apc_attribute25
      ,p_apc_attribute26                =>  p_apc_attribute26
      ,p_apc_attribute27                =>  p_apc_attribute27
      ,p_apc_attribute28                =>  p_apc_attribute28
      ,p_apc_attribute29                =>  p_apc_attribute29
      ,p_apc_attribute30                =>  p_apc_attribute30
      ,p_name                           =>  p_name
      ,p_pgm_id                         =>  p_pgm_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_acrs_ptip_cvg'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_acrs_ptip_cvg
    --
  end;
  --
  ben_apc_ins.ins
    (
     p_acrs_ptip_cvg_id              => l_acrs_ptip_cvg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_mx_cvg_alwd_amt               => p_mx_cvg_alwd_amt
    ,p_mn_cvg_alwd_amt               => p_mn_cvg_alwd_amt
    ,p_business_group_id             => p_business_group_id
    ,p_apc_attribute_category        => p_apc_attribute_category
    ,p_apc_attribute1                => p_apc_attribute1
    ,p_apc_attribute2                => p_apc_attribute2
    ,p_apc_attribute3                => p_apc_attribute3
    ,p_apc_attribute4                => p_apc_attribute4
    ,p_apc_attribute5                => p_apc_attribute5
    ,p_apc_attribute6                => p_apc_attribute6
    ,p_apc_attribute7                => p_apc_attribute7
    ,p_apc_attribute8                => p_apc_attribute8
    ,p_apc_attribute9                => p_apc_attribute9
    ,p_apc_attribute10               => p_apc_attribute10
    ,p_apc_attribute11               => p_apc_attribute11
    ,p_apc_attribute12               => p_apc_attribute12
    ,p_apc_attribute13               => p_apc_attribute13
    ,p_apc_attribute14               => p_apc_attribute14
    ,p_apc_attribute15               => p_apc_attribute15
    ,p_apc_attribute16               => p_apc_attribute16
    ,p_apc_attribute17               => p_apc_attribute17
    ,p_apc_attribute18               => p_apc_attribute18
    ,p_apc_attribute19               => p_apc_attribute19
    ,p_apc_attribute20               => p_apc_attribute20
    ,p_apc_attribute21               => p_apc_attribute21
    ,p_apc_attribute22               => p_apc_attribute22
    ,p_apc_attribute23               => p_apc_attribute23
    ,p_apc_attribute24               => p_apc_attribute24
    ,p_apc_attribute25               => p_apc_attribute25
    ,p_apc_attribute26               => p_apc_attribute26
    ,p_apc_attribute27               => p_apc_attribute27
    ,p_apc_attribute28               => p_apc_attribute28
    ,p_apc_attribute29               => p_apc_attribute29
    ,p_apc_attribute30               => p_apc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_name                          => p_name
    ,p_pgm_id                        => p_pgm_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_acrs_ptip_cvg
    --
    ben_acrs_ptip_cvg_bk1.create_acrs_ptip_cvg_a
      (
       p_acrs_ptip_cvg_id               =>  l_acrs_ptip_cvg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mn_cvg_alwd_amt                =>  p_mn_cvg_alwd_amt
      ,p_business_group_id              =>  p_business_group_id
      ,p_apc_attribute_category         =>  p_apc_attribute_category
      ,p_apc_attribute1                 =>  p_apc_attribute1
      ,p_apc_attribute2                 =>  p_apc_attribute2
      ,p_apc_attribute3                 =>  p_apc_attribute3
      ,p_apc_attribute4                 =>  p_apc_attribute4
      ,p_apc_attribute5                 =>  p_apc_attribute5
      ,p_apc_attribute6                 =>  p_apc_attribute6
      ,p_apc_attribute7                 =>  p_apc_attribute7
      ,p_apc_attribute8                 =>  p_apc_attribute8
      ,p_apc_attribute9                 =>  p_apc_attribute9
      ,p_apc_attribute10                =>  p_apc_attribute10
      ,p_apc_attribute11                =>  p_apc_attribute11
      ,p_apc_attribute12                =>  p_apc_attribute12
      ,p_apc_attribute13                =>  p_apc_attribute13
      ,p_apc_attribute14                =>  p_apc_attribute14
      ,p_apc_attribute15                =>  p_apc_attribute15
      ,p_apc_attribute16                =>  p_apc_attribute16
      ,p_apc_attribute17                =>  p_apc_attribute17
      ,p_apc_attribute18                =>  p_apc_attribute18
      ,p_apc_attribute19                =>  p_apc_attribute19
      ,p_apc_attribute20                =>  p_apc_attribute20
      ,p_apc_attribute21                =>  p_apc_attribute21
      ,p_apc_attribute22                =>  p_apc_attribute22
      ,p_apc_attribute23                =>  p_apc_attribute23
      ,p_apc_attribute24                =>  p_apc_attribute24
      ,p_apc_attribute25                =>  p_apc_attribute25
      ,p_apc_attribute26                =>  p_apc_attribute26
      ,p_apc_attribute27                =>  p_apc_attribute27
      ,p_apc_attribute28                =>  p_apc_attribute28
      ,p_apc_attribute29                =>  p_apc_attribute29
      ,p_apc_attribute30                =>  p_apc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_name                           =>  p_name
      ,p_pgm_id                         =>  p_pgm_id
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_acrs_ptip_cvg'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_acrs_ptip_cvg
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
  p_acrs_ptip_cvg_id := l_acrs_ptip_cvg_id;
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
    ROLLBACK TO create_acrs_ptip_cvg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_acrs_ptip_cvg_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_acrs_ptip_cvg;
    raise;
    --
end create_acrs_ptip_cvg;
-- ----------------------------------------------------------------------------
-- |------------------------< update_acrs_ptip_cvg >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_acrs_ptip_cvg
  (p_validate                       in  boolean   default false
  ,p_acrs_ptip_cvg_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_mx_cvg_alwd_amt                in  number    default hr_api.g_number
  ,p_mn_cvg_alwd_amt                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_apc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_apc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_acrs_ptip_cvg';
  l_object_version_number ben_acrs_ptip_cvg_f.object_version_number%TYPE;
  l_effective_start_date ben_acrs_ptip_cvg_f.effective_start_date%TYPE;
  l_effective_end_date ben_acrs_ptip_cvg_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_acrs_ptip_cvg;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_acrs_ptip_cvg
    --
    ben_acrs_ptip_cvg_bk2.update_acrs_ptip_cvg_b
      (
       p_acrs_ptip_cvg_id               =>  p_acrs_ptip_cvg_id
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mn_cvg_alwd_amt                =>  p_mn_cvg_alwd_amt
      ,p_business_group_id              =>  p_business_group_id
      ,p_apc_attribute_category         =>  p_apc_attribute_category
      ,p_apc_attribute1                 =>  p_apc_attribute1
      ,p_apc_attribute2                 =>  p_apc_attribute2
      ,p_apc_attribute3                 =>  p_apc_attribute3
      ,p_apc_attribute4                 =>  p_apc_attribute4
      ,p_apc_attribute5                 =>  p_apc_attribute5
      ,p_apc_attribute6                 =>  p_apc_attribute6
      ,p_apc_attribute7                 =>  p_apc_attribute7
      ,p_apc_attribute8                 =>  p_apc_attribute8
      ,p_apc_attribute9                 =>  p_apc_attribute9
      ,p_apc_attribute10                =>  p_apc_attribute10
      ,p_apc_attribute11                =>  p_apc_attribute11
      ,p_apc_attribute12                =>  p_apc_attribute12
      ,p_apc_attribute13                =>  p_apc_attribute13
      ,p_apc_attribute14                =>  p_apc_attribute14
      ,p_apc_attribute15                =>  p_apc_attribute15
      ,p_apc_attribute16                =>  p_apc_attribute16
      ,p_apc_attribute17                =>  p_apc_attribute17
      ,p_apc_attribute18                =>  p_apc_attribute18
      ,p_apc_attribute19                =>  p_apc_attribute19
      ,p_apc_attribute20                =>  p_apc_attribute20
      ,p_apc_attribute21                =>  p_apc_attribute21
      ,p_apc_attribute22                =>  p_apc_attribute22
      ,p_apc_attribute23                =>  p_apc_attribute23
      ,p_apc_attribute24                =>  p_apc_attribute24
      ,p_apc_attribute25                =>  p_apc_attribute25
      ,p_apc_attribute26                =>  p_apc_attribute26
      ,p_apc_attribute27                =>  p_apc_attribute27
      ,p_apc_attribute28                =>  p_apc_attribute28
      ,p_apc_attribute29                =>  p_apc_attribute29
      ,p_apc_attribute30                =>  p_apc_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_name                           =>  p_name
      ,p_pgm_id                         =>  p_pgm_id
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_acrs_ptip_cvg'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_acrs_ptip_cvg
    --
  end;
  --
  ben_apc_upd.upd
    (
     p_acrs_ptip_cvg_id              => p_acrs_ptip_cvg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_mx_cvg_alwd_amt               => p_mx_cvg_alwd_amt
    ,p_mn_cvg_alwd_amt               => p_mn_cvg_alwd_amt
    ,p_business_group_id             => p_business_group_id
    ,p_apc_attribute_category        => p_apc_attribute_category
    ,p_apc_attribute1                => p_apc_attribute1
    ,p_apc_attribute2                => p_apc_attribute2
    ,p_apc_attribute3                => p_apc_attribute3
    ,p_apc_attribute4                => p_apc_attribute4
    ,p_apc_attribute5                => p_apc_attribute5
    ,p_apc_attribute6                => p_apc_attribute6
    ,p_apc_attribute7                => p_apc_attribute7
    ,p_apc_attribute8                => p_apc_attribute8
    ,p_apc_attribute9                => p_apc_attribute9
    ,p_apc_attribute10               => p_apc_attribute10
    ,p_apc_attribute11               => p_apc_attribute11
    ,p_apc_attribute12               => p_apc_attribute12
    ,p_apc_attribute13               => p_apc_attribute13
    ,p_apc_attribute14               => p_apc_attribute14
    ,p_apc_attribute15               => p_apc_attribute15
    ,p_apc_attribute16               => p_apc_attribute16
    ,p_apc_attribute17               => p_apc_attribute17
    ,p_apc_attribute18               => p_apc_attribute18
    ,p_apc_attribute19               => p_apc_attribute19
    ,p_apc_attribute20               => p_apc_attribute20
    ,p_apc_attribute21               => p_apc_attribute21
    ,p_apc_attribute22               => p_apc_attribute22
    ,p_apc_attribute23               => p_apc_attribute23
    ,p_apc_attribute24               => p_apc_attribute24
    ,p_apc_attribute25               => p_apc_attribute25
    ,p_apc_attribute26               => p_apc_attribute26
    ,p_apc_attribute27               => p_apc_attribute27
    ,p_apc_attribute28               => p_apc_attribute28
    ,p_apc_attribute29               => p_apc_attribute29
    ,p_apc_attribute30               => p_apc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_name                          => p_name
    ,p_pgm_id                        => p_pgm_id
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_acrs_ptip_cvg
    --
    ben_acrs_ptip_cvg_bk2.update_acrs_ptip_cvg_a
      (
       p_acrs_ptip_cvg_id               =>  p_acrs_ptip_cvg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mn_cvg_alwd_amt                =>  p_mn_cvg_alwd_amt
      ,p_business_group_id              =>  p_business_group_id
      ,p_apc_attribute_category         =>  p_apc_attribute_category
      ,p_apc_attribute1                 =>  p_apc_attribute1
      ,p_apc_attribute2                 =>  p_apc_attribute2
      ,p_apc_attribute3                 =>  p_apc_attribute3
      ,p_apc_attribute4                 =>  p_apc_attribute4
      ,p_apc_attribute5                 =>  p_apc_attribute5
      ,p_apc_attribute6                 =>  p_apc_attribute6
      ,p_apc_attribute7                 =>  p_apc_attribute7
      ,p_apc_attribute8                 =>  p_apc_attribute8
      ,p_apc_attribute9                 =>  p_apc_attribute9
      ,p_apc_attribute10                =>  p_apc_attribute10
      ,p_apc_attribute11                =>  p_apc_attribute11
      ,p_apc_attribute12                =>  p_apc_attribute12
      ,p_apc_attribute13                =>  p_apc_attribute13
      ,p_apc_attribute14                =>  p_apc_attribute14
      ,p_apc_attribute15                =>  p_apc_attribute15
      ,p_apc_attribute16                =>  p_apc_attribute16
      ,p_apc_attribute17                =>  p_apc_attribute17
      ,p_apc_attribute18                =>  p_apc_attribute18
      ,p_apc_attribute19                =>  p_apc_attribute19
      ,p_apc_attribute20                =>  p_apc_attribute20
      ,p_apc_attribute21                =>  p_apc_attribute21
      ,p_apc_attribute22                =>  p_apc_attribute22
      ,p_apc_attribute23                =>  p_apc_attribute23
      ,p_apc_attribute24                =>  p_apc_attribute24
      ,p_apc_attribute25                =>  p_apc_attribute25
      ,p_apc_attribute26                =>  p_apc_attribute26
      ,p_apc_attribute27                =>  p_apc_attribute27
      ,p_apc_attribute28                =>  p_apc_attribute28
      ,p_apc_attribute29                =>  p_apc_attribute29
      ,p_apc_attribute30                =>  p_apc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_name                           =>  p_name
      ,p_pgm_id                         =>  p_pgm_id
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_acrs_ptip_cvg'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_acrs_ptip_cvg
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
    ROLLBACK TO update_acrs_ptip_cvg;
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
    ROLLBACK TO update_acrs_ptip_cvg;
      /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end update_acrs_ptip_cvg;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_acrs_ptip_cvg >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acrs_ptip_cvg
  (p_validate                       in  boolean  default false
  ,p_acrs_ptip_cvg_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_acrs_ptip_cvg';
  l_object_version_number ben_acrs_ptip_cvg_f.object_version_number%TYPE;
  l_effective_start_date ben_acrs_ptip_cvg_f.effective_start_date%TYPE;
  l_effective_end_date ben_acrs_ptip_cvg_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_acrs_ptip_cvg;
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
    -- Start of API User Hook for the before hook of delete_acrs_ptip_cvg
    --
    ben_acrs_ptip_cvg_bk3.delete_acrs_ptip_cvg_b
      (
       p_acrs_ptip_cvg_id               =>  p_acrs_ptip_cvg_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_acrs_ptip_cvg'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_acrs_ptip_cvg
    --
  end;
  --
  ben_apc_del.del
    (
     p_acrs_ptip_cvg_id              => p_acrs_ptip_cvg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_acrs_ptip_cvg
    --
    ben_acrs_ptip_cvg_bk3.delete_acrs_ptip_cvg_a
      (
       p_acrs_ptip_cvg_id               =>  p_acrs_ptip_cvg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_acrs_ptip_cvg'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_acrs_ptip_cvg
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
    ROLLBACK TO delete_acrs_ptip_cvg;
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
    ROLLBACK TO delete_acrs_ptip_cvg;
      /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end delete_acrs_ptip_cvg;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_acrs_ptip_cvg_id                   in     number
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
  ben_apc_shd.lck
    (
      p_acrs_ptip_cvg_id                 => p_acrs_ptip_cvg_id
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
end ben_acrs_ptip_cvg_api;

/
