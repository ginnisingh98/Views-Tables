--------------------------------------------------------
--  DDL for Package Body OTA_CHAT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CHAT_API" as
/* $Header: otchaapi.pkb 120.3 2006/03/06 02:25 rdola noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_CHAT_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_CHAT >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_chat(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2         default null
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date             default null
  ,p_end_date_active              in  date             default null
  ,p_start_time_active            in  varchar2         default null
  ,p_end_time_active              in  varchar2         default NULL
  ,p_timezone_code                in  varchar2         default NULL
  ,p_public_flag                  in  varchar2         default 'N'
  ,p_chat_id                     out nocopy number
  ,p_object_version_number        out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create_chat';
  l_chat_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_CHAT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
ota_chat_bk1.create_chat_b
(
  p_effective_date
  ,p_name
  ,p_description
  ,p_business_group_id
  ,p_start_date_active
  ,p_end_date_active
  ,p_start_time_active
  ,p_end_time_active
  ,p_timezone_code
  ,p_public_flag
  ,p_object_version_number);

  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_cha_ins.ins
  (  p_effective_date              => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_public_flag                   => p_public_flag
  ,p_start_date_active             => p_start_date_active
  ,p_end_date_active               => p_end_date_active
  ,p_start_time_active             => p_start_time_active
  ,p_end_time_active               => p_end_time_active
  ,p_timezone_code                 => p_timezone_code
  ,p_chat_id                      => l_chat_id
  ,p_object_version_number         => l_object_version_number
  );

   ota_cht_ins.ins_tl
    (
      p_effective_date      => l_effective_date
  ,p_language_code          => USERENV('LANG')
  ,p_chat_id         => l_chat_id
  ,p_name             => p_name
  ,p_description      => p_description
    );
  --
  -- Call After Process User Hook
  --
ota_chat_bk1.create_chat_a
(
   p_effective_date
  ,p_name
  ,p_description
  ,p_business_group_id
  ,p_start_date_active
  ,p_end_date_active
  ,p_start_time_active
  ,p_end_time_active
  ,p_timezone_code
  ,p_public_flag
  ,p_chat_id
  ,p_object_version_number);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_chat_id                := l_chat_id;
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_CHAT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_chat_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_CHAT;
    p_chat_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_chat;


-- ----------------------------------------------------------------------------
-- |----------------------------< update_chat >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_chat
  (p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date             default hr_api.g_date
  ,p_end_date_active              in  date             default hr_api.g_date
  ,p_start_time_active            in  varchar2         default hr_api.g_varchar2
  ,p_end_time_active              in  varchar2         default hr_api.g_varchar2
  ,p_timezone_code                in  varchar2         default hr_api.g_varchar2
  ,p_public_flag                  in  varchar2         default hr_api.g_varchar2
  ,p_chat_id                     in  number
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
  savepoint UPDATE_CHAT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
ota_chat_bk2.update_chat_b
  (
  p_effective_date
  ,p_name
  ,p_description
  ,p_business_group_id
  ,p_start_date_active
  ,p_end_date_active
  ,p_start_time_active
  ,p_end_time_active
  ,p_timezone_code
  ,p_public_flag
  ,p_chat_id
  ,p_object_version_number);

  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_cha_upd.upd
    (p_effective_date               => l_effective_date
   ,p_business_group_id             => p_business_group_id
   ,p_public_flag                   => p_public_flag
   ,p_start_date_active             => p_start_date_active
   ,p_end_date_active               => p_end_date_active
   ,p_start_time_active             => p_start_time_active
   ,p_end_time_active               => p_end_time_active
   ,p_timezone_code                 => p_timezone_code
   ,p_chat_id                      => p_chat_id
   ,p_object_version_number         => p_object_version_number    );

  ota_cht_upd.upd_tl( p_effective_date      => l_effective_date
  ,p_language_code          => USERENV('LANG')
  ,p_chat_id        => p_chat_id
  ,p_name     => p_name
  ,p_description      => p_description  );
  --
  -- Call After Process User Hook
  --
ota_chat_bk2.update_chat_a
  (
  p_effective_date
  ,p_name
  ,p_description
  ,p_business_group_id
  ,p_start_date_active
  ,p_end_date_active
  ,p_start_time_active
  ,p_end_time_active
  ,p_timezone_code
  ,p_public_flag
  ,p_chat_id
  ,p_object_version_number);

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
    rollback to UPDATE_CHAT;
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
    rollback to UPDATE_CHAT;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_chat;



-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_CHAT >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_chat
  (p_validate                      in     boolean  default false
  ,p_chat_id               in     number
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
  savepoint DELETE_CHAT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  --
  ota_chat_bk3.delete_chat_b
    (
     p_chat_id
    ,p_object_version_number
  );
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_cht_del.del_tl
  (p_chat_id        => p_chat_id
   --,p_language =>  USERENV('LANG')
  );

  ota_cha_del.del
  (p_chat_id        => p_chat_id
  ,p_object_version_number   => p_object_version_number
  );


  --
  -- Call After Process User Hook
  --
    ota_chat_bk3.delete_chat_a
      (
       p_chat_id
      ,p_object_version_number
    );

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
    rollback to DELETE_CHAT;
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
    rollback to DELETE_CHAT;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_chat;

--
end ota_chat_api;

/
