--------------------------------------------------------
--  DDL for Package Body PER_SUPPLEMENTARY_ROLE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUPPLEMENTARY_ROLE_API" as
/* $Header: perolapi.pkb 120.0.12010000.2 2008/08/06 09:35:26 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'per_supplementary_role_api';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_supplementary_role >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_supplementary_role
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_job_id                        in     number
  ,p_job_group_id                  in     number
  ,p_person_id                     in     number
  ,p_organization_id               in     number   default null
  ,p_start_date                    in     date
  ,p_end_date                      in     date     default null
  ,p_confidential_date             in     date     default null
  ,p_emp_rights_flag               in     varchar2 default 'N'
  ,p_end_of_rights_date            in     date     default null
  ,p_primary_contact_flag          in     varchar2 default 'N'
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
  ,p_role_information_category      in     varchar2 default null
  ,p_role_information1              in     varchar2 default null
  ,p_role_information2              in     varchar2 default null
  ,p_role_information3              in     varchar2 default null
  ,p_role_information4              in     varchar2 default null
  ,p_role_information5              in     varchar2 default null
  ,p_role_information6              in     varchar2 default null
  ,p_role_information7              in     varchar2 default null
  ,p_role_information8              in     varchar2 default null
  ,p_role_information9              in     varchar2 default null
  ,p_role_information10             in     varchar2 default null
  ,p_role_information11             in     varchar2 default null
  ,p_role_information12             in     varchar2 default null
  ,p_role_information13             in     varchar2 default null
  ,p_role_information14             in     varchar2 default null
  ,p_role_information15             in     varchar2 default null
  ,p_role_information16             in     varchar2 default null
  ,p_role_information17             in     varchar2 default null
  ,p_role_information18             in     varchar2 default null
  ,p_role_information19             in     varchar2 default null
  ,p_role_information20             in     varchar2 default null
  ,p_role_id                        out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'create_role';
  l_role_id                per_roles.role_id%TYPE;
  l_object_version_number  per_roles.object_version_number%TYPE;
  l_effective_date         date;
  l_start_date             per_roles.start_date%TYPE;
  l_end_date               per_roles.end_date%TYPE;
  l_confidential_date      per_roles.confidential_date%TYPE;
  l_end_of_rights_date     per_roles.end_of_rights_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_role;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_start_date := trunc(p_start_date);
  l_end_date   := trunc(p_end_date);
  l_confidential_date := trunc(p_confidential_date);
  l_end_of_rights_date := trunc(p_end_of_rights_date);
  --
  -- Call Before Process User Hook
  --
begin
 per_supplementary_role_bk1.create_supplementary_role_b
  (p_effective_date              => l_effective_date
  ,p_job_id                      => p_job_id
  ,p_job_group_id                => p_job_group_id
  ,p_person_id                   => p_person_id
  ,p_organization_id             => p_organization_id
  ,p_start_date                  => l_start_date
  ,p_end_date                    => l_end_date
  ,p_confidential_date           => l_confidential_date
  ,p_emp_rights_flag             => p_emp_rights_flag
  ,p_end_of_rights_date          => l_end_of_rights_date
  ,p_primary_contact_flag        => p_primary_contact_flag
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
  ,p_role_information_category   => p_role_information_category
  ,p_role_information1           => p_role_information1
  ,p_role_information2           => p_role_information2
  ,p_role_information3           => p_role_information3
  ,p_role_information4           => p_role_information4
  ,p_role_information5           => p_role_information5
  ,p_role_information6           => p_role_information6
  ,p_role_information7           => p_role_information7
  ,p_role_information8           => p_role_information8
  ,p_role_information9           => p_role_information9
  ,p_role_information10          => p_role_information10
  ,p_role_information11          => p_role_information11
  ,p_role_information12          => p_role_information12
  ,p_role_information13          => p_role_information13
  ,p_role_information14          => p_role_information14
  ,p_role_information15          => p_role_information15
  ,p_role_information16          => p_role_information16
  ,p_role_information17          => p_role_information17
  ,p_role_information18          => p_role_information18
  ,p_role_information19          => p_role_information19
  ,p_role_information20          => p_role_information20
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_supplementary_role_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  hr_utility.set_location('before call to rh',3);
  -- Process Logic
  --
 per_rol_ins.ins
  (p_effective_date                => l_effective_date
  ,p_job_id                        => p_job_id
  ,p_job_group_id                  => p_job_group_id
  ,p_person_id                     => p_person_id
  ,p_organization_id               => p_organization_id
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_confidential_date             => l_confidential_date
  ,p_emp_rights_flag               => p_emp_rights_flag
  ,p_end_of_rights_date            => l_end_of_rights_date
  ,p_primary_contact_flag          => p_primary_contact_flag
  ,p_attribute_category            => p_attribute_category
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
  ,p_attribute18        => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_role_information_category     => p_role_information_category
  ,p_role_information1             => p_role_information1
  ,p_role_information2             => p_role_information2
  ,p_role_information3             => p_role_information3
  ,p_role_information4             => p_role_information4
  ,p_role_information5             => p_role_information5
  ,p_role_information6             => p_role_information6
  ,p_role_information7             => p_role_information7
  ,p_role_information8             => p_role_information8
  ,p_role_information9             => p_role_information9
  ,p_role_information10            => p_role_information10
  ,p_role_information11            => p_role_information11
  ,p_role_information12            => p_role_information12
  ,p_role_information13            => p_role_information13
  ,p_role_information14            => p_role_information14
  ,p_role_information15            => p_role_information15
  ,p_role_information16            => p_role_information16
  ,p_role_information17            => p_role_information17
  ,p_role_information18            => p_role_information18
  ,p_role_information19            => p_role_information19
  ,p_role_information20            => p_role_information20
  ,p_role_id                       => l_role_id
  ,p_object_version_number         => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
--
 per_supplementary_role_bk1.create_supplementary_role_a
  (p_effective_date              => l_effective_date
  ,p_job_id                      => p_job_id
  ,p_job_group_id                => p_job_group_id
  ,p_person_id                   => p_person_id
  ,p_organization_id             => p_organization_id
  ,p_start_date                  => l_start_date
  ,p_end_date                    => l_end_date
  ,p_confidential_date           => l_confidential_date
  ,p_emp_rights_flag             => p_emp_rights_flag
  ,p_end_of_rights_date          => l_end_of_rights_date
  ,p_primary_contact_flag        => p_primary_contact_flag
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
  ,p_role_information_category   => p_role_information_category
  ,p_role_information1           => p_role_information1
  ,p_role_information2           => p_role_information2
  ,p_role_information3           => p_role_information3
  ,p_role_information4           => p_role_information4
  ,p_role_information5           => p_role_information5
  ,p_role_information6           => p_role_information6
  ,p_role_information7           => p_role_information7
  ,p_role_information8           => p_role_information8
  ,p_role_information9           => p_role_information9
  ,p_role_information10          => p_role_information10
  ,p_role_information11          => p_role_information11
  ,p_role_information12          => p_role_information12
  ,p_role_information13          => p_role_information13
  ,p_role_information14          => p_role_information14
  ,p_role_information15          => p_role_information15
  ,p_role_information16          => p_role_information16
  ,p_role_information17          => p_role_information17
  ,p_role_information18          => p_role_information18
  ,p_role_information19          => p_role_information19
  ,p_role_information20          => p_role_information20
  ,p_role_id                     => l_role_id
  ,p_object_version_number       => l_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_supplementary_role_a'
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
  p_role_id                := l_role_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_role;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_role_id                := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_role_id                := null;
    p_object_version_number  := null;
    rollback to create_role;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_supplementary_role;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_supplementary_role >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_supplementary_role
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_role_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_confidential_date             in     date     default hr_api.g_date
  ,p_emp_rights_flag               in     varchar2 default hr_api.g_varchar2
  ,p_end_of_rights_date            in     date     default hr_api.g_date
  ,p_primary_contact_flag          in     varchar2 default hr_api.g_varchar2
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
  ,p_role_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_role_information1              in     varchar2 default hr_api.g_varchar2
  ,p_role_information2              in     varchar2 default hr_api.g_varchar2
  ,p_role_information3              in     varchar2 default hr_api.g_varchar2
  ,p_role_information4              in     varchar2 default hr_api.g_varchar2
  ,p_role_information5              in     varchar2 default hr_api.g_varchar2
  ,p_role_information6              in     varchar2 default hr_api.g_varchar2
  ,p_role_information7              in     varchar2 default hr_api.g_varchar2
  ,p_role_information8              in     varchar2 default hr_api.g_varchar2
  ,p_role_information9              in     varchar2 default hr_api.g_varchar2
  ,p_role_information10             in     varchar2 default hr_api.g_varchar2
  ,p_role_information11             in     varchar2 default hr_api.g_varchar2
  ,p_role_information12             in     varchar2 default hr_api.g_varchar2
  ,p_role_information13             in     varchar2 default hr_api.g_varchar2
  ,p_role_information14             in     varchar2 default hr_api.g_varchar2
  ,p_role_information15             in     varchar2 default hr_api.g_varchar2
  ,p_role_information16             in     varchar2 default hr_api.g_varchar2
  ,p_role_information17             in     varchar2 default hr_api.g_varchar2
  ,p_role_information18             in     varchar2 default hr_api.g_varchar2
  ,p_role_information19             in     varchar2 default hr_api.g_varchar2
  ,p_role_information20             in     varchar2 default hr_api.g_varchar2
  ,p_old_end_date                   in     date     default hr_api.g_date     -- fix 1370960
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_role';
  l_role_id                per_roles.role_id%TYPE;
  l_object_version_number  per_roles.object_version_number%TYPE;
  l_effective_date         date;
  l_start_date             per_roles.start_date%TYPE;
  l_end_date               per_roles.end_date%TYPE;
  l_confidential_date      per_roles.confidential_date%TYPE;
  l_end_of_rights_date     per_roles.end_of_rights_date%TYPE;
  l_old_end_date           per_roles.old_end_date%TYPE; -- fix 1370960
  l_temp_ovn               number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_role;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  l_temp_ovn              := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_start_date     := trunc(p_start_date);
  l_end_date       := trunc(p_end_date);
  l_confidential_date := trunc(p_confidential_date);
  l_end_of_rights_date := trunc(p_end_of_rights_date);
  l_old_end_date   := trunc(p_old_end_date); -- fix 1370960
  --
  -- Call Before Process User Hook
  --
  begin
 per_supplementary_role_bk2.update_supplementary_role_b
  (p_effective_date              => l_effective_date
  ,p_role_id                     => p_role_id
  ,p_object_version_number       => p_object_version_number
  ,p_start_date                  => l_start_date
  ,p_end_date                    => l_end_date
  ,p_confidential_date           => l_confidential_date
  ,p_emp_rights_flag             => p_emp_rights_flag
  ,p_end_of_rights_date          => l_end_of_rights_date
  ,p_primary_contact_flag        => p_primary_contact_flag
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
  ,p_role_information_category   => p_role_information_category
  ,p_role_information1           => p_role_information1
  ,p_role_information2           => p_role_information2
  ,p_role_information3           => p_role_information3
  ,p_role_information4           => p_role_information4
  ,p_role_information5           => p_role_information5
  ,p_role_information6           => p_role_information6
  ,p_role_information7           => p_role_information7
  ,p_role_information8           => p_role_information8
  ,p_role_information9           => p_role_information9
  ,p_role_information10          => p_role_information10
  ,p_role_information11          => p_role_information11
  ,p_role_information12          => p_role_information12
  ,p_role_information13          => p_role_information13
  ,p_role_information14          => p_role_information14
  ,p_role_information15          => p_role_information15
  ,p_role_information16          => p_role_information16
  ,p_role_information17          => p_role_information17
  ,p_role_information18          => p_role_information18
  ,p_role_information19          => p_role_information19
  ,p_role_information20          => p_role_information20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_supplementary_role_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
 per_rol_upd.upd
  (p_effective_date              => l_effective_date
  ,p_role_id                     => p_role_id
  ,p_object_version_number       => l_object_version_number
  ,p_start_date                  => l_start_date
  ,p_end_date                    => l_end_date
  ,p_confidential_date           => l_confidential_date
  ,p_emp_rights_flag             => p_emp_rights_flag
  ,p_end_of_rights_date          => l_end_of_rights_date
  ,p_primary_contact_flag        => p_primary_contact_flag
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
  ,p_role_information_category   => p_role_information_category
  ,p_role_information1           => p_role_information1
  ,p_role_information2           => p_role_information2
  ,p_role_information3           => p_role_information3
  ,p_role_information4           => p_role_information4
  ,p_role_information5           => p_role_information5
  ,p_role_information6           => p_role_information6
  ,p_role_information7           => p_role_information7
  ,p_role_information8           => p_role_information8
  ,p_role_information9           => p_role_information9
  ,p_role_information10          => p_role_information10
  ,p_role_information11          => p_role_information11
  ,p_role_information12          => p_role_information12
  ,p_role_information13          => p_role_information13
  ,p_role_information14          => p_role_information14
  ,p_role_information15          => p_role_information15
  ,p_role_information16          => p_role_information16
  ,p_role_information17          => p_role_information17
  ,p_role_information18          => p_role_information18
  ,p_role_information19          => p_role_information19
  ,p_role_information20          => p_role_information20
  ,p_old_end_date                => l_old_end_date -- fix 1370960
  );
  --
  -- Call After Process User Hook
  --
  begin
 per_supplementary_role_bk2.update_supplementary_role_a
  (p_effective_date              => l_effective_date
  ,p_role_id                     => p_role_id
  ,p_object_version_number       => l_object_version_number
  ,p_start_date                  => l_start_date
  ,p_end_date                    => l_end_date
  ,p_confidential_date           => l_confidential_date
  ,p_emp_rights_flag             => p_emp_rights_flag
  ,p_end_of_rights_date          => l_end_of_rights_date
  ,p_primary_contact_flag        => p_primary_contact_flag
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
  ,p_role_information_category   => p_role_information_category
  ,p_role_information1           => p_role_information1
  ,p_role_information2           => p_role_information2
  ,p_role_information3           => p_role_information3
  ,p_role_information4           => p_role_information4
  ,p_role_information5           => p_role_information5
  ,p_role_information6           => p_role_information6
  ,p_role_information7           => p_role_information7
  ,p_role_information8           => p_role_information8
  ,p_role_information9           => p_role_information9
  ,p_role_information10          => p_role_information10
  ,p_role_information11          => p_role_information11
  ,p_role_information12          => p_role_information12
  ,p_role_information13          => p_role_information13
  ,p_role_information14          => p_role_information14
  ,p_role_information15          => p_role_information15
  ,p_role_information16          => p_role_information16
  ,p_role_information17          => p_role_information17
  ,p_role_information18          => p_role_information18
  ,p_role_information19          => p_role_information19
  ,p_role_information20          => p_role_information20
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_supplementary_role_a'
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
    rollback to update_role;
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
    p_object_version_number := l_temp_ovn;
    rollback to update_role;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_supplementary_role;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_supplementary_role >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_supplementary_role
  (p_validate                      in     boolean  default false
  ,p_role_id                       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_role';
  l_election_candidate_id     per_election_candidates.election_candidate_id%TYPE;
  l_election_ovn     per_election_candidates.object_version_number%TYPE;
  l_election_role_id       per_election_candidates.role_id%TYPE;
  --
  -- Cursor to select candidates to have the role id removed from
  --
  cursor csr_candidate_update (p_role_id number) is
  select election_candidate_id, object_version_number
  from per_election_candidates
  where role_id = p_role_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_role;
  --
  -- Call Before Process User Hook
  --
  begin
    per_supplementary_role_bk3.delete_supplementary_role_b
     (p_role_id                 => p_role_id,
      p_object_version_number   => p_object_version_number
     );
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_supplementary_role_b',
           p_hook_type   => 'BP'
          );
  end;
  --
  --
  hr_utility.set_location(l_proc, 7);
 -- Changes made for bug 5475480.
 -- First un-link the role from candidate record and then delete the person role record.
  l_election_role_id := null;
  --
  open csr_candidate_update(p_role_id);

  loop
   fetch csr_candidate_update into l_election_candidate_id, l_election_ovn;
   exit when csr_candidate_update%notfound;
    hr_elc_candidate_api.update_election_candidate
    (p_election_candidate_id      => l_election_candidate_id
    ,p_object_version_number      => l_election_ovn
    ,p_role_id                    => l_election_role_id);
  end loop;
  close csr_candidate_update;

  --
  -- Process Logic
  --
  per_rol_del.del
  (p_role_id                       => p_role_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Call After Process User Hook
  begin
    per_supplementary_role_bk3.delete_supplementary_role_a
     (p_role_id                 => p_role_id,
      p_object_version_number   => p_object_version_number
     );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
           (p_module_name  => 'delete_supplementary_role_a',
            p_hook_type   => 'AP'
           );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_role;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  --
  ROLLBACK TO delete_role;
  --
  raise;
  --
end delete_supplementary_role;
--
end per_supplementary_role_api;

/
