--------------------------------------------------------
--  DDL for Package Body OTA_CHAT_USER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CHAT_USER_API" as
/*$Header: otcusapi.pkb 120.1 2005/08/03 16:30 asud noship $*/
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_CHAT_USER_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_CHAT_USER >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_chat_user (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_login_date                     in  date
  ,p_business_group_id            in  number
  ,p_object_version_number        out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_chat_user';
  l_object_version_number   number;
  l_effective_date          date;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_CHAT_USER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
    begin
  ota_chat_user_bk1.create_chat_user_b
  ( p_chat_id                   => p_chat_id
  ,p_person_id                 => p_person_id
  ,p_contact_id                => p_contact_id
  ,p_effective_date            => p_effective_date
  ,p_business_group_id         => p_business_group_id
  ,p_login_date                  => p_login_date
  ,p_object_version_number     => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CHAT_USER'
        ,p_hook_type   => 'BP'
        );
  end;

  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_cus_ins.ins
  (
   p_chat_id                   => p_chat_id
  ,p_person_id                 => p_person_id
  ,p_contact_id                => p_contact_id
  ,p_effective_date            => p_effective_date
  ,p_business_group_id         => p_business_group_id
  ,p_login_date                  => p_login_date
  ,p_object_version_number     => p_object_version_number
  );

  --
  -- Call After Process User Hook
    begin
  ota_chat_user_bk1.create_chat_user_a
  ( p_chat_id                   => p_chat_id
  ,p_person_id                 => p_person_id
  ,p_contact_id                => p_contact_id
  ,p_effective_date            => p_effective_date
  ,p_business_group_id         => p_business_group_id
  ,p_login_date                  => p_login_date
  ,p_object_version_number     => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CHAT_USER'
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
    rollback to CREATE_CHAT_USER;
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
    rollback to CREATE_CHAT_USER;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_chat_user;

--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_CHAT_USER >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_chat_user (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number           default hr_api.g_number
  ,p_contact_id                   in  number           default hr_api.g_number
  ,p_login_date                   in  date
  ,p_business_group_id            in  number
  ,p_object_version_number        in out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_chat_user';
  l_object_version_number   number := p_object_version_number;
  l_effective_date          date := trunc(p_effective_date);
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_CHAT_USER;
  --
  -- Call Before Process User Hook
  --
    begin
  ota_chat_user_bk2.update_chat_user_b
  ( p_chat_id                  => p_chat_id
  ,p_person_id                 => p_person_id
  ,p_contact_id                => p_contact_id
  ,p_effective_date            => p_effective_date
  ,p_business_group_id         => p_business_group_id
  ,p_login_date                => p_login_date
  ,p_object_version_number     => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CHAT_USER'
        ,p_hook_type   => 'BP'
        );
  end;

  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_cus_upd.upd
  (
   p_chat_id                   => p_chat_id
  ,p_person_id                 => p_person_id
  ,p_contact_id                => p_contact_id
  ,p_effective_date            => l_effective_date
  ,p_business_group_id         => p_business_group_id
  ,p_login_date                => p_login_date
  ,p_object_version_number     => l_object_version_number
  );

  --
  -- Call After Process User Hook
    begin
  ota_chat_user_bk2.update_chat_user_a
  ( p_chat_id                  => p_chat_id
  ,p_person_id                 => p_person_id
  ,p_contact_id                => p_contact_id
  ,p_effective_date            => l_effective_date
  ,p_business_group_id         => p_business_group_id
  ,p_login_date                => p_login_date
  ,p_object_version_number     => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CHAT_USER'
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
    rollback to UPDATE_CHAT_USER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_CHAT_USER;
    p_object_version_number   := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_chat_user;

-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_CHAT_USER >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_chat_user
  (p_validate                      in     boolean  default false
  ,p_chat_id                      in     number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete_chat';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_CHAT_USER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  begin
  ota_chat_user_bk3.delete_chat_user_b
  (p_chat_id        => p_chat_id
  ,p_person_id      => p_person_id
  ,p_contact_id     => p_contact_id
  ,p_object_version_number   => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CHAT_USER'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_cus_del.del
  (p_chat_id        => p_chat_id
  ,p_person_id      => p_person_id
  ,p_contact_id     => p_contact_id
  ,p_object_version_number   => p_object_version_number
  );


  --
  -- Call After Process User Hook
  begin
  ota_chat_user_bk3.delete_chat_user_a
  (p_chat_id        => p_chat_id
  ,p_person_id      => p_person_id
  ,p_contact_id     => p_contact_id
  ,p_object_version_number   => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CHAT_USER'
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
    rollback to DELETE_CHAT_USER;
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
    rollback to DELETE_CHAT_USER;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_chat_user;
--
end ota_chat_user_api;

/
