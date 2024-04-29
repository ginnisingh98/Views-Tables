--------------------------------------------------------
--  DDL for Package Body BEN_PREM_CSTG_BY_SGMT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PREM_CSTG_BY_SGMT_API" as
/* $Header: becbsapi.pkb 120.0 2005/05/28 00:56:21 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PREM_CSTG_BY_SGMT_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PREM_CSTG_BY_SGMT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PREM_CSTG_BY_SGMT
  (p_validate                       in  boolean   default false
  ,p_prem_cstg_by_sgmt_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_sgmt_num                       in  number    default null
  ,p_sgmt_cstg_mthd_cd              in  varchar2  default null
  ,p_sgmt_cstg_mthd_rl              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_cbs_attribute_category         in  varchar2  default null
  ,p_cbs_attribute1                 in  varchar2  default null
  ,p_cbs_attribute2                 in  varchar2  default null
  ,p_cbs_attribute3                 in  varchar2  default null
  ,p_cbs_attribute4                 in  varchar2  default null
  ,p_cbs_attribute5                 in  varchar2  default null
  ,p_cbs_attribute6                 in  varchar2  default null
  ,p_cbs_attribute7                 in  varchar2  default null
  ,p_cbs_attribute8                 in  varchar2  default null
  ,p_cbs_attribute9                 in  varchar2  default null
  ,p_cbs_attribute10                in  varchar2  default null
  ,p_cbs_attribute11                in  varchar2  default null
  ,p_cbs_attribute12                in  varchar2  default null
  ,p_cbs_attribute13                in  varchar2  default null
  ,p_cbs_attribute14                in  varchar2  default null
  ,p_cbs_attribute15                in  varchar2  default null
  ,p_cbs_attribute16                in  varchar2  default null
  ,p_cbs_attribute17                in  varchar2  default null
  ,p_cbs_attribute18                in  varchar2  default null
  ,p_cbs_attribute19                in  varchar2  default null
  ,p_cbs_attribute20                in  varchar2  default null
  ,p_cbs_attribute21                in  varchar2  default null
  ,p_cbs_attribute22                in  varchar2  default null
  ,p_cbs_attribute23                in  varchar2  default null
  ,p_cbs_attribute24                in  varchar2  default null
  ,p_cbs_attribute25                in  varchar2  default null
  ,p_cbs_attribute26                in  varchar2  default null
  ,p_cbs_attribute27                in  varchar2  default null
  ,p_cbs_attribute28                in  varchar2  default null
  ,p_cbs_attribute29                in  varchar2  default null
  ,p_cbs_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prem_cstg_by_sgmt_id ben_prem_cstg_by_sgmt_f.prem_cstg_by_sgmt_id%TYPE;
  l_effective_start_date ben_prem_cstg_by_sgmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_prem_cstg_by_sgmt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PREM_CSTG_BY_SGMT';
  l_object_version_number ben_prem_cstg_by_sgmt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PREM_CSTG_BY_SGMT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PREM_CSTG_BY_SGMT
    --
    ben_PREM_CSTG_BY_SGMT_bk1.create_PREM_CSTG_BY_SGMT_b
      (
       p_sgmt_num                       =>  p_sgmt_num
      ,p_sgmt_cstg_mthd_cd              =>  p_sgmt_cstg_mthd_cd
      ,p_sgmt_cstg_mthd_rl              =>  p_sgmt_cstg_mthd_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_cbs_attribute_category         =>  p_cbs_attribute_category
      ,p_cbs_attribute1                 =>  p_cbs_attribute1
      ,p_cbs_attribute2                 =>  p_cbs_attribute2
      ,p_cbs_attribute3                 =>  p_cbs_attribute3
      ,p_cbs_attribute4                 =>  p_cbs_attribute4
      ,p_cbs_attribute5                 =>  p_cbs_attribute5
      ,p_cbs_attribute6                 =>  p_cbs_attribute6
      ,p_cbs_attribute7                 =>  p_cbs_attribute7
      ,p_cbs_attribute8                 =>  p_cbs_attribute8
      ,p_cbs_attribute9                 =>  p_cbs_attribute9
      ,p_cbs_attribute10                =>  p_cbs_attribute10
      ,p_cbs_attribute11                =>  p_cbs_attribute11
      ,p_cbs_attribute12                =>  p_cbs_attribute12
      ,p_cbs_attribute13                =>  p_cbs_attribute13
      ,p_cbs_attribute14                =>  p_cbs_attribute14
      ,p_cbs_attribute15                =>  p_cbs_attribute15
      ,p_cbs_attribute16                =>  p_cbs_attribute16
      ,p_cbs_attribute17                =>  p_cbs_attribute17
      ,p_cbs_attribute18                =>  p_cbs_attribute18
      ,p_cbs_attribute19                =>  p_cbs_attribute19
      ,p_cbs_attribute20                =>  p_cbs_attribute20
      ,p_cbs_attribute21                =>  p_cbs_attribute21
      ,p_cbs_attribute22                =>  p_cbs_attribute22
      ,p_cbs_attribute23                =>  p_cbs_attribute23
      ,p_cbs_attribute24                =>  p_cbs_attribute24
      ,p_cbs_attribute25                =>  p_cbs_attribute25
      ,p_cbs_attribute26                =>  p_cbs_attribute26
      ,p_cbs_attribute27                =>  p_cbs_attribute27
      ,p_cbs_attribute28                =>  p_cbs_attribute28
      ,p_cbs_attribute29                =>  p_cbs_attribute29
      ,p_cbs_attribute30                =>  p_cbs_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PREM_CSTG_BY_SGMT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PREM_CSTG_BY_SGMT
    --
  end;
  --
  ben_cbs_ins.ins
    (
     p_prem_cstg_by_sgmt_id          => l_prem_cstg_by_sgmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_sgmt_num                      => p_sgmt_num
    ,p_sgmt_cstg_mthd_cd             => p_sgmt_cstg_mthd_cd
    ,p_sgmt_cstg_mthd_rl             => p_sgmt_cstg_mthd_rl
    ,p_business_group_id             => p_business_group_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_cbs_attribute_category        => p_cbs_attribute_category
    ,p_cbs_attribute1                => p_cbs_attribute1
    ,p_cbs_attribute2                => p_cbs_attribute2
    ,p_cbs_attribute3                => p_cbs_attribute3
    ,p_cbs_attribute4                => p_cbs_attribute4
    ,p_cbs_attribute5                => p_cbs_attribute5
    ,p_cbs_attribute6                => p_cbs_attribute6
    ,p_cbs_attribute7                => p_cbs_attribute7
    ,p_cbs_attribute8                => p_cbs_attribute8
    ,p_cbs_attribute9                => p_cbs_attribute9
    ,p_cbs_attribute10               => p_cbs_attribute10
    ,p_cbs_attribute11               => p_cbs_attribute11
    ,p_cbs_attribute12               => p_cbs_attribute12
    ,p_cbs_attribute13               => p_cbs_attribute13
    ,p_cbs_attribute14               => p_cbs_attribute14
    ,p_cbs_attribute15               => p_cbs_attribute15
    ,p_cbs_attribute16               => p_cbs_attribute16
    ,p_cbs_attribute17               => p_cbs_attribute17
    ,p_cbs_attribute18               => p_cbs_attribute18
    ,p_cbs_attribute19               => p_cbs_attribute19
    ,p_cbs_attribute20               => p_cbs_attribute20
    ,p_cbs_attribute21               => p_cbs_attribute21
    ,p_cbs_attribute22               => p_cbs_attribute22
    ,p_cbs_attribute23               => p_cbs_attribute23
    ,p_cbs_attribute24               => p_cbs_attribute24
    ,p_cbs_attribute25               => p_cbs_attribute25
    ,p_cbs_attribute26               => p_cbs_attribute26
    ,p_cbs_attribute27               => p_cbs_attribute27
    ,p_cbs_attribute28               => p_cbs_attribute28
    ,p_cbs_attribute29               => p_cbs_attribute29
    ,p_cbs_attribute30               => p_cbs_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PREM_CSTG_BY_SGMT
    --
    ben_PREM_CSTG_BY_SGMT_bk1.create_PREM_CSTG_BY_SGMT_a
      (
       p_prem_cstg_by_sgmt_id           =>  l_prem_cstg_by_sgmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_sgmt_num                       =>  p_sgmt_num
      ,p_sgmt_cstg_mthd_cd              =>  p_sgmt_cstg_mthd_cd
      ,p_sgmt_cstg_mthd_rl              =>  p_sgmt_cstg_mthd_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_cbs_attribute_category         =>  p_cbs_attribute_category
      ,p_cbs_attribute1                 =>  p_cbs_attribute1
      ,p_cbs_attribute2                 =>  p_cbs_attribute2
      ,p_cbs_attribute3                 =>  p_cbs_attribute3
      ,p_cbs_attribute4                 =>  p_cbs_attribute4
      ,p_cbs_attribute5                 =>  p_cbs_attribute5
      ,p_cbs_attribute6                 =>  p_cbs_attribute6
      ,p_cbs_attribute7                 =>  p_cbs_attribute7
      ,p_cbs_attribute8                 =>  p_cbs_attribute8
      ,p_cbs_attribute9                 =>  p_cbs_attribute9
      ,p_cbs_attribute10                =>  p_cbs_attribute10
      ,p_cbs_attribute11                =>  p_cbs_attribute11
      ,p_cbs_attribute12                =>  p_cbs_attribute12
      ,p_cbs_attribute13                =>  p_cbs_attribute13
      ,p_cbs_attribute14                =>  p_cbs_attribute14
      ,p_cbs_attribute15                =>  p_cbs_attribute15
      ,p_cbs_attribute16                =>  p_cbs_attribute16
      ,p_cbs_attribute17                =>  p_cbs_attribute17
      ,p_cbs_attribute18                =>  p_cbs_attribute18
      ,p_cbs_attribute19                =>  p_cbs_attribute19
      ,p_cbs_attribute20                =>  p_cbs_attribute20
      ,p_cbs_attribute21                =>  p_cbs_attribute21
      ,p_cbs_attribute22                =>  p_cbs_attribute22
      ,p_cbs_attribute23                =>  p_cbs_attribute23
      ,p_cbs_attribute24                =>  p_cbs_attribute24
      ,p_cbs_attribute25                =>  p_cbs_attribute25
      ,p_cbs_attribute26                =>  p_cbs_attribute26
      ,p_cbs_attribute27                =>  p_cbs_attribute27
      ,p_cbs_attribute28                =>  p_cbs_attribute28
      ,p_cbs_attribute29                =>  p_cbs_attribute29
      ,p_cbs_attribute30                =>  p_cbs_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PREM_CSTG_BY_SGMT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PREM_CSTG_BY_SGMT
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
  p_prem_cstg_by_sgmt_id := l_prem_cstg_by_sgmt_id;
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
    ROLLBACK TO create_PREM_CSTG_BY_SGMT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prem_cstg_by_sgmt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PREM_CSTG_BY_SGMT;
    -- NOCOPY Changas
    p_prem_cstg_by_sgmt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_PREM_CSTG_BY_SGMT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PREM_CSTG_BY_SGMT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PREM_CSTG_BY_SGMT
  (p_validate                       in  boolean   default false
  ,p_prem_cstg_by_sgmt_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_sgmt_num                       in  number    default hr_api.g_number
  ,p_sgmt_cstg_mthd_cd              in  varchar2  default hr_api.g_varchar2
  ,p_sgmt_cstg_mthd_rl              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_cbs_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cbs_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PREM_CSTG_BY_SGMT';
  l_object_version_number ben_prem_cstg_by_sgmt_f.object_version_number%TYPE;
  l_effective_start_date ben_prem_cstg_by_sgmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_prem_cstg_by_sgmt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PREM_CSTG_BY_SGMT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PREM_CSTG_BY_SGMT
    --
    ben_PREM_CSTG_BY_SGMT_bk2.update_PREM_CSTG_BY_SGMT_b
      (
       p_prem_cstg_by_sgmt_id           =>  p_prem_cstg_by_sgmt_id
      ,p_sgmt_num                       =>  p_sgmt_num
      ,p_sgmt_cstg_mthd_cd              =>  p_sgmt_cstg_mthd_cd
      ,p_sgmt_cstg_mthd_rl              =>  p_sgmt_cstg_mthd_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_cbs_attribute_category         =>  p_cbs_attribute_category
      ,p_cbs_attribute1                 =>  p_cbs_attribute1
      ,p_cbs_attribute2                 =>  p_cbs_attribute2
      ,p_cbs_attribute3                 =>  p_cbs_attribute3
      ,p_cbs_attribute4                 =>  p_cbs_attribute4
      ,p_cbs_attribute5                 =>  p_cbs_attribute5
      ,p_cbs_attribute6                 =>  p_cbs_attribute6
      ,p_cbs_attribute7                 =>  p_cbs_attribute7
      ,p_cbs_attribute8                 =>  p_cbs_attribute8
      ,p_cbs_attribute9                 =>  p_cbs_attribute9
      ,p_cbs_attribute10                =>  p_cbs_attribute10
      ,p_cbs_attribute11                =>  p_cbs_attribute11
      ,p_cbs_attribute12                =>  p_cbs_attribute12
      ,p_cbs_attribute13                =>  p_cbs_attribute13
      ,p_cbs_attribute14                =>  p_cbs_attribute14
      ,p_cbs_attribute15                =>  p_cbs_attribute15
      ,p_cbs_attribute16                =>  p_cbs_attribute16
      ,p_cbs_attribute17                =>  p_cbs_attribute17
      ,p_cbs_attribute18                =>  p_cbs_attribute18
      ,p_cbs_attribute19                =>  p_cbs_attribute19
      ,p_cbs_attribute20                =>  p_cbs_attribute20
      ,p_cbs_attribute21                =>  p_cbs_attribute21
      ,p_cbs_attribute22                =>  p_cbs_attribute22
      ,p_cbs_attribute23                =>  p_cbs_attribute23
      ,p_cbs_attribute24                =>  p_cbs_attribute24
      ,p_cbs_attribute25                =>  p_cbs_attribute25
      ,p_cbs_attribute26                =>  p_cbs_attribute26
      ,p_cbs_attribute27                =>  p_cbs_attribute27
      ,p_cbs_attribute28                =>  p_cbs_attribute28
      ,p_cbs_attribute29                =>  p_cbs_attribute29
      ,p_cbs_attribute30                =>  p_cbs_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PREM_CSTG_BY_SGMT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PREM_CSTG_BY_SGMT
    --
  end;
  --
  ben_cbs_upd.upd
    (
     p_prem_cstg_by_sgmt_id          => p_prem_cstg_by_sgmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_sgmt_num                      => p_sgmt_num
    ,p_sgmt_cstg_mthd_cd             => p_sgmt_cstg_mthd_cd
    ,p_sgmt_cstg_mthd_rl             => p_sgmt_cstg_mthd_rl
    ,p_business_group_id             => p_business_group_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_cbs_attribute_category        => p_cbs_attribute_category
    ,p_cbs_attribute1                => p_cbs_attribute1
    ,p_cbs_attribute2                => p_cbs_attribute2
    ,p_cbs_attribute3                => p_cbs_attribute3
    ,p_cbs_attribute4                => p_cbs_attribute4
    ,p_cbs_attribute5                => p_cbs_attribute5
    ,p_cbs_attribute6                => p_cbs_attribute6
    ,p_cbs_attribute7                => p_cbs_attribute7
    ,p_cbs_attribute8                => p_cbs_attribute8
    ,p_cbs_attribute9                => p_cbs_attribute9
    ,p_cbs_attribute10               => p_cbs_attribute10
    ,p_cbs_attribute11               => p_cbs_attribute11
    ,p_cbs_attribute12               => p_cbs_attribute12
    ,p_cbs_attribute13               => p_cbs_attribute13
    ,p_cbs_attribute14               => p_cbs_attribute14
    ,p_cbs_attribute15               => p_cbs_attribute15
    ,p_cbs_attribute16               => p_cbs_attribute16
    ,p_cbs_attribute17               => p_cbs_attribute17
    ,p_cbs_attribute18               => p_cbs_attribute18
    ,p_cbs_attribute19               => p_cbs_attribute19
    ,p_cbs_attribute20               => p_cbs_attribute20
    ,p_cbs_attribute21               => p_cbs_attribute21
    ,p_cbs_attribute22               => p_cbs_attribute22
    ,p_cbs_attribute23               => p_cbs_attribute23
    ,p_cbs_attribute24               => p_cbs_attribute24
    ,p_cbs_attribute25               => p_cbs_attribute25
    ,p_cbs_attribute26               => p_cbs_attribute26
    ,p_cbs_attribute27               => p_cbs_attribute27
    ,p_cbs_attribute28               => p_cbs_attribute28
    ,p_cbs_attribute29               => p_cbs_attribute29
    ,p_cbs_attribute30               => p_cbs_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PREM_CSTG_BY_SGMT
    --
    ben_PREM_CSTG_BY_SGMT_bk2.update_PREM_CSTG_BY_SGMT_a
      (
       p_prem_cstg_by_sgmt_id           =>  p_prem_cstg_by_sgmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_sgmt_num                       =>  p_sgmt_num
      ,p_sgmt_cstg_mthd_cd              =>  p_sgmt_cstg_mthd_cd
      ,p_sgmt_cstg_mthd_rl              =>  p_sgmt_cstg_mthd_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_cbs_attribute_category         =>  p_cbs_attribute_category
      ,p_cbs_attribute1                 =>  p_cbs_attribute1
      ,p_cbs_attribute2                 =>  p_cbs_attribute2
      ,p_cbs_attribute3                 =>  p_cbs_attribute3
      ,p_cbs_attribute4                 =>  p_cbs_attribute4
      ,p_cbs_attribute5                 =>  p_cbs_attribute5
      ,p_cbs_attribute6                 =>  p_cbs_attribute6
      ,p_cbs_attribute7                 =>  p_cbs_attribute7
      ,p_cbs_attribute8                 =>  p_cbs_attribute8
      ,p_cbs_attribute9                 =>  p_cbs_attribute9
      ,p_cbs_attribute10                =>  p_cbs_attribute10
      ,p_cbs_attribute11                =>  p_cbs_attribute11
      ,p_cbs_attribute12                =>  p_cbs_attribute12
      ,p_cbs_attribute13                =>  p_cbs_attribute13
      ,p_cbs_attribute14                =>  p_cbs_attribute14
      ,p_cbs_attribute15                =>  p_cbs_attribute15
      ,p_cbs_attribute16                =>  p_cbs_attribute16
      ,p_cbs_attribute17                =>  p_cbs_attribute17
      ,p_cbs_attribute18                =>  p_cbs_attribute18
      ,p_cbs_attribute19                =>  p_cbs_attribute19
      ,p_cbs_attribute20                =>  p_cbs_attribute20
      ,p_cbs_attribute21                =>  p_cbs_attribute21
      ,p_cbs_attribute22                =>  p_cbs_attribute22
      ,p_cbs_attribute23                =>  p_cbs_attribute23
      ,p_cbs_attribute24                =>  p_cbs_attribute24
      ,p_cbs_attribute25                =>  p_cbs_attribute25
      ,p_cbs_attribute26                =>  p_cbs_attribute26
      ,p_cbs_attribute27                =>  p_cbs_attribute27
      ,p_cbs_attribute28                =>  p_cbs_attribute28
      ,p_cbs_attribute29                =>  p_cbs_attribute29
      ,p_cbs_attribute30                =>  p_cbs_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PREM_CSTG_BY_SGMT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PREM_CSTG_BY_SGMT
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
    ROLLBACK TO update_PREM_CSTG_BY_SGMT;
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
    ROLLBACK TO update_PREM_CSTG_BY_SGMT;
    p_object_version_number := l_object_version_number ;
    p_effective_start_date := null ;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_PREM_CSTG_BY_SGMT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PREM_CSTG_BY_SGMT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PREM_CSTG_BY_SGMT
  (p_validate                       in  boolean  default false
  ,p_prem_cstg_by_sgmt_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PREM_CSTG_BY_SGMT';
  l_object_version_number ben_prem_cstg_by_sgmt_f.object_version_number%TYPE;
  l_effective_start_date ben_prem_cstg_by_sgmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_prem_cstg_by_sgmt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PREM_CSTG_BY_SGMT;
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
    -- Start of API User Hook for the before hook of delete_PREM_CSTG_BY_SGMT
    --
    ben_PREM_CSTG_BY_SGMT_bk3.delete_PREM_CSTG_BY_SGMT_b
      (
       p_prem_cstg_by_sgmt_id           =>  p_prem_cstg_by_sgmt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PREM_CSTG_BY_SGMT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PREM_CSTG_BY_SGMT
    --
  end;
  --
  ben_cbs_del.del
    (
     p_prem_cstg_by_sgmt_id          => p_prem_cstg_by_sgmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PREM_CSTG_BY_SGMT
    --
    ben_PREM_CSTG_BY_SGMT_bk3.delete_PREM_CSTG_BY_SGMT_a
      (
       p_prem_cstg_by_sgmt_id           =>  p_prem_cstg_by_sgmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PREM_CSTG_BY_SGMT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PREM_CSTG_BY_SGMT
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
    ROLLBACK TO delete_PREM_CSTG_BY_SGMT;
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
    ROLLBACK TO delete_PREM_CSTG_BY_SGMT;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_PREM_CSTG_BY_SGMT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prem_cstg_by_sgmt_id                   in     number
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
  ben_cbs_shd.lck
    (
      p_prem_cstg_by_sgmt_id                 => p_prem_cstg_by_sgmt_id
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
end ben_PREM_CSTG_BY_SGMT_api;

/
