--------------------------------------------------------
--  DDL for Package Body BEN_PYMT_CHECK_DET_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PYMT_CHECK_DET_API" as
/* $Header: bepdtapi.pkb 115.0 2003/10/30 09:34:36 rpillay noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_pymt_check_det_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pymt_check_det >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pymt_check_det
  (p_validate                       in boolean    default false
  ,p_pymt_check_det_id              out nocopy number
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_check_num                      in  varchar2  default null
  ,p_pymt_dt                        in  date      default null
  ,p_pymt_amt                       in  number    default null
  ,p_pdt_attribute_category         in  varchar2  default null
  ,p_pdt_attribute1                 in  varchar2  default null
  ,p_pdt_attribute2                 in  varchar2  default null
  ,p_pdt_attribute3                 in  varchar2  default null
  ,p_pdt_attribute4                 in  varchar2  default null
  ,p_pdt_attribute5                 in  varchar2  default null
  ,p_pdt_attribute6                 in  varchar2  default null
  ,p_pdt_attribute7                 in  varchar2  default null
  ,p_pdt_attribute8                 in  varchar2  default null
  ,p_pdt_attribute9                 in  varchar2  default null
  ,p_pdt_attribute10                in  varchar2  default null
  ,p_pdt_attribute11                in  varchar2  default null
  ,p_pdt_attribute12                in  varchar2  default null
  ,p_pdt_attribute13                in  varchar2  default null
  ,p_pdt_attribute14                in  varchar2  default null
  ,p_pdt_attribute15                in  varchar2  default null
  ,p_pdt_attribute16                in  varchar2  default null
  ,p_pdt_attribute17                in  varchar2  default null
  ,p_pdt_attribute18                in  varchar2  default null
  ,p_pdt_attribute19                in  varchar2  default null
  ,p_pdt_attribute20                in  varchar2  default null
  ,p_pdt_attribute21                in  varchar2  default null
  ,p_pdt_attribute22                in  varchar2  default null
  ,p_pdt_attribute23                in  varchar2  default null
  ,p_pdt_attribute24                in  varchar2  default null
  ,p_pdt_attribute25                in  varchar2  default null
  ,p_pdt_attribute26                in  varchar2  default null
  ,p_pdt_attribute27                in  varchar2  default null
  ,p_pdt_attribute28                in  varchar2  default null
  ,p_pdt_attribute29                in  varchar2  default null
  ,p_pdt_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pymt_check_det_id ben_pymt_check_det.pymt_check_det_id%TYPE;
  l_proc varchar2(72) := g_package||'create_pymt_check_det';
  l_object_version_number ben_pymt_check_det.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_pymt_check_det;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_pymt_check_det
    --
    ben_pymt_check_det_bk1.create_pymt_check_det_b
      (
       p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_check_num                      =>  p_check_num
      ,p_pymt_dt                        =>  p_pymt_dt
      ,p_pymt_amt                       =>  p_pymt_amt
      ,p_pdt_attribute_category         =>  p_pdt_attribute_category
      ,p_pdt_attribute1                 =>  p_pdt_attribute1
      ,p_pdt_attribute2                 =>  p_pdt_attribute2
      ,p_pdt_attribute3                 =>  p_pdt_attribute3
      ,p_pdt_attribute4                 =>  p_pdt_attribute4
      ,p_pdt_attribute5                 =>  p_pdt_attribute5
      ,p_pdt_attribute6                 =>  p_pdt_attribute6
      ,p_pdt_attribute7                 =>  p_pdt_attribute7
      ,p_pdt_attribute8                 =>  p_pdt_attribute8
      ,p_pdt_attribute9                 =>  p_pdt_attribute9
      ,p_pdt_attribute10                =>  p_pdt_attribute10
      ,p_pdt_attribute11                =>  p_pdt_attribute11
      ,p_pdt_attribute12                =>  p_pdt_attribute12
      ,p_pdt_attribute13                =>  p_pdt_attribute13
      ,p_pdt_attribute14                =>  p_pdt_attribute14
      ,p_pdt_attribute15                =>  p_pdt_attribute15
      ,p_pdt_attribute16                =>  p_pdt_attribute16
      ,p_pdt_attribute17                =>  p_pdt_attribute17
      ,p_pdt_attribute18                =>  p_pdt_attribute18
      ,p_pdt_attribute19                =>  p_pdt_attribute19
      ,p_pdt_attribute20                =>  p_pdt_attribute20
      ,p_pdt_attribute21                =>  p_pdt_attribute21
      ,p_pdt_attribute22                =>  p_pdt_attribute22
      ,p_pdt_attribute23                =>  p_pdt_attribute23
      ,p_pdt_attribute24                =>  p_pdt_attribute24
      ,p_pdt_attribute25                =>  p_pdt_attribute25
      ,p_pdt_attribute26                =>  p_pdt_attribute26
      ,p_pdt_attribute27                =>  p_pdt_attribute27
      ,p_pdt_attribute28                =>  p_pdt_attribute28
      ,p_pdt_attribute29                =>  p_pdt_attribute29
      ,p_pdt_attribute30                =>  p_pdt_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_pymt_check_det'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_pymt_check_det
    --
  end;
  --
  ben_pdt_ins.ins
    (
     p_pymt_check_det_id             => l_pymt_check_det_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_check_num                     => p_check_num
    ,p_pymt_dt                       => p_pymt_dt
    ,p_pymt_amt                      => p_pymt_amt
    ,p_pdt_attribute_category        => p_pdt_attribute_category
    ,p_pdt_attribute1                => p_pdt_attribute1
    ,p_pdt_attribute2                => p_pdt_attribute2
    ,p_pdt_attribute3                => p_pdt_attribute3
    ,p_pdt_attribute4                => p_pdt_attribute4
    ,p_pdt_attribute5                => p_pdt_attribute5
    ,p_pdt_attribute6                => p_pdt_attribute6
    ,p_pdt_attribute7                => p_pdt_attribute7
    ,p_pdt_attribute8                => p_pdt_attribute8
    ,p_pdt_attribute9                => p_pdt_attribute9
    ,p_pdt_attribute10               => p_pdt_attribute10
    ,p_pdt_attribute11               => p_pdt_attribute11
    ,p_pdt_attribute12               => p_pdt_attribute12
    ,p_pdt_attribute13               => p_pdt_attribute13
    ,p_pdt_attribute14               => p_pdt_attribute14
    ,p_pdt_attribute15               => p_pdt_attribute15
    ,p_pdt_attribute16               => p_pdt_attribute16
    ,p_pdt_attribute17               => p_pdt_attribute17
    ,p_pdt_attribute18               => p_pdt_attribute18
    ,p_pdt_attribute19               => p_pdt_attribute19
    ,p_pdt_attribute20               => p_pdt_attribute20
    ,p_pdt_attribute21               => p_pdt_attribute21
    ,p_pdt_attribute22               => p_pdt_attribute22
    ,p_pdt_attribute23               => p_pdt_attribute23
    ,p_pdt_attribute24               => p_pdt_attribute24
    ,p_pdt_attribute25               => p_pdt_attribute25
    ,p_pdt_attribute26               => p_pdt_attribute26
    ,p_pdt_attribute27               => p_pdt_attribute27
    ,p_pdt_attribute28               => p_pdt_attribute28
    ,p_pdt_attribute29               => p_pdt_attribute29
    ,p_pdt_attribute30               => p_pdt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_pymt_check_det
    --
    ben_pymt_check_det_bk1.create_pymt_check_det_a
      (
       p_pymt_check_det_id              =>  l_pymt_check_det_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_check_num                      =>  p_check_num
      ,p_pymt_dt                        =>  p_pymt_dt
      ,p_pymt_amt                       =>  p_pymt_amt
      ,p_pdt_attribute_category         =>  p_pdt_attribute_category
      ,p_pdt_attribute1                 =>  p_pdt_attribute1
      ,p_pdt_attribute2                 =>  p_pdt_attribute2
      ,p_pdt_attribute3                 =>  p_pdt_attribute3
      ,p_pdt_attribute4                 =>  p_pdt_attribute4
      ,p_pdt_attribute5                 =>  p_pdt_attribute5
      ,p_pdt_attribute6                 =>  p_pdt_attribute6
      ,p_pdt_attribute7                 =>  p_pdt_attribute7
      ,p_pdt_attribute8                 =>  p_pdt_attribute8
      ,p_pdt_attribute9                 =>  p_pdt_attribute9
      ,p_pdt_attribute10                =>  p_pdt_attribute10
      ,p_pdt_attribute11                =>  p_pdt_attribute11
      ,p_pdt_attribute12                =>  p_pdt_attribute12
      ,p_pdt_attribute13                =>  p_pdt_attribute13
      ,p_pdt_attribute14                =>  p_pdt_attribute14
      ,p_pdt_attribute15                =>  p_pdt_attribute15
      ,p_pdt_attribute16                =>  p_pdt_attribute16
      ,p_pdt_attribute17                =>  p_pdt_attribute17
      ,p_pdt_attribute18                =>  p_pdt_attribute18
      ,p_pdt_attribute19                =>  p_pdt_attribute19
      ,p_pdt_attribute20                =>  p_pdt_attribute20
      ,p_pdt_attribute21                =>  p_pdt_attribute21
      ,p_pdt_attribute22                =>  p_pdt_attribute22
      ,p_pdt_attribute23                =>  p_pdt_attribute23
      ,p_pdt_attribute24                =>  p_pdt_attribute24
      ,p_pdt_attribute25                =>  p_pdt_attribute25
      ,p_pdt_attribute26                =>  p_pdt_attribute26
      ,p_pdt_attribute27                =>  p_pdt_attribute27
      ,p_pdt_attribute28                =>  p_pdt_attribute28
      ,p_pdt_attribute29                =>  p_pdt_attribute29
      ,p_pdt_attribute30                =>  p_pdt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_pymt_check_det'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_pymt_check_det
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
  p_pymt_check_det_id := l_pymt_check_det_id;
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
    ROLLBACK TO create_pymt_check_det;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pymt_check_det_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_pymt_check_det;
    -- NOCOPY Changes
    p_pymt_check_det_id := null;
    p_object_version_number  := null;
    -- NOCOPY Changes
   raise;
    --
end create_pymt_check_det;
-- ----------------------------------------------------------------------------
-- |------------------------< update_pymt_check_det >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pymt_check_det
  (p_validate                       in boolean    default false
  ,p_pymt_check_det_id              in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_check_num                      in  varchar2  default hr_api.g_varchar2
  ,p_pymt_dt                        in  date      default hr_api.g_date
  ,p_pymt_amt                       in  number    default hr_api.g_number
  ,p_pdt_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pymt_check_det';
  l_object_version_number ben_pymt_check_det.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_pymt_check_det;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_pymt_check_det
    --
    ben_pymt_check_det_bk2.update_pymt_check_det_b
      (
       p_pymt_check_det_id              =>  p_pymt_check_det_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_check_num                      =>  p_check_num
      ,p_pymt_dt                        =>  p_pymt_dt
      ,p_pymt_amt                       =>  p_pymt_amt
      ,p_pdt_attribute_category         =>  p_pdt_attribute_category
      ,p_pdt_attribute1                 =>  p_pdt_attribute1
      ,p_pdt_attribute2                 =>  p_pdt_attribute2
      ,p_pdt_attribute3                 =>  p_pdt_attribute3
      ,p_pdt_attribute4                 =>  p_pdt_attribute4
      ,p_pdt_attribute5                 =>  p_pdt_attribute5
      ,p_pdt_attribute6                 =>  p_pdt_attribute6
      ,p_pdt_attribute7                 =>  p_pdt_attribute7
      ,p_pdt_attribute8                 =>  p_pdt_attribute8
      ,p_pdt_attribute9                 =>  p_pdt_attribute9
      ,p_pdt_attribute10                =>  p_pdt_attribute10
      ,p_pdt_attribute11                =>  p_pdt_attribute11
      ,p_pdt_attribute12                =>  p_pdt_attribute12
      ,p_pdt_attribute13                =>  p_pdt_attribute13
      ,p_pdt_attribute14                =>  p_pdt_attribute14
      ,p_pdt_attribute15                =>  p_pdt_attribute15
      ,p_pdt_attribute16                =>  p_pdt_attribute16
      ,p_pdt_attribute17                =>  p_pdt_attribute17
      ,p_pdt_attribute18                =>  p_pdt_attribute18
      ,p_pdt_attribute19                =>  p_pdt_attribute19
      ,p_pdt_attribute20                =>  p_pdt_attribute20
      ,p_pdt_attribute21                =>  p_pdt_attribute21
      ,p_pdt_attribute22                =>  p_pdt_attribute22
      ,p_pdt_attribute23                =>  p_pdt_attribute23
      ,p_pdt_attribute24                =>  p_pdt_attribute24
      ,p_pdt_attribute25                =>  p_pdt_attribute25
      ,p_pdt_attribute26                =>  p_pdt_attribute26
      ,p_pdt_attribute27                =>  p_pdt_attribute27
      ,p_pdt_attribute28                =>  p_pdt_attribute28
      ,p_pdt_attribute29                =>  p_pdt_attribute29
      ,p_pdt_attribute30                =>  p_pdt_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pymt_check_det'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_pymt_check_det
    --
  end;
  --
  ben_pdt_upd.upd
    (
     p_pymt_check_det_id             => p_pymt_check_det_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_check_num                     => p_check_num
    ,p_pymt_dt                       => p_pymt_dt
    ,p_pymt_amt                      => p_pymt_amt
    ,p_pdt_attribute_category        => p_pdt_attribute_category
    ,p_pdt_attribute1                => p_pdt_attribute1
    ,p_pdt_attribute2                => p_pdt_attribute2
    ,p_pdt_attribute3                => p_pdt_attribute3
    ,p_pdt_attribute4                => p_pdt_attribute4
    ,p_pdt_attribute5                => p_pdt_attribute5
    ,p_pdt_attribute6                => p_pdt_attribute6
    ,p_pdt_attribute7                => p_pdt_attribute7
    ,p_pdt_attribute8                => p_pdt_attribute8
    ,p_pdt_attribute9                => p_pdt_attribute9
    ,p_pdt_attribute10               => p_pdt_attribute10
    ,p_pdt_attribute11               => p_pdt_attribute11
    ,p_pdt_attribute12               => p_pdt_attribute12
    ,p_pdt_attribute13               => p_pdt_attribute13
    ,p_pdt_attribute14               => p_pdt_attribute14
    ,p_pdt_attribute15               => p_pdt_attribute15
    ,p_pdt_attribute16               => p_pdt_attribute16
    ,p_pdt_attribute17               => p_pdt_attribute17
    ,p_pdt_attribute18               => p_pdt_attribute18
    ,p_pdt_attribute19               => p_pdt_attribute19
    ,p_pdt_attribute20               => p_pdt_attribute20
    ,p_pdt_attribute21               => p_pdt_attribute21
    ,p_pdt_attribute22               => p_pdt_attribute22
    ,p_pdt_attribute23               => p_pdt_attribute23
    ,p_pdt_attribute24               => p_pdt_attribute24
    ,p_pdt_attribute25               => p_pdt_attribute25
    ,p_pdt_attribute26               => p_pdt_attribute26
    ,p_pdt_attribute27               => p_pdt_attribute27
    ,p_pdt_attribute28               => p_pdt_attribute28
    ,p_pdt_attribute29               => p_pdt_attribute29
    ,p_pdt_attribute30               => p_pdt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_pymt_check_det
    --
    ben_pymt_check_det_bk2.update_pymt_check_det_a
      (
       p_pymt_check_det_id              =>  p_pymt_check_det_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_check_num                      =>  p_check_num
      ,p_pymt_dt                        =>  p_pymt_dt
      ,p_pymt_amt                       =>  p_pymt_amt
      ,p_pdt_attribute_category         =>  p_pdt_attribute_category
      ,p_pdt_attribute1                 =>  p_pdt_attribute1
      ,p_pdt_attribute2                 =>  p_pdt_attribute2
      ,p_pdt_attribute3                 =>  p_pdt_attribute3
      ,p_pdt_attribute4                 =>  p_pdt_attribute4
      ,p_pdt_attribute5                 =>  p_pdt_attribute5
      ,p_pdt_attribute6                 =>  p_pdt_attribute6
      ,p_pdt_attribute7                 =>  p_pdt_attribute7
      ,p_pdt_attribute8                 =>  p_pdt_attribute8
      ,p_pdt_attribute9                 =>  p_pdt_attribute9
      ,p_pdt_attribute10                =>  p_pdt_attribute10
      ,p_pdt_attribute11                =>  p_pdt_attribute11
      ,p_pdt_attribute12                =>  p_pdt_attribute12
      ,p_pdt_attribute13                =>  p_pdt_attribute13
      ,p_pdt_attribute14                =>  p_pdt_attribute14
      ,p_pdt_attribute15                =>  p_pdt_attribute15
      ,p_pdt_attribute16                =>  p_pdt_attribute16
      ,p_pdt_attribute17                =>  p_pdt_attribute17
      ,p_pdt_attribute18                =>  p_pdt_attribute18
      ,p_pdt_attribute19                =>  p_pdt_attribute19
      ,p_pdt_attribute20                =>  p_pdt_attribute20
      ,p_pdt_attribute21                =>  p_pdt_attribute21
      ,p_pdt_attribute22                =>  p_pdt_attribute22
      ,p_pdt_attribute23                =>  p_pdt_attribute23
      ,p_pdt_attribute24                =>  p_pdt_attribute24
      ,p_pdt_attribute25                =>  p_pdt_attribute25
      ,p_pdt_attribute26                =>  p_pdt_attribute26
      ,p_pdt_attribute27                =>  p_pdt_attribute27
      ,p_pdt_attribute28                =>  p_pdt_attribute28
      ,p_pdt_attribute29                =>  p_pdt_attribute29
      ,p_pdt_attribute30                =>  p_pdt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pymt_check_det'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_pymt_check_det
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
    ROLLBACK TO update_pymt_check_det;
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
    ROLLBACK TO update_pymt_check_det;
    raise;
    --
end update_pymt_check_det;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pymt_check_det >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pymt_check_det
  (p_validate                       in  boolean  default false
  ,p_pymt_check_det_id              in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pymt_check_det';
  l_object_version_number ben_pymt_check_det.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_pymt_check_det;
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
    -- Start of API User Hook for the before hook of delete_pymt_check_det
    --
    ben_pymt_check_det_bk3.delete_pymt_check_det_b
      (
       p_pymt_check_det_id              =>  p_pymt_check_det_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pymt_check_det'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_pymt_check_det
    --
  end;
  --
  ben_pdt_del.del
    (
     p_pymt_check_det_id             => p_pymt_check_det_id
    ,p_object_version_number         => l_object_version_number
    -- ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_pymt_check_det
    --
    ben_pymt_check_det_bk3.delete_pymt_check_det_a
      (
       p_pymt_check_det_id              =>  p_pymt_check_det_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pymt_check_det'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_pymt_check_det
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
    ROLLBACK TO delete_pymt_check_det;
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
    ROLLBACK TO delete_pymt_check_det;
    raise;
    --
end delete_pymt_check_det;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pymt_check_det_id              in     number
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
  ben_pdt_shd.lck
    (
      p_pymt_check_det_id          => p_pymt_check_det_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_pymt_check_det_api;

/
