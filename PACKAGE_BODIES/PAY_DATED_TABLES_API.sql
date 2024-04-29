--------------------------------------------------------
--  DDL for Package Body PAY_DATED_TABLES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DATED_TABLES_API" as
/* $Header: pyptaapi.pkb 115.8 2002/12/05 12:35:00 swinton noship $ */
--
g_package  varchar2(33) := '  pay_dated_tables_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_dated_table >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates enforcing the required business rules.
--
procedure create_dated_table
  (p_validate                       in     boolean default false
  ,p_table_name                     in     varchar2
  ,p_application_id                 in     number  default null
  ,p_surrogate_key_name             in     varchar2
  ,p_start_date_name                in     varchar2
  ,p_end_date_name                  in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_dated_table_id                    out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_dyn_trigger_type               in     varchar2
  ,p_dyn_trigger_package_name       in     varchar2
  ,p_dyn_trig_pkg_generated         in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_dated_table';
  l_object_version_number number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint create_dated_table;
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
  pay_dated_tables_bk1.create_dated_table_b
  (p_table_name              => p_table_name
  ,p_application_id          => p_application_id
  ,p_surrogate_key_name      => p_surrogate_key_name
  ,p_start_date_name         => p_start_date_name
  ,p_end_date_name           => p_end_date_name
  ,p_business_group_id       => p_business_group_id
  ,p_legislation_code        => p_legislation_code
  ,p_dyn_trigger_type        => p_dyn_trigger_type
  ,p_dyn_trigger_package_name => p_dyn_trigger_package_name
  ,p_dyn_trig_pkg_generated   => p_dyn_trig_pkg_generated
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_DATED_TABLE',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_pta_ins.ins
  (p_table_name              => p_table_name
  ,p_application_id          => p_application_id
  ,p_surrogate_key_name      => p_surrogate_key_name
  ,p_start_date_name         => p_start_date_name
  ,p_end_date_name           => p_end_date_name
  ,p_business_group_id       => p_business_group_id
  ,p_legislation_code        => p_legislation_code
  ,p_dated_table_id          => p_dated_table_id
  ,p_object_version_number   => l_object_version_number
  ,p_dyn_trigger_type        => p_dyn_trigger_type
  ,p_dyn_trigger_package_name => p_dyn_trigger_package_name
  ,p_dyn_trig_pkg_generated   => p_dyn_trig_pkg_generated
  );
  --
  -- Start of API User Hook for the after hook of create_DATED_TABLE
  --
  begin
  pay_dated_tables_bk1.create_dated_table_a
  (p_table_name              => p_table_name
  ,p_application_id          => p_application_id
  ,p_surrogate_key_name      => p_surrogate_key_name
  ,p_start_date_name         => p_start_date_name
  ,p_end_date_name           => p_end_date_name
  ,p_business_group_id       => p_business_group_id
  ,p_legislation_code        => p_legislation_code
  ,p_dated_table_id          => p_dated_table_id
  ,p_object_version_number   => l_object_version_number
  ,p_dyn_trigger_type        => p_dyn_trigger_type
  ,p_dyn_trigger_package_name => p_dyn_trigger_package_name
  ,p_dyn_trig_pkg_generated   => p_dyn_trig_pkg_generated
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_DATED_TABLE',
          p_hook_type         => 'AP'
         );
  end;
 --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
exception
  --
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_dated_table;
    raise;
  -- Bugfix 2692195
  when others then
    --
    -- set all out parameters to null
    --
    p_dated_table_id := null;
    p_object_version_number := null;
    raise;
--
end create_dated_table;
-- ----------------------------------------------------------------------------
-- |--------------------------<update_dated_table >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates an existing dated table.
--
procedure update_dated_table
  (p_validate                       in     boolean default false
  ,p_dated_table_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_table_name                   in     varchar2  default hr_api.g_varchar2
  ,p_application_id               in     number    default hr_api.g_number
  ,p_surrogate_key_name           in     varchar2  default hr_api.g_varchar2
  ,p_start_date_name              in     varchar2  default hr_api.g_varchar2
  ,p_end_date_name                in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_dyn_trigger_type             in     varchar2  default hr_api.g_varchar2
  ,p_dyn_trigger_package_name     in     varchar2  default hr_api.g_varchar2
  ,p_dyn_trig_pkg_generated       in     varchar2  default hr_api.g_varchar2
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package ||'update_dated_table';
  l_object_version_number number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint update_dated_table;
  End If;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Start of API User Hook for the before hook of update_DATED_TABLE.
  --
  begin
  pay_dated_tables_bk2.update_dated_table_b
  (
   p_dated_table_id          => p_dated_table_id
  ,p_object_version_number   => l_object_version_number
  ,p_table_name              => p_table_name
  ,p_application_id          => p_application_id
  ,p_surrogate_key_name      => p_surrogate_key_name
  ,p_start_date_name         => p_start_date_name
  ,p_end_date_name           => p_end_date_name
  ,p_business_group_id       => p_business_group_id
  ,p_legislation_code        => p_legislation_code
  ,p_dyn_trigger_type        => p_dyn_trigger_type
  ,p_dyn_trigger_package_name => p_dyn_trigger_package_name
  ,p_dyn_trig_pkg_generated   => p_dyn_trig_pkg_generated
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_DATED_TABLE',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_pta_upd.upd
  (
   p_dated_table_id          => p_dated_table_id
  ,p_object_version_number   => l_object_version_number
  ,p_table_name              => p_table_name
  ,p_application_id          => p_application_id
  ,p_surrogate_key_name      => p_surrogate_key_name
  ,p_start_date_name         => p_start_date_name
  ,p_end_date_name           => p_end_date_name
  ,p_business_group_id       => p_business_group_id
  ,p_legislation_code        => p_legislation_code
  ,p_dyn_trigger_type        => p_dyn_trigger_type
  ,p_dyn_trigger_package_name => p_dyn_trigger_package_name
  ,p_dyn_trig_pkg_generated   => p_dyn_trig_pkg_generated
  );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  --
  -- Start of API User Hook for the after hook of update_DATED_TABLE.
  --
  begin
  pay_dated_tables_bk2.update_dated_table_a
  (
   p_dated_table_id          => p_dated_table_id
  ,p_object_version_number   => l_object_version_number
  ,p_table_name              => p_table_name
  ,p_application_id          => p_application_id
  ,p_surrogate_key_name      => p_surrogate_key_name
  ,p_start_date_name         => p_start_date_name
  ,p_end_date_name           => p_end_date_name
  ,p_business_group_id       => p_business_group_id
  ,p_legislation_code        => p_legislation_code
  ,p_dyn_trigger_type        => p_dyn_trigger_type
  ,p_dyn_trigger_package_name => p_dyn_trigger_package_name
  ,p_dyn_trig_pkg_generated   => p_dyn_trig_pkg_generated
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_DATED_TABLE',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of update_DATED_TABLE.
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
exception
  --
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_dated_table;
    --
  -- Bugfix 2692195
  when others then
    --
    -- reset all IN OUT paramters
    --
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_dated_table;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_dated_table >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API deletes an existing dated table.
--
procedure delete_dated_table
  (p_validate                       in     boolean default false
  ,p_dated_table_id                       in     number
  ,p_object_version_number                in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_dated_table';
  l_object_version_number number;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint delete_dated_table;
  End If;
  --
   l_object_version_number:= p_object_version_number;
  --
  -- Start of API User Hook for the before hook of delete_DATED_TABLE.
  --
  begin
  pay_dated_tables_bk3.delete_dated_table_b
  (
    p_dated_table_id =>  p_dated_table_id
   ,p_object_version_number    => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_DATED_TABLE',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_pta_del.del
  (
    p_dated_table_id =>  p_dated_table_id
   ,p_object_version_number    => l_object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  --
  -- Start of API User Hook for the after hook of DELETE_DATED_TABLE.
  --
  begin
  pay_dated_tables_bk3.delete_dated_table_a
  (
    p_dated_table_id =>  p_dated_table_id
   ,p_object_version_number    => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_DATED_TABLE',
          p_hook_type         => 'AP'
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
    ROLLBACK TO delete_dated_table;
    --
end delete_dated_table;
--
end pay_dated_tables_api;

/
