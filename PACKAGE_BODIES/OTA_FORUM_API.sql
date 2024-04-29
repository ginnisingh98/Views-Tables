--------------------------------------------------------
--  DDL for Package Body OTA_FORUM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FORUM_API" as
/* $Header: otfrmapi.pkb 120.1 2005/08/10 15:05 asud noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_FORUM_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_FORUM >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_forum(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2         default null
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date             default null
  ,p_end_date_active              in  date             default null
  ,p_message_type_flag            in  varchar2         default 'P'
  ,p_allow_html_flag              in  varchar2         default 'N'
  ,p_allow_attachment_flag        in  varchar2         default 'N'
  ,p_auto_notification_flag       in  varchar2         default 'N'
  ,p_public_flag                  in  varchar2         default 'N'
  ,p_forum_id                     out nocopy number
  ,p_object_version_number        out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create_forum';
  l_forum_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_FORUM;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
     begin
  ota_forum_bk1.create_forum_b
  (  p_effective_date              => p_effective_date
   ,p_name                          => p_name
   ,p_description                   => p_description
  ,p_business_group_id             => p_business_group_id
  ,p_message_type_flag		   => p_message_type_flag
  ,p_allow_html_flag		   => p_allow_html_flag
  ,p_allow_attachment_flag         => p_allow_attachment_flag
  ,p_auto_notification_flag        => p_auto_notification_flag
  ,p_public_flag                   => p_public_flag
  ,p_start_date_active             => p_start_date_active
  ,p_end_date_active               => p_end_date_active
  ,p_object_version_number         => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FORUM'
        ,p_hook_type   => 'BP'
        );
  end;

  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_frm_ins.ins
  (  p_effective_date              => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_message_type_flag		   => p_message_type_flag
  ,p_allow_html_flag		   => p_allow_html_flag
  ,p_allow_attachment_flag         => p_allow_attachment_flag
  ,p_auto_notification_flag        => p_auto_notification_flag
  ,p_public_flag                   => p_public_flag
  ,p_start_date_active             => p_start_date_active
  ,p_end_date_active               => p_end_date_active
  ,p_forum_id                      => l_forum_id
  ,p_object_version_number         => l_object_version_number
  );

   ota_fmt_ins.ins_tl
    (
      p_effective_date      => l_effective_date
  ,p_language_code          => USERENV('LANG')
  ,p_forum_id         => l_forum_id
  ,p_name             => p_name
  ,p_description      => p_description
    );
  --
  -- Call After Process User Hook
  --
     begin
  ota_forum_bk1.create_forum_a
  (  p_effective_date              => p_effective_date
   ,p_name                          => p_name
   ,p_description                   => p_description
  ,p_business_group_id             => p_business_group_id
  ,p_message_type_flag		   => p_message_type_flag
  ,p_allow_html_flag		   => p_allow_html_flag
  ,p_allow_attachment_flag         => p_allow_attachment_flag
  ,p_auto_notification_flag        => p_auto_notification_flag
  ,p_public_flag                   => p_public_flag
  ,p_start_date_active             => p_start_date_active
  ,p_end_date_active               => p_end_date_active
  ,p_forum_id                      => p_forum_id
  ,p_object_version_number         => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FORUM'
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
  p_forum_id                := l_forum_id;
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_FORUM;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_forum_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_FORUM;
    p_forum_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_forum;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_forum >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_forum
  (p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date             default hr_api.g_date
  ,p_end_date_active              in  date             default hr_api.g_date
  ,p_message_type_flag            in  varchar2         default hr_api.g_varchar2
  ,p_allow_html_flag              in  varchar2         default hr_api.g_varchar2
  ,p_allow_attachment_flag        in  varchar2         default hr_api.g_varchar2
  ,p_auto_notification_flag       in  varchar2         default hr_api.g_varchar2
  ,p_public_flag                  in  varchar2         default hr_api.g_varchar2
  ,p_forum_id                     in  number
  ,p_object_version_number        in out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Forum';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_FORUM;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  ota_forum_bk2.update_forum_b
  (p_effective_date               => p_effective_date
     ,p_name                          => p_name
   ,p_description                   => p_description
   ,p_business_group_id             => p_business_group_id
   ,p_message_type_flag	 	    => p_message_type_flag
   ,p_allow_html_flag	  	    => p_allow_html_flag
   ,p_allow_attachment_flag         => p_allow_attachment_flag
   ,p_auto_notification_flag        => p_auto_notification_flag
   ,p_public_flag                   => p_public_flag
   ,p_start_date_active             => p_start_date_active
   ,p_end_date_active               => p_end_date_active
   ,p_forum_id                      => p_forum_id
   ,p_object_version_number         => p_object_version_number
   );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FORUM'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_frm_upd.upd
    (p_effective_date               => l_effective_date
   ,p_business_group_id             => p_business_group_id
   ,p_message_type_flag	 	    => p_message_type_flag
   ,p_allow_html_flag	  	    => p_allow_html_flag
   ,p_allow_attachment_flag         => p_allow_attachment_flag
   ,p_auto_notification_flag        => p_auto_notification_flag
   ,p_public_flag                   => p_public_flag
   ,p_start_date_active             => p_start_date_active
   ,p_end_date_active               => p_end_date_active
   ,p_forum_id                      => p_forum_id
   ,p_object_version_number         => p_object_version_number    );

  ota_fmt_upd.upd_tl( p_effective_date      => l_effective_date
  ,p_language_code          => USERENV('LANG')
  ,p_forum_id        => p_forum_id
  ,p_name     => p_name
  ,p_description      => p_description  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_forum_bk2.update_forum_a
  (p_effective_date               => p_effective_date
   ,p_name                          => p_name
   ,p_description                   => p_description
   ,p_business_group_id             => p_business_group_id
   ,p_message_type_flag	 	    => p_message_type_flag
   ,p_allow_html_flag	  	    => p_allow_html_flag
   ,p_allow_attachment_flag         => p_allow_attachment_flag
   ,p_auto_notification_flag        => p_auto_notification_flag
   ,p_public_flag                   => p_public_flag
   ,p_start_date_active             => p_start_date_active
   ,p_end_date_active               => p_end_date_active
   ,p_forum_id                      => p_forum_id
   ,p_object_version_number         => p_object_version_number
   );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FORUM'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_FORUM;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_FORUM;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_forum;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_FORUM >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_forum
  (p_validate                      in     boolean  default false
  ,p_forum_id               in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete_forum';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_FORUM;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  begin
  ota_forum_bk3.delete_forum_b
  (p_forum_id        => p_forum_id
  ,p_object_version_number   => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FORUM'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_fmt_del.del_tl
  (p_forum_id        => p_forum_id
   --,p_language =>  USERENV('LANG')
  );

  ota_frm_del.del
  (p_forum_id        => p_forum_id
  ,p_object_version_number   => p_object_version_number
  );


  --
  -- Call After Process User Hook
  begin
  ota_forum_bk3.delete_forum_a
  (p_forum_id        => p_forum_id
  ,p_object_version_number   => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FORUM'
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
    rollback to DELETE_FORUM;
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
    rollback to DELETE_FORUM;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_forum;
--
end ota_forum_api;

/
