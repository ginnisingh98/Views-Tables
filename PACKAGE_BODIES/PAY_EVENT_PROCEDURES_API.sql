--------------------------------------------------------
--  DDL for Package Body PAY_EVENT_PROCEDURES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVENT_PROCEDURES_API" as
/* $Header: pyevpapi.pkb 120.0 2005/05/29 04:48:23 appldev noship $*/
--
g_package  varchar2(33) := '  pay_event_procedures_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_event_proc >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates enforcing the required business rules.
--
procedure create_event_proc
  (p_validate                       in            boolean  default false
  ,p_dated_table_id                 in            number
  ,p_procedure_name                 in            varchar2 default null
  ,p_business_group_id              in            number   default null
  ,p_legislation_code               in            varchar2 default null
  ,p_column_name                    in            varchar2 default null
  ,p_event_procedure_id                out nocopy number
  ,p_object_version_number             out nocopy number
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_event_proc';
  l_object_version_number number;
  l_event_procedure_id    number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint CREATE_EVENT_PROC;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Start of API User Hook for the before hook of create_dateteacked_event.
  --
  begin
  pay_event_procedures_bk1.create_event_proc_b
  (
   p_dated_table_id                 => p_dated_table_id
  ,p_procedure_name                 => p_procedure_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_column_name                    => p_column_name
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_EVENT_PROC',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- Process Logic
  --
  pay_evp_ins.ins
  (
   p_dated_table_id                 => p_dated_table_id
  ,p_procedure_name                 => p_procedure_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_column_name                    => p_column_name
  ,p_event_procedure_id             => l_event_procedure_id
  ,p_object_version_number          => l_object_version_number
  );
--
  -- Start of API User Hook for the after hook of create_datetracked_events
  --
  begin
  pay_event_procedures_bk1.create_event_proc_a
  (
   p_dated_table_id                 => p_dated_table_id
  ,p_procedure_name                 => p_procedure_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_column_name                    => p_column_name
  ,p_event_procedure_id             => l_event_procedure_id
  ,p_object_version_number          => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_EVENT_PROC',
          p_hook_type         => 'AP'
         );
  end;
  --
   --
  -- Bug no. 4038782
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_event_procedure_id    := l_event_procedure_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_EVENT_PROC;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_event_procedure_id    := null;
    p_object_version_number := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_EVENT_PROC;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_event_procedure_id    := null;
    p_object_version_number := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_event_proc;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_event_proc >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This API updates an existing event procedure.
--
Procedure update_event_proc
  (p_validate                     in            boolean   default false
  ,p_event_procedure_id           in            number
  ,p_object_version_number        in out nocopy number
  ,p_dated_table_id               in            number    default hr_api.g_number
  ,p_procedure_name               in            varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in            number    default hr_api.g_number
  ,p_legislation_code             in            varchar2  default hr_api.g_varchar2
  ,p_column_name                  in            varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package ||'update_event_proc';
  l_object_version_number number;
  l_copy_ov_number number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_copy_ov_number := p_object_version_number;
  --
  savepoint UPDATE_EVENT_PROC;
  --
  l_object_version_number := p_object_version_number;
    --
  -- Start of API User Hook for the before hook of update_EVENT_PROC.
  --
  begin
  pay_event_procedures_bk2.update_event_proc_b
  (p_event_procedure_id            => p_event_procedure_id
  ,p_object_version_number        => l_object_version_number
  ,p_dated_table_id                 => p_dated_table_id
  ,p_procedure_name                 => p_procedure_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_column_name                    => p_column_name
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_EVENT_PROC',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_evp_upd.upd
  (p_event_procedure_id            => p_event_procedure_id
  ,p_object_version_number        => l_object_version_number
  ,p_dated_table_id                 => p_dated_table_id
  ,p_procedure_name                 => p_procedure_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_column_name                    => p_column_name
  );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Start of API User Hook for the after hook of update_EVENT_PROC.
  --
  begin
pay_event_procedures_bk2.update_event_proc_a
  (p_event_procedure_id            => p_event_procedure_id
  ,p_object_version_number        => l_object_version_number
  ,p_dated_table_id                 => p_dated_table_id
  ,p_procedure_name                 => p_procedure_name
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_column_name                    => p_column_name
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_EVENT_PROC',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of update_EVENT_PROC.
  --
  -- Bug no. 4038782
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;

exception
  --
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_EVENT_PROC;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_EVENT_PROC;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    raise;
    --
end update_event_proc;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_event_proc >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API deletes an existing event procedure
--
Procedure delete_event_proc
  (p_validate                             in     boolean   default false
  ,p_event_procedure_id                   in     number
  ,p_object_version_number                in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_event_proc';
  l_object_version_number number;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint DELETE_EVENT_PROC;
  --
   l_object_version_number:= p_object_version_number;
  --
  -- Start of API User Hook for the before hook of delete_EVENT_PROC.
  --
  begin
  pay_event_procedures_bk3.delete_event_proc_b
  (
    p_event_procedure_id       => p_event_procedure_id
   ,p_object_version_number    => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_EVENT_PROC',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_evp_del.del
  (
    p_event_procedure_id       => p_event_procedure_id
   ,p_object_version_number    => l_object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  --
  -- Start of API User Hook for the after hook of DELETE_EVENT_PROC.
  --
  begin
pay_event_procedures_bk3.delete_event_proc_a
  (
    p_event_procedure_id       => p_event_procedure_id
   ,p_object_version_number    => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_EVENT_PROC',
          p_hook_type         => 'AP'
         );
  end;
  --
  --
  -- Bug no. 4038782
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  --
exception
   --
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_EVENT_PROC;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_EVENT_PROC;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    raise;
    --
end delete_event_proc;
--
end pay_event_procedures_api;

/
