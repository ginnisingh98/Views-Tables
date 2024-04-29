--------------------------------------------------------
--  DDL for Package Body BEN_BNFT_VRBL_RT_RL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNFT_VRBL_RT_RL_API" as
/* $Header: bebrrapi.pkb 120.0 2005/05/28 00:52:04 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_bnft_vrbl_rt_rl_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_bnft_vrbl_rt_rl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bnft_vrbl_rt_rl
  (p_validate                       in  boolean   default false
  ,p_bnft_vrbl_rt_rl_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_to_aply_num               in  number    default null
  ,p_cvg_amt_calc_mthd_id           in  number    default null
  ,p_formula_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_brr_attribute_category         in  varchar2  default null
  ,p_brr_attribute1                 in  varchar2  default null
  ,p_brr_attribute2                 in  varchar2  default null
  ,p_brr_attribute3                 in  varchar2  default null
  ,p_brr_attribute4                 in  varchar2  default null
  ,p_brr_attribute5                 in  varchar2  default null
  ,p_brr_attribute6                 in  varchar2  default null
  ,p_brr_attribute7                 in  varchar2  default null
  ,p_brr_attribute8                 in  varchar2  default null
  ,p_brr_attribute9                 in  varchar2  default null
  ,p_brr_attribute10                in  varchar2  default null
  ,p_brr_attribute11                in  varchar2  default null
  ,p_brr_attribute12                in  varchar2  default null
  ,p_brr_attribute13                in  varchar2  default null
  ,p_brr_attribute14                in  varchar2  default null
  ,p_brr_attribute15                in  varchar2  default null
  ,p_brr_attribute16                in  varchar2  default null
  ,p_brr_attribute17                in  varchar2  default null
  ,p_brr_attribute18                in  varchar2  default null
  ,p_brr_attribute19                in  varchar2  default null
  ,p_brr_attribute20                in  varchar2  default null
  ,p_brr_attribute21                in  varchar2  default null
  ,p_brr_attribute22                in  varchar2  default null
  ,p_brr_attribute23                in  varchar2  default null
  ,p_brr_attribute24                in  varchar2  default null
  ,p_brr_attribute25                in  varchar2  default null
  ,p_brr_attribute26                in  varchar2  default null
  ,p_brr_attribute27                in  varchar2  default null
  ,p_brr_attribute28                in  varchar2  default null
  ,p_brr_attribute29                in  varchar2  default null
  ,p_brr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_bnft_vrbl_rt_rl_id ben_bnft_vrbl_rt_rl_f.bnft_vrbl_rt_rl_id%TYPE;
  l_effective_start_date ben_bnft_vrbl_rt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_vrbl_rt_rl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_bnft_vrbl_rt_rl';
  l_object_version_number ben_bnft_vrbl_rt_rl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_bnft_vrbl_rt_rl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_bnft_vrbl_rt_rl
    --
    ben_bnft_vrbl_rt_rl_bk1.create_bnft_vrbl_rt_rl_b
      (
       p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_formula_id                     =>  p_formula_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_brr_attribute_category         =>  p_brr_attribute_category
      ,p_brr_attribute1                 =>  p_brr_attribute1
      ,p_brr_attribute2                 =>  p_brr_attribute2
      ,p_brr_attribute3                 =>  p_brr_attribute3
      ,p_brr_attribute4                 =>  p_brr_attribute4
      ,p_brr_attribute5                 =>  p_brr_attribute5
      ,p_brr_attribute6                 =>  p_brr_attribute6
      ,p_brr_attribute7                 =>  p_brr_attribute7
      ,p_brr_attribute8                 =>  p_brr_attribute8
      ,p_brr_attribute9                 =>  p_brr_attribute9
      ,p_brr_attribute10                =>  p_brr_attribute10
      ,p_brr_attribute11                =>  p_brr_attribute11
      ,p_brr_attribute12                =>  p_brr_attribute12
      ,p_brr_attribute13                =>  p_brr_attribute13
      ,p_brr_attribute14                =>  p_brr_attribute14
      ,p_brr_attribute15                =>  p_brr_attribute15
      ,p_brr_attribute16                =>  p_brr_attribute16
      ,p_brr_attribute17                =>  p_brr_attribute17
      ,p_brr_attribute18                =>  p_brr_attribute18
      ,p_brr_attribute19                =>  p_brr_attribute19
      ,p_brr_attribute20                =>  p_brr_attribute20
      ,p_brr_attribute21                =>  p_brr_attribute21
      ,p_brr_attribute22                =>  p_brr_attribute22
      ,p_brr_attribute23                =>  p_brr_attribute23
      ,p_brr_attribute24                =>  p_brr_attribute24
      ,p_brr_attribute25                =>  p_brr_attribute25
      ,p_brr_attribute26                =>  p_brr_attribute26
      ,p_brr_attribute27                =>  p_brr_attribute27
      ,p_brr_attribute28                =>  p_brr_attribute28
      ,p_brr_attribute29                =>  p_brr_attribute29
      ,p_brr_attribute30                =>  p_brr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_bnft_vrbl_rt_rl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_bnft_vrbl_rt_rl
    --
  end;
  --
  ben_brr_ins.ins
    (
     p_bnft_vrbl_rt_rl_id            => l_bnft_vrbl_rt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_cvg_amt_calc_mthd_id          => p_cvg_amt_calc_mthd_id
    ,p_formula_id                    => p_formula_id
    ,p_business_group_id             => p_business_group_id
    ,p_brr_attribute_category        => p_brr_attribute_category
    ,p_brr_attribute1                => p_brr_attribute1
    ,p_brr_attribute2                => p_brr_attribute2
    ,p_brr_attribute3                => p_brr_attribute3
    ,p_brr_attribute4                => p_brr_attribute4
    ,p_brr_attribute5                => p_brr_attribute5
    ,p_brr_attribute6                => p_brr_attribute6
    ,p_brr_attribute7                => p_brr_attribute7
    ,p_brr_attribute8                => p_brr_attribute8
    ,p_brr_attribute9                => p_brr_attribute9
    ,p_brr_attribute10               => p_brr_attribute10
    ,p_brr_attribute11               => p_brr_attribute11
    ,p_brr_attribute12               => p_brr_attribute12
    ,p_brr_attribute13               => p_brr_attribute13
    ,p_brr_attribute14               => p_brr_attribute14
    ,p_brr_attribute15               => p_brr_attribute15
    ,p_brr_attribute16               => p_brr_attribute16
    ,p_brr_attribute17               => p_brr_attribute17
    ,p_brr_attribute18               => p_brr_attribute18
    ,p_brr_attribute19               => p_brr_attribute19
    ,p_brr_attribute20               => p_brr_attribute20
    ,p_brr_attribute21               => p_brr_attribute21
    ,p_brr_attribute22               => p_brr_attribute22
    ,p_brr_attribute23               => p_brr_attribute23
    ,p_brr_attribute24               => p_brr_attribute24
    ,p_brr_attribute25               => p_brr_attribute25
    ,p_brr_attribute26               => p_brr_attribute26
    ,p_brr_attribute27               => p_brr_attribute27
    ,p_brr_attribute28               => p_brr_attribute28
    ,p_brr_attribute29               => p_brr_attribute29
    ,p_brr_attribute30               => p_brr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_bnft_vrbl_rt_rl
    --
    ben_bnft_vrbl_rt_rl_bk1.create_bnft_vrbl_rt_rl_a
      (
       p_bnft_vrbl_rt_rl_id             =>  l_bnft_vrbl_rt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_formula_id                     =>  p_formula_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_brr_attribute_category         =>  p_brr_attribute_category
      ,p_brr_attribute1                 =>  p_brr_attribute1
      ,p_brr_attribute2                 =>  p_brr_attribute2
      ,p_brr_attribute3                 =>  p_brr_attribute3
      ,p_brr_attribute4                 =>  p_brr_attribute4
      ,p_brr_attribute5                 =>  p_brr_attribute5
      ,p_brr_attribute6                 =>  p_brr_attribute6
      ,p_brr_attribute7                 =>  p_brr_attribute7
      ,p_brr_attribute8                 =>  p_brr_attribute8
      ,p_brr_attribute9                 =>  p_brr_attribute9
      ,p_brr_attribute10                =>  p_brr_attribute10
      ,p_brr_attribute11                =>  p_brr_attribute11
      ,p_brr_attribute12                =>  p_brr_attribute12
      ,p_brr_attribute13                =>  p_brr_attribute13
      ,p_brr_attribute14                =>  p_brr_attribute14
      ,p_brr_attribute15                =>  p_brr_attribute15
      ,p_brr_attribute16                =>  p_brr_attribute16
      ,p_brr_attribute17                =>  p_brr_attribute17
      ,p_brr_attribute18                =>  p_brr_attribute18
      ,p_brr_attribute19                =>  p_brr_attribute19
      ,p_brr_attribute20                =>  p_brr_attribute20
      ,p_brr_attribute21                =>  p_brr_attribute21
      ,p_brr_attribute22                =>  p_brr_attribute22
      ,p_brr_attribute23                =>  p_brr_attribute23
      ,p_brr_attribute24                =>  p_brr_attribute24
      ,p_brr_attribute25                =>  p_brr_attribute25
      ,p_brr_attribute26                =>  p_brr_attribute26
      ,p_brr_attribute27                =>  p_brr_attribute27
      ,p_brr_attribute28                =>  p_brr_attribute28
      ,p_brr_attribute29                =>  p_brr_attribute29
      ,p_brr_attribute30                =>  p_brr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_bnft_vrbl_rt_rl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_bnft_vrbl_rt_rl
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
  p_bnft_vrbl_rt_rl_id := l_bnft_vrbl_rt_rl_id;
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
    ROLLBACK TO create_bnft_vrbl_rt_rl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_bnft_vrbl_rt_rl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_bnft_vrbl_rt_rl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO create_bnft_vrbl_rt_rl;
    raise;
    --
end create_bnft_vrbl_rt_rl;
-- ----------------------------------------------------------------------------
-- |------------------------< update_bnft_vrbl_rt_rl >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_bnft_vrbl_rt_rl
  (p_validate                       in  boolean   default false
  ,p_bnft_vrbl_rt_rl_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_to_aply_num               in  number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id           in  number    default hr_api.g_number
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_brr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_brr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_bnft_vrbl_rt_rl';
  l_object_version_number ben_bnft_vrbl_rt_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_vrbl_rt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_vrbl_rt_rl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_bnft_vrbl_rt_rl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_bnft_vrbl_rt_rl
    --
    ben_bnft_vrbl_rt_rl_bk2.update_bnft_vrbl_rt_rl_b
      (
       p_bnft_vrbl_rt_rl_id             =>  p_bnft_vrbl_rt_rl_id
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_formula_id                     =>  p_formula_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_brr_attribute_category         =>  p_brr_attribute_category
      ,p_brr_attribute1                 =>  p_brr_attribute1
      ,p_brr_attribute2                 =>  p_brr_attribute2
      ,p_brr_attribute3                 =>  p_brr_attribute3
      ,p_brr_attribute4                 =>  p_brr_attribute4
      ,p_brr_attribute5                 =>  p_brr_attribute5
      ,p_brr_attribute6                 =>  p_brr_attribute6
      ,p_brr_attribute7                 =>  p_brr_attribute7
      ,p_brr_attribute8                 =>  p_brr_attribute8
      ,p_brr_attribute9                 =>  p_brr_attribute9
      ,p_brr_attribute10                =>  p_brr_attribute10
      ,p_brr_attribute11                =>  p_brr_attribute11
      ,p_brr_attribute12                =>  p_brr_attribute12
      ,p_brr_attribute13                =>  p_brr_attribute13
      ,p_brr_attribute14                =>  p_brr_attribute14
      ,p_brr_attribute15                =>  p_brr_attribute15
      ,p_brr_attribute16                =>  p_brr_attribute16
      ,p_brr_attribute17                =>  p_brr_attribute17
      ,p_brr_attribute18                =>  p_brr_attribute18
      ,p_brr_attribute19                =>  p_brr_attribute19
      ,p_brr_attribute20                =>  p_brr_attribute20
      ,p_brr_attribute21                =>  p_brr_attribute21
      ,p_brr_attribute22                =>  p_brr_attribute22
      ,p_brr_attribute23                =>  p_brr_attribute23
      ,p_brr_attribute24                =>  p_brr_attribute24
      ,p_brr_attribute25                =>  p_brr_attribute25
      ,p_brr_attribute26                =>  p_brr_attribute26
      ,p_brr_attribute27                =>  p_brr_attribute27
      ,p_brr_attribute28                =>  p_brr_attribute28
      ,p_brr_attribute29                =>  p_brr_attribute29
      ,p_brr_attribute30                =>  p_brr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_bnft_vrbl_rt_rl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_bnft_vrbl_rt_rl
    --
  end;
  --
  ben_brr_upd.upd
    (
     p_bnft_vrbl_rt_rl_id            => p_bnft_vrbl_rt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_cvg_amt_calc_mthd_id          => p_cvg_amt_calc_mthd_id
    ,p_formula_id                    => p_formula_id
    ,p_business_group_id             => p_business_group_id
    ,p_brr_attribute_category        => p_brr_attribute_category
    ,p_brr_attribute1                => p_brr_attribute1
    ,p_brr_attribute2                => p_brr_attribute2
    ,p_brr_attribute3                => p_brr_attribute3
    ,p_brr_attribute4                => p_brr_attribute4
    ,p_brr_attribute5                => p_brr_attribute5
    ,p_brr_attribute6                => p_brr_attribute6
    ,p_brr_attribute7                => p_brr_attribute7
    ,p_brr_attribute8                => p_brr_attribute8
    ,p_brr_attribute9                => p_brr_attribute9
    ,p_brr_attribute10               => p_brr_attribute10
    ,p_brr_attribute11               => p_brr_attribute11
    ,p_brr_attribute12               => p_brr_attribute12
    ,p_brr_attribute13               => p_brr_attribute13
    ,p_brr_attribute14               => p_brr_attribute14
    ,p_brr_attribute15               => p_brr_attribute15
    ,p_brr_attribute16               => p_brr_attribute16
    ,p_brr_attribute17               => p_brr_attribute17
    ,p_brr_attribute18               => p_brr_attribute18
    ,p_brr_attribute19               => p_brr_attribute19
    ,p_brr_attribute20               => p_brr_attribute20
    ,p_brr_attribute21               => p_brr_attribute21
    ,p_brr_attribute22               => p_brr_attribute22
    ,p_brr_attribute23               => p_brr_attribute23
    ,p_brr_attribute24               => p_brr_attribute24
    ,p_brr_attribute25               => p_brr_attribute25
    ,p_brr_attribute26               => p_brr_attribute26
    ,p_brr_attribute27               => p_brr_attribute27
    ,p_brr_attribute28               => p_brr_attribute28
    ,p_brr_attribute29               => p_brr_attribute29
    ,p_brr_attribute30               => p_brr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_bnft_vrbl_rt_rl
    --
    ben_bnft_vrbl_rt_rl_bk2.update_bnft_vrbl_rt_rl_a
      (
       p_bnft_vrbl_rt_rl_id             =>  p_bnft_vrbl_rt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_formula_id                     =>  p_formula_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_brr_attribute_category         =>  p_brr_attribute_category
      ,p_brr_attribute1                 =>  p_brr_attribute1
      ,p_brr_attribute2                 =>  p_brr_attribute2
      ,p_brr_attribute3                 =>  p_brr_attribute3
      ,p_brr_attribute4                 =>  p_brr_attribute4
      ,p_brr_attribute5                 =>  p_brr_attribute5
      ,p_brr_attribute6                 =>  p_brr_attribute6
      ,p_brr_attribute7                 =>  p_brr_attribute7
      ,p_brr_attribute8                 =>  p_brr_attribute8
      ,p_brr_attribute9                 =>  p_brr_attribute9
      ,p_brr_attribute10                =>  p_brr_attribute10
      ,p_brr_attribute11                =>  p_brr_attribute11
      ,p_brr_attribute12                =>  p_brr_attribute12
      ,p_brr_attribute13                =>  p_brr_attribute13
      ,p_brr_attribute14                =>  p_brr_attribute14
      ,p_brr_attribute15                =>  p_brr_attribute15
      ,p_brr_attribute16                =>  p_brr_attribute16
      ,p_brr_attribute17                =>  p_brr_attribute17
      ,p_brr_attribute18                =>  p_brr_attribute18
      ,p_brr_attribute19                =>  p_brr_attribute19
      ,p_brr_attribute20                =>  p_brr_attribute20
      ,p_brr_attribute21                =>  p_brr_attribute21
      ,p_brr_attribute22                =>  p_brr_attribute22
      ,p_brr_attribute23                =>  p_brr_attribute23
      ,p_brr_attribute24                =>  p_brr_attribute24
      ,p_brr_attribute25                =>  p_brr_attribute25
      ,p_brr_attribute26                =>  p_brr_attribute26
      ,p_brr_attribute27                =>  p_brr_attribute27
      ,p_brr_attribute28                =>  p_brr_attribute28
      ,p_brr_attribute29                =>  p_brr_attribute29
      ,p_brr_attribute30                =>  p_brr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_bnft_vrbl_rt_rl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_bnft_vrbl_rt_rl
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
    ROLLBACK TO update_bnft_vrbl_rt_rl;
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
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO update_bnft_vrbl_rt_rl;
    raise;
    --
end update_bnft_vrbl_rt_rl;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_bnft_vrbl_rt_rl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bnft_vrbl_rt_rl
  (p_validate                       in  boolean  default false
  ,p_bnft_vrbl_rt_rl_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_bnft_vrbl_rt_rl';
  l_object_version_number ben_bnft_vrbl_rt_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_vrbl_rt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_vrbl_rt_rl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_bnft_vrbl_rt_rl;
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
    -- Start of API User Hook for the before hook of delete_bnft_vrbl_rt_rl
    --
    ben_bnft_vrbl_rt_rl_bk3.delete_bnft_vrbl_rt_rl_b
      (
       p_bnft_vrbl_rt_rl_id             =>  p_bnft_vrbl_rt_rl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_bnft_vrbl_rt_rl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_bnft_vrbl_rt_rl
    --
  end;
  --
  ben_brr_del.del
    (
     p_bnft_vrbl_rt_rl_id            => p_bnft_vrbl_rt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_bnft_vrbl_rt_rl
    --
    ben_bnft_vrbl_rt_rl_bk3.delete_bnft_vrbl_rt_rl_a
      (
       p_bnft_vrbl_rt_rl_id             =>  p_bnft_vrbl_rt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_bnft_vrbl_rt_rl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_bnft_vrbl_rt_rl
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
    ROLLBACK TO delete_bnft_vrbl_rt_rl;
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
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO delete_bnft_vrbl_rt_rl;
    raise;
    --
end delete_bnft_vrbl_rt_rl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_bnft_vrbl_rt_rl_id                   in     number
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
  ben_brr_shd.lck
    (
      p_bnft_vrbl_rt_rl_id                 => p_bnft_vrbl_rt_rl_id
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
end ben_bnft_vrbl_rt_rl_api;

/
