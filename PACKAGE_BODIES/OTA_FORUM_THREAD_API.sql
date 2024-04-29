--------------------------------------------------------
--  DDL for Package Body OTA_FORUM_THREAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FORUM_THREAD_API" as
/* $Header: otftsapi.pkb 120.2 2005/08/10 16:47 asud noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_FORUM_THREAD_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_FORUM_THREAD >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_forum_thread(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_id                       in     number
  ,p_business_group_id              in     number
  ,p_subject                        in     varchar2
  ,p_private_thread_flag            in     varchar2
  ,p_last_post_date                 in     date     default null
  ,p_reply_count                    in     number   default null
  ,p_forum_thread_id                   out nocopy number
  ,p_object_version_number             out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create_forum_thread';
  l_forum_thread_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_FORUM_THREAD;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
    begin
  ota_forum_thread_bk1.create_forum_thread_b
  (p_effective_date               => p_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_business_group_id            => p_business_group_id
    ,p_subject                      => p_subject
    ,p_private_thread_flag          => p_private_thread_flag
    ,p_last_post_date               => p_last_post_date
    ,p_reply_count                  => p_reply_count
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FORUM_THREAD'
        ,p_hook_type   => 'BP'
        );
  end;


  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_fts_ins.ins
  (  p_effective_date               => l_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_business_group_id            => p_business_group_id
    ,p_subject                      => p_subject
    ,p_private_thread_flag          => p_private_thread_flag
    ,p_last_post_date               => p_last_post_date
    ,p_reply_count                  => p_reply_count
    ,p_forum_thread_id              => l_forum_thread_id
    ,p_object_version_number        => l_object_version_number
   );


  --
  -- Call After Process User Hook
    begin
  ota_forum_thread_bk1.create_forum_thread_a
  (p_effective_date               => p_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_business_group_id            => p_business_group_id
    ,p_subject                      => p_subject
    ,p_private_thread_flag          => p_private_thread_flag
    ,p_last_post_date               => p_last_post_date
    ,p_reply_count                  => p_reply_count
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FORUM_THREAD'
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
  p_forum_thread_id                := l_forum_thread_id;
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_FORUM_THREAD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_forum_thread_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_FORUM_THREAD;
    p_forum_thread_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_forum_thread;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_FORUM_THREAD >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_forum_thread(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_id                       in     number
  ,p_business_group_id              in     number
  ,p_subject                        in     varchar2
  ,p_private_thread_flag            in     varchar2
  ,p_last_post_date                 in     date     default null
  ,p_reply_count                    in     number   default null
  ,p_forum_thread_id                in number
  ,p_object_version_number          in out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update_forum_thread';
  l_object_version_number   number := p_object_version_number;
  l_effective_date          date;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_FORUM_THREAD;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
    begin
  ota_forum_thread_bk2.update_forum_thread_b
  (p_effective_date               => l_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_business_group_id            => p_business_group_id
    ,p_subject                      => p_subject
    ,p_private_thread_flag          => p_private_thread_flag
    ,p_last_post_date               => p_last_post_date
    ,p_reply_count                  => p_reply_count
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_object_version_number        => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FORUM_THREAD'
        ,p_hook_type   => 'BP'
        );
  end;


  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_fts_upd.upd
  (  p_effective_date               => l_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_business_group_id            => p_business_group_id
    ,p_subject                      => p_subject
    ,p_private_thread_flag          => p_private_thread_flag
    ,p_last_post_date               => p_last_post_date
    ,p_reply_count                  => p_reply_count
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_object_version_number        => l_object_version_number
   );


  --
  -- Call After Process User Hook
    begin
  ota_forum_thread_bk2.update_forum_thread_a
  (p_effective_date               => p_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_business_group_id            => p_business_group_id
    ,p_subject                      => p_subject
    ,p_private_thread_flag          => p_private_thread_flag
    ,p_last_post_date               => p_last_post_date
    ,p_reply_count                  => p_reply_count
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_object_version_number        => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FORUM_THREAD'
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
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_FORUM_THREAD;
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
    rollback to UPDATE_FORUM_THREAD;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_forum_thread;
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_FORUM_THREAD > --------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_forum_thread
  (p_validate                      in     boolean  default false
  ,p_forum_thread_id               in     number
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
        where forum_thread_id = p_forum_thread_id;

  --
  l_proc                    varchar2(72) := g_package||' Delete_forum_thread';
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
  savepoint DELETE_FORUM_THREAD;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  begin
  ota_forum_thread_bk3.delete_forum_thread_b
  (p_forum_thread_id        => p_forum_thread_id
  ,p_object_version_number   => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FORUM_THREAD'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  --delete all the messages first
  OPEN csr_child_message;
  FETCH csr_child_message into v_forum_message_id, v_object_version_number;

  LOOP
  Exit When csr_child_message%notfound OR csr_child_message%notfound is null;

  --ota_forum_message_api.delete_forum_message(p_validate,v_forum_message_id,v_object_version_number);
  ota_fms_del.del
    (p_forum_message_id        => v_forum_message_id
    ,p_object_version_number   => v_object_version_number
    );

  FETCH csr_child_message into v_forum_message_id, v_object_version_number;
  End Loop;
  Close csr_child_message;

  --delete the given forum thread
  ota_fts_del.del
  (p_forum_thread_id        => p_forum_thread_id
  ,p_object_version_number   => p_object_version_number
  );


  --
  -- Call After Process User Hook
  begin
  ota_forum_thread_bk3.delete_forum_thread_a
  (p_forum_thread_id        => p_forum_thread_id
  ,p_object_version_number   => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FORUM_THREAD'
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
    rollback to DELETE_FORUM_THREAD;
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
    rollback to DELETE_FORUM_THREAD;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_forum_thread;
--
end ota_forum_thread_api;

/
