--------------------------------------------------------
--  DDL for Package Body BEN_LER_CHG_PTIP_ENRT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LER_CHG_PTIP_ENRT_API" as
/* $Header: belctapi.pkb 115.2 2002/12/31 23:59:27 mmudigon ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ler_chg_ptip_enrt_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ler_chg_ptip_enrt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ler_chg_ptip_enrt
  (p_validate                       in  boolean   default false
  ,p_ler_chg_ptip_enrt_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2  default null
  ,p_stl_elig_cant_chg_flag         in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_dflt_enrt_cd                   in  varchar2  default null
  ,p_dflt_enrt_rl                   in  varchar2  default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_enrt_rl                        in  varchar2  default null
  ,p_tco_chg_enrt_cd                in  varchar2  default null
  ,p_ptip_id                        in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_lct_attribute_category         in  varchar2  default null
  ,p_lct_attribute1                 in  varchar2  default null
  ,p_lct_attribute2                 in  varchar2  default null
  ,p_lct_attribute3                 in  varchar2  default null
  ,p_lct_attribute4                 in  varchar2  default null
  ,p_lct_attribute5                 in  varchar2  default null
  ,p_lct_attribute6                 in  varchar2  default null
  ,p_lct_attribute7                 in  varchar2  default null
  ,p_lct_attribute8                 in  varchar2  default null
  ,p_lct_attribute9                 in  varchar2  default null
  ,p_lct_attribute10                in  varchar2  default null
  ,p_lct_attribute11                in  varchar2  default null
  ,p_lct_attribute12                in  varchar2  default null
  ,p_lct_attribute13                in  varchar2  default null
  ,p_lct_attribute14                in  varchar2  default null
  ,p_lct_attribute15                in  varchar2  default null
  ,p_lct_attribute16                in  varchar2  default null
  ,p_lct_attribute17                in  varchar2  default null
  ,p_lct_attribute18                in  varchar2  default null
  ,p_lct_attribute19                in  varchar2  default null
  ,p_lct_attribute20                in  varchar2  default null
  ,p_lct_attribute21                in  varchar2  default null
  ,p_lct_attribute22                in  varchar2  default null
  ,p_lct_attribute23                in  varchar2  default null
  ,p_lct_attribute24                in  varchar2  default null
  ,p_lct_attribute25                in  varchar2  default null
  ,p_lct_attribute26                in  varchar2  default null
  ,p_lct_attribute27                in  varchar2  default null
  ,p_lct_attribute28                in  varchar2  default null
  ,p_lct_attribute29                in  varchar2  default null
  ,p_lct_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ler_chg_ptip_enrt_id ben_ler_chg_ptip_enrt_f.ler_chg_ptip_enrt_id%TYPE;
  l_effective_start_date ben_ler_chg_ptip_enrt_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_chg_ptip_enrt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ler_chg_ptip_enrt';
  l_object_version_number ben_ler_chg_ptip_enrt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ler_chg_ptip_enrt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ler_chg_ptip_enrt
    --
    ben_ler_chg_ptip_enrt_bk1.create_ler_chg_ptip_enrt_b
      (
       p_crnt_enrt_prclds_chg_flag      =>  p_crnt_enrt_prclds_chg_flag
      ,p_stl_elig_cant_chg_flag         =>  p_stl_elig_cant_chg_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_rl                   =>  p_dflt_enrt_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_tco_chg_enrt_cd                =>  p_tco_chg_enrt_cd
      ,p_ptip_id                        =>  p_ptip_id
      ,p_ler_id                         =>  p_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lct_attribute_category         =>  p_lct_attribute_category
      ,p_lct_attribute1                 =>  p_lct_attribute1
      ,p_lct_attribute2                 =>  p_lct_attribute2
      ,p_lct_attribute3                 =>  p_lct_attribute3
      ,p_lct_attribute4                 =>  p_lct_attribute4
      ,p_lct_attribute5                 =>  p_lct_attribute5
      ,p_lct_attribute6                 =>  p_lct_attribute6
      ,p_lct_attribute7                 =>  p_lct_attribute7
      ,p_lct_attribute8                 =>  p_lct_attribute8
      ,p_lct_attribute9                 =>  p_lct_attribute9
      ,p_lct_attribute10                =>  p_lct_attribute10
      ,p_lct_attribute11                =>  p_lct_attribute11
      ,p_lct_attribute12                =>  p_lct_attribute12
      ,p_lct_attribute13                =>  p_lct_attribute13
      ,p_lct_attribute14                =>  p_lct_attribute14
      ,p_lct_attribute15                =>  p_lct_attribute15
      ,p_lct_attribute16                =>  p_lct_attribute16
      ,p_lct_attribute17                =>  p_lct_attribute17
      ,p_lct_attribute18                =>  p_lct_attribute18
      ,p_lct_attribute19                =>  p_lct_attribute19
      ,p_lct_attribute20                =>  p_lct_attribute20
      ,p_lct_attribute21                =>  p_lct_attribute21
      ,p_lct_attribute22                =>  p_lct_attribute22
      ,p_lct_attribute23                =>  p_lct_attribute23
      ,p_lct_attribute24                =>  p_lct_attribute24
      ,p_lct_attribute25                =>  p_lct_attribute25
      ,p_lct_attribute26                =>  p_lct_attribute26
      ,p_lct_attribute27                =>  p_lct_attribute27
      ,p_lct_attribute28                =>  p_lct_attribute28
      ,p_lct_attribute29                =>  p_lct_attribute29
      ,p_lct_attribute30                =>  p_lct_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ler_chg_ptip_enrt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ler_chg_ptip_enrt
    --
  end;
  --
  ben_lct_ins.ins
    (
     p_ler_chg_ptip_enrt_id          => l_ler_chg_ptip_enrt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_crnt_enrt_prclds_chg_flag     => p_crnt_enrt_prclds_chg_flag
    ,p_stl_elig_cant_chg_flag        => p_stl_elig_cant_chg_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_dflt_enrt_cd                  => p_dflt_enrt_cd
    ,p_dflt_enrt_rl                  => p_dflt_enrt_rl
    ,p_enrt_cd                       => p_enrt_cd
    ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
    ,p_enrt_rl                       => p_enrt_rl
    ,p_tco_chg_enrt_cd               => p_tco_chg_enrt_cd
    ,p_ptip_id                       => p_ptip_id
    ,p_ler_id                        => p_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_lct_attribute_category        => p_lct_attribute_category
    ,p_lct_attribute1                => p_lct_attribute1
    ,p_lct_attribute2                => p_lct_attribute2
    ,p_lct_attribute3                => p_lct_attribute3
    ,p_lct_attribute4                => p_lct_attribute4
    ,p_lct_attribute5                => p_lct_attribute5
    ,p_lct_attribute6                => p_lct_attribute6
    ,p_lct_attribute7                => p_lct_attribute7
    ,p_lct_attribute8                => p_lct_attribute8
    ,p_lct_attribute9                => p_lct_attribute9
    ,p_lct_attribute10               => p_lct_attribute10
    ,p_lct_attribute11               => p_lct_attribute11
    ,p_lct_attribute12               => p_lct_attribute12
    ,p_lct_attribute13               => p_lct_attribute13
    ,p_lct_attribute14               => p_lct_attribute14
    ,p_lct_attribute15               => p_lct_attribute15
    ,p_lct_attribute16               => p_lct_attribute16
    ,p_lct_attribute17               => p_lct_attribute17
    ,p_lct_attribute18               => p_lct_attribute18
    ,p_lct_attribute19               => p_lct_attribute19
    ,p_lct_attribute20               => p_lct_attribute20
    ,p_lct_attribute21               => p_lct_attribute21
    ,p_lct_attribute22               => p_lct_attribute22
    ,p_lct_attribute23               => p_lct_attribute23
    ,p_lct_attribute24               => p_lct_attribute24
    ,p_lct_attribute25               => p_lct_attribute25
    ,p_lct_attribute26               => p_lct_attribute26
    ,p_lct_attribute27               => p_lct_attribute27
    ,p_lct_attribute28               => p_lct_attribute28
    ,p_lct_attribute29               => p_lct_attribute29
    ,p_lct_attribute30               => p_lct_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ler_chg_ptip_enrt
    --
    ben_ler_chg_ptip_enrt_bk1.create_ler_chg_ptip_enrt_a
      (
       p_ler_chg_ptip_enrt_id           =>  l_ler_chg_ptip_enrt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_crnt_enrt_prclds_chg_flag      =>  p_crnt_enrt_prclds_chg_flag
      ,p_stl_elig_cant_chg_flag         =>  p_stl_elig_cant_chg_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_rl                   =>  p_dflt_enrt_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_tco_chg_enrt_cd                =>  p_tco_chg_enrt_cd
      ,p_ptip_id                        =>  p_ptip_id
      ,p_ler_id                         =>  p_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lct_attribute_category         =>  p_lct_attribute_category
      ,p_lct_attribute1                 =>  p_lct_attribute1
      ,p_lct_attribute2                 =>  p_lct_attribute2
      ,p_lct_attribute3                 =>  p_lct_attribute3
      ,p_lct_attribute4                 =>  p_lct_attribute4
      ,p_lct_attribute5                 =>  p_lct_attribute5
      ,p_lct_attribute6                 =>  p_lct_attribute6
      ,p_lct_attribute7                 =>  p_lct_attribute7
      ,p_lct_attribute8                 =>  p_lct_attribute8
      ,p_lct_attribute9                 =>  p_lct_attribute9
      ,p_lct_attribute10                =>  p_lct_attribute10
      ,p_lct_attribute11                =>  p_lct_attribute11
      ,p_lct_attribute12                =>  p_lct_attribute12
      ,p_lct_attribute13                =>  p_lct_attribute13
      ,p_lct_attribute14                =>  p_lct_attribute14
      ,p_lct_attribute15                =>  p_lct_attribute15
      ,p_lct_attribute16                =>  p_lct_attribute16
      ,p_lct_attribute17                =>  p_lct_attribute17
      ,p_lct_attribute18                =>  p_lct_attribute18
      ,p_lct_attribute19                =>  p_lct_attribute19
      ,p_lct_attribute20                =>  p_lct_attribute20
      ,p_lct_attribute21                =>  p_lct_attribute21
      ,p_lct_attribute22                =>  p_lct_attribute22
      ,p_lct_attribute23                =>  p_lct_attribute23
      ,p_lct_attribute24                =>  p_lct_attribute24
      ,p_lct_attribute25                =>  p_lct_attribute25
      ,p_lct_attribute26                =>  p_lct_attribute26
      ,p_lct_attribute27                =>  p_lct_attribute27
      ,p_lct_attribute28                =>  p_lct_attribute28
      ,p_lct_attribute29                =>  p_lct_attribute29
      ,p_lct_attribute30                =>  p_lct_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ler_chg_ptip_enrt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ler_chg_ptip_enrt
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
  p_ler_chg_ptip_enrt_id := l_ler_chg_ptip_enrt_id;
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
    ROLLBACK TO create_ler_chg_ptip_enrt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ler_chg_ptip_enrt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ler_chg_ptip_enrt;
    raise;
    --
end create_ler_chg_ptip_enrt;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ler_chg_ptip_enrt >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ler_chg_ptip_enrt
  (p_validate                       in  boolean   default false
  ,p_ler_chg_ptip_enrt_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2  default hr_api.g_varchar2
  ,p_stl_elig_cant_chg_flag         in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_rl                   in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rl                        in  varchar2  default hr_api.g_varchar2
  ,p_tco_chg_enrt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_lct_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_lct_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ler_chg_ptip_enrt';
  l_object_version_number ben_ler_chg_ptip_enrt_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_chg_ptip_enrt_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_chg_ptip_enrt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ler_chg_ptip_enrt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ler_chg_ptip_enrt
    --
    ben_ler_chg_ptip_enrt_bk2.update_ler_chg_ptip_enrt_b
      (
       p_ler_chg_ptip_enrt_id           =>  p_ler_chg_ptip_enrt_id
      ,p_crnt_enrt_prclds_chg_flag      =>  p_crnt_enrt_prclds_chg_flag
      ,p_stl_elig_cant_chg_flag         =>  p_stl_elig_cant_chg_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_rl                   =>  p_dflt_enrt_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_tco_chg_enrt_cd                =>  p_tco_chg_enrt_cd
      ,p_ptip_id                        =>  p_ptip_id
      ,p_ler_id                         =>  p_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lct_attribute_category         =>  p_lct_attribute_category
      ,p_lct_attribute1                 =>  p_lct_attribute1
      ,p_lct_attribute2                 =>  p_lct_attribute2
      ,p_lct_attribute3                 =>  p_lct_attribute3
      ,p_lct_attribute4                 =>  p_lct_attribute4
      ,p_lct_attribute5                 =>  p_lct_attribute5
      ,p_lct_attribute6                 =>  p_lct_attribute6
      ,p_lct_attribute7                 =>  p_lct_attribute7
      ,p_lct_attribute8                 =>  p_lct_attribute8
      ,p_lct_attribute9                 =>  p_lct_attribute9
      ,p_lct_attribute10                =>  p_lct_attribute10
      ,p_lct_attribute11                =>  p_lct_attribute11
      ,p_lct_attribute12                =>  p_lct_attribute12
      ,p_lct_attribute13                =>  p_lct_attribute13
      ,p_lct_attribute14                =>  p_lct_attribute14
      ,p_lct_attribute15                =>  p_lct_attribute15
      ,p_lct_attribute16                =>  p_lct_attribute16
      ,p_lct_attribute17                =>  p_lct_attribute17
      ,p_lct_attribute18                =>  p_lct_attribute18
      ,p_lct_attribute19                =>  p_lct_attribute19
      ,p_lct_attribute20                =>  p_lct_attribute20
      ,p_lct_attribute21                =>  p_lct_attribute21
      ,p_lct_attribute22                =>  p_lct_attribute22
      ,p_lct_attribute23                =>  p_lct_attribute23
      ,p_lct_attribute24                =>  p_lct_attribute24
      ,p_lct_attribute25                =>  p_lct_attribute25
      ,p_lct_attribute26                =>  p_lct_attribute26
      ,p_lct_attribute27                =>  p_lct_attribute27
      ,p_lct_attribute28                =>  p_lct_attribute28
      ,p_lct_attribute29                =>  p_lct_attribute29
      ,p_lct_attribute30                =>  p_lct_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ler_chg_ptip_enrt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ler_chg_ptip_enrt
    --
  end;
  --
  ben_lct_upd.upd
    (
     p_ler_chg_ptip_enrt_id          => p_ler_chg_ptip_enrt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_crnt_enrt_prclds_chg_flag     => p_crnt_enrt_prclds_chg_flag
    ,p_stl_elig_cant_chg_flag        => p_stl_elig_cant_chg_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_dflt_enrt_cd                  => p_dflt_enrt_cd
    ,p_dflt_enrt_rl                  => p_dflt_enrt_rl
    ,p_enrt_cd                       => p_enrt_cd
    ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
    ,p_enrt_rl                       => p_enrt_rl
    ,p_tco_chg_enrt_cd               => p_tco_chg_enrt_cd
    ,p_ptip_id                       => p_ptip_id
    ,p_ler_id                        => p_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_lct_attribute_category        => p_lct_attribute_category
    ,p_lct_attribute1                => p_lct_attribute1
    ,p_lct_attribute2                => p_lct_attribute2
    ,p_lct_attribute3                => p_lct_attribute3
    ,p_lct_attribute4                => p_lct_attribute4
    ,p_lct_attribute5                => p_lct_attribute5
    ,p_lct_attribute6                => p_lct_attribute6
    ,p_lct_attribute7                => p_lct_attribute7
    ,p_lct_attribute8                => p_lct_attribute8
    ,p_lct_attribute9                => p_lct_attribute9
    ,p_lct_attribute10               => p_lct_attribute10
    ,p_lct_attribute11               => p_lct_attribute11
    ,p_lct_attribute12               => p_lct_attribute12
    ,p_lct_attribute13               => p_lct_attribute13
    ,p_lct_attribute14               => p_lct_attribute14
    ,p_lct_attribute15               => p_lct_attribute15
    ,p_lct_attribute16               => p_lct_attribute16
    ,p_lct_attribute17               => p_lct_attribute17
    ,p_lct_attribute18               => p_lct_attribute18
    ,p_lct_attribute19               => p_lct_attribute19
    ,p_lct_attribute20               => p_lct_attribute20
    ,p_lct_attribute21               => p_lct_attribute21
    ,p_lct_attribute22               => p_lct_attribute22
    ,p_lct_attribute23               => p_lct_attribute23
    ,p_lct_attribute24               => p_lct_attribute24
    ,p_lct_attribute25               => p_lct_attribute25
    ,p_lct_attribute26               => p_lct_attribute26
    ,p_lct_attribute27               => p_lct_attribute27
    ,p_lct_attribute28               => p_lct_attribute28
    ,p_lct_attribute29               => p_lct_attribute29
    ,p_lct_attribute30               => p_lct_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ler_chg_ptip_enrt
    --
    ben_ler_chg_ptip_enrt_bk2.update_ler_chg_ptip_enrt_a
      (
       p_ler_chg_ptip_enrt_id           =>  p_ler_chg_ptip_enrt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_crnt_enrt_prclds_chg_flag      =>  p_crnt_enrt_prclds_chg_flag
      ,p_stl_elig_cant_chg_flag         =>  p_stl_elig_cant_chg_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_rl                   =>  p_dflt_enrt_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_tco_chg_enrt_cd                =>  p_tco_chg_enrt_cd
      ,p_ptip_id                        =>  p_ptip_id
      ,p_ler_id                         =>  p_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lct_attribute_category         =>  p_lct_attribute_category
      ,p_lct_attribute1                 =>  p_lct_attribute1
      ,p_lct_attribute2                 =>  p_lct_attribute2
      ,p_lct_attribute3                 =>  p_lct_attribute3
      ,p_lct_attribute4                 =>  p_lct_attribute4
      ,p_lct_attribute5                 =>  p_lct_attribute5
      ,p_lct_attribute6                 =>  p_lct_attribute6
      ,p_lct_attribute7                 =>  p_lct_attribute7
      ,p_lct_attribute8                 =>  p_lct_attribute8
      ,p_lct_attribute9                 =>  p_lct_attribute9
      ,p_lct_attribute10                =>  p_lct_attribute10
      ,p_lct_attribute11                =>  p_lct_attribute11
      ,p_lct_attribute12                =>  p_lct_attribute12
      ,p_lct_attribute13                =>  p_lct_attribute13
      ,p_lct_attribute14                =>  p_lct_attribute14
      ,p_lct_attribute15                =>  p_lct_attribute15
      ,p_lct_attribute16                =>  p_lct_attribute16
      ,p_lct_attribute17                =>  p_lct_attribute17
      ,p_lct_attribute18                =>  p_lct_attribute18
      ,p_lct_attribute19                =>  p_lct_attribute19
      ,p_lct_attribute20                =>  p_lct_attribute20
      ,p_lct_attribute21                =>  p_lct_attribute21
      ,p_lct_attribute22                =>  p_lct_attribute22
      ,p_lct_attribute23                =>  p_lct_attribute23
      ,p_lct_attribute24                =>  p_lct_attribute24
      ,p_lct_attribute25                =>  p_lct_attribute25
      ,p_lct_attribute26                =>  p_lct_attribute26
      ,p_lct_attribute27                =>  p_lct_attribute27
      ,p_lct_attribute28                =>  p_lct_attribute28
      ,p_lct_attribute29                =>  p_lct_attribute29
      ,p_lct_attribute30                =>  p_lct_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ler_chg_ptip_enrt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ler_chg_ptip_enrt
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
    ROLLBACK TO update_ler_chg_ptip_enrt;
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
    ROLLBACK TO update_ler_chg_ptip_enrt;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_ler_chg_ptip_enrt;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ler_chg_ptip_enrt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ler_chg_ptip_enrt
  (p_validate                       in  boolean  default false
  ,p_ler_chg_ptip_enrt_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ler_chg_ptip_enrt';
  l_object_version_number ben_ler_chg_ptip_enrt_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_chg_ptip_enrt_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_chg_ptip_enrt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ler_chg_ptip_enrt;
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
    -- Start of API User Hook for the before hook of delete_ler_chg_ptip_enrt
    --
    ben_ler_chg_ptip_enrt_bk3.delete_ler_chg_ptip_enrt_b
      (
       p_ler_chg_ptip_enrt_id           =>  p_ler_chg_ptip_enrt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ler_chg_ptip_enrt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ler_chg_ptip_enrt
    --
  end;
  --
  ben_lct_del.del
    (
     p_ler_chg_ptip_enrt_id          => p_ler_chg_ptip_enrt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ler_chg_ptip_enrt
    --
    ben_ler_chg_ptip_enrt_bk3.delete_ler_chg_ptip_enrt_a
      (
       p_ler_chg_ptip_enrt_id           =>  p_ler_chg_ptip_enrt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ler_chg_ptip_enrt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ler_chg_ptip_enrt
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
    ROLLBACK TO delete_ler_chg_ptip_enrt;
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
    ROLLBACK TO delete_ler_chg_ptip_enrt;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_ler_chg_ptip_enrt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ler_chg_ptip_enrt_id                   in     number
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
  ben_lct_shd.lck
    (
      p_ler_chg_ptip_enrt_id                 => p_ler_chg_ptip_enrt_id
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
end ben_ler_chg_ptip_enrt_api;

/
