--------------------------------------------------------
--  DDL for Package Body BEN_ENRT_PERD_FOR_PL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENRT_PERD_FOR_PL_API" as
/* $Header: beerpapi.pkb 115.2 2002/12/16 13:25:19 vsethi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_enrt_perd_for_pl_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_enrt_perd_for_pl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_enrt_perd_for_pl
  (p_validate                       in  boolean   default false
  ,p_enrt_perd_for_pl_id            out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_enrt_perd_id                   in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_lee_rsn_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_erp_attribute_category         in  varchar2  default null
  ,p_erp_attribute1                 in  varchar2  default null
  ,p_erp_attribute2                 in  varchar2  default null
  ,p_erp_attribute3                 in  varchar2  default null
  ,p_erp_attribute4                 in  varchar2  default null
  ,p_erp_attribute5                 in  varchar2  default null
  ,p_erp_attribute6                 in  varchar2  default null
  ,p_erp_attribute7                 in  varchar2  default null
  ,p_erp_attribute8                 in  varchar2  default null
  ,p_erp_attribute9                 in  varchar2  default null
  ,p_erp_attribute10                in  varchar2  default null
  ,p_erp_attribute11                in  varchar2  default null
  ,p_erp_attribute12                in  varchar2  default null
  ,p_erp_attribute13                in  varchar2  default null
  ,p_erp_attribute14                in  varchar2  default null
  ,p_erp_attribute15                in  varchar2  default null
  ,p_erp_attribute16                in  varchar2  default null
  ,p_erp_attribute17                in  varchar2  default null
  ,p_erp_attribute18                in  varchar2  default null
  ,p_erp_attribute19                in  varchar2  default null
  ,p_erp_attribute20                in  varchar2  default null
  ,p_erp_attribute21                in  varchar2  default null
  ,p_erp_attribute22                in  varchar2  default null
  ,p_erp_attribute23                in  varchar2  default null
  ,p_erp_attribute24                in  varchar2  default null
  ,p_erp_attribute25                in  varchar2  default null
  ,p_erp_attribute26                in  varchar2  default null
  ,p_erp_attribute27                in  varchar2  default null
  ,p_erp_attribute28                in  varchar2  default null
  ,p_erp_attribute29                in  varchar2  default null
  ,p_erp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_enrt_perd_for_pl_id ben_enrt_perd_for_pl_f.enrt_perd_for_pl_id%TYPE;
  l_effective_start_date ben_enrt_perd_for_pl_f.effective_start_date%TYPE;
  l_effective_end_date ben_enrt_perd_for_pl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_enrt_perd_for_pl';
  l_object_version_number ben_enrt_perd_for_pl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_enrt_perd_for_pl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_enrt_perd_for_pl
    --
    ben_enrt_perd_for_pl_bk1.create_enrt_perd_for_pl_b
      (
       p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_pl_id                          =>  p_pl_id
      ,p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_erp_attribute_category         =>  p_erp_attribute_category
      ,p_erp_attribute1                 =>  p_erp_attribute1
      ,p_erp_attribute2                 =>  p_erp_attribute2
      ,p_erp_attribute3                 =>  p_erp_attribute3
      ,p_erp_attribute4                 =>  p_erp_attribute4
      ,p_erp_attribute5                 =>  p_erp_attribute5
      ,p_erp_attribute6                 =>  p_erp_attribute6
      ,p_erp_attribute7                 =>  p_erp_attribute7
      ,p_erp_attribute8                 =>  p_erp_attribute8
      ,p_erp_attribute9                 =>  p_erp_attribute9
      ,p_erp_attribute10                =>  p_erp_attribute10
      ,p_erp_attribute11                =>  p_erp_attribute11
      ,p_erp_attribute12                =>  p_erp_attribute12
      ,p_erp_attribute13                =>  p_erp_attribute13
      ,p_erp_attribute14                =>  p_erp_attribute14
      ,p_erp_attribute15                =>  p_erp_attribute15
      ,p_erp_attribute16                =>  p_erp_attribute16
      ,p_erp_attribute17                =>  p_erp_attribute17
      ,p_erp_attribute18                =>  p_erp_attribute18
      ,p_erp_attribute19                =>  p_erp_attribute19
      ,p_erp_attribute20                =>  p_erp_attribute20
      ,p_erp_attribute21                =>  p_erp_attribute21
      ,p_erp_attribute22                =>  p_erp_attribute22
      ,p_erp_attribute23                =>  p_erp_attribute23
      ,p_erp_attribute24                =>  p_erp_attribute24
      ,p_erp_attribute25                =>  p_erp_attribute25
      ,p_erp_attribute26                =>  p_erp_attribute26
      ,p_erp_attribute27                =>  p_erp_attribute27
      ,p_erp_attribute28                =>  p_erp_attribute28
      ,p_erp_attribute29                =>  p_erp_attribute29
      ,p_erp_attribute30                =>  p_erp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_enrt_perd_for_pl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_enrt_perd_for_pl
    --
  end;
  --
  ben_erp_ins.ins
    (
     p_enrt_perd_for_pl_id           => l_enrt_perd_for_pl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_pl_id                         => p_pl_id
    ,p_lee_rsn_id                    => p_lee_rsn_id
    ,p_business_group_id             => p_business_group_id
    ,p_erp_attribute_category        => p_erp_attribute_category
    ,p_erp_attribute1                => p_erp_attribute1
    ,p_erp_attribute2                => p_erp_attribute2
    ,p_erp_attribute3                => p_erp_attribute3
    ,p_erp_attribute4                => p_erp_attribute4
    ,p_erp_attribute5                => p_erp_attribute5
    ,p_erp_attribute6                => p_erp_attribute6
    ,p_erp_attribute7                => p_erp_attribute7
    ,p_erp_attribute8                => p_erp_attribute8
    ,p_erp_attribute9                => p_erp_attribute9
    ,p_erp_attribute10               => p_erp_attribute10
    ,p_erp_attribute11               => p_erp_attribute11
    ,p_erp_attribute12               => p_erp_attribute12
    ,p_erp_attribute13               => p_erp_attribute13
    ,p_erp_attribute14               => p_erp_attribute14
    ,p_erp_attribute15               => p_erp_attribute15
    ,p_erp_attribute16               => p_erp_attribute16
    ,p_erp_attribute17               => p_erp_attribute17
    ,p_erp_attribute18               => p_erp_attribute18
    ,p_erp_attribute19               => p_erp_attribute19
    ,p_erp_attribute20               => p_erp_attribute20
    ,p_erp_attribute21               => p_erp_attribute21
    ,p_erp_attribute22               => p_erp_attribute22
    ,p_erp_attribute23               => p_erp_attribute23
    ,p_erp_attribute24               => p_erp_attribute24
    ,p_erp_attribute25               => p_erp_attribute25
    ,p_erp_attribute26               => p_erp_attribute26
    ,p_erp_attribute27               => p_erp_attribute27
    ,p_erp_attribute28               => p_erp_attribute28
    ,p_erp_attribute29               => p_erp_attribute29
    ,p_erp_attribute30               => p_erp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_enrt_perd_for_pl
    --
    ben_enrt_perd_for_pl_bk1.create_enrt_perd_for_pl_a
      (
       p_enrt_perd_for_pl_id            =>  l_enrt_perd_for_pl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_pl_id                          =>  p_pl_id
      ,p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_erp_attribute_category         =>  p_erp_attribute_category
      ,p_erp_attribute1                 =>  p_erp_attribute1
      ,p_erp_attribute2                 =>  p_erp_attribute2
      ,p_erp_attribute3                 =>  p_erp_attribute3
      ,p_erp_attribute4                 =>  p_erp_attribute4
      ,p_erp_attribute5                 =>  p_erp_attribute5
      ,p_erp_attribute6                 =>  p_erp_attribute6
      ,p_erp_attribute7                 =>  p_erp_attribute7
      ,p_erp_attribute8                 =>  p_erp_attribute8
      ,p_erp_attribute9                 =>  p_erp_attribute9
      ,p_erp_attribute10                =>  p_erp_attribute10
      ,p_erp_attribute11                =>  p_erp_attribute11
      ,p_erp_attribute12                =>  p_erp_attribute12
      ,p_erp_attribute13                =>  p_erp_attribute13
      ,p_erp_attribute14                =>  p_erp_attribute14
      ,p_erp_attribute15                =>  p_erp_attribute15
      ,p_erp_attribute16                =>  p_erp_attribute16
      ,p_erp_attribute17                =>  p_erp_attribute17
      ,p_erp_attribute18                =>  p_erp_attribute18
      ,p_erp_attribute19                =>  p_erp_attribute19
      ,p_erp_attribute20                =>  p_erp_attribute20
      ,p_erp_attribute21                =>  p_erp_attribute21
      ,p_erp_attribute22                =>  p_erp_attribute22
      ,p_erp_attribute23                =>  p_erp_attribute23
      ,p_erp_attribute24                =>  p_erp_attribute24
      ,p_erp_attribute25                =>  p_erp_attribute25
      ,p_erp_attribute26                =>  p_erp_attribute26
      ,p_erp_attribute27                =>  p_erp_attribute27
      ,p_erp_attribute28                =>  p_erp_attribute28
      ,p_erp_attribute29                =>  p_erp_attribute29
      ,p_erp_attribute30                =>  p_erp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_enrt_perd_for_pl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_enrt_perd_for_pl
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
  p_enrt_perd_for_pl_id := l_enrt_perd_for_pl_id;
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
    ROLLBACK TO create_enrt_perd_for_pl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_enrt_perd_for_pl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_enrt_perd_for_pl;
    raise;
    --
end create_enrt_perd_for_pl;
-- ----------------------------------------------------------------------------
-- |------------------------< update_enrt_perd_for_pl >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_perd_for_pl
  (p_validate                       in  boolean   default false
  ,p_enrt_perd_for_pl_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_lee_rsn_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_erp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_erp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_enrt_perd_for_pl';
  l_object_version_number ben_enrt_perd_for_pl_f.object_version_number%TYPE;
  l_effective_start_date ben_enrt_perd_for_pl_f.effective_start_date%TYPE;
  l_effective_end_date ben_enrt_perd_for_pl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_enrt_perd_for_pl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_enrt_perd_for_pl
    --
    ben_enrt_perd_for_pl_bk2.update_enrt_perd_for_pl_b
      (
       p_enrt_perd_for_pl_id            =>  p_enrt_perd_for_pl_id
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_pl_id                          =>  p_pl_id
      ,p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_erp_attribute_category         =>  p_erp_attribute_category
      ,p_erp_attribute1                 =>  p_erp_attribute1
      ,p_erp_attribute2                 =>  p_erp_attribute2
      ,p_erp_attribute3                 =>  p_erp_attribute3
      ,p_erp_attribute4                 =>  p_erp_attribute4
      ,p_erp_attribute5                 =>  p_erp_attribute5
      ,p_erp_attribute6                 =>  p_erp_attribute6
      ,p_erp_attribute7                 =>  p_erp_attribute7
      ,p_erp_attribute8                 =>  p_erp_attribute8
      ,p_erp_attribute9                 =>  p_erp_attribute9
      ,p_erp_attribute10                =>  p_erp_attribute10
      ,p_erp_attribute11                =>  p_erp_attribute11
      ,p_erp_attribute12                =>  p_erp_attribute12
      ,p_erp_attribute13                =>  p_erp_attribute13
      ,p_erp_attribute14                =>  p_erp_attribute14
      ,p_erp_attribute15                =>  p_erp_attribute15
      ,p_erp_attribute16                =>  p_erp_attribute16
      ,p_erp_attribute17                =>  p_erp_attribute17
      ,p_erp_attribute18                =>  p_erp_attribute18
      ,p_erp_attribute19                =>  p_erp_attribute19
      ,p_erp_attribute20                =>  p_erp_attribute20
      ,p_erp_attribute21                =>  p_erp_attribute21
      ,p_erp_attribute22                =>  p_erp_attribute22
      ,p_erp_attribute23                =>  p_erp_attribute23
      ,p_erp_attribute24                =>  p_erp_attribute24
      ,p_erp_attribute25                =>  p_erp_attribute25
      ,p_erp_attribute26                =>  p_erp_attribute26
      ,p_erp_attribute27                =>  p_erp_attribute27
      ,p_erp_attribute28                =>  p_erp_attribute28
      ,p_erp_attribute29                =>  p_erp_attribute29
      ,p_erp_attribute30                =>  p_erp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_enrt_perd_for_pl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_enrt_perd_for_pl
    --
  end;
  --
  ben_erp_upd.upd
    (
     p_enrt_perd_for_pl_id           => p_enrt_perd_for_pl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_pl_id                         => p_pl_id
    ,p_lee_rsn_id                    => p_lee_rsn_id
    ,p_business_group_id             => p_business_group_id
    ,p_erp_attribute_category        => p_erp_attribute_category
    ,p_erp_attribute1                => p_erp_attribute1
    ,p_erp_attribute2                => p_erp_attribute2
    ,p_erp_attribute3                => p_erp_attribute3
    ,p_erp_attribute4                => p_erp_attribute4
    ,p_erp_attribute5                => p_erp_attribute5
    ,p_erp_attribute6                => p_erp_attribute6
    ,p_erp_attribute7                => p_erp_attribute7
    ,p_erp_attribute8                => p_erp_attribute8
    ,p_erp_attribute9                => p_erp_attribute9
    ,p_erp_attribute10               => p_erp_attribute10
    ,p_erp_attribute11               => p_erp_attribute11
    ,p_erp_attribute12               => p_erp_attribute12
    ,p_erp_attribute13               => p_erp_attribute13
    ,p_erp_attribute14               => p_erp_attribute14
    ,p_erp_attribute15               => p_erp_attribute15
    ,p_erp_attribute16               => p_erp_attribute16
    ,p_erp_attribute17               => p_erp_attribute17
    ,p_erp_attribute18               => p_erp_attribute18
    ,p_erp_attribute19               => p_erp_attribute19
    ,p_erp_attribute20               => p_erp_attribute20
    ,p_erp_attribute21               => p_erp_attribute21
    ,p_erp_attribute22               => p_erp_attribute22
    ,p_erp_attribute23               => p_erp_attribute23
    ,p_erp_attribute24               => p_erp_attribute24
    ,p_erp_attribute25               => p_erp_attribute25
    ,p_erp_attribute26               => p_erp_attribute26
    ,p_erp_attribute27               => p_erp_attribute27
    ,p_erp_attribute28               => p_erp_attribute28
    ,p_erp_attribute29               => p_erp_attribute29
    ,p_erp_attribute30               => p_erp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_enrt_perd_for_pl
    --
    ben_enrt_perd_for_pl_bk2.update_enrt_perd_for_pl_a
      (
       p_enrt_perd_for_pl_id            =>  p_enrt_perd_for_pl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_pl_id                          =>  p_pl_id
      ,p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_erp_attribute_category         =>  p_erp_attribute_category
      ,p_erp_attribute1                 =>  p_erp_attribute1
      ,p_erp_attribute2                 =>  p_erp_attribute2
      ,p_erp_attribute3                 =>  p_erp_attribute3
      ,p_erp_attribute4                 =>  p_erp_attribute4
      ,p_erp_attribute5                 =>  p_erp_attribute5
      ,p_erp_attribute6                 =>  p_erp_attribute6
      ,p_erp_attribute7                 =>  p_erp_attribute7
      ,p_erp_attribute8                 =>  p_erp_attribute8
      ,p_erp_attribute9                 =>  p_erp_attribute9
      ,p_erp_attribute10                =>  p_erp_attribute10
      ,p_erp_attribute11                =>  p_erp_attribute11
      ,p_erp_attribute12                =>  p_erp_attribute12
      ,p_erp_attribute13                =>  p_erp_attribute13
      ,p_erp_attribute14                =>  p_erp_attribute14
      ,p_erp_attribute15                =>  p_erp_attribute15
      ,p_erp_attribute16                =>  p_erp_attribute16
      ,p_erp_attribute17                =>  p_erp_attribute17
      ,p_erp_attribute18                =>  p_erp_attribute18
      ,p_erp_attribute19                =>  p_erp_attribute19
      ,p_erp_attribute20                =>  p_erp_attribute20
      ,p_erp_attribute21                =>  p_erp_attribute21
      ,p_erp_attribute22                =>  p_erp_attribute22
      ,p_erp_attribute23                =>  p_erp_attribute23
      ,p_erp_attribute24                =>  p_erp_attribute24
      ,p_erp_attribute25                =>  p_erp_attribute25
      ,p_erp_attribute26                =>  p_erp_attribute26
      ,p_erp_attribute27                =>  p_erp_attribute27
      ,p_erp_attribute28                =>  p_erp_attribute28
      ,p_erp_attribute29                =>  p_erp_attribute29
      ,p_erp_attribute30                =>  p_erp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_enrt_perd_for_pl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_enrt_perd_for_pl
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
    ROLLBACK TO update_enrt_perd_for_pl;
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
    ROLLBACK TO update_enrt_perd_for_pl;
    raise;
    --
end update_enrt_perd_for_pl;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrt_perd_for_pl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_perd_for_pl
  (p_validate                       in  boolean  default false
  ,p_enrt_perd_for_pl_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_enrt_perd_for_pl';
  l_object_version_number ben_enrt_perd_for_pl_f.object_version_number%TYPE;
  l_effective_start_date ben_enrt_perd_for_pl_f.effective_start_date%TYPE;
  l_effective_end_date ben_enrt_perd_for_pl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_enrt_perd_for_pl;
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
    -- Start of API User Hook for the before hook of delete_enrt_perd_for_pl
    --
    ben_enrt_perd_for_pl_bk3.delete_enrt_perd_for_pl_b
      (
       p_enrt_perd_for_pl_id            =>  p_enrt_perd_for_pl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_enrt_perd_for_pl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_enrt_perd_for_pl
    --
  end;
  --
  ben_erp_del.del
    (
     p_enrt_perd_for_pl_id           => p_enrt_perd_for_pl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_enrt_perd_for_pl
    --
    ben_enrt_perd_for_pl_bk3.delete_enrt_perd_for_pl_a
      (
       p_enrt_perd_for_pl_id            =>  p_enrt_perd_for_pl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_enrt_perd_for_pl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_enrt_perd_for_pl
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
    ROLLBACK TO delete_enrt_perd_for_pl;
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
    ROLLBACK TO delete_enrt_perd_for_pl;
    raise;
    --
end delete_enrt_perd_for_pl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_enrt_perd_for_pl_id                   in     number
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
  ben_erp_shd.lck
    (
      p_enrt_perd_for_pl_id                 => p_enrt_perd_for_pl_id
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
end ben_enrt_perd_for_pl_api;

/
