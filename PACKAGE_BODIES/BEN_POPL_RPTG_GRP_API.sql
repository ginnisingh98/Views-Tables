--------------------------------------------------------
--  DDL for Package Body BEN_POPL_RPTG_GRP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_POPL_RPTG_GRP_API" as
/* $Header: bergrapi.pkb 120.0 2005/05/28 11:39:06 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_POPL_RPTG_GRP_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_POPL_RPTG_GRP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_POPL_RPTG_GRP
  (p_validate                       in  boolean   default false
  ,p_popl_rptg_grp_id               out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_rptg_grp_id                    in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_ordr_num                       in  number    default null          --iRec
  ,p_rgr_attribute_category         in  varchar2  default null
  ,p_rgr_attribute1                 in  varchar2  default null
  ,p_rgr_attribute2                 in  varchar2  default null
  ,p_rgr_attribute3                 in  varchar2  default null
  ,p_rgr_attribute4                 in  varchar2  default null
  ,p_rgr_attribute5                 in  varchar2  default null
  ,p_rgr_attribute6                 in  varchar2  default null
  ,p_rgr_attribute7                 in  varchar2  default null
  ,p_rgr_attribute8                 in  varchar2  default null
  ,p_rgr_attribute9                 in  varchar2  default null
  ,p_rgr_attribute10                in  varchar2  default null
  ,p_rgr_attribute11                in  varchar2  default null
  ,p_rgr_attribute12                in  varchar2  default null
  ,p_rgr_attribute13                in  varchar2  default null
  ,p_rgr_attribute14                in  varchar2  default null
  ,p_rgr_attribute15                in  varchar2  default null
  ,p_rgr_attribute16                in  varchar2  default null
  ,p_rgr_attribute17                in  varchar2  default null
  ,p_rgr_attribute18                in  varchar2  default null
  ,p_rgr_attribute19                in  varchar2  default null
  ,p_rgr_attribute20                in  varchar2  default null
  ,p_rgr_attribute21                in  varchar2  default null
  ,p_rgr_attribute22                in  varchar2  default null
  ,p_rgr_attribute23                in  varchar2  default null
  ,p_rgr_attribute24                in  varchar2  default null
  ,p_rgr_attribute25                in  varchar2  default null
  ,p_rgr_attribute26                in  varchar2  default null
  ,p_rgr_attribute27                in  varchar2  default null
  ,p_rgr_attribute28                in  varchar2  default null
  ,p_rgr_attribute29                in  varchar2  default null
  ,p_rgr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_popl_rptg_grp_id ben_popl_rptg_grp_f.popl_rptg_grp_id%TYPE;
  l_effective_start_date ben_popl_rptg_grp_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_rptg_grp_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_POPL_RPTG_GRP';
  l_object_version_number ben_popl_rptg_grp_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_POPL_RPTG_GRP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_POPL_RPTG_GRP
    --
    ben_POPL_RPTG_GRP_bk1.create_POPL_RPTG_GRP_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ordr_num                       =>  p_ordr_num                 --iRec
      ,p_rgr_attribute_category         =>  p_rgr_attribute_category
      ,p_rgr_attribute1                 =>  p_rgr_attribute1
      ,p_rgr_attribute2                 =>  p_rgr_attribute2
      ,p_rgr_attribute3                 =>  p_rgr_attribute3
      ,p_rgr_attribute4                 =>  p_rgr_attribute4
      ,p_rgr_attribute5                 =>  p_rgr_attribute5
      ,p_rgr_attribute6                 =>  p_rgr_attribute6
      ,p_rgr_attribute7                 =>  p_rgr_attribute7
      ,p_rgr_attribute8                 =>  p_rgr_attribute8
      ,p_rgr_attribute9                 =>  p_rgr_attribute9
      ,p_rgr_attribute10                =>  p_rgr_attribute10
      ,p_rgr_attribute11                =>  p_rgr_attribute11
      ,p_rgr_attribute12                =>  p_rgr_attribute12
      ,p_rgr_attribute13                =>  p_rgr_attribute13
      ,p_rgr_attribute14                =>  p_rgr_attribute14
      ,p_rgr_attribute15                =>  p_rgr_attribute15
      ,p_rgr_attribute16                =>  p_rgr_attribute16
      ,p_rgr_attribute17                =>  p_rgr_attribute17
      ,p_rgr_attribute18                =>  p_rgr_attribute18
      ,p_rgr_attribute19                =>  p_rgr_attribute19
      ,p_rgr_attribute20                =>  p_rgr_attribute20
      ,p_rgr_attribute21                =>  p_rgr_attribute21
      ,p_rgr_attribute22                =>  p_rgr_attribute22
      ,p_rgr_attribute23                =>  p_rgr_attribute23
      ,p_rgr_attribute24                =>  p_rgr_attribute24
      ,p_rgr_attribute25                =>  p_rgr_attribute25
      ,p_rgr_attribute26                =>  p_rgr_attribute26
      ,p_rgr_attribute27                =>  p_rgr_attribute27
      ,p_rgr_attribute28                =>  p_rgr_attribute28
      ,p_rgr_attribute29                =>  p_rgr_attribute29
      ,p_rgr_attribute30                =>  p_rgr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_POPL_RPTG_GRP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_POPL_RPTG_GRP
    --
  end;
  --
  ben_rgr_ins.ins
    (
     p_popl_rptg_grp_id              => l_popl_rptg_grp_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_rptg_grp_id                   => p_rptg_grp_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_ordr_num                      => p_ordr_num                     --iRec
    ,p_rgr_attribute_category        => p_rgr_attribute_category
    ,p_rgr_attribute1                => p_rgr_attribute1
    ,p_rgr_attribute2                => p_rgr_attribute2
    ,p_rgr_attribute3                => p_rgr_attribute3
    ,p_rgr_attribute4                => p_rgr_attribute4
    ,p_rgr_attribute5                => p_rgr_attribute5
    ,p_rgr_attribute6                => p_rgr_attribute6
    ,p_rgr_attribute7                => p_rgr_attribute7
    ,p_rgr_attribute8                => p_rgr_attribute8
    ,p_rgr_attribute9                => p_rgr_attribute9
    ,p_rgr_attribute10               => p_rgr_attribute10
    ,p_rgr_attribute11               => p_rgr_attribute11
    ,p_rgr_attribute12               => p_rgr_attribute12
    ,p_rgr_attribute13               => p_rgr_attribute13
    ,p_rgr_attribute14               => p_rgr_attribute14
    ,p_rgr_attribute15               => p_rgr_attribute15
    ,p_rgr_attribute16               => p_rgr_attribute16
    ,p_rgr_attribute17               => p_rgr_attribute17
    ,p_rgr_attribute18               => p_rgr_attribute18
    ,p_rgr_attribute19               => p_rgr_attribute19
    ,p_rgr_attribute20               => p_rgr_attribute20
    ,p_rgr_attribute21               => p_rgr_attribute21
    ,p_rgr_attribute22               => p_rgr_attribute22
    ,p_rgr_attribute23               => p_rgr_attribute23
    ,p_rgr_attribute24               => p_rgr_attribute24
    ,p_rgr_attribute25               => p_rgr_attribute25
    ,p_rgr_attribute26               => p_rgr_attribute26
    ,p_rgr_attribute27               => p_rgr_attribute27
    ,p_rgr_attribute28               => p_rgr_attribute28
    ,p_rgr_attribute29               => p_rgr_attribute29
    ,p_rgr_attribute30               => p_rgr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_POPL_RPTG_GRP
    --
    ben_POPL_RPTG_GRP_bk1.create_POPL_RPTG_GRP_a
      (
       p_popl_rptg_grp_id               =>  l_popl_rptg_grp_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ordr_num                       =>  p_ordr_num                   --iRec
      ,p_rgr_attribute_category         =>  p_rgr_attribute_category
      ,p_rgr_attribute1                 =>  p_rgr_attribute1
      ,p_rgr_attribute2                 =>  p_rgr_attribute2
      ,p_rgr_attribute3                 =>  p_rgr_attribute3
      ,p_rgr_attribute4                 =>  p_rgr_attribute4
      ,p_rgr_attribute5                 =>  p_rgr_attribute5
      ,p_rgr_attribute6                 =>  p_rgr_attribute6
      ,p_rgr_attribute7                 =>  p_rgr_attribute7
      ,p_rgr_attribute8                 =>  p_rgr_attribute8
      ,p_rgr_attribute9                 =>  p_rgr_attribute9
      ,p_rgr_attribute10                =>  p_rgr_attribute10
      ,p_rgr_attribute11                =>  p_rgr_attribute11
      ,p_rgr_attribute12                =>  p_rgr_attribute12
      ,p_rgr_attribute13                =>  p_rgr_attribute13
      ,p_rgr_attribute14                =>  p_rgr_attribute14
      ,p_rgr_attribute15                =>  p_rgr_attribute15
      ,p_rgr_attribute16                =>  p_rgr_attribute16
      ,p_rgr_attribute17                =>  p_rgr_attribute17
      ,p_rgr_attribute18                =>  p_rgr_attribute18
      ,p_rgr_attribute19                =>  p_rgr_attribute19
      ,p_rgr_attribute20                =>  p_rgr_attribute20
      ,p_rgr_attribute21                =>  p_rgr_attribute21
      ,p_rgr_attribute22                =>  p_rgr_attribute22
      ,p_rgr_attribute23                =>  p_rgr_attribute23
      ,p_rgr_attribute24                =>  p_rgr_attribute24
      ,p_rgr_attribute25                =>  p_rgr_attribute25
      ,p_rgr_attribute26                =>  p_rgr_attribute26
      ,p_rgr_attribute27                =>  p_rgr_attribute27
      ,p_rgr_attribute28                =>  p_rgr_attribute28
      ,p_rgr_attribute29                =>  p_rgr_attribute29
      ,p_rgr_attribute30                =>  p_rgr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_POPL_RPTG_GRP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_POPL_RPTG_GRP
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
  p_popl_rptg_grp_id := l_popl_rptg_grp_id;
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
    ROLLBACK TO create_POPL_RPTG_GRP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_popl_rptg_grp_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_POPL_RPTG_GRP;
    p_popl_rptg_grp_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_POPL_RPTG_GRP;
-- ----------------------------------------------------------------------------
-- |------------------------< update_POPL_RPTG_GRP >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_POPL_RPTG_GRP
  (p_validate                       in  boolean   default false
  ,p_popl_rptg_grp_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rptg_grp_id                    in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number          --iRec
  ,p_rgr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_rgr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POPL_RPTG_GRP';
  l_object_version_number ben_popl_rptg_grp_f.object_version_number%TYPE;
  l_effective_start_date ben_popl_rptg_grp_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_rptg_grp_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_POPL_RPTG_GRP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_POPL_RPTG_GRP
    --
    ben_POPL_RPTG_GRP_bk2.update_POPL_RPTG_GRP_b
      (
       p_popl_rptg_grp_id               =>  p_popl_rptg_grp_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ordr_num                       =>  p_ordr_num                     --iRec
      ,p_rgr_attribute_category         =>  p_rgr_attribute_category
      ,p_rgr_attribute1                 =>  p_rgr_attribute1
      ,p_rgr_attribute2                 =>  p_rgr_attribute2
      ,p_rgr_attribute3                 =>  p_rgr_attribute3
      ,p_rgr_attribute4                 =>  p_rgr_attribute4
      ,p_rgr_attribute5                 =>  p_rgr_attribute5
      ,p_rgr_attribute6                 =>  p_rgr_attribute6
      ,p_rgr_attribute7                 =>  p_rgr_attribute7
      ,p_rgr_attribute8                 =>  p_rgr_attribute8
      ,p_rgr_attribute9                 =>  p_rgr_attribute9
      ,p_rgr_attribute10                =>  p_rgr_attribute10
      ,p_rgr_attribute11                =>  p_rgr_attribute11
      ,p_rgr_attribute12                =>  p_rgr_attribute12
      ,p_rgr_attribute13                =>  p_rgr_attribute13
      ,p_rgr_attribute14                =>  p_rgr_attribute14
      ,p_rgr_attribute15                =>  p_rgr_attribute15
      ,p_rgr_attribute16                =>  p_rgr_attribute16
      ,p_rgr_attribute17                =>  p_rgr_attribute17
      ,p_rgr_attribute18                =>  p_rgr_attribute18
      ,p_rgr_attribute19                =>  p_rgr_attribute19
      ,p_rgr_attribute20                =>  p_rgr_attribute20
      ,p_rgr_attribute21                =>  p_rgr_attribute21
      ,p_rgr_attribute22                =>  p_rgr_attribute22
      ,p_rgr_attribute23                =>  p_rgr_attribute23
      ,p_rgr_attribute24                =>  p_rgr_attribute24
      ,p_rgr_attribute25                =>  p_rgr_attribute25
      ,p_rgr_attribute26                =>  p_rgr_attribute26
      ,p_rgr_attribute27                =>  p_rgr_attribute27
      ,p_rgr_attribute28                =>  p_rgr_attribute28
      ,p_rgr_attribute29                =>  p_rgr_attribute29
      ,p_rgr_attribute30                =>  p_rgr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POPL_RPTG_GRP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_POPL_RPTG_GRP
    --
  end;
  --
  ben_rgr_upd.upd
    (
     p_popl_rptg_grp_id              => p_popl_rptg_grp_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_rptg_grp_id                   => p_rptg_grp_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_ordr_num                      => p_ordr_num                     --iRec
    ,p_rgr_attribute_category        => p_rgr_attribute_category
    ,p_rgr_attribute1                => p_rgr_attribute1
    ,p_rgr_attribute2                => p_rgr_attribute2
    ,p_rgr_attribute3                => p_rgr_attribute3
    ,p_rgr_attribute4                => p_rgr_attribute4
    ,p_rgr_attribute5                => p_rgr_attribute5
    ,p_rgr_attribute6                => p_rgr_attribute6
    ,p_rgr_attribute7                => p_rgr_attribute7
    ,p_rgr_attribute8                => p_rgr_attribute8
    ,p_rgr_attribute9                => p_rgr_attribute9
    ,p_rgr_attribute10               => p_rgr_attribute10
    ,p_rgr_attribute11               => p_rgr_attribute11
    ,p_rgr_attribute12               => p_rgr_attribute12
    ,p_rgr_attribute13               => p_rgr_attribute13
    ,p_rgr_attribute14               => p_rgr_attribute14
    ,p_rgr_attribute15               => p_rgr_attribute15
    ,p_rgr_attribute16               => p_rgr_attribute16
    ,p_rgr_attribute17               => p_rgr_attribute17
    ,p_rgr_attribute18               => p_rgr_attribute18
    ,p_rgr_attribute19               => p_rgr_attribute19
    ,p_rgr_attribute20               => p_rgr_attribute20
    ,p_rgr_attribute21               => p_rgr_attribute21
    ,p_rgr_attribute22               => p_rgr_attribute22
    ,p_rgr_attribute23               => p_rgr_attribute23
    ,p_rgr_attribute24               => p_rgr_attribute24
    ,p_rgr_attribute25               => p_rgr_attribute25
    ,p_rgr_attribute26               => p_rgr_attribute26
    ,p_rgr_attribute27               => p_rgr_attribute27
    ,p_rgr_attribute28               => p_rgr_attribute28
    ,p_rgr_attribute29               => p_rgr_attribute29
    ,p_rgr_attribute30               => p_rgr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_POPL_RPTG_GRP
    --
    ben_POPL_RPTG_GRP_bk2.update_POPL_RPTG_GRP_a
      (
       p_popl_rptg_grp_id               =>  p_popl_rptg_grp_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ordr_num                       =>  p_ordr_num                      --iRec
      ,p_rgr_attribute_category         =>  p_rgr_attribute_category
      ,p_rgr_attribute1                 =>  p_rgr_attribute1
      ,p_rgr_attribute2                 =>  p_rgr_attribute2
      ,p_rgr_attribute3                 =>  p_rgr_attribute3
      ,p_rgr_attribute4                 =>  p_rgr_attribute4
      ,p_rgr_attribute5                 =>  p_rgr_attribute5
      ,p_rgr_attribute6                 =>  p_rgr_attribute6
      ,p_rgr_attribute7                 =>  p_rgr_attribute7
      ,p_rgr_attribute8                 =>  p_rgr_attribute8
      ,p_rgr_attribute9                 =>  p_rgr_attribute9
      ,p_rgr_attribute10                =>  p_rgr_attribute10
      ,p_rgr_attribute11                =>  p_rgr_attribute11
      ,p_rgr_attribute12                =>  p_rgr_attribute12
      ,p_rgr_attribute13                =>  p_rgr_attribute13
      ,p_rgr_attribute14                =>  p_rgr_attribute14
      ,p_rgr_attribute15                =>  p_rgr_attribute15
      ,p_rgr_attribute16                =>  p_rgr_attribute16
      ,p_rgr_attribute17                =>  p_rgr_attribute17
      ,p_rgr_attribute18                =>  p_rgr_attribute18
      ,p_rgr_attribute19                =>  p_rgr_attribute19
      ,p_rgr_attribute20                =>  p_rgr_attribute20
      ,p_rgr_attribute21                =>  p_rgr_attribute21
      ,p_rgr_attribute22                =>  p_rgr_attribute22
      ,p_rgr_attribute23                =>  p_rgr_attribute23
      ,p_rgr_attribute24                =>  p_rgr_attribute24
      ,p_rgr_attribute25                =>  p_rgr_attribute25
      ,p_rgr_attribute26                =>  p_rgr_attribute26
      ,p_rgr_attribute27                =>  p_rgr_attribute27
      ,p_rgr_attribute28                =>  p_rgr_attribute28
      ,p_rgr_attribute29                =>  p_rgr_attribute29
      ,p_rgr_attribute30                =>  p_rgr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POPL_RPTG_GRP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_POPL_RPTG_GRP
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
    ROLLBACK TO update_POPL_RPTG_GRP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_POPL_RPTG_GRP;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_POPL_RPTG_GRP;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_POPL_RPTG_GRP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_RPTG_GRP
  (p_validate                       in  boolean  default false
  ,p_popl_rptg_grp_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POPL_RPTG_GRP';
  l_object_version_number ben_popl_rptg_grp_f.object_version_number%TYPE;
  l_effective_start_date ben_popl_rptg_grp_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_rptg_grp_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_POPL_RPTG_GRP;
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
    -- Start of API User Hook for the before hook of delete_POPL_RPTG_GRP
    --
    ben_POPL_RPTG_GRP_bk3.delete_POPL_RPTG_GRP_b
      (
       p_popl_rptg_grp_id               =>  p_popl_rptg_grp_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POPL_RPTG_GRP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_POPL_RPTG_GRP
    --
  end;
  --
  ben_rgr_del.del
    (
     p_popl_rptg_grp_id              => p_popl_rptg_grp_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_POPL_RPTG_GRP
    --
    ben_POPL_RPTG_GRP_bk3.delete_POPL_RPTG_GRP_a
      (
       p_popl_rptg_grp_id               =>  p_popl_rptg_grp_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POPL_RPTG_GRP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_POPL_RPTG_GRP
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
    ROLLBACK TO delete_POPL_RPTG_GRP;
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
    ROLLBACK TO delete_POPL_RPTG_GRP;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_POPL_RPTG_GRP;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_popl_rptg_grp_id                   in     number
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
  ben_rgr_shd.lck
    (
      p_popl_rptg_grp_id                 => p_popl_rptg_grp_id
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
end ben_POPL_RPTG_GRP_api;

/
