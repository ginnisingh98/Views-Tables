--------------------------------------------------------
--  DDL for Package Body BEN_CBR_PER_IN_LER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CBR_PER_IN_LER_API" as
/* $Header: becrpapi.pkb 115.4 2003/01/16 14:33:52 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_CBR_PER_IN_LER_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_CBR_PER_IN_LER >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_CBR_PER_IN_LER
  (p_validate                       in  boolean   default false
  ,p_cbr_per_in_ler_id              out nocopy number
  ,p_init_evt_flag                  in  varchar2  default 'N'
  ,p_cnt_num                        in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_cbr_quald_bnf_id               in  number    default null
  ,p_prvs_elig_perd_end_dt          in  date      default null
  ,p_business_group_id              in  number    default null
  ,p_crp_attribute_category         in  varchar2  default null
  ,p_crp_attribute1                 in  varchar2  default null
  ,p_crp_attribute2                 in  varchar2  default null
  ,p_crp_attribute3                 in  varchar2  default null
  ,p_crp_attribute4                 in  varchar2  default null
  ,p_crp_attribute5                 in  varchar2  default null
  ,p_crp_attribute6                 in  varchar2  default null
  ,p_crp_attribute7                 in  varchar2  default null
  ,p_crp_attribute8                 in  varchar2  default null
  ,p_crp_attribute9                 in  varchar2  default null
  ,p_crp_attribute10                in  varchar2  default null
  ,p_crp_attribute11                in  varchar2  default null
  ,p_crp_attribute12                in  varchar2  default null
  ,p_crp_attribute13                in  varchar2  default null
  ,p_crp_attribute14                in  varchar2  default null
  ,p_crp_attribute15                in  varchar2  default null
  ,p_crp_attribute16                in  varchar2  default null
  ,p_crp_attribute17                in  varchar2  default null
  ,p_crp_attribute18                in  varchar2  default null
  ,p_crp_attribute19                in  varchar2  default null
  ,p_crp_attribute20                in  varchar2  default null
  ,p_crp_attribute21                in  varchar2  default null
  ,p_crp_attribute22                in  varchar2  default null
  ,p_crp_attribute23                in  varchar2  default null
  ,p_crp_attribute24                in  varchar2  default null
  ,p_crp_attribute25                in  varchar2  default null
  ,p_crp_attribute26                in  varchar2  default null
  ,p_crp_attribute27                in  varchar2  default null
  ,p_crp_attribute28                in  varchar2  default null
  ,p_crp_attribute29                in  varchar2  default null
  ,p_crp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cbr_per_in_ler_id ben_cbr_per_in_ler.cbr_per_in_ler_id%TYPE;
  l_proc varchar2(72) := g_package||'create_CBR_PER_IN_LER';
  l_object_version_number ben_cbr_per_in_ler.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_CBR_PER_IN_LER;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_CBR_PER_IN_LER
    --
    ben_CBR_PER_IN_LER_bk1.create_CBR_PER_IN_LER_b
      (
       p_init_evt_flag                  =>  p_init_evt_flag
      ,p_cnt_num                        =>  p_cnt_num
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_cbr_quald_bnf_id               =>  p_cbr_quald_bnf_id
      ,p_prvs_elig_perd_end_dt          =>  p_prvs_elig_perd_end_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_crp_attribute_category         =>  p_crp_attribute_category
      ,p_crp_attribute1                 =>  p_crp_attribute1
      ,p_crp_attribute2                 =>  p_crp_attribute2
      ,p_crp_attribute3                 =>  p_crp_attribute3
      ,p_crp_attribute4                 =>  p_crp_attribute4
      ,p_crp_attribute5                 =>  p_crp_attribute5
      ,p_crp_attribute6                 =>  p_crp_attribute6
      ,p_crp_attribute7                 =>  p_crp_attribute7
      ,p_crp_attribute8                 =>  p_crp_attribute8
      ,p_crp_attribute9                 =>  p_crp_attribute9
      ,p_crp_attribute10                =>  p_crp_attribute10
      ,p_crp_attribute11                =>  p_crp_attribute11
      ,p_crp_attribute12                =>  p_crp_attribute12
      ,p_crp_attribute13                =>  p_crp_attribute13
      ,p_crp_attribute14                =>  p_crp_attribute14
      ,p_crp_attribute15                =>  p_crp_attribute15
      ,p_crp_attribute16                =>  p_crp_attribute16
      ,p_crp_attribute17                =>  p_crp_attribute17
      ,p_crp_attribute18                =>  p_crp_attribute18
      ,p_crp_attribute19                =>  p_crp_attribute19
      ,p_crp_attribute20                =>  p_crp_attribute20
      ,p_crp_attribute21                =>  p_crp_attribute21
      ,p_crp_attribute22                =>  p_crp_attribute22
      ,p_crp_attribute23                =>  p_crp_attribute23
      ,p_crp_attribute24                =>  p_crp_attribute24
      ,p_crp_attribute25                =>  p_crp_attribute25
      ,p_crp_attribute26                =>  p_crp_attribute26
      ,p_crp_attribute27                =>  p_crp_attribute27
      ,p_crp_attribute28                =>  p_crp_attribute28
      ,p_crp_attribute29                =>  p_crp_attribute29
      ,p_crp_attribute30                =>  p_crp_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CBR_PER_IN_LER'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_CBR_PER_IN_LER
    --
  end;
  --
  ben_crp_ins.ins
    (
     p_cbr_per_in_ler_id             => l_cbr_per_in_ler_id
    ,p_init_evt_flag                 => p_init_evt_flag
    ,p_cnt_num                       => p_cnt_num
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_cbr_quald_bnf_id              => p_cbr_quald_bnf_id
    ,p_prvs_elig_perd_end_dt         => p_prvs_elig_perd_end_dt
    ,p_business_group_id             => p_business_group_id
    ,p_crp_attribute_category        => p_crp_attribute_category
    ,p_crp_attribute1                => p_crp_attribute1
    ,p_crp_attribute2                => p_crp_attribute2
    ,p_crp_attribute3                => p_crp_attribute3
    ,p_crp_attribute4                => p_crp_attribute4
    ,p_crp_attribute5                => p_crp_attribute5
    ,p_crp_attribute6                => p_crp_attribute6
    ,p_crp_attribute7                => p_crp_attribute7
    ,p_crp_attribute8                => p_crp_attribute8
    ,p_crp_attribute9                => p_crp_attribute9
    ,p_crp_attribute10               => p_crp_attribute10
    ,p_crp_attribute11               => p_crp_attribute11
    ,p_crp_attribute12               => p_crp_attribute12
    ,p_crp_attribute13               => p_crp_attribute13
    ,p_crp_attribute14               => p_crp_attribute14
    ,p_crp_attribute15               => p_crp_attribute15
    ,p_crp_attribute16               => p_crp_attribute16
    ,p_crp_attribute17               => p_crp_attribute17
    ,p_crp_attribute18               => p_crp_attribute18
    ,p_crp_attribute19               => p_crp_attribute19
    ,p_crp_attribute20               => p_crp_attribute20
    ,p_crp_attribute21               => p_crp_attribute21
    ,p_crp_attribute22               => p_crp_attribute22
    ,p_crp_attribute23               => p_crp_attribute23
    ,p_crp_attribute24               => p_crp_attribute24
    ,p_crp_attribute25               => p_crp_attribute25
    ,p_crp_attribute26               => p_crp_attribute26
    ,p_crp_attribute27               => p_crp_attribute27
    ,p_crp_attribute28               => p_crp_attribute28
    ,p_crp_attribute29               => p_crp_attribute29
    ,p_crp_attribute30               => p_crp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_CBR_PER_IN_LER
    --
    ben_CBR_PER_IN_LER_bk1.create_CBR_PER_IN_LER_a
      (
       p_cbr_per_in_ler_id              =>  l_cbr_per_in_ler_id
      ,p_init_evt_flag                  =>  p_init_evt_flag
      ,p_cnt_num                        =>  p_cnt_num
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_cbr_quald_bnf_id               =>  p_cbr_quald_bnf_id
      ,p_prvs_elig_perd_end_dt          =>  p_prvs_elig_perd_end_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_crp_attribute_category         =>  p_crp_attribute_category
      ,p_crp_attribute1                 =>  p_crp_attribute1
      ,p_crp_attribute2                 =>  p_crp_attribute2
      ,p_crp_attribute3                 =>  p_crp_attribute3
      ,p_crp_attribute4                 =>  p_crp_attribute4
      ,p_crp_attribute5                 =>  p_crp_attribute5
      ,p_crp_attribute6                 =>  p_crp_attribute6
      ,p_crp_attribute7                 =>  p_crp_attribute7
      ,p_crp_attribute8                 =>  p_crp_attribute8
      ,p_crp_attribute9                 =>  p_crp_attribute9
      ,p_crp_attribute10                =>  p_crp_attribute10
      ,p_crp_attribute11                =>  p_crp_attribute11
      ,p_crp_attribute12                =>  p_crp_attribute12
      ,p_crp_attribute13                =>  p_crp_attribute13
      ,p_crp_attribute14                =>  p_crp_attribute14
      ,p_crp_attribute15                =>  p_crp_attribute15
      ,p_crp_attribute16                =>  p_crp_attribute16
      ,p_crp_attribute17                =>  p_crp_attribute17
      ,p_crp_attribute18                =>  p_crp_attribute18
      ,p_crp_attribute19                =>  p_crp_attribute19
      ,p_crp_attribute20                =>  p_crp_attribute20
      ,p_crp_attribute21                =>  p_crp_attribute21
      ,p_crp_attribute22                =>  p_crp_attribute22
      ,p_crp_attribute23                =>  p_crp_attribute23
      ,p_crp_attribute24                =>  p_crp_attribute24
      ,p_crp_attribute25                =>  p_crp_attribute25
      ,p_crp_attribute26                =>  p_crp_attribute26
      ,p_crp_attribute27                =>  p_crp_attribute27
      ,p_crp_attribute28                =>  p_crp_attribute28
      ,p_crp_attribute29                =>  p_crp_attribute29
      ,p_crp_attribute30                =>  p_crp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CBR_PER_IN_LER'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_CBR_PER_IN_LER
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
  p_cbr_per_in_ler_id := l_cbr_per_in_ler_id;
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
    ROLLBACK TO create_CBR_PER_IN_LER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cbr_per_in_ler_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_CBR_PER_IN_LER;
    p_cbr_per_in_ler_id := null; --nocopy change
    p_object_version_number := null; --nocopy change
    raise;
    --
end create_CBR_PER_IN_LER;
-- ----------------------------------------------------------------------------
-- |------------------------< update_CBR_PER_IN_LER >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_CBR_PER_IN_LER
  (p_validate                       in  boolean   default false
  ,p_cbr_per_in_ler_id              in  number
  ,p_init_evt_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_cnt_num                        in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_cbr_quald_bnf_id               in  number    default hr_api.g_number
  ,p_prvs_elig_perd_end_dt          in  date      default hr_api.g_date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_crp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_crp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CBR_PER_IN_LER';
  l_object_version_number ben_cbr_per_in_ler.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_CBR_PER_IN_LER;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_CBR_PER_IN_LER
    --
    ben_CBR_PER_IN_LER_bk2.update_CBR_PER_IN_LER_b
      (
       p_cbr_per_in_ler_id              =>  p_cbr_per_in_ler_id
      ,p_init_evt_flag                  =>  p_init_evt_flag
      ,p_cnt_num                        =>  p_cnt_num
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_cbr_quald_bnf_id               =>  p_cbr_quald_bnf_id
      ,p_prvs_elig_perd_end_dt          =>  p_prvs_elig_perd_end_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_crp_attribute_category         =>  p_crp_attribute_category
      ,p_crp_attribute1                 =>  p_crp_attribute1
      ,p_crp_attribute2                 =>  p_crp_attribute2
      ,p_crp_attribute3                 =>  p_crp_attribute3
      ,p_crp_attribute4                 =>  p_crp_attribute4
      ,p_crp_attribute5                 =>  p_crp_attribute5
      ,p_crp_attribute6                 =>  p_crp_attribute6
      ,p_crp_attribute7                 =>  p_crp_attribute7
      ,p_crp_attribute8                 =>  p_crp_attribute8
      ,p_crp_attribute9                 =>  p_crp_attribute9
      ,p_crp_attribute10                =>  p_crp_attribute10
      ,p_crp_attribute11                =>  p_crp_attribute11
      ,p_crp_attribute12                =>  p_crp_attribute12
      ,p_crp_attribute13                =>  p_crp_attribute13
      ,p_crp_attribute14                =>  p_crp_attribute14
      ,p_crp_attribute15                =>  p_crp_attribute15
      ,p_crp_attribute16                =>  p_crp_attribute16
      ,p_crp_attribute17                =>  p_crp_attribute17
      ,p_crp_attribute18                =>  p_crp_attribute18
      ,p_crp_attribute19                =>  p_crp_attribute19
      ,p_crp_attribute20                =>  p_crp_attribute20
      ,p_crp_attribute21                =>  p_crp_attribute21
      ,p_crp_attribute22                =>  p_crp_attribute22
      ,p_crp_attribute23                =>  p_crp_attribute23
      ,p_crp_attribute24                =>  p_crp_attribute24
      ,p_crp_attribute25                =>  p_crp_attribute25
      ,p_crp_attribute26                =>  p_crp_attribute26
      ,p_crp_attribute27                =>  p_crp_attribute27
      ,p_crp_attribute28                =>  p_crp_attribute28
      ,p_crp_attribute29                =>  p_crp_attribute29
      ,p_crp_attribute30                =>  p_crp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CBR_PER_IN_LER'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_CBR_PER_IN_LER
    --
  end;
  --
  ben_crp_upd.upd
    (
     p_cbr_per_in_ler_id             => p_cbr_per_in_ler_id
    ,p_init_evt_flag                 => p_init_evt_flag
    ,p_cnt_num                       => p_cnt_num
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_cbr_quald_bnf_id              => p_cbr_quald_bnf_id
    ,p_prvs_elig_perd_end_dt         => p_prvs_elig_perd_end_dt
    ,p_business_group_id             => p_business_group_id
    ,p_crp_attribute_category        => p_crp_attribute_category
    ,p_crp_attribute1                => p_crp_attribute1
    ,p_crp_attribute2                => p_crp_attribute2
    ,p_crp_attribute3                => p_crp_attribute3
    ,p_crp_attribute4                => p_crp_attribute4
    ,p_crp_attribute5                => p_crp_attribute5
    ,p_crp_attribute6                => p_crp_attribute6
    ,p_crp_attribute7                => p_crp_attribute7
    ,p_crp_attribute8                => p_crp_attribute8
    ,p_crp_attribute9                => p_crp_attribute9
    ,p_crp_attribute10               => p_crp_attribute10
    ,p_crp_attribute11               => p_crp_attribute11
    ,p_crp_attribute12               => p_crp_attribute12
    ,p_crp_attribute13               => p_crp_attribute13
    ,p_crp_attribute14               => p_crp_attribute14
    ,p_crp_attribute15               => p_crp_attribute15
    ,p_crp_attribute16               => p_crp_attribute16
    ,p_crp_attribute17               => p_crp_attribute17
    ,p_crp_attribute18               => p_crp_attribute18
    ,p_crp_attribute19               => p_crp_attribute19
    ,p_crp_attribute20               => p_crp_attribute20
    ,p_crp_attribute21               => p_crp_attribute21
    ,p_crp_attribute22               => p_crp_attribute22
    ,p_crp_attribute23               => p_crp_attribute23
    ,p_crp_attribute24               => p_crp_attribute24
    ,p_crp_attribute25               => p_crp_attribute25
    ,p_crp_attribute26               => p_crp_attribute26
    ,p_crp_attribute27               => p_crp_attribute27
    ,p_crp_attribute28               => p_crp_attribute28
    ,p_crp_attribute29               => p_crp_attribute29
    ,p_crp_attribute30               => p_crp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_CBR_PER_IN_LER
    --
    ben_CBR_PER_IN_LER_bk2.update_CBR_PER_IN_LER_a
      (
       p_cbr_per_in_ler_id              =>  p_cbr_per_in_ler_id
      ,p_init_evt_flag                  =>  p_init_evt_flag
      ,p_cnt_num                        =>  p_cnt_num
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_cbr_quald_bnf_id               =>  p_cbr_quald_bnf_id
      ,p_prvs_elig_perd_end_dt          =>  p_prvs_elig_perd_end_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_crp_attribute_category         =>  p_crp_attribute_category
      ,p_crp_attribute1                 =>  p_crp_attribute1
      ,p_crp_attribute2                 =>  p_crp_attribute2
      ,p_crp_attribute3                 =>  p_crp_attribute3
      ,p_crp_attribute4                 =>  p_crp_attribute4
      ,p_crp_attribute5                 =>  p_crp_attribute5
      ,p_crp_attribute6                 =>  p_crp_attribute6
      ,p_crp_attribute7                 =>  p_crp_attribute7
      ,p_crp_attribute8                 =>  p_crp_attribute8
      ,p_crp_attribute9                 =>  p_crp_attribute9
      ,p_crp_attribute10                =>  p_crp_attribute10
      ,p_crp_attribute11                =>  p_crp_attribute11
      ,p_crp_attribute12                =>  p_crp_attribute12
      ,p_crp_attribute13                =>  p_crp_attribute13
      ,p_crp_attribute14                =>  p_crp_attribute14
      ,p_crp_attribute15                =>  p_crp_attribute15
      ,p_crp_attribute16                =>  p_crp_attribute16
      ,p_crp_attribute17                =>  p_crp_attribute17
      ,p_crp_attribute18                =>  p_crp_attribute18
      ,p_crp_attribute19                =>  p_crp_attribute19
      ,p_crp_attribute20                =>  p_crp_attribute20
      ,p_crp_attribute21                =>  p_crp_attribute21
      ,p_crp_attribute22                =>  p_crp_attribute22
      ,p_crp_attribute23                =>  p_crp_attribute23
      ,p_crp_attribute24                =>  p_crp_attribute24
      ,p_crp_attribute25                =>  p_crp_attribute25
      ,p_crp_attribute26                =>  p_crp_attribute26
      ,p_crp_attribute27                =>  p_crp_attribute27
      ,p_crp_attribute28                =>  p_crp_attribute28
      ,p_crp_attribute29                =>  p_crp_attribute29
      ,p_crp_attribute30                =>  p_crp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CBR_PER_IN_LER'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_CBR_PER_IN_LER
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
    ROLLBACK TO update_CBR_PER_IN_LER;
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
    ROLLBACK TO update_CBR_PER_IN_LER;

    raise;
    --
end update_CBR_PER_IN_LER;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CBR_PER_IN_LER >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CBR_PER_IN_LER
  (p_validate                       in  boolean  default false
  ,p_cbr_per_in_ler_id              in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CBR_PER_IN_LER';
  l_object_version_number ben_cbr_per_in_ler.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_CBR_PER_IN_LER;
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
    -- Start of API User Hook for the before hook of delete_CBR_PER_IN_LER
    --
    ben_CBR_PER_IN_LER_bk3.delete_CBR_PER_IN_LER_b
      (
       p_cbr_per_in_ler_id              =>  p_cbr_per_in_ler_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CBR_PER_IN_LER'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_CBR_PER_IN_LER
    --
  end;
  --
  ben_crp_del.del
    (
     p_cbr_per_in_ler_id             => p_cbr_per_in_ler_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_CBR_PER_IN_LER
    --
    ben_CBR_PER_IN_LER_bk3.delete_CBR_PER_IN_LER_a
      (
       p_cbr_per_in_ler_id              =>  p_cbr_per_in_ler_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CBR_PER_IN_LER'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_CBR_PER_IN_LER
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
    ROLLBACK TO delete_CBR_PER_IN_LER;
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
    ROLLBACK TO delete_CBR_PER_IN_LER;

    raise;
    --
end delete_CBR_PER_IN_LER;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cbr_per_in_ler_id                   in     number
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
  ben_crp_shd.lck
    (
      p_cbr_per_in_ler_id                 => p_cbr_per_in_ler_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_CBR_PER_IN_LER_api;

/
