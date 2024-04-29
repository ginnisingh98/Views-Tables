--------------------------------------------------------
--  DDL for Package Body OTA_CERT_MEMBER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CERT_MEMBER_API" as
/* $Header: otcmbapi.pkb 120.0 2005/06/03 08:28 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_cert_member_api.';
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_CERTIFICATION_MEMBER >-----------------|
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
procedure create_certification_member
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_certification_id               in     number
  ,p_object_id                      in     number
  ,p_object_type                    in     varchar2
  ,p_member_sequence                in     number
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
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
  ,p_certification_member_id           out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Certification Member';
  l_certification_member_id number;
  l_object_version_number   number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_certification_member;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    ota_cert_member_bk1.create_certification_member_b
    (p_effective_date                 => l_effective_date
    ,p_certification_id               => p_certification_id
    ,p_object_id                      => p_object_id
    ,p_object_type                    => p_object_type
    ,p_member_sequence                => p_member_sequence
    ,p_business_group_id              => p_business_group_id
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
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_certification_member'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_cmb_ins.ins
    (p_effective_date                 => l_effective_date
    ,p_certification_id               => p_certification_id
    ,p_object_id                      => p_object_id
    ,p_object_type                    => p_object_type
    ,p_member_sequence                => p_member_sequence
    ,p_business_group_id              => p_business_group_id
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
    ,p_certification_member_id        => l_certification_member_id
    ,p_object_version_number          => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
  ota_cert_member_bk1.create_certification_member_a
    (p_effective_date                 => l_effective_date
    ,p_certification_id               => p_certification_id
    ,p_object_id                      => p_object_id
    ,p_object_type                    => p_object_type
    ,p_member_sequence                => p_member_sequence
    ,p_business_group_id              => p_business_group_id
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
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_certification_member'
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
  p_certification_member_id := l_certification_member_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_certification_member;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_certification_member_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
end create_certification_member;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_CERTIFICATION_MEMBER >-----------------|
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
procedure update_certification_member
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_certification_member_id        in      number
  ,p_object_version_number          in   out nocopy number
  ,p_object_id                      in     number
  ,p_object_type                    in     varchar2
  ,p_member_sequence                in     number
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
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
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Certification member';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_certification_member;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --

  -- Call Before Process User Hook
  --
  begin
    ota_cert_member_bk2.update_certification_member_b
    (p_effective_date                 => l_effective_date
    ,p_certification_member_id        => p_certification_member_id
    ,p_object_version_number          => l_object_version_number
    ,p_object_id                      => p_object_id
    ,p_object_type                    => p_object_type
    ,p_member_sequence                => p_member_sequence
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
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_certification_MEMBER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_cmb_upd.upd
    (p_effective_date                 => l_effective_date
    ,p_certification_member_id        => p_certification_member_id
    ,p_object_version_number          => l_object_version_number
    ,p_object_id                      => p_object_id
    ,p_object_type                    => p_object_type
    ,p_member_sequence                => p_member_sequence
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
    );
  --
  -- Call After Process User Hook
  --
  begin
  ota_cert_member_bk2.update_certification_member_a
    (p_effective_date                 => l_effective_date
    ,p_certification_member_id        => p_certification_member_id
    ,p_object_version_number          => l_object_version_number
    ,p_object_id                      => p_object_id
    ,p_object_type                    => p_object_type
    ,p_member_sequence                => p_member_sequence
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
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_certification_MEMBER'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_certification_member;
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
    rollback to update_certification_member;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_object_version_number := l_object_version_number;
    raise;
end update_certification_member;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_CERTIFICATION_MEMBER >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  This business process allows the user to delete a certification
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_certification_member
  (p_validate                      in     boolean  default false
  ,p_certification_member_id       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Certification Member';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_certification_member;
  --
  -- Call Before Process User Hook
  --
  begin
    ota_cert_member_bk3.delete_certification_member_b
    (p_certification_member_id     => p_certification_member_id
    ,p_object_version_number       => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CERTIFICATION_MEMBER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ota_cmb_del.del
  (p_certification_member_id        => p_certification_member_id
  ,p_object_version_number          => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_cert_member_bk3.delete_certification_member_a
  (p_certification_member_id     => p_certification_member_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CERTIFICATION_MEMBER'
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
    rollback to delete_certification_member;
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
    rollback to delete_certification_member;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_certification_member;
--
end ota_cert_member_api;

/
