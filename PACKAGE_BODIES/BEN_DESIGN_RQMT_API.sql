--------------------------------------------------------
--  DDL for Package Body BEN_DESIGN_RQMT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DESIGN_RQMT_API" as
/* $Header: beddrapi.pkb 115.3 2002/12/13 08:28:10 bmanyam ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_design_rqmt_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_design_rqmt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_design_rqmt
  (p_validate                       in  boolean   default false
  ,p_dsgn_rqmt_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_mn_dpnts_rqd_num               in  number    default null
  ,p_mx_dpnts_alwd_num              in  number    default null
  ,p_no_mn_num_dfnd_flag            in  varchar2  default null
  ,p_no_mx_num_dfnd_flag            in  varchar2  default null
  ,p_cvr_all_elig_flag              in  varchar2  default null
  ,p_oipl_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_grp_rlshp_cd                   in  varchar2  default null
  ,p_dsgn_typ_cd                    in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_ddr_attribute_category         in  varchar2  default null
  ,p_ddr_attribute1                 in  varchar2  default null
  ,p_ddr_attribute2                 in  varchar2  default null
  ,p_ddr_attribute3                 in  varchar2  default null
  ,p_ddr_attribute4                 in  varchar2  default null
  ,p_ddr_attribute5                 in  varchar2  default null
  ,p_ddr_attribute6                 in  varchar2  default null
  ,p_ddr_attribute7                 in  varchar2  default null
  ,p_ddr_attribute8                 in  varchar2  default null
  ,p_ddr_attribute9                 in  varchar2  default null
  ,p_ddr_attribute10                in  varchar2  default null
  ,p_ddr_attribute11                in  varchar2  default null
  ,p_ddr_attribute12                in  varchar2  default null
  ,p_ddr_attribute13                in  varchar2  default null
  ,p_ddr_attribute14                in  varchar2  default null
  ,p_ddr_attribute15                in  varchar2  default null
  ,p_ddr_attribute16                in  varchar2  default null
  ,p_ddr_attribute17                in  varchar2  default null
  ,p_ddr_attribute18                in  varchar2  default null
  ,p_ddr_attribute19                in  varchar2  default null
  ,p_ddr_attribute20                in  varchar2  default null
  ,p_ddr_attribute21                in  varchar2  default null
  ,p_ddr_attribute22                in  varchar2  default null
  ,p_ddr_attribute23                in  varchar2  default null
  ,p_ddr_attribute24                in  varchar2  default null
  ,p_ddr_attribute25                in  varchar2  default null
  ,p_ddr_attribute26                in  varchar2  default null
  ,p_ddr_attribute27                in  varchar2  default null
  ,p_ddr_attribute28                in  varchar2  default null
  ,p_ddr_attribute29                in  varchar2  default null
  ,p_ddr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_dsgn_rqmt_id ben_dsgn_rqmt_f.dsgn_rqmt_id%TYPE;
  l_effective_start_date ben_dsgn_rqmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_dsgn_rqmt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_design_rqmt';
  l_object_version_number ben_dsgn_rqmt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_design_rqmt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_design_rqmt
    --
    ben_design_rqmt_bk1.create_design_rqmt_b
      (
       p_mn_dpnts_rqd_num               =>  p_mn_dpnts_rqd_num
      ,p_mx_dpnts_alwd_num              =>  p_mx_dpnts_alwd_num
      ,p_no_mn_num_dfnd_flag            =>  p_no_mn_num_dfnd_flag
      ,p_no_mx_num_dfnd_flag            =>  p_no_mx_num_dfnd_flag
      ,p_cvr_all_elig_flag              =>  p_cvr_all_elig_flag
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_opt_id                         =>  p_opt_id
      ,p_grp_rlshp_cd                   =>  p_grp_rlshp_cd
      ,p_dsgn_typ_cd                    =>  p_dsgn_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_ddr_attribute_category         =>  p_ddr_attribute_category
      ,p_ddr_attribute1                 =>  p_ddr_attribute1
      ,p_ddr_attribute2                 =>  p_ddr_attribute2
      ,p_ddr_attribute3                 =>  p_ddr_attribute3
      ,p_ddr_attribute4                 =>  p_ddr_attribute4
      ,p_ddr_attribute5                 =>  p_ddr_attribute5
      ,p_ddr_attribute6                 =>  p_ddr_attribute6
      ,p_ddr_attribute7                 =>  p_ddr_attribute7
      ,p_ddr_attribute8                 =>  p_ddr_attribute8
      ,p_ddr_attribute9                 =>  p_ddr_attribute9
      ,p_ddr_attribute10                =>  p_ddr_attribute10
      ,p_ddr_attribute11                =>  p_ddr_attribute11
      ,p_ddr_attribute12                =>  p_ddr_attribute12
      ,p_ddr_attribute13                =>  p_ddr_attribute13
      ,p_ddr_attribute14                =>  p_ddr_attribute14
      ,p_ddr_attribute15                =>  p_ddr_attribute15
      ,p_ddr_attribute16                =>  p_ddr_attribute16
      ,p_ddr_attribute17                =>  p_ddr_attribute17
      ,p_ddr_attribute18                =>  p_ddr_attribute18
      ,p_ddr_attribute19                =>  p_ddr_attribute19
      ,p_ddr_attribute20                =>  p_ddr_attribute20
      ,p_ddr_attribute21                =>  p_ddr_attribute21
      ,p_ddr_attribute22                =>  p_ddr_attribute22
      ,p_ddr_attribute23                =>  p_ddr_attribute23
      ,p_ddr_attribute24                =>  p_ddr_attribute24
      ,p_ddr_attribute25                =>  p_ddr_attribute25
      ,p_ddr_attribute26                =>  p_ddr_attribute26
      ,p_ddr_attribute27                =>  p_ddr_attribute27
      ,p_ddr_attribute28                =>  p_ddr_attribute28
      ,p_ddr_attribute29                =>  p_ddr_attribute29
      ,p_ddr_attribute30                =>  p_ddr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_design_rqmt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_design_rqmt
    --
  end;
  --
  ben_ddr_ins.ins
    (
     p_dsgn_rqmt_id                  => l_dsgn_rqmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_mn_dpnts_rqd_num              => p_mn_dpnts_rqd_num
    ,p_mx_dpnts_alwd_num             => p_mx_dpnts_alwd_num
    ,p_no_mn_num_dfnd_flag           => p_no_mn_num_dfnd_flag
    ,p_no_mx_num_dfnd_flag           => p_no_mx_num_dfnd_flag
    ,p_cvr_all_elig_flag             => p_cvr_all_elig_flag
    ,p_oipl_id                       => p_oipl_id
    ,p_pl_id                         => p_pl_id
    ,p_opt_id                        => p_opt_id
    ,p_grp_rlshp_cd                  => p_grp_rlshp_cd
    ,p_dsgn_typ_cd                   => p_dsgn_typ_cd
    ,p_business_group_id             => p_business_group_id
    ,p_ddr_attribute_category        => p_ddr_attribute_category
    ,p_ddr_attribute1                => p_ddr_attribute1
    ,p_ddr_attribute2                => p_ddr_attribute2
    ,p_ddr_attribute3                => p_ddr_attribute3
    ,p_ddr_attribute4                => p_ddr_attribute4
    ,p_ddr_attribute5                => p_ddr_attribute5
    ,p_ddr_attribute6                => p_ddr_attribute6
    ,p_ddr_attribute7                => p_ddr_attribute7
    ,p_ddr_attribute8                => p_ddr_attribute8
    ,p_ddr_attribute9                => p_ddr_attribute9
    ,p_ddr_attribute10               => p_ddr_attribute10
    ,p_ddr_attribute11               => p_ddr_attribute11
    ,p_ddr_attribute12               => p_ddr_attribute12
    ,p_ddr_attribute13               => p_ddr_attribute13
    ,p_ddr_attribute14               => p_ddr_attribute14
    ,p_ddr_attribute15               => p_ddr_attribute15
    ,p_ddr_attribute16               => p_ddr_attribute16
    ,p_ddr_attribute17               => p_ddr_attribute17
    ,p_ddr_attribute18               => p_ddr_attribute18
    ,p_ddr_attribute19               => p_ddr_attribute19
    ,p_ddr_attribute20               => p_ddr_attribute20
    ,p_ddr_attribute21               => p_ddr_attribute21
    ,p_ddr_attribute22               => p_ddr_attribute22
    ,p_ddr_attribute23               => p_ddr_attribute23
    ,p_ddr_attribute24               => p_ddr_attribute24
    ,p_ddr_attribute25               => p_ddr_attribute25
    ,p_ddr_attribute26               => p_ddr_attribute26
    ,p_ddr_attribute27               => p_ddr_attribute27
    ,p_ddr_attribute28               => p_ddr_attribute28
    ,p_ddr_attribute29               => p_ddr_attribute29
    ,p_ddr_attribute30               => p_ddr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_design_rqmt
    --
    ben_design_rqmt_bk1.create_design_rqmt_a
      (
       p_dsgn_rqmt_id                   =>  l_dsgn_rqmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_mn_dpnts_rqd_num               =>  p_mn_dpnts_rqd_num
      ,p_mx_dpnts_alwd_num              =>  p_mx_dpnts_alwd_num
      ,p_no_mn_num_dfnd_flag            =>  p_no_mn_num_dfnd_flag
      ,p_no_mx_num_dfnd_flag            =>  p_no_mx_num_dfnd_flag
      ,p_cvr_all_elig_flag              =>  p_cvr_all_elig_flag
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_opt_id                         =>  p_opt_id
      ,p_grp_rlshp_cd                   =>  p_grp_rlshp_cd
      ,p_dsgn_typ_cd                    =>  p_dsgn_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_ddr_attribute_category         =>  p_ddr_attribute_category
      ,p_ddr_attribute1                 =>  p_ddr_attribute1
      ,p_ddr_attribute2                 =>  p_ddr_attribute2
      ,p_ddr_attribute3                 =>  p_ddr_attribute3
      ,p_ddr_attribute4                 =>  p_ddr_attribute4
      ,p_ddr_attribute5                 =>  p_ddr_attribute5
      ,p_ddr_attribute6                 =>  p_ddr_attribute6
      ,p_ddr_attribute7                 =>  p_ddr_attribute7
      ,p_ddr_attribute8                 =>  p_ddr_attribute8
      ,p_ddr_attribute9                 =>  p_ddr_attribute9
      ,p_ddr_attribute10                =>  p_ddr_attribute10
      ,p_ddr_attribute11                =>  p_ddr_attribute11
      ,p_ddr_attribute12                =>  p_ddr_attribute12
      ,p_ddr_attribute13                =>  p_ddr_attribute13
      ,p_ddr_attribute14                =>  p_ddr_attribute14
      ,p_ddr_attribute15                =>  p_ddr_attribute15
      ,p_ddr_attribute16                =>  p_ddr_attribute16
      ,p_ddr_attribute17                =>  p_ddr_attribute17
      ,p_ddr_attribute18                =>  p_ddr_attribute18
      ,p_ddr_attribute19                =>  p_ddr_attribute19
      ,p_ddr_attribute20                =>  p_ddr_attribute20
      ,p_ddr_attribute21                =>  p_ddr_attribute21
      ,p_ddr_attribute22                =>  p_ddr_attribute22
      ,p_ddr_attribute23                =>  p_ddr_attribute23
      ,p_ddr_attribute24                =>  p_ddr_attribute24
      ,p_ddr_attribute25                =>  p_ddr_attribute25
      ,p_ddr_attribute26                =>  p_ddr_attribute26
      ,p_ddr_attribute27                =>  p_ddr_attribute27
      ,p_ddr_attribute28                =>  p_ddr_attribute28
      ,p_ddr_attribute29                =>  p_ddr_attribute29
      ,p_ddr_attribute30                =>  p_ddr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_design_rqmt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_design_rqmt
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
  p_dsgn_rqmt_id := l_dsgn_rqmt_id;
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
    ROLLBACK TO create_design_rqmt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_dsgn_rqmt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_design_rqmt;
    -- NOCOPY Changes
		p_dsgn_rqmt_id := null;
		p_effective_start_date := null;
		p_effective_end_date := null;
		p_object_version_number  := null;
	-- NOCOPY Changes
    raise;
    --
end create_design_rqmt;
-- ----------------------------------------------------------------------------
-- |------------------------< update_design_rqmt >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_design_rqmt
  (p_validate                       in  boolean   default false
  ,p_dsgn_rqmt_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_mn_dpnts_rqd_num               in  number    default hr_api.g_number
  ,p_mx_dpnts_alwd_num              in  number    default hr_api.g_number
  ,p_no_mn_num_dfnd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_num_dfnd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_cvr_all_elig_flag              in  varchar2  default hr_api.g_varchar2
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_grp_rlshp_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dsgn_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ddr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_design_rqmt';
  l_object_version_number ben_dsgn_rqmt_f.object_version_number%TYPE;
  l_effective_start_date ben_dsgn_rqmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_dsgn_rqmt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_design_rqmt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_design_rqmt
    --
    ben_design_rqmt_bk2.update_design_rqmt_b
      (
       p_dsgn_rqmt_id                   =>  p_dsgn_rqmt_id
      ,p_mn_dpnts_rqd_num               =>  p_mn_dpnts_rqd_num
      ,p_mx_dpnts_alwd_num              =>  p_mx_dpnts_alwd_num
      ,p_no_mn_num_dfnd_flag            =>  p_no_mn_num_dfnd_flag
      ,p_no_mx_num_dfnd_flag            =>  p_no_mx_num_dfnd_flag
      ,p_cvr_all_elig_flag              =>  p_cvr_all_elig_flag
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_opt_id                         =>  p_opt_id
      ,p_grp_rlshp_cd                   =>  p_grp_rlshp_cd
      ,p_dsgn_typ_cd                    =>  p_dsgn_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_ddr_attribute_category         =>  p_ddr_attribute_category
      ,p_ddr_attribute1                 =>  p_ddr_attribute1
      ,p_ddr_attribute2                 =>  p_ddr_attribute2
      ,p_ddr_attribute3                 =>  p_ddr_attribute3
      ,p_ddr_attribute4                 =>  p_ddr_attribute4
      ,p_ddr_attribute5                 =>  p_ddr_attribute5
      ,p_ddr_attribute6                 =>  p_ddr_attribute6
      ,p_ddr_attribute7                 =>  p_ddr_attribute7
      ,p_ddr_attribute8                 =>  p_ddr_attribute8
      ,p_ddr_attribute9                 =>  p_ddr_attribute9
      ,p_ddr_attribute10                =>  p_ddr_attribute10
      ,p_ddr_attribute11                =>  p_ddr_attribute11
      ,p_ddr_attribute12                =>  p_ddr_attribute12
      ,p_ddr_attribute13                =>  p_ddr_attribute13
      ,p_ddr_attribute14                =>  p_ddr_attribute14
      ,p_ddr_attribute15                =>  p_ddr_attribute15
      ,p_ddr_attribute16                =>  p_ddr_attribute16
      ,p_ddr_attribute17                =>  p_ddr_attribute17
      ,p_ddr_attribute18                =>  p_ddr_attribute18
      ,p_ddr_attribute19                =>  p_ddr_attribute19
      ,p_ddr_attribute20                =>  p_ddr_attribute20
      ,p_ddr_attribute21                =>  p_ddr_attribute21
      ,p_ddr_attribute22                =>  p_ddr_attribute22
      ,p_ddr_attribute23                =>  p_ddr_attribute23
      ,p_ddr_attribute24                =>  p_ddr_attribute24
      ,p_ddr_attribute25                =>  p_ddr_attribute25
      ,p_ddr_attribute26                =>  p_ddr_attribute26
      ,p_ddr_attribute27                =>  p_ddr_attribute27
      ,p_ddr_attribute28                =>  p_ddr_attribute28
      ,p_ddr_attribute29                =>  p_ddr_attribute29
      ,p_ddr_attribute30                =>  p_ddr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_design_rqmt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_design_rqmt
    --
  end;
  --
  ben_ddr_upd.upd
    (
     p_dsgn_rqmt_id                  => p_dsgn_rqmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_mn_dpnts_rqd_num              => p_mn_dpnts_rqd_num
    ,p_mx_dpnts_alwd_num             => p_mx_dpnts_alwd_num
    ,p_no_mn_num_dfnd_flag           => p_no_mn_num_dfnd_flag
    ,p_no_mx_num_dfnd_flag           => p_no_mx_num_dfnd_flag
    ,p_cvr_all_elig_flag             => p_cvr_all_elig_flag
    ,p_oipl_id                       => p_oipl_id
    ,p_pl_id                         => p_pl_id
    ,p_opt_id                        => p_opt_id
    ,p_grp_rlshp_cd                  => p_grp_rlshp_cd
    ,p_dsgn_typ_cd                   => p_dsgn_typ_cd
    ,p_business_group_id             => p_business_group_id
    ,p_ddr_attribute_category        => p_ddr_attribute_category
    ,p_ddr_attribute1                => p_ddr_attribute1
    ,p_ddr_attribute2                => p_ddr_attribute2
    ,p_ddr_attribute3                => p_ddr_attribute3
    ,p_ddr_attribute4                => p_ddr_attribute4
    ,p_ddr_attribute5                => p_ddr_attribute5
    ,p_ddr_attribute6                => p_ddr_attribute6
    ,p_ddr_attribute7                => p_ddr_attribute7
    ,p_ddr_attribute8                => p_ddr_attribute8
    ,p_ddr_attribute9                => p_ddr_attribute9
    ,p_ddr_attribute10               => p_ddr_attribute10
    ,p_ddr_attribute11               => p_ddr_attribute11
    ,p_ddr_attribute12               => p_ddr_attribute12
    ,p_ddr_attribute13               => p_ddr_attribute13
    ,p_ddr_attribute14               => p_ddr_attribute14
    ,p_ddr_attribute15               => p_ddr_attribute15
    ,p_ddr_attribute16               => p_ddr_attribute16
    ,p_ddr_attribute17               => p_ddr_attribute17
    ,p_ddr_attribute18               => p_ddr_attribute18
    ,p_ddr_attribute19               => p_ddr_attribute19
    ,p_ddr_attribute20               => p_ddr_attribute20
    ,p_ddr_attribute21               => p_ddr_attribute21
    ,p_ddr_attribute22               => p_ddr_attribute22
    ,p_ddr_attribute23               => p_ddr_attribute23
    ,p_ddr_attribute24               => p_ddr_attribute24
    ,p_ddr_attribute25               => p_ddr_attribute25
    ,p_ddr_attribute26               => p_ddr_attribute26
    ,p_ddr_attribute27               => p_ddr_attribute27
    ,p_ddr_attribute28               => p_ddr_attribute28
    ,p_ddr_attribute29               => p_ddr_attribute29
    ,p_ddr_attribute30               => p_ddr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_design_rqmt
    --
    ben_design_rqmt_bk2.update_design_rqmt_a
      (
       p_dsgn_rqmt_id                   =>  p_dsgn_rqmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_mn_dpnts_rqd_num               =>  p_mn_dpnts_rqd_num
      ,p_mx_dpnts_alwd_num              =>  p_mx_dpnts_alwd_num
      ,p_no_mn_num_dfnd_flag            =>  p_no_mn_num_dfnd_flag
      ,p_no_mx_num_dfnd_flag            =>  p_no_mx_num_dfnd_flag
      ,p_cvr_all_elig_flag              =>  p_cvr_all_elig_flag
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_opt_id                         =>  p_opt_id
      ,p_grp_rlshp_cd                   =>  p_grp_rlshp_cd
      ,p_dsgn_typ_cd                    =>  p_dsgn_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_ddr_attribute_category         =>  p_ddr_attribute_category
      ,p_ddr_attribute1                 =>  p_ddr_attribute1
      ,p_ddr_attribute2                 =>  p_ddr_attribute2
      ,p_ddr_attribute3                 =>  p_ddr_attribute3
      ,p_ddr_attribute4                 =>  p_ddr_attribute4
      ,p_ddr_attribute5                 =>  p_ddr_attribute5
      ,p_ddr_attribute6                 =>  p_ddr_attribute6
      ,p_ddr_attribute7                 =>  p_ddr_attribute7
      ,p_ddr_attribute8                 =>  p_ddr_attribute8
      ,p_ddr_attribute9                 =>  p_ddr_attribute9
      ,p_ddr_attribute10                =>  p_ddr_attribute10
      ,p_ddr_attribute11                =>  p_ddr_attribute11
      ,p_ddr_attribute12                =>  p_ddr_attribute12
      ,p_ddr_attribute13                =>  p_ddr_attribute13
      ,p_ddr_attribute14                =>  p_ddr_attribute14
      ,p_ddr_attribute15                =>  p_ddr_attribute15
      ,p_ddr_attribute16                =>  p_ddr_attribute16
      ,p_ddr_attribute17                =>  p_ddr_attribute17
      ,p_ddr_attribute18                =>  p_ddr_attribute18
      ,p_ddr_attribute19                =>  p_ddr_attribute19
      ,p_ddr_attribute20                =>  p_ddr_attribute20
      ,p_ddr_attribute21                =>  p_ddr_attribute21
      ,p_ddr_attribute22                =>  p_ddr_attribute22
      ,p_ddr_attribute23                =>  p_ddr_attribute23
      ,p_ddr_attribute24                =>  p_ddr_attribute24
      ,p_ddr_attribute25                =>  p_ddr_attribute25
      ,p_ddr_attribute26                =>  p_ddr_attribute26
      ,p_ddr_attribute27                =>  p_ddr_attribute27
      ,p_ddr_attribute28                =>  p_ddr_attribute28
      ,p_ddr_attribute29                =>  p_ddr_attribute29
      ,p_ddr_attribute30                =>  p_ddr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_design_rqmt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_design_rqmt
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
    ROLLBACK TO update_design_rqmt;
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
    ROLLBACK TO update_design_rqmt;
	-- NOCOPY Changes
		p_effective_start_date := null;
		p_effective_end_date := null;
	-- NOCOPY Changes

    raise;
    --
end update_design_rqmt;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_design_rqmt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_design_rqmt
  (p_validate                       in  boolean  default false
  ,p_dsgn_rqmt_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_design_rqmt';
  l_object_version_number ben_dsgn_rqmt_f.object_version_number%TYPE;
  l_effective_start_date ben_dsgn_rqmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_dsgn_rqmt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_design_rqmt;
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
    -- Start of API User Hook for the before hook of delete_design_rqmt
    --
    ben_design_rqmt_bk3.delete_design_rqmt_b
      (
       p_dsgn_rqmt_id                   =>  p_dsgn_rqmt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_design_rqmt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_design_rqmt
    --
  end;
  --
  ben_ddr_del.del
    (
     p_dsgn_rqmt_id                  => p_dsgn_rqmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_design_rqmt
    --
    ben_design_rqmt_bk3.delete_design_rqmt_a
      (
       p_dsgn_rqmt_id                   =>  p_dsgn_rqmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_design_rqmt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_design_rqmt
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
    ROLLBACK TO delete_design_rqmt;
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
    ROLLBACK TO delete_design_rqmt;
	-- NOCOPY Changes
		p_effective_start_date := null;
		p_effective_end_date := null;
	-- NOCOPY Changes

    raise;
    --
end delete_design_rqmt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_dsgn_rqmt_id                   in     number
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
  ben_ddr_shd.lck
    (
      p_dsgn_rqmt_id                 => p_dsgn_rqmt_id
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
end ben_design_rqmt_api;

/
