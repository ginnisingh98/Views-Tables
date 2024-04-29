--------------------------------------------------------
--  DDL for Package Body BEN_PER_CM_USG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PER_CM_USG_API" as
/* $Header: bepcuapi.pkb 120.0 2005/05/28 10:19:14 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PER_CM_USG_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PER_CM_USG >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM_USG
  (p_validate                       in  boolean   default false
  ,p_per_cm_usg_id                  out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_per_cm_id                      in  number    default null
  ,p_cm_typ_usg_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcu_attribute_category         in  varchar2  default null
  ,p_pcu_attribute1                 in  varchar2  default null
  ,p_pcu_attribute2                 in  varchar2  default null
  ,p_pcu_attribute3                 in  varchar2  default null
  ,p_pcu_attribute4                 in  varchar2  default null
  ,p_pcu_attribute5                 in  varchar2  default null
  ,p_pcu_attribute6                 in  varchar2  default null
  ,p_pcu_attribute7                 in  varchar2  default null
  ,p_pcu_attribute8                 in  varchar2  default null
  ,p_pcu_attribute9                 in  varchar2  default null
  ,p_pcu_attribute10                in  varchar2  default null
  ,p_pcu_attribute11                in  varchar2  default null
  ,p_pcu_attribute12                in  varchar2  default null
  ,p_pcu_attribute13                in  varchar2  default null
  ,p_pcu_attribute14                in  varchar2  default null
  ,p_pcu_attribute15                in  varchar2  default null
  ,p_pcu_attribute16                in  varchar2  default null
  ,p_pcu_attribute17                in  varchar2  default null
  ,p_pcu_attribute18                in  varchar2  default null
  ,p_pcu_attribute19                in  varchar2  default null
  ,p_pcu_attribute20                in  varchar2  default null
  ,p_pcu_attribute21                in  varchar2  default null
  ,p_pcu_attribute22                in  varchar2  default null
  ,p_pcu_attribute23                in  varchar2  default null
  ,p_pcu_attribute24                in  varchar2  default null
  ,p_pcu_attribute25                in  varchar2  default null
  ,p_pcu_attribute26                in  varchar2  default null
  ,p_pcu_attribute27                in  varchar2  default null
  ,p_pcu_attribute28                in  varchar2  default null
  ,p_pcu_attribute29                in  varchar2  default null
  ,p_pcu_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_per_cm_usg_id ben_per_cm_usg_f.per_cm_usg_id%TYPE;
  l_effective_start_date ben_per_cm_usg_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_usg_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PER_CM_USG';
  l_object_version_number ben_per_cm_usg_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PER_CM_USG;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PER_CM_USG
    --
    ben_PER_CM_USG_bk1.create_PER_CM_USG_b
      (p_per_cm_id                      =>  p_per_cm_id
      ,p_cm_typ_usg_id                  =>  p_cm_typ_usg_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcu_attribute_category         =>  p_pcu_attribute_category
      ,p_pcu_attribute1                 =>  p_pcu_attribute1
      ,p_pcu_attribute2                 =>  p_pcu_attribute2
      ,p_pcu_attribute3                 =>  p_pcu_attribute3
      ,p_pcu_attribute4                 =>  p_pcu_attribute4
      ,p_pcu_attribute5                 =>  p_pcu_attribute5
      ,p_pcu_attribute6                 =>  p_pcu_attribute6
      ,p_pcu_attribute7                 =>  p_pcu_attribute7
      ,p_pcu_attribute8                 =>  p_pcu_attribute8
      ,p_pcu_attribute9                 =>  p_pcu_attribute9
      ,p_pcu_attribute10                =>  p_pcu_attribute10
      ,p_pcu_attribute11                =>  p_pcu_attribute11
      ,p_pcu_attribute12                =>  p_pcu_attribute12
      ,p_pcu_attribute13                =>  p_pcu_attribute13
      ,p_pcu_attribute14                =>  p_pcu_attribute14
      ,p_pcu_attribute15                =>  p_pcu_attribute15
      ,p_pcu_attribute16                =>  p_pcu_attribute16
      ,p_pcu_attribute17                =>  p_pcu_attribute17
      ,p_pcu_attribute18                =>  p_pcu_attribute18
      ,p_pcu_attribute19                =>  p_pcu_attribute19
      ,p_pcu_attribute20                =>  p_pcu_attribute20
      ,p_pcu_attribute21                =>  p_pcu_attribute21
      ,p_pcu_attribute22                =>  p_pcu_attribute22
      ,p_pcu_attribute23                =>  p_pcu_attribute23
      ,p_pcu_attribute24                =>  p_pcu_attribute24
      ,p_pcu_attribute25                =>  p_pcu_attribute25
      ,p_pcu_attribute26                =>  p_pcu_attribute26
      ,p_pcu_attribute27                =>  p_pcu_attribute27
      ,p_pcu_attribute28                =>  p_pcu_attribute28
      ,p_pcu_attribute29                =>  p_pcu_attribute29
      ,p_pcu_attribute30                =>  p_pcu_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_CM_USG'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_PER_CM_USG
    --
  end;
  --
  ben_pcu_ins.ins
    (p_per_cm_usg_id                 => l_per_cm_usg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_per_cm_id                     => p_per_cm_id
    ,p_cm_typ_usg_id                 => p_cm_typ_usg_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcu_attribute_category        => p_pcu_attribute_category
    ,p_pcu_attribute1                => p_pcu_attribute1
    ,p_pcu_attribute2                => p_pcu_attribute2
    ,p_pcu_attribute3                => p_pcu_attribute3
    ,p_pcu_attribute4                => p_pcu_attribute4
    ,p_pcu_attribute5                => p_pcu_attribute5
    ,p_pcu_attribute6                => p_pcu_attribute6
    ,p_pcu_attribute7                => p_pcu_attribute7
    ,p_pcu_attribute8                => p_pcu_attribute8
    ,p_pcu_attribute9                => p_pcu_attribute9
    ,p_pcu_attribute10               => p_pcu_attribute10
    ,p_pcu_attribute11               => p_pcu_attribute11
    ,p_pcu_attribute12               => p_pcu_attribute12
    ,p_pcu_attribute13               => p_pcu_attribute13
    ,p_pcu_attribute14               => p_pcu_attribute14
    ,p_pcu_attribute15               => p_pcu_attribute15
    ,p_pcu_attribute16               => p_pcu_attribute16
    ,p_pcu_attribute17               => p_pcu_attribute17
    ,p_pcu_attribute18               => p_pcu_attribute18
    ,p_pcu_attribute19               => p_pcu_attribute19
    ,p_pcu_attribute20               => p_pcu_attribute20
    ,p_pcu_attribute21               => p_pcu_attribute21
    ,p_pcu_attribute22               => p_pcu_attribute22
    ,p_pcu_attribute23               => p_pcu_attribute23
    ,p_pcu_attribute24               => p_pcu_attribute24
    ,p_pcu_attribute25               => p_pcu_attribute25
    ,p_pcu_attribute26               => p_pcu_attribute26
    ,p_pcu_attribute27               => p_pcu_attribute27
    ,p_pcu_attribute28               => p_pcu_attribute28
    ,p_pcu_attribute29               => p_pcu_attribute29
    ,p_pcu_attribute30               => p_pcu_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PER_CM_USG
    --
    ben_PER_CM_USG_bk1.create_PER_CM_USG_a
      (p_per_cm_usg_id                  =>  l_per_cm_usg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_cm_typ_usg_id                  =>  p_cm_typ_usg_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcu_attribute_category         =>  p_pcu_attribute_category
      ,p_pcu_attribute1                 =>  p_pcu_attribute1
      ,p_pcu_attribute2                 =>  p_pcu_attribute2
      ,p_pcu_attribute3                 =>  p_pcu_attribute3
      ,p_pcu_attribute4                 =>  p_pcu_attribute4
      ,p_pcu_attribute5                 =>  p_pcu_attribute5
      ,p_pcu_attribute6                 =>  p_pcu_attribute6
      ,p_pcu_attribute7                 =>  p_pcu_attribute7
      ,p_pcu_attribute8                 =>  p_pcu_attribute8
      ,p_pcu_attribute9                 =>  p_pcu_attribute9
      ,p_pcu_attribute10                =>  p_pcu_attribute10
      ,p_pcu_attribute11                =>  p_pcu_attribute11
      ,p_pcu_attribute12                =>  p_pcu_attribute12
      ,p_pcu_attribute13                =>  p_pcu_attribute13
      ,p_pcu_attribute14                =>  p_pcu_attribute14
      ,p_pcu_attribute15                =>  p_pcu_attribute15
      ,p_pcu_attribute16                =>  p_pcu_attribute16
      ,p_pcu_attribute17                =>  p_pcu_attribute17
      ,p_pcu_attribute18                =>  p_pcu_attribute18
      ,p_pcu_attribute19                =>  p_pcu_attribute19
      ,p_pcu_attribute20                =>  p_pcu_attribute20
      ,p_pcu_attribute21                =>  p_pcu_attribute21
      ,p_pcu_attribute22                =>  p_pcu_attribute22
      ,p_pcu_attribute23                =>  p_pcu_attribute23
      ,p_pcu_attribute24                =>  p_pcu_attribute24
      ,p_pcu_attribute25                =>  p_pcu_attribute25
      ,p_pcu_attribute26                =>  p_pcu_attribute26
      ,p_pcu_attribute27                =>  p_pcu_attribute27
      ,p_pcu_attribute28                =>  p_pcu_attribute28
      ,p_pcu_attribute29                =>  p_pcu_attribute29
      ,p_pcu_attribute30                =>  p_pcu_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_CM_USG'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_PER_CM_USG
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
  p_per_cm_usg_id := l_per_cm_usg_id;
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
    ROLLBACK TO create_PER_CM_USG;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_cm_usg_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PER_CM_USG;
    --
    p_per_cm_usg_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end create_PER_CM_USG;
-- ----------------------------------------------------------------------------
-- |------------------------< create_PER_CM_USG_perf >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM_USG_perf
  (p_validate                       in  boolean   default false
  ,p_per_cm_usg_id                  out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_per_cm_id                      in  number    default null
  ,p_cm_typ_usg_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcu_attribute_category         in  varchar2  default null
  ,p_pcu_attribute1                 in  varchar2  default null
  ,p_pcu_attribute2                 in  varchar2  default null
  ,p_pcu_attribute3                 in  varchar2  default null
  ,p_pcu_attribute4                 in  varchar2  default null
  ,p_pcu_attribute5                 in  varchar2  default null
  ,p_pcu_attribute6                 in  varchar2  default null
  ,p_pcu_attribute7                 in  varchar2  default null
  ,p_pcu_attribute8                 in  varchar2  default null
  ,p_pcu_attribute9                 in  varchar2  default null
  ,p_pcu_attribute10                in  varchar2  default null
  ,p_pcu_attribute11                in  varchar2  default null
  ,p_pcu_attribute12                in  varchar2  default null
  ,p_pcu_attribute13                in  varchar2  default null
  ,p_pcu_attribute14                in  varchar2  default null
  ,p_pcu_attribute15                in  varchar2  default null
  ,p_pcu_attribute16                in  varchar2  default null
  ,p_pcu_attribute17                in  varchar2  default null
  ,p_pcu_attribute18                in  varchar2  default null
  ,p_pcu_attribute19                in  varchar2  default null
  ,p_pcu_attribute20                in  varchar2  default null
  ,p_pcu_attribute21                in  varchar2  default null
  ,p_pcu_attribute22                in  varchar2  default null
  ,p_pcu_attribute23                in  varchar2  default null
  ,p_pcu_attribute24                in  varchar2  default null
  ,p_pcu_attribute25                in  varchar2  default null
  ,p_pcu_attribute26                in  varchar2  default null
  ,p_pcu_attribute27                in  varchar2  default null
  ,p_pcu_attribute28                in  varchar2  default null
  ,p_pcu_attribute29                in  varchar2  default null
  ,p_pcu_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_per_cm_usg_id ben_per_cm_usg_f.per_cm_usg_id%TYPE;
  l_effective_start_date ben_per_cm_usg_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_usg_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PER_CM_USG';
  l_object_version_number ben_per_cm_usg_f.object_version_number%TYPE;
  --
  cursor c_seq is
    select ben_per_cm_usg_f_s.nextval
    from   sys.dual;
  --
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PER_CM_USG;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PER_CM_USG
    --
    ben_PER_CM_USG_bk1.create_PER_CM_USG_b
      (p_per_cm_id                      =>  p_per_cm_id
      ,p_cm_typ_usg_id                  =>  p_cm_typ_usg_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcu_attribute_category         =>  p_pcu_attribute_category
      ,p_pcu_attribute1                 =>  p_pcu_attribute1
      ,p_pcu_attribute2                 =>  p_pcu_attribute2
      ,p_pcu_attribute3                 =>  p_pcu_attribute3
      ,p_pcu_attribute4                 =>  p_pcu_attribute4
      ,p_pcu_attribute5                 =>  p_pcu_attribute5
      ,p_pcu_attribute6                 =>  p_pcu_attribute6
      ,p_pcu_attribute7                 =>  p_pcu_attribute7
      ,p_pcu_attribute8                 =>  p_pcu_attribute8
      ,p_pcu_attribute9                 =>  p_pcu_attribute9
      ,p_pcu_attribute10                =>  p_pcu_attribute10
      ,p_pcu_attribute11                =>  p_pcu_attribute11
      ,p_pcu_attribute12                =>  p_pcu_attribute12
      ,p_pcu_attribute13                =>  p_pcu_attribute13
      ,p_pcu_attribute14                =>  p_pcu_attribute14
      ,p_pcu_attribute15                =>  p_pcu_attribute15
      ,p_pcu_attribute16                =>  p_pcu_attribute16
      ,p_pcu_attribute17                =>  p_pcu_attribute17
      ,p_pcu_attribute18                =>  p_pcu_attribute18
      ,p_pcu_attribute19                =>  p_pcu_attribute19
      ,p_pcu_attribute20                =>  p_pcu_attribute20
      ,p_pcu_attribute21                =>  p_pcu_attribute21
      ,p_pcu_attribute22                =>  p_pcu_attribute22
      ,p_pcu_attribute23                =>  p_pcu_attribute23
      ,p_pcu_attribute24                =>  p_pcu_attribute24
      ,p_pcu_attribute25                =>  p_pcu_attribute25
      ,p_pcu_attribute26                =>  p_pcu_attribute26
      ,p_pcu_attribute27                =>  p_pcu_attribute27
      ,p_pcu_attribute28                =>  p_pcu_attribute28
      ,p_pcu_attribute29                =>  p_pcu_attribute29
      ,p_pcu_attribute30                =>  p_pcu_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_CM_USG'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_PER_CM_USG
    --
  end;
  --
  open c_seq;
    --
    fetch c_seq into l_per_cm_usg_id;
    --
  close c_seq;
  --
  -- Post insert row handler hook
  --
  dt_api.validate_dt_mode
    (p_effective_date          => p_effective_date,
     p_datetrack_mode          => 'INSERT',
     p_base_table_name         => 'ben_per_cm_usg_f',
     p_base_key_column         => 'per_cm_usg_id',
     p_base_key_value          => p_per_cm_usg_id,
     p_parent_table_name1      => 'ben_cm_typ_usg_f',
     p_parent_key_column1      => 'cm_typ_usg_id',
     p_parent_key_value1       => p_cm_typ_usg_id,
     p_parent_table_name2      => 'ben_per_cm_f',
     p_parent_key_column2      => 'per_cm_id',
     p_parent_key_value2       => p_per_cm_id,
     p_enforce_foreign_locking => false,
     p_validation_start_date   => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  l_effective_start_date := l_validation_start_date;
  l_effective_end_date := l_validation_end_date;
  l_object_version_number := 1;
  --
  insert into ben_per_cm_usg_f
    (per_cm_usg_id
    ,effective_start_date
    ,effective_end_date
    ,per_cm_id
    ,cm_typ_usg_id
    ,business_group_id
    ,pcu_attribute_category
    ,pcu_attribute1
    ,pcu_attribute2
    ,pcu_attribute3
    ,pcu_attribute4
    ,pcu_attribute5
    ,pcu_attribute6
    ,pcu_attribute7
    ,pcu_attribute8
    ,pcu_attribute9
    ,pcu_attribute10
    ,pcu_attribute11
    ,pcu_attribute12
    ,pcu_attribute13
    ,pcu_attribute14
    ,pcu_attribute15
    ,pcu_attribute16
    ,pcu_attribute17
    ,pcu_attribute18
    ,pcu_attribute19
    ,pcu_attribute20
    ,pcu_attribute21
    ,pcu_attribute22
    ,pcu_attribute23
    ,pcu_attribute24
    ,pcu_attribute25
    ,pcu_attribute26
    ,pcu_attribute27
    ,pcu_attribute28
    ,pcu_attribute29
    ,pcu_attribute30
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,object_version_number)
  values
    (l_per_cm_usg_id
    ,l_effective_start_date
    ,l_effective_end_date
    ,p_per_cm_id
    ,p_cm_typ_usg_id
    ,p_business_group_id
    ,p_pcu_attribute_category
    ,p_pcu_attribute1
    ,p_pcu_attribute2
    ,p_pcu_attribute3
    ,p_pcu_attribute4
    ,p_pcu_attribute5
    ,p_pcu_attribute6
    ,p_pcu_attribute7
    ,p_pcu_attribute8
    ,p_pcu_attribute9
    ,p_pcu_attribute10
    ,p_pcu_attribute11
    ,p_pcu_attribute12
    ,p_pcu_attribute13
    ,p_pcu_attribute14
    ,p_pcu_attribute15
    ,p_pcu_attribute16
    ,p_pcu_attribute17
    ,p_pcu_attribute18
    ,p_pcu_attribute19
    ,p_pcu_attribute20
    ,p_pcu_attribute21
    ,p_pcu_attribute22
    ,p_pcu_attribute23
    ,p_pcu_attribute24
    ,p_pcu_attribute25
    ,p_pcu_attribute26
    ,p_pcu_attribute27
    ,p_pcu_attribute28
    ,p_pcu_attribute29
    ,p_pcu_attribute30
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,l_object_version_number);
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_pcu_rki.after_insert
      (p_per_cm_usg_id                 =>l_per_cm_usg_id
      ,p_effective_start_date          =>l_effective_start_date
      ,p_effective_end_date            =>l_effective_end_date
      ,p_per_cm_id                     =>p_per_cm_id
      ,p_cm_typ_usg_id                 =>p_cm_typ_usg_id
      ,p_business_group_id             =>p_business_group_id
      ,p_pcu_attribute_category        =>p_pcu_attribute_category
      ,p_pcu_attribute1                =>p_pcu_attribute1
      ,p_pcu_attribute2                =>p_pcu_attribute2
      ,p_pcu_attribute3                =>p_pcu_attribute3
      ,p_pcu_attribute4                =>p_pcu_attribute4
      ,p_pcu_attribute5                =>p_pcu_attribute5
      ,p_pcu_attribute6                =>p_pcu_attribute6
      ,p_pcu_attribute7                =>p_pcu_attribute7
      ,p_pcu_attribute8                =>p_pcu_attribute8
      ,p_pcu_attribute9                =>p_pcu_attribute9
      ,p_pcu_attribute10               =>p_pcu_attribute10
      ,p_pcu_attribute11               =>p_pcu_attribute11
      ,p_pcu_attribute12               =>p_pcu_attribute12
      ,p_pcu_attribute13               =>p_pcu_attribute13
      ,p_pcu_attribute14               =>p_pcu_attribute14
      ,p_pcu_attribute15               =>p_pcu_attribute15
      ,p_pcu_attribute16               =>p_pcu_attribute16
      ,p_pcu_attribute17               =>p_pcu_attribute17
      ,p_pcu_attribute18               =>p_pcu_attribute18
      ,p_pcu_attribute19               =>p_pcu_attribute19
      ,p_pcu_attribute20               =>p_pcu_attribute20
      ,p_pcu_attribute21               =>p_pcu_attribute21
      ,p_pcu_attribute22               =>p_pcu_attribute22
      ,p_pcu_attribute23               =>p_pcu_attribute23
      ,p_pcu_attribute24               =>p_pcu_attribute24
      ,p_pcu_attribute25               =>p_pcu_attribute25
      ,p_pcu_attribute26               =>p_pcu_attribute26
      ,p_pcu_attribute27               =>p_pcu_attribute27
      ,p_pcu_attribute28               =>p_pcu_attribute28
      ,p_pcu_attribute29               =>p_pcu_attribute29
      ,p_pcu_attribute30               =>p_pcu_attribute30
      ,p_request_id                    =>p_request_id
      ,p_program_application_id        =>p_program_application_id
      ,p_program_id                    =>p_program_id
      ,p_program_update_date           =>p_program_update_date
      ,p_object_version_number         =>l_object_version_number
      ,p_effective_date                =>p_effective_date
      ,p_validation_start_date         =>l_validation_start_date
      ,p_validation_end_date           =>l_validation_end_date);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_per_cm_usg_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PER_CM_USG
    --
    ben_PER_CM_USG_bk1.create_PER_CM_USG_a
      (p_per_cm_usg_id                  =>  l_per_cm_usg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_cm_typ_usg_id                  =>  p_cm_typ_usg_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcu_attribute_category         =>  p_pcu_attribute_category
      ,p_pcu_attribute1                 =>  p_pcu_attribute1
      ,p_pcu_attribute2                 =>  p_pcu_attribute2
      ,p_pcu_attribute3                 =>  p_pcu_attribute3
      ,p_pcu_attribute4                 =>  p_pcu_attribute4
      ,p_pcu_attribute5                 =>  p_pcu_attribute5
      ,p_pcu_attribute6                 =>  p_pcu_attribute6
      ,p_pcu_attribute7                 =>  p_pcu_attribute7
      ,p_pcu_attribute8                 =>  p_pcu_attribute8
      ,p_pcu_attribute9                 =>  p_pcu_attribute9
      ,p_pcu_attribute10                =>  p_pcu_attribute10
      ,p_pcu_attribute11                =>  p_pcu_attribute11
      ,p_pcu_attribute12                =>  p_pcu_attribute12
      ,p_pcu_attribute13                =>  p_pcu_attribute13
      ,p_pcu_attribute14                =>  p_pcu_attribute14
      ,p_pcu_attribute15                =>  p_pcu_attribute15
      ,p_pcu_attribute16                =>  p_pcu_attribute16
      ,p_pcu_attribute17                =>  p_pcu_attribute17
      ,p_pcu_attribute18                =>  p_pcu_attribute18
      ,p_pcu_attribute19                =>  p_pcu_attribute19
      ,p_pcu_attribute20                =>  p_pcu_attribute20
      ,p_pcu_attribute21                =>  p_pcu_attribute21
      ,p_pcu_attribute22                =>  p_pcu_attribute22
      ,p_pcu_attribute23                =>  p_pcu_attribute23
      ,p_pcu_attribute24                =>  p_pcu_attribute24
      ,p_pcu_attribute25                =>  p_pcu_attribute25
      ,p_pcu_attribute26                =>  p_pcu_attribute26
      ,p_pcu_attribute27                =>  p_pcu_attribute27
      ,p_pcu_attribute28                =>  p_pcu_attribute28
      ,p_pcu_attribute29                =>  p_pcu_attribute29
      ,p_pcu_attribute30                =>  p_pcu_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_CM_USG'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_PER_CM_USG
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_per_cm_usg_id := l_per_cm_usg_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_PER_CM_USG;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_cm_usg_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PER_CM_USG;
    --
    p_per_cm_usg_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    --
    raise;
    --
end create_PER_CM_USG_perf;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PER_CM_USG >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PER_CM_USG
  (p_validate                       in  boolean   default false
  ,p_per_cm_usg_id                  in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_per_cm_id                      in  number    default hr_api.g_number
  ,p_cm_typ_usg_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcu_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcu_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PER_CM_USG';
  l_object_version_number ben_per_cm_usg_f.object_version_number%TYPE;
  l_effective_start_date ben_per_cm_usg_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_usg_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PER_CM_USG;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PER_CM_USG
    --
    ben_PER_CM_USG_bk2.update_PER_CM_USG_b
      (p_per_cm_usg_id                  =>  p_per_cm_usg_id
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_cm_typ_usg_id                  =>  p_cm_typ_usg_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcu_attribute_category         =>  p_pcu_attribute_category
      ,p_pcu_attribute1                 =>  p_pcu_attribute1
      ,p_pcu_attribute2                 =>  p_pcu_attribute2
      ,p_pcu_attribute3                 =>  p_pcu_attribute3
      ,p_pcu_attribute4                 =>  p_pcu_attribute4
      ,p_pcu_attribute5                 =>  p_pcu_attribute5
      ,p_pcu_attribute6                 =>  p_pcu_attribute6
      ,p_pcu_attribute7                 =>  p_pcu_attribute7
      ,p_pcu_attribute8                 =>  p_pcu_attribute8
      ,p_pcu_attribute9                 =>  p_pcu_attribute9
      ,p_pcu_attribute10                =>  p_pcu_attribute10
      ,p_pcu_attribute11                =>  p_pcu_attribute11
      ,p_pcu_attribute12                =>  p_pcu_attribute12
      ,p_pcu_attribute13                =>  p_pcu_attribute13
      ,p_pcu_attribute14                =>  p_pcu_attribute14
      ,p_pcu_attribute15                =>  p_pcu_attribute15
      ,p_pcu_attribute16                =>  p_pcu_attribute16
      ,p_pcu_attribute17                =>  p_pcu_attribute17
      ,p_pcu_attribute18                =>  p_pcu_attribute18
      ,p_pcu_attribute19                =>  p_pcu_attribute19
      ,p_pcu_attribute20                =>  p_pcu_attribute20
      ,p_pcu_attribute21                =>  p_pcu_attribute21
      ,p_pcu_attribute22                =>  p_pcu_attribute22
      ,p_pcu_attribute23                =>  p_pcu_attribute23
      ,p_pcu_attribute24                =>  p_pcu_attribute24
      ,p_pcu_attribute25                =>  p_pcu_attribute25
      ,p_pcu_attribute26                =>  p_pcu_attribute26
      ,p_pcu_attribute27                =>  p_pcu_attribute27
      ,p_pcu_attribute28                =>  p_pcu_attribute28
      ,p_pcu_attribute29                =>  p_pcu_attribute29
      ,p_pcu_attribute30                =>  p_pcu_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PER_CM_USG'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_PER_CM_USG
    --
  end;
  --
  ben_pcu_upd.upd
    (p_per_cm_usg_id                 => p_per_cm_usg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_per_cm_id                     => p_per_cm_id
    ,p_cm_typ_usg_id                 => p_cm_typ_usg_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcu_attribute_category        => p_pcu_attribute_category
    ,p_pcu_attribute1                => p_pcu_attribute1
    ,p_pcu_attribute2                => p_pcu_attribute2
    ,p_pcu_attribute3                => p_pcu_attribute3
    ,p_pcu_attribute4                => p_pcu_attribute4
    ,p_pcu_attribute5                => p_pcu_attribute5
    ,p_pcu_attribute6                => p_pcu_attribute6
    ,p_pcu_attribute7                => p_pcu_attribute7
    ,p_pcu_attribute8                => p_pcu_attribute8
    ,p_pcu_attribute9                => p_pcu_attribute9
    ,p_pcu_attribute10               => p_pcu_attribute10
    ,p_pcu_attribute11               => p_pcu_attribute11
    ,p_pcu_attribute12               => p_pcu_attribute12
    ,p_pcu_attribute13               => p_pcu_attribute13
    ,p_pcu_attribute14               => p_pcu_attribute14
    ,p_pcu_attribute15               => p_pcu_attribute15
    ,p_pcu_attribute16               => p_pcu_attribute16
    ,p_pcu_attribute17               => p_pcu_attribute17
    ,p_pcu_attribute18               => p_pcu_attribute18
    ,p_pcu_attribute19               => p_pcu_attribute19
    ,p_pcu_attribute20               => p_pcu_attribute20
    ,p_pcu_attribute21               => p_pcu_attribute21
    ,p_pcu_attribute22               => p_pcu_attribute22
    ,p_pcu_attribute23               => p_pcu_attribute23
    ,p_pcu_attribute24               => p_pcu_attribute24
    ,p_pcu_attribute25               => p_pcu_attribute25
    ,p_pcu_attribute26               => p_pcu_attribute26
    ,p_pcu_attribute27               => p_pcu_attribute27
    ,p_pcu_attribute28               => p_pcu_attribute28
    ,p_pcu_attribute29               => p_pcu_attribute29
    ,p_pcu_attribute30               => p_pcu_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PER_CM_USG
    --
    ben_PER_CM_USG_bk2.update_PER_CM_USG_a
      (p_per_cm_usg_id                  =>  p_per_cm_usg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_cm_typ_usg_id                  =>  p_cm_typ_usg_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcu_attribute_category         =>  p_pcu_attribute_category
      ,p_pcu_attribute1                 =>  p_pcu_attribute1
      ,p_pcu_attribute2                 =>  p_pcu_attribute2
      ,p_pcu_attribute3                 =>  p_pcu_attribute3
      ,p_pcu_attribute4                 =>  p_pcu_attribute4
      ,p_pcu_attribute5                 =>  p_pcu_attribute5
      ,p_pcu_attribute6                 =>  p_pcu_attribute6
      ,p_pcu_attribute7                 =>  p_pcu_attribute7
      ,p_pcu_attribute8                 =>  p_pcu_attribute8
      ,p_pcu_attribute9                 =>  p_pcu_attribute9
      ,p_pcu_attribute10                =>  p_pcu_attribute10
      ,p_pcu_attribute11                =>  p_pcu_attribute11
      ,p_pcu_attribute12                =>  p_pcu_attribute12
      ,p_pcu_attribute13                =>  p_pcu_attribute13
      ,p_pcu_attribute14                =>  p_pcu_attribute14
      ,p_pcu_attribute15                =>  p_pcu_attribute15
      ,p_pcu_attribute16                =>  p_pcu_attribute16
      ,p_pcu_attribute17                =>  p_pcu_attribute17
      ,p_pcu_attribute18                =>  p_pcu_attribute18
      ,p_pcu_attribute19                =>  p_pcu_attribute19
      ,p_pcu_attribute20                =>  p_pcu_attribute20
      ,p_pcu_attribute21                =>  p_pcu_attribute21
      ,p_pcu_attribute22                =>  p_pcu_attribute22
      ,p_pcu_attribute23                =>  p_pcu_attribute23
      ,p_pcu_attribute24                =>  p_pcu_attribute24
      ,p_pcu_attribute25                =>  p_pcu_attribute25
      ,p_pcu_attribute26                =>  p_pcu_attribute26
      ,p_pcu_attribute27                =>  p_pcu_attribute27
      ,p_pcu_attribute28                =>  p_pcu_attribute28
      ,p_pcu_attribute29                =>  p_pcu_attribute29
      ,p_pcu_attribute30                =>  p_pcu_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PER_CM_USG'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_PER_CM_USG
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
    ROLLBACK TO update_PER_CM_USG;
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
    ROLLBACK TO update_PER_CM_USG;
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    --
    raise;
    --
end update_PER_CM_USG;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PER_CM_USG >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PER_CM_USG
  (p_validate                       in  boolean  default false
  ,p_per_cm_usg_id                  in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PER_CM_USG';
  l_object_version_number ben_per_cm_usg_f.object_version_number%TYPE;
  l_effective_start_date ben_per_cm_usg_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_usg_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PER_CM_USG;
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
    -- Start of API User Hook for the before hook of delete_PER_CM_USG
    --
    ben_PER_CM_USG_bk3.delete_PER_CM_USG_b
      (p_per_cm_usg_id                  =>  p_per_cm_usg_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PER_CM_USG'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_PER_CM_USG
    --
  end;
  --
  ben_pcu_del.del
    (p_per_cm_usg_id                 => p_per_cm_usg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PER_CM_USG
    --
    ben_PER_CM_USG_bk3.delete_PER_CM_USG_a
      (p_per_cm_usg_id                  =>  p_per_cm_usg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PER_CM_USG'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_PER_CM_USG
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
    ROLLBACK TO delete_PER_CM_USG;
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
    ROLLBACK TO delete_PER_CM_USG;
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    --
    raise;
    --
end delete_PER_CM_USG;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_per_cm_usg_id                  in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date) is
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
  ben_pcu_shd.lck
     (p_per_cm_usg_id              => p_per_cm_usg_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_PER_CM_USG_api;

/
