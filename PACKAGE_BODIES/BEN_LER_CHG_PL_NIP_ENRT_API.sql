--------------------------------------------------------
--  DDL for Package Body BEN_LER_CHG_PL_NIP_ENRT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LER_CHG_PL_NIP_ENRT_API" as
/* $Header: belpeapi.pkb 115.5 2002/12/13 06:57:33 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Ler_Chg_Pl_Nip_Enrt_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Ler_Chg_Pl_Nip_Enrt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Ler_Chg_Pl_Nip_Enrt
  (p_validate                       in  boolean   default false
  ,p_ler_chg_pl_nip_enrt_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_tco_chg_enrt_cd                in  varchar2  default null
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2  default null
  ,p_dflt_enrt_cd                   in  varchar2  default null
  ,p_dflt_enrt_rl                   in  number    default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_enrt_rl                        in  number    default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_stl_elig_cant_chg_flag         in  varchar2  default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_lpe_attribute_category         in  varchar2  default null
  ,p_lpe_attribute1                 in  varchar2  default null
  ,p_lpe_attribute2                 in  varchar2  default null
  ,p_lpe_attribute3                 in  varchar2  default null
  ,p_lpe_attribute4                 in  varchar2  default null
  ,p_lpe_attribute5                 in  varchar2  default null
  ,p_lpe_attribute6                 in  varchar2  default null
  ,p_lpe_attribute7                 in  varchar2  default null
  ,p_lpe_attribute8                 in  varchar2  default null
  ,p_lpe_attribute9                 in  varchar2  default null
  ,p_lpe_attribute10                in  varchar2  default null
  ,p_lpe_attribute11                in  varchar2  default null
  ,p_lpe_attribute12                in  varchar2  default null
  ,p_lpe_attribute13                in  varchar2  default null
  ,p_lpe_attribute14                in  varchar2  default null
  ,p_lpe_attribute15                in  varchar2  default null
  ,p_lpe_attribute16                in  varchar2  default null
  ,p_lpe_attribute17                in  varchar2  default null
  ,p_lpe_attribute18                in  varchar2  default null
  ,p_lpe_attribute19                in  varchar2  default null
  ,p_lpe_attribute20                in  varchar2  default null
  ,p_lpe_attribute21                in  varchar2  default null
  ,p_lpe_attribute22                in  varchar2  default null
  ,p_lpe_attribute23                in  varchar2  default null
  ,p_lpe_attribute24                in  varchar2  default null
  ,p_lpe_attribute25                in  varchar2  default null
  ,p_lpe_attribute26                in  varchar2  default null
  ,p_lpe_attribute27                in  varchar2  default null
  ,p_lpe_attribute28                in  varchar2  default null
  ,p_lpe_attribute29                in  varchar2  default null
  ,p_lpe_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ler_chg_pl_nip_enrt_id ben_ler_chg_pl_nip_enrt_f.ler_chg_pl_nip_enrt_id%TYPE;
  l_effective_start_date ben_ler_chg_pl_nip_enrt_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_chg_pl_nip_enrt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Ler_Chg_Pl_Nip_Enrt';
  l_object_version_number ben_ler_chg_pl_nip_enrt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Ler_Chg_Pl_Nip_Enrt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Ler_Chg_Pl_Nip_Enrt
    --
    ben_Ler_Chg_Pl_Nip_Enrt_bk1.create_Ler_Chg_Pl_Nip_Enrt_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ler_id                         =>  p_ler_id
      ,p_tco_chg_enrt_cd                =>  p_tco_chg_enrt_cd
      ,p_crnt_enrt_prclds_chg_flag      =>  p_crnt_enrt_prclds_chg_flag
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_rl                   =>  p_dflt_enrt_rl
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_stl_elig_cant_chg_flag         =>  p_stl_elig_cant_chg_flag
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_lpe_attribute_category         =>  p_lpe_attribute_category
      ,p_lpe_attribute1                 =>  p_lpe_attribute1
      ,p_lpe_attribute2                 =>  p_lpe_attribute2
      ,p_lpe_attribute3                 =>  p_lpe_attribute3
      ,p_lpe_attribute4                 =>  p_lpe_attribute4
      ,p_lpe_attribute5                 =>  p_lpe_attribute5
      ,p_lpe_attribute6                 =>  p_lpe_attribute6
      ,p_lpe_attribute7                 =>  p_lpe_attribute7
      ,p_lpe_attribute8                 =>  p_lpe_attribute8
      ,p_lpe_attribute9                 =>  p_lpe_attribute9
      ,p_lpe_attribute10                =>  p_lpe_attribute10
      ,p_lpe_attribute11                =>  p_lpe_attribute11
      ,p_lpe_attribute12                =>  p_lpe_attribute12
      ,p_lpe_attribute13                =>  p_lpe_attribute13
      ,p_lpe_attribute14                =>  p_lpe_attribute14
      ,p_lpe_attribute15                =>  p_lpe_attribute15
      ,p_lpe_attribute16                =>  p_lpe_attribute16
      ,p_lpe_attribute17                =>  p_lpe_attribute17
      ,p_lpe_attribute18                =>  p_lpe_attribute18
      ,p_lpe_attribute19                =>  p_lpe_attribute19
      ,p_lpe_attribute20                =>  p_lpe_attribute20
      ,p_lpe_attribute21                =>  p_lpe_attribute21
      ,p_lpe_attribute22                =>  p_lpe_attribute22
      ,p_lpe_attribute23                =>  p_lpe_attribute23
      ,p_lpe_attribute24                =>  p_lpe_attribute24
      ,p_lpe_attribute25                =>  p_lpe_attribute25
      ,p_lpe_attribute26                =>  p_lpe_attribute26
      ,p_lpe_attribute27                =>  p_lpe_attribute27
      ,p_lpe_attribute28                =>  p_lpe_attribute28
      ,p_lpe_attribute29                =>  p_lpe_attribute29
      ,p_lpe_attribute30                =>  p_lpe_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Ler_Chg_Pl_Nip_Enrt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Ler_Chg_Pl_Nip_Enrt
    --
  end;
  --
  ben_lpe_ins.ins
    (
     p_ler_chg_pl_nip_enrt_id        => l_ler_chg_pl_nip_enrt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_ler_id                        => p_ler_id
    ,p_tco_chg_enrt_cd               => p_tco_chg_enrt_cd
    ,p_crnt_enrt_prclds_chg_flag     => p_crnt_enrt_prclds_chg_flag
    ,p_dflt_enrt_cd                  => p_dflt_enrt_cd
    ,p_dflt_enrt_rl                  => p_dflt_enrt_rl
    ,p_dflt_flag                     => p_dflt_flag
    ,p_enrt_rl                       => p_enrt_rl
    ,p_enrt_cd                       => p_enrt_cd
    ,p_stl_elig_cant_chg_flag        => p_stl_elig_cant_chg_flag
    ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
    ,p_auto_enrt_mthd_rl             => p_auto_enrt_mthd_rl
    ,p_lpe_attribute_category        => p_lpe_attribute_category
    ,p_lpe_attribute1                => p_lpe_attribute1
    ,p_lpe_attribute2                => p_lpe_attribute2
    ,p_lpe_attribute3                => p_lpe_attribute3
    ,p_lpe_attribute4                => p_lpe_attribute4
    ,p_lpe_attribute5                => p_lpe_attribute5
    ,p_lpe_attribute6                => p_lpe_attribute6
    ,p_lpe_attribute7                => p_lpe_attribute7
    ,p_lpe_attribute8                => p_lpe_attribute8
    ,p_lpe_attribute9                => p_lpe_attribute9
    ,p_lpe_attribute10               => p_lpe_attribute10
    ,p_lpe_attribute11               => p_lpe_attribute11
    ,p_lpe_attribute12               => p_lpe_attribute12
    ,p_lpe_attribute13               => p_lpe_attribute13
    ,p_lpe_attribute14               => p_lpe_attribute14
    ,p_lpe_attribute15               => p_lpe_attribute15
    ,p_lpe_attribute16               => p_lpe_attribute16
    ,p_lpe_attribute17               => p_lpe_attribute17
    ,p_lpe_attribute18               => p_lpe_attribute18
    ,p_lpe_attribute19               => p_lpe_attribute19
    ,p_lpe_attribute20               => p_lpe_attribute20
    ,p_lpe_attribute21               => p_lpe_attribute21
    ,p_lpe_attribute22               => p_lpe_attribute22
    ,p_lpe_attribute23               => p_lpe_attribute23
    ,p_lpe_attribute24               => p_lpe_attribute24
    ,p_lpe_attribute25               => p_lpe_attribute25
    ,p_lpe_attribute26               => p_lpe_attribute26
    ,p_lpe_attribute27               => p_lpe_attribute27
    ,p_lpe_attribute28               => p_lpe_attribute28
    ,p_lpe_attribute29               => p_lpe_attribute29
    ,p_lpe_attribute30               => p_lpe_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Ler_Chg_Pl_Nip_Enrt
    --
    ben_Ler_Chg_Pl_Nip_Enrt_bk1.create_Ler_Chg_Pl_Nip_Enrt_a
      (
       p_ler_chg_pl_nip_enrt_id         =>  l_ler_chg_pl_nip_enrt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ler_id                         =>  p_ler_id
      ,p_tco_chg_enrt_cd                =>  p_tco_chg_enrt_cd
      ,p_crnt_enrt_prclds_chg_flag      =>  p_crnt_enrt_prclds_chg_flag
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_rl                   =>  p_dflt_enrt_rl
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_stl_elig_cant_chg_flag         =>  p_stl_elig_cant_chg_flag
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_lpe_attribute_category         =>  p_lpe_attribute_category
      ,p_lpe_attribute1                 =>  p_lpe_attribute1
      ,p_lpe_attribute2                 =>  p_lpe_attribute2
      ,p_lpe_attribute3                 =>  p_lpe_attribute3
      ,p_lpe_attribute4                 =>  p_lpe_attribute4
      ,p_lpe_attribute5                 =>  p_lpe_attribute5
      ,p_lpe_attribute6                 =>  p_lpe_attribute6
      ,p_lpe_attribute7                 =>  p_lpe_attribute7
      ,p_lpe_attribute8                 =>  p_lpe_attribute8
      ,p_lpe_attribute9                 =>  p_lpe_attribute9
      ,p_lpe_attribute10                =>  p_lpe_attribute10
      ,p_lpe_attribute11                =>  p_lpe_attribute11
      ,p_lpe_attribute12                =>  p_lpe_attribute12
      ,p_lpe_attribute13                =>  p_lpe_attribute13
      ,p_lpe_attribute14                =>  p_lpe_attribute14
      ,p_lpe_attribute15                =>  p_lpe_attribute15
      ,p_lpe_attribute16                =>  p_lpe_attribute16
      ,p_lpe_attribute17                =>  p_lpe_attribute17
      ,p_lpe_attribute18                =>  p_lpe_attribute18
      ,p_lpe_attribute19                =>  p_lpe_attribute19
      ,p_lpe_attribute20                =>  p_lpe_attribute20
      ,p_lpe_attribute21                =>  p_lpe_attribute21
      ,p_lpe_attribute22                =>  p_lpe_attribute22
      ,p_lpe_attribute23                =>  p_lpe_attribute23
      ,p_lpe_attribute24                =>  p_lpe_attribute24
      ,p_lpe_attribute25                =>  p_lpe_attribute25
      ,p_lpe_attribute26                =>  p_lpe_attribute26
      ,p_lpe_attribute27                =>  p_lpe_attribute27
      ,p_lpe_attribute28                =>  p_lpe_attribute28
      ,p_lpe_attribute29                =>  p_lpe_attribute29
      ,p_lpe_attribute30                =>  p_lpe_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Ler_Chg_Pl_Nip_Enrt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Ler_Chg_Pl_Nip_Enrt
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
  p_ler_chg_pl_nip_enrt_id := l_ler_chg_pl_nip_enrt_id;
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
    ROLLBACK TO create_Ler_Chg_Pl_Nip_Enrt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ler_chg_pl_nip_enrt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Ler_Chg_Pl_Nip_Enrt;
    raise;
    --
end create_Ler_Chg_Pl_Nip_Enrt;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Ler_Chg_Pl_Nip_Enrt >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Chg_Pl_Nip_Enrt
  (p_validate                       in  boolean   default false
  ,p_ler_chg_pl_nip_enrt_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_tco_chg_enrt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_rl                   in  number    default hr_api.g_number
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_stl_elig_cant_chg_flag         in  varchar2  default hr_api.g_varchar2
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_lpe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_lpe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Ler_Chg_Pl_Nip_Enrt';
  l_object_version_number ben_ler_chg_pl_nip_enrt_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_chg_pl_nip_enrt_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_chg_pl_nip_enrt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Ler_Chg_Pl_Nip_Enrt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Ler_Chg_Pl_Nip_Enrt
    --
    ben_Ler_Chg_Pl_Nip_Enrt_bk2.update_Ler_Chg_Pl_Nip_Enrt_b
      (
       p_ler_chg_pl_nip_enrt_id         =>  p_ler_chg_pl_nip_enrt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ler_id                         =>  p_ler_id
      ,p_tco_chg_enrt_cd                =>  p_tco_chg_enrt_cd
      ,p_crnt_enrt_prclds_chg_flag      =>  p_crnt_enrt_prclds_chg_flag
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_rl                   =>  p_dflt_enrt_rl
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_stl_elig_cant_chg_flag         =>  p_stl_elig_cant_chg_flag
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_lpe_attribute_category         =>  p_lpe_attribute_category
      ,p_lpe_attribute1                 =>  p_lpe_attribute1
      ,p_lpe_attribute2                 =>  p_lpe_attribute2
      ,p_lpe_attribute3                 =>  p_lpe_attribute3
      ,p_lpe_attribute4                 =>  p_lpe_attribute4
      ,p_lpe_attribute5                 =>  p_lpe_attribute5
      ,p_lpe_attribute6                 =>  p_lpe_attribute6
      ,p_lpe_attribute7                 =>  p_lpe_attribute7
      ,p_lpe_attribute8                 =>  p_lpe_attribute8
      ,p_lpe_attribute9                 =>  p_lpe_attribute9
      ,p_lpe_attribute10                =>  p_lpe_attribute10
      ,p_lpe_attribute11                =>  p_lpe_attribute11
      ,p_lpe_attribute12                =>  p_lpe_attribute12
      ,p_lpe_attribute13                =>  p_lpe_attribute13
      ,p_lpe_attribute14                =>  p_lpe_attribute14
      ,p_lpe_attribute15                =>  p_lpe_attribute15
      ,p_lpe_attribute16                =>  p_lpe_attribute16
      ,p_lpe_attribute17                =>  p_lpe_attribute17
      ,p_lpe_attribute18                =>  p_lpe_attribute18
      ,p_lpe_attribute19                =>  p_lpe_attribute19
      ,p_lpe_attribute20                =>  p_lpe_attribute20
      ,p_lpe_attribute21                =>  p_lpe_attribute21
      ,p_lpe_attribute22                =>  p_lpe_attribute22
      ,p_lpe_attribute23                =>  p_lpe_attribute23
      ,p_lpe_attribute24                =>  p_lpe_attribute24
      ,p_lpe_attribute25                =>  p_lpe_attribute25
      ,p_lpe_attribute26                =>  p_lpe_attribute26
      ,p_lpe_attribute27                =>  p_lpe_attribute27
      ,p_lpe_attribute28                =>  p_lpe_attribute28
      ,p_lpe_attribute29                =>  p_lpe_attribute29
      ,p_lpe_attribute30                =>  p_lpe_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Ler_Chg_Pl_Nip_Enrt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Ler_Chg_Pl_Nip_Enrt
    --
  end;
  --
  ben_lpe_upd.upd
    (
     p_ler_chg_pl_nip_enrt_id        => p_ler_chg_pl_nip_enrt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_ler_id                        => p_ler_id
    ,p_tco_chg_enrt_cd               => p_tco_chg_enrt_cd
    ,p_crnt_enrt_prclds_chg_flag     => p_crnt_enrt_prclds_chg_flag
    ,p_dflt_enrt_cd                  => p_dflt_enrt_cd
    ,p_dflt_enrt_rl                  => p_dflt_enrt_rl
    ,p_dflt_flag                     => p_dflt_flag
    ,p_enrt_rl                       => p_enrt_rl
    ,p_enrt_cd                       => p_enrt_cd
    ,p_stl_elig_cant_chg_flag        => p_stl_elig_cant_chg_flag
    ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
    ,p_auto_enrt_mthd_rl             => p_auto_enrt_mthd_rl
    ,p_lpe_attribute_category        => p_lpe_attribute_category
    ,p_lpe_attribute1                => p_lpe_attribute1
    ,p_lpe_attribute2                => p_lpe_attribute2
    ,p_lpe_attribute3                => p_lpe_attribute3
    ,p_lpe_attribute4                => p_lpe_attribute4
    ,p_lpe_attribute5                => p_lpe_attribute5
    ,p_lpe_attribute6                => p_lpe_attribute6
    ,p_lpe_attribute7                => p_lpe_attribute7
    ,p_lpe_attribute8                => p_lpe_attribute8
    ,p_lpe_attribute9                => p_lpe_attribute9
    ,p_lpe_attribute10               => p_lpe_attribute10
    ,p_lpe_attribute11               => p_lpe_attribute11
    ,p_lpe_attribute12               => p_lpe_attribute12
    ,p_lpe_attribute13               => p_lpe_attribute13
    ,p_lpe_attribute14               => p_lpe_attribute14
    ,p_lpe_attribute15               => p_lpe_attribute15
    ,p_lpe_attribute16               => p_lpe_attribute16
    ,p_lpe_attribute17               => p_lpe_attribute17
    ,p_lpe_attribute18               => p_lpe_attribute18
    ,p_lpe_attribute19               => p_lpe_attribute19
    ,p_lpe_attribute20               => p_lpe_attribute20
    ,p_lpe_attribute21               => p_lpe_attribute21
    ,p_lpe_attribute22               => p_lpe_attribute22
    ,p_lpe_attribute23               => p_lpe_attribute23
    ,p_lpe_attribute24               => p_lpe_attribute24
    ,p_lpe_attribute25               => p_lpe_attribute25
    ,p_lpe_attribute26               => p_lpe_attribute26
    ,p_lpe_attribute27               => p_lpe_attribute27
    ,p_lpe_attribute28               => p_lpe_attribute28
    ,p_lpe_attribute29               => p_lpe_attribute29
    ,p_lpe_attribute30               => p_lpe_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Ler_Chg_Pl_Nip_Enrt
    --
    ben_Ler_Chg_Pl_Nip_Enrt_bk2.update_Ler_Chg_Pl_Nip_Enrt_a
      (
       p_ler_chg_pl_nip_enrt_id         =>  p_ler_chg_pl_nip_enrt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ler_id                         =>  p_ler_id
      ,p_tco_chg_enrt_cd                =>  p_tco_chg_enrt_cd
      ,p_crnt_enrt_prclds_chg_flag      =>  p_crnt_enrt_prclds_chg_flag
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_rl                   =>  p_dflt_enrt_rl
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_stl_elig_cant_chg_flag         =>  p_stl_elig_cant_chg_flag
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_lpe_attribute_category         =>  p_lpe_attribute_category
      ,p_lpe_attribute1                 =>  p_lpe_attribute1
      ,p_lpe_attribute2                 =>  p_lpe_attribute2
      ,p_lpe_attribute3                 =>  p_lpe_attribute3
      ,p_lpe_attribute4                 =>  p_lpe_attribute4
      ,p_lpe_attribute5                 =>  p_lpe_attribute5
      ,p_lpe_attribute6                 =>  p_lpe_attribute6
      ,p_lpe_attribute7                 =>  p_lpe_attribute7
      ,p_lpe_attribute8                 =>  p_lpe_attribute8
      ,p_lpe_attribute9                 =>  p_lpe_attribute9
      ,p_lpe_attribute10                =>  p_lpe_attribute10
      ,p_lpe_attribute11                =>  p_lpe_attribute11
      ,p_lpe_attribute12                =>  p_lpe_attribute12
      ,p_lpe_attribute13                =>  p_lpe_attribute13
      ,p_lpe_attribute14                =>  p_lpe_attribute14
      ,p_lpe_attribute15                =>  p_lpe_attribute15
      ,p_lpe_attribute16                =>  p_lpe_attribute16
      ,p_lpe_attribute17                =>  p_lpe_attribute17
      ,p_lpe_attribute18                =>  p_lpe_attribute18
      ,p_lpe_attribute19                =>  p_lpe_attribute19
      ,p_lpe_attribute20                =>  p_lpe_attribute20
      ,p_lpe_attribute21                =>  p_lpe_attribute21
      ,p_lpe_attribute22                =>  p_lpe_attribute22
      ,p_lpe_attribute23                =>  p_lpe_attribute23
      ,p_lpe_attribute24                =>  p_lpe_attribute24
      ,p_lpe_attribute25                =>  p_lpe_attribute25
      ,p_lpe_attribute26                =>  p_lpe_attribute26
      ,p_lpe_attribute27                =>  p_lpe_attribute27
      ,p_lpe_attribute28                =>  p_lpe_attribute28
      ,p_lpe_attribute29                =>  p_lpe_attribute29
      ,p_lpe_attribute30                =>  p_lpe_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Ler_Chg_Pl_Nip_Enrt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Ler_Chg_Pl_Nip_Enrt
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
    ROLLBACK TO update_Ler_Chg_Pl_Nip_Enrt;
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
    ROLLBACK TO update_Ler_Chg_Pl_Nip_Enrt;
    raise;
    --
end update_Ler_Chg_Pl_Nip_Enrt;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Ler_Chg_Pl_Nip_Enrt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ler_Chg_Pl_Nip_Enrt
  (p_validate                       in  boolean  default false
  ,p_ler_chg_pl_nip_enrt_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Ler_Chg_Pl_Nip_Enrt';
  l_object_version_number ben_ler_chg_pl_nip_enrt_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_chg_pl_nip_enrt_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_chg_pl_nip_enrt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Ler_Chg_Pl_Nip_Enrt;
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
    -- Start of API User Hook for the before hook of delete_Ler_Chg_Pl_Nip_Enrt
    --
    ben_Ler_Chg_Pl_Nip_Enrt_bk3.delete_Ler_Chg_Pl_Nip_Enrt_b
      (
       p_ler_chg_pl_nip_enrt_id         =>  p_ler_chg_pl_nip_enrt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Ler_Chg_Pl_Nip_Enrt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Ler_Chg_Pl_Nip_Enrt
    --
  end;
  --
  ben_lpe_del.del
    (
     p_ler_chg_pl_nip_enrt_id        => p_ler_chg_pl_nip_enrt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Ler_Chg_Pl_Nip_Enrt
    --
    ben_Ler_Chg_Pl_Nip_Enrt_bk3.delete_Ler_Chg_Pl_Nip_Enrt_a
      (
       p_ler_chg_pl_nip_enrt_id         =>  p_ler_chg_pl_nip_enrt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Ler_Chg_Pl_Nip_Enrt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Ler_Chg_Pl_Nip_Enrt
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
    ROLLBACK TO delete_Ler_Chg_Pl_Nip_Enrt;
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
    ROLLBACK TO delete_Ler_Chg_Pl_Nip_Enrt;
    raise;
    --
end delete_Ler_Chg_Pl_Nip_Enrt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ler_chg_pl_nip_enrt_id                   in     number
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
  ben_lpe_shd.lck
    (
      p_ler_chg_pl_nip_enrt_id                 => p_ler_chg_pl_nip_enrt_id
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
end ben_Ler_Chg_Pl_Nip_Enrt_api;

/
