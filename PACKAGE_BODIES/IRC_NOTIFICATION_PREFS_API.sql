--------------------------------------------------------
--  DDL for Package Body IRC_NOTIFICATION_PREFS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_NOTIFICATION_PREFS_API" as
/* $Header: irinpapi.pkb 120.1 2006/02/15 16:19:07 gjaggava noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'IRC_NOTIFICATION_PREFS_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< CREATE_NOTIFICATION_PREFS >------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_NOTIFICATION_PREFS
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_effective_date                in     date
  ,p_address_id                    in     number   default null
  ,p_matching_jobs                 in     varchar2 default 'N'
  ,p_matching_job_freq             in     varchar2 default '1'
  ,p_allow_access                  in     varchar2 default 'N'
  ,p_receive_info_mail             in     varchar2 default 'N'
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_agency_id                     in     number   default null
  ,p_attempt_id                    in     number   default null
  ,p_notification_preference_id       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package||'CREATE_NOTIFICATION_PREFS';
  l_object_version_number number;
  l_effective_date        date;
  l_notification_preference_id number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_NOTIFICATION_PREFS;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_NOTIFICATION_PREFS_BK1.CREATE_NOTIFICATION_PREFS_B
      (p_person_id          => p_person_id
      ,p_effective_date     => l_effective_date
      ,p_address_id         => p_address_id
      ,p_matching_jobs      => p_matching_jobs
      ,p_matching_job_freq  => p_matching_job_freq
      ,p_allow_access       => p_allow_access
      ,p_receive_info_mail  => p_receive_info_mail
      ,p_attribute_category => p_attribute_category
      ,p_attribute1         => p_attribute1
      ,p_attribute2         => p_attribute2
      ,p_attribute3         => p_attribute3
      ,p_attribute4         => p_attribute4
      ,p_attribute5         => p_attribute5
      ,p_attribute6         => p_attribute6
      ,p_attribute7         => p_attribute7
      ,p_attribute8         => p_attribute8
      ,p_attribute9         => p_attribute9
      ,p_attribute10        => p_attribute10
      ,p_attribute11        => p_attribute11
      ,p_attribute12        => p_attribute12
      ,p_attribute13        => p_attribute13
      ,p_attribute14        => p_attribute14
      ,p_attribute15        => p_attribute15
      ,p_attribute16        => p_attribute16
      ,p_attribute17        => p_attribute17
      ,p_attribute18        => p_attribute18
      ,p_attribute19        => p_attribute19
      ,p_attribute20        => p_attribute20
      ,p_attribute21        => p_attribute21
      ,p_attribute22        => p_attribute22
      ,p_attribute23        => p_attribute23
      ,p_attribute24        => p_attribute24
      ,p_attribute25        => p_attribute25
      ,p_attribute26        => p_attribute26
      ,p_attribute27        => p_attribute27
      ,p_attribute28        => p_attribute28
      ,p_attribute29        => p_attribute29
      ,p_attribute30        => p_attribute30
      ,p_agency_id          => p_agency_id
      ,p_attempt_id         => p_attempt_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_NOTIFICATION_PREFS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  irc_inp_ins.ins
  (p_effective_date                => l_effective_date
  ,p_person_id                     => p_person_id
  ,p_matching_jobs                 => p_matching_jobs
  ,p_matching_job_freq             => p_matching_job_freq
  ,p_receive_info_mail             => p_receive_info_mail
  ,p_allow_access                  => p_allow_access
  ,p_attribute_category            => p_attribute_category
  ,p_address_id                    => p_address_id
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_object_version_number         => l_object_version_number
  ,p_notification_preference_id    => l_notification_preference_id
  ,p_agency_id                     => p_agency_id
  ,p_attempt_id                    => p_attempt_id
  );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_NOTIFICATION_PREFS_BK1.CREATE_NOTIFICATION_PREFS_A
      (p_person_id            => p_person_id
      ,p_effective_date       => l_effective_date
      ,p_address_id           => p_address_id
      ,p_matching_jobs        => p_matching_jobs
      ,p_matching_job_freq    => p_matching_job_freq
      ,p_allow_access         => p_allow_access
      ,p_receive_info_mail    => p_receive_info_mail
      ,p_object_version_number => l_object_version_number
      ,p_attribute_category   => p_attribute_category
      ,p_attribute1           => p_attribute1
      ,p_attribute2           => p_attribute2
      ,p_attribute3           => p_attribute3
      ,p_attribute4           => p_attribute4
      ,p_attribute5           => p_attribute5
      ,p_attribute6           => p_attribute6
      ,p_attribute7           => p_attribute7
      ,p_attribute8           => p_attribute8
      ,p_attribute9           => p_attribute9
      ,p_attribute10          => p_attribute10
      ,p_attribute11          => p_attribute11
      ,p_attribute12          => p_attribute12
      ,p_attribute13          => p_attribute13
      ,p_attribute14          => p_attribute14
      ,p_attribute15          => p_attribute15
      ,p_attribute16          => p_attribute16
      ,p_attribute17          => p_attribute17
      ,p_attribute18          => p_attribute18
      ,p_attribute19          => p_attribute19
      ,p_attribute20          => p_attribute20
      ,p_attribute21          => p_attribute21
      ,p_attribute22          => p_attribute22
      ,p_attribute23          => p_attribute23
      ,p_attribute24          => p_attribute24
      ,p_attribute25          => p_attribute25
      ,p_attribute26          => p_attribute26
      ,p_attribute27          => p_attribute27
      ,p_attribute28          => p_attribute28
      ,p_attribute29          => p_attribute29
      ,p_attribute30          => p_attribute30
      ,p_notification_preference_id => l_notification_preference_id
      ,p_agency_id            => p_agency_id
      ,p_attempt_id           => p_attempt_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_NOTIFICATION_PREFS'
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
  p_notification_preference_id := l_notification_preference_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_NOTIFICATION_PREFS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_notification_preference_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := null;
    p_notification_preference_id := null;
    rollback to CREATE_NOTIFICATION_PREFS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_NOTIFICATION_PREFS;
--
-- ----------------------------------------------------------------------------
-- |---------------------< UPDATE_NOTIFICATION_PREFS >------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_NOTIFICATION_PREFS
  (p_validate                      in     boolean  default false
  ,p_party_id                      in     number   default hr_api.g_number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_effective_date                in     date
  ,p_matching_jobs                 in     varchar2 default hr_api.g_varchar2
  ,p_matching_job_freq             in     varchar2 default hr_api.g_varchar2
  ,p_allow_access                  in     varchar2 default hr_api.g_varchar2
  ,p_receive_info_mail             in     varchar2 default hr_api.g_varchar2
  ,p_address_id                    in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_notification_preference_id    in     number
  ,p_agency_id                     in     number   default hr_api.g_number
  ,p_attempt_id                    in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package||'UPDATE_NOTIFICATION_PREFS';
  --
  l_effective_date        date;
  l_p_object_version_number number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_NOTIFICATION_PREFS;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_NOTIFICATION_PREFS_BK2.UPDATE_NOTIFICATION_PREFS_B
      (p_party_id           => p_party_id
      ,p_person_id          => p_person_id
      ,p_notification_preference_id => p_notification_preference_id
      ,p_effective_date     => l_effective_date
      ,p_matching_jobs      => p_matching_jobs
      ,p_matching_job_freq  => p_matching_job_freq
      ,p_allow_access       => p_allow_access
      ,p_receive_info_mail  => p_receive_info_mail
      ,p_object_version_number => l_p_object_version_number
      ,p_address_id         => p_address_id
      ,p_attribute_category => p_attribute_category
      ,p_attribute1         => p_attribute1
      ,p_attribute2         => p_attribute2
      ,p_attribute3         => p_attribute3
      ,p_attribute4         => p_attribute4
      ,p_attribute5         => p_attribute5
      ,p_attribute6         => p_attribute6
      ,p_attribute7         => p_attribute7
      ,p_attribute8         => p_attribute8
      ,p_attribute9         => p_attribute9
      ,p_attribute10        => p_attribute10
      ,p_attribute11        => p_attribute11
      ,p_attribute12        => p_attribute12
      ,p_attribute13        => p_attribute13
      ,p_attribute14        => p_attribute14
      ,p_attribute15        => p_attribute15
      ,p_attribute16        => p_attribute16
      ,p_attribute17        => p_attribute17
      ,p_attribute18        => p_attribute18
      ,p_attribute19        => p_attribute19
      ,p_attribute20        => p_attribute20
      ,p_attribute21        => p_attribute21
      ,p_attribute22        => p_attribute22
      ,p_attribute23        => p_attribute23
      ,p_attribute24        => p_attribute24
      ,p_attribute25        => p_attribute25
      ,p_attribute26        => p_attribute26
      ,p_attribute27        => p_attribute27
      ,p_attribute28        => p_attribute28
      ,p_attribute29        => p_attribute29
      ,p_attribute30        => p_attribute30
      ,p_agency_id          => p_agency_id
      ,p_attempt_id         => p_attempt_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_NOTIFICATION_PREFS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  --
  -- Process Logic
  --
    --
  irc_inp_upd.upd
  (p_effective_date                => l_effective_date
  ,p_party_id                      => p_party_id
  ,p_person_id                     => p_person_id
  ,p_notification_preference_id    => p_notification_preference_id
  ,p_object_version_number         => l_p_object_version_number
  ,p_matching_jobs                 => p_matching_jobs
  ,p_matching_job_freq             => p_matching_job_freq
  ,p_receive_info_mail             => p_receive_info_mail
  ,p_allow_access                  => p_allow_access
  ,p_attribute_category            => p_attribute_category
  ,p_address_id                    => p_address_id
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_agency_id                     => p_agency_id
  ,p_attempt_id                    => p_attempt_id
  );
 --
  --
  -- Call After Process User Hook
  --
  begin
    IRC_NOTIFICATION_PREFS_BK2.UPDATE_NOTIFICATION_PREFS_A
      (p_party_id              => p_party_id
      ,p_person_id             => p_person_id
      ,p_notification_preference_id => p_notification_preference_id
      ,p_effective_date        => l_effective_date
      ,p_matching_jobs         => p_matching_jobs
      ,p_matching_job_freq     => p_matching_job_freq
      ,p_allow_access          => p_allow_access
      ,p_receive_info_mail     => p_receive_info_mail
      ,p_object_version_number => l_p_object_version_number
      ,p_address_id           => p_address_id
      ,p_attribute_category   => p_attribute_category
      ,p_attribute1           => p_attribute1
      ,p_attribute2           => p_attribute2
      ,p_attribute3           => p_attribute3
      ,p_attribute4           => p_attribute4
      ,p_attribute5           => p_attribute5
      ,p_attribute6           => p_attribute6
      ,p_attribute7           => p_attribute7
      ,p_attribute8           => p_attribute8
      ,p_attribute9           => p_attribute9
      ,p_attribute10          => p_attribute10
      ,p_attribute11          => p_attribute11
      ,p_attribute12          => p_attribute12
      ,p_attribute13          => p_attribute13
      ,p_attribute14          => p_attribute14
      ,p_attribute15          => p_attribute15
      ,p_attribute16          => p_attribute16
      ,p_attribute17          => p_attribute17
      ,p_attribute18          => p_attribute18
      ,p_attribute19          => p_attribute19
      ,p_attribute20          => p_attribute20
      ,p_attribute21          => p_attribute21
      ,p_attribute22          => p_attribute22
      ,p_attribute23          => p_attribute23
      ,p_attribute24          => p_attribute24
      ,p_attribute25          => p_attribute25
      ,p_attribute26          => p_attribute26
      ,p_attribute27          => p_attribute27
      ,p_attribute28          => p_attribute28
      ,p_attribute29          => p_attribute29
      ,p_attribute30          => p_attribute30
      ,p_agency_id            => p_agency_id
      ,p_attempt_id           => p_attempt_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_NOTIFICATION_PREFS'
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
  p_object_version_number := l_p_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_NOTIFICATION_PREFS;
    --
    -- Reset IN OUT parameters and set OUT parameters
    p_object_version_number := l_p_object_version_number;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_NOTIFICATION_PREFS;
    --
    -- Reset IN OUT parameters and set OUT parameters
    p_object_version_number := l_p_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_NOTIFICATION_PREFS;
--
-- ----------------------------------------------------------------------------
-- |---------------------< DELETE_NOTIFICATION_PREFS >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_NOTIFICATION_PREFS
  (p_validate                      in     boolean  default false
  ,p_notification_preference_id    in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package||'DELETE_NOTIFICATION_PREFS';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_NOTIFICATION_PREFS;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_NOTIFICATION_PREFS_BK3.DELETE_NOTIFICATION_PREFS_B
      (p_notification_preference_id    => p_notification_preference_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_NOTIFICATION_PREFS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  irc_inp_del.del
  (p_notification_preference_id    => p_notification_preference_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_NOTIFICATION_PREFS_BK3.DELETE_NOTIFICATION_PREFS_A
      (p_notification_preference_id    => p_notification_preference_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_NOTIFICATION_PREFS'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_NOTIFICATION_PREFS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_NOTIFICATION_PREFS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_NOTIFICATION_PREFS;
--
end IRC_NOTIFICATION_PREFS_API;

/
