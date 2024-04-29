--------------------------------------------------------
--  DDL for Package Body BEN_DEDUCT_SCHED_PAY_FREQ_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DEDUCT_SCHED_PAY_FREQ_API" as
/* $Header: bedsqapi.pkb 115.4 2002/12/11 10:38:18 lakrish ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_DEDUCT_SCHED_PAY_FREQ_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_DEDUCT_SCHED_PAY_FREQ >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_DEDUCT_SCHED_PAY_FREQ
  (p_validate                       in  boolean   default false
  ,p_ded_sched_py_freq_id           out nocopy number
  ,p_py_freq_cd                     in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_acty_rt_ded_sched_id           in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_dsq_attribute_category         in  varchar2  default null
  ,p_dsq_attribute1                 in  varchar2  default null
  ,p_dsq_attribute2                 in  varchar2  default null
  ,p_dsq_attribute3                 in  varchar2  default null
  ,p_dsq_attribute4                 in  varchar2  default null
  ,p_dsq_attribute5                 in  varchar2  default null
  ,p_dsq_attribute6                 in  varchar2  default null
  ,p_dsq_attribute7                 in  varchar2  default null
  ,p_dsq_attribute8                 in  varchar2  default null
  ,p_dsq_attribute9                 in  varchar2  default null
  ,p_dsq_attribute10                in  varchar2  default null
  ,p_dsq_attribute11                in  varchar2  default null
  ,p_dsq_attribute12                in  varchar2  default null
  ,p_dsq_attribute13                in  varchar2  default null
  ,p_dsq_attribute14                in  varchar2  default null
  ,p_dsq_attribute15                in  varchar2  default null
  ,p_dsq_attribute16                in  varchar2  default null
  ,p_dsq_attribute17                in  varchar2  default null
  ,p_dsq_attribute18                in  varchar2  default null
  ,p_dsq_attribute19                in  varchar2  default null
  ,p_dsq_attribute20                in  varchar2  default null
  ,p_dsq_attribute21                in  varchar2  default null
  ,p_dsq_attribute22                in  varchar2  default null
  ,p_dsq_attribute23                in  varchar2  default null
  ,p_dsq_attribute24                in  varchar2  default null
  ,p_dsq_attribute25                in  varchar2  default null
  ,p_dsq_attribute26                in  varchar2  default null
  ,p_dsq_attribute27                in  varchar2  default null
  ,p_dsq_attribute28                in  varchar2  default null
  ,p_dsq_attribute29                in  varchar2  default null
  ,p_dsq_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ded_sched_py_freq_id ben_ded_sched_py_freq.ded_sched_py_freq_id%TYPE;
  l_proc varchar2(72) := g_package||'create_DEDUCT_SCHED_PAY_FREQ';
  l_object_version_number ben_ded_sched_py_freq.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_DEDUCT_SCHED_PAY_FREQ;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_DEDUCT_SCHED_PAY_FREQ
    --
    ben_DEDUCT_SCHED_PAY_FREQ_bk1.create_DEDUCT_SCHED_PAY_FREQ_b
      (
       p_py_freq_cd                     =>  p_py_freq_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_acty_rt_ded_sched_id           =>  p_acty_rt_ded_sched_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dsq_attribute_category         =>  p_dsq_attribute_category
      ,p_dsq_attribute1                 =>  p_dsq_attribute1
      ,p_dsq_attribute2                 =>  p_dsq_attribute2
      ,p_dsq_attribute3                 =>  p_dsq_attribute3
      ,p_dsq_attribute4                 =>  p_dsq_attribute4
      ,p_dsq_attribute5                 =>  p_dsq_attribute5
      ,p_dsq_attribute6                 =>  p_dsq_attribute6
      ,p_dsq_attribute7                 =>  p_dsq_attribute7
      ,p_dsq_attribute8                 =>  p_dsq_attribute8
      ,p_dsq_attribute9                 =>  p_dsq_attribute9
      ,p_dsq_attribute10                =>  p_dsq_attribute10
      ,p_dsq_attribute11                =>  p_dsq_attribute11
      ,p_dsq_attribute12                =>  p_dsq_attribute12
      ,p_dsq_attribute13                =>  p_dsq_attribute13
      ,p_dsq_attribute14                =>  p_dsq_attribute14
      ,p_dsq_attribute15                =>  p_dsq_attribute15
      ,p_dsq_attribute16                =>  p_dsq_attribute16
      ,p_dsq_attribute17                =>  p_dsq_attribute17
      ,p_dsq_attribute18                =>  p_dsq_attribute18
      ,p_dsq_attribute19                =>  p_dsq_attribute19
      ,p_dsq_attribute20                =>  p_dsq_attribute20
      ,p_dsq_attribute21                =>  p_dsq_attribute21
      ,p_dsq_attribute22                =>  p_dsq_attribute22
      ,p_dsq_attribute23                =>  p_dsq_attribute23
      ,p_dsq_attribute24                =>  p_dsq_attribute24
      ,p_dsq_attribute25                =>  p_dsq_attribute25
      ,p_dsq_attribute26                =>  p_dsq_attribute26
      ,p_dsq_attribute27                =>  p_dsq_attribute27
      ,p_dsq_attribute28                =>  p_dsq_attribute28
      ,p_dsq_attribute29                =>  p_dsq_attribute29
      ,p_dsq_attribute30                =>  p_dsq_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_DEDUCT_SCHED_PAY_FREQ'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_DEDUCT_SCHED_PAY_FREQ
    --
  end;
  --
  ben_dsq_ins.ins
    (
     p_ded_sched_py_freq_id          => l_ded_sched_py_freq_id
    ,p_py_freq_cd                    => p_py_freq_cd
    ,p_dflt_flag                     => p_dflt_flag
    ,p_acty_rt_ded_sched_id          => p_acty_rt_ded_sched_id
    ,p_business_group_id             => p_business_group_id
    ,p_dsq_attribute_category        => p_dsq_attribute_category
    ,p_dsq_attribute1                => p_dsq_attribute1
    ,p_dsq_attribute2                => p_dsq_attribute2
    ,p_dsq_attribute3                => p_dsq_attribute3
    ,p_dsq_attribute4                => p_dsq_attribute4
    ,p_dsq_attribute5                => p_dsq_attribute5
    ,p_dsq_attribute6                => p_dsq_attribute6
    ,p_dsq_attribute7                => p_dsq_attribute7
    ,p_dsq_attribute8                => p_dsq_attribute8
    ,p_dsq_attribute9                => p_dsq_attribute9
    ,p_dsq_attribute10               => p_dsq_attribute10
    ,p_dsq_attribute11               => p_dsq_attribute11
    ,p_dsq_attribute12               => p_dsq_attribute12
    ,p_dsq_attribute13               => p_dsq_attribute13
    ,p_dsq_attribute14               => p_dsq_attribute14
    ,p_dsq_attribute15               => p_dsq_attribute15
    ,p_dsq_attribute16               => p_dsq_attribute16
    ,p_dsq_attribute17               => p_dsq_attribute17
    ,p_dsq_attribute18               => p_dsq_attribute18
    ,p_dsq_attribute19               => p_dsq_attribute19
    ,p_dsq_attribute20               => p_dsq_attribute20
    ,p_dsq_attribute21               => p_dsq_attribute21
    ,p_dsq_attribute22               => p_dsq_attribute22
    ,p_dsq_attribute23               => p_dsq_attribute23
    ,p_dsq_attribute24               => p_dsq_attribute24
    ,p_dsq_attribute25               => p_dsq_attribute25
    ,p_dsq_attribute26               => p_dsq_attribute26
    ,p_dsq_attribute27               => p_dsq_attribute27
    ,p_dsq_attribute28               => p_dsq_attribute28
    ,p_dsq_attribute29               => p_dsq_attribute29
    ,p_dsq_attribute30               => p_dsq_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_DEDUCT_SCHED_PAY_FREQ
    --
    ben_DEDUCT_SCHED_PAY_FREQ_bk1.create_DEDUCT_SCHED_PAY_FREQ_a
      (
       p_ded_sched_py_freq_id           =>  l_ded_sched_py_freq_id
      ,p_py_freq_cd                     =>  p_py_freq_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_acty_rt_ded_sched_id           =>  p_acty_rt_ded_sched_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dsq_attribute_category         =>  p_dsq_attribute_category
      ,p_dsq_attribute1                 =>  p_dsq_attribute1
      ,p_dsq_attribute2                 =>  p_dsq_attribute2
      ,p_dsq_attribute3                 =>  p_dsq_attribute3
      ,p_dsq_attribute4                 =>  p_dsq_attribute4
      ,p_dsq_attribute5                 =>  p_dsq_attribute5
      ,p_dsq_attribute6                 =>  p_dsq_attribute6
      ,p_dsq_attribute7                 =>  p_dsq_attribute7
      ,p_dsq_attribute8                 =>  p_dsq_attribute8
      ,p_dsq_attribute9                 =>  p_dsq_attribute9
      ,p_dsq_attribute10                =>  p_dsq_attribute10
      ,p_dsq_attribute11                =>  p_dsq_attribute11
      ,p_dsq_attribute12                =>  p_dsq_attribute12
      ,p_dsq_attribute13                =>  p_dsq_attribute13
      ,p_dsq_attribute14                =>  p_dsq_attribute14
      ,p_dsq_attribute15                =>  p_dsq_attribute15
      ,p_dsq_attribute16                =>  p_dsq_attribute16
      ,p_dsq_attribute17                =>  p_dsq_attribute17
      ,p_dsq_attribute18                =>  p_dsq_attribute18
      ,p_dsq_attribute19                =>  p_dsq_attribute19
      ,p_dsq_attribute20                =>  p_dsq_attribute20
      ,p_dsq_attribute21                =>  p_dsq_attribute21
      ,p_dsq_attribute22                =>  p_dsq_attribute22
      ,p_dsq_attribute23                =>  p_dsq_attribute23
      ,p_dsq_attribute24                =>  p_dsq_attribute24
      ,p_dsq_attribute25                =>  p_dsq_attribute25
      ,p_dsq_attribute26                =>  p_dsq_attribute26
      ,p_dsq_attribute27                =>  p_dsq_attribute27
      ,p_dsq_attribute28                =>  p_dsq_attribute28
      ,p_dsq_attribute29                =>  p_dsq_attribute29
      ,p_dsq_attribute30                =>  p_dsq_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_DEDUCT_SCHED_PAY_FREQ'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_DEDUCT_SCHED_PAY_FREQ
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
  p_ded_sched_py_freq_id := l_ded_sched_py_freq_id;
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
    ROLLBACK TO create_DEDUCT_SCHED_PAY_FREQ;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ded_sched_py_freq_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_DEDUCT_SCHED_PAY_FREQ;

    -- NOCOPY, Reset out parameters
    p_ded_sched_py_freq_id   := null;
    p_object_version_number  := null;

    raise;
    --
end create_DEDUCT_SCHED_PAY_FREQ;
-- ----------------------------------------------------------------------------
-- |------------------------< update_DEDUCT_SCHED_PAY_FREQ >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_DEDUCT_SCHED_PAY_FREQ
  (p_validate                       in  boolean   default false
  ,p_ded_sched_py_freq_id           in  number
  ,p_py_freq_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_acty_rt_ded_sched_id           in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_dsq_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_dsq_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DEDUCT_SCHED_PAY_FREQ';
  l_object_version_number ben_ded_sched_py_freq.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_DEDUCT_SCHED_PAY_FREQ;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_DEDUCT_SCHED_PAY_FREQ
    --
    ben_DEDUCT_SCHED_PAY_FREQ_bk2.update_DEDUCT_SCHED_PAY_FREQ_b
      (
       p_ded_sched_py_freq_id           =>  p_ded_sched_py_freq_id
      ,p_py_freq_cd                     =>  p_py_freq_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_acty_rt_ded_sched_id           =>  p_acty_rt_ded_sched_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dsq_attribute_category         =>  p_dsq_attribute_category
      ,p_dsq_attribute1                 =>  p_dsq_attribute1
      ,p_dsq_attribute2                 =>  p_dsq_attribute2
      ,p_dsq_attribute3                 =>  p_dsq_attribute3
      ,p_dsq_attribute4                 =>  p_dsq_attribute4
      ,p_dsq_attribute5                 =>  p_dsq_attribute5
      ,p_dsq_attribute6                 =>  p_dsq_attribute6
      ,p_dsq_attribute7                 =>  p_dsq_attribute7
      ,p_dsq_attribute8                 =>  p_dsq_attribute8
      ,p_dsq_attribute9                 =>  p_dsq_attribute9
      ,p_dsq_attribute10                =>  p_dsq_attribute10
      ,p_dsq_attribute11                =>  p_dsq_attribute11
      ,p_dsq_attribute12                =>  p_dsq_attribute12
      ,p_dsq_attribute13                =>  p_dsq_attribute13
      ,p_dsq_attribute14                =>  p_dsq_attribute14
      ,p_dsq_attribute15                =>  p_dsq_attribute15
      ,p_dsq_attribute16                =>  p_dsq_attribute16
      ,p_dsq_attribute17                =>  p_dsq_attribute17
      ,p_dsq_attribute18                =>  p_dsq_attribute18
      ,p_dsq_attribute19                =>  p_dsq_attribute19
      ,p_dsq_attribute20                =>  p_dsq_attribute20
      ,p_dsq_attribute21                =>  p_dsq_attribute21
      ,p_dsq_attribute22                =>  p_dsq_attribute22
      ,p_dsq_attribute23                =>  p_dsq_attribute23
      ,p_dsq_attribute24                =>  p_dsq_attribute24
      ,p_dsq_attribute25                =>  p_dsq_attribute25
      ,p_dsq_attribute26                =>  p_dsq_attribute26
      ,p_dsq_attribute27                =>  p_dsq_attribute27
      ,p_dsq_attribute28                =>  p_dsq_attribute28
      ,p_dsq_attribute29                =>  p_dsq_attribute29
      ,p_dsq_attribute30                =>  p_dsq_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DEDUCT_SCHED_PAY_FREQ'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_DEDUCT_SCHED_PAY_FREQ
    --
  end;
  --
  ben_dsq_upd.upd
    (
     p_ded_sched_py_freq_id          => p_ded_sched_py_freq_id
    ,p_py_freq_cd                    => p_py_freq_cd
    ,p_dflt_flag                     => p_dflt_flag
    ,p_acty_rt_ded_sched_id          => p_acty_rt_ded_sched_id
    ,p_business_group_id             => p_business_group_id
    ,p_dsq_attribute_category        => p_dsq_attribute_category
    ,p_dsq_attribute1                => p_dsq_attribute1
    ,p_dsq_attribute2                => p_dsq_attribute2
    ,p_dsq_attribute3                => p_dsq_attribute3
    ,p_dsq_attribute4                => p_dsq_attribute4
    ,p_dsq_attribute5                => p_dsq_attribute5
    ,p_dsq_attribute6                => p_dsq_attribute6
    ,p_dsq_attribute7                => p_dsq_attribute7
    ,p_dsq_attribute8                => p_dsq_attribute8
    ,p_dsq_attribute9                => p_dsq_attribute9
    ,p_dsq_attribute10               => p_dsq_attribute10
    ,p_dsq_attribute11               => p_dsq_attribute11
    ,p_dsq_attribute12               => p_dsq_attribute12
    ,p_dsq_attribute13               => p_dsq_attribute13
    ,p_dsq_attribute14               => p_dsq_attribute14
    ,p_dsq_attribute15               => p_dsq_attribute15
    ,p_dsq_attribute16               => p_dsq_attribute16
    ,p_dsq_attribute17               => p_dsq_attribute17
    ,p_dsq_attribute18               => p_dsq_attribute18
    ,p_dsq_attribute19               => p_dsq_attribute19
    ,p_dsq_attribute20               => p_dsq_attribute20
    ,p_dsq_attribute21               => p_dsq_attribute21
    ,p_dsq_attribute22               => p_dsq_attribute22
    ,p_dsq_attribute23               => p_dsq_attribute23
    ,p_dsq_attribute24               => p_dsq_attribute24
    ,p_dsq_attribute25               => p_dsq_attribute25
    ,p_dsq_attribute26               => p_dsq_attribute26
    ,p_dsq_attribute27               => p_dsq_attribute27
    ,p_dsq_attribute28               => p_dsq_attribute28
    ,p_dsq_attribute29               => p_dsq_attribute29
    ,p_dsq_attribute30               => p_dsq_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_DEDUCT_SCHED_PAY_FREQ
    --
    ben_DEDUCT_SCHED_PAY_FREQ_bk2.update_DEDUCT_SCHED_PAY_FREQ_a
      (
       p_ded_sched_py_freq_id           =>  p_ded_sched_py_freq_id
      ,p_py_freq_cd                     =>  p_py_freq_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_acty_rt_ded_sched_id           =>  p_acty_rt_ded_sched_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dsq_attribute_category         =>  p_dsq_attribute_category
      ,p_dsq_attribute1                 =>  p_dsq_attribute1
      ,p_dsq_attribute2                 =>  p_dsq_attribute2
      ,p_dsq_attribute3                 =>  p_dsq_attribute3
      ,p_dsq_attribute4                 =>  p_dsq_attribute4
      ,p_dsq_attribute5                 =>  p_dsq_attribute5
      ,p_dsq_attribute6                 =>  p_dsq_attribute6
      ,p_dsq_attribute7                 =>  p_dsq_attribute7
      ,p_dsq_attribute8                 =>  p_dsq_attribute8
      ,p_dsq_attribute9                 =>  p_dsq_attribute9
      ,p_dsq_attribute10                =>  p_dsq_attribute10
      ,p_dsq_attribute11                =>  p_dsq_attribute11
      ,p_dsq_attribute12                =>  p_dsq_attribute12
      ,p_dsq_attribute13                =>  p_dsq_attribute13
      ,p_dsq_attribute14                =>  p_dsq_attribute14
      ,p_dsq_attribute15                =>  p_dsq_attribute15
      ,p_dsq_attribute16                =>  p_dsq_attribute16
      ,p_dsq_attribute17                =>  p_dsq_attribute17
      ,p_dsq_attribute18                =>  p_dsq_attribute18
      ,p_dsq_attribute19                =>  p_dsq_attribute19
      ,p_dsq_attribute20                =>  p_dsq_attribute20
      ,p_dsq_attribute21                =>  p_dsq_attribute21
      ,p_dsq_attribute22                =>  p_dsq_attribute22
      ,p_dsq_attribute23                =>  p_dsq_attribute23
      ,p_dsq_attribute24                =>  p_dsq_attribute24
      ,p_dsq_attribute25                =>  p_dsq_attribute25
      ,p_dsq_attribute26                =>  p_dsq_attribute26
      ,p_dsq_attribute27                =>  p_dsq_attribute27
      ,p_dsq_attribute28                =>  p_dsq_attribute28
      ,p_dsq_attribute29                =>  p_dsq_attribute29
      ,p_dsq_attribute30                =>  p_dsq_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DEDUCT_SCHED_PAY_FREQ'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_DEDUCT_SCHED_PAY_FREQ
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
    ROLLBACK TO update_DEDUCT_SCHED_PAY_FREQ;
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
    ROLLBACK TO update_DEDUCT_SCHED_PAY_FREQ;
    raise;
    --
end update_DEDUCT_SCHED_PAY_FREQ;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_DEDUCT_SCHED_PAY_FREQ >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DEDUCT_SCHED_PAY_FREQ
  (p_validate                       in  boolean  default false
  ,p_ded_sched_py_freq_id           in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DEDUCT_SCHED_PAY_FREQ';
  l_object_version_number ben_ded_sched_py_freq.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_DEDUCT_SCHED_PAY_FREQ;
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
    -- Start of API User Hook for the before hook of delete_DEDUCT_SCHED_PAY_FREQ
    --
    ben_DEDUCT_SCHED_PAY_FREQ_bk3.delete_DEDUCT_SCHED_PAY_FREQ_b
      (
       p_ded_sched_py_freq_id           =>  p_ded_sched_py_freq_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DEDUCT_SCHED_PAY_FREQ'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_DEDUCT_SCHED_PAY_FREQ
    --
  end;
  --
  ben_dsq_del.del
    (
     p_ded_sched_py_freq_id          => p_ded_sched_py_freq_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_DEDUCT_SCHED_PAY_FREQ
    --
    ben_DEDUCT_SCHED_PAY_FREQ_bk3.delete_DEDUCT_SCHED_PAY_FREQ_a
      (
       p_ded_sched_py_freq_id           =>  p_ded_sched_py_freq_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DEDUCT_SCHED_PAY_FREQ'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_DEDUCT_SCHED_PAY_FREQ
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
    ROLLBACK TO delete_DEDUCT_SCHED_PAY_FREQ;
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
    ROLLBACK TO delete_DEDUCT_SCHED_PAY_FREQ;
    raise;
    --
end delete_DEDUCT_SCHED_PAY_FREQ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ded_sched_py_freq_id                   in     number
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
  ben_dsq_shd.lck
    (
      p_ded_sched_py_freq_id                 => p_ded_sched_py_freq_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_DEDUCT_SCHED_PAY_FREQ_api;

/
