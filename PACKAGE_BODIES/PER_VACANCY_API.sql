--------------------------------------------------------
--  DDL for Package Body PER_VACANCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VACANCY_API" as
/* $Header: pevacapi.pkb 120.3.12010000.2 2009/06/01 11:12:26 sidsaxen ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PER_VACANCY_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_vacancy >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_vacancy
  (
    P_VALIDATE                  in      boolean         default false
  , P_EFFECTIVE_DATE            in      date            default null
  , P_REQUISITION_ID            in      number
  , P_DATE_FROM                 in      date
  , P_NAME                      in      varchar2
  , P_SECURITY_METHOD           in      varchar2        default 'B'
  , P_BUSINESS_GROUP_ID         in      number
  , P_POSITION_ID               in      number          default null
  , P_JOB_ID                    in      number          default null
  , P_GRADE_ID                  in      number          default null
  , P_ORGANIZATION_ID           in      number          default null
  , P_PEOPLE_GROUP_ID           in      number          default null
  , P_LOCATION_ID               in      number          default null
  , P_RECRUITER_ID              in      number          default null
  , P_DATE_TO                   in      date            default null
  , P_DESCRIPTION               in      varchar2        default null
  , P_NUMBER_OF_OPENINGS        in      number          default null
  , P_STATUS                    in      varchar2        default null
  , P_BUDGET_MEASUREMENT_TYPE   in      varchar2        default null
  , P_BUDGET_MEASUREMENT_VALUE  in      number          default null
  , P_VACANCY_CATEGORY          in      varchar2        default null
  , P_MANAGER_ID                in      number          default null
  , P_PRIMARY_POSTING_ID        in      number          default null
  , P_ASSESSMENT_ID             in      number          default null
  , P_ATTRIBUTE_CATEGORY        in      varchar2        default null
  , P_ATTRIBUTE1                in      varchar2        default null
  , P_ATTRIBUTE2                in      varchar2        default null
  , P_ATTRIBUTE3                in      varchar2        default null
  , P_ATTRIBUTE4                in      varchar2        default null
  , P_ATTRIBUTE5                in      varchar2        default null
  , P_ATTRIBUTE6                in      varchar2        default null
  , P_ATTRIBUTE7                in      varchar2        default null
  , P_ATTRIBUTE8                in      varchar2        default null
  , P_ATTRIBUTE9                in      varchar2        default null
  , P_ATTRIBUTE10               in      varchar2        default null
  , P_ATTRIBUTE11               in      varchar2        default null
  , P_ATTRIBUTE12               in      varchar2        default null
  , P_ATTRIBUTE13               in      varchar2        default null
  , P_ATTRIBUTE14               in      varchar2        default null
  , P_ATTRIBUTE15               in      varchar2        default null
  , P_ATTRIBUTE16               in      varchar2        default null
  , P_ATTRIBUTE17               in      varchar2        default null
  , P_ATTRIBUTE18               in      varchar2        default null
  , P_ATTRIBUTE19               in      varchar2        default null
  , P_ATTRIBUTE20               in      varchar2        default null
  , P_ATTRIBUTE21               in      varchar2        default null
  , P_ATTRIBUTE22               in      varchar2        default null
  , P_ATTRIBUTE23               in      varchar2        default null
  , P_ATTRIBUTE24               in      varchar2        default null
  , P_ATTRIBUTE25               in      varchar2        default null
  , P_ATTRIBUTE26               in      varchar2        default null
  , P_ATTRIBUTE27               in      varchar2        default null
  , P_ATTRIBUTE28               in      varchar2        default null
  , P_ATTRIBUTE29               in      varchar2        default null
  , P_ATTRIBUTE30               in      varchar2        default null
  , P_OBJECT_VERSION_NUMBER         out nocopy number
  , P_VACANCY_ID                    out nocopy number
  , p_inv_pos_grade_warning         out nocopy boolean
  , p_inv_job_grade_warning         out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72)    := g_package||'create_vacancy';
  l_vacancy_id                  number;
  l_object_version_number       number          := 1;
  l_date_from                   date            := trunc(P_DATE_FROM);
  l_date_to                     date            := trunc(P_DATE_TO);
  l_effective_date              date;
  l_inv_pos_grade_warning       boolean;
  l_inv_job_grade_warning       boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_vacancy;
  --
  -- Truncate the time portion from all IN date parameters
  --
  if p_effective_date is null then
    l_effective_date:=l_date_from;
  else
    l_effective_date:=trunc(p_effective_date);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    PER_VACANCY_BK1.create_vacancy_b
    (  P_EFFECTIVE_DATE                 => l_effective_date
     , P_REQUISITION_ID                 => P_REQUISITION_ID
     , P_DATE_FROM                      => l_date_from
     , P_NAME                           => P_NAME
     , P_SECURITY_METHOD                => P_SECURITY_METHOD
     , P_BUSINESS_GROUP_ID              => P_BUSINESS_GROUP_ID
     , P_POSITION_ID                    => P_POSITION_ID
     , P_JOB_ID                         => P_JOB_ID
     , P_GRADE_ID                       => P_GRADE_ID
     , P_ORGANIZATION_ID                => P_ORGANIZATION_ID
     , P_PEOPLE_GROUP_ID                => P_PEOPLE_GROUP_ID
     , P_LOCATION_ID                    => P_LOCATION_ID
     , P_RECRUITER_ID                   => P_RECRUITER_ID
     , P_DATE_TO                        => l_date_to
     , P_DESCRIPTION                    => P_DESCRIPTION
     , P_NUMBER_OF_OPENINGS             => P_NUMBER_OF_OPENINGS
     , P_STATUS                         => P_STATUS
     , P_BUDGET_MEASUREMENT_TYPE        => P_BUDGET_MEASUREMENT_TYPE
     , P_BUDGET_MEASUREMENT_VALUE       => P_BUDGET_MEASUREMENT_VALUE
     , P_VACANCY_CATEGORY               => P_VACANCY_CATEGORY
     , P_MANAGER_ID                     => P_MANAGER_ID
     , P_PRIMARY_POSTING_ID             => P_PRIMARY_POSTING_ID
     , P_ASSESSMENT_ID                  => P_ASSESSMENT_ID
     , P_ATTRIBUTE_CATEGORY             => P_ATTRIBUTE_CATEGORY
     , P_ATTRIBUTE1                     => P_ATTRIBUTE1
     , P_ATTRIBUTE2                     => P_ATTRIBUTE2
     , P_ATTRIBUTE3                     => P_ATTRIBUTE3
     , P_ATTRIBUTE4                     => P_ATTRIBUTE4
     , P_ATTRIBUTE5                     => P_ATTRIBUTE5
     , P_ATTRIBUTE6                     => P_ATTRIBUTE6
     , P_ATTRIBUTE7                     => P_ATTRIBUTE7
     , P_ATTRIBUTE8                     => P_ATTRIBUTE8
     , P_ATTRIBUTE9                     => P_ATTRIBUTE9
     , P_ATTRIBUTE10                    => P_ATTRIBUTE10
     , P_ATTRIBUTE11                    => P_ATTRIBUTE11
     , P_ATTRIBUTE12                    => P_ATTRIBUTE12
     , P_ATTRIBUTE13                    => P_ATTRIBUTE13
     , P_ATTRIBUTE14                    => P_ATTRIBUTE14
     , P_ATTRIBUTE15                    => P_ATTRIBUTE15
     , P_ATTRIBUTE16                    => P_ATTRIBUTE16
     , P_ATTRIBUTE17                    => P_ATTRIBUTE17
     , P_ATTRIBUTE18                    => P_ATTRIBUTE18
     , P_ATTRIBUTE19                    => P_ATTRIBUTE19
     , P_ATTRIBUTE20                    => P_ATTRIBUTE20
     , P_ATTRIBUTE21                    => P_ATTRIBUTE21
     , P_ATTRIBUTE22                    => P_ATTRIBUTE22
     , P_ATTRIBUTE23                    => P_ATTRIBUTE23
     , P_ATTRIBUTE24                    => P_ATTRIBUTE24
     , P_ATTRIBUTE25                    => P_ATTRIBUTE25
     , P_ATTRIBUTE26                    => P_ATTRIBUTE26
     , P_ATTRIBUTE27                    => P_ATTRIBUTE27
     , P_ATTRIBUTE28                    => P_ATTRIBUTE28
     , P_ATTRIBUTE29                    => P_ATTRIBUTE29
     , P_ATTRIBUTE30                    => P_ATTRIBUTE30
 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_vacancy'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  per_vac_ins.ins
    (p_effective_date                => l_effective_date
    ,p_business_group_id             => P_BUSINESS_GROUP_ID
    ,p_requisition_id                => P_REQUISITION_ID
    ,p_date_from                     => l_date_from
    ,p_name                          => P_NAME
    ,p_position_id                   => P_POSITION_ID
    ,p_job_id                        => P_JOB_ID
    ,p_grade_id                      => P_GRADE_ID
    ,p_organization_id               => P_ORGANIZATION_ID
    ,p_people_group_id               => P_PEOPLE_GROUP_ID
    ,p_location_id                   => P_LOCATION_ID
    ,p_recruiter_id                  => P_RECRUITER_ID
    ,p_date_to                       => l_date_to
    ,p_description                   => P_DESCRIPTION
    ,p_number_of_openings            => P_NUMBER_OF_OPENINGS
    ,p_status                        => P_STATUS
    ,p_attribute_category            => P_ATTRIBUTE_CATEGORY
    ,p_attribute1                    => P_ATTRIBUTE1
    ,p_attribute2                    => P_ATTRIBUTE2
    ,p_attribute3                    => P_ATTRIBUTE3
    ,p_attribute4                    => P_ATTRIBUTE4
    ,p_attribute5                    => P_ATTRIBUTE5
    ,p_attribute6                    => P_ATTRIBUTE6
    ,p_attribute7                    => P_ATTRIBUTE7
    ,p_attribute8                    => P_ATTRIBUTE8
    ,p_attribute9                    => P_ATTRIBUTE9
    ,p_attribute10                   => P_ATTRIBUTE10
    ,p_attribute11                   => P_ATTRIBUTE11
    ,p_attribute12                   => P_ATTRIBUTE12
    ,p_attribute13                   => P_ATTRIBUTE13
    ,p_attribute14                   => P_ATTRIBUTE14
    ,p_attribute15                   => P_ATTRIBUTE15
    ,p_attribute16                   => P_ATTRIBUTE16
    ,p_attribute17                   => P_ATTRIBUTE17
    ,p_attribute18                   => P_ATTRIBUTE18
    ,p_attribute19                   => P_ATTRIBUTE19
    ,p_attribute20                   => P_ATTRIBUTE20
    ,p_vacancy_category              => P_VACANCY_CATEGORY
    ,p_budget_measurement_type       => P_BUDGET_MEASUREMENT_TYPE
    ,p_budget_measurement_value      => P_BUDGET_MEASUREMENT_VALUE
    ,p_manager_id                    => P_MANAGER_ID
    ,p_security_method               => P_SECURITY_METHOD
    ,p_primary_posting_id            => P_PRIMARY_POSTING_ID
    ,p_assessment_id                 => P_ASSESSMENT_ID
    ,p_inv_pos_grade_warning         => l_inv_pos_grade_warning
    ,p_inv_job_grade_warning         => l_inv_job_grade_warning
    ,p_vacancy_id                    => l_vacancy_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
  PER_VACANCY_BK1.create_vacancy_a
         (  p_EFFECTIVE_DATE           => l_effective_date
          , P_REQUISITION_ID           => P_REQUISITION_ID
          , P_DATE_FROM                => l_date_from
          , P_NAME                     => P_NAME
          , P_SECURITY_METHOD          => P_SECURITY_METHOD
          , P_BUSINESS_GROUP_ID        => P_BUSINESS_GROUP_ID
          , P_POSITION_ID              => P_POSITION_ID
          , P_JOB_ID                   => P_JOB_ID
          , P_GRADE_ID                 => P_GRADE_ID
          , P_ORGANIZATION_ID          => P_ORGANIZATION_ID
          , P_PEOPLE_GROUP_ID          => P_PEOPLE_GROUP_ID
          , P_LOCATION_ID              => P_LOCATION_ID
          , P_RECRUITER_ID             => P_RECRUITER_ID
          , P_DATE_TO                  => l_date_to
          , P_DESCRIPTION              => P_DESCRIPTION
          , P_NUMBER_OF_OPENINGS       => P_NUMBER_OF_OPENINGS
          , P_STATUS                   => P_STATUS
          , P_BUDGET_MEASUREMENT_TYPE  => P_BUDGET_MEASUREMENT_TYPE
          , P_BUDGET_MEASUREMENT_VALUE => P_BUDGET_MEASUREMENT_VALUE
          , P_VACANCY_CATEGORY         => P_VACANCY_CATEGORY
          , P_MANAGER_ID               => P_MANAGER_ID
          , P_PRIMARY_POSTING_ID       => P_PRIMARY_POSTING_ID
          , P_ASSESSMENT_ID            => P_ASSESSMENT_ID
          , P_ATTRIBUTE_CATEGORY       => P_ATTRIBUTE_CATEGORY
          , P_ATTRIBUTE1               => P_ATTRIBUTE1
          , P_ATTRIBUTE2               => P_ATTRIBUTE2
          , P_ATTRIBUTE3               => P_ATTRIBUTE3
          , P_ATTRIBUTE4               => P_ATTRIBUTE4
          , P_ATTRIBUTE5               => P_ATTRIBUTE5
          , P_ATTRIBUTE6               => P_ATTRIBUTE6
          , P_ATTRIBUTE7               => P_ATTRIBUTE7
          , P_ATTRIBUTE8               => P_ATTRIBUTE8
          , P_ATTRIBUTE9               => P_ATTRIBUTE9
          , P_ATTRIBUTE10              => P_ATTRIBUTE10
          , P_ATTRIBUTE11              => P_ATTRIBUTE11
          , P_ATTRIBUTE12              => P_ATTRIBUTE12
          , P_ATTRIBUTE13              => P_ATTRIBUTE13
          , P_ATTRIBUTE14              => P_ATTRIBUTE14
          , P_ATTRIBUTE15              => P_ATTRIBUTE15
          , P_ATTRIBUTE16              => P_ATTRIBUTE16
          , P_ATTRIBUTE17              => P_ATTRIBUTE17
          , P_ATTRIBUTE18              => P_ATTRIBUTE18
          , P_ATTRIBUTE19              => P_ATTRIBUTE19
          , P_ATTRIBUTE20              => P_ATTRIBUTE20
          , P_ATTRIBUTE21              => P_ATTRIBUTE21
          , P_ATTRIBUTE22              => P_ATTRIBUTE22
          , P_ATTRIBUTE23              => P_ATTRIBUTE23
          , P_ATTRIBUTE24              => P_ATTRIBUTE24
          , P_ATTRIBUTE25              => P_ATTRIBUTE25
          , P_ATTRIBUTE26              => P_ATTRIBUTE26
          , P_ATTRIBUTE27              => P_ATTRIBUTE27
          , P_ATTRIBUTE28              => P_ATTRIBUTE28
          , P_ATTRIBUTE29              => P_ATTRIBUTE29
          , P_ATTRIBUTE30              => P_ATTRIBUTE30
          , P_OBJECT_VERSION_NUMBER    => l_object_version_number
          , P_VACANCY_ID               => l_vacancy_id
          , p_inv_pos_grade_warning    => l_inv_pos_grade_warning
          , p_inv_job_grade_warning    => l_inv_job_grade_warning
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_vacancy'
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
  P_VACANCY_ID                  := l_vacancy_id;
  P_OBJECT_VERSION_NUMBER       := l_object_version_number;
  p_inv_pos_grade_warning       := l_inv_pos_grade_warning;
  p_inv_job_grade_warning       := l_inv_job_grade_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_vacancy;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    P_VACANCY_ID                := null;
    P_OBJECT_VERSION_NUMBER     := null;
    p_inv_pos_grade_warning       := l_inv_pos_grade_warning;
    p_inv_job_grade_warning       := l_inv_job_grade_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    P_VACANCY_ID                := null;
    P_OBJECT_VERSION_NUMBER     := null;
    p_inv_pos_grade_warning       :=null;
    p_inv_job_grade_warning       := null;

    rollback to create_vacancy;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_vacancy;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_vacancy >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_vacancy
(
  P_VALIDATE                    in     boolean          default false
, P_EFFECTIVE_DATE              in     date             default null
, P_VACANCY_ID                  in     number
, P_OBJECT_VERSION_NUMBER       in out nocopy number
, P_DATE_FROM                   in     date            default hr_api.g_date
, P_POSITION_ID                 in     number          default hr_api.g_number
, P_JOB_ID                      in     number          default hr_api.g_number
, P_GRADE_ID                    in     number          default hr_api.g_number
, P_ORGANIZATION_ID             in     number          default hr_api.g_number
, P_PEOPLE_GROUP_ID             in     number          default hr_api.g_number
, P_LOCATION_ID                 in     number          default hr_api.g_number
, P_RECRUITER_ID                in     number          default hr_api.g_number
, P_DATE_TO                     in     date            default hr_api.g_date
, P_SECURITY_METHOD             in     varchar2        default hr_api.g_varchar2
, P_DESCRIPTION                 in     varchar2        default hr_api.g_varchar2
, P_NUMBER_OF_OPENINGS          in     number          default hr_api.g_number
, P_STATUS                      in     varchar2        default hr_api.g_varchar2
, P_BUDGET_MEASUREMENT_TYPE     in     varchar2        default hr_api.g_varchar2
, P_BUDGET_MEASUREMENT_VALUE    in     number          default hr_api.g_number
, P_VACANCY_CATEGORY            in     varchar2        default hr_api.g_varchar2
, P_MANAGER_ID                  in     number           default hr_api.g_number
, P_PRIMARY_POSTING_ID          in     number          default hr_api.g_number
, P_ASSESSMENT_ID               in     number          default hr_api.g_number
, P_ATTRIBUTE_CATEGORY          in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE1                  in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE2                  in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE3                  in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE4                  in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE5                  in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE6                  in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE7                  in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE8                  in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE9                  in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE10                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE11                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE12                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE13                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE14                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE15                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE16                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE17                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE18                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE19                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE20                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE21                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE22                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE23                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE24                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE25                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE26                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE27                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE28                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE29                 in     varchar2        default hr_api.g_varchar2
, P_ATTRIBUTE30                 in     varchar2        default hr_api.g_varchar2
, P_ASSIGNMENT_CHANGED             out nocopy boolean
,p_inv_pos_grade_warning           out nocopy boolean
,p_inv_job_grade_warning           out nocopy boolean
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72)    := g_package||'update_vacancy';
  l_date_from                   date            := trunc(P_DATE_FROM);
  l_date_to                     date            := trunc(P_DATE_TO);
  l_effective_date              date;
  l_asg_found                   number          := null;
  l_job_id                      number          := null;
  l_grade_id                    number          := null;
  l_people_group_id             number          := null;
  l_organization_id             number          := null;
  l_position_id                 number          := null;
  l_location_id                 number          := null;
  l_manager_id                  number          := null;
  l_recruiter_id                number          := null;
  l_con_segments                varchar2(100)   := null;
  l_comment_id                  number          := null;
  l_assignment_changed          boolean         := false;
  l_object_version_number       number          := P_OBJECT_VERSION_NUMBER;
  l_asg_ovn                     number;
  l_inv_pos_grade_warning       boolean;
  l_inv_job_grade_warning       boolean;
  l_temp_ovn                    number          := P_OBJECT_VERSION_NUMBER;
 cursor csr_asg is
              select assignment_id,paf.object_version_number
                from per_all_assignments_f paf,
                     per_all_vacancies pav
               where paf.vacancy_id = p_vacancy_id
                 and paf.vacancy_id = pav.vacancy_id
                 and paf.assignment_type = 'A';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_vacancy;
  --
  -- Truncate the time portion from all IN date parameters
  --
  if p_effective_date is null then
    l_effective_date:=l_date_from;
  else
    l_effective_date:=trunc(p_effective_date);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
   PER_VACANCY_BK2.update_vacancy_b
   (P_EFFECTIVE_DATE                    => l_effective_date
  , P_VACANCY_ID                        => P_VACANCY_ID
  , P_OBJECT_VERSION_NUMBER             => l_object_version_number
  , P_DATE_FROM                         => l_date_from
  , P_POSITION_ID                       => P_POSITION_ID
  , P_JOB_ID                            => P_JOB_ID
  , P_GRADE_ID                          => P_GRADE_ID
  , P_ORGANIZATION_ID                   => P_ORGANIZATION_ID
  , P_PEOPLE_GROUP_ID                   => P_PEOPLE_GROUP_ID
  , P_LOCATION_ID                       => P_LOCATION_ID
  , P_RECRUITER_ID                      => P_RECRUITER_ID
  , P_DATE_TO                           => l_date_to
  , P_SECURITY_METHOD                   => P_SECURITY_METHOD
  , P_DESCRIPTION                       => P_DESCRIPTION
  , P_NUMBER_OF_OPENINGS                => P_NUMBER_OF_OPENINGS
  , P_STATUS                            => P_STATUS
  , P_BUDGET_MEASUREMENT_TYPE           => P_BUDGET_MEASUREMENT_TYPE
  , P_BUDGET_MEASUREMENT_VALUE          => P_BUDGET_MEASUREMENT_VALUE
  , P_VACANCY_CATEGORY                  => P_VACANCY_CATEGORY
  , P_MANAGER_ID                        => P_MANAGER_ID
  , P_PRIMARY_POSTING_ID                => P_PRIMARY_POSTING_ID
  , P_ASSESSMENT_ID                     => P_ASSESSMENT_ID
  , P_ATTRIBUTE_CATEGORY                => P_ATTRIBUTE_CATEGORY
  , P_ATTRIBUTE1                        => P_ATTRIBUTE1
  , P_ATTRIBUTE2                        => P_ATTRIBUTE2
  , P_ATTRIBUTE3                        => P_ATTRIBUTE3
  , P_ATTRIBUTE4                        => P_ATTRIBUTE4
  , P_ATTRIBUTE5                        => P_ATTRIBUTE5
  , P_ATTRIBUTE6                        => P_ATTRIBUTE6
  , P_ATTRIBUTE7                        => P_ATTRIBUTE7
  , P_ATTRIBUTE8                        => P_ATTRIBUTE8
  , P_ATTRIBUTE9                        => P_ATTRIBUTE9
  , P_ATTRIBUTE10                       => P_ATTRIBUTE10
  , P_ATTRIBUTE11                       => P_ATTRIBUTE11
  , P_ATTRIBUTE12                       => P_ATTRIBUTE12
  , P_ATTRIBUTE13                       => P_ATTRIBUTE13
  , P_ATTRIBUTE14                       => P_ATTRIBUTE14
  , P_ATTRIBUTE15                       => P_ATTRIBUTE15
  , P_ATTRIBUTE16                       => P_ATTRIBUTE16
  , P_ATTRIBUTE17                       => P_ATTRIBUTE17
  , P_ATTRIBUTE18                       => P_ATTRIBUTE18
  , P_ATTRIBUTE19                       => P_ATTRIBUTE19
  , P_ATTRIBUTE20                       => P_ATTRIBUTE20
  , P_ATTRIBUTE21                       => P_ATTRIBUTE21
  , P_ATTRIBUTE22                       => P_ATTRIBUTE22
  , P_ATTRIBUTE23                       => P_ATTRIBUTE23
  , P_ATTRIBUTE24                       => P_ATTRIBUTE24
  , P_ATTRIBUTE25                       => P_ATTRIBUTE25
  , P_ATTRIBUTE26                       => P_ATTRIBUTE26
  , P_ATTRIBUTE27                       => P_ATTRIBUTE27
  , P_ATTRIBUTE28                       => P_ATTRIBUTE28
  , P_ATTRIBUTE29                       => P_ATTRIBUTE29
  , P_ATTRIBUTE30                       => P_ATTRIBUTE30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_vacancy'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
  per_vac_upd.upd
  (p_effective_date               => l_effective_date
  ,p_vacancy_id                   => P_VACANCY_ID
  ,p_object_version_number        => l_object_version_number
  ,p_date_from                    => l_date_from
  ,p_position_id                  => P_POSITION_ID
  ,p_job_id                       => P_JOB_ID
  ,p_grade_id                     => P_GRADE_ID
  ,p_organization_id              => P_ORGANIZATION_ID
  ,p_people_group_id              => P_PEOPLE_GROUP_ID
  ,p_location_id                  => P_LOCATION_ID
  ,p_recruiter_id                 => P_RECRUITER_ID
  ,p_date_to                      => l_date_to
  ,p_number_of_openings           => P_NUMBER_OF_OPENINGS
  ,p_status                       => P_STATUS
  ,p_attribute_category           => P_ATTRIBUTE_CATEGORY
  ,p_attribute1                   => P_ATTRIBUTE1
  ,p_attribute2                   => P_ATTRIBUTE2
  ,p_attribute3                   => P_ATTRIBUTE3
  ,p_attribute4                   => P_ATTRIBUTE4
  ,p_attribute5                   => P_ATTRIBUTE5
  ,p_attribute6                   => P_ATTRIBUTE6
  ,p_attribute7                   => P_ATTRIBUTE7
  ,p_attribute8                   => P_ATTRIBUTE8
  ,p_attribute9                   => P_ATTRIBUTE9
  ,p_attribute10                  => P_ATTRIBUTE10
  ,p_attribute11                  => P_ATTRIBUTE11
  ,p_attribute12                  => P_ATTRIBUTE12
  ,p_attribute13                  => P_ATTRIBUTE13
  ,p_attribute14                  => P_ATTRIBUTE14
  ,p_attribute15                  => P_ATTRIBUTE15
  ,p_attribute16                  => P_ATTRIBUTE16
  ,p_attribute17                  => P_ATTRIBUTE17
  ,p_attribute18                  => P_ATTRIBUTE18
  ,p_attribute19                  => P_ATTRIBUTE19
  ,p_attribute20                  => P_ATTRIBUTE20
  ,p_vacancy_category             => P_VACANCY_CATEGORY
  ,p_budget_measurement_type      => P_BUDGET_MEASUREMENT_TYPE
  ,p_budget_measurement_value     => P_BUDGET_MEASUREMENT_VALUE
  ,p_manager_id                   => P_MANAGER_ID
  ,p_security_method              => P_SECURITY_METHOD
  ,p_primary_posting_id           => P_PRIMARY_POSTING_ID
  ,p_assessment_id                => P_ASSESSMENT_ID
  ,p_description                  => P_DESCRIPTION
  ,p_inv_pos_grade_warning        => l_inv_pos_grade_warning
  ,p_inv_job_grade_warning        => l_inv_job_grade_warning
 );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- look to see if the assignment needs updating
  --
  l_ASSIGNMENT_CHANGED := FALSE;
  --
  -- start changes for bug 8518955
  if (nvl(p_organization_id,0) <> nvl(per_vac_shd.g_old_rec.organization_id,0))
    and (nvl(p_organization_id,0) <> hr_api.g_number)
  then
    l_ASSIGNMENT_CHANGED := TRUE;
    --l_organization_id := p_organization_id;
    --l_position_id := p_position_id;
  end if;
  --
  if (nvl(p_job_id,0) <> nvl(per_vac_shd.g_old_rec.job_id,0))
    and (nvl(p_job_id,0) <> hr_api.g_number)
  then
    l_ASSIGNMENT_CHANGED := TRUE;
    --l_job_id := p_job_id;
    --l_position_id := p_position_id;
  end if;
  --
  if  (nvl(p_grade_id,0)<> nvl(per_vac_shd.g_old_rec.grade_id,0))
    and (nvl(p_grade_id,0) <> hr_api.g_number)
  then
      l_ASSIGNMENT_CHANGED := TRUE;
    --l_grade_id := p_grade_id;
  end if;
  --
  if (nvl(p_people_group_id,0) <> nvl(per_vac_shd.g_old_rec.people_group_id,0))
     and (nvl(p_people_group_id,0) <> hr_api.g_number)
  then
    l_ASSIGNMENT_CHANGED := TRUE;
    --l_people_group_id := p_people_group_id;
  end if;
  --
  if (nvl(p_position_id,0) <> nvl(per_vac_shd.g_old_rec.position_id,0))
     and (nvl(p_position_id,0) <> hr_api.g_number)
  then
    l_ASSIGNMENT_CHANGED := TRUE;
    --l_position_id := p_position_id;
  end if;
  --
  if (nvl(p_location_id,0) <> nvl(per_vac_shd.g_old_rec.location_id,0))
     and (nvl(p_location_id,0) <> hr_api.g_number)
  then
    l_ASSIGNMENT_CHANGED := TRUE;
    --l_location_id := p_location_id;
  end if;
  --
  if (nvl(p_recruiter_id,0) <> nvl(per_vac_shd.g_old_rec.recruiter_id,0))
     and (nvl(p_recruiter_id,0) <> hr_api.g_number)
  then
    l_ASSIGNMENT_CHANGED := TRUE;
    --l_recruiter_id := p_recruiter_id;
  end if;
  --
  if (nvl(p_manager_id,0) <> nvl(per_vac_shd.g_old_rec.manager_id,0))
     and (nvl(p_manager_id,0) <> hr_api.g_number)
  then
    l_ASSIGNMENT_CHANGED := TRUE;
    --l_manager_id := p_manager_id;
  end if;
  --
  if l_ASSIGNMENT_CHANGED = TRUE then
    --
    -- fix for the bug 5719667
    --l_position_id := p_position_id;
    hr_utility.set_location(l_proc, 40);

    l_job_id           := case
                            when nvl(p_job_id,0) = hr_api.g_number then per_vac_shd.g_old_rec.job_id
                            else p_job_id
                          end;

    l_grade_id         := case
                           when nvl(p_grade_id,0) = hr_api.g_number then per_vac_shd.g_old_rec.grade_id
                           else p_grade_id
                          end;

    l_people_group_id  := case
                           when nvl(p_people_group_id,0) = hr_api.g_number then per_vac_shd.g_old_rec.people_group_id
                           else P_people_group_id
                          end;

    l_organization_id  := case
                           when nvl(p_organization_id,0) = hr_api.g_number then per_vac_shd.g_old_rec.organization_id
                           else nvl(p_organization_id,per_vac_shd.g_old_rec.organization_id)
                          end;

    l_position_id      := case
                           when nvl(p_position_id,0) = hr_api.g_number then per_vac_shd.g_old_rec.position_id
                           else p_position_id
                          end;

    l_location_id      := case
                           when nvl(p_location_id,0) = hr_api.g_number then per_vac_shd.g_old_rec.location_id
                           else p_location_id
                          end;

    l_manager_id       := case
                           when nvl(p_manager_id,0) = hr_api.g_number then per_vac_shd.g_old_rec.manager_id
                           else p_manager_id
                          end;

    l_recruiter_id     := case
                           when nvl(p_recruiter_id,0) = hr_api.g_number then per_vac_shd.g_old_rec.recruiter_id
                           else p_recruiter_id
                          end;
    --
    /*update per_all_assignments_f asg
    set asg.organization_id = nvl(l_organization_id, asg.organization_id)
    ,asg.job_id          = nvl(l_job_id, asg.job_id)
    ,asg.grade_id        = nvl(l_grade_id, asg.grade_id)
    ,asg.people_group_id = nvl(l_people_group_id, asg.people_group_id)
    ,asg.location_id     = nvl(l_location_id, asg.location_id)
    ,asg.recruiter_id    = nvl(l_recruiter_id, asg.recruiter_id)
    ,asg.supervisor_id   = nvl(l_manager_id, asg.supervisor_id)
    ,asg.position_id     = decode
                        (l_organization_id||'.'||l_job_id,
                         per_vac_shd.g_old_rec.organization_id||'.'||per_vac_shd.g_old_rec.job_id,
                         nvl(l_position_id, asg.position_id),
                          l_position_id) */

    update per_all_assignments_f asg
    set asg.organization_id = nvl(l_organization_id,asg.organization_id)
    ,asg.job_id          = l_job_id
    ,asg.grade_id        = l_grade_id
    ,asg.people_group_id = l_people_group_id
    ,asg.location_id     = l_location_id
    ,asg.recruiter_id    = l_recruiter_id
    ,asg.supervisor_id   = l_manager_id
    ,asg.position_id     = l_position_id
    where  asg.assignment_type = 'A'
     and    asg.vacancy_id = p_vacancy_id
     and exists ( select 1
      	     from per_all_assignments_f  f2
	     where asg.assignment_id = f2.assignment_id
 	     and f2.effective_end_date = hr_api.g_eot  )
     and not exists ( select 1
      		 from per_all_assignments_f  f2
		 where asg.assignment_id = f2.assignment_id
		 and f2.assignment_status_type_id in (  select assignment_status_type_id
                                             		from per_assignment_status_types
                                                	where per_system_status in ('ACCEPTED')));
      /*and (  asg.organization_id         <> nvl(l_organization_id,asg.organization_id)
         or nvl(asg.job_id,          -1) <> nvl(l_job_id,nvl(asg.job_id, -1))
         or nvl(asg.grade_id,        -1) <> nvl(l_grade_id,nvl(asg.grade_id, -1))
         or nvl(asg.people_group_id, -1) <> nvl(l_people_group_id, nvl(asg.people_group_id, -1))
         or nvl(asg.position_id,     -1) <> nvl(l_position_id,nvl(asg.position_id, -1))
         or nvl(asg.location_id,     -1) <> nvl(l_location_id, nvl(asg.location_id, -1))
         or nvl(asg.recruiter_id,    -1) <> nvl(l_recruiter_id, nvl(asg.recruiter_id, -1))
         or nvl(asg.supervisor_id,   -1) <> nvl(l_manager_id, nvl(asg.supervisor_id, -1))
         );*/

    --end changes for bug 8518955

  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
--
  PER_VACANCY_BK2.update_vacancy_a(
   P_EFFECTIVE_DATE                     => l_effective_date
  ,P_VACANCY_ID                         => P_VACANCY_ID
  ,P_OBJECT_VERSION_NUMBER              => p_object_version_number
  ,P_DATE_FROM                          => l_date_from
  ,P_POSITION_ID                        => P_POSITION_ID
  ,P_JOB_ID                             => P_JOB_ID
  ,P_GRADE_ID                           => P_GRADE_ID
  ,P_ORGANIZATION_ID                    => P_ORGANIZATION_ID
  ,P_PEOPLE_GROUP_ID                    => P_PEOPLE_GROUP_ID
  ,P_LOCATION_ID                        => P_LOCATION_ID
  ,P_RECRUITER_ID                       => P_RECRUITER_ID
  ,P_DATE_TO                            => l_date_to
  ,P_SECURITY_METHOD                    => P_SECURITY_METHOD
  ,P_DESCRIPTION                        => P_DESCRIPTION
  ,P_NUMBER_OF_OPENINGS                 => P_NUMBER_OF_OPENINGS
  ,P_STATUS                             => P_STATUS
  ,P_BUDGET_MEASUREMENT_TYPE            => P_BUDGET_MEASUREMENT_TYPE
  ,P_BUDGET_MEASUREMENT_VALUE           => P_BUDGET_MEASUREMENT_VALUE
  ,P_VACANCY_CATEGORY                   => P_VACANCY_CATEGORY
  ,P_MANAGER_ID                         => P_MANAGER_ID
  ,P_PRIMARY_POSTING_ID                 => P_PRIMARY_POSTING_ID
  ,P_ASSESSMENT_ID                      => P_ASSESSMENT_ID
  ,P_ATTRIBUTE_CATEGORY                 => P_ATTRIBUTE_CATEGORY
  ,P_ATTRIBUTE1                         => P_ATTRIBUTE1
  ,P_ATTRIBUTE2                         => P_ATTRIBUTE2
  ,P_ATTRIBUTE3                         => P_ATTRIBUTE3
  ,P_ATTRIBUTE4                         => P_ATTRIBUTE4
  ,P_ATTRIBUTE5                         => P_ATTRIBUTE5
  ,P_ATTRIBUTE6                         => P_ATTRIBUTE6
  ,P_ATTRIBUTE7                         => P_ATTRIBUTE7
  ,P_ATTRIBUTE8                         => P_ATTRIBUTE8
  ,P_ATTRIBUTE9                         => P_ATTRIBUTE9
  ,P_ATTRIBUTE10                        => P_ATTRIBUTE10
  ,P_ATTRIBUTE11                        => P_ATTRIBUTE11
  ,P_ATTRIBUTE12                        => P_ATTRIBUTE12
  ,P_ATTRIBUTE13                        => P_ATTRIBUTE13
  ,P_ATTRIBUTE14                        => P_ATTRIBUTE14
  ,P_ATTRIBUTE15                        => P_ATTRIBUTE15
  ,P_ATTRIBUTE16                        => P_ATTRIBUTE16
  ,P_ATTRIBUTE17                        => P_ATTRIBUTE17
  ,P_ATTRIBUTE18                        => P_ATTRIBUTE18
  ,P_ATTRIBUTE19                        => P_ATTRIBUTE19
  ,P_ATTRIBUTE20                        => P_ATTRIBUTE20
  ,P_ATTRIBUTE21                        => P_ATTRIBUTE21
  ,P_ATTRIBUTE22                        => P_ATTRIBUTE22
  ,P_ATTRIBUTE23                        => P_ATTRIBUTE23
  ,P_ATTRIBUTE24                        => P_ATTRIBUTE24
  ,P_ATTRIBUTE25                        => P_ATTRIBUTE25
  ,P_ATTRIBUTE26                        => P_ATTRIBUTE26
  ,P_ATTRIBUTE27                        => P_ATTRIBUTE27
  ,P_ATTRIBUTE28                        => P_ATTRIBUTE28
  ,P_ATTRIBUTE29                        => P_ATTRIBUTE29
  ,P_ATTRIBUTE30                        => P_ATTRIBUTE30
  ,P_ASSIGNMENT_CHANGED                 => l_assignment_changed
  ,p_inv_pos_grade_warning              => l_inv_pos_grade_warning
  ,p_inv_job_grade_warning              => l_inv_job_grade_warning

  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_vacancy'
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
 P_ASSIGNMENT_CHANGED := l_assignment_changed;
 P_OBJECT_VERSION_NUMBER := l_object_version_number;
 p_inv_pos_grade_warning              := l_inv_pos_grade_warning;
 p_inv_job_grade_warning              := l_inv_job_grade_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_vacancy;
 p_inv_pos_grade_warning              := l_inv_pos_grade_warning;
 p_inv_job_grade_warning              := l_inv_job_grade_warning;
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
    p_assignment_changed        := null;
    P_OBJECT_VERSION_NUMBER     := l_temp_ovn;
    p_inv_pos_grade_warning       := null;
    p_inv_job_grade_warning       := null;

    rollback to update_vacancy;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_vacancy;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_vacancy >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vacancy
(
  P_VALIDATE                    in boolean    default false
, P_OBJECT_VERSION_NUMBER       in number
, P_VACANCY_ID                  in number
)
is
  --
  -- Declare cursors and local variables
  --

  l_proc   varchar2(72) := g_package||'delete_vacancy';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vacancy;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin

  PER_VACANCY_BK3.delete_vacancy_b
   (
    P_OBJECT_VERSION_NUMBER
   ,P_VACANCY_ID
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_vacancy'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  per_vac_del.del(
                  p_vacancy_id => P_VACANCY_ID
                 ,p_object_version_number => P_OBJECT_VERSION_NUMBER
                 );
  --
  -- Process Logic
  --
  --
  -- Call After Process User Hook
  --
  begin
    PER_VACANCY_BK3.delete_vacancy_a
     (
      P_OBJECT_VERSION_NUMBER
     ,P_VACANCY_ID
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_vacancy'
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
    rollback to delete_vacancy;
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
    rollback to delete_vacancy;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_vacancy;
--
end PER_VACANCY_API;

/
