--------------------------------------------------------
--  DDL for Package Body BEN_CMBN_PTIP_OPT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CMBN_PTIP_OPT_API" as
/* $Header: becptapi.pkb 115.3 2002/12/13 06:54:44 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_CMBN_PTIP_OPT_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_CMBN_PTIP_OPT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_CMBN_PTIP_OPT
  (p_validate                       in  boolean   default false
  ,p_cmbn_ptip_opt_id               out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_cpt_attribute_category         in  varchar2  default null
  ,p_cpt_attribute1                 in  varchar2  default null
  ,p_cpt_attribute2                 in  varchar2  default null
  ,p_cpt_attribute3                 in  varchar2  default null
  ,p_cpt_attribute4                 in  varchar2  default null
  ,p_cpt_attribute5                 in  varchar2  default null
  ,p_cpt_attribute6                 in  varchar2  default null
  ,p_cpt_attribute7                 in  varchar2  default null
  ,p_cpt_attribute8                 in  varchar2  default null
  ,p_cpt_attribute9                 in  varchar2  default null
  ,p_cpt_attribute10                in  varchar2  default null
  ,p_cpt_attribute11                in  varchar2  default null
  ,p_cpt_attribute12                in  varchar2  default null
  ,p_cpt_attribute13                in  varchar2  default null
  ,p_cpt_attribute14                in  varchar2  default null
  ,p_cpt_attribute15                in  varchar2  default null
  ,p_cpt_attribute16                in  varchar2  default null
  ,p_cpt_attribute17                in  varchar2  default null
  ,p_cpt_attribute18                in  varchar2  default null
  ,p_cpt_attribute19                in  varchar2  default null
  ,p_cpt_attribute20                in  varchar2  default null
  ,p_cpt_attribute21                in  varchar2  default null
  ,p_cpt_attribute22                in  varchar2  default null
  ,p_cpt_attribute23                in  varchar2  default null
  ,p_cpt_attribute24                in  varchar2  default null
  ,p_cpt_attribute25                in  varchar2  default null
  ,p_cpt_attribute26                in  varchar2  default null
  ,p_cpt_attribute27                in  varchar2  default null
  ,p_cpt_attribute28                in  varchar2  default null
  ,p_cpt_attribute29                in  varchar2  default null
  ,p_cpt_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_ptip_id                        in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cmbn_ptip_opt_id ben_cmbn_ptip_opt_f.cmbn_ptip_opt_id%TYPE;
  l_effective_start_date ben_cmbn_ptip_opt_f.effective_start_date%TYPE;
  l_effective_end_date ben_cmbn_ptip_opt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_CMBN_PTIP_OPT';
  l_object_version_number ben_cmbn_ptip_opt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_CMBN_PTIP_OPT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_CMBN_PTIP_OPT
    --
    ben_CMBN_PTIP_OPT_bk1.create_CMBN_PTIP_OPT_b
      (
       p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_cpt_attribute_category         =>  p_cpt_attribute_category
      ,p_cpt_attribute1                 =>  p_cpt_attribute1
      ,p_cpt_attribute2                 =>  p_cpt_attribute2
      ,p_cpt_attribute3                 =>  p_cpt_attribute3
      ,p_cpt_attribute4                 =>  p_cpt_attribute4
      ,p_cpt_attribute5                 =>  p_cpt_attribute5
      ,p_cpt_attribute6                 =>  p_cpt_attribute6
      ,p_cpt_attribute7                 =>  p_cpt_attribute7
      ,p_cpt_attribute8                 =>  p_cpt_attribute8
      ,p_cpt_attribute9                 =>  p_cpt_attribute9
      ,p_cpt_attribute10                =>  p_cpt_attribute10
      ,p_cpt_attribute11                =>  p_cpt_attribute11
      ,p_cpt_attribute12                =>  p_cpt_attribute12
      ,p_cpt_attribute13                =>  p_cpt_attribute13
      ,p_cpt_attribute14                =>  p_cpt_attribute14
      ,p_cpt_attribute15                =>  p_cpt_attribute15
      ,p_cpt_attribute16                =>  p_cpt_attribute16
      ,p_cpt_attribute17                =>  p_cpt_attribute17
      ,p_cpt_attribute18                =>  p_cpt_attribute18
      ,p_cpt_attribute19                =>  p_cpt_attribute19
      ,p_cpt_attribute20                =>  p_cpt_attribute20
      ,p_cpt_attribute21                =>  p_cpt_attribute21
      ,p_cpt_attribute22                =>  p_cpt_attribute22
      ,p_cpt_attribute23                =>  p_cpt_attribute23
      ,p_cpt_attribute24                =>  p_cpt_attribute24
      ,p_cpt_attribute25                =>  p_cpt_attribute25
      ,p_cpt_attribute26                =>  p_cpt_attribute26
      ,p_cpt_attribute27                =>  p_cpt_attribute27
      ,p_cpt_attribute28                =>  p_cpt_attribute28
      ,p_cpt_attribute29                =>  p_cpt_attribute29
      ,p_cpt_attribute30                =>  p_cpt_attribute30
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_opt_id                         =>  p_opt_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CMBN_PTIP_OPT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_CMBN_PTIP_OPT
    --
  end;
  --
  ben_cpt_ins.ins
    (
     p_cmbn_ptip_opt_id              => l_cmbn_ptip_opt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_cpt_attribute_category        => p_cpt_attribute_category
    ,p_cpt_attribute1                => p_cpt_attribute1
    ,p_cpt_attribute2                => p_cpt_attribute2
    ,p_cpt_attribute3                => p_cpt_attribute3
    ,p_cpt_attribute4                => p_cpt_attribute4
    ,p_cpt_attribute5                => p_cpt_attribute5
    ,p_cpt_attribute6                => p_cpt_attribute6
    ,p_cpt_attribute7                => p_cpt_attribute7
    ,p_cpt_attribute8                => p_cpt_attribute8
    ,p_cpt_attribute9                => p_cpt_attribute9
    ,p_cpt_attribute10               => p_cpt_attribute10
    ,p_cpt_attribute11               => p_cpt_attribute11
    ,p_cpt_attribute12               => p_cpt_attribute12
    ,p_cpt_attribute13               => p_cpt_attribute13
    ,p_cpt_attribute14               => p_cpt_attribute14
    ,p_cpt_attribute15               => p_cpt_attribute15
    ,p_cpt_attribute16               => p_cpt_attribute16
    ,p_cpt_attribute17               => p_cpt_attribute17
    ,p_cpt_attribute18               => p_cpt_attribute18
    ,p_cpt_attribute19               => p_cpt_attribute19
    ,p_cpt_attribute20               => p_cpt_attribute20
    ,p_cpt_attribute21               => p_cpt_attribute21
    ,p_cpt_attribute22               => p_cpt_attribute22
    ,p_cpt_attribute23               => p_cpt_attribute23
    ,p_cpt_attribute24               => p_cpt_attribute24
    ,p_cpt_attribute25               => p_cpt_attribute25
    ,p_cpt_attribute26               => p_cpt_attribute26
    ,p_cpt_attribute27               => p_cpt_attribute27
    ,p_cpt_attribute28               => p_cpt_attribute28
    ,p_cpt_attribute29               => p_cpt_attribute29
    ,p_cpt_attribute30               => p_cpt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_ptip_id                       => p_ptip_id
    ,p_pgm_id                        => p_pgm_id
    ,p_opt_id                        => p_opt_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_CMBN_PTIP_OPT
    --
    ben_CMBN_PTIP_OPT_bk1.create_CMBN_PTIP_OPT_a
      (
       p_cmbn_ptip_opt_id               =>  l_cmbn_ptip_opt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_cpt_attribute_category         =>  p_cpt_attribute_category
      ,p_cpt_attribute1                 =>  p_cpt_attribute1
      ,p_cpt_attribute2                 =>  p_cpt_attribute2
      ,p_cpt_attribute3                 =>  p_cpt_attribute3
      ,p_cpt_attribute4                 =>  p_cpt_attribute4
      ,p_cpt_attribute5                 =>  p_cpt_attribute5
      ,p_cpt_attribute6                 =>  p_cpt_attribute6
      ,p_cpt_attribute7                 =>  p_cpt_attribute7
      ,p_cpt_attribute8                 =>  p_cpt_attribute8
      ,p_cpt_attribute9                 =>  p_cpt_attribute9
      ,p_cpt_attribute10                =>  p_cpt_attribute10
      ,p_cpt_attribute11                =>  p_cpt_attribute11
      ,p_cpt_attribute12                =>  p_cpt_attribute12
      ,p_cpt_attribute13                =>  p_cpt_attribute13
      ,p_cpt_attribute14                =>  p_cpt_attribute14
      ,p_cpt_attribute15                =>  p_cpt_attribute15
      ,p_cpt_attribute16                =>  p_cpt_attribute16
      ,p_cpt_attribute17                =>  p_cpt_attribute17
      ,p_cpt_attribute18                =>  p_cpt_attribute18
      ,p_cpt_attribute19                =>  p_cpt_attribute19
      ,p_cpt_attribute20                =>  p_cpt_attribute20
      ,p_cpt_attribute21                =>  p_cpt_attribute21
      ,p_cpt_attribute22                =>  p_cpt_attribute22
      ,p_cpt_attribute23                =>  p_cpt_attribute23
      ,p_cpt_attribute24                =>  p_cpt_attribute24
      ,p_cpt_attribute25                =>  p_cpt_attribute25
      ,p_cpt_attribute26                =>  p_cpt_attribute26
      ,p_cpt_attribute27                =>  p_cpt_attribute27
      ,p_cpt_attribute28                =>  p_cpt_attribute28
      ,p_cpt_attribute29                =>  p_cpt_attribute29
      ,p_cpt_attribute30                =>  p_cpt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_opt_id                         =>  p_opt_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CMBN_PTIP_OPT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_CMBN_PTIP_OPT
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
  p_cmbn_ptip_opt_id := l_cmbn_ptip_opt_id;
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
    ROLLBACK TO create_CMBN_PTIP_OPT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cmbn_ptip_opt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_CMBN_PTIP_OPT;
    raise;
    --
end create_CMBN_PTIP_OPT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_CMBN_PTIP_OPT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_CMBN_PTIP_OPT
  (p_validate                       in  boolean   default false
  ,p_cmbn_ptip_opt_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cpt_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cpt_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CMBN_PTIP_OPT';
  l_object_version_number ben_cmbn_ptip_opt_f.object_version_number%TYPE;
  l_effective_start_date ben_cmbn_ptip_opt_f.effective_start_date%TYPE;
  l_effective_end_date ben_cmbn_ptip_opt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_CMBN_PTIP_OPT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_CMBN_PTIP_OPT
    --
    ben_CMBN_PTIP_OPT_bk2.update_CMBN_PTIP_OPT_b
      (
       p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_cpt_attribute_category         =>  p_cpt_attribute_category
      ,p_cpt_attribute1                 =>  p_cpt_attribute1
      ,p_cpt_attribute2                 =>  p_cpt_attribute2
      ,p_cpt_attribute3                 =>  p_cpt_attribute3
      ,p_cpt_attribute4                 =>  p_cpt_attribute4
      ,p_cpt_attribute5                 =>  p_cpt_attribute5
      ,p_cpt_attribute6                 =>  p_cpt_attribute6
      ,p_cpt_attribute7                 =>  p_cpt_attribute7
      ,p_cpt_attribute8                 =>  p_cpt_attribute8
      ,p_cpt_attribute9                 =>  p_cpt_attribute9
      ,p_cpt_attribute10                =>  p_cpt_attribute10
      ,p_cpt_attribute11                =>  p_cpt_attribute11
      ,p_cpt_attribute12                =>  p_cpt_attribute12
      ,p_cpt_attribute13                =>  p_cpt_attribute13
      ,p_cpt_attribute14                =>  p_cpt_attribute14
      ,p_cpt_attribute15                =>  p_cpt_attribute15
      ,p_cpt_attribute16                =>  p_cpt_attribute16
      ,p_cpt_attribute17                =>  p_cpt_attribute17
      ,p_cpt_attribute18                =>  p_cpt_attribute18
      ,p_cpt_attribute19                =>  p_cpt_attribute19
      ,p_cpt_attribute20                =>  p_cpt_attribute20
      ,p_cpt_attribute21                =>  p_cpt_attribute21
      ,p_cpt_attribute22                =>  p_cpt_attribute22
      ,p_cpt_attribute23                =>  p_cpt_attribute23
      ,p_cpt_attribute24                =>  p_cpt_attribute24
      ,p_cpt_attribute25                =>  p_cpt_attribute25
      ,p_cpt_attribute26                =>  p_cpt_attribute26
      ,p_cpt_attribute27                =>  p_cpt_attribute27
      ,p_cpt_attribute28                =>  p_cpt_attribute28
      ,p_cpt_attribute29                =>  p_cpt_attribute29
      ,p_cpt_attribute30                =>  p_cpt_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_opt_id                         =>  p_opt_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CMBN_PTIP_OPT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_CMBN_PTIP_OPT
    --
  end;
  --
  ben_cpt_upd.upd
    (
     p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_cpt_attribute_category        => p_cpt_attribute_category
    ,p_cpt_attribute1                => p_cpt_attribute1
    ,p_cpt_attribute2                => p_cpt_attribute2
    ,p_cpt_attribute3                => p_cpt_attribute3
    ,p_cpt_attribute4                => p_cpt_attribute4
    ,p_cpt_attribute5                => p_cpt_attribute5
    ,p_cpt_attribute6                => p_cpt_attribute6
    ,p_cpt_attribute7                => p_cpt_attribute7
    ,p_cpt_attribute8                => p_cpt_attribute8
    ,p_cpt_attribute9                => p_cpt_attribute9
    ,p_cpt_attribute10               => p_cpt_attribute10
    ,p_cpt_attribute11               => p_cpt_attribute11
    ,p_cpt_attribute12               => p_cpt_attribute12
    ,p_cpt_attribute13               => p_cpt_attribute13
    ,p_cpt_attribute14               => p_cpt_attribute14
    ,p_cpt_attribute15               => p_cpt_attribute15
    ,p_cpt_attribute16               => p_cpt_attribute16
    ,p_cpt_attribute17               => p_cpt_attribute17
    ,p_cpt_attribute18               => p_cpt_attribute18
    ,p_cpt_attribute19               => p_cpt_attribute19
    ,p_cpt_attribute20               => p_cpt_attribute20
    ,p_cpt_attribute21               => p_cpt_attribute21
    ,p_cpt_attribute22               => p_cpt_attribute22
    ,p_cpt_attribute23               => p_cpt_attribute23
    ,p_cpt_attribute24               => p_cpt_attribute24
    ,p_cpt_attribute25               => p_cpt_attribute25
    ,p_cpt_attribute26               => p_cpt_attribute26
    ,p_cpt_attribute27               => p_cpt_attribute27
    ,p_cpt_attribute28               => p_cpt_attribute28
    ,p_cpt_attribute29               => p_cpt_attribute29
    ,p_cpt_attribute30               => p_cpt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_ptip_id                       => p_ptip_id
    ,p_pgm_id                        =>  p_pgm_id
    ,p_opt_id                        =>  p_opt_id
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_CMBN_PTIP_OPT
    --
    ben_CMBN_PTIP_OPT_bk2.update_CMBN_PTIP_OPT_a
      (
       p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_cpt_attribute_category         =>  p_cpt_attribute_category
      ,p_cpt_attribute1                 =>  p_cpt_attribute1
      ,p_cpt_attribute2                 =>  p_cpt_attribute2
      ,p_cpt_attribute3                 =>  p_cpt_attribute3
      ,p_cpt_attribute4                 =>  p_cpt_attribute4
      ,p_cpt_attribute5                 =>  p_cpt_attribute5
      ,p_cpt_attribute6                 =>  p_cpt_attribute6
      ,p_cpt_attribute7                 =>  p_cpt_attribute7
      ,p_cpt_attribute8                 =>  p_cpt_attribute8
      ,p_cpt_attribute9                 =>  p_cpt_attribute9
      ,p_cpt_attribute10                =>  p_cpt_attribute10
      ,p_cpt_attribute11                =>  p_cpt_attribute11
      ,p_cpt_attribute12                =>  p_cpt_attribute12
      ,p_cpt_attribute13                =>  p_cpt_attribute13
      ,p_cpt_attribute14                =>  p_cpt_attribute14
      ,p_cpt_attribute15                =>  p_cpt_attribute15
      ,p_cpt_attribute16                =>  p_cpt_attribute16
      ,p_cpt_attribute17                =>  p_cpt_attribute17
      ,p_cpt_attribute18                =>  p_cpt_attribute18
      ,p_cpt_attribute19                =>  p_cpt_attribute19
      ,p_cpt_attribute20                =>  p_cpt_attribute20
      ,p_cpt_attribute21                =>  p_cpt_attribute21
      ,p_cpt_attribute22                =>  p_cpt_attribute22
      ,p_cpt_attribute23                =>  p_cpt_attribute23
      ,p_cpt_attribute24                =>  p_cpt_attribute24
      ,p_cpt_attribute25                =>  p_cpt_attribute25
      ,p_cpt_attribute26                =>  p_cpt_attribute26
      ,p_cpt_attribute27                =>  p_cpt_attribute27
      ,p_cpt_attribute28                =>  p_cpt_attribute28
      ,p_cpt_attribute29                =>  p_cpt_attribute29
      ,p_cpt_attribute30                =>  p_cpt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_opt_id                         =>  p_opt_id
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CMBN_PTIP_OPT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_CMBN_PTIP_OPT
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
    ROLLBACK TO update_CMBN_PTIP_OPT;
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
    ROLLBACK TO update_CMBN_PTIP_OPT;
    raise;
    --
end update_CMBN_PTIP_OPT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CMBN_PTIP_OPT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CMBN_PTIP_OPT
  (p_validate                       in  boolean  default false
  ,p_cmbn_ptip_opt_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CMBN_PTIP_OPT';
  l_object_version_number ben_cmbn_ptip_opt_f.object_version_number%TYPE;
  l_effective_start_date ben_cmbn_ptip_opt_f.effective_start_date%TYPE;
  l_effective_end_date ben_cmbn_ptip_opt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_CMBN_PTIP_OPT;
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
    -- Start of API User Hook for the before hook of delete_CMBN_PTIP_OPT
    --
    ben_CMBN_PTIP_OPT_bk3.delete_CMBN_PTIP_OPT_b
      (
       p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CMBN_PTIP_OPT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_CMBN_PTIP_OPT
    --
  end;
  --
  ben_cpt_del.del
    (
     p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_CMBN_PTIP_OPT
    --
    ben_CMBN_PTIP_OPT_bk3.delete_CMBN_PTIP_OPT_a
      (
       p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CMBN_PTIP_OPT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_CMBN_PTIP_OPT
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
    ROLLBACK TO delete_CMBN_PTIP_OPT;
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
    ROLLBACK TO delete_CMBN_PTIP_OPT;
    raise;
    --
end delete_CMBN_PTIP_OPT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cmbn_ptip_opt_id                   in     number
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
  ben_cpt_shd.lck
    (
      p_cmbn_ptip_opt_id                 => p_cmbn_ptip_opt_id
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
end ben_CMBN_PTIP_OPT_api;

/
