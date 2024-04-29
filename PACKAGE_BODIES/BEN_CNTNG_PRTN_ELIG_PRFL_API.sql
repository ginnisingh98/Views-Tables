--------------------------------------------------------
--  DDL for Package Body BEN_CNTNG_PRTN_ELIG_PRFL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CNTNG_PRTN_ELIG_PRFL_API" as
/* $Header: becgpapi.pkb 120.0 2005/05/28 01:01:37 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_CNTNG_PRTN_ELIG_PRFL_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_CNTNG_PRTN_ELIG_PRFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_CNTNG_PRTN_ELIG_PRFL
  (p_validate                       in  boolean   default false
  ,p_cntng_prtn_elig_prfl_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_eligy_prfl_id                  in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_pymt_must_be_rcvd_uom          in  varchar2  default null
  ,p_pymt_must_be_rcvd_num          in  number    default null
  ,p_pymt_must_be_rcvd_rl           in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_cgp_attribute_category         in  varchar2  default null
  ,p_cgp_attribute1                 in  varchar2  default null
  ,p_cgp_attribute2                 in  varchar2  default null
  ,p_cgp_attribute3                 in  varchar2  default null
  ,p_cgp_attribute4                 in  varchar2  default null
  ,p_cgp_attribute5                 in  varchar2  default null
  ,p_cgp_attribute6                 in  varchar2  default null
  ,p_cgp_attribute7                 in  varchar2  default null
  ,p_cgp_attribute8                 in  varchar2  default null
  ,p_cgp_attribute9                 in  varchar2  default null
  ,p_cgp_attribute10                in  varchar2  default null
  ,p_cgp_attribute11                in  varchar2  default null
  ,p_cgp_attribute12                in  varchar2  default null
  ,p_cgp_attribute13                in  varchar2  default null
  ,p_cgp_attribute14                in  varchar2  default null
  ,p_cgp_attribute15                in  varchar2  default null
  ,p_cgp_attribute16                in  varchar2  default null
  ,p_cgp_attribute17                in  varchar2  default null
  ,p_cgp_attribute18                in  varchar2  default null
  ,p_cgp_attribute19                in  varchar2  default null
  ,p_cgp_attribute20                in  varchar2  default null
  ,p_cgp_attribute21                in  varchar2  default null
  ,p_cgp_attribute22                in  varchar2  default null
  ,p_cgp_attribute23                in  varchar2  default null
  ,p_cgp_attribute24                in  varchar2  default null
  ,p_cgp_attribute25                in  varchar2  default null
  ,p_cgp_attribute26                in  varchar2  default null
  ,p_cgp_attribute27                in  varchar2  default null
  ,p_cgp_attribute28                in  varchar2  default null
  ,p_cgp_attribute29                in  varchar2  default null
  ,p_cgp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cntng_prtn_elig_prfl_id ben_cntng_prtn_elig_prfl_f.cntng_prtn_elig_prfl_id%TYPE;
  l_effective_start_date ben_cntng_prtn_elig_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_cntng_prtn_elig_prfl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_CNTNG_PRTN_ELIG_PRFL';
  l_object_version_number ben_cntng_prtn_elig_prfl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_CNTNG_PRTN_ELIG_PRFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_CNTNG_PRTN_ELIG_PRFL
    --
    ben_CNTNG_PRTN_ELIG_PRFL_bk1.create_CNTNG_PRTN_ELIG_PRFL_b
      (
       p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_name                           =>  p_name
      ,p_pymt_must_be_rcvd_uom          =>  p_pymt_must_be_rcvd_uom
      ,p_pymt_must_be_rcvd_num          =>  p_pymt_must_be_rcvd_num
      ,p_pymt_must_be_rcvd_rl           =>  p_pymt_must_be_rcvd_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_cgp_attribute_category         =>  p_cgp_attribute_category
      ,p_cgp_attribute1                 =>  p_cgp_attribute1
      ,p_cgp_attribute2                 =>  p_cgp_attribute2
      ,p_cgp_attribute3                 =>  p_cgp_attribute3
      ,p_cgp_attribute4                 =>  p_cgp_attribute4
      ,p_cgp_attribute5                 =>  p_cgp_attribute5
      ,p_cgp_attribute6                 =>  p_cgp_attribute6
      ,p_cgp_attribute7                 =>  p_cgp_attribute7
      ,p_cgp_attribute8                 =>  p_cgp_attribute8
      ,p_cgp_attribute9                 =>  p_cgp_attribute9
      ,p_cgp_attribute10                =>  p_cgp_attribute10
      ,p_cgp_attribute11                =>  p_cgp_attribute11
      ,p_cgp_attribute12                =>  p_cgp_attribute12
      ,p_cgp_attribute13                =>  p_cgp_attribute13
      ,p_cgp_attribute14                =>  p_cgp_attribute14
      ,p_cgp_attribute15                =>  p_cgp_attribute15
      ,p_cgp_attribute16                =>  p_cgp_attribute16
      ,p_cgp_attribute17                =>  p_cgp_attribute17
      ,p_cgp_attribute18                =>  p_cgp_attribute18
      ,p_cgp_attribute19                =>  p_cgp_attribute19
      ,p_cgp_attribute20                =>  p_cgp_attribute20
      ,p_cgp_attribute21                =>  p_cgp_attribute21
      ,p_cgp_attribute22                =>  p_cgp_attribute22
      ,p_cgp_attribute23                =>  p_cgp_attribute23
      ,p_cgp_attribute24                =>  p_cgp_attribute24
      ,p_cgp_attribute25                =>  p_cgp_attribute25
      ,p_cgp_attribute26                =>  p_cgp_attribute26
      ,p_cgp_attribute27                =>  p_cgp_attribute27
      ,p_cgp_attribute28                =>  p_cgp_attribute28
      ,p_cgp_attribute29                =>  p_cgp_attribute29
      ,p_cgp_attribute30                =>  p_cgp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CNTNG_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_CNTNG_PRTN_ELIG_PRFL
    --
  end;
  --
  ben_cgp_ins.ins
    (
     p_cntng_prtn_elig_prfl_id       => l_cntng_prtn_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_name                          => p_name
    ,p_pymt_must_be_rcvd_uom         => p_pymt_must_be_rcvd_uom
    ,p_pymt_must_be_rcvd_num         => p_pymt_must_be_rcvd_num
    ,p_pymt_must_be_rcvd_rl          => p_pymt_must_be_rcvd_rl
    ,p_business_group_id             => p_business_group_id
    ,p_cgp_attribute_category        => p_cgp_attribute_category
    ,p_cgp_attribute1                => p_cgp_attribute1
    ,p_cgp_attribute2                => p_cgp_attribute2
    ,p_cgp_attribute3                => p_cgp_attribute3
    ,p_cgp_attribute4                => p_cgp_attribute4
    ,p_cgp_attribute5                => p_cgp_attribute5
    ,p_cgp_attribute6                => p_cgp_attribute6
    ,p_cgp_attribute7                => p_cgp_attribute7
    ,p_cgp_attribute8                => p_cgp_attribute8
    ,p_cgp_attribute9                => p_cgp_attribute9
    ,p_cgp_attribute10               => p_cgp_attribute10
    ,p_cgp_attribute11               => p_cgp_attribute11
    ,p_cgp_attribute12               => p_cgp_attribute12
    ,p_cgp_attribute13               => p_cgp_attribute13
    ,p_cgp_attribute14               => p_cgp_attribute14
    ,p_cgp_attribute15               => p_cgp_attribute15
    ,p_cgp_attribute16               => p_cgp_attribute16
    ,p_cgp_attribute17               => p_cgp_attribute17
    ,p_cgp_attribute18               => p_cgp_attribute18
    ,p_cgp_attribute19               => p_cgp_attribute19
    ,p_cgp_attribute20               => p_cgp_attribute20
    ,p_cgp_attribute21               => p_cgp_attribute21
    ,p_cgp_attribute22               => p_cgp_attribute22
    ,p_cgp_attribute23               => p_cgp_attribute23
    ,p_cgp_attribute24               => p_cgp_attribute24
    ,p_cgp_attribute25               => p_cgp_attribute25
    ,p_cgp_attribute26               => p_cgp_attribute26
    ,p_cgp_attribute27               => p_cgp_attribute27
    ,p_cgp_attribute28               => p_cgp_attribute28
    ,p_cgp_attribute29               => p_cgp_attribute29
    ,p_cgp_attribute30               => p_cgp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_CNTNG_PRTN_ELIG_PRFL
    --
    ben_CNTNG_PRTN_ELIG_PRFL_bk1.create_CNTNG_PRTN_ELIG_PRFL_a
      (
       p_cntng_prtn_elig_prfl_id        =>  l_cntng_prtn_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_name                           =>  p_name
      ,p_pymt_must_be_rcvd_uom          =>  p_pymt_must_be_rcvd_uom
      ,p_pymt_must_be_rcvd_num          =>  p_pymt_must_be_rcvd_num
      ,p_pymt_must_be_rcvd_rl           =>  p_pymt_must_be_rcvd_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_cgp_attribute_category         =>  p_cgp_attribute_category
      ,p_cgp_attribute1                 =>  p_cgp_attribute1
      ,p_cgp_attribute2                 =>  p_cgp_attribute2
      ,p_cgp_attribute3                 =>  p_cgp_attribute3
      ,p_cgp_attribute4                 =>  p_cgp_attribute4
      ,p_cgp_attribute5                 =>  p_cgp_attribute5
      ,p_cgp_attribute6                 =>  p_cgp_attribute6
      ,p_cgp_attribute7                 =>  p_cgp_attribute7
      ,p_cgp_attribute8                 =>  p_cgp_attribute8
      ,p_cgp_attribute9                 =>  p_cgp_attribute9
      ,p_cgp_attribute10                =>  p_cgp_attribute10
      ,p_cgp_attribute11                =>  p_cgp_attribute11
      ,p_cgp_attribute12                =>  p_cgp_attribute12
      ,p_cgp_attribute13                =>  p_cgp_attribute13
      ,p_cgp_attribute14                =>  p_cgp_attribute14
      ,p_cgp_attribute15                =>  p_cgp_attribute15
      ,p_cgp_attribute16                =>  p_cgp_attribute16
      ,p_cgp_attribute17                =>  p_cgp_attribute17
      ,p_cgp_attribute18                =>  p_cgp_attribute18
      ,p_cgp_attribute19                =>  p_cgp_attribute19
      ,p_cgp_attribute20                =>  p_cgp_attribute20
      ,p_cgp_attribute21                =>  p_cgp_attribute21
      ,p_cgp_attribute22                =>  p_cgp_attribute22
      ,p_cgp_attribute23                =>  p_cgp_attribute23
      ,p_cgp_attribute24                =>  p_cgp_attribute24
      ,p_cgp_attribute25                =>  p_cgp_attribute25
      ,p_cgp_attribute26                =>  p_cgp_attribute26
      ,p_cgp_attribute27                =>  p_cgp_attribute27
      ,p_cgp_attribute28                =>  p_cgp_attribute28
      ,p_cgp_attribute29                =>  p_cgp_attribute29
      ,p_cgp_attribute30                =>  p_cgp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CNTNG_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_CNTNG_PRTN_ELIG_PRFL
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     => p_eligy_prfl_id,
     p_base_table_reference_column => 'CNTNG_PRTN_ELIG_PRFL_FLAG',
     p_reference_table             => 'BEN_CNTNG_PRTN_ELIG_PRFL_F',
     p_reference_table_column      => 'ELIGY_PRFL_ID');
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
  p_cntng_prtn_elig_prfl_id := l_cntng_prtn_elig_prfl_id;
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
    ROLLBACK TO create_CNTNG_PRTN_ELIG_PRFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cntng_prtn_elig_prfl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_CNTNG_PRTN_ELIG_PRFL;
     --
    p_cntng_prtn_elig_prfl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    raise;
    --
end create_CNTNG_PRTN_ELIG_PRFL;
-- ----------------------------------------------------------------------------
-- |------------------------< update_CNTNG_PRTN_ELIG_PRFL >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_CNTNG_PRTN_ELIG_PRFL
  (p_validate                       in  boolean   default false
  ,p_cntng_prtn_elig_prfl_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_pymt_must_be_rcvd_uom          in  varchar2  default hr_api.g_varchar2
  ,p_pymt_must_be_rcvd_num          in  number    default hr_api.g_number
  ,p_pymt_must_be_rcvd_rl           in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cgp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cgp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CNTNG_PRTN_ELIG_PRFL';
  l_object_version_number ben_cntng_prtn_elig_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_cntng_prtn_elig_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_cntng_prtn_elig_prfl_f.effective_end_date%TYPE;
  l_in_object_version_number  number  := p_object_version_number ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_CNTNG_PRTN_ELIG_PRFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_CNTNG_PRTN_ELIG_PRFL
    --
    ben_CNTNG_PRTN_ELIG_PRFL_bk2.update_CNTNG_PRTN_ELIG_PRFL_b
      (
       p_cntng_prtn_elig_prfl_id        =>  p_cntng_prtn_elig_prfl_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_name                           =>  p_name
      ,p_pymt_must_be_rcvd_uom          =>  p_pymt_must_be_rcvd_uom
      ,p_pymt_must_be_rcvd_num          =>  p_pymt_must_be_rcvd_num
      ,p_pymt_must_be_rcvd_rl           =>  p_pymt_must_be_rcvd_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_cgp_attribute_category         =>  p_cgp_attribute_category
      ,p_cgp_attribute1                 =>  p_cgp_attribute1
      ,p_cgp_attribute2                 =>  p_cgp_attribute2
      ,p_cgp_attribute3                 =>  p_cgp_attribute3
      ,p_cgp_attribute4                 =>  p_cgp_attribute4
      ,p_cgp_attribute5                 =>  p_cgp_attribute5
      ,p_cgp_attribute6                 =>  p_cgp_attribute6
      ,p_cgp_attribute7                 =>  p_cgp_attribute7
      ,p_cgp_attribute8                 =>  p_cgp_attribute8
      ,p_cgp_attribute9                 =>  p_cgp_attribute9
      ,p_cgp_attribute10                =>  p_cgp_attribute10
      ,p_cgp_attribute11                =>  p_cgp_attribute11
      ,p_cgp_attribute12                =>  p_cgp_attribute12
      ,p_cgp_attribute13                =>  p_cgp_attribute13
      ,p_cgp_attribute14                =>  p_cgp_attribute14
      ,p_cgp_attribute15                =>  p_cgp_attribute15
      ,p_cgp_attribute16                =>  p_cgp_attribute16
      ,p_cgp_attribute17                =>  p_cgp_attribute17
      ,p_cgp_attribute18                =>  p_cgp_attribute18
      ,p_cgp_attribute19                =>  p_cgp_attribute19
      ,p_cgp_attribute20                =>  p_cgp_attribute20
      ,p_cgp_attribute21                =>  p_cgp_attribute21
      ,p_cgp_attribute22                =>  p_cgp_attribute22
      ,p_cgp_attribute23                =>  p_cgp_attribute23
      ,p_cgp_attribute24                =>  p_cgp_attribute24
      ,p_cgp_attribute25                =>  p_cgp_attribute25
      ,p_cgp_attribute26                =>  p_cgp_attribute26
      ,p_cgp_attribute27                =>  p_cgp_attribute27
      ,p_cgp_attribute28                =>  p_cgp_attribute28
      ,p_cgp_attribute29                =>  p_cgp_attribute29
      ,p_cgp_attribute30                =>  p_cgp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CNTNG_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_CNTNG_PRTN_ELIG_PRFL
    --
  end;
  --
  ben_cgp_upd.upd
    (
     p_cntng_prtn_elig_prfl_id       => p_cntng_prtn_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_name                          => p_name
    ,p_pymt_must_be_rcvd_uom         => p_pymt_must_be_rcvd_uom
    ,p_pymt_must_be_rcvd_num         => p_pymt_must_be_rcvd_num
    ,p_pymt_must_be_rcvd_rl          => p_pymt_must_be_rcvd_rl
    ,p_business_group_id             => p_business_group_id
    ,p_cgp_attribute_category        => p_cgp_attribute_category
    ,p_cgp_attribute1                => p_cgp_attribute1
    ,p_cgp_attribute2                => p_cgp_attribute2
    ,p_cgp_attribute3                => p_cgp_attribute3
    ,p_cgp_attribute4                => p_cgp_attribute4
    ,p_cgp_attribute5                => p_cgp_attribute5
    ,p_cgp_attribute6                => p_cgp_attribute6
    ,p_cgp_attribute7                => p_cgp_attribute7
    ,p_cgp_attribute8                => p_cgp_attribute8
    ,p_cgp_attribute9                => p_cgp_attribute9
    ,p_cgp_attribute10               => p_cgp_attribute10
    ,p_cgp_attribute11               => p_cgp_attribute11
    ,p_cgp_attribute12               => p_cgp_attribute12
    ,p_cgp_attribute13               => p_cgp_attribute13
    ,p_cgp_attribute14               => p_cgp_attribute14
    ,p_cgp_attribute15               => p_cgp_attribute15
    ,p_cgp_attribute16               => p_cgp_attribute16
    ,p_cgp_attribute17               => p_cgp_attribute17
    ,p_cgp_attribute18               => p_cgp_attribute18
    ,p_cgp_attribute19               => p_cgp_attribute19
    ,p_cgp_attribute20               => p_cgp_attribute20
    ,p_cgp_attribute21               => p_cgp_attribute21
    ,p_cgp_attribute22               => p_cgp_attribute22
    ,p_cgp_attribute23               => p_cgp_attribute23
    ,p_cgp_attribute24               => p_cgp_attribute24
    ,p_cgp_attribute25               => p_cgp_attribute25
    ,p_cgp_attribute26               => p_cgp_attribute26
    ,p_cgp_attribute27               => p_cgp_attribute27
    ,p_cgp_attribute28               => p_cgp_attribute28
    ,p_cgp_attribute29               => p_cgp_attribute29
    ,p_cgp_attribute30               => p_cgp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_CNTNG_PRTN_ELIG_PRFL
    --
    ben_CNTNG_PRTN_ELIG_PRFL_bk2.update_CNTNG_PRTN_ELIG_PRFL_a
      (
       p_cntng_prtn_elig_prfl_id        =>  p_cntng_prtn_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_name                           =>  p_name
      ,p_pymt_must_be_rcvd_uom          =>  p_pymt_must_be_rcvd_uom
      ,p_pymt_must_be_rcvd_num          =>  p_pymt_must_be_rcvd_num
      ,p_pymt_must_be_rcvd_rl           =>  p_pymt_must_be_rcvd_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_cgp_attribute_category         =>  p_cgp_attribute_category
      ,p_cgp_attribute1                 =>  p_cgp_attribute1
      ,p_cgp_attribute2                 =>  p_cgp_attribute2
      ,p_cgp_attribute3                 =>  p_cgp_attribute3
      ,p_cgp_attribute4                 =>  p_cgp_attribute4
      ,p_cgp_attribute5                 =>  p_cgp_attribute5
      ,p_cgp_attribute6                 =>  p_cgp_attribute6
      ,p_cgp_attribute7                 =>  p_cgp_attribute7
      ,p_cgp_attribute8                 =>  p_cgp_attribute8
      ,p_cgp_attribute9                 =>  p_cgp_attribute9
      ,p_cgp_attribute10                =>  p_cgp_attribute10
      ,p_cgp_attribute11                =>  p_cgp_attribute11
      ,p_cgp_attribute12                =>  p_cgp_attribute12
      ,p_cgp_attribute13                =>  p_cgp_attribute13
      ,p_cgp_attribute14                =>  p_cgp_attribute14
      ,p_cgp_attribute15                =>  p_cgp_attribute15
      ,p_cgp_attribute16                =>  p_cgp_attribute16
      ,p_cgp_attribute17                =>  p_cgp_attribute17
      ,p_cgp_attribute18                =>  p_cgp_attribute18
      ,p_cgp_attribute19                =>  p_cgp_attribute19
      ,p_cgp_attribute20                =>  p_cgp_attribute20
      ,p_cgp_attribute21                =>  p_cgp_attribute21
      ,p_cgp_attribute22                =>  p_cgp_attribute22
      ,p_cgp_attribute23                =>  p_cgp_attribute23
      ,p_cgp_attribute24                =>  p_cgp_attribute24
      ,p_cgp_attribute25                =>  p_cgp_attribute25
      ,p_cgp_attribute26                =>  p_cgp_attribute26
      ,p_cgp_attribute27                =>  p_cgp_attribute27
      ,p_cgp_attribute28                =>  p_cgp_attribute28
      ,p_cgp_attribute29                =>  p_cgp_attribute29
      ,p_cgp_attribute30                =>  p_cgp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CNTNG_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_CNTNG_PRTN_ELIG_PRFL
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
    ROLLBACK TO update_CNTNG_PRTN_ELIG_PRFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := l_effective_start_date;
    p_effective_end_date := l_effective_end_date;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    p_object_version_number := l_in_object_version_number ;
    --
    ROLLBACK TO update_CNTNG_PRTN_ELIG_PRFL;
    p_effective_start_date := l_effective_start_date;
    p_effective_end_date := l_effective_end_date;
    raise;
    --
end update_CNTNG_PRTN_ELIG_PRFL;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CNTNG_PRTN_ELIG_PRFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CNTNG_PRTN_ELIG_PRFL
  (p_validate                       in  boolean  default false
  ,p_cntng_prtn_elig_prfl_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CNTNG_PRTN_ELIG_PRFL';
  l_object_version_number ben_cntng_prtn_elig_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_cntng_prtn_elig_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_cntng_prtn_elig_prfl_f.effective_end_date%TYPE;
  l_in_object_version_number  number  := p_object_version_number ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_CNTNG_PRTN_ELIG_PRFL;
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
    -- Start of API User Hook for the before hook of delete_CNTNG_PRTN_ELIG_PRFL
    --
    ben_CNTNG_PRTN_ELIG_PRFL_bk3.delete_CNTNG_PRTN_ELIG_PRFL_b
      (
       p_cntng_prtn_elig_prfl_id        =>  p_cntng_prtn_elig_prfl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CNTNG_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_CNTNG_PRTN_ELIG_PRFL
    --
  end;
  --
  ben_cgp_del.del
    (
     p_cntng_prtn_elig_prfl_id       => p_cntng_prtn_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_CNTNG_PRTN_ELIG_PRFL
    --
    ben_CNTNG_PRTN_ELIG_PRFL_bk3.delete_CNTNG_PRTN_ELIG_PRFL_a
      (
       p_cntng_prtn_elig_prfl_id        =>  p_cntng_prtn_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CNTNG_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_CNTNG_PRTN_ELIG_PRFL
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     => ben_cgp_shd.g_old_rec.eligy_prfl_id,
     p_base_table_reference_column => 'CNTNG_PRTN_ELIG_PRFL_FLAG',
     p_reference_table             => 'BEN_CNTNG_PRTN_ELIG_PRFL_F',
     p_reference_table_column      => 'ELIGY_PRFL_ID');
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
    ROLLBACK TO delete_CNTNG_PRTN_ELIG_PRFL;
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
    p_object_version_number := l_in_object_version_number ;
    --
    ROLLBACK TO delete_CNTNG_PRTN_ELIG_PRFL;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end delete_CNTNG_PRTN_ELIG_PRFL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cntng_prtn_elig_prfl_id                   in     number
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
  ben_cgp_shd.lck
    (
      p_cntng_prtn_elig_prfl_id                 => p_cntng_prtn_elig_prfl_id
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
end ben_CNTNG_PRTN_ELIG_PRFL_api;

/
