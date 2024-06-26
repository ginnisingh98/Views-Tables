--------------------------------------------------------
--  DDL for Package Body BEN_LER_ENRT_CTFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LER_ENRT_CTFN_API" as
/* $Header: belncapi.pkb 120.0 2005/05/28 03:25:22 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ler_enrt_ctfn_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ler_enrt_ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ler_enrt_ctfn
  (p_validate                       in  boolean   default false
  ,p_ler_enrt_ctfn_id               out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_ctfn_rqd_when_rl               in  number    default null
  ,p_ler_rqrs_enrt_ctfn_id          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_lnc_attribute_category         in  varchar2  default null
  ,p_lnc_attribute1                 in  varchar2  default null
  ,p_lnc_attribute2                 in  varchar2  default null
  ,p_lnc_attribute3                 in  varchar2  default null
  ,p_lnc_attribute4                 in  varchar2  default null
  ,p_lnc_attribute5                 in  varchar2  default null
  ,p_lnc_attribute6                 in  varchar2  default null
  ,p_lnc_attribute7                 in  varchar2  default null
  ,p_lnc_attribute8                 in  varchar2  default null
  ,p_lnc_attribute9                 in  varchar2  default null
  ,p_lnc_attribute10                in  varchar2  default null
  ,p_lnc_attribute11                in  varchar2  default null
  ,p_lnc_attribute12                in  varchar2  default null
  ,p_lnc_attribute13                in  varchar2  default null
  ,p_lnc_attribute14                in  varchar2  default null
  ,p_lnc_attribute15                in  varchar2  default null
  ,p_lnc_attribute16                in  varchar2  default null
  ,p_lnc_attribute17                in  varchar2  default null
  ,p_lnc_attribute18                in  varchar2  default null
  ,p_lnc_attribute19                in  varchar2  default null
  ,p_lnc_attribute20                in  varchar2  default null
  ,p_lnc_attribute21                in  varchar2  default null
  ,p_lnc_attribute22                in  varchar2  default null
  ,p_lnc_attribute23                in  varchar2  default null
  ,p_lnc_attribute24                in  varchar2  default null
  ,p_lnc_attribute25                in  varchar2  default null
  ,p_lnc_attribute26                in  varchar2  default null
  ,p_lnc_attribute27                in  varchar2  default null
  ,p_lnc_attribute28                in  varchar2  default null
  ,p_lnc_attribute29                in  varchar2  default null
  ,p_lnc_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ler_enrt_ctfn_id ben_ler_enrt_ctfn_f.ler_enrt_ctfn_id%TYPE;
  l_effective_start_date ben_ler_enrt_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_enrt_ctfn_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ler_enrt_ctfn';
  l_object_version_number ben_ler_enrt_ctfn_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ler_enrt_ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ler_enrt_ctfn
    --
    ben_ler_enrt_ctfn_bk1.create_ler_enrt_ctfn_b
      (
       p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_ler_rqrs_enrt_ctfn_id          =>  p_ler_rqrs_enrt_ctfn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lnc_attribute_category         =>  p_lnc_attribute_category
      ,p_lnc_attribute1                 =>  p_lnc_attribute1
      ,p_lnc_attribute2                 =>  p_lnc_attribute2
      ,p_lnc_attribute3                 =>  p_lnc_attribute3
      ,p_lnc_attribute4                 =>  p_lnc_attribute4
      ,p_lnc_attribute5                 =>  p_lnc_attribute5
      ,p_lnc_attribute6                 =>  p_lnc_attribute6
      ,p_lnc_attribute7                 =>  p_lnc_attribute7
      ,p_lnc_attribute8                 =>  p_lnc_attribute8
      ,p_lnc_attribute9                 =>  p_lnc_attribute9
      ,p_lnc_attribute10                =>  p_lnc_attribute10
      ,p_lnc_attribute11                =>  p_lnc_attribute11
      ,p_lnc_attribute12                =>  p_lnc_attribute12
      ,p_lnc_attribute13                =>  p_lnc_attribute13
      ,p_lnc_attribute14                =>  p_lnc_attribute14
      ,p_lnc_attribute15                =>  p_lnc_attribute15
      ,p_lnc_attribute16                =>  p_lnc_attribute16
      ,p_lnc_attribute17                =>  p_lnc_attribute17
      ,p_lnc_attribute18                =>  p_lnc_attribute18
      ,p_lnc_attribute19                =>  p_lnc_attribute19
      ,p_lnc_attribute20                =>  p_lnc_attribute20
      ,p_lnc_attribute21                =>  p_lnc_attribute21
      ,p_lnc_attribute22                =>  p_lnc_attribute22
      ,p_lnc_attribute23                =>  p_lnc_attribute23
      ,p_lnc_attribute24                =>  p_lnc_attribute24
      ,p_lnc_attribute25                =>  p_lnc_attribute25
      ,p_lnc_attribute26                =>  p_lnc_attribute26
      ,p_lnc_attribute27                =>  p_lnc_attribute27
      ,p_lnc_attribute28                =>  p_lnc_attribute28
      ,p_lnc_attribute29                =>  p_lnc_attribute29
      ,p_lnc_attribute30                =>  p_lnc_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ler_enrt_ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ler_enrt_ctfn
    --
  end;
  --
  ben_lnc_ins.ins
    (
     p_ler_enrt_ctfn_id              => l_ler_enrt_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_rqd_flag                      => p_rqd_flag
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_ler_rqrs_enrt_ctfn_id         => p_ler_rqrs_enrt_ctfn_id
    ,p_business_group_id             => p_business_group_id
    ,p_lnc_attribute_category        => p_lnc_attribute_category
    ,p_lnc_attribute1                => p_lnc_attribute1
    ,p_lnc_attribute2                => p_lnc_attribute2
    ,p_lnc_attribute3                => p_lnc_attribute3
    ,p_lnc_attribute4                => p_lnc_attribute4
    ,p_lnc_attribute5                => p_lnc_attribute5
    ,p_lnc_attribute6                => p_lnc_attribute6
    ,p_lnc_attribute7                => p_lnc_attribute7
    ,p_lnc_attribute8                => p_lnc_attribute8
    ,p_lnc_attribute9                => p_lnc_attribute9
    ,p_lnc_attribute10               => p_lnc_attribute10
    ,p_lnc_attribute11               => p_lnc_attribute11
    ,p_lnc_attribute12               => p_lnc_attribute12
    ,p_lnc_attribute13               => p_lnc_attribute13
    ,p_lnc_attribute14               => p_lnc_attribute14
    ,p_lnc_attribute15               => p_lnc_attribute15
    ,p_lnc_attribute16               => p_lnc_attribute16
    ,p_lnc_attribute17               => p_lnc_attribute17
    ,p_lnc_attribute18               => p_lnc_attribute18
    ,p_lnc_attribute19               => p_lnc_attribute19
    ,p_lnc_attribute20               => p_lnc_attribute20
    ,p_lnc_attribute21               => p_lnc_attribute21
    ,p_lnc_attribute22               => p_lnc_attribute22
    ,p_lnc_attribute23               => p_lnc_attribute23
    ,p_lnc_attribute24               => p_lnc_attribute24
    ,p_lnc_attribute25               => p_lnc_attribute25
    ,p_lnc_attribute26               => p_lnc_attribute26
    ,p_lnc_attribute27               => p_lnc_attribute27
    ,p_lnc_attribute28               => p_lnc_attribute28
    ,p_lnc_attribute29               => p_lnc_attribute29
    ,p_lnc_attribute30               => p_lnc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ler_enrt_ctfn
    --
    ben_ler_enrt_ctfn_bk1.create_ler_enrt_ctfn_a
      (
       p_ler_enrt_ctfn_id               =>  l_ler_enrt_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_ler_rqrs_enrt_ctfn_id          =>  p_ler_rqrs_enrt_ctfn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lnc_attribute_category         =>  p_lnc_attribute_category
      ,p_lnc_attribute1                 =>  p_lnc_attribute1
      ,p_lnc_attribute2                 =>  p_lnc_attribute2
      ,p_lnc_attribute3                 =>  p_lnc_attribute3
      ,p_lnc_attribute4                 =>  p_lnc_attribute4
      ,p_lnc_attribute5                 =>  p_lnc_attribute5
      ,p_lnc_attribute6                 =>  p_lnc_attribute6
      ,p_lnc_attribute7                 =>  p_lnc_attribute7
      ,p_lnc_attribute8                 =>  p_lnc_attribute8
      ,p_lnc_attribute9                 =>  p_lnc_attribute9
      ,p_lnc_attribute10                =>  p_lnc_attribute10
      ,p_lnc_attribute11                =>  p_lnc_attribute11
      ,p_lnc_attribute12                =>  p_lnc_attribute12
      ,p_lnc_attribute13                =>  p_lnc_attribute13
      ,p_lnc_attribute14                =>  p_lnc_attribute14
      ,p_lnc_attribute15                =>  p_lnc_attribute15
      ,p_lnc_attribute16                =>  p_lnc_attribute16
      ,p_lnc_attribute17                =>  p_lnc_attribute17
      ,p_lnc_attribute18                =>  p_lnc_attribute18
      ,p_lnc_attribute19                =>  p_lnc_attribute19
      ,p_lnc_attribute20                =>  p_lnc_attribute20
      ,p_lnc_attribute21                =>  p_lnc_attribute21
      ,p_lnc_attribute22                =>  p_lnc_attribute22
      ,p_lnc_attribute23                =>  p_lnc_attribute23
      ,p_lnc_attribute24                =>  p_lnc_attribute24
      ,p_lnc_attribute25                =>  p_lnc_attribute25
      ,p_lnc_attribute26                =>  p_lnc_attribute26
      ,p_lnc_attribute27                =>  p_lnc_attribute27
      ,p_lnc_attribute28                =>  p_lnc_attribute28
      ,p_lnc_attribute29                =>  p_lnc_attribute29
      ,p_lnc_attribute30                =>  p_lnc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ler_enrt_ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ler_enrt_ctfn
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
  p_ler_enrt_ctfn_id := l_ler_enrt_ctfn_id;
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
    ROLLBACK TO create_ler_enrt_ctfn;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ler_enrt_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ler_enrt_ctfn;
    /* Inserted for nocopy changes */
    p_ler_enrt_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_ler_enrt_ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ler_enrt_ctfn >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ler_enrt_ctfn
  (p_validate                       in  boolean   default false
  ,p_ler_enrt_ctfn_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_when_rl               in  number    default hr_api.g_number
  ,p_ler_rqrs_enrt_ctfn_id          in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_lnc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_lnc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ler_enrt_ctfn';
  l_object_version_number ben_ler_enrt_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_enrt_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_enrt_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ler_enrt_ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ler_enrt_ctfn
    --
    ben_ler_enrt_ctfn_bk2.update_ler_enrt_ctfn_b
      (
       p_ler_enrt_ctfn_id               =>  p_ler_enrt_ctfn_id
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_ler_rqrs_enrt_ctfn_id          =>  p_ler_rqrs_enrt_ctfn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lnc_attribute_category         =>  p_lnc_attribute_category
      ,p_lnc_attribute1                 =>  p_lnc_attribute1
      ,p_lnc_attribute2                 =>  p_lnc_attribute2
      ,p_lnc_attribute3                 =>  p_lnc_attribute3
      ,p_lnc_attribute4                 =>  p_lnc_attribute4
      ,p_lnc_attribute5                 =>  p_lnc_attribute5
      ,p_lnc_attribute6                 =>  p_lnc_attribute6
      ,p_lnc_attribute7                 =>  p_lnc_attribute7
      ,p_lnc_attribute8                 =>  p_lnc_attribute8
      ,p_lnc_attribute9                 =>  p_lnc_attribute9
      ,p_lnc_attribute10                =>  p_lnc_attribute10
      ,p_lnc_attribute11                =>  p_lnc_attribute11
      ,p_lnc_attribute12                =>  p_lnc_attribute12
      ,p_lnc_attribute13                =>  p_lnc_attribute13
      ,p_lnc_attribute14                =>  p_lnc_attribute14
      ,p_lnc_attribute15                =>  p_lnc_attribute15
      ,p_lnc_attribute16                =>  p_lnc_attribute16
      ,p_lnc_attribute17                =>  p_lnc_attribute17
      ,p_lnc_attribute18                =>  p_lnc_attribute18
      ,p_lnc_attribute19                =>  p_lnc_attribute19
      ,p_lnc_attribute20                =>  p_lnc_attribute20
      ,p_lnc_attribute21                =>  p_lnc_attribute21
      ,p_lnc_attribute22                =>  p_lnc_attribute22
      ,p_lnc_attribute23                =>  p_lnc_attribute23
      ,p_lnc_attribute24                =>  p_lnc_attribute24
      ,p_lnc_attribute25                =>  p_lnc_attribute25
      ,p_lnc_attribute26                =>  p_lnc_attribute26
      ,p_lnc_attribute27                =>  p_lnc_attribute27
      ,p_lnc_attribute28                =>  p_lnc_attribute28
      ,p_lnc_attribute29                =>  p_lnc_attribute29
      ,p_lnc_attribute30                =>  p_lnc_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ler_enrt_ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ler_enrt_ctfn
    --
  end;
  --
  ben_lnc_upd.upd
    (
     p_ler_enrt_ctfn_id              => p_ler_enrt_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_rqd_flag                      => p_rqd_flag
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_ler_rqrs_enrt_ctfn_id         => p_ler_rqrs_enrt_ctfn_id
    ,p_business_group_id             => p_business_group_id
    ,p_lnc_attribute_category        => p_lnc_attribute_category
    ,p_lnc_attribute1                => p_lnc_attribute1
    ,p_lnc_attribute2                => p_lnc_attribute2
    ,p_lnc_attribute3                => p_lnc_attribute3
    ,p_lnc_attribute4                => p_lnc_attribute4
    ,p_lnc_attribute5                => p_lnc_attribute5
    ,p_lnc_attribute6                => p_lnc_attribute6
    ,p_lnc_attribute7                => p_lnc_attribute7
    ,p_lnc_attribute8                => p_lnc_attribute8
    ,p_lnc_attribute9                => p_lnc_attribute9
    ,p_lnc_attribute10               => p_lnc_attribute10
    ,p_lnc_attribute11               => p_lnc_attribute11
    ,p_lnc_attribute12               => p_lnc_attribute12
    ,p_lnc_attribute13               => p_lnc_attribute13
    ,p_lnc_attribute14               => p_lnc_attribute14
    ,p_lnc_attribute15               => p_lnc_attribute15
    ,p_lnc_attribute16               => p_lnc_attribute16
    ,p_lnc_attribute17               => p_lnc_attribute17
    ,p_lnc_attribute18               => p_lnc_attribute18
    ,p_lnc_attribute19               => p_lnc_attribute19
    ,p_lnc_attribute20               => p_lnc_attribute20
    ,p_lnc_attribute21               => p_lnc_attribute21
    ,p_lnc_attribute22               => p_lnc_attribute22
    ,p_lnc_attribute23               => p_lnc_attribute23
    ,p_lnc_attribute24               => p_lnc_attribute24
    ,p_lnc_attribute25               => p_lnc_attribute25
    ,p_lnc_attribute26               => p_lnc_attribute26
    ,p_lnc_attribute27               => p_lnc_attribute27
    ,p_lnc_attribute28               => p_lnc_attribute28
    ,p_lnc_attribute29               => p_lnc_attribute29
    ,p_lnc_attribute30               => p_lnc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ler_enrt_ctfn
    --
    ben_ler_enrt_ctfn_bk2.update_ler_enrt_ctfn_a
      (
       p_ler_enrt_ctfn_id               =>  p_ler_enrt_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_ler_rqrs_enrt_ctfn_id          =>  p_ler_rqrs_enrt_ctfn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lnc_attribute_category         =>  p_lnc_attribute_category
      ,p_lnc_attribute1                 =>  p_lnc_attribute1
      ,p_lnc_attribute2                 =>  p_lnc_attribute2
      ,p_lnc_attribute3                 =>  p_lnc_attribute3
      ,p_lnc_attribute4                 =>  p_lnc_attribute4
      ,p_lnc_attribute5                 =>  p_lnc_attribute5
      ,p_lnc_attribute6                 =>  p_lnc_attribute6
      ,p_lnc_attribute7                 =>  p_lnc_attribute7
      ,p_lnc_attribute8                 =>  p_lnc_attribute8
      ,p_lnc_attribute9                 =>  p_lnc_attribute9
      ,p_lnc_attribute10                =>  p_lnc_attribute10
      ,p_lnc_attribute11                =>  p_lnc_attribute11
      ,p_lnc_attribute12                =>  p_lnc_attribute12
      ,p_lnc_attribute13                =>  p_lnc_attribute13
      ,p_lnc_attribute14                =>  p_lnc_attribute14
      ,p_lnc_attribute15                =>  p_lnc_attribute15
      ,p_lnc_attribute16                =>  p_lnc_attribute16
      ,p_lnc_attribute17                =>  p_lnc_attribute17
      ,p_lnc_attribute18                =>  p_lnc_attribute18
      ,p_lnc_attribute19                =>  p_lnc_attribute19
      ,p_lnc_attribute20                =>  p_lnc_attribute20
      ,p_lnc_attribute21                =>  p_lnc_attribute21
      ,p_lnc_attribute22                =>  p_lnc_attribute22
      ,p_lnc_attribute23                =>  p_lnc_attribute23
      ,p_lnc_attribute24                =>  p_lnc_attribute24
      ,p_lnc_attribute25                =>  p_lnc_attribute25
      ,p_lnc_attribute26                =>  p_lnc_attribute26
      ,p_lnc_attribute27                =>  p_lnc_attribute27
      ,p_lnc_attribute28                =>  p_lnc_attribute28
      ,p_lnc_attribute29                =>  p_lnc_attribute29
      ,p_lnc_attribute30                =>  p_lnc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ler_enrt_ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ler_enrt_ctfn
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
    ROLLBACK TO update_ler_enrt_ctfn;
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
    ROLLBACK TO update_ler_enrt_ctfn;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_ler_enrt_ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ler_enrt_ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ler_enrt_ctfn
  (p_validate                       in  boolean  default false
  ,p_ler_enrt_ctfn_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ler_enrt_ctfn';
  l_object_version_number ben_ler_enrt_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_enrt_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_enrt_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ler_enrt_ctfn;
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
    -- Start of API User Hook for the before hook of delete_ler_enrt_ctfn
    --
    ben_ler_enrt_ctfn_bk3.delete_ler_enrt_ctfn_b
      (
       p_ler_enrt_ctfn_id               =>  p_ler_enrt_ctfn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ler_enrt_ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ler_enrt_ctfn
    --
  end;
  --
  ben_lnc_del.del
    (
     p_ler_enrt_ctfn_id              => p_ler_enrt_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ler_enrt_ctfn
    --
    ben_ler_enrt_ctfn_bk3.delete_ler_enrt_ctfn_a
      (
       p_ler_enrt_ctfn_id               =>  p_ler_enrt_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ler_enrt_ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ler_enrt_ctfn
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
    ROLLBACK TO delete_ler_enrt_ctfn;
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
    ROLLBACK TO delete_ler_enrt_ctfn;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_ler_enrt_ctfn;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ler_enrt_ctfn_id                   in     number
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
  ben_lnc_shd.lck
    (
      p_ler_enrt_ctfn_id                 => p_ler_enrt_ctfn_id
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
end ben_ler_enrt_ctfn_api;

/
