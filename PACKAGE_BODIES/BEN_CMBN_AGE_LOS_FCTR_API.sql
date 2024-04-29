--------------------------------------------------------
--  DDL for Package Body BEN_CMBN_AGE_LOS_FCTR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CMBN_AGE_LOS_FCTR_API" as
/* $Header: beclaapi.pkb 120.0 2005/05/28 01:03:00 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_cmbn_age_los_fctr_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cmbn_age_los_fctr >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cmbn_age_los_fctr
  (p_validate                       in  boolean   default false
  ,p_cmbn_age_los_fctr_id           out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_los_fctr_id                    in  number    default null
  ,p_age_fctr_id                    in  number    default null
  ,p_cmbnd_min_val                  in  number    default null
  ,p_cmbnd_max_val                  in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_cla_attribute_category         in  varchar2  default null
  ,p_cla_attribute1                 in  varchar2  default null
  ,p_cla_attribute2                 in  varchar2  default null
  ,p_cla_attribute3                 in  varchar2  default null
  ,p_cla_attribute4                 in  varchar2  default null
  ,p_cla_attribute5                 in  varchar2  default null
  ,p_cla_attribute6                 in  varchar2  default null
  ,p_cla_attribute7                 in  varchar2  default null
  ,p_cla_attribute8                 in  varchar2  default null
  ,p_cla_attribute9                 in  varchar2  default null
  ,p_cla_attribute10                in  varchar2  default null
  ,p_cla_attribute11                in  varchar2  default null
  ,p_cla_attribute12                in  varchar2  default null
  ,p_cla_attribute13                in  varchar2  default null
  ,p_cla_attribute14                in  varchar2  default null
  ,p_cla_attribute15                in  varchar2  default null
  ,p_cla_attribute16                in  varchar2  default null
  ,p_cla_attribute17                in  varchar2  default null
  ,p_cla_attribute18                in  varchar2  default null
  ,p_cla_attribute19                in  varchar2  default null
  ,p_cla_attribute20                in  varchar2  default null
  ,p_cla_attribute21                in  varchar2  default null
  ,p_cla_attribute22                in  varchar2  default null
  ,p_cla_attribute23                in  varchar2  default null
  ,p_cla_attribute24                in  varchar2  default null
  ,p_cla_attribute25                in  varchar2  default null
  ,p_cla_attribute26                in  varchar2  default null
  ,p_cla_attribute27                in  varchar2  default null
  ,p_cla_attribute28                in  varchar2  default null
  ,p_cla_attribute29                in  varchar2  default null
  ,p_cla_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cmbn_age_los_fctr_id ben_cmbn_age_los_fctr.cmbn_age_los_fctr_id%TYPE;
  l_proc varchar2(72) := g_package||'create_cmbn_age_los_fctr';
  l_object_version_number ben_cmbn_age_los_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_cmbn_age_los_fctr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_cmbn_age_los_fctr
    --
    ben_cmbn_age_los_fctr_bk1.create_cmbn_age_los_fctr_b
      (
       p_name                           =>  p_name
      ,p_los_fctr_id                    =>  p_los_fctr_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_cmbnd_min_val                  =>  p_cmbnd_min_val
      ,p_cmbnd_max_val                  =>  p_cmbnd_max_val
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_cla_attribute_category         =>  p_cla_attribute_category
      ,p_cla_attribute1                 =>  p_cla_attribute1
      ,p_cla_attribute2                 =>  p_cla_attribute2
      ,p_cla_attribute3                 =>  p_cla_attribute3
      ,p_cla_attribute4                 =>  p_cla_attribute4
      ,p_cla_attribute5                 =>  p_cla_attribute5
      ,p_cla_attribute6                 =>  p_cla_attribute6
      ,p_cla_attribute7                 =>  p_cla_attribute7
      ,p_cla_attribute8                 =>  p_cla_attribute8
      ,p_cla_attribute9                 =>  p_cla_attribute9
      ,p_cla_attribute10                =>  p_cla_attribute10
      ,p_cla_attribute11                =>  p_cla_attribute11
      ,p_cla_attribute12                =>  p_cla_attribute12
      ,p_cla_attribute13                =>  p_cla_attribute13
      ,p_cla_attribute14                =>  p_cla_attribute14
      ,p_cla_attribute15                =>  p_cla_attribute15
      ,p_cla_attribute16                =>  p_cla_attribute16
      ,p_cla_attribute17                =>  p_cla_attribute17
      ,p_cla_attribute18                =>  p_cla_attribute18
      ,p_cla_attribute19                =>  p_cla_attribute19
      ,p_cla_attribute20                =>  p_cla_attribute20
      ,p_cla_attribute21                =>  p_cla_attribute21
      ,p_cla_attribute22                =>  p_cla_attribute22
      ,p_cla_attribute23                =>  p_cla_attribute23
      ,p_cla_attribute24                =>  p_cla_attribute24
      ,p_cla_attribute25                =>  p_cla_attribute25
      ,p_cla_attribute26                =>  p_cla_attribute26
      ,p_cla_attribute27                =>  p_cla_attribute27
      ,p_cla_attribute28                =>  p_cla_attribute28
      ,p_cla_attribute29                =>  p_cla_attribute29
      ,p_cla_attribute30                =>  p_cla_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_cmbn_age_los_fctr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_cmbn_age_los_fctr
    --
  end;
  --
  ben_cla_ins.ins
    (
     p_cmbn_age_los_fctr_id          => l_cmbn_age_los_fctr_id
    ,p_name                          => p_name
    ,p_los_fctr_id                   => p_los_fctr_id
    ,p_age_fctr_id                   => p_age_fctr_id
    ,p_cmbnd_min_val                 => p_cmbnd_min_val
    ,p_cmbnd_max_val                 => p_cmbnd_max_val
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_cla_attribute_category        => p_cla_attribute_category
    ,p_cla_attribute1                => p_cla_attribute1
    ,p_cla_attribute2                => p_cla_attribute2
    ,p_cla_attribute3                => p_cla_attribute3
    ,p_cla_attribute4                => p_cla_attribute4
    ,p_cla_attribute5                => p_cla_attribute5
    ,p_cla_attribute6                => p_cla_attribute6
    ,p_cla_attribute7                => p_cla_attribute7
    ,p_cla_attribute8                => p_cla_attribute8
    ,p_cla_attribute9                => p_cla_attribute9
    ,p_cla_attribute10               => p_cla_attribute10
    ,p_cla_attribute11               => p_cla_attribute11
    ,p_cla_attribute12               => p_cla_attribute12
    ,p_cla_attribute13               => p_cla_attribute13
    ,p_cla_attribute14               => p_cla_attribute14
    ,p_cla_attribute15               => p_cla_attribute15
    ,p_cla_attribute16               => p_cla_attribute16
    ,p_cla_attribute17               => p_cla_attribute17
    ,p_cla_attribute18               => p_cla_attribute18
    ,p_cla_attribute19               => p_cla_attribute19
    ,p_cla_attribute20               => p_cla_attribute20
    ,p_cla_attribute21               => p_cla_attribute21
    ,p_cla_attribute22               => p_cla_attribute22
    ,p_cla_attribute23               => p_cla_attribute23
    ,p_cla_attribute24               => p_cla_attribute24
    ,p_cla_attribute25               => p_cla_attribute25
    ,p_cla_attribute26               => p_cla_attribute26
    ,p_cla_attribute27               => p_cla_attribute27
    ,p_cla_attribute28               => p_cla_attribute28
    ,p_cla_attribute29               => p_cla_attribute29
    ,p_cla_attribute30               => p_cla_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_cmbn_age_los_fctr
    --
    ben_cmbn_age_los_fctr_bk1.create_cmbn_age_los_fctr_a
      (
       p_cmbn_age_los_fctr_id           =>  l_cmbn_age_los_fctr_id
      ,p_name                           =>  p_name
      ,p_los_fctr_id                    =>  p_los_fctr_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_cmbnd_min_val                  =>  p_cmbnd_min_val
      ,p_cmbnd_max_val                  =>  p_cmbnd_max_val
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_cla_attribute_category         =>  p_cla_attribute_category
      ,p_cla_attribute1                 =>  p_cla_attribute1
      ,p_cla_attribute2                 =>  p_cla_attribute2
      ,p_cla_attribute3                 =>  p_cla_attribute3
      ,p_cla_attribute4                 =>  p_cla_attribute4
      ,p_cla_attribute5                 =>  p_cla_attribute5
      ,p_cla_attribute6                 =>  p_cla_attribute6
      ,p_cla_attribute7                 =>  p_cla_attribute7
      ,p_cla_attribute8                 =>  p_cla_attribute8
      ,p_cla_attribute9                 =>  p_cla_attribute9
      ,p_cla_attribute10                =>  p_cla_attribute10
      ,p_cla_attribute11                =>  p_cla_attribute11
      ,p_cla_attribute12                =>  p_cla_attribute12
      ,p_cla_attribute13                =>  p_cla_attribute13
      ,p_cla_attribute14                =>  p_cla_attribute14
      ,p_cla_attribute15                =>  p_cla_attribute15
      ,p_cla_attribute16                =>  p_cla_attribute16
      ,p_cla_attribute17                =>  p_cla_attribute17
      ,p_cla_attribute18                =>  p_cla_attribute18
      ,p_cla_attribute19                =>  p_cla_attribute19
      ,p_cla_attribute20                =>  p_cla_attribute20
      ,p_cla_attribute21                =>  p_cla_attribute21
      ,p_cla_attribute22                =>  p_cla_attribute22
      ,p_cla_attribute23                =>  p_cla_attribute23
      ,p_cla_attribute24                =>  p_cla_attribute24
      ,p_cla_attribute25                =>  p_cla_attribute25
      ,p_cla_attribute26                =>  p_cla_attribute26
      ,p_cla_attribute27                =>  p_cla_attribute27
      ,p_cla_attribute28                =>  p_cla_attribute28
      ,p_cla_attribute29                =>  p_cla_attribute29
      ,p_cla_attribute30                =>  p_cla_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cmbn_age_los_fctr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_cmbn_age_los_fctr
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
  p_cmbn_age_los_fctr_id := l_cmbn_age_los_fctr_id;
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
    ROLLBACK TO create_cmbn_age_los_fctr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cmbn_age_los_fctr_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_cmbn_age_los_fctr;

    p_cmbn_age_los_fctr_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_cmbn_age_los_fctr;
-- ----------------------------------------------------------------------------
-- |------------------------< update_cmbn_age_los_fctr >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cmbn_age_los_fctr
  (p_validate                       in  boolean   default false
  ,p_cmbn_age_los_fctr_id           in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_los_fctr_id                    in  number    default hr_api.g_number
  ,p_age_fctr_id                    in  number    default hr_api.g_number
  ,p_cmbnd_min_val                  in  number    default hr_api.g_number
  ,p_cmbnd_max_val                  in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cla_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cla_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cmbn_age_los_fctr';
  l_object_version_number ben_cmbn_age_los_fctr.object_version_number%TYPE;
  l_in_object_version_number  number  := p_object_version_number ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_cmbn_age_los_fctr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_cmbn_age_los_fctr
    --
    ben_cmbn_age_los_fctr_bk2.update_cmbn_age_los_fctr_b
      (
       p_cmbn_age_los_fctr_id           =>  p_cmbn_age_los_fctr_id
      ,p_name                           =>  p_name
      ,p_los_fctr_id                    =>  p_los_fctr_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_cmbnd_min_val                  =>  p_cmbnd_min_val
      ,p_cmbnd_max_val                  =>  p_cmbnd_max_val
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_cla_attribute_category         =>  p_cla_attribute_category
      ,p_cla_attribute1                 =>  p_cla_attribute1
      ,p_cla_attribute2                 =>  p_cla_attribute2
      ,p_cla_attribute3                 =>  p_cla_attribute3
      ,p_cla_attribute4                 =>  p_cla_attribute4
      ,p_cla_attribute5                 =>  p_cla_attribute5
      ,p_cla_attribute6                 =>  p_cla_attribute6
      ,p_cla_attribute7                 =>  p_cla_attribute7
      ,p_cla_attribute8                 =>  p_cla_attribute8
      ,p_cla_attribute9                 =>  p_cla_attribute9
      ,p_cla_attribute10                =>  p_cla_attribute10
      ,p_cla_attribute11                =>  p_cla_attribute11
      ,p_cla_attribute12                =>  p_cla_attribute12
      ,p_cla_attribute13                =>  p_cla_attribute13
      ,p_cla_attribute14                =>  p_cla_attribute14
      ,p_cla_attribute15                =>  p_cla_attribute15
      ,p_cla_attribute16                =>  p_cla_attribute16
      ,p_cla_attribute17                =>  p_cla_attribute17
      ,p_cla_attribute18                =>  p_cla_attribute18
      ,p_cla_attribute19                =>  p_cla_attribute19
      ,p_cla_attribute20                =>  p_cla_attribute20
      ,p_cla_attribute21                =>  p_cla_attribute21
      ,p_cla_attribute22                =>  p_cla_attribute22
      ,p_cla_attribute23                =>  p_cla_attribute23
      ,p_cla_attribute24                =>  p_cla_attribute24
      ,p_cla_attribute25                =>  p_cla_attribute25
      ,p_cla_attribute26                =>  p_cla_attribute26
      ,p_cla_attribute27                =>  p_cla_attribute27
      ,p_cla_attribute28                =>  p_cla_attribute28
      ,p_cla_attribute29                =>  p_cla_attribute29
      ,p_cla_attribute30                =>  p_cla_attribute30
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cmbn_age_los_fctr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_cmbn_age_los_fctr
    --
  end;
  --
  ben_cla_upd.upd
    (
     p_cmbn_age_los_fctr_id          => p_cmbn_age_los_fctr_id
    ,p_name                          => p_name
    ,p_los_fctr_id                   => p_los_fctr_id
    ,p_age_fctr_id                   => p_age_fctr_id
    ,p_cmbnd_min_val                 => p_cmbnd_min_val
    ,p_cmbnd_max_val                 => p_cmbnd_max_val
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_cla_attribute_category        => p_cla_attribute_category
    ,p_cla_attribute1                => p_cla_attribute1
    ,p_cla_attribute2                => p_cla_attribute2
    ,p_cla_attribute3                => p_cla_attribute3
    ,p_cla_attribute4                => p_cla_attribute4
    ,p_cla_attribute5                => p_cla_attribute5
    ,p_cla_attribute6                => p_cla_attribute6
    ,p_cla_attribute7                => p_cla_attribute7
    ,p_cla_attribute8                => p_cla_attribute8
    ,p_cla_attribute9                => p_cla_attribute9
    ,p_cla_attribute10               => p_cla_attribute10
    ,p_cla_attribute11               => p_cla_attribute11
    ,p_cla_attribute12               => p_cla_attribute12
    ,p_cla_attribute13               => p_cla_attribute13
    ,p_cla_attribute14               => p_cla_attribute14
    ,p_cla_attribute15               => p_cla_attribute15
    ,p_cla_attribute16               => p_cla_attribute16
    ,p_cla_attribute17               => p_cla_attribute17
    ,p_cla_attribute18               => p_cla_attribute18
    ,p_cla_attribute19               => p_cla_attribute19
    ,p_cla_attribute20               => p_cla_attribute20
    ,p_cla_attribute21               => p_cla_attribute21
    ,p_cla_attribute22               => p_cla_attribute22
    ,p_cla_attribute23               => p_cla_attribute23
    ,p_cla_attribute24               => p_cla_attribute24
    ,p_cla_attribute25               => p_cla_attribute25
    ,p_cla_attribute26               => p_cla_attribute26
    ,p_cla_attribute27               => p_cla_attribute27
    ,p_cla_attribute28               => p_cla_attribute28
    ,p_cla_attribute29               => p_cla_attribute29
    ,p_cla_attribute30               => p_cla_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_cmbn_age_los_fctr
    --
    ben_cmbn_age_los_fctr_bk2.update_cmbn_age_los_fctr_a
      (
       p_cmbn_age_los_fctr_id           =>  p_cmbn_age_los_fctr_id
      ,p_name                           =>  p_name
      ,p_los_fctr_id                    =>  p_los_fctr_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_cmbnd_min_val                  =>  p_cmbnd_min_val
      ,p_cmbnd_max_val                  =>  p_cmbnd_max_val
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_cla_attribute_category         =>  p_cla_attribute_category
      ,p_cla_attribute1                 =>  p_cla_attribute1
      ,p_cla_attribute2                 =>  p_cla_attribute2
      ,p_cla_attribute3                 =>  p_cla_attribute3
      ,p_cla_attribute4                 =>  p_cla_attribute4
      ,p_cla_attribute5                 =>  p_cla_attribute5
      ,p_cla_attribute6                 =>  p_cla_attribute6
      ,p_cla_attribute7                 =>  p_cla_attribute7
      ,p_cla_attribute8                 =>  p_cla_attribute8
      ,p_cla_attribute9                 =>  p_cla_attribute9
      ,p_cla_attribute10                =>  p_cla_attribute10
      ,p_cla_attribute11                =>  p_cla_attribute11
      ,p_cla_attribute12                =>  p_cla_attribute12
      ,p_cla_attribute13                =>  p_cla_attribute13
      ,p_cla_attribute14                =>  p_cla_attribute14
      ,p_cla_attribute15                =>  p_cla_attribute15
      ,p_cla_attribute16                =>  p_cla_attribute16
      ,p_cla_attribute17                =>  p_cla_attribute17
      ,p_cla_attribute18                =>  p_cla_attribute18
      ,p_cla_attribute19                =>  p_cla_attribute19
      ,p_cla_attribute20                =>  p_cla_attribute20
      ,p_cla_attribute21                =>  p_cla_attribute21
      ,p_cla_attribute22                =>  p_cla_attribute22
      ,p_cla_attribute23                =>  p_cla_attribute23
      ,p_cla_attribute24                =>  p_cla_attribute24
      ,p_cla_attribute25                =>  p_cla_attribute25
      ,p_cla_attribute26                =>  p_cla_attribute26
      ,p_cla_attribute27                =>  p_cla_attribute27
      ,p_cla_attribute28                =>  p_cla_attribute28
      ,p_cla_attribute29                =>  p_cla_attribute29
      ,p_cla_attribute30                =>  p_cla_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cmbn_age_los_fctr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_cmbn_age_los_fctr
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
    ROLLBACK TO update_cmbn_age_los_fctr;
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
    p_object_version_number := l_in_object_version_number ;
    --
    ROLLBACK TO update_cmbn_age_los_fctr;
    raise;
    --
end update_cmbn_age_los_fctr;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cmbn_age_los_fctr >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cmbn_age_los_fctr
  (p_validate                       in  boolean  default false
  ,p_cmbn_age_los_fctr_id           in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cmbn_age_los_fctr';
  l_object_version_number ben_cmbn_age_los_fctr.object_version_number%TYPE;
  l_in_object_version_number  number  := p_object_version_number ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_cmbn_age_los_fctr;
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
    -- Start of API User Hook for the before hook of delete_cmbn_age_los_fctr
    --
    ben_cmbn_age_los_fctr_bk3.delete_cmbn_age_los_fctr_b
      (
       p_cmbn_age_los_fctr_id           =>  p_cmbn_age_los_fctr_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cmbn_age_los_fctr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_cmbn_age_los_fctr
    --
  end;
  --
  ben_cla_del.del
    (
     p_cmbn_age_los_fctr_id          => p_cmbn_age_los_fctr_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_cmbn_age_los_fctr
    --
    ben_cmbn_age_los_fctr_bk3.delete_cmbn_age_los_fctr_a
      (
       p_cmbn_age_los_fctr_id           =>  p_cmbn_age_los_fctr_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cmbn_age_los_fctr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_cmbn_age_los_fctr
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
    ROLLBACK TO delete_cmbn_age_los_fctr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    p_object_version_number := l_in_object_version_number ;
    --
    ROLLBACK TO delete_cmbn_age_los_fctr;
    raise;
    --
end delete_cmbn_age_los_fctr;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cmbn_age_los_fctr_id                   in     number
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
  ben_cla_shd.lck
    (
      p_cmbn_age_los_fctr_id                 => p_cmbn_age_los_fctr_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_cmbn_age_los_fctr_api;

/
