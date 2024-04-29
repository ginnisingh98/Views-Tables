--------------------------------------------------------
--  DDL for Package Body OTA_CONFERENCE_SERVER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CONFERENCE_SERVER_API" as
/* $Header: otcfsapi.pkb 120.0 2005/05/29 07:05:31 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_conference_server_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_conference_server >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_conference_server
  (p_effective_date               in  date
  ,p_conference_server_id         out nocopy number
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2         default null
  ,p_url                          in  varchar2
  ,p_type                         in  varchar2
  ,p_owc_site_id                  in  varchar2         default null
  ,p_owc_auth_token               in  varchar2         default null
  ,p_end_date_active              in  date             default null
  ,p_object_version_number        out nocopy number
  ,p_business_group_id            in  number
  ,p_attribute_category           in  varchar2         default null
  ,p_attribute1                   in  varchar2         default null
  ,p_attribute2                   in  varchar2         default null
  ,p_attribute3                   in  varchar2         default null
  ,p_attribute4                   in  varchar2         default null
  ,p_attribute5                   in  varchar2         default null
  ,p_attribute6                   in  varchar2         default null
  ,p_attribute7                   in  varchar2         default null
  ,p_attribute8                   in  varchar2         default null
  ,p_attribute9                   in  varchar2         default null
  ,p_attribute10                  in  varchar2         default null
  ,p_attribute11                  in  varchar2         default null
  ,p_attribute12                  in  varchar2         default null
  ,p_attribute13                  in  varchar2         default null
  ,p_attribute14                  in  varchar2         default null
  ,p_attribute15                  in  varchar2         default null
  ,p_attribute16                  in  varchar2         default null
  ,p_attribute17                  in  varchar2         default null
  ,p_attribute18                  in  varchar2         default null
  ,p_attribute19                  in  varchar2         default null
  ,p_attribute20                  in  varchar2         default null
  ,p_validate                     in  boolean          default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Conference Server';
  l_conference_server_id number;
  l_object_version_number   number;
  l_effective_date          date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_CONFERENCE_SERVER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    ota_conference_server_bk1.create_conference_server_b
  (p_effective_date                 => l_effective_date
  ,p_name                           => p_name
  ,p_description                    => p_description
  ,p_url                            => p_url
  ,p_type                           => p_type
  ,p_owc_site_id                    => p_owc_site_id
  ,p_owc_auth_token                 => p_owc_auth_token
  ,p_end_date_active                => p_end_date_active
  ,p_business_group_id              => p_business_group_id
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CONFERENCE_SERVER'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_cfs_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_name                           => p_name
  ,p_url                            => p_url
  ,p_type                           => p_type
  ,p_business_group_id              => p_business_group_id
  ,p_description                    => p_description
  ,p_owc_site_id                    => p_owc_site_id
  ,p_owc_auth_token                 => p_owc_auth_token
  ,p_end_date_active                => p_end_date_active
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_conference_server_id           => l_conference_server_id
  ,p_object_version_number          => l_object_version_number
  );
  --
  -- Set all output arguments
  --
  p_conference_server_id         := l_conference_server_id;
  p_object_version_number        := l_object_version_number;

  ota_cft_ins.ins_tl
  (p_effective_date	             => p_effective_date
  ,p_language_code	             => USERENV('LANG')
  ,p_conference_server_id         => p_conference_server_id
  ,p_name                         => rtrim(p_name)
  ,p_description                  => p_description
  );
--

  --
  -- Call After Process User Hook
  --
  begin
  ota_conference_server_bk1.create_conference_server_a
  (p_effective_date                 => l_effective_date
  ,p_conference_server_id           => l_conference_server_id
  ,p_name                           => p_name
  ,p_description                    => p_description
  ,p_url                            => p_url
  ,p_type                           => p_type
  ,p_owc_site_id                    => p_owc_site_id
  ,p_owc_auth_token                 => p_owc_auth_token
  ,p_end_date_active                => p_end_date_active
  ,p_object_version_number          => l_object_version_number
  ,p_business_group_id              => p_business_group_id
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CONFERENCE_SERVER'
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
  p_conference_server_id        := l_conference_server_id;
  p_object_version_number       := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_CONFERENCE_SERVER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_conference_server_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_CONFERENCE_SERVER;
    p_conference_server_id    := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_conference_server;
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_conference_server >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_conference_server
  (p_effective_date               in  date
  ,p_conference_server_id         in  number
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_url                          in  varchar2
  ,p_type                         in  varchar2
  ,p_owc_site_id                  in  varchar2         default hr_api.g_varchar2
  ,p_owc_auth_token               in  varchar2         default hr_api.g_varchar2
  ,p_end_date_active              in  date             default hr_api.g_date
  ,p_business_group_id            in  number
  ,p_object_version_number        in out nocopy number
  ,p_attribute_category           in  varchar2         default hr_api.g_varchar2
  ,p_attribute1                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute2                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute3                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute4                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute5                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute6                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute7                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute8                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute9                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute10                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute11                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute12                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute13                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute14                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute15                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute16                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute17                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute18                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute19                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute20                  in  varchar2         default hr_api.g_varchar2
  ,p_validate                     in  boolean          default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Conference Server';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_CONFERENCE_SERVER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
  ota_conference_server_bk2.update_conference_server_b
  (p_effective_date                 => l_effective_date
  ,p_conference_server_id           => p_conference_server_id
  ,p_name                           => p_name
  ,p_description                    => p_description
  ,p_url                            => p_url
  ,p_type                           => p_type
  ,p_owc_site_id                    => p_owc_site_id
  ,p_owc_auth_token                 => p_owc_auth_token
  ,p_end_date_active                => p_end_date_active
  ,p_business_group_id              => p_business_group_id
  ,p_object_version_number          => l_object_version_number
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CONFERENCE_SERVER'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_cfs_upd.upd
  (p_effective_date                 => p_effective_date
  ,p_conference_server_id           => p_conference_server_id
  ,p_object_version_number          => l_object_version_number
  ,p_name                           => p_name
  ,p_url                            => p_url
  ,p_type                           => p_type
  ,p_business_group_id              => p_business_group_id
  ,p_description                    => p_description
  ,p_owc_site_id                    => p_owc_site_id
  ,p_owc_auth_token                 => p_owc_auth_token
  ,p_end_date_active                => p_end_date_active
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  );

  ota_cft_upd.upd_tl
  (p_effective_date                 => p_effective_date
  ,p_language_code	               => USERENV('LANG')
  ,p_conference_server_id           => p_conference_server_id
  ,p_name                           => rtrim(p_name)
  ,p_description                    => p_description
  );



  --
  -- Call After Process User Hook
  --
  begin
  ota_conference_server_bk2.update_conference_server_a
  (p_effective_date                 => l_effective_date
  ,p_conference_server_id           => p_conference_server_id
  ,p_name                           => p_name
  ,p_description                    => p_description
  ,p_url                            => p_url
  ,p_type                           => p_type
  ,p_owc_site_id                    => p_owc_site_id
  ,p_owc_auth_token                 => p_owc_auth_token
  ,p_end_date_active                => p_end_date_active
  ,p_business_group_id              => p_business_group_id
  ,p_object_version_number          => l_object_version_number
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CONFERENCE_SERVER'
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
    rollback to UPDATE_CONFERENCE_SERVER;
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
    rollback to UPDATE_CONFERENCE_SERVER;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_conference_server;
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_conference_server >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_conference_server
  (p_validate                      in     boolean  default false
  ,p_conference_server_id          in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Conference Server';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_CONFERENCE_SERVER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  --
  begin
    ota_conference_server_bk3.delete_conference_server_b
    (p_conference_server_id        => p_conference_server_id
    ,p_object_version_number       => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CONFERENCE_SERVER'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
 --
  ota_cft_del.del_tl
  (p_conference_server_id        => p_conference_server_id
  );
  --

  ota_cfs_del.del
  (p_conference_server_id        => p_conference_server_id
  ,p_object_version_number       => p_object_version_number
  );
  --

  -- Call After Process User Hook
  --
  begin
  ota_conference_server_bk3.delete_conference_server_a
  (p_conference_server_id        => p_conference_server_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CONFERENCE_SERVER'
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
    rollback to DELETE_CONFERENCE_SERVER;
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
    rollback to DELETE_CONFERENCE_SERVER;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_conference_server;
--
end ota_conference_server_api;

/
