--------------------------------------------------------
--  DDL for Package Body PAY_EVENT_UPDATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVENT_UPDATES_API" as
/* $Header: pypeuapi.pkb 115.7 2002/12/11 15:12:55 exjones noship $ */
--
g_package  varchar2(33) := '  pay_event_updates_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_event_update >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates enforcing the required business rules.
--
procedure create_event_update
  (p_validate                       in     boolean default false
  ,p_effective_date               in     date
  ,p_dated_table_id                 in     number
  ,p_change_type                    in     varchar2
  ,p_table_name                     in     varchar2 default null
  ,p_column_name                    in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_event_type                     in     varchar2 default null
  ,p_event_update_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_event_update';
  l_object_version_number number;
  l_event_update_id       number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint create_event_update;
  End If;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  -- Start of API User Hook for the before hook of create_dateteacked_event.
  --
  begin
  pay_event_updates_bk1.create_event_update_b
  (p_effective_date               => p_effective_date
  ,p_dated_table_id                 => p_dated_table_id
  ,p_change_type                    => p_change_type
  ,p_table_name                     => p_table_name
  ,p_column_name                    => p_column_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_event_type                     => p_event_type
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_EVENT_UPDATE',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_peu_ins.ins
  (p_effective_date               => p_effective_date
  ,p_dated_table_id                 => p_dated_table_id
  ,p_change_type                    => p_change_type
  ,p_table_name                     => p_table_name
  ,p_column_name                    => p_column_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_event_type                     => p_event_type
  ,p_event_update_id                => l_event_update_id
  ,p_object_version_number   => l_object_version_number
  );
--
  -- Start of API User Hook for the after hook of create_EVENT_UPDATE
  --
  begin
  pay_event_updates_bk1.create_event_update_a
  (p_effective_date               => p_effective_date
  ,p_dated_table_id                 => p_dated_table_id
  ,p_change_type                    => p_change_type
  ,p_table_name                     => p_table_name
  ,p_column_name                    => p_column_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_event_type                     => p_event_type
  ,p_event_update_id                => l_event_update_id
  ,p_object_version_number   => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_EVENT_UPDATE',
          p_hook_type         => 'AP'
         );
  end;
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  p_event_update_id               := l_event_update_id;
  p_object_version_number         := l_object_version_number;
  --
exception
  --
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_event_update;
--
end create_event_update;
-- ----------------------------------------------------------------------------
-- |--------------------------<update_event_update >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates an existing dated table.
--
procedure update_event_update
  (p_validate                       in     boolean default false
  ,p_effective_date               in     date
  ,p_event_update_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_dated_table_id               in     number    default hr_api.g_number
  ,p_change_type                  in     varchar2  default hr_api.g_varchar2
  ,p_table_name                   in     varchar2  default hr_api.g_varchar2
  ,p_column_name                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_event_type                   in     varchar2  default hr_api.g_varchar2
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package ||'update_event_update';
  l_object_version_number number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint update_event_update;
  End If;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Start of API User Hook for the before hook of update_EVENT_UPDATE.
  --
  begin
  pay_event_updates_bk2.update_event_update_b
  (p_effective_date               => p_effective_date
  ,p_event_update_id                => p_event_update_id
  ,p_object_version_number   => l_object_version_number
  ,p_dated_table_id                 => p_dated_table_id
  ,p_change_type                    => p_change_type
  ,p_table_name                     => p_table_name
  ,p_column_name                    => p_column_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_event_type                     => p_event_type
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_EVENT_UPDATE',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_peu_upd.upd
  (p_effective_date               => p_effective_date
  ,p_event_update_id                => p_event_update_id
  ,p_object_version_number   => l_object_version_number
  ,p_dated_table_id                 => p_dated_table_id
  ,p_change_type                    => p_change_type
  ,p_table_name                     => p_table_name
  ,p_column_name                    => p_column_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_event_type                     => p_event_type
  );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
    --
  -- Start of API User Hook for the after hook of update_EVENT_UPDATE.
  --
  begin
  pay_event_updates_bk2.update_event_update_a
  (p_effective_date               => p_effective_date
  ,p_event_update_id                => p_event_update_id
  ,p_object_version_number   => l_object_version_number
  ,p_dated_table_id                 => p_dated_table_id
  ,p_change_type                    => p_change_type
  ,p_table_name                     => p_table_name
  ,p_column_name                    => p_column_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_event_type                     => p_event_type
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_EVENT_UPDATE',
          p_hook_type         => 'AP'
         );
  end;
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  p_object_version_number         := l_object_version_number;
  --
exception
  --
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_event_update;
    raise;
    --
end update_event_update;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_event_update >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API deletes an existing dated table.
--
procedure delete_event_update
  (p_validate                       in     boolean default false
  ,p_event_update_id                      in     number
  ,p_object_version_number                in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_event_update';
  l_object_version_number number;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint delete_event_update;
  End If;
  --
  --
  -- Start of API User Hook for the before hook of delete_EVENT_UPDATE.
  --
  begin
  pay_event_updates_bk3.delete_event_update_b
  (
    p_event_update_id                => p_event_update_id
   ,p_object_version_number    => p_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_EVENT_UPDATE',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_peu_del.del
  (
    p_event_update_id                => p_event_update_id
   ,p_object_version_number    => p_object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  begin
  pay_event_updates_bk3.delete_event_update_a
  (
    p_event_update_id                => p_event_update_id
   ,p_object_version_number    => p_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_EVENT_UPDATE',
          p_hook_type         => 'BP'
         );
  end;
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
exception
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_event_update;
    --
end delete_event_update;
--
end pay_event_updates_api;

/
