--------------------------------------------------------
--  DDL for Package Body OTA_LP_SECTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LP_SECTION_API" as
/* $Header: otlpcapi.pkb 120.0 2005/05/29 07:20:34 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_LP_SECTION_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_LP_SECTION >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_lp_section
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_section_name                  in     varchar2
  ,p_description                   in     varchar2  default null
  ,p_learning_path_id              in     number
  ,p_section_sequence              in     number
  ,p_completion_type_code          in     varchar2
  ,p_no_of_mandatory_courses       in     number    default null
  ,p_attribute_category            in     varchar2  default null
  ,p_attribute1                    in     varchar2  default null
  ,p_attribute2                    in     varchar2  default null
  ,p_attribute3                    in     varchar2  default null
  ,p_attribute4                    in     varchar2  default null
  ,p_attribute5                    in     varchar2  default null
  ,p_attribute6                    in     varchar2  default null
  ,p_attribute7                    in     varchar2  default null
  ,p_attribute8                    in     varchar2  default null
  ,p_attribute9                    in     varchar2  default null
  ,p_attribute10                   in     varchar2  default null
  ,p_attribute11                   in     varchar2  default null
  ,p_attribute12                   in     varchar2  default null
  ,p_attribute13                   in     varchar2  default null
  ,p_attribute14                   in     varchar2  default null
  ,p_attribute15                   in     varchar2  default null
  ,p_attribute16                   in     varchar2  default null
  ,p_attribute17                   in     varchar2  default null
  ,p_attribute18                   in     varchar2  default null
  ,p_attribute19                   in     varchar2  default null
  ,p_attribute20                   in     varchar2  default null
  ,p_learning_path_section_id          out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Learning Path Section';
  l_learning_path_section_id number;
  l_object_version_number   number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_lp_section;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    ota_lp_section_bk1.create_lp_section_b
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_section_name                => p_section_name
  ,p_description                 => p_description
  ,p_learning_path_id            => p_learning_path_id
  ,p_section_sequence            => p_section_sequence
  ,p_completion_type_code        => p_completion_type_code
  ,p_no_of_mandatory_courses     => p_no_of_mandatory_courses
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
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_Lp_Section'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_lpc_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_business_group_id              => p_business_group_id
  ,p_learning_path_id               => p_learning_path_id
  ,p_section_sequence               => p_section_sequence
  ,p_completion_type_code           => p_completion_type_code
  ,p_no_of_mandatory_courses        => p_no_of_mandatory_courses
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
  ,p_object_version_number          => l_object_version_number
  ,p_learning_path_section_id       => l_learning_path_section_id
  );
  --
  --
  -- Set all output arguments
  --
  p_learning_path_section_id        := l_learning_path_section_id;
  p_object_version_number   := l_object_version_number;


  ota_lst_ins.ins_tl
    (  p_effective_date               => p_effective_date
      ,p_language_code                => USERENV('LANG')
      ,p_learning_path_section_id     => p_learning_path_section_id
      ,p_name                         => rtrim(p_section_name)
      ,p_description                  => p_description
  );

  -- Call After Process User Hook
  --
  begin
  ota_lp_section_bk1.create_lp_section_a
  (p_effective_date                 => l_effective_date
  ,p_business_group_id              => p_business_group_id
  ,p_section_name                   => p_section_name
  ,p_description                    => p_description
  ,p_learning_path_id               => p_learning_path_id
  ,p_section_sequence               => p_section_sequence
  ,p_completion_type_code           => p_completion_type_code
  ,p_no_of_mandatory_courses        => p_no_of_mandatory_courses
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
  ,p_learning_path_section_id       => l_learning_path_section_id
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_Lp_Section'
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
  p_learning_path_section_id := l_learning_path_section_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_lp_section;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_learning_path_section_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_lp_section;
    p_learning_path_section_id := null;
    p_object_version_number :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_lp_section;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_lp_section >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_lp_section
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_learning_path_section_id      in     number
  ,p_section_name                  in     varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_section_sequence              in     number   default hr_api.g_number
  ,p_completion_type_code          in     varchar2 default hr_api.g_varchar2
  ,p_no_of_mandatory_courses       in     number   default hr_api.g_number
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
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Learning Path Section';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;

  l_lpm_ovn                 ota_learning_path_members.object_version_number%TYPE;
  l_old_comp_type           ota_lp_sections.completion_type_code%TYPE;
  l_no_of_mandatory_courses ota_lp_sections.no_of_mandatory_courses%TYPE := p_no_of_mandatory_courses;

  CURSOR comp_type IS
  SELECT completion_type_code
    FROM ota_lp_sections
   WHERE learning_path_section_id = p_learning_path_section_id;

  CURSOR get_lpms IS
  SELECT learning_path_member_id,
         object_version_number,
         activity_version_id,
         course_sequence
    FROM ota_learning_path_members
   WHERE learning_path_section_id = p_learning_path_section_id
     AND (duration IS NOT NULL OR
          duration_units is not null OR
          notify_days_before_target IS NOT NULL);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_lp_section;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
   OPEN comp_type;
 FETCH comp_type INTO l_old_comp_type;
 CLOSE comp_type;

  IF l_old_comp_type = 'S' AND
     p_completion_type_code <> 'S' AND
     p_no_of_mandatory_courses IS NOT NULL
THEN l_no_of_mandatory_courses := null;
 END IF;

  -- Call Before Process User Hook
  --
  begin
    ota_lp_section_bk2.update_lp_section_b
  (p_effective_date                 => l_effective_date
  ,p_learning_path_section_id       => p_learning_path_section_id
  ,p_section_name                   => p_section_name
  ,p_description                    => p_description
  ,p_object_version_number          => l_object_version_number
  ,p_section_sequence               => p_section_sequence
  ,p_completion_type_code           => p_completion_type_code
  ,p_no_of_mandatory_courses        => l_no_of_mandatory_courses
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
        (p_module_name => 'Update_Lp_Section'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_lpc_upd.upd
  (p_effective_date                 => l_effective_date
  ,p_learning_path_section_id       => p_learning_path_section_id
  ,p_object_version_number          => l_object_version_number
  ,p_section_sequence               => p_section_sequence
  ,p_completion_type_code           => p_completion_type_code
  ,p_no_of_mandatory_courses        => l_no_of_mandatory_courses
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

  ota_lst_upd.upd_tl
 ( p_effective_date               => p_effective_date
  ,p_language_code                => USERENV('LANG')
  ,p_learning_path_section_id     => p_learning_path_section_id
  ,p_name                         => rtrim(p_section_name)
  ,p_description                  => p_description
  );


  -- Call After Process User Hook
  --
  begin
  ota_lp_section_bk2.update_lp_section_a
  (p_effective_date                 => l_effective_date
  ,p_learning_path_section_id       => p_learning_path_section_id
  ,p_section_name                   => p_section_name
  ,p_description                    => p_description
  ,p_object_version_number          => l_object_version_number
  ,p_section_sequence               => p_section_sequence
  ,p_completion_type_code           => p_completion_type_code
  ,p_no_of_mandatory_courses        => l_no_of_mandatory_courses
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
        (p_module_name => 'Update_Lp_Section'
        ,p_hook_type   => 'AP'
        );
  end;
  --

 IF l_old_comp_type = 'M' AND p_completion_type_code <> 'M' THEN
    FOR csr_lpms IN get_lpms
    LOOP
    l_lpm_ovn := csr_lpms.object_version_number;

    ota_lp_member_api.update_learning_path_member
       (p_validate                      => p_validate
       ,p_effective_date                => l_effective_date
       ,p_learning_path_member_id       => csr_lpms.learning_path_member_id
       ,p_object_version_number         => l_lpm_ovn
       ,p_activity_version_id           => csr_lpms.activity_version_id
       ,p_course_sequence               => csr_lpms.course_sequence
       ,p_duration                      => null
       ,p_duration_units                => null
       ,p_notify_days_before_target     => null);

     END LOOP;
 END IF;

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
    rollback to update_lp_section;
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
    rollback to update_lp_section;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_object_version_number := l_object_version_number;
    raise;
end update_lp_section;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_lp_section >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lp_section
  (p_validate                      in     boolean  default false
  ,p_learning_path_section_id       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Learning Path Section';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_lp_section;
  --
  -- Call Before Process User Hook
  --
  begin
    ota_lp_section_bk3.delete_lp_section_b
    (p_learning_path_section_id     => p_learning_path_section_id
    ,p_object_version_number       => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_Learning_Path_Section'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  OTA_lpc_del.del
  (p_learning_path_section_id        => p_learning_path_section_id
  ,p_object_version_number          => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_lp_section_bk3.delete_lp_section_a
  (p_learning_path_section_id     => p_learning_path_section_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_Lp_Section'
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
    rollback to delete_lp_section;
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
    rollback to delete_lp_section;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_lp_section;
--
end ota_lp_section_api;

/
