--------------------------------------------------------
--  DDL for Package Body BEN_VRBL_RT_ELIG_PRFL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VRBL_RT_ELIG_PRFL_API" as
/* $Header: bevepapi.pkb 115.1 2004/05/11 05:28:52 abparekh noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_vrbl_rt_elig_prfl_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_vrbl_rt_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_vrbl_rt_elig_prfl
  (p_validate                       in  boolean   default false
  ,p_vrbl_rt_elig_prfl_id                       out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_vrbl_rt_prfl_id                      in  number    default null
  ,p_eligy_prfl_id                         in  number    default null
  ,p_mndtry_flag                    in  varchar2  default null
  ,p_vep_attribute_category         in  varchar2  default null
  ,p_vep_attribute1                 in  varchar2  default null
  ,p_vep_attribute2                 in  varchar2  default null
  ,p_vep_attribute3                 in  varchar2  default null
  ,p_vep_attribute4                 in  varchar2  default null
  ,p_vep_attribute5                 in  varchar2  default null
  ,p_vep_attribute6                 in  varchar2  default null
  ,p_vep_attribute7                 in  varchar2  default null
  ,p_vep_attribute8                 in  varchar2  default null
  ,p_vep_attribute9                 in  varchar2  default null
  ,p_vep_attribute10                in  varchar2  default null
  ,p_vep_attribute11                in  varchar2  default null
  ,p_vep_attribute12                in  varchar2  default null
  ,p_vep_attribute13                in  varchar2  default null
  ,p_vep_attribute14                in  varchar2  default null
  ,p_vep_attribute15                in  varchar2  default null
  ,p_vep_attribute16                in  varchar2  default null
  ,p_vep_attribute17                in  varchar2  default null
  ,p_vep_attribute18                in  varchar2  default null
  ,p_vep_attribute19                in  varchar2  default null
  ,p_vep_attribute20                in  varchar2  default null
  ,p_vep_attribute21                in  varchar2  default null
  ,p_vep_attribute22                in  varchar2  default null
  ,p_vep_attribute23                in  varchar2  default null
  ,p_vep_attribute24                in  varchar2  default null
  ,p_vep_attribute25                in  varchar2  default null
  ,p_vep_attribute26                in  varchar2  default null
  ,p_vep_attribute27                in  varchar2  default null
  ,p_vep_attribute28                in  varchar2  default null
  ,p_vep_attribute29                in  varchar2  default null
  ,p_vep_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Cursor to find the uniqueness of the vrbl_rt_elig_prfl
  --
  cursor c_uniq_vrbl_rt_elig_prfl is
    select null from
         ben_vrbl_rt_elig_prfl_f vep
    where
          vep.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
     and  vep.eligy_prfl_id    = p_eligy_prfl_id
     and  p_effective_date between vep.effective_start_date and
                                   vep.effective_end_date ;
  --
  cursor c_future_vrbl_rt_elig_prfl is
    select vrbl_rt_elig_prfl_id, vep.effective_end_date from
         ben_vrbl_rt_elig_prfl_f vep
    where
      vep.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
     and  vep.eligy_prfl_id    = p_eligy_prfl_id
     and  vep.effective_start_date  > p_effective_date ;

  -- Declare cursors and local variables
  --
  l_vrbl_rt_elig_prfl_id ben_vrbl_rt_elig_prfl_f.vrbl_rt_elig_prfl_id%TYPE;
  l_effective_start_date ben_vrbl_rt_elig_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_vrbl_rt_elig_prfl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_vrbl_rt_elig_prfl';
  l_object_version_number ben_vrbl_rt_elig_prfl_f.object_version_number%TYPE;
  l_dummy      varchar2(1) := null ;
  l_future_vrbl_rt_elig_prfl_id ben_vrbl_rt_elig_prfl_f.vrbl_rt_elig_prfl_id%TYPE;
  l_future_record_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_vrbl_rt_elig_prfl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
    --
    open c_uniq_vrbl_rt_elig_prfl ;
    --
    fetch c_uniq_vrbl_rt_elig_prfl into l_dummy;
    --
    if c_uniq_vrbl_rt_elig_prfl%found then
    --
      close c_uniq_vrbl_rt_elig_prfl ;
      hr_utility.set_location('Record already exists. no need to insert another record', 20 ) ;
      hr_utility.set_location('exiting from '||l_proc,25);
      -- Bug : 3621420
      -- Raise an error as the ELPRO being inserted is already associated with the VAPRO
      fnd_message.set_name('BEN','BEN_93966_ELPRO_FOR_VAPRO_EXST');
      fnd_message.raise_error;
      --return ;
      -- Bug : 3621420
    --
    end if;
    close c_uniq_vrbl_rt_elig_prfl ;
    --
    open c_future_vrbl_rt_elig_prfl ;
    fetch c_future_vrbl_rt_elig_prfl into l_future_vrbl_rt_elig_prfl_id, l_future_record_end_date ;
    --
    if c_future_vrbl_rt_elig_prfl%found then
    --
      hr_utility.set_location('Future record exists. we need to extend the record ', 20 ) ;
      update ben_vrbl_rt_elig_prfl_f
      set effective_start_date = p_effective_date
      where vrbl_rt_elig_prfl_id = l_future_vrbl_rt_elig_prfl_id ;
      hr_utility.set_location('exiting from '||l_proc,25);
      close c_future_vrbl_rt_elig_prfl ;
      -- Bug : 3621420
      -- Set the new effective start and end date for the record
      p_effective_start_date := p_effective_date;
      p_effective_end_date := l_future_record_end_date;
      -- Bug : 3621420
      return ;
    --
    end if;
    close c_future_vrbl_rt_elig_prfl ;

    begin
    -- Start of API User Hook for the before hook of create_vrbl_rt_elig_prfl
    --
    ben_vrbl_rt_elig_prfl_bk1.create_vrbl_rt_elig_prfl_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                      =>  p_vrbl_rt_prfl_id
      ,p_eligy_prfl_id                         =>  p_eligy_prfl_id
      ,p_mndtry_flag                    => p_mndtry_flag
      ,p_vep_attribute_category         =>  p_vep_attribute_category
      ,p_vep_attribute1                 =>  p_vep_attribute1
      ,p_vep_attribute2                 =>  p_vep_attribute2
      ,p_vep_attribute3                 =>  p_vep_attribute3
      ,p_vep_attribute4                 =>  p_vep_attribute4
      ,p_vep_attribute5                 =>  p_vep_attribute5
      ,p_vep_attribute6                 =>  p_vep_attribute6
      ,p_vep_attribute7                 =>  p_vep_attribute7
      ,p_vep_attribute8                 =>  p_vep_attribute8
      ,p_vep_attribute9                 =>  p_vep_attribute9
      ,p_vep_attribute10                =>  p_vep_attribute10
      ,p_vep_attribute11                =>  p_vep_attribute11
      ,p_vep_attribute12                =>  p_vep_attribute12
      ,p_vep_attribute13                =>  p_vep_attribute13
      ,p_vep_attribute14                =>  p_vep_attribute14
      ,p_vep_attribute15                =>  p_vep_attribute15
      ,p_vep_attribute16                =>  p_vep_attribute16
      ,p_vep_attribute17                =>  p_vep_attribute17
      ,p_vep_attribute18                =>  p_vep_attribute18
      ,p_vep_attribute19                =>  p_vep_attribute19
      ,p_vep_attribute20                =>  p_vep_attribute20
      ,p_vep_attribute21                =>  p_vep_attribute21
      ,p_vep_attribute22                =>  p_vep_attribute22
      ,p_vep_attribute23                =>  p_vep_attribute23
      ,p_vep_attribute24                =>  p_vep_attribute24
      ,p_vep_attribute25                =>  p_vep_attribute25
      ,p_vep_attribute26                =>  p_vep_attribute26
      ,p_vep_attribute27                =>  p_vep_attribute27
      ,p_vep_attribute28                =>  p_vep_attribute28
      ,p_vep_attribute29                =>  p_vep_attribute29
      ,p_vep_attribute30                =>  p_vep_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_vrbl_rt_elig_prfl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_vrbl_rt_elig_prfl
    --
  end;
  --
  ben_vep_ins.ins
    (
     p_vrbl_rt_elig_prfl_id                      => l_vrbl_rt_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_vrbl_rt_prfl_id                     => p_vrbl_rt_prfl_id
    ,p_eligy_prfl_id                        => p_eligy_prfl_id
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_vep_attribute_category        => p_vep_attribute_category
    ,p_vep_attribute1                => p_vep_attribute1
    ,p_vep_attribute2                => p_vep_attribute2
    ,p_vep_attribute3                => p_vep_attribute3
    ,p_vep_attribute4                => p_vep_attribute4
    ,p_vep_attribute5                => p_vep_attribute5
    ,p_vep_attribute6                => p_vep_attribute6
    ,p_vep_attribute7                => p_vep_attribute7
    ,p_vep_attribute8                => p_vep_attribute8
    ,p_vep_attribute9                => p_vep_attribute9
    ,p_vep_attribute10               => p_vep_attribute10
    ,p_vep_attribute11               => p_vep_attribute11
    ,p_vep_attribute12               => p_vep_attribute12
    ,p_vep_attribute13               => p_vep_attribute13
    ,p_vep_attribute14               => p_vep_attribute14
    ,p_vep_attribute15               => p_vep_attribute15
    ,p_vep_attribute16               => p_vep_attribute16
    ,p_vep_attribute17               => p_vep_attribute17
    ,p_vep_attribute18               => p_vep_attribute18
    ,p_vep_attribute19               => p_vep_attribute19
    ,p_vep_attribute20               => p_vep_attribute20
    ,p_vep_attribute21               => p_vep_attribute21
    ,p_vep_attribute22               => p_vep_attribute22
    ,p_vep_attribute23               => p_vep_attribute23
    ,p_vep_attribute24               => p_vep_attribute24
    ,p_vep_attribute25               => p_vep_attribute25
    ,p_vep_attribute26               => p_vep_attribute26
    ,p_vep_attribute27               => p_vep_attribute27
    ,p_vep_attribute28               => p_vep_attribute28
    ,p_vep_attribute29               => p_vep_attribute29
    ,p_vep_attribute30               => p_vep_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_vrbl_rt_elig_prfl
    --
    ben_vrbl_rt_elig_prfl_bk1.create_vrbl_rt_elig_prfl_a
      (
       p_vrbl_rt_elig_prfl_id                       =>  l_vrbl_rt_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                      =>  p_vrbl_rt_prfl_id
      ,p_eligy_prfl_id                         =>  p_eligy_prfl_id
      ,p_mndtry_flag                    => p_mndtry_flag
      ,p_vep_attribute_category         =>  p_vep_attribute_category
      ,p_vep_attribute1                 =>  p_vep_attribute1
      ,p_vep_attribute2                 =>  p_vep_attribute2
      ,p_vep_attribute3                 =>  p_vep_attribute3
      ,p_vep_attribute4                 =>  p_vep_attribute4
      ,p_vep_attribute5                 =>  p_vep_attribute5
      ,p_vep_attribute6                 =>  p_vep_attribute6
      ,p_vep_attribute7                 =>  p_vep_attribute7
      ,p_vep_attribute8                 =>  p_vep_attribute8
      ,p_vep_attribute9                 =>  p_vep_attribute9
      ,p_vep_attribute10                =>  p_vep_attribute10
      ,p_vep_attribute11                =>  p_vep_attribute11
      ,p_vep_attribute12                =>  p_vep_attribute12
      ,p_vep_attribute13                =>  p_vep_attribute13
      ,p_vep_attribute14                =>  p_vep_attribute14
      ,p_vep_attribute15                =>  p_vep_attribute15
      ,p_vep_attribute16                =>  p_vep_attribute16
      ,p_vep_attribute17                =>  p_vep_attribute17
      ,p_vep_attribute18                =>  p_vep_attribute18
      ,p_vep_attribute19                =>  p_vep_attribute19
      ,p_vep_attribute20                =>  p_vep_attribute20
      ,p_vep_attribute21                =>  p_vep_attribute21
      ,p_vep_attribute22                =>  p_vep_attribute22
      ,p_vep_attribute23                =>  p_vep_attribute23
      ,p_vep_attribute24                =>  p_vep_attribute24
      ,p_vep_attribute25                =>  p_vep_attribute25
      ,p_vep_attribute26                =>  p_vep_attribute26
      ,p_vep_attribute27                =>  p_vep_attribute27
      ,p_vep_attribute28                =>  p_vep_attribute28
      ,p_vep_attribute29                =>  p_vep_attribute29
      ,p_vep_attribute30                =>  p_vep_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_vrbl_rt_elig_prfl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_vrbl_rt_elig_prfl
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
   hr_utility.set_location(l_proc, 60);
   ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_ELIG_PRFL_FLAG',
     p_reference_table             => 'BEN_VRBL_RT_ELIG_PRFL_F',
     p_reference_table_column      => 'VRBL_RT_PRFL_ID');

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_vrbl_rt_elig_prfl_id := l_vrbl_rt_elig_prfl_id;
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
    ROLLBACK TO create_vrbl_rt_elig_prfl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_vrbl_rt_elig_prfl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_vrbl_rt_elig_prfl;

    -- NOCOPY, Reset out parameters
    p_vrbl_rt_elig_prfl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    raise;
    --
end create_vrbl_rt_elig_prfl;
-- ----------------------------------------------------------------------------
-- |------------------------< update_vrbl_rt_elig_prfl >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_vrbl_rt_elig_prfl
  (p_validate                       in  boolean   default false
  ,p_vrbl_rt_elig_prfl_id                       in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                      in  number    default hr_api.g_number
  ,p_eligy_prfl_id                         in  number    default hr_api.g_number
  ,p_mndtry_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_vep_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_vrbl_rt_elig_prfl';
  l_object_version_number ben_vrbl_rt_elig_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_vrbl_rt_elig_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_vrbl_rt_elig_prfl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_vrbl_rt_elig_prfl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_vrbl_rt_elig_prfl
    --
    ben_vrbl_rt_elig_prfl_bk2.update_vrbl_rt_elig_prfl_b
      (
       p_vrbl_rt_elig_prfl_id                       =>  p_vrbl_rt_elig_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                      =>  p_vrbl_rt_prfl_id
      ,p_eligy_prfl_id                         =>  p_eligy_prfl_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_vep_attribute_category         =>  p_vep_attribute_category
      ,p_vep_attribute1                 =>  p_vep_attribute1
      ,p_vep_attribute2                 =>  p_vep_attribute2
      ,p_vep_attribute3                 =>  p_vep_attribute3
      ,p_vep_attribute4                 =>  p_vep_attribute4
      ,p_vep_attribute5                 =>  p_vep_attribute5
      ,p_vep_attribute6                 =>  p_vep_attribute6
      ,p_vep_attribute7                 =>  p_vep_attribute7
      ,p_vep_attribute8                 =>  p_vep_attribute8
      ,p_vep_attribute9                 =>  p_vep_attribute9
      ,p_vep_attribute10                =>  p_vep_attribute10
      ,p_vep_attribute11                =>  p_vep_attribute11
      ,p_vep_attribute12                =>  p_vep_attribute12
      ,p_vep_attribute13                =>  p_vep_attribute13
      ,p_vep_attribute14                =>  p_vep_attribute14
      ,p_vep_attribute15                =>  p_vep_attribute15
      ,p_vep_attribute16                =>  p_vep_attribute16
      ,p_vep_attribute17                =>  p_vep_attribute17
      ,p_vep_attribute18                =>  p_vep_attribute18
      ,p_vep_attribute19                =>  p_vep_attribute19
      ,p_vep_attribute20                =>  p_vep_attribute20
      ,p_vep_attribute21                =>  p_vep_attribute21
      ,p_vep_attribute22                =>  p_vep_attribute22
      ,p_vep_attribute23                =>  p_vep_attribute23
      ,p_vep_attribute24                =>  p_vep_attribute24
      ,p_vep_attribute25                =>  p_vep_attribute25
      ,p_vep_attribute26                =>  p_vep_attribute26
      ,p_vep_attribute27                =>  p_vep_attribute27
      ,p_vep_attribute28                =>  p_vep_attribute28
      ,p_vep_attribute29                =>  p_vep_attribute29
      ,p_vep_attribute30                =>  p_vep_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_vrbl_rt_elig_prfl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_vrbl_rt_elig_prfl
    --
  end;
  --
  ben_vep_upd.upd
    (
     p_vrbl_rt_elig_prfl_id                      => p_vrbl_rt_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_vrbl_rt_prfl_id                     => p_vrbl_rt_prfl_id
    ,p_eligy_prfl_id                        => p_eligy_prfl_id
    ,p_mndtry_flag                    => p_mndtry_flag
    ,p_vep_attribute_category        => p_vep_attribute_category
    ,p_vep_attribute1                => p_vep_attribute1
    ,p_vep_attribute2                => p_vep_attribute2
    ,p_vep_attribute3                => p_vep_attribute3
    ,p_vep_attribute4                => p_vep_attribute4
    ,p_vep_attribute5                => p_vep_attribute5
    ,p_vep_attribute6                => p_vep_attribute6
    ,p_vep_attribute7                => p_vep_attribute7
    ,p_vep_attribute8                => p_vep_attribute8
    ,p_vep_attribute9                => p_vep_attribute9
    ,p_vep_attribute10               => p_vep_attribute10
    ,p_vep_attribute11               => p_vep_attribute11
    ,p_vep_attribute12               => p_vep_attribute12
    ,p_vep_attribute13               => p_vep_attribute13
    ,p_vep_attribute14               => p_vep_attribute14
    ,p_vep_attribute15               => p_vep_attribute15
    ,p_vep_attribute16               => p_vep_attribute16
    ,p_vep_attribute17               => p_vep_attribute17
    ,p_vep_attribute18               => p_vep_attribute18
    ,p_vep_attribute19               => p_vep_attribute19
    ,p_vep_attribute20               => p_vep_attribute20
    ,p_vep_attribute21               => p_vep_attribute21
    ,p_vep_attribute22               => p_vep_attribute22
    ,p_vep_attribute23               => p_vep_attribute23
    ,p_vep_attribute24               => p_vep_attribute24
    ,p_vep_attribute25               => p_vep_attribute25
    ,p_vep_attribute26               => p_vep_attribute26
    ,p_vep_attribute27               => p_vep_attribute27
    ,p_vep_attribute28               => p_vep_attribute28
    ,p_vep_attribute29               => p_vep_attribute29
    ,p_vep_attribute30               => p_vep_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_vrbl_rt_elig_prfl
    --
    ben_vrbl_rt_elig_prfl_bk2.update_vrbl_rt_elig_prfl_a
      (
       p_vrbl_rt_elig_prfl_id                       =>  p_vrbl_rt_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                      =>  p_vrbl_rt_prfl_id
      ,p_eligy_prfl_id                         =>  p_eligy_prfl_id
      ,p_mndtry_flag                    => p_mndtry_flag
      ,p_vep_attribute_category         =>  p_vep_attribute_category
      ,p_vep_attribute1                 =>  p_vep_attribute1
      ,p_vep_attribute2                 =>  p_vep_attribute2
      ,p_vep_attribute3                 =>  p_vep_attribute3
      ,p_vep_attribute4                 =>  p_vep_attribute4
      ,p_vep_attribute5                 =>  p_vep_attribute5
      ,p_vep_attribute6                 =>  p_vep_attribute6
      ,p_vep_attribute7                 =>  p_vep_attribute7
      ,p_vep_attribute8                 =>  p_vep_attribute8
      ,p_vep_attribute9                 =>  p_vep_attribute9
      ,p_vep_attribute10                =>  p_vep_attribute10
      ,p_vep_attribute11                =>  p_vep_attribute11
      ,p_vep_attribute12                =>  p_vep_attribute12
      ,p_vep_attribute13                =>  p_vep_attribute13
      ,p_vep_attribute14                =>  p_vep_attribute14
      ,p_vep_attribute15                =>  p_vep_attribute15
      ,p_vep_attribute16                =>  p_vep_attribute16
      ,p_vep_attribute17                =>  p_vep_attribute17
      ,p_vep_attribute18                =>  p_vep_attribute18
      ,p_vep_attribute19                =>  p_vep_attribute19
      ,p_vep_attribute20                =>  p_vep_attribute20
      ,p_vep_attribute21                =>  p_vep_attribute21
      ,p_vep_attribute22                =>  p_vep_attribute22
      ,p_vep_attribute23                =>  p_vep_attribute23
      ,p_vep_attribute24                =>  p_vep_attribute24
      ,p_vep_attribute25                =>  p_vep_attribute25
      ,p_vep_attribute26                =>  p_vep_attribute26
      ,p_vep_attribute27                =>  p_vep_attribute27
      ,p_vep_attribute28                =>  p_vep_attribute28
      ,p_vep_attribute29                =>  p_vep_attribute29
      ,p_vep_attribute30                =>  p_vep_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_vrbl_rt_elig_prfl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_vrbl_rt_elig_prfl
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
    ROLLBACK TO update_vrbl_rt_elig_prfl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date   := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_vrbl_rt_elig_prfl;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end update_vrbl_rt_elig_prfl;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_vrbl_rt_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vrbl_rt_elig_prfl
  (p_validate                       in  boolean  default false
  ,p_vrbl_rt_elig_prfl_id           in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_vrbl_rt_elig_prfl';
  l_object_version_number ben_vrbl_rt_elig_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_vrbl_rt_elig_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_vrbl_rt_elig_prfl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_vrbl_rt_elig_prfl;
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
    -- Start of API User Hook for the before hook of delete_vrbl_rt_elig_prfl
    --
    ben_vrbl_rt_elig_prfl_bk3.delete_vrbl_rt_elig_prfl_b
      (
       p_vrbl_rt_elig_prfl_id                       =>  p_vrbl_rt_elig_prfl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_vrbl_rt_elig_prfl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_vrbl_rt_elig_prfl
    --
  end;
  --
  ben_vep_del.del
    (
     p_vrbl_rt_elig_prfl_id                      => p_vrbl_rt_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_vrbl_rt_elig_prfl
    --
    ben_vrbl_rt_elig_prfl_bk3.delete_vrbl_rt_elig_prfl_a
      (
       p_vrbl_rt_elig_prfl_id                       =>  p_vrbl_rt_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_vrbl_rt_elig_prfl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_vrbl_rt_elig_prfl
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_ELIG_PRFL_FLAG',
     p_reference_table             => 'BEN_VRBL_RT_ELIG_PRFL_F',
     p_reference_table_column      => 'VRBL_RT_PRFL_ID');

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
    ROLLBACK TO delete_vrbl_rt_elig_prfl;
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
    ROLLBACK TO delete_vrbl_rt_elig_prfl;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end delete_vrbl_rt_elig_prfl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_vrbl_rt_elig_prfl_id                   in     number
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
  ben_vep_shd.lck
    (
      p_vrbl_rt_elig_prfl_id                 => p_vrbl_rt_elig_prfl_id
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
end ben_vrbl_rt_elig_prfl_api;

/
