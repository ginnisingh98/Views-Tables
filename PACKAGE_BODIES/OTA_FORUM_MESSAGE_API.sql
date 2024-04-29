--------------------------------------------------------
--  DDL for Package Body OTA_FORUM_MESSAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FORUM_MESSAGE_API" as
/* $Header: otfmsapi.pkb 120.4 2005/09/26 02:02 aabalakr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_FORUM_MESSAGE_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_FORUM_MESSAGE >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_forum_message(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_id                     in     number
  ,p_forum_thread_id              in     number
  ,p_business_group_id            in     number
  ,p_message_scope                in     varchar2
  ,p_message_body                 in     varchar2 default null
  ,p_parent_message_id            in     number   default null
  ,p_person_id                    in     number   default null
  ,p_contact_id                   in     number   default null
  ,p_target_person_id             in     number   default null
  ,p_target_contact_id            in     number   default null
  ,p_forum_message_id             out nocopy number
  ,p_object_version_number        out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create_forum_message';
  l_forum_message_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_FORUM_MESSAGE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  ota_forum_message_bk1.create_forum_message_b
  (p_effective_date               => p_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_business_group_id            => p_business_group_id
    ,p_message_scope                => p_message_scope
    ,p_message_body                 => p_message_body
    ,p_parent_message_id            => p_parent_message_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_target_person_id             => p_target_person_id
    ,p_target_contact_id            => p_target_contact_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FORUM_MESSAGE'
        ,p_hook_type   => 'BP'
        );
  end;

  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_fms_ins.ins
  (  p_effective_date               => l_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_business_group_id            => p_business_group_id
    ,p_message_scope                => p_message_scope
    ,p_message_body                 => p_message_body
    ,p_parent_message_id            => p_parent_message_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_target_person_id             => p_target_person_id
    ,p_target_contact_id            => p_target_contact_id
    ,p_forum_message_id             => l_forum_message_id
    ,p_object_version_number        => l_object_version_number
   );



  --
  -- Call After Process User Hook
  --
  begin
  ota_forum_message_bk1.create_forum_message_a
  (p_effective_date               => p_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_business_group_id            => p_business_group_id
    ,p_message_scope                => p_message_scope
    ,p_message_body                 => p_message_body
    ,p_parent_message_id            => p_parent_message_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_target_person_id             => p_target_person_id
    ,p_target_contact_id            => p_target_contact_id
    ,p_forum_message_id             => l_forum_message_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FORUM_MESSAGE'
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
  p_forum_message_id                := l_forum_message_id;
  p_object_version_number   := l_object_version_number;


 --Send notification only if the posted message scope is 'P'
   if(p_message_scope = 'P') then
	ota_initialization_wf.Init_forum_notif(p_forum_id => p_forum_id,
                p_forum_message_id => l_forum_message_id );
   end if;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_FORUM_MESSAGE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_forum_message_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_FORUM_MESSAGE;
    p_forum_message_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_forum_message;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_FORUM_MESSAGE >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_forum_message(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_id                     in  number   default hr_api.g_number
  ,p_forum_thread_id              in  number   default hr_api.g_number
  ,p_business_group_id            in  number   default hr_api.g_number
  ,p_message_scope                in  varchar2 default hr_api.g_varchar2
  ,p_message_body                 in  varchar2 default hr_api.g_varchar2
  ,p_parent_message_id            in  number   default hr_api.g_number
  ,p_person_id                    in  number   default hr_api.g_number
  ,p_contact_id                   in  number   default hr_api.g_number
  ,p_target_person_id             in  number   default hr_api.g_number
  ,p_target_contact_id            in  number   default hr_api.g_number
  ,p_forum_message_id             in  number
  ,p_object_version_number        in  out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create_forum_message';
  l_forum_message_id number;
  l_object_version_number   number := p_object_version_number;
  l_effective_date          date;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_FORUM_MESSAGE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  ota_forum_message_bk2.update_forum_message_b
    (p_effective_date               => l_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_business_group_id            => p_business_group_id
    ,p_message_scope                => p_message_scope
    ,p_message_body                 => p_message_body
    ,p_parent_message_id            => p_parent_message_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_target_person_id             => p_target_person_id
    ,p_target_contact_id            => p_target_contact_id
    ,p_forum_message_id             => p_forum_message_id
    ,p_object_version_number        => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FORUM_MESSAGE'
        ,p_hook_type   => 'BP'
        );
  end;

  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_fms_upd.upd
  (  p_effective_date               => l_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_business_group_id            => p_business_group_id
    ,p_message_scope                => p_message_scope
    ,p_message_body                 => p_message_body
    ,p_parent_message_id            => p_parent_message_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_target_person_id             => p_target_person_id
    ,p_target_contact_id            => p_target_contact_id
    ,p_forum_message_id             => p_forum_message_id
    ,p_object_version_number        => l_object_version_number
   );



  --
  -- Call After Process User Hook
  --
  begin
  ota_forum_message_bk2.update_forum_message_a
    (p_effective_date               => l_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_business_group_id            => p_business_group_id
    ,p_message_scope                => p_message_scope
    ,p_message_body                 => p_message_body
    ,p_parent_message_id            => p_parent_message_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_target_person_id             => p_target_person_id
    ,p_target_contact_id            => p_target_contact_id
    ,p_forum_message_id             => p_forum_message_id
    ,p_object_version_number        => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FORUM_MESSAGE'
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
    rollback to UPDATE_FORUM_MESSAGE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_FORUM_MESSAGE;
    p_object_version_number   := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_forum_message;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_FORUM_MESSAGE > -------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_forum_message
  (p_validate                      in     boolean  default false
  ,p_forum_message_id               in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR csr_child_message is
        SELECT
          forum_message_id,
          object_version_number
        FROM  ota_forum_messages
        connect by parent_message_id = prior forum_message_id
        start with forum_message_id = p_forum_message_id;

  --
  l_proc                    varchar2(72) := g_package||' Delete_forum_message';
  l_object_version_id       number;
  v_forum_message_id        number;
  v_object_version_number   number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_FORUM_MESSAGE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook

  begin
  ota_forum_message_bk3.delete_forum_message_b
  (p_forum_message_id       =>p_forum_message_id
  ,p_object_version_number   =>p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FORUM_MESSAGE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  --delete all the childern first
  OPEN csr_child_message;
  FETCH csr_child_message into v_forum_message_id, v_object_version_number;

  LOOP
  Exit When csr_child_message%notfound OR csr_child_message%notfound is null;

  ota_fms_del.del
    (p_forum_message_id        => v_forum_message_id
    ,p_object_version_number   => v_object_version_number
    );

  FETCH csr_child_message into v_forum_message_id, v_object_version_number;
  End Loop;
  Close csr_child_message;

  /*--delete the given forum message
  ota_fms_del.del
  (p_forum_message_id        => p_forum_message_id
  ,p_object_version_number   => p_object_version_number
  );*/


  --
  -- Call After Process User Hook
  begin
  ota_forum_message_bk3.delete_forum_message_a
  (p_forum_message_id       =>p_forum_message_id
  ,p_object_version_number   =>p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FORUM_MESSAGE'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_FORUM_MESSAGE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_FORUM_MESSAGE;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_forum_message;
--
end ota_forum_message_api;

/
