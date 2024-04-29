--------------------------------------------------------
--  DDL for Package Body HR_PERSON_TYPE_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_TYPE_USAGE_API" as
/* $Header: peptuapi.pkb 120.0 2005/05/31 15:53:03 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_person_type_usage_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_type_usage >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_type_usage
  (p_validate                       in  boolean    default false
  ,p_person_type_usage_id           in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_person_type_id                 in  number    default hr_api.g_number
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_person_type_usage';
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE;
  l_effective_start_date per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date per_person_type_usages_f.effective_end_date%TYPE;
  l_effective_date   date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    savepoint update_person_type_usage;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  l_effective_date        := trunc(p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_person_type_usage
    --
    hr_person_type_usage_bk1.update_person_type_usage_b
      (
       p_person_type_usage_id           =>  p_person_type_usage_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
    ,p_effective_date                      => l_effective_date
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_person_type_usage'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_person_type_usage
    --
  end;
  --
  -- For first release, datetrack update mode must be 'CORRECTION'
  -- Commented as part of PTU changes
--  if ( p_datetrack_mode <> 'CORRECTION') then
--      hr_utility.set_message(801, 'HR_52363_PTU_INV_DT_UPD_MODE');
--      hr_utility.raise_error;
--  end if;
  --
  --
  per_ptu_upd.upd
    (
     p_person_type_usage_id          => p_person_type_usage_id
    ,p_person_type_id                => p_person_type_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_person_type_usage
    --
    hr_person_type_usage_bk1.update_person_type_usage_a
      (
       p_person_type_usage_id           =>  p_person_type_usage_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_effective_date                     => l_effective_date
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_person_type_usage'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_person_type_usage
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
    ROLLBACK TO update_person_type_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
end update_person_type_usage;
-- ----------------------------------------------------------------------------
-- |------------------------< check_person_type >-----------------------------|
-- ----------------------------------------------------------------------------
function check_person_type
          (
            p_person_id                      in  number
           ,p_effective_date                 in  date
           ,p_person_type                    in  varchar2
          ) return boolean is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'check_per_type_on_specific_day';
  l_result            varchar2(4);
  l_temp_type         per_person_types.system_person_type%type;
  l_temp_id           number;
  --
  cursor check_person_type is
    select system_person_type
    from per_person_types ppt
    where p_person_type = system_person_type;
  --
  cursor check_person_id is
    select person_id
    from per_all_people_f
    where person_id = p_person_id;
  --
  cursor current_person_type is
    select 'Y'
    from per_person_types ppt,
         per_person_type_usages_f ptu
    where ptu.person_id = p_person_id
      and ptu.effective_start_date <= p_effective_date
      and ptu.effective_end_date   >= p_effective_date
      and ptu.person_type_id = ppt.person_type_id
      and ppt.system_person_type = p_person_type;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check that the person type is valid.
  --
  open check_person_type;
  fetch check_person_type into l_temp_type;
  if check_person_type%notfound then
     close check_person_type;
    hr_utility.set_message(801, 'HR_52366_PTU_INV_PERSON_TYPE');
    hr_utility.raise_error;
  end if;
  --
  close check_person_type;
  --
  -- Check that the type passed in isn't an 'EX' type or a combination of
  -- old types
  --
  if ( p_person_type = 'EX_EMP' or
       p_person_type = 'EX_APL' or
       p_person_type = 'EMP_APL' or
       p_person_type = 'EX_EMP_APL' or
       p_person_type = 'APL_EX_APL') then
    hr_utility.set_message(801, 'HR_52366_PTU_INV_PERSON_TYPE');
    hr_utility.raise_error;
  end if;
  --
  --
  -- Check that the person id is valid.
  --
  open check_person_id;
  fetch check_person_id into l_temp_id;
  if check_person_id%notfound then
    close check_person_id;
    hr_utility.set_message(801, 'HR_52365_PTU_NO_PERSON_EXISTS');
    hr_utility.raise_error;
  end if;
  --
  close check_person_id;
  --
  open current_person_type;
  fetch current_person_type into l_result;
  if current_person_type%found then
    close current_person_type;
    hr_utility.set_location('Leaving:'|| l_proc, 10);
    return TRUE;
  end if;
  --
  close current_person_type;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
  return FALSE;
  --
end check_person_type;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_person_ex_type >--------------------------|
-- ----------------------------------------------------------------------------
function check_person_ex_type
          (
            p_person_id                      in  number
           ,p_effective_date                 in  date
           ,p_person_type                    in  varchar2
          ) return boolean is
  --
  -- Declare cursors and local variables
  --
  cursor check_person_type is
    select system_person_type
    from per_person_types ppt
    where p_person_type = system_person_type;
  --
  cursor check_person_id is
    select person_id
    from per_all_people_f
    where person_id = p_person_id;
  --
  cursor check_person_ex_type is
    select 'Y'
    from per_person_types ppt,
         per_person_type_usages_f ptu
    where ptu.person_id = p_person_id
      and ppt.system_person_type = p_person_type
      and ptu.effective_end_date < p_effective_date
      and ptu.person_type_id = ppt.person_type_id
      and not exists (select 'Y' from per_person_types ppt1,
                                      per_person_type_usages_f ptu1
                      where ptu1.person_id = p_person_id
                        and ppt1.system_person_type = p_person_type
                        and ptu1.effective_end_date >= p_effective_date
                        and ptu1.effective_start_date <= p_effective_date
                        and ptu1.person_type_id = ppt1.person_type_id);
  --
  --
  l_proc varchar2(72) := g_package||'check_person_ex_type';
  l_temp_type         per_person_types.system_person_type%type;
  l_temp_id           number;
  l_result            varchar2(4);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check that the person type is valid.
  --
  open check_person_type;
  fetch check_person_type into l_temp_type;
  if check_person_type%notfound then
     close check_person_type;
    hr_utility.set_message(801, 'HR_52366_PTU_INV_PERSON_TYPE');
    hr_utility.raise_error;
  end if;
  --
  -- Check that the type passed in isn't an 'EX' type or a combination of
  -- old types
  --
  if ( p_person_type = 'EX_EMP' or
       p_person_type = 'EX_APL' or
       p_person_type = 'EMP_APL' or
       p_person_type = 'EX_EMP_APL' or
       p_person_type = 'APL_EX_APL') then
    hr_utility.set_message(801, 'HR_52366_PTU_INV_PERSON_TYPE');
    hr_utility.raise_error;
  end if;
  --
  close check_person_type;
  --
  -- Check that the person id is valid.
  --
  open check_person_id;
  fetch check_person_id into l_temp_id;
  if check_person_id%notfound then
    close check_person_id;
    hr_utility.set_message(801, 'HR_52365_PTU_NO_PERSON_EXISTS');
    hr_utility.raise_error;
  end if;
  --
  close check_person_id;
  --
  -- Check that there exist rows of the person type previous to the
  -- effective_date.
  --
  open check_person_ex_type;
  fetch check_person_ex_type into l_result;
  if check_person_ex_type%found then
    close check_person_ex_type;
    hr_utility.set_location('Leaving:'|| l_proc, 10);
    return TRUE;
  end if;

  close check_person_ex_type;
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  return FALSE;
  --
end check_person_ex_type;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_type_usage >----------------------|
-- ----------------------------------------------------------------------------
procedure create_person_type_usage
( p_validate                       in boolean    default false
  ,p_person_id                      in  number
  ,p_person_type_id                 in  number
  ,p_effective_date                 in  date
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_person_type_usage_id           out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
 ) is
  l_proc             varchar2(80) :=  g_package||'create_person_type_usage';
  l_person_type      per_person_types.system_person_type%TYPE;
  l_person_type_usage_id per_person_type_usages_f.person_type_usage_id%TYPE;
  l_effective_start_date per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date per_person_type_usages_f.effective_end_date%TYPE;
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE;
  --
  -- Setup cursor for valid person type check
  --
  cursor csr_valid_person_type
    is
    select system_person_type
    from per_person_types
    where person_type_id = p_person_type_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    savepoint create_person_type_usage;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  -----------------------------------
  -- Check person type id is valid --
  -----------------------------------
  open csr_valid_person_type;
  fetch csr_valid_person_type into l_person_type;
  if csr_valid_person_type%notfound then
    close csr_valid_person_type;
    fnd_message.set_name('PER', 'HR_52362_PTU_INV_PER_TYPE_ID');
    fnd_message.raise_error;
  end if;
  close csr_valid_person_type;

  hr_utility.set_location('At: '||l_proc,15);

  --
  -- Must not exist in hr_standard_lookups where lookup_type is
  -- HR_SYS_PTU
  --
  if not hr_api.not_exists_in_hrstanlookups
  (p_effective_date               => p_effective_date
  ,p_lookup_type                  => 'HR_SYS_PTU'
  ,p_lookup_code                  => l_person_type
  ) then
    fnd_message.set_name('PER', 'HR_52362_PTU_INV_PER_TYPE_ID');
    fnd_message.raise_error;
  end if;

  hr_utility.set_location('At: '||l_proc,20);

  begin
    --
    -- Start of API User Hook for the before hook of create_person_type_usage
    --
       hr_person_type_usage_bk2.create_person_type_usage_b
          (p_person_id                      =>  p_person_id
          ,p_person_type_id                 =>  p_person_type_id
          ,p_effective_date                 =>  p_effective_date
          ,p_attribute_category             =>  p_attribute_category
          ,p_attribute1                     =>  p_attribute1
          ,p_attribute2                     =>  p_attribute2
          ,p_attribute3                     =>  p_attribute3
          ,p_attribute4                     =>  p_attribute4
          ,p_attribute5                     =>  p_attribute5
          ,p_attribute6                     =>  p_attribute6
          ,p_attribute7                     =>  p_attribute7
          ,p_attribute8                     =>  p_attribute8
          ,p_attribute9                     =>  p_attribute9
          ,p_attribute10                    =>  p_attribute10
          ,p_attribute11                    =>  p_attribute11
          ,p_attribute12                    =>  p_attribute12
          ,p_attribute13                    =>  p_attribute13
          ,p_attribute14                    =>  p_attribute14
          ,p_attribute15                    =>  p_attribute15
          ,p_attribute16                    =>  p_attribute16
          ,p_attribute17                    =>  p_attribute17
          ,p_attribute18                    =>  p_attribute18
          ,p_attribute19                    =>  p_attribute19
          ,p_attribute20                    =>  p_attribute20
          ,p_attribute21                    =>  p_attribute21
          ,p_attribute22                    =>  p_attribute22
          ,p_attribute23                    =>  p_attribute23
          ,p_attribute24                    =>  p_attribute24
          ,p_attribute25                    =>  p_attribute25
          ,p_attribute26                    =>  p_attribute26
          ,p_attribute27                    =>  p_attribute27
          ,p_attribute28                    =>  p_attribute28
          ,p_attribute29                    =>  p_attribute29
          ,p_attribute30                    =>  p_attribute30
         );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_person_type_usage'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_person_type_usage
    --
  end;

  hr_per_type_usage_internal.create_person_type_usage
    (p_validate                       =>  FALSE
    ,p_person_id                      =>  p_person_id
    ,p_person_type_id                 =>  p_person_type_id
    ,p_effective_date                 =>  p_effective_date
    ,p_attribute_category             =>  p_attribute_category
    ,p_attribute1                     =>  p_attribute1
    ,p_attribute2                     =>  p_attribute2
    ,p_attribute3                     =>  p_attribute3
    ,p_attribute4                     =>  p_attribute4
    ,p_attribute5                     =>  p_attribute5
    ,p_attribute6                     =>  p_attribute6
    ,p_attribute7                     =>  p_attribute7
    ,p_attribute8                     =>  p_attribute8
    ,p_attribute9                     =>  p_attribute9
    ,p_attribute10                    =>  p_attribute10
    ,p_attribute11                    =>  p_attribute11
    ,p_attribute12                    =>  p_attribute12
    ,p_attribute13                    =>  p_attribute13
    ,p_attribute14                    =>  p_attribute14
    ,p_attribute15                    =>  p_attribute15
    ,p_attribute16                    =>  p_attribute16
    ,p_attribute17                    =>  p_attribute17
    ,p_attribute18                    =>  p_attribute18
    ,p_attribute19                    =>  p_attribute19
    ,p_attribute20                    =>  p_attribute20
    ,p_attribute21                    =>  p_attribute21
    ,p_attribute22                    =>  p_attribute22
    ,p_attribute23                    =>  p_attribute23
    ,p_attribute24                    =>  p_attribute24
    ,p_attribute25                    =>  p_attribute25
    ,p_attribute26                    =>  p_attribute26
    ,p_attribute27                    =>  p_attribute27
    ,p_attribute28                    =>  p_attribute28
    ,p_attribute29                    =>  p_attribute29
    ,p_attribute30                    =>  p_attribute30
    ,p_person_type_usage_id           =>  l_person_type_usage_id
    ,p_object_version_number          =>  l_object_version_number
    ,p_effective_start_date           =>  l_effective_start_date
    ,p_effective_end_date             =>  l_effective_end_date);

  --
  --
  hr_utility.set_location(l_proc, 60);
  begin
    --
    -- Start of API User Hook for the after hook of create_person_type_usage
    --
    -- Out paramters are being passed as they are being set to the correct value in
    -- create_person_type_usage_internal.

       hr_person_type_usage_bk2.create_person_type_usage_a
          (p_person_id                      =>  p_person_id
          ,p_person_type_id                 =>  p_person_type_id
          ,p_effective_date                 =>  p_effective_date
          ,p_attribute_category             =>  p_attribute_category
          ,p_attribute1                     =>  p_attribute1
          ,p_attribute2                     =>  p_attribute2
          ,p_attribute3                     =>  p_attribute3
          ,p_attribute4                     =>  p_attribute4
          ,p_attribute5                     =>  p_attribute5
          ,p_attribute6                     =>  p_attribute6
          ,p_attribute7                     =>  p_attribute7
          ,p_attribute8                     =>  p_attribute8
          ,p_attribute9                     =>  p_attribute9
          ,p_attribute10                    =>  p_attribute10
          ,p_attribute11                    =>  p_attribute11
          ,p_attribute12                    =>  p_attribute12
          ,p_attribute13                    =>  p_attribute13
          ,p_attribute14                    =>  p_attribute14
          ,p_attribute15                    =>  p_attribute15
          ,p_attribute16                    =>  p_attribute16
          ,p_attribute17                    =>  p_attribute17
          ,p_attribute18                    =>  p_attribute18
          ,p_attribute19                    =>  p_attribute19
          ,p_attribute20                    =>  p_attribute20
          ,p_attribute21                    =>  p_attribute21
          ,p_attribute22                    =>  p_attribute22
          ,p_attribute23                    =>  p_attribute23
          ,p_attribute24                    =>  p_attribute24
          ,p_attribute25                    =>  p_attribute25
          ,p_attribute26                    =>  p_attribute26
          ,p_attribute27                    =>  p_attribute27
          ,p_attribute28                    =>  p_attribute28
          ,p_attribute29                    =>  p_attribute29
          ,p_attribute30                    =>  p_attribute30
          ,p_person_type_usage_id           =>  l_person_type_usage_id
          ,p_object_version_number          =>  l_object_version_number
          ,p_effective_start_date           =>  l_effective_start_date
          ,p_effective_end_date             =>  l_effective_end_date
         );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_person_type_usage'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_person_type_usage
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
  p_person_type_usage_id := l_person_type_usage_id;
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
    ROLLBACK TO create_person_type_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    p_person_type_usage_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
end create_person_type_usage;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_person_type_usage >----------------------|
-- ----------------------------------------------------------------------------
procedure delete_person_type_usage
  ( p_validate                       in boolean        default false
  ,p_person_type_usage_id           in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ) is

  l_proc             varchar2(80) :=  g_package||'delete_person_type_usage';
  l_system_person_type      per_person_types.system_person_type%TYPE;
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE;
  l_effective_start_date per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date per_person_type_usages_f.effective_end_date%TYPE;

  cursor csr_ptu
  is
  select ppt.system_person_type
  from per_person_type_usages_f ptu , per_person_types ppt
  where ptu.person_type_usage_id = p_person_type_usage_id
  and ptu.person_type_id = ppt.person_type_id
  and ( p_effective_date between
      ptu.effective_start_date and ptu.effective_end_date);

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    savepoint delete_person_type_usage;
  end if;
  --
  hr_utility.set_location('At:'||l_proc, 20);
  --
  -- Process Logic
  --
  --

  l_object_version_number := p_object_version_number;

  OPEN csr_ptu;
  FETCH csr_ptu INTO l_system_person_type;
  IF csr_ptu%NOTFOUND THEN
    --
    -- The primary key is invalid therefore we must error
    --
    CLOSE csr_ptu;
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_ptu;

  --
  -- Must not exist in hr_standard_lookups where lookup_type is
  -- HR_SYS_PTU
  --
--  PTU Changes
--
--  if not hr_api.not_exists_in_hrstanlookups
--    (p_effective_date               => p_effective_date
--    ,p_lookup_type                  => 'HR_SYS_PTU'
--    ,p_lookup_code                  => l_system_person_type
--    ) then
--    fnd_message.set_name('PER', 'HR_52658_PTU_INVALID_DELETE');
--    fnd_message.raise_error;
--  end if;
--
--  End of PTU Changes
  --
  --
  hr_utility.set_location('At: '||l_proc,40);
  begin
    --
    -- Start of API User Hook for the before hook of delete_person_type_usage
    --
       hr_person_type_usage_bk3.delete_person_type_usage_b
         (p_person_type_usage_id           => p_person_type_usage_id
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode
         ,p_object_version_number          => l_object_version_number
         );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_person_type_usage'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_person_type_usage
    --
  end;

  hr_utility.set_location('At: '||l_proc,30);

  hr_per_type_usage_internal.delete_person_type_usage
   (p_validate                        => FALSE
    ,p_person_type_usage_id           => p_person_type_usage_id
    ,p_effective_date                 => p_effective_date
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_object_version_number          => l_object_version_number
    ,p_effective_start_date           => l_effective_start_date
    ,p_effective_end_date             => l_effective_end_date
    );

  --
  --
  hr_utility.set_location(l_proc, 60);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_person_type_usage
    --
    -- Out paramters are being passed as they are being set to the correct value in
    -- delete_person_type_usage_internal.

       hr_person_type_usage_bk3.delete_person_type_usage_a
         (p_person_type_usage_id           => p_person_type_usage_id
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode
         ,p_object_version_number          => l_object_version_number
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_person_type_usage'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_person_type_usage
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date   := l_effective_end_date;
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
    ROLLBACK TO delete_person_type_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
end delete_person_type_usage;
end hr_person_type_usage_api;

/
