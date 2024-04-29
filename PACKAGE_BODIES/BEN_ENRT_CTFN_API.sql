--------------------------------------------------------
--  DDL for Package Body BEN_ENRT_CTFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENRT_CTFN_API" as
/* $Header: beecfapi.pkb 120.0 2005/05/28 01:49:40 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Enrt_Ctfn_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Enrt_Ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Enrt_Ctfn
  (p_validate                       in  boolean   default false
  ,p_enrt_ctfn_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_ctfn_rqd_when_rl               in  number    default null
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ecf_attribute_category         in  varchar2  default null
  ,p_ecf_attribute1                 in  varchar2  default null
  ,p_ecf_attribute2                 in  varchar2  default null
  ,p_ecf_attribute3                 in  varchar2  default null
  ,p_ecf_attribute4                 in  varchar2  default null
  ,p_ecf_attribute5                 in  varchar2  default null
  ,p_ecf_attribute6                 in  varchar2  default null
  ,p_ecf_attribute7                 in  varchar2  default null
  ,p_ecf_attribute8                 in  varchar2  default null
  ,p_ecf_attribute9                 in  varchar2  default null
  ,p_ecf_attribute10                in  varchar2  default null
  ,p_ecf_attribute11                in  varchar2  default null
  ,p_ecf_attribute12                in  varchar2  default null
  ,p_ecf_attribute13                in  varchar2  default null
  ,p_ecf_attribute14                in  varchar2  default null
  ,p_ecf_attribute15                in  varchar2  default null
  ,p_ecf_attribute16                in  varchar2  default null
  ,p_ecf_attribute17                in  varchar2  default null
  ,p_ecf_attribute18                in  varchar2  default null
  ,p_ecf_attribute19                in  varchar2  default null
  ,p_ecf_attribute20                in  varchar2  default null
  ,p_ecf_attribute21                in  varchar2  default null
  ,p_ecf_attribute22                in  varchar2  default null
  ,p_ecf_attribute23                in  varchar2  default null
  ,p_ecf_attribute24                in  varchar2  default null
  ,p_ecf_attribute25                in  varchar2  default null
  ,p_ecf_attribute26                in  varchar2  default null
  ,p_ecf_attribute27                in  varchar2  default null
  ,p_ecf_attribute28                in  varchar2  default null
  ,p_ecf_attribute29                in  varchar2  default null
  ,p_ecf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_oipl_id                        in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_enrt_ctfn_id ben_enrt_ctfn_f.enrt_ctfn_id%TYPE;
  l_effective_start_date ben_enrt_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_enrt_ctfn_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Enrt_Ctfn';
  l_object_version_number ben_enrt_ctfn_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Enrt_Ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Enrt_Ctfn
    --
    ben_Enrt_Ctfn_bk1.create_Enrt_Ctfn_b
      (
       p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ecf_attribute_category         =>  p_ecf_attribute_category
      ,p_ecf_attribute1                 =>  p_ecf_attribute1
      ,p_ecf_attribute2                 =>  p_ecf_attribute2
      ,p_ecf_attribute3                 =>  p_ecf_attribute3
      ,p_ecf_attribute4                 =>  p_ecf_attribute4
      ,p_ecf_attribute5                 =>  p_ecf_attribute5
      ,p_ecf_attribute6                 =>  p_ecf_attribute6
      ,p_ecf_attribute7                 =>  p_ecf_attribute7
      ,p_ecf_attribute8                 =>  p_ecf_attribute8
      ,p_ecf_attribute9                 =>  p_ecf_attribute9
      ,p_ecf_attribute10                =>  p_ecf_attribute10
      ,p_ecf_attribute11                =>  p_ecf_attribute11
      ,p_ecf_attribute12                =>  p_ecf_attribute12
      ,p_ecf_attribute13                =>  p_ecf_attribute13
      ,p_ecf_attribute14                =>  p_ecf_attribute14
      ,p_ecf_attribute15                =>  p_ecf_attribute15
      ,p_ecf_attribute16                =>  p_ecf_attribute16
      ,p_ecf_attribute17                =>  p_ecf_attribute17
      ,p_ecf_attribute18                =>  p_ecf_attribute18
      ,p_ecf_attribute19                =>  p_ecf_attribute19
      ,p_ecf_attribute20                =>  p_ecf_attribute20
      ,p_ecf_attribute21                =>  p_ecf_attribute21
      ,p_ecf_attribute22                =>  p_ecf_attribute22
      ,p_ecf_attribute23                =>  p_ecf_attribute23
      ,p_ecf_attribute24                =>  p_ecf_attribute24
      ,p_ecf_attribute25                =>  p_ecf_attribute25
      ,p_ecf_attribute26                =>  p_ecf_attribute26
      ,p_ecf_attribute27                =>  p_ecf_attribute27
      ,p_ecf_attribute28                =>  p_ecf_attribute28
      ,p_ecf_attribute29                =>  p_ecf_attribute29
      ,p_ecf_attribute30                =>  p_ecf_attribute30
      ,p_oipl_id                        =>  p_oipl_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Enrt_Ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Enrt_Ctfn
    --
  end;
  --
  ben_ecf_ins.ins
    (
     p_enrt_ctfn_id                  => l_enrt_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_rqd_flag                      => p_rqd_flag
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_ecf_attribute_category        => p_ecf_attribute_category
    ,p_ecf_attribute1                => p_ecf_attribute1
    ,p_ecf_attribute2                => p_ecf_attribute2
    ,p_ecf_attribute3                => p_ecf_attribute3
    ,p_ecf_attribute4                => p_ecf_attribute4
    ,p_ecf_attribute5                => p_ecf_attribute5
    ,p_ecf_attribute6                => p_ecf_attribute6
    ,p_ecf_attribute7                => p_ecf_attribute7
    ,p_ecf_attribute8                => p_ecf_attribute8
    ,p_ecf_attribute9                => p_ecf_attribute9
    ,p_ecf_attribute10               => p_ecf_attribute10
    ,p_ecf_attribute11               => p_ecf_attribute11
    ,p_ecf_attribute12               => p_ecf_attribute12
    ,p_ecf_attribute13               => p_ecf_attribute13
    ,p_ecf_attribute14               => p_ecf_attribute14
    ,p_ecf_attribute15               => p_ecf_attribute15
    ,p_ecf_attribute16               => p_ecf_attribute16
    ,p_ecf_attribute17               => p_ecf_attribute17
    ,p_ecf_attribute18               => p_ecf_attribute18
    ,p_ecf_attribute19               => p_ecf_attribute19
    ,p_ecf_attribute20               => p_ecf_attribute20
    ,p_ecf_attribute21               => p_ecf_attribute21
    ,p_ecf_attribute22               => p_ecf_attribute22
    ,p_ecf_attribute23               => p_ecf_attribute23
    ,p_ecf_attribute24               => p_ecf_attribute24
    ,p_ecf_attribute25               => p_ecf_attribute25
    ,p_ecf_attribute26               => p_ecf_attribute26
    ,p_ecf_attribute27               => p_ecf_attribute27
    ,p_ecf_attribute28               => p_ecf_attribute28
    ,p_ecf_attribute29               => p_ecf_attribute29
    ,p_ecf_attribute30               => p_ecf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_oipl_id                       => p_oipl_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Enrt_Ctfn
    --
    ben_Enrt_Ctfn_bk1.create_Enrt_Ctfn_a
      (
       p_enrt_ctfn_id                   =>  l_enrt_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ecf_attribute_category         =>  p_ecf_attribute_category
      ,p_ecf_attribute1                 =>  p_ecf_attribute1
      ,p_ecf_attribute2                 =>  p_ecf_attribute2
      ,p_ecf_attribute3                 =>  p_ecf_attribute3
      ,p_ecf_attribute4                 =>  p_ecf_attribute4
      ,p_ecf_attribute5                 =>  p_ecf_attribute5
      ,p_ecf_attribute6                 =>  p_ecf_attribute6
      ,p_ecf_attribute7                 =>  p_ecf_attribute7
      ,p_ecf_attribute8                 =>  p_ecf_attribute8
      ,p_ecf_attribute9                 =>  p_ecf_attribute9
      ,p_ecf_attribute10                =>  p_ecf_attribute10
      ,p_ecf_attribute11                =>  p_ecf_attribute11
      ,p_ecf_attribute12                =>  p_ecf_attribute12
      ,p_ecf_attribute13                =>  p_ecf_attribute13
      ,p_ecf_attribute14                =>  p_ecf_attribute14
      ,p_ecf_attribute15                =>  p_ecf_attribute15
      ,p_ecf_attribute16                =>  p_ecf_attribute16
      ,p_ecf_attribute17                =>  p_ecf_attribute17
      ,p_ecf_attribute18                =>  p_ecf_attribute18
      ,p_ecf_attribute19                =>  p_ecf_attribute19
      ,p_ecf_attribute20                =>  p_ecf_attribute20
      ,p_ecf_attribute21                =>  p_ecf_attribute21
      ,p_ecf_attribute22                =>  p_ecf_attribute22
      ,p_ecf_attribute23                =>  p_ecf_attribute23
      ,p_ecf_attribute24                =>  p_ecf_attribute24
      ,p_ecf_attribute25                =>  p_ecf_attribute25
      ,p_ecf_attribute26                =>  p_ecf_attribute26
      ,p_ecf_attribute27                =>  p_ecf_attribute27
      ,p_ecf_attribute28                =>  p_ecf_attribute28
      ,p_ecf_attribute29                =>  p_ecf_attribute29
      ,p_ecf_attribute30                =>  p_ecf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_oipl_id                        =>  p_oipl_id
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Enrt_Ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Enrt_Ctfn
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
  p_enrt_ctfn_id := l_enrt_ctfn_id;
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
    ROLLBACK TO create_Enrt_Ctfn;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_enrt_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Enrt_Ctfn;
    p_enrt_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_Enrt_Ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Enrt_Ctfn >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Enrt_Ctfn
  (p_validate                       in  boolean   default false
  ,p_enrt_ctfn_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_when_rl               in  number    default hr_api.g_number
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ecf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ecf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Enrt_Ctfn';
  l_object_version_number ben_enrt_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_enrt_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_enrt_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Enrt_Ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Enrt_Ctfn
    --
    ben_Enrt_Ctfn_bk2.update_Enrt_Ctfn_b
      (
       p_enrt_ctfn_id                   =>  p_enrt_ctfn_id
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ecf_attribute_category         =>  p_ecf_attribute_category
      ,p_ecf_attribute1                 =>  p_ecf_attribute1
      ,p_ecf_attribute2                 =>  p_ecf_attribute2
      ,p_ecf_attribute3                 =>  p_ecf_attribute3
      ,p_ecf_attribute4                 =>  p_ecf_attribute4
      ,p_ecf_attribute5                 =>  p_ecf_attribute5
      ,p_ecf_attribute6                 =>  p_ecf_attribute6
      ,p_ecf_attribute7                 =>  p_ecf_attribute7
      ,p_ecf_attribute8                 =>  p_ecf_attribute8
      ,p_ecf_attribute9                 =>  p_ecf_attribute9
      ,p_ecf_attribute10                =>  p_ecf_attribute10
      ,p_ecf_attribute11                =>  p_ecf_attribute11
      ,p_ecf_attribute12                =>  p_ecf_attribute12
      ,p_ecf_attribute13                =>  p_ecf_attribute13
      ,p_ecf_attribute14                =>  p_ecf_attribute14
      ,p_ecf_attribute15                =>  p_ecf_attribute15
      ,p_ecf_attribute16                =>  p_ecf_attribute16
      ,p_ecf_attribute17                =>  p_ecf_attribute17
      ,p_ecf_attribute18                =>  p_ecf_attribute18
      ,p_ecf_attribute19                =>  p_ecf_attribute19
      ,p_ecf_attribute20                =>  p_ecf_attribute20
      ,p_ecf_attribute21                =>  p_ecf_attribute21
      ,p_ecf_attribute22                =>  p_ecf_attribute22
      ,p_ecf_attribute23                =>  p_ecf_attribute23
      ,p_ecf_attribute24                =>  p_ecf_attribute24
      ,p_ecf_attribute25                =>  p_ecf_attribute25
      ,p_ecf_attribute26                =>  p_ecf_attribute26
      ,p_ecf_attribute27                =>  p_ecf_attribute27
      ,p_ecf_attribute28                =>  p_ecf_attribute28
      ,p_ecf_attribute29                =>  p_ecf_attribute29
      ,p_ecf_attribute30                =>  p_ecf_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_oipl_id                        =>  p_oipl_id
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Enrt_Ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Enrt_Ctfn
    --
  end;
  --
  ben_ecf_upd.upd
    (
     p_enrt_ctfn_id                  => p_enrt_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_rqd_flag                      => p_rqd_flag
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_ecf_attribute_category        => p_ecf_attribute_category
    ,p_ecf_attribute1                => p_ecf_attribute1
    ,p_ecf_attribute2                => p_ecf_attribute2
    ,p_ecf_attribute3                => p_ecf_attribute3
    ,p_ecf_attribute4                => p_ecf_attribute4
    ,p_ecf_attribute5                => p_ecf_attribute5
    ,p_ecf_attribute6                => p_ecf_attribute6
    ,p_ecf_attribute7                => p_ecf_attribute7
    ,p_ecf_attribute8                => p_ecf_attribute8
    ,p_ecf_attribute9                => p_ecf_attribute9
    ,p_ecf_attribute10               => p_ecf_attribute10
    ,p_ecf_attribute11               => p_ecf_attribute11
    ,p_ecf_attribute12               => p_ecf_attribute12
    ,p_ecf_attribute13               => p_ecf_attribute13
    ,p_ecf_attribute14               => p_ecf_attribute14
    ,p_ecf_attribute15               => p_ecf_attribute15
    ,p_ecf_attribute16               => p_ecf_attribute16
    ,p_ecf_attribute17               => p_ecf_attribute17
    ,p_ecf_attribute18               => p_ecf_attribute18
    ,p_ecf_attribute19               => p_ecf_attribute19
    ,p_ecf_attribute20               => p_ecf_attribute20
    ,p_ecf_attribute21               => p_ecf_attribute21
    ,p_ecf_attribute22               => p_ecf_attribute22
    ,p_ecf_attribute23               => p_ecf_attribute23
    ,p_ecf_attribute24               => p_ecf_attribute24
    ,p_ecf_attribute25               => p_ecf_attribute25
    ,p_ecf_attribute26               => p_ecf_attribute26
    ,p_ecf_attribute27               => p_ecf_attribute27
    ,p_ecf_attribute28               => p_ecf_attribute28
    ,p_ecf_attribute29               => p_ecf_attribute29
    ,p_ecf_attribute30               => p_ecf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_oipl_id                       => p_oipl_id
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Enrt_Ctfn
    --
    ben_Enrt_Ctfn_bk2.update_Enrt_Ctfn_a
      (
       p_enrt_ctfn_id                   =>  p_enrt_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ecf_attribute_category         =>  p_ecf_attribute_category
      ,p_ecf_attribute1                 =>  p_ecf_attribute1
      ,p_ecf_attribute2                 =>  p_ecf_attribute2
      ,p_ecf_attribute3                 =>  p_ecf_attribute3
      ,p_ecf_attribute4                 =>  p_ecf_attribute4
      ,p_ecf_attribute5                 =>  p_ecf_attribute5
      ,p_ecf_attribute6                 =>  p_ecf_attribute6
      ,p_ecf_attribute7                 =>  p_ecf_attribute7
      ,p_ecf_attribute8                 =>  p_ecf_attribute8
      ,p_ecf_attribute9                 =>  p_ecf_attribute9
      ,p_ecf_attribute10                =>  p_ecf_attribute10
      ,p_ecf_attribute11                =>  p_ecf_attribute11
      ,p_ecf_attribute12                =>  p_ecf_attribute12
      ,p_ecf_attribute13                =>  p_ecf_attribute13
      ,p_ecf_attribute14                =>  p_ecf_attribute14
      ,p_ecf_attribute15                =>  p_ecf_attribute15
      ,p_ecf_attribute16                =>  p_ecf_attribute16
      ,p_ecf_attribute17                =>  p_ecf_attribute17
      ,p_ecf_attribute18                =>  p_ecf_attribute18
      ,p_ecf_attribute19                =>  p_ecf_attribute19
      ,p_ecf_attribute20                =>  p_ecf_attribute20
      ,p_ecf_attribute21                =>  p_ecf_attribute21
      ,p_ecf_attribute22                =>  p_ecf_attribute22
      ,p_ecf_attribute23                =>  p_ecf_attribute23
      ,p_ecf_attribute24                =>  p_ecf_attribute24
      ,p_ecf_attribute25                =>  p_ecf_attribute25
      ,p_ecf_attribute26                =>  p_ecf_attribute26
      ,p_ecf_attribute27                =>  p_ecf_attribute27
      ,p_ecf_attribute28                =>  p_ecf_attribute28
      ,p_ecf_attribute29                =>  p_ecf_attribute29
      ,p_ecf_attribute30                =>  p_ecf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_oipl_id                        =>  p_oipl_id
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Enrt_Ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Enrt_Ctfn
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
    ROLLBACK TO update_Enrt_Ctfn;
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
    ROLLBACK TO update_Enrt_Ctfn;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_Enrt_Ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Enrt_Ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Enrt_Ctfn
  (p_validate                       in  boolean  default false
  ,p_enrt_ctfn_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Enrt_Ctfn';
  l_object_version_number ben_enrt_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_enrt_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_enrt_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Enrt_Ctfn;
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
    -- Start of API User Hook for the before hook of delete_Enrt_Ctfn
    --
    ben_Enrt_Ctfn_bk3.delete_Enrt_Ctfn_b
      (
       p_enrt_ctfn_id                   =>  p_enrt_ctfn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Enrt_Ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Enrt_Ctfn
    --
  end;
  --
  ben_ecf_del.del
    (
     p_enrt_ctfn_id                  => p_enrt_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Enrt_Ctfn
    --
    ben_Enrt_Ctfn_bk3.delete_Enrt_Ctfn_a
      (
       p_enrt_ctfn_id                   =>  p_enrt_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Enrt_Ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Enrt_Ctfn
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
    ROLLBACK TO delete_Enrt_Ctfn;
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
    ROLLBACK TO delete_Enrt_Ctfn;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_Enrt_Ctfn;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_enrt_ctfn_id                   in     number
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
  ben_ecf_shd.lck
    (
      p_enrt_ctfn_id                 => p_enrt_ctfn_id
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
end ben_Enrt_Ctfn_api;

/
