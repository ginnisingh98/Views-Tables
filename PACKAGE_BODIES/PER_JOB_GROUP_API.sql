--------------------------------------------------------
--  DDL for Package Body PER_JOB_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JOB_GROUP_API" as
/* $Header: pejgrapi.pkb 115.3 2002/12/11 11:30:28 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PER_JOB_GROUP_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_JOB_GROUP >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_JOB_GROUP
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_internal_name                 in     varchar2
  ,p_displayed_name                in     varchar2
  ,p_id_flex_num                   in     number
  ,p_master_flag                   in     varchar2 default 'N'
  ,p_job_group_id                  out nocopy    number
  ,p_object_version_number         out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'CREATE_JOB_GROUP';
  l_effective_date      date;
  l_job_group_id        PER_JOB_GROUPS.JOB_GROUP_ID%TYPE;
  l_object_version_number PER_JOB_GROUPS.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint CREATE_JOB_GROUP;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    PER_JOB_GROUP_BK1.CREATE_JOB_GROUP_b
    (p_effective_date            => l_effective_date
    ,p_business_group_id         => p_business_group_id
    ,p_legislation_code          => p_legislation_code
    ,p_internal_name             => p_internal_name
    ,p_displayed_name            => p_displayed_name
    ,p_id_flex_num               => p_id_flex_num
    ,p_master_flag               => p_master_flag
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_JOB_GROUP_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_jgr_ins.ins(
   p_effective_date         => p_effective_date
  ,p_business_group_id      => p_business_group_id
  ,p_internal_name          => p_internal_name
  ,p_displayed_name         => p_displayed_name
  ,p_id_flex_num            => p_id_flex_num
  ,p_master_flag            => p_master_flag
  ,p_legislation_code       => p_legislation_code
  ,p_job_group_id           => l_job_group_id
  ,p_object_version_number  => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_JOB_GROUP_BK1.CREATE_JOB_GROUP_a
       (p_effective_date          => l_effective_date
       ,p_business_group_id       => p_business_group_id
       ,p_legislation_code        => p_legislation_code
       ,p_internal_name           => p_internal_name
       ,p_displayed_name          => p_displayed_name
       ,p_id_flex_num             => p_id_flex_num
       ,p_master_flag             => p_master_flag
       ,p_job_group_id            => l_job_group_id
       ,p_object_version_number   => l_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_JOB_GROUP_a'
        ,p_hook_type   => 'AP'
        );
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
  p_job_group_id           := l_job_group_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_JOB_GROUP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_job_group_id           := null;
    p_object_version_number  := null;
--
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_JOB_GROUP;
    --
    -- set in out parameters and set out parameters
    --
    p_job_group_id           := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_JOB_GROUP;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_JOB_GROUP >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_JOB_GROUP
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_job_group_id                  in     number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_internal_name                 in     varchar2
  ,p_displayed_name                in     varchar2
  ,p_id_flex_num                   in     number
  ,p_master_flag                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_JOB_GROUP';
  l_effective_date        date;
  l_job_group_id          PER_JOB_GROUPS.JOB_GROUP_ID%TYPE;
  l_object_version_number PER_JOB_GROUPS.OBJECT_VERSION_NUMBER%TYPE;
  l_ovn PER_JOB_GROUPS.OBJECT_VERSION_NUMBER%TYPE := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint UPDATE_JOB_GROUP;
  --
  -- Store initial value for OVN in out parameter.
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    PER_JOB_GROUP_BK2.UPDATE_JOB_GROUP_b
    (p_effective_date            => l_effective_date
    ,p_job_group_id              => p_job_group_id
    ,p_object_version_number     => p_object_version_number
    ,p_business_group_id         => p_business_group_id
    ,p_legislation_code          => p_legislation_code
    ,p_internal_name             => p_internal_name
    ,p_displayed_name            => p_displayed_name
    ,p_id_flex_num               => p_id_flex_num
    ,p_master_flag               => p_master_flag
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_JOB_GROUP_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_jgr_upd.upd(
   p_effective_date         => l_effective_date
  ,p_job_group_id           => p_job_group_id
  ,p_object_version_number  => l_object_version_number
  ,p_business_group_id      => p_business_group_id
  ,p_internal_name          => p_internal_name
  ,p_displayed_name         => p_displayed_name
  ,p_id_flex_num            => p_id_flex_num
  ,p_master_flag            => p_master_flag
  ,p_legislation_code       => p_legislation_code
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_JOB_GROUP_BK2.UPDATE_JOB_GROUP_a
       (p_effective_date          => p_effective_date
       ,p_job_group_id            => p_job_group_id
       ,p_object_version_number   => l_object_version_number
       ,p_business_group_id       => p_business_group_id
       ,p_legislation_code        => p_legislation_code
       ,p_internal_name           => p_internal_name
       ,p_displayed_name          => p_displayed_name
       ,p_id_flex_num             => p_id_flex_num
       ,p_master_flag             => p_master_flag
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_JOB_GROUP_a'
        ,p_hook_type   => 'AP'
        );
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_JOB_GROUP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_JOB_GROUP;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_JOB_GROUP;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_JOB_GROUP >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_JOB_GROUP
  (p_validate                      in     boolean  default false
  ,p_job_group_id                  in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'DELETE_JOB_GROUP';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint DELETE_JOB_GROUP;
  --
  -- Call Before Process User Hook
  --
  begin
    PER_JOB_GROUP_BK3.DELETE_JOB_GROUP_b
    (p_job_group_id              => p_job_group_id
    ,p_object_version_number     => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_JOB_GROUP_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  per_jgr_del.del
   (p_job_group_id                       => p_job_group_id
   ,p_object_version_number              => p_object_version_number
  );
  --
  begin
    PER_JOB_GROUP_BK3.DELETE_JOB_GROUP_a
      (p_job_group_id              => p_job_group_id
      ,p_object_version_number     => p_object_version_number
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'UPDATE_JOB_GROUP_a'
          ,p_hook_type   => 'AP'
          );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_JOB_GROUP;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
   rollback to DELETE_JOB_GROUP;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 90);
   --
   raise;
   --
end DELETE_JOB_GROUP;
--
end PER_JOB_GROUP_API;

/
