--------------------------------------------------------
--  DDL for Package Body BEN_ACTY_RT_DEDUCT_SCHED_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ACTY_RT_DEDUCT_SCHED_API" as
/* $Header: beadsapi.pkb 120.0 2005/05/28 00:22:01 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ACTY_RT_DEDUCT_SCHED_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ACTY_RT_DEDUCT_SCHED >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ACTY_RT_DEDUCT_SCHED
  (p_validate                       in  boolean   default false
  ,p_acty_rt_ded_sched_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_ded_sched_py_freq_id           in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_ded_sched_rl                   in  number    default null
  ,p_ded_sched_cd                   in  varchar2  default null
  ,p_ads_attribute_category         in  varchar2  default null
  ,p_ads_attribute1                 in  varchar2  default null
  ,p_ads_attribute2                 in  varchar2  default null
  ,p_ads_attribute3                 in  varchar2  default null
  ,p_ads_attribute4                 in  varchar2  default null
  ,p_ads_attribute5                 in  varchar2  default null
  ,p_ads_attribute6                 in  varchar2  default null
  ,p_ads_attribute7                 in  varchar2  default null
  ,p_ads_attribute8                 in  varchar2  default null
  ,p_ads_attribute9                 in  varchar2  default null
  ,p_ads_attribute10                in  varchar2  default null
  ,p_ads_attribute11                in  varchar2  default null
  ,p_ads_attribute12                in  varchar2  default null
  ,p_ads_attribute13                in  varchar2  default null
  ,p_ads_attribute14                in  varchar2  default null
  ,p_ads_attribute15                in  varchar2  default null
  ,p_ads_attribute16                in  varchar2  default null
  ,p_ads_attribute17                in  varchar2  default null
  ,p_ads_attribute18                in  varchar2  default null
  ,p_ads_attribute19                in  varchar2  default null
  ,p_ads_attribute20                in  varchar2  default null
  ,p_ads_attribute21                in  varchar2  default null
  ,p_ads_attribute22                in  varchar2  default null
  ,p_ads_attribute23                in  varchar2  default null
  ,p_ads_attribute24                in  varchar2  default null
  ,p_ads_attribute25                in  varchar2  default null
  ,p_ads_attribute26                in  varchar2  default null
  ,p_ads_attribute27                in  varchar2  default null
  ,p_ads_attribute28                in  varchar2  default null
  ,p_ads_attribute29                in  varchar2  default null
  ,p_ads_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_acty_rt_ded_sched_id ben_acty_rt_ded_sched_f.acty_rt_ded_sched_id%TYPE;
  l_effective_start_date ben_acty_rt_ded_sched_f.effective_start_date%TYPE;
  l_effective_end_date ben_acty_rt_ded_sched_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ACTY_RT_DEDUCT_SCHED';
  l_object_version_number ben_acty_rt_ded_sched_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ACTY_RT_DEDUCT_SCHED;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ACTY_RT_DEDUCT_SCHED
    --
    ben_ACTY_RT_DEDUCT_SCHED_bk1.create_ACTY_RT_DEDUCT_SCHED_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_ded_sched_py_freq_id           =>  p_ded_sched_py_freq_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_ded_sched_rl                   =>  p_ded_sched_rl
      ,p_ded_sched_cd                   =>  p_ded_sched_cd
      ,p_ads_attribute_category         =>  p_ads_attribute_category
      ,p_ads_attribute1                 =>  p_ads_attribute1
      ,p_ads_attribute2                 =>  p_ads_attribute2
      ,p_ads_attribute3                 =>  p_ads_attribute3
      ,p_ads_attribute4                 =>  p_ads_attribute4
      ,p_ads_attribute5                 =>  p_ads_attribute5
      ,p_ads_attribute6                 =>  p_ads_attribute6
      ,p_ads_attribute7                 =>  p_ads_attribute7
      ,p_ads_attribute8                 =>  p_ads_attribute8
      ,p_ads_attribute9                 =>  p_ads_attribute9
      ,p_ads_attribute10                =>  p_ads_attribute10
      ,p_ads_attribute11                =>  p_ads_attribute11
      ,p_ads_attribute12                =>  p_ads_attribute12
      ,p_ads_attribute13                =>  p_ads_attribute13
      ,p_ads_attribute14                =>  p_ads_attribute14
      ,p_ads_attribute15                =>  p_ads_attribute15
      ,p_ads_attribute16                =>  p_ads_attribute16
      ,p_ads_attribute17                =>  p_ads_attribute17
      ,p_ads_attribute18                =>  p_ads_attribute18
      ,p_ads_attribute19                =>  p_ads_attribute19
      ,p_ads_attribute20                =>  p_ads_attribute20
      ,p_ads_attribute21                =>  p_ads_attribute21
      ,p_ads_attribute22                =>  p_ads_attribute22
      ,p_ads_attribute23                =>  p_ads_attribute23
      ,p_ads_attribute24                =>  p_ads_attribute24
      ,p_ads_attribute25                =>  p_ads_attribute25
      ,p_ads_attribute26                =>  p_ads_attribute26
      ,p_ads_attribute27                =>  p_ads_attribute27
      ,p_ads_attribute28                =>  p_ads_attribute28
      ,p_ads_attribute29                =>  p_ads_attribute29
      ,p_ads_attribute30                =>  p_ads_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ACTY_RT_DEDUCT_SCHED'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ACTY_RT_DEDUCT_SCHED
    --
  end;
  --
  ben_ads_ins.ins
    (
     p_acty_rt_ded_sched_id          => l_acty_rt_ded_sched_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_ded_sched_py_freq_id          => p_ded_sched_py_freq_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_ded_sched_rl                  => p_ded_sched_rl
    ,p_ded_sched_cd                  => p_ded_sched_cd
    ,p_ads_attribute_category        => p_ads_attribute_category
    ,p_ads_attribute1                => p_ads_attribute1
    ,p_ads_attribute2                => p_ads_attribute2
    ,p_ads_attribute3                => p_ads_attribute3
    ,p_ads_attribute4                => p_ads_attribute4
    ,p_ads_attribute5                => p_ads_attribute5
    ,p_ads_attribute6                => p_ads_attribute6
    ,p_ads_attribute7                => p_ads_attribute7
    ,p_ads_attribute8                => p_ads_attribute8
    ,p_ads_attribute9                => p_ads_attribute9
    ,p_ads_attribute10               => p_ads_attribute10
    ,p_ads_attribute11               => p_ads_attribute11
    ,p_ads_attribute12               => p_ads_attribute12
    ,p_ads_attribute13               => p_ads_attribute13
    ,p_ads_attribute14               => p_ads_attribute14
    ,p_ads_attribute15               => p_ads_attribute15
    ,p_ads_attribute16               => p_ads_attribute16
    ,p_ads_attribute17               => p_ads_attribute17
    ,p_ads_attribute18               => p_ads_attribute18
    ,p_ads_attribute19               => p_ads_attribute19
    ,p_ads_attribute20               => p_ads_attribute20
    ,p_ads_attribute21               => p_ads_attribute21
    ,p_ads_attribute22               => p_ads_attribute22
    ,p_ads_attribute23               => p_ads_attribute23
    ,p_ads_attribute24               => p_ads_attribute24
    ,p_ads_attribute25               => p_ads_attribute25
    ,p_ads_attribute26               => p_ads_attribute26
    ,p_ads_attribute27               => p_ads_attribute27
    ,p_ads_attribute28               => p_ads_attribute28
    ,p_ads_attribute29               => p_ads_attribute29
    ,p_ads_attribute30               => p_ads_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ACTY_RT_DEDUCT_SCHED
    --
    ben_ACTY_RT_DEDUCT_SCHED_bk1.create_ACTY_RT_DEDUCT_SCHED_a
      (
       p_acty_rt_ded_sched_id           =>  l_acty_rt_ded_sched_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_ded_sched_py_freq_id           =>  p_ded_sched_py_freq_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_ded_sched_rl                   =>  p_ded_sched_rl
      ,p_ded_sched_cd                   =>  p_ded_sched_cd
      ,p_ads_attribute_category         =>  p_ads_attribute_category
      ,p_ads_attribute1                 =>  p_ads_attribute1
      ,p_ads_attribute2                 =>  p_ads_attribute2
      ,p_ads_attribute3                 =>  p_ads_attribute3
      ,p_ads_attribute4                 =>  p_ads_attribute4
      ,p_ads_attribute5                 =>  p_ads_attribute5
      ,p_ads_attribute6                 =>  p_ads_attribute6
      ,p_ads_attribute7                 =>  p_ads_attribute7
      ,p_ads_attribute8                 =>  p_ads_attribute8
      ,p_ads_attribute9                 =>  p_ads_attribute9
      ,p_ads_attribute10                =>  p_ads_attribute10
      ,p_ads_attribute11                =>  p_ads_attribute11
      ,p_ads_attribute12                =>  p_ads_attribute12
      ,p_ads_attribute13                =>  p_ads_attribute13
      ,p_ads_attribute14                =>  p_ads_attribute14
      ,p_ads_attribute15                =>  p_ads_attribute15
      ,p_ads_attribute16                =>  p_ads_attribute16
      ,p_ads_attribute17                =>  p_ads_attribute17
      ,p_ads_attribute18                =>  p_ads_attribute18
      ,p_ads_attribute19                =>  p_ads_attribute19
      ,p_ads_attribute20                =>  p_ads_attribute20
      ,p_ads_attribute21                =>  p_ads_attribute21
      ,p_ads_attribute22                =>  p_ads_attribute22
      ,p_ads_attribute23                =>  p_ads_attribute23
      ,p_ads_attribute24                =>  p_ads_attribute24
      ,p_ads_attribute25                =>  p_ads_attribute25
      ,p_ads_attribute26                =>  p_ads_attribute26
      ,p_ads_attribute27                =>  p_ads_attribute27
      ,p_ads_attribute28                =>  p_ads_attribute28
      ,p_ads_attribute29                =>  p_ads_attribute29
      ,p_ads_attribute30                =>  p_ads_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ACTY_RT_DEDUCT_SCHED'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ACTY_RT_DEDUCT_SCHED
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
  p_acty_rt_ded_sched_id := l_acty_rt_ded_sched_id;
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
    ROLLBACK TO create_ACTY_RT_DEDUCT_SCHED;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_acty_rt_ded_sched_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ACTY_RT_DEDUCT_SCHED;
    -- NOCOPY Changes
    p_acty_rt_ded_sched_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := null ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_ACTY_RT_DEDUCT_SCHED;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ACTY_RT_DEDUCT_SCHED >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ACTY_RT_DEDUCT_SCHED
  (p_validate                       in  boolean   default false
  ,p_acty_rt_ded_sched_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ded_sched_py_freq_id           in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_ded_sched_rl                   in  number    default hr_api.g_number
  ,p_ded_sched_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ads_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ACTY_RT_DEDUCT_SCHED';
  l_object_version_number ben_acty_rt_ded_sched_f.object_version_number%TYPE;
  l_effective_start_date ben_acty_rt_ded_sched_f.effective_start_date%TYPE;
  l_effective_end_date ben_acty_rt_ded_sched_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ACTY_RT_DEDUCT_SCHED;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ACTY_RT_DEDUCT_SCHED
    --
    ben_ACTY_RT_DEDUCT_SCHED_bk2.update_ACTY_RT_DEDUCT_SCHED_b
      (
       p_acty_rt_ded_sched_id           =>  p_acty_rt_ded_sched_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ded_sched_py_freq_id           =>  p_ded_sched_py_freq_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_ded_sched_rl                   =>  p_ded_sched_rl
      ,p_ded_sched_cd                   =>  p_ded_sched_cd
      ,p_ads_attribute_category         =>  p_ads_attribute_category
      ,p_ads_attribute1                 =>  p_ads_attribute1
      ,p_ads_attribute2                 =>  p_ads_attribute2
      ,p_ads_attribute3                 =>  p_ads_attribute3
      ,p_ads_attribute4                 =>  p_ads_attribute4
      ,p_ads_attribute5                 =>  p_ads_attribute5
      ,p_ads_attribute6                 =>  p_ads_attribute6
      ,p_ads_attribute7                 =>  p_ads_attribute7
      ,p_ads_attribute8                 =>  p_ads_attribute8
      ,p_ads_attribute9                 =>  p_ads_attribute9
      ,p_ads_attribute10                =>  p_ads_attribute10
      ,p_ads_attribute11                =>  p_ads_attribute11
      ,p_ads_attribute12                =>  p_ads_attribute12
      ,p_ads_attribute13                =>  p_ads_attribute13
      ,p_ads_attribute14                =>  p_ads_attribute14
      ,p_ads_attribute15                =>  p_ads_attribute15
      ,p_ads_attribute16                =>  p_ads_attribute16
      ,p_ads_attribute17                =>  p_ads_attribute17
      ,p_ads_attribute18                =>  p_ads_attribute18
      ,p_ads_attribute19                =>  p_ads_attribute19
      ,p_ads_attribute20                =>  p_ads_attribute20
      ,p_ads_attribute21                =>  p_ads_attribute21
      ,p_ads_attribute22                =>  p_ads_attribute22
      ,p_ads_attribute23                =>  p_ads_attribute23
      ,p_ads_attribute24                =>  p_ads_attribute24
      ,p_ads_attribute25                =>  p_ads_attribute25
      ,p_ads_attribute26                =>  p_ads_attribute26
      ,p_ads_attribute27                =>  p_ads_attribute27
      ,p_ads_attribute28                =>  p_ads_attribute28
      ,p_ads_attribute29                =>  p_ads_attribute29
      ,p_ads_attribute30                =>  p_ads_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ACTY_RT_DEDUCT_SCHED'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ACTY_RT_DEDUCT_SCHED
    --
  end;
  --
  ben_ads_upd.upd
    (
     p_acty_rt_ded_sched_id          => p_acty_rt_ded_sched_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_ded_sched_py_freq_id          => p_ded_sched_py_freq_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_ded_sched_rl                  => p_ded_sched_rl
    ,p_ded_sched_cd                  => p_ded_sched_cd
    ,p_ads_attribute_category        => p_ads_attribute_category
    ,p_ads_attribute1                => p_ads_attribute1
    ,p_ads_attribute2                => p_ads_attribute2
    ,p_ads_attribute3                => p_ads_attribute3
    ,p_ads_attribute4                => p_ads_attribute4
    ,p_ads_attribute5                => p_ads_attribute5
    ,p_ads_attribute6                => p_ads_attribute6
    ,p_ads_attribute7                => p_ads_attribute7
    ,p_ads_attribute8                => p_ads_attribute8
    ,p_ads_attribute9                => p_ads_attribute9
    ,p_ads_attribute10               => p_ads_attribute10
    ,p_ads_attribute11               => p_ads_attribute11
    ,p_ads_attribute12               => p_ads_attribute12
    ,p_ads_attribute13               => p_ads_attribute13
    ,p_ads_attribute14               => p_ads_attribute14
    ,p_ads_attribute15               => p_ads_attribute15
    ,p_ads_attribute16               => p_ads_attribute16
    ,p_ads_attribute17               => p_ads_attribute17
    ,p_ads_attribute18               => p_ads_attribute18
    ,p_ads_attribute19               => p_ads_attribute19
    ,p_ads_attribute20               => p_ads_attribute20
    ,p_ads_attribute21               => p_ads_attribute21
    ,p_ads_attribute22               => p_ads_attribute22
    ,p_ads_attribute23               => p_ads_attribute23
    ,p_ads_attribute24               => p_ads_attribute24
    ,p_ads_attribute25               => p_ads_attribute25
    ,p_ads_attribute26               => p_ads_attribute26
    ,p_ads_attribute27               => p_ads_attribute27
    ,p_ads_attribute28               => p_ads_attribute28
    ,p_ads_attribute29               => p_ads_attribute29
    ,p_ads_attribute30               => p_ads_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ACTY_RT_DEDUCT_SCHED
    --
    ben_ACTY_RT_DEDUCT_SCHED_bk2.update_ACTY_RT_DEDUCT_SCHED_a
      (
       p_acty_rt_ded_sched_id           =>  p_acty_rt_ded_sched_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_ded_sched_py_freq_id           =>  p_ded_sched_py_freq_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_ded_sched_rl                   =>  p_ded_sched_rl
      ,p_ded_sched_cd                   =>  p_ded_sched_cd
      ,p_ads_attribute_category         =>  p_ads_attribute_category
      ,p_ads_attribute1                 =>  p_ads_attribute1
      ,p_ads_attribute2                 =>  p_ads_attribute2
      ,p_ads_attribute3                 =>  p_ads_attribute3
      ,p_ads_attribute4                 =>  p_ads_attribute4
      ,p_ads_attribute5                 =>  p_ads_attribute5
      ,p_ads_attribute6                 =>  p_ads_attribute6
      ,p_ads_attribute7                 =>  p_ads_attribute7
      ,p_ads_attribute8                 =>  p_ads_attribute8
      ,p_ads_attribute9                 =>  p_ads_attribute9
      ,p_ads_attribute10                =>  p_ads_attribute10
      ,p_ads_attribute11                =>  p_ads_attribute11
      ,p_ads_attribute12                =>  p_ads_attribute12
      ,p_ads_attribute13                =>  p_ads_attribute13
      ,p_ads_attribute14                =>  p_ads_attribute14
      ,p_ads_attribute15                =>  p_ads_attribute15
      ,p_ads_attribute16                =>  p_ads_attribute16
      ,p_ads_attribute17                =>  p_ads_attribute17
      ,p_ads_attribute18                =>  p_ads_attribute18
      ,p_ads_attribute19                =>  p_ads_attribute19
      ,p_ads_attribute20                =>  p_ads_attribute20
      ,p_ads_attribute21                =>  p_ads_attribute21
      ,p_ads_attribute22                =>  p_ads_attribute22
      ,p_ads_attribute23                =>  p_ads_attribute23
      ,p_ads_attribute24                =>  p_ads_attribute24
      ,p_ads_attribute25                =>  p_ads_attribute25
      ,p_ads_attribute26                =>  p_ads_attribute26
      ,p_ads_attribute27                =>  p_ads_attribute27
      ,p_ads_attribute28                =>  p_ads_attribute28
      ,p_ads_attribute29                =>  p_ads_attribute29
      ,p_ads_attribute30                =>  p_ads_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ACTY_RT_DEDUCT_SCHED'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ACTY_RT_DEDUCT_SCHED
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
    ROLLBACK TO update_ACTY_RT_DEDUCT_SCHED;
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
    ROLLBACK TO update_ACTY_RT_DEDUCT_SCHED;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_ACTY_RT_DEDUCT_SCHED;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ACTY_RT_DEDUCT_SCHED >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ACTY_RT_DEDUCT_SCHED
  (p_validate                       in  boolean  default false
  ,p_acty_rt_ded_sched_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ACTY_RT_DEDUCT_SCHED';
  l_object_version_number ben_acty_rt_ded_sched_f.object_version_number%TYPE;
  l_effective_start_date ben_acty_rt_ded_sched_f.effective_start_date%TYPE;
  l_effective_end_date ben_acty_rt_ded_sched_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ACTY_RT_DEDUCT_SCHED;
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
    -- Start of API User Hook for the before hook of delete_ACTY_RT_DEDUCT_SCHED
    --
    ben_ACTY_RT_DEDUCT_SCHED_bk3.delete_ACTY_RT_DEDUCT_SCHED_b
      (
       p_acty_rt_ded_sched_id           =>  p_acty_rt_ded_sched_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ACTY_RT_DEDUCT_SCHED'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ACTY_RT_DEDUCT_SCHED
    --
  end;
  --
  ben_ads_del.del
    (
     p_acty_rt_ded_sched_id          => p_acty_rt_ded_sched_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ACTY_RT_DEDUCT_SCHED
    --
    ben_ACTY_RT_DEDUCT_SCHED_bk3.delete_ACTY_RT_DEDUCT_SCHED_a
      (
       p_acty_rt_ded_sched_id           =>  p_acty_rt_ded_sched_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ACTY_RT_DEDUCT_SCHED'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ACTY_RT_DEDUCT_SCHED
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
    ROLLBACK TO delete_ACTY_RT_DEDUCT_SCHED;
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
    ROLLBACK TO delete_ACTY_RT_DEDUCT_SCHED;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_ACTY_RT_DEDUCT_SCHED;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_acty_rt_ded_sched_id                   in     number
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
  ben_ads_shd.lck
    (
      p_acty_rt_ded_sched_id                 => p_acty_rt_ded_sched_id
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
end ben_ACTY_RT_DEDUCT_SCHED_api;

/
