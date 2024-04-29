--------------------------------------------------------
--  DDL for Package Body BEN_PAY_BASIS_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PAY_BASIS_RATE_API" as
/* $Header: bepbrapi.pkb 115.3 2002/12/16 09:37:16 hnarayan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PAY_BASIS_RATE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PAY_BASIS_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PAY_BASIS_RATE
  (p_validate                       in  boolean   default false
  ,p_py_bss_rt_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_pay_basis_id                   in  number    default null
  ,p_excld_flag                     in  varchar2  default null
  ,p_ordr_num                       in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pbr_attribute_category         in  varchar2  default null
  ,p_pbr_attribute1                 in  varchar2  default null
  ,p_pbr_attribute2                 in  varchar2  default null
  ,p_pbr_attribute3                 in  varchar2  default null
  ,p_pbr_attribute4                 in  varchar2  default null
  ,p_pbr_attribute5                 in  varchar2  default null
  ,p_pbr_attribute6                 in  varchar2  default null
  ,p_pbr_attribute7                 in  varchar2  default null
  ,p_pbr_attribute8                 in  varchar2  default null
  ,p_pbr_attribute9                 in  varchar2  default null
  ,p_pbr_attribute10                in  varchar2  default null
  ,p_pbr_attribute11                in  varchar2  default null
  ,p_pbr_attribute12                in  varchar2  default null
  ,p_pbr_attribute13                in  varchar2  default null
  ,p_pbr_attribute14                in  varchar2  default null
  ,p_pbr_attribute15                in  varchar2  default null
  ,p_pbr_attribute16                in  varchar2  default null
  ,p_pbr_attribute17                in  varchar2  default null
  ,p_pbr_attribute18                in  varchar2  default null
  ,p_pbr_attribute19                in  varchar2  default null
  ,p_pbr_attribute20                in  varchar2  default null
  ,p_pbr_attribute21                in  varchar2  default null
  ,p_pbr_attribute22                in  varchar2  default null
  ,p_pbr_attribute23                in  varchar2  default null
  ,p_pbr_attribute24                in  varchar2  default null
  ,p_pbr_attribute25                in  varchar2  default null
  ,p_pbr_attribute26                in  varchar2  default null
  ,p_pbr_attribute27                in  varchar2  default null
  ,p_pbr_attribute28                in  varchar2  default null
  ,p_pbr_attribute29                in  varchar2  default null
  ,p_pbr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_py_bss_rt_id ben_py_bss_rt_f.py_bss_rt_id%TYPE;
  l_effective_start_date ben_py_bss_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_py_bss_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PAY_BASIS_RATE';
  l_object_version_number ben_py_bss_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PAY_BASIS_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PAY_BASIS_RATE
    --
    ben_PAY_BASIS_RATE_bk1.create_PAY_BASIS_RATE_b
      (
       p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_pay_basis_id                   =>  p_pay_basis_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbr_attribute_category         =>  p_pbr_attribute_category
      ,p_pbr_attribute1                 =>  p_pbr_attribute1
      ,p_pbr_attribute2                 =>  p_pbr_attribute2
      ,p_pbr_attribute3                 =>  p_pbr_attribute3
      ,p_pbr_attribute4                 =>  p_pbr_attribute4
      ,p_pbr_attribute5                 =>  p_pbr_attribute5
      ,p_pbr_attribute6                 =>  p_pbr_attribute6
      ,p_pbr_attribute7                 =>  p_pbr_attribute7
      ,p_pbr_attribute8                 =>  p_pbr_attribute8
      ,p_pbr_attribute9                 =>  p_pbr_attribute9
      ,p_pbr_attribute10                =>  p_pbr_attribute10
      ,p_pbr_attribute11                =>  p_pbr_attribute11
      ,p_pbr_attribute12                =>  p_pbr_attribute12
      ,p_pbr_attribute13                =>  p_pbr_attribute13
      ,p_pbr_attribute14                =>  p_pbr_attribute14
      ,p_pbr_attribute15                =>  p_pbr_attribute15
      ,p_pbr_attribute16                =>  p_pbr_attribute16
      ,p_pbr_attribute17                =>  p_pbr_attribute17
      ,p_pbr_attribute18                =>  p_pbr_attribute18
      ,p_pbr_attribute19                =>  p_pbr_attribute19
      ,p_pbr_attribute20                =>  p_pbr_attribute20
      ,p_pbr_attribute21                =>  p_pbr_attribute21
      ,p_pbr_attribute22                =>  p_pbr_attribute22
      ,p_pbr_attribute23                =>  p_pbr_attribute23
      ,p_pbr_attribute24                =>  p_pbr_attribute24
      ,p_pbr_attribute25                =>  p_pbr_attribute25
      ,p_pbr_attribute26                =>  p_pbr_attribute26
      ,p_pbr_attribute27                =>  p_pbr_attribute27
      ,p_pbr_attribute28                =>  p_pbr_attribute28
      ,p_pbr_attribute29                =>  p_pbr_attribute29
      ,p_pbr_attribute30                =>  p_pbr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PAY_BASIS_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PAY_BASIS_RATE
    --
  end;
  --
  ben_pbr_ins.ins
    (
     p_py_bss_rt_id                  => l_py_bss_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_pay_basis_id                  => p_pay_basis_id
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_pbr_attribute_category        => p_pbr_attribute_category
    ,p_pbr_attribute1                => p_pbr_attribute1
    ,p_pbr_attribute2                => p_pbr_attribute2
    ,p_pbr_attribute3                => p_pbr_attribute3
    ,p_pbr_attribute4                => p_pbr_attribute4
    ,p_pbr_attribute5                => p_pbr_attribute5
    ,p_pbr_attribute6                => p_pbr_attribute6
    ,p_pbr_attribute7                => p_pbr_attribute7
    ,p_pbr_attribute8                => p_pbr_attribute8
    ,p_pbr_attribute9                => p_pbr_attribute9
    ,p_pbr_attribute10               => p_pbr_attribute10
    ,p_pbr_attribute11               => p_pbr_attribute11
    ,p_pbr_attribute12               => p_pbr_attribute12
    ,p_pbr_attribute13               => p_pbr_attribute13
    ,p_pbr_attribute14               => p_pbr_attribute14
    ,p_pbr_attribute15               => p_pbr_attribute15
    ,p_pbr_attribute16               => p_pbr_attribute16
    ,p_pbr_attribute17               => p_pbr_attribute17
    ,p_pbr_attribute18               => p_pbr_attribute18
    ,p_pbr_attribute19               => p_pbr_attribute19
    ,p_pbr_attribute20               => p_pbr_attribute20
    ,p_pbr_attribute21               => p_pbr_attribute21
    ,p_pbr_attribute22               => p_pbr_attribute22
    ,p_pbr_attribute23               => p_pbr_attribute23
    ,p_pbr_attribute24               => p_pbr_attribute24
    ,p_pbr_attribute25               => p_pbr_attribute25
    ,p_pbr_attribute26               => p_pbr_attribute26
    ,p_pbr_attribute27               => p_pbr_attribute27
    ,p_pbr_attribute28               => p_pbr_attribute28
    ,p_pbr_attribute29               => p_pbr_attribute29
    ,p_pbr_attribute30               => p_pbr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PAY_BASIS_RATE
    --
    ben_PAY_BASIS_RATE_bk1.create_PAY_BASIS_RATE_a
      (
       p_py_bss_rt_id                   =>  l_py_bss_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_pay_basis_id                   =>  p_pay_basis_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbr_attribute_category         =>  p_pbr_attribute_category
      ,p_pbr_attribute1                 =>  p_pbr_attribute1
      ,p_pbr_attribute2                 =>  p_pbr_attribute2
      ,p_pbr_attribute3                 =>  p_pbr_attribute3
      ,p_pbr_attribute4                 =>  p_pbr_attribute4
      ,p_pbr_attribute5                 =>  p_pbr_attribute5
      ,p_pbr_attribute6                 =>  p_pbr_attribute6
      ,p_pbr_attribute7                 =>  p_pbr_attribute7
      ,p_pbr_attribute8                 =>  p_pbr_attribute8
      ,p_pbr_attribute9                 =>  p_pbr_attribute9
      ,p_pbr_attribute10                =>  p_pbr_attribute10
      ,p_pbr_attribute11                =>  p_pbr_attribute11
      ,p_pbr_attribute12                =>  p_pbr_attribute12
      ,p_pbr_attribute13                =>  p_pbr_attribute13
      ,p_pbr_attribute14                =>  p_pbr_attribute14
      ,p_pbr_attribute15                =>  p_pbr_attribute15
      ,p_pbr_attribute16                =>  p_pbr_attribute16
      ,p_pbr_attribute17                =>  p_pbr_attribute17
      ,p_pbr_attribute18                =>  p_pbr_attribute18
      ,p_pbr_attribute19                =>  p_pbr_attribute19
      ,p_pbr_attribute20                =>  p_pbr_attribute20
      ,p_pbr_attribute21                =>  p_pbr_attribute21
      ,p_pbr_attribute22                =>  p_pbr_attribute22
      ,p_pbr_attribute23                =>  p_pbr_attribute23
      ,p_pbr_attribute24                =>  p_pbr_attribute24
      ,p_pbr_attribute25                =>  p_pbr_attribute25
      ,p_pbr_attribute26                =>  p_pbr_attribute26
      ,p_pbr_attribute27                =>  p_pbr_attribute27
      ,p_pbr_attribute28                =>  p_pbr_attribute28
      ,p_pbr_attribute29                =>  p_pbr_attribute29
      ,p_pbr_attribute30                =>  p_pbr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PAY_BASIS_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PAY_BASIS_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_PY_BSS_FLAG',
     p_reference_table             => 'BEN_PY_BSS_RT_F',
     p_reference_table_column      => 'VRBL_RT_PRFL_ID');
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
  p_py_bss_rt_id := l_py_bss_rt_id;
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
    ROLLBACK TO create_PAY_BASIS_RATE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_py_bss_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PAY_BASIS_RATE;
    p_py_bss_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_PAY_BASIS_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PAY_BASIS_RATE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PAY_BASIS_RATE
  (p_validate                       in  boolean   default false
  ,p_py_bss_rt_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_pay_basis_id                   in  number    default hr_api.g_number
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pbr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pbr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PAY_BASIS_RATE';
  l_object_version_number ben_py_bss_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_py_bss_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_py_bss_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PAY_BASIS_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PAY_BASIS_RATE
    --
    ben_PAY_BASIS_RATE_bk2.update_PAY_BASIS_RATE_b
      (
       p_py_bss_rt_id                   =>  p_py_bss_rt_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_pay_basis_id                   =>  p_pay_basis_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbr_attribute_category         =>  p_pbr_attribute_category
      ,p_pbr_attribute1                 =>  p_pbr_attribute1
      ,p_pbr_attribute2                 =>  p_pbr_attribute2
      ,p_pbr_attribute3                 =>  p_pbr_attribute3
      ,p_pbr_attribute4                 =>  p_pbr_attribute4
      ,p_pbr_attribute5                 =>  p_pbr_attribute5
      ,p_pbr_attribute6                 =>  p_pbr_attribute6
      ,p_pbr_attribute7                 =>  p_pbr_attribute7
      ,p_pbr_attribute8                 =>  p_pbr_attribute8
      ,p_pbr_attribute9                 =>  p_pbr_attribute9
      ,p_pbr_attribute10                =>  p_pbr_attribute10
      ,p_pbr_attribute11                =>  p_pbr_attribute11
      ,p_pbr_attribute12                =>  p_pbr_attribute12
      ,p_pbr_attribute13                =>  p_pbr_attribute13
      ,p_pbr_attribute14                =>  p_pbr_attribute14
      ,p_pbr_attribute15                =>  p_pbr_attribute15
      ,p_pbr_attribute16                =>  p_pbr_attribute16
      ,p_pbr_attribute17                =>  p_pbr_attribute17
      ,p_pbr_attribute18                =>  p_pbr_attribute18
      ,p_pbr_attribute19                =>  p_pbr_attribute19
      ,p_pbr_attribute20                =>  p_pbr_attribute20
      ,p_pbr_attribute21                =>  p_pbr_attribute21
      ,p_pbr_attribute22                =>  p_pbr_attribute22
      ,p_pbr_attribute23                =>  p_pbr_attribute23
      ,p_pbr_attribute24                =>  p_pbr_attribute24
      ,p_pbr_attribute25                =>  p_pbr_attribute25
      ,p_pbr_attribute26                =>  p_pbr_attribute26
      ,p_pbr_attribute27                =>  p_pbr_attribute27
      ,p_pbr_attribute28                =>  p_pbr_attribute28
      ,p_pbr_attribute29                =>  p_pbr_attribute29
      ,p_pbr_attribute30                =>  p_pbr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PAY_BASIS_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PAY_BASIS_RATE
    --
  end;
  --
  ben_pbr_upd.upd
    (
     p_py_bss_rt_id                  => p_py_bss_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_pay_basis_id                  => p_pay_basis_id
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_pbr_attribute_category        => p_pbr_attribute_category
    ,p_pbr_attribute1                => p_pbr_attribute1
    ,p_pbr_attribute2                => p_pbr_attribute2
    ,p_pbr_attribute3                => p_pbr_attribute3
    ,p_pbr_attribute4                => p_pbr_attribute4
    ,p_pbr_attribute5                => p_pbr_attribute5
    ,p_pbr_attribute6                => p_pbr_attribute6
    ,p_pbr_attribute7                => p_pbr_attribute7
    ,p_pbr_attribute8                => p_pbr_attribute8
    ,p_pbr_attribute9                => p_pbr_attribute9
    ,p_pbr_attribute10               => p_pbr_attribute10
    ,p_pbr_attribute11               => p_pbr_attribute11
    ,p_pbr_attribute12               => p_pbr_attribute12
    ,p_pbr_attribute13               => p_pbr_attribute13
    ,p_pbr_attribute14               => p_pbr_attribute14
    ,p_pbr_attribute15               => p_pbr_attribute15
    ,p_pbr_attribute16               => p_pbr_attribute16
    ,p_pbr_attribute17               => p_pbr_attribute17
    ,p_pbr_attribute18               => p_pbr_attribute18
    ,p_pbr_attribute19               => p_pbr_attribute19
    ,p_pbr_attribute20               => p_pbr_attribute20
    ,p_pbr_attribute21               => p_pbr_attribute21
    ,p_pbr_attribute22               => p_pbr_attribute22
    ,p_pbr_attribute23               => p_pbr_attribute23
    ,p_pbr_attribute24               => p_pbr_attribute24
    ,p_pbr_attribute25               => p_pbr_attribute25
    ,p_pbr_attribute26               => p_pbr_attribute26
    ,p_pbr_attribute27               => p_pbr_attribute27
    ,p_pbr_attribute28               => p_pbr_attribute28
    ,p_pbr_attribute29               => p_pbr_attribute29
    ,p_pbr_attribute30               => p_pbr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PAY_BASIS_RATE
    --
    ben_PAY_BASIS_RATE_bk2.update_PAY_BASIS_RATE_a
      (
       p_py_bss_rt_id                   =>  p_py_bss_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_pay_basis_id                   =>  p_pay_basis_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbr_attribute_category         =>  p_pbr_attribute_category
      ,p_pbr_attribute1                 =>  p_pbr_attribute1
      ,p_pbr_attribute2                 =>  p_pbr_attribute2
      ,p_pbr_attribute3                 =>  p_pbr_attribute3
      ,p_pbr_attribute4                 =>  p_pbr_attribute4
      ,p_pbr_attribute5                 =>  p_pbr_attribute5
      ,p_pbr_attribute6                 =>  p_pbr_attribute6
      ,p_pbr_attribute7                 =>  p_pbr_attribute7
      ,p_pbr_attribute8                 =>  p_pbr_attribute8
      ,p_pbr_attribute9                 =>  p_pbr_attribute9
      ,p_pbr_attribute10                =>  p_pbr_attribute10
      ,p_pbr_attribute11                =>  p_pbr_attribute11
      ,p_pbr_attribute12                =>  p_pbr_attribute12
      ,p_pbr_attribute13                =>  p_pbr_attribute13
      ,p_pbr_attribute14                =>  p_pbr_attribute14
      ,p_pbr_attribute15                =>  p_pbr_attribute15
      ,p_pbr_attribute16                =>  p_pbr_attribute16
      ,p_pbr_attribute17                =>  p_pbr_attribute17
      ,p_pbr_attribute18                =>  p_pbr_attribute18
      ,p_pbr_attribute19                =>  p_pbr_attribute19
      ,p_pbr_attribute20                =>  p_pbr_attribute20
      ,p_pbr_attribute21                =>  p_pbr_attribute21
      ,p_pbr_attribute22                =>  p_pbr_attribute22
      ,p_pbr_attribute23                =>  p_pbr_attribute23
      ,p_pbr_attribute24                =>  p_pbr_attribute24
      ,p_pbr_attribute25                =>  p_pbr_attribute25
      ,p_pbr_attribute26                =>  p_pbr_attribute26
      ,p_pbr_attribute27                =>  p_pbr_attribute27
      ,p_pbr_attribute28                =>  p_pbr_attribute28
      ,p_pbr_attribute29                =>  p_pbr_attribute29
      ,p_pbr_attribute30                =>  p_pbr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PAY_BASIS_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PAY_BASIS_RATE
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
    ROLLBACK TO update_PAY_BASIS_RATE;
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
    ROLLBACK TO update_PAY_BASIS_RATE;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_PAY_BASIS_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PAY_BASIS_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PAY_BASIS_RATE
  (p_validate                       in  boolean  default false
  ,p_py_bss_rt_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PAY_BASIS_RATE';
  l_object_version_number ben_py_bss_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_py_bss_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_py_bss_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PAY_BASIS_RATE;
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
    -- Start of API User Hook for the before hook of delete_PAY_BASIS_RATE
    --
    ben_PAY_BASIS_RATE_bk3.delete_PAY_BASIS_RATE_b
      (
       p_py_bss_rt_id                   =>  p_py_bss_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PAY_BASIS_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PAY_BASIS_RATE
    --
  end;
  --
  ben_pbr_del.del
    (
     p_py_bss_rt_id                  => p_py_bss_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PAY_BASIS_RATE
    --
    ben_PAY_BASIS_RATE_bk3.delete_PAY_BASIS_RATE_a
      (
       p_py_bss_rt_id                   =>  p_py_bss_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PAY_BASIS_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PAY_BASIS_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => ben_pbr_shd.g_old_rec.vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_PY_BSS_FLAG',
     p_reference_table             => 'BEN_PY_BSS_RT_F',
     p_reference_table_column      => 'VRBL_RT_PRFL_ID');
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
    ROLLBACK TO delete_PAY_BASIS_RATE;
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
    ROLLBACK TO delete_PAY_BASIS_RATE;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_PAY_BASIS_RATE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_py_bss_rt_id                   in     number
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
  ben_pbr_shd.lck
    (
      p_py_bss_rt_id                 => p_py_bss_rt_id
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
end ben_PAY_BASIS_RATE_api;

/
