--------------------------------------------------------
--  DDL for Package Body BEN_BNFT_RSTRN_CTFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNFT_RSTRN_CTFN_API" as
/* $Header: bebrcapi.pkb 120.0 2005/05/28 00:49:50 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_BNFT_RSTRN_CTFN_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_BNFT_RSTRN_CTFN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_BNFT_RSTRN_CTFN
  (p_validate                       in  boolean   default false
  ,p_bnft_rstrn_ctfn_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_ctfn_rqd_when_rl               in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_brc_attribute_category         in  varchar2  default null
  ,p_brc_attribute1                 in  varchar2  default null
  ,p_brc_attribute2                 in  varchar2  default null
  ,p_brc_attribute3                 in  varchar2  default null
  ,p_brc_attribute4                 in  varchar2  default null
  ,p_brc_attribute5                 in  varchar2  default null
  ,p_brc_attribute6                 in  varchar2  default null
  ,p_brc_attribute7                 in  varchar2  default null
  ,p_brc_attribute8                 in  varchar2  default null
  ,p_brc_attribute9                 in  varchar2  default null
  ,p_brc_attribute10                in  varchar2  default null
  ,p_brc_attribute11                in  varchar2  default null
  ,p_brc_attribute12                in  varchar2  default null
  ,p_brc_attribute13                in  varchar2  default null
  ,p_brc_attribute14                in  varchar2  default null
  ,p_brc_attribute15                in  varchar2  default null
  ,p_brc_attribute16                in  varchar2  default null
  ,p_brc_attribute17                in  varchar2  default null
  ,p_brc_attribute18                in  varchar2  default null
  ,p_brc_attribute19                in  varchar2  default null
  ,p_brc_attribute20                in  varchar2  default null
  ,p_brc_attribute21                in  varchar2  default null
  ,p_brc_attribute22                in  varchar2  default null
  ,p_brc_attribute23                in  varchar2  default null
  ,p_brc_attribute24                in  varchar2  default null
  ,p_brc_attribute25                in  varchar2  default null
  ,p_brc_attribute26                in  varchar2  default null
  ,p_brc_attribute27                in  varchar2  default null
  ,p_brc_attribute28                in  varchar2  default null
  ,p_brc_attribute29                in  varchar2  default null
  ,p_brc_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_bnft_rstrn_ctfn_id ben_bnft_rstrn_ctfn_f.bnft_rstrn_ctfn_id%TYPE;
  l_effective_start_date ben_bnft_rstrn_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_rstrn_ctfn_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_BNFT_RSTRN_CTFN';
  l_object_version_number ben_bnft_rstrn_ctfn_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_BNFT_RSTRN_CTFN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_BNFT_RSTRN_CTFN
    --
    ben_BNFT_RSTRN_CTFN_bk1.create_BNFT_RSTRN_CTFN_b
      (
       p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_brc_attribute_category         =>  p_brc_attribute_category
      ,p_brc_attribute1                 =>  p_brc_attribute1
      ,p_brc_attribute2                 =>  p_brc_attribute2
      ,p_brc_attribute3                 =>  p_brc_attribute3
      ,p_brc_attribute4                 =>  p_brc_attribute4
      ,p_brc_attribute5                 =>  p_brc_attribute5
      ,p_brc_attribute6                 =>  p_brc_attribute6
      ,p_brc_attribute7                 =>  p_brc_attribute7
      ,p_brc_attribute8                 =>  p_brc_attribute8
      ,p_brc_attribute9                 =>  p_brc_attribute9
      ,p_brc_attribute10                =>  p_brc_attribute10
      ,p_brc_attribute11                =>  p_brc_attribute11
      ,p_brc_attribute12                =>  p_brc_attribute12
      ,p_brc_attribute13                =>  p_brc_attribute13
      ,p_brc_attribute14                =>  p_brc_attribute14
      ,p_brc_attribute15                =>  p_brc_attribute15
      ,p_brc_attribute16                =>  p_brc_attribute16
      ,p_brc_attribute17                =>  p_brc_attribute17
      ,p_brc_attribute18                =>  p_brc_attribute18
      ,p_brc_attribute19                =>  p_brc_attribute19
      ,p_brc_attribute20                =>  p_brc_attribute20
      ,p_brc_attribute21                =>  p_brc_attribute21
      ,p_brc_attribute22                =>  p_brc_attribute22
      ,p_brc_attribute23                =>  p_brc_attribute23
      ,p_brc_attribute24                =>  p_brc_attribute24
      ,p_brc_attribute25                =>  p_brc_attribute25
      ,p_brc_attribute26                =>  p_brc_attribute26
      ,p_brc_attribute27                =>  p_brc_attribute27
      ,p_brc_attribute28                =>  p_brc_attribute28
      ,p_brc_attribute29                =>  p_brc_attribute29
      ,p_brc_attribute30                =>  p_brc_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_BNFT_RSTRN_CTFN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_BNFT_RSTRN_CTFN
    --
  end;
  --
  ben_brc_ins.ins
    (
     p_bnft_rstrn_ctfn_id            => l_bnft_rstrn_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_rqd_flag                      => p_rqd_flag
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_brc_attribute_category        => p_brc_attribute_category
    ,p_brc_attribute1                => p_brc_attribute1
    ,p_brc_attribute2                => p_brc_attribute2
    ,p_brc_attribute3                => p_brc_attribute3
    ,p_brc_attribute4                => p_brc_attribute4
    ,p_brc_attribute5                => p_brc_attribute5
    ,p_brc_attribute6                => p_brc_attribute6
    ,p_brc_attribute7                => p_brc_attribute7
    ,p_brc_attribute8                => p_brc_attribute8
    ,p_brc_attribute9                => p_brc_attribute9
    ,p_brc_attribute10               => p_brc_attribute10
    ,p_brc_attribute11               => p_brc_attribute11
    ,p_brc_attribute12               => p_brc_attribute12
    ,p_brc_attribute13               => p_brc_attribute13
    ,p_brc_attribute14               => p_brc_attribute14
    ,p_brc_attribute15               => p_brc_attribute15
    ,p_brc_attribute16               => p_brc_attribute16
    ,p_brc_attribute17               => p_brc_attribute17
    ,p_brc_attribute18               => p_brc_attribute18
    ,p_brc_attribute19               => p_brc_attribute19
    ,p_brc_attribute20               => p_brc_attribute20
    ,p_brc_attribute21               => p_brc_attribute21
    ,p_brc_attribute22               => p_brc_attribute22
    ,p_brc_attribute23               => p_brc_attribute23
    ,p_brc_attribute24               => p_brc_attribute24
    ,p_brc_attribute25               => p_brc_attribute25
    ,p_brc_attribute26               => p_brc_attribute26
    ,p_brc_attribute27               => p_brc_attribute27
    ,p_brc_attribute28               => p_brc_attribute28
    ,p_brc_attribute29               => p_brc_attribute29
    ,p_brc_attribute30               => p_brc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_BNFT_RSTRN_CTFN
    --
    ben_BNFT_RSTRN_CTFN_bk1.create_BNFT_RSTRN_CTFN_a
      (
       p_bnft_rstrn_ctfn_id             =>  l_bnft_rstrn_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_brc_attribute_category         =>  p_brc_attribute_category
      ,p_brc_attribute1                 =>  p_brc_attribute1
      ,p_brc_attribute2                 =>  p_brc_attribute2
      ,p_brc_attribute3                 =>  p_brc_attribute3
      ,p_brc_attribute4                 =>  p_brc_attribute4
      ,p_brc_attribute5                 =>  p_brc_attribute5
      ,p_brc_attribute6                 =>  p_brc_attribute6
      ,p_brc_attribute7                 =>  p_brc_attribute7
      ,p_brc_attribute8                 =>  p_brc_attribute8
      ,p_brc_attribute9                 =>  p_brc_attribute9
      ,p_brc_attribute10                =>  p_brc_attribute10
      ,p_brc_attribute11                =>  p_brc_attribute11
      ,p_brc_attribute12                =>  p_brc_attribute12
      ,p_brc_attribute13                =>  p_brc_attribute13
      ,p_brc_attribute14                =>  p_brc_attribute14
      ,p_brc_attribute15                =>  p_brc_attribute15
      ,p_brc_attribute16                =>  p_brc_attribute16
      ,p_brc_attribute17                =>  p_brc_attribute17
      ,p_brc_attribute18                =>  p_brc_attribute18
      ,p_brc_attribute19                =>  p_brc_attribute19
      ,p_brc_attribute20                =>  p_brc_attribute20
      ,p_brc_attribute21                =>  p_brc_attribute21
      ,p_brc_attribute22                =>  p_brc_attribute22
      ,p_brc_attribute23                =>  p_brc_attribute23
      ,p_brc_attribute24                =>  p_brc_attribute24
      ,p_brc_attribute25                =>  p_brc_attribute25
      ,p_brc_attribute26                =>  p_brc_attribute26
      ,p_brc_attribute27                =>  p_brc_attribute27
      ,p_brc_attribute28                =>  p_brc_attribute28
      ,p_brc_attribute29                =>  p_brc_attribute29
      ,p_brc_attribute30                =>  p_brc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BNFT_RSTRN_CTFN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_BNFT_RSTRN_CTFN
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
  p_bnft_rstrn_ctfn_id := l_bnft_rstrn_ctfn_id;
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
    ROLLBACK TO create_BNFT_RSTRN_CTFN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_bnft_rstrn_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_bnft_rstrn_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    --
    ROLLBACK TO create_BNFT_RSTRN_CTFN;
    raise;
    --
end create_BNFT_RSTRN_CTFN;
-- ----------------------------------------------------------------------------
-- |------------------------< update_BNFT_RSTRN_CTFN >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_BNFT_RSTRN_CTFN
  (p_validate                       in  boolean   default false
  ,p_bnft_rstrn_ctfn_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_when_rl               in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_brc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_brc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_BNFT_RSTRN_CTFN';
  l_object_version_number ben_bnft_rstrn_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_rstrn_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_rstrn_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_BNFT_RSTRN_CTFN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_BNFT_RSTRN_CTFN
    --
    ben_BNFT_RSTRN_CTFN_bk2.update_BNFT_RSTRN_CTFN_b
      (
       p_bnft_rstrn_ctfn_id             =>  p_bnft_rstrn_ctfn_id
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_brc_attribute_category         =>  p_brc_attribute_category
      ,p_brc_attribute1                 =>  p_brc_attribute1
      ,p_brc_attribute2                 =>  p_brc_attribute2
      ,p_brc_attribute3                 =>  p_brc_attribute3
      ,p_brc_attribute4                 =>  p_brc_attribute4
      ,p_brc_attribute5                 =>  p_brc_attribute5
      ,p_brc_attribute6                 =>  p_brc_attribute6
      ,p_brc_attribute7                 =>  p_brc_attribute7
      ,p_brc_attribute8                 =>  p_brc_attribute8
      ,p_brc_attribute9                 =>  p_brc_attribute9
      ,p_brc_attribute10                =>  p_brc_attribute10
      ,p_brc_attribute11                =>  p_brc_attribute11
      ,p_brc_attribute12                =>  p_brc_attribute12
      ,p_brc_attribute13                =>  p_brc_attribute13
      ,p_brc_attribute14                =>  p_brc_attribute14
      ,p_brc_attribute15                =>  p_brc_attribute15
      ,p_brc_attribute16                =>  p_brc_attribute16
      ,p_brc_attribute17                =>  p_brc_attribute17
      ,p_brc_attribute18                =>  p_brc_attribute18
      ,p_brc_attribute19                =>  p_brc_attribute19
      ,p_brc_attribute20                =>  p_brc_attribute20
      ,p_brc_attribute21                =>  p_brc_attribute21
      ,p_brc_attribute22                =>  p_brc_attribute22
      ,p_brc_attribute23                =>  p_brc_attribute23
      ,p_brc_attribute24                =>  p_brc_attribute24
      ,p_brc_attribute25                =>  p_brc_attribute25
      ,p_brc_attribute26                =>  p_brc_attribute26
      ,p_brc_attribute27                =>  p_brc_attribute27
      ,p_brc_attribute28                =>  p_brc_attribute28
      ,p_brc_attribute29                =>  p_brc_attribute29
      ,p_brc_attribute30                =>  p_brc_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BNFT_RSTRN_CTFN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_BNFT_RSTRN_CTFN
    --
  end;
  --
  ben_brc_upd.upd
    (
     p_bnft_rstrn_ctfn_id            => p_bnft_rstrn_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_rqd_flag                      => p_rqd_flag
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_brc_attribute_category        => p_brc_attribute_category
    ,p_brc_attribute1                => p_brc_attribute1
    ,p_brc_attribute2                => p_brc_attribute2
    ,p_brc_attribute3                => p_brc_attribute3
    ,p_brc_attribute4                => p_brc_attribute4
    ,p_brc_attribute5                => p_brc_attribute5
    ,p_brc_attribute6                => p_brc_attribute6
    ,p_brc_attribute7                => p_brc_attribute7
    ,p_brc_attribute8                => p_brc_attribute8
    ,p_brc_attribute9                => p_brc_attribute9
    ,p_brc_attribute10               => p_brc_attribute10
    ,p_brc_attribute11               => p_brc_attribute11
    ,p_brc_attribute12               => p_brc_attribute12
    ,p_brc_attribute13               => p_brc_attribute13
    ,p_brc_attribute14               => p_brc_attribute14
    ,p_brc_attribute15               => p_brc_attribute15
    ,p_brc_attribute16               => p_brc_attribute16
    ,p_brc_attribute17               => p_brc_attribute17
    ,p_brc_attribute18               => p_brc_attribute18
    ,p_brc_attribute19               => p_brc_attribute19
    ,p_brc_attribute20               => p_brc_attribute20
    ,p_brc_attribute21               => p_brc_attribute21
    ,p_brc_attribute22               => p_brc_attribute22
    ,p_brc_attribute23               => p_brc_attribute23
    ,p_brc_attribute24               => p_brc_attribute24
    ,p_brc_attribute25               => p_brc_attribute25
    ,p_brc_attribute26               => p_brc_attribute26
    ,p_brc_attribute27               => p_brc_attribute27
    ,p_brc_attribute28               => p_brc_attribute28
    ,p_brc_attribute29               => p_brc_attribute29
    ,p_brc_attribute30               => p_brc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_BNFT_RSTRN_CTFN
    --
    ben_BNFT_RSTRN_CTFN_bk2.update_BNFT_RSTRN_CTFN_a
      (
       p_bnft_rstrn_ctfn_id             =>  p_bnft_rstrn_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_brc_attribute_category         =>  p_brc_attribute_category
      ,p_brc_attribute1                 =>  p_brc_attribute1
      ,p_brc_attribute2                 =>  p_brc_attribute2
      ,p_brc_attribute3                 =>  p_brc_attribute3
      ,p_brc_attribute4                 =>  p_brc_attribute4
      ,p_brc_attribute5                 =>  p_brc_attribute5
      ,p_brc_attribute6                 =>  p_brc_attribute6
      ,p_brc_attribute7                 =>  p_brc_attribute7
      ,p_brc_attribute8                 =>  p_brc_attribute8
      ,p_brc_attribute9                 =>  p_brc_attribute9
      ,p_brc_attribute10                =>  p_brc_attribute10
      ,p_brc_attribute11                =>  p_brc_attribute11
      ,p_brc_attribute12                =>  p_brc_attribute12
      ,p_brc_attribute13                =>  p_brc_attribute13
      ,p_brc_attribute14                =>  p_brc_attribute14
      ,p_brc_attribute15                =>  p_brc_attribute15
      ,p_brc_attribute16                =>  p_brc_attribute16
      ,p_brc_attribute17                =>  p_brc_attribute17
      ,p_brc_attribute18                =>  p_brc_attribute18
      ,p_brc_attribute19                =>  p_brc_attribute19
      ,p_brc_attribute20                =>  p_brc_attribute20
      ,p_brc_attribute21                =>  p_brc_attribute21
      ,p_brc_attribute22                =>  p_brc_attribute22
      ,p_brc_attribute23                =>  p_brc_attribute23
      ,p_brc_attribute24                =>  p_brc_attribute24
      ,p_brc_attribute25                =>  p_brc_attribute25
      ,p_brc_attribute26                =>  p_brc_attribute26
      ,p_brc_attribute27                =>  p_brc_attribute27
      ,p_brc_attribute28                =>  p_brc_attribute28
      ,p_brc_attribute29                =>  p_brc_attribute29
      ,p_brc_attribute30                =>  p_brc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BNFT_RSTRN_CTFN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_BNFT_RSTRN_CTFN
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
    ROLLBACK TO update_BNFT_RSTRN_CTFN;
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
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    --
    ROLLBACK TO update_BNFT_RSTRN_CTFN;
    raise;
    --
end update_BNFT_RSTRN_CTFN;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_BNFT_RSTRN_CTFN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_BNFT_RSTRN_CTFN
  (p_validate                       in  boolean  default false
  ,p_bnft_rstrn_ctfn_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_BNFT_RSTRN_CTFN';
  l_object_version_number ben_bnft_rstrn_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_rstrn_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_rstrn_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_BNFT_RSTRN_CTFN;
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
    -- Start of API User Hook for the before hook of delete_BNFT_RSTRN_CTFN
    --
    ben_BNFT_RSTRN_CTFN_bk3.delete_BNFT_RSTRN_CTFN_b
      (
       p_bnft_rstrn_ctfn_id             =>  p_bnft_rstrn_ctfn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BNFT_RSTRN_CTFN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_BNFT_RSTRN_CTFN
    --
  end;
  --
  ben_brc_del.del
    (
     p_bnft_rstrn_ctfn_id            => p_bnft_rstrn_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_BNFT_RSTRN_CTFN
    --
    ben_BNFT_RSTRN_CTFN_bk3.delete_BNFT_RSTRN_CTFN_a
      (
       p_bnft_rstrn_ctfn_id             =>  p_bnft_rstrn_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BNFT_RSTRN_CTFN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_BNFT_RSTRN_CTFN
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
    ROLLBACK TO delete_BNFT_RSTRN_CTFN;
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
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    --
    ROLLBACK TO delete_BNFT_RSTRN_CTFN;
    raise;
    --
end delete_BNFT_RSTRN_CTFN;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_bnft_rstrn_ctfn_id                   in     number
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
  ben_brc_shd.lck
    (
      p_bnft_rstrn_ctfn_id                 => p_bnft_rstrn_ctfn_id
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
end ben_BNFT_RSTRN_CTFN_api;

/
