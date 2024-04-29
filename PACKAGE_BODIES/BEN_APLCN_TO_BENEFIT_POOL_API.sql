--------------------------------------------------------
--  DDL for Package Body BEN_APLCN_TO_BENEFIT_POOL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_APLCN_TO_BENEFIT_POOL_API" as
/* $Header: beabpapi.pkb 120.0 2005/05/28 00:17:52 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Aplcn_To_Benefit_Pool_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Aplcn_To_Benefit_Pool >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Aplcn_To_Benefit_Pool
  (p_validate                       in  boolean   default false
  ,p_aplcn_to_bnft_pool_id          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_acty_base_rt_id                in  number    default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_abp_attribute_category         in  varchar2  default null
  ,p_abp_attribute1                 in  varchar2  default null
  ,p_abp_attribute2                 in  varchar2  default null
  ,p_abp_attribute3                 in  varchar2  default null
  ,p_abp_attribute4                 in  varchar2  default null
  ,p_abp_attribute5                 in  varchar2  default null
  ,p_abp_attribute6                 in  varchar2  default null
  ,p_abp_attribute7                 in  varchar2  default null
  ,p_abp_attribute8                 in  varchar2  default null
  ,p_abp_attribute9                 in  varchar2  default null
  ,p_abp_attribute10                in  varchar2  default null
  ,p_abp_attribute11                in  varchar2  default null
  ,p_abp_attribute12                in  varchar2  default null
  ,p_abp_attribute13                in  varchar2  default null
  ,p_abp_attribute14                in  varchar2  default null
  ,p_abp_attribute15                in  varchar2  default null
  ,p_abp_attribute16                in  varchar2  default null
  ,p_abp_attribute17                in  varchar2  default null
  ,p_abp_attribute18                in  varchar2  default null
  ,p_abp_attribute19                in  varchar2  default null
  ,p_abp_attribute20                in  varchar2  default null
  ,p_abp_attribute21                in  varchar2  default null
  ,p_abp_attribute22                in  varchar2  default null
  ,p_abp_attribute23                in  varchar2  default null
  ,p_abp_attribute24                in  varchar2  default null
  ,p_abp_attribute25                in  varchar2  default null
  ,p_abp_attribute26                in  varchar2  default null
  ,p_abp_attribute27                in  varchar2  default null
  ,p_abp_attribute28                in  varchar2  default null
  ,p_abp_attribute29                in  varchar2  default null
  ,p_abp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_aplcn_to_bnft_pool_id ben_aplcn_to_bnft_pool_f.aplcn_to_bnft_pool_id%TYPE;
  l_effective_start_date ben_aplcn_to_bnft_pool_f.effective_start_date%TYPE;
  l_effective_end_date ben_aplcn_to_bnft_pool_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Aplcn_To_Benefit_Pool';
  l_object_version_number ben_aplcn_to_bnft_pool_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Aplcn_To_Benefit_Pool;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Aplcn_To_Benefit_Pool
    --
    ben_Aplcn_To_Benefit_Pool_bk1.create_Aplcn_To_Benefit_Pool_b
      (
       p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_abp_attribute_category         =>  p_abp_attribute_category
      ,p_abp_attribute1                 =>  p_abp_attribute1
      ,p_abp_attribute2                 =>  p_abp_attribute2
      ,p_abp_attribute3                 =>  p_abp_attribute3
      ,p_abp_attribute4                 =>  p_abp_attribute4
      ,p_abp_attribute5                 =>  p_abp_attribute5
      ,p_abp_attribute6                 =>  p_abp_attribute6
      ,p_abp_attribute7                 =>  p_abp_attribute7
      ,p_abp_attribute8                 =>  p_abp_attribute8
      ,p_abp_attribute9                 =>  p_abp_attribute9
      ,p_abp_attribute10                =>  p_abp_attribute10
      ,p_abp_attribute11                =>  p_abp_attribute11
      ,p_abp_attribute12                =>  p_abp_attribute12
      ,p_abp_attribute13                =>  p_abp_attribute13
      ,p_abp_attribute14                =>  p_abp_attribute14
      ,p_abp_attribute15                =>  p_abp_attribute15
      ,p_abp_attribute16                =>  p_abp_attribute16
      ,p_abp_attribute17                =>  p_abp_attribute17
      ,p_abp_attribute18                =>  p_abp_attribute18
      ,p_abp_attribute19                =>  p_abp_attribute19
      ,p_abp_attribute20                =>  p_abp_attribute20
      ,p_abp_attribute21                =>  p_abp_attribute21
      ,p_abp_attribute22                =>  p_abp_attribute22
      ,p_abp_attribute23                =>  p_abp_attribute23
      ,p_abp_attribute24                =>  p_abp_attribute24
      ,p_abp_attribute25                =>  p_abp_attribute25
      ,p_abp_attribute26                =>  p_abp_attribute26
      ,p_abp_attribute27                =>  p_abp_attribute27
      ,p_abp_attribute28                =>  p_abp_attribute28
      ,p_abp_attribute29                =>  p_abp_attribute29
      ,p_abp_attribute30                =>  p_abp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Aplcn_To_Benefit_Pool'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Aplcn_To_Benefit_Pool
    --
  end;
  --
  ben_abp_ins.ins
    (
     p_aplcn_to_bnft_pool_id         => l_aplcn_to_bnft_pool_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_business_group_id             => p_business_group_id
    ,p_abp_attribute_category        => p_abp_attribute_category
    ,p_abp_attribute1                => p_abp_attribute1
    ,p_abp_attribute2                => p_abp_attribute2
    ,p_abp_attribute3                => p_abp_attribute3
    ,p_abp_attribute4                => p_abp_attribute4
    ,p_abp_attribute5                => p_abp_attribute5
    ,p_abp_attribute6                => p_abp_attribute6
    ,p_abp_attribute7                => p_abp_attribute7
    ,p_abp_attribute8                => p_abp_attribute8
    ,p_abp_attribute9                => p_abp_attribute9
    ,p_abp_attribute10               => p_abp_attribute10
    ,p_abp_attribute11               => p_abp_attribute11
    ,p_abp_attribute12               => p_abp_attribute12
    ,p_abp_attribute13               => p_abp_attribute13
    ,p_abp_attribute14               => p_abp_attribute14
    ,p_abp_attribute15               => p_abp_attribute15
    ,p_abp_attribute16               => p_abp_attribute16
    ,p_abp_attribute17               => p_abp_attribute17
    ,p_abp_attribute18               => p_abp_attribute18
    ,p_abp_attribute19               => p_abp_attribute19
    ,p_abp_attribute20               => p_abp_attribute20
    ,p_abp_attribute21               => p_abp_attribute21
    ,p_abp_attribute22               => p_abp_attribute22
    ,p_abp_attribute23               => p_abp_attribute23
    ,p_abp_attribute24               => p_abp_attribute24
    ,p_abp_attribute25               => p_abp_attribute25
    ,p_abp_attribute26               => p_abp_attribute26
    ,p_abp_attribute27               => p_abp_attribute27
    ,p_abp_attribute28               => p_abp_attribute28
    ,p_abp_attribute29               => p_abp_attribute29
    ,p_abp_attribute30               => p_abp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Aplcn_To_Benefit_Pool
    --
    ben_Aplcn_To_Benefit_Pool_bk1.create_Aplcn_To_Benefit_Pool_a
      (
       p_aplcn_to_bnft_pool_id          =>  l_aplcn_to_bnft_pool_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_abp_attribute_category         =>  p_abp_attribute_category
      ,p_abp_attribute1                 =>  p_abp_attribute1
      ,p_abp_attribute2                 =>  p_abp_attribute2
      ,p_abp_attribute3                 =>  p_abp_attribute3
      ,p_abp_attribute4                 =>  p_abp_attribute4
      ,p_abp_attribute5                 =>  p_abp_attribute5
      ,p_abp_attribute6                 =>  p_abp_attribute6
      ,p_abp_attribute7                 =>  p_abp_attribute7
      ,p_abp_attribute8                 =>  p_abp_attribute8
      ,p_abp_attribute9                 =>  p_abp_attribute9
      ,p_abp_attribute10                =>  p_abp_attribute10
      ,p_abp_attribute11                =>  p_abp_attribute11
      ,p_abp_attribute12                =>  p_abp_attribute12
      ,p_abp_attribute13                =>  p_abp_attribute13
      ,p_abp_attribute14                =>  p_abp_attribute14
      ,p_abp_attribute15                =>  p_abp_attribute15
      ,p_abp_attribute16                =>  p_abp_attribute16
      ,p_abp_attribute17                =>  p_abp_attribute17
      ,p_abp_attribute18                =>  p_abp_attribute18
      ,p_abp_attribute19                =>  p_abp_attribute19
      ,p_abp_attribute20                =>  p_abp_attribute20
      ,p_abp_attribute21                =>  p_abp_attribute21
      ,p_abp_attribute22                =>  p_abp_attribute22
      ,p_abp_attribute23                =>  p_abp_attribute23
      ,p_abp_attribute24                =>  p_abp_attribute24
      ,p_abp_attribute25                =>  p_abp_attribute25
      ,p_abp_attribute26                =>  p_abp_attribute26
      ,p_abp_attribute27                =>  p_abp_attribute27
      ,p_abp_attribute28                =>  p_abp_attribute28
      ,p_abp_attribute29                =>  p_abp_attribute29
      ,p_abp_attribute30                =>  p_abp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Aplcn_To_Benefit_Pool'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Aplcn_To_Benefit_Pool
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
  p_aplcn_to_bnft_pool_id := l_aplcn_to_bnft_pool_id;
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
    ROLLBACK TO create_Aplcn_To_Benefit_Pool;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_aplcn_to_bnft_pool_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Aplcn_To_Benefit_Pool;
    raise;
    --
end create_Aplcn_To_Benefit_Pool;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Aplcn_To_Benefit_Pool >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Aplcn_To_Benefit_Pool
  (p_validate                       in  boolean   default false
  ,p_aplcn_to_bnft_pool_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_abp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_abp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Aplcn_To_Benefit_Pool';
  l_object_version_number ben_aplcn_to_bnft_pool_f.object_version_number%TYPE;
  l_effective_start_date ben_aplcn_to_bnft_pool_f.effective_start_date%TYPE;
  l_effective_end_date ben_aplcn_to_bnft_pool_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Aplcn_To_Benefit_Pool;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Aplcn_To_Benefit_Pool
    --
    ben_Aplcn_To_Benefit_Pool_bk2.update_Aplcn_To_Benefit_Pool_b
      (
       p_aplcn_to_bnft_pool_id          =>  p_aplcn_to_bnft_pool_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_abp_attribute_category         =>  p_abp_attribute_category
      ,p_abp_attribute1                 =>  p_abp_attribute1
      ,p_abp_attribute2                 =>  p_abp_attribute2
      ,p_abp_attribute3                 =>  p_abp_attribute3
      ,p_abp_attribute4                 =>  p_abp_attribute4
      ,p_abp_attribute5                 =>  p_abp_attribute5
      ,p_abp_attribute6                 =>  p_abp_attribute6
      ,p_abp_attribute7                 =>  p_abp_attribute7
      ,p_abp_attribute8                 =>  p_abp_attribute8
      ,p_abp_attribute9                 =>  p_abp_attribute9
      ,p_abp_attribute10                =>  p_abp_attribute10
      ,p_abp_attribute11                =>  p_abp_attribute11
      ,p_abp_attribute12                =>  p_abp_attribute12
      ,p_abp_attribute13                =>  p_abp_attribute13
      ,p_abp_attribute14                =>  p_abp_attribute14
      ,p_abp_attribute15                =>  p_abp_attribute15
      ,p_abp_attribute16                =>  p_abp_attribute16
      ,p_abp_attribute17                =>  p_abp_attribute17
      ,p_abp_attribute18                =>  p_abp_attribute18
      ,p_abp_attribute19                =>  p_abp_attribute19
      ,p_abp_attribute20                =>  p_abp_attribute20
      ,p_abp_attribute21                =>  p_abp_attribute21
      ,p_abp_attribute22                =>  p_abp_attribute22
      ,p_abp_attribute23                =>  p_abp_attribute23
      ,p_abp_attribute24                =>  p_abp_attribute24
      ,p_abp_attribute25                =>  p_abp_attribute25
      ,p_abp_attribute26                =>  p_abp_attribute26
      ,p_abp_attribute27                =>  p_abp_attribute27
      ,p_abp_attribute28                =>  p_abp_attribute28
      ,p_abp_attribute29                =>  p_abp_attribute29
      ,p_abp_attribute30                =>  p_abp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Aplcn_To_Benefit_Pool'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Aplcn_To_Benefit_Pool
    --
  end;
  --
  ben_abp_upd.upd
    (
     p_aplcn_to_bnft_pool_id         => p_aplcn_to_bnft_pool_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_business_group_id             => p_business_group_id
    ,p_abp_attribute_category        => p_abp_attribute_category
    ,p_abp_attribute1                => p_abp_attribute1
    ,p_abp_attribute2                => p_abp_attribute2
    ,p_abp_attribute3                => p_abp_attribute3
    ,p_abp_attribute4                => p_abp_attribute4
    ,p_abp_attribute5                => p_abp_attribute5
    ,p_abp_attribute6                => p_abp_attribute6
    ,p_abp_attribute7                => p_abp_attribute7
    ,p_abp_attribute8                => p_abp_attribute8
    ,p_abp_attribute9                => p_abp_attribute9
    ,p_abp_attribute10               => p_abp_attribute10
    ,p_abp_attribute11               => p_abp_attribute11
    ,p_abp_attribute12               => p_abp_attribute12
    ,p_abp_attribute13               => p_abp_attribute13
    ,p_abp_attribute14               => p_abp_attribute14
    ,p_abp_attribute15               => p_abp_attribute15
    ,p_abp_attribute16               => p_abp_attribute16
    ,p_abp_attribute17               => p_abp_attribute17
    ,p_abp_attribute18               => p_abp_attribute18
    ,p_abp_attribute19               => p_abp_attribute19
    ,p_abp_attribute20               => p_abp_attribute20
    ,p_abp_attribute21               => p_abp_attribute21
    ,p_abp_attribute22               => p_abp_attribute22
    ,p_abp_attribute23               => p_abp_attribute23
    ,p_abp_attribute24               => p_abp_attribute24
    ,p_abp_attribute25               => p_abp_attribute25
    ,p_abp_attribute26               => p_abp_attribute26
    ,p_abp_attribute27               => p_abp_attribute27
    ,p_abp_attribute28               => p_abp_attribute28
    ,p_abp_attribute29               => p_abp_attribute29
    ,p_abp_attribute30               => p_abp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Aplcn_To_Benefit_Pool
    --
    ben_Aplcn_To_Benefit_Pool_bk2.update_Aplcn_To_Benefit_Pool_a
      (
       p_aplcn_to_bnft_pool_id          =>  p_aplcn_to_bnft_pool_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_abp_attribute_category         =>  p_abp_attribute_category
      ,p_abp_attribute1                 =>  p_abp_attribute1
      ,p_abp_attribute2                 =>  p_abp_attribute2
      ,p_abp_attribute3                 =>  p_abp_attribute3
      ,p_abp_attribute4                 =>  p_abp_attribute4
      ,p_abp_attribute5                 =>  p_abp_attribute5
      ,p_abp_attribute6                 =>  p_abp_attribute6
      ,p_abp_attribute7                 =>  p_abp_attribute7
      ,p_abp_attribute8                 =>  p_abp_attribute8
      ,p_abp_attribute9                 =>  p_abp_attribute9
      ,p_abp_attribute10                =>  p_abp_attribute10
      ,p_abp_attribute11                =>  p_abp_attribute11
      ,p_abp_attribute12                =>  p_abp_attribute12
      ,p_abp_attribute13                =>  p_abp_attribute13
      ,p_abp_attribute14                =>  p_abp_attribute14
      ,p_abp_attribute15                =>  p_abp_attribute15
      ,p_abp_attribute16                =>  p_abp_attribute16
      ,p_abp_attribute17                =>  p_abp_attribute17
      ,p_abp_attribute18                =>  p_abp_attribute18
      ,p_abp_attribute19                =>  p_abp_attribute19
      ,p_abp_attribute20                =>  p_abp_attribute20
      ,p_abp_attribute21                =>  p_abp_attribute21
      ,p_abp_attribute22                =>  p_abp_attribute22
      ,p_abp_attribute23                =>  p_abp_attribute23
      ,p_abp_attribute24                =>  p_abp_attribute24
      ,p_abp_attribute25                =>  p_abp_attribute25
      ,p_abp_attribute26                =>  p_abp_attribute26
      ,p_abp_attribute27                =>  p_abp_attribute27
      ,p_abp_attribute28                =>  p_abp_attribute28
      ,p_abp_attribute29                =>  p_abp_attribute29
      ,p_abp_attribute30                =>  p_abp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Aplcn_To_Benefit_Pool'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Aplcn_To_Benefit_Pool
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
    ROLLBACK TO update_Aplcn_To_Benefit_Pool;
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
    ROLLBACK TO update_Aplcn_To_Benefit_Pool;
    raise;
    --
end update_Aplcn_To_Benefit_Pool;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Aplcn_To_Benefit_Pool >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Aplcn_To_Benefit_Pool
  (p_validate                       in  boolean  default false
  ,p_aplcn_to_bnft_pool_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Aplcn_To_Benefit_Pool';
  l_object_version_number ben_aplcn_to_bnft_pool_f.object_version_number%TYPE;
  l_effective_start_date ben_aplcn_to_bnft_pool_f.effective_start_date%TYPE;
  l_effective_end_date ben_aplcn_to_bnft_pool_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Aplcn_To_Benefit_Pool;
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
    -- Start of API User Hook for the before hook of delete_Aplcn_To_Benefit_Pool
    --
    ben_Aplcn_To_Benefit_Pool_bk3.delete_Aplcn_To_Benefit_Pool_b
      (
       p_aplcn_to_bnft_pool_id          =>  p_aplcn_to_bnft_pool_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Aplcn_To_Benefit_Pool'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Aplcn_To_Benefit_Pool
    --
  end;
  --
  ben_abp_del.del
    (
     p_aplcn_to_bnft_pool_id         => p_aplcn_to_bnft_pool_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Aplcn_To_Benefit_Pool
    --
    ben_Aplcn_To_Benefit_Pool_bk3.delete_Aplcn_To_Benefit_Pool_a
      (
       p_aplcn_to_bnft_pool_id          =>  p_aplcn_to_bnft_pool_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Aplcn_To_Benefit_Pool'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Aplcn_To_Benefit_Pool
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
    ROLLBACK TO delete_Aplcn_To_Benefit_Pool;
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
    ROLLBACK TO delete_Aplcn_To_Benefit_Pool;
    raise;
    --
end delete_Aplcn_To_Benefit_Pool;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_aplcn_to_bnft_pool_id                   in     number
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
  ben_abp_shd.lck
    (
      p_aplcn_to_bnft_pool_id                 => p_aplcn_to_bnft_pool_id
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
end ben_Aplcn_To_Benefit_Pool_api;

/
