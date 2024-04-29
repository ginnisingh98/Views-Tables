--------------------------------------------------------
--  DDL for Package Body OTA_OPEN_FC_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OPEN_FC_ENROLLMENT_API" as
/* $Header: otfceapi.pkb 120.1 2005/08/10 15:03 asud noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_OPEN_FC_ENROLLMENT_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_OPEN_FC_ENROLLMENT    >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_open_fc_enrollment
(  p_validate                  in boolean default false
    ,p_effective_date               in     date
    ,p_business_group_id              in     number
    ,p_forum_id                       in     number   default null
    ,p_person_id                      in     number   default null
    ,p_contact_id                     in     number   default null
    ,p_chat_id                        in     number   default null
    ,p_enrollment_id                     out nocopy number
    ,p_object_version_number             out nocopy number
    ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_open_fc_enrollment';
  l_enrollment_id number;
  l_object_version_number   number;
  l_effective_date date;


 l_mode varchar2(1);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_OPEN_FC_ENROLLMENT;
  l_effective_date := trunc(p_effective_date);


  begin
  OTA_OPEN_FC_ENROLLMENT_bk1.create_open_fc_enrollment_b
  (  p_effective_date               => p_effective_date
      ,p_business_group_id    => p_business_group_id
      ,p_forum_id             => p_forum_id
      ,p_person_id            => p_person_id
      ,p_contact_id           => p_contact_id
      ,p_chat_id              => p_chat_id
    ,p_object_version_number  => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OPEN_FC_ENROLLMENT'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_fce_ins.ins
  (   p_effective_date         => l_effective_date
      ,p_business_group_id  => p_business_group_id
      ,p_forum_id           => p_forum_id
      ,p_person_id          => p_person_id
      ,p_contact_id         => p_contact_id
      ,p_chat_id            => p_chat_id
      ,p_enrollment_id      => l_enrollment_id
    ,p_object_version_number => l_object_version_number
  );
  --
  -- Set all output arguments
  --
  p_enrollment_id  := l_enrollment_id;
  p_object_version_number   := l_object_version_number;



  begin
  OTA_OPEN_FC_ENROLLMENT_bk1.create_open_fc_enrollment_a
   ( p_effective_date               => p_effective_date
      ,p_business_group_id    => p_business_group_id
      ,p_forum_id             => p_forum_id
      ,p_person_id            => p_person_id
      ,p_contact_id           => p_contact_id
      ,p_chat_id              => p_chat_id
      ,p_enrollment_id        => p_enrollment_id
    ,p_object_version_number  => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OPEN_FC_ENROLLMENT'
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
    rollback to CREATE_OPEN_FC_ENROLLMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_enrollment_id  := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_OPEN_FC_ENROLLMENT;
    p_enrollment_id  := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_open_fc_enrollment;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_OPEN_FC_ENROLLMENT >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_open_fc_enrollment
  ( p_validate                     in  boolean          default false
    ,p_effective_date               in     date
    ,p_enrollment_id                in     number
    ,p_business_group_id            in     number    default hr_api.g_number
    ,p_forum_id                     in     number    default hr_api.g_number
    ,p_person_id                    in     number    default hr_api.g_number
    ,p_contact_id                   in     number    default hr_api.g_number
    ,p_chat_id                      in     number    default hr_api.g_number
    ,p_object_version_number        in out nocopy number   ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_open_fc_enrollment';
  l_object_version_number   number := p_object_version_number;
  l_effective_date date;


 l_mode varchar2(1);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_OPEN_FC_ENROLLMENT;
  l_effective_date := trunc(p_effective_date);

  begin
  OTA_OPEN_FC_ENROLLMENT_bk2.update_open_fc_enrollment_b
  (   p_effective_date      => p_effective_date
    ,p_enrollment_id        =>  p_enrollment_id
    ,p_business_group_id    =>  p_business_group_id
    ,p_forum_id             => p_forum_id
    ,p_person_id            =>   p_person_id
    ,p_contact_id           =>   p_contact_id
    ,p_chat_id              => p_chat_id
    ,p_object_version_number => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OPEN_FC_ENROLLMENT'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Process Logic
  --

 ota_fce_upd.upd
  (
   p_effective_date      => l_effective_date
    ,p_enrollment_id        =>  p_enrollment_id
    ,p_business_group_id    =>  p_business_group_id
    ,p_forum_id             => p_forum_id
    ,p_person_id            =>   p_person_id
    ,p_contact_id           =>   p_contact_id
    ,p_chat_id              => p_chat_id
    ,p_object_version_number => p_object_version_number
  );


  begin
  OTA_OPEN_FC_ENROLLMENT_bk2.update_open_fc_enrollment_a
  (  p_effective_date      => p_effective_date
    ,p_enrollment_id        =>  p_enrollment_id
    ,p_business_group_id    =>  p_business_group_id
    ,p_forum_id             => p_forum_id
    ,p_person_id            =>   p_person_id
    ,p_contact_id           =>   p_contact_id
    ,p_chat_id              => p_chat_id
    ,p_object_version_number => p_object_version_number   );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OPEN_FC_ENROLLMENT'
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
    rollback to UPDATE_OPEN_FC_ENROLLMENT;
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_OPEN_FC_ENROLLMENT;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_open_fc_enrollment;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_OPEN_FC_ENROLLMENT >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_open_fc_enrollment
  (p_validate                      in     boolean  default false
  ,p_enrollment_id        in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' delete_open_fc_enrollment';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_OPEN_FC_ENROLLMENT ;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  OTA_OPEN_FC_ENROLLMENT_bk3.delete_open_fc_enrollment_b
  (p_enrollment_id         => p_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OPEN_FC_ENROLLMENT'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  ota_fce_del.del
  (
  p_enrollment_id   => p_enrollment_id,
  p_object_version_number    => p_object_version_number
  );


  begin
  OTA_OPEN_FC_ENROLLMENT_bk3.delete_open_fc_enrollment_a
  (p_enrollment_id             => p_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OPEN_FC_ENROLLMENT'
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
    rollback to DELETE_OPEN_FC_ENROLLMENT ;
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
    rollback to DELETE_OPEN_FC_ENROLLMENT ;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_open_fc_enrollment;
--
end OTA_OPEN_FC_ENROLLMENT_API;

/
