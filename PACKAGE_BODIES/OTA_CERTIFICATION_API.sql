--------------------------------------------------------
--  DDL for Package Body OTA_CERTIFICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CERTIFICATION_API" as
/* $Header: otcrtapi.pkb 120.1 2005/08/10 15:51 asud noship $ */
-- Package Variables
--
g_package  varchar2(33) := '  OTA_CERTIFICATION_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_CERTIFICATION >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
--
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_certification
  (p_effective_date                 in     date
  ,p_validate                       in     boolean   default false
  ,p_name                           in     varchar2
  ,p_business_group_id              in     number
  ,p_public_flag                    in     varchar2 default 'Y'
  ,p_initial_completion_date        in     date     default null
  ,p_initial_completion_duration    in     number   default null
  ,p_initial_compl_duration_units   in     varchar2 default null
  ,p_renewal_duration               in     number   default null
  ,p_renewal_duration_units         in     varchar2 default null
  ,p_notify_days_before_expire      in     number   default null
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
  ,p_description                    in     varchar2 default null
  ,p_objectives                     in     varchar2 default null
  ,p_purpose                        in     varchar2 default null
  ,p_keywords                       in     varchar2 default null
  ,p_end_date_comments              in     varchar2 default null
  ,p_initial_period_comments        in     varchar2 default null
  ,p_renewal_period_comments        in     varchar2 default null
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
  ,p_VALIDITY_DURATION              in     NUMBER   default null
  ,p_VALIDITY_DURATION_UNITS        in     VARCHAR2 default null
  ,p_RENEWABLE_FLAG                 in     VARCHAR2 default null
  ,p_VALIDITY_START_TYPE            in     VARCHAR2 default null
  ,p_COMPETENCY_UPDATE_LEVEL        in     VARCHAR2 default null
  ,p_certification_id               out nocopy number
  ,p_object_version_number          out nocopy number
) is
 --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_certification';
  l_certification_id number;
  l_object_version_number   number;
  l_effective_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_CERTIFICATION;
  l_effective_date := trunc(p_effective_date);


  begin
  ota_certification_bk1.create_certification_b
  (p_effective_date                 => p_effective_date
  ,p_validate                       => p_validate
  ,p_name                           => p_name
  ,p_business_group_id              => p_business_group_id
  ,p_public_flag                    => p_public_flag
  ,p_initial_completion_date        => p_initial_completion_date
  ,p_initial_completion_duration    => p_initial_completion_duration
  ,p_initial_compl_duration_units   => p_initial_compl_duration_units
  ,p_renewal_duration               => p_renewal_duration
  ,p_renewal_duration_units         => p_renewal_duration_units
  ,p_notify_days_before_expire      => p_notify_days_before_expire
  ,p_start_date_active              => p_start_date_active
  ,p_end_date_active                => p_end_date_active
  ,p_description                    => p_description
  ,p_objectives                     => p_objectives
  ,p_purpose                        => p_purpose
  ,p_keywords                       => p_keywords
  ,p_end_date_comments              => p_end_date_comments
  ,p_initial_period_comments        => p_initial_period_comments
  ,p_renewal_period_comments        => p_renewal_period_comments
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
  ,p_VALIDITY_DURATION              => p_VALIDITY_DURATION
  ,p_VALIDITY_DURATION_UNITS        => p_VALIDITY_DURATION_UNITS
  ,p_RENEWABLE_FLAG                 => p_RENEWABLE_FLAG
  ,p_VALIDITY_START_TYPE            => p_VALIDITY_START_TYPE
  ,p_COMPETENCY_UPDATE_LEVEL        => p_COMPETENCY_UPDATE_LEVEL
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CERTIFICATION'
        ,p_hook_type   => 'BP'
        );
  end;

 --
  -- Process Logic
  --
  ota_crt_ins.ins
  (p_effective_date                 => p_effective_date
  ,p_business_group_id              => p_business_group_id
  ,p_public_flag                    => p_public_flag
  ,p_initial_completion_date        => p_initial_completion_date
  ,p_initial_completion_duration    => p_initial_completion_duration
  ,p_initial_compl_duration_units   => p_initial_compl_duration_units
  ,p_renewal_duration               => p_renewal_duration
  ,p_renewal_duration_units         => p_renewal_duration_units
  ,p_notify_days_before_expire      => p_notify_days_before_expire
  ,p_start_date_active              => p_start_date_active
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
  ,p_VALIDITY_DURATION              => p_VALIDITY_DURATION
  ,p_VALIDITY_DURATION_UNITS        => p_VALIDITY_DURATION_UNITS
  ,p_RENEWABLE_FLAG                 => p_RENEWABLE_FLAG
  ,p_VALIDITY_START_TYPE            => p_VALIDITY_START_TYPE
  ,p_COMPETENCY_UPDATE_LEVEL        => p_COMPETENCY_UPDATE_LEVEL
  ,p_certification_id               => l_certification_id
  ,p_object_version_number          => l_object_version_number
  );
 --
  -- Set all output arguments
  --
  p_certification_id        := l_certification_id;
  p_object_version_number   := l_object_version_number;


  ota_ctl_ins.ins_tl
  (
   p_effective_date               => p_effective_date
  ,p_language_code                => USERENV('LANG')
  ,p_certification_id             => p_certification_id
  ,p_name                         => rtrim(p_name)
  ,p_description                  => p_description
  ,p_objectives                   => p_objectives
  ,p_purpose                      => p_purpose
  ,p_keywords                     => p_keywords
  ,p_end_date_comments            => p_end_date_comments
  ,p_initial_period_comments      => p_initial_period_comments
  ,p_renewal_period_comments      => p_renewal_period_comments
  );


  begin
  ota_certification_bk1.create_certification_a
  (p_effective_date                 => p_effective_date
  ,p_certification_id               => p_certification_id
  ,p_validate                       => p_validate
  ,p_name                           => p_name
  ,p_business_group_id              => p_business_group_id
  ,p_public_flag                    => p_public_flag
  ,p_initial_completion_date        => p_initial_completion_date
  ,p_initial_completion_duration    => p_initial_completion_duration
  ,p_initial_compl_duration_units   => p_initial_compl_duration_units
  ,p_renewal_duration               => p_renewal_duration
  ,p_renewal_duration_units         => p_renewal_duration_units
  ,p_notify_days_before_expire      => p_notify_days_before_expire
  ,p_start_date_active              => p_start_date_active
  ,p_end_date_active                => p_end_date_active
  ,p_description                    => p_description
  ,p_objectives                     => p_objectives
  ,p_purpose                        => p_purpose
  ,p_keywords                       => p_keywords
  ,p_end_date_comments              => p_end_date_comments
  ,p_initial_period_comments        => p_initial_period_comments
  ,p_renewal_period_comments        => p_renewal_period_comments
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
  ,p_VALIDITY_DURATION              => p_VALIDITY_DURATION
  ,p_VALIDITY_DURATION_UNITS        => p_VALIDITY_DURATION_UNITS
  ,p_RENEWABLE_FLAG                 => p_RENEWABLE_FLAG
  ,p_VALIDITY_START_TYPE            => p_VALIDITY_START_TYPE
  ,p_COMPETENCY_UPDATE_LEVEL        => p_COMPETENCY_UPDATE_LEVEL
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CERTIFICATION'
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
    rollback to CREATE_CERTIFICATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_certification_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_CERTIFICATION;
    p_certification_id     := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_certification;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_LEARNING_PATH >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_certification
  (p_effective_date                 in     date
  ,p_certification_id               in     number
  ,p_object_version_number          in out nocopy number
  ,p_name                           in     varchar2  default hr_api.g_varchar2
  ,p_public_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_initial_completion_date        in     date      default hr_api.g_date
  ,p_initial_completion_duration    in     number    default hr_api.g_number
  ,p_initial_compl_duration_units   in     varchar2  default hr_api.g_varchar2
  ,p_renewal_duration               in     number    default  hr_api.g_number
  ,p_renewal_duration_units         in     varchar2  default hr_api.g_varchar2
  ,p_notify_days_before_expire      in     number    default hr_api.g_number
  ,p_start_date_active              in     date      default hr_api.g_date
  ,p_end_date_active                in     date      default hr_api.g_date
  ,p_description                    in     varchar2  default hr_api.g_varchar2
  ,p_objectives                     in     varchar2  default hr_api.g_varchar2
  ,p_purpose                        in     varchar2  default hr_api.g_varchar2
  ,p_keywords                       in     varchar2  default hr_api.g_varchar2
  ,p_end_date_comments              in     varchar2  default hr_api.g_varchar2
  ,p_initial_period_comments        in     varchar2  default hr_api.g_varchar2
  ,p_renewal_period_comments        in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in     number    default hr_api.g_number
  ,p_VALIDITY_DURATION              in     number    default hr_api.g_number
  ,p_VALIDITY_DURATION_UNITS        in     varchar2  default hr_api.g_varchar2
  ,p_RENEWABLE_FLAG                 in     varchar2  default hr_api.g_varchar2
  ,p_VALIDITY_START_TYPE            in     varchar2  default hr_api.g_varchar2
  ,p_COMPETENCY_UPDATE_LEVEL        in     varchar2  default hr_api.g_varchar2
  ,p_validate                       in     boolean   default false
) is
 --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_certification';
  l_certification_id number;
  l_object_version_number   number;
  l_effective_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_CERTIFICATION;
  l_effective_date := trunc(p_effective_date);


  begin
  ota_certification_bk2.update_certification_b
  (p_effective_date                 => p_effective_date
  ,p_certification_id               => p_certification_id
  ,p_object_version_number          => p_object_version_number
  ,p_name                           => p_name
  ,p_public_flag                    => p_public_flag
  ,p_initial_completion_date        => p_initial_completion_date
  ,p_initial_completion_duration    => p_initial_completion_duration
  ,p_initial_compl_duration_units   => p_initial_compl_duration_units
  ,p_renewal_duration               => p_renewal_duration
  ,p_renewal_duration_units         => p_renewal_duration_units
  ,p_notify_days_before_expire      => p_notify_days_before_expire
  ,p_start_date_active              => p_start_date_active
  ,p_end_date_active                => p_end_date_active
  ,p_description                    => p_description
  ,p_objectives                     => p_objectives
  ,p_purpose                        => p_purpose
  ,p_keywords                       => p_keywords
  ,p_end_date_comments              => p_end_date_comments
  ,p_initial_period_comments        => p_initial_period_comments
  ,p_renewal_period_comments        => p_renewal_period_comments
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
  ,p_business_group_id              => p_business_group_id
  ,p_VALIDITY_DURATION              => p_VALIDITY_DURATION
  ,p_VALIDITY_DURATION_UNITS        => p_VALIDITY_DURATION_UNITS
  ,p_RENEWABLE_FLAG                 => p_RENEWABLE_FLAG
  ,p_VALIDITY_START_TYPE            => p_VALIDITY_START_TYPE
  ,p_COMPETENCY_UPDATE_LEVEL        => p_COMPETENCY_UPDATE_LEVEL
  ,p_validate                     => p_validate
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UDPATE_CERTIFICATION'
        ,p_hook_type   => 'BP'
        );
  end;

 --
  -- Process Logic
  --
  ota_crt_upd.upd
  (p_effective_date                 => p_effective_date
  ,p_business_group_id              => p_business_group_id
  ,p_public_flag                    => p_public_flag
  ,p_initial_completion_date        => p_initial_completion_date
  ,p_initial_completion_duration    => p_initial_completion_duration
  ,p_initial_compl_duration_units   => p_initial_compl_duration_units
  ,p_renewal_duration               => p_renewal_duration
  ,p_renewal_duration_units         => p_renewal_duration_units
  ,p_notify_days_before_expire      => p_notify_days_before_expire
  ,p_start_date_active              => p_start_date_active
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
  ,p_VALIDITY_DURATION              => p_VALIDITY_DURATION
  ,p_VALIDITY_DURATION_UNITS        => p_VALIDITY_DURATION_UNITS
  ,p_RENEWABLE_FLAG                 => p_RENEWABLE_FLAG
  ,p_VALIDITY_START_TYPE            => p_VALIDITY_START_TYPE
  ,p_COMPETENCY_UPDATE_LEVEL        => p_COMPETENCY_UPDATE_LEVEL
  ,p_certification_id               => p_certification_id
  ,p_object_version_number          => p_object_version_number
  );


  ota_ctl_upd.upd_tl
  (
   p_effective_date               => p_effective_date
  ,p_language_code                => USERENV('LANG')
  ,p_certification_id             => p_certification_id
  ,p_name                         => rtrim(p_name)
  ,p_description                  => p_description
  ,p_objectives                   => p_objectives
  ,p_purpose                      => p_purpose
  ,p_keywords                     => p_keywords
  ,p_end_date_comments            => p_end_date_comments
  ,p_initial_period_comments      => p_initial_period_comments
  ,p_renewal_period_comments      => p_renewal_period_comments
  );


  begin
  ota_certification_bk2.update_certification_a
  (p_effective_date                 => p_effective_date
  ,p_certification_id               => p_certification_id
  ,p_object_version_number          => p_object_version_number
  ,p_name                           => p_name
  ,p_public_flag                    => p_public_flag
  ,p_initial_completion_date        => p_initial_completion_date
  ,p_initial_completion_duration    => p_initial_completion_duration
  ,p_initial_compl_duration_units   => p_initial_compl_duration_units
  ,p_renewal_duration               => p_renewal_duration
  ,p_renewal_duration_units         => p_renewal_duration_units
  ,p_notify_days_before_expire      => p_notify_days_before_expire
  ,p_start_date_active              => p_start_date_active
  ,p_end_date_active                => p_end_date_active
  ,p_description                    => p_description
  ,p_objectives                     => p_objectives
  ,p_purpose                        => p_purpose
  ,p_keywords                       => p_keywords
  ,p_end_date_comments              => p_end_date_comments
  ,p_initial_period_comments        => p_initial_period_comments
  ,p_renewal_period_comments        => p_renewal_period_comments
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
  ,p_business_group_id              => p_business_group_id
  ,p_VALIDITY_DURATION              => p_VALIDITY_DURATION
  ,p_VALIDITY_DURATION_UNITS        => p_VALIDITY_DURATION_UNITS
  ,p_RENEWABLE_FLAG                 => p_RENEWABLE_FLAG
  ,p_VALIDITY_START_TYPE            => p_VALIDITY_START_TYPE
  ,p_COMPETENCY_UPDATE_LEVEL        => p_COMPETENCY_UPDATE_LEVEL
  ,p_validate                     => p_validate
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CERTIFICATION'
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
    rollback to UPDATE_CERTIFICATION;
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
    rollback to UPDATE_CERTIFICATION;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_certification;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_CERTIFICATION >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_certification
  (
  p_certification_id                   in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Certification';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_CERTIFICATION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  ota_certification_bk3.delete_certification_b
  (p_certification_id             => p_certification_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CERTIFICATION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_ctl_del.del_tl
    (p_certification_id   => p_certification_id
    );

  ota_crt_del.del
  (
  p_certification_id         => p_certification_id ,
  p_object_version_number    => p_object_version_number
  );
  begin
  ota_certification_bk3.delete_certification_a
  (p_certification_id             => p_certification_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CERTIFICATION'
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
    rollback to DELETE_CERTIFICATION;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_certification;
--
end ota_certification_api;

/
