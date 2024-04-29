--------------------------------------------------------
--  DDL for Package Body BEN_PYMT_SCHED_PY_FREQ_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PYMT_SCHED_PY_FREQ_API" as
/* $Header: bepsqapi.pkb 120.0 2005/05/28 11:19:44 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_pymt_sched_py_freq_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pymt_sched_py_freq >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pymt_sched_py_freq
  (p_validate                       in  boolean   default false
  ,p_pymt_sched_py_freq_id          out nocopy number
  ,p_py_freq_cd                     in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_acty_rt_pymt_sched_id          in  number    default null
  ,p_psq_attribute_category         in  varchar2  default null
  ,p_psq_attribute1                 in  varchar2  default null
  ,p_psq_attribute2                 in  varchar2  default null
  ,p_psq_attribute3                 in  varchar2  default null
  ,p_psq_attribute4                 in  varchar2  default null
  ,p_psq_attribute5                 in  varchar2  default null
  ,p_psq_attribute6                 in  varchar2  default null
  ,p_psq_attribute7                 in  varchar2  default null
  ,p_psq_attribute8                 in  varchar2  default null
  ,p_psq_attribute9                 in  varchar2  default null
  ,p_psq_attribute10                in  varchar2  default null
  ,p_psq_attribute11                in  varchar2  default null
  ,p_psq_attribute12                in  varchar2  default null
  ,p_psq_attribute13                in  varchar2  default null
  ,p_psq_attribute14                in  varchar2  default null
  ,p_psq_attribute15                in  varchar2  default null
  ,p_psq_attribute16                in  varchar2  default null
  ,p_psq_attribute17                in  varchar2  default null
  ,p_psq_attribute18                in  varchar2  default null
  ,p_psq_attribute19                in  varchar2  default null
  ,p_psq_attribute20                in  varchar2  default null
  ,p_psq_attribute21                in  varchar2  default null
  ,p_psq_attribute22                in  varchar2  default null
  ,p_psq_attribute23                in  varchar2  default null
  ,p_psq_attribute24                in  varchar2  default null
  ,p_psq_attribute25                in  varchar2  default null
  ,p_psq_attribute26                in  varchar2  default null
  ,p_psq_attribute27                in  varchar2  default null
  ,p_psq_attribute28                in  varchar2  default null
  ,p_psq_attribute29                in  varchar2  default null
  ,p_psq_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pymt_sched_py_freq_id ben_pymt_sched_py_freq.pymt_sched_py_freq_id%TYPE;
  l_proc varchar2(72) := g_package||'create_pymt_sched_py_freq';
  l_object_version_number ben_pymt_sched_py_freq.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_pymt_sched_py_freq;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_pymt_sched_py_freq
    --
    ben_pymt_sched_py_freq_bk1.create_pymt_sched_py_freq_b
      (
       p_py_freq_cd                     =>  p_py_freq_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_acty_rt_pymt_sched_id          =>  p_acty_rt_pymt_sched_id
      ,p_psq_attribute_category         =>  p_psq_attribute_category
      ,p_psq_attribute1                 =>  p_psq_attribute1
      ,p_psq_attribute2                 =>  p_psq_attribute2
      ,p_psq_attribute3                 =>  p_psq_attribute3
      ,p_psq_attribute4                 =>  p_psq_attribute4
      ,p_psq_attribute5                 =>  p_psq_attribute5
      ,p_psq_attribute6                 =>  p_psq_attribute6
      ,p_psq_attribute7                 =>  p_psq_attribute7
      ,p_psq_attribute8                 =>  p_psq_attribute8
      ,p_psq_attribute9                 =>  p_psq_attribute9
      ,p_psq_attribute10                =>  p_psq_attribute10
      ,p_psq_attribute11                =>  p_psq_attribute11
      ,p_psq_attribute12                =>  p_psq_attribute12
      ,p_psq_attribute13                =>  p_psq_attribute13
      ,p_psq_attribute14                =>  p_psq_attribute14
      ,p_psq_attribute15                =>  p_psq_attribute15
      ,p_psq_attribute16                =>  p_psq_attribute16
      ,p_psq_attribute17                =>  p_psq_attribute17
      ,p_psq_attribute18                =>  p_psq_attribute18
      ,p_psq_attribute19                =>  p_psq_attribute19
      ,p_psq_attribute20                =>  p_psq_attribute20
      ,p_psq_attribute21                =>  p_psq_attribute21
      ,p_psq_attribute22                =>  p_psq_attribute22
      ,p_psq_attribute23                =>  p_psq_attribute23
      ,p_psq_attribute24                =>  p_psq_attribute24
      ,p_psq_attribute25                =>  p_psq_attribute25
      ,p_psq_attribute26                =>  p_psq_attribute26
      ,p_psq_attribute27                =>  p_psq_attribute27
      ,p_psq_attribute28                =>  p_psq_attribute28
      ,p_psq_attribute29                =>  p_psq_attribute29
      ,p_psq_attribute30                =>  p_psq_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_pymt_sched_py_freq'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_pymt_sched_py_freq
    --
  end;
  --
  ben_psq_ins.ins
    (
     p_pymt_sched_py_freq_id         => l_pymt_sched_py_freq_id
    ,p_py_freq_cd                    => p_py_freq_cd
    ,p_dflt_flag                     => p_dflt_flag
    ,p_business_group_id             => p_business_group_id
    ,p_acty_rt_pymt_sched_id         => p_acty_rt_pymt_sched_id
    ,p_psq_attribute_category        => p_psq_attribute_category
    ,p_psq_attribute1                => p_psq_attribute1
    ,p_psq_attribute2                => p_psq_attribute2
    ,p_psq_attribute3                => p_psq_attribute3
    ,p_psq_attribute4                => p_psq_attribute4
    ,p_psq_attribute5                => p_psq_attribute5
    ,p_psq_attribute6                => p_psq_attribute6
    ,p_psq_attribute7                => p_psq_attribute7
    ,p_psq_attribute8                => p_psq_attribute8
    ,p_psq_attribute9                => p_psq_attribute9
    ,p_psq_attribute10               => p_psq_attribute10
    ,p_psq_attribute11               => p_psq_attribute11
    ,p_psq_attribute12               => p_psq_attribute12
    ,p_psq_attribute13               => p_psq_attribute13
    ,p_psq_attribute14               => p_psq_attribute14
    ,p_psq_attribute15               => p_psq_attribute15
    ,p_psq_attribute16               => p_psq_attribute16
    ,p_psq_attribute17               => p_psq_attribute17
    ,p_psq_attribute18               => p_psq_attribute18
    ,p_psq_attribute19               => p_psq_attribute19
    ,p_psq_attribute20               => p_psq_attribute20
    ,p_psq_attribute21               => p_psq_attribute21
    ,p_psq_attribute22               => p_psq_attribute22
    ,p_psq_attribute23               => p_psq_attribute23
    ,p_psq_attribute24               => p_psq_attribute24
    ,p_psq_attribute25               => p_psq_attribute25
    ,p_psq_attribute26               => p_psq_attribute26
    ,p_psq_attribute27               => p_psq_attribute27
    ,p_psq_attribute28               => p_psq_attribute28
    ,p_psq_attribute29               => p_psq_attribute29
    ,p_psq_attribute30               => p_psq_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_pymt_sched_py_freq
    --
    ben_pymt_sched_py_freq_bk1.create_pymt_sched_py_freq_a
      (
       p_pymt_sched_py_freq_id          =>  l_pymt_sched_py_freq_id
      ,p_py_freq_cd                     =>  p_py_freq_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_acty_rt_pymt_sched_id          =>  p_acty_rt_pymt_sched_id
      ,p_psq_attribute_category         =>  p_psq_attribute_category
      ,p_psq_attribute1                 =>  p_psq_attribute1
      ,p_psq_attribute2                 =>  p_psq_attribute2
      ,p_psq_attribute3                 =>  p_psq_attribute3
      ,p_psq_attribute4                 =>  p_psq_attribute4
      ,p_psq_attribute5                 =>  p_psq_attribute5
      ,p_psq_attribute6                 =>  p_psq_attribute6
      ,p_psq_attribute7                 =>  p_psq_attribute7
      ,p_psq_attribute8                 =>  p_psq_attribute8
      ,p_psq_attribute9                 =>  p_psq_attribute9
      ,p_psq_attribute10                =>  p_psq_attribute10
      ,p_psq_attribute11                =>  p_psq_attribute11
      ,p_psq_attribute12                =>  p_psq_attribute12
      ,p_psq_attribute13                =>  p_psq_attribute13
      ,p_psq_attribute14                =>  p_psq_attribute14
      ,p_psq_attribute15                =>  p_psq_attribute15
      ,p_psq_attribute16                =>  p_psq_attribute16
      ,p_psq_attribute17                =>  p_psq_attribute17
      ,p_psq_attribute18                =>  p_psq_attribute18
      ,p_psq_attribute19                =>  p_psq_attribute19
      ,p_psq_attribute20                =>  p_psq_attribute20
      ,p_psq_attribute21                =>  p_psq_attribute21
      ,p_psq_attribute22                =>  p_psq_attribute22
      ,p_psq_attribute23                =>  p_psq_attribute23
      ,p_psq_attribute24                =>  p_psq_attribute24
      ,p_psq_attribute25                =>  p_psq_attribute25
      ,p_psq_attribute26                =>  p_psq_attribute26
      ,p_psq_attribute27                =>  p_psq_attribute27
      ,p_psq_attribute28                =>  p_psq_attribute28
      ,p_psq_attribute29                =>  p_psq_attribute29
      ,p_psq_attribute30                =>  p_psq_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_pymt_sched_py_freq'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_pymt_sched_py_freq
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
  p_pymt_sched_py_freq_id := l_pymt_sched_py_freq_id;
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
    ROLLBACK TO create_pymt_sched_py_freq;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pymt_sched_py_freq_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    -- Initialize OUT Variables for NOCOPY
    p_pymt_sched_py_freq_id :=null;
    p_object_version_number :=null ;

    ROLLBACK TO create_pymt_sched_py_freq;
    raise;
    --
end create_pymt_sched_py_freq;
-- ----------------------------------------------------------------------------
-- |------------------------< update_pymt_sched_py_freq >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pymt_sched_py_freq
  (p_validate                       in  boolean   default false
  ,p_pymt_sched_py_freq_id          in  number
  ,p_py_freq_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_acty_rt_pymt_sched_id          in  number    default hr_api.g_number
  ,p_psq_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_psq_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pymt_sched_py_freq';
  l_object_version_number ben_pymt_sched_py_freq.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_pymt_sched_py_freq;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_pymt_sched_py_freq
    --
    ben_pymt_sched_py_freq_bk2.update_pymt_sched_py_freq_b
      (
       p_pymt_sched_py_freq_id          =>  p_pymt_sched_py_freq_id
      ,p_py_freq_cd                     =>  p_py_freq_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_acty_rt_pymt_sched_id          =>  p_acty_rt_pymt_sched_id
      ,p_psq_attribute_category         =>  p_psq_attribute_category
      ,p_psq_attribute1                 =>  p_psq_attribute1
      ,p_psq_attribute2                 =>  p_psq_attribute2
      ,p_psq_attribute3                 =>  p_psq_attribute3
      ,p_psq_attribute4                 =>  p_psq_attribute4
      ,p_psq_attribute5                 =>  p_psq_attribute5
      ,p_psq_attribute6                 =>  p_psq_attribute6
      ,p_psq_attribute7                 =>  p_psq_attribute7
      ,p_psq_attribute8                 =>  p_psq_attribute8
      ,p_psq_attribute9                 =>  p_psq_attribute9
      ,p_psq_attribute10                =>  p_psq_attribute10
      ,p_psq_attribute11                =>  p_psq_attribute11
      ,p_psq_attribute12                =>  p_psq_attribute12
      ,p_psq_attribute13                =>  p_psq_attribute13
      ,p_psq_attribute14                =>  p_psq_attribute14
      ,p_psq_attribute15                =>  p_psq_attribute15
      ,p_psq_attribute16                =>  p_psq_attribute16
      ,p_psq_attribute17                =>  p_psq_attribute17
      ,p_psq_attribute18                =>  p_psq_attribute18
      ,p_psq_attribute19                =>  p_psq_attribute19
      ,p_psq_attribute20                =>  p_psq_attribute20
      ,p_psq_attribute21                =>  p_psq_attribute21
      ,p_psq_attribute22                =>  p_psq_attribute22
      ,p_psq_attribute23                =>  p_psq_attribute23
      ,p_psq_attribute24                =>  p_psq_attribute24
      ,p_psq_attribute25                =>  p_psq_attribute25
      ,p_psq_attribute26                =>  p_psq_attribute26
      ,p_psq_attribute27                =>  p_psq_attribute27
      ,p_psq_attribute28                =>  p_psq_attribute28
      ,p_psq_attribute29                =>  p_psq_attribute29
      ,p_psq_attribute30                =>  p_psq_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pymt_sched_py_freq'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_pymt_sched_py_freq
    --
  end;
  --
  ben_psq_upd.upd
    (
     p_pymt_sched_py_freq_id         => p_pymt_sched_py_freq_id
    ,p_py_freq_cd                    => p_py_freq_cd
    ,p_dflt_flag                     => p_dflt_flag
    ,p_business_group_id             => p_business_group_id
    ,p_acty_rt_pymt_sched_id         => p_acty_rt_pymt_sched_id
    ,p_psq_attribute_category        => p_psq_attribute_category
    ,p_psq_attribute1                => p_psq_attribute1
    ,p_psq_attribute2                => p_psq_attribute2
    ,p_psq_attribute3                => p_psq_attribute3
    ,p_psq_attribute4                => p_psq_attribute4
    ,p_psq_attribute5                => p_psq_attribute5
    ,p_psq_attribute6                => p_psq_attribute6
    ,p_psq_attribute7                => p_psq_attribute7
    ,p_psq_attribute8                => p_psq_attribute8
    ,p_psq_attribute9                => p_psq_attribute9
    ,p_psq_attribute10               => p_psq_attribute10
    ,p_psq_attribute11               => p_psq_attribute11
    ,p_psq_attribute12               => p_psq_attribute12
    ,p_psq_attribute13               => p_psq_attribute13
    ,p_psq_attribute14               => p_psq_attribute14
    ,p_psq_attribute15               => p_psq_attribute15
    ,p_psq_attribute16               => p_psq_attribute16
    ,p_psq_attribute17               => p_psq_attribute17
    ,p_psq_attribute18               => p_psq_attribute18
    ,p_psq_attribute19               => p_psq_attribute19
    ,p_psq_attribute20               => p_psq_attribute20
    ,p_psq_attribute21               => p_psq_attribute21
    ,p_psq_attribute22               => p_psq_attribute22
    ,p_psq_attribute23               => p_psq_attribute23
    ,p_psq_attribute24               => p_psq_attribute24
    ,p_psq_attribute25               => p_psq_attribute25
    ,p_psq_attribute26               => p_psq_attribute26
    ,p_psq_attribute27               => p_psq_attribute27
    ,p_psq_attribute28               => p_psq_attribute28
    ,p_psq_attribute29               => p_psq_attribute29
    ,p_psq_attribute30               => p_psq_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_pymt_sched_py_freq
    --
    ben_pymt_sched_py_freq_bk2.update_pymt_sched_py_freq_a
      (
       p_pymt_sched_py_freq_id          =>  p_pymt_sched_py_freq_id
      ,p_py_freq_cd                     =>  p_py_freq_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_acty_rt_pymt_sched_id          =>  p_acty_rt_pymt_sched_id
      ,p_psq_attribute_category         =>  p_psq_attribute_category
      ,p_psq_attribute1                 =>  p_psq_attribute1
      ,p_psq_attribute2                 =>  p_psq_attribute2
      ,p_psq_attribute3                 =>  p_psq_attribute3
      ,p_psq_attribute4                 =>  p_psq_attribute4
      ,p_psq_attribute5                 =>  p_psq_attribute5
      ,p_psq_attribute6                 =>  p_psq_attribute6
      ,p_psq_attribute7                 =>  p_psq_attribute7
      ,p_psq_attribute8                 =>  p_psq_attribute8
      ,p_psq_attribute9                 =>  p_psq_attribute9
      ,p_psq_attribute10                =>  p_psq_attribute10
      ,p_psq_attribute11                =>  p_psq_attribute11
      ,p_psq_attribute12                =>  p_psq_attribute12
      ,p_psq_attribute13                =>  p_psq_attribute13
      ,p_psq_attribute14                =>  p_psq_attribute14
      ,p_psq_attribute15                =>  p_psq_attribute15
      ,p_psq_attribute16                =>  p_psq_attribute16
      ,p_psq_attribute17                =>  p_psq_attribute17
      ,p_psq_attribute18                =>  p_psq_attribute18
      ,p_psq_attribute19                =>  p_psq_attribute19
      ,p_psq_attribute20                =>  p_psq_attribute20
      ,p_psq_attribute21                =>  p_psq_attribute21
      ,p_psq_attribute22                =>  p_psq_attribute22
      ,p_psq_attribute23                =>  p_psq_attribute23
      ,p_psq_attribute24                =>  p_psq_attribute24
      ,p_psq_attribute25                =>  p_psq_attribute25
      ,p_psq_attribute26                =>  p_psq_attribute26
      ,p_psq_attribute27                =>  p_psq_attribute27
      ,p_psq_attribute28                =>  p_psq_attribute28
      ,p_psq_attribute29                =>  p_psq_attribute29
      ,p_psq_attribute30                =>  p_psq_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pymt_sched_py_freq'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_pymt_sched_py_freq
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
    ROLLBACK TO update_pymt_sched_py_freq;
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
    -- Initialize IN/OUT Variables for NOCOPY
    p_object_version_number := l_object_version_number ;

    ROLLBACK TO update_pymt_sched_py_freq;
    raise;
    --
end update_pymt_sched_py_freq;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pymt_sched_py_freq >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pymt_sched_py_freq
  (p_validate                       in  boolean  default false
  ,p_pymt_sched_py_freq_id          in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pymt_sched_py_freq';
  l_object_version_number ben_pymt_sched_py_freq.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_pymt_sched_py_freq;
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
    -- Start of API User Hook for the before hook of delete_pymt_sched_py_freq
    --
    ben_pymt_sched_py_freq_bk3.delete_pymt_sched_py_freq_b
      (
       p_pymt_sched_py_freq_id          =>  p_pymt_sched_py_freq_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pymt_sched_py_freq'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_pymt_sched_py_freq
    --
  end;
  --
  ben_psq_del.del
    (
     p_pymt_sched_py_freq_id         => p_pymt_sched_py_freq_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_pymt_sched_py_freq
    --
    ben_pymt_sched_py_freq_bk3.delete_pymt_sched_py_freq_a
      (
       p_pymt_sched_py_freq_id          =>  p_pymt_sched_py_freq_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pymt_sched_py_freq'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_pymt_sched_py_freq
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
    ROLLBACK TO delete_pymt_sched_py_freq;
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
    --

    -- Initialize IN/OUT Variables for NOCOPY
    p_object_version_number  := l_object_version_number;


    ROLLBACK TO delete_pymt_sched_py_freq;
    raise;
    --
end delete_pymt_sched_py_freq;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pymt_sched_py_freq_id                   in     number
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
  ben_psq_shd.lck
    (
      p_pymt_sched_py_freq_id                 => p_pymt_sched_py_freq_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_pymt_sched_py_freq_api;

/
