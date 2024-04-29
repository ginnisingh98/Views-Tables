--------------------------------------------------------
--  DDL for Package Body OTA_LP_MEMBER_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LP_MEMBER_ENROLLMENT_API" as
/* $Header: otlmeapi.pkb 120.0.12010000.2 2009/05/14 07:44:34 pekasi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_LP_MEMBER_ENROLLMENT_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_LP_MEMBER_ENROLLMENT    >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_lp_member_enrollment
( p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_lp_enrollment_id             in number,
  p_learning_path_section_id     in number           default null,
  p_learning_path_member_id      in number           default null,
  p_member_status_code                in varchar2,
  p_completion_target_date       in date             default null,
  p_completion_date               in date             default null,
  p_business_group_id            in number,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_attribute21                  in varchar2         default null,
  p_attribute22                  in varchar2         default null,
  p_attribute23                  in varchar2         default null,
  p_attribute24                  in varchar2         default null,
  p_attribute25                  in varchar2         default null,
  p_attribute26                  in varchar2         default null,
  p_attribute27                  in varchar2         default null,
  p_attribute28                  in varchar2         default null,
  p_attribute29                  in varchar2         default null,
  p_attribute30                  in varchar2         default null,
  p_creator_person_id            in number           default null,
  p_event_id                     in number           default null,
  p_lp_member_enrollment_id      out nocopy number,
  p_object_version_number        out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_lp_member_enrollment';
  l_lp_member_enrollment_id number;
  l_object_version_number   number;
  l_effective_date date;

  l_member_status_code	ota_lp_member_enrollments.member_status_code%TYPE := p_member_status_code;
  l_completion_date     ota_lp_member_enrollments.completion_date%TYPE := p_completion_date;
  l_activity_version_id	ota_activity_versions.activity_version_id%TYPE;

  CURSOR csr_get_course_id IS
  SELECT activity_version_id
    FROM ota_learning_path_members
   WHERE learning_path_member_id = p_learning_path_member_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_LP_MEMBER_ENROLLMENT;
  l_effective_date := trunc(p_effective_date);

  IF p_member_status_code = 'PLANNED' THEN
     OPEN csr_get_course_id;
    FETCH csr_get_course_id INTO l_activity_version_id;
    CLOSE csr_get_course_id;
     ota_lrng_path_member_util.calculate_lme_status(p_activity_version_id 	=> l_activity_version_id,
                                                    p_lp_enrollment_id 		=> p_lp_enrollment_id,
                                                    p_member_status_code	=> l_member_status_code,
                                                    p_completion_date           => l_completion_date);
 END IF;

  begin
  ota_lp_member_enrollment_bk1.create_lp_member_enrollment_b
  (  p_effective_date               => l_effective_date
    ,p_validate                     => p_validate
    ,p_lp_enrollment_id             => p_lp_enrollment_id
    ,p_business_group_id            => p_business_group_id
    ,p_learning_path_section_id     => p_learning_path_section_id
    ,p_learning_path_member_id      => p_learning_path_member_id
    ,p_member_status_code           => l_member_status_code
    ,p_completion_target_date       => p_completion_target_date
    ,p_completion_date              => l_completion_date
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_creator_person_id            => p_creator_person_id
    ,p_event_id                     => p_event_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LP_MEMBER_ENROLLMENT'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_lme_ins.ins
  (
   p_effective_date                 =>   l_effective_date
  ,p_lp_enrollment_id               =>   p_lp_enrollment_id
  ,p_learning_path_section_id       =>   p_learning_path_section_id
  ,p_learning_path_member_id        =>   p_learning_path_member_id
  ,p_member_status_code             =>   l_member_status_code
  ,p_business_group_id              =>   p_business_group_id
  ,p_completion_target_date         =>   p_completion_target_date
  ,p_completion_date                =>   l_completion_date
  ,p_attribute_category             =>   p_attribute_category
  ,p_attribute1                     =>   p_attribute1
  ,p_attribute2                     =>   p_attribute2
  ,p_attribute3                     =>   p_attribute3
  ,p_attribute4                     =>   p_attribute4
  ,p_attribute5                     =>   p_attribute5
  ,p_attribute6                     =>   p_attribute6
  ,p_attribute7                     =>   p_attribute7
  ,p_attribute8                     =>   p_attribute8
  ,p_attribute9                     =>   p_attribute9
  ,p_attribute10                    =>   p_attribute10
  ,p_attribute11                    =>   p_attribute11
  ,p_attribute12                    =>   p_attribute12
  ,p_attribute13                    =>   p_attribute13
  ,p_attribute14                    =>   p_attribute14
  ,p_attribute15                    =>   p_attribute15
  ,p_attribute16                    =>   p_attribute16
  ,p_attribute17                    =>   p_attribute17
  ,p_attribute18                    =>   p_attribute18
  ,p_attribute19                    =>   p_attribute19
  ,p_attribute20                    =>   p_attribute20
  ,p_attribute21                    =>   p_attribute21
  ,p_attribute22                    =>   p_attribute22
  ,p_attribute23                    =>   p_attribute23
  ,p_attribute24                    =>   p_attribute24
  ,p_attribute25                    =>   p_attribute25
  ,p_attribute26                    =>   p_attribute26
  ,p_attribute27                    =>   p_attribute27
  ,p_attribute28                    =>   p_attribute28
  ,p_attribute29                    =>   p_attribute29
  ,p_attribute30                    =>   p_attribute30
  ,p_creator_person_id              =>   p_creator_person_id
  ,p_event_id                       =>   p_event_id
  ,p_lp_member_enrollment_id        =>   l_lp_member_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  );
  --
  -- Set all output arguments
  --
  p_lp_member_enrollment_id        := l_lp_member_enrollment_id;
  p_object_version_number   := l_object_version_number;

  begin
  ota_lp_member_enrollment_bk1.create_lp_member_enrollment_a
  (  p_effective_date               => l_effective_date
    ,p_validate                     => p_validate
    ,p_lp_enrollment_id             => p_lp_enrollment_id
    ,p_business_group_id            => p_business_group_id
    ,p_learning_path_section_id     => p_learning_path_section_id
    ,p_learning_path_member_id      => p_learning_path_member_id
    ,p_member_status_code           => l_member_status_code
    ,p_completion_target_date       => p_completion_target_date
    ,p_completion_date              => l_completion_date
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_creator_person_id            => p_creator_person_id
    ,p_event_id                     => p_event_id
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LP_MEMBER_ENROLLMENT'
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
    rollback to CREATE_LP_MEMBER_ENROLLMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_lp_member_enrollment_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_LP_MEMBER_ENROLLMENT;
    p_lp_member_enrollment_id     := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_lp_member_enrollment;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_LP_MEMBER_ENROLLMENT >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_lp_member_enrollment
( p_effective_date               in date,
  p_lp_member_enrollment_id      in number,
  p_object_version_number        in out nocopy number,
  p_lp_enrollment_id             in number           default hr_api.g_number,
  p_learning_path_section_id     in number           default hr_api.g_number,
  p_learning_path_member_id      in number           default hr_api.g_number,
  p_member_status_code                in varchar2         default hr_api.g_varchar2,
  p_completion_target_date       in date             default hr_api.g_date,
  p_completion_date               in date             default hr_api.g_date,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_creator_person_id            in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_validate                     in boolean          default false,
  p_event_id                     in number           default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Learning Path';
  l_object_version_number   number := p_object_version_number;
  l_effective_date date;
  l_member_status_code	    ota_lp_member_enrollments.member_status_code%TYPE := p_member_status_code;
  l_completion_date         ota_lp_member_enrollments.completion_date%TYPE := p_completion_date;
  l_activity_version_id	ota_activity_versions.activity_version_id%TYPE;
  l_lp_enrollment_id    ota_lp_enrollments.lp_enrollment_id%TYPE := p_lp_enrollment_id;

  CURSOR csr_get_course_id IS
  SELECT lpm.activity_version_id,
         lpe.lp_enrollment_id
    FROM ota_learning_path_members lpm,
         ota_lp_member_enrollments lme,
         ota_lp_enrollments lpe
   WHERE lme.lp_member_enrollment_id = p_lp_member_enrollment_id
     AND lpe.lp_enrollment_id = lme.lp_enrollment_id
     AND lme.learning_path_member_id = lpm.learning_path_member_id;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_LP_MEMBER_ENROLLMENT;
  l_effective_date := trunc(p_effective_date);

  IF p_member_status_code <> 'CANCELLED' THEN
      FOR cr_course IN csr_get_course_id
     LOOP
          l_activity_version_id := cr_course.activity_version_id;
          l_lp_enrollment_id    := cr_course.lp_enrollment_id;
     EXIT;
      END LOOP;
     ota_lrng_path_member_util.calculate_lme_status(p_activity_version_id 	=> l_activity_version_id,
                                                    p_lp_enrollment_id 		=> l_lp_enrollment_id,
                                                    p_member_status_code	=> l_member_status_code,
                                                    p_completion_date           => l_completion_date);
 END IF;

  begin
  ota_lp_member_enrollment_bk2.update_lp_member_enrollment_b
  (  p_effective_date               => p_effective_date
    ,p_lp_member_enrollment_id      => p_lp_member_enrollment_id
    ,p_object_version_number        => l_object_version_number
    ,p_lp_enrollment_id             => l_lp_enrollment_id
    ,p_learning_path_section_id     => p_learning_path_section_id
    ,p_learning_path_member_id      => p_learning_path_member_id
    ,p_member_status_code                => l_member_status_code
    ,p_completion_target_date       => p_completion_target_date
    ,p_completion_date               => l_completion_date
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_creator_person_id            => p_creator_person_id
    ,p_business_group_id            => p_business_group_id
    ,p_validate                     => p_validate
    ,p_event_id                     => p_event_id
    );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LP_MEMBER_ENROLLMENT'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  --
  -- Process Logic
  --
  ota_lme_upd.upd
  (
   p_effective_date                 =>   p_effective_date
  ,p_lp_member_enrollment_id        =>   p_lp_member_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  ,p_lp_enrollment_id               =>   l_lp_enrollment_id
  ,p_learning_path_section_id       =>   p_learning_path_section_id
  ,p_learning_path_member_id        =>   p_learning_path_member_id
  ,p_member_status_code                  =>   l_member_status_code
  ,p_business_group_id              =>   p_business_group_id
  ,p_completion_target_date         =>   p_completion_target_date
  ,p_completion_date                 =>   l_completion_date
  ,p_attribute_category             =>   p_attribute_category
  ,p_attribute1                     =>   p_attribute1
  ,p_attribute2                     =>   p_attribute2
  ,p_attribute3                     =>   p_attribute3
  ,p_attribute4                     =>   p_attribute4
  ,p_attribute5                     =>   p_attribute5
  ,p_attribute6                     =>   p_attribute6
  ,p_attribute7                     =>   p_attribute7
  ,p_attribute8                     =>   p_attribute8
  ,p_attribute9                     =>   p_attribute9
  ,p_attribute10                    =>   p_attribute10
  ,p_attribute11                    =>   p_attribute11
  ,p_attribute12                    =>   p_attribute12
  ,p_attribute13                    =>   p_attribute13
  ,p_attribute14                    =>   p_attribute14
  ,p_attribute15                    =>   p_attribute15
  ,p_attribute16                    =>   p_attribute16
  ,p_attribute17                    =>   p_attribute17
  ,p_attribute18                    =>   p_attribute18
  ,p_attribute19                    =>   p_attribute19
  ,p_attribute20                    =>   p_attribute20
  ,p_attribute21                    =>   p_attribute21
  ,p_attribute22                    =>   p_attribute22
  ,p_attribute23                    =>   p_attribute23
  ,p_attribute24                    =>   p_attribute24
  ,p_attribute25                    =>   p_attribute25
  ,p_attribute26                    =>   p_attribute26
  ,p_attribute27                    =>   p_attribute27
  ,p_attribute28                    =>   p_attribute28
  ,p_attribute29                    =>   p_attribute29
  ,p_attribute30                    =>   p_attribute30
  ,p_creator_person_id              =>   p_creator_person_id
  ,p_event_id                       =>   p_event_id
  );

  begin
  ota_lp_member_enrollment_bk2.update_lp_member_enrollment_a
  (  p_effective_date               => p_effective_date
    ,p_lp_member_enrollment_id      => p_lp_member_enrollment_id
    ,p_object_version_number        => l_object_version_number
    ,p_lp_enrollment_id             => l_lp_enrollment_id
    ,p_learning_path_section_id     => p_learning_path_section_id
    ,p_learning_path_member_id      => p_learning_path_member_id
    ,p_member_status_code           => l_member_status_code
    ,p_completion_target_date       => p_completion_target_date
    ,p_completion_date              => l_completion_date
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_creator_person_id            => p_creator_person_id
    ,p_business_group_id            => p_business_group_id
    ,p_validate                     => p_validate
    ,p_event_id                     => p_event_id
    );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LP_MEMBER_ENROLLMENT'
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
    rollback to UPDATE_LP_MEMBER_ENROLLMENT;
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
    rollback to UPDATE_LP_MEMBER_ENROLLMENT;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_lp_member_enrollment;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_LP_MEMBER_ENROLLMENT >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lp_member_enrollment
  (p_lp_member_enrollment_id       in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'DELETE_LP_MEMBER_ENROLLMENT';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_LP_MEMBER_ENROLLMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  ota_lp_member_enrollment_bk3.delete_lp_member_enrollment_b
  (p_lp_member_enrollment_id        => p_lp_member_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LP_MEMBER_ENROLLMENT'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  ota_lme_del.del
  (
  p_lp_member_enrollment_id  => p_lp_member_enrollment_id             ,
  p_object_version_number    => p_object_version_number
  );


  begin
  ota_lp_member_enrollment_bk3.delete_lp_member_enrollment_a
  (p_lp_member_enrollment_id        => p_lp_member_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LP_MEMBER_ENROLLMENT'
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
    rollback to DELETE_LP_MEMBER_ENROLLMENT;
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
    rollback to DELETE_LP_MEMBER_ENROLLMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_lp_member_enrollment;
--
end ota_lp_member_enrollment_api;

/
