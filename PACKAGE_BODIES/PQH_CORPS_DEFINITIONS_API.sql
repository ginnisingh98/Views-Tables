--------------------------------------------------------
--  DDL for Package Body PQH_CORPS_DEFINITIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CORPS_DEFINITIONS_API" as
/* $Header: pqcpdapi.pkb 115.4 2003/11/13 07:05:05 kgowripe noship $ */
g_package varchar2(33) := 'pqh_corps_definitions_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_corps_definition >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
-- Name                           Reqd     Type     Description
-- p_validate                      YES     boolean  Commit or Rollback
-- p_effective_date                YES     date
-- p_business_group_id             NO      number
-- p_name                          NO      varchar2
-- p_status_cd                     NO      varchar2
-- p_retirement_age                NO      number
-- p_category_cd                   NO      varchar2
-- p_starting_grade_step_id        NO      number
-- p_type_of_ps                NO      varchar2
-- p_task_desc                         NO      varchar2
-- p_secondment_threshold          NO      number
-- p_normal_hours                  NO      number3
-- p_normal_hours_frequency        NO      varchar2
-- p_minimum_hours                 NO      number
-- p_minimum_hours_frequency       NO      varchar2
-- p_attribute1                    NO      varchar2
-- p_attribute2                    NO      varchar2
-- p_attribute3                    NO      varchar2
-- p_attribute4                    NO      varchar2
-- p_attribute5                    NO      varchar2
-- p_attribute6                    NO      varchar2
-- p_attribute7                    NO      varchar2
-- p_attribute8                    NO      varchar2
-- p_attribute9                    NO      varchar2
-- p_attribute10                   NO      varchar2
-- p_attribute11                   NO      varchar2
-- p_attribute12                   NO      varchar2
-- p_attribute13                   NO      varchar2
-- p_attribute14                   NO      varchar2
-- p_attribute15                   NO      varchar2
-- p_attribute16                   NO      varchar2
-- p_attribute17                   NO      varchar2
-- p_attribute18                   NO      varchar2
-- p_attribute19                   NO      varchar2
-- p_attribute20                   NO      varchar2
-- p_attribute21                   NO      varchar2
-- p_attribute22                   NO      varchar2
-- p_attribute23                   NO      varchar2
-- p_attribute24                   NO      varchar2
-- p_attribute25                   NO      varchar2
-- p_attribute26                   NO      varchar2
-- p_attribute27                   NO      varchar2
-- p_attribute28                   NO      varchar2
-- p_attribute29                   NO      varchar2
-- p_attribute30                   NO      varchar2
-- p_attribute_category            NO      varchar2
-- p_primary_prof_field_id         NO      number
-- p_starting_grade_id             NO      number
-- p_ben_pgm_id                    NO      number
-- p_probation_period              NO      number
-- p_probation_units               NO      varchar2

-- Post Success:
--
-- Out Parameters:
--   Name                          Reqd   Type      Description
--   p_object_version_number        Yes   number    OVN of record
--   p_corps_definition_id          Yes   number
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_corps_definition
(
  p_validate                      in     boolean   default false
  ,p_effective_date               in     date
  ,p_corps_definition_id          out nocopy    number
  ,p_business_group_id            in     number
  ,p_name                         in    varchar2
  ,p_status_cd                    in    varchar2
  ,p_retirement_age               in    number     default null
  ,p_category_cd                  in    varchar2
  ,p_corps_type_cd                in    varchar2
  ,p_date_from         in    date
  ,p_date_to           in    date       default null
  ,p_recruitment_end_date         in    date       default null
  ,p_starting_grade_step_id       in    number     default null
  ,p_type_of_ps               in    varchar2   default null
  ,p_task_desc                    in    varchar2   default null
  ,p_secondment_threshold         in    number     default null
  ,p_normal_hours                 in    number     default null
  ,p_normal_hours_frequency       in    varchar2   default null
  ,p_minimum_hours                in    number     default null
  ,p_minimum_hours_frequency      in    varchar2   default null
  ,p_attribute1                   in    varchar2   default null
  ,p_attribute2                   in    varchar2   default null
  ,p_attribute3                   in    varchar2   default null
  ,p_attribute4                   in    varchar2   default null
  ,p_attribute5                   in    varchar2   default null
  ,p_attribute6                   in    varchar2   default null
  ,p_attribute7                   in    varchar2   default null
  ,p_attribute8                   in    varchar2   default null
  ,p_attribute9                   in    varchar2   default null
  ,p_attribute10                  in    varchar2   default null
  ,p_attribute11                  in    varchar2   default null
  ,p_attribute12                  in    varchar2   default null
  ,p_attribute13                  in    varchar2   default null
  ,p_attribute14                  in    varchar2   default null
  ,p_attribute15                  in    varchar2   default null
  ,p_attribute16                  in    varchar2   default null
  ,p_attribute17                  in    varchar2   default null
  ,p_attribute18                  in    varchar2   default null
  ,p_attribute19                  in    varchar2   default null
  ,p_attribute20                  in    varchar2   default null
  ,p_attribute21                  in    varchar2   default null
  ,p_attribute22                  in    varchar2   default null
  ,p_attribute23                  in    varchar2   default null
  ,p_attribute24                  in    varchar2   default null
  ,p_attribute25                  in    varchar2   default null
  ,p_attribute26                  in    varchar2   default null
  ,p_attribute27                  in    varchar2   default null
  ,p_attribute28                  in    varchar2   default null
  ,p_attribute29                  in    varchar2   default null
  ,p_attribute30                  in    varchar2   default null
  ,p_attribute_category           in    varchar2   default null
  ,p_object_version_number        out nocopy   number
  ,p_primary_prof_field_id          in number      default null
  ,p_starting_grade_id              in number      default null
  ,p_ben_pgm_id                     in number      default null
  ,p_probation_period               in number      default null
  ,p_probation_units                in varchar2    default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_corps_definition_id pqh_corps_definitions.corps_definition_id%TYPE;
  l_proc varchar2(72) := g_package||'create_corps_definition';
  l_object_version_number pqh_corps_definitions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_corps_definition;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_corps_definition
  pqh_corps_definitions_bk1.create_corps_definition_b
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_business_group_id            =>    p_business_group_id
  ,p_name                         =>    p_name
  ,p_status_cd                    =>    p_status_cd
  ,p_retirement_age               =>    p_retirement_age
  ,p_category_cd                  =>    p_category_cd
  ,p_corps_type_cd                =>    p_corps_type_cd
  ,p_date_from         =>    p_date_from
  ,p_date_to           =>    p_date_to
  ,p_recruitment_end_date         =>    p_recruitment_end_date
  ,p_starting_grade_step_id       =>    p_starting_grade_step_id
  ,p_type_of_ps               =>    p_type_of_ps
  ,p_task_desc                    =>    p_task_desc
  ,p_secondment_threshold         =>    p_secondment_threshold
  ,p_normal_hours                 =>    p_normal_hours
  ,p_normal_hours_frequency       =>    p_normal_hours_frequency
  ,p_minimum_hours                =>    p_minimum_hours
  ,p_minimum_hours_frequency      =>    p_minimum_hours_frequency
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
  ,p_primary_prof_field_id        =>    p_primary_prof_field_id
  ,p_starting_grade_id            =>    p_starting_grade_id
  ,p_ben_pgm_id                   =>    p_ben_pgm_id
  ,p_probation_period             =>    p_probation_period
  ,p_probation_units              =>    p_probation_units
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_corps_definition'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_corps_definition
    --
  end;

  pqh_cpd_ins.ins
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_definition_id          =>    l_corps_definition_id
  ,p_object_version_number        =>    l_object_version_number
  ,p_business_group_id            =>    p_business_group_id
  ,p_name                         =>    p_name
  ,p_status_cd                    =>    p_status_cd
  ,p_retirement_age               =>    p_retirement_age
  ,p_category_cd                  =>    p_category_cd
  ,p_corps_type_cd                =>    p_corps_type_cd
  ,p_date_from         =>    p_date_from
  ,p_date_to           =>    p_date_to
  ,p_recruitment_end_date         =>    p_recruitment_end_date
  ,p_starting_grade_step_id       =>    p_starting_grade_step_id
  ,p_type_of_ps               =>    p_type_of_ps
  ,p_task_desc                    =>    p_task_desc
  ,p_secondment_threshold         =>    p_secondment_threshold
  ,p_normal_hours                 =>    p_normal_hours
  ,p_normal_hours_frequency       =>    p_normal_hours_frequency
  ,p_minimum_hours                =>    p_minimum_hours
  ,p_minimum_hours_frequency      =>    p_minimum_hours_frequency
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
  ,p_primary_prof_field_id        =>    p_primary_prof_field_id
  ,p_starting_grade_id            =>    p_starting_grade_id
  ,p_ben_pgm_id                   =>    p_ben_pgm_id
  ,p_probation_period             =>    p_probation_period
  ,p_probation_units              =>    p_probation_units
);

  begin
    --
    -- Start of API User Hook for the afetr hook of create_corps_definition
  pqh_corps_definitions_bk1.create_corps_definition_a
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_business_group_id            =>    p_business_group_id
  ,p_name                         =>    p_name
  ,p_status_cd                    =>    p_status_cd
  ,p_retirement_age               =>    p_retirement_age
  ,p_category_cd                  =>    p_category_cd
  ,p_corps_type_cd                =>    p_corps_type_cd
  ,p_date_from         =>    p_date_from
  ,p_date_to           =>    p_date_to
  ,p_recruitment_end_date         =>    p_recruitment_end_date
  ,p_starting_grade_step_id       =>    p_starting_grade_step_id
  ,p_type_of_ps               =>    p_type_of_ps
  ,p_task_desc                    =>    p_task_desc
  ,p_secondment_threshold         =>    p_secondment_threshold
  ,p_normal_hours                 =>    p_normal_hours
  ,p_normal_hours_frequency       =>    p_normal_hours_frequency
  ,p_minimum_hours                =>    p_minimum_hours
  ,p_minimum_hours_frequency      =>    p_minimum_hours_frequency
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
  ,p_primary_prof_field_id        =>    p_primary_prof_field_id
  ,p_starting_grade_id            =>    p_starting_grade_id
  ,p_ben_pgm_id                   =>    p_ben_pgm_id
  ,p_probation_period             =>    p_probation_period
  ,p_probation_units              =>    p_probation_units
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_corps_definition'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_corps_definition
    --
  end;

  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_corps_definition_id := l_corps_definition_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_corps_definition;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_corps_definition_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_corps_definition_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_corps_definition;
    raise;
    --
end create_corps_definition;

-- ----------------------------------------------------------------------------
-- |------------------------< update_corps_definition >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--
-- Name                           Reqd     Type     Description
-- p_validate                      YES     boolean  Commit or Rollback
-- p_corps_definition_id           YES     number   PK of record
-- p_effective_date                YES     date
-- p_business_group_id             NO      number
-- p_name                          NO      varchar2
-- p_status_cd                     NO      varchar2
-- p_retirement_age                NO      number
-- p_category_cd                   NO      varchar2
-- p_starting_grade_step_id        NO      number
-- p_type_of_ps                NO      varchar2
-- p_task_desc                         NO      varchar2
-- p_secondment_threshold          NO      number
-- p_normal_hours                  NO      number3
-- p_normal_hours_frequency        NO      varchar2
-- p_minimum_hours                 NO      number
-- p_minimum_hours_frequency       NO      varchar2
-- p_attribute1                    NO      varchar2
-- p_attribute2                    NO      varchar2
-- p_attribute3                    NO      varchar2
-- p_attribute4                    NO      varchar2
-- p_attribute5                    NO      varchar2
-- p_attribute6                    NO      varchar2
-- p_attribute7                    NO      varchar2
-- p_attribute8                    NO      varchar2
-- p_attribute9                    NO      varchar2
-- p_attribute10                   NO      varchar2
-- p_attribute11                   NO      varchar2
-- p_attribute12                   NO      varchar2
-- p_attribute13                   NO      varchar2
-- p_attribute14                   NO      varchar2
-- p_attribute15                   NO      varchar2
-- p_attribute16                   NO      varchar2
-- p_attribute17                   NO      varchar2
-- p_attribute18                   NO      varchar2
-- p_attribute19                   NO      varchar2
-- p_attribute20                   NO      varchar2
-- p_attribute21                   NO      varchar2
-- p_attribute22                   NO      varchar2
-- p_attribute23                   NO      varchar2
-- p_attribute24                   NO      varchar2
-- p_attribute25                   NO      varchar2
-- p_attribute26                   NO      varchar2
-- p_attribute27                   NO      varchar2
-- p_attribute28                   NO      varchar2
-- p_attribute29                   NO      varchar2
-- p_attribute30                   NO      varchar2
-- p_attribute_category            NO      varchar2
-- p_primary_prof_field_id         NO      number
-- p_starting_grade_id             NO      number
-- p_ben_pgm_id                    NO      number
-- p_probation_period              NO      number
-- p_probation_units               NO      varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_corps_definition
  (
  p_validate                      in    boolean    default false
  ,p_effective_date               in    date
  ,p_corps_definition_id          in    number
  ,p_business_group_id            in    number     default hr_api.g_number
  ,p_name                         in    varchar2   default hr_api.g_varchar2
  ,p_status_cd                    in    varchar2   default hr_api.g_varchar2
  ,p_retirement_age               in    number     default hr_api.g_number
  ,p_category_cd                  in    varchar2   default hr_api.g_varchar2
  ,p_starting_grade_step_id       in    number     default hr_api.g_number
  ,p_type_of_ps               in    varchar2   default hr_api.g_varchar2
  ,p_corps_type_cd                in    varchar2   default hr_api.g_varchar2
  ,p_date_from         in    date       default hr_api.g_date
  ,p_date_to           in    date       default hr_api.g_date
  ,p_recruitment_end_date         in    date       default hr_api.g_date
  ,p_task_desc                    in    varchar2   default hr_api.g_varchar2
  ,p_secondment_threshold         in    number     default hr_api.g_number
  ,p_normal_hours                 in    number     default hr_api.g_number
  ,p_normal_hours_frequency       in    varchar2   default hr_api.g_varchar2
  ,p_minimum_hours                in    number     default hr_api.g_number
  ,p_minimum_hours_frequency      in    varchar2   default hr_api.g_varchar2
  ,p_attribute1                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute2                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute3                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute4                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute5                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute6                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute7                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute8                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute9                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute10                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute11                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute12                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute13                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute14                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute15                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute16                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute17                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute18                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute19                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute20                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute21                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute22                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute23                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute24                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute25                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute26                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute27                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute28                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute29                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute30                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute_category           in    varchar2   default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy   number
  ,p_primary_prof_field_id          in number      default hr_api.g_number
  ,p_starting_grade_id              in number      default hr_api.g_number
  ,p_ben_pgm_id                     in number      default hr_api.g_number
  ,p_probation_period               in number      default hr_api.g_number
  ,p_probation_units                in varchar2    default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_corps_definition';
  l_object_version_number pqh_corps_definitions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_corps_definition;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_corps_definition
  pqh_corps_definitions_bk2.update_corps_definition_b
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_definition_id          =>    p_corps_definition_id
  ,p_business_group_id            =>    p_business_group_id
  ,p_object_version_number        =>    p_object_version_number
  ,p_name                         =>    p_name
  ,p_status_cd                    =>    p_status_cd
  ,p_retirement_age               =>    p_retirement_age
  ,p_category_cd                  =>    p_category_cd
  ,p_starting_grade_step_id       =>    p_starting_grade_step_id
  ,p_corps_type_cd                =>    p_corps_type_cd
  ,p_date_from         =>    p_date_from
  ,p_date_to           =>    p_date_to
  ,p_recruitment_end_date         =>    p_recruitment_end_date
  ,p_type_of_ps               =>    p_type_of_ps
  ,p_task_desc                    =>    p_task_desc
  ,p_secondment_threshold         =>    p_secondment_threshold
  ,p_normal_hours                 =>    p_normal_hours
  ,p_normal_hours_frequency       =>    p_normal_hours_frequency
  ,p_minimum_hours                =>    p_minimum_hours
  ,p_minimum_hours_frequency      =>    p_minimum_hours_frequency
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
  ,p_primary_prof_field_id        =>    p_primary_prof_field_id
  ,p_starting_grade_id            =>    p_starting_grade_id
  ,p_ben_pgm_id                   =>    p_ben_pgm_id
  ,p_probation_period             =>    p_probation_period
  ,p_probation_units              =>    p_probation_units
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'update_corps_definition'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_corps_definition
    --
  end;
  pqh_cpd_upd.upd
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_definition_id          =>    p_corps_definition_id
  ,p_object_version_number        =>    l_object_version_number
  ,p_business_group_id            =>    p_business_group_id
  ,p_name                         =>    p_name
  ,p_status_cd                    =>    p_status_cd
  ,p_retirement_age               =>    p_retirement_age
  ,p_category_cd                  =>    p_category_cd
  ,p_starting_grade_step_id       =>    p_starting_grade_step_id
  ,p_corps_type_cd                =>    p_corps_type_cd
  ,p_date_from         =>    p_date_from
  ,p_date_to           =>    p_date_to
  ,p_recruitment_end_date         =>    p_recruitment_end_date
  ,p_type_of_ps               =>    p_type_of_ps
  ,p_task_desc                    =>    p_task_desc
  ,p_secondment_threshold         =>    p_secondment_threshold
  ,p_normal_hours                 =>    p_normal_hours
  ,p_normal_hours_frequency       =>    p_normal_hours_frequency
  ,p_minimum_hours                =>    p_minimum_hours
  ,p_minimum_hours_frequency      =>    p_minimum_hours_frequency
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
  ,p_primary_prof_field_id        =>    p_primary_prof_field_id
  ,p_starting_grade_id            =>    p_starting_grade_id
  ,p_ben_pgm_id                   =>    p_ben_pgm_id
  ,p_probation_period             =>    p_probation_period
  ,p_probation_units              =>    p_probation_units
);

  begin
    --
    -- Start of API User Hook for the afetr hook of update_corps_definition
  pqh_corps_definitions_bk2.update_corps_definition_a
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_definition_id          =>    p_corps_definition_id
  ,p_business_group_id            =>    p_business_group_id
  ,p_object_version_number        =>    l_object_version_number
  ,p_name                         =>    p_name
  ,p_status_cd                    =>    p_status_cd
  ,p_retirement_age               =>    p_retirement_age
  ,p_category_cd                  =>    p_category_cd
  ,p_corps_type_cd                =>    p_corps_type_cd
  ,p_date_from         =>    p_date_from
  ,p_date_to           =>    p_date_to
  ,p_recruitment_end_date         =>    p_recruitment_end_date
  ,p_starting_grade_step_id       =>    p_starting_grade_step_id
  ,p_type_of_ps               =>    p_type_of_ps
  ,p_task_desc                    =>    p_task_desc
  ,p_secondment_threshold         =>    p_secondment_threshold
  ,p_normal_hours                 =>    p_normal_hours
  ,p_normal_hours_frequency       =>    p_normal_hours_frequency
  ,p_minimum_hours                =>    p_minimum_hours
  ,p_minimum_hours_frequency      =>    p_minimum_hours_frequency
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
  ,p_primary_prof_field_id        =>    p_primary_prof_field_id
  ,p_starting_grade_id            =>    p_starting_grade_id
  ,p_ben_pgm_id                   =>    p_ben_pgm_id
  ,p_probation_period             =>    p_probation_period
  ,p_probation_units              =>    p_probation_units
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'update_corps_definition'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_corps_definition
    --
  end;

  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_corps_definition;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_corps_definition;
    raise;
    --
end;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_corps_definition >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_corps_definition_id          Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_object_version_number        Yes  number    OVN of record

-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_corps_definition
  (
  p_validate                        in boolean        default false
  ,p_corps_definition_id            in  number
  ,p_object_version_number          in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_corps_definition';
  l_object_version_number pqh_corps_definitions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_corps_definition;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_corps_definition
    --
    pqh_corps_definitions_bk3.delete_corps_definition_b
      (
       p_corps_definition_id            =>  p_corps_definition_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_corps_definition'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_corps_definition
    --
  end;
  --
  PQH_CPD_del.del
    (
     p_corps_definition_id           => p_corps_definition_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_corps_definition
    --
    pqh_corps_definitions_bk3.delete_corps_definition_a
      (
       p_corps_definition_id            =>  p_corps_definition_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_corps_definition'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_corps_definition
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_corps_definition;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_corps_definition;
    raise;
    --
end delete_corps_definition;

--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_corps_definition_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  PQH_CPD_shd.lck
    (
      p_corps_definition_id                 => p_corps_definition_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_corps_definitions_api;

/
