--------------------------------------------------------
--  DDL for Package Body BEN_LEGAL_ENTITY_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LEGAL_ENTITY_RATE_API" as
/* $Header: belglapi.pkb 120.0 2005/05/28 03:23:25 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_LEGAL_ENTITY_RATE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_LEGAL_ENTITY_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_LEGAL_ENTITY_RATE
  (p_validate                       in  boolean   default false
  ,p_lgl_enty_rt_id                 out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_organization_id                in  number    default null
  ,p_excld_flag                     in  varchar2  default null
  ,p_ordr_num                       in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ler1_attribute_category        in  varchar2  default null
  ,p_ler1_attribute1                in  varchar2  default null
  ,p_ler1_attribute2                in  varchar2  default null
  ,p_ler1_attribute3                in  varchar2  default null
  ,p_ler1_attribute4                in  varchar2  default null
  ,p_ler1_attribute5                in  varchar2  default null
  ,p_ler1_attribute6                in  varchar2  default null
  ,p_ler1_attribute7                in  varchar2  default null
  ,p_ler1_attribute8                in  varchar2  default null
  ,p_ler1_attribute9                in  varchar2  default null
  ,p_ler1_attribute10               in  varchar2  default null
  ,p_ler1_attribute11               in  varchar2  default null
  ,p_ler1_attribute12               in  varchar2  default null
  ,p_ler1_attribute13               in  varchar2  default null
  ,p_ler1_attribute14               in  varchar2  default null
  ,p_ler1_attribute15               in  varchar2  default null
  ,p_ler1_attribute16               in  varchar2  default null
  ,p_ler1_attribute17               in  varchar2  default null
  ,p_ler1_attribute18               in  varchar2  default null
  ,p_ler1_attribute19               in  varchar2  default null
  ,p_ler1_attribute20               in  varchar2  default null
  ,p_ler1_attribute21               in  varchar2  default null
  ,p_ler1_attribute22               in  varchar2  default null
  ,p_ler1_attribute23               in  varchar2  default null
  ,p_ler1_attribute24               in  varchar2  default null
  ,p_ler1_attribute25               in  varchar2  default null
  ,p_ler1_attribute26               in  varchar2  default null
  ,p_ler1_attribute27               in  varchar2  default null
  ,p_ler1_attribute28               in  varchar2  default null
  ,p_ler1_attribute29               in  varchar2  default null
  ,p_ler1_attribute30               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_lgl_enty_rt_id ben_lgl_enty_rt_f.lgl_enty_rt_id%TYPE;
  l_effective_start_date ben_lgl_enty_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_lgl_enty_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_LEGAL_ENTITY_RATE';
  l_object_version_number ben_lgl_enty_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_LEGAL_ENTITY_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_LEGAL_ENTITY_RATE
    --
    ben_LEGAL_ENTITY_RATE_bk1.create_LEGAL_ENTITY_RATE_b
      (
       p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_organization_id                =>  p_organization_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_ler1_attribute_category        =>  p_ler1_attribute_category
      ,p_ler1_attribute1                =>  p_ler1_attribute1
      ,p_ler1_attribute2                =>  p_ler1_attribute2
      ,p_ler1_attribute3                =>  p_ler1_attribute3
      ,p_ler1_attribute4                =>  p_ler1_attribute4
      ,p_ler1_attribute5                =>  p_ler1_attribute5
      ,p_ler1_attribute6                =>  p_ler1_attribute6
      ,p_ler1_attribute7                =>  p_ler1_attribute7
      ,p_ler1_attribute8                =>  p_ler1_attribute8
      ,p_ler1_attribute9                =>  p_ler1_attribute9
      ,p_ler1_attribute10               =>  p_ler1_attribute10
      ,p_ler1_attribute11               =>  p_ler1_attribute11
      ,p_ler1_attribute12               =>  p_ler1_attribute12
      ,p_ler1_attribute13               =>  p_ler1_attribute13
      ,p_ler1_attribute14               =>  p_ler1_attribute14
      ,p_ler1_attribute15               =>  p_ler1_attribute15
      ,p_ler1_attribute16               =>  p_ler1_attribute16
      ,p_ler1_attribute17               =>  p_ler1_attribute17
      ,p_ler1_attribute18               =>  p_ler1_attribute18
      ,p_ler1_attribute19               =>  p_ler1_attribute19
      ,p_ler1_attribute20               =>  p_ler1_attribute20
      ,p_ler1_attribute21               =>  p_ler1_attribute21
      ,p_ler1_attribute22               =>  p_ler1_attribute22
      ,p_ler1_attribute23               =>  p_ler1_attribute23
      ,p_ler1_attribute24               =>  p_ler1_attribute24
      ,p_ler1_attribute25               =>  p_ler1_attribute25
      ,p_ler1_attribute26               =>  p_ler1_attribute26
      ,p_ler1_attribute27               =>  p_ler1_attribute27
      ,p_ler1_attribute28               =>  p_ler1_attribute28
      ,p_ler1_attribute29               =>  p_ler1_attribute29
      ,p_ler1_attribute30               =>  p_ler1_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_LEGAL_ENTITY_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_LEGAL_ENTITY_RATE
    --
  end;
  --
  ben_lgl_ins.ins
    (
     p_lgl_enty_rt_id                => l_lgl_enty_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_organization_id               => p_organization_id
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_ler1_attribute_category       => p_ler1_attribute_category
    ,p_ler1_attribute1               => p_ler1_attribute1
    ,p_ler1_attribute2               => p_ler1_attribute2
    ,p_ler1_attribute3               => p_ler1_attribute3
    ,p_ler1_attribute4               => p_ler1_attribute4
    ,p_ler1_attribute5               => p_ler1_attribute5
    ,p_ler1_attribute6               => p_ler1_attribute6
    ,p_ler1_attribute7               => p_ler1_attribute7
    ,p_ler1_attribute8               => p_ler1_attribute8
    ,p_ler1_attribute9               => p_ler1_attribute9
    ,p_ler1_attribute10              => p_ler1_attribute10
    ,p_ler1_attribute11              => p_ler1_attribute11
    ,p_ler1_attribute12              => p_ler1_attribute12
    ,p_ler1_attribute13              => p_ler1_attribute13
    ,p_ler1_attribute14              => p_ler1_attribute14
    ,p_ler1_attribute15              => p_ler1_attribute15
    ,p_ler1_attribute16              => p_ler1_attribute16
    ,p_ler1_attribute17              => p_ler1_attribute17
    ,p_ler1_attribute18              => p_ler1_attribute18
    ,p_ler1_attribute19              => p_ler1_attribute19
    ,p_ler1_attribute20              => p_ler1_attribute20
    ,p_ler1_attribute21              => p_ler1_attribute21
    ,p_ler1_attribute22              => p_ler1_attribute22
    ,p_ler1_attribute23              => p_ler1_attribute23
    ,p_ler1_attribute24              => p_ler1_attribute24
    ,p_ler1_attribute25              => p_ler1_attribute25
    ,p_ler1_attribute26              => p_ler1_attribute26
    ,p_ler1_attribute27              => p_ler1_attribute27
    ,p_ler1_attribute28              => p_ler1_attribute28
    ,p_ler1_attribute29              => p_ler1_attribute29
    ,p_ler1_attribute30              => p_ler1_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_LEGAL_ENTITY_RATE
    --
    ben_LEGAL_ENTITY_RATE_bk1.create_LEGAL_ENTITY_RATE_a
      (
       p_lgl_enty_rt_id                 =>  l_lgl_enty_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_organization_id                =>  p_organization_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_ler1_attribute_category        =>  p_ler1_attribute_category
      ,p_ler1_attribute1                =>  p_ler1_attribute1
      ,p_ler1_attribute2                =>  p_ler1_attribute2
      ,p_ler1_attribute3                =>  p_ler1_attribute3
      ,p_ler1_attribute4                =>  p_ler1_attribute4
      ,p_ler1_attribute5                =>  p_ler1_attribute5
      ,p_ler1_attribute6                =>  p_ler1_attribute6
      ,p_ler1_attribute7                =>  p_ler1_attribute7
      ,p_ler1_attribute8                =>  p_ler1_attribute8
      ,p_ler1_attribute9                =>  p_ler1_attribute9
      ,p_ler1_attribute10               =>  p_ler1_attribute10
      ,p_ler1_attribute11               =>  p_ler1_attribute11
      ,p_ler1_attribute12               =>  p_ler1_attribute12
      ,p_ler1_attribute13               =>  p_ler1_attribute13
      ,p_ler1_attribute14               =>  p_ler1_attribute14
      ,p_ler1_attribute15               =>  p_ler1_attribute15
      ,p_ler1_attribute16               =>  p_ler1_attribute16
      ,p_ler1_attribute17               =>  p_ler1_attribute17
      ,p_ler1_attribute18               =>  p_ler1_attribute18
      ,p_ler1_attribute19               =>  p_ler1_attribute19
      ,p_ler1_attribute20               =>  p_ler1_attribute20
      ,p_ler1_attribute21               =>  p_ler1_attribute21
      ,p_ler1_attribute22               =>  p_ler1_attribute22
      ,p_ler1_attribute23               =>  p_ler1_attribute23
      ,p_ler1_attribute24               =>  p_ler1_attribute24
      ,p_ler1_attribute25               =>  p_ler1_attribute25
      ,p_ler1_attribute26               =>  p_ler1_attribute26
      ,p_ler1_attribute27               =>  p_ler1_attribute27
      ,p_ler1_attribute28               =>  p_ler1_attribute28
      ,p_ler1_attribute29               =>  p_ler1_attribute29
      ,p_ler1_attribute30               =>  p_ler1_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LEGAL_ENTITY_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_LEGAL_ENTITY_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_LGL_ENTY_FLAG',
     p_reference_table             => 'BEN_LGL_ENTY_RT_F',
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
  p_lgl_enty_rt_id := l_lgl_enty_rt_id;
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
    ROLLBACK TO create_LEGAL_ENTITY_RATE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_lgl_enty_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_LEGAL_ENTITY_RATE;
    /* Inserted for nocopy changes */
    p_lgl_enty_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_LEGAL_ENTITY_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_LEGAL_ENTITY_RATE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_LEGAL_ENTITY_RATE
  (p_validate                       in  boolean   default false
  ,p_lgl_enty_rt_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ler1_attribute_category        in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute1                in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute2                in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute3                in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute4                in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute5                in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute6                in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute7                in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute8                in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute9                in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute10               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute11               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute12               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute13               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute14               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute15               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute16               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute17               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute18               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute19               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute20               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute21               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute22               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute23               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute24               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute25               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute26               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute27               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute28               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute29               in  varchar2  default hr_api.g_varchar2
  ,p_ler1_attribute30               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_LEGAL_ENTITY_RATE';
  l_object_version_number ben_lgl_enty_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_lgl_enty_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_lgl_enty_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_LEGAL_ENTITY_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_LEGAL_ENTITY_RATE
    --
    ben_LEGAL_ENTITY_RATE_bk2.update_LEGAL_ENTITY_RATE_b
      (
       p_lgl_enty_rt_id                 =>  p_lgl_enty_rt_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_organization_id                =>  p_organization_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_ler1_attribute_category        =>  p_ler1_attribute_category
      ,p_ler1_attribute1                =>  p_ler1_attribute1
      ,p_ler1_attribute2                =>  p_ler1_attribute2
      ,p_ler1_attribute3                =>  p_ler1_attribute3
      ,p_ler1_attribute4                =>  p_ler1_attribute4
      ,p_ler1_attribute5                =>  p_ler1_attribute5
      ,p_ler1_attribute6                =>  p_ler1_attribute6
      ,p_ler1_attribute7                =>  p_ler1_attribute7
      ,p_ler1_attribute8                =>  p_ler1_attribute8
      ,p_ler1_attribute9                =>  p_ler1_attribute9
      ,p_ler1_attribute10               =>  p_ler1_attribute10
      ,p_ler1_attribute11               =>  p_ler1_attribute11
      ,p_ler1_attribute12               =>  p_ler1_attribute12
      ,p_ler1_attribute13               =>  p_ler1_attribute13
      ,p_ler1_attribute14               =>  p_ler1_attribute14
      ,p_ler1_attribute15               =>  p_ler1_attribute15
      ,p_ler1_attribute16               =>  p_ler1_attribute16
      ,p_ler1_attribute17               =>  p_ler1_attribute17
      ,p_ler1_attribute18               =>  p_ler1_attribute18
      ,p_ler1_attribute19               =>  p_ler1_attribute19
      ,p_ler1_attribute20               =>  p_ler1_attribute20
      ,p_ler1_attribute21               =>  p_ler1_attribute21
      ,p_ler1_attribute22               =>  p_ler1_attribute22
      ,p_ler1_attribute23               =>  p_ler1_attribute23
      ,p_ler1_attribute24               =>  p_ler1_attribute24
      ,p_ler1_attribute25               =>  p_ler1_attribute25
      ,p_ler1_attribute26               =>  p_ler1_attribute26
      ,p_ler1_attribute27               =>  p_ler1_attribute27
      ,p_ler1_attribute28               =>  p_ler1_attribute28
      ,p_ler1_attribute29               =>  p_ler1_attribute29
      ,p_ler1_attribute30               =>  p_ler1_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LEGAL_ENTITY_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_LEGAL_ENTITY_RATE
    --
  end;
  --
  ben_lgl_upd.upd
    (
     p_lgl_enty_rt_id                => p_lgl_enty_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_organization_id               => p_organization_id
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_ler1_attribute_category       => p_ler1_attribute_category
    ,p_ler1_attribute1               => p_ler1_attribute1
    ,p_ler1_attribute2               => p_ler1_attribute2
    ,p_ler1_attribute3               => p_ler1_attribute3
    ,p_ler1_attribute4               => p_ler1_attribute4
    ,p_ler1_attribute5               => p_ler1_attribute5
    ,p_ler1_attribute6               => p_ler1_attribute6
    ,p_ler1_attribute7               => p_ler1_attribute7
    ,p_ler1_attribute8               => p_ler1_attribute8
    ,p_ler1_attribute9               => p_ler1_attribute9
    ,p_ler1_attribute10              => p_ler1_attribute10
    ,p_ler1_attribute11              => p_ler1_attribute11
    ,p_ler1_attribute12              => p_ler1_attribute12
    ,p_ler1_attribute13              => p_ler1_attribute13
    ,p_ler1_attribute14              => p_ler1_attribute14
    ,p_ler1_attribute15              => p_ler1_attribute15
    ,p_ler1_attribute16              => p_ler1_attribute16
    ,p_ler1_attribute17              => p_ler1_attribute17
    ,p_ler1_attribute18              => p_ler1_attribute18
    ,p_ler1_attribute19              => p_ler1_attribute19
    ,p_ler1_attribute20              => p_ler1_attribute20
    ,p_ler1_attribute21              => p_ler1_attribute21
    ,p_ler1_attribute22              => p_ler1_attribute22
    ,p_ler1_attribute23              => p_ler1_attribute23
    ,p_ler1_attribute24              => p_ler1_attribute24
    ,p_ler1_attribute25              => p_ler1_attribute25
    ,p_ler1_attribute26              => p_ler1_attribute26
    ,p_ler1_attribute27              => p_ler1_attribute27
    ,p_ler1_attribute28              => p_ler1_attribute28
    ,p_ler1_attribute29              => p_ler1_attribute29
    ,p_ler1_attribute30              => p_ler1_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_LEGAL_ENTITY_RATE
    --
    ben_LEGAL_ENTITY_RATE_bk2.update_LEGAL_ENTITY_RATE_a
      (
       p_lgl_enty_rt_id                 =>  p_lgl_enty_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_organization_id                =>  p_organization_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_ler1_attribute_category        =>  p_ler1_attribute_category
      ,p_ler1_attribute1                =>  p_ler1_attribute1
      ,p_ler1_attribute2                =>  p_ler1_attribute2
      ,p_ler1_attribute3                =>  p_ler1_attribute3
      ,p_ler1_attribute4                =>  p_ler1_attribute4
      ,p_ler1_attribute5                =>  p_ler1_attribute5
      ,p_ler1_attribute6                =>  p_ler1_attribute6
      ,p_ler1_attribute7                =>  p_ler1_attribute7
      ,p_ler1_attribute8                =>  p_ler1_attribute8
      ,p_ler1_attribute9                =>  p_ler1_attribute9
      ,p_ler1_attribute10               =>  p_ler1_attribute10
      ,p_ler1_attribute11               =>  p_ler1_attribute11
      ,p_ler1_attribute12               =>  p_ler1_attribute12
      ,p_ler1_attribute13               =>  p_ler1_attribute13
      ,p_ler1_attribute14               =>  p_ler1_attribute14
      ,p_ler1_attribute15               =>  p_ler1_attribute15
      ,p_ler1_attribute16               =>  p_ler1_attribute16
      ,p_ler1_attribute17               =>  p_ler1_attribute17
      ,p_ler1_attribute18               =>  p_ler1_attribute18
      ,p_ler1_attribute19               =>  p_ler1_attribute19
      ,p_ler1_attribute20               =>  p_ler1_attribute20
      ,p_ler1_attribute21               =>  p_ler1_attribute21
      ,p_ler1_attribute22               =>  p_ler1_attribute22
      ,p_ler1_attribute23               =>  p_ler1_attribute23
      ,p_ler1_attribute24               =>  p_ler1_attribute24
      ,p_ler1_attribute25               =>  p_ler1_attribute25
      ,p_ler1_attribute26               =>  p_ler1_attribute26
      ,p_ler1_attribute27               =>  p_ler1_attribute27
      ,p_ler1_attribute28               =>  p_ler1_attribute28
      ,p_ler1_attribute29               =>  p_ler1_attribute29
      ,p_ler1_attribute30               =>  p_ler1_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LEGAL_ENTITY_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_LEGAL_ENTITY_RATE
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
    ROLLBACK TO update_LEGAL_ENTITY_RATE;
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
    ROLLBACK TO update_LEGAL_ENTITY_RATE;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_LEGAL_ENTITY_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_LEGAL_ENTITY_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LEGAL_ENTITY_RATE
  (p_validate                       in  boolean  default false
  ,p_lgl_enty_rt_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_LEGAL_ENTITY_RATE';
  l_object_version_number ben_lgl_enty_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_lgl_enty_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_lgl_enty_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_LEGAL_ENTITY_RATE;
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
    -- Start of API User Hook for the before hook of delete_LEGAL_ENTITY_RATE
    --
    ben_LEGAL_ENTITY_RATE_bk3.delete_LEGAL_ENTITY_RATE_b
      (
       p_lgl_enty_rt_id                 =>  p_lgl_enty_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LEGAL_ENTITY_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_LEGAL_ENTITY_RATE
    --
  end;
  --
  ben_lgl_del.del
    (
     p_lgl_enty_rt_id                => p_lgl_enty_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_LEGAL_ENTITY_RATE
    --
    ben_LEGAL_ENTITY_RATE_bk3.delete_LEGAL_ENTITY_RATE_a
      (
       p_lgl_enty_rt_id                 =>  p_lgl_enty_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LEGAL_ENTITY_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_LEGAL_ENTITY_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => ben_lgl_shd.g_old_rec.vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_LGL_ENTY_FLAG',
     p_reference_table             => 'BEN_LGL_ENTY_RT_F',
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
    ROLLBACK TO delete_LEGAL_ENTITY_RATE;
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
    ROLLBACK TO delete_LEGAL_ENTITY_RATE;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_LEGAL_ENTITY_RATE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_lgl_enty_rt_id                   in     number
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
  ben_lgl_shd.lck
    (
      p_lgl_enty_rt_id                 => p_lgl_enty_rt_id
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
end ben_LEGAL_ENTITY_RATE_api;

/
