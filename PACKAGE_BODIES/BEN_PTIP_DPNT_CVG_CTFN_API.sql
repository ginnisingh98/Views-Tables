--------------------------------------------------------
--  DDL for Package Body BEN_PTIP_DPNT_CVG_CTFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTIP_DPNT_CVG_CTFN_API" as
/* $Header: bepydapi.pkb 115.4 2002/12/13 08:31:17 bmanyam ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Ptip_Dpnt_Cvg_Ctfn_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Ptip_Dpnt_Cvg_Ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Ptip_Dpnt_Cvg_Ctfn
  (p_validate                       in  boolean   default false
  ,p_ptip_dpnt_cvg_ctfn_id          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pfd_flag                       in  varchar2  default 'N'
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2  default 'N'
  ,p_ctfn_rqd_when_rl               in  number    default null
  ,p_dpnt_cvg_ctfn_typ_cd           in  varchar2  default null
  ,p_rlshp_typ_cd                   in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_pyd_attribute_category         in  varchar2  default null
  ,p_pyd_attribute1                 in  varchar2  default null
  ,p_pyd_attribute2                 in  varchar2  default null
  ,p_pyd_attribute3                 in  varchar2  default null
  ,p_pyd_attribute4                 in  varchar2  default null
  ,p_pyd_attribute5                 in  varchar2  default null
  ,p_pyd_attribute6                 in  varchar2  default null
  ,p_pyd_attribute7                 in  varchar2  default null
  ,p_pyd_attribute8                 in  varchar2  default null
  ,p_pyd_attribute9                 in  varchar2  default null
  ,p_pyd_attribute10                in  varchar2  default null
  ,p_pyd_attribute11                in  varchar2  default null
  ,p_pyd_attribute12                in  varchar2  default null
  ,p_pyd_attribute13                in  varchar2  default null
  ,p_pyd_attribute14                in  varchar2  default null
  ,p_pyd_attribute15                in  varchar2  default null
  ,p_pyd_attribute16                in  varchar2  default null
  ,p_pyd_attribute17                in  varchar2  default null
  ,p_pyd_attribute18                in  varchar2  default null
  ,p_pyd_attribute19                in  varchar2  default null
  ,p_pyd_attribute20                in  varchar2  default null
  ,p_pyd_attribute21                in  varchar2  default null
  ,p_pyd_attribute22                in  varchar2  default null
  ,p_pyd_attribute23                in  varchar2  default null
  ,p_pyd_attribute24                in  varchar2  default null
  ,p_pyd_attribute25                in  varchar2  default null
  ,p_pyd_attribute26                in  varchar2  default null
  ,p_pyd_attribute27                in  varchar2  default null
  ,p_pyd_attribute28                in  varchar2  default null
  ,p_pyd_attribute29                in  varchar2  default null
  ,p_pyd_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ptip_dpnt_cvg_ctfn_id ben_ptip_dpnt_cvg_ctfn_f.ptip_dpnt_cvg_ctfn_id%TYPE;
  l_effective_start_date ben_ptip_dpnt_cvg_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_ptip_dpnt_cvg_ctfn_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Ptip_Dpnt_Cvg_Ctfn';
  l_object_version_number ben_ptip_dpnt_cvg_ctfn_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Ptip_Dpnt_Cvg_Ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Ptip_Dpnt_Cvg_Ctfn
    --
    ben_Ptip_Dpnt_Cvg_Ctfn_bk1.create_Ptip_Dpnt_Cvg_Ctfn_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_enrt_flag      =>  p_lack_ctfn_sspnd_enrt_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_dpnt_cvg_ctfn_typ_cd           =>  p_dpnt_cvg_ctfn_typ_cd
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_pyd_attribute_category         =>  p_pyd_attribute_category
      ,p_pyd_attribute1                 =>  p_pyd_attribute1
      ,p_pyd_attribute2                 =>  p_pyd_attribute2
      ,p_pyd_attribute3                 =>  p_pyd_attribute3
      ,p_pyd_attribute4                 =>  p_pyd_attribute4
      ,p_pyd_attribute5                 =>  p_pyd_attribute5
      ,p_pyd_attribute6                 =>  p_pyd_attribute6
      ,p_pyd_attribute7                 =>  p_pyd_attribute7
      ,p_pyd_attribute8                 =>  p_pyd_attribute8
      ,p_pyd_attribute9                 =>  p_pyd_attribute9
      ,p_pyd_attribute10                =>  p_pyd_attribute10
      ,p_pyd_attribute11                =>  p_pyd_attribute11
      ,p_pyd_attribute12                =>  p_pyd_attribute12
      ,p_pyd_attribute13                =>  p_pyd_attribute13
      ,p_pyd_attribute14                =>  p_pyd_attribute14
      ,p_pyd_attribute15                =>  p_pyd_attribute15
      ,p_pyd_attribute16                =>  p_pyd_attribute16
      ,p_pyd_attribute17                =>  p_pyd_attribute17
      ,p_pyd_attribute18                =>  p_pyd_attribute18
      ,p_pyd_attribute19                =>  p_pyd_attribute19
      ,p_pyd_attribute20                =>  p_pyd_attribute20
      ,p_pyd_attribute21                =>  p_pyd_attribute21
      ,p_pyd_attribute22                =>  p_pyd_attribute22
      ,p_pyd_attribute23                =>  p_pyd_attribute23
      ,p_pyd_attribute24                =>  p_pyd_attribute24
      ,p_pyd_attribute25                =>  p_pyd_attribute25
      ,p_pyd_attribute26                =>  p_pyd_attribute26
      ,p_pyd_attribute27                =>  p_pyd_attribute27
      ,p_pyd_attribute28                =>  p_pyd_attribute28
      ,p_pyd_attribute29                =>  p_pyd_attribute29
      ,p_pyd_attribute30                =>  p_pyd_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Ptip_Dpnt_Cvg_Ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Ptip_Dpnt_Cvg_Ctfn
    --
  end;
  --
  ben_pyd_ins.ins
    (
     p_ptip_dpnt_cvg_ctfn_id         => l_ptip_dpnt_cvg_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_ptip_id                       => p_ptip_id
    ,p_pfd_flag                      => p_pfd_flag
    ,p_lack_ctfn_sspnd_enrt_flag     => p_lack_ctfn_sspnd_enrt_flag
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_dpnt_cvg_ctfn_typ_cd          => p_dpnt_cvg_ctfn_typ_cd
    ,p_rlshp_typ_cd                  => p_rlshp_typ_cd
    ,p_rqd_flag                      => p_rqd_flag
    ,p_pyd_attribute_category        => p_pyd_attribute_category
    ,p_pyd_attribute1                => p_pyd_attribute1
    ,p_pyd_attribute2                => p_pyd_attribute2
    ,p_pyd_attribute3                => p_pyd_attribute3
    ,p_pyd_attribute4                => p_pyd_attribute4
    ,p_pyd_attribute5                => p_pyd_attribute5
    ,p_pyd_attribute6                => p_pyd_attribute6
    ,p_pyd_attribute7                => p_pyd_attribute7
    ,p_pyd_attribute8                => p_pyd_attribute8
    ,p_pyd_attribute9                => p_pyd_attribute9
    ,p_pyd_attribute10               => p_pyd_attribute10
    ,p_pyd_attribute11               => p_pyd_attribute11
    ,p_pyd_attribute12               => p_pyd_attribute12
    ,p_pyd_attribute13               => p_pyd_attribute13
    ,p_pyd_attribute14               => p_pyd_attribute14
    ,p_pyd_attribute15               => p_pyd_attribute15
    ,p_pyd_attribute16               => p_pyd_attribute16
    ,p_pyd_attribute17               => p_pyd_attribute17
    ,p_pyd_attribute18               => p_pyd_attribute18
    ,p_pyd_attribute19               => p_pyd_attribute19
    ,p_pyd_attribute20               => p_pyd_attribute20
    ,p_pyd_attribute21               => p_pyd_attribute21
    ,p_pyd_attribute22               => p_pyd_attribute22
    ,p_pyd_attribute23               => p_pyd_attribute23
    ,p_pyd_attribute24               => p_pyd_attribute24
    ,p_pyd_attribute25               => p_pyd_attribute25
    ,p_pyd_attribute26               => p_pyd_attribute26
    ,p_pyd_attribute27               => p_pyd_attribute27
    ,p_pyd_attribute28               => p_pyd_attribute28
    ,p_pyd_attribute29               => p_pyd_attribute29
    ,p_pyd_attribute30               => p_pyd_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Ptip_Dpnt_Cvg_Ctfn
    --
    ben_Ptip_Dpnt_Cvg_Ctfn_bk1.create_Ptip_Dpnt_Cvg_Ctfn_a
      (
       p_ptip_dpnt_cvg_ctfn_id          =>  l_ptip_dpnt_cvg_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_enrt_flag      =>  p_lack_ctfn_sspnd_enrt_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_dpnt_cvg_ctfn_typ_cd           =>  p_dpnt_cvg_ctfn_typ_cd
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_pyd_attribute_category         =>  p_pyd_attribute_category
      ,p_pyd_attribute1                 =>  p_pyd_attribute1
      ,p_pyd_attribute2                 =>  p_pyd_attribute2
      ,p_pyd_attribute3                 =>  p_pyd_attribute3
      ,p_pyd_attribute4                 =>  p_pyd_attribute4
      ,p_pyd_attribute5                 =>  p_pyd_attribute5
      ,p_pyd_attribute6                 =>  p_pyd_attribute6
      ,p_pyd_attribute7                 =>  p_pyd_attribute7
      ,p_pyd_attribute8                 =>  p_pyd_attribute8
      ,p_pyd_attribute9                 =>  p_pyd_attribute9
      ,p_pyd_attribute10                =>  p_pyd_attribute10
      ,p_pyd_attribute11                =>  p_pyd_attribute11
      ,p_pyd_attribute12                =>  p_pyd_attribute12
      ,p_pyd_attribute13                =>  p_pyd_attribute13
      ,p_pyd_attribute14                =>  p_pyd_attribute14
      ,p_pyd_attribute15                =>  p_pyd_attribute15
      ,p_pyd_attribute16                =>  p_pyd_attribute16
      ,p_pyd_attribute17                =>  p_pyd_attribute17
      ,p_pyd_attribute18                =>  p_pyd_attribute18
      ,p_pyd_attribute19                =>  p_pyd_attribute19
      ,p_pyd_attribute20                =>  p_pyd_attribute20
      ,p_pyd_attribute21                =>  p_pyd_attribute21
      ,p_pyd_attribute22                =>  p_pyd_attribute22
      ,p_pyd_attribute23                =>  p_pyd_attribute23
      ,p_pyd_attribute24                =>  p_pyd_attribute24
      ,p_pyd_attribute25                =>  p_pyd_attribute25
      ,p_pyd_attribute26                =>  p_pyd_attribute26
      ,p_pyd_attribute27                =>  p_pyd_attribute27
      ,p_pyd_attribute28                =>  p_pyd_attribute28
      ,p_pyd_attribute29                =>  p_pyd_attribute29
      ,p_pyd_attribute30                =>  p_pyd_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Ptip_Dpnt_Cvg_Ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Ptip_Dpnt_Cvg_Ctfn
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
  p_ptip_dpnt_cvg_ctfn_id := l_ptip_dpnt_cvg_ctfn_id;
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
    ROLLBACK TO create_Ptip_Dpnt_Cvg_Ctfn;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ptip_dpnt_cvg_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Ptip_Dpnt_Cvg_Ctfn;
	-- NOCOPY Changes
    p_ptip_dpnt_cvg_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    -- NOCOPY Changes
    raise;
    --
end create_Ptip_Dpnt_Cvg_Ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Ptip_Dpnt_Cvg_Ctfn >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ptip_Dpnt_Cvg_Ctfn
  (p_validate                       in  boolean   default false
  ,p_ptip_dpnt_cvg_ctfn_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pfd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_when_rl               in  number    default hr_api.g_number
  ,p_dpnt_cvg_ctfn_typ_cd           in  varchar2  default hr_api.g_varchar2
  ,p_rlshp_typ_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pyd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Ptip_Dpnt_Cvg_Ctfn';
  l_object_version_number ben_ptip_dpnt_cvg_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_ptip_dpnt_cvg_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_ptip_dpnt_cvg_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Ptip_Dpnt_Cvg_Ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Ptip_Dpnt_Cvg_Ctfn
    --
    ben_Ptip_Dpnt_Cvg_Ctfn_bk2.update_Ptip_Dpnt_Cvg_Ctfn_b
      (
       p_ptip_dpnt_cvg_ctfn_id          =>  p_ptip_dpnt_cvg_ctfn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_enrt_flag      =>  p_lack_ctfn_sspnd_enrt_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_dpnt_cvg_ctfn_typ_cd           =>  p_dpnt_cvg_ctfn_typ_cd
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_pyd_attribute_category         =>  p_pyd_attribute_category
      ,p_pyd_attribute1                 =>  p_pyd_attribute1
      ,p_pyd_attribute2                 =>  p_pyd_attribute2
      ,p_pyd_attribute3                 =>  p_pyd_attribute3
      ,p_pyd_attribute4                 =>  p_pyd_attribute4
      ,p_pyd_attribute5                 =>  p_pyd_attribute5
      ,p_pyd_attribute6                 =>  p_pyd_attribute6
      ,p_pyd_attribute7                 =>  p_pyd_attribute7
      ,p_pyd_attribute8                 =>  p_pyd_attribute8
      ,p_pyd_attribute9                 =>  p_pyd_attribute9
      ,p_pyd_attribute10                =>  p_pyd_attribute10
      ,p_pyd_attribute11                =>  p_pyd_attribute11
      ,p_pyd_attribute12                =>  p_pyd_attribute12
      ,p_pyd_attribute13                =>  p_pyd_attribute13
      ,p_pyd_attribute14                =>  p_pyd_attribute14
      ,p_pyd_attribute15                =>  p_pyd_attribute15
      ,p_pyd_attribute16                =>  p_pyd_attribute16
      ,p_pyd_attribute17                =>  p_pyd_attribute17
      ,p_pyd_attribute18                =>  p_pyd_attribute18
      ,p_pyd_attribute19                =>  p_pyd_attribute19
      ,p_pyd_attribute20                =>  p_pyd_attribute20
      ,p_pyd_attribute21                =>  p_pyd_attribute21
      ,p_pyd_attribute22                =>  p_pyd_attribute22
      ,p_pyd_attribute23                =>  p_pyd_attribute23
      ,p_pyd_attribute24                =>  p_pyd_attribute24
      ,p_pyd_attribute25                =>  p_pyd_attribute25
      ,p_pyd_attribute26                =>  p_pyd_attribute26
      ,p_pyd_attribute27                =>  p_pyd_attribute27
      ,p_pyd_attribute28                =>  p_pyd_attribute28
      ,p_pyd_attribute29                =>  p_pyd_attribute29
      ,p_pyd_attribute30                =>  p_pyd_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Ptip_Dpnt_Cvg_Ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Ptip_Dpnt_Cvg_Ctfn
    --
  end;
  --
  ben_pyd_upd.upd
    (
     p_ptip_dpnt_cvg_ctfn_id         => p_ptip_dpnt_cvg_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_ptip_id                       => p_ptip_id
    ,p_pfd_flag                      => p_pfd_flag
    ,p_lack_ctfn_sspnd_enrt_flag     => p_lack_ctfn_sspnd_enrt_flag
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_dpnt_cvg_ctfn_typ_cd          => p_dpnt_cvg_ctfn_typ_cd
    ,p_rlshp_typ_cd                  => p_rlshp_typ_cd
    ,p_rqd_flag                      => p_rqd_flag
    ,p_pyd_attribute_category        => p_pyd_attribute_category
    ,p_pyd_attribute1                => p_pyd_attribute1
    ,p_pyd_attribute2                => p_pyd_attribute2
    ,p_pyd_attribute3                => p_pyd_attribute3
    ,p_pyd_attribute4                => p_pyd_attribute4
    ,p_pyd_attribute5                => p_pyd_attribute5
    ,p_pyd_attribute6                => p_pyd_attribute6
    ,p_pyd_attribute7                => p_pyd_attribute7
    ,p_pyd_attribute8                => p_pyd_attribute8
    ,p_pyd_attribute9                => p_pyd_attribute9
    ,p_pyd_attribute10               => p_pyd_attribute10
    ,p_pyd_attribute11               => p_pyd_attribute11
    ,p_pyd_attribute12               => p_pyd_attribute12
    ,p_pyd_attribute13               => p_pyd_attribute13
    ,p_pyd_attribute14               => p_pyd_attribute14
    ,p_pyd_attribute15               => p_pyd_attribute15
    ,p_pyd_attribute16               => p_pyd_attribute16
    ,p_pyd_attribute17               => p_pyd_attribute17
    ,p_pyd_attribute18               => p_pyd_attribute18
    ,p_pyd_attribute19               => p_pyd_attribute19
    ,p_pyd_attribute20               => p_pyd_attribute20
    ,p_pyd_attribute21               => p_pyd_attribute21
    ,p_pyd_attribute22               => p_pyd_attribute22
    ,p_pyd_attribute23               => p_pyd_attribute23
    ,p_pyd_attribute24               => p_pyd_attribute24
    ,p_pyd_attribute25               => p_pyd_attribute25
    ,p_pyd_attribute26               => p_pyd_attribute26
    ,p_pyd_attribute27               => p_pyd_attribute27
    ,p_pyd_attribute28               => p_pyd_attribute28
    ,p_pyd_attribute29               => p_pyd_attribute29
    ,p_pyd_attribute30               => p_pyd_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Ptip_Dpnt_Cvg_Ctfn
    --
    ben_Ptip_Dpnt_Cvg_Ctfn_bk2.update_Ptip_Dpnt_Cvg_Ctfn_a
      (
       p_ptip_dpnt_cvg_ctfn_id          =>  p_ptip_dpnt_cvg_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_enrt_flag      =>  p_lack_ctfn_sspnd_enrt_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_dpnt_cvg_ctfn_typ_cd           =>  p_dpnt_cvg_ctfn_typ_cd
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_pyd_attribute_category         =>  p_pyd_attribute_category
      ,p_pyd_attribute1                 =>  p_pyd_attribute1
      ,p_pyd_attribute2                 =>  p_pyd_attribute2
      ,p_pyd_attribute3                 =>  p_pyd_attribute3
      ,p_pyd_attribute4                 =>  p_pyd_attribute4
      ,p_pyd_attribute5                 =>  p_pyd_attribute5
      ,p_pyd_attribute6                 =>  p_pyd_attribute6
      ,p_pyd_attribute7                 =>  p_pyd_attribute7
      ,p_pyd_attribute8                 =>  p_pyd_attribute8
      ,p_pyd_attribute9                 =>  p_pyd_attribute9
      ,p_pyd_attribute10                =>  p_pyd_attribute10
      ,p_pyd_attribute11                =>  p_pyd_attribute11
      ,p_pyd_attribute12                =>  p_pyd_attribute12
      ,p_pyd_attribute13                =>  p_pyd_attribute13
      ,p_pyd_attribute14                =>  p_pyd_attribute14
      ,p_pyd_attribute15                =>  p_pyd_attribute15
      ,p_pyd_attribute16                =>  p_pyd_attribute16
      ,p_pyd_attribute17                =>  p_pyd_attribute17
      ,p_pyd_attribute18                =>  p_pyd_attribute18
      ,p_pyd_attribute19                =>  p_pyd_attribute19
      ,p_pyd_attribute20                =>  p_pyd_attribute20
      ,p_pyd_attribute21                =>  p_pyd_attribute21
      ,p_pyd_attribute22                =>  p_pyd_attribute22
      ,p_pyd_attribute23                =>  p_pyd_attribute23
      ,p_pyd_attribute24                =>  p_pyd_attribute24
      ,p_pyd_attribute25                =>  p_pyd_attribute25
      ,p_pyd_attribute26                =>  p_pyd_attribute26
      ,p_pyd_attribute27                =>  p_pyd_attribute27
      ,p_pyd_attribute28                =>  p_pyd_attribute28
      ,p_pyd_attribute29                =>  p_pyd_attribute29
      ,p_pyd_attribute30                =>  p_pyd_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Ptip_Dpnt_Cvg_Ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Ptip_Dpnt_Cvg_Ctfn
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
    ROLLBACK TO update_Ptip_Dpnt_Cvg_Ctfn;
    --
	-- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes

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
    ROLLBACK TO update_Ptip_Dpnt_Cvg_Ctfn;
	-- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes

    raise;
    --
end update_Ptip_Dpnt_Cvg_Ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Ptip_Dpnt_Cvg_Ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ptip_Dpnt_Cvg_Ctfn
  (p_validate                       in  boolean  default false
  ,p_ptip_dpnt_cvg_ctfn_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Ptip_Dpnt_Cvg_Ctfn';
  l_object_version_number ben_ptip_dpnt_cvg_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_ptip_dpnt_cvg_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_ptip_dpnt_cvg_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Ptip_Dpnt_Cvg_Ctfn;
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
    -- Start of API User Hook for the before hook of delete_Ptip_Dpnt_Cvg_Ctfn
    --
    ben_Ptip_Dpnt_Cvg_Ctfn_bk3.delete_Ptip_Dpnt_Cvg_Ctfn_b
      (
       p_ptip_dpnt_cvg_ctfn_id          =>  p_ptip_dpnt_cvg_ctfn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Ptip_Dpnt_Cvg_Ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Ptip_Dpnt_Cvg_Ctfn
    --
  end;
  --
  ben_pyd_del.del
    (
     p_ptip_dpnt_cvg_ctfn_id         => p_ptip_dpnt_cvg_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Ptip_Dpnt_Cvg_Ctfn
    --
    ben_Ptip_Dpnt_Cvg_Ctfn_bk3.delete_Ptip_Dpnt_Cvg_Ctfn_a
      (
       p_ptip_dpnt_cvg_ctfn_id          =>  p_ptip_dpnt_cvg_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Ptip_Dpnt_Cvg_Ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Ptip_Dpnt_Cvg_Ctfn
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
    ROLLBACK TO delete_Ptip_Dpnt_Cvg_Ctfn;
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
    ROLLBACK TO delete_Ptip_Dpnt_Cvg_Ctfn;
	-- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes
    raise;
    --
end delete_Ptip_Dpnt_Cvg_Ctfn;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ptip_dpnt_cvg_ctfn_id                   in     number
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
  ben_pyd_shd.lck
    (
      p_ptip_dpnt_cvg_ctfn_id                 => p_ptip_dpnt_cvg_ctfn_id
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
end ben_Ptip_Dpnt_Cvg_Ctfn_api;

/
