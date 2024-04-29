--------------------------------------------------------
--  DDL for Package Body BEN_WV_PRTN_RSN_CTFN_PL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WV_PRTN_RSN_CTFN_PL_API" as
/* $Header: bewcnapi.pkb 115.3 2002/12/27 21:49:02 tjesumic ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_WV_PRTN_RSN_CTFN_PL_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WV_PRTN_RSN_CTFN_PL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_WV_PRTN_RSN_CTFN_PL
  (p_validate                       in  boolean   default false
  ,p_wv_prtn_rsn_ctfn_pl_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pfd_flag                       in  varchar2  default null
  ,p_lack_ctfn_sspnd_wvr_flag       in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default null
  ,p_ctfn_rqd_when_rl               in  number    default null
  ,p_wv_prtn_ctfn_typ_cd            in  varchar2  default null
  ,p_wv_prtn_rsn_pl_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_wcn_attribute_category         in  varchar2  default null
  ,p_wcn_attribute1                 in  varchar2  default null
  ,p_wcn_attribute2                 in  varchar2  default null
  ,p_wcn_attribute3                 in  varchar2  default null
  ,p_wcn_attribute4                 in  varchar2  default null
  ,p_wcn_attribute5                 in  varchar2  default null
  ,p_wcn_attribute6                 in  varchar2  default null
  ,p_wcn_attribute7                 in  varchar2  default null
  ,p_wcn_attribute8                 in  varchar2  default null
  ,p_wcn_attribute9                 in  varchar2  default null
  ,p_wcn_attribute10                in  varchar2  default null
  ,p_wcn_attribute11                in  varchar2  default null
  ,p_wcn_attribute12                in  varchar2  default null
  ,p_wcn_attribute13                in  varchar2  default null
  ,p_wcn_attribute14                in  varchar2  default null
  ,p_wcn_attribute15                in  varchar2  default null
  ,p_wcn_attribute16                in  varchar2  default null
  ,p_wcn_attribute17                in  varchar2  default null
  ,p_wcn_attribute18                in  varchar2  default null
  ,p_wcn_attribute19                in  varchar2  default null
  ,p_wcn_attribute20                in  varchar2  default null
  ,p_wcn_attribute21                in  varchar2  default null
  ,p_wcn_attribute22                in  varchar2  default null
  ,p_wcn_attribute23                in  varchar2  default null
  ,p_wcn_attribute24                in  varchar2  default null
  ,p_wcn_attribute25                in  varchar2  default null
  ,p_wcn_attribute26                in  varchar2  default null
  ,p_wcn_attribute27                in  varchar2  default null
  ,p_wcn_attribute28                in  varchar2  default null
  ,p_wcn_attribute29                in  varchar2  default null
  ,p_wcn_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_wv_prtn_rsn_ctfn_pl_id ben_wv_prtn_rsn_ctfn_pl_f.wv_prtn_rsn_ctfn_pl_id%TYPE;
  l_effective_start_date ben_wv_prtn_rsn_ctfn_pl_f.effective_start_date%TYPE;
  l_effective_end_date ben_wv_prtn_rsn_ctfn_pl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_WV_PRTN_RSN_CTFN_PL';
  l_object_version_number ben_wv_prtn_rsn_ctfn_pl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_WV_PRTN_RSN_CTFN_PL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_WV_PRTN_RSN_CTFN_PL
    --
    ben_WV_PRTN_RSN_CTFN_PL_bk1.create_WV_PRTN_RSN_CTFN_PL_b
      (
       p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_wvr_flag       =>  p_lack_ctfn_sspnd_wvr_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_wv_prtn_ctfn_typ_cd            =>  p_wv_prtn_ctfn_typ_cd
      ,p_wv_prtn_rsn_pl_id              =>  p_wv_prtn_rsn_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_wcn_attribute_category         =>  p_wcn_attribute_category
      ,p_wcn_attribute1                 =>  p_wcn_attribute1
      ,p_wcn_attribute2                 =>  p_wcn_attribute2
      ,p_wcn_attribute3                 =>  p_wcn_attribute3
      ,p_wcn_attribute4                 =>  p_wcn_attribute4
      ,p_wcn_attribute5                 =>  p_wcn_attribute5
      ,p_wcn_attribute6                 =>  p_wcn_attribute6
      ,p_wcn_attribute7                 =>  p_wcn_attribute7
      ,p_wcn_attribute8                 =>  p_wcn_attribute8
      ,p_wcn_attribute9                 =>  p_wcn_attribute9
      ,p_wcn_attribute10                =>  p_wcn_attribute10
      ,p_wcn_attribute11                =>  p_wcn_attribute11
      ,p_wcn_attribute12                =>  p_wcn_attribute12
      ,p_wcn_attribute13                =>  p_wcn_attribute13
      ,p_wcn_attribute14                =>  p_wcn_attribute14
      ,p_wcn_attribute15                =>  p_wcn_attribute15
      ,p_wcn_attribute16                =>  p_wcn_attribute16
      ,p_wcn_attribute17                =>  p_wcn_attribute17
      ,p_wcn_attribute18                =>  p_wcn_attribute18
      ,p_wcn_attribute19                =>  p_wcn_attribute19
      ,p_wcn_attribute20                =>  p_wcn_attribute20
      ,p_wcn_attribute21                =>  p_wcn_attribute21
      ,p_wcn_attribute22                =>  p_wcn_attribute22
      ,p_wcn_attribute23                =>  p_wcn_attribute23
      ,p_wcn_attribute24                =>  p_wcn_attribute24
      ,p_wcn_attribute25                =>  p_wcn_attribute25
      ,p_wcn_attribute26                =>  p_wcn_attribute26
      ,p_wcn_attribute27                =>  p_wcn_attribute27
      ,p_wcn_attribute28                =>  p_wcn_attribute28
      ,p_wcn_attribute29                =>  p_wcn_attribute29
      ,p_wcn_attribute30                =>  p_wcn_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_WV_PRTN_RSN_CTFN_PL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_WV_PRTN_RSN_CTFN_PL
    --
  end;
  --
  ben_wcn_ins.ins
    (
     p_wv_prtn_rsn_ctfn_pl_id        => l_wv_prtn_rsn_ctfn_pl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pfd_flag                      => p_pfd_flag
    ,p_lack_ctfn_sspnd_wvr_flag      => p_lack_ctfn_sspnd_wvr_flag
    ,p_rqd_flag                      => p_rqd_flag
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_wv_prtn_ctfn_typ_cd           => p_wv_prtn_ctfn_typ_cd
    ,p_wv_prtn_rsn_pl_id             => p_wv_prtn_rsn_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_wcn_attribute_category        => p_wcn_attribute_category
    ,p_wcn_attribute1                => p_wcn_attribute1
    ,p_wcn_attribute2                => p_wcn_attribute2
    ,p_wcn_attribute3                => p_wcn_attribute3
    ,p_wcn_attribute4                => p_wcn_attribute4
    ,p_wcn_attribute5                => p_wcn_attribute5
    ,p_wcn_attribute6                => p_wcn_attribute6
    ,p_wcn_attribute7                => p_wcn_attribute7
    ,p_wcn_attribute8                => p_wcn_attribute8
    ,p_wcn_attribute9                => p_wcn_attribute9
    ,p_wcn_attribute10               => p_wcn_attribute10
    ,p_wcn_attribute11               => p_wcn_attribute11
    ,p_wcn_attribute12               => p_wcn_attribute12
    ,p_wcn_attribute13               => p_wcn_attribute13
    ,p_wcn_attribute14               => p_wcn_attribute14
    ,p_wcn_attribute15               => p_wcn_attribute15
    ,p_wcn_attribute16               => p_wcn_attribute16
    ,p_wcn_attribute17               => p_wcn_attribute17
    ,p_wcn_attribute18               => p_wcn_attribute18
    ,p_wcn_attribute19               => p_wcn_attribute19
    ,p_wcn_attribute20               => p_wcn_attribute20
    ,p_wcn_attribute21               => p_wcn_attribute21
    ,p_wcn_attribute22               => p_wcn_attribute22
    ,p_wcn_attribute23               => p_wcn_attribute23
    ,p_wcn_attribute24               => p_wcn_attribute24
    ,p_wcn_attribute25               => p_wcn_attribute25
    ,p_wcn_attribute26               => p_wcn_attribute26
    ,p_wcn_attribute27               => p_wcn_attribute27
    ,p_wcn_attribute28               => p_wcn_attribute28
    ,p_wcn_attribute29               => p_wcn_attribute29
    ,p_wcn_attribute30               => p_wcn_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_WV_PRTN_RSN_CTFN_PL
    --
    ben_WV_PRTN_RSN_CTFN_PL_bk1.create_WV_PRTN_RSN_CTFN_PL_a
      (
       p_wv_prtn_rsn_ctfn_pl_id         =>  l_wv_prtn_rsn_ctfn_pl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_wvr_flag       =>  p_lack_ctfn_sspnd_wvr_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_wv_prtn_ctfn_typ_cd            =>  p_wv_prtn_ctfn_typ_cd
      ,p_wv_prtn_rsn_pl_id              =>  p_wv_prtn_rsn_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_wcn_attribute_category         =>  p_wcn_attribute_category
      ,p_wcn_attribute1                 =>  p_wcn_attribute1
      ,p_wcn_attribute2                 =>  p_wcn_attribute2
      ,p_wcn_attribute3                 =>  p_wcn_attribute3
      ,p_wcn_attribute4                 =>  p_wcn_attribute4
      ,p_wcn_attribute5                 =>  p_wcn_attribute5
      ,p_wcn_attribute6                 =>  p_wcn_attribute6
      ,p_wcn_attribute7                 =>  p_wcn_attribute7
      ,p_wcn_attribute8                 =>  p_wcn_attribute8
      ,p_wcn_attribute9                 =>  p_wcn_attribute9
      ,p_wcn_attribute10                =>  p_wcn_attribute10
      ,p_wcn_attribute11                =>  p_wcn_attribute11
      ,p_wcn_attribute12                =>  p_wcn_attribute12
      ,p_wcn_attribute13                =>  p_wcn_attribute13
      ,p_wcn_attribute14                =>  p_wcn_attribute14
      ,p_wcn_attribute15                =>  p_wcn_attribute15
      ,p_wcn_attribute16                =>  p_wcn_attribute16
      ,p_wcn_attribute17                =>  p_wcn_attribute17
      ,p_wcn_attribute18                =>  p_wcn_attribute18
      ,p_wcn_attribute19                =>  p_wcn_attribute19
      ,p_wcn_attribute20                =>  p_wcn_attribute20
      ,p_wcn_attribute21                =>  p_wcn_attribute21
      ,p_wcn_attribute22                =>  p_wcn_attribute22
      ,p_wcn_attribute23                =>  p_wcn_attribute23
      ,p_wcn_attribute24                =>  p_wcn_attribute24
      ,p_wcn_attribute25                =>  p_wcn_attribute25
      ,p_wcn_attribute26                =>  p_wcn_attribute26
      ,p_wcn_attribute27                =>  p_wcn_attribute27
      ,p_wcn_attribute28                =>  p_wcn_attribute28
      ,p_wcn_attribute29                =>  p_wcn_attribute29
      ,p_wcn_attribute30                =>  p_wcn_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_WV_PRTN_RSN_CTFN_PL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_WV_PRTN_RSN_CTFN_PL
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
  p_wv_prtn_rsn_ctfn_pl_id := l_wv_prtn_rsn_ctfn_pl_id;
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
    ROLLBACK TO create_WV_PRTN_RSN_CTFN_PL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_wv_prtn_rsn_ctfn_pl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_WV_PRTN_RSN_CTFN_PL;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end create_WV_PRTN_RSN_CTFN_PL;
-- ----------------------------------------------------------------------------
-- |------------------------< update_WV_PRTN_RSN_CTFN_PL >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_WV_PRTN_RSN_CTFN_PL
  (p_validate                       in  boolean   default false
  ,p_wv_prtn_rsn_ctfn_pl_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pfd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_lack_ctfn_sspnd_wvr_flag       in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_when_rl               in  number    default hr_api.g_number
  ,p_wv_prtn_ctfn_typ_cd            in  varchar2  default hr_api.g_varchar2
  ,p_wv_prtn_rsn_pl_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_wcn_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_wcn_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_WV_PRTN_RSN_CTFN_PL';
  l_object_version_number ben_wv_prtn_rsn_ctfn_pl_f.object_version_number%TYPE;
  l_effective_start_date ben_wv_prtn_rsn_ctfn_pl_f.effective_start_date%TYPE;
  l_effective_end_date ben_wv_prtn_rsn_ctfn_pl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_WV_PRTN_RSN_CTFN_PL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_WV_PRTN_RSN_CTFN_PL
    --
    ben_WV_PRTN_RSN_CTFN_PL_bk2.update_WV_PRTN_RSN_CTFN_PL_b
      (
       p_wv_prtn_rsn_ctfn_pl_id         =>  p_wv_prtn_rsn_ctfn_pl_id
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_wvr_flag       =>  p_lack_ctfn_sspnd_wvr_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_wv_prtn_ctfn_typ_cd            =>  p_wv_prtn_ctfn_typ_cd
      ,p_wv_prtn_rsn_pl_id              =>  p_wv_prtn_rsn_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_wcn_attribute_category         =>  p_wcn_attribute_category
      ,p_wcn_attribute1                 =>  p_wcn_attribute1
      ,p_wcn_attribute2                 =>  p_wcn_attribute2
      ,p_wcn_attribute3                 =>  p_wcn_attribute3
      ,p_wcn_attribute4                 =>  p_wcn_attribute4
      ,p_wcn_attribute5                 =>  p_wcn_attribute5
      ,p_wcn_attribute6                 =>  p_wcn_attribute6
      ,p_wcn_attribute7                 =>  p_wcn_attribute7
      ,p_wcn_attribute8                 =>  p_wcn_attribute8
      ,p_wcn_attribute9                 =>  p_wcn_attribute9
      ,p_wcn_attribute10                =>  p_wcn_attribute10
      ,p_wcn_attribute11                =>  p_wcn_attribute11
      ,p_wcn_attribute12                =>  p_wcn_attribute12
      ,p_wcn_attribute13                =>  p_wcn_attribute13
      ,p_wcn_attribute14                =>  p_wcn_attribute14
      ,p_wcn_attribute15                =>  p_wcn_attribute15
      ,p_wcn_attribute16                =>  p_wcn_attribute16
      ,p_wcn_attribute17                =>  p_wcn_attribute17
      ,p_wcn_attribute18                =>  p_wcn_attribute18
      ,p_wcn_attribute19                =>  p_wcn_attribute19
      ,p_wcn_attribute20                =>  p_wcn_attribute20
      ,p_wcn_attribute21                =>  p_wcn_attribute21
      ,p_wcn_attribute22                =>  p_wcn_attribute22
      ,p_wcn_attribute23                =>  p_wcn_attribute23
      ,p_wcn_attribute24                =>  p_wcn_attribute24
      ,p_wcn_attribute25                =>  p_wcn_attribute25
      ,p_wcn_attribute26                =>  p_wcn_attribute26
      ,p_wcn_attribute27                =>  p_wcn_attribute27
      ,p_wcn_attribute28                =>  p_wcn_attribute28
      ,p_wcn_attribute29                =>  p_wcn_attribute29
      ,p_wcn_attribute30                =>  p_wcn_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WV_PRTN_RSN_CTFN_PL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_WV_PRTN_RSN_CTFN_PL
    --
  end;
  --
  ben_wcn_upd.upd
    (
     p_wv_prtn_rsn_ctfn_pl_id        => p_wv_prtn_rsn_ctfn_pl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pfd_flag                      => p_pfd_flag
    ,p_lack_ctfn_sspnd_wvr_flag      => p_lack_ctfn_sspnd_wvr_flag
    ,p_rqd_flag                      => p_rqd_flag
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_wv_prtn_ctfn_typ_cd           => p_wv_prtn_ctfn_typ_cd
    ,p_wv_prtn_rsn_pl_id             => p_wv_prtn_rsn_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_wcn_attribute_category        => p_wcn_attribute_category
    ,p_wcn_attribute1                => p_wcn_attribute1
    ,p_wcn_attribute2                => p_wcn_attribute2
    ,p_wcn_attribute3                => p_wcn_attribute3
    ,p_wcn_attribute4                => p_wcn_attribute4
    ,p_wcn_attribute5                => p_wcn_attribute5
    ,p_wcn_attribute6                => p_wcn_attribute6
    ,p_wcn_attribute7                => p_wcn_attribute7
    ,p_wcn_attribute8                => p_wcn_attribute8
    ,p_wcn_attribute9                => p_wcn_attribute9
    ,p_wcn_attribute10               => p_wcn_attribute10
    ,p_wcn_attribute11               => p_wcn_attribute11
    ,p_wcn_attribute12               => p_wcn_attribute12
    ,p_wcn_attribute13               => p_wcn_attribute13
    ,p_wcn_attribute14               => p_wcn_attribute14
    ,p_wcn_attribute15               => p_wcn_attribute15
    ,p_wcn_attribute16               => p_wcn_attribute16
    ,p_wcn_attribute17               => p_wcn_attribute17
    ,p_wcn_attribute18               => p_wcn_attribute18
    ,p_wcn_attribute19               => p_wcn_attribute19
    ,p_wcn_attribute20               => p_wcn_attribute20
    ,p_wcn_attribute21               => p_wcn_attribute21
    ,p_wcn_attribute22               => p_wcn_attribute22
    ,p_wcn_attribute23               => p_wcn_attribute23
    ,p_wcn_attribute24               => p_wcn_attribute24
    ,p_wcn_attribute25               => p_wcn_attribute25
    ,p_wcn_attribute26               => p_wcn_attribute26
    ,p_wcn_attribute27               => p_wcn_attribute27
    ,p_wcn_attribute28               => p_wcn_attribute28
    ,p_wcn_attribute29               => p_wcn_attribute29
    ,p_wcn_attribute30               => p_wcn_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_WV_PRTN_RSN_CTFN_PL
    --
    ben_WV_PRTN_RSN_CTFN_PL_bk2.update_WV_PRTN_RSN_CTFN_PL_a
      (
       p_wv_prtn_rsn_ctfn_pl_id         =>  p_wv_prtn_rsn_ctfn_pl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_wvr_flag       =>  p_lack_ctfn_sspnd_wvr_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_wv_prtn_ctfn_typ_cd            =>  p_wv_prtn_ctfn_typ_cd
      ,p_wv_prtn_rsn_pl_id              =>  p_wv_prtn_rsn_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_wcn_attribute_category         =>  p_wcn_attribute_category
      ,p_wcn_attribute1                 =>  p_wcn_attribute1
      ,p_wcn_attribute2                 =>  p_wcn_attribute2
      ,p_wcn_attribute3                 =>  p_wcn_attribute3
      ,p_wcn_attribute4                 =>  p_wcn_attribute4
      ,p_wcn_attribute5                 =>  p_wcn_attribute5
      ,p_wcn_attribute6                 =>  p_wcn_attribute6
      ,p_wcn_attribute7                 =>  p_wcn_attribute7
      ,p_wcn_attribute8                 =>  p_wcn_attribute8
      ,p_wcn_attribute9                 =>  p_wcn_attribute9
      ,p_wcn_attribute10                =>  p_wcn_attribute10
      ,p_wcn_attribute11                =>  p_wcn_attribute11
      ,p_wcn_attribute12                =>  p_wcn_attribute12
      ,p_wcn_attribute13                =>  p_wcn_attribute13
      ,p_wcn_attribute14                =>  p_wcn_attribute14
      ,p_wcn_attribute15                =>  p_wcn_attribute15
      ,p_wcn_attribute16                =>  p_wcn_attribute16
      ,p_wcn_attribute17                =>  p_wcn_attribute17
      ,p_wcn_attribute18                =>  p_wcn_attribute18
      ,p_wcn_attribute19                =>  p_wcn_attribute19
      ,p_wcn_attribute20                =>  p_wcn_attribute20
      ,p_wcn_attribute21                =>  p_wcn_attribute21
      ,p_wcn_attribute22                =>  p_wcn_attribute22
      ,p_wcn_attribute23                =>  p_wcn_attribute23
      ,p_wcn_attribute24                =>  p_wcn_attribute24
      ,p_wcn_attribute25                =>  p_wcn_attribute25
      ,p_wcn_attribute26                =>  p_wcn_attribute26
      ,p_wcn_attribute27                =>  p_wcn_attribute27
      ,p_wcn_attribute28                =>  p_wcn_attribute28
      ,p_wcn_attribute29                =>  p_wcn_attribute29
      ,p_wcn_attribute30                =>  p_wcn_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WV_PRTN_RSN_CTFN_PL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_WV_PRTN_RSN_CTFN_PL
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
    ROLLBACK TO update_WV_PRTN_RSN_CTFN_PL;
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
    ROLLBACK TO update_WV_PRTN_RSN_CTFN_PL;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end update_WV_PRTN_RSN_CTFN_PL;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WV_PRTN_RSN_CTFN_PL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WV_PRTN_RSN_CTFN_PL
  (p_validate                       in  boolean  default false
  ,p_wv_prtn_rsn_ctfn_pl_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_WV_PRTN_RSN_CTFN_PL';
  l_object_version_number ben_wv_prtn_rsn_ctfn_pl_f.object_version_number%TYPE;
  l_effective_start_date ben_wv_prtn_rsn_ctfn_pl_f.effective_start_date%TYPE;
  l_effective_end_date ben_wv_prtn_rsn_ctfn_pl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_WV_PRTN_RSN_CTFN_PL;
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
    -- Start of API User Hook for the before hook of delete_WV_PRTN_RSN_CTFN_PL
    --
    ben_WV_PRTN_RSN_CTFN_PL_bk3.delete_WV_PRTN_RSN_CTFN_PL_b
      (
       p_wv_prtn_rsn_ctfn_pl_id         =>  p_wv_prtn_rsn_ctfn_pl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WV_PRTN_RSN_CTFN_PL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_WV_PRTN_RSN_CTFN_PL
    --
  end;
  --
  ben_wcn_del.del
    (
     p_wv_prtn_rsn_ctfn_pl_id        => p_wv_prtn_rsn_ctfn_pl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_WV_PRTN_RSN_CTFN_PL
    --
    ben_WV_PRTN_RSN_CTFN_PL_bk3.delete_WV_PRTN_RSN_CTFN_PL_a
      (
       p_wv_prtn_rsn_ctfn_pl_id         =>  p_wv_prtn_rsn_ctfn_pl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WV_PRTN_RSN_CTFN_PL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_WV_PRTN_RSN_CTFN_PL
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
    ROLLBACK TO delete_WV_PRTN_RSN_CTFN_PL;
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
    ROLLBACK TO delete_WV_PRTN_RSN_CTFN_PL;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end delete_WV_PRTN_RSN_CTFN_PL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_wv_prtn_rsn_ctfn_pl_id                   in     number
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
  ben_wcn_shd.lck
    (
      p_wv_prtn_rsn_ctfn_pl_id                 => p_wv_prtn_rsn_ctfn_pl_id
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
end ben_WV_PRTN_RSN_CTFN_PL_api;

/