--------------------------------------------------------
--  DDL for Package Body BEN_CNTNU_PRTN_CTFN_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CNTNU_PRTN_CTFN_TYP_API" as
/* $Header: becpcapi.pkb 120.0 2005/05/28 01:10:44 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_CNTNU_PRTN_CTFN_TYP_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_CNTNU_PRTN_CTFN_TYP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_CNTNU_PRTN_CTFN_TYP
  (p_validate                       in  boolean   default false
  ,p_cntnu_prtn_ctfn_typ_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_cntng_prtn_elig_prfl_id        in  number    default null
  ,p_pfd_flag                       in  varchar2  default null
  ,p_lack_ctfn_sspnd_elig_flag      in  varchar2  default null
  ,p_ctfn_rqd_when_rl               in  number    default null
  ,p_prtn_ctfn_typ_cd               in  varchar2  default null
  ,p_cpc_attribute_category         in  varchar2  default null
  ,p_cpc_attribute1                 in  varchar2  default null
  ,p_cpc_attribute2                 in  varchar2  default null
  ,p_cpc_attribute3                 in  varchar2  default null
  ,p_cpc_attribute4                 in  varchar2  default null
  ,p_cpc_attribute5                 in  varchar2  default null
  ,p_cpc_attribute6                 in  varchar2  default null
  ,p_cpc_attribute7                 in  varchar2  default null
  ,p_cpc_attribute8                 in  varchar2  default null
  ,p_cpc_attribute9                 in  varchar2  default null
  ,p_cpc_attribute10                in  varchar2  default null
  ,p_cpc_attribute11                in  varchar2  default null
  ,p_cpc_attribute12                in  varchar2  default null
  ,p_cpc_attribute13                in  varchar2  default null
  ,p_cpc_attribute14                in  varchar2  default null
  ,p_cpc_attribute15                in  varchar2  default null
  ,p_cpc_attribute16                in  varchar2  default null
  ,p_cpc_attribute17                in  varchar2  default null
  ,p_cpc_attribute18                in  varchar2  default null
  ,p_cpc_attribute19                in  varchar2  default null
  ,p_cpc_attribute20                in  varchar2  default null
  ,p_cpc_attribute21                in  varchar2  default null
  ,p_cpc_attribute22                in  varchar2  default null
  ,p_cpc_attribute23                in  varchar2  default null
  ,p_cpc_attribute24                in  varchar2  default null
  ,p_cpc_attribute25                in  varchar2  default null
  ,p_cpc_attribute26                in  varchar2  default null
  ,p_cpc_attribute27                in  varchar2  default null
  ,p_cpc_attribute28                in  varchar2  default null
  ,p_cpc_attribute29                in  varchar2  default null
  ,p_cpc_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cntnu_prtn_ctfn_typ_id ben_cntnu_prtn_ctfn_typ_f.cntnu_prtn_ctfn_typ_id%TYPE;
  l_effective_start_date ben_cntnu_prtn_ctfn_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_cntnu_prtn_ctfn_typ_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_CNTNU_PRTN_CTFN_TYP';
  l_object_version_number ben_cntnu_prtn_ctfn_typ_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_CNTNU_PRTN_CTFN_TYP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_CNTNU_PRTN_CTFN_TYP
    --
    ben_CNTNU_PRTN_CTFN_TYP_bk1.create_CNTNU_PRTN_CTFN_TYP_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_cntng_prtn_elig_prfl_id        =>  p_cntng_prtn_elig_prfl_id
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_elig_flag      =>  p_lack_ctfn_sspnd_elig_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_prtn_ctfn_typ_cd               =>  p_prtn_ctfn_typ_cd
      ,p_cpc_attribute_category         =>  p_cpc_attribute_category
      ,p_cpc_attribute1                 =>  p_cpc_attribute1
      ,p_cpc_attribute2                 =>  p_cpc_attribute2
      ,p_cpc_attribute3                 =>  p_cpc_attribute3
      ,p_cpc_attribute4                 =>  p_cpc_attribute4
      ,p_cpc_attribute5                 =>  p_cpc_attribute5
      ,p_cpc_attribute6                 =>  p_cpc_attribute6
      ,p_cpc_attribute7                 =>  p_cpc_attribute7
      ,p_cpc_attribute8                 =>  p_cpc_attribute8
      ,p_cpc_attribute9                 =>  p_cpc_attribute9
      ,p_cpc_attribute10                =>  p_cpc_attribute10
      ,p_cpc_attribute11                =>  p_cpc_attribute11
      ,p_cpc_attribute12                =>  p_cpc_attribute12
      ,p_cpc_attribute13                =>  p_cpc_attribute13
      ,p_cpc_attribute14                =>  p_cpc_attribute14
      ,p_cpc_attribute15                =>  p_cpc_attribute15
      ,p_cpc_attribute16                =>  p_cpc_attribute16
      ,p_cpc_attribute17                =>  p_cpc_attribute17
      ,p_cpc_attribute18                =>  p_cpc_attribute18
      ,p_cpc_attribute19                =>  p_cpc_attribute19
      ,p_cpc_attribute20                =>  p_cpc_attribute20
      ,p_cpc_attribute21                =>  p_cpc_attribute21
      ,p_cpc_attribute22                =>  p_cpc_attribute22
      ,p_cpc_attribute23                =>  p_cpc_attribute23
      ,p_cpc_attribute24                =>  p_cpc_attribute24
      ,p_cpc_attribute25                =>  p_cpc_attribute25
      ,p_cpc_attribute26                =>  p_cpc_attribute26
      ,p_cpc_attribute27                =>  p_cpc_attribute27
      ,p_cpc_attribute28                =>  p_cpc_attribute28
      ,p_cpc_attribute29                =>  p_cpc_attribute29
      ,p_cpc_attribute30                =>  p_cpc_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CNTNU_PRTN_CTFN_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_CNTNU_PRTN_CTFN_TYP
    --
  end;
  --
  ben_cpc_ins.ins
    (
     p_cntnu_prtn_ctfn_typ_id        => l_cntnu_prtn_ctfn_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_cntng_prtn_elig_prfl_id       => p_cntng_prtn_elig_prfl_id
    ,p_pfd_flag                      => p_pfd_flag
    ,p_lack_ctfn_sspnd_elig_flag     => p_lack_ctfn_sspnd_elig_flag
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_prtn_ctfn_typ_cd              => p_prtn_ctfn_typ_cd
    ,p_cpc_attribute_category        => p_cpc_attribute_category
    ,p_cpc_attribute1                => p_cpc_attribute1
    ,p_cpc_attribute2                => p_cpc_attribute2
    ,p_cpc_attribute3                => p_cpc_attribute3
    ,p_cpc_attribute4                => p_cpc_attribute4
    ,p_cpc_attribute5                => p_cpc_attribute5
    ,p_cpc_attribute6                => p_cpc_attribute6
    ,p_cpc_attribute7                => p_cpc_attribute7
    ,p_cpc_attribute8                => p_cpc_attribute8
    ,p_cpc_attribute9                => p_cpc_attribute9
    ,p_cpc_attribute10               => p_cpc_attribute10
    ,p_cpc_attribute11               => p_cpc_attribute11
    ,p_cpc_attribute12               => p_cpc_attribute12
    ,p_cpc_attribute13               => p_cpc_attribute13
    ,p_cpc_attribute14               => p_cpc_attribute14
    ,p_cpc_attribute15               => p_cpc_attribute15
    ,p_cpc_attribute16               => p_cpc_attribute16
    ,p_cpc_attribute17               => p_cpc_attribute17
    ,p_cpc_attribute18               => p_cpc_attribute18
    ,p_cpc_attribute19               => p_cpc_attribute19
    ,p_cpc_attribute20               => p_cpc_attribute20
    ,p_cpc_attribute21               => p_cpc_attribute21
    ,p_cpc_attribute22               => p_cpc_attribute22
    ,p_cpc_attribute23               => p_cpc_attribute23
    ,p_cpc_attribute24               => p_cpc_attribute24
    ,p_cpc_attribute25               => p_cpc_attribute25
    ,p_cpc_attribute26               => p_cpc_attribute26
    ,p_cpc_attribute27               => p_cpc_attribute27
    ,p_cpc_attribute28               => p_cpc_attribute28
    ,p_cpc_attribute29               => p_cpc_attribute29
    ,p_cpc_attribute30               => p_cpc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_CNTNU_PRTN_CTFN_TYP
    --
    ben_CNTNU_PRTN_CTFN_TYP_bk1.create_CNTNU_PRTN_CTFN_TYP_a
      (
       p_cntnu_prtn_ctfn_typ_id         =>  l_cntnu_prtn_ctfn_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_cntng_prtn_elig_prfl_id        =>  p_cntng_prtn_elig_prfl_id
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_elig_flag      =>  p_lack_ctfn_sspnd_elig_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_prtn_ctfn_typ_cd               =>  p_prtn_ctfn_typ_cd
      ,p_cpc_attribute_category         =>  p_cpc_attribute_category
      ,p_cpc_attribute1                 =>  p_cpc_attribute1
      ,p_cpc_attribute2                 =>  p_cpc_attribute2
      ,p_cpc_attribute3                 =>  p_cpc_attribute3
      ,p_cpc_attribute4                 =>  p_cpc_attribute4
      ,p_cpc_attribute5                 =>  p_cpc_attribute5
      ,p_cpc_attribute6                 =>  p_cpc_attribute6
      ,p_cpc_attribute7                 =>  p_cpc_attribute7
      ,p_cpc_attribute8                 =>  p_cpc_attribute8
      ,p_cpc_attribute9                 =>  p_cpc_attribute9
      ,p_cpc_attribute10                =>  p_cpc_attribute10
      ,p_cpc_attribute11                =>  p_cpc_attribute11
      ,p_cpc_attribute12                =>  p_cpc_attribute12
      ,p_cpc_attribute13                =>  p_cpc_attribute13
      ,p_cpc_attribute14                =>  p_cpc_attribute14
      ,p_cpc_attribute15                =>  p_cpc_attribute15
      ,p_cpc_attribute16                =>  p_cpc_attribute16
      ,p_cpc_attribute17                =>  p_cpc_attribute17
      ,p_cpc_attribute18                =>  p_cpc_attribute18
      ,p_cpc_attribute19                =>  p_cpc_attribute19
      ,p_cpc_attribute20                =>  p_cpc_attribute20
      ,p_cpc_attribute21                =>  p_cpc_attribute21
      ,p_cpc_attribute22                =>  p_cpc_attribute22
      ,p_cpc_attribute23                =>  p_cpc_attribute23
      ,p_cpc_attribute24                =>  p_cpc_attribute24
      ,p_cpc_attribute25                =>  p_cpc_attribute25
      ,p_cpc_attribute26                =>  p_cpc_attribute26
      ,p_cpc_attribute27                =>  p_cpc_attribute27
      ,p_cpc_attribute28                =>  p_cpc_attribute28
      ,p_cpc_attribute29                =>  p_cpc_attribute29
      ,p_cpc_attribute30                =>  p_cpc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CNTNU_PRTN_CTFN_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_CNTNU_PRTN_CTFN_TYP
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
  p_cntnu_prtn_ctfn_typ_id := l_cntnu_prtn_ctfn_typ_id;
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
    ROLLBACK TO create_CNTNU_PRTN_CTFN_TYP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cntnu_prtn_ctfn_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_CNTNU_PRTN_CTFN_TYP;
    /* Inserted for nocopy changes */
    p_cntnu_prtn_ctfn_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_CNTNU_PRTN_CTFN_TYP;
-- ----------------------------------------------------------------------------
-- |------------------------< update_CNTNU_PRTN_CTFN_TYP >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_CNTNU_PRTN_CTFN_TYP
  (p_validate                       in  boolean   default false
  ,p_cntnu_prtn_ctfn_typ_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cntng_prtn_elig_prfl_id        in  number    default hr_api.g_number
  ,p_pfd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_lack_ctfn_sspnd_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_when_rl               in  number    default hr_api.g_number
  ,p_prtn_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cpc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CNTNU_PRTN_CTFN_TYP';
  l_object_version_number ben_cntnu_prtn_ctfn_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_cntnu_prtn_ctfn_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_cntnu_prtn_ctfn_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_CNTNU_PRTN_CTFN_TYP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_CNTNU_PRTN_CTFN_TYP
    --
    ben_CNTNU_PRTN_CTFN_TYP_bk2.update_CNTNU_PRTN_CTFN_TYP_b
      (
       p_cntnu_prtn_ctfn_typ_id         =>  p_cntnu_prtn_ctfn_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_cntng_prtn_elig_prfl_id        =>  p_cntng_prtn_elig_prfl_id
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_elig_flag      =>  p_lack_ctfn_sspnd_elig_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_prtn_ctfn_typ_cd               =>  p_prtn_ctfn_typ_cd
      ,p_cpc_attribute_category         =>  p_cpc_attribute_category
      ,p_cpc_attribute1                 =>  p_cpc_attribute1
      ,p_cpc_attribute2                 =>  p_cpc_attribute2
      ,p_cpc_attribute3                 =>  p_cpc_attribute3
      ,p_cpc_attribute4                 =>  p_cpc_attribute4
      ,p_cpc_attribute5                 =>  p_cpc_attribute5
      ,p_cpc_attribute6                 =>  p_cpc_attribute6
      ,p_cpc_attribute7                 =>  p_cpc_attribute7
      ,p_cpc_attribute8                 =>  p_cpc_attribute8
      ,p_cpc_attribute9                 =>  p_cpc_attribute9
      ,p_cpc_attribute10                =>  p_cpc_attribute10
      ,p_cpc_attribute11                =>  p_cpc_attribute11
      ,p_cpc_attribute12                =>  p_cpc_attribute12
      ,p_cpc_attribute13                =>  p_cpc_attribute13
      ,p_cpc_attribute14                =>  p_cpc_attribute14
      ,p_cpc_attribute15                =>  p_cpc_attribute15
      ,p_cpc_attribute16                =>  p_cpc_attribute16
      ,p_cpc_attribute17                =>  p_cpc_attribute17
      ,p_cpc_attribute18                =>  p_cpc_attribute18
      ,p_cpc_attribute19                =>  p_cpc_attribute19
      ,p_cpc_attribute20                =>  p_cpc_attribute20
      ,p_cpc_attribute21                =>  p_cpc_attribute21
      ,p_cpc_attribute22                =>  p_cpc_attribute22
      ,p_cpc_attribute23                =>  p_cpc_attribute23
      ,p_cpc_attribute24                =>  p_cpc_attribute24
      ,p_cpc_attribute25                =>  p_cpc_attribute25
      ,p_cpc_attribute26                =>  p_cpc_attribute26
      ,p_cpc_attribute27                =>  p_cpc_attribute27
      ,p_cpc_attribute28                =>  p_cpc_attribute28
      ,p_cpc_attribute29                =>  p_cpc_attribute29
      ,p_cpc_attribute30                =>  p_cpc_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CNTNU_PRTN_CTFN_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_CNTNU_PRTN_CTFN_TYP
    --
  end;
  --
  ben_cpc_upd.upd
    (
     p_cntnu_prtn_ctfn_typ_id        => p_cntnu_prtn_ctfn_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_cntng_prtn_elig_prfl_id       => p_cntng_prtn_elig_prfl_id
    ,p_pfd_flag                      => p_pfd_flag
    ,p_lack_ctfn_sspnd_elig_flag     => p_lack_ctfn_sspnd_elig_flag
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_prtn_ctfn_typ_cd              => p_prtn_ctfn_typ_cd
    ,p_cpc_attribute_category        => p_cpc_attribute_category
    ,p_cpc_attribute1                => p_cpc_attribute1
    ,p_cpc_attribute2                => p_cpc_attribute2
    ,p_cpc_attribute3                => p_cpc_attribute3
    ,p_cpc_attribute4                => p_cpc_attribute4
    ,p_cpc_attribute5                => p_cpc_attribute5
    ,p_cpc_attribute6                => p_cpc_attribute6
    ,p_cpc_attribute7                => p_cpc_attribute7
    ,p_cpc_attribute8                => p_cpc_attribute8
    ,p_cpc_attribute9                => p_cpc_attribute9
    ,p_cpc_attribute10               => p_cpc_attribute10
    ,p_cpc_attribute11               => p_cpc_attribute11
    ,p_cpc_attribute12               => p_cpc_attribute12
    ,p_cpc_attribute13               => p_cpc_attribute13
    ,p_cpc_attribute14               => p_cpc_attribute14
    ,p_cpc_attribute15               => p_cpc_attribute15
    ,p_cpc_attribute16               => p_cpc_attribute16
    ,p_cpc_attribute17               => p_cpc_attribute17
    ,p_cpc_attribute18               => p_cpc_attribute18
    ,p_cpc_attribute19               => p_cpc_attribute19
    ,p_cpc_attribute20               => p_cpc_attribute20
    ,p_cpc_attribute21               => p_cpc_attribute21
    ,p_cpc_attribute22               => p_cpc_attribute22
    ,p_cpc_attribute23               => p_cpc_attribute23
    ,p_cpc_attribute24               => p_cpc_attribute24
    ,p_cpc_attribute25               => p_cpc_attribute25
    ,p_cpc_attribute26               => p_cpc_attribute26
    ,p_cpc_attribute27               => p_cpc_attribute27
    ,p_cpc_attribute28               => p_cpc_attribute28
    ,p_cpc_attribute29               => p_cpc_attribute29
    ,p_cpc_attribute30               => p_cpc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_CNTNU_PRTN_CTFN_TYP
    --
    ben_CNTNU_PRTN_CTFN_TYP_bk2.update_CNTNU_PRTN_CTFN_TYP_a
      (
       p_cntnu_prtn_ctfn_typ_id         =>  p_cntnu_prtn_ctfn_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_cntng_prtn_elig_prfl_id        =>  p_cntng_prtn_elig_prfl_id
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_lack_ctfn_sspnd_elig_flag      =>  p_lack_ctfn_sspnd_elig_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_prtn_ctfn_typ_cd               =>  p_prtn_ctfn_typ_cd
      ,p_cpc_attribute_category         =>  p_cpc_attribute_category
      ,p_cpc_attribute1                 =>  p_cpc_attribute1
      ,p_cpc_attribute2                 =>  p_cpc_attribute2
      ,p_cpc_attribute3                 =>  p_cpc_attribute3
      ,p_cpc_attribute4                 =>  p_cpc_attribute4
      ,p_cpc_attribute5                 =>  p_cpc_attribute5
      ,p_cpc_attribute6                 =>  p_cpc_attribute6
      ,p_cpc_attribute7                 =>  p_cpc_attribute7
      ,p_cpc_attribute8                 =>  p_cpc_attribute8
      ,p_cpc_attribute9                 =>  p_cpc_attribute9
      ,p_cpc_attribute10                =>  p_cpc_attribute10
      ,p_cpc_attribute11                =>  p_cpc_attribute11
      ,p_cpc_attribute12                =>  p_cpc_attribute12
      ,p_cpc_attribute13                =>  p_cpc_attribute13
      ,p_cpc_attribute14                =>  p_cpc_attribute14
      ,p_cpc_attribute15                =>  p_cpc_attribute15
      ,p_cpc_attribute16                =>  p_cpc_attribute16
      ,p_cpc_attribute17                =>  p_cpc_attribute17
      ,p_cpc_attribute18                =>  p_cpc_attribute18
      ,p_cpc_attribute19                =>  p_cpc_attribute19
      ,p_cpc_attribute20                =>  p_cpc_attribute20
      ,p_cpc_attribute21                =>  p_cpc_attribute21
      ,p_cpc_attribute22                =>  p_cpc_attribute22
      ,p_cpc_attribute23                =>  p_cpc_attribute23
      ,p_cpc_attribute24                =>  p_cpc_attribute24
      ,p_cpc_attribute25                =>  p_cpc_attribute25
      ,p_cpc_attribute26                =>  p_cpc_attribute26
      ,p_cpc_attribute27                =>  p_cpc_attribute27
      ,p_cpc_attribute28                =>  p_cpc_attribute28
      ,p_cpc_attribute29                =>  p_cpc_attribute29
      ,p_cpc_attribute30                =>  p_cpc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CNTNU_PRTN_CTFN_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_CNTNU_PRTN_CTFN_TYP
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
    ROLLBACK TO update_CNTNU_PRTN_CTFN_TYP;
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
    ROLLBACK TO update_CNTNU_PRTN_CTFN_TYP;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_CNTNU_PRTN_CTFN_TYP;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CNTNU_PRTN_CTFN_TYP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CNTNU_PRTN_CTFN_TYP
  (p_validate                       in  boolean  default false
  ,p_cntnu_prtn_ctfn_typ_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CNTNU_PRTN_CTFN_TYP';
  l_object_version_number ben_cntnu_prtn_ctfn_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_cntnu_prtn_ctfn_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_cntnu_prtn_ctfn_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_CNTNU_PRTN_CTFN_TYP;
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
    -- Start of API User Hook for the before hook of delete_CNTNU_PRTN_CTFN_TYP
    --
    ben_CNTNU_PRTN_CTFN_TYP_bk3.delete_CNTNU_PRTN_CTFN_TYP_b
      (
       p_cntnu_prtn_ctfn_typ_id         =>  p_cntnu_prtn_ctfn_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CNTNU_PRTN_CTFN_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_CNTNU_PRTN_CTFN_TYP
    --
  end;
  --
  ben_cpc_del.del
    (
     p_cntnu_prtn_ctfn_typ_id        => p_cntnu_prtn_ctfn_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_CNTNU_PRTN_CTFN_TYP
    --
    ben_CNTNU_PRTN_CTFN_TYP_bk3.delete_CNTNU_PRTN_CTFN_TYP_a
      (
       p_cntnu_prtn_ctfn_typ_id         =>  p_cntnu_prtn_ctfn_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CNTNU_PRTN_CTFN_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_CNTNU_PRTN_CTFN_TYP
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
    ROLLBACK TO delete_CNTNU_PRTN_CTFN_TYP;
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
    ROLLBACK TO delete_CNTNU_PRTN_CTFN_TYP;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_CNTNU_PRTN_CTFN_TYP;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cntnu_prtn_ctfn_typ_id                   in     number
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
  ben_cpc_shd.lck
    (
      p_cntnu_prtn_ctfn_typ_id                 => p_cntnu_prtn_ctfn_typ_id
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
end ben_CNTNU_PRTN_CTFN_TYP_api;

/
