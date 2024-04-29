--------------------------------------------------------
--  DDL for Package Body HR_PER_TYPE_USAGE_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PER_TYPE_USAGE_INTERNAL" as
/* $Header: peptubsi.pkb 120.3.12010000.2 2009/02/26 13:30:35 skura ship $ */
--
-- Package Variables
--
g_package varchar2(33) := '  per_person_type_usage_internal.';
g_debug boolean := hr_utility.debug_enabled;
g_old_ben_ptu_ler_rec ben_ptu_ler.g_ptu_ler_rec;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_type_usage >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_type_usage
(  p_validate                       in  boolean    default false
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
  --
  -- Declare cursors and local variables
  --
  l_person_type_usage_id per_person_type_usages_f.person_type_usage_id%TYPE;
  l_effective_start_date per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date per_person_type_usages_f.effective_end_date%TYPE;
  l_proc varchar2(72);
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE;
  --
  -- BEGIN TCA_UNMERGE CHANGES
  cursor c_person is
    select *
    from   per_all_people_f
    where  person_id = p_person_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_person per_all_people_f%rowtype;
  --
  -- TCA_UNMERGE
begin
  --
 if g_debug then
 l_proc := g_package||'create_person_type_usage';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    savepoint create_person_type_usage;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Process Logic
  --
  per_ptu_ins.ins
    (
     p_person_type_usage_id          => l_person_type_usage_id
    ,p_person_id                     => p_person_id
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
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  --
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  ------------------------------------------------
  -- BEGIN TCA_UNMERGE CHANGES
  --
  -- Bug fix 3725055.If condition removed.
  --if hr_general.g_data_migrator_mode <> 'P' then
    open c_person;
    fetch c_person into l_person;
    close c_person;

    per_hrtca_merge.create_tca_person(p_rec => l_person);
  --end if;
  --
  -- END TCA_UNMERGE CHANGES
  ------------------------------------------------
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
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 70);
 end if;
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
    --
    p_person_type_usage_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 80);
 end if;
    --
end create_person_type_usage;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_person_type_usage >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_type_usage
(  p_validate                       in boolean        default false
  ,p_person_type_usage_id           in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE;
  l_effective_start_date per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date per_person_type_usages_f.effective_end_date%TYPE;
  --
begin
  --
 if g_debug then
  l_proc := g_package||'delete_person_type_usage';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    savepoint delete_person_type_usage;
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  per_ptu_del.del
    (
     p_person_type_usage_id          => p_person_type_usage_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
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
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
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
    --
end delete_person_type_usage;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_type_usage >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_type_usage
(
   p_validate                       in     boolean    default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_person_type_usage_id           in     number
  ,p_object_version_number          in out nocopy number
  ,p_person_type_id                 in     number    default hr_api.g_number
  ,p_attribute_category             in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date           out nocopy    date
  ,p_effective_end_date             out nocopy    date
 ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_start_date per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date per_person_type_usages_f.effective_end_date%TYPE;
  l_proc varchar2(72);
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE := p_object_version_number;
  --
begin
  --
  if g_debug then
    l_proc := g_package||'update_person_type_usage';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    savepoint update_person_type_usage;
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Process Logic
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
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
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
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := p_object_version_number;
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
end update_person_type_usage;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_ben_ptu_ler_rec >--------------------------|
-- ----------------------------------------------------------------------------
function get_ben_ptu_ler_rec
(  p_effective_date                 in     date
  ,p_person_type_usage_id           in     number
  )
return ben_ptu_ler.g_ptu_ler_rec is
  --
  -- Declare cursors and local variables
  --
  cursor csr_person_type_usages
  (  p_effective_date                 in     date
    ,p_person_type_usage_id           in     number
    ) is
    select *
      from per_person_type_usages_f ptu
     where p_effective_date between ptu.effective_start_date and ptu.effective_end_date
       and ptu.person_type_usage_id = p_person_type_usage_id;
  l_person_type_usage csr_person_type_usages%rowtype;
  --
  l_ben_ptu_ler_rec ben_ptu_ler.g_ptu_ler_rec;
  --
begin
  --
  open csr_person_type_usages
    (p_effective_date                 => p_effective_date
    ,p_person_type_usage_id           => p_person_type_usage_id
    );
  fetch csr_person_type_usages into l_person_type_usage;
  close csr_person_type_usages;
  l_ben_ptu_ler_rec.person_id := l_person_type_usage.person_id;
  l_ben_ptu_ler_rec.person_type_usage_id := l_person_type_usage.person_type_usage_id;
  l_ben_ptu_ler_rec.person_type_id := l_person_type_usage.person_type_id;
  l_ben_ptu_ler_rec.effective_start_date := l_person_type_usage.effective_start_date;
  l_ben_ptu_ler_rec.effective_end_date :=  l_person_type_usage.effective_end_date;
  --
  return l_ben_ptu_ler_rec;
  --
end get_ben_ptu_ler_rec;
--
-- ----------------------------------------------------------------------------
-- |---------------------< benefits_person_type_usage_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure benefits_person_type_usage_b
(  p_effective_date                 in     date
  ,p_person_type_usage_id           in     number
  ) is
  --
begin
  --
  g_old_ben_ptu_ler_rec := get_ben_ptu_ler_rec
    (p_effective_date                 => p_effective_date
    ,p_person_type_usage_id           => p_person_type_usage_id
    );
  --
end benefits_person_type_usage_b;
--
-- ----------------------------------------------------------------------------
-- |---------------------< benefits_person_type_usage_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure benefits_person_type_usage_a
(  p_effective_date                 in     date
  ,p_person_type_usage_id           in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_old_ben_ptu_ler_rec ben_ptu_ler.g_ptu_ler_rec;
  l_new_ben_ptu_ler_rec ben_ptu_ler.g_ptu_ler_rec;
  --
begin
  --
  l_old_ben_ptu_ler_rec := g_old_ben_ptu_ler_rec;
  l_new_ben_ptu_ler_rec := get_ben_ptu_ler_rec
    (p_effective_date                 => p_effective_date
    ,p_person_type_usage_id           => p_person_type_usage_id
    );
  --
  ben_ptu_ler.ler_chk
    (p_old                            => l_old_ben_ptu_ler_rec
    ,p_new                            => l_new_ben_ptu_ler_rec
    ,p_effective_date                 => p_effective_date
    );
  --
end benefits_person_type_usage_a;
--
-- ----------------------------------------------------------------------------
-- |----------------------< maintain_person_type_usage >----------------------|
-- ----------------------------------------------------------------------------
--
procedure maintain_person_type_usage
(
   p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_person_type_id                 in     number
  ,p_datetrack_update_mode          in     varchar2 default hr_api.g_update
  ,p_datetrack_delete_mode          in     varchar2 default null
 ) is
  --
  -- Declare cursors and local variables
  --
  TYPE spt_list IS TABLE OF per_person_types.system_person_type%type
   INDEX BY binary_integer;
  system_type spt_list;
  --
  -- Returns person type usages records for the specified person and person type
  -- effective on the specified date.
  --
  cursor csr_delete_person_type_usages
  (
     p_effective_date                 in     date
    ,p_person_id                      in     number
    ,p_person_type_id                 in     number
   ) is
    select ptu.person_type_usage_id
          ,ptu.object_version_number
      from per_person_type_usages_f ptu
     where p_effective_date between ptu.effective_start_date and ptu.effective_end_date
       and ptu.person_id = p_person_id
       and ptu.person_type_id = p_person_type_id;
  l_delete_person_type_usage csr_delete_person_type_usages%rowtype;
  --
  -- Returns person types records for the specified person type
  --
  cursor csr_person_types
  (
     p_person_type_id                 in     number
   ) is
    select ppt.person_type_id
          ,ppt.system_person_type
      from per_person_types ppt
     where ppt.person_type_id = p_person_type_id;
  l_person_type csr_person_types%rowtype;
  --
  -- Returns person type usages records for the specified person and system
  -- person type effective on the specified date. EMP and EX_EMP; and APL and
  -- EX_APL are considered to be the same type, and are stored in the same
  -- datetracked record.
  --
  cursor csr_update_person_type_usages
  (
     p_effective_date                 in     date
    ,p_person_id                      in     number
    ,p_system_person_type             in     varchar2
   ) is
    select ptu.person_type_usage_id
          ,ptu.object_version_number
      from per_person_type_usages_f ptu
     where p_effective_date between ptu.effective_start_date and ptu.effective_end_date
       and ptu.person_id = p_person_id
       and ptu.person_type_id in
             (select ppt.person_type_id
                from per_person_types ppt
               where (  (   p_system_person_type in ('EMP','EX_EMP')
                        and ppt.system_person_type in ('EMP','EX_EMP') )
                     or (   p_system_person_type in ('APL','EX_APL')
                        and ppt.system_person_type in ('APL','EX_APL') )
                     or (   p_system_person_type in ('CWK','EX_CWK')
                        and ppt.system_person_type in ('CWK','EX_CWK') )
                     or (   p_system_person_type = 'OTHER'
                        and ppt.system_person_type = 'OTHER' )));

  l_update_person_type_usage csr_update_person_type_usages%rowtype;
  l_update_person_type_usage1 csr_update_person_type_usages%rowtype;
  --
  l_effective_start_date per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date per_person_type_usages_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'maintain_person_type_usage';
  l_person_type_usage_id per_person_type_usages_f.person_type_usage_id%TYPE;
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE;
  l_no_other varchar2(1) := 'Y';
  --
  -- BEGIN TCA_UNMERGE CHANGES
  cursor c_person is
    select *
    from   per_all_people_f
    where  person_id = p_person_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_person per_all_people_f%rowtype;
  --
  -- TCA_UNMERGE
begin
  --
  system_type(1):='EMP';
  system_type(2):='APL';
  system_type(3):='CWK';
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.set_location('p_effective_date = '||to_char(p_effective_date,'DD-MON-YYYY'),11);
    hr_utility.set_location('p_person_id = '||p_person_id,12);
    hr_utility.set_location('p_person_type_id = '||p_person_type_id,13);
    hr_utility.set_location('p_datetrack_update_mode = '||p_datetrack_update_mode,14);
    hr_utility.set_location('p_datetrack_delete_mode = '||p_datetrack_delete_mode,15);
  end if;
  --
  -- For deletes
  --
  if (p_datetrack_delete_mode is not null) then
    --
    if g_debug then
      hr_utility.set_location(l_proc, 10);
    end if;
    --
    -- Find matching person type usage record, and delete
    --
    open csr_delete_person_type_usages
      (p_effective_date                 => p_effective_date
      ,p_person_id                      => p_person_id
      ,p_person_type_id                 => p_person_type_id
      );
    fetch csr_delete_person_type_usages into l_delete_person_type_usage;
    if (csr_delete_person_type_usages%notfound) then
      --
      if g_debug then
        hr_utility.set_location(l_proc, 20);
      end if;
      --
      close csr_delete_person_type_usages;
      fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE',l_proc);
      fnd_message.set_token('STEP',10);
      fnd_message.raise_error;
    else
      --
      if g_debug then
        hr_utility.set_location(l_proc, 30);
      end if;
      --
      close csr_delete_person_type_usages;
      --
      benefits_person_type_usage_b
        (p_effective_date                 => p_effective_date
        ,p_person_type_usage_id           => l_delete_person_type_usage.person_type_usage_id
        );
      --
      delete_person_type_usage
        (p_person_type_usage_id           => l_delete_person_type_usage.person_type_usage_id
        ,p_effective_date                 => p_effective_date
        ,p_datetrack_mode                 => p_datetrack_delete_mode
        ,p_object_version_number          => l_delete_person_type_usage.object_version_number
        ,p_effective_start_date           => l_effective_start_date
        ,p_effective_end_date             => l_effective_end_date
        );
      --
      benefits_person_type_usage_a
        (p_effective_date                 => p_effective_date
        ,p_person_type_usage_id           => l_delete_person_type_usage.person_type_usage_id
        );
      --
    end if;
  --
  -- For updates
  --
  elsif (p_datetrack_update_mode is not null) then
    --
    if g_debug then
      hr_utility.set_location(l_proc, 40);
    end if;
    --
    -- Determine system person type of person type parameter
    --
    open csr_person_types
      (p_person_type_id                 => p_person_type_id
      );
    fetch csr_person_types into l_person_type;
    if (csr_person_types%notfound) then
      --
      if g_debug then
        hr_utility.set_location(l_proc, 50);
      end if;
      --
      close csr_person_types;
      fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE',l_proc);
      fnd_message.set_token('STEP',20);
      fnd_message.raise_error;
    else
      --
      if g_debug then
        hr_utility.set_location(l_proc, 60);
      end if;
      --
      close csr_person_types;
      --
      -- Find existing record corresponding to system person type
      --
      open csr_update_person_type_usages
        (p_effective_date                 => p_effective_date
        ,p_person_id                      => p_person_id
        ,p_system_person_type             => l_person_type.system_person_type
        );
      fetch csr_update_person_type_usages into l_update_person_type_usage;
      if (csr_update_person_type_usages%found) then

        -- Added close
        close csr_update_person_type_usages;
        --
        if g_debug then
          hr_utility.set_location(l_proc, 70);
        end if;
        --
        -- There is an existing record, so update with new person type
        --
        benefits_person_type_usage_b
          (p_effective_date                 => p_effective_date
          ,p_person_type_usage_id           => l_update_person_type_usage.person_type_usage_id
          );
        --
        update_person_type_usage
          (p_effective_date                 => p_effective_date
          ,p_datetrack_mode                 => p_datetrack_update_mode
          ,p_person_type_usage_id           => l_update_person_type_usage.person_type_usage_id
          ,p_object_version_number          => l_update_person_type_usage.object_version_number
          ,p_person_type_id                 => p_person_type_id
          ,p_effective_start_date           => l_effective_start_date
          ,p_effective_end_date             => l_effective_end_date
          );
        --
        benefits_person_type_usage_a
          (p_effective_date                 => p_effective_date
          ,p_person_type_usage_id           => l_update_person_type_usage.person_type_usage_id
          );
        --
      else
        --
        if g_debug then
          hr_utility.set_location(l_proc, 80);
        end if;
        -- Added close;
        close csr_update_person_type_usages;
        --
        -- There is not an existing record, so create a new one
        --
        --
        if g_debug then
          hr_utility.set_location(l_proc, 81);
        end if;

        -- But before creating a new PTU record do the following
        -- If SPT is EMP,APL,CWK, then delete any existing OTHER PTU record
        -- If OTHER then only create if they are not already an EMP or APL or CWK

        IF l_person_type.system_person_type in ( 'EMP','APL','CWK' ) THEN

          if g_debug then
            hr_utility.set_location(l_proc, 82);
          end if;
          --
          -- Find existing record corresponding to system person type
          --
          open csr_update_person_type_usages
            (p_effective_date                 => p_effective_date
            ,p_person_id                      => p_person_id
            ,p_system_person_type             => 'OTHER'
            );
          fetch csr_update_person_type_usages into l_update_person_type_usage1;
          if (csr_update_person_type_usages%found) then

            -- Added close
            close csr_update_person_type_usages;
            --
            if g_debug then
              hr_utility.set_location(l_proc, 83);
            end if;
            --
            benefits_person_type_usage_b
              (p_effective_date                 => p_effective_date - 1
              ,p_person_type_usage_id           => l_update_person_type_usage1.person_type_usage_id
              );
            --

            if g_debug then
              hr_utility.set_location(l_proc, 84);
            end if;

            delete_person_type_usage
              (p_person_type_usage_id           => l_update_person_type_usage1.person_type_usage_id
              ,p_effective_date                 => p_effective_date - 1
              ,p_datetrack_mode                 => 'DELETE'
              ,p_object_version_number          => l_update_person_type_usage1.object_version_number
              ,p_effective_start_date           => l_effective_start_date
              ,p_effective_end_date             => l_effective_end_date
              );
            --
            benefits_person_type_usage_a
              (p_effective_date                 => p_effective_date - 1
              ,p_person_type_usage_id           => l_update_person_type_usage1.person_type_usage_id
              );
            --
            if g_debug then
              hr_utility.set_location(l_proc, 85);
            end if;

          end if;
        ELSIF l_person_type.system_person_type = 'OTHER' THEN
          --
          if g_debug then
            hr_utility.set_location(l_proc, 86);
          end if;
          --
          /*
          ** New code since CWK
          */
          for i in system_type.first..system_type.last loop
            --
	    -- Find existing record corresponding to system person type
	    --
	    open csr_update_person_type_usages
	      (p_effective_date                 => p_effective_date
	      ,p_person_id                      => p_person_id
	      ,p_system_person_type             => system_type(i)
	      );
	    fetch csr_update_person_type_usages into l_update_person_type_usage1;
	    if (csr_update_person_type_usages%found) then
	      l_no_other := 'N';
	    else
	      l_no_other := 'Y';
	    end if;
	    close csr_update_person_type_usages;
	    if l_no_other='N' then
	      exit;
	    end if;
	  end loop;

        END IF;

        IF l_no_other <> 'N' THEN

          benefits_person_type_usage_b
            (p_effective_date                 => p_effective_date
            ,p_person_type_usage_id           => l_person_type_usage_id
            );
          --
          if g_debug then
            hr_utility.set_location(l_proc, 93);
          end if;
          create_person_type_usage
            (p_person_id                      => p_person_id
            ,p_person_type_id                 => p_person_type_id
            ,p_effective_date                 => p_effective_date
            ,p_person_type_usage_id           => l_person_type_usage_id
            ,p_object_version_number          => l_object_version_number
            ,p_effective_start_date           => l_effective_start_date
            ,p_effective_end_date             => l_effective_end_date
            );
          --
          if g_debug then
            hr_utility.set_location(l_proc, 94);
          end if;
          benefits_person_type_usage_a
            (p_effective_date                 => p_effective_date
            ,p_person_type_usage_id           => l_person_type_usage_id
            );
          if g_debug then
            hr_utility.set_location(l_proc, 95);
          end if;
        --
        END IF;
        if g_debug then
          hr_utility.set_location(l_proc, 96);
        end if;
      end if;
      --
      if g_debug then
        hr_utility.set_location(l_proc, 97);
      end if;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc, 98);
    end if;
  end if;
  --
  ------------------------------------------------
  -- BEGIN TCA_UNMERGE CHANGES
  --
  -- Bug fix 3725055. If condition removed.
  --if hr_general.g_data_migrator_mode <> 'P' then
    open c_person;
    fetch c_person into l_person;
    close c_person;

    per_hrtca_merge.create_tca_person(p_rec => l_person);
  --end if;
  --
  -- END TCA_UNMERGE CHANGES
  ------------------------------------------------
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 1000);
  end if;
  --
end maintain_person_type_usage;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< cancel_person_type_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_person_type_usage
(
   p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_system_person_type             in     varchar2
 ) is
  --
  -- Declare cursors and local variables
  --
  c_backwards constant varchar2(30) := 'BACKWARDS';
  c_forwards constant varchar2(30) := 'FORWARDS';
  c_person_type_usage_id number;
  --
  cursor csr_person_type_usages
  (
     p_effective_date                 in     date
    ,p_person_id                      in     number
    ,p_search_type                    in     varchar2
    ) is
    select ptu.person_type_usage_id
          ,ptu.object_version_number
          ,ppt.system_person_type
          ,ptu.effective_start_date
          ,ptu.effective_end_date
      from per_person_types ppt
          ,per_person_type_usages_f ptu
     where ppt.person_type_id = ptu.person_type_id
       and ptu.person_type_usage_id = c_person_type_usage_id
       and ptu.person_id = p_person_id
       and (  (   p_search_type = c_backwards
              and ptu.effective_start_date <= p_effective_date)
           or (   p_search_type = c_forwards
              and ptu.effective_end_date >= p_effective_date) )
  order by decode(p_search_type
                 ,c_backwards,(p_effective_date - ptu.effective_start_date)
                 ,c_forwards,(ptu.effective_end_date - p_effective_date) )
  for update of ptu.person_type_usage_id;
  --
  cursor csr_ptu_rec_extra
	(p_person_type_usage_id NUMBER
	,p_person_id		NUMBER
	,p_effective_start_date	DATE)
  is
	--cursor update for bug 5706213
    select 	ptu.person_type_usage_id,ptu.effective_start_date,ptu.effective_end_date,object_version_number
    from 	per_person_type_usages_f ptu ,per_person_types ppt
    where	ptu.person_type_usage_id <> p_person_type_usage_id
    and 	ptu.person_id 	= p_person_id
    and     ppt.PERSON_TYPE_ID = ptu.PERSON_TYPE_ID
    and     ppt.system_person_type = 'APL'
    and	    ptu.effective_end_date = p_effective_start_date -1;
  --end changes for bug 5706213
    --
  cursor csr_pds_start is
    select max(date_start)
      from per_periods_of_service
     where person_id=p_person_id
       and date_start <= p_effective_date;
  --
  cursor csr_pdp_start is
    select max(date_start)
      from per_periods_of_service
     where person_id=p_person_id
       and date_start <= p_effective_date;
  --
  l_date_start date;
  --
  l_csr_person_type_usages csr_person_type_usages%ROWTYPE := NULL;
  l_person_type_usage_id per_person_type_usages_f.person_type_usage_id%TYPE;
  l_effective_start_date per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date per_person_type_usages_f.effective_end_date%TYPE;
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE;
  l_system_person_type  per_person_types.system_person_type%TYPE;
  l_proc varchar2(72) := g_package||'cancel_person_type_usage';
  l_effective_start_date1 per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date1 per_person_type_usages_f.effective_end_date%TYPE;
  l_object_version_number1 per_person_type_usages_f.object_version_number%TYPE;
  --
  -- BEGIN TCA_UNMERGE CHANGES
  cursor c_person is
    select *
    from   per_all_people_f
    where  person_id = p_person_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_person per_all_people_f%rowtype;
  --
  -- TCA_UNMERGE
  --
begin
  --
  if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
   hr_utility.set_location('cancel_person_type_usage.p_effective_date = '||to_char(p_effective_date,'DD-MON-YYYY'),11);
   hr_utility.set_location('cancel_person_type_usage.p_person_id = '||to_char(p_person_id),11);
   hr_utility.set_location('cancel_person_type_usage.p_system_person_type = '||p_system_person_type,11);
  end if;
  --
  begin
    select ptu.person_type_usage_id into c_person_type_usage_id
      from per_person_types ppt
          ,per_person_type_usages_f ptu
     where ppt.person_type_id = ptu.person_type_id
       and ppt.system_person_type = p_system_person_type
       and p_effective_date between ptu.effective_start_date and ptu.effective_end_date
       and ptu.person_id = p_person_id;
    if g_debug then
      hr_utility.set_location('cancel_person_type_usage.c_person_type_usage_id = '||to_char(c_person_type_usage_id),12);
    end if;
  exception
    when no_data_found then
      fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE',l_proc);
      fnd_message.set_token('STEP',13);
      fnd_message.raise_error;
  end;
  --
  --added following 'if' clause for 2449091
  --
  if p_system_person_type='EMP' then
    open csr_pds_start;
    fetch csr_pds_start into l_date_start;
    close csr_pds_start;
  elsif p_system_person_type='CWK' then
    open csr_pdp_start;
    fetch csr_pdp_start into l_date_start;
    close csr_pdp_start;
  else
    l_date_start := p_effective_date;
  end if;
  --
  -- Search backwards through the person type usage records for the start of
  -- this system person type
  --
  if g_debug then
    hr_utility.set_location('cancel_person_type_usage.c_backwards = '||c_backwards,14);
  end if;

  for currec in csr_person_type_usages
    (p_effective_date                 => p_effective_date
    ,p_person_id                      => p_person_id
    ,p_search_type                    => c_backwards) loop

    if g_debug then
      hr_utility.set_location('csr_person_type_usages',15);
      hr_utility.set_location('person_type_usage_id = '||currec.person_type_usage_id,15);
      hr_utility.set_location('object_version_number = '||to_char(currec.object_version_number),15);
      hr_utility.set_location('system_person_type = '||currec.system_person_type,15);
      hr_utility.set_location('effective_start_date = '||to_char(currec.effective_start_date),15);
      hr_utility.set_location('effective_end_date = '||to_char(currec.effective_end_date),15);
    end if;
    --
    --bug 2449091: back2back contracts dont have a change in SPT, so add extra check to stop at
    --change of period of service or placement (but only for backwards search)
    --
    EXIT WHEN (currec.system_person_type <> p_system_person_type
           OR (p_system_person_type in ('EMP','CWK')
          AND currec.effective_start_date = l_date_start));
    --
    if g_debug then
      hr_utility.set_location(l_proc, 15);
    end if;
    l_person_type_usage_id := currec.person_type_usage_id;
    l_object_version_number := currec.object_version_number;
    l_system_person_type := currec.system_person_type;
    l_effective_start_date := currec.effective_start_date;
    l_effective_end_date := currec.effective_end_date;

  end loop;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Search forwards through the person type usage records for the end of this
  -- system person type
  --
  for currec in csr_person_type_usages
    (p_effective_date                 => p_effective_date
    ,p_person_id                      => p_person_id
    ,p_search_type                    => c_forwards) loop

   if g_debug then
     hr_utility.set_location('csr_person_type_usages',16);
     hr_utility.set_location('person_type_usage_id = '||to_char(currec.person_type_usage_id),16);
     hr_utility.set_location('object_version_number = '||to_char(currec.object_version_number),16);
     hr_utility.set_location('system_person_type = '||currec.system_person_type,16);
     hr_utility.set_location('effective_start_date = '||to_char(currec.effective_start_date),16);
     hr_utility.set_location('effective_end_date = '||to_char(currec.effective_end_date),16);
   end if;

   EXIT WHEN currec.system_person_type <> p_system_person_type;

   if g_debug then
     hr_utility.set_location(l_proc, 25);
   end if;
   l_person_type_usage_id := currec.person_type_usage_id;
   l_object_version_number := currec.object_version_number;
   l_system_person_type := currec.system_person_type;
   l_effective_end_date := currec.effective_end_date;

  end loop;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_location(l_proc||':'||to_char(l_effective_start_date,'DD-MON-YYYY'), 99);
    hr_utility.set_location(l_proc||':'||to_char(l_effective_end_date,'DD-MON-YYYY'), 99);
    hr_utility.set_location(l_proc||':'||to_char(l_person_type_usage_id),99);
  end if;
  -- Ensure the person type usage identifier and effective dates have all been set
  --
  if ((l_person_type_usage_id is not null)
      and (l_effective_start_date is not null) and (l_effective_end_date is not null)) then
    --
    if g_debug then
      hr_utility.set_location(l_proc, 40);
    end if;
    --
    benefits_person_type_usage_b
      (p_effective_date                 => p_effective_date
      ,p_person_type_usage_id           => l_person_type_usage_id
      );
    --
    -- Remove records for the entire time that this system person type was in
    -- effect. Done through direct SQL as row handler does not allow this kind
    -- of manipulation.
    --
    delete
      from per_person_type_usages_f ptu
     where ptu.effective_start_date >= l_effective_start_date
       and ptu.effective_end_date <= l_effective_end_date
       and ptu.person_type_usage_id = l_person_type_usage_id;
    --
    --
    -- Extend any previous record to cover the time that the cancelled system
    -- person type existed. Done through direct SQL as row handler does not
    -- allow this kind of manipulation.
    --
    update per_person_type_usages_f ptu
       set effective_end_date = l_effective_end_date
     where ptu.effective_end_date = (l_effective_start_date - 1)
       and ptu.person_type_usage_id = l_person_type_usage_id;

--The csr_ptu_rec_extra looks for other person types that should remain in the system.
--The records are fetched of other person types only when the Emp and Apl
-- records are terminated on the same day. The loop is not executed otherwise.
--On discussing internally, found that there was no need to look for other
--person types of the record. Hence, we can eliminate the loop logic.
--Bug fix 4704941

--fix for the bug 5706213
--The csr_ptu_rec_extra is modified, it executes only in the case of Applicant.
  for csr_ptu_rec in csr_ptu_rec_extra
	(l_person_type_usage_id
	,p_person_id
	,l_effective_start_date	)
    loop

      l_object_version_number1 := csr_ptu_rec.object_version_number;

      if g_debug then
        hr_utility.set_location('csr_ptu_rec',16);
        hr_utility.set_location('person_type_usage_id = '||to_char(csr_ptu_rec.person_type_usage_id),16);
        hr_utility.set_location('effective_end_date = '||to_char(csr_ptu_rec.effective_end_date,'DD-MON-YYYY'),16);
      end if;
      --
      hr_per_type_usage_internal.delete_person_type_usage
                (p_person_type_usage_id  => csr_ptu_rec.person_type_usage_id
                ,p_effective_date        => csr_ptu_rec.effective_end_date
                ,p_datetrack_mode        =>  hr_api.g_future_change
                ,p_object_version_number => l_object_version_number1
                ,p_effective_start_date  => l_effective_start_date1
                ,p_effective_end_date    => l_effective_end_date1
                );

      if g_debug then
        hr_utility.set_location('l_object_version_number1 = '||to_char(l_object_version_number1),16);
        hr_utility.set_location('l_effective_start_date1 = '||to_char(l_effective_start_date1,'DD-MON-YYYY'),16);
        hr_utility.set_location('l_effective_end_date1 = '||to_char(l_effective_end_date1,'DD-MON-YYYY'),16);
      end if;

    end loop;

    --end changes for bug 5706213

    ------------------------------------------------
    -- BEGIN TCA_UNMERGE CHANGES
    --
    -- Bug fix 3725055. IF condition removed.
    --if hr_general.g_data_migrator_mode <> 'P' then
      open c_person;
      fetch c_person into l_person;
      close c_person;

      per_hrtca_merge.create_tca_person(p_rec => l_person);
    --end if;
    --
    -- END TCA_UNMERGE CHANGES
    ------------------------------------------------
    benefits_person_type_usage_a
      (p_effective_date                 => p_effective_date
      ,p_person_type_usage_id           => l_person_type_usage_id
      );
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 1000);
  end if;
  --
end cancel_person_type_usage;
--
-- ----------------------------------------------------------------------------
-- |-----------------------<   change_hire_date_ptu   >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure change_hire_date_ptu
(
   p_date_start          in      date
  ,p_old_date_start 	in	date
  ,p_person_id		in	number
  ,p_system_person_type	in	varchar2
 ) is
  --
  -- Declare cursors and local variables
  --
l_person_type_usages_id    number;
l_object_version_number    number;
l_ptu_effective_start_date date;
l_ptu_effective_end_date   date;
l_proc                     varchar2(30);
  --
l_chk_assign      varchar2(1):='N';
 --
cursor get_ptu(c_system_person_type varchar2,
               c_date date,
               c_person_id number) is
    select ptu.person_type_usage_id,
	   ptu.object_version_number,
           effective_start_date,
           effective_end_date
    from   per_person_type_usages_f ptu,
	   per_person_types         pt
    where  ptu.person_id = c_person_id
      and  (c_date between ptu.effective_start_date
		      and ptu.effective_end_date
            or c_date+1 between ptu.effective_start_date
                        and     ptu.effective_end_date
            and c_system_person_type = 'RETIREE'
              )
      and  ptu.person_type_id = pt.person_type_id
      and  pt.system_person_type = c_system_person_type;
  --
  cursor c1 is
    select *
    from   per_person_type_usages_f
    where  person_type_usage_id  = l_person_type_usages_id
    and    object_version_number = l_object_version_number;
  --
  cursor csr_ptu_prev_row is
    select *
    from per_person_type_usages_f
    where person_type_usage_id = l_person_type_usages_id
    and   effective_end_date = l_ptu_effective_start_date-1;
  --
  cursor csr_ptu_exapl_row is
    select ptu.person_type_usage_id
          ,ptu.object_version_number
          ,ptu.effective_start_date
          ,ptu.effective_end_date
    from per_person_type_usages_f ptu
        ,per_person_types ppt
    where ptu.effective_start_date = l_ptu_effective_start_date
    and   ptu.person_id = p_person_id
    and   ptu.person_type_id = ppt.person_type_id
    and   ppt.system_person_type = 'EX_APL';
  --
  cursor csr_ptu_apl_row is
    select ptu.person_type_usage_id
          ,ptu.object_version_number
          ,ptu.effective_start_date
          ,ptu.effective_end_date
    from per_person_type_usages_f ptu
        ,per_person_types ppt
    where ptu.effective_end_date = l_ptu_effective_start_date-1
    and   ptu.person_id = p_person_id
    and   ptu.person_type_id = ppt.person_type_id
    and   ppt.system_person_type = 'APL';
  --
  cursor csr_prev_other_row is
    select ptu.person_type_usage_id
          ,ptu.object_version_number
          ,ptu.effective_start_date
          ,ptu.effective_end_date
    from per_person_type_usages_f ptu
        ,per_person_types ppt
    where ptu.effective_end_date = l_ptu_effective_start_date-1
    and   ptu.person_id = p_person_id
    and   ptu.person_type_id = ppt.person_type_id
    and   ppt.system_person_type = 'OTHER';

  --cursor to check if change in hire date should update
  --the EX_*** records
  cursor csr_chk_assgn_id is
  select 'Y'
  from dual
  where exists (select p1.assignment_id
              from per_all_assignments_f p1,
              per_all_assignments_f p2
              where p1.assignment_type='A'
              and p2.assignment_type='E'
              and p1.assignment_id=p2.assignment_id
              and p1.person_id=p_person_id);
  --
  l_prev_other_row csr_prev_other_row%rowtype;
  l_ptu_prev_row csr_ptu_prev_row%rowtype;
  l_old ben_ptu_ler.g_ptu_ler_rec;
  l_new ben_ptu_ler.g_ptu_ler_rec;
  --
  l_c1 c1%rowtype;
  l_rows_found boolean := false;
  --
begin
 if g_debug then
   l_proc := 'change_hire_date_ptu';
   hr_utility.set_location(' Entering:'||l_proc, 10);
 end if;
 /*
 ** Get the person type usage record valid on the old date_start
 ** with correct type -
 */
 open get_ptu(c_system_person_type => p_system_person_type,
              c_date               => p_old_date_start,
              c_person_id          => p_person_id);
 fetch get_ptu into l_person_type_usages_id, l_object_version_number,
                    l_ptu_effective_start_date, l_ptu_effective_end_date;
 if get_ptu%FOUND then
   /*
   ** Update the PTU record. This will require a direct update since the
   ** API does not allow for updates to effective_start_date.
   **
   ** NB. Need also to move the end date of any previous EX record
   **     or OTHER record if one exists as of the day before p_old_date_start
   **     but raise error if this comes before the effective_start_date on the same row
   */
   --
   open c1;
   --
   fetch c1 into l_c1;
   if c1%found then
     --
     l_rows_found := true;
     --
   end if;
   --
   close c1;
   --
-- Bug 3905654 Start Here
-- Desc: Modified the UPDATE statement to include the ESD and EED in the where clause
--       So that its dependency on the OVN is overwritten.
   update PER_PERSON_TYPE_USAGES_F
      set effective_start_date  = p_date_start,
          object_version_number = object_version_number+1
    where person_type_usage_id  = l_person_type_usages_id
      and object_version_number = l_object_version_number
      and effective_start_date = l_ptu_effective_start_date
      and effective_end_date = l_ptu_effective_end_date;
-- Bug 3905654 Ends Here
   --
   -- fix2299851: update the end date of the previous records if they exist
   -- These will be the EX_xxx record and the OTHER record.
   --
   open csr_ptu_prev_row;
   fetch csr_ptu_prev_row into l_ptu_prev_row;
   if csr_ptu_prev_row%found then
     if l_ptu_prev_row.effective_start_date > p_date_start-1 then
       fnd_message.set_name('PER','HR_289742_NO_CHG_DATE_PTU');
       fnd_message.raise_error;
     else
       update PER_PERSON_TYPE_USAGES_F
	  set effective_end_date    = p_date_start-1,
              object_version_number = object_version_number+1
        where person_type_usage_id  = l_person_type_usages_id
          and object_version_number = l_ptu_prev_row.object_version_number;
      end if;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc, 20);
    end if;
    --
    open csr_prev_other_row;
    fetch csr_prev_other_row into l_prev_other_row;
    if csr_prev_other_row%found then
      if l_prev_other_row.effective_start_date > p_date_start-1 then
        fnd_message.set_name('PER','HR_289742_NO_CHG_DATE_PTU');
        fnd_message.raise_error;
      else
	update PER_PERSON_TYPE_USAGES_F
	   set effective_end_date    = p_date_start-1,
	       object_version_number = object_version_number+1
         where person_type_usage_id  = l_prev_other_row.person_type_usage_id
	   and object_version_number = l_prev_other_row.object_version_number;
      end if;
    end if;
    --
    open csr_chk_assgn_id;
    fetch csr_chk_assgn_id into l_chk_assign;
    if l_chk_assign='Y' then
    --checking cursor
    --move the EX_APL and APL records only if assignment_id are same
    --else do no change
    open csr_ptu_exapl_row;
    fetch csr_ptu_exapl_row into l_prev_other_row;
    if csr_ptu_exapl_row%found then
      update PER_PERSON_TYPE_USAGES_F
	 set effective_start_date  = p_date_start,
	     object_version_number = object_version_number+1
       where person_type_usage_id  = l_prev_other_row.person_type_usage_id
	 and object_version_number = l_prev_other_row.object_version_number;
    end if;
    --
    open csr_ptu_apl_row;
    fetch csr_ptu_apl_row into l_prev_other_row;
    if csr_ptu_apl_row%found then
      if l_prev_other_row.effective_start_date > p_date_start-1 then
        fnd_message.set_name('PER','HR_289742_NO_CHG_DATE_PTU');
        fnd_message.raise_error;
      else
        update PER_PERSON_TYPE_USAGES_F
	   set effective_end_date    = p_date_start-1,
	       object_version_number = object_version_number+1
         where person_type_usage_id  = l_prev_other_row.person_type_usage_id
	   and object_version_number = l_prev_other_row.object_version_number;
      end if;
    end if;
    --
   end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc, 30);
    end if;
    --
    if l_rows_found then
      --
      l_old.person_id := l_c1.person_id;
      l_old.person_type_usage_id := l_c1.person_type_usage_id;
      l_old.person_type_id := l_c1.person_type_id;
      l_old.effective_start_date := l_c1.effective_start_date;
      l_old.effective_end_date := l_c1.effective_end_date;
      l_new.person_id := l_c1.person_id;
      l_new.person_type_usage_id := l_c1.person_type_usage_id;
      l_new.person_type_id := l_c1.person_type_id;
      l_new.effective_start_date := p_date_start;
      l_new.effective_end_date := l_c1.effective_end_date;
      --
      ben_ptu_ler.ler_chk(p_old            => l_old,
                          p_new            => l_new,
                          p_effective_date => p_date_start);
      --
    end if;
    --
  end if;
  close get_ptu;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 100);
  end if;
end change_hire_date_ptu;
--
--
-- bug fix 7410493 starts
--
-- ----------------------------------------------------------------------------
-- |------------------------< cancel_emp_apl_ptu >----------------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_emp_apl_ptu
(
   p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_system_person_type             in     varchar2
 ) is


  c_person_type_usage_id number;
  --
  cursor csr_person_type_usages is

     select max (effective_start_date),max(effective_end_date)
         from per_person_type_usages_f
         where person_type_usage_id = c_person_type_usage_id ;

  --

  l_date_start date;
  --
  l_csr_person_type_usages csr_person_type_usages%ROWTYPE := NULL;
  l_person_type_usage_id per_person_type_usages_f.person_type_usage_id%TYPE;
  l_effective_start_date per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date per_person_type_usages_f.effective_end_date%TYPE;
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE;
  l_system_person_type  per_person_types.system_person_type%TYPE;
  l_proc varchar2(72) := g_package||'cancel_emp_apl_ptu';
  l_effective_start_date1 per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date1 per_person_type_usages_f.effective_end_date%TYPE;
  l_object_version_number1 per_person_type_usages_f.object_version_number%TYPE;
  --
  -- BEGIN TCA_UNMERGE CHANGES
  cursor c_person is
    select *
    from   per_all_people_f
    where  person_id = p_person_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_person per_all_people_f%rowtype;
  --
  -- TCA_UNMERGE
  --
begin
  --
  g_debug:=TRUE;
  if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
   hr_utility.set_location('cancel_emp_apl_ptu.p_effective_date = '||to_char(p_effective_date,'DD-MON-YYYY'),11);
   hr_utility.set_location('cancel_emp_apl_ptu.p_person_id = '||to_char(p_person_id),11);
   hr_utility.set_location('cancel_emp_apl_ptu.p_system_person_type = '||p_system_person_type,11);
  end if;
  --
  begin
    select ptu.person_type_usage_id into c_person_type_usage_id
      from per_person_types ppt
          ,per_person_type_usages_f ptu
     where ppt.person_type_id = ptu.person_type_id
       and ppt.system_person_type = p_system_person_type
       and p_effective_date between ptu.effective_start_date and ptu.effective_end_date
       and ptu.person_id = p_person_id;
    if g_debug then
      hr_utility.set_location('cancel_emp_apl_ptu.c_person_type_usage_id = '||to_char(c_person_type_usage_id),12);
    end if;
  exception
    when no_data_found then
      fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE',l_proc);
      fnd_message.set_token('STEP',13);
      fnd_message.raise_error;
  end;
  --
  --added following 'if' clause for 2449091
  --
/*
  if p_system_person_type='EMP' then
    open csr_pds_start;
    fetch csr_pds_start into l_date_start;
    close csr_pds_start;
  elsif p_system_person_type='CWK' then
    open csr_pdp_start;
    fetch csr_pdp_start into l_date_start;
    close csr_pdp_start;
  else
    l_date_start := p_effective_date;
  end if;
*/
l_date_start := p_effective_date;
  --
  open csr_person_type_usages;
   fetch csr_person_type_usages into l_effective_start_date , l_effective_end_date;
   close csr_person_type_usages;

   hr_utility.set_location(l_proc, 30);
    hr_utility.set_location(l_proc||':'||to_char(l_effective_start_date,'DD-MON-YYYY'), 99);
    hr_utility.set_location(l_proc||':'||to_char(l_effective_end_date,'DD-MON-YYYY'), 99);
    hr_utility.set_location(l_proc||':'||to_char(c_person_type_usage_id),99);



  if ((c_person_type_usage_id is not null)
      and (l_effective_start_date is not null)
       and (l_effective_end_date is not null)) then
    --

      hr_utility.set_location(l_proc, 40);

    --
    benefits_person_type_usage_b
      (p_effective_date                 => p_effective_date
      ,p_person_type_usage_id           => l_person_type_usage_id
      );
    --
    -- Remove records for the entire time that this system person type was in
    -- effect. Done through direct SQL as row handler does not allow this kind
    -- of manipulation.
    --
     hr_utility.set_location(l_proc, 50);

       hr_utility.set_location(l_proc||':'||to_char(l_effective_start_date,'DD-MON-YYYY'), 99);
    hr_utility.set_location(l_proc||':'||to_char(l_effective_end_date,'DD-MON-YYYY'), 99);
    hr_utility.set_location(l_proc||':'||to_char(c_person_type_usage_id),99);

    delete
      from per_person_type_usages_f ptu
     where ptu.effective_start_date >= l_effective_start_date
       and ptu.effective_end_date <= l_effective_end_date
       and ptu.person_type_usage_id = c_person_type_usage_id;
        if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','cancel_emp_apl_ptu');
    hr_utility.set_message_token('STEP',1);
    hr_utility.raise_error;
  end if;
    --
    --
      hr_utility.set_location(l_proc, 60);
    -- Extend any previous record to cover the time that the cancelled system
    -- person type existed. Done through direct SQL as row handler does not
    -- allow this kind of manipulation.
    --
      hr_utility.set_location(l_proc, 70);
    update per_person_type_usages_f ptu
       set effective_end_date = l_effective_end_date
     where ptu.effective_end_date = (l_effective_start_date - 1)
       and ptu.person_type_usage_id = c_person_type_usage_id;
        if sql%notfound then

 hr_utility.set_location(l_proc, 80);
  update per_person_type_usages_f ptu
  set effective_end_date = l_effective_end_date
  where ptu.effective_end_date = (l_effective_start_date - 1)
  and ptu.person_type_usage_id =  ( select distinct (person_type_usage_id)
                                    from per_person_type_usages_f ppf,
                                     per_person_types ppt
                                    where ppf.person_id = p_person_id
                                    and ppt.PERSON_TYPE_ID = ppf.PERSON_TYPE_ID
                                    and  ppt.system_person_type = 'APL'
        and effective_end_date = l_effective_start_date -1 );

        end if;

-- fix for the bug 5685089
--The csr_ptu_rec_extra looks for other person types that should remain in the system.
--The records are fetched of other person types only when the Emp and Apl
-- records are terminated on the same day. The loop is not executed otherwise.
--On discussing internally, found that there was no need to look for other
--person types of the record. Hence, we can eliminate the loop logic.

--fix for the bug 6012689
--The csr_ptu_rec_extra is modified, it executes only in the case of Applicant.
  hr_utility.set_location(l_proc, 90);

-- end of fix for the bug 6012689
-- end of fix for the bug 5685089
    ------------------------------------------------
    -- BEGIN TCA_UNMERGE CHANGES
    --
    -- Bug fix 3725055. IF condition removed.
    --if hr_general.g_data_migrator_mode <> 'P' then
    hr_utility.set_location(' Leaving: 1 ', 999);
      open c_person;
      fetch c_person into l_person;
      close c_person;
    hr_utility.set_location(' Leaving: 2 ', 91);
      per_hrtca_merge.create_tca_person(p_rec => l_person);
          hr_utility.set_location(' Leaving: 3', 99);
    --end if;
    --
    -- END TCA_UNMERGE CHANGES
    ------------------------------------------------
    benefits_person_type_usage_a
      (p_effective_date                 => p_effective_date
      ,p_person_type_usage_id           => l_person_type_usage_id
      );
    --
        hr_utility.set_location(' Leaving: 4 ', 100);
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 999);
  end if;
  --

end cancel_emp_apl_ptu;
 -- bug 7410493
 --
end hr_per_type_usage_internal;

/
