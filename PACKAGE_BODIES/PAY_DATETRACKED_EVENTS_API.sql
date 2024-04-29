--------------------------------------------------------
--  DDL for Package Body PAY_DATETRACKED_EVENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DATETRACKED_EVENTS_API" as
/* $Header: pydteapi.pkb 115.6 2002/12/06 14:45:55 jford noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------<create_datetracked_event >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates enforcing the required business rules.
--
g_package  varchar2(33) := '  pay_datetracked_events_api.';
--
procedure create_datetracked_event
  (
   p_validate                       in     boolean default false
  ,p_effective_date               in     date
  ,p_event_group_id                 in     number
  ,p_dated_table_id                 in     number
  ,p_update_type                    in     varchar2
  ,p_column_name                    in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_proration_style                in     varchar2 default null
  ,p_datetracked_event_id              out nocopy number
  ,p_object_version_number             out nocopy number
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_datetracked_event';
  l_datetracked_event_id  number;
  l_object_version_number number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
     savepoint create_datetracked_event;
  End If;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Start of API User Hook for the before hook of create_dateteacked_event.
  --
  begin
   pay_datetracked_events_bk1.create_datetracked_event_b
  (
   p_effective_date              => p_effective_date
  ,p_event_group_id              => p_event_group_id
  ,p_dated_table_id              => p_dated_table_id
  ,p_update_type                 => p_update_type
  ,p_column_name                 => p_column_name
  ,p_business_group_id           => p_business_group_id
  ,p_legislation_code            => p_legislation_code
  ,p_proration_style             => p_proration_style
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_DATETRACKED_EVENT',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- Process Logic
  --
  pay_dte_ins.ins
  (p_effective_date              => p_effective_date
  ,p_event_group_id              => p_event_group_id
  ,p_dated_table_id              => p_dated_table_id
  ,p_update_type                 => p_update_type
  ,p_column_name                 => p_column_name
  ,p_business_group_id           => p_business_group_id
  ,p_legislation_code            => p_legislation_code
  ,p_datetracked_event_id        => l_datetracked_event_id
  ,p_object_version_number       => l_object_version_number
  ,p_proration_style             => p_proration_style
  );
--
  -- Start of API User Hook for the after hook of create_datetracked_events
  --
  begin
  pay_datetracked_events_bk1. create_datetracked_event_a
  (p_effective_date              => p_effective_date
  ,p_event_group_id              => p_event_group_id
  ,p_dated_table_id              => p_dated_table_id
  ,p_update_type                 => p_update_type
  ,p_column_name                 => p_column_name
  ,p_business_group_id           => p_business_group_id
  ,p_legislation_code            => p_legislation_code
  ,p_datetracked_event_id        => l_datetracked_event_id
  ,p_object_version_number       => l_object_version_number
  ,p_proration_style             => p_proration_style
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_DATETRACKED_EVENT',
          p_hook_type         => 'AP'
         );
  end;
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
--
  p_object_version_number         := l_object_version_number;
  p_datetracked_event_id          := l_datetracked_event_id;
--
exception
  --
  when HR_Api.Validate_Enabled then
    --
   -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_datetracked_event;
--
end create_datetracked_event;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<update_datetracked_event >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates an existing datetracked event.
--
procedure update_datetracked_event
  (p_validate                       in     boolean default false
  ,p_effective_date               in     date
  ,p_datetracked_event_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_event_group_id               in     number    default hr_api.g_number
  ,p_dated_table_id               in     number    default hr_api.g_number
  ,p_update_type                  in     varchar2  default hr_api.g_varchar2
  ,p_column_name                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_proration_style              in     varchar2  default hr_api.g_varchar2
  )  IS
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package ||'update_datetracked_event';
  l_object_version_number number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint update_datetracked_event;
  End If;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Start of API User Hook for the before hook of update_DATETRACKED_EVENT.
  --
  begin
  pay_datetracked_events_bk2.update_datetracked_event_b
    (p_effective_date              => p_effective_date
    ,p_datetracked_event_id        => p_datetracked_event_id
    ,p_object_version_number       => l_object_version_number
    ,p_event_group_id              => p_event_group_id
    ,p_dated_table_id              => p_dated_table_id
    ,p_update_type                 => p_update_type
    ,p_column_name                 => p_column_name
    ,p_business_group_id           => p_business_group_id
    ,p_legislation_code            => p_legislation_code
    ,p_proration_style             => p_proration_style
    );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_DATETRACKED_EVENT',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_dte_upd.upd
    (p_effective_date              => p_effective_date
    ,p_datetracked_event_id        => p_datetracked_event_id
    ,p_object_version_number       => l_object_version_number
    ,p_event_group_id              => p_event_group_id
    ,p_dated_table_id              => p_dated_table_id
    ,p_update_type                 => p_update_type
    ,p_column_name                 => p_column_name
    ,p_business_group_id           => p_business_group_id
    ,p_legislation_code            => p_legislation_code
    ,p_proration_style             => p_proration_style
    );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  --
  -- Start of API User Hook for the after hook of update_DATETRACKED_EVENT.
  --
  begin
  pay_datetracked_events_bk2.update_datetracked_event_a
    (p_effective_date              => p_effective_date
    ,p_datetracked_event_id        => p_datetracked_event_id
    ,p_object_version_number       => l_object_version_number
    ,p_event_group_id              => p_event_group_id
    ,p_dated_table_id              => p_dated_table_id
    ,p_update_type                 => p_update_type
    ,p_column_name                 => p_column_name
    ,p_business_group_id           => p_business_group_id
    ,p_legislation_code            => p_legislation_code
    ,p_proration_style             => p_proration_style
    );

  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_DATETRACKED_EVENT',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of update_DATETRACKED_EVENT.
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
    ROLLBACK TO update_datetracked_event;
    --
end update_datetracked_event;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_datetracked_event ---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API deletes an existing datetracked event.
--
procedure delete_datetracked_event
  (p_validate                       in     boolean default false
  ,p_datetracked_event_id                 in     number
  ,p_object_version_number                in     number
  ) IS
 --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_datetracked_event';
  l_object_version_number number;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint delete_datetracked_event;
  End If;
  --
  l_object_version_number:= p_object_version_number;
  --
  --
  -- Start of API User Hook for the before hook of delete_DATETRACKED_EVENT.
  --
  begin
  pay_datetracked_events_bk3.delete_datetracked_event_b
  ( p_datetracked_event_id        => p_datetracked_event_id
   ,p_object_version_number       => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_DATETRACKED_EVENT',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_dte_del.del
  ( p_datetracked_event_id        => p_datetracked_event_id
   ,p_object_version_number       => l_object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  --
  -- Start of API User Hook for the after hook of DELETE_DATETRACKED_EVENT.
  --
  begin
  pay_datetracked_events_bk3.delete_datetracked_event_a
  ( p_datetracked_event_id        => p_datetracked_event_id
   ,p_object_version_number       => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_DATETRACKED_EVENT',
          p_hook_type         => 'AP'
         );
  end;
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
exception
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_datetracked_event;
    --
end delete_datetracked_event;

--
end pay_datetracked_events_api;

/
