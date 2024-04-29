--------------------------------------------------------
--  DDL for Package Body BEN_VRBL_RATE_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VRBL_RATE_RULE_API" as
/* $Header: bevrrapi.pkb 120.0 2005/05/28 12:13:24 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Vrbl_Rate_Rule_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Vrbl_Rate_Rule >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Vrbl_Rate_Rule
  (p_validate                       in  boolean   default false
  ,p_vrbl_rt_rl_id                  out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_drvbl_fctr_apls_flag           in  varchar2  default null
  ,p_rt_trtmt_cd                    in  varchar2  default null
  ,p_ordr_to_aply_num               in  number    default null
  ,p_formula_id                     in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_vrr_attribute_category         in  varchar2  default null
  ,p_vrr_attribute1                 in  varchar2  default null
  ,p_vrr_attribute2                 in  varchar2  default null
  ,p_vrr_attribute3                 in  varchar2  default null
  ,p_vrr_attribute4                 in  varchar2  default null
  ,p_vrr_attribute5                 in  varchar2  default null
  ,p_vrr_attribute6                 in  varchar2  default null
  ,p_vrr_attribute7                 in  varchar2  default null
  ,p_vrr_attribute8                 in  varchar2  default null
  ,p_vrr_attribute9                 in  varchar2  default null
  ,p_vrr_attribute10                in  varchar2  default null
  ,p_vrr_attribute11                in  varchar2  default null
  ,p_vrr_attribute12                in  varchar2  default null
  ,p_vrr_attribute13                in  varchar2  default null
  ,p_vrr_attribute14                in  varchar2  default null
  ,p_vrr_attribute15                in  varchar2  default null
  ,p_vrr_attribute16                in  varchar2  default null
  ,p_vrr_attribute17                in  varchar2  default null
  ,p_vrr_attribute18                in  varchar2  default null
  ,p_vrr_attribute19                in  varchar2  default null
  ,p_vrr_attribute20                in  varchar2  default null
  ,p_vrr_attribute21                in  varchar2  default null
  ,p_vrr_attribute22                in  varchar2  default null
  ,p_vrr_attribute23                in  varchar2  default null
  ,p_vrr_attribute24                in  varchar2  default null
  ,p_vrr_attribute25                in  varchar2  default null
  ,p_vrr_attribute26                in  varchar2  default null
  ,p_vrr_attribute27                in  varchar2  default null
  ,p_vrr_attribute28                in  varchar2  default null
  ,p_vrr_attribute29                in  varchar2  default null
  ,p_vrr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_vrbl_rt_rl_id ben_vrbl_rt_rl_f.vrbl_rt_rl_id%TYPE;
  l_effective_start_date ben_vrbl_rt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_vrbl_rt_rl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Vrbl_Rate_Rule';
  l_object_version_number ben_vrbl_rt_rl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Vrbl_Rate_Rule;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Vrbl_Rate_Rule
    --
    ben_Vrbl_Rate_Rule_bk1.create_Vrbl_Rate_Rule_b
      (
       p_drvbl_fctr_apls_flag           =>  p_drvbl_fctr_apls_flag
      ,p_rt_trtmt_cd                    =>  p_rt_trtmt_cd
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_formula_id                     =>  p_formula_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrr_attribute_category         =>  p_vrr_attribute_category
      ,p_vrr_attribute1                 =>  p_vrr_attribute1
      ,p_vrr_attribute2                 =>  p_vrr_attribute2
      ,p_vrr_attribute3                 =>  p_vrr_attribute3
      ,p_vrr_attribute4                 =>  p_vrr_attribute4
      ,p_vrr_attribute5                 =>  p_vrr_attribute5
      ,p_vrr_attribute6                 =>  p_vrr_attribute6
      ,p_vrr_attribute7                 =>  p_vrr_attribute7
      ,p_vrr_attribute8                 =>  p_vrr_attribute8
      ,p_vrr_attribute9                 =>  p_vrr_attribute9
      ,p_vrr_attribute10                =>  p_vrr_attribute10
      ,p_vrr_attribute11                =>  p_vrr_attribute11
      ,p_vrr_attribute12                =>  p_vrr_attribute12
      ,p_vrr_attribute13                =>  p_vrr_attribute13
      ,p_vrr_attribute14                =>  p_vrr_attribute14
      ,p_vrr_attribute15                =>  p_vrr_attribute15
      ,p_vrr_attribute16                =>  p_vrr_attribute16
      ,p_vrr_attribute17                =>  p_vrr_attribute17
      ,p_vrr_attribute18                =>  p_vrr_attribute18
      ,p_vrr_attribute19                =>  p_vrr_attribute19
      ,p_vrr_attribute20                =>  p_vrr_attribute20
      ,p_vrr_attribute21                =>  p_vrr_attribute21
      ,p_vrr_attribute22                =>  p_vrr_attribute22
      ,p_vrr_attribute23                =>  p_vrr_attribute23
      ,p_vrr_attribute24                =>  p_vrr_attribute24
      ,p_vrr_attribute25                =>  p_vrr_attribute25
      ,p_vrr_attribute26                =>  p_vrr_attribute26
      ,p_vrr_attribute27                =>  p_vrr_attribute27
      ,p_vrr_attribute28                =>  p_vrr_attribute28
      ,p_vrr_attribute29                =>  p_vrr_attribute29
      ,p_vrr_attribute30                =>  p_vrr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Vrbl_Rate_Rule'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Vrbl_Rate_Rule
    --
  end;
  --
  ben_vrr_ins.ins
    (
     p_vrbl_rt_rl_id                 => l_vrbl_rt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_drvbl_fctr_apls_flag          => p_drvbl_fctr_apls_flag
    ,p_rt_trtmt_cd                   => p_rt_trtmt_cd
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_formula_id                    => p_formula_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_vrr_attribute_category        => p_vrr_attribute_category
    ,p_vrr_attribute1                => p_vrr_attribute1
    ,p_vrr_attribute2                => p_vrr_attribute2
    ,p_vrr_attribute3                => p_vrr_attribute3
    ,p_vrr_attribute4                => p_vrr_attribute4
    ,p_vrr_attribute5                => p_vrr_attribute5
    ,p_vrr_attribute6                => p_vrr_attribute6
    ,p_vrr_attribute7                => p_vrr_attribute7
    ,p_vrr_attribute8                => p_vrr_attribute8
    ,p_vrr_attribute9                => p_vrr_attribute9
    ,p_vrr_attribute10               => p_vrr_attribute10
    ,p_vrr_attribute11               => p_vrr_attribute11
    ,p_vrr_attribute12               => p_vrr_attribute12
    ,p_vrr_attribute13               => p_vrr_attribute13
    ,p_vrr_attribute14               => p_vrr_attribute14
    ,p_vrr_attribute15               => p_vrr_attribute15
    ,p_vrr_attribute16               => p_vrr_attribute16
    ,p_vrr_attribute17               => p_vrr_attribute17
    ,p_vrr_attribute18               => p_vrr_attribute18
    ,p_vrr_attribute19               => p_vrr_attribute19
    ,p_vrr_attribute20               => p_vrr_attribute20
    ,p_vrr_attribute21               => p_vrr_attribute21
    ,p_vrr_attribute22               => p_vrr_attribute22
    ,p_vrr_attribute23               => p_vrr_attribute23
    ,p_vrr_attribute24               => p_vrr_attribute24
    ,p_vrr_attribute25               => p_vrr_attribute25
    ,p_vrr_attribute26               => p_vrr_attribute26
    ,p_vrr_attribute27               => p_vrr_attribute27
    ,p_vrr_attribute28               => p_vrr_attribute28
    ,p_vrr_attribute29               => p_vrr_attribute29
    ,p_vrr_attribute30               => p_vrr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Vrbl_Rate_Rule
    --
    ben_Vrbl_Rate_Rule_bk1.create_Vrbl_Rate_Rule_a
      (
       p_vrbl_rt_rl_id                  =>  l_vrbl_rt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_drvbl_fctr_apls_flag           =>  p_drvbl_fctr_apls_flag
      ,p_rt_trtmt_cd                    =>  p_rt_trtmt_cd
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_formula_id                     =>  p_formula_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrr_attribute_category         =>  p_vrr_attribute_category
      ,p_vrr_attribute1                 =>  p_vrr_attribute1
      ,p_vrr_attribute2                 =>  p_vrr_attribute2
      ,p_vrr_attribute3                 =>  p_vrr_attribute3
      ,p_vrr_attribute4                 =>  p_vrr_attribute4
      ,p_vrr_attribute5                 =>  p_vrr_attribute5
      ,p_vrr_attribute6                 =>  p_vrr_attribute6
      ,p_vrr_attribute7                 =>  p_vrr_attribute7
      ,p_vrr_attribute8                 =>  p_vrr_attribute8
      ,p_vrr_attribute9                 =>  p_vrr_attribute9
      ,p_vrr_attribute10                =>  p_vrr_attribute10
      ,p_vrr_attribute11                =>  p_vrr_attribute11
      ,p_vrr_attribute12                =>  p_vrr_attribute12
      ,p_vrr_attribute13                =>  p_vrr_attribute13
      ,p_vrr_attribute14                =>  p_vrr_attribute14
      ,p_vrr_attribute15                =>  p_vrr_attribute15
      ,p_vrr_attribute16                =>  p_vrr_attribute16
      ,p_vrr_attribute17                =>  p_vrr_attribute17
      ,p_vrr_attribute18                =>  p_vrr_attribute18
      ,p_vrr_attribute19                =>  p_vrr_attribute19
      ,p_vrr_attribute20                =>  p_vrr_attribute20
      ,p_vrr_attribute21                =>  p_vrr_attribute21
      ,p_vrr_attribute22                =>  p_vrr_attribute22
      ,p_vrr_attribute23                =>  p_vrr_attribute23
      ,p_vrr_attribute24                =>  p_vrr_attribute24
      ,p_vrr_attribute25                =>  p_vrr_attribute25
      ,p_vrr_attribute26                =>  p_vrr_attribute26
      ,p_vrr_attribute27                =>  p_vrr_attribute27
      ,p_vrr_attribute28                =>  p_vrr_attribute28
      ,p_vrr_attribute29                =>  p_vrr_attribute29
      ,p_vrr_attribute30                =>  p_vrr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Vrbl_Rate_Rule'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Vrbl_Rate_Rule
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
  p_vrbl_rt_rl_id := l_vrbl_rt_rl_id;
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
    ROLLBACK TO create_Vrbl_Rate_Rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_vrbl_rt_rl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Vrbl_Rate_Rule;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    raise;
    --
end create_Vrbl_Rate_Rule;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Vrbl_Rate_Rule >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Vrbl_Rate_Rule
  (p_validate                       in  boolean   default false
  ,p_vrbl_rt_rl_id                  in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_drvbl_fctr_apls_flag           in  varchar2  default hr_api.g_varchar2
  ,p_rt_trtmt_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ordr_to_aply_num               in  number    default hr_api.g_number
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_vrr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_vrr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Vrbl_Rate_Rule';
  l_object_version_number ben_vrbl_rt_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_vrbl_rt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_vrbl_rt_rl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Vrbl_Rate_Rule;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Vrbl_Rate_Rule
    --
    ben_Vrbl_Rate_Rule_bk2.update_Vrbl_Rate_Rule_b
      (
       p_vrbl_rt_rl_id                  =>  p_vrbl_rt_rl_id
      ,p_drvbl_fctr_apls_flag           =>  p_drvbl_fctr_apls_flag
      ,p_rt_trtmt_cd                    =>  p_rt_trtmt_cd
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_formula_id                     =>  p_formula_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrr_attribute_category         =>  p_vrr_attribute_category
      ,p_vrr_attribute1                 =>  p_vrr_attribute1
      ,p_vrr_attribute2                 =>  p_vrr_attribute2
      ,p_vrr_attribute3                 =>  p_vrr_attribute3
      ,p_vrr_attribute4                 =>  p_vrr_attribute4
      ,p_vrr_attribute5                 =>  p_vrr_attribute5
      ,p_vrr_attribute6                 =>  p_vrr_attribute6
      ,p_vrr_attribute7                 =>  p_vrr_attribute7
      ,p_vrr_attribute8                 =>  p_vrr_attribute8
      ,p_vrr_attribute9                 =>  p_vrr_attribute9
      ,p_vrr_attribute10                =>  p_vrr_attribute10
      ,p_vrr_attribute11                =>  p_vrr_attribute11
      ,p_vrr_attribute12                =>  p_vrr_attribute12
      ,p_vrr_attribute13                =>  p_vrr_attribute13
      ,p_vrr_attribute14                =>  p_vrr_attribute14
      ,p_vrr_attribute15                =>  p_vrr_attribute15
      ,p_vrr_attribute16                =>  p_vrr_attribute16
      ,p_vrr_attribute17                =>  p_vrr_attribute17
      ,p_vrr_attribute18                =>  p_vrr_attribute18
      ,p_vrr_attribute19                =>  p_vrr_attribute19
      ,p_vrr_attribute20                =>  p_vrr_attribute20
      ,p_vrr_attribute21                =>  p_vrr_attribute21
      ,p_vrr_attribute22                =>  p_vrr_attribute22
      ,p_vrr_attribute23                =>  p_vrr_attribute23
      ,p_vrr_attribute24                =>  p_vrr_attribute24
      ,p_vrr_attribute25                =>  p_vrr_attribute25
      ,p_vrr_attribute26                =>  p_vrr_attribute26
      ,p_vrr_attribute27                =>  p_vrr_attribute27
      ,p_vrr_attribute28                =>  p_vrr_attribute28
      ,p_vrr_attribute29                =>  p_vrr_attribute29
      ,p_vrr_attribute30                =>  p_vrr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Vrbl_Rate_Rule'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Vrbl_Rate_Rule
    --
  end;
  --
  ben_vrr_upd.upd
    (
     p_vrbl_rt_rl_id                 => p_vrbl_rt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_drvbl_fctr_apls_flag          => p_drvbl_fctr_apls_flag
    ,p_rt_trtmt_cd                   => p_rt_trtmt_cd
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_formula_id                    => p_formula_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_vrr_attribute_category        => p_vrr_attribute_category
    ,p_vrr_attribute1                => p_vrr_attribute1
    ,p_vrr_attribute2                => p_vrr_attribute2
    ,p_vrr_attribute3                => p_vrr_attribute3
    ,p_vrr_attribute4                => p_vrr_attribute4
    ,p_vrr_attribute5                => p_vrr_attribute5
    ,p_vrr_attribute6                => p_vrr_attribute6
    ,p_vrr_attribute7                => p_vrr_attribute7
    ,p_vrr_attribute8                => p_vrr_attribute8
    ,p_vrr_attribute9                => p_vrr_attribute9
    ,p_vrr_attribute10               => p_vrr_attribute10
    ,p_vrr_attribute11               => p_vrr_attribute11
    ,p_vrr_attribute12               => p_vrr_attribute12
    ,p_vrr_attribute13               => p_vrr_attribute13
    ,p_vrr_attribute14               => p_vrr_attribute14
    ,p_vrr_attribute15               => p_vrr_attribute15
    ,p_vrr_attribute16               => p_vrr_attribute16
    ,p_vrr_attribute17               => p_vrr_attribute17
    ,p_vrr_attribute18               => p_vrr_attribute18
    ,p_vrr_attribute19               => p_vrr_attribute19
    ,p_vrr_attribute20               => p_vrr_attribute20
    ,p_vrr_attribute21               => p_vrr_attribute21
    ,p_vrr_attribute22               => p_vrr_attribute22
    ,p_vrr_attribute23               => p_vrr_attribute23
    ,p_vrr_attribute24               => p_vrr_attribute24
    ,p_vrr_attribute25               => p_vrr_attribute25
    ,p_vrr_attribute26               => p_vrr_attribute26
    ,p_vrr_attribute27               => p_vrr_attribute27
    ,p_vrr_attribute28               => p_vrr_attribute28
    ,p_vrr_attribute29               => p_vrr_attribute29
    ,p_vrr_attribute30               => p_vrr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Vrbl_Rate_Rule
    --
    ben_Vrbl_Rate_Rule_bk2.update_Vrbl_Rate_Rule_a
      (
       p_vrbl_rt_rl_id                  =>  p_vrbl_rt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_drvbl_fctr_apls_flag           =>  p_drvbl_fctr_apls_flag
      ,p_rt_trtmt_cd                    =>  p_rt_trtmt_cd
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_formula_id                     =>  p_formula_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrr_attribute_category         =>  p_vrr_attribute_category
      ,p_vrr_attribute1                 =>  p_vrr_attribute1
      ,p_vrr_attribute2                 =>  p_vrr_attribute2
      ,p_vrr_attribute3                 =>  p_vrr_attribute3
      ,p_vrr_attribute4                 =>  p_vrr_attribute4
      ,p_vrr_attribute5                 =>  p_vrr_attribute5
      ,p_vrr_attribute6                 =>  p_vrr_attribute6
      ,p_vrr_attribute7                 =>  p_vrr_attribute7
      ,p_vrr_attribute8                 =>  p_vrr_attribute8
      ,p_vrr_attribute9                 =>  p_vrr_attribute9
      ,p_vrr_attribute10                =>  p_vrr_attribute10
      ,p_vrr_attribute11                =>  p_vrr_attribute11
      ,p_vrr_attribute12                =>  p_vrr_attribute12
      ,p_vrr_attribute13                =>  p_vrr_attribute13
      ,p_vrr_attribute14                =>  p_vrr_attribute14
      ,p_vrr_attribute15                =>  p_vrr_attribute15
      ,p_vrr_attribute16                =>  p_vrr_attribute16
      ,p_vrr_attribute17                =>  p_vrr_attribute17
      ,p_vrr_attribute18                =>  p_vrr_attribute18
      ,p_vrr_attribute19                =>  p_vrr_attribute19
      ,p_vrr_attribute20                =>  p_vrr_attribute20
      ,p_vrr_attribute21                =>  p_vrr_attribute21
      ,p_vrr_attribute22                =>  p_vrr_attribute22
      ,p_vrr_attribute23                =>  p_vrr_attribute23
      ,p_vrr_attribute24                =>  p_vrr_attribute24
      ,p_vrr_attribute25                =>  p_vrr_attribute25
      ,p_vrr_attribute26                =>  p_vrr_attribute26
      ,p_vrr_attribute27                =>  p_vrr_attribute27
      ,p_vrr_attribute28                =>  p_vrr_attribute28
      ,p_vrr_attribute29                =>  p_vrr_attribute29
      ,p_vrr_attribute30                =>  p_vrr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Vrbl_Rate_Rule'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Vrbl_Rate_Rule
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
    ROLLBACK TO update_Vrbl_Rate_Rule;
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
    ROLLBACK TO update_Vrbl_Rate_Rule;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end update_Vrbl_Rate_Rule;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Vrbl_Rate_Rule >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Vrbl_Rate_Rule
  (p_validate                       in  boolean  default false
  ,p_vrbl_rt_rl_id                  in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Vrbl_Rate_Rule';
  l_object_version_number ben_vrbl_rt_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_vrbl_rt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_vrbl_rt_rl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Vrbl_Rate_Rule;
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
    -- Start of API User Hook for the before hook of delete_Vrbl_Rate_Rule
    --
    ben_Vrbl_Rate_Rule_bk3.delete_Vrbl_Rate_Rule_b
      (
       p_vrbl_rt_rl_id                  =>  p_vrbl_rt_rl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Vrbl_Rate_Rule'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Vrbl_Rate_Rule
    --
  end;
  --
  ben_vrr_del.del
    (
     p_vrbl_rt_rl_id                 => p_vrbl_rt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Vrbl_Rate_Rule
    --
    ben_Vrbl_Rate_Rule_bk3.delete_Vrbl_Rate_Rule_a
      (
       p_vrbl_rt_rl_id                  =>  p_vrbl_rt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Vrbl_Rate_Rule'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Vrbl_Rate_Rule
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
    ROLLBACK TO delete_Vrbl_Rate_Rule;
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
    ROLLBACK TO delete_Vrbl_Rate_Rule;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    raise;
    --
end delete_Vrbl_Rate_Rule;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_vrbl_rt_rl_id                   in     number
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
  ben_vrr_shd.lck
    (
      p_vrbl_rt_rl_id                 => p_vrbl_rt_rl_id
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
end ben_Vrbl_Rate_Rule_api;

/
