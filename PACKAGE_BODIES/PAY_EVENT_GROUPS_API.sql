--------------------------------------------------------
--  DDL for Package Body PAY_EVENT_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVENT_GROUPS_API" as
/* $Header: pyevgapi.pkb 120.2 2005/10/04 00:23:34 adkumar noship $ */
--
--
-- Package Variables
--
g_package  varchar2(33) := ' pay_event_groups_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_event_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_event_group
(
   p_validate                       in     boolean default false
  ,p_effective_date                 in date
  ,p_event_group_name               in varchar2
  ,p_event_group_type               in varchar2
  ,p_proration_type                 in varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_event_group_id                 out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_time_definition_id             in     number   default null
) is
 --
  l_proc varchar2(72) := g_package||'create_event_group';
  l_object_version_number pay_event_groups.object_version_number%TYPE;
  l_event_group_id        pay_event_groups.event_group_id%TYPE;
 --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint create_event_group;
   --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  -- Start of API User Hook for the before hook of create_EVENT_GROUP.
  --
  begin
  pay_event_groups_bk1.create_event_group_b
  (
   p_effective_date     => p_effective_date
  ,p_event_group_name   => p_event_group_name
  ,p_event_group_type   => p_event_group_type
  ,p_proration_type     => p_proration_type
  ,p_business_group_id  => p_business_group_id
  ,p_legislation_code   => p_legislation_code
  ,p_time_definition_id => p_time_definition_id
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_EVENT_GROUP',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_evg_ins.ins
  (
   p_effective_date     => p_effective_date
  ,p_event_group_name   => p_event_group_name
  ,p_event_group_type   => p_event_group_type
  ,p_proration_type     => p_proration_type
  ,p_business_group_id  => p_business_group_id
  ,p_legislation_code   => p_legislation_code
  ,p_event_group_id        => l_event_group_id
  ,p_object_version_number => l_object_version_number
  ,p_time_definition_id => p_time_definition_id
  );
--
  --
  -- Start of API User Hook for the after hook of create_EVENT_GROUP.
  --
  begin
  pay_event_groups_bk1.create_event_group_a
  (
   p_effective_date     => p_effective_date
  ,p_event_group_name   => p_event_group_name
  ,p_event_group_type   => p_event_group_type
  ,p_proration_type     => p_proration_type
  ,p_business_group_id  => p_business_group_id
  ,p_legislation_code   => p_legislation_code
  ,p_event_group_id        => l_event_group_id
  ,p_object_version_number => l_object_version_number
  ,p_time_definition_id => p_time_definition_id
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_EVENT_GROUP',
          p_hook_type         => 'AP'
         );
  end;
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  p_event_group_id        := l_event_group_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_event_group;
    p_event_group_id        := l_event_group_id;
    p_object_version_number := l_object_version_number;
    hr_utility.set_location('Leaving:'|| l_proc, 80);
  when others then
    ROLLBACK TO create_event_group;
    p_event_group_id        := null;
    p_object_version_number := null;
    hr_utility.set_location('Leaving:'|| l_proc, 90);
    raise;
--
end create_event_group;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_event_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_event_group
(
   p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_event_group_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_event_group_name             in     varchar2  default hr_api.g_varchar2
  ,p_event_group_type             in     varchar2  default hr_api.g_varchar2
  ,p_proration_type               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_time_definition_id           in     number    default hr_api.g_number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_event_group';
  l_object_version_number pay_event_groups.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint update_event_group;
  --
  l_object_version_number := p_object_version_number;
  --
  --
  -- Start of API User Hook for the before hook of update_EVENT_GROUP.
  --
  begin
  pay_event_groups_bk2.update_event_group_b
  (p_effective_date            => p_effective_date
  ,p_event_group_id        => p_event_group_id
  ,p_object_version_number => l_object_version_number
  ,p_event_group_name   => p_event_group_name
  ,p_event_group_type   => p_event_group_type
  ,p_proration_type     => p_proration_type
  ,p_business_group_id  => p_business_group_id
  ,p_legislation_code   => p_legislation_code
  ,p_time_definition_id => p_time_definition_id
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_EVENT_GROUP',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_evg_upd.upd
  (
   p_effective_date            => p_effective_date
  ,p_event_group_id        => p_event_group_id
  ,p_object_version_number => l_object_version_number
  ,p_event_group_name   => p_event_group_name
  ,p_event_group_type   => p_event_group_type
  ,p_proration_type     => p_proration_type
  ,p_business_group_id  => p_business_group_id
  ,p_legislation_code   => p_legislation_code
  ,p_time_definition_id => p_time_definition_id
  );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  --
  -- Start of API User Hook for the after hook of update_EVENT_GROUP.
  --
  begin
  pay_event_groups_bk2.update_event_group_a
  (p_effective_date            => p_effective_date
  ,p_event_group_id        => p_event_group_id
  ,p_object_version_number => l_object_version_number
  ,p_event_group_name   => p_event_group_name
  ,p_event_group_type   => p_event_group_type
  ,p_proration_type     => p_proration_type
  ,p_business_group_id  => p_business_group_id
  ,p_legislation_code   => p_legislation_code
  ,p_time_definition_id => p_time_definition_id
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_EVENT_GROUP',
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
    ROLLBACK TO update_event_group;
    p_object_version_number         := l_object_version_number;
    hr_utility.set_location('Leaving:'|| l_proc, 80);
  when others then
    ROLLBACK TO update_event_group;
    p_object_version_number         := l_object_version_number;
    hr_utility.set_location('Leaving:'|| l_proc, 90);
    raise;
    --
end update_event_group;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_event_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_event_group
(
   p_validate                       in     boolean default false
  ,p_event_group_id                 in     number
  ,p_object_version_number          in number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_event_group';
  l_object_version_number pay_event_groups.object_version_number%TYPE;
 --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint delete_event_group;
  --
  --
  l_object_version_number:= p_object_version_number;
  --
  -- Start of API User Hook for the before hook of delete_EVENT_GROUP.
  --
  begin
  pay_event_groups_bk3.delete_event_group_b
  (
    p_event_group_id           => p_event_group_id
   ,p_object_version_number    => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_EVENT_GROUP',
          p_hook_type         => 'BP'
         );
  end;
  --
  pay_evg_del.del
  (
    p_event_group_id           => p_event_group_id
   ,p_object_version_number    => l_object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  --
  -- Start of API User Hook for the after hook of create_EVENT_GROUP.
  --
  begin
  pay_event_groups_bk3.delete_event_group_a
  (
    p_event_group_id           => p_event_group_id
   ,p_object_version_number    => l_object_version_number
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_EVENT_GROUP',
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
    ROLLBACK TO delete_event_group;
    hr_utility.set_location('Leaving:'|| l_proc, 80);
  when others then
    ROLLBACK TO delete_event_group;
    hr_utility.set_location('Leaving:'|| l_proc, 90);
    raise;
    --
end delete_event_group ;
--
--
/*
-- ----------------------------------------------------------------------------
-- |------------------------< lck_event_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck_event_group
(
   p_event_group_id                   in     number
  ,p_object_version_number            in     number
) is
  --
  --
  -- Declare cursors and local variables
  l_proc                  varchar2(72) := g_package||'lck_event_group.';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pay_evg_shd.lck
  (
    p_event_group_id    => p_event_group_id
   ,p_object_version_number => p_object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck_event_group;
*/
--
--
end pay_event_groups_api;

/
