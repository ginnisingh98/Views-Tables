--------------------------------------------------------
--  DDL for Package Body OTA_PVT_FRM_THREAD_USERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_PVT_FRM_THREAD_USERS_API" as
/* $Header: otftuapi.pkb 120.1 2005/08/10 17:50 asud noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_PVT_FRM_THREAD_USERS_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pvt_frm_thread_user>------------------|
-- ----------------------------------------------------------------------------
--
   procedure create_pvt_frm_thread_user(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_thread_id              in  number
  ,p_forum_id                     in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_business_group_id            in number
  ,p_author_person_id             in number default null
  ,p_author_contact_id            in number default null
  ,p_object_version_number        out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_pvt_frm_thread_user ';
  l_object_version_number   number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_pvt_frm_thread_user;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  --
    begin
    OTA_PVT_FRM_THREAD_USERS_bk1.create_pvt_frm_thread_user_b
    (  p_effective_date             => p_effective_date
    ,p_forum_thread_id            => p_forum_thread_id
    ,p_forum_id                   => p_forum_id
    ,p_person_id                  => p_person_id
    ,p_contact_id                 => p_contact_id
    ,p_business_group_id          => p_business_group_id
    ,p_author_person_id           => p_author_person_id
    ,p_author_contact_id          => p_author_contact_id
    ,p_object_version_number      => p_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'CREATE_PVT_FRM_THREAD_USER'
          ,p_hook_type   => 'BP'
          );
    end;

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_ftu_ins.ins
  (  p_effective_date             => l_effective_date
    ,p_forum_thread_id            => p_forum_thread_id
    ,p_forum_id                   => p_forum_id
    ,p_person_id                  => p_person_id
    ,p_contact_id                 => p_contact_id
    ,p_business_group_id          => p_business_group_id
    ,p_author_person_id           => p_author_person_id
    ,p_author_contact_id          => p_author_contact_id
    ,p_object_version_number      => l_object_version_number
  );


  --
  -- Call After Process User Hook
    begin
  OTA_PVT_FRM_THREAD_USERS_bk1.create_pvt_frm_thread_user_a
   ( p_effective_date             => p_effective_date
    ,p_forum_thread_id            => p_forum_thread_id
    ,p_forum_id                   => p_forum_id
    ,p_person_id                  => p_person_id
    ,p_contact_id                 => p_contact_id
    ,p_business_group_id          => p_business_group_id
    ,p_author_person_id           => p_author_person_id
    ,p_author_contact_id          => p_author_contact_id
    ,p_object_version_number      => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PVT_FRM_THREAD_USER'
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
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_pvt_frm_thread_user;
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
    rollback to create_pvt_frm_thread_user;
    p_object_version_number :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_pvt_frm_thread_user ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_pvt_frm_thread_user>------------------|
-- ----------------------------------------------------------------------------
--
   procedure update_pvt_frm_thread_user(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_thread_id              in  number
  ,p_forum_id                     in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_business_group_id            in number
  ,p_author_person_id             in number default null
  ,p_author_contact_id            in number default null
  ,p_object_version_number        in out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_pvt_frm_thread_user ';
  l_object_version_number   number:= p_object_version_number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_pvt_frm_thread_user;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  --
    begin
    OTA_PVT_FRM_THREAD_USERS_bk2.update_pvt_frm_thread_user_b
    (  p_effective_date             => p_effective_date
    ,p_forum_thread_id            => p_forum_thread_id
    ,p_forum_id                   => p_forum_id
    ,p_person_id                  => p_person_id
    ,p_contact_id                 => p_contact_id
    ,p_business_group_id          => p_business_group_id
    ,p_author_person_id           => p_author_person_id
    ,p_author_contact_id          => p_author_contact_id
    ,p_object_version_number      => p_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'UPDATE_PVT_FRM_THREAD_USER'
          ,p_hook_type   => 'BP'
          );
    end;

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_ftu_upd.upd
  (  p_effective_date             => l_effective_date
    ,p_forum_thread_id            => p_forum_thread_id
    ,p_forum_id                   => p_forum_id
    ,p_person_id                  => p_person_id
    ,p_contact_id                 => p_contact_id
    ,p_business_group_id          => p_business_group_id
    ,p_author_person_id           => p_author_person_id
    ,p_author_contact_id          => p_author_contact_id
    ,p_object_version_number      => l_object_version_number
  );


  --
  -- Call After Process User Hook
    begin
  OTA_PVT_FRM_THREAD_USERS_bk2.update_pvt_frm_thread_user_a
   ( p_effective_date             => p_effective_date
    ,p_forum_thread_id            => p_forum_thread_id
    ,p_forum_id                   => p_forum_id
    ,p_person_id                  => p_person_id
    ,p_contact_id                 => p_contact_id
    ,p_business_group_id          => p_business_group_id
    ,p_author_person_id           => p_author_person_id
    ,p_author_contact_id          => p_author_contact_id
    ,p_object_version_number      => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PVT_FRM_THREAD_USER'
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
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_pvt_frm_thread_user;
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
    rollback to update_pvt_frm_thread_user;
    p_object_version_number :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_pvt_frm_thread_user ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pvt_frm_thread_user >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pvt_frm_thread_user
(  p_validate                      in     boolean  default false
  ,p_forum_thread_id               in     number
  ,p_forum_id                      in     number
  ,p_person_id                     in     number
  ,p_contact_id                    in     number
  ,p_object_version_number         in     number

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' delete_pvt_frm_thread_user ';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pvt_frm_thread_user ;
  --
  -- Call Before Process User Hook
      begin
      OTA_PVT_FRM_THREAD_USERS_bk3.delete_pvt_frm_thread_user_b
      (  p_forum_thread_id =>p_forum_thread_id
     ,p_forum_id =>p_forum_id
     ,p_person_id =>p_person_id
     ,p_contact_id =>p_contact_id
     ,p_object_version_number =>p_object_version_number
        );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'DELETE_PVT_FRM_THREAD_USER'
            ,p_hook_type   => 'BP'
            );
      end;

--
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  OTA_ftu_del.del
    (p_forum_thread_id =>p_forum_thread_id
     ,p_forum_id =>p_forum_id
     ,p_person_id =>p_person_id
     ,p_contact_id =>p_contact_id
     ,p_object_version_number =>p_object_version_number
    );
  --
  -- Call After Process User Hook

      begin
    OTA_PVT_FRM_THREAD_USERS_bk3.delete_pvt_frm_thread_user_a
     ( p_forum_thread_id =>p_forum_thread_id
     ,p_forum_id =>p_forum_id
     ,p_person_id =>p_person_id
     ,p_contact_id =>p_contact_id
     ,p_object_version_number =>p_object_version_number
      );

    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'DELETE_PVT_FRM_THREAD_USER'
          ,p_hook_type   => 'AP'
          );
    end;

  --
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
    rollback to delete_pvt_frm_thread_user ;
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
    rollback to delete_pvt_frm_thread_user ;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_pvt_frm_thread_user;
--
end OTA_PVT_FRM_THREAD_USERS_API;

/
