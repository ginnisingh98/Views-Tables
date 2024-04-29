--------------------------------------------------------
--  DDL for Package Body OTA_CERT_MBR_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CERT_MBR_ENROLLMENT_API" as
/* $Header: otcmeapi.pkb 120.1.12010000.2 2010/04/01 08:58:56 pekasi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_CERT_MBR_ENROLLMENT_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_cert_mbr_enrollment    >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_cert_mbr_enrollment
(
  p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_cert_prd_enrollment_id       in number,
  p_cert_member_id               in number,
  p_member_status_code           in varchar2,
  p_completion_date              in date             default null,
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
  p_cert_mbr_enrollment_id       out nocopy number,
  p_object_version_number        out nocopy number
    ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_cert_mbr_enrollment';
  l_cert_mbr_enrollment_id number;
  l_object_version_number   number;
  l_effective_date date;

  l_member_status_code	ota_cert_mbr_enrollments.member_status_code%TYPE := p_member_status_code;
  l_completion_date     ota_cert_mbr_enrollments.completion_date%TYPE := p_completion_date;
  l_activity_version_id	ota_activity_versions.activity_version_id%TYPE;

  CURSOR csr_get_course_id IS
  SELECT object_id
    FROM ota_certification_members
   WHERE certification_member_id = p_cert_member_id;

 l_mode varchar2(1);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_cert_mbr_enrollment;
  l_effective_date := trunc(p_effective_date);

  IF p_member_status_code = 'PLANNED' THEN
     OPEN csr_get_course_id;
    FETCH csr_get_course_id INTO l_activity_version_id;
    CLOSE csr_get_course_id;
    l_mode := 'C';
     ota_cme_util.calculate_cme_status(p_activity_version_id 	=> l_activity_version_id,
                                                 p_cert_prd_enrollment_id => p_cert_prd_enrollment_id,
                                                 p_mode => l_mode,
                                                 p_member_status_code	=> l_member_status_code,
                                                 p_completion_date      => l_completion_date);
 END IF;

  begin
  OTA_CERT_MBR_ENROLLMENT_bk1.create_cert_mbr_enrollment_b
  (  p_effective_date               => p_effective_date
    ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
    ,p_cert_member_id               => p_cert_member_id
    ,p_member_status_code           => l_member_status_code
    ,p_completion_date              => l_completion_date
    ,p_business_group_id            => p_business_group_id
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
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cert_mbr_enrollment'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_cme_ins.ins
  (
   p_effective_date                 =>   p_effective_date
  ,p_cert_prd_enrollment_id         =>   p_cert_prd_enrollment_id
  ,p_cert_member_id                 =>   p_cert_member_id
  ,p_member_status_code             =>   l_member_status_code
  ,p_completion_date                =>   l_completion_date
  ,p_business_group_id              =>   p_business_group_id
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
  ,p_cert_mbr_enrollment_id         =>   l_cert_mbr_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  );
  --
  -- Set all output arguments
  --
  p_cert_mbr_enrollment_id  := l_cert_mbr_enrollment_id;
  p_object_version_number   := l_object_version_number;



  begin
  OTA_CERT_MBR_ENROLLMENT_bk1.create_cert_mbr_enrollment_a
   ( p_effective_date               => p_effective_date
    ,p_cert_mbr_enrollment_id       => p_cert_mbr_enrollment_id
    ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
    ,p_cert_member_id               => p_cert_member_id
    ,p_member_status_code           => l_member_status_code
    ,p_completion_date              => l_completion_date
    ,p_business_group_id            => p_business_group_id
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
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cert_mbr_enrollment'
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
    rollback to CREATE_cert_mbr_enrollment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cert_mbr_enrollment_id  := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_cert_mbr_enrollment;
    p_cert_mbr_enrollment_id  := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_cert_mbr_enrollment;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_cert_mbr_enrollment >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cert_mbr_enrollment
  (p_effective_date               in     date
  ,p_cert_mbr_enrollment_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_cert_prd_enrollment_id       in     number
  ,p_cert_member_id               in     number
  ,p_member_status_code           in     varchar2
  ,p_completion_date              in     date      default hr_api.g_date
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     boolean          default false
   ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Cert Enrollment';
  l_object_version_number   number := p_object_version_number;
  l_effective_date date;

  l_member_status_code	    ota_cert_mbr_enrollments.member_status_code%TYPE := p_member_status_code;
  l_completion_date         ota_cert_mbr_enrollments.completion_date%TYPE := p_completion_date;
  l_activity_version_id	ota_activity_versions.activity_version_id%TYPE;
  l_cert_prd_enrollment_id    ota_cert_prd_enrollments.cert_enrollment_id%TYPE := p_cert_prd_enrollment_id;

  CURSOR csr_get_course_id IS
  SELECT cmb.object_id,
         cpe.cert_prd_enrollment_id
    FROM ota_certification_members cmb,
         ota_cert_mbr_enrollments cme,
         ota_cert_prd_enrollments cpe
   WHERE cme.cert_mbr_enrollment_id = p_cert_mbr_enrollment_id
     AND cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
     AND cme.cert_member_id = cmb.certification_member_id;

 l_mode varchar2(1);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_cert_mbr_enrollment;
  l_effective_date := trunc(p_effective_date);

  IF p_member_status_code <> 'CANCELLED' THEN
      FOR rec_course IN csr_get_course_id
     LOOP
          l_activity_version_id := rec_course.object_id;
          l_cert_prd_enrollment_id    := rec_course.cert_prd_enrollment_id;
     EXIT;
      END LOOP;
     l_mode := 'U';
     ota_cme_util.calculate_cme_status(p_activity_version_id 	  => l_activity_version_id,
                                                 p_cert_prd_enrollment_id => l_cert_prd_enrollment_id,
                                                 p_mode => l_mode,
                                                 p_member_status_code	  => l_member_status_code,
                                                 p_completion_date        => l_completion_date);

     if(p_member_status_code is not null) then
        l_member_status_code := p_member_status_code;
     end if;

     if(p_completion_date is not null) then
        l_completion_date := p_completion_date;
     end if;

  END IF;

  begin
  OTA_CERT_MBR_ENROLLMENT_bk2.update_cert_mbr_enrollment_b
  (  p_effective_date               => p_effective_date
    ,p_cert_mbr_enrollment_id       => p_cert_mbr_enrollment_id
    ,p_object_version_number        => p_object_version_number
    ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
    ,p_cert_member_id               => p_cert_member_id
    ,p_member_status_code           => l_member_status_code
    ,p_completion_date              => l_completion_date
    ,p_business_group_id            => p_business_group_id
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
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cert_mbr_enrollment'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Process Logic
  --

 ota_cme_upd.upd
  (
   p_effective_date                 =>   p_effective_date
  ,p_cert_mbr_enrollment_id         =>   p_cert_mbr_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  ,p_cert_prd_enrollment_id         =>   p_cert_prd_enrollment_id
  ,p_cert_member_id                 =>   p_cert_member_id
  ,p_member_status_code             =>   l_member_status_code
  ,p_completion_date                =>   l_completion_date
  ,p_business_group_id              =>   p_business_group_id
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
  );


  begin
  OTA_CERT_MBR_ENROLLMENT_bk2.update_cert_mbr_enrollment_a
  (  p_effective_date               => p_effective_date
    ,p_cert_mbr_enrollment_id       => p_cert_mbr_enrollment_id
    ,p_object_version_number        => p_object_version_number
    ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
    ,p_cert_member_id               => p_cert_member_id
    ,p_member_status_code           => l_member_status_code
    ,p_completion_date              => l_completion_date
    ,p_business_group_id            => p_business_group_id
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
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CERT_MBR_ENROLLMENT'
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
    rollback to UPDATE_cert_mbr_enrollment;
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
    rollback to UPDATE_cert_mbr_enrollment;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_cert_mbr_enrollment;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_cert_mbr_enrollment >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cert_mbr_enrollment
  (p_cert_mbr_enrollment_id        in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'DELETE_cert_mbr_enrollment';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_cert_mbr_enrollment;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  OTA_CERT_MBR_ENROLLMENT_bk3.delete_cert_mbr_enrollment_b
  (p_cert_mbr_enrollment_id         => p_cert_mbr_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cert_mbr_enrollment'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  ota_cme_del.del
  (
  p_cert_mbr_enrollment_id   => p_cert_mbr_enrollment_id,
  p_object_version_number    => p_object_version_number
  );


  begin
  OTA_CERT_MBR_ENROLLMENT_bk3.delete_cert_mbr_enrollment_a
  (p_cert_mbr_enrollment_id             => p_cert_mbr_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cert_mbr_enrollment'
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
    rollback to DELETE_cert_mbr_enrollment;
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
    rollback to DELETE_cert_mbr_enrollment;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_cert_mbr_enrollment;
--
end OTA_CERT_MBR_ENROLLMENT_api;

/
