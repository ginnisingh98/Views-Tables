--------------------------------------------------------
--  DDL for Package Body PAY_PPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPE_API" as
/* $Header: pyppeapi.pkb 120.2.12010000.1 2008/07/27 23:25:01 appldev ship $ */
--
g_package  varchar2(33) := '  pay_ppe_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_process_event >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates enforcing the required business rules.
--
procedure create_process_event(
   p_validate                       in     boolean   default false
  ,p_assignment_id                  in     number    default null
  ,p_effective_date                 in     date
  ,p_change_type                    in     varchar2
  ,p_status                         in     varchar2
  ,p_description                    in     varchar2   default null
  ,p_process_event_id                  out nocopy     number
  ,p_object_version_number             out nocopy     number
  ,p_event_update_id                in     number     default null
  ,p_org_process_event_group_id     in     number     default null
  ,p_business_group_id              in     number     default null
  ,p_surrogate_key                  in     varchar2   default null
  ,p_calculation_date               in     date       default null
  ,p_retroactive_status             in     varchar2   default null
  ,p_noted_value                    in     varchar2   default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_process_event';
  l_object_version_number number;
  l_process_event_id       number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint create_process_event;
  End If;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Start of API User Hook for the before hook of create_dateteacked_event.
  --
  begin
  pay_ppe_bk1.create_process_event_b
  (
   p_assignment_id                  => p_assignment_id
  ,p_effective_date                 => p_effective_date
  ,p_change_type                    => p_change_type
  ,p_status                         => p_status
  ,p_description                    => p_description
  ,p_event_update_id                => p_event_update_id
  ,p_org_process_event_group_id     => p_org_process_event_group_id
  ,p_business_group_id              => p_business_group_id
  ,p_surrogate_key                  => p_surrogate_key
  ,p_calculation_date               => p_calculation_date
  ,p_retroactive_status             => p_retroactive_status
  ,p_noted_value                    => p_noted_value
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_PROCESS_EVENT',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- Process Logic
  --
  pay_pev_ins.ins
  (
   p_effective_date                 => p_effective_date
  ,p_change_type                    => p_change_type
  ,p_status                         => p_status
  ,p_assignment_id                  => p_assignment_id
  ,p_description                    => p_description
  ,p_event_update_id                => p_event_update_id
  ,p_business_group_id              => p_business_group_id
  ,p_org_process_event_group_id     => p_org_process_event_group_id
  ,p_surrogate_key                  => p_surrogate_key
  ,p_calculation_date               => p_calculation_date
  ,p_retroactive_status             => p_retroactive_status
  ,p_noted_value                    => p_noted_value
  ,p_process_event_id               => l_process_event_id
  ,p_object_version_number          => l_object_version_number
  );
  --
  --
  -- Start of API User Hook for the after hook of create_PROCESS_EVENT
  --
  begin
  pay_ppe_bk1.create_process_event_a
  (
   p_assignment_id                  => p_assignment_id
  ,p_effective_date                 => p_effective_date
  ,p_change_type                    => p_change_type
  ,p_status                         => p_status
  ,p_description                    => p_description
  ,p_process_event_id               => l_process_event_id
  ,p_object_version_number          => l_object_version_number
  ,p_event_update_id                => p_event_update_id
  ,p_org_process_event_group_id     => p_org_process_event_group_id
  ,p_business_group_id              => p_business_group_id
  ,p_surrogate_key                  => p_surrogate_key
  ,p_calculation_date               => p_calculation_date
  ,p_retroactive_status             => p_retroactive_status
  ,p_noted_value                    => p_noted_value
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_PROCESS_EVENT',
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
    ROLLBACK TO create_process_event;
    --
    p_process_event_id := null;
    p_object_version_number := null;
--
end create_process_event;
-- ----------------------------------------------------------------------------
-- |--------------------------<update_process_event >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates an existing process event.
--
procedure update_process_event
  (
   p_validate                       in     boolean default false
  ,p_process_event_id             in     number
  ,p_object_version_number        in out nocopy    number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_change_type                  in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_event_update_id              in     number    default hr_api.g_number
  ,p_org_process_event_group_id   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_surrogate_key                in     varchar2  default hr_api.g_varchar2
  ,p_calculation_date             in     date      default hr_api.g_date
  ,p_retroactive_status           in     varchar2  default hr_api.g_varchar2
  ,p_noted_value                  in     varchar2  default hr_api.g_varchar2
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package ||'update_process_event';
  l_object_version_number number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint update_process_event;
  End If;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Start of API User Hook for the before hook of update_PROCESS_EVENT.
  --
  begin
  pay_ppe_bk2.update_process_event_b
  (p_process_event_id               => p_process_event_id
  ,p_object_version_number          => p_object_version_number
  ,p_assignment_id                  => p_assignment_id
  ,p_effective_date                 => p_effective_date
  ,p_change_type                    => p_change_type
  ,p_status                         => p_status
  ,p_description                    => p_description
  ,p_event_update_id                => p_event_update_id
  ,p_org_process_event_group_id     => p_org_process_event_group_id
  ,p_business_group_id              => p_business_group_id
  ,p_surrogate_key                  => p_surrogate_key
  ,p_calculation_date               => p_calculation_date
  ,p_retroactive_status             => p_retroactive_status
  ,p_noted_value                    => p_noted_value
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_PROCESS_EVENT',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_pev_upd.upd
  (p_process_event_id               => p_process_event_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_change_type                    => p_change_type
  ,p_status                         => p_status
  ,p_assignment_id                  => p_assignment_id
  ,p_description                    => p_description
  ,p_event_update_id                => p_event_update_id
  ,p_business_group_id              => p_business_group_id
  ,p_org_process_event_group_id     => p_org_process_event_group_id
  ,p_surrogate_key                  => p_surrogate_key
  ,p_calculation_date               => p_calculation_date
  ,p_retroactive_status             => p_retroactive_status
  ,p_noted_value                    => p_noted_value
  );
  --
  --
  -- Start of API User Hook for the after hook of update_PROCESS_EVENT.
  --
  begin
  pay_ppe_bk2.update_process_event_a
  (p_process_event_id               => p_process_event_id
  ,p_object_version_number          => p_object_version_number
  ,p_assignment_id                  => p_assignment_id
  ,p_effective_date                 => p_effective_date
  ,p_change_type                    => p_change_type
  ,p_status                         => p_status
  ,p_description                    => p_description
  ,p_event_update_id                => p_event_update_id
  ,p_org_process_event_group_id     => p_org_process_event_group_id
  ,p_business_group_id              => p_business_group_id
  ,p_surrogate_key                  => p_surrogate_key
  ,p_calculation_date               => p_calculation_date
  ,p_retroactive_status             => p_retroactive_status
  ,p_noted_value                    => p_noted_value
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_PROCESS_EVENT',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of update_PROCESS_EVENT.
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
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
    ROLLBACK TO update_process_event;
    --
    p_object_version_number := l_object_version_number;
    --
end update_process_event;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_process_event >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API deletes an existing process event.
--
procedure delete_process_event
  (p_validate                       in     boolean default false
  ,p_process_event_id                      in     number
  ,p_object_version_number                in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_process_event';
  l_object_version_number number;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    savepoint delete_process_event;
  End If;
  --
  l_object_version_number:= p_object_version_number;
  --
  -- Start of API User Hook for the before hook of delete_PROCESS_EVENT.
  --
  begin
  pay_ppe_bk3.delete_process_event_b
  (
    p_process_event_id         => p_process_event_id
   ,p_object_version_number    => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_PROCESS_EVENT',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_pev_del.del
  (
    p_process_event_id         => p_process_event_id
   ,p_object_version_number    => l_object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  -- Start of API User Hook for the after hook of DELETE_PROCESS_EVENT.
  --
  begin
  pay_ppe_bk3.delete_process_event_a
  (
    p_process_event_id         => p_process_event_id
   ,p_object_version_number    => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_PROCESS_EVENT',
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
    ROLLBACK TO delete_process_event;
    --
end delete_process_event;
--
end pay_ppe_api;

/
