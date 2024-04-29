--------------------------------------------------------
--  DDL for Package Body BEN_PL_R_OIPL_PREM_BY_MO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PL_R_OIPL_PREM_BY_MO_API" as
/* $Header: bepbmapi.pkb 115.4 2002/12/16 09:37:05 hnarayan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PL_R_OIPL_PREM_BY_MO_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PL_R_OIPL_PREM_BY_MO >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PL_R_OIPL_PREM_BY_MO
  (p_validate                       in  boolean   default false
  ,p_pl_r_oipl_prem_by_mo_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_mnl_adj_flag                   in  varchar2  default 'N'
  ,p_mo_num                         in  number    default null
  ,p_yr_num                         in  number    default null
  ,p_val                            in  number    default null
  ,p_uom                            in  varchar2  default null
  ,p_prtts_num                      in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_cost_allocation_keyflex_id     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pbm_attribute_category         in  varchar2  default null
  ,p_pbm_attribute1                 in  varchar2  default null
  ,p_pbm_attribute2                 in  varchar2  default null
  ,p_pbm_attribute3                 in  varchar2  default null
  ,p_pbm_attribute4                 in  varchar2  default null
  ,p_pbm_attribute5                 in  varchar2  default null
  ,p_pbm_attribute6                 in  varchar2  default null
  ,p_pbm_attribute7                 in  varchar2  default null
  ,p_pbm_attribute8                 in  varchar2  default null
  ,p_pbm_attribute9                 in  varchar2  default null
  ,p_pbm_attribute10                in  varchar2  default null
  ,p_pbm_attribute11                in  varchar2  default null
  ,p_pbm_attribute12                in  varchar2  default null
  ,p_pbm_attribute13                in  varchar2  default null
  ,p_pbm_attribute14                in  varchar2  default null
  ,p_pbm_attribute15                in  varchar2  default null
  ,p_pbm_attribute16                in  varchar2  default null
  ,p_pbm_attribute17                in  varchar2  default null
  ,p_pbm_attribute18                in  varchar2  default null
  ,p_pbm_attribute19                in  varchar2  default null
  ,p_pbm_attribute20                in  varchar2  default null
  ,p_pbm_attribute21                in  varchar2  default null
  ,p_pbm_attribute22                in  varchar2  default null
  ,p_pbm_attribute23                in  varchar2  default null
  ,p_pbm_attribute24                in  varchar2  default null
  ,p_pbm_attribute25                in  varchar2  default null
  ,p_pbm_attribute26                in  varchar2  default null
  ,p_pbm_attribute27                in  varchar2  default null
  ,p_pbm_attribute28                in  varchar2  default null
  ,p_pbm_attribute29                in  varchar2  default null
  ,p_pbm_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_request_id                     in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_r_oipl_prem_by_mo_id ben_pl_r_oipl_prem_by_mo_f.pl_r_oipl_prem_by_mo_id%TYPE;
  l_effective_start_date ben_pl_r_oipl_prem_by_mo_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_r_oipl_prem_by_mo_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PL_R_OIPL_PREM_BY_MO';
  l_object_version_number ben_pl_r_oipl_prem_by_mo_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PL_R_OIPL_PREM_BY_MO;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PL_R_OIPL_PREM_BY_MO
    --
    ben_PL_R_OIPL_PREM_BY_MO_bk1.create_PL_R_OIPL_PREM_BY_MO_b
      (
       p_mnl_adj_flag                   =>  p_mnl_adj_flag
      ,p_mo_num                         =>  p_mo_num
      ,p_yr_num                         =>  p_yr_num
      ,p_val                            =>  p_val
      ,p_uom                            =>  p_uom
      ,p_prtts_num                      =>  p_prtts_num
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbm_attribute_category         =>  p_pbm_attribute_category
      ,p_pbm_attribute1                 =>  p_pbm_attribute1
      ,p_pbm_attribute2                 =>  p_pbm_attribute2
      ,p_pbm_attribute3                 =>  p_pbm_attribute3
      ,p_pbm_attribute4                 =>  p_pbm_attribute4
      ,p_pbm_attribute5                 =>  p_pbm_attribute5
      ,p_pbm_attribute6                 =>  p_pbm_attribute6
      ,p_pbm_attribute7                 =>  p_pbm_attribute7
      ,p_pbm_attribute8                 =>  p_pbm_attribute8
      ,p_pbm_attribute9                 =>  p_pbm_attribute9
      ,p_pbm_attribute10                =>  p_pbm_attribute10
      ,p_pbm_attribute11                =>  p_pbm_attribute11
      ,p_pbm_attribute12                =>  p_pbm_attribute12
      ,p_pbm_attribute13                =>  p_pbm_attribute13
      ,p_pbm_attribute14                =>  p_pbm_attribute14
      ,p_pbm_attribute15                =>  p_pbm_attribute15
      ,p_pbm_attribute16                =>  p_pbm_attribute16
      ,p_pbm_attribute17                =>  p_pbm_attribute17
      ,p_pbm_attribute18                =>  p_pbm_attribute18
      ,p_pbm_attribute19                =>  p_pbm_attribute19
      ,p_pbm_attribute20                =>  p_pbm_attribute20
      ,p_pbm_attribute21                =>  p_pbm_attribute21
      ,p_pbm_attribute22                =>  p_pbm_attribute22
      ,p_pbm_attribute23                =>  p_pbm_attribute23
      ,p_pbm_attribute24                =>  p_pbm_attribute24
      ,p_pbm_attribute25                =>  p_pbm_attribute25
      ,p_pbm_attribute26                =>  p_pbm_attribute26
      ,p_pbm_attribute27                =>  p_pbm_attribute27
      ,p_pbm_attribute28                =>  p_pbm_attribute28
      ,p_pbm_attribute29                =>  p_pbm_attribute29
      ,p_pbm_attribute30                =>  p_pbm_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_request_id                     => p_request_id
      ,p_program_id                     => p_program_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_update_date            => p_program_update_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PL_R_OIPL_PREM_BY_MO'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PL_R_OIPL_PREM_BY_MO
    --
  end;
  --
  ben_pbm_ins.ins
    (
     p_pl_r_oipl_prem_by_mo_id       => l_pl_r_oipl_prem_by_mo_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_mnl_adj_flag                  => p_mnl_adj_flag
    ,p_mo_num                        => p_mo_num
    ,p_yr_num                        => p_yr_num
    ,p_val                           => p_val
    ,p_uom                           => p_uom
    ,p_prtts_num                     => p_prtts_num
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
    ,p_business_group_id             => p_business_group_id
    ,p_pbm_attribute_category        => p_pbm_attribute_category
    ,p_pbm_attribute1                => p_pbm_attribute1
    ,p_pbm_attribute2                => p_pbm_attribute2
    ,p_pbm_attribute3                => p_pbm_attribute3
    ,p_pbm_attribute4                => p_pbm_attribute4
    ,p_pbm_attribute5                => p_pbm_attribute5
    ,p_pbm_attribute6                => p_pbm_attribute6
    ,p_pbm_attribute7                => p_pbm_attribute7
    ,p_pbm_attribute8                => p_pbm_attribute8
    ,p_pbm_attribute9                => p_pbm_attribute9
    ,p_pbm_attribute10               => p_pbm_attribute10
    ,p_pbm_attribute11               => p_pbm_attribute11
    ,p_pbm_attribute12               => p_pbm_attribute12
    ,p_pbm_attribute13               => p_pbm_attribute13
    ,p_pbm_attribute14               => p_pbm_attribute14
    ,p_pbm_attribute15               => p_pbm_attribute15
    ,p_pbm_attribute16               => p_pbm_attribute16
    ,p_pbm_attribute17               => p_pbm_attribute17
    ,p_pbm_attribute18               => p_pbm_attribute18
    ,p_pbm_attribute19               => p_pbm_attribute19
    ,p_pbm_attribute20               => p_pbm_attribute20
    ,p_pbm_attribute21               => p_pbm_attribute21
    ,p_pbm_attribute22               => p_pbm_attribute22
    ,p_pbm_attribute23               => p_pbm_attribute23
    ,p_pbm_attribute24               => p_pbm_attribute24
    ,p_pbm_attribute25               => p_pbm_attribute25
    ,p_pbm_attribute26               => p_pbm_attribute26
    ,p_pbm_attribute27               => p_pbm_attribute27
    ,p_pbm_attribute28               => p_pbm_attribute28
    ,p_pbm_attribute29               => p_pbm_attribute29
    ,p_pbm_attribute30               => p_pbm_attribute30
    ,p_object_version_number         => l_object_version_number
      ,p_request_id                     => p_request_id
      ,p_program_id                     => p_program_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_update_date            => p_program_update_date
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PL_R_OIPL_PREM_BY_MO
    --
    ben_PL_R_OIPL_PREM_BY_MO_bk1.create_PL_R_OIPL_PREM_BY_MO_a
      (
       p_pl_r_oipl_prem_by_mo_id        =>  l_pl_r_oipl_prem_by_mo_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_mnl_adj_flag                   =>  p_mnl_adj_flag
      ,p_mo_num                         =>  p_mo_num
      ,p_yr_num                         =>  p_yr_num
      ,p_val                            =>  p_val
      ,p_uom                            =>  p_uom
      ,p_prtts_num                      =>  p_prtts_num
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbm_attribute_category         =>  p_pbm_attribute_category
      ,p_pbm_attribute1                 =>  p_pbm_attribute1
      ,p_pbm_attribute2                 =>  p_pbm_attribute2
      ,p_pbm_attribute3                 =>  p_pbm_attribute3
      ,p_pbm_attribute4                 =>  p_pbm_attribute4
      ,p_pbm_attribute5                 =>  p_pbm_attribute5
      ,p_pbm_attribute6                 =>  p_pbm_attribute6
      ,p_pbm_attribute7                 =>  p_pbm_attribute7
      ,p_pbm_attribute8                 =>  p_pbm_attribute8
      ,p_pbm_attribute9                 =>  p_pbm_attribute9
      ,p_pbm_attribute10                =>  p_pbm_attribute10
      ,p_pbm_attribute11                =>  p_pbm_attribute11
      ,p_pbm_attribute12                =>  p_pbm_attribute12
      ,p_pbm_attribute13                =>  p_pbm_attribute13
      ,p_pbm_attribute14                =>  p_pbm_attribute14
      ,p_pbm_attribute15                =>  p_pbm_attribute15
      ,p_pbm_attribute16                =>  p_pbm_attribute16
      ,p_pbm_attribute17                =>  p_pbm_attribute17
      ,p_pbm_attribute18                =>  p_pbm_attribute18
      ,p_pbm_attribute19                =>  p_pbm_attribute19
      ,p_pbm_attribute20                =>  p_pbm_attribute20
      ,p_pbm_attribute21                =>  p_pbm_attribute21
      ,p_pbm_attribute22                =>  p_pbm_attribute22
      ,p_pbm_attribute23                =>  p_pbm_attribute23
      ,p_pbm_attribute24                =>  p_pbm_attribute24
      ,p_pbm_attribute25                =>  p_pbm_attribute25
      ,p_pbm_attribute26                =>  p_pbm_attribute26
      ,p_pbm_attribute27                =>  p_pbm_attribute27
      ,p_pbm_attribute28                =>  p_pbm_attribute28
      ,p_pbm_attribute29                =>  p_pbm_attribute29
      ,p_pbm_attribute30                =>  p_pbm_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     => p_request_id
      ,p_program_id                     => p_program_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_update_date            => p_program_update_date
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PL_R_OIPL_PREM_BY_MO'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PL_R_OIPL_PREM_BY_MO
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
  p_pl_r_oipl_prem_by_mo_id := l_pl_r_oipl_prem_by_mo_id;
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
    ROLLBACK TO create_PL_R_OIPL_PREM_BY_MO;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_r_oipl_prem_by_mo_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PL_R_OIPL_PREM_BY_MO;
    p_pl_r_oipl_prem_by_mo_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_PL_R_OIPL_PREM_BY_MO;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PL_R_OIPL_PREM_BY_MO >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PL_R_OIPL_PREM_BY_MO
  (p_validate                       in  boolean   default false
  ,p_pl_r_oipl_prem_by_mo_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_mnl_adj_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_mo_num                         in  number    default hr_api.g_number
  ,p_yr_num                         in  number    default hr_api.g_number
  ,p_val                            in  number    default hr_api.g_number
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_prtts_num                      in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_cost_allocation_keyflex_id    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pbm_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pbm_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in number default hr_api.g_number
  ,p_program_id                     in number default hr_api.g_number
  ,p_program_application_id         in number default hr_api.g_number
  ,p_program_update_date            in date default hr_api.g_date
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PL_R_OIPL_PREM_BY_MO';
  l_object_version_number ben_pl_r_oipl_prem_by_mo_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_r_oipl_prem_by_mo_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_r_oipl_prem_by_mo_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PL_R_OIPL_PREM_BY_MO;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PL_R_OIPL_PREM_BY_MO
    --
    ben_PL_R_OIPL_PREM_BY_MO_bk2.update_PL_R_OIPL_PREM_BY_MO_b
      (
       p_pl_r_oipl_prem_by_mo_id        =>  p_pl_r_oipl_prem_by_mo_id
      ,p_mnl_adj_flag                   =>  p_mnl_adj_flag
      ,p_mo_num                         =>  p_mo_num
      ,p_yr_num                         =>  p_yr_num
      ,p_val                            =>  p_val
      ,p_uom                            =>  p_uom
      ,p_prtts_num                      =>  p_prtts_num
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbm_attribute_category         =>  p_pbm_attribute_category
      ,p_pbm_attribute1                 =>  p_pbm_attribute1
      ,p_pbm_attribute2                 =>  p_pbm_attribute2
      ,p_pbm_attribute3                 =>  p_pbm_attribute3
      ,p_pbm_attribute4                 =>  p_pbm_attribute4
      ,p_pbm_attribute5                 =>  p_pbm_attribute5
      ,p_pbm_attribute6                 =>  p_pbm_attribute6
      ,p_pbm_attribute7                 =>  p_pbm_attribute7
      ,p_pbm_attribute8                 =>  p_pbm_attribute8
      ,p_pbm_attribute9                 =>  p_pbm_attribute9
      ,p_pbm_attribute10                =>  p_pbm_attribute10
      ,p_pbm_attribute11                =>  p_pbm_attribute11
      ,p_pbm_attribute12                =>  p_pbm_attribute12
      ,p_pbm_attribute13                =>  p_pbm_attribute13
      ,p_pbm_attribute14                =>  p_pbm_attribute14
      ,p_pbm_attribute15                =>  p_pbm_attribute15
      ,p_pbm_attribute16                =>  p_pbm_attribute16
      ,p_pbm_attribute17                =>  p_pbm_attribute17
      ,p_pbm_attribute18                =>  p_pbm_attribute18
      ,p_pbm_attribute19                =>  p_pbm_attribute19
      ,p_pbm_attribute20                =>  p_pbm_attribute20
      ,p_pbm_attribute21                =>  p_pbm_attribute21
      ,p_pbm_attribute22                =>  p_pbm_attribute22
      ,p_pbm_attribute23                =>  p_pbm_attribute23
      ,p_pbm_attribute24                =>  p_pbm_attribute24
      ,p_pbm_attribute25                =>  p_pbm_attribute25
      ,p_pbm_attribute26                =>  p_pbm_attribute26
      ,p_pbm_attribute27                =>  p_pbm_attribute27
      ,p_pbm_attribute28                =>  p_pbm_attribute28
      ,p_pbm_attribute29                =>  p_pbm_attribute29
      ,p_pbm_attribute30                =>  p_pbm_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_request_id                     => p_request_id
      ,p_program_id                     => p_program_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_update_date            => p_program_update_date
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PL_R_OIPL_PREM_BY_MO'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PL_R_OIPL_PREM_BY_MO
    --
  end;
  --
  ben_pbm_upd.upd
    (
     p_pl_r_oipl_prem_by_mo_id       => p_pl_r_oipl_prem_by_mo_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_mnl_adj_flag                  => p_mnl_adj_flag
    ,p_mo_num                        => p_mo_num
    ,p_yr_num                        => p_yr_num
    ,p_val                           => p_val
    ,p_uom                           => p_uom
    ,p_prtts_num                     => p_prtts_num
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
    ,p_business_group_id             => p_business_group_id
    ,p_pbm_attribute_category        => p_pbm_attribute_category
    ,p_pbm_attribute1                => p_pbm_attribute1
    ,p_pbm_attribute2                => p_pbm_attribute2
    ,p_pbm_attribute3                => p_pbm_attribute3
    ,p_pbm_attribute4                => p_pbm_attribute4
    ,p_pbm_attribute5                => p_pbm_attribute5
    ,p_pbm_attribute6                => p_pbm_attribute6
    ,p_pbm_attribute7                => p_pbm_attribute7
    ,p_pbm_attribute8                => p_pbm_attribute8
    ,p_pbm_attribute9                => p_pbm_attribute9
    ,p_pbm_attribute10               => p_pbm_attribute10
    ,p_pbm_attribute11               => p_pbm_attribute11
    ,p_pbm_attribute12               => p_pbm_attribute12
    ,p_pbm_attribute13               => p_pbm_attribute13
    ,p_pbm_attribute14               => p_pbm_attribute14
    ,p_pbm_attribute15               => p_pbm_attribute15
    ,p_pbm_attribute16               => p_pbm_attribute16
    ,p_pbm_attribute17               => p_pbm_attribute17
    ,p_pbm_attribute18               => p_pbm_attribute18
    ,p_pbm_attribute19               => p_pbm_attribute19
    ,p_pbm_attribute20               => p_pbm_attribute20
    ,p_pbm_attribute21               => p_pbm_attribute21
    ,p_pbm_attribute22               => p_pbm_attribute22
    ,p_pbm_attribute23               => p_pbm_attribute23
    ,p_pbm_attribute24               => p_pbm_attribute24
    ,p_pbm_attribute25               => p_pbm_attribute25
    ,p_pbm_attribute26               => p_pbm_attribute26
    ,p_pbm_attribute27               => p_pbm_attribute27
    ,p_pbm_attribute28               => p_pbm_attribute28
    ,p_pbm_attribute29               => p_pbm_attribute29
    ,p_pbm_attribute30               => p_pbm_attribute30
    ,p_object_version_number         => l_object_version_number
      ,p_request_id                     => p_request_id
      ,p_program_id                     => p_program_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_update_date            => p_program_update_date
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PL_R_OIPL_PREM_BY_MO
    --
    ben_PL_R_OIPL_PREM_BY_MO_bk2.update_PL_R_OIPL_PREM_BY_MO_a
      (
       p_pl_r_oipl_prem_by_mo_id        =>  p_pl_r_oipl_prem_by_mo_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_mnl_adj_flag                   =>  p_mnl_adj_flag
      ,p_mo_num                         =>  p_mo_num
      ,p_yr_num                         =>  p_yr_num
      ,p_val                            =>  p_val
      ,p_uom                            =>  p_uom
      ,p_prtts_num                      =>  p_prtts_num
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbm_attribute_category         =>  p_pbm_attribute_category
      ,p_pbm_attribute1                 =>  p_pbm_attribute1
      ,p_pbm_attribute2                 =>  p_pbm_attribute2
      ,p_pbm_attribute3                 =>  p_pbm_attribute3
      ,p_pbm_attribute4                 =>  p_pbm_attribute4
      ,p_pbm_attribute5                 =>  p_pbm_attribute5
      ,p_pbm_attribute6                 =>  p_pbm_attribute6
      ,p_pbm_attribute7                 =>  p_pbm_attribute7
      ,p_pbm_attribute8                 =>  p_pbm_attribute8
      ,p_pbm_attribute9                 =>  p_pbm_attribute9
      ,p_pbm_attribute10                =>  p_pbm_attribute10
      ,p_pbm_attribute11                =>  p_pbm_attribute11
      ,p_pbm_attribute12                =>  p_pbm_attribute12
      ,p_pbm_attribute13                =>  p_pbm_attribute13
      ,p_pbm_attribute14                =>  p_pbm_attribute14
      ,p_pbm_attribute15                =>  p_pbm_attribute15
      ,p_pbm_attribute16                =>  p_pbm_attribute16
      ,p_pbm_attribute17                =>  p_pbm_attribute17
      ,p_pbm_attribute18                =>  p_pbm_attribute18
      ,p_pbm_attribute19                =>  p_pbm_attribute19
      ,p_pbm_attribute20                =>  p_pbm_attribute20
      ,p_pbm_attribute21                =>  p_pbm_attribute21
      ,p_pbm_attribute22                =>  p_pbm_attribute22
      ,p_pbm_attribute23                =>  p_pbm_attribute23
      ,p_pbm_attribute24                =>  p_pbm_attribute24
      ,p_pbm_attribute25                =>  p_pbm_attribute25
      ,p_pbm_attribute26                =>  p_pbm_attribute26
      ,p_pbm_attribute27                =>  p_pbm_attribute27
      ,p_pbm_attribute28                =>  p_pbm_attribute28
      ,p_pbm_attribute29                =>  p_pbm_attribute29
      ,p_pbm_attribute30                =>  p_pbm_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     => p_request_id
      ,p_program_id                     => p_program_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_update_date            => p_program_update_date
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PL_R_OIPL_PREM_BY_MO'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PL_R_OIPL_PREM_BY_MO
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
    ROLLBACK TO update_PL_R_OIPL_PREM_BY_MO;
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
    ROLLBACK TO update_PL_R_OIPL_PREM_BY_MO;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_PL_R_OIPL_PREM_BY_MO;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PL_R_OIPL_PREM_BY_MO >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PL_R_OIPL_PREM_BY_MO
  (p_validate                       in  boolean  default false
  ,p_pl_r_oipl_prem_by_mo_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PL_R_OIPL_PREM_BY_MO';
  l_object_version_number ben_pl_r_oipl_prem_by_mo_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_r_oipl_prem_by_mo_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_r_oipl_prem_by_mo_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PL_R_OIPL_PREM_BY_MO;
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
    -- Start of API User Hook for the before hook of delete_PL_R_OIPL_PREM_BY_MO
    --
    ben_PL_R_OIPL_PREM_BY_MO_bk3.delete_PL_R_OIPL_PREM_BY_MO_b
      (
       p_pl_r_oipl_prem_by_mo_id        =>  p_pl_r_oipl_prem_by_mo_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PL_R_OIPL_PREM_BY_MO'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PL_R_OIPL_PREM_BY_MO
    --
  end;
  --
  ben_pbm_del.del
    (
     p_pl_r_oipl_prem_by_mo_id       => p_pl_r_oipl_prem_by_mo_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PL_R_OIPL_PREM_BY_MO
    --
    ben_PL_R_OIPL_PREM_BY_MO_bk3.delete_PL_R_OIPL_PREM_BY_MO_a
      (
       p_pl_r_oipl_prem_by_mo_id        =>  p_pl_r_oipl_prem_by_mo_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PL_R_OIPL_PREM_BY_MO'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PL_R_OIPL_PREM_BY_MO
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
    ROLLBACK TO delete_PL_R_OIPL_PREM_BY_MO;
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
    ROLLBACK TO delete_PL_R_OIPL_PREM_BY_MO;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_PL_R_OIPL_PREM_BY_MO;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_r_oipl_prem_by_mo_id                   in     number
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
  ben_pbm_shd.lck
    (
      p_pl_r_oipl_prem_by_mo_id                 => p_pl_r_oipl_prem_by_mo_id
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
end ben_PL_R_OIPL_PREM_BY_MO_api;

/
