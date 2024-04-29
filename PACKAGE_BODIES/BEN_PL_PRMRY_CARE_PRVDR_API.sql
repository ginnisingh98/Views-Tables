--------------------------------------------------------
--  DDL for Package Body BEN_PL_PRMRY_CARE_PRVDR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PL_PRMRY_CARE_PRVDR_API" as
/* $Header: bepcpapi.pkb 115.3 2002/12/16 11:58:50 vsethi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_pl_prmry_care_prvdr_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pl_prmry_care_prvdr >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pl_prmry_care_prvdr
  (p_validate                       in  boolean   default false
  ,p_pl_pcp_id                      out nocopy number
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcp_strt_dt_cd                 in  varchar2  default null
  ,p_pcp_dsgn_cd                    in  varchar2  default null
  ,p_pcp_dpnt_dsgn_cd               in  varchar2  default null
  ,p_pcp_rpstry_flag                in  varchar2  default null
  ,p_pcp_can_keep_flag              in  varchar2  default null
  ,p_pcp_radius                     in  number    default null
  ,p_pcp_radius_uom                 in  varchar2  default null
  ,p_pcp_radius_warn_flag           in  varchar2  default null
  ,p_pcp_num_chgs                   in  number    default null
  ,p_pcp_num_chgs_uom               in  varchar2  default null
  ,p_pcp_attribute_category         in  varchar2  default null
  ,p_pcp_attribute1                 in  varchar2  default null
  ,p_pcp_attribute2                 in  varchar2  default null
  ,p_pcp_attribute3                 in  varchar2  default null
  ,p_pcp_attribute4                 in  varchar2  default null
  ,p_pcp_attribute5                 in  varchar2  default null
  ,p_pcp_attribute6                 in  varchar2  default null
  ,p_pcp_attribute7                 in  varchar2  default null
  ,p_pcp_attribute8                 in  varchar2  default null
  ,p_pcp_attribute9                 in  varchar2  default null
  ,p_pcp_attribute10                in  varchar2  default null
  ,p_pcp_attribute11                in  varchar2  default null
  ,p_pcp_attribute12                in  varchar2  default null
  ,p_pcp_attribute13                in  varchar2  default null
  ,p_pcp_attribute14                in  varchar2  default null
  ,p_pcp_attribute15                in  varchar2  default null
  ,p_pcp_attribute16                in  varchar2  default null
  ,p_pcp_attribute17                in  varchar2  default null
  ,p_pcp_attribute18                in  varchar2  default null
  ,p_pcp_attribute19                in  varchar2  default null
  ,p_pcp_attribute20                in  varchar2  default null
  ,p_pcp_attribute21                in  varchar2  default null
  ,p_pcp_attribute22                in  varchar2  default null
  ,p_pcp_attribute23                in  varchar2  default null
  ,p_pcp_attribute24                in  varchar2  default null
  ,p_pcp_attribute25                in  varchar2  default null
  ,p_pcp_attribute26                in  varchar2  default null
  ,p_pcp_attribute27                in  varchar2  default null
  ,p_pcp_attribute28                in  varchar2  default null
  ,p_pcp_attribute29                in  varchar2  default null
  ,p_pcp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_pcp_id ben_pl_pcp.pl_pcp_id%TYPE;
  l_proc varchar2(72) := g_package||'create_pl_prmry_care_prvdr';
  l_object_version_number ben_pl_pcp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_pl_prmry_care_prvdr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_pl_prmry_care_prvdr
    --
    ben_pl_prmry_care_prvdr_bk1.create_pl_prmry_care_prvdr_b
      (
       p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcp_strt_dt_cd                 =>  p_pcp_strt_dt_cd
      ,p_pcp_dsgn_cd                    =>  p_pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd               =>  p_pcp_dpnt_dsgn_cd
      ,p_pcp_rpstry_flag                =>  p_pcp_rpstry_flag
      ,p_pcp_can_keep_flag              =>  p_pcp_can_keep_flag
      ,p_pcp_radius                     =>  p_pcp_radius
      ,p_pcp_radius_uom                 =>  p_pcp_radius_uom
      ,p_pcp_radius_warn_flag           =>  p_pcp_radius_warn_flag
      ,p_pcp_num_chgs                   =>  p_pcp_num_chgs
      ,p_pcp_num_chgs_uom               =>  p_pcp_num_chgs_uom
      ,p_pcp_attribute_category         =>  p_pcp_attribute_category
      ,p_pcp_attribute1                 =>  p_pcp_attribute1
      ,p_pcp_attribute2                 =>  p_pcp_attribute2
      ,p_pcp_attribute3                 =>  p_pcp_attribute3
      ,p_pcp_attribute4                 =>  p_pcp_attribute4
      ,p_pcp_attribute5                 =>  p_pcp_attribute5
      ,p_pcp_attribute6                 =>  p_pcp_attribute6
      ,p_pcp_attribute7                 =>  p_pcp_attribute7
      ,p_pcp_attribute8                 =>  p_pcp_attribute8
      ,p_pcp_attribute9                 =>  p_pcp_attribute9
      ,p_pcp_attribute10                =>  p_pcp_attribute10
      ,p_pcp_attribute11                =>  p_pcp_attribute11
      ,p_pcp_attribute12                =>  p_pcp_attribute12
      ,p_pcp_attribute13                =>  p_pcp_attribute13
      ,p_pcp_attribute14                =>  p_pcp_attribute14
      ,p_pcp_attribute15                =>  p_pcp_attribute15
      ,p_pcp_attribute16                =>  p_pcp_attribute16
      ,p_pcp_attribute17                =>  p_pcp_attribute17
      ,p_pcp_attribute18                =>  p_pcp_attribute18
      ,p_pcp_attribute19                =>  p_pcp_attribute19
      ,p_pcp_attribute20                =>  p_pcp_attribute20
      ,p_pcp_attribute21                =>  p_pcp_attribute21
      ,p_pcp_attribute22                =>  p_pcp_attribute22
      ,p_pcp_attribute23                =>  p_pcp_attribute23
      ,p_pcp_attribute24                =>  p_pcp_attribute24
      ,p_pcp_attribute25                =>  p_pcp_attribute25
      ,p_pcp_attribute26                =>  p_pcp_attribute26
      ,p_pcp_attribute27                =>  p_pcp_attribute27
      ,p_pcp_attribute28                =>  p_pcp_attribute28
      ,p_pcp_attribute29                =>  p_pcp_attribute29
      ,p_pcp_attribute30                =>  p_pcp_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_pl_prmry_care_prvdr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_pl_prmry_care_prvdr
    --
  end;
  --
  ben_pcp_ins.ins
    (
     p_pl_pcp_id                     => l_pl_pcp_id
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcp_strt_dt_cd                => p_pcp_strt_dt_cd
    ,p_pcp_dsgn_cd                   => p_pcp_dsgn_cd
    ,p_pcp_dpnt_dsgn_cd              => p_pcp_dpnt_dsgn_cd
    ,p_pcp_rpstry_flag               => p_pcp_rpstry_flag
    ,p_pcp_can_keep_flag             => p_pcp_can_keep_flag
    ,p_pcp_radius                    => p_pcp_radius
    ,p_pcp_radius_uom                => p_pcp_radius_uom
    ,p_pcp_radius_warn_flag          => p_pcp_radius_warn_flag
    ,p_pcp_num_chgs                  => p_pcp_num_chgs
    ,p_pcp_num_chgs_uom              => p_pcp_num_chgs_uom
    ,p_pcp_attribute_category        => p_pcp_attribute_category
    ,p_pcp_attribute1                => p_pcp_attribute1
    ,p_pcp_attribute2                => p_pcp_attribute2
    ,p_pcp_attribute3                => p_pcp_attribute3
    ,p_pcp_attribute4                => p_pcp_attribute4
    ,p_pcp_attribute5                => p_pcp_attribute5
    ,p_pcp_attribute6                => p_pcp_attribute6
    ,p_pcp_attribute7                => p_pcp_attribute7
    ,p_pcp_attribute8                => p_pcp_attribute8
    ,p_pcp_attribute9                => p_pcp_attribute9
    ,p_pcp_attribute10               => p_pcp_attribute10
    ,p_pcp_attribute11               => p_pcp_attribute11
    ,p_pcp_attribute12               => p_pcp_attribute12
    ,p_pcp_attribute13               => p_pcp_attribute13
    ,p_pcp_attribute14               => p_pcp_attribute14
    ,p_pcp_attribute15               => p_pcp_attribute15
    ,p_pcp_attribute16               => p_pcp_attribute16
    ,p_pcp_attribute17               => p_pcp_attribute17
    ,p_pcp_attribute18               => p_pcp_attribute18
    ,p_pcp_attribute19               => p_pcp_attribute19
    ,p_pcp_attribute20               => p_pcp_attribute20
    ,p_pcp_attribute21               => p_pcp_attribute21
    ,p_pcp_attribute22               => p_pcp_attribute22
    ,p_pcp_attribute23               => p_pcp_attribute23
    ,p_pcp_attribute24               => p_pcp_attribute24
    ,p_pcp_attribute25               => p_pcp_attribute25
    ,p_pcp_attribute26               => p_pcp_attribute26
    ,p_pcp_attribute27               => p_pcp_attribute27
    ,p_pcp_attribute28               => p_pcp_attribute28
    ,p_pcp_attribute29               => p_pcp_attribute29
    ,p_pcp_attribute30               => p_pcp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_pl_prmry_care_prvdr
    --
    ben_pl_prmry_care_prvdr_bk1.create_pl_prmry_care_prvdr_a
      (
       p_pl_pcp_id                      =>  l_pl_pcp_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcp_strt_dt_cd                 =>  p_pcp_strt_dt_cd
      ,p_pcp_dsgn_cd                    =>  p_pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd               =>  p_pcp_dpnt_dsgn_cd
      ,p_pcp_rpstry_flag                =>  p_pcp_rpstry_flag
      ,p_pcp_can_keep_flag              =>  p_pcp_can_keep_flag
      ,p_pcp_radius                     =>  p_pcp_radius
      ,p_pcp_radius_uom                 =>  p_pcp_radius_uom
      ,p_pcp_radius_warn_flag           =>  p_pcp_radius_warn_flag
      ,p_pcp_num_chgs                   =>  p_pcp_num_chgs
      ,p_pcp_num_chgs_uom               =>  p_pcp_num_chgs_uom
      ,p_pcp_attribute_category         =>  p_pcp_attribute_category
      ,p_pcp_attribute1                 =>  p_pcp_attribute1
      ,p_pcp_attribute2                 =>  p_pcp_attribute2
      ,p_pcp_attribute3                 =>  p_pcp_attribute3
      ,p_pcp_attribute4                 =>  p_pcp_attribute4
      ,p_pcp_attribute5                 =>  p_pcp_attribute5
      ,p_pcp_attribute6                 =>  p_pcp_attribute6
      ,p_pcp_attribute7                 =>  p_pcp_attribute7
      ,p_pcp_attribute8                 =>  p_pcp_attribute8
      ,p_pcp_attribute9                 =>  p_pcp_attribute9
      ,p_pcp_attribute10                =>  p_pcp_attribute10
      ,p_pcp_attribute11                =>  p_pcp_attribute11
      ,p_pcp_attribute12                =>  p_pcp_attribute12
      ,p_pcp_attribute13                =>  p_pcp_attribute13
      ,p_pcp_attribute14                =>  p_pcp_attribute14
      ,p_pcp_attribute15                =>  p_pcp_attribute15
      ,p_pcp_attribute16                =>  p_pcp_attribute16
      ,p_pcp_attribute17                =>  p_pcp_attribute17
      ,p_pcp_attribute18                =>  p_pcp_attribute18
      ,p_pcp_attribute19                =>  p_pcp_attribute19
      ,p_pcp_attribute20                =>  p_pcp_attribute20
      ,p_pcp_attribute21                =>  p_pcp_attribute21
      ,p_pcp_attribute22                =>  p_pcp_attribute22
      ,p_pcp_attribute23                =>  p_pcp_attribute23
      ,p_pcp_attribute24                =>  p_pcp_attribute24
      ,p_pcp_attribute25                =>  p_pcp_attribute25
      ,p_pcp_attribute26                =>  p_pcp_attribute26
      ,p_pcp_attribute27                =>  p_pcp_attribute27
      ,p_pcp_attribute28                =>  p_pcp_attribute28
      ,p_pcp_attribute29                =>  p_pcp_attribute29
      ,p_pcp_attribute30                =>  p_pcp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_pl_prmry_care_prvdr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_pl_prmry_care_prvdr
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
  p_pl_pcp_id := l_pl_pcp_id;
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
    ROLLBACK TO create_pl_prmry_care_prvdr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_pcp_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_pl_prmry_care_prvdr;
    p_pl_pcp_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_pl_prmry_care_prvdr;
-- ----------------------------------------------------------------------------
-- |------------------------< update_pl_prmry_care_prvdr >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pl_prmry_care_prvdr
  (p_validate                       in  boolean   default false
  ,p_pl_pcp_id                      in  number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcp_strt_dt_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_dsgn_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pcp_dpnt_dsgn_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pcp_rpstry_flag                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_can_keep_flag              in  varchar2  default hr_api.g_varchar2
  ,p_pcp_radius                     in  number    default hr_api.g_number
  ,p_pcp_radius_uom                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_radius_warn_flag           in  varchar2  default hr_api.g_varchar2
  ,p_pcp_num_chgs                   in  number    default hr_api.g_number
  ,p_pcp_num_chgs_uom               in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pl_prmry_care_prvdr';
  l_object_version_number ben_pl_pcp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_pl_prmry_care_prvdr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_pl_prmry_care_prvdr
    --
    ben_pl_prmry_care_prvdr_bk2.update_pl_prmry_care_prvdr_b
      (
       p_pl_pcp_id                      =>  p_pl_pcp_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcp_strt_dt_cd                 =>  p_pcp_strt_dt_cd
      ,p_pcp_dsgn_cd                    =>  p_pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd               =>  p_pcp_dpnt_dsgn_cd
      ,p_pcp_rpstry_flag                =>  p_pcp_rpstry_flag
      ,p_pcp_can_keep_flag              =>  p_pcp_can_keep_flag
      ,p_pcp_radius                     =>  p_pcp_radius
      ,p_pcp_radius_uom                 =>  p_pcp_radius_uom
      ,p_pcp_radius_warn_flag           =>  p_pcp_radius_warn_flag
      ,p_pcp_num_chgs                   =>  p_pcp_num_chgs
      ,p_pcp_num_chgs_uom               =>  p_pcp_num_chgs_uom
      ,p_pcp_attribute_category         =>  p_pcp_attribute_category
      ,p_pcp_attribute1                 =>  p_pcp_attribute1
      ,p_pcp_attribute2                 =>  p_pcp_attribute2
      ,p_pcp_attribute3                 =>  p_pcp_attribute3
      ,p_pcp_attribute4                 =>  p_pcp_attribute4
      ,p_pcp_attribute5                 =>  p_pcp_attribute5
      ,p_pcp_attribute6                 =>  p_pcp_attribute6
      ,p_pcp_attribute7                 =>  p_pcp_attribute7
      ,p_pcp_attribute8                 =>  p_pcp_attribute8
      ,p_pcp_attribute9                 =>  p_pcp_attribute9
      ,p_pcp_attribute10                =>  p_pcp_attribute10
      ,p_pcp_attribute11                =>  p_pcp_attribute11
      ,p_pcp_attribute12                =>  p_pcp_attribute12
      ,p_pcp_attribute13                =>  p_pcp_attribute13
      ,p_pcp_attribute14                =>  p_pcp_attribute14
      ,p_pcp_attribute15                =>  p_pcp_attribute15
      ,p_pcp_attribute16                =>  p_pcp_attribute16
      ,p_pcp_attribute17                =>  p_pcp_attribute17
      ,p_pcp_attribute18                =>  p_pcp_attribute18
      ,p_pcp_attribute19                =>  p_pcp_attribute19
      ,p_pcp_attribute20                =>  p_pcp_attribute20
      ,p_pcp_attribute21                =>  p_pcp_attribute21
      ,p_pcp_attribute22                =>  p_pcp_attribute22
      ,p_pcp_attribute23                =>  p_pcp_attribute23
      ,p_pcp_attribute24                =>  p_pcp_attribute24
      ,p_pcp_attribute25                =>  p_pcp_attribute25
      ,p_pcp_attribute26                =>  p_pcp_attribute26
      ,p_pcp_attribute27                =>  p_pcp_attribute27
      ,p_pcp_attribute28                =>  p_pcp_attribute28
      ,p_pcp_attribute29                =>  p_pcp_attribute29
      ,p_pcp_attribute30                =>  p_pcp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pl_prmry_care_prvdr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_pl_prmry_care_prvdr
    --
  end;
  --
  ben_pcp_upd.upd
    (
     p_pl_pcp_id                     => p_pl_pcp_id
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcp_strt_dt_cd                => p_pcp_strt_dt_cd
    ,p_pcp_dsgn_cd                   => p_pcp_dsgn_cd
    ,p_pcp_dpnt_dsgn_cd              => p_pcp_dpnt_dsgn_cd
    ,p_pcp_rpstry_flag               => p_pcp_rpstry_flag
    ,p_pcp_can_keep_flag             => p_pcp_can_keep_flag
    ,p_pcp_radius                    => p_pcp_radius
    ,p_pcp_radius_uom                => p_pcp_radius_uom
    ,p_pcp_radius_warn_flag          => p_pcp_radius_warn_flag
    ,p_pcp_num_chgs                  => p_pcp_num_chgs
    ,p_pcp_num_chgs_uom              => p_pcp_num_chgs_uom
    ,p_pcp_attribute_category        => p_pcp_attribute_category
    ,p_pcp_attribute1                => p_pcp_attribute1
    ,p_pcp_attribute2                => p_pcp_attribute2
    ,p_pcp_attribute3                => p_pcp_attribute3
    ,p_pcp_attribute4                => p_pcp_attribute4
    ,p_pcp_attribute5                => p_pcp_attribute5
    ,p_pcp_attribute6                => p_pcp_attribute6
    ,p_pcp_attribute7                => p_pcp_attribute7
    ,p_pcp_attribute8                => p_pcp_attribute8
    ,p_pcp_attribute9                => p_pcp_attribute9
    ,p_pcp_attribute10               => p_pcp_attribute10
    ,p_pcp_attribute11               => p_pcp_attribute11
    ,p_pcp_attribute12               => p_pcp_attribute12
    ,p_pcp_attribute13               => p_pcp_attribute13
    ,p_pcp_attribute14               => p_pcp_attribute14
    ,p_pcp_attribute15               => p_pcp_attribute15
    ,p_pcp_attribute16               => p_pcp_attribute16
    ,p_pcp_attribute17               => p_pcp_attribute17
    ,p_pcp_attribute18               => p_pcp_attribute18
    ,p_pcp_attribute19               => p_pcp_attribute19
    ,p_pcp_attribute20               => p_pcp_attribute20
    ,p_pcp_attribute21               => p_pcp_attribute21
    ,p_pcp_attribute22               => p_pcp_attribute22
    ,p_pcp_attribute23               => p_pcp_attribute23
    ,p_pcp_attribute24               => p_pcp_attribute24
    ,p_pcp_attribute25               => p_pcp_attribute25
    ,p_pcp_attribute26               => p_pcp_attribute26
    ,p_pcp_attribute27               => p_pcp_attribute27
    ,p_pcp_attribute28               => p_pcp_attribute28
    ,p_pcp_attribute29               => p_pcp_attribute29
    ,p_pcp_attribute30               => p_pcp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_pl_prmry_care_prvdr
    --
    ben_pl_prmry_care_prvdr_bk2.update_pl_prmry_care_prvdr_a
      (
       p_pl_pcp_id                      =>  p_pl_pcp_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcp_strt_dt_cd                 =>  p_pcp_strt_dt_cd
      ,p_pcp_dsgn_cd                    =>  p_pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd               =>  p_pcp_dpnt_dsgn_cd
      ,p_pcp_rpstry_flag                =>  p_pcp_rpstry_flag
      ,p_pcp_can_keep_flag              =>  p_pcp_can_keep_flag
      ,p_pcp_radius                     =>  p_pcp_radius
      ,p_pcp_radius_uom                 =>  p_pcp_radius_uom
      ,p_pcp_radius_warn_flag           =>  p_pcp_radius_warn_flag
      ,p_pcp_num_chgs                   =>  p_pcp_num_chgs
      ,p_pcp_num_chgs_uom               =>  p_pcp_num_chgs_uom
      ,p_pcp_attribute_category         =>  p_pcp_attribute_category
      ,p_pcp_attribute1                 =>  p_pcp_attribute1
      ,p_pcp_attribute2                 =>  p_pcp_attribute2
      ,p_pcp_attribute3                 =>  p_pcp_attribute3
      ,p_pcp_attribute4                 =>  p_pcp_attribute4
      ,p_pcp_attribute5                 =>  p_pcp_attribute5
      ,p_pcp_attribute6                 =>  p_pcp_attribute6
      ,p_pcp_attribute7                 =>  p_pcp_attribute7
      ,p_pcp_attribute8                 =>  p_pcp_attribute8
      ,p_pcp_attribute9                 =>  p_pcp_attribute9
      ,p_pcp_attribute10                =>  p_pcp_attribute10
      ,p_pcp_attribute11                =>  p_pcp_attribute11
      ,p_pcp_attribute12                =>  p_pcp_attribute12
      ,p_pcp_attribute13                =>  p_pcp_attribute13
      ,p_pcp_attribute14                =>  p_pcp_attribute14
      ,p_pcp_attribute15                =>  p_pcp_attribute15
      ,p_pcp_attribute16                =>  p_pcp_attribute16
      ,p_pcp_attribute17                =>  p_pcp_attribute17
      ,p_pcp_attribute18                =>  p_pcp_attribute18
      ,p_pcp_attribute19                =>  p_pcp_attribute19
      ,p_pcp_attribute20                =>  p_pcp_attribute20
      ,p_pcp_attribute21                =>  p_pcp_attribute21
      ,p_pcp_attribute22                =>  p_pcp_attribute22
      ,p_pcp_attribute23                =>  p_pcp_attribute23
      ,p_pcp_attribute24                =>  p_pcp_attribute24
      ,p_pcp_attribute25                =>  p_pcp_attribute25
      ,p_pcp_attribute26                =>  p_pcp_attribute26
      ,p_pcp_attribute27                =>  p_pcp_attribute27
      ,p_pcp_attribute28                =>  p_pcp_attribute28
      ,p_pcp_attribute29                =>  p_pcp_attribute29
      ,p_pcp_attribute30                =>  p_pcp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pl_prmry_care_prvdr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_pl_prmry_care_prvdr
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
    ROLLBACK TO update_pl_prmry_care_prvdr;
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
    ROLLBACK TO update_pl_prmry_care_prvdr;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_pl_prmry_care_prvdr;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pl_prmry_care_prvdr >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_prmry_care_prvdr
  (p_validate                       in  boolean  default false
  ,p_pl_pcp_id                      in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pl_prmry_care_prvdr';
  l_object_version_number ben_pl_pcp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_pl_prmry_care_prvdr;
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
    -- Start of API User Hook for the before hook of delete_pl_prmry_care_prvdr
    --
    ben_pl_prmry_care_prvdr_bk3.delete_pl_prmry_care_prvdr_b
      (
       p_pl_pcp_id                      =>  p_pl_pcp_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pl_prmry_care_prvdr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_pl_prmry_care_prvdr
    --
  end;
  --
  -- Bug 1415961 ,On deleting the Plan PCP record,
  -- clear out the designation values for the Options in Plan
  --
  begin

    UPDATE ben_oipl_f
    SET   pcp_dsgn_cd = NULL ,
          pcp_dpnt_dsgn_cd = NULL
    WHERE pl_id = ( SELECT pl_id
                    FROM ben_pl_pcp
                    WHERE pl_pcp_id = p_pl_pcp_id )
    AND   business_group_id = ( SELECT business_group_id
     	 		        FROM ben_pl_pcp
     			        WHERE pl_pcp_id = p_pl_pcp_id )
    AND   p_effective_date BETWEEN effective_start_date AND effective_end_date;

  end;
  -- End of fix, Bug 1415961

  ben_pcp_del.del
    (
     p_pl_pcp_id                     => p_pl_pcp_id
    ,p_object_version_number         => l_object_version_number
   -- ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_pl_prmry_care_prvdr
    --
    ben_pl_prmry_care_prvdr_bk3.delete_pl_prmry_care_prvdr_a
      (
       p_pl_pcp_id                      =>  p_pl_pcp_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pl_prmry_care_prvdr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_pl_prmry_care_prvdr
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
    ROLLBACK TO delete_pl_prmry_care_prvdr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_pl_prmry_care_prvdr;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_pl_prmry_care_prvdr;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_pcp_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_pcp_shd.lck
    (
      p_pl_pcp_id                 => p_pl_pcp_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_pl_prmry_care_prvdr_api;

/
