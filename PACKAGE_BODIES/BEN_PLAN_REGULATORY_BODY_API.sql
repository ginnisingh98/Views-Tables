--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_REGULATORY_BODY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_REGULATORY_BODY_API" as
/* $Header: beprbapi.pkb 115.3 2002/12/13 06:55:12 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Plan_Regulatory_body_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Plan_Regulatory_body >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Plan_Regulatory_body
  (p_validate                       in  boolean   default false
  ,p_pl_regy_bod_id                 out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_rptg_grp_id                    in  number    default null
  ,p_quald_dt                       in  date      default null
  ,p_quald_flag                     in  varchar2  default null
  ,p_regy_pl_name                   in  varchar2  default null
  ,p_aprvd_trmn_dt                  in  date      default null
  ,p_prb_attribute_category         in  varchar2  default null
  ,p_prb_attribute1                 in  varchar2  default null
  ,p_prb_attribute2                 in  varchar2  default null
  ,p_prb_attribute3                 in  varchar2  default null
  ,p_prb_attribute4                 in  varchar2  default null
  ,p_prb_attribute5                 in  varchar2  default null
  ,p_prb_attribute6                 in  varchar2  default null
  ,p_prb_attribute7                 in  varchar2  default null
  ,p_prb_attribute8                 in  varchar2  default null
  ,p_prb_attribute9                 in  varchar2  default null
  ,p_prb_attribute10                in  varchar2  default null
  ,p_prb_attribute11                in  varchar2  default null
  ,p_prb_attribute12                in  varchar2  default null
  ,p_prb_attribute13                in  varchar2  default null
  ,p_prb_attribute14                in  varchar2  default null
  ,p_prb_attribute15                in  varchar2  default null
  ,p_prb_attribute16                in  varchar2  default null
  ,p_prb_attribute17                in  varchar2  default null
  ,p_prb_attribute18                in  varchar2  default null
  ,p_prb_attribute19                in  varchar2  default null
  ,p_prb_attribute20                in  varchar2  default null
  ,p_prb_attribute21                in  varchar2  default null
  ,p_prb_attribute22                in  varchar2  default null
  ,p_prb_attribute23                in  varchar2  default null
  ,p_prb_attribute24                in  varchar2  default null
  ,p_prb_attribute25                in  varchar2  default null
  ,p_prb_attribute26                in  varchar2  default null
  ,p_prb_attribute27                in  varchar2  default null
  ,p_prb_attribute28                in  varchar2  default null
  ,p_prb_attribute29                in  varchar2  default null
  ,p_prb_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_regy_bod_id ben_pl_regy_bod_f.pl_regy_bod_id%TYPE;
  l_effective_start_date ben_pl_regy_bod_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_regy_bod_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Plan_Regulatory_body';
  l_object_version_number ben_pl_regy_bod_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    savepoint create_Plan_Regulatory_body;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Plan_Regulatory_body
    --
    ben_Plan_Regulatory_body_bk1.create_Plan_Regulatory_body_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_quald_dt                       =>  p_quald_dt
      ,p_quald_flag                     =>  p_quald_flag
      ,p_regy_pl_name                   =>  p_regy_pl_name
      ,p_aprvd_trmn_dt                  =>  p_aprvd_trmn_dt
      ,p_prb_attribute_category         =>  p_prb_attribute_category
      ,p_prb_attribute1                 =>  p_prb_attribute1
      ,p_prb_attribute2                 =>  p_prb_attribute2
      ,p_prb_attribute3                 =>  p_prb_attribute3
      ,p_prb_attribute4                 =>  p_prb_attribute4
      ,p_prb_attribute5                 =>  p_prb_attribute5
      ,p_prb_attribute6                 =>  p_prb_attribute6
      ,p_prb_attribute7                 =>  p_prb_attribute7
      ,p_prb_attribute8                 =>  p_prb_attribute8
      ,p_prb_attribute9                 =>  p_prb_attribute9
      ,p_prb_attribute10                =>  p_prb_attribute10
      ,p_prb_attribute11                =>  p_prb_attribute11
      ,p_prb_attribute12                =>  p_prb_attribute12
      ,p_prb_attribute13                =>  p_prb_attribute13
      ,p_prb_attribute14                =>  p_prb_attribute14
      ,p_prb_attribute15                =>  p_prb_attribute15
      ,p_prb_attribute16                =>  p_prb_attribute16
      ,p_prb_attribute17                =>  p_prb_attribute17
      ,p_prb_attribute18                =>  p_prb_attribute18
      ,p_prb_attribute19                =>  p_prb_attribute19
      ,p_prb_attribute20                =>  p_prb_attribute20
      ,p_prb_attribute21                =>  p_prb_attribute21
      ,p_prb_attribute22                =>  p_prb_attribute22
      ,p_prb_attribute23                =>  p_prb_attribute23
      ,p_prb_attribute24                =>  p_prb_attribute24
      ,p_prb_attribute25                =>  p_prb_attribute25
      ,p_prb_attribute26                =>  p_prb_attribute26
      ,p_prb_attribute27                =>  p_prb_attribute27
      ,p_prb_attribute28                =>  p_prb_attribute28
      ,p_prb_attribute29                =>  p_prb_attribute29
      ,p_prb_attribute30                =>  p_prb_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Plan_Regulatory_body'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Plan_Regulatory_body
    --
  end;
  --
  ben_prb_ins.ins
    (
     p_pl_regy_bod_id                => l_pl_regy_bod_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_rptg_grp_id                   => p_rptg_grp_id
    ,p_quald_dt                      => p_quald_dt
    ,p_quald_flag                    => p_quald_flag
    ,p_regy_pl_name                  => p_regy_pl_name
    ,p_aprvd_trmn_dt                 => p_aprvd_trmn_dt
    ,p_prb_attribute_category        => p_prb_attribute_category
    ,p_prb_attribute1                => p_prb_attribute1
    ,p_prb_attribute2                => p_prb_attribute2
    ,p_prb_attribute3                => p_prb_attribute3
    ,p_prb_attribute4                => p_prb_attribute4
    ,p_prb_attribute5                => p_prb_attribute5
    ,p_prb_attribute6                => p_prb_attribute6
    ,p_prb_attribute7                => p_prb_attribute7
    ,p_prb_attribute8                => p_prb_attribute8
    ,p_prb_attribute9                => p_prb_attribute9
    ,p_prb_attribute10               => p_prb_attribute10
    ,p_prb_attribute11               => p_prb_attribute11
    ,p_prb_attribute12               => p_prb_attribute12
    ,p_prb_attribute13               => p_prb_attribute13
    ,p_prb_attribute14               => p_prb_attribute14
    ,p_prb_attribute15               => p_prb_attribute15
    ,p_prb_attribute16               => p_prb_attribute16
    ,p_prb_attribute17               => p_prb_attribute17
    ,p_prb_attribute18               => p_prb_attribute18
    ,p_prb_attribute19               => p_prb_attribute19
    ,p_prb_attribute20               => p_prb_attribute20
    ,p_prb_attribute21               => p_prb_attribute21
    ,p_prb_attribute22               => p_prb_attribute22
    ,p_prb_attribute23               => p_prb_attribute23
    ,p_prb_attribute24               => p_prb_attribute24
    ,p_prb_attribute25               => p_prb_attribute25
    ,p_prb_attribute26               => p_prb_attribute26
    ,p_prb_attribute27               => p_prb_attribute27
    ,p_prb_attribute28               => p_prb_attribute28
    ,p_prb_attribute29               => p_prb_attribute29
    ,p_prb_attribute30               => p_prb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Plan_Regulatory_body
    --
    ben_Plan_Regulatory_body_bk1.create_Plan_Regulatory_body_a
      (
       p_pl_regy_bod_id                 =>  l_pl_regy_bod_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_quald_dt                       =>  p_quald_dt
      ,p_quald_flag                     =>  p_quald_flag
      ,p_regy_pl_name                   =>  p_regy_pl_name
      ,p_aprvd_trmn_dt                  =>  p_aprvd_trmn_dt
      ,p_prb_attribute_category         =>  p_prb_attribute_category
      ,p_prb_attribute1                 =>  p_prb_attribute1
      ,p_prb_attribute2                 =>  p_prb_attribute2
      ,p_prb_attribute3                 =>  p_prb_attribute3
      ,p_prb_attribute4                 =>  p_prb_attribute4
      ,p_prb_attribute5                 =>  p_prb_attribute5
      ,p_prb_attribute6                 =>  p_prb_attribute6
      ,p_prb_attribute7                 =>  p_prb_attribute7
      ,p_prb_attribute8                 =>  p_prb_attribute8
      ,p_prb_attribute9                 =>  p_prb_attribute9
      ,p_prb_attribute10                =>  p_prb_attribute10
      ,p_prb_attribute11                =>  p_prb_attribute11
      ,p_prb_attribute12                =>  p_prb_attribute12
      ,p_prb_attribute13                =>  p_prb_attribute13
      ,p_prb_attribute14                =>  p_prb_attribute14
      ,p_prb_attribute15                =>  p_prb_attribute15
      ,p_prb_attribute16                =>  p_prb_attribute16
      ,p_prb_attribute17                =>  p_prb_attribute17
      ,p_prb_attribute18                =>  p_prb_attribute18
      ,p_prb_attribute19                =>  p_prb_attribute19
      ,p_prb_attribute20                =>  p_prb_attribute20
      ,p_prb_attribute21                =>  p_prb_attribute21
      ,p_prb_attribute22                =>  p_prb_attribute22
      ,p_prb_attribute23                =>  p_prb_attribute23
      ,p_prb_attribute24                =>  p_prb_attribute24
      ,p_prb_attribute25                =>  p_prb_attribute25
      ,p_prb_attribute26                =>  p_prb_attribute26
      ,p_prb_attribute27                =>  p_prb_attribute27
      ,p_prb_attribute28                =>  p_prb_attribute28
      ,p_prb_attribute29                =>  p_prb_attribute29
      ,p_prb_attribute30                =>  p_prb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Plan_Regulatory_body'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Plan_Regulatory_body
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
  p_pl_regy_bod_id := l_pl_regy_bod_id;
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
    ROLLBACK TO create_Plan_Regulatory_body;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_regy_bod_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
end create_Plan_Regulatory_body;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Plan_Regulatory_body >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_Regulatory_body
  (p_validate                       in  boolean   default false
  ,p_pl_regy_bod_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_rptg_grp_id                    in  number    default hr_api.g_number
  ,p_quald_dt                       in  date      default hr_api.g_date
  ,p_quald_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_regy_pl_name                   in  varchar2  default hr_api.g_varchar2
  ,p_aprvd_trmn_dt                  in  date      default hr_api.g_date
  ,p_prb_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prb_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan_Regulatory_body';
  l_object_version_number ben_pl_regy_bod_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_regy_bod_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_regy_bod_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    savepoint update_Plan_Regulatory_body;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Plan_Regulatory_body
    --
    ben_Plan_Regulatory_body_bk2.update_Plan_Regulatory_body_b
      (
       p_pl_regy_bod_id                 =>  p_pl_regy_bod_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_quald_dt                       =>  p_quald_dt
      ,p_quald_flag                     =>  p_quald_flag
      ,p_regy_pl_name                   =>  p_regy_pl_name
      ,p_aprvd_trmn_dt                  =>  p_aprvd_trmn_dt
      ,p_prb_attribute_category         =>  p_prb_attribute_category
      ,p_prb_attribute1                 =>  p_prb_attribute1
      ,p_prb_attribute2                 =>  p_prb_attribute2
      ,p_prb_attribute3                 =>  p_prb_attribute3
      ,p_prb_attribute4                 =>  p_prb_attribute4
      ,p_prb_attribute5                 =>  p_prb_attribute5
      ,p_prb_attribute6                 =>  p_prb_attribute6
      ,p_prb_attribute7                 =>  p_prb_attribute7
      ,p_prb_attribute8                 =>  p_prb_attribute8
      ,p_prb_attribute9                 =>  p_prb_attribute9
      ,p_prb_attribute10                =>  p_prb_attribute10
      ,p_prb_attribute11                =>  p_prb_attribute11
      ,p_prb_attribute12                =>  p_prb_attribute12
      ,p_prb_attribute13                =>  p_prb_attribute13
      ,p_prb_attribute14                =>  p_prb_attribute14
      ,p_prb_attribute15                =>  p_prb_attribute15
      ,p_prb_attribute16                =>  p_prb_attribute16
      ,p_prb_attribute17                =>  p_prb_attribute17
      ,p_prb_attribute18                =>  p_prb_attribute18
      ,p_prb_attribute19                =>  p_prb_attribute19
      ,p_prb_attribute20                =>  p_prb_attribute20
      ,p_prb_attribute21                =>  p_prb_attribute21
      ,p_prb_attribute22                =>  p_prb_attribute22
      ,p_prb_attribute23                =>  p_prb_attribute23
      ,p_prb_attribute24                =>  p_prb_attribute24
      ,p_prb_attribute25                =>  p_prb_attribute25
      ,p_prb_attribute26                =>  p_prb_attribute26
      ,p_prb_attribute27                =>  p_prb_attribute27
      ,p_prb_attribute28                =>  p_prb_attribute28
      ,p_prb_attribute29                =>  p_prb_attribute29
      ,p_prb_attribute30                =>  p_prb_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_Regulatory_body'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Plan_Regulatory_body
    --
  end;
  --
  ben_prb_upd.upd
    (
     p_pl_regy_bod_id                => p_pl_regy_bod_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_rptg_grp_id                   => p_rptg_grp_id
    ,p_quald_dt                      => p_quald_dt
    ,p_quald_flag                    => p_quald_flag
    ,p_regy_pl_name                  => p_regy_pl_name
    ,p_aprvd_trmn_dt                 => p_aprvd_trmn_dt
    ,p_prb_attribute_category        => p_prb_attribute_category
    ,p_prb_attribute1                => p_prb_attribute1
    ,p_prb_attribute2                => p_prb_attribute2
    ,p_prb_attribute3                => p_prb_attribute3
    ,p_prb_attribute4                => p_prb_attribute4
    ,p_prb_attribute5                => p_prb_attribute5
    ,p_prb_attribute6                => p_prb_attribute6
    ,p_prb_attribute7                => p_prb_attribute7
    ,p_prb_attribute8                => p_prb_attribute8
    ,p_prb_attribute9                => p_prb_attribute9
    ,p_prb_attribute10               => p_prb_attribute10
    ,p_prb_attribute11               => p_prb_attribute11
    ,p_prb_attribute12               => p_prb_attribute12
    ,p_prb_attribute13               => p_prb_attribute13
    ,p_prb_attribute14               => p_prb_attribute14
    ,p_prb_attribute15               => p_prb_attribute15
    ,p_prb_attribute16               => p_prb_attribute16
    ,p_prb_attribute17               => p_prb_attribute17
    ,p_prb_attribute18               => p_prb_attribute18
    ,p_prb_attribute19               => p_prb_attribute19
    ,p_prb_attribute20               => p_prb_attribute20
    ,p_prb_attribute21               => p_prb_attribute21
    ,p_prb_attribute22               => p_prb_attribute22
    ,p_prb_attribute23               => p_prb_attribute23
    ,p_prb_attribute24               => p_prb_attribute24
    ,p_prb_attribute25               => p_prb_attribute25
    ,p_prb_attribute26               => p_prb_attribute26
    ,p_prb_attribute27               => p_prb_attribute27
    ,p_prb_attribute28               => p_prb_attribute28
    ,p_prb_attribute29               => p_prb_attribute29
    ,p_prb_attribute30               => p_prb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Plan_Regulatory_body
    --
    ben_Plan_Regulatory_body_bk2.update_Plan_Regulatory_body_a
      (
       p_pl_regy_bod_id                 =>  p_pl_regy_bod_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_quald_dt                       =>  p_quald_dt
      ,p_quald_flag                     =>  p_quald_flag
      ,p_regy_pl_name                   =>  p_regy_pl_name
      ,p_aprvd_trmn_dt                  =>  p_aprvd_trmn_dt
      ,p_prb_attribute_category         =>  p_prb_attribute_category
      ,p_prb_attribute1                 =>  p_prb_attribute1
      ,p_prb_attribute2                 =>  p_prb_attribute2
      ,p_prb_attribute3                 =>  p_prb_attribute3
      ,p_prb_attribute4                 =>  p_prb_attribute4
      ,p_prb_attribute5                 =>  p_prb_attribute5
      ,p_prb_attribute6                 =>  p_prb_attribute6
      ,p_prb_attribute7                 =>  p_prb_attribute7
      ,p_prb_attribute8                 =>  p_prb_attribute8
      ,p_prb_attribute9                 =>  p_prb_attribute9
      ,p_prb_attribute10                =>  p_prb_attribute10
      ,p_prb_attribute11                =>  p_prb_attribute11
      ,p_prb_attribute12                =>  p_prb_attribute12
      ,p_prb_attribute13                =>  p_prb_attribute13
      ,p_prb_attribute14                =>  p_prb_attribute14
      ,p_prb_attribute15                =>  p_prb_attribute15
      ,p_prb_attribute16                =>  p_prb_attribute16
      ,p_prb_attribute17                =>  p_prb_attribute17
      ,p_prb_attribute18                =>  p_prb_attribute18
      ,p_prb_attribute19                =>  p_prb_attribute19
      ,p_prb_attribute20                =>  p_prb_attribute20
      ,p_prb_attribute21                =>  p_prb_attribute21
      ,p_prb_attribute22                =>  p_prb_attribute22
      ,p_prb_attribute23                =>  p_prb_attribute23
      ,p_prb_attribute24                =>  p_prb_attribute24
      ,p_prb_attribute25                =>  p_prb_attribute25
      ,p_prb_attribute26                =>  p_prb_attribute26
      ,p_prb_attribute27                =>  p_prb_attribute27
      ,p_prb_attribute28                =>  p_prb_attribute28
      ,p_prb_attribute29                =>  p_prb_attribute29
      ,p_prb_attribute30                =>  p_prb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_Regulatory_body'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Plan_Regulatory_body
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
    ROLLBACK TO update_Plan_Regulatory_body;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
end update_Plan_Regulatory_body;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Plan_Regulatory_body >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_Regulatory_body
  (p_validate                       in  boolean  default false
  ,p_pl_regy_bod_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan_Regulatory_body';
  l_object_version_number ben_pl_regy_bod_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_regy_bod_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_regy_bod_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    savepoint delete_Plan_Regulatory_body;
  end if;
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
    -- Start of API User Hook for the before hook of delete_Plan_Regulatory_body
    --
    ben_Plan_Regulatory_body_bk3.delete_Plan_Regulatory_body_b
      (
       p_pl_regy_bod_id                 =>  p_pl_regy_bod_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_Regulatory_body'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Plan_Regulatory_body
    --
  end;
  --
  ben_prb_del.del
    (
     p_pl_regy_bod_id                => p_pl_regy_bod_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Plan_Regulatory_body
    --
    ben_Plan_Regulatory_body_bk3.delete_Plan_Regulatory_body_a
      (
       p_pl_regy_bod_id                 =>  p_pl_regy_bod_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_Regulatory_body'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Plan_Regulatory_body
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
    ROLLBACK TO delete_Plan_Regulatory_body;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
end delete_Plan_Regulatory_body;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_regy_bod_id                   in     number
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
  ben_prb_shd.lck
    (
      p_pl_regy_bod_id                 => p_pl_regy_bod_id
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
end ben_Plan_Regulatory_body_api;

/
