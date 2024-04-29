--------------------------------------------------------
--  DDL for Package Body OTA_ANNOUNCEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ANNOUNCEMENT_API" as
/* $Header: otancapi.pkb 115.1 2003/12/30 17:46:26 dhmulia noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_ANNOUNCEMENT_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_ANNOUNCEMEMT >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_announcement(
   p_validate                      in     boolean  default false
  ,p_effective_date               in     date
  ,p_announcement_title           in varchar2
  ,p_announcement_body            in varchar2
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
  ,p_owner_id                       in     number   default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_announcement_id                   out nocopy number
  ,p_object_version_number             out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create_announcement';
  l_announcement_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_ANNOUNCEMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    ota_announcement_bk1.create_announcement_b
  (p_effective_date              => l_effective_date
  ,p_announcement_title          => p_announcement_title
  ,p_announcement_body           => p_announcement_body
  ,p_business_group_id           => p_business_group_id
  ,p_start_date_active           => p_start_date_active
  ,p_end_date_active             => p_end_date_active
  ,p_owner_id                    => p_owner_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_object_version_number       => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ANNOUNCEMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_anc_ins.ins
  (  p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_start_date_active           => p_start_date_active
  ,p_end_date_active             => p_end_date_active
  ,p_owner_id                    => p_owner_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_announcement_id             => l_announcement_id
  ,p_object_version_number       => l_object_version_number
  );

   ota_ant_ins.ins_tl
    (
      p_effective_date      => l_effective_date
  ,p_language_code          => USERENV('LANG')
  ,p_announcement_id        => l_announcement_id
  ,p_announcement_title     => p_announcement_title
  ,p_announcement_body      => p_announcement_body
    );
  --
  -- Call After Process User Hook
  --

  begin
  ota_announcement_bk1.create_announcement_a
  (p_effective_date              => l_effective_date
  ,p_announcement_title          => p_announcement_title
  ,p_announcement_body           => p_announcement_body
  ,p_business_group_id           => p_business_group_id
  ,p_start_date_active           => p_start_date_active
  ,p_end_date_active             => p_end_date_active
  ,p_owner_id                    => p_owner_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_announcement_id             => l_announcement_id
  ,p_object_version_number       => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ANNOUNCEMENT'
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
  p_announcement_id        := l_announcement_id;
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_ANNOUNCEMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_announcement_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_ANNOUNCEMENT;
    p_announcement_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_announcement;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_announcement >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_announcement
  (p_validate                      in     boolean  default false
  ,p_effective_date               in     date
  ,p_announcement_title           in varchar2
  ,p_announcement_body            in varchar2
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date     default hr_api.g_date
  ,p_end_date_active                in     date     default hr_api.g_date
  ,p_owner_id                       in     number   default hr_api.g_number
  ,p_attribute_category             in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2 default hr_api.g_varchar2
  ,p_announcement_id                in     number
  ,p_object_version_number          in   out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Training Plan';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
  l_end_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_ANNOUNCEMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    ota_announcement_bk2.update_announcement_b
  (p_effective_date              => l_effective_date
  ,p_announcement_title          => p_announcement_title
  ,p_announcement_body           => p_announcement_body
  ,p_business_group_id           => p_business_group_id
  ,p_start_date_active           => p_start_date_active
  ,p_end_date_active             => p_end_date_active
  ,p_owner_id                    => p_owner_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_announcement_id             => p_announcement_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ANNOUNCEMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_anc_upd.upd
    (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_start_date_active           => p_start_date_active
  ,p_end_date_active             => p_end_date_active
  ,p_owner_id                    => p_owner_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_announcement_id             => p_announcement_id
  ,p_object_version_number       => p_object_version_number    );

  ota_ant_upd.upd_tl( p_effective_date      => l_effective_date
  ,p_language_code          => USERENV('LANG')
  ,p_announcement_id        => p_announcement_id
  ,p_announcement_title     => p_announcement_title
  ,p_announcement_body      => p_announcement_body  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_announcement_bk2.update_announcement_a
  (p_effective_date              => l_effective_date
  ,p_announcement_title          => p_announcement_title
  ,p_announcement_body           => p_announcement_body
  ,p_business_group_id           => p_business_group_id
  ,p_start_date_active           => p_start_date_active
  ,p_end_date_active             => p_end_date_active
  ,p_owner_id                    => p_owner_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_announcement_id             => p_announcement_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ANNOUNCEMENT'
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
    rollback to UPDATE_ANNOUNCEMENT;
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
    rollback to UPDATE_ANNOUNCEMENT;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_announcement;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_ANNOUNCEMENT >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_announcement
  (p_validate                      in     boolean  default false
  ,p_announcement_id               in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete_announcement';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_ANNOUNCEMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  --
  begin
    ota_announcement_bk3.delete_announcement_b
  (p_announcement_id            => p_announcement_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ANNOUNCEMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_ant_del.del_tl
  (p_announcement_id        => p_announcement_id
   --,p_language =>  USERENV('LANG')
  );

  ota_anc_del.del
  (p_announcement_id        => p_announcement_id
  ,p_object_version_number   => p_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
  ota_announcement_bk3.delete_announcement_a
  (p_announcement_id            => p_announcement_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ANNOUNCEMENT'
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
    rollback to DELETE_ANNOUNCEMENT;
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
    rollback to DELETE_ANNOUNCEMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_announcement;
--
end ota_announcement_api;

/
