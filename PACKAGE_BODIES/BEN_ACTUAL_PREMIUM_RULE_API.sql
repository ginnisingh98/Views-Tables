--------------------------------------------------------
--  DDL for Package Body BEN_ACTUAL_PREMIUM_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ACTUAL_PREMIUM_RULE_API" as
/* $Header: beavaapi.pkb 120.0 2005/05/28 00:31:27 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_actual_premium_rule_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_actual_premium_rule >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_actual_premium_rule
  (p_validate                       in  boolean   default false
  ,p_actl_prem_vrbl_rt_rl_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_actl_prem_id                   in  number    default null
  ,p_formula_id                     in  number    default null
  ,p_ordr_to_aply_num               in  number    default null
  ,p_rt_trtmt_cd                    in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_ava_attribute_category         in  varchar2  default null
  ,p_ava_attribute1                 in  varchar2  default null
  ,p_ava_attribute2                 in  varchar2  default null
  ,p_ava_attribute3                 in  varchar2  default null
  ,p_ava_attribute4                 in  varchar2  default null
  ,p_ava_attribute5                 in  varchar2  default null
  ,p_ava_attribute6                 in  varchar2  default null
  ,p_ava_attribute7                 in  varchar2  default null
  ,p_ava_attribute8                 in  varchar2  default null
  ,p_ava_attribute9                 in  varchar2  default null
  ,p_ava_attribute10                in  varchar2  default null
  ,p_ava_attribute11                in  varchar2  default null
  ,p_ava_attribute12                in  varchar2  default null
  ,p_ava_attribute13                in  varchar2  default null
  ,p_ava_attribute14                in  varchar2  default null
  ,p_ava_attribute15                in  varchar2  default null
  ,p_ava_attribute16                in  varchar2  default null
  ,p_ava_attribute17                in  varchar2  default null
  ,p_ava_attribute18                in  varchar2  default null
  ,p_ava_attribute19                in  varchar2  default null
  ,p_ava_attribute20                in  varchar2  default null
  ,p_ava_attribute21                in  varchar2  default null
  ,p_ava_attribute22                in  varchar2  default null
  ,p_ava_attribute23                in  varchar2  default null
  ,p_ava_attribute24                in  varchar2  default null
  ,p_ava_attribute25                in  varchar2  default null
  ,p_ava_attribute26                in  varchar2  default null
  ,p_ava_attribute27                in  varchar2  default null
  ,p_ava_attribute28                in  varchar2  default null
  ,p_ava_attribute29                in  varchar2  default null
  ,p_ava_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_actl_prem_vrbl_rt_rl_id ben_actl_prem_vrbl_rt_rl_f.actl_prem_vrbl_rt_rl_id%TYPE;
  l_effective_start_date ben_actl_prem_vrbl_rt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_actl_prem_vrbl_rt_rl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_actual_premium_rule';
  l_object_version_number ben_actl_prem_vrbl_rt_rl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_actual_premium_rule;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_actual_premium_rule
    --
    ben_actual_premium_rule_bk1.create_actual_premium_rule_b
      (
       p_actl_prem_id                   =>  p_actl_prem_id
      ,p_formula_id                     =>  p_formula_id
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_rt_trtmt_cd                    =>  p_rt_trtmt_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_ava_attribute_category         =>  p_ava_attribute_category
      ,p_ava_attribute1                 =>  p_ava_attribute1
      ,p_ava_attribute2                 =>  p_ava_attribute2
      ,p_ava_attribute3                 =>  p_ava_attribute3
      ,p_ava_attribute4                 =>  p_ava_attribute4
      ,p_ava_attribute5                 =>  p_ava_attribute5
      ,p_ava_attribute6                 =>  p_ava_attribute6
      ,p_ava_attribute7                 =>  p_ava_attribute7
      ,p_ava_attribute8                 =>  p_ava_attribute8
      ,p_ava_attribute9                 =>  p_ava_attribute9
      ,p_ava_attribute10                =>  p_ava_attribute10
      ,p_ava_attribute11                =>  p_ava_attribute11
      ,p_ava_attribute12                =>  p_ava_attribute12
      ,p_ava_attribute13                =>  p_ava_attribute13
      ,p_ava_attribute14                =>  p_ava_attribute14
      ,p_ava_attribute15                =>  p_ava_attribute15
      ,p_ava_attribute16                =>  p_ava_attribute16
      ,p_ava_attribute17                =>  p_ava_attribute17
      ,p_ava_attribute18                =>  p_ava_attribute18
      ,p_ava_attribute19                =>  p_ava_attribute19
      ,p_ava_attribute20                =>  p_ava_attribute20
      ,p_ava_attribute21                =>  p_ava_attribute21
      ,p_ava_attribute22                =>  p_ava_attribute22
      ,p_ava_attribute23                =>  p_ava_attribute23
      ,p_ava_attribute24                =>  p_ava_attribute24
      ,p_ava_attribute25                =>  p_ava_attribute25
      ,p_ava_attribute26                =>  p_ava_attribute26
      ,p_ava_attribute27                =>  p_ava_attribute27
      ,p_ava_attribute28                =>  p_ava_attribute28
      ,p_ava_attribute29                =>  p_ava_attribute29
      ,p_ava_attribute30                =>  p_ava_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_actual_premium_rule'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_actual_premium_rule
    --
  end;
  --
  ben_ava_ins.ins
    (
     p_actl_prem_vrbl_rt_rl_id       => l_actl_prem_vrbl_rt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_formula_id                    => p_formula_id
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_rt_trtmt_cd                   => p_rt_trtmt_cd
    ,p_business_group_id             => p_business_group_id
    ,p_ava_attribute_category        => p_ava_attribute_category
    ,p_ava_attribute1                => p_ava_attribute1
    ,p_ava_attribute2                => p_ava_attribute2
    ,p_ava_attribute3                => p_ava_attribute3
    ,p_ava_attribute4                => p_ava_attribute4
    ,p_ava_attribute5                => p_ava_attribute5
    ,p_ava_attribute6                => p_ava_attribute6
    ,p_ava_attribute7                => p_ava_attribute7
    ,p_ava_attribute8                => p_ava_attribute8
    ,p_ava_attribute9                => p_ava_attribute9
    ,p_ava_attribute10               => p_ava_attribute10
    ,p_ava_attribute11               => p_ava_attribute11
    ,p_ava_attribute12               => p_ava_attribute12
    ,p_ava_attribute13               => p_ava_attribute13
    ,p_ava_attribute14               => p_ava_attribute14
    ,p_ava_attribute15               => p_ava_attribute15
    ,p_ava_attribute16               => p_ava_attribute16
    ,p_ava_attribute17               => p_ava_attribute17
    ,p_ava_attribute18               => p_ava_attribute18
    ,p_ava_attribute19               => p_ava_attribute19
    ,p_ava_attribute20               => p_ava_attribute20
    ,p_ava_attribute21               => p_ava_attribute21
    ,p_ava_attribute22               => p_ava_attribute22
    ,p_ava_attribute23               => p_ava_attribute23
    ,p_ava_attribute24               => p_ava_attribute24
    ,p_ava_attribute25               => p_ava_attribute25
    ,p_ava_attribute26               => p_ava_attribute26
    ,p_ava_attribute27               => p_ava_attribute27
    ,p_ava_attribute28               => p_ava_attribute28
    ,p_ava_attribute29               => p_ava_attribute29
    ,p_ava_attribute30               => p_ava_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_actual_premium_rule
    --
    ben_actual_premium_rule_bk1.create_actual_premium_rule_a
      (
       p_actl_prem_vrbl_rt_rl_id        =>  l_actl_prem_vrbl_rt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_formula_id                     =>  p_formula_id
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_rt_trtmt_cd                    =>  p_rt_trtmt_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_ava_attribute_category         =>  p_ava_attribute_category
      ,p_ava_attribute1                 =>  p_ava_attribute1
      ,p_ava_attribute2                 =>  p_ava_attribute2
      ,p_ava_attribute3                 =>  p_ava_attribute3
      ,p_ava_attribute4                 =>  p_ava_attribute4
      ,p_ava_attribute5                 =>  p_ava_attribute5
      ,p_ava_attribute6                 =>  p_ava_attribute6
      ,p_ava_attribute7                 =>  p_ava_attribute7
      ,p_ava_attribute8                 =>  p_ava_attribute8
      ,p_ava_attribute9                 =>  p_ava_attribute9
      ,p_ava_attribute10                =>  p_ava_attribute10
      ,p_ava_attribute11                =>  p_ava_attribute11
      ,p_ava_attribute12                =>  p_ava_attribute12
      ,p_ava_attribute13                =>  p_ava_attribute13
      ,p_ava_attribute14                =>  p_ava_attribute14
      ,p_ava_attribute15                =>  p_ava_attribute15
      ,p_ava_attribute16                =>  p_ava_attribute16
      ,p_ava_attribute17                =>  p_ava_attribute17
      ,p_ava_attribute18                =>  p_ava_attribute18
      ,p_ava_attribute19                =>  p_ava_attribute19
      ,p_ava_attribute20                =>  p_ava_attribute20
      ,p_ava_attribute21                =>  p_ava_attribute21
      ,p_ava_attribute22                =>  p_ava_attribute22
      ,p_ava_attribute23                =>  p_ava_attribute23
      ,p_ava_attribute24                =>  p_ava_attribute24
      ,p_ava_attribute25                =>  p_ava_attribute25
      ,p_ava_attribute26                =>  p_ava_attribute26
      ,p_ava_attribute27                =>  p_ava_attribute27
      ,p_ava_attribute28                =>  p_ava_attribute28
      ,p_ava_attribute29                =>  p_ava_attribute29
      ,p_ava_attribute30                =>  p_ava_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_actual_premium_rule'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_actual_premium_rule
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
  p_actl_prem_vrbl_rt_rl_id := l_actl_prem_vrbl_rt_rl_id;
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
    ROLLBACK TO create_actual_premium_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_actl_prem_vrbl_rt_rl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_actual_premium_rule;
    /* Inserted for nocopy changes */
    p_actl_prem_vrbl_rt_rl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_actual_premium_rule;
-- ----------------------------------------------------------------------------
-- |------------------------< update_actual_premium_rule >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_actual_premium_rule
  (p_validate                       in  boolean   default false
  ,p_actl_prem_vrbl_rt_rl_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_ordr_to_aply_num               in  number    default hr_api.g_number
  ,p_rt_trtmt_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ava_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ava_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_actual_premium_rule';
  l_object_version_number ben_actl_prem_vrbl_rt_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_actl_prem_vrbl_rt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_actl_prem_vrbl_rt_rl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_actual_premium_rule;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_actual_premium_rule
    --
    ben_actual_premium_rule_bk2.update_actual_premium_rule_b
      (
       p_actl_prem_vrbl_rt_rl_id        =>  p_actl_prem_vrbl_rt_rl_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_formula_id                     =>  p_formula_id
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_rt_trtmt_cd                    =>  p_rt_trtmt_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_ava_attribute_category         =>  p_ava_attribute_category
      ,p_ava_attribute1                 =>  p_ava_attribute1
      ,p_ava_attribute2                 =>  p_ava_attribute2
      ,p_ava_attribute3                 =>  p_ava_attribute3
      ,p_ava_attribute4                 =>  p_ava_attribute4
      ,p_ava_attribute5                 =>  p_ava_attribute5
      ,p_ava_attribute6                 =>  p_ava_attribute6
      ,p_ava_attribute7                 =>  p_ava_attribute7
      ,p_ava_attribute8                 =>  p_ava_attribute8
      ,p_ava_attribute9                 =>  p_ava_attribute9
      ,p_ava_attribute10                =>  p_ava_attribute10
      ,p_ava_attribute11                =>  p_ava_attribute11
      ,p_ava_attribute12                =>  p_ava_attribute12
      ,p_ava_attribute13                =>  p_ava_attribute13
      ,p_ava_attribute14                =>  p_ava_attribute14
      ,p_ava_attribute15                =>  p_ava_attribute15
      ,p_ava_attribute16                =>  p_ava_attribute16
      ,p_ava_attribute17                =>  p_ava_attribute17
      ,p_ava_attribute18                =>  p_ava_attribute18
      ,p_ava_attribute19                =>  p_ava_attribute19
      ,p_ava_attribute20                =>  p_ava_attribute20
      ,p_ava_attribute21                =>  p_ava_attribute21
      ,p_ava_attribute22                =>  p_ava_attribute22
      ,p_ava_attribute23                =>  p_ava_attribute23
      ,p_ava_attribute24                =>  p_ava_attribute24
      ,p_ava_attribute25                =>  p_ava_attribute25
      ,p_ava_attribute26                =>  p_ava_attribute26
      ,p_ava_attribute27                =>  p_ava_attribute27
      ,p_ava_attribute28                =>  p_ava_attribute28
      ,p_ava_attribute29                =>  p_ava_attribute29
      ,p_ava_attribute30                =>  p_ava_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_actual_premium_rule'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_actual_premium_rule
    --
  end;
  --
  ben_ava_upd.upd
    (
     p_actl_prem_vrbl_rt_rl_id       => p_actl_prem_vrbl_rt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_formula_id                    => p_formula_id
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_rt_trtmt_cd                   => p_rt_trtmt_cd
    ,p_business_group_id             => p_business_group_id
    ,p_ava_attribute_category        => p_ava_attribute_category
    ,p_ava_attribute1                => p_ava_attribute1
    ,p_ava_attribute2                => p_ava_attribute2
    ,p_ava_attribute3                => p_ava_attribute3
    ,p_ava_attribute4                => p_ava_attribute4
    ,p_ava_attribute5                => p_ava_attribute5
    ,p_ava_attribute6                => p_ava_attribute6
    ,p_ava_attribute7                => p_ava_attribute7
    ,p_ava_attribute8                => p_ava_attribute8
    ,p_ava_attribute9                => p_ava_attribute9
    ,p_ava_attribute10               => p_ava_attribute10
    ,p_ava_attribute11               => p_ava_attribute11
    ,p_ava_attribute12               => p_ava_attribute12
    ,p_ava_attribute13               => p_ava_attribute13
    ,p_ava_attribute14               => p_ava_attribute14
    ,p_ava_attribute15               => p_ava_attribute15
    ,p_ava_attribute16               => p_ava_attribute16
    ,p_ava_attribute17               => p_ava_attribute17
    ,p_ava_attribute18               => p_ava_attribute18
    ,p_ava_attribute19               => p_ava_attribute19
    ,p_ava_attribute20               => p_ava_attribute20
    ,p_ava_attribute21               => p_ava_attribute21
    ,p_ava_attribute22               => p_ava_attribute22
    ,p_ava_attribute23               => p_ava_attribute23
    ,p_ava_attribute24               => p_ava_attribute24
    ,p_ava_attribute25               => p_ava_attribute25
    ,p_ava_attribute26               => p_ava_attribute26
    ,p_ava_attribute27               => p_ava_attribute27
    ,p_ava_attribute28               => p_ava_attribute28
    ,p_ava_attribute29               => p_ava_attribute29
    ,p_ava_attribute30               => p_ava_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_actual_premium_rule
    --
    ben_actual_premium_rule_bk2.update_actual_premium_rule_a
      (
       p_actl_prem_vrbl_rt_rl_id        =>  p_actl_prem_vrbl_rt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_formula_id                     =>  p_formula_id
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_rt_trtmt_cd                    =>  p_rt_trtmt_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_ava_attribute_category         =>  p_ava_attribute_category
      ,p_ava_attribute1                 =>  p_ava_attribute1
      ,p_ava_attribute2                 =>  p_ava_attribute2
      ,p_ava_attribute3                 =>  p_ava_attribute3
      ,p_ava_attribute4                 =>  p_ava_attribute4
      ,p_ava_attribute5                 =>  p_ava_attribute5
      ,p_ava_attribute6                 =>  p_ava_attribute6
      ,p_ava_attribute7                 =>  p_ava_attribute7
      ,p_ava_attribute8                 =>  p_ava_attribute8
      ,p_ava_attribute9                 =>  p_ava_attribute9
      ,p_ava_attribute10                =>  p_ava_attribute10
      ,p_ava_attribute11                =>  p_ava_attribute11
      ,p_ava_attribute12                =>  p_ava_attribute12
      ,p_ava_attribute13                =>  p_ava_attribute13
      ,p_ava_attribute14                =>  p_ava_attribute14
      ,p_ava_attribute15                =>  p_ava_attribute15
      ,p_ava_attribute16                =>  p_ava_attribute16
      ,p_ava_attribute17                =>  p_ava_attribute17
      ,p_ava_attribute18                =>  p_ava_attribute18
      ,p_ava_attribute19                =>  p_ava_attribute19
      ,p_ava_attribute20                =>  p_ava_attribute20
      ,p_ava_attribute21                =>  p_ava_attribute21
      ,p_ava_attribute22                =>  p_ava_attribute22
      ,p_ava_attribute23                =>  p_ava_attribute23
      ,p_ava_attribute24                =>  p_ava_attribute24
      ,p_ava_attribute25                =>  p_ava_attribute25
      ,p_ava_attribute26                =>  p_ava_attribute26
      ,p_ava_attribute27                =>  p_ava_attribute27
      ,p_ava_attribute28                =>  p_ava_attribute28
      ,p_ava_attribute29                =>  p_ava_attribute29
      ,p_ava_attribute30                =>  p_ava_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_actual_premium_rule'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_actual_premium_rule
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
    ROLLBACK TO update_actual_premium_rule;
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
    ROLLBACK TO update_actual_premium_rule;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_actual_premium_rule;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_actual_premium_rule >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_actual_premium_rule
  (p_validate                       in  boolean  default false
  ,p_actl_prem_vrbl_rt_rl_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_actual_premium_rule';
  l_object_version_number ben_actl_prem_vrbl_rt_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_actl_prem_vrbl_rt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_actl_prem_vrbl_rt_rl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_actual_premium_rule;
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
    -- Start of API User Hook for the before hook of delete_actual_premium_rule
    --
    ben_actual_premium_rule_bk3.delete_actual_premium_rule_b
      (
       p_actl_prem_vrbl_rt_rl_id        =>  p_actl_prem_vrbl_rt_rl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_actual_premium_rule'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_actual_premium_rule
    --
  end;
  --
  ben_ava_del.del
    (
     p_actl_prem_vrbl_rt_rl_id       => p_actl_prem_vrbl_rt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_actual_premium_rule
    --
    ben_actual_premium_rule_bk3.delete_actual_premium_rule_a
      (
       p_actl_prem_vrbl_rt_rl_id        =>  p_actl_prem_vrbl_rt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_actual_premium_rule'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_actual_premium_rule
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
    ROLLBACK TO delete_actual_premium_rule;
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
    ROLLBACK TO delete_actual_premium_rule;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_actual_premium_rule;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_actl_prem_vrbl_rt_rl_id                   in     number
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
  ben_ava_shd.lck
    (
      p_actl_prem_vrbl_rt_rl_id                 => p_actl_prem_vrbl_rt_rl_id
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
end ben_actual_premium_rule_api;

/
