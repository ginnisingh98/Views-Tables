--------------------------------------------------------
--  DDL for Package Body OTA_FRM_NOTIF_SUBSCRIBER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FRM_NOTIF_SUBSCRIBER_API" as
/* $Header: otfnsapi.pkb 120.0 2005/06/24 07:55 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_FRM_NOTIF_SUBSCRIBER_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_FRM_NOTIF_SUBSCRIBER    >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_frm_notif_subscriber
  ( p_validate                     in boolean          default false
    ,p_effective_date               in     date
   ,p_business_group_id              in     number
   ,p_forum_id                          in  number
   ,p_person_id                         in  number
   ,p_contact_id                        in  number
   ,p_object_version_number             out nocopy number
  ) is

  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_frm_notif_subscriber';
  l_object_version_number   number;
  l_effective_date date;


 l_mode varchar2(1);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_FRM_NOTIF_SUBSCRIBER;
  l_effective_date := trunc(p_effective_date);


  begin
  OTA_FRM_NOTIF_SUBSCRIBER_bk1.create_frm_notif_subscriber_b
  (  p_effective_date               => p_effective_date
      ,p_business_group_id    => p_business_group_id
      ,p_forum_id             => p_forum_id
      ,p_person_id            => p_person_id
      ,p_contact_id           => p_contact_id
    ,p_object_version_number  => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FRM_NOTIF_SUBSCRIBER'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_fns_ins.ins
    (  p_effective_date             => l_effective_date
      ,p_business_group_id          => p_business_group_id
      ,p_forum_id                   => p_forum_id
      ,p_person_id                  => p_person_id
      ,p_contact_id                 => p_contact_id
      ,p_object_version_number      => l_object_version_number
    );

  --
  -- Set all output arguments
  --
  p_object_version_number   := l_object_version_number;



  begin
  OTA_FRM_NOTIF_SUBSCRIBER_bk1.create_frm_notif_subscriber_a
   ( p_effective_date               => p_effective_date
      ,p_business_group_id    => p_business_group_id
      ,p_forum_id             => p_forum_id
      ,p_person_id            => p_person_id
      ,p_contact_id           => p_contact_id
    ,p_object_version_number  => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FRM_NOTIF_SUBSCRIBER'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_FRM_NOTIF_SUBSCRIBER;
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
    rollback to CREATE_FRM_NOTIF_SUBSCRIBER;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_frm_notif_subscriber;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_FRM_NOTIF_SUBSCRIBER >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_frm_notif_subscriber
  (p_validate                     in boolean          default false
    ,p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_frm_notif_subscriber';
  l_object_version_number   number := p_object_version_number;
  l_effective_date date;


 l_mode varchar2(1);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_FRM_NOTIF_SUBSCRIBER;
  l_effective_date := trunc(p_effective_date);

  begin
  OTA_FRM_NOTIF_SUBSCRIBER_bk2.update_frm_notif_subscriber_b
  (   p_effective_date      => p_effective_date
    ,p_forum_id             => p_forum_id
    ,p_person_id            =>   p_person_id
    ,p_contact_id           =>   p_contact_id
    ,p_object_version_number => p_object_version_number
    ,p_business_group_id    =>  p_business_group_id
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FRM_NOTIF_SUBSCRIBER'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Process Logic
  --

 ota_fns_upd.upd
  (
   p_effective_date      => l_effective_date
    ,p_forum_id             => p_forum_id
    ,p_person_id            =>   p_person_id
    ,p_contact_id           =>   p_contact_id
    ,p_object_version_number => p_object_version_number
    ,p_business_group_id    =>  p_business_group_id
  );


  begin
  OTA_FRM_NOTIF_SUBSCRIBER_bk2.update_frm_notif_subscriber_a
  (   p_effective_date      => p_effective_date
    ,p_forum_id             => p_forum_id
    ,p_person_id            =>   p_person_id
    ,p_contact_id           =>   p_contact_id
    ,p_object_version_number => p_object_version_number
    ,p_business_group_id    =>  p_business_group_id
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FRM_NOTIF_SUBSCRIBER'
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
  p_object_version_number  := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_FRM_NOTIF_SUBSCRIBER;
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_FRM_NOTIF_SUBSCRIBER;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_frm_notif_subscriber;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DEELTE_FRM_NOTIF_SUBSCRIBER >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_frm_notif_subscriber
  (p_validate                      in     boolean
  ,p_forum_id                             in     number
  ,p_person_id                            in     number
  ,p_contact_id                           in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' delete_frm_notif_subscriber';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DEELTE_FRM_NOTIF_SUBSCRIBER ;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  OTA_FRM_NOTIF_SUBSCRIBER_bk3.delete_frm_notif_subscriber_b
  (p_forum_id      => p_forum_id
  ,p_person_id    => p_person_id
  ,p_contact_id   => p_contact_id
  ,p_object_version_number    => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DEELTE_FRM_NOTIF_SUBSCRIBER'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  ota_fns_del.del
  (
  p_forum_id      => p_forum_id
  ,p_person_id    => p_person_id
  ,p_contact_id   => p_contact_id
  ,p_object_version_number    => p_object_version_number
  );


  begin
  OTA_FRM_NOTIF_SUBSCRIBER_bk3.delete_frm_notif_subscriber_a
  (  p_forum_id      => p_forum_id
  ,p_person_id    => p_person_id
  ,p_contact_id   => p_contact_id
  ,p_object_version_number    => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DEELTE_FRM_NOTIF_SUBSCRIBER'
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
    rollback to DEELTE_FRM_NOTIF_SUBSCRIBER ;
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
    rollback to DEELTE_FRM_NOTIF_SUBSCRIBER ;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_frm_notif_subscriber;
--
end OTA_FRM_NOTIF_SUBSCRIBER_API;

/
