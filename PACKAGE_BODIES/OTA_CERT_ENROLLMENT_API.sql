--------------------------------------------------------
--  DDL for Package Body OTA_CERT_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CERT_ENROLLMENT_API" as
/* $Header: otcreapi.pkb 120.17.12010000.5 2010/03/24 06:27:10 pekasi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_CERT_ENROLLMENT_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_cert_enrollment    >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cert_enrollment
(
  p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_certification_id             in number,
  p_person_id                    in number           default null,
  p_contact_id                   in number           default null,
  p_certification_status_code    in varchar2,
  p_completion_date              in date             default null,
  p_UNENROLLMENT_DATE            in date             default null,
  p_EXPIRATION_DATE              in date             default null,
  p_EARLIEST_ENROLL_DATE         in date             default null,
  p_IS_HISTORY_FLAG              in varchar2         default 'N',
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
  p_enrollment_date	         in date             default null,
  p_cert_enrollment_id           out nocopy number,
  p_object_version_number        out nocopy number
    ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_cert_enrollment';
  l_cert_enrollment_id number;
  l_object_version_number   number;
  l_effective_date date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_cert_enrollment;
  l_effective_date := trunc(p_effective_date);


  begin
  OTA_CERT_ENROLLMENT_bk1.create_cert_enrollment_b
  (  p_effective_date               => p_effective_date
    ,p_certification_id             => p_certification_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_certification_status_code    => p_certification_status_code
    ,p_completion_date              => p_completion_date
    ,p_UNENROLLMENT_DATE            => p_UNENROLLMENT_DATE
    ,p_EXPIRATION_DATE              => p_EXPIRATION_DATE
    ,p_EARLIEST_ENROLL_DATE         => p_EARLIEST_ENROLL_DATE
    ,p_IS_HISTORY_FLAG              => p_IS_HISTORY_FLAG
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
    ,p_enrollment_date              => p_enrollment_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cert_enrollment'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_cre_ins.ins
  (
   p_effective_date                 =>   p_effective_date
  ,p_certification_id               =>   p_certification_id
  ,p_certification_status_code      =>   p_certification_status_code
  ,p_IS_HISTORY_FLAG                =>   p_IS_HISTORY_FLAG
  ,p_person_id                      =>   p_person_id
  ,p_contact_id                     =>   p_contact_id
  ,p_completion_date                =>   p_completion_date
  ,p_business_group_id              =>   p_business_group_id
  ,p_UNENROLLMENT_DATE              =>   p_UNENROLLMENT_DATE
  ,p_EXPIRATION_DATE                =>   p_EXPIRATION_DATE
  ,p_EARLIEST_ENROLL_DATE           =>   p_EARLIEST_ENROLL_DATE
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
  ,p_enrollment_date                =>   p_enrollment_date
  ,p_cert_enrollment_id             =>   l_cert_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  );
  --
  -- Set all output arguments
  --
  p_cert_enrollment_id        := l_cert_enrollment_id;
  p_object_version_number   := l_object_version_number;

  begin
  OTA_CERT_ENROLLMENT_bk1.create_cert_enrollment_a
   ( p_effective_date               => p_effective_date
    ,p_cert_enrollment_id           => p_cert_enrollment_id
    ,p_certification_id             => p_certification_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_certification_status_code    => p_certification_status_code
    ,p_completion_date              => p_completion_date
    ,p_UNENROLLMENT_DATE            => p_UNENROLLMENT_DATE
    ,p_EXPIRATION_DATE              => p_EXPIRATION_DATE
    ,p_EARLIEST_ENROLL_DATE         => p_EARLIEST_ENROLL_DATE
    ,p_IS_HISTORY_FLAG              => p_IS_HISTORY_FLAG
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
    ,p_enrollment_date              => p_enrollment_date
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cert_enrollment'
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
    rollback to CREATE_cert_enrollment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cert_enrollment_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_cert_enrollment;
    p_cert_enrollment_id     := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_cert_enrollment;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_cert_enrollment >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cert_enrollment
  (p_effective_date               in     date
  ,p_cert_enrollment_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_certification_id             in     number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_certification_status_code    in     varchar2  default hr_api.g_varchar2
  ,p_completion_date              in     date      default hr_api.g_date
  ,p_unenrollment_date            in     date      default hr_api.g_date
  ,p_expiration_date              in     date      default hr_api.g_date
  ,p_earliest_enroll_date         in     date      default hr_api.g_date
  ,p_is_history_flag              in     varchar2  default hr_api.g_varchar2
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
  ,p_enrollment_date	          in     date      default hr_api.g_date
  ,p_validate                     in boolean          default false
   ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Cert Enrollment';
  l_object_version_number   number := p_object_version_number;
  l_effective_date date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_cert_enrollment;
  l_effective_date := trunc(p_effective_date);

  begin
  OTA_CERT_ENROLLMENT_bk2.update_cert_enrollment_b
  (  p_effective_date               => p_effective_date
    ,p_cert_enrollment_id           => p_cert_enrollment_id
    ,p_object_version_number        => p_object_version_number
    ,p_certification_id             => p_certification_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_certification_status_code    => p_certification_status_code
    ,p_completion_date              => p_completion_date
    ,p_UNENROLLMENT_DATE            => p_UNENROLLMENT_DATE
    ,p_EXPIRATION_DATE              => p_EXPIRATION_DATE
    ,p_EARLIEST_ENROLL_DATE         => p_EARLIEST_ENROLL_DATE
    ,p_IS_HISTORY_FLAG              => p_IS_HISTORY_FLAG
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
    ,p_enrollment_date              => p_enrollment_date
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cert_enrollment'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Process Logic
  --

 ota_cre_upd.upd
  (
   p_effective_date                 =>   p_effective_date
  ,p_cert_enrollment_id             =>   p_cert_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  ,p_certification_id               =>   p_certification_id
  ,p_certification_status_code      =>   p_certification_status_code
  ,p_IS_HISTORY_FLAG                =>   p_IS_HISTORY_FLAG
  ,p_completion_date                =>   p_completion_date
  ,p_business_group_id              =>   p_business_group_id
  ,p_person_id                      =>   p_person_id
  ,p_contact_id                     =>   p_contact_id
  ,p_UNENROLLMENT_DATE              =>   p_UNENROLLMENT_DATE
  ,p_EXPIRATION_DATE                =>   p_EXPIRATION_DATE
  ,p_EARLIEST_ENROLL_DATE           =>   p_EARLIEST_ENROLL_DATE
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
  ,p_enrollment_date              => p_enrollment_date
  );


  begin
  OTA_CERT_ENROLLMENT_bk2.update_cert_enrollment_a
  (  p_effective_date               => p_effective_date
    ,p_cert_enrollment_id           => p_cert_enrollment_id
    ,p_object_version_number        => p_object_version_number
    ,p_certification_id             => p_certification_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_certification_status_code    => p_certification_status_code
    ,p_completion_date              => p_completion_date
    ,p_UNENROLLMENT_DATE            => p_UNENROLLMENT_DATE
    ,p_EXPIRATION_DATE              => p_EXPIRATION_DATE
    ,p_EARLIEST_ENROLL_DATE         => p_EARLIEST_ENROLL_DATE
    ,p_IS_HISTORY_FLAG              => p_IS_HISTORY_FLAG
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
    ,p_enrollment_date              => p_enrollment_date
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cert_enrollment'
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
    rollback to UPDATE_cert_enrollment;
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
    rollback to UPDATE_cert_enrollment;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_cert_enrollment;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_cert_enrollment >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cert_enrollment
  (p_cert_enrollment_id            in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false

  ) is


  CURSOR get_person_info IS
  select person_id
  from ota_cert_enrollments
  where CERT_ENROLLMENT_ID = p_cert_enrollment_id;
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'DELETE_cert_enrollment';

 l_person_id number := -1;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

      OPEN get_person_info;
      FETCH get_person_info INTO l_person_id;
      CLOSE get_person_info;

  --
  -- Issue a savepoint
  --
  savepoint DELETE_cert_enrollment;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  OTA_CERT_ENROLLMENT_bk3.delete_cert_enrollment_b
  (p_cert_enrollment_id             => p_cert_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cert_enrollment'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  ota_cre_del.del
  (
  p_cert_enrollment_id       => p_cert_enrollment_id,
  p_object_version_number    => p_object_version_number
  );


  begin
  OTA_CERT_ENROLLMENT_bk3.delete_cert_enrollment_a
  (p_cert_enrollment_id             => p_cert_enrollment_id
    ,p_object_version_number        => p_object_version_number
    ,p_person_id                    => l_person_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cert_enrollment'
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
    rollback to DELETE_cert_enrollment;
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
    rollback to DELETE_cert_enrollment;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_cert_enrollment;

-- ----------------------------------------------------------------------------
-- |--------------------------< SUBSCRIBE_TO_CERTIFICATION>-------------------|
-- ----------------------------------------------------------------------------
procedure subscribe_to_certification
  (p_validate in boolean default false
  ,p_certification_id IN NUMBER
  ,p_person_id IN NUMBER default null
  ,p_contact_id IN NUMBER default null
  ,p_business_group_id IN NUMBER
  ,p_approval_flag IN VARCHAR2
  ,p_completion_date              in     date      default null
  ,p_unenrollment_date            in     date      default null
  ,p_expiration_date              in     date      default null
  ,p_earliest_enroll_date         in     date      default null
  ,p_is_history_flag              in     varchar2
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_enrollment_date	          in     date      default null
  ,p_cert_enrollment_id OUT NOCOPY NUMBER
  ,p_certification_status_code OUT NOCOPY VARCHAR2
  ,p_enroll_from         in varchar2 default null
  ) IS

CURSOR csr_cert_info IS
select
          b.certification_id certification_id
        , b.INITIAL_COMPLETION_DATE
        , b.INITIAL_COMPLETION_DURATION
        , b.INITIAL_COMPL_DURATION_UNITS
        , b.RENEWAL_DURATION
        , b.RENEWAL_DURATION_UNITS
        , b.NOTIFY_DAYS_BEFORE_EXPIRE
        , b.VALIDITY_DURATION
        , b.VALIDITY_DURATION_UNITS
        , b.RENEWABLE_FLAG
        , b.VALIDITY_START_TYPE
        , b.PUBLIC_FLAG
        , b.START_DATE_ACTIVE
        , b.END_DATE_ACTIVE
from ota_certifications_b b
where b.certification_id = p_certification_id;

CURSOR csr_recert IS
select
          cre.cert_enrollment_id,
          cre.certification_id,
          cre.object_version_number,
          cre.certification_status_code
  from ota_cert_enrollments cre
 where cre.certification_id = p_certification_id
    and (cre.person_id = p_person_id or cre.contact_id = p_contact_id);

CURSOR csr_cert_enrl(p_cert_enrollment_id  in ota_cert_enrollments.cert_enrollment_id%type) IS
select cert_enrollment_id, certification_id, certification_status_code, object_version_number, completion_date
FROM ota_cert_enrollments
where cert_enrollment_id = p_cert_enrollment_id;

CURSOR csr_prd_enrl(p_cert_enrollment_id  in ota_cert_enrollments.cert_enrollment_id%type) IS
select cert_prd_enrollment_id, period_status_code, object_version_number, completion_date
FROM ota_cert_prd_enrollments
where cert_enrollment_id = p_cert_enrollment_id
and trunc(sysdate) between trunc(cert_period_start_date) and nvl(trunc(cert_period_end_date),trunc(sysdate))
and period_status_code = 'ACTIVE' --Bug#7705069
order by cert_prd_enrollment_id desc;

CURSOR csr_cpe_exist(p_cert_enrollment_id  in ota_cert_enrollments.cert_enrollment_id%type) IS
select cert_prd_enrollment_id
FROM ota_cert_prd_enrollments
where cert_enrollment_id = p_cert_enrollment_id;


l_proc    varchar2(72) := g_package || ' subscribe_to_certification';
l_cert_rec csr_cert_info%ROWTYPE;
l_cert_enrl_rec csr_cert_enrl%ROWTYPE;
l_prd_enrl_rec csr_prd_enrl%ROWTYPE;
l_recert_rec csr_recert%ROWTYPE;

l_object_version_number1 number;
l_object_version_number2 number;

l_period_status_code VARCHAR2(30);
l_certification_status_code ota_cert_enrollments.certification_status_code%type;
l_cert_enrollment_id NUMBER;
l_cert_prd_enrollment_id NUMBER;
l_cert_mbr_enrollment_id NUMBER;

l_expiration_date DATE;
l_earliest_enroll_date DATE;

l_is_recert VARCHAR2(1);
l_is_appr_recert VARCHAR2(1) := 'N';

l_attribute_category VARCHAR2(30) := p_attribute_category;
l_attribute1 VARCHAR2(150) := p_attribute1 ;
l_attribute2 VARCHAR2(150) := p_attribute2 ;
l_attribute3 VARCHAR2(150) := p_attribute3 ;
l_attribute4 VARCHAR2(150) := p_attribute4 ;
l_attribute5 VARCHAR2(150) := p_attribute5 ;
l_attribute6 VARCHAR2(150) := p_attribute6 ;
l_attribute7 VARCHAR2(150) := p_attribute7 ;
l_attribute8 VARCHAR2(150) := p_attribute8 ;
l_attribute9 VARCHAR2(150) := p_attribute9 ;
l_attribute10 VARCHAR2(150) := p_attribute10 ;
l_attribute11 VARCHAR2(150) := p_attribute11 ;
l_attribute12 VARCHAR2(150) := p_attribute12 ;
l_attribute13 VARCHAR2(150) := p_attribute13 ;
l_attribute14 VARCHAR2(150) := p_attribute14 ;
l_attribute15 VARCHAR2(150) := p_attribute15 ;
l_attribute16 VARCHAR2(150) := p_attribute16 ;
l_attribute17 VARCHAR2(150) := p_attribute17 ;
l_attribute18 VARCHAR2(150) := p_attribute18 ;
l_attribute19 VARCHAR2(150) := p_attribute19 ;
l_attribute20 VARCHAR2(150) := p_attribute20 ;

l_dummy number;
l_o_cert_enroll_id number;
l_o_cert_enroll_status varchar2(100);

  BEGIN
      hr_utility.set_location('Entering:'|| l_proc, 10);

      OPEN csr_cert_info;
      FETCH csr_cert_info INTO l_cert_rec;
      CLOSE csr_cert_info;

      hr_multi_message.enable_message_list;
      savepoint create_cert_subscription;

      if (p_approval_flag = 'N' or p_approval_flag = 'S') then
         l_certification_status_code := 'ENROLLED';
         l_period_status_code := 'ENROLLED';
      else
         l_certification_status_code := 'AWAITING_APPROVAL';
      end if;

      hr_utility.set_location(' Step:'|| l_proc, 20);

      --check for initial subscription or resubscription to unsubscribed cert
      --re-cert is applicable if approvals is off and certification_status_code in 'CANCELLED'
      --or if approvals on and certification_status_code in 'AWAITING_APPROVAL' but has atleast one period.

      OPEN csr_recert;
      FETCH csr_recert INTO l_recert_rec;
      CLOSE csr_recert;

   -- needed for firing ntf from admin side
      l_o_cert_enroll_id := l_recert_rec.cert_enrollment_id;
      l_o_cert_enroll_status :=l_recert_rec.certification_status_code;


      hr_utility.set_location(' Step:'|| l_proc, 30);

      --check for approvals re-cert
      if (l_recert_rec.certification_status_code = 'AWAITING_APPROVAL') then
          open csr_cpe_exist(l_recert_rec.cert_enrollment_id);
          fetch csr_cpe_exist into l_dummy;
          if csr_cpe_exist%found then
             l_is_appr_recert := 'Y';
          end if;
          close csr_cpe_exist;
      end if;

      if (l_recert_rec.certification_status_code = 'CANCELLED' or l_recert_rec.certification_status_code = 'REJECTED' or l_is_appr_recert = 'Y') then
          l_is_recert := 'Y';
      else
    	  l_is_recert := 'N';
      end if;

      l_cert_enrollment_id := l_recert_rec.cert_enrollment_id;

      hr_utility.set_location(' Step:'|| l_proc, 40);

      --calculate exp and earliest enrol dates
	  --for onetime certs there's no expiration
      --for renewable certs calc based on initial_completion_date, INITIAL_COMPLETION_DURATION,
	  --validity_start_type and validity_duration

      if (l_cert_rec.renewable_flag = 'Y') then
          ota_cpe_util.calc_cre_dates(null, l_cert_rec.certification_id, 'I', l_earliest_enroll_date, l_expiration_date, p_enrollment_date);
      end if; --end renewal flag

      hr_utility.set_location(' Step:'|| l_proc, 50);

      --create or update CRE based on recert flag
      if (l_is_recert = 'N') then
         -- initial subscription
   	     --create cert enrollment only when the approval is off or enrl is sent for approval

	     if (p_approval_flag = 'N' or p_approval_flag = 'A') then

	     hr_utility.set_location(' Step:'|| l_proc, 60);
	     ota_utility.Get_Default_Value_Dff(
					   appl_short_name => 'OTA'
                           		  ,flex_field_name => 'OTA_CERT_ENROLLMENTS'
                        ,p_attribute_category           => l_attribute_category
                      			  ,p_attribute1                   => l_attribute1
					  ,p_attribute2                   => l_attribute2
					  ,p_attribute3                   => l_attribute3
					  ,p_attribute4                   => l_attribute4
					  ,p_attribute5                   => l_attribute5
					  ,p_attribute6                   => l_attribute6
					  ,p_attribute7                   => l_attribute7
					  ,p_attribute8                   => l_attribute8
					  ,p_attribute9                   => l_attribute9
					  ,p_attribute10                  => l_attribute10
					  ,p_attribute11                  => l_attribute11
					  ,p_attribute12                  => l_attribute12
					  ,p_attribute13                  => l_attribute13
					  ,p_attribute14                  => l_attribute14
					  ,p_attribute15                  => l_attribute15
					  ,p_attribute16                  => l_attribute16
					  ,p_attribute17                  => l_attribute17
					  ,p_attribute18                  => l_attribute18
					  ,p_attribute19                  => l_attribute19
					  ,p_attribute20                  => l_attribute20);

     	     ota_cert_enrollment_api.create_cert_enrollment(
					   p_effective_date => trunc(sysdate)
					  ,p_validate => p_validate
					  ,p_certification_id => p_certification_id
					  ,p_person_id => p_person_id
					  ,p_contact_id => p_contact_id
					  ,p_certification_status_code => l_certification_status_code
					  ,p_business_group_id => p_business_group_id
					  ,p_completion_date              => p_completion_date
					  ,p_unenrollment_date            => p_unenrollment_date
					  ,p_earliest_enroll_date         => l_earliest_enroll_date
					  ,p_is_history_flag              => p_is_history_flag
					  ,p_attribute_category           => l_attribute_category
                      			  ,p_attribute1                   => l_attribute1
					  ,p_attribute2                   => l_attribute2
					  ,p_attribute3                   => l_attribute3
					  ,p_attribute4                   => l_attribute4
					  ,p_attribute5                   => l_attribute5
					  ,p_attribute6                   => l_attribute6
					  ,p_attribute7                   => l_attribute7
					  ,p_attribute8                   => l_attribute8
					  ,p_attribute9                   => l_attribute9
					  ,p_attribute10                  => l_attribute10
					  ,p_attribute11                  => l_attribute11
					  ,p_attribute12                  => l_attribute12
					  ,p_attribute13                  => l_attribute13
					  ,p_attribute14                  => l_attribute14
					  ,p_attribute15                  => l_attribute15
					  ,p_attribute16                  => l_attribute16
					  ,p_attribute17                  => l_attribute17
					  ,p_attribute18                  => l_attribute18
					  ,p_attribute19                  => l_attribute19
					  ,p_attribute20                  => l_attribute20
					  ,p_enrollment_date              => trunc(nvl(p_enrollment_date, sysdate))
					  ,p_cert_enrollment_id           => l_cert_enrollment_id
					  ,p_object_version_number        => l_object_version_number1
					  );
	      end if; --end create CRE

	  hr_utility.set_location(' Step:'|| l_proc, 70);

          if (p_approval_flag = 'N' or p_approval_flag = 'S') then

         --update cre status on approval confirmed
         if (p_approval_flag = 'S') then
               OPEN csr_cert_enrl(l_cert_enrollment_id);
                   FETCH csr_cert_enrl INTO l_cert_enrl_rec;
                   CLOSE csr_cert_enrl;

		   hr_utility.set_location(' Step:'|| l_proc, 75);

           ota_cert_enrollment_api.update_cert_enrollment
      		          (p_effective_date               => sysdate
              		   ,p_cert_enrollment_id           => l_cert_enrollment_id
              		   ,p_certification_id             => p_certification_id
              		   ,p_object_version_number        => l_cert_enrl_rec.object_version_number
              		   ,p_certification_status_code    => l_certification_status_code
		               );
        end if;

          --call create CPE and CME util proc
              ota_cpe_util.create_cpe_rec(p_cert_enrollment_id => l_cert_enrollment_id,
              				  p_expiration_date => l_expiration_date,
              				  p_cert_period_start_date => trunc(nvl(p_enrollment_date, sysdate)),
              		     p_cert_prd_enrollment_id => l_cert_prd_enrollment_id,
          		         p_certification_status_code => l_certification_status_code,
                         	p_is_recert => l_is_recert);
          end if;--create CPE CMEs

          hr_utility.set_location(' Step:'|| l_proc, 80);

      else -- start of recert
      -- resubscription to unsubscribed cert
      -- set the status and flip the unenrollment date to null

	 hr_utility.set_location(' Step:'|| l_proc, 90);

         --update cert enrollment
         OPEN csr_cert_enrl(l_recert_rec.cert_enrollment_id);
    	 FETCH csr_cert_enrl INTO l_cert_enrl_rec;
    	 CLOSE csr_cert_enrl;

	 hr_utility.set_location(' Step:'|| l_proc, 100);

	     ota_cert_enrollment_api.update_cert_enrollment
	       		   (p_effective_date               => sysdate
	       		    ,p_cert_enrollment_id           => l_cert_enrollment_id
	       		    ,p_certification_id             => l_cert_enrl_rec.certification_id
	       		    ,p_object_version_number        => l_cert_enrl_rec.object_version_number
	       		    ,p_certification_status_code    => l_certification_status_code
                    ,p_is_history_flag              => p_is_history_flag
	       		    ,p_unenrollment_date            => null
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
                    ,p_enrollment_date               => trunc(nvl(p_enrollment_date, sysdate)));

         --udpate prd enrol and mbr enrol only if approval mode is off or enrl approval is granted success;
         if (p_approval_flag = 'N' or p_approval_flag = 'S') then
            -- check active period and update if found, otherwise create CPE and CME
            OPEN csr_prd_enrl(l_recert_rec.cert_enrollment_id);
            FETCH csr_prd_enrl INTO l_prd_enrl_rec;
                if (csr_prd_enrl%FOUND) then
                    l_cert_prd_enrollment_id := l_prd_enrl_rec.cert_prd_enrollment_id;
                end if;
            CLOSE csr_prd_enrl;

	    hr_utility.set_location(' Step:'|| l_proc, 110);

	        if (l_cert_prd_enrollment_id is not null) then
                    --Bug 4565761
                    ota_cme_util.refresh_cme(l_cert_prd_enrollment_id);

	            --calculate period and mbr enroll status for existing data and update accordingly
	            ota_cpe_util.update_cpe_status(l_cert_prd_enrollment_id,
                                       p_certification_status_code => l_certification_status_code);

		    hr_utility.set_location(' Step:'|| l_proc, 120);

	        else
	           --create prd and mbr enrols

	           --update cre for exp date and earliest enroll date when creating new period
	           --calculate exp and earliest enrol dates
	           --for onetime certs there's no expiration
	           --for renewable certs calc based on initial_completion_date, INITIAL_COMPLETION_DURATION,
	           --validity_start_type and validity_duration
      	           OPEN csr_cert_enrl(l_recert_rec.cert_enrollment_id);
                   FETCH csr_cert_enrl INTO l_cert_enrl_rec;
                   CLOSE csr_cert_enrl;

		   hr_utility.set_location(' Step:'|| l_proc, 130);

            	   ota_cert_enrollment_api.update_cert_enrollment
      		          (p_effective_date               => sysdate
              		   ,p_cert_enrollment_id           => l_cert_enrollment_id
              		   ,p_certification_id             => p_certification_id
              		   ,p_object_version_number        => l_cert_enrl_rec.object_version_number
              		   ,p_certification_status_code    => l_certification_status_code
                            ,p_is_history_flag              => p_is_history_flag
              		   ,p_earliest_enroll_date         => l_earliest_enroll_date
		               );

		   hr_utility.set_location(' Step:'|| l_proc, 140);

                   --call create CPE and CME util proc
                   ota_cpe_util.create_cpe_rec(p_cert_enrollment_id => l_cert_enrollment_id,
                   			      p_expiration_date => l_expiration_date,
                   			      p_cert_period_start_date => trunc(nvl(p_enrollment_date, sysdate)),
          		                    p_cert_prd_enrollment_id => l_cert_prd_enrollment_id,
                             		p_certification_status_code => l_certification_status_code,
                         		p_is_recert => l_is_recert);
                end if;
           end if; --for approval N or S
      end if; --end recert

      hr_utility.set_location(' Step:'|| l_proc, 150);

      --set output param
      p_cert_enrollment_id         := l_cert_enrollment_id;
      p_certification_status_code  := l_certification_status_code;

      --fire ntf for enrollment from admin side

      if (((l_o_cert_enroll_id is null and l_certification_status_code ='ENROLLED')
        or (l_o_cert_enroll_id is not null and l_o_cert_enroll_status <> 'ENROLLED'
        and l_certification_status_code ='ENROLLED'))
        and p_person_id is not null
        and nvl(p_enroll_from , '-1')<> 'LRNR')then
      OTA_LRNR_ENROLL_UNENROLL_WF.Cert_Enrollment(p_process => 'OTA_CERT_APPROVAL_JSP_PRC',
            p_itemtype 	=> 'HRSSA',
            p_person_id => p_person_id,
            p_certificationid  => p_certification_id);

      end if;




   if p_validate then
    raise hr_api.validate_enabled;
  end if;

exception
  when hr_api.validate_enabled then
    --
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_cert_subscription;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_cert_enrollment_id  := null;
    p_certification_status_code := null;
    hr_utility.set_location(' Leaving:' || l_proc, 160);

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_cert_subscription;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_cert_enrollment_id  := null;
    p_certification_status_code := null;

    hr_utility.set_location(' Leaving:' || l_proc,170);
    raise;
  END subscribe_to_certification;
--
end OTA_CERT_ENROLLMENT_api;

/
